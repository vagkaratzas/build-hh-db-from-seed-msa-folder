#!/usr/bin/env python3

import os
import gzip
import argparse

def split_stockholm_gz(input_file, output_dir, mapping_file=None):
    os.makedirs(output_dir, exist_ok=True)

    mapping_out = None
    mapping_count = 0
    if mapping_file:
        mapping_dir = os.path.dirname(mapping_file)
        if mapping_dir:
            os.makedirs(mapping_dir, exist_ok=True)
        mapping_out = open(mapping_file, "w", encoding="utf-8")
        mapping_out.write("rep_seq\tpfam\n")

    wrote = 0
    with gzip.open(input_file, "rt", encoding="utf-8") as infile:
        block = []
        first_gs = None
        ac = None
        id_ = None
        de = None

        for line in infile:
            if line.startswith("# STOCKHOLM 1.0"):
                # New block begins
                block.clear()
                block.append(line)
                first_gs = None
                ac = None
                id_ = None
                de = None
            elif line.startswith("#=GS "):
                # "#=GS <seqname> ..." -> take the first token after "#=GS"
                parts = line.split()
                if len(parts) >= 2 and first_gs is None:
                    first_gs = parts[1]
                block.append(line)
            elif line.startswith("#=GF "):
                # GF lines: e.g. "#=GF AC   PF00244.27"
                # split on whitespace; structure: ['#=GF', 'AC', 'PF00244.27']
                parts = line.split(None, 2)
                if len(parts) >= 3:
                    tag = parts[1].strip()
                    value = parts[2].strip()
                    if tag == "AC":
                        ac = value
                    elif tag == "ID":
                        id_ = value
                    elif tag == "DE":
                        de = value
                block.append(line)
            elif line.startswith("//"):
                block.append(line)
                # Write .sto file if we have AC (pfam accession)
                if ac:
                    outpath = os.path.join(output_dir, f"{ac}.sto")
                    with open(outpath, "w", encoding="utf-8") as out:
                        out.writelines(block)
                    wrote += 1
                else:
                    print("⚠️ Warning: block without Pfam AC, skipping .sto write")

                # Write mapping line if requested
                if mapping_out:
                    if first_gs and ac:
                        mapping_out.write(f"{first_gs}\t{ac} ; { id_ or '' } ; { de or '' }\n")
                        mapping_count += 1
                    else:
                        # if mapping requested but missing fields, print a warning and still write what we can
                        if ac:
                            mapping_out.write(f"{first_gs or ''}\t{ac} ; { id_ or '' } ; { de or '' }\n")
                            mapping_count += 1
                        else:
                            print("⚠️ Warning: cannot write mapping for block (missing AC)")

            else:
                block.append(line)

    if mapping_out:
        mapping_out.close()

    print(f"✅ Done! Wrote {wrote} Stockholm .sto files to '{output_dir}'")
    if mapping_file:
        print(f"✅ Wrote mapping file '{mapping_file}' with {mapping_count} entries")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Split a gzipped Stockholm alignment file into separate .sto files per Pfam ID and optionally create a mapping of first #=GS -> AC/ID/DE."
    )
    parser.add_argument(
        "--downloaded_pfam_seed",
        required=True,
        help="Path to the gzipped Stockholm file (e.g., Pfam-A.seed.gz)"
    )
    parser.add_argument(
        "--out_folder",
        required=True,
        help="Directory where the extracted .sto files will be written"
    )
    parser.add_argument(
        "--mapping_file",
        required=False,
        help="Optional path to write mapping TSV (seq_name<TAB>AC<TAB>ID<TAB>DE)"
    )

    args = parser.parse_args()

    if not os.path.isfile(args.downloaded_pfam_seed):
        parser.error(f"Input file '{args.downloaded_pfam_seed}' does not exist.")

    split_stockholm_gz(args.downloaded_pfam_seed, args.out_folder, args.mapping_file)
