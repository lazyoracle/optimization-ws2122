clear;
clearvars;
clf;

lb = [-1.2, -1.2];
ub = [1.2, 1.2];
x0 = [0, 0];

f = {@f1, @f2};

% utopian point is the min
up_x = fmincon(@f2, x0, [], [], [], [], lb, ub);
up = f2(up_x);
disp("Utopian Point:" + num2str(up));
% nadir point is the max
g2 = @(x)-f2(x);
np_x = fmincon(g2, x0, [], [], [], [], lb, ub); 
np = f2(np_x);
disp("Nadir Point:" + num2str(np));

weights = get_equidistant_weights(10);
options = optimoptions("fmincon", "Display", "off");

for idx = 1:5
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