%% Example of how we call L3 methods
%
%% Historical note

% I cleaned up the default camera, getting rid of the scene training data
% and the cos4th and ...
% save('tmpCameraDefault','camera');
% oi = cameraGet(camera,'oi');
% L3 = cameraGet(camera,'ip L3');
% L3 = L3Set(L3,'oi',oi);
% camera = cameraSet(camera,'ip L3',L3);
% camera = cameraClearData(camera);
% 
% fname = fullfile(L3rootpath,'data','cameras','L3defaultcamera');
% save(fname,'camera');
%
%  camera = cameraCreate('L3');
%  camera = cameraSet(camera,'ip gamma',1);
%  fname = fullfile(L3rootpath,'data','cameras','L3defaultcamera');
%  save(fname,'camera');
%
%% Clean the environment
ieInit

%% Load an L3 camera

% The default camera is an RGBW with an L3 structure that has seven small
% training scenes.   We should make more cameras and put in an fname option
% into the L3 cameraCreate call.  Maybe instead of L3struct as a second
% argument, we could have a string that is the camera name to load?
camera = cameraCreate('L3');
% camera = cameraSet(camera,'ip gamma',1);

% Render a simple scene
scene = sceneCreate;
camera = cameraCompute(camera,scene);
cameraGet(camera,'ip gamma')
cameraWindow(camera,'ip');

%%
scene = sceneSet(scene,'mean luminance',10);
camera = cameraCompute(camera,scene);
camera = cameraSet(camera,'ip gamma',1);
cameraWindow(camera,'ip');


%% Render a different scene

% Scene options
% scene = sceneCreate;
% scene = sceneCreate('rings rays');
% scene = sceneCreate('freq orient');
% fname = fullfile(isetRootPath,'data','images','rgb','eagle.jpg');
fname = fullfile(isetRootPath,'data','images','rgb','FruitMCC_6500.tif');  
scene = sceneFromFile(fname,'rgb');

scene = sceneSet(scene,'mean luminance',10);
fprintf('scene mean luminance %g\n',sceneGet(scene,'mean luminance'));

% L3 at the front makes sure we get an L3 rendering method call
camera = cameraSet(camera,'sensor exp time',0.05);
camera = cameraSet(camera,'ip name',sprintf('L3 %s',sceneGet(scene,'name')));
camera = cameraCompute(camera,scene);

% Have a look
cameraWindow(camera,'ip');

%%
scene = sceneSet(scene,'mean luminance',100);
fprintf('scene mean luminance %g\n',sceneGet(scene,'mean luminance'));

% L3 at the front makes sure we get an L3 rendering method call
camera = cameraSet(camera,'sensor exp time',0.05);
camera = cameraSet(camera,'ip name',sprintf('L3 %s',sceneGet(scene,'name')));
camera = cameraCompute(camera,scene);

% Have a look
cameraWindow(camera,'ip');

%% Use the standard processing pipeline
camera = cameraSet(camera,'ip name','standard');
cameraWindow(camera,'ip');

%% Look at other stuff, if you like
cameraWindow(camera,'sensor');
cameraWindow(camera,'oi');

scene = sceneCreate('rings rays');
scene = sceneSet(scene,'mean luminance',0.00001);
vcAddObject(scene); sceneWindow;
camera = cameraCompute(camera,scene);
cameraWindow(camera,'ip');


%% Let's make a new Bayer camera, train it, and render with it

% Now we use the camera design for rendering images


%% Load a training scene 
%  This will become load a cell array of training scenes

scene = sceneFromFile('StuffedAnimals_tungsten-hdrs','multispectral');
meanLuminance = 100;     % cd/m^2
fovScene      = 10;     % degrees in horizontal field of view
scene = sceneSet(scene,'hfov',fovScene);
scene = sceneAdjustLuminance(scene,meanLuminance);

%% Adjust camera FOV of camera to match scene
camera = cameraSet(camera,'sensor fov',fovScene);

% Set a 50 ms exposure time on the sensor.  Not sure why, and probably this
% should be managed in the L3Train, not here.
camera = cameraSet(camera,'sensor exp time',0.05);
%% Perform training

