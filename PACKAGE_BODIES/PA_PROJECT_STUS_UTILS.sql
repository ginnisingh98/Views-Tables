--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_STUS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_STUS_UTILS" AS
-- $Header: PAPSUTLB.pls 120.3 2007/02/08 12:50:38 sukhanna ship $

l_pkg_name    VARCHAR2(30) := 'PA_PROJECT_STUS_UTILS';
/* Bug 3059344: this function is commented, please see eof for the function code
FUNCTION Is_Project_Closed
                          (x_project_id IN NUMBER ) return VARCHAR2 IS

CURSOR l_proj_csr IS
SELECT project_status_code
FROM  pa_projects_all
WHERE project_id = x_project_id;
l_proj_status_code  VARCHAR2(30);
l_closed            VARCHAR2(1) := 'N';
BEGIN
     OPEN l_proj_csr;
     FETCH l_proj_csr INTO l_proj_status_code;
     IF l_proj_csr%NOTFOUND THEN
        CLOSE l_proj_csr;
        RETURN 'N';
     END IF;
     CLOSE l_proj_csr;

     l_closed := Is_Project_Status_Closed (l_proj_status_code);
     RETURN NVL(l_closed,'N');

EXCEPTION
  WHEN OTHERS THEN
       RETURN 'N';
END Is_Project_Closed;
*/

-- STATUS MODEL changes - the following function is for status_type PROJECT
-- only since it calls pa_utils2.IsProjectClosed which compares Project
-- related system statuses only. The filer for status_type has been added
-- only to make it apparent that this function is for PROJECT only.
/* Bug 3059344: this function is commented, please see eof for the function code
FUNCTION Is_Project_Status_Closed
                    (x_project_status_code IN VARCHAR2 ) return VARCHAR2 IS
CURSOR l_stus_csr IS
SELECT project_system_status_code
FROM pa_project_statuses
WHERE project_status_code = x_project_status_code
and status_type = 'PROJECT';

l_system_stus_code    VARCHAR2(30) := 'N';

BEGIN
     OPEN l_stus_csr;
     FETCH l_stus_csr INTO l_system_stus_code;
     IF l_stus_csr%NOTFOUND THEN
        CLOSE l_stus_csr;
        RETURN 'N';
     END IF;
     CLOSE l_stus_csr;
     IF pa_utils2.IsProjectClosed(l_system_stus_code)  = 'Y' THEN
        RETURN 'Y';
     ELSE
        RETURN 'N';
     END IF;
EXCEPTION
   WHEN OTHERS THEN
      RETURN 'N';

END Is_Project_Status_Closed;
*/

/* Bug#2431718 The function Is_ARPR_Project_Status_Closed is created to get the
   closed and partially purged projects only  */

FUNCTION Is_ARPR_Project_Status_Closed
                    (x_project_status_code IN VARCHAR2 ) return VARCHAR2 IS
  CURSOR l_arpr_stus_csr IS
  SELECT project_system_status_code
    FROM pa_project_statuses
   WHERE project_status_code = x_project_status_code
     and status_type = 'PROJECT';

  l_system_status_code    VARCHAR2(30) := 'N';

BEGIN

   OPEN l_arpr_stus_csr;
   FETCH l_arpr_stus_csr INTO l_system_status_code;

   IF l_arpr_stus_csr%NOTFOUND THEN
      CLOSE l_arpr_stus_csr;
      RETURN 'N';
   END IF;
   CLOSE l_arpr_stus_csr;

   if l_system_status_code in ( 'CLOSED',
                                'PARTIALLY_PURGED')  then
       RETURN ( 'Y');
   else
       RETURN ( 'N');
   end if;

EXCEPTION
   WHEN OTHERS THEN
      RETURN 'N';

END Is_ARPR_Project_Status_Closed;


-- STATUS MODEL changes - the following function is for status_type PROJECT
-- only since it calls pa_utils2.IsProjectInPurgeStatus which compares Project
-- related system statuses only. The filer for status_type has been added
-- only to make it apparent that this function is for PROJECT only.
FUNCTION Is_Project_In_Purge_Status
                    (x_project_status_code IN VARCHAR2 ) return VARCHAR2 IS
CURSOR l_stus_csr IS
SELECT project_system_status_code
FROM pa_project_statuses
WHERE project_status_code = x_project_status_code
and status_type = 'PROJECT';

l_system_stus_code    VARCHAR2(30) := 'N';

BEGIN
     OPEN l_stus_csr;
     FETCH l_stus_csr INTO l_system_stus_code;
     IF l_stus_csr%NOTFOUND THEN
        CLOSE l_stus_csr;
        RETURN 'N';
     END IF;
     CLOSE l_stus_csr;
     IF pa_utils2.IsProjectInPurgeStatus(l_system_stus_code)  = 'Y' THEN
        RETURN 'Y';
     ELSE
        RETURN 'N';
     END IF;
