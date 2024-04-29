--------------------------------------------------------
--  DDL for Package Body PA_BUDGET_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BUDGET_WF" AS
/* $Header: PAWFBUVB.pls 120.7.12010000.4 2009/06/26 00:16:39 skkoppul ship $ */


-- -------------------------------------------------------------------------------------
--	Globals
-- -------------------------------------------------------------------------------------

G_API_VERSION_NUMBER 	CONSTANT NUMBER := 1.0;

-- -------------------------------------------------------------------------------------
--	Procedures
-- -------------------------------------------------------------------------------------

-- ===================================================

--Name: 		START_BUDGET_WF
--Type:               	Procedure
--Description:          This procedure is used to start a Budget Approval workflow.
--
--
--Called subprograms:	PA_CLIENT_EXTN_BUDGET_WF.Start_Budget_Wf
--			, PA_WORKFLOW_UTILS.Insert_WF_Processes
--
--Notes:
--	This wrapper is called DIRECTLY from the Budgets form and the public
--	Baseline_Budget API.
--
--	This wrapper is also called from the Budget Integration Workflow.
--
--	Error messages in the form and public API call  the 'PA_WF_CLIENT_EXTN'
--	error code. Two tokens are passed to the error message: the name of this
--	client extension and the error code.
--
--
--       * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
--             * * *         R12 MOAC Specific Notes          * * *
--
--                  The Budget Approval Workflow is now explicitly defined
--                  as a SINGLE PROJECT/OU workflow.
--
--                  Any procedure call for/from the Budget Approval workflow must
--                  call the PA_BUDGET_UTILS.Set_Prj_Policy_Context procedure to
--                  set the OU Context to the org_id for the project being
--                  processed.
--
--       * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
--
--
--History:
--    	08-SEP-97	jwhite	Created
--	21-OCT-97	jwhite	- Updated as per Kevin Hudson's code review
--
--	03-MAY-01	jwhite	- As per the Non-Project Integration
--				  development effort, added the following as parameters
--                                and attributes to Budget Approval Worflow:
--                                1. p_fck_req_flag
--                                2. p_bgt_intg_flag
--
--	08-AUG-02	jwhite	- Added new parameters for FP processing.
--
--      14-JUL-05       jwhite  -R12 MOAC Effort
--                               Added calls to the new Set_Prj_Policy_Context to enforce
--                               a single project/OU context for the Budget Approval
--                               Worklfow nodes.
--
--
--
-- IN Parameters
--   p_project_id			- Unique identifier for the project of the budget for which approval
--				   is requested.
--
--   p_budget_type_code		- Unique identifier for  budget submitted for approval, as per the r11.5.7
--                                Budgets model.
--
--                                For the new FP model, the p_budget_type_code will be NULL!
--
--   p_mark_as_original		-  Yes, mark budget as original; N, do not mark. Defaults to 'N'.
--
-- OUT Parameters
--   p_err_code			-  Standard error code: 0, Success; x < 0, Unexpected Error;
--				   x > 0, Business Rule Violated.
--   p_err_stage			-   Not used.
--   p_err_stack			-   Not used.


PROCEDURE Start_Budget_Wf
(p_draft_version_id	IN	NUMBER
, p_project_id 		IN 	NUMBER
, p_budget_type_code	IN 	VARCHAR2
, p_mark_as_original	IN 	VARCHAR2
, p_fck_req_flag        IN      VARCHAR2  DEFAULT NULL
, p_bgt_intg_flag       IN      VARCHAR2  DEFAULT NULL
, p_fin_plan_type_id    IN      NUMBER     default NULL
, p_version_type        IN      VARCHAR2   default NULL
, p_err_code            IN OUT	NOCOPY NUMBER  --File.Sql.39 bug 4440895
, p_err_stage         	IN OUT	NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
, p_err_stack         	IN OUT	NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
)
--
IS
--

--	Local Variables

l_err_code	NUMBER := NULL;
l_item_type     pa_wf_processes.item_type%TYPE;
l_item_key	pa_wf_processes.item_key%TYPE;

 -- R12 MOAC, 19-JUL-05, jwhite -------------------

 l_return_status VARCHAR2(1)    := NULL;
 l_msg_count     NUMBER         := NULL;
 l_msg_data      VARCHAR2(2000) := NULL;


BEGIN

 -- R12 MOAC, 14-JUL-05, jwhite -------------------
 -- Set Single Project/OU context

 PA_BUDGET_UTILS.Set_Prj_Policy_Context
       (p_project_id => p_project_id
        ,x_return_status => l_return_status
        ,x_msg_count     => l_msg_count
        ,x_msg_data      => l_msg_data
        ,x_err_code      => l_err_code
        );

 IF (l_err_code <> 0)
  THEN
     p_err_code := l_err_code;
     RETURN;
 END IF;

 -- -----------------------------------------------




PA_CLIENT_EXTN_BUDGET_WF.Start_Budget_Wf
( p_draft_version_id		=>	p_draft_version_id
, p_project_id 			=>	p_project_id
, p_budget_type_code		=>	p_budget_type_code
, p_mark_as_original		=>	p_mark_as_original
, p_fck_req_flag                =>      p_fck_req_flag
, p_bgt_intg_flag               =>      p_bgt_intg_flag
, p_fin_plan_type_id            =>      p_fin_plan_type_id
, p_version_type                =>      p_version_type
, p_item_type           	=> 	l_item_type
, p_item_key           		=> 	l_item_key
, p_err_code             	=>	l_err_code
, p_err_stage         		=> 	p_err_stage
, p_err_stack			=>	p_err_stack
);


IF (l_err_code = 0)
 THEN
-- Succesful! Log pa_wf_processes table for new workflow.

      PA_WORKFLOW_UTILS.Insert_WF_Processes
      (p_wf_type_code        	=> 'BUDGET'
      ,p_item_type           	=> l_item_type
      ,p_item_key           	=> l_item_key
      ,p_entity_key1         	=> to_char(p_draft_version_id)
      ,p_description         	=> NULL
      ,p_err_code            	=> p_err_code
      ,p_err_stage           	=> p_err_stage
      ,p_err_stack           	=> p_err_stack
      );
  ELSE
	p_err_code := l_err_code;

  END IF;


EXCEPTION

WHEN OTHERS
   THEN
	 p_err_code 	:= SQLCODE;
	 RAISE;


END Start_Budget_Wf;

