import React from 'react';
import { AbsoluteFill, Easing, Img, Interactive, Sequence, interpolate, staticFile, useCurrentFrame, useVideoConfig } from 'remotion';
import { Audio } from '@remotion/media';

const paper = '#F8F9F7';
const ink = '#172520';
const forest = '#143E32';
const accent = '#176B56';
const ease = Easing.bezier(.22, 1, .36, 1);
const clamp = {extrapolateLeft: 'clamp' as const, extrapolateRight: 'clamp' as const};

const Eyebrow: React.FC<{children: React.ReactNode; dark?: boolean}> = ({children, dark}) => <div style={{fontSize: 24, fontWeight: 500, letterSpacing: 4, color: dark ? '#B4D0C0' : '#56645D', textTransform: 'uppercase', marginBottom: 36}}>{children}</div>;
const Reveal: React.FC<{children: React.ReactNode; delay?: number; size?: number; color?: string}> = ({children, delay = 0, size = 116, color = ink}) => {
  const frame = useCurrentFrame();
  return <Interactive.Div name="Editorial headline" style={{fontSize: size, lineHeight: 1.045, letterSpacing: -5, fontWeight: 500, color, opacity: interpolate(frame, [delay, delay+32], [0,1], clamp), translate: `0px ${interpolate(frame, [delay,delay+48], [25,0], {...clamp,easing: ease})}px`}}>{children}</Interactive.Div>;
};
const Plate: React.FC<{screen: string; width?: number; delay?: number}> = ({screen, width = 416, delay = 0}) => {
  const frame = useCurrentFrame();
  return <Interactive.Div name={`Native UI — ${screen}`} style={{width, flexShrink: 0, opacity: interpolate(frame,[delay,delay+36],[0,1],clamp), translate: `0px ${interpolate(frame,[delay,delay+56],[26,0],{...clamp,easing: ease})}px`, borderRadius: 38, overflow: 'hidden', boxShadow: '0 24px 60px rgba(23,37,32,0.08)', border: '1px solid rgba(23,37,32,.07)'}}><Img src={staticFile(`ui/${screen}.png`)} style={{width:'100%', display:'block'}} /></Interactive.Div>;
};
const Stage: React.FC<{children: React.ReactNode; duration: number; dark?: boolean}> = ({children,duration,dark}) => {
  const frame = useCurrentFrame();
  return <AbsoluteFill style={{backgroundColor: dark ? forest : paper, color: dark ? paper : ink, opacity: interpolate(frame,[0,18,duration-24,duration-1],[0,1,1,0],clamp)}}>{children}</AbsoluteFill>;
};
const Pair: React.FC<{children: React.ReactNode; screen: string}> = ({children,screen}) => <div style={{display:'grid', gridTemplateColumns:'1fr 416px',gap:80,alignItems:'center',height:'100%',padding:'72px 190px 72px 150px'}}><div>{children}</div><Plate screen={screen} delay={8}/></div>;
const Foot: React.FC<{children: React.ReactNode; dark?: boolean}> = ({children,dark}) => <div style={{fontSize:31,lineHeight:1.45,color:dark?'#B4D0C0':'#56645D',marginTop:38,fontWeight:400,letterSpacing:-.5}}>{children}</div>;

