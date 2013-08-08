function [line_abIdeal, line_abL3, line_deltaE, line_L3_Ideal] = moire_diagonal(abIdeal,abL3,deltaEim)

%% Diagonal line
min_size=min(size(abIdeal));
x=linspace(1, min_size, min_size);

data_abIdeal=[];   data_abL3=[];   data_deltaE=[]; data_L3_Ideal=[];
for i=1 : min_size
    data_abIdeal(1,i)=abIdeal(i,i);
    data_abL3(1,i)=abL3(i,i);
    data_deltaE(1,i)=deltaEim(i,i);
    data_L3_Ideal(1,i)=abL3(i,i)-abIdeal(i,i);
end

line_abIdeal=data_abIdeal;
line_abL3=data_abL3;
line_deltaE=data_deltaE;
line_L3_Ideal=data_L3_Ideal;

figure
plot(x, data_abIdeal, 'LineWidth',2.5);
hold on;
plot(x, data_abL3, 'r', 'LineWidth',2.5);
plot(x, data_deltaE, 'g', 'LineWidth',2.5);
plot(x, data_L3_Ideal, 'm', 'LineWidth',2.5);
axis([0, min_size, 0, 150])
xlabel('distance from origin'); ylabel('ab');
title('ab values of ideal and L3 and L3_Ideal')
legend('ab Ideal','ab L3','deltaE', 'L3_Ideal')