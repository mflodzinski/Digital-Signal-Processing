function out = dtmf(x, fs)
    % Wywołanie:
    %   [out] = dtmf(x, fs)
    % Gdzie pierw:
    %   [x, fs] = audioread('dtmf.wav')
    %
    % Parametry wejściowe:
    %   x  - wektor próbek audio
    %   fs - częstotliwość próbkowania
    %
    % Parametry wyjściowe:
    %   out - tablica wykrytych dźwięków

    % napis który będziemy wypisywać jako ciąg znaków
    out = "";

    % błąd dopuszczalny
    error = 0.06;

    % możliwe etykiety danych
    labels = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "#"];

    % możliwe wartości danych
    x_freq = [1209, 1336, 1477];
    y_freq = [697, 770, 852, 941];
    yx_freq = {y_freq, x_freq };

    win_len = 500;            % wielkość okna do analizy
    win_overlap = win_len/2;  % nakładanie ramek
    nfft = win_len;           % liczba próbek do FFT

    % wyznaczenie widma częstotliwości w oknach i wyznaczenie amplitudy funkcji składowych
    [s, f, ~] = spectrogram(x, win_len, win_overlap, nfft, fs);
    A = abs(s) / nfft;

    for i=1:size(A, 2)
        N = size(yx_freq, 2);
        [~, j_max] = maxk(A(:, i), 6);    
        [~, j_peak] = findpeaks(A(:, i));

        % indexy punktów które na pewno są szukanymi maksymami funkcji o
        % największych amplitudach - przecięcie zbiorów
        j = intersect(j_max, j_peak);
        if size(j, 1)==0 || size(j, 1)==1
            j = [1; 1];
        end

        freq = [f(j(1)) f(j(2))];
        max_freq = sort(freq);
        freq = zeros(1, N);

        for k=1:N
            for l=1:size(yx_freq{k}, 2)
                down_bound = yx_freq{k}(l) * (1 - error);
                up_bound = yx_freq{k}(l) * (1 + error);
                if max_freq(k) > down_bound && max_freq(k) < up_bound
                    freq(k) = l;
                    break;
                end
            end
            if size(freq) < k
                freq(k) = 0;
            end
        end

        if freq(1)==0 || freq(2)==0
            new_label = "_";
        else
            idx = size(x_freq, 2) * (freq(1) - 1) + freq(2);
            new_label = labels(idx);
        end

        % dopisanie wartosci w momencie nie powtarzania sie jej do wektora out
        if new_label ~= out(size(out))
            out = [out new_label];
        end 
    end

    % zamiana wektora stringów na stringa
    out = strrep(string(strjoin((out))), " ","");
end
