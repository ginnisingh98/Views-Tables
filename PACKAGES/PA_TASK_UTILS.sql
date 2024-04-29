--------------------------------------------------------
--  DDL for Package PA_TASK_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TASK_UTILS" AUTHID CURRENT_USER as
-- $Header: PAXTUTLS.pls 120.3.12010000.5 2009/05/19 08:12:00 rthumma ship $

--
--  FUNCTION
--              get_wbs_level
--  PURPOSE
--              This function retrieves the wbs level of a task.
--              If no wbs level is found, null is returned.
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function get_wbs_level (x_task_id  IN number) return number;
pragma RESTRICT_REFERENCES (get_wbs_level, WNDS, WNPS);

--
--  FUNCTION
--              get_top_task_id
--  PURPOSE
--              This function retrieves the top task id of a task.
--              If no top task id is found, null is returned.
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function get_top_task_id (x_task_id  IN number) return number;
pragma RESTRICT_REFERENCES (get_top_task_id, WNDS, WNPS);

--
--  FUNCTION
--              get_parent_task_id
--  PURPOSE
--              This function retrieves the parent task id of a task.
--              If no parent task id is found, null is returned.
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function get_parent_task_id (x_task_id  IN number) return number;
pragma RESTRICT_REFERENCES (get_parent_task_id, WNDS, WNPS);


--
--  FUNCTION
--              check_unique_task_number
--  PURPOSE
--		This function returns 1 if a task number is not already
--              used in PA system for a specific project id and returns 0
-- 		if number is used.
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_unique_task_number (x_project_id  IN number
				   , x_task_number  IN varchar2
				   , x_rowid	  IN varchar2 ) return number;
pragma RESTRICT_REFERENCES (check_unique_task_number, WNDS, WNPS);


--
--  FUNCTION
--              check_last_task
--  PURPOSE
--              This function returns 1 if a task is the last task
--              and returns 0 otherwise.
--              If Oracle error occurs, Oracle error number is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_last_task (x_task_id  IN number ) return number;
pragma RESTRICT_REFERENCES (check_last_task, WNDS, WNPS);

--
--  FUNCTION
--              check_last_child
--  PURPOSE
--              This function returns 1 if a task is the last child of branch
--              and returns 0 otherwise.
--              If Oracle error occurs, Oracle error number is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_last_child (x_task_id  IN number ) return number;
pragma RESTRICT_REFERENCES (check_last_child, WNDS, WNPS);


--
--  FUNCTION
--              check_pct_complete_exists
--  PURPOSE
--              This function returns 1 if percent complete exists for a
--              specific task and returns 0 if no percent complete is found
--              for that task.
--
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_pct_complete_exists (x_task_id  IN number ) return number;
pragma RESTRICT_REFERENCES (check_pct_complete_exists, WNDS, WNPS);


--  FUNCTION
--              check_labor_cost_multiplier
--  PURPOSE
--              This function returns 1 if a task has labor cost multiplier
--              and returns 0 otherwise.
--
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_labor_cost_multiplier
			(x_task_id  IN number ) return number;
pragma RESTRICT_REFERENCES (check_labor_cost_multiplier, WNDS, WNPS);


--
--  PROCEDURE
--              check_create_subtask_ok
--  PURPOSE
--              This procedure checks if a specific task has any transaction
--              control, burden schedule override, budget, billing,
--              and other transaction information.  If task has any of
--              these information, then it's not ok to create subtask for
--              that task.  Specific reason will be returned.
--		If it's ok to create subtask, the x_err_code will be 0.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
procedure check_create_subtask_ok ( x_task_id   IN  number
                                  , x_validation_mode    IN VARCHAR2   DEFAULT 'U'    --bug 2947492
                                  , x_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
                                  , x_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                                  , x_err_stack         IN OUT    NOCOPY varchar2); --File.Sql.39 bug 4440895


