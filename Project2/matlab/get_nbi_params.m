function [starting_points, normal_vector] = get_nbi_params(ep, n)
% Calculate the hyperparameters for Pascoletti-Serafini with the
% Normal-Boundary-Intersection scheme. NOTE: Only works for k = 2!
% ep: matrix of extreme points with the extreme points being 2-by-1 vectors 
% n: number of Pareto optimal solutions

w = linspace(0,1,n);
starting_points = ep(:,1)*(1-w) + ep(:,2)*w;
normal_vector = [0 -1; 1 0]*(ep(:,1)-ep(:,2));
if normal_vector(1) > 0
    normal_vector = -normal_vector;
end

end