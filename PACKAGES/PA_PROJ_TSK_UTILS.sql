--------------------------------------------------------
--  DDL for Package PA_PROJ_TSK_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJ_TSK_UTILS" AUTHID CURRENT_USER as
-- $Header: PAXPTUTS.pls 120.2 2006/01/04 05:09:14 avaithia noship $

--
--  FUNCTION
--              get_task_project_id
--  PURPOSE
--              This function retrieves the project id of a task.
--              If no project id is found, null is returned.
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function get_task_project_id (x_task_id  IN number) return number;
pragma RESTRICT_REFERENCES (get_task_project_id, WNDS, WNPS);

--  FUNCTION
--	 	check_event_exists
--  PURPOSE
--	        This function returns 1 if event exists for project id or
--              task id and returns 0 if no event is found.
--
--		User can pass either project id or task id.  If both
--		project id and task id are provided, function treated
--		as if only task were passed.  Events exist at project
--		and top tasks level.
--		If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_event_exists (x_project_id  IN number
			   , x_task_id     IN number ) return number;
pragma RESTRICT_REFERENCES (check_event_exists, WNDS, WNPS);


--  FUNCTION
--	 	check_exp_item_exists
--  PURPOSE
--		This function returns 1 if expenditure item exists for
--              a project or a task and returns 0 if no expenditure item
--		is found.
--
--	        User can pass either project id or task id.  If both
--		project id and task id are provided, function treated
--		as if only task were passed.  Expenditure items exist
--		at project and lowest level tasks.
--		If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_exp_item_exists (x_project_id  IN number
	  		      , x_task_id     IN number
			      , x_check_subtasks IN boolean default TRUE)
				return number;
pragma RESTRICT_REFERENCES (check_exp_item_exists, WNDS, WNPS);


--  FUNCTION
--              check_po_dist_exists
--  PURPOSE
--              This function returns 1 if purchase order distribution exists
--              for a project or a task and returns 0 if no purchase order
--              distribution is found.
--
--              User can pass either project id or task id.  If both
--              project id and task id are provided, function treated
--              as if only task were passed.  Purchase order exists
--              at project and lowest level tasks.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_po_dist_exists (x_project_id  IN number
                              , x_task_id     IN number
                              , x_check_subtasks IN boolean default TRUE) -- Added for Performance Fix 4903460
				 return number;
pragma RESTRICT_REFERENCES (check_po_dist_exists, WNDS, WNPS);


--  FUNCTION
--	 	check_po_req_dist_exists
--  PURPOSE
--		This function returns 1 if purchase requisition exists
--		for a project or a task and returns 0 if no purchase
--		requisition is found.
--
--	        User can pass either project id or task id.  If both
--		project id and task id are provided, function treated
--		as if only task were passed.  Purchase requisition exists
--		at project and lowest level tasks.
--		If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_po_req_dist_exists (x_project_id  IN number
	  		      , x_task_id     IN number
                              , x_check_subtasks IN boolean default TRUE)  -- Added for Performance Fix 4903460
				return number;
pragma RESTRICT_REFERENCES (check_po_req_dist_exists, WNDS, WNPS);


--  FUNCTION
--              check_ap_invoice_exists
--  PURPOSE
--              This function returns 1 if supplier invoice exists
--              for a project or a task and returns 0 if no supplier
--              invoice is found.
--
--              User can pass either project id or task id.  If both
--              project id and task id are provided, function treated
--              as if only task were passed.  Supplier invoice exists
--              at project and lowest level tasks.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_ap_invoice_exists (x_project_id  IN number
                              , x_task_id     IN number
                              , x_check_subtasks IN boolean default TRUE ) -- Added for Performance Fix 4903460
				 return number;
pragma RESTRICT_REFERENCES (check_ap_invoice_exists, WNDS, WNPS);


--  FUNCTION
--              check_ap_inv_dist_exists
--  PURPOSE
--              This function returns 1 if supplier invoice distribution
--              exists for a project or a task and returns 0 if no supplier
--              invoice distribution is found.
--
--              User can pass either project id or task id.  If both
--              project id and task id are provided, function treated
--              as if only task were passed.  Supplier invoice distribution
--              exists at lowest level tasks.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_ap_inv_dist_exists (x_project_id  IN number
                              , x_task_id     IN number
                              , x_check_subtasks IN boolean default TRUE ) -- Added for Performance Fix 4903460
				 return number;
