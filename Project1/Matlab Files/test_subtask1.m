clear;
clearvars;

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