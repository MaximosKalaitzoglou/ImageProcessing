#Maximos Kalaitzoglou AM 2983

#VARIABLES 

K = input("Give value of K (noisy pictures to be used):\n");
disp(K);
SNR = 5; #SNR VALUE 



#FUNCTIONS USED 
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#


#get mean of image
function meanOfimage = GetMean(Image)
  meanOfimage = 0;
  for i = 1:rows(Image)
    for j = 1:columns(Image)
      meanOfimage += Image(i,j);
    endfor
  endfor
  
endfunction



#{
solving for variance we get var^2 = s/M*N*10^SNR where SNR = 5

SNR = log10(SiSj(f(i,j) - mean(f))^2/M*N*variance^2

where SiSj(f(i,j) - mean(f))^2 = s

therefore we have :

SNR = log10(s/M*N*variance^2)

=> SNR = ln(s/M*N*variance^2)/ln(10) 

=> ln(s/M*N*variance^2) = SNR*ln(10) 

=> from(e^) 

=> s/M*N*variance^2 = ...e^(SNR*ln(10)) 

=> M*N*variance^2 *(e^ln(10))^SNR = s
 
=> M*N*variance^2*10^SNR = s

=> variance^2 = s/(M*N*10^SNR)
#}

#Caluclate variance based on SNR 

function variance = CalcVar(Image,meanOfimage,SNR)
  variance = 0;
  s = 0;
  [M,N] = size(Image);
  for i = 1:rows(Image)#get the sum of matrix elements - mean of image squared
    for j = 1:columns(Image)
      s += (Image(i,j) - meanOfimage)^2;
    endfor
  endfor
  variance = sqrt(s/(M*N*(10^SNR)));
endfunction








#used for generating K noisy images to use for noise reduction 

function GenerateKnoisyImages(OriginalImage,variance,K)
  
  [W,H] = size(OriginalImage);
  for i = 1:K
    fname = sprintf("noise%d.jpg",i);
    
    temp = imnoise(OriginalImage,"gaussian",variance^2);
    

    imwrite(temp,fname);
  endfor
endfunction





#Noise reduction function

function [data,ReductedImage] = NoiseReduction (K,M,N,NoisyImage,OriginalImage)
  t = 0;
  data = zeros(1,K);
  for j = 1:K
    new_image = NoisyImage;
    temp2 = 0;
    for i = 1:j
    
      fname = sprintf("noise%d.jpg",i);#read noisy images
      A = imread(fname);
      A = mat2gray(A); #convert into a double
      new_image = new_image .+ A; #add images 
    endfor
    new_image /= j; #get the mean of the noisy images
    Error = MSE(new_image,OriginalImage);
    data(j) = Error;
    disp(data(j));
    ReductedImage = new_image;
  endfor  
endfunction

#calculate the MSE of the reducted image from the original 
function Error = MSE(Image,OriginalImage)
  temp2 = 0;
  [M,N] = size(Image);
  for i = 1:rows(Image)
      for j = 1:columns(Image)
        
        temp2 += (OriginalImage(i,j)-Image(i,j))^2;
      endfor
    endfor
  disp("from NoiseReduction");
  Error = temp2/(M*N);
  return;
endfunction


#END OF FUNCTIONS USED
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#MAIN CALLS  
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#




#Variables And image Load
Lena = imread("lena512.jpg"); #read image

LenaGray = mat2gray(Lena); #make it a double value range [0,1]
[M,N] = size(LenaGray);


#calculate mean of image
meanOfimage = GetMean(LenaGray); 
disp(meanOfimage);
meanOfimage /= (M*N); #mean of image
disp("MEAN of image = ");
disp(meanOfimage);

#calculate variance based on SNR

variance = CalcVar(LenaGray,meanOfimage,SNR); 
disp("Variance based on SNR : ");
disp(variance);


GenerateImages = input("If you wish to generate K noisy images for the algorithm enter 1 \nIf you already have K noisy images enter 0 :\n");

if ((GenerateImages == 1))
  GenerateKnoisyImages(LenaGray,variance,K);
  disp("Generated Images ");
endif



#ADDING NOISE 

GrayNoise = imread("noise1.jpg");



#Get Error and image after reduction up to K 
#If you use K = 5 => 5 MSE will be calculated and the last reducted image will be returned (K = 5)

[data,reductedImage] = NoiseReduction(K,M,N,GrayNoise,LenaGray);


#END OF MAIN CALLS
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#


#plots the images original ,noisy,and noise reduction image
imwrite(reductedImage,"reductedImage.jpg");

subplot(2,2,1);
imshow(GrayNoise);
title("Before Reduction Noisy");
subplot(2,2,2);
imshow(LenaGray);
title("Original");
subplot(2,2,3);
imshow(reductedImage);
title("After reduction");

figure;
N = 1:K
plot(N,data(N));
xlabel("Noisty pictures Used");
ylabel("Mean squared error");
title("Mean Error Graph");
