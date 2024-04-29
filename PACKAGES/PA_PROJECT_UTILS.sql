--------------------------------------------------------
--  DDL for Package PA_PROJECT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_UTILS" AUTHID CURRENT_USER as
-- $Header: PAXPUTLS.pls 120.3 2007/02/06 10:20:08 dthakker ship $

/* Added for bug 2125791*/

   glob_total_rec number := 0;
   glob_project_status_code        PA_PLSQL_DATATYPES.Char30TabTyp;
   glob_proj_sys_status_code       PA_PLSQL_DATATYPES.Char30TabTyp;
   glob_action_code                PA_PLSQL_DATATYPES.Char30TabTyp;
   glob_enabled_flag               PA_PLSQL_DATATYPES.Char1TabTyp;
   null_pointer                    PA_PLSQL_DATATYPES.Char30TabTyp;
   null_pointer1                   PA_PLSQL_DATATYPES.Char1TabTyp;

/* End for bug 2125791*/

--
--  PROCEDURE
--              get_project_status_code
--  PURPOSE
--              This procedure retrieves project status code for a specified
--              project status.
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
procedure get_project_status_code ( x_project_status  	  IN varchar2
				  , x_project_status_code OUT NOCOPY varchar2 --File.Sql.39 bug 4440895
				  , x_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
				  , x_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
				  , x_err_stack         IN OUT    NOCOPY varchar2); --File.Sql.39 bug 4440895

--
--  PROCEDURE
--              get_distribution_rule_code
--  PURPOSE
--		This procedure retrieves distribution rule name given the
--              user-friendly name that describes the distribution rule.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
procedure get_distribution_rule_code ( x_dist_name  	  IN varchar2
				  , x_dist_code 	OUT NOCOPY varchar2 --File.Sql.39 bug 4440895
				  , x_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
				  , x_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
				  , x_err_stack         IN OUT    NOCOPY varchar2); --File.Sql.39 bug 4440895

--
--  PROCEDURE
--              get_proj_type_class_code
--  PURPOSE
--              This procedure retrieves project type class code for
--              a given project type or project id.  If both project type
--		and project id are passed, then procedure treated it as if
--		only project id were passed.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
procedure get_proj_type_class_code ( x_project_type     IN varchar2
				  , x_project_id	IN	number
				  , x_proj_type_class_code OUT NOCOPY varchar2 --File.Sql.39 bug 4440895
				  , x_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
				  , x_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
				  , x_err_stack         IN OUT    NOCOPY varchar2); --File.Sql.39 bug 4440895

--
--  FUNCTION
--              check_unique_project_name
--  PURPOSE
--		This function returns 1 if a project name is not already
--              used in PA system and returns 0 if name is used.
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_unique_project_name (x_project_name  IN varchar2,
				    x_rowid	  IN varchar2 ) return number;
pragma RESTRICT_REFERENCES (check_unique_project_name, WNDS, WNPS);


--
--  FUNCTION
--              check_unique_long_name
--  PURPOSE
--              This function returns 1 if a long name is not already
--              used in PA system and returns 0 if name is used.
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   26-OCT-02      MUMOHAN       Created
--
function check_unique_long_name (x_long_name  IN varchar2,
                                 x_rowid      IN varchar2 ) return number;
pragma RESTRICT_REFERENCES (check_unique_long_name, WNDS, WNPS);


--
--  FUNCTION
--              check_unique_project_number
--  PURPOSE
--		This function returns 1 if a project number is not already
--              used in PA system and returns 0 if name is used.
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_unique_project_number (x_project_number  IN varchar2,
				    x_rowid	  IN varchar2 ) return number;
pragma RESTRICT_REFERENCES (check_unique_project_number, WNDS, WNPS);


--
--  FUNCTION
--              check_unique_proj_class
--  PURPOSE
--		This function returns 1 if a project class code is
--              not already used for a specified project and class
--              category in PA system and returns 0 otherwise.
--              If a user does not supply all the values for project id,
--		x_class_category, and x_class_code, then null will
--              be returned.
--              If Oracle error occurs, Oracle error number is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_unique_proj_class (x_project_id  IN number
				  , x_class_category  IN varchar2
				  , x_class_code     IN varchar2
				  , x_rowid	  IN varchar2 ) return number;
