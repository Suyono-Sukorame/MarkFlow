import React, { useState, useEffect, useRef } from 'react';
import { MarkdownFile } from '../types';
import { 
  ArrowLeft, Undo, Redo, Cloud, Menu, Eye, Edit3, CheckCircle,
  Bold, Italic, Link2, List, Table, Image as ImageIcon, Code
} from 'lucide-react';
import MarkdownRenderer from './MarkdownRenderer';
import { motion, AnimatePresence } from 'motion/react';

interface EditorViewProps {
  file: MarkdownFile;
  onBack: () => void;
  onSave: (fileId: string, content: string, name: string) => void;
}

export default function EditorView({ file, onBack, onSave }: EditorViewProps) {
  const [content, setContent] = useState(file.content);
  const [fileName, setFileName] = useState(file.name);
  const [mobileTab, setMobileTab] = useState<'editor' | 'preview'>('editor');
  const [saveStatus, setSaveStatus] = useState<'saved' | 'unsaved' | 'saving'>('saved');
  const [showToc, setShowToc] = useState(false);

  // History state for Undo & Redo
  const [undoStack, setUndoStack] = useState<string[]>([]);
  const [redoStack, setRedoStack] = useState<string[]>([]);

  const textareaRef = useRef<HTMLTextAreaElement>(null);

  // Parse headers for Table of Contents
  const getHeaders = () => {
    const lines = content.split('\n');
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

  // Handle auto-saving on a debounce (1.5 seconds)
  useEffect(() => {
    if (content === file.content && fileName === file.name) {
      setSaveStatus('saved');
      return;
    }

    setSaveStatus('unsaved');
    const timer = setTimeout(() => {
      setSaveStatus('saving');
      onSave(file.id, content, fileName);
      setSaveStatus('saved');
    }, 1500);

    return () => clearTimeout(timer);
  }, [content, fileName]);

  // Handle Text Changes and History push
  const handleContentChange = (newVal: string) => {
    // Avoid putting identical sequential states in history
    if (undoStack.length === 0 || undoStack[undoStack.length - 1] !== content) {
      setUndoStack(prev => [...prev, content]);
    }
    setRedoStack([]); // clear redo stack on new action
    setContent(newVal);
  };

  // Undo Function
  const handleUndo = () => {
    if (undoStack.length === 0) return;
    const previous = undoStack[undoStack.length - 1];
    setRedoStack(prev => [content, ...prev]);
    setContent(previous);
    setUndoStack(prev => prev.slice(0, prev.length - 1));
  };

  // Redo Function
  const handleRedo = () => {
    if (redoStack.length === 0) return;
    const next = redoStack[0];
    setUndoStack(prev => [...prev, content]);
    setContent(next);
    setRedoStack(prev => prev.slice(1));
  };

  // Insert formatting at cursor position
  const insertFormatting = (type: 'bold' | 'italic' | 'link' | 'list' | 'table' | 'image' | 'code') => {
    const textarea = textareaRef.current;
    if (!textarea) return;

    const start = textarea.selectionStart;
    const end = textarea.selectionEnd;
    const text = textarea.value;
    const selectedText = text.substring(start, end);

    let replacement = '';
    let cursorOffset = 0;

    switch (type) {
      case 'bold':
        replacement = `**${selectedText || 'text'}**`;
        cursorOffset = selectedText ? replacement.length : 2;
        break;
      case 'italic':
        replacement = `*${selectedText || 'text'}*`;
        cursorOffset = selectedText ? replacement.length : 1;
        break;
      case 'link':
        replacement = `[${selectedText || 'link text'}](https://url.com)`;
        cursorOffset = selectedText ? replacement.length : 1;
        break;
      case 'list':
        // Insert a checklist / bullet item at the start of current line or current position
        replacement = `\n- [ ] ${selectedText || 'Task'}`;
        cursorOffset = replacement.length;
        break;
      case 'table':
        replacement = `\n| Header 1 | Header 2 |\n| :--- | :--- |\n| Cell 1 | Cell 2 | \n`;
        cursorOffset = replacement.length;
        break;
      case 'image':
        replacement = `![${selectedText || 'alt text'}](https://image-url.com)`;
        cursorOffset = selectedText ? replacement.length : 2;
        break;
      case 'code':
        replacement = `\n\`\`\`javascript\n${selectedText || '// code here'}\n\`\`\`\n`;
        cursorOffset = replacement.length;
        break;
    }

    const newContent = text.substring(0, start) + replacement + text.substring(end);
    handleContentChange(newContent);

    // Refocus and place cursor appropriately
    setTimeout(() => {
      textarea.focus();
      textarea.setSelectionRange(start + cursorOffset, start + cursorOffset);
    }, 10);
  };

  // Immediate explicit Save
  const handleManualSave = () => {
    setSaveStatus('saving');
    onSave(file.id, content, fileName);
    setSaveStatus('saved');
  };

  return (
    <div className="flex flex-col h-screen bg-surface overflow-hidden">
      {/* Header Bar */}
      <header className="bg-surface-container-low text-primary flex justify-between items-center px-4 h-14 w-full z-40 shadow-xs shrink-0 select-none">
        <div className="flex items-center gap-3">
          <button 
            onClick={onBack}
            className="p-2 rounded-full hover:bg-surface-variant active:scale-95 transition-transform text-on-surface-variant cursor-pointer"
          >
            <ArrowLeft size={18} />
          </button>
          
          <input
            type="text"
            value={fileName}
            onChange={e => setFileName(e.target.value)}
            className="font-sans font-bold text-base md:text-lg text-primary tracking-tight bg-transparent border-b border-transparent hover:border-outline-variant/50 focus:border-primary focus:outline-none focus:ring-0 px-1 py-0.5 rounded transition-all max-w-[120px] sm:max-w-[240px]"
            title="Edit File Name"
          />
        </div>

        <div className="flex items-center gap-2">
          {/* Saved Status Indicator */}
          <div className="hidden sm:flex items-center gap-1.5 text-on-surface-variant mr-2">
            <Cloud size={16} className={`transition-all duration-300 ${saveStatus === 'saving' ? 'animate-pulse text-secondary' : 'opacity-80'}`} />
            <span className="font-sans text-[10px] md:text-xs">
              {saveStatus === 'saved' ? 'Saved' : saveStatus === 'saving' ? 'Saving...' : 'Unsaved changes'}
            </span>
          </div>

          <div className="flex items-center bg-surface-container rounded-xl p-0.5">
            <button 
              onClick={handleUndo}
              disabled={undoStack.length === 0}
              className={`p-2 hover:bg-surface-variant rounded-lg active:scale-95 transition-transform cursor-pointer ${undoStack.length === 0 ? 'opacity-30 pointer-events-none' : ''}`}
              title="Undo"
            >
              <Undo size={16} />
            </button>
            <button 
              onClick={handleRedo}
              disabled={redoStack.length === 0}
              className={`p-2 hover:bg-surface-variant rounded-lg active:scale-95 transition-transform cursor-pointer ${redoStack.length === 0 ? 'opacity-30 pointer-events-none' : ''}`}
              title="Redo"
            >
              <Redo size={16} />
            </button>
          </div>

          <button 
            onClick={handleManualSave}
            disabled={saveStatus === 'saved'}
            className={`bg-primary text-on-primary px-4 py-1.5 rounded-full font-sans text-xs font-semibold active:scale-95 transition-transform cursor-pointer shadow-sm ${saveStatus === 'saved' ? 'opacity-60 pointer-events-none bg-primary/40' : 'hover:bg-primary/90'}`}
          >
            Save
          </button>
        </div>
      </header>

      {/* Editor Body Area */}
      <main className="flex-1 flex overflow-hidden relative">
        {/* Editor Pane (Left Side in desktop / Toggled inside mobile) */}
        <section 
          className={`h-full flex flex-col border-r border-outline-variant bg-surface-container-lowest transition-all duration-300 ${
            mobileTab === 'editor' ? 'w-full md:w-1/2' : 'hidden md:flex md:w-1/2'
          }`}
        >
          {/* Sub Header label */}
          <div className="flex items-center justify-between px-4 py-1.5 bg-surface-container-low text-on-surface-variant select-none border-b border-outline-variant/35">
            <span className="font-sans text-[11px] font-bold uppercase tracking-wider">Markdown Editor</span>
            {/* Mobile Tab Toggle view toggler */}
            <div className="md:hidden">
              <button 
                onClick={() => setMobileTab('preview')}
                className="text-primary font-sans font-semibold text-xs flex items-center gap-1 cursor-pointer"
              >
                Preview <Eye size={14} />
              </button>
            </div>
          </div>

          {/* Text Area Raw Text Input */}
          <div className="flex-1 relative overflow-hidden">
            <textarea
              ref={textareaRef}
              value={content}
              onChange={e => handleContentChange(e.target.value)}
              className="absolute inset-0 w-full h-full p-4 font-mono text-xs md:text-sm bg-transparent resize-none focus:outline-none focus:ring-0 text-on-surface-variant leading-relaxed custom-scrollbar selection:bg-primary-fixed selection:text-on-primary-fixed"
              spellCheck="false"
              placeholder="Start writing markdown content..."
            />
          </div>
        </section>

        {/* Live Preview Pane (Right Side in desktop / Toggled inside mobile) */}
        <section 
          className={`h-full flex flex-col bg-surface transition-all duration-300 ${
            mobileTab === 'preview' ? 'w-full md:w-1/2' : 'hidden md:flex md:w-1/2'
          }`}
        >
          {/* Sub Header label */}
          <div className="flex items-center justify-between px-4 py-1.5 bg-surface-container-low text-on-surface-variant select-none border-b border-outline-variant/35">
            <span className="font-sans text-[11px] font-bold uppercase tracking-wider">Live Preview</span>
            {/* Mobile Tab Toggle view toggler */}
            <div className="md:hidden">
              <button 
                onClick={() => setMobileTab('editor')}
                className="text-primary font-sans font-semibold text-xs flex items-center gap-1 cursor-pointer"
              >
                Edit <Edit3 size={14} />
              </button>
            </div>
          </div>

          {/* Rendered Preview Screen */}
          <div className="flex-1 overflow-y-auto p-4 md:p-6 custom-scrollbar pb-24 selection:bg-primary-fixed selection:text-on-primary-fixed">
            <MarkdownRenderer content={content} />
          </div>
        </section>
      </main>

      {/* Floating Action Button: Table of Contents */}
      {headers.length > 0 && (
        <button 
          onClick={() => setShowToc(!showToc)}
          className="fixed bottom-24 right-4 bg-primary-container text-on-primary-container w-14 h-14 rounded-2xl flex items-center justify-center shadow-lg active:scale-95 transition-transform z-40 cursor-pointer"
          title="Outline Map"
        >
          <Menu size={24} />
        </button>
      )}

      {/* Quick Formatting Toolbar fixed at absolute bottom */}
      <nav className="shrink-0 bg-surface-container-high h-16 md:h-20 flex items-center justify-center px-4 z-40 border-t border-outline-variant select-none relative">
        <div className="flex items-center gap-1 sm:gap-2 bg-surface px-4 py-1.5 rounded-full shadow-sm">
          <button 
            onClick={() => insertFormatting('bold')}
            className="p-2 hover:bg-surface-variant rounded-full text-on-surface-variant active:scale-90 transition-all cursor-pointer"
            title="Bold"
          >
            <Bold size={16} />
          </button>
          
          <button 
            onClick={() => insertFormatting('italic')}
            className="p-2 hover:bg-surface-variant rounded-full text-on-surface-variant active:scale-90 transition-all cursor-pointer"
            title="Italic"
          >
            <Italic size={16} />
          </button>
          
          <button 
            onClick={() => insertFormatting('link')}
            className="p-2 hover:bg-surface-variant rounded-full text-on-surface-variant active:scale-90 transition-all cursor-pointer"
            title="Insert Link"
          >
            <Link2 size={16} />
          </button>
          
          <div className="w-[1px] h-6 bg-outline-variant mx-1 sm:mx-2"></div>
          
          <button 
            onClick={() => insertFormatting('list')}
            className="p-2 hover:bg-surface-variant rounded-full text-on-surface-variant active:scale-90 transition-all cursor-pointer"
            title="List checklist item"
          >
            <List size={16} />
          </button>
          
          <button 
            onClick={() => insertFormatting('table')}
            className="p-2 hover:bg-surface-variant rounded-full text-on-surface-variant active:scale-90 transition-all cursor-pointer"
            title="Mock Table"
          >
            <Table size={16} />
          </button>
          
          <button 
            onClick={() => insertFormatting('image')}
            className="p-2 hover:bg-surface-variant rounded-full text-on-surface-variant active:scale-90 transition-all cursor-pointer"
            title="Image Reference"
          >
            <ImageIcon size={16} />
          </button>
          
          <button 
            onClick={() => insertFormatting('code')}
            className="p-2 hover:bg-surface-variant rounded-full text-on-surface-variant active:scale-90 transition-all cursor-pointer"
            title="Code Block"
          >
            <Code size={16} />
          </button>
        </div>

        {/* Mobile Quick-Save Badge */}
        <div className="absolute right-4 text-secondary md:hidden flex items-center">
          <CheckCircle size={20} className={saveStatus === 'saved' ? 'opacity-100 text-secondary' : 'opacity-30'} />
        </div>
      </nav>

      {/* Outlines List TOC Slide panel */}
      <AnimatePresence>
        {showToc && (
          <>
            {/* Scrim Overlay */}
            <div 
              onClick={() => setShowToc(false)}
              className="fixed inset-0 bg-black/30 z-40 cursor-pointer"
            />
            {/* Sidebar content */}
            <motion.aside 
              initial={{ x: '100%' }}
              animate={{ x: 0 }}
              exit={{ x: '100%' }}
              transition={{ type: 'tween', duration: 0.25 }}
              className="fixed top-14 right-0 bottom-20 w-64 bg-surface border-l border-outline-variant z-50 p-4 overflow-y-auto shadow-xl"
            >
              <h3 className="font-sans font-bold text-xs uppercase tracking-wider text-outline mb-4">
                Document Outlines
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
                        // Move cursor to that line index inside textarea
                        const textarea = textareaRef.current;
                        if (textarea) {
                          const lines = content.split('\n');
                          let charIndex = 0;
                          for (let i = 0; i < h.lineIndex; i++) {
                            charIndex += lines[i].length + 1; // +1 for the newline char
                          }
                          textarea.focus();
                          textarea.setSelectionRange(charIndex, charIndex);
                        }
                        // Scroll heading into view if in preview mode
                        if (mobileTab === 'preview') {
                          const headingElement = document.querySelectorAll('.prose-markdown h1, .prose-markdown h2, .prose-markdown h3')[idx];
                          if (headingElement) {
                            headingElement.scrollIntoView({ behavior: 'smooth', block: 'center' });
                          }
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
    </div>
  );
}
