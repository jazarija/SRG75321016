load ../genericSRG.sage
cann = {}
found = false
for G in graphs.nauty_geng("-d2 -D2 15"):
    for v in [0..14]:
        G.add_edge(v, 15) # 15 = x_0
        G.add_edge(v, 17) # 17 = x_1'
    
    G.add_edge(16, 17) # 16 = x_1

    G.add_edge(18, 16) # 18 = x_3
    G.add_edge(18, 15)

    if isInterlaced(G):
        G.add_edge(19, 15)

        for nbr in Combinations([0..14],9):
            H = G.copy()
            H.add_edges ( (19, v) for v in nbr )
            s = H.canonical_label().graph6_string()
            if s not in cann:
                cann[s] = True
                if isInterlaced(H):
                    found = True
                    break
if not found:
    print 'No interlacing example found.'
else:
    print 'There are interlacing canddiates. Rerun and find them out'
