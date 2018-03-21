clear;
dataset_dir='/home/zbh/Desktop/alpha_2_zbh/UCF101pic';
if dataset_dir(end)~='/';dataset_dir=[dataset_dir,'/'];end

of_dir='/home/zbh/Desktop/alpha_2_zbh/UCF101pic_of';
if of_dir(end)~='/';of_dir=[of_dir,'/'];end

dict_to_write_dir='/home/zbh/Desktop/alpha_2_zbh/UCF101pic_of_dict';
if dict_to_write_dir(end)~='/';dict_to_write_dir=[dict_to_write_dir,'/'];end

dataset_sub=dir(dataset_dir);              % DIR下除了检测出来已有文件，MATLAB中的检测还包括.和..
of_step=1;

for i=3:length(dataset_sub)                             % 3 : remove '.' & '..'
    class_nam=dataset_sub(i).name;                      % YoYo
    class_dir=fullfile(dataset_dir,class_nam);          % path/to/dataset/YoYo
    class_sub=dir(class_dir);                           % path/to/dataset/YoYo/list
    
    dict_python_io_dir=fullfile(dict_to_write_dir,[class_nam,'.txt']);
    fp=fopen(dict_python_io_dir,'a');
    
    for j=3:length(class_sub)
        sample_nam=class_sub(j).name;                   % v_YoYo_g25_c05
        sample_dir=fullfile(class_dir,sample_nam);      % path/to/dataset/YoYo/v_YoYo_g25_c05
        sample_sub=dir(sample_dir);                     % path/to/dataset/YoYo/v_YoYo_g25_c05/list
        [ of_sample_dir ] = get_of_dir( dataset_dir,of_dir,sample_dir ); % get or creat of_file_path
        for k=1:length(sample_sub)-of_step              % OF : frame+1 is out of range
            frame_nam=sample_sub(k).name;               % 1.jpg
            [ of_frame_dir_x, of_frame_dir_y ] = get_of_jpg_dir( of_sample_dir,frame_nam );
            if k==1
                fprintf('%s\n',of_frame_dir_x);
            end
%             if ~exist(of_frame_dir_x,'file') || ~exist(of_frame_dir_y,'file')
%                 frame_dir=fullfile(sample_dir,frame_nam);   % % path/to/dataset/YoYo/v_YoYo_g25_c05/1.jpg
%                 frame_nxt=fullfile(sample_dir,sample_sub(k+of_step).name);
%                 frame1 = imread(frame_dir);frame2 = imread(frame_nxt);
%                 [ flow_x, flow_y ] = get_of_vectors( frame1,frame2 );
%                 [ min_x,max_x ] = put_of_vector_in_jpg( of_frame_dir_x, flow_x );
%                 if min_x~=false || max_x~=false
%                     dict_word1=of_frame_dir_x(length(fullfile(of_dir,class_nam))+2:end);
%                     fprintf(fp,'''%s'':{''min'':%f,''max'':%f},',dict_word1,min_x,max_x);
%                 end
%                 [ min_y,max_y ] = put_of_vector_in_jpg( of_frame_dir_y, flow_y );
%                 if min_y~=false || max_y~=false
%                     dict_word2=of_frame_dir_y(length(fullfile(of_dir,class_nam))+2:end);
%                     fprintf(fp,'''%s'':{''min'':%f,''max'':%f},',dict_word2,min_y,max_y);
%                 end
%             end
        end
        %fprintf('%s is finished\n',sample_dir)
    end
    fclose(fp);
end
fprintf('ALL DONE\n');
