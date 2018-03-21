clear;
% FOR FRAMES like this:
% 'root_dir/UCF101pic/ApplyEyeMakeup/v_ApplyEyeMakeup_g01_c01/1.jpg'
%% SETTINGS
of_step=1;
resize=int16(256);                 %%%%%%%%%%% 0 for not resize %%%%%%%%%%%
rewrite=true;
root_dir='/home/zbh/Desktop/alpha_2_zbh/';
data_floder='UCF101pic';
%% Get dirs
orig_dir=fullfile(root_dir,data_floder);    % root/UCF101pic
if resize > 0
    frame_dir=fullfile(root_dir,[data_floder,'_',num2str(resize)]);   % root/UCF101pic_256
else
    frame_dir=orig_dir;
end
of_dir=[frame_dir,'_of'];                   % root/UCF101pic_256_of
dict_to_write_dir=[frame_dir,'_dict'];      % root/UCF101pic_256_of_dict
%% BEGIN
fprintf('Program starts at %s.\n',datestr(now));
dataset_sub=dir(orig_dir);              % DIR下除了检测出来已有文件，MATLAB中的检测还包括.和..
dataset_sub=dataset_sub(3:end);
if dataset_dir(end)~='/';dataset_dir=[dataset_dir,'/'];end
if of_dir(end)~='/';of_dir=[of_dir,'/'];end
if dict_to_write_dir(end)~='/';dict_to_write_dir=[dict_to_write_dir,'/'];end








check_sub={'ApplyEyeMakeup'
    'ApplyLipstick'
    'Archery'
    'BabyCrawling'
    'BalanceBeam'
    'BandMarching'
    'BaseballPitch'
    'Basketball'
    'Biking'
    'Billiards'
    'BlowDryHair'
    'BlowingCandles'
    'BoxingSpeedBag'
    'CricketShot'
    'Diving'
    'GolfSwing'
    'Haircut'
    'Hammering'
    'HorseRiding'
    'JugglingBalls'
    'JumpRope'
    'Kayaking'
    'PlayingFlute'
    'PlayingGuitar'
    'PlayingPiano'
    'PlayingTabla'
    'PoleVault'
    'PommelHorse'
    'PullUps'
    'RockClimbingIndoor'
    'SoccerJuggling'
    'SumoWrestling'
    'Swing'
    'TableTennisShot'
    'TennisSwing'
    'ThrowDiscus'
    'TrampolineJumping'
    'Typing'
    'UnevenBars'
    'VolleyballSpiking'
    'WalkingWithDog'
    'WallPushups'
    'WritingOnBoard'};

% for i=3:length(dataset_sub)
parfor i=1:length(check_sub)                             % 3 : remove '.' & '..'
    % class_nam=dataset_sub(i).name;                      % YoYo
    class_nam=char(check_sub(i));
    class_dir=fullfile(dataset_dir,class_nam);          % path/to/dataset/YoYo
    class_sub=dir(class_dir);                           % path/to/dataset/YoYo/list
    
    dict_python_io_dir=fullfile(dict_to_write_dir,[class_nam,'.txt']);
    of_sub_dir=fullfile(of_dir,class_nam);
    if rewrite_whole_part==true
        fprintf('cleaning %s and %s.\n',dict_python_io_dir,of_sub_dir);
        if exist(dict_python_io_dir,'file')
            delete(dict_python_io_dir);
        end
        if exist(of_sub_dir,'dir')
            rmdir(of_sub_dir,'s');l
        end
    end
    fp=fopen(dict_python_io_dir,'a');
    
    for j=3:length(class_sub)
        sample_nam=class_sub(j).name;                   % v_YoYo_g25_c05
        sample_dir=fullfile(class_dir,sample_nam);      % path/to/dataset/YoYo/v_YoYo_g25_c05
        
        %%% sample_sub.name={'.','..','1.jpg','10.jpg','100.jpg','101.jpg','11.jpg',...,'99.jpg'}
        sample_sub=dir(sample_dir);                     % path/to/dataset/YoYo/v_YoYo_g25_c05/list
        %%% new_order = {'1.jpg','2.jpg','3.jpg',...,'99.jpg',...,''101.jpg'}
        [ new_order ] = make_struck_in_123_order( sample_sub );
        
        [ of_sample_dir ] = get_of_dir( dataset_dir,of_dir,sample_dir ); % get or creat of_file_path
        for k=1:length(new_order)-of_step              % OF : frame+1 is out of range
            [ of_frame_dir_x, of_frame_dir_y ] = get_of_jpg_dir( of_sample_dir,char(new_order(k)));
            if ~exist(of_frame_dir_x,'file') || ~exist(of_frame_dir_y,'file')
                frame_dir=fullfile(sample_dir,char(new_order(k)));   % % path/to/dataset/YoYo/v_YoYo_g25_c05/1.jpg
                frame_nxt=fullfile(sample_dir,char(new_order(k+of_step)));
                frame1 = imread(frame_dir);frame2 = imread(frame_nxt);
                [ flow_x, flow_y ] = get_of_vectors( frame1,frame2 );
                [ min_x,max_x ] = put_of_vector_in_jpg( of_frame_dir_x, flow_x );
                if min_x~=false || max_x~=false
                    dict_word1=of_frame_dir_x(length(fullfile(of_dir,class_nam))+2:end);
                    fprintf(fp,'''%s'':{''min'':%f,''max'':%f},',dict_word1,min_x,max_x);
                end
                [ min_y,max_y ] = put_of_vector_in_jpg( of_frame_dir_y, flow_y );
                if min_y~=false || max_y~=false
                    dict_word2=of_frame_dir_y(length(fullfile(of_dir,class_nam))+2:end);
                    fprintf(fp,'''%s'':{''min'':%f,''max'':%f},',dict_word2,min_y,max_y);
                end
            end
        end
        fprintf('%s is finished, %d frames inall.\n',fullfile(class_nam,sample_nam),length(new_order))
    end
    fclose(fp);
end
fprintf('ALL DONE. Ends at %s.\n',datestr(now));