L3 = cameraGet(camera,'ip L3');
if ieNotDefined('trainingscenes'),     
    L3 = L3InitTrainingScenes(L3);
else
    % use specified training scenes
    L3 = L3Set(L3,'scene',trainingscenes);
end

% Temporarily shrink the number of scenes.
s = L3Get(L3,'scenes');
s = {s{1}};

L3 = L3Set(L3,'scenes',s);

% Way to add a scene
% L3 = L3Set(L3,'scenes',scene,1);

% We should be able to set the luminance levels from here easily
L3 = L3Train(L3);



%%  Move deeper in the code to more L^3 specific functions
%

% Following is in ipCompute, which is called using the following line:
% vci    = ipCompute(vci,sensor);  
    L3 = cameraGet(camera,'ip L3');

%   Following is in L3render, which is called using the following line:
    % [L3xyz, lumIdx, satIdx, clusterIdx] = L3render(L3,sensor,mode); 

%% Show CFA and RAW image
% The CFA pattern is visible in the RAW image.  Here the RAW image is
% drawn as a monochrome image although the measurement at each pixel
% has an associated color.
%
% The 2x2 RGBW CFA is used in this example.

      % RAW sensor image
      inputIm = sensorGet(sensor,'volts');
      vcNewGraphWin; 
      imagesc(inputIm/max(inputIm(:))); colormap(gray)
      sz      = sensorGet(sensor,'size');
      title('RAW sensor image')
      
      % RGBW CFA
      L3plot(L3,'cfa full');       title('RGBW CFA')
 
      % Spectral sensitivities
      wave = sensorGet(sensor,'wave');
      sensitivities = sensorGet(sensor,'spectral QE');
      vcNewGraphWin;   hold on
      plotcolors='rgbk';
      for colornum=1:4
          plot(wave,sensitivities(:,colornum),plotcolors(colornum))
      end
      xlabel('Wavelength (nm)');  title('Spectral Sensitivities')          
    
%% Show Patch Types
% L^3 is a patch based algorithm.  The output at each pixel is a
% function only of a set of nearby pixels in the input RAW image.
%
% Here a patch is a 5x5 square of pixels centered at the pixel where
% we want to calculate the output.  Since the CFA is a 2x2 pattern,
% there are 4 types of pixels (RGB and W), which could be at the
% center of a patch.  Therefore, we have the following four types of
% patches.
%
% Different filters have been trained for each patch type.  We will
% build the output image by iterating through each patch type and
% using the appropriate filters.

      warning('off')    %needed because of CFA/data mismatch      
      for patchtyperow=1:2
          for patchtypecol=1:2
              L3plot(L3,'block pattern',[patchtyperow,patchtypecol]);
              title(['Patch Type ',num2str(patchtyperow),', '...
                  ,num2str(patchtypecol)])
          end
      end
      warning('on')     
      
%% Load and show patches from RAW image
% All patches of a particular patch type are loaded at the same time.

      % For the rest of this article, just consider patch type 1,1 that has
      % a center R pixel because the stored CFA has R in 1st row and
      % column. Normally all patch types are looped over.
      rr=1; cc=1;
      L3 = L3Set(L3,'patch type',[rr,cc]);
      
      % Load all patches of this cfa position from RAW image
      inputPatches = L3sensor2Patches(L3,inputIm); 
      
      % Patches are stored as a matrix where each row is a vectorized
      % patch.
      
      % Size of this matrix: number of pixels in a patch x number of
      % R pixels in the RAW image.  (The border of the image is ignored
      % when a patch cannot fit so this number is slightly off.)      
      patchesSize = size(inputPatches)
      
      indices=ceil(rand(1,25)*size(inputPatches,2)/2); %Randomly pick 25 patches
      
      L3 = L3Set(L3,'patches', inputPatches);
      L3plotpatches(L3,indices,5,5);
      title('Some of the Input Patches of Type 1,1')