const Invitation = () => {
  const frame = useCurrentFrame();
  return <Stage duration={240}><div style={{display:'flex',flexDirection:'column',justifyContent:'center',padding:'0 150px',height:'100%'}}><Eyebrow>Persoo</Eyebrow><Reveal size={150}>Life happens.</Reveal><Interactive.Div name="Invitation second line" style={{fontSize:150,lineHeight:1.12,fontWeight:500,letterSpacing:-7,color:accent,opacity:interpolate(frame,[48,90],[0,1],clamp),translate:interpolate(frame,[48,100],['0px 24px','0px 0px'],{...clamp,easing:ease})}}>Just tell Persoo.</Interactive.Div></div></Stage>;
};
const Tell = () => <Stage duration={360}><Pair screen="dictation"><Eyebrow>A small moment</Eyebrow><Reveal size={102}>“Spent €6.20</Reveal><Reveal size={102} delay={37}>on an</Reveal><Reveal size={102} delay={72}>energy drink.”</Reveal><Foot>Say it as it happened.</Foot></Pair></Stage>;
const Structure = () => <Stage duration={300}><Pair screen="purchase"><Eyebrow>Quietly put together</Eyebrow><Reveal>One sentence.</Reveal><Reveal delay={28} color={accent}>In its place.</Reveal><Foot>Finance. Already structured.</Foot></Pair></Stage>;
const Time = () => {
  const frame=useCurrentFrame();
  return <Stage duration={360}><div style={{height:'100%',display:'flex',flexDirection:'column',justifyContent:'center',padding:'80px 150px'}}><Eyebrow>Across 30 days</Eyebrow><Reveal size={114}>Little moments add up.</Reveal><div style={{display:'flex',gap:18,alignItems:'end',marginTop:92,marginBottom:46}}>{Array.from({length:12},(_,i)=><div key={i} style={{width:118,opacity:interpolate(frame,[38+i*10,62+i*10],[0,1],clamp),translate:`0px ${interpolate(frame,[38+i*10,68+i*10],[14,0],{...clamp,easing:ease})}px`}}><div style={{fontSize:30,fontVariantNumeric:'tabular-nums',color:'#56645D',marginBottom:20}}>{i===0?'€5.80':'€6.20'}</div><div style={{height: i===0?65:72,backgroundColor:i===11?accent:'#D5DED7',borderRadius:'5px 5px 0 0'}}/></div>)}</div><div style={{display:'flex',alignItems:'baseline',justifyContent:'space-between',borderTop:'1px solid #B7C5BC',paddingTop:30}}><span style={{fontSize:32,color:'#56645D'}}>12 recorded purchases</span><div style={{fontSize:104,fontWeight:500,letterSpacing:-5,opacity:interpolate(frame,[162,196],[0,1],clamp)}}>€74</div></div></div></Stage>;
};
const Notice = () => <Stage duration={360}><Pair screen="savings"><Eyebrow>A little perspective</Eyebrow><Reveal size={184}>€74</Reveal><Foot>On energy drinks in the last 30 days.<br/>12 purchases. One clearer picture.</Foot></Pair></Stage>;
const Possibility = () => {
  const frame=useCurrentFrame();
  return <Stage duration={360} dark><div style={{height:'100%',display:'flex',flexDirection:'column',justifyContent:'center',padding:'70px 150px'}}><Eyebrow dark>Your choice</Eyebrow><Reveal size={105} color={paper}>If you chose to skip them.</Reveal><div style={{display:'grid',gridTemplateColumns:'1fr 1fr 1fr',gap:70,marginTop:80}}>{[['1 month','€74'],['6 months','€444'],['1 year','€888']].map(([period,value],i)=><Interactive.Div key={period} name={`Scenario ${period}`} style={{borderTop:'1px solid #588170',paddingTop:26,opacity:interpolate(frame,[45+i*40,78+i*40],[0,1],clamp),translate:`0px ${interpolate(frame,[45+i*40,90+i*40],[20,0],{...clamp,easing:ease})}px`}}><div style={{fontSize:32,color:'#B4D0C0',marginBottom:24}}>{period}</div><div style={{fontSize:146,fontWeight:500,letterSpacing:-6,fontVariantNumeric:'tabular-nums'}}>{value}</div></Interactive.Div>)}</div><Foot dark>If monthly spending stayed the same.<br/>Potential savings, not a prediction.</Foot></div></Stage>;
};
const YourPlan = () => <Stage duration={360}><Pair screen="plans"><Eyebrow>From your own plans</Eyebrow><Reveal size={105}>A little less here.</Reveal><Reveal size={105} delay={38} color={accent}>A little more<br/>there.</Reveal><Foot>A weekend in Copenhagen.<br/>Your €900 estimate.</Foot></Pair></Stage>;
const WholeDay = () => <Stage duration={360}><div style={{height:'100%',display:'grid',gridTemplateColumns:'1fr 360px 360px',gap:42,padding:'100px 110px 100px 150px',alignItems:'center'}}><div><Eyebrow>A life in context</Eyebrow><Reveal size={85}>Movement.</Reveal><Reveal size={85} delay={28}>Classes.</Reveal><Reveal size={85} delay={56} color={accent}>Room to<br/>think.</Reveal></div><Plate screen="fitness" width={360}/><Plate screen="schedule" width={360} delay={70}/></div></Stage>;
const Ahead = () => <Stage duration={240}><Pair screen="reminder"><Eyebrow>When it matters</Eyebrow><Reveal size={118}>A moment<br/>ahead.</Reveal><Foot>Tomorrow starts at 09:00.</Foot></Pair></Stage>;
const Ending = () => {
  const frame=useCurrentFrame();
  return <AbsoluteFill style={{backgroundColor:paper,justifyContent:'center',alignItems:'center'}}><Interactive.Div name="Persoo wordmark" style={{fontSize:178,letterSpacing:-9,fontWeight:500,opacity:interpolate(frame,[0,48],[0,1],clamp),translate:interpolate(frame,[0,54],['0px 16px','0px 0px'],{...clamp,easing:ease})}}>Persoo</Interactive.Div><Interactive.Div name="End tagline" style={{fontSize:45,letterSpacing:-1,color:'#56645D',marginTop:30,opacity:interpolate(frame,[45,90],[0,1],clamp)}}>Life, in context.</Interactive.Div><div style={{position:'absolute',bottom:52,fontSize:22,color:'#56645D',letterSpacing:.3}}>Product concept · Open source</div></AbsoluteFill>;
};
export const LaunchFilm = () => <AbsoluteFill style={{fontFamily:'"Helvetica Neue", Helvetica, Arial, sans-serif',backgroundColor:paper,color:ink}}>
  <Audio src={staticFile('launch-score.wav')}/>
  <Sequence name="01 Invitation" durationInFrames={240}><Invitation/></Sequence>
  <Sequence name="02 Tell" from={240} durationInFrames={360}><Tell/></Sequence>
  <Sequence name="03 Structure" from={600} durationInFrames={300}><Structure/></Sequence>
  <Sequence name="04 Time" from={900} durationInFrames={360}><Time/></Sequence>
  <Sequence name="05 Notice" from={1260} durationInFrames={360}><Notice/></Sequence>
  <Sequence name="06 Possibility" from={1620} durationInFrames={360}><Possibility/></Sequence>
  <Sequence name="07 Your plan" from={1980} durationInFrames={360}><YourPlan/></Sequence>
  <Sequence name="08 Whole day" from={2340} durationInFrames={360}><WholeDay/></Sequence>
  <Sequence name="09 Ahead" from={2700} durationInFrames={240}><Ahead/></Sequence>
  <Sequence name="10 Persoo" from={2940} durationInFrames={300}><Ending/></Sequence>
