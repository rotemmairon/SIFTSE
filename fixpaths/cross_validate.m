dataset = 'NUSEF';
subset  = [];
[thisdir, ~, ~] = fileparts(mfilename('fullpath'));
output_data_dir = fullfile(thisdir, 'data');
load(fullfile(output_data_dir, ['_' dataset '_samples.mat']));

% filter portrait / face images
if ~isempty(subset)
    imnames = cellfun(@(x)tiltsep(x), {samples(:,1).imgname}, 'un', 0);
    imidxs = cellfun(@(x)strcmp(fileparts(x), subset), imnames);
    samples = samples(imidxs,:);
end

K = SIFTSE_1.constants('nwords');       % number of visual words
M = SIFTSE_1.constants('nstates');      % number of hmm states
folds = [10];                          % validation folds
scores = cell(numel(folds), 1);

for i = 1:numel(folds)
    
    fprintf('%d-folds:\n', folds(i));    
    cv = cvpartition(size(samples, 1), 'KFold', folds(i));
    
    for j = 1:cv.NumTestSets

        % train hmm model
        train_samples =  get_train_samples(samples(cv.training(j), :));
        fprintf('Training...\n');
        TR = hmm_normalize(rand(M,M),2);
        E  = hmm_normalize(rand(M,K),2);
        PI = hmm_normalize(rand(M,1),1);        
        [TR, E, PI] = SIFTSE_1.hmm_em(TR, E, PI, train_samples);
        
        figure();
        subplot(121); imagesc(TR)
        subplot(122); imagesc(E)
        mkdir(fullfile(output_data_dir, ['hmm_figs' '_' dataset subset]));
        savefig(fullfile(output_data_dir, ['hmm_figs' '_' dataset subset], num2str(j)));
        close(gcf);
        
        % test hmm model
        test_samples = samples(cv.test(j), :);
        score = test_model(TR, E, PI, test_samples);
        scores{i} = [scores{i}, score];
        
        display(scores{i});
    end
end
save(fullfile(output_data_dir, ['_' dataset subset '_scores.mat']), 'scores');


function out = get_train_samples(samples)
    N = size(samples, 1);
    out = cell(N, 1);
    for i = 1:N
        imtrials = get_imtrials(samples, i);        
        regions = imtrials(1).regions;
        bovws = imtrials(1).bovws;
        out{i} = arrayfun(@(x) cell2mat(bovws(regions(x.fixdata))),...
            imtrials, 'un', 0);
    end
    out = cat(2, out{:})';
    out = out(cellfun(@(x)~isempty(x), out));
end


function score = test_model(TR, E, PI, samples)

    pathlen = SIFTSE_1.constants('pathlen');
    n_imgs = size(samples, 1);
    score = 0;
    count = 0;

    for i = 1:n_imgs

        % Make a scanpath prediction
        imtrials = get_imtrials(samples, i);
        regions = imtrials(1).regions;
        bovws = imtrials(1).bovws;
        p = SIFTSE_1.makepath(TR, E, PI, bovws, pathlen);        

        % imshow(random_color(double(stimulus), regions, SIFTSE_1.constants('regnum')));    

        % Get a random location at each region  
        stats = struct2cell(regionprops(regions, 'PixelList'))';
        regxy = cell2mat(cellfun(@(x)x(randi(size(x, 1)),:), stats, 'un', 0));

        % compare ground truth with generated path
        for j = 1:numel(imtrials)
            g = regions(imtrials(j).fixdata);
            score = score + seqcmp(regxy(p,:), regxy(g,:), 'swalign');
            count = count + 1;        
        end
        % test_predScanpathVSGroundtruth    
    end
    score = score/count;
end
