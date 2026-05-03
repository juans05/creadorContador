import { useState, useEffect, useRef } from 'react';
import { useParams, Link } from 'react-router-dom';
import { ArrowLeft, Send, Image, Smile, MoreVertical, Phone, Video } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

const mockMessages = [
  { id: 1, sender: 'creator', text: 'Hola! Gracias por suscribirte 💕', time: '10:30 AM' },
  { id: 2, sender: 'user', text: 'Hola! Thank you! Love your content 🔥', time: '10:32 AM' },
  { id: 3, sender: 'creator', text: 'Tienes alguna solicitud especial?', time: '10:35 AM' },
  { id: 4, sender: 'user', text: 'Podrías hacer un reel de dance?', time: '10:40 AM' },
  { id: 5, sender: 'creator', text: 'Claro! Lo tendré listo mañana 💃', time: '10:45 AM' },
];

const mockCreator = {
  name: 'Sofia Martinez',
  username: 'sofiam',
  avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop',
  online: true,
};

const Chat = () => {
  const { username } = useParams();
  const { user } = useAuth();
  const [messages, setMessages] = useState(mockMessages);
  const [newMessage, setNewMessage] = useState('');
  const [typing, setTyping] = useState(false);
  const messagesEndRef = useRef(null);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  useEffect(() => {
    const timer = setTimeout(() => setTyping(true), 1000);
    const hideTyping = setTimeout(() => setTyping(false), 3000);
    return () => {
      clearTimeout(timer);
      clearTimeout(hideTyping);
    };
  }, []);

  const handleSend = () => {
    if (!newMessage.trim()) return;
    
    setMessages([...messages, {
      id: messages.length + 1,
      sender: 'user',
      text: newMessage,
      time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
    }]);
    setNewMessage('');
  };

  const handleKeyPress = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  return (
    <div className="min-h-screen bg-slate-900 flex flex-col">
      {/* Header */}
      <div className="bg-slate-800 border-b border-slate-700 p-4">
        <div className="flex items-center justify-between max-w-4xl mx-auto">
          <div className="flex items-center gap-4">
            <Link to={`/creadora/${username}`} className="p-2 rounded-full hover:bg-slate-700 transition-colors">
              <ArrowLeft className="w-5 h-5 text-slate-400" />
            </Link>
            <div className="relative">
              <img src={mockCreator.avatar} alt={mockCreator.name} className="w-10 h-10 rounded-full object-cover" />
              {mockCreator.online && (
                <span className="absolute bottom-0 right-0 w-3 h-3 bg-emerald-500 rounded-full border-2 border-slate-800" />
              )}
            </div>
            <div>
              <h1 className="font-semibold text-white">{mockCreator.name}</h1>
              <p className="text-sm text-slate-400">@{username}</p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <button className="p-2 rounded-full hover:bg-slate-700 transition-colors text-slate-400 hover:text-white">
              <Phone className="w-5 h-5" />
            </button>
            <button className="p-2 rounded-full hover:bg-slate-700 transition-colors text-slate-400 hover:text-white">
              <Video className="w-5 h-5" />
            </button>
            <button className="p-2 rounded-full hover:bg-slate-700 transition-colors text-slate-400 hover:text-white">
              <MoreVertical className="w-5 h-5" />
            </button>
          </div>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4">
        <div className="max-w-4xl mx-auto space-y-4">
          {messages.map((msg) => (
            <div key={msg.id} className={`flex ${msg.sender === 'user' ? 'justify-end' : 'justify-start'}`}>
              <div className={`max-w-[70%] ${msg.sender === 'user' ? 'order-2' : 'order-1'}`}>
                <div className={`px-4 py-3 rounded-2xl ${
                  msg.sender === 'user' 
                    ? 'bg-gradient-to-r from-violet-600 to-fuchsia-600 text-white' 
                    : 'bg-slate-800 text-slate-100'
                }`}>
                  <p>{msg.text}</p>
                </div>
                <p className={`text-xs text-slate-500 mt-1 ${msg.sender === 'user' ? 'text-right' : ''}`}>
                  {msg.time}
                </p>
              </div>
            </div>
          ))}
          
          {typing && (
            <div className="flex justify-start">
              <div className="bg-slate-800 px-4 py-3 rounded-2xl">
                <div className="flex gap-1">
                  <span className="w-2 h-2 bg-slate-400 rounded-full animate-bounce" style={{ animationDelay: '0ms' }} />
                  <span className="w-2 h-2 bg-slate-400 rounded-full animate-bounce" style={{ animationDelay: '150ms' }} />
                  <span className="w-2 h-2 bg-slate-400 rounded-full animate-bounce" style={{ animationDelay: '300ms' }} />
                </div>
              </div>
            </div>
          )}
          <div ref={messagesEndRef} />
        </div>
      </div>

      {/* Input */}
      <div className="bg-slate-800 border-t border-slate-700 p-4">
        <div className="max-w-4xl mx-auto flex items-end gap-3">
          <button className="p-2 rounded-full hover:bg-slate-700 transition-colors text-slate-400">
            <Image className="w-5 h-5" />
          </button>
          <button className="p-2 rounded-full hover:bg-slate-700 transition-colors text-slate-400">
            <Smile className="w-5 h-5" />
          </button>
          <div className="flex-1">
            <textarea
              value={newMessage}
              onChange={(e) => setNewMessage(e.target.value)}
              onKeyDown={handleKeyPress}
              placeholder="Escribe un mensaje..."
              className="w-full bg-slate-700 text-white rounded-2xl px-4 py-3 resize-none focus:outline-none focus:ring-2 focus:ring-violet-500"
              rows={1}
            />
          </div>
          <button 
            onClick={handleSend}
            disabled={!newMessage.trim()}
            className="p-3 rounded-full bg-gradient-to-r from-violet-600 to-fuchsia-600 text-white disabled:opacity-50 disabled:cursor-not-allowed hover:shadow-lg transition-all"
          >
            <Send className="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>
  );
};

export default Chat;