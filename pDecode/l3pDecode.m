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

% I think the row offset is 12.
% I am not sure if the col offset is 14 or 15

%%
rStart = 1500;
cStart = 600;
n = 128;
channel = 1;
sjpg = jpg(rStart:(rStart+n-1),(cStart:(cStart+n-1)),channel);
sraw = raw(rStart:(rStart+n-1),(cStart:(cStart+n-1)));
vcNewGraphWin; imagesc(sjpg), axis image; colormap(gray), title('JPEG')
vcNewGraphWin; imagesc(sraw), axis image; colormap(gray), title('RAW')


%%

n = 64;
template = jpg(rStart:(rStart+n),(cStart:(cStart+n)),3);

n = 96;
A = raw(rStart:(rStart+n),(cStart:(cStart+n)));
cc = normxcorr2(template,A);

[max_cc, imax] = max(abs(cc(:)));
[ypeak, xpeak] = ind2sub(size(cc),imax(1));
corr_offset = [ (ypeak-size(template,1)) (xpeak-size(template,2)) ];
fprintf('Estimated offset row %i, col %i\n',corr_offset(1),corr_offset(2));

% vcNewGraphWin; mesh(C)
rMax = max(cc,[],1); cMax = max(cc,[],2);
vcNewGraphWin; plot(rMax); hold on; plot(cMax);

%%
vcNewGraphWin;
% 
whichCol = 40;
tmpRaw = double(sraw(:,whichCol));
tmpRaw = tmpRaw/max(tmpRaw(:));
plot((1:128) - corr_offset(1),tmpRaw)
hold on;
tmpJPG = double(sjpg(:,whichCol));
tmpJPG = tmpJPG/max(tmpJPG(:));
plot((1:128),tmpJPG)



%% END