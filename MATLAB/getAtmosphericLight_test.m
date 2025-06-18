hazyImg = im2double(imread("C:\Users\Rohan\Downloads\canyon.jpg"));
patchSize = 3;
darkChannel = getDarkChannel(hazyImg, patchSize);


A = getAtmosphericLight(hazyImg, darkChannel);
disp(['Estimated Atmospheric Light: ', num2str(A)]);