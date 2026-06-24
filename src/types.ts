export interface Folder {
  id: string;
  name: string;
  parentId: string | null;
  updatedAt: string;
}

export interface MarkdownFile {
  id: string;
  name: string;
  content: string;
  folderId: string | null;
  tags: string[];
  isFavorite: boolean;
  updatedAt: string;
  size: string;
}

export type ActiveView = 
  | 'DASHBOARD'
  | 'FILES'
  | 'SEARCH'
  | 'FAVORITES'
  | 'SETTINGS'
  | 'READER'
  | 'EDITOR';
