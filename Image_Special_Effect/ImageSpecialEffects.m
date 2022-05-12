filename = "lena512.jpg";
disp(filename);
Image = imread(filename);
Image = mat2gray(Image);
[R,C] = size(Image);
disp("R = ");
disp(R);
disp("C = ");
disp(C);

#[X,Y] = meshgrid((1:R)-floor(R/2), (1:C)-floor(C/2));
   


#Cartesian to Polar coordinates
 function [Rho, Theta] = PolarCoord(R,C)
   Rho = zeros(R,C);
   Theta = zeros(R,C);
   
   for i = 1:R
     for j = 1:C
       X = i-R/2;
       Y = j - C/2;
       Rho(i,j) = sqrt(X^2 + Y^2);
       Theta(i,j) = atan2(Y,X);
     endfor
   endfor
   
   
   
 endfunction
 

 
[Rho,Theta] = PolarCoord(R,C);


function [FishRho,FishTheta] = FisheyeTrans(R,C,Rho,Theta)
  FishRho = zeros(R,C);
  
  for i = 1:R
    for j = 1:C
      FishRho(i,j) = ((Rho(i,j))^2)/(sqrt(R^2 + C^2));
      
    endfor
  endfor
  FishTheta = Theta;
endfunction

[FishRho,FishTheta] = FisheyeTrans(R,C,Rho,Theta);


function [RippleR,RippleT] = RipplesOnApond(R,C,Rho,Theta)
  for i = 1:R
    for j = 1:C
      angle = Rho(i,j)/2;
      RippleR(i,j) = 4 + sin(angle);
    endfor
  endfor
  RippleT = Theta;
endfunction

[RippleR,RippleT] = RipplesOnApond(R,C,Rho,Theta);



function [ModR,ModT] = ModTrans(R,C,Rho,Theta)
  for i = 1:R
    for j = 1:C
      angle = floor(10*Theta(i,j));
      ModR(i,j) = Rho(i,j) - mod(Rho(i,j),5);;
      ModT(i,j) = angle/10;
    endfor
  endfor
  
endfunction



[ModR,ModT] = ModTrans(R,C,Rho,Theta);


function [PiR,PiT] = PiTrans(R,C,Rho,Theta)
  for i = 1:R
    for j = 1:C
      angle = Theta(i,j)^2;
      angle /= 2*pi;
      
     PiT(i,j) = angle;
    endfor
  endfor
  PiR = Rho;
endfunction

[PiR,PiT] = PiTrans(R,C,Rho,Theta);

function Iout = ImageSpecialEffect(I,Rho,Theta)   

  [R,C] = size(I);
  disp(R);
  disp(C);
  
  for i = 1:R
    
    for j = 1:C
      dx = 0;
      dy = 0;
      
      
      dx = R/2+ Rho(i,j)*cos(Theta(i,j));
      
      dy = C/2+ Rho(i,j)*sin(Theta(i,j));
      
      #round values nearest neighbour interpolation
      dx = round(dx);
      dy = round(dy);
      
      
     
      #Copy pixel intensity to output image 
      if (dx > 0 && dx < R && dy > 0 && dy < C )
       
        Iout(dx,dy) = I(i,j);
        
      
      endif     
    endfor
  endfor
endfunction

#Show new transformed image 
Iout = ImageSpecialEffect(Image,RippleR,RippleT);
imwrite(Iout,"Ripple.jpg");
