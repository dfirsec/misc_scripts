#!/usr/bin/env python

__description__ = "Python Password Generator"

import string
import secrets


def str_gen(str_len=10):
    s = string.ascii_letters + string.digits + string.punctuation
    return ''.join(secrets.choice(s) for i in range(str_len))


print(str_gen())
