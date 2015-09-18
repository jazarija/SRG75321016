load ../../../genericSRG.sage

cann = {}
found = false
L = []

for G in graphs.nauty_geng("-d2 -D2 14"):
    G.add_vertex(14) # \overline{x_0} = 14

    for i in [0..13]: # 15 = x_1'
        G.add_edge(15, i)
    
    G.add_edge(15, 17) # 17 = x_3
    G.add_edge(15, 16)  # 16 = x_1

    G.add_edge(16, 17) 

    G.add_edge(17, 18) # 18 = x_0
    G.add_edge(17, 14)

    for i in [0..14]:
        G.add_edge(18, i)

    if isInterlacedFast(G):
        G.add_edge(19, 18) # 19 = x_0'
        G.add_edge(19, 17)

    # In this case x_0' and x_1' are NOT adjacent
    #        G.add_edge(19, 15)
    
        # x_0' has precisely 8 neighbors in X_2
        for nbr in Combinations([0..14], 8):
            H = G.copy()
            H.add_edges( (19, i) for i in nbr)
            s = H.canonical_label().graph6_string()
            if s not in cann:
                if isInterlacedFast(H):
                    L += [H]
                    found = True 
                cann[s] = True

print 'Testing second configuration. Fingers crossed'

for G in graphs.nauty_geng("-d2 -D2 13"):
    G.add_edge(13,14) # we assume \overline{x_0} = 14

    for i in [0..12]: # 15 = x_1'
        G.add_edge(15, i)

    G.add_edge(15, 14)

    G.add_edge(15, 17) # 17 = x_3
    G.add_edge(15, 16)  # 16 = x_1

    G.add_edge(16, 17) 

    G.add_edge(17, 18) # 18 = x_0
    G.add_edge(17, 14)

    for i in [0..14]:
        G.add_edge(18, i)

    if isInterlacedFast(G):
        G.add_edge(19, 18) # 19 = x_0'
        G.add_edge(19, 17)

        for nbr in Combinations([0..14],8):
            H = G.copy()
            H.add_edges( (19, i) for i in nbr)
            s = H.canonical_label(partition=[[0..13],[14],[16,18],[17],[15,19]).graph6_string()
            if s not in cann:
                if isInterlacedFast(H):
                    L += [H]
                    found = True
                cann[s] = True

if not found:
    print 'No interlacing candidates found.'
else:    
    print 'Interlacing candidates found.'
    for G in L:
        print G.graph6_string()
