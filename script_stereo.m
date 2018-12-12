% TDM Stereovision
clear; 
close all; 
clc; dbstop if error; path(pathdef);

%% Estimation de disparite

% Charge les images

I1 = imread('data/cones/im2.png');  %left image
I2 = imread('data/cones/im6.png');  %right image
I1 = double(I1)/255;
I2 = double(I2)/255;

% Image size
[h,w]=size(I1(:,:,1));

%% Affiche les images

figure(1);
h1=subplot(1,3,1); imshow(I1); title('Left image I1');
h2=subplot(1,3,2); imshow(I2); title('Right image I2');
h3=subplot(1,3,3); imshow((I1+I2)/2); title('Average');
linkaxes([h1,h2,h3]);


%% Calcul de la disparite

mins = 0;
maxs = 35;%disparite maximum
win_size = 16;

D1 = estimate_disparity(I1,I2, mins, maxs, win_size);
D2 = abs(estimate_disparity(I2,I1, -maxs, mins,win_size));

max_D1 = max(D1);
max_D2 = max(D2);

figure(2); clf
subplot(1,2,1), imagesc(D1); title('Disparity on I1');
subplot(1,2,2), imagesc(D2); title('Disparity on I2');


%% Calcul de profondeur et affichage 3D

b = 5;
f = 380;
% Carte de profondeur
Z1 = (b*f)./D1;

zmax = 200; % 200cm (modify if not using tsukuba)
Z1(Z1>zmax)=nan; % Remove far away pixels

% Display 3D scatter plot
figure(11); clf;

set(gcf,'renderer','opengl');
[X,Y]=meshgrid(1:w,1:h);
% Orthographic plot
surf(X,Y,Z1,...
    'CData',I1,'Marker','.','MarkerFaceColor','flat',...
    'EdgeColor','none',...
    'CDataMapping','direct');
axis([1 w 1 h 0 zmax]);

cameratoolbar
campos([1600 -500 -10]/3);
camup([0 -1 0]);
camva(40);
cameratoolbar('SetMode','orbit');
cameratoolbar('SetCoordSys','y');

%% Prediction de I1 a partir de I2

% Matrice des coordonnees (i,j): X(i,j)=j, Y(i,j)=i
[X1,Y1]=meshgrid(1:w,1:h);

% Predire I1 a partir de I2
X2=X1-D1;
Y2=Y1;

% Interpolation: recopie des pixels I2(X2(i,j),Y(i,j)) dans I1p
I1p = interp2color(I2, X2,Y2);

figure(3);
handle=[];
subplot(2,2,1), imshow(I1); title('I1'); handle(1)=gca;
subplot(2,2,2), imshow(I2); title('I2'); handle(2)=gca;
subplot(2,2,3), imshow(I1p); title('I1 predicted from I2'); handle(3)=gca;
subplot(2,2,4), imagesc(rgb2gray(I1p)-rgb2gray(I1)); axis image; title('Error on I1p'); handle(4)=gca;
linkaxes(handle,'xy');

%% Prediction de I2 a partir de I1

[X2,Y2]=meshgrid(1:w,1:h);

% On souhaite interpoler I1 afin de predire I2
X1=X2+D2;
Y1=Y2;

% Interpolation: recopie des pixels I1(X1(i,j),Y(i,j)) dans I2p
I2p = interp2color(I1, X1,Y1);

figure(4);
handle=[];
subplot(2,2,1), imshow(I1); title('I1'); handle(1)=gca;
subplot(2,2,2), imshow(I2); title('I2'); handle(2)=gca;
subplot(2,2,4), imshow(I2p); title('I2 predicted from I1'); handle(3)=gca;
subplot(2,2,3), imagesc(rgb2gray(I2p)-rgb2gray(I2)); axis image; title('Error on I2p'); handle(4)=gca;
linkaxes(handle,'xy');



%% Interpolation de vue

Im = double(imread('data/cones/im4.png'))/255;  %middle image
alpha = 0.5;

%% Prediction de I1 a partir de Im

%error('Modifier/completer les lignes suivantes: I1 a partir de Im');

[X1,Y]=meshgrid(1:w,1:h);

% I1 predit a partir de Im
Xm_1=X1 - alpha*D1 ;
I1pm = interp2color(Im, Xm_1,Y);

