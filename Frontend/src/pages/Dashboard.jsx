import { useState, useEffect } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import creatorsService from '../services/creators';
import diamondsService from '../services/diamonds';
import contentService from '../services/content';
import TopHeader from '../components/Navigation/TopHeader';
import BottomNav from '../components/Navigation/BottomNav';
import Icon from '../components/Common/Icon';
import Card from '../components/Common/Card';
import Button from '../components/Common/Button';

const Dashboard = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const { user, logout } = useAuth();
  const [activeTab, setActiveTab] = useState('summary');
  const [stats, setStats] = useState(null);
  const [transactions, setTransactions] = useState([]);
  const [myContent, setMyContent] = useState([]);
  const [loading, setLoading] = useState(true);
  const [balance, setBalance] = useState(0);

  const isCreator = user?.type === 'creator' || location.pathname.includes('influencer');

  useEffect(() => {
    if (isCreator) {
      fetchCreatorData();
    } else {
      fetchUserData();
    }
  }, [isCreator]);

  const fetchCreatorData = async () => {
    try {
      setLoading(true);
      const [statsRes, contentRes] = await Promise.all([
        creatorsService.getDashboardStats(),
        contentService.getMyContent()
      ]);
      
      if (statsRes.success) {
        setStats(statsRes.data.stats);
        setTransactions(statsRes.data.recentTransactions);
      }
      if (contentRes.success) {
        setMyContent(contentRes.data);
      }
    } catch (error) {
      console.error('Error fetching creator data:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchUserData = async () => {
    try {
      setLoading(true);
      const [balanceRes, historyRes] = await Promise.all([
        diamondsService.getBalance(),
        diamondsService.getHistory()
      ]);
      
      if (balanceRes.success) {
        setBalance(balanceRes.data.balance);
      }
      if (historyRes.success) {
        setTransactions(historyRes.data);
      }
    } catch (error) {
      console.error('Error fetching user data:', error);
    } finally {
      setLoading(false);
    }
  };

  const tabs = isCreator 
    ? [
        { id: 'summary', label: 'Estudio', icon: 'dashboard' },
        { id: 'content', label: 'Contenido', icon: 'movie' },
        { id: 'earnings', label: 'Finanzas', icon: 'payments' },
      ]
    : [
        { id: 'summary', label: 'Resumen', icon: 'home' },
        { id: 'diamonds', label: 'Diamantes', icon: 'diamond' },
        { id: 'history', label: 'Historial', icon: 'history' },
      ];

  return (
    <div className="min-h-screen pb-24 pt-20">
      <TopHeader title={isCreator ? "Creator Studio" : "Mi Cuenta"} />
      
      {/* Tabs Navigation */}
      <div className="flex gap-2 px-5 mb-8 overflow-x-auto scrollbar-hide">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id)}
            className={`
              flex items-center gap-2 px-5 py-2.5 rounded-xl font-display font-bold text-sm whitespace-nowrap transition-all duration-300
              ${activeTab === tab.id 
                ? 'bg-primary/20 text-primary border border-primary/30' 
                : 'glass-panel text-slate-500 border-white/5'}
            `}
          >
            <Icon name={tab.icon} className="text-xl" fill={activeTab === tab.id} />
            {tab.label}
          </button>
        ))}
      </div>

      <main className="px-5">
        {activeTab === 'summary' && isCreator && (
          <div className="space-y-6">
            {/* Earnings Cards */}
            <div className="grid grid-cols-2 gap-4">
              <Card className="bg-gradient-to-br from-primary/20 to-transparent border-primary/20">
                <p className="text-[10px] font-black text-primary uppercase tracking-widest mb-1">Hoy</p>
                <p className="text-2xl font-display font-black text-white">S/ {stats?.todayEarnings || '0.00'}</p>
                <div className="mt-4 flex items-center gap-1 text-[10px] font-bold text-secondary">
                  <Icon name="trending_up" className="text-sm" />
                  +12% vs ayer
                </div>
              </Card>
              <Card>
                <p className="text-[10px] font-black text-slate-500 uppercase tracking-widest mb-1">Total</p>
                <p className="text-2xl font-display font-black text-white">S/ {stats?.totalEarnings || '0.00'}</p>
                <div className="mt-4 flex items-center gap-1 text-[10px] font-bold text-slate-400">
                  Acumulado
                </div>
              </Card>
            </div>

            {/* Quick Actions */}
            <div className="grid grid-cols-2 gap-4">
              <Link to="/studio" className="no-underline">
                <Button variant="primary" className="w-full py-4 rounded-2xl flex-col gap-1">
                  <Icon name="add_circle" className="text-2xl" fill={true} />
                  <span className="text-xs">Subir Contenido</span>
                </Button>
              </Link>
              <Button variant="secondary" className="w-full py-4 rounded-2xl flex-col gap-1">
                <Icon name="sensors" className="text-2xl" />
                <span className="text-xs">Ir a Live</span>
              </Button>
            </div>

            {/* Recent Activity */}
            <h3 className="font-display font-bold text-white text-lg mt-8 flex items-center gap-2">
              <Icon name="history" className="text-primary" />
              Actividad Reciente
            </h3>
            <div className="space-y-3">
              {transactions.map((t) => (
                <Card key={t.id} padding="sm" className="flex items-center justify-between border-white/5">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-surface flex items-center justify-center border border-white/10">
                      <Icon name={t.type === 'tip' ? 'volunteer_activism' : 'subscriptions'} className="text-primary text-xl" />
                    </div>
                    <div>
                      <p className="text-sm font-bold text-white">{t.userName}</p>
                      <p className="text-[10px] font-medium text-slate-500 uppercase tracking-tighter">
                        {t.type === 'tip' ? 'Envió una propina' : 'Nueva Suscripción'}
                      </p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="text-sm font-black text-secondary">+ S/ {t.amount}</p>
                    <p className="text-[10px] text-slate-600">Hace 2h</p>
                  </div>
                </Card>
              ))}
              {transactions.length === 0 && (
                <div className="text-center py-8 text-slate-500">
                  <p>Aún no hay actividad</p>
                </div>
              )}
            </div>
          </div>
        )}

        {activeTab === 'summary' && !isCreator && (
          <div className="space-y-6">
            <Card className="bg-gradient-to-br from-primary to-tertiary p-6 border-none relative overflow-hidden">
              <div className="relative z-10">
                <p className="text-xs font-black text-white/80 uppercase tracking-widest mb-1">Mi Balance</p>
                <div className="flex items-end gap-2 mb-6">
                  <span className="text-5xl font-display font-black text-white">{balance}</span>
                  <Icon name="diamond" className="text-white text-2xl mb-1" fill={true} />
                </div>
                <Link to="/diamantes">
                  <Button variant="secondary" className="bg-white/20 border-white/30 text-white backdrop-blur-md">
                    Comprar Diamantes
                  </Button>
                </Link>
              </div>
              <Icon name="diamond" className="absolute -bottom-10 -right-10 text-white/10 text-[200px]" fill={true} />
            </Card>

            <h3 className="font-display font-bold text-white text-lg mt-8">Mis Suscripciones</h3>
            <div className="flex gap-4 overflow-x-auto pb-4 scrollbar-hide">
              {/* Mock Subs */}
              {[1, 2, 3].map((s) => (
                <div key={s} className="flex-shrink-0 w-24">
                  <div className="w-24 h-24 rounded-full p-1 border-2 border-primary mb-2">
                    <img 
                      src={`https://i.pravatar.cc/150?u=${s}`} 
                      className="w-full h-full rounded-full object-cover" 
                    />
                  </div>
                  <p className="text-[10px] font-bold text-center text-white truncate">@creadora_{s}</p>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Other tabs can be implemented similarly */}
      </main>

      <BottomNav />
    </div>
  );
};

export default Dashboard;