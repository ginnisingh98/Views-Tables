--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_BUDGET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_BUDGET" AS
/* $Header: PAXBCECB.pls 120.2 2005/08/19 17:08:53 mwasowic ship $ */

 PROCEDURE Calc_Raw_Cost(x_budget_version_id     in number,
                        x_project_id             in number,
                        x_task_id                in number,
                        x_resource_list_member_id  in number,
                        x_resource_list_id       in number,
                        x_resource_id            in number,
                        x_start_date             in date,
                        x_end_date               in date,
                        x_period_name            in varchar2,
                        x_quantity               in number,
                        x_raw_cost               in out NOCOPY number, --File.Sql.39 bug 4440895
                        x_pm_product_code        in varchar2,
                        --x_txn_currency_code      IN VARCHAR2 DEFAULT NULL,
                        x_txn_currency_code      IN VARCHAR2 ,
                        x_error_code             out NOCOPY number, --File.Sql.39 bug 4440895
                        x_error_message          out NOCOPY varchar2) --File.Sql.39 bug 4440895

 IS
     /* start of bug 3736220 */
      CURSOR get_resource_assignment_id(p_budget_version_id in NUMBER,
	                                   p_project_id in NUMBER,
					   p_task_id in NUMBER,
					   p_resource_list_member_id in NUMBER)
	 IS
		 SELECT resource_assignment_id FROM pa_resource_assignments
		 WHERE  budget_version_id = p_budget_version_id AND
			project_id = p_project_id AND
			task_id = p_task_id AND
			resource_list_member_id = p_resource_list_member_id;

   l_err_code                 varchar2(30);
    /* end of bug 3736220 */
     -- Define your local variables here

 BEGIN
     -- Initialize the output parameters
     x_error_code := 0;
     l_err_code := null;    -- Added for bug 3736220
     -- Enter your business rules to calculate raw cost here

 EXCEPTION
     WHEN OTHERS THEN
       -- Add your exception handler here.
       -- To raise an ORACLE error, assign SQLCODE to x_error_code
       null;
 END Calc_Raw_Cost;

-- =================================================

 PROCEDURE Calc_Burdened_Cost(x_budget_version_id   in number,
                           x_project_id             in number,
                           x_task_id                in number,
                           x_resource_list_member_id  in number,
                           x_resource_list_id       in number,
                           x_resource_id            in number,
                           x_start_date             in date,
                           x_end_date               in date,
                           x_period_name            in varchar2,
                           x_quantity               in number,
                           x_raw_cost               in number,
                           x_burdened_cost          in out NOCOPY number, --File.Sql.39 bug 4440895
                           X_pm_product_code        in varchar2,
                           x_txn_currency_code      IN VARCHAR2 ,
                           --x_txn_currency_code      IN VARCHAR2 DEFAULT NULL,
                           x_error_code             out NOCOPY number, --File.Sql.39 bug 4440895
                           x_error_message          out NOCOPY varchar2) --File.Sql.39 bug 4440895
 IS
 /* start of bug 3736220 */
      CURSOR get_resource_assignment_id(p_budget_version_id in NUMBER,
	                                   p_project_id in NUMBER,
					   p_task_id in NUMBER,
					   p_resource_list_member_id in NUMBER)
	 IS
		 SELECT resource_assignment_id FROM pa_resource_assignments
		 WHERE  budget_version_id = p_budget_version_id AND
			project_id = p_project_id AND
			task_id = p_task_id AND
			resource_list_member_id = p_resource_list_member_id;

   l_err_code                 varchar2(30);
    /* end of bug 3736220 */
     -- Define your local variables here

 BEGIN

     -- Initialize the output parameters

     x_error_code := 0;
     l_err_code := null;    -- Added for bug 3736220

     -- Add your business rules to calculate burdened cost here

 EXCEPTION
     WHEN OTHERS THEN
       -- Add your exception handler here.
       -- To raise an ORACLE error, assign SQLCODE to x_error_code
       null;
 END Calc_Burdened_Cost;

