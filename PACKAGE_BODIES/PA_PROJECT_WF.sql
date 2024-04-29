--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_WF" AS
/* $Header: PAWFPRVB.pls 120.2.12010000.4 2009/06/10 05:35:05 sugupta ship $ */

-- ==================================================
--
--Name:               Select_Project_Approver
--Type:                 Procedure
--Description:     This procedure calls a client extension
--                      that returns the correct ID of the
--      project approver.
--
--
--Called subprograms: PA_CLIENT_EXTN_PROJECT_WF.Select_Project_Approver
--
--
--
--
--History:
--      24-FEB-1997       L. de Werker    Created
--  06-OCT-97   jwhite      - Updated as required per
--                     unit testing.
--  26-NOV-97   jwhite      - Replaced calls to Set_Global_Info
--                     with Set_Global_Attr to
--                     drop AMG linkage.
--
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The notification process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   Resultout    - Approver User ID
--
PROCEDURE Select_Project_Approver (     itemtype    in varchar2,
                    itemkey     in varchar2,
                    actid       in number,
                    funcmode    in varchar2,
                    resultout   out NOCOPY varchar2    ) --File.Sql.39 bug 4440895
IS
--
CURSOR  l_approver_user_csr( p_approver_id NUMBER ) IS
SELECT  f.user_id
,       f.user_name
,       e.first_name||' '||e.last_name
FROM    fnd_user f
        ,pa_employees e
WHERE   f.employee_id = p_approver_id
AND     f.employee_id = e.person_id;

l_err_code  NUMBER := 0;
l_resp_id           NUMBER;
l_project_id            NUMBER;
l_workflow_started_by_id    NUMBER;
l_approver_employee_id      NUMBER;
l_approver_user_id      NUMBER;
l_approver_user_name        VARCHAR2(240);
l_approver_full_name        VARCHAR2(400);/*UTF8-changed from varchsr2(240)  to varchar2(400)*/
l_msg_count         NUMBER;
l_msg_data          VARCHAR(2000);
l_return_status         VARCHAR2(1);
l_data              VARCHAR(2000);
l_msg_index_out         NUMBER;
l_api_version_number        NUMBER      := 1.0;



--
BEGIN
    --
    -- Return if WF Not Running
    --
    IF (funcmode <> wf_engine.eng_run) THEN
        --
            resultout := wf_engine.eng_null;
            RETURN;
        --
    END IF;
    --

l_resp_id := wf_engine.GetItemAttrNumber
            (itemtype   => itemtype,
         itemkey    => itemkey,
             aname      => 'RESPONSIBILITY_ID' );

l_project_id := wf_engine.GetItemAttrNumber(itemtype    => itemtype,
                            itemkey     => itemkey,
                            aname       => 'PROJECT_ID' );
l_workflow_started_by_id :=
         wf_engine.GetItemAttrNumber(itemtype  => itemtype,
                     itemkey   => itemkey,
                     aname     => 'WORKFLOW_STARTED_BY_ID' );

-- Based on the Responsibility, Intialize the Application
PA_WORKFLOW_UTILS.Set_Global_Attr
 (p_item_type => itemtype
                 , p_item_key  => itemkey
   , p_err_code  => l_err_code);


    PA_CLIENT_EXTN_PROJECT_WF.Select_Project_Approver
                (p_project_id                   => l_project_id
      , p_workflow_started_by_id          => l_workflow_started_by_id
      , p_project_approver_id                 => l_approver_employee_id
      );


