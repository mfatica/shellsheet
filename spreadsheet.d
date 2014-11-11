module spreadsheet;

import CellRange : CellRange;
import CellValue : CellValue;
import regex;

import std.stdio;
import std.string;


class Spreadsheet
{
	CellRange worksheet;

	void Operation(string input)
	{
		input = input.toUpper.strip;
		input = replaceAll(input, ctRegex!r"\s", "");

		if(match(input, singleCellRegex)) writeln(lookupCell(input));
		else if(indexOf(input, '=') > -1)
		{
			auto equation = split(input, '=');
			setCells(equation[0], equation[1]);
		}
	}

	void setCells(string range, string value)
	{
		worksheet ~= CellRange(range) = value;
	}

	double lookupCell(string cell)
	{
		return cell in worksheet ? worksheet[cell].value : 0;
	}
}