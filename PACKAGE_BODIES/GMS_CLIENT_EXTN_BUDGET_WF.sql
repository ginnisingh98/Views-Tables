--------------------------------------------------------
--  DDL for Package Body GMS_CLIENT_EXTN_BUDGET_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_CLIENT_EXTN_BUDGET_WF" AS
/* $Header: gmsfbceb.pls 120.3 2006/05/23 05:26:29 smaroju noship $ */

-- -------------------------------------------------------------------------------------
--	GLOBALS
-- -------------------------------------------------------------------------------------

G_API_VERSION_NUMBER 	CONSTANT NUMBER := 1.0;
-- To check on, whether to print debug messages in log file or not
L_DEBUG varchar2(1) := NVL(FND_PROFILE.value('GMS_ENABLE_DEBUG_MODE'), 'N');

-- -------------------------------------------------------------------------------------
--	PROCEDURES
-- -------------------------------------------------------------------------------------

--
--Name:        	IS_BUDGET_WF_USED
--Type:         Procedure
--Description:  This procedure must return a "T" or "F" depending on whether a workflow
--		should be started for this particular budget.
--
--
--Called Subprograms:	none.
--
--Notes:
--	This client extension is called directly from the Budgets form and the public
--	Baseline_Budget API (actually, from a wrapper with the same name).
--
--	This extension is NOT called form workflow!
--
--	Error messages in the form and public API call  the 'GMS_WF_CLIENT_EXTN'
--	error code. Two tokens are passed to the error message: the name of this
--	client extension and the error code.
--
--
--
--
--History:
--
--
-- IN Parameters
--   p_project_id		- Unique identifier for the project of the budget for which approval
--				  is requested.
--   p_award_id			- Unique identifier for the award of the budget for which approval
--				  is requested.
--   p_budget_type_code		- Unique identifier for  budget submitted for approval
--   p_pm_product_code		- The PM vendor's product code stored in gms_budget_versions.
--
-- OUT NOCOPY Parameters
--   p_result    		- 'T' or 'F' (True/False)
--   p_err_code			-  Standard error code: 0, Success; x < 0, Unexpected Error;
--				   x > 0, Business Rule Violated.
--   p_err_stage		-   Standard error message
--   p_err_stack		-   Not used.
--





PROCEDURE IS_BUDGET_WF_USED
( p_project_id 			IN 	NUMBER
, p_award_id			IN	NUMBER
, p_budget_type_code		IN 	VARCHAR2
, p_pm_product_code		IN 	VARCHAR2
, p_result			IN OUT NOCOPY VARCHAR2
, p_err_code             	IN OUT NOCOPY	NUMBER
, p_err_stage			IN OUT NOCOPY	VARCHAR2
, p_err_stack			IN OUT NOCOPY	VARCHAR2
)

IS
/*
You can use this procedure to add/modify the conditions to enable
workflow for budget status changes. By default, Oracle Projects enables
and launches workflow based on the Budget Type and Project type setup.
You can choose to override these conditions with your own conditions

*/


--  check if WF is enabled for the Award Budget

	CURSOR	l_award_csr (p_award_id NUMBER)
	IS
	SELECT	budget_wf_enabled_flag
	FROM	gms_awards
	WHERE	award_id = p_award_id;

	l_budget_wf_enabled_flag 	gms_awards.budget_wf_enabled_flag%TYPE 	:= 'N';

 BEGIN

-- dbms_output.put_line('GMS_CLIENT_EXTN_BUDGET_WF.IS_BUDGET_WF_USED - start');

     -- Initialize The Output Parameters

     p_err_code := 0;
     p_result := 'F';

     -- Enter Your Business Rules Here.Or, Use The
     -- Provided Default.

	OPEN l_award_csr (p_award_id);
	FETCH l_award_csr INTO l_budget_wf_enabled_flag;
	CLOSE l_award_csr ;

	IF (l_budget_wf_enabled_flag = 'Y')
	THEN
		p_result := 'T';
	ELSE
		p_result := 'F';
	END IF;

-- dbms_output.put_line('BUDGET_WF_USED - RESULT = '||p_result);


 EXCEPTION

     WHEN OTHERS THEN
       -- Add your exception handler here.
       -- To raise an ORACLE error, assign SQLCODE to p_error_code
	p_err_code := SQLCODE;
	RAISE;

 END IS_BUDGET_WF_USED;
--------------------------------------------------------------------------------------------

-- Name: 		START_BUDGET_WF
-- Type:               	Procedure
-- Description:      	This procedure is used to start a workflow process to approve
--			and baseline a budget.
--
--
-- Called subprograms:	none.
--
--
--
-- History:
--
--
-- IN Parameters
--   p_project_id		- Unique identifier for the project of the budget for which approval
--				   is requested.
--   p_budget_type_code		- Unique identifier for  budget submitted for approval
--   p_mark_as_original		- Yes, mark budget as original; N, do not mark. Defaults to 'N'.
--
-- OUT NOCOPY Parameters
--   p_err_code			-  Standard error code: 0, Success; x < 0, Unexpected Error;
--				   x > 0, Business Rule Violated.
--   p_err_stage			-   Standard error message
--   p_err_stack			-   Not used.
--


PROCEDURE START_BUDGET_WF
(p_draft_version_id	IN	NUMBER
, p_project_id 		IN 	NUMBER
, p_award_id 		IN 	NUMBER
, p_budget_type_code	IN 	VARCHAR2
, p_mark_as_original	IN 	VARCHAR2
, p_item_type           OUT NOCOPY	VARCHAR2
, p_item_key           	OUT NOCOPY	VARCHAR2
, p_err_code            IN OUT NOCOPY	NUMBER
, p_err_stage         	IN OUT NOCOPY	VARCHAR2
, p_err_stack         	IN OUT NOCOPY	VARCHAR2
)

IS
--Notes:
--	This client extension is called directly from the Budgets form and the public
--	Baseline_Budget API (actually, from a wrapper with the same name).
--
--	!!!THIS EXTENSION IS NOT CALLED FROM WORKFLOW!!!
--
--	Error messages in the form and public API call  the 'GMS_WF_CLIENT_EXTN'
--	error code. Two tokens are passed to the error message: the name of this
--	client extension and the error code.
--
-- CAUTION:
--
--	This is a working client extension. It is designed to start the
--	GMSBUDWF Budget workflow. If you make changes to this
--	procedure, you must properly populate the OUT-parameters,
--	particularly the p_item_type and p_item_key OUT-parameters.
--
--      	Also, if you want to use a different item type or process ,you must
--      	change the value for the variable ItemType and the
--      	change the value for the parameter "process" in the
--      	call to wf_engine.Create_Process.
--      	Make sure that you have a thorough understanding
--      	of the Oracle Workflow product and how to use PL/SQL with Workflow.
--
CURSOR l_award_csr
		( p_award_id NUMBER)
IS
SELECT award_number
     , award_short_name
  FROM gms_awards   -- gms_awards_v -- Bug 4004577
 WHERE award_id	= p_award_id;

--

CURSOR l_baselined_csr
    		( p_project_id NUMBER
		, p_award_id NUMBER
    		, p_budget_type_code VARCHAR2 )
IS
SELECT 'x'
FROM   gms_budget_versions
WHERE project_id 		= p_project_id
AND   award_id			= p_award_id
AND   budget_type_code 		= p_budget_type_code
AND   budget_status_code	= 'B';

--
CURSOR l_project_csr	( p_project_id NUMBER )
IS
SELECT 	pm_project_reference
,	segment1
,	name
,	description
,	project_type
,	pm_product_code
,	carrying_out_organization_id
FROM	pa_projects
WHERE   project_id = p_project_id;
--