-- =================================================
--
--Name:        	BUDGET_WF_IS_USED
--Type:         Procedure
--Description:  This procedure must return a "T" or "F" depending on whether a workflow
--		should be started for this particular budget.
--
--
--Called Subprograms:	PA_CLIENT_EXTN_BUDGET_WF.Budget_Wf_Is_Used
--
--
--Notes:
--	This wrapper is called DIRECTLY the public AMG
--	Baseline_Budget API.
--
--	!!! THIS WRAPPER IS NOT CALLED FROM WORKFLOW !!!
--
--	Error messages in the form and public API call  the 'PA_WF_CLIENT_EXTN'
--	error code. Two tokens are passed to the error message: the name of this
--	client extension and the error code.
--
--      * * * R12 MOAC Notes:
--            Since this procedure is only called from AMG package
--            PA_BUDGET_PUB (PAPMBUPB.pls), is NOT necessary to call the
--            R12 PA_BUDGET_UTILS.Set_Prj_Policy_Context to set the
--            project/OU context.
--
--
--
--
--History:
--	08-SEP-97	jwhite		Created
--	21-OCT-97	jwhite	- Updated as per Kevin Hudson's code review
--
--	08-AUG-02	jwhite	- Added new parameters for FP processing.
--
-- IN Parameters
--   p_project_id		- Unique identifier for the project of the budget for which approval
--				   is requested.
--
--   p_budget_type_code		- Unique identifier for  budget submitted for approval, as per the r11.5.7
--                                  Budgets model.
--
--                                  For the new FP model, the p_budget_type_code will be NULL!
--
--   p_pm_product_code		- The PM vendor's product code stored in pa_budget_versions.
--
-- OUT Parameters
--   p_result    			- 'T' or 'F' (True/False)
--   p_err_code			-  Standard error code: 0, Success; x < 0, Unexpected Error;
--				   x > 0, Business Rule Violated.
--   p_err_stage			-   Standard error message
--   p_err_stack			-   Not used.
--

PROCEDURE Budget_Wf_Is_Used
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
--

BEGIN

PA_CLIENT_EXTN_BUDGET_WF.BUDGET_WF_IS_USED
( p_draft_version_id		=>	p_draft_version_id
, p_project_id 			=>	p_project_id
, p_budget_type_code		=>	p_budget_type_code
, p_pm_product_code		=>	p_pm_product_code
, p_fin_plan_type_id            =>      p_fin_plan_type_id
, p_version_type                =>      p_version_type
, p_result			=>	p_result
, p_err_code                    =>	p_err_code
, p_err_stage         		=> 	p_err_stage
, p_err_stack			=>	p_err_stack
);


EXCEPTION

WHEN OTHERS
   THEN
	p_err_code 	:= SQLCODE;
	RAISE;


END Budget_WF_Is_Used;

-- =================================================
--Name:              	Reject_Budget
--Type:               	Procedure
--Description:     	This procedure resets a given project-budget status
--		        to a Working 'Rejected' status.
--
--
--
--Called subprograms: none.
--
--Notes:
--
--      * * * R12 MOAC Notes:
--
--            Technically, this procedure does NOT require the single project/OU context
--            to be set for the following reasons:
--            a) A client extension is not called.
--            b) The other code in this procedure does not have an OU dependency.
--
--            However, to avoid future maintenance issues, I added code to explicitly
--            set the single project/OU Context.
--
--
--
--History:
--	22-AUG-97	jwhite	- Created
--	26-SEP-97	jwhite	- Updated WF error processing.
--	21-OCT-97	jwhite	- Updated as per Kevin Hudson's code review
--
--      23-AUG-02	jwhite	- As part of implementation of new FP model, converted this node
--                                procedure to use draft_version_id in lieu of
--                                project_id, budget_type_code and budget_status_code.
--
--
--      19-JUL-05       jwhite  -R12 MOAC Effort
--                               Added calls to the new Set_Prj_Policy_Context to enforce
--                               a single project/OU context for the Budget Approval
--                               Worklfow nodes.
--
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The notIFication process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   Resultout    - NULL
--

