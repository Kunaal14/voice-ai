
import React from 'react';

interface ControlsProps {
  status: string;
  onStart: () => void;
  onStop: () => void;
}

const Controls: React.FC<ControlsProps> = ({ status, onStart, onStop }) => {
  if (status === 'DISCONNECTED') {
    return (
      <button 
        onClick={onStart}
        className="w-full py-8 bg-white text-black font-black text-xl rounded-[2rem] shadow-[0_20px_60px_-15px_rgba(255,255,255,0.2)] hover:bg-white/95 transition-all active:scale-[0.97] flex flex-col items-center group relative overflow-hidden"
      >
        <span className="relative z-10 flex items-center text-black">
          Start Demo Chat
          <div className="ml-3 p-1 bg-black/5 rounded-lg group-hover:translate-x-1 transition-transform">
            <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M14 5l7 7m0 0l-7 7m7-7H3" />
            </svg>
          </div>
        </span>
        <div className="absolute inset-0 bg-indigo-50 translate-y-full group-hover:translate-y-0 transition-transform duration-500" />
      </button>
    );
  }

  return (
    <button 
      onClick={onStop} 
      className="w-full py-5 bg-white/5 hover:bg-red-500/10 hover:text-red-400 text-white/20 font-black text-[10px] uppercase tracking-[0.4em] rounded-2xl transition-all border border-white/5 mb-2 hover:border-red-500/20 group"
    >
      <span className="group-hover:scale-105 transition-transform block">End Connection</span>
    </button>
  );
};

export default Controls;
