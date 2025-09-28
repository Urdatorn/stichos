import os 
import re

dir = "~/git/hypotactic/hypotactic_txts_greek"
textfiles = [os.path.join(dir, file) for file in os.listdir(dir) if file.endswith(".txt")]

hexameter = re.compile(r"^(--|-uu|uuuu){5}--$") # no anapaests
penthemimeres_f = re.compile(r"^(-\s*-\s*|-\s*u\s*u\s*|u\s*u\s*-\s*|u\s*u\s*u\s*u\s*){2}-u\s")
penthemimeres_m = re.compile(r"^(-\s*-\s*|-\s*u\s*u\s*|u\s*u\s*-\s*|u\s*u\s*u\s*u\s*){2}-\s")
hepthemimeres = re.compile(r"^(-\s*-\s*|-\s*u\s*u\s*|u\s*u\s*-\s*|u\s*u\s*u\s*u\s*){3}-\s")
trithemimeres = re.compile(r"^(-\s*-\s*|-\s*u\s*u\s*|u\s*u\s*-\s*|u\s*u\s*u\s*u\s*){1}-\s")

pentameter = re.compile(r"^(--|-uu|uu-|uuuu){2}-(--|-uu|uu-|uuuu){2}-$")

anapaests = re.compile(r'^(?:(?:--|-uu|uu-){2})*$')

trimeter_tragic = re.compile(r"^(--u-|u-u-|uu-u-|uuuuu_|uuuuuuu){3}$")
trimeter_comic  = re.compile(r"^(--u-|u-u-|uu-u-|uuuuu_|uuuuuuu|--uu-|u-uu-|uu-uu-|uuuuuu_|uuuuuuuu){3}$")
not_porson = re.compile(r".*--\s+-\s*u\s*-$")


outdir = "tsv"
if not os.path.exists(outdir):
    os.mkdir(outdir)
pattern = re.compile(r"\[(.+?)\]")
for textfile in textfiles: 
    with open(textfile, "r", encoding="utf-8") as file:
        lines = file.readlines()
        tablines = []
        for line in lines:
            tabs = re.findall(pattern, line)
            if re.match(hexameter, tabs[1].replace(" ", "")):
                tabs.append("dactylic hexameter")
                caesurae = []
                if re.match(penthemimeres_f, tabs[1]):
                    caesurae.append("feminine penthemimeral")
                elif re.match(penthemimeres_m, tabs[1]):
                    caesurae.append("masculine penthemimeral")
                if re.match(hepthemimeres, tabs[1]):
                    caesurae.append("hepthemimeral")
                if re.match(trithemimeres, tabs[1]):
                    caesurae.append("trithemimeral")
                if caesurae:
                    tabs.append(", ".join(caesurae))

            elif re.match(trimeter_tragic, tabs[1].replace(" ", "")):
                tabs.append("iambic trimeter (tragic)")
                if re.match(not_porson, tabs[1]):
                    tabs.append("Not Porson")
            elif re.match(trimeter_comic, tabs[1].replace(" ", "")):
                tabs.append("iambic trimeter (anapaestic)")
                if re.match(not_porson, tabs[1]):
                    tabs.append("Not Porson")
            elif re.match(pentameter, tabs[1].replace(" ", "")):
                tabs.append("dactylic pentameter")
            elif re.match(anapaests, tabs[1].replace(" ", "")):
                tabs.append("anapaestic")
            else:
                tabs.append("lyric")
            if len(tabs) < 4:
                tabs.append("")

            tablines.append(tabs)

    with open(os.path.join(outdir, os.path.basename(textfile).replace(".txt", ".tsv")), "w", encoding="utf-8") as outfile:
        for tabline in tablines:
            outfile.write("\t".join(tabline) + "\n")

