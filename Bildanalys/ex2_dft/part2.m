

f=imread('cameraman.tif'); % read image
f=double(f(1:256,1:256));

c=fft2(f); % calculate FT
ic=ifft2(c); % calculate IFT

colormap(gray);
subplot(2,2,1); imagesc(f); title('original image'); 
subplot(2,2,3); imagesc(ic); title('reconstructed image');
subplot(2,2,2); imagesc(fftshift(log10(abs(c)))); title('fft log10');
subplot(2,2,4); imagesc(fftshift(abs(c^0.2))); title('fft abs^{0.2}');
e=0;
for i = 1:256
    for j = 1:256
        e = e + (f(i,j)-ic(i,j))^2;
    end
end

for i = 1:256
    krow = int16(rand()*255);
    kcol = int16(rand()*255);
    cex = c(mod(krow,256)+1,mod(kcol,256)+1);
    conex = c(mod(-krow,256)+1,mod(-kcol,256)+1);
    abssym = [abs(cex), abs(conex)];
    argsym = [angle(cex), angle(conex)];
    realsym = [real(cex), real(conex)];
    imagsym = [imag(cex), imag(conex)];

    if cex ~= conj(conex)
        'wrong'
    end


end