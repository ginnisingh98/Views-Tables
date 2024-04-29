--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_BUDGET_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_BUDGET_WF" AS
/* $Header: PAWFBCEB.pls 120.3.12010000.5 2009/08/03 15:24:00 rthumma ship $ */

-- -------------------------------------------------------------------------------------
--	GLOBALS
-- -------------------------------------------------------------------------------------

G_API_VERSION_NUMBER 	CONSTANT NUMBER := 1.0;

-- -------------------------------------------------------------------------------------
--	PROCEDURES
-- -------------------------------------------------------------------------------------

--
--Name:        	BUDGET_WF_IS_USED
--Type:               	Procedure
--Description:          This procedure must return a "T" or "F" depending on whether a workflow
--		        should be started for this particular budget.
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
--	Error messages in the form and public API call  the 'PA_WF_CLIENT_EXTN'
--	error code. Two tokens are passed to the error message: the name of this
--	client extension and the error code.
--
--
--
--
--History:
--    	24-FEB-1997       L. de Werker	- Created
--	24-JUN-97	jwhite		- Updated to latest specs.
--	29-JUL-97	jwhite		- Updated to specs directed by jlowell.
--	12-AUG	-97	jwhite		- Ditto; added check for enable flags
--					  from pa_project_types and
--					  pa_budget_types.
--	21-OCT-87	jwhite		- Updated as per Kevin Hudson's code review
--
--      08-AUG-02	jwhite		- Adapted default logic to also support the new FP model.
--
--
-- IN Parameters
--   p_project_id			- Unique identifier for the project of the budget for which approval
--				   is requested.
--   p_budget_type_code		- Unique identifier for  budget submitted for approval
--   p_pm_product_code		- The PM vendor's product code stored in pa_budget_versions.
--
-- OUT Parameters
--   p_result    			- 'T' or 'F' (True/False)
--   p_err_code			-  Standard error code: 0, Success; x < 0, Unexpected Error;
--				   x > 0, Business Rule Violated.
--   p_err_stage			-   Standard error message
--   p_err_stack			-   Not used.
--

PROCEDURE BUDGET_WF_IS_USED
(p_draft_version_id		IN 	NUMBER
, p_project_id 			IN 	NUMBER
, p_budget_type_code		IN 	VARCHAR2
, p_pm_product_code		IN 	VARCHAR2
, p_fin_plan_type_id            IN      NUMBER     default NULL
, p_version_type                IN      VARCHAR2   default NULL
, p_result			IN OUT  NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
, p_err_code                    IN OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_err_stage			IN OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_err_stack			IN OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)

IS
/*
You can use this procedure to add/modify the conditions to enable
workflow for budget status changes. By default,Oracle Projects enables
and launches workflow based on the Budget Type and Project type setup.
You can choose to override these conditions with your own conditions

*/

     -- Define your local variables and cursors here

	CURSOR	l_project_types_csr (p_project_id NUMBER)
	IS
	SELECT	pt.enable_budget_wf_flag
	FROM		pa_projects p, pa_project_types pt
	WHERE		p.project_id = p_project_id
	AND		p.project_type = pt.project_type;

	CURSOR	l_budget_types_csr (p_budget_type_code VARCHAR2)
	IS
	SELECT	b.enable_wf_flag
	FROM 		pa_budget_types b
	WHERE		b.budget_type_code = p_budget_type_code;

	CURSOR	l_plan_types_csr (p_fin_plan_type_id NUMBER)
	IS
	SELECT	pl.enable_wf_flag
	FROM 		pa_fin_plan_types_b pl
	WHERE	pl.fin_plan_type_id = 	p_fin_plan_type_id;



	l_enable_budget_wf_flag 	pa_project_types.enable_budget_wf_flag%TYPE 	:= 'N';
	l_enable_wf_flag		pa_budget_types.enable_wf_flag%TYPE 	:= 'N';


 BEGIN


     -- Initialize The Output Parameters

     p_err_code := 0;
     p_result := 'F';

     -- Enter Your Business Rules Here.Or, Use The
     -- Provided Default.

	OPEN l_project_types_csr (p_project_id);
	FETCH l_project_types_csr INTO l_enable_budget_wf_flag;
	CLOSE l_project_types_csr ;


        IF (p_budget_type_code IS NULL)
          THEN
            -- FP model
	    OPEN l_plan_types_csr (p_fin_plan_type_id);
	    FETCH l_plan_types_csr INTO l_enable_wf_flag;
	    CLOSE l_plan_types_csr;

        ELSE
            -- r11.5.7 Budgets Model
	    OPEN l_budget_types_csr (p_budget_type_code);
	    FETCH l_budget_types_csr INTO l_enable_wf_flag;
	    CLOSE l_budget_types_csr;

        END IF;


	IF (
            ( l_enable_budget_wf_flag = 'Y')
		AND (l_enable_wf_flag = 'Y')
           )
	 THEN
		p_result := 'T';
	ELSE
		p_result := 'F';
	END IF;

