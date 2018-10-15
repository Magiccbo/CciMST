clear all
close all 
clc

path(path,'data_sets');             % the path of data sets
path(path,'matlab_bgl');            % the path of SDK of graph theory
data = importdata('WheatSeeds.mat');
group = importdata('WheatSeedsgroup.mat');
K = length(unique(group));
[ ClusterLabel, Center ] = CciMST( data,K );

[AC,PR,RE,F1] = AC_PE_RE(ClusterLabel,group);
disp(['AC=', num2str(AC) , '; ','PR=',num2str(PR),'; ','RE=',num2str(RE),'; ','F1='...
    num2str(F1)])


