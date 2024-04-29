--------------------------------------------------------
--  DDL for Package Body GMS_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_WF_PKG" AS
/* $Header: gmsfbuvb.pls 120.8.12010000.3 2009/10/08 11:55:07 byeturi ship $ */


-- -------------------------------------------------------------------------------------
--	Globals
-- -------------------------------------------------------------------------------------

-- To check on, whether to print debug messages in log file or not
L_DEBUG varchar2(1) := NVL(FND_PROFILE.value('GMS_ENABLE_DEBUG_MODE'), 'N');

G_API_VERSION_NUMBER 	CONSTANT NUMBER := 1.0;

-- Bug 5162777 : The l_budget_versions_csr is moved out of the procedure Baseline_Budget.
-- Cursor for Verify Budget Rules and Core.Baseline Call

      CURSOR l_budget_versions_csr
    		( p_project_id NUMBER
		, p_award_id NUMBER
    		, p_budget_type_code VARCHAR2 )

      IS
      SELECT budget_version_id
      FROM   gms_budget_versions
      WHERE project_id 		= p_project_id
      AND   award_id            = p_award_id
      AND   budget_type_code 	= p_budget_type_code
      AND   budget_status_code 	in ('S','W');

-- -------------------------------------------------------------------------------------
--	Procedures
-- -------------------------------------------------------------------------------------

--Name: 		START_BUDGET_WF
--Type:               	Procedure
--Description:      This procedure is used to start a budget workflow process.
--
--
--Called subprograms:	GMS_CLIENT_EXTN_BUDGET_WF.Start_Budget_Wf
--			, GMS_WORKFLOW_UTILS.Insert_WF_Processes
--
--Notes:
--	This wrapper is called DIRECTLY from the Budgets form and the public
--	Baseline_Budget API.
--
--	!!! This wrapper is NOT CALLED FROM WORKFLOW !!!
--
--	Error messages in the form and public API call  the 'GMS_WF_CLIENT_EXTN'
--	error code. Two tokens are passed to the error message: the name of this
--	client extension and the error code.
--
--
--
--History:
--
-- IN Parameters
--   p_project_id			- Unique identifier for the project of the budget for which approval
--				   is requested.
--   p_budget_type_code		- Unique identifier for  budget submitted for approval
--   p_mark_as_original		-  Yes, mark budget as original; N, do not mark. Defaults to 'N'.
--
-- OUT NOCOPY Parameters
--   p_err_code			-  Standard error code: 0, Success; x < 0, Unexpected Error;
--				   x > 0, Business Rule Violated.
--   p_err_stage			-   Standard error message
--   p_err_stack			-   Not used.

-- -------------------
-- FUNCTION
-- Bug 3465169 : This function returns the Burden amount calculated
--               for  input parameters burdenable_raw_cost,expenditure_type
--               organization_id and ind_compiled_set_id.
--               This is introduced for performance fix inorder to avoid
--               a join with gms_commitment_encumbered_v .

FUNCTION Get_Burden_amount  (p_expenditure_type VARCHAR2,
                                p_organization_id  NUMBER,
				p_ind_compiled_set_id NUMBER,
				p_burdenable_raw_cost NUMBER)
   RETURN NUMBER IS
        CURSOR C_get_burden_amount IS
         SELECT SUM (p_burdenable_raw_cost * NVL(cm.compiled_multiplier,0))
           FROM pa_ind_rate_sch_revisions irsr,
	        pa_ind_cost_codes icc,
	        pa_cost_base_exp_types cbet,
	        pa_ind_compiled_sets ics,
  	        pa_compiled_multipliers cm
          WHERE irsr.cost_plus_structure = cbet.cost_plus_structure AND
                icc.ind_cost_code = cm.ind_cost_code AND
	        cbet.cost_base = cm.cost_base AND
	        ics.cost_base = cbet.cost_base AND
	        cbet.cost_base_type = 'INDIRECT COST' AND
		cbet.expenditure_type = p_expenditure_type AND
		ics.ind_rate_sch_revision_id = irsr.ind_rate_sch_revision_id AND
		ics.organization_id = p_organization_id AND
		ics.ind_compiled_set_id = p_ind_compiled_set_id AND
		cm.ind_compiled_set_id = p_ind_compiled_set_id ;

   l_burden_amount NUMBER;
   BEGIN

    OPEN C_get_burden_amount;
    FETCH C_get_burden_amount INTO l_burden_amount;
    CLOSE C_get_burden_amount;

    RETURN NVL(l_burden_amount,0);

END Get_Burden_amount;

PROCEDURE Start_Budget_Wf
(p_draft_version_id	IN	NUMBER
, p_project_id 		IN 	NUMBER
, p_award_id 		IN 	NUMBER
, p_budget_type_code	IN 	VARCHAR2
, p_mark_as_original	IN 	VARCHAR2
, p_err_code            IN OUT NOCOPY	NUMBER
, p_err_stage         	IN OUT NOCOPY	VARCHAR2
, p_err_stack         	IN OUT NOCOPY	VARCHAR2
)
--
IS
--

--	Local Variables

l_err_code	NUMBER;
l_item_type     gms_wf_processes.item_type%TYPE;
l_item_key	gms_wf_processes.item_key%TYPE;



BEGIN

GMS_CLIENT_EXTN_BUDGET_WF.Start_Budget_Wf
( p_draft_version_id		=>	p_draft_version_id
, p_project_id 			=>	p_project_id
, p_award_id 			=>	p_award_id
, p_budget_type_code		=>	p_budget_type_code
, p_mark_as_original		=>	p_mark_as_original
, p_item_type           	=> 	l_item_type
, p_item_key           		=> 	l_item_key
, p_err_code             	=>	l_err_code
, p_err_stage         		=> 	p_err_stage
, p_err_stack			=>	p_err_stack
);


IF (l_err_code = 0)
 THEN
-- Succesful! Log gms_wf_processes table for new workflow.

      GMS_WORKFLOW_UTILS.Insert_WF_Processes
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

-- ===================================================

--Name: 		START_BUDGET_WF_NTFY_ONLY
--
--Type:               	Procedure
--
--Description:      	This procedure is used to send a notification
--			when a budget is baselined.
--
--
--Called subprograms:	GMS_CLIENT_EXTN_BUDGET_WF.Start_Budget_Wf_Ntfy_Only
--			, GMS_WORKFLOW_UTILS.Insert_WF_Processes
--
--Notes:
--	This wrapper is called DIRECTLY from the Budgets form and the public
--	Baseline_Budget API.
--
--	!!! This wrapper is NOT CALLED FROM WORKFLOW !!!
--
--	Error messages in the form and public API call  the 'GMS_WF_CLIENT_EXTN'
--	error code. Two tokens are passed to the error message: the name of this
--	client extension and the error code.
--
--
--
--History:
--
-- IN Parameters
--   p_project_id			- Unique identifier for the project of the budget for which approval
--				   is requested.
--   p_budget_type_code		- Unique identifier for  budget submitted for approval
--   p_mark_as_original		-  Yes, mark budget as original; N, do not mark. Defaults to 'N'.
--
-- OUT NOCOPY Parameters
--   p_err_code			-  Standard error code: 0, Success; x < 0, Unexpected Error;
--				   x > 0, Business Rule Violated.
--   p_err_stage			-   Standard error message
--   p_err_stack			-   Not used.


PROCEDURE Start_Budget_Wf_Ntfy_Only
(p_draft_version_id	IN	NUMBER
, p_project_id 		IN 	NUMBER
, p_award_id 		IN 	NUMBER
, p_budget_type_code	IN 	VARCHAR2
, p_mark_as_original	IN 	VARCHAR2
, p_err_code            IN OUT NOCOPY	NUMBER
, p_err_stage         	IN OUT NOCOPY	VARCHAR2
, p_err_stack         	IN OUT NOCOPY	VARCHAR2
) IS

--	Local Variables

l_err_code	NUMBER;
l_item_type     gms_wf_processes.item_type%TYPE;
l_item_key	gms_wf_processes.item_key%TYPE;



BEGIN

GMS_CLIENT_EXTN_BUDGET_WF.Start_Budget_Wf_Ntfy_Only
( p_draft_version_id		=>	p_draft_version_id
, p_project_id 			=>	p_project_id
, p_award_id 			=>	p_award_id
, p_budget_type_code		=>	p_budget_type_code
, p_mark_as_original		=>	p_mark_as_original
, p_item_type           	=> 	l_item_type
, p_item_key           		=> 	l_item_key
, p_err_code             	=>	l_err_code
, p_err_stage         		=> 	p_err_stage
, p_err_stack			=>	p_err_stack
);


IF (l_err_code = 0)
 THEN