--dbms_output.put_line('BUDGET_WF_USED - RESULT'||p_result);


 EXCEPTION

     WHEN OTHERS THEN
       -- Add your exception handler here.
       -- To raise an ORACLE error, assign SQLCODE to p_error_code
	p_err_code := SQLCODE;
	RAISE;

 END BUDGET_WF_IS_USED;
-- ===================================================
--
--Name: 		START_BUDGET_WF
--Type:               	Procedure
--Description:          This procedure is used to start the Budget Approval workflow.
--
--Notes:
--
--                      Calling Objects ------------------------------
--
--                      This procedure is called from the PA_BUDGET_WF.Start_Budget_WF. In turn,
--                      the PA_BUDGET_WF.Start_Budget_WF called from the following objects:
--                      1) Budgets form
--                      2) AMG Baseline_Budget API
--                      3) Budget Integration Workflow
--
--
--                      Error Messaging -----------------------------
--
--	                Error messages in the form and public API call  the 'PA_WF_CLIENT_EXTN'
--	                error code. Two tokens are passed to the error message: the name of this
--	                client extension and the error code.
--
--
--                      Financial Planning ---------------------------
--
--                      This procedure has been modified to support both the r11.5.7 Budgets Model
--                      and the Financial Planning Model:
--
--                      CRITICAL NOTES-1
--                         1) This procedure now drives off of the p_draft_version_id IN-parameter.
--                            The default logic ignores the p_budget_type_code IN-parameter.
--
--                         2) The p_draf_version_id IN-parameter is now passed to the
--                            workflow. The workflow now drives off
--                            of the p_draft_version_id IN-parameter.
--
--                         3) Although p_fin_plan_type_id and p_version_type can be passed as
--                            IN-parameters, the default logic ignores them.
--
--                         4) The FP parameters that are loaded into the workflow are populated
--                            from the draft_budget_version record.
--
--                         5) Conditional logic has been added for the r11.5.7 Budget and FP
--                            model processing.
--
--
--
--
--Called subprograms:	none.
--
--
--
--History:
--    	28-FEB-97	L. de Werker	- Created
--	26-JUN-97	jwhite		- Updated to lastest specs
--	29-JUL-97	jwhite		- Updated to specs as directed by jlowell
--	08-SEP-97	jwhite		-  Added item_type and item_key
--					   parameters and code as part of
--					   changes to encapsulate procedure
--					    in wrapper.
--	21-OCT-87	jwhite		- Updated as per Kevin Hudson's code review
--	04-NOV-97	jwhite		-  Added workflow-started-date
--					   to Start_Budget_WF procedure.
--	25-NOV-97	jwhite		- Replaced call to set_global_info
--					   with FND_GLOBAL.Apps_Initialize.
--					   Did not call Set_Global_Attr because
--					   the WF does NOT exist yet.
--
--      03-MAY-01	jwhite	        - As per the Non-Project Integration
--				          development effort, added the following
--                                        parameters and attributes to Start_Budget_WF:
--                                        1. p_fck_req_flag
--                                        2. p_bgt_intg_flag
--
--      08-AUG-02	jwhite		- Adapted default logic to also support the new FP model.
--                                        See desription above for modifications.
--
--      14-OCT-02	jwhite		- As part of supporting both r11.5.7 Budgets
--                                        and FP model in the notifications, modified code to
--                                        conditional populate budget/FP name and FP planning
--                                        elements for display in notifications.
--
--                                        Also, noticed that the BEM was being populated
--                                        with the CODE, NOT the name. Fixed this. Added
--                                        a cursor and a budget_entry_method_code attribute
--                                        to procedure and workflow.
--
--     01-NOV-02       jwhite          - Bug 2651400
--                                       Fixed typo for CLOSE cursor l_fin_attr_csr
--
--
--
-- IN Parameters
--   p_project_id		- Unique identifier for the project of the budget for which approval
--				  is requested.
--   p_budget_type_code		- Unique identifier for  budget submitted for approval
--   p_mark_as_original		-  Yes, mark budget as original; N, do not mark. Defaults to 'N'.
--   p_fck_req_flag             - Null or N, then funds check processing is not required. Y, if required.
--   p_bgt_intg_flag            - Null or N, then no budgetary controls. Y, if budgetary controls.
--
-- OUT Parameters
--   p_err_code			-  Standard error code: 0, Success; x < 0, Unexpected Error;
--				   x > 0, Business Rule Violated.
--   p_err_stage			-   Standard error message
--   p_err_stack			-   Not used.
--


