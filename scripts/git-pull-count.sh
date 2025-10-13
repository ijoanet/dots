#!/bin/bash
cd "$1" 2>/dev/null || exit 1
git rev-list --count HEAD..@{upstream} 2>/dev/null | awk '{if($1>0) printf "↓%d", $1}'
