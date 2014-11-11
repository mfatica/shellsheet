module regex;
public import std.regex;

enum rangeRegex = ctRegex!r"([A-Z]+)([0-9]+)(:([A-Z]+)([0-9]+))?";
enum singleCellRegex = ctRegex!r"^[A-Z]+[0-9]+$";
enum equationRegex = ctRegex!r"^([A-Z]*[0-9]+)([\+\-\*\/\^])([A-Z]*[0-9]+)$";