EXCEPTION
   WHEN OTHERS THEN
      RETURN 'N';

END Is_Project_In_Purge_Status;

Procedure Handle_Project_Status_Change
                 (x_calling_module                IN VARCHAR2
                 ,X_project_id                    IN NUMBER
                 ,X_old_proj_status_code          IN VARCHAR2
                 ,X_new_proj_status_code          IN VARCHAR2
                 ,X_project_type                  IN VARCHAR2
                 ,X_project_start_date            IN DATE
                 ,X_project_end_date              IN DATE
                 ,X_public_sector_flag            IN VARCHAR2
                 ,X_attribute_category            IN VARCHAR2
                 ,X_attribute1                    IN VARCHAR2
                 ,X_attribute2                    IN VARCHAR2
                 ,X_attribute3                    IN VARCHAR2
                 ,X_attribute4                    IN VARCHAR2
                 ,X_attribute5                    IN VARCHAR2
                 ,X_attribute6                    IN VARCHAR2
                 ,X_attribute7                    IN VARCHAR2
                 ,X_attribute8                    IN VARCHAR2
                 ,X_attribute9                    IN VARCHAR2
                 ,X_attribute10                   IN VARCHAR2
                 ,X_pm_product_code               IN VARCHAR2
                 ,x_init_msg                      IN VARCHAR2 := 'Y'
                 ,x_verify_ok_flag               OUT NOCOPY VARCHAR2 /* Added the nocopy check for Bug 4537865 */
                 ,x_wf_enabled_flag              OUT NOCOPY VARCHAR2 /* Added the nocopy check for Bug 4537865 */
                 ,X_err_stage                 IN OUT NOCOPY varchar2 /* Added the nocopy check for Bug 4537865 */
                 ,X_err_stack                 IN OUT NOCOPY varchar2 /* Added the nocopy check for Bug 4537865 */
                 ,x_err_msg_count                OUT NOCOPY Number /* Added the nocopy check for Bug 4537865 */
                 ,x_warnings_only_flag           OUT NOCOPY VARCHAR2 /* Added the nocopy check for Bug 4537865 */
 ) IS

l_msg_count  NUMBER;
l_err_code   NUMBER;
l_item_type  VARCHAR2(30);
l_wf_process VARCHAR2(30);
l_wf_enabled_flag VARCHAR2(1);
l_msg_data   VARCHAR2(2000);
l_api_name   VARCHAR2(30) := 'Handle_Project_Status_Change';
l_org_func_security  VARCHAR2(1);  /*bug#1968394  */
l_warnings_only_flag varchar2(1); --bug3134205
BEGIN
      IF x_init_msg = 'Y' THEN
         FND_MSG_PUB.Initialize;
      END IF;
         x_wf_enabled_flag := NULL;
         x_verify_ok_flag  := 'Y';

      --  Code Added for the bug#1968394
      -- Test the function security for Org changes
      --
      IF (fnd_function.test('PA_PAXPREPR_UPDATE_ORG') = TRUE) THEN
        l_org_func_security := 'Y';
      ELSE
        l_org_func_security := 'N';
      END IF;

  -- validate the status
       pa_project_utils2.validate_attribute_change(
       X_Context                => 'PROJECT_STATUS_CHANGE'
    ,  X_insert_update_mode     => NULL
    ,  X_calling_module         => x_calling_module
    ,  X_project_id             => x_project_id
    ,  X_task_id                => NULL
    ,  X_old_value              => X_old_proj_status_code
    ,  X_new_value              => X_new_proj_status_code
    ,  X_project_type           => X_project_type
    ,  X_project_start_date     => X_project_start_date
    ,  X_project_end_date       => X_project_end_date
    ,  X_public_sector_flag     => X_public_sector_flag
    ,  X_task_manager_person_id => NULL
    ,  X_Service_type           => NULL
    ,  X_task_start_date        => NULL
    ,  X_task_end_date          => NULL
    ,  X_entered_by_user_id     => FND_GLOBAL.USER_ID
    ,  X_attribute_category     => X_attribute_category
    ,  X_attribute1             => X_attribute1
    ,  X_attribute2             => X_attribute2
    ,  X_attribute3             => X_attribute3
    ,  X_attribute4             => X_attribute4
    ,  X_attribute5             => X_attribute5
    ,  X_attribute6             => X_attribute6
    ,  X_attribute7             => X_attribute7
    ,  X_attribute8             => X_attribute8
    ,  X_attribute9             => X_attribute9
    ,  X_attribute10            => X_attribute10
    ,  X_pm_product_code        => X_pm_product_code
    ,  X_pm_project_reference   => NULL
    ,  X_pm_task_reference      => NULL
--    ,  X_functional_security_flag => NULL  /* bug#1968394  */
    ,  X_functional_security_flag => l_org_func_security  /* bug#1968394  */
    ,  x_warnings_only_flag     => l_warnings_only_flag --bug3134205
    ,  X_err_code               => l_err_code
    ,  X_err_stage              => x_err_stage
    ,  X_err_stack              => x_err_stack );

       x_warnings_only_flag := l_warnings_only_flag; --bug3134205

       IF l_err_code <> 0 THEN
          x_err_msg_count := FND_MSG_PUB.Count_msg;
          x_wf_enabled_flag := NULL;
          x_verify_ok_flag  := 'N';
          RETURN;
       ELSE
          x_verify_ok_flag  := 'Y';

          Check_Wf_Enabled (x_project_status_code => X_new_proj_status_code,
                            x_project_type        => x_project_type,
                            x_project_id          => x_project_id,
                            x_wf_item_type        => l_item_type,
			    x_wf_process          => l_wf_process,
                            x_wf_enabled_flag     => l_wf_enabled_flag,
                            x_err_code            => l_err_code
                             );