CURSOR 	l_organization_csr ( p_carrying_out_organization_id NUMBER )
IS
SELECT	name
FROM 	hr_organization_units
WHERE	  organization_id = p_carrying_out_organization_id;
--
CURSOR	l_project_type_class( p_project_type VARCHAR2)
IS
SELECT	project_type_class_code
FROM	pa_project_types
WHERE  	project_type = p_project_type;
--
CURSOR 	l_starter_user_name_csr( p_starter_user_id NUMBER )
IS
SELECT 	user_name
FROM	fnd_user
WHERE 	user_id = p_starter_user_id;
--
CURSOR	l_starter_full_name_csr(p_starter_user_id NUMBER )
IS
SELECT  p.first_name||' '||p.last_name
FROM    fnd_user f, per_people_f p      /*Bug 5122724 */
where p.effective_start_date = (select
min(pp.effective_start_date) from per_all_people_f pp where pp.person_id =
p.person_id and pp.effective_end_date >=trunc(sysdate)) and
((p.employee_number is not null) or (p.npw_number is not null))
and f.user_id = p_starter_user_id
and f.employee_id = p.person_id;
/* Replaced below sql with above sql for Bug 5122724
SELECT	e.first_name||' '||e.last_name
FROM	fnd_user f, per_all_people_f e  --pa_employees e  Commented for Bug5067575, SQLId:16329634
WHERE 	f.user_id = p_starter_user_id
AND	f.employee_id = e.person_id
AND	rownum=1;  -- Added for Bug5067575, SQLId:16329634 */
--
CURSOR l_budget_csr( p_project_id NUMBER
		    ,p_award_id NUMBER
		    ,p_budget_type_code VARCHAR2 )
IS
SELECT	pm_budget_reference
,	description
,	change_reason_code
,	budget_entry_method_code
,	pm_product_code
,	labor_quantity
,	raw_cost
,	burdened_cost
,	revenue
,	resource_list_id
,	budget_version_id
,	version_name
FROM 	gms_budget_versions
WHERE	project_id = p_project_id
AND	award_id = p_award_id
AND	budget_type_code = p_budget_type_code
--AND 	budget_status_code = 'S'; -- Modified on 20-May-2000
AND 	budget_status_code in ('S','W');
--

CURSOR l_resource_list_csr( p_resource_list_id NUMBER )
IS
SELECT	name
,	description
FROM	pa_resource_lists
WHERE 	resource_list_id = p_resource_list_id;
--
CURSOR l_budget_type_csr( p_budget_type_code VARCHAR2 )
IS
SELECT	budget_type
FROM	pa_budget_types
WHERE	budget_type_code = p_budget_type_code;

CURSOR l_wf_notification_role_csr(p_award_id NUMBER)
IS
SELECT	user_id, user_name
FROM 	gms_notifications_v
WHERE	award_id = p_award_id
AND 	event_type = 'BUDGET_BASELINE';

-- Get System Date for Worflow-Started-Date
CURSOR l_wf_started_date_csr
IS
SELECT sysdate
FROM 	sys.dual;

ItemType	varchar2(30) := 'GMSWF';  --<----Identifies the workflow process!!!
ItemKey		varchar2(30);

l_award_id			gms_awards.award_id%TYPE;
l_award_number			gms_awards.award_number%TYPE;
l_award_short_name		gms_awards.award_short_name%TYPE;

l_pm_project_reference		pa_projects.pm_project_reference%TYPE;
l_pa_project_number		pa_projects.segment1%TYPE;
l_project_name			pa_projects.name%TYPE;
l_description			pa_projects.description%TYPE;
l_project_type			pa_projects.project_type%TYPE;
l_pm_project_product_code	pa_projects.pm_product_code%TYPE;
l_carrying_out_org_id		NUMBER;
l_carrying_out_org_name		hr_organization_units.name%TYPE;
l_project_type_class_code	pa_project_types.project_type_class_code%TYPE;

l_pm_budget_reference		gms_budget_versions.pm_budget_reference%TYPE;
l_budget_description		gms_budget_versions.description%TYPE;
l_budget_change_reason_code	gms_budget_versions.change_reason_code%TYPE;
l_budget_entry_method_code	gms_budget_versions.budget_entry_method_code%TYPE;
l_pm_budget_product_code	gms_budget_versions.pm_product_code%TYPE;
l_mark_as_original 		gms_budget_versions.original_flag%TYPE;
l_budget_version_id		gms_budget_versions.budget_version_id%TYPE;
l_version_name			gms_budget_versions.version_name%TYPE;

l_total_labor_hours		NUMBER;
l_total_raw_cost		NUMBER;
l_total_burdened_cost		NUMBER;
l_total_revenue			NUMBER;
l_resource_list_id		NUMBER;
l_resource_list_name		pa_resource_lists.name%TYPE;
l_resource_list_description	pa_resource_lists.description%TYPE;
l_budget_type			pa_budget_types.budget_type%TYPE;
l_wf_started_date		DATE;

l_workflow_started_by_id	NUMBER;
l_starter_name			VARCHAR2(240);
l_starter_full_name		VARCHAR2(240);

l_user_id			NUMBER;
l_user_name			VARCHAR2(240);
l_role_name			VARCHAR2(100);
l_role_name_disp		VARCHAR2(100); -- fix for NOCOPY related same variable passed to 2 paramters.
--Start Bug 2204122 Changed the width of l_user_roles to 32000 from 4000--
l_user_roles      VARCHAR2(32000);
--End Bug 2204122--
l_resp_id			NUMBER;
l_resp_appl_id			NUMBER;
l_row_found 			VARCHAR2(1);

l_api_version_number		NUMBER	:= G_api_version_number ;
l_msg_count			NUMBER;
l_msg_data			VARCHAR(2000);
l_return_status			VARCHAR2(1)		:= NULL;
l_data				VARCHAR2(2000);
l_msg_index_out			NUMBER;
l_err_code   			NUMBER 		:= 0;
l_err_stage  			VARCHAR2(100);
l_err_stack  			VARCHAR2(100);

WF_API_EXCEPTION 		EXCEPTION;
pragma exception_init(WF_API_EXCEPTION, -20002);


BEGIN

    IF L_DEBUG = 'Y' THEN
    	gms_error_pkg.gms_debug('GMS_CLIENT_EXTN_BUDGET_WF.START_BUDGET_WF - start', 'C');
    END IF;

--  Standard BEGIN of API savepoint

    SAVEPOINT START_BUDGET_WF_pvt;

--  Set API Return Status To Success for Public API and Form Error Processing

    p_err_code 	:= 0;


       BEGIN
-- --------------------------------------------------------------------------------------
--	Initialize Globals for Starting Approve Budget Workflow
-- --------------------------------------------------------------------------------------

             l_workflow_started_by_id := FND_GLOBAL.user_id;

             OPEN l_starter_user_name_csr( l_workflow_started_by_id );
             FETCH l_starter_user_name_csr INTO l_starter_name;
             CLOSE l_starter_user_name_csr;

             OPEN l_starter_full_name_csr( l_workflow_started_by_id );
             FETCH l_starter_full_name_csr INTO l_starter_full_name;
             CLOSE l_starter_full_name_csr;

             l_resp_id := FND_GLOBAL.resp_id;
             l_resp_appl_id := FND_GLOBAL.resp_appl_id;

-- Based on the Responsibility, Intialize the Application
-- Cannot call Set_Global_Attr here because the WF does NOT
-- Exist yet.

FND_GLOBAL.Apps_Initialize
	(user_id         	=> l_workflow_started_by_id
	  , resp_id         	=> l_resp_id
	  , resp_appl_id	=> l_resp_appl_id);


