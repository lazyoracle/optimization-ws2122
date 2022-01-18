clear;
clearvars;

f1 = @(x)(x(1));
f2 = @(x)(x(2));
f = {f1, f2};
weights = [0.5, 0.5];
x0 = [1, 1];
ref = [0.3, 0.3];
eps = 0.5; % x(2) less than equal to 0.5

options = optimoptions("fmincon", "Display", "final-detailed");

ws_problem = get_ws_problem(f, weights, x0, [], [], @subtask1_constraint, options);
rp_problem = get_rp_problem(f, ref, x0, [], [], @subtask1_constraint, options);
eps_problem = get_eps_problem(f, eps, x0, [], [], @subtask1_constraint, options);
disp("Weighted Sum: ")
fmincon(ws_problem)
disp("Reference Point: ")
fmincon(rp_problem)
disp("Epsilon Constraint: ")
fmincon(eps_problem)

function [c, ceq] = subtask1_constraint(x)
        c = norm([x(1) - 1, x(2) - 1]) - 1;
        ceq = [];
end