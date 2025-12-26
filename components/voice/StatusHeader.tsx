
import React from 'react';

interface StatusHeaderProps {
  timeLeft: number;
  status: string;
}

const StatusHeader: React.FC<StatusHeaderProps> = ({ timeLeft, status }) => {
  if (status !== 'CONNECTED') return null;

  return (
    <div className="absolute top-8 left-1/2 -translate-x-1/2 px-4 py-2 rounded-full bg-white/5 border border-white/10 text-[10px] font-mono text-white/40 tracking-[0.2em] z-30 flex items-center space-x-2">
      <div className="w-1.5 h-1.5 rounded-full bg-green-500 animate-pulse" />
      <span>SESSION: {Math.floor(timeLeft / 60)}:{(timeLeft % 60).toString().padStart(2, '0')}</span>
    </div>
  );
};

export default StatusHeader;
