import { clsx } from 'clsx';

const Card = ({
  children,
  className = '',
  padding = 'md',
  hover = false,
  glass = true,
}) => {
  const paddings = {
    none: '',
    sm: 'p-3',
    md: 'p-5',
    lg: 'p-8',
  };

  return (
    <div
      className={clsx(
        'rounded-2xl transition-all duration-300 overflow-hidden',
        glass ? 'glass-panel' : 'bg-surface border border-white/5',
        hover && 'cursor-pointer hover:border-primary/30 active:scale-[0.98]',
        paddings[padding],
        className
      )}
    >
      {children}
    </div>
  );
};

export default Card;