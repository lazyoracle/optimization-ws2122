function [c, ceq] = distance_constr_fmin(dec_vars, d_wt)

ceq = [];

pos = reshape(dec_vars, 2, [], size(dec_vars, 2));

combinations = nchoosek(1:size(pos,2),2);
dists = vecnorm(pos(:,combinations(:,1),:) - pos(:,combinations(:,2),:),2,1).^2;

c = d_wt^2 - dists;

end