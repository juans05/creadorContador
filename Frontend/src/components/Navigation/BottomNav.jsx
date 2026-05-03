import { NavLink } from 'react-router-dom';
import Icon from '../Common/Icon';
import { useAuth } from '../../context/AuthContext';

const BottomNav = () => {
  const { user } = useAuth();
  const isCreator = user?.role === 'influencer' || user?.role === 'creator';

  const navItems = [
    { to: '/home', icon: 'movie', label: 'Feed' },
    { to: '/search', icon: 'grid_view', label: 'Grilla' },
    { 
      to: '/crear', 
      icon: 'add_circle', 
      label: 'Crear', 
      special: true 
    },
    { to: '/chat', icon: 'chat_bubble', label: 'Chat' },
    { to: '/dashboard', icon: 'person', label: 'Perfil' },
  ];

  return (
    <nav className="fixed bottom-0 left-0 w-full z-50 bg-[#0F111A]/80 backdrop-blur-xl border-t border-white/5 flex justify-between items-center px-6 pb-6 pt-4 shadow-[0_-10px_40px_rgba(0,0,0,0.5)]">
      {navItems.map((item) => {
        // Only show "Crear" for creators
        if (item.special && !isCreator) return null;

        return (
          <NavLink
            key={item.to}
            to={item.to}
            className={({ isActive }) => `
              flex flex-col items-center justify-center transition-all duration-300 active:scale-90 no-underline
              ${item.special 
                ? 'text-primary scale-110 mb-4' 
                : isActive 
                  ? 'text-primary drop-shadow-[0_0_8px_rgba(255,77,109,0.5)]' 
                  : 'text-slate-500 hover:text-primary'}
            `}
          >
            {({ isActive }) => (
              <>
                <div className={item.special ? 'bg-primary/20 p-3 rounded-full border-2 border-primary shadow-[0_0_20px_rgba(255,77,109,0.3)] animate-pulse' : ''}>
                  <Icon name={item.icon} fill={isActive || item.special} className={item.special ? 'text-3xl' : 'text-2xl'} />
                </div>
                {!item.special && (
                  <span className="font-display text-[8px] font-black uppercase tracking-widest mt-1.5">
                    {item.label}
                  </span>
                )}
              </>
            )}
          </NavLink>
        );
      })}
    </nav>
  );
};

export default BottomNav;
