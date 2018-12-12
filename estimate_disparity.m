%-- slides images across each other to get disparity estimate
function [D_SGM_1] = estimate_disparity(I1,I2,mins,maxs,win_size)


unaryTerms1 = computeUnaryTerms(I1,I2,mins,maxs,win_size);

[Gmag,~] = imgradient(rgb2gray(I1));
alpha = 1e-2./max(Gmag,1e-1);
alpha = 1*ones(size(alpha));
S1 = sgm(unaryTerms1, alpha);
[~,ind1] = min(S1,[],3);
D_SGM_1 = ind1 - 1 + mins;


end

function [unaryTerms] = computeUnaryTerms(i1,i2,mins,maxs,win_size)
% Compute Unary terms between i1 and i2
% images(i,j,d) is the disparity cost for pixel (i,j) in image I1:
% Disparity values are tested within [mins..maxs]
% A square window of size (win_size,win_size) is used

weight = 5;

[dimy,dimx,c] = size(i1);

nbDisparity = abs(maxs - mins) +1;

unaryTerms = zeros(dimy,dimx,nbDisparity);    %-- init outputs

h = ones(win_size)/win_size.^2;  %-- averaging filter

[g1x g1y g1z] = gradient(double(i1)); %-- get gradient for each image
[g2x g2y g2z] = gradient(double(i2));

step = sign(maxs-mins);          %-- adjusts to reverse slide

for i=mins:step:maxs
    s  = shift_image(i2,i);        %-- shift image and derivs
    sx = shift_image(g2x,i);
    sy = shift_image(g2y,i);
    sz = shift_image(g2z,i);
    
    %--CSAD  is Cost from Sum of Absolute Differences
    diffs = sum(abs(i1-s),3);       %-- get CSAD
    
    gdiffx = sum(abs(g1x-sx),3);
    gdiffy = sum(abs(g1y-sy),3);
    gdiffz = sum(abs(g1z-sz),3);
    gdiff = gdiffx+gdiffy+gdiffz;
    
    unaryTerms(:,:,abs(i-mins)+1)  =  imfilter(diffs,h)+weight*imfilter(gdiff,h);
    
end


end

%-- Shift an image
function I = shift_image(I,shift)
dimx = size(I,2);
if(shift > 0)
    I(:,shift:dimx,:) = I(:,1:dimx-shift+1,:);
    I(:,1:shift-1,:) = 0;
else
    if(shift<0)
        I(:,1:dimx+shift+1,:) = I(:,-shift:dimx,:);
        I(:,dimx+shift+1:dimx,:) = 0;
    end
end
end

function S = sgm(unaryTerms, alpha)

[h,w,nbDisp] = size(unaryTerms);

S = zeros(h,w,nbDisp);


[X,Y] = meshgrid(0:nbDisp-1);
pairwiseTerms = abs(X-Y);

%% Horizontal Scanline

for l = 1:h %traite chaque ligne
    
    unaryTermsLine = squeeze(unaryTerms(l,:,:));
    
    L_hor_aller = zeros(w,nbDisp);
    L_hor_aller(1,:) = unaryTerms(l,1,:);
    for c = 2:w
        
        [val,ind] = min(alpha(l,c).*pairwiseTerms + repmat(L_hor_aller(c-1,:)',1,nbDisp), [], 1);
        
        L_hor_aller(c,:) = unaryTermsLine(c,:) + val;
        
    end
    
    L_hor_retour = zeros(w,nbDisp);
    L_hor_retour(w,:) = unaryTerms(l,w,:);
    for c = w-1:-1:1
        
        [val,ind] = min(alpha(l,c).*pairwiseTerms + repmat(L_hor_retour(c+1,:)',1,nbDisp), [], 1);
        
        L_hor_retour(c,:) = unaryTermsLine(c,:) + val;
        
    end
    
    S(l,:,:) = S(l,:,:) + reshape(L_hor_aller,1,w,nbDisp) + reshape(L_hor_retour,1,w,nbDisp);
    
end

%% Vertical Scanline

for c = 1:w %traite chaque colonne
    
    unaryTermsCol = squeeze(unaryTerms(:,c,:));
    
    L_ver_aller = zeros(h,nbDisp);
    L_ver_aller(1,:) = unaryTerms(1,c,:);
    for l = 2:h
        
        [val,ind] = min(alpha(l,c).*pairwiseTerms + repmat(L_ver_aller(l-1,:)',1,nbDisp), [], 1);
        
        L_ver_aller(l,:) = unaryTermsCol(l,:) + val;
        
    end
    
    L_ver_retour = zeros(h,nbDisp);
    L_ver_retour(h,:) = unaryTerms(h,c,:);
    for l = h-1:-1:1
        
        [val,ind] = min(alpha(l,c).*pairwiseTerms + repmat(L_ver_retour(l+1,:)',1,nbDisp), [], 1);
        
        L_ver_retour(l,:) = unaryTermsCol(l,:) + val;
        
    end
    
    S(:,c,:) = S(:,c,:) + reshape(L_ver_aller,h,1,nbDisp) + reshape(L_ver_retour,h,1,nbDisp);
    
end

end