pragma RESTRICT_REFERENCES (check_unique_proj_class, WNDS, WNPS);

--
--  FUNCTION
--              check_unique_customer
--  PURPOSE
--		 This function returns 1 if a customer is unique for
--               the specified project and returns 0 if that customer
--               already exists for that project.  If a user does not
--               supply all the values, then null is returned. If Oracle
--               error occurs, Oracle error number is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_unique_customer (x_project_id  IN number
				  , x_customer_id  IN varchar2
				  , x_rowid	  IN varchar2 ) return number;
pragma RESTRICT_REFERENCES (check_unique_customer, WNDS, WNPS);

--
--  FUNCTION
--              check_project_type_valid
--  PURPOSE
--		This function returns 1 if a project type is valid in
--              PA system and returns 0 if it's not valid.
--              If Oracle error occurs, Oracle error number is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_project_type_valid (x_project_type  IN varchar2 ) return number;
pragma RESTRICT_REFERENCES (check_project_type_valid, WNDS, WNPS);

--
--  FUNCTION
--	 	check_manager_exists
--  PURPOSE
--   		This function returns 1 if a project has an acting
--		manager and returns 0  if no manage is found.
--              If Oracle error occurs, Oracle error number is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_manager_exists (x_project_id  IN number ) return number;
pragma RESTRICT_REFERENCES (check_manager_exists, WNDS, WNPS);

--
--  FUNCTION
--	 	check_bill_split
--  PURPOSE
--   		This function returns 1 if a project has total customer
--		contribution of 100% and returns 0 if total contribution
--		is less than 100%.
--              If Oracle error occurs, Oracle error number is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_bill_split (x_project_id  IN number ) return number;
pragma RESTRICT_REFERENCES (check_bill_split, WNDS, WNPS);

--  FUNCTION
--	 	check_bill_contact_exists
--  PURPOSE
--   		This function returns 1 if a project has a billing contact
--		for a customer whose contribution is greater than 0 and
--		returns 0 if this condition is not met for that project.
--              If Oracle error occurs, Oracle error number is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_bill_contact_exists (x_project_id  IN number ) return number;
pragma RESTRICT_REFERENCES (check_bill_contact_exists, WNDS, WNPS);

--  FUNCTION
--	 	check_class_category
--  PURPOSE
--   		This function returns 1 if a project has all the mandatory
--		class categories and returns 0 if mandatory class category
--		is missing.
--              If Oracle error occurs, Oracle error number is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_class_category (x_project_id  IN number ) return number;
pragma RESTRICT_REFERENCES (check_class_category, WNDS, WNPS);


--  FUNCTION
--              check_draft_inv_exists
--  PURPOSE
--              This function returns 1 if draft invoice exists for a project
--              and returns 0 if no draft invoice is found.
--
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_draft_inv_exists (x_project_id  IN number ) return number;
pragma RESTRICT_REFERENCES (check_draft_inv_exists, WNDS, WNPS);


--  FUNCTION
--              check_draft_rev_exists
--  PURPOSE
--              This function returns 1 if draft revenue exists for a project
--              and returns 0 if no draft revenue is found.
--
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_draft_rev_exists (x_project_id  IN number ) return number;
pragma RESTRICT_REFERENCES (check_draft_rev_exists, WNDS, WNPS);


--  FUNCTION
--              check_created_proj_reference
--  PURPOSE
--              This function returns 1 if a project is referenced
--              by another project in pa_projects.created_from_project_id
--              and returns 0 if a project is not referenced.
--
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_created_proj_reference (x_project_id  IN number ) return number;
pragma RESTRICT_REFERENCES (check_created_proj_reference, WNDS, WNPS);


--
--  PROCEDURE
--              check_delete_project_ok
--  PURPOSE
--              This procedure checks if it is OK to delete a project
--  HISTORY
--   04-JAN-96      S. Lee	Created
--
procedure check_delete_project_ok ( x_project_id	IN        number
                                  , x_validation_mode   IN        VARCHAR2  DEFAULT 'U'   --Bug 2947492
				  , x_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
				  , x_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
				  , x_err_stack         IN OUT    NOCOPY varchar2); --File.Sql.39 bug 4440895
