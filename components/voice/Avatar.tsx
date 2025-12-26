
import React from 'react';

interface AvatarProps {
  isAgentSpeaking: boolean;
  isUserSpeaking: boolean;
  isConnecting: boolean;
}

const Avatar: React.FC<AvatarProps> = ({ isAgentSpeaking, isUserSpeaking, isConnecting }) => {
  return (
    <div className="relative mb-16">
      {/* Ambient Glow */}
      <div className={`absolute inset-0 rounded-full blur-[100px] transition-all duration-700 
        ${isUserSpeaking ? 'bg-indigo-500/40 scale-150' : (isAgentSpeaking ? 'bg-indigo-400/20 scale-125' : 'bg-transparent')}`} 
      />
      
      <div className={`w-44 h-44 rounded-full flex items-center justify-center transition-all duration-700 
        ${!isConnecting ? 'bg-white/[0.01] border border-white/5 shadow-inner' : ''}`}>
        
        <div className={`w-32 h-32 rounded-full flex items-center justify-center transition-all duration-500 
          ${isAgentSpeaking ? 'bg-indigo-400 scale-105 shadow-[0_0_60px_rgba(129,140,248,0.4)]' : 'bg-indigo-600 shadow-[0_0_40px_rgba(79,70,229,0.2)]'} 
          shadow-2xl`}>
          
          {isAgentSpeaking ? (
            <div className="flex items-center space-x-1.5">
              {[1, 2, 3, 4].map(i => (
                <div 
                  key={i} 
                  className="w-1.5 h-10 bg-white rounded-full animate-pulse" 
                  style={{ animationDelay: `${i * 0.1}s` }} 
                />
              ))}
            </div>
          ) : (
            <svg className={`w-14 h-14 text-white ${isUserSpeaking ? 'scale-110' : 'opacity-80'}`} fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m8 0h-3m4-12a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
          )}
        </div>
      </div>
    </div>
  );
};

export default Avatar;
