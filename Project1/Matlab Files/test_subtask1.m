clear;
clearvars;

x_0 = [2 0];
delta = 0.01;
N = 2001;
x_star_noise = load("x_star_noise.mat");

sim_param = {x_0, delta, N, x_star_noise}; %delta is the time step size, N number of measurements
param_0 = [2;4;0.1]; %inital guess for parameters

get_residuum(param_0, sim_param)

% opt_fun = @(param)get_residuum(param,sim_param); 
% [param_star,fval] = fminunc(opt_fun,param_0);