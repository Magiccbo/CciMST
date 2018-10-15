function [ci,Remember,sizes,T,EdgeOnPath] = MST_Cluster(dist,T2,start,K,rho)
%% Author: Xiaobo Lv.   Email: 791066779@qq.com     supervisor: Yan Ma 
G = sparse(T2);
T = T2;
[m,n] = size(T2);             
ci = ones(m,1) ;                    %�����ǩ
sizes = m ;       

%% Step1��find the shortest path of any two initial cluster center
% G = sparse(T2);
[Path] = PathOfIntraCentroids(dist,G,start);
% Path = Path + Path' ;
EdgeForPath = [] ;
EdgeOnPath = [] ;
for i = 1 : K
    for j = 1 : K
        l = length(Path{i,j}) ; 
        if l == 0 
            continue ;
        else
            for k = 1 : l - 1 
                EdgeForPath = [EdgeForPath;[Path{i,j}(k),Path{i,j}(k+1)]];
                EdgeOnPath = [EdgeOnPath;[i,j]];                                    %��¼��Ӧ��������������path
            end           
        end        
    end
end

ll = size(EdgeForPath,1) ;
Edge = zeros(ll,5);

SumRho = [] ;
for i = 1 : size(EdgeForPath,1)
   Edge(i,1:2) = EdgeForPath(i,:);                  %��¼�ߵ����������±�
   Edge(i,3) = T2(Edge(i,1),Edge(i,2));             %��¼�ñߵ�Ȩֵ
   Edge(i,4:5) = EdgeOnPath(i,:);                   %��¼�ñߴ���������·��
   SumRho = [SumRho;(rho(Edge(i,1))+rho(Edge(i,2))) / 2];     %��¼�ܶȺ�
%    Edge(i,7) = rho(Edge(i,2));
end
% SumRho = (SumRho-min(SumRho)) / (max(SumRho) - min(SumRho));
w = 0.4 ;
% Edge(:,3) = (Edge(:,3)-min(Edge(:,3))) / (max(Edge(:,3)) - min(Edge(:,3))) ;
% Edge(:,3) = w*Edge(:,3) - (1-w)*SumRho ;
Edge(:,3) = Edge(:,3) ./ SumRho ;
Edge = -sortrows(-Edge,3);

%% Step2��Find the longer edge edge on the MST
T(Edge(1,1),Edge(1,2)) = 0 ;
T(Edge(1,2),Edge(1,1)) = 0 ;
Remember = Edge(1,:);
flag = 1 ;
for i = 2 : ll
    if ifContain(Edge(i,4:5),Remember(:,4:5)) || ifContain(Edge(i,1:2),Remember(:,1:2))
        continue ;
    else
        T(Edge(i,1),Edge(i,2)) = 0 ;
        T(Edge(i,2),Edge(i,1)) = 0 ;
        Remember = [Remember;Edge(i,:)];
        flag = flag + 1 ;
        if flag == K-1
            break ;
        end
    end
end

A = sparse(T) ;
[ci, sizes] = components(A);		%ci��ʾ�صı�ţ�sizes��ʾָ���صĴ�С    
