function [r] = makepath(TR, E, PI, bovws, T)

r = zeros(1, T);

N = numel(bovws);
b = SIFTSE_1.hmm_b(E, cell2mat(bovws));
M = size(TR, 1);

alpha_cur = bsxfun(@times, b, PI);
alpha_nxt = zeros(size(alpha_cur));

p = sum(alpha_cur);     % probability per region to be gazed @ time t=1
[~, r(1)] = max(p);     % selected first region 

for t = 2:T
    
    % inhibit return to previous region
    b(:, r(t-1)) = 0;
    
    % probability of region k to be gazed @ time t
    p = zeros(1, N);
    for k = 1:N
        for i = 1:M
            for j = 1:M
                p(k) = p(k) + b(i, k) * TR(j, i) * alpha_cur(j, k);
            end
            alpha_nxt(i, k) = b(i, k) * sum(alpha_cur(:, k) .* TR(:,i));
        end
    end
    alpha_cur = alpha_nxt;
    [~, r(t)] = max(p(:));
    
end