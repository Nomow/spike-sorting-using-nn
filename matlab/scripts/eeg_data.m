load('/home/vtpc/Documents/Alvils/spike-sorting/data/BOU_JO_Localizer6Hz_sessions','femicro','micros2');
path_to_save = "/home/vtpc/Documents/Alvils/spike-sorting/data/eeg_sess_2";

sess = 2;
fs = femicro;
new_fs = 24000 / fs;
for i = 1:size(micros2, 1)
    recording = micros2(i, :, sess);
    recording_gpu = gpuArray(recording);
    index = gpuArray(0:size(recording, 2) - 1);
    new_index = gpuArray(0:new_fs:size(recording, 2) - 1);
    new_recording = gather(interp1(index,recording_gpu,new_index));
    result1 = detect1(new_recording, 24000);
    result2 = detect2(new_recording, 24000);
    spikes = [result1, result2];
    Fb=100;
    [b,a]=butter(1,[2*Fb/24000], 'high'); % femicro: sampling frequency (24kHz)
    %bdata = data * - 1;
    % filtrage du signal:
    LFPh=filtfilt(b,a,new_recording')';
    opt_zscore = 0.6745 * (LFPh - median(LFPh)) ./ mad(LFPh, 1);
    spikes_to_use = spikes(find(opt_zscore(spikes) <= -4.5 | opt_zscore(spikes) >= 4.5));
    spike_train = [spikes_to_use - 1; ones(size(spikes_to_use))];
    save_path_gd = fullfile(path_to_save, "gd_" + string(i) + ".npy");
    writeNPY(spike_train, save_path_gd)
    save_path_data = fullfile(path_to_save, "data_" + string(i) + ".npy");
    writeNPY(new_recording, save_path_data)

end




