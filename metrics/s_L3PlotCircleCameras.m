%% s_L3PlotCircleCameras
%
% Plots circle diagram of camera types for a set of given CFAs.
% Figure contains a subplot for each different CFA type.  
% Each subplot has a line for each type of camera (such as L3).
%
% (c) Stanford VISTA Team


%% Metric selection (for spokes of circle plot)
% Specify what camera metrics to plot.  Below metricnames is a cell array
% where each entry specifies a metric to plot on the spoke of a polar
% diagram.

% metricnames = {'S-CIELAB_6', 'SSIM_6', 'Moire', 'MTF50', 'MCC', 'vSNR_6'};
metricnames = { 'vSNR_6'};
% metricnames = {'S-CIELAB_1', 'S-CIELAB_2', 'S-CIELAB_3','S-CIELAB_4','S-CIELAB_5','S-CIELAB_6','S-CIELAB_7','S-CIELAB_8'};
% metricnames = {'SSIM_1', 'SSIM_2', 'SSIM_3','SSIM_4','SSIM_5','SSIM_6','SSIM_7','SSIM_8'};
% metricnames = {'vSNR_1', 'vSNR_2', 'vSNR_3','vSNR_4','vSNR_5','vSNR_6','vSNR_7','vSNR_8'};

% Options include:  S-CIELAB_X, SSIM_X, Moire, MTF50, MCC, vSNR_X
%   where X is a number indicating the desired light level

%% File locations
% Metrics will be calculated or loaded for all of the .mat files in the
% following directory which should all contain one camera.
L3cameraFolder = fullfile(L3rootpath,'Cameras','L3_1strun');
globalcameraFolder = fullfile(L3rootpath,'Cameras','global_1strun');
basiccameraFolder = fullfile(L3rootpath,'Cameras','basic_1strun');

colors = 'rgbcmyk'; %each letter is a color to plot the above camera types
    
%% List camera files and remove unwanted CFAs
% list of CFA camera files to skip
% ignorecfas = {'HDRcolor','HDRgray'};
ignorecfas = {'HDRcolor','HDRgray','RGB1','RGB2','RGB3','RGB4','RGB5','RGB6',...
    'CMY1','CMY2','CMY3','CMY5','CMY6','CMY7','CMY8','RGBW1','RGBW2',...
    'RGBW3','RGBW4','RGBW5','RGBW6','RGBW7'};

L3cameraFiles = dir(fullfile(L3cameraFolder, '*.mat'));
globalcameraFiles = dir(fullfile(globalcameraFolder, '*.mat'));
basiccameraFiles = dir(fullfile(basiccameraFolder, '*.mat'));

ignore = [];   % will hold indices of files to ignore
for cameraFilenum = 1:length(L3cameraFiles)   
    L3cameraFile = L3cameraFiles(cameraFilenum).name;
    L3cfaname = L3cameraFile(10:end-4);         %cut off 'L3camera_' at beginning and '.mat' at end
    for ignorecfanum = 1:length(ignorecfas)
        ignorecfa = ignorecfas{ignorecfanum};
        if strcmpi(L3cfaname,ignorecfa)
            ignore(end+1) = cameraFilenum;
        end
    end
end

L3cameraFiles(ignore) = [];
globalcameraFiles(ignore) = [];
basiccameraFiles(ignore) = [];

%% Load each camera and make plots

metrics = zeros(3*length(L3cameraFiles), length(metricnames));
for cameraFilenum = 1:length(L3cameraFiles)
    L3cameraFile = L3cameraFiles(cameraFilenum).name;
    L3cfaname = L3cameraFile(10:end-4);         %cut off 'L3camera_' at beginning and '.mat' at end

    globalcameraFile = globalcameraFiles(cameraFilenum).name;
    globalcfaname = globalcameraFile(14:end-4);         %cut off 'globalcamera_' at beginning and '.mat' at end
    
    basiccameraFile = basiccameraFiles(cameraFilenum).name;            
    basiccfaname = basiccameraFile(13:end-4);    %cut off 'basiccamera_' at beginning and '.mat' at end

    if ~strcmp(L3cfaname,globalcfaname) || ~strcmp(L3cfaname,basiccfaname)
        error('CFAs do not appear to match between current pair of cameras')
    end
    

    tmp = load(L3cameraFile);
    L3camera = tmp.camera;   

    tmp = load(globalcameraFile);
    globalcamera = tmp.camera;
    
    tmp = load(basiccameraFile);
    basiccamera = tmp.camera;

    cameras = {L3camera, globalcamera, basiccamera};
    camerarange = 3*(cameraFilenum-1)+(1:3);
    [metrics(camerarange,:), largeisgood] = L3loadCameraMetrics(cameras,metricnames);
end

%% Scale data
% metrics = L3scaleCameraMetrics(metrics,largeisgood);

% Instead of the automatic scaling done above that independently scales
% each metric.  Sometimes it might be better to scale all the same way.
                        
% metricmax = 1;
% metricmin = 0;

%large is good for this metric
% metrics = (metrics-metricmin)/(metricmax-metricmin); 

%small is good for this metric
% metrics = (metricmax-metrics)/(metricmax-metricmin);

%% Plot data
figure
subplotcols = ceil(sqrt(length(L3cameraFiles)));
subplotrows = ceil(length(L3cameraFiles)/subplotcols);
for cameraFilenum = 1:length(L3cameraFiles)
    subplot(subplotrows,subplotcols,cameraFilenum);
    camerarange = 3*(cameraFilenum-1)+(1:3);
    for cameratype=1:3;        
        cameranum = camerarange(cameratype);
        color = colors(cameratype);
        if cameratype>1
            hold on        %enables 1st drawn plot to remain
        end
        plotMetricsPolar(metrics(cameranum,:), metricnames, color);
    end    
    
    L3cameraFile = L3cameraFiles(cameraFilenum).name;
    L3cfaname = L3cameraFile(10:end-4);         %cut off 'L3camera_' at beginning and '.mat' at end
    title(L3cfaname)
end
legend('L3','Global Linear','Bilinear')