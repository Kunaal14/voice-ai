
import React from 'react';

const TigestLogo = () => (
  <svg viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg" className="w-full h-full">
    <circle cx="50" cy="50" r="50" fill="black"/>
    <path d="M20 26.5H41V67.5L20 47V26.5Z" fill="white"/>
    <path d="M41 26.5H82V47.5H61.5L41 68V88.5L82 47.5V26.5H41Z" fill="white"/>
    <path d="M41 26.5L61.5 47.5H41V26.5Z" fill="black" fillOpacity="0.3"/>
  </svg>
);

const Header: React.FC = () => {
  const scrollTo = (id: string) => {
    const el = document.getElementById(id);
    if (el) {
      el.scrollIntoView({ behavior: 'smooth' });
    }
  };

  return (
    <header className="fixed top-0 left-0 right-0 z-50 bg-[#050505]/80 backdrop-blur-lg border-b border-white/5">
      <div className="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <div className="w-10 h-10 flex items-center justify-center">
            <TigestLogo />
          </div>
          <span className="text-xl font-outfit font-bold text-white tracking-tight">Tigest</span>
        </div>
        
        <nav className="hidden md:flex items-center space-x-8 text-sm font-medium text-white/60">
          <button onClick={() => scrollTo('solutions')} className="hover:text-white transition-colors">Solutions</button>
          <button onClick={() => scrollTo('results')} className="hover:text-white transition-colors">Results</button>
          <button onClick={() => scrollTo('clients')} className="hover:text-white transition-colors">Clients</button>
          <button onClick={() => scrollTo('roi-calculator')} className="hover:text-white transition-colors">ROI</button>
        </nav>
        
        <div className="flex items-center">
          <button 
            onClick={() => scrollTo('voice-agent-container')}
            className="px-5 py-2.5 bg-white text-black font-semibold text-sm rounded-xl hover:bg-white/90 transition-all active:scale-[0.98]"
          >
            Launch Demo
          </button>
        </div>
      </div>
    </header>
  );
};

export default Header;
