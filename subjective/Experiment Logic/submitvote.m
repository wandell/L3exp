function [pairs, orders, votes] = ...
    submitvote(preference, pairs, orders, votes)

% [pairs, orders, votes] = submitvote(preference, pairs, orders, votes)
%
% Enters pair-wise preference and returns with next pair of images to show
%
% INPUTS:
%   preference: Scalar describing preferred image from top row in pairs.
%               1 = left image,  2 = right image
%   pairs:      Matrix of size (n x 2) where each row gives a pair of
%               images that should be compared by a user.  This is the to
%               do list.
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
%   scenenum:   Scalar giving the number of the scene to next be compared
%   im1:        Scalar giving the image to show on the left
%   im2:        Scalar giving the image to show on the right
%   pairs, orders, votes:  Same format as input except sometimes updated.
%
%
% General workflow for a subjective test is following:
%      [pairs, orders, votes] = setupexperiment(orders);
%       while ~isempty(pairs)
%           scenenum = pairs(1,1);
%           imleft = pairs(1,2);   imright = pairs(1,3);
%           % show imleft and imright and store preference
%           [pairs, orders, votes] = ...
%             submitvote(preference, pairs, orders, votes);
%       end
%
% Example for GUI:
% Initialization:   
%   [pairs, orders, votes] = setupexperiment(orders);
%   scenenum = pairs(1,1);
%   imleft = pairs(1,2);   imright = pairs(1,3);
%   % show imleft and imright
%
% After user clicks:
%   % based on what they clicked store in preference
%   [pairs, orders, votes] = submitvote(preference, pairs, orders, votes);

%   if isempty(pairs)
%       % study is over, give message to user, save results
%   else
%        scenenum = pairs(1,1);
%        imleft = pairs(1,2);   imright = pairs(1,3);
%        % show imleft and imright
%   end


% General operation of this code:
% 1.  Record last vote and remove completed pair.
% 2.  If there are more pairs on the current list, proceed with those 
%       without adding more pairs or updating orders.
% 3.  If current list of pairs is empty, update orders and add any newly
%       needed pairs.

%% Record last vote and remove completed pair
scene = pairs(1,1);     imleft = pairs(1,2);   imright = pairs(1,3);
switch preference
    case 1      %left image preferred
        votes{scene}(imleft, imright) = votes{scene}(imleft, imright) + 1;
    case 2      %right image preferred
        votes{scene}(imright, imleft) = votes{scene}(imright, imleft) + 1;        
    otherwise
        error('Preference needs to be 1 or 2.')
end
pairs(1,:) = [];    %remove completed pair

%% If needed, update orders and add any newly needed pairs

if isempty(pairs)
    [pairs, orders] = nextpairs(orders, votes);
end
