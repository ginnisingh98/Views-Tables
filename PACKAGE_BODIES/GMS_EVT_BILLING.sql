--------------------------------------------------------
--  DDL for Package Body GMS_EVT_BILLING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_EVT_BILLING" AS
-- $Header: gmsinmab.pls 120.1 2005/07/26 14:35:46 appldev ship $


NO_PROCESSING_OF_AWARD Exception;
-- ## This exception is handled in the main procedure MANUAL_BILLING
-- ## but this exception is called from procedures which are called within MANUAL_BILLING

Procedure  GET_EVENT_INFO(X_Project_Id                 IN    NUMBER,
                          X_Event_Num                  IN    NUMBER,
                          X_Event_Type                 OUT NOCOPY   VARCHAR2,
                          X_Event_Type_Classification  OUT NOCOPY   VARCHAR2,
                          X_Installment_Id             OUT NOCOPY   VARCHAR2,
                          X_Actual_Project_Id          OUT NOCOPY   NUMBER,
                          X_Actual_Task_Id             OUT NOCOPY   NUMBER) IS
X_Err_Code Number;
X_Err_buff Varchar2(2000);

Begin

-- For 11.5, event information is being picked from gms_events_v view

 Select distinct
 a.event_type,
 b.event_type_classification,
 a.installment_id,
 a.actual_project_id,
 a.actual_task_id
 into
 X_Event_Type,
 X_Event_Type_Classification,
 X_Installment_Id,
 X_Actual_Project_Id,
 X_Actual_Task_Id
 from
 gms_events_v a,
 pa_event_types b
 where
 a.project_id  = X_Project_Id and
 a.event_num   = X_Event_Num  and
 a.event_type  = b.event_type
