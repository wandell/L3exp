function [line_abIdeal_mean, line_abL3_mean, line_deltaE_mean] = moire_diagonal_processing(abIdeal_mean, abL3_mean, deltaEim_mean)

%% Diagonal line
min_size=min(size(abIdeal_mean));
x=linspace(1, min_size, min_size);

data_abIdeal_mean=[];   data_abL3_mean=[];   data_deltaE_mean=[];
for i=1 : min_size
    data_abIdeal_mean(1,i)=abIdeal_mean(i,i);
    data_abL3_mean(1,i)=abL3_mean(i,i);
    data_deltaE_mean(1,i)=deltaEim_mean(i,i);
end

line_abIdeal_mean=data_abIdeal_mean;
line_abL3_mean=data_abL3_mean;
line_deltaE_mean=data_deltaE_mean;

figure
plot(x, data_abIdeal_mean, 'LineWidth',2.5);
hold on;
plot(x, data_abL3_mean, 'r', 'LineWidth',2.5);
plot(x, data_deltaE_mean, 'g', 'LineWidth',2.5);
axis([0, min_size, 0, 150])
xlabel('distance from origin'); ylabel('ab');
title('ab values of processing of ideal and L3')
legend('ab Ideal pro','ab L3 pro','deltaE pro')