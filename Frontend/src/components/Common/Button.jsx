import { forwardRef } from 'react';
import { Loader2 } from 'lucide-react';
import { clsx } from 'clsx';

const variants = {
  primary: 'btn-primary-gradient text-white border-none',
  secondary: 'glass-panel text-white hover:border-primary/50 border-white/10',
  outline: 'border-2 border-primary text-primary bg-transparent hover:bg-primary hover:text-white',
  ghost: 'text-slate-400 hover:text-white hover:bg-white/5',
  danger: 'bg-red-500/10 text-red-500 hover:bg-red-500 hover:text-white border border-red-500/20',
  success: 'bg-secondary/10 text-secondary hover:bg-secondary hover:text-background border border-secondary/20',
};

const sizes = {
  sm: 'px-4 py-2 text-xs',
  md: 'px-6 py-3 text-sm',
  lg: 'px-8 py-4 text-base font-bold',
};

const Button = forwardRef(({
  children,
  variant = 'primary',
  size = 'md',
  loading = false,
  disabled = false,
  className = '',
  ...props
}, ref) => {
  return (
    <button
      ref={ref}
      disabled={disabled || loading}
      className={clsx(
        'inline-flex items-center justify-center gap-2 font-display font-semibold rounded-2xl',
        'transition-all duration-300 focus:outline-none',
        'disabled:opacity-50 disabled:cursor-not-allowed active:scale-[0.96]',
        variants[variant],
        sizes[size],
        className
      )}
      {...props}
    >
      {loading && <Loader2 className="w-4 h-4 animate-spin text-white" />}
      {children}
    </button>
  );
});

Button.displayName = 'Button';

export default Button;