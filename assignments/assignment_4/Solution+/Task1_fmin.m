%%
n_wt = 15; % number of wind turbines

n_dec = 2*n_wt; % for each wind turbine two coordinates are needed
l_sq = 170; % edge length of the square containing the wind turbines
d_wt = 30;  % min distance between turbines

fmin_opts = optimoptions("fmincon", "MaxFunctionEvaluations", 1e5);

feas_positions = [nchoosek(0:50:l_sq,2)', fliplr(nchoosek(0:50:l_sq,2))', (0:50:l_sq).*[1;1]];
x0 = [reshape(feas_positions(:, randperm(size(feas_positions,2),n_wt)), [], 1)];

sol = fmincon(@wind_power_cost, x0, [], [], [], [], zeros(length(x0),1), ones(length(x0),1)*l_sq, ...
    @(x) distance_constr_fmin(x, d_wt), fmin_opts);

plot(sol(1:2:end-1), sol(2:2:end), 'x')
wind_power_cost(sol)