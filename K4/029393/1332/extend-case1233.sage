load ../../genericSRG.sage
from multiprocessing import Pool
from itertools import combinations 

global cann
cann = {}

def extendCliqueVertex(G, v, notYet):
    
    global cann
    ret = []

    if v >= 0 and v <= 7:
        for nb in [19..22]:
            H = G.copy()
            H.add_edge(nb,v)
            s = H.canonical_label().graph6_string()
            if s not in cann:
                cann[s] = True
                X = H.subgraph(set(H) - notYet)
                X.relabel()
                if isInterlaced(X):
                    ret+= [H]
    else:
        for nbr in combinations( [19..22], 2):
            H = G.copy()
            H.add_edges( (v,nb) for nb in nbr)
            s = H.canonical_label().graph6_string()
            if s not in cann:
                cann[s] = True
                X = H.subgraph(set(H) - notYet)
                X.relabel()
                if isInterlaced(X):
                    ret += [H]

    return ret
# The vertices of the clique are going to be 19,20,21,22
def extendClique(G):
    G.add_edges(Combinations( [19..22],2))

    G.add_edge(8, 19)
    G.add_edge(8, 20)
    G.add_edge(8, 21)

    G.add_edge(9, 19)
    G.add_edge(9, 20)
    G.add_edge(9, 21)

    G.add_edge(10, 19)
    G.add_edge(10, 20)
    G.add_edge(10, 22)

    toFix = set([0..7] + [11..18])

    generated = [G]
    while toFix:
        v = toFix.pop()
        generated_tmp = []
        for G in generated:
            generated_tmp += extendCliqueVertex(G, v, toFix)
        generated = generated_tmp
    return generated        

def extendVertexBetween(G, v, notYet):
    
    ret = []
    global cann
    if G.subgraph([0..7]).degree(v) + 6+int(G.has_edge(22,v)>8:
        return []
    for nbr1 in combinations([11..18], G.subgraph([0..7]).degree(v) + 6+int(G.has_edge(22,v))):
        H = G.copy()
        H.add_edges( (v,nb) for nb in nbr1)
        s = H.canonical_label().graph6_string()
        if s not in cann:
            cann[s] = True
            X = H.subgraph(set(H) - notYet)
            X.relabel()
            if isInterlacedFast(X):
                ret += [H]
    return ret                
def extendBetween(arg):

    G = arg[0].copy()
    H = arg[1].copy()

    G.add_vertices([8,9,10]) # these are the vertices x_0,x_1,x_2

    for v in [0..7]:
        G.add_edge(9, v)

    H.relabel( {i:i+11 for i in H} )
    G.add_edges( H.edges() )

    # upper graph is adjacent with x_0,x_2
    for v in [11..18]:
        G.add_edge(v, 8)
        G.add_edge(v, 10)
    
    toFix = set( [0..7] )
    generated = [G]
    
    while toFix:
        v = toFix.pop()
        generated_tmp = []
        for G in generated:
            generated_tmp += extendVertexBetween(G, v, toFix)
        generated = generated_tmp
    return generated

# This 5 graphs were obtained  by the program case1233-inter1.sage The vertex labeled with 7 is the special
# vertex.
right_graph = [Graph('G?????'),Graph('G???C?'), Graph('G??E??'), Graph('G?AA??'), Graph('G?`@??')]
upper_graph = list(graphs.nauty_geng("-D2 -t 8"))

p = Pool(8)
L = []
o = open('output.g6','w')
for el in p.imap(extendBetween, CartesianProduct(upper_graph, right_graph)):
   L += el 
   for G in L:
       o.write(G.graph6_string() + '\n')
o.close()
print 'We got a total of', len(L) , 'graphs.'

L2 = []
c = 0
for el in p.imap(extendClique, L):
    L2 += el
    c+=1
    print c


