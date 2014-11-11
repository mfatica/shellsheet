module CellRange;

import regex;
import CellValue : CellValue;

import std.conv;
import std.string;

struct CellRange
{
	CellValue[string] Cells;
	alias Cells this;

	this(string range, string expression)
	{
		bool add = true;
		foreach(relativePart; split(range, '~')) 
		{
			foreach(rangePart; split(relativePart, '&'))
			{
				auto cellParts = match(rangePart, rangeRegex).captures;
				int colmin = fromBase26(cellParts[1]) - 1;
				int rowmin = to!int(cellParts[2]) - 1;
				int colmax = (cellParts[4].count > 0 ? fromBase26(cellParts[4]) : colmin + 1);
				int rowmax = (cellParts[5].count > 0 ? to!int(cellParts[5]) : rowmin + 1);

				foreach(i; colmin..colmax)
					foreach(j; rowmin..rowmax)
					{
						string cell = text(toBase26(i+1), j + 1);
						if (add) Cells[cell] = CellValue(expression);
						else Cells.remove(cell);
					}
			}
			add = !add;
		}
	}

	this(string range)
	{
		this(range, "0");
	}

	ref CellRange opAssign(string expression)
	{
		foreach(cell; Cells.keys)
		{
			Cells[cell] = expression;
		}
		return this;
	}

	ref CellRange opOpAssign(string op)(CellRange range)
	{
		return this ~ range;
	}

	ref CellRange opBinary(string op)(CellRange range)
	if(op == "~")
	{
		foreach(cell, exp; range)
		{
			this[cell] = exp;
		}
		return this;
	}

	pure string toBase26(int n)
	{
		char[] ret;
		while(n > 0)
		{
			--n;
			ret ~= ('A' + (n%26));
			n /= 26;
		}

		return cast(string)ret.reverse;
	}

	pure int fromBase26(string number)
	{
		number = number.toUpper;
		int decimalValue = 0;
		for(int i = number.length-1; i > -1; i--)
		{
			decimalValue += 25 * i;
			decimalValue += (number[i] - 64);
		}
		return decimalValue;
	}
}