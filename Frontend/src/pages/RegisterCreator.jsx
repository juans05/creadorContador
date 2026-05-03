import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import creatorsService from '../services/creators';
import Button from '../components/Common/Button';
import Icon from '../components/Common/Icon';
import Card from '../components/Common/Card';

const RegisterCreator = () => {
  const navigate = useNavigate();
  const { user } = useAuth();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [formData, setFormData] = useState({
    username: '',
    bio: '',
    category: 'Modelo',
    yapeNumber: '',
  });

  const categories = ['Modelo', 'Fitness', 'Gamer', 'Música', 'Arte', 'Influencer'];

  const handleChange = (field, value) => {
    setFormData({ ...formData, [field]: value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await creatorsService.register(formData);
      if (response.success) {
        navigate('/dashboard/influencer');
      } else {
        setError(response.message || 'Error al registrarse como creadora');
      }
    } catch (err) {
      setError('Error de conexión. Intenta de nuevo.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-background flex flex-col items-center justify-center px-6 py-12 relative overflow-hidden">
      {/* Background Decor */}
      <div className="absolute top-0 -right-20 w-96 h-96 bg-primary/10 blur-[120px] rounded-full" />
      <div className="absolute bottom-0 -left-20 w-96 h-96 bg-tertiary/10 blur-[120px] rounded-full" />

      <Link to="/" className="no-underline mb-12 relative z-10">
        <span className="font-display font-black text-4xl italic tracking-tighter text-gradient">
          LUXOR
        </span>
      </Link>

      <div className="w-full max-w-md relative z-10">
        <div className="text-center mb-10">
          <h1 className="text-3xl font-display font-black text-white mb-2 uppercase italic">Únete como Creadora</h1>
          <p className="text-slate-400 font-medium">Empieza a monetizar tu pasión en LUXOR.</p>
        </div>

        <Card className="p-8 border-white/5">
          <form onSubmit={handleSubmit} className="space-y-6">
            <div className="space-y-1">
              <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest ml-1">Username Único</label>
              <div className="relative">
                <div className="absolute left-4 top-1/2 -translate-y-1/2 font-display font-black text-primary">@</div>
                <input
                  type="text"
                  placeholder="tu_nombre"
                  value={formData.username}
                  onChange={(e) => handleChange('username', e.target.value)}
                  className="w-full bg-surface/50 border border-white/5 rounded-2xl pl-10 pr-4 py-3 text-white font-display font-bold focus:border-primary/50 focus:ring-1 focus:ring-primary/20 outline-none transition-all"
                  required
                />
              </div>
            </div>

            <div className="space-y-1">
              <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest ml-1">Categoría Principal</label>
              <div className="relative">
                <Icon name="category" className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-500" />
                <select
                  value={formData.category}
                  onChange={(e) => handleChange('category', e.target.value)}
                  className="w-full bg-surface/50 border border-white/5 rounded-2xl pl-12 pr-4 py-3 text-white focus:border-primary/50 outline-none transition-all appearance-none"
                >
                  {categories.map(c => <option key={c} value={c} className="bg-surface">{c}</option>)}
                </select>
                <Icon name="expand_more" className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-500 pointer-events-none" />
              </div>
            </div>

            <div className="space-y-1">
              <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest ml-1">Biografía Corta</label>
              <textarea
                placeholder="Cuéntale a tus fans quién eres..."
                value={formData.bio}
                onChange={(e) => handleChange('bio', e.target.value)}
                className="w-full bg-surface/50 border border-white/5 rounded-2xl px-4 py-3 text-white focus:border-primary/50 outline-none transition-all resize-none h-24"
                required
              />
            </div>

            <div className="space-y-1">
              <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest ml-1">Número de Yape / Plin</label>
              <div className="relative">
                <Icon name="smartphone" className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-500" />
                <input
                  type="tel"
                  placeholder="987 654 321"
                  value={formData.yapeNumber}
                  onChange={(e) => handleChange('yapeNumber', e.target.value)}
                  className="w-full bg-surface/50 border border-white/5 rounded-2xl pl-12 pr-4 py-3 text-white focus:border-primary/50 outline-none transition-all"
                  required
                />
              </div>
              <p className="text-[10px] text-slate-600 ml-1">Para tus cobros locales y retiros directos.</p>
            </div>

            {error && <p className="text-danger text-xs font-bold text-center">{error}</p>}

            <Button type="submit" className="w-full py-4 mt-4" loading={loading}>
              <div className="flex items-center justify-center gap-2">
                <Icon name="rocket_launch" fill={true} />
                Unirme como Creadora
              </div>
            </Button>
          </form>
        </Card>

        <div className="mt-8 text-center">
          <p className="text-slate-500 text-sm font-medium">
            ¿Ya tienes cuenta de creadora?{' '}
            <Link to="/login" className="text-primary font-bold hover:underline">
              Inicia Sesión
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
};

export default RegisterCreator;