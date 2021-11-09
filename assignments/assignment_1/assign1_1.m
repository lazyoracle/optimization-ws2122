clear;
sympref('FloatingPointOutput',true);

a = 5;
b = 3;
gamma = 3;
x = sym('x', [1 1])
f(x) = 0.5 * (((x(1, 1) - a)/gamma)^2 + (x(1, 1) - b)^2)
% dfx = diff(f, x(1, 1)) + diff(f, x(1, 1))
dfx = diff(f)

x_next = 0 ;
fchanges = {};
fvals = [f(x_next)];

for i = 1:10
    x_now = x_next;
    x_next = steep(f, dfx, x_next);
    fval = f(x_next);
    fvals = [fvals, fval];
    fchange = f(x_now) - f(x_next);
    fchanges = [fchanges, fchange];
end

subplot(2, 1, 1);
plot(fvals);
title("Optimization");

subplot(2, 1, 2);
plot(fchanges);
title("Convergence");

x_next