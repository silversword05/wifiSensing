function pd_signal = compute_phase_difference(stream)
    pd_signal = [];
    time_ix = size(stream.antenna1.csiBuff, 2) + 1;
    csi_stream_1 = [stream.antenna1.csiBuff stream.antenna1.timeBuff'];
    csi_stream_2 = [stream.antenna2.csiBuff stream.antenna2.timeBuff'];
    % merge both the streams
    ix_1 = 1; ix_2 = 1;
    merged_streams = [];
    N1 = size(csi_stream_1, 1);
    N2 = size(csi_stream_2, 1);
    while (ix_1 <= N1) && (ix_2 <= N2)
        if (csi_stream_1(ix_1, time_ix) < csi_stream_2(ix_2, time_ix))
            row = [csi_stream_1(ix_1,:) 0];
            merged_streams = [merged_streams; row];
            ix_1 = ix_1 + 1;
        else
            row = [csi_stream_2(ix_2,:) 1];
            merged_streams = [merged_streams; row];
            ix_2 = ix_2 + 1;
        end
    end
    while ix_1 <= N1
        row = [csi_stream_1(ix_1,:) 0];
        merged_streams = [merged_streams; row];
        ix_1 = ix_1 + 1;
    end
    while ix_2 <= N2
        row = [csi_stream_2(ix_2,:) 1];
        merged_streams = [merged_streams; row];
        ix_2 = ix_2 + 1;
    end
    % compute the phase difference signal
    ix = 1;
    N = size(merged_streams, 1);
    while (ix + 1 <= N)
        core_num_1 = merged_streams(ix, time_ix + 1);
        core_num_2 = merged_streams(ix + 1, time_ix + 1);
        curr_time = min(merged_streams(ix, time_ix), merged_streams(ix + 1, time_ix));
        if core_num_1 == 0 && core_num_2 == 1
            % phase difference of the csi from two antenna
            csi_frame_1 = merged_streams(ix, 1:time_ix-1);
            csi_frame_2 = merged_streams(ix + 1, 1:time_ix-1);
            phase_difference = angle(csi_frame_1 .* conj(csi_frame_2));
            pd_signal = [pd_signal; [phase_difference curr_time]];            
            ix = ix + 2;
        else
            % dropping the earlier packet i.e. frame at index 'ix'
            ix = ix + 1;
        end
    end
end
