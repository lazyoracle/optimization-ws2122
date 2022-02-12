function cost = wind_power_cost(pos_vec)

posx = pos_vec(1:2:end-1, :);
posy = pos_vec(2:2:end, :);
d = 20;
w = 0.6;
u0 = 12;
% sigma = @heaviside; %step function, diff switch = @(x) 1/pi*(atan(100*x)+pi/2) also possible
sigma = @(x) 1/pi*(atan(100*x)+pi/2);
cx_intens = @(x, xi) sigma(x - xi).*(exp(-((x - xi).^2)/2e4)); 
cy_intens = @(y, yi) exp(-(y - yi).^2/(2*d^2));

% reshape to 3D-tensor to handle all differences at once
ci_intens = @(x, y) cx_intens( x, reshape(posx', 1, size(pos_vec,2), [])).*cy_intens( y, reshape(posy', 1, size(pos_vec,2), []) );
c_intens = @(x, y) sum(ci_intens(x, y), 3);

u_i = u0*w.^c_intens(posx, posy);

delta = @(u_i,a,b) sigma(u_i-a) - sigma(u_i-b);
P_i = @(u_i) delta(u_i,3,11.6) .* (21401*u_i.^2 - 17154*u_i - 143481) + ...
           sigma(u_i-11.6)   * 2533000;
cost = -sum(P_i(u_i), 1);
end