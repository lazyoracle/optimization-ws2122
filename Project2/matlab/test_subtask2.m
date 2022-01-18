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
disp("Utopian Point:" + num2str([up1, up2]));
% nadir point is the max
g1 = @(x)-f1(x);
g2 = @(x)-f2(x);
np_x1 = fmincon(g1, x0, [], [], [], [], lb, ub, [], options); 
np1 = f1(np_x1);
np_x2 = fmincon(g2, x0, [], [], [], [], lb, ub, [], options); 
np2 = f2(np_x2);
disp("Nadir Point:" + num2str([np1, np2]));

N = 10; % Number of pareto optimal points

weights = get_equidistant_weights(N);

f1_star = zeros(N, 1);
f2_star = zeros(N, 1);
for idx = 1:N % use parfor if N>100, Parallel Computing Toolbox required
    ws_problem = get_ws_problem(f, weights(:,idx), x0, lb, ub, [], options);
    x_star = fmincon(ws_problem);
    f1_star(idx) = f1(x_star);
    f2_star(idx) = f2(x_star);
end

% subplot(3, 1, 1);
plot(f1_star, f2_star)
title("Weighted Sum");
legend('pareto');
xlabel("f1");
ylabel("f2");
text(up1, up2, "Utopian Point");
text(np1, np2, "Nadir Point");

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