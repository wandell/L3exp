%% L3 analysis for decoding camera pipeline
%

%% 
ieInit

%% Try it in the dcraw utility directory
remoteD = 'http://scarlet.stanford.edu/validation/SCIEN/L3/nikond200';


%% We need to figure out the array from dcraw and store it remotely
%  Then we should get the camera information here.

%% Get the PGM file (raw data)

% There are many potential files.  Here is one.
remoteF = 'PGM/DSC_0767.pgm';
fname = fullfile(remoteD,remoteF);
[~,status] = urlwrite(fname,'rawFile.pgm');
if status, disp('Done.'); end

raw = imread('rawFile.pgm');

% Row and column size of the mosaic 
[r,c] = size(raw);

% vcNewGraphWin; imagesc(raw); 
% colormap(gray(1024)); axis image
% vcNewGraphWin; hist(single(raw(:)),100)

%% Now get the corresponding JPG data

% Corresponding JPG files
remoteF = 'JPG/DSC_0767.JPG';
fname = fullfile(remoteD,remoteF);
[~,status] = urlwrite(fname,'jpgFile.jpg');
if status, disp('Done.'); end

jpg = imread('jpgFile.jpg');

% 0803 needs a rotate
% jpg = imrotate(jpg,90);

% vcNewGraphWin; imagesc(jpg); 
% colormap(gray(1024)); axis image

%% Go to a red pixel in the middle, assuming red is 1:3:end
%  Pull out the 5x5 patch around that pixel
%  Pull out the R,G,B values in the jpeg at that pixel
%  Have a look

rowRed = [1:2:r];
colRed = [1:2:c];

[X,Y] =  meshgrid(rowRed,colRed);
Red = [X(:), Y(:)];

rr = rowRed(1000);
cc = colRed(1000);
[X,Y] = meshgrid(((rr - 2):(rr + 2)),((cc - 2): (cc + 2)));
patch = [X(:),Y(:)];
[jr,jc,w] =  size(jpg)

% These aren't the same.  So, I have to find the shift/offset
r - jr
c - jc

rStart = 1500;
cStart = 500;
n = 256;
sjpg = jpg(rStart:(rStart+n),(cStart:(cStart+n)),2);
sraw = raw(rStart:(rStart+n),(cStart:(cStart+n)));
vcNewGraphWin; imagesc(sjpg), axis image; colormap(gray), title('JPEG')
vcNewGraphWin; imagesc(sraw), axis image; colormap(gray), title('RAW')




%% END