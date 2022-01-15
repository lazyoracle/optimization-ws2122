function eps = get_epsilons(up, np, idx, n, scaling_fh)
% Generates the epsilons as intermediate points between the highest and
% lowest values of the constrained cost function. This is done by
% transforming the numbers between 0 and 1.
% up: utopian point
% np: nadir point
% idx: idx of the cost function to be constrained
% n: number of points to be found
% scaling_fh: function handle to shift the intermediate points for more
% even distribution. To see the effect:
% plot(linspace(0,1,n), ones(1,n)*0, '+', linspace(0,1,n).^2, ones(1,n)*1, 'x', linspace(0,1,n).^0.4, ones(1,n)*-1, 'o')


discretization = linspace(0,1,n);

if nargin == 5
    discretization = scaling_fh(discretization);
end

eps = discretization*(np(idx) - up(idx)) + up(idx);

end

