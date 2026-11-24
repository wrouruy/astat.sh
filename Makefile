PREFIX ?= /usr/local
USER_HOME ?= $(shell getent passwd "$${SUDO_USER:-$${USER}}" | cut -d: -f6)
BASHRC ?= $(USER_HOME)/.bashrc

install:
	install -d $(PREFIX)/bin
	install -d $(PREFIX)/lib/astat

	install -m644 src/*.sh $(PREFIX)/lib/astat/

	ln -sf ../lib/astat/main.sh $(PREFIX)/bin/astat
	grep -qF 'astat() {' $(BASHRC) || \
		printf '\nastat() {\n\tsource $(PREFIX)/bin/astat "$$@"\n}\n' >> $(BASHRC)
