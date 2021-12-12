function obj = denoise_obj(y_den, y_raw, smooth)
    % smooth controls the weighing of J1 and J2
    % smooth should be between (0, 1) 
    J1 = get_signal_distance(y_den, y_raw);
    J2 = get_regularization(y_den);
    obj = ((1 - smooth) * J1) + (smooth * J2);
end