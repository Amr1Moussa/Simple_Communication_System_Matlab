% read audio file 
[x, Fs] = audioread('speech.wav');  

% Convert stereo to mono
if size(x,2) > 1
    x = mean(x, 2);
end

N = length(x);
t = (0:N-1)/Fs;

fprintf('Playing original sound\n');
sound(x, Fs);
pause(length(x)/Fs + 1);

% fourier transform 
X = fftshift(fft(x));
f = (-N/2 : (N/2)-1)*(Fs/N); 

% Original Signal Plots
figure;
subplot(2,1,1)
plot(t, x)
title('Original Sound - Time Domain')
xlabel('Time (s)')
ylabel('Amplitude')
grid on

subplot(2,1,2)
plot(f, abs(X)/N)
title('Original Sound - Frequency Domain')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
grid on

t_h = 0:1/Fs:1;

% Four Channels Impulse Response

% Channel 1: Delta function
h1 = zeros(size(t_h));
h1(1) = 1;

% Channel 2: exp(-2*pi*5000*t)
h2 = exp(-2*pi*5000*t_h);

% Channel 3: exp(-2*pi*1000*t)
h3 = exp(-2*pi*1000*t_h);

% Channel 4: Echo channel from figure
h4 = zeros(size(t_h));
h4(1) = 2;
h4(end) = 0.5;

% Plot Channel Impulse Responses
figure;

subplot(2,2,1)
stem(t_h, h1, 'filled')
title('h1(t) - Delta Channel')
xlabel('Time (s)')
ylabel('h1(t)')
grid on

subplot(2,2,2)
plot(t_h, h2)
title('h2(t) = exp(-2\pi5000t)')
xlabel('Time (s)')
ylabel('h2(t)')
grid on

subplot(2,2,3)
plot(t_h, h3)
title('h3(t) = exp(-2\pi1000t)')
xlabel('Time (s)')
ylabel('h3(t)')
grid on

subplot(2,2,4)
stem(t_h, h4, 'filled')
title('h4(t) - Echo Channel')
xlabel('Time (s)')
ylabel('h4(t)')
grid on

% Pass Signal Through Channels
y1 = conv(x, h1, 'same');
y2 = conv(x, h2, 'same');
y3 = conv(x, h3, 'same');
y4 = conv(x, h4, 'same');

% Normalize for safe playback
y1_play = y1 / max(abs(y1));
y2_play = y2 / max(abs(y2));
y3_play = y3 / max(abs(y3));
y4_play = y4 / max(abs(y4));


% Plot Channel Outputs
figure;

subplot(2,2,1)
plot(t, y1)
title('Output y1 - Delta Channel')
xlabel('Time (s)')
ylabel('Amplitude')
grid on

subplot(2,2,2)
plot(t, y2)
title('Output y2 - exp(-2\pi5000t)')
xlabel('Time (s)')
ylabel('Amplitude')
grid on

subplot(2,2,3)
plot(t, y3)
title('Output y3 - exp(-2\pi1000t)')
xlabel('Time (s)')
ylabel('Amplitude')
grid on

subplot(2,2,4)
plot(t, y4)
title('Output y4 - Echo Channel')
xlabel('Time (s)')
ylabel('Amplitude')
grid on

% Frequency Domain of Channel Outputs
Y1 = fftshift(fft(y1));
Y2 = fftshift(fft(y2));
Y3 = fftshift(fft(y3));
Y4 = fftshift(fft(y4));

figure;

subplot(2,2,1)
plot(f, abs(Y1)/N)
title('Spectrum of y1')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
grid on

subplot(2,2,2)
plot(f, abs(Y2)/N)
title('Spectrum of y2')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
grid on

subplot(2,2,3)
plot(f, abs(Y3)/N)
title('Spectrum of y3')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
grid on

subplot(2,2,4)
plot(f, abs(Y4)/N)
title('Spectrum of y4')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
grid on

% Choose one channel output to continue the system.

selected_channel = y2;

fprintf('Playing selected channel output\n');
sound(selected_channel / max(abs(selected_channel)), Fs);
pause(length(selected_channel)/Fs + 1);

% Add Noise
sigma = 0.05;
z = sigma * randn(size(selected_channel));

noisy_signal = selected_channel + z;

fprintf('Playing noisy signal\n');
sound(noisy_signal / max(abs(noisy_signal)), Fs);
pause(length(noisy_signal)/Fs + 1);


% Plot Noisy Signal 
Noisy_F = fftshift(fft(noisy_signal));

figure;

subplot(2,1,1)
plot(t, noisy_signal)
title('Noisy Signal - Time Domain')
xlabel('Time (s)')
ylabel('Amplitude')
grid on

subplot(2,1,2)
plot(f, abs(Noisy_F)/N)
title('Noisy Signal - Frequency Domain')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
grid on


% Receiver: Ideal Low Pass Filter 
cutoff = 3400;  

H_lpf = abs(f) <= cutoff;   % vector of zeros and ones

Filtered_F = Noisy_F .* H_lpf.';  % element multiplication for each frequency component
% return to time doamin
filtered_signal = real(ifft(ifftshift(Filtered_F)));

fprintf('Playing filtered signal\n');
sound(filtered_signal / max(abs(filtered_signal)), Fs);
pause(length(filtered_signal)/Fs + 1);

% Plot Ideal LPF Response 
figure;
plot(f, H_lpf)
title('Ideal Low Pass Filter Frequency Response')
xlabel('Frequency (Hz)')
ylabel('H(f)')
ylim([-0.2 1.2])
grid on

% Plot Filtered Signal
Filtered_Spectrum = fftshift(fft(filtered_signal));

figure;

subplot(2,1,1)
plot(t, filtered_signal)
title('Filtered Signal - Time Domain')
xlabel('Time (s)')
ylabel('Amplitude')
grid on

subplot(2,1,2)
plot(f, abs(Filtered_Spectrum)/N)
title('Filtered Signal - Frequency Domain')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
grid on


% Save Output Audio Files
audiowrite('channel_output.wav', selected_channel / max(abs(selected_channel)), Fs);
audiowrite('noisy_output.wav', noisy_signal / max(abs(noisy_signal)), Fs);
audiowrite('filtered_output.wav', filtered_signal / max(abs(filtered_signal)), Fs);