clear;
clearvars;
clf;

lb = [-1.2, -1.2];
ub = [1.2, 1.2];
x0 = [0, 0];

f = {@f1, @f2};
options = optimoptions("fmincon", "Display", "off");

% utopian point is the min
up_x1 = fmincon(@f1, x0, [], [], [], [], lb, ub, [], options);
up1 = f1(up_x1);
up_x2 = fmincon(@f2, x0, [], [], [], [], lb, ub, [], options);
up2 = f2(up_x2);
up = [up1, up2];
disp("Utopia Point:" + num2str(up));
% nadir point is the max
g1 = @(x)-f1(x);
g2 = @(x)-f2(x);
np_x1 = fmincon(g1, x0, [], [], [], [], lb, ub, [], options); 
np1 = f1(np_x1);
np_x2 = fmincon(g2, x0, [], [], [], [], lb, ub, [], options); 
np2 = f2(np_x2);
np = [np1, np2];
disp("Nadir Point:" + num2str(np));

extreme_points = [up1, np1;
                  np2, up1];

N = 500; % Number of pareto optimal points

weights = get_equidistant_weights(N);
epsilons = get_epsilons(up, np, 2, N);
refs = get_ref_points(up', extreme_points, (N/2)+1);
refs = sortrows(refs', 1)'; % sort ref points so that plotting isn't messed

% Calculate Pareto Fronts
f1_star = zeros(N, 3);
f2_star = zeros(N, 3);
for idx = 1:N
    ws_problem = get_ws_problem(f, weights(:,idx), x0, lb, ub, [], options);
    x_star_w = fmincon(ws_problem);
    f1_star(idx, 1) = f1(x_star_w);
    f2_star(idx, 1) = f2(x_star_w);
    rp_problem = get_rp_problem(f, refs(:,idx), x0, lb, ub, [], options);
    x_star_r = fmincon(rp_problem);
    f1_star(idx, 2) = f1(x_star_r);
    f2_star(idx, 2) = f2(x_star_r);
    ep_problem = get_eps_problem(f, epsilons(idx), x0, lb, ub, [], options);
    x_star_e = fmincon(ep_problem);
    f1_star(idx, 3) = f1(x_star_e);
    f2_star(idx, 3) = f2(x_star_e);
end

subplot(3, 1, 1);
hold on;
scatter(f1_star(:, 1), f2_star(:, 1), 'o');
xlim([0.5, 3.5]);
ylim([0.5, 3.5]);
xlabel("f1");
ylabel("f2");
scatter(up1, up2, '*');
scatter(np1, np2, '*');
scatter(up1, np2, '*');
scatter(np1, up2, '*');
title("Comparison of Pareto Fronts");
legend("Weighted Sum", ...
        "Utopia Point", "Nadir Point", ...
        "Extreme Point 1", "Extreme Point 2");
hold off

subplot(3, 1, 2);
scatter(f1_star(:, 2), f2_star(:, 2), '+');
xlim([0.5, 3.5]);
ylim([0.5, 3.5]);
xlabel("f1");
ylabel("f2");
legend("Reference Point");

subplot(3, 1, 3);
scatter(f1_star(:, 3), f2_star(:, 3), '*');
xlim([0.5, 3.5]);
ylim([0.5, 3.5]);
xlabel("f1");
ylabel("f2");
legend("Epsilon Constraint");

function obj1 = f1(x)
    a = sqrt(1 + (x(1) + x(2))^2);
    b = sqrt(1 + (x(1) - x(2))^2);
    c = 0.6 * exp(-((x(1) - x(2))^2));
    obj1 = 0.5 * (a + b + x(1) - x(2)) + c;
end

function obj2 = f2(x)
    a = sqrt(1 + (x(1) + x(2))^2);
    b = sqrt(1 + (x(1) - x(2))^2);
    c = 0.6 * exp(-((x(1) - x(2))^2));
    obj2 = 0.5 * (a + b - x(1) + x(2)) + c;
end