;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
      gms_error_pkg.gms_message('GMS_NO_DATA_PRJ_EVT',
			        'EVT',
			        X_Event_Num,
			        'PRJ',
			        X_Project_Id,
			        X_Exec_Type => 'C',
			        X_Err_Code => X_Err_Code,
			        X_Err_Buff => X_Err_Buff);
      --RAISE_APPLICATION_ERROR(-20110,X_Err_Buff);

        RAISE NO_PROCESSING_OF_AWARD;

  WHEN TOO_MANY_ROWS THEN
      gms_error_pkg.gms_message('GMS_TOO_MANY_ROWS_PRJ_EVT',
			        'PRJ',
				X_Project_Id,
				'EVT',
				X_Event_Num,
				X_Exec_Type =>'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      --RAISE_APPLICATION_ERROR(-20111,X_Err_Buff);

        RAISE NO_PROCESSING_OF_AWARD;

End GET_EVENT_INFO;

Procedure GET_CURR_BILLED_AMOUNT(X_calling_process   IN VARCHAR2,
                                 X_Actual_Project_Id IN NUMBER,
                                 X_Actual_Task_Id    IN NUMBER,
                                 X_Installment_Id    IN NUMBER,
                                 X_BillRev_Amount     OUT NOCOPY NUMBER) IS
X_Err_Code Number;
X_Err_buff Varchar2(2000);

Begin

 Select
 decode(X_calling_process,'Invoice',nvl(gmf.total_billed_amount,0),'Revenue',nvl(gmf.total_revenue_amount,0),NULL)
 into
 X_BillRev_Amount
 from
 GMS_SUMMARY_PROJECT_FUNDINGS gmf
 where
    gmf.project_id           = X_Actual_Project_Id
and
 (
    (gmf.task_id IS NULL)
 or (gmf.task_Id  = X_Actual_Task_Id)
 or (gmf.task_id = (select top_task_id from pa_tasks where task_id = X_Actual_Task_Id))
 )
 and installment_id       = X_Installment_Id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      gms_error_pkg.gms_message('GMS_NO_DATA_PRJ_TASK_INST',
				'PRJ',
				X_Actual_Project_Id,
				'TASK',
				X_Actual_Task_Id,
				'INST',
				X_Installment_Id,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      --RAISE_APPLICATION_ERROR(-20112,X_Err_Buff);
      RAISE NO_PROCESSING_OF_AWARD;

End GET_CURR_BILLED_AMOUNT;

Procedure UPDATE_GMS_SUMMARY_FUNDING(X_calling_process   IN VARCHAR2,
                                     X_Actual_Project_Id IN NUMBER,
          			     X_Actual_Task_Id    IN NUMBER,
 				     X_Installment_Id    IN NUMBER,
                                     X_Bill_Rev_Amount   IN NUMBER) IS
X_Curr_BillRev_Amount    NUMBER;
X_Total_BillRev_Amount NUMBER;

X_Err_Code Number;
X_Err_buff Varchar2(2000);

Begin

  GET_CURR_BILLED_AMOUNT(X_calling_process,
                         X_Actual_Project_Id,
                         X_Actual_Task_Id,
                         X_Installment_Id,
                         X_Curr_BillRev_Amount);

   X_Total_BillRev_Amount := X_Bill_Rev_Amount + X_Curr_BillRev_Amount;

If X_calling_process = 'Invoice' then

 Update GMS_SUMMARY_PROJECT_FUNDINGS gmf
 set
 gmf.total_billed_amount = X_Total_BillRev_Amount
 ,gmf.last_update_date = sysdate
 ,gmf.last_updated_by  = fnd_global.user_id
 ,gmf.last_update_login = fnd_global.login_id
 where
    gmf.project_id   = X_Actual_Project_Id
and
 (
   (gmf.task_id IS NULL)
 or(gmf.task_id = X_Actual_Task_Id)
 or(gmf.task_id = (select top_task_id from pa_tasks where task_id = X_Actual_Task_Id))
 )
 and
 installment_id  = X_Installment_Id;

Elsif X_calling_process = 'Revenue' then

 Update GMS_SUMMARY_PROJECT_FUNDINGS gmf
 set
 gmf.total_revenue_amount = X_Total_BillRev_Amount
 ,gmf.last_update_date = sysdate
 ,gmf.last_updated_by  = fnd_global.user_id
 ,gmf.last_update_login = fnd_global.login_id
 where
    gmf.project_id   = X_Actual_Project_Id
and
 (
   (gmf.task_id IS NULL)
 or(gmf.task_id = X_Actual_Task_Id)
 or(gmf.task_id = (select top_task_id from pa_tasks where task_id = X_Actual_Task_Id))
 )
 and
 installment_id  = X_Installment_Id;

End If;
   IF SQL%NOTFOUND then
      gms_error_pkg.gms_message('GMS_NO_UPD_PRJ_TASK_INST',
				'PRJ',
				X_Actual_Project_Id,
				'TASK',
				X_Actual_Task_Id,
				'INST',
				X_Installment_Id,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      --RAISE_APPLICATION_ERROR(-20113,X_Err_Buff);
	RAISE NO_PROCESSING_OF_AWARD;
   End IF;

End UPDATE_GMS_SUMMARY_FUNDING;

PROCEDURE MANUAL_BILLING( X_project_id IN NUMBER,
                                X_top_Task_id IN NUMBER DEFAULT NULL,
                                X_calling_process IN VARCHAR2 DEFAULT NULL,
                                X_calling_place IN VARCHAR2 DEFAULT NULL,
                                X_amount IN NUMBER DEFAULT NULL,
                                X_percentage IN NUMBER DEFAULT NULL,
                                X_rev_or_bill_date IN DATE DEFAULT NULL,
                                X_bill_extn_assignment_id IN NUMBER DEFAULT NULL,
                                X_bill_extension_id IN NUMBER DEFAULT NULL,
                                X_request_id IN NUMBER DEFAULT NULL) IS

/*------------------------------------------------------------------*/

CURSOR GET_INVOICES IS
Select
draft_invoice_num
from
pa_draft_invoices
where
project_id         = X_project_id and
request_id         = X_request_id;

  F_Draft_Invoice_Num  NUMBER;

CURSOR GET_INVOICE_ITEMS IS
Select
line_num,
event_num,
amount
from
pa_draft_invoice_items
where
project_id          = X_project_id and
draft_invoice_num   = F_Draft_Invoice_Num;
  F_Line_Num     NUMBER;
  F_Event_Num    NUMBER;
  F_Bill_Amount  NUMBER;

/*--------------------------------------------------------------------*/

CURSOR GET_REVENUES IS
Select
draft_revenue_num
from
pa_draft_revenues
where project_id  = X_project_id and
request_id        = X_request_id;

  F_Draft_Revenue_Num  NUMBER;

CURSOR GET_REV_ITEMS_RDL IS
Select
ri.project_id,
ri.line_num,
rdl.event_num,
ri.amount
from
pa_draft_revenue_items ri,
pa_cust_event_rdl_all  rdl
where
ri.draft_revenue_num                 = F_Draft_Revenue_Num  and
ri.project_id                        = X_project_Id         and
rdl.draft_revenue_num                = ri.draft_revenue_num and
rdl.draft_revenue_item_line_num      = ri.line_num          and
rdl.project_id                       = ri.project_id ;

 F_Award_Project_Id        NUMBER;
 F_Rev_Line_Num            NUMBER;
 F_Rev_Event_Num           NUMBER;
 F_Rev_Amount              NUMBER;

/*----------------------------------------------------------------------*/

X_Event_Type                 VARCHAR2(30);
X_Event_Type_Classification  VARCHAR2(30);
X_Installment_Id             NUMBER(15);
X_Actual_Project_Id          NUMBER(15);
X_Actual_Task_Id             NUMBER(15);
X_Sponsored_Type_Flag        VARCHAR2(1);

X_Project_Type		     VARCHAR2(30);

X_Award_Rev_Distribution_Rule  VARCHAR2(30);
X_Award_Bill_Distribution_Rule VARCHAR2(30);

X_Err_Code Number;
X_Err_buff Varchar2(2000);

X_Stage Number(3);

Begin

   gms_error_pkg.set_debug_context; -- Added for Bug: 2510024

   SAVEPOINT MANUAL_BILLING_SAVEPOINT;

  /* CHECK IF GMS_INSTALLATION HAS BEEN CARRIED OUT NOCOPY */

  If gms_install.enabled then

 X_Stage := 10;

  /* Checking the Sponsored Flag on the Project Type */
  /* -- This checking is supposed to be for the Actual Projects on the Exp Items
     -- not for Award Projects !!! Mistake.
    Begin
    select
     nvl(pt.attribute1,'N')--Sponsored Flag
     into
     X_Sponsored_Type_Flag
     from
     PA_PROJECTS_ALL p,
     PA_PROJECT_TYPES pt
     where
     p.project_id   = X_Project_Id
     and p.project_type = pt.project_type;
   End;
  */

/* Getting the PROJECT_TYPE. GO Through Extension only if PROJECT_TYPE is
   'AWARD_PROJECT'
*/
    Begin
    select
     project_type
     into
     X_Project_Type
     from
     PA_PROJECTS_ALL
     where project_id = X_Project_Id;
    End;

X_Stage := 20;

  /* Checking the Revenue and Billing Distribution Rule on the Award */
  Begin
    select
      Revenue_Distribution_Rule,
      Billing_Distribution_Rule
    into
      X_Award_Rev_Distribution_Rule,
      X_Award_Bill_Distribution_Rule
    from
    GMS_AWARDS
    where
      Award_Project_Id = X_Project_Id;
  End;

If X_Project_Type = 'AWARD_PROJECT' then

/*-------------------------------------------------------------------------------------*/

  IF (X_calling_process = 'Invoice' and X_Award_Bill_Distribution_Rule = 'EVENT') then

  open GET_INVOICES;
   LOOP
    FETCH GET_INVOICES
    into
    F_Draft_Invoice_Num;


       EXIT WHEN GET_INVOICES%NOTFOUND;

     open GET_INVOICE_ITEMS;
      LOOP
        FETCH GET_INVOICE_ITEMS
        into
        F_Line_Num,
        F_Event_Num,
        F_Bill_Amount;


            EXIT WHEN GET_INVOICE_ITEMS%NOTFOUND;

           GET_EVENT_INFO(X_Project_Id,
                          F_Event_Num,
                          X_Event_Type,
                          X_Event_Type_Classification,
                          X_Installment_Id,
                          X_Actual_Project_Id,
                          X_Actual_Task_Id);

               If X_Event_Type_Classification = 'MANUAL' then

                  UPDATE_GMS_SUMMARY_FUNDING(X_calling_process,
                                             X_Actual_Project_Id,
                                             X_Actual_Task_Id,
                                             X_Installment_Id,
                                             F_Bill_Amount);
               End If;
      END LOOP;
         close GET_INVOICE_ITEMS;
   End LOOP;
         close GET_INVOICES;
  End If; -- End If for Billing Distribution Rule Check

/*----------------------------------------------------------------------------------------*/
  If    (X_calling_process = 'Revenue' and X_Award_Rev_Distribution_Rule = 'EVENT') then

     open GET_REVENUES;

      LOOP
      FETCH GET_REVENUES into
      F_Draft_Revenue_Num;

         EXIT WHEN GET_REVENUES%NOTFOUND;

       /* Get Revenue RDLS and corresponding Event Information */
       open GET_REV_ITEMS_RDL;

       LOOP
       FETCH GET_REV_ITEMS_RDL
       into
       F_Award_Project_Id,
       F_Rev_Line_Num,
       F_Rev_Event_Num,
       F_Rev_Amount;
            EXIT WHEN GET_REV_ITEMS_RDL%NOTFOUND;

                 GET_EVENT_INFO(F_Award_Project_Id,
                                F_Rev_Event_Num,
                                X_Event_Type,
                                X_Event_Type_Classification,
                                X_Installment_Id,
                                X_Actual_Project_Id,
                                X_Actual_Task_Id);


               If X_Event_Type_Classification = 'MANUAL' then

                  UPDATE_GMS_SUMMARY_FUNDING(X_calling_process,
                                             X_Actual_Project_Id,
                                             X_Actual_Task_Id,
                                             X_Installment_Id,
                                             F_Rev_Amount);
               End If;


       End LOOP; --End of LOOP for GET_REVENUE_ITEMS_RDL
           close GET_REV_ITEMS_RDL;

     End LOOP;
       close GET_REVENUES;

  End If; -- End If for Revenue Distribution Rule Check

/*----------------------------------------------------------------------------------------*/
End If; -- End If for PROJECT_TYPE Check

 End if;  -- GMS_INSTALLATION CHECK

Exception

  WHEN NO_DATA_FOUND THEN

      gms_error_pkg.gms_message('GMS_NO_DATA_PRJ_AT_STAGE',
				'PRJ',
				X_Project_Id,
				'STAGE',
				X_Stage,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      --RAISE_APPLICATION_ERROR(-20114,X_Err_Buff);
        ROLLBACK TO MANUAL_BILLING_SAVEPOINT;
	RETURN;

 When NO_PROCESSING_OF_AWARD then

 -- ## This exception is declared at the package level
 -- ## This exception is called from many procedures called by MANUAL_BILLING
 -- ## It is only handled in this program
 -- ## When this exception is raised, all data for that award_project_id
 -- ## which has been modified or created is rolled back thus ensuring consistency
 -- ## Further processing for that award is ignored.

         gms_error_pkg.gms_message('GMS_UNEXPECTED_ERR_NO_PROCESS',
                                'PRJ',
                                X_Project_id,
                                X_Exec_Type => 'C',
                                X_Err_Code => X_Err_Code,
                                X_Err_Buff => X_Err_Buff);
         ROLLBACK TO MANUAL_BILLING_SAVEPOINT;
         RETURN;

End MANUAL_BILLING;
End GMS_EVT_BILLING;

/
