%% s_L3PlotCircleCFAs
%
% Plots a circle diagram with a line for each CFA.
% This should be plotted for one type of camera such as L3.
%
% (c) Stanford VISTA Team


%% Metric selection  (for spokes of circle plot)
% Specify what camera metrics to plot.  Below metricnames is a cell array
% where each entry specifies a metric to plot on the spoke of a polar
% diagram.

metricnames = {'S-CIELAB_6', 'SSIM_6', 'Moire', 'MTF50', 'MCC', 'vSNR_6'};
% metricnames = {'S-CIELAB_1', 'S-CIELAB_2', 'S-CIELAB_3','S-CIELAB_4','S-CIELAB_5','S-CIELAB_6','S-CIELAB_7','S-CIELAB_8'};
% metricnames = {'SSIM_1', 'SSIM_2', 'SSIM_3','SSIM_4','SSIM_5','SSIM_6','SSIM_7','SSIM_8'};
% metricnames = {'vSNR_1', 'vSNR_2', 'vSNR_3','vSNR_4','vSNR_5','vSNR_6','vSNR_7','vSNR_8'};

% Options include:  S-CIELAB_X, SSIM_X, Moire, MTF50, MCC, vSNR_X
%   where X is a number indicating the desired light level

%% File locations
% Metrics will be calculated or loaded for all of the .mat files in the
% following directory which should all contain one camera.
cameraFolder = fullfile(L3rootpath,'Cameras','L3_1strun');
% cameraFolder = fullfile(L3rootpath,'Cameras','L3_1strun','Small Set');
% cameraFolder = fullfile(L3rootpath,'Cameras','global_1strun');
% cameraFolder = fullfile(L3rootpath,'Cameras','basic_1strun');

colors = {'r','g','b','c','m','y','k',...
          'r--','g--','b--','c--','m--','y--','k--',...
          'r:','g:','b:','c:','m:','y:','k:',...
          'r-.','g-.','b-.','c-.','m-.','y-.','k-.'};
      %each letter is a color to plot the above camera types
%% Load each camera and make plots
cameraFiles = dir(fullfile(cameraFolder, '*.mat'));
cfanames = cell(1,length(cameraFiles));
metrics = zeros(length(cameraFiles), length(metricnames));
for cameraFilenum = 1:length(cameraFiles)   
    cameraFile = cameraFiles(cameraFilenum).name;
    underscorelocation = strfind(cameraFile,'_');    
    cfanames{cameraFilenum} = cameraFile((underscorelocation(end)+1):end-4);         
        %cut off something like 'L3camera_' at beginning and '.mat' at end   

    tmp = load(cameraFile);
    camera = tmp.camera;   

    [metrics(cameraFilenum,:), largeisgood] = L3loadCameraMetrics(camera,metricnames);
end

%% Scale data
% metricsscaled = L3scaleCameraMetrics(metrics,largeisgood);

% Instead of the automatic scaling done above that independently scales
% each metric.  Sometimes it might be better to scale all the same way.
                        
metricmax = 9;
metricmin = 0;

if largeisgood(1)  %large is good for this metric
    metricsscaled = (metrics-metricmin)/(metricmax-metricmin); 
else
    %small is good for this metric
    metricsscaled = (metricmax-metrics)/(metricmax-metricmin);
end

%% Plot data
figure
for cameraFilenum = 1:length(cameraFiles)
    if cameraFilenum>1
        hold on        %enables 1st drawn plot to remain
    end
    color = colors{cameraFilenum};
    plotMetricsPolar(metricsscaled(cameraFilenum,:), metricnames, color);     
end
legend(cfanames)