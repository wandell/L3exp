
%% t_norm2xcorr
%
%  This helps to check and understand the indices we use when applying
%  norm2xcorr to find a matching block.
%
%  We read remote data.
%  We make a template from a block of the remote data itself
%  We then search for the best match of the template with the data
%  We show that the match is perfect, demonstrating that we have the
%  logic and indexing right.
%
% (BW) Copyright Stanford Vistasoft Team 2015.

%% Get the data
ieInit

% Remote data directory with Nikon 200 pictures
remoteD = 'http://scarlet.stanford.edu/validation/SCIEN/L3/nikond200';

%% Get a PGM file (raw data)

% Read the pgm into the variable raw
remoteF = 'PGM/DSC_0767.pgm';  % There are many
fname = fullfile(remoteD,remoteF);
[~,status] = urlwrite(fname,'rawFile.pgm');
if status, disp('Done.'); end
raw = imread('rawFile.pgm');

% Row and column size of the mosaic 
[r,c] = size(raw);

% Read the jpg into the variable jpg
remoteF = 'JPG/DSC_0767.JPG';
fname = fullfile(remoteD,remoteF);
[~,status] = urlwrite(fname,'jpgFile.jpg');
if status, disp('Done.'); end
jpg = imread('jpgFile.jpg');

%% Start with raw and then make a template
n = 128;
A = raw(rStart:(rStart+n),(cStart:(cStart+n)));

% Make the template - from raw with some offsets (s1 and s2).
% I tested with various values of s1 and s2 and template sizes
s1 = 17; s2 = 22;
template = A(s1:(s1+6),s2:(s2+6));

% template should be smaller than the A data matrix
cc = normxcorr2(template,A);
[max_cc, imax] = max(abs(cc(:)));
[ypeak, xpeak] = ind2sub(size(cc),imax(1));
corr_offset = [ (ypeak-size(template,1)) (xpeak-size(template,2)) ];
fprintf('Estimated offset row %i, col %i\n',corr_offset(1),corr_offset(2));

% Pull out the matching part of the A data matrix
rows = (corr_offset(1)+1):(corr_offset(1)+size(template,1));
cols = (corr_offset(2)+1):(corr_offset(2)+size(template,2));
chk = double(A(rows,cols));

% This should be all zeros
double(chk) - double(template)

%% END