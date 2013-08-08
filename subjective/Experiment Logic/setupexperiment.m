function [pairs, orders, votes] = setupexperiment(orders)

% [pairs, orders, votes] = setupexperiment(orders)
%
% Initialize variables for pair-wise preference experiment
%
% INPUTS:
%   orders:     Cell array where each cell is for a scene.  Each cell
%               contains a vector where each entry refers to an image of
%               that scene.  The ordering of the images is given
%               with the best image in the first entry, and the worst image
%               in the last.  The ranking is an initial guess that will be
%               modified through the experiment.
%               (Here scene means a set of similar images that should be
%               ranked.  There may be any number of such sets of images.)
%
% OUTPUTS:
%   pairs, orders, votes:  Keeps track of data in the experiment.  See
%                          submitvote.m for details.
%
%
% General workflow for a subjective test is following:
%      [pairs, orders, votes] = setupexperiment(orders)
%       while ~isempty(pairs)
%           scenenum = pairs(1,1);
%           imleft = pairs(1,2);   imright = pairs(1,3);
%           % show imleft and imright and store preference
%           [pairs, orders, votes] = ...
%             submitvote(preference, pairs, orders, votes)
%       end


%% Initalize votes data with all 0's
numscenes = length(orders);
votes = cell(1,numscenes);
for scene = 1:numscenes
    numimages = length(orders{scene});  %number of images in current scene
    votes{scene} = zeros(numimages);
end

%% Find list of pairs of images that need to be compared
pairs = nextpairs(orders, votes);
