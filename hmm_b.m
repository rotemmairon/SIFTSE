function [bX] = hmm_b(E, X)

M  = size(E, 1);
T  = size(X, 1);
bX = zeros(M, T);

for i = 1:M    
    for t = 1:T        
        bX(i,t) = prod(E(i,:).^X(t,:));    
    end    
end