--
--  PROCEDURE
--              change_lowest_task_num_ok
--  PURPOSE
--              This procedure checks if a specific task has expenditure items,
--              Po req distributions,po distributions,ap invoices and ap
--              invoice distributions. If task has any of
--              these information, then it's not ok to change the task number
--              and specific reason will be returned.
--		If it's ok to change task number, the x_err_code will be 0.
--
--  HISTORY
--   29-DEC-95      R.Krishnamurthy  Created
--
procedure change_lowest_task_num_ok ( x_task_id           IN  number
                                    , x_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
                                    , x_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                                    , x_err_stack         IN OUT    NOCOPY varchar2); --File.Sql.39 bug 4440895
--
--  PROCEDURE
--              change_task_org_ok
--  PURPOSE
--              This procedure checks if a specific task has CDLs,RDLs or
--              Draft invoices.If task has any of
--              these information, then it's not ok to change the task org
--              and specific reason will be returned.
--		If it's ok to change task org, the x_err_code will be 0.
--
--  HISTORY
--   29-DEC-95      R.Krishnamurthy  Created
--
procedure change_task_org_ok        ( x_task_id           IN  number
                                    , x_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
                                    , x_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                                    , x_err_stack         IN OUT    NOCOPY varchar2); --File.Sql.39 bug 4440895


-- Added the following for the fix of 6316383
--
--  PROCEDURE
--              change_task_org_ok1
--  PURPOSE
--              This procedure checks if a specific task has CDLs,RDLs or
--              Draft invoices.If task has any of  these information,
--              the future dated expenditure items recalculation is handled.
--
--  HISTORY
--   20-12-07   Pallavi Jain   Created
--
procedure change_task_org_ok1        (p_task_id          IN number
                                     ,p_project_id       IN number
				     ,p_new_org_id       IN number
				     ,p_commit           IN varchar2
				     ,x_err_stage       IN OUT NOCOPY varchar2); --File.Sql.39 GSCC Standard

--
--  PROCEDURE
--              change_task_org_ok2
--  PURPOSE
--              This procedure receives a table of task Ids and org Ids along with other,
--              other parameters , then in turn calls Procedure pa_task_utils.change_task_org_ok1
--              for each set of task Id and org Id.
--
--
--  HISTORY
--   26-DEC-07     Pallavi Jain  Created

procedure change_task_org_ok2 (  p_task_id_tbl       IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
                                ,p_project_id        IN  number
				,p_org_id_tbl        IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
                                ,p_commit            IN  varchar2
				,x_err_stage         IN  OUT NOCOPY varchar2); --File.Sql.39 GSCC Standard


--Added for the fix of 7291217
 	 --  FUNCTION
 	 --              get_resource_list_name
 	 --  PURPOSE
 	 --              This function retrieves the resource list name
 	 --              If no resource_list_id found, null is returned.
 	 --              If Oracle error occurs, Oracle error number is returned.
 	 --  HISTORY
 	 --   24-JUL-08     sugupta       Created
 	 --
function get_resource_list_name (p_resource_list_id  IN number) return varchar2;
 	 pragma RESTRICT_REFERENCES (get_resource_list_name, WNDS, WNPS);


--
--  PROCEDURE
--              check_delete_task_ok
--  PURPOSE
--              This objective of this API is to check if it is OK to delete
--              a task.
--
--  HISTORY
--   05-JAN-96      S. Lee      Created
--
procedure check_delete_task_ok (x_task_id             IN        number
                        , x_validation_mode    IN VARCHAR2   DEFAULT 'U'    --bug 2947492
                        , x_err_code            IN OUT    NOCOPY number --File.Sql.39 bug 4440895
                        , x_err_stage           IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                        , x_err_stack           IN OUT    NOCOPY varchar2); --File.Sql.39 bug 4440895


--
--  FUNCTION
--              sort_order_tree_walk
--  PURPOSE
--              This function does a reverse tree walk in the pa_task table
--              to set up a sort order using input parent_task_id and
--              task_number.
--              If Oracle error occurs, Oracle error number is returned.
--
--  HISTORY
--   12-DEC-96      Charles Fong  Created
--
function sort_order_tree_walk(x_parent_id  IN number, x_sort_order_col IN varchar2) return varchar2;
pragma RESTRICT_REFERENCES (sort_order_tree_walk, WNDS, WNPS);

