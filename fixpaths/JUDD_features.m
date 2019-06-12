require('segmentation')
require('sift')
load('MIT1000_fix')                           % trials matrix
stimuli = MIT1000_constants('stimuli');       % path to stimulus images

% Dataset image names
image_names = {trials(:,1).imgname};
n_images = numel(image_names);

% Store SIFT descriptors
descs = cell(n_images, 1);

for i = 1:n_images
    
    imname = image_names{i};    
    impath = fullfile(stimuli, [imname '.jpeg']);    
    img = imread(impath);

    % Use if images are were not fitted to match stimulus size during data 
    % collection (see plot_NUSEF_fix_data.m)
    % img = fit_img_size(img);
    
    % extract SIFT features
    grey  = single(rgb2gray(img));
    [f, d] = vl_sift(grey);    
    descs{i} = d;
end

features = cell2mat(descs');