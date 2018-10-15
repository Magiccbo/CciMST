clear all
close all 
clc

path(path,'data_sets');             % the path of data sets
path(path,'matlab_bgl');            % the path of SDK of graph theory

data = importdata('data.txt');
K = 3;
[ ClusterLabel, Center ] = CciMST( data,K );
x = data(:,1) ;
y = data(:,2) ;

figure ;
for i=1:max(ClusterLabel)
    hold on
    scatter(x(ClusterLabel==i),y(ClusterLabel==i),'filled');
end
set(gca,'position',[0.05  0.05  0.92  0.92])