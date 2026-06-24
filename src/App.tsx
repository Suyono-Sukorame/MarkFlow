import React, { useState, useEffect } from 'react';
import { Folder, MarkdownFile, ActiveView } from './types';
import { INITIAL_FILES, INITIAL_FOLDERS } from './data';
import DashboardView from './components/DashboardView';
import FileExplorerView from './components/FileExplorerView';
import SearchView from './components/SearchView';
import ReaderView from './components/ReaderView';
import EditorView from './components/EditorView';
import { Home, FolderOpen, Search, Star, Settings, Plus, RotateCcw, ShieldCheck } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

// Seed initial state or fetch from LocalStorage
const getLocalStorageFiles = (): MarkdownFile[] => {
  const data = localStorage.getItem('markflow_files');
  if (data) {
    try {
      return JSON.parse(data);
    } catch {
      return INITIAL_FILES;
    }
  }
  localStorage.setItem('markflow_files', JSON.stringify(INITIAL_FILES));
  return INITIAL_FILES;
};

const getLocalStorageFolders = (): Folder[] => {
  const data = localStorage.getItem('markflow_folders');
  if (data) {
    try {
      return JSON.parse(data);
    } catch {
      return INITIAL_FOLDERS;
    }
  }
  localStorage.setItem('markflow_folders', JSON.stringify(INITIAL_FOLDERS));
  return INITIAL_FOLDERS;
};

