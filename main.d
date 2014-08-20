import spreadsheet;

void main()
{
	string formula = "B1:B3&B4:E10&F1:G1&F4~C5:C8&B2";

	Spreadsheet sheet = new Spreadsheet;
	sheet.Operation("B2");
}

