function [guessTR, guessE, guessPI] = hmm_em(guessTR, guessE, guessPI, samples)

[M, K] = size(guessE);

N = numel(samples);
[alphas, betas, bX] = deal(cell(N, 1));

tol  = SIFTSE_1.constants('tol');       % tolerance
imax = SIFTSE_1.constants('imax');  	% max num of iterations

% log likelihood of all samples given theta and phi
converged = false;
loglik = 1;
logliks = zeros(1, imax);

for iter = 2:imax
    oldLL = loglik;
    loglik = 0;
    
    % -------------- E-step -------------- 
        
    for n = 1:N    
        X = samples{n};       
        bX{n} = SIFTSE_1.hmm_b(guessE, X);
        [alphas{n}, betas{n}, scale] = ...
            SIFTSE_1.hmm_e(bX{n}, guessTR, guessPI);
        loglik = loglik + sum(log(scale));
    end
    
    % -------------- M-step -------------- 
    
    TR = zeros(M, M);       % probability of a sequence being in (i @ t) and in (j @ t+1)
    E = zeros(M, K);        % co-occurence matrix of state i and feature k
    
    for n = 1:N
        
        X = samples{n};
        T = size(X,1);
        b = bX{n};
        alpha = alphas{n};
        beta = betas{n};
        
        for t = 1:T-1
            
            KSI = zeros(M, M);
            for i = 1:M
                for j = 1:M
                    KSI(i,j) = alpha(i,t)*guessTR(i,j)*b(j, t+1)*beta(j, t+1);
                end
            end
            KSI = KSI./sum(sum(KSI));
            
            TR = TR + KSI;
            
            ETA = sum(KSI, 2);          % stores value per state, i
            E = E + bsxfun(@times, ETA, repmat(X(t,:), M, 1));
            
        end
        
        E = E + bsxfun(@times, alpha(:,T), repmat(X(T,:), M, 1));
        
    end
    
    % update PI
    alpha1 = cellfun(@(a)a(:,1), alphas, 'UniformOutput', false);
    guessPI = sum(cat(2,alpha1{:}),2)/N;
    guessPI = guessPI./(sum(guessPI));
    
    % update THETA
    guessTR = bsxfun(@rdivide, TR, sum(TR, 2));
    
    % update PHI
    guessE = bsxfun(@rdivide, E, sum(E, 2));

    % -------------- Check convergence --------------
    
    logliks(iter) = loglik;
    relative_change = (abs(loglik-oldLL)/(1+abs(oldLL)));
    fprintf('Iteration %d, llh %.2f\n', iter, loglik);
    if relative_change < tol
        fprintf('Converged after iteration %d\n', iter);
        converged = true;
        break; 
    end
end

if ~converged
    fprintf('No convergence\n');
end