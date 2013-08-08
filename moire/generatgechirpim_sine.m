f=.001;  %frequency
theta=pi/2; %orientation angle
spacing=1:500;  %number of pixels on a side of the final image, we should make sure this is much higher than in our sensor later
[x,y]=meshgrid(2*pi/f*spacing,spacing');

sinusoidalim=sin(f*(cos(theta)*x+sin(theta)*y).^2);
squareim=(1+sign(sinusoidalim-.5))/2;
sinusoidalim=rot90(sinusoidalim,1);
squareim=rot90(squareim,1);

%%% Horizontal line
min_size=min(size(sinusoidalim));
center=round(min_size/2);
max_size=max(size(sinusoidalim));
x=linspace(1, max_size, max_size);
data_sinusoidalim=sinusoidalim(center,:);
data_squareim=squareim(center,:);

%%% Make images
imwrite(sinusoidalim, 'sinusoidalim_line.jpg');
imwrite(squareim, 'squareim_line.jpg');

figure(1)
imagesc(sinusoidalim)
axis square
colormap(gray)

% threshold the sinusoidal pattern to get the square pattern
squareim=(1+sign(sinusoidalim-.5))/2;

figure(2)
imagesc(squareim)
axis square
colormap(gray)
