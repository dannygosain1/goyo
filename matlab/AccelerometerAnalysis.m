function [ ] = AccelerometerAnalysis( twwalker )
    % Shows graph of acceleration in Z and Y directions along with the Fourier
    % transform

    z_accel = (twwalker(:,3));
    y_accel = (twwalker(:,2));

    sampling_rate = 10;
    dt = 1/sampling_rate;
    t = (0:dt:length(z_accel)/10 - 0.1)';
    N = length(t);

    Z = fftshift(fft(z_accel));
    Y = fftshift(fft(y_accel));
    dF = sampling_rate/N;
    %f = -sampling_rate/2:dF:sampling_rate/2-dF;
    f = -sampling_rate/2:dF:sampling_rate/2-dF;
    
    figure;
    subplot(2,2,1)
    stem(f,abs(Z));
    xlabel('Frequency)');
    title('Magnitude Response of Z');
    subplot(2,2,2);
    plot(z_accel)
    title('Z Acceleration');
    subplot(2,2,3);
    stem(n,abs(Y));
    xlabel('Frequency (in hertz)');
    title('Magnitude Response of Y');
    subplot(2,2,4);
    plot(y_accel);
    title('Y Acceleration');

end

