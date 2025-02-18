KICAD = /Applications/KiCad/KiCad.app/Contents/MacOS/kicad-cli
LAYERS = F.Cu,In1.Cu,In2.Cu,B.Cu,F.Paste,F.SilkS,B.SilkS,F.Mask,B.Mask,Edge.Cuts

PYTHON = python3
BOM_SCRIPT =  ../GW_KiCADBuild/export_bom.py

F_PCB = $@/../WarpSE-Overclocking-Board.kicad_pcb
F_SCH = $@/../WarpSE-Overclocking-Board.kicad_sch
F_NETLIST = $@/WarpSE-OCBoard-NET.xml
F_BOM = $@/WarpSE-Overclocking-Board-BOM.csv
F_POS = $@/WarpSE-Overclocking-Board-top-pos.csv
F_ZIP = $@/WarpSE-Overclocking-Board-gerber.zip
F_SCHPDF = $@/WarpSE-Overclocking-Board-Schematic.pdf
F_PCBPDF = $@/WarpSE-Overclocking-Board-Placement.pdf


OPT_GERBER = -l $(LAYERS) --subtract-soldermask --no-netlist --no-x2
CMD_GERBER = pcb export gerbers $(OPT_GERBER) -o $@/ $(F_PCB)

CMD_DRILL = pcb export drill -o $@/ $(F_PCB)

CMD_NETLIST = sch export netlist --format kicadxml -o $(F_NETLIST) $(F_SCH)

OPT_POS = --smd-only --units mm --side front --format csv
CMD_POS = pcb export pos $(OPT_POS) -o $(F_POS) $(F_PCB)

CMD_SCHPDF = sch export pdf --black-and-white --no-background-color -o $(F_SCHPDF) $(F_SCH)
CMD_PCBPDF = pcb export pdf --black-and-white -l F.Fab,Edge.Cuts -o $(F_PCBPDF) $(F_PCB)


.PHONY: all clean gerber stencil Documentation rom
all: gerber stencil Documentation rom
clean:
	rm -fr gerber/
	rm -f  Documentation/WarpSE-Overclocking-Board-Schematic.pdf
	rm -f  Documentation/WarpSE-Overclocking-Board-Placement.pdf

gerber:
	mkdir -p $@
	$(KICAD) $(CMD_GERBER)
	$(KICAD) $(CMD_DRILL)
	$(KICAD) $(CMD_POS)
	$(KICAD) $(CMD_NETLIST)
	sed -i '' 's/PosX/MidX/g' $(F_POS)
	sed -i '' 's/PosY/MidY/g' $(F_POS)
	sed -i '' 's/Rot/Rotation/g' $(F_POS)
	$(PYTHON) $(BOM_SCRIPT) $(F_NETLIST) $(F_BOM)
	rm -f $(F_ZIP)
	zip -r $(F_ZIP) $@/

Documentation:
	mkdir -p $@
	$(KICAD) $(CMD_SCHPDF)
	$(KICAD) $(CMD_PCBPDF)