-- 30-DEC-97, jwhite ---------------------------------------
-- Comment related to code change in
-- Check_Wf_Enabled procedure:
-- Unlike Create_Project API, it is NOT necessary
-- to check for x_err_code here. The Check_Wf_Enabled
-- procedure overrides the x_wf_enabled_flag (sets to 'N')
-- if x_err_code is <> 0.
-- Also, WF not coupled to changing statuses.
-- So, x_err_code is only meaningful if ORA error. If
-- ORA error, then the RAISE in Check_Wf_Enabled
-- will automatically rollback this and all higher
-- procedures.
--

          x_wf_enabled_flag := NVL(l_wf_enabled_flag,'N');

-- -------------------------------------------------------------------

       END IF;


EXCEPTION
WHEN OTHERS THEN

    -- 4537865
   x_verify_ok_flag        := NULL ;
   x_wf_enabled_flag       := 'N' ; -- As per logic in this API
   X_err_stage             := 'In WHEN OTHERS Block of Handle_Project_Status_Change API';
   x_warnings_only_flag    := NULL ;

    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name            => l_pkg_name
    , p_procedure_name      => l_api_name   );
     FND_MSG_PUB.Count_And_Get
    (p_count             =>      x_err_msg_count ,
     p_data              =>      X_err_stack);
    WF_CORE.CONTEXT('PA_PROJECT_STUS_UTILS','HANDLE_PROJECT_STATUS_CHANGE') ;
    RAISE;

END Handle_Project_Status_Change;

--
--  History
-- 	29-DEC-97	jwhite		- Populated x_err_code on
--					   Check_Wf_Enabled procedure.
--	30-DEC-97	jwhite 		- Override the returned
--					   x_wf_enabled_flag IF the
--                                                                        returned x_err_code <>0
--

Procedure Check_Wf_Enabled (x_project_status_code IN VARCHAR2,
                            x_project_type        IN VARCHAR2,
                            x_project_id          IN NUMBER,
                            x_wf_item_type       OUT NOCOPY VARCHAR2, /* Added the nocopy check for Bug 4537865 */
                            x_wf_process         OUT NOCOPY VARCHAR2, /* Added the nocopy check for Bug 4537865 */
                            x_wf_enabled_flag    OUT NOCOPY VARCHAR2, /* Added the nocopy check for Bug 4537865 */
                            x_err_code           OUT NOCOPY  NUMBER ) /* Added the nocopy check for Bug 4537865 */
IS
l_item_type  VARCHAR2(30) ;
l_wf_process VARCHAR2(30);
l_wf_enabled_flag VARCHAR2(1);
l_err_code   NUMBER;
l_msg_count  NUMBER;
l_msg_data   VARCHAR2(2000);
l_api_name   VARCHAR2(30) := 'Check_Wf_Enabled';
x_status_type   VARCHAR2(30);

CURSOR l_get_wf_details_csr (l_project_status_code IN VARCHAR2) IS
SELECT workflow_item_type,workflow_process
FROM pa_project_statuses
WHERE project_status_code = l_project_status_code;
BEGIN
        x_wf_enabled_flag := 'N';
        x_wf_item_type    := NULL;
        x_wf_process      := NULL;

-- Get the status_type for the given status_code
SELECT status_type
INTO   x_status_type
FROM   pa_project_statuses
WHERE  project_status_code=x_project_status_code;

-- Call the client extn that determines whether workflow is enabled or not

        pa_client_extn_proj_status.Check_wf_enabled
                           (x_project_status_code => x_project_status_code,
                            x_project_type        => x_project_type,
                            x_project_id          => x_project_id,
                            x_wf_enabled_flag     => l_wf_enabled_flag,
                            x_err_code            => l_err_code,
                            x_status_type         => x_status_type
                            );

-- 29-DEC-97, jwhite ----------------------------------
-- Populate OUT-parameter because
-- Create_Project API checks BOTH
-- the x_wf_enabled_flag and the
-- x_err_code OUT-parameters.
-- The Handle_Project_Status_Changes
-- procedure of the Update_Project
-- API only tests the  x_wf_enabled_flag.
--
x_err_code            := l_err_code;
-- ----------------------------------------------------------

