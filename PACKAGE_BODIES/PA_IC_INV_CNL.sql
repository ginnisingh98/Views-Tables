--------------------------------------------------------
--  DDL for Package Body PA_IC_INV_CNL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_IC_INV_CNL" as
/* $Header: PAICCNLB.pls 120.5 2006/04/05 14:18:41 rmarcel noship $ */
--
-- This procedure will perform cancellation of a specified invoice
-- for a project
-- Input parameters
-- Parameter           Type       Required Description
-- P_PROJECT_ID        NUMBER      Yes      Identifier of the Project
-- P_DRAFT_INV_NUM     NUMBER      Yes      Identifier of the Invoice to be
--                                          Cancelled
--
g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE cancel_invoice
	   (P_PROJECT_ID   IN  NUMBER,
            P_DRAFT_INV_NUM IN NUMBER) IS

   l_request_id  number ;
   l_program_application_id number;
   l_program_id  number;
   l_user_id     number;

   l_new_draft_inv_num number;
   l_agreement_id      number;

   l_lock_status       number;
   l_EI_upd_cnt        number;

   l_draft_invoice_detail_id    PA_PLSQL_DATATYPES.IdTabTyp;
   l_new_draft_inv_detail_id    PA_PLSQL_DATATYPES.IdTabTyp;
   l_expenditure_item_id        PA_PLSQL_DATATYPES.IdTabTyp;
   l_EI_date                    PA_PLSQL_DATATYPES.Char30TabTyp;
   l_sys_linkage                PA_PLSQL_DATATYPES.Char30TabTyp; /*Bug 3857986 */
   l_DENOM_TP_CURRENCY_CODE     PA_PLSQL_DATATYPES.Char30TabTyp;
   l_DENOM_TRANSFER_PRICE       PA_PLSQL_DATATYPES.NumTabTyp;
   l_ACCT_TP_RATE_TYPE          PA_PLSQL_DATATYPES.Char30TabTyp;
   l_ACCT_TP_RATE_DATE          PA_PLSQL_DATATYPES.Char30TabTyp;
   l_ACCT_TP_EXCHANGE_RATE      PA_PLSQL_DATATYPES.NumTabTyp;
   l_ACCT_TRANSFER_PRICE        PA_PLSQL_DATATYPES.NumTabTyp;
   l_PROJACCT_TRANSFER_PRICE    PA_PLSQL_DATATYPES.NumTabTyp;
   l_CC_MARKUP_BASE_CODE        PA_PLSQL_DATATYPES.Char30TabTyp;
   l_TP_BASE_AMOUNT             PA_PLSQL_DATATYPES.NumTabTyp;
   l_TP_IND_COMPILED_SET_ID     PA_PLSQL_DATATYPES.IdTabTyp;
   l_TP_BILL_RATE               PA_PLSQL_DATATYPES.NumTabTyp;
   l_TP_BILL_MARKUP_PERCENTAGE  PA_PLSQL_DATATYPES.NumTabTyp;
   l_TP_SCHEDULE_LINE_PERCENTAGE PA_PLSQL_DATATYPES.NumTabTyp;
   l_TP_RULE_PERCENTAGE          PA_PLSQL_DATATYPES.NumTabTyp;

   l_inv_detail_rec  pa_draft_invoice_details%rowtype;


  /* Bug 5082249 : Performance Issue : FTS
         Fix : Added the project_id in the subquery */

   cursor c_invoice_detail (p_proj_id number,
                            p_inv_num number) is
   select *
   from   pa_draft_invoice_details did
   where  project_id = p_proj_id
     and  draft_invoice_num = p_inv_num
     and  not exists
          ( select 'x'
            from pa_draft_invoice_details did1
            where did1.project_id = p_proj_id
              and did1.detail_id_reversed = did.draft_invoice_detail_id) ;

   CANNOT_ACQUIRE_LOCK exception;
   INV_CANCELED_OR_CREDIT_MEMO exception;