PROCEDURE START_BUDGET_WF
(p_draft_version_id	IN	NUMBER
, p_project_id 		IN 	NUMBER
, p_budget_type_code	IN 	VARCHAR2
, p_mark_as_original	IN 	VARCHAR2
, p_fck_req_flag        IN      VARCHAR2  DEFAULT NULL
, p_bgt_intg_flag       IN      VARCHAR2  DEFAULT NULL
, p_fin_plan_type_id    IN      NUMBER    DEFAULT NULL
, p_version_type        IN      VARCHAR2  DEFAULT NULL
, p_item_type           OUT	NOCOPY VARCHAR2 	 --File.Sql.39 bug 4440895
, p_item_key           	OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_err_code            IN OUT	NOCOPY NUMBER  --File.Sql.39 bug 4440895
, p_err_stage         	IN OUT	NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
, p_err_stack         	IN OUT	NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
)

IS

--
-- CAUTION:
--
--	This is a working client extension. It is designed to start the
--	PABUDWF Budget Approval workflow. If you make changes to this
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




CURSOR l_project_csr	( p_project_id NUMBER )
IS
SELECT 	pm_project_reference
,	segment1
,	name
,	description
,	project_type
,	pm_product_code
,	carrying_out_organization_id
, template_flag --Bug 6691634
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
SELECT	e.first_name||' '||e.last_name
FROM	fnd_user f, per_all_people_f e
WHERE 	f.user_id = p_starter_user_id
AND		f.employee_id = e.person_id
AND     e.effective_start_date = (SELECT MIN(pap.effective_start_date)               --Bug 5102146.
                                  FROM   per_all_people_f pap
                                  WHERE  pap.person_id = e.person_id
                                  AND    pap.effective_end_date >= TRUNC(SYSDATE));
--
CURSOR l_budget_csr( p_draft_version_id NUMBER )
IS
SELECT	pm_budget_reference
        ,description
        ,change_reason_code
        ,budget_entry_method_code
        ,pm_product_code
        ,labor_quantity
        ,raw_cost
        ,burdened_cost
        ,revenue
        ,resource_list_id
        ,version_name
        ,budget_type_code
        ,fin_plan_type_id
        ,version_type
FROM 	pa_budget_versions
WHERE	budget_version_id = p_draft_version_id
AND 	budget_status_code = 'S';
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
WHERE	  budget_type_code = p_budget_type_code;
--
CURSOR l_wf_started_date_csr
IS
SELECT sysdate
FROM 	dual;
--
CURSOR l_fin_plan_name_csr (l_fin_plan_type_id NUMBER)
IS
SELECT name, plan_class_code --Bug 6691634
FROM   pa_fin_plan_types_vl fpt
WHERE  fpt.fin_plan_type_id  = l_fin_plan_type_id;
--AND fpt.LANGUAGE = USERENV('LANG');Bug 6691634
--
CURSOR l_fin_attr_csr (p_draft_version_id NUMBER, l_version_type VARCHAR2)
IS
SELECT l1.meaning
       , l2.meaning
