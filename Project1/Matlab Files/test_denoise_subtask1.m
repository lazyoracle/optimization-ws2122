clc;
clear;
clearvars;
clf;

%% Apply the Optimization Filter from task 2 to task 1 data

SMOOTH = 0.8;

x_star_noise = load("x_star_noise.mat").x_star_noise;
position = x_star_noise(:,1)';
velocity = x_star_noise(:,2)';
t = linspace(1, size(position, 2), size(position, 2));

position_den = get_optim_signal(position, t, SMOOTH);
velocity_den = get_optim_signal(velocity, t, SMOOTH);

subplot(2, 1, 1);
plot(t, position_den)
hold on
plot(t, position)
title("Position")
legend("Denoised", "Original")

subplot(2, 1, 2);
plot(t, velocity_den)
hold on
plot(t, velocity)
title("Position")
legend("Denoised", "Original")