export default function App() {
  const [files, setFiles] = useState<MarkdownFile[]>(getLocalStorageFiles);
  const [folders, setFolders] = useState<Folder[]>(getLocalStorageFolders);

  // Default explorer folder starts on 'study' to match the screenshot "Study Notes"
  const [currentFolderId, setCurrentFolderId] = useState<string | null>('study');
  const [activeView, setActiveView] = useState<ActiveView>('DASHBOARD');
  const [selectedFileId, setSelectedFileId] = useState<string | null>(null);

  // History stack for Back operations (stores previous screen config)
  const [history, setHistory] = useState<{ view: ActiveView; fileId: string | null; folderId: string | null }[]>([]);

  // Synchronize state with LocalStorage
  useEffect(() => {
    localStorage.setItem('markflow_files', JSON.stringify(files));
  }, [files]);

  useEffect(() => {
    localStorage.setItem('markflow_folders', JSON.stringify(folders));
  }, [folders]);

  // Navigate view with history tracking
  const navigateTo = (view: ActiveView, fileId: string | null = null, folderId: string | null = null) => {
    // Record current state in history
    setHistory(prev => [...prev, { view: activeView, fileId: selectedFileId, folderId: currentFolderId }]);
    
    if (fileId) setSelectedFileId(fileId);
    if (folderId !== undefined) setCurrentFolderId(folderId);
    setActiveView(view);
  };

  // Handle Back Action
  const handleBack = () => {
    if (history.length === 0) {
      // Fallback if no history exists
      setActiveView('DASHBOARD');
      return;
    }
    const previous = history[history.length - 1];
    setHistory(prev => prev.slice(0, prev.length - 1));
    setActiveView(previous.view);
    setSelectedFileId(previous.fileId);
    setCurrentFolderId(previous.folderId);
  };

  // Switch primary bottom bar tabs directly (clears custom sub-page stacks)
  const handleTabChange = (view: ActiveView) => {
    setHistory([]); // clear sub-page stacks
    setActiveView(view);
    if (view === 'FILES' && !currentFolderId) {
      setCurrentFolderId('study'); // keep on study by default to display the mock folder layout
    }
  };

  // 1. Core Markdown Data Operations
  const handleAddFolder = (name: string, parentId: string | null) => {
    const newFolder: Folder = {
      id: `folder-${Date.now()}`,
      name,
      parentId,
      updatedAt: 'Just now'
    };
    setFolders(prev => [newFolder, ...prev]);
  };

  const handleAddFile = (name: string, folderId: string | null) => {
    const newFile: MarkdownFile = {
      id: `file-${Date.now()}`,
      name,
      content: `# ${name.replace('.md', '')}\n\nStart writing notes here...`,
      folderId,
      tags: [],
      isFavorite: false,
      updatedAt: 'Just now',
      size: '0.1kb'
    };
    setFiles(prev => [newFile, ...prev]);
    // Instantly transition to editing mode!
    navigateTo('EDITOR', newFile.id);
  };

  const handleRenameFile = (fileId: string, newName: string) => {
    setFiles(prev => prev.map(f => f.id === fileId ? { ...f, name: newName, updatedAt: 'Just now' } : f));
  };

  const handleRenameFolder = (folderId: string, newName: string) => {
    setFolders(prev => prev.map(f => f.id === folderId ? { ...f, name: newName, updatedAt: 'Just now' } : f));
  };

  const handleDeleteFile = (fileId: string) => {
    setFiles(prev => prev.filter(f => f.id !== fileId));
  };

  const handleDeleteFolder = (folderId: string) => {
    // Delete folders recursively, also deleting files in those folders
    const getSubfolderIds = (id: string): string[] => {
      let ids = [id];
      folders.filter(f => f.parentId === id).forEach(child => {
        ids = [...ids, ...getSubfolderIds(child.id)];
      });
      return ids;
    };

    const targetFolderIds = getSubfolderIds(folderId);
    setFolders(prev => prev.filter(f => !targetFolderIds.includes(f.id)));
    setFiles(prev => prev.filter(f => f.folderId === null || !targetFolderIds.includes(f.folderId)));
    
    // If we deleted the current active folder, step up to root
    if (targetFolderIds.includes(currentFolderId || '')) {
      setCurrentFolderId(null);
    }
  };

  const handleToggleFavoriteFile = (fileId: string) => {
    setFiles(prev => prev.map(f => f.id === fileId ? { ...f, isFavorite: !f.isFavorite } : f));
  };

  const handleUpdateFileContent = (fileId: string, newContent: string) => {
    const sizeInKb = (newContent.length / 1024).toFixed(1) + 'kb';
    setFiles(prev => prev.map(f => f.id === fileId ? { ...f, content: newContent, size: sizeInKb, updatedAt: 'Just now' } : f));
  };

  const handleEditorSave = (fileId: string, newContent: string, newName: string) => {
    const sizeInKb = (newContent.length / 1024).toFixed(1) + 'kb';
    setFiles(prev => prev.map(f => f.id === fileId ? { ...f, content: newContent, name: newName, size: sizeInKb, updatedAt: 'Just now' } : f));
  };

  // Reset database helper for user convenience in Settings
  const handleResetDatabase = () => {
    localStorage.removeItem('markflow_files');
    localStorage.removeItem('markflow_folders');
    setFiles(INITIAL_FILES);
    setFolders(INITIAL_FOLDERS);
    setCurrentFolderId('study');
    setActiveView('DASHBOARD');
  };

  // Filter Favorite Files list
  const favoriteFiles = files.filter(f => f.isFavorite);

  // Locate current active file
  const activeFile = files.find(f => f.id === selectedFileId);

  // Determine if we should show the persistent bottom nav bar & app header
  const isDocumentCentricView = activeView === 'READER' || activeView === 'EDITOR';

  return (
    <div className="min-h-screen bg-surface text-on-surface flex flex-col font-sans">
      {/* 1. Global Header Bar (shown on Tab views only) */}
      {!isDocumentCentricView && (
        <header className="bg-surface sticky top-0 flex justify-between items-center px-4 h-14 w-full z-40 border-b border-outline-variant/10 shrink-0">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-full overflow-hidden border border-outline-variant/30 bg-surface-container-high flex items-center justify-center">
              <img 
                className="w-full h-full object-cover" 
                src="https://lh3.googleusercontent.com/aida-public/AB6AXuDPGtRpeJbbEFtgJb4S7pnIL0NjzvOPKdGp4qlX_MXafpe5sJZ20VIIqaLeIgHMghqe_sFcWCMcFfNjDCOmoXWtcxKc9XmMEvIHgHvnxec-WyIf5WatKGt52bDBE1eI3PxjoL7V_pvHWfba9cSsVZXJGQSgwS8OPMsxYNkDSI6Q7jAGkP0SLxfaD6S4OO4p21NWd9F3vuNqug5sLoVp8SoqIohBdlurRT9VaNppIkzBhkJWdXoR0neoA2I9YOKgq74WCE3xyRXoWfE" 
                alt="User headshot avatar"
                referrerPolicy="no-referrer"
              />
            </div>
            <span className="font-serif font-black text-xl text-primary italic tracking-widest">MARKFLOW</span>
          </div>

          <button 
            onClick={() => handleAddFile('New Note.md', currentFolderId)}
            className="text-primary hover:bg-surface-variant p-2 rounded-full active:scale-95 transition-transform duration-150 cursor-pointer"
            title="Create New File"
          >
            <Plus size={20} />
          </button>
        </header>
      )}

      {/* 2. Primary Page Content area */}
      <div className={`flex-1 overflow-x-hidden ${!isDocumentCentricView ? 'px-4 pt-4' : ''}`}>
        <AnimatePresence mode="wait">
          {activeView === 'DASHBOARD' && (
            <motion.div 
              key="dashboard"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
            >
              <DashboardView 
                files={files}
                folders={folders}
                onSelectFile={(id, mode) => navigateTo(mode, id)}
                onSelectFolder={(id) => navigateTo('FILES', null, id)}
                onNavigateToView={handleTabChange}
                onNewFile={() => handleAddFile('Untitled.md', currentFolderId)}
              />
            </motion.div>
          )}

          {activeView === 'FILES' && (
            <motion.div 
              key="explorer"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
            >
              <FileExplorerView 
                files={files}
                folders={folders}
                currentFolderId={currentFolderId}
                onSelectFolder={setCurrentFolderId}
                onSelectFile={(id, mode) => navigateTo(mode, id)}
                onAddFolder={handleAddFolder}
                onAddFile={handleAddFile}
                onRenameFile={handleRenameFile}
                onRenameFolder={handleRenameFolder}
                onDeleteFile={handleDeleteFile}
                onDeleteFolder={handleDeleteFolder}
                onToggleFavoriteFile={handleToggleFavoriteFile}
              />
            </motion.div>
          )}

          {activeView === 'SEARCH' && (
            <motion.div 
              key="search"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
            >
              <SearchView 
                files={files} 
                onSelectFile={(id, mode) => navigateTo(mode, id)} 
              />
            </motion.div>
          )}

          {activeView === 'FAVORITES' && (
            <motion.div 
              key="favorites"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              className="space-y-6 pb-24 font-sans"
            >
              <div>
                <h1 className="font-sans font-extrabold text-xl text-on-surface">Starred Documents</h1>
                <p className="text-on-surface-variant text-xs mt-0.5">Your quick-access favorited files and resources.</p>
              </div>

              {favoriteFiles.length === 0 ? (
                <div className="py-16 text-center opacity-60 flex flex-col items-center justify-center">
                  <Star size={40} className="text-outline mb-3" />
                  <p className="font-sans font-semibold text-sm text-on-surface-variant">No starred documents yet</p>
                  <p className="font-sans text-xs text-on-surface-variant max-w-xs mt-0.5">
                    Click the star icon next to any document in your Explorer or Reader view to flag it as favorite.
                  </p>
                </div>
              ) : (
                <div className="grid grid-cols-1 gap-2">
                  {favoriteFiles.map(file => (
                    <motion.div
                      whileTap={{ scale: 0.99 }}
                      onClick={() => navigateTo('READER', file.id)}
                      key={file.id}
                      className="p-4 bg-surface rounded-2xl border border-surface-variant hover:shadow-sm transition-all cursor-pointer flex items-center justify-between"
                    >
                      <div className="flex items-center gap-3">
                        <span className="material-symbols-outlined text-primary text-[20px]">description</span>
                        <div>
                          <p className="font-sans font-semibold text-sm text-on-surface">{file.name}</p>
                          <p className="text-[10px] text-on-surface-variant font-medium font-sans">
                            {file.size} • Last edited {file.updatedAt}
                          </p>
                        </div>
                      </div>
                      <span className="material-symbols-outlined text-primary text-[20px]" style={{ fontVariationSettings: "'FILL' 1" }}>
                        star
                      </span>
                    </motion.div>
                  ))}
                </div>
              )}
            </motion.div>
          )}

          {activeView === 'SETTINGS' && (
            <motion.div 
              key="settings"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              className="space-y-6 pb-24 font-sans"
            >
              <div>
                <h1 className="font-sans font-extrabold text-xl text-on-surface">Settings</h1>
                <p className="text-on-surface-variant text-xs mt-0.5">Manage preferences and local markdown content state.</p>
              </div>

              {/* User Account Info */}
              <section className="bg-surface-container-low p-4 rounded-2xl border border-outline-variant/10">
                <h3 className="text-xs font-semibold uppercase tracking-wider text-outline mb-3">Account Profile</h3>
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center text-primary font-bold">
                    S
                  </div>
                  <div>
                    <p className="font-sans font-semibold text-sm text-on-surface">Suyono</p>
                    <p className="text-xs text-on-surface-variant/80 font-mono">suyono@aqj.or.id</p>
                  </div>
                </div>
              </section>

              {/* Reset database section */}
              <section className="bg-surface-container-low p-4 rounded-2xl border border-outline-variant/10 space-y-4">
                <div>
                  <h3 className="text-xs font-semibold uppercase tracking-wider text-outline">Workspace Actions</h3>
                  <p className="text-xs text-on-surface-variant mt-1 leading-relaxed">
                    Resetting the workspace database will clear all your custom changes and restore default directories and study guides.
                  </p>
                </div>
                
                <button 
                  onClick={handleResetDatabase}
                  className="px-4 py-2 bg-error text-on-error rounded-full text-xs font-bold font-sans active:scale-95 transition-transform shadow cursor-pointer hover:bg-error/95 flex items-center gap-1.5"
                >
                  <RotateCcw size={14} />
                  <span>Restore Demo Database</span>
                </button>
              </section>

              {/* Diagnostics details */}
              <section className="bg-surface-container-low p-4 rounded-2xl border border-outline-variant/10 space-y-2">
                <h3 className="text-xs font-semibold uppercase tracking-wider text-outline">Workspace Diagnostics</h3>
                <div className="space-y-1 text-xs font-mono text-on-surface-variant/80">
                  <p>Folders Count: {folders.length}</p>
                  <p>Files Count: {files.length}</p>
                  <p>Active Layout: Corporate Modern (MD3)</p>
                  <p>Status: Local-First Persistent</p>
                </div>
                <div className="pt-2 flex items-center gap-1.5 text-xs text-secondary font-sans font-semibold select-none">
                  <ShieldCheck size={14} />
                  <span>All databases synchronized & secure</span>
                </div>
              </section>
            </motion.div>
          )}

          {activeView === 'READER' && activeFile && (
            <motion.div 
              key="reader"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="absolute inset-0 z-50 overflow-y-auto"
            >
              <ReaderView 
                file={activeFile}
                onBack={handleBack}
                onEdit={() => navigateTo('EDITOR', activeFile.id)}
                onToggleFavorite={handleToggleFavoriteFile}
                onUpdateFileContent={handleUpdateFileContent}
              />
            </motion.div>
          )}

          {activeView === 'EDITOR' && activeFile && (
            <motion.div 
              key="editor"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="absolute inset-0 z-50 overflow-hidden"
            >
              <EditorView 
                file={activeFile}
                onBack={handleBack}
                onSave={handleEditorSave}
              />
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      {/* 3. Global Bottom Navigation Bar (Tab views only) */}
      {!isDocumentCentricView && (
        <nav className="fixed bottom-0 left-0 right-0 h-20 bg-surface border-t border-outline-variant/20 flex items-center justify-around px-2 z-40 shadow-[0_-2px_10px_rgba(0,0,0,0.03)] pb-safe select-none">
          {/* Home Tab */}
          <button 
            onClick={() => handleTabChange('DASHBOARD')}
            className="flex flex-col items-center justify-center p-2 relative w-16 group cursor-pointer"
          >
            <div className={`py-1 px-4 rounded-full transition-all duration-200 ${activeView === 'DASHBOARD' ? 'bg-secondary-container text-on-secondary-container' : 'text-on-surface-variant group-hover:bg-surface-variant/40'}`}>
              <Home size={20} className={activeView === 'DASHBOARD' ? 'stroke-[2.5px]' : 'stroke-[2px]'} />
            </div>
            <span className={`text-[10px] font-sans font-medium mt-1 transition-colors ${activeView === 'DASHBOARD' ? 'text-primary font-bold' : 'text-on-surface-variant'}`}>
              Home
            </span>
          </button>

          {/* Files Tab */}
          <button 
            onClick={() => handleTabChange('FILES')}
            className="flex flex-col items-center justify-center p-2 relative w-16 group cursor-pointer"
          >
            <div className={`py-1 px-4 rounded-full transition-all duration-200 ${activeView === 'FILES' ? 'bg-secondary-container text-on-secondary-container' : 'text-on-surface-variant group-hover:bg-surface-variant/40'}`}>
              <FolderOpen size={20} className={activeView === 'FILES' ? 'stroke-[2.5px]' : 'stroke-[2px]'} />
            </div>
            <span className={`text-[10px] font-sans font-medium mt-1 transition-colors ${activeView === 'FILES' ? 'text-primary font-bold' : 'text-on-surface-variant'}`}>
              Files
            </span>
          </button>

          {/* Search Tab */}
          <button 
            onClick={() => handleTabChange('SEARCH')}
            className="flex flex-col items-center justify-center p-2 relative w-16 group cursor-pointer"
          >
            <div className={`py-1 px-4 rounded-full transition-all duration-200 ${activeView === 'SEARCH' ? 'bg-secondary-container text-on-secondary-container' : 'text-on-surface-variant group-hover:bg-surface-variant/40'}`}>
              <Search size={20} className={activeView === 'SEARCH' ? 'stroke-[2.5px]' : 'stroke-[2px]'} />
            </div>
            <span className={`text-[10px] font-sans font-medium mt-1 transition-colors ${activeView === 'SEARCH' ? 'text-primary font-bold' : 'text-on-surface-variant'}`}>
              Search
            </span>
          </button>

          {/* Favorites Tab */}
          <button 
            onClick={() => handleTabChange('FAVORITES')}
            className="flex flex-col items-center justify-center p-2 relative w-16 group cursor-pointer"
          >
            <div className={`py-1 px-4 rounded-full transition-all duration-200 ${activeView === 'FAVORITES' ? 'bg-secondary-container text-on-secondary-container' : 'text-on-surface-variant group-hover:bg-surface-variant/40'}`}>
              <Star size={20} className={activeView === 'FAVORITES' ? 'stroke-[2.5px]' : 'stroke-[2px]'} />
            </div>
            <span className={`text-[10px] font-sans font-medium mt-1 transition-colors ${activeView === 'FAVORITES' ? 'text-primary font-bold' : 'text-on-surface-variant'}`}>
              Favorites
            </span>
          </button>

          {/* Settings Tab */}
          <button 
            onClick={() => handleTabChange('SETTINGS')}
            className="flex flex-col items-center justify-center p-2 relative w-16 group cursor-pointer"
          >
            <div className={`py-1 px-4 rounded-full transition-all duration-200 ${activeView === 'SETTINGS' ? 'bg-secondary-container text-on-secondary-container' : 'text-on-surface-variant group-hover:bg-surface-variant/40'}`}>
              <Settings size={20} className={activeView === 'SETTINGS' ? 'stroke-[2.5px]' : 'stroke-[2px]'} />
            </div>
            <span className={`text-[10px] font-sans font-medium mt-1 transition-colors ${activeView === 'SETTINGS' ? 'text-primary font-bold' : 'text-on-surface-variant'}`}>
              Settings
            </span>
          </button>
        </nav>
      )}
    </div>
  );
}