PROCEDURE Reject_Budget
(itemtype			IN   	VARCHAR2
, itemkey  			IN   	VARCHAR2
, actid				IN	NUMBER
, funcmode			IN   	VARCHAR2
, resultout			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
--
IS
--
-- ROW LOCKING

	CURSOR l_lock_budget_csr (p_draft_version_id NUMBER)
	IS
	SELECT 'x'
	FROM 	pa_budget_versions
	WHERE	        budget_version_id = p_draft_version_id
	FOR UPDATE NOWAIT;

-- Local Variables

l_draft_version_id	        NUMBER;

l_err_code  			NUMBER := 0;
l_msg_count			NUMBER;
l_msg_data			VARCHAR(2000);
l_return_status			VARCHAR2(1);
l_data				VARCHAR2(2000);
l_msg_index_out			NUMBER;
l_api_version_number		NUMBER		:= G_api_version_number;


 --R12 MOAC, 19-JUL-05, jwhite
 l_project_id                    pa_projects_all.project_id%TYPE := NULL;



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

-- GET BUDGET ITEM ATTRIBUTES  for Subsequent Processing -----------------------


	l_draft_version_id := wf_engine.GetItemAttrNumber(
                                                        itemtype  	=> itemtype,
			    				itemkey   	=> itemkey,
			    				aname  		=> 'DRAFT_VERSION_ID'
                                                         );

        -- R12 MOAC, 19-JUL-05, jwhite
        -- Project_id Needed for subsequent procedure call
	l_project_id := wf_engine.GetItemAttrNumber( 	itemtype  	=> itemtype,
			    				itemkey   	=> itemkey,
			    				aname  		=> 'PROJECT_ID' );

/*Commented for bug 5233870*/
-- SET GLOBALS ------------------------------------------------------------------

-- Based on the Responsibility, Intialize the Application
-- Un Commented for bug 8464143.
   PA_WORKFLOW_UTILS.Set_Global_Attr
                (p_item_type => itemtype
                 , p_item_key  => itemkey
                 , p_err_code  => l_err_code);


-- R12 MOAC, 19-JUL-05, jwhite -------------------
-- Set Single Project/OU context

   PA_BUDGET_UTILS.Set_Prj_Policy_Context
       (p_project_id => l_project_id
        ,x_return_status => l_return_status
        ,x_msg_count     => l_msg_count
        ,x_msg_data      => l_msg_data
        ,x_err_code      => l_err_code
        );

   IF (l_err_code <> 0)
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

 -- -----------------------------------------------



-- REVERT STATUS of Project-Budget to 'Working' , 'REJECTED' -----------------

-- LOCK Draft Budget Version

    	OPEN l_lock_budget_csr(l_draft_version_id);
    	CLOSE l_lock_budget_csr;

-- UPDATE Draft Budget Version

	UPDATE pa_budget_versions
	 SET budget_status_code = 'W'
             , WF_status_code = 'REJECTED'
 	WHERE  budget_version_id = l_draft_version_id;


--
	resultout := wf_engine.eng_completed;
--

EXCEPTION

WHEN FND_API.G_EXC_ERROR
	THEN
	WF_CORE.CONTEXT('PA_BUDGET_WF','REJECT_BUDGET', itemtype, itemkey, to_char(actid), funcmode);
		RAISE;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
WF_CORE.CONTEXT('PA_BUDGET_WF','REJECT_BUDGET', itemtype, itemkey, to_char(actid), funcmode);
		RAISE;

WHEN OTHERS
    THEN
	WF_CORE.CONTEXT('PA_BUDGET_WF','REJECT_BUDGET', itemtype, itemkey, to_char(actid), funcmode);
	RAISE;



END Reject_Budget;

-- =================================================
--Name:              	Select_Budget_Approver
--Type:               	Procedure
--Description:     	This procedure will call a client extension  that will return the
--                      correct ID of the person that must approve a budget
--		        for baselining.
--
--
--Called subprograms: PA_CLIENT_EXTN_BUDGET_WF.select_budget_approver
--
--      * * * R12 MOAC Notes:
--
--            This procedure requires a single project/OU context.
--
--
--
--History:
--    	28-FEB-97       L. de Werker    - Created
--	24-JUN-97	jwhite		- Updated to latest specs
--	26-SEP-97	jwhite		- Updated WF error processing.
--	21-OCT-97	jwhite          - Updated as per Kevin Hudson's code review
--
--      23-AUG-02       jwhite          - Adapted to FP Model.
--
--
--      19-JUL-05       jwhite  -R12 MOAC Effort
--                               Added calls to the new Set_Prj_Policy_Context to enforce
--                               a single project/OU context for the Budget Approval
--                               Worklfow nodes.
--
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The notIFication process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   Resultout    - T/F
--
PROCEDURE Select_Budget_Approver
(itemtype			IN   	VARCHAR2
, itemkey  			IN   	VARCHAR2
, actid				IN	NUMBER
, funcmode			IN   	VARCHAR2
, resultout			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)

IS

        CURSOR 	l_baseliner_user_csr( p_baseliner_id NUMBER )
        IS
        SELECT 	f.user_id
                , f.user_name
                , e.first_name||' '||e.last_name
        FROM	fnd_user f
	        , pa_employees e
        WHERE   f.employee_id = p_baseliner_id
        AND     f.employee_id = e.person_id
		AND     TRUNC(SYSDATE) BETWEEN f.start_date AND nvl(f.end_date, TRUNC(SYSDATE)+1);  --Added : 7688624

l_workflow_started_by_id		NUMBER;
l_project_id			NUMBER;
l_budget_type_code		pa_budget_types.budget_type_code%TYPE;

l_baseliner_employee_id		NUMBER;

l_baseliner_user_id		NUMBER;
l_baseliner_user_name		VARCHAR2(100);
l_baseliner_full_name		VARCHAR2(400);

l_err_code  			NUMBER := 0;
l_msg_count			NUMBER;
l_msg_data			VARCHAR(2000);
l_return_status			VARCHAR2(1);
l_data				VARCHAR2(2000);
l_msg_index_out			NUMBER;
l_api_version_number		NUMBER		:= G_api_version_number;


l_fin_plan_type_id              NUMBER := NULL;
l_version_type                  pa_budget_versions.version_type%TYPE := NULL;
l_draft_version_id              NUMBER := NULL;

l_approver_role varchar2(50); -- Bug 6994708

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

-- GET BUDGET ITEM ATTRIBUTES  for Subsequent Processing -----------------------

	l_project_id := wf_engine.GetItemAttrNumber( 	itemtype  	=> itemtype,
			    				itemkey   	=> itemkey,
			    				aname  		=> 'PROJECT_ID' );

	l_workflow_started_by_id := wf_engine.GetItemAttrNumber(itemtype  	=> itemtype,
				    				itemkey   	=> itemkey,
				    				aname  		=> 'WORKFLOW_STARTED_BY_ID' );

	l_budget_type_code := wf_engine.GetItemAttrText(itemtype  	=> itemtype,
				    			itemkey   	=> itemkey,
				    			aname  		=> 'BUDGET_TYPE_CODE' );


        l_draft_version_id := wf_engine.GetItemAttrNumber(itemtype  	=> itemtype,
				    				itemkey   	=> itemkey,
				    				aname  		=> 'DRAFT_VERSION_ID' );

        l_fin_plan_type_id := wf_engine.GetItemAttrNumber(itemtype  	=> itemtype,
				    			  itemkey   	=> itemkey,
				    			  aname  		=> 'FIN_PLAN_TYPE_ID' );

        l_version_type  := wf_engine.GetItemAttrText(itemtype  	=> itemtype,
				    			itemkey   	=> itemkey,
				    			aname  		=> 'VERSION_TYPE' );




/*Commented for bug 5233870*/
-- SET GLOBALS ------------------------------------------------------------------

-- Based on the Responsibility, Intialize the Application
-- Un Commented for bug 8464143.
       PA_WORKFLOW_UTILS.Set_Global_Attr
                                 (p_item_type => itemtype
                                  , p_item_key  => itemkey
                                  , p_err_code  => l_err_code
                                 );


-- R12 MOAC, 19-JUL-05, jwhite -------------------
-- Set Single Project/OU context

   PA_BUDGET_UTILS.Set_Prj_Policy_Context
       (p_project_id => l_project_id
        ,x_return_status => l_return_status
        ,x_msg_count     => l_msg_count
        ,x_msg_data      => l_msg_data
        ,x_err_code      => l_err_code
        );

   IF (l_err_code <> 0)
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

 -- -----------------------------------------------


	PA_CLIENT_EXTN_BUDGET_WF.Select_Budget_Approver
	(p_item_type			=> itemtype
	,p_item_key  			=> itemkey
	,p_project_id			=> l_project_id
        ,p_budget_type_code		=> l_budget_type_code
        ,p_workflow_started_by_id	=> l_workflow_started_by_id
        ,p_fin_plan_type_id             => l_fin_plan_type_id
        ,p_version_type                 => l_version_type
        ,p_draft_version_id      => l_draft_version_id
	,p_budget_baseliner_id		=> l_baseliner_employee_id
	 );


        --ISSUE: a employee can have several users attached to it. So, this
        -- Code Retrieves the First User.


	IF (l_baseliner_employee_id IS NOT NULL)
	THEN

		OPEN 	l_baseliner_user_csr( l_baseliner_employee_id );

		FETCH 	l_baseliner_user_csr
		INTO 	l_baseliner_user_id
                        ,l_baseliner_user_name
                        ,l_baseliner_full_name;

		IF (l_baseliner_user_csr%FOUND)
                  THEN
			CLOSE l_baseliner_user_csr;

			wf_engine.SetItemAttrNumber
                        (itemtype   => itemtype,
			 itemkey  	=> itemkey,
			 aname 		=> 'BUDGET_BASELINER_ID',
			 avalue		=> l_baseliner_user_id );

		       wf_engine.SetItemAttrText
                        (itemtype  => itemtype,
		         itemkey   => itemkey,
			 aname 	   => 'BUDGET_BASELINER_NAME',
			 avalue		=>  l_baseliner_user_name);

		      wf_engine.SetItemAttrText
                        (itemtype  => itemtype,
		         itemkey   => itemkey,
		         aname 	   => 'BUDGET_BASELINER_FULL_NAME',
			 avalue	   =>  l_baseliner_full_name);

--Bug 6994708
-- For Reminder Notification From will be always the Baseliner

            l_approver_role := 'APPR_' ||itemtype ||  itemkey;

            WF_DIRECTORY.CreateAdHocRole( role_name         => l_approver_role
                                           , role_display_name => l_baseliner_full_name
                       , expiration_date   => sysdate+1
                                           );

                        wf_engine.SetItemAttrText
                        (itemtype   => itemtype,
                         itemkey          => itemkey,
                         aname                 => '#FROM_ROLE',
                         avalue                => l_approver_role );

--Bug 6994708

			resultout := wf_engine.eng_completed||':'||'T';
		ELSE

		    	CLOSE l_baseliner_user_csr;
		        resultout := wf_engine.eng_completed||':'||'F';
		END IF;
	ELSE

		resultout := wf_engine.eng_completed||':'||'F';
	END IF;


EXCEPTION

WHEN FND_API.G_EXC_ERROR
	THEN
	WF_CORE.CONTEXT('PA_BUDGET_WF','SELECT_BUDGET_APPROVER', itemtype, itemkey, to_char(actid), funcmode);
		RAISE;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
	WF_CORE.CONTEXT('PA_BUDGET_WF','SELECT_BUDGET_APPROVER', itemtype, itemkey, to_char(actid), funcmode);
		RAISE;

WHEN OTHERS
	THEN
	WF_CORE.CONTEXT('PA_BUDGET_WF','SELECT_BUDGET_APPROVER', itemtype, itemkey, to_char(actid), funcmode);
	RAISE;


END Select_Budget_Approver;


-- ==================================================

--Name		Verify_Budget_Rules
--Type:            	Procedure
--Description:      This procedure will call a client extension that will return a
--		 'T' or 'F', depending on whether all defined rules were met.
--
--
--Called subprograms: PA_BUDGET_UTILS.Verify_Budget_Rules
--PA_CLIENT_EXTN_BUDGET_WF.Verify_Budget_Rules
--
--
--Notes:
--
--      * * * R12 MOAC Notes:
--            This procedure requires a single project/OU context.
--
--
--History:
--    	28-FEB-97       L. de Werker   	- Created
--	24-JUN-97	jwhite		- Updated to latest specs
--	09-SEP-97	jwhite		- Updated to latest specs
--	26-SEP-97	jwhite		- Updated WF error processing.
--	21-OCT-97	jwhite		- Updated as per Kevin Hudson's code review
--
--	03-MAY-01	jwhite	        - As per the Non-Project Integration
--				          development effort, referenced the following
--                                        attributes:
--                                        1. bgt_intg_flag
--
--      23-AUG-02       jwhite          - Adapted to the new FP model.
--
--      19-JUL-05       jwhite          -R12 MOAC Effort
--                                       Added calls to the new Set_Prj_Policy_Context to enforce
--                                       a single project/OU context for the Budget Approval
--                                       Workflow nodes.
--
--
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The notIFication process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   Resultout    - T/F
--
PROCEDURE Verify_Budget_Rules
( itemtype	in varchar2
, itemkey  	in varchar2
, actid		in number
, funcmode	in varchar2
, resultout	out NOCOPY varchar2 --File.Sql.39 bug 4440895
)

IS
--



-- Local Variables
l_workflow_started_by_id		NUMBER;
l_project_id			NUMBER;
l_budget_type_code		pa_budget_types.budget_type_code%TYPE;


l_warnings_only_flag		VARCHAR2(1);
l_warnings_only			VARCHAR2(1)		:= 'Y';
l_err_msg_count			NUMBER		:= 0;
l_mark_as_original		pa_budget_versions.current_original_flag%TYPE;
l_resource_list_id              NUMBER;
l_project_type_class_code       pa_project_types.project_type_class_code%TYPE;

l_msg_count			NUMBER;
l_msg_data			VARCHAR(2000);
l_return_status			VARCHAR2(1);
l_data				VARCHAR2(2000);
l_msg_index_out			NUMBER;
l_api_version_number		NUMBER		:= G_api_version_number;

l_err_code			NUMBER		:= 0;
l_err_stage			VARCHAR2(120);
l_err_stack			VARCHAR2(630);

l_bgt_intg_flag                 VARCHAR2(1)     := NULL;

l_fin_plan_type_id              NUMBER := NULL;
l_version_type                  pa_budget_versions.version_type%TYPE := NULL;
l_draft_version_id       NUMBER := NULL;


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

-- GET BUDGET ITEM ATTRIBUTES  for Subsequent Processing -----------------------

	l_project_id := wf_engine.GetItemAttrNumber( 	itemtype  	=> itemtype,
			    				itemkey   	=> itemkey,
			    				aname  		=> 'PROJECT_ID' );

	l_workflow_started_by_id := wf_engine.GetItemAttrNumber(itemtype  	=> itemtype,
				    				itemkey   	=> itemkey,
				    				aname  		=> 'WORKFLOW_STARTED_BY_ID' );

	l_budget_type_code := wf_engine.GetItemAttrText(itemtype  	=> itemtype,
				    			itemkey   	=> itemkey,
				    			aname  		=> 'BUDGET_TYPE_CODE' );

	l_mark_as_original := wf_engine.GetItemAttrText(itemtype  	=> itemtype,
				    			itemkey   	=> itemkey,
				    			aname  		=> 'MARK_AS_ORIGINAL' );

        l_resource_list_id := wf_engine.GetItemAttrText(itemtype  	=> itemtype,
				    			itemkey   	=> itemkey,
				    			aname  		=>'RESOURCE_LIST_ID');

        l_project_type_class_code  := wf_engine.GetItemAttrText(itemtype  => itemtype,
				    			itemkey   	=> itemkey,
				    			aname  		=>'PROJECT_TYPE_CLASS_CODE');

        l_bgt_intg_flag := wf_engine.GetItemAttrText(itemtype           => itemtype,
				    			itemkey   	=> itemkey,
				    			aname  		=>'BGT_INTG_FLAG');


        l_draft_version_id := wf_engine.GetItemAttrNumber(itemtype  	=> itemtype,
				    				itemkey   	=> itemkey,
				    				aname  		=> 'DRAFT_VERSION_ID' );

        l_fin_plan_type_id := wf_engine.GetItemAttrNumber(itemtype  	=> itemtype,
				    			  itemkey   	=> itemkey,
				    			  aname  		=> 'FIN_PLAN_TYPE_ID' );

        l_version_type  := wf_engine.GetItemAttrText(itemtype  	=> itemtype,
				    			itemkey   	=> itemkey,
				    			aname  		=> 'VERSION_TYPE' );





-- SET GLOBALS -----------------------------------------------------------------

   -- Based on the Responsibility, Intialize the Application
   /*Commented for bug 5233870*/
-- Un Commented for bug 8464143.
   PA_WORKFLOW_UTILS.Set_Global_Attr
                 (p_item_type => itemtype
                 , p_item_key  => itemkey
                 , p_err_code  => l_err_code);


   -- R12 MOAC, 19-JUL-05, jwhite -------------------
   -- Set Single Project/OU context

   PA_BUDGET_UTILS.Set_Prj_Policy_Context
       (p_project_id => l_project_id
        ,x_return_status => l_return_status
        ,x_msg_count     => l_msg_count
        ,x_msg_data      => l_msg_data
        ,x_err_code      => l_err_code
        );

   IF (l_err_code <> 0)
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- -----------------------------------------------



   -- Populate Package Global for Conditional Budget Integration Processing in the
   -- Verify_Budget_Rules Procedures.
   PA_BUDGET_UTILS.G_Bgt_Intg_Flag := l_bgt_intg_flag;

-- ------------------------------------------------------------------------------------
-- NON-WF Verify Budget Rules
-- ------------------------------------------------------------------------------------

-- Edits Here Obsoleted by the FP Model Dev Effort.


-- SUBMISSION RULES -------------------------------------------------------------
--dbms_output.put_line('Verify Budget Rules - SUBMIT');


     PA_BUDGET_UTILS.VERIFY_BUDGET_RULES
    (p_draft_version_id		=>	l_draft_version_id
    , p_mark_as_original        =>	l_mark_as_original
    , p_event			=>	'SUBMIT'
    , p_project_id              =>	l_project_id
    , p_budget_type_code        =>	l_budget_type_code
    , p_resource_list_id        =>	l_resource_list_id
    , p_project_type_class_code	=>	l_project_type_class_code
    , p_created_by              =>	l_workflow_started_by_id
    , p_calling_module		=>	'PAWFBUVB'
    , p_fin_plan_type_id        =>      l_fin_plan_type_id
    , p_version_type            =>      l_version_type
    , p_warnings_only_flag      => 	l_warnings_only_flag
    , p_err_msg_count		=> 	l_err_msg_count
    , p_err_code                => 	l_err_code
    , p_err_stage               => 	l_err_stage
    , p_err_stack               => 	l_err_stack
    );

   IF (l_err_msg_count > 0 )
    THEN
	PA_WORKFLOW_UTILS.Set_Notification_Messages
	(p_item_type  	=> itemtype
	, p_item_key   	=> itemkey
	);
	IF (l_warnings_only_flag = 'N') THEN
		l_warnings_only := 'N';
	END IF;
   END IF;



-- BASELINE RULES -------------------------------------------------------------
     PA_BUDGET_UTILS.VERIFY_BUDGET_RULES
    (p_draft_version_id		=>	l_draft_version_id
    , p_mark_as_original        =>	l_mark_as_original
    , p_event			=>	'BASELINE'
    , p_project_id              =>	l_project_id
    , p_budget_type_code        =>	l_budget_type_code
    , p_resource_list_id        =>	l_resource_list_id
    , p_project_type_class_code	=>	l_project_type_class_code
    , p_created_by              =>	l_workflow_started_by_id
    , p_calling_module		=>	'PAWFBUVB'
    , p_fin_plan_type_id        =>      l_fin_plan_type_id
    , p_version_type            =>      l_version_type
    , p_warnings_only_flag      => 	l_warnings_only_flag
    , p_err_msg_count		=> 	l_err_msg_count
    , p_err_code                => 	l_err_code
    , p_err_stage               => 	l_err_stage
    , p_err_stack               => 	l_err_stack
    );



    IF (l_err_msg_count > 0 )
     THEN
	PA_WORKFLOW_UTILS.Set_Notification_Messages
	(p_item_type  	=> itemtype
	, p_item_key   	=> itemkey
	);
	IF (l_warnings_only_flag = 'N') THEN
		l_warnings_only := 'N';
	END IF;
    END IF;


-- ------------------------------------------------------------------------------------
-- WORKFLOW Verify Budget Rules
-- ------------------------------------------------------------------------------------

	PA_CLIENT_EXTN_BUDGET_WF.Verify_Budget_Rules
 	(p_item_type			=> itemtype
	 , p_item_key  			=> itemkey
	 , p_project_id			=> l_project_id
	 , p_budget_type_code		=> l_budget_type_code
	 , p_workflow_started_by_id	=> l_workflow_started_by_id
	 , p_event			=> 'SUBMIT'
         , p_fin_plan_type_id           => l_fin_plan_type_id
         , p_version_type               => l_version_type
	 , p_warnings_only_flag		=> l_warnings_only_flag
	 , p_err_msg_count		=> l_err_msg_count
	 );


	IF (l_err_msg_count > 0 )
	THEN
		PA_WORKFLOW_UTILS.Set_Notification_Messages
		(p_item_type  	=> itemtype
   		, p_item_key   	=> itemkey
		);
		IF (l_warnings_only_flag = 'N') THEN
			l_warnings_only := 'N';
		END IF;
	END IF;

	PA_CLIENT_EXTN_BUDGET_WF.Verify_Budget_Rules
 	(p_item_type			=> itemtype
	 , p_item_key  			=> itemkey
	 , p_project_id			=> l_project_id
	 , p_budget_type_code		=> l_budget_type_code
	 , p_workflow_started_by_id	=> l_workflow_started_by_id
	 , p_event			=> 'BASELINE'
         , p_fin_plan_type_id           => l_fin_plan_type_id
         , p_version_type               => l_version_type
	 , p_warnings_only_flag		=> l_warnings_only_flag
	 , p_err_msg_count		=> l_err_msg_count
	 );


	IF (l_err_msg_count > 0 )
	THEN
		PA_WORKFLOW_UTILS.Set_Notification_Messages
		(p_item_type  	=> itemtype
   		, p_item_key   	=> itemkey
		);
		IF (l_warnings_only_flag = 'N') THEN
			l_warnings_only := 'N';
		END IF;
	END IF;


	IF (l_warnings_only = 'Y')
	THEN
		resultout := wf_engine.eng_completed||':'||'T';
	ELSE
		resultout := wf_engine.eng_completed||':'||'F';
	END IF;

	--

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR
	THEN
           WF_CORE.CONTEXT('PA_BUDGET_WF','VERIFY_BUDGET_RULES', itemtype, itemkey, to_char(actid), funcmode);
	   RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
           WF_CORE.CONTEXT('PA_BUDGET_WF','VERIFY_BUDGET_RULES', itemtype, itemkey, to_char(actid), funcmode);
	   RAISE;

    WHEN OTHERS THEN
	WF_CORE.CONTEXT('PA_BUDGET_WF','VERIFY_BUDGET_RULES', itemtype, itemkey, to_char(actid), funcmode);
	RAISE;


END Verify_Budget_Rules;

-- ==================================================###
--Name:               Baseline_Budget
--Type:               	Procedure
--Description: 	This procedures performs BASELINE verification,
--		baseline functionality via the core baseline
--		procedure, and directly updates the draft budget.
--
--
--
--
--Called subprograms: PA_BUDGET_UTILS.Verify_Budget_Rules
--	, PA_CLIENT_EXTN_BUDGET_WF.Verify_Budget_Rules
--	, PA_BUDGET_UTILS.Baseline_Budget
--	, PA_WORKFLOW_UTILS.Insert_WF_Processes
--
--
--Notes:
--
--      * * * R12 MOAC Notes:
--            This procedure requires a single project/OU context.
--
--
--History:
--    	28-FEB-1997      L. de Werker   - Created
--	24-JUN-97	jwhite		- Updated
--	23-AUG-97	jwhite		- Updated to latest specs.
--	09-SEP-97	jwhite		- Updated to lastest specs.
--	17-SEP-97	jwhite		- Added Insert_WF_Processes to
--				  	  Baseline_Budget procedure.
--	26-SEP-97	jwhite		- Updated WF error processing.
--	21-OCT-97	jwhite		- Updated as per Kevin Hudson's code review
--
--	08-MAY-01	jwhite	        - As per the Non-Project Integration
--				          development effort, substituted the core
--                                        baseline procedure with the new
--                                        wrapper baseline_budget procedure.
--
--      23-AUG-02       jwhite          - Adapted to new FP model.
--
--	16-OCT-02	jwhite      	- Oops!
--                                        For BASELINE_BUDGET api, added conditional call logic for
--                                        the FP Baseline procedure.
--
--      23-AUG-05       jwhite          - R12 SLA Effort, Phase II
--                                        1) Changed logic to test for FND_API.G_RET_STS_SUCCESS
--                                        2) Populate Notifcation messages for successful budget integration
--
--
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The notIFication process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   Resultout    - T/F
--
--
--
PROCEDURE Baseline_Budget
(itemtype			IN   	VARCHAR2
, itemkey  			IN   	VARCHAR2
, actid                         IN	NUMBER
, funcmode			IN   	VARCHAR2
, resultout			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)

     IS



      -- R11.5.7 Budgets Model  -----------------------
      CURSOR l_baseline_csr
    		( p_project_id NUMBER
    		, p_budget_type_code VARCHAR2 )

      IS
      SELECT  MAX(budget_version_id)
      FROM   pa_budget_versions
      WHERE project_id 		= p_project_id
      AND   budget_type_code 	= p_budget_type_code
      AND   budget_status_code 	= 'B';


      -- FP Plan Model -----------------------

      -- Note: This cursor can have NO_DATA_FOUND
      CURSOR l_fp_baseline_csr ( p_project_id NUMBER
                                  , p_fin_plan_type_id  NUMBER
                                  , p_version_type VARCHAR2)
      IS
      SELECT budget_version_id
             , RECORD_VERSION_NUMBER
      FROM   pa_budget_versions
      WHERE  project_id   = p_project_id
      AND    current_flag   = 'Y'
      and    fin_plan_type_id  = p_fin_plan_type_id
      and    version_type = p_version_type;


      CURSOR l_fp_draft_csr ( p_draft_version_id NUMBER)
      IS
      SELECT RECORD_VERSION_NUMBER
      FROM   pa_budget_versions
      WHERE  budget_version_id = p_draft_version_id;




      -- Local Variable Declaration ---------------

