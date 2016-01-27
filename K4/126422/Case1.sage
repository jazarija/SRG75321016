load genericSRG.sage
from itertools import product, combinations
from multiprocessing import Pool

global cann
cann = {}

def extendVertex(G, v, toFix):
    global cann

    ret = []

    if v == 14 or v == 15:
        t = 3
    elif v == 17 or v == 18:
        t = 1
    else:
        t = 2

    for nbr in combinations([19..22],t):
        H = G.copy()
        H.add_edges( (v, el) for el in nbr)
        s = H.canonical_label(partition=[[0..13],[14,15],[16],[17,18],[19..22]]).graph6_string()
        if s not in cann:
            cann[s] = True
            X = H.subgraph (set(H) - set(toFix) )
            X.relabel()
            if isInterlacedFast(X):
                ret += [H]
    return ret     

# We obtain a graph with 19 vertices we add vertices [19,20,21,22] representing
# K_4. The vertices [14,15] then need 3 vertices in K_4, 16,17 need a singe vertex in K_4
# and the vertices 0..13 need 2 vertices in K_4
def extend(G):
    G.add_edges( combinations( [19..22], 2) )
    generated = [G]
    toFix = [0..13] + [14,15] + [17,18] # fixme kje je 16?
    while toFix:
        v = toFix.pop()
        generated_tmp = []
        for G in generated:
            generated_tmp += extendVertex(G,v, toFix)
        generated = generated_tmp
    return generated

# The graph we recive needs to have the vertices in [0..13]
# adjacent to the correct number of vertices in {x_0',x_0''} = [17,18]
def fixGraph(G):
    global cann
    ret = []
    
    toFix = set()

    for v in [0..13]:
        deg = G.subgraph([0..13]).degree(v)
        if deg == 1 and len(set(G[v]).intersection(set([14,15])))==0:
            toFix.add(v)
        if deg == 0 and len(set(G[v]).intersection(set([14,15])))==1:
            toFix.add(v)
        if deg == 2 or (deg==1 and len(set(G[v]).intersection(set([14,15])))==1) or (deg==0 and len(set(G[v]).intersection(set([14,15])))==2):
            G.add_edge(v, 17)
            G.add_edge(v, 18)

    X = G.subgraph(set(G) - toFix)
    X.relabel()
    if not isInterlacedFast(X):
        return []

    toFix = list(toFix)

    # At this point it remains to fix the vertices in toFix,
    # these are the vertices that can pick their neighbor in [17,18]
    for nbr in product( * [[17,18]]*len(toFix)):
        H = G.copy()
        H.add_edges( (nbr[i], toFix[i]) for i in xrange(len(toFix)) )
        s = H.canonical_label(partition=[[0..13],[14,15],[16],[17,18]]).graph6_string()
        if s not in cann:
            cann[s] = True
            if isInterlacedFast(H):


                # A final check is offfered by Lemma 10 saying that x_0',x_0''
                # must have 15-t neighbors in X_2^{-0}, where t is the
                # number of its neighbors in {x_1,x_2}
                t = len( set(G[17]).intersection([14,15]) )
                if len(set(G[17]).intersection([0..13])) != 15-t:
                    continue

                t = len( set(G[18]).intersection([14,15]) )
                if len(set(G[18]).intersection([0..13])) != 15-t:
                    continue

                ret += [H]

    return ret


L = []
for G in graphs.nauty_geng("14 -D2"):
    G.add_edge(16,14) # 14,15 = x_1,x_2
    G.add_edge(16,15) # 16 = x_0

    # We have 4 cases to cover
        # 1. x_1,x_2 have no neibgbohrs in X_2^{\emptyset}
        # 2. Precisely one of x_1,x_2 has a neighbor in X_2
        # 3. They both have distinct neighbors in X_2
        # 4. They both have the same neighbor in X_2.

    # Case 1

    if isInterlacedFast(G):
        L += [G.copy()]

    # Case 2 - we assume x_1 has a neighbor in X_2^{\emptyset} and this neigbor has degree at most 1.
    candNbr = [v for v in [0..13] if G.subgraph([0..13]).degree(v) <= 1]

    for nbr in candNbr:
        H = G.copy()
        H.add_edge(14, nbr)
        s = H.canonical_label(partition=[[0..13],[14,15],[16]]).graph6_string()
        if s not in cann:
            cann[s] = True
            if isInterlacedFast(H):
                L += [H]
    # Case 3
    for nbr1,nbr2 in combinations(candNbr, 2):
        H = G.copy()
        H.add_edge(14, nbr1)
        H.add_edge(15, nbr2)
        s = H.canonical_label(partition=[[0..13],[14,15],[16]]).graph6_string()
        if s not in cann:
            cann[s] = True
            if isInterlacedFast(H):
                L += [H]

    candNbr = [v for v in [0..13] if G.subgraph([0..13]).degree(v) == 0]

    for nbr in candNbr:
        H = G.copy()
        H.add_edge(14, nbr)
        H.add_edge(15, nbr)
        s = H.canonical_label(partition=[[0..13],[14,15],[16]]).graph6_string()
        if s not in cann:
            cann[s] = True
            if isInterlacedFast(H):
                L += [H]

print "We have obtained", len(L), "candidate graphs. We will add x_0', x_0'' now."

L2 = []
for G in L:
    G.add_edge(16, 17) # x_0', x_0'' = 17,18
    G.add_edge(16, 18)

    for nbr1,nbr2 in product( [ [17],[18], [17,18] ], [ [17],[18], [17,18] ] ):
        H = G.copy()
        H.add_edges( (15,el) for el in nbr1)
        H.add_edges( (14,el) for el in nbr2)

        # s = H.canonical_label(partition=[[0..13],[14,15],[16],[17,18]]).graph6_string()
        # if s not in cann:
        #     cann[s] = True
        L2 += [H]
print 'We got', len(L2), 'candidate graphs. We add remaining edges now.'

p = Pool(8)

L = []
c = 0
for el in p.imap(fixGraph, L2):
    L += el

print 'We got', len(L), 'candidate graphs. We will add the 4-clique now.'

L2 = []
c = 0
for el in p.imap(extend, L):
    L2 += el
    c += 1
    print c

o = open('cands.g6','w')
for G in L2:
    o.write(G.graph6_string() +'\n')
