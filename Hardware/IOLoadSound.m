function HW = IOLoadSound(HW, stim)
if size(stim,1)<size(stim,2)
    stim=stim';
end;
HW.StimLength = size(stim,1)/HW.params.fsAO;
%zero out unused analog output channel if not in use
if size(stim,2)<HW.params.NumAOChan
    stim(:,2) = zeros(size(stim));
end
%% Apply software attenuation if specified--assumes only one channel of sound; applies to all sounds in a trial (target, non-target, probe)
if isfield(HW,'SoftwareAttendB')
    attend_db=HW.SoftwareAttendB;
    level_scale=10.^(-attend_db./20);
    stim(:,1)=stim(:,1).*level_scale;
end
HW.StimLength = size(stim,1)/HW.params.fsAO;
HW.AO.queueOutputData(stim-eps);
