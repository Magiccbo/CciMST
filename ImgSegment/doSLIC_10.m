function [ slic_result2 ] = doSLIC_10( rgb, superpixel_number,sizeofsuperpixel)
%% Author: Xiaobo Lv.   Email: 791066779@qq.com     Supervisor: Yan Ma 

cform = makecform('srgb2lab'); 
lab = applycform(rgb, cform);
L=double(lab(:,:,1));
A=double(lab(:,:,2));
B=double(lab(:,:,3));


%   B = double(rgb(:,:,3));
%   G = double(rgb(:,:,2));
%   R = double(rgb(:,:,1));
% if max(max(R)) > 1.0 || max(max(G)) > 1.0 || max(max(B)) > 1.0
%   R = double(R) / 255;
%   G = double(G) / 255;
%   B = double(B) / 255;
% end
% % Set a threshold
% T = 0.008856;
% [M, N] = size(R);
% s = M * N;
% RGB = [reshape(R,1,s); reshape(G,1,s); reshape(B,1,s)];
% % RGB to XYZ
% MAT = [0.412453 0.357580 0.180423;
%        0.212671 0.715160 0.072169;
%        0.019334 0.119193 0.950227];
% XYZ = MAT * RGB;
% % Normalize for D65 white point
% X = XYZ(1,:) / 0.950456;
% Y = XYZ(2,:);
% Z = XYZ(3,:) / 1.088754;
% XT = X > T;
% YT = Y > T;
% ZT = Z > T;
% Y3 = Y.^(1/3); 
% fX = XT .* X.^(1/3) + (~XT) .* (7.787 .* X + 16/116);
% fY = YT .* Y3 + (~YT) .* (7.787 .* Y + 16/116);
% fZ = ZT .* Z.^(1/3) + (~ZT) .* (7.787 .* Z + 16/116);
% L = reshape(YT .* (116 * Y3 - 16.0) + (~YT) .* (903.3 * Y), M, N);
% A = reshape(500 * (fX - fY), M, N);
% B = reshape(200 * (fY - fZ), M, N);


%1.初始化种子点：按照设定的超像素个数，在图像内均匀的分配种子点。
%假设图片有N个像素点，预分割为K个相同尺寸的超像素，那么每个超像素的大小为N/K ，
%则相邻种子点的距离（步长）近似为S=sqrt(N/K)。
size1=size(L);
slic_result=zeros(size1(1),size1(2));
imagepixel_number=size1(1)*size1(2);
superpixel_size=fix(imagepixel_number/superpixel_number);
seed_step=fix(sqrt(imagepixel_number/superpixel_number));
%初始化种子点
seed_coordinate=zeros(superpixel_number+3,6);
seed_step_half=fix(seed_step/2);
t=0;
for i=seed_step_half:seed_step:size1(1)-seed_step_half
    for j=seed_step_half:seed_step:size1(2)-seed_step_half
        t=t+1;
        seed_coordinate(t,1)=i;
        seed_coordinate(t,2)=j;
        seed_coordinate(t,3)=L(i,j);
        seed_coordinate(t,4)=A(i,j);
        seed_coordinate(t,5)=B(i,j);
    end
end
superpixel_number=t;
% 在种子点的n*n邻域内重新选择种子点（一般取n=3）。
%具体方法为：计算该邻域内所有像素点的梯度值，将种子点移到该邻域内梯度最小的地方。
for k=1:superpixel_number
    min_gradient=50000;
    for i=-1:1
        for j=-1:1
            x=seed_coordinate(k,1)+i;
            y=seed_coordinate(k,2)+j;
            dx=(L(x-1,y)-L(x+1,y))*(L(x-1,y)-L(x+1,y))+(A(x-1,y)-A(x+1,y))*(A(x-1,y)-A(x+1,y))+(B(x-1,y)-B(x+1,y))*(B(x-1,y)-B(x+1,y));
            dy=(L(x,y-1)-L(x,y+1))*(L(x,y-1)-L(x,y+1))+(A(x,y-1)-A(x,y+1))*(A(x,y-1)-A(x,y+1))+(B(x,y-1)-B(x,y+1))*(B(x,y-1)-B(x,y+1));
            gradient=dx+dy;
            if gradient<min_gradient
                min_gradient=gradient;
                seed_coordinate(k,1)=x;
                seed_coordinate(k,2)=y;
                seed_coordinate(k,3)=L(x,y);
                seed_coordinate(k,4)=A(x,y);
                seed_coordinate(k,5)=B(x,y);                
            end
        end
    end