l_workflow_started_by_id        NUMBER;
l_baseliner_id			NUMBER;
l_project_id			NUMBER;
l_budget_type_code		pa_budget_types.budget_type_code%TYPE;

l_row_found			NUMBER;
l_baselined_version_id		NUMBER;

l_api_version_number		NUMBER		:= G_api_version_number;
l_msg_count			NUMBER;
l_msg_data			VARCHAR(2000);
l_return_status			VARCHAR2(1);
l_pm_product_code		pa_projects.pm_product_code%TYPE	:='WORKFLOW';
l_data				VARCHAR2(2000);
l_msg_index_out			NUMBER;


l_warnings_only_flag		VARCHAR2(1);
l_warnings_only			VARCHAR2(1)		:= 'Y';
l_err_msg_count			NUMBER;
l_mark_as_original		pa_budget_versions.current_original_flag%TYPE;
l_resource_list_id              NUMBER;
l_project_type_class_code       pa_project_types.project_type_class_code%TYPE;

l_err_code			NUMBER			:= 0;
l_err_stage			VARCHAR2(120)		:= NULL;
l_err_stack			VARCHAR2(630);

l_bgt_intg_flag                 VARCHAR2(1)     := NULL;
l_fck_req_flag                  VARCHAR2(1)     := NULL;

