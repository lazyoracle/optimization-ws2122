clearvars;
clear;
clf;
load("measurements.mat");
Y_LABEL = "Signal Values";
Y_LABEL_DIFF = "Signal Derivative";
X_LABEL = "Time in s";

% uncomment for a longer dataset
% t2 = t + t(end);
% t = [t t2];
% y = [y y];
% y_raw = [y_raw y_raw];

% Plot noisy signal
subplot(2, 3, 1);
plot(t, y_raw)
hold on
plot(t, y)
title("Noisy Measurement");
ylabel(Y_LABEL);

% Plot noisy signal derivative
y_raw_df = diff(y_raw)./diff(t);
y_df = diff(y)./diff(t);
subplot(2, 3, 4);
plot(t(1:end-1), y_raw_df)
hold on
plot(t(1:end-1), y_df)
ylabel(Y_LABEL_DIFF);
xlabel("Time in s");

% fmincon denoised signal
y_den = get_optim_signal(y_raw, t);

% Plot denoised signal
subplot(2, 3, 2);
plot(t, y_den)
hold on
plot(t, y)
title("Optimization Filter");
ylabel(Y_LABEL);

% Plot denoised signal derivative
y_den_df = diff(y_den)./diff(t);
subplot(2, 3, 5);
plot(t(1:end-1), y_den_df)
hold on
plot(t(1:end-1), y_df)
ylabel(Y_LABEL_DIFF);
xlabel("Time in s");

% Plot lpf signal
y_lpf = easy_low_pass(y_raw, 0.5);
subplot(2, 3, 3);
plot(t, y_lpf)
hold on
plot(t, y)
title("Low-pass Filter");
ylabel(Y_LABEL);

% Plot lpf signal derivative
y_lpf_df = diff(y_lpf)./diff(t);
subplot(2, 3, 6);
plot(t(1:end-1), y_lpf_df)
hold on
plot(t(1:end-1), y_df)
ylabel(Y_LABEL_DIFF);
xlabel("Time in s");