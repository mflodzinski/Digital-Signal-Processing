% Liczba ramek do wczytania (przy 10 sekundach i 30 FPS będzie to 300)
N = 300;
% wektor jasności
br = zeros(1, N);
v = VideoReader('output.mp4');

for i=1:N
    I = rgb2gray(read(v,i));
    br(i) = mean(I, 'all');
end
% dla ułatwienia późniejszej analizy od razu można odjąć od sygnału składową stałą
br = br - mean(br);

t=1:1:N;
g = fspecial('gaussian', [1,  15], 3);
cg = conv(br, g, 'same');
% plot(t, cg);

[r, lags] = xcorr(cg, cg);
% wycięcie jedynie dodatnich przesunięć
r = r(lags >= 0);
lags = lags(lags>=0);
plot(lags, r);

[pks, loc] = findpeaks(r, "MinPeakDistance", 10, "MinPeakProminence", 20);
fs = 30;
% przesunięcie w sekundach
lag_s = (loc(1)+1) * 1/fs;
% częstotliwość bazowa
freq = 1/lag_s;
disp(freq*60)
