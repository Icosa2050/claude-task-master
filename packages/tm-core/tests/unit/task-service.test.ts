/**
 * @fileoverview Unit tests for TaskService dotted subtask lookups
 */

import { describe, expect, it } from 'vitest';

import { TaskService } from '../../src/services/task-service';
import type { Task } from '../../src/types/index';
import type { IStorage, StorageStats } from '../../src/interfaces/storage.interface';

class MockConfigManager {
	getActiveTag(): string {
		return 'master';
	}

	// Only included to satisfy the TaskService constructor; not used in these tests
	getStorageConfig() {
		return { type: 'file', basePath: process.cwd() } as const;
	}

	getProjectRoot(): string {
		return process.cwd();
	}
}

class MockStorage implements IStorage {
	constructor(private readonly tasks: Task[]) {}

	async loadTasks(): Promise<Task[]> {
		return this.tasks;
	}

	async loadTask(taskId: string): Promise<Task | null> {
		return this.tasks.find((task) => String(task.id) === taskId) ?? null;
	}

	async saveTasks(): Promise<void> {}
	async appendTasks(): Promise<void> {}
	async updateTask(): Promise<void> {}
	async updateTaskStatus(): Promise<any> {
		return { success: false };
	}
	async deleteTask(): Promise<void> {}
	async exists(): Promise<boolean> {
		return true;
	}
	async loadMetadata(): Promise<any> {
		return null;
	}
	async saveMetadata(): Promise<void> {}
	async getAllTags(): Promise<string[]> {
		return ['master'];
	}
	async deleteTag(): Promise<void> {}
	async renameTag(): Promise<void> {}
	async copyTag(): Promise<void> {}
	async initialize(): Promise<void> {}
	async close(): Promise<void> {}
	async getStats(): Promise<StorageStats> {
		return {
			totalTasks: this.tasks.length,
			totalTags: 1,
			storageSize: 0,
			lastModified: new Date().toISOString(),
			tagStats: []
		};
	}
}

const buildParentTask = (): Task => ({
	id: '518',
	title: 'Implement distribution references',
	description: 'Parent task with subtasks',
	status: 'in-progress',
	priority: 'medium',
	dependencies: ['516'],
	details: '',
	testStrategy: '',
	subtasks: [
		{
			id: 6,
			parentId: '518',
			title: 'Migration and legacy compatibility',
			description: '',
			status: 'done',
			priority: 'medium',
			dependencies: [],
			details: '',
			testStrategy: ''
		},
		{
			id: 7,
			parentId: '518',
			title: 'QA, documentation, and rollout',
			description: '',
			status: 'pending',
			priority: 'high',
			dependencies: ['6', '520'],
			details: '',
			testStrategy: ''
		}
	],
	createdAt: '2024-01-01T00:00:00.000Z',
	updatedAt: '2024-01-02T00:00:00.000Z',
	tags: ['fairshare']
});

describe('TaskService#getTask - dotted subtask IDs', () => {
	const configManager = new MockConfigManager();
	const tasks = [buildParentTask()];
	const storage = new MockStorage(tasks);
	const service = new TaskService(configManager as any);

	Object.assign(service as any, {
		storage,
		initialized: true
	});

	it('returns the parent task when requesting the base ID', async () => {
		const parent = await service.getTask('518');

		expect(parent).not.toBeNull();
		expect(parent?.id).toBe('518');
		expect(parent?.subtasks).toHaveLength(2);
	});

	it('expands dotted subtask identifiers with normalized output', async () => {
		const subtask = (await service.getTask('518.7')) as Task & {
			isSubtask: boolean;
			parentTask: { id: string };
		};

		expect(subtask).toBeTruthy();
		expect(subtask.id).toBe('518.7');
		expect(subtask.isSubtask).toBe(true);
		expect(subtask.parentTask.id).toBe('518');
		expect(subtask.dependencies).toEqual(['518.6', '520']);
		expect(subtask.subtasks).toEqual([]);
		expect(subtask.priority).toBe('high');
	});

	it('returns null for unknown subtask identifiers', async () => {
		const result = await service.getTask('518.99');
		expect(result).toBeNull();
	});
});

