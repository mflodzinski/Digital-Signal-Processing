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
plot(t, cg);

[~, loc_max] = findpeaks(cg, "MinPeakDistance", 10);
hb = size(loc_max, 2);
BMP = hb * 60 / 10;
disp(BMP)
