PREFIX ?= /usr/local

install:
	install -d $(PREFIX)/bin
	install -d $(PREFIX)/lib/astat

	install -m644 src/*.sh $(PREFIX)/lib/astat/

	ln -sf ../lib/astat/astat.sh $(PREFIX)/bin/astat
	grep -qF 'astat() {' $(BASHRC) || \
		printf '\nastat() {\n\tsource $(PREFIX)/bin/astat "$$@"\n}\n' >> $(BASHRC)
