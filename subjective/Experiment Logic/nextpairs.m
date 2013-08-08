function [pairs, orders] = nextpairs(orders, votes)

% [pairs, orders] = nextpairs(orders, votes)
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

%% Add any more pairs that may be needed for current scene

% Find scene that is the last one to have a positive number of votes.
% Current scene is the scene that was last voted on.
currentscene = 1;
numscenes = length(orders);
while (currentscene < numscenes) & (sum(sum(votes{currentscene+1})) > 0)
    % logical on right of above line is true if next scene has some votes
    currentscene = currentscene + 1;
end

pairs = [];
order = orders{currentscene};
vote = votes{currentscene};

if sum(vote(:)) == 0    % No votes cast for this scene
    % This only happens if this is the very beginning of the experiment (no
    % votes cast for any scene).
    % Setup for first run by comparing adjacent entries in order
    pairs1scene = [order(1:end-1)', order(2:end)'];
else
    % Add any more pairs that are needed for current scene
    [pairs1scene, orders{currentscene}] = nextpairs1scene(order, vote);
    
    numpairs = size(pairs1scene,1);
    if numpairs == 0 & (currentscene < numscenes)  
        % Current scene is complete, move on to next one
        currentscene = currentscene + 1;
        order = orders{currentscene};
        vote = votes{currentscene};
        % Setup for first run on this scene by comparing adjacent entries
        % in order
        pairs1scene = [order(1:end-1)', order(2:end)'];
    end
end

% Place into pairs structure by adding current scene in 1st column
numpairs = size(pairs1scene,1);
pairs(1:numpairs, 1) = currentscene;
pairs(1:numpairs, [2,3]) = pairs1scene;

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