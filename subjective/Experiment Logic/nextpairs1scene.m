function [pairs, neworder] = nextpairs1scene(order, vote)

% [pairs, order] = nextpairs1scene(order, vote)
%
% Gives next comparisons needed for a single scene.
% Here a scene is a set of similar images to be ranked.
%
% INPUTS:
%   order:      Vector containing consecutive integers starting with 1
%               where each refers to an image.  The previous ordering of
%               the images is given with the best image in the first entry,
%               and the worst image in the last.
%   vote:       Square matrix giving the result of previous comparisons.
%               The entry in vote(i,j) is the number of times image i
%               was vote over image j.
%
% OUTPUTS:
%   pairs:      Matrix of size (n x 2) where each row gives a pair of
%               images that should be compared by a user.
%   neworder:   Vector containing updated order of images reflecting any
%               switches implied by entries in vote.  Same format as
%               input variable 'order'


%% Make any needed swaps in order
neworder = order;

% done is binary and indicates whether another pass of possibly swapping
% adjacent pairs may be needed.  We need to keep making passes through
% until no swaps are performed in an entire pass through.
done = 0;
while ~done  % Keep making passes until no swaps are performed.
    done = 1;   % This is reset to 0 when a swap is performed.  
                % If not swaps are performed, another pass is not needed.
    for im1index = 1:(length(order)-1)
        im1 = neworder(im1index);      % image previously thought to be better
        im2 = neworder(im1index+1);    % image previously thought to be worse

        im1overim2 = vote(im1, im2);   % # times im1 vote over im2
        im2overim1 = vote(im2, im1);   % # times im2 vote over im1

        % Images have not been compared previously.  They will be compared.
        if im1overim2==0 & im2overim1==0            

        % Image 1 is better than image 2, no swap needed.
        elseif im1overim2 > im2overim1

        % Image 2 is better than image 1, swap them.
        elseif im1overim2 < im2overim1
                neworder(im1index) = im2;
                neworder(im1index+1) = im1;
                done = 0;   % Need to pass through again

        else    % Images were chosen equal number of non-0 times
            error('Images chosen same number of times.')
            % This should not happen.  Images should be compared an odd
            % number of times.
        end
    end
end

%% Check adjacent entries in neworder and see which need to be compared
pairs = zeros(0,2); %start with empty set of comparisons
for im1index = 1:(length(neworder)-1)
    im1 = neworder(im1index);      % image previously thought to be better
    im2 = neworder(im1index+1);    % image previously thought to be worse
    
    im1overim2 = vote(im1, im2);   % # times im1 vote over im2
    im2overim1 = vote(im2, im1);   % # times im2 vote over im1
    
    
    % Images have not been compared previously, compare them next
    if im1overim2==0 & im2overim1==0
        pairs(end+1,:) = [im1, im2];
        
    % Image 1 is better than image 2, no need to compare
    elseif im1overim2 > im2overim1
    
    
    % Image 2 is better than image 1
    elseif im1overim2 < im2overim1
        error('Image with low ranking was previously voted over higher ranking image.')
        % This should never happen because once compared, the vote
        % image should have a higher ranking and never again be compared to
        % the non-vote image.
    
    else    % Images were chosen equal number of non-0 times
        error('Images chosen same number of times.')
        % This should not happen.  Images should be compared an odd
        % number of times.        
    end
end