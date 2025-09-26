#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"

cat <<'JSCONTENT' > "${repo_root}/mcp-server/src/tools/index.js"
/**
 * tools/index.js
 * Export all Task Master CLI tools for MCP server
 * MODIFIED: Disabled unused tools to reduce context from 39K to ~15K tokens
 */

// ESSENTIAL TOOLS - Always needed
import { registerListTasksTool } from './get-tasks.js';
import logger from '../logger.js';
import { registerSetTaskStatusTool } from './set-task-status.js';
import { registerShowTaskTool } from './get-task.js';
import { registerNextTaskTool } from './next-task.js';
import { registerExpandTaskTool } from './expand-task.js';
import { registerAddTaskTool } from './add-task.js';
import { registerAddSubtaskTool } from './add-subtask.js';
import { registerAddDependencyTool } from './add-dependency.js';
import { registerInitializeProjectTool } from './initialize-project.js';
import { registerModelsTool } from './models.js';

// OCCASIONALLY USED
import { registerExpandAllTool } from './expand-all.js';
import { registerListTagsTool } from './list-tags.js';
import { registerAddTagTool } from './add-tag.js';

// DISABLED - Not used in fairshare project (saves ~24K tokens)
// import { registerParsePRDTool } from './parse-prd.js';
// import { registerUpdateTool } from './update.js';
// import { registerUpdateTaskTool } from './update-task.js';
// import { registerUpdateSubtaskTool } from './update-subtask.js';
// import { registerGenerateTool } from './generate.js';
// import { registerRemoveSubtaskTool } from './remove-subtask.js';
// import { registerAnalyzeProjectComplexityTool } from './analyze.js';
// import { registerClearSubtasksTool } from './clear-subtasks.js';
// import { registerRemoveDependencyTool } from './remove-dependency.js';
// import { registerValidateDependenciesTool } from './validate-dependencies.js';
// import { registerFixDependenciesTool } from './fix-dependencies.js';
// import { registerComplexityReportTool } from './complexity-report.js';
// import { registerRemoveTaskTool } from './remove-task.js';
// import { registerMoveTaskTool } from './move-task.js';
// import { registerResponseLanguageTool } from './response-language.js';
// import { registerDeleteTagTool } from './delete-tag.js';
// import { registerUseTagTool } from './use-tag.js';
// import { registerRenameTagTool } from './rename-tag.js';
// import { registerCopyTagTool } from './copy-tag.js';
// import { registerResearchTool } from './research.js';
// import { registerRulesTool } from './rules.js';
// import { registerScopeUpTool } from './scope-up.js';
// import { registerScopeDownTool } from './scope-down.js';

/**
 * Register all Task Master tools with the MCP server
 * @param {Object} server - FastMCP server instance
 */
export function registerTaskMasterTools(server) {
	try {
		// MINIMAL TOOL SET - Only essentials for fairshare project
		// Reduced from 40 tools to 13 tools (saves ~24K tokens)

		// Group 1: Core Initialization
		registerInitializeProjectTool(server);
		registerModelsTool(server);

		// Group 2: Task Viewing & Navigation
		registerListTasksTool(server);
		registerShowTaskTool(server);
		registerNextTaskTool(server);

		// Group 3: Task Management
		registerSetTaskStatusTool(server);
		registerAddTaskTool(server);
		registerAddSubtaskTool(server);
		registerExpandTaskTool(server);
		registerExpandAllTool(server);

		// Group 4: Dependencies
		registerAddDependencyTool(server);

		// Group 5: Tag Management (minimal)
		registerListTagsTool(server);
		registerAddTagTool(server);

		// DISABLED TOOLS - Commented out to reduce context
		// Group: Setup & Config
		// registerRulesTool(server);
		// registerParsePRDTool(server);
		// registerResponseLanguageTool(server);

		// Group: Analysis & Reports
		// registerAnalyzeProjectComplexityTool(server);
		// registerComplexityReportTool(server);
		// registerScopeUpTool(server);
		// registerScopeDownTool(server);

		// Group: Task Modification
		// registerUpdateTool(server);
		// registerUpdateTaskTool(server);
		// registerUpdateSubtaskTool(server);
		// registerGenerateTool(server);

		// Group: Task Removal
		// registerRemoveTaskTool(server);
		// registerRemoveSubtaskTool(server);
		// registerClearSubtasksTool(server);
		// registerMoveTaskTool(server);

		// Group: Dependency Management (advanced)
		// registerRemoveDependencyTool(server);
		// registerValidateDependenciesTool(server);
		// registerFixDependenciesTool(server);

		// Group: Tag Management (advanced)
		// registerDeleteTagTool(server);
		// registerUseTagTool(server);
		// registerRenameTagTool(server);
		// registerCopyTagTool(server);

		// Group: Research
		// registerResearchTool(server);
	} catch (error) {
		logger.error(`Error registering Task Master tools: ${error.message}`);
		throw error;
	}
}

export default {
	registerTaskMasterTools
};
JSCONTENT

if ! git -C "${repo_root}" diff --quiet -- mcp-server/src/tools/index.js; then
  printf 'Updated minimal tools in mcp-server/src/tools/index.js\n'
else
  printf 'Minimal tools already applied; no changes made.\n'
fi