-- =================================================
  PROCEDURE Calc_Revenue(x_budget_version_id        in number,
                           x_project_id             in number,
                           x_task_id                in number,
                           x_resource_list_member_id  in number,
                           x_resource_list_id       in number,
                           x_resource_id            in number,
                           x_start_date             in date,
                           x_end_date               in date,
                           x_period_name            in varchar2,
                           x_quantity               in number,
                           x_revenue                in out NOCOPY number, --File.Sql.39 bug 4440895
                           x_pm_product_code        in varchar2,
                           x_txn_currency_code      IN VARCHAR2 ,
                           --x_txn_currency_code      IN VARCHAR2 DEFAULT NULL,
                           x_error_code             out NOCOPY number, --File.Sql.39 bug 4440895
                           x_error_message          out NOCOPY varchar2, --File.Sql.39 bug 4440895
                           x_raw_cost               IN NUMBER ,
                           x_burdened_cost          IN NUMBER )
  IS
  /* start of bug 3736220 */
      CURSOR get_resource_assignment_id(p_budget_version_id in NUMBER,
	                                   p_project_id in NUMBER,
					   p_task_id in NUMBER,
					   p_resource_list_member_id in NUMBER)
	 IS
		 SELECT resource_assignment_id FROM pa_resource_assignments
		 WHERE  budget_version_id = p_budget_version_id AND
			project_id = p_project_id AND
			task_id = p_task_id AND
			resource_list_member_id = p_resource_list_member_id;

   l_err_code                 varchar2(30);
    /* end of bug 3736220 */
     --define your local variables here

  BEGIN

     -- Initialize the output parameters here
     x_error_code := 0;
     l_err_code := null;    -- Added for bug 3736220
     -- Add your business rules to calculate revenue here

 EXCEPTION
     WHEN OTHERS THEN
       -- Add your exception handler here.
       -- To raise an ORACLE error, assign SQLCODE to x_error_code
       null;
 END Calc_Revenue;
-- =================================================

--Name:              Verify_Budget_Rules
--Type:               Procedure
--Description:
--
--
--Called subprograms: none.
--
--
--
--History:
--	Summer-97	jwhite	Created
--
--	26-APR-01	jwhite	For the Verify_Budget_Rules API,
--                              added notes and code for global
--                              G_bgt_intg_flag for GL/PA Budget Integration.
--
--	07-AUG-01	jwhite  Updated tech doc for Financial Planning. See
--                              p_budget_type_code notes below.
--
-- NOTES:
--
-- IN
--   p_workflow_started_by_id	- identifies the user that initiated the workflow
--   p_event			- indicates whether procedure called for
--				  either a 'SUBMIT' or 'BASELINE'
--				  event.
--
--   p_budget_type_code        - For r11.5.7 Budgets this code is NOT null.
--
--                               !!! For Financial Planning Plan Types, this IN-parameter is NULL !!!
--
--                               Therefore, if you have special processing for Plan Types,
--                               you must code the following:
--
--                                  IF (p_budget_type_code IS NULL)
--                                    THEN
--                                      Code any financial planning logic.
--
--
--   G_bgt_intg_flag           - PA_BUDGET_UTILS.G_Bgt_Intg_Flag
--                               This package specification global defaults to NULL.
--                               It may be populated by the Budgets form and other Budget
--                               APIs for integration budgets. It will NOT be populated
--                               by Budget and Project Form Copy_Budget functions.
--
--                               The values and meanings for this global are as follows:
--                                  NULL- Budget Integration not enabled
--                                  'N' - Budget Integration not enabled
--                                  'G' - GL Budget Integration
--                                  'C' - CBC Budget Integration
--
--
-- OUT
--    p_warnings_only_flag	- RETURN 'Y' if ALL triggered edits are warnings. Otherwise,
--				   if there is at least one hard error, then RETURN 'N'.
--    p_err_msg_count		-  Count of warning and error messages.
--
--  By using the commented code in the body of this procedure, you may
--  add error and warning messages to the message stack.
--
--  Moreover, error/warning processing in the calling procedure
--  will only occur if OUT p_err_msg_count
--  parameter is greater than zero.
--

