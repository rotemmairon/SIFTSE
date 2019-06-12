stimuli = BGU300_constants('stimuli');                                      % image dataset

datadir = fullfile(drive, 'Datasets\Gaze_Shifting\BGU_300');                % train data
fixpaths = fullfile(datadir, 'fixpaths_train.csv');

tools = fullfile(drive, 'workspace\Tools');                                 % Image Segmentation
addpath(genpath(fullfile(tools, '\segmentaion\EntropyRateSuperpixel')));    

addpath(genpath(fullfile(tools, '\vlfeat-0.9.21')));                        % SIFT and K-means
vl_setup

% Load dictionary with K visual words
[thisdir, ~, ~] = fileparts(mfilename('fullpath'));
load(fullfile(thisdir, 'features.mat'));
Y = double(features);
K = 20;
[dict, A] = vl_kmeans(Y, K);

% count samples
FID = fopen(fixpaths);
lines = cell2mat(textscan(FID,'%1c%*[^\n]'));
N = numel(lines);
fclose(FID);

% read data and store samples
samples = cell(N, 1);
idx = 1;
prv = '';
FID = fopen(fixpaths);

% superpixels per image
nC = SIFTSE_1.constants('regnum');

nosift = 0;

while ~feof(FID)
    tline = strsplit(fgetl(FID),',');
    [~, cur, ext] = fileparts(tline{1});
    
    if ~strcmp(cur, prv)
        fprintf('image: %s\n', cur);
        prv = cur;
        % read image (once for all image trials)
        stimulus = imread(fullfile(stimuli, [cur, ext]));
        % Segment into regions
        labels = mex_ers(double(stimulus), nC);
        labels = labels + 1;
        % Represent regions as BoVW
        [f, bovw] = SIFTSE_1.reg2bovw(stimulus, labels, dict);
    end
    
    % get a single raw scanpath
    slen = numel(tline)-2;
    fixs = cell2mat(tline(2:end-1));
    fixs = strsplit(fixs(2:end-1));
    fixs = reshape(cellfun(@(x)str2double(x), fixs), 2, slen)';
    
    % Get fixated regions
    fixind = sub2ind(size(labels), fixs(:,2), fixs(:,1));
    gazed = labels(fixind);
    
    % represent fixated regions BoVWs
    observations = cell2mat(bovw(gazed));
    
    % normalize observations to sum to 1, avoid division by zero
    % C = sum(observations, 2);
    % C(C==0) = eps;
    % samples{idx} = observations./repmat(C, 1, K);
    
    samples{idx} = observations;
    
    idx = idx + 1;
    
    % Count fixations to segments with not SIFT data
    % count = sum(observations, 2);
    % nosift = nosift + any(count==0);    
    
    % TEST: Show sift points over image segments
    % figure; imshow(labels==gazed(end))    
    % [sx,sy] = vl_grad(double(labels), 'type', 'forward') ;
    % bounds = labels;
    % bounds(sx|sy) = 0;
    % bounds(labels==gazed(end)) = 0;
    % figure; 
    % imshow(stimulus);
    % hold on
    % h1 = imshow(bounds);
    % set(h1,'AlphaData',0.35);
    % viscircles(f(1:2,:)', 1*ones(size(f,2), 1))    
    
end

fclose(FID);