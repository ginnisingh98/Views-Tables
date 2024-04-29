--------------------------------------------------------
--  DDL for Package Body GMS_CLIENT_EXTN_BUDGET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_CLIENT_EXTN_BUDGET" AS
/* $Header: gmsbcecb.pls 120.1 2005/07/26 14:21:10 appldev ship $ */

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
                        x_raw_cost               in out NOCOPY number,
                        x_pm_product_code        in varchar2,
                        x_error_code             out NOCOPY number,
                        x_error_message          out NOCOPY varchar2)

 IS

     -- Define your local variables here

 BEGIN
 ---------------------------------------------------------------------
 -- IMPORTANT: This procedure is for future enhancements and it is
 --            NOT supported at this point in time.
 ---------------------------------------------------------------------
     -- Initialize the output parameters
     x_error_code := 0;
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
                           x_burdened_cost          in out NOCOPY number,
                           X_pm_product_code        in varchar2,
                           x_error_code             out NOCOPY number,
                           x_error_message          out NOCOPY varchar2)
 IS

     -- Define your local variables here

 BEGIN

 ---------------------------------------------------------------------
 -- IMPORTANT: This procedure is for future enhancements and it is
 --            NOT supported at this point in time.
 ---------------------------------------------------------------------
     -- Initialize the output parameters

     x_error_code := 0;

     -- Add your business rules to calculate burdened cost here

 EXCEPTION
     WHEN OTHERS THEN
       -- Add your exception handler here.
       -- To raise an ORACLE error, assign SQLCODE to x_error_code
       null;
 END Calc_Burdened_Cost;

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
--
-- NOTES:
--
-- IN
--   p_workflow_started_by_id	- identifies the user that initiated the workflow
--   p_event			- indicates whether procedure called for
--				  either a 'SUBMIT' or 'BASELINE'
--				  event.
--
-- OUT NOCOPY
--    p_warnings_only_flag		- RETURN 'Y' if ALL triggered edits are warnings. Otherwise,
--				   if there is at least one hard error, then RETURN 'N'.
--    p_err_msg_count		-  Count of warning and error messages.
--
--  By using the commented code in the body of this procedure, you may
--  add error and warning messages to the message stack.
--
--  Moreover, error/warning processing in the calling procedure
--  will only occur if OUT NOCOPY p_err_msg_count
--  parameter is greater than zero.
--

PROCEDURE Verify_Budget_Rules
 (p_draft_version_id		IN 	NUMBER
  , p_mark_as_original 		IN	VARCHAR2
  , p_event			IN	VARCHAR2
  , p_project_id       		IN 	NUMBER
  , p_budget_type_code  	IN	VARCHAR2
  , p_resource_list_id		IN	NUMBER
  , p_project_type_class_code	IN 	VARCHAR2
  , p_created_by 		IN	NUMBER
  , p_calling_module		IN	VARCHAR2
  , p_warnings_only_flag	OUT NOCOPY	VARCHAR2
  , p_err_msg_count		OUT NOCOPY	NUMBER
  , p_error_code             	OUT NOCOPY	NUMBER
  , p_error_message          	OUT NOCOPY 	VARCHAR2
)

IS
     --Define Your Local Variables Here


  BEGIN

 ---------------------------------------------------------------------
 -- IMPORTANT: This procedure is for future enhancements and it is
 --            NOT supported at this point in time.
 ---------------------------------------------------------------------

-- Initialize OUT-parameters Here
	p_warnings_only_flag 	:= 'Y';
	p_err_msg_count		:= 0;
	p_error_code		:= 0;
--
-- Put The Rules That  You Want To Check For Here
--
-- Make sure to update the OUT NOCOPY variable for the
-- message count

	p_err_msg_count	:= FND_MSG_PUB.Count_Msg;

 EXCEPTION
     WHEN OTHERS THEN
       -- Add your exception handler here.
       -- To raise an ORACLE error, assign SQLCODE to x_error_code
       NULL;
 END Verify_Budget_Rules;

-- =================================================
--Name:		OVERRIDE_INST_DATE_VALIDATION
--Type:		Procedure
--Purpose:      This procedure can be customized at site to achieve the following:
--                 1. By default, Award budget  validation will not allow budgeting outside of installment dates.
--                    This procedure can be customized to override this functionality.
--
--		   2. By default, budget validation checks budget line amount against available funds in the
--                    order of budget period. This default functionality can be overriden to check the funds availability
--                    in the ascending order of budget line amounts so that negative amounts are compared first.
--              Customizing this procedure to return 'Y'  will achieve the above two objectives. This client extension
--              is designed to accomodate the override the functionality selectively at award budget level.
--
--Called subprograms: none.
--
--History:
--
-- NOTES:
--
-- IN
--   p_award_id   	- identifies the award_id whose Budget-Installment validation to override.
--   p_project_id	- identifies the project_id whose Budget-Installment validation to override.
--
-- OUT NOCOPY
--   p_override_validation  - RETURN 'Y' to override validation or 'N' not to override validation
--
-- =================================================

PROCEDURE override_inst_date_validation
 ( p_award_id                   IN      NUMBER,
   p_project_id                 IN      NUMBER,
   p_override_validation	OUT NOCOPY 	VARCHAR2)
IS

 begin

	p_override_validation := 'N';

	-- Add your business rules to override the Installment-Budget validation here.
	-- Assigning 'Y' to p_override_validation will override the default budget validations
        -- described in the purpose section above.

 exception
 when OTHERS then
       -- Add your appropriate  exception handler here.
	 NULL;
 end;

END gms_client_extn_budget;

/
