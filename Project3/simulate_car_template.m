%% Initialization
close all
nNodes        = ...; % number of shooting nodes 
nSteps        = ...; % number of intermediate multiple shooting steps
T_max         = ...; % max time to reach the goal

%% Setting up the problem
opt = casadi.Opti();
opt.solver('ipopt')
T = opt.variable(1);

x0  = ...;
x   = [x0, opt.variable( 5, nNodes-1 )];
u   = opt.variable( ..., (nNodes-1) * (nSteps+1) );
dt  = T / ((nNodes-1) * (nSteps+1));

%% setting the equality constraints for dynamics
for iStep = 1:(nNodes-1)
    initial_step = (nSteps+1) * (iStep-1)+1;
    opt.subject_to( ms_step(x(:,iStep), u(:, initial_step:(initial_step + nSteps)), dt) == x(:,iStep+1) )
end

%% box constraints
...
opt.subject_to( 1 <= T <= T_max )

%% add cost functions
cost_u = ...;
cost = [T, cost_u];

opt.minimize(...);
sol = opt.solve();

x_val = sol.value(x);
u_val = sol.value(u);


%% Plotting
figure
title("position")
plot(x_val(1,:), x_val(2,:), 'LineWidth', 2)
grid on

figure
title("inputs")
stairs(0:sol.value(dt):sol.value(T-dt), u_val', 'LineWidth', 2)
legend("$u_1$", "$u_2$", 'Interpreter', 'latex')
grid on

%%
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
    xdot = [...];
end