PROCEDURE Verify_Budget_Rules
 (p_draft_version_id		IN 	NUMBER
  , p_mark_as_original  	IN	VARCHAR2
  , p_event			IN	VARCHAR2
  , p_project_id        	IN 	NUMBER
  , p_budget_type_code  	IN	VARCHAR2
  , p_resource_list_id		IN	NUMBER
  , p_project_type_class_code	IN 	VARCHAR2
  , p_created_by 		IN	NUMBER
  , p_calling_module		IN	VARCHAR2
  , p_fin_plan_type_id          IN      NUMBER
  --, p_fin_plan_type_id          IN      NUMBER DEFAULT NULL
  , p_version_type              IN      VARCHAR2
  --, p_version_type              IN      VARCHAR2 DEFAULT NULL
  , p_warnings_only_flag	OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  , p_err_msg_count		OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
  , p_error_code             	OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
  , p_error_message          	OUT 	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)

IS
     --Define Your Local Variables Here

       -- Global Semaphore for Non-Project Budget Integration
       l_bgt_intg_flag  VARCHAR2(1) :=NULL;


  BEGIN
--dbms_output.put_line('Client Extn VERIFY_BUDGET_RULES - Inside');

--
-- Initialize Local Variable for  Non-Project Budget Integration Global.
--
      l_bgt_intg_flag := PA_BUDGET_UTILS.G_Bgt_Intg_Flag;

--
-- Initialize OUT-parameters Here
--
	p_warnings_only_flag 	:= 'Y';
	p_err_msg_count		:= 0;
	p_error_code		:= 0;
--
-- Put The Rules That  You Want To Check For Here
--
-- Remember: p_event - SUBMIT for submission validation,
-- BASELINE for baseline validation.
--

--
-- NOTIFICATION Error/Warning Handling  --------------------------
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
-- To display an error or warning message in the workflow notification
-- or the Budgets form , you
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
-- You can also define your own tokens for the messages .You can supply
-- upto 5 tokens for the PA_UTILS.Add_Message procedure
-- ---------------------------------------------------------------------------------------

--
-- Make sure to update the OUT variable for the
-- message count
--

	p_err_msg_count	:= FND_MSG_PUB.Count_Msg;



 EXCEPTION
     WHEN OTHERS THEN
       -- Add your exception handler here.
       -- To raise an ORACLE error, assign SQLCODE to p_error_code
       NULL;
 END Verify_Budget_Rules;


-- =================================================
/*============================================================================
 Name:                Get_Custom_Layout_Code
 Type:                Procedure
 Description:         This API has been created for the Financial Planning
                      WebADI upload functionality. This is a Client Extension
                      provided to the customers to modify the layout code that
                      is selected by Default for the budget version. This can
                      be used by the users for viewing their Custom Layouts.
                      The details of the parameters are provided below.

 Calling subprograms: pa_fp_webadi_utils.get_metadata_info (Procedure used
                      to return the layout code based on the budget version id).

 IN:

 p_budget_version_id - Budget Version ID for which the layout code needs to be
                       determined.
 p_layout_code_in    - Layout code that is determined by the calling procedure
                       for the above budget version id.
 OUT

 x_layout_code_out   - The customized layout code that the user woule like to
                       view for the budget version id.
 x_return_status     - The returning status to be sent to the calling API.
 x_msg_count         - Count of warning and error messages if any.
 x_msg_data          - Error message data to be sent to the calling API.

 NOTE:
 By default, this Client Extension API will return the same input layout code
 to the calling API. The user can modify the code of this API to return the
 code of the Customized Layout.

 By using the commented code in the body of this procedure, you may
 add error and warning messages to the message stack.

 Moreover, error/warning processing in the calling procedure
 will only occur if OUT parameter x_return_status is not FND_API.G_RET_STS_SUCCESS
 or if we explicitly "RAISE" the exception in the exception portion of the api.
===============================================================================*/

PROCEDURE Get_Custom_Layout_Code
                   (
                    p_budget_version_id      IN   NUMBER
                    , p_layout_code_in       IN   VARCHAR2
                    , x_layout_code_out      OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                    , x_return_status        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                    , x_msg_count            OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
                    , x_msg_data             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                    )

