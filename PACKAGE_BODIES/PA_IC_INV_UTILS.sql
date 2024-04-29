--------------------------------------------------------
--  DDL for Package Body PA_IC_INV_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_IC_INV_UTILS" AS
/* $Header: PAICUTLB.pls 120.3.12010000.3 2008/09/25 11:28:02 nkapling ship $ */
-- Package specification for utilities to be used in Intercompany
-- Invoice generation process
--
-- This procedure will initialize the global variables
-- Input paramaters
-- Parameter                Type       Required Description
-- P_LAST_UPDATE_LOGIN      NUMBER     Yes      Standard Who column
-- P_REQUEST_ID             NUMBER     Yes
-- P_PROGRAM_APPLICATION_ID NUMBER     Yes
-- P_PROGRAM_ID             NUMBER     Yes
-- P_LAST_UPDATED_BY        NUMBER     Yes
-- P_CREATED_BY             NUMBER     Yes
-- P_DEBUG_MODE             VARCHAR2   Yes      Debug mode
-- P_SOB                    NUMBER     Yes      Set of books id
-- P_ORG                    NUMBER     Yes      Org Id
-- P_FUNC_CURR              VARCHAR2   Yes      Functional currency code
--
--
g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE Init (
        P_LAST_UPDATE_LOGIN      NUMBER,
        P_REQUEST_ID             NUMBER,
        P_PROGRAM_APPLICATION_ID NUMBER,
        P_PROGRAM_ID             NUMBER,
        P_LAST_UPDATED_BY        NUMBER,
        P_CREATED_BY             NUMBER,
        P_DEBUG_MODE             VARCHAR2,
        P_SOB                    NUMBER,
        P_ORG                    NUMBER,
        P_FUNC_CURR              VARCHAR2
) IS


/* R12 :  Ledger Architecture Changes : The table gl_mc_reporting_options will  obsoleted, replace with
   new table gl_alc_ledger_rships_v and corresponding columns
   Also remove the date validation, If we add application id and relationship_enabled_flag check then no need to
   check the date. */

  /* cursor c_reporting_sob(p_sob_id in number,p_org_id in number) is
         select reporting_set_of_books_id ,
                reporting_currency_code
           from gl_mc_reporting_options
           where primary_set_of_books_id = p_sob_id
            and org_id = p_org_id
            and application_id = 275
            and nvl(enabled_flag,'N')='Y'
            and TRUNC(sysdate) between
                TRUNC(start_date) and TRUNC(nvl(end_date,sysdate)); */    /* BUG# 3118592 */


         cursor c_reporting_sob(p_sob_id in number,p_org_id in number) is
         select ledger_id  reporting_set_of_books_id ,
                currency_code reporting_currency_code
           from gl_alc_ledger_rships_v
          where source_ledger_id  = p_sob_id
            and (org_id = -99 OR org_id = p_org_id)
            and application_id = 275
            and relationship_enabled_flag ='Y';


  I     integer ;

BEGIN
G_LAST_UPDATE_LOGIN := P_LAST_UPDATE_LOGIN;
G_REQUEST_ID := P_REQUEST_ID;
G_PROGRAM_APPLICATION_ID := P_PROGRAM_APPLICATION_ID;
G_PROGRAM_ID := P_PROGRAM_ID;
G_LAST_UPDATED_BY := P_LAST_UPDATED_BY;
G_CREATED_BY := P_CREATED_BY;
G_DEBUG_MODE := P_DEBUG_MODE;

pa_debug.init_err_stack ('Intercompany Invoice');
pa_debug.set_process(
            x_process => 'PLSQL',
            x_debug_mode => p_debug_mode);

pa_debug.G_Err_Stage := 'Initializing IC Invoice';

IF g1_debug_mode  = 'Y' THEN
	pa_ic_inv_utils.log_message('Init: ' || pa_debug.G_Err_Stage);
END IF;

-- Initialize global variables for MRC

