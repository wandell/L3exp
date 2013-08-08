%% Specify cameras to use and scene
% cfas = {'Bayer', 'RGBx', 'RGBW1', 'CMY4','multi1'};
% cfas = {'Bayer', 'RGBx', 'CMY4','multi1','5band'};
% cfas = {'Bayer','5band'};
cfas = {'RGBW1'};

% processors = {'basic', 'L3'};
processors = {'L3'};
scenefileNames = {'FosterBuilding-photons', 'FosterBuilding-photons',...
    'Uniform D65', 'Moire Orient', 'text.png', 'ConnyCloseup', ...
    'Fruit_506x759-corrected', 'Tomatoes_506x759-corrected', ...
    'CaucasianAsianAfricanAmerican'};
sceneNames =     {'Buildings50', 'Buildings100', ...
    'Uniform', 'Moire', 'Text', 'Conny', 'Fruit', 'Tomato', 'People'};
meanLuminances = [50,            100,      ...
    100,        100,    100,    100,     100,     100, 100];
scenefovs =      [32,            32,       ...
    32,         22,     22,      24,       32,      32, 39];
    %field of view for scene, this results in some cropping
    % cropping is needed to deal with aspect ratio not being same as sz
    % camera's fov is 21
scaleoutputs =   [1,              1,       ...
    0.5,           .9,  .9,      1.5,         1,       1,  1.5];
    
createsceneflags = [0,            0,       ...
    1,          1,      1,       0,         0,       0,  0];


    
    
    
    
    
    
    
for scenenum = 6:length(scenefileNames)
% for scenenum = 6
    scenefileName = scenefileNames{scenenum};
    sceneName = sceneNames{scenenum};
    meanLuminance = meanLuminances(scenenum);
    scenefov = scenefovs(scenenum);
    scaleoutput = scaleoutputs(scenenum);    
    createsceneflag = createsceneflags(scenenum);    

    outputfolder = fullfile(L3rootpath,'Experiments','Subjective','Images',sceneName);
    rawfolder = fullfile(L3rootpath,'Experiments','Subjective','Images',sceneName,'Raw');
    sz = [512,512]; % size of output images


    %% Make all of the test images

    % If output folder does not exist, make it.
    if exist(outputfolder,'dir')~=7
        mkdir(outputfolder)
    end
    if exist(rawfolder,'dir')~=7
        mkdir(rawfolder)
    end    

    
    
    
    for cfanum = length(cfas)
        
        
        
        
        
        
        
        cfa = cfas{cfanum};
        disp(['CFA = ',cfa])

        % This would be more efficient if we stored the raw and ideal images
        % after the first run.  Then only apply the processing for all
        % remaining processors.
        for processornum = 1:length(processors)
            processor = processors{processornum};
            disp(['  Processor = ',processor])

            camerafilename = [processor,'camera_',cfa,'.mat'];
            tmp = load(camerafilename);
            camera = tmp.camera;

            if createsceneflag
                if strcmp(scenefileName, 'text.bmp')
                    scene = sceneFromFile('text.bmp','rgb');
                else
                    scene  = sceneCreate(scenefileName);                   
                end
                [srgbResult, srgbIdeal, raw] = ...
                    cameraComputesrgb(camera, scene, meanLuminance, ...
                    sz, scenefov, scaleoutput);
            else
                [srgbResult, srgbIdeal, raw] = ...
                    cameraComputesrgb(camera, scenefileName, meanLuminance, ...
                    sz, scenefov, scaleoutput);
            end
            
            % Blacken the bottom right of the Moire images
            if strcmpi(sceneName,'moire')
                maxdist = min(sz);
                [x,y]=meshgrid(1:maxdist);
                dist=sqrt(x.^2+y.^2);

                % Set maximum distance.  This makes bottom right of image be constant
                % color instead of having increasingly high frequencies.
                remove = (dist>maxdist);
                for colornum = 1:3
                    channel = srgbResult(:,:,colornum);
                    channel(remove) = 0;
                    srgbResult(:,:,colornum) = channel;
                    
                    channel = srgbIdeal(:,:,colornum);  
                    channel(remove) = 0;
                    srgbIdeal(:,:,colornum) = channel;
                end
            end
                
            imwrite(srgbResult,[outputfolder,filesep,processor,'_',cfa,'.png'])
        end
        save([rawfolder,filesep,cfa,'-raw'],'raw')
    end
    imwrite(srgbIdeal,[outputfolder,filesep,'ideal.png'])
end