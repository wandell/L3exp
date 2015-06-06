function p = patchExtract(imgMosaic,centers,sz)
% Extract patches of sz from many center locations
%
% p = prod(sz) by nCenters matrix.  Each one is the local patch data
%

if length(sz) == 1, sz(1:2) = sz; end
nCenters = size(centers,1);

h = floor(sz(1)/2); rows = -h:h; 
h = floor(sz(2)/2); cols = -h:h; 

% Faster way to do this maybe?
p = zeros(prod(sz),nCenters);
for ii=1:nCenters
    tmp = imgMosaic(rows + centers(ii,1),cols + centers(ii,2));
    p(:,ii) = tmp(:);
end


end