end
%显示种子点
% for k=1:superpixel_number
%     x=seed_coordinate(k,1);
%     y=seed_coordinate(k,2);
%     rgb(x-1:x+1,y-1:y+1,1)=255;
%     rgb(x-1:x+1,y-1:y+1,2)=0;
%     rgb(x-1:x+1,y-1:y+1,3)=0;
% end
% figure;imshow(rgb);
mid3=(max(max(L))-min(min(L)))^2+(max(max(A))-min(min(A)))^2+(max(max(B))-min(min(B)))^2;
mid4=0.8;mid5=1-mid4;
for num=1:20
%     num
slic_result=zeros(size1(1),size1(2));
%3.在每个种子点周围的邻域内为每个像素点分配类标签（即属于哪个聚类中心）。SLIC的搜索范围限制为2S*2S
min_distance=zeros(size1(1),size1(2));
min_distance(1:size1(1),1:size1(2))=50000000;
S=2*(seed_step^2);
for k=1:superpixel_number
    for i=-seed_step:seed_step
        for j=-seed_step:seed_step
            x=seed_coordinate(k,1)+i;
            y=seed_coordinate(k,2)+j;
            if x>=1 && x<=size1(1) && y>=1 && y<=size1(2)
                dc=(L(x,y)-seed_coordinate(k,3))^2+(A(x,y)-seed_coordinate(k,4))^2+(B(x,y)-seed_coordinate(k,5))^2;
                ds=(x-seed_coordinate(k,1))^2+(y-seed_coordinate(k,2))^2;
                %D=dc/11501+ds/S;
                D=mid4*dc/mid3+mid5*ds/S;
                if D<min_distance(x,y)
                    slic_result(x,y)=k;
                    min_distance(x,y)=D;
                end
            end
        end
    end
end
seed_coordinate=zeros(superpixel_number,6);
for i=1:size1(1)
    for j=1:size1(2)
        mid1=slic_result(i,j);
        if mid1~=0
            seed_coordinate(mid1,1)=seed_coordinate(mid1,1)+i;
            seed_coordinate(mid1,2)=seed_coordinate(mid1,2)+j;
            seed_coordinate(mid1,3)=seed_coordinate(mid1,3)+L(i,j);
            seed_coordinate(mid1,4)=seed_coordinate(mid1,4)+A(i,j);
            seed_coordinate(mid1,5)=seed_coordinate(mid1,5)+B(i,j);
            seed_coordinate(mid1,6)=seed_coordinate(mid1,6)+1;
        end
    end
end
for k=1:superpixel_number
    for i=1:5
        seed_coordinate(k,i)=fix(seed_coordinate(k,i)/seed_coordinate(k,6));
    end
