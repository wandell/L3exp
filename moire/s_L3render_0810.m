%% s_L3render
%
% After creating an L3 structure using, say, s_L3Scenes2SensorData, we 
% render an image using the L3 pipeline using this script
%
%
% See also: s_L3Scenes2SensorData, L3render, cameraCompute
%
% (c) Stanford Vista Team 2012

%% Let's write an L3show(L3,param) function
% Let's try some more extensive training
%
% Get the image that shows us which luminance level is used per image patch
% and do some demos of the method
%
% We want to see that the training worked out well.
% Or maybe what popped up is enough.
%

%% Load scene
% ii = 2;
% sNames     = dir(fullfile(L3rootpath,'Data','Scenes','*scene.mat'));
% thisName   = fullfile(L3rootpath,'Data','Scenes',sNames(ii).name);
% data       = load(thisName,'scene');
% thisScene  = data.scene;
%We might need to check that the scene FOV and illuminant match what was
%used for training.

horizontalFOV = 4;
meanLuminance = 600;

% Set the scene mean luminance somewhere reasonable
% thisScene = sceneAdjustLuminance(thisScene,meanLuminance);
% thisScene = sceneSet(thisScene,'hfov',horizontalFOV);

%%<<<<<<< .mine
%% Alternative
% thisScene = sceneCreate('freq orient');
% thisScene = sceneSet(thisScene,'fov',4);

%% Alternative2 for Moire pattern
thisScene = sceneCreate('moire orient');
sensor = cameraGet(L3camera,'sensor');
wave = oiGet(sensor,'wave');
d65 = vcReadSpectra('D65',wave);
thisScene = sceneSet(thisScene,'illuminant',d65);
thisScene = sceneSet(thisScene,'fov',4);
%% Alternative
% thisScene = sceneFromFile('StuffedAnimals_tungsten-hdrs','multispectral');
% thisScene = sceneAdjustLuminance(thisScene,meanLuminance);
% thisScene = sceneSet(thisScene,'hfov',horizontalFOV);

%% Alternative
% thisScene = sceneCreate('zone plate',[512 512]);
% thisScene = sceneSet(thisScene,'fov',horizontalFOV);
% thisScene = sceneAdjustLuminance(thisScene,meanLuminance);

% vcAddAndSelectObject(thisScene); sceneWindow;

%% Alternative
% thisScene = sceneCreate('freq orient');
%>>>>>>> .r934
% thisScene = sceneSet(thisScene,'fov',horizontalFOV);
% thisScene = sceneAdjustLuminance(thisScene,meanLuminance);






%% Increase size of sensor
% sensor = cameraGet(L3camera,'sensor');
% sensor = sensorSet(sensor,'size',[1000,1000]);
% L3camera = cameraSet(L3camera,'sensor',sensor);
% 
% sensor = cameraGet(xyzcamera,'sensor');
% sensor = sensorSet(sensor,'size',[1000,1000]);
% xyzcamera = cameraSet(xyzcamera,'sensor',sensor);


%% Calculate ideal XYZ image
[L3camera,xyzIdeal] = cameraCompute(L3camera,thisScene,'idealxyz');

% Get an estimate of the irradiance at the sensor (lux-sec).  This depends
% on the aperture and exposure time.
oi     = cameraGet(L3camera,'oi');
lux    = oiGet(oi,'mean illuminance');
sensor = cameraGet(L3camera,'sensor');
eTime  = sensorGet(sensor,'exp time','sec');
fprintf('Light at sensor %.3f (luxSec)\n',lux*eTime);

% Ideally we would take the oi out of xyzcamera and move it to L3camera so
% it doesn't need to be calculated again in the next cell.

%% Calculate L^3 result
% Make sure this is set for an L3 pipeline.
% Run it from the scene.
L3camera = cameraSet(L3camera,'vci name','L3');
L3camera = cameraCompute(L3camera,'oi');   % OI is already calculated
xyzL3    = cameraGet(L3camera,'image');

%% Calculate global L^3
% This implementation with cameraCompute is inefficient because L3render
% calculates both L3 and global L3 but only one output is stored at a time.
L3camera  = cameraSet(L3camera,'vci name','L3 global');
L3camera  = cameraCompute(L3camera,'sensor');
xyzGlobal = cameraGet(L3camera,'image');

%% Basic ISET pipeline result
% We should set up some typical defaults in the vci so that the system runs
% right.  Not done yet.
L3camera = cameraSet(L3camera,'vci name','default');
L3camera = cameraCompute(L3camera,'sensor');
rgbBasic = cameraGet(L3camera,'image');

%% Show the three results
vcNewGraphWin([],'tall'); 

% Should we scale on just Y? or on the whole XYZ?
xyzmax = max(xyzIdeal(:));   %this is used to scale all images
rgbIdeal = xyz2srgb(xyzIdeal/xyzmax);
subplot(3,1,1), imagesc(rgbIdeal); axis image
title('Ideal')

%% Show the L3 result
% NOTE: Clipping going on here.