l_fin_plan_type_id              NUMBER := NULL;
l_version_type                  pa_budget_versions.version_type%TYPE := NULL;
l_draft_version_id              NUMBER := NULL;
l_baselined_record_number       NUMBER := NULL;
l_draft_record_number           NUMBER := NULL;
l_fc_version_created_flag       VARCHAR2(1);
l_resp_id              		NUMBER ; -- Bug 8464143


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


      -- GET BUDGET ITEM ATTRIBUTES  for Subsequent Processing -----------------------

	l_project_id := wf_engine.GetItemAttrNumber( 	itemtype  	=> itemtype,
			    				itemkey   	=> itemkey,
			    				aname  		=> 'PROJECT_ID' );


	l_budget_type_code := wf_engine.GetItemAttrText(itemtype  	=> itemtype,
				    			itemkey   	=> itemkey,
				    			aname  		=> 'BUDGET_TYPE_CODE' );

	l_workflow_started_by_id := wf_engine.GetItemAttrNumber(itemtype  => itemtype,
				    				itemkey   => itemkey,
				    				aname  	=> 'WORKFLOW_STARTED_BY_ID' );


	l_baseliner_id := wf_engine.GetItemAttrNumber(	itemtype  	=> itemtype,
				    			itemkey   	=> itemkey,
				    			aname  		=> 'BUDGET_BASELINER_ID' );

	l_mark_as_original := wf_engine.GetItemAttrText(itemtype  	=> itemtype,
				    			itemkey   	=> itemkey,
				    			aname  		=> 'MARK_AS_ORIGINAL' );

         l_resource_list_id := wf_engine.GetItemAttrText(itemtype  	=> itemtype,
				    			itemkey   	=> itemkey,
				    			aname  		=>'RESOURCE_LIST_ID');

         l_project_type_class_code := wf_engine.GetItemAttrText(itemtype => itemtype,
				    			itemkey   	 => itemkey,
				    			aname  		 => 'PROJECT_TYPE_CLASS_CODE');

        l_bgt_intg_flag := wf_engine.GetItemAttrText(itemtype           => itemtype,
				    			itemkey   	=> itemkey,
				    			aname  		=>'BGT_INTG_FLAG');

        l_fck_req_flag := wf_engine.GetItemAttrText(itemtype           => itemtype,
				    			itemkey   	=> itemkey,
				    			aname  		=>'FCK_REQ_FLAG');



        l_draft_version_id := wf_engine.GetItemAttrNumber(itemtype  	=> itemtype,
				    				itemkey   	=> itemkey,
				    				aname  		=> 'DRAFT_VERSION_ID' );

        l_fin_plan_type_id := wf_engine.GetItemAttrNumber(itemtype  	=> itemtype,
				    			  itemkey   	=> itemkey,
				    			  aname  		=> 'FIN_PLAN_TYPE_ID' );

        l_version_type  := wf_engine.GetItemAttrText(itemtype  	=> itemtype,
				    			itemkey   	=> itemkey,
				    			aname  		=> 'VERSION_TYPE' );



