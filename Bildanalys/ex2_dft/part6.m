f = imread('cameraman.tif'); % read image
f = double(f(1:256,1:256));
krow = 5;
kcol = -5;
E = base(256,krow,kcol);
proj = sum(sum(conj(E).*f)) %compute the projection 
c = fft2(f); %the DFT of the image f of size 256x256 
c(mod(krow,256)+1,mod(kcol,256)+1) %compare with the DFT value for krow=5 and kcol=−1
%imagesc(real(E))


E1 = base(256,5,5);
E2 = base(256,10,-10);
E3 = base(256,-5,-5);
E4=base(256,-10,10);

Cim=(3+2i)*E1+(2-2i)*E2+(3-2i)*E3 + (2+2i)*E4 ;

d = fft2(Cim);

colormap(gray);
subplot(3,2,1); imagesc(real(Cim)); 
subplot(3,2,2); imagesc(fftshift(log10(abs(d)))); 
subplot(3,2,3); imagesc(real(E1)); 
subplot(3,2,4); imagesc(real(E2)); 
subplot(3,2,5); imagesc(real(E3)); 
subplot(3,2,6); imagesc(real(E4)); 