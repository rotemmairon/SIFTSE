function [words] = desc2word(siftvecs, dict)

% siftvecs: rows are variables, cols are observations

% dict: rows are variables, cols are observations

words = [];

if isempty(siftvecs); return; end
    
dist = pdist2(siftvecs', dict');

[~, words] = min(dist, [], 2);
    
end

