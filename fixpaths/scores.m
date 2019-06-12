[thisdir, ~, ~] = fileparts(mfilename('fullpath'));
datadir = fullfile(thisdir, 'data');

S = containers.Map();
load(fullfile(datadir, '_NUSEFface_scores.mat'));   S('face') = scores{1};
load(fullfile(datadir, '_NUSEFport_scores.mat'));   S('portrait') = scores{1};
load(fullfile(datadir, '_NUSEF_scores.mat'));       S('NUSEF') = scores{1};
load(fullfile(datadir, '_JUDD_scores.mat'));        S('JUDD') = scores{1};
clear scores;

keys = {'face' 'portrait' 'NUSEF' 'JUDD'};
n_keys = numel(keys);
[avg_, var_, std_, err_] = deal(zeros(1, n_keys));

for i = 1:n_keys
    scores = S(keys{i});
    avg_(i) = mean(scores);
    var_(i) = var(scores);
    std_(i) = std(scores);
    err_(i) = std(scores)/sqrt(n_keys);
end 

x = 1:n_keys;
bar(avg_, .2, 'FaceColor', [255 207 0]./255)
ylim([0.5 1.5])
yticks([0.5:0.2:1.5]);
xticklabels(keys);
set(gca,'XTickLabel', keys, 'FontSize', 16)
ylabel('similarity')
hold on
er = errorbar(x, avg_, -err_, err_);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
hold off