</AbsoluteFill>;
const PreviewShot: React.FC<{screen:string}> = ({screen}) => {
  const frame=useCurrentFrame();
  return <AbsoluteFill style={{opacity:interpolate(frame,[0,9],[0,1],clamp)}}><Img src={staticFile(`ui/${screen}.png`)} style={{width:'100%',height:'100%',objectFit:'contain'}}/></AbsoluteFill>;
};
export const PreviewConcept = () => {
  const {height}=useVideoConfig();
  return <AbsoluteFill style={{backgroundColor:paper,fontFamily:'"Helvetica Neue", Helvetica, Arial, sans-serif'}}><Audio src={staticFile('preview-score.wav')}/>
    <Sequence name="Dictation" durationInFrames={120}><PreviewShot screen="dictation"/></Sequence>
    <Sequence name="Receipt" from={120} durationInFrames={120}><PreviewShot screen="purchase"/></Sequence>
    <Sequence name="Savings" from={240} durationInFrames={150}><PreviewShot screen="savings"/></Sequence>
    <Sequence name="Plans" from={390} durationInFrames={120}><PreviewShot screen="plans"/></Sequence>
    <Sequence name="Fitness" from={510} durationInFrames={120}><PreviewShot screen="fitness"/></Sequence>
    <Sequence name="Reminder" from={630} durationInFrames={90}><PreviewShot screen="reminder"/></Sequence>
    <div style={{position:'absolute',top:height-24,left:0,right:0,textAlign:'center',fontSize:16,fontWeight:500,color:'#56645D',backgroundColor:paper}}>Design prototype · Synthetic data</div>
  </AbsoluteFill>;
};