PA_MC_INVOICE_DETAIL_PKG.G_FUNC_CURR := P_FUNC_CURR;
PA_MC_INVOICE_DETAIL_PKG.G_SOB       := P_SOB;
PA_MC_INVOICE_DETAIL_PKG.G_ORG_ID    := P_ORG;

I := 1;

PA_MC_INVOICE_DETAIL_PKG.G_No_of_SOB := I - 1;

END Init;
-- This procedure will return the next draft invoice number to be used
-- for creating a new invoice header.
--
-- Input parameters
-- Parameter       Type       Required Description
-- P_PROJECT_ID   NUMBER      Yes      Identifier of the Project
-- P_REQUEST_ID   NUMBER      Yes      The current request id
--
-- Output Parameters
-- Parameter         Type   Description
-- X_NEW_INVOICE_NUM NUMBER Invoice number to be used for the new Invoice
--
PROCEDURE  Get_Next_Draft_Inv_Num
           ( P_project_id      IN  NUMBER,
	     P_request_id      IN  NUMBER,
             X_new_invoice_num OUT NOCOPY NUMBER) IS --File.Sql.39 bug 4440895

CURSOR C_NEW_INVOICE_NUM IS
SELECT  nvl(MAX(draft_invoice_num),0) + 1
FROM    pa_draft_invoices DI
WHERE   DI.project_id = P_project_id;

CURSOR C_ERR_INVOICE_NUM IS
SELECT  DI.draft_invoice_num
FROM    pa_draft_invoices DI
WHERE   DI.Project_ID = P_project_id
AND     DI.draft_invoice_num
        =
        ( select min(draft_invoice_num)
            from pa_draft_invoices
           where project_id = P_project_id
           AND     request_id = P_request_id
           AND     generation_error_flag = 'Y'
        );

l_new_invoice_num  number;
l_err_invoice_num  number;
l_user_id	   number;

BEGIN
/* Get the next draft invoice number for the provider project
* This procedure will return the next draft invoice number to be used for
  creating a new invoice header.
* In case multiple invoices are generated as maybe in case of bill by
  project option the invoices with generation error should have the
  highest number.
* In order to ensure this when the new maximum invoice number is generated
  the procedure should check if any Invoices are created with generation error
  for the project and in the current request .
  If multiple error invoices exist  then pick up the one with the minimum number ,
  this invoice should be renumbered with the new invoice number.
* All the associated invoice lines and invoice details should also be
  renumbered.
* Distribution warnings if any should also be renumbered.
* Finally the procedure will return the old invoice number of the
  error invoice to be used by the new Invoice.
*/

-- Get the highest invoice number for the project

   pa_debug.g_err_stage := ' In Get_Next_Draft_Inv_Num ';
   IF g1_debug_mode  = 'Y' THEN
   	pa_ic_inv_utils.log_message('Get_Next_Draft_Inv_Num: ' || pa_debug.g_err_stage);
   	pa_ic_inv_utils.log_message('Get_Next_Draft_Inv_Num: ' || 'opening cursor c_new_invoice_num');
   END IF;

   Open c_new_invoice_num;

   Fetch c_new_invoice_num into l_new_invoice_num;

   IF g1_debug_mode  = 'Y' THEN
   	pa_ic_inv_utils.log_message('Get_Next_Draft_Inv_Num: ' || 'new_invoice_num = '||l_new_invoice_num);
   END IF;

   Close c_new_invoice_num;


