#!/bin/bash
cd "$1" 2>/dev/null || exit 1
git branch --show-current 2>/dev/null