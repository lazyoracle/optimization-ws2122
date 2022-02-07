%% Initialization
close all
nNodes        = 20; % number of shooting nodes 
nSteps        = 3; % number of intermediate multiple shooting steps
T_max         = 20; % max time to reach the goal

%% Setting up the problem
opt = casadi.Opti();
opt.solver('ipopt')
T = opt.variable(1);

x0  = opt.variable(5, 1);
x   = [x0, opt.variable( 5, nNodes-1 )];
u   = opt.variable( 2, (nNodes-1) * (nSteps+1) );
dt  = T / ((nNodes-1) * (nSteps+1));

%% setting the equality constraints for dynamics
for iStep = 1:(nNodes-1)
    initial_step = (nSteps+1) * (iStep-1)+1;
    opt.subject_to( ms_step(x(:,iStep), ...
        u(:, initial_step:(initial_step + nSteps)), dt) == x(:,iStep+1) )
end

%% box constraints
opt.subject_to( -45 <= x(5, :) <=  45);
opt.subject_to( -20 <= u(2, :) <= 20);
opt.subject_to( x(3, :) >= -0.2);
opt.subject_to( x(1, :) <= 7.1);
opt.subject_to(  -10 <= u(1, :) <= 5);
opt.subject_to( 1 <= T <= T_max );

%% boundary constraints
opt.subject_to(x(1, 1) == 0); % initial x position
opt.subject_to(x(1, end) == 7); % final x position
opt.subject_to(x(2, 1) == 0); % initial y position
opt.subject_to(x(2, end) == 5); % final y position
opt.subject_to(x(3, 1) == 0); % standing still
opt.subject_to(x(4, 1) == -135); % initial angle
opt.subject_to(x(4, end) == 90); % final angle

%% add cost functions
cost_u = 0.5 * sum(u(1,:).^2);
cost = [T, cost_u];

%% Parameterize
weight = opt.parameter(1);
opt.set_value(weight, 0.8)

opt.minimize(0.2 * cost(1) + 0.8 * cost(2));
sol = opt.solve();

x_val = sol.value(x);
u_val = sol.value(u);


%% Plotting
subplot(1, 2, 1);
plot(x_val(1,:), x_val(2,:), 'LineWidth', 2)
grid on
title("position")

subplot(1, 2, 2);
stairs(0:sol.value(dt):sol.value(T-dt), u_val', 'LineWidth', 2)
legend("$u_1$", "$u_2$", 'Interpreter', 'latex')
grid on
title("inputs")

%% ODE Solver
function x_end = ms_step(x0, u_series, dt)
% calculate one multiple shooting step with step size dt
import casadi.*

x0_rk = x0;
k = casadi.MX( size( x0, 1 ), 4 );

for i = 1:size( u_series, 2 )
    k(:,1) = robot_ode(x0_rk(:,end), u_series(:,i));
    k(:,2) = robot_ode(x0_rk(:,end) + dt / 2 * k(:,1), u_series(:,i));
    k(:,3) = robot_ode(x0_rk(:,end) + dt / 2 * k(:,2), u_series(:,i));
    k(:,4) = robot_ode(x0_rk(:,end) + dt * k(:,3), u_series(:,i));
    x0_rk  = [x0_rk, x0_rk(:,end) + dt / 6 * k * [1 2 2 1]'];
end

x_end = x0_rk(:, end);
end  

%% ode
function xdot = robot_ode(x, u)
    xdot = [x(3)*cos(x(4) + x(5)), ...
            x(3)*sin(x(4) + x(5)), ...
            u(1), ...
            x(3)*sin(x(5)), ...
            u(2)];
end