-- Succesful! Log gms_wf_processes table for new workflow.

      GMS_WORKFLOW_UTILS.Insert_WF_Processes
      (p_wf_type_code        	=> 'BUDGET_NTFY_ONLY'
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
	 -- Modified for Bug: 2510024
	 p_err_code 	:= 4;

END Start_Budget_Wf_Ntfy_Only;



-- =================================================
--
-- Name:        	IS_BUDGET_WF_USED
-- Type:               	Procedure
-- Description:      	This procedure must return a "T" or "F" depending on whether a workflow
--			should be started for this particular budget.
--
--
-- Called Subprograms:	GMS_CLIENT_EXTN_BUDGET_WF.Budget_Wf_Is_Used
--
--
--Notes:
--	This wrapper is called DIRECTLY from the Budgets form and the public
--	Baseline_Budget API.
--
--	!!! THIS WRAPPER IS NOT CALLED FROM WORKFLOW !!!
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
-- IN Parameters
--   p_project_id		- Unique identifier for the project of the budget for which approval
--				  is requested.
--   p_award_id			- Unique identifier for the award of the budget for which approval
--				  is requested.
--   p_budget_type_code		- Unique identifier for  budget submitted for approval
--   p_pm_product_code		- The PM vendor's product code stored in gms_budget_versions.
--
-- OUT NOCOPY Parameters
--   p_result    			- 'T' or 'F' (True/False)
--   p_err_code			-  Standard error code: 0, Success; x < 0, Unexpected Error;
--				   x > 0, Business Rule Violated.
--   p_err_stage		-   Standard error message
--   p_err_stack		-   Not used.
--

PROCEDURE Is_Budget_WF_Used
( p_project_id 			IN 	NUMBER
, p_award_id			IN 	NUMBER
, p_budget_type_code		IN 	VARCHAR2
, p_pm_product_code		IN 	VARCHAR2
, p_result			IN OUT NOCOPY VARCHAR2
, p_err_code             	IN OUT NOCOPY	NUMBER
, p_err_stage			IN OUT NOCOPY	VARCHAR2
, p_err_stack			IN OUT NOCOPY	VARCHAR2
)

IS
--

BEGIN

GMS_CLIENT_EXTN_BUDGET_WF.IS_BUDGET_WF_USED
( p_project_id 			=>	p_project_id
, p_award_id 			=>	p_award_id
, p_budget_type_code		=>	p_budget_type_code
, p_pm_product_code		=>	p_pm_product_code
, p_result			=>	p_result
, p_err_code             	=>	p_err_code
, p_err_stage         		=> 	p_err_stage
, p_err_stack			=>	p_err_stack
);


EXCEPTION

WHEN OTHERS
   THEN
	p_err_code 	:= SQLCODE;
	RAISE;


END Is_Budget_WF_Used;

-- =================================================
-- Name:              	Reject_Budget
-- Type:               	Procedure
-- Description:     	This procedure resets a given project-budget status
--			to a 'Working', 'Rejected'.
--
--
--
-- Called subprograms: 	NONE
--
--
--
-- History:
--
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The notIFication process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT NOCOPY
--   Resultout    - NULL
--

PROCEDURE Reject_Budget
(itemtype			IN   	VARCHAR2
, itemkey  			IN   	VARCHAR2
, actid				IN	NUMBER
, funcmode			IN   	VARCHAR2
, resultout			OUT NOCOPY	VARCHAR2
)
--
IS
--
-- ROW LOCKING

	CURSOR l_lock_budget_csr (p_project_id NUMBER, p_award_id NUMBER, p_budget_type_code VARCHAR2)
	IS
	SELECT 'x'
	FROM 	gms_budget_versions
	WHERE		project_id = p_project_id
	AND		award_id   = p_award_id
	AND		budget_type_code = p_budget_type_code
	AND		budget_status_code = 'S'
	FOR UPDATE NOWAIT;

-- Local Variables

l_project_id			NUMBER;
l_award_id   			NUMBER;
l_budget_type_code		pa_budget_types.budget_type_code%TYPE;

l_err_code  			NUMBER := 0;
l_msg_count			NUMBER;
l_msg_data			VARCHAR(2000);
l_return_status			VARCHAR2(1);
l_data				VARCHAR2(2000);
l_msg_index_out			NUMBER;
l_api_version_number		NUMBER		:= G_api_version_number;


--
BEGIN
	-- Return if WF Not Running

  	IF (funcmode <> wf_engine.eng_run) THEN
    		resultout := wf_engine.eng_null;
    		RETURN;
  	END IF;


-- GET BUDGET ITEM ATTRIBUTES  for Subsequent Processing -----------------------


	l_project_id := wf_engine.GetItemAttrNumber( 	itemtype  	=> itemtype,
			    				itemkey   	=> itemkey,
			    				aname  		=> 'PROJECT_ID' );

	l_award_id   := wf_engine.GetItemAttrNumber( 	itemtype  	=> itemtype,
			    				itemkey   	=> itemkey,
			    				aname  		=> 'AWARD_ID' );

	l_budget_type_code := wf_engine.GetItemAttrText(itemtype  	=> itemtype,
				    			itemkey   	=> itemkey,
				    			aname  		=> 'BUDGET_TYPE_CODE' );

-- SET GLOBALS ------------------------------------------------------------------

-- Based on the Responsibility, Intialize the Application
GMS_WORKFLOW_UTILS.Set_Global_Attr
 		(p_item_type => itemtype
                , p_item_key  => itemkey
   		, p_err_code  => l_err_code);
--Setting OU Context
   GMS_BUDGET_UTILS.Set_Award_Policy_Context (p_award_id => l_award_id
        ,x_return_status => l_return_status
        ,x_msg_count     => l_msg_count
        ,x_msg_data      => l_msg_data
        ,x_err_code      => l_err_code
        );

   IF (l_err_code <> 0)
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;



-- REVERT STATUS of Project-Budget to 'Working' , 'REJECTED' -----------------

-- LOCK Draft Budget Version

    	OPEN l_lock_budget_csr(l_project_id, l_award_id, l_budget_type_code);
    	CLOSE l_lock_budget_csr;

-- UPDATE Draft Budget Version

	UPDATE gms_budget_versions
	 SET budget_status_code = 'W', WF_status_code = 'REJECTED'
 	WHERE		project_id = l_project_id
 	AND		award_id =  l_award_id
	AND		budget_type_code = l_budget_type_code
	AND		budget_status_code = 'S';


	resultout := wf_engine.eng_completed;


EXCEPTION

WHEN FND_API.G_EXC_ERROR
	THEN
	WF_CORE.CONTEXT('GMS_WF_PKG','REJECT_BUDGET', itemtype, itemkey, to_char(actid), funcmode);
		RAISE;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
WF_CORE.CONTEXT('GMS_WF_PKG','REJECT_BUDGET', itemtype, itemkey, to_char(actid), funcmode);
		RAISE;

WHEN OTHERS
    THEN
	WF_CORE.CONTEXT('GMS_WF_PKG','REJECT_BUDGET', itemtype, itemkey, to_char(actid), funcmode);
	RAISE;



END Reject_Budget;

-- =================================================
-- Name:              	Select_Budget_Approver
-- Type:               	Procedure
-- Description:     	This procedure will call a client extension  that will return the
--			correct ID of the person that must approve a budget
--			for baselining.
--
--
-- Called subprograms: GMS_CLIENT_EXTN_BUDGET_WF.select_budget_approver
--
--
--
--History:
--
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The notIFication process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT NOCOPY
--   Resultout    - T/F
--
PROCEDURE Select_Budget_Approver
(itemtype			IN   	VARCHAR2
, itemkey  			IN   	VARCHAR2
, actid				IN	NUMBER
, funcmode			IN   	VARCHAR2
, resultout			OUT NOCOPY	VARCHAR2
)

IS
--
CURSOR 	l_baseliner_user_csr( p_baseliner_id NUMBER )
IS
SELECT 	f.user_id
,       f.user_name
,       p.first_name||' '||p.last_name
FROM	fnd_user f, per_people_f  p /*Bug 5122724 */
WHERE  p.effective_start_date = (SELECT min(pp.effective_start_date)
                                 FROM per_all_people_f pp where pp.person_id = p.person_id
                                 AND  pp.effective_end_date >=trunc(sysdate))
AND ((p.employee_number is not null) OR (p.npw_number is not null))
AND		f.employee_id = p_baseliner_id
AND		f.employee_id = p.person_id;
--

l_workflow_started_by_id	NUMBER;
l_project_id			NUMBER;
l_award_id			NUMBER;
l_budget_type_code		pa_budget_types.budget_type_code%TYPE;

l_baseliner_employee_id		NUMBER;

l_baseliner_user_id		NUMBER;
l_baseliner_user_name		VARCHAR2(100);
l_baseliner_full_name		VARCHAR2(240);

l_err_code  			NUMBER := 0;
l_msg_count			NUMBER;
l_msg_data			VARCHAR(2000);
l_return_status			VARCHAR2(1);
l_data				VARCHAR2(2000);
l_msg_index_out			NUMBER;
l_api_version_number		NUMBER		:= G_api_version_number;

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

	l_award_id   := wf_engine.GetItemAttrNumber( 	itemtype  	=> itemtype,
			    				itemkey   	=> itemkey,
			    				aname  		=> 'AWARD_ID' );

	l_workflow_started_by_id := wf_engine.GetItemAttrNumber(itemtype  	=> itemtype,
				    				itemkey   	=> itemkey,
				    				aname  		=> 'WORKFLOW_STARTED_BY_ID' );

	l_budget_type_code := wf_engine.GetItemAttrText(itemtype  	=> itemtype,
				    			itemkey   	=> itemkey,
				    			aname  		=> 'BUDGET_TYPE_CODE' );

-- SET GLOBALS ------------------------------------------------------------------

-- Based on the Responsibility, Intialize the Application
GMS_WORKFLOW_UTILS.Set_Global_Attr
 		(p_item_type => itemtype
                , p_item_key  => itemkey
   		, p_err_code  => l_err_code);

--Setting the OU Context
   GMS_BUDGET_UTILS.Set_Award_Policy_Context
       (p_award_id => l_award_id
        ,x_return_status => l_return_status
        ,x_msg_count     => l_msg_count
        ,x_msg_data      => l_msg_data
        ,x_err_code      => l_err_code
        );

   IF (l_err_code <> 0)
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


	GMS_CLIENT_EXTN_BUDGET_WF.Select_Budget_Approver
	(p_item_type			=> itemtype
	,p_item_key  			=> itemkey
	,p_project_id			=> l_project_id
	,p_award_id			=> l_award_id
        ,p_budget_type_code		=> l_budget_type_code
        ,p_workflow_started_by_id	=> l_workflow_started_by_id
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

		IF (l_baseliner_user_csr%FOUND) THEN
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
	WF_CORE.CONTEXT('GMS_WF_PKG','SELECT_BUDGET_APPROVER', itemtype, itemkey, to_char(actid), funcmode);
		RAISE;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
	WF_CORE.CONTEXT('GMS_WF_PKG','SELECT_BUDGET_APPROVER', itemtype, itemkey, to_char(actid), funcmode);
		RAISE;

WHEN OTHERS
	THEN
	WF_CORE.CONTEXT('GMS_WF_PKG','SELECT_BUDGET_APPROVER', itemtype, itemkey, to_char(actid), funcmode);
	RAISE;


END Select_Budget_Approver;


-- ==================================================
--Name			Verify_Budget_Rules
--Type:            	Procedure
--Description:      	This procedure will call a client extension that will return a
--		 	'T' or 'F', depending on whether all defined rules were met.
--
--
--Called subprograms: 	GMS_BUDGET_UTILS.Verify_Budget_Rules
--			GMS_CLIENT_EXTN_BUDGET_WF.Verify_Budget_Rules
--
--
--
--History:
--
-- IN
--   			itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   			itemkey   - A string generated from the application object's primary key.
--   			actid     - The notIFication process activity(instance id).
--   			funcmode  - Run/Cancel
-- OUT NOCOPY
--   			Resultout    - T/F
--
PROCEDURE Verify_Budget_Rules
( itemtype	in varchar2
, itemkey  	in varchar2
, actid		in number
, funcmode	in varchar2
, resultout	out NOCOPY varchar2
)

IS
--

-- Cursor for Verify_Budget_Rules
    CURSOR	l_budget_rules_csr(p_project_id NUMBER, p_award_id NUMBER, p_budget_type_code VARCHAR2)
    IS
    SELECT 	v.budget_version_id
		FROM   gms_budget_versions v
    WHERE  	v.project_id = p_project_id
    AND 	v.award_id = p_award_id
    AND		v.budget_type_code = p_budget_type_code
    AND		v.budget_status_code in ('S','W');


-- Local Variables
l_workflow_started_by_id		NUMBER;
l_project_id			NUMBER;
l_award_id 			NUMBER;
l_budget_type_code		pa_budget_types.budget_type_code%TYPE;


l_warnings_only_flag		VARCHAR2(1);
l_warnings_only			VARCHAR2(1)	:= 'Y';
l_err_msg_count			NUMBER		:= 0;
l_budget_version_id		NUMBER;
l_mark_as_original		gms_budget_versions.current_original_flag%TYPE;
l_resource_list_id		NUMBER;
l_project_type_class_code	pa_project_types.project_type_class_code%TYPE;

l_msg_count			NUMBER;
l_msg_data			VARCHAR(2000);
l_return_status			VARCHAR2(1);
l_data				VARCHAR2(2000);
l_msg_index_out			NUMBER;
l_api_version_number		NUMBER		:= G_api_version_number;

l_err_code			NUMBER		:= 0;
l_err_stage			VARCHAR2(120);
l_err_stack			VARCHAR2(630);



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

	l_award_id := wf_engine.GetItemAttrNumber( 	itemtype  	=> itemtype,
			    				itemkey   	=> itemkey,
			    				aname  		=> 'AWARD_ID' );

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

	l_project_type_class_code	 := wf_engine.GetItemAttrText(itemtype  	=> itemtype,
				    			itemkey   	=> itemkey,
				    			aname  		=>'PROJECT_TYPE_CLASS_CODE');

-- SET GLOBALS -----------------------------------------------------------------

-- Based on the Responsibility, Intialize the Application
GMS_WORKFLOW_UTILS.Set_Global_Attr
 		(p_item_type => itemtype
                , p_item_key  => itemkey
   		, p_err_code  => l_err_code);



-- ------------------------------------------------------------------------------------
-- NON-WF Verify Budget Rules
-- ------------------------------------------------------------------------------------

-- Retrieve Required IN-parameters for Verify_Budget_Rules Calls

     OPEN l_budget_rules_csr(l_project_id, l_award_id, l_budget_type_code);


     FETCH l_budget_rules_csr   INTO  l_budget_version_id;

     IF ( l_budget_rules_csr%NOTFOUND)
    THEN

-- jjj - use gms_messages utility instead of PA's

	PA_UTILS.Add_Message
	( p_app_short_name	=> 'GMS'
	  , p_msg_name		=> 'GMS_NO_BUDGET_RULES_ATTR'
	);

   	GMS_WORKFLOW_UTILS.Set_Notification_Messages
	(p_item_type  	=> itemtype
	, p_item_key   	=> itemkey
	);

	resultout := wf_engine.eng_completed||':'||'F';
	CLOSE l_budget_rules_csr;
    	RETURN;
    END IF;

    CLOSE l_budget_rules_csr;


-- SUBMISSION RULES -------------------------------------------------------------
--dbms_output.put_line('Verify Budget Rules - SUBMIT');


     GMS_BUDGET_UTILS.VERIFY_BUDGET_RULES
    (p_draft_version_id			=>	l_budget_version_id
    , p_mark_as_original  		=>	l_mark_as_original
    , p_event				=>	'SUBMIT'
    , p_project_id			=>	l_project_id
    , p_award_id			=>	l_award_id
    , p_budget_type_code		=>	l_budget_type_code
    , p_resource_list_id		=>	l_resource_list_id
    , p_project_type_class_code		=>	l_project_type_class_code
    , p_created_by 			=>	l_workflow_started_by_id
    , p_calling_module			=>	'GMSFBUVB'
    , p_warnings_only_flag		=> 	l_warnings_only_flag
    , p_err_msg_count			=> 	l_err_msg_count
    , p_err_code			=> 	l_err_code
    , p_err_stage			=> 	l_err_stage
    , p_err_stack			=> 	l_err_stack
    );

IF (l_err_msg_count > 0 )
THEN
	GMS_WORKFLOW_UTILS.Set_Notification_Messages
	(p_item_type  	=> itemtype
	, p_item_key   	=> itemkey
	);
	IF (l_warnings_only_flag = 'N') THEN
		l_warnings_only := 'N';
	END IF;
END IF;



-- BASELINE RULES -------------------------------------------------------------

GMS_BUDGET_UTILS.VERIFY_BUDGET_RULES
    (p_draft_version_id		=>	l_budget_version_id
    , p_mark_as_original	=>	l_mark_as_original
    , p_event	       	        => 	'BASELINE'
    , p_project_id		=>	l_project_id
    , p_award_id		=>	l_award_id
    , p_budget_type_code	=>	l_budget_type_code
    , p_resource_list_id	=>	l_resource_list_id
    , p_project_type_class_code	=>	l_project_type_class_code
    , p_created_by 		=>	l_workflow_started_by_id
    , p_calling_module		=>	'GMSFBUVB'
    , p_warnings_only_flag	=> 	l_warnings_only_flag
    , p_err_msg_count		=> 	l_err_msg_count
    , p_err_code		=> 	l_err_code
    , p_err_stage		=> 	l_err_stage
    , p_err_stack		=> 	l_err_stack
    );

IF (l_err_msg_count > 0 )
THEN
	GMS_WORKFLOW_UTILS.Set_Notification_Messages
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

	GMS_CLIENT_EXTN_BUDGET_WF.Verify_Budget_Rules
 	(p_item_type			=> itemtype
	 , p_item_key  			=> itemkey
	 , p_project_id			=> l_project_id
         , p_award_id			=> l_award_id
	 , p_budget_type_code		=> l_budget_type_code
	 , p_workflow_started_by_id	=> l_workflow_started_by_id
	 , p_event			=> 'SUBMIT'
	 , p_warnings_only_flag		=> l_warnings_only_flag
	 , p_err_msg_count		=> l_err_msg_count
	 );


	IF (l_err_msg_count > 0 )
	THEN
		GMS_WORKFLOW_UTILS.Set_Notification_Messages
		(p_item_type  	=> itemtype
   		, p_item_key   	=> itemkey
		);
		IF (l_warnings_only_flag = 'N') THEN
			l_warnings_only := 'N';
		END IF;
	END IF;

	GMS_CLIENT_EXTN_BUDGET_WF.Verify_Budget_Rules
 	(p_item_type			=> itemtype
	 , p_item_key  			=> itemkey
	 , p_project_id			=> l_project_id
         , p_award_id			=> l_award_id
	 , p_budget_type_code		=> l_budget_type_code
	 , p_workflow_started_by_id	=> l_workflow_started_by_id
	 , p_event			=> 'BASELINE'
	 , p_warnings_only_flag		=> l_warnings_only_flag
	 , p_err_msg_count		=> l_err_msg_count
	 );


	IF (l_err_msg_count > 0 )
	THEN
		GMS_WORKFLOW_UTILS.Set_Notification_Messages
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
WF_CORE.CONTEXT('GMS_WF_PKG','VERIFY_BUDGET_RULES', itemtype, itemkey, to_char(actid), funcmode);
	RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
WF_CORE.CONTEXT('GMS_WF_PKG','VERIFY_BUDGET_RULES', itemtype, itemkey, to_char(actid), funcmode);
	RAISE;

    WHEN OTHERS THEN
WF_CORE.CONTEXT('GMS_WF_PKG','VERIFY_BUDGET_RULES', itemtype, itemkey, to_char(actid), funcmode);
	RAISE;


END Verify_Budget_Rules;

-- ==================================================
--Name:               	Baseline_Budget
--Type:               	Procedure
--Description: 		This procedures performs BASELINE verification,
--			baseline functionality via the core baseline
--			procedure, and directly updates the draft budget.
--
--
--
--
--Called subprograms: 	GMS_BUDGET_UTILS.Verify_Budget_Rules
--			, GMS_CLIENT_EXTN_BUDGET_WF.Verify_Budget_Rules
--			, GMS_BUDGET_CORE.Baseline
--			, GMS_WORKFLOW_UTILS.Insert_WF_Processes
--
--
--
--History:
--
-- IN
--   itemtype  - 	A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - 	A string generated from the application object's primary key.
--   actid     - 	The notIFication process activity(instance id).
--   funcmode  - 	Run/Cancel
-- OUT NOCOPY
--   Resultout    - 	T/F
--
--
PROCEDURE Baseline_Budget
(itemtype			IN   	VARCHAR2
, itemkey  			IN   	VARCHAR2
, actid			IN	NUMBER
, funcmode			IN   	VARCHAR2
, resultout			OUT NOCOPY	VARCHAR2
)
IS

-- Cursor for Insert_WF_Processes Call
      CURSOR l_baseline_csr
    		( p_project_id NUMBER
		, p_award_id NUMBER
    		, p_budget_type_code VARCHAR2 )

      IS
      SELECT  MAX(budget_version_id)
      FROM   gms_budget_versions
      WHERE project_id 		= p_project_id
      AND   award_id            = p_award_id
      AND   budget_type_code 	= p_budget_type_code
      AND   budget_status_code 	= 'B';

-- Bug 5162777 : The cursors l_time_phased_type_csr and l_grp_resource_type_csr are removed as they are never used in this procedure.


l_workflow_started_by_id		NUMBER;
l_baseliner_id			NUMBER;
l_project_id			NUMBER;
l_award_id			NUMBER;
l_budget_type_code		pa_budget_types.budget_type_code%TYPE;
l_time_phased_type_code		VARCHAR2(30);

l_row_found			NUMBER;
l_budget_version_id		NUMBER;
l_baselined_version_id		NUMBER;
l_draft_version_id		NUMBER;

l_app_short_name		VARCHAR2(30);
l_count				NUMBER; -- used by the Budgetary Control Setup process.
l_entry_level_code		VARCHAR2(30); -- used by the Budgetary Control Setup process.
l_group_resource_type_id	NUMBER; -- used by the Budgetary Control Setup process.

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
l_mark_as_original		gms_budget_versions.current_original_flag%TYPE;
l_resource_list_id		NUMBER;
l_project_type_class_code	pa_project_types.project_type_class_code%TYPE;

l_err_code			NUMBER			:= 0;
l_err_stage			VARCHAR2(120)		:= NULL;
l_err_stack			VARCHAR2(630);



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

	l_award_id := wf_engine.GetItemAttrNumber( 	itemtype  	=> itemtype,
			    				itemkey   	=> itemkey,
			    				aname  		=> 'AWARD_ID' );

	l_budget_type_code := wf_engine.GetItemAttrText(itemtype  	=> itemtype,
				    			itemkey   	=> itemkey,
				    			aname  		=> 'BUDGET_TYPE_CODE' );

	l_workflow_started_by_id := wf_engine.GetItemAttrNumber(itemtype  	=> itemtype,
				    				itemkey   	=> itemkey,
				    				aname  		=> 'WORKFLOW_STARTED_BY_ID' );


	l_baseliner_id := wf_engine.GetItemAttrNumber(	itemtype  	=> itemtype,
				    			itemkey   	=> itemkey,
				    			aname  		=> 'BUDGET_BASELINER_ID' );

	l_mark_as_original := wf_engine.GetItemAttrText(itemtype  	=> itemtype,
				    			itemkey   	=> itemkey,
				    			aname  		=> 'MARK_AS_ORIGINAL' );

	l_resource_list_id := wf_engine.GetItemAttrText(itemtype  	=> itemtype,
				    			itemkey   	=> itemkey,
				    			aname  		=>'RESOURCE_LIST_ID');

	l_project_type_class_code	 := wf_engine.GetItemAttrText(itemtype  => itemtype,
				    			itemkey   	=> itemkey,
				    			aname  		=>'PROJECT_TYPE_CLASS_CODE');

-- SET GLOBALS -----------------------------------------------------------------

-- Based on the Responsibility, Intialize the Application
GMS_WORKFLOW_UTILS.Set_Global_Attr
 		(p_item_type => itemtype
                 , p_item_key  => itemkey
		 , p_err_code  => l_err_code);

--Setting OU Context
   GMS_BUDGET_UTILS.Set_Award_Policy_Context
       (p_award_id => l_award_id
        ,x_return_status => l_return_status
        ,x_msg_count     => l_msg_count
        ,x_msg_data      => l_msg_data
        ,x_err_code      => l_err_code
        );

   IF (l_err_code <> 0)
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

 -- Get The Budget Version ID Associated With This Project/Award/Budget_Type_Code Combination

    OPEN l_budget_versions_csr ( l_project_id, l_award_id, l_budget_type_code );
    FETCH l_budget_versions_csr INTO l_budget_version_id;


     IF ( l_budget_versions_csr%NOTFOUND)
    THEN

	PA_UTILS.Add_Message
	( p_app_short_name	=> 'GMS'
	  , p_msg_name		=> 'GMS_NO_BUDGET_RULES_ATTR'
	);

   	GMS_WORKFLOW_UTILS.Set_Notification_Messages
	(p_item_type  	=> itemtype
	, p_item_key   	=> itemkey
	);
	resultout := wf_engine.eng_completed||':'||'F';
	CLOSE l_budget_versions_csr;
    	RETURN ;
    END IF;

    CLOSE l_budget_versions_csr;

-- ------------------------------------------------------------------------------------
-- NON-WF Verify Budget Rules
-- ------------------------------------------------------------------------------------

GMS_BUDGET_UTILS.VERIFY_BUDGET_RULES
    (p_draft_version_id			=>	l_budget_version_id
    , p_mark_as_original  		=>	l_mark_as_original
    , p_event 		                => 	'BASELINE'
    , p_project_id			=>	l_project_id
    , p_award_id			=>	l_award_id
    , p_budget_type_code		=>	l_budget_type_code
    , p_resource_list_id		=>	l_resource_list_id
    , p_project_type_class_code		=>	l_project_type_class_code
    , p_created_by 			=>	l_workflow_started_by_id
    , p_calling_module			=>	'GMSFBUVB'
    , p_warnings_only_flag		=> 	l_warnings_only_flag
    , p_err_msg_count			=> 	l_err_msg_count
    , p_err_code			=> 	l_err_code
    , p_err_stage			=> 	l_err_stage
    , p_err_stack			=> 	l_err_stack
    );

IF (l_err_msg_count > 0 )
THEN
	GMS_WORKFLOW_UTILS.Set_Notification_Messages
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

	GMS_CLIENT_EXTN_BUDGET_WF.Verify_Budget_Rules
 	(p_item_type			=> itemtype
	 , p_item_key  			=> itemkey
	 , p_project_id			=> l_project_id
	 , p_award_id			=> l_award_id
	 , p_budget_type_code		=> l_budget_type_code
	 , p_workflow_started_by_id	=> l_workflow_started_by_id
	 , p_event			=> 'BASELINE'
	 , p_warnings_only_flag		=> l_warnings_only_flag
	 , p_err_msg_count		=> l_err_msg_count
	 );


	IF (l_err_msg_count > 0 )
	THEN
		GMS_WORKFLOW_UTILS.Set_Notification_Messages
		(p_item_type  	=> itemtype
   		, p_item_key   	=> itemkey
		);
		IF (l_warnings_only_flag = 'N') THEN
			l_warnings_only := 'N';
		END IF;
	END IF;

-- ---------------------------------------------------------------------------------------
--  BASELINE THIS BUDGET VERSION
--  Make sure verify budget rules NOT called again:
--      x_verify_budget_rules	=> 'N'
-- ---------------------------------------------------------------------------------------

	IF (l_warnings_only = 'Y')
	THEN

    GMS_BUDGET_CORE.Baseline ( x_draft_version_id 	=> l_budget_version_id
    			     ,x_mark_as_original	=> l_mark_as_original
			     ,x_verify_budget_rules	=> 'N'
    			     ,x_err_code		=> l_err_code
    			     ,x_err_stage		=> l_err_stage
    			     ,x_err_stack		=> l_err_stack
			);


-- All Errors Should Be Unexpected Errors. However,
-- Oracle Errors will be Captured by the Procedure
-- Exception. This Code can only Capture
-- Business Errors.

		IF (l_err_code <> 0)
		THEN
			WF_CORE.CONTEXT('GMS_WF_PKG','BASELINE_BUDGET', itemtype, itemkey, to_char(actid), funcmode);
			RAISE FND_API.G_EXC_ERROR;
		END IF;


--
-- Insert a Row into the GMS_WF_PROCESSES Table
-- to Record the Workflow Associated with the Baselined
-- Budget
--

    		OPEN l_baseline_csr ( l_project_id, l_award_id, l_budget_type_code );
		 FETCH l_baseline_csr INTO l_baselined_version_id;

-- Extensive Error Checking Not Required Because The Baselined Version Was Just
-- Created By The gms_Budget_Core.Baseline Call.


	GMS_WORKFLOW_UTILS.Insert_WF_Processes
	      (p_wf_type_code        	=> 'BUDGET'
	      ,p_item_type           	=> itemtype
	      ,p_item_key           	=> itemkey
	      ,p_entity_key1         	=> to_char(l_budget_version_id)
	      ,p_entity_key2		=> to_char(l_baselined_version_id)
	      ,p_description         	=> NULL
	      ,p_err_code            	=> l_err_code
	      ,p_err_stage           	=> l_err_stage
	      ,p_err_stack           	=> l_err_stack
	      );

		IF (l_err_code <> 0)
		     THEN
			WF_CORE.CONTEXT('GMS_WF_PKG','BASELINE_BUDGET', itemtype, itemkey, to_char(actid), funcmode);
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

END IF ; -- OK to Baseline



IF (l_warnings_only = 'Y')
THEN
	resultout := wf_engine.eng_completed||':'||'T';
ELSE
	resultout := wf_engine.eng_completed||':'||'F';
END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR
	THEN
WF_CORE.CONTEXT('GMS_BUDGET_WF','BASELINE_BUDGET', itemtype, itemkey, to_char(actid), funcmode);
	RAISE;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
WF_CORE.CONTEXT('GMS_BUDGET_WF','BASELINE_BUDGET', itemtype, itemkey, to_char(actid), funcmode);
	RAISE;

WHEN OTHERS THEN
	WF_CORE.CONTEXT('GMS_BUDGET_WF','BASELINE_BUDGET', itemtype, itemkey, to_char(actid), funcmode);
	RAISE;

END Baseline_Budget;

----------------------------------------------------------------------------------------
-- Name:               	Select_WF_Process
-- Type:               	Procedure
-- Description: 	This procedure is used to select the branch of the WF process
--			(Budget/Installment/Report) based on the Item_Attribute that
--			is sent from the calling program.
--
--History:
--
-- IN
--   itemtype  - 	A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - 	A string generated from the application object's primary key.
--   actid     - 	The notIFication process activity(instance id).
--   funcmode  - 	Run/Cancel
-- OUT NOCOPY
--   Resultout    - 	BUDGET or INSTALLMENT or REPORT
--
--
PROCEDURE select_wf_process (	itemtype        	in  varchar2,
				itemkey         	in  varchar2,
	                     	actid           	in number,
				funcmode        	in  varchar2,
				resultout          	out NOCOPY varchar2    )
is
	x_gms_wf_process	varchar2(25);
begin

  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  x_gms_wf_process := wf_engine.GetItemAttrText
  					( itemtype => itemtype,
					  itemkey  => itemkey,
					  aname    => 'GMS_WF_PROCESS');
  if   x_gms_wf_process = 'BUDGET' then
	resultout := 'COMPLETE:BUDGET';
  elsif   x_gms_wf_process = 'BUDGET_NTFY_ONLY' then
	resultout := 'COMPLETE:BUDGET_NTFY_ONLY';
  elsif   x_gms_wf_process = 'INSTALLMENT' then
	resultout := 'COMPLETE:INSTALLMENT';
  elsif   x_gms_wf_process = 'REPORT' then
	resultout := 'COMPLETE:REPORT';
--Start : Build of the installment closeout Notification Bug # 1969587
  elsif   x_gms_wf_process = 'INSTALLMENT_CLOSEOUT' then
 	resultout := 'COMPLETE:INSTALLMENT_CLOSEOUT';
--Start : Build of the installment closeout Notification Bug # 1969587
  end if;


EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('GMS_BUDGET_WF', 'SELECT_WF_PROCESS', itemtype, itemkey, to_char(actid), funcmode);
        raise;
end select_wf_process;
----------------------------------------------------------------------------------------

-- Name:               	Funds_check
-- Type:               	Procedure
-- Description: 	This procedure is used to invoke the GMS Funds check process from
--			the GMS Workflow process
--History:
--
-- IN
--   itemtype  - 	A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - 	A string generated from the application object's primary key.
--   actid     - 	The notIFication process activity(instance id).
--   funcmode  - 	Run/Cancel
-- OUT NOCOPY
--   Resultout    - 	COMPLETE:FUNDSCHECK_PASS or COMPLETE:FUNDSCHECK_FAIL
--
--

PROCEDURE Funds_check
(itemtype			IN   	VARCHAR2
, itemkey  			IN   	VARCHAR2
, actid				IN	NUMBER
, funcmode			IN   	VARCHAR2
, resultout			OUT NOCOPY	VARCHAR2
)

IS

l_workflow_started_by_id	NUMBER;
l_project_id			NUMBER;
l_award_id			NUMBER;
l_mode				VARCHAR2(3);
l_retcode			VARCHAR2(1);
l_budget_type_code		pa_budget_types.budget_type_code%TYPE;
l_baselined_version_id		NUMBER;
l_prev_baselined_version_id	NUMBER;
l_budget_version_id             NUMBER;
l_prev_entry_level_code         pa_budget_entry_methods.entry_level_code%type;
l_time_phased_type_code		VARCHAR2(30);
l_count				NUMBER;
l_packet_id			NUMBER;
l_app_short_name		VARCHAR2(30);
l_group_resource_type_id	NUMBER;
l_entry_level_code		VARCHAR2(30);
l_resource_list_id		NUMBER;


l_baseliner_employee_id		NUMBER;

l_baseliner_user_id		NUMBER;
l_baseliner_user_name		VARCHAR2(100);
l_baseliner_full_name		VARCHAR2(240);

l_err_code  			VARCHAR2(630);
l_err_stage			VARCHAR2(630);

l_msg_count			NUMBER;
l_msg_data			VARCHAR(2000);
l_return_status			VARCHAR2(1);
l_data				VARCHAR2(2000);
l_msg_index_out			NUMBER;
l_api_version_number		NUMBER		:= G_api_version_number;

l_user_profile_value1           VARCHAR2(30);
l_set_profile_success1          BOOLEAN := FALSE;
l_user_profile_value2           VARCHAR2(30);
l_set_profile_success2          BOOLEAN := FALSE;



-- Cursor for Summarizing Project Budgets -- 24-May-2000

	CURSOR l_time_phased_type_csr ( p_budget_version_id NUMBER)
	IS
	SELECT 	pbem.time_phased_type_code,
		pbem.entry_level_code
	FROM	gms_budget_versions gbv,
		pa_budget_entry_methods pbem
	WHERE	gbv.budget_version_id = p_budget_version_id
	AND	gbv.budget_entry_method_code = pbem.budget_entry_method_code;

-- Cursor for Budgetary Control Default Setup -- 25-May-2000

	CURSOR l_grp_resource_type_csr ( p_budget_version_id NUMBER)
	IS
	SELECT 	prl.group_resource_type_id,
		gbv.resource_list_id
	FROM	gms_budget_versions gbv,
		pa_resource_lists prl
	WHERE	gbv.budget_version_id = p_budget_version_id
	AND	gbv.resource_list_id = prl.resource_list_id;


BEGIN
  	-- Return if WF Not Running

  	IF (funcmode <> wf_engine.eng_run) THEN
    		resultout := wf_engine.eng_null;
    		RETURN;
  	END IF;

-- GET BUDGET ITEM ATTRIBUTES  for Subsequent Processing -----------------------

	l_project_id := wf_engine.GetItemAttrNumber( 	itemtype  	=> itemtype,
			    				itemkey   	=> itemkey,
			    				aname  		=> 'PROJECT_ID' );

	l_award_id   := wf_engine.GetItemAttrNumber( itemtype  	=> itemtype,
			    				itemkey   	=> itemkey,
			    				aname  		=> 'AWARD_ID' );

	l_budget_type_code   := wf_engine.GetItemAttrText( itemtype  	=> itemtype,
			    				itemkey   	=> itemkey,
			    				aname  		=> 'BUDGET_TYPE_CODE' );

	l_mode   := wf_engine.GetItemAttrText( itemtype  	=> itemtype,
			    				itemkey   	=> itemkey,
			    				aname  		=> 'FC_MODE' );


-- SET GLOBALS ------------------------------------------------------------------

-- Based on the Responsibility, Intialize the Application
GMS_WORKFLOW_UTILS.Set_Global_Attr
 		(p_item_type => itemtype
                , p_item_key  => itemkey
   		, p_err_code  => l_err_code);

--Setting the OU Context
   GMS_BUDGET_UTILS.Set_Award_Policy_Context (p_award_id => l_award_id
        ,x_return_status => l_return_status
        ,x_msg_count     => l_msg_count
        ,x_msg_data      => l_msg_data
        ,x_err_code      => l_err_code
        );

   IF (l_err_code <> 0)
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

if l_mode = 'B' then

----------- DERIVING THE BUDGET_VERSION_ID OF THE PREVIOUSLY BASELINED BUDGET -----------------

	-- Bug 2386041
	begin
	-- First get the budget_version_id of the previously baselined budget. In case there is an error we need to set the current_flag
	-- for this line to Y


	      select	bv.budget_version_id,
	                bem.entry_level_code
	        into    l_prev_baselined_version_id,
		        l_prev_entry_level_code
	        from    gms_budget_versions bv,
		        pa_budget_entry_methods bem
		where 	bv.award_id = l_award_id
		and 	bv.project_id = l_project_id
		and	bv.budget_type_code = l_budget_type_code
		and 	bv.budget_status_code = 'B'
		and 	bv.current_flag = 'R'
		and     bv.budget_entry_method_code = bem.budget_entry_method_code;

	exception
	when NO_DATA_FOUND then
	               -- this means that there did not exist any baselined budget earlier
	                l_prev_baselined_version_id := null;
			l_prev_entry_level_code := null;

	when OTHERS then
			WF_CORE.CONTEXT('GMS_WF_PKG','FUNDS_CHECK', itemtype, itemkey, to_char(actid), funcmode);
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	end;
	-- Bug 2386041

---------------------------------------------------------------------------------------------------------

/* Bug 5162777: The budgetary control records are created before invoking fundscheck process. */
----------------------- START  OF BC RECORD CREATION -------------------------

			OPEN l_budget_versions_csr ( l_project_id, l_award_id, l_budget_type_code );
		        FETCH l_budget_versions_csr INTO l_budget_version_id;
			Close l_budget_versions_csr ;

			open 	l_grp_resource_type_csr( p_budget_version_id => l_budget_version_id);
			fetch 	l_grp_resource_type_csr into l_group_resource_type_id, l_resource_list_id;
			close 	l_grp_resource_type_csr;

			open 	l_time_phased_type_csr( l_budget_version_id );
			fetch	l_time_phased_type_csr into l_time_phased_type_code, l_entry_level_code;
			close	l_time_phased_type_csr;


			gms_budg_cont_setup.bud_ctrl_create(p_project_id => l_project_id
							   ,p_award_id => l_award_id
							   ,p_prev_entry_level_code => l_prev_entry_level_code
							   ,p_entry_level_code => l_entry_level_code
							   ,p_resource_list_id => l_resource_list_id
							   ,p_group_resource_type_id => l_group_resource_type_id
							   ,x_err_code => l_err_code
							   ,x_err_stage => l_err_stage);


			if l_err_code <> 0
			then
				WF_CORE.CONTEXT('GMS_WF_PKG','FUNDS_CHECK', itemtype, itemkey, to_char(actid), funcmode);
				RAISE FND_API.G_EXC_ERROR;
				-- Bug 2386041
			end if;


--------------------------------------------------------------------------------------------------

end if;

-- Calling the Fundcheck process....

GMS_BUDGET_BALANCE.update_gms_balance(	x_project_id => l_project_id,
					x_award_id => l_award_id,
					x_mode => l_mode,
					errbuf => l_err_code,
					retcode => l_retcode);

IF l_retcode = 'S'
THEN
	resultout := 'COMPLETE:FUNDSCHECK_PASS';


	-- 29-May-2000------------------------------------------------------------------------------------
	-- if Funds check (during baselining, only) was successful then we have to:
	-- 	1. set the current_flag = 'N' for the previously baselined budget whose current_flag was set to 'R' earlier,
	-- 	2. set the current_flag = 'Y' for the newly created budget,
	-- 	3. Summarize the Project Budget,
	-- 	4. Run the default setup for Budgetary Control (if budget is baselined for the first time) and
	-- 	5. set the budget_status_code = 'W' and wf_status_code = NULL for the budget that was 'Submitted'.
	-- 	6. call gms_sweeper -- added for Bug: 1666853

	if l_mode = 'B'
	then



	--------------------------------------------------------------------------------------------------

	-- 	1. set the current_flag = 'N' for the previously baselined budget.

		update 	gms_budget_versions
		set 	current_flag = 'N'
		where 	award_id = l_award_id
		and 	project_id = l_project_id
		and	budget_type_code = l_budget_type_code
		and 	budget_status_code = 'B'
		and 	current_flag = 'R';

	--------------------------------------------------------------------------------------------------

	-- 	2. set the current_flag = 'Y' for the newly created budget.

		-- Corrected the query for Bug:2542827

		update 	gms_budget_versions
		set	current_flag = 'Y'
		where  	budget_version_id = (	select 	max(budget_version_id)
						from 	gms_budget_versions
						where 	award_id = l_award_id
						and 	project_id = l_project_id
						and 	budget_type_code = l_budget_type_code);


	--------------------------------------------------------------------------------------------------
	-- 	After updating the newly created budget we have to get the budget_version_id of this budget
	-- 	which is going to be used by the Project Budget Summarization and Default Budgetary Control
	--	Setup programs

		begin
			select 	budget_version_id
			into 	l_baselined_version_id
			from 	gms_budget_versions
			where	award_id = l_award_id
			and	project_id = l_project_id
			and 	budget_type_code = l_budget_type_code
			and	budget_status_code = 'B'
			and	current_flag = 'Y';

		exception
		when OTHERS
		then
			WF_CORE.CONTEXT('GMS_WF_PKG','FUNDS_CHECK', itemtype, itemkey, to_char(actid), funcmode,'1');
			RAISE FND_API.G_EXC_ERROR;
		end;


	-- 	3. Summarize the Project Budget.


	          -- Bug 2386041
                l_user_profile_value1 := fnd_profile.value_specific(
                						    NAME		=>	'PA_SUPER_PROJECT',
                						    USER_ID		=>	fnd_global.user_id,
                						    RESPONSIBILITY_ID	=>	fnd_global.resp_id,
                						    APPLICATION_ID	=>	fnd_global.resp_appl_id);

                if ((l_user_profile_value1 = 'N') OR  (l_user_profile_value1 is null)) then

                   BEGIN

                      SELECT profile_option_value
                      INTO   l_user_profile_value1
                      FROM   fnd_profile_options       p,
                             fnd_profile_option_values v
                      WHERE  p.profile_option_name = 'PA_SUPER_PROJECT'
                      AND    v.profile_option_id = p.profile_option_id
                      AND    v.level_id = 10004
                      AND    v.level_value = fnd_global.user_id;

                   EXCEPTION

                      WHEN no_data_found THEN
                         l_user_profile_value1 := null;

                      WHEN others THEN
                         l_user_profile_value1 := null;

                   END;

                   l_set_profile_success1 :=  fnd_profile.save(
                   						X_NAME		=>	'PA_SUPER_PROJECT',
                   						X_VALUE		=>	'Y',
                   						X_LEVEL_NAME	=>	'USER',
                   						X_LEVEL_VALUE	=>	fnd_global.user_id);
                end if;

                l_user_profile_value2 := fnd_profile.value_specific(
                						    NAME		=>	'PA_SUPER_PROJECT_VIEW',
                						    USER_ID		=>	fnd_global.user_id,
                						    RESPONSIBILITY_ID	=>	fnd_global.resp_id,
                						    APPLICATION_ID	=>	fnd_global.resp_appl_id);


                if ((l_user_profile_value2 = 'N') OR  (l_user_profile_value2 is null)) then

                   BEGIN

                      SELECT profile_option_value
                      INTO   l_user_profile_value2
                      FROM   fnd_profile_options       p,
                             fnd_profile_option_values v
                      WHERE  p.profile_option_name = 'PA_SUPER_PROJECT_VIEW'
                      AND    v.profile_option_id = p.profile_option_id
                      AND    v.level_id = 10004
                      AND    v.level_value = fnd_global.user_id;

                   EXCEPTION

                      WHEN no_data_found THEN
                         l_user_profile_value2 := null;

                      WHEN others THEN
                         l_user_profile_value2 := null;

                   END;

                   l_set_profile_success2 :=  fnd_profile.save(
                   						X_NAME		=>	'PA_SUPER_PROJECT_VIEW',
                   						X_VALUE		=>	'Y',
                   						X_LEVEL_NAME	=>	'USER',
                   						X_LEVEL_VALUE	=>	fnd_global.user_id);


                end if;
                -- Bug 2386041


	     		gms_summarize_budgets.summarize_baselined_versions( x_project_id => l_project_id
								, x_time_phased_type_code => l_time_phased_type_code
								, x_app_short_name => l_app_short_name -- out NOCOPY variable
								, RETCODE => l_return_status
								, ERRBUF =>  l_err_stage );

	        -- Bug 2386041

	         if (l_set_profile_success1 = TRUE) then
                     l_set_profile_success1 :=  fnd_profile.save('PA_SUPER_PROJECT', l_user_profile_value1, 'USER', fnd_global.user_id);
                 end if;

                 if (l_set_profile_success2 = TRUE) then
                     l_set_profile_success2 :=  fnd_profile.save('PA_SUPER_PROJECT_VIEW', l_user_profile_value2, 'USER', fnd_global.user_id);
                 end if;
	        -- Bug 2386041

		if l_return_status <> 'S'
		then
			WF_CORE.CONTEXT('GMS_WF_PKG','FUNDS_CHECK', itemtype, itemkey, to_char(actid), funcmode);
			-- Bug 2386041
			update 	gms_budget_versions
			set 	current_flag = 'Y'
			where 	budget_version_id = l_prev_baselined_version_id;

			update 	gms_budget_versions
			set 	current_flag = 'N'
			where 	budget_version_id = l_baselined_version_id;
			RAISE FND_API.G_EXC_ERROR;
			-- Bug 2386041
		end if;


	-- 	5. set the budget_status_code = 'W' and wf_status_code = NULL for the budget that was 'Submitted'.

		update 	gms_budget_versions
		set	budget_status_code = 'W',
			wf_status_code = NULL
		where 	award_id = l_award_id
		and 	project_id = l_project_id
		and 	budget_type_code = l_budget_type_code
		and 	budget_status_code = 'S';

	--------------------------------------------------------------------------------------------------
	-- 	6. call gms_sweeper -- added for Bug: 1666853 ...

        -- get the packet id for the budget and pass it on to the sweeper process.
        -- locking issue addressed as the scope of locking is limited to the packet.
	-- if there are no transactions then no point calling sweeper process. We'll skip it.
        -- Bug : 2821482.

	-- changes for 2821482 begin...

		begin
		  select distinct packet_id
		    into l_packet_id
		    from gms_bc_packets
                   where budget_version_id = l_baselined_version_id;
		exception
		  -- no data found can occur when there are no transactions
		  -- for the award.
		  when no_data_found then
		    l_packet_id := null;
		    null;
		end;
		-- bug 2821482 changes end.

		if l_packet_id is not null then --> bug 2821482.

		   gms_sweeper.upd_act_enc_bal(ERRBUF => l_err_stage,
				               retcode => l_err_code,
				               x_mode => 'B',
				               x_packet_id => l_packet_id, --> bug 2821482
				               x_project_id => l_project_id,
				               x_award_id => l_award_id);

		   if l_err_code <> 0 then -- Checking for 0 (zero) instead of 'S' for Bug:2464800

			   WF_CORE.CONTEXT('GMS_WF_PKG','FUNDS_CHECK', itemtype, itemkey, to_char(actid), funcmode);
			-- Bug 2386041
			   update gms_budget_versions
			      set current_flag = 'Y'
			    where budget_version_id = l_prev_baselined_version_id;

			   update gms_budget_versions
			      set current_flag = 'N'
			    where budget_version_id = l_baselined_version_id;

			RAISE FND_API.G_EXC_ERROR;
			-- Bug 2386041
		end if;

		end if; --> l_packet_id is not null. Bug 2821482
	-- ... for Bug: 1666853
	--------------------------------------------------------------------------------------------------

	elsif l_mode = 'S'
	then
		--	Budget Status is set to 'Submitted' and FC_MODE is set to 'B' since the Funds check process
		-- 	for baselining looks for budget_status_code = 'S' and FC_MODE = 'B'

		update 	gms_budget_versions
		set 	budget_status_code = 'S'
		where 	award_id = l_award_id
		and 	project_id = l_project_id
		and	budget_type_code = l_budget_type_code
		and 	budget_status_code = 'W';


		wf_engine.SetItemAttrText(itemtype => itemtype,
					itemkey => itemkey,
					aname => 'FC_MODE',
					avalue => 'B');



	end if; -- (l_mode = 'B')

ELSE
--	if Funds check failed then the previously baselined budget (whose current_flag was set to 'R' earlier) should be restored

	if l_mode = 'B'
	then
		update 	gms_budget_versions
		set 	current_flag = 'Y'
		where 	award_id = l_award_id
		and 	project_id = l_project_id
		and	budget_type_code = l_budget_type_code
		and 	budget_status_code = 'B'
		and 	current_flag = 'R';
	end if;

	resultout := 'COMPLETE:FUNDSCHECK_FAIL';
END IF;


EXCEPTION

WHEN FND_API.G_EXC_ERROR
	THEN
	WF_CORE.CONTEXT('GMS_WF_PKG','FUNDS_CHECK', itemtype, itemkey, to_char(actid), funcmode);
	resultout := 'COMPLETE:FUNDSCHECK_FAIL';

WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
	WF_CORE.CONTEXT('GMS_WF_PKG','FUNDS_CHECK', itemtype, itemkey, to_char(actid), funcmode);
	resultout := 'COMPLETE:FUNDSCHECK_FAIL';

WHEN OTHERS
	THEN
	WF_CORE.CONTEXT('GMS_WF_PKG','FUNDS_CHECK', itemtype, itemkey, to_char(actid), funcmode);
	resultout := 'COMPLETE:FUNDSCHECK_FAIL';

END Funds_check;

----------------------------------------------------------------------------------------

PROCEDURE Chk_Baselined_Budget_Exists
(itemtype		IN   	VARCHAR2
, itemkey  		IN   	VARCHAR2
, actid			IN	NUMBER
, funcmode		IN   	VARCHAR2
, resultout		OUT NOCOPY	VARCHAR2
)
IS

l_project_id			NUMBER;
l_award_id			NUMBER;
l_budget_type_code		pa_budget_types.budget_type_code%TYPE;
l_budget_version_id		NUMBER;

l_err_code			NUMBER;
l_err_stage			VARCHAR2(120);
l_err_stack			VARCHAR2(630);
l_msg_count			NUMBER;
l_msg_data			VARCHAR(2000);
l_return_status			VARCHAR2(1);

begin

  	IF (funcmode <> wf_engine.eng_run)
  	THEN
    		resultout := wf_engine.eng_null;
    		RETURN;
  	END IF;
	--

-- GET BUDGET ITEM ATTRIBUTES  for Subsequent Processing -----------------------

	l_project_id := wf_engine.GetItemAttrNumber( 	itemtype  	=> itemtype,
			    				itemkey   	=> itemkey,
			    				aname  		=> 'PROJECT_ID' );

	l_award_id   := wf_engine.GetItemAttrNumber( itemtype  	=> itemtype,
			    				itemkey   	=> itemkey,
			    				aname  		=> 'AWARD_ID' );

	l_budget_type_code   := wf_engine.GetItemAttrText( itemtype  	=> itemtype,
			    				itemkey   	=> itemkey,
			    				aname  		=> 'BUDGET_TYPE_CODE' );


-- SET GLOBALS ------------------------------------------------------------------

-- Based on the Responsibility, Intialize the Application

	GMS_WORKFLOW_UTILS.Set_Global_Attr
 		(p_item_type => itemtype
                , p_item_key  => itemkey
   		, p_err_code  => l_err_code);

--Setting OU Context
    GMS_BUDGET_UTILS.Set_Award_Policy_Context (p_award_id => l_award_id
        ,x_return_status => l_return_status
        ,x_msg_count     => l_msg_count
        ,x_msg_data      => l_msg_data
        ,x_err_code      => l_err_code
        );

   IF (l_err_code <> 0)
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


	GMS_BUDGET_UTILS.get_baselined_version_id (
					x_project_id => l_project_id,
					x_award_id => l_award_id,
					x_budget_type_code => l_budget_type_code,
					x_budget_version_id => l_budget_version_id,
					x_err_code => l_err_code,
					x_err_stage => l_err_stage,
					x_err_stack => l_err_stack);

	IF l_err_code <> 0
	THEN
		-- baselined version doesn't exist

		-- Since a baselined budget doesn't exist Funds checking for Submit process
		-- should be bypassed and so the FC_MODE is being set to 'B'.

		wf_engine.SetItemAttrText(itemtype => itemtype,
					itemkey => itemkey,
					aname => 'FC_MODE',
					avalue => 'B');

		update 	gms_budget_versions
		set 	budget_status_code = 'S'
		where 	award_id = l_award_id
		and 	project_id = l_project_id
		and	budget_type_code = l_budget_type_code
		and 	budget_status_code = 'W';

-- the above update is being explicitly commited since the budget_status_code (S) is required
-- to enable/disable the control in the Award Budget Form

		commit;
		resultout := 'COMPLETE:NO';
		return;
	ELSE
		-- baselined version exists
		resultout := 'COMPLETE:YES';
		return;
	END IF;

end;

----------------------------------------------------------------------------------

PROCEDURE start_report_wf_process( x_award_id IN NUMBER
				  ,x_award_number IN VARCHAR2
				  ,x_award_short_name IN VARCHAR2
				  ,x_installment_number IN VARCHAR2
				  ,x_report_name IN VARCHAR2
				  ,x_report_due_date IN VARCHAR2
				  ,x_funding_source_name IN VARCHAR2
				  ,x_role IN VARCHAR2
				  ,x_err_code OUT NOCOPY NUMBER
				  ,x_err_stage OUT NOCOPY VARCHAR2)
IS
ItemType varchar2(30) := 'GMSWF';
ItemKey number;
x_workflow_started_by_id number := FND_GLOBAL.User_Id;
x_user_name varchar2(100) := FND_GLOBAL.User_Name;
x_full_name varchar2(65);
x_wf_started_date date := SYSDATE;

cursor l_starter_full_name_csr
is
	select p.first_name||' '||p.last_name /*Bug 5122724 */
        from fnd_user f, per_people_f p
        where p.effective_start_date = (select min(pp.effective_start_date)
                                        from per_all_people_f pp
                                        where pp.person_id = p.person_id
                                        and pp.effective_end_date >=trunc(sysdate))
        and ((p.employee_number is not null) OR (p.npw_number is not null))
        and user_id = FND_GLOBAL.User_Id
        and f.employee_id = p.person_id;



BEGIN
 x_err_code := 0;

	select gms_workflow_itemkey_s.nextval
	into ItemKey
	from dual;
	open l_starter_full_name_csr;
	fetch l_starter_full_name_csr into x_full_name;
	IF (l_starter_full_name_csr%NOTFOUND)
	THEN
		x_err_code := 10;
		close l_starter_full_name_csr;
		return;
	END IF;

	close l_starter_full_name_csr;

	wf_engine.CreateProcess( ItemType => ItemType,
				 ItemKey  => ItemKey,
				 process  => 'GMS_WF_PROCESS' );

-- Attribute GMS_WF_PROCESS is used to select the appropriate branch
-- in the workflow process.


	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'GMS_WF_PROCESS',
					avalue		=>  'REPORT');

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'AWARD_NUMBER',
					avalue		=>  x_award_number);

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'AWARD_SHORT_NAME',
					avalue		=>  x_award_short_name);
       -- Added below call to pass Installment Number attribute Bug 2286855
         wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'INSTALL_NUM',
                                        avalue          =>  x_installment_number);

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'REPORT_NAME',
					avalue		=>  x_report_name);

	wf_engine.SetItemAttrDate ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'REPORT_DUE_DATE',
					avalue		=>  x_report_due_date);

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'FUNDING_SOURCE_NAME',
					avalue		=>  x_funding_source_name);

	wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'WORKFLOW_STARTED_BY_ID',
					avalue		=>  x_workflow_started_by_id);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'WORKFLOW_STARTED_BY_NAME',
					avalue		=>  x_user_name);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'NOTIF_RECIPIENT_ROLE',
					avalue		=>  x_role);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'WORKFLOW_STARTED_BY_FULL_NAME',
					avalue		=>  x_full_name);

	wf_engine.SetItemAttrDate (	itemtype	=> itemtype,
	      			   	itemkey  	=> itemkey,
 	      			   	aname 		=> 'WF_STARTED_DATE',
				   	avalue		=> x_wf_started_date
				);


	wf_engine.StartProcess( 	itemtype	=> itemtype,
	      				itemkey		=> itemkey );


