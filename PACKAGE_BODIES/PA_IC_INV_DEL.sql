--------------------------------------------------------
--  DDL for Package Body PA_IC_INV_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_IC_INV_DEL" as
/* $Header: PAICDELB.pls 120.2.12010000.7 2010/01/15 00:43:47 apaul ship $ */
--
-- This procedure will delete the unreleased and error draft invoices
-- for a project
-- Input parameters
-- Parameter           Type       Required Description
-- P_PROJECT_ID        NUMBER      Yes      Identifier of the Project
--
g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE delete_invoices
	     (P_PROJECT_ID   IN  NUMBER,
	    p_mass_delete  in varchar2 DEFAULT 'N',
	    p_unapproved_inv_only IN varchar2 DEFAULT 'N') IS /*New variable added for bug 7026205*/
	     /*new parameter p_unapproved_inv_only for bug 7172117 */

/**
Delete the pending and unreleased Invoices for a project
* Select the pending / unreleased invoices for a project
* If the invoice is a canceled invoice or a credit memo
* then the invoice should be in error
**/

-- This procedure will delete the Invoice and its foreign key references

-- Cursor to select the unreleased draft invoices for a project

/*Added new select variable (DI.APPROVED_DATE) in the below cursor : bug 7172117 */

CURSOR C_DEL_UNAPPROVED_INV IS
        SELECT   DI.DRAFT_INVOICE_NUM,
                 DI.AGREEMENT_ID,
		 DI.APPROVED_DATE
        FROM     PA_DRAFT_INVOICES  DI
        WHERE    DI.PROJECT_ID = P_project_id
        AND      DI.RELEASED_BY_PERSON_ID IS NULL
        AND
          (
           nvl(DI.CANCEL_CREDIT_MEMO_FLAG, 'N') = 'N'
           or
           (
           nvl(DI.CANCEL_CREDIT_MEMO_FLAG, 'N') = 'Y'
           AND DI.generation_error_flag = 'Y'
           )
          )
        FOR UPDATE of DI.Draft_Invoice_Num
        ORDER BY DI.Draft_Invoice_Num  DESC;

l_draft_inv_num   number;
l_amount          number;
l_agreement_id    number;

l_request_id      number ;
l_program_application_id number;
l_program_id      number;
l_user_id         number;
l_inv_unapproved  date; /*Temp variable for bug 7172117 */


BEGIN

   IF g1_debug_mode  = 'Y' THEN
   	pa_ic_inv_utils.log_message(' Entering delete_invoices procedure ');
   END IF;

    l_user_id := pa_ic_inv_utils.g_last_update_login;
    l_program_id := pa_ic_inv_utils.g_program_id;
    l_program_application_id := pa_ic_inv_utils.g_program_application_id;
    l_request_id := pa_ic_inv_utils.g_request_id;

/**** logic is as follows

        OPEN C_DEL_UNAPPROVED_INV ;
         For each Draft_Invoice_num
         Loop
             Update summary project fundings reduce invoiced_amount by the
             deleting invoice amount;
             Delete from pa_distribution_warnings  ;
             Delete from pa_draft_invoice_items
             Delete from pa_draft_invoices
      // remove the reference to the Invoice from Invoice Details
         End Loop;
*****/

       open C_DEL_UNAPPROVED_INV;

       loop

        FETCH C_DEL_UNAPPROVED_INV
         into l_draft_inv_num,
              l_agreement_id,
	      l_inv_unapproved; /* Fetching the newly added parameter into new local variable. Bug 7172117 */

        IF C_DEL_UNAPPROVED_INV%NOTFOUND THEN
           EXIT;
        END IF;
