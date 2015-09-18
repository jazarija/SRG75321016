load ../../genericSRG.sage

from sys import argv
global cann
cann = {}
def extendVertex(G,v, toFix):
    global cann

    ret = []

    if v == 14 or v == 15:
        t = 3
    elif v == 17 or v == 18:
        t = 1
    else:
        t = 2

    for nbr in Combinations([19..22],t):
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
    G.add_edges( Combinations( [19..22], 2) )
    generated = [G]
    toFix = [0..13] + [14,15] + [17,18] 
    while toFix:
        v = toFix.pop()
        generated_tmp = []
        for G in generated:
            generated_tmp += extendVertex(G,v, toFix)
        generated = generated_tmp
        print len(generated)
    return generated
L = []
for line in open(argv[1]):
    G = Graph(line)
    L += extend(G)
o = open(argv[1]+'.out','w')
for G in L:
    o.write(G.graph6_string() + '\n')

