import { useState, useRef, useEffect } from 'react';
import Icon from '../Common/Icon';
import Button from '../Common/Button';
import { Link } from 'react-router-dom';

const VideoReel = ({ content }) => {
  const videoRef = useRef(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [isMuted, setIsMuted] = useState(true);

  useEffect(() => {
    const options = {
      root: null,
      rootMargin: '0px',
      threshold: 0.5
    };

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          videoRef.current?.play().catch(e => console.log('Autoplay blocked'));
          setIsPlaying(true);
        } else {
          videoRef.current?.pause();
          setIsPlaying(false);
        }
      });
    }, options);

    if (videoRef.current) {
      observer.observe(videoRef.current);
    }

    return () => {
      if (videoRef.current) {
        observer.unobserve(videoRef.current);
      }
    };
  }, []);

  const togglePlay = () => {
    if (isPlaying) {
      videoRef.current?.pause();
    } else {
      videoRef.current?.play();
    }
    setIsPlaying(!isPlaying);
  };

  return (
    <div className="relative w-full h-[calc(100vh-160px)] snap-start bg-black rounded-3xl overflow-hidden mb-4 group shadow-2xl">
      {/* Video element */}
      <video
        ref={videoRef}
        src={content.url}
        className="w-full h-full object-cover"
        loop
        muted={isMuted}
        onClick={togglePlay}
        playsInline
      />

      {/* Interactions Overlay */}
      <div className="absolute right-4 bottom-24 flex flex-col items-center gap-6 z-20">
        <div className="flex flex-col items-center">
          <button className="w-14 h-14 bg-white/10 backdrop-blur-xl rounded-full flex items-center justify-center border border-white/10 hover:bg-primary/20 hover:border-primary transition-all group/btn">
            <Icon name="favorite" className="text-3xl group-hover/btn:scale-110 transition-transform" fill={content.hasLiked} />
          </button>
          <span className="text-xs font-black mt-2 drop-shadow-md">{content.likesCount || 0}</span>
        </div>

        <div className="flex flex-col items-center">
          <button className="w-14 h-14 bg-white/10 backdrop-blur-xl rounded-full flex items-center justify-center border border-white/10 hover:bg-secondary/20 hover:border-secondary transition-all group/btn">
            <Icon name="chat_bubble" className="text-2xl group-hover/btn:scale-110 transition-transform" />
          </button>
          <span className="text-xs font-black mt-2 drop-shadow-md">{content.commentsCount || 0}</span>
        </div>

        <div className="flex flex-col items-center">
          <button className="w-14 h-14 bg-white/10 backdrop-blur-xl rounded-full flex items-center justify-center border border-white/10 hover:bg-tertiary/20 hover:border-tertiary transition-all group/btn">
            <Icon name="diamond" className="text-2xl text-tertiary group-hover/btn:scale-110 transition-transform" fill={true} />
          </button>
          <span className="text-[10px] font-black mt-1 uppercase text-tertiary drop-shadow-md">Propina</span>
        </div>
      </div>

      {/* Info Overlay */}
      <div className="absolute inset-x-0 bottom-0 p-8 bg-gradient-to-t from-black/80 via-black/40 to-transparent z-10">
        <Link to={`/creadora/${content.creator?.username}`} className="flex items-center gap-4 no-underline mb-4 group/author">
          <div className="w-12 h-12 rounded-full border-2 border-primary overflow-hidden shadow-lg shadow-primary/20 group-hover/author:scale-110 transition-transform">
            <img src={content.creator?.profilePicture} alt="Profile" className="w-full h-full object-cover" />
          </div>
          <div>
            <div className="flex items-center gap-1">
              <span className="font-display font-black text-white text-lg tracking-tight">@{content.creator?.username}</span>
              <Icon name="verified" className="text-secondary text-sm" fill={true} />
            </div>
            <span className="text-xs font-medium text-slate-300">Monetizando su pasión</span>
          </div>
        </Link>
        
        <p className="text-sm text-white/90 font-medium mb-4 line-clamp-2 max-w-[80%]">
          {content.description || 'Descubre mi nuevo contenido exclusivo en LUXOR. 🔥'}
        </p>

        {content.visibility === 'exclusive' && (
          <div className="inline-flex items-center gap-3 glass-panel px-4 py-2 rounded-xl border-tertiary/30">
            <Icon name="lock" className="text-tertiary text-sm" fill={true} />
            <span className="text-[10px] font-black uppercase text-tertiary tracking-widest">Desbloquea por {content.price_diamonds} Diamantes</span>
          </div>
        )}
      </div>

      {/* Play/Pause indicator */}
      {!isPlaying && (
        <div className="absolute inset-0 flex items-center justify-center pointer-events-none bg-black/20">
          <Icon name="play_arrow" className="text-8xl text-white/40" fill={true} />
        </div>
      )}

      {/* Mute toggle */}
      <button 
        onClick={(e) => { e.stopPropagation(); setIsMuted(!isMuted); }}
        className="absolute top-6 right-6 w-10 h-10 bg-black/40 backdrop-blur-md rounded-full flex items-center justify-center border border-white/10 z-20"
      >
        <Icon name={isMuted ? 'volume_off' : 'volume_up'} className="text-xl text-white" />
      </button>
    </div>
  );
};

export default VideoReel;
