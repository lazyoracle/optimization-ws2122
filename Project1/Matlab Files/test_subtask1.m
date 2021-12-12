clear;
clearvars;
clf;

x_0 = [2 0];
delta = 0.01;
N = 2001;
x_star_noise = load("x_star_noise.mat");

%delta is the time step size, N number of measurements
sim_param = {x_0, delta, N, x_star_noise};
param_0 = [2;4;0.1]; %inital guess for parameters

options = optimoptions('fminunc', ...
    'Display','final-detailed', ...
    'OptimalityTolerance', 1e-5);
opt_fun = @(param)get_residuum(param, sim_param); 
[param_star, fval] = fminunc(opt_fun, param_0, options);

disp("Best params:");
disp(param_star);

x_sim_star = gen_sim_data(param_star(1), ...
    param_star(2), param_star(3), ...
    x_0, delta, N);

subplot(2, 1, 1);
plot(x_sim_star(1,:))
hold on
plot(x_star_noise.x_star_noise(:,1))
title("Estimated and Measured x");
legend('Estimated', 'Measured');

subplot(2, 1, 2);
plot(x_sim_star(2,:))
hold on
plot(x_star_noise.x_star_noise(:,2))
title("Estimated and Measured x'");
legend('Estimated', 'Measured');