end
end      
% mid1=max(max(slic_result));
% I_rgb=zeros(mid1,3);
% for i=1:mid1
%     for j=1:3
%         I_rgb(i,j)=fix(rand*255);
%     end
% end
% 显示类标签
% for i=2:size1(1)-1
%     for j=2:size1(2)-1
%         mid1=sum(sum(slic_result(i-1:i+1,j-1:j+1)));
%         mid2=slic_result(i,j)*9;
%         mid3=slic_result(i,j);
%         if mid1~=mid2
%             rgb(i,j,1)=I_rgb(mid3,1);
%             rgb(i,j,2)=I_rgb(mid3,2);
%             rgb(i,j,3)=I_rgb(mid3,3);
%         end
%     end
% end
% figure;imshow(rgb);
% pause
%删除过小的超像素
slic_result2=zeros(size1(1),size1(2));
slic_result2(1:size1(1),1:size1(2))=-1;
for i=2:size1(1)-1
    for j=2:size1(2)-1
        if slic_result2(i,j)==-1 && ((4*slic_result(i,j))~=(slic_result(i-1,j)+slic_result(i+1,j)+slic_result(i,j-1)+slic_result(i,j+1)))
            if slic_result(i-1,j)~=slic_result(i,j)
                adjacent=slic_result(i-1,j);
            else
                if slic_result(i+1,j)~=slic_result(i,j)
                    adjacent=slic_result(i+1,j);
                else
                    if slic_result(i,j-1)~=slic_result(i,j)
                        adjacent=slic_result(i,j-1);
                    else
                        if slic_result(i,j+1)~=slic_result(i,j)
                            adjacent=slic_result(i,j+1);
                        end
                    end
                end
            end
            aa=2000000;
            stack1=zeros(imagepixel_number,2);
            flag=1;
            total=0;
            stack1(1,1)=i;
            stack1(1,2)=j;
            slic_result2(i,j)=aa;
            total=total+1;
            while flag>=1
                x=stack1(flag,1);
                y=stack1(flag,2);
                flag=flag-1;
                if (x-1)>=1 && (x-1)<=size1(1) && y>=1 && y<=size1(2)
                    if slic_result(x-1,y)==slic_result(x,y) && slic_result2(x-1,y)~=aa 
                        flag=flag+1;
                        stack1(flag,1)=x-1;
                        stack1(flag,2)=y;
                        slic_result2(x-1,y)=aa;
                        total=total+1;
                    end
                end
                if (x+1)>=1 && (x+1)<=size1(1) && y>=1 && y<=size1(2)
                    if slic_result(x+1,y)==slic_result(x,y)  && slic_result2(x+1,y)~=aa
                        flag=flag+1;
                        stack1(flag,1)=x+1;
                        stack1(flag,2)=y;
                        slic_result2(x+1,y)=aa;
                        total=total+1;
                    end
                end
                if x>=1 && x<=size1(1) && (y-1)>=1 && (y-1)<=size1(2)
                    if slic_result(x,y-1)==slic_result(x,y)  && slic_result2(x,y-1)~=aa
                        flag=flag+1;
                        stack1(flag,1)=x;
                        stack1(flag,2)=y-1;
                        slic_result2(x,y-1)=aa;
                        total=total+1;
                    end
                end
                if x>=1 && x<=size1(1) && (y+1)>=1 && (y+1)<=size1(2)
                    if slic_result(x,y+1)==slic_result(x,y)  && slic_result2(x,y+1)~=aa 
                        flag=flag+1;
                        stack1(flag,1)=x;
                        stack1(flag,2)=y+1;
                        slic_result2(x,y+1)=aa;
                        total=total+1;
                    end
                end
            end
            if total<sizeofsuperpixel
                slic_result2(slic_result2==aa)=adjacent;
            else
                slic_result2(slic_result2==aa)=slic_result(i,j);
            end
        end
    end
end
for i=2:size1(1)-1
    for j=2:size1(2)-1
        if slic_result2(i,j)~=slic_result2(i-1,j) && slic_result2(i,j)~=slic_result2(i+1,j) && slic_result2(i,j)~=slic_result2(i,j-1) && slic_result2(i,j)~=slic_result2(i,j+1) 
            slic_result2(i,j)=slic_result2(i-1,j);
        end
    end
end
%对超像素块重新编号
max1=max(max(slic_result2));
eachsuperpixelnumber=zeros(max1,1);
for i=2:size1(1)-1
    for j=2:size1(2)-1
        mid1=slic_result2(i,j);
        eachsuperpixelnumber(mid1)=eachsuperpixelnumber(mid1)+1;
    end
end
top1=1;bottom1=max1;
while top1<bottom1
    if eachsuperpixelnumber(top1)==0 && eachsuperpixelnumber(bottom1)~=0
        slic_result2(slic_result2==bottom1)=top1;
        top1=top1+1;
        bottom1=bottom1-1;
    else
        if eachsuperpixelnumber(top1)==0 && eachsuperpixelnumber(bottom1)==0
            bottom1=bottom1-1;
        else
            if eachsuperpixelnumber(top1)~=0
                top1=top1+1;
            end
        end
    end
end        




