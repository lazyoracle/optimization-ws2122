%% Initialization
close all
nNodes        = 60; % number of shooting nodes 
nSteps        = 1; % number of intermediate multiple shooting steps
T_max         = 20; % max time to reach the goal

%% Setting up the problem
opt = casadi.Opti();
opt.solver('ipopt')
T = opt.variable(1);

x0  = [0; 0; 0; -2.3562; 0]; % provide initial conditions
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
opt.subject_to( (-pi/4) <= x(5, :) <=  (pi/4));
opt.subject_to( (-pi/9) <= u(2, :) <= (pi/9));
opt.subject_to( x(3, :) >= (-0.2));
opt.subject_to( x(1, :) <= 7.1);
opt.subject_to(  (-10) <= u(1, :) <= 5);
opt.subject_to( 1 <= T <= T_max );

%% boundary constraints
opt.subject_to(x(1, end) == 7); % final x position
opt.subject_to(x(2, end) == 5); % final y position
opt.subject_to(x(3, end) == 0); % standing still at end
opt.subject_to(x(4, end) == (pi/2)); % final angle

%% Obstacle at (x, y) of radius r
obstacle_x = 4;
obstacle_y = 0;
obstacle_r = 1;
obstacle_buff = 0.2;
obstacle_loc = (x(1, :) - obstacle_x).^2 + (x(2, :) - obstacle_y).^2;
obstacle_constant = ((obstacle_r + obstacle_buff)^2 + zeros(size(x(1,:))));
opt.subject_to(obstacle_loc >= obstacle_constant) ;

%% add cost functions
cost_u = 0.5 * sum(u(1,:).^2);
cost = [T, cost_u];

%% Parameterize
weight = opt.parameter(1);

%% Cost Function
opt.minimize(((1 - weight) * cost(1)) + (weight * cost(2)));

%% Solve Parameterized Multi-Objective OCP
num_pareto_points = 15; % Set to ~20 for smooth plots
mid = floor(num_pareto_points/2);
plot_idx = [1, mid, num_pareto_points];
weights = linspace(0, 1, num_pareto_points);
cost_values = zeros(2, num_pareto_points);

for idx = 1:num_pareto_points
    opt.set_value(weight, weights(idx))
    sol = opt.solve();
    x_val = sol.value(x);
    u_val = sol.value(u);
    cost_values(1, idx) = sol.value(T);
    cost_values(2, idx) = 0.5 * sum(u_val(1,:).^2);
    %% Plotting - Single Output
    if sum(plot_idx==idx)>0
        figure
        hold on
        subplot(1, 2, 1);
        plot(x_val(1,:), x_val(2,:), 'LineWidth', 2)
        time_txt = ["Total Time: " num2str(cost_values(1, idx))];
        energy_txt = ["Total Energy: ", num2str(cost_values(2, idx))];
        text(5, 4, time_txt);
        text(5, 1, energy_txt);
        
        viscircles([obstacle_x, obstacle_y], obstacle_r, ...
                    'Color', 'red', 'LineWidth', 2);
        viscircles([obstacle_x, obstacle_y], obstacle_r+obstacle_buff, ...
                    'Color', '#EDB120', 'LineStyle','--');
        grid on
        title("position")
        hold off
        
        subplot(1, 2, 2);
        stairs(0:sol.value(dt):sol.value(T-dt), u_val', 'LineWidth', 2)
        legend("$u_1$", "$u_2$", 'Interpreter', 'latex')
        grid on
        title("inputs")
    end
end

%% Plotting - Pareto Front
figure
semilogy(cost_values(1, :), cost_values(2, :))
grid on
xlabel("Time")
ylabel("Energy")
text(cost_values(1, 1), cost_values(2, 1), "Minimum Time");
text(cost_values(1, mid), cost_values(2, mid), "Midway between Energy, Time");
text(cost_values(1, end), cost_values(2, end), "Minimum Energy");

title("Pareto Front")

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

