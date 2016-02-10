from itertools import product

right = [Graph(line) for line in open('right.g6')]
upper = [Graph(line) for line in open('upper.g6')]
o = open('candidatePairs.g6', 'w')
for G,H in product(right, upper):
    if G.subgraph([8..14]).is_isomorphic(H.subgraph([8..14])):
        o.write(G.graph6_string() + ' ' + H.graph6_string() + '\n')

