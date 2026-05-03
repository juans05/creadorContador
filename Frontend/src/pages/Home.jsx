import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import creatorsService from '../services/creators';
import TopHeader from '../components/Navigation/TopHeader';
import BottomNav from '../components/Navigation/BottomNav';
import Icon from '../components/Common/Icon';
import Card from '../components/Common/Card';
import VideoReel from '../components/Feed/VideoReel';

const Home = () => {
  const [creators, setCreators] = useState([]);
  const [feedItems, setFeedItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [activeFilter, setActiveFilter] = useState('trending');
  const [viewMode, setViewMode] = useState('grid'); // 'grid' or 'tiktok'

  useEffect(() => {
    fetchFeed();
  }, [activeFilter, viewMode]);

  const fetchFeed = async () => {
    try {
      setLoading(true);
      if (viewMode === 'grid') {
        const response = await creatorsService.getFeed(1, 20, activeFilter);
        if (response.success) {
          setCreators(response.data.creators);
        }
      } else {
        // For TikTok style, we could have a specific endpoint or use the same
        // Mocking some data for the reel
        setFeedItems([
          {
            id: 1,
            url: 'https://assets.mixkit.co/videos/preview/mixkit-girl-dancing-under-a-disco-ball-in-a-nightclub-34537-large.mp4',
            creator: { username: 'valeria_fit', profilePicture: 'https://ui-avatars.com/api/?name=Valeria&background=FF4D6D&color=fff' },
            description: 'Nueva rutina de cardio! 🔥 Prepárate para el verano en LUXOR.',
            likesCount: 1240,
            commentsCount: 85,
            visibility: 'public'
          },
          {
            id: 2,
            url: 'https://assets.mixkit.co/videos/preview/mixkit-young-woman-dancing-in-front-of-a-mirror-34538-large.mp4',
            creator: { username: 'camila_dance', profilePicture: 'https://ui-avatars.com/api/?name=Camila&background=FF8A00&color=fff' },
            description: 'Exclusivo para mis suscriptores diamantes. ✨ ¿Les gusta este look?',
            likesCount: 5200,
            commentsCount: 312,
            visibility: 'exclusive',
            price_diamonds: 50
          }
        ]);
      }
    } catch (error) {
      console.error('Error fetching feed:', error);
    } finally {
      setLoading(false);
    }
  };

  const filters = [
    { id: 'trending', label: 'Tendencias', icon: 'local_fire_department' },
    { id: 'recent', label: 'Recientes', icon: 'schedule' },
    { id: 'premium', label: 'Top Premium', icon: 'star' },
  ];

  return (
    <div className="min-h-screen pb-24 pt-20 bg-background">
      <TopHeader />
      
      {/* View Toggle and Filters */}
      <div className="sticky top-20 z-40 bg-background/80 backdrop-blur-xl py-4 border-b border-white/5">
        <div className="flex items-center justify-between px-5 mb-4">
          <div className="flex gap-2 glass-panel p-1 rounded-2xl border-white/5">
            <button 
              onClick={() => setViewMode('grid')}
              className={`p-2 rounded-xl transition-all ${viewMode === 'grid' ? 'bg-primary text-white shadow-lg shadow-primary/20' : 'text-slate-500'}`}
            >
              <Icon name="grid_view" />
            </button>
            <button 
              onClick={() => setViewMode('tiktok')}
              className={`p-2 rounded-xl transition-all ${viewMode === 'tiktok' ? 'bg-primary text-white shadow-lg shadow-primary/20' : 'text-slate-500'}`}
            >
              <Icon name="movie" />
            </button>
          </div>
          
          <div className="flex gap-3 overflow-x-auto scrollbar-hide flex-1 ml-4">
            {filters.map((filter) => (
              <button
                key={filter.id}
                onClick={() => setActiveFilter(filter.id)}
                className={`
                  flex items-center gap-2 px-5 py-2 rounded-xl font-display font-black text-[10px] uppercase tracking-widest whitespace-nowrap transition-all
                  ${activeFilter === filter.id 
                    ? 'bg-white text-black' 
                    : 'bg-surface border border-white/5 text-slate-500'}
                `}
              >
                {filter.label}
              </button>
            ))}
          </div>
        </div>
      </div>

      <main className="px-5 mt-6">
        {viewMode === 'grid' ? (
          <>
            <h2 className="font-display text-2xl font-black text-white mb-6 flex items-center gap-2 uppercase italic tracking-tighter">
              <span className="text-gradient">DESCUBRE</span> CREADORAS
            </h2>

            {loading ? (
              <div className="grid grid-cols-2 gap-4">
                {[1, 2, 3, 4].map((n) => (
                  <div key={n} className="aspect-[3/4] rounded-3xl bg-surface animate-pulse border border-white/5"></div>
                ))}
              </div>
            ) : (
              <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                {creators.map((creator) => (
                  <Link 
                    key={creator.influencerId} 
                    to={`/creadora/${creator.username}`}
                    className="no-underline group"
                  >
                    <Card padding="none" className="aspect-[3/4] relative overflow-hidden group border-white/5 hover:border-primary/50 transition-all">
                      <img 
                        src={creator.profilePicture || `https://ui-avatars.com/api/?name=${creator.username}&background=random`} 
                        alt={creator.username}
                        className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110"
                      />
                      
                      <div className="absolute inset-x-0 bottom-0 p-4 bg-gradient-to-t from-black/90 via-black/40 to-transparent">
                        <div className="flex items-center gap-2 mb-1">
                          <span className="font-display font-black text-white truncate text-sm">
                            @{creator.username}
                          </span>
                          <Icon name="verified" className="text-secondary text-xs" fill={true} />
                        </div>
                        
                        <div className="flex items-center justify-between text-[8px] font-black text-slate-300 uppercase tracking-widest">
                          <div className="flex items-center gap-1">
                            <Icon name="star" className="text-tertiary text-[10px]" fill={true} />
                            {creator.rating || '5.0'}
                          </div>
                          <div>
                            {creator.subscribersCount || '0'} FANS
                          </div>
                        </div>
                      </div>

                      {creator.rating > 4.8 && (
                        <div className="absolute top-3 right-3 bg-primary/20 backdrop-blur-md border border-primary/30 rounded-full px-2 py-1 flex items-center gap-1">
                          <Icon name="local_fire_department" className="text-primary text-[10px]" fill={true} />
                          <span className="text-[9px] font-black text-primary">HOT</span>
                        </div>
                      )}
                    </Card>
                  </Link>
                ))}
              </div>
            )}
          </>
        ) : (
          <div className="snap-y snap-mandatory overflow-y-auto h-[calc(100vh-260px)] scrollbar-hide">
            {feedItems.map(item => (
              <VideoReel key={item.id} content={item} />
            ))}
            {loading && (
              <div className="w-full h-full flex items-center justify-center">
                <Icon name="sync" className="text-primary text-4xl animate-spin" />
              </div>
            )}
          </div>
        )}
      </main>

      <BottomNav />
    </div>
  );
};

export default Home;