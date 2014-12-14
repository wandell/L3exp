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
% expIdx = 1; 
expIdx = 4;

[sensor, optics] = fbCreate(wavelength', expIdx);

oi = oiCreate;
oi = oiSet(oi,'optics',optics);
oi = oiSet(oi,'name','fb optics');

%% Here is an image with the FB camera and an MCC
fName = fullfile(workDir,sprintf('Steve_2.8_Tungsten_exp_%i.mat',expIdx));
tmp = load(fName);

% The raw camera data
vcNewGraphWin;
data = tmp.RAW;
dataRot = rot90(tmp.RAW,1);
imagesc(dataRot);
axis image

% The SPD of the light, divide out by the white Macbeth patch reflectance
macbethReflectances = ieReadSpectra(fullfile(isetRootPath,'data','surfaces','macbethChart'),tmp.wave);
vcNewGraphWin;
ill.SPD = tmp.SPD./macbethReflectances(:,4);
ill.wave = tmp.wave;

plot(ill.wave,ill.SPD);
xlabel('Wave (nm)');
ylabel('Energy watts/sr/nm/m2');

%%  Place the measured image into a new sensor structure

sensorData = sensor;
sensorData = sensorSet(sensorData,'volts',data);
sensorData = sensorSet(sensorData,'dv',data*(2^sensorGet(sensorData,'nbits')));
sensorData = sensorSet(sensorData,'name','data');

vcAddObject(sensorData); sensorWindow('scale',1);

%% Get the measured camera five band data for the MCC and this image
showSelection = 1;
fullData = 1;

cornerPoints = [ 718   109
    88   129
    83   540
   725   530];

[mRGB, ~, ~, ~] = macbethSelect(sensorData,showSelection,fullData,cornerPoints);
sData = cell2mat(cellfun(@nanmean,mRGB','UniformOutput',false));



%%
spectrum.wave = wavelength;
scene = sceneCreate('macbethD65',[],spectrum);
scene = sceneSet(scene,'fov',60);
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



%% Select the proper image in the sensor window!

cornerPoints = [    199         658
        1080         658
        1085          68
         196          63];

[mRGB, ~, ~, ~] = macbethSelect(sensor,1,1,cornerPoints);
sSim = cell2mat(cellfun(@nanmean,mRGB','UniformOutput',false));

%% Plot the data
vcNewGraphWin;
styles = {'ro','go','bo','co','yo'};

for i=1:5
    
    % Least-squares fit
    A = [sSim(:,i) ones(24,1)];
    b = sData(:,i);
    coeffs = A\b;
    fprintf('Gain %f, offset %f\n',coeffs(1),coeffs(2));
    
    subplot(2,3,i);
    axis equal; grid on; hold on;
    plot(sSim(:,i),sData(:,i),styles{i});
    xlabel('Simulated');
    ylabel('Captured');
    
    % Plot the data after least-squares fitting
    plot(A*coeffs,b,'.');
    
    plot(linspace(0,max([sSim(:,i); sData(:,i)]*1.1),10),linspace(0,max([sSim(:,i); sData(:,i)]*1.1),10),'r:');
end



%%


