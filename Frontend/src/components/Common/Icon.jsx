import { clsx } from 'clsx';

const Icon = ({ name, fill = false, className = '' }) => {
  return (
    <span 
      className={clsx("material-symbols-outlined", className)}
      style={{ fontVariationSettings: `'FILL' ${fill ? 1 : 0}, 'wght' 400, 'GRAD' 0, 'opsz' 24` }}
    >
      {name}
    </span>
  );
};

export default Icon;