BEGIN

    IF g1_debug_mode  = 'Y' THEN
    	pa_ic_inv_utils.log_message('Entered pa_ic_inv_cancel.cancel_invoice');
    	pa_ic_inv_utils.log_message('cancel_invoice: ' || 'Project Id :'||P_PROJECT_ID);
    	pa_ic_inv_utils.log_message('cancel_invoice: ' || 'Invoice Num :'||P_DRAFT_INV_NUM);
    END IF;

    l_user_id := pa_ic_inv_utils.g_last_update_login;
    l_program_id := pa_ic_inv_utils.g_program_id;
    l_program_application_id := pa_ic_inv_utils.g_program_application_id;
    l_request_id := pa_ic_inv_utils.g_request_id;

/*
 Obtain the User Lock with name as provider project _id ,
 this lock will solve the concurrency issues with similar
 Invoice generation process and other processes that  update invoice details.
*/

IF (pa_ic_inv_utils.Set_User_Lock (P_Project_Id) <> 0) THEN
   IF g1_debug_mode  = 'Y' THEN
   	pa_ic_inv_utils.log_message('cancel_invoice: ' || 'unable to acquire lock');
   END IF;
   raise CANNOT_ACQUIRE_LOCK;
END IF;

/*
  Mark the current Invoice as canceled and
  update the Invoice comment to indicate that Invoice is canceled
  provided it satisfies the following criteria
+ Invoice has not been canceled earlier
+ Credit memo has not been generated for the Invoice
*/

-- This update statement also returns the agreement_id
--
 Update pa_draft_invoices
 Set canceled_flag = 'Y',
     invoice_comment =
                     (select rtrim(upper(l.meaning)||' '||
                             rtrim(substrb(i.invoice_comment,1,232)))
                      from   pa_lookups l,
                             pa_draft_invoices i
                      where  i.project_id = p_project_id
                      and    i.draft_invoice_num = p_draft_inv_num
                      and    l.lookup_type = 'INVOICE_CREDIT_TYPE'
                      AND    l.lookup_code = 'CANCEL'
                     ) ,
    last_update_date = SYSDATE,
    last_update_login = l_user_id,
    request_id        = l_request_id,
    program_application_id = l_program_application_id,
    program_id        = l_program_id
 where project_id = P_PROJECT_ID
 and draft_invoice_num = P_DRAFT_INV_NUM
 and nvl(canceled_flag, 'N') <> 'Y'
 and not exists
     (
         select null
         from pa_draft_invoices di
         where di.project_id = P_PROJECT_ID
         and di.draft_invoice_num_credited = P_DRAFT_INV_NUM
      )
 returning agreement_id into l_agreement_id;


/* If no rows are updated then raise the exception
   so that the ineligibility criteria is reported.
*/

if SQL%ROWCOUNT = 0 then
    IF g1_debug_mode  = 'Y' THEN
    	pa_ic_inv_utils.log_message('cancel_invoice: ' || 'raising error');
    END IF;
    RAISE INV_CANCELED_OR_CREDIT_MEMO ;
end if;

    IF g1_debug_mode  = 'Y' THEN
        pa_ic_inv_utils.log_message('Updating pa_draft_invoices rows = '||
                                 SQL%ROWCOUNT);
    	pa_ic_inv_utils.log_message('cancel_invoice: ' || 'Agreement id returned = '||
                                 l_agreement_id);
    END IF;
-- Get the new Invoice number to be used for the crediting Invoice

    pa_ic_inv_utils.Get_Next_Draft_Inv_Num(P_PROJECT_ID,
                                           l_request_id,
                                           l_new_draft_inv_num );