%删除过小的超像素
slic_result=slic_result2;
slic_result2=zeros(size1(1),size1(2));
slic_result2(1:size1(1),1:size1(2))=-1;
for i=2:size1(1)-1
    for j=2:size1(2)-1
        if slic_result2(i,j)==-1 && ((4*slic_result(i,j))~=(slic_result(i-1,j)+slic_result(i+1,j)+slic_result(i,j-1)+slic_result(i,j+1)))
            if slic_result(i-1,j)~=slic_result(i,j)
                adjacent=slic_result(i-1,j);
            else
                if slic_result(i+1,j)~=slic_result(i,j)
                    adjacent=slic_result(i+1,j);
                else
                    if slic_result(i,j-1)~=slic_result(i,j)
                        adjacent=slic_result(i,j-1);
                    else
                        if slic_result(i,j+1)~=slic_result(i,j)
                            adjacent=slic_result(i,j+1);
                        end
                    end
                end
            end
            aa=2000000;
            stack1=zeros(imagepixel_number,2);
            flag=1;
            total=0;
            stack1(1,1)=i;
            stack1(1,2)=j;
            slic_result2(i,j)=aa;
            total=total+1;
            while flag>=1
                x=stack1(flag,1);
                y=stack1(flag,2);
                flag=flag-1;
                if (x-1)>=1 && (x-1)<=size1(1) && y>=1 && y<=size1(2)
                    if slic_result(x-1,y)==slic_result(x,y) && slic_result2(x-1,y)~=aa 
                        flag=flag+1;
                        stack1(flag,1)=x-1;
                        stack1(flag,2)=y;
                        slic_result2(x-1,y)=aa;
                        total=total+1;
                    end
                end
                if (x+1)>=1 && (x+1)<=size1(1) && y>=1 && y<=size1(2)
                    if slic_result(x+1,y)==slic_result(x,y)  && slic_result2(x+1,y)~=aa
                        flag=flag+1;
                        stack1(flag,1)=x+1;
                        stack1(flag,2)=y;
                        slic_result2(x+1,y)=aa;
                        total=total+1;
                    end
                end
                if x>=1 && x<=size1(1) && (y-1)>=1 && (y-1)<=size1(2)
                    if slic_result(x,y-1)==slic_result(x,y)  && slic_result2(x,y-1)~=aa
                        flag=flag+1;
                        stack1(flag,1)=x;
                        stack1(flag,2)=y-1;
                        slic_result2(x,y-1)=aa;
                        total=total+1;
                    end
                end
                if x>=1 && x<=size1(1) && (y+1)>=1 && (y+1)<=size1(2)
                    if slic_result(x,y+1)==slic_result(x,y)  && slic_result2(x,y+1)~=aa 
                        flag=flag+1;
                        stack1(flag,1)=x;
                        stack1(flag,2)=y+1;
                        slic_result2(x,y+1)=aa;
                        total=total+1;
                    end
                end
            end
            if total<sizeofsuperpixel
                slic_result2(slic_result2==aa)=adjacent;
            else
                slic_result2(slic_result2==aa)=slic_result(i,j);
            end
        end
    end
end
for i=2:size1(1)-1
    for j=2:size1(2)-1
        if slic_result2(i,j)~=slic_result2(i-1,j) && slic_result2(i,j)~=slic_result2(i+1,j) && slic_result2(i,j)~=slic_result2(i,j-1) && slic_result2(i,j)~=slic_result2(i,j+1) 
            slic_result2(i,j)=slic_result2(i-1,j);
        end
    end
end
%对超像素块重新编号
max1=max(max(slic_result2));
eachsuperpixelnumber=zeros(max1,1);
for i=2:size1(1)-1
    for j=2:size1(2)-1
        mid1=slic_result2(i,j);
        eachsuperpixelnumber(mid1)=eachsuperpixelnumber(mid1)+1;
    end
end
top1=1;bottom1=max1;
while top1<bottom1
    if eachsuperpixelnumber(top1)==0 && eachsuperpixelnumber(bottom1)~=0
        slic_result2(slic_result2==bottom1)=top1;
        top1=top1+1;
        bottom1=bottom1-1;
    else
        if eachsuperpixelnumber(top1)==0 && eachsuperpixelnumber(bottom1)==0
            bottom1=bottom1-1;
        else
            if eachsuperpixelnumber(top1)~=0
                top1=top1+1;
            end
        end
    end
end  



