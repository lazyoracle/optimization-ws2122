function obj = denoise_obj(y_den, y_raw)
    J1 = get_signal_distance(y_den, y_raw);
    J2 = get_regularization(y_den);
    obj = (0.3 * J1) + (0.7 * J2);
end