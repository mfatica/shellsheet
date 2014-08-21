import spreadsheet, std.stdio, std.string, std.regex, std.conv, std.algorithm;

void main()
{
	string formula = "B1:B3&B4:E10&F1:G1&F4~C5:C8&B2";

	Spreadsheet sheet = new Spreadsheet;

	sheet.Operation("a1=3");
	sheet.Operation("a1");
	sheet.Operation("a2=a1*2");
	sheet.Operation("a2");
	sheet.Operation("A3=A2^2");
	sheet.Operation("a3");
	sheet.Operation("A4=avg(A1:A3)");
	sheet.Operation("A4");

	foreach(line; stdin.byLine())
	{
		sheet.Operation(to!string(line));
	}
}