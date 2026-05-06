.PHONY = clean uninstall
.RECIPEPREFIX = >

INSTALL_DIR    = $(HOME)/.bin
STRELITZIA     = $(INSTALL_DIR)/strelitzia

$(STRELITZIA): main.rkt \
               helpers.rkt \
               utils.rkt \
               say.rkt \
               tlmgr.rkt \
               tex.rkt
> @[ -d $(INSTALL_DIR) ] || mkdir -p $(INSTALL_DIR)
> @(echo ":$(PATH):" | grep -q ":$(INSTALL_DIR):") || echo "$(INSTALL_DIR) not in PATH!"
> @raco exe -v -o $(STRELITZIA) $<

clean:
> @rm -fr compiled

uninstall: clean
> @rm $(STRELITZIA)

