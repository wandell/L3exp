%% s_L3Plot2Metrics
%
% Loads 2 metrics for different CFAs and plots data.
%
% (c) Stanford VISTA Team


%% File locations
% Metrics will be calculated or loaded for all of the .mat files in the
% following directory which should all contain one camera.
cameraFiles=[];
cameraFiles{1} = dir(fullfile(L3rootpath,'Cameras','L3_1strun','*.mat'));
cameraFiles{2} = dir(fullfile(L3rootpath,'Cameras','global_1strun','*.mat'));
cameraFiles{3} = dir(fullfile(L3rootpath,'Cameras','basic_1strun','*.mat'));

foldernames = {'L3','Global','ISET default'};   %used for legend
markers = {'or','kx','gs'}; %used to plot the point for each of the above folders

%% Name of metrics
% Specify which metric values should be plotted on each axis. 
% Options include:  S-CIELAB_X, SSIM_X, Moire, MTF50, MCC, vSNR_X
%   where X is a number indicating the desired light level

metricnames = cell(1,2);
metricnames{1} = 'S-CIELAB_1';   %horizontal axis
metricnames{2} = 'S-CIELAB_8';      %vertical axis

%% Check that each folder contains the same number of files.
% Only the number is checked here.  It is assumed that folders contain
% similar files in the same order (for example each folder has a camera for
% the exact same set of CFAs)
for cameraFoldernum=1:length(cameraFiles)    
    if cameraFoldernum>1 && length(cameraFiles{1}) ~= length(cameraFiles{cameraFoldernum})
        error('Number of files in each folder do not match.')
    end
end

%% Load each camera and calculate or load metrics

% Following is the data to plot.  Top row is data for horizontal axis.
data = zeros(2,length(cameraFiles{1}));
cfanames = cell(1,length(cameraFiles{1}));
figure
hold on
for cameraFilenum = 1:length(cameraFiles{1})
    cameras = cell(1,length(cameraFiles));
    for foldernum = 1:length(cameraFiles)
        cameraFile = cameraFiles{foldernum}(cameraFilenum).name;

        tmp = load(cameraFile);
        if isfield(tmp, 'camera')
            cameras{foldernum} = tmp.camera;
        else
            error('No camera found in file.')
        end   
    end

    metrics = L3loadCameraMetrics(cameras,metricnames);

%% Make plot
    for foldernum = 1:length(cameraFiles)
        marker = markers{foldernum};
        plot(metrics(foldernum,1),metrics(foldernum,2), marker)
    end
    plot(metrics(:,1), metrics(:,2), '-')

    % Get name of CFA from camera file name.
    underscorelocation = strfind(cameraFile,'_');    
    cfaName = cameraFile((underscorelocation(end)+1):end-4);         
        %cut off something like 'L3camera_' at beginning and '.mat' at end 
    
    text(metrics(1,1), metrics(1,2), cfaName)
end
grid on
xlabel(metricnames{1})
ylabel(metricnames{2})
legend(foldernames)