"""Verify delivery encoding metadata. Does not certify creative or App Store readiness."""
import json, subprocess, sys
from pathlib import Path
for arg in sys.argv[1:]:
    path=Path(arg)
    data=json.loads(subprocess.check_output(['ffprobe','-v','error','-show_streams','-show_format','-of','json',str(path)]))
    video=next(s for s in data['streams'] if s['codec_type']=='video')
    audio=next(s for s in data['streams'] if s['codec_type']=='audio')
    preview='Preview' in path.name
    expected=(886,1920,'30/1',24) if preview else (1920,1080,'60/1',54)
    assert (video['width'],video['height'],video['avg_frame_rate'])==expected[:3]
    assert abs(float(data['format']['duration'])-expected[3])<.1
    assert video['codec_name']=='h264' and video['pix_fmt']=='yuv420p'
    assert audio['codec_name']=='aac' and audio['channels']==2 and audio['sample_rate']=='48000'
    assert int(data['format']['size'])<500_000_000
    if preview: assert video['profile']=='High' and video['level']<=40
    result={'file':path.name,'duration':data['format']['duration'],'size':data['format']['size'],'video':{k:video.get(k) for k in ['codec_name','profile','level','width','height','avg_frame_rate','nb_frames','pix_fmt','bit_rate']},'audio':{k:audio.get(k) for k in ['codec_name','channels','sample_rate','bit_rate']}}
    print(json.dumps(result,indent=2))
