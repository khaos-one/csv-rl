# csv-random-lines

A lightweight, memory-efficient tool written in Zig to extract a specified number of random lines from a CSV file and write them to a new CSV file. This program uses the Reservoir Sampling algorithm to handle large files without loading them entirely into memory.

## Features
- Stream-based processing for minimal memory usage
- Preserves the CSV header (if present)
- Handles arbitrarily long lines dynamically
- Cross-platform (tested on macOS, should work on Linux/Windows with minor adjustments)

## Prerequisites
- [Zig](https://ziglang.org/download/) compiler (version 0.13.0 or later recommended)
- (for macOS) macOS Command Line Tools (for macOS users): `xcode-select --install`

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/csv-random-lines.git
   cd csv-random-lines
   ```
2. Build the project:
   ```bash
   zig build -Doptimize=ReleaseFast
   ```
   
   The executable will be located in zig-out/bin/csv-rl.

   For macOS M1 (ARM64):
   ```bash
   zig build -Doptimize=ReleaseFast -Dtarget=aarch64-macos
   ```

# Usage

Run the program with three arguments:
- Input CSV file path
- Output CSV file path
- Number of random lines to extract

Example:
```bash
zig-out/bin/csv-random-lines input.csv output.csv 50
```

This selects 50 random lines from input.csv (excluding the header) and writes them to output.csv, preserving the header if it exists.

Alternatively, use the run step:
```
zig build run -- input.csv output.csv 50
```

# How It Works

- Uses Reservoir Sampling to select random lines with uniform probability
- Processes the file line-by-line, keeping only the selected lines in memory
- Dynamically allocates memory for lines of any length

# Limitations

- Assumes newline (\n) as the line delimiter
- Does not validate CSV format (assumes well-formed input)
