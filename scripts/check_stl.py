#!/usr/bin/env python3
"""Sanity-check exported STLs: watertight-ish triangle count + bounding box.

Figures must stand ~70mm tall and everything must fit the Neptune 4 bed
(225 x 225 x 265mm) with room to spare. Pure stdlib, handles binary + ascii STL.
"""
import struct
import sys

BED = (225, 225, 265)
FIGURES = {"rifleman", "officer", "heavy"}


def read_stl(path):
    with open(path, "rb") as f:
        data = f.read()
    if data[:5] == b"solid" and b"facet" in data[:200]:
        tris = []
        vals = []
        for line in data.decode(errors="ignore").splitlines():
            parts = line.split()
            if parts[:1] == ["vertex"]:
                vals.append(tuple(float(v) for v in parts[1:4]))
        tris = [vals[i:i + 3] for i in range(0, len(vals), 3)]
        return tris
    n = struct.unpack_from("<I", data, 80)[0]
    tris = []
    off = 84
    for _ in range(n):
        v = struct.unpack_from("<12f", data, off)
        tris.append([v[3:6], v[6:9], v[9:12]])
        off += 50
    return tris


def floating_components(tris):
    """Connected components whose lowest point is above the bed — these are
    midair geometry that slicers reject."""
    parent = {}

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    for t in tris:
        vs = [tuple(v) for v in t]
        for v in vs:
            parent.setdefault(v, v)
        for v in vs[1:]:
            ra, rb = find(vs[0]), find(v)
            if ra != rb:
                parent[ra] = rb
    zmin = {}
    for t in tris:
        r = find(tuple(t[0]))
        zmin[r] = min(zmin.get(r, 1e9), min(v[2] for v in t))
    return [z for z in zmin.values() if z > 0.5]


def main(paths):
    failed = False
    for path in paths:
        name = path.rsplit("/", 1)[-1].removesuffix(".stl")
        tris = read_stl(path)
        if not tris:
            print(f"FAIL {name}: no triangles")
            failed = True
            continue
        xs, ys, zs = zip(*[v for t in tris for v in t])
        dims = (max(xs) - min(xs), max(ys) - min(ys), max(zs) - min(zs))
        problems = []
        if any(d > b for d, b in zip(dims, BED)):
            problems.append("exceeds bed")
        if name in FIGURES and not 60 <= dims[2] <= 80:
            problems.append(f"height {dims[2]:.1f}mm not ~70mm")
        if min(zs) < -0.01:
            problems.append(f"geometry below z=0 (min z {min(zs):.2f})")
        floating = floating_components(tris)
        if floating:
            problems.append(
                f"{len(floating)} floating part(s) at z={min(floating):.1f}")
        status = "FAIL" if problems else "ok"
        failed |= bool(problems)
        print(f"{status:4} {name}: {len(tris)} tris, "
              f"{dims[0]:.1f} x {dims[1]:.1f} x {dims[2]:.1f}mm"
              + (" — " + ", ".join(problems) if problems else ""))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
