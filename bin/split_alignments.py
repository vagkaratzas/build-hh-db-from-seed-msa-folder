#!/usr/bin/env python3

import os
import gzip
import argparse

def split_stockholm_gz(input_file, output_dir):
    os.makedirs(output_dir, exist_ok=True)

    with gzip.open(input_file, "rt", encoding="utf-8") as infile:
        block = []
        pfam_id = None
        for line in infile:
            if line.startswith("# STOCKHOLM 1.0"):
                block.clear()
                block.append(line)
                pfam_id = None
            elif line.startswith("#=GF AC"):
                # Direct slice instead of multiple splits
                acc = line[8:].strip()   # Get everything after "#=GF AC"
                pfam_id = acc.split(".", 1)[0]
                block.append(line)
            elif line.startswith("//"):
                block.append(line)
                if pfam_id:
                    outpath = os.path.join(output_dir, f"{pfam_id}.sto")
                    with open(outpath, "w", encoding="utf-8") as out:
                        out.writelines(block)
                else:
                    print("⚠️ Warning: block without Pfam ID, skipping")
            else:
                block.append(line)

    print(f"✅ Done! Wrote Stockholm blocks to '{output_dir}'")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Split a gzipped Stockholm alignment file into separate .sto files per Pfam ID."
    )
    parser.add_argument(
        "--downloaded_pfam_seed",
        help="Path to the gzipped Stockholm file (e.g., Pfam-A.seed.gz)"
    )
    parser.add_argument(
        "--out_folder",
        help="Directory where the extracted .sto files will be written"
    )

    args = parser.parse_args()

    if not os.path.isfile(args.downloaded_pfam_seed):
        parser.error(f"Input file '{args.downloaded_pfam_seed}' does not exist.")

    split_stockholm_gz(args.downloaded_pfam_seed, args.out_folder)
