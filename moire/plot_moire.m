function plot_moire(abIdeal,abL3,deltaEim)

figure
imagesc(deltaEim)



origin=[1,1];   %center of rings

[rows,cols] = size(deltaEim);

%ys and xs gives location of each pixel
[ys,xs] = meshgrid(1:rows, 1:cols);

%dist is distance from origin of each pixel
dist = sqrt((xs-origin(1)).^2 + (ys-origin(2)).^2);

%% Create mean line
numbuckets = 50;
quantizeddists = linspace(0,max(dist(:)), numbuckets);

meanabIdeal = zeros(1,numbuckets);
meanabL3 = zeros(1,numbuckets);
meandeltaE = zeros(1,numbuckets);

halfspacing = (quantizeddists(2) - quantizeddists(1))/2;
for bucketnum= 1:numbuckets
    quantizeddist = quantizeddists(bucketnum);
    
    %following indicate which of the pixels are closest to the current
    %distance
    indices = (abs(dist - quantizeddist) < halfspacing);
    
    meanabIdeal(bucketnum) = mean(abIdeal(indices));
    meanabL3(bucketnum) = mean(abL3(indices));
    meandeltaE(bucketnum) = mean(deltaEim(indices));    
end
    
%%
figure
plot(dist(:), abIdeal(:), '.', 'LineWidth',2.5);
hold on
plot(quantizeddists,meanabIdeal,'k.-')
title('ab Ideal')
xlabel('distance from origin'); ylabel('ab');

figure
plot(dist(:), abL3(:), 'r.', 'LineWidth',2.5);
hold on
plot(quantizeddists,meanabL3,'k.-')
title('ab L3')
xlabel('distance from origin'); ylabel('ab');

figure
plot(dist(:), deltaEim(:), 'g.', 'LineWidth',2.5);
hold on
plot(quantizeddists,meandeltaE,'k.-')
title('deltaE')
xlabel('distance from origin'); ylabel('ab');


%%