pragma RESTRICT_REFERENCES (check_ap_inv_dist_exists, WNDS, WNPS);


--  FUNCTION
--              check_funding_exists
--  PURPOSE
--               This function returns 1 if funding exists for a project
--               or a task and returns 0 if no funding is found.
--
--              User can pass either project id or task id.  If both
--              project id and task id are provided, function treated
--              as if only task were passed.  Funding can exist at project
--              and top task levels.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_funding_exists (x_project_id  IN number
                              , x_task_id     IN number ) return number;
pragma RESTRICT_REFERENCES (check_funding_exists, WNDS, WNPS);


--  FUNCTION
--              check_cdl_exists
--  PURPOSE
--              This function returns 1 if cost distribution lines exists
--              for a specified project or task and returns 0 if no
--              cost distribution line is found.
--
--              User can pass either project id or task id.  If both
--              project id and task id are provided, function treated
--              as if only task were passed.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_cdl_exists (x_project_id  IN number
                         , x_task_id  IN number ) return number;
pragma RESTRICT_REFERENCES (check_cdl_exists, WNDS, WNPS);


--  FUNCTION
--              check_rdl_exists
--  PURPOSE
--              This function returns 1 if revenue distribution lines exists
--              for a specified project or task and returns 0 if no
--              revenue distribution line is found.
--
--              User can pass either project id or task id.  If both
--              project id and task id are provided, function treated
--              as if only task were passed.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_rdl_exists (x_project_id  IN number
                         , x_task_id  IN number ) return number;
pragma RESTRICT_REFERENCES (check_rdl_exists, WNDS, WNPS);


--  FUNCTION
--              check_erdl_exists
--  PURPOSE
--              This function returns 1 if event revenue distribution
--              lines exists for a specified project or task and returns 0
--              if no event revenue distribution line is found for project
--              or task.
--
--              User can pass either project id or task id.  If both
--              project id and task id are provided, function treated
--              as if only task were passed.  User can also pass in a
--              specific event number.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_erdl_exists (x_project_id  IN number
                         , x_task_id  IN number
			 , x_event_num IN number ) return number;
pragma RESTRICT_REFERENCES (check_erdl_exists, WNDS, WNPS);


--  FUNCTION
--              check_draft_inv_item_exists
--  PURPOSE
--              This function returns 1 if draft invoice item exists
--              for a project or a task and returns 0 if no draft
--              invoice item is found for that project or task.
--
--              User can pass either project id or task id.  If both
--              project id and task id are provided, function treated
--              as if only task were passed.  Draft invoice item can exist
--              at project or lowest level tasks.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_draft_inv_item_exists (x_project_id  IN number
                              , x_task_id     IN number
                              , x_check_subtasks IN boolean default TRUE ) -- Added for Performance Fix 4903460
				 return number;
pragma RESTRICT_REFERENCES (check_draft_inv_item_exists, WNDS, WNPS);


--  FUNCTION
--              check_draft_rev_item_exists
--  PURPOSE
--              This function returns 1 if draft revenue item exists
--              for a project or a task and returns 0 if no draft
--              revenue item is found for that project or task.
--
--              User can pass either project id or task id.  If both
--              project id and task id are provided, function treated
--              as if only task were passed.  Draft revenue item can exist
--              at project or lowest level tasks.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_draft_rev_item_exists (x_project_id  IN number
                              , x_task_id     IN number
                              , x_check_subtasks IN boolean default TRUE ) -- Added for Performance Fix 4903460
				 return number;
pragma RESTRICT_REFERENCES (check_draft_rev_item_exists, WNDS, WNPS);

--  FUNCTION
--              check_draft_inv_details_exists
--  PURPOSE
--              This function returns 1 if draft invoice details exists
--              for a task and returns 0 if no draft
--              invoice details is found for that task.
--
--              User can pass task id. Draft invoice details can exist
--              at lowest level tasks. If Oracle error occured,
--              Oracle error code is returned.
--
--  HISTORY
--   28-JUL-99      sbalasub       Created
--
function check_draft_inv_details_exists (x_task_id     IN number
                              , x_check_subtasks IN boolean default TRUE ) -- Added for Performance Fix 4903460
				 return number;
