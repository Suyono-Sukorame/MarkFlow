import React, { useState, useEffect } from 'react';
import { MarkdownFile, ActiveView } from '../types';
import { Search, FileText, Check, FileCode2 } from 'lucide-react';
import { motion } from 'motion/react';

interface SearchViewProps {
  files: MarkdownFile[];
  onSelectFile: (fileId: string, view: ActiveView) => void;
}

export default function SearchView({ files, onSelectFile }: SearchViewProps) {
  const [query, setQuery] = useState('');
  const [searchByName, setSearchByName] = useState(true);
  const [searchByContent, setSearchByContent] = useState(false);
  const [searchByTags, setSearchByTags] = useState(false);
  const [results, setResults] = useState<MarkdownFile[]>([]);

  useEffect(() => {
    if (query.trim().length <= 2) {
      setResults([]);
      return;
    }

    const lowerQuery = query.toLowerCase().trim();
    const filtered = files.filter(file => {
      let match = false;
      
      if (searchByName && file.name.toLowerCase().includes(lowerQuery)) {
        match = true;
      }
      
      if (searchByContent && file.content.toLowerCase().includes(lowerQuery)) {
        match = true;
      }
      
      if (searchByTags && file.tags.some(tag => tag.toLowerCase().includes(lowerQuery))) {
        match = true;
      }

      // Default fallback if no search category is toggled: search all
      if (!searchByName && !searchByContent && !searchByTags) {
        match = file.name.toLowerCase().includes(lowerQuery) || 
                file.content.toLowerCase().includes(lowerQuery) ||
                file.tags.some(tag => tag.toLowerCase().includes(lowerQuery));
      }

      return match;
    });

    setResults(filtered);
  }, [query, searchByName, searchByContent, searchByTags, files]);

  // Helper function to extract a snippet containing the searched query and highlight it
  const getHighlightedSnippet = (content: string, keyword: string) => {
    if (!keyword) return content.length > 120 ? content.substring(0, 120) + '...' : content;
    
    const lowerContent = content.toLowerCase();
    const lowerKeyword = keyword.toLowerCase().trim();
    const index = lowerContent.indexOf(lowerKeyword);
    
    if (index === -1) {
      // Fallback if content match was negative but we need a preview
      return content.length > 120 ? content.substring(0, 120) + '...' : content;
    }

    // Determine start and end surrounding words
    const start = Math.max(0, index - 40);
    const end = Math.min(content.length, index + lowerKeyword.length + 80);
    let snippet = content.substring(start, end);
    
    if (start > 0) snippet = '...' + snippet;
    if (end < content.length) snippet = snippet + '...';

    // Highlight the keyword (case-insensitive replace with styled span)
    const parts = snippet.split(new RegExp(`(${escapeRegExp(lowerKeyword)})`, 'gi'));
    return (
      <span className="leading-relaxed font-sans text-xs text-on-surface-variant">
        {parts.map((part, idx) => 
          part.toLowerCase() === lowerKeyword ? (
            <span key={idx} className="bg-primary-fixed text-on-primary-fixed px-1 rounded font-semibold">
              {part}
            </span>
          ) : (
            part
          )
        )}
      </span>
    );
  };

  const escapeRegExp = (string: string) => {
    return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  };

  return (
    <div className="space-y-6 pb-24 font-sans">
      {/* Search Header Section */}
      <section className="mt-4">
        <div className="relative group">
          <div className="absolute inset-y-0 left-4 flex items-center pointer-events-none text-on-surface-variant">
            <Search size={20} />
          </div>
          <input
            type="text"
            value={query}
            onChange={e => setQuery(e.target.value)}
            placeholder="Search your markdown..."
            className="w-full h-14 pl-12 pr-4 bg-surface-container-high border-none rounded-full text-sm text-on-surface focus:outline-none focus:ring-2 focus:ring-primary transition-all duration-200"
            autoFocus
          />
        </div>

        {/* Filter Chips */}
        <div className="flex flex-wrap gap-2 mt-4 select-none">
          {/* File Name Chip */}
          <button
            onClick={() => setSearchByName(!searchByName)}
            className={`px-4 py-1.5 rounded-full font-sans text-xs font-semibold flex items-center gap-1 cursor-pointer transition-all ${
              searchByName
                ? 'bg-secondary-container text-on-secondary-container'
                : 'border border-outline-variant text-on-surface-variant hover:bg-surface-container-high'
            }`}
          >
            {searchByName && <Check size={14} />}
            <span>File Name</span>
          </button>

          {/* Content Chip */}
          <button
            onClick={() => setSearchByContent(!searchByContent)}
            className={`px-4 py-1.5 rounded-full font-sans text-xs font-semibold flex items-center gap-1 cursor-pointer transition-all ${
              searchByContent
                ? 'bg-secondary-container text-on-secondary-container'
                : 'border border-outline-variant text-on-surface-variant hover:bg-surface-container-high'
            }`}
          >
            {searchByContent && <Check size={14} />}
            <span>Content</span>
          </button>

          {/* Tags Chip */}
          <button
            onClick={() => setSearchByTags(!searchByTags)}
            className={`px-4 py-1.5 rounded-full font-sans text-xs font-semibold flex items-center gap-1 cursor-pointer transition-all ${
              searchByTags
                ? 'bg-secondary-container text-on-secondary-container'
                : 'border border-outline-variant text-on-surface-variant hover:bg-surface-container-high'
            }`}
          >
            {searchByTags && <Check size={14} />}
            <span>Tags</span>
          </button>
        </div>
      </section>

      {/* Empty State / Results Logic */}
      {query.trim().length <= 2 ? (
        <div className="mt-12 flex flex-col items-center justify-center py-16 text-center">
          <div className="w-48 h-48 mb-6 text-primary/10 flex items-center justify-center bg-primary/5 rounded-full select-none">
            <span className="material-symbols-outlined text-[110px]" style={{ fontVariationSettings: "'wght' 200" }}>search_spark</span>
          </div>
          <h2 className="font-sans font-bold text-base text-on-surface-variant">No search performed yet</h2>
          <p className="mt-1 font-sans text-xs text-on-surface-variant/70 max-w-xs leading-relaxed">
            Enter a keyword above to scan your local and cloud markdown repositories.
          </p>
        </div>
      ) : results.length === 0 ? (
        <div className="mt-12 flex flex-col items-center justify-center py-16 text-center">
          <div className="w-48 h-48 mb-6 text-error/10 flex items-center justify-center bg-error/5 rounded-full select-none">
            <span className="material-symbols-outlined text-[100px]" style={{ fontVariationSettings: "'wght' 200" }}>search_off</span>
          </div>
          <h2 className="font-sans font-bold text-base text-on-surface-variant">No results found</h2>
          <p className="mt-1 font-sans text-xs text-on-surface-variant/70 max-w-xs leading-relaxed">
            We couldn't find any file matching <span className="font-bold text-on-surface">"{query}"</span>. Try adjusting your search filters.
          </p>
        </div>
      ) : (
        <div className="mt-6 space-y-4">
          <h3 className="font-serif italic font-black text-sm text-primary mb-2">
            Found {results.length} Matches
          </h3>
          <div className="space-y-3">
            {results.map(file => (
              <motion.div
                whileTap={{ scale: 0.99 }}
                onClick={() => onSelectFile(file.id, 'READER')}
                key={file.id}
                className="p-4 bg-surface-container-low hover:bg-surface-container rounded-2xl border border-surface-container-high hover:border-outline-variant transition-colors cursor-pointer group flex flex-col gap-2"
              >
                <div className="flex justify-between items-start">
                  <div className="flex items-center gap-3">
                    <span className="material-symbols-outlined text-primary text-[20px] select-none">description</span>
                    <h3 className="font-sans font-bold text-sm text-on-surface group-hover:text-primary transition-colors">
                      {file.name}
                    </h3>
                  </div>
                  <span className="text-[10px] font-sans font-medium text-on-surface-variant/60">
                    {file.updatedAt}
                  </span>
                </div>

                <div className="text-xs text-on-surface-variant leading-relaxed">
                  {getHighlightedSnippet(file.content, query)}
                </div>

                {file.tags.length > 0 && (
                  <div className="mt-2 flex flex-wrap gap-1">
                    {file.tags.map(tag => (
                      <span key={tag} className="px-2 py-0.5 bg-surface-variant text-on-surface-variant rounded-md text-[10px] font-semibold font-sans">
                        #{tag}
                      </span>
                    ))}
                  </div>
                )}
              </motion.div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
