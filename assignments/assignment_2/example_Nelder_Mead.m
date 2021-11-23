rosenbrock = @(x) 100*(x(:,2)-x(:,1).^2).^2+(x(:,1)-1).^2;
rosenbrock_plot = @(x, y) 100*(y-x.^2).^2+(x-1).^2;
initial_guess = [-1, -1];
% initial_guess = [-1 -1; 0 1.5; 1.5 1.5]

s = NelderMeadSimplex(initial_guess, rosenbrock);

%%

for i = 1:67
    [s(end+1), action_applied] = s(end).do_step();
    [min_x, min_f] = s(end).get_min();
    disp("Action: " + action_applied + "   min(f(x) " + min_f + "   at x = " + num2str(min_x));
end

%%
figure
fcontour(rosenbrock_plot, [-1.5 1.5 -1.5 1.5])
hold on
s.plot2D();


figure
fsurf(rosenbrock_plot, [-1.5 1.5 -1.5 1.5], 'EdgeColor', 'none', 'FaceAlpha', 0.5)
hold on
s.plotmin();
