# svg_to_gcode_scratchnetch

Convert SVGs exported from KiCad to gcode for scratch 'n etch PCBs with a RepRap variant.

Runs in Processing (3.2.3). requires the ControlP5 and Geomerative libraries.

There are various variables in the "Configuration" section that will need to be customized for your setup.

A typical workflow for a single-sided board is to design your PCB in KiCAD so that throughhole components are on the top, and all traces and SMD components are on the bottom. (Traces on the top layer can be used to represent jumper wires.) Place the design near the top-left of the Pcbnew work area. Export just the bottom layer ("B.cu"), uncheck "Print board edges", and check "Print mirrored". Place the svg in the "data" folder of the Processing sketch, and change the "filename_in" to your svg's filename.