-- Check if other invoices with generation error have been created in the
-- current request
-- If exists then renumber the error invoice  with the new invoice number
-- and return the error invoice number
-- else
-- return the highest invoice number for the project
--

    l_user_id := pa_ic_inv_utils.g_last_update_login;

    Open c_err_invoice_num;

    Fetch c_err_invoice_num into l_err_invoice_num;


    IF c_err_invoice_num%FOUND THEN

    IF g1_debug_mode  = 'Y' THEN
    	pa_ic_inv_utils.log_message('Get_Next_Draft_Inv_Num: ' || 'error invoice_num = '||l_err_invoice_num);
    END IF;

	  Update pa_draft_invoices
             set draft_invoice_num = l_new_invoice_num,
		 last_update_date  = SYSDATE,
		 last_update_login = l_user_id
	   where project_id = P_Project_Id
	     and draft_invoice_num = l_err_invoice_num;

	  Update pa_draft_invoice_items
             set draft_invoice_num = l_new_invoice_num,
		 last_update_date  = SYSDATE,
		 last_update_login = l_user_id
	   where project_id = P_Project_Id
	     and draft_invoice_num = l_err_invoice_num;

	  Update pa_draft_invoice_details
             set draft_invoice_num = l_new_invoice_num,
		 last_update_date  = SYSDATE,
		 last_update_login = l_user_id
	   where project_id = P_Project_Id
	     and draft_invoice_num = l_err_invoice_num;

	  Update pa_distribution_warnings
             set draft_invoice_num = l_new_invoice_num,
		 last_update_date  = SYSDATE,
		 last_update_login = l_user_id
	   where project_id = P_Project_Id
	     and draft_invoice_num = l_err_invoice_num;

          X_NEW_INVOICE_NUM := l_err_invoice_num;

    ELSE

          X_NEW_INVOICE_NUM := l_new_invoice_num;

    END IF;

    Close c_err_invoice_num; /* bug 3865056 */

    IF g1_debug_mode  = 'Y' THEN
    	pa_ic_inv_utils.log_message('Get_Next_Draft_Inv_Num: ' || 'new invoice_num = '||l_new_invoice_num);
    END IF;

EXCEPTION
    when OTHERS then
    IF c_err_invoice_num%ISOPEN THEN
       close c_err_invoice_num;
    END IF;
    /* ATG Changes */
     X_new_invoice_num := null;

         raise;

END Get_Next_Draft_Inv_Num;
-- This procedure will commit the invoice transaction
--
-- There are no parameters to this procedure
--
PROCEDURE  Commit_Invoice AS
BEGIN
      COMMIT;
END Commit_Invoice;

--  This procedure will update the summary project fundings with
--  the invoiced amounts
--
-- Input parameters
-- Parameter           Type       Required Description
-- P_DRAFT_INVOICE_NUM NUMBER      Yes      The draft invoice number
-- P_AGREEMENT_ID      NUMBER      Yes      Identifier of the Agreement
-- P_PROJECT_ID        NUMBER      Yes      Identifier of the Project
--

PROCEDURE  Update_SPF
	   ( P_DRAFT_INVOICE_NUM IN NUMBER ,
	     P_AGREEMENT_ID      IN NUMBER,
             P_PROJECT_ID        IN NUMBER,
             P_INVOICE_MODE      IN VARCHAR2) AS

   l_total_billed_amount  NUMBER := 0;

   l_request_id  number ;
   l_program_application_id number;
   l_program_id  number;
   l_user_id     number;

BEGIN
    l_user_id := pa_ic_inv_utils.g_last_update_login;
    l_program_id := pa_ic_inv_utils.g_program_id;
    l_program_application_id := pa_ic_inv_utils.g_program_application_id;
    l_request_id := pa_ic_inv_utils.g_request_id;

   pa_debug.g_err_stage := ' In Update_SPF ';
   IF g1_debug_mode  = 'Y' THEN
   	pa_ic_inv_utils.log_message('Update_SPF: ' || pa_debug.g_err_stage);
   END IF;

    SELECT SUM(amount)
    INTO   l_total_billed_amount
    FROM   pa_draft_invoice_items
    WHERE  draft_invoice_num = p_draft_invoice_num
    AND    project_id = p_project_id ;

    Update pa_summary_project_fundings
       set total_accrued_amount = NVL(total_accrued_amount,0) +
    decode(P_INVOICE_MODE,'DELETE',(-1)*l_total_billed_amount,
                                    l_total_billed_amount),
           total_billed_amount = NVL(total_billed_amount,0) +
    decode(P_INVOICE_MODE,'DELETE',(-1)*l_total_billed_amount,
                                    l_total_billed_amount),
           last_update_date = SYSDATE,
	   last_update_login = l_user_id,
	   request_id        = l_request_id,
           program_application_id = l_program_application_id,
	   program_id        = l_program_id
      where project_id = P_project_id
	and agreement_id = P_agreement_id;

   IF g1_debug_mode  = 'Y' THEN
        pa_ic_inv_utils.log_message ('Updated SPF rows = '||SQL%rowcount);
   	pa_ic_inv_utils.log_message ('Update_SPF: ' || 'Updating SPF with amount =  ' ||
                                    l_total_billed_amount);
   END IF;


