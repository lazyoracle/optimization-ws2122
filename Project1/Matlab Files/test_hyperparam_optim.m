clearvars;
clear;
clf;

Y_LABEL = "Signal Values";
Y_LABEL_DIFF = "Signal Derivative";
X_LABEL = "Time in s";

load("measurements.mat");

smooth_star = get_optim_smooth(y_raw, t);
disp("Optimum smooth parameter found:");
disp(smooth_star);

y_den = get_optim_signal(y_raw, t, smooth_star);

% Plot denoised signal
subplot(2, 3, 2);
plot(t, y_den)
hold on
plot(t, y)
title("Optimization Filter");
ylabel(Y_LABEL);

% Plot denoised signal derivative
y_den_df = diff(y_den)./diff(t);
y_df = diff(y)./diff(t);
subplot(2, 3, 5);
plot(t(1:end-1), y_den_df)
hold on
plot(t(1:end-1), y_df)
ylabel(Y_LABEL_DIFF);
xlabel("Time in s");

% Conclusion: The obj func for optimizing smooth only looks at
% the signal distance and thus fails to find the best smooth
% that gives both high fidelity and high smoothness. Alternatively, 
% you could give an obj func that looks at the signal derivative
% and this will in turn fail to account for fidelity.