pragma RESTRICT_REFERENCES (check_draft_inv_details_exists, WNDS, WNPS);

--  FUNCTION
--              check_project_customer_exists
--  PURPOSE
--              This function returns 1 if project_customer_exists
--              for a task and returns 0 if no project_customer_exists
--              is found for that task.
--
--              User can pass task id. project_customer_exists can exist
--              at lowest level tasks. If Oracle error occured,
--              Oracle error code is returned.
--
--  HISTORY
--   28-JUL-99      sbalasub       Created
--
function check_project_customer_exists (x_task_id     IN number
                              , x_check_subtasks IN boolean default TRUE ) -- Added for Performance Fix 4903460
				 return number;
pragma RESTRICT_REFERENCES (check_project_customer_exists, WNDS, WNPS);

--  FUNCTION
--              check_projects_exists
--  PURPOSE
--              This function returns 1 if projects_exists
--              for a task and returns 0 if no projects_exists
--              is found for that task.
--
--              User can pass task id. projects_exists can exist
--              at lowest level tasks. If Oracle error occured,
--              Oracle error code is returned.
--
--  HISTORY
--   28-JUL-99      sbalasub       Created
--
function check_projects_exists (x_task_id     IN number
                              , x_check_subtasks IN boolean default TRUE -- Added for Performance Fix 4903460
				) return number;
pragma RESTRICT_REFERENCES (check_projects_exists, WNDS, WNPS);

--  FUNCTION
--              check_commitment_txn_exists
--  PURPOSE
--              This function returns 1 if commitment transaction exists
--              for a project or a task and returns 0 if no commitment
--              transaction is found for that project or task.
--
--              User can pass either project id or task id.  If both
--              project id and task id are provided, function treated
--              as if only task were passed.  commitment transaction can
--              exist at project or lowest level tasks.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_commitment_txn_exists (x_project_id  IN number
                              , x_task_id     IN number
			      , x_check_subtasks IN boolean default TRUE  -- Added for Performance Fix 4903460
				     ) return number;
pragma RESTRICT_REFERENCES (check_commitment_txn_exists, WNDS, WNPS);


--  FUNCTION
--              check_comp_rule_set_exists
--  PURPOSE
--              This function returns 1 if compensation rule set exists
--              for a project or a task and returns 0 if no compensation
--              rule set is found for that project or task.
--
--              User can pass either project id or task id.  If both
--              project id and task id are provided, function treated
--              as if only task were passed.  Compensation rule set can
--              exist at project or lowest level tasks.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_comp_rule_set_exists (x_project_id  IN number
                                   , x_task_id     IN number
				   , x_check_subtasks IN boolean default TRUE -- Added for Performance Fix 4903460
				     ) return number;
pragma RESTRICT_REFERENCES (check_comp_rule_set_exists, WNDS, WNPS);


--  FUNCTION
--              check_asset_assignmt_exists
--  PURPOSE
--              This function returns 1 if asset assignment exists
--              for a specific project or task and returns 0 if no asset
--              assignment is found for that project or task.
--
--              User can pass either project id or task id.  If both
--              project id and task id are provided, function treated
--              as if only task were passed.  Asset assignment can
--              exist at project or lowest level tasks.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_asset_assignmt_exists (x_project_id  IN number
                                   , x_task_id     IN number
                                   , x_check_subtasks IN boolean default TRUE -- Added for Performance Fix 4903460
			  	     ) return number;
pragma RESTRICT_REFERENCES (check_asset_assignmt_exists, WNDS, WNPS);


--  FUNCTION
--              check_job_bill_rate_override
--  PURPOSE
--              This function returns 1 if job bill rate override exists
--              for a specific project or task and returns 0 if no
--              job bill rate override is found for that project or task.
--
--              User can pass either project id or task id.  If both
--              project id and task id are provided, function treated
--              as if only task were passed.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_job_bill_rate_override (x_project_id  IN number
                                   , x_task_id     IN number ) return number;
pragma RESTRICT_REFERENCES (check_job_bill_rate_override, WNDS, WNPS);


