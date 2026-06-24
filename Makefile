.PHONY: tp1-build tp1-run tp1-test tp1-stop tp1-clean tp1-tag

tp1-build:
	$(MAKE) -C tp1 build

tp1-run:
	$(MAKE) -C tp1 run

tp1-test:
	$(MAKE) -C tp1 test

tp1-stop:
	$(MAKE) -C tp1 stop

tp1-clean:
	$(MAKE) -C tp1 clean

tp1-tag:
	$(MAKE) -C tp1 tag
