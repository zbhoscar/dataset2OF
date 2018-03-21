function new_order = make_struck_in_123_order( sample_sub )
for i = 1:length(sample_sub)
    if sample_sub(i).isdir == false
        [~,pic_num,~] = fileparts(sample_sub(i).name); % pic_num = '123.'
        new_num = str2double(pic_num);
        new_order{new_num} = sample_sub(i).name;
    end
end