--  FUNCTION
--              check_burden_sched_override
--  PURPOSE
--              This function returns 1 if burden schedule override exists
--              for a specific project or task and returns 0 if no
--              burden schedule override is found for that project or task.
--
--              User can pass either project id or task id.  If both
--              project id and task id are provided, function treated
--              as if only task were passed.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_burden_sched_override (x_project_id  IN number
                                   , x_task_id     IN number ) return number;
pragma RESTRICT_REFERENCES (check_burden_sched_override, WNDS);  -- Bug 4363092: Removed WNPS restriction


--  FUNCTION
--              check_emp_bill_rate_override
--  PURPOSE
--              This function returns 1 if emp bill rate override exists
--              for a specific project or task and returns 0 if no
--              emp bill rate override is found for that project or task.
--
--              User can pass either project id or task id.  If both
--              project id and task id are provided, function treated
--              as if only task were passed.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_emp_bill_rate_override (x_project_id  IN number
                                   , x_task_id     IN number ) return number;
pragma RESTRICT_REFERENCES (check_emp_bill_rate_override, WNDS, WNPS);


--  FUNCTION
--              check_labor_multiplier
--  PURPOSE
--              This function returns 1 if labor multiplier exists
--              for a specific project or task and returns 0 if no
--              labor multiplier is found for that project or task.
--
--              User can pass either project id or task id.  If both
--              project id and task id are provided, function treated
--              as if only task were passed.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_labor_multiplier (x_project_id  IN number
                                   , x_task_id     IN number ) return number;
pragma RESTRICT_REFERENCES (check_labor_multiplier, WNDS, WNPS);

--  FUNCTION
--              check_transaction_control
--  PURPOSE
--              This function returns 1 if transaction control exists
--              for a specific project or task and returns 0 if no
--              transaction control is found for that project or task.
--
--              User can pass either project id or task id.  If both
--              project id and task id are provided, function treated
--              as if only task were passed.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_transaction_control (x_project_id  IN number
                                   , x_task_id     IN number ) return number;
pragma RESTRICT_REFERENCES (check_transaction_control, WNDS, WNPS);


--  FUNCTION
--              check_nl_bill_rate_override
--  PURPOSE
--              This function returns 1 if non-labor bill rate override
--              exists for a specific project or task and returns 0 if no
--              non-labor bill rate override is found for that project or task.
--
--              User can pass either project id or task id.  If both
--              project id and task id are provided, function treated
--              as if only task were passed.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_nl_bill_rate_override (x_project_id  IN number
                                   , x_task_id     IN number ) return number;
pragma RESTRICT_REFERENCES (check_nl_bill_rate_override, WNDS, WNPS);

--  FUNCTION
--              check_job_bill_title_override
--  PURPOSE
--              This function returns 1 if job bill title override
--              exists for a specific project or task and returns 0 if no
--              job bill title override is found for that project or task.
--
--              User can pass either project id or task id.  If both
--              project id and task id are provided, function treated
--              as if only task were passed.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_job_bill_title_override (x_project_id  IN number
                                   , x_task_id     IN number ) return number;
pragma RESTRICT_REFERENCES (check_job_bill_title_override, WNDS, WNPS);


--  FUNCTION
--              check_job_assignmt_override
--  PURPOSE
--              This function returns 1 if job assignment override
--              exists for a specific project or task and returns 0 if no
--              job assignment override is found for that project or task.
--
--              User can pass either project id or task id.  If both
--              project id and task id are provided, function treated
--              as if only task were passed.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_job_assignmt_override (x_project_id  IN number
                                   , x_task_id     IN number ) return number;
pragma RESTRICT_REFERENCES (check_job_assignmt_override, WNDS, WNPS);

--  FUNCTION
--              check_iex_task_charged
--  PURPOSE
--              This function returns 1 if the task is charged in iexpense
--              and returns 0 if no expense is charged against the task in iexpense.
--
--              User can pass the task id.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   29-MAY-2002      GJAIN       Created
--
function check_iex_task_charged(x_task_id     IN number ) return number;

pragma RESTRICT_REFERENCES (check_iex_task_charged, WNDS, WNPS);

end PA_PROJ_TSK_UTILS ;
 

/
