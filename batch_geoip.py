import sys

import requests
import urllib3
from bs4 import BeautifulSoup
from colorama import Fore, Style, init

# Console Colors
init()
BOLD = Style.BRIGHT
CYAN = Fore.CYAN
GREEN = Fore.GREEN
RED = Fore.RED
RESET = Fore.RESET
YELLOW = Fore.YELLOW

host = ''
if len(sys.argv) < 2:
    sys.exit(f"{RED}[ERROR]{RESET} You forgot to include the host address.")
else:
    host = sys.argv[1]


# freegeoip.live
try:
    fg_url = requests.get(f'https://freegeoip.live/json/{host}').json()
    print(f"\n{CYAN}Freegeoip Results{RESET}\n{('-' * 50)}")
    with open("geo_results.txt", 'w') as f:
        f.write(f"\nFreegeoip Results\n{('-' * 50)}\n")
    for k, v in fg_url.items():
        if v:
            print(f"{k.title().replace('_', ' '):15}: {v}")
            with open("geo_results.txt", 'a') as f:
                f.write(f"{k.title().replace('_', ' '):15}: {v}\n")
except Exception as err:
    print(err)

# tools.keycdn.com
try:
    kc_url = requests.get(
        f'https://tools.keycdn.com/geo.json?host={host}').json()
    print(f"\n{CYAN}KeyCDN Results{RESET}\n{('-' * 50)}")
    with open("geo_results.txt", 'a') as f:
        f.write(f"\nKeyCDN Results\n{('-' * 50)}\n")
    for k, v in kc_url['data']['geo'].items():
        if v:
            print(f"{k.title().replace('_', ' '):15}: {v}")
            with open("geo_results.txt", 'a') as f:
                f.write(f"{k.title().replace('_', ' '):15}: {v}\n")
except Exception as err:
    print(err)

# ipgeolocation.io
try:
    ipg = requests.get(f'https://ipgeolocation.io/ip-location/{host}').text
    soup = BeautifulSoup(ipg, 'lxml')
    tb = soup.find_all('table')[0]
    tb_data = tb.tbody.find_all('tr')

    data = dict()
    for td in tb_data:
        k = td.find_all("td")[0].text.strip()
        v = td.find_all("td")[1].text.strip()
        data[k] = v

    print(f"\n{CYAN}IP Geolocation Results{RESET}\n{('-' * 50)}")
    with open("geo_results.txt", 'a') as f:
        f.write(f"\nIP Geolocation Results\n{('-' * 50)}\n")
    for k, v in data.items():
        if v:
            try:
                print(f"{k:35}: {v}")
                with open("geo_results.txt", 'a') as f:
                    f.write(f"{k:35}: {v}\n")
            except Exception:
                continue
except Exception as err:
    print(err)