/* Addedd for bug 7172117 */
   IF((p_unapproved_inv_only ='Y' and l_inv_unapproved is null) or (p_unapproved_inv_only = 'N')) then
        pa_ic_inv_utils.update_spf (l_draft_inv_num,
                                    l_agreement_id,
                                    p_project_id,
                                    'DELETE' );

        delete from pa_distribution_warnings
         where project_id = P_PROJECT_ID
           and draft_invoice_num = l_draft_inv_num;

   IF g1_debug_mode  = 'Y' THEN
   	pa_ic_inv_utils.log_message('pa_distribution_warnings rows deleted = ' || SQL%rowcount);
   	 END IF;

	   if p_mass_delete = 'Y' then  /*Added for bug 7026205*/
		insert_dist_warnings(p_project_id,
		                     l_draft_inv_num);
   END IF;

        delete from pa_draft_invoice_items
         where project_id = P_PROJECT_ID
           and draft_invoice_num = l_draft_inv_num;

   IF g1_debug_mode  = 'Y' THEN
     pa_ic_inv_utils.log_message('pa_draft_invoice_items rows deleted = ' || SQL%rowcount);
   END IF;

        delete from pa_draft_invoices
         where project_id = P_PROJECT_ID
           and draft_invoice_num = l_draft_inv_num;

   IF g1_debug_mode  = 'Y' THEN
       pa_ic_inv_utils.log_message('pa_draft_invoices rows deleted = ' || SQL%rowcount);
   END IF;

   /* Added denom transfer price and denom tp_currency code for bug 2638956 */
   /* Added acct_tp columns for bug 5276946 */
        Update pa_expenditure_items_all EI
           set cc_ic_processed_code = 'N',
	     denom_transfer_price   = NULL,
	     denom_tp_currency_code = NULL,
         /* Added following column updates to NULL to clear these columns when
            deleting the invoice for bug 6132313. acct_tp_rate_date = NULL added for bug 5276946*/
             acct_transfer_price = NULL,
             tp_base_amount = NULL,
	     tp_ind_compiled_set_id = NULL,
	     tp_bill_rate = NULL,
	     tp_bill_markup_percentage = NULL,
	     tp_schedule_line_percentage = NULL,
	     tp_rule_percentage = NULL,
	     tp_job_id = NULL,
             projfunc_transfer_price = NULL,
             project_transfer_price = NULL,
             projacct_transfer_price = NULL,
             Acct_tp_rate_type = NULL,
             Acct_tp_rate_date = NULL,
             Acct_tp_exchange_rate = NULL,
             project_tp_rate_type = NULL,
             project_tp_rate_date = NULL,
             project_tp_exchange_rate = NULL,
             projfunc_tp_rate_type = NULL,
             projfunc_tp_rate_date = NULL,
             projfunc_tp_exchange_rate = NULL
         where expenditure_item_id in
             ( select expenditure_item_id
                 from PA_DRAFT_INVOICE_DETAILS
                 Where Project_id = P_project_id
                 and Draft_Invoice_Num = L_draft_inv_num
             )
	   and (adjusted_expenditure_item_id is null /*Clause added for Bug 6899120*/
	        or (adjusted_expenditure_item_id is not null and
        /*	    adjusted_expenditure_item_id in
        ( select expenditure_item_id
                 from PA_DRAFT_INVOICE_DETAILS
                 Where Project_id = P_project_id
                 and Draft_Invoice_Num = L_draft_inv_num
                   )
		    )
             ); 9203389 */
                    expenditure_item_id in /* 9203389 */
               ( select PADI.expenditure_item_id
                 from PA_DRAFT_INVOICE_DETAILS PADI,
                      PA_DRAFT_INVOICE_DETAILS PADI2
                 Where PADI2.expenditure_item_id = EI.adjusted_expenditure_item_id
                 and   PADI.orig_draft_invoice_num = PADI2.draft_invoice_num
                 and   PADI2.project_id = P_project_id
                 and   PADI.project_id = P_project_id
                 and   PADI.draft_invoice_num = L_draft_inv_num
               )
                    )
             );

   IF g1_debug_mode  = 'Y' THEN
      pa_ic_inv_utils.log_message('pa_expenditure_items_all rows updated = ' || SQL%rowcount);
   END IF;


   /* Added following code to update related item when deleting invoice associated
   with the original transaction. Bug 6651747. */

        Update pa_expenditure_items_all
           set cc_ic_processed_code = 'N',
	     denom_transfer_price   = NULL,
	     denom_tp_currency_code = NULl,
             acct_transfer_price = NULL,
             tp_base_amount = NULL,
	     tp_ind_compiled_set_id = NULL,
	     tp_bill_rate = NULL,
	     tp_bill_markup_percentage = NULL,
	     tp_schedule_line_percentage = NULL,
	     tp_rule_percentage = NULL,
	     tp_job_id = NULL,
             projfunc_transfer_price = NULL,
             project_transfer_price = NULL,
             projacct_transfer_price = NULL,
             Acct_tp_rate_type = NULL,
             Acct_tp_rate_date = NULL,
             Acct_tp_exchange_rate = NULL,
             project_tp_rate_type = NULL,
             project_tp_rate_date = NULL,
             project_tp_exchange_rate = NULL,
             projfunc_tp_rate_type = NULL,
             projfunc_tp_rate_date = NULL,
             projfunc_tp_exchange_rate = NULL
         where source_expenditure_item_id in
             ( select expenditure_item_id
                 from PA_DRAFT_INVOICE_DETAILS
                 Where Project_id = P_project_id
                 and Draft_Invoice_Num = L_draft_inv_num
             );

   IF g1_debug_mode  = 'Y' THEN
      pa_ic_inv_utils.log_message('Related Items: pa_expenditure_items_all rows updated = ' || SQL%rowcount);
   END IF;

