function[Sep,Com] = new_Indicator(Dist,ci,sizes,T,start)
%% Author: Xiaobo Lv.   Email: 791066779@qq.com     supervisor: Yan Ma 
K = length(unique(ci));
MeanD = zeros(K*(K-1),1);
ind = cell(K,2);
flag = 1 ;
for i = 1 : K
    for j = 1 : K
        if i ~= j
            a = sizes(i) ; 
            indx = find(ci == i);
            indx1 = find(ci == j) ;
            ShortD = zeros(length(indx),1);
            for k = 1 : length(indx)
                dd = Dist(indx(k),:);
                dd1 = dd(indx1) ;
                ShortD(k) = min(dd1);
            end
            ShortD1 = sort(ShortD);
            ShortD2 = ShortD1(1:ceil(a*0.2));
            MeanD(flag) = mean(ShortD2);
            flag = flag + 1 ;
        end
    end
end
Sep = mean(MeanD);

%% º∆À„¿‡ƒ⁄æ‡¿Î
Com1 = zeros(K,1);
sizes = ceil(sizes*0.2);
Com = 0 ;
for i = 1 : K
    indx = find(ci==i);    
    a = Dist(indx,indx);
    if length(a) == 1 
        continue ;
    end
%     Com1(i) = mean(a(a~=0));
    a = a(a~=0);
    a = -sort(-a) ;
    a = a(1:ceil(length(a)*0.2));
    Com1(i) = mean(a);
    Com = Com + Com1(i)*sizes(i)/sum(sizes);
end
% Com1(isnan(Com1)) = 0;
% Com = mean(Com1);
% Com = 0 ; 

% Com = sum(Com1);

