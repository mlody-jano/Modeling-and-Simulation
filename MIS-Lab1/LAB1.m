clear all; close all;

% IDENTYFIKACJA 

TzewN   = -20;          % oC        Temperatura zewnętrzna
TkzN    =  30;          % oC        Temperatura wprowadzanego powietrza
Tw1N    =  20;          % oC        Temperatura pomieszczenia nr 1
Tw2N    =  15;          % oC        Temperatura pomieszczenia nr 2

PkN     =  10000;       % W         Strumień ciepła z klimatyzatora

sp1     =  30;          % m2        Pole powierzchni pokoju nr 1
hp1     =  3;           % m         Wysokosc pokoju nr 1
Vp1     =  sp1*hp1;     % m3        Objętość pokoju nr 1

sp2     =  20;          % m2        Pole powierzchni pokoju nr 2
hp2     =  3;           % m         Wysokosc pokoju nr 2
Vp2     =  sp2*hp2;     % m3        Objętość pokoju nr 2

a       =  2;           %           Parametr
cpp     =  1000;        % J/(kgK)   Powietrze
rop     =  1.2;         % kg/m3     Powietrze

% Identyfikacja parametrów statycznych

FpN = PkN/(cpp*rop*(TkzN-Tw1N));
Cv1 = cpp * rop * Vp1;
Cv2 = cpp * rop * Vp2;

% Równania dynamiki

Ks2 = PkN/(a*(Tw1N - TzewN) + (Tw2N - TzewN));
Ks1 = a*Ks2;
K0  = (PkN - Ks1 * (Tw1N - TzewN))/(Tw1N-Tw2N);

% WYZNACZANIE PUNKTU PRACY

% Warunki początkowe

% Wejścia

Tkz0    = TkzN + 0;                                                                         % Temperatura początkowa wprowadzanego powietrza [oC]
Fp0     = FpN + 0;                                                                          % Początkowy przepływ powietrza [m3/s]
Tzew0   = TzewN + 0;                                                                        % Temperatura początkowa zewnętrzna [oC]

% Wyjścia

Tw10 = (cpp * rop * Fp0 * Tkz0 + Ks1 * Tzew0 + K0 * (Ks2*Tzew0) ... 
        /(Ks2 + K0)) / (cpp * rop * Fp0 + Ks1 + K0 - power(K0,2)/(Ks2 + K0));               % Temperatura początkowa pomieszczenia nr 1 [oC]
Tw20 = (K0 * Tw10 + Ks2 * Tzew0) / (Ks2 + K0);                                              % Temperatura początkowa pomieszczenia nr 2 [oC]

% Wyświetlanie danych o modelu

fprintf("Początkowe dane o modelu:\n");

fprintf('FpN = %8.4f m3/s\n',  FpN);
fprintf('K0  = %8.2f W/K\n' ,  K0 );
fprintf('Ks1 = %8.2f W/K\n' ,  Ks1);
fprintf('Ks2 = %8.2f W/K\n' ,  Ks2);
fprintf('Cv1 = %8.2f W/K\n' ,  Cv1);
fprintf('Cv2 = %8.2f W/K\n' ,  Cv2);
fprintf('Tw10 = %8.2f oC\n' ,  Tw10);
fprintf('Tw20 = %8.2f oC\n' ,  Tw20);

% Symulacja

czas        = 1200;         % czas symulacji [s]
czas_skok   = 100;          % moment skoku sygnału podczas symulacji [s]
dTkz        = 0;            % skok temperatury wprowadzanego powietrza [oC]
dTzew       = 0;            % skok temperatury zewnetrznej [oC]
dFp         = 0;            % skok przeplywu [m3/s]

% BADANIE DYNAMIKI

% Definicja punktów pracy

punkt_pracy2 = [TzewN, TkzN, FpN; 
                TzewN+10, TkzN, FpN; 
                TzewN+10, TkzN-10, FpN; 
                TzewN+10, TkzN-10, FpN*0.5];

% Definicja skoków

% Skok 1 -> skok Tkz o 2 stopnie
% Skok 2 -> skok Fp o 0.1 (10%)
% Skok 3 -> skok Tzew o 2 stopnie

wart_skok2 = [2 0 0; 
              0 0.1 0; 
              0 0 2];

nP = size(punkt_pracy2,1);                % określenie ilości punktów pracy w celu zapisu wyników
nS = size(wart_skok2,1);                  % określenie ilości skoków w iteracji po skokach

kolory = [0 0.447 0.741;                  % niebieski
          0.85 0.325 0.098;               % pomarańczowy
          0.466 0.674 0.188;              % zielony
          0.494 0.184 0.556];             % fioletowy

