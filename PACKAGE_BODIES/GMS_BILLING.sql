--------------------------------------------------------
--  DDL for Package Body GMS_BILLING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_BILLING" AS
--  $Header: gmsinblb.pls 120.15.12010000.6 2008/11/27 11:13:44 rrambati ship $

-- To check on, whether to print debug messages in log file or not
L_DEBUG varchar2(1) := NVL(FND_PROFILE.value('GMS_ENABLE_DEBUG_MODE'), 'N');

TYPE Inst_Rec is RECORD(INSTALLMENT_ID NUMBER(15),
		        REV_BILL_AMOUNT NUMBER(22,5));

TYPE Inst_tab is TABLE OF Inst_Rec
                 INDEX BY BINARY_INTEGER;

X_Installment_tab       Inst_tab; -- Used to get store installment numbers for invoice
X_Rev_Installment_tab   Inst_tab; -- Used to get store installment numbers for revenue
X_ei_rollback_Inst_tab    Inst_tab; -- Used to get the rollback transaction amounts  /* for bug 5242484 */

TYPE Inst_Rec2 is RECORD(INSTALLMENT_ID NUMBER(15),
                         REV_BILL_AMOUNT NUMBER(22,5),
                         ACTUAL_PROJECT_ID NUMBER(15),
                         ACTUAL_TASK_ID NUMBER(15));

TYPE Inst_tab2 is TABLE OF Inst_Rec2
                 INDEX BY BINARY_INTEGER;

X_Installment_Total     Inst_tab2; -- Used to collect amt's on installments for invoice
X_Rev_Installment_Total Inst_tab2; -- Used to collect amt's on installments for revenue

ROLLBACK_FAILURE       Exception;

-- ## this exception is handled in the main procedure AWARD_BILLING only
-- ## but this exception is called from procedures which are called within AWARD_BILLING

NO_PROCESSING_OF_AWARD Exception;

-- ## This exception is handled in the main procedure AWARD_BILLING only
-- ## but this exception is called from procedures which are called within AWARD_BILLING

AWARD_DATA_LOCKED      Exception;
-- ## This exception is handled in the main procedure AWARD_BILLING only

GMS_TAX_FAILURE Exception;   --Added for bug 4506225
-- ## This exception is handled in the main procedure AWARD_BILLING only
-- ## This exception is raised when the call to GMS_TAX returns a value St_Err_Code <> 0

INVALID_INVOICE_FORMAT Exception;

-- ## This exception is handled in the main procedure AWARD_BILLING only
-- ## This exception is raised when the invoice format containins an element not supported by GMS

X_BURDEN_NULL_EVENT_PROCESSED  BOOLEAN := FALSE;
X_REVRAW_NULL_EVENT_PROCESSED  BOOLEAN := FALSE;
X_INVRAW_NULL_EVENT_PROCESSED  BOOLEAN := FALSE;

-- Above package variables are set if NULL events are processed. These variables are accessed
-- in award_billing procedure.
-- X_BURDEN_NULL_EVENT_PROCESSED  set in do_burden_event_processing
-- X_REVRAW_NULL_EVENT_PROCESSED  set in do_rev_event_processing
-- X_INVRAW_NULL_EVENT_PROCESSED  set in do_event_processing

-- X_LAST_CALL_FOR_REVENUE       BOOLEAN := FALSE; -- Bug 3254097 : Commenting out the variable as the logic
                                                   --               which uses this variable is commented out.

-- This package variable is set when do_rev_event_processing procedure is
-- called for the last record.

-- Bug 3254097 : Flag to check if billing flags need to be updated for an expenditure Item.
X_UPD_BILLING_FLAG             BOOLEAN := FALSE;

-- Bug 3235390 :  Introduced the following variable to generate negative sequence
--                for temprary events.
x_temp_negative_evt_num    NUMBER(15) ;

-- Bug 5413530
X_trans_type VARCHAR2(10);
G_trans_type VARCHAR2(10);

/* -----------------------------------------------------------------------------------------+ */
-- Function Is_Invoice_Format_Valid : This is called from :AWARDS form and gms_billing.award_billing
-- Function checks whether the invoice format (labor/non-labor) has any element (column) that is not
-- supported by Grants Accounting.
-- Calling context would be 'AWARDS_FORM' or 'BILLING_PROCESS'
-- Function returns TRUE is format is VALID else returns FALSE

Function Is_Invoice_Format_Valid(X_award_project_id IN NUMBER,
                                 X_Labor_format_id IN NUMBER,
                                 X_Non_Labor_format_id IN NUMBER,
                                 X_calling_context IN VARCHAR2)
RETURN BOOLEAN IS
 l_dummy number;
 l_labor_format_id     gms_Awards_all.labor_invoice_format_id%TYPE;
 l_non_labor_format_id gms_Awards_all.non_labor_invoice_format_id%TYPE;
Begin

 If X_calling_context = 'BILLING_PROCESS' then

    select a.labor_invoice_format_id, a.non_labor_invoice_format_id
    into   l_labor_format_id,l_non_labor_format_id
    from   gms_awards_all a
    where  a.award_project_id = X_Award_Project_Id;

 Elsif X_calling_context = 'AWARDS_FORM' then

    l_Labor_format_id     := X_Labor_format_id;
    l_Non_Labor_format_id := X_Non_Labor_format_id;

 End If;

--Commented columns containing 'Job' for Bug# 5003907
 Begin
  select 1 into l_dummy from dual where exists (
  select 1
  from   pa_invoice_group_columns a,
         pa_invoice_format_details b
  where  a.invoice_group_column_id = b.invoice_group_column_id
  and    b.invoice_format_id in(l_labor_format_id,X_Non_Labor_format_id)
  and    a.column_code not in ('EMPLOYEE FIRST NAME','EMPLOYEE FULL NAME',
                               'EMPLOYEE LAST NAME','EXPENDITURE CATEGORY',
                               'EXPENDITURE TYPE', --'JOB','JOB DISCIPLINE','JOB LEVEL',
			       'NON-LABOR RESOURCE','ORGANIZATION',
                               'REVENUE CATEGORY','TEXT','TOP TASK NAME',
                               'TOP TASK NUMBER','TOTAL AMOUNT','TOTAL HOURS',
                               'UNITS'));

  RETURN FALSE;
 Exception
    When no_data_found then
         RETURN TRUE;
 End;
End Is_Invoice_Format_Valid;
/* -----------------------------------------------------------------------------------------+ */
-- Following function determines if burden is allowed ..
-- Used in format_specific_billing and revenue_accrual

Function allow_burden(p_transaction_source in varchar2) return BOOLEAN is
 l_allow_burden_flag pa_transaction_sources.allow_burden_flag%type;
Begin
	 -- import burden amount (Txn. source UI) = allow_burden_flag (database)
         -- Allow burden
	 --  Y - burden is imported from external transaction source and do not calculate in Projects
	 --  N - burden is calculated in projects.
	 --  we need to allow burden when allow_burden_flag is 'N'

  Select DECODE( NVL(allow_burden_flag,'N'), 'N', 'Y', 'N')
  into   l_allow_burden_flag
  from   pa_transaction_sources pts
  where  pts.transaction_source = p_transaction_source;

  If l_allow_burden_flag = 'Y' then
     RETURN TRUE;
  Else
     RETURN FALSE;
  End If;
Exception
  When no_data_found then
       RETURN TRUE;
End allow_burden;

/* ----------------------------------------------------------------------------------------- */
-- Following function is called from do_rev_event_processing.
-- this will check if there are any records with null event number ..

Function NULL_REVENUE_EVENT_EXISTS(X_award_project_id IN NUMBER,
				   X_request_id       IN NUMBER,
				   X_event_type       IN VARCHAR2)
RETURN BOOLEAN IS
x_dummy  number(1);
BEGIN

     Select 1
     into   x_dummy
          from   dual
          where exists (select 1
                        from   gms_event_intersect
                        where  award_project_id = X_Award_Project_Id
                        and    request_id       = X_Request_Id
			and    event_type       = X_Event_Type
                        and    event_num IS NULL);

      RETURN TRUE;

EXCEPTION

   When Others then

        RETURN FALSE;

END;

/* ----------------------------------------------------------------------------------------- */
-- This function will be called to determine whether we need to run billing
-- process (REVENUE/INVOICE) or not.

FUNCTION  IS_PROCESSING_REQD(X_Calling_Process IN VARCHAR2,
                          X_Award_Id        IN NUMBER)
RETURN BOOLEAN   IS
l_value NUMBER :=0;

/* Added for bug 3848203 */

X_Award_Rev_Distribution_Rule VARCHAR2(30);
X_Award_Bill_Distribution_Rule VARCHAR2(30);

Begin

   If  X_Calling_Process = 'Revenue' then

      Begin
     /* Changes for bug 3848203 */

    select
      a.Revenue_Distribution_Rule
    into
      X_Award_Rev_Distribution_Rule
    from
       GMS_AWARDS a
    where
      a.Award_Id =X_Award_Id;

if (X_Award_Rev_Distribution_Rule = 'EVENT') then
    RETURN FALSE;
else
       Select 1
       into   l_value
       from   dual
       where exists(
         select /*+ INDEX(adl gms_award_distributions_n7) */ 1 /* Added hint for bug 6969435 */
         from   gms_award_distributions adl,
                pa_tasks t3,
                pa_tasks t5
         where  adl.award_id = X_Award_Id
            and adl.document_type = 'EXP'
            and adl.adl_status = 'A'
            and adl.fc_status = 'A'
            and adl.billable_flag ='Y'  /* removed nvl for  bug 6969435 */
            and adl.revenue_distributed_flag in ('N','Z') /* removed nvl for bug 6969435 */
            and adl.project_id = t3.project_id /* Added for bug 6969435 */
            and t3.task_id = adl.task_id
            and t3.top_task_id = t5.task_id
            and t5.ready_to_distribute_flag = 'Y');

         RETURN TRUE;
end if;

      Exception

         When NO_DATA_FOUND Then

               RETURN FALSE;
      End;

   ElsIf  X_Calling_Process = 'Invoice' then

      Begin

    select
     a.Billing_Distribution_Rule
    into
      X_Award_Bill_Distribution_Rule
    from
       GMS_AWARDS a
    where
      a.Award_Id =X_Award_Id ;

if(X_Award_Bill_Distribution_Rule = 'EVENT') then
return FALSE;
else
       Select 1
       into   l_value
       from   dual
       where exists(
         select /*+ INDEX(adl gms_award_distributions_n7) */  1 /* Added hint for bug 6969435 */
         from
                gms_award_distributions adl,
                pa_tasks t3,
                pa_tasks t5
         where  adl.award_id = X_Award_Id
            and adl.document_type = 'EXP'
            and adl.adl_status = 'A'
            and adl.fc_status = 'A'
            and adl.billable_flag ='Y' /* removed nvl for bug 6969435 */
            and adl.billed_flag in ('N','Z') /*  removed nvl for bug 6969435 */
            and t3.task_id = adl.task_id
            and t3.top_task_id = t5.task_id
            and t5.ready_to_distribute_flag = 'Y');

         RETURN TRUE;
end if;

/* End of Changes for bug 3848203 */

      Exception

         When NO_DATA_FOUND Then

               RETURN FALSE;
      End;

   End If;

End IS_PROCESSING_REQD;


-- Bug 1652198 ...
-- PROCEDURE LOCK_AWARD_RECORDS, new procedure to achieve concurrency between billing
-- processes and Awards form.

PROCEDURE LOCK_AWARD_RECORDS(X_Award_Project_id   IN NUMBER,
		              X_Err_Code           IN OUT NOCOPY NUMBER,
			      X_Err_Buff           IN OUT NOCOPY VARCHAR2)
IS

 X_Dummy number(1);
 RESOURCE_BUSY EXCEPTION;
 PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -00054);

 Cursor Cur_installment_lock is
       select   a.installment_id
       from     gms_installments a,
                gms_awards b
       where    b.award_project_id = X_Award_Project_id
       and      a.award_id = b.award_id;

Begin

 X_Err_Code := 0;

 Select 1
 into   x_dummy
 from   gms_awards
 where  award_project_id =  X_Award_Project_id
 FOR UPDATE NOWAIT;

 IF L_DEBUG = 'Y' THEN
 	gms_error_pkg.gms_debug('After Locking Award','C');
 END IF;

 for installment_records in Cur_installment_lock
 loop

   Begin

     Select 1
     into   x_dummy
     from   gms_installments
     where  installment_id = installment_records.installment_id
     FOR UPDATE NOWAIT;
   Exception
     When  RESOURCE_BUSY THEN
            RAISE;
     When OTHERS THEN
            RAISE;
   END;
 end loop;

 IF L_DEBUG = 'Y' THEN
 	gms_error_pkg.gms_debug('After Locking Installments','C');
 END IF;

Exception

   When  RESOURCE_BUSY THEN

     Raise AWARD_DATA_LOCKED;

    When  OTHERS THEN

      gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
                                'SQLCODE',
                                SQLCODE,
                                'SQLERRM',
                                SQLERRM,
                                X_Exec_Type => 'C',
                                X_Err_Code => X_Err_Code,
                                X_Err_Buff => X_Err_Buff);

     --Raise NO_PROCESSING_OF_AWARD ;

End LOCK_AWARD_RECORDS;


-- PROCEDURE BILLING_ROLLBACK, new procedure for roll ups in case of process failure
-- Added x_event_num.. 8/26/02. This has been added so that event_number value can be
-- passed while rolling back null events ...

PROCEDURE billing_rollback (
   x_award_project_id   IN       NUMBER,
   --x_calling_process    IN       VARCHAR2,
   x_event_num		IN       NUMBER DEFAULT NULL,
   x_err_code           IN OUT NOCOPY   NUMBER,
   x_err_buff           IN OUT NOCOPY   VARCHAR2
)
IS
F_Request_id  number := 0 ;
F_calling_process varchar(20);

   CURSOR events_to_rollback
   IS
      SELECT DISTINCT project_id, event_num, event_calling_process event_type
        FROM gms_event_attribute gea
       WHERE project_id = x_award_project_id
         --AND event_calling_process = x_calling_process
	 and event_num > 0   /* Added for bug 4594090 */ /*Changed to >0 for bug 6969435 */
         AND ( (x_event_num IS NULL)    OR
               (x_event_num IS NOT NULL AND  event_num = x_event_num)
              )
         AND  event_calling_process IS NOT NULL
         -- null for manual events
      and not exists ( /* Modified MINUS operation to Not exists clause */
      SELECT 1 --project_id, event_num, calling_process event_type /* Modifed for 6969435 */
        FROM pa_events
       WHERE --project_id = x_award_project_id /* commented for 6969435 */
         --AND calling_process = x_calling_process /* commented for 6969435 */
         --AND ( (x_event_num IS NULL)    OR  /* commented for 6969435 */
         --      (x_event_num IS NOT NULL AND event_num = x_event_num) /* commented for 6969435 */
         --     ) /* commented for 6969435 */
         --AND  /* commented for 6969435 */
         event_type = 'AWARD_BILLING'
         and  project_id = gea.project_id
	 and  event_num = gea.event_num
         and  calling_process = gea.event_calling_process
	 );

      -- x_event_num will have a value when this procedure is being called for
      -- rolling back NULL events ...

   CURSOR get_exp_raw_info (f_project_id NUMBER, f_event_num NUMBER,
                            f_event_calling_process VARCHAR2)
   IS
      SELECT DISTINCT gei.expenditure_item_id, gei.adl_line_num,
                      gea.actual_project_id, gea.actual_task_id,
                      gea.expenditure_org_id, gei.amount,
                      gei.revenue_accumulated, gei.creation_date,gea.request_id
        FROM gms_event_intersect gei, gms_event_attribute gea
       WHERE gea.project_id = f_project_id
         AND gea.event_num = f_event_num
         AND gea.event_calling_process = f_event_calling_process
         AND gei.award_project_id = gea.project_id
         AND gei.event_num = gea.event_num
	 AND gei.event_type = UPPER(f_event_calling_process);

   f_raw_exp_item_id        gms_award_distributions.expenditure_item_id%TYPE;
   f_raw_adl_line_num       gms_award_distributions.adl_line_num%TYPE;
   f_raw_act_project_id     gms_event_attribute.actual_project_id%TYPE;
   f_raw_act_task_id        gms_event_attribute.actual_task_id%TYPE;
   f_raw_org_id             gms_event_attribute.expenditure_org_id%TYPE;
   f_raw_rev_accumulated    gms_event_intersect.revenue_accumulated%TYPE;
   f_raw_revenue_amount     gms_event_intersect.amount%TYPE;
   f_raw_creation_date      gms_event_intersect.creation_date%TYPE;

   CURSOR get_exp_burden_info (f_project_id NUMBER, f_event_num NUMBER,
                               f_event_calling_process VARCHAR2)
   IS
      SELECT expenditure_item_id, adl_line_num, actual_project_id,
             actual_task_id, expenditure_org_id, burden_exp_type, burden_cost_code,
             amount, revenue_accumulated, creation_date
        FROM gms_burden_components
       WHERE award_project_id = f_project_id
         AND event_num = f_event_num
	 AND event_type = UPPER(f_event_calling_process);

   f_burd_exp_item_id       gms_award_distributions.expenditure_item_id%TYPE;
   f_burd_adl_line_num      gms_award_distributions.adl_line_num%TYPE;
   f_burd_rev_accumulated   gms_burden_components.revenue_accumulated%TYPE;
   f_burd_revenue_amount    gms_burden_components.amount%TYPE;
   f_burd_act_project_id    gms_burden_components.actual_project_id%TYPE;
   f_burd_act_task_id       gms_burden_components.actual_task_id%TYPE;
   f_burd_org_id            gms_burden_components.expenditure_org_id%TYPE;
   f_burd_exp_type          gms_burden_components.burden_exp_type%TYPE;
   f_burd_cost_code         gms_burden_components.burden_cost_code%TYPE;
   f_burd_creation_date     gms_burden_components.creation_date%TYPE;

-- Get_Event_Details required as Event to Installment has one - many relationship

   CURSOR get_event_details (f_project_id NUMBER, f_event_num NUMBER,
                             f_event_calling_process VARCHAR2)
   IS
      SELECT actual_project_id, actual_task_id, installment_id,
             revenue_amount, bill_amount
             , rowid  -- Bug 2715312
        FROM gms_event_attribute
       WHERE project_id = f_project_id
         AND event_num = f_event_num
	 AND event_calling_process = f_event_calling_process;

   f_act_project_id         gms_event_attribute.actual_project_id%TYPE;
   f_act_task_id            gms_event_attribute.actual_task_id%TYPE;
   f_installment_id         gms_event_attribute.installment_id%TYPE;
   f_rev_amount             gms_event_attribute.revenue_amount%TYPE;
   f_bill_amount            gms_event_attribute.bill_amount%TYPE;
   f_row_id                 rowid ;  -- Bug 2715312
   x_stage                  NUMBER (2);
BEGIN
/* --------------------------------------------------------------------------
|| Rollback Activities Include:
|| 10. Updating gms_award_distributions (revenue_distributed_flag/billed_flag)
|| 20. Deleting from gms_event_intersect
|| 30. Deleting from gms_burden_components
|| 40. Updating gms_summary_project_fundings
|| 50. Deleting gms_event_attribute
   -------------------------------------------------------------------------- */

   FOR evt IN events_to_rollback
   LOOP
   F_calling_process :=  UPPER(evt.event_type); /* Added for bug 4957529 */

/* -------- EXPENDITURE RELATED UPDATIONS ------------ */

      -- ## RAW UPDATION

      OPEN get_exp_raw_info (evt.project_id, evt.event_num,evt.event_type);

      LOOP
         FETCH get_exp_raw_info INTO f_raw_exp_item_id,
                                     f_raw_adl_line_num,
                                     f_raw_act_project_id,
                                     f_raw_act_task_id,
                                     f_raw_org_id,
                                     f_raw_revenue_amount,
                                     f_raw_rev_accumulated,
                                     f_raw_creation_date,
				     f_request_id; --Added for bug 4957529
         EXIT WHEN get_exp_raw_info%NOTFOUND;

         BEGIN                                    -- Expenditure Rollup Block
            -- 10: Updating the gms_award_distributions table

            x_stage := 10;

            IF evt.event_type = 'Revenue'
            THEN
               IF f_raw_rev_accumulated = 'Y'
               THEN
                  /* Create negative entry in gms_billing_cancellations
                     for ASI to backout revenue accumulated */
                  gms_billing_adjustments.insert_bill_cancel (evt.project_id,
                     evt.event_num,
                     f_raw_exp_item_id,
                     f_raw_adl_line_num,
                     -1 * f_raw_revenue_amount,
                     evt.event_type,
                     NULL,                                 -- burden_exp_type
                     NULL,                                -- burden_cost_code
                     f_raw_creation_date,
                     f_raw_act_project_id,
                     f_raw_act_task_id,
                     f_raw_org_id,
                     SYSDATE,                                -- deletion_date
                     NULL,                                            -- rlmi
                     x_err_code,
                     x_err_buff
                  );
               END IF;

               UPDATE gms_award_distributions
                  SET revenue_distributed_flag = decode(x_event_num,NULL,'N','Z'),
                      last_update_date = SYSDATE,
                      last_updated_by = fnd_global.user_id,
                      last_update_login = fnd_global.login_id
                WHERE expenditure_item_id = f_raw_exp_item_id
                  AND adl_line_num = f_raw_adl_line_num
                  AND document_type = 'EXP'
                  AND adl_status = 'A';
            ELSIF evt.event_type = 'Invoice'
            THEN
               UPDATE gms_award_distributions
                  SET billed_flag = decode(x_event_num,NULL,'N','Z'),
                      last_update_date = SYSDATE,
                      last_updated_by = fnd_global.user_id,
                      last_update_login = fnd_global.login_id
                WHERE expenditure_item_id = f_raw_exp_item_id
                  AND adl_line_num = f_raw_adl_line_num
                  AND document_type = 'EXP'
                  AND adl_status = 'A';
            END IF;

            -- 20: Deleting records from gms_event_intersect

            x_stage := 20;

            DELETE
              FROM gms_event_intersect
             WHERE expenditure_item_id = f_raw_exp_item_id
               AND adl_line_num = f_raw_adl_line_num
               AND award_project_id = evt.project_id
               AND event_num = evt.event_num
               AND event_type = upper(evt.event_type);
         END;
      END LOOP;                                            -- Get_Exp_Raw_Info

      CLOSE get_exp_raw_info;

      -- ## BURDEN  UPDATION


      OPEN get_exp_burden_info (evt.project_id, evt.event_num,evt.event_type);

      LOOP
         FETCH get_exp_burden_info INTO f_burd_exp_item_id,
                                        f_burd_adl_line_num,
                                        f_burd_act_project_id,
                                        f_burd_act_task_id,
                                        f_burd_org_id,
                                        f_burd_exp_type,
                                        f_burd_cost_code,
                                        f_burd_revenue_amount,
                                        f_burd_rev_accumulated,
                                        f_burd_creation_date;
         EXIT WHEN get_exp_burden_info%NOTFOUND;

         BEGIN                                    -- Expenditure Rollup Block
            -- 30: Deleting records from gms_burden_components
            x_stage := 30;

            IF f_burd_rev_accumulated = 'Y' and evt.event_type = 'Revenue'
            THEN
               /* Create negative entry in gms_billing_cancellations
                  for ASI to backout revenue accumulated */
               gms_billing_adjustments.insert_bill_cancel (evt.project_id,
                  evt.event_num,
                  f_burd_exp_item_id,
                  f_burd_adl_line_num,
                  -1 * f_burd_revenue_amount,
                  evt.event_type,
                  f_burd_exp_type,                        -- burden_exp_type
                  f_burd_cost_code,                       -- burden_cost_code
                  f_burd_creation_date,
                  f_burd_act_project_id,
                  f_burd_act_task_id,
                  f_burd_org_id,
                  SYSDATE,                                   -- deletion_date
                  NULL,                                               -- rlmi
                  x_err_code,
                  x_err_buff
               );
            END IF;

            DELETE
              FROM gms_burden_components
             WHERE expenditure_item_id = f_burd_exp_item_id
               AND adl_line_num = f_burd_adl_line_num
               AND award_project_id = evt.project_id
               AND event_num = evt.event_num
               AND event_type = upper(evt.event_type) ;


         END;
      END LOOP;                                         -- Get_Exp_Burden_Info

      CLOSE get_exp_burden_info;
/* -------- EVENT RELATED UPDATIONS ------------ */

      OPEN get_event_details (evt.project_id, evt.event_num,evt.event_type);

      LOOP
         FETCH get_event_details INTO f_act_project_id,
                                      f_act_task_id,
                                      f_installment_id,
                                      f_rev_amount,
                                      f_bill_amount,
                                      f_row_id;      -- Bug 2715312
         EXIT WHEN get_event_details%NOTFOUND;

         BEGIN                                               -- Event Related
            -- 40: Updating gms_summary_project_fundings

            IF evt.event_type = 'Invoice'
            THEN
               UPDATE gms_summary_project_fundings
                  SET total_billed_amount =
                         total_billed_amount - f_bill_amount
                WHERE project_id = f_act_project_id
                  AND (   task_id IS NULL
                       OR task_id = f_act_task_id
                       OR task_id = (select t.top_task_id
                                     from   PA_TASKS t
                                     where  t.task_id = f_act_task_id)
                       )
                  AND installment_id = f_installment_id;

            ELSIF evt.event_type = 'Revenue'
            THEN
               UPDATE gms_summary_project_fundings
                  SET total_revenue_amount =
                         total_revenue_amount - f_rev_amount
                WHERE project_id = f_act_project_id
                  AND (   task_id IS NULL
                       OR task_id = f_act_task_id
                       OR task_id = (select t.top_task_id
                                     from   PA_TASKS t
                                     where  t.task_id = f_act_task_id)
                       )
                  AND installment_id = f_installment_id;

            END IF;

            -- 50: Delete gms_event_attribute

            DELETE
              FROM gms_event_attribute
             WHERE rowid= f_row_id ;  -- Bug 2715312, Replaced the below conditions with rowid
           --  WHERE project_id = evt.project_id
           --    AND event_num  = evt.event_num
           --    AND actual_project_id = f_act_project_id
           --    AND actual_task_id = f_act_task_id
           --    AND installment_id = f_installment_id
           --    AND event_calling_process = evt.event_type;

            IF SQL%NOTFOUND
            THEN

               -- Following If..End If added for bug 2648168 ..

               If (f_bill_amount <> 0  or
                   f_rev_amount  <> 0) then

                  gms_error_pkg.gms_message ('GMS_BILLING_ROLLBACK_EVT',
                  'PRJ',
                  f_act_project_id,
                  'TASK',
                  f_act_task_id,
                  'INST',
                  f_installment_id,
                  'STAGE',
                  x_stage,
                  x_exec_type   => 'C',
                  x_err_code    => x_err_code,
                  x_err_buff    => x_err_buff
                  );
                  RAISE no_processing_of_award;

              End If;

            END IF;
         END;                                                 -- Event Related
      END LOOP;                                           -- get_event_details

     CLOSE get_event_details;

   END LOOP;                                  -- Main Loop: events_to_rollback

   x_err_code := 0;

If  ( F_request_id <> 0 )  then
   -- Handle net zero events .... /* Added for bug 4957529 */
  gms_billing_adjustments.HANDLE_NET_ZERO_EVENTS (P_AWARD_PROJECT_ID => X_Award_Project_id,
                          P_REQUEST_ID       => F_request_id,
                          P_CALLING_PROCESS  => F_calling_process);
 End IF ;  /* Added for bug 4957529 */

END billing_rollback;

-- -----------------------------------------------------------------------------
-- Following procedure DELETE_NULL_EVENTS will delete the null event
-- records from gms_event_intersect and gms_burden_components
-- At the same time, it will reset the award distribution lines billing flags
-- For invoice records, procedure may have to update summary fundings ...

-- !!! Flags will be reset with a value of "Z" indicating net zero ...
/***Commented out for bug 4957529
PROCEDURE DELETE_NULL_EVENTS (X_award_project_id  IN  NUMBER,
                              X_request_id        IN  NUMBER,
                              X_calling_process   IN  VARCHAR2,
                              X_err_code          OUT NOCOPY NUMBER,
                              X_err_buff          OUT NOCOPY VARCHAR2)
IS
X_event_type VARCHAR2(10);
BEGIN

IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('In DELETE_NULL_EVENTS - START', 'C');
END IF;
X_event_type := UPPER(X_calling_process);

-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
-- Null events for raw invoice records .. Code start

If X_INVRAW_NULL_EVENT_PROCESSED then

   IF L_DEBUG = 'Y' THEN
   	gms_error_pkg.gms_debug('In DELETE_NULL_EVENTS - Stage: Rollback Invoice raw events','C');
   END IF;

         billing_rollback(X_award_project_id,
       		          --X_calling_process,
                          -1, -- event_num for NULL events...check do_event_processing
                          X_Err_Code,
                          X_Err_Buff);

IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('In DELETE_NULL_EVENTS - Stage: After Rollback Invoice raw events,X_Err_Code:'||X_Err_Code,'C');
END IF;

  If X_Err_Code <> 0  then
      gms_error_pkg.gms_message('GMS_BILLING_ROLLBACK_FAILURE',
                                'PRJ',
                                X_award_project_id,
                                X_Exec_Type => 'C',
                                X_Err_Code => X_Err_Code,
                                X_Err_Buff => X_Err_Buff);
     Raise ROLLBACK_FAILURE;

  End if;

End if;
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
-- Null events for raw revenue records .. Code start

If X_REVRAW_NULL_EVENT_PROCESSED then

     IF L_DEBUG = 'Y' THEN
     	gms_error_pkg.gms_debug('In DELETE_NULL_EVENTS - Stage: Revenue Raw - ADL update', 'C');
     END IF;

     Update gms_award_distributions
     set    revenue_distributed_flag = decode(revenue_distributed_flag,'Y','Z','Z','N')
     where  (expenditure_item_id,adl_line_num) in
             (select expenditure_item_id,
                    adl_line_num
             from   gms_event_intersect
             where  award_project_id = X_award_project_id
             and    event_num        = -1
             and    request_id       = X_request_id
             and    event_type       = X_event_type
             )
    and      document_type = 'EXP';

     IF L_DEBUG = 'Y' THEN
     	gms_error_pkg.gms_debug('In DELETE_NULL_EVENTS - Stage: Revenue Raw - Delete records', 'C');
     END IF;

   Delete
   from   gms_event_intersect
   where  award_project_id = X_award_project_id
   and    event_num        = -1
   and    request_id       = X_request_id
   and    event_type       = X_event_type;

End If;

-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
-- Null events for burden records .. Code Start

If X_BURDEN_NULL_EVENT_PROCESSED then

   If X_event_type = 'INVOICE' then

     IF L_DEBUG = 'Y' THEN
     	gms_error_pkg.gms_debug('In DELETE_NULL_EVENTS - Stage: Invoice Burden - ADL Update', 'C');
     END IF;

     Update gms_award_distributions
     set    billed_flag =  decode(billed_flag,'Y','Z','Z','N')
     where  (expenditure_item_id,adl_line_num) in
             (select expenditure_item_id,
                    adl_line_num
             from   gms_burden_components
             where  award_project_id = X_award_project_id
             and    event_num        = -2
             and    request_id       = X_request_id
             and    event_type       = X_event_type
             )
    and      document_type = 'EXP';

   ElsIf X_event_type = 'REVENUE' then

     IF L_DEBUG = 'Y' THEN
     	gms_error_pkg.gms_debug('In DELETE_NULL_EVENTS - Stage: Revenue Burden - ADL Update', 'C');
     END IF;

     Update gms_award_distributions
     set    revenue_distributed_flag = decode(revenue_distributed_flag,'Y','Z','Z','N')
     where  (expenditure_item_id,adl_line_num) in
             (select expenditure_item_id,
                    adl_line_num
             from   gms_burden_components
             where  award_project_id = X_award_project_id
             and    event_num        = -2
             and    request_id       = X_request_id
             and    event_type       = X_event_type
             )
    and      document_type = 'EXP';

   End if;

     IF L_DEBUG = 'Y' THEN
     	gms_error_pkg.gms_debug('In DELETE_NULL_EVENTS - Stage: Burden - Delete records', 'C');
     END IF;

   Delete
   from   gms_burden_components
   where  award_project_id = X_award_project_id
   and    event_num        = -2
   and    request_id       = X_request_id
   and    event_type       = X_event_type;

End if;

-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
X_err_code := 0;
IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('In DELETE_NULL_EVENTS - END', 'C');
END IF;
-- Not handling exceptions in this procedure .. exceptions falls to award_billing
End DELETE_NULL_EVENTS;
***************************/
-- -----------------------------------------------------------------------------

-- PROCEDURE GMS_BILL_CONCURRENCY , new procedure for Concurrency Control

PROCEDURE GMS_BILL_CONCURRENCY(X_Request_Id 		IN NUMBER,
			       X_Award_Project_Id	IN NUMBER,
			       X_Err_Code  		IN OUT NOCOPY NUMBER,
			       X_Err_Buff  		IN OUT NOCOPY VARCHAR2)
IS
X_Process_Name Varchar2(15);
Begin

   Select 0
   into   X_Err_Code
   from   gms_concurrency_control
   where  process_key  = X_Award_Project_Id
   and    process_name = 'GMS_BLNG'
   for    update NOWAIT;

Exception
 When no_data_found then
     -- Bug 2441525 : GSCC Errors :Added columns in insert command
     insert into gms_concurrency_control
     (PROCESS_NAME,
      PROCESS_KEY ,
      REQUEST_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATED_BY ,
      CREATION_DATE,
      LAST_UPDATE_LOGIN )
     values('GMS_BLNG',
            X_Award_Project_Id,
	    X_Request_Id,
            sysdate,
	    fnd_global.user_id,
	    fnd_global.user_id,
	    sysdate,
	    fnd_global.login_id
           );

     commit;

-- The next begin end is required for the case when another user may
-- execute a select before the current user

      Begin

         Select 0
         into   X_Err_Code
         from   gms_concurrency_control
         where  process_key  = X_Award_Project_Id
   	 and    process_name = 'GMS_BLNG'
         for update NOWAIT;

      Exception
          When others then
              gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
					'SQLCODE',
			        	SQLCODE,
					'SQLERRM',
					SQLERRM,
					X_Exec_Type => 'C',
					X_Err_Code => X_Err_Code,
					X_Err_Buff => X_Err_Buff);
      End;

 When others then
      gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);

End GMS_BILL_CONCURRENCY;

-- PROCEDURE ONE_TIME_BILL_HOLD, updates ADL records for ONE TIME Bill Hold

PROCEDURE ONE_TIME_BILL_HOLD(X_Award_Project_Id IN NUMBER,
			     X_Award_Id	     IN NUMBER,
			     X_Rev_Or_Bill_Date IN DATE,
			     X_Request_Id	IN NUMBER,
			     X_Err_Code         IN OUT NOCOPY NUMBER,
			     X_Err_Buff		IN OUT NOCOPY VARCHAR2) IS
/* This Cursor fetches expenditure items on ONE TIME BILL HOLD */
Cursor one_time_hold is
       select /*+INDEX(pt PA_PROJECT_TYPES_U1)*/
              ei.expenditure_item_id expenditure_item_id,
       	      adl.adl_line_num        adl_line_num,
              adl.award_id            award_id
       from   pa_expenditure_items_all ei,
	      pa_expenditure_types et,
	      pa_projects_all p,
   	      pa_project_types pt,
	      pa_tasks t3,
	      pa_tasks t5,
	      gms_award_distributions adl
       where  adl.award_id = X_Award_Id
       and    ei.expenditure_item_id = adl.expenditure_item_id
       and    ei.system_linkage_function <> 'BTC'
       and    p.project_status_code <> 'CLOSED'
       and    pt.project_type = p.project_type
       and    pt.direct_flag = 'N'
       and    t3.project_id = p.project_id
       and    ei.task_id = t3.task_id
       and    t3.top_task_id = t5.task_id
       and    t5.ready_to_bill_flag = 'Y'
       and    adl.cost_distributed_flag = 'Y'
       and    ei.expenditure_item_date <= nvl(trunc(X_rev_or_bill_date),SYSDATE)
       and    ei.expenditure_type = et.expenditure_type
       and    adl.document_type = 'EXP'
       and    adl.fc_status = 'A'
       and    adl.adl_status = 'A'
       and    ei.bill_hold_flag='O';

Begin

     For Bill_Hold_Rec in one_time_hold
     loop
/*
        Update gms_award_distributions
        set    bill_hold_flag='N'
        where  expenditure_item_id = Bill_Hold_Rec.expenditure_item_id
	and    adl_line_num        = Bill_Hold_Rec.adl_line_num
	and    award_id		   = Bill_Hold_Rec.award_id
	and    document_type='EXP'
	and    adl_status = 'A';
*/

        update pa_expenditure_items_all
	set    bill_hold_flag='N'
        where  expenditure_item_id = Bill_Hold_Rec.expenditure_item_id;

       if sql%notfound then

          gms_error_pkg.gms_message('GMS_NO_UPD_AWD_EXP_ADL',
				'AWD',
				Bill_Hold_Rec.award_id,
				'EXP',
				Bill_Hold_Rec.expenditure_item_id,
				'ADL',
				Bill_Hold_Rec.adl_line_num,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
         --RAISE_APPLICATION_ERROR(-20501,X_Err_Buff);
         EXIT;
      else
         X_Err_Code := 0;
      End if;

    End loop;

    -- Commit; -- Moved to Award_Billing

End ONE_TIME_BILL_HOLD;

-- PROCEDURE INSTALLMENT_AMOUNT, new procedure for storing amounts on installments

PROCEDURE INSTALLMENT_AMOUNT(X_Installment_id	IN NUMBER,
			     X_Rev_Bill_Amt	IN NUMBER,
			     X_Inst_amt		IN OUT NOCOPY Inst_tab2,
                             X_Actual_Project_Id IN NUMBER,
                             X_Task_Id          IN NUMBER,
			     X_Err_Code		IN OUT NOCOPY NUMBER,
			     X_Err_Buff		IN OUT NOCOPY VARCHAR2) IS
X_Count_Rec	NUMBER;
X_Counter 	NUMBER :=0;
X_match		VARCHAR2(1) := 'N';
Begin
   X_Count_Rec :=  X_inst_amt.COUNT;

   IF L_DEBUG = 'Y' THEN
   	gms_error_pkg.gms_debug('INSTALLMENT_AMOUNT - X_Count_Rec:'||X_Count_Rec,'C');
   END IF;

   If nvl(X_Count_rec,0) > 0 then

   IF L_DEBUG = 'Y' THEN
   	gms_error_pkg.gms_debug('INSTALLMENT_AMOUNT - If nvl(X_Count_rec,0) > 0','C');
   END IF;

    for X_Rec_Count in 1..X_Count_Rec
    loop

        IF L_DEBUG = 'Y' THEN
        	gms_error_pkg.gms_debug('INSTALLMENT_AMOUNT - IN LOOP','C');
        END IF;

        X_Counter:= X_Counter+1;

	if    (X_inst_amt(X_Counter).installment_id = X_Installment_id
           and X_inst_amt(X_Counter).actual_project_id = X_Actual_Project_Id
           and nvl(X_inst_amt(X_Counter).actual_task_id,0) = nvl(X_Task_Id,0))
        then
           X_inst_amt(X_Counter).rev_bill_amount := X_inst_amt(X_Counter).rev_bill_amount + X_Rev_Bill_Amt;
    	   X_match := 'Y';

           IF L_DEBUG = 'Y' THEN
           	gms_error_pkg.gms_debug('INSTALLMENT_AMOUNT - IN LOOP - IN IF ','C');
           	gms_error_pkg.gms_debug('INSTALLMENT_AMOUNT - IN LOOP - IN IF installment_id:'||X_inst_amt(X_Counter).installment_id,'C');
           	gms_error_pkg.gms_debug('INSTALLMENT_AMOUNT - IN LOOP - IN IF actual_project_id:'||X_inst_amt(X_Counter).actual_project_id,'C');
           	gms_error_pkg.gms_debug('INSTALLMENT_AMOUNT - IN LOOP - IN IF actual_task_id:'||X_inst_amt(X_Counter).actual_task_id,'C');
           	gms_error_pkg.gms_debug('INSTALLMENT_AMOUNT - IN LOOP - IN IF rev_bill_amount:'||X_Rev_Bill_Amt,'C');
           END IF;

	   exit;
	end if;

    end loop;

   End if;   -- nvl(X_Counter,0) > 0

   if X_match ='N' then

      X_inst_amt(nvl(X_Counter,0) + 1).installment_id := X_Installment_id;
      X_inst_amt(nvl(X_Counter,0) + 1).rev_bill_amount :=  X_Rev_Bill_Amt;
      X_inst_amt(nvl(X_Counter,0) + 1).actual_project_id := X_Actual_Project_Id;
      X_inst_amt(nvl(X_Counter,0) + 1).actual_task_id := X_Task_Id;

        IF L_DEBUG = 'Y' THEN
        	gms_error_pkg.gms_debug('INSTALLMENT_AMOUNT - IN LOOP - IN NO ','C');
        	gms_error_pkg.gms_debug('INSTALLMENT_AMOUNT - IN LOOP - IN NO installment_id:'||X_Installment_id,'C');
        	gms_error_pkg.gms_debug('INSTALLMENT_AMOUNT - IN LOOP - IN NO actual_project_id:'||X_Actual_Project_Id,'C');
        	gms_error_pkg.gms_debug('INSTALLMENT_AMOUNT - IN LOOP - IN NO actual_task_id:'||X_Task_Id,'C');
        	gms_error_pkg.gms_debug('INSTALLMENT_AMOUNT - IN LOOP - IN NO X_Rev_Bill_Amt:'||X_Rev_Bill_Amt,'C');
        END IF;

   end if;

   X_Err_Code := 0;

Exception
  WHEN OTHERS THEN
      gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      --RAISE_APPLICATION_ERROR(-20502,X_Err_Buff);
      --RETURN;

End INSTALLMENT_AMOUNT;

------------------------------------------------------------------------------
/* New Procedure added for bug 5242484 */

PROCEDURE EI_ROLLBACK (
   x_award_id   IN       NUMBER,
   x_event_type    IN       VARCHAR2,
   x_expenditure_item_id IN NUMBER,
   x_adl_line_num IN NUMBER,
   x_actual_project_id IN NUMBER,
   x_task_id IN NUMBER,
   x_inst_cnt IN NUMBER
    )
IS

x_award_project_id NUMBER := 0;
i NUMBER := 0;


BEGIN

/* --------------------------------------------------------------------------
|| Here's what we need to do :
|| 1. Updating gms_summary_project_fundings
|| 2. Deleting from gms_event_intersect
|| 3. Deleting from gms_burden_components
|| 4. Updating gms_award_distributions (revenue_distributed_flag/billed_flag)
   -------------------------------------------------------------------------- */

select award_project_id
into x_award_project_id
from gms_awards_all where award_id = x_award_id ;


    FOR i in 1..x_inst_cnt
    LOOP
    UPDATE gms_summary_project_fundings
                  SET total_billed_amount = decode(x_event_type,'INVOICE',
                         (total_billed_amount - X_ei_rollback_inst_tab(i).rev_bill_amount),total_billed_amount),
                      total_revenue_amount = decode(x_event_type,'REVENUE',
                         (total_revenue_amount - X_ei_rollback_inst_tab(i).rev_bill_amount),total_revenue_amount)
                WHERE project_id = x_actual_project_id
                  AND (   task_id IS NULL
                       OR task_id = x_task_id
                       OR task_id = (select t.top_task_id
                                     from   PA_TASKS t
                                     where  t.task_id = x_task_id)
                       )
                  AND installment_id = X_ei_rollback_inst_tab(i).installment_id ;

    END LOOP;

    UPDATE gms_award_distributions
                  SET revenue_distributed_flag = decode(x_event_type,'REVENUE','N',revenue_distributed_flag),
		      billed_flag = decode(x_event_type,'INVOICE','N',billed_flag),
                      last_update_date = SYSDATE,
                      last_updated_by = fnd_global.user_id,
                      last_update_login = fnd_global.login_id
                WHERE expenditure_item_id = x_expenditure_item_id
		  AND document_type = 'EXP'
                  AND adl_status = 'A'
		  AND ( expenditure_item_id,adl_line_num ) in ( select expenditure_item_id, adl_line_num
		                                                from gms_Event_intersect
								where expenditure_item_id = x_expenditure_item_id
                                                                AND award_project_id = x_award_project_id
                                                        	AND event_num is NULL
                                                                AND event_type = x_event_type
								union
								select expenditure_item_id, adl_line_num
		                                                from gms_burden_components
								where expenditure_item_id = x_expenditure_item_id
                                                                AND award_project_id = x_award_project_id
                                                        	AND event_num is NULL
                                                                AND event_type = x_event_type );

    DELETE FROM gms_event_intersect
             WHERE expenditure_item_id = x_expenditure_item_id
               AND award_project_id = x_award_project_id
               AND event_num is NULL
	       AND event_type = x_event_type ;


   DELETE FROM gms_burden_components
             WHERE expenditure_item_id = x_expenditure_item_id
               AND award_project_id = x_award_project_id
	       AND event_num IS NULL
               AND event_type = x_event_type ;

END ei_rollback;

/* End of new procedure for bug 5242484 */

-------------------------------------------------------------------------------
PROCEDURE  GET_SUMM_FUNDING(C_Installment_Id          IN NUMBER,
                            X_Expenditure_item_date   IN DATE DEFAULT NULL,
                            X_Award_Id                IN NUMBER DEFAULT NULL,
                            X_Task_Id                 IN NUMBER,
                            X_Calling_Process         IN VARCHAR2,
                            X_Total_Funding_Amount    OUT NOCOPY NUMBER,
                            X_Total_Rev_Bill_Amount   OUT NOCOPY NUMBER,
                            X_Err_Code                IN OUT NOCOPY NUMBER,
                            X_Err_Buff                IN OUT NOCOPY VARCHAR2) IS

Begin
 select
 sum(total_funding_amount),
 sum(decode(X_Calling_Process,'Invoice',nvl(gmf.total_billed_amount,0),
        'Revenue',nvl(gmf.total_revenue_amount,0) ))
 into
 X_Total_Funding_Amount,
 X_Total_Rev_Bill_Amount
 from
 gms_summary_project_fundings gmf
 where
 (gmf.installment_id = nvl(C_Installment_Id,0)   -- 11.5 changes, hard limit to award level
  OR
  (C_Installment_Id is NULL
   AND gmf.installment_id in
       (select installment_id
        from gms_installments
        where  award_id = X_award_id
        and (trunc(end_date_Active) >= trunc(X_Expenditure_item_date))
	/* and active_flag = 'Y'  Bug 6878405 */
        and nvl(billable_flag,'N') = 'Y'
        --order by end_date_active
       )
   )
  )
 and (
      (gmf.task_id  = X_Task_Id)
 OR   (gmf.task_id is NULL)
 OR   (gmf.task_id = (select t.top_task_id from PA_TASKS t where t.task_id = X_Task_Id))
     )
 and gmf.project_id     = (select project_id from PA_TASKS where task_id = X_Task_Id);


 --t.task_id = decode(gmf.task_id,null,t.task_id,gmf.task_id);

X_Err_Code := 0;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
    X_Err_Code := 0;
    X_Total_Funding_Amount   := -99;
    X_Total_Rev_Bill_Amount  := -99;
END GET_SUMM_FUNDING;
--------------------------------------------------------------------------------

-- PROCEDURE: INSTALLMENT_CHECK, new procedure for Installment Check

PROCEDURE INSTALLMENT_CHECK(X_Installment_id	    IN NUMBER,
			    X_Award_Id		    IN NUMBER,
			    X_Task_Id		    IN NUMBER,
			    X_Calling_Process       IN VARCHAR2,
			    X_Expenditure_item_date IN DATE,
			    X_Money_In_Inst         IN NUMBER,
			    X_Money_In_Curr_Inst    OUT NOCOPY NUMBER,
			    X_Inst_Flag             OUT NOCOPY VARCHAR2,
			    X_Err_Code		    IN OUT NOCOPY NUMBER,
			    X_Err_Buff		    IN OUT NOCOPY VARCHAR2) IS
X_temp_flag  NUMBER;
X_Total_Funding_Amount NUMBER(22,5);
X_Total_Rev_Bill_Amount NUMBER(22,5);

Begin

	   GET_SUMM_FUNDING(X_Installment_id,
                            X_Expenditure_Item_Date,
                            X_Award_Id,
                            X_Task_Id,
                            X_calling_process,
                            X_Total_Funding_Amount,
                            X_Total_Rev_Bill_Amount,
   			    X_Err_Code,
			    X_Err_Buff);

          X_Money_In_Curr_Inst :=  X_Total_Funding_Amount - X_Total_Rev_Bill_Amount;

  If X_Money_In_Curr_Inst >= 0 then /* Changed to 'greater than or equal to' for bug 5349106 */

      X_Inst_Flag := 'A';    -- Money Available on current Installment

  else
      If X_Money_In_Inst > 0 then

          X_Inst_Flag := 'I';    -- Money Available on other Installment

      elsif X_Money_In_Inst <= 0 then

          X_Inst_Flag := 'N';    -- No other Installment exists

      End if;
  End if;

 X_Err_Code := 0;

EXCEPTION
    WHEN OTHERS THEN
      gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      --RAISE_APPLICATION_ERROR(-20503,X_Err_Buff);
      --RETURN;
End INSTALLMENT_CHECK;

--ETAX Enhancement : Replace the Output_Vat_tax_id with Output_Tax_Classification_code
-- PROCEDURE: GMS_TAX,  new procedure to calculate Tax Details for ADL

PROCEDURE GMS_TAX(X_Award_Project_Id IN NUMBER,
		  X_Award_Id	     IN NUMBER,
		  X_Rev_Or_Bill_Date IN DATE,
		  X_Request_Id	     IN NUMBER,
		  X_Err_Code         IN OUT NOCOPY NUMBER,
		  X_Err_Buff         IN OUT NOCOPY VARCHAR2) IS

X_Customer_Id 		pa_project_customers.customer_id%type;
X_Bill_To_Site_Use_Id  hz_cust_site_uses.site_use_id%type;
X_Ship_To_Site_Use_Id  hz_cust_site_uses.site_use_id%type;

/* This Cursor fetches expenditure items for which tax codes has to be calculated */
Cursor get_exp_items is
       select --distinct
	      adl.expenditure_item_id,
	      adl.adl_line_num,
              adl.award_id
       from   pa_expenditure_items_all ei,
	      pa_projects_all p,
   	      pa_project_types pt,
	      pa_tasks t3,
	      pa_tasks t5,
	      gms_award_distributions adl
       where  adl.award_id = X_Award_Id
       and    ei.expenditure_item_id = adl.expenditure_item_id
       and    ei.system_linkage_function <> 'BTC'
       and    p.project_status_code <> 'CLOSED'
       and    pt.project_type = p.project_type
       and    pt.direct_flag = 'N'
       and    t3.project_id = p.project_id
       and    ei.task_id = t3.task_id
       and    t3.top_task_id = t5.task_id
       and    t5.ready_to_bill_flag = 'Y'
       and    adl.cost_distributed_flag = 'Y'
       and    ei.expenditure_item_date <= nvl(trunc(X_rev_or_bill_date),SYSDATE)
       and    adl.billed_flag = 'N' /* removed nvl for bug 6969435 */
       and    adl.document_type='EXP'
       and    adl.adl_status = 'A'
       and    adl.fc_status = 'A'
       and    adl.output_tax_exempt_flag is null;

-- Last clause, so that tax is calculated once for an ADL, either in Revenue or Invoice Process

F_Expenditure_Item_Id   gms_award_distributions.expenditure_item_id%type;
F_Adl_Line_Num          gms_award_distributions.adl_line_num%type;
F_Award_Id		gms_award_distributions.award_id%type;

--S_Output_Vat_Tax_Id 	    gms_award_distributions.output_vat_tax_id%type;	 --Changes for ETax
S_Output_Tax_classify_code    gms_award_distributions.output_tax_classification_code%type; --Changes for ETax
S_Output_Tax_Exempt_Flag    gms_award_distributions.output_tax_exempt_flag%type;
S_Output_Tax_Exempt_Number  gms_award_distributions.output_tax_exempt_number%type;
S_Output_Exempt_Reason_Code gms_award_distributions.output_tax_exempt_reason_code%type;

X_Set_Of_Book_Id NUMBER(15);

-- Bug Fix 2994625
-- Added new local variables to store bill_to_customer_id and ship_to_customer_id

l_Bill_to_customer_id PA_PROJECT_CUSTOMERS.BILL_TO_CUSTOMER_ID%TYPE;
l_Ship_to_customer_id PA_PROJECT_CUSTOMERS.SHIP_TO_CUSTOMER_ID%TYPE;

-- End of Fix for Bug 2994625

Begin

   X_Err_Code := 0;

-- STAGE 10 : GET SOB ID FROM PA_IMPLEMENTATIONS
   Begin

     select set_of_books_id
     into   X_Set_Of_Book_Id
     from   pa_implementations;

   Exception
    WHEN NO_DATA_FOUND THEN
      gms_error_pkg.gms_message('GMS_SOB_ID_NOT_FOUND',
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      --RAISE_APPLICATION_ERROR(-20504,X_Err_Buff);
      RETURN;
   End;

-- STAGE 20: RETRIEVE CUSTOMER AND SITE INFORMATION

-- Bug Fix 2994625
-- Storing the bill_to_customer_id and ship_to_customer_id in the local variables
-- End of Fix 2994625.
--TCA Enhancement :Changed the reference from RA tables to HZ tables
    Begin

       select distinct
	      c.customer_id,
              c.bill_to_customer_id,
              c.ship_to_customer_id,
	      ras.site_use_id,
	      ras1.site_use_id
	into  X_Customer_id,
              l_bill_to_customer_id,
              l_ship_to_customer_id,
	      X_Bill_To_Site_Use_Id,
	      X_Ship_To_Site_Use_Id
	from  pa_project_customers c,
     hz_cust_accounts cust_acct,
     hz_cust_site_uses ras,
                            hz_cust_site_uses ras1
	where c.project_id = X_Award_Project_Id
--	and   c.customer_id = rc.customer_id
--	and   nvl(rc.status,'A') = 'A'
          and      c.customer_id = cust_acct.cust_account_id
            and      nvl(cust_acct.status,'A') = 'A'
	and   c.customer_bill_split <> 0
	--and   ras.address_id = c.bill_to_address_id
           and   ras.cust_acct_site_id = c.bill_to_address_id
       and   ras.site_use_code || '' = 'BILL_TO'
       and   ras.status || '' = 'A'
--       and   ras1.address_id = c.ship_to_address_id
       and   ras1. cust_acct_site_id = c.ship_to_address_id
       and   ras1.site_use_code || '' = 'SHIP_TO'
       and   ras1.status || '' = 'A';

   EXCEPTION
    WHEN NO_DATA_FOUND THEN
      gms_error_pkg.gms_message('GMS_NO_SITE_CUST',
				'PRJ',
				X_Award_Project_Id,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      --RAISE_APPLICATION_ERROR(-20505,X_Err_Buff);
      RETURN;

    WHEN TOO_MANY_ROWS THEN
      gms_error_pkg.gms_message('GMS_MORE_THAN_ONE_SITE_CUST',
                                'PRJ',
                                X_Award_Project_Id,
                                X_Exec_Type => 'C',
                                X_Err_Code => X_Err_Code,
                                X_Err_Buff => X_Err_Buff);
      --RAISE_APPLICATION_ERROR(-20506,X_Err_Buff);
      RETURN;

    WHEN OTHERS THEN
      gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      --RAISE_APPLICATION_ERROR(-20507,X_Err_Buff);
      RETURN;
  End;


-- STAGE 30:  OPEN CURSOR TO FETCH RECORDS FROM ADL TABLE

  Open  get_exp_items;
  Loop
	Fetch get_exp_items into F_Expenditure_Item_Id, F_Adl_Line_Num, F_Award_Id;
	Exit When get_exp_items%NOTFOUND;

-- STAGE 40:  CALL PA'S TAX CALCULATION PROCEDURE

-- Bug Fix 2994625
-- passing the bill_to_customer_id and ship_to_customer_id in the call to pa_output_tax.get_default_tax_info.
-- End of Fix 2994625.

     pa_output_tax.get_default_tax_info(p_project_id  			=> X_Award_Project_Id,
				        P_Draft_Inv_Num 		=> NULL, 		-- Invoice number
					P_Customer_Id	 		=> X_Customer_Id,
					P_Bill_to_site_use_id 		=> X_Bill_To_Site_Use_Id,
					P_Ship_to_site_use_id 		=>X_Ship_To_Site_Use_Id,
					P_Sets_of_books_id 		=> X_Set_Of_Book_Id,
					P_Event_id  			=> NULL, 		-- Event Number
					P_Expenditure_item_id 		=>F_Expenditure_Item_Id,
					P_User_Id 			=> fnd_global.user_id,
					P_Request_id  			=> X_Request_id,
					--S_Output_Vat_Tax_Id,
					X_Output_tax_exempt_flag    	=> S_Output_Tax_Exempt_Flag,
					X_Output_tax_exempt_number  	=> S_Output_Tax_Exempt_number,
					X_Output_exempt_reason_code 	=> S_Output_Exempt_Reason_Code,
					X_Output_tax_code          	=> S_Output_Tax_classify_code,
                                        Pbill_to_customer_id      	=> l_bill_to_customer_id,
                                        Pship_to_customer_id		=> l_ship_to_customer_id
					);

-- STAGE 50: UPDATE ADL LINES WITH TAX INFORMATION

   Begin

	Update  gms_award_distributions
	set
		--output_vat_tax_id = S_Output_Vat_Tax_Id,
		output_tax_classification_code = S_Output_tax_classify_code,
		output_tax_exempt_flag 		 = S_Output_Tax_Exempt_Flag,
		output_tax_exempt_number 	 = S_Output_Tax_Exempt_Number,
		output_tax_exempt_reason_code  = S_Output_Exempt_Reason_Code,
		last_update_date 			 = sysdate,
		last_update_login 		 = fnd_global.login_id,
		last_updated_by 			 = fnd_global.user_id
	where   expenditure_item_id 		 = F_Expenditure_Item_Id
	and     adl_line_num 			 = F_Adl_Line_Num
      and   award_id 			 	 = X_Award_Id
	and     document_type			 ='EXP'
	and     adl_status 			 = 'A'
	and     output_tax_exempt_flag is null;


      If SQL%ROWCOUNT = 0 then
        gms_error_pkg.gms_message('GMS_NO_UPD_AWD_EXP',
				'AWD',
				X_Award_Id,
				'EXP',
				F_Expenditure_Item_Id,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
        --RAISE_APPLICATION_ERROR(-20508,X_Err_Buff);
        RETURN;
      Else
         X_Err_Code := 0;
      End If;
    End;

 End Loop; -- get_exp_items

  X_Err_Code := 0;

End GMS_TAX;

-- PROCEDURE: GET_INSTALLMENT_NUM, new procedure to get Installment Number's in case of splits

PROCEDURE GET_INSTALLMENT_NUM(X_Installment_id        IN NUMBER,
                              X_Award_Id              IN NUMBER,
		              X_Task_Id		      IN NUMBER,
                              X_Expenditure_item_date IN DATE,
			      X_Calling_Process	      IN VARCHAR2,
                              X_Money_In_Inst         IN NUMBER,
			      X_Inst_Task_Run_Total   IN NUMBER,
                              X_Inst_Flag             IN VARCHAR2,
			      X_Inst_tab	      OUT NOCOPY Inst_tab,
			      X_Inst_Count	      OUT NOCOPY NUMBER,
                              X_Err_Code              IN OUT NOCOPY NUMBER,
                              X_Err_Buff              IN OUT NOCOPY VARCHAR2) IS

X_Count       NUMBER(2) :=0;
X_Diff_Amount NUMBER(22,5) :=0;
X_Fund_Amt    NUMBER(22,5) :=0;
X_Total_Amt   NUMBER(22,5) :=0;
X_RB_Amt      NUMBER(22,5) :=0;
X_Installment NUMBER(15);

Cursor Inst_Id is
       select ins.installment_id installment_id,
	      gmf.total_funding_amount total_funding_amount,
decode(X_Calling_Process,'Invoice',nvl(gmf.total_billed_amount,0),'Revenue',nvl(gmf.total_revenue_amount,0)) Inv_Rev_Amount
       from   gms_installments ins,
              gms_summary_project_fundings gmf
       where  ins.award_id = X_award_id
       and trunc(ins.end_date_active) >= trunc(X_Expenditure_item_date)
      /* and ins.active_flag = 'Y' Bug 6878405  */
       and nvl(ins.billable_flag,'N') = 'Y'
       and ins.Installment_id = gmf.Installment_id
       and (gmf.total_funding_amount - decode(X_Calling_Process,'Invoice',nvl(gmf.total_billed_amount,0),
            'Revenue',nvl(gmf.total_revenue_amount,0) )) >0
       and ((gmf.task_id  = X_Task_Id)
            OR (gmf.task_id is NULL)
            OR (gmf.task_id = (select t.top_task_id from PA_TASKS t where t.task_id = X_Task_Id))
            )
       and gmf.project_id     = (select project_id from PA_TASKS where task_id = X_Task_Id)
       and ins.installment_id <> X_Installment_id
       order by ins.end_date_active;

Begin

 X_Inst_tab.delete; -- initialize

 X_Inst_Count:=0;

 If X_Inst_Flag = 'N' then

    X_Inst_Count :=1;
    X_Diff_Amount :=0;

 Else

   If X_Money_In_Inst >= X_Inst_Task_Run_Total then

      X_Inst_Count :=1;
      X_Diff_Amount :=0;
   Else
/* Added IF for bug 5349106 */
IF X_Inst_flag = 'A' then

      X_Inst_Count :=1;

      X_Inst_tab(X_Inst_Count).Installment_id  := X_Installment_id;
      X_Inst_tab(X_Inst_Count).Rev_Bill_Amount := X_Money_In_Inst;

      X_Diff_Amount := X_Inst_Task_Run_Total - X_Money_In_Inst;
End If;  /* For Bug 5349106 */

      Open Inst_Id;
      Loop
      Fetch Inst_id into X_Installment, X_Total_Amt, X_RB_Amt;
      exit when Inst_id%notfound;

         X_Inst_Count := X_Inst_Count + 1;

         X_Fund_Amt := X_Total_Amt - X_RB_Amt ;

         If X_Fund_Amt > X_Diff_Amount then

	    X_Inst_tab(X_Inst_Count).Installment_id  := X_Installment;
	    X_Inst_tab(X_Inst_Count).Rev_Bill_Amount := X_Diff_Amount;
	    X_Diff_Amount := 0;
	    exit; -- exit loop

         Else

	    X_Inst_tab(X_Inst_Count).Installment_id  := X_Installment;
            X_Inst_tab(X_Inst_Count).Rev_Bill_Amount := X_Fund_Amt;

            X_Diff_Amount := X_Diff_Amount - X_Fund_Amt;

         End if;
      End Loop;

      Close Inst_Id;
    End if; -- X_Money_In_Inst >= X_Inst_Task_Run_Total then
  End if;  --  X_Inst_Flag = 'N' then

      If  X_Diff_Amount > 0 then

         X_Inst_tab(X_Inst_tab.Last).Rev_Bill_Amount := X_Inst_tab(X_Inst_tab.Last).Rev_Bill_Amount + X_Diff_Amount;

     End if;

     X_Err_Code := 0;

EXCEPTION
    WHEN OTHERS THEN
      gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      --RAISE_APPLICATION_ERROR(-20509,X_Err_Buff);
      RETURN;

End GET_INSTALLMENT_NUM;


-- PROCEDURE: INSERT_EVENT, new procedure to insert records into GMS_EVENT_ATTRIBUTE table

PROCEDURE INSERT_EVENT(X_AWARD_PROJECT_ID      IN NUMBER       DEFAULT NULL,
                        X_EVENT_NUM             IN NUMBER       DEFAULT NULL,
                        X_INSTALLMENT_ID        IN NUMBER       DEFAULT NULL,
                        X_ACTUAL_PROJECT_ID     IN NUMBER       DEFAULT NULL,
                        X_ACTUAL_TASK_ID        IN NUMBER       DEFAULT NULL,
                        X_BURDEN_COST_CODE      IN VARCHAR2     DEFAULT NULL,
                        X_EXPENDITURE_ORG_ID    IN NUMBER       DEFAULT NULL,
                        X_BILL_AMOUNT           IN NUMBER       DEFAULT NULL,
                        X_REVENUE_AMOUNT        IN NUMBER       DEFAULT NULL,
                        X_REQUEST_ID            IN NUMBER       DEFAULT NULL,
                        X_EXPENDITURE_TYPE      IN VARCHAR2     DEFAULT NULL,
                        X_Err_Code              IN OUT NOCOPY NUMBER,
                        X_Err_Buff              IN OUT NOCOPY VARCHAR2,
			X_Calling_Process	IN VARCHAR2     DEFAULT NULL) IS

Begin
	/* Insert into GMS_EVENT_ATTRIBUTE_TABLE */

	INSERT INTO GMS_EVENT_ATTRIBUTE(
		PROJECT_ID,
		EVENT_NUM,
		INSTALLMENT_ID,
		ACTUAL_PROJECT_ID,
		ACTUAL_TASK_ID,
		BURDEN_COST_CODE,
		EXPENDITURE_ORG_ID,
		BILL_AMOUNT,
		REVENUE_AMOUNT,
		WRITE_OFF_AMOUNT,
		CREATED_BY,
		CREATED_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN,
		REVENUE_ACCUMULATED,
		RESOURCE_LIST_MEMBER_ID,
		REQUEST_ID,
		EXPENDITURE_TYPE,
		EVENT_CALLING_PROCESS)
	 VALUES(X_AWARD_PROJECT_ID,
		X_EVENT_NUM,
		X_INSTALLMENT_ID,
		X_ACTUAL_PROJECT_ID,
		X_ACTUAL_TASK_ID,
		X_BURDEN_COST_CODE,
		X_EXPENDITURE_ORG_ID,
		NVL(X_BILL_AMOUNT,0),
		NVL(X_REVENUE_AMOUNT,0),
		0, 			-- Write_Off_Amount
		fnd_global.user_id,
		sysdate,
		fnd_global.user_id,
		sysdate,
		fnd_global.login_id,
		'N',			-- Revenue_Accumulated
		NULL,			-- RLMI
		X_REQUEST_ID,
		X_EXPENDITURE_TYPE,
		X_Calling_Process
	       );

      X_Err_Code := 0;

Exception
    WHEN OTHERS THEN
      gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      --RAISE_APPLICATION_ERROR(-20510,X_Err_Buff);
      RETURN;

End INSERT_EVENT;


-- PROCEDURE: UPDATE_EVENT, new procedure to update GMS_EVENT_ATTRIBUTE table records

PROCEDURE UPDATE_EVENT(X_AWARD_PROJECT_ID      IN NUMBER       DEFAULT NULL,
                        X_EVENT_NUM             IN NUMBER       DEFAULT NULL,
                        X_INSTALLMENT_ID        IN NUMBER       DEFAULT NULL,
                        X_ACTUAL_PROJECT_ID     IN NUMBER       DEFAULT NULL,
                        X_ACTUAL_TASK_ID        IN NUMBER       DEFAULT NULL,
                        X_BURDEN_COST_CODE      IN VARCHAR2     DEFAULT NULL,
                        X_EXPENDITURE_ORG_ID    IN NUMBER       DEFAULT NULL,
                        X_BILL_AMOUNT           IN NUMBER       DEFAULT NULL,
                        X_REVENUE_AMOUNT        IN NUMBER       DEFAULT NULL,
                        X_REQUEST_ID            IN NUMBER       DEFAULT NULL,
                        X_EXPENDITURE_TYPE      IN VARCHAR2     DEFAULT NULL,
                        X_Err_Code              IN OUT NOCOPY NUMBER,
                        X_Err_Buff              IN OUT NOCOPY VARCHAR2) IS

Begin
	/* Update GMS_EVENT_ATTRIBUTE record */

	UPDATE  GMS_EVENT_ATTRIBUTE
	SET     installment_id     = X_INSTALLMENT_ID,
		actual_project_id  = X_ACTUAL_PROJECT_ID,
		actual_task_id     = X_ACTUAL_TASK_ID,
		burden_cost_code   = X_BURDEN_COST_CODE,
		expenditure_org_id = X_EXPENDITURE_ORG_ID,
		bill_amount        = nvl(X_BILL_AMOUNT,0),
		revenue_amount     = nvl(X_REVENUE_AMOUNT,0),
	        expenditure_type   = X_EXPENDITURE_TYPE,
		last_updated_by    = fnd_global.user_id,
		last_update_date   = sysdate,
		last_update_login  = fnd_global.login_id,
		request_id	   = X_REQUEST_ID
	WHERE   project_id	   = X_AWARD_PROJECT_ID
	AND	event_num          = X_EVENT_NUM
        AND     event_calling_process IS NULL; --Added for bug 2979125

    If SQL%ROWCOUNT = 0 then

      gms_error_pkg.gms_message('GMS_NO_UPD_PRJ_EVT',
				'PRJ',
				X_AWARD_PROJECT_ID,
				'EVT',
				X_EVENT_NUM,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      --ROLLBACK;
      --RAISE_APPLICATION_ERROR(-20511,X_Err_Buff);
      --Raise NO_PROCESSING_OF_AWARD ;

      RETURN;

    Else
        X_Err_Code := 0;
    End If;

END UPDATE_EVENT;

-- PROCEDURE: DELETE_EVENT, new procedure to delete records from GMS_EVENT_ATTRIBUTE table

PROCEDURE DELETE_EVENT (X_AWARD_PROJECT_ID      IN NUMBER,
                        X_EVENT_NUM             IN NUMBER,
                        X_INSTALLMENT_ID        IN NUMBER,
                        X_Err_Code              IN OUT NOCOPY NUMBER,
                        X_Err_Buff              IN OUT NOCOPY VARCHAR2) IS

Begin
        /* Delete from GMS_EVENT_ATTRIBUTE_TABLE */

	DELETE
	FROM   gms_event_attribute
	WHERE  project_id = X_AWARD_PROJECT_ID
	AND    event_num  = X_EVENT_NUM
	AND    installment_id = X_INSTALLMENT_ID
        AND    event_calling_process IS NULL; --Added for bug 2979125

    If SQL%ROWCOUNT = 0 then
      gms_error_pkg.gms_message('GMS_NO_DATA_PRJ_EVT_INST',
				'PRJ',
				X_AWARD_PROJECT_ID,
				'EVT',
				X_EVENT_NUM,
				'INST',
				X_Installment_Id,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      --ROLLBACK;
      --RAISE_APPLICATION_ERROR(-20512,X_Err_Buff);
	--Raise NO_PROCESSING_OF_AWARD ;
       -- RETURN;
    Else
        X_Err_Code := 0;
    End If;

END DELETE_EVENT;

-- FUNCTION get_total_adl_raw_cost is a  new procedure to get the total billable amount from ADL
-- Bug 3235390

FUNCTION get_total_adl_raw_cost( x_billing_type IN VARCHAR2,
                                 X_EXPENDITURE_ITEM_ID IN NUMBER ) RETURN NUMBER IS
l_raw_cost  NUMBER:=NULL;
BEGIN

    IF L_DEBUG = 'Y' THEN
          gms_error_pkg.gms_debug('IN get_total_adl_raw_cost - Start ','C');
    END IF;

     SELECT  NVL(SUM(raw_cost),0)
     INTO    l_raw_cost
     FROM    gms_award_distributions
     WHERE   expenditure_item_id      =  X_Expenditure_item_id
     AND     document_type            = 'EXP'   -- To pick up only actuals and not encumbrances
     AND     adl_status               = 'A'
     AND     fc_status                = 'A'
     AND     billable_flag            = 'Y';

    RETURN l_raw_cost;

EXCEPTION
    WHEN OTHERS THEN

        IF L_DEBUG = 'Y' THEN
          gms_error_pkg.gms_debug('IN get_total_adl_raw_cost - WHEN OTHERS ','C');
        END IF;
        RETURN l_raw_cost;

END get_total_adl_raw_cost;


--PROCEDURE EVENT_WARPPER, new procedure to build installment num for event desc and create event_attribute record

PROCEDURE EVENT_WRAPPER(X_Award_Project_Id      IN NUMBER,
			X_Actual_Project_Id	IN NUMBER,
                        X_Task_Id               IN NUMBER,
                        X_Calling_Process       IN VARCHAR2,
                        X_Evt_Amount            IN NUMBER,
                        X_Installment_Total     IN OUT NOCOPY Inst_tab2,
--                      X_Evt_Inst_Num          OUT NOCOPY VARCHAR2,     -- Bug 2380344
                        X_Burden_Cost_Code      IN VARCHAR2 DEFAULT NULL,
                        X_Exp_Org_Id            IN NUMBER DEFAULT NULL,
			X_Request_Id		IN NUMBER DEFAULT NULL,
                        X_Err_Code              IN OUT NOCOPY NUMBER,
                        X_Err_Buff              IN OUT NOCOPY VARCHAR2) IS

X_Row_Count 	NUMBER:=0;
X_Diff_Amount   NUMBER(22,5) :=0;
X_Bill_Amount   NUMBER(22,5) :=0;
X_Rev_Amount    NUMBER(22,5) :=0;

x_plsql_installment_id number(15);
x_plsql_project_id     number(15);
x_plsql_task_id        number(15);
x_plsql_amount         number(22,5) :=0;
x_plsql_count          number := 0;

Begin

 IF L_DEBUG = 'Y' THEN
 	gms_error_pkg.gms_debug('-- Start Calculation Process --','C');
 END IF;

 X_Row_Count := X_Installment_Total.COUNT;

 X_Diff_Amount := X_Evt_Amount;

 IF L_DEBUG = 'Y' THEN
 	gms_error_pkg.gms_debug('X_Row_Count'||X_Row_Count,'C');
 	gms_error_pkg.gms_debug('X_Diff_Amount'||X_Diff_Amount,'C');
 	gms_error_pkg.gms_debug('X_Actual_Project_Id :'||X_Actual_Project_Id,'C');
 	gms_error_pkg.gms_debug('X_Task_Id  :'||X_Task_Id,'C');
 END IF;

If X_Row_Count > 0 then

-- Stage 1: Event_Desc Creation and Event_Attribute record creation

    for Rec_Count in 1..X_Row_Count
    loop

         IF L_DEBUG = 'Y' THEN
         	gms_error_pkg.gms_debug('PLSQL - APID:'||X_Installment_Total(Rec_Count).Actual_Project_Id,'C');
         	gms_error_pkg.gms_debug('PLSQL - ATID:'||X_Installment_Total(Rec_Count).Actual_Task_Id,'C');
	 	gms_error_pkg.gms_debug('X_Diff_Amount:'||X_Diff_Amount,'C');
	 	gms_error_pkg.gms_debug('X_Installment_Total(Rec_Count).Rev_bill_Amount:'||X_Installment_Total(Rec_Count).Rev_bill_Amount,'C');
	 END IF;

      If X_Installment_Total(Rec_Count).Actual_Project_Id = X_Actual_Project_Id and
         nvl(X_Installment_Total(Rec_Count).Actual_Task_Id,0) = X_Task_Id then

         x_plsql_installment_id := X_Installment_Total(Rec_Count).Installment_Id;
         x_plsql_project_id     := X_Installment_Total(Rec_Count).Actual_Project_Id;
         x_plsql_task_id        := X_Installment_Total(Rec_Count).Actual_Task_Id;
         x_plsql_count         := rec_count;

         IF L_DEBUG = 'Y' THEN
         	gms_error_pkg.gms_debug(' ---------rec_count----------- '||rec_count,'C');
        	gms_error_pkg.gms_debug('In If APID / ATID ','C');
        END IF;

        If X_Installment_Total(Rec_Count).Rev_bill_Amount > 0 then

        IF L_DEBUG = 'Y' THEN
        	gms_error_pkg.gms_debug('In If PLsql amt > 0','C');
        END IF;

         If X_Installment_Total(Rec_Count).Rev_bill_Amount >=  X_Diff_Amount then

           IF L_DEBUG = 'Y' THEN
           	gms_error_pkg.gms_debug('In If Plsql amt > diff ','C');
           END IF;

	   X_Installment_Total(Rec_Count).Rev_bill_Amount:=X_Installment_Total(Rec_Count).Rev_bill_Amount - X_Diff_Amount;

           /* Event Attribute Creation */

           If X_calling_Process = 'Invoice' then
	      X_Bill_Amount := X_Diff_Amount;
	      X_Rev_Amount := 0;
	   Elsif X_Calling_Process = 'Revenue' then
	      X_Bill_Amount := 0;
	      X_Rev_Amount := X_Diff_Amount;
	   End if;

           IF L_DEBUG = 'Y' THEN
           	gms_error_pkg.gms_debug('EVENT WRAPPER - BEFORE INSERT EVENT +VE PLSQL>DIFF','C');
           END IF;

           INSERT_EVENT(X_Award_Project_Id,
                     NULL,   -- event number
                     X_Installment_Total(Rec_Count).Installment_id,
                     X_Actual_Project_id,
                     X_Task_Id,
                     X_Burden_Cost_Code,
                     X_Exp_Org_Id,
                     X_Bill_Amount,
                     X_Rev_Amount,
		     X_Request_Id,
		     NULL,		-- expenditure type,
                     X_Err_Code,
                     X_Err_Buff,
		     X_calling_Process);

                If X_Err_Code <> 0 then
		        Raise NO_PROCESSING_OF_AWARD ;
                End If;

            IF L_DEBUG = 'Y' THEN
            	gms_error_pkg.gms_debug('EVENT WRAPPER - AFTER INSERT EVENT +VE PLSQL>DIFF','C');
            END IF;

           /* Event Attribute Creation */

           X_Diff_Amount:=0;

           exit;

        else --  X_Installment_Total(Rec_Count).Rev_bill_Amount >= X_Diff_Amount

           IF L_DEBUG = 'Y' THEN
           	gms_error_pkg.gms_debug('In Diff > Plsql','C');
           END IF;

	   -- =============================================================================
	   -- BUG:1714882 - GENERATE DRAFT INVOICES ON A RANGE OF AWARDS ORA-20154 CALCULATION ERROR
	   -- BUG:1689442 - CALCULATION ERROR IN REVENUE PROCESS
	   -- Following lines were commented out NOCOPY to resolve the fix.
	   -- ======================================================================================
           --X_Diff_Amount:= X_Diff_Amount - X_Installment_Total(Rec_Count).Rev_bill_Amount;
           --X_Installment_Total(Rec_Count).Rev_bill_Amount:=0;

	   -- ======================================================================================
	   -- Following lines were added to solve the fix.
	   -- ======================================================================================
           If x_plsql_count = X_Row_Count then
              X_Installment_Total(Rec_Count).Rev_bill_Amount:= X_Installment_Total(Rec_Count).Rev_bill_Amount - X_Diff_Amount ;
               X_plsql_amount := X_Diff_Amount;
         	   X_Diff_Amount := 0 ;

           Else
              X_Diff_Amount:= X_Diff_Amount - X_Installment_Total(Rec_Count).Rev_bill_Amount;
              X_plsql_amount := X_Installment_Total(Rec_Count).Rev_bill_Amount;
              X_Installment_Total(Rec_Count).Rev_bill_Amount:=0;

           End If;
	   -- ======================================================================================
	   -- END OF THE FIX.
	   -- ======================================================================================

            /* Event Attribute Creation */

           If X_calling_Process = 'Invoice' then
	      X_Bill_Amount := X_plsql_amount;
	      X_Rev_Amount := 0;
	   Elsif X_Calling_Process = 'Revenue' then
	      X_Bill_Amount := 0;
	      X_Rev_Amount := X_plsql_amount;
	   End if;

           IF L_DEBUG = 'Y' THEN
           	gms_error_pkg.gms_debug('EVENT WRAPPER - BEFORE INSERT EVENT +VE PLSQL<DIFF','C');
           END IF;

           INSERT_EVENT(X_Award_Project_Id,
                     NULL,   -- event number
                     X_Installment_Total(Rec_Count).Installment_id,
                     X_Actual_Project_id,
                     X_Task_Id,
                     X_Burden_Cost_Code,
                     X_Exp_Org_Id,
                     X_Bill_Amount,
                     X_Rev_Amount,
		     X_Request_Id,
		     NULL,		-- Expenditure_Type
                     X_Err_Code,
                     X_Err_Buff,
		     X_calling_Process);

                If X_Err_Code <> 0 then
                        --ROLLBACK;
                        --RAISE FND_API.G_EXC_ERROR;
			Raise NO_PROCESSING_OF_AWARD ;
                End If;

                IF L_DEBUG = 'Y' THEN
                	gms_error_pkg.gms_debug('EVENT WRAPPER - AFTER INSERT EVENT +VE PLSQL<DIFF','C');
                END IF;

           /* Event Attribute Creation */

        End if; -- X_Installment_Total(Rec_Count).Rev_bill_Amount >= X_Diff_Amount

           /* ----------------------------------------------------------------------------*/
        ELSIf ( X_Installment_Total(Rec_Count).Rev_bill_Amount < 0 ) then

           IF L_DEBUG = 'Y' THEN
           	gms_error_pkg.gms_debug('-ve amount','C');
           END IF;

           If X_calling_Process = 'Invoice' then
              X_Bill_Amount := X_Diff_Amount;
              X_Rev_Amount := 0;
           Elsif X_Calling_Process = 'Revenue' then
              X_Bill_Amount := 0;
              X_Rev_Amount := X_Diff_Amount;
           End if;

           IF L_DEBUG = 'Y' THEN
           	gms_error_pkg.gms_debug('EVENT WRAPPER - BEFORE INSERT EVENT -VE','C');
           END IF;

           INSERT_EVENT(X_Award_Project_Id,
                     NULL,   -- event number
                     X_Installment_Total(Rec_Count).Installment_id,
                     X_Actual_Project_id,
                     X_Task_Id,
                     X_Burden_Cost_Code,
                     X_Exp_Org_Id,
                     X_Bill_Amount,
                     X_Rev_Amount,
                     X_Request_Id,
                     NULL,              -- Expenditure_Type
                     X_Err_Code,
                     X_Err_Buff,
                     X_calling_Process);

                If X_Err_Code <> 0 then
			Raise NO_PROCESSING_OF_AWARD ;
                End If;

                 IF L_DEBUG = 'Y' THEN
                 	gms_error_pkg.gms_debug('EVENT WRAPPER - AFTER INSERT EVENT -VE','C');
                 END IF;

             IF X_Diff_Amount>0 THEN
                  IF L_DEBUG = 'Y' THEN
                  	gms_error_pkg.gms_debug('X_diff > 0','C');
                  END IF;
                   X_Installment_Total(Rec_Count).Rev_bill_Amount:=
                            X_Installment_Total(Rec_Count).Rev_bill_Amount - X_Diff_Amount;
             else
		   IF L_DEBUG = 'Y' THEN
		   	gms_error_pkg.gms_debug('X_Diff < 0','C');
		   END IF;
                   X_Installment_Total(Rec_Count).Rev_bill_Amount:=
                            X_Installment_Total(Rec_Count).Rev_bill_Amount + X_Diff_Amount;

             END IF;

             X_Diff_Amount := 0;
             /* ----------------------------------------------------------------------------*/

               -- --------------------------------------------------------------------
               -- Following code has been added for null events (event num -1)
               -- --------------------------------------------------------------------
        ELSIf ( X_Installment_Total(Rec_Count).Rev_bill_Amount  =  0 ) then

               -- -----------------------------------------------------------------------------
               If X_INVRAW_NULL_EVENT_PROCESSED THEN

                  IF L_DEBUG = 'Y' THEN
                  	gms_error_pkg.gms_debug('EVENT WRAPPER - BEFORE ZERO $ EVENT INSERT','C');
                  END IF;

                   INSERT_EVENT(X_Award_Project_Id,
                                -1,  -- event_num
                                X_Installment_Total(Rec_Count).Installment_id,
                                X_Actual_Project_id,
                                X_Task_Id,
                                NULL, --X_Burden_Cost_Code,
                                NULL, --X_Exp_Org_Id,
                                0,
                                0,
		                X_Request_Id,
        		        NULL,		-- expenditure type,
                                X_Err_Code,
                                X_Err_Buff,
		                X_calling_Process);

                   If X_Err_Code <> 0 then
		        Raise NO_PROCESSING_OF_AWARD ;
                   End If;

                   IF L_DEBUG = 'Y' THEN
                   	gms_error_pkg.gms_debug('EVENT WRAPPER - AFTER ZERO $ EVENT INSERT ','C');
                   END IF;

               End If;
               -- -----------------------------------------------------------------------------

        End if; --  X_Installment_Total(Rec_Count).Rev_bill_Amount > 0
     End if;  -- Project and task check
    End loop;
End if;  -- X_Row_Count >0

If X_Diff_amount <> 0 then

           If X_calling_Process = 'Invoice' then
	      X_Bill_Amount := X_Diff_amount;
	      X_Rev_Amount := 0;
	   Elsif X_Calling_Process = 'Revenue' then
	      X_Bill_Amount := 0;
	      X_Rev_Amount := X_Diff_amount;
	   End if;

           IF L_DEBUG = 'Y' THEN
           	gms_error_pkg.gms_debug('EVENT WRAPPER - BEFORE INSERT EVENT DIFF <> 0','C');
           END IF;

           INSERT_EVENT(X_Award_Project_Id,
                     NULL,   -- event number
                     x_plsql_installment_id,
                     x_plsql_project_id,
                     x_plsql_task_id,
                     X_Burden_Cost_Code,
                     X_Exp_Org_Id,
                     X_Bill_Amount,
                     X_Rev_Amount,
		     X_Request_Id,
		     NULL,		-- Expenditure_Type
                     X_Err_Code,
                     X_Err_Buff,
		     X_calling_Process);

                If X_Err_Code <> 0 then
                        --ROLLBACK;
                        --RAISE FND_API.G_EXC_ERROR;
        			Raise NO_PROCESSING_OF_AWARD ;
                End If;

                IF L_DEBUG = 'Y' THEN
                	gms_error_pkg.gms_debug('EVENT WRAPPER - AFTER INSERT EVENT DIFF <> 0','C');
                END IF;

          X_Installment_Total(x_plsql_count).Rev_bill_Amount := X_Installment_Total(x_plsql_count).Rev_bill_Amount - X_Diff_Amount;

          X_Diff_Amount := 0;

End If;

-- Step 2: Error handling
    IF L_DEBUG = 'Y' THEN
    	gms_error_pkg.gms_debug('X_Diff_Amount :'||to_char(X_Diff_Amount),'C');
    END IF;

    If X_Diff_Amount <> 0 then
      gms_error_pkg.gms_message('GMS_CALC_ERROR',
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
	Raise NO_PROCESSING_OF_AWARD ;

    Else
      X_Err_Code := 0;
    End if;

End EVENT_WRAPPER;


/* This Procedure GET_FORMAT_SELECT returns: */
--1)  The Award_ID of the Award Project
--2)  The Carrying Out NOCOPY Organization Id of the Award Project
--3)  An Array indicating which of the columns have groupby columns for Labor Format
--4)  An Array indicating which of the columns have groupby columns for Non_Labor Format
--5)  Count of Number of Columns Selected for the Labor Inv Format
--6)  Count of Number of Columns Selected for the Non Labor Inv Format
--7)  An Array indicating whether each Labor column selected is to be right justified or not
--8)  An Array indicating whether each Non Labor Column selected is to be left justified or not
--9)  An Array indicating what the Padding Length should be for each Labor Invoice Column selected
--10) An Array indicating what the Padding Length should be for each NonLabor Invoice Column selected
--11) An Array containing the Free Text for each Labor Format Text Column
--12) An Array containing the Free Text for each Non Labor Format Text Column
--13)  A concatenated select for the Labor format
--14)  A concatenated from for the Labor format
--15)  A concatenated where for the Labor Format
--16) A concatenated order by for the Labor Format
--17) A concatenated select for the Non Labor format
--18) A concatenated from for the Non Labor format
--19) A concatenated where for the Non Labor Format
--20) A concatenated order by for the Non Labor Format
--21) If Task is used in Labor Invoice format or not
--22) If Task is used in Non Labor Invoice format or not
Procedure GET_FORMAT_SELECT(X_Project_Id IN NUMBER,
                            X_Award_Id IN OUT NOCOPY NUMBER,
                            X_Carrying_Out_Org_Id IN OUT NOCOPY NUMBER,
                            X_Labor_Sel_Grp_Diff_Ind OUT NOCOPY Mark_Sel_Grp_Diff_Array,
                            X_Non_Labor_Sel_Grp_Diff_Ind OUT NOCOPY Mark_Sel_Grp_Diff_Array,
                            X_Lbr_Cnt_Of_Columns_Selected IN OUT NOCOPY NUMBER,
                            X_Nlbr_Cnt_Of_Columns_Selected IN OUT NOCOPY NUMBER,
                            X_Lbr_Rt_Jstfy_Flag OUT NOCOPY Mark_Sel_Grp_Diff_Array,
                            X_Nlbr_Rt_Jstfy_Flag OUT NOCOPY Mark_Sel_Grp_Diff_Array,
                            X_Lbr_Padding_Length OUT NOCOPY Padding_Length_Array,
                            X_Nlbr_Padding_Length OUT NOCOPY Padding_Length_Array,
                            X_Lbr_Text_Array OUT NOCOPY Free_Text_Array,
                            X_Nlbr_Text_Array OUT NOCOPY Free_Text_Array,
 			    X_LABOR_CONCAT_SELECT OUT NOCOPY VARCHAR2,
                            X_LABOR_CONCAT_FROM   OUT NOCOPY VARCHAR2,
                            X_LABOR_CONCAT_WHERE   OUT NOCOPY VARCHAR2,
                            X_LABOR_CONCAT_ORDERBY OUT NOCOPY VARCHAR2,
			    X_LABOR_ORDERBY_IS_NULL OUT NOCOPY VARCHAR2,
                            X_NON_LABOR_CONCAT_SELECT  OUT NOCOPY VARCHAR2,
                            X_NON_LABOR_CONCAT_FROM    OUT NOCOPY VARCHAR2,
                            X_NON_LABOR_CONCAT_WHERE  OUT NOCOPY VARCHAR2 ,
                            X_NON_LABOR_CONCAT_ORDERBY OUT NOCOPY VARCHAR2,
			    X_NON_LABOR_ORDERBY_IS_NULL OUT NOCOPY VARCHAR2,
			    X_LABOR_tsk_lvl_fmt OUT NOCOPY VARCHAR2,  /* added for bug 3523930 */
			    X_NON_LABOR_tsk_lvl_fmt OUT NOCOPY VARCHAR2,  /* added for bug 3523930 */
                            X_Err_Num OUT NOCOPY NUMBER,
                            X_Err_Stage OUT NOCOPY VARCHAR2) IS
X_LABOR_SELECT VARCHAR2(2000) := NULL;
X_LABOR_FROM VARCHAR2(2000) := NULL;
X_LABOR_WHERE  VARCHAR2(2000) := NULL;
X_LABOR_ORDERBY  VARCHAR2(2000) := NULL;
X_NON_LABOR_SELECT VARCHAR2(2000) := NULL;
X_NON_LABOR_FROM VARCHAR2(2000) := NULL;
X_NON_LABOR_WHERE VARCHAR2(2000) := NULL;
X_NON_LABOR_ORDERBY VARCHAR2(2000) := NULL;
/* Cursor to get Labor_Invoice_Format_Id and Non_Labor_Invoice_Format_Id */
CURSOR GET_INVOICE_FORMAT(X_Project_Id NUMBER) IS
select
a.labor_invoice_format_id,
a.non_labor_invoice_format_id,
b.award_id, /*Award_Id*/
a.carrying_out_organization_id
from
PA_PROJECTS_ALL a,
GMS_AWARDS b
where
a.project_id = X_Project_Id and
b.award_project_id = a.project_id ;

X_Labor_Invoice_Format_Id NUMBER(15);
X_Non_Labor_Invoice_Format_Id NUMBER(15);
X_Col_Code VARCHAR2(30);
/* CURSORS FOR Creating Selects , From and Where for Labor and Non Labor Invoice Formats */
/* Cursor to get the COLUMNS associated with the Invoice Format Details */
CURSOR Column_Cursor(X_INV_FORMAT_ID NUMBER) IS
select
b.start_position START_POSITION,
b.end_position END_POSITION,
b.right_justify_flag RT_FLAG,
b.text TEXT,
a.column_code COL_CODE,
a.select_text  SELECT_TEXT,
a.group_by_text GROUP_TEXT
from
pa_invoice_group_columns a,
pa_invoice_format_details b
where
a.invoice_group_column_id = b.invoice_group_column_id and
b.invoice_format_id = X_INV_FORMAT_ID
order by b.start_position;
/* Cursor to get the TABLES for the Group Column associated with the Invoice Format Details */
CURSOR Table_Cursor(X_INV_FORMAT_ID NUMBER ) IS
select /*+INDEX(a PA_INVOICE_GROUP_TABLES_N1)*/
distinct a.text TABLE_TEXT
from
pa_invoice_group_tables a,
pa_invoice_group_columns b,
pa_invoice_format_details c
where
b.invoice_group_column_id = c.invoice_group_column_id and
a.invoice_group_column_id = c.invoice_group_column_id and
c.invoice_format_id = X_INV_FORMAT_ID;
/* Cursor to get the WHERE for the Group Column associated with the Invoice Format Details */
CURSOR Where_Cursor(X_INV_FORMAT_ID  NUMBER) IS
select /*+INDEX(b PA_INV_GRP_WHR_CLAUSES_U1)*/
distinct b.text  WHERE_TEXT
from
pa_inv_grp_col_whr_clauses a,
pa_inv_grp_whr_clauses b,
pa_invoice_group_columns c,
pa_invoice_format_details d
where
b.invoice_group_where_clause_id = a.invoice_group_where_clause_id and
a.invoice_group_column_id = c.invoice_group_column_id and
c.invoice_group_column_id = d.invoice_group_column_id and
d.invoice_format_id = X_INV_FORMAT_ID;
/* Getting the Award Id, Labor Invoice Format Id and Non Labor Invoice Format Id for the Award Project */
Begin
 	X_LABOR_SELECT := NULL;
	X_LABOR_FROM := NULL;
	X_LABOR_WHERE  := NULL;
	X_NON_LABOR_SELECT := NULL;
	X_NON_LABOR_FROM := NULL;
	X_NON_LABOR_WHERE := NULL;
/* Two lines below are added for bug 3523930 */
        X_LABOR_tsk_lvl_fmt := 'N';
        X_NON_LABOR_tsk_lvl_fmt := 'N';
	OPEN GET_INVOICE_FORMAT(X_Project_Id);
            FETCH GET_INVOICE_FORMAT INTO
            X_Labor_Invoice_Format_Id ,
            X_Non_Labor_Invoice_Format_Id,
            X_Award_Id,
            X_Carrying_Out_Org_Id;
        CLOSE GET_INVOICE_FORMAT;
       X_Lbr_Cnt_Of_Columns_Selected := 0;
       X_Nlbr_Cnt_Of_Columns_Selected:= 0;
Begin
/*==========================================================*/
/* Fetching for Labor Invoice Format  SELECT, FROM, WHERE */
/*==========================================================*/
   FOR Column_Record IN Column_Cursor(X_Labor_Invoice_Format_Id) LOOP
       If (Column_Record.SELECT_TEXT is NOT NULL) then
        X_LABOR_SELECT := X_LABOR_SELECT||Column_Record.SELECT_TEXT||',';
        X_Lbr_Cnt_Of_Columns_Selected := X_Lbr_Cnt_Of_Columns_Selected + 1;
        X_Lbr_Rt_Jstfy_Flag(X_Lbr_Cnt_Of_Columns_Selected) := Column_Record.RT_FLAG;
        X_Lbr_Padding_Length(X_Lbr_Cnt_Of_Columns_Selected) := (Column_Record.END_POSITION -
                                                                Column_Record.START_POSITION);
    /* If added for bug 3523930 */
        IF(Column_Record.COL_CODE like '%TASK%') THEN
	  X_LABOR_tsk_lvl_fmt :='Y';
        END IF;
       End If;
      If (Column_Record.GROUP_TEXT is NOT NULL) then
        X_LABOR_ORDERBY := X_LABOR_ORDERBY||Column_Record.GROUP_TEXT||',';
        X_Labor_Sel_Grp_Diff_Ind(X_Lbr_Cnt_Of_Columns_Selected) := 'Y';
      Else
        If Column_Record.COL_CODE = 'TEXT' then
          X_Labor_Sel_Grp_Diff_Ind(X_Lbr_Cnt_Of_Columns_Selected) := 'T';
          X_Lbr_Text_Array(X_Lbr_Cnt_Of_Columns_Selected) := Column_Record.TEXT;
          X_Lbr_Rt_Jstfy_Flag(X_Lbr_Cnt_Of_Columns_Selected) := Column_Record.RT_FLAG;
          X_Lbr_Padding_Length(X_Lbr_Cnt_Of_Columns_Selected) := (Column_Record.END_POSITION -
                                                                  Column_Record.START_POSITION) + 1;
        Else
          X_Labor_Sel_Grp_Diff_Ind(X_Lbr_Cnt_Of_Columns_Selected) := 'N';
        End If;
      End If;
   END LOOP;
      X_LABOR_CONCAT_SELECT := X_LABOR_SELECT;
   If X_LABOR_ORDERBY IS NOT NULL THEN
      X_LABOR_CONCAT_ORDERBY := (substr(X_LABOR_ORDERBY,1,length(X_LABOR_ORDERBY)-1))||' , ';
      X_LABOR_ORDERBY_IS_NULL := 'N';
   ELSE
      X_LABOR_ORDERBY_IS_NULL := 'Y';
      --X_LABOR_CONCAT_ORDERBY := ' , ';
   END IF;
  FOR Table_Record IN Table_Cursor(X_Labor_Invoice_Format_Id) LOOP
     X_LABOR_FROM := X_LABOR_FROM||Table_Record.TABLE_TEXT||',';
  END LOOP;
      X_LABOR_CONCAT_FROM := X_LABOR_FROM;
  FOR Where_Record IN Where_Cursor(X_Labor_Invoice_Format_Id) LOOP
    X_LABOR_WHERE := X_LABOR_WHERE||Where_Record.WHERE_TEXT||'  and ';
  END LOOP;
      X_LABOR_CONCAT_WHERE := X_LABOR_WHERE;
/*=======================================================*/
/*==============================================================*/
/* Fetching Non Labor Invoice Format Select, From, Where */
/*=============================================================*/
 FOR Column_Record IN Column_Cursor(X_Non_Labor_Invoice_Format_Id) LOOP
       If (Column_Record.SELECT_TEXT is NOT NULL) then
        X_NON_LABOR_SELECT := X_NON_LABOR_SELECT||Column_Record.SELECT_TEXT||',';
        X_Nlbr_Cnt_Of_Columns_Selected := X_Nlbr_Cnt_Of_Columns_Selected + 1;
        X_Nlbr_Rt_Jstfy_Flag(X_Nlbr_Cnt_Of_Columns_Selected) := Column_Record.RT_FLAG;
        X_Nlbr_Padding_Length(X_Nlbr_Cnt_Of_Columns_Selected) := (Column_Record.END_POSITION -
                                                                  Column_Record.START_POSITION);
    /* If added for bug 3523930 */
	IF(Column_Record.COL_CODE like '%TASK%') THEN
	      X_NON_LABOR_tsk_lvl_fmt :='Y';
	END IF;
       End If;
      If (Column_Record.GROUP_TEXT is NOT NULL) then
        X_NON_LABOR_ORDERBY := X_NON_LABOR_ORDERBY||Column_Record.GROUP_TEXT||',';
        X_Non_Labor_Sel_Grp_Diff_Ind(X_Nlbr_Cnt_Of_Columns_Selected) := 'Y';
      Else
       If Column_Record.COL_CODE = 'TEXT' then
          X_Non_Labor_Sel_Grp_Diff_Ind(X_Nlbr_Cnt_Of_Columns_Selected) := 'T';
          X_Nlbr_Text_Array(X_Nlbr_Cnt_Of_Columns_Selected) := Column_Record.TEXT;
          X_Nlbr_Rt_Jstfy_Flag(X_Nlbr_Cnt_Of_Columns_Selected) := Column_Record.RT_FLAG;
          X_Nlbr_Padding_Length(X_Nlbr_Cnt_Of_Columns_Selected) := (Column_Record.END_POSITION -
                                                                  Column_Record.START_POSITION) + 1;
       Else
           X_Non_Labor_Sel_Grp_Diff_Ind(X_Nlbr_Cnt_Of_Columns_Selected) := 'N';
       End If;
      End If;
   END LOOP;
      X_NON_LABOR_CONCAT_SELECT := X_NON_LABOR_SELECT;
   If X_NON_LABOR_ORDERBY IS NOT NULL THEN
      X_NON_LABOR_CONCAT_ORDERBY := (substr(X_NON_LABOR_ORDERBY,1,length(X_NON_LABOR_ORDERBY)-1))||' , ';
      X_NON_LABOR_ORDERBY_IS_NULL := 'N';
   ElSE
      X_NON_LABOR_ORDERBY_IS_NULL := 'Y';
      --X_NON_LABOR_CONCAT_ORDERBY := ' , ';
   END IF;
  FOR Table_Record IN Table_Cursor(X_Non_Labor_Invoice_Format_Id) LOOP
     X_NON_LABOR_FROM := X_NON_LABOR_FROM||Table_Record.TABLE_TEXT||',';
  END LOOP;
      X_NON_LABOR_CONCAT_FROM := X_NON_LABOR_FROM;
  FOR Where_Record IN Where_Cursor(X_Non_Labor_Invoice_Format_Id) LOOP
    X_NON_LABOR_WHERE := X_NON_LABOR_WHERE||Where_Record.WHERE_TEXT||'  and ';
  END LOOP;
      X_NON_LABOR_CONCAT_WHERE := X_NON_LABOR_WHERE;
/*=======================================================*/
 End;
EXCEPTION
 WHEN OTHERS THEN
      gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Num,
				X_Err_Buff => X_Err_Stage);
      --ROLLBACK;
      --RAISE_APPLICATION_ERROR(-20514,X_Err_Stage);
      --RETURN;
      Raise NO_PROCESSING_OF_AWARD ;

END GET_FORMAT_SELECT;

---------------------------------------------------------------------------------------
-- Procedure GET_AMOUNT_IN_INTERSECT: Given the Expenditure Item Id returns the cumulative
-- Amount in the GMS_EVENT_INTERSECT table for all the number of times this
-- expenditure item has been picked up before for billing
--------------------------------------------------------------------------------------
PROCEDURE GET_AMOUNT_IN_INTERSECT(X_Expenditure_Item_Id IN NUMBER,
				  X_Adl_Line_Num	IN NUMBER,
                                  X_Calling_Process IN VARCHAR2,
                                  X_Amount_In_Intersect OUT NOCOPY NUMBER) IS
X_Err_Code Varchar2(1);
X_Err_Buff Varchar2(2000);

X_Current_Amount NUMBER(22,5) := 0;
Begin
 Begin
    select
    nvl(sum(nvl(amount,0)),0)
    into
    X_Current_Amount
    from
    GMS_EVENT_INTERSECT
    where
    expenditure_item_id = X_Expenditure_Item_Id and
    adl_line_num = X_Adl_Line_Num and
    event_type = decode(X_Calling_Process,'Invoice','INVOICE','Revenue','REVENUE');
 Exception
    When others then
      gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      --ROLLBACK;
      --RAISE_APPLICATION_ERROR(-20515,X_Err_Buff);
      --RETURN;
	Raise NO_PROCESSING_OF_AWARD ;

 End;

    X_Amount_In_Intersect := X_Current_Amount;

END GET_AMOUNT_IN_INTERSECT;

---------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--Procedure GET_BURD_AMT_IN_INTERSECT: For a given expenditure item and for a given burden
--cost component used to burden this expenditure item this procedure will return the burden
--amount that has been billed or accrued to_date from the GMS_BURDEN_COMPONENTS table
--------------------------------------------------------------------------------
PROCEDURE GET_BURD_AMT_IN_INTERSECT(X_Expenditure_Item_Id  IN NUMBER,
				    X_Adl_Line_Num 	   IN NUMBER,
			            X_Calling_Process      IN VARCHAR2,
			            X_Burden_Cost_Code     IN VARCHAR2,
			            X_Burden_Amt_In_Table  OUT NOCOPY NUMBER) IS

X_Err_Code Varchar2(1);
X_Err_Buff Varchar2(2000);
Begin
  Select
  nvl(sum(nvl(amount,0)),0)
  into X_Burden_Amt_In_Table
  from
  GMS_BURDEN_COMPONENTS
  where
      expenditure_item_id = X_Expenditure_Item_Id
  and adl_line_num        = X_Adl_Line_Num
  and burden_cost_code    = X_Burden_Cost_Code
  and event_type          =  decode(X_Calling_Process,'Invoice','INVOICE','Revenue','REVENUE');
 Exception
    When others then
      gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      --ROLLBACK;
      --RAISE_APPLICATION_ERROR(-20517,X_Err_Buff);
      --RETURN;
      Raise NO_PROCESSING_OF_AWARD ;

End GET_BURD_AMT_IN_INTERSECT;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Function CHECK_FOR_NO_FUNDINGS_ROW(C_Installment_Id      IN NUMBER,
                                   X_Task_Id             IN NUMBER) RETURN BOOLEAN IS
X_Check_Row_Exists NUMBER;
Begin
  select
  1
  into
  X_Check_Row_Exists
  from
  gms_summary_project_fundings gmf
  where
  gmf.installment_id = C_Installment_Id
  and (
       (gmf.task_id  = X_Task_Id)
  OR   (gmf.task_id is NULL)
  OR   (gmf.task_id = (select t.top_task_id from PA_TASKS t where t.task_id = X_Task_Id))
      )
  and gmf.project_id     = (select project_id from PA_TASKS where task_id = X_Task_Id);
  RETURN FALSE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
          RETURN TRUE;
    WHEN OTHERS THEN
         RETURN TRUE;

End CHECK_FOR_NO_FUNDINGS_ROW;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--Procedure GET_ACCRUE_BILL_OR_INSERT_AMT: Gets the resultant amount that needs to be accrued or
--Billed for a particular Expenditure Item after taking into account the amount already existing in the
--GMS_EVENT_INTERSECT table for that Expenditure Item . If the calling Process is
--'Invoice' the process will look at the Billable Flag and Bill_Hold_Flag to decide how much amount
--needs to be reduced from the Total Billed Amount. These two flags are not looked at for the
--'Revenue' process.

PROCEDURE GET_ACCRUE_BILL_OR_INSERT_AMT(X_Expenditure_Item_Id            IN NUMBER,
					X_Adl_Line_Num			 IN NUMBER,
			                X_Calling_Process                IN VARCHAR2,
				        X_Raw_Cost	                 IN NUMBER,
				        X_Billable_Flag                  IN VARCHAR2,
			                X_Bill_Hold_Flag                 IN VARCHAR2,
                                        X_Amount_To_Accrue_Bill_Insert   OUT NOCOPY NUMBER,
                                        X_Err_Num                        OUT NOCOPY NUMBER,
				        X_Err_Stage                      OUT NOCOPY VARCHAR2) IS

X_Current_Amount_In_Intersect NUMBER; -- Current Amount in Intersect table for that Exp Item
Begin

   GET_AMOUNT_IN_INTERSECT(X_Expenditure_Item_Id ,
			   X_Adl_Line_Num,
                           X_Calling_Process,
                           X_Current_Amount_In_Intersect);

 If X_Calling_Process = 'Invoice' then

   If     (X_Billable_Flag = 'N' OR nvl(X_Bill_Hold_Flag,'N') = 'Y') then

     If X_Current_Amount_In_Intersect <> 0 then
         --dbms_output.put_line('In IF for BILL HOLD FLAG = Y');
         X_Amount_To_Accrue_Bill_Insert := (-1 * X_Current_Amount_In_Intersect);
     Else
         X_Amount_To_Accrue_Bill_Insert := 0;
     End If;

   Else
     X_Amount_To_Accrue_Bill_Insert := (X_Raw_Cost - X_Current_Amount_In_Intersect);
   End If;

 Elsif X_Calling_Process = 'Revenue' then

   If (X_Billable_Flag = 'N' ) then

     If X_Current_Amount_In_Intersect <> 0 then
         X_Amount_To_Accrue_Bill_Insert := (-1 * X_Current_Amount_In_Intersect);
     Else
         X_Amount_To_Accrue_Bill_Insert := 0;
     End If;

   Else
         X_Amount_To_Accrue_Bill_Insert := (X_Raw_Cost - X_Current_Amount_In_Intersect);
   End If;

 End If;

End GET_ACCRUE_BILL_OR_INSERT_AMT;

-----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--Procedure GET_BURDEN_AMT_TO_INSERT returns the burden amount to be inserted into
--GMS_BURDEN_COMPONENTS table for a given expenditure item id and for a given burden
--cost component
----------------------------------------------------------------------------------
PROCEDURE GET_BURDEN_AMT_TO_INSERT(X_Expenditure_Item_Id     IN NUMBER,
				     X_Adl_Line_Num	     IN NUMBER,
				     X_Calling_Process	     IN VARCHAR2,
				     X_Burden_Cost_Code      IN VARCHAR2,
                                     X_Billable_Flag         IN VARCHAR2,
                                     X_Bill_Hold_Flag        IN VARCHAR2,
				     X_Burden_Amt_From_Vw    IN NUMBER,
				     X_Burden_Amt_To_Insert  OUT NOCOPY NUMBER) IS

X_Curr_Burden_Amt_In_Table  NUMBER;

Begin

  GET_BURD_AMT_IN_INTERSECT(X_Expenditure_Item_Id
			   ,X_Adl_Line_Num
		           ,X_Calling_Process
			   ,X_Burden_Cost_Code
			   ,X_Curr_Burden_Amt_In_Table);

 If X_Calling_Process = 'Invoice' then
   If     (X_Billable_Flag = 'N' OR nvl(X_Bill_Hold_Flag,'N') = 'Y') then
     If X_Curr_Burden_Amt_In_Table <> 0 then
         X_Burden_Amt_To_Insert := (-1 * X_Curr_Burden_Amt_In_Table);
     Else
         X_Burden_Amt_To_Insert := 0;
     End If;
   Else
     X_Burden_Amt_To_Insert := (X_Burden_Amt_From_Vw - X_Curr_Burden_Amt_In_Table);
   End If;
 Elsif X_Calling_Process = 'Revenue' then
   If (X_Billable_Flag = 'N' ) then
     If X_Curr_Burden_Amt_In_Table <> 0 then
         X_Burden_Amt_To_Insert := (-1 * X_Curr_Burden_Amt_In_Table);
     Else
         X_Burden_Amt_To_Insert := 0;
     End If;
   Else
         X_Burden_Amt_To_Insert := (X_Burden_Amt_From_Vw - X_Curr_Burden_Amt_In_Table);
   End If;
 End If;

End GET_BURDEN_AMT_TO_INSERT;
------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
--Procedure INSERT_GMS_BURDEN_COMPONENTS: Inserts rows into GMS_BURDEN_COMPONENTS table for
--each component that a raw cost transaction is burdened by for an amount equal to the difference
--between the current Burden Amt from the View for that Component and that expenditure item id and
--the cumulative amount in GMS_BURDEN_COMPONENTS table for that component and that exp item.
-----------------------------------------------------------------------------------
PROCEDURE INSERT_GMS_BURDEN_COMPONENTS(X_Award_Project_Id 		IN NUMBER,
                                       X_Expenditure_Item_Id       	IN NUMBER,
				       X_Adl_Line_Num			IN NUMBER,
                                       X_Request_Id			IN NUMBER,
                                       X_Calling_Process		IN VARCHAR2,
                                       X_Actual_Project_Id		IN NUMBER,
                                       X_Actual_Task_Id                 IN NUMBER,
                                       X_Burden_Expenditure_Type        IN VARCHAR2,
                                       X_Burden_Cost_Code               IN VARCHAR2,
                                       X_Expenditure_Org_Id             IN NUMBER,
                                       X_Burd_Amt_To_Insert             IN NUMBER,
				       X_Err_Num			OUT NOCOPY NUMBER,
				       X_Err_Stage			OUT NOCOPY VARCHAR2) IS

X_Err_Code Varchar2(1);
X_Err_Buff Varchar2(2000);
Begin

  If X_Burd_Amt_To_Insert <> 0 then
   Begin

    INSERT INTO GMS_BURDEN_COMPONENTS(AWARD_PROJECT_ID,
                                      EXPENDITURE_ITEM_ID,
				      ADL_LINE_NUM,
                                      AMOUNT,
                                      REQUEST_ID,
                                      EVENT_TYPE,
				      ACTUAL_PROJECT_ID,
 				      ACTUAL_TASK_ID,
 				      BURDEN_EXP_TYPE,
 				      EXPENDITURE_ORG_ID,
 				      BURDEN_COST_CODE,
                                      LAST_UPDATE_DATE,
                                      LAST_UPDATED_BY,
                                      CREATION_DATE,
                                      CREATED_BY,
                                      LAST_UPDATE_LOGIN,
				      REVENUE_ACCUMULATED,
			              RESOURCE_LIST_MEMBER_ID)
    VALUES(X_Award_Project_Id,
           X_Expenditure_Item_Id,
	   X_Adl_Line_Num,
           X_Burd_Amt_To_Insert,
           X_request_id,
           decode(X_Calling_Process,'Invoice','INVOICE','Revenue','REVENUE'),
           X_Actual_Project_Id,
	   X_Actual_Task_Id,
	   X_Burden_Expenditure_Type,
	   X_Expenditure_Org_Id,
	   X_Burden_Cost_Code,
           SYSDATE,
           fnd_global.user_id,
           SYSDATE,
           fnd_global.user_id,
           fnd_global.login_id,
	   decode(X_Calling_Process,'Invoice','X','Revenue','N'), -- Added decode for bug 5472366
	   null);

         X_Err_Num := 0;
         X_UPD_BILLING_FLAG := TRUE; -- Bug 3254097

         IF L_DEBUG = 'Y' THEN
         	gms_error_pkg.gms_debug('Inserted into GBC, EXP/ADL:'||X_Expenditure_Item_Id||':'||X_Adl_Line_Num,'C');
         END IF;

      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
         gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
	   Raise NO_PROCESSING_OF_AWARD ;

        WHEN OTHERS THEN
          gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
	    Raise NO_PROCESSING_OF_AWARD ;

    End;
   End If;

End INSERT_GMS_BURDEN_COMPONENTS;
------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- Procedure INSERT_GMS_EVENT_INTERSECT: Inserts a row into GMS_EVENT_INTERSECT table for an
-- amount equal to the difference between the current Raw Cost on the Expenditure Item and
-- the cumulative amount for the expenditure item in the table
-----------------------------------------------------------------------------------------
PROCEDURE INSERT_GMS_EVENT_INTERSECT(X_Award_Project_Id IN NUMBER,
                                     X_Raw_Cost IN NUMBER,
				     X_Expenditure_Item_Id IN NUMBER,
				     X_Adl_Line_Num IN NUMBER,
                                     X_request_id IN NUMBER,
                                     X_Amount_To_Insert IN OUT NOCOPY NUMBER,
                                     X_Calling_Process IN VARCHAR2,
                                     X_Billable_Flag   IN VARCHAR2,
                                     X_Bill_Hold_Flag  IN VARCHAR2,
                                     X_Err_Num OUT NOCOPY NUMBER,
                                     X_Err_Stage OUT NOCOPY VARCHAR2) IS

X_Err_Code Varchar2(1);
X_Err_Buff Varchar2(2000);
X_Current_Amount  NUMBER(22,5);
Begin

       GET_ACCRUE_BILL_OR_INSERT_AMT(X_Expenditure_Item_Id,
				     X_Adl_Line_Num,
                                     X_Calling_Process,
                                     X_Raw_Cost,
                                     X_Billable_Flag,
                                     X_Bill_Hold_Flag,
                                     X_Amount_To_Insert,
                                     X_Err_Num,
                                     X_Err_Stage);

X_Amount_To_Insert := pa_currency.round_currency_amt(nvl(X_Amount_To_Insert,0));  -- added for bug 5182669
  If X_Amount_To_Insert <> 0 then
   Begin
    INSERT INTO GMS_EVENT_INTERSECT(AWARD_PROJECT_ID,
                                    EXPENDITURE_ITEM_ID,
				    ADL_LINE_NUM,
                                    AMOUNT,
                                    REQUEST_ID,
                                    EVENT_TYPE,
                                    LAST_UPDATE_DATE,
                                    LAST_UPDATED_BY,
                                    CREATION_DATE,
                                    CREATED_BY,
                                    LAST_UPDATE_LOGIN,
				    REVENUE_ACCUMULATED)
    VALUES(X_Award_Project_Id,
           X_Expenditure_Item_Id,
	   X_Adl_Line_Num,
           X_Amount_To_Insert,
           X_request_id,
           decode(X_Calling_Process,'Invoice','INVOICE','Revenue','REVENUE'),
           SYSDATE,
           fnd_global.user_id,
           SYSDATE,
           fnd_global.user_id,
           fnd_global.login_id,
	   decode(X_Calling_Process,'Invoice','X','Revenue','N')); -- Added decode for bug 5472366
         X_Err_Num := 0;
         X_UPD_BILLING_FLAG    := TRUE; -- Bug 3254097

         IF L_DEBUG = 'Y' THEN
         	gms_error_pkg.gms_debug('Inserted into GEI, EXP/ADL:'||X_Expenditure_Item_Id||':'||X_Adl_Line_Num,'C');
         END IF;

      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
         gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
	   Raise NO_PROCESSING_OF_AWARD ;

        WHEN OTHERS THEN
         gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
                                'SQLCODE',
                                SQLCODE,
                                'SQLERRM',
                                SQLERRM,
                                X_Exec_Type => 'C',
                                X_Err_Code => X_Err_Code,
                                X_Err_Buff => X_Err_Buff);
	   --ROLLBACK;
           --RAISE_APPLICATION_ERROR(-20521,X_Err_Buff);
           --RETURN;
	   Raise NO_PROCESSING_OF_AWARD ;

    End;
   End If;

End INSERT_GMS_EVENT_INTERSECT;

-----------------------------------------------------------------------------------------
-- Procedure UPDATE_GMS_EVENT_INTERSECT: Updates GMS_EVENT_INTERSECT table with the Event Num
-- of the Event created.
-- Bug 3235390 : Modified the below procedure to update records based on project and task_id.
-----------------------------------------------------------------------------------------
PROCEDURE UPDATE_GMS_EVENT_INTERSECT(X_Event_Num        IN NUMBER,
                                     X_Award_Project_Id IN NUMBER,
                                     X_request_id       IN NUMBER,
                                     X_ACT_PROJECT_ID   IN NUMBER,
                                     X_TASK_ID          IN NUMBER) IS

X_Err_Code Varchar2(1);
X_Err_Buff Varchar2(2000);
Begin
 IF L_DEBUG = 'Y' THEN
 	gms_error_pkg.gms_debug('IN EVENT INTERSECT Updation - START','C');
 END IF;

 update GMS_EVENT_INTERSECT gei
 set
 gei.EVENT_NUM = X_Event_Num
 ,gei.last_update_date  = sysdate
 ,gei.last_updated_by   = fnd_global.user_id
 ,gei.last_update_login = fnd_global.login_id
 where gei.REQUEST_ID = X_Request_id and
 gei.award_project_id = X_Award_Project_Id and
 gei.EVENT_NUM IS NULL
 AND  EXISTS  ( -- Bug 3235390 : Added below conditions to check for project and task.
         SELECT gei2.expenditure_item_id
           FROM gms_award_distributions adl,
                gms_event_intersect gei2
          WHERE gei2.expenditure_item_id = gei.expenditure_item_id
            AND adl.expenditure_item_id  = gei2.expenditure_item_id
            AND adl.adl_status = 'A'
            AND adl.document_type ='EXP'
            AND adl.project_id    = x_act_project_id
            AND adl.task_id    = x_task_id);


    If SQL%NOTFOUND THEN
      IF L_DEBUG = 'Y' THEN
      	gms_error_pkg.gms_debug('IN EVENT INTERSECT Updation - ERROR','C');
      END IF;
      gms_error_pkg.gms_message('GMS_NO_UPD_PRJ_REQ',
				'PRJ',
				X_Award_Project_Id,
				'REQ',
				X_Request_id,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
	Raise NO_PROCESSING_OF_AWARD ;

    End If;
    IF L_DEBUG = 'Y' THEN
    	gms_error_pkg.gms_debug('IN EVENT INTERSECT Updation - END','C');
    END IF;

End UPDATE_GMS_EVENT_INTERSECT;

--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
--Procedure UPDATE_GMS_BURDEN_COMPONENTS: Updates GMS_BURDEN_COMPONENTS table with the Event Num of
--the event created.
--------------------------------------------------------------------------------------------
PROCEDURE UPDATE_GMS_BURDEN_COMPONENTS(X_Event_Num	    IN NUMBER,
				       X_Award_Project_Id   IN NUMBER,
				       X_Request_Id	    IN NUMBER,
				       X_Actual_Project_Id  IN NUMBER,
				       X_Actual_Task_Id     IN NUMBER,
				       X_Burden_Cost_Code   IN VARCHAR2,
				       X_Expenditure_Org_Id IN NUMBER) IS

X_Err_Code Varchar2(1);
X_Err_Buff Varchar2(2000);
Begin
 IF L_DEBUG = 'Y' THEN
 	gms_error_pkg.gms_debug('IN BURDEN COMPONENTS Updation - START','C');
 END IF;
 update /*+INDEX(GMS_BURDEN_COMPONENTS GMS_BURDEN_COMPONENTS_N3)*/ GMS_BURDEN_COMPONENTS
 set
 EVENT_NUM = X_Event_Num
 ,last_update_date  = sysdate
 ,last_updated_by   = fnd_global.user_id
 ,last_update_login = fnd_global.login_id
 where
 request_id = X_request_id             and
 award_project_id = X_Award_Project_Id and
 EVENT_NUM IS NULL                     and
 actual_project_id = X_Actual_Project_Id and
 actual_task_id    = X_Actual_Task_Id  and
 burden_cost_code  = X_Burden_Cost_Code and
 expenditure_org_id = X_Expenditure_Org_Id;

    If SQL%NOTFOUND THEN
      IF L_DEBUG = 'Y' THEN
      	gms_error_pkg.gms_debug('IN BURDEN COMPONENTS Updation - ERROR','C');
      END IF;
      gms_error_pkg.gms_message('GMS_NO_UPD_PRJ_REQ',
				'PRJ',
				X_Award_Project_Id,
				'REQ',
				X_Request_id,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
	Raise NO_PROCESSING_OF_AWARD ;

    End If;

    IF L_DEBUG = 'Y' THEN
    	gms_error_pkg.gms_debug('IN BURDEN COMPONENTS Updation - END','C');
    END IF;

End UPDATE_GMS_BURDEN_COMPONENTS;
---------------------------------------------------------------------------------------------
--PROCEDURE: EVENT_ATTRIBUTE_UPDATION, new procedure to update event number on Event_Attribute

PROCEDURE EVENT_ATTRIBUTE_UPDATION(X_Event_Num        IN NUMBER,
				   X_Award_Project_Id IN NUMBER,
				   X_request_id       IN NUMBER,
				   X_Err_Code	      IN OUT NOCOPY NUMBER,
				   X_Err_Buff         IN OUT NOCOPY VARCHAR2) IS

x_count number :=0;

Begin

 IF L_DEBUG = 'Y' THEN
 	gms_error_pkg.gms_debug('IN EVENT ARRIBUTE UPDATION -- START','C');
 END IF;

 update GMS_EVENT_ATTRIBUTE
 set
 EVENT_NUM = X_Event_Num
 ,last_update_date  = sysdate
 ,last_updated_by   = fnd_global.user_id
 ,last_update_login = fnd_global.login_id
 where
 request_id = X_request_id             and
 project_id = X_Award_Project_Id and
 EVENT_NUM IS NULL;

 Begin

    Select 1
    into   x_count
    from   dual
    where  exists
    (select 1
     from   gms_event_attribute
     where  request_id = X_request_id
     and    project_id = X_Award_Project_Id
     and    EVENT_NUM IS NULL);

 Exception

   When no_data_found then

       x_count := 0;
 End;

--    If SQL%NOTFOUND THEN
      If x_count > 0 then

      gms_error_pkg.gms_message('GMS_NO_UPD_PRJ_REQ',
				'PRJ',
				X_Award_Project_Id,
				'REQ',
				X_Request_id,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      RETURN;
    Else
      X_Err_Code := 0;
    End If;
Exception

  When Others then
  IF L_DEBUG = 'Y' THEN
  	gms_error_pkg.gms_debug('IN EVENT ARRIBUTE WHEN OTHERS ','C');
  END IF;
  gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
                                'SQLCODE',
                                SQLCODE,
                                'SQLERRM',
                                SQLERRM,
                                X_Exec_Type => 'C',
                                X_Err_Code => X_Err_Code,
                                X_Err_Buff => X_Err_Buff);
  RAISE;

End EVENT_ATTRIBUTE_UPDATION;

---------------------------------------------------------------------------------------------

PROCEDURE UPDATE_GMS_SUMMARY_FUNDINGS(X_Installment_Id   IN NUMBER,
                                      X_Task_Id          IN NUMBER,
                                      X_Calling_Process  IN VARCHAR2,
                                      X_Rev_Bill_Amount  IN NUMBER,
				      X_Err_Code	 IN OUT NOCOPY NUMBER,
				      X_Err_Buff         IN OUT NOCOPY VARCHAR2) IS

X_Total_Funding_Amount NUMBER(22,5) := 0;
X_Total_Rev_Bill_Amount  NUMBER(22,5) := 0;

Begin
   GET_SUMM_FUNDING(X_Installment_Id,
		    NULL,
		    NULL,
                    X_Task_Id,
                    X_Calling_Process,
                    X_Total_Funding_Amount,
                    X_Total_Rev_Bill_Amount,
		    X_Err_Code,
		    X_Err_Buff);

            	If X_Err_Code <> 0 then
		        --ROLLBACK;
                 	--RAISE FND_API.G_EXC_ERROR;
			Raise NO_PROCESSING_OF_AWARD ;
            	End If;
 Begin
 If X_Calling_Process = 'Invoice' then

    update GMS_SUMMARY_PROJECT_FUNDINGS spf
    set
    spf.TOTAL_BILLED_AMOUNT = (X_Rev_Bill_Amount + X_Total_Rev_Bill_Amount),
    spf.last_update_date    = sysdate,
    spf.last_updated_by     = fnd_global.user_id,
    spf.last_update_login   = fnd_global.login_id
    where
    spf.INSTALLMENT_ID = X_Installment_Id
    and (
         (spf.TASK_ID = X_Task_Id)
     or  (spf.TASK_ID IS NULL)
     or  (spf.TASK_ID = (select t.top_task_id from PA_TASKS t where
                         t.task_id = X_Task_Id))
     )
    and PROJECT_ID = (select project_id from pa_tasks where task_id = X_Task_Id);

    --DECODE(TASK_ID,NULL,X_Task_Id,TASK_ID) = X_Task_Id

 Elsif X_Calling_Process = 'Revenue' then

    update GMS_SUMMARY_PROJECT_FUNDINGS spf
    set
    spf.TOTAL_REVENUE_AMOUNT = (X_Rev_Bill_Amount + X_Total_Rev_Bill_Amount),
    spf.last_update_date    = sysdate,
    spf.last_updated_by     = fnd_global.user_id,
    spf.last_update_login   = fnd_global.login_id
    where
    spf.INSTALLMENT_ID = X_Installment_Id
    and (
         (spf.TASK_ID = X_Task_Id)
     or  (spf.TASK_ID IS NULL)
     or  (spf.TASK_ID = (select t.top_task_id from PA_TASKS t where
                         t.task_id = X_Task_Id))
     )
    and PROJECT_ID = (select project_id from pa_tasks where task_id = X_Task_Id);

    --DECODE(TASK_ID,NULL,X_Task_Id,TASK_ID) = X_Task_Id


 End If;

  If SQL%ROWCOUNT = 0 then
      gms_error_pkg.gms_message('GMS_NO_UPD_TASK_INST',
				'TASK',
				X_Task_Id,
				'INST',
				X_Installment_Id,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      --RAISE_APPLICATION_ERROR(-20524,X_Err_Buff);
      RETURN;
  Else
     X_Err_Code := 0;
  End If;

 End;

END UPDATE_GMS_SUMMARY_FUNDINGS;

-- PROCEDURE: UPD_GSPF_WRAPPER, new procedure for updating gms_summary_project_fundings

PROCEDURE UPD_GSPF_WRAPPER(X_Installment_Id     IN NUMBER,
			   X_Task_Id		IN NUMBER,
                           X_Actual_Project_Id  IN NUMBER,
			   X_Calling_Process    IN VARCHAR2,
			   X_Rev_Bill_Amount	IN NUMBER,
			   X_Installment_Count  IN NUMBER,
			   X_Install_tab        IN Inst_tab,
			   X_Inst_total         IN OUT NOCOPY Inst_tab2,
			   X_Err_Code		IN OUT NOCOPY NUMBER,
			   X_Err_Buff		IN OUT NOCOPY VARCHAR2) IS
Begin

     If X_Installment_Count = 1 then

        UPDATE_GMS_SUMMARY_FUNDINGS(X_Installment_Id,
				    X_Task_Id,
				    X_Calling_Process,
				    X_Rev_Bill_Amount,
			            X_Err_Code,
				    X_Err_Buff);

            	If X_Err_Code <> 0 then
			Raise NO_PROCESSING_OF_AWARD ;
            	End If;

        INSTALLMENT_AMOUNT(X_Installment_id,
			   X_Rev_Bill_Amount,
			   X_Inst_Total,
                           X_Actual_Project_Id,
                           X_Task_Id,
			   X_Err_Code,
			   X_Err_Buff);

                If X_Err_Code <> 0 then
			Raise NO_PROCESSING_OF_AWARD ;
                End If;
    Else

      for X_Count_Reqd in 1..X_Installment_Count
      loop
	  UPDATE_GMS_SUMMARY_FUNDINGS(X_Install_tab(X_Count_Reqd).Installment_Id,
				      X_Task_Id,
                                      X_Calling_Process,
				      X_Install_tab(X_Count_Reqd).Rev_Bill_Amount,
				      X_Err_Code,
				      X_Err_Buff);

            	If X_Err_Code <> 0 then
			Raise NO_PROCESSING_OF_AWARD ;
            	End If;

          INSTALLMENT_AMOUNT(X_Install_tab(X_Count_Reqd).Installment_Id,
                           X_Install_tab(X_Count_Reqd).Rev_Bill_Amount,
                           X_Inst_Total,
                           X_Actual_Project_Id,
                           X_Task_Id,
                           X_Err_Code,
                           X_Err_Buff);

                If X_Err_Code <> 0 then
			Raise NO_PROCESSING_OF_AWARD ;
                End If;

       end loop;
    End if;

     X_Err_Code := 0;

EXCEPTION
    WHEN OTHERS THEN
      gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      RETURN;

End UPD_GSPF_WRAPPER;

-----------------------------------------------------------------------------------------
-- Procedure UPD_ADL_BILLING_FLAG: Updates GMS_AWARD_DISTRIBUTIONS table sets the
-- Billed Flag and Revenue Distributed flag to 'Y' for the expenditure item that has been processed
-----------------------------------------------------------------------------------------
PROCEDURE UPD_ADL_BILLING_FLAG(X_Expenditure_Item_Id IN NUMBER,
			  X_Adl_Line_Num IN NUMBER,
		          X_Calling_Process     IN VARCHAR2,
		          X_Billable_Flag       IN VARCHAR2,
		          X_Bill_Hold_Flag      IN VARCHAR2,
			  X_Err_Code              IN OUT NOCOPY NUMBER,
                          X_Err_Buff              IN OUT NOCOPY VARCHAR2) IS

Begin
If X_Calling_Process = 'Invoice' then
 update
 GMS_AWARD_DISTRIBUTIONS
 set
 BILLED_FLAG = 'Y'
 ,last_update_date  = sysdate
 ,last_updated_by   = fnd_global.user_id
 ,last_update_login = fnd_global.login_id
 where expenditure_item_id = X_Expenditure_Item_Id
 and   adl_line_num = X_Adl_Line_Num
 and   document_type='EXP'
 and   adl_status = 'A';

Elsif X_Calling_Process = 'Revenue' then
 update
 GMS_AWARD_DISTRIBUTIONS
 set
 revenue_distributed_flag = 'Y'
 ,last_update_date  = sysdate
 ,last_updated_by   = fnd_global.user_id
 ,last_update_login = fnd_global.login_id
 where expenditure_item_id = X_Expenditure_Item_Id
 and   adl_line_num = X_Adl_Line_Num
 and   document_type='EXP'
 and   adl_status = 'A';

End If;

  If SQL%ROWCOUNT = 0 then
      gms_error_pkg.gms_message('GMS_NO_UPD_EXP_ADL',
				'EXP',
				X_Expenditure_Item_Id,
				'ADL',
				X_Adl_Line_Num,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      RETURN;
  Else
     X_Err_Code := 0;
  End If;

End UPD_ADL_BILLING_FLAG;

------------------------------------------------------------------------------------------
-- Procedure GET_RUN_TOTAL: This procedure get the running total for the event description
------------------------------------------------------------------------------------------
Procedure GET_RUN_TOTAL(X_Req_id  IN NUMBER,
                        X_Proj_Id IN NUMBER,
                        X_Qty    OUT NOCOPY NUMBER)
is
Begin
  -- Bug 3235390 : Added decode to get correct quantity
  Select SUM(NVL( DECODE(adl.line_num_reversed, NULL, peia.quantity,-1*peia.quantity),0))
  into x_qty
  from   pa_expenditure_items_all peia,
         gms_event_intersect      gei,
         gms_award_distributions  adl
  where  peia.expenditure_item_id = gei.expenditure_item_id
  and    adl.expenditure_item_id  = gei.expenditure_item_id
  and    adl.adl_line_num = gei.adl_line_num
  and    adl.document_type        ='EXP'
  and    adl.adl_status           ='A'
  and    gei.request_id           = X_Req_id
  and    gei.award_project_id     = X_Proj_Id
  and    gei.event_num is null;
Exception
  When no_data_found then
    x_qty:=0;
End;

------------------------------------------------------------------------------------------
-- Bug 3235390 : Introduced the following procedure
-- PROCESS_TEMP_EVENTS : This procedure is used to insert / update the temporary
--                       events stored in temporary global table  gms_events_temp_format.
------------------------------------------------------------------------------------------
PROCEDURE PROCESS_TEMP_EVENTS  (p_act_project_id IN NUMBER,
		                p_task_id        IN NUMBER,
				p_invfmt_incl_task IN VARCHAR2, /* Bug 3523930*/
		                p_format         IN VARCHAR2,
                                p_description    IN VARCHAR2,
                                p_calling_place  IN VARCHAR2,
                                p_units          IN VARCHAR2,
                                p_quantity       IN NUMBER,
		                p_amount         IN NUMBER,
                                p_event_num      OUT NOCOPY NUMBER,
			        p_err_code       IN OUT NOCOPY NUMBER,
                                p_err_buff       IN OUT NOCOPY VARCHAR2) IS


l_description    VARCHAR2(2000);

/* Added below 2 cursors for 3523930*/
CURSOR C_event_exists_PTF IS
SELECT event_num
   FROM gms_events_temp_format
WHERE act_project_id = p_act_project_id
   AND task_id = p_task_id
   AND NVL(format,'X')  = NVL(p_format,'X');

CURSOR C_event_exists_F IS
SELECT event_num
  FROM gms_events_temp_format
WHERE NVL(format,'X')  = NVL(p_format,'X');

BEGIN

     IF L_DEBUG = 'Y' THEN
 	gms_error_pkg.gms_debug('IN PROCESS_TEMP_EVENTS - START ','C');
	gms_error_pkg.gms_debug('IN PROCESS_TEMP_EVENTS - X_trans_type is '||X_trans_type,'C'); -- added debug for 5413530
	gms_error_pkg.gms_debug('IN PROCESS_TEMP_EVENTS - G_trans_type is '||G_trans_type,'C'); -- added debug for 5413530
     END IF;

     IF p_calling_place = 'Revenue' THEN
         l_description := p_description  ||'- '|| p_quantity || ' ' || p_units;
     ELSE
         l_description := p_description;
     END IF;


 OPEN C_event_exists_PTF;
 FETCH C_event_exists_PTF INTO p_event_num ;

 IF ( C_event_exists_PTF%FOUND AND
          ( ( p_format IS NULL AND X_trans_type = G_trans_type ) OR ( p_format IS NOT NULL ))) -- for bug 5413530
THEN
 --If there exists a temporary event with exact match then we dont need to bother about the p_invfmt_incl_task = 'N'
 --and update the event with the amount

	UPDATE gms_events_temp_format
           SET amount      = amount + p_amount,
               quantity    = quantity + p_quantity,
               description = decode(p_calling_place,'Revenue',p_description || '- '|| to_char(quantity + p_quantity) || ' ' ||p_units,p_description)
         WHERE event_num = p_Event_num
           AND act_project_id = p_act_project_id
           AND task_id = p_task_id
           AND nvl(format,'X') = nvl(p_format,'X'); -- for bug 5413530

        IF L_DEBUG = 'Y' THEN
 	   gms_error_pkg.gms_debug('IN PROCESS_TEMP_EVENTS - After updating  '||p_event_num||' in gms_events_temp_format with amount '||p_amount ,'C');
        END IF;

 ELSE

      IF p_invfmt_incl_task = 'N' THEN
       --If there exists no temporary event with exact match and task id is not a format column then fetch
       --the event_num which is already creatd for this format and insert new line into gms_events_temp_format with
       --same event_num but with new task_id

        OPEN C_event_exists_F;
	FETCH C_event_exists_F INTO p_event_num ;

        IF ( C_event_exists_F%NOTFOUND OR
	     ( X_trans_type <> G_trans_type AND p_format IS NULL ) ) -- for bug 5413530
	THEN
  	    --If there exists no temporary event with format match then generate new event_num
	    p_Event_num            := x_temp_negative_evt_num;
            X_temp_negative_evt_num :=x_temp_negative_evt_num-1;
	END If;
 	CLOSE C_event_exists_F;

      ELSE
          --If task is one of the column in format then generate new event as no match found
           p_Event_num            := x_temp_negative_evt_num;
	   X_temp_negative_evt_num :=x_temp_negative_evt_num-1;
      END If;

      INSERT INTO gms_events_temp_format(Event_num ,
                 		    ACT_PROJECT_ID,
		                    TASK_ID,
                                    QUANTITY,
		                    AMOUNT,
		                    FORMAT,
                                    DESCRIPTION)
        VALUES (p_event_num,
                p_act_project_id,
   	        p_task_id,
                p_quantity,
                p_Amount,
                p_format,
                l_description );

        IF L_DEBUG = 'Y' THEN
 	   gms_error_pkg.gms_debug('IN PROCESS_TEMP_EVENTS - After inserting event '||p_event_num||' into gms_events_temp_format for task '||p_task_id ||' with amount '||p_amount,'C');
        END IF;

 END IF;
 CLOSE C_event_exists_PTF;

G_trans_type := X_trans_type ;   /* For bug 5413530 */

 IF L_DEBUG = 'Y' THEN
    gms_error_pkg.gms_debug('IN PROCESS_TEMP_EVENTS - END ','C');
 END IF;

EXCEPTION
    WHEN OTHERS THEN

        IF L_DEBUG = 'Y' THEN
          gms_error_pkg.gms_debug('IN PROCESS_TEMP_EVENTS - WHEN OTHERS ','C');
        END IF;

        IF C_event_exists_F%ISOPEN THEN
	   CLOSE C_event_exists_F;
        END IF;

        IF C_event_exists_PTF%ISOPEN THEN
	   CLOSE C_event_exists_PTF;
        END IF;

        gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
                                  'SQLCODE',
                                  SQLCODE,
                                  'SQLERRM',
                                  SQLERRM,
                                  X_Exec_Type => 'C',
                                  X_Err_Code => p_Err_Code,
                                  X_Err_Buff => p_Err_Buff);
        Raise NO_PROCESSING_OF_AWARD ;

End PROCESS_TEMP_EVENTS;

---------------------------------------------------------------------------------------
--Procedure CREATE_PA_EVENTS
-----------------------------------------------------------------------------------------
-- Bug 3235390 : This newly introduced procedure does the following :
--               a. Fetches consolidated records from the plsql table
--               b. Inserts consolidated events into gms_event_attribute table
--               b. If amount <> 0 then inserts events into Pa_events and
--                  updates GEI and GEA with newly generated event_num.
--               c. If amount = 0 then updates -1 on GEA and GEI and sets the
--                  NULL events variables.
----------------------------------------------------------------------------------------------------

PROCEDURE CREATE_PA_EVENTS          (p_project_id       In NUMBER,
				     p_Calling_Process  IN VARCHAR2,
				     p_completion_date  IN DATE,
                                     p_carrying_out_org_id IN NUMBER,
                                     p_Request_Id        IN NUMBER,
                                     p_installment_total IN OUT NOCOPY inst_tab2,
				     p_Err_Code 	 IN OUT NOCOPY NUMBER,
				     p_Err_Buff 	 IN OUT NOCOPY VARCHAR2) IS

Evt_Num          NUMBER(15) := 0;
Evt_Description  VARCHAR2(2000) := NULL;
St_Error_Message VARCHAR2(2000);
St_Status        NUMBER;
X_count          NUMBER;
X_rev_amt        NUMBER(22,5);
X_bill_amt       NUMBER(22,5);

CURSOR C_get_temp_pa_events IS
SELECT event_num,
       format,
       description,
       SUM(amount) amount
  FROM gms_events_temp_format
GROUP BY event_num,format,description
ORDER BY event_num desc;

CURSOR C_get_temp_gms_events (p_evt_num NUMBER,
                              p_format  VARCHAR2,
                              p_description VARCHAR2 ) IS
SELECT act_project_id,
       task_id,
       SUM(amount) amount
  FROM gms_events_temp_format
 WHERE event_num = p_evt_num
   AND NVL(format,'X')  = NVL(p_format,'X')
   AND description = p_description
GROUP BY act_project_id,task_id;

BEGIN

 IF L_DEBUG = 'Y' THEN
    gms_error_pkg.gms_debug('IN CREATE_PA_EVENTS - START','C');
 END IF;

 FOR pa_events_rec IN  C_get_temp_pa_events LOOP

   IF nvl(pa_events_rec.amount,0) = 0 THEN
       Evt_num := -1;

       IF p_Calling_Process = 'Revenue' THEN
          X_REVRAW_NULL_EVENT_PROCESSED := TRUE;
       ELSIF p_Calling_Process = 'Invoice' THEN
          X_INVRAW_NULL_EVENT_PROCESSED := TRUE;
       END IF;

       IF L_DEBUG = 'Y' THEN
          gms_error_pkg.gms_debug('IN CREATE_PA_EVENTS - Encountered NULL event- After setting NULL event flags','C');
       END IF;
   END IF;

   FOR gms_events_rec IN  C_get_temp_gms_events(pa_events_rec.event_num,pa_events_rec.format,pa_events_rec.description) LOOP

       EVENT_WRAPPER(p_Project_Id,
	      	     gms_events_rec.act_project_id,
	             gms_events_rec.task_id,
		     p_Calling_Process,
		     gms_events_rec.amount,
                     p_installment_total,
		     NULL, -- Burden Cost Code
		     NULL, -- Exp Org
		     p_Request_Id,
		     p_Err_Code,
		     p_Err_Buff);

      IF L_DEBUG = 'Y' THEN
         gms_error_pkg.gms_debug('IN CREATE_PA_EVENTS - After EVENT_WRAPPER call for event '||pa_events_rec.event_num,'C');
         gms_error_pkg.gms_debug('IN CREATE_PA_EVENTS - After EVENT_WRAPPER call for project_id '||gms_events_rec.act_project_id,'C');
         gms_error_pkg.gms_debug('IN CREATE_PA_EVENTS - After EVENT_WRAPPER call for task_id '||gms_events_rec.task_id,'C');
         gms_error_pkg.gms_debug('IN CREATE_PA_EVENTS - After EVENT_WRAPPER call value of p_Err_Code '||p_Err_Code,'C');
         gms_error_pkg.gms_debug('IN CREATE_PA_EVENTS - After EVENT_WRAPPER call value of p_Err_Buff '||p_Err_Buff,'C');
      END IF;

      IF p_Err_Code <> 0 THEN
         Raise NO_PROCESSING_OF_AWARD ;
      END IF;

   END LOOP;

   IF pa_events_rec.amount <> 0 THEN

       IF p_Calling_Process = 'Revenue' then
          X_rev_amt  := pa_events_rec.amount;
          X_bill_amt := 0;
       ELSIF p_Calling_Process = 'Invoice' then
          X_bill_amt := pa_events_rec.amount;
          X_rev_amt  := 0;
       END IF;

       Evt_Num := pa_billing_seq.next_eventnum(p_Project_Id,NULL); -- Bug 3235390

       pa_billing_pub.insert_event(
				X_rev_amt            => X_rev_amt,
                                X_bill_amt           => X_bill_amt,
                                X_project_id         => p_project_id,
                                X_event_type         => 'AWARD_BILLING',
                                X_top_task_id        => NULL,
                                X_organization_id    => p_Carrying_Out_Org_Id,
                                X_completion_date    => p_completion_date,
                                X_event_description  => pa_events_rec.description,
                                X_event_num_reversed => NULL,
                                X_attribute_category => NULL,
                                X_attribute1         => NULL,
                                X_attribute2         => NULL,
                                X_attribute3         => NULL,
                                X_attribute4         => NULL,
                                X_attribute5         => NULL,
                                X_attribute6         => NULL,
                                X_attribute7         => NULL,
                                X_attribute8         => NULL,
                                X_attribute9         => NULL,
                                X_attribute10        => NULL,
				X_error_message      => St_Error_Message,
                                X_status             => St_Status
				);

       IF L_DEBUG = 'Y' THEN
          gms_error_pkg.gms_debug('IN CREATE_PA_EVENTS - After insert_event call for event number '||Evt_Num||' with amount '||pa_events_rec.amount,'C');
          gms_error_pkg.gms_debug('IN CREATE_PA_EVENTS - After insert_event call value of St_Error_Message '||St_Error_Message,'C');
          gms_error_pkg.gms_debug('IN CREATE_PA_EVENTS - After insert_event call value of St_Status '||St_Status,'C');
       END IF;

       IF St_Status <> 0 THEN
          RAISE NO_PROCESSING_OF_AWARD;
       END IF;



   END IF;

   UPDATE gms_event_intersect
      SET Event_Num  = Evt_num
    WHERE Event_num =  pa_events_rec.event_num
    AND award_project_id = p_project_id; /* Added for bug 4172924*/

   IF L_DEBUG = 'Y' THEN
      gms_error_pkg.gms_debug('IN CREATE_PA_EVENTS - After updating GEI ','C');
   END IF;

   EVENT_ATTRIBUTE_UPDATION( Evt_Num,
	                     p_Project_Id,
			     p_Request_Id,
			     p_Err_Code,
			     p_Err_Buff);

   IF L_DEBUG = 'Y' THEN
      gms_error_pkg.gms_debug('IN CREATE_PA_EVENTS - After EVENT_ATTRIBUTE_UPDATION value of p_Err_Code'||p_Err_Code,'C');
      gms_error_pkg.gms_debug('IN CREATE_PA_EVENTS - After EVENT_ATTRIBUTE_UPDATION value of p_Err_Buff'||p_Err_Buff,'C');
   END IF;

   IF p_Err_Code <> 0 THEN
      Raise NO_PROCESSING_OF_AWARD ;
   END IF;

 END LOOP;

 IF L_DEBUG = 'Y' THEN
    gms_error_pkg.gms_debug('IN CREATE_PA_EVENTS - END','C');
 END IF;

EXCEPTION

    When Others then

      IF L_DEBUG = 'Y' THEN
      	gms_error_pkg.gms_debug('IN CREATE_PA_EVENTS - WHEN OTHERS ','C');
      END IF;

      gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => p_Err_Code,
				X_Err_Buff => p_Err_Buff);

     RAISE NO_PROCESSING_OF_AWARD;

END CREATE_PA_EVENTS;

-----------------------------------------------------------------------------------------
-- Procedure DO_EVENT_PROCESSING: This procedure builds the Event description and creates the
-- Billing or Revenue Event
-----------------------------------------------------------------------------------------
-- Bug 3235390 : Modified the logic as mentioned below
--               a. Code to create events in pa_events and gms_event_attribute table is
--                  shifted to CREATE_PA_EVENTS procedure.
--               b. Events will be inserted into GBC and GEI and will be marked as billed/accrued.
--               c. Events will be assigned a negative seqeunce number which starts from -1001
--               d. Distinct events and their format will be temporarly stored in plsql table
--               e. Newly introduced procedure CREATE_PA_EVENTS will fetch the consolidated
--                  records from the plsql table and will insert events into Pa_events and
--                  gms_event_attribute tables and updates GEI with newly generated event_num.
--                  Even the NULL events logic is shifted to create_pa_events procedure.
----------------------------------------------------------------------------------------------------


PROCEDURE DO_EVENT_PROCESSING(X_Count_Of_Columns IN NUMBER DEFAULT 0,
                              X_Sel_Grp_Diff_Ind IN Mark_Sel_Grp_Diff_Array ,
                              X_Right_Jstfy_Flag_Array IN Mark_Sel_Grp_Diff_Array,
                              X_Values IN Selected_Values_Rows,
                              X_Padding_Length IN Padding_Length_Array,
                              X_Run_Total IN Running_Total_Array ,
                              X_Text_Array IN Free_Text_Array,
                              X_Proj_Id IN NUMBER DEFAULT NULL,
			      X_Task_Id IN NUMBER DEFAULT NULL,
			      X_invfmt_incl_task IN VARCHAR2 DEFAULT 'N', /* Bug 3523930 */
                              X_Evt_Amount IN NUMBER DEFAULT NULL,
                              X_Carry_Out_Org_Id IN NUMBER DEFAULT NULL,
                              X_Through_Date IN DATE DEFAULT SYSDATE,
                              X_Call_Process IN VARCHAR2 DEFAULT NULL,
                              X_Req_Id IN NUMBER DEFAULT NULL,
                              C_Installment_Id IN NUMBER,
			      X_Install_Count	IN NUMBER,
			      X_Installment_Total IN OUT NOCOPY Inst_tab2,
			      X_Err_Code IN OUT NOCOPY NUMBER,
			      X_Err_Buff IN OUT NOCOPY VARCHAR2) IS

CURSOR GET_RAW_ROWS_FROM_INTERSECT IS
Select
 gei.award_project_id Award_Project_Id
,adl.project_id       Actual_Project_Id
,adl.task_id          Actual_Task_Id
,sum(gei.Amount) amount
from
 gms_event_intersect gei,
 gms_award_distributions adl
where
gei.award_project_id    = X_Proj_Id  and
gei.request_id          = X_Req_Id   and
gei.event_type          = 'INVOICE'  and
gei.event_num is NULL                and
adl.expenditure_item_id = gei.expenditure_item_id and
adl.adl_line_num = gei.adl_line_num and
adl.document_type ='EXP'  and
adl.adl_status ='A'
group by
 gei.award_project_id,
 adl.project_id,
 adl.task_id;

Evt_Num NUMBER(15);
Evt_Description VARCHAR2(2000);
Evt_format VARCHAR2(2000);
X_Quantity NUMBER(22,5);

-- 3120142
x_pad1 number;
x_pad2 number;
x_pad3 number;
-- 3120142

Begin

  IF L_DEBUG = 'Y' THEN
 	gms_error_pkg.gms_debug('IN DO_EVENT_PROCESSING - START ','C');
  END IF;

  /* Building the Event Description */

  For j in 1..X_Count_Of_Columns LOOP

-- 3120142 Start
      gms_error_pkg.gms_debug('****** Evt_Description '||Evt_Description,'C');

  If X_Sel_Grp_Diff_Ind(j) = 'Y' then -- I

      --gms_error_pkg.gms_debug('****** X_Values(j) '||X_Values(j),'C');
      --gms_error_pkg.gms_debug('****** X_Padding_Length(j) '||X_Padding_Length(j),'C');
      --gms_error_pkg.gms_debug('****** length(X_Values(j)) '||length(X_Values(j)),'C');

      -- Grouping value ................... Start

      If   (X_Padding_Length(j)- length(X_Values(j))) <= 0 then
            X_pad1 := X_Padding_Length(j);
      Else
            X_pad1 := X_Padding_Length(j) - (abs(X_Padding_Length(j)- length(X_Values(j))));
      End If;
      gms_error_pkg.gms_debug('****** X_pad1 '||X_pad1,'C');

      If X_Right_Jstfy_Flag_Array(j) = 'N' then
         Evt_Description := Evt_Description||rpad(X_Values(j),X_Pad1)||' ';
      Elsif X_Right_Jstfy_Flag_Array(j) = 'Y' then
         Evt_Description := Evt_Description||lpad(X_Values(j),X_Pad1)||' ';
      End If;

      -- Grouping value ................... End
      gms_error_pkg.gms_debug('****** Evt_Description '||Evt_Description,'C');

  Elsif X_Sel_Grp_Diff_Ind(j) = 'N' then -- I
      -- Grouping Quantity ................... Start
      get_run_total(X_Req_id,X_Proj_Id,x_quantity);
      If   (X_Padding_Length(j)- length(to_char(x_quantity))) <= 0 then
            X_pad2 := X_Padding_Length(j);
      Else
            X_pad2 := X_Padding_Length(j) - (abs(X_Padding_Length(j)- length(to_char(x_quantity ))));
      End If;
      gms_error_pkg.gms_debug('****** X_pad2 '||X_pad1,'C');

      If X_Right_Jstfy_Flag_Array(j) = 'N' then
         Evt_Description := Evt_Description||rpad(to_char(x_quantity),x_pad2)||' ';
      Elsif X_Right_Jstfy_Flag_Array(j) = 'Y' then
         Evt_Description := Evt_Description||lpad(to_char(x_quantity),x_pad2)||' ';
      End If;
      -- Grouping Quantity ................... End
     gms_error_pkg.gms_debug('****** Evt_Description '||Evt_Description,'C');

  Elsif X_Sel_Grp_Diff_Ind(j) = 'T' then  -- I

    -- Grouping Text ................... Start
    If   (X_Padding_Length(j)- length(X_Text_Array(j))) <= 0 then
          X_pad3 := X_Padding_Length(j);
    Else
          X_pad3 := X_Padding_Length(j) - (abs(X_Padding_Length(j)- length(X_Text_Array(j))));
    End If;

    gms_error_pkg.gms_debug('****** X_pad3 '||X_pad3,'C');

    If X_Right_Jstfy_Flag_Array(j) = 'N' then
       Evt_Description := Evt_Description||rpad(X_Text_Array(j),x_pad3)||' ';
    Elsif X_Right_Jstfy_Flag_Array(j) = 'Y' then
       Evt_Description := Evt_Description||lpad(X_Text_Array(j),x_pad3)||' ';
    End If;

    -- Grouping Text ................... End
    gms_error_pkg.gms_debug('****** Evt_Description '||Evt_Description,'C');
 End If; -- I

-- 3120142 End

/* ------------------------------------------------------------- 3120142 --- commented out ----------------------

           If X_Sel_Grp_Diff_Ind(j) = 'Y' then
               If X_Right_Jstfy_Flag_Array(j) = 'N' then
                Evt_Description := Evt_Description||rpad(X_Values(j),X_Padding_Length(j) - (abs(X_Padding_Length(j)-
length(X_Values(j) ))))||' ';
               Elsif X_Right_Jstfy_Flag_Array(j) = 'Y' then
                 Evt_Description := Evt_Description||lpad(X_Values(j),X_Padding_Length(j) - (abs(X_Padding_Length(j)-
length(X_Values(j) ))))||' ';
               End If;
           Elsif X_Sel_Grp_Diff_Ind(j) = 'N' then

                 get_run_total(X_Req_id,X_Proj_Id,x_quantity);

               If X_Right_Jstfy_Flag_Array(j) = 'N' then
                 Evt_Description := Evt_Description||rpad(to_char(x_quantity),X_Padding_Length(j) - (abs(X_Padding_Length(j)-
length(to_char(x_quantity )))))||' ';
               Elsif X_Right_Jstfy_Flag_Array(j) = 'Y' then
                 Evt_Description := Evt_Description||rpad(to_char(x_quantity),X_Padding_Length(j) - (abs(X_Padding_Length(j)-
length(to_char(x_quantity )))))||' ';
               End If;
           Elsif X_Sel_Grp_Diff_Ind(j) = 'T' then
               If X_Right_Jstfy_Flag_Array(j) = 'N' then
                 Evt_Description := Evt_Description||rpad(X_Text_Array(j),X_Padding_Length(j) - (abs(X_Padding_Length(j)-
length(X_Text_Array(j) ))))||' ';
               Elsif X_Right_Jstfy_Flag_Array(j) = 'Y' then
                 Evt_Description := Evt_Description||rpad(X_Text_Array(j),X_Padding_Length(j) - (abs(X_Padding_Length(j)-
length(X_Text_Array(j) ))))||' ';
               End If;
           End If;
 ------------------------------------------------------------- 3120142 --- commented out ---------------------- */
   End LOOP;

   FOR i IN 1..X_Count_Of_Columns LOOP
      IF X_Sel_Grp_Diff_Ind(i) = 'Y' then
          Evt_format := Evt_format||' - '||X_values(i);
      END IF;

   END LOOP;

   IF L_DEBUG = 'Y' THEN
      gms_error_pkg.gms_debug('IN DO_EVENT_PROCESSING - Value of Evt_Description '||Evt_Description,'C');
      gms_error_pkg.gms_debug('IN DO_EVENT_PROCESSING - Value of Evt_format '||Evt_format,'C');
   END IF;

   /*x_temp_negative_evt_num := x_temp_negative_evt_num - 1 ; Bug 3523930 - Moved this into process tempevents*/
   FOR raw_events IN GET_RAW_ROWS_FROM_INTERSECT LOOP

       PROCESS_TEMP_EVENTS  (raw_events.actual_project_id,
                             raw_events.actual_task_id,
			     X_invfmt_incl_task, /* Added for bug 3523930 */
		             Evt_format,
                             Evt_Description,
                             X_Call_Process,
                             NULL,
                             NULL,
		             raw_events.amount,
                             evt_num,
    	                     x_err_code,
                             x_err_buff) ;

       IF L_DEBUG = 'Y' THEN
         gms_error_pkg.gms_debug('IN DO_EVENT_PROCESSING - After PROCESS_TEMP_EVENTS value of X_Err_Code '||X_Err_Code,'C');
         gms_error_pkg.gms_debug('IN DO_EVENT_PROCESSING - After PROCESS_TEMP_EVENTS value of x_err_buff '||x_err_buff,'C');
       END IF;

       IF X_Err_Code <> 0 then
         Raise NO_PROCESSING_OF_AWARD ;
       END IF;

      UPDATE_GMS_EVENT_INTERSECT(Evt_Num,
	  		       X_Proj_Id,
		  	       X_Req_Id,
                               raw_events.actual_project_id,
                               raw_events.actual_task_id );

      IF L_DEBUG = 'Y' THEN
         gms_error_pkg.gms_debug('IN DO_EVENT_PROCESSING - After UPDATE_GMS_EVENT_INTERSECT','C');
      END IF;

   END LOOP;

EXCEPTION
   WHEN OTHERS THEN

       IF L_DEBUG = 'Y' THEN
       	  gms_error_pkg.gms_debug('IN DO_EVENT_PROCESSING - WHEN OTHERS ','C');
       END IF;
       gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
END DO_EVENT_PROCESSING;

---------------------------------------------------------------------------------------
--Procedure DO_BURDEN_EVENT_PROCESSING
---------------------------------------------------------------------------------------
PROCEDURE DO_BURDEN_EVENT_PROCESSING(X_Project_Id   IN NUMBER,
			             X_Through_Date IN DATE,
				     X_Calling_Process IN VARCHAR2,
				     X_Carrying_Out_Org_Id IN NUMBER,
				     X_Request_Id IN NUMBER,
				     X_Installment_total IN OUT NOCOPY Inst_tab2,
				     X_Err_Code 	 IN OUT NOCOPY NUMBER,
				     X_Err_Buff 	 IN OUT NOCOPY VARCHAR2) IS

CURSOR GET_BURD_ROWS_FROM_INTERSECT IS
Select
 Award_Project_Id
,Actual_Project_Id
,Actual_Task_Id
,Burden_Cost_Code
,Expenditure_Org_Id
,sum(Amount)
from
GMS_BURDEN_COMPONENTS
where
award_project_id    = X_Project_Id  and
request_id          = X_Request_Id       and
event_type          = decode(X_Calling_Process,'Revenue','REVENUE','Invoice','INVOICE') and
event_num is NULL
group by
 Award_Project_Id
,Actual_Project_Id
,Actual_Task_Id
,Burden_Cost_Code
,Expenditure_Org_Id ;

Ins_Award_Project_Id     NUMBER := 0;
Ins_Actual_Project_Id    NUMBER := 0;
Ins_Actual_Task_Id       NUMBER := 0;
Ins_Burden_Cost_Code     VARCHAR2(30) := NULL;
Ins_Expenditure_Org_Id   NUMBER := 0;
Ins_Amount               NUMBER := 0;

Ins_Act_Proj_Num        VARCHAR2(30);
Ins_Act_Task_Num        VARCHAR2(30);
--Ins_Exp_Org_Name        VARCHAR2(60);
--The width of the variable is changed for UTF8 changes for HRMS schema. Refer bug 2302839.
Ins_Exp_Org_Name  HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE;

Evt_Num NUMBER(15) := 0;
Evt_Description VARCHAR2(2000) := NULL;

St_Error_Message VARCHAR2(2000);
St_Status NUMBER;

Begin

 IF L_DEBUG = 'Y' THEN
 	gms_error_pkg.gms_debug('IN BURDEN EVENT - START','C');
 END IF;

 OPEN GET_BURD_ROWS_FROM_INTERSECT;
 LOOP
  FETCH GET_BURD_ROWS_FROM_INTERSECT into
   Ins_Award_Project_Id
  ,Ins_Actual_Project_Id
  ,Ins_Actual_Task_Id
  ,Ins_Burden_Cost_Code
  ,Ins_Expenditure_Org_Id
  ,Ins_Amount;
          EXIT WHEN GET_BURD_ROWS_FROM_INTERSECT%NOTFOUND;

   If Ins_Amount <> 0 then
   -- DO NOT INSERT ZERO AMOUNT EVENTS
   IF L_DEBUG = 'Y' THEN
   	gms_error_pkg.gms_debug('DBP - If Ins_Amount <> 0 part ..','C');
   END IF;

       /* Getting Actual Project Number, Task Number and Expenditure Organization Name */
           Begin
             Select
               a.segment1,
               b.task_number,
               c.name
             into
               Ins_Act_Proj_Num,
  	       Ins_Act_Task_Num,
	       Ins_Exp_Org_Name
             from
             pa_projects_all a,
	     pa_tasks b,
             hr_organization_units c
             where a.project_id = Ins_Actual_Project_Id  and
		   b.task_id    = Ins_Actual_Task_Id     and
                   c.organization_id = Ins_Expenditure_Org_Id;
           End;

 --------------------------------------------------------------------------
 /* Get the Installment Number to be concatenated with Event Description */
 --------------------------------------------------------------------------
 IF L_DEBUG = 'Y' THEN
 	gms_error_pkg.gms_debug('DBP - CALL EVENT WRAPPER','C');
 END IF;
 EVENT_WRAPPER(X_Project_Id,
		Ins_Actual_Project_Id,
                Ins_Actual_Task_Id,
                X_Calling_Process,
                Ins_Amount,
                X_Installment_Total,
--                Inst_Num,		Bug 2380344
		Ins_Burden_Cost_Code,
		Ins_Expenditure_Org_Id,
		X_Request_Id,
                X_Err_Code,
                X_Err_Buff);

                If X_Err_Code <> 0 then
			--ROLLBACK;
                        --RAISE FND_API.G_EXC_ERROR;
			Raise NO_PROCESSING_OF_AWARD ;
                End If;
 IF L_DEBUG = 'Y' THEN
 	gms_error_pkg.gms_debug('DBP - AFTER EVENT WRAPPER','C');
 END IF;

-------------------------------------------------------------------------------------
       /* Getting the Event Number */
                    Evt_Num := pa_billing_seq.next_eventnum(Ins_Award_Project_Id,NULL);

 IF L_DEBUG = 'Y' THEN
 	gms_error_pkg.gms_debug('DBP - Evt_Num::'||Evt_Num,'C');
 END IF;


       /* Building the Event Description */
  Evt_Description := Ins_Act_Proj_Num||'- '||Ins_Act_Task_Num||' - '||Ins_Burden_Cost_Code||'- '||Ins_Exp_Org_Name ;	-- Bug 2380344 : Removed Inst_Num

     If X_Calling_Process = 'Revenue' then
         pa_billing_pub.insert_event(
				X_rev_amt => Ins_Amount,         /* X_rev_amt */
                                X_bill_amt => 0,                      /* X_bill_amt */
                                X_project_id => Ins_Award_Project_Id,            /* X_project_id */
                                X_event_type => 'AWARD_BILLING',             /* X_event_type */
                                X_top_task_id => NULL,                    /* X_top_task_id */
                                X_organization_id => X_Carrying_Out_Org_Id,   /* X_organization_id */
                                X_completion_date => X_Through_Date,      /* X_completion_date */
                                X_event_description => Evt_Description,     /* X_event_description */
                                X_event_num_reversed => NULL,         /* Event Num Reversed */
                                X_attribute_category => NULL,                    /* X_attribute_category */
                                X_attribute1 => NULL,	 /* X_attribute1 */
                                X_attribute2 => NULL,                    /* X_attribute2 */
                                X_attribute3 => NULL,                    /* X_attribute3 */
                                X_attribute4 => NULL,                    /* X_attribute4 */
                                X_attribute5 => NULL,                    /* X_attribute5 */
                                X_attribute6 => NULL,                    /* X_attribute6 */
                                X_attribute7 => NULL,                    /* X_attribute7 */
                                X_attribute8 => NULL,                    /* X_attribute8 */
                                X_attribute9 => NULL,                    /* X_attribute9 */
                                X_attribute10 => NULL,                     /* X_attribute10 */
				X_error_message => St_Error_Message,
                                X_status => St_Status
				);

     Elsif X_Calling_Process = 'Invoice' then

        pa_billing_pub.insert_event(
				X_rev_amt => 0,         /* X_rev_amt */
                                X_bill_amt => Ins_Amount,                      /* X_bill_amt */
                                X_project_id => Ins_Award_Project_Id,            /* X_project_id */
                                X_event_type => 'AWARD_BILLING',             /* X_event_type */
                                X_top_task_id => NULL,                    /* X_top_task_id */
                                X_organization_id => X_Carrying_Out_Org_Id,   /* X_organization_id */
                                X_completion_date => X_Through_Date,      /* X_completion_date */
                                X_event_description => Evt_Description,     /* X_event_description */
                                X_event_num_reversed => NULL,         /* Event Num Reversed */
                                X_attribute_category => NULL,                    /* X_attribute_category */
                                X_attribute1 => NULL, /* X_attribute1 */
                                X_attribute2 => NULL,                    /* X_attribute2 */
                                X_attribute3 => NULL,                    /* X_attribute3 */
                                X_attribute4 => NULL,                    /* X_attribute4 */
                                X_attribute5 => NULL,                    /* X_attribute5 */
                                X_attribute6 => NULL,                    /* X_attribute6 */
                                X_attribute7 => NULL,                    /* X_attribute7 */
                                X_attribute8 => NULL,                    /* X_attribute8 */
                                X_attribute9 => NULL,                    /* X_attribute9 */
                                X_attribute10 => NULL,                     /* X_attribute10 */
				X_error_message => St_Error_Message,
                                X_status => St_Status
				);
     End If;

     IF L_DEBUG = 'Y' THEN
     	gms_error_pkg.gms_debug('After API Event->Status Code,Message:'||St_Status||','||St_Error_Message,'C');
     END IF;
     If St_Status <> 0 then

        IF L_DEBUG = 'Y' THEN
        	gms_error_pkg.gms_debug('!!! IN Burden EVENT - API Call Exception !!! ','C');
        END IF;
        RAISE NO_PROCESSING_OF_AWARD;

     End If;

     IF L_DEBUG = 'Y' THEN
     	gms_error_pkg.gms_debug('DBP - After Event Creation','C');
     END IF;

    /* ------------------------------------------------------------------------------- */
    -- Updating Event Attribute

    EVENT_ATTRIBUTE_UPDATION(Evt_Num,
                             X_Project_Id,
                             X_Request_Id,
                             X_Err_Code,
                             X_Err_Buff);

                If X_Err_Code <> 0 then
			Raise NO_PROCESSING_OF_AWARD ;
                End If;

    IF L_DEBUG = 'Y' THEN
    	gms_error_pkg.gms_debug('DBP - After Event Attribute Updation','C');
    END IF;

 ElsIf Ins_Amount = 0 then

    IF L_DEBUG = 'Y' THEN
    	gms_error_pkg.gms_debug('DBP - In Ins_Amount = 0 part ...','C');
    END IF;

    -- ------------------------------------------------------------------------------------
    -- Event num NULL change ...
    -- -------------------------
    -- If event amount  = 0 , update GBC record with event_num of -2. Set package variable
    -- indicating that there are burden records created with event num -2. In procedure
    -- award_billing, there is a check for this flag. If flag is set, then procedure
    -- DELETE_NULL_EVENTS will be called.
    -- Event Number is -2 so that billing_rollback does not rollback events..
    -- ------------------------------------------------------------------------------------
              Evt_Num := -2;

              -- Set package variable to TRUE, accessed in award_billing procedure..
              X_BURDEN_NULL_EVENT_PROCESSED := TRUE;

    End If; -- DO NOT INSERT ZERO AMOUNT EVENTS

   /* ------------------------------------------------------------------------------- */
   -- Updating Burden Components

              UPDATE_GMS_BURDEN_COMPONENTS(Evt_Num ,
                                           Ins_Award_Project_Id,
                                           X_Request_Id ,
                                           Ins_Actual_Project_Id ,
                                       	   Ins_Actual_Task_Id ,
                                           Ins_Burden_Cost_Code ,
                                           Ins_Expenditure_Org_Id );

   IF L_DEBUG = 'Y' THEN
   	gms_error_pkg.gms_debug('DBP - After GBC Updation','C');
   END IF;

  End LOOP;

  IF L_DEBUG = 'Y' THEN
  	gms_error_pkg.gms_debug('IN BURDEN EVENT - END','C');
  END IF;

Exception

    When Others then

      IF L_DEBUG = 'Y' THEN
      	gms_error_pkg.gms_debug('IN BURDEN EVENT WHEN OTHERS ','C');
      END IF;

      gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);

     RAISE NO_PROCESSING_OF_AWARD;

End DO_BURDEN_EVENT_PROCESSING;
---------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------
--Procedure DO_REV_EVENT_PROCESSING
-----------------------------------------------------------------------------------------
-- Bug 3235390 : Modified the logic as mentioned below
--               a. Code to create events in pa_events and gms_event_attribute table is
--                  shifted to CREATE_PA_EVENTS procedure.
--               b. Events will be inserted into GBC and GEI and will be marked as billed/accrued.
--               c. Events will be assigned a negative seqeunce number which starts from -1001
--               d. Distinct events and their format will be temporarly stored in plsql table
--               e. Newly introduced procedure CREATE_PA_EVENTS will fetch the consolidated
--                  records from the plsql table and will insert events into Pa_events and
--                  gms_event_attribute tables and updates GEI with newly generated event_num.
--                  Even the NULL events logic is shifted to create_pa_events procedure.
----------------------------------------------------------------------------------------------------

PROCEDURE  DO_REV_EVENT_PROCESSING(X_Act_Project_Id          IN NUMBER,
                   	           X_Task_Id                 IN NUMBER,
                                   X_Expenditure_Type        IN VARCHAR2,
                                   X_Expenditure_Org_Id      IN NUMBER,
				   X_Units		     IN VARCHAR2,
                                   X_Rev_Run_Total           IN NUMBER,
                                   X_Project_Id              IN NUMBER,
                                   X_Rev_Event_Amount        IN NUMBER,
                                   X_Rev_Carrying_Out_Org_Id IN NUMBER,
                                   X_rev_or_bill_date        IN DATE,
                                   X_calling_process	     IN VARCHAR2,
                                   X_Request_id              IN NUMBER,
                                   C_Installment_Id          IN NUMBER,
			           X_Install_Count	     IN NUMBER,
			           X_Installment_Total       IN OUT NOCOPY Inst_tab2,
			           X_Err_Code 		     IN OUT NOCOPY NUMBER,
			           X_Err_Buff 	 	     IN OUT NOCOPY VARCHAR2) IS

CURSOR GET_RAW_ROWS_FROM_INTERSECT IS
SELECT 'Y'
  FROM gms_event_intersect gei,
       gms_award_distributions adl
 WHERE gei.award_project_id    = X_Project_Id
   AND gei.request_id          = X_Request_Id
   AND gei.event_type          = 'REVENUE'
   AND gei.event_num is NULL
   AND adl.expenditure_item_id = gei.expenditure_item_id
   AND adl.adl_line_num = gei.adl_line_num
   AND adl.document_type ='EXP'
   AND adl.adl_status ='A'
   AND adl.project_id          = X_Act_Project_Id
   AND adl.task_id             = X_Task_Id
   AND ROWNUM =1 ;

Evt_Num NUMBER(15);
Evt_Description VARCHAR2(2000);
--Inst_Num VARCHAR2(15);	Bug 2380344
Ins_Act_Proj_Num VARCHAR2(30);
Ins_Act_Task_Num VARCHAR2(30);
--Ins_Exp_Org_Name VARCHAR2(60);
-- The widht of the variable is changed for UTF8 changes for HRMS schema. Refer bug 2302839.
Ins_Exp_Org_Name  HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE;
Evt_format VARCHAR2(2000);
X_event_exists VARCHAR2(1);

Begin

 IF L_DEBUG = 'Y' THEN
    gms_error_pkg.gms_debug('IN DO_REV_EVENT_PROCESSING - START','C');
 END IF;

 OPEN GET_RAW_ROWS_FROM_INTERSECT;
 FETCH GET_RAW_ROWS_FROM_INTERSECT INTO X_event_exists;

 IF GET_RAW_ROWS_FROM_INTERSECT%FOUND THEN

     /* Getting Actual Project Number, Task Number and Expenditure Organization Name */
     Begin
             Select
               a.segment1,
               b.task_number,
               c.name
             into
               Ins_Act_Proj_Num,
  	       Ins_Act_Task_Num,
	       Ins_Exp_Org_Name
             from
             pa_projects_all a,
	     pa_tasks b,
             hr_organization_units c
             where a.project_id = X_Act_Project_Id  and
		   b.task_id    = X_Task_Id     and
                   c.organization_id = X_Expenditure_Org_Id;
     End;

     --Concatenating Installment Number to Event Description
     Evt_Description := Ins_Act_Proj_Num||'- '||Ins_Act_Task_Num||' - '||X_Expenditure_Type;
     --Moved X_Rev_Run_Total and X_Units concatenation to PROCESS_TEMP_EVENTS procedure
     ---||'- '||to_char(X_Rev_Run_Total)||' '||X_Units; -- Bug 2380344 : Removed inst_num
     Evt_format      := X_Act_Project_Id||' - '||X_Task_Id||' - '||X_Expenditure_Type||' - '||X_Expenditure_Org_Id ; -- Bug 3235390

     IF L_DEBUG = 'Y' THEN
        gms_error_pkg.gms_debug('IN DO_REV_EVENT_PROCESSING - Value of Evt_Description '||Evt_Description,'C');
        gms_error_pkg.gms_debug('IN DO_REV_EVENT_PROCESSING - Value of Evt_format '||Evt_format,'C');
     END IF;

   /*x_temp_negative_evt_num := x_temp_negative_evt_num - 1 ; Bug 3523930 - Moved this into process tempevents*/
     PROCESS_TEMP_EVENTS  (X_Act_Project_Id,
                           X_task_id,
			   'Y',  /* Added for bug 3523930 */
                           Evt_format,
                           Evt_Description,
                           X_calling_process,
                           X_Units,
                           X_Rev_Run_total,
                           X_Rev_Event_Amount,
                           evt_num,
    	                   x_err_code,
                           x_err_buff) ;

     IF L_DEBUG = 'Y' THEN
        gms_error_pkg.gms_debug('IN DO_REV_EVENT_PROCESSING - After PROCESS_TEMP_EVENTS value of X_Err_Code '||X_Err_Code,'C');
        gms_error_pkg.gms_debug('IN DO_REV_EVENT_PROCESSING - After PROCESS_TEMP_EVENTS value of x_err_buff '||x_err_buff,'C');
     END IF;

     IF X_Err_Code <> 0 then
        Raise NO_PROCESSING_OF_AWARD ;
     END IF;


      UPDATE_GMS_EVENT_INTERSECT(Evt_Num,
	  		       X_Project_Id,
		  	       X_Request_Id,
                               X_Act_Project_Id,
                               X_Task_Id );

     IF L_DEBUG = 'Y' THEN
        gms_error_pkg.gms_debug('IN DO_REV_EVENT_PROCESSING - After UPDATE_GMS_EVENT_INTERSECT','C');
      	gms_error_pkg.gms_debug('IN DO_REV_EVENT_PROCESSING - END','C');
     END IF;

  END IF;
  CLOSE GET_RAW_ROWS_FROM_INTERSECT;

End DO_REV_EVENT_PROCESSING;

-------------------------------------------------------------------------------------------
--Procedure GET_BURDEN_COMPONENT_DATA returns the burden_components and the burden amounts
-------------------------------------------------------------------------------------------
PROCEDURE GET_BURDEN_COMPONENT_DATA(P_project_id              IN NUMBER,
				    P_task_id                 IN NUMBER,
				    P_expenditure_org_id      IN NUMBER,
				    P_ind_compiled_set_id     IN NUMBER,
			            P_burdenable_raw_cost     IN NUMBER,
				    P_expenditure_type        IN VARCHAR2,
				    P_Burden_Components_Count OUT NOCOPY   NUMBER,
				    P_Burden_Component_Data   OUT NOCOPY   Burden_Component_Tab_Type )IS

CURSOR Get_Components_Cursor IS
SELECT cm.ind_cost_code,
       icc.expenditure_type icc_expenditure_type,
       sum(pa_currency.round_currency_amt (P_burdenable_raw_cost * cm.compiled_multiplier)) Tot_Exp_Item_Burden_Cost
   FROM pa_ind_cost_codes icc,
       pa_compiled_multipliers cm,
       --pa_ind_compiled_sets ics,  /* For bug 6969435 */
       pa_cost_base_exp_types cbet,
       PA_COST_BASE_COST_CODES CBCC /* For bug 6969435 */
       --pa_cost_bases cb,/* For bug 6969435 */
       --pa_ind_rate_sch_revisions irsr,/* For bug 6969435 */
       --pa_ind_rate_schedules_all_bg irs/* For bug 6969435 */
 WHERE --ics.ind_rate_sch_revision_id = irsr.ind_rate_sch_revision_id/* For bug 6969435 */
   --AND irs.ind_rate_sch_id          = irsr.ind_rate_sch_id/* For bug 6969435 */
   --AND irsr.cost_plus_structure     = cbet.cost_plus_structure/* For bug 6969435 */
    cbet.cost_base               = cm.cost_base
   --AND cb.cost_base                 = cbet.cost_base/* For bug 6969435 */
   --AND ics.cost_base                = cbet.cost_base/* For bug 6969435 */
   --AND cb.cost_base_type            = cbet.cost_base_type/* For bug 6969435 */
   AND cbet.cost_base_type          = 'INDIRECT COST'
   AND cbet.expenditure_type        = P_expenditure_type
   --AND ics.organization_id          = P_expenditure_org_id/* For bug 6969435 */
   --AND ics.ind_compiled_set_id      = cm.ind_compiled_set_id/* For bug 6969435 */
   AND icc.ind_cost_code            = cm.ind_cost_code
   AND cm.ind_compiled_set_id      = P_ind_compiled_set_id /* For bug 6969435 */
   AND cbcc.cost_plus_structure     = cbet.cost_plus_structure   /* For bug 6969435 */
   AND cbcc.cost_base               = cbet.cost_base             /* For bug 6969435 */
   AND cbcc.cost_base_type          = cbet.cost_base_type        /* For bug 6969435 */
   AND cm.cost_base_cost_code_Id    = cbcc.cost_base_cost_code_Id /* For bug 6969435 */
   AND cm.ind_cost_code             = cbcc.ind_cost_code  /* For bug 6969435 */
   and cm.compiled_multiplier <> 0
   group by cm.ind_cost_code, icc.expenditure_type;

St_Burden_Components_Count NUMBER := 0;

Begin

   FOR Get_Components_Record IN Get_Components_Cursor
   LOOP
    --  commenting this out so that datafixes will work  ...differential billing ..
    --If Get_Components_Record.Tot_Exp_Item_Burden_Cost <> 0 then
     St_Burden_Components_Count := St_Burden_Components_Count + 1;
     P_Burden_Component_Data(St_Burden_Components_Count).Actual_Project_Id       := P_Project_Id;
     P_Burden_Component_Data(St_Burden_Components_Count).Actual_Task_Id          := P_Task_Id;
     P_Burden_Component_Data(St_Burden_Components_Count).Expenditure_Org_Id      := P_expenditure_org_id;
     P_Burden_Component_Data(St_Burden_Components_Count).Burden_Expenditure_Type := Get_Components_Record.Icc_Expenditure_Type;
     P_Burden_Component_Data(St_Burden_Components_Count).Burden_Cost_Code        := Get_Components_Record.Ind_Cost_Code;
     P_Burden_Component_Data(St_Burden_Components_Count).Burden_Cost             := Get_Components_Record.Tot_Exp_Item_Burden_Cost;
   --End If;
  END LOOP;

     P_Burden_Components_Count := St_Burden_Components_Count;

End GET_BURDEN_COMPONENT_DATA;
-----------------------------------------------------------------------------------------
-- Procedure FORMAT_SPECIFIC_BILLING: This procedure is the core of the billing extension. It
-- builds the select statement given the Invoice Format Details, execution of which then processes
-- all the expenditure items which meet the selection criteria. This procedure is executed once for
-- each installment within the Award being processed. The expenditure items picked up have to have
-- an expenditure item date which falls within the start and end date of the installment. This procedure
-- also checks to see that the amount on the expenditure items doesnot exceed the amount left on the
-- installment that can be billed.
-----------------------------------------------------------------------------------------
PROCEDURE FORMAT_SPECIFIC_BILLING(X_Project_Id IN NUMBER,
                                  X_Award_Id IN NUMBER,
                                  X_Class_Category IN VARCHAR2,
                                  X_rev_or_bill_date IN DATE,
   				  --X_Revenue_Limit_Flag IN VARCHAR2,
   				                  X_Invoice_Limit_Flag IN VARCHAR2, /*Bug 6642901*/
                                  X_Request_Id IN NUMBER,
                                  X_Sel_Grp_Diff_Array IN Mark_Sel_Grp_Diff_Array,
                                  X_Cnt_Of_Columns_Selected IN NUMBER,
                                  X_Rt_Jstfy_Flag_Array IN Mark_Sel_Grp_Diff_Array,
                                  X_Padding_Length_Array IN Padding_Length_Array,
                                  X_Text_Array IN Free_Text_Array,
                                  X_sql_select IN VARCHAR2,
                                  X_Carrying_Out_Org_Id IN NUMBER,
                                  X_calling_process IN VARCHAR2,
				  X_invfmt_incl_task IN VARCHAR2,  /* Added for bug 3523930 */
                                  C_Installment_Id IN NUMBER,
                                  C_Start_Date_Active IN DATE,
                                  C_End_Date_Active IN DATE,
                                  X_Err_Num OUT NOCOPY NUMBER,
                                  X_Err_Stage OUT NOCOPY VARCHAR2,
				  g_mode IN VARCHAR2,               /* added for bug 5026657 */
				  g_labor_exp_to_process OUT NOCOPY VARCHAR2,        /* added for bug 5026657 */
				  g_non_labor_neg_exp_processed OUT NOCOPY VARCHAR2  /* added for bug 5026657 */
				  ) IS
X_Run_Total Running_Total_Array;
X_Old_Values Selected_Values_Rows;
X_New_Values Selected_Values_Rows;

cur_select INTEGER := 0;
X_Rows_Processed INTEGER := 0;
X_Expenditure_Item_Id 		PA_EXPENDITURE_ITEMS_ALL.EXPENDITURE_ITEM_ID%TYPE;
X_Expenditure_Item_Date   	PA_EXPENDITURE_ITEMS_ALL.EXPENDITURE_ITEM_DATE%TYPE;
X_Task_Id                 	PA_EXPENDITURE_ITEMS_ALL.TASK_ID%TYPE;
X_Bill_Hold_Flag          	PA_EXPENDITURE_ITEMS_ALL.BILL_HOLD_FLAG%TYPE; --VARCHAR2(1);
X_Billable_Flag           	PA_EXPENDITURE_ITEMS_ALL.BILLABLE_FLAG%TYPE;  --VARCHAR2(1);
X_Adjusted_Expenditure_Item_Id  PA_EXPENDITURE_ITEMS_ALL.ADJUSTED_EXPENDITURE_ITEM_ID%TYPE;
X_First_Indicator         	BOOLEAN := TRUE;

-- 11.5 Changes Start
X_Adl_Line_Num			gms_award_distributions.adl_line_num%type;
X_Cdl_Line_Num			gms_award_distributions.cdl_line_num%type; --bug 2909746
X_Parent_Adl_Line_Num		gms_award_distributions.parent_adl_line_num%type;
X_Adl_Status			gms_award_distributions.adl_status%type;
X_Bill_Award_Id			gms_award_distributions.award_id%type;
St_Err_Code  NUMBER(1);
St_Err_Buff    Varchar2(2000);
X_Installment_Status Varchar2(1) :=null;
X_Count  Number :=0;
X_Money_On_Curr_Inst number(22,5);
-- 11.5 Changes End

X_Money_Left_In_Inst  NUMBER(22,5) := 0;  -- Amount left in Installment that can be billed
X_Total_Funding_Amount NUMBER(22,5) := 0; -- Total Funding by Installment,Task for a particular Project
X_Total_Rev_Bill_Amount  NUMBER(22,5) := 0; -- Total Revenue or Billed Amount(Depending on the Calling Process)
                                            -- by Installment, Task for a particular Project
X_Raw_Cost PA_EXPENDITURE_ITEMS_ALL.RAW_COST%TYPE; -- Amount on the Current Transaction being Processed
X_Amount_In_Intersect NUMBER(22,5) := 0; -- Sum of Amounts in Intersect table for current Trx being processed
X_Amount_To_Insert NUMBER(22,5) := 0; -- Amount to be Inserted into Intersect Table,(X_Raw_Cost - X_Amount_In_Intersect)
X_Event_Amount NUMBER(22,5) := 0; -- Running total for the Amount for which Event is to be created
C_Inst_Task_Run_Total NUMBER(22,5):= 0; -- Running Total for the amount that will be billed on this Installment.
                               -- Adds the amount on the Trx being processed to current total. When processing is done for
                               -- this Installment, this amount will be added to the existing billed amount on Installment
                               -- and Installment updated with the total amount.
X_Amount_To_Accrue_Bill_Insert NUMBER;

X_Err_Nbr NUMBER(15) := NULL;
X_Err_Stg VARCHAR2(200) := NULL;

X_Lock_Exp_Id  VARCHAR2(30);

X_Adl_Lock_Exp_Id  gms_award_distributions.expenditure_item_id%type; -- 11.5 change

X_Orig_Item_Billed_Flag  VARCHAR2(2);
X_Actual_project_id NUMBER(15);
X_Adl_Orig_Item_Billed_Flag VARCHAR2(1); -- 11.5 change

X_Burden_Component_Data     Burden_Component_Tab_Type;
X_Burden_Components_Count   NUMBER := 0;
X_Amt_In_Tmp_By_Component       NUMBER := 0;
X_Tot_Burd_Amt_In_Tmp      NUMBER := 0;
X_Tot_Burden_Amt_In_View	  NUMBER := 0;
X_Burd_Amt_To_Insert_By_Comp    NUMBER := 0;
X_Tot_Burd_Amt_To_Insert     NUMBER := 0;

/* bug 5242484 start */
X_old_expenditure_item_id NUMBER(15) := -9999 ;
X_event_rollback_amount NUMBER(22,5) := 0;
k NUMBER := 0;
/* bug 5242484 end */

/* Bug 3523930 Start*/
X_old_task_id pa_expenditure_items_all.task_id%type;
X_new_task_id pa_expenditure_items_all.task_id%type;
X_old_actprj_id pa_expenditure_items_all.project_id%type;
X_new_actprj_id pa_expenditure_items_all.project_id%type;
/* Bug 3523930 End*/
ss_text VARCHAR2(300);
RESOURCE_BUSY EXCEPTION;
PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -00054);

 -- Bug 3630577 : performance fix ..
X_expenditure_type    pa_expenditure_items_all.expenditure_type%type;
X_expenditure_org_id  pa_expenditure_items_all.override_to_organization_id%type;
X_ind_compiled_set_id pa_cost_distribution_lines_all.ind_compiled_set_id%type;
X_burdenable_raw_cost gms_award_distributions.burdenable_raw_cost%type;
X_transaction_source  pa_transaction_sources.transaction_source%type;

Begin

  /* To set project_id NULL to be able to use Suresh's view to derive Burden Components and Burden Cost */
      -- GMS_BURDEN_COSTING.SET_CURRENT_PROJECT_ID(NULL);
       -- The above line has been commented out NOCOPY for bug 2442827

  /* bug 5026657  */
g_labor_exp_to_process := 'N';
g_non_labor_neg_exp_processed := 'N';

  -- dbms_output.put_line(X_sql_select);
  cur_select := DBMS_SQL.OPEN_CURSOR;
-----------------------------------------------------------
 -- Initializing Old Values Table and New Values Table
   For i in 1..X_Cnt_Of_Columns_Selected LOOP
     X_Old_Values(i) := NULL;
     X_New_Values(i) := NULL;
     X_Run_Total(i) := 0;
   END LOOP;
/* Bug 3523930 Start -Initializing the Project and task values too*/
X_old_task_id := NULL;
X_new_task_id :=NULL;
X_old_actprj_id :=NULL;
X_new_actprj_id :=NULL;
/* Bug 3523930 End*/
------------------------------------------------------------
--------------------------------------------------------------------
-- Parsing the Select statement and defining Bind Variable for the --
-- Input parameter Project Id --
  DBMS_SQL.PARSE(cur_select,X_sql_select,dbms_sql.native);
  --dbms_output.put_line('After Parse');
  DBMS_SQL.BIND_VARIABLE(cur_select,':X_Award_Id', X_Award_Id);
  DBMS_SQL.BIND_VARIABLE(cur_select,':X_rev_or_bill_date',X_rev_or_bill_date);
--  DBMS_SQL.BIND_VARIABLE(cur_select,':C_Start_Date_Active',C_Start_Date_Active);
  DBMS_SQL.BIND_VARIABLE(cur_select,':C_End_Date_Active',C_End_Date_Active);
 --dbms_output.put_line('After Bind');
    DBMS_SQL.BIND_VARIABLE(cur_select,':C_Installment_id',C_Installment_id);
---------------------------------------------------------------------
----------------------------------------------------------
-- Defining Fetch Variables for all the Columns Fetched --
  For i in 1..X_Cnt_Of_Columns_Selected LOOP
     DBMS_SQL.DEFINE_COLUMN(cur_select,i, X_Old_Values(i),1000);
  END LOOP;
     DBMS_SQL.DEFINE_COLUMN(cur_select,X_Cnt_Of_Columns_Selected + 1, X_Raw_Cost);
     DBMS_SQL.DEFINE_COLUMN(cur_select,X_Cnt_Of_Columns_Selected + 2, X_Expenditure_Item_Id);
     DBMS_SQL.DEFINE_COLUMN(cur_select,X_Cnt_Of_Columns_Selected + 3, X_Expenditure_Item_Date);
     DBMS_SQL.DEFINE_COLUMN(cur_select,X_Cnt_Of_Columns_Selected + 4, X_Task_Id);
     DBMS_SQL.DEFINE_COLUMN(cur_select,X_Cnt_Of_Columns_Selected + 5, X_Bill_Hold_Flag,1);
     DBMS_SQL.DEFINE_COLUMN(cur_select,X_Cnt_Of_Columns_Selected + 6, X_Billable_Flag,1);
     DBMS_SQL.DEFINE_COLUMN(cur_select,X_Cnt_Of_Columns_Selected + 7, X_Adjusted_Expenditure_Item_Id);

-- 11.5 Changes Start
     DBMS_SQL.DEFINE_COLUMN(cur_select,X_Cnt_Of_Columns_Selected + 8,  X_Adl_Line_Num);
     DBMS_SQL.DEFINE_COLUMN(cur_select,X_Cnt_Of_Columns_Selected + 9,  X_Parent_Adl_Line_Num);
     DBMS_SQL.DEFINE_COLUMN(cur_select,X_Cnt_Of_Columns_Selected + 10, X_Adl_Status,1);
     DBMS_SQL.DEFINE_COLUMN(cur_select,X_Cnt_Of_Columns_Selected + 11, X_Bill_Award_Id);
     DBMS_SQL.DEFINE_COLUMN(cur_select,X_Cnt_Of_Columns_Selected + 12, X_Actual_Project_Id);
     DBMS_SQL.DEFINE_COLUMN(cur_select,X_Cnt_Of_Columns_Selected + 13, X_Cdl_Line_Num); --bug 2909746
-- 11.5 Changes End
 -- Bug 3630577 : performance fix ..
     DBMS_SQL.DEFINE_COLUMN(cur_select,X_Cnt_Of_Columns_Selected + 14, X_expenditure_type,30);
     DBMS_SQL.DEFINE_COLUMN(cur_select,X_Cnt_Of_Columns_Selected + 15, X_expenditure_org_id);
     DBMS_SQL.DEFINE_COLUMN(cur_select,X_Cnt_Of_Columns_Selected + 16, X_ind_compiled_set_id);
     DBMS_SQL.DEFINE_COLUMN(cur_select,X_Cnt_Of_Columns_Selected + 17, X_burdenable_raw_cost);
     DBMS_SQL.DEFINE_COLUMN(cur_select,X_Cnt_Of_Columns_Selected + 18, X_transaction_source,30);

----------------------------------------------------------------
----------------------------------------------------
-- Executing the Cursor cur_select --
   X_Rows_Processed := DBMS_SQL.EXECUTE(cur_select);
----------------------------------------------------
--------------------------------------------------------------------
-- Beginning Loop to process rows returned from Cursor cur_select for current Installment --
LOOP

 BEGIN

    SAVEPOINT EXPENDITURE_ITEM_PROCESSING;

  --dbms_output.put_line('In Loop');

/*$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$*/

   If DBMS_SQL.FETCH_ROWS(cur_select) > 0 then --Start of 'Cursor_Rows_Check_If'

      /* Initializing the X_Burden_Component_Data table */
          X_Burden_Component_Data.DELETE;

      DBMS_SQL.COLUMN_VALUE(cur_select,X_Cnt_Of_Columns_Selected + 1, X_Raw_Cost);
         --dbms_output.put_line('Raw Cost '||to_char(X_Raw_Cost));
      DBMS_SQL.COLUMN_VALUE(cur_select,X_Cnt_Of_Columns_Selected + 2, X_Expenditure_Item_Id);
          --dbms_output.put_line('Exp Item Id '||to_char(X_Expenditure_Item_Id));
      DBMS_SQL.COLUMN_VALUE(cur_select,X_Cnt_Of_Columns_Selected + 3, X_Expenditure_Item_Date);
          --dbms_output.put_line('Exp Item Date '||to_char(X_Expenditure_Item_Date));
      DBMS_SQL.COLUMN_VALUE(cur_select,X_Cnt_Of_Columns_Selected + 4, X_Task_Id);
          --dbms_output.put_line('Task Id'||to_char(X_Task_Id));
      DBMS_SQL.COLUMN_VALUE(cur_select,X_Cnt_Of_Columns_Selected + 5, X_Bill_Hold_Flag);
          --dbms_output.put_line('Bill Hold Flag'||X_Bill_Hold_Flag);
      DBMS_SQL.COLUMN_VALUE(cur_select,X_Cnt_Of_Columns_Selected + 6, X_Billable_Flag);

          --dbms_output.put_line('Billable Flag '||X_Billable_Flag);
      DBMS_SQL.COLUMN_VALUE(cur_select,X_Cnt_Of_Columns_Selected + 7, X_Adjusted_Expenditure_Item_Id);
          --dbms_output.put_line('Adjusted Expenditure Item Id '||X_Adjusted_Expenditure_Item_Id);

--11.5 Changes Start

      DBMS_SQL.COLUMN_VALUE(cur_select,X_Cnt_Of_Columns_Selected + 8, X_Adl_Line_Num);
      DBMS_SQL.COLUMN_VALUE(cur_select,X_Cnt_Of_Columns_Selected + 9, X_Parent_Adl_Line_Num);
      DBMS_SQL.COLUMN_VALUE(cur_select,X_Cnt_Of_Columns_Selected + 10,X_Adl_Status);
      DBMS_SQL.COLUMN_VALUE(cur_select,X_Cnt_Of_Columns_Selected + 11,X_Bill_Award_Id);
      DBMS_SQL.COLUMN_VALUE(cur_select,X_Cnt_Of_Columns_Selected + 12,X_Actual_Project_Id);
      DBMS_SQL.COLUMN_VALUE(cur_select,X_Cnt_Of_Columns_Selected + 13,X_Cdl_Line_Num); --bug 2909746

--11.5 Changes End
 -- Bug 3630577 : performance fix ..
      DBMS_SQL.COLUMN_VALUE(cur_select,X_Cnt_Of_Columns_Selected + 14,X_expenditure_type);
      DBMS_SQL.COLUMN_VALUE(cur_select,X_Cnt_Of_Columns_Selected + 15,X_expenditure_org_id);
      DBMS_SQL.COLUMN_VALUE(cur_select,X_Cnt_Of_Columns_Selected + 16,X_ind_compiled_set_id);
      DBMS_SQL.COLUMN_VALUE(cur_select,X_Cnt_Of_Columns_Selected + 17,X_burdenable_raw_cost);
      DBMS_SQL.COLUMN_VALUE(cur_select,X_Cnt_Of_Columns_Selected + 18,X_transaction_source);

IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('Expenditure Item Id :'||X_Expenditure_Item_Id,'C');
	gms_error_pkg.gms_debug('X_Adl_Line_Num:'||X_Adl_Line_Num,'C');
	gms_error_pkg.gms_debug('X_Cdl_Line_Num:'||X_Cdl_Line_Num,'C'); --bug 2909746
	gms_error_pkg.gms_debug('X_Expenditure_Item_Date:'||X_Expenditure_Item_Date,'C');
	gms_error_pkg.gms_debug('X_Raw_Cost:'||X_Raw_Cost,'C');
	gms_error_pkg.gms_debug('X_Bill_Hold_Flag:'||X_Bill_Hold_Flag,'C');
END IF;

    -- Lock the Expenditure Item
       select expenditure_item_id
       into
       X_Lock_Exp_Id
       from
       pa_expenditure_items_all
       where
       expenditure_item_id = X_Expenditure_Item_Id
       FOR UPDATE NOWAIT;

-- 11.5 Change, Lock Adl Expenditure Item too

	select expenditure_item_id
        into
	X_Adl_Lock_Exp_Id
	from
	gms_award_distributions
	where expenditure_item_id = X_Expenditure_Item_Id
	and   adl_line_num=X_Adl_Line_Num
	and   document_type='EXP'
	and   adl_status = 'A'
	FOR UPDATE NOWAIT;

/* This is to see that the Adjusting Expenditure Item is picked up first for Billing */
-- 11.5 change, pick billed_flag from adl table and award_id required in where clause
--Bug 3235390 commented out
/*
If X_Adjusted_Expenditure_Item_Id IS NOT NULL then
 Begin
  Select
    nvl(adl.billed_flag,'N')
  into
    X_Orig_Item_Billed_Flag
  from
    gms_award_distributions adl
  where
    expenditure_item_id = X_Adjusted_Expenditure_Item_Id
  and
    award_id = X_Bill_award_id
  and
    adl_status='A'
  and
    document_type ='EXP'
  and
    adl_line_num =
                   (select max(adl_line_num)
		    from   gms_award_distributions
		    where  expenditure_item_id = X_Adjusted_Expenditure_Item_Id
		    and    award_id = X_Bill_award_id
		    and    adl_status='A'
		    and    document_type ='EXP');
 End;

End If; */ --Bug 3235390

-----------------------------------------------------------------------------------------------------
   /*Resetting Burden Totals from View and Tmp table to zero for every Exp Item being processed */
    X_Tot_Burd_Amt_In_Tmp    := 0;
    X_Tot_Burden_Amt_In_View := 0;
    X_Tot_Burd_Amt_To_Insert := 0;
    X_UPD_BILLING_FLAG := FALSE; -- Bug 3254097 : Intializing the flag

----------------------------------------------------------------------------------------------------


   /* If (X_Adjusted_Expenditure_Item_Id IS NOT NULL and X_Orig_Item_Billed_Flag <> 'Y' ) then

       GOTO  DO_NOT_PROCESS;  DO NOT GO ANY FURTHER WITH PROCESSING OF THIS ITEM

    End If; */  --Bug 3235390: Commented out

--------------------------------------------------------------------
       -- Rounding fix : Bug 1417062

        X_Raw_Cost := pa_currency.round_currency_amt(nvl(X_Raw_Cost,0));

         -----------------------------------------------------------------------------
         /* For the particular Installment,Task get Total Billed Amount and Total Funding Amount */
 	   GET_SUMM_FUNDING(NULL, -- C_Installment_Id, Made Null for 11.5
                            X_Expenditure_Item_Date,
                            X_Award_Id,
                            X_Task_Id,
                            X_calling_process,
                            X_Total_Funding_Amount,
                            X_Total_Rev_Bill_Amount,
			    St_Err_Code,
			    St_Err_Buff);

            	If St_Err_Code <> 0 then
			--ROLLBACK;
                 	--RAISE FND_API.G_EXC_ERROR;
			Raise NO_PROCESSING_OF_AWARD ;
            	End If;
         -----------------------------------------------------------------------------
   X_Money_Left_In_Inst := (X_Total_Funding_Amount - X_Total_Rev_Bill_Amount);
----------------------------------------------------------------------------------------------------------------
      --dbms_output.put_line('Money Left in Installment  = '||to_char(X_Money_Left_In_Inst));
        ------------------------------------------------------------------------------

	-- Bug 2441525 : if the raw cost is greater than the funding left then there is no need for deriving burden.

	--IF NVL(X_Raw_Cost,0) > NVL(X_Money_Left_In_Inst,0) AND X_Revenue_Limit_Flag = 'Y'  THEN   -- hard limit
        --   GOTO  DO_NOT_PROCESS;   /* Do not go any further with processing of this item */
        --END IF;
        -- Above code commented for bug 4289410


   X_Installment_Status := null; -- Initialize

	/* Installment Check */

	INSTALLMENT_CHECK(C_Installment_Id,
			  X_Award_Id,
			  X_Task_Id,
			  X_Calling_Process,
			  X_Expenditure_Item_Date,
			  X_Money_Left_In_Inst,
			  X_Money_On_Curr_Inst,
			  X_Installment_Status,
			  St_Err_Code,
			  St_Err_Buff);

            	If St_Err_Code <> 0 then
			--ROLLBACK;
                 	--RAISE FND_API.G_EXC_ERROR;
			Raise NO_PROCESSING_OF_AWARD ;
            	End If;

                IF L_DEBUG = 'Y' THEN
	           gms_error_pkg.gms_debug('After INSTALLMENT_CHECK X_error_code:'||St_Err_Code,'C');
                END IF;

/* Commented IF for bug 5349106 */
--		If X_Installment_Status ='I' then
--		    GOTO  DO_NOT_PROCESS; /* Do not go any further with processing of this item */
--		End if;

      /* Getting the Burden Components and Burden Amount from View for each Raw Expenditure Item in an array form */

          X_Burden_Components_Count := 0;


          If (nvl(x_burdenable_raw_cost,0) <> 0 and x_ind_compiled_set_id is not null) then
            If allow_burden(x_transaction_source) then
             GET_BURDEN_COMPONENT_DATA(X_Actual_Project_Id,
                                       X_Task_Id,
                                       X_Expenditure_Org_Id,
                                       X_ind_compiled_set_id,
                                       X_burdenable_raw_cost,
                                       X_Expenditure_Type,
				       X_Burden_Components_Count,
				       X_Burden_Component_Data);
            End If; --If allow_burden(x_transaction_source) then
          End If;
         -----------------------------------------------------------------------------
          IF L_DEBUG = 'Y' THEN
	     gms_error_pkg.gms_debug('X_Burden_Components_Count:'||X_Burden_Components_Count,'C');
          END IF;
         -----------------------------------------------------------------------------
         /* For each Trx fetched Get total Raw Amount for the Trx already existing in Intersect table */
           GET_AMOUNT_IN_INTERSECT(X_Expenditure_Item_Id,
				   X_Adl_Line_Num,
                                   X_Calling_Process,
                                   X_Amount_In_Intersect
                                   );
         --dbms_output.put_line('Amount in intersect = '||to_char(X_Amount_In_Intersect));
         -----------------------------------------------------------------------------

       --For i in 1..X_Burden_Components_Count LOOP
        --dbms_output.put_line('Data '||X_Burden_Component_Data(i).Burden_Cost_Code);
	 -- null;
       --End LOOP;

       For i in 1..X_Burden_Components_Count LOOP
          GET_BURD_AMT_IN_INTERSECT(X_Expenditure_Item_Id ,
				    X_Adl_Line_Num,
                                    X_Calling_Process ,
                                    X_Burden_Component_Data(i).Burden_Cost_Code ,
                                    X_Amt_In_Tmp_By_Component );
               X_Tot_Burd_Amt_In_Tmp := X_Tot_Burd_Amt_In_Tmp + X_Amt_In_Tmp_By_Component;
       End LOOP;
              --dbms_output.put_line('Burden Amt in Temp table = '||to_char(X_Tot_Burd_Amt_In_Tmp));
        ------------------------------------------------------------------------------

            For i in 1..X_Burden_Components_Count LOOP

               X_Tot_Burden_Amt_In_View :=  X_Tot_Burden_Amt_In_View
					     + X_Burden_Component_Data(i).Burden_Cost;
            End LOOP;

/* Check if the current transaction amount takes it over the Money Left In Installment. If it does, donot do any */
/* further processing on it . If not, then do the checking for Invoice Formats */

/*IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII*/

/* For bug 5026657 */
/* Commented revenue limit flag and added condition for invoice limit flag for bug 6642901*/
IF ( /*(X_Revenue_Limit_Flag = 'Y')*/ (X_Invoice_Limit_Flag = 'Y') AND
     (g_mode = 'LABOR')  AND
     ( (X_Raw_Cost + X_Tot_Burden_Amt_In_View) - (X_Amount_In_Intersect + X_Tot_Burd_Amt_In_Tmp)
                        > (X_Money_Left_In_Inst - C_Inst_Task_Run_Total) ) ) THEN
    g_labor_exp_to_process := 'Y' ;

END IF;

IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('X_Tot_Burden_Amt_In_View  '||X_Tot_Burden_Amt_In_View,'C');
        gms_error_pkg.gms_debug('X_Raw_Cost  '||X_Raw_Cost,'C');
	gms_error_pkg.gms_debug('X_Amount_In_Intersect  '||X_Amount_In_Intersect,'C');
	gms_error_pkg.gms_debug('X_Tot_Burd_Amt_In_Tmp  '||X_Tot_Burd_Amt_In_Tmp,'C');
	gms_error_pkg.gms_debug('X_Money_Left_In_Inst  '||X_Money_Left_In_Inst,'C');
	gms_error_pkg.gms_debug('C_Inst_Task_Run_Total  '||C_Inst_Task_Run_Total,'C');
	gms_error_pkg.gms_debug('g_labor_exp_to_process  '||g_labor_exp_to_process,'C');
	--	gms_error_pkg.gms_debug('X_Revenue_Limit_Flag  '||X_Revenue_Limit_Flag,'C'); commented and added below line for the bug 6642901
    gms_error_pkg.gms_debug('X_Invoice_Limit_Flag '||X_Invoice_Limit_Flag,'C');
	gms_error_pkg.gms_debug('g_mode  '||g_mode,'C');
END IF;

 IF ( (
       ((X_Raw_Cost + X_Tot_Burden_Amt_In_View) - (X_Amount_In_Intersect + X_Tot_Burd_Amt_In_Tmp)
                        <= (X_Money_Left_In_Inst - C_Inst_Task_Run_Total)) AND
       (X_Total_Funding_Amount <> -99 and X_Total_Rev_Bill_Amount <> -99) AND
--       (X_Revenue_Limit_Flag = 'Y')
         (X_Invoice_Limit_Flag = 'Y')
       )
      OR
     /*(X_Revenue_Limit_Flag = 'N')*/ (X_Invoice_Limit_Flag = 'N')) then --IIIII


     GET_ACCRUE_BILL_OR_INSERT_AMT(X_Expenditure_Item_Id,
				   X_Adl_Line_Num,
                                   X_Calling_Process,
                                   X_Raw_Cost,
                                   X_Billable_Flag,
                                   X_Bill_Hold_Flag,
                                   X_Amount_To_Accrue_Bill_Insert,
                                   X_Err_Num,
                                   X_Err_Stage);

     For i in 1..X_Burden_Components_Count LOOP
            GET_BURDEN_AMT_TO_INSERT(X_Expenditure_Item_Id,
				     X_Adl_Line_Num,
                                     X_Calling_Process,
                                     X_Burden_Component_Data(i).Burden_Cost_Code,
				     X_Billable_Flag,
				     X_Bill_Hold_Flag,
                                     X_Burden_Component_Data(i).Burden_Cost,
                                     X_Burd_Amt_To_Insert_By_Comp);

		-- Rounding fix : Bug 1417062
                X_Burd_Amt_To_Insert_By_Comp := pa_currency.round_currency_amt(nvl(X_Burd_Amt_To_Insert_By_Comp,0));


               INSERT_GMS_BURDEN_COMPONENTS(X_Project_Id,
                                            X_Expenditure_Item_Id,
					    X_Adl_Line_Num,
					    X_Request_Id,
					    X_Calling_Process,
                                            X_Burden_Component_Data(i).Actual_Project_Id,
					    X_Burden_Component_Data(i).Actual_Task_Id,
					    X_Burden_Component_Data(i).Burden_Expenditure_Type,
					    X_Burden_Component_Data(i).Burden_Cost_Code,
					    X_Burden_Component_Data(i).Expenditure_Org_Id,
					    X_Burd_Amt_To_Insert_By_Comp,
					    X_Err_Num,
					    X_Err_Stage);

             X_Tot_Burd_Amt_To_Insert := X_Tot_Burd_Amt_To_Insert + X_Burd_Amt_To_Insert_By_Comp;

     End LOOP;

           C_Inst_Task_Run_Total := nvl(C_Inst_Task_Run_Total,0) + (nvl(X_Amount_To_Accrue_Bill_Insert,0) + nvl(X_Tot_Burd_Amt_To_Insert,0));

/* For bug 5026657 */

/* Commented revenue limit flag and added condition for invoice limit flag for bug 6642901*/
IF ( /*(X_Revenue_Limit_Flag = 'Y')*/ (X_Invoice_Limit_Flag = 'Y') AND
     (g_mode = 'NON LABOR')  AND
     (nvl(X_Amount_To_Accrue_Bill_Insert,0) + nvl(X_Tot_Burd_Amt_To_Insert,0)) < 0 )  THEN

    g_non_labor_neg_exp_processed := 'Y' ;

END IF;

-- GET_INSTALLMENT_NUM, to get installment numbers in case of amounts across installments

    GET_INSTALLMENT_NUM(C_Installment_id,
			X_Award_Id,
			X_Task_Id,
			X_Expenditure_item_date,
			X_Calling_Process,
			X_Money_On_Curr_Inst,
			C_Inst_Task_Run_Total,
			X_Installment_Status,
			X_Installment_tab,
			X_Count,
			St_Err_Code,
			St_Err_Buff);


            	If St_Err_Code <> 0 then
			Raise NO_PROCESSING_OF_AWARD ;
            	End If;

IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('After GET_INSTALLMENT_NUM X_error_code:'||St_Err_Code,'C');
END IF;

/* bug 5242484 - start */
       IF ( X_old_expenditure_item_id = X_expenditure_item_id )  THEN
	   	IF ( X_Count = 1) THEN
                  X_ei_rollback_inst_tab(1).rev_bill_amount := X_ei_rollback_inst_tab(1).rev_bill_amount + C_Inst_Task_Run_Total;
                ELSE
	           FOR k in 1..X_Count LOOP
                       X_ei_rollback_inst_tab(k).rev_bill_amount := X_ei_rollback_inst_tab(k).rev_bill_amount + X_Installment_tab(k).rev_bill_amount;
                   END LOOP;
                END IF;
       ELSE
	       IF ( X_Count = 1) THEN
                  X_ei_rollback_inst_tab(1).rev_bill_amount := C_Inst_Task_Run_Total;
	          X_ei_rollback_inst_tab(1).installment_id := C_Installment_id;

               ELSE
                  FOR k in 1..X_Count LOOP
                      X_ei_rollback_inst_tab(k).rev_bill_amount := X_Installment_tab(k).rev_bill_amount ;
	              X_ei_rollback_inst_tab(k).installment_id := X_Installment_tab(k).installment_id;
                  END LOOP;
               END IF;

       END IF;
/* bug 5242484 - end */

--Updating GMS_SUMMARY_PROJECT_FUNDINGS Billed Amount with the Amount of the current transaction

	 UPD_GSPF_WRAPPER(C_Installment_Id,
		          X_Task_Id,
			  X_Actual_Project_Id,
			  X_Calling_Process,
			  C_Inst_Task_Run_Total,
			  X_Count,
			  X_Installment_tab,
			  X_Installment_total,
			  St_Err_Code,
			  St_Err_Buff);

                If St_Err_Code <> 0 then
			Raise NO_PROCESSING_OF_AWARD ;
                End If;

IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('After UPD_GSPF_WRAPPER X_error_code:'||St_Err_Code,'C');
END IF;

-- Bug 3254097 : Shifted the call to UPD_ADL_BILLING_FLAG at the end of the process

    --Resetting the Inst_Task_Bill_Amount Running Total to Zero for Next transaction
           C_Inst_Task_Run_Total := 0;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

    If X_First_Indicator then --Begin of 1st If for 'First_Row_Indicator' (First Row values go into Old Table)
                              -- for Invoice Format Checking

       -- Copy Values from Cursor into Old_Values Table --
        --dbms_output.put_line('In First Indicator True Check');
        For i in 1..X_Cnt_Of_Columns_Selected LOOP
         DBMS_SQL.COLUMN_VALUE(cur_select,i,X_Old_Values(i));
		 IF L_DEBUG = 'Y' THEN
  	       gms_error_pkg.gms_debug('In First Indicator X_old_values('||i||')='||X_Old_Values(i),'C');
         END IF;
        END LOOP;
	/* Bug 3523930 -Setting the old values for project/task */
	X_old_task_id := X_task_id;
	X_old_actprj_id := X_Actual_Project_Id;
	gms_error_pkg.gms_debug('When First Indicator X_old_task_id ='||X_old_task_id,'C');
	gms_error_pkg.gms_debug('When First Indicator X_old_project_id ='||X_old_actprj_id,'C');
	/* Bug 3523930- Changes end */
          ----------------------------------------------
                --Create Running Total For Columns not in Group By--
                 For i in 1..X_Cnt_Of_Columns_Selected LOOP
                   If X_Sel_Grp_Diff_Array(i) = 'N' then
			null;
                     --X_Run_Total(i) := to_number(X_Old_Values(i));
                   Else
                     X_Run_Total(i) := -1;
                   End If;
                 End LOOP;

    Else -- Else for 1st If for 'First_Row_Indicator' (2nd Row Values go into New Table)
         -- for Invoice Format Checking

      -- Copy Values from Cursor into New_Values Table --
        For i in 1..X_Cnt_Of_Columns_Selected LOOP
         DBMS_SQL.COLUMN_VALUE(cur_select,i,X_New_Values(i));
 		 IF L_DEBUG = 'Y' THEN
  	       gms_error_pkg.gms_debug('When !First Indicator X_new_values('||i||')='||X_New_Values(i),'C');
         END IF;
        END LOOP;
	/* Bug 3523930 -Setting the new values for project/task */
	X_new_task_id := X_task_id;
	X_new_actprj_id := X_Actual_Project_Id;
	gms_error_pkg.gms_debug('When !First Indicator X_new_task_id ='||X_New_task_id,'C');
	gms_error_pkg.gms_debug('When !First Indicator X_new_project_id ='||X_New_actprj_id,'C');
	/* Bug 3523930- Changes end */
                     For i in 1..X_Cnt_Of_Columns_Selected LOOP
			null;
                       --dbms_output.put_line('NEW VALUES ARRE '||X_New_Values(i) );
                     END LOOP;
    End If; -- End of 1st If for 'First_Row_Indicator'

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

/*************************************************************************************************/

    If X_First_Indicator then --Begin of 2nd If for 'First_Row_Indicator'Check
          X_First_Indicator := FALSE;
    Else -- Else of 2nd If for 'First_Row_Indicator 'Check
                 --Compare  Old and New and accordingly create event
       For i in 1..X_Cnt_Of_Columns_Selected LOOP
          If X_Sel_Grp_Diff_Array(i) = 'Y' then --Begin of If for 'Check_Ind' 999999999999999
		    IF L_DEBUG = 'Y' THEN
     	       gms_error_pkg.gms_debug('Inside X_sel_grp_diff_array(i) = Y','C');
             END IF;
	     /* Bug 3523930- Where condition changed */
             If ((X_Old_Values(i) <> X_New_Values(i) and X_invfmt_incl_task='N')
		 or (X_invfmt_incl_task='Y'
		     and (X_Old_Values(i) <> X_New_Values(i)
			  or X_old_task_id <> X_new_task_id
			  or X_old_actprj_id <> X_new_actprj_id))) then  -- 888888888
		IF L_DEBUG = 'Y' THEN
     	           gms_error_pkg.gms_debug('Old Values are not equal to new values','C');
                END IF;
           ------------------------------------------------
    -- This procedure builds the Event Description, Creates the Event and Updates the --
   --GMS_EVENT_INTERSECT table with the corresponding Event Number --

               -- Following IF .. End if statement commented for NULL Events logic ..
               -- zero $ amount logic shifted to DO_EVENT_PROCESSING

                --If X_Event_Amount <> 0 then
                        --dbms_output.put_line('Creating Event');
                      DO_EVENT_PROCESSING(X_Cnt_Of_Columns_Selected,
                                          X_Sel_Grp_Diff_Array,
                                          X_Rt_Jstfy_Flag_Array,
                                          X_Old_Values,
                                  	  X_Padding_Length_Array,
                                  	  X_Run_Total,
                                  	  X_Text_Array,
                                  	  X_Project_Id,
			                  /*X_Task_Id, Changed for bug 3523930 */
					  X_old_task_id,
					  X_invfmt_incl_task, /* Added for bug 3523930 */
                                  	  X_Event_Amount,
                                  	  X_Carrying_Out_Org_Id,
                                  	  X_rev_or_bill_date,
                                  	  X_calling_process,
                                  	  X_Request_id,
                                          C_Installment_Id,
					  X_Count,
					  X_Installment_total,
					  St_Err_Code,
					  St_Err_Buff) ;

	            	If St_Err_Code <> 0 then
				Raise NO_PROCESSING_OF_AWARD ;
       		     	End If;

IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('After DO_EVENT_PROCESSING X_error_code:'||St_Err_Code,'C');
END IF;

                --End If;
           ----------------------------------------------
                --Copy New_Values to Old_Values--
		 gms_error_pkg.gms_debug('Restting old task/project with new task/projet','C');
                 For i in 1..X_Cnt_Of_Columns_Selected LOOP
                     X_Old_Values(i) := X_New_Values(i);
                 End LOOP;
		 /* Bug 3523930 */
		 X_old_task_id := X_New_task_id;
		 X_old_actprj_id := X_new_actprj_id;
           -----------------------------------------------
           ---------------------------------------------
            --Reset Cumulative Total --
                X_Event_Amount := 0;
           ---------------------------------------------
           ---------------------------------------------
          -- Reset Running Total Array to ZERO --
             For i in 1..X_Cnt_Of_Columns_Selected LOOP
                         X_Run_Total(i) := 0;
             End LOOP;
                      EXIT ; --We donot check for any of the other columns
                             --if a different one is found
             Else --888888888
                NULL;
             End If; -- Check for Old_Values <> New_Values -- 888888888
          Else -- Else for 'Check_Ind' 999999999999999
             --Do not Compare Old and New Value
                NULL;
          End If; -- End of If for 'Check_Ind' 999999999999999
       END LOOP;
    End If;-- End of 2nd If for 'First_Row_Indicator'Check
         ----------------------------------------------

/***********************************************************************************************/


   -- Inserting a row into GMS_EVENT_INTERSECT for every row Fetched --
   -- after checking to see if rows already exist for that Expenditure Item Id --
       --dbms_output.put_line('Before GMS_EVENT_INTERSECT');
           INSERT_GMS_EVENT_INTERSECT(X_Project_Id,
                                      X_Raw_Cost,
                                      X_Expenditure_Item_Id,
				      X_Adl_Line_Num,
                                      X_Request_id,
                                      X_Amount_To_Insert,
                                      x_calling_process,
                                      X_Billable_Flag,
                                      X_Bill_Hold_Flag,
                                      X_Err_Nbr,
                                      X_Err_Stg); -- Insert into GMS_EVENT_INTERSECT
               If X_Err_Nbr <> 0 then
                --dbms_output.put_line('After GMS EVENT INTERSECT '||to_char(X_Err_Nbr)||X_Err_Stg);
                   RETURN;
               End If;

   /* bug 5242484 - start */
       IF ( X_old_expenditure_item_id = X_expenditure_item_id )  THEN

           X_event_rollback_amount := X_event_rollback_amount + X_Amount_To_Insert;

       ELSE

           X_old_expenditure_item_id := X_expenditure_item_id;

	   X_event_rollback_amount := X_Amount_To_Insert;

       END IF;
  /* for bug 5242484 - end */
    --------------------------------------------------------
    -- Maintaining Cumulative Total for Creating Event --
       X_Event_Amount := X_Event_Amount + X_Amount_To_Insert ;
    --------------------------------------------------------
    -- Bug 3254097 : Shifted the call to UPD_ADL_BILLING_FLAG so that the flag gets updated only when
    --               the expenditure is processed.

       IF X_UPD_BILLING_FLAG   -- Bug 3233706
 OR ((X_Amount_To_Insert = 0 ) AND (X_Tot_Burd_Amt_To_Insert = 0 )) THEN -- added for bug 5182669
 ---OR ((X_Raw_Cost + X_Tot_Burden_Amt_In_View) = (X_Amount_In_Intersect + X_Tot_Burd_Amt_In_Tmp)) then --bug 5122434--commented for bug 5182669


          -- Update GMS_AWARD_DISTRIBUTIONS set Billed_Flag to 'Y' indicating item has been picked for Invoicing

          IF L_DEBUG = 'Y' THEN
            gms_error_pkg.gms_debug('Format specific Billing : Calling UPD_ADL_BILLING_FLAG for expenditure '||X_Expenditure_Item_Id,'C');
          END IF;

          UPD_ADL_BILLING_FLAG(X_Expenditure_Item_Id,
			  X_Adl_Line_Num,
		          X_Calling_Process,
	                  X_Billable_Flag,
                          X_Bill_Hold_Flag,
			  St_Err_Code,
			  St_Err_Buff);

          IF L_DEBUG = 'Y' THEN
              gms_error_pkg.gms_debug('After UPD_ADL_BILLING_FLAG X_error_code:'||St_Err_Code,'C');
          END IF;

          If St_Err_Code <> 0 then
	      Raise NO_PROCESSING_OF_AWARD ;
          End If;

       END IF;  -- Bug 3254097

    -------------------------------------------------------------------------------------
    -- Maintaining Cumulative Total for the Columns in Select_Text which donot have Group_By_Text--
      For i in 1..X_Cnt_Of_Columns_Selected LOOP
       If X_Sel_Grp_Diff_Array(i) = 'N' then
       --   X_Run_Total(i) := X_Run_Total(i) + nvl(to_number(X_New_Values(i)),0);
		null;
       Else -- (If Ind is 'T' or 'Y')
          X_Run_Total(i) := -1;
       End If;
      End LOOP;
    -------------------------------------------------------------------------------------
   END IF ;-- End of IF for Installment Check IIIII

/*IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII*/

  Else  -- Else for 'Cursor_Rows_Check_If'
    --dbms_output.put_line('For last Row or If no rows present');
   -- This is for the Last Row being processed --
   --This procedure builds the Event Description, Creates the Event and Updates the --
   -- GMS_EVENT_INTERSECT table with the corresponding Event Number --

   -- Following IF .. End if statement commented for NULL Events logic ..
   -- zero $ amount logic shifted to DO_EVENT_PROCESSING

      --If X_Event_Amount <> 0 then

          DO_EVENT_PROCESSING(X_Cnt_Of_Columns_Selected,
                                  X_Sel_Grp_Diff_Array,
                                  X_Rt_Jstfy_Flag_Array,
                                  X_Old_Values,
                                  X_Padding_Length_Array,
                                  X_Run_Total,
                                  X_Text_Array,
                                  X_Project_Id,
				  /* X_Task_Id, Changed for bug 3523930*/
				  X_old_task_id,
				  X_invfmt_incl_task, /* Added for bug 3523930 */
                                  X_Event_Amount,
                                  X_Carrying_Out_Org_Id,
                                  X_rev_or_bill_date,
                                  X_calling_process,
                                  X_Request_id,
                                  C_Installment_Id,
			          X_Count,
                                  X_Installment_total,
                                  St_Err_Code,
                                  St_Err_Buff) ;

                        If St_Err_Code <> 0 then
				Raise NO_PROCESSING_OF_AWARD ;
                        End If;
      --End If;

        EXIT;


  End If; -- End of 'Cursor_Rows_Check_If'

  /* bug 5242484 - start */
  /* Commented revenue limit flag and added condition for invoice limit flag for bug 6642901*/
IF (
       ((X_Raw_Cost + X_Tot_Burden_Amt_In_View) - (X_Amount_In_Intersect + X_Tot_Burd_Amt_In_Tmp)
                        > (X_Money_Left_In_Inst - C_Inst_Task_Run_Total)) AND
       (X_Total_Funding_Amount <> -99 and X_Total_Rev_Bill_Amount <> -99) AND
       --(X_Revenue_Limit_Flag = 'Y')
       (X_Invoice_Limit_Flag = 'Y')
    AND ( X_expenditure_item_id = X_old_expenditure_item_id )
   )  THEN

IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('Calling Procedure EI rollback with parameters :- ','C');
        gms_error_pkg.gms_debug('EI rollback : Expenditure_item_id is '||x_expenditure_item_id,'C');
	gms_error_pkg.gms_debug('EI rollback : Adl_line_num is '||x_adl_line_num,'C');
	gms_error_pkg.gms_debug('EI rollback : Project id is '||X_old_actprj_id,'C');
	gms_error_pkg.gms_debug('EI rollback : Task id is '||X_old_task_id,'C');
	gms_error_pkg.gms_debug('EI rollback : Rollback amt is '||x_event_rollback_amount,'C');
	gms_error_pkg.gms_debug('EI rollback : Installment Count is '||x_Count,'C');
END IF;

     ei_rollback(x_award_id,
            'INVOICE',
	    x_expenditure_item_id,
	    x_adl_line_num,
	    X_old_actprj_id,
            X_old_task_id,
	    X_Count);

X_Event_Amount := X_Event_Amount - X_event_rollback_amount;

gms_error_pkg.gms_debug('Rolled back EI '||X_expenditure_item_id||' ! ','C');

END IF;
/* bug 5242484 - end */

<<DO_NOT_PROCESS>>

 NULL;

/*$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$*/

  EXCEPTION
    WHEN RESOURCE_BUSY THEN
         ROLLBACK TO EXPENDITURE_ITEM_PROCESSING;
       ss_text := SQLCODE||' '||SQLERRM;

END;

 END LOOP;


     DBMS_SQL.CLOSE_CURSOR(cur_select);

  EXCEPTION
    WHEN OTHERS THEN
       ss_text := SQLCODE||' '||SQLERRM;
        IF L_DEBUG = 'Y' THEN
        	gms_error_pkg.gms_debug(ss_text ,'C');
        END IF;
      RAISE NO_PROCESSING_OF_AWARD;

End FORMAT_SPECIFIC_BILLING;

-----------------------------------------------------------------------------------------------------
-- Procedure REVENUE_ACCRUAL: This is a new process to be used in addition to FORMAT_SPECIFIC_BILLING
-- to handle Revenue Accrual process separately because of the requirement to create Revenue Events
-- by Actual project
-----------------------------------------------------------------------------------------------------
Procedure REVENUE_ACCRUAL(X_Project_Id                IN NUMBER,
                          X_Award_Id                  IN NUMBER,
                          X_Class_Category            IN VARCHAR2,
                          X_rev_or_bill_date          IN DATE,
                          X_Revenue_Limit_Flag        IN VARCHAR2,
                          X_request_id                IN NUMBER,
                	  X_Rev_Carrying_Out_Org_Id   IN NUMBER,
                	  X_calling_process           IN VARCHAR2,
			  X_Trx_Type		      IN VARCHAR2,
               		  C_Installment_Id            IN NUMBER,
              	          C_Start_Date_Active         IN DATE,
              	          C_End_Date_Active           IN DATE,
                          X_Err_Num                   OUT NOCOPY NUMBER,
                          X_Err_Stage                 OUT NOCOPY VARCHAR2,
			  g_labor_exp_to_process      OUT NOCOPY VARCHAR2,                   /* added for bug 5026657 */
			  g_non_labor_neg_exp_processed OUT NOCOPY VARCHAR2)  IS             /* added for bug 5026657 */
 --Bug : 2909746 - change the order by clause from adl.adl_line_num to adl.cdl_line_num
-- 11.5, rev_cur_select cursor changed, so that certain columns are picked up from the adl table
 CURSOR rev_cur_select IS
 Select /*+INDEX(ei PA_EXPENDITURE_ITEMS_U1)
           INDEX(adl gms_award_distributions_n7) */  /* Added INDEX(adl gms_award_distributions_n7) for 6969435 */
   p.project_id
 , adl.task_id
 , ei.expenditure_type
 , nvl(ei.override_to_organization_id,e.incurred_by_organization_id) EXPENDITURE_ORG
 , ei.quantity * (adl.distribution_value/100)*DECODE(adl.line_num_reversed,NULL,1,-1) --Added decode to get correct quantity
 , unit.meaning
 , decode(ei.system_linkage_function,'BTC',adl.raw_cost,adl.raw_cost)
 , ei.expenditure_item_id
 , ei.expenditure_item_date
 , ei.bill_hold_flag
 , adl.billable_flag
 , ei.adjusted_expenditure_item_id
 , adl.adl_line_num
 , adl.cdl_line_num --Bug 2909746
 , adl.parent_adl_line_num
 , adl.adl_status
 , adl.award_id
 , adl.ind_compiled_set_id
 , adl.burdenable_raw_cost
 , ei.transaction_source
 from
  gms_award_distributions adl /* Moved this up in the order for 6969435*/
 ,pa_expenditure_items_all ei
 ,pa_expenditures e
 ,pa_expenditure_types et
 ,pa_lookups unit
 ,pa_projects_all p
 ,pa_project_types pt
 ,pa_tasks t3
 ,pa_tasks t5
 where
     adl.award_id = X_Award_Id
 and ei.expenditure_item_id = adl.expenditure_item_id
 and adl.fc_status = 'A'
 and ((adl.line_num_reversed is null and adl.reversed_flag is null and ei.cost_distributed_flag='Y') or
       ((adl.line_num_reversed is not null or adl.reversed_flag is not null) and adl.cost_distributed_flag = 'Y')) --Bug 1852802
 and nvl(adl.billable_flag,'N')='Y'
 and ei.system_linkage_function <> 'BTC'
 and (adl.revenue_distributed_flag in ('N','Z') or adl.revenue_distributed_flag is null) -- For bug 4386936 -- reverting this for bug 4594090 /* Modified this for 6969435 */
 and ei.expenditure_item_date <= nvl(trunc(X_rev_or_bill_date),SYSDATE)
 and trunc(ei.expenditure_item_date) <=  trunc(C_End_Date_Active)
 and adl.document_type = 'EXP'   -- To pick up only actuals and not encumbrances
 and adl.adl_status = 'A'
 and ei.expenditure_type = et.expenditure_type
 and e.expenditure_id = ei.expenditure_id
 and et.unit_of_measure = unit.lookup_code
 and (  (ei.system_linkage_function in( 'ST', 'OT') and X_Trx_Type = 'LABOR')
      OR (ei.system_linkage_function not in( 'ST' , 'OT') and X_Trx_Type = 'NON_LABOR'))
 and unit.lookup_type = 'UNIT'
 and ei.task_id = t3.task_id
 and t3.top_task_id = t5.task_id
 and t5.ready_to_distribute_flag = 'Y'
 and t3.project_id = p.project_id
 and p.project_status_code <> 'CLOSED' -- Bug 3254097 : Modified 'CLOSED ' to 'CLOSED'
 and pt.project_type = p.project_type
 and pt.direct_flag = 'N'
 and exists ( select 1
	      from   gms_summary_project_fundings gspf
	      where  gspf.installment_id = C_installment_id
              and    gspf.project_id     = adl.project_id
	      and    (gspf.task_id is NULL             or
		      gspf.task_id       = adl.task_id or
		      gspf.task_id       = (select t.top_task_id
					    from   pa_tasks t
					    where  t.task_id = adl.task_id
				           )
		      )
	     )
 order by DECODE( NVL(ei.net_zero_adjustment_flag,'N'),'N', NVL(ei.raw_cost,
               gms_billing.get_total_adl_raw_cost(X_calling_process,ei.expenditure_item_id)),
                                              'Y', DECODE(SIGN(NVL(ei.raw_cost,
               gms_billing.get_total_adl_raw_cost(X_calling_process,ei.expenditure_item_id))),
                                                  1,-NVL(ei.raw_Cost,
               gms_billing.get_total_adl_raw_cost(X_calling_process,ei.expenditure_item_id)),
                                                   NVL(ei.raw_cost,
               gms_billing.get_total_adl_raw_cost(X_calling_process,ei.expenditure_item_id)))),
               NVL(ei.raw_cost,gms_billing.get_total_adl_raw_cost(X_calling_process,ei.expenditure_item_id)),
              NVL(ei.adjusted_expenditure_item_id,ei.expenditure_item_id),
           adl.raw_cost, adl.cdl_line_num , -- Bug 3235390
          p.project_id,ei.task_id,ei.expenditure_type,EXPENDITURE_ORG;

 X_Rev_Act_Project_Id               	NUMBER(15);
 X_Rev_Task_Id                  	NUMBER(15);
 X_Rev_Expenditure_Type         	VARCHAR2(30);
 X_Rev_Expenditure_Org_Id		NUMBER(15);
 X_Rev_Quantity				NUMBER(15);
 X_Rev_Units				VARCHAR2(30);
 X_Rev_Expenditure_Cost			NUMBER(22,5);
 X_Rev_Expenditure_Item_Id		NUMBER(15);
 X_Rev_Expenditure_Item_Date		DATE;
 X_Rev_Bill_Hold_Flag			VARCHAR2(1);
 X_Rev_Billable_Flag			VARCHAR2(1);
 X_Rev_Adjusted_Exp_Item_Id	        NUMBER(15);

/* -- 11.5 Additions -- */
 X_Rev_Adl_Line_Num			NUMBER(15);
 X_Rev_Cdl_Line_Num                     NUMBER(15); --bug 2909746
 X_Rev_parent_Adl_Line_Num		NUMBER(15);
 X_Rev_Adl_Status			VARCHAR2(1);
 X_Rev_Award_Id				NUMBER(15);
 St_Err_Code  			        VARCHAR2(30);
 St_Err_Buff    			VARCHAR2(2000);
 X_Rev_Installment_Status 		VARCHAR2(1) :=null;
 X_Rev_Count  				NUMBER :=0;
 X_Rev_Money_On_Curr_Inst 		NUMBER(22,5);
/* -- 11.5 Additions -- */

 X_Rev_Lock_Exp_Id        NUMBER(15);
 X_Rev_Adl_Lock_Exp_Id    NUMBER(15);

 X_Rev_Orig_Item_Distr_Flag    VARCHAR2(1);
 X_Rev_Total_Funding_Amount     NUMBER(22,6):= 0;
 X_Total_Rev_Amount	        NUMBER(22,6):= 0;
 X_Rev_Amount_In_Intersect      NUMBER(22,6):= 0;
 X_Rev_Money_Left_In_Inst       NUMBER(22,6):= 0;
 C_Rev_Inst_Task_Run_Total 	NUMBER(22,5):= 0;
 X_Rev_Amount_To_Insert         NUMBER(22,5):= 0;
 X_Rev_Event_Amount 		NUMBER(22,5):= 0;
 X_Rev_Run_Total                NUMBER(15)  := 0;

 X_Rev_First_Row_Ind            BOOLEAN := TRUE;

 X_Act_Project_Id_Old         	NUMBER(15);
 X_Task_Id_Old		  	NUMBER(15);
 X_Expenditure_Type_Old	  	VARCHAR2(30);
 X_Expenditure_Org_Id_Old 	NUMBER(15);
 X_Quantity_Old			NUMBER(15) := 0;
 X_Units_Old			VARCHAR2(30);

 /* bug 5242484 - start */
 X_old_expenditure_item_id NUMBER(15) := -9999 ;
 X_event_rollback_amount NUMBER(22,5) := 0;
 X_event_rollback_qty NUMBER(15) := 0;
 k NUMBER := 0;
/* bug 5242484 - end */

 X_Act_Project_Id_New		NUMBER(15);
 X_Task_Id_New			NUMBER(15);
 X_Expenditure_Type_New		VARCHAR2(30);
 X_Expenditure_Org_Id_New       NUMBER(15);
 X_Quantity_New			NUMBER(15) := 0;
 X_Units_New			VARCHAR2(30);

 X_Rev_Burden_Component_Data     Burden_Component_Tab_Type;
 X_Rev_Burden_Components_Count   NUMBER := 0;
 X_Rev_Amt_In_Tmp_By_Component       NUMBER := 0;
 X_Rev_Tot_Burd_Amt_In_Tmp      NUMBER := 0;
 X_Rev_Tot_Burden_Amt_In_View          NUMBER := 0;
 X_Rev_Burd_Amt_To_Ins_By_Comp    NUMBER := 0;
 X_Rev_Tot_Burd_Amt_To_Insert     NUMBER := 0;

 X_Err_Nbr NUMBER(15) := NULL;
 X_Err_Stg VARCHAR2(200) := NULL;
 ss_text VARCHAR2(300);
 RESOURCE_BUSY EXCEPTION;
 PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -00054);

 X_ind_compiled_Set_id gms_award_distributions.ind_compiled_set_id%type;
 X_burdenable_raw_cost gms_award_distributions.burdenable_raw_cost%type;
 X_transaction_source  pa_expenditure_items_all.transaction_source%type;

Begin


   /* To set project_id NULL to be able to use Suresh's view to derive Burden Components and Burden Cost */
     --GMS_BURDEN_COSTING.SET_CURRENT_PROJECT_ID(NULL);
     --The above line has been commented out NOCOPY for bug 2442827

/* bug 5026657  */
g_labor_exp_to_process := 'N';
g_non_labor_neg_exp_processed := 'N';


   OPEN rev_cur_select;
 Begin
 LOOP
  Begin
     SAVEPOINT REV_EXP_ITEM_PROCESSING;

     FETCH rev_cur_select into
      X_Rev_Act_Project_Id
     ,X_Rev_Task_Id
     ,X_Rev_Expenditure_Type
     ,X_Rev_Expenditure_Org_Id
     ,X_Rev_Quantity
     ,X_Rev_Units
     ,X_Rev_Expenditure_Cost
     ,X_Rev_Expenditure_Item_Id
     ,X_Rev_Expenditure_Item_Date
     ,X_Rev_Bill_Hold_Flag
     ,X_Rev_Billable_Flag
     ,X_Rev_Adjusted_Exp_Item_Id
     ,X_Rev_Adl_Line_Num
     ,X_Rev_Cdl_Line_Num --Bug 2909746
     ,X_Rev_Parent_Adl_Line_Num
     ,X_Rev_Adl_Status
     ,X_Rev_Award_Id
     ,X_ind_compiled_Set_id
     ,X_burdenable_raw_cost
     ,X_transaction_source;

           EXIT WHEN rev_cur_select%NOTFOUND;

      X_Rev_Burden_Component_Data.DELETE;

IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('Expenditure Item Id :'||X_Rev_Expenditure_Item_Id,'C');
	gms_error_pkg.gms_debug('X_Adl_Line_Num:'||X_Rev_Adl_Line_Num,'C');
	gms_error_pkg.gms_debug('X_Cdl_Line_Num:'||X_Rev_Cdl_Line_Num,'C'); -- Bug 2909746
	gms_error_pkg.gms_debug('X_Expenditure_Item_Date:'||X_Rev_Expenditure_Item_Date,'C');
	gms_error_pkg.gms_debug('X_Raw_Cost:'||X_Rev_Expenditure_Cost,'C');
	gms_error_pkg.gms_debug('X_Bill_Hold_Flag:'||X_Rev_Bill_Hold_Flag,'C');
END IF;

        -- Lock the Expenditure Item
       select expenditure_item_id
       into
       X_Rev_Lock_Exp_Id
       from
       pa_expenditure_items_all
       where
       expenditure_item_id = X_Rev_Expenditure_Item_Id
       FOR UPDATE NOWAIT;

-- 11.5 Change, Lock Adl Expenditure Item too

	select expenditure_item_id
        into
	X_Rev_Adl_Lock_Exp_Id
	from
	gms_award_distributions
	where expenditure_item_id = X_Rev_Expenditure_Item_Id
	and   adl_line_num=X_Rev_Adl_Line_Num
	and    document_type='EXP'
	and    adl_status = 'A'
	FOR UPDATE NOWAIT;

       /* This is to see that the Adjusting Expenditure Item is picked up first for Billing */
            -- Bug 3235390 : commented out
/*	If X_Rev_Adjusted_Exp_Item_Id IS NOT NULL then
 	  Begin
         	Select
    	 	nvl(revenue_distributed_flag,'N')
  	 	into
    	 	X_Rev_Orig_Item_Distr_Flag
  	 	from
    	 	gms_award_distributions
  	 	where expenditure_item_id = X_Rev_Adjusted_Exp_Item_Id
         	and   award_id = X_Rev_award_id
  		and   adl_status='A'
  		and   document_type ='EXP'
  		and   adl_line_num =
                   	(select max(adl_line_num)
		    	 from   gms_award_distributions
		    	 where  expenditure_item_id = X_Rev_Adjusted_Exp_Item_Id
			 and   award_id = X_Rev_award_id
			 and   adl_status='A'
			 and   document_type ='EXP');

        End;
        End If; */ --bug 3235390

 -----------------------------------------------------------------------------------------------------
   /*Resetting Burden Totals from View and Tmp table to zero for every Exp Item being processed */
    X_Rev_Tot_Burd_Amt_In_Tmp    := 0;
    X_Rev_Tot_Burden_Amt_In_View := 0;
    X_Rev_Tot_Burd_Amt_To_Insert := 0;
    X_UPD_BILLING_FLAG := FALSE; -- Bug 3254097 : Intializing the flag

----------------------------------------------------------------------------------------------------
     /*   If (X_Rev_Adjusted_Exp_Item_Id IS NOT NULL and X_Rev_Orig_Item_Distr_Flag <> 'Y' ) then

            GOTO  DO_NOT_PROCESS_REV;  Do not go any further with processing of this item

        End If; */ --Bug 3235390

  ------------------------------------------------------------------------------------
   -- Rounding fix : Bug 1417062

   X_Rev_Expenditure_Cost := pa_currency.round_currency_amt(nvl(X_Rev_Expenditure_Cost,0));

         -----------------------------------------------------------------------------
         /* For the particular Installment,Task get Total Billed Amount and Total Funding Amount */
           GET_SUMM_FUNDING(NULL,-- C_Installment_Id, Made Null for 11.5
			    X_Rev_Expenditure_Item_Date,
			    X_Rev_Award_Id,
                            X_Rev_Task_Id,
                            X_calling_process,
                            X_Rev_Total_Funding_Amount,
                            X_Total_Rev_Amount,
			    St_Err_Code,
			    St_Err_Buff);

            	If St_Err_Code <> 0 then
			Raise NO_PROCESSING_OF_AWARD ;
            	End If;
         -----------------------------------------------------------------------------
          X_Rev_Money_Left_In_Inst := (X_Rev_Total_Funding_Amount - X_Total_Rev_Amount);
         -----------------------------------------------------------------------------

     -- Bug 2441525 : If the raw cost is greater than the funding left then there is  no need for deriving burden.

       --  IF NVL(X_Rev_Expenditure_Cost,0) > NVL(X_Rev_Money_Left_In_Inst,0) AND X_Revenue_Limit_Flag = 'Y'  THEN   -- hard limit
       --    GOTO  DO_NOT_PROCESS_REV;   /* Do not go any further with processing of this item */
       --  END IF;
       -- Above code commented out .. Bug 4289410

-- 11.5 changes start

   X_Rev_Installment_Status := null; -- Initialize

	/* Installment Check */

	INSTALLMENT_CHECK(C_Installment_Id,
			  X_Rev_Award_Id,
			  X_Rev_Task_Id,
			  X_Calling_Process,
			  X_Rev_Expenditure_Item_Date,
			  X_Rev_Money_Left_In_Inst,
			  X_Rev_Money_On_Curr_Inst,
			  X_Rev_Installment_Status,
			  St_Err_Code,
			  St_Err_Buff);

            	If St_Err_Code <> 0 then
			Raise NO_PROCESSING_OF_AWARD ;
            	End If;

/* Commented for bug 5349106 */
--		If X_Rev_Installment_Status ='I' then
--		    GOTO  DO_NOT_PROCESS_REV; /* Do not go any further with processing of this item */
--		End if;
-- 11.5 changes end
         ----------------------------------------------------------------------------
         /* Getting the Burden Components and Burden Amount from View for each Raw Expenditure Item in an array form */

          X_Rev_Burden_Components_Count := 0;

          If (nvl(x_burdenable_raw_cost,0) <> 0 and x_ind_compiled_set_id is not null) then

            If allow_burden(x_transaction_source) then

             GET_BURDEN_COMPONENT_DATA(X_Rev_Act_Project_Id,
				       X_Rev_Task_Id,
				       X_Rev_Expenditure_Org_Id,
				       X_ind_compiled_set_id,
				       X_burdenable_raw_cost,
				       X_Rev_Expenditure_Type,
				       X_Rev_Burden_Components_Count,
				       X_Rev_Burden_Component_Data);
            End If; --If allow_burden(x_transaction_source) then

          End If;
         ----------------------------------------------------------------------------
          IF L_DEBUG = 'Y' THEN
	     gms_error_pkg.gms_debug('X_Rev_Burden_Components_Count:'||X_Rev_Burden_Components_Count,'C');
          END IF;
         -----------------------------------------------------------------------------
         /* For each Trx fetched Get total amount for the Trx already existing in Intersect table */
           GET_AMOUNT_IN_INTERSECT(X_Rev_Expenditure_Item_Id,
                                   X_Rev_Adl_Line_Num,
                                   X_Calling_Process,
                                   X_Rev_Amount_In_Intersect
                                   );
         -----------------------------------------------------------------------------

         -----------------------------------------------------------------------------
         For i in 1..X_Rev_Burden_Components_Count LOOP
           GET_BURD_AMT_IN_INTERSECT(X_Rev_Expenditure_Item_Id,
                                     X_Rev_Adl_Line_Num,
				     X_Calling_Process,
				     X_Rev_Burden_Component_Data(i).Burden_Cost_Code,
				     X_Rev_Amt_In_Tmp_By_Component);

           X_Rev_Tot_Burd_Amt_In_Tmp := X_Rev_Tot_Burd_Amt_In_Tmp + X_Rev_Amt_In_Tmp_By_Component;

         End LOOP;
        ------------------------------------------------------------------------------
        -----------------------------------------------------------------------------
         For i in 1..X_Rev_Burden_Components_Count LOOP
           X_Rev_Tot_Burden_Amt_In_View := X_Rev_Tot_Burden_Amt_In_View + X_Rev_Burden_Component_Data(i).Burden_Cost;
         End LOOP;
        ------------------------------------------------------------------------------
 /* For bug 5026657 */
IF ( (X_Revenue_Limit_Flag = 'Y') AND
     (X_Trx_Type = 'LABOR')  AND
     ( (X_Rev_Expenditure_Cost + X_Rev_Tot_Burden_Amt_In_View) - (X_Rev_Amount_In_Intersect + X_Rev_Tot_Burd_Amt_In_Tmp)
                        > (X_Rev_Money_Left_In_Inst - C_Rev_Inst_Task_Run_Total) ) ) THEN
    g_labor_exp_to_process := 'Y' ;

END IF;

 IF ( (
        (   (X_Rev_Expenditure_Cost + X_Rev_Tot_Burden_Amt_In_View)  - (X_Rev_Amount_In_Intersect + X_Rev_Tot_Burd_Amt_In_Tmp)
           <= ( X_Rev_Money_Left_In_Inst - C_Rev_Inst_Task_Run_Total) )
    AND (X_Rev_Total_Funding_Amount <> -99 and X_Total_Rev_Amount <> -99)
    AND (X_Revenue_Limit_Flag = 'Y')
       )
      OR
       (X_Revenue_Limit_Flag = 'N')
    ) then --??????????????

              GET_ACCRUE_BILL_OR_INSERT_AMT(X_Rev_Expenditure_Item_Id,
					    X_Rev_Adl_line_Num,
                                  	    X_Calling_Process,
                                            X_Rev_Expenditure_Cost,
                                            X_Rev_Billable_Flag,
                                            X_Rev_Bill_Hold_Flag,
                                            X_Rev_Amount_To_Insert,
                                            X_Err_Num,
                                            X_Err_Stage);

           FOR i in 1..X_Rev_Burden_Components_Count LOOP
                  GET_BURDEN_AMT_TO_INSERT(X_Rev_Expenditure_Item_Id,
					   X_Rev_Adl_Line_Num,
					   X_Calling_Process,
					   X_Rev_Burden_Component_Data(i).Burden_Cost_Code,
					   X_Rev_Billable_Flag,
					   X_Rev_Bill_Hold_Flag,
					   X_Rev_Burden_Component_Data(i).Burden_Cost,
					   X_Rev_Burd_Amt_To_Ins_By_Comp);

               -- Rounding fix : Bug 1417062
		X_Rev_Burd_Amt_To_Ins_By_Comp := pa_currency.round_currency_amt(nvl(X_Rev_Burd_Amt_To_Ins_By_Comp,0));

               INSERT_GMS_BURDEN_COMPONENTS(X_Project_Id,
                                            X_Rev_Expenditure_Item_Id,
					    X_Rev_Adl_Line_Num,
                                            X_Request_Id,
                                            X_Calling_Process,
                                            X_Rev_Burden_Component_Data(i).Actual_Project_Id,
                                            X_Rev_Burden_Component_Data(i).Actual_Task_Id,
                                            X_Rev_Burden_Component_Data(i).Burden_Expenditure_Type,
                                            X_Rev_Burden_Component_Data(i).Burden_Cost_Code,
                                            X_Rev_Burden_Component_Data(i).Expenditure_Org_Id,
                                            X_Rev_Burd_Amt_To_Ins_By_Comp,
                                            X_Err_Num,
                                            X_Err_Stage);

                   X_Rev_Tot_Burd_Amt_To_Insert := X_Rev_Tot_Burd_Amt_To_Insert + X_Rev_Burd_Amt_To_Ins_By_Comp;

           END LOOP;

           C_Rev_Inst_Task_Run_Total := nvl(C_Rev_Inst_Task_Run_Total,0) + (nvl(X_Rev_Amount_To_Insert,0) + nvl(X_Rev_Tot_Burd_Amt_To_Insert,0));

/* For bug 5026657 */

IF ( (X_Revenue_Limit_Flag = 'Y') AND
     (X_Trx_Type = 'NON_LABOR')  AND
     (nvl(X_Rev_Amount_To_Insert,0) + nvl(X_Rev_Tot_Burd_Amt_To_Insert,0)) < 0 )  THEN

    g_non_labor_neg_exp_processed := 'Y' ;

END IF;

------------------------------------------------------------------------------
-- 11.5 changes start

-- GET_INSTALLMENT_NUM, to get installment numbers in case of amounts across installments

    GET_INSTALLMENT_NUM(C_Installment_id,
			X_Rev_Award_Id,
			X_Rev_Task_Id,
			X_Rev_Expenditure_item_date,
			X_Calling_Process,
			X_Rev_Money_On_Curr_Inst,
			C_Rev_Inst_Task_Run_Total,
			X_Rev_Installment_Status,
			X_Rev_Installment_tab,
			X_Rev_Count,
			St_Err_Code,
			St_Err_Buff);

            	If St_Err_Code <> 0 then
			Raise NO_PROCESSING_OF_AWARD ;
            	End If;

-- 11.5 changes end

/* bug 5242484 - end */
       IF ( X_old_expenditure_item_id = X_Rev_expenditure_item_id )  THEN
	   	IF ( X_Rev_Count = 1) THEN
                  X_ei_rollback_inst_tab(1).rev_bill_amount := X_ei_rollback_inst_tab(1).rev_bill_amount + C_Rev_Inst_Task_Run_Total;
                ELSE
	           FOR k in 1..X_Rev_Count LOOP
                       X_ei_rollback_inst_tab(k).rev_bill_amount := X_ei_rollback_inst_tab(k).rev_bill_amount + X_Rev_Installment_tab(k).rev_bill_amount;
                   END LOOP;
                END IF;
       ELSE
	       IF ( X_Rev_Count = 1) THEN
                  X_ei_rollback_inst_tab(1).rev_bill_amount := C_Rev_Inst_Task_Run_Total;
	          X_ei_rollback_inst_tab(1).installment_id := C_Installment_id;

               ELSE
                  FOR k in 1..X_Rev_Count LOOP
                      X_ei_rollback_inst_tab(k).rev_bill_amount := X_Rev_Installment_tab(k).rev_bill_amount ;
	              X_ei_rollback_inst_tab(k).installment_id := X_Rev_Installment_tab(k).installment_id;
                  END LOOP;
               END IF;

       END IF;
 /* bug 5242484 - end */

------------------------------------------------------------------------------
--Updating GMS_SUMMARY_PROJECT_FUNDINGS Billed Amount with the Amount of the current transaction

          	     UPD_GSPF_WRAPPER(C_Installment_Id,
                                      X_Rev_Task_Id,
                                      X_Rev_Act_Project_Id,
                                      X_Calling_Process,
                                      C_Rev_Inst_Task_Run_Total,
			       	      X_Rev_Count,
				      X_Rev_Installment_tab,
				      X_Rev_Installment_total,
			  	      St_Err_Code,
			  	      St_Err_Buff);

		If St_Err_Code <> 0 then
			Raise NO_PROCESSING_OF_AWARD ;
                End If;

-- Bug 3254097 : Shifted the call to UPD_ADL_BILLING_FLAG at the end of the process.

    --Resetting the Inst_Task_Bill_Amount Running Total to Zero for Next transaction
           C_Rev_Inst_Task_Run_Total := 0;

----------------------------------------------------------------------------------
         If X_Rev_First_Row_Ind  then
           X_Act_Project_Id_Old 	:= X_Rev_Act_Project_Id;
           X_Task_Id_Old    		:= X_Rev_Task_Id;
           X_Expenditure_Type_Old       := X_Rev_Expenditure_Type;
           X_Expenditure_Org_Id_Old     := X_Rev_Expenditure_Org_Id;
           X_Units_Old			:= X_Rev_Units;
           X_Quantity_Old               := X_Rev_Quantity;
           X_Rev_Run_Total 		:= X_Quantity_Old;

         Else
           X_Act_Project_Id_New         := X_Rev_Act_Project_Id;
           X_Task_Id_New                := X_Rev_Task_Id;
           X_Expenditure_Type_New       := X_Rev_Expenditure_Type;
           X_Expenditure_Org_Id_New     := X_Rev_Expenditure_Org_Id;
           X_Units_New                  := X_Rev_Units;
           X_Quantity_New               := X_Rev_Quantity;

         End If;

----------------------------------------------------------------------------

         If X_Rev_First_Row_Ind then
              X_Rev_First_Row_Ind := FALSE;
         Else

             If ( (X_Act_Project_Id_Old       <> X_Act_Project_Id_New) OR
                  (X_Task_Id_Old              <> X_Task_Id_New)    OR
                  (X_Expenditure_Type_Old     <> X_Expenditure_Type_New) OR
                  (X_Expenditure_Org_Id_Old   <> X_Expenditure_Org_Id_New) ) then

	         -- Following IF .. End if statement commented for NULL Events logic ..
                 -- zero $ amount logic shifted to DO_REV_EVENT_PROCESSING

                 --If (X_Rev_Event_Amount <> 0) then
                  DO_REV_EVENT_PROCESSING(X_Act_Project_Id_Old,
					  X_Task_Id_Old,
					  X_Expenditure_Type_Old,
					  X_Expenditure_Org_Id_Old,
                                          X_Units_Old,
                                          X_Rev_Run_Total,
                                          X_Project_Id,
                                          X_Rev_Event_Amount,
                                          X_Rev_Carrying_Out_Org_Id,
                                          X_rev_or_bill_date,
                                          X_calling_process,
                                          X_Request_id,
                                          C_Installment_Id,
					  X_Rev_Count,
					  X_Rev_Installment_total,
					  St_Err_Code,
					  St_Err_Buff);
                 --End If;

                /* Copying New values to Old values */
                   X_Act_Project_Id_Old     := X_Act_Project_Id_New;
                   X_Task_Id_Old            := X_Task_Id_New;
                   X_Expenditure_Type_Old   := X_Expenditure_Type_New;
                   X_Expenditure_Org_Id_Old := X_Expenditure_Org_Id_New;

                   X_Units_Old              := X_Units_New;

               /* Resetting X_Rev_Event_Amount */
                    X_Rev_Event_Amount := 0;

		/* Resetting Running Total for Hours etc for Event Description */
                    X_Rev_Run_Total := 0;

             End If;

           End If;
---------------------------------------------------
     INSERT_GMS_EVENT_INTERSECT(X_Project_Id,
                                X_Rev_Expenditure_Cost,
                                X_Rev_Expenditure_Item_Id,
				X_Rev_Adl_Line_Num,
                                X_Request_id,
                                X_Rev_Amount_To_Insert,
                                X_Calling_process,
                                X_Rev_Billable_Flag,
                                X_Rev_Bill_Hold_Flag,
                                X_Err_Nbr,
                                X_Err_Stg); -- Insert into GMS_EVENT_INTERSECT
               If X_Err_Nbr <> 0 then
                   RETURN;
               End If;

    /* for bug 5242484 - start  */
       IF ( X_old_expenditure_item_id = X_Rev_expenditure_item_id )  THEN

           X_event_rollback_amount := X_event_rollback_amount + X_Rev_Amount_To_Insert;
           X_event_rollback_qty :=    X_event_rollback_qty + X_Quantity_New;

       ELSE

           X_old_expenditure_item_id := X_Rev_expenditure_item_id;

	   X_event_rollback_amount := X_Rev_Amount_To_Insert;
	   X_event_rollback_qty := X_Quantity_New ;

       END IF;
  /* for bug 5242484 - end */


    -- Maintaining Cumulative Total for Creating Event --
       X_Rev_Event_Amount := X_Rev_Event_Amount + X_Rev_Amount_To_Insert;

    -- Maintaining total for Quantity etc for Description
       X_Rev_Run_Total := X_Rev_Run_Total + X_Quantity_New;

    -- Bug 3254097 : Shifted the call to UPD_ADL_BILLING_FLAG so that the flag gets updated only when
    --               the expenditure is processed.

       IF X_UPD_BILLING_FLAG  -- Bug 3233706
 OR ((X_Rev_Amount_To_Insert = 0) AND (  X_Rev_Tot_Burd_Amt_To_Insert = 0 ) ) THEN -- added for bug 5182669
 --OR ((X_Rev_Expenditure_Cost + X_Rev_Tot_Burden_Amt_In_View) = (X_Rev_Amount_In_Intersect + X_Rev_Tot_Burd_Amt_In_Tmp)) then -- bug 5122434--Commented for bug 5182269

          IF L_DEBUG = 'Y' THEN
             gms_error_pkg.gms_debug('Revenue accrual : Calling UPD_ADL_BILLING_FLAG For expenditure_item_id '||X_Rev_Expenditure_Item_Id,'C');
          END IF;

          UPD_ADL_BILLING_FLAG(X_Rev_Expenditure_Item_Id,
			  X_Rev_Adl_Line_Num,
                          X_Calling_Process,
                          X_Rev_Billable_Flag,
                          X_Rev_Bill_Hold_Flag,
			  St_Err_Code,
			  St_Err_Buff);

            	If St_Err_Code <> 0 then
			Raise NO_PROCESSING_OF_AWARD ;
            	End If;
       END IF;
--------------------------------------------------


 End If; --????????????

 /* for bug 5242484 - start  */
IF (
        (   (X_Rev_Expenditure_Cost + X_Rev_Tot_Burden_Amt_In_View)  - (X_Rev_Amount_In_Intersect + X_Rev_Tot_Burd_Amt_In_Tmp)
           > ( X_Rev_Money_Left_In_Inst - C_Rev_Inst_Task_Run_Total) )
    AND (X_Rev_Total_Funding_Amount <> -99 and X_Total_Rev_Amount <> -99)
    AND (X_Revenue_Limit_Flag = 'Y')
    AND ( X_Rev_expenditure_item_id = X_old_expenditure_item_id )
   )  THEN

IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('Calling Procedure EI rollback with parameters :- ','C');
        gms_error_pkg.gms_debug('EI rollback : Expenditure_item_id is '||x_Rev_expenditure_item_id,'C');
	gms_error_pkg.gms_debug('EI rollback : Adl_line_num is '||x_Rev_adl_line_num,'C');
	gms_error_pkg.gms_debug('EI rollback : Project id is '||x_act_project_id_old,'C');
	gms_error_pkg.gms_debug('EI rollback : Task id is '||x_task_id_old,'C');
	gms_error_pkg.gms_debug('EI rollback : Rollback amt is '||x_event_rollback_amount,'C');
	gms_error_pkg.gms_debug('EI rollback : Rollback qty is '||x_event_rollback_qty,'C');
	gms_error_pkg.gms_debug('EI rollback : Installment Count is '||x_Rev_Count,'C');
END IF;

     ei_rollback(x_Rev_award_id,
            'REVENUE',
	    x_Rev_expenditure_item_id,
	    x_rev_adl_line_num,
	    x_act_project_id_old,
            x_task_id_old,
	    X_Rev_Count);

X_Rev_Run_Total := X_Rev_Run_Total - x_event_rollback_qty ;
X_Rev_Event_Amount := X_Rev_Event_Amount - X_event_rollback_amount;

gms_error_pkg.gms_debug('Rolled back EI '||X_Rev_expenditure_item_id||' ! ','C');
/* for bug 5242484 - end  */

END IF;

          <<DO_NOT_PROCESS_REV>>

            NULL;

          EXCEPTION
  	    WHEN RESOURCE_BUSY THEN
            ROLLBACK TO REV_EXP_ITEM_PROCESSING;
     		  ss_text := SQLCODE||' '||SQLERRM;

	    WHEN OTHERS THEN
                  ss_text := SQLCODE||' '||SQLERRM;
                  -- insert into ss_log(id,err_text) values (2,ss_text);
            ROLLBACK TO REV_EXP_ITEM_PROCESSING;
  End;
 End LOOP;

     /* For last row Processing */
   -- Following IF .. End if statement commented for NULL Events logic ..
   -- zero $ amount logic shifted to DO_REV_EVENT_PROCESSING

   --If X_Rev_Event_Amount <> 0 then
       -- X_LAST_CALL_FOR_REVENUE := TRUE; -- Bug 3254097
       IF L_DEBUG = 'Y' THEN
       	gms_error_pkg.gms_debug('IN REVENUE_ACCRUAL, last call ...','C');
       END IF;
       DO_REV_EVENT_PROCESSING(X_Act_Project_Id_Old,
                               X_Task_Id_Old,
                               X_Expenditure_Type_Old,
                               X_Expenditure_Org_Id_Old,
 			       X_Units_Old,
                               X_Rev_Run_Total,
                               X_Project_Id,
                               X_Rev_Event_Amount,
                               X_Rev_Carrying_Out_Org_Id,
                               X_rev_or_bill_date,
                               X_calling_process,
                               X_Request_id,
                               C_Installment_Id,
			       X_Rev_Count,
			       X_Rev_Installment_total,
                               St_Err_Code,
                               St_Err_Buff);
	--X_LAST_CALL_FOR_REVENUE := FALSE; -- Bug 3254097
   --End If;

 End;
 CLOSE rev_cur_select;

End REVENUE_ACCRUAL;

------------------------------------------------------------------------
------------------------------------------------------------------------
--Procedure UPDATE_PROJECT_MANAGER : This procedure updates Award Project Manager
--with current Award Manager
--Stoped use of this procedure because GMS will be updating project manager
--through award form only to fix bug 1907565
------------------------------------------------------------------------
PROCEDURE UPDATE_PROJECT_MANAGER(X_Project_Id IN NUMBER,
				 X_Award_Id   IN NUMBER) IS
X_Person_Id NUMBER(15);
X_end_date_active DATE := NULL;  		-- Bug fix for 863428
Begin

 Begin
  Select
  person_id,
  end_date_active
  into
  X_Person_Id,
  X_end_date_active				-- Bug fix for 863428
  from
  GMS_PERSONNEL
  where award_id = X_Award_Id
  and trunc(sysdate) between trunc(start_date_active) and trunc(end_date_active)
  and award_role = 'AM';
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
           Begin
             Select
              person_id
             into
              X_Person_Id
             from
             GMS_PERSONNEL
             where award_id = X_Award_Id
             and award_role = 'AM'
             and end_date_active IS NULL;
                  EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                Begin
                                        Select
                                        person_id
                                        into
                                        X_Person_Id
                                        from
                                        GMS_PERSONNEL
                                        where award_id = X_Award_Id
                                        and award_role = 'AM'
                                        and end_date_active = (select max(end_date_active)
                                                               from gms_personnel
                                                               where
                                                                   award_id = X_Award_Id
                                                               and award_role = 'AM');

                                End ;
           End ;
   End;


 Begin

  update pa_project_parties
  set   resource_source_id=X_Person_Id,
        end_date_active = X_end_date_active
  where project_id = X_Project_Id
  and project_role_id =(select project_role_id
                        from   pa_project_role_types
                        where  project_role_type = 'PROJECT MANAGER');
 Exception
  when others then
       RAISE;
 End;

End UPDATE_PROJECT_MANAGER;

-----------------------------------------------------------------------------------------
-- Procedure AWARD_BILLING: This is the actual Billing Extension which gets called by the core
-- Billing or Revenue Programs.
-----------------------------------------------------------------------------------------
PROCEDURE AWARD_BILLING
( X_project_id IN NUMBER,
                         X_top_Task_id IN NUMBER DEFAULT NULL,
                         X_calling_process IN VARCHAR2 DEFAULT NULL,
                         X_calling_place IN VARCHAR2 DEFAULT NULL,
                         X_amount IN NUMBER DEFAULT NULL,
                         X_percentage IN NUMBER DEFAULT NULL,
                         X_rev_or_bill_date IN DATE DEFAULT NULL,
                         X_bill_extn_assignment_id IN NUMBER DEFAULT NULL,
                         X_bill_extension_id IN NUMBER DEFAULT NULL,
                         X_request_id IN NUMBER DEFAULT NULL) IS
sql_select VARCHAR2(4000);
sql_from VARCHAR2(2000);
sql_where  VARCHAR2(2000);
sql_orderby VARCHAR2(2000);
l_sql_orderby VARCHAR2(2000); --Bug 3235390

X_Award_Id NUMBER(15);
X_Award_Rev_Distribution_Rule VARCHAR2(30);
X_Award_Bill_Distribution_Rule VARCHAR2(30);
X_Award_Status    VARCHAR2(30);
X_Revenue_Limit_Flag VARCHAR2(1);
X_Invoice_Limit_Flag VARCHAR2(1);  /*Bug 6642901 */
/* Added for bug 5026657 */
g_process_again VARCHAR2(1) DEFAULT 'N';
g_labor_exp_to_process VARCHAR2(1) DEFAULT 'N';
g_non_labor_neg_exp_processed VARCHAR2(1) DEFAULT 'N';
f_labor_exp_to_process VARCHAR2(1) DEFAULT 'N';
f_non_labor_neg_exp_processed VARCHAR2(1) DEFAULT 'N';

CURSOR GET_INSTALLMENTS IS
Select
Installment_Id,
Start_Date_Active,
End_Date_Active
from
GMS_INSTALLMENTS
where
Award_Id = X_Award_Id
/*  and active_flag = 'Y'  bug 6878405  */
and nvl(billable_flag,'N') = 'Y'
order by End_Date_Active;

-- Added for Bug 1744641: To Generate errors when an exception occurs
-- during the process of generation of invoice/Revenue.
Cursor GMS_AWARDS_CURSOR is
select
      a.Award_number,
      a.Award_short_name,
      a.award_id
    from
    GMS_AWARDS a
    where
      a.Award_Project_Id = X_Project_Id;

/* Fetch Variables for GET_INSTALLMENTS */
 C_Installment_Id      NUMBER(15);
 C_Start_Date_Active   DATE;
 C_End_Date_Active     DATE;

X_Labor_Sel_Grp_Diff_Ind Mark_Sel_Grp_Diff_Array;
X_Lbr_Rt_Jstfy_Flag Mark_Sel_Grp_Diff_Array;
X_Lbr_Padding_Length Padding_Length_Array;
X_Lbr_Text_Array Free_Text_Array;
X_Lbr_Cnt_Of_Columns_Selected NUMBER(3) := 0;
X_LABOR_CONCAT_SELECT VARCHAR2(2000);
X_LABOR_CONCAT_FROM VARCHAR2(2000);
X_LABOR_CONCAT_WHERE VARCHAR2(2000);
X_LABOR_CONCAT_ORDERBY VARCHAR2(2000);
X_LABOR_ORDERBY_IS_NULL VARCHAR2(1);

X_Non_Labor_Sel_Grp_Diff_Ind Mark_Sel_Grp_Diff_Array;
X_Nlbr_Rt_Jstfy_Flag Mark_Sel_Grp_Diff_Array;
X_Nlbr_Padding_Length Padding_Length_Array;
X_Nlbr_Text_Array Free_Text_Array;
X_Nlbr_Cnt_Of_Columns_Selected NUMBER(3) := 0;
X_NON_LABOR_CONCAT_SELECT VARCHAR2(2000);
X_NON_LABOR_CONCAT_FROM VARCHAR2(2000);
X_NON_LABOR_CONCAT_WHERE VARCHAR2(2000);
X_NON_LABOR_CONCAT_ORDERBY VARCHAR2(2000);
X_NON_LABOR_ORDERBY_IS_NULL  VARCHAR2(1);
/* Following two variables added for bug 3523930 */
X_LABOR_tsk_lvl_fmt VARCHAR2(1) :='N';
X_NON_LABOR_tsk_lvl_fmt VARCHAR2(1) :='N';

X_Format_Specific_Where  VARCHAR2(2000) := NULL;
X_Fixed_Select VARCHAR2(2000) := NULL;
X_Fixed_Where VARCHAR2(2000) := NULL;
X_Fixed_From VARCHAR2(2000) := NULL;

X_Class_Category VARCHAR2(30) := NULL;
X_Carrying_Out_Org_Id NUMBER(15);
X_Rev_Carrying_Out_Org_Id NUMBER(15);

X_Sponsored_Type_Flag   VARCHAR2(1);
X_Project_Type		VARCHAR2(30);

X_Trx_Type  VARCHAR2(15);

X_Period_Status VARCHAR2(1);

X_Err_Num NUMBER;
X_Err_Stage VARCHAR2(200);

x_pa_err_msg VARCHAR2(2000);
x_pa_status NUMBER;

St_Err_Code  NUMBER(1);
St_Err_Buff    Varchar2(2000);

X_award_number VARCHAR2(15);--For bug 1744641
X_award_name   varchar2(250);--For bug 1744641
X_awd_id       NUMBER;

/* bug 5242484 - start */
k NUMBER := 0;
x_tot_inst_count NUMBER := 0;
/* bug 5242484 - end */

f_dummy NUMBER := 0 ;--For Bug 5026657

X_Position Number(3);

-- ##This is to process awards that has no expenditures to process
NO_EXP_TO_PROCESS Exception;

Begin

SAVEPOINT AWARD_BILLING_BEGIN;   -- Added for bug 4243374
gms_error_pkg.set_debug_context; -- Added for Bug: 2510024

-- Code added for bug 1744641
open GMS_AWARDS_CURSOR;
Fetch gms_awards_cursor into X_award_number,X_award_name, x_awd_id;
Close GMS_AWARDS_CURSOR;
--End of the Code added for bug 1744641

/* GMS INSTALLATION CHECK */
If gms_install.enabled then

IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('GMS INSTALLED -- START AWARD BILLING FOR Award Project:','C');
	gms_error_pkg.gms_debug('X_Project_id:'||X_Project_id,'C');
END IF;

-- Bug 1980810 : Added to set currency related global variables
--		 Call to pa_currency.round_currency_amt function will use
--		 global variables and thus improves performance

pa_currency.set_currency_info;

-- Concurrency Control
     gms_bill_concurrency(X_request_id,
			  X_Project_id,
			  St_Err_Code,
			  St_Err_Buff);
IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('After gms_bill_concurrency x_error_code :'||St_Err_Code,'C');
END IF;

  If St_Err_Code <> 0  then
      gms_error_pkg.gms_message('GMS_BILLING_CONCURRENCY',
                                'PRJ',
                                X_Project_id,
                                X_Exec_Type => 'C',
                                X_Err_Code => St_Err_Code,
                                X_Err_Buff => St_Err_Buff);

     Raise NO_PROCESSING_OF_AWARD ;

  End if;

/*-------------------------------------------------------------------------
|| Following Begin ... End code has been added for concurrency control.
|| If a user is updating any billing related data, billing process should
|| not run for that award. Corollary: If billing process is running for an
|| award, users should not be able to update any billing data on the award
|| form. Bug 1652198.....
|| Procedure: lock_award_records created for this.
 ------------------------------------------------------------------------- */
-- ## Code change starts here for Bug 1652198....
/**FOr Bug 4506225 :MOved the code after the call to GMS_TAX
   lock_award_records(X_Project_id,
		      St_Err_Code,
		      St_Err_Buff);

  IF L_DEBUG = 'Y' THEN
  	gms_error_pkg.gms_debug('After lock_award_records St_Err_Code :'||St_Err_Code,'C');
  END IF;

    If St_Err_Code <> 0  then
      gms_error_pkg.gms_message('GMS_BILLING_CONCURRENCY',
                                'PRJ',
                                X_Project_id,
                                X_Exec_Type => 'C',
                                X_Err_Code => St_Err_Code,
                                X_Err_Buff => St_Err_Buff);

     Raise NO_PROCESSING_OF_AWARD ;

  End if;
---End of moving of code for bug 4506225*/
-- ## Code change ends here for Bug 1652198....


-- Process failure rollback
         billing_rollback(X_Project_id,
		          --X_calling_process,
                          NULL, -- event_num
                          St_Err_Code,
                          St_Err_Buff);

IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('After billing_rollback x_error_code :'||St_Err_Code,'C');
END IF;

  If St_Err_Code <> 0  then
      gms_error_pkg.gms_message('GMS_BILLING_ROLLBACK_FAILURE',
                                'PRJ',
                                X_Project_id,
                                X_Exec_Type => 'C',
                                X_Err_Code => St_Err_Code,
                                X_Err_Buff => St_Err_Buff);
     Raise ROLLBACK_FAILURE;

  End if;

-- This function check was done for performance reasons
-- If there are no transactions to be processed, RETURN from this process.
-- We're  filtering by bare minimum conditions only.

IF NOT IS_PROCESSING_REQD(X_Calling_Process , X_Awd_Id ) THEN

   IF L_DEBUG = 'Y' THEN
   	gms_error_pkg.gms_debug('No records to process - NOT IS_PROCESSING_REQD :'||St_Err_Code,'C');
   END IF;
   RAISE NO_EXP_TO_PROCESS;
   -- NO recored for processing, we raising an exception to cleanup GMS processing

END IF;


/* Selecting the Project Type. GO THROUGH BILL_EXTENSION only if
   Project_Type = 'AWARD_PROJECT'
*/
  Begin
     Select
     project_type,
     carrying_out_organization_id --This is being selected again here because Revenue
     into                         --doesn't have access to GET_FORMAT_SELECT
     X_Project_Type,
     X_Rev_Carrying_Out_Org_Id
     from
     PA_PROJECTS_ALL
     where
     project_id = X_Project_Id;

   EXCEPTION
    WHEN OTHERS THEN
      gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => St_Err_Code,
				X_Err_Buff => St_Err_Buff);
      --RAISE_APPLICATION_ERROR(-20526,St_Err_Buff);
      Raise NO_PROCESSING_OF_AWARD ;
      --RETURN;

  End;

   IF L_DEBUG = 'Y' THEN
   	gms_error_pkg.gms_debug('Project Type is :'||X_Project_Type,'C');
   END IF;

/* ===============================================================================
|| Code for period validation has been commented out.
|| bug number: 1510848, release 11.5D
  =============================================================================== */

If X_Project_Type = 'AWARD_PROJECT' then --

  -- Selecting the Class Category--
  Begin
  select
  cc.class_category
  into
  X_Class_Category
  from
  pa_class_categories cc
  where
  sysdate between cc.start_date_active and
  nvl(cc.end_date_active,SYSDATE + 1) and
  cc.autoaccounting_flag = 'Y';
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     X_Class_Category := NULL;
  End;

   IF L_DEBUG = 'Y' THEN
   	gms_error_pkg.gms_debug('After Class Category select','C');
   END IF;

  Begin
    select
      a.Award_Id,
      a.Revenue_Distribution_Rule,
      a.Billing_Distribution_Rule,
      a.Status,
      -- ag.Revenue_Limit_Flag -- Bug 1841288
      nvl(a.hard_limit_flag,'N') -- Bug 1841288 : Taken hard_limit_flag from gms_awards instead of pa_agreements_all
      ,nvl(a.invoice_limit_flag,'N') -- Bug 6642901
    into
      X_Award_Id, -- Adding this because Revenue Process doesnot have access to GET_FORMAT_SELECT proc.
      X_Award_Rev_Distribution_Rule,
      X_Award_Bill_Distribution_Rule,
      X_Award_Status,
      X_Revenue_Limit_Flag,
      X_Invoice_limit_Flag -- Bug 6642901
    from
    GMS_AWARDS a
    --PA_AGREEMENTS_ALL ag -- Bug 1841288 : Removed join from PA_AGREEMENTS_ALL Table
    where
      a.Award_Project_Id = X_Project_Id;
  -- and a.agreement_id = ag.agreement_id;  -- Bug 1841288 : Removed the join
  End;

  IF L_DEBUG = 'Y' THEN
  	gms_error_pkg.gms_debug('Distribution Rule:Revenue:'||X_Award_Rev_Distribution_Rule,'C');
  	gms_error_pkg.gms_debug('Distribution Rule:Invoice:'||X_Award_Bill_Distribution_Rule,'C');
  END IF;

--------------------------------------------------------------------------------------------------------- +
-- Bug 3143102 : Following code takes care of the scenario where the labor and/or non-labor format
-- has an invalid element ..
  If (X_calling_process = 'Invoice' and X_Award_Bill_Distribution_Rule = 'COST') THEN

      IF NOT Is_Invoice_Format_Valid(X_project_id,NULL,NULL,'BILLING_PROCESS') THEN

         IF L_DEBUG = 'Y' THEN
  	    gms_error_pkg.gms_debug('Labor/Non-Labor format is Invalid','C');
         END IF;

         RAISE INVALID_INVOICE_FORMAT;

      End If;

  End If;

  IF L_DEBUG = 'Y' THEN
  	gms_error_pkg.gms_debug('Labor/Non-Labor format is Valid','C');
  END IF;
--------------------------------------------------------------------------------------------------------- +

-- CALL TAX UPDATION PROCEDURE

     gms_tax(X_Project_Id,
	     X_Award_Id,
	     X_Rev_Or_Bill_Date,
	     X_Request_Id,
	     St_Err_Code,
	     St_Err_Buff
	     );

    If St_Err_Code <> 0 then
       --ROLLBACK;
       --RAISE FND_API.G_EXC_ERROR;
	--Raise NO_PROCESSING_OF_AWARD ;--4506225
	Raise GMS_TAX_FAILURE; --4506225
   End If;

IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('After tax, x_error_code :'||St_Err_Code,'C');
END IF;
 --For Bug 4506225 :Moved the code after gms_Tax
 lock_award_records(X_Project_id,
                      St_Err_Code,
                      St_Err_Buff);

  IF L_DEBUG = 'Y' THEN
        gms_error_pkg.gms_debug('After lock_award_records St_Err_Code :'||St_Err_Code,'C');
  END IF;

    If St_Err_Code <> 0  then
      gms_error_pkg.gms_message('GMS_BILLING_CONCURRENCY',
                                'PRJ',
                                X_Project_id,
                                X_Exec_Type => 'C',
                                X_Err_Code => St_Err_Code,
                                X_Err_Buff => St_Err_Buff);

     Raise NO_PROCESSING_OF_AWARD ;

  End if;
--End of bug fix for Bug 4506225
   --commit;

If X_Award_Status in ('ACTIVE','ON_HOLD') then  -- Do processing only if Award Status is Active

        --UPDATE_PROJECT_MANAGER(X_Project_Id,X_Award_Id);
          /* Stopped updating in billing process because now onwards GMS
              will update project manager through award form only to fix  bug 1907565 gnema*/

 -- Bug 3235390  : Intializing the variables used .
 x_temp_negative_evt_num := -1000;

IF (
     -- (X_calling_process = 'Revenue' and X_Award_Rev_Distribution_Rule = 'COST')  OR
      (X_calling_process = 'Invoice' and X_Award_Bill_Distribution_Rule = 'COST')
    ) then -- Check for Billing Distribution Rule
 Begin

  GET_FORMAT_SELECT(X_Project_Id,
                    X_Award_Id,
                    X_Carrying_Out_Org_Id,
                    X_Labor_Sel_Grp_Diff_Ind,
                    X_Non_Labor_Sel_Grp_Diff_Ind,
                    X_Lbr_Cnt_Of_Columns_Selected,
                    X_Nlbr_Cnt_Of_Columns_Selected,
                    X_Lbr_Rt_Jstfy_Flag,
                    X_Nlbr_Rt_Jstfy_Flag,
                    X_Lbr_Padding_Length,
                    X_Nlbr_Padding_Length,
                    X_Lbr_Text_Array,
                    X_Nlbr_Text_Array,
 		    X_LABOR_CONCAT_SELECT,
                    X_LABOR_CONCAT_FROM,
                    X_LABOR_CONCAT_WHERE,
                    X_LABOR_CONCAT_ORDERBY,
   		    X_LABOR_ORDERBY_IS_NULL,
                    X_NON_LABOR_CONCAT_SELECT,
                    X_NON_LABOR_CONCAT_FROM,
                    X_NON_LABOR_CONCAT_WHERE,
                    X_NON_LABOR_CONCAT_ORDERBY,
                    X_NON_LABOR_ORDERBY_IS_NULL,
		    X_LABOR_tsk_lvl_fmt,  /* added for bug 3523930 */
		    X_NON_LABOR_tsk_lvl_fmt,  /* added for bug 3523930 */
                    X_Err_Num,
                    X_Err_Stage);

         --dbms_output.put_line('After GET_FORMAT_SELECT Proc '||'Award Id '||to_char(X_Award_Id) );

IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('After Format Selection','C');
END IF;


  sql_select := 'select /*+INDEX(ei PA_EXPENDITURE_ITEMS_U1)*/  ';
  sql_from   := 'from ';
  sql_where  := 'where ';
  X_Fixed_Select := ' adl.raw_cost, ei.expenditure_item_id, ei.expenditure_item_date, ei.task_id,
  ei.bill_hold_flag, adl.billable_flag, ei.adjusted_expenditure_item_id, adl.adl_line_num,adl.parent_adl_line_num,
  adl.adl_status, adl.award_id, adl.project_id, adl.cdl_line_num,ei.expenditure_type,
  nvl(ei.override_to_organization_id,e.incurred_by_organization_id),adl.ind_compiled_Set_id,adl.burdenable_raw_cost,
  ei.transaction_source '; --bug 2909746

  X_Fixed_From := 'pa_expenditure_items_all ei ,pa_expenditures_all e, pa_expenditure_types et,'
  ||' pa_projects_all p, pa_project_types pt,'
  ||' pa_tasks t3, pa_tasks t5, gms_award_distributions adl ';

/* --- 11.5 changes --- */
--1. gms_award_distributions  added in the from clause
--2. 4 new columns being selected from gms_award_distributions, raw_cost picked differently


 /* The DYNAMIC WHERE CLAUSE BUILDING below for Revenue is NOT USED any more. Replaced by the Procedure
    REVENUE_ACCRUAL
  */
If X_calling_process = 'Revenue' then

 null;

Elsif X_calling_process = 'Invoice' then

/* ---   11.5 Changes ---
-- 1.Columns like billed_flag,award_id, revenue_distributed_flag being picked from gms_award_distributions
-- 2.Column attribute2 IS NULL changed to adl.document_type <>'ENC'
-- 3.condtions to join gms_award_distributions and pa_expenditure_items_all added
-- 4.check for adl lines with adl status <> 'I'
*/

X_Fixed_Where := ' adl.award_id = :X_Award_Id '
  ||'and ei.expenditure_item_id = adl.expenditure_item_id '
  ||'and adl.adl_status <> ''I'' '
  ||'and ei.system_linkage_function <> ''BTC'' '
  ||'and p.project_status_code <> ''CLOSED'' '
  ||'and pt.project_type = p.project_type '
  ||'and pt.direct_flag = ''N'' '
  ||'and t3.project_id = p.project_id '   --Changed t to t2, then changed t2 to t3 to get rid or ORA-09118
  ||'and ei.task_id = t3.task_id '
  ||'and t3.top_task_id = t5.task_id '
  ||'and t5.ready_to_bill_flag = ''Y'' '
  ||'and ((adl.line_num_reversed is null and adl.reversed_flag is null and ei.cost_distributed_flag = ''Y'') '
  ||'     or  ((adl.line_num_reversed is not null or adl.reversed_flag is not null) and adl.cost_distributed_flag = ''Y''))' -- Bug 1852802
  ||'and nvl(ei.bill_hold_flag,''N'') = ''N'' '
  ||'and ei.expenditure_item_date <= nvl(trunc(:X_rev_or_bill_date),SYSDATE) '
  ||'and trunc(ei.expenditure_item_date) <= trunc(:C_End_Date_Active) '
  ||'and nvl(adl.billed_flag,''N'') <> ''Y'' ' -- To pick up items where Billed Flag <> 'Y'
  ||'and ei.expenditure_type = et.expenditure_type '
  ||'and e.expenditure_id = ei.expenditure_id '
  ||'and adl.fc_status = ''A'' '
  ||'and adl.adl_status = ''A'' '
  ||'and nvl(adl.billable_flag,''N'') = ''Y'' '
  ||'and adl.document_type = ''EXP''  '
  ||'and  exists '
  ||'(select 1 '
  ||'from gms_summary_project_fundings gspf '
  ||'where gspf.installment_id = :C_Installment_Id '
  ||'and ( '
  ||'    (gspf.task_id  = adl.task_id) '
  ||'OR  (gspf.task_id is NULL) '
  ||'OR  (gspf.task_id = (select t1.top_task_id from pa_tasks t1 where t1.task_id = adl.task_id)) '
  ||'   ) '
  ||'and gspf.project_id     = adl.project_id '
  ||') ';

End If;

/* bug 5242484 - start */
select count(*)
into x_tot_inst_count
from gms_installments
where award_id = X_Award_id
/* and active_flag = 'Y' bug 6878405 */
and nvl(billable_flag,'N') = 'Y';

FOR k in 1..x_tot_inst_count LOOP
X_ei_rollback_inst_tab(k).rev_bill_amount := 0;
X_ei_rollback_inst_tab(k).installment_id := 0;
END LOOP;
/* bug 5242484 - end */

------------------------------------------------------------------
/* Opening the Cursor to Process each Installment of this Award (For INVOICE Processing) */
------------------------------------------------------------------
OPEN GET_INSTALLMENTS;
 BEGIN
   LOOP
    FETCH GET_INSTALLMENTS into
    C_Installment_Id,
    C_Start_Date_Active,
    C_End_Date_Active;


    EXIT WHEN GET_INSTALLMENTS%NOTFOUND;


 -- BUG 3235390 : Deleting data from gms_events_temp_format
 DELETE gms_events_temp_format;

 /* For bug 5026657 */
 f_dummy := 0;

WHILE f_dummy<2 LOOP   /* dummy loop for re-processing , bug 5026657 */

f_dummy := f_dummy + 1;


IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('In installment loop, Installment_Id :'||C_Installment_Id,'C');
END IF;

/*============================================================================================*/
/* Processing Begins here for the rows which have expenditure type which are LABOR related */
/*==============================================================================================*/
X_Format_Specific_Where := 'and ei.system_linkage_function in (''ST'',''OT'') ';
sql_select := sql_select||X_LABOR_CONCAT_SELECT;
sql_select := sql_select||X_Fixed_Select;

sql_from := sql_from||X_LABOR_CONCAT_FROM;
sql_from := sql_from||X_Fixed_From;

sql_where := sql_where||X_LABOR_CONCAT_WHERE;
sql_where := sql_where||X_Fixed_Where;
sql_where := sql_where||X_Format_Specific_Where;

/* ------ GROUP BY CHANGES ------- */
select instr(UPPER(X_LABOR_CONCAT_SELECT),'SUM',1,1)
into   X_position
from   dual;

if x_position=0 then
   sql_orderby := ' order by ';
elsif x_position >0 then
   sql_orderby := ' group by ';
end if;
/* ------ GROUP BY CHANGES ------- */

-- Bug 3235390 : Modified the order by clause
l_sql_orderby :=' DECODE( NVL(ei.net_zero_adjustment_flag,'||''''||'N'||''''||'),'||''''||'N' ||''''||
 ', NVL(ei.raw_cost,gms_billing.get_total_adl_raw_cost('||''''||'Invoice'||''''||',ei.expenditure_item_id)),'
   ||''''||'Y'||''''||', DECODE(SIGN(NVL(ei.raw_cost,gms_billing.get_total_adl_raw_cost('
   ||''''||'Invoice'||''''||',ei.expenditure_item_id))),'
   ||'1,-NVL(ei.raw_Cost,gms_billing.get_total_adl_raw_cost('||''''||'Invoice'||''''||
   ',ei.expenditure_item_id)),' ||' NVL(ei.raw_cost,gms_billing.get_total_adl_raw_cost('
   ||''''||'Invoice'||''''||',ei.expenditure_item_id)))),'
   || 'NVL(ei.raw_cost,gms_billing.get_total_adl_raw_cost('||''''||'Invoice'||''''
   ||',ei.expenditure_item_id)),NVL(ei.adjusted_expenditure_item_id,ei.expenditure_item_id),'
   || 'adl.raw_cost, adl.cdl_line_num';


if x_position=0 then
 sql_orderby := sql_orderby || l_sql_orderby ||',';
elsif x_position >0 then
   sql_orderby := sql_orderby || ' ei.raw_cost,adl.raw_cost, ei.net_zero_adjustment_flag, ';
end if;

-- Bug 1652198, moved format order by first.
  sql_orderby := sql_orderby || X_LABOR_CONCAT_ORDERBY;

--sql_orderby := sql_orderby||' adl.output_vat_tax_id, adl.output_tax_exempt_flag, adl.output_tax_exempt_number, adl.output_tax_exempt_reason_code ';
sql_orderby := sql_orderby||' adl.output_tax_classification_code, adl.output_tax_exempt_flag, adl.output_tax_exempt_number, adl.output_tax_exempt_reason_code ';

--Bug 2909746 : Added cdl_line_num in the order by clause

If X_LABOR_ORDERBY_IS_NULL = 'N' then

  sql_orderby := sql_orderby||' ,ei.expenditure_item_id, adl.cdl_line_num,adl.adl_line_num ';

Elsif X_LABOR_ORDERBY_IS_NULL = 'Y' then

  sql_orderby := sql_orderby||' ,ei.expenditure_item_id, adl.cdl_line_num,adl.adl_line_num ';

End If;

-- 11.5 Change, Added adl.adl_line_num in the order by clause

/* ------ GROUP BY CHANGES ------- */
if x_position >0 then
sql_orderby := sql_orderby||' ,  ei.expenditure_item_date '||
               ', ei.task_id,ei.bill_hold_flag, adl.billable_flag, ei.adjusted_expenditure_item_id, '||
               ' adl.parent_adl_line_num, adl.adl_status, adl.award_id, adl.project_id,  '||
	       'ei.expenditure_type,nvl(ei.override_to_organization_id,e.incurred_by_organization_id),'||
	       ' adl.ind_compiled_Set_id, adl.burdenable_raw_cost,  ei.transaction_source';
end if;

/* ------ GROUP BY CHANGES ------- */

      For i in 1..X_Lbr_Cnt_Of_Columns_Selected LOOP
	   null;
            --dbms_output.put_line('Column :'||X_Labor_Sel_Grp_Diff_Ind(i));
      END LOOP;
      For i in 1..X_Nlbr_Cnt_Of_Columns_Selected LOOP
		null;
            --dbms_output.put_line('Column :'||X_Non_Labor_Sel_Grp_Diff_Ind(i));
      END LOOP;

  -- Bug 3235390 : Modified the below logic to introduce new order by clause
  -- sql_select := sql_select||' '||sql_from||' '||sql_where||' '||sql_orderby ;
  IF  x_position=0 THEN
      sql_select := sql_select||' '||sql_from||' '||sql_where||' '||sql_orderby ;
  ELSIF x_position >0 THEN
      sql_select := sql_select||' '||sql_from||' '||sql_where||' '||sql_orderby ||'  order by ' ||  l_sql_orderby  ;
  END IF;


--dbms_output.put_line('Processing LABOR Transactions ');

IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('Before FORMAT_SPECIFIC_BILLING call','C');

END IF;

/* bug 5413530 */
X_Trans_type := 'LABOR';
IF ( f_dummy = 2 ) THEN G_trans_type := 'LABOR';
END IF;

     FORMAT_SPECIFIC_BILLING(X_Project_Id,
                             X_Award_Id,
                             X_Class_Category,
                             X_rev_or_bill_date,
			--     X_Revenue_Limit_Flag,
				     X_Invoice_Limit_Flag, /* for bug 6642901*/
                             X_request_id,
                             X_Labor_Sel_Grp_Diff_Ind,
                             X_Lbr_Cnt_Of_Columns_Selected,
                             X_Lbr_Rt_Jstfy_Flag,
                             X_Lbr_Padding_Length,
                             X_Lbr_Text_Array,
                             sql_select,
                             X_Carrying_Out_Org_Id,
                             X_calling_process,
			     X_LABOR_tsk_lvl_fmt,  /* added for bug 3523930 */
                             C_Installment_Id,
                             C_Start_Date_Active,
                             C_End_Date_Active,
                             X_Err_Num,
                             X_Err_Stage,
			     'LABOR',            /* added for bug 5026657 */
			     f_labor_exp_to_process, /* added for bug 5026657 */
			     f_non_labor_neg_exp_processed); /* added for bug 5026657 */

g_labor_exp_to_process := f_labor_exp_to_process;

/*======================================================================================*/
/* Processing begins here for rows which have Expenditure Types which are NON-LABOR related */
/*=======================================================================================*/
sql_select := 'select /*+INDEX(ei PA_EXPENDITURE_ITEMS_U1)*/  ';
sql_from   := 'from ';
sql_where  := 'where ';
X_Format_Specific_Where := 'and ei.system_linkage_function not in (''ST'',''OT'') ';
sql_select := sql_select||X_NON_LABOR_CONCAT_SELECT;
sql_select := sql_select||X_Fixed_Select;

sql_from := sql_from||X_NON_LABOR_CONCAT_FROM;
sql_from := sql_from||X_Fixed_From;

sql_where := sql_where||X_NON_LABOR_CONCAT_WHERE;
sql_where := sql_where||X_Fixed_Where;
sql_where := sql_where||X_Format_Specific_Where;

/* ------ GROUP BY CHANGES ------- */

x_position := 0;

select instr(UPPER(X_NON_LABOR_CONCAT_SELECT),'SUM',1,1)
into   X_position
from   dual;

if x_position=0 then
   sql_orderby := ' order by ';
elsif x_position >0 then
   sql_orderby := ' group by ';
end if;
/* ------ GROUP BY CHANGES ------- */

-- Bug 3235390 : Modified the order by clause
l_sql_orderby := ' DECODE( NVL(ei.net_zero_adjustment_flag,'||''''||'N'||''''||'),'||''''||'N' ||''''||
 ', NVL(ei.raw_cost,gms_billing.get_total_adl_raw_cost('||''''||'Invoice'||''''||',ei.expenditure_item_id)),'
   ||''''||'Y'||''''||', DECODE(SIGN(NVL(ei.raw_cost,gms_billing.get_total_adl_raw_cost('
   ||''''||'Invoice'||''''||',ei.expenditure_item_id))),'
   ||'1,-NVL(ei.raw_Cost,gms_billing.get_total_adl_raw_cost('||''''||'Invoice'||''''||
   ',ei.expenditure_item_id)),' ||' NVL(ei.raw_cost,gms_billing.get_total_adl_raw_cost('
   ||''''||'Invoice'||''''||',ei.expenditure_item_id)))),'
   || 'NVL(ei.raw_cost,gms_billing.get_total_adl_raw_cost('||''''||'Invoice'||''''
   ||',ei.expenditure_item_id)),NVL(ei.adjusted_expenditure_item_id,ei.expenditure_item_id),'
   || 'adl.raw_cost, adl.cdl_line_num';


  if x_position=0 then
      sql_orderby :=  sql_orderby ||l_sql_orderby||',' ;
  elsif x_position >0 then
   sql_orderby := sql_orderby || ' ei.raw_cost,adl.raw_cost, ei.net_zero_adjustment_flag, ';
  end if;

-- Bug 1652198, moved format order by first.
  sql_orderby := sql_orderby || X_NON_LABOR_CONCAT_ORDERBY;


--sql_orderby := sql_orderby||' adl.output_vat_tax_id, adl.output_tax_exempt_flag, adl.output_tax_exempt_number, adl.output_tax_exempt_reason_code ';

sql_orderby := sql_orderby||' adl.output_tax_classification_code, adl.output_tax_exempt_flag, adl.output_tax_exempt_number, adl.output_tax_exempt_reason_code ';

--Bug 2909746 : Added cdl_line_num in the order by clause
If X_NON_LABOR_ORDERBY_IS_NULL = 'N' then

     sql_orderby := sql_orderby||' ,ei.expenditure_item_id, adl.cdl_line_num,adl.adl_line_num ';

Elsif X_NON_LABOR_ORDERBY_IS_NULL = 'Y' then

     sql_orderby := sql_orderby||' ,ei.expenditure_item_id, adl.cdl_line_num,adl.adl_line_num ';

End If;

-- 11.5 Change, Added adl.adl_line_num in the order by clause

/* ------ GROUP BY CHANGES ------- */
if x_position >0 then
sql_orderby := sql_orderby||' ,  ei.expenditure_item_date '||
               ', ei.task_id,ei.bill_hold_flag, adl.billable_flag, ei.adjusted_expenditure_item_id, '||
               ' adl.parent_adl_line_num, adl.adl_status, adl.award_id, adl.project_id, '||
	       'ei.expenditure_type,nvl(ei.override_to_organization_id,e.incurred_by_organization_id),'||
	       ' adl.ind_compiled_Set_id, adl.burdenable_raw_cost,  ei.transaction_source';
end if;

/* ------ GROUP BY CHANGES ------- */

  -- Bug 3235390 : Modified the below logic to introduce new order by clause

  IF  x_position=0 THEN
      sql_select := sql_select||' '||sql_from||' '||sql_where||' '||sql_orderby ;
  ELSIF x_position >0 THEN
      sql_select := sql_select||' '||sql_from||' '||sql_where||' '||sql_orderby || ' Order By '||l_sql_orderby  ;
  END IF;

--dbms_output.put_line('Processing NON LABOR Transactions ');

/* bug 5413530 */
X_Trans_type := 'NON-LABOR';

  FORMAT_SPECIFIC_BILLING(X_Project_Id,
                          X_Award_Id,
                          X_Class_Category,
                          X_rev_or_bill_date,
			 -- X_Revenue_Limit_Flag,
			 X_Invoice_Limit_Flag, /* for bug 6642901 */
                          X_request_id,
                          X_Non_Labor_Sel_Grp_Diff_Ind,
                          X_Nlbr_Cnt_Of_Columns_Selected,
                          X_Nlbr_Rt_Jstfy_Flag,
                          X_Nlbr_Padding_Length,
                          X_Nlbr_Text_Array,
                          sql_select,
                          X_Carrying_Out_Org_Id,
                          X_calling_process,
			  X_NON_LABOR_tsk_lvl_fmt,  /* added for bug 3523930 */
                          C_Installment_Id,
                          C_Start_Date_Active,
                          C_End_Date_Active,
                          X_Err_Num,
                          X_Err_Stage,
			  'NON LABOR',            /* added for bug 5026657 */
			  f_labor_exp_to_process, /* added for bug 5026657 */
			  f_non_labor_neg_exp_processed); /* added for bug 5026657 */

g_non_labor_neg_exp_processed := f_non_labor_neg_exp_processed ;

-------------------------------------------------------------------------
  sql_select := 'select /*+INDEX(ei PA_EXPENDITURE_ITEMS_U1)*/  ';		-- Bug 2380344 : Hardcoded Index for Performance Fix
  sql_from   := 'from ';
  sql_where  := 'where ';

/* Added for bug 5026657 */
IF (g_labor_exp_to_process = 'Y' and g_non_labor_neg_exp_processed = 'Y') THEN
g_process_again := 'Y';
ELSE
g_process_again := 'N';
END IF;

IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('f_dummy is '||f_dummy,'C');
        gms_error_pkg.gms_debug('g_process_again is '||g_process_again,'C');
	gms_error_pkg.gms_debug('g_labor_exp_to_process is '||g_labor_exp_to_process,'C');
	gms_error_pkg.gms_debug('g_non_labor_neg_exp_processed is '||g_non_labor_neg_exp_processed,'C');
END IF;

/* Added for bug 5026657 */
/* Commented revenue limit flag condition and added invoice limit flag check for bug 6642901
IF ( X_Revenue_Limit_Flag = 'N' OR
     ( X_Revenue_Limit_Flag = 'Y' AND g_process_again = 'N' ) ) THEN     -- %%%%%%% */

IF ( X_Invoice_Limit_Flag = 'N' OR
     ( X_Invoice_Limit_Flag = 'Y' AND g_process_again = 'N' ) ) THEN

f_dummy := f_dummy + 1;

-- Bug 3235390 : Calling the CREATE_PA_EVENTS procedure to insert records in pa_events
--               gms_event_attribute table from temporary table.

CREATE_PA_EVENTS (X_project_id          ,
	          X_Calling_Process ,
                  X_rev_or_bill_Date ,
                  X_Carrying_Out_Org_Id,
                  X_Request_Id ,
                  X_Installment_total,
		  St_Err_Code,
	          St_Err_Buff );

IF St_Err_Code <> 0 THEN
   raise NO_PROCESSING_OF_AWARD ;
END IF;


/* Moved this here from inside FORMAT_SPECIFIC_BILLING so that Burden for Labor and NonLabor appear together */

        DO_BURDEN_EVENT_PROCESSING(X_Project_Id,
                                   X_rev_or_bill_Date,
                                   X_Calling_Process,
                                   X_Carrying_Out_Org_Id,
                                   X_Request_Id,
				   X_Installment_total,
				   St_Err_Code,
				   St_Err_Buff);
                                   --C_Installment_Id);

                If St_Err_Code <> 0 then
			--ROLLBACK;
                        --RAISE FND_API.G_EXC_ERROR;
			Raise NO_PROCESSING_OF_AWARD ;
                End If;


END IF ;    -- end if for  %%%%%%%   , bug 5026657

END LOOP ;  -- dummy loop of re-processing , bug 5026657

 X_Installment_total.delete ; -- initalize installment_amount table for new installment
 X_Installment_tab.delete; -- initalize install_tab  for new installment

END LOOP;

 -- Update the expenditures with bill_hold_flag set to Once (before the process) to 'N'

  One_Time_Bill_Hold(X_Project_Id,
		     X_Award_Id,
		     X_Rev_Or_Bill_Date,
		     X_Request_Id,
		     St_Err_Code,
		     St_Err_Buff);

    If St_Err_Code <> 0 then

       --ROLLBACK;
       --RAISE FND_API.G_EXC_ERROR;
	Raise NO_PROCESSING_OF_AWARD ;

    End if;

 END;
 CLOSE GET_INSTALLMENTS;


End;

--9999999999999999999999999999999999999999999

ElsIf  (X_calling_process = 'Revenue' and X_Award_Rev_Distribution_Rule = 'COST') then -- Elsif for Billing_Distribution_Rule Check

 --dbms_output.put_line('Got into New Revenue Process ');

------------------------------------------------------------------
/* Opening the Cursor to Process each Installment of this Award (For REVENUE Processing) */
------------------------------------------------------------------
OPEN GET_INSTALLMENTS;
 BEGIN
   LOOP
    FETCH GET_INSTALLMENTS into
    C_Installment_Id,
    C_Start_Date_Active,
    C_End_Date_Active;
       EXIT WHEN GET_INSTALLMENTS%NOTFOUND;

IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('Revenue Process, In installment loop, installment :'||C_Installment_Id,'C');
END IF;

f_dummy := 0 ; --For Bug 5026657

  -- BUG 3235390 : Deleting data from gms_events_temp_format
  DELETE gms_events_temp_format;

WHILE f_dummy<2 LOOP   /* dummy loop for re-processing , bug 5026657 */

f_dummy := f_dummy + 1;

  IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('Entering dummy loop....f_dummy is '||f_dummy,'C');
END IF;

/* Processing Labor Transactions */
    X_Trx_Type := 'LABOR';

           REVENUE_ACCRUAL(X_Project_Id,
                           X_Award_Id,
                           X_Class_Category,
                           X_rev_or_bill_date,
                           X_Revenue_Limit_Flag,
                           X_request_id,
                           X_Rev_Carrying_Out_Org_Id,
                           X_calling_process,
			   X_Trx_Type,
                           C_Installment_Id,
                           C_Start_Date_Active,
                           C_End_Date_Active,
                           X_Err_Num,
                           X_Err_Stage,
			   f_labor_exp_to_process,  /* Added for bug 5026657 */
			   f_non_labor_neg_exp_processed); /* Added for bug 5026657 */

g_labor_exp_to_process := f_labor_exp_to_process ; /* Added for bug 5026657 */

 /* Processing Non_Labor Transactions */
    X_Trx_Type := 'NON_LABOR';

	   REVENUE_ACCRUAL(X_Project_Id,
                           X_Award_Id,
                           X_Class_Category,
                           X_rev_or_bill_date,
                           X_Revenue_Limit_Flag,
                           X_request_id,
                           X_Rev_Carrying_Out_Org_Id,
                           X_calling_process,
                           X_Trx_Type,
                           C_Installment_Id,
                           C_Start_Date_Active,
                           C_End_Date_Active,
                           X_Err_Num,
                           X_Err_Stage,
			   f_labor_exp_to_process, /* Added for bug 5026657 */
			   f_non_labor_neg_exp_processed); /* Added for bug 5026657 */

g_non_labor_neg_exp_processed := f_non_labor_neg_exp_processed ; /* Added for bug 5026657 */

-- Bug 3235390 : Calling the CREATE_PA_EVENTS procedure to insert records in pa_events
--               gms_event_attribute table from temporary table.

/* Added for bug 5026657 */
IF (g_labor_exp_to_process = 'Y' and g_non_labor_neg_exp_processed = 'Y') THEN
g_process_again := 'Y';
ELSE
g_process_again := 'N';
END IF;

/* Added for bug 5026657 */
IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('f_dummy is '||f_dummy,'C');
        gms_error_pkg.gms_debug('g_process_again is '||g_process_again,'C');
	gms_error_pkg.gms_debug('g_labor_exp_to_process is '||g_labor_exp_to_process,'C');
	gms_error_pkg.gms_debug('g_non_labor_neg_exp_processed is '||g_non_labor_neg_exp_processed,'C');
END IF;

/* Added for bug 5026657 */
IF ( X_Revenue_Limit_Flag = 'N' OR
     ( X_Revenue_Limit_Flag = 'Y' AND g_process_again = 'N' ) ) THEN     -- %%%%%%%

f_dummy := f_dummy + 1;

CREATE_PA_EVENTS (X_project_id          ,
	          X_Calling_Process ,
                  X_rev_or_bill_Date ,
                  X_Rev_Carrying_Out_Org_Id,
                  X_Request_Id ,
                  X_Rev_Installment_total,
		  St_Err_Code,
	          St_Err_Buff );

IF St_Err_Code <> 0 THEN
   raise NO_PROCESSING_OF_AWARD ;
END IF;

/* Moved this here from inside REVENUE_ACCRUAL to club Labor and Nonlabor Burden together */

 DO_BURDEN_EVENT_PROCESSING(X_Project_Id,
                             X_rev_or_bill_Date,
                             X_Calling_Process,
                             X_Rev_Carrying_Out_Org_Id,
                             X_Request_Id,
			     X_Rev_Installment_total,
		             St_Err_Code,
                             St_Err_Buff);

                If St_Err_Code <> 0 then
			Raise NO_PROCESSING_OF_AWARD ;
                End If;

                             --C_Installment_Id

 END IF ;    -- end if for  %%%%%%%   , bug 5026657

 END LOOP ;  -- dummy loop of re-processing , bug 5026657

 X_Rev_Installment_total.delete ; -- initalize installment_amount table for new installment
 X_Rev_Installment_tab.delete; -- initalize install_tab  for new installment

   END LOOP;


 END;
  CLOSE GET_INSTALLMENTS;

End If; -- End If for Billing Distribution Rule Check

--999999999999999999999999999999999999999999

End If; -- End of If for check to see if Award Status is 'ACTIVE' or 'ON_HOLD'


End If;  -- End of If for Project_Type_Flag Check to see if it is 'AWARD_PROJECT'

 -- Null Event Deletion ...
/*******
For bug 4957529
 If X_BURDEN_NULL_EVENT_PROCESSED  OR
    X_REVRAW_NULL_EVENT_PROCESSED  OR
    X_INVRAW_NULL_EVENT_PROCESSED  then

    DELETE_NULL_EVENTS (X_project_id,
		        X_request_id,
			X_Calling_Process,
		        St_Err_Code,
                        St_Err_Buff);

 End if;
****/
 -- Concurrency Control Code  Starts

 Begin

   Delete
   from   gms_concurrency_control
   where  process_name = 'GMS_BLNG'
   and    process_key  = X_project_id;

 Exception

   When Others then
      gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => St_Err_Code,
				X_Err_Buff => St_Err_Buff);
	Raise NO_PROCESSING_OF_AWARD ;

 End;

 -- Concurrency Control Code  Ends

 COMMIT; -- Commit to release locks on award and expenditures

End if;  -- GMS INSTALLATION CHECK

IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('End Award Billing ','C');
END IF;

Exception
 When NO_PROCESSING_OF_AWARD then

 -- ## This exception is declared at the package level
 -- ## This exception is called from many procedures called by AWARD_BILLING
 -- ## It is only handled in this program
 -- ## When this exception is raised, all data for that award_project_id
 -- ## which has been modified or created is rolled back thus ensuring consistency
 -- ## Further processing for that award is ignored.
    -- Added for Bug 1744641: To Generate errors when an exception occurs
    -- during the process of generation of invoice/Revenue.
         If (nvl(GMS_ERROR_PKG.X_Request_Trace_Id,-1)<>X_Request_id) then
         gms_error_pkg.gms_exception_head_proc(x_calling_process) ;
         GMS_ERROR_PKG.X_Request_Trace_Id:=X_request_id;
         End If;
         gms_error_pkg.gms_exception_lines_proc ( 'GMS_UNEXPECTED_ERR_NO_PROCESS' ,
                                                'PRJ',
                                                x_calling_place,
                                                x_project_id ,
                                                x_award_number ,
                                                x_award_name );

         -- End of the code added for bug 1744641
         IF L_DEBUG = 'Y' THEN
         	gms_error_pkg.gms_debug('WHEN NO_PROCESSING_OF_AWARD - AWARD_BILLING','C');
         END IF;
         gms_error_pkg.gms_message('GMS_UNEXPECTED_ERR_NO_PROCESS',
                                'PRJ',
                                X_Project_id,
                                X_Exec_Type => 'C',
                                X_Err_Code => St_Err_Code,
                                X_Err_Buff => St_Err_Buff);

       --  ROLLBACK; -- If record not found , rollback to release lock --For Bug 4243374
	 ROLLBACK to AWARD_BILLING_BEGIN; -- If record not found , rollback to release lock
         /* Rollback to Savepoint introduced instead of Rollback for bug 4243374 */
         RETURN;

  When AWARD_DATA_LOCKED then

 -- ## This exception is declared at the package level
 -- ## This exception happens when Awards form is modifying billing related data
 -- ## for the Award being processed.
 -- ## When this exception is raised, all data for that award_project_id
 -- ## which has been modified or created is rolled back thus ensuring consistency
 -- ## Further processing for that award is ignored.
         -- Added for Bug 1744641: To Generate errors when an exception occurs
         -- during the process of generation of invoice/Revenue.
	 If (nvl(GMS_ERROR_PKG.X_Request_Trace_Id,-1)<>X_Request_id) then
         gms_error_pkg.gms_exception_head_proc(x_calling_process) ;
         GMS_ERROR_PKG.X_Request_Trace_Id:=X_request_id;
        End If;
         gms_error_pkg.gms_exception_lines_proc( 'GMS_BILL_AWARD_LOCK' ,
                                                'PROJECT_ID',
                                                x_calling_place ,
                                                x_project_id ,
                                                x_award_number ,
                                                x_award_name );
         gms_error_pkg.gms_exception_lines_proc( 'GMS_UNEXPECTED_ERR_NO_PROCESS' ,
                                                'PRJ',
                                                x_calling_place,
                                                x_project_id );
 	  -- End of the code added for bug 1744641
         IF L_DEBUG = 'Y' THEN
         	gms_error_pkg.gms_debug('WHEN AWARD_DATA_LOCKED - AWARD_BILLING','C');
         END IF;
         gms_error_pkg.gms_message('GMS_BILL_AWARD_LOCK',
                                'PROJECT_ID',
                                X_Project_id,
                                X_Exec_Type => 'C',
                                X_Err_Code => St_Err_Code,
                                X_Err_Buff => St_Err_Buff);

         gms_error_pkg.gms_message('GMS_UNEXPECTED_ERR_NO_PROCESS',
                                'PRJ',
                                X_Project_id,
                                X_Exec_Type => 'C',
                                X_Err_Code => St_Err_Code,
                                X_Err_Buff => St_Err_Buff);
         ROLLBACK; -- If record not found , rollback to release lock
         RETURN;

 When ROLLBACK_FAILURE then

 	 -- Added for Bug 1744641: To Generate errors when an exception occurs
         -- during the process of generation of invoice/Revenue.
        If (nvl(GMS_ERROR_PKG.X_Request_Trace_Id,-1)<>X_Request_id) then
         gms_error_pkg.gms_exception_head_proc(x_calling_process) ;
         GMS_ERROR_PKG.X_Request_Trace_Id:=X_request_id;
        End If;
        gms_error_pkg.gms_exception_lines_proc('GMS_BILLING_ROLLBACK_FAILURE' ,
                                                'PRJ',
                                                x_calling_place,
                                                x_project_id ,
                                                x_award_number ,
                                                x_award_name);
         -- End of code added for bug 1744641.
         IF L_DEBUG = 'Y' THEN
         	gms_error_pkg.gms_debug('WHEN ROLLBACK_FAILURE  - AWARD_BILLING','C');
         END IF;
         rollback; -- release lock and any changes carried out.
         RETURN;

       --RAISE_APPLICATION_ERROR(-20558,St_Err_Buff);

 When NO_EXP_TO_PROCESS then

 -- This exception is raised when there are no transactions to be processed
 -- Billing rollback happens before this in which transactions may have been
 -- processed, so unlike all other exceptions, in this exception, we do the following:
 -- 1. Delete concurrency control record.
 -- 2. COMMIT
 -- 3. RETURN

   Delete
   from   gms_concurrency_control
   where  process_name = 'GMS_BLNG'
   and    process_key  = X_project_id;

   COMMIT;

   RETURN;

 When INVALID_INVOICE_FORMAT then

 -- ## This exception is declared at the package level
 -- ## This exception happens when Awards form has an invoice format (labor or
 -- ## non-labor) that has an element not supported by Grants.
 -- ## Refer to Grants userguide Chapter 28 for valid formats (columns that can be used)
 -- ## When this exception is raised, all data for that award_project_id
 -- ## which has been modified or created is rolled back thus ensuring consistency
 -- ## Further processing for that award is ignored.
 -- Added for Bug 3143102: QI LABOR/NON-LABOR INVOICE FORMATS NOT SUPPORTED BY GMS

	 If (nvl(GMS_ERROR_PKG.X_Request_Trace_Id,-1)<>X_Request_id) then
         gms_error_pkg.gms_exception_head_proc(x_calling_process) ;
         GMS_ERROR_PKG.X_Request_Trace_Id:=X_request_id;
        End If;
         gms_error_pkg.gms_exception_lines_proc('GMS_INVALID_INVOICE_FORMAT' ,
                                                NULL,
                                                x_calling_place ,
                                                x_project_id ,
                                                x_award_number ,
                                                x_award_name );

         IF L_DEBUG = 'Y' THEN
         	gms_error_pkg.gms_debug('WHEN INVALID INVOICE FORMAT - AWARD_BILLING','C');
         END IF;
         gms_error_pkg.gms_message('GMS_INVALID_INVOICE_FORMAT',
                                X_Exec_Type => 'C',
                                X_Err_Code => St_Err_Code,
                                X_Err_Buff => St_Err_Buff);

         ROLLBACK; -- If record not found , rollback to release lock

            Delete
            from   gms_concurrency_control
            where  process_name = 'GMS_BLNG'
            and    process_key  = X_project_id;
         COMMIT;

         RETURN;
--Added for bug 4506225
When GMS_TAX_FAILURE then
 -- ## This exception is declared at the package level
 -- ## This exception is raised when the call to GMS_TAX in procedure award_billing
 -- ## returns a non zero value.One possible cause for GMS_TAX to return a non_zero
 -- ## value is an inactive award sponsor.
 -- ## Added for bug 4243374.
         If (nvl(GMS_ERROR_PKG.X_Request_Trace_Id,-1)<>X_Request_id) then
         gms_error_pkg.gms_exception_head_proc(x_calling_process) ;
         GMS_ERROR_PKG.X_Request_Trace_Id:=X_request_id;
         End If;
         gms_error_pkg.gms_exception_lines_proc ( 'GMS_UNEXPECTED_ERR_NO_PROCESS' ,
                                                'PRJ',
                                                x_calling_place,
                                                x_project_id ,
                                                x_award_number ,
                                                x_award_name );

         IF L_DEBUG = 'Y' THEN
                gms_error_pkg.gms_debug('WHEN GMS_TAX_FAILURE - AWARD_BILLING','C');
         END IF;
         gms_error_pkg.gms_message('GMS_UNEXPECTED_ERR_NO_PROCESS',
                                'PRJ',
                                X_Project_id,
                                X_Exec_Type => 'C',
                                X_Err_Code => St_Err_Code,
                                X_Err_Buff => St_Err_Buff);

       Delete
        from   gms_concurrency_control
        where  process_name = 'GMS_BLNG'
        and    process_key  = X_project_id;

        return;

--End of bug fix 4506225
 When Others then
 	-- Added for Bug 1744641: To Generate errors when an exception occurs
        -- during the process of generation of invoice/Revenue.
       If (nvl(GMS_ERROR_PKG.X_Request_Trace_Id,-1)<>X_Request_id) then
         gms_error_pkg.gms_exception_head_proc(x_calling_process) ;
         GMS_ERROR_PKG.X_Request_Trace_Id:=X_request_id;
        End If;
        gms_error_pkg.gms_exception_lines_proc('GMS_UNEXPECTED_ERROR',
                                               'PRJ',
                                               x_calling_place,
                                               x_project_id ,
                                               x_award_number ,
                                               x_award_name,
                                               SQLCODE,
                                               SQLERRM  );
	gms_error_pkg.gms_exception_lines_proc('GMS_UNEXPECTED_ERR_NO_PROCESS' ,
                                               'PRJ',
                                               x_calling_place ,
                                               x_project_id
                                               );
      --End of Code added for bug 1744641
      IF L_DEBUG = 'Y' THEN
      	gms_error_pkg.gms_debug('WHEN OTHERS - AWARD_BILLING','C');
      END IF;
      gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
                                'SQLCODE',
                                SQLCODE,
                                'SQLERRM',
                                SQLERRM,
                                X_Exec_Type => 'C',
                                X_Err_Code => St_Err_Code,
                                X_Err_Buff => St_Err_Buff);

      gms_error_pkg.gms_message('GMS_UNEXPECTED_ERR_NO_PROCESS',
                                'PRJ',
                                X_Project_id,
                                X_Exec_Type => 'C',
                                X_Err_Code => St_Err_Code,
                                X_Err_Buff => St_Err_Buff);


         rollback; -- release lock and any changes carried out.
         RETURN;

      --RAISE_APPLICATION_ERROR(-20557,St_Err_Buff);

End AWARD_BILLING;

END GMS_BILLING;

/
