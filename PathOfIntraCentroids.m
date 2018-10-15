function[Path] = PathOfIntraCentroids(dist,G,start)
%% Author: Xiaobo Lv.   Email: 791066779@qq.com     supervisor: Yan Ma 
% This function is designed to compute paths between Centroids
% 
% Inupts:
%           dist:dist martix
%           G:Sparse matrix of MST
%           start:label of cluster centroids
%
%Outputs:
%           Path:paths between Centroids
K = length(start) ; 
Path = cell(K,K) ;
dist1 = dist(start,start) ;
dist1 = round(dist1,4);
xishu = sparse(dist1) ; 
G1 = prim_mst(xishu) ; 
T = full(G1) ;

for i = 1 : K 
    for j = i+1 : K 
        if T(i,j) ~= 0
            [~,Path{i,j}]=graphshortestpath(G,start(i),start(j),'Method','Dijkstra');
        end
    end
end