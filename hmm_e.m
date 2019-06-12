function [alpha, beta, scale] = hmm_e(bX, guessTR, guessPI)
% calculate forward and backward probabilites

[M, T] = size(bX);

% scaling factor to avoid numerical instability
scale = zeros(1,T);

alpha = zeros(M,T);
alpha(:,1) = bX(:,1) .* guessPI;
scale(1) = sum(alpha(:,1));
alpha(:,1) = alpha(:,1) ./ scale(1);
for t = 2:T
    for i = 1:M
        alpha(i,t) = bX(i,t) .* sum(alpha(:,t-1) .* guessTR(:,i));
    end
    scale(t) = sum(alpha(:,t));
    alpha(:,t) = alpha(:,t)./scale(t);
end

beta = ones(M,T);
for t = T-1:-1:1
    for i = 1:M
        beta(i,t) = (1/scale(t+1)) * sum(guessTR(i,:)' .* bX(:,t+1) .* beta(:,t+1));
    end
end