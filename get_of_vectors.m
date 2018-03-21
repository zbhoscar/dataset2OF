function [ flow_x, flow_y ] = get_of_vectors( frame1,frame2 )
im1    = double(frame1);
im2    = double(frame2);
flow   = mex_OF(im1,im2);
flow_x = flow(:,:,1);
flow_y = flow(:,:,2);
end