--Bug 2162949
  G_baselined_by_user_id :=l_baseliner_id;

-- SET GLOBALS -----------------------------------------------------------------
   /*Commented for bug 5233870
   -- Based on the Responsibility, Intialize the Application
   PA_WORKFLOW_UTILS.Set_Global_Attr
                 (p_item_type => itemtype
                 , p_item_key  => itemkey
                 , p_err_code  => l_err_code);
   */

-- Bug 8464143
l_resp_id := wf_engine.GetItemAttrNumber
            (itemtype   => itemtype,
             itemkey    => itemkey,
             aname      => 'RESPONSIBILITY_ID' );

IF l_baseliner_id is NOT NULL THEN
     FND_GLOBAL.Apps_Initialize
        (   user_id             => l_baseliner_id
          , resp_id             => l_resp_id
          , resp_appl_id        => pa_workflow_utils.get_application_id(l_resp_id)
        );
ELSE
     Pa_workflow_utils.Set_Global_Attr (p_item_type => itemtype,
                                   p_item_key  => itemkey,
                                   p_err_code  => l_err_code);
END IF;
--  End Bug 8464143


   -- R12 MOAC, 19-JUL-05, jwhite -------------------
   -- Set Single Project/OU context

   PA_BUDGET_UTILS.Set_Prj_Policy_Context
       (p_project_id => l_project_id
        ,x_return_status => l_return_status
        ,x_msg_count     => l_msg_count
        ,x_msg_data      => l_msg_data
        ,x_err_code      => l_err_code
        );

   IF (l_err_code <> 0)
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- -----------------------------------------------



   -- Populate Package Global for Conditional Budget Integration Processing in the
   -- Verify_Budget_Rules Procedures.
   PA_BUDGET_UTILS.G_Bgt_Intg_Flag := l_bgt_intg_flag;




