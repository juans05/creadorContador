import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import Button from '../components/Common/Button';
import Icon from '../components/Common/Icon';
import Card from '../components/Common/Card';

const Register = () => {
  const navigate = useNavigate();
  const { register } = useAuth();

  const [formData, setFormData] = useState({
    email: '',
    password: '',
    confirmPassword: '',
    name: '',
    phone: '',
    birthDate: '',
    acceptTerms: false,
    accept18: false,
  });

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleChange = (field, value) => {
    setFormData({ ...formData, [field]: value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (formData.password !== formData.confirmPassword) {
      setError('Las contraseñas no coinciden');
      return;
    }
    
    setLoading(true);
    setError('');

    try {
      const result = await register(formData);
      if (result.success) {
        navigate('/verify-email', { state: { userId: result.data.userId } });
      } else {
        setError(result.error || 'Error al registrarse');
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
      <div className="absolute top-0 -left-20 w-96 h-96 bg-primary/10 blur-[120px] rounded-full" />
      <div className="absolute bottom-0 -right-20 w-96 h-96 bg-tertiary/10 blur-[120px] rounded-full" />

      <Link to="/" className="no-underline mb-12 relative z-10">
        <span className="font-display font-black text-4xl italic tracking-tighter text-gradient">
          LUXOR
        </span>
      </Link>

      <div className="w-full max-w-md relative z-10">
        <div className="text-center mb-10">
          <h1 className="text-3xl font-display font-black text-white mb-2">BIENVENIDO A LUXOR</h1>
          <p className="text-slate-400 font-medium">Crea tu cuenta de Fan y empieza a brillar.</p>
        </div>

        <Card className="p-8 border-white/5">
          <form onSubmit={handleSubmit} className="space-y-5">
            <div className="grid grid-cols-2 gap-4 mb-8">
              <button 
                type="button"
                className="flex flex-col items-center gap-2 p-4 rounded-2xl bg-primary/20 border-2 border-primary text-primary transition-all"
              >
                <Icon name="favorite" className="text-2xl" fill={true} />
                <span className="text-[10px] font-black uppercase tracking-widest">Soy Fan</span>
              </button>
              <Link 
                to="/register/creadora"
                className="flex flex-col items-center gap-2 p-4 rounded-2xl glass-panel border-2 border-white/5 text-slate-500 hover:border-white/20 transition-all no-underline"
              >
                <Icon name="auto_awesome" className="text-2xl" />
                <span className="text-[10px] font-black uppercase tracking-widest">Soy Creadora</span>
              </Link>
            </div>

            <div className="space-y-1">
              <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest ml-1">Nombre Completo</label>
              <div className="relative">
                <Icon name="person" className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-500" />
                <input
                  type="text"
                  placeholder="Ej. Juan Pérez"
                  value={formData.name}
                  onChange={(e) => handleChange('name', e.target.value)}
                  className="w-full bg-surface/50 border border-white/5 rounded-2xl pl-12 pr-4 py-3 text-white focus:border-primary/50 focus:ring-1 focus:ring-primary/20 outline-none transition-all"
                  required
                />
              </div>
            </div>

            <div className="space-y-1">
              <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest ml-1">Email</label>
              <div className="relative">
                <Icon name="mail" className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-500" />
                <input
                  type="email"
                  placeholder="tu@email.com"
                  value={formData.email}
                  onChange={(e) => handleChange('email', e.target.value)}
                  className="w-full bg-surface/50 border border-white/5 rounded-2xl pl-12 pr-4 py-3 text-white focus:border-primary/50 focus:ring-1 focus:ring-primary/20 outline-none transition-all"
                  required
                />
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1">
                <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest ml-1">Celular</label>
                <input
                  type="tel"
                  placeholder="987654321"
                  value={formData.phone}
                  onChange={(e) => handleChange('phone', e.target.value)}
                  className="w-full bg-surface/50 border border-white/5 rounded-2xl px-4 py-3 text-white focus:border-primary/50 outline-none transition-all"
                  required
                />
              </div>
              <div className="space-y-1">
                <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest ml-1">Fecha Nac.</label>
                <input
                  type="date"
                  value={formData.birthDate}
                  onChange={(e) => handleChange('birthDate', e.target.value)}
                  className="w-full bg-surface/50 border border-white/5 rounded-2xl px-4 py-3 text-white focus:border-primary/50 outline-none transition-all"
                  required
                />
              </div>
            </div>

            <div className="space-y-1">
              <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest ml-1">Contraseña</label>
              <div className="relative">
                <Icon name="lock" className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-500" />
                <input
                  type="password"
                  placeholder="••••••••"
                  value={formData.password}
                  onChange={(e) => handleChange('password', e.target.value)}
                  className="w-full bg-surface/50 border border-white/5 rounded-2xl pl-12 pr-4 py-3 text-white focus:border-primary/50 outline-none transition-all"
                  required
                />
              </div>
            </div>

            <div className="space-y-1">
              <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest ml-1">Confirmar</label>
              <input
                type="password"
                placeholder="••••••••"
                value={formData.confirmPassword}
                onChange={(e) => handleChange('confirmPassword', e.target.value)}
                className="w-full bg-surface/50 border border-white/5 rounded-2xl px-4 py-3 text-white focus:border-primary/50 outline-none transition-all"
                required
              />
            </div>

            <div className="pt-2 space-y-3">
              <label className="flex items-center gap-3 cursor-pointer group">
                <input 
                  type="checkbox" 
                  checked={formData.accept18}
                  onChange={(e) => handleChange('accept18', e.target.checked)}
                  className="w-5 h-5 rounded-lg border-white/10 bg-surface text-primary focus:ring-primary/20" 
                  required
                />
                <span className="text-xs text-slate-400 group-hover:text-slate-200 transition-colors">Tengo 18+ años</span>
              </label>
              <label className="flex items-center gap-3 cursor-pointer group">
                <input 
                  type="checkbox" 
                  checked={formData.acceptTerms}
                  onChange={(e) => handleChange('acceptTerms', e.target.checked)}
                  className="w-5 h-5 rounded-lg border-white/10 bg-surface text-primary focus:ring-primary/20" 
                  required
                />
                <span className="text-xs text-slate-400 group-hover:text-slate-200 transition-colors">Acepto Términos y Privacidad</span>
              </label>
            </div>

            {error && <p className="text-danger text-xs font-bold text-center">{error}</p>}

            <Button type="submit" className="w-full py-4 mt-4" loading={loading}>
              Crear mi Cuenta
            </Button>
          </form>
        </Card>

        <div className="mt-8 text-center">
          <p className="text-slate-500 text-sm font-medium">
            ¿Ya tienes cuenta?{' '}
            <Link to="/login" className="text-primary font-bold hover:underline">
              Inicia Sesión
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
};

export default Register;