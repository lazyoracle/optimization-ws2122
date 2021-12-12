function optim_signal = get_optim_signal(y_raw, t)
    meas_size = size(y_raw);
    y_den_0 = zeros(meas_size);
    options = optimoptions("fmincon", "Display", "final-detailed", ...
        "OptimalityTolerance", 1e-15, ...
        "MaxFunctionEvaluations", 1e5, ...
        "ConstraintTolerance", 1e-15, ...
        "StepTolerance", 1e-15, ...
        "EnableFeasibilityMode", true);
    
    % A & B matrix for linear inequality constraint
    % We need (f(y2) - f(y1)) / (t2 - t1) <= 1
    % or f(y2) - f(y1) <= t2 - t1
    % We also need (f(y1) - f(y2)) / (t2 - t1) <= 1
    % A matrix can thus be the forward difference and
    % backward difference operator augmented together
    % b matrix can be diff(t) augmented with itself
    b = diff(t);
    b(end + 1) = t(end); % diff(t) is one elem smaller
    b = [b b]; % augment b with itself

    A = zeros(2 * meas_size(2), meas_size(2));
    m_max = size(A, 1);
    n_max = size(A, 2);
    for m = 1: m_max
        for n = 1:n_max
            if n == m
                A(m, n) = -1;
            elseif n == m+1
                A(m, n) = 1;
            elseif m > n_max
                if (m - n_max) == n
                    A(m, n) = 1;
                elseif (m - n_max)+1 == n
                    A(m, n) = -1;
                end
            end
        end
    end
    A = sparse(A);

    optim_signal = fmincon(@(y_den)denoise_obj(y_den,y_raw), ...
        y_den_0, A, b, [], [], [], [], [], ...
        options);
end