-- ------------------------------------------------------------------------------------
-- NON-WF Verify Budget Rules
-- ------------------------------------------------------------------------------------

   PA_BUDGET_UTILS.VERIFY_BUDGET_RULES
    (p_draft_version_id		=>	l_draft_version_id
    , p_mark_as_original        =>	l_mark_as_original
    , p_event			=>	'BASELINE'
    , p_project_id              =>	l_project_id
    , p_budget_type_code        =>	l_budget_type_code
    , p_resource_list_id        =>	l_resource_list_id
    , p_project_type_class_code	=>	l_project_type_class_code
    , p_created_by              =>	l_workflow_started_by_id
    , p_calling_module		=>	'PAWFBUVB'
    , p_fin_plan_type_id        =>      l_fin_plan_type_id
    , p_version_type            =>      l_version_type
    , p_warnings_only_flag      => 	l_warnings_only_flag
    , p_err_msg_count		=> 	l_err_msg_count
    , p_err_code                => 	l_err_code
    , p_err_stage               => 	l_err_stage
    , p_err_stack               => 	l_err_stack
    );



  IF (l_err_msg_count > 0 )
   THEN
	PA_WORKFLOW_UTILS.Set_Notification_Messages
	(p_item_type  	=> itemtype
	, p_item_key   	=> itemkey
	);
	IF (l_warnings_only_flag = 'N') THEN
		l_warnings_only := 'N';
	END IF;
  END IF;


-- ------------------------------------------------------------------------------------
-- WORKFLOW Verify Budget Rules
-- ------------------------------------------------------------------------------------


	PA_CLIENT_EXTN_BUDGET_WF.Verify_Budget_Rules
 	(p_item_type			=> itemtype
	 , p_item_key  			=> itemkey
	 , p_project_id			=> l_project_id
	 , p_budget_type_code		=> l_budget_type_code
	 , p_workflow_started_by_id	=> l_workflow_started_by_id
	 , p_event			=> 'BASELINE'
         , p_fin_plan_type_id           => l_fin_plan_type_id
         , p_version_type               => l_version_type
	 , p_warnings_only_flag		=> l_warnings_only_flag
	 , p_err_msg_count		=> l_err_msg_count
	 );


	IF (l_err_msg_count > 0 )
	THEN
		PA_WORKFLOW_UTILS.Set_Notification_Messages
		(p_item_type  	=> itemtype
   		, p_item_key   	=> itemkey
		);
		IF (l_warnings_only_flag = 'N') THEN
			l_warnings_only := 'N';
		END IF;
	END IF;

