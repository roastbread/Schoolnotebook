
produce_letters_image; %Read the original image. The routine 
%delivers the image ft. 

figure(1) %we decide to work with figure 1 and show it
subplot(3,2,1); %...we decide to divide it to 6 subimages to see 
 % all at the same time. We work with the first quadrant in the 
 %reading direction, the current quadrant

imshow(ft) %...we show the original image ft in the current quadrant 
FTabs=abs(fft2(ft));
FTabsproc=fftshift(log(FTabs+eps)); %We take the discrete Fourier 
%transform and process it for display purposes
subplot(3,2,2); %...choose the second quadrant to display it....
imshow(FTabsproc, [min(FTabsproc(:)) max(FTabsproc(:))]); %The 
%peculiar %syntax, with min and max is to make sure that the minimum 
%of FTabs %maps to 0 and maximum to 255. We could have used imagesc 
%without this %complicated call, but imagesc is older and has som 
%undesired side %effects ... 

FTFT=fft2(fft2(ft));
subplot(3,2,3);imshow(FTFT) % We display it in the current work 
%quadrant 
%Let us see, the range of the imaginary part of FTFT...
disp('Here is the range of the imaginary part of FTFT, ')
[min(min(imag(FTFT))), max(max(imag(FTFT)))]
disp('...it shows that all pixels are practically zero, that is FTFT has real valued pixels!!!')
disp('...and fourier transform is "almost" its inverse...except it is mirrored in the centre')

FTFTFTFT= fft2(fft2(fft2(fft2(ft)))); %insert the missing statement BEFORE EXECUTION …i.e.
 %we take four times fourier transform of the 
 %image ft..
 subplot(3,2,4);imshow(FTFTFTFT) % We display it in the current work 
%quadrant 
%Let us see the range of imaginary part of FTFTFTFT...
disp('Here is the range of the imaginary part of FTFTFTFT, ')
[min(min(imag(FTFTFTFT))), max(max(imag(FTFTFTFT)))]
disp('...it shows that alll pixels are practically zero, that is…FTFTFTFT has real valued pixels!!!')
disp('...and after 4 times Fourier Transform we have obtained…original ...etc')
disp('...This is illustrated also by the second and fourth…image!')



%%We translate our original image ft with 35 pixels to the 
%right...using modulo arithmetic 
% Note that to move THE OBJECTS IN THE IMAGE TO THE RIGHT YOU 
%NEED TO ADD
% -35 TO THE CORRESPONDING column INDEX 
N=size(ft,2); %Image width
ci=0:N-1; %column index in C notation
ft_p=ft(:,mod(ci-35,N)+1); %dont forget +1 for matlab indices
subplot(3,2,5);
imshow(ft_p);

FT_Pabs=abs(fft2(ft_p)); %FILL!!
FT_Pabsproc=fftshift(log(FT_Pabs+eps)); %We 
%process the transformed image for display 
%purposes
subplot(3,2,6); %...choose the second quadrant 
%to display it....
imshow(FT_Pabsproc, [min(FT_Pabsproc(:)),max(FT_Pabsproc(:))]); %The peculiar syntax, with 
%min and max is to 
 % makes sure that the minimum of 
%FTabs maps to 0 and maximum to 255
 %We could have used imagesc without 
%this complicated call, but imagesc is older and 
%having some bugs... %
diff=FT_Pabs-FTabs;
%Let us see the range of the difference between % 
% |FT| and |FT_P|...
disp(' ')
disp('Here is the range of the difference…between |FT| and |FT_P|')
[min(min(diff)), max(max(diff))]
disp('...it shows that all pixels are…practically zero, that is |FT| and |FT_P| ...')
disp('...has the same values at all pixels!!!')


%% section 1.C
%You can repeat to run this section by different circle sizes to 
%see that
%if you reduce the radius in one domain the extension of the 
%function in the other domain
%increases, and vice versa
figure(2)
cir=circle(10); %generate a white circle on a black background
subplot(1,2,1); imshow(cir); %show the circle and see that its 
%centre is at the display centre...
 
% subplot(3,2,2); imshow(L); %show L now and see that it is a 
%circle with centre at (1,1) as fft/ifft expects it...
CIR=fft2(cir);
CIRproc=fftshift(log(abs(CIR))+eps);
subplot(1,2,2); imshow(CIRproc, [min(CIRproc(:)),max(CIRproc(:))]); 
%Let us see the range of CIR...
disp('Range of real part of CIR')
[min(min(real(CIR))), max(max(real(CIR)))]
disp('Range of imaginary part of CIR)')
[min(min(imag(CIR))), max(max(imag(CIR)))]
disp('Range of absolute value of CIR)')
[min(min(abs(CIR))), max(max(abs(CIR)))]
%Repeat the above but with circle(20)..