-- Mark-As-Original Flag Set From IN-Parameter

     l_mark_as_original := p_mark_as_original;

      -- Bug 4004577
      If GMS_SECURITY.ALLOW_QUERY(p_award_id) = 'Y' Then

         OPEN l_award_csr (p_award_id);
         FETCH l_award_csr INTO l_award_number
      	                      , l_award_short_name;
         CLOSE l_award_csr;

      End If;

      OPEN l_project_csr(p_project_id);
      FETCH l_project_csr INTO l_pm_project_reference
			,l_pa_project_number
			,l_project_name
			,l_description
			,l_project_type
			,l_pm_project_product_code
			,l_carrying_out_org_id;
       CLOSE l_project_csr;

       OPEN l_budget_type_csr( p_budget_type_code );
       FETCH l_budget_type_csr INTO l_budget_type;
       CLOSE l_budget_type_csr;

       OPEN l_organization_csr( l_carrying_out_org_id );
       FETCH l_organization_csr INTO l_carrying_out_org_name;
       CLOSE l_organization_csr;

       OPEN l_project_type_class( l_project_type );
       FETCH l_project_type_class INTO l_project_type_class_code;
       CLOSE l_project_type_class;

       OPEN l_budget_csr( p_project_id, p_award_id, p_budget_type_code );
       FETCH l_budget_csr INTO  l_pm_budget_reference
			,l_budget_description
			,l_budget_change_reason_code
			,l_budget_entry_method_code
			,l_pm_budget_product_code
			,l_total_labor_hours
			,l_total_raw_cost
			,l_total_burdened_cost
			,l_total_revenue
			,l_resource_list_id
			,l_budget_version_id
			,l_version_name;

       CLOSE l_budget_csr;

       OPEN l_resource_list_csr( l_resource_list_id );
       FETCH l_resource_list_csr INTO l_resource_list_name
			      ,l_resource_list_description;
       CLOSE l_resource_list_csr;

       OPEN l_wf_started_date_csr;
       FETCH l_wf_started_date_csr INTO l_wf_started_date;
       CLOSE l_wf_started_date_csr;

--------------------------------------------------------------------------------
-- Creating Role and Users required for GMS Workflow process; based on data in
-- GMS_NOTIFICATIONS_V table/view.

       OPEN l_wf_notification_role_csr(p_award_id);
       LOOP
       		FETCH l_wf_notification_role_csr INTO l_user_id, l_user_name;
--Start Bug Fix 2204122--
--The Exit statement should get executed first, Else the last USERID gets repeated--

		EXIT WHEN l_wf_notification_role_csr%NOTFOUND;
                --Start Bug Fix 3224843
                IF GMS_WF_PKG.Excl_Person_From_Notification(p_award_id, l_user_id) = 'N'  THEN
       		   l_user_roles :=  (l_user_roles||','||l_user_name);
                END IF;
                --End Bug Fix 3224843
       --exit when l_wf_notification_role_csr%NOTFOUND;
--End 	Bug Fix 2204122--
	   END LOOP;
       CLOSE l_wf_notification_role_csr;

       -- In order to remove an extra comma that is preceding l_user_roles
	if substr(l_user_roles, 1, 1) = ','
	then
		l_user_roles := substr(l_user_roles, 2, (length(l_user_roles)-1));
	end if;

	l_role_name := p_award_id||'-BUDGET';
	l_role_name_disp := l_role_name;

	IF L_DEBUG = 'Y' THEN
		gms_error_pkg.gms_debug('GMS_CLIENT_EXTN_BUDGET_WF.START_BUDGET_WF - l_role_name = '||l_role_name, 'C');
	END IF;
--Bug 2204122 Commented the following line--
--Procedure call_gms_debug called to print the same in the log file--
--	gms_error_pkg.gms_debug('GMS_CLIENT_EXTN_BUDGET_WF.START_BUDGET_WF - l_user_roles = '||l_user_roles, 'C');
   	gms_client_extn_budget_wf.call_gms_debug(p_user_roles => l_user_roles
   						,p_disp_text =>'GMS_CLIENT_EXTN_BUDGET_WF.START_BUDGET_WF - l_user_roles = ') ;
--End Bug 2204122--
	IF L_DEBUG = 'Y' THEN
		gms_error_pkg.gms_debug('GMS_CLIENT_EXTN_BUDGET_WF.START_BUDGET_WF - creating Adhoc role..', 'C');
	END IF;

   	BEGIN
   		wf_directory.CreateAdhocRole( role_name => l_role_name,
   					      role_display_name => l_role_name_disp,
   					      language => 'AMERICAN',
   					      territory => 'AMERICA',
   					      notification_preference => 'MAILHTML');
	EXCEPTION
	WHEN WF_API_EXCEPTION
	THEN
		NULL;
	END;

	-- Purging all the existing users (if any) in the above created role.

	IF L_DEBUG = 'Y' THEN
		gms_error_pkg.gms_debug('GMS_CLIENT_EXTN_BUDGET_WF.START_BUDGET_WF - removing users from Adhoc role..', 'C');
	END IF;

	wf_directory.RemoveUsersFromAdhocRole(role_name => l_role_name);

	-------------------------------------------------------------------------------------------------------------
	-- If there is atleast one user defined in GMS_NOTIFICATIONS_V for this award
	-- then
	-- add the user to the above created role.
	-- else
	-- raise exception since WF will fail while looking for users to send notifications to.
	-------------------------------------------------------------------------------------------------------------

	IF l_user_roles IS NOT NULL
	THEN
		IF L_DEBUG = 'Y' THEN
			gms_error_pkg.gms_debug('GMS_CLIENT_EXTN_BUDGET_WF.START_BUDGET_WF - adding users to Adhoc role..', 'C');
		END IF;
		BEGIN
		--Start Bug 2204122--

		gms_client_extn_budget_wf.call_wf_addusers_to_adhocrole(p_user_roles => l_user_roles ,
		       						        p_role_name  => l_role_name ) ;
		/*wf_directory.AddUsersToAdhocRole(role_name => l_role_name,
                                     		 role_users => l_user_roles);*/
                --End Bug 2204122--
	    EXCEPTION
		  WHEN WF_API_EXCEPTION
		  THEN
		  NULL;
	    END ;

	ELSE
		IF L_DEBUG = 'Y' THEN
			gms_error_pkg.gms_debug('GMS_CLIENT_EXTN_BUDGET_WF.START_BUDGET_WF - Exception: No users found for this role.', 'C');
		END IF;
		gms_error_pkg.gms_message( x_err_name => 'GMS_FND_USER_NOT_CREATED',
					x_err_code => l_err_code,
					x_err_buff => l_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;

--------------------------------------------------------------------------------

       SELECT gms_workflow_itemkey_s.nextval
       INTO ItemKey
       from dual;


        EXCEPTION

	WHEN FND_API.G_EXC_ERROR
	THEN
		ROLLBACK TO START_BUDGET_WF_pvt;
		RAISE;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
		p_err_code 	:= SQLCODE;
		ROLLBACK TO START_BUDGET_WF_pvt;
		RAISE;

	 WHEN OTHERS THEN
		p_err_code 	:= SQLCODE;
		ROLLBACK TO START_BUDGET_WF_pvt;
		RAISE;


     END;

     BEGIN
-- ------------------------------------------------------------------------------------
-- INSTANTIATE BUDGET WORKFLOW
-- ------------------------------------------------------------------------------------
-- NOTE:
-- The process name passed here is the root process for the
--  'GMS Workflow Process'. The Selector procedure may override
--  the process name specified here. However, the default
--  GMS_WF procedure does not call the Selector procedure.
-- ------------------------------------------------------------------------------------

	IF L_DEBUG = 'Y' THEN
		gms_error_pkg.gms_debug('GMS_CLIENT_EXTN_BUDGET_WF.START_BUDGET_WF - Calling wf_engine.CreateProcess..', 'C');
	END IF;

	wf_engine.CreateProcess( ItemType => ItemType,
				 ItemKey  => ItemKey,
				 process  => 'GMS_WF_PROCESS' );

	IF L_DEBUG = 'Y' THEN
		gms_error_pkg.gms_debug('GMS_CLIENT_EXTN_BUDGET_WF.START_BUDGET_WF - Setting Item Attributes..', 'C');
	END IF;


-- attribute GMS_WF_PROCESS is used to select the appropriate branch
-- in the workflow process.

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'GMS_WF_PROCESS',
					avalue		=>  'BUDGET' );

	wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'AWARD_ID',
					avalue		=>  p_award_id);

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'AWARD_NUMBER',
					avalue		=>  l_award_number);

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'AWARD_SHORT_NAME',
					avalue		=>  l_award_short_name);

	wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'PROJECT_ID',
					avalue		=>  p_project_id);

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'PM_PROJECT_REFERENCE',
					avalue		=>  l_pm_project_reference );

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'PA_PROJECT_NUMBER',
					avalue		=>  l_pa_project_number );

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'PROJECT_NAME',
					avalue		=>  l_project_name );

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'PROJECT_DESCRIPTION',
					avalue		=>  l_description );

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'PROJECT_TYPE',
					avalue		=>  l_project_type );

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'PM_PROJECT_PRODUCT_CODE',
					avalue		=>  l_pm_project_product_code );

	wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'CARRYING_OUT_ORG_ID',
					avalue		=>  l_carrying_out_org_id);

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'CARRYING_OUT_ORG_NAME',
					avalue		=>  l_carrying_out_org_name);

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'PROJECT_TYPE_CLASS_CODE',
					avalue		=>  l_project_type_class_code);

	wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'WORKFLOW_STARTED_BY_ID',
					avalue		=>  l_workflow_started_by_id);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'WORKFLOW_STARTED_BY_NAME',
					avalue		=>  l_starter_name);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'WORKFLOW_STARTED_BY_FULL_NAME',
					avalue		=>  l_starter_full_name);


	wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'RESPONSIBILITY_ID',
					avalue		=>  l_resp_id);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'BUDGET_TYPE_CODE',
					avalue		=>  p_budget_type_code);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'BUDGET_TYPE',
					avalue		=>  l_budget_type);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'PM_BUDGET_REFERENCE',
					avalue		=>  l_pm_budget_reference);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'BUDGET_DESCRIPTION',
					avalue		=>  l_budget_description);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'CHANGE_REASON_CODE',
					avalue		=>  l_budget_change_reason_code);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'BUDGET_ENTRY_METHOD',
					avalue		=>  l_budget_entry_method_code);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'PM_BUDGET_PRODUCT_CODE',
					avalue		=>  l_pm_budget_product_code);

	wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'TOTAL_LABOR_HOURS',
					avalue		=>  l_total_labor_hours);

	wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'TOTAL_RAW_COST',
					avalue		=>  l_total_raw_cost);

	wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'TOTAL_BURDENED_COST',
					avalue		=>  l_total_burdened_cost);

	wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'RESOURCE_LIST_ID',
					avalue		=>  l_resource_list_id);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'RESOURCE_LIST_NAME',
					avalue		=>  l_resource_list_name);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'RESOURCE_LIST_DESCRIPTION',
					avalue		=>  l_resource_list_description);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'MARK_AS_ORIGINAL',
					avalue		=>  l_mark_as_original);


	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'NOTIF_RECIPIENT_ROLE',
					avalue		=>  l_role_name);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'FC_MODE',
					avalue		=>  'S');

	wf_engine.SetItemAttrDate (	itemtype	=> itemtype,
	      			   	itemkey  	=> itemkey,
 	      			   	aname 		=> 'WF_STARTED_DATE',
				   	avalue		=> l_wf_started_date
				);

	--
	IF L_DEBUG = 'Y' THEN
		gms_error_pkg.gms_debug('GMS_CLIENT_EXTN_BUDGET_WF.START_BUDGET_WF - Calling wf_engine.StartProcess..', 'C');
	END IF;

	wf_engine.StartProcess( 	itemtype	=> itemtype,
	      				itemkey		=> itemkey );

	IF L_DEBUG = 'Y' THEN
		gms_error_pkg.gms_debug('GMS_CLIENT_EXTN_BUDGET_WF.START_BUDGET_WF - After wf_engine.StartProcess', 'C');
	END IF;

