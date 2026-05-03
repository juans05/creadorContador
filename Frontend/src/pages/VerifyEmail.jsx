import { useState, useEffect } from 'react';
import { Link, useSearchParams, useNavigate } from 'react-router-dom';
import Button from '../components/Common/Button';
import Icon from '../components/Common/Icon';
import Card from '../components/Common/Card';

const VerifyEmail = () => {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const email = searchParams.get('email') || '';
  
  const [code, setCode] = useState(['', '', '', '', '', '']);
  const [timeLeft, setTimeLeft] = useState(180);
  const [verified, setVerified] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    if (timeLeft > 0) {
      const timer = setTimeout(() => setTimeLeft(timeLeft - 1), 1000);
      return () => clearTimeout(timer);
    }
  }, [timeLeft]);

  const handleCodeChange = (index, value) => {
    if (!isNaN(value) && value.length <= 1) {
      const newCode = [...code];
      newCode[index] = value;
      setCode(newCode);
      
      if (value && index < 5) {
        document.getElementById(`code-${index + 1}`).focus();
      }
    }
  };

  const handleKeyDown = (index, e) => {
    if (e.key === 'Backspace' && !code[index] && index > 0) {
      document.getElementById(`code-${index - 1}`).focus();
    }
  };

  const handleVerify = async () => {
    const fullCode = code.join('');
    if (fullCode.length !== 6) return;
    
    setLoading(true);
    setError('');
    
    try {
      // Simulation of verification
      await new Promise(resolve => setTimeout(resolve, 1500));
      setVerified(true);
    } catch (err) {
      setError('Código inválido o expirado');
    } finally {
      setLoading(false);
    }
  };

  const formatTime = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  if (verified) {
    return (
      <div className="min-h-screen bg-background flex flex-col items-center justify-center p-6 text-center">
        <div className="w-24 h-24 bg-primary/20 rounded-full flex items-center justify-center mb-8 shadow-[0_0_40px_rgba(255,77,109,0.3)] animate-bounce">
          <Icon name="check_circle" className="text-primary text-5xl" fill={true} />
        </div>
        <h1 className="text-4xl font-display font-black text-white mb-4 uppercase italic">¡CUENTA ACTIVADA!</h1>
        <p className="text-slate-400 font-medium mb-10 max-w-xs">
          Tu email ha sido verificado con éxito. Ya eres parte de LUXOR.
        </p>
        <Link to="/login" className="w-full max-w-xs">
          <Button className="w-full py-4">
            Empezar Ahora
          </Button>
        </Link>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background flex flex-col items-center justify-center p-6 relative overflow-hidden">
      <div className="absolute top-0 left-0 w-96 h-96 bg-primary/5 blur-[120px] rounded-full" />
      
      <div className="w-full max-w-md relative z-10">
        <div className="text-center mb-10">
          <div className="w-20 h-20 bg-surface/80 glass-panel rounded-3xl flex items-center justify-center mx-auto mb-6 border border-white/5 shadow-2xl">
            <Icon name="mail" className="text-primary text-3xl" />
          </div>
          <h1 className="text-3xl font-display font-black text-white mb-2 uppercase italic">Verifica tu Email</h1>
          <p className="text-slate-400 font-medium">
            Ingresa el código enviado a <span className="text-primary font-bold">{email}</span>
          </p>
        </div>

        <Card className="p-8 border-white/5">
          <div className="flex justify-between gap-2 mb-10">
            {code.map((digit, index) => (
              <input
                key={index}
                id={`code-${index}`}
                type="text"
                maxLength={1}
                value={digit}
                onChange={(e) => handleCodeChange(index, e.target.value)}
                onKeyDown={(e) => handleKeyDown(index, e)}
                className="w-12 h-16 text-center text-2xl font-display font-black rounded-2xl bg-surface/50 border-2 border-white/5 text-primary focus:border-primary focus:ring-4 focus:ring-primary/10 outline-none transition-all"
              />
            ))}
          </div>

          <div className="text-center mb-8">
            <p className="text-[10px] font-black text-slate-500 uppercase tracking-widest mb-1">El código expira en</p>
            <div className="text-xl font-display font-bold text-white tracking-widest">
              {formatTime(timeLeft)}
            </div>
          </div>

          {error && <p className="text-danger text-xs font-bold text-center mb-4">{error}</p>}

          <Button 
            className="w-full py-4" 
            onClick={handleVerify}
            loading={loading}
            disabled={code.join('').length !== 6}
          >
            Confirmar Código
          </Button>

          <div className="mt-8 text-center">
            <button 
              disabled={timeLeft > 0}
              className="text-xs font-black text-slate-500 uppercase tracking-widest hover:text-primary transition-colors disabled:opacity-50"
            >
              Reenviar Código
            </button>
          </div>
        </Card>
      </div>
    </div>
  );
};

export default VerifyEmail;