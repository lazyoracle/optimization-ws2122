function obj = smooth_obj(smooth, t, y_raw)
    % objective function for finding best smooth
    % Either use signal distance or derivative
    y_den = get_optim_signal(y_raw, t, smooth);
    obj = get_signal_distance(y_den, y_raw);
    % obj = diff(y_den)./diff(t);
end