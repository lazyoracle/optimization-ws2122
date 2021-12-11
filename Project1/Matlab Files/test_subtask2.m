clearvars;
clear;
load("measurements.mat");

subplot(2, 3, 1);
plot(t, y_raw)
hold on
plot(t, y)
title("Noisy Measurement");
ylabel("Signal Values");

y_raw_df = diff(y_raw)./diff(t);
y_df = diff(y)./diff(t);

subplot(2, 3, 4);
plot(t(1:end-1), y_raw_df)
hold on
plot(t(1:end-1), y_df)
ylabel("Signal Derivative");
xlabel("Time in s");