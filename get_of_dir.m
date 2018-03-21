function [ of_file_path ] = get_of_dir( dataset_dir,of_dir,sample_dir )
%%% root/UCF101pic, root/UCF101pic_256_of, root/UCF101pic/YoYo/v_YoYo_g25_c05
of_file_path = fullfile(of_dir,sample_dir(length(dataset_dir):end));
if ~exist(of_file_path,'dir')
    mkdir(of_file_path);
end
