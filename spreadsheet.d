module spreadsheet;
import std.stdio, std.regex, std.conv, std.string, std.array, std.algorithm, std.range;

private enum rangeRegex = ctRegex!r"([A-Z]+)([0-9]+)(:([A-Z]+)([0-9]+))?";
private enum singleCellRegex = ctRegex!r"^[A-Z]+[0-9]+$";
private enum equationRegex = ctRegex!r"^([A-Z]*[0-9]+)([\+\-\*\/\^])([A-Z]*[0-9]+)$";

struct CellValue
{
	string expression = "0";
	@property double value() { return evaluate(expression); };

	ref CellValue opAssign(string expression)
	{
		this.expression = expression;
		return this;
	}

	double opBinary(string op)(CellValue rhs)
	{
		return mixin("this.value" ~ op ~ "rhs.value");
	}

	double func(string formula, double[] values)
	{
		double result;
		if(formula.startsWith("SUM")) 
		{
			result = reduce!((a,b) => a + b)(0.0,values);
		}
		else if(formula.startsWith("AVG")) 
		{
			result = reduce!((a,b) => a + b / values.count)(0.0,values);
		}
		else if(formula.startsWith("PROD")) 
		{
			result = reduce!((a,b) => a * b)(1.0,values);
		}
		return result;
	}

	double evaluate(string expression)
	{
		double result = 0;

		if(match(expression, ctRegex!r"^\d+$")) return to!double(expression);
		else if(match(expression, singleCellRegex)) return evaluate(expression);
		else if(auto m = match(expression, equationRegex))
		{
			string op = m.captures[2];
			switch(op)
			{
				case "+": result = CellValue(m.captures[1]) + CellValue(m.captures[3]); break;
				case "-": result = CellValue(m.captures[1]) - CellValue(m.captures[3]); break;
				case "*": result = CellValue(m.captures[1]) * CellValue(m.captures[3]); break;
				case "/": result = CellValue(m.captures[1]) / CellValue(m.captures[3]); break;
				case "^": result = CellValue(m.captures[1]) ^^ CellValue(m.captures[3]); break;
					
				default: break;
			}
		}
		else
		{
			CellRange cells = CellRange(match(expression, rangeRegex).captures[0]);
			auto values = map!(a => a.value)(cells.values);
			result = func(expression, values.array);
		}

		return result;
	}
}

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
}

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

	double binary(double lhs, double rhs, string op)
	{
		double result;
		switch(op)
		{
			case "+":
				result = lhs + rhs; break;
			case "-":
				result = lhs - rhs; break;
			case "*":
				result = lhs * rhs; break;
			case "/":
				result = lhs / rhs; break;
			case "^":
				result = lhs ^^ rhs; break;
			default:
				result = double.nan;
		}
		return result;
	}
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