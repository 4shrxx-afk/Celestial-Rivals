"""Bundle the Ui lib modules into single-file loadstring builds.

Reads Ui lib/<Module>.lua in dependency order, embeds each source inside
the Init.lua loader tail, and writes:
  - Ui lib/dist/CelestialUI.lua
  - CelestialUI.lua (repo root, for the shortest loadstring)

Usage:  python build.py
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent
SRC = ROOT / "Ui lib"
ORDER = [
    "Theme", "Utils", "Icons", "Config", "Settings",
    "ColorPicker", "Tab", "Toggle", "Slider", "Dropdown", "Window",
]
TAIL_MARKER = "-- Load order matters"


def _strip_lua(src: str) -> str:
    """Replace strings/comments with blanks so delimiters can be counted."""
    out: list[str] = []
    i, n = 0, len(src)
    while i < n:
        if src.startswith("--", i):
            m = re.match(r"--\[(=*)\[", src[i:])
            if m:
                closer = "]" + m.group(1) + "]"
                j = src.find(closer, i + m.end())
                i = n if j < 0 else j + len(closer)
                out.append(" ")
                continue
            j = src.find("\n", i)
            i = n if j < 0 else j
            out.append(" ")
            continue
        if src[i] in "\"'":
            q = src[i]
            j = i + 1
            while j < n and src[j] != q:
                if src[j] == "\\":
                    j += 1
                j += 1
            i = j + 1
            out.append('""')
            continue
        m = re.match(r"\[(=*)\[", src[i:])
        if m:
            closer = "]" + m.group(1) + "]"
            j = src.find(closer, i + m.end())
            i = n if j < 0 else j + len(closer)
            out.append('""')
            continue
        out.append(src[i])
        i += 1
    return "".join(out)


def check_structure(bundle: str) -> None:
    """Fail loudly on structural breakage (broken bundles never ship)."""
    code = _strip_lua(bundle)
    for a, b in (("(", ")"), ("{", "}"), ("[", "]")):
        if code.count(a) != code.count(b):
            sys.exit(f"build failed: unbalanced {a}{b} ({code.count(a)} vs {code.count(b)})")
    funcs = len(re.findall(r"\bfunction\b", code))
    ends = len(re.findall(r"\bend\b", code))
    if ends < funcs:
        sys.exit(f"build failed: {ends} ends for {funcs} functions")
    for token in ("local Library", "return Library", "local function need"):
        if token not in code:
            sys.exit(f"build failed: bundle missing {token!r}")
    print(f"structure : delimiters balanced, {ends} ends / {funcs} functions")


def main() -> None:
    embedded: dict[str, str] = {}
    for name in ORDER:
        p = SRC / f"{name}.lua"
        if not p.is_file():
            sys.exit(f"build failed: missing module {p}")
        src = p.read_text(encoding="utf-8")
        if "]==]" in src:
            sys.exit(f"build failed: {name}.lua contains ]==] (change long-bracket level)")
        embedded[name] = src

    init_src = (SRC / "Init.lua").read_text(encoding="utf-8")
    if TAIL_MARKER not in init_src:
        sys.exit("build failed: TAIL_MARKER not found in Init.lua")
    tail = TAIL_MARKER + init_src.split(TAIL_MARKER, 1)[1]

    # The dist bundle replaces Init's loader infra with embedded sources,
    # so it must still carry the Library table block (marked in Init.lua).
    # Without it, the tail's `Library._ThemeData = ...` indexes nil.
    HEAD_START = "-- BUNDLE_HEAD_START"
    HEAD_END = "-- BUNDLE_HEAD_END"
    lines = init_src.splitlines(keepends=True)
    try:
        s = next(i for i, l in enumerate(lines) if HEAD_START in l)
        e = next(i for i, l in enumerate(lines) if HEAD_END in l)
    except StopIteration:
        sys.exit("build failed: BUNDLE_HEAD markers not found in Init.lua")
    if e <= s:
        sys.exit("build failed: BUNDLE_HEAD_END comes before START")
    # Lines strictly between the marker lines (immune to same-line trailing text).
    head = "".join(lines[s + 1:e]).strip("\n")
    if "local Library" not in head:
        sys.exit("build failed: BUNDLE_HEAD block does not define Library")

    needed = sorted(set(re.findall(r'need\("([\w]+)"\)', tail)))
    missing = [n for n in needed if n not in embedded]
    if missing:
        sys.exit(f"build failed: unresolved modules: {missing}")

    parts = [
        "--[[\n"
        "    CelestialUI.lua — single-file bundle (GENERATED, do not edit).\n"
        "    Built by build.py from Ui lib/*.lua. Edit the modules, then rebuild.\n"
        "    Loadstring:\n"
        '      local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/4shrxx-afk/Celestial-Rivals/main/CelestialUI.lua"))()\n'
        "]]\n",
        "-- Embedded module sources (dependency order, resolved by need()).",
        "local __SRC = {}",
    ]
    for name in ORDER:
        parts.append(f'__SRC["{name}"] = [==[\n{embedded[name]}\n]==]')
    parts += [
        "local function need(name)",
        '    local src = __SRC[name]',
        '    assert(src, "[CelestialUI] missing embedded module: " .. tostring(name))',
        "    local fn, err = (loadstring or load)(src, \"@CelestialUI/\" .. name)",
        '    assert(fn, "[CelestialUI] load error in " .. tostring(name) .. ": " .. tostring(err))',
        "    return fn()",
        "end",
        "",
        head,
        "",
        tail,
    ]
    bundle = "\n".join(parts)
    check_structure(bundle)

    out_dist = SRC / "dist" / "CelestialUI.lua"
    out_root = ROOT / "CelestialUI.lua"
    out_dist.parent.mkdir(parents=True, exist_ok=True)
    out_dist.write_text(bundle, encoding="utf-8")
    out_root.write_text(bundle, encoding="utf-8")

    print(f"modules : {len(ORDER)} ({', '.join(ORDER)})")
    print(f"need()  : {', '.join(needed)}")
    total = 0
    for name in ORDER:
        n = len(embedded[name].encode("utf-8"))
        total += n
        print(f"  {name:12s} {n:7d} bytes")
    print(f"bundle  : {len(bundle.encode('utf-8')):7d} bytes -> {out_root} + {out_dist}")


if __name__ == "__main__":
    main()
