#!/usr/bin/env python

import argparse
import os
import sqlite3
import sys

from colorama import Fore, Style, init

# Initialize colorama
init()


class Termcolor:
    # Unicode Symbols and colors
    BOLD = Style.BRIGHT
    CYAN = Fore.CYAN
    YELLOW = Fore.YELLOW
    RESET = Style.RESET_ALL
    PROCESSING = CYAN + "\u279C " + RESET
    WARNING = YELLOW + "\u03DF" + RESET


def history(db):
    try:
        conn = sqlite3.connect(db)
        cursor = conn.cursor()
        bookmarks = "SELECT url, moz_places.title, datetime(last_visit_date/1000000, \"unixepoch\") FROM moz_places JOIN moz_bookmarks ON moz_bookmarks.fk=moz_places.id WHERE visit_count >= 0 AND moz_places.url LIKE 'http%' order by dateAdded desc;"
        history = "SELECT url, datetime(visit_date/1000000, \"unixepoch\") FROM moz_places, moz_historyvisits WHERE visit_count >= 0 AND moz_places.id==moz_historyvisits.place_id;"
    
        print(f"{Termcolor.YELLOW}\n --[ Bookmarks ]--{Termcolor.RESET}")
        for row in cursor.execute(bookmarks):
            url = str(row[0])
            bookmark = str(row[1])
            last_visited = str(row[2])
            if row[0] and row[2] != None:
                print(f"{Termcolor.PROCESSING} {last_visited}: {bookmark}, {url}")
            else:
                print(f"{Termcolor.PROCESSING} {url}")

        print(f"{Termcolor.YELLOW}\n --[ History ]--{Termcolor.RESET}")
        for row in cursor.execute(history):
            url = str(row[0])
            date = str(row[1])
            print(f"{Termcolor.PROCESSING} {date}: {url}")
     
    except Exception as err:
        sys.exit(f"{Termcolor.WARNING} Error reading database. {err}")


def main():
    parser = argparse.ArgumentParser("Firefox History & Bookmarks Viewer")
    parser.add_argument("-f", dest="file", help="Firefox sqlite file path")
    args = parser.parse_args()
    places = args.file

    if places:
        history(places)
    else:
        sys.exit(f"{Termcolor.WARNING} SQLite database does not exist.")


if __name__ == "__main__":
    main()
