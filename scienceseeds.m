function [ clusterCenter,Density] = scienceseeds(data,K,percent,dist)
%% Author: Xiaobo Lv.   Email: 791066779@qq.com     supervisor: Yan Ma 
%SCIENCESEEDS Summary of this function goes here
%This function is designed to implement the algorithm of points selection that published in SCIENCE in 2014
% input_args:
%       data    : Data sets to be clustered
%       K       : The number of clusters
%       percent : The percent of cutoff distance
%       dist1   : The Geodesic distance matrix
%       
% output_args:
%       clusterCenter : The K clusters' centers
%       Density       : The guassian density of each point
%
%   Detailed explanation goes here

alldist=dist(dist~=0);
N=size(alldist,1);
ND=size(data,1);

position=round(N*percent/100); 
sda=sort(alldist); 
dc=sda(position);
for i=1:ND
    Density(i)=0.;
end
% Gaussian kernel
for i=1:ND-1
    for j=i+1:ND
        Density(i)=Density(i)+exp(-(dist(i,j)/dc)*(dist(i,j)/dc));
        Density(j)=Density(j)+exp(-(dist(i,j)/dc)*(dist(i,j)/dc));
    end
end
maxd=max(max(dist));
[~,ordrho]=sort(Density,'descend');
delta(ordrho(1))=-1.;
nneigh(ordrho(1))=0;
for ii=2:ND
    dd = [];
    indx = [] ;
    delta(ordrho(ii))=maxd;
    flag = 0 ;
    for jj=1:ii-1
        if(dist(ordrho(ii),ordrho(jj))<delta(ordrho(ii)))
            flag = flag + 1;
            dd = [dd,dist(ordrho(ii),ordrho(jj))] ;
            indx = [indx,ordrho(jj)];            
        end
    end
    ind = find(dd==min(dd));
    delta(ordrho(ii))=dd(ind(1)) ;
    nneigh(ordrho(ii))=ordrho(ind(1));
end
delta(ordrho(1))=max(delta(:));
hunhe = Density .* delta;
[~, v]=sort(hunhe,'descend');
ncloc=v(1:K);
clusterCenter=data(ncloc,:);

