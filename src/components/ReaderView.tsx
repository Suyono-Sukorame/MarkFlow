import React, { useState } from 'react';
import { MarkdownFile, ActiveView } from '../types';
import { ArrowLeft, Edit, Star, Share2, Clipboard, Edit2, Menu } from 'lucide-react';
import MarkdownRenderer from './MarkdownRenderer';
import { motion, AnimatePresence } from 'motion/react';

interface ReaderViewProps {
  file: MarkdownFile;
  onBack: () => void;
  onEdit: () => void;
  onToggleFavorite: (fileId: string) => void;
  onUpdateFileContent: (fileId: string, newContent: string) => void;
}

export default function ReaderView({
  file,
  onBack,
  onEdit,
  onToggleFavorite,
  onUpdateFileContent
}: ReaderViewProps) {
  const [showShareToast, setShowShareToast] = useState(false);
  const [showToc, setShowToc] = useState(false);

  // Parse headers from markdown content to construct a beautiful dynamic Table of Contents
  const getHeaders = () => {
    const lines = file.content.split('\n');
    const headers: { level: number; text: string; lineIndex: number }[] = [];
    lines.forEach((line, index) => {
      const match = line.match(/^(#{1,3})\s+(.*)$/);
      if (match) {
        headers.push({
          level: match[1].length,
          text: match[2].replaceAll('**', '').replaceAll('*', ''),
          lineIndex: index
        });
      }
    });
    return headers;
  };

  const headers = getHeaders();

  // Handle Share copy link
  const handleShare = () => {
    const url = window.location.href;
    navigator.clipboard.writeText(`${url}?file=${file.id}`);
    setShowShareToast(true);
    setTimeout(() => setShowShareToast(false), 2000);
  };

  // Directly toggle checkboxes in reader mode!
  const handleToggleChecklist = (lineIndex: number) => {
    const lines = file.content.split('\n');
    const line = lines[lineIndex];
    const match = line.match(/^(\s*)-\s+\[([ xX])\]\s+(.*)$/);
    if (match) {
      const isChecked = match[2].toLowerCase() === 'x';
      const spacing = match[1];
      const text = match[3];
      lines[lineIndex] = `${spacing}- [${isChecked ? ' ' : 'x'}] ${text}`;
      onUpdateFileContent(file.id, lines.join('\n'));
    }
  };

  return (
    <div className="relative min-h-screen bg-surface text-on-surface font-sans">
      {/* Top App Bar */}
      <header className="fixed top-0 left-0 right-0 h-14 bg-surface/90 backdrop-blur-md border-b border-outline-variant/30 flex items-center justify-between px-4 z-40 shadow-xs">
        <div className="flex items-center gap-2">
          <button 
            onClick={onBack}
            className="p-2 rounded-full hover:bg-surface-variant active:scale-95 transition-all text-on-surface-variant cursor-pointer"
            title="Back"
          >
            <ArrowLeft size={18} />
          </button>
          <h1 className="font-sans font-bold text-sm text-primary tracking-tight truncate w-40 sm:w-60">
            {file.name}
          </h1>
        </div>

        <div className="flex items-center gap-1">
          {/* Table of Contents Menu Toggle */}
          {headers.length > 0 && (
            <button 
              onClick={() => setShowToc(!showToc)}
              className={`p-2 rounded-full hover:bg-surface-variant text-on-surface-variant cursor-pointer transition-colors ${showToc ? 'text-primary bg-primary/10' : ''}`}
              title="Table of Contents"
            >
              <Menu size={18} />
            </button>
          )}

          <button 
            onClick={onEdit}
            className="p-2 rounded-full hover:bg-surface-variant text-on-surface-variant cursor-pointer"
            title="Edit Document"
          >
            <Edit size={18} />
          </button>
          
          <button 
            onClick={() => onToggleFavorite(file.id)}
            className={`p-2 rounded-full hover:bg-surface-variant cursor-pointer transition-colors ${file.isFavorite ? 'text-primary' : 'text-on-surface-variant'}`}
            title="Favorite Document"
          >
            <span className="material-symbols-outlined text-[20px]" style={{ fontVariationSettings: file.isFavorite ? "'FILL' 1" : "'FILL' 0" }}>
              star
            </span>
          </button>

          <button 
            onClick={handleShare}
            className="p-2 rounded-full hover:bg-surface-variant text-on-surface-variant cursor-pointer"
            title="Share Document"
          >
            <Share2 size={18} />
          </button>
        </div>
      </header>

      {/* Main Content Area */}
      <main className="max-w-2xl mx-auto pt-20 pb-32 px-4 selection:bg-primary-container selection:text-on-primary-container">
        <article className="space-y-4">
          <MarkdownRenderer 
            content={file.content} 
            onToggleChecklist={handleToggleChecklist} 
          />
        </article>
      </main>

      {/* Slide-out Table of Contents Sidebar */}
      <AnimatePresence>
        {showToc && (
          <>
            {/* Scrim Overlay */}
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 0.3 }}
              exit={{ opacity: 0 }}
              onClick={() => setShowToc(false)}
              className="fixed inset-0 bg-black z-40 cursor-pointer"
            />
            {/* Sidebar content */}
            <motion.aside 
              initial={{ x: '100%' }}
              animate={{ x: 0 }}
              exit={{ x: '100%' }}
              transition={{ type: 'tween', duration: 0.25 }}
              className="fixed top-14 right-0 bottom-0 w-64 bg-surface border-l border-outline-variant z-50 p-4 overflow-y-auto shadow-xl"
            >
              <h3 className="font-sans font-bold text-xs uppercase tracking-wider text-outline mb-4">
                Table of Contents
              </h3>
              <ul className="space-y-2">
                {headers.map((h, idx) => (
                  <li 
                    key={idx}
                    style={{ paddingLeft: `${(h.level - 1) * 12}px` }}
                  >
                    <button
                      onClick={() => {
                        setShowToc(false);
                        // Simple window scrolling to simulated heading
                        const headingElement = document.querySelectorAll('.prose-markdown h1, .prose-markdown h2, .prose-markdown h3')[idx];
                        if (headingElement) {
                          headingElement.scrollIntoView({ behavior: 'smooth', block: 'center' });
                        }
                      }}
                      className="text-left text-xs font-sans text-on-surface-variant hover:text-primary transition-colors hover:underline"
                    >
                      {h.text}
                    </button>
                  </li>
                ))}
              </ul>
            </motion.aside>
          </>
        )}
      </AnimatePresence>

      {/* Floating Action Button (FAB): Toggle to Editor */}
      <button 
        onClick={onEdit}
        className="fixed bottom-6 right-4 w-14 h-14 bg-primary text-on-primary rounded-2xl shadow-xl flex items-center justify-center active:scale-90 transition-all duration-200 hover:bg-primary-container group z-[45] cursor-pointer"
        title="Switch to Editor"
      >
        <span className="material-symbols-outlined text-[26px]">edit_note</span>
        <span className="absolute right-16 bg-inverse-surface text-inverse-on-surface text-[11px] px-2.5 py-1 rounded-md opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap pointer-events-none font-sans font-medium shadow shadow-black/10 border border-outline/10">
          Switch to Editor
        </span>
      </button>

      {/* Toast Notification */}
      <AnimatePresence>
        {showShareToast && (
          <motion.div 
            initial={{ opacity: 0, y: 40 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 40 }}
            className="fixed bottom-24 left-1/2 -translate-x-1/2 bg-inverse-surface text-inverse-on-surface px-4 py-2.5 rounded-full text-xs font-sans font-semibold shadow-lg z-50 flex items-center gap-2"
          >
            <Clipboard size={14} className="text-secondary-fixed" />
            <span>Document share link copied!</span>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
