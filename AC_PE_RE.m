function [AC,PR,RE,F1] = AC_PE_RE(true_labels, cluster_labels)
%ACCURACY Compute clustering accuracy using the true and cluster labels and
%   return the value in 'score'.
%
%   Input  : true_labels    : N-by-1 vector containing true labels
%            cluster_labels : N-by-1 vector containing cluster labels
%
%   Output : score          : clustering accuracy

% Compute the confusion matrix 'cmat', where
%   col index is for true label (CAT),
%   row index is for cluster label (CLS).
n = length(true_labels);
cat = spconvert([(1:n)' true_labels ones(n,1)]);
cls = spconvert([(1:n)' cluster_labels ones(n,1)]);
cls = cls';
cmat = full(cls * cat);

%
% Calculate accuracy
%
[match, cost] = hungarian(-cmat);

l = size(match,2) ;
for i = 1 : l
    ind = find(match(:,i) == 1);
    cmat([i,ind],:) = cmat([ind,i],:) ;
    match([i,ind],:) = match([ind,i],:) ;
end

sum_A = zeros(l,1);
sum_p = zeros(l,1);
sum_r = zeros(l,1);
for i = 1 : l
    sum_A(i) = cmat(i,i) ;
    sum_p(i) = cmat(i,i)/sum(cmat(i,:)) ; 
    sum_r(i) = cmat(i,i)/sum(cmat(:,i));
end
AC = sum(sum_A)/length(true_labels);
PR = mean(sum_p);
RE = mean(sum_r);
F1 = 2*PR*RE/(PR+RE);