--ISSUE: a employee can have several users attached to it!!
-- Return True if an approver can be found
-- Else Return False

           IF (l_approver_employee_id IS NOT NULL )
           THEN
       OPEN l_approver_user_csr( l_approver_employee_id );
       FETCH l_approver_user_csr INTO
                 l_approver_user_id
        ,l_approver_user_name
        ,l_approver_full_name;
       IF (l_approver_user_csr%FOUND)
        THEN
          CLOSE l_approver_user_csr;
          wf_engine.SetItemAttrNumber
                    (itemtype => itemtype,
                     itemkey  => itemkey,
                     aname    => 'PROJECT_APPROVER_ID',
                     avalue   => l_approver_user_id );
          wf_engine.SetItemAttrText
                    (itemtype  => itemtype,
                     itemkey   => itemkey,
             aname     => 'PROJECT_APPROVER_NAME',
             avalue    =>  l_approver_user_name);
          wf_engine.SetItemAttrText
                    (itemtype  => itemtype,
                     itemkey   => itemkey,
             aname     => 'PROJECT_APPROVER_FULL_NAME',
             avalue    =>  l_approver_full_name
            );
          resultout := wf_engine.eng_completed||':'||'T';
        ELSE
            CLOSE l_approver_user_csr;
            resultout := wf_engine.eng_completed||':'||'F';
                  END IF;
            ELSE
        resultout := wf_engine.eng_completed||':'||'F';
           END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR
    THEN
    WF_CORE.CONTEXT('PA_PROJECT_WF','SELECT_PROJECT_APPROVER',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR
   THEN
    WF_CORE.CONTEXT('PA_PROJECT_WF','SELECT_PROJECT_APPROVER',itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

WHEN OTHERS
   THEN
    WF_CORE.CONTEXT('PA_PROJECT_WF','SELECT_PROJECT_APPROVER',itemtype, itemkey, to_char(actid), funcmode);
    RAISE;



END Select_Project_Approver;

-- ====================================================

PROCEDURE Start_Project_Wf (p_project_id  IN NUMBER,
                            p_err_stack  IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            p_err_stage  IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            p_err_code   OUT NOCOPY NUMBER) IS --File.Sql.39 bug 4440895

CURSOR l_get_projinfo_csr (l_project_id IN NUMBER)  IS
SELECT
      ps.workflow_item_type,
      ps.workflow_process
FROM pa_projects_all pap,  -- Bug#3807805 : Modified pa_projects to pa_projects_all
     pa_project_statuses ps
WHERE pap.project_id = l_project_id
AND   pap.project_status_code = ps.project_status_code;

l_get_projinfo_rec l_get_projinfo_csr%ROWTYPE;
l_out_item_key   VARCHAR2(100);
l_err_code NUMBER := 0;
l_err_stack VARCHAR2(2000);
l_err_stage VARCHAR2(2000);

BEGIN

--dbms_output.put_line('START_PROJECT_WF  - INSIDE');

   OPEN l_get_projinfo_csr (p_project_id) ;
   FETCH l_get_projinfo_csr INTO l_get_projinfo_rec;
   IF l_get_projinfo_csr%NOTFOUND THEN
      p_err_code  := 10;
      p_err_stage := 'PA_PROJECT_STATUS_INVALID';
      CLOSE l_get_projinfo_csr;
   END IF;
   CLOSE l_get_projinfo_csr;

 --dbms_output.put_line('CALL EXTN START_PROJECT_WF');

   Pa_Client_Extn_Project_Wf.Start_Project_Wf
                         (p_project_id => p_project_id,
                          p_item_type  => l_get_projinfo_rec.workflow_item_type,
                          p_process    => l_get_projinfo_rec.workflow_process,
                          p_out_item_key => l_out_item_key,
                          p_err_stack  => l_err_stack,
                          p_err_stage  => l_err_stage,
                          p_err_code   => l_err_code
        );

--dbms_output.put_line('AFTER EXTN - l_err_code: '||to_char(l_err_code));

   IF l_err_code = 0 THEN
      PA_WORKFLOW_UTILS.Insert_WF_Processes
      (p_wf_type_code        => 'PROJECT'
      ,p_item_type           => l_get_projinfo_rec.workflow_item_type
      ,p_item_key            => l_out_item_key
      ,p_entity_key1         => to_char(p_project_id)
      ,p_description         => NULL
      ,p_err_code            => l_err_code
      ,p_err_stage           => l_err_stage
      ,p_err_stack           => l_err_stack
      );
  END IF;

--dbms_output.put_line('AFTER INSERT_WF_PROCESSES');

EXCEPTION
WHEN OTHERS
  THEN
    p_err_code := SQLCODE;
    WF_CORE.CONTEXT('PA_PROJECT_WF','START_PROJECT_WF');
    RAISE;


END Start_Project_Wf;

-- ====================================================
--
-- History
--  02-DEC-97   jwhite      - For Set_Success_Status added
--                     clauses to the update that
--                     occurs if the verify was OK.
--

PROCEDURE Set_Success_status
  (itemtype                      IN      VARCHAR2
  ,itemkey                       IN      VARCHAR2
  ,actid                         IN      NUMBER
  ,funcmode                      IN      VARCHAR2
  ,resultout                     OUT     NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
l_err_code  NUMBER := 0;
l_err_stage VARCHAR2(2000);
l_err_stack VARCHAR2(2000);
l_success_status_code   VARCHAR2(30);
l_failure_status_code   VARCHAR2(30);
l_project_id NUMBER := 0;
l_wf_enabled_flag VARCHAR2(1);
l_verify_ok_flag  VARCHAR2(1);

/* Bug 2345889 Part 1- Begin*/
l_resp_id              NUMBER ;
l_project_approver_id  NUMBER ;
l_proj_stus_code       PA_PROJECT_STATUSES.PROJECT_STATUS_CODE%TYPE;
l_proj_system_status_code       PA_PROJECT_STATUSES.PROJECT_SYSTEM_STATUS_CODE%TYPE;
l_proj_success_sys_sts_code     PA_PROJECT_STATUSES.PROJECT_SYSTEM_STATUS_CODE%TYPE;

CURSOR l_proj_system_status_csr(x_project_status_code PA_PROJECT_STATUSES.PROJECT_STATUS_CODE%TYPE) IS
SELECT project_system_status_code
FROM   pa_project_statuses
WHERE  project_status_code = x_project_status_code;
/* Bug 2345889 Part 1- End*/

l_msg_count NUMBER :=0;         /*Bug 3611598*/
l_return_status VARCHAR2(2000);

-- 3671408 added cursor to retrieve project number

 CURSOR c_project_details(p_project_id PA_PROJECTS_ALL.PROJECT_ID%TYPE) IS
 SELECT segment1
 FROM  PA_PROJECTS_ALL
 WHERE PROJECT_ID = p_project_id;

 l_project_number pa_projects_all.segment1%type;

BEGIN

        --
        -- Return if WF Not Running
        --
        IF (funcmode <> wf_engine.eng_run) THEN
                --
                resultout := wf_engine.eng_null;
                RETURN;
        END IF;

Get_proj_status_attributes (x_item_type             => itemtype,
                            x_item_key              => itemkey,
                            x_success_proj_stus_code =>l_success_status_code,
                            x_failure_proj_stus_code =>l_failure_status_code,
                            x_err_code              => l_err_code,
                            x_err_stage             => l_err_stage
         );

IF (l_err_code < 0)
 THEN
    WF_CORE.CONTEXT('PA_PROJECT_WF','GET_PROJ_STATUS_ATTRIBUTES',itemtype, itemkey, to_char(actid), funcmode);
    RAISE FND_API.G_EXC_ERROR;
ELSIF (l_err_code > 0)
   THEN
    resultout := wf_engine.eng_completed||':'||'F';
    WF_CORE.CONTEXT('PA_PROJECT_WF','GET_PROJ_STATUS_ATTRIBUTES',itemtype, itemkey, to_char(actid), funcmode);
 PA_WORKFLOW_UTILS.Set_Notification_Messages
    (p_item_type    => itemtype
    , p_item_key    => itemkey
    );
   RETURN;
END IF;

/* Bug 2345889 Part 2- Begin */

l_resp_id := wf_engine.GetItemAttrNumber
            (itemtype   => itemtype,
             itemkey    => itemkey,
             aname      => 'RESPONSIBILITY_ID' );

l_project_approver_id := wf_engine.GetItemAttrNumber
               (itemtype => itemtype,
                itemkey  => itemkey,
                aname    => 'PROJECT_APPROVER_ID');

l_proj_stus_code := wf_engine.GetItemAttrText
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'PROJECT_STATUS_CODE' );

   /* Adding the following check so that if approver is not null then user_id
      should be set as the approver_id and not as workflow_started_by_id */
IF l_project_approver_id is NOT NULL THEN
     FND_GLOBAL.Apps_Initialize
        (   user_id                => l_project_approver_id
          , resp_id             => l_resp_id
          , resp_appl_id        => pa_workflow_utils.get_application_id(l_resp_id)
        );
ELSE
     Pa_workflow_utils.Set_Global_Attr (p_item_type => itemtype,
                                   p_item_key  => itemkey,
                                   p_err_code  => l_err_code);
END IF;

OPEN l_proj_system_status_csr(l_proj_stus_code);
FETCH l_proj_system_status_csr INTO l_proj_system_status_code;
CLOSE l_proj_system_status_csr;

 /* Note that for the above cursor call, no need of checking cursor
    NOT FOUND or catching any exceptions because it is already
    checked in Get_proj_status_attributes. If any error comes then
    execution will not come to this point */

OPEN l_proj_system_status_csr(l_success_status_code);
FETCH l_proj_system_status_csr INTO l_proj_success_sys_sts_code;
CLOSE l_proj_system_status_csr;

  /* l_success_status_code can be null, so no need of checking cursor NOT FOUND  */

/* Bug 2345889 Part 2- End*/

l_project_id     := wf_engine.GetItemAttrNumber
               ( itemtype   => itemtype,
         itemkey    => itemkey,
             aname      => 'PROJECT_ID');

Validate_Changes (x_project_id              => l_project_id,
                  x_success_status_code     => l_success_status_code,
          x_err_code                => l_err_code,
                  x_err_stage               => l_err_stage,
                  x_wf_enabled_flag         => l_wf_enabled_flag,
                  x_verify_ok_flag          => l_verify_ok_flag );

-- Bug 7534431
IF l_proj_system_status_code = l_proj_success_sys_sts_code THEN
  l_wf_enabled_flag := 'N';
END IF;

IF l_verify_ok_flag = 'Y' THEN
   resultout := wf_engine.eng_completed||':'||'T';
   IF l_wf_enabled_flag = 'Y' THEN

       /* Bug 2345889 Part-3 Begin*/
      /* Commenting out this code and adding the code below instead*/
/*
-- -------------------------------------------------------------------------------------
-- 02-DEC-97, jwhite: added wf_status_code and where clause
-- to this update.

      UPDATE pa_projects
      SET    project_status_code = l_success_status_code,
             wf_status_code      = 'IN_ROUTE'
      WHERE  project_id = l_project_id;
-- -------------------------------------------------------------------------------------
*/

          IF l_proj_system_status_code <> 'CLOSED' THEN
               IF l_proj_success_sys_sts_code = 'CLOSED' THEN
                   UPDATE pa_projects_all /* Bug#6367069 replaced PA_PROJECTS with PA_PROJECTS_ALL */
                   SET    project_status_code = l_success_status_code,
                          wf_status_code      = 'IN_ROUTE',
                          closed_date        = sysdate,
                          last_update_date    = sysdate,
                          last_updated_by     = fnd_global.user_id,
                          last_update_login   = fnd_global.login_id
                   WHERE  project_id = l_project_id;
               ELSE
                   UPDATE  pa_projects_all /* Bug#6367069 replaced PA_PROJECTS with PA_PROJECTS_ALL */
                   SET    project_status_code = l_success_status_code,
                          wf_status_code      = 'IN_ROUTE',
                          last_update_date    = sysdate,
                          last_updated_by     = fnd_global.user_id,
                          last_update_login   = fnd_global.login_id
                   WHERE  project_id = l_project_id;
               END IF;
           ELSE
           IF l_proj_success_sys_sts_code = 'CLOSED' THEN
                   UPDATE pa_projects_all /* Bug#6367069 replaced PA_PROJECTS with PA_PROJECTS_ALL */
                   SET    project_status_code = l_success_status_code,
                          wf_status_code      = 'IN_ROUTE',
                          last_update_date    = sysdate,
                          last_updated_by     = fnd_global.user_id,
                          last_update_login   = fnd_global.login_id
                   WHERE  project_id = l_project_id;
           ELSE
                   UPDATE  pa_projects_all /* Bug#6367069 replaced PA_PROJECTS with PA_PROJECTS_ALL */
                   SET    project_status_code = l_success_status_code,
                          wf_status_code      = 'IN_ROUTE',
                          closed_date        = null,
                          last_update_date    = sysdate,
                          last_updated_by     = fnd_global.user_id,
                          last_update_login   = fnd_global.login_id
                   WHERE  project_id = l_project_id;
               END IF;
          END IF;
         /* Bug 2345889 Part-3 End*/

      Start_Project_Wf (p_project_id  => l_project_id,
                        p_err_stack   => l_err_stack,
                        p_err_stage   => l_err_stage,
                        p_err_code    => l_err_code );
ELSE
      resultout := wf_engine.eng_completed||':'||'T';

       /* Bug 2345889 Part-4 Begin*/
      /* Commenting out this code and adding the code below instead*/
      /*
      UPDATE pa_projects
      SET    project_status_code = l_success_status_code,
             wf_status_code      = NULL
      WHERE  project_id = l_project_id;
      */
      IF l_proj_system_status_code <> 'CLOSED' THEN
         IF l_proj_success_sys_sts_code = 'CLOSED' THEN
         UPDATE pa_projects_all /* Bug#6367069 replaced PA_PROJECTS with PA_PROJECTS_ALL */
         SET    project_status_code = l_success_status_code,
            wf_status_code      = NULL,
            closed_date         = sysdate,
            last_update_date    = sysdate,
            last_updated_by     = fnd_global.user_id,
            last_update_login   = fnd_global.login_id
         WHERE  project_id = l_project_id;
     ELSE
             UPDATE pa_projects_all /* Bug#6367069 replaced PA_PROJECTS with PA_PROJECTS_ALL */
         SET    project_status_code = l_success_status_code,
            wf_status_code      = NULL,
	    closed_date         = null, --bug#8586702
            last_update_date    = sysdate,
            last_updated_by     = fnd_global.user_id,
            last_update_login   = fnd_global.login_id
         WHERE  project_id = l_project_id;
     END IF;
      ELSE
         IF l_proj_success_sys_sts_code = 'CLOSED' THEN
             UPDATE pa_projects_all /* Bug#6367069 replaced PA_PROJECTS with PA_PROJECTS_ALL */
         SET    project_status_code = l_success_status_code,
            wf_status_code      = NULL,
            last_update_date    = sysdate,
            last_updated_by     = fnd_global.user_id,
            last_update_login   = fnd_global.login_id
         WHERE  project_id = l_project_id;
     ELSE
             UPDATE pa_projects_all /* Bug#6367069 replaced PA_PROJECTS with PA_PROJECTS_ALL */
         SET    project_status_code = l_success_status_code,
            wf_status_code      = NULL,
            closed_date         = null,
            last_update_date    = sysdate,
            last_updated_by     = fnd_global.user_id,
            last_update_login   = fnd_global.login_id
         WHERE  project_id = l_project_id;
     END IF;
      END IF;
       /* Bug 2345889 Part-4 End*/
  END IF;

/* Stubbed out Auto-Initiate Demand On Project Approval Functionality
   Bug 3819086 -Hence Commenting Out Following Code */

/* Bug 3611598 Place call to the wrapper API which will invoke Concurrent Process to Initiate Demand ,If the Project Status is Approved*/
/*
  IF nvl(l_proj_system_status_code,'-99') = 'APPROVED' THEN

       -- 3671408 Added below code to retrieve project number
       OPEN  c_project_details(l_project_id) ;
       FETCH c_project_details INTO l_project_number ;
       CLOSE c_project_details;

       PA_Actions_Pub.RUN_ACTION_CONC_PROCESS_WRP
                    (
                       p_project_id         => l_project_id
                       -- 3671408 added p_project_number IN parameter and passing retrieved project number
                       ,p_project_number    => l_project_number
                       ,x_msg_count         => l_msg_count
                       ,x_msg_data          => l_err_stack
                       ,x_return_status     => l_return_status
                    );
       IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
            RAISE   FND_API.G_EXC_ERROR;
       END IF;
  END IF;
End Commenting for Bug 3819086 */

/* Code Added for bug 7299466*/
        DECLARE
               l_rowid                 VARCHAR2(255);
               l_obj_status_change_id  NUMBER;
               l_old_sys_status        VARCHAR2(30);
               l_new_sys_status        VARCHAR2(30);
               l_note                   VARCHAR2(2000);

               CURSOR cur_get_system_status(c_status_code IN VARCHAR2) IS
               SELECT pps.project_system_status_code
               FROM   pa_project_statuses pps
               WHERE  pps.project_status_code = nvl(c_status_code,' ');

           BEGIN

                l_note := wf_engine.GetItemAttrText( itemtype       => itemtype,
                                                     itemkey        => itemkey,
                                                     aname          => 'NOTE' );

                SELECT pa_obj_status_changes_s.NEXTVAL INTO l_obj_status_change_id
                FROM dual;

                OPEN  cur_get_system_status(l_success_status_code);
                FETCH cur_get_system_status INTO l_new_sys_status;
                CLOSE cur_get_system_status;

                OPEN  cur_get_system_status(l_proj_stus_code);
                FETCH cur_get_system_status INTO l_old_sys_status;
                CLOSE cur_get_system_status;

                --For inserting status change comment into the status history table
                PA_OBJ_STATUS_CHANGES_PKG.INSERT_ROW
                ( X_ROWID                        => l_rowid,
                  X_OBJ_STATUS_CHANGE_ID         => l_obj_status_change_id,
                  X_OBJECT_TYPE                  => 'PA_PROJECTS',
                  X_OBJECT_ID                    => l_project_id,
                  X_STATUS_TYPE                  => 'PROJECT',
                  X_NEW_PROJECT_STATUS_CODE      => l_success_status_code,
                  X_NEW_PROJECT_SYSTEM_STATUS_CO => l_new_sys_status,
                  X_OLD_PROJECT_STATUS_CODE      => l_proj_stus_code,
                  X_OLD_PROJECT_SYSTEM_STATUS_CO => l_old_sys_status,
                  X_CHANGE_COMMENT               => l_note,
                  X_LAST_UPDATED_BY              => fnd_global.user_id,
                  X_CREATED_BY                   => fnd_global.user_id,
                  X_CREATION_DATE                => sysdate,
                  X_LAST_UPDATE_DATE             => sysdate,
                  X_LAST_UPDATE_LOGIN            => fnd_global.user_id);

           END;
/* End of code for 7299466*/

ELSE
    resultout := wf_engine.eng_completed||':'||'F';
    Wf_Status_failure    (x_project_id           => l_project_id,
                          x_failure_status_code  => l_failure_status_code,
                          x_item_type            => itemtype,
                          x_item_key             => itemkey,
                          x_update_db_YN         => 'Y',
                          x_populate_msg_yn      => 'Y',
                          x_err_code             => l_err_code );
 END IF;


 PA_WORKFLOW_UTILS.Set_Notification_Messages
    (p_item_type    => itemtype
    , p_item_key    => itemkey
    );


EXCEPTION

WHEN FND_API.G_EXC_ERROR
    THEN
WF_CORE.CONTEXT('PA_PROJECT_WF','SET_SUCCESS_STATUS',itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

WHEN OTHERS
  THEN
    WF_CORE.CONTEXT('PA_PROJECT_WF','SET_SUCCESS_STATUS',itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

END Set_Success_status;

PROCEDURE Set_Failure_status
  (itemtype                      IN      VARCHAR2
  ,itemkey                       IN      VARCHAR2
  ,actid                         IN      NUMBER
  ,funcmode                      IN      VARCHAR2
  ,resultout                     OUT     NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895

l_err_code  NUMBER := 0;
l_success_status_code   VARCHAR2(30);
l_failure_status_code   VARCHAR2(30);
l_err_stage VARCHAR2(2000);
l_project_id NUMBER := 0;
BEGIN
        -- Return if WF Not Running
        --
        IF(funcmode <> wf_engine.eng_run) THEN
                --
                resultout := wf_engine.eng_null;
                RETURN;
        END IF;
Get_proj_status_attributes (x_item_type             => itemtype,
                            x_item_key              => itemkey,
                            x_success_proj_stus_code =>l_success_status_code,
                            x_failure_proj_stus_code =>l_failure_status_code,
                            x_err_code              => l_err_code,
                            x_err_stage             => l_err_stage );

IF (l_err_code < 0)
-- Don't Check for positive error codes because there isn't any notification to display the
-- business rule messages.
 THEN
    WF_CORE.CONTEXT('PA_PROJECT_WF','GET_PROJ_STATUS_ATTRIBUTES',itemtype, itemkey, to_char(actid), funcmode);
    RAISE FND_API.G_EXC_ERROR;
END IF;

Pa_workflow_utils.Set_Global_Attr (p_item_type => itemtype,
                                   p_item_key  => itemkey,
                                   p_err_code  => l_err_code);
l_project_id     := wf_engine.GetItemAttrNumber
               ( itemtype   => itemtype,
         itemkey    => itemkey,
             aname      => 'PROJECT_ID');
-- Call wf status failure.We only need to update the database
-- No need to populate the message notifications

Wf_Status_failure    (x_project_id           => l_project_id,
                      x_failure_status_code  => l_failure_status_code,
                      x_item_type            => itemtype,
                      x_item_key             => itemkey,
                      x_update_db_YN         => 'Y',
                      x_populate_msg_yn      => 'N',
                      x_err_code             => l_err_code );
resultout := wf_engine.eng_completed||':'||'F';

/* Code Added for bug 7299466*/
        DECLARE
               l_rowid                 VARCHAR2(255);
               l_obj_status_change_id  NUMBER;
               l_old_sys_status        VARCHAR2(30);
               l_new_sys_status        VARCHAR2(30);
               l_note                   VARCHAR2(2000);
               l_proj_stus_code         VARCHAR2(30);

               CURSOR cur_get_system_status(c_status_code IN VARCHAR2) IS
               SELECT pps.project_system_status_code
               FROM   pa_project_statuses pps
               WHERE  pps.project_status_code = nvl(c_status_code,' ');

           BEGIN

                l_note := wf_engine.GetItemAttrText( itemtype       => itemtype,
                                                     itemkey        => itemkey,
                                                     aname          => 'NOTE' );

                l_proj_stus_code := wf_engine.GetItemAttrText(  itemtype       => itemtype,
                                                                itemkey        => itemkey,
                                                                aname          => 'PROJECT_STATUS_CODE' );

                SELECT pa_obj_status_changes_s.NEXTVAL INTO l_obj_status_change_id
                FROM dual;

                OPEN  cur_get_system_status(l_failure_status_code);
                FETCH cur_get_system_status INTO l_new_sys_status;
                CLOSE cur_get_system_status;

                OPEN  cur_get_system_status(l_proj_stus_code);
                FETCH cur_get_system_status INTO l_old_sys_status;
                CLOSE cur_get_system_status;

                --For inserting status change comment into the status history table
                PA_OBJ_STATUS_CHANGES_PKG.INSERT_ROW
                ( X_ROWID                        => l_rowid,
                  X_OBJ_STATUS_CHANGE_ID         => l_obj_status_change_id,
                  X_OBJECT_TYPE                  => 'PA_PROJECTS',
                  X_OBJECT_ID                    => l_project_id,
                  X_STATUS_TYPE                  => 'PROJECT',
                  X_NEW_PROJECT_STATUS_CODE      => l_failure_status_code,
                  X_NEW_PROJECT_SYSTEM_STATUS_CO => l_new_sys_status,
                  X_OLD_PROJECT_STATUS_CODE      => l_proj_stus_code,
                  X_OLD_PROJECT_SYSTEM_STATUS_CO => l_old_sys_status,
                  X_CHANGE_COMMENT               => l_note,
                  X_LAST_UPDATED_BY              => fnd_global.user_id,
                  X_CREATED_BY                   => fnd_global.user_id,
                  X_CREATION_DATE                => sysdate,
                  X_LAST_UPDATE_DATE             => sysdate,
                  X_LAST_UPDATE_LOGIN            => fnd_global.user_id);

           END;
/* End of code for 7299466*/

EXCEPTION

WHEN FND_API.G_EXC_ERROR
    THEN
WF_CORE.CONTEXT('PA_PROJECT_WF','SET_FAILURE_STATUS',itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

WHEN OTHERS
  THEN
    WF_CORE.CONTEXT('PA_PROJECT_WF','SET_FAILURE_STATUS',itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

END Set_Failure_status;

PROCEDURE Verify_status_change_rules
  (itemtype                      IN      VARCHAR2
  ,itemkey                       IN      VARCHAR2
  ,actid                         IN      NUMBER
  ,funcmode                      IN      VARCHAR2
  ,resultout                     OUT     NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895
l_err_code  NUMBER := 0;
l_success_status_code   VARCHAR2(30);
l_failure_status_code   VARCHAR2(30);
l_err_stage VARCHAR2(2000);
l_project_id NUMBER := 0;
l_wf_enabled_flag VARCHAR2(1);
l_verify_ok_flag  VARCHAR2(1);

BEGIN
        -- Return if WF Not Running
        --
        IF(funcmode <> wf_engine.eng_run) THEN
                --
                resultout := wf_engine.eng_null;
                RETURN;
                --
        END IF;

Get_proj_status_attributes (x_item_type             => itemtype,
                            x_item_key              => itemkey,
                            x_success_proj_stus_code =>l_success_status_code,
                            x_failure_proj_stus_code =>l_failure_status_code,
                            x_err_code              => l_err_code,
                            x_err_stage             => l_err_stage );

IF (l_err_code < 0)
 THEN
    WF_CORE.CONTEXT('PA_PROJECT_WF','GET_PROJ_STATUS_ATTRIBUTES',itemtype, itemkey, to_char(actid), funcmode);
    RAISE FND_API.G_EXC_ERROR;
ELSIF (l_err_code > 0)
   THEN
    resultout := wf_engine.eng_completed||':'||'F';
    WF_CORE.CONTEXT('PA_PROJECT_WF','GET_PROJ_STATUS_ATTRIBUTES',itemtype, itemkey, to_char(actid), funcmode);
 PA_WORKFLOW_UTILS.Set_Notification_Messages
    (p_item_type    => itemtype
    , p_item_key    => itemkey
    );
   RETURN;
END IF;

Pa_workflow_utils.Set_Global_Attr (p_item_type => itemtype,
                                   p_item_key  => itemkey,
                                   p_err_code  => l_err_code);
l_project_id     := wf_engine.GetItemAttrNumber( itemtype   => itemtype,
                 itemkey    => itemkey,
                     aname      => 'PROJECT_ID'
                    );

Validate_Changes (x_project_id              => l_project_id,
                  x_success_status_code     => l_success_status_code,
          x_err_code                => l_err_code,
                  x_err_stage               => l_err_stage,
                  x_wf_enabled_flag         => l_wf_enabled_flag,
                  x_verify_ok_flag          => l_verify_ok_flag );

IF l_verify_ok_flag = 'Y' THEN
   resultout := wf_engine.eng_completed||':'||'T';
ELSE
   resultout := wf_engine.eng_completed||':'||'F';
Wf_Status_failure (x_project_id           => l_project_id,
                      x_failure_status_code  => l_failure_status_code,
                      x_item_type            => itemtype,
                      x_item_key             => itemkey,
                      x_update_db_YN         => 'N',
                      x_populate_msg_yn      => 'Y',
                      x_err_code             => l_err_code );
END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR
    THEN
WF_CORE.CONTEXT('PA_PROJECT_WF','VERIFY_STATUS_CHANGE_RULES',itemtype, itemkey, to_char(actid), funcmode);
     RAISE;

WHEN OTHERS THEN
     WF_CORE.CONTEXT('PA_PROJECT_WF','VERIFY_STATUS_CHANGE_RULES',itemtype, itemkey, to_char(actid), funcmode);
     RAISE;

END Verify_status_change_rules;

PROCEDURE Wf_Status_failure (x_project_id IN NUMBER,
                             x_failure_status_code IN VARCHAR2,
                             x_item_type IN VARCHAR2,
                             x_item_key  IN VARCHAR2,
                             x_populate_msg_yn IN VARCHAR2,
                             x_update_db_yn IN VARCHAR2,
                             x_err_code  OUT NOCOPY NUMBER ) IS --File.Sql.39 bug 4440895
BEGIN
     x_err_code := 0;
     IF x_update_db_yn = 'Y' THEN
        UPDATE pa_projects_all /* Bug#6367069 replaced PA_PROJECTS with PA_PROJECTS_ALL */
        SET project_status_code = x_failure_status_code,
            Wf_Status_code      = NULL
        WHERE project_id = x_project_id;

     END IF;
    IF x_populate_msg_yn = 'Y' THEN
       pa_workflow_utils.set_notification_messages
                 (p_item_type => x_item_type,
                  p_item_key  => x_item_key );
    END IF; -- x_populate_msg_yn = 'Y'

EXCEPTION
WHEN OTHERS
  THEN
    WF_CORE.CONTEXT('PA_PROJECT_WF','WF_STATUS_FAILURE', x_item_type, x_item_key);
    RAISE;

END Wf_Status_failure;


PROCEDURE Get_proj_status_attributes (x_item_type IN VARCHAR2,
                                      x_item_key  IN VARCHAR2,
                                      x_success_proj_stus_code OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                      x_failure_proj_stus_code OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                      x_err_code  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                      x_err_stage OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
l_proj_stus_code  VARCHAR2(30);

CURSOR l_proj_stus_csr IS
SELECT wf_success_status_code,
       wf_failure_status_code
FROM   pa_project_statuses
WHERE  project_status_code = l_proj_stus_code;
BEGIN
    x_err_code := 0;
    x_success_proj_stus_code := NULL;
    x_failure_proj_stus_code := NULL;
l_proj_stus_code := wf_engine.GetItemAttrText
               ( itemtype   => x_item_type,
         itemkey    => x_item_key,
             aname      => 'PROJECT_STATUS_CODE' );

IF l_proj_stus_code IS NOT NULL THEN
   OPEN l_proj_stus_csr;
   FETCH l_proj_stus_csr INTO
         x_success_proj_stus_code,
         x_failure_proj_stus_code;
   IF l_proj_stus_csr%NOTFOUND THEN
      CLOSE l_proj_stus_csr;
      x_err_code := 10;
      x_err_stage := 'PA_PROJECT_STATUS_INVALID';
PA_UTILS.Add_Message
    ( p_app_short_name  => 'PA'
      , p_msg_name      => 'PA_PROJECT_STATUS_INVALID'
    );
      RETURN;
   ELSE
      CLOSE l_proj_stus_csr;
   END IF ;
ELSE
      x_err_code := 10;
      x_err_stage := 'PA_ITEM_ATTR_NOT_SET';
PA_UTILS.Add_Message
    ( p_app_short_name  => 'PA'
      , p_msg_name      => 'PA_ITEM_ATTR_NOT_SET'
    );
      RETURN;
END IF;

EXCEPTION
WHEN OTHERS
  THEN
    x_err_code := SQLCODE;
    WF_CORE.CONTEXT('PA_PROJECT_WF','GET_PROJ_STATUS_ATTRIBUTES', x_item_type, x_item_key);
    RAISE;

END Get_proj_status_attributes;

PROCEDURE  validate_changes  (x_project_id            IN NUMBER,
                              x_success_status_code   IN VARCHAR2,
                              x_err_code             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stage            OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_wf_enabled_flag      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_verify_ok_flag       OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

l_verify_ok_flag  VARCHAR2(1);
l_wf_enabled_flag VARCHAR2(1);
l_err_stack    VARCHAR2(2000);
l_err_msg_count  NUMBER := 0;
l_warnings_only_flag  VARCHAR2(1);
l_err_code NUMBER;
l_err_stage VARCHAR2(2000);


CURSOR l_project_csr IS
SELECT * FROM pa_projects_all /* Bug#6367069 replaced PA_PROJECTS with PA_PROJECTS_ALL */
WHERE project_id = x_project_id;
l_project_rec l_project_csr%ROWTYPE;

BEGIN
--dbms_output.put_line('VALIDATE_CHANGES - INSIDE');

OPEN l_project_csr;
FETCH l_project_csr INTO l_project_rec;
IF l_project_csr%NOTFOUND THEN
   CLOSE l_project_csr;
   x_err_code := 10;
   x_err_stage := 'PA_PROJECT_ID_INVALID';
   RETURN;
END IF;

CLOSE l_project_csr;

--dbms_output.put_line('CALL HANDLE_PROJECT_STATUS_CHANGE');


Pa_project_stus_utils.Handle_Project_Status_Change
                 (x_calling_module       => 'PAPROJWF'
                 ,X_project_id           => x_project_id
                 ,X_old_proj_status_code => l_project_rec.project_status_code
                 ,X_new_proj_status_code => x_success_status_code
                 ,X_project_type         => l_project_rec.project_type
                 ,X_project_start_date   => l_project_rec.start_date
                 ,X_project_end_date     => l_project_rec.completion_date
                 ,X_public_sector_flag   => l_project_rec.public_sector_flag
                 ,X_attribute_category   => l_project_rec.attribute_category
                 ,X_attribute1           => l_project_rec.attribute1
                 ,X_attribute2           => l_project_rec.attribute2
                 ,X_attribute3           => l_project_rec.attribute3
                 ,X_attribute4           => l_project_rec.attribute4
                 ,X_attribute5           => l_project_rec.attribute5
                 ,X_attribute6           => l_project_rec.attribute6
                 ,X_attribute7           => l_project_rec.attribute7
                 ,X_attribute8           => l_project_rec.attribute8
                 ,X_attribute9           => l_project_rec.attribute9
                 ,X_attribute10          => l_project_rec.attribute10
                 ,X_pm_product_code      => l_project_rec.pm_product_code
                 ,x_init_msg             => 'Y'
                 ,x_verify_ok_flag       => l_verify_ok_flag
                 ,x_wf_enabled_flag      => l_wf_enabled_flag
                 ,X_err_stage            => l_err_stage
                 ,X_err_stack            => l_err_stack
                 ,x_err_msg_count        => l_err_msg_count
                 ,x_warnings_only_flag   => l_warnings_only_flag
     );

--dbms_output.put_line('AFTER HANDLE_PROJECT_STATUS_CHANGE');


x_verify_ok_flag  := l_verify_ok_flag;
x_wf_enabled_flag := l_wf_enabled_flag;

--dbms_output.put_line('LAST LINE OF VALIDATE_CHANGES');


EXCEPTION
 WHEN OTHERS THEN
    x_err_code := SQLCODE ;
        WF_CORE.CONTEXT('PA_PROJECT_WF ','VALIDATE_CHANGES');
        RAISE;

END Validate_Changes;

END pa_project_wf;

/
