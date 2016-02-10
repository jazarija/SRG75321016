load ../../genericSRG.sage
from itertools import product, combinations

global cann
cann = set()

def fixGraph(G):

    for v in [0..14]:
        deg = G.subgraph([0..14]).degree(v)
        if deg == 2:
            G.add_edge(v, 18)

        if deg == 0 and not G.has_edge(v, 17): 
            return []

        if deg == 1 and G.has_edge(v, 17):
            G.add_edge(v, 18)

    if isInterlacedFast(G):
        return [G]

    return []

L = []
for G in graphs.nauty_geng("15 -D2"):

    # 15 = x_0, 16 = x_1
    G.add_vertices([15, 16])

    for x in [0..14]:
        G.add_edge(x, 15)

    if not isInterlacedFast(G):
        continue

    # 17 = x_3
    # 18 = x_1'
    G.add_edge(17, 16) 
    G.add_edge(17, 15) 
    G.add_edge(18, 16)

    # we cover two options based on whether x_3 and x_1' are adjacent or not

    H = G.copy()
    I = H.copy()

    # not adjacent 
    L += [I]

    # adjacent
    H.add_edge(18, 17)
        
    candNbr = [v for v in [0..14] if G.subgraph([0..14]).degree(v) <= 1]

    for nbr in candNbr:
        I = H.copy()
        # note, nbr may still be adjacent to x_1'
        I.add_edge(17, nbr)
        L += [I]


print "We have obtained", len(L), "candidate graphs. We will add edges between x_0', x_1 and X_2^0 now."


L2 = []
for G in L:
    L2 += fixGraph(G)

print 'We got', len(L2), 'candidate graphs. We will add K_4 now.'

def extendVertex(G,v, toFix):
    global cann

    ret = []

    if v == 15 or v == 16:
        t = 0
    elif v == 17:
        t = 3
    elif v == 18:
        t = 1
    else:
        t = 2

    for nbr in combinations([19..22], t):
        H = G.copy()
        H.add_edges( (v, el) for el in nbr)
        s = H.canonical_label(partition=[[0..14],[15,16],[17],[18],[19..22]]).graph6_string()
        if s not in cann:
            cann.add(s)
            X = H.subgraph( set(H) - set(toFix) )
            X.relabel()
            if isInterlacedFast(X):
                ret += [H]
    return ret     

# We obtain a graph with 19 vertices we add vertices [19,20,21,22] representing
# K_4. The vertices [14,15] then need 3 vertices in K_4, 16,17 need a singe vertex in K_4
# and the vertices 0..13 need 2 vertices in K_4
def extend(G):

    G.add_edges( Combinations( [19..22], 2) )
    generated = [G]
    toFix = [0..18] 

    while toFix:
        v = toFix.pop()
        generated_tmp = []
        for G in generated:
            generated_tmp += extendVertex(G, v, toFix)
        generated = generated_tmp
        print len(generated), len(toFix)
    return generated

L3 = []
for G in L2:
    L3 += extend(G)
print 'We got', len(L3), 'candidate graphs.'

