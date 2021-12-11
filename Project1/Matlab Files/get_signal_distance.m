function sq_dist = get_signal_distance(y_raw, y_den)
    err = y_raw - y_den;
    sq_dist = sum(err.^2, 'all');
end