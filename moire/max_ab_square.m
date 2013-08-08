function [abIdeal_max, abL3_max, deltaEim_max] = max_ab_square(abIdeal, abL3, deltaEim, filter_size)

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
        abIdeal_temp(i,j)=max(temp1(:));
        abL3_temp(i,j)=max(temp2(:));
        deltaEim_temp(i,j)=max(temp3(:));
    end
end

abIdeal_max=abIdeal_temp;
abL3_max=abL3_temp;
deltaEim_max=deltaEim_temp;

vcNewGraphWin; imagesc(abIdeal_max); axis image; % truesize
title('abIdeal Max Image')

vcNewGraphWin; imagesc(abL3_max); axis image; % truesize
title('abL3 Max Image')

vcNewGraphWin; imagesc(deltaEim_max); axis image; % truesize
title('deltaEim Max Image')