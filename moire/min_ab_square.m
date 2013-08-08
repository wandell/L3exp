function [abIdeal_min, abL3_min, deltaEim_min] = min_ab_square(abIdeal,abL3, deltaEim, filter_size)

width=floor(filter_size/2);
[R C] = size(abIdeal);
abIdeal_temp=zeros(R-width,C-width);
abL3_temp=zeros(R-width,C-width);
deltaEim_temp=zeros(R-width,C-width);

%% Mean of square of a and b
for i=width+1 : R-width
    for j=width+1 : C-width
        temp1=abIdeal(i-width:i+width,j-width:j+width);
        temp2=abL3(i-width:i+width,j-width:j+width);
        temp3=deltaEim(i-width:i+width,j-width:j+width);
        abIdeal_temp(i,j)=min(temp1(:));
        abL3_temp(i,j)=min(temp2(:));
        deltaEim_temp(i,j)=min(temp3(:));
    end
end

abIdeal_min=abIdeal_temp;
abL3_min=abL3_temp;
deltaEim_min=deltaEim_temp;

vcNewGraphWin; imagesc(abIdeal_min); axis image; % truesize
title('abIdeal Min Image')

vcNewGraphWin; imagesc(abL3_min); axis image; % truesize
title('abL3 Min Image')

vcNewGraphWin; imagesc(deltaEim_min); axis image; % truesize
title('deltaEim Min Image')