FROM   pa_proj_fp_options fo
       , pa_lookups l1
       , pa_lookups l2
WHERE  fo.fin_plan_version_id = p_draft_version_id
AND    l1.lookup_code = decode(l_version_type, 'COST', fo.cost_fin_plan_level_code
                                 ,'REVENUE', fo.revenue_fin_plan_level_code
                                   ,'ALL', fo.all_fin_plan_level_code, NULL)
AND    l1.lookup_type = 'BUDGET ENTRY LEVEL'
AND    l2.lookup_code = decode(l_version_type, 'COST', fo.cost_time_phased_code
                                 ,'REVENUE', fo.revenue_time_phased_code
                                   ,'ALL', fo.all_time_phased_code, NULL)
AND    l2.lookup_type = 'BUDGET TIME PHASED TYPE';
--
CURSOR l_bem_csr( l_budget_entry_method_code VARCHAR2 )
IS
SELECT budget_entry_method
FROM   pa_budget_entry_methods m
WHERE  m.budget_entry_method_code = l_budget_entry_method_code;



ItemType	varchar2(30) := 'PABUDWF';  --<----Identifies the workflow process!!!
ItemKey		varchar2(30);

l_pm_project_reference		pa_projects.pm_project_reference%TYPE;
l_pa_project_number		pa_projects.segment1%TYPE;
l_project_name			pa_projects.name%TYPE;
l_description			pa_projects.description%TYPE;
l_project_type			pa_projects.project_type%TYPE;
l_pm_project_product_code	pa_projects.pm_product_code%TYPE;
l_carrying_out_org_id		NUMBER;
l_carrying_out_org_name		hr_organization_units.name%TYPE;
l_project_type_class_code	pa_project_types.project_type_class_code%TYPE;

l_pm_budget_reference		pa_budget_versions.pm_budget_reference%TYPE;
l_budget_description		pa_budget_versions.description%TYPE;
l_budget_change_reason_code	pa_budget_versions.change_reason_code%TYPE;
l_budget_entry_method_code	pa_budget_versions.budget_entry_method_code%TYPE;
l_budget_entry_method	        pa_budget_entry_methods.budget_entry_method%TYPE;
l_pm_budget_product_code	pa_budget_versions.pm_product_code%TYPE;
l_mark_as_original 		pa_budget_versions.original_flag%TYPE;
l_version_name			pa_budget_versions.version_name%TYPE;
l_budget_type_code              pa_budget_versions.budget_type_code%TYPE;

l_fin_plan_type_id              pa_budget_versions.fin_plan_type_id%TYPE;
l_version_type                  pa_budget_versions.version_type%TYPE;
l_fin_plan_type_name            pa_fin_plan_types_tl.name%TYPE;
l_fin_plan_level                pa_lookups.meaning%TYPE;
l_fin_plan_time_phase           pa_lookups.meaning%TYPE;


l_total_labor_hours		NUMBER;
l_total_raw_cost                NUMBER;
l_total_burdened_cost		NUMBER;
l_total_revenue			NUMBER;
l_resource_list_id              NUMBER;
l_resource_list_name		pa_resource_lists.name%TYPE;
l_resource_list_description	pa_resource_lists.description%TYPE;
l_budget_type			pa_fin_plan_types_tl.name%TYPE; --Bug 6974760 pa_budget_types.budget_type%TYPE;
l_wf_started_date			DATE;

l_workflow_started_by_id		NUMBER;
l_user_name			VARCHAR2(240);
l_full_name			VARCHAR2(400);/*UTF8-from varchar(240) to (400)*/
l_resp_id			NUMBER;
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

