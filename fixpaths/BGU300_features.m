stimuli = BGU300_constants('stimuli');                                      % image dataset

datadir = fullfile(drive, 'Datasets\Gaze_Shifting\BGU_300');                % train data
fixpaths = fullfile(datadir, 'fixpaths_train.csv');

tools = fullfile(drive, 'workspace\Tools');                                 % Image Segmentation
addpath(genpath(fullfile(tools, '\segmentaion\EntropyRateSuperpixel')));    

addpath(genpath(fullfile(tools, '\vlfeat-0.9.21')));                        % SIFT and K-means
vl_setup

% Dataset image names
load('BGU300_names');

% Extract image idxs
idxs = SIFTSE_1.extract_image_idxs(fixpaths);

% Stores SIFT descriptors
descs = cell(numel(idxs), 1);

for i = 1:numel(idxs)
    
    imname = image_names{idxs(i)};
    
    impath = fullfile(stimuli, imname);
    
    grey = single(rgb2gray(imread(impath)));
    
    [f, d] = vl_sift(grey);
    
    descs{i} = d;
end

features = cell2mat(descs');