%% Find saturation case for each patch
% When a patch has at least one pixel of a certain color saturated, all
% pixels of that color are ignored during calculations.  There are
% saturation cases like no saturation, W saturation, W&G saturation.
%
% Different filters have been trained for each saturation case. We will
% build the output image by iterating through each saturation case and
% using the appropriate filters.
        
        % Find all saturation cases for R patches, stored as a matrix. Each
        % column represents a saturation case. Rows represent R, G, B, W
        % pixels and "1" indicates saturated color for this saturation case.
        saturationlist = L3Get(L3,'saturation list')
        
        % Find saturation type for each patch
        saturationindex = L3FindSaturationIndex(L3);
        % Find needed saturation cases for all R patches for this RAW image
        neededsaturations = unique(saturationindex(:))
           
        % For the rest of this article, just consider the case where no
        % colors are saturated, which is always the first column.
        st = 1;
        saturationindices = (saturationindex == st);
        
        % Set current patch luminance index
        L3 = L3Set(L3,'Saturation Type', st);                
        allPatches = L3Get(L3,'patches');
        L3 = L3Set(L3,'patches', allPatches(:, saturationindices));              
               
%% Find patch luminance for each patch
% Since light level significantly alters the amount of noise in the
% measurements, the L^3 algorithm adapts to the local light level.
%
% The local light level for a patch is called its patch luminance.  The
% patch luminance is a weighted average of the RAW voltage values and is
% calculated by:
%
%       1.  Finding the average color across the patch for each CFA color
%       that is not saturated.
%
%       2.  Averaging the numbers in (1).
%
% This calculation is performed by applying the luminance filter using an
% inner product.

%     Following is in L3applyPipeline2Patches, which is called using:
%      [xhatL3,lumIdx] = L3applyPipeline2Patches(L3,inputPatches,L3Type);

        luminancefilter = L3Get(L3,'luminance filter');
        L3plot(L3,'luminance filter');   title('Luminance Filter')
        
        allPatches = L3Get(L3,'patches');
        patchluminances = luminancefilter*allPatches;
        
        vcNewGraphWin;     hist(patchluminances,50)
        xlabel('Patch Luminance');      ylabel('Number of Patches')
        
