%% s_L3CameraMetrics
%
% Calculates and stores predefiend metrics for a series of stored cameras.
%
% (c) Stanford VISTA Team

s_initISET

%% File locations
% Metrics will be calculated for all of the .mat files in the following 
% directory which should all contain one camera.  The files will be
% overwritten with a file containing the camera structure with the
% additional metrics stored.

cameraFolder = fullfile(L3rootpath,'Cameras','L3_1strun');
% cameraFolder = fullfile(L3rootpath,'Cameras','global_1strun');
% cameraFolder = fullfile(L3rootpath,'Cameras','basic_1strun');


%% Metric names
% Following is a list of metrics that will be calculated and are
% implemented in metricsCamera.
% metricNames = {'SlantedEdge', 'MCCcolor', 'FullReference','Moire','vSNR'};
metricNames = {'FullReference'};

%% Load each camera and calculate metrics

cameraFiles = dir(fullfile(cameraFolder, '*.mat'));

for cameraFilenum = 1:length(cameraFiles)
    cameraFile = cameraFiles(cameraFilenum).name;
    disp(['Camera:  ', cameraFile, '  ', num2str(cameraFilenum),' / ', num2str(length(cameraFiles))])
    data = load(cameraFile);
    if isfield(data, 'camera')
        camera = data.camera;
    elseif isfield(data, 'L3camera')
        camera = data.L3camera;
    else
        error('No camera found in file.')
    end
    
    for metricNum = 1:length(metricNames)
        metricName = metricNames{metricNum};
        metric = cameraGet(camera, 'metric', metricName);
        camera = cameraSet(camera, 'metric', metric, metricName);
    end
          
    
    % Should I also try to save anything else that might be in data?
    % Should it be called L3camera sometimes?
    save(fullfile(cameraFolder, cameraFile), 'camera')
    
    close all
end