EXCEPTION
      when OTHERS then
           raise;
END Update_SPF;

--
-- This procedure will mark the generation error on the draft invoice
-- and insert the distribution warnings
--
-- Input parameters
-- Parameter           Type       Required Description
-- P_DRAFT_INVOICE_NUM NUMBER      Yes      The draft invoice number
-- P_REJN_LOOKUP_TYPE  VARCHAR     Yes      The lookup type to be used to
--				            get the rejection reason
-- P_REJN_LOOKUP_CODE  VARCHAR     Yes      The lookup type to be used to
-- P_PROJECT_ID        NUMBER      Yes      Identifier of the Project
--				            get the rejection code

PROCEDURE Mark_Inv_Error
	   ( P_DRAFT_INVOICE_NUM   IN  NUMBER,
	     P_REJN_LOOKUP_TYPE    IN  VARCHAR,
	     P_REJN_LOOKUP_CODE    IN  VARCHAR,
	     P_PROJECT_ID	   IN  NUMBER) AS

   l_request_id  number ;
   l_program_application_id number;
   l_program_id  number;
   l_user_id     number;
   l_cnt	 number:=0; /* Added for bug 7034356*/
   l_rejection_reason varchar2(80);

BEGIN

    l_user_id := pa_ic_inv_utils.g_last_update_login;
    l_program_id := pa_ic_inv_utils.g_program_id;
    l_program_application_id := pa_ic_inv_utils.g_program_application_id;
    l_request_id := pa_ic_inv_utils.g_request_id;

/* Fix for bug 7034356 starts here */
	IF (P_REJN_LOOKUP_CODE = 'NO_INV_LINES') THEN
		SELECT	COUNT(*)
		INTO	l_cnt
		FROM	pa_distribution_warnings
		WHERE	project_id = p_project_id
		AND	draft_invoice_num = P_DRAFT_INVOICE_NUM;
	END IF;

	IF (P_REJN_LOOKUP_CODE = 'NO_INV_LINES' and l_cnt = 0 ) THEN
		pa_ic_inv_utils.log_message('Deleting invoice');
		/*pa_ic_inv_del.delete_invoices(p_project_id);*/
		/*Fix for Bug 	7433201*/
		delete pa_draft_invoices_all
		where project_id = p_project_id
		AND	draft_invoice_num = P_DRAFT_INVOICE_NUM;
		/*End of fix for Bug 	7433201*/
		pa_ic_inv_utils.log_message('Done Deleting invoice');
	ELSE
	/* Fix for bug 7034356 ends here */
		   pa_debug.g_err_stage := ' In Mark Inv Error ';
		   IF g1_debug_mode  = 'Y' THEN
			pa_ic_inv_utils.log_message('Mark_Inv_Error: ' || pa_debug.g_err_stage);
		   END IF;

		     begin
		     select meaning
		     into l_rejection_reason
		     from pa_lookups
		     where lookup_type = P_REJN_LOOKUP_TYPE
		     and lookup_code = P_REJN_LOOKUP_CODE;

		     exception
		     when NO_DATA_FOUND then
			  l_rejection_reason := P_REJN_LOOKUP_TYPE ||'-'|| P_REJN_LOOKUP_CODE;
		     when OTHERS then
			  raise;
		     end;

		     Update pa_draft_invoices
		       set generation_error_flag = 'Y',
			  last_update_date = SYSDATE,
			  last_update_login = l_user_id,
			  request_id        = l_request_id,
			  transfer_rejection_reason = l_rejection_reason
		     where project_id = P_PROJECT_ID
		     and draft_invoice_num = P_DRAFT_INVOICE_NUM;

		   IF g1_debug_mode  = 'Y' THEN
		     pa_ic_inv_utils.log_message('Rows updated in DI = '||SQL%rowcount);
		    END IF;

		     INSERT INTO PA_DISTRIBUTION_WARNINGS
		     (
			DRAFT_INVOICE_NUM, PROJECT_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,
			CREATION_DATE, CREATED_BY, REQUEST_ID, PROGRAM_APPLICATION_ID,
			PROGRAM_ID, PROGRAM_UPDATE_DATE, WARNING_MESSAGE
		     )
		     VALUES
			(
			 P_draft_invoice_num, P_project_id, SYSDATE, l_user_id,
			 SYSDATE, l_user_id, l_request_id, l_program_application_id,
			 l_program_id, SYSDATE, l_rejection_reason
			);

		   IF g1_debug_mode  = 'Y' THEN
		     pa_ic_inv_utils.log_message('Rows Inserted in pa_distribution_warnings = '||SQL%rowcount);
		      pa_debug.g_err_stage := ' Done Mark Inv Error ';
			pa_ic_inv_utils.log_message('Mark_Inv_Error: ' || pa_debug.g_err_stage);
		   END IF;
	END IF;		  	/* Added for bug 7034356*/