/* Create the new invoice header for the crediting invoice ,
   most of the information is obtained from the original Invoice.
*/
    IF g1_debug_mode  = 'Y' THEN
    	pa_ic_inv_utils.log_message('cancel_invoice: ' || 'New invoice num = '||l_new_draft_inv_num);
    END IF;

    /* Bug#5137884 : INTERCOMP INVOICES ERRORING OUT WITH ORA-06512:
              Issue: As part of the MOAC changes, the org_id insertion is missing
               Fix : Org Id is inserted for the new invoices */


     INSERT INTO PA_DRAFT_INVOICES
     (
        DRAFT_INVOICE_NUM,
        PROJECT_ID,
        AGREEMENT_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        TRANSFER_STATUS_CODE,
        PA_DATE,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        BILL_THROUGH_DATE,
        WRITE_OFF_FLAG,
        UNEARNED_REVENUE_CR,
        UNBILLED_RECEIVABLE_DR,
        INVOICE_COMMENT,
        DRAFT_INVOICE_NUM_CREDITED,
        CANCEL_CREDIT_MEMO_FLAG,
        APPROVED_BY_PERSON_ID,
        APPROVED_DATE,
        GENERATION_ERROR_FLAG,
        TRANSFER_REJECTION_REASON,
        RETENTION_PERCENTAGE,
        INV_CURRENCY_CODE,
        INV_RATE_TYPE,
        INV_RATE_DATE,
        INV_EXCHANGE_RATE,
        BILL_TO_ADDRESS_ID,
        SHIP_TO_ADDRESS_ID,
        LANGUAGE,
        CC_PROJECT_ID,
        CC_INVOICE_GROUP_CODE  ,
	INVPROC_CURRENCY_CODE,
        CUSTOMER_ID,
        BILL_TO_CUSTOMER_ID,
        SHIP_TO_CUSTOMER_ID,
        BILL_TO_CONTACT_ID,
        SHIP_TO_CONTACT_ID   /*Added for 2760630*/,
        PROJFUNC_INVTRANS_RATE_TYPE, /* Added below columns for bug 4500281*/
        PROJFUNC_INVTRANS_RATE_DATE,
        PROJFUNC_INVTRANS_EX_RATE,
        ORG_ID
      )
      SELECT l_new_draft_inv_num,
             I2.PROJECT_ID,
             I2.AGREEMENT_ID,
             TRUNC(SYSDATE),
             l_user_id,
             TRUNC(SYSDATE),
             l_user_id,
             'P',
             TRUNC(SYSDATE),
             l_request_id,
             l_program_application_id,
             l_program_id,
             TRUNC(SYSDATE),
             I2.BILL_THROUGH_DATE,
             NULL,
             0,
             0,
             P.INVOICE_COMMENT,
             I2.DRAFT_INVOICE_NUM,
             'Y',
             NULL,
             TRUNC(SYSDATE),
             'N',
             NULL,
             I2.RETENTION_PERCENTAGE,
             I2.INV_CURRENCY_CODE,
             I2.INV_RATE_TYPE,
             I2.INV_RATE_DATE,
             I2.INV_EXCHANGE_RATE,
             I2.BILL_TO_ADDRESS_ID,
             I2.SHIP_TO_ADDRESS_ID,
             I2.LANGUAGE,
             I2.CC_PROJECT_ID,
             I2.CC_INVOICE_GROUP_CODE,
	     I2.INVPROC_CURRENCY_CODE,
             I2.CUSTOMER_ID,
             I2.BILL_TO_CUSTOMER_ID,
             I2.SHIP_TO_CUSTOMER_ID,
             I2.BILL_TO_CONTACT_ID,
             I2.SHIP_TO_CONTACT_ID,
             I2.PROJFUNC_INVTRANS_RATE_TYPE, /* Added below columns for bug 4500281*/
             I2.PROJFUNC_INVTRANS_RATE_DATE,
             I2.PROJFUNC_INVTRANS_EX_RATE,
             I2.ORG_ID
      FROM   PA_DRAFT_INVOICES I2, PA_PROJECTS P
      WHERE  I2.DRAFT_INVOICE_NUM = P_DRAFT_INV_NUM
      AND    I2.PROJECT_ID = P_PROJECT_ID
      AND    P.PROJECT_ID = P_PROJECT_ID;

    IF g1_debug_mode  = 'Y' THEN
        pa_ic_inv_utils.log_message('Inserting pa_draft_invoices rows = '||
                                 SQL%ROWCOUNT);
    END IF;

/* A new line will be created in the canceling Invoice for every line
   in the original canceled invoice.
   The following insert statement will create all the crediting invoice
   lines.
*/

