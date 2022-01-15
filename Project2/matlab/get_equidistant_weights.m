function weights = get_equidistant_weights(n)
% Calculates n equidistant weight combinations. To see the effect enable
% the plotting at the end and set a break point.

w = linspace(0,1,n);
weights = [w; 1-w];

% plot(weights(1,:), weights(2,:), 'x')

end