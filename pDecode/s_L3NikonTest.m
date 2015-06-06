%% s_L3NikonTest
%  This script test whether nikon camera image processing pipeline can be
%  well approximated by a bunch of local linear transforms
%
%  HJ/BW/JEF, 2015

%% Pre-processing images
% Init parameters
cfa = [2 1; 3 4]; % Bayer pattern, 2 and 4 are both for green
patch_sz = 5; % patch size, usually use odd integers
pad_sz = (patch_sz - 1) / 2;
n_lum_levels = 10;


% Load images
imgDir = 'http://scarlet.stanford.edu/validation/SCIEN/L3/nikond200';
I_raw = imread(fullfile(imgDir, 'PGM', 'DSC_0767.pgm')); % raw image
I_raw = im2double(I_raw);

I_jpg = imread(fullfile(imgDir, 'JPG', 'DSC_0767.JPG')); % jpeg image
I_jpg = im2double(I_jpg);

% adjust size
% raw image size is larger than jpeg by 24 pixels in height and 28 pixels 
% in width
[I_jpg, r, c] = RGB2XWFormat(I_jpg);
I_raw = imcrop(I_raw, [(size(I_raw)-[r, c])/2-pad_sz, [c, r]+pad_sz+1]);

% image patch to columns in matrix
I_raw = im2col(I_raw, [patch_sz patch_sz], 'sliding');

%% Classify
%  the patches are first classified by their center pixel color
[ind_x, ind_y] = meshgrid(1:c, 1:r);
ind_x = mod(ind_x, size(cfa, 1)); ind_x(ind_x == 0) = size(cfa, 1);
ind_y = mod(ind_y, size(cfa, 2)); ind_y(ind_y == 0) = size(cfa, 2);
patch_type = cfa(ind_x(:) + (ind_y(:)-1) * size(cfa, 2));

% classify for each class
beta = cell(n_lum_levels, numel(cfa));
I_rec = I_jpg;
for p_type = 1 : numel(cfa)
    % get data for current type
    X = I_raw(:, patch_type == cfa(p_type))';
    X = padarray(X, [0 1], 1, 'pre'); % pad for intercept term
    Y = I_jpg(patch_type == cfa(p_type), :);
    Y_rec = Y;
    
    % regression for different luminance region
    p = linspace(0, 1, n_lum_levels+1);
    X_mean = mean(X, 2); % this is not right, should be changed
    lum_levels = quantile(X_mean, p);
    
    fprintf('p_type:%d\n', p_type);
    for l_type = 1 : n_lum_levels
        fprintf('\tl_type:%d\n', l_type);
        indx = X_mean > lum_levels(l_type) & X_mean < lum_levels(l_type+1);
        beta{l_type, p_type} = lscov(X(indx, :), Y(indx, :));
        Y_rec(indx, :) = X(indx, :) * beta{l_type, p_type};
    end
    I_rec(patch_type == cfa(p_type), :) = Y_rec;
end

vcNewGraphWin([], 'wide');
subplot(1,2,1); imshow(XW2RGBFormat(I_jpg, r, c));
subplot(1,2,2); imshow(XW2RGBFormat(I_rec, r, c));

%% Evaluate


%% Predict
I_raw = imread(fullfile(imgDir, 'PGM', 'DSC_0768.pgm')); % raw image
I_raw = im2double(I_raw);

I_jpg = imread(fullfile(imgDir, 'JPG', 'DSC_0768.JPG')); % jpeg image
I_jpg = im2double(I_jpg);

I_raw = imcrop(I_raw, [(size(I_raw)-[r, c])/2-pad_sz, [c, r]+pad_sz+1]);

% image patch to columns in matrix
[I_jpg, r, c] = RGB2XWFormat(I_jpg);
I_raw = im2col(I_raw, [patch_sz patch_sz], 'sliding');

for p_type = 1 : numel(cfa)
    % get data for current type
    X = I_raw(:, patch_type == cfa(p_type))';
    X = padarray(X, [0 1], 1, 'pre'); % pad for intercept term

    % regression for different luminance region
    X_mean = mean(X, 2); % this is not right, should be changed
    
    fprintf('p_type:%d\n', p_type);
    for l_type = 1 : n_lum_levels
        fprintf('\tl_type:%d\n', l_type);
        indx = X_mean > lum_levels(l_type) & X_mean < lum_levels(l_type+1);
        Y_rec(indx, :) = X(indx, :) * beta{l_type, p_type};
    end
    I_rec(patch_type == cfa(p_type), :) = Y_rec;
end

vcNewGraphWin([], 'wide');
subplot(1,2,1); imshow(XW2RGBFormat(I_jpg, r, c));
subplot(1,2,2); imshow(XW2RGBFormat(I_rec, r, c));