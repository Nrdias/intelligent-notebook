#!/bin/bash
# Script to convert SVG icons to .si binary files for jovial_svg
# Usage: ./scripts/generate_si.sh [source_directory]

SRC_DIR="${1:-assets/icons/svg}"
OUT_DIR="assets/icons"

if [ ! -d "$SRC_DIR" ]; then
  echo "Error: Source directory $SRC_DIR does not exist."
  exit 1
fi

mkdir -p "$OUT_DIR"

echo "Converting SVG icons from $SRC_DIR to $OUT_DIR..."
dart run jovial_svg:svg_to_si -o "$OUT_DIR/" "$SRC_DIR"/*.svg

echo "Done converting SVG icons to .si binary assets!"
