import { useState, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { contentService } from '../services/content';
import Button from '../components/Common/Button';
import Icon from '../components/Common/Icon';
import Card from '../components/Common/Card';
import TopHeader from '../components/Navigation/TopHeader';
import BottomNav from '../components/Navigation/BottomNav';

const CreateContent = () => {
  const navigate = useNavigate();
  const fileInputRef = useRef(null);
  
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [preview, setPreview] = useState(null);
  const [file, setFile] = useState(null);
  
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    visibility: 'public', // public, premium, exclusive
    diamonds: 0,
    isNsfw: false
  });

  const handleFileChange = (e) => {
    const selectedFile = e.target.files[0];
    if (selectedFile) {
      setFile(selectedFile);
      const reader = new FileReader();
      reader.onloadend = () => {
        setPreview(reader.result);
      };
      reader.readAsDataURL(selectedFile);
    }
  };

  const handleChange = (field, value) => {
    setFormData({ ...formData, [field]: value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!file) {
      setError('Por favor selecciona un archivo');
      return;
    }

    setLoading(true);
    setError('');

    const uploadData = new FormData();
    uploadData.append('file', file);
    uploadData.append('title', formData.title);
    uploadData.append('description', formData.description);
    uploadData.append('visibility', formData.visibility);
    uploadData.append('price_diamonds', formData.diamonds);
    uploadData.append('is_nsfw', formData.isNsfw);

    try {
      const result = await contentService.upload(uploadData);
      if (result.success) {
        navigate('/dashboard/influencer');
      } else {
        setError(result.error || 'Error al subir contenido');
      }
    } catch (err) {
      setError('Error de conexión. Intenta de nuevo.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-background pb-24">
      <TopHeader title="Subir Contenido" showBack={true} />

      <main className="px-6 py-8 max-w-2xl mx-auto">
        <form onSubmit={handleSubmit} className="space-y-8">
          {/* Upload Area */}
          <div 
            onClick={() => fileInputRef.current?.click()}
            className="aspect-video glass-panel border-2 border-dashed border-white/10 rounded-3xl flex flex-col items-center justify-center cursor-pointer hover:border-primary/50 transition-all overflow-hidden relative group"
          >
            {preview ? (
              <>
                {file?.type.startsWith('video') ? (
                  <video src={preview} className="w-full h-full object-cover" />
                ) : (
                  <img src={preview} alt="Preview" className="w-full h-full object-cover" />
                )}
                <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity">
                  <span className="text-white font-black text-xs uppercase tracking-widest">Cambiar Archivo</span>
                </div>
              </>
            ) : (
              <div className="text-center">
                <div className="w-16 h-16 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-4 group-hover:scale-110 transition-transform">
                  <Icon name="add_a_photo" className="text-primary text-3xl" />
                </div>
                <p className="text-white font-display font-bold">Selecciona Fotos o Videos</p>
                <p className="text-slate-500 text-xs mt-1 font-medium">Formato recomendado: 9:16 o 16:9</p>
              </div>
            )}
            <input 
              type="file" 
              ref={fileInputRef}
              onChange={handleFileChange}
              className="hidden" 
              accept="image/*,video/*"
            />
          </div>

          <Card className="p-6 space-y-6">
            <div className="space-y-1">
              <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest ml-1">Título del Post</label>
              <input
                type="text"
                placeholder="Un nombre llamativo..."
                value={formData.title}
                onChange={(e) => handleChange('title', e.target.value)}
                className="w-full bg-surface/50 border border-white/5 rounded-2xl px-4 py-3 text-white focus:border-primary/50 outline-none transition-all"
                required
              />
            </div>

            <div className="space-y-1">
              <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest ml-1">Descripción</label>
              <textarea
                placeholder="Cuéntale a tus fans sobre este contenido..."
                value={formData.description}
                onChange={(e) => handleChange('description', e.target.value)}
                className="w-full bg-surface/50 border border-white/5 rounded-2xl px-4 py-3 text-white focus:border-primary/50 outline-none transition-all resize-none h-32"
              />
            </div>

            <div className="space-y-4">
              <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest ml-1">Visibilidad y Precio</label>
              <div className="grid grid-cols-3 gap-3">
                {[
                  { id: 'public', label: 'Gratis', icon: 'public' },
                  { id: 'premium', label: 'Fans', icon: 'star' },
                  { id: 'exclusive', label: 'PPV', icon: 'diamond' }
                ].map((option) => (
                  <button
                    key={option.id}
                    type="button"
                    onClick={() => handleChange('visibility', option.id)}
                    className={`flex flex-col items-center gap-2 p-3 rounded-2xl border transition-all ${
                      formData.visibility === option.id 
                        ? 'bg-primary/20 border-primary text-primary' 
                        : 'bg-surface border-white/5 text-slate-500 hover:border-white/20'
                    }`}
                  >
                    <Icon name={option.icon} className="text-xl" fill={formData.visibility === option.id} />
                    <span className="text-[9px] font-black uppercase tracking-tighter">{option.label}</span>
                  </button>
                ))}
              </div>

              {formData.visibility === 'exclusive' && (
                <div className="animate-in fade-in slide-in-from-top-2 duration-300">
                  <div className="relative">
                    <Icon name="diamond" className="absolute left-4 top-1/2 -translate-y-1/2 text-tertiary" fill={true} />
                    <input
                      type="number"
                      placeholder="Precio en diamantes"
                      value={formData.diamonds}
                      onChange={(e) => handleChange('diamonds', e.target.value)}
                      className="w-full bg-surface/50 border border-tertiary/20 rounded-2xl pl-12 pr-4 py-3 text-white focus:border-tertiary outline-none transition-all"
                    />
                  </div>
                </div>
              )}
            </div>

            <div className="flex items-center justify-between p-4 glass-panel rounded-2xl border-white/5">
              <div className="flex items-center gap-3">
                <Icon name="explicit" className="text-danger" />
                <div>
                  <p className="text-sm text-white font-bold">Contenido Sensible</p>
                  <p className="text-[10px] text-slate-500">Marcar si es contenido para adultos (+18)</p>
                </div>
              </div>
              <input 
                type="checkbox"
                checked={formData.isNsfw}
                onChange={(e) => handleChange('isNsfw', e.target.checked)}
                className="w-6 h-6 rounded-lg border-white/10 bg-surface text-danger focus:ring-danger/20"
              />
            </div>

            {error && <p className="text-danger text-xs font-bold text-center">{error}</p>}

            <Button 
              type="submit" 
              className="w-full py-4" 
              loading={loading}
              disabled={!file || !formData.title}
            >
              <div className="flex items-center justify-center gap-2">
                <Icon name="publish" fill={true} />
                Publicar Ahora
              </div>
            </Button>
          </Card>
        </form>
      </main>

      <BottomNav activeTab="upload" isCreator={true} />
    </div>
  );
};

export default CreateContent;
