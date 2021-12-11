function [c,ceq] = non_lin_constraint(y, t)
    % Nonlinear inequality constraints
    dydt = abs(diff(y)./diff(t));
    c = dydt - ones(size(dydt));
    % Nonlinear equality constraints
    ceq = [];
end