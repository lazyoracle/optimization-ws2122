function reg = get_regularization(y)
    % L2 Regularization
    reg = sum(diff(y).^2, 'all');
end