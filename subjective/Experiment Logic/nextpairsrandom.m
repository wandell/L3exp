function [pairs, orders] = nextpairsrandom(orders, votes)

% [pairs, orders] = nextpairsrandom(orders, votes)
%
% Gives next comparisons needed for pairwise subjective test & bubble sort
% All scenes appear in a random order with this function (see nextpairs.m)
% for all images of a scene to appear grouped together.
%
% INPUTS:
%   orders:     Cell array where each cell is for a scene.  Each cell
%               contains a vector where each entry refers to an image of
%               that scene.  The ordering of the images is given
%               with the best image in the first entry, and the worst image
%               in the last.
%   votes:      Cell array where each cell is for a scene.  Each cell
%               contains a square matrix giving the result of previous
%               comparisons. The entry in (i,j) is the number of times
%               image i was vote over image j.
%
% OUTPUTS:
%   pairs:      Matrix of size (n x 3) where each row gives a pair of
%               images that should be compared by a user.  Columns give the
%               following information:
%                   Column 1:  number of the scene
%                   Column 2:  image to show on left
%                   Column 3:  image to show on right
%   orders:     Updated order of images reflecting any switches implied by
%               entries in vote.  Same format as input variable 'orders'


%% Parameter
% Maybe this parameter should be passed in instead of being coded here?

% Number of times each pair of images need to be compared.  The ranking
% will be based on a majority vote with the following number of comparisons
% being made.  For this reason, the following number must be odd.
numrepetitions = 3;

%% For each scene, find what pairs need to be compared next
numscenes = length(orders);
pairs = [];
for scene = 1:numscenes
    order = orders{scene};
    vote = votes{scene};
    
    if sum(vote(:)) == 0    % No votes cast yet
        % Setup for first run by comparing adjacent entries in order
        pairs1scene = [order(1:end-1)', order(2:end)'];
    else
        [pairs1scene, orders{scene}] = nextpairs1scene(order, vote);
    end
    
    numpairs = size(pairs1scene,1);
    newrows = size(pairs,1)+(1:numpairs);
    
    pairs(newrows,1) = scene;
    pairs(newrows,[2,3]) = pairs1scene;    
end

%% Replicate pairs
% Copy each pair so that it will be compared the desired number of times.
pairs = repmat(pairs, numrepetitions, 1);

%% Randomly rearrange order of pairs
% Currently images go in order of scene (and from best to worst in each
% scene).  But we want the pairs of images to come in random order.
numpairs = size(pairs,1);

permutation = randperm(numpairs);
pairs = pairs(permutation,:);

%% Randomly swap which image is displayed on left/right
% Currently the image that is believed to be better is on the left.  We
% want to randomly switch these.

swap = (rand(1, numpairs) > .5);
pairs(swap, [2,3]) = pairs(swap, [3,2]);