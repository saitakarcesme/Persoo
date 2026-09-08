import { Composition } from 'remotion';
import { LaunchFilm, PreviewConcept } from './Composition';
import './index.css';
export const RemotionRoot = () => <>
  <Composition id="PersooLaunch" component={LaunchFilm} durationInFrames={3240} fps={60} width={1920} height={1080} />
  <Composition id="PersooPreviewConcept" component={PreviewConcept} durationInFrames={720} fps={30} width={886} height={1920} />
</>;
