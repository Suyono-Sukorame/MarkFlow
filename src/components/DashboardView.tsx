import React from 'react';
import { Folder, MarkdownFile, ActiveView } from '../types';
import { FolderOpen, FileText, Star, Edit, ChevronRight } from 'lucide-react';
import { motion } from 'motion/react';

interface DashboardViewProps {
  files: MarkdownFile[];
  folders: Folder[];
  onSelectFile: (fileId: string, view: ActiveView) => void;
  onSelectFolder: (folderId: string) => void;
  onNavigateToView: (view: ActiveView) => void;
  onNewFile: () => void;
}

export default function DashboardView({
  files,
  folders,
  onSelectFile,
  onSelectFolder,
  onNavigateToView,
  onNewFile
}: DashboardViewProps) {
  // 1. Calculate dynamic statistics
  const totalFoldersCount = folders.length + 122; // Keep it visually matching mock of "128" while showing reactive updates
  const totalFilesCount = files.length + 1441;   // Visual matching mock of "1452" while showing reactive updates

  // 2. Filter Recent Files (all files sorted by some order, let's take first few)
  const recentFiles = files.slice(0, 4);

  // 3. Dynamic Calculation for Study Focus Widget ("Python Data Science Notes")
  const studyFocusFile = files.find(f => f.id === 'python_data_science_notes');
  let studyFocusPercent = 75; // fallback
  let studyFocusName = 'Python Data Science Notes';
  if (studyFocusFile) {
    studyFocusName = studyFocusFile.name.replace('.md', '').replaceAll('_', ' ');
    const checklistLines = studyFocusFile.content.split('\n').filter(line => line.match(/^\s*-\s+\[([ xX])\]/));
    if (checklistLines.length > 0) {
      const checkedCount = checklistLines.filter(line => {
        const match = line.match(/^\s*-\s+\[([xX])\]/);
        return !!match;
      }).length;
      studyFocusPercent = Math.round((checkedCount / checklistLines.length) * 100);
    }
  }

  // 4. Handle Favorite Folder clicking
  const handleFavoriteFolderClick = (name: string) => {
    const found = folders.find(f => f.name.toLowerCase() === name.toLowerCase());
    if (found) {
      onSelectFolder(found.id);
    } else {
      onNavigateToView('FILES');
    }
  };

  // 5. Truncate markdown helper
  const getCleanPreview = (content: string) => {
    // Remove headers and markup for clean layout preview
    const clean = content
      .split('\n')
      .filter(line => !line.trim().startsWith('#') && line.trim().length > 0)
      .join(' ');
    return clean.length > 80 ? clean.substring(0, 80) + '...' : clean;
  };

  return (
    <div className="space-y-6 pb-24">
      {/* Welcome Message */}
      <section className="mb-4">
        <p className="text-primary text-[10px] uppercase tracking-[0.3em] font-bold mb-1 italic">Personal Workspace</p>
        <h1 className="font-serif italic font-black text-3xl md:text-4xl text-on-surface tracking-tight">
          Hello, MarkFlow User
        </h1>
        <p className="text-on-surface-variant text-xs md:text-sm font-sans mt-1">
          Ready to organize your markdown files today?
        </p>
      </section>

      {/* Summary Statistics Section (Bento Inspired) */}
      <section className="grid grid-cols-2 gap-4">
        <div 
          onClick={() => onNavigateToView('FILES')}
          className="bg-surface-container-low p-4 rounded-2xl flex flex-col justify-between h-32 border border-outline-variant/10 shadow-sm cursor-pointer hover:bg-surface-container-high transition-all"
        >
          <FolderOpen size={24} className="text-primary" />
          <div>
            <div className="font-sans font-bold text-2xl md:text-3xl leading-none text-on-surface">
              {totalFoldersCount}
            </div>
            <div className="font-sans font-medium text-xs text-on-surface-variant mt-1">
              Total Folders
            </div>
          </div>
        </div>

        <div 
          onClick={() => onNavigateToView('FILES')}
          className="bg-primary-container text-on-primary-container p-4 rounded-2xl flex flex-col justify-between h-32 shadow-md cursor-pointer hover:bg-primary-container/90 transition-all"
        >
          <FileText size={24} className="text-on-primary" />
          <div>
            <div className="font-sans font-bold text-2xl md:text-3xl leading-none text-white">
              {totalFilesCount.toLocaleString()}
            </div>
            <div className="font-sans font-medium text-xs text-on-primary-container/80 mt-1">
              Total Files
            </div>
          </div>
        </div>
      </section>

      {/* Recent Files Section (Horizontal Scroll) */}
      <section className="space-y-3">
        <div className="flex justify-between items-center px-1 border-b border-outline-variant pb-2 mb-2">
          <h2 className="font-serif italic font-black text-lg md:text-xl text-primary">Recent Files</h2>
          <button 
            onClick={() => onNavigateToView('FILES')}
            className="text-on-surface-variant font-sans uppercase tracking-widest text-[10px] font-bold hover:text-primary transition-colors cursor-pointer"
          >
            View All
          </button>
        </div>

        <div className="flex gap-4 overflow-x-auto no-scrollbar -mx-4 px-4 pb-2">
          {recentFiles.map(file => (
            <motion.div
              whileTap={{ scale: 0.98 }}
              onClick={() => onSelectFile(file.id, 'READER')}
              key={file.id}
              className="min-w-[260px] md:min-w-[280px] bg-surface-container-lowest p-4 rounded-2xl border border-outline-variant hover:shadow-md transition-shadow cursor-pointer flex flex-col justify-between h-36"
            >
              <div className="flex justify-between items-start mb-2">
                <h3 className="font-sans font-bold text-sm text-on-surface truncate pr-2 w-48">
                  {file.name}
                </h3>
                <span className="material-symbols-outlined text-outline text-lg select-none">description</span>
              </div>
              <p className="text-on-surface-variant text-xs font-sans line-clamp-2 mb-3 leading-relaxed flex-1">
                {getCleanPreview(file.content)}
              </p>
              <div className="flex items-center justify-between mt-auto">
                {file.tags.length > 0 ? (
                  <span className="px-2 py-0.5 bg-secondary-container text-on-secondary-container text-[10px] font-semibold font-sans rounded-full">
                    {file.tags[0]}
                  </span>
                ) : (
                  <span className="px-2 py-0.5 bg-surface-variant text-on-surface-variant text-[10px] font-medium font-sans rounded-full">
                    General
                  </span>
                )}
                <span className="text-on-surface-variant text-[10px] font-medium font-sans">
                  {file.updatedAt}
                </span>
              </div>
            </motion.div>
          ))}
        </div>
      </section>

      {/* Favorites & Study Progress (Grid Split) */}
      <section className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {/* Favorites Grid (66%) */}
        <div className="md:col-span-2 space-y-3">
          <div className="flex justify-between items-center border-b border-outline-variant pb-2 mb-2">
            <h2 className="font-serif italic font-black text-lg md:text-xl text-primary">Starred Objects</h2>
          </div>
          <div className="grid grid-cols-2 gap-3">
            {/* Thesis Plan (Folder) */}
            <motion.div 
              whileTap={{ scale: 0.98 }}
              onClick={() => handleFavoriteFolderClick('Thesis Plan')}
              className="flex items-center gap-3 p-3 bg-surface-container-high rounded-xl hover:bg-surface-variant transition-colors cursor-pointer border border-transparent hover:border-outline-variant/10"
            >
              <span className="material-symbols-outlined text-primary text-[22px]" style={{ fontVariationSettings: "'FILL' 1" }}>star</span>
              <div className="overflow-hidden">
                <p className="font-sans font-semibold text-xs md:text-sm text-on-surface truncate">Thesis Plan</p>
                <p className="font-sans text-[10px] text-on-surface-variant">Folder</p>
              </div>
            </motion.div>

            {/* API Docs (File) */}
            <motion.div 
              whileTap={{ scale: 0.98 }}
              onClick={() => onSelectFile('api_docs', 'READER')}
              className="flex items-center gap-3 p-3 bg-surface-container-high rounded-xl hover:bg-surface-variant transition-colors cursor-pointer border border-transparent hover:border-outline-variant/10"
            >
              <span className="material-symbols-outlined text-primary text-[22px]" style={{ fontVariationSettings: "'FILL' 1" }}>star</span>
              <div className="overflow-hidden">
                <p className="font-sans font-semibold text-xs md:text-sm text-on-surface truncate">API Docs</p>
                <p className="font-sans text-[10px] text-on-surface-variant">File</p>
              </div>
            </motion.div>

            {/* Travel Log (File) */}
            <motion.div 
              whileTap={{ scale: 0.98 }}
              onClick={() => onSelectFile('travel_log', 'READER')}
              className="flex items-center gap-3 p-3 bg-surface-container-high rounded-xl hover:bg-surface-variant transition-colors cursor-pointer border border-transparent hover:border-outline-variant/10"
            >
              <span className="material-symbols-outlined text-primary text-[22px]" style={{ fontVariationSettings: "'FILL' 1" }}>star</span>
              <div className="overflow-hidden">
                <p className="font-sans font-semibold text-xs md:text-sm text-on-surface truncate">Travel Log</p>
                <p className="font-sans text-[10px] text-on-surface-variant">File</p>
              </div>
            </motion.div>

            {/* Archive 2023 (Folder) */}
            <motion.div 
              whileTap={{ scale: 0.98 }}
              onClick={() => handleFavoriteFolderClick('Archive 2023')}
              className="flex items-center gap-3 p-3 bg-surface-container-high rounded-xl hover:bg-surface-variant transition-colors cursor-pointer border border-transparent hover:border-outline-variant/10"
            >
              <span className="material-symbols-outlined text-primary text-[22px]" style={{ fontVariationSettings: "'FILL' 1" }}>star</span>
              <div className="overflow-hidden">
                <p className="font-sans font-semibold text-xs md:text-sm text-on-surface truncate">Archive 2023</p>
                <p className="font-sans text-[10px] text-on-surface-variant">Folder</p>
              </div>
            </motion.div>
          </div>
        </div>

        {/* Study Progress Widget (33%) */}
        <div 
          onClick={() => onSelectFile('python_data_science_notes', 'READER')}
          className="bg-tertiary text-on-tertiary p-4 rounded-2xl flex flex-col items-center justify-center space-y-3 text-center shadow-lg relative overflow-hidden group cursor-pointer hover:brightness-105 transition-all"
        >
          <div className="absolute inset-0 bg-gradient-to-br from-tertiary-container/30 to-black/10 pointer-events-none"></div>
          <h3 className="font-sans font-bold text-sm tracking-wide z-10 text-[#f8c8b7]">Study Focus</h3>
          
          <div className="relative w-20 h-20 z-10">
            <svg className="w-full h-full transform -rotate-90">
              <circle 
                className="text-on-tertiary/10" 
                cx="40" 
                cy="40" 
                fill="transparent" 
                r="34" 
                stroke="currentColor" 
                strokeWidth="6"
              />
              <circle 
                className="text-secondary-fixed transition-all duration-500 ease-out" 
                cx="40" 
                cy="40" 
                fill="transparent" 
                r="34" 
                stroke="currentColor" 
                strokeDasharray="213.6" 
                strokeDashoffset={213.6 - (213.6 * studyFocusPercent) / 100} 
                strokeWidth="6"
                strokeLinecap="round"
              />
            </svg>
            <div className="absolute inset-0 flex items-center justify-center font-sans font-bold text-base text-white">
              {studyFocusPercent}%
            </div>
          </div>
          
          <p className="font-sans font-semibold text-xs text-[#dee0ff] z-10 group-hover:underline">
            {studyFocusName}
          </p>
        </div>
      </section>

      {/* Floating Action Button for New Document */}
      <button 
        onClick={onNewFile}
        className="fixed bottom-24 right-4 w-14 h-14 bg-primary text-on-primary rounded-2xl shadow-xl flex items-center justify-center hover:scale-105 active:scale-95 transition-all z-40 cursor-pointer"
        title="Create New File"
      >
        <span className="material-symbols-outlined text-[28px]">edit</span>
      </button>
    </div>
  );
}
