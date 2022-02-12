clearvars

n_wt  = 15; % number of wind turbines

n_dec = 2*n_wt; % for each wind turbine two coordinates are needed
l_sq  = 170; % edge length of the square containing the wind turbines
d_wt  = 30;  % min distance between turbines

%% DE parameters
use_feasible_solution = true; % initialize population with one feasible solution?
n_mem                 = 50; % number of members for each generation, 20 <= n_mem <= 100
constraint_compliance = "border";   % Select if and how to handle wind turbines leaving the square
                                  % Possible values: "none", "border" or "flip"

use_personal_best     = true;
personal_best_factor  = 0.2;

use_current_best      = true;
current_best_factor   = 0.4;

use_historical_best   = true;
historical_best_factor= 0.5;

use_random            = true;
random_factor         = 0.4;

intertia              = 0.8;

% stopping criterion is a min number of evolutions, a relative enhancement
% over the last 1000 iterations and a max number of evolutions
stopping_criterion    = @(nEvo, b, fit) (nEvo > 8e3 && abs((b(end-999)-b(end))/b(end)) <= 0.001) || nEvo > 5e4 || ...
    abs((min(fit)-max(fit))/min(fit)) < 0.0001 ;

%% Initialize population
if use_feasible_solution
    % find a set of feasible positions so that at least one feasible individuum
    % is in the set.
    feas_positions = [nchoosek(0:50:l_sq,2)', fliplr(nchoosek(0:50:l_sq,2))', (0:50:l_sq).*[1;1]];
    decvars = [reshape(feas_positions(:, randperm(size(feas_positions,2),n_wt)), [], 1), unifrnd(0, l_sq, n_dec, n_mem-1)];
else
    decvars = [unifrnd(0, l_sq, n_dec, n_mem)];
end
velocity = zeros(n_dec, n_mem);

fitness = wind_power_cost(decvars);
constr_value = distance_constr_de(decvars, d_wt, l_sq);

if use_personal_best
    personal_best    = decvars;
    personal_fitness = fitness;
    personal_constr  = constr_value;
end

if use_historical_best
    historical_best         = struct;
    historical_best.dec     = []; %vars(:, global_best_idx);
    historical_best.fitness = []; %fitness(global_best_idx);
    historical_best.constr  = []; %constr_value(global_best_idx);
end

%%
nEvolutions = 0;

best_fitness = [];
%do evolutions until stopping criterion is fulfilled
while ~stopping_criterion(nEvolutions, best_fitness, fitness)
    tic
    % randomly select vectors for generating the donor vector
    velocity = intertia*velocity;

    if use_personal_best
        [personal_best, personal_fitness, personal_constr] = set_personal_best(personal_best, personal_fitness,...
            personal_constr, decvars, fitness, constr_value);
        velocity = velocity + personal_best_factor * (personal_best - decvars).*rand(n_dec, n_mem);
    end
    
    if use_current_best
        current_best_idx = find_best(fitness, constr_value);
        velocity = velocity + current_best_factor * (decvars(:, current_best_idx) - decvars).*rand(n_dec, n_mem);
    end
    
    if use_random
        velocity = velocity + random_factor * randn(n_dec, n_mem);
    end

    if use_historical_best
        historical_best = set_historical_best(decvars, fitness, constr_value, historical_best);
        velocity = velocity + historical_best_factor * (historical_best.dec - decvars).*rand(n_dec, n_mem);
    end
    
    % build offspring
    decvars = decvars + velocity;

    % prevent constraint violations if a wind turbine leaves the square
    % push it back into it or make it flip along the borders

    switch constraint_compliance
        case "border"
             decvars = min(max(decvars, 0), l_sq);
        case "flip"
            decvars(decvars < 0) = mod(decvars(decvars < 0), l_sq);
            decvars(decvars > l_sq) = mod(decvars(decvars > l_sq), l_sq);
        otherwise
    end  
    
    fitness = wind_power_cost(decvars);
    best_fitness = [best_fitness, min(fitness)];
    constr_value = distance_constr_de(decvars, d_wt, l_sq);

    % plot the positions of the currently best individuum
    if mod(nEvolutions, 100) == 0
        best_idx = find_best(fitness, constr_value);
        plot(decvars(1:2:end-1, best_idx), decvars(2:2:end, best_idx), 'x')
        xlim([0, l_sq])
        ylim([0, l_sq])
        title("Episode: " + nEvolutions + ", fitness: " + fitness(best_idx) + ", constr. violations: " ...
            + constr_value(best_idx))
        drawnow
    end

    nEvolutions = nEvolutions + 1;
end

disp(historical_best)

%%
function best_idx = find_best(fitness, constr_values)
    current_min_constr       = find(constr_values == min(constr_values));
    [~, current_min_fitness] = min(fitness(current_min_constr));
    best_idx                 = current_min_constr(current_min_fitness);
end

%%
function historical_best = set_historical_best(decvars, fitness, constr_values, historical_best_struct)
    all_dec = [decvars, historical_best_struct.dec];
    all_constr  = [constr_values, historical_best_struct.constr];
    all_fitness = [fitness, historical_best_struct.fitness];
    global_best_idx = find_best(all_fitness, all_constr);
    
    historical_best         = struct;
    historical_best.dec     = all_dec(:, global_best_idx);
    historical_best.fitness = all_fitness(global_best_idx);
    historical_best.constr  = all_constr(global_best_idx);
end

%%
function [personal_best, personal_fitness, personal_constr] = set_personal_best(current_personal_best, ...
    current_personal_fitness, current_personal_constr, decvars, fitness, constr_value)

    replace          = (current_personal_fitness >= fitness) & (current_personal_constr >= constr_value);
    personal_best    = current_personal_best.*(~replace) + decvars.*replace;
    personal_fitness = current_personal_fitness.*(~replace) + fitness.*replace;
    personal_constr  = current_personal_constr.*(~replace) + constr_value.*replace;

end