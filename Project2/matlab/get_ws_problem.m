function ws_problem = get_ws_problem(cost_fun, weights, x0, lb, ub, nonlcon, options)
    cost_fun1 = cost_fun{1, 1};
    cost_fun2 = cost_fun{1, 2};
    weighted_sum = @(x) weights(1) * cost_fun1(x) + weights(2) * cost_fun2(x);
    ws_problem.objective = weighted_sum;
    ws_problem.x0 = x0;
    ws_problem.solver = 'fmincon';
    ws_problem.lb = lb;
    ws_problem.ub = ub;
    ws_problem.nonlcon = nonlcon;
    ws_problem.options = options;



    