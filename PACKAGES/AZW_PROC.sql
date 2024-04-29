--------------------------------------------------------
--  DDL for Package AZW_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AZW_PROC" AUTHID CURRENT_USER AS
/* $Header: AZWPROCS.pls 115.12 99/08/13 11:20:03 porting shi $ */

  TYPE context_rec_t IS RECORD (
    context_id        az_processes.context_id%TYPE,
    context_name      az_processes.context_name%TYPE);

  TYPE context_tbl_t IS TABLE OF context_rec_t INDEX BY BINARY_INTEGER;

--
-- Name:        get_application_name
-- Description: given an application id, find the corresponding application
--              name.  Called by AZW_HIER and AZW_GROUP package.
-- Parameters:  none
--
  FUNCTION get_application_name(appl_id NUMBER) RETURN VARCHAR2;


--
-- Name:        get_context
-- Description: given a context type, return all context instances belonging
--              to that type.  Called by AZW_PROC and AZW_HIER package.
-- Parameters:
--	ctx_type: context type of BG, SOB, OU, or IO.
--
  PROCEDURE get_context(ctx_type IN VARCHAR2, ctx_table OUT context_tbl_t);

--
-- Name:        get_lookup_meaning
-- Description: given a lookup code, find the corresponding meaning.
--              Called by AZW_HIER and AZW_GROUP package.
-- Parameters:  none
--
  FUNCTION get_lookup_meaning(code VARCHAR2) RETURN VARCHAR2;

--
-- Name:	parse_application_ids
-- Description: parses a string of app ids, returning one appl_id at a time.
--              Called by AZW_FLOW and AZW_REPORT package.
-- Parameters:
--	p_application_ids - string of application ids delimited by commas
--	id_cnt
--
  FUNCTION parse_application_ids(p_application_ids IN VARCHAR2,
                                 id_cnt IN NUMBER) RETURN NUMBER;
--
-- Name:        az_start_task
-- Description: starts a new task and passes its display string.
--              Called by AZWIZARD.fmb.
-- Parameters:
--     	item_type    -  first part of the process identification
--     	process_name -  second part of the process identification
--    	context_id   -  third/last part of the process identification
--     	role         -  role assigned to the task
--
  FUNCTION az_start_task(node_id IN VARCHAR2, role IN VARCHAR2) RETURN VARCHAR2;

--
-- Name:        populate_az_processes
-- Description: updates AZ_PROCESSES table
--              Called by AZW_HIER package.
-- Parameters:
-- 	None
--
  PROCEDURE populate_az_processes;

--
-- Name:        az_reassign_task
-- Description: reassigns a task and returns the new label.
--              Called by AZWIZARD.fmb.
-- Parameters:
--    	node_id - concatenated task identifier: item_type, process_name
--                context_id, item_key
--
  FUNCTION az_reassign_task(node_id IN VARCHAR2, p_role IN VARCHAR2)
           RETURN VARCHAR2;

--
-- Name:        az_abort_task
-- Description: aborts a task and returns its label.
--              Called by AZWIZARD.fmb.
-- Parameters:
--    	node_id - concatenated task identifier: item_type, process_name
--                context_id, item_key
--
  FUNCTION az_abort_task(node_id IN VARCHAR2) RETURN VARCHAR2;

--
-- Name:	update_process_comments
-- Description: updates comments for a given process.
--              Called by AZWIZARD.fmb.
-- Parameters:
-- 	item_type    - 	first part of the process identification
--      process_name - 	second part of the process identification
--      context_id   - 	third/last part of the process identification
--      value        -  the new value to be updated
--
  PROCEDURE update_process_comments(node_id IN VARCHAR2, value IN VARCHAR2);

--
-- Name:	update_process_status
-- Description: updates status information for a given process.
--              Called by AZWIZARD.fmb.
-- Parameters:
-- 	item_type    - 	first part of the process identification
--      process_name - 	second part of the process identification
--      context_id   - 	third/last part of the process identification
--      value        -  the new value to be updated
--
  PROCEDURE update_process_status(node_id IN VARCHAR2, value IN VARCHAR2);

--
-- Name:        get_group_color
-- Description: gets color for a task.
--              Called by AZWIZARD.fmb.
-- Parameters:
--     	node_id - concatenated task identifier: item_type, process_name
--                context_id, item_key
--
  FUNCTION get_group_color(node_id IN VARCHAR2) RETURN VARCHAR2;

--
-- Name: 	parse_item_type
-- Description: returns item_type for a task/process.
--              Called by AZWIZARD.fmb.
-- Parameters:
--	task node id
--
  FUNCTION parse_item_type(node_id IN VARCHAR2) RETURN VARCHAR2;

--
-- Name: 	parse_item_key
-- Description: returns item_key for a task.
--              Called by AZWIZARD.fmb.
-- Parameters:
--	task node id
--
  FUNCTION parse_item_key(node_id IN VARCHAR2) RETURN VARCHAR2;

--
-- Name: 	parse_process_name
-- Description: returns process_name for a process.
--              Called by AZWIZARD.fmb.
-- Parameters:
--     node_id - Node id for a process (Item_Type.Process_Name.Ctxt_Id)
--
  FUNCTION parse_process_name(node_id IN VARCHAR2) RETURN VARCHAR2;

--
-- Name: 	parse_process_name_task
-- Description: returns process name for a task.
--              Called by AZWIZARD.fmb.
-- Parameters:
--     node_id - Node id for task: Item_Type.Process_Name.Ctxt_I.item_key
--
  FUNCTION parse_process_name_task(node_id IN VARCHAR2) RETURN VARCHAR2;

--
-- Name: 	parse_context_id
-- Description: returns context id.
--              Called by AZWIZARD.fmb.
-- Parameters:
--	node id for process
--
  FUNCTION parse_context_id(node_id IN VARCHAR2) RETURN VARCHAR2;

--
-- Name: 	parse_ctxt_id_task
-- Description: returns context id.
--              Called by AZWIZARD.fmb.
-- Parameters:
--	node id for task
--
  FUNCTION parse_ctxt_id_task(node_id IN VARCHAR2) RETURN NUMBER;

--
-- Name:	get_task_label
-- Description:	given a task node id for a task return it's display label.
--              Called by AZWIZARD.fmb.
-- Parameters:
--	node id for task
--
  FUNCTION get_task_label(node_id IN VARCHAR2) RETURN VARCHAR2;

--
-- Name: 	get_task_status
-- Description:	given a task node id for a task return it's status.
--              Called by AZWIZARD.fmb.
-- Parameters:
--	node id for task
--
  FUNCTION get_task_status(node_id IN VARCHAR2) RETURN VARCHAR2;

--
-- Name:        abort_running_tasks
-- Description: abort all tasks without an end_date.
--              Called by azwpdt.sql during upgrade from 11.0 to 11.5.
-- Parameters:
--      none
--
  PROCEDURE abort_running_tasks;

--
-- Name:        populate_process_status
-- Description: insert value of 'A', 'C', or 'N' into the status_code column
--              of AZ_PROCESSES
--              Called by azwpdt.sql during upgrade from 11.0 to 11.5.
-- Parameters:
--      none
--
  PROCEDURE populate_process_status;

--
--
-- Name:        process_has_active_tasks
-- Description:
--              This function checks if the specified process has any
-- 		active tasks.
--              Called by AZWIZARD.fmb when a process is marked complete.
-- Parameters:
--    	node_id - concatenated task identifier: item_type, process_name
--                context_id, item_key
  FUNCTION process_has_active_tasks(node_id IN VARCHAR2) RETURN BOOLEAN;

END AZW_PROC;

 

/
