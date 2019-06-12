stimuli = BGU300_constants('stimuli');                                      % image dataset

datadir = fullfile(drive, 'Datasets\Gaze_Shifting\BGU_300');                % train data
fixpaths = fullfile(datadir, 'fixpaths_train.csv');

tools = fullfile(drive, 'workspace\Tools');                                 % Image Segmentation
addpath(genpath(fullfile(tools, '\segmentaion\EntropyRateSuperpixel')));    

addpath(genpath(fullfile(tools, '\vlfeat-0.9.21')));                        % SIFT and K-means
vl_setup

[thisdir, ~, ~] = fileparts(mfilename('fullpath'));

load(fullfile(thisdir, 'dict.mat'));        % Dict with K visual words
load(fullfile(thisdir, 'hmm.mat'));         % HMM model
num_regions = SIFTSE_1.constants('regnum'); % number of image segments

M = size(TR, 1);                            % number of hmm states
out = cell(M, 1);                           % stores gazed regions 

idx = 1;
prv = '';

[imnames, sequences] = read_samples(fixpaths);

for i = 1:numel(imnames)
    
    [~, cur, ext] = fileparts(imnames{i});    
    stimulus = imread(fullfile(stimuli, [cur, ext]));  
    labelimg = mex_ers(double(stimulus), num_regions) + 1;    
    [f, bovw] = SIFTSE_1.reg2bovw(stimulus, labelimg, dict);
    
    imseqs = sequences{i};    
    reg_state = zeros(num_regions, M);
    
    for j = 1:numel(imseqs)
        
        fixs = imseqs{j};
        T = size(fixs, 1);
        
        % Get sequence of fixated regions
        fixind = sub2ind(size(labelimg), fixs(:,2), fixs(:,1));
        R = labelimg(fixind);

        % Calculate most probable sequence of latent states
        X = bovw(R);
        bX = SIFTSE_1.hmm_b(E, cell2mat(X));
        L = hmm_viterbi(bX, TR, PI);
        
        % histogram of states per region id
        for t = 1:T
            reg_state(R(t), L(t)) = reg_state(R(t), L(t)) + 1;
        end
        
    end
    
    reg_id = find(sum(reg_state, 2));
    reg_state = reg_state(reg_id, :);
    
    % display([reg_id, reg_state]); 
    
    % group regions by state. If more than two states are noted 
    % for the same region, pick the more frequent one
    for k = 1:numel(reg_id)
        
        reg_img = extract_region(reg_id(k), labelimg, stimulus);
        [~, state] = max(reg_state(k,:));
        out{state} = [out{state} {reg_img}];
        
    end
    
end
    

% figure(1);
% showpath(stimulus, labeled_img, segpath, numel(segpath))

% regs = out{1};
% probs = cellfun(@(x)x.prob, regs);
% [l, I] = sort(probs, 'descend');
% reg_id = I(1:49);
% images = cellfun(@(x)imresize(x.image, [50, 50]), regs(reg_id), 'un', 0);

% regs = out{8};
% reg_id = randperm(numel(regs), 49);
% images = regs(reg_id);
% 
% figure();
% ha = tight_subplot(7, 7, [.01 .01], [.01 .01], [.01 .01]);
% for i = 1:49
%     axes(ha(i));
%     imshow(images{i})
% end
    

