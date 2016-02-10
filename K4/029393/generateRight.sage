load genericSRG.sage
from multiprocessing import Pool 
from itertools import combinations

# This code generates all graphs K_4 \cup X_3 \cup X_2^0

def extendVertex(G, v, toFix, cann):
    
    k = G.subgraph([0..7]).degree(v)

    t = int(G.has_edge(v,9)) + int(G.has_edge(v,10)) 

    ret = []

    for x,y in combinations([11..14], 2):
        if x != 14 and y != 14:
            m = 2
        else:
            m = 1

        if m+t+k > 3:
            continue

        H = G.copy()
        H.add_edge(v,x)
        H.add_edge(v,y)

        s = H.canonical_label(partition=[[0..7],[8,9,10],[11..14]]).graph6_string()
    
        if s not in cann:
            cann.add(s) 
            X = H.subgraph(set(H)-toFix)               
            X.relabel()
            if isInterlacedFast(X):
                ret+= [H]
    return ret  

# Vertices 8,9 and 10 are x_0, x_1 and x_2 while 11,12,13,14 are the vertices of K_4

def extend(G):

    G.add_vertices([8,9,10])
    G.add_edges(combinations([11..14], 2))

    G.add_edge(8,11)
    G.add_edge(8,12)
    G.add_edge(8,13)

    for v in  [0..7]: 
        G.add_edge(8,v)

    edges_to_X3 = [ [(9,11), (9,12), (9,13), (10,11), (10,12), (10,13)],
                    [(9,11), (9,12), (9,13), (10,11), (10,12), (10,14)],
                    [(9,11), (9,12), (9,14), (10,11), (10,13), (10,14)] ]

    edges_to_X2 = [[],[(7,9)],[(7,10)],[(7,9),(7,10)],[(6,9),(7,10)]]

    generated = []

    for edges1 in edges_to_X3:
        for edges2 in edges_to_X2:
            H = G.copy()
            H.add_edges(edges1+edges2)
            generated += [H]

    toFix = set([0..7])

    while toFix:
        
        v = toFix.pop()
        generated_tmp = []
        cann = set()
        for H in generated:
            generated_tmp += extendVertex(H, v, toFix, cann)

        generated = generated_tmp
        
    print 'We got plenty of graphs', len(generated)

    return generated

L = []

global cann
cann = set() 


# In this first part we construct all possible graphs X_2^0 which
# are labeled with the integers 0,..,7. The vertices 6 and 7 are the
# ones that are potentially adjacent to x_1 or x_2.    

for G in graphs.nauty_geng("-t -D2 6"):

    if not isInterlacedFast(G):
        continue

    G.add_vertices( [6,7] )

    for nbr1, nbr2 in combinations( list(combinations([0..5],2))+list(combinations([0..5],1))+[[]], 2):

        H = G.copy()
        H.add_edges( (6, el) for el in nbr1)
        H.add_edges( (7, el) for el in nbr2)

        if max(H.degree()) > 2:
            continue

        if not H.subgraph([0..6]).is_triangle_free():
            continue

        s1 = H.canonical_label(partition = [ [6,7], [0..5] ]).graph6_string()
        s2 = H.canonical_label(partition = [ [7], [0..6] ]).graph6_string()

        if s1 not in cann or s2 not in cann:
            cann.add(s1)
            cann.add(s2)

            if isInterlacedFast(H):
                L += [H]

        H2 = H.copy()
        H2.add_edge(6,7)

        if max(H2.degree()) > 2:
            continue

        s1 = H2.canonical_label(partition = [ [6,7], [0..5] ]).graph6_string()
        s2 = H2.canonical_label(partition = [ [7], [0..6] ]).graph6_string()

        if s1 not in cann or s2 not in cann:
            cann.add(s1) 
            cann.add(s2)

            if isInterlacedFast(H2):
                L += [H2]

print 'got' , len(L), 'right graphs'

cann = set()
    
L2 = []
p = Pool(8)

for el in p.imap(extend, L):
    L2 += el
print 'We got a final list of length', len(L2) 

o = open('right.g6','w')
for G in L2:
    o.write(G.graph6_string() + '\n')
o.close() 
