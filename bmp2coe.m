X = imread('Cactus1.bmp');
%ºìÉ«
XR = X(:,:,1);
[m,n] = size(XR);
XX  = double(XR);
XR2R = floor(XX./16);
%ÂÌÉ«
XG = X(:,:,2);
[m,n] = size(XG);
XX  = double(XG);
XR2G = floor(XX./16);
%À¶É«
XB = X(:,:,3);
[m,n] = size(XB);
XX  = double(XB);
XR2B = floor(XX./16);

XR22 = XR2R.*256+XR2G.*16+XR2B;
XR3 = dec2hex(XR22,3);
XR4 = cellstr(XR3);
XR5 = reshape (XR4,[m,n]);
xlswrite('Cactus1.xls',XR5);


