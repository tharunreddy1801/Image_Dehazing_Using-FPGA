hazyImg = im2double(imread("C:\Users\Rohan\Downloads\canyon.jpg"));
patchSize = 3;
darkChannel = getDarkChannel(hazyImg, patchSize);
figure, imshow(darkChannel), title('Dark Channel');