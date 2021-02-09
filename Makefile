##
# PlantUML k8s library
#
# @file
# @version 0.1
SDIR = src
DEST = k8s

SVG_SRC = $(call rwildcard, src/, *.svg)
PNG_SRC = $(SVG_SRC:svg=png)
SPRITE_SRC = $(PNG_SRC:png=sprite)

BUILD_DIRS = $(subst $(SDIR),$(DEST),$(sort $(dir $(SVG_SRC))))
PUML_FILES = $(addsuffix all.puml, $(BUILD_DIRS))

rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

all: make_dirs $(PNG_SRC) $(SPRITE_SRC) $(PUML_FILES) $(DEST)/common.puml

.PHONY: make_dirs
make_dirs: $(BUILD_DIRS)

$(BUILD_DIRS):
	mkdir -p $@

%.png: %.svg
	cat $< | sed -e "s/326ce5/000000/g" | rsvg-convert -b white -w 128 -f png > $@

%.sprite: %.png
	java -jar ~/.emacs.d/.local/etc/plantuml.jar -encodesprite 16z $< > $@
	sed -i -e 's#\$$\w\+\b#\$$$(subst -,_,$(notdir $*))#' $@

%.puml: $(SPRITE_SRC)
	 cat $(dir $(@:$(DEST)/%=$(SDIR)/%))*.sprite > $@

$(DEST)/common.puml: common.puml
	cp common.puml $(DEST)/common.puml

.PHONY: clean
clean:
	rm $(PNG_SRC) $(SPRITE_SRC)

.PHONY: distclean
distclean: clean
	rm -rf $(DEST)/

# end
