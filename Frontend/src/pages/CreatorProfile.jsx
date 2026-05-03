import { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import creatorsService from '../services/creators';
import subscriptionsService from '../services/subscriptions';
import { tipsService } from '../services/content';
import TopHeader from '../components/Navigation/TopHeader';
import BottomNav from '../components/Navigation/BottomNav';
import Icon from '../components/Common/Icon';
import Card from '../components/Common/Card';
import Button from '../components/Common/Button';
import Modal from '../components/Common/Modal';

const CreatorProfile = () => {
  const { username } = useParams();
  const [creator, setCreator] = useState(null);
  const [loading, setLoading] = useState(true);
  const [showSubscribeModal, setShowSubscribeModal] = useState(false);
  const [showTipModal, setShowTipModal] = useState(false);
  const [tipAmount, setTipAmount] = useState(10);

  useEffect(() => {
    fetchProfile();
  }, [username]);

  const fetchProfile = async () => {
    try {
      setLoading(true);
      const response = await creatorsService.getProfile(username);
      if (response.success) {
        setCreator(response.data);
      }
    } catch (error) {
      console.error('Error fetching profile:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <div className="min-h-screen bg-background" />;

  return (
    <div className="min-h-screen pb-24">
      <TopHeader showBack={true} />
      
      {/* Profile Cover & Header */}
      <div className="relative">
        <div className="h-48 bg-gradient-to-r from-primary to-tertiary opacity-30" />
        <div className="px-5 -mt-16">
          <div className="flex items-end justify-between mb-4">
            <div className="relative">
              <div className="w-32 h-32 rounded-full p-1 bg-background">
                <img 
                  src={creator?.profilePicture || `https://ui-avatars.com/api/?name=${creator?.username}&background=random`} 
                  className="w-full h-full rounded-full object-cover border-2 border-primary"
                />
              </div>
              <div className="absolute bottom-2 right-2 bg-secondary rounded-full p-1 border-2 border-background">
                <Icon name="verified" className="text-background text-sm" fill={true} />
              </div>
            </div>
            <div className="flex gap-2 mb-2">
              <Button variant="secondary" size="sm" onClick={() => setShowTipModal(true)}>
                <Icon name="volunteer_activism" className="text-xl" />
              </Button>
              <Button variant="secondary" size="sm">
                <Icon name="share" className="text-xl" />
              </Button>
            </div>
          </div>

          <div className="space-y-1">
            <h1 className="font-display text-2xl font-black text-white flex items-center gap-2">
              {creator?.name || creator?.username}
            </h1>
            <p className="text-primary font-bold text-sm">@{creator?.username}</p>
          </div>

          <p className="mt-4 text-slate-300 text-sm leading-relaxed">
            {creator?.bio || "Sin biografía disponible."}
          </p>

          <div className="mt-6 flex gap-8 items-center border-y border-white/5 py-4">
            <div className="text-center">
              <p className="text-lg font-display font-black text-white">{creator?.photos?.length || 0}</p>
              <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest">Contenido</p>
            </div>
            <div className="text-center border-x border-white/5 px-8">
              <p className="text-lg font-display font-black text-white">{creator?.subscribersCount || 0}</p>
              <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest">Fans</p>
            </div>
            <div className="text-center">
              <p className="text-lg font-display font-black text-white">{creator?.rating || '5.0'}</p>
              <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest">Rating</p>
            </div>
          </div>

          <Button 
            className="w-full mt-6 py-4 text-lg" 
            onClick={() => setShowSubscribeModal(true)}
          >
            Suscribirse a @{creator?.username}
          </Button>
        </div>
      </div>

      {/* Gallery Section */}
      <section className="mt-8 px-5">
        <h2 className="font-display font-black text-white text-lg mb-4">Galería</h2>
        <div className="grid grid-cols-3 gap-2">
          {creator?.photos?.map((item) => (
            <div key={item.photoId} className="aspect-square relative rounded-xl overflow-hidden group">
              <img 
                src={item.hasAccess ? item.url : (item.thumbnail || 'https://via.placeholder.com/400?text=Premium')} 
                className={`w-full h-full object-cover ${!item.hasAccess ? 'blur-md grayscale' : ''}`}
              />
              {!item.hasAccess && (
                <div className="absolute inset-0 bg-black/40 backdrop-blur-sm flex items-center justify-center">
                  <Icon name="lock" className="text-white text-2xl" fill={true} />
                </div>
              )}
            </div>
          ))}
        </div>
      </section>

      <BottomNav />

      {/* Tip Modal */}
      <Modal isOpen={showTipModal} onClose={() => setShowTipModal(false)} title="Enviar Propina">
        <div className="p-6 space-y-6">
          <div className="grid grid-cols-3 gap-3">
            {[10, 20, 50, 100, 200, 500].map(amt => (
              <button 
                key={amt}
                onClick={() => setTipAmount(amt)}
                className={`py-3 rounded-xl font-display font-bold border-2 transition-all ${tipAmount === amt ? 'bg-primary/20 border-primary text-primary' : 'glass-panel border-white/5 text-slate-400'}`}
              >
                S/ {amt}
              </button>
            ))}
          </div>
          <Button className="w-full py-4" onClick={() => { alert('Tip enviado'); setShowTipModal(false); }}>
            Enviar S/ {tipAmount}
          </Button>
        </div>
      </Modal>
    </div>
  );
};

export default CreatorProfile;