figure(30); clf
errorrange=[-100 100]/255;
handle=[];
subplot(1,3,1), imshow(I1); title('I1 (left)'); handle(1)=gca;
subplot(1,3,2), imshow(I1pm); title('I1 predicted from Im'); handle(2)=gca;
subplot(1,3,3), imagesc(rgb2gray(I1pm)-rgb2gray(I1),errorrange); title('Prediction error 1'); axis image; handle(3)=gca;
linkaxes(handle,'xy')

%% Interpolation de Im a partir de I1 et I2

[X1,Y]=meshgrid(1:w,1:h);
[X2,Y]=meshgrid(1:w,1:h);
Xm_1=X1 - alpha*D1;
Xm_2=X2 + (1-alpha)*D2;

X1_m = reversewarpx(Xm_1); % Pour chaque (im,jm) dans Im, coordonnee dans I1
X2_m = reversewarpx(Xm_2); % Pour chaque (im,jm) dans Im, coordonnee dans I2

% Prediction de Im a partir de I1 et I2:
Imp1 = interp2color(I1, X1_m,Y); % a partir de I1
Imp2 = interp2color(I2, X2_m,Y); % a partir de I2

% Fusion entre les deux images predites
Imp =  0.5*Imp1 + 0.5*Imp2;

figure(31); clf
errorrange=[-100 100]/255;
subplot(2,3,1), imshow(I1); title('I1 (left)'); handle(1)=gca;
subplot(2,3,4), imshow(I2); title('I2 (right)'); handle(2)=gca;
subplot(2,3,2), imagesc(Imp1); title('Im predicted from I1'); axis image; handle(3)=gca;
subplot(2,3,3), imagesc(rgb2gray(Imp1)-rgb2gray(Im),errorrange); title('Prediction error 1'); axis image; handle(4)=gca;
subplot(2,3,5), imagesc(Imp2); title('Im predicted from I2'); axis image; handle(5)=gca;
subplot(2,3,6), imagesc(rgb2gray(Imp2)-rgb2gray(Im),errorrange); title('Prediction error 2'); axis image; handle(6)=gca;
linkaxes(handle,'xy')

figure(201)
imshow(Imp);
%% Generation d'une image interpolee quelconque
%  puis, sequence d'images interpolees

% a = facteur d'interpolation
% (a=0 lorsque Im=I1, a=1 lorsque Im=I2)
a_list=[0:0.1:1]; % Uncomment this line only when ready for video
for i=1:length(a_list)
    a=a_list(i);
    fprintf('a=%f\n',a);
    
    % Calculer les cartes de transformation adequates
    [X1,Y]=meshgrid(1:w,1:h);
    [X2,Y]=meshgrid(1:w,1:h);
    Xm_1=X1 - a*D1;
    Xm_2=X2 + (1-a)*D2;
    
    X1_m = reversewarpx(Xm_1); % Pour chaque (i,j) dans Im, coordonn?e dans I1
    X2_m = reversewarpx(Xm_2); % Pour chaque (i,j) dans Im, coordonn?e dans I2
    
    % Predire Im a partir de I1 et I2, et les fusionner
    Imp1 = interp2color(I1, X1_m,Y); % a partir de I1
    Imp2 = interp2color(I2, X2_m,Y); % a partir de I2
    Imp = (1-a)*Imp1 + a*Imp2; % Bien choisir la ponderation de moyennage
    
    % Simple nettoyage pour eviter les valeurs abherrantes
    Imp1 = min(1,max(0,Imp1));
    Imp2 = min(1,max(0,Imp2));
    Imp = min(1,max(0,Imp));
    
    % Stocke les images interpolees
    J1{i}=Imp1;
    J2{i}=Imp2;
    J{i} =Imp;
    
    figure(40);
    subplot(1,3,1), imshow(J1{i}); title('Interpolated image from I1');
    subplot(1,3,2), imshow(J2{i}); title('Interpolated image from I2');
    subplot(1,3,3), imshow(J{i}); title('Average interpolated image');
    
    drawnow
end
%% Affichage de la sequence predite a partir de I1
% 
% figure(50);
% loop_im_seq(J1);
% 
% %% Affichage de la sequence predite a partir de I2
% 
% figure(51);
% loop_im_seq(J2);

%% Affichage de la sequence interpolee moyennee

figure(52);
loop_im_seq(J);