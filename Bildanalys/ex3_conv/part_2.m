f =ones(5,5); 
g=ones(3,3);
y=conv2(f,g)

F=fft2(f,5,5);
G=fft2(g,5,5);
Y=F.*G;
yy=real(ifft2(Y))

%%
f=imread('flowers.jpg');
f=double(f(1:256,1:256));
g=ones(21,21)/(21*21);
y=conv2(f,g);
subplot(2,2,1); imshow(f/255);
subplot(2,2,2); imshow(y/255);

yy1 = ifft2(fft2(f,256,256).*fft2(g,256,256));
subplot(2,2,3); imshow(yy1/255);

yy2 = ifft2(fft2(f,276,276).*fft2(g,276,276));
subplot(2,2,4); imshow(yy2/255);

