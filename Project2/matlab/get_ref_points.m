function ref_points = get_ref_points(up, ep, n)
% Generates reference points for the reference point method on the lines
% connecting the utopia point to both extreme points.
% up: utopia point as a 2-by-1 vector
% ep: matrix with both extreme points as 2-by-1 vectors als columns
% n: number of points per extreme point
% ref_points: 2-by-(2n-1) matrix with reference points as 2-by-1 vectors in
% columns

w = linspace(0,1,n);
ref_points = ep(:,1)*(1-w) + up*w;
ref_points = [ref_points, ep(:,2)*(1-w(1:end-1)) + up*w(1:end-1)];
end