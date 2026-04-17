# Top-level build for all 3D model designs in the repo.
#
# Auto-discovers every .scad file (outside 3mf/), parses its OpenSCAD
# Customizer parts annotation, and exports one 3MF per part to the design's
# 3mf/ directory. Also renders a PNG preview per .scad file and regenerates
# the README design catalog.
#
# See CLAUDE.md for the parts-declaration and README conventions.
#
# Targets:
#   make            — export 3MFs, render previews, refresh README
#   make list       — print the discovered designs and their parts
#   make <dir>      — build everything in one design directory
#   make readme     — refresh README catalog block only
#   make clean      — remove all generated 3MFs and previews

OPENSCAD   ?= /Applications/OpenSCAD-2021.01.app/Contents/MacOS/OpenSCAD
LIST_PARTS := $(CURDIR)/scripts/list-parts.sh
GEN_README := $(CURDIR)/scripts/gen-readme.sh
PREVIEW_SIZE ?= 1200,900

SCAD_FILES := $(shell find . -name '*.scad' -not -path '*/3mf/*' -not -path '*/.git/*' | sed 's|^\./||')

ALL_3MF :=
ALL_PNG :=

.DEFAULT_GOAL := all

# Multi-part design: one 3MF per declared part.
# Args: $(1)=scad path, $(2)=space-separated parts list
define multi_part_rules
ALL_3MF += $(foreach p,$(2),$(dir $(1))3mf/$(basename $(notdir $(1)))-$(p).3mf)

$(dir $(1))3mf/$(basename $(notdir $(1)))-%.3mf: $(1)
	@mkdir -p $$(@D)
	$$(OPENSCAD) -o $$@ -D 'part="$$*"' $$<
endef

# Single-part design: one combined 3MF.
# Args: $(1)=scad path
define single_part_rules
ALL_3MF += $(dir $(1))3mf/$(basename $(notdir $(1))).3mf

$(dir $(1))3mf/$(basename $(notdir $(1))).3mf: $(1)
	@mkdir -p $$(@D)
	$$(OPENSCAD) -o $$@ $$<
endef

# Preview PNG, always rendered with part="all" (harmless override for single-part).
# Args: $(1)=scad path
define preview_rule
ALL_PNG += $(dir $(1))$(basename $(notdir $(1))).png

$(dir $(1))$(basename $(notdir $(1))).png: $(1)
	@mkdir -p $$(@D)
	$$(OPENSCAD) --imgsize=$$(PREVIEW_SIZE) -D 'part="all"' -o $$@ $$<
endef

# Per-file dispatch: pick multi vs single based on whether the file declares parts.
define gen_rules
$$(eval _parts := $$(shell $(LIST_PARTS) $(1)))
$$(if $$(_parts),$$(eval $$(call multi_part_rules,$(1),$$(_parts))),$$(eval $$(call single_part_rules,$(1))))
$$(eval $$(call preview_rule,$(1)))
endef

$(foreach scad,$(SCAD_FILES),$(eval $(call gen_rules,$(scad))))

# Per-directory phony aliases: `make wire-mounts` builds 3MFs + preview for that dir.
DESIGN_DIRS := $(sort $(patsubst %/,%,$(dir $(SCAD_FILES))))
$(foreach d,$(DESIGN_DIRS),$(eval .PHONY: $(d))$(eval $(d): $(filter $(d)/%,$(ALL_3MF) $(ALL_PNG))))

.PHONY: all list readme clean

all: $(ALL_3MF) $(ALL_PNG) readme

readme: $(ALL_PNG)
	@$(GEN_README)

list:
	@for f in $(SCAD_FILES); do \
	    parts=$$($(LIST_PARTS) $$f); \
	    if [ -n "$$parts" ]; then \
	        printf '%s\n' "$$f"; \
	        printf '%s\n' "$$parts" | sed 's/^/  - /'; \
	    fi; \
	done

clean:
	rm -f $(ALL_3MF) $(ALL_PNG)
