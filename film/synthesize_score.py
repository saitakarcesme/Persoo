"""Original Persoo score: generated partials, no sampled or third-party audio."""
from pathlib import Path
import wave
import numpy as np

RATE = 48000

def compose(duration, path, preview=False):
    audio = np.zeros((int(duration * RATE), 2), dtype=np.float64)
    def note(start, frequency, length=3.4, amp=.08, pan=0., soft=True):
        n = min(int(length*RATE), len(audio)-int(start*RATE))
        if n <= 0: return
        t = np.arange(n)/RATE
        attack = 1 - np.exp(-t/(.045 if soft else .007))
        env = attack*np.exp(-t/(1.15 if soft else .2))*np.minimum(1, (length-t)/.3).clip(0,1)
        signal = np.sin(2*np.pi*frequency*t) + .22*np.sin(2*np.pi*frequency*2.001*t) + .07*np.sin(2*np.pi*frequency*3*t)
        signal *= env*amp
        pos=int(start*RATE)
        for delay, gain in [(0,1),(.117,.14),(.291,.09),(.463,.045)]:
            at=pos+int(delay*RATE); count=min(n,len(audio)-at)
            if count>0:
                audio[at:at+count,0] += signal[:count]*gain*np.sqrt((1-pan)/2)
                audio[at:at+count,1] += signal[:count]*gain*np.sqrt((1+pan)/2)
    def bed(start, length, chord):
        n=min(int(length*RATE),len(audio)-int(start*RATE));t=np.arange(n)/RATE
        env=np.minimum(t/2.8,1)*np.minimum((length-t)/3,1).clip(0,1)
        for j,f in enumerate(chord):
            sig=np.sin(2*np.pi*f*t+.15*np.sin(2*np.pi*.12*t))*.009*env
            pos=int(start*RATE);audio[pos:pos+n,j%2]+=sig
            audio[pos:pos+n,(j+1)%2]+=sig*.75
    if preview:
        for start,chord in [(0,[130.81,196,293.66]),(8,[146.83,220,329.63]),(16,[130.81,196,293.66])]: bed(start,9,chord)
        for i,start in enumerate([.5,2.2,4.3,7,8.5,11,13.5,16,17.5,20,21.5]):note(start,[523.25,587.33,783.99,659.25][i%4],amp=.05,pan=(-.22 if i%2 else .22))
    else:
        for start,length,chord in [(0,16,[130.81,196,293.66]),(14,15,[146.83,220,329.63]),(26,14,[164.81,246.94,369.99]),(38,16,[130.81,196,293.66])]:bed(start,length,chord)
        events=[(.4,523.25),(1.65,587.33),(4.4,659.25),(6.1,783.99),(8.5,587.33),(10.2,523.25),(12.1,391.995),(15.3,293.66),(17.4,440),(19.5,587.33),(21.3,659.25),(24.1,783.99),(27.2,493.88),(28.8,659.25),(30.2,739.99),(32,987.77),(33.5,783.99),(36,659.25),(38.3,587.33),(39.4,523.25),(42.1,587.33),(45.3,659.25),(47.1,783.99),(49.4,523.25),(50.2,587.33),(51.1,783.99)]
        for i,(start,f) in enumerate(events):note(start,f,amp=.065 if start<27 else .08,pan=(-.2 if i%2 else .2))
        for start in [4,10,15,21,27,33,39,45,49]:note(start,1568,1,.014,soft=False)
    # Original deterministic air texture; silence at both boundaries.
    rng=np.random.default_rng(20260908);noise=rng.normal(0,.00022,len(audio));noise=np.diff(noise,prepend=0)
    audio += noise[:,None]
    t=np.arange(len(audio))/RATE
    fade=np.minimum(t/.3,1)*np.minimum((duration-t)/1.2,1)
    audio*=fade[:,None]
    audio=np.tanh(audio*1.3)
    pcm=(np.clip(audio,-1,1)*32767).astype('<i2')
    with wave.open(str(path),'wb') as w:w.setnchannels(2);w.setsampwidth(2);w.setframerate(RATE);w.writeframes(pcm.tobytes())
    print(path, 'peak dBFS',20*np.log10(max(np.max(np.abs(audio)),1e-9)))

out=Path(__file__).resolve().parent/'motion/public'
out.mkdir(parents=True,exist_ok=True)
compose(54,out/'launch-score-raw.wav')
compose(24,out/'preview-score-raw.wav',True)
