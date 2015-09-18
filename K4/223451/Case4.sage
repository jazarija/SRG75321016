load ../genericSRG.sage

cann = {}
found = false

for G in graphs.nauty_geng("15 -d2 -D2"):
    for v in [0..14]:
        G.add_edge(15,v) # 15 = x_0'
        G.add_edge(17,v) # 17 = x_1'

    G.add_edge(16,17) # 16 = x_1
    G.add_edge(16,18) # 18 = x_3
    G.add_edge(18,15) 


    if isInterlacedFast(G):
        G.add_edge(19, 15) # 19 = x_1
        G.add_edge(19, 18) 

        for nbr in Combinations([0..14],8):
            H = G.copy()
            H.add_edges ( (19,v) for v in nbr ) 
            s = H.canonical_label().graph6_string()
            if s not in cann:
                cann[s] = True
                if isInterlacedFast(H):
                    found = True
if not found:
    print 'No interlacing subgraphs found.'
