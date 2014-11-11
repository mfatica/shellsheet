module CellValue;

import regex;
import CellRange : CellRange;

import std.conv;
import std.array;
import std.string;
import std.algorithm;

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

		if(match(expression, ctRegex!r"^\d+$")) result = to!double(expression);
		else if(match(expression, singleCellRegex)) result = evaluate(expression);
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