EXCEPTION
        when OTHERS then
	     raise;
END Mark_Inv_Error;
--
-- This procedure will mark the expenditure items billed on an invoice as
-- billed.
--
-- Input parameters
-- Parameter           Type       Required Description
-- P_DRAFT_INVOICE_NUM NUMBER      Yes      The draft invoice number
-- P_REQUEST_ID	       NUMBER	   Yes	    The current request id
-- P_PROJECT_ID        NUMBER      Yes      Identifier of the Project
--
PROCEDURE Mark_EI_as_Billed
	   ( P_DRAFT_INVOICE_NUM IN NUMBER ,
	     P_REQUEST_ID	 IN NUMBER ,
             P_PROJECT_ID        IN NUMBER) AS

   l_request_id  number ;
   l_program_application_id number;
   l_program_id  number;
   l_user_id     number;

   CURSOR c_inv_detail IS
   select  expenditure_item_id expenditure_item_id,
           denom_currency_code denom_tp_currency_code,
           denom_bill_amount   denom_transfer_price,
	   acct_rate_type      acct_tp_rate_type,
	   acct_rate_date      acct_tp_rate_date,
	   acct_exchange_rate  acct_tp_exchange_rate,
	   bill_amount         acct_transfer_price,
           markup_calc_base_code cc_markup_base_code,
	   base_amount         tp_base_amount,
           ind_compiled_set_id tp_ind_compiled_set_id,
           bill_rate           tp_bill_rate,
           bill_markup_percentage tp_bill_markup_percentage,
	   schedule_line_percentage tp_schedule_line_percentage
     from  pa_draft_invoice_details did
     where did.project_id = P_PROJECT_ID
       and did.request_id = P_REQUEST_ID
       and did.draft_invoice_num = P_DRAFT_INVOICE_NUM
       and did.line_num = ( select max(did1.line_num)
                              from pa_draft_invoice_details did1
			      where did1.expenditure_item_id =
                                      did.expenditure_item_id)
   ;

   /*Code Changes for Bug No.2984871 start */
    l_rowcount number :=0;
   /*Code Changes for Bug No.2984871 end */

BEGIN
    l_user_id := pa_ic_inv_utils.g_last_update_login;
    l_program_id := pa_ic_inv_utils.g_program_id;
    l_program_application_id := pa_ic_inv_utils.g_program_application_id;
    l_request_id := pa_ic_inv_utils.g_request_id;

   pa_debug.g_err_stage := ' In mark_ei_as_billed ';
   IF g1_debug_mode  = 'Y' THEN
   	pa_ic_inv_utils.log_message('Mark_EI_as_Billed: ' || pa_debug.g_err_stage);
   END IF;

    FOR c_rec in c_inv_detail
    loop