--
--  FUNCTION
--              check_child_exists
--  PURPOSE
--              This function checks whether the task has any child or not and
--              return 1 or 0 accordingly.
--              If Oracle error occurs, Oracle error number is returned.
--
--  HISTORY
--   12-DEC-96      Charles Fong  Created
--
function check_child_exists(x_task_id  IN number) return number;
pragma RESTRICT_REFERENCES (check_child_exists, WNDS, WNPS);


/* Start of Bug 6497559 */

--
--  FUNCTION
--              get_resource_name
--  PURPOSE
--              This functions returns the resource name for a corresponding resource_list_member_id
--
--  HISTORY
--   19-May-2009      rthumma  Created
--

function get_resource_name (x_rlm_id  IN number) return varchar2;
pragma RESTRICT_REFERENCES (get_resource_name, WNDS, WNPS);

--
--  FUNCTION
--              get_task_name
--  PURPOSE
--              This functions returns the task name for a corresponding task_id
--
--  HISTORY
--   19-May-2009      rthumma  Created
--

function get_task_name (x_task_id  IN number) return varchar2;
pragma RESTRICT_REFERENCES (get_task_name, WNDS, WNPS);

--
--  FUNCTION
--              get_task_number
--  PURPOSE
--              This functions returns the task number for a corresponding task_id
--
--  HISTORY
--   19-May-2009      rthumma  Created
--

function get_task_number (x_task_id  IN number) return varchar2;
pragma RESTRICT_REFERENCES (get_task_number, WNDS, WNPS);

--
--  FUNCTION
--              get_project_name
--  PURPOSE
--              This functions returns the project name for a corresponding project_id
--
--  HISTORY
--   19-May-2009      rthumma  Created
--

function get_project_name (x_project_id  IN number) return varchar2;
pragma RESTRICT_REFERENCES (get_project_name, WNDS, WNPS);
--
--  FUNCTION
--              get_project_number
--  PURPOSE
--              This functions returns the project number for a corresponding project_id
--
--  HISTORY
--   19-May-2009      rthumma  Created
--

function get_project_number (x_project_id  IN number) return varchar2;
pragma RESTRICT_REFERENCES (get_project_number, WNDS, WNPS);

/* End of Bug 6497559 */


--rtarway 3908013

PROCEDURE validate_flex_fields(
                  p_desc_flex_name        IN     VARCHAR2
                 ,p_attribute_category    IN     VARCHAR2 := null
                 ,p_attribute1            IN     VARCHAR2 := null
                 ,p_attribute2            IN     VARCHAR2 := null
                 ,p_attribute3            IN     VARCHAR2 := null
                 ,p_attribute4            IN     VARCHAR2 := null
                 ,p_attribute5            IN     VARCHAR2 := null
                 ,p_attribute6            IN     VARCHAR2 := null
                 ,p_attribute7            IN     VARCHAR2 := null
                 ,p_attribute8            IN     VARCHAR2 := null
                 ,p_attribute9            IN     VARCHAR2 := null
                 ,p_attribute10           IN     VARCHAR2 := null
                 ,p_attribute11           IN     VARCHAR2 := null
                 ,p_attribute12           IN     VARCHAR2 := null
                 ,p_attribute13           IN     VARCHAR2 := null
                 ,p_attribute14           IN     VARCHAR2 := null
                 ,p_attribute15           IN     VARCHAR2 := null
                 ,p_RETURN_msg            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                 ,p_validate_status       OUT NOCOPY VARCHAR2)    ;     --File.Sql.39 bug 4440895
--rtarway, 3908013

--
--  PROCEDURE
--              check_set_nonchargeable_ok
--  PURPOSE
--              This procedure checks if a specific task has PO distributions,
--              PO requisition distributions, AP invoice distributions
--              and also if it is referenced in PJM. If the task has any of
--              these information, then it's not ok to make the task nonchargeable
--              and the specific reason will be returned.
--		If it's ok to make the task nonchargeable, the x_err_code will be 0.
--
--  HISTORY
--
--   24-FEB-05      Derrin Joseph  Created for bug 4069938
--
procedure check_set_nonchargeable_ok ( x_task_id           IN  number
                                     , x_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
                                     , x_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                                     , x_err_stack         IN OUT    NOCOPY varchar2); --File.Sql.39 bug 4440895

end PA_TASK_UTILS ;

/