%删除过小的超像素
slic_result=slic_result2;
slic_result2=zeros(size1(1),size1(2));
slic_result2(1:size1(1),1:size1(2))=-1;
for i=2:size1(1)-1
    for j=2:size1(2)-1
        if slic_result2(i,j)==-1 && ((4*slic_result(i,j))~=(slic_result(i-1,j)+slic_result(i+1,j)+slic_result(i,j-1)+slic_result(i,j+1)))
            if slic_result(i-1,j)~=slic_result(i,j)
                adjacent=slic_result(i-1,j);
            else
                if slic_result(i+1,j)~=slic_result(i,j)
                    adjacent=slic_result(i+1,j);
                else
                    if slic_result(i,j-1)~=slic_result(i,j)
                        adjacent=slic_result(i,j-1);
                    else
                        if slic_result(i,j+1)~=slic_result(i,j)
                            adjacent=slic_result(i,j+1);
                        end
                    end
                end
            end
            aa=2000000;
            stack1=zeros(imagepixel_number,2);
            flag=1;
            total=0;
            stack1(1,1)=i;
            stack1(1,2)=j;
            slic_result2(i,j)=aa;
            total=total+1;
            while flag>=1
                x=stack1(flag,1);
                y=stack1(flag,2);
                flag=flag-1;
                if (x-1)>=1 && (x-1)<=size1(1) && y>=1 && y<=size1(2)
                    if slic_result(x-1,y)==slic_result(x,y) && slic_result2(x-1,y)~=aa 
                        flag=flag+1;
                        stack1(flag,1)=x-1;
                        stack1(flag,2)=y;
                        slic_result2(x-1,y)=aa;
                        total=total+1;
                    end
                end
                if (x+1)>=1 && (x+1)<=size1(1) && y>=1 && y<=size1(2)
                    if slic_result(x+1,y)==slic_result(x,y)  && slic_result2(x+1,y)~=aa
                        flag=flag+1;
                        stack1(flag,1)=x+1;
                        stack1(flag,2)=y;
                        slic_result2(x+1,y)=aa;
                        total=total+1;
                    end
                end
                if x>=1 && x<=size1(1) && (y-1)>=1 && (y-1)<=size1(2)
                    if slic_result(x,y-1)==slic_result(x,y)  && slic_result2(x,y-1)~=aa
                        flag=flag+1;
                        stack1(flag,1)=x;
                        stack1(flag,2)=y-1;
                        slic_result2(x,y-1)=aa;
                        total=total+1;
                    end
                end
                if x>=1 && x<=size1(1) && (y+1)>=1 && (y+1)<=size1(2)
                    if slic_result(x,y+1)==slic_result(x,y)  && slic_result2(x,y+1)~=aa 
                        flag=flag+1;
                        stack1(flag,1)=x;
                        stack1(flag,2)=y+1;
                        slic_result2(x,y+1)=aa;
                        total=total+1;
                    end
                end
            end
            if total<sizeofsuperpixel
                slic_result2(slic_result2==aa)=adjacent;
            else
                slic_result2(slic_result2==aa)=slic_result(i,j);
            end
        end
    end
end
for i=2:size1(1)-1
    for j=2:size1(2)-1
        if slic_result2(i,j)~=slic_result2(i-1,j) && slic_result2(i,j)~=slic_result2(i+1,j) && slic_result2(i,j)~=slic_result2(i,j-1) && slic_result2(i,j)~=slic_result2(i,j+1) 
            slic_result2(i,j)=slic_result2(i-1,j);
        end
    end
end
%对超像素块重新编号
max1=max(max(slic_result2));
eachsuperpixelnumber=zeros(max1,1);
for i=2:size1(1)-1
    for j=2:size1(2)-1
        mid1=slic_result2(i,j);
        eachsuperpixelnumber(mid1)=eachsuperpixelnumber(mid1)+1;
    end
end
top1=1;bottom1=max1;
while top1<bottom1
    if eachsuperpixelnumber(top1)==0 && eachsuperpixelnumber(bottom1)~=0
        slic_result2(slic_result2==bottom1)=top1;
        top1=top1+1;
        bottom1=bottom1-1;
    else
        if eachsuperpixelnumber(top1)==0 && eachsuperpixelnumber(bottom1)==0
            bottom1=bottom1-1;
        else
            if eachsuperpixelnumber(top1)~=0
                top1=top1+1;
            end
        end
    end
end  







