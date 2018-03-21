clear;
% FOR FRAMES like this:
% 'root_dir/UCF101pic/ApplyEyeMakeup/v_ApplyEyeMakeup_g01_c01/1.jpg'
%% SETTINGS
of_step = 1;
resize = 0;                 %%%%%%%%%%% 0 for not resize %%%%%%%%%%%
rewrite = true;
if filesep == '/'
    root_dir = '/home/zbh/Desktop/alpha_2_zbh';
elseif filesep == '\'
    root_dir = 'D:\Desktop';
end
data_floder = 'UCF101pic_256';
%% Get dirs
orig_dir = fullfile(root_dir,data_floder);    % root/UCF101pic
if resize > 0
    frame_dir = fullfile(root_dir,[data_floder,'_',num2str(resize)]);   % root/UCF101pic_256
else
    frame_dir = orig_dir;
end
of_dir = [frame_dir,'_of'];                   % root/UCF101pic_256_of
dict_to_write_dir = [of_dir,'_dict'];      % root/UCF101pic_256_of_dict
%% BEGIN
fprintf('Program starts at %s.\n',datestr(now));

dataset_sub = dir(orig_dir);              % all files&dirs, including .&..
dataset_sub = dataset_sub(3:end);         % 3 : remove '.' & '..'

for i = 1:length(dataset_sub)    
    class_nam = dataset_sub(i).name;                      % YoYo
    class_dir = fullfile(orig_dir,class_nam);             % root/UCF101pic/YoYo
    class_sub = dir(class_dir);
    class_sub = class_sub(3:end);                         % root/UCF101pic/YoYo/list
    %% set python_dict path to save max/min for YoYo
    % 'root/UCF101pic_dict/ApplyEyeMakeup.txt'
    dict_python_io_dir = fullfile(dict_to_write_dir,[class_nam,'.txt']);
    %% set of path to save of and check if needs to rewrite
    of_sub_dir = fullfile(of_dir,class_nam);              % 'root/UCF101pic_of/ApplyEyeMakeup'
    if rewrite == true || ~exist(dict_python_io_dir,'file')         % if rewrite, then delete
        fprintf('cleaning %s and %s\n',dict_python_io_dir,of_sub_dir);
        if exist(dict_python_io_dir,'file');delete(dict_python_io_dir);end
        if exist(of_sub_dir,'dir');rmdir(of_sub_dir,'s');end
        dict_check = '';
    elseif exist(dict_python_io_dir,'file')
        fid = fopen(dict_python_io_dir,'r');dict_check=fgetl(fid);fclose(fid);
    end
    if ~exist(dict_to_write_dir,'dir');mkdir(dict_to_write_dir);end
    fp = fopen(dict_python_io_dir,'a');                   % prepare to write python_dict
    %%    
    for j = 1:length(class_sub)        
        sample_nam = class_sub(j).name;                   % v_YoYo_g25_c05
        sample_dir = fullfile(class_dir,sample_nam);      % root/UCF101pic/YoYo/v_YoYo_g25_c05
        %% Order: ., .., 1, 10, 100, 101...99 to 1, 2, 3...
        %%% sample_sub.name = {'.','..','1.jpg','10.jpg','100.jpg','101.jpg','11.jpg',...,'99.jpg'}
        sample_sub = dir(sample_dir);                     % path/to/dataset/YoYo/v_YoYo_g25_c05/list
        %%% new_order = {'1.jpg','2.jpg','3.jpg',...,'99.jpg',...,''101.jpg'}
        new_order = make_struck_in_123_order( sample_sub );
        %% Get or creat resized_pic_path, of_file_path,
        in_video = fullfile(class_nam, sample_nam);         % /YoYo/v_YoYo_g25_c05
        of_sample_dir = fullfile(of_dir, in_video);         % root/UCF101pic_256_of/YoYo/v_YoYo_g25_c05
        if ~exist(of_sample_dir,'dir');mkdir(of_sample_dir);end
        frame_smp_dir = fullfile(frame_dir, in_video);      % root/UCF101pic_256/YoYo/v_YoYo_g25_c05
        if ~exist(frame_smp_dir,'dir');mkdir(frame_smp_dir);end
        orig_smp_dir = fullfile(orig_dir, in_video);        % root/UCF101pic/YoYo/v_YoYo_g25_c05
        %% bigen scan frame_pic for of&dict
        frame_temp = []; k_temp = 0;        
        for k = 1:length(new_order)-of_step              % OF : frame+1 is out of range
            %% examine of_x, of_y
            [ of_frame_dir_x, of_frame_dir_y ] = get_of_jpg_dir( of_sample_dir,char(new_order(k)));
            if ~exist(of_frame_dir_x,'file') || ~exist(of_frame_dir_y,'file')
                %% if rewirte new_frames
                if k_temp == k
                    frame_prev = frame_temp;
                else
                    frame_prev = check_and_imread( orig_smp_dir, frame_smp_dir, resize, new_order, k, 1 );
                end
                frame_next = check_and_imread( orig_smp_dir, frame_smp_dir, resize, new_order, k+1, 1 );
                %% get of_x, of_y between 2 frames
                [ flow_x, flow_y ] = get_of_vectors( frame_prev,frame_next );
                %% for flow_x
                [ min_x, max_x ] = put_of_vector_in_jpg( of_frame_dir_x, flow_x );
                if min_x ~= false || max_x ~= false
                    dict_word1 = strrep(of_frame_dir_x(length(fullfile(of_dir,class_nam))+2:end),'\','/'); % use linux sep
                    if rewrite == true || ~contains(dict_check, dict_word1)
                        fprintf(fp,'''%s'':{''min'':%f,''max'':%f},',dict_word1,min_x,max_x);
                    end
                end
                %% for flow_y
                [ min_y, max_y ] = put_of_vector_in_jpg( of_frame_dir_y, flow_y );
                if min_y ~= false || max_y ~= false
                    dict_word2 = strrep(of_frame_dir_y(length(fullfile(of_dir,class_nam))+2:end),'\','/'); % use linux sep
                    if rewrite == true || ~contains(dict_check, dict_word2)
                        fprintf(fp,'''%s'':{''min'':%f,''max'':%f},',dict_word2,min_y,max_y);
                    end
                end                
                frame_temp = frame_next; k_temp = k+1;
            else
                check_and_imread( orig_smp_dir, frame_smp_dir, resize, new_order, k, 0 );
                check_and_imread( orig_smp_dir, frame_smp_dir, resize, new_order, k+1, 0 );
            end
        end
        fprintf('%s is finished, %d frames inall.\n',in_video,length(new_order))
    end
    fclose(fp);
end
fprintf('ALL DONE. Ends at %s.\n',datestr(now));