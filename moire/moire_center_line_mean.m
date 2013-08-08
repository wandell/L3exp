function [line_abIdeal_mean, line_abL3_mean, line_deltaE_mean] = moire_center_line_mean(abIdeal_mean, abL3_mean, deltaEim_mean)

%% Horizontal line
data_abIdeal_mean=[];   data_abL3_mean=[];   data_deltaE_mean=[];

min_size=min(size(abIdeal_mean));
center=round(min_size/2);
max_size=max(size(abIdeal_mean));
x=linspace(1, max_size, max_size);

data_abIdeal_mean=abIdeal_mean(center,:);
data_abL3_mean=abL3_mean(center,:);
data_delta_E_mean=deltaEim_mean(center,:);

line_abIdeal_mean=data_abIdeal_mean;
line_abL3_mean=data_abL3_mean;
line_deltaE_mean=data_delta_E_mean;

figure
plot(x, data_abIdeal_mean, 'LineWidth',2.5);
hold on;
plot(x, data_abL3_mean, 'r', 'LineWidth',2.5);
plot(x, data_delta_E_mean, 'g', 'LineWidth',2.5);
axis([0, min_size, 0, 150])
xlabel('distance from origin'); ylabel('ab');
title('ab values of mean of ideal and L3')
legend('ab Ideal','ab L3','deltaE')