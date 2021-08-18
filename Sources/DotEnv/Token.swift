enum Token: String {
    case carriageReturn = "\r"
    case comment = "#"
    case equal = "="
    case eof = "\0"
    case newline = "\n"
    case quote = "\""
    case tab = "\t"
    case whitespace = " "
}