-- 30-DEC-97, jwhite ----------------------------------
-- Override the returned x_wf_enabled_flag IF the
--  returned x_err_code <>0 (meaning either
--  business error or SQL error).
--  The default value of 'N' will be returned
--  to the calling procedure.
--

      IF ( (l_wf_enabled_flag = 'Y') AND
	(l_err_code = 0)  )
	 THEN
          OPEN l_get_wf_details_csr (x_project_status_code);
          FETCH l_get_wf_details_csr INTO l_item_type,l_wf_process;
          IF l_get_wf_details_csr%NOTFOUND OR
             l_item_type IS NULL OR
             l_wf_process is NULL  THEN
                x_wf_enabled_flag := 'N';
                CLOSE l_get_wf_details_csr;
                RETURN;
          END IF;
          CLOSE l_get_wf_details_csr;
          x_wf_enabled_flag := 'Y';
          x_wf_item_type    := l_item_type;
          x_wf_process      := l_wf_process;
     END IF;


EXCEPTION
WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name            => l_pkg_name
    , p_procedure_name      => l_api_name   );
     FND_MSG_PUB.Count_And_Get
    (p_count             =>      l_msg_count     ,
     p_data              =>      l_msg_data      );
    WF_CORE.CONTEXT('PA_PROJECT_STUS_UTILS','CHECK_WF_ENABLED');

     -- 4537865 : RESET OUT params

     x_wf_item_type       := NULL ;
     x_wf_process         := NULL ;
     x_wf_enabled_flag    := 'N' ;
     x_err_code := SQLCODE;
     RAISE;

END Check_Wf_Enabled;

FUNCTION Is_Starting_Status (x_project_status_code IN VARCHAR2) RETURN VARCHAR2

-- This function checks whether a given project status is a starting
-- status for any project type
IS
CURSOR l_chk_starting_stus_csr IS
SELECT 'Y'
FROM    pa_project_statuses
WHERE   project_status_code = x_project_status_code
AND     trunc(sysdate) BETWEEN start_date_active and
        nvl(end_date_active,trunc(sysdate))
AND     starting_status_flag='Y';

l_dummy   VARCHAR2(1);

BEGIN
     OPEN  l_chk_starting_stus_csr;
     FETCH l_chk_starting_stus_csr INTO l_dummy;
     IF    l_chk_starting_stus_csr%NOTFOUND THEN
           l_dummy := 'N';
     END IF;
     CLOSE l_chk_starting_stus_csr;
     RETURN NVL(l_dummy,'N');

END Is_Starting_Status;

