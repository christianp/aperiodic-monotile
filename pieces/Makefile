PIECES=$(wildcard *.svg)
STLS=$(patsubst %.svg, %.stl, $(PIECES))

%.stl: %.svg
	openscad-nightly piece.scad -D "piece=\"$<\"" -o $@

stls: $(STLS)
	echo $(STLS)
