%% s_L3render
%
% After creating L3 cameras, say, s_L3TrainCamera, we 
% render an image using the L3 pipeline using this script
%
%
% See also: s_L3TrainCamera, L3render, cameraCompute
%
% (c) Stanford Vista Team 2012


%% Parameters
meanLuminance = 1000;
fovScene      = 10;

%% Load scene included in L3 directory
% ii = 5;
% sNames     = dir(fullfile(L3rootpath,'Data','Scenes','*scene.mat'));
% thisName   = fullfile(L3rootpath,'Data','Scenes',sNames(ii).name);
% data       = load(thisName,'scene');
% thisScene  = data.scene;

%% Alternative Scenes
% thisScene = sceneFromFile('StuffedAnimals_tungsten-hdrs','multispectral');
% thisScene = sceneCreate('zone plate',[1000,1000]); %sz = number of pixels of scene
% thisScene = sceneCreate('freq orient');
thisScene = sceneCreate('moire orient');

%% Adjust FOV of camera to match scene, no extra pixels needed. 
L3camera = cameraSet(L3camera,'sensor fov',fovScene);

%% Change the scene so its wavelength samples matches the camera
wave = cameraGet(L3camera,'sensor','wave');
thisScene = sceneSet(thisScene,'wave',wave');

%% Chagne scene illuminant if it is different than used for training
testingilluminant = sceneGet(thisScene,'illuminant energy');

L3 = cameraGet(L3camera,'vci','L3');
trainingilluminant = L3Get(L3,'training illuminant');
% %Following might need to be changed to illuminantGet( ,'energy') for new
% scenes
trainingilluminant = trainingilluminant.data;

%Normalize since the scale is adjusted later when setting mean luminance.
testingilluminant = testingilluminant/mean(testingilluminant);
trainingilluminant = trainingilluminant/mean(trainingilluminant);

percenterror = max(abs(trainingilluminant - testingilluminant)...
                / trainingilluminant);
            
if percenterror > .01
    warning(['Scene illuminant does not match illuminant used for testing.',...
            '  Now changing scene illuminant to make it match.'])
    thisScene = sceneAdjustIlluminant(thisScene,trainingilluminant')
end

%% Find white point
whitept = sceneGet(thisScene,'illuminant xyz');
whitept = whitept/max(whitept);

%White point scaling is consistent with how the images are scaled for
%display where the brightest XYZ value in the ideal image is scaled to 1.

%% Set scene FOV and mean luminance
thisScene = sceneSet(thisScene,'hfov',fovScene);
thisScene = sceneAdjustLuminance(thisScene,meanLuminance);


%% Calculate ideal XYZ image
[L3camera,xyzIdeal] = cameraCompute(L3camera,thisScene,'idealxyz');


%% Estimate of amount of light at sensor
% Get an estimate of the irradiance at the sensor (lux-sec).  This depends
% on the aperture and exposure time.
oi     = cameraGet(L3camera,'oi');
lux    = oiGet(oi,'mean illuminance');
sensor = cameraGet(L3camera,'sensor');
eTime  = sensorGet(sensor,'exp time','sec');
fprintf('Light at sensor %.3f (luxSec)\n',lux*eTime);

%% Calculate L^3 result
% Make sure this is set for an L3 pipeline.
L3camera = cameraSet(L3camera,'vci name','L3');
L3camera = cameraCompute(L3camera,'oi');   % OI is already calculated
xyzL3    = cameraGet(L3camera,'image');

%% Calculate global L^3
L3camera  = cameraSet(L3camera,'vci name','L3 global');
L3camera  = cameraCompute(L3camera,'sensor');
xyzGlobal = cameraGet(L3camera,'image');

%% Basic ISET pipeline result
% We should set up some typical defaults in the vci so that the system runs
% right.  Not done yet.
L3camera = cameraSet(L3camera,'vci name','default');
L3camera = cameraCompute(L3camera,'sensor');
rgbBasic = cameraGet(L3camera,'image');

%% Remove black border from all images
L3         = cameraGet(L3camera,'L3');
lumIdx     = L3Get(L3,'luminance index');

xyzIdeal    = L3imcrop(L3,xyzIdeal); 
xyzL3       = L3imcrop(L3,xyzL3);
xyzGlobal   = L3imcrop(L3,xyzGlobal);
rgbBasic    = L3imcrop(L3,rgbBasic);
lumIdx      = L3imcrop(L3,lumIdx);

%% Convert XYZ to sRGB
rgbIdeal    = L3xyz2srgb(xyzIdeal,xyzIdeal);
rgbL3       = L3xyz2srgb(xyzL3,xyzIdeal);
rgbGlobal   = L3xyz2srgb(xyzGlobal,xyzIdeal);

%% Show the three results
vcNewGraphWin;  imagesc(rgbIdeal); axis image
title('Ideal')

%% Show the L3 result
vcNewGraphWin; imagesc(rgbL3); axis image
title('L3')

%% Show the Global L3 result
vcNewGraphWin; imagesc(rgbGlobal); axis image
title('L3 Global')


%% Moire pattern measurement
xyzIdeal_new = srgb2xyz(rgbIdeal);
LabIdeal=xyz2lab(xyzIdeal_new,whitept);

aa=abs( LabIdeal(:,:,3)-LabIdeal(:,:,2) );
abIdeal=sqrt((LabIdeal(:,:,2).^2)+(LabIdeal(:,:,3).^2));
abIdeal=aa.*abIdeal;
vcNewGraphWin; imagesc(abIdeal); axis image; % truesize
title('abIdeal image')

xyzL3_new = srgb2xyz(rgbL3);
LabL3=xyz2lab(xyzL3_new,whitept);

bb=abs( LabL3(:,:,3)-LabL3(:,:,2) );
abL3=sqrt((LabL3(:,:,2).^2)+(LabL3(:,:,3).^2));
abL3=bb.*abL3;
vcNewGraphWin; imagesc(abL3); axis image; % truesize
title('abL3 Image')

%% Delta E
deltaEim = deltaEab(xyzIdeal_new,xyzL3_new,whitept);
vcNewGraphWin; imagesc(deltaEim);
axis image; % truesize
title('Delta E')

%% Cut Boundary
[R C]=size(abIdeal);
abIdeal=abIdeal(3:R-2,3:C-2,:);
abL3=abL3(3:R-2,3:C-2,:);
deltaEim=deltaEim(3:R-2,3:C-2,:);

%% Moire Examination 1

% Mean of square of a and b
filter_size=3;

[abIdeal_mean, abL3_mean, deltaEim_mean]=mean_ab_square(abIdeal,abL3, deltaEim, filter_size);
% [abIdeal_max, abL3_max, deltaEim_max]=max_ab_square(abIdeal,abL3, deltaEim, filter_size);
% [abIdeal_min, abL3_min, deltaEim_min]=min_ab_square(abIdeal,abL3, deltaEim, filter_size);


% Diagonal Line (sinusoidalim, squareim, flat in sceneCreate)
[line_abIdeal, line_abL3, line_deltaE, line_L3_Ideal] = moire_diagonal(abIdeal, abL3, deltaEim);
[line_abIdeal_mean, line_abL3_mean, line_deltaE_mean] = moire_diagonal_processing(abIdeal_mean, abL3_mean, deltaEim_mean);
 plot_moire(abIdeal, abL3, deltaEim);

% Center Line (sinusoidalim_line, squareim_line, flat in sceneCreate)
% [line_abIdeal, line_abL3, line_deltaE] = moire_center_line(abIdeal,abL3, deltaEim);
% [line_abIdeal_mean, line_abL3_mean, line_deltaE_mean] = moire_center_line(abIdeal_mean, abL3_mean, deltaEim_mean);
%  plot_moire(abIdeal, abL3, deltaEim);

% Moire starting point
moire_cpd = moire_starting_point(line_L3_Ideal);

%% Show the SSIM result between Ideal and L3
% rgb_split_Ideal=rgbIdeal(4:74,4:92,:);
% grayIdeal=rgb2gray(rgb_split_Ideal);
% max_grayIdeal=max(grayIdeal(:));
% grayIdeal_image=uint8((grayIdeal/max_grayIdeal)*255);
% vcNewGraphWin; imagesc(grayIdeal_image); axis image; % truesize
% title('grayIdeal Image')
% 
% rgb_split_L3=rgbL3(4:74,4:92,:);
% grayL3=rgb2gray(rgb_split_L3);
% max_grayL3=max(grayL3(:));
% grayL3_image=uint8((grayL3/max_grayL3)*255);
% vcNewGraphWin; imagesc(grayL3_image); axis image; % truesize
% title('grayL3 Image')
% 
% K = [0.01 0.03]; % constants in the SSIM index formula
% window = fspecial('gaussian', 11, 1.5); % local window for statistics
% L = 255; % L: dynamic range of the images
% 
% [mssim, ssim_map] = ssim_index(grayIdeal_image, grayL3_image, K, window, L);
% vcNewGraphWin; 
% imagesc(ssim_map); axis image
% title('SSIM_MAP')

%% Show luminance index used for each patch
% vcNewGraphWin;
% imagesc(lumIdx)
% title('Luminance Index')

%% Show the basic ISET result
% This uses some arbitrary scaling.  I'm not sure what makes the most sense.
% rgbBasic(isnan(rgbBasic)) = 0;
% vcNewGraphWin;
% imagescRGB(rgbBasic);
% title('Basic Pipeline')

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
