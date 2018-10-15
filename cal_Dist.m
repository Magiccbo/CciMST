function [d,d1] = cal_Dist(data)
%% Author: Xiaobo Lv.   Email: 791066779@qq.com     supervisor: Yan Ma 
T = makeMST(data) ;
x = size(T,1) ;
G = sparse(T) ; 

T1 = T ;
T1(T1>0) = 1 ;
G1 = sparse(T1) ;

A = zeros(x,x);
A1 = zeros(x,x) ;

for i = 1 : x
    [dd , ~] = dijkstra_sp(G,i);
    A(i,:) = dd;
    [dd , ~] = dijkstra_sp(G1,i);
    A1(i,:) = dd ;
end

d = A ;
d1 = A1 ;
end