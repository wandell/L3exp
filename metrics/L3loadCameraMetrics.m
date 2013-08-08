function [metrics,largeisgood] = L3loadCameraMetrics(cameras,metricnames)

% [metrics,largeisgood] = L3loadCameraMetrics(cameras,metricnames)
%
% For each camera, the specified metrics are loaded.
%
% INPUTS
% cameras:      cell array of cameras  (or a single camera)
% metricnames:  cell array of strings where each entry specifies a metric
%          Options include:  S-CIELAB_X, SSIM_X, Moire, MTF50, MCC, vSNR_X
%          where X is a number indicating the desired light level
% scaleflag:    binary saying whether to scale the metrics to 0 and 1 or not
%
% OUTPUT
% metrics:         2D array where metrics(i,j) is from camera{i} and
%               metricnames{j}
% largeisgood:  binary vector describing if for each metric a large value
%               is desirable

% If single camera is passed in, convert it to a cell array containing only
% that camera
if isstruct(cameras)
    tmp = cameras;  cameras=[];  cameras{1}=tmp;
end

if nargin<2
    error('metricnames is required')
end


%% Load metrics from camera
metrics = zeros(length(cameras), length(metricnames));
for cameranum=1:length(cameras)
    camera = cameras{cameranum};    
    
    % Following get over written on each camera iteration, but it is fine
    largeisgood = zeros(1,length(metricnames)); %indicates large metric score is good
    
    for metricnum=1:length(metricnames)
        metricname = metricnames{metricnum};
        breaklocation = strfind(metricname,'_');
        if ~isempty(breaklocation)

            % Selection of light level for certain metrics.  For full reference
            % metrics, this is the index of the desired light level from
            % cameraFullReference.m.
            luminancelevel = str2double(metricname((breaklocation(end)+1):end));
            metricname = ieParamFormat(metricname(1:(breaklocation(end)-1)));
        else
            metricname = ieParamFormat(metricname);
        end

        % Load each metric
        switch(metricname)
            case {'s-cielab'}   % deltaE  (S-CIELAB)       
                fullReference = cameraGet(camera, 'metrics', 'Full Reference');
                metricvalue = fullReference.scielab(luminancelevel);
                largeisgood(metricnum) = 0;  %small is good for this metric
                
            case {'ssim'}       % MSSIM
                fullReference = cameraGet(camera, 'metrics', 'Full Reference');
                metricvalue = fullReference.ssim(luminancelevel);  
                largeisgood(metricnum) = 1;  %large is good for this metric

            case {'moire'}      % Moire starting point             
                moire = cameraGet(camera, 'metrics', 'Moire');
                metricvalue = moire.cpd_mean;  
                largeisgood(metricnum) = 1;  %large is good for this metric
                
            case {'mtf50'}       %MTF 50         
                slantedEdge = cameraGet(camera, 'metrics', 'Slanted Edge');
                metricvalue = slantedEdge.mtf50;
                largeisgood(metricnum) = 1;  %large is good for this metric
                
            case {'mcc'}        % deltaE for Macbeth color checker
                MCCcolor = cameraGet(camera, 'metrics', 'MCC color');
                metricvalue = mean(MCCcolor.deltaE);  
                largeisgood(metricnum) = 0;  %small is good for this metric

            case {'vsnr'}       % noise in uniform area   
                vSNR = cameraGet(camera, 'metrics', 'vSNR');
                metricvalue = vSNR.vSNR(luminancelevel);
                largeisgood(metricnum) = 1;  %large is good for this metric                
                
            otherwise
                error('Unknown %s\n',metricname);
        end
        metrics(cameranum,metricnum) = metricvalue;
    end
end
    