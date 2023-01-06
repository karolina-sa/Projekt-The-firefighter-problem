#!/usr/bin/env python
# coding: utf-8

# In[4]:


# sestavljanje seznama grafov:

c = graphs.CycleGraph(5)
p = graphs.PathGraph(3)

seznam_grafov = [graphs.HeawoodGraph(), p.cartesian_product(c), graphs.PappusGraph()]

for i in range(3, 100): # manj kot 3 je nesmiselno
    seznam_grafov.append(graphs.CircularLadderGraph(i)) # ima 2 * i vozlišč

for i in range(2, 15):
    for j in range(3,15):
        seznam_grafov.append(graphs.Grid2dGraph(i,j)) # matrika i x j, tj. ima i * j vozlišč

for i in range(4, 15):
    for j in range(4,15):
        seznam_grafov.append(graphs.CycleGraph(i).cartesian_product(graphs.CycleGraph(j))) # ima i * j vozlišč

for i in range(3, 15):
    for j in range(3, 15):
        seznam_grafov.append(graphs.RandomBlockGraph(i, j))

seznam_grafov.sort(key=lambda G: (G.order(), G.size())) # uredimo po številu vozlišč in povezav

# s tem dobimo zelo velik seznam grafov, na katerem lahko izvedemo funkcijo seznam_naborov_st_vozlisc_cas za poljubno št. vozlišč in vozlišč v B:
#seznam_naborov_1_2 = seznam_naborov_st_vozlisc_cas(seznam_grafov, 1, 2)
#seznam_naborov_1_3 = seznam_naborov_st_vozlisc_cas(seznam_grafov, 1, 3)
#seznam_naborov_1_4 = seznam_naborov_st_vozlisc_cas(seznam_grafov, 1, 4)

#seznam_naborov_2_2 = seznam_naborov_st_vozlisc_cas(seznam_grafov, 2, 2)
#seznam_naborov_2_3 = seznam_naborov_st_vozlisc_cas(seznam_grafov, 2, 3)
#seznam_naborov_2_4 = seznam_naborov_st_vozlisc_cas(seznam_grafov, 2, 4)

DATOTEKA = "poganjanje-12-234.csv"


# In[ ]:


import csv
import sys

gens = [seznam_naborov_st_vozlisc_cas(seznam_grafov, i, j) for i in (1, 2) for j in (2, 3, 4)]

with open(DATOTEKA, "w") as f:
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
