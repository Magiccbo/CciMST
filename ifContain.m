function [inc] = ifContain(a,b)
inc = 0 ;

for i = 1 : size(b,1)
    if isequal(a,b(i,:))
        inc = 1 ;
        break ;
    end
end