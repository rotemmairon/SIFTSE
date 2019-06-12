function [f, regbovw] = reg2bovw(stimulus, labels, dict)

[h, w] = size(labels);
n_words = size(dict, 2);

% Compute SIFT features (f has a column per keypoint. A keypoint 
% is a disk of center  f(1:2), scale f(3) and orientation f(4)
grey = single(rgb2gray(stimulus));
[f, d] = vl_sift(grey);

% Get the region label for each SIFT keypoint
siftind = uint32(sub2ind([h, w], f(2,:), f(1,:)));
siftreg = labels(siftind);

% Group SIFT descriptors by region (associate empty regions with empty bags)
regdesc = cell(max(labels(:)), 1);
[sorted, sortidx] = sort(siftreg);
[from, till] = blockidx(sorted+1);

for i = 1:numel(from)
    idxs  = sortidx(from(i): till(i));
    label = siftreg(idxs(1));
    regdesc{label} = d(:, idxs);
end

% Transform SIFT descriptors into visual words
regwords = cellfun(@(x)SIFTSE_1.desc2word(double(x), dict), regdesc, 'un', 0);

% words to histogram (BoVW)
regbovw = cellfun(@(x)hist(x, 1:n_words), regwords, 'un', 0);