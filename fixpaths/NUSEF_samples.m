require('segmentation')
require('sift')
load('NUSEF_fix')                           % trials matrix
stimuli = NUSEF_constants('stimuli');       % path to stimulus images

nregs = SIFTSE_1.constants('nregions');
nwords = SIFTSE_1.constants('nwords');

% make dict with K visual words
[thisdir, ~, ~] = fileparts(mfilename('fullpath'));
load(fullfile(thisdir, '_NUSEF_features.mat'));
[dict, ~] = vl_kmeans(double(features), nwords);

n_imgs = size(trials, 1);
n_subs = size(trials, 2);
samples(n_imgs, n_subs).imgname = [];
samples(n_imgs, n_subs).fixdata = [];

idx = 1;

for i = 1:n_imgs

    imtrials = get_imtrials(trials, i);    
    [ctg, name, ext] = fileparts(get_image_name(imtrials));
    fprintf('image: %s\n', name);        
    img = imread(fullfile(stimuli, ctg, [name, ext]));    
    
    % Use if images are were not fitted to match stimulus size during data 
    % collection (see plot_NUSEF_fix_data.m)
    % img = fit_img_size(img);
    
    % Segment image into regions and represent them as BoVWs
    regions = mex_ers(double(img), nregs) + 1;                       
    [f, bovws] = SIFTSE_1.reg2bovw(img, regions, dict);
    
    % TEST: Show sift points over image regions
    % test_siftOverRegions
    
    for j = 1:numel(imtrials)
        
        if j==1
            samples(i,j).imgname = fullfile(ctg, [name ext]);
            samples(i,j).regions = regions;
            samples(i,j).bovws = bovws;
        end
        
        % Get BoVW rep. of fixated regions        
        [col, row, ~] = get_fix_data(imtrials(j));
        if numel(col) < 2
            continue;
        end        
        samples(i,j).fixdata = sub2ind(size(regions), row, col);
        
        idx = idx + 1;
    end
    
end