--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_PROJECT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_PROJECT_WF" AS
/* $Header: PAWFPCEB.pls 120.2.12010000.2 2008/09/17 06:56:41 sugupta ship $ */

-- ===================================================
--
--Name:               Select_Project_Approver
--Type:                 Procedure
--Description:      This client extension returns the project_approver ID
--              to the calling PA_PROJECT_WF Select_Project_Approver
--              procedure.
--
--
--Called subprograms: none.
--
--
--
--History:
--      24-FEB-1997       L. de Werker          - Created
--      06-OCT-97       jwhite          - Updated as required per
--                                         unit testing.
--
-- IN
--   p_project_id                       - unique identifier for the project that needs approval
--   p_workflow_started_by_id   - identifies the user that triggered the workflow
--
-- OUT
--   p_project_approver_id      - unique identifier of the employee
--                                (employee_id in per_people_f table)
--                                that must approve this project
--
PROCEDURE Select_Project_Approver
 (p_project_id                  IN NUMBER
  , p_workflow_started_by_id    IN NUMBER
  , p_project_approver_id               OUT NOCOPY NUMBER  --File.Sql.39 bug 4440895
)
--
IS
/*
   You can use this procedure to add any additional rules to determine
   who can approve a project. This procedure is being used by the
   Workflow APIs and determine who the approver for a project
   should be. By default this procedure fetches the supervisor of the
   person who initiated the workflow as the approver.
*/
--
l_employee_id NUMBER;
--
CURSOR l_employee_csr IS
SELECT  employee_id
FROM    fnd_user
WHERE   user_id = p_workflow_started_by_id;

CURSOR l_approver_csr IS
SELECT supervisor_id
FROM    per_assignments_f
WHERE    person_id = l_employee_id
/*AND   Assignment_type ='E'                          -- Added this condition for bug 2911451*/ --Commented by avaithia Bug # 3448680
AND Assignment_type IN ('E','C')           --Included 'C' also in Assignment_type Bug # 3448680
AND   Primary_flag ='Y'                             -- Added this condition for bug 2911451
AND TRUNC(sysdate) BETWEEN EFFECTIVE_START_DATE
AND NVL(EFFECTIVE_END_DATE, sysdate);

BEGIN

OPEN l_employee_csr;
FETCH l_employee_csr INTO l_employee_id;
CLOSE l_employee_csr;
IF l_employee_id IS NOT NULL THEN
   OPEN l_approver_csr;
   FETCH l_approver_csr INTO p_project_approver_id;
   CLOSE l_approver_csr;
END IF;


--
--The following algorithm can be used to handle known error conditions
--When this code is used the arguments and there values will be displayed
--in the error message that is send by workflow.
--
--IF <error condition>
--THEN
--      WF_CORE.TOKEN('ARG1', arg1);
--      WF_CORE.TOKEN('ARGn', argn);
--      WF_CORE.RAISE('ERROR_NAME');
--END IF;

EXCEPTION

WHEN OTHERS THEN
       WF_CORE.CONTEXT('PA_CLIENT_EXTN_PROJECT_WF ','SELECT_PROJECT_APPROVER');
        RAISE;

END Select_Project_Approver;

-- ===================================================
--Name:         Start_Project_WF
--Type:                 Procedure
--Description:  This procedure instantiates the Project workflow.
--
--
--Called Subprograms:   none.
--
-- Notes:
--

-- History:
--      XX-AUTUMN-97rkrishna            - Created.
--
--      28-OCT-97       jwhite          - Updated as per latest WF
--                                         standards.
--      30-OCT-97       jwhite          - Added project_status_successs_code
--                                        as a WF attribute.
--      03-NOV-97       jwhite          -  Added workflow-started-date
--                                         to Start_Project_WF procedure.
--      25-NOV-97       jwhite          - Replaced call to set_global_info
--                                         with FND_GLOBAL.Apps_Initialize
--                                         to drop linkage to AMG license
--                                         Did NOT replace with Set_Global_Attr
--                                         because WF NOT exist yet.
--      17-NOV-08       sugupta        - Bug 6720288 : Added handling for the
--                                        item attribute NOTE which corresponds
--                                        to the change comment
--


