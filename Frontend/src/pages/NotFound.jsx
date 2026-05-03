import { Link } from 'react-router-dom';
import { Home, Search } from 'lucide-react';
import Button from '../components/Common/Button';

const NotFound = () => {
  return (
    <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4">
      <div className="text-center">
        <div className="text-9xl font-display font-bold text-slate-200 mb-4">404</div>
        <h1 className="text-3xl font-display font-bold text-slate-900 mb-2">Página no encontrada</h1>
        <p className="text-slate-500 mb-8 max-w-md mx-auto">
          Lo sentimos, la página que buscas no existe o ha sido movida.
        </p>
        <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
          <Link to="/">
            <Button>
              <Home className="w-5 h-5" />
              Volver al inicio
            </Button>
          </Link>
          <Link to="/home">
            <Button variant="secondary">
              <Search className="w-5 h-5" />
              Explorar
            </Button>
          </Link>
        </div>
      </div>
    </div>
  );
};

export default NotFound;