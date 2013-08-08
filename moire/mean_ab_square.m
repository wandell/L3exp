function [abIdeal_mean, abL3_mean, deltaEim_mean] = mean_ab_square(abIdeal,abL3, deltaEim, filter_size)

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
        abIdeal_temp(i,j)=mean(temp1(:));
        abL3_temp(i,j)=mean(temp2(:));
        deltaEim_temp(i,j)=mean(temp3(:));
    end
end

abIdeal_mean=abIdeal_temp;
abL3_mean=abL3_temp;
deltaEim_mean=deltaEim_temp;

vcNewGraphWin; imagesc(abIdeal_mean); axis image; % truesize
title('abIdeal mean Image')

vcNewGraphWin; imagesc(abL3_mean); axis image; % truesize
title('abL3 mean Image')

vcNewGraphWin; imagesc(deltaEim_mean); axis image; % truesize
title('deltaEim mean Image')