IS
     /* Use the below variable to check if the PA debug mode is ON before printing
        the debug messages. */

        L_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

     /* Define any other local variables, here. */

BEGIN

 /* Initialize out parameters. */
      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      pa_debug.set_err_stack('PA_CLIENT_EXTN_BUDGET.Get_Custom_Layout_Code');

 /* Display Errors:
    To display an error or warning message use PA_UTILS.Add_Message.
    For example, a typical call might look like the following:

    -- PA_UTILS.Add_Message
    -- ( p_app_short_name  => 'PA'
    --  ,p_msg_name        => 'PA_INVALID_LAYOUT'
    -- );
    -- x_return_status := FND_API.G_RET_STS_ERROR;
    -- x_msg_count := FND_MSG_PUB.count_msg;

    You can define your own message (PA_INVALID_LAYOUT is just an example)
    and for the messages . Upto 5 tokens can be passed to the PA_UTILS.Add_Message procedure
 */

 /* To print debug messages, the following statements can be modified and
    used.

    --     IF l_pa_debug_mode = 'Y' THEN
    --        pa_debug.g_err_stage:= 'The Layout is invalid.';
    --        pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    --     END IF;

 */

 /* By default the out parameter x_layout_code_out is initialised to
    in parameter p_layout_code_in.
    The user can put in their processing logic and arrive at the out
    parameter x_layout_code_out.
 */

    x_layout_code_out :=  p_layout_code_in;

    /* Reset the error stack. */
    pa_debug.reset_err_stack;


 EXCEPTION
     WHEN OTHERS THEN
          NULL;
--   Following sample exception handling can be used to handle the exception.
--
--          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--          x_msg_count     := 1;
--          x_msg_data      := SQLERRM;
--          FND_MSG_PUB.add_exc_msg
--                          ( p_pkg_name        => 'PA_CLIENT_EXTN_BUDGET'
--                           ,p_procedure_name  => 'Get_Custom_Layout_Code'
--                           ,p_error_text      => sqlerrm);
--          IF l_pa_debug_mode = 'Y' THEN
--              pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
--              pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
--          END IF;
--          pa_debug.reset_err_stack;
--          RAISE;
 END Get_Custom_Layout_Code;

 -- created tpalaniv  For bug 3736220
 -- This API will stamp the customized errors defined by the Customer within this client extension
 -- in interface table, so that these client extension error messages will be displayed in Excel,
 -- when some validation done in client extension fails.
 -- Also Please Note that,
 -- 1. p_error_code is equivalent to lookup_code in pa_lookups table.
 -- 2. Only if this lookup_code is present in pa_lookups table, will the  customized client extension error
 --    message will be displayed


 PROCEDURE Stamp_Client_Extn_Errors
 (  p_resource_assignment_id IN NUMBER
  , p_error_code IN VARCHAR2
  , x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  , x_msg_count     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  , x_msg_data      OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS

 PRAGMA AUTONOMOUS_TRANSACTION;
 BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

 UPDATE  PA_FP_WEBADI_XFACE_TMP
	          SET   val_error_code = p_error_code,
                        val_error_flag = 'Y'
                  WHERE resource_assignment_id = p_resource_assignment_id
		AND
		  NOT EXISTS
		      (SELECT 'Y'
		       FROM   PA_FP_WEBADI_XFACE_TMP tmpchk
		       WHERE  tmpchk.val_error_code IS NOT NULL
		       AND    tmpchk.val_error_flag = 'Y'
	               AND    resource_assignment_id = p_resource_assignment_id);

 COMMIT;
 RETURN;
EXCEPTION
	WHEN OTHERS THEN
	NULL;
--   Following sample exception handling can be used to handle the exception.
--
--          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--          x_msg_count     := 1;
--          x_msg_data      := SQLERRM;
--          FND_MSG_PUB.add_exc_msg
--                          ( p_pkg_name        => 'PA_CLIENT_EXTN_BUDGET'
--                           ,p_procedure_name  => 'Get_Custom_Layout_Code'
--                           ,p_error_text      => sqlerrm);
--          RAISE;
 END Stamp_Client_Extn_Errors;

END pa_client_extn_budget;

/
