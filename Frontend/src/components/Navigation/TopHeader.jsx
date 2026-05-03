import { Link, useNavigate } from 'react-router-dom';
import Icon from '../Common/Icon';

const TopHeader = ({ title, showBack = false, rightElement }) => {
  const navigate = useNavigate();

  return (
    <header className="fixed top-0 w-full z-50 bg-[#0F111A]/80 backdrop-blur-xl border-b border-white/5 flex justify-between items-center px-5 h-16 shadow-2xl shadow-primary/5">
      <div className="flex items-center gap-4">
        {showBack && (
          <button onClick={() => navigate(-1)} className="active:scale-95 duration-200">
            <Icon name="arrow_back" className="text-slate-400" />
          </button>
        )}
        <Link to="/home" className="no-underline">
          <span className="font-display antialiased text-2xl font-black italic tracking-tighter text-transparent bg-clip-text bg-gradient-to-r from-primary to-tertiary">
            LUXOR
          </span>
        </Link>
        {title && (
          <h1 className="font-display font-bold text-lg text-white ml-2">{title}</h1>
        )}
      </div>
      
      <div className="flex items-center gap-4">
        {rightElement || (
          <div className="flex items-center gap-4">
            <Link to="/wallet" className="text-slate-400 hover:text-primary transition-colors">
              <Icon name="account_balance_wallet" />
            </Link>
            <button className="text-slate-400 hover:text-primary transition-colors">
              <Icon name="notifications" />
            </button>
            <Link to="/dashboard" className="w-8 h-8 rounded-full overflow-hidden border border-white/20">
              <img 
                src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop" 
                alt="Profile" 
                className="w-full h-full object-cover"
              />
            </Link>
          </div>
        )}
      </div>
    </header>
  );
};

export default TopHeader;