-- ---------------------------------------------------------------------------------------
--  BASELINE THIS BUDGET VERSION if only warnings
--  Make sure verify budget rules NOT called again:
--      x_verify_budget_rules	=> 'N'
-- ---------------------------------------------------------------------------------------

	IF (l_warnings_only = 'Y')
	THEN


          IF (l_budget_type_code IS NULL)
             THEN

             -- This is a FINANCIAL PLAN Model Entity ----------------------

             -- Get IN-parameters for FP Baseline Call

                  -- Fetch existing baseline FP data, if any
    		  OPEN l_fp_baseline_csr ( l_project_id, l_fin_plan_type_id, l_version_type );
       		  FETCH l_fp_baseline_csr INTO l_baselined_version_id, l_baselined_record_number;
                  IF (l_fp_baseline_csr%NOTFOUND)
                     THEN
                         l_baselined_version_id  := NULL;
                         l_baselined_record_number := NULL;
                  END IF;
                  CLOSE l_fp_baseline_csr;


                  -- Fetch Current Working Version FP Data
    		  OPEN l_fp_draft_csr ( l_draft_version_id  );
       		  FETCH l_fp_draft_csr INTO l_draft_record_number;
                  IF (l_fp_draft_csr%NOTFOUND)
                     THEN
                         l_draft_record_number := NULL;
                  END IF;
                  CLOSE l_fp_draft_csr;


                  PA_FIN_PLAN_PUB.Baseline
                            (p_project_id                   => l_project_id
                             , p_budget_version_id          => l_draft_version_id
                             , p_record_version_number      => l_draft_record_number
                             , p_orig_budget_version_id     => l_baselined_version_id
                             , p_orig_record_version_number => l_baselined_record_number
                             , x_fc_version_created_flag    => l_fc_version_created_flag
                             , x_return_status              => l_return_status
                             , x_msg_count                  => l_msg_count
                             , x_msg_data                   => l_msg_data
                             );

                  -- Any message or stutus other than 'S', then initiate Workflow Failure.

                  IF ( (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                         OR (l_msg_count > 0)
                      )
		          THEN

                          PA_WORKFLOW_UTILS.Set_Notification_Messages
	                    (p_item_type  	=> itemtype
	                     , p_item_key   	=> itemkey
	                     );

	                        resultout := wf_engine.eng_completed||':'||'F';

                         /* 4995380: Added code to set the WF status to 'REJECTED'
                            so that the changes can be done and the Baseline can be submitted
                            once again, if Baseline fails. */
                             UPDATE pa_budget_versions
                             SET budget_status_code = 'W'
                               , wf_status_code = 'REJECTED'
                             WHERE budget_version_id = l_draft_version_id;

    	                  RETURN ;

                  END IF; -- FP Baseline Failure



           ELSE
              -- This is a r11.5.7 B-U-D-G-E-T Model Entity  ----------------------


             -- Call the following wrapper API, which also performs funds checking if required.

             PA_BUDGET_UTILS.Baseline_Budget
                   ( p_draft_version_id     => l_draft_version_id
                   ,p_project_id            => l_project_id
                   ,p_mark_as_original	    => l_mark_as_original
                   ,p_verify_budget_rules   => 'N'
                   ,p_fck_req_flag          => l_fck_req_flag
                   ,x_msg_count             => l_msg_count
                   ,x_msg_data              => l_msg_data
                   ,x_return_status         => l_return_status
                   );


             -- With the advent of Non-Project Budget Integration,
             -- Application Errors may be returned by the new wrapper Baseline_Budget API.
             -- Therefore, original r11.0 code is augmented, accordingly.

             -- Begin: R12 SLA Effort, Phase II, 23-AUG-2005, jwhite -------------------

             IF (  (l_return_status = FND_API.G_RET_STS_SUCCESS)
                      AND  ( l_fck_req_flag = 'Y') )
		THEN
                    -- Budget Integration must have been successful
                    -- Following call will display success message for Budget Integration
                    PA_WORKFLOW_UTILS.Set_Notification_Messages
	                (p_item_type  	=> itemtype
	                 , p_item_key 	=> itemkey
	                );


             END IF;

             -- For error handling, changed 'IF (l_msg_count > 0)' reference to l_return_status

             IF ((l_return_status <> FND_API.G_RET_STS_SUCCESS) OR (l_msg_count > 0)) -- Bug 4995380
		        THEN
                   -- Error! Baseline Failed. ------------------

                   --Populate Notification Message Text
  	           PA_WORKFLOW_UTILS.Set_Notification_Messages
	           (p_item_type  	=> itemtype
	           , p_item_key   	=> itemkey
	           );

                   -- R12 SLA Phase II, 23-AUG-2005, jwhite ----------------------
                   -- Since baseline will fail more often with new R12 functionality, Need to
                   -- properly populate draft version semaphores.
                   --
                   -- Update WF Status on Draft Budget Version
                   UPDATE pa_budget_versions SET
	                   budget_status_code = 'W'
                      ,WF_status_code = 'REJECTED'
 	               WHERE  budget_version_id = l_draft_version_id;
                   -- -------------------------------------------------------------

                   -- FAIL Workflow and Exit
	           resultout := wf_engine.eng_completed||':'||'F';
    	           RETURN ;

             END IF; -- l_return_status <> FND_API.G_RET_STS_SUCCESS

             -- End: R12 SLA Effort, Phase II, 23-AUG-2005, jwhite -------------------


          END IF; -- r1157/FP Model Baseline Processing

          --
          -- Insert a Row into the PA_WF_PROCESSES Table
          -- to Record the Workflow Associated with the Baselined
          -- Budget
          --

                IF (l_budget_type_code IS NULL)
                  THEN
                  -- FP Plan Model

    		  OPEN l_fp_baseline_csr ( l_project_id, l_fin_plan_type_id, l_version_type );
       		  FETCH l_fp_baseline_csr INTO l_baselined_version_id, l_baselined_record_number;
                  CLOSE l_fp_baseline_csr;


                  ELSE
                  -- R11.5.7 Budgets Model

    		  OPEN l_baseline_csr (l_project_id,l_budget_type_code );
		  FETCH l_baseline_csr INTO l_baselined_version_id;
                  CLOSE l_baseline_csr;


                END IF;



	PA_WORKFLOW_UTILS.Insert_WF_Processes
	      (p_wf_type_code        	=> 'BUDGET'
	      ,p_item_type           	=> itemtype
	      ,p_item_key           	=> itemkey
	      ,p_entity_key1         	=> to_char(l_draft_version_id)
	      ,p_entity_key2		=> to_char(l_baselined_version_id)
	      ,p_description         	=> NULL
	      ,p_err_code            	=> l_err_code
	      ,p_err_stage           	=> l_err_stage
	      ,p_err_stack           	=> l_err_stack
	      );

		IF (l_err_code <> 0)
		     THEN
			WF_CORE.CONTEXT('PA_BUDGET_CORE','BASELINE', itemtype, itemkey, to_char(actid), funcmode);
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

--
-- After Successfully calling BASELINE, Set The Budget_Status_Code
-- Back To 'W' (Working) and wf_status_code to NULL.
--

   	 UPDATE pa_budget_versions SET
	        budget_status_code = 'W'
                , wf_status_code = NULL
	 WHERE  budget_version_id = l_draft_version_id;



      END IF ; -- OK to Baseline



      IF (l_warnings_only = 'Y')
       THEN
	    resultout := wf_engine.eng_completed||':'||'T';
      ELSE
            /* 4995380: Added code to set the WF status to 'REJECTED'
            so that the changes can be done and the Baseline can be submitted
            once again, if there are any errors and l_warnings_only = 'N'. */
             UPDATE pa_budget_versions
             SET budget_status_code = 'W'
               , wf_status_code = 'REJECTED'
             WHERE budget_version_id = l_draft_version_id;
	    resultout := wf_engine.eng_completed||':'||'F';
      END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR
	THEN
WF_CORE.CONTEXT('PA_BUDGET_WF','BASELINE_BUDGET', itemtype, itemkey, to_char(actid), funcmode);
	RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
WF_CORE.CONTEXT('PA_BUDGET_WF','BASELINE_BUDGET', itemtype, itemkey, to_char(actid), funcmode);
	RAISE;

WHEN OTHERS THEN
	WF_CORE.CONTEXT('PA_BUDGET_WF','BASELINE_BUDGET', itemtype, itemkey, to_char(actid), funcmode);
	RAISE;

END Baseline_Budget;

--Name:                 IS_FEDERAL_ENABLED
--Type:                 Procedure
--Description:          This procedure is used to find if FV_ENABLED(Federal profile) option is enabled
--
--Called subprograms:   None
--
--Notes:
--  This is called from PA Budget Baseline Workflow to find if Federal Option is enabled. If yes, and also
--  if the BEM/Third part interface is successful, then a notification is sent to the Budget Approver to
--  inform the Budget Analyst to import the Budget data from Interface tables.

PROCEDURE IS_FEDERAL_ENABLED
(itemtype           IN      VARCHAR2
, itemkey           IN      VARCHAR2
, actid                         IN  NUMBER
, funcmode          IN      VARCHAR2
, resultout         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
Is
l_federal_enabled  VARCHAR2(1);
l_budget_type_code      pa_budget_types.budget_type_code%TYPE;

Begin

    l_budget_type_code := wf_engine.GetItemAttrText(itemtype    => itemtype,
                                itemkey     => itemkey,
                                aname       => 'BUDGET_TYPE_CODE' );


    l_federal_enabled := NVL(FND_PROFILE.value('FV_ENABLED'), 'N');


    If  l_federal_enabled = 'Y' and l_budget_type_code is NOT NULL then
        resultout := wf_engine.eng_completed||':'||'T';
    Else
        resultout := wf_engine.eng_completed||':'||'F';
    End if;

Return;
End IS_FEDERAL_ENABLED;


-- ====================================================
END pa_budget_wf;

/
