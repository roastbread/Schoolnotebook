f=imread('blood1.tif'); % read image
f=double(f(1:256,1:256));
g=imread('enamel.tif'); % read image
g=double(g(1:256,1:256));

F = fft2(f);
G = fft2(g);

fg = sum(sum(f.*g)) % <f,g>
FG = sum(sum(conj(F).*G))/256/256 %<F,G>
ff = sum(sum(f.*f)) % <f,f>
FF = sum(sum(conj(F).*F))/256/256 %<F,F>