--	p_item_type	:= itemtype;
--	p_item_key	:= itemkey;

-- Added Exception for Bug:2662848

Exception
when OTHERS then
	gms_error_pkg.gms_message(x_err_name => 'GMS_UNEXPECTED_ERROR',
				x_token_name1 => 'SQLCODE',
				x_token_val1 => sqlcode,
				x_token_name2 => 'SQLERRM',
				x_token_val2 => sqlerrm,
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
end start_report_wf_process;

----------------------------------------------------------------------------------------
PROCEDURE Schedule_Notification( ERRBUF OUT NOCOPY Varchar2
			  ,RETCODE OUT NOCOPY Varchar2
			  ,p_offset_days IN NUMBER)
IS
        l_offset_days NUMBER;    -- Bug 1868293

/*	cursor c1 is
	select ga.award_id,
               ga.award_number,
               ga.award_short_name,
               gi.installment_num,
               grv.report_name,
               grv.due_date,
               ga.funding_source_short_name,
               grv.report_id  --bug 2282107
	from   gms_awards_v ga, gms_installments gi, gms_reports_v grv
	where grv.installment_id = gi.installment_id
	and gi.award_id = ga.award_id
	and grv.due_date = trunc(sysdate) + l_offset_days  -- Bug 1868293
	and ga.status <> 'CLOSED' --Changed from 'ACTIVE'  to fix bug 2200837
	and gi.active_flag = 'Y'
        and ga.award_template_flag ='DEFERRED'; */-- commentedout to fix bug 2660430

       --following cursor is re-structured of above query to fix bug 2660430
       cursor c1 is
       select  ga.award_id,
               ga.award_number,
               ga.award_short_name,
               gi.installment_num,
               grt.report_name,
               gr.due_date,
               substrb(party.party_name,1,50) funding_source_short_name,
               gr.report_id  --bug 2282107
       from    gms_awards  ga,
               gms_installments gi,
               gms_reports  gr,
               gms_report_templates grt,
               hz_parties party,
               hz_cust_accounts cust_acct
       where  ga.award_template_flag ='DEFERRED'
       and    ga.status <> 'CLOSED'  --Changed from 'ACTIVE'  to fix bug 2200837
       and    ga.award_id = gi.award_id
       and    gi.active_flag = 'Y'
       and    gr.installment_id = gi.installment_id
       and    gr.report_template_id  = grt.report_template_id
       and    gr.due_date = trunc(sysdate) + l_offset_days     -- Bug 1868293
       and    ga.funding_source_id =cust_acct.cust_account_id(+)
       and    cust_acct.party_id = party.party_id;


	cursor c2 (p_award_id NUMBER,
		  p_event_type VARCHAR2)
	is
	select user_id, user_name
	from gms_notifications_v
	where event_type like p_event_type
	and award_id = p_award_id;

	l_award_id	number;
	l_award_number	varchar2(15);
	l_award_short_name varchar2(30);
	l_installment_num varchar2(15);
	l_report_name varchar2(60);
	l_report_due_date date;
	l_funding_source_name varchar2(255);
	l_user_id number;
	l_user_name varchar2(240);
	l_role_name varchar2(100);
	l_role_name_disp varchar2(100);  -- NOCOPY fix
        l_report_id   number; --bug 2282107
--start bug fix 2204122 changed the width of var l_user_roles to 32000 from 4000--
	l_user_roles varchar2(32000) := NULL;
--end bug fix 2204122--
	l_err_code number;
	l_err_stage varchar2(630);

	WF_API_EXCEPTION	exception;
	pragma exception_init(WF_API_EXCEPTION, -20002);

begin

gms_error_pkg.set_debug_context; -- Added for Bug: 2510024

IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('GMS_WF_PKG.SCHEDULE_NOTIFICATION - start', 'C');
END IF;

-- Start of code added for Bug 1868293
l_offset_days := p_offset_days;

If l_offset_days IS NULL Then
	FND_PROFILE.GET('GMS_NOTIFICATION_OFFSET_DAYS',l_offset_days);

	If l_offset_days IS NULL Then
     		IF L_DEBUG = 'Y' THEN
     			gms_error_pkg.gms_debug('Profile GMS_NOTIFICATION_OFFSET_DAYS is undefined', 'C');
     		END IF;
	Elsif (l_offset_days < 0) Then
     		IF L_DEBUG = 'Y' THEN
     			gms_error_pkg.gms_debug('Invalid value for Profile GMS_NOTIFICATION_OFFSET_DAYS', 'C');
     		END IF;
	End If;
End If;


If (l_offset_days >= 0) Then           -- End of code added for Bug 1868293
IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('GMS_WF_PKG.SCHEDULE_NOTIFICATION - Offset Days = '||to_char(l_offset_days), 'C');
END IF;

open c1;
	loop
	fetch c1 into
		l_award_id,
		l_award_number,
		l_award_short_name,
		l_installment_num,
		l_report_name,
		l_report_due_date,
		l_funding_source_name,
                l_report_id;  --bug 2282107

	exit when c1%NOTFOUND;

		open c2 (l_award_id
			,'REPORT%');
		loop
		fetch c2 into
			l_user_id,
			l_user_name;
		exit when c2%notfound;
                  ---bug# 3224843---
                  IF Excl_Person_From_Notification(l_award_id, l_user_id) = 'N' THEN
		     l_user_roles := l_user_roles||','||l_user_name;
                  END IF;
                  ---bug# 3224843---
		end loop;
		close c2;
-- In order to remove an extra comma (,) in the starting of l_user_roles
	if substr(l_user_roles,1,1) = ','
	then
		l_user_roles := substr(l_user_roles, 2, (length(l_user_roles) - 1));
	end if;

		l_role_name := l_award_id||'-'||l_report_id; -- change from l_report_name bug 2282107
		l_role_name_disp:= l_role_name ;

IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('GMS_WF_PKG.SCHEDULE_NOTIFICATION - role_name = '||l_role_name, 'C');
END IF;
--start bug fix 2204122--
--Commented the following line as this is called from procedure call_gms_debug--
--gms_error_pkg.gms_debug('GMS_WF_PKG.SCHEDULE_NOTIFICATION - user_roles = '||l_user_roles, 'C');
gms_client_extn_budget_wf.call_gms_debug(p_user_roles => l_user_roles
					,p_disp_text =>'GMS_WF_PKG.SCHEDULE_NOTIFICATION - user_roles = ') ;
--end bug fix 2204122--

----------------------------------------------------------------------------
		begin
		wf_directory.CreateAdhocRole(
					role_name => l_role_name,
					role_display_name => l_role_name_disp,
					language => 'AMERICAN', -- jjj
					territory => 'AMERICA', -- jjj
					notification_preference => 'MAILHTML'
					);
		exception
			when WF_API_EXCEPTION
			then
				NULL;
		end;
IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('GMS_WF_PKG.SCHEDULE_NOTIFICATION - created adhoc role', 'C');
END IF;
----------------------------------------------------------------------------

		wf_directory.RemoveUsersFromAdhocRole(role_name => l_role_name);

IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('GMS_WF_PKG.SCHEDULE_NOTIFICATION - removed users from adhoc role', 'C');
END IF;

		begin
--start bug fix 2204122--

		gms_client_extn_budget_wf.call_wf_addusers_to_adhocrole( p_user_roles => l_user_roles
									,p_role_name  => l_role_name);

--			wf_directory.AddUsersToAdhocRole( role_name => l_role_name
--							 ,role_users => l_user_roles);
--end bug fix 2204122--

		exception
		when WF_API_EXCEPTION
		then
			NULL;
		end;

IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('GMS_WF_PKG.SCHEDULE_NOTIFICATION - added users to adhoc role', 'C');
	gms_error_pkg.gms_debug('GMS_WF_PKG.SCHEDULE_NOTIFICATION - Calling start_report_wf_process...', 'C');
END IF;

		gms_wf_pkg.start_report_wf_process(
					x_award_id => l_award_id,
					x_award_number => l_award_number,
					x_award_short_name => l_award_short_name,
					x_installment_number => l_installment_num,
					x_report_name => l_report_name,
					x_report_due_date => l_report_due_date,
					x_funding_source_name => l_funding_source_name,
					x_role => l_role_name,
					x_err_code => l_err_code,
					x_err_stage => l_err_stage);

IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('GMS_WF_PKG.SCHEDULE_NOTIFICATION - After start_report_wf_process...', 'C');
END IF;
--start bug fix 2204122--
--As new set of userid's will get stored in l_user_roles. reinitializing the variable--
      l_user_roles := NULL ;
--end bug fix 2204122--
	end loop;
	close c1;
End if; -- if (l_offset_days >= 0) Then             -- Bug 1868293
exception
        when VALUE_ERROR then   -- Added, Bug 1868293
		-- Added RETCODE and ERRBUF for Bug:2464800
		ERRBUF := 'The following error occured : '||sqlerrm;
		RETCODE := '2';
        	IF L_DEBUG = 'Y' THEN
        		gms_error_pkg.gms_debug('Invalid value for Profile GMS_NOTIFICATION_OFFSET_DAYS', 'C');
        	END IF;

	when others
	then
		-- Changed RETCODE to 2 for Bug:2464800
		ERRBUF := 'The following error occured : '||sqlerrm;
		RETCODE := '2';

end Schedule_Notification;
------------------------------------------------------------------------------------

PROCEDURE Init_Installment_WF(x_award_id IN NUMBER
				     ,x_installment_id IN NUMBER)
IS
	l_user_id number;
	l_user_name varchar2(240);
	l_role_name varchar2(100);
	l_role_name_disp varchar2(100); -- NOCOPY related fix
--start bug fix 2204122 changed the width of var l_user_roles to 32000 from 4000--
	l_user_roles varchar2(32000) := NULL;
--end bug fix 2204122--
	l_err_code number;
	l_err_stage varchar2(630);
	l_wf_threshold_orig number;  -- Added for Bug:1457961

	WF_API_EXCEPTION	exception;
	pragma exception_init(WF_API_EXCEPTION, -20002);

	cursor c1 (p_award_id IN NUMBER)
	is
	select user_id, user_name
	from gms_notifications_v
	where event_type = 'INSTALLMENT_ACTIVE'
	and award_id = p_award_id;

begin
	SAVEPOINT create_installment_wf;


		open c1 (x_award_id);
		loop
		fetch c1 into
			l_user_id,
			l_user_name;
		exit when c1%notfound;
                  ---bug# 3224843---
                  IF Excl_Person_From_Notification(x_award_id, l_user_id) = 'N' THEN
		     l_user_roles := l_user_roles||','||l_user_name;
                  END IF;
                  ---bug# 3224843---
		end loop;

		close c1;

-- In order to remove an extra comma (,) in the starting of l_user_roles

	if substr(l_user_roles,1,1) = ','
	then
		l_user_roles := substr(l_user_roles, 2, (length(l_user_roles) - 1));
	end if;

		l_role_name := to_char(x_award_id)||'-'||to_char(x_installment_id)||'-INSTALLMENT';
		l_role_name_disp := l_role_name ;

----------------------------------------------------------------------------
		begin
		wf_directory.CreateAdhocRole(
					role_name => l_role_name,
					role_display_name => l_role_name_disp,
					language => 'AMERICAN',
					territory => 'AMERICA',
					notification_preference => 'MAILHTML'
					);
		exception
			when WF_API_EXCEPTION
			then
				NULL;
		end;
----------------------------------------------------------------------------

		wf_directory.RemoveUsersFromAdhocRole(role_name => l_role_name);

		begin
--start bug fix 2204122--
gms_client_extn_budget_wf.call_wf_addusers_to_adhocrole(p_user_roles => l_user_roles
							,p_role_name => l_role_name);

--		wf_directory.AddUsersToAdhocRole( role_name => l_role_name
--						 ,role_users => l_user_roles);
--end bug fix 2204122--
		exception
		when WF_API_EXCEPTION
		then
			NULL;
		end;

		-- The WF threshold logic has been added for Bug: 1457961
		-- the threshold is lowered to -1 so that the process is taken over
		-- by the background engine, which in turn is started by the concurrent
		-- process (Workflow Background Process) on regular intervals.
		-- The threshold is set back to the original threshold after calling
		-- the start_installment_wf procedure.

		-- l_wf_threshold_orig := wf_engine.threshold;
		-- wf_engine.threshold := -1;

		gms_wf_pkg.start_installment_wf( x_award_id => x_award_id
						,x_install_id => x_installment_id
						,x_role => l_role_name
						,x_err_code => l_err_code
						,x_err_stage => l_err_stage);

		-- wf_engine.threshold := l_wf_threshold_orig;

		if l_err_code <> 0
		then
			gms_error_pkg.gms_message(x_err_name => 'GMS_START_INSTALL_WF_FAIL',
						  x_err_code => l_err_code,
						  x_err_buff => l_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;
		end if;

EXCEPTION
	WHEN OTHERS
	THEN
		ROLLBACK to create_installment_wf;

END Init_Installment_WF;
------------------------------------------------------------------------------------
PROCEDURE start_installment_wf( x_award_id IN NUMBER
				  ,x_install_id IN NUMBER
				  ,x_role IN VARCHAR2
				  ,x_err_code OUT NOCOPY NUMBER
				  ,x_err_stage OUT NOCOPY VARCHAR2)
IS
ItemType varchar2(30) := 'GMSWF';
ItemKey number;

l_award_number		varchar2(15);
l_award_short_name	varchar2(30);
l_funding_source_name varchar2(255);

-- Bug Fix 2225725
--l_install_number 	number;
l_install_number 	gms_installments.installment_num%TYPE;
-- End of Fix

l_install_start_date 	date;
l_install_end_date	date;
l_install_issue_date	date;
l_install_close_date	date;
l_install_direct_cost 	number;
l_install_indirect_cost	number;
l_install_total_amount	number;
l_install_description	varchar(250);

l_workflow_started_by_id number := FND_GLOBAL.User_Id;
l_user_name 		varchar2(100) := FND_GLOBAL.User_Name;
l_full_name 		varchar2(65);
l_wf_started_date 	date := SYSDATE;

cursor l_starter_full_name_csr
is
	select p.first_name||' '||p.last_name /*Bug 5122724 */
        from fnd_user f, per_people_f p
        where p.effective_start_date = (select min(pp.effective_start_date)
                                        from per_all_people_f pp
                                        where pp.person_id = p.person_id
                                        and pp.effective_end_date >=trunc(sysdate))
        and ((p.employee_number is not null) OR (p.npw_number is not null))
        and user_id = FND_GLOBAL.User_Id
        and f.employee_id = p.person_id;

cursor l_installment_detail_csr
is
	select 	ga.award_number,
		ga.award_short_name,
		substrb(party.party_name,1,50),
		gi.installment_num,
		gi.start_date_active,
		gi.end_date_active,
		gi.issue_date,
		gi.close_date,
		gi.direct_cost,
		gi.indirect_cost,
		(nvl(gi.direct_cost,0) + nvl(gi.indirect_cost,0)),
		gi.description
	from 	gms_awards  ga,
		gms_installments gi, hz_parties party,
               hz_cust_accounts cust_acct
	where 	gi.award_id = ga.award_id
	and	cust_acct.cust_account_id(+) = ga.funding_source_id
        and	cust_acct.party_id = party.party_id
	and	gi.installment_id = x_install_id
	and	ga.award_id = x_award_id;

BEGIN

	x_err_code := 0;

	select gms_workflow_itemkey_s.nextval
	into ItemKey
	from dual;

	open l_starter_full_name_csr;
	fetch l_starter_full_name_csr into l_full_name;
	close l_starter_full_name_csr;

	open l_installment_detail_csr;
	fetch l_installment_detail_csr
	into
		l_award_number,
		l_award_short_name,
		l_funding_source_name,
		l_install_number,
		l_install_start_date,
		l_install_end_date,
		l_install_issue_date,
		l_install_close_date,
		l_install_direct_cost,
		l_install_indirect_cost,
		l_install_total_amount,
		l_install_description;

	IF (l_installment_detail_csr%NOTFOUND)
	THEN
		x_err_code := 10;
		x_err_stage := 'GMS_INVALID_INSTALLMENT';
		fnd_message.set_name('GMS','GMS_INVALID_INSTALLMENT');
		app_exception.raise_exception;
		close l_installment_detail_csr;
		return;
	END IF;

	close l_installment_detail_csr;


	wf_engine.CreateProcess( ItemType => ItemType,
				 ItemKey  => ItemKey,
				 process  => 'GMS_WF_PROCESS' );

-- Attribute GMS_WF_PROCESS is used to select the appropriate branch
-- in the workflow process.


	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'GMS_WF_PROCESS',
					avalue		=>  'INSTALLMENT');

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'AWARD_NUMBER',
					avalue		=>  l_award_number);

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'AWARD_SHORT_NAME',
					avalue		=>  l_award_short_name);

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'FUNDING_SOURCE_NAME',
					avalue		=>  l_funding_source_name);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'INSTALL_NUM',
					avalue		=>  l_install_number);

	wf_engine.SetItemAttrDate (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'INSTALL_START_DATE',
					avalue		=>  l_install_start_date);

	wf_engine.SetItemAttrDate (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'INSTALL_END_DATE',
					avalue		=>  l_install_end_date);

	wf_engine.SetItemAttrDate (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'INSTALL_ISSUE_DATE',
					avalue		=>  l_install_issue_date);

	wf_engine.SetItemAttrDate (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'INSTALL_CLOSE_DATE',
					avalue		=>  l_install_close_date);

	wf_engine.SetItemAttrNumber (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'INSTALL_DIRECT_COST',
					avalue		=>  l_install_direct_cost);

	wf_engine.SetItemAttrNumber (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'INSTALL_INDIRECT_COST',
					avalue		=>  l_install_indirect_cost);

	wf_engine.SetItemAttrNumber (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'INSTALL_TOTAL_AMOUNT',
					avalue		=>  l_install_total_amount);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'INSTALL_DESCRIPTION',
					avalue		=>  l_install_description);

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'NOTIF_RECIPIENT_ROLE',
					avalue		=>  x_role);

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

	wf_engine.SetItemAttrDate (	itemtype	=> itemtype,
	      			   	itemkey  	=> itemkey,
 	      			   	aname 		=> 'WF_STARTED_DATE',
				   	avalue		=> l_wf_started_date
				);


	wf_engine.StartProcess( 	itemtype	=> itemtype,
	      				itemkey		=> itemkey );


