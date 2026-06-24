import { Folder, MarkdownFile } from './types';

export const INITIAL_FOLDERS: Folder[] = [
  {
    id: 'documents',
    name: 'Documents',
    parentId: null,
    updatedAt: 'Updated 1d ago'
  },
  {
    id: 'study',
    name: 'Study',
    parentId: 'documents',
    updatedAt: 'Updated 3h ago'
  },
  {
    id: 'algorithms',
    name: 'Algorithms',
    parentId: 'study',
    updatedAt: 'Updated 2h ago'
  },
  {
    id: 'biology',
    name: 'Biology Research',
    parentId: 'study',
    updatedAt: 'Updated Yesterday'
  },
  {
    id: 'thesis_plan',
    name: 'Thesis Plan',
    parentId: 'documents',
    updatedAt: 'Updated 3d ago'
  },
  {
    id: 'archive_2023',
    name: 'Archive 2023',
    parentId: null,
    updatedAt: 'Updated 1mo ago'
  }
];

export const INITIAL_FILES: MarkdownFile[] = [
  {
    id: 'project_roadmap',
    name: 'Project_Roadmap.md',
    folderId: null,
    tags: ['Work'],
    isFavorite: false,
    updatedAt: '2h ago',
    size: '1.2kb',
    content: `# Project Roadmap: Q4 Infrastructure Upgrade

## Overview
The primary objective of this quarter is to **transition our legacy data pipelines** into a more *resilient and scalable* event-driven architecture. We aim to achieve 99.9% uptime while reducing latency for end-user markdown synchronization.

### Key Deliverables
- [x] Initialize Kafka clusters for production
- [ ] Migrate user metadata to PostgreSQL 15
- [ ] Implement end-to-end encryption for sync

### Example Configuration
\`\`\`javascript
const syncEngine = new FlowWorker({
  interval: 5000,
  strategy: 'incremental',
  hooks: {
    onComplete: (data) => {
      console.log(\`Synced \${data.count} blocks\`);
    }
  }
});
\`\`\`

### Technical Considerations
While the migration is underway, we must ensure that the *MarkFlow mobile application* maintains full offline support. All edits made locally will be queued and resolved using the **Last Write Wins (LWW)** conflict resolution policy.

> "The best productivity tool is the one that disappears and lets the user work." — MarkFlow Design Philosophy`
  },
  {
    id: 'project_alpha',
    name: 'Project_Alpha.md',
    folderId: null,
    tags: ['Work', 'Strategy'],
    isFavorite: false,
    updatedAt: 'Just now',
    size: '0.8kb',
    content: `# Quarterly Strategic Overview

## Core Objectives
We aim to deliver the most robust **Markdown File Management** experience available.

- [x] Integrate MD3 Design Tokens
- [ ] Optimize for high-end UI patterns
- [ ] Implement local-first persistence

### Key Metrics
| Milestone | Status | Owner |
| :--- | :--- | :--- |
| API Layer | 90% | @dev_team |
| Auth Flow | 100% | @security |

For more details, check [Internal Docs](https://markflow.io/docs).`
  },
  {
    id: 'deep_learning_notes',
    name: 'Deep_Learning_Notes.md',
    folderId: null,
    tags: ['Study'],
    isFavorite: false,
    updatedAt: '5h ago',
    size: '0.4kb',
    content: `# Deep Learning Notes

Neural networks are computing systems inspired by biological neurons.

## Core Concepts
1. **Perceptrons**: Basic unit of neural networks.
2. **Backpropagation**: Gradient descent algorithm used for fine-tuning weights.
3. **Activation Functions**: Relu, Sigmoid, and Tanh introduced to model non-linear boundaries.

### Study Roadmap
- [x] Understand gradient descent descent algorithms
- [ ] Implement multi-layer perceptron from scratch
- [ ] Study convolutional neural networks`
  },
  {
    id: 'weekly_grocery',
    name: 'Weekly_Grocery.md',
    folderId: null,
    tags: ['Personal'],
    isFavorite: false,
    updatedAt: 'Yesterday',
    size: '0.2kb',
    content: `# Weekly Grocery List

Here are the items required for this week's meal plan:
- [ ] Almond Milk (unsweetened)
- [ ] Organic Spinach
- [ ] Quinoa
- [ ] Salmon fillets`
  },
  {
    id: 'exam_prep_2024',
    name: 'Exam_Prep_2024.md',
    folderId: 'study',
    tags: ['Urgent', 'Finals'],
    isFavorite: false,
    updatedAt: 'Updated 2h ago',
    size: '1.5kb',
    content: `# Exam Prep 2024: Study Guide

This document lists the critical concepts required for the upcoming Computer Science final exams.

## Priority Topics
- [x] Time Complexity & Big O notations
- [ ] Hash Table collisions & resolutions
- [ ] Red-Black Trees insertions and balancing

### Milestones
| Milestone | Status | Weight |
| :--- | :--- | :--- |
| Mock Quiz | 100% | 15% |
| Midterm Exam | 92% | 35% |
| Final Project | 88% | 20% |`
  },
  {
    id: 'data_structures',
    name: 'Data_Structures.md',
    folderId: 'study',
    tags: ['CS101'],
    isFavorite: false,
    updatedAt: 'Updated Yesterday',
    size: '0.9kb',
    content: `# Data Structures CS101 Notes

Review of essential structures for data organization and retrieval.

## Linear Structures
- **Arrays**: Fixed size, contiguous memory, index-based access in O(1).
- **Linked Lists**: Node-based dynamic sizing, insertions in O(1).

## Non-Linear Structures
- **Binary Trees**: Hierarchical layout with left and right children.
- **Graphs**: Node vertices joined by edges. Common representations include adjacency list and matrix.`
  },
  {
    id: 'weekly_reflection',
    name: 'Weekly_Reflection.md',
    folderId: 'study',
    tags: [],
    isFavorite: false,
    updatedAt: 'May 12',
    size: '42kb',
    content: `# Weekly Reflection: May 12

A regular review of learning outcomes and habits.

## Summary of Accomplishments
- Implemented deep search index on local content repositories.
- Documented key API requirements for MD3 Design system.

## Areas for Improvement
- Improve task estimation accuracy.
- Dedicate fixed blocks for distraction-free deep focus.`
  },
  {
    id: 'history_thesis_outline',
    name: 'History_Thesis_Outline.md',
    folderId: 'study',
    tags: ['Draft'],
    isFavorite: false,
    updatedAt: 'Updated 1w ago',
    size: '0.6kb',
    content: `# History Thesis Outline

**Title**: The Socio-Economic Catalyst of Modern Print Media

## Abstract
This thesis explores the structural changes in public communication channels throughout the mid-19th century and their consequences on political mobilization.`
  },
  {
    id: 'api_docs',
    name: 'API_Docs.md',
    folderId: null,
    tags: ['Technical'],
    isFavorite: true,
    updatedAt: 'Oct 5',
    size: '2.5kb',
    content: `# API Specs: V2 Reference

This document provides specifications for the MarkFlow synchronization API.

## Endpoints
### GET /api/v2/sync
Retrieve active markdown files updated since a given timestamp.

**Parameters**:
- \`since\`: ISO-8601 Timestamp

**Response**:
\`\`\`json
{
  "status": "success",
  "files": []
}
\`\`\``
  },
  {
    id: 'travel_log',
    name: 'Travel_Log.md',
    folderId: null,
    tags: ['Personal'],
    isFavorite: true,
    updatedAt: '2d ago',
    size: '1.1kb',
    content: `# Travel Log: Tokyo & Kyoto

Detailed itinerary and reflection on cultural landmarks.

## Places Visited
- [x] Shinjuku Gyoen National Garden
- [x] Fushimi Inari Shrine (Kyoto)
- [ ] Arashiyama Bamboo Grove`
  },
  {
    id: 'python_data_science_notes',
    name: 'Python_Data_Science_Notes.md',
    folderId: 'study',
    tags: ['Study', 'Python'],
    isFavorite: false,
    updatedAt: '3h ago',
    size: '1.8kb',
    content: `# Python Data Science Notes

A focused notebook for data analysis tools and machine learning workflows.

## Study Focus Tasks
- [x] NumPy array indexing and manipulation
- [x] Pandas DataFrame group-by operations
- [x] Matplotlib and Seaborn visualization styling
- [ ] Scikit-Learn pipeline configurations`
  }
];
