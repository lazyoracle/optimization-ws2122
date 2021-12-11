function res = get_residuum(param,sim_param)
    m = param(1);
    k = param(2);
    d = param(3);
    x0 = cell2mat(sim_param(1));
    dt = cell2mat(sim_param(2));
    N = cell2mat(sim_param(3));
    x_star_noise = cell2mat(sim_param(4)).x_star_noise;
    x_sim = gen_sim_data(m, k, d, x0, dt, N);
    errs = x_star_noise - x_sim';
    errr_sq = errs.^2;
    res = sum(sum(errr_sq));
end