-- -----------------------------------------------------------------------------------
-- CAUTION: These two OUT-Parameters must be populated
--          properly in order for the calling procedures
--	    to work as designed.
-- ------------------------------------------------------------------------------------

	p_item_type	:= itemtype;
	p_item_key	:= itemkey;

-- -------------------------------------------------------------------------------------

	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR
	THEN
		WF_CORE.CONTEXT(' GMS_CLIENT_EXTN_BUDGET_WF ','START_BUDGET_WF', itemtype, itemkey);
		RAISE;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
		WF_CORE.CONTEXT(' GMS_CLIENT_EXTN_BUDGET_WF ','START_BUDGET_WF', itemtype, itemkey);
		p_err_code 	:= SQLCODE;
		RAISE;

	WHEN OTHERS
	 THEN
		WF_CORE.CONTEXT(' GMS_CLIENT_EXTN_BUDGET_WF ','START_BUDGET_WF', itemtype, itemkey);
		p_err_code 	:= SQLCODE;
		RAISE;

	END;

END START_BUDGET_WF;


--------------------------------------------------------------------------------------------

-- Name: 		START_BUDGET_WF_NTFY_ONLY
-- Type:               	Procedure
-- Description:
--
--
--
-- Called subprograms:	none.
--
--
--
-- History:
--
--
-- IN Parameters
--   p_project_id		- Unique identifier for the project of the budget for which approval
--				   is requested.
--   p_budget_type_code		- Unique identifier for  budget submitted for approval
--   p_mark_as_original		- Yes, mark budget as original; N, do not mark. Defaults to 'N'.
--
-- OUT NOCOPY Parameters
--   p_err_code			-  Standard error code: 0, Success; x < 0, Unexpected Error;
--				   x > 0, Business Rule Violated.
--   p_err_stage			-   Standard error message
--   p_err_stack			-   Not used.
--


PROCEDURE START_BUDGET_WF_NTFY_ONLY
(p_draft_version_id	IN	NUMBER
, p_project_id 		IN 	NUMBER
, p_award_id 		IN 	NUMBER
, p_budget_type_code	IN 	VARCHAR2
, p_mark_as_original	IN 	VARCHAR2
, p_item_type           OUT NOCOPY	VARCHAR2
, p_item_key           	OUT NOCOPY	VARCHAR2
, p_err_code            IN OUT NOCOPY	NUMBER
, p_err_stage         	IN OUT NOCOPY	VARCHAR2
, p_err_stack         	IN OUT NOCOPY	VARCHAR2
)

IS
--Notes:
--	This client extension is called directly from the Budgets form and the public
--	Baseline_Budget API (actually, from a wrapper with the same name).
--
--	!!!THIS EXTENSION IS NOT CALLED FROM WORKFLOW!!!
--
--	Error messages in the form and public API call  the 'GMS_WF_CLIENT_EXTN'
--	error code. Two tokens are passed to the error message: the name of this
--	client extension and the error code.
--
-- CAUTION:
--
--	This is a working client extension. It is designed to start the
--	GMSBUDWF Budget workflow. If you make changes to this
--	procedure, you must properly populate the OUT-parameters,
--	particularly the p_item_type and p_item_key OUT-parameters.
--
--      	Also, if you want to use a different item type or process ,you must
--      	change the value for the variable ItemType and the
--      	change the value for the parameter "process" in the
--      	call to wf_engine.Create_Process.
--      	Make sure that you have a thorough understanding
--      	of the Oracle Workflow product and how to use PL/SQL with Workflow.
--
CURSOR l_award_csr
		( p_award_id NUMBER)
IS
  SELECT award_number
        ,award_short_name
    FROM gms_awards  -- gms_awards_v -- Bug 4004577
   WHERE award_id = p_award_id;
--

CURSOR l_baselined_csr
    		( p_project_id NUMBER
		, p_award_id NUMBER
    		, p_budget_type_code VARCHAR2 )
IS
SELECT 'x'
FROM   gms_budget_versions
WHERE project_id 		= p_project_id
AND   award_id			= p_award_id
AND   budget_type_code 		= p_budget_type_code
AND   budget_status_code	= 'B';

--
CURSOR l_project_csr	( p_project_id NUMBER )
IS
SELECT 	pm_project_reference
,	segment1
,	name
,	description
,	project_type
,	pm_product_code
,	carrying_out_organization_id
FROM	pa_projects
WHERE   project_id = p_project_id;
--

