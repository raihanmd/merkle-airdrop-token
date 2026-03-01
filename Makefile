include .env
export

.PHONY: build

build:
	FOUNDRY_PROFILE=solx forge build