styl = {'-', '--', 'x', '-.'};            % style linii na wykresach, w celu rozróżnienia gdy na siebie nachodzą
szer = [2 1 0.7 0.6];                     % grubości linii na wykresach, w celu rozróżnienia gdy na siebie nachodzą

% Pętla testująca po różnych skokach
for skok = 1:nS
    dTkz  = wart_skok2(skok,1);
    dFp   = wart_skok2(skok,2);
    dTzew = wart_skok2(skok,3);

    fprintf('\nSkok nr %d: dTkz = %.2f, dFp = %.4f, dTzew = %.2f\n', skok, dTkz, dFp, dTzew);

    % Definicja zmiennych do zapisu wyników testów
    y1 = cell(nP,1);  y2 = cell(nP,1);  temps = cell(nP,2); time = cell(nP,1);

    % Pętla testująca po różnych punktach pracy
    for punkt = 1:nP
        Tzew0 = punkt_pracy2(punkt,1);
        Tkz0  = punkt_pracy2(punkt,2);
        Fp0   = punkt_pracy2(punkt,3);

        fprintf('\nPunkt nr %d: Tkz0 = %.2f, Fp0 = %.4f, Tzew0 = %.2f\n', punkt, Tzew0, Tkz0, Fp0);

        Tw10 = (cpp*rop*Fp0*Tkz0 + Ks1*Tzew0 + K0*(Ks2*Tzew0)/(Ks2+K0)) / (cpp*rop*Fp0 + Ks1 + K0 - K0^2/(Ks2+K0));
        Tw20 = (K0*Tw10 + Ks2*Tzew0)/(Ks2+K0);

        fprintf("Obliczone temperatury początkowe: \n");
        fprintf('Tw10 = %8.2f oC\n' ,  Tw10);
        fprintf('Tw20 = %8.2f oC\n' ,  Tw20);

        out = sim('LAB1simulink', czas);

        y1{punkt}       = out.aTwp1;
        y2{punkt}       = out.aTwp2;
        time{punkt}     = out.tout;
        temps{punkt,1}  = Tw10;
        temps{punkt,2}  = Tw20;
    end

    % Wykres zbiorczy TW1
    figure; hold on; grid on;
    for punkt = 1:nP
        plot(time{punkt}, y1{punkt}, styl{punkt}, 'Color', kolory(punkt,:), 'LineWidth', szer(punkt), 'DisplayName', sprintf('Pkt pracy nr %d', punkt));
    end
    legend('Location','best'); xlabel('Czas [s]'); ylabel('Tw1 [°C]');
    title("Tw1 - przebiegi dla różnych punktów pracy - skok: dTkz = " + dTkz + " dFp = " + dFp + " dTzew = " + dTzew);

    % Wykres zbiorczy TW2
    figure; hold on; grid on;
    for punkt = 1:nP
        plot(time{punkt}, y2{punkt}, styl{punkt}, 'Color', kolory(punkt,:), 'LineWidth', szer(punkt), 'DisplayName', sprintf('Pkt pracy nr %d', punkt));
    end
    legend('Location','best'); xlabel('Czas [s]'); ylabel('Tw2 [°C]');
    title("Tw2 - przebiegi dla różnych punktów pracy - skok: dTkz = " + dTkz + " dFp = " + dFp + " dTzew = " + dTzew);

    % Znormalizowany wykres TW1
    figure; hold on; grid on;
    for punkt = 1:nP
        dy1 = y1{punkt} - y1{punkt}(1);     % Normalizacja poprzez odjęcie wartości wyliczonej
        plot(time{punkt}, dy1, styl{punkt}, 'Color', kolory(punkt,:), 'LineWidth', szer(punkt), 'DisplayName', sprintf('Pkt pracy nr %d', punkt));
    end
    legend('Location','best'); xlabel('Czas [s]'); ylabel('\Delta Tw1 [°C]');
    title("Tw1 - znormalizowany (\Delta Tw1) - skok: dTkz = " + dTkz + " dFp = " + dFp + " dTzew = " + dTzew);

    % Znormalizowany wykres TW2
    figure; hold on; grid on;
    for punkt = 1:nP
        dy2 = y2{punkt} - y2{punkt}(1);     % Normalizacja poprzez odjęcie wartości wyliczonej
        plot(time{punkt}, dy2, styl{punkt}, 'Color', kolory(punkt,:), 'LineWidth', szer(punkt), 'DisplayName', sprintf('Pkt pracy nr %d', punkt));
    end
    legend('Location','best'); xlabel('Czas [s]'); ylabel('\Delta Tw2 [°C]');
    title("Tw2 - znormalizowany (\Delta Tw2) - skok: dTkz = " + dTkz + " dFp = " + dFp + " dTzew = " + dTzew);
end