/*End of code changes for Bug 6651747 */

        Update  PA_DRAFT_INVOICE_DETAILS
           Set  draft_invoice_num = NULL,
                draft_invoice_line_num = NULL,
                last_update_date  = SYSDATE,
                last_update_login = l_user_id,
                request_id = l_request_id,
                Invoiced_Flag = 'N'
           Where Project_id = P_project_id
             and Draft_Invoice_Num = L_draft_inv_num;

   IF g1_debug_mode  = 'Y' THEN
      pa_ic_inv_utils.log_message('PA_DRAFT_INVOICE_DETAILS rows updated = ' || SQL%rowcount);
   END IF;

/* Commented for bug 1849569
        pa_ic_inv_utils.commit_invoice;*/
      end if;
       end loop;
/* Added for bug 1849569*/
        pa_ic_inv_utils.commit_invoice;
	close  C_DEL_UNAPPROVED_INV;
/* End for bug 1849569*/
   IF g1_debug_mode  = 'Y' THEN
   	pa_ic_inv_utils.log_message(' Leaving delete_invoices procedure ');
   END IF;

EXCEPTION
        when others then
             raise;

END delete_invoices;
/*New procedure added for bug 7026205*/

 PROCEDURE insert_dist_warnings
           (P_PROJECT_ID IN NUMBER,
	    P_DRAFT_INVOICE_NUM IN NUMBER)

 IS

  BEGIN

    INSERT INTO PA_DISTRIBUTION_WARNINGS
	(
	   PROJECT_ID,
	   DRAFT_INVOICE_NUM,
	   LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   CREATION_DATE,
	   CREATED_BY,
	   REQUEST_ID,
	   PROGRAM_APPLICATION_ID,
	   PROGRAM_ID,
	   PROGRAM_UPDATE_DATE,
	   AGREEMENT_ID,
	   WARNING_MESSAGE_CODE,
	   WARNING_MESSAGE
	)
	(
	   Select dia.project_id,
		  DRAFT_INVOICE_NUM,
		  sysdate,
		  PA_IC_INV_UTILS.G_LAST_UPDATED_BY,
		  sysdate,
		  PA_IC_INV_UTILS.G_CREATED_BY,
		  PA_IC_INV_UTILS.G_REQUEST_ID,
		  PA_IC_INV_UTILS.G_PROGRAM_APPLICATION_ID,
		  PA_IC_INV_UTILS.G_PROGRAM_ID,
		  dia.invoice_Date,
		  dia.agreement_id,
		  dia.INV_CURRENCY_CODE,
		  (SELECT SUM(INV_AMOUNT)
		   FROM PA_DRAFT_INVOICE_ITEMS
		   WHERE PROJECT_ID = P_PROJECT_ID
		   AND DRAFT_INVOICE_NUM = P_DRAFT_INVOICE_NUM)
	   FROM PA_DRAFT_INVOICES DIA
	   WHERE PROJECT_ID = P_PROJECT_ID
	   AND   DRAFT_INVOICE_NUM = P_DRAFT_INVOICE_NUM
	 );

EXCEPTION
        when others then
             raise;

END insert_dist_warnings;


end PA_IC_INV_DEL;

/
