#!/bin/bash

pandoc --variable urlcolor=blue title.md README.md hello_world_c/README.md hello_world_asm/README.md time_libc/README.md -o debian-mips-tutorial.pdf