INSERT INTO PA_DRAFT_INVOICE_ITEMS
       (LINE_NUM,
        DRAFT_INVOICE_NUM,
        PROJECT_ID,
        TASK_ID,
        AMOUNT,
        INV_AMOUNT,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        TEXT,
        EVENT_TASK_ID,
        EVENT_NUM,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        UNEARNED_REVENUE_CR,
        UNBILLED_RECEIVABLE_DR,
        DRAFT_INV_LINE_NUM_CREDITED,
        INVOICE_LINE_TYPE,
        TAXABLE_FLAG,
        SHIP_TO_ADDRESS_ID,
        OUTPUT_TAX_CLASSIFICATION_CODE,
        OUTPUT_TAX_EXEMPT_FLAG,
        OUTPUT_TAX_EXEMPT_REASON_CODE,
        OUTPUT_TAX_EXEMPT_NUMBER,
        CC_PROJECT_ID,
        CC_TAX_TASK_ID,
        CC_REV_CODE_COMBINATION_ID,
        TRANSLATED_TEXT,
	invproc_currency_code,
	projfunc_currency_code,
	projfunc_bill_amount,
	project_currency_code,
	project_bill_amount,
	funding_currency_code,
	funding_bill_amount
        )
 SELECT I2.LINE_NUM,
        l_new_draft_inv_num,
        I2.PROJECT_ID,
        I2.TASK_ID,
        -1 * AMOUNT,
        -1 * INV_AMOUNT,
        TRUNC(SYSDATE),
        l_user_id,
        TRUNC(SYSDATE),
        l_user_id,
        I2.TEXT,
        I2.EVENT_TASK_ID,
        NULL,
        l_request_id,
        l_program_application_id,
        l_program_id,
        TRUNC(SYSDATE),
        0,
        0,
        I2.LINE_NUM,
        I2.INVOICE_LINE_TYPE,
        I2.TAXABLE_FLAG,
        I2.SHIP_TO_ADDRESS_ID,
        I2.OUTPUT_TAX_CLASSIFICATION_CODE,
        I2.OUTPUT_TAX_EXEMPT_FLAG,
        I2.OUTPUT_TAX_EXEMPT_REASON_CODE,
        I2.OUTPUT_TAX_EXEMPT_NUMBER,
        I2.CC_PROJECT_ID,
        I2.CC_TAX_TASK_ID,
        I2.CC_REV_CODE_COMBINATION_ID,
        I2.TRANSLATED_TEXT,
	I2.invproc_currency_code,
	I2.projfunc_currency_code,
	-1 * I2.projfunc_bill_amount,
	I2.project_currency_code,
	-1 * I2.project_bill_amount,
	I2.funding_currency_code,
	-1 * I2.funding_bill_amount
FROM    PA_DRAFT_INVOICE_ITEMS  I2
WHERE  I2.PROJECT_ID = P_PROJECT_ID
AND    I2.DRAFT_INVOICE_NUM = P_DRAFT_INV_NUM;

    IF g1_debug_mode  = 'Y' THEN
       pa_ic_inv_utils.log_message('Inserting pa_draft_invoice_items rows = '||
                                 SQL%ROWCOUNT);
    END IF;

/* For each reversing invoice line create new Invoice details ,
   the new rows in the Invoice details will be reversing the Invoice details
   belonging to the Original canceled Invoice line ,
   except in the case when reversing invoice details already exists due
   to adjustments then new invoice details will not be created
   but the reversing  invoice details will be updated with the new Invoice
   number and line number.
*/

