function dxdt = spring_diff(t,x,m,k,d)
    dxdt = zeros(2, 1);
    dxdt(1) = x(2);
    dxdt(2) = ((-k/m) * x(1)) + ((-d/m) * x(2));
end