%% Find closest patch luminance from trained samples for each patch
% Filters are learned for a predefined set of patch luminance values.  For
% each patch, calculate the patch luminance and find the closest luminance
% value that was used for training.

        %List of patch luminance values used for training
        patchLuminanceSamples = L3Get(L3,'luminance list')
        
        differences = repmat(patchluminances',1,length(patchLuminanceSamples)) - ...
            repmat(patchLuminanceSamples,length(patchluminances),1);
        [~,luminanceindex] = min(abs(differences'));    % closest sample

        vcNewGraphWin;
        hist(patchLuminanceSamples(luminanceindex),50)
        xlabel('Closest Patch Luminance');      ylabel('Number of Patches')

        % For the rest of this article, just consider patches that are
        % closest to the first trained patch luminance value.
        % Normally all patch types are looped over.
        ll = 1;
        currentpatches = find(luminanceindex == ll);
        
        %Set current patch luminance index
        L3 = L3Set(L3,'luminance type',ll);
        L3 = L3Set(L3,'patches', allPatches(:,currentpatches));        
        
%% Global Linear Pipeline  (simpler alternative to full L^3 pipeline)
% The simplest way to run the pipeline is to have a single filter for each
% patch type, saturation case, and luminance level.  We call this the
% global linear pipeline (which is a bad name).  This pipeline is simpler
% than the full L^3 pipeline and performance is usually only a little
% worse.

        L3plot(L3,'global filter');
        subplot(1,3,2)
        title('Global Pipeline Filters (3 plots are for XYZ)')

        %Output for global linear pipeline is calculated using a single
        %multiplication.
        globalpipelinefilter = L3Get(L3,'global filter');
        xhatL3(:,currentpatches) = globalpipelinefilter* L3Get(L3,'patches');

%% Divide patches into flat and texture
% Patches are divided into two groups, flat and texture.
%
% Flat patches come from uniform regions of an image.  For a flat patch all
% measurements of the same color are nearly equal.
%
% Texture patches come from edges or texture regions of an image.  For a
% texture patch, there is more variation across the patch measurements.

% Following steps are automatically calculated by L3Get.  Here the internal
% process is more clearly illustrated.
        
%%      1.  Calculate the mean in each color channel
            % means = L3Get(L3,'sensor patch means');
            meansFilter = L3Get(L3,'means filter');
            patches     = L3Get(L3,'patches');
            means = meansFilter*patches;

            L3plot(L3,'mean filter');
            subplot(1,4,2)
            title('Color Channel Means Filters (4 plots are for RGBW)')
            
%%      2.  Subtract the mean from each pixel with the corresponding color         
            % patcheszeromean = L3Get(L3,'sensor patch zero mean')
            blockPattern = L3Get(L3,'block pattern');
            patcheszeromean = L3adjustpatchmean(patches,-means,blockPattern);
        
%%      3.  Find patch contrast by summing 0 mean patch with abs value        
            % contrasts = L3Get(L3,'sensor patch contrasts');
            contrasts = mean(abs(patcheszeromean));

%%      4.  Compare patch contrast to threshold.  
            % If contrast<threshold, patch is flat.  If contrast>threshold, patch is texture.
            % flatindices = L3Get(L3,'flat indices');
            flatThreshold = L3Get(L3,'flat threshold');
            flatindices = (flatThreshold >= contrasts);

%% Apply filters to flat patches
% Optimal filters learned for the flat patches are applied to get the
% output XYZ estimates.
        flatfilters = L3Get(L3,'flat filters');
        patches = L3Get(L3,'patches');
        xhatL3(:,currentpatches(flatindices)) = flatfilters * patches(:,flatindices);        
                                
        L3plot(L3,'flat filter');
        subplot(1,3,2)        
        title('Filters for Flat Patches (3 plots are for XYZ)')

%% Flip texture patches into canonical form
% Since there are significant spatial differences within texture patches,
% it helps (a little) to decrease the possible variation in the patches.
% The patches are flipped over the vertical, horizontal, and main diagonal
% (assuming there is symmetry in the CFA pattern across these directions)
% so that each flipped texture patch has higher averages in the top, left,
% and above diagonal halves.

      textureindices = find(L3Get(L3,'texture indices'));
      randompick=ceil(rand(1,25)*size(textureindices,2)/2); %randomly pick 25
      selectedtextureindices = textureindices(randompick);
      
      L3plotpatches(L3,selectedtextureindices,5,5);
      title('Some Texture Patches before flip')

      L3 = L3flippatches(L3);
      
      L3plotpatches(L3,selectedtextureindices,5,5);
      title('Some Texture Patches after flip')      

%% Cluster texture patches
% The texture patches can be further subdivided using a hierarchical
% clustering method.  The idea is that by subdividing, similar patches will
% be grouped together and optimal filters for each cluster will be able to
% exploit the similar statistics of the patches.  This offers very small
% improvements and probably should be omitted for general natural scenes.
        L3 = L3clustertexturepatches(L3);        
                
%% Apply filters to texture patches
% Optimal filters learned for each cluster of texture patches are applied
% to get the output XYZ estimates.
        texturefilters = L3Get(L3,'texture filters');
        clustermembers = L3Get(L3,'cluster members');
        treedepth      = L3Get(L3,'tree depth');
        numclusters    = L3Get(L3,'nclusters');
        clusterrange   = 1:numclusters; %this should probably just be leaves
        for clusternum = clusterrange
            %clusterindices is vector of length equal to the number of allPatches,
            %each entry is 1 for each patch in the current cluster and 0 otherwise
            clusterindices = ...
                floor(clustermembers/2^(treedepth-floor(log2(clusternum))-1))==clusternum;

            xhatL3(:,currentpatches(clusterindices)) = ...
                texturefilters{clusternum} * patches(:,clusterindices);              
        end
                
        textureType = 1;
        L3plot(L3,'texture filter',[rr,cc],ll,st,textureType);
        subplot(1,3,2)        
        title('Filters for all Texture Patches (3 plots are for XYZ)')
        
        textureType = 5;
        L3plot(L3,'texture filter',[rr,cc],ll,st,textureType);
        subplot(1,3,2)        
        title('Filters for 1/4 of Texture Patches (3 plots are for XYZ)')        


%% Calculate ideal XYZ image
% Following XYZ image is the result that would occur with no noise if we
% had a sensor that measured the XYZ channels at every pixel.
[camera,xyzIdeal] = cameraCompute(camera,scene,'idealxyz');
xyzIdeal = xyzIdeal/max(xyzIdeal(:));   %scale to full display range

% vcNewGraphWin;  image(xyzIdeal); axis image; axis off;
% title('Ideal XYZ')

%Convert XYZ to lRGB and sRGB
[srgbIdeal, lrgbIdeal] = xyz2srgb(xyzIdeal);
vcNewGraphWin;  image(srgbIdeal)
title('Ideal XYZ as sRGB')

%% Calculate final output images
% Once the above calculations are performed for each patch using the
% appropriate patch type, saturation, luminance, and flat/texture, (which
% happens by calling cameraCompute), we can get the final output images.
      
% % Calculate L^3 result
% [camera, lrgbL3] = cameraCompute(camera,scene,lrgbIdeal);

% Calculate global L^3 result
camera  = cameraSet(camera,'vci name','L3 global');
[camera, lrgbGlobal] = cameraCompute(camera,scene,lrgbIdeal);

% Calculate L^3 result
camera  = cameraSet(camera,'vci name','L3');
[camera, lrgbL3] = cameraCompute(camera,'sensor',lrgbIdeal);

% lrgbIdeal is passed in above to help with scaling.
% To achieve consistent appearance for display, the result images are
% scaled so they have the same mean as the lrgbIdeal image.  This gives a
% consistent brightness for all images, which is not possible by simple
% independent scaling such as adjusting max to 1.

%% Show which of the trained patch luminance samples used at each pixel
vci = cameraGet(camera,'vci');
L3 = ipGet(vci,'L3');

lumIdx = L3Get(L3,'luminance index');
vcNewGraphWin;  imagesc(lumIdx); axis image; axis off;
colorbar
title('Luminance Value Used')

%% Show which of the saturation cases used at each pixel
vci = cameraGet(camera,'vci');
L3 = ipGet(vci,'L3');

satIdx = L3Get(L3,'saturation index');
vcNewGraphWin;  imagesc(satIdx); axis image; axis off;
colorbar
title('Saturation Case Used')

%% Show flat/texture classification results
vci = cameraGet(camera,'vci');
L3 = ipGet(vci,'L3');

clusterIdx = L3Get(L3,'cluster index');
vcNewGraphWin;  imagesc(clusterIdx); axis image; axis off;
colorbar
title('Flat/ Texture Classification Results')

%% Crop black border from all images
% L^3 does not give estimates for pixels near the image border.  An
% estimate is not possible for pixels when there is not enough room to fit 
% a patch.
xyzIdeal    = L3imcrop(L3,xyzIdeal);
srgbIdeal   = L3imcrop(L3,srgbIdeal);
lrgbIdeal   = L3imcrop(L3,lrgbIdeal);
lrgbL3      = L3imcrop(L3,lrgbL3);
lrgbGlobal  = L3imcrop(L3,lrgbGlobal);


%% Convert lrgb to srgb
srgbL3      = lrgb2srgb(ieClip(lrgbL3,0,1));
srgbGlobal  = lrgb2srgb(ieClip(lrgbGlobal,0,1));

%% Show the sRGB results
vcNewGraphWin;  imagesc(srgbIdeal); axis image
title('Ideal')

vcNewGraphWin; imagesc(srgbL3); axis image
title('L3')

vcNewGraphWin; imagesc(srgbGlobal); axis image
title('L3 Global')

%% Default ISET pipeline result
% Following is the default pipeline in ISET - bilinear demosaicking and
% linear color transform optimized over MCC.

camera = cameraSet(camera,'vci name','default');
[camera, lrgbbilinear] = cameraCompute(camera,'sensor',lrgbIdeal);

%Crop image to compare with other cropped images
lrgbbilinear   = L3imcrop(L3,lrgbbilinear);

% Convert to srgb
srgbbilinear   = lrgb2srgb(ieClip(lrgbbilinear,0,1));

vcNewGraphWin; imagesc(srgbbilinear); axis image
title('Default pipeline')

%% END