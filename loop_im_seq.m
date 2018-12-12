function loop_im_seq(J_cell)
% Displays a sequence of images in infinite loop (click to stop)
% J_cell : cell array of images

n=length(J_cell);

evalin('base','loop_im_seq_flagcont=1');

clf
h=imshow(J_cell{1});
set(h,'ButtonDownFcn',@stop_loop);
%set(gcf,'WindowButtonDownFcn',@stop_loop);
%set(gcf,'WindowKeyPressFcn',@stop_loop);

period=0.05;
while (evalin('base','loop_im_seq_flagcont'))
    for i=[1:n]
        %imshow(J_cell{i});
        set(h,'CData',J_cell{i});
        title(sprintf('Image #%i',i));
        pause(period)
        drawnow
        if ~(evalin('base','loop_im_seq_flagcont')), break; end
    end
    pause(0.5)
    for i=[n:-1:1]
        %imshow(J_cell{i});
        set(h,'CData',J_cell{i});
        title(sprintf('Image #%i',i));
        pause(period)
        drawnow
        if ~(evalin('base','loop_im_seq_flagcont')), break; end
    end
    pause(0.5)
end



function stop_loop(varargin)

disp('Stopping loop on image sequence');
evalin('base','loop_im_seq_flagcont=0;');
