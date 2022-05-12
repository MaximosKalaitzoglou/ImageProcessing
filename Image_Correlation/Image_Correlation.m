#Hello
clear
I1 = imread("Image1.tif");
I1 = mat2gray(I1);
I2 = imread("Image2.tif");
I2 = mat2gray(I2);
template = imread("Template.tif");
template = mat2gray(template);



[M,N] = size(template);

#Get mean of image

function meanOfimage = GetMean(Image)
  meanOfimage = 0;
  for i = 1:rows(Image)
    for j = 1:columns(Image)
      meanOfimage += Image(i,j);
    endfor
  endfor
  meanOfimage /= (rows(Image)*columns(Image));
endfunction


#hello
#490-690
#469-669




function Iout = correlation(I1,template)
  #get size of image
  [R,C] = size(I1);
  #size of template 
  [xtranslate,ytranslate] = size(template);
  #the equations depicts fxy - fmeanxy so we get the mean of image and template
   meanT = GetMean(template);
   meanI1 = GetMean(I1);
   #values used for calculating the correlation value all are template size arrays
   sumT = zeros(xtranslate,ytranslate);
   denom1 = zeros(xtranslate,ytranslate);
   denom2 = zeros(xtranslate,ytranslate);
   denom = zeros(xtranslate,ytranslate);
   #get the image - the mean saves us proccessing time
   Y = I1 - meanI1;
   #get the template - mean
   X = template - meanT;
   Iout = zeros(R,C);
   #The way this works is the following:
   #we have a template of size 21x21 
   #so we can;t fit it in the image cells (x,y) ->(1-21,1-21)
   #because it will go off the image and its not allowed
   #so we start the loop from 21 -> Width-21 and 21-> Height-21
   #So we are guranteed to get all the valid cells then it is a simple matrix handling
   #and we get the time down from 4 loops (estimated 1 hour of runtime) down to 18 sec 
   
  for i = xtranslate:(R - xtranslate)
    
    for j = ytranslate:(C - ytranslate)
      #values for calculating the output for each i,j 
      tempS = 0;
      tempD1 = 0;
      tempD2 = 0;
      tempD = 0;
      
      #sumT = X*Y where y is from i+1 - templateSize + i meaning
      #that in the first call we have (22,42) -> (43,63) 
      sumT = X .* Y(i+1:xtranslate+i,j+1:ytranslate+j);
      #we get the sum of all the values in a 21x21 block
      tempS = sum(sumT(:));
      #we do the same for denominator of equations where denom1 = (template-mean)^2
      #denom2 = Y(block) ^2 
      #denom = sqrt(denom1 * denom2) then we save the values into tempS ,tempD1,tempD2, tempD and we get the final value for our i,j
      
      denom1 = X .* X;
      tempD1 = sum(denom1(:));
      
      denom2 = (Y(i+1:xtranslate+i,j+1:ytranslate+j)).^2;
      tempD2 = sum(denom2(:));
      tempD = sqrt(tempD1 * tempD2);
      temp = tempS / tempD;
      Iout(i,j) = temp;
      
      
    endfor
  endfor
  
  
endfunction


function Upos = getMaxminCorrelation(Image,filename)
  [minx,minpos] = min(Image(:));
  [maxx,maxpos] = max(Image(:));
  disp(filename);
  disp("Minimum value of image =");
  disp(minx);


  disp("Maximum value of image = ");
  disp(maxx);


  disp("Position of maximum correlation value = ");
  Umax = max(minx,maxx);
  if Umax == minx
    Upos = minpos;
  else
    Upos = maxpos;
  endif

  disp(Upos);
endfunction
  

filename1 = "correlation1.tif"
filename2 = "correlation2.tif"

tic();

Iout1 = correlation(I1,template);
Iout2 = correlation(I2,template);


imwrite(Iout1,filename1);
imwrite(Iout2,filename2);

elapsed_time = toc();


disp("Total time elapsed = ");
disp(elapsed_time);


Upos1 = getMaxminCorrelation(Iout1,filename1);
Upos2 = getMaxminCorrelation(Iout2,filename2);
disp("Difference of template in the 2 images:");
DU = abs(Upos1-Upos2);
disp(abs(Upos1-Upos2));

function Iout = Mosaic(I1,I2,DU)
  [R,C] = size(I1);
  
  Iout = zeros(R,2*C);
  Iout(1:(R*C - DU)) = I1(1:(R*C - DU));
  Iout((R*C - DU):(R*2*C - DU - 1)) = I2(1:R*C);
  
  
  #Iout(R*C:2*R*C) = I2(DU:R*C);
  #Iout((R*C-DU):(R*C-DU)+R*C)) = I2(R*C:1);
   
endfunction

I = Mosaic(I1,I2,DU);
figure();
subplot(2,1,1);
imshow(I);
title("my mosaic");
imwrite(I,"mosaic.tif");

