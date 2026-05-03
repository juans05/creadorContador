import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import Button from '../components/Common/Button';
import Icon from '../components/Common/Icon';
import Card from '../components/Common/Card';

const Login = () => {
  const navigate = useNavigate();
  const { login } = useAuth();
  const [formData, setFormData] = useState({ email: '', password: '' });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    
    try {
      const result = await login(formData.email, formData.password);
      if (result.success) {
        navigate('/home');
      } else {
        setError(result.error || 'Credenciales incorrectas');
      }
    } catch (err) {
      setError('Ocurrió un error. Intenta de nuevo.');
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
          <h1 className="text-3xl font-display font-black text-white mb-2 uppercase italic">BIENVENIDO DE VUELTA</h1>
          <p className="text-slate-400 font-medium">Ingresa tus credenciales para continuar.</p>
        </div>

        <Card className="p-8 border-white/5">
          <form onSubmit={handleSubmit} className="space-y-6">
            <div className="space-y-1">
              <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest ml-1">Email</label>
              <div className="relative">
                <Icon name="mail" className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-500" />
                <input
                  type="email"
                  placeholder="tu@email.com"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  className="w-full bg-surface/50 border border-white/5 rounded-2xl pl-12 pr-4 py-3 text-white focus:border-primary/50 focus:ring-1 focus:ring-primary/20 outline-none transition-all"
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
                  onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                  className="w-full bg-surface/50 border border-white/5 rounded-2xl pl-12 pr-4 py-3 text-white focus:border-primary/50 outline-none transition-all"
                  required
                />
              </div>
            </div>

            <div className="text-right">
              <button type="button" className="text-xs font-bold text-primary hover:underline">
                ¿Olvidaste tu contraseña?
              </button>
            </div>

            {error && <p className="text-danger text-xs font-bold text-center">{error}</p>}

            <Button type="submit" className="w-full py-4" loading={loading}>
              Iniciar Sesión
            </Button>
          </form>
        </Card>

        <div className="mt-8 text-center space-y-4">
          <p className="text-slate-500 text-sm font-medium">
            ¿No tienes cuenta?{' '}
            <Link to="/register" className="text-primary font-bold hover:underline">
              Regístrate aquí
            </Link>
          </p>
          
          <div className="pt-4 border-t border-white/5">
            <p className="text-[10px] font-black text-slate-600 uppercase tracking-widest mb-3">¿Eres Creadora?</p>
            <Link to="/register/creadora" className="inline-flex items-center gap-2 text-sm text-slate-400 hover:text-white transition-colors group">
              Crea tu perfil profesional
              <Icon name="arrow_forward" className="text-sm group-hover:translate-x-1 transition-transform" />
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Login;