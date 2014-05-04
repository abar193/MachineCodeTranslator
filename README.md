Small utility, written in D programing language to make process of reading MIPS Machine code instructions codes easier. 

Reads instructions, knows their format ("R"/"I"/"J"), parses their content - opcode, registers/addresses. Translates register numbers into names like 0 is $zero, or 8 is $t0.

Right now it works that way: you copy commands you want to translate in some text file, one at the line. Example for such a file - "inputexample.txt". Please note: after the very last command should be newline character, or space - otherwise that command will loose it's last character.    

Then, all you have to do is launch mct.exe from the console with path to file as single parameter. If you have carefully followed all the instructions abowe you will see the table with extracted information. Now, all you have to do, is to translate opcodes/functs with MIPS_Green_Card (https://www.isis.tu-berlin.de/2.0/pluginfile.php/92082/mod_folder/content/0/MIPS_Green_Card.pdf).

Please note: this utility is provided "as-is", without any garanties. Wrong input data may cause it to crash, or I may have missed something, and some data are being interpretated wrong. Use it with caution. 