CURSOR 	l_organization_csr ( p_carrying_out_organization_id NUMBER )
IS
SELECT	name
FROM 	hr_organization_units
WHERE	  organization_id = p_carrying_out_organization_id;
--
CURSOR	l_project_type_class( p_project_type VARCHAR2)
IS
SELECT	project_type_class_code
FROM	pa_project_types
WHERE  	project_type = p_project_type;
--
CURSOR 	l_starter_user_name_csr( p_starter_user_id NUMBER )
IS
SELECT 	user_name
FROM	fnd_user
WHERE 	user_id = p_starter_user_id;
--
CURSOR	l_starter_full_name_csr(p_starter_user_id NUMBER )
IS
SELECT  p.first_name||' '||p.last_name /* Bug 5122724 */
FROM    fnd_user f, per_people_f p
where p.effective_start_date = (select
min(pp.effective_start_date) from per_all_people_f pp where pp.person_id =
p.person_id and pp.effective_end_date >=trunc(sysdate)) and
((p.employee_number is not null) or (p.npw_number is not null))
and f.user_id = p_starter_user_id
and f.employee_id = p.person_id;
/* Replaced below sql with above sql for Bug 5122724
SELECT	e.first_name||' '||e.last_name
FROM	fnd_user f, per_all_people_f e  --pa_employees e  Commented for Bug5067575, SQLId:16329634
WHERE 	f.user_id = p_starter_user_id
AND	f.employee_id = e.person_id
AND	rownum=1;   -- Added for Bug5067575, SQLId:16329634 */
--
CURSOR l_budget_csr( p_project_id NUMBER
		    ,p_award_id NUMBER
		    ,p_budget_type_code VARCHAR2 )
IS
SELECT	pm_budget_reference
,	description
,	change_reason_code
,	budget_entry_method_code
,	pm_product_code
,	labor_quantity
,	raw_cost
,	burdened_cost
,	revenue
,	resource_list_id
,	budget_version_id
,	version_name
FROM 	gms_budget_versions
WHERE	project_id = p_project_id
AND	award_id = p_award_id
AND	budget_type_code = p_budget_type_code
--AND 	budget_status_code = 'S'; -- Modified on 20-May-2000
AND 	budget_status_code in ('S','W');
--

CURSOR l_resource_list_csr( p_resource_list_id NUMBER )
IS
SELECT	name
,	description
FROM	pa_resource_lists
WHERE 	resource_list_id = p_resource_list_id;
--
CURSOR l_budget_type_csr( p_budget_type_code VARCHAR2 )
IS
SELECT	budget_type
FROM	pa_budget_types
WHERE	budget_type_code = p_budget_type_code;

CURSOR l_wf_notification_role_csr(p_award_id NUMBER)
IS
SELECT	user_id, user_name
FROM 	gms_notifications_v
WHERE	award_id = p_award_id
AND 	event_type = 'BUDGET_BASELINE';

-- Get System Date for Worflow-Started-Date
CURSOR l_wf_started_date_csr
IS
SELECT sysdate
FROM 	sys.dual;

ItemType	varchar2(30) := 'GMSWF';  --<----Identifies the workflow process!!!
ItemKey		varchar2(30);

l_award_id			gms_awards.award_id%TYPE;
l_award_number			gms_awards.award_number%TYPE;
l_award_short_name		gms_awards.award_short_name%TYPE;

l_pm_project_reference		pa_projects.pm_project_reference%TYPE;
l_pa_project_number		pa_projects.segment1%TYPE;
l_project_name			pa_projects.name%TYPE;
l_description			pa_projects.description%TYPE;
l_project_type			pa_projects.project_type%TYPE;
l_pm_project_product_code	pa_projects.pm_product_code%TYPE;
l_carrying_out_org_id		NUMBER;
l_carrying_out_org_name		hr_organization_units.name%TYPE;
l_project_type_class_code	pa_project_types.project_type_class_code%TYPE;

l_pm_budget_reference		gms_budget_versions.pm_budget_reference%TYPE;
l_budget_description		gms_budget_versions.description%TYPE;
l_budget_change_reason_code	gms_budget_versions.change_reason_code%TYPE;
l_budget_entry_method_code	gms_budget_versions.budget_entry_method_code%TYPE;
l_pm_budget_product_code	gms_budget_versions.pm_product_code%TYPE;
l_mark_as_original 		gms_budget_versions.original_flag%TYPE;
l_budget_version_id		gms_budget_versions.budget_version_id%TYPE;
l_version_name			gms_budget_versions.version_name%TYPE;

l_total_labor_hours		NUMBER;
l_total_raw_cost		NUMBER;
l_total_burdened_cost		NUMBER;
l_total_revenue			NUMBER;
l_resource_list_id		NUMBER;
l_resource_list_name		pa_resource_lists.name%TYPE;
l_resource_list_description	pa_resource_lists.description%TYPE;
l_budget_type			pa_budget_types.budget_type%TYPE;
l_wf_started_date		DATE;

l_workflow_started_by_id	NUMBER;
l_starter_name			VARCHAR2(240);
l_starter_full_name		VARCHAR2(240);

l_user_id			NUMBER;
l_user_name			VARCHAR2(240);
l_role_name			VARCHAR2(100);
l_role_name_disp	        VARCHAR2(100); -- for NOCOPY fix to seprate in out paramters.
--Start Bug Fix 2204122 changed the width of var l_user_roles to 32000 from 4000--
l_user_roles			VARCHAR2(32000) := NULL;
--End Bug Fix 2204122--
l_resp_id			NUMBER;
l_resp_appl_id			NUMBER;
l_row_found 			VARCHAR2(1);

l_api_version_number		NUMBER	:= G_api_version_number ;
l_msg_count			NUMBER;
l_msg_data			VARCHAR(2000);
l_return_status			VARCHAR2(1)		:= NULL;
l_data				VARCHAR2(2000);
l_msg_index_out			NUMBER;
l_err_code   			NUMBER 		:= 0;
l_err_stage  			VARCHAR2(100);
l_err_stack  			VARCHAR2(100);

WF_API_EXCEPTION 		EXCEPTION;
pragma exception_init(WF_API_EXCEPTION, -20002);


BEGIN

    IF L_DEBUG = 'Y' THEN
    	gms_error_pkg.gms_debug('GMS_CLIENT_EXTN_BUDGET_WF.START_BUDGET_WF_NTFY_ONLY - start', 'C');
    END IF;

--  Standard BEGIN of API savepoint

    SAVEPOINT START_BUDGET_WF_NTFY_ONLY_pvt;

--  Set API Return Status To Success for Public API and Form Error Processing

    p_err_code 	:= 0;


       BEGIN
-- --------------------------------------------------------------------------------------
--	Initialize Globals for Starting Approve Budget Workflow
-- --------------------------------------------------------------------------------------

             l_workflow_started_by_id := FND_GLOBAL.user_id;

             OPEN l_starter_user_name_csr( l_workflow_started_by_id );
             FETCH l_starter_user_name_csr INTO l_starter_name;
             CLOSE l_starter_user_name_csr;

             OPEN l_starter_full_name_csr( l_workflow_started_by_id );
             FETCH l_starter_full_name_csr INTO l_starter_full_name;
             CLOSE l_starter_full_name_csr;

             l_resp_id := FND_GLOBAL.resp_id;
             l_resp_appl_id := FND_GLOBAL.resp_appl_id;

-- Based on the Responsibility, Intialize the Application
-- Cannot call Set_Global_Attr here because the WF does NOT
-- Exist yet.

FND_GLOBAL.Apps_Initialize
	(user_id         	=> l_workflow_started_by_id
	  , resp_id         	=> l_resp_id
	  , resp_appl_id	=> l_resp_appl_id);


