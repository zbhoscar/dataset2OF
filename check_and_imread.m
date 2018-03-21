function [ output_args ] = check_and_imread( orig_smp_dir, frame_smp_dir, resize, new_order, k, read )
frame_path = fullfile(frame_smp_dir,char(new_order(k)));
if exist(frame_path,'file')
    if read == true
        output_args = imread(frame_path);
    end
else
    orig_path = fullfile(orig_smp_dir,char(new_order(k)));
    orig_args = imread(orig_path);
    orig_size = size(orig_args);
    orig_size = orig_size(1:2);
    fnew_size = int32(double(resize) * orig_size / min(orig_size));
    output_args = imresize(orig_args,fnew_size);
    imwrite(output_args,frame_path);
end