function visualise_signal_spectrum(T, Fs, signal, only_positive_frequencies, plot_time_signal)
    arguments
        T double
        Fs double
        signal double
        only_positive_frequencies logical = false
        plot_time_signal logical = false
    end

    window_size = round(T*Fs, 3);
    number_of_windows = floor(length(signal)/window_size);

    % Compute the spectrum for each window
    spectrum = zeros(window_size, number_of_windows);
    for i = 1:number_of_windows-1
        window = signal((i-1)*window_size+1:i*window_size);
        fft_window = fft(window);
        spectrum(:, i) = abs(fft_window); %(1:window_size/2+1));
    end

    if plot_time_signal
        % show the signal
        figure;
        plot(signal);
    end

    % show the spectrum
    f_lim = [0, Fs/2];
    t_lim = [0, length(signal)/Fs];

    figure;
    if ~only_positive_frequencies
        print("visualise_signal_spectrum() : negative frequencies not supported anymore")
    end

    imagesc(t_lim, f_lim, spectrum(1:ceil(size(spectrum, 1)/2), :));
    xlabel("Time (s)");
    ylabel("Frequency (Hz)");
end