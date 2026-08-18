# Host build of the board-agnostic core + its tests. No ESP-IDF needed.
#   make test
CC      ?= clang
CFLAGS  ?= -std=c11 -Wall -Wextra -O2
CORE    := core/ble_ow.c core/sha1.c core/totp.c core/pedometer.c
TESTBIN := /tmp/ow_core_test

.PHONY: test
test:
	$(CC) $(CFLAGS) $(CORE) test/test_core.c -o $(TESTBIN) -lm
	$(TESTBIN)
