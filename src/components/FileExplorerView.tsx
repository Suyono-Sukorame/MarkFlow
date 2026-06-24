import React, { useState } from 'react';
import { Folder, MarkdownFile, ActiveView } from '../types';
import { 
  Home, ChevronRight, Folder as FolderIcon, FileText, 
  MoreVertical, ArrowUpDown, Plus, FilePlus, FolderPlus, 
  Trash2, Edit, Eye, Star, Check
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

interface FileExplorerViewProps {
  files: MarkdownFile[];
  folders: Folder[];
  currentFolderId: string | null;
  onSelectFolder: (folderId: string | null) => void;
  onSelectFile: (fileId: string, view: ActiveView) => void;
  onAddFolder: (name: string, parentId: string | null) => void;
  onAddFile: (name: string, folderId: string | null) => void;
  onRenameFile: (fileId: string, newName: string) => void;
  onRenameFolder: (folderId: string, newName: string) => void;
  onDeleteFile: (fileId: string) => void;
  onDeleteFolder: (folderId: string) => void;
  onToggleFavoriteFile: (fileId: string) => void;
}

export default function FileExplorerView({
  files,
  folders,
  currentFolderId,
  onSelectFolder,
  onSelectFile,
  onAddFolder,
  onAddFile,
  onRenameFile,
  onRenameFolder,
  onDeleteFile,
  onDeleteFolder,
  onToggleFavoriteFile
}: FileExplorerViewProps) {
  const [isFabOpen, setIsFabOpen] = useState(false);
  const [showNewFolderModal, setShowNewFolderModal] = useState(false);
  const [showNewFileModal, setShowNewFileModal] = useState(false);
  const [newFolderName, setNewFolderName] = useState('');
  const [newFileName, setNewFileName] = useState('');
  const [sortOrder, setSortOrder] = useState<'name-asc' | 'name-desc' | 'date-desc'>('name-asc');
  
  // States for Context Menu / Item Options
  const [activeMenuId, setActiveMenuId] = useState<{ id: string; type: 'file' | 'folder' } | null>(null);
  const [renameState, setRenameState] = useState<{ id: string; type: 'file' | 'folder'; value: string } | null>(null);

  // 1. Traverse parent folders to build Breadcrumbs
  const getBreadcrumbs = () => {
    const crumbs: { id: string | null; name: string }[] = [{ id: null, name: 'Root' }];
    if (!currentFolderId) return crumbs;

    const path: { id: string; name: string }[] = [];
    let currId: string | null = currentFolderId;
    while (currId) {
      const folder = folders.find(f => f.id === currId);
      if (folder) {
        path.unshift({ id: folder.id, name: folder.name });
        currId = folder.parentId;
      } else {
        break;
      }
    }
    return [...crumbs, ...path];
  };

  const breadcrumbs = getBreadcrumbs();

  // 2. Filter active items based on current folder
  const currentFolders = folders.filter(f => f.parentId === currentFolderId);
  const currentFiles = files.filter(file => file.folderId === currentFolderId);

  // Apply sorting
  const sortedFolders = [...currentFolders].sort((a, b) => {
    if (sortOrder === 'name-asc') return a.name.localeCompare(b.name);
    if (sortOrder === 'name-desc') return b.name.localeCompare(a.name);
    return 0; // folders don't have rich timestamps in mock so we stay alphabetic
  });

  const sortedFiles = [...currentFiles].sort((a, b) => {
    if (sortOrder === 'name-asc') return a.name.localeCompare(b.name);
    if (sortOrder === 'name-desc') return b.name.localeCompare(a.name);
    if (sortOrder === 'date-desc') return b.updatedAt.includes('now') ? -1 : 1;
    return 0;
  });

  // 3. Modal Submissions
  const handleCreateFolderSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (newFolderName.trim()) {
      onAddFolder(newFolderName.trim(), currentFolderId);
      setNewFolderName('');
      setShowNewFolderModal(false);
      setIsFabOpen(false);
    }
  };

  const handleCreateFileSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (newFileName.trim()) {
      let finalName = newFileName.trim();
      if (!finalName.toLowerCase().endsWith('.md')) {
        finalName += '.md';
      }
      onAddFile(finalName, currentFolderId);
      setNewFileName('');
      setShowNewFileModal(false);
      setIsFabOpen(false);
    }
  };

  // 4. Handle item inline rename
  const triggerRename = (id: string, type: 'file' | 'folder', currentName: string) => {
    setRenameState({ id, type, value: currentName });
    setActiveMenuId(null);
  };

  const submitRename = () => {
    if (!renameState || !renameState.value.trim()) return;
    if (renameState.type === 'file') {
      let finalName = renameState.value.trim();
      if (!finalName.toLowerCase().endsWith('.md')) {
        finalName += '.md';
      }
      onRenameFile(renameState.id, finalName);
    } else {
      onRenameFolder(renameState.id, renameState.value.trim());
    }
    setRenameState(null);
  };

  const getItemsCountInFolder = (folderId: string) => {
    const subfolders = folders.filter(f => f.parentId === folderId).length;
    const subfiles = files.filter(f => f.folderId === folderId).length;
    return subfolders + subfiles;
  };

  return (
    <div className="relative min-h-[calc(100vh-140px)] flex flex-col pb-24">
      {/* Breadcrumb Header Section */}
      <section className="bg-surface-container-lowest sticky top-0 z-20 py-2 border-b border-outline-variant/10">
        <nav className="flex items-center overflow-x-auto whitespace-nowrap gap-1 py-1 no-scrollbar text-on-surface-variant text-xs">
          {breadcrumbs.map((crumb, idx) => (
            <React.Fragment key={crumb.id || 'root-crumb'}>
              {idx > 0 && <ChevronRight size={14} className="text-outline-variant mx-0.5" />}
              <button
                onClick={() => onSelectFolder(crumb.id)}
                className={`flex items-center hover:text-primary transition-colors cursor-pointer ${
                  idx === breadcrumbs.length - 1 ? 'font-bold text-primary' : 'font-medium'
                }`}
              >
                {crumb.id === null && <Home size={14} className="mr-1" />}
                <span>{crumb.name}</span>
              </button>
            </React.Fragment>
          ))}
        </nav>

        <div className="mt-3 flex items-center justify-between">
          <h2 className="font-serif italic font-black text-xl text-primary">
            {currentFolderId ? folders.find(f => f.id === currentFolderId)?.name + ' Notes' : 'Files'}
          </h2>
          
          <button 
            onClick={() => {
              if (sortOrder === 'name-asc') setSortOrder('name-desc');
              else if (sortOrder === 'name-desc') setSortOrder('date-desc');
              else setSortOrder('name-asc');
            }}
            className="text-on-surface-variant hover:bg-surface-variant p-2 rounded-full transition-all active:scale-95 cursor-pointer flex items-center gap-1 text-xs font-semibold font-sans"
            title="Toggle Sorting"
          >
            <ArrowUpDown size={14} />
            <span className="hidden sm:inline">
              {sortOrder === 'name-asc' ? 'A-Z' : sortOrder === 'name-desc' ? 'Z-A' : 'Newest'}
            </span>
          </button>
        </div>
      </section>

      {/* Folders & Files Container */}
      <div className="flex-1 mt-4">
        {sortedFolders.length === 0 && sortedFiles.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-20 text-center opacity-60">
            <span className="material-symbols-outlined text-outline text-[48px] select-none">folder_off</span>
            <p className="font-sans font-medium text-sm text-on-surface-variant mt-2">This folder is empty</p>
            <p className="font-sans text-xs text-on-surface-variant mt-0.5">Use the FAB button below to add content!</p>
          </div>
        ) : (
          <div className="flex flex-col gap-1.5">
            {/* 1. Folders List */}
            {sortedFolders.map(folder => (
              <div 
                key={folder.id} 
                className="flex items-center p-3 bg-surface-container-low rounded-2xl hover:bg-surface-container-high transition-colors cursor-pointer group relative border border-transparent hover:border-outline-variant/10"
              >
                <div 
                  onClick={() => onSelectFolder(folder.id)}
                  className="w-10 h-10 flex items-center justify-center bg-secondary-container text-on-secondary-container rounded-xl mr-3 select-none"
                >
                  <span className="material-symbols-outlined text-[22px]" style={{ fontVariationSettings: "'FILL' 1" }}>folder</span>
                </div>

                <div 
                  onClick={() => onSelectFolder(folder.id)}
                  className="flex-1 min-w-0"
                >
                  {renameState?.id === folder.id && renameState.type === 'folder' ? (
                    <div className="flex items-center gap-2" onClick={e => e.stopPropagation()}>
                      <input
                        type="text"
                        value={renameState.value}
                        onChange={e => setRenameState({ ...renameState, value: e.target.value })}
                        className="border border-primary rounded px-2 py-1 text-sm bg-white focus:outline-none focus:ring-1 focus:ring-primary w-40"
                        autoFocus
                        onKeyDown={e => { if (e.key === 'Enter') submitRename(); }}
                      />
                      <button onClick={submitRename} className="p-1 text-secondary hover:bg-surface-variant rounded">
                        <Check size={16} />
                      </button>
                    </div>
                  ) : (
                    <>
                      <p className="font-sans font-semibold text-sm text-on-surface truncate">{folder.name}</p>
                      <p className="text-on-surface-variant text-[11px] font-sans">
                        {getItemsCountInFolder(folder.id)} items • {folder.updatedAt}
                      </p>
                    </>
                  )}
                </div>

                {/* Folder Context Options Trigger */}
                <div className="relative" onClick={e => e.stopPropagation()}>
                  <button 
                    onClick={() => setActiveMenuId(activeMenuId?.id === folder.id && activeMenuId?.type === 'folder' ? null : { id: folder.id, type: 'folder' })}
                    className="p-2 text-on-surface-variant hover:bg-surface-variant rounded-full transition-opacity opacity-70 group-hover:opacity-100"
                  >
                    <MoreVertical size={16} />
                  </button>

                  {/* Dropdown Menu */}
                  {activeMenuId?.id === folder.id && activeMenuId?.type === 'folder' && (
                    <div className="absolute right-0 mt-1 w-36 bg-surface-container-lowest border border-outline-variant rounded-xl shadow-lg z-30 overflow-hidden font-sans">
                      <button 
                        onClick={() => triggerRename(folder.id, 'folder', folder.name)}
                        className="flex items-center gap-2 w-full px-3 py-2 text-xs text-on-surface hover:bg-surface-variant text-left"
                      >
                        <Edit size={12} /> Rename
                      </button>
                      <button 
                        onClick={() => { onDeleteFolder(folder.id); setActiveMenuId(null); }}
                        className="flex items-center gap-2 w-full px-3 py-2 text-xs text-error hover:bg-error-container/20 text-left"
                      >
                        <Trash2 size={12} /> Delete
                      </button>
                    </div>
                  )}
                </div>
              </div>
            ))}

            {/* Low-contrast Divider if folders and files co-exist */}
            {sortedFolders.length > 0 && sortedFiles.length > 0 && (
              <div className="my-2 border-b border-outline-variant/30"></div>
            )}

            {/* 2. Files List */}
            {sortedFiles.map(file => (
              <div 
                key={file.id} 
                className="flex items-center p-3 bg-surface rounded-2xl border border-surface-variant hover:shadow-md transition-all cursor-pointer group relative hover:border-primary/20"
              >
                <div 
                  onClick={() => onSelectFile(file.id, 'READER')}
                  className="w-10 h-10 flex items-center justify-center bg-primary-container text-on-primary-container rounded-xl mr-3 select-none"
                >
                  <span className="material-symbols-outlined text-[22px]">description</span>
                </div>

                <div 
                  onClick={() => onSelectFile(file.id, 'READER')}
                  className="flex-1 min-w-0"
                >
                  {renameState?.id === file.id && renameState.type === 'file' ? (
                    <div className="flex items-center gap-2" onClick={e => e.stopPropagation()}>
                      <input
                        type="text"
                        value={renameState.value}
                        onChange={e => setRenameState({ ...renameState, value: e.target.value })}
                        className="border border-primary rounded px-2 py-1 text-sm bg-white focus:outline-none focus:ring-1 focus:ring-primary w-40"
                        autoFocus
                        onKeyDown={e => { if (e.key === 'Enter') submitRename(); }}
                      />
                      <button onClick={submitRename} className="p-1 text-secondary hover:bg-surface-variant rounded">
                        <Check size={16} />
                      </button>
                    </div>
                  ) : (
                    <>
                      <p className="font-sans font-semibold text-sm text-on-surface truncate">{file.name}</p>
                      
                      {file.tags.length > 0 ? (
                        <div className="flex flex-wrap items-center gap-1 mt-1">
                          {file.tags.map(tag => {
                            let badgeStyle = 'bg-surface-container-highest text-on-surface-variant';
                            if (tag.toLowerCase() === 'urgent') badgeStyle = 'bg-tertiary-fixed text-on-tertiary-fixed';
                            if (tag.toLowerCase() === 'finals') badgeStyle = 'bg-secondary-container text-on-secondary-container';
                            return (
                              <span key={tag} className={`px-2 py-0.5 rounded-full font-sans text-[10px] font-semibold ${badgeStyle}`}>
                                {tag}
                              </span>
                            );
                          })}
                        </div>
                      ) : (
                        <p className="text-on-surface-variant text-[10px] font-sans">
                          {file.size} • Last edited {file.updatedAt}
                        </p>
                      )}
                    </>
                  )}
                </div>

                {/* Star Favorites Shortcut */}
                <button
                  onClick={() => onToggleFavoriteFile(file.id)}
                  className={`p-2 rounded-full hover:bg-surface-variant text-outline mr-1 cursor-pointer transition-colors ${file.isFavorite ? 'text-primary' : 'opacity-30 group-hover:opacity-70'}`}
                >
                  <span className="material-symbols-outlined text-[18px]" style={{ fontVariationSettings: file.isFavorite ? "'FILL' 1" : "'FILL' 0" }}>
                    star
                  </span>
                </button>

                {/* File Context Options Trigger */}
                <div className="relative" onClick={e => e.stopPropagation()}>
                  <button 
                    onClick={() => setActiveMenuId(activeMenuId?.id === file.id && activeMenuId?.type === 'file' ? null : { id: file.id, type: 'file' })}
                    className="p-2 text-on-surface-variant hover:bg-surface-variant rounded-full transition-opacity opacity-70 group-hover:opacity-100"
                  >
                    <MoreVertical size={16} />
                  </button>

                  {/* Dropdown Menu */}
                  {activeMenuId?.id === file.id && activeMenuId?.type === 'file' && (
                    <div className="absolute right-0 mt-1 w-36 bg-surface-container-lowest border border-outline-variant rounded-xl shadow-lg z-30 overflow-hidden font-sans">
                      <button 
                        onClick={() => onSelectFile(file.id, 'READER')}
                        className="flex items-center gap-2 w-full px-3 py-2 text-xs text-on-surface hover:bg-surface-variant text-left"
                      >
                        <Eye size={12} /> Read File
                      </button>
                      <button 
                        onClick={() => onSelectFile(file.id, 'EDITOR')}
                        className="flex items-center gap-2 w-full px-3 py-2 text-xs text-on-surface hover:bg-surface-variant text-left"
                      >
                        <Edit size={12} /> Edit File
                      </button>
                      <button 
                        onClick={() => triggerRename(file.id, 'file', file.name)}
                        className="flex items-center gap-2 w-full px-3 py-2 text-xs text-on-surface hover:bg-surface-variant text-left"
                      >
                        <Edit size={12} /> Rename
                      </button>
                      <button 
                        onClick={() => { onDeleteFile(file.id); setActiveMenuId(null); }}
                        className="flex items-center gap-2 w-full px-3 py-2 text-xs text-error hover:bg-error-container/20 text-left"
                      >
                        <Trash2 size={12} /> Delete
                      </button>
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Floating Action Button - Contextual expandable menu */}
      <div className="fixed bottom-24 right-4 z-40 flex flex-col items-end">
        {/* Expanded Options */}
        <AnimatePresence>
          {isFabOpen && (
            <motion.div 
              initial={{ opacity: 0, y: 15, scale: 0.9 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              exit={{ opacity: 0, y: 15, scale: 0.9 }}
              className="flex flex-col gap-3 mb-3 items-end"
            >
              <button 
                onClick={() => setShowNewFolderModal(true)}
                className="flex items-center gap-3 px-4 py-3 bg-surface-container-high hover:bg-surface-container-highest rounded-full shadow-md text-on-surface font-sans font-semibold text-xs active:scale-95 transition-all cursor-pointer border border-outline-variant/20"
              >
                <span>New Folder</span>
                <FolderPlus size={16} className="text-secondary" />
              </button>
              
              <button 
                onClick={() => setShowNewFileModal(true)}
                className="flex items-center gap-3 px-4 py-3 bg-primary-container hover:bg-primary-container/90 text-white rounded-full shadow-md font-sans font-semibold text-xs active:scale-95 transition-all cursor-pointer"
              >
                <span>New File</span>
                <FilePlus size={16} className="text-on-primary" />
              </button>
            </motion.div>
          )}
        </AnimatePresence>

        {/* Primary Toggle FAB */}
        <button 
          onClick={() => setIsFabOpen(!isFabOpen)}
          className={`w-14 h-14 bg-primary text-on-primary rounded-2xl shadow-xl flex items-center justify-center active:scale-95 transition-all cursor-pointer ${isFabOpen ? 'rotate-45 bg-[#ba1a1a]' : ''}`}
        >
          <Plus size={28} />
        </button>
      </div>

      {/* Modals for creation */}
      {showNewFolderModal && (
        <div className="fixed inset-0 bg-black/40 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-fade-in font-sans">
          <div className="bg-surface-container-lowest border border-outline-variant rounded-2xl p-6 w-full max-w-sm shadow-xl">
            <h3 className="font-bold text-base text-on-surface mb-3">Create New Folder</h3>
            <form onSubmit={handleCreateFolderSubmit}>
              <input
                type="text"
                placeholder="Folder name..."
                value={newFolderName}
                onChange={e => setNewFolderName(e.target.value)}
                className="w-full border border-outline rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary mb-4 bg-white"
                autoFocus
                required
              />
              <div className="flex justify-end gap-2">
                <button 
                  type="button" 
                  onClick={() => setShowNewFolderModal(false)}
                  className="px-4 py-2 rounded-full text-xs font-semibold text-on-surface-variant hover:bg-surface-variant"
                >
                  Cancel
                </button>
                <button 
                  type="submit"
                  className="px-4 py-2 rounded-full text-xs font-semibold bg-primary text-on-primary hover:bg-primary/90 shadow"
                >
                  Create
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {showNewFileModal && (
        <div className="fixed inset-0 bg-black/40 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-fade-in font-sans">
          <div className="bg-surface-container-lowest border border-outline-variant rounded-2xl p-6 w-full max-w-sm shadow-xl">
            <h3 className="font-bold text-base text-on-surface mb-3">Create New Markdown File</h3>
            <form onSubmit={handleCreateFileSubmit}>
              <input
                type="text"
                placeholder="File name (e.g., Notes.md)..."
                value={newFileName}
                onChange={e => setNewFileName(e.target.value)}
                className="w-full border border-outline rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary mb-4 bg-white"
                autoFocus
                required
              />
              <div className="flex justify-end gap-2">
                <button 
                  type="button" 
                  onClick={() => setShowNewFileModal(false)}
                  className="px-4 py-2 rounded-full text-xs font-semibold text-on-surface-variant hover:bg-surface-variant"
                >
                  Cancel
                </button>
                <button 
                  type="submit"
                  className="px-4 py-2 rounded-full text-xs font-semibold bg-primary text-on-primary hover:bg-primary/90 shadow"
                >
                  Create
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
