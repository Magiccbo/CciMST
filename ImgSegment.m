clear all 
close all 
clc

path(path,'ImgSegment');
imName = '41004';
superpixel_number=250;
sizeofsuperpixel=100;
rgb=imread([imName,'.jpg']);

[ slic_result ] = doSLIC_10(rgb, 250, 100);
[ LBPCOLORhist ] = lbpcolorhistogram2(rgb, slic_result);
nColors = 3;
[ ClusterLabel, Center ] = CciMST( LBPCOLORhist,nColors );
I_rgb=zeros(nColors,3);
for i=1:nColors
    for j=1:3
        I_rgb(i,j)=fix(rand*255);
    end
end
% load 'bear.mat' slic_result_100;
imagecolor=rgb;
imagecolor1=imagecolor;
size1=size(slic_result);
for i=2:size1(1)-1
    for j=2:size1(2)-1
        mid1=slic_result(i,j);
        mid2=ClusterLabel(mid1);
        imagecolor1(i,j,:)=I_rgb(mid2,:);
    end
end
imagecolor1 = rgb2gray(imagecolor1);
allnum=unique(imagecolor1(2:size1(1)-1,2 : size1(2) - 1 ));
avgcolor = zeros(nColors,3);
% figure;
% imagecolor2 = imagecolor;
[m,n] = size(imagecolor1);
aa = reshape(imagecolor,m*n,3);
imagecolor2 = aa;
for i = 1 : nColors 
    idx = find(imagecolor1==allnum(i));
    centroids1(i,:) = mean(aa(idx,:));
    imagecolor2(idx,1) = centroids1(i,1);
    imagecolor2(idx,2) = centroids1(i,2);
    imagecolor2(idx,3) = centroids1(i,3);
end
imagecolor2 = reshape(imagecolor2,[m,n,3]);
% 
% subplot(2,1,1);imshow(imagecolor);title('Ô­Í¼')    
% subplot(2,1,2);imshow(imagecolor2);title('·Ö¸î')
figure
imshow(imagecolor2);
title('segmentImg');
