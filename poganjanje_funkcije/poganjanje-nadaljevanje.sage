#!/usr/bin/env python
# coding: utf-8

DATOTEKA = "poganjanje-12-234.csv"


# In[ ]:


import csv
import random
import sys

#random.seed(42)
gens = [seznam_naborov_st_vozlisc_cas(seznam_grafov[298:], i, j) for i in (1, 2) for j in (2, 3, 4)]

with open(DATOTEKA, "a") as f:
    wr = csv.writer(f)
    while gens:
        for i, g in enumerate(gens):
            try:
                r = next(g)
                print(r)
                wr.writerow(r)
                sys.stdout.flush()
                f.flush()
            except StopIteration:
                gens[i] = None
        gens = [g for g in gens if g is not None]
