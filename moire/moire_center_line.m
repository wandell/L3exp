function [line_abIdeal, line_abL3, line_deltaE] = moire_center_line(abIdeal,abL3,deltaEim)

%% Horizontal line
data_abIdeal=[];   data_abL3=[];   data_deltaE=[];

min_size=min(size(abIdeal));
center=round(min_size/2);
max_size=max(size(abIdeal));
x=linspace(1, max_size, max_size);

data_abIdeal=abIdeal(center,:);
data_abL3=abL3(center,:);
data_deltaE=deltaEim(center,:);

line_abIdeal=data_abIdeal;
line_abL3=data_abL3;
line_deltaE=data_deltaE;

figure
plot(x, data_abIdeal, 'LineWidth',2.5);
hold on;
plot(x, data_abL3, 'r', 'LineWidth',2.5);
plot(x, data_deltaE, 'g', 'LineWidth',2.5);
axis([0, min_size, 0, 150])
xlabel('distance from origin'); ylabel('ab');
title('ab values of ideal and L3')
legend('ab Ideal','ab L3','deltaE')