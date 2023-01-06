#!/usr/bin/env python
# coding: utf-8

# In[ ]:


from operator import add

def accumulate(iterable, func=add, initial=None):
    'Return running totals'
    it = iter(iterable)
    total = initial
    if initial is None:
        try:
            total = next(it)
        except StopIteration:
            return
    yield total
    for element in it:
        total = func(total, element)
        yield total


def clp(G, B, gasilci, cas):
    ''' vhodni podatki:
         G           izbran graf
         B           vozlišča, ki na začetku zgorijo
         gasilci     število gasilcev, ki v vsakem koraku gasijo požar
         cas         maksimaleno število časovnih enot
     izhodni podatki:
         seznam oblike [število časovnih enot, pogorela/burnt vozlišča po časih, zaščitena/defended vozlišča po časih] '''
 
    casi = range(1, cas+1) # uprabljamo pri zankah
    
    # CLP:
    p = MixedIntegerLinearProgram(maximization=False) # CLP
    d = p.new_variable(binary=True) # spremenljivka, defended
    b = p.new_variable(binary=True) # spremenljivka, burnt

    p.set_objective(sum(b[i, cas] for i in G)) # minimiziramo število pogorelih vozlišč na koncu 

    for t in casi:
        for i in G:
            for j in G[i]: # j je številka v seznamu vozlišča i, sosed od i
                p.add_constraint(b[i,t] + d[i,t] - b[j,t-1] >= 0)
            p.add_constraint(b[i,t] + d[i,t] <= 1)
            p.add_constraint(b[i,t] - b[i,t-1] >= 0)
            p.add_constraint(d[i,t] - d[i,t-1] >= 0)
        p.add_constraint(sum((d[i,t] - d[i,t-1]) for i in G) <= gasilci)

    for i in G:
        p.add_constraint(b[i,0] == (1 if i in B else 0))
        p.add_constraint(d[i,0] == 0)
        
    return [p.solve(), p.get_values(b), p.get_values(d)]


def cas_potreben(G, B, gasilci):
    ''' iz p.solve() pridobi čas po katerem se nič več ne spremeni -> dobimo potreben čas '''
    #cas = 10 #začetni cas
    cas = 10
    while True:
        t, burnt, defended = clp(G, B, gasilci, cas)

        urej_burnt = sorted(burnt.items(), key=lambda tup: tup[0][1]) #uredi glede na čas po vozliščih naraščajoče
        urej_defended = sorted(defended.items(), key=lambda tup: tup[0][1]) 

        vredn_burnt= []
        for i, v in urej_burnt:
            vredn_burnt.append(v)
        # pridobim ven vrednosti spremnljivk b v časih in vozliščih naraščajoče

        vredn_defended= []
        for i, v in urej_defended:
            vredn_defended.append(v)
        # pridobim ven vrednosti spremnljivk d v časih in vozliščih naraščajoče

        # from itertools import islice
        from itertools import accumulate
        dolzina = [len(G)] * (cas +1) # Vrednosti zgrupiram v paketke, v vsakem je toliko vrednosti, kolikor je vozlišč
        seznami_vrednosti_po_casih_burnt = [tuple(vredn_burnt[x - y: x]) for x, y in zip(
                            accumulate(dolzina), dolzina)]

        seznami_vrednosti_po_casih_defended = [tuple(vredn_defended[x - y: x]) for x, y in zip(
                            accumulate(dolzina), dolzina)]

        d = next(i for i in range(len(dolzina)) if all(len(set(l[i:i+2])) == 1 for l in (seznami_vrednosti_po_casih_burnt, seznami_vrednosti_po_casih_defended)))
        if d < cas:
            break
        else:
            cas += 10
    return d

import random
def nakljucno_izberi_vzolisca(graf, n):
    ''' funkcija naključno izbere n vozlišč iz grafa graf '''
    return random.sample(list(graf), n)


def seznam_naborov_st_vozlisc_cas(seznam_imen_grafov, st_gasilcev, stevilo_vozlisc_v_B):
    ''' funkcija, ki sprejme seznam v katerem so imena grafov, število gasilcev ter število vozlišč, ki jih želimo v začetni množici B.
            Vrne pa seznam naborov oblike (število vozlišč, potreben čas reševanje problema)'''
    # določimo čas:
    cas = 10
    # sprehodimo se po seznam_imen_grafov in sestavljamo nabor:
    seznam_naborov = []
    for graf in seznam_imen_grafov:
        B1 = nakljucno_izberi_vzolisca(graf, stevilo_vozlisc_v_B)
        B2 = nakljucno_izberi_vzolisca(graf, stevilo_vozlisc_v_B)
        potreben_cas1 = cas_potreben(graf, B1, st_gasilcev)
        potreben_cas2 = cas_potreben(graf, B2, st_gasilcev)
        #seznam_naborov.append((len(graf), potreben_cas1))
        #seznam_naborov.append((len(graf), potreben_cas2))
        yield (len(graf), graf.name(), st_gasilcev, stevilo_vozlisc_v_B, potreben_cas1, potreben_cas2)
    
    #return seznam_naborov
