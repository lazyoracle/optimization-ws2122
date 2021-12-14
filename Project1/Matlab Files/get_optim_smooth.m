function optim_smooth = get_optim_smooth(y_raw, t)
    % get optimum value of the smooth hyperparameter
    options = optimoptions("fmincon", "Display", "final-detailed", ...
        "OptimalityTolerance", 1e-15, ...
        "MaxFunctionEvaluations", 1e5, ...
        "ConstraintTolerance", 1e-15, ...
        "StepTolerance", 1e-15, ...
        "EnableFeasibilityMode", true);

    smooth_0 = 0.9;

    optim_smooth = fmincon(@(smooth)smooth_obj(smooth, t, y_raw), ...
        smooth_0, [], [], [], [], ...
        0, 1, [], options);
end