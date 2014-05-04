import std.stdio, std.conv, std.string, std.format;
import std.c.stdio, std.array;

/** Single MIPS command */
struct machComm {
	char type;
	int opcode, rs, rt, rd, shamt, func, bigvalue;
}

/** Generates mask of ones (1-bit) from starting bit till ending
*/
uint generateMask (int startingBit, int endingBit)
{
	int mask = 0;
	int i;
	for(i = startingBit; i > endingBit; i--) {
		int temp = 1 << i; 
		mask |= temp;
	}

	if (endingBit == 0) mask |= 1;
	else mask |= 1 << (endingBit);

	return mask;	
}

/** Translates register (0..31) into string with register names */
string regTranslator(int register)
{
	switch(register)
	{
		case 0: return "$zero";
		case 1: return "$at";
		case 2:
		case 3: 
			return "$v" ~ to!string(register - 2);
		case 4:
		.. 
		case 7:
			return "$a" ~ to!string(register - 4);
		case 8:
		..
		case 15:
			return "$t" ~ to!string(register - 8);
		case 16:
		..
		case 23:
			return "$s" ~ to!string(register - 16);
		case 24: return "$t8";
		case 25: return "$t9";
		case 26: return "$k0";
		case 27: return "$k1";
		case 28: return "$gp";
		case 29: return "$sp";
		case 30: return "$fp";
		case 31: return "$ra";
		default: return "ERR!";
	}
}

/** Generates output string for a given machComm  */
string commandVisualisator(machComm command)
{
	auto writer = appender!string();
	with(command) {

		if(command.type == 'R') {
			formattedWrite(writer, "|R|%* 6d|%* 5s|%* 5s|%* 5s|%* 5d|%* 6d|", opcode, regTranslator(rs), regTranslator(rt), regTranslator(rd), shamt, func);
		} else if(command.type == 'I') {
			formattedWrite(writer, "|I|%* 6d|%* 5s|%* 5s|%* 18d|", opcode, regTranslator(rs), regTranslator(rt), bigvalue);
		} else if(command.type == 'J') {
			formattedWrite(writer, "|J|%* 6d|%* 30d|", opcode, bigvalue);
		}
	}	

	return writer.data;
}

/** Translates 32-bit command word into machComm  */ 
machComm commandTranslator(uint command)
{
	machComm retVal;

	int opcode = command >> 26;
	retVal.opcode = opcode;

	if (opcode == 0) 
	{
		retVal.type = 'R';

		retVal.rs = (command & generateMask(25, 21)) >> 21;
		retVal.rt = (command & generateMask(20, 16)) >> 16;
		retVal.rd = (command & generateMask(15, 11)) >> 11;
		retVal.shamt = (command & generateMask(10, 6)) >> 6;
		retVal.func = (command & generateMask(5, 0));
	} 
	else 
	{
		if(opcode == 2 || opcode == 3) 
		{
			retVal.type = 'J';
			retVal.bigvalue = (command & generateMask(25, 0));
		} 
		else 
		{
			retVal.type = 'I';

			retVal.rs = (command & generateMask(25, 21)) >> 21;
			retVal.rt = (command & generateMask(20, 16)) >> 16;	
			retVal.bigvalue = (command & generateMask(15, 0));
		}
	}

	return retVal;
}

/** Translates string to command word 
 * Params:
 * command = input string. If it starts with leading "0x", then in is being read as hexadezimal word, otherwise it will be interpreted 
 * 		as decimal number
 * Returns: uint - command word
 * TODO: add more tests, wrap in try-catch block, because right now this function is the most weak part of the whole utility
*/
uint stringToInt(string command)
{
	if(indexOf(command, "0x") == 0) 
	{
		command = command[2..command.length];
		return parse!int(command, 16);
	} else return parse!int(command);

	return 0;
}

/** A simple translator from machine code into MIPS-assembler commands
 * It's buggy and ugly, but as starting point it will go
 * Authors: Anton Bardishev
 */
int main(string[] arg)
{
	
	if(arg.length != 2) {
		writeln("Usage: mct.exe %filename%");
		return 0;
	}

	writefln("           |R|%* 6s|%* 5s|%* 5s|%* 5s|%* 5s|%* 6s|", "opcode", "rs", "rt", "rd", "shamt", "func");
	writefln("           |I|%* 6s|%* 5s|%* 5s|%* 18s|", "opcode", "rs", "rt", "immediate");
	writefln("           |J|%* 6s|%* 30s|", "opcode", "adress");
	writeln("=========================================");
	
	auto f = File(arg[1], "r");
	foreach (string line; lines(f))
  	{
   		line = line[0..line.length - 1];
   		line ~= " " ~ commandVisualisator(commandTranslator(stringToInt(line)));
   		writeln(line);
  	}
  	f.close();
  	writeln("\nPlease, check that the last symbol in the last command was not cut from the input, since I'm too lazy to do it");
	/*
	writeln(stringToInt("0x20090000"));
	commandTranslator(537460736); // 537460736*/
	return 0;
}
