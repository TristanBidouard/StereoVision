function [X1_from_2 Xtmp] = reversewarpx(X2_from_1)

[h,w]=size(X2_from_1);

[X Y]=meshgrid(1:w,1:h);

if 1
    % Process line by line...
    X1_from_2=nan(h,w);
    for row=1:h
        [sX2,ids]=sort(X2_from_1(row,:),'ascend');
        sX1=ids;
        X1_from_2(row,:) = interp1q(sX2(:),sX1(:),[1:w]');
    end
    
else
    
    if 0
        % subsample by 2 for interpolant
        X2_from_1=X2_from_1(1:2:end,1:2:end);
        XX=X(1:2:end,1:2:end);
        YY=Y(1:2:end,1:2:end);
    end
    
    
    X2_from_1=imfilter(X2_from_1,[1 2 1]/4,'symmetric');
    X2_from_1=imfilter(X2_from_1,[1 2 1]'/4,'symmetric');
    
    % Create an interpolator using Delaunay triangulation
    inverseModel = TriScatteredInterp(X2_from_1(:),Y(:), X(:),'linear');
    X1_from_2=inverseModel(X,Y);
    
    %X1_from_2 = griddata(X2_from_1(:),Y(:), X(:), X,Y,'linear');
end

X1_from_2(isnan(X1_from_2))=X(isnan(X1_from_2));