--  Changed the update for the new ei locking strategy
--  update only if intermediate value of ei.cc_ic_processed_code = 'B' ,
--  i.e. succesfully billed
--
    Update pa_expenditure_items_all ei
       set ei.cc_ic_processed_code = decode(ei.cc_cross_charge_code,'I','Y','X')
          ,ei.last_update_date = SYSDATE
          ,ei.last_update_login = l_user_id
          ,ei.request_id        = l_request_id
    where ei.expenditure_item_id = c_rec.expenditure_item_id
      and ei.cc_ic_processed_code = 'B';

	/*Code Changes for Bug No.2984871 start */
		l_rowcount:=sql%rowcount;
	/*Code Changes for Bug No.2984871 end */

    IF g1_debug_mode  = 'Y' THEN
    	 pa_ic_inv_utils.log_message('Mark_EI_as_Billed: ' || 'Updating EI = '||c_rec.expenditure_item_id);

	/* Commented for Bug 2984871
	 pa_ic_inv_utils.log_message('Updated rows = '||SQL%rowcount);*/

	/*Code Changes for Bug No.2984871 start */
		 pa_ic_inv_utils.log_message('Updated rows = '||l_rowcount);
	/*Code Changes for Bug No.2984871 end */
    END IF;
    end loop;

    IF g1_debug_mode  = 'Y' THEN
    	pa_ic_inv_utils.log_message('Mark_EI_as_Billed: ' || 'Done Updating EI as billed');
    END IF;

EXCEPTION
    when OTHERS then
         raise;
END Mark_EI_as_Billed;
--
-- This function will set and acquire the user lock
--
-- Input parameters
-- Parameter           Type       Required Description
-- P_PROJECT_ID        NUMBER      Yes      Identifier of the Project
--
-- Return Values
--  0         Success
-- Other      Unable to acquire lock
--
--
FUNCTION Set_User_Lock
	   (P_PROJECT_ID   IN  NUMBER) RETURN NUMBER IS
     lock_status   number;
     lock_name     VARCHAR2(50);
BEGIN
lock_name   := 'IC-'||P_PROJECT_ID;

lock_status := pa_debug.acquire_user_lock(lock_name,6,FALSE,0);

return(lock_status);

END  Set_User_Lock;
--
-- This procedure will release user lock
--
-- Input parameters
-- Parameter           Type       Required Description
-- P_PROJECT_ID        NUMBER      Yes      Identifier of the Project
--
-- Return Values
--  0         Success
-- Other      Unable to acquire lock
--
FUNCTION Release_User_Lock
	   (P_PROJECT_ID   IN  NUMBER) RETURN NUMBER IS
     lock_status   number;
     lock_name     VARCHAR2(50);
BEGIN
lock_name   := 'IC-'||P_PROJECT_ID;

lock_status := pa_debug.release_user_lock(lock_name);

return(lock_status);
END Release_User_Lock;
--
-- This Function will return 'Y' if unreleased invoices exist for a project
--
-- Input parameters
-- Parameter           Type       Required Description
-- P_BILL_BY_PROJECT   VARCHAR    Yes      The draft invoice number
-- P_PROJECT_ID        NUMBER      Yes      Identifier of the Project
--
FUNCTION CHECK_IF_UNRELEASED_INVOICE
	  ( P_BILL_BY_PROJECT     IN  VARCHAR ,
	    P_PROJECT_ID	  IN  NUMBER) RETURN VARCHAR AS

/***
Function will return 'Y' if unreleased invoices exist for a project
***/


CURSOR C_UNREL_INV_BY_PROJECT IS
 SELECT 'x'
 FROM  PA_DRAFT_INVOICE_DETAILS DID
 WHERE DID.PROJECT_ID = P_PROJECT_ID
 AND DID.INVOICED_FLAG = 'N'
 AND NOT EXISTS
     ( SELECT 'X'
       FROM  PA_DRAFT_INVOICES DI
       WHERE DI.PROJECT_ID = P_PROJECT_ID
       AND  DI.RELEASED_BY_PERSON_ID IS NULL
       AND  DI.CC_PROJECT_ID = DID.CC_PROJECT_ID )
      ;