-- Start Changes for bug 6691634
l_url                   VARCHAR2(2000);
l_plan_class_code       pa_fin_plan_types_b.plan_class_code%TYPE;
l_template_flag         VARCHAR2(1);
-- End Changes for bug 6691634
--
--
BEGIN

    --  Standard BEGIN of API savepoint

    SAVEPOINT START_BUDGET_WF_pvt;

    --  Set API Return Status To Success for Public API and Form Error Processing

    p_err_code 	:= 0;


       BEGIN

      --
      --  Initialize FND Globals for Starting Approve Budget Workflow --------------
      --
      --      Please note that these globals will be populated from the calling
      --      module (AMG procedure, Budgets form or Budget Integration Workflow).


         --dbms_output.put_line('Item Key(s/b null): '||itemkey);

        l_workflow_started_by_id := FND_GLOBAL.user_id;

        OPEN l_starter_user_name_csr( l_workflow_started_by_id );
        FETCH l_starter_user_name_csr INTO l_user_name;
        CLOSE l_starter_user_name_csr;

        OPEN l_starter_full_name_csr( l_workflow_started_by_id );
        FETCH l_starter_full_name_csr INTO l_full_name;
        CLOSE l_starter_full_name_csr;

        l_resp_id := FND_GLOBAL.resp_id;

       -- Based on the Responsibility, Intialize the Application
       -- Cannot call Set_Global_Attr here because the WF does NOT
       -- Exist yet.
       FND_GLOBAL.Apps_Initialize
	(user_id         	=> l_workflow_started_by_id
	  , resp_id         	=> l_resp_id
	  , resp_appl_id	=> FND_GLOBAL.resp_appl_id
	);



     --
     -- Populate Workflow IN-Parameters ----------------------------------------------
     --

     -- Mark-As-Original Flag Set From IN-Parameter
     l_mark_as_original := p_mark_as_original;


      OPEN l_project_csr(p_project_id);
      FETCH l_project_csr INTO l_pm_project_reference
			,l_pa_project_number
			,l_project_name
			,l_description
			,l_project_type
			,l_pm_project_product_code
			,l_carrying_out_org_id
			,l_template_flag; --Bug 6691634
       CLOSE l_project_csr;


       OPEN l_organization_csr( l_carrying_out_org_id );
       FETCH l_organization_csr INTO l_carrying_out_org_name;
       CLOSE l_organization_csr;

       OPEN l_project_type_class( l_project_type );
       FETCH l_project_type_class INTO l_project_type_class_code;
       CLOSE l_project_type_class;

       OPEN l_budget_csr( p_draft_version_id );
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
			,l_version_name
                        ,l_budget_type_code
                        ,l_fin_plan_type_id
                        ,l_version_type;

       CLOSE l_budget_csr;


       -- Conditional Processing for r11.5.7/FP Models -------------
       IF (l_fin_plan_type_id IS NULL)
         THEN
         -- R11.5.7 Model  ----------------------------


         -- Not Applicable
         l_fin_plan_type_name            := NULL;
         l_fin_plan_level                := NULL;
         l_fin_plan_time_phase           := NULL;


         -- Get Budget Type Name
         OPEN l_budget_type_csr( p_budget_type_code );
         FETCH l_budget_type_csr INTO l_budget_type;
         CLOSE l_budget_type_csr;

        -- Get Budget Entry Method Name
         OPEN  l_BEM_csr( l_budget_entry_method_code );
         FETCH l_BEM_csr INTO l_budget_entry_method;
         CLOSE l_BEM_csr;




       ELSE
         -- FP Model  ---------------------------------



         OPEN l_fin_plan_name_csr (l_fin_plan_type_id);
         FETCH l_fin_plan_name_csr INTO  l_fin_plan_type_name ,l_plan_class_code; -- Bug 6691634
         CLOSE l_fin_plan_name_csr;

         OPEN l_fin_attr_csr (p_draft_version_id, l_version_type);
         FETCH l_fin_attr_csr INTO l_fin_plan_level, l_fin_plan_time_phase;
         CLOSE l_fin_attr_csr;


          -- Not Applicable to FP Model, but ...

             --  Used to Display Plan Type Name on PA Default Notifications !!!
             l_budget_type :=   l_fin_plan_type_name;


             --  Displayed as NULL on Notification
             l_budget_entry_method_code := NULL;   -- BEM Code
             l_budget_entry_method := NULL;        -- BEM Name


       END IF; -- l_fin_plan_type_id IS NULL

       -- ----------------------------------------------------------

       OPEN l_resource_list_csr( l_resource_list_id );
       FETCH l_resource_list_csr INTO l_resource_list_name
			      ,l_resource_list_description;
       CLOSE l_resource_list_csr;

       OPEN l_wf_started_date_csr;
       FETCH l_wf_started_date_csr INTO l_wf_started_date;
       CLOSE l_wf_started_date_csr;



       SELECT pa_workflow_itemkey_s.nextval
       INTO itemkey
       from dual;

