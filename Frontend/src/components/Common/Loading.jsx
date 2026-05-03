import { Loader2 } from 'lucide-react';
import { clsx } from 'clsx';

const Loading = ({ size = 'md', text, className = '' }) => {
  const sizes = {
    sm: 'w-4 h-4',
    md: 'w-8 h-8',
    lg: 'w-12 h-12',
    xl: 'w-16 h-16',
  };

  return (
    <div className={clsx('flex flex-col items-center justify-center gap-3', className)}>
      <Loader2 className={clsx('animate-spin text-primary', sizes[size])} />
      {text && <p className="text-sm text-slate-500">{text}</p>}
    </div>
  );
};

export const PageLoading = () => (
  <div className="min-h-[60vh] flex items-center justify-center">
    <Loading text="Cargando..." />
  </div>
);

export default Loading;