CURSOR C_UNREL_INV IS
SELECT 'X'
FROM  PA_DRAFT_INVOICES DI
WHERE DI.PROJECT_ID = P_PROJECT_ID
     AND  DI.RELEASED_BY_PERSON_ID IS NULL
     ;

l_temp    VARCHAR2(1);

BEGIN

/* If bill by project option is set then
*  Identify  cross charged project with uninvoiced details
*  For each cross charged project check if unreleased invoice exists ,
   if no unreleased invoice exists for a cross charge project then
   the intercompany billing project needs to be picked up.
*/

if p_bill_by_project = 'P' then

     open c_unrel_inv_by_project ;

     fetch c_unrel_inv_by_project into l_temp;

     if c_unrel_inv_by_project%notfound then
        close c_unrel_inv_by_project ;   /* bug 3865056 */
                  RETURN ('N');
     end if;

     close c_unrel_inv_by_project ;    /* bug 3865056 */
else

-- Else check if unreleased invoice exists for the provider project.

       open c_unrel_inv;

       fetch c_unrel_inv into l_temp;

       if c_unrel_inv%FOUND then
         close c_unrel_inv;  /* bug 3865056 */
         RETURN ('Y') ;
       end if;

       close c_unrel_inv;  /* bug 3865056 */

end if;

 RETURN('N');

exception
    when others then
         raise;
end check_if_unreleased_invoice ;
--
-- This procedure will update the draft invoice to trigger MRC
--
-- Input parameters
-- Parameter           Type       Required Description
-- P_DRAFT_INVOICE_NUM NUMBER      Yes      The draft invoice number
-- P_REQUEST_ID	       NUMBER	   Yes	    The current request id
-- P_PROJECT_ID        NUMBER      Yes      Identifier of the Project
--
PROCEDURE Update_DI_for_MRC
	   ( P_DRAFT_INVOICE_NUM IN NUMBER ,
	     P_REQUEST_ID	 IN NUMBER ,
             P_PROJECT_ID        IN NUMBER) AS
begin

-- Update pa_draft_invoices with creation date so that the
-- trigger on this table is fired and creates MRC rows
   pa_debug.g_err_stage := ' In Update_DI_for_MRC ';
   IF g1_debug_mode  = 'Y' THEN
   	pa_ic_inv_utils.log_message('Update_DI_for_MRC: ' || pa_debug.g_err_stage);
   END IF;

    update pa_draft_invoices
       set creation_date = creation_date
       where project_id = P_PROJECT_ID
         and request_id = P_request_id
         and draft_invoice_num = P_draft_invoice_num;

    IF g1_debug_mode  = 'Y' THEN
        pa_ic_inv_utils.log_message('Rows Updated = '||SQL%rowcount);
    	pa_ic_inv_utils.log_message('Done Update_DI_for_MRC');
    END IF;

end Update_DI_for_MRC;

--
-- This procedure brings credit hold from site level profile
--
FUNCTION get_credit_hold ( P_SITE_USE_ID       IN  NUMBER)
RETURN   VARCHAR2
IS
  L_CREDIT_HOLD     VARCHAR2(2);
BEGIN
  SELECT CREDIT_HOLD
  INTO   L_CREDIT_HOLD
/*  FROM   AR_CUSTOMER_PROFILES  Commented for TCA changes */
  FROM   HZ_CUSTOMER_PROFILES
  WHERE  SITE_USE_ID   = P_SITE_USE_ID ;

  return(L_CREDIT_HOLD);
EXCEPTION
  WHEN NO_DATA_FOUND
  THEN
       RETURN(NULL);
END get_credit_hold;