tmp = xyzL3/xyzmax; rgbL3 = xyz2srgb(tmp);
rgbL3(rgbL3<0)=0; 
subplot(3,1,2), imagesc(rgbL3); axis image
title('L3')

%% Show the Global L3 result
tmp = xyzGlobal/xyzmax;  rgbGlobal =xyz2srgb(tmp);
rgbGlobal(rgbGlobal<0)=0; 
subplot(3,1,3), imagesc(rgbGlobal); axis image
title('L3 Global')

%% 
vci = cameraGet(L3camera,'vci');
L3 = imageGet(vci,'L3');
lumIdx = L3Get(L3,'luminance index');
vcNewGraphWin;
imagesc(lumIdx)

%% Show the basic ISET result
% This uses some arbitrary scaling.  I'm not sure what makes the most sense.
% rgbBasic(isnan(rgbBasic)) = 0;
% vcNewGraphWin;
% imagescRGB(rgbBasic);
% title('Basic Pipeline')


%% Show the SSIM result between Ideal and L3
%r_Ideal=rgbIdeal(:,:,1);
%r_L3=rgbL3(:,:,1);
rgb_split_Ideal=rgbIdeal(4:end-3,4:end-3,:);
grayIdeal=rgb2gray(rgb_split_Ideal);
max_grayIdeal=max(grayIdeal(:));
grayIdeal_image=uint8((grayIdeal/max_grayIdeal)*255);
vcNewGraphWin; imagesc(grayIdeal_image); axis image; % truesize
title('gray image of Ideal')

rgb_split_L3=rgbL3(4:end-3,4:end-3,:);
grayL3=rgb2gray(rgb_split_L3);
max_grayL3=max(grayL3(:));
grayL3_image=uint8((grayL3/max_grayL3)*255);
vcNewGraphWin; imagesc(grayL3_image); axis image; % truesize
title('gray Image of L3')

K = [0.01 0.03]; % constants in the SSIM index formula
window = fspecial('gaussian', 11, 1.5); % local window for statistics
L = 255; % L: dynamic range of the images

[mssim, ssim_map] = ssim_index(grayIdeal_image, grayL3_image, K, window, L);
vcNewGraphWin; 
imagesc(ssim_map); axis image
title('SSIM MAP')

%% Moire pattern measurement
rgb_split_Ideal=rgbIdeal(4:74,4:92,:);
whitept = whitepoint('d65');
whitept = whitept/max(whitept);
LabIdeal=xyz2lab(srgb2xyz(rgb_split_Ideal),whitept);
abIdeal=sqrt((LabIdeal(:,:,2).^2)+(LabIdeal(:,:,3).^2));
vcNewGraphWin; imagesc(abIdeal); axis image; % truesize
title('ab values of Ideal in Lab')

rgb_split_L3=rgbL3(4:74,4:92,:);
LabL3=xyz2lab(srgb2xyz(rgb_split_L3),whitept);
abL3=sqrt((LabL3(:,:,2).^2)+(LabL3(:,:,3).^2));
vcNewGraphWin; imagesc(abL3); axis image; % truesize
title('ab values of L3 in Lab')

%%%%% Draw Graph
%%% Diagonal line
% min_size=min(size(abIdeal));
% x=linspace(1, min_size, min_size);
% 
% for i=1 : min_size
%     data_abIdeal(1,i)=abIdeal(i,i);
%     data_abL3(1,i)=abL3(i,i);
% end

%% Horizontal line
min_size=min(size(abIdeal));
center=round(min_size/2);
max_size=max(size(abIdeal));
x=linspace(1, max_size, max_size);
data_abIdeal=abIdeal(center,:);
data_abL3=abL3(center,:);

plot(x, data_abIdeal, 'LineWidth',2.5);
hold on;
plot(x, data_abL3, 'r', 'LineWidth',2.5);
axis([0, min_size, 0, 150])
xlabel('distance from origin'); ylabel('ab');
title('ab values of ideal and L3')
%% We need to write the series of evaluation functions
% L3Evaluate(L3,resultImage,idealImage)

%% Other random stuff


%% Compare the two algorithms in srgb space
% % Let's start getting metrics running at some point.  Probably move it into
% % an s_L3Evaluate script.
% vcNewGraphWin([],'tall');
% eImg = abs(srgbL3 - srgbG);
% eImg = eImg/max(eImg(:));
% 
% subplot(2,1,1), imagesc(eImg);
% subplot(2,1,2), hist(srgbL3(:)-srgbG(:)); title('RGB error')
% 
% %% Build a new sensor image and look again
% thisScene = sceneCreate;
% oi     = L3Get(L3,'oi');
% oi     = oiCompute(thisScene,oi);
% sensor = L3Get(L3,'sensor design');
% sensor = sensorSet(sensor,'NoiseFlag',2);  % Turn on noise
% sensor = sensorCompute(sensor,oi,0);
% % vcAddAndSelectObject(sensor); sensorImageWindow