PROCEDURE Start_Project_Wf (p_project_id    IN NUMBER
                          , p_item_type     IN VARCHAR2
                          , p_process       IN VARCHAR2
                          , p_out_item_key OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                          , p_err_stack    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                          , p_err_stage    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                          , p_err_code     OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
                          , p_status_type  IN  VARCHAR2 DEFAULT 'PROJECT') IS


-- !!!THIS EXTENSION IS CALLED FROM either a
--      straight PL/SQL package or WORKFLOW!!!
--
--
-- This procedure starts the workflow process for project status changes
-- Do not add/delete/modify the parameters to this procedure
-- If you need to use a different item_type and process to start the
-- workflow, please use the Project Statuses form to specify that information
-- against the relevant project status
-- Any new item type attributes you may add,need to be populated
-- using SetItemAttr calls. Make sure that you have a thorough understanding
-- of the Oracle Workflow product and how to use PL/SQL with Workflow.

CURSOR l_project_csr    ( l_project_id NUMBER )
IS
SELECT  pm_project_reference
,       segment1
,       name
,       description
,       project_type
,       pm_product_code
,       carrying_out_organization_id
,       project_status_code
,       template_flag -- Bug 6875403
FROM    pa_projects
WHERE   project_id = l_project_id;
--
CURSOR  l_organization_csr ( l_carrying_out_organization_id NUMBER )
IS
SELECT  name
FROM    hr_organization_units
WHERE   organization_id = l_carrying_out_organization_id;
--
CURSOR  l_project_type_class( l_project_type VARCHAR2)
IS
SELECT  project_type_class_code
FROM    pa_project_types
WHERE   project_type = l_project_type;
--
CURSOR  l_starter_name_csr( l_starter_user_id NUMBER )
IS
SELECT  user_name
FROM    fnd_user
WHERE   user_id = l_starter_user_id;

-- 5078716 For R12 Performance Fix, changed cursor select query
-- Removed pa_employee view usage with base tables , the query
-- to retrieve name is taken from function
-- PA_RESOURCE_UTILS.get_person_name_no_date
/*
CURSOR  l_starter_full_name_csr(l_starter_user_id NUMBER )
IS
SELECT  e.first_name||' '||e.last_name
FROM    fnd_user f, pa_employees e
WHERE   f.user_id = l_starter_user_id
AND     f.employee_id = e.person_id;
*/

CURSOR  l_starter_full_name_csr(l_starter_user_id NUMBER )
IS
SELECT  e.first_name||' '||e.last_name
FROM    fnd_user f, per_all_people_f e
WHERE   f.user_id = l_starter_user_id
AND     f.employee_id = e.person_id
and     e.effective_end_date = ( SELECT
                                        MAX(papf.effective_end_date)
                                 FROM   per_all_people_f papf
                                 WHERE  papf.person_id = e.person_id);

-- 5078716 end

-- Project Status Codes and Name Cursors ----------------------------------------

-- Get Success and Failure Status codes for Current Project Status Code
CURSOR l_project_status_csr(l_project_status_code VARCHAR2)
IS
SELECT project_status_name
        , wf_success_status_code
        , wf_failure_status_code
FROM   pa_project_statuses
WHERE  project_status_code = l_project_status_code;

-- Get Success Status Name
CURSOR l_wf_success_status_name_csr(l_wf_success_status_code VARCHAR2)
IS
SELECT project_status_name
FROM   pa_project_statuses
WHERE  project_status_code = l_wf_success_status_code;

-- Get Failure Status Name
CURSOR l_wf_failure_status_name_csr(l_wf_failure_status_code VARCHAR2)
IS
SELECT project_status_name
FROM   pa_project_statuses
WHERE  project_status_code = l_wf_failure_status_code;
-- -------------------------------------------------------------------------------------

