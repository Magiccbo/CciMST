function T = makeMST(data)
    d = pdist(data) ; 
    d = squareform(d) ; 
    xishu = sparse(d) ; 
    G = prim_mst(xishu) ; 
    T = full(G) ; 
end

