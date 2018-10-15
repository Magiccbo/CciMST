function [ ClusterLabel, Center ] = CciMST( data,K )
%% Author: Xiaobo Lv.   Email: 791066779@qq.com     supervisor: Yan Ma 

% CciMST Summary of this function goes here 
% input_args:
%       data : Data sets to be clustered
%       K    : The number of clusters
%
% output_args:
%       ClusterLabel : The final clusters' label
%       Center       : The K clusters' centers
%
% Demo for UCI data sets : 
%       path(path,'data_sets');
%       path(path,'matlab_bgl');
%       data = importdata('WheatSeeds.mat');   
%       K = 3;
%       [ ClusterLabel, Center ] = CciMST( data,K );

    T = makeMST(data) ;
    T2 = T ;               
    T1 = triu(T);
    dist1 = cal_Dist(data) ;

    %% Determine the cluster centers
    [centroids,rho] = scienceseeds(data,K,2,dist1);   
    start = zeros(K,1);
    for i = 1 : size(data,1)
        for j = 1 : K
            if data(i,:) == centroids(j,:)
                start(j) = i ;
            end
        end
    end

    [ci,~,sizes,T1,EdgeOnPath] = MST_Cluster(dist1,T2,start,K,rho);

    newEonP = EdgeOnPath ; 
    for i = 1 : K 
        newEonP(EdgeOnPath==i) = ci(start(i));
    end

    [Sep,Com] = new_Indicator(dist1,ci,sizes,T1,start);

    [centroids1,rho1] = scienceseeds(data,K,20,dist1);   
    start1 = zeros(K,1);
    for i = 1 : size(data,1)
        for j = 1 : K
            if data(i,:) == centroids1(j,:)
                start1(j) = i ;
            end
        end
    end

    [ci1,~,sizes1,T1,EdgeOnPath1] = MST_Cluster(dist1,T2,start1,K,rho1);
    newEonP = EdgeOnPath1 ; 
    for i = 1 : K 
        newEonP(EdgeOnPath1==i) = ci1(start1(i));
    end
    [Sep1,Com1] = new_Indicator(dist1,ci1,sizes1,T1,start1);

    %% Determine the inconsistent edges
    disp('-------- Cutoff distance : 2%--------');
    ICV2 = Sep/Com ;
    str = ['Sep/CP£º',num2str(Sep),'/',num2str(Com),'=',num2str(ICV2)];
    disp(str);
    disp('-------- Cutoff distance : 20%--------');
    ICV20 = Sep1/Com1 ;
    str1 = ['Sep/Cp£º',num2str(Sep1),'/',num2str(Com1),'=',num2str(ICV20)];
    disp(str1);

    if ICV2 > ICV20
        ClusterLabel = ci;
        Center = centroids;
    else
        ClusterLabel = ci1;
        Center = centroids1;
    end

end

