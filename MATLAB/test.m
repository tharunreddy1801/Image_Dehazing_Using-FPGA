hazyImg = im2double(imread("C:\Users\Rohan\Downloads\canyon.jpg"));
patchSize = 3;
darkChannel = getDarkChannel(hazyImg, patchSize);


A = getAtmosphericLight(hazyImg, darkChannel);
disp(['Estimated Atmospheric Light: ', num2str(A)]);

Edge_det = computeEdgeDetection(hazyImg, 80);

t_x = computeTransmissionFilter(hazyImg, Edge_det);

dehazed_Img = recoverSceneRadiance(hazyImg, A, t_x, 0.3);

figure, imshow(dehazed_Img), title('Final');