/* Open the cursor to fetch the non reversed invoice details of
   the original invoice .
   For each row create reversing invoice details using the table
   handlers.
*/

   l_EI_upd_cnt := 0;

   PA_INVOICE_DETAIL_PROCESS.init;

   Open  c_invoice_detail(p_project_id , p_draft_inv_num);

   loop

   fetch c_invoice_detail into l_inv_detail_rec;

   if c_invoice_detail%notfound  then exit;
   end if;


   l_EI_upd_cnt := l_EI_upd_cnt + 1;

   IF g1_debug_mode  = 'Y' THEN
   	pa_ic_inv_utils.log_message ('cancel_invoice: ' || 'Reversing row number '|| l_EI_upd_cnt);
   	pa_ic_inv_utils.log_message ('cancel_invoice: ' || 'Reversing EI id , line num '||
             l_inv_detail_rec.expenditure_item_id ||','
             ||l_inv_detail_rec.line_num);
   END IF;


   /* Store the values in local tables to be used later for EI update */

   l_expenditure_item_id (l_EI_upd_cnt)
                     := l_inv_detail_rec.expenditure_item_id;
   l_draft_invoice_detail_id (l_EI_upd_cnt)
                     := l_inv_detail_rec.draft_invoice_detail_id;
   l_DENOM_TP_CURRENCY_CODE(l_EI_upd_cnt)
                     := l_inv_detail_rec.DENOM_CURRENCY_CODE;
   l_DENOM_TRANSFER_PRICE(l_EI_upd_cnt)
                     := l_inv_detail_rec.DENOM_BILL_AMOUNT;
   l_ACCT_TP_RATE_TYPE(l_EI_upd_cnt) := l_inv_detail_rec.ACCT_RATE_TYPE;
   l_ACCT_TP_RATE_DATE(l_EI_upd_cnt) := l_inv_detail_rec.ACCT_RATE_DATE;
   l_ACCT_TP_EXCHANGE_RATE(l_EI_upd_cnt)
                     := l_inv_detail_rec.ACCT_EXCHANGE_RATE;
   l_ACCT_TRANSFER_PRICE(l_EI_upd_cnt)
                     := l_inv_detail_rec.BILL_AMOUNT;
   l_PROJACCT_TRANSFER_PRICE(l_EI_upd_cnt)
                     := l_inv_detail_rec.PROJACCT_BILL_AMOUNT;
   l_CC_MARKUP_BASE_CODE(l_EI_upd_cnt)
                     := l_inv_detail_rec.MARKUP_CALC_BASE_CODE;
   l_TP_BASE_AMOUNT(l_EI_upd_cnt)
                     := l_inv_detail_rec.BASE_AMOUNT;
   l_TP_IND_COMPILED_SET_ID(l_EI_upd_cnt)
                     := l_inv_detail_rec.IND_COMPILED_SET_ID;
   l_TP_BILL_RATE(l_EI_upd_cnt)
                     := l_inv_detail_rec.BILL_RATE;
   l_TP_BILL_MARKUP_PERCENTAGE(l_EI_upd_cnt)
                     := l_inv_detail_rec.BILL_MARKUP_PERCENTAGE;
   l_TP_SCHEDULE_LINE_PERCENTAGE(l_EI_upd_cnt)
                     := l_inv_detail_rec.SCHEDULE_LINE_PERCENTAGE;
   l_TP_RULE_PERCENTAGE(l_EI_upd_cnt)
                     := l_inv_detail_rec.RULE_PERCENTAGE;

   /* Reverse row will create reversing invoice details */
   PA_INVOICE_DETAIL_PROCESS.reverse_row(l_inv_detail_rec);

   l_new_draft_inv_detail_id(l_EI_upd_cnt)
                := l_inv_detail_rec.draft_invoice_detail_id;
   end loop;

   close c_invoice_detail;

   PA_INVOICE_DETAIL_PROCESS.apply_ins_changes;

/* Update the existing reversing invoice details ,
   these rows will already have the columns orig_draft_invoice_num
   and orig_draft_invoice_line_num populated */

   UPDATE PA_DRAFT_INVOICE_DETAILS
      SET DRAFT_INVOICE_NUM = l_new_draft_inv_num ,
	  DRAFT_INVOICE_LINE_NUM = ORIG_DRAFT_INVOICE_LINE_NUM,
          INVOICED_FLAG = 'Y',
          last_update_date = SYSDATE,
          last_update_login = l_user_id,
          request_id        = l_request_id,
          program_application_id = l_program_application_id,
          program_id        = l_program_id
    WHERE ORIG_DRAFT_INVOICE_NUM = P_DRAFT_INV_NUM
      AND INVOICED_FLAG = 'N'
      AND PROJECT_ID = P_PROJECT_ID;

   IF g1_debug_mode  = 'Y' THEN
       pa_ic_inv_utils.log_message('Updating invoice details rows  = '
                                                 || SQL%rowcount);
   END IF;


