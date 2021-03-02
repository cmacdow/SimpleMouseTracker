function outputFrame=readvideoindex(videoSource,frameNumber,FrameRate)
    if isempty(FrameRate) %spock doesn't like get(), so just pass the measured FrameRate
        info=get(videoSource);
        videoSource.CurrentTime=(frameNumber-1)/info.FrameRate;
    else
        videoSource.CurrentTime=(frameNumber-1)/FrameRate;
    end   
    outputFrame=readFrame(videoSource);
end