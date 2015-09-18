load genericSRG.sage
from multiprocessing import Pool

global cann
cann = {}

def extendVertexClique(G, v, toFix):

    global cann
    ret = []

    for nb in [19,20,21]:
        H = G.copy()
        H.add_edge(v, nb)
        s = H.canonical_label(partition=[0..7],[8,9,10],[11..18],[19..22]).graph6_string()
        if s not in cann:
            cann[s] = True
            X = H.subgraph( set(H) - toFix)
            X.relabel()
            if isInterlacedFast(X):
                ret += [H]
    return ret                
# the vertices of the clique are labeled by [19,20,21,22]
# the vertex 22 is the special one not adjacent to any of
# the vertices of X_3
def extendClique(G):

    G.add_edges( Combinations([19..22],2) )

    for v in [19,20,21]:
        G.add_edge(8,v)
        G.add_edge(9,v)
        G.add_edge(10,v)


    # every vertex of X_2^0 is adjacent to the special vertex
    for v in [0..7]:
        G.add_edge(22, v)

    # All these vertices still need one more neighbor in [19,20,21]
    toFix = set([0..7] + [11..18])
    
    generated = [G]

    while toFix:
        v = toFix.pop()
        generated_tmp = []
        for G in generated:
            generated_tmp += extendVertexClique(G,v,toFix)
        generated = generated_tmp
    return generated        

def extendVertexBetween(G, v, notYet):
    
    global cann
    ret = []

    for nbr1 in Combinations( [0..7], 6 + G.subgraph([11..18]).degree(v)):
        H = G.copy()
        H.add_edges ( (v, el) for el in nbr1)
        s = H.canonical_label(partition=[[0..7],[8,9,10],[11..18]]).graph6_string()
        if s not in cann:
            cann[s] = True
            X = H.subgraph(set(H) - notYet)
            X.relabel()
            if isInterlacedFast(X):
                ret+=[H]
    return ret

def extendBetween(H):

    G = graphs.CompleteGraph(8).complement()
    G.add_vertices([8,9,10]) # 8,9,10 = x_0,x_1,x_2

    for v in [0..7]:
        G.add_edge(10,v)

    H.relabel( {i:i+11 for i in H} )

    G.add_edges( H.edges() )

    # The graph induced by H is in fact X_1^{0,1}.
    for v in [11..18]:
        G.add_edge(9,v)
        G.add_edge(8,v)

    generated = [G]

    toFix = set([11..18])

    while toFix:
        v = toFix.pop()
        generated_tmp = []
        for G in generated:
            generated_tmp += extendVertexBetween(G,v, toFix)
        generated = generated_tmp
    return generated

p = Pool(8)
L = []
for el in p.imap(extendBetween, graphs.nauty_geng("-t 8 -D2")):
    L += el

print 'We generated a total of', len(L), 'graphs. We will now introduce the clique to them.'

L2 = []
for el in p.imap(extendClique, L):
    L2 += el
    if el:
        print 'got some'
o = open('case0333-cands.g6','w')
print 'Got a total of ', len(L2), 'graphs.'

for G in L2:
    o.write(G.graph6_string() + '\n')
o.close()    
