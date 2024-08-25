.PHONY = doc clean uninstall
.RECIPEPREFIX = >

INSTALL_DIR    = $(HOME)/.local/bin
STRELITZIA     = $(INSTALL_DIR)/strelitzia
STRELITZIA_DOC = $(INSTALL_DIR)/strelitzia.md

$(STRELITZIA): main.rkt \
               parsers.rkt \
               run-shell.rkt \
               say.rkt \
               tlmgr.rkt
> @[ -d $(INSTALL_DIR) ] || mkdir -p $(INSTALL_DIR)
> @(echo ":$(PATH):" | grep -q ":$(INSTALL_DIR):") || echo "$(INSTALL_DIR) not in PATH!"
> @raco exe -o $(STRELITZIA) $<

doc: $(STRELITZIA_DOC)

$(STRELITZIA_DOC): README.md
> @cp README.md $(STRELITZIA_DOC)

clean:
> @rm -fr compiled

uninstall: clean
> @rm $(STRELITZIA)
> @rm $(STRELITZIA_DOC)

