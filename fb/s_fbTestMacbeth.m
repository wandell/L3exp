% s_fbTestMacbeth
%
%
%

%%
s_initISET
workDir = fullfile(L3expRootPath,'fb');

%% Here is a simulation of the FB camera

% Sample wavelengths
wavelength = [400:10:680]';

% Exposure index for the 5-band camera
expIdx = 1; 
% expIdx = 4;

[sensor, optics] = fbCreate(wavelength', expIdx);

oi = oiCreate;
oi = oiSet(oi,'optics',optics);
oi = oiSet(oi,'name','fb optics');

%% Here is an image with the FB camera and an MCC
fName = fullfile(workDir,'Steve_2.8_Tungsten_exp_1.mat');
% fName = fullfile(workDir,'Steve_2.8_Tungsten_exp_4.mat');
tmp = load(fName);

% The raw camera data
vcNewGraphWin;
data = rot90(tmp.RAW,1);
imagesc(data);
axis image

% The SPD of the light
vcNewGraphWin;
ill.SPD = tmp.SPD;
ill.wave = tmp.wave;

plot(ill.wave,ill.SPD);
xlabel('Wave (nm)');
ylabel('Energy watts/sr/nm/m2');

%%  Place the measured image into a new sensor structure

sensorData = sensor;
sensorData = sensorSet(sensorData,'volts',data);
sensorData = sensorSet(sensorData,'name','data');

vcAddObject(sensorData); sensorWindow('scale',1);

%%
scene = sceneCreate('macbethD65',[],wavelength);
scene = sceneSet(scene,'fov',5);
SPDi = interp1(ill.wave,ill.SPD,wavelength);
% vcNewGraphWin; plot(ill.wave,ill.SPD,'k-',wavelength,SPDi,'ro')

scene = sceneAdjustIlluminant(scene,SPDi);
vcAddObject(scene); sceneWindow;

%%  Simulated values for the MCC under tungsten light

oi     = oiCompute(oi,scene);
vcAddObject(oi); oiWindow;

sensor = sensorCompute(sensor,oi);
sensor = sensorSet(sensor,'name','Simulated');
vcAddObject(sensor);
sensorWindow('scale',1);

%% Get the measured camera five band data for the MCC and this image
showSelection = 1;
fullData = 1;
[mRGB mLocs, pSize, cornerPoints] = macbethSelect(sensorData,showSelection,fullData);

% Select the proper image in the sensor window!
sData = zeros(24,sensorGet(sensorData,'n filters'));
for ii=1:24
    sData(ii,:) = nanmean(mRGB{ii});
end

%% Select the proper image in the sensor window!
[mRGB mLocs, pSize, cornerPoints] = macbethSelect(sensor,showSelection,fullData);
sSim = zeros(24,sensorGet(sensor,'n filters'));
for ii=1:24
    sSim(ii,:) = nanmean(mRGB{ii});
end

%
vcNewGraphWin;
plot(sSim(:)/max(sSim(:)),sData(:)/max(sData(:)),'o');
axis equal; grid on
identityLine;



%%


