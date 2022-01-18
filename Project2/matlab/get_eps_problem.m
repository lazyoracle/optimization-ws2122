function eps_problem = get_eps_problem(cost_fun, eps, x0, lb, ub, nonlcon, options)
    cost_fun1 = cost_fun{1};
    cost_fun2 = cost_fun{2};

    function [c,ceq] = constraint(x)
        c(1) = cost_fun2(x) - eps; % eps-constraint as nonlcon
        if isempty(nonlcon) == 0
            c(2) = nonlcon(x); % nonlcon for the original problem
        end
        ceq = [];
    end

    eps_problem.objective = cost_fun1;
    eps_problem.x0 = x0;
    eps_problem.solver = 'fmincon';
    eps_problem.lb = lb;
    eps_problem.ub = ub;
    eps_problem.nonlcon = @constraint;    
    eps_problem.options = options;
end