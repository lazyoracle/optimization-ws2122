clearvars

n_wt = 15; % number of wind turbines

n_dec = 2*n_wt; % for each wind turbine two coordinates are needed
l_sq = 170; % edge length of the square containing the wind turbines
d_wt = 30;  % min distance between turbines

%% DE parameters
use_feasible_solution = false; % initialize population with one feasible solution?
n_mem                 = 20; % number of members for each generation, 20 <= n_mem <= 100
constraint_compliance = "none";   % Select if and how to handle wind turbines leaving the square
                                  % Possible values: "none", "border" or "flip"

donor_style = 'rand'; % Select if the first point of the DE mutation is a random point ('rand') or the best 
                      % individuum ('best')

don_probabability     = 0.4; % probability of interchanging values with the donor vector
F                     = @(x) randn(1,n_mem).^2; % scaling factor of DE
% F                   = @(x) 0.35*ones(1,n_mem);

% stopping criterion is a min number of evolutions, a relative enhancement
% over the last 1000 iterations and a max number of evolutions
stopping_criterion    = @(nEvo, b) (nEvo > 8e3 && abs((b(end-999)-b(end))/b(end)) <= 0.001) || nEvo > 5e4;

%% Initialize population
if use_feasible_solution
    % find a set of feasible positions so that at least one feasible individuum
    % is in the set.
    feas_positions = [nchoosek(0:50:l_sq,2)', fliplr(nchoosek(0:50:l_sq,2))', (0:50:l_sq).*[1;1]];
    decvars = [reshape(feas_positions(:, randperm(size(feas_positions,2),n_wt)), [], 1), unifrnd(0, l_sq, n_dec, n_mem-1)];
else
    decvars = [unifrnd(0, l_sq, n_dec, n_mem)];
end
fitness = wind_power_cost(decvars);
constr_violations = distance_constr_de(decvars, d_wt, l_sq);

%%
nEvolutions = 0;

best_fitness = [];
%do evolutions until stopping criterion is fulfilled
while ~stopping_criterion(nEvolutions, best_fitness)
    
    % randomly select vectors for generating the donor vector
    donor_parents = zeros(3, n_mem);
    for iMember = 1:n_mem
        available = setdiff(1:n_mem, iMember);
        donor_parents(1:3, iMember) = available(randperm(n_mem-1, 3))';
    end
    
    switch donor_style
        case 'rand'
            donor_points = decvars(:, donor_parents(1,:));
        case 'best'
            donor_points = decvars(:, best_idx);
    end

    % build the donor vector
    donor_vectors = donor_points + F().*(decvars(:, donor_parents(2,:)) - decvars(:, donor_parents(3,:)));
    
    % select the positions where the donor vector donates his values
    donate = rand(n_dec, n_mem) < don_probabability;
    donate(randi(n_dec), all(donate == 0,1)) = 1;
    
    % build offspring
    offspring = decvars .* (~donate) + donor_vectors .* (donate);

    % prevent constraint violations if a wind turbine leaves the square
    % or make it flip along the borders
    switch constraint_compliance
        case "border"
             % push an infeasible solution back into the square
             offspring = min(max(offspring, 0), l_sq);
        case "flip"
            % if a turbine exits the square to one side, it enters the square
            % again on the other side of the square (like in Pac-Man)
            offspring(offspring < 0) = mod(offspring(offspring < 0), l_sq);
            offspring(offspring > l_sq) = mod(offspring(offspring > l_sq), l_sq);
        otherwise
    end  

    offspring_fitness = wind_power_cost(offspring);
    offspring_violations = distance_constr_de(offspring, d_wt, l_sq);

    % Did the offspring reduce the number of violations?
    reduced_violations = offspring_violations < constr_violations;
    same_violations    = offspring_violations == constr_violations;

    % Replace the parent if its offspring has either less constraint
    % violations or the same, but an equal or lower fitness value.
    replace = reduced_violations | (same_violations & offspring_fitness <= fitness);

    decvars = [decvars(:, ~replace) offspring(:, replace)];

    % calculate fitness and number of violated constraints
    fitness = [fitness(:, ~replace) offspring_fitness(:, replace)];
    constr_violations = [constr_violations(:, ~replace) offspring_violations(:, replace)];
    
    % select the best individuum
    lowest_constr_value_idc = find(constr_violations == min(constr_violations));
    [~, lowest_fitness_idx] = min(fitness(lowest_constr_value_idc));
    best_idx = lowest_constr_value_idc(lowest_fitness_idx);
    best_fitness = [best_fitness, fitness(best_idx)];

    % plot the positions of the currently best individuum
    if mod(nEvolutions, 100) == 0
        plot(decvars(1:2:end-1, best_idx), decvars(2:2:end, best_idx), 'x')
        xlim([0, l_sq])
        ylim([0, l_sq])
        title("Episode: " + nEvolutions + ", fitness: " + fitness(best_idx) + ", constr: " + constr_violations(best_idx))
        drawnow
    end

    nEvolutions = nEvolutions + 1;
end