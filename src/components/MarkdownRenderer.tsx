import React, { useState } from 'react';
import { Check, Copy } from 'lucide-react';

interface MarkdownRendererProps {
  content: string;
  onToggleChecklist?: (lineIndex: number) => void;
}

export default function MarkdownRenderer({ content, onToggleChecklist }: MarkdownRendererProps) {
  const [copiedCodeId, setCopiedCodeId] = useState<string | null>(null);

  const handleCopyCode = (codeText: string, blockId: string) => {
    navigator.clipboard.writeText(codeText);
    setCopiedCodeId(blockId);
    setTimeout(() => setCopiedCodeId(null), 2000);
  };

  const lines = content.split('\n');
  const renderedElements: React.ReactNode[] = [];
  
  let i = 0;
  while (i < lines.length) {
    const line = lines[i];

    // 1. Code Block Parsing
    if (line.trim().startsWith('```')) {
      const language = line.trim().slice(3).trim();
      let codeLines: string[] = [];
      i++;
      while (i < lines.length && !lines[i].trim().startsWith('```')) {
        codeLines.push(lines[i]);
        i++;
      }
      const codeText = codeLines.join('\n');
      const blockId = `code-${i}`;
      
      renderedElements.push(
        <div key={`code-block-${i}`} className="my-4 rounded-xl bg-inverse-surface p-4 text-sm font-mono overflow-x-auto shadow-sm text-inverse-on-surface relative group">
          <div className="flex justify-between items-center mb-2 pb-1 border-b border-outline/30 text-xs text-outline font-sans">
            <span className="uppercase tracking-wider font-semibold text-[10px]">{language || 'code'}</span>
            <button
              onClick={() => handleCopyCode(codeText, blockId)}
              className="flex items-center gap-1 hover:text-white transition-colors cursor-pointer"
            >
              {copiedCodeId === blockId ? (
                <>
                  <Check size={12} className="text-secondary-fixed" />
                  <span className="text-secondary-fixed">Copied</span>
                </>
              ) : (
                <>
                  <Copy size={12} />
                  <span>Copy</span>
                </>
              )}
            </button>
          </div>
          <pre className="text-xs md:text-sm font-mono leading-relaxed select-text custom-scrollbar whitespace-pre">{codeText}</pre>
        </div>
      );
      i++;
      continue;
    }

    // 2. Table Parsing
    if (line.trim().startsWith('|') && i + 1 < lines.length && lines[i + 1].trim().includes('---')) {
      const headers = line.split('|').map(s => s.trim()).filter((_, index, arr) => index > 0 && index < arr.length - 1);
      const alignLine = lines[i + 1];
      const alignments = alignLine.split('|').map(s => s.trim()).filter((_, index, arr) => index > 0 && index < arr.length - 1).map(align => {
        if (align.startsWith(':') && align.endsWith(':')) return 'center';
        if (align.endsWith(':')) return 'right';
        return 'left';
      });

      let rowLines: string[][] = [];
      i += 2;
      while (i < lines.length && lines[i].trim().startsWith('|')) {
        const cols = lines[i].split('|').map(s => s.trim()).filter((_, index, arr) => index > 0 && index < arr.length - 1);
        rowLines.push(cols);
        i++;
      }

      renderedElements.push(
        <div key={`table-${i}`} className="overflow-x-auto border border-outline-variant rounded-xl mb-4 shadow-sm bg-surface-container-low custom-scrollbar">
          <table className="w-full text-left text-sm font-sans border-collapse">
            <thead className="bg-surface-container-high border-b border-outline-variant text-on-surface font-semibold text-xs uppercase tracking-wider">
              <tr>
                {headers.map((h, idx) => (
                  <th 
                    key={`th-${idx}`} 
                    className="px-4 py-3 font-semibold text-on-surface-variant"
                    style={{ textAlign: alignments[idx] as any || 'left' }}
                  >
                    {inlineFormatter(h)}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-outline-variant">
              {rowLines.map((row, rowIdx) => (
                <tr key={`tr-${rowIdx}`} className="hover:bg-surface-container transition-colors">
                  {headers.map((_, colIdx) => (
                    <td 
                      key={`td-${rowIdx}-${colIdx}`} 
                      className="px-4 py-3 text-on-surface font-sans"
                      style={{ textAlign: alignments[colIdx] as any || 'left' }}
                    >
                      {inlineFormatter(row[colIdx] || '')}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      );
      continue;
    }

    // 3. Header Parsing
    if (line.startsWith('# ')) {
      renderedElements.push(
        <h1 key={`h1-${i}`} className="font-sans font-bold text-2xl md:text-3xl text-primary mt-6 mb-4 leading-tight tracking-tight border-b border-outline-variant/20 pb-1">
          {inlineFormatter(line.slice(2))}
        </h1>
      );
      i++;
      continue;
    }
    if (line.startsWith('## ')) {
      renderedElements.push(
        <h2 key={`h2-${i}`} className="font-sans font-bold text-lg md:text-xl text-on-surface mt-5 mb-3 leading-snug tracking-tight border-b border-outline-variant pb-1">
          {inlineFormatter(line.slice(3))}
        </h2>
      );
      i++;
      continue;
    }
    if (line.startsWith('### ')) {
      renderedElements.push(
        <h3 key={`h3-${i}`} className="font-sans font-semibold text-base md:text-lg text-on-surface-variant mt-4 mb-2 leading-snug">
          {inlineFormatter(line.slice(4))}
        </h3>
      );
      i++;
      continue;
    }

    // 4. Blockquote Parsing
    if (line.startsWith('> ')) {
      let quoteLines = [line.slice(2)];
      i++;
      while (i < lines.length && lines[i].startsWith('> ')) {
        quoteLines.push(lines[i].slice(2));
        i++;
      }
      renderedElements.push(
        <blockquote key={`quote-${i}`} className="p-4 border-l-4 border-primary bg-primary-fixed/20 rounded-r-xl italic text-on-primary-fixed-variant my-4 leading-relaxed font-sans">
          {inlineFormatter(quoteLines.join('\n'))}
        </blockquote>
      );
      continue;
    }

    // 5. Checklist Item Parsing
    const todoMatch = line.match(/^(\s*)-\s+\[([ xX])\]\s+(.*)$/);
    if (todoMatch) {
      const lineIdx = i; // capture exact line index for toggling
      const checked = todoMatch[2].toLowerCase() === 'x';
      const text = todoMatch[3];
      renderedElements.push(
        <div 
          key={`checklist-${i}`} 
          className="flex items-center gap-3 p-3 rounded-xl bg-surface-container-low mb-2 hover:bg-surface-container-high transition-colors group cursor-pointer border border-transparent hover:border-outline-variant/10"
          onClick={() => onToggleChecklist && onToggleChecklist(lineIdx)}
        >
          <span className={`material-symbols-outlined text-[20px] transition-all select-none duration-150 ${checked ? 'text-primary' : 'text-outline hover:text-primary'}`} style={{ fontVariationSettings: checked ? "'FILL' 1" : "'FILL' 0" }}>
            {checked ? 'check_box' : 'check_box_outline_blank'}
          </span>
          <span className={`font-sans text-sm text-on-surface transition-all ${checked ? 'line-through text-on-surface-variant/60' : ''}`}>
            {inlineFormatter(text)}
          </span>
        </div>
      );
      i++;
      continue;
    }

    // 6. Bullet List Parsing
    if (line.trim().startsWith('- ') || line.trim().startsWith('* ')) {
      let listItems = [line.trim().slice(2)];
      i++;
      while (i < lines.length && (lines[i].trim().startsWith('- ') || lines[i].trim().startsWith('* '))) {
        // Exclude checklists which starting with - [ ]
        if (lines[i].trim().match(/^-\s+\[([ xX])\]/)) {
          break;
        }
        listItems.push(lines[i].trim().slice(2));
        i++;
      }
      renderedElements.push(
        <ul key={`list-${i}`} className="list-disc pl-6 mb-4 space-y-1.5 font-sans text-on-surface-variant">
          {listItems.map((item, idx) => (
            <li key={`li-${idx}`} className="text-sm leading-relaxed">
              {inlineFormatter(item)}
            </li>
          ))}
        </ul>
      );
      continue;
    }

    // 7. Numbered List Parsing
    if (line.trim().match(/^\d+\.\s+/)) {
      let numItems = [line.trim().replace(/^\d+\.\s+/, '')];
      i++;
      while (i < lines.length && lines[i].trim().match(/^\d+\.\s+/)) {
        numItems.push(lines[i].trim().replace(/^\d+\.\s+/, ''));
        i++;
      }
      renderedElements.push(
        <ol key={`num-list-${i}`} className="list-decimal pl-6 mb-4 space-y-1.5 font-sans text-on-surface-variant">
          {numItems.map((item, idx) => (
            <li key={`num-li-${idx}`} className="text-sm leading-relaxed">
              {inlineFormatter(item)}
            </li>
          ))}
        </ol>
      );
      continue;
    }

    // 8. Normal Paragraph
    if (line.trim().length > 0) {
      renderedElements.push(
        <p key={`p-${i}`} className="font-sans text-sm md:text-base text-on-surface-variant leading-relaxed mb-3">
          {inlineFormatter(line)}
        </p>
      );
    } else {
      // Empty line spacer
      renderedElements.push(<div key={`spacer-${i}`} className="h-2"></div>);
    }

    i++;
  }

  return (
    <div className="prose-markdown select-text">
      {renderedElements}
    </div>
  );
}

// Simple Inline Parser for Bold, Italic, Code Backticks, and Links
function inlineFormatter(text: string): React.ReactNode[] {
  // We will parse:
  // - Links: [Text](Url)
  // - Bold: **text**
  // - Italic: *text* or _text_
  // - Code inline: `code`
  
  let parts: { type: 'text' | 'bold' | 'italic' | 'code' | 'link'; content: string; url?: string }[] = [{ type: 'text', content: text }];

  // 1. Parse Links first: [label](url)
  let updatedParts: typeof parts = [];
  parts.forEach(part => {
    if (part.type !== 'text') {
      updatedParts.push(part);
      return;
    }
    const regex = /\[([^\]]+)\]\(([^)]+)\)/g;
    let match;
    let lastIndex = 0;
    while ((match = regex.exec(part.content)) !== null) {
      if (match.index > lastIndex) {
        updatedParts.push({ type: 'text', content: part.content.substring(lastIndex, match.index) });
      }
      updatedParts.push({ type: 'link', content: match[1], url: match[2] });
      lastIndex = regex.lastIndex;
    }
    if (lastIndex < part.content.length) {
      updatedParts.push({ type: 'text', content: part.content.substring(lastIndex) });
    }
  });
  parts = updatedParts;

  // 2. Parse Bold: **text**
  updatedParts = [];
  parts.forEach(part => {
    if (part.type !== 'text') {
      updatedParts.push(part);
      return;
    }
    const regex = /\*\*([^*]+)\*\*/g;
    let match;
    let lastIndex = 0;
    while ((match = regex.exec(part.content)) !== null) {
      if (match.index > lastIndex) {
        updatedParts.push({ type: 'text', content: part.content.substring(lastIndex, match.index) });
      }
      updatedParts.push({ type: 'bold', content: match[1] });
      lastIndex = regex.lastIndex;
    }
    if (lastIndex < part.content.length) {
      updatedParts.push({ type: 'text', content: part.content.substring(lastIndex) });
    }
  });
  parts = updatedParts;

  // 3. Parse Inline Code: `code`
  updatedParts = [];
  parts.forEach(part => {
    if (part.type !== 'text') {
      updatedParts.push(part);
      return;
    }
    const regex = /`([^`]+)`/g;
    let match;
    let lastIndex = 0;
    while ((match = regex.exec(part.content)) !== null) {
      if (match.index > lastIndex) {
        updatedParts.push({ type: 'text', content: part.content.substring(lastIndex, match.index) });
      }
      updatedParts.push({ type: 'code', content: match[1] });
      lastIndex = regex.lastIndex;
    }
    if (lastIndex < part.content.length) {
      updatedParts.push({ type: 'text', content: part.content.substring(lastIndex) });
    }
  });
  parts = updatedParts;

  // 4. Parse Italic: *text* or _text_
  updatedParts = [];
  parts.forEach(part => {
    if (part.type !== 'text') {
      updatedParts.push(part);
      return;
    }
    const regex = /\*([^*]+)\*/g;
    let match;
    let lastIndex = 0;
    while ((match = regex.exec(part.content)) !== null) {
      if (match.index > lastIndex) {
        updatedParts.push({ type: 'text', content: part.content.substring(lastIndex, match.index) });
      }
      updatedParts.push({ type: 'italic', content: match[1] });
      lastIndex = regex.lastIndex;
    }
    if (lastIndex < part.content.length) {
      updatedParts.push({ type: 'text', content: part.content.substring(lastIndex) });
    }
  });
  parts = updatedParts;

  // Return formatted react nodes
  return parts.map((part, index) => {
    switch (part.type) {
      case 'bold':
        return <strong key={index} className="font-bold text-on-surface">{part.content}</strong>;
      case 'italic':
        return <em key={index} className="italic text-on-surface-variant">{part.content}</em>;
      case 'code':
        return <code key={index} className="px-1.5 py-0.5 bg-surface-variant text-secondary text-xs rounded font-mono border border-outline-variant/10">{part.content}</code>;
      case 'link':
        return <a key={index} href={part.url || '#'} target="_blank" rel="referrer noopener" className="text-primary hover:underline font-medium inline-flex items-center gap-0.5">{part.content}</a>;
      default:
        return <span key={index}>{part.content}</span>;
    }
  });
}
