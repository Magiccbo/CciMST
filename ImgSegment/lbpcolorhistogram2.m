function [ LBPCOLORhist ] = lbpcolorhistogram2( imagecolor, slic_result)
%% Author: Xiaobo Lv.   Email: 791066779@qq.com     Supervisor: Yan Ma 

max1=max(max(slic_result));
neighborrelation=zeros(max1,max1);
size1=size(slic_result);
% image1=imread('beargray.jpg');
image1 = rgb2gray(imagecolor);
% imagecolor=imread([imName,'.jpg']);
cform = makecform('srgb2lab'); 
imagecolor1 = applycform(imagecolor, cform);
%minmaxij中4列内容规定：行最小，最大值，列最小，最大值
LBPhist=zeros(max1,10);
minmaxij=zeros(max1,4);
minmaxij(:,1)=1000;
minmaxij(:,2)=1;
minmaxij(:,3)=1000;
minmaxij(:,4)=1;
for i=1:size1(1)
    for j=1:size1(2)
        mid1=slic_result(i,j);
        if mid1>0
            if i<minmaxij(mid1,1)
                minmaxij(mid1,1)=i;
            end
            if i>minmaxij(mid1,2);
                minmaxij(mid1,2)=i;
            end
            if j<minmaxij(mid1,3)
                minmaxij(mid1,3)=j;
            end
            if j>minmaxij(mid1,4);
                minmaxij(mid1,4)=j;
            end
        end
    end
end
mapping=getmapping(8,'riu2');
for i=1:max1
    i1=minmaxij(i,1);
    i2=minmaxij(i,2);
    j1=minmaxij(i,3);
    j2=minmaxij(i,4);
    mid1=image1(i1:i2,j1:j2);
    LBPhist(i,:)=LBP(mid1,1,8,mapping,'nh');
end
% RGB_aver=zeros(max1,3);
%L
bin_number1=4;
bin_number2=4;
bin_number3=4;
mid1=min(min(imagecolor1(:,:,1)));
imagecolor1(:,:,1)=imagecolor1(:,:,1)-mid1;
mid1=max(max(imagecolor1(:,:,1)));
interval1=fix(mid1/bin_number1);
%A
mid1=min(min(imagecolor1(:,:,2)));
imagecolor1(:,:,2)=imagecolor1(:,:,2)-mid1;
mid1=max(max(imagecolor1(:,:,2)));
interval2=fix(mid1/bin_number2);
%B
mid1=min(min(imagecolor1(:,:,3)));
imagecolor1(:,:,3)=imagecolor1(:,:,3)-mid1;
mid1=max(max(imagecolor1(:,:,3)));
interval3=fix(mid1/bin_number3);
COLORhist1=zeros(max1,bin_number1);
COLORhist2=zeros(max1,bin_number2);
COLORhist3=zeros(max1,bin_number3);
eachsuperpixelnumber=zeros(max1,1);
for i=2:size1(1)-1
    for j=2:size1(2)-1
        mid1=slic_result(i,j);
        eachsuperpixelnumber(mid1)=eachsuperpixelnumber(mid1)+1;
        mid3=floor(imagecolor1(i,j,1)/interval1)+1;
        if mid3>bin_number1
            mid3=bin_number1;
        end
        COLORhist1(mid1,mid3)=COLORhist1(mid1,mid3)+1;
        mid3=floor(imagecolor1(i,j,2)/interval2)+1;
        if mid3>bin_number2
            mid3=bin_number2;
        end
        COLORhist2(mid1,mid3)=COLORhist2(mid1,mid3)+1;
        mid3=floor(imagecolor1(i,j,3)/interval3)+1;
        if mid3>bin_number3
            mid3=bin_number3;
        end
        COLORhist3(mid1,mid3)=COLORhist3(mid1,mid3)+1;
%         RGB_aver(mid1,1)=RGB_aver(mid1,1)+imagecolor(i,j,1);
%         RGB_aver(mid1,2)=RGB_aver(mid1,2)+imagecolor(i,j,2);
%         RGB_aver(mid1,3)=RGB_aver(mid1,3)+imagecolor(i,j,3);
    end
end
for i=1:max1
    COLORhist1(i,:)=COLORhist1(i,:)/eachsuperpixelnumber(i);
    COLORhist2(i,:)=COLORhist2(i,:)/eachsuperpixelnumber(i);
    COLORhist3(i,:)=COLORhist3(i,:)/eachsuperpixelnumber(i);
%     RGB_aver(i,:)=RGB_aver(i,:)/eachsuperpixelnumber(i);
end
LBPCOLORhist=[COLORhist1 COLORhist2 COLORhist3];
%LBPCOLORhist=[LBPhist COLORhist1 COLORhist2 COLORhist3];
% LBPCOLORhist=[COLORhist1];
% LBPCOLORhist=[LBPhist COLORhist1 COLORhist2 COLORhist3 RGB_aver];
% mid1=3;
%LBPCOLORhist=[COLORhist1(:,1:mid1) COLORhist2(:,1:mid1) COLORhist3(:,1:mid1)];
% LBPCOLORhist=[LBPhist];
% LBPCOLORhist=[RGB_aver];
% save 'bearLBPCOLORhist.mat' LBPCOLORhist;
end
    
        

                
                


                    

