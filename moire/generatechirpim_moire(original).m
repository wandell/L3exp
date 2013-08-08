%% Parameters
%number of pixels on a side of the final image, we should make sure this is
%much higher than in our sensor later
pixelwidth=500;  

%a constant that controls initial frequency
%Goal is to avoid aliasing in this image but still make it hard for a
%camera to render the scene properly.  We will have to experiment to find
%out what value is best here.  Remember this is the scene so even an ideal
%sensor should have a lower resolution version of this.
% f=1/pixelwidth/10*4;    %seems to be at Nyquist limit at edges, too hard
% f=1/pixelwidth/10*2;    %1/2 Nyquist at edges, perhaps still too hard
f=1/pixelwidth/10;        %1/4 Nyquist at edges, more feasible


%% Generate sinusoidal and square chirps
[x,y]=meshgrid(1:pixelwidth);
dist=sqrt(x.^2+y.^2);
sinusoidalim=sin(2*pi*f/2*dist.^2);

%threshold the sinusoidal pattern to get the square pattern
squareim=(1+sign(sinusoidalim-.5))/2;

%% Make images
imwrite(sinusoidalim, 'sinusoidalim.jpg');
imwrite(squareim, 'squareim.jpg');

%% Show images
figure(1)
imagesc(sinusoidalim)
axis square
colormap(gray)
title('Sinusoidal Image')

figure(2)
imagesc(squareim)
axis square
colormap(gray)
title('Square Image')