--
--  PROCEDURE
--              change_pt_org_ok
--  PURPOSE
--              This procedure checks if a project  has CDLs,Rev  or
--              Draft invoices.If project has any of
--              these information, then it's not ok to change the project
--              type or org and specific reason will be returned.
--		If it's ok to change project type or org,
--              the x_err_code will be 0.
--
--  HISTORY
--   13-JAN-96      R.Krishnamurthy  Created
--

procedure change_pt_org_ok        ( x_project_id	IN        number
				  , x_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
				  , x_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
				  , x_err_stack         IN OUT    NOCOPY varchar2); --File.Sql.39 bug 4440895
--
--  PROCEDURE
--              change_proj_num_ok
--  PURPOSE
--              This procedure checks if a project  has exp items,po reqs,
--              Draft invoices,po dists,ap invoices and ap inv dists .
--              If project has any of
--              these information, then it's not ok to change the project
--              number If it's ok to change project number
--              the x_err_code will be 0.
--
--  HISTORY
--   15-JAN-96      R.Krishnamurthy  Created
--

procedure change_proj_num_ok      ( x_project_id	IN        number
				  , x_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
				  , x_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
				  , x_err_stack         IN OUT    NOCOPY varchar2); --File.Sql.39 bug 4440895
--  FUNCTION
--              check_proj_funding
--  PURPOSE
--              This function returns 1 if funding exists for a project
--              with allocated amount > 0.Returns 0 if allocated amount <- 0
--              or there are no fundings for that project. If fundings
--              exist and allocated amount > 0 then , function returns 1.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   16-JAN-96      R. Krishnamurthy       Created
--
function check_proj_funding (x_project_id  IN number ) return number;
pragma RESTRICT_REFERENCES (check_proj_funding, WNDS, WNPS);

--  FUNCTION
--              check_option_child_exists
--  PURPOSE
--              This function returns Y if child  exists for a project
--              option and N otherwise
--
--  HISTORY
--   13-DEC-1996    D.Roy        Created
--
function check_option_child_exists (p_option_code  IN VARCHAR2 )
  return VARCHAR2;
pragma RESTRICT_REFERENCES (check_option_child_exists, WNDS, WNPS);

--  PROCEDURE
--              check_dist_rule_chg_ok
--  PURPOSE
--              This procedure checks whether it is ok
--              to change the Distribution rule
--              If it's ok to change Distribution rule
--              the x_err_code will be 0.
--
--  HISTORY
--   17-APR-96      R.Krishnamurthy  Created
--

procedure check_dist_rule_chg_ok  ( x_project_id	IN        number
                                  , x_old_dist_rule     IN        varchar2
                                  , x_new_dist_rule     IN        varchar2
				  , x_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
				  , x_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
				  , x_err_stack         IN OUT    NOCOPY varchar2); --File.Sql.39 bug 4440895

FUNCTION GetProjNumMode RETURN VARCHAR2;
pragma RESTRICT_REFERENCES (GetProjNumMode, WNDS, WNPS);

FUNCTION GetProjNumType RETURN VARCHAR2;
pragma RESTRICT_REFERENCES (GetProjNumType, WNDS, WNPS);

--  FUNCTION
--              Check_project_action_allowed
--  PURPOSE
--              This function returns 'N' or 'Y'
--              depending on whether the given action is allowed for
--              a project. It returns the value returned by the
--              Check_prj_stus_action_allowed function

FUNCTION Check_project_action_allowed
                          (x_project_id   IN NUMBER,
                           x_action_code  IN VARCHAR2 ) return VARCHAR2;
pragma RESTRICT_REFERENCES (Check_project_action_allowed, WNDS);/*Removed WNPS for bug 2125791*/

--  FUNCTION
--              Check_prj_stus_action_allowed
--  PURPOSE
--              This function returns 'N' or 'Y'
--              depending on whether the given action is allowed for
--              the project status.

FUNCTION Check_prj_stus_action_allowed
                          (x_project_status_code IN VARCHAR2,
                           x_action_code         IN VARCHAR2 ) return VARCHAR2;

pragma RESTRICT_REFERENCES (Check_prj_stus_action_allowed, WNDS);/*Removed WNPS for bug 2125791*/

--  FUNCTION
--              Check_sys_action_allowed
--  PURPOSE
--              This function returns 'N' or 'Y'
--              depending on whether the given action is allowed for
--              the project system status.

