load ../genericSRG.sage
from multiprocessing import Pool
cann = {}    
right_graphs =  []

def extendVertex(G, v, toFix):
    ret = [] 
    for x,y in Combinations( [11..14], 2):
        H = G.copy()
        H.add_edge(v, x)
        H.add_edge(v, y)
        s = H.canonical_label(partition=[[0..7],[8,9,10],[11..14]]).graph6_string()
        if s not in cann:
            cann[s] = True
            X = H.subgraph(set(G) - toFix)
            X.relabel()
            if isInterlacedFast(X):
                ret += [H]

    return ret 

def extendToClique(G):
    G.add_edges( Combinations([11..14],2) )
# x_0, x_1 sta vezana na 12,13,14
# x_2 11,12,13
    G.add_edges( [ (8,12 ), (8,13), (8,14) ] )
    G.add_edges( [ (9,12 ), (9,13), (9,14) ] )

    G.add_edges( [(10, 11), (10,12), (10,13)] )

    generated = [G]
    toFix = set([0..7])
    
    while toFix:
        v = toFix.pop()
        generated_tmp = []
        for G in generated:
            generated_tmp += extendVertex(G, v, toFix)
        generated = generated_tmp

    return generated 

for G in graphs.nauty_geng("-t 7"):
    G.add_vertex(7)

    for nbr1 in subsets([0..6]):
        H = G.copy()
        H.add_edges( (7, el) for el in nbr1)
        if not H.is_triangle_free():
            continue

        s = H.canonical_label(partition = [ [7], [0..6] ]).graph6_string()
        if s not in cann:
            cann[s] = True
            right_graphs += [H]

print 'Print got' , len(right_graphs), 'right graphs'
L2 = []
# 8,9,10 are the vertices x_0,x_1,x_2
for G in right_graphs:
    G.add_vertices([8,9,10])

    for v in [0..7]:
        G.add_edge(v, 9)
    
    #  assuming one comon negibhor of x_1,x_2 is in in X_2
    G.add_edge(7,10)
    
    if isInterlacedFast(G):
        L2 += [G]

print 'Reduced to', len(L2), 'graphs.'
L3 = []
p = Pool(8)
for el in p.imap(extendToClique, L2):
    if el:
        L3 += [el[0].subgraph([0..7])]
print 'We got a final list of length', len(L3)    
