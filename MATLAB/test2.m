hazyImg = "C:\Users\Rohan\Downloads\canyon.jpg";
res = haze_removal(hazyImg);
figure, imshow(hazyImg), title('Input');

figure, imshow(res), title('Output');