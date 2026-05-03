import { useState } from 'react';
import { Link } from 'react-router-dom';
import Button from '../components/Common/Button';
import Icon from '../components/Common/Icon';
import Card from '../components/Common/Card';

const Landing = () => {
  const categories = [
    { name: 'Modelos', icon: 'auto_awesome' },
    { name: 'Fitness', icon: 'fitness_center' },
    { name: 'Música', icon: 'music_note' },
    { name: 'Gamer', icon: 'sports_esports' },
    { name: 'Arte', icon: 'palette' },
  ];

  return (
    <div className="min-h-screen bg-background text-white selection:bg-primary/30 selection:text-primary">
      {/* Navbar */}
      <nav className="fixed top-0 w-full z-50 glass-panel border-x-0 border-t-0 flex justify-between items-center px-6 h-20">
        <span className="font-display font-black text-3xl italic tracking-tighter text-gradient">
          LUXOR
        </span>
        <div className="flex gap-4">
          <Link to="/login" className="no-underline">
            <Button variant="ghost">Ingresar</Button>
          </Link>
          <Link to="/register" className="no-underline">
            <Button>Empezar Gratis</Button>
          </Link>
        </div>
      </nav>

      {/* Hero Section */}
      <header className="relative pt-40 pb-20 px-6 overflow-hidden">
        {/* Background Glows */}
        <div className="absolute top-20 -left-20 w-80 h-80 bg-primary/20 blur-[120px] rounded-full" />
        <div className="absolute bottom-0 -right-20 w-96 h-96 bg-tertiary/10 blur-[150px] rounded-full" />

        <div className="max-w-4xl mx-auto text-center relative z-10">
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full glass-panel border-primary/20 mb-8 animate-fade-in">
            <Icon name="bolt" className="text-primary" fill={true} />
            <span className="text-xs font-black uppercase tracking-widest text-primary">La #1 en Latinoamérica</span>
          </div>
          
          <h1 className="font-display text-5xl md:text-8xl font-black leading-[0.9] tracking-tighter mb-8 animate-slide-up">
            MONETIZA TU <br />
            <span className="text-gradient">CONTENIDO</span> <br />
            SIN LÍMITES
          </h1>
          
          <p className="text-lg md:text-xl text-slate-400 max-w-2xl mx-auto mb-12 font-medium leading-relaxed">
            La plataforma diseñada para creadores de LATAM. 
            Cobra en tu moneda local con <span className="text-white font-bold italic">Yape, Plin y más.</span>
          </p>

          <div className="flex flex-col sm:flex-row justify-center gap-4 animate-fade-in" style={{ animationDelay: '0.4s' }}>
            <Link to="/register/creadora" className="no-underline">
              <Button size="lg" className="w-full sm:w-auto px-12 py-5 text-lg">
                Soy Creadora
              </Button>
            </Link>
            <Link to="/home" className="no-underline">
              <Button size="lg" variant="secondary" className="w-full sm:w-auto px-12 py-5 text-lg">
                Explorar Feed
              </Button>
            </Link>
          </div>
        </div>
      </header>

      {/* Categories Bar */}
      <section className="py-12 border-y border-white/5 bg-surface/30">
        <div className="flex gap-6 overflow-x-auto px-6 scrollbar-hide justify-center">
          {categories.map((cat, idx) => (
            <div key={idx} className="flex items-center gap-3 glass-panel px-6 py-3 rounded-2xl border-white/5 hover:border-primary/30 transition-all cursor-pointer whitespace-nowrap">
              <Icon name={cat.icon} className="text-primary text-2xl" />
              <span className="font-display font-bold text-sm uppercase tracking-widest">{cat.name}</span>
            </div>
          ))}
        </div>
      </section>

      {/* Features Grid */}
      <section className="py-24 px-6">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-20">
            <h2 className="font-display text-4xl md:text-6xl font-black mb-6">TODO LO QUE NECESITAS</h2>
            <p className="text-slate-500 font-medium max-w-xl mx-auto text-lg">Creamos las herramientas perfectas para que vivas de tu pasión.</p>
          </div>

          <div className="grid md:grid-cols-3 gap-6">
            <Card className="p-8 space-y-4">
              <div className="w-14 h-14 rounded-2xl bg-primary/10 flex items-center justify-center">
                <Icon name="payments" className="text-primary text-3xl" fill={true} />
              </div>
              <h3 className="text-xl font-display font-black">Pagos Locales</h3>
              <p className="text-slate-400 leading-relaxed text-sm">
                Recibe tus ganancias directamente por Yape, Plin o transferencia bancaria. Sin esperas, sin complicaciones.
              </p>
            </Card>

            <Card className="p-8 space-y-4">
              <div className="w-14 h-14 rounded-2xl bg-secondary/10 flex items-center justify-center">
                <Icon name="verified_user" className="text-secondary text-3xl" fill={true} />
              </div>
              <h3 className="text-xl font-display font-black">100% Seguro</h3>
              <p className="text-slate-400 leading-relaxed text-sm">
                Protección contra chargebacks y sistemas anti-piratería integrados. Tu contenido y tu dinero están a salvo.
              </p>
            </Card>

            <Card className="p-8 space-y-4">
              <div className="w-14 h-14 rounded-2xl bg-tertiary/10 flex items-center justify-center">
                <Icon name="auto_graph" className="text-tertiary text-3xl" fill={true} />
              </div>
              <h3 className="text-xl font-display font-black">Crecimiento Orgánico</h3>
              <p className="text-slate-400 leading-relaxed text-sm">
                Nuestro algoritmo de descubrimiento te ayuda a llegar a nuevos fans sin depender de otras redes sociales.
              </p>
            </Card>
          </div>
        </div>
      </section>

      {/* Final CTA */}
      <section className="py-32 px-6 relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-t from-primary/10 to-transparent pointer-events-none" />
        <div className="max-w-4xl mx-auto glass-panel p-12 md:p-20 rounded-[40px] border-primary/20 text-center relative z-10 overflow-hidden">
          <Icon name="diamond" className="absolute -top-10 -right-10 text-primary/5 text-[300px]" fill={true} />
          <h2 className="font-display text-4xl md:text-6xl font-black mb-8 relative z-10">¿LISTA PARA BRILLAR?</h2>
          <p className="text-xl text-slate-300 mb-12 relative z-10 max-w-lg mx-auto">Únete a la comunidad de creadoras más grande de la región.</p>
          <Link to="/register/creadora" className="no-underline relative z-10">
            <Button size="lg" className="px-16 py-6 text-xl">Crear mi Perfil</Button>
          </Link>
        </div>
      </section>

      {/* Simple Footer */}
      <footer className="py-12 border-t border-white/5 text-center px-6">
        <span className="font-display font-black text-2xl italic text-gradient mb-6 block">LUXOR</span>
        <p className="text-slate-600 text-xs font-bold uppercase tracking-widest">© 2026 LUXOR PLATFORM · LATAM PRIDE</p>
      </footer>
    </div>
  );
};

export default Landing;