-- Mark-As-Original Flag Set From IN-Parameter

     l_mark_as_original := p_mark_as_original;

      -- Bug 4004577
      If GMS_SECURITY.ALLOW_QUERY(p_award_id) = 'Y' Then
         OPEN l_award_csr (p_award_id);
         FETCH l_award_csr INTO l_award_number
      	                      , l_award_short_name;
         CLOSE l_award_csr;
      End If;

      OPEN l_project_csr(p_project_id);
      FETCH l_project_csr INTO l_pm_project_reference
			,l_pa_project_number
			,l_project_name
			,l_description
			,l_project_type
			,l_pm_project_product_code
			,l_carrying_out_org_id;
       CLOSE l_project_csr;

       OPEN l_budget_type_csr( p_budget_type_code );
       FETCH l_budget_type_csr INTO l_budget_type;
       CLOSE l_budget_type_csr;

       OPEN l_organization_csr( l_carrying_out_org_id );
       FETCH l_organization_csr INTO l_carrying_out_org_name;
       CLOSE l_organization_csr;

       OPEN l_project_type_class( l_project_type );
       FETCH l_project_type_class INTO l_project_type_class_code;
       CLOSE l_project_type_class;

       OPEN l_budget_csr( p_project_id, p_award_id, p_budget_type_code );
       FETCH l_budget_csr INTO  l_pm_budget_reference
			,l_budget_description
			,l_budget_change_reason_code
			,l_budget_entry_method_code
			,l_pm_budget_product_code
			,l_total_labor_hours
			,l_total_raw_cost
			,l_total_burdened_cost
			,l_total_revenue
			,l_resource_list_id
			,l_budget_version_id
			,l_version_name;

       CLOSE l_budget_csr;

       OPEN l_resource_list_csr( l_resource_list_id );
       FETCH l_resource_list_csr INTO l_resource_list_name
			      ,l_resource_list_description;
       CLOSE l_resource_list_csr;

       OPEN l_wf_started_date_csr;
       FETCH l_wf_started_date_csr INTO l_wf_started_date;
       CLOSE l_wf_started_date_csr;

--------------------------------------------------------------------------------
-- Creating Role and Users required for GMS Workflow process; based on data in
-- GMS_NOTIFICATIONS_V table/view.

       OPEN l_wf_notification_role_csr(p_award_id);
       LOOP
       		FETCH l_wf_notification_role_csr INTO l_user_id, l_user_name;
--start bug fix 2204122--
--Exit statement to be executed first , Else the last user id gets repeated--
       		EXIT WHEN l_wf_notification_role_csr%NOTFOUND;
                --start bug fix 3224843--
                IF GMS_WF_PKG.Excl_Person_From_Notification(p_award_id, l_user_id) = 'N'  THEN
       		   l_user_roles := l_user_roles||','||l_user_name;
                END IF;
                --end bug fix 3224843--
	        --exit when l_wf_notification_role_csr%NOTFOUND;
--end bug fix 2204122--

       END LOOP;

       CLOSE l_wf_notification_role_csr;


       -- In order to remove an extra comma that is preceding l_user_roles
	if substr(l_user_roles, 1, 1) = ','
	then
		l_user_roles := substr(l_user_roles, 2, (length(l_user_roles)-1));
	end if;

	l_role_name := p_award_id||'-BUDGET';
	l_role_name_disp := l_role_name;

	IF L_DEBUG = 'Y' THEN
		gms_error_pkg.gms_debug('GMS_CLIENT_EXTN_BUDGET_WF.START_BUDGET_WF_NTFY_ONLY - l_role_name = '||l_role_name, 'C');
	END IF;
--Bug 2204122 Commented the following line as this will be called--
--from gms_client_extn_budget_wf.call_gms_debug--
--	gms_error_pkg.gms_debug('GMS_CLIENT_EXTN_BUDGET_WF.START_BUDGET_WF_NTFY_ONLY - l_user_roles = '||l_user_roles, 'C');

gms_client_extn_budget_wf.call_gms_debug(p_user_roles => l_user_roles
   				        ,p_disp_text  => 'GMS_CLIENT_EXTN_BUDGET_WF.START_BUDGET_WF_NTFY_ONLY - l_user_roles = ') ;
--End Bug Fix 2204122--
   	-- Creating the Adhoc Role to which notifications are to be sent.

	IF L_DEBUG = 'Y' THEN
		gms_error_pkg.gms_debug('GMS_CLIENT_EXTN_BUDGET_WF.START_BUDGET_WF_NTFY_ONLY - creating Adhoc role..', 'C');
	END IF;

   	BEGIN
   		wf_directory.CreateAdhocRole( role_name => l_role_name,
   					      role_display_name => l_role_name_disp,
   					      language => 'AMERICAN',
   					      territory => 'AMERICA',
   					      notification_preference => 'MAILHTML');
	EXCEPTION
	WHEN WF_API_EXCEPTION
	THEN
		NULL;
	END;

	-- Purging all the existing users (if any) in the above created role.

	IF L_DEBUG = 'Y' THEN
		gms_error_pkg.gms_debug('GMS_CLIENT_EXTN_BUDGET_WF.START_BUDGET_WF_NTFY_ONLY - removing users from Adhoc role..', 'C');
	END IF;

	wf_directory.RemoveUsersFromAdhocRole(role_name => l_role_name);

	-------------------------------------------------------------------------------------------------------------
	-- If there is atleast one user defined in GMS_NOTIFICATIONS_V for this award
	-- then
	-- add the user to the above created role.
	-- else
	-- raise exception since WF will fail while looking for users to send notifications to.
	-------------------------------------------------------------------------------------------------------------

	IF l_user_roles IS NOT NULL
	THEN
		IF L_DEBUG = 'Y' THEN
			gms_error_pkg.gms_debug('GMS_CLIENT_EXTN_BUDGET_WF.START_BUDGET_WF_NTFY_ONLY - adding users to Adhoc role..', 'C');
		END IF;

--Start Bug fix 2204122--
--call procedure call_wf_addusers_to_adhocrole--
	    BEGIN
  	    gms_client_extn_budget_wf.call_wf_addusers_to_adhocrole(p_user_roles => l_user_roles ,
					  p_role_name  => l_role_name ) ;

		EXCEPTION
		  WHEN WF_API_EXCEPTION
		  THEN
		  NULL;
	    END ;
		/*begin
			wf_directory.AddUsersToAdhocRole(role_name => l_role_name,
						 role_users => l_user_roles);
		exception
		when WF_API_EXCEPTION
		then
			NULL;
		end;*/
--End Bug fix 2204122--
	ELSE
		IF L_DEBUG = 'Y' THEN
			gms_error_pkg.gms_debug('GMS_CLIENT_EXTN_BUDGET_WF.START_BUDGET_WF_NTFY_ONLY - Exception: No users found for this role.', 'C');
		END IF;
		gms_error_pkg.gms_message( x_err_name => 'GMS_FND_USER_NOT_CREATED',
					x_err_code => l_err_code,
					x_err_buff => l_err_stage);

		l_err_code := 4; -- This error code will be used to show a warning.
		return;
	END IF;

--------------------------------------------------------------------------------

       SELECT gms_workflow_itemkey_s.nextval
       INTO ItemKey
       from dual;


        EXCEPTION

	WHEN FND_API.G_EXC_ERROR
	THEN
		ROLLBACK TO START_BUDGET_WF_NTFY_ONLY_pvt;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
		p_err_code 	:= SQLCODE;
		ROLLBACK TO START_BUDGET_WF_NTFY_ONLY_pvt;

	 WHEN OTHERS THEN
		p_err_code 	:= SQLCODE;
		ROLLBACK TO START_BUDGET_WF_NTFY_ONLY_pvt;

     END;

     BEGIN
-- ------------------------------------------------------------------------------------
-- INSTANTIATE BUDGET WORKFLOW
-- ------------------------------------------------------------------------------------
-- NOTE:
-- The process name passed here is the root process for the
--  'GMS Workflow Process'. The Selector procedure may override
--  the process name specified here. However, the default
--  GMS_WF procedure does not call the Selector procedure.
-- ------------------------------------------------------------------------------------

	IF L_DEBUG = 'Y' THEN
		gms_error_pkg.gms_debug('GMS_CLIENT_EXTN_BUDGET_WF.START_BUDGET_WF_NTFY_ONLY - Calling wf_engine.CreateProcess..', 'C');
	END IF;

	wf_engine.CreateProcess( ItemType => ItemType,
				 ItemKey  => ItemKey,
				 process  => 'GMS_WF_PROCESS' );

	IF L_DEBUG = 'Y' THEN
		gms_error_pkg.gms_debug('GMS_CLIENT_EXTN_BUDGET_WF.START_BUDGET_WF_NTFY_ONLY - Setting Item Attributes..', 'C');
	END IF;