FUNCTION Check_sys_action_allowed
                          (x_project_system_status_code IN VARCHAR2,
                           x_action_code         IN VARCHAR2 ) return VARCHAR2;

pragma RESTRICT_REFERENCES (Check_sys_action_allowed, WNDS); /*Removed WNPS for bug 2125791*/

--
--  FUNCTION
--              is_tp_schd_proj_task
--  PURPOSE
--              This function returns 'N' or 'Y'
--              depending on whether the given schedule_id is in any
--              of the project/task.
--  HISTORY
--   03-AUG-99      sbalasub       Created
--
function is_tp_schd_proj_task (p_tp_schedule_id  IN Number) return varchar2;
pragma RESTRICT_REFERENCES (is_tp_schd_proj_task, WNDS, WNPS);


--  FUNCTION
--              Is_Admin_Project
--  PURPOSE
--              This function checks if a given project_id is
--              an Admin Project.  If it is an Admin project
--              then the function returns 'Y'.  If not, then the
--              function returns 'N'.
--
--  HISTORY
--   21-NOV-00      A.Layton       Created
--
FUNCTION Is_Admin_Project (p_project_id  IN pa_projects_all.project_id%TYPE)
                              RETURN VARCHAR2;
pragma RESTRICT_REFERENCES (Is_Admin_Project, WNDS, WNPS);

--  FUNCTION
--              Is_Admin_Project
--  PURPOSE
--              This function checks if a given project_id is
--              an Admin Project.  If it is an Admin project
--              then the function returns 'Y'.  If not, then the
--              function returns 'N'.
--
--  HISTORY
--   21-NOV-00      A.Layton       Created
--
FUNCTION Is_Unassigned_Time_Project (p_project_id  IN pa_projects_all.project_id%TYPE)
                                    RETURN VARCHAR2;

FUNCTION IsUserProjectManager (p_project_id  IN  NUMBER,
                               p_user_id     IN  NUMBER) return varchar2;

pragma RESTRICT_REFERENCES (Is_Unassigned_Time_Project, WNDS, WNPS);

procedure check_delete_project_type_ok (
    p_project_type_id                   IN  NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_message_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

/*Start: Addition of code for bug 2682806 */

Procedure check_delete_class_catg_ok (
    p_class_category                    IN  VARCHAR2
   ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_message_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

Procedure check_delete_class_code_ok (
    p_class_category                    IN  VARCHAR2
   ,p_class_code                        IN  VARCHAR2
   ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_message_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

/*End: Addition of code for bug 2682806 */

function check_unique_project_reference (p_proj_ref  IN varchar2,
				 p_prod_code IN varchar2, -- added for bug 4870305
                                 p_rowid      IN varchar2 ) return number;
pragma RESTRICT_REFERENCES (check_unique_project_reference, WNDS, WNPS);

--bug#2984611
function check_ic_proj_type_allowed(p_project_id IN NUMBER
                                   ,p_cc_prvdr_flag IN VARCHAR2)
RETURN NUMBER ;


-- Added for bug 3738892
function is_flex_enabled ( appl_id IN number, flex_name IN varchar2)
RETURN NUMBER;

-- Added for Bug 5647964
PROCEDURE VALIDATE_DFF
(   p_application_id               IN  NUMBER,
    p_flexfield_name               IN VARCHAR2,
    p_attribute_category           IN VARCHAR2,
    p_calling_module               IN VARCHAR2,
    p_attribute1                   IN VARCHAR2,
    p_attribute2                   IN VARCHAR2,
    p_attribute3                   IN VARCHAR2,
    p_attribute4                   IN VARCHAR2,
    p_attribute5                   IN VARCHAR2,
    p_attribute6                   IN VARCHAR2,
    p_attribute7                   IN VARCHAR2,
    p_attribute8                   IN VARCHAR2,
    p_attribute9                   IN VARCHAR2,
    p_attribute10                  IN VARCHAR2,
    p_attribute11                  IN VARCHAR2,
    p_attribute12                  IN VARCHAR2,
    p_attribute13                  IN VARCHAR2,
    p_attribute14                  IN VARCHAR2,
    p_attribute15                  IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2);

end PA_PROJECT_UTILS ;

/
