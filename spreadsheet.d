module spreadsheet;
import std.stdio, std.regex, std.conv, std.string;

class Spreadsheet
{
	void Operation(string input)
	{
		auto singleCellRegex = ctRegex!r"([A-Z]+)([0-9]+)";
		if(match(input, singleCellRegex))
		{
		}
		else
			writeln("invalid");
	}

	string[Cell] worksheet;
	Cell[] selected;

	Cell[] selectCells(string formula)
	{
		auto rangeRegex = ctRegex!r"([A-Z]+)([0-9]+)(:([A-Z]+)([0-9]+))?";

		auto selected = List!Cell();

		foreach(cnt, relativePart; split(formula, '~')) 
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
						if (!cnt) selected.add(Cell(i,j));
						else selected.del(Cell(i,j));
			}
		}

		return selected.array;
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

private:
struct Cell
{
	int x,y;
	string toString() { return text(x, ",", y); }
}

struct List(T)
{
	private T[] _elements;
	@property int count() { return _elements.length; }
	@property T[] array() { return _elements.dup; }
	void add(T item) { _elements ~= item; }
	T get(int index) { return _elements[index]; }

	void del(T item)
	{
		foreach(i, e; _elements)
			if(e == item) 
			{
				if(i == 0) _elements = _elements[1..$];
				else if(i == _elements.length - 1) _elements = _elements[0..$-1];
				else _elements = _elements[0..i] ~ _elements[i+1..$];
				break;
			}
	}
}