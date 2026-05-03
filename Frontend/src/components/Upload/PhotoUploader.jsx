import { useState, useRef } from 'react';
import { Upload, X, Image, Video, Lock, Users, DollarSign, Check, Play } from 'lucide-react';
import Button from '../Common/Button';

const PhotoUploader = ({ onClose, onUpload }) => {
  const [file, setFile] = useState(null);
  const [preview, setPreview] = useState(null);
  const [mediaType, setMediaType] = useState('photo');
  const [description, setDescription] = useState('');
  const [visibility, setVisibility] = useState('free');
  const [price, setPrice] = useState(0);
  const [uploading, setUploading] = useState(false);
  const [progress, setProgress] = useState(0);
  const fileInputRef = useRef(null);
  const videoRef = useRef(null);

  const handleFileSelect = (e) => {
    const selectedFile = e.target.files[0];
    if (selectedFile) {
      setFile(selectedFile);
      
      if (selectedFile.type.startsWith('video/')) {
        setMediaType('video');
        const url = URL.createObjectURL(selectedFile);
        setPreview(url);
      } else if (selectedFile.type.startsWith('image/')) {
        setMediaType('photo');
        const reader = new FileReader();
        reader.onload = (e) => setPreview(e.target.result);
        reader.readAsDataURL(selectedFile);
      }
    }
  };

  const handleDrop = (e) => {
    e.preventDefault();
    const droppedFile = e.dataTransfer.files[0];
    if (droppedFile) {
      if (droppedFile.type.startsWith('image/') || droppedFile.type.startsWith('video/')) {
        setFile(droppedFile);
        if (droppedFile.type.startsWith('video/')) {
          setMediaType('video');
          const url = URL.createObjectURL(droppedFile);
          setPreview(url);
        } else {
          setMediaType('photo');
          const reader = new FileReader();
          reader.onload = (e) => setPreview(e.target.result);
          reader.readAsDataURL(droppedFile);
        }
      }
    }
  };

  const handleUpload = async () => {
    if (!file) return;
    setUploading(true);
    setProgress(0);

    const interval = setInterval(() => {
      setProgress((prev) => {
        if (prev >= 100) {
          clearInterval(interval);
          return 100;
        }
        return prev + 10;
      });
    }, 200);

    setTimeout(() => {
      clearInterval(interval);
      setProgress(100);
      setTimeout(() => {
        onUpload({ file, mediaType, description, visibility, price });
        onClose();
      }, 500);
    }, 2000);
  };

  const removeFile = () => {
    if (mediaType === 'video' && preview) {
      URL.revokeObjectURL(preview);
    }
    setFile(null);
    setPreview(null);
    setMediaType('photo');
  };

  const visibilityOptions = [
    { id: 'free', label: 'Libre', icon: mediaType === 'video' ? Video : Image, desc: 'Visible para todos' },
    { id: 'subscribers', label: 'Suscriptores', icon: Users, desc: 'Solo suscriptores' },
    { id: 'ppv', label: 'PPV', icon: DollarSign, desc: 'Desbloqueo con diamantes' },
  ];

  const maxSizes = {
    photo: '200x200px mínimo',
    video: 'Hasta 500MB, MP4 o MOV'
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-slate-900/60 backdrop-blur-sm" onClick={onClose} />
      
      <div className="relative w-full max-w-lg bg-white rounded-2xl shadow-2xl overflow-hidden">
        {/* Header */}
        <div className="bg-gradient-to-r from-[#ff424d] to-[#ff6b73] px-6 py-4 flex items-center justify-between">
          <h2 className="text-xl font-semibold text-white">
            Subir {mediaType === 'video' ? 'video' : 'foto'}
          </h2>
          <button onClick={onClose} className="p-1 rounded-full hover:bg-white/20 transition-colors">
            <X className="w-5 h-5 text-white" />
          </button>
        </div>

        <div className="p-6 space-y-6">
          {/* Type Selector */}
          <div className="flex gap-2">
            <button
              onClick={() => { setMediaType('photo'); setFile(null); setPreview(null); }}
              className={`flex-1 flex items-center justify-center gap-2 py-3 rounded-xl font-medium transition-all ${
                mediaType === 'photo'
                  ? 'bg-[#ff424d] text-white'
                  : 'bg-[#fdfbf7] text-[#6b6b6b] border border-[#e8e4dc]'
              }`}
            >
              <Image className="w-5 h-5" />
              Foto
            </button>
            <button
              onClick={() => { setMediaType('video'); setFile(null); setPreview(null); }}
              className={`flex-1 flex items-center justify-center gap-2 py-3 rounded-xl font-medium transition-all ${
                mediaType === 'video'
                  ? 'bg-[#ff424d] text-white'
                  : 'bg-[#fdfbf7] text-[#6b6b6b] border border-[#e8e4dc]'
              }`}
            >
              <Video className="w-5 h-5" />
              Video
            </button>
          </div>

          {/* Drop Zone */}
          <div
            onClick={() => fileInputRef.current?.click()}
            onDrop={handleDrop}
            onDragOver={(e) => e.preventDefault()}
            className={`relative border-2 border-dashed rounded-xl p-8 text-center cursor-pointer transition-all ${
              preview ? 'border-transparent' : 'border-[#e8e4dc] hover:border-[#ff424d] hover:bg-[#fdf4f3]'
            }`}
          >
            {preview ? (
              <div className="relative">
                {mediaType === 'video' ? (
                  <div className="relative">
                    <video 
                      ref={videoRef}
                      src={preview} 
                      className="max-h-64 mx-auto rounded-lg"
                      controls
                    />
                    <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                      <div className="w-16 h-16 bg-white/80 rounded-full flex items-center justify-center">
                        <Play className="w-8 h-8 text-[#ff424d] ml-1" />
                      </div>
                    </div>
                  </div>
                ) : (
                  <img src={preview} alt="Preview" className="max-h-64 mx-auto rounded-lg" />
                )}
                <button
                  onClick={(e) => { e.stopPropagation(); removeFile(); }}
                  className="absolute top-2 right-2 p-2 bg-slate-900/70 rounded-full hover:bg-slate-800"
                >
                  <X className="w-4 h-4 text-white" />
                </button>
                {file && (
                  <p className="mt-2 text-sm text-[#6b6b6b] truncate max-w-full">
                    {file.name}
                  </p>
                )}
              </div>
            ) : (
              <div>
                <Upload className="w-12 h-12 text-[#999] mx-auto mb-3" />
                <p className="text-[#37352f]">
                  Arrastra o haz clic para seleccionar
                </p>
                <p className="text-sm text-[#999] mt-1">{maxSizes[mediaType]}</p>
              </div>
            )}
            <input
              ref={fileInputRef}
              type="file"
              accept={mediaType === 'video' ? 'video/mp4,video/quicktime,video/x-msvideo' : 'image/*'}
              onChange={handleFileSelect}
              className="hidden"
            />
          </div>

          {/* Description */}
          <div>
            <label className="block text-sm font-semibold text-[#37352f] mb-2">
              Descripción {mediaType === 'video' ? 'del video' : ''} (opcional)
            </label>
            <textarea
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder={mediaType === 'video' ? 'Describe tu video...' : 'Escribe una descripción...'}
              className="w-full px-4 py-3 border border-[#e8e4dc] rounded-xl resize-none focus:outline-none focus:border-[#ff424d] focus:ring-2 focus:ring-[#ff424d]/10"
              rows={2}
            />
          </div>

          {/* Visibility */}
          <div>
            <label className="block text-sm font-semibold text-[#37352f] mb-3">Visibilidad</label>
            <div className="grid grid-cols-3 gap-3">
              {visibilityOptions.map((opt) => (
                <button
                  key={opt.id}
                  onClick={() => setVisibility(opt.id)}
                  className={`p-3 rounded-xl border-2 text-center transition-all ${
                    visibility === opt.id
                      ? 'border-[#ff424d] bg-[#fdf4f3]'
                      : 'border-[#e8e4dc] hover:border-[#ff424d]/50'
                  }`}
                >
                  <opt.icon className={`w-6 h-6 mx-auto mb-1 ${visibility === opt.id ? 'text-[#ff424d]' : 'text-[#999]'}`} />
                  <span className={`text-sm font-medium ${visibility === opt.id ? 'text-[#ff424d]' : 'text-[#6b6b6b]'}`}>
                    {opt.label}
                  </span>
                </button>
              ))}
            </div>
          </div>

          {/* Price (only for PPV) */}
          {visibility === 'ppv' && (
            <div>
              <label className="block text-sm font-semibold text-[#37352f] mb-2">Precio en diamantes</label>
              <div className="flex items-center gap-2">
                <input
                  type="number"
                  value={price}
                  onChange={(e) => setPrice(Number(e.target.value))}
                  min={1}
                  className="flex-1 px-4 py-2 border border-[#e8e4dc] rounded-lg focus:outline-none focus:border-[#ff424d]"
                  placeholder="10"
                />
                <span className="text-2xl">💎</span>
              </div>
              <p className="text-xs text-[#999] mt-1">Los suscriptores deberán pagar para desbloquear</p>
            </div>
          )}

          {/* Progress */}
          {uploading && (
            <div>
              <div className="flex justify-between text-sm text-[#6b6b6b] mb-2">
                <span>Subiendo {mediaType === 'video' ? 'video' : 'imagen'}...</span>
                <span>{progress}%</span>
              </div>
              <div className="h-2 bg-[#e8e4dc] rounded-full overflow-hidden">
                <div
                  className="h-full bg-gradient-to-r from-[#ff424d] to-[#ff6b73] transition-all duration-200"
                  style={{ width: `${progress}%` }}
                />
              </div>
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="px-6 py-4 bg-[#fdfbf7] border-t border-[#e8e4dc] flex gap-3">
          <Button variant="ghost" onClick={onClose} className="flex-1">Cancelar</Button>
          <Button 
            onClick={handleUpload} 
            disabled={!file || uploading} 
            className="flex-1 bg-[#ff424d] hover:bg-[#e63946]"
          >
            {uploading ? 'Subiendo...' : `Subir ${mediaType === 'video' ? 'video' : 'foto'}`}
          </Button>
        </div>
      </div>
    </div>
  );
};

export default PhotoUploader;