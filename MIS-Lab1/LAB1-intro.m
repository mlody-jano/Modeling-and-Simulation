figure;
hold on;
grid on;

a = transpose(-2:.5:2);

kolor = 'rgbc';
tekst = ['r--'; 'g: '; 'b  '; 'c* '];

x = -10:1:10;

for i = 1:length(a)

    index = mod(i-1, length(tekst)) + 1;
    form = tekst(index, :);

    y = a(i) * x.^2;
    plot(x, y, form, 'Color', kolor(index));
end

hold off;