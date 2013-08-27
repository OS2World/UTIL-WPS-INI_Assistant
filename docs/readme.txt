INI Assistent 0.0.7

0. Disclaimer

Freeware under GNU GPL. See enclosed file named copying.
Use at your own risk. This program can easily be used to destroy
vital parts of your system.

1. Purpose

None at all.;-)
Might save INI entries to REXX-.CMD files to restore them later or
somewhere else.;-)

2. Known problems

As this is a quick hack only, it's not been thoroughly tested and it's
not complete, however I've been using this a lot and it has worked well
despite one thing, that one has to be aware of:

ASCII-Mode only saves the entry up to the first byte with a value
of 0 (zero). The rest is truncated; the created REXX file is therefore
incomplete and not suitable for an exact restoration!!

Applying such an incomplete REXX script to vital parts of system or user
INI files can destroy your system completely!

Use ASCII-mode only if you are sure that there is no (not a single) zero 
byte within the selected INI entriy values (most entries are zero terminated,
but that's okay). Therefore, if you are not sure, what you are doing, do not
use ASCII mode!

Use Hex-mode to ensure complete saving! Hex mode should really be painless.

3. Usage

- Start INIAssi
- Choose the desired INI file
- Choose the desired application
- Ensure you have Hex-mode chosen (menu)
- Press "REXX"
- Enter desired filename
- Press "OK"
- You' re done (I hope so)

The GUI should be quite self explanatory...
There are no hidden cludges and features...
Help is not rather short, despite the fancy about box.

4. Source

Complete source is included. 
Developed with VX-REXX 2.1d.

5. Author

Herwig Bauernfeind

email: herwig.bauernfeind@aon.at
FidoNet: Herwig Bauernfeind@2:313/41.5