--	p_item_type	:= itemtype;
--	p_item_key	:= itemkey;

-- Added Exception for Bug:2662848

exception
when OTHERS then
	gms_error_pkg.gms_message(x_err_name => 'GMS_UNEXPECTED_ERROR',
				x_token_name1 => 'SQLCODE',
				x_token_val1 => sqlcode,
				x_token_name2 => 'SQLERRM',
				x_token_val2 => sqlerrm,
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;

end start_installment_wf;

------------------------------------------------------------------------------------
--Start : Build of the installment closeout Notification Bug # 1969587
/*======================================================================================================================
  Following Logic selects Open commitments associated with the particular award,project and task combination and frames
  a  message which gets displayed as text in the notification.
  ======================================================================================================================*/

PROCEDURE Get_Inst_Open_Commitments ( 	 document_id      IN      VARCHAR2
                    			,display_type     IN      VARCHAR2
                    			,document	  IN OUT NOCOPY  VARCHAR2
                    			,document_type    IN OUT NOCOPY  VARCHAR2) IS


  	l_item_type 			wf_items.item_type%TYPE;
  	l_item_key 				wf_items.item_key%TYPE;
  	l_document_id   		VARCHAR2(100);
  	l_document      		VARCHAR2(32000) := '';
  	l_commitment_number 		VARCHAR2(50);
  	l_commit_document_type  	VARCHAR2(3);
        l_commit_document_type_desc 	VARCHAR2(80);
  	l_amount            		NUMBER;
  	l_award_id	      		gms_awards.award_id%TYPE;
  	l_project_id	      		gms_encumbrance_items.project_id%TYPE;
  	l_task_id	      		gms_encumbrance_items.task_id%TYPE;
  	l_installment_end_date 		gms_installments.start_date_active%TYPE;
  	l_installment_start_date 	gms_installments.end_date_active%TYPE;
  	l_installment_id 		gms_installments.installment_id%TYPE;
  	l_header 			gms_lookups.meaning%TYPE;
  	l_award_number			gms_awards.award_number%TYPE;
  	l_installment_number		gms_installments.installment_num%TYPE;

	l_installment_end_date_text varchar2(60); /*Added for bug:7538344 */
	l_user_id      number; /*Added for bug:7538344 */

  -- Declare a variable to create a new line.
	NL                 		VARCHAR2(1) := fnd_global.newline;
  -- Cursor to fetch all the open commitments attached associated with the award ,project and task combination

 	CURSOR  lookups_cursor (type VARCHAR2) IS
  		 SELECT  meaning
                 FROM  gms_lookups
                 WHERE  lookup_type='GMS_COMMT_TYPE'
                 AND lookup_code = type ;


 	CURSOR  lookup_document (header VARCHAR2) IS
  		SELECT  meaning
                FROM gms_lookups
                WHERE lookup_type='GMS_DOC_NOTIF'
                AND lookup_code = header ;

 /*
 -- Bug 3465169 : Modified the below sql to fix issue  'Sharable memory is greater than 1000000.'
 --               Fix : The below cursor was using gms_status_commitments_v which inturn
 --                     fires gms_commitment_encumbered_v twice i.e once for fetching raw line
 --                     and once for burden line.
 --                     Hence modified the sql to directly use gms_status_commitments_v for fetching
 --                     raw data and calculate burden for each raw line.
 --                     The option of directly calling base tables was not feasible as there was
 --                     no much performance improvement and also would result in code duplication
 --                     as the below sql needs AP,REQ,PO and burden calculation logic.

 	CURSOR open_commitments( p_installment_id VARCHAR2
 				,p_award_id       NUMBER
 				,p_installment_start_date DATE
 				,p_installment_end_date   DATE  ) IS
  	       SELECT  gscv.commitment_number
  	       	      ,gscv.document_type
           	      ,SUM(gscv.burdened_cost)
 	       FROM gms_status_commitments_v gscv ,gms_summary_project_fundings  gmpf
               WHERE gmpf.installment_id = p_installment_id
 	             AND gscv.award_id = p_award_id
  	             AND gscv.project_id  =  gmpf.project_id
  	             AND gscv.task_id =      nvl(gmpf.task_id,gscv.task_id)
  	             AND gscv.expenditure_item_date BETWEEN p_installment_start_date AND  p_installment_end_date
   	             AND gscv.document_type  IN  ('AP','PO','REQ')
  	       GROUP BY document_type , gscv.project_id , gscv.task_id , award_id , commitment_number ;    */
--For Bug 4948033:SQL Repository :Modified the Select statement so that
--Shared memory gets reduced
--


        CURSOR open_commitments( p_installment_id VARCHAR2
 				,p_award_id       NUMBER
 				,p_installment_start_date DATE
 				,p_installment_end_date   DATE  ) IS
              SELECT  cmt.cmt_number
  	       	      ,cmt.document_type
           	      ,PA_CURRENCY.ROUND_CURRENCY_AMT(SUM (cmt.acct_raw_cost +
		                                            DECODE(nvl(cmt.ind_compiled_set_id,0),0,0,
							                DECODE(NVL(cmt.burdenable_raw_cost,0),0,0,
								                   gms_wf_pkg.Get_Burden_amount(cmt.expenditure_type,
										                                cmt.organization_id,
														cmt.ind_compiled_set_id,
														cmt.burdenable_raw_cost)
									       )
								   )
							   )
							 )
 	       FROM  gms_commitment_encumbered_v cmt
               WHERE cmt.award_id =  p_award_id
  	      AND (cmt.project_id,cmt.task_id) IN (SELECT  gmpf.project_id,nvl(gmpf.task_id,cmt.task_id)
						   FROM gms_summary_project_fundings  gmpf
						   WHERE gmpf.installment_id =p_installment_id )
  	       AND cmt.expenditure_item_date BETWEEN p_installment_start_date AND  p_installment_end_date
   	       AND cmt.document_type  IN  ('AP','PO','REQ')
  	       GROUP BY document_type , cmt.project_id , cmt.task_id , cmt.award_id , cmt.cmt_number ;

BEGIN

 -- Get the values of all the attributes used in this procedure to generate an message.
  	l_item_type:= substr(document_id, 1, instr(document_id, ':') - 1);
  	l_item_key := substr(document_id, instr(document_id, ':') + 1,length(document_id) - 2);
  	l_document_id := wf_engine.GetItemAttrNumber
                                     (itemtype   => l_item_type,
                                      itemkey    => l_item_key,
                                      aname      => 'DOCUMENT_ID');
 	l_Award_number := wf_engine.GetItemAttrText
               	                     (itemtype   => l_item_type,
                                      itemkey    => l_item_key,
                                      aname      => 'AWARD_NUMBER');
 	l_Award_id := wf_engine.GetItemAttrNumber
 	                       	      (itemtype   => l_item_type,
                                      itemkey    => l_item_key,
                                      aname      => 'AWARD_ID');
  	l_Installment_id    := wf_engine.GetItemAttrNumber
	   			      (itemtype   => l_item_type,
                                      itemkey    => l_item_key,
                                      aname      => 'INSTALL_ID');
  	l_Installment_number := wf_engine.GetItemAttrText
		      			(itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'INSTALL_NUM');

 	l_Installment_End_date:= wf_engine.GetItemAttrDate
    			               	(itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'INSTALL_END_DATE');

 	l_Installment_start_date:= wf_engine.GetItemAttrDate
    			             	(itemtype   => l_item_type,
                                       	 itemkey    => l_item_key,
                                         aname      => 'INSTALL_START_DATE');


  --Changes for bug:7538344   starts here
   if (FND_RELEASE.MAJOR_VERSION = 12 and FND_RELEASE.minor_version >= 1 and FND_RELEASE.POINT_VERSION >= 1 )
    or (FND_RELEASE.MAJOR_VERSION > 12) then

     begin

      --Obtain the user_id based on the unique user_name
      SELECT USER_ID
      INTO   l_user_id
      FROM   FND_USER
      WHERE  user_name = FND_GLOBAL.User_Name;
    exception
      when NO_DATA_FOUND then
        l_user_id := to_number(null);
     end;
   if (display_type=wf_notification.doc_html) then
   l_Installment_End_date_text := to_char(l_Installment_End_date,
                                 FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK',l_user_id),
                                   'NLS_CALENDAR = ''' || NVL(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', l_user_id), 'GREGORIAN') || ''''); /*Added for bug:8974271*/
    else
     l_Installment_End_date_text := to_char(l_Installment_End_date,
                                   FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK',l_user_id),
                                      'NLS_CALENDAR = ''' || NVL(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', l_user_id), 'GREGORIAN') || ''''); /*Added for bug:8974271*/
    end if;
    else
       l_Installment_End_date_text := to_char(l_Installment_End_date);
     end if;
      --Changes for bug:7538344  Ends here

 -- Thel message that's going to be printed in the notification is concatenated to the l_document variable.
 -- based on the different conditions the document to be printed is framed.

   IF (display_type = 'text/html') THEN

    l_document := NL || NL || '<!-- INSTALLMENT_CLOSEOUT -->'|| NL || NL || '<P><B>';

            -- Set the tokens of the message.
    		fnd_message.set_name('GMS', 'GMS_WF_INSTALL_END_DATE');
    		fnd_message.set_token('INSTALLMENT_NUMBER', l_installment_number);
    		fnd_message.set_token('AWARD_NUMBER', l_award_number);
    		fnd_message.set_token('INSTALLMENT_END_DATE', l_installment_end_date_text); --added for bug:7538344
    		l_document := l_document || fnd_message.get|| NL;
    		l_document := l_document || '</P></B>' || NL;

        	 -- Set the tokens of the message
		l_document := l_document || '<P><B>' ;
        	fnd_message.set_name('GMS', 'GMS_WF_NOTIFY_INSTALL_CLSOUT');
--		Commented the following token as part of bug fix 2049763
--    		fnd_message.set_token('INSTALLMENT_NUMBER', l_installment_number);
    		l_document := l_document || fnd_message.get|| NL;
    		l_document := l_document || '</B></P>' || NL;

 -- Open the cursor and fetch values .if no data is found than nothing will be printed else the
 -- GMS_WF_NOTIFY_OPEN_COIMMITMENTS gets printed and also the open commitments will be printed in a table format

  		    OPEN open_commitments(l_installment_id ,
  				      l_award_id ,
  				      l_installment_start_date,
  				      l_installment_end_date) ;

  	            FETCH open_commitments  INTO l_commitment_number   ,
  			     			 	 l_commit_document_type,
                  			     	 	 l_amount ;
    		IF (open_commitments%FOUND ) THEN
		        l_document := l_document || '<P><B>' ;
     			l_document := l_document || fnd_message.get_string('GMS', 'GMS_WF_NOTIFY_OPEN_COMMT')|| NL;
    			l_document := l_document || '<P></B>' || NL;
    			l_document := l_document || '<TABLE border=1 cellpadding=2 cellspacing=1>' || NL;
    			l_document := l_document || '<TR>';

			OPEN lookup_document('DOCN');
    			FETCH lookup_document INTO l_header;
               	        CLOSE lookup_document;

			l_document := l_document || '<TH>' || l_header || '</TH>' || NL;
      		   	OPEN lookup_document('DOCT');
      		   	FETCH lookup_document INTO l_header;
               		CLOSE lookup_document;
    		     	l_document := l_document || '<TH>' ||   l_header || '</TH>' || NL;
      		    	OPEN lookup_document('AMT');
      		        FETCH lookup_document INTO l_header ;
               		CLOSE lookup_document;
    		     	l_document := l_document || '<TH>' || l_header || '</TH>' || NL;
    		     	l_document := l_document || '</TR>' || NL;
 			LOOP
      				l_document := l_document || '<TR>' || NL;
      				l_document := l_document || '<TD nowrap align=center>' || l_commitment_number || '</TD>' || NL;

                                -- Based on the Document type the following text will be printed under the document type header.

     				OPEN lookups_cursor(l_commit_document_type);
     				FETCH lookups_cursor into l_commit_document_type_desc;
      				CLOSE lookups_cursor;

				l_document := l_document || '<TD nowrap>' || l_commit_document_type_desc || '</TD>' || NL;
      				l_document := l_document || '<TD nowrap>' || l_amount || '</TD>' || NL;
      				l_document := l_document || '</TR>' || NL;

				FETCH open_commitments  INTO  l_commitment_number
  			    	  			     ,l_commit_document_type
    				  			     ,l_amount;
       				EXIT WHEN open_commitments%NOTFOUND;
      			END LOOP;
			document_type := 'text/html';
       			l_document := l_document || '</TABLE></P>' || NL;
    		END IF;
    		CLOSE open_commitments;
    		document := l_document;

 -- If the display type is text/plain

  	ELSIF (display_type = 'text/plain') THEN

       		fnd_message.set_name('GMS','GMS_WF_INSTALL_END_DATE');
    		fnd_message.set_token('INSTALLMENT_NUMBER', l_installment_number);
    		fnd_message.set_token('AWARD_NUMBER', l_award_number);
    		fnd_message.set_token('INSTALLMENT_END_DATE', l_installment_end_date_text );	--added for bug:7538344
    		l_document := l_document || fnd_message.get || NL;

  	        l_document := l_document || NL;
       		fnd_message.set_name('GMS', 'GMS_WF_NOTIFY_INSTALL_CLSOUT');
--		Commented the following token as part of bug fix 2049763
--    		fnd_message.set_token('INSTALLMENT_NUMBER', l_installment_number);
    		l_document := l_document || fnd_message.get || NL;

       		OPEN open_commitments(l_installment_id
       				      ,l_award_id
       				      ,l_installment_start_date
       				      ,l_installment_end_date);

       		FETCH open_commitments INTO  l_commitment_number
       				            ,l_commit_document_type
       	         			    ,l_amount;
	        l_document := l_document ||  NL;
    		IF (open_commitments%found ) THEN
    			l_document := l_document || fnd_message.get_string('GMS', 'GMS_WF_NOTIFY_OPEN_COMMT')|| NL;
    			l_document := l_document ||  NL;

			OPEN lookup_document('DOCN');
      			FETCH lookup_document INTO l_header;
                	CLOSE lookup_document;

           		l_document := l_document ||rpad(l_header,50);

      			OPEN lookup_document('DOCT');
      			FETCH lookup_document INTO l_header ;
               	        CLOSE lookup_document;

      			l_document := l_document || rpad(l_header,16);

       			OPEN lookup_document('AMT');
       			FETCH lookup_document INTO l_header;
               	        CLOSE lookup_document;

      			l_document := l_document || l_header ;

		        l_document := l_document || NL ;

                        --Rpad is used for handling the padding of text

   			LOOP
      				l_document := l_document || NL ;
      				l_document := l_document || rpad(l_commitment_number,50);

				OPEN lookups_cursor(l_commit_document_type);
     				FETCH lookups_cursor into l_commit_document_type_desc;
      				CLOSE lookups_cursor;

      				l_document := l_document || rpad(l_commit_document_type_desc,16);
       				l_document := l_document || l_amount;
      				l_document := l_document || NL;
            			FETCH open_commitments  INTO l_commitment_number ,l_commit_document_type, l_amount;
      				EXIT WHEN open_commitments%NOTFOUND;
    			END LOOP;
   		END IF;
   		document_type := 'text/plain';
    		CLOSE open_commitments;
    		l_document := l_document;
    		document := l_document;
 	END IF;
END Get_Inst_Open_Commitments;


/*===================================================================================================
  Following Procedure Set the values of the workflow attributes and the starts the work flow process
 ====================================================================================================*/

PROCEDURE  Start_Inst_Clsout_wf_Process (
 					  x_award_id 		IN  NUMBER
					, x_installment_id 	IN  NUMBER
					, x_role 		IN  VARCHAR2
					, x_err_code 		OUT NOCOPY NUMBER
					, x_err_stage 		OUT NOCOPY VARCHAR2 )  IS



	ItemType 			VARCHAR2(30) := 'GMSWF';
	ItemKey 			NUMBER;
	l_installment_end_date  	gms_installments.end_date_active%TYPE;
	l_installment_start_date   	gms_installments.start_date_active%TYPE;
	l_award_number              	gms_awards.award_number%TYPE;
	l_installment_number      	gms_installments.installment_num%TYPE;

	CURSOR award_cursor IS
		SELECT  award_number
		FROM   gms_awards
		WHERE award_id = x_award_id;

	CURSOR installment_cursor is
		SELECT   installment_num
          		,end_date_active
          		,start_date_active
		FROM   gms_installments
		WHERE installment_id = x_installment_id;


BEGIN
 	x_err_code := 0;
	SELECT gms_workflow_itemkey_s.NEXTVAL INTO ItemKey FROM DUAL;

	OPEN award_cursor;
	FETCH award_cursor INTO  l_award_number;
	close award_cursor;

	OPEN installment_cursor;
	FETCH installment_cursor INTO l_installment_number,l_installment_end_date, l_installment_start_date;
	CLOSE installment_cursor;

-- Creating the workflow Process

	wf_engine.CreateProcess( ItemType => ItemType,
		    		 ItemKey  => ItemKey,
		    		 process  => 'GMS_WF_PROCESS' );

-- Attribute GMS_WF_PROCESS is used to select the appropriate branch
-- in the workflow process.
-- Set the values for all the attributes used for this workflow process

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'GMS_WF_PROCESS',
					avalue		=> 'INSTALLMENT_CLOSEOUT');

	wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'AWARD_ID',
					avalue		=>  x_award_id);

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'AWARD_NUMBER',
					avalue		=>  l_award_number);

 	wf_engine.SetItemAttrNumber ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'INSTALL_ID',
					avalue		=> x_installment_id);

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'INSTALL_NUM',
					avalue		=> l_installment_number);

	wf_engine.SetItemAttrDate ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'INSTALL_END_DATE',
					avalue		=> l_installment_end_date);

	wf_engine.SetItemAttrDate ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'INSTALL_START_DATE',
					avalue		=> l_installment_start_date);

	wf_engine.SetItemAttrText ( 	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'DOCUMENT_ID',
					avalue		=>  ItemType ||':'||to_char(ItemKey));

  	wf_engine.SetItemAttrtext(	itemtype => itemtype,
                           		itemkey  => itemkey,
                           		aname    => 'CLOSEOUT_MESSAGE',
                           		avalue   => 'PLSQL:GMS_WF_PKG.Get_Inst_Open_Commitments/'||itemtype||':'||to_char(itemkey));

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'NOTIF_RECIPIENT_ROLE',
					avalue		=>  x_role);
-- Start the work flow process

	wf_engine.StartProcess  ( 	itemtype	=> itemtype,
	      				itemkey		=> itemkey );
-- Added Exception for Bug:2662848
EXCEPTION
when OTHERS then
	gms_error_pkg.gms_message(x_err_name => 'GMS_UNEXPECTED_ERROR',
				x_token_name1 => 'SQLCODE',
				x_token_val1 => sqlcode,
				x_token_name2 => 'SQLERRM',
				x_token_val2 => sqlerrm,
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;

END Start_Inst_Clsout_wf_Process;



/*========================================================================================================
  Following Logic selects installments for which  notification are to be generated
  and then calls the procedure which kicks of the workflow process in loop for each installment selected.
  ========================================================================================================*/

PROCEDURE Notify_Installment_Closeout(
 				       ERRBUF        OUT NOCOPY VARCHAR2
     				       ,RETCODE       OUT NOCOPY VARCHAR2
				       ,p_offset_days IN  NUMBER ) IS

--Cursor to selects all the installments which are going to get closed  by the offset number of days
   	CURSOR award_install_cursor is
 		SELECT   	ga.award_id ,
            			gi.installment_id
 		FROM  	gms_awards        ga,
       			gms_installments  gi
		WHERE   gi.award_id = ga.award_id
 		AND 	trunc(gi.end_date_active )= trunc(SYSDATE) + p_offset_days
 		AND 	ga.status <> 'CLOSED'  -- Change from 'ACTIVE' to fix bug 2200585
        	AND	gi.active_flag = 'Y'
                AND     ga.award_template_flag ='DEFERRED'; --Added to fix bug 2200585
	--	AND 	ga.budget_wf_enabled_flag = 'Y' Commented out NOCOPY to fix bug 2200585

--Cursor to select corresponding user id attached to each award personnel .
	CURSOR  gms_notification_cursor ( p_award_id      NUMBER) IS
		SELECT   gn.user_id ,
 		         fu.user_name
		FROM	gms_notifications gn, fnd_user fu
		WHERE	gn.user_id = fu.user_id
		AND     event_type = 'INSTALLMENT_CLOSEOUT'
		AND 	award_id = p_award_id;



-- Declare the variables Used during the workflow process

	l_award_id		gms_awards.award_id%TYPE;
	l_installment_id        gms_installments.installment_id%TYPE;
	l_user_id 		fnd_user.user_id%TYPE;
	l_user_name 		fnd_user.user_name%TYPE;
	l_role_name 		VARCHAR2(1000);
	l_role_name_disp 	VARCHAR2(1000); -- Fix for NOCOPY  related issues.
--start bug fix 2204122 changed the width of var to 32000 from 4000--
	l_role_users		VARCHAR2(32000) := NULL;
--end bug fix 2204122--

	l_offset_days 		NUMBER;

-- Declare variable used to handle errors
	l_err_code 		NUMBER;
	l_err_stage 		VARCHAR2(630);
	WF_API_EXCEPTION	EXCEPTION;
	PRAGMA EXCEPTION_INIT(WF_API_EXCEPTION, -20002);

BEGIN
	gms_error_pkg.set_debug_context; -- Added for Bug: 2510024

	l_offset_days := p_offset_days;

-- If the value of the parameter passed from the concurrent request is null then pick up the value
-- set at profile option

	IF l_offset_days IS NULL THEN
		FND_PROFILE.GET('GMS_NOTIFICATION_OFFSET_DAYS', l_offset_days);
	END IF;
	IF (l_offset_days >= 0) THEN

-- After a valid offset days is supplied .Open the cursor which returns all the Installments that are going to be ended by offset
-- number of days. Loop is created  for each Installment.

		OPEN  award_install_cursor ;
 		LOOP
		FETCH award_install_cursor INTO l_award_id , l_installment_id;
   		EXIT WHEN award_install_cursor%NOTFOUND;

-- For each Installment id open the cursor  c2 which will fetch all the persons who are attached to this award and
-- concatenates with the l_role_users variable.

                l_role_users := NULL;                         -- Bug 6137699: Base Bug 6034495

		OPEN gms_notification_cursor (l_award_id);

   		LOOP
		   FETCH gms_notification_cursor INTO l_user_id,l_user_name;
       		   EXIT WHEN gms_notification_cursor%NOTFOUND;
                   ---bug# 3224843---
                   IF Excl_Person_From_Notification(l_award_id, l_user_id) = 'N'  THEN
       		     l_role_users := l_role_users ||','||l_user_name;
                   END IF;
                   ---bug# 3224843---

       	END LOOP;

       	CLOSE gms_notification_cursor;



-- Use the following logic to remove an extra comma (,) in the starting of  l_role_users

		IF SUBSTR(l_role_users,1,1) = ',' THEN
 			l_role_users:=SUBSTR(l_role_users,2,(LENGTH(l_role_users)-1));
		END IF;

    	l_role_name := l_installment_id||'-'|| 'INSTALLMENT_CLOSEOUT';
    	l_role_name_disp := l_role_name ;


--create an Adhoc role
--language and territory are not passed .These parameters will be resolved based on the sessions setting.

 			BEGIN
				wf_directory.CreateAdhocRole(
								role_name 	  	        => l_role_name,
								role_display_name               => l_role_name_disp,
								notification_preference => 'MAILHTML'
						     	    );
			EXCEPTION
				WHEN WF_API_EXCEPTION THEN NULL;
			END;

-- Delete the users attached to the New role created calling the following function :
       		wf_directory.RemoveUsersFromAdhocRole(role_name => l_role_name);

--Add  all the users retrieved  from the cursor 2  to the new role created
			BEGIN
--start bug fix 2204122--
gms_client_extn_budget_wf.call_wf_addusers_to_adhocrole(p_user_roles => l_role_users
							,p_role_name => l_role_name) ;

--		wf_directory.AddUsersToAdhocRole( role_name => l_role_name
--						 ,role_users => l_user_roles);
--end bug fix 2204122--
			/*	wf_directory.AddUsersToAdhocRole( role_name => l_role_name
	   			 				  ,role_users => l_role_users);*/
   			EXCEPTION
	   			WHEN WF_API_EXCEPTION THEN NULL;
	   		END;


-- Call the procedure which starts the concurrent process
   				Start_Inst_Clsout_Wf_Process( x_award_id 		=> l_award_id,
								 x_installment_id 	=> l_installment_id,
								 x_role 		=> l_role_name,
								 x_err_code 		=> l_err_code,
								 x_err_stage 		=> l_err_stage);

		END LOOP;
		CLOSE award_install_cursor;
	END IF;
EXCEPTION
        WHEN VALUE_ERROR THEN
			-- Added RETCODE and ERRBUF for Bug:2464800
			RETCODE := '2';
			ERRBUF  := 'The following error occured :  '||sqlerrm;
          		IF L_DEBUG = 'Y' THEN
          			gms_error_pkg.gms_debug('Invalid value for Profile GMS_NOTIFICATION_OFFSET_DAYS', 'C');
          		END IF;
	WHEN OTHERS THEN
			-- Changed RETCODE to 2 for Bug:2464800
			RETCODE := '2';
			ERRBUF  := 'The following error occured :  '||sqlerrm;

END Notify_Installment_Closeout;
--End : Build of the installment closeout Notification Bug # 1969587

-- -------------------
-- FUNCTION
-- -------------------
-- This function prevents notifying inactive Key Members
   FUNCTION Excl_Person_From_Notification
          (p_award_id NUMBER, p_user_id NUMBER)
   RETURN VARCHAR2 IS
       --This function returns either 'Y' to exclude person from getting notifications
       --OR 'N' to receive notifications.
        ------bug# 3224843 ----
        --This checks if person exists in personnal tab
        --user_id will always bring a unique person_id
        cursor chk_person_exists ( p_person_id Number )
        is
        select 1
          from gms_personnel gmsp
         where gmsp.award_id = p_award_id
           and gmsp.person_id = p_person_id;
        /*******
           and gmsp.person_id in
               (select fndu.employee_id
                  from fnd_user fndu
                 where fndu.user_id = p_user_id) ;
        *******/  --commented as per bug# 3495840 fix

        --Bug# 3495840
        --Check to see the person an ACTIVE user and a HR person
        --user_id will always bring a unique person_id
        --Also, beware that employee_id could be blank too
        --blank employee_id should be rejected
        cursor is_user_active
        is
          select fndu.employee_id /*Bug 5122724 */
            from fnd_user fndu
                ,per_people_f p
            where p.effective_start_date = (select min(pp.effective_start_date)
                                        from per_all_people_f pp
                                        where pp.person_id = p.person_id
                                        and pp.effective_end_date >=trunc(sysdate))
            and ((p.employee_number is not null) OR (p.npw_number is not null))
            and p.person_id = fndu.employee_id
            and fndu.user_id = p_user_id;
            /*and trunc(sysdate) between start_date
                                    and nvl(end_date,to_date('12/31/4712','MM/DD/YYYY'))*/

        --Only person active will receive notification
        cursor chk_person_active ( p_person_id NUMBER)
        is
        select 1
          from gms_personnel
         where person_id = p_person_id
           and award_id = p_award_id
           and trunc(sysdate) between start_date_active
                                  and nvl(end_date_active,to_date('12/31/4712','MM/DD/YYYY'));


        --local variable
        l_person_id NUMBER;
        l_count     NUMBER;

   BEGIN

     --Bug# 3495840
     --
     --Check if the person is an ACTIVE system user as of run date
     --  and if the person is an ACTIVE employee or a contingent worker
     --
     OPEN is_user_active;
     FETCH is_user_active INTO l_person_id;
     CLOSE is_user_active;

     --Exclude, as user is not active
     IF l_person_id IS NULL THEN
        RETURN 'Y';
     END IF;
     --
     --Finally, if the person is end-dated in personnel tab of
     --award window then do not send notification to this person
     --

     --Check if person is listed in award
     OPEN chk_person_exists ( l_person_id );
     FETCH chk_person_exists INTO l_count;
     CLOSE chk_person_exists;
     --person exists in award
     IF l_count is NOT NULL THEN
        OPEN chk_person_active ( l_person_id );
        FETCH chk_person_active INTO l_count;
        l_count := chk_person_active%ROWCOUNT;
        CLOSE chk_person_active;

        --person not active
        IF l_count = 0 THEN
           RETURN 'Y';
        END IF;
     END IF;
   --do not exclude
   RETURN 'N';
   END Excl_Person_From_Notification;
END gms_wf_pkg;

/
