import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { ArrowLeft, Diamond, Check } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import Button from '../components/Common/Button';
import Card from '../components/Common/Card';

const packages = [
  { id: 1, diamonds: 50, price: 9.99, bonus: 0, label: 'Entrada' },
  { id: 2, diamonds: 150, price: 24.99, bonus: 15, label: 'Popular' },
  { id: 3, diamonds: 350, price: 49.99, bonus: 30, label: 'Mejor valor' },
  { id: 4, diamonds: 1000, price: 129.99, bonus: 40, label: 'Mega ahorro' },
];

const recentPurchases = [
  { date: '01/05', package: '150 💎', price: 'S/ 25.00', status: 'Completado' },
  { date: '29/04', package: '350 💎', price: 'S/ 50.00', status: 'Completado' },
  { date: '25/04', package: '50 💎', price: 'S/ 10.00', status: 'Completado' },
];

const DiamondStore = () => {
  const navigate = useNavigate();
  const { user } = useAuth();
  const balance = 150; // Mock balance

  const handlePurchase = (pkg) => {
    // Simulate purchase
    alert(`Compra de ${pkg.diamonds} 💎 por S/ ${pkg.price} - Simulado`);
  };

  return (
    <div className="min-h-screen bg-slate-50">
      {/* Header */}
      <div className="bg-white border-b border-slate-200 sticky top-0 z-40">
        <div className="max-w-5xl mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-4">
            <button onClick={() => navigate(-1)} className="p-2 rounded-full hover:bg-slate-100">
              <ArrowLeft className="w-5 h-5" />
            </button>
            <h1 className="text-xl font-display font-semibold">Tienda de Diamantes</h1>
          </div>
          <div className="flex items-center gap-2 px-4 py-2 bg-yellow-50 rounded-full">
            <Diamond className="w-5 h-5 text-yellow-500" />
            <span className="font-semibold text-yellow-700">{balance} 💎</span>
          </div>
        </div>
      </div>

      <div className="max-w-5xl mx-auto px-4 py-8">
        {/* Packages Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-12">
          {packages.map((pkg) => (
            <Card 
              key={pkg.id} 
              elevated={pkg.id === 2}
              className={`relative ${pkg.id === 2 ? 'ring-2 ring-primary' : ''}`}
            >
              {pkg.label && (
                <div className={`absolute -top-3 left-1/2 -translate-x-1/2 px-3 py-1 rounded-full text-xs font-medium ${
                  pkg.label === 'Popular' ? 'bg-primary text-white' :
                  pkg.label === 'Mejor valor' ? 'bg-success text-white' :
                  pkg.label === 'Mega ahorro' ? 'bg-yellow-500 text-white' :
                  'bg-slate-200 text-slate-600'
                }`}>
                  {pkg.label}
                </div>
              )}
              <div className="text-center pt-4">
                <div className="flex items-center justify-center gap-2 mb-2">
                  <Diamond className="w-8 h-8 text-yellow-500" />
                  <span className="text-3xl font-bold text-slate-900">{pkg.diamonds}</span>
                </div>
                <p className="text-2xl font-bold text-primary mb-4">S/ {pkg.price}</p>
                {pkg.bonus > 0 && (
                  <div className="inline-flex items-center gap-1 px-3 py-1 bg-success/10 text-success rounded-full text-sm mb-4">
                    <Check className="w-4 h-4" />
                    +{pkg.bonus}% bonus
                  </div>
                )}
                <Button 
                  className="w-full" 
                  variant={pkg.id === 2 ? 'primary' : 'secondary'}
                  onClick={() => handlePurchase(pkg)}
                >
                  Comprar
                </Button>
              </div>
            </Card>
          ))}
        </div>

        {/* Info Section */}
        <div className="bg-white rounded-2xl p-6 mb-12 border border-slate-200">
          <h2 className="text-xl font-semibold text-slate-900 mb-4">¿Qué son los diamantes?</h2>
          <div className="grid md:grid-cols-3 gap-6">
            <div className="text-center">
              <div className="w-12 h-12 rounded-full bg-yellow-100 flex items-center justify-center mx-auto mb-3">
                <Diamond className="w-6 h-6 text-yellow-600" />
              </div>
              <p className="text-slate-700">Moneda virtual</p>
              <p className="text-sm text-slate-500">1 💎 = S/ 0.10</p>
            </div>
            <div className="text-center">
              <div className="w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center mx-auto mb-3">
                <span className="text-2xl">🔓</span>
              </div>
              <p className="text-slate-700">Desbloquea contenido</p>
              <p className="text-sm text-slate-500">Contenido exclusivo</p>
            </div>
            <div className="text-center">
              <div className="w-12 h-12 rounded-full bg-pink-100 flex items-center justify-center mx-auto mb-3">
                <span className="text-2xl">💝</span>
              </div>
              <p className="text-slate-700">Tips mejorados</p>
              <p className="text-sm text-slate-500">Envía más a tus creadoras</p>
            </div>
          </div>
        </div>

        {/* Recent Purchases */}
        <div className="bg-white rounded-2xl p-6 border border-slate-200">
          <h2 className="text-xl font-semibold text-slate-900 mb-4">Tus compras recientes</h2>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-slate-200">
                  <th className="text-left py-3 px-4 text-sm font-medium text-slate-500">Fecha</th>
                  <th className="text-left py-3 px-4 text-sm font-medium text-slate-500">Paquete</th>
                  <th className="text-left py-3 px-4 text-sm font-medium text-slate-500">Precio</th>
                  <th className="text-left py-3 px-4 text-sm font-medium text-slate-500">Estado</th>
                </tr>
              </thead>
              <tbody>
                {recentPurchases.map((purchase, i) => (
                  <tr key={i} className="border-b border-slate-100">
                    <td className="py-3 px-4 text-slate-900">{purchase.date}</td>
                    <td className="py-3 px-4 text-slate-900 font-medium">{purchase.package}</td>
                    <td className="py-3 px-4 text-slate-900">{purchase.price}</td>
                    <td className="py-3 px-4">
                      <span className="inline-flex items-center gap-1 text-success text-sm">
                        <Check className="w-4 h-4" />
                        {purchase.status}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DiamondStore;