-- This procedure returns active site id
--
PROCEDURE get_active_site_id ( P_ADDRESS_ID    IN NUMBER,
                               P_SITE_USE_CODE IN VARCHAR2,
                               P_SITE_USE_ID  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                               P_SITE_STATUS  OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
BEGIN
 SELECT STATUS,
        SITE_USE_ID
 INTO   P_SITE_STATUS,
        P_SITE_USE_ID
/*  FROM   RA_SITE_USES  Commented for TCA changes. */
 FROM  HZ_CUST_SITE_USES
 WHERE  CUST_ACCT_SITE_ID     = P_ADDRESS_ID   /* The column address_id has been replaced with CUST_ACCT_SITE_ID for tca change */
 AND    SITE_USE_CODE         = P_SITE_USE_CODE
 AND    STATUS                = 'A';

EXCEPTION
 WHEN NO_DATA_FOUND
 THEN
      P_SITE_STATUS := 'I';
      P_SITE_USE_ID := -99;
END get_active_site_id;


-- This procedure will return active bill_to_site_use_id and
-- ship_to_site_id
-- Input parameters
-- Parameter               Type       Required
-- P_BILL_TO_ADDRESS_ID    NUMBER      Yes
-- P_SHIP_TO_ADDRESS_ID    NUMBER      Yes
-- X_BILL_TO_SITE_USE_ID   NUMBER
-- X_SHIP_TO_SITE_USE_ID   NUMBER
-- X_BILL_TO_SITE_STATUS   VARCHAR2
-- X_SHIP_TO_SITE_STATUS   VARCHAR2
--
PROCEDURE Get_active_sites
           ( P_BILL_TO_ADDRESS_ID         IN PA_PLSQL_DATATYPES.IdTabTyp ,
             P_SHIP_TO_ADDRESS_ID         IN PA_PLSQL_DATATYPES.IdTabTyp ,
             P_NO_OF_RECORDS              IN NUMBER,
             P_CUST_CREDIT_HOLD       IN OUT NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp, --File.Sql.39 bug 4440895
             X_BILL_TO_SITE_USE_ID       OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp, --File.Sql.39 bug 4440895
             X_SHIP_TO_SITE_USE_ID       OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp, --File.Sql.39 bug 4440895
             X_BILL_TO_SITE_STATUS       OUT NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp, --File.Sql.39 bug 4440895
             X_SHIP_TO_SITE_STATUS       OUT NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp) --File.Sql.39 bug 4440895
IS
   I        number;
BEGIN

 FOR I in 1..P_NO_OF_RECORDS
 LOOP
   /* Get active Bill sites */
   get_active_site_id ( P_ADDRESS_ID              => P_BILL_TO_ADDRESS_ID(I),
                        P_SITE_USE_CODE           => 'BILL_TO',
                        P_SITE_USE_ID             => X_BILL_TO_SITE_USE_ID(I),
                        P_SITE_STATUS             => X_BILL_TO_SITE_STATUS(I) );

   /* Get active ship sites */
   get_active_site_id ( P_ADDRESS_ID              => P_SHIP_TO_ADDRESS_ID(I),
                        P_SITE_USE_CODE           => 'SHIP_TO',
                        P_SITE_USE_ID             => X_SHIP_TO_SITE_USE_ID(I),
                        P_SITE_STATUS             => X_SHIP_TO_SITE_STATUS(I) );

   /* Set Credit Hold for the customer */
  /* Changed the P_BILL_TO_ADDRESS_ID(I) to X_BILL_TO_SITE_USE_ID(I)
     in the following call of get_credit_hold for bug 2653488 */
   P_CUST_CREDIT_HOLD(I) := nvl(get_credit_hold(X_BILL_TO_SITE_USE_ID(I)),
                                                  P_CUST_CREDIT_HOLD(I));

 END LOOP;

END Get_active_sites;

PROCEDURE log_message (p_log_msg IN VARCHAR2) IS
BEGIN
pa_debug.write_file ('LOG',to_char(sysdate, 'DD-MON-YYYY HH:MI:SS ')||p_log_msg);
NULL;
END log_message;

end PA_IC_INV_UTILS;

/