%删除过小的超像素
slic_result=slic_result2;
slic_result2=zeros(size1(1),size1(2));
slic_result2(1:size1(1),1:size1(2))=-1;
for i=2:size1(1)-1
    for j=2:size1(2)-1
        if slic_result2(i,j)==-1 && ((4*slic_result(i,j))~=(slic_result(i-1,j)+slic_result(i+1,j)+slic_result(i,j-1)+slic_result(i,j+1)))
            if slic_result(i-1,j)~=slic_result(i,j)
                adjacent=slic_result(i-1,j);
            else
                if slic_result(i+1,j)~=slic_result(i,j)
                    adjacent=slic_result(i+1,j);
                else
                    if slic_result(i,j-1)~=slic_result(i,j)
                        adjacent=slic_result(i,j-1);
                    else
                        if slic_result(i,j+1)~=slic_result(i,j)
                            adjacent=slic_result(i,j+1);
                        end
                    end
                end
            end
            aa=2000000;
            stack1=zeros(imagepixel_number,2);
            flag=1;
            total=0;
            stack1(1,1)=i;
            stack1(1,2)=j;
            slic_result2(i,j)=aa;
            total=total+1;
            while flag>=1
                x=stack1(flag,1);
                y=stack1(flag,2);
                flag=flag-1;
                if (x-1)>=1 && (x-1)<=size1(1) && y>=1 && y<=size1(2)
                    if slic_result(x-1,y)==slic_result(x,y) && slic_result2(x-1,y)~=aa 
                        flag=flag+1;
                        stack1(flag,1)=x-1;
                        stack1(flag,2)=y;
                        slic_result2(x-1,y)=aa;
                        total=total+1;
                    end
                end
                if (x+1)>=1 && (x+1)<=size1(1) && y>=1 && y<=size1(2)
                    if slic_result(x+1,y)==slic_result(x,y)  && slic_result2(x+1,y)~=aa
                        flag=flag+1;
                        stack1(flag,1)=x+1;
                        stack1(flag,2)=y;
                        slic_result2(x+1,y)=aa;
                        total=total+1;
                    end
                end
                if x>=1 && x<=size1(1) && (y-1)>=1 && (y-1)<=size1(2)
                    if slic_result(x,y-1)==slic_result(x,y)  && slic_result2(x,y-1)~=aa
                        flag=flag+1;
                        stack1(flag,1)=x;
                        stack1(flag,2)=y-1;
                        slic_result2(x,y-1)=aa;
                        total=total+1;
                    end
                end
                if x>=1 && x<=size1(1) && (y+1)>=1 && (y+1)<=size1(2)
                    if slic_result(x,y+1)==slic_result(x,y)  && slic_result2(x,y+1)~=aa 
                        flag=flag+1;
                        stack1(flag,1)=x;
                        stack1(flag,2)=y+1;
                        slic_result2(x,y+1)=aa;
                        total=total+1;
                    end
                end
            end
            if total<sizeofsuperpixel
                slic_result2(slic_result2==aa)=adjacent;
            else
                slic_result2(slic_result2==aa)=slic_result(i,j);
            end
        end
    end
end
for i=2:size1(1)-1
    for j=2:size1(2)-1
        if slic_result2(i,j)~=slic_result2(i-1,j) && slic_result2(i,j)~=slic_result2(i+1,j) && slic_result2(i,j)~=slic_result2(i,j-1) && slic_result2(i,j)~=slic_result2(i,j+1) 
            slic_result2(i,j)=slic_result2(i-1,j);
        end
    end
end
%对超像素块重新编号
max1=max(max(slic_result2));
eachsuperpixelnumber=zeros(max1,1);
for i=2:size1(1)-1
    for j=2:size1(2)-1
        mid1=slic_result2(i,j);
        eachsuperpixelnumber(mid1)=eachsuperpixelnumber(mid1)+1;
    end
end
top1=1;bottom1=max1;
while top1<bottom1
    if eachsuperpixelnumber(top1)==0 && eachsuperpixelnumber(bottom1)~=0
        slic_result2(slic_result2==bottom1)=top1;
        top1=top1+1;
        bottom1=bottom1-1;
    else
        if eachsuperpixelnumber(top1)==0 && eachsuperpixelnumber(bottom1)==0
            bottom1=bottom1-1;
        else
            if eachsuperpixelnumber(top1)~=0
                top1=top1+1;
            end
        end
    end
end  


mid1=max(max(slic_result2));
I_rgb=zeros(mid1,3);
for i=1:mid1
    for j=1:3
        I_rgb(i,j)=fix(rand*255);
    end
end
%显示类标签
for i=2:size1(1)-1
    for j=2:size1(2)-1
        mid1=sum(sum(slic_result2(i-1:i+1,j-1:j+1)));
        mid2=slic_result2(i,j)*9;
        mid3=slic_result2(i,j);
        if mid1~=mid2
            rgb(i,j,1)=I_rgb(mid3,1);
            rgb(i,j,2)=I_rgb(mid3,2);
            rgb(i,j,3)=I_rgb(mid3,3);
        end
    end
end
figure;imshow(rgb);
end