-- Get System Date for Worflow-Started-Date
CURSOR l_wf_started_date_csr
IS
SELECT sysdate
FROM    sys.dual;

	 -- Get the change comment
 	 CURSOR l_change_comment_csr(l_project_id NUMBER)
 	 IS
 	 SELECT change_comment FROM (
 	         SELECT change_comment
 	         FROM pa_obj_status_changes
 	         WHERE object_type = 'PA_PROJECTS'
 	         AND object_id = l_project_id
 	         AND new_project_status_code =
 	                 (SELECT project_status_code
 	                  FROM pa_projects_all
 	                  WHERE project_id = l_project_id)
 	         ORDER BY obj_status_change_id DESC
 	 )
 	 WHERE rownum = 1;


--

--
ItemKey         varchar2(30);
ItemType        varchar2(30);

l_pm_project_reference          varchar2(30);
l_pa_project_number             varchar2(30);
l_project_name                  varchar2(30);
l_description                   varchar2(250);
l_project_type                  varchar2(20);
l_pm_product_code               varchar2(30);
l_carrying_out_org_id           number;
/* Bug No:- 2487147, UTF8 change : changed l_carrying_out_org_name to %TYPE */
/* l_carrying_out_org_name              varchar2(60); */
l_carrying_out_org_name         hr_organization_units.name%TYPE;
l_project_type_class_code       varchar2(30);

l_project_status_code                      pa_project_statuses.project_status_code%TYPE;
l_wf_success_status_code                pa_project_statuses.project_status_code%TYPE;
l_wf_failure_status_code                pa_project_statuses.project_status_code%TYPE;

l_project_status_name                     pa_project_statuses.project_status_name%TYPE;
l_wf_success_status_name                pa_project_statuses.project_status_name%TYPE;
l_wf_failure_status_name                pa_project_statuses.project_status_name%TYPE;

l_wf_started_date                       DATE;


l_workflow_started_by_id                number;
l_user_full_name                        varchar(400); /* Bug no. 2487147:- UTF8 changes: changed the length of l_user_full_name from 240 to 400 */
l_user_name                             varchar(240);
l_resp_id                       number;

l_msg_count             NUMBER;
l_msg_data              VARCHAR(2000);
l_return_status         VARCHAR2(1);
l_api_version_number    NUMBER          := 1.0;
l_data                  VARCHAR2(2000);
l_msg_index_out         NUMBER;

l_change_comment        pa_obj_status_changes.change_comment%TYPE;

--
--

l_url                   VARCHAR2(2000); --Bug 6875403
l_template_flag         VARCHAR2(1);    --Bug 6875403

BEGIN

  p_err_code := 0;
--get the unique identifier for this specific workflow

ItemType := p_item_type;

SELECT pa_workflow_itemkey_s.nextval
INTO itemkey
from dual;

-- Need this to populate the attribute information in Workflow
l_workflow_started_by_id := FND_GLOBAL.user_id;
l_resp_id := FND_GLOBAL.resp_id;

--dbms_output.put_line('set_global_info');

-- Based on the Responsibility, Intialize the Application
-- Cannot use Set_Global_Attr here because the WF
--  Does NOT exits yet.
FND_GLOBAL.Apps_Initialize
        (user_id                => l_workflow_started_by_id
          , resp_id             => l_resp_id
          , resp_appl_id        => fnd_global.resp_appl_id
        );

-- Create the workflow process
--dbms_output.put_line('wf_engine.CreateProcess');

wf_engine.CreateProcess( ItemType => ItemType,
                         ItemKey  => ItemKey,
                         process  => p_process
                        );

p_out_item_key := ItemKey;
OPEN  l_starter_name_csr(l_workflow_started_by_id );
FETCH l_starter_name_csr INTO l_user_name;
CLOSE l_starter_name_csr;

OPEN  l_starter_full_name_csr(l_workflow_started_by_id );
FETCH l_starter_full_name_csr INTO l_user_full_name;
CLOSE l_starter_full_name_csr;

OPEN l_project_csr(p_project_id);
FETCH l_project_csr INTO l_pm_project_reference
                        ,l_pa_project_number
                        ,l_project_name
                        ,l_description
                        ,l_project_type
                        ,l_pm_product_code
                        ,l_carrying_out_org_id
                        ,l_project_status_code
                        ,l_template_flag; -- Bug 6875403
CLOSE l_project_csr;