-- attribute GMS_WF_PROCESS is used to select the appropriate branch
-- in the workflow process.

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'GMS_WF_PROCESS',
					avalue		=>  'BUDGET_NTFY_ONLY' );

	wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'AWARD_ID',
					avalue		=>  p_award_id);

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'AWARD_NUMBER',
					avalue		=>  l_award_number);

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'AWARD_SHORT_NAME',
					avalue		=>  l_award_short_name);

	wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'PROJECT_ID',
					avalue		=>  p_project_id);

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'PM_PROJECT_REFERENCE',
					avalue		=>  l_pm_project_reference );

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'PA_PROJECT_NUMBER',
					avalue		=>  l_pa_project_number );

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'PROJECT_NAME',
					avalue		=>  l_project_name );

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'PROJECT_DESCRIPTION',
					avalue		=>  l_description );

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'PROJECT_TYPE',
					avalue		=>  l_project_type );

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'PM_PROJECT_PRODUCT_CODE',
					avalue		=>  l_pm_project_product_code );

	wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'CARRYING_OUT_ORG_ID',
					avalue		=>  l_carrying_out_org_id);

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'CARRYING_OUT_ORG_NAME',
					avalue		=>  l_carrying_out_org_name);

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'PROJECT_TYPE_CLASS_CODE',
					avalue		=>  l_project_type_class_code);

	wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'WORKFLOW_STARTED_BY_ID',
					avalue		=>  l_workflow_started_by_id);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'WORKFLOW_STARTED_BY_NAME',
					avalue		=>  l_starter_name);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'WORKFLOW_STARTED_BY_FULL_NAME',
					avalue		=>  l_starter_full_name);


	wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'RESPONSIBILITY_ID',
					avalue		=>  l_resp_id);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'BUDGET_TYPE_CODE',
					avalue		=>  p_budget_type_code);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'BUDGET_TYPE',
					avalue		=>  l_budget_type);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'PM_BUDGET_REFERENCE',
					avalue		=>  l_pm_budget_reference);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'BUDGET_DESCRIPTION',
					avalue		=>  l_budget_description);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'CHANGE_REASON_CODE',
					avalue		=>  l_budget_change_reason_code);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'BUDGET_ENTRY_METHOD',
					avalue		=>  l_budget_entry_method_code);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'PM_BUDGET_PRODUCT_CODE',
					avalue		=>  l_pm_budget_product_code);

	wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'TOTAL_LABOR_HOURS',
					avalue		=>  l_total_labor_hours);

	wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'TOTAL_RAW_COST',
					avalue		=>  l_total_raw_cost);

	wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'TOTAL_BURDENED_COST',
					avalue		=>  l_total_burdened_cost);

	wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'RESOURCE_LIST_ID',
					avalue		=>  l_resource_list_id);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'RESOURCE_LIST_NAME',
					avalue		=>  l_resource_list_name);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'RESOURCE_LIST_DESCRIPTION',
					avalue		=>  l_resource_list_description);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'MARK_AS_ORIGINAL',
					avalue		=>  l_mark_as_original);


	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'NOTIF_RECIPIENT_ROLE',
					avalue		=>  l_role_name);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'FC_MODE',
					avalue		=>  'S');

	wf_engine.SetItemAttrDate (	itemtype	=> itemtype,
	      			   	itemkey  	=> itemkey,
 	      			   	aname 		=> 'WF_STARTED_DATE',
				   	avalue		=> l_wf_started_date
				);

	--
	IF L_DEBUG = 'Y' THEN
		gms_error_pkg.gms_debug('GMS_CLIENT_EXTN_BUDGET_WF.START_BUDGET_WF_NTFY_ONLY - Calling wf_engine.StartProcess..', 'C');
	END IF;

	wf_engine.StartProcess( 	itemtype	=> itemtype,
	      				itemkey		=> itemkey );

	IF L_DEBUG = 'Y' THEN
		gms_error_pkg.gms_debug('GMS_CLIENT_EXTN_BUDGET_WF.START_BUDGET_WF_NTFY_ONLY - After wf_engine.StartProcess', 'C');
	END IF;

-- -----------------------------------------------------------------------------------
-- CAUTION: These two OUT-Parameters must be populated
--          properly in order for the calling procedures
--	    to work as designed.
-- ------------------------------------------------------------------------------------

	p_item_type	:= itemtype;
	p_item_key	:= itemkey;

-- -------------------------------------------------------------------------------------

	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR
	THEN
		WF_CORE.CONTEXT(' GMS_CLIENT_EXTN_BUDGET_WF ','START_BUDGET_WF_NTFY_ONLY', itemtype, itemkey);
		p_err_code 	:= 4;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
		WF_CORE.CONTEXT(' GMS_CLIENT_EXTN_BUDGET_WF ','START_BUDGET_WF_NTFY_ONLY', itemtype, itemkey);
		p_err_code 	:= 4;

	WHEN OTHERS
	 THEN
		WF_CORE.CONTEXT(' GMS_CLIENT_EXTN_BUDGET_WF ','START_BUDGET_WF_NTFY_ONLY', itemtype, itemkey);
		p_err_code 	:= 4;

	END;

END START_BUDGET_WF_NTFY_ONLY;


-----------------------------------------------------------------------------------------------------

--Name:         	Select_Budget_Approver
--Type:               	Procedure
--Description:      This client extension returns the
--	        correct budget approver.
--
--
--Called subprograms:
--
--
--
--History:
--
-- IN
--   p_project_id		- unique identifier for the project
--   p_award_id			- unique identifier for the award
--   p_budget_type_code		- needed to uniquely identify the working budget
--   p_workflow_started_by_id	- identifies the user that initiated the workflow
--
-- OUT NOCOPY
--   p_budget_baseliner_id    	- unique identifier of the employee
--				  (award_manager_id in gms_awards table)
--				  that must approve this budget for baselining.
--

PROCEDURE Select_Budget_Approver
(p_item_type			IN VARCHAR2
, p_item_key  			IN VARCHAR2
, p_project_id			IN NUMBER
, p_award_id 			IN NUMBER
, p_budget_type_code		IN VARCHAR2
, p_workflow_started_by_id  	IN NUMBER
, p_budget_baseliner_id		OUT NOCOPY NUMBER
 )
 --
IS

--
-- Define Your Local Variables Here
--
l_employee_id NUMBER;
--
/*
   You can use this procedure to add any additional rules to determine
   who can approve a project. This procedure is being used by the
   Workflow APIs and determine who the approver for a project
   should be. By default this procedure fetches the supervisor of the
   person who initiated the workflow as the approver.
*/


BEGIN

-- Specify Your Business Rules Here

/*
	SELECT	employee_id
	INTO	l_employee_id
	FROM	fnd_user
	WHERE	user_id = p_workflow_started_by_id;
*/

-- Selecting the active Award Manager for this Award as the Baseliner.

	SELECT 	person_id
	INTO 	p_budget_baseliner_id
	FROM 	gms_personnel
	WHERE	award_id = p_award_id
   	AND 	award_role = 'AM' -- (AM => Award Manager)
   	AND 	sysdate BETWEEN START_DATE_ACTIVE
   	AND 	NVL(END_DATE_ACTIVE, sysdate);


--
--The following algorithm can be used to handle known error conditions
--When this code is used the arguments and there values will be displayed
--in the error message that is send by workflow.
--
--IF <error condition>
--THEN
--	WF_CORE.TOKEN('ARG1', arg1);
--	WF_CORE.TOKEN('ARGn', argn);
--	WF_CORE.RAISE('ERROR_NAME');
--END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
	p_budget_baseliner_id := NULL;

WHEN OTHERS THEN
  	WF_CORE.CONTEXT('GMS_CLIENT_EXTN_BUDGET_WF','SELECT_BUDGET_APPROVER',
p_item_type, p_item_key);
 RAISE;

END Select_Budget_Approver;

