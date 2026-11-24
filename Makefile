PREFIX ?= /usr/local
USER_HOME ?= $(shell getent passwd "$${SUDO_USER:-$${USER}}" | cut -d: -f6)
SHELLRC ?= $(USER_HOME)/.bashrc

install:
	install -d $(PREFIX)/bin
	install -d $(PREFIX)/lib/astat

	install -m644 src/*.sh $(PREFIX)/lib/astat/

	ln -sf ../lib/astat/main.sh $(PREFIX)/bin/astat.sh
	grep -qF 'astat() {' $(SHELLRC) || \
		printf '\nastat() { source $(PREFIX)/bin/astat.sh "$$@"; }\n' >> $(SHELLRC)

uninstall:
	rm -f "$(PREFIX)/bin/astat"
	rm -rf "$(PREFIX)/lib/astat/"
	@if [ -f "$(SHELLRC)" ]; then \
		sed -i '/^astat() {/d' "$(SHELLRC)"; \
	fi