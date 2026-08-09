# Renders every model: .scad source -> stl/ (print-ready) + previews/ (png)
# macOS default; override with `make OPENSCAD=openscad` on Linux/Windows
OPENSCAD ?= $(firstword $(wildcard /Applications/OpenSCAD*.app/Contents/MacOS/OpenSCAD) openscad)

SRCS := $(wildcard scad/figures/*.scad) $(wildcard scad/weapons/*.scad) scad/fit-test.scad
NAMES := $(basename $(notdir $(SRCS)))
STLS  := $(addprefix stl/,$(addsuffix .stl,$(NAMES)))
PNGS  := $(addprefix previews/,$(addsuffix .png,$(NAMES)))

VPATH := scad/figures:scad/weapons:scad

all: $(STLS) $(PNGS)

stl/%.stl: %.scad scad/lib/soldier.scad
	@mkdir -p stl
	$(OPENSCAD) -o $@ $<

previews/%.png: %.scad scad/lib/soldier.scad
	@mkdir -p previews
	$(OPENSCAD) --render --autocenter --viewall --imgsize 900,900 -o $@ $<

check: $(STLS)
	python3 scripts/check_stl.py stl/*.stl

clean:
	rm -rf stl previews

.PHONY: all check clean