OPEN l_organization_csr( l_carrying_out_org_id );
FETCH l_organization_csr INTO l_carrying_out_org_name;
CLOSE l_organization_csr;

OPEN l_project_type_class( l_project_type );
FETCH l_project_type_class INTO l_project_type_class_code;
CLOSE l_project_type_class;

OPEN l_project_status_csr(l_project_status_code);
FETCH l_project_status_csr INTO l_project_status_name
                                        , l_wf_success_status_code
                                        , l_wf_failure_status_code;
CLOSE l_project_status_csr;

OPEN l_wf_success_status_name_csr(l_wf_success_status_code);
FETCH l_wf_success_status_name_csr INTO l_wf_success_status_name;
CLOSE l_wf_success_status_name_csr;

OPEN l_wf_failure_status_name_csr(l_wf_failure_status_code);
FETCH l_wf_failure_status_name_csr INTO l_wf_failure_status_name;
CLOSE l_wf_failure_status_name_csr;

OPEN l_wf_started_date_csr;
FETCH l_wf_started_date_csr INTO l_wf_started_date;
CLOSE l_wf_started_date_csr;


OPEN l_change_comment_csr(p_project_id);
FETCH l_change_comment_csr INTO l_change_comment;
CLOSE l_change_comment_csr;

-- -----------------------------------------------------------------------------------
-- Initialize Workflow Item Attributes
-- -----------------------------------------------------------------------------------

        wf_engine.SetItemAttrNumber (itemtype   => itemtype,
                                     itemkey    => itemkey,
                                     aname      => 'PROJECT_ID',
                                     avalue     =>  p_project_id
                                    );

        wf_engine.SetItemAttrText (itemtype     => itemtype,
                                   itemkey      => itemkey,
                                   aname        => 'PM_PROJECT_REFERENCE',
                                   avalue       =>  l_pm_project_reference
                                    );

        wf_engine.SetItemAttrText (itemtype     => itemtype,
                                   itemkey      => itemkey,
                                   aname        => 'PA_PROJECT_NUMBER',
                                   avalue       =>  l_pa_project_number
                                    );

        wf_engine.SetItemAttrText (itemtype     => itemtype,
                                   itemkey      => itemkey,
                                   aname        => 'PROJECT_NAME',
                                   avalue       =>  l_project_name
                                    );

        wf_engine.SetItemAttrText (itemtype     => itemtype,
                                   itemkey      => itemkey,
                                   aname        => 'PROJECT_DESCRIPTION',
                                   avalue       =>  l_description
                                  );

        wf_engine.SetItemAttrText (itemtype     => itemtype,
                                   itemkey      => itemkey,
                                   aname        => 'PROJECT_TYPE',
                                   avalue       =>  l_project_type
                                   );

        wf_engine.SetItemAttrText (itemtype     => itemtype,
                                   itemkey      => itemkey,
                                   aname        => 'PM_PROJECT_PRODUCT_CODE',
                                   avalue       => l_pm_product_code
                                   );

        wf_engine.SetItemAttrNumber (itemtype   => itemtype,
                                     itemkey    => itemkey,
                                     aname      => 'CARRYING_OUT_ORG_ID',
                                     avalue     =>  l_carrying_out_org_id
                                    );

        wf_engine.SetItemAttrText (itemtype     => itemtype,
                                   itemkey      => itemkey,
                                   aname        => 'CARRYING_OUT_ORG_NAME',
                                   avalue       =>  l_carrying_out_org_name
                                    );

        wf_engine.SetItemAttrText (itemtype     => itemtype,
                                   itemkey      => itemkey,
                                   aname        => 'PROJECT_TYPE_CLASS_CODE',
                                   avalue       =>  l_project_type_class_code
                                   );

		 wf_engine.SetItemAttrText (itemtype        => itemtype,
									itemkey        => itemkey,
									aname        => 'NOTE',
									avalue        =>  l_change_comment
										);

        wf_engine.SetItemAttrNumber (itemtype   => itemtype,
                                     itemkey    => itemkey,
                                     aname      => 'WORKFLOW_STARTED_BY_ID',
                                     avalue     =>  l_workflow_started_by_id
                                    );

        wf_engine.SetItemAttrText (itemtype     => itemtype,
                                   itemkey      => itemkey,
                                   aname        => 'WORKFLOW_STARTED_BY_NAME',
                                   avalue       =>  l_user_name
                                );

               wf_engine.SetItemAttrText (itemtype     => itemtype,
                                   itemkey      => itemkey,
                                   aname        =>
                                                'WORKFLOW_STARTED_BY_FULL_NAME',
                                   avalue       =>  l_user_full_name
                                );

        wf_engine.SetItemAttrNumber (itemtype   => itemtype,
                                     itemkey    => itemkey,
                                     aname      => 'RESPONSIBILITY_ID',
                                     avalue     =>  l_resp_id
                                );

        wf_engine.SetItemAttrText (itemtype     => itemtype,
                                   itemkey      => itemkey,
                                   aname        => 'PROJECT_STATUS_CODE',
                                   avalue       =>  l_project_status_code
                                );

        wf_engine.SetItemAttrText (itemtype     => itemtype,
                                   itemkey      => itemkey,
                                   aname        => 'PROJECT_STATUS_NAME',
                                   avalue               => l_project_status_name
                                );

        wf_engine.SetItemAttrText (itemtype     => itemtype,
                                   itemkey      => itemkey,
                                   aname        => 'WF_SUCCESS_STATUS_CODE',
                                   avalue               => l_wf_success_status_code
                                );


        wf_engine.SetItemAttrText (itemtype     => itemtype,
                                   itemkey      => itemkey,
                                   aname        => 'WF_SUCCESS_STATUS_NAME',
                                   avalue               => l_wf_success_status_name
                                );

        wf_engine.SetItemAttrText (itemtype     => itemtype,
                                   itemkey      => itemkey,
                                   aname        => 'WF_FAILURE_STATUS_CODE',
                                   avalue               => l_wf_failure_status_code
                                );


        wf_engine.SetItemAttrText (itemtype     => itemtype,
                                   itemkey      => itemkey,
                                   aname        => 'WF_FAILURE_STATUS_NAME',
                                   avalue               => l_wf_failure_status_name
                                );

        wf_engine.SetItemAttrText (itemtype     => itemtype,
                                   itemkey      => itemkey,
                                   aname        => 'WF_STARTED_DATE',
                                   avalue               => l_wf_started_date
                                );


        --Bug 6875403
        If (nvl(l_template_flag,'N') = 'N') Then
         l_url := 'JSP:/OA_HTML/OA.jsp?OAFunc=PA_PROJ_HOME'
                   ||'&'||'paProjectId='||p_project_id
                   ||'&'||'addBreadCrumb=Y';
        Else
          l_url := 'JSP:/OA_HTML/OA.jsp?OAFunc=PA_PAXPREPR_TEMPLATE_SS'
                   ||'&'||'paProjectId='||p_project_id
                   ||'&'||'addBreadCrumb=Y';
        End If;


        wf_engine.SetItemAttrText( itemtype
                                      , itemkey
                                      , 'PROJECT_SSWA_URL'
                                      , l_url
        	  );

  	    --Bug 6875403


--dbms_output.put_line('wf_engine.StartProcess');
        --
        wf_engine.StartProcess(         itemtype        => itemtype,
                                        itemkey         => itemkey );
        --

EXCEPTION

WHEN FND_API.G_EXC_ERROR
        THEN
WF_CORE.CONTEXT('PA_CLIENT_EXTN_PROJECT_WF ','START_PROJECT_WF', itemtype, itemkey);
                RAISE;


WHEN FND_API.G_EXC_UNEXPECTED_ERROR
          THEN
                p_err_code      := SQLCODE;
WF_CORE.CONTEXT('PA_CLIENT_EXTN_PROJECT_WF ','START_PROJECT_WF', itemtype, itemkey);
                RAISE;

 WHEN OTHERS
          THEN
                p_err_code      := SQLCODE;
WF_CORE.CONTEXT('PA_CLIENT_EXTN_PROJECT_WF ','START_PROJECT_WF', itemtype, itemkey);
                RAISE;

END Start_Project_Wf;
-- ====================================================
END pa_client_extn_project_wf;

/
