
import React from 'react';
import { Message } from '../../types';

interface TranscriptBoxProps {
  transcript: Message[];
  liveUser: string;
  liveAgent: string;
}

const TranscriptBox: React.FC<TranscriptBoxProps> = ({ transcript, liveUser, liveAgent }) => {
  return (
    <div className="h-44 overflow-y-auto mb-8 px-8 no-scrollbar space-y-4 bg-white/[0.01] rounded-[2.5rem] py-8 border border-white/5 flex flex-col-reverse shadow-inner">
      {liveAgent && <div className="text-white/50 italic text-sm text-left animate-pulse">{liveAgent}...</div>}
      {liveUser && <div className="text-indigo-400 italic text-sm text-right animate-pulse">{liveUser}...</div>}
      
      {transcript.slice().reverse().map((msg, i) => (
        <div key={i} className={`text-[13px] leading-relaxed ${msg.role === 'user' ? 'text-indigo-400/80 text-right font-medium' : 'text-white/70 text-left font-light'}`}>
          {msg.text}
        </div>
      ))}
    </div>
  );
};

export default TranscriptBox;