/* Update the project summary fundings to reflect the cancellation */

   pa_ic_inv_utils.update_SPF(l_new_draft_inv_num,
                              l_agreement_id,
                              P_DRAFT_INV_NUM,
                              'CANCEL');

/* Update the EI's with the transfer price attributes.
   Only those EI's corresponding to Invoice details
   that have been reversed in the procedure will be Updated.
   The others are not updated since the other processes
   must have updated the appropriate TP attributes
*/

/* For bug 2968292 Assigned a value of NULL to denom_transfer_price,
   acct_transfer_price and projacct_transfer_price */
/* For bug 3857986, added system_linkage_fuction in returning clause of this update statement */
  FORALL I IN 1..l_EI_upd_cnt
  UPDATE PA_EXPENDITURE_ITEMS
  SET    DENOM_TP_CURRENCY_CODE = l_DENOM_TP_CURRENCY_CODE(I),
         DENOM_TRANSFER_PRICE   = NULL ,
         ACCT_TP_RATE_TYPE      = l_ACCT_TP_RATE_TYPE(I),
         ACCT_TP_RATE_DATE      = l_ACCT_TP_RATE_DATE(I),
         ACCT_TP_EXCHANGE_RATE  = l_ACCT_TP_EXCHANGE_RATE(I),
         ACCT_TRANSFER_PRICE    = NULL,
         PROJACCT_TRANSFER_PRICE = NULL,
         CC_MARKUP_BASE_CODE     = l_CC_MARKUP_BASE_CODE(I),
         TP_BASE_AMOUNT         = l_TP_BASE_AMOUNT(I),
         TP_IND_COMPILED_SET_ID = l_TP_IND_COMPILED_SET_ID(I),
         TP_BILL_RATE           = l_TP_BILL_RATE(I),
         TP_BILL_MARKUP_PERCENTAGE = l_TP_BILL_MARKUP_PERCENTAGE(I),
         TP_SCHEDULE_LINE_PERCENTAGE = l_TP_SCHEDULE_LINE_PERCENTAGE(I),
         TP_RULE_PERCENTAGE     = l_TP_RULE_PERCENTAGE(I),
         cc_ic_processed_code = decode(cc_cross_charge_code,'I','N','X'),
         last_update_date = SYSDATE,
         last_update_login = l_user_id,
         request_id        = l_request_id,
         program_application_id = l_program_application_id,
         program_id        = l_program_id
   WHERE  EXPENDITURE_ITEM_ID = L_EXPENDITURE_ITEM_ID(I)
   RETURNING expenditure_item_date , system_linkage_function
   BULK COLLECT INTO l_ei_date, l_sys_linkage;

   IF g1_debug_mode  = 'Y' THEN
       pa_ic_inv_utils.log_message('Updating EI rows  = ' || SQL%rowcount);
   END IF;

 /** do provider reclass for reversed rows **/

   pa_invoice_detail_process.reverse_preclass
                             (l_draft_invoice_detail_id,
                              l_new_draft_inv_detail_id,
                              l_expenditure_item_id,
                              l_EI_date,
                              l_sys_linkage, /* Bug 3857986 */
                              l_EI_upd_cnt
                             );

 /** To trigger MRC for draft invoice items **/

   PA_IC_INV_UTILS.Commit_Invoice ();

-- Release the user lock once the cancellation for the Invoice is complete.
   l_lock_status := PA_IC_INV_UTILS.Release_User_Lock (P_Project_Id);

EXCEPTION

         WHEN INV_CANCELED_OR_CREDIT_MEMO THEN
         IF g1_debug_mode  = 'Y' THEN
         	pa_ic_inv_utils.log_message('cancel_invoice: ' || 'Invoice Cancelled or Credit memo exists');
         END IF;
         l_lock_status := PA_IC_INV_UTILS.Release_User_Lock (P_Project_Id);
--         raise;
         WHEN CANNOT_ACQUIRE_LOCK THEN
          IF g1_debug_mode  = 'Y' THEN
          	pa_ic_inv_utils.log_message('cancel_invoice: ' || 'Cannot acquire lock for project ' ||
                                       P_project_id);
          END IF;
         WHEN OTHERS THEN
          raise;
END cancel_invoice;

end pa_ic_inv_cnl;

/
