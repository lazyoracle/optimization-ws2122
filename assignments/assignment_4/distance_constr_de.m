function [constr_violations, constr_value] = distance_constr_de(dec_vars, d_wt, l_sq)

pos = reshape(dec_vars, 2, [], size(dec_vars, 2));

combinations = nchoosek(1:size(pos,2),2);
dists_ = vecnorm(pos(:,combinations(:,1),:) - pos(:,combinations(:,2),:),2,1);
dists = reshape(dists_, size(dists_,2), size(dists_,3));

room_to_breath = dists >= d_wt;

on_property = all((0 <= dec_vars) & (dec_vars <= l_sq), 1);

constr_violations = sum(~[on_property; room_to_breath], 1);

end