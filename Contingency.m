function Cont=Contingency(Mem1,Mem2)

if nargin < 2 | min(size(Mem1)) > 1 | min(size(Mem2)) > 1
   error('Contingency: Requires two vector arguments')
   return
end

Cont=zeros(max(Mem1),max(Mem2));

for i = 1:length(Mem1);
   Cont(Mem1(i),Mem2(i))=Cont(Mem1(i),Mem2(i))+1;
end

K = length(Cont);
% for i = 1 : K - 1
%     ind = find(Cont(i:K,i)==max(Cont(i:K,i)));
%     ind = ind(1) + i - 1 ;
%     Cont([i,ind],:) = Cont([ind,i],:);
% end

A = (Cont(Cont~=0)) ;
A = -sort(-A) ;

Rem = [] ;
for i = 1 : length(A)-1 
    [x,y] = find(Cont==A(i)) ;
    for k = 1 : length(x)
        if ~ismember(x(k),Rem) && ~ismember(y(k),Rem) && max(Cont(x(k),:)) == A(i) && max(Cont(:,y(k))) == A(i)
            Cont([x(k),y(k)],:) = Cont([y(k),x(k)],:) ;
            Rem = [Rem,x(k)];
            Rem = [Rem,y(k)];
            break ;
        end
    end
end
