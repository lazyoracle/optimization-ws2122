function [signal_filtered] = easy_low_pass(signal,weighting)
% EASY_LOW_PASS calculates the output of a discrete low-pass filter. It is
% realized as the weighted sum of he current output and the coming
% measurement.
% signal: signal to be filtered
% weighting: weights how much the coming measurements impacts the filter's
% output. 
% weight = 0: no filtering 
% weight = 1: only initial value is put out


signal_filtered = signal(1);
for s = signal(2:end)
    signal_filtered = [signal_filtered, weighting*signal_filtered(end) + (1-weighting)*s];
end
end

