function [z, p] = makepath(TR, E, PI, bovws, T)
%
%
% Input:
%   bX:  M x T emmision matrix
%   TR:  M x M transition matrix
%   PI:  M x 1 start probability (prior)
% Output:
%   z: 1 x n latent state
%   p: 1 x n probability
% 

[z, p] = deal(zeros(1, T));

% for each region, calculate alpha(i, 1) the probability for the region 
% to be emmited at the beginning of a sequence at each state of the hmm.
bX = SIFTSE_1.hmm_b(E, cell2mat(bovws));
alpha1 = bsxfun(@times, bX, PI);

% state-region pair with highest probability
[~, idx] = max(alpha1(:));
[z(1), p(1)] = ind2sub(size(bX), idx);

for t = 2:T
    
    % inhibit previous region
    bX(:, p(t-1)) = 0;
    
    % select next region
    p_next = bsxfun(@times, bX, TR(z(t-1), :)');   
    [~, idx] = max(p_next(:));   
    [z(t), p(t)] = ind2sub(size(bX), idx);
        
end