-- ==================================================
--Name:              Verify_Budget_Rules
--Type:               Procedure
--Description:     This procedure is for verification rules that may
--		vary by workflow.
--
--
--Called subprograms: none.
--
--
--
--History:
--
-- IN
--   p_item_type		- WF item type
--   p_item_key			- WF item key
--   p_project_id		- unique identifier for the project that needs baselining
--   p_award_id			- unique identifier for the award that needs baselining
--   p_budget_type_code		- needed to uniquely identify this working budget
--   p_workflow_started_by_id	- identifies the user that initiated the workflow
--   p_event			- indicates whether procedure called for
--				  either a 'SUBMIT' or 'BASELINE'
--				  event.
--
-- OUT NOCOPY
--  p_warnings_only_flag		- RETURN 'Y' if ALL triggered edits are warnings. Otherwise,
--				   if there is at least one hard error, then RETURN 'N'.
-- p_err_msg_count		-  Count of warning and error messages.
--
-- NOTES
--	By using the commented code in the body of this procedure, you may
--	add error and warning messages to the message stack.
--	However, the workflow notification will only display
--	ten messages.
--
--	Moreover, error/warning processing in the calling procedure
--	will only occur if OUT NOCOPY p_err_msg_count
--	parameter is greater than zero.
--

PROCEDURE Verify_Budget_Rules
(p_item_type			IN   	VARCHAR2
, p_item_key  			IN   	VARCHAR2
, p_project_id			IN 	NUMBER
, p_award_id 			IN 	NUMBER
, p_budget_type_code		IN 	VARCHAR2
, p_workflow_started_by_id  	IN 	NUMBER
, p_event			IN	VARCHAR2
, p_warnings_only_flag		OUT NOCOPY	VARCHAR2
, p_err_msg_count		OUT NOCOPY	NUMBER
)
--
IS
--
-- Declare Variables here


BEGIN

--
-- Initialize OUT-parameters Here.
-- All 'p_' parameters are required.
--
	p_warnings_only_flag 	:= 'Y';
	p_err_msg_count		:= 0;

--
-- Put The Rules That  You Want To Check For Here
--

--
-- NOTIFICATION Error/Warning Handling  --------------------------
--
-- Note: You must call PA_UTILS.Add_Message at least once
--           for the higher-level workflow processing to be invoked.
--
-- For error and warning messages, you must increment the p_err_msg_count
-- OUT-parameter before passing control to the calling procedure:
--
--  p_err_msg_count := FND_MSG_PUB.Count_Msg;
--
--
-- For a hard error, one that you want to force the calling procedure
-- to invoke a 'False' or 'Failure' transition:
--
-- p_warnings_only_flag := 'N';
--
--
-- To display an error or warning message in the workflow notification, you
-- must call  the following:
--
-- 	PA_UTILS.Add_Message
--
-- For example, a typical call might look like the following:
--
-- PA_UTILS.Add_Message
--	( p_app_short_name 	=> 'PA'
--	, p_msg_name 		=> 'PA_NO_BUDGET_RULES_ATTR'
--	);
-- ---------------------------------------------------------------------------------------

--
-- WF_CORE Error Handling --------------------------------------------------
-- To display errors using the WF_CORE functionality,
-- the following algorithm can be used to handle known error conditions.
-- When this code is used the arguments and there values will be displayed
-- in the workflow monitor.
--
--IF <error condition>
--THEN
--	WF_CORE.TOKEN('ARG1', arg1);
--	WF_CORE.TOKEN('ARGn', argn);
--	WF_CORE.RAISE('ERROR_NAME');
--END IF;
-- ---------------------------------------------------------------------------------------

--
-- Make sure to update the OUT NOCOPY variable for the
-- message count
--
	p_err_msg_count	:= FND_MSG_PUB.Count_Msg;


EXCEPTION

WHEN OTHERS THEN
	WF_CORE.CONTEXT('GMS_CLIENT_EXTN_BUDGET_WF','VERIFY_BUDGET_RULES', p_item_type, p_item_key);
	RAISE;


END Verify_Budget_Rules;

-----------------------------------------------------------------------------------------------

-- =================================================
--Bug fix 2204122 added the following two procedures--
--1. call_gms_debug  2.call_wf_addusers_to_adhocrole--
-------------------------------------------------------------------------
--In Procedure  call_gms_debug stream of 255 chars--
--would be passed to procedure gms_error_pkg.gms_debug--
--in a loop till it prints all the USERIDS--

PROCEDURE call_gms_debug
(p_user_roles IN VARCHAR2
,p_disp_text  IN VARCHAR2)

IS

l_user_roles      VARCHAR2(32000);
l_user_roles_temp VARCHAR2(150) ;
l_total_char 	  NUMBER ;
l_start_pos  	  NUMBER := 0;
l_char_send  	  NUMBER := 0 ;
l_tot_char_send   NUMBER := 0 ;

BEGIN
  l_user_roles :=  p_user_roles ;
  l_total_char :=  LENGTH(l_user_roles) ;
  IF l_total_char > 150 THEN
    LOOP
      l_start_pos       := l_start_pos + l_char_send + 1;
	  l_user_roles_temp := SUBSTR(l_user_roles, l_start_pos , 150 )  ;
	  l_char_send       := LENGTH(l_user_roles_temp) ;
	  l_tot_char_send   := l_tot_char_send + l_char_send ;

	  IF (l_total_char - l_start_pos  >= 150) THEN

	    l_user_roles_temp := SUBSTR(l_user_roles_temp , 1 , INSTR(l_user_roles_temp,',',-1,1)-1) ;

            l_char_send := LENGTH(l_user_roles_temp) ;
	    l_tot_char_send:= l_tot_char_send + (l_char_send-150 ) ;
	    IF L_DEBUG = 'Y' THEN
	    	gms_error_pkg.gms_debug(p_disp_text||l_user_roles_temp, 'C');
	    END IF;

         ELSE

          IF L_DEBUG = 'Y' THEN
          	gms_error_pkg.gms_debug(p_disp_text||l_user_roles_temp, 'C');
          END IF;
        END IF ;

	END LOOP ;

  ELSE

	IF L_DEBUG = 'Y' THEN
		gms_error_pkg.gms_debug(p_disp_text||l_user_roles, 'C');
	END IF;

  END IF ;

END call_gms_debug ;


--Bug 2204122 Stream of maximum 2000 chars each would be passed--
--to procedure wf_directory.AddUsersToAdhocRole--
--through Procedure call_wf_addusers_to_adhocrole , within a loop to pass all the USERID's--


PROCEDURE call_wf_addusers_to_adhocrole
(p_user_roles IN VARCHAR2
,p_role_name  IN VARCHAR2)

IS
l_disp_text       VARCHAR2(100) ;
l_role_name       VARCHAR2(100) ;
l_user_roles      VARCHAR2(32000);
l_user_roles_temp VARCHAR2(2000) ;
l_total_char 	  NUMBER ;
l_start_pos  	  NUMBER := 0 ;
l_char_send  	  NUMBER := 0 ;
l_tot_char_send   NUMBER := 0 ;

BEGIN
  l_user_roles := p_user_roles ;
  l_role_name  := p_role_name  ;
  l_total_char := LENGTH(l_user_roles) ;

  IF l_total_char > 2000 THEN
    LOOP
      l_start_pos       := l_start_pos + l_char_send + 1;
	  l_user_roles_temp := SUBSTR(l_user_roles, l_start_pos , 2000 )  ;
	  l_char_send       := LENGTH(l_user_roles_temp) ;
	  l_tot_char_send   := l_tot_char_send + l_char_send ;

	  IF (l_total_char - l_start_pos  >= 2000) THEN

	    l_user_roles_temp := SUBSTR(l_user_roles_temp , 1 , INSTR(l_user_roles_temp,',',-1,1)-1) ;

            l_char_send := LENGTH(l_user_roles_temp) ;
  	    l_tot_char_send:= l_tot_char_send + (l_char_send-2000 ) ;
            wf_directory.AddUsersToAdhocRole(role_name  => l_role_name,
	               		         role_users => l_user_roles_temp);
          ELSE
            wf_directory.AddUsersToAdhocRole(role_name  => l_role_name,
	               			     role_users => l_user_roles_temp);
          END IF ;
    END LOOP ;
  ELSE
	wf_directory.AddUsersToAdhocRole(role_name  => l_role_name,
   				         role_users => l_user_roles);
  END IF ;

END call_wf_addusers_to_adhocrole;
END gms_client_extn_budget_wf;

/
