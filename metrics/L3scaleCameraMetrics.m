function metrics = L3scaleCameraMetrics(metrics,largeisgood)

% metrics = L3scaleCameraMetrics(metrics,largeisgood)
%
% Metric values are scaled to be between 0 and 1 with 1 being a good value.
%  The scaling is based on the passed in data so the best camera gets a
%  score of 1 and the worst gets a score of 0.
%
% Scaled data can later be plotted by plotMetricsPolar.
%
% INPUTS
% metrics:      2D array where metrics(i,j) is from camera i and
%               metric j
% largeisgood:  binary vector describing if for each metric a large value
%               is desirable
%
% See L3loadCameraMetrics

if nargin<2
    error('Not all required inputs entered.')
end

for metricnum=1:size(metrics,2)
    metricmax = max(metrics(:,metricnum));
    metricmin = min(metrics(:,metricnum));        
    if largeisgood(metricnum)   %large is good for this metric
        metrics(:,metricnum) = (metrics(:,metricnum)-metricmin)...
                            /(metricmax-metricmin); 
    else    %small is good for this metric
        metrics(:,metricnum) = (metricmax-metrics(:,metricnum))...
                            /(metricmax-metricmin);
    end
end