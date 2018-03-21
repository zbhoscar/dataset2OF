function [ of_frame_dir_x, of_frame_dir_y ] = get_of_jpg_dir( of_sample_dir,frame_nam )
[~,filename,extention]=fileparts(frame_nam);
of_frame_dir_x=fullfile(of_sample_dir,[filename,'_x',extention]);
of_frame_dir_y=fullfile(of_sample_dir,[filename,'_y',extention]);
end

