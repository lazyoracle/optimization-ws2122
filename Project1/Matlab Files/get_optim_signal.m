function optim_signal = get_optim_signal(y_raw, t)
    meas_size = size(y_raw);
    y_den_0 = zeros(meas_size);
    options = optimoptions("fmincon", "Display", "final-detailed", ...
        "OptimalityTolerance", 1e-10, ...
        "MaxFunctionEvaluations", 1e5);
    
    % A & B matrix for linear inequality constraint
    % We need (f(y2) - f(y1)) / (t2 - t1) <= 1
    % or f(y2) - f(y1) <= t2 - t1
    % A matrix can thus be the forward difference operator
    % b matrix can be diff(t) with some shape adjustments
    b = diff(t);
    b(end + 1) = t(end);
    A = - eye(meas_size(2));
    for m = 1:meas_size(2)
        for n = 1:meas_size(2)
            if n == m+1
                A(m, n) = 1;
            end
        end
    end


    optim_signal = fmincon(@(y_den)denoise_obj(y_den,y_raw), ...
        y_den_0, A, b, [], [], [], [], [], ...
        options);
end