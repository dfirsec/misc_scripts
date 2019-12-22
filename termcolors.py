class Termcolor:
    HEADER = '\033[95m'
    BLUE = '\033[34m'
    GREEN = '\033[32m'
    MAGENTA = '\033[35m'
    CYAN = '\033[36m'
    GRAY = '\033[90m'
    WARNING = '\033[33m'
    FAIL = '\033[31m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


print(f"This is {Termcolor.CYAN}{Termcolor.BOLD}Cyan{Termcolor.ENDC} in Bold")
print(f"This is {Termcolor.CYAN}Cyan{Termcolor.ENDC} Normal")
print(f"This is {Termcolor.CYAN}{Termcolor.UNDERLINE}Cyan{Termcolor.ENDC} Underlined")
print(f"This is {Termcolor.CYAN}{Termcolor.UNDERLINE}{Termcolor.BOLD}Cyan{Termcolor.ENDC} Underlined and Bold")
