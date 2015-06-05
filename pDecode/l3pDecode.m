%% L3 analysis for decoding camera pipeline (l3pDecode)
%
% First part aligns the RAW NEF data with the JPEG data from the Nikon
% camera.
% Second part sets up linear transforms from similar NEF data regions to
% the Nikon JPEG RGB values
%
% BW, Copyright Vistasoft Team, 2015

%% 
ieInit

% Remote data directory with Nikon 200 pictures
remoteD = 'http://scarlet.stanford.edu/validation/SCIEN/L3/nikond200';

%% We figured out the array from dcraw and stored information remotely

% These are the settings of the camera when JEF took the picture.
remoteF    = 'NikonD200.txt';  % There are many
fname      = fullfile(remoteD,remoteF);
[~,status] = urlwrite(fname,remoteF);
if status, disp('Done.'); end
type(remoteF)

% Perhaps we should make a camera = cameraCreate('NikonD200') and set the
% other parameters.

%% Get a PGM and corresponding JPG file

% Read the pgm into the variable raw
remoteF = 'PGM/DSC_0767.pgm';  % There are many
fname = fullfile(remoteD,remoteF);
[~,status] = urlwrite(fname,'rawFile.pgm');
if status, disp('Done.'); end
raw = imread('rawFile.pgm');

% Read the jpg into the variable jpg
remoteF = 'JPG/DSC_0767.JPG';
fname = fullfile(remoteD,remoteF);
[~,status] = urlwrite(fname,'jpgFile.jpg');
if status, disp('Done.'); end
jpg = imread('jpgFile.jpg');

vcNewGraphWin; imagesc(jpg); axis on; axis image

% Warning: 0803 needs a rotate
% jpg = imrotate(jpg,90);

%%  Let's work with a small part, not the whole giant image

rStart = 1500; cStart = 300; n = 511; channel = 1;
rect = [cStart, rStart, n, n];
sjpg = imcrop(jpg(:,:,channel),rect);
sraw = imcrop(raw,rect);
vcNewGraphWin; imagesc(sjpg), axis image; colormap(gray), title('JPEG')
vcNewGraphWin; imagesc(sraw), axis image; colormap(gray), title('RAW')

%%  Now, find the offset between the raw and jpg
% We find the offset using normxcorr2.
% See the tutorial t_normxcorr2

nT = 64;  % Template should be smaller than A
nA = 2*nT;
template = jpg(rStart:(rStart+nT-1),(cStart:(cStart+nT-1)),3);
A        = raw(rStart:(rStart+nA-1),(cStart:(cStart+nA-1)));
cc       = normxcorr2(template,A);

% Find the position of the peak cross-correlation
[max_cc, imax] = max(abs(cc(:)));
[ypeak, xpeak] = ind2sub(size(cc),imax(1));
corr_offset = [ (ypeak-size(template,1)) (xpeak-size(template,2)) ];

% Tell the user
fprintf('Estimated offset row %i, col %i\n',corr_offset(1),corr_offset(2));

%% Pull out the section of the A data matrix that matches the jpg data

% The matching part of the raw data matrix
rows = (corr_offset(1)+1):n;
cols = (corr_offset(2)+1):n;
tmpRaw = double(sraw(rows,cols)); 
tmpRaw = tmpRaw/mean(tmpRaw(:));

% Pull out the matching part of jpg
tmpJPG = double(sjpg(1:size(tmpRaw,1),1:size(tmpRaw,2)));
tmpJPG = tmpJPG/mean(tmpJPG(:));

% vcNewGraphWin; imagesc(template); colormap(gray); title('template')
% vcNewGraphWin; imagesc(tmpRaw);   colormap(gray); title('Raw')

% vcNewGraphWin; plot(tmpJPG(:),tmpRaw(:),'.'); grid on; axis equal
% identityLine;
% 
tst = zeros(size(tmpJPG,1),size(tmpJPG,2),3);
tst(:,:,1) = ieScale(tmpRaw,1);
tst(:,:,2) = ieScale(tmpJPG(:,:,channel),1);
vcNewGraphWin; imagesc(tst);

%% At this point, the jpg and raw data should be aligned.


%% END