FUNCTION Get_Default_Starting_Status (x_project_type IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR l_get_def_stus_csr IS
SELECT def_start_proj_status_code
FROM   pa_project_types
WHERE  project_type = x_project_type;

l_project_type   VARCHAR2(30);

BEGIN

     OPEN l_get_def_stus_csr;
     FETCH l_get_def_stus_csr INTO l_project_type;
     IF l_get_def_stus_csr%NOTFOUND THEN
        l_project_type := NULL;
     END IF;
     CLOSE l_get_def_stus_csr;
     RETURN l_project_type;

END Get_Default_Starting_Status;

-- STATUS MODEL addition --PROCEDURE Allow_Status_Deletion
-- This procedure checks the current status to see if it is used anywhere
-- The following procedure was moved from forms to server side
-- so as to make the form code generic for all the different status types
-- and let a server side procedure handles the specifics
-- The parameters are:
--       p_project_status_code : the status code as in
--					   PA_PROJECT_STATUSES.project_status_code
--       p_status_type : the status type of the entiry as in
--					   PA_PROJECT_STATUSES.status_type
--       x_err_code    : an error code which indicates the results of the check
--       x_err_stage   :
--       x_err_stack   :
--       x_allow_deletion_flag   : 'Y' for deletable and 'N' for non-deletable
--
PROCEDURE Allow_Status_Deletion(
	    p_project_status_code IN VARCHAR2
          , p_status_type        IN VARCHAR2
          , x_err_code          OUT NOCOPY NUMBER /* Added the nocopy check for Bug 4537865 */
          , x_err_stage         OUT NOCOPY VARCHAR2 /* Added the nocopy check for Bug 4537865 */
          , x_err_stack         OUT NOCOPY VARCHAR2  /* Added the nocopy check for Bug 4537865 */
          , x_allow_deletion_flag OUT NOCOPY VARCHAR2)  /* Added the nocopy check for Bug 4537865 */
IS
    old_stack             varchar2(630);
    x_in_use_flag         varchar2(1);
    x_return_status       varchar2(255);
    x_error_message_code  varchar2(255);

    --Bug: 5635429
     l_status_used_in_proj_type  varchar2(1);

BEGIN
-- hr_utility.trace_on(null, 'RMDEL');
-- hr_utility.trace('Start Allow_Status_Deletion');
        x_err_code := 0;
        old_stack := x_err_stack;
    x_err_stack := x_err_stack||'PA_PROJECT_STUS_UTILS.Allow_Status_Deletion';
        x_err_stage := 'IS_DELETABLE';
    x_allow_deletion_flag := 'N';

--   Added for lifecycle support
--  Calling procedure check_delete_phase_Ok to check for the constraints available for phase type status code before deleting

   IF (p_status_type='PHASE') THEN
      Begin
      	check_delete_phase_ok( p_project_status_code  => p_project_status_code,
		                       x_err_code =>x_err_code,
					x_err_stage =>x_err_stage,
					x_err_stack =>x_err_stack,
					x_allow_deletion_flag =>x_allow_deletion_flag);
	if (x_allow_deletion_flag='N') then
	            return;
	 end if;
	 exception when no_data_found then
                null;
	end;
   END IF;


   IF (p_status_type='PROJECT') THEN
--   First (keep it FIRST) check if it is a default starting status

       --Bug 5635429. Replaced the select statement below with a function call
       --so that the same can be used in multiple places. The function will be
       --used in PAXSUDPS.fmb
       l_status_used_in_proj_type :=
                    pa_project_stus_utils.is_status_used_in_proj_type(p_project_status_code => p_project_status_code);

       IF l_status_used_in_proj_type = 'Y' THEN

            x_err_stage           := 'PA_STATUS_CHECK_PRJSTRT';
            x_allow_deletion_flag := 'N';

       END IF;
       begin
        /*Select 'PA_STATUS_CHECK_PRJSTRT','N'
        Into x_err_stage,x_allow_deletion_flag
        From dual
        Where exists
             (select '1'
             from PA_PROJECT_TYPES_ALL   T
             where T.def_start_proj_status_code=p_project_status_code);*/
	--Bug 5635429
        if       (x_allow_deletion_flag='N' AND
		    x_err_stage = 'PA_STATUS_CHECK_PRJSTRT') then
				 return;
        end if;
      exception when no_data_found then
                null;
      end;
--   Second check if it is a status in use in Projects
       begin
        Select 'PA_STATUS_CHECK_PRJUSED','N'
        Into x_err_stage,x_allow_deletion_flag
        From dual
        Where exists
             (select '1'
             from PA_PROJECTS_ALL   P
             where P.project_status_code=p_project_status_code);
        if       (x_allow_deletion_flag='N') then
				 return;
        end if;
      exception when no_data_found then
                null;
      end;

--   Third check if it is a status in use in Projects Role Status security

-- hr_utility.trace('before check_status_is_in_use');
      pa_role_status_menu_utils.check_status_is_in_use(
                   p_status_code        => p_project_status_code
                  ,p_in_use_flag        => x_in_use_flag
                  ,p_return_status      => x_return_status
                  ,p_error_message_code => x_error_message_code);

-- hr_utility.trace('after check_status_is_in_use');
-- hr_utility.trace('x_in_use_flag is :' || x_in_use_flag);
      IF x_in_use_flag = 'Y' THEN
         x_allow_deletion_flag := 'N';
         x_err_stage := x_error_message_code;
         return;
      ELSE
         x_allow_deletion_flag := 'Y';
      END IF;

   ELSE  -- if a PRM related status_type
            PA_ASSIGNMENT_UTILS.check_status_is_in_use(
				p_project_status_code
				, x_in_use_flag
				, x_return_status
				,x_error_message_code
				);
           if    x_in_use_flag='Y' then
                 x_allow_deletion_flag:='N';
                 x_err_stage:=x_error_message_code;
           else
                 x_allow_deletion_flag:='Y';
           end if;
   END IF;

--   Third check if it is a pre-defined status
       begin
        Select 'PA_STATUS_CHECK_PRE_DEF','N'
        Into x_err_stage,x_allow_deletion_flag
        From dual
        Where exists
     		 (select '1'
              from PA_PROJECT_STATUSES   S
              where S.project_status_code=p_project_status_code
              and   S.predefined_flag='Y');
        if       (x_allow_deletion_flag='N') then
				 return;
        end if;
      exception when no_data_found then
                null;
      end;

--   Fourth check if it is a next allowable status
       begin
        Select 'PA_STATUS_CHECK_NEXT','N'
        Into x_err_stage,x_allow_deletion_flag
        From dual
        Where exists
     		 (select '1'
              from PA_NEXT_ALLOW_STATUSES N
              where N.next_allowable_status_code=p_project_status_code);
        if       (x_allow_deletion_flag='N') then
				 return;
        end if;
      exception when no_data_found then
                null;
      end;

--   Fifth check if it is a workflow status
       begin
        Select 'PA_STATUS_CHECK_WF_USED','N'
        Into x_err_stage,x_allow_deletion_flag
        From dual
        Where exists
             (select '1'
             from PA_PROJECT_STATUSES  S
             where S.wf_success_status_code=p_project_status_code
             OR    S.wf_failure_status_code=p_project_status_code);
        if       (x_allow_deletion_flag='N') then
				 return;
        end if;
      exception when no_data_found then
                null;
      end;

--   Sixth check if referenced in progress tables. Added in FP.K
     if(pa_progress_utils.check_status_referenced(p_project_status_code) ) then
       x_allow_deletion_flag := 'N';
       x_err_stage := 'PA_STATUS_CHECK_TSKUSED';
       return;
     end if;

    x_allow_deletion_flag := 'Y';
    x_err_stack := old_stack;

EXCEPTION
    WHEN OTHERS THEN
         x_err_code := SQLCODE;
         x_err_stack := x_err_stack||' ->in exception of ALLOW_STATUS_DELETION';
	 x_allow_deletion_flag := 'N' ; -- 4537865
End Allow_Status_Deletion;



-- STATUS MODEL addition
-- The following function was added to check if changing of status
-- for the given two statuses is allowed. This function could be used
-- by any status type
FUNCTION Allow_Status_Change (o_status_code IN VARCHAR2
                              ,n_status_code IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR c_allow_status_change IS
SELECT STATUS_CODE, NEXT_ALLOWABLE_STATUS_CODE
FROM   pa_next_allow_statuses
WHERE  STATUS_CODE=o_status_code
-- AND    NEXT_ALLOWABLE_STATUS_CODE=n_status_code
;
   c_rec  c_allow_status_change%ROWTYPE;

old_status_code   VARCHAR2(30);
new_status_code   VARCHAR2(30);
v_change_allowed    VARCHAR2(1):='N';
v_next_allowable_status_flag    VARCHAR2(1);

BEGIN
  Select next_allowable_status_flag
  into v_next_allowable_status_flag
  from pa_project_statuses
  where project_status_code = o_status_code;

  IF     (v_next_allowable_status_flag='A')  THEN
         v_change_allowed:='Y';
     	 RETURN v_change_allowed;
  ELSIF  (v_next_allowable_status_flag='N')  THEN
         v_change_allowed:='N';
     	 RETURN v_change_allowed;
  ELSIF  (v_next_allowable_status_flag='U')  THEN
         FOR c_rec in c_allow_status_change LOOP
             IF  (c_rec.NEXT_ALLOWABLE_STATUS_CODE = n_status_code)  THEN
                   v_change_allowed := 'Y';
     	           RETURN v_change_allowed;
             ELSE
                   v_change_allowed := 'N';
             END IF;
         END LOOP;
     	 RETURN v_change_allowed;
  ELSIF  (v_next_allowable_status_flag='S')  THEN
         FOR c_rec in c_allow_status_change LOOP
          begin
             Select 'Y'
             Into v_change_allowed
			 /*
             From PA_PROJECT_STATUSES
             Where PROJECT_SYSTEM_STATUS_CODE=c_rec.NEXT_ALLOWABLE_STATUS_CODE
             and   PROJECT_STATUS_CODE=n_status_code;
			 */
			 From dual
			 Where exists(
                select 'x'
                from PA_PROJECT_STATUSES
                where PROJECT_SYSTEM_STATUS_CODE=c_rec.NEXT_ALLOWABLE_STATUS_CODE
                and   PROJECT_STATUS_CODE=n_status_code);
             IF (v_change_allowed = 'Y') THEN
				    RETURN v_change_allowed;
             END IF;
          exception
           when no_data_found then
           null; -- to continue through the LOOP
          end;
         END LOOP;
     	 RETURN v_change_allowed;
  ELSE
         v_change_allowed:='N';
     	 RETURN v_change_allowed;
  END IF;
  EXCEPTION
         WHEN NO_DATA_FOUND THEN
         v_change_allowed:='N';
     	 RETURN v_change_allowed;
END Allow_Status_Change;

-- STATUS MODEL addition
-- The following procedure was added to delete from PA_NEXT_ALLOW_STATUSES
-- This procedure deletes all the rows which are not for the
--- current next_allow_status_flag
PROCEDURE Delete_from_Next_Status (p_current_status_code  IN VARCHAR2) IS

BEGIN

          Delete from PA_NEXT_ALLOW_STATUSES  N
          where N.status_code = p_current_status_code
        ;
END Delete_from_Next_Status;


-- STATUS MODEL addition
-- The following procedure was added to insert into PA_NEXT_ALLOW_STATUSES.
-- This procedure inserts the status_code and the next_allowable_status_code
-- passed.
PROCEDURE Insert_into_Next_Status(
					  p_current_status_code IN VARCHAR2
					  , p_next_status_code IN VARCHAR2) IS
cursor c_check1 IS
select status_code
from   PA_NEXT_ALLOW_STATUSES
where  STATUS_CODE = p_current_status_code
and    NEXT_ALLOWABLE_STATUS_CODE = p_next_status_code;

v_check1 VARCHAR2(30);

BEGIN

   OPEN c_check1;
   FETCH c_check1 INTO v_check1;
   IF c_check1%NOTFOUND THEN
      CLOSE c_check1;
	   Insert into PA_NEXT_ALLOW_STATUSES(
		   STATUS_CODE
		   , NEXT_ALLOWABLE_STATUS_CODE
		   , LAST_UPDATE_DATE
		   , LAST_UPDATED_BY
		   , CREATION_DATE
		   , CREATED_BY
		   , LAST_UPDATE_LOGIN
           )
       Values(
		   p_current_status_code
		   , p_next_status_code
		   , sysdate
		   , 1
		   , sysdate
		   , 1
		   , 1
		   );
   ELSE
       CLOSE c_check1;
   END IF;
END Insert_into_Next_Status;


-- STATUS MODEL addition
-- The following procedure was added for the PRM team to be able to
-- check either the name or code of a status given the other
PROCEDURE Check_Status_Name_or_Code(
                 p_status_code           IN VARCHAR2
                 ,p_status_name          IN VARCHAR2
                 ,p_status_type          IN VARCHAR2
                 ,p_check_id_flag        IN VARCHAR2
                 ,x_status_code             OUT NOCOPY VARCHAR2  /* Added the nocopy check for Bug 4537865 */
                 ,x_return_status       OUT NOCOPY VARCHAR2  /* Added the nocopy check for Bug 4537865 */
                 ,x_error_message_code  OUT NOCOPY VARCHAR2) IS  /* Added the nocopy check for Bug 4537865 */
BEGIN
   IF       p_status_code IS NOT NULL THEN
            if      p_check_id_flag = 'Y' then
                    SELECT project_status_code
                    INTO   x_status_code
                    FROM   pa_project_statuses
                    WHERE  project_status_code = p_status_code
					AND    status_type = p_status_type
					AND    trunc(sysdate) between trunc(start_date_active) and trunc(nvl(end_date_active,sysdate));
            else    x_status_code := p_status_code;
            end if;
   ELSE
                    SELECT project_status_code
                    INTO   x_status_code
                    FROM   pa_project_statuses
                    WHERE  project_status_name = p_status_name
					AND    status_type = p_status_type
					AND    trunc(sysdate) between trunc(start_date_active) and trunc(nvl(end_date_active,sysdate));
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_STATUS_INVALID_AMBIGUOUS';
        WHEN TOO_MANY_ROWS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_STATUS_INVALID_AMBIGUOUS';
        WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	 x_error_message_code := SQLERRM; -- 4537865
	 x_status_code := NULL ; -- 4537865
        RAISE;
END Check_Status_Name_or_Code;


-- this procedure returns the wf success and failure statuses for a given
-- status. If the values are not specified, it returns the same
-- status
PROCEDURE  get_wf_success_failure_status
				(p_status_code IN VARCHAR2
				,p_status_type IN VARCHAR2
				,x_wf_success_status_code OUT NOCOPY VARCHAR2 /* Added the nocopy check for Bug 4537865 */
				,x_wf_failure_status_code OUT NOCOPY VARCHAR2 /* Added the nocopy check for Bug 4537865 */
                                ,x_return_status       OUT NOCOPY VARCHAR2 /* Added the nocopy check for Bug 4537865 */
                                ,x_error_message_code  OUT NOCOPY VARCHAR2)  /* Added the nocopy check for Bug 4537865 */
IS
BEGIN
	SELECT NVL(wf_success_status_code,project_status_code),
	       NVL(wf_failure_status_code,project_status_code)
	INTO x_wf_success_status_code,x_wf_failure_status_code
	FROM pa_project_statuses
	WHERE project_status_code = p_status_code
	AND   status_type         = p_status_type;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_STATUS_INVALID_AMBIGUOUS';
         -- 4537865
         x_wf_success_status_code := NULL ;
         x_wf_failure_status_code := NULL ;
        WHEN TOO_MANY_ROWS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_STATUS_INVALID_AMBIGUOUS';
         -- 4537865
         x_wf_success_status_code := NULL ;
         x_wf_failure_status_code := NULL ;
        WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	 -- 4537865
	 x_wf_success_status_code := NULL ;
	 x_wf_failure_status_code := NULL ;
	 x_error_message_code := SQLERRM;
        RAISE;
END get_wf_success_failure_status;

--   Added for lifecycle support
--  This procedure will check for the constraints available for phase type status code before deleting
	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/

Procedure check_delete_phase_ok(
          p_project_status_code  IN VARCHAR2
	  , x_err_code          OUT NOCOPY NUMBER /* Added the nocopy check for Bug 4537865 */
          , x_err_stage         OUT NOCOPY VARCHAR2 /* Added the nocopy check for Bug 4537865 */
          , x_err_stack         OUT NOCOPY VARCHAR2 /* Added the nocopy check for Bug 4537865 */
          , x_allow_deletion_flag         OUT NOCOPY VARCHAR2) /* Added the nocopy check for Bug 4537865 */
IS
BEGIN
--  checking whether the phase to be deleted has been used by a lifecycle
	Select 'PA_PHASE_LIFECYCLE_USED','N'
		Into x_err_stage,x_allow_deletion_flag
		From dual
		Where exists(Select 'XYZ' from pa_proj_elements
		 where project_id= 0 and object_type = 'PA_TASKS'
		 and phase_code= p_project_status_code);
--   check for PLM needs to be added
-- 4537865
EXCEPTION
WHEN OTHERS THEN
	x_err_code := SQLCODE ;
	x_err_stage := 'PA_PHASE_LIFECYCLE_USED' ;
	x_err_stack := SUBSTRB(SQLERRM ,1,100);
	x_allow_deletion_flag := 'N' ;

	-- NO RAISE as per the usage of this API
End check_delete_phase_ok;

--start Bug 3059344
FUNCTION Is_Project_Closed(x_project_id IN NUMBER ) return VARCHAR2 IS
        l_Found         BOOLEAN         := FALSE;
        l_proj_status_code pa_projects_all.project_status_code%type;
        X_PROJ_CLOSED    VARCHAR2(1);
  Begin
        -- Check if there are any records in the pl/sql table.
        If G_ProjID_Tab.COUNT > 0 Then
            --Dbms_Output.Put_Line('count > 0');

            Begin
                X_PROJ_CLOSED := G_ProjID_Tab(x_project_id);
                l_Found := TRUE;
                --Dbms_Output.Put_Line('l_found TRUE');
            Exception
                When No_Data_Found Then
                        l_Found := FALSE;
                When Others Then
                        Raise;
            End;

        End If;

        If Not l_Found Then
                --Dbms_Output.Put_Line('l_found FALSE');

                If G_ProjID_Tab.COUNT > 999 Then
                        --Dbms_Output.Put_Line('count > 199');
                        G_ProjID_Tab.Delete;
                End If;

              Begin
                --Dbms_Output.Put_Line('select');
                SELECT project_status_code
                into  l_proj_status_code
                FROM  pa_projects_all
                WHERE project_id = x_project_id;

                X_PROJ_CLOSED := Is_Project_Status_Closed (l_proj_status_code);

                G_ProjID_Tab(x_project_ID) := X_PROJ_CLOSED;
                --Dbms_Output.Put_Line('after select');
              Exception
                When No_Data_Found Then
                     --Dbms_Output.Put_Line('wndf ');
                     X_PROJ_CLOSED := 'N';
                     G_ProjID_Tab(x_project_id) := 'N';
              End;

        End If;

        Return X_PROJ_CLOSED;

EXCEPTION
  WHEN OTHERS THEN
       RETURN 'N';
END Is_Project_Closed;

-- STATUS MODEL changes - the following function is for status_type PROJECT
-- only since it calls pa_utils2.IsProjectClosed which compares Project
-- related system statuses only. The filer for status_type has been added
-- only to make it apparent that this function is for PROJECT only.
FUNCTION Is_Project_Status_Closed (x_project_status_code IN VARCHAR2 ) return VARCHAR2 IS

        l_system_status_code pa_projects_all.project_status_code%type;
  Begin

       If x_project_status_code = g_project_status_code Then
          RETURN g_proj_sts_closed;
       Else
              Begin
                --Dbms_Output.Put_Line('select');
                SELECT project_system_status_code
                INTO  l_system_status_code
                FROM pa_project_statuses
                WHERE project_status_code = x_project_status_code
                and status_type = 'PROJECT';

                g_project_status_code := x_project_status_code;
                G_PROJ_STS_CLOSED := pa_utils2.IsProjectClosed(l_system_status_code);

                --Dbms_Output.Put_Line('after select');
              Exception
                When No_Data_Found Then
                     --Dbms_Output.Put_Line('wndf ');
                     g_project_status_code := x_project_status_code;
                     G_PROJ_STS_CLOSED := 'N';
              End;

        End If;

        Return G_PROJ_STS_CLOSED;

EXCEPTION
   WHEN OTHERS THEN
      RETURN 'N';

END Is_Project_Status_Closed;
--End Bug 3059344


--Bug 5635429. This function will return Y if the project status is being
--used in project types setup. N will be returned otherwise
FUNCTION   is_status_used_in_proj_type(p_project_status_code IN VARCHAR2)
RETURN VARCHAR2
AS
l_dummy    VARCHAR2(1);
BEGIN

    SELECT 'Y'
    INTO   l_dummy
    FROM   dual
    WHERE EXISTS
        (SELECT '1'
         FROM   pa_project_types_all   t
         WHERE  t.def_start_proj_status_code=p_project_status_code
         AND project_type <> 'AWARD_PROJECT' /* Bug 5718627 */
         );

    RETURN 'Y';
EXCEPTION WHEN NO_DATA_FOUND THEN

    RETURN 'N';
END;


END PA_PROJECT_STUS_UTILS;



/
