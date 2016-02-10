from sys import argv
from itertools import combinations, product


def create_new(G):

    ret=[]
    case=G.subgraph([14,8,9,10]).degree(14)

    if case==0:
        permutat=Permutations([11..13])
        for perm in permutat:
            H=G.copy()
            H.relabel({[11..13][i]:perm[i] for i in [0..2]})
            ret+=[H]
            H1=G.copy()
            H1.relabel({9:10,10:9})
            ret+=[H1]

    if case==1:
        permutat=Permutations([11,12])
        for perm in permutat:
            H=G.copy()
            H.relabel({[11,12][i]:perm[i] for i in [0,1]})
            ret+=[H]


    if case==2:
        permutat=Permutations([12,13])
        for perm in permutat:
            H=G.copy()
            H.relabel({[12,13][i]:perm[i] for i in [0,1]})
            H.relabel({[9,10][i]:(perm[i]-3) for i in [0,1]})
            ret+=[H]

    # print case, len(ret)
    return ret




L = []
L3=[]
for line in open("right.g6"):
    L3+=[Graph(line).graph6_string()]
    for g in create_new(Graph(line)):
        L += [g.graph6_string()]
L2=[]
print len(L)
L=list(set(L))
print len(L)
for g in L:
    if g not in L3:
        L2+=[g]
print 'Got ', len(L2), 'graphs'
o = open('right2.out','w')
for G in L2:
    o.write(G + '\n')
o.close()    
