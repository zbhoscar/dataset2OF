function [ min_x,max_x ] = put_of_vector_in_jpg( of_frame_dir_x, flow_x )
if ~exist(of_frame_dir_x,'file')
    min_x=min(min(flow_x));
    max_x=max(max(flow_x));
    of_jpg_double=(flow_x-min_x)*(255/(max_x-min_x));
    of_jpg_uint8 =uint8(of_jpg_double);
    imwrite(of_jpg_uint8,of_frame_dir_x);
else
    min_x=false;max_x=false;
end