--dbms_output.put_line('Item Key!: '||itemkey);

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
--  'PA Budget Approval Workflow'.
-- ------------------------------------------------------------------------------------
--dbms_output.put_line('Call for CreateProcess');

	wf_engine.CreateProcess( ItemType => ItemType,
			 ItemKey  => ItemKey,
			 process  => 'PRO_BASELINE_BUDGET' );

--dbms_output.put_line('SetitemAttributes');


	wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'PROJECT_ID',
					avalue		=>  p_project_id);
	--
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
					avalue		=>  l_user_name);

        wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'WORKFLOW_STARTED_BY_FULL_NAME',
					avalue		=>  l_full_name);


	wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'RESPONSIBILITY_ID',
					avalue		=>  l_resp_id);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'BUDGET_TYPE_CODE',
					avalue		=>  l_budget_type_code);

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
					avalue		=>  l_budget_entry_method);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'BUDGET_ENTRY_METHOD_CODE',
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
  	      				aname 		=> 'TOTAL_REVENUE',
					avalue		=>  l_total_revenue);

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

	wf_engine.SetItemAttrText (itemtype	=> itemtype,
	      			   itemkey  	=> itemkey,
 	      			   aname 	=> 'WF_STARTED_DATE',
				   avalue		=> l_wf_started_date);


        wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'DRAFT_VERSION_ID',
					avalue		=>  p_draft_version_id);



        -- Budget Integration Attributes ------------------------------------------

        wf_engine.SetItemAttrText (itemtype	=> itemtype,
	      			   itemkey  	=> itemkey,
 	      			   aname 	=> 'FCK_REQ_FLAG',
				   avalue	=> p_fck_req_flag);

        wf_engine.SetItemAttrText (itemtype	=> itemtype,
	      			   itemkey  	=> itemkey,
 	      			   aname 	=> 'BGT_INTG_FLAG',
				   avalue	=> p_bgt_intg_flag);


	-- Financial Planning Attributes ------------------------------------------




        wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'FIN_PLAN_TYPE_ID',
					avalue		=>  l_fin_plan_type_id);

        wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'VERSION_TYPE',
					avalue		=>  l_version_type);

        wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'FIN_PLAN_TYPE_NAME',
					avalue		=>  l_fin_plan_type_name);

        wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'FIN_PLAN_LEVEL',
					avalue		=>  l_fin_plan_level);

        wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'FIN_PLAN_TIME_PHASE',
					avalue		=>  l_fin_plan_time_phase);


        -- Added this condition for Bug 8742127
        IF l_fin_plan_type_id IS NOT NULL THEN

					--bug 6691634
					l_url := 'JSP:/OA_HTML/OA.jsp?OAFunc=PJI_VIEW_BDGT_TASK_SUMMARY'
                 ||'&'||'paProjectId='||p_project_id
                 ||'&'||'paFinTypeId='||l_fin_plan_type_id
                 ||'&'||'paPlanClassCode='||l_plan_class_code
                 ||'&'||'paBudgetVersionId='||p_draft_version_id
                 ||'&'||'paVersionType='||l_version_type
                 ||'&'||'paTemplateFlag='||l_template_flag
                 ||'&'||'paCallingPage=paBudgetWF'
                 ||'&'||'addBreadCrumb=Y';

	       wf_engine.SetItemAttrText( itemtype
                                      , itemkey
                                      , 'FINANCIAL_PLAN_URL'
                                      , l_url
					  );
					  --bug 6691634

        END IF;

        -- -----------------------------------------------------------------------




	wf_engine.StartProcess( 	itemtype	=> itemtype,
	      				itemkey		=> itemkey );


--dbms_output.put_line('AFTER Call for StartProcess');

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
WF_CORE.CONTEXT(' PA_CLIENT_EXTN_BUDGET_WF ','START_BUDGET_WF', itemtype, itemkey);
		RAISE;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
WF_CORE.CONTEXT(' PA_CLIENT_EXTN_BUDGET_WF ','START_BUDGET_WF', itemtype, itemkey);
		p_err_code 	:= SQLCODE;
		RAISE;

	WHEN OTHERS
	 THEN
WF_CORE.CONTEXT(' PA_CLIENT_EXTN_BUDGET_WF ','START_BUDGET_WF', itemtype, itemkey);
		p_err_code 	:= SQLCODE;
		RAISE;

	END;

END START_BUDGET_WF;


-- ===================================================

--Name:         	Select_Budget_Approver
--Type:               	Procedure
--Description:      This client extension returns the
--		correct budget approver.
--
--
--Called subprograms:
--
--
--
--History:
--   	24-FEB-97  	L. de Werker    	- Created
--	24-JUN-97	jwhite		- Updated to latest specs.
--	26-SEP-97	jwhite		- Updated WF error processing.
--	21-OCT-87	jwhite		- Updated as per Kevin Hudson's code review
--
--      08-AUG-02	jwhite		- Adapted default logic to also support the new FP model
--
-- IN
--   p_project_id			- unique identifier for the project
--   p_budget_type_code		- needed to uniquely identify the working budget
--   p_workflow_started_by_id	- identifies the user that initiated the workflow
--
-- OUT
--   p_budget_baseliner_id    	- unique identifier of the employee
--				  (employee_id in per_people_f table)
--				  that must approver this budget for baselining.
--

PROCEDURE Select_Budget_Approver
(p_item_type			IN   	VARCHAR2
, p_item_key  			IN   	VARCHAR2
, p_project_id			IN      NUMBER
, p_budget_type_code		IN      VARCHAR2
, p_workflow_started_by_id  	IN      NUMBER
, p_fin_plan_type_id            IN      NUMBER     default NULL
, p_version_type                IN      VARCHAR2   default NULL
, p_draft_version_id            IN      NUMBER     default NULL
, p_budget_baseliner_id		OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 )
 --
IS
-- 07-DEC-2009 - Kevin Bouwmeester
-- Cursor fetches 'Budget Approver' role from project.
CURSOR c_budget_approver(b_project_id pa_project_parties.project_id%TYPE)
IS
SELECT ppp.resource_source_id
FROM   pa_project_parties ppp
,      pa_project_role_types_tl pprt
where  pprt.meaning = 'Budget Approver'
and    ppp.project_role_id = pprt.project_role_id
and    ppp.project_id = b_project_id
and    trunc(sysdate) between ppp.start_date_active and nvl(ppp.end_date_active, sysdate+1)
;

--
-- Define Your Local Variables Here
--
l_employee_id NUMBER;

-- Selects modified to Cursors for Bug# 7675780
CURSOR c_employee_id(p_workflow_started_by_id NUMBER) IS
SELECT  employee_id
FROM    fnd_user
WHERE   user_id = p_workflow_started_by_id;

CURSOR c_supervisor_id(p_employee_id NUMBER) IS
SELECT  supervisor_id
FROM    per_assignments_f
WHERE    person_id = l_employee_id
AND assignment_type in ('C','E')  -- Bug#2911451 + FP.M for 'C'
AND primary_flag = 'Y'     -- Bug#2911451
AND TRUNC(sysdate) BETWEEN EFFECTIVE_START_DATE
AND NVL(EFFECTIVE_END_DATE, sysdate);

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
-- Selects modified to Cursors for Bug# 7675780
/*
   OPEN  c_employee_id(p_workflow_started_by_id);
   FETCH c_employee_id INTO l_employee_id;
   CLOSE c_employee_id;

   OPEN  c_supervisor_id(l_employee_id);
   FETCH c_supervisor_id INTO p_budget_baseliner_id;
   CLOSE c_supervisor_id;
*/
-- 07-DEC-2009 - Kevin Bouwmeester
-- Pick up Budget Approver from the project members.
OPEN  c_budget_approver(p_project_id);
FETCH c_budget_approver INTO p_budget_baseliner_id;
CLOSE c_budget_approver;

IF p_budget_baseliner_id IS NULL
THEN
  -- Budget approver not defined on the project -> fetch default approver
  p_budget_baseliner_id := FND_PROFILE.VALUE('XXAH_DEFAULT_BUDGET_APPROVER');

END IF;

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

WHEN OTHERS THEN
  WF_CORE.CONTEXT('PA_CLIENT_EXTN_BUDGET_WF','SELECT_BUDGET_APPROVER',
p_item_type, p_item_key);
 RAISE;

END Select_Budget_Approver;

-- ==================================================
--Name:              Verify_Budget_Rules
--Type:              Procedure
--Description:       This procedure is for verification rules that may
--                   vary by workflow.
--
--
--Called subprograms: none.
--
--
--
--History:
--    	25-FEB-97       L. de Werker    - Created
--	05-SEP-97	jwhite		- Updated to latest specs.
--	26-SEP-97	jwhite		- Updated WF error processing.
--	21-OCT-87	jwhite		- Updated as per Kevin Hudson's code review
--
--	26-APR-01	jwhite	        - For the Verify_Budget_Rules API,
--                                        added notes and code for global
--                                        G_bgt_intg_flag for GL/PA Budget Integration.
--
--      08-AUG-02	jwhite		- Adapted default logic to also support the new FP model
--
-- IN
--   p_item_type			- WF item type
--   p_item_key                         - WF item key
--   p_project_id			- unique identifier for the project that needs baselining
--   p_budget_type_code                 - needed to uniquely identify this working budget
--   p_workflow_started_by_id           - identifies the user that initiated the workflow
--   p_event                            - indicates whether procedure called for
--                                        either a 'SUBMIT' or 'BASELINE' event.
--
--   G_bgt_intg_flag                   - PA_BUDGET_UTILS.G_Bgt_Intg_Flag
--                                       This package specification global defaults to NULL.
--                                       It may be populated by the Budgets form and other Budget
--                                       APIs for integration budgets. It will NOT be populated
--                                       by Budget and Project Form Copy_Budget functions.
--
--                                       The values and meanings for this global are as follows:
--                                       NULL or 'N' - Budget Integration not enabled
--                                       'G' - GL Budget Integration
--                                       'C' - CBC Budget Integration

--
-- OUT
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
--	will only occur if OUT p_err_msg_count
--	parameter is greater than zero.
--

PROCEDURE Verify_Budget_Rules
(p_item_type			IN   	VARCHAR2
, p_item_key  			IN   	VARCHAR2
, p_project_id			IN 	NUMBER
, p_budget_type_code		IN 	VARCHAR2
, p_workflow_started_by_id  	IN 	NUMBER
, p_event			IN	VARCHAR2
, p_fin_plan_type_id            IN      NUMBER     default NULL
, p_version_type                IN      VARCHAR2   default NULL
, p_warnings_only_flag		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_err_msg_count		OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
)
--
IS
--
-- Declare Variables here

       -- Global Semaphore for Non-Project Budget Integration
       l_bgt_intg_flag  VARCHAR2(1) :=NULL;


BEGIN
--
-- Initialize Local Variable for  Non-Project Budget Integration Global.
--
      l_bgt_intg_flag := PA_BUDGET_UTILS.G_Bgt_Intg_Flag;

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
-- Make sure to update the OUT variable for the
-- message count
--
	p_err_msg_count	:= FND_MSG_PUB.Count_Msg;


EXCEPTION

WHEN OTHERS THEN
	WF_CORE.CONTEXT('PA_CLIENT_EXTN_BUDGET_WF','VERIFY_BUDGET_RULES', p_item_type, p_item_key);
	RAISE;


END Verify_Budget_Rules;
-- =================================================

END pa_client_extn_budget_wf;

/
