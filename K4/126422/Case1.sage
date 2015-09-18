load ../../genericSRG.sage
from itertools import product

global cann
cann = {}

# The graph we recive needs to have the vertices in [0..13]
# adjacent to the correct number of vertices in {x_0',x_0''} = [17,18]
def fixGraph(G):
    global cann
    ret = []
    
    toFix = set()

    for v in [0..13]:
        deg = G.subgraph([0..13]).degree(v)
        if deg == 1:
            toFix.add(v)
        if deg == 2:
            G.add_edge(v, 17)
            G.add_edge(v, 18)

    X = G.subgraph(set(G) - toFix)
    X.relabel()
    if not isInterlacedFast(X):
        return []

    toFix = list(toFix)

    # At this point it remains to fix the vertices in toFix,
    # these are the vertices that can chose their neighbor in [17,18]
    for nbr in product( * [[17,18]]*len(toFix)):
        H = G.copy()
        H.add_edges( (nbr[i], toFix[i]) for i in xrange(len(toFix)) )
        s = H.canonical_label(partition=[[0..13],[14,15],[16],[17,18]]).graph6_string()
        if s not in cann:
            cann[s] = True
            if isInterlacedFast(H):


                # A final check is offfered by Lemma 9 saying that x_0',x_0''
                # must have 15-t neighbors in X_2^{\emptyset}, where t is the
                # number of its neighbors in \{x_1,x_2\}
                t = len( set(G[17]).intersection([14,15]) )
                if not len(set(G[17]).intersection([0..13])) == 15-t:
                    continue

                t = len( set(G[18]).intersection([14,15]) )
                if not len(set(G[18]).intersection([0..13])) == 15-t:
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
    for nbr1,nbr2 in Combinations(candNbr, 2):
        H = G.copy()
        H.add_edge(14, nbr1)
        H.add_edge(15, nbr1)
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

    for nbr1,nbr2 in CartesianProduct ( [ [17],[18], [17,18] ], [ [17],[18], [17,18] ] ):
        H = G.copy()
        H.add_edges( (15,el) for el in nbr1)
        H.add_edges( (14,el) for el in nbr2)

        s = H.canonical_label(partition=[[0..13],[14,15],[16],[17,18]]).graph6_string()
        if s not in cann:
            cann[s] = True
            L2 += [H]
print 'We got', len(L2), 'candidate graphs. We add remaining edges now.'

L = []
c = 0
for G in L2:
    L += fixGraph(G)
o = open('Case1.out','w')
for G in L:
    o.write(G.graph6_string() +'\n')
