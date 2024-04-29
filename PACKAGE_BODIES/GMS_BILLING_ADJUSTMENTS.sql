--------------------------------------------------------
--  DDL for Package Body GMS_BILLING_ADJUSTMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_BILLING_ADJUSTMENTS" AS
-- $Header: gmsinadb.pls 120.3 2006/03/23 20:42:31 appldev ship $

-- To check on, whether to print debug messages in log file or not
L_DEBUG varchar2(1) := NVL(FND_PROFILE.value('GMS_ENABLE_DEBUG_MODE'), 'N');

-- Variable set in procedure wriinv and used in procedure write_off_creation
g_request_id number;

-- Procedure HANDLE_NET_ZERO_EVENTS
-- Procedure added for: 4594090
PROCEDURE HANDLE_NET_ZERO_EVENTS (P_AWARD_PROJECT_ID IN NUMBER,
                                  P_REQUEST_ID       IN NUMBER,
                                  P_CALLING_PROCESS  IN VARCHAR2)
IS
Cursor c_gspf_update is
       select gea.installment_id,
              gea.actual_project_id,
              gea.actual_task_id,
              pt.top_task_id,
              sum(gea.bill_amount) billed_amount -- null handling not reqd.
       from   gms_event_attribute gea,
              pa_tasks            pt
       where  gea.project_id            = P_AWARD_PROJECT_ID
       and    gea.event_num  in ( -1,-2)
       and    gea.request_id            = P_REQUEST_ID
       and    gea.event_calling_process = 'Invoice'
       and    pt.task_id                = gea.actual_task_id
       group by gea.installment_id,
                gea.actual_project_id,
                gea.actual_task_id,
                pt.top_task_id;
BEGIN

 -- A. Update gms_summary_project_fundings ....
 --    This is required for Invoice only as invoice events can
 --    span across tasks. Revenue is always grouped by tasks ..

If p_calling_process = 'INVOICE' then

   for x in c_gspf_update loop
       Update gms_summary_project_fundings gspf
       set    gspf.total_billed_amount = nvl(gspf.total_billed_amount,0) -
                                         x.billed_amount
       where  gspf.installment_id = x.installment_id
       and    gspf.project_id     = x.actual_project_id
       and    (gspf.task_id is NULL or
               gspf.task_id = x.actual_task_id or
               gspf.task_id = x.top_task_id);
   end loop;

End If;

 -- B. Update ADL Flag ..
  Update gms_award_distributions adl
  set    adl.billed_flag              = decode(p_calling_process,'REVENUE',
                                               adl.billed_flag,'N'),
         adl.revenue_distributed_flag = decode(p_calling_process,'INVOICE',
                                               adl.revenue_distributed_flag,'N')
  where (expenditure_item_id,adl_line_num) in
         (select expenditure_item_id,adl_line_num
          from   gms_event_intersect
          where  award_project_id = p_award_project_id
          and    request_id       = p_request_id
          and    event_type       = p_calling_process
	  and event_num = -1    /*Added for bug 5060427*/
          UNION ALL
          select expenditure_item_id,adl_line_num
          -- from   gms_event_intersect  /* Commented for bug 5060427 */
          from  gms_burden_components /*Added for bug 5060427*/
          where  award_project_id = p_award_project_id
          and    request_id       = p_request_id
          and    event_type       = p_calling_process
	  and event_num = -2    /*Added for bug 5060427*/ )
  and    document_type  = 'EXP'
  and    adl_status     = 'A';

 IF SQL%ROWCOUNT > 0 then
   -- there are some records to process ..
  -- C. Delete gei
  Delete from gms_event_intersect
  where  award_project_id = p_award_project_id
  and    event_num        = -1
  and    request_id       = p_request_id
  and    event_type       = p_calling_process;

  -- D. Delete gbc
  Delete from gms_burden_components
  where  award_project_id = p_award_project_id
  and    event_num        = -2
  and    request_id       = p_request_id
  and    event_type       = p_calling_process;

  -- E. Delete gea
  Delete from gms_event_attribute
  where  project_id            = p_award_project_id
  and    event_num             in ( -1,-2)
  and    request_id            = p_request_id
  and    event_calling_process = INITCAP(p_calling_process);
 END IF;
END HANDLE_NET_ZERO_EVENTS;


-- PROCEDURE INSERT_BILL_CANCEL, new procedure to account for deleted revenue items in ASI

PROCEDURE INSERT_BILL_CANCEL(X_Award_Project_Id    IN NUMBER,
			     X_Event_Num 	   IN NUMBER,
			     X_Expenditure_item_id IN NUMBER DEFAULT null,
			     X_Adl_Line_No	   IN NUMBER DEFAULT null,
			     X_Bill_Amount	   IN NUMBER,
			     X_Calling_Process	   IN VARCHAR2,
			     X_Burden_Exp_Type     IN VARCHAR2 DEFAULT null,
			     X_Burden_Cost_Code    IN VARCHAR2 DEFAULT null,
			     X_Creation_Date	   IN DATE,
			     X_Actual_Project_Id   IN NUMBER,
			     X_Actual_Task_Id      IN NUMBER,
			     X_Expenditure_Org_Id  IN NUMBER,
			     X_Deletion_Date       IN DATE,
			     X_Resource_List_Member_Id IN NUMBER DEFAULT null,
			     X_Err_Code            IN OUT NOCOPY NUMBER,
			     X_Err_Buff           IN OUT NOCOPY VARCHAR2) IS

Begin
	/* Inserting into gms_billing_cancellations table */

   INSERT INTO GMS_BILLING_CANCELLATIONS (AWARD_PROJECT_ID,
                                           EVENT_NUM,
                                           EXPENDITURE_ITEM_ID,
                                           ADL_LINE_NUM,
                                           BILL_AMOUNT,
                                           CALLING_PROCESS,
                                           BURDEN_EXP_TYPE,
                                           BURDEN_COST_CODE,
                                           CREATION_DATE,
                                           ACTUAL_PROJECT_ID,
                                           ACTUAL_TASK_ID,
                                           EXPENDITURE_ORG_ID,
                                           DELETION_DATE,
                                           RESOURCE_LIST_MEMBER_ID)
                                         VALUES(X_Award_Project_Id,
                                            	X_Event_Num,
                                            	X_Expenditure_item_id,
                                            	X_Adl_Line_No,
                                            	X_Bill_Amount,
                                            	X_Calling_Process,
                                            	X_Burden_Exp_Type,
                                            	X_Burden_Cost_Code,
                                            	X_Creation_Date,
                                            	X_Actual_Project_Id,
                                            	X_Actual_Task_Id,
                                                X_Expenditure_Org_Id,
                                            	X_Deletion_Date,
                                            	X_Resource_List_Member_Id
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
      RAISE_APPLICATION_ERROR(-20200,X_Err_Buff);
End INSERT_BILL_CANCEL;


-- PROCEDURE UPD_GMS_SUMMARY_PRJ_FUNDS, new procedure for project funding table updation for write_off

PROCEDURE UPD_GMS_SUMMARY_PRJ_FUNDS(X_Actual_Project_Id IN NUMBER,
                                    X_Actual_Task_Id    IN NUMBER,
                                    X_Installment_id    IN NUMBER,
                                    X_Amount            IN NUMBER,
                                    X_Process           IN VARCHAR2,
                                    X_Err_Code          IN OUT NOCOPY NUMBER,
                                    X_Err_Buff          IN OUT NOCOPY VARCHAR2) IS
Begin

  /* Write_off Deletion/Cancellation */

  If X_Process = 'WRITE_OFF_DEL' then

      Update gms_summary_project_fundings
      set    total_billed_amount = total_billed_amount + X_Amount
      where  project_id = X_Actual_Project_Id
      and    (task_id is null
              or task_id    = X_Actual_Task_id
              or task_id    = (select top_task_id from pa_tasks where task_id = X_Actual_Task_id) -- Bug 2369179,Added
             )
      and    installment_id = X_Installment_id;

  /* Write_off Creation */

  ElsIf X_Process = 'WRITE_OFF_GEN' then

     Update gms_summary_project_fundings
     set    total_billed_amount = total_billed_amount - X_Amount
     where  project_id = X_Actual_Project_Id
      and    (task_id is null
              or task_id    = X_Actual_Task_id
              or task_id    = (select top_task_id from pa_tasks where task_id = X_Actual_Task_id)  -- Bug 2369179,Added
             )
     and    installment_id = X_Installment_id;

  End if;

      If SQL%NOTFOUND THEN

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
      RAISE_APPLICATION_ERROR(-20201,X_Err_Buff);
      Else
        X_Err_Code := 0;
      End If;

End UPD_GMS_SUMMARY_PRJ_FUNDS;

-- PROCEDURE WRITE_OFF_CREATION, new procedure for write_off creation
PROCEDURE WRITE_OFF_CREATION(X_Award_Project_Id   IN NUMBER,
                             X_Action             IN VARCHAR2,
                             X_Err_Code           IN OUT NOCOPY NUMBER,
                             X_Err_Buff           IN OUT NOCOPY VARCHAR2) IS
Cursor c_invoice_lines is
       select pdii.event_num event_num,
              -1*pdii.amount    amount
       from   pa_draft_invoice_items pdii,
              pa_draft_invoices      pdi
       where  pdi.project_id         = X_Award_Project_Id
       and    pdi.request_id         = g_request_id
       and    pdii.project_id        = pdi.project_id
       and    pdii.draft_invoice_num = pdi.draft_invoice_num
       and    (nvl(pdi.write_off_flag,'N') = 'Y' OR nvl(pdi.concession_flag,'N') = 'Y');

Cursor c_event_attribute(p_award_project_id in number,
                         p_event_num        in number) is
       select gea.installment_id,
 		      gea.actual_Project_Id,
		      gea.Actual_Task_id,
              gea.bill_amount,
              gea.rowid
       from   gms_event_attribute gea
       where  gea.project_id = p_award_project_id
       and    gea.event_num  = p_event_num;

F_Total_Bill_Amt     gms_event_attribute.bill_amount%type :=0;
F_prorate_amt        gms_event_attribute.bill_amount%type :=0;
F_Amount_written_off gms_event_attribute.bill_amount%type :=0;

F_Event_Count        Number := 0;
F_Counter            Number := 0;
F_Stage              VARCHAR2(25);

BEGIN
 X_Err_Code := 0;
 F_Stage := 'Set currency info';
 pa_currency.set_currency_info; --For Bug 2895874

 For invoice_line in c_invoice_lines
 Loop
      F_Stage := 'Get Total Event Inv Amt';
      select sum(bill_amount),count(*)
      into   F_Total_Bill_Amt,F_Event_Count
      from   gms_event_attribute
      where  project_id = X_award_project_id
      and    event_num  = Invoice_line.event_num;

      F_Stage := 'Main Processing';
      for event_attribute in  c_event_attribute(X_award_project_id,
                                                invoice_line.event_num)
      Loop -- event attribute loop

        -- 1. Calculate Prorate Amt.
        -- If .. end if required for Rounding ( Bug 2895874)
        If F_Counter = F_Event_count - 1 then

 	       F_Prorate_Amt := invoice_line.amount - F_Amount_written_off;
           -- Prorate amt is the remaining line amount ..

        Else
          -- Formula:
          -- Prorate Amt  = ((Event attribute bill amount) * (Invoice line amount))
          --                 ------------------------------------------------------
          --                       ( Total Event attribute amount for the event )

           F_prorate_amt := (event_attribute.bill_amount * invoice_line.amount)/F_Total_Bill_Amt;
           F_prorate_amt :=  pa_currency.round_currency_amt(F_prorate_amt);

           F_Amount_written_off := F_Amount_written_off + F_prorate_amt;

        End If;

        -- 2. Update gea
        Begin
           Update gms_event_attribute
           set    bill_amount      = bill_amount -  F_prorate_amt,
                  write_off_amount = nvl(write_off_amount,0) + F_prorate_amt
           where  rowid            = event_attribute.rowid;

           If SQL%NOTFOUND THEN
              gms_error_pkg.gms_message('GMS_NO_UPD_PRJ_EVT_INST',
				'PRJ',
				X_Award_Project_Id,
				'EVT',
				Invoice_line.event_num,
				'INST',
				event_attribute.Installment_Id,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      	     RAISE_APPLICATION_ERROR(-20203,X_Err_Buff);
           Else
             X_Err_Code := 0;
          End If;
        End;

        -- 3. Update gspf:

          /* Update gms_summary_project_fundings */

         UPD_GMS_SUMMARY_PRJ_FUNDS(event_attribute.Actual_project_id,
                                   event_attribute.Actual_Task_id,
                                   event_attribute.Installment_Id,
                                   F_prorate_amt,
                                   'WRITE_OFF_GEN',
                                   X_Err_Code,
                                   X_Err_Buff);

         If X_Err_Code <> 0 then
            RAISE FND_API.G_EXC_ERROR;
         End If;

         -- 4. Re initialize variables
         F_Counter           := F_Counter + 1;

     End Loop;  -- event attribute loop

      -- Re initialize variables for next event ..
         F_Total_Bill_Amt    := 0;
         F_Counter           := 0;
         F_Event_Count       := 0;
         F_Amount_written_off:= 0;
         F_Prorate_amt       :=0;

 End loop;

EXCEPTION
  WHEN OTHERS THEN
      gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				F_Stage||SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      RAISE_APPLICATION_ERROR(-20204,X_Err_Buff);
END WRITE_OFF_CREATION;

-- PROCEDURE WRITE_OFF_DELETION, new procedure for write_off invoice deletions/cancellations

PROCEDURE WRITE_OFF_DELETION(X_Award_Project_Id   IN NUMBER,
			     X_Draft_Invoice_Num  IN NUMBER,
			     X_Err_Code		  IN OUT NOCOPY NUMBER,
			     X_Err_Buff		  IN OUT NOCOPY VARCHAR2) IS

Cursor Get_Invoice_Items is
	Select project_id,
	       event_num,
	       -1*amount
	from   pa_draft_invoice_items
	where  draft_invoice_num = X_Draft_Invoice_Num
	and    project_id = X_Award_Project_Id;

F_invoice_project_id pa_draft_invoice_items.project_id%type;
F_invoice_event_num  pa_draft_invoice_items.event_num%type;
F_invoice_amount     pa_draft_invoice_items.amount%type;

Cursor Get_Gms_Event_Lines is
	Select project_id,
	       event_num,
	       installment_id,
	       write_off_amount,
	       actual_project_id,
	       actual_task_id,
	       rowid
	from   gms_event_attribute
	where  project_id = F_invoice_Project_id
	and    event_num = F_invoice_Event_Num;

F_project_id        gms_event_attribute.project_id%type;
F_event_num         gms_event_attribute.event_num%type;
F_installment_id    gms_event_attribute.installment_id%type;
F_write_off_amount  gms_event_attribute.write_off_amount%type;
F_actual_project_id gms_event_attribute.actual_project_id%type;
F_actual_task_id    gms_event_attribute.actual_task_id%type;

Upd_amount            gms_event_attribute.write_off_amount%type;
X_Total_Write_Off_Amt gms_event_attribute.write_off_amount%type;
F_rowid             varchar2(50);
F_Event_Count        Number := 0;
F_Counter            Number := 0;
F_Amount_written_off gms_event_attribute.bill_amount%type :=0;

BEGIN

   X_Err_Code := 0;
   pa_currency.set_currency_info; --For Bug 2895874

   Open Get_Invoice_items;
   Loop
   Fetch Get_Invoice_items
   into  F_Invoice_Project_Id, F_Invoice_Event_Num, F_Invoice_Amount;

   Exit When Get_Invoice_items%notfound;

   /* Start - Get Total Write_off Amount */

   BEGIN

      select sum(nvl(write_off_amount,0)),count(*)
      into   X_Total_Write_Off_Amt,F_Event_Count
      from   gms_event_attribute
      where  project_id = F_invoice_project_id
      and    event_num  = F_Invoice_event_num;

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
      RAISE_APPLICATION_ERROR(-20204,X_Err_Buff);
   END;

   /* End - Get Total Write_off Amount */


   Open Get_Gms_Event_Lines;
   Loop
   Fetch Get_Gms_Event_Lines
   Into  F_project_id, F_event_num, F_installment_id, F_write_off_amount,
         F_actual_project_id, F_actual_task_id, F_rowid;

   EXIT WHEN Get_Gms_Event_Lines%NOTFOUND;

   If F_Counter = F_Event_count - 1 then
      Upd_amount := F_Invoice_Amount - F_Amount_written_off;
   Else
     --For Bug 2895874 :Introduced pa_currency.round_curreny_amt
     Upd_amount := pa_currency.round_currency_amt((F_write_off_amount * F_Invoice_Amount)/X_Total_Write_Off_Amt);
     F_Amount_written_off := F_Amount_written_off + Upd_amount;
   End If;

   /* Start Update gms_event_attribute */

   BEGIN

      Update gms_event_attribute
      set    write_off_amount = write_off_amount - Upd_amount,
             bill_amount = bill_amount + Upd_amount
      where  rowid = F_rowid;


      If SQL%NOTFOUND THEN
      gms_error_pkg.gms_message('GMS_NO_DATA_PRJ_EVT_INST',
				'PRJ',
				F_Project_Id,
				'EVT',
				F_event_num,
				'INST',
				F_Installment_Id,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
        RAISE_APPLICATION_ERROR(-20205,X_Err_Buff);
      Else
        X_Err_Code := 0;
      End If;

   END;

   /* End - Update gms_event_attribute */

  /* Update gms_summary_project_fundings */

    UPD_GMS_SUMMARY_PRJ_FUNDS(F_actual_project_id,
                              F_actual_task_id,
                              F_installment_id,
                              Upd_amount,
                              'WRITE_OFF_DEL',
                              X_Err_Code,
                              X_Err_Buff);

    If X_Err_Code <> 0 then
       RAISE FND_API.G_EXC_ERROR;
    End If;
  F_Counter := F_Counter + 1;
  End Loop; -- get_gms_event_lines

  Close Get_Gms_Event_Lines;

  -- Re-initalize variables
  F_Amount_written_off := 0;
  Upd_amount           := 0;
  F_Counter            := 0;
  F_Event_Count       := 0;

 End Loop; -- get_invoice_items;

END WRITE_OFF_DELETION;

-- Procedure DELETE_GMS_EVENT_ATTRIBUTE deletes the gms_event_attribute records
-- Bug 2979125 : added parameter calling_process
Procedure DELETE_GMS_EVENT_ATTRIBUTE(X_Award_Project_Id  IN NUMBER,
				  X_Event_Num	      IN NUMBER,
                                  X_calling_process   IN VARCHAR2,
                                  X_Err_Code          IN OUT NOCOPY NUMBER,
                                  X_Err_Buff          IN OUT NOCOPY VARCHAR2) IS

Begin

  DELETE
  FROM	gms_event_attribute
  WHERE project_id=X_Award_Project_id
  AND   event_num=X_Event_Num
  AND   event_calling_process= x_calling_process ; -- Bug 2979125 : added filter calling_process

  If SQL%ROWCOUNT = 0 then
      gms_error_pkg.gms_message('GMS_NO_UPD_PRJ_EVT',
				'PRJ',
				X_Award_Project_id,
				'EVT',
				X_Event_Num,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      RAISE_APPLICATION_ERROR(-20206,X_Err_Buff);
  Else
     X_Err_Code := 0;
  End If;

End DELETE_GMS_EVENT_ATTRIBUTE;

Procedure GET_SUMM_REV_BILL_AMT(X_Installment_Id     IN NUMBER,
                                X_Act_Project_Id     IN NUMBER,
                                X_Act_Task_Id        IN NUMBER,
                                X_Calling_Process    IN VARCHAR2,
                                X_Amount             OUT NOCOPY NUMBER,
                                X_Err_Code           IN OUT NOCOPY NUMBER,
                                X_Err_Buff           IN OUT NOCOPY VARCHAR2)IS
St_Amount NUMBER(22,5) := 0;

Begin

 Select
 decode(X_Calling_Process,'Invoice',nvl(spf.total_billed_amount,0),'Revenue',nvl(spf.total_revenue_amount,0))
 into
 St_Amount
 from
 GMS_SUMMARY_PROJECT_FUNDINGS spf
 where
      spf.installment_id = X_Installment_Id
 and  spf.project_id     = X_Act_Project_Id
 and (
      (spf.task_id IS NULL)
  OR  (spf.task_id = X_Act_Task_Id)
  OR  (spf.task_id = (select top_task_id from pa_tasks where task_id = X_Act_Task_Id))
     );

 X_Amount := St_Amount;

 X_Err_Code := 0;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      gms_error_pkg.gms_message('GMS_NO_UPD_PRJ_TASK_INST',
				'PRJ',
				X_Act_Project_Id,
				'TASK',
				X_Act_Task_Id,
				'INST',
				X_Installment_Id,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
       RAISE_APPLICATION_ERROR(-20207,X_Err_Buff);
WHEN OTHERS THEN
      gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      RAISE_APPLICATION_ERROR(-20208,X_Err_Buff);
End GET_SUMM_REV_BILL_AMT;

Procedure MANIP_BILLREV_AMOUNT(X_Award_Project_id IN NUMBER,
                               X_Event_Num        IN NUMBER,
                               X_Calling_Process  IN VARCHAR2,
                               X_Err_Code         IN OUT NOCOPY NUMBER,
                               X_Err_Buff         IN OUT NOCOPY VARCHAR2) IS
X_Curr_Amount   NUMBER(22,5);
X_Amt_To_Update NUMBER(22,5);

Cursor get_event_details is
       select installment_id,
	      actual_project_id,
	      actual_task_id,
              decode(X_calling_Process,'Invoice',bill_amount,'Revenue',revenue_amount) Amount
       from   gms_event_attribute
       where  project_id = X_Award_Project_id
       and    event_num  = X_Event_Num;

F_Installment_id     gms_event_attribute.installment_id%type;
F_actual_project_id  gms_event_attribute.actual_project_id%type;
F_actual_task_id     gms_event_attribute.actual_task_id%type;
F_amount	     gms_event_attribute.bill_amount%type;

Begin

 X_Err_Code := 0;

 OPEN get_event_details;
 LOOP
 FETCH get_event_details
 INTO  F_Installment_id,F_actual_project_id,F_actual_task_id,F_amount;

 EXIT WHEN get_event_details%NOTFOUND;

 Begin
  GET_SUMM_REV_BILL_AMT(F_Installment_id,
                        F_actual_project_id,
                        F_actual_task_id,
                        X_Calling_Process,
                        X_Curr_Amount,
                        X_Err_Code,
                        X_Err_Buff);

           If X_Err_Code <> 0  then
              RAISE FND_API.G_EXC_ERROR;
           End If;

   /* Amount To Update */
      X_Amt_To_Update := (X_Curr_Amount - F_amount);

 End;

   /* Update GMS_SUMMARY_PROJECT_FUNDINGS */
  Begin
      If X_Calling_Process = 'Invoice' then

       update GMS_SUMMARY_PROJECT_FUNDINGS spf
       set
       spf.Total_Billed_Amount = X_Amt_To_Update
       ,spf.last_update_date   = sysdate
       ,spf.last_update_login  = fnd_global.login_id
       ,spf.last_updated_by    = fnd_global.user_id
       where
       spf.installment_id = F_Installment_id
       and spf.project_id = F_actual_project_id
       and (
          (spf.task_id IS NULL)
       OR (spf.task_id = F_actual_task_id)
       OR (spf.task_id = (select t.top_task_id from pa_tasks t where t.task_id = F_actual_task_id))
           );

      Elsif

        X_Calling_Process = 'Revenue' then
       update GMS_SUMMARY_PROJECT_FUNDINGS spf
       set
       spf.Total_Revenue_Amount = X_Amt_To_Update
       ,spf.last_update_date   = sysdate
       ,spf.last_update_login  = fnd_global.login_id
       ,spf.last_updated_by    = fnd_global.user_id
       where
       spf.installment_id = F_Installment_id
       and spf.project_id = F_actual_project_id
       and (
          (spf.task_id IS NULL)
       OR (spf.task_id = F_actual_task_id)
       OR (spf.task_id = (select t.top_task_id from pa_tasks t where t.task_id = F_actual_task_id))
           );

      End If;

      IF SQL%NOTFOUND then
         gms_error_pkg.gms_message('GMS_NO_UPD_PRJ_TASK_INST',
				'PRJ',
				F_actual_project_id,
				'TASK',
				F_Actual_Task_Id,
				'INST',
				F_Installment_Id,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
         RAISE_APPLICATION_ERROR(-20209,X_Err_Buff);
      Else
         X_Err_Code := 0;
      End If;
   End;

   End Loop;

End MANIP_BILLREV_AMOUNT;

Procedure DELETE_GMS_BURDEN_INTRSCT(X_Expenditure_Item_Id IN NUMBER,
				    X_Award_Project_Id    IN NUMBER,
				    X_Event_Num		  IN NUMBER,
                                    X_Adl_Line_No         IN NUMBER,
				    X_Calling_Process	  IN VARCHAR2,
                                    X_Burden_Cost_Code    IN VARCHAR2,  -- Bug 1193080
			            X_Err_Code            IN OUT NOCOPY NUMBER,
				    X_Err_Buff		  IN OUT NOCOPY VARCHAR2) IS

Begin

  X_Err_Code := 0;

 If X_Calling_Process = 'Invoice' then

  DELETE /*+INDEX(GMS_BURDEN_COMPONENTS GMS_BURDEN_COMPONENTS_U1) */
  from
  GMS_BURDEN_COMPONENTS
  where
  expenditure_item_id   = X_Expenditure_Item_Id
  and award_project_Id  = X_Award_Project_Id
  and event_num         = X_Event_Num
  and adl_line_num       = X_Adl_Line_No
  and burden_cost_code  = X_Burden_Cost_Code  -- Bug 1193080
  and event_type        = 'INVOICE';

  If SQL%ROWCOUNT = 0 then

         gms_error_pkg.gms_message('GMS_NO_DEL_PRJ_EVT_EXP_ADL',
				'PRJ',
				X_Award_Project_Id,
				'EVT',
				X_Event_Num,
				'EXP',
				X_Expenditure_Item_Id,
				'ADL',
				X_Adl_Line_No,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
         RAISE_APPLICATION_ERROR(-20210,X_Err_Buff);
  Else
        X_Err_Code := 0;
  End If;

 Elsif X_Calling_Process = 'Revenue' then
  DELETE /*+INDEX(GMS_BURDEN_COMPONENTS GMS_BURDEN_COMPONENTS_U1) */
  from
  GMS_BURDEN_COMPONENTS
  where
  expenditure_item_id   = X_Expenditure_Item_Id
  and award_project_Id  = X_Award_Project_Id
  and event_num         = X_Event_Num
  and adl_line_num       = X_Adl_Line_No
  and burden_cost_code  = X_Burden_Cost_Code  -- Bug 1193080
  and event_type        = 'REVENUE';

  If SQL%ROWCOUNT = 0 then
        gms_error_pkg.gms_message('GMS_NO_DEL_PRJ_EVT_EXP_ADL',
                                'PRJ',
                                X_Award_Project_Id,
                                'EVT',
                                X_Event_Num,
                                'EXP',
                                X_Expenditure_Item_Id,
                                'ADL',
                                X_Adl_Line_No,
                                X_Exec_Type => 'C',
                                X_Err_Code => X_Err_Code,
                                X_Err_Buff => X_Err_Buff);
        RAISE_APPLICATION_ERROR(-20211,X_Err_Buff);
  Else
        X_Err_Code := 0;
  End If;

 End If;

End DELETE_GMS_BURDEN_INTRSCT;

Procedure DELETE_GMS_INTERSECT(X_Expenditure_Item_Id IN NUMBER,
                               X_Award_Project_Id    IN NUMBER,
                               X_Event_Num           IN NUMBER,
			       X_Adl_Line_No	     IN NUMBER,
			       X_Calling_Process     IN VARCHAR2,
                               X_Err_Code            IN OUT NOCOPY NUMBER,
                               X_Err_Buff            IN OUT NOCOPY VARCHAR2) IS
Begin

 X_Err_Code := 0;

 If X_Calling_Process = 'Invoice' then
  DELETE /*+INDEX(GMS_EVENT_INTERSECT GMS_EVENT_INTERSECT_U1) */
  from
  GMS_EVENT_INTERSECT
  where
  expenditure_item_id   = X_Expenditure_Item_Id
  and award_project_Id  = X_Award_Project_Id
  and event_num         = X_Event_Num
  and adl_line_num       = X_Adl_Line_No
  and event_type        = 'INVOICE';

     If SQL%ROWCOUNT = 0 then

        gms_error_pkg.gms_message('GMS_NO_DEL_PRJ_EVT_EXP_ADL',
                                'PRJ',
                                X_Award_Project_Id,
                                'EVT',
                                X_Event_Num,
                                'EXP',
                                X_Expenditure_Item_Id,
                                'ADL',
                                X_Adl_Line_No,
                                X_Exec_Type => 'C',
                                X_Err_Code => X_Err_Code,
                                X_Err_Buff => X_Err_Buff);
        RAISE_APPLICATION_ERROR(-20212,X_Err_Buff);
     Else
        X_Err_Code := 0;
     End If;
 Elsif X_Calling_Process = 'Revenue' then
  DELETE /*+INDEX(GMS_EVENT_INTERSECT GMS_EVENT_INTERSECT_U1) */
  from
  GMS_EVENT_INTERSECT
  where
  expenditure_item_id   = X_Expenditure_Item_Id
  and award_project_Id  = X_Award_Project_Id
  and event_num         = X_Event_Num
  and adl_line_num       = X_Adl_Line_No
  and event_type        = 'REVENUE';

     If SQL%ROWCOUNT = 0 then

        gms_error_pkg.gms_message('GMS_NO_DEL_PRJ_EVT_EXP_ADL',
                                'PRJ',
                                X_Award_Project_Id,
                                'EVT',
                                X_Event_Num,
                                'EXP',
                                X_Expenditure_Item_Id,
                                'ADL',
                                X_Adl_Line_No,
                                X_Exec_Type => 'C',
                                X_Err_Code => X_Err_Code,
                                X_Err_Buff => X_Err_Buff);
        RAISE_APPLICATION_ERROR(-20213,X_Err_Buff);
     Else
      X_Err_Code := 0;
     End If;

 End If;

End DELETE_GMS_INTERSECT;

Procedure UPD_PA_EXP_AND_ADL(X_Award_Project_id     IN NUMBER,
			     X_Expenditure_Item_Id  IN NUMBER,
			     X_Adl_Line_No	    IN NUMBER,
			     X_Calling_Process      IN VARCHAR2,
                             X_Err_Code             IN OUT NOCOPY NUMBER,
                             X_Err_Buff             IN OUT NOCOPY VARCHAR2) IS

Begin

If X_Calling_Process = 'Invoice' then

 UPDATE GMS_AWARD_DISTRIBUTIONS
 set
 billed_flag = 'N'
 ,last_update_date   = sysdate
 ,last_updated_by    = fnd_global.user_id
 ,last_update_login  = fnd_global.login_id
 where expenditure_item_id = X_Expenditure_Item_Id
 and   adl_line_num = X_Adl_Line_No
 and   award_id=
       (select award_id
        from   gms_awards
	where  award_project_id=X_Award_Project_Id
       )
 and    document_type='EXP'
 and    adl_status = 'A';

    If SQL%NOTFOUND THEN
        gms_error_pkg.gms_message('GMS_NO_UPD_PRJ_EXP_ADL',
                                'PRJ',
                                X_Award_Project_Id,
                                'EXP',
                                X_Expenditure_Item_Id,
                                'ADL',
                                X_Adl_Line_No,
                                X_Exec_Type => 'C',
                                X_Err_Code => X_Err_Code,
                                X_Err_Buff => X_Err_Buff);
        RAISE_APPLICATION_ERROR(-20214,X_Err_Buff);
    Else
     X_Err_Code := 0;
    End If;

Elsif X_Calling_Process = 'Revenue' then

-- PA_EXPENDITURE_ITEMS_ALL would not be updated
/*
 UPDATE PA_EXPENDITURE_ITEMS_ALL
 set
 revenue_distributed_flag  = 'N'
 ,last_update_date   = sysdate
 ,last_updated_by    = fnd_global.user_id
 ,last_update_login  = fnd_global.login_id
 where
 expenditure_item_id = X_Expenditure_Item_Id;

    If SQL%NOTFOUND THEN
        X_Err_Code := 'E';
        FND_MESSAGE.SET_NAME('GMS','GMS_BILLING_ADJUSTMENTS');
	FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE','No Expenditure Line Updated');
        FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_BILLING_ADJUSTMENTS : UPD_GET_PA_EXP_INFO');
        X_Err_Buff := FND_MESSAGE.GET;
     pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => 'GMS_BILLING_ADJUSTMENTS.UPD_GET_PA_EXP_INFO'
                                      ,x_message => X_Err_Buff
                                      ,x_error_message => X_pa_Err_Msg
                                      ,x_status => X_pa_Status);
			RAISE_APPLICATION_ERROR(-20008,X_Err_Buff);
           RETURN;
    Else
     X_Err_Code := 'S';
    End If;
*/
 UPDATE GMS_AWARD_DISTRIBUTIONS
 set
 revenue_distributed_flag = 'N'
 ,last_update_date   = sysdate
 ,last_updated_by    = fnd_global.user_id
 ,last_update_login  = fnd_global.login_id
 where expenditure_item_id = X_Expenditure_Item_Id
 and   adl_line_num = X_Adl_Line_No
 and   award_id=
       (select award_id
        from   gms_awards
	where  award_project_id=X_Award_Project_Id
       )
 and    document_type='EXP'
 and    adl_status = 'A';

    If SQL%NOTFOUND THEN
        gms_error_pkg.gms_message('GMS_NO_UPD_PRJ_EXP_ADL',
                                'PRJ',
                                X_Award_Project_Id,
                                'EXP',
                                X_Expenditure_Item_Id,
                                'ADL',
                                X_Adl_Line_No,
                                X_Exec_Type => 'C',
                                X_Err_Code => X_Err_Code,
                                X_Err_Buff => X_Err_Buff);
        RAISE_APPLICATION_ERROR(-20215,X_Err_Buff);
    Else
     X_Err_Code := 0;
    End If;

End If;

End UPD_PA_EXP_AND_ADL;


Procedure GET_EVENT_INFO(X_Award_Project_Id   IN NUMBER,
                         X_Event_Num          IN NUMBER,
                         X_Event_Type         OUT NOCOPY VARCHAR2,
                         X_Event_Type_Class   OUT NOCOPY VARCHAR2,
                         X_Burden_Evt_Flag    OUT NOCOPY VARCHAR2,
                         X_Err_Code           IN OUT NOCOPY NUMBER,
                         X_Err_Buff           IN OUT NOCOPY VARCHAR2)  IS

X_Burden_Cost_Code VARCHAR2(30);

Begin

 Select distinct
 nvl(a.burden_cost_code,'NULL'),
 a.event_type,
 b.event_type_classification
 into
 X_Burden_Cost_Code,
 X_Event_Type,
 X_Event_Type_Class
 from
 gms_events_v a,
 pa_event_types b
 where
     a.project_id = X_Award_Project_Id
 and a.event_num  = X_Event_Num
 and a.event_type = b.event_type;

      X_Err_Code := 0;

         If X_Burden_Cost_Code = 'NULL' then
            X_Burden_Evt_Flag := 'N' ;
         Else
            X_Burden_Evt_Flag := 'Y';
         End If;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      gms_error_pkg.gms_message('GMS_NO_DATA_PRJ_EVT',
				'PRJ',
				X_Award_Project_Id,
				'EVT',
				X_Event_Num,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      RAISE_APPLICATION_ERROR(-20216,X_Err_Buff);
  WHEN OTHERS THEN
      gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      RAISE_APPLICATION_ERROR(-20217,X_Err_Buff);
End GET_EVENT_INFO;


	/* Procedure GET_EVENT_PROJ_TASK to Get Project and Task for the Event */

Procedure GET_EVENT_PROJ_TASK(X_Event_Num             IN NUMBER,
                              X_Award_Project_Id      IN NUMBER,
			      X_Expenditure_Item_Id   IN NUMBER DEFAULT NULL,
                              X_Actual_Project_Id     OUT NOCOPY NUMBER,
                              X_Actual_Task_Id        OUT NOCOPY NUMBER,
			      X_Expenditure_Org_Id    OUT NOCOPY NUMBER,
			      X_Revenue_Accumulated   OUT NOCOPY VARCHAR2,
			      X_Creation_Date	      OUT NOCOPY DATE,
                              X_Err_Code              IN OUT NOCOPY NUMBER,
                              X_Err_Buff              IN OUT NOCOPY VARCHAR2) IS

Begin
Select distinct
Actual_Project_Id,
Actual_Task_Id,
Expenditure_Org_Id,
Revenue_Accumulated
--,Creation_Date
into
X_Actual_Project_Id,
X_Actual_Task_Id,
X_Expenditure_Org_Id,
X_Revenue_Accumulated
--,X_Creation_Date
from
gms_events_v
where project_id = X_Award_Project_Id
and   event_num  = X_Event_Num;

If X_Expenditure_Item_Id is not null then
-- Cost Based
    Select trunc(expenditure_item_date)
    into   X_creation_date
    from   pa_expenditure_items_all
    where  Expenditure_Item_Id = X_Expenditure_Item_Id;
End If;

    X_Err_Code := 0;

   EXCEPTION
    WHEN NO_DATA_FOUND THEN
      gms_error_pkg.gms_message('GMS_NO_DATA_PRJ_EVT',
				'PRJ',
				X_Award_Project_Id,
				'EVT',
				X_Event_Num,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      RAISE_APPLICATION_ERROR(-20218,X_Err_Buff);
    WHEN OTHERS THEN
      gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      RAISE_APPLICATION_ERROR(-20219,X_Err_Buff);
End GET_EVENT_PROJ_TASK;


Procedure GET_INVOICE_CREDIT_INFO(X_Draft_Invoice_Num          IN  NUMBER,
                                  X_Award_Project_Id           IN  NUMBER,
                                  X_Write_Off_Flag             OUT NOCOPY VARCHAR2,
				  X_Concession_Invoice_Flag    OUT NOCOPY VARCHAR2,
                                  X_Draft_Invoice_Num_Credited OUT NOCOPY VARCHAR2,
                                  X_Err_Code                   IN OUT NOCOPY NUMBER,
                                  X_Err_Buff                   IN OUT NOCOPY VARCHAR2) IS

Begin
 Select
 NVL(write_off_flag,'N'),
 NVL(concession_flag,'N'),
 draft_invoice_num_credited
 into
 X_Write_Off_Flag,
 X_Concession_Invoice_Flag,
 X_Draft_Invoice_Num_Credited
 from
 PA_DRAFT_INVOICES
 where project_id = X_Award_Project_Id
 and draft_invoice_num = X_Draft_Invoice_Num;
         X_Err_Code := 0;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      RAISE_APPLICATION_ERROR(-20220,X_Err_Buff);
End GET_INVOICE_CREDIT_INFO;


Procedure DO_INV_ITEM_PROCESSING(St_Award_Project_Id   IN NUMBER,
				 St_Draft_Invoice_Num IN NUMBER,
                                 X_Adj_Action         IN VARCHAR2,
                                 X_Adjust_Amount      IN NUMBER DEFAULT NULL,
                                 X_Calling_Process    IN VARCHAR2,
                                 X_Err_Code           IN OUT NOCOPY NUMBER,
                                 X_Err_Buff           IN OUT NOCOPY VARCHAR2) IS

CURSOR GET_INV_ITEMS IS
Select
project_id,
line_num,
event_num,
amount
from
pa_draft_invoice_items
where
draft_invoice_num = St_Draft_Invoice_Num and
project_id        = St_Award_Project_Id;

F_Award_Project_Id    NUMBER(15);
F_Line_Num            NUMBER(15);
F_Event_Num           NUMBER(15);
F_Amount              NUMBER(22,5);

/* This is the cursor to identify the rows in the intersect table related to the Invoice items */
CURSOR IDENT_INV_INTRSCT_ITEMS is
Select
expenditure_item_id,
adl_line_num,
request_id   -- for bug 4594090
from
gms_event_intersect
where
award_project_id = F_Award_Project_Id and
event_num        = F_Event_Num        and
event_type       = 'INVOICE';

F_Expenditure_Item_Id   NUMBER(15);
F_Adl_Line_No		NUMBER(15);

/* This is the cursor to identify the rows in the Burden Component table related to the Burden
   Invoice Items */
CURSOR BURDEN_INV_INTRSCT_ITEMS is
Select
Expenditure_Item_Id,
adl_line_num,
Amount,
Actual_Project_Id,
Actual_Task_Id,
Burden_Exp_Type,
Burden_Cost_Code,
Expenditure_Org_Id,
request_id   -- Added for bug 4594090
from
GMS_BURDEN_COMPONENTS
where
award_project_id   = F_Award_Project_Id and
event_num          = F_Event_Num        and
event_type         = 'INVOICE';

F_Burd_Expenditure_Item_Id   NUMBER(15);
F_Burd_Adl_Line_No           NUMBER(15);
F_Burd_Intrsct_Amount        NUMBER(22,5);
F_Burd_Actual_Project_Id     NUMBER(15);
F_Burd_Actual_Task_Id        NUMBER(15);
F_Burd_Exp_Type              VARCHAR2(30);
F_Burd_Cost_Code	     VARCHAR2(30);
F_Burd_Expenditure_Org_Id    NUMBER(15);

F_Actual_Project_Id_1 NUMBER(15);
F_Actual_Task_Id_1    NUMBER(15);
F_Line_Num_1          NUMBER(15);
F_Installment_Id_1    NUMBER(15);
F_Write_Off_Amount_1  NUMBER(22,5);

F_Actual_Project_Id_2 NUMBER(15);
F_Actual_Task_Id_2    NUMBER(15);
F_Line_Num_2	      NUMBER(15);
F_Installment_Id_2    NUMBER(15);
F_Write_Off_Amount_2  NUMBER(22,5);

X_Event_Type          VARCHAR2(30);
X_Event_Type_Class    VARCHAR2(30);
X_Installment_Id      NUMBER(15);
X_Actual_Project_Id   NUMBER(15);
X_Actual_Task_Id      NUMBER(15);
X_Write_Off_Flag              VARCHAR2(1);
X_Draft_Invoice_Num_Credited  NUMBER(15);
X_Write_Off_Amount            NUMBER(22,5);

X_Burden_Evt_Flag     VARCHAR2(1);

X_Concession_flag     VARCHAR2(1);

F_request_id          gms_event_attribute.request_id%TYPE; --  Added for bug 4594090

Begin

 If X_Adj_Action in ('CANCEL','DELETE') then

 /* Find Out NOCOPY if the Invoice that's being processed is a Regular Invoice
   or a Write Off on some other Invoice */

        GET_INVOICE_CREDIT_INFO(St_Draft_Invoice_Num,
			        St_Award_Project_Id,
			        X_Write_Off_Flag,
				X_Concession_Flag,
			        X_Draft_Invoice_Num_Credited,
                                X_Err_Code,
                                X_Err_Buff);

                If X_Err_Code <> 0 then
                    RAISE FND_API.G_EXC_ERROR;
                End If;

 End If;

If (X_Adj_Action = 'CANCEL' OR X_Adj_Action = 'DELETE') then
 If ((X_Write_Off_Flag = 'Y') OR (X_Concession_Flag = 'Y')) then
   Begin

/* --------------------------------------------------------------- */
-- 11.5 Changes, re writing of Write_off deletion/cancellation Processing
/* --------------------------------------------------------------- */

      WRITE_OFF_DELETION(St_Award_Project_Id,
			 St_Draft_Invoice_Num,
                         X_Err_Code,
                         X_Err_Buff);

                If X_Err_Code <> 0 then
                    RAISE FND_API.G_EXC_ERROR;
                End If;


      /* pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '5 - CANINV'
                                          ,x_message => 'Inside WRITE-OFF Flag = Y '
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status); */

   End;

 Else -- (X_Write_Off_Flag <> 'Y'=> Regular Invoice)

  open GET_INV_ITEMS;
         /* pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '6 - CANINV'
                                          ,x_message =>'In WRITE_OFF_FLAG = N'
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status);  */

  LOOP -- Loop for PA_DRAFT_INVOICE_ITEMS
    FETCH
    GET_INV_ITEMS
    into
    F_Award_Project_Id,
    F_Line_Num,
    F_Event_Num,
    F_Amount;
      EXIT WHEN GET_INV_ITEMS%NOTFOUND;

        /* pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '6.1 - CANINV'
                                          ,x_message =>'Before GET_EVENT_INFO'
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status);  */

         GET_EVENT_INFO(F_Award_Project_Id,
                        F_Event_Num,
                        X_Event_Type,
                        X_Event_Type_Class,
			X_Burden_Evt_Flag,
                        X_Err_Code,
                        X_Err_Buff);

       /* pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '6.2 - CANINV'
                                          ,x_message =>'After GET_EVENT_INFO'||'-'||St_Err_Code
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status); */

            If X_Err_Code <> 0 then
                 RAISE FND_API.G_EXC_ERROR;
            End If;

 If (X_Event_Type_Class = 'AUTOMATIC' and X_Event_Type = 'AWARD_BILLING') then

--------------------------------------------------------------------
   If (X_Burden_Evt_Flag = 'N') then

         /* pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '6.2.1 - CANINV'
                                          ,x_message =>'Inside Burden_Evt_Flag = N'
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status); */

     Begin  -- Raw Component Processing
      open IDENT_INV_INTRSCT_ITEMS;
      LOOP
         FETCH
         IDENT_INV_INTRSCT_ITEMS
         into
         F_Expenditure_Item_Id,
         F_Adl_Line_No,
         F_request_id; -- 4594090

             EXIT WHEN IDENT_INV_INTRSCT_ITEMS%NOTFOUND;

        /* Updating PA_EXPENDITURE_ITEMS_ALL and GMS_AWARD_DISTRIBUTIONS, setting the Revenue Accrued Flag to 'N' */
                     UPD_PA_EXP_AND_ADL(F_Award_Project_id,
                                        F_Expenditure_Item_Id,
					F_Adl_Line_No,
                                        X_Calling_Process,
                                        X_Err_Code,
                                        X_Err_Buff);

        /* pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '6.2.2 - CANINV'
                                          ,x_message =>'After UPD_GET_PA_EXP_INFO '||'-'||St_Err_Code
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status); */

                              If X_Err_Code <> 0 then
                                RAISE FND_API.G_EXC_ERROR;
                              End If;

              /* Deleting Items From GMS_EVENT_INTERSECT Table */
                    DELETE_GMS_INTERSECT(F_Expenditure_Item_Id,
                                         F_Award_Project_Id,
                                         F_Event_Num,
					 F_Adl_Line_No,
					 X_Calling_Process,
                                         X_Err_Code,
                                         X_Err_Buff);

       /* pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '6.2.3 - CANINV'
                                          ,x_message =>'After DELETE_GMS_INTERSECT '||'-'||St_Err_Code
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status); */

                              If X_Err_Code <> 0 then
                                 RAISE FND_API.G_EXC_ERROR;
                              End If;

     End LOOP;
     close IDENT_INV_INTRSCT_ITEMS;

              /* Updating GMS_SUMMARY_PROJECT_FUNDINGS Revenue Accrued Amount */
                   MANIP_BILLREV_AMOUNT(F_Award_Project_id,
                                        F_Event_Num,
                                        X_Calling_Process,
                                        X_Err_Code,
                                        X_Err_Buff);

    /*pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '6.2.4 - CANINV'
                                          ,x_message =>'After MANIP_BILLREV_AMOUNT '||'-'||St_Err_Code
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status); */

                              If X_Err_Code <> 0 then
                                 RAISE FND_API.G_EXC_ERROR;
                              End If;

               /* Delete entries from GMS_EVENT_ATTRIBUTE */
               /* Bug 2979125: added parameter calling_process */
                  DELETE_GMS_EVENT_ATTRIBUTE(F_Award_Project_id,
                                             F_Event_Num,
                                             X_Calling_Process,
                                             X_Err_Code,
                                             X_Err_Buff);

  /* pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '6.2.5 - CANINV'
                                          ,x_message =>'After DELETE_GMS_EVENT_ATTRIBUTE '||'-'||St_Err_Code
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status); */

                              If X_Err_Code <> 0 then
                                 RAISE FND_API.G_EXC_ERROR;
                              End If;

    End; -- Raw Component Processing

  Elsif (X_Burden_Evt_Flag = 'Y') then -----------------------------------

    Begin -- Burden Component Processing

    open BURDEN_INV_INTRSCT_ITEMS;

   /* pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '6.3.1 - CANINV'
                                          ,x_message =>'Inside X_Burden_Evt_Flag = Y '||'-'||St_Err_Code
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status); */
       LOOP
        FETCH BURDEN_INV_INTRSCT_ITEMS into
        F_Burd_Expenditure_Item_Id ,
        F_Burd_Adl_Line_No         ,
        F_Burd_Intrsct_Amount      ,
	F_Burd_Actual_Project_Id   ,
	F_Burd_Actual_Task_Id      ,
	F_Burd_Exp_Type            ,
	F_Burd_Cost_Code           ,
	F_Burd_Expenditure_Org_Id  ,
        F_request_id; -- 4594090

                 EXIT WHEN BURDEN_INV_INTRSCT_ITEMS%NOTFOUND;

		 -- Bug 2477972, start
		 /* On GMS_AWARD_DISTRIBUTIONS setting the Invoice Accrued Flag to 'N' */
                     UPD_PA_EXP_AND_ADL(F_Award_Project_id,
                                        F_Burd_Expenditure_Item_Id,
                                        F_Burd_Adl_Line_No,
                                        X_Calling_Process,
                                        X_Err_Code,
                                        X_Err_Buff);
            	 If X_Err_Code <> 0 then
                     RAISE FND_API.G_EXC_ERROR;
                 End If;
		 -- Bug 2477972, end

           /* Deleting items from GMS_BURDEN_COMPONENTS table */

     /* pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '6.3.2 - CANINV'
                                          ,x_message =>'Before DELETE_GMS_BURDEN_INTRSCT'
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status); */

       DELETE_GMS_BURDEN_INTRSCT(F_Burd_Expenditure_Item_Id ,
                                 F_Award_Project_Id,
                                 F_Event_Num,
				 F_Burd_Adl_Line_No,
                                 X_Calling_Process,
				 F_Burd_Cost_Code,		-- Bug 1193080
                                 X_Err_Code,
                                 X_Err_Buff);

      /* pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '6.3.3 - CANINV'
                                          ,x_message =>'After DELETE_GMS_BURDEN_INTRSCT'||'-'||St_Err_Code
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status); */

                            If X_Err_Code <> 0 then
                                 RAISE FND_API.G_EXC_ERROR;
                            End If;

       END LOOP;
    close BURDEN_INV_INTRSCT_ITEMS;

              /* Updating GMS_SUMMARY_PROJECT_FUNDINGS Revenue Accrued Amount */
                   MANIP_BILLREV_AMOUNT(F_Award_Project_id,
                                        F_Event_Num,
                                        X_Calling_Process,
                                        X_Err_Code,
                                        X_Err_Buff);

             /* pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '6.3.4 - CANINV'
                                          ,x_message =>'After MANIP_BILLREV_AMOUNT '||'-'||St_Err_Code
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status); */

                              If X_Err_Code <> 0 then
                                 RAISE FND_API.G_EXC_ERROR;
                              End If;

               /* Delete entries from GMS_EVENT_ATTRIBUTE */
               /* Bug 2979125 : added parameter calling_process */
                  DELETE_GMS_EVENT_ATTRIBUTE(F_Award_Project_id,
                                             F_Event_Num,
                                             X_Calling_Process,
                                             X_Err_Code,
                                             X_Err_Buff);

             /* pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '6.3.5 - CANINV'
                                          ,x_message =>'After DELETE_GMS_EVENT_ATTRIBUTE '||'-'||St_Err_Code
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status); */

                              If X_Err_Code <> 0 then
                                 RAISE FND_API.G_EXC_ERROR;
                              End If;

    End; -- Burden Component Processing

  End If ; -- End If for X_Burden_Evt_Flag

--------------------------------------------------------------------------
/* -- Handle net zero events .... (4594090)
  HANDLE_NET_ZERO_EVENTS (P_AWARD_PROJECT_ID => F_Award_Project_id,
                          P_REQUEST_ID       => F_request_id,
                          P_CALLING_PROCESS  => 'INVOICE');
Moving this call from here to after the close of GET_INV_ITEMS cursor
for perfomance reasons. Bug 5060427 */
 Elsif  X_Event_Type_Class = 'MANUAL' then

    Begin

              /* Updating GMS_SUMMARY_PROJECT_FUNDINGS Revenue Accrued Amount */
                   MANIP_BILLREV_AMOUNT(F_Award_Project_id,
                                        F_Event_Num,
                                        X_Calling_Process,
                                        X_Err_Code,
                                        X_Err_Buff);

    /* pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '6.4.1 - CANINV'
                                          ,x_message =>'After MANIP_BILLREV_AMOUNT '||'-'||St_Err_Code
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status); */

            If X_Err_Code <> 0 then
                 RAISE FND_API.G_EXC_ERROR;
            End If;
    End;

 End If; -- End of If for Event_Type_Classification('Manual' or 'Automatic')

  End LOOP; -- End Loop for PA_DRAFT_INVOICE_ITEMS

   CLOSE GET_INV_ITEMS;

         X_Err_Code := 0;

 -- Handle net zero events .... (4594090)
 -- Moved this call to here from an earlier point for bug 5060427
  HANDLE_NET_ZERO_EVENTS (P_AWARD_PROJECT_ID => F_Award_Project_id,
                          P_REQUEST_ID       => F_request_id,
                          P_CALLING_PROCESS  => 'INVOICE');

 End If; -- Check FOR WRITE_OFF_FLAG

Elsif (X_Adj_Action in ('WRITE_OFF','CONCESSION')) then

  /* pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '2 - WRITEOFFF'
                                          ,x_message => 'Getting INTO GRANTS WRITE OFF Process '
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status); */

  Begin

  /* pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '2.25 - WRITEOFFF'
                                          ,x_message => to_char(St_Award_Project_Id)||'-  '||to_char(St_Draft_Invoice_Num)
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status); */

/* --------------------------------------------------------------- */
-- 11.5 Changes, re writing of Write_off Processing
/* --------------------------------------------------------------- */

    WRITE_OFF_CREATION(St_Award_Project_Id,
		       X_Adj_Action,
                       X_Err_Code,
                       X_Err_Buff);

                If X_Err_Code <> 0 then
                    RAISE FND_API.G_EXC_ERROR;
                End If;

      /* pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '2.50 - AFTER WRITE OFF PROCESSING'
                                          ,x_message => 'Inside WRITE-OFF Flag = Y '
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status); */

   End;
End If; -- End of X_Adj_Action IF

      X_Err_Code := 0;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK;
        RETURN;

End DO_INV_ITEM_PROCESSING;


Procedure DO_REV_ITEM_PROCESSING(St_Award_Project_Id    IN  NUMBER,
				 St_Draft_Revenue_Num   IN  NUMBER,
				 X_Calling_Process      IN  VARCHAR2,
				 X_Err_Code             IN OUT NOCOPY NUMBER,
				 X_Err_Buff 		IN OUT NOCOPY VARCHAR2) IS
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
ri.draft_revenue_num                       = St_Draft_Revenue_Num and
ri.project_id                              = St_Award_Project_Id  and
rdl.draft_revenue_num                      = ri.draft_revenue_num and
rdl.project_id                             = ri.project_id        and
rdl.draft_revenue_item_line_num            = ri.line_num;

F_Award_Project_Id    NUMBER(15);
F_Line_Num            NUMBER(15);
F_Event_Num           NUMBER(15);
F_Amount              NUMBER(22,5);

X_Event_Type          VARCHAR2(30);
X_Event_Type_Class    VARCHAR2(30);
X_Installment_Id      NUMBER(15);


/* This is the cursor to identify the rows in the intersect table related to the Revenue Items */
CURSOR IDENT_REV_INTRSCT_ITEMS is
Select
expenditure_item_id,
adl_line_num,
amount,
revenue_accumulated,
request_id   -- 4594090
from
gms_event_intersect
where
award_project_id = F_Award_Project_Id and
event_num        = F_Event_Num        and
event_type       = 'REVENUE';

F_Expenditure_Item_Id   NUMBER(15);
F_Adl_Line_No		NUMBER(15);
F_Raw_Revenue_Amount	NUMBER(22,5);
F_Rev_Accumulated     VARCHAR2(1);

/* This is the cursor to identify the rows in the Burden Component table related to the Burden
   Invoice Items */
CURSOR BURDEN_REV_INTRSCT_ITEMS is
Select
Expenditure_Item_Id,
Adl_Line_Num,
Amount,
Actual_Project_Id,
Actual_Task_Id,
Burden_Exp_Type,
Burden_Cost_Code,
Expenditure_Org_Id,
Creation_Date,
Revenue_Accumulated,
request_id   -- 4594090
from
GMS_BURDEN_COMPONENTS
where
award_project_id   = F_Award_Project_Id and
event_num          = F_Event_Num        and
event_type         = 'REVENUE';

F_Rev_Burd_Expend_Item_Id   NUMBER(15);
F_Rev_Adl_Line_No           NUMBER(15);
F_Rev_Burd_Intrsct_Amt      NUMBER(22,5);
F_Rev_Actual_Project_Id     NUMBER(15);
F_Rev_Actual_Task_Id        NUMBER(15);
F_Rev_Burden_Exp_Type       VARCHAR2(30);
F_Rev_Burden_Cost_Code      VARCHAR2(30);
F_Rev_Burd_Exp_Org_Id       NUMBER(15);
F_Rev_Creation_Date	    DATE;
F_Rev_Revenue_Accumulated   VARCHAR2(1);


X_Actual_Project_Id   NUMBER(15);
X_Actual_Task_Id      NUMBER(15);
X_Expenditure_Org_Id  NUMBER(15);
X_Revenue_Accumulated VARCHAR2(1);
X_Creation_Date       DATE;

X_Burden_Evt_Flag     VARCHAR2(1);

F_request_id          gms_event_attribute.request_id%TYPE; -- 4594090

Begin
  OPEN GET_REV_ITEMS_RDL;
  LOOP
   FETCH GET_REV_ITEMS_RDL into
   F_Award_Project_Id,
   F_Line_Num,
   F_Event_Num,
   F_Amount;
      EXIT WHEN GET_REV_ITEMS_RDL%NOTFOUND;

         GET_EVENT_INFO(F_Award_Project_Id,
                        F_Event_Num,
                        X_Event_Type,
                        X_Event_Type_Class,
                        X_Burden_Evt_Flag,
                        X_Err_Code,
                        X_Err_Buff);

            If X_Err_Code <> 0 then
                 RAISE FND_API.G_EXC_ERROR;
            End If;

 If (X_Event_Type_Class = 'AUTOMATIC' and X_Event_Type = 'AWARD_BILLING' ) then

--------------------------------------------------------------------------------
  If (X_Burden_Evt_Flag = 'N') then
  Begin -- Raw Component processing

     OPEN IDENT_REV_INTRSCT_ITEMS;
       LOOP
         FETCH
         IDENT_REV_INTRSCT_ITEMS
         into
         F_Expenditure_Item_Id,
         F_Adl_Line_No,
	 F_Raw_Revenue_Amount,
	 F_Rev_Accumulated,
	 F_request_id; -- 4594090
             EXIT WHEN IDENT_REV_INTRSCT_ITEMS%NOTFOUND;

        /* Updating PA_EXPENDITURE_ITEMS_ALL and GMS_AWARD_DISTRIBUTIONS, setting the Revenue Accrued Flag to 'N' */
                     UPD_PA_EXP_AND_ADL(F_Award_Project_id,
				        F_Expenditure_Item_Id,
					F_Adl_Line_No,
					X_Calling_Process,
                                        X_Err_Code,
                                        X_Err_Buff);

                              If X_Err_Code <> 0 then
                                RAISE FND_API.G_EXC_ERROR;
                              End If;

              /* Deleting Items From GMS_EVENT_INTERSECT Table */
                    DELETE_GMS_INTERSECT(F_Expenditure_Item_Id,
                                         F_Award_Project_Id,
                                         F_Event_Num,
					 F_Adl_Line_No,
					 X_Calling_Process,
                                         X_Err_Code,
                                         X_Err_Buff);

                              If X_Err_Code <> 0 then
                                 RAISE FND_API.G_EXC_ERROR;
                              End If;

	           /* Get Event Information */
                GET_EVENT_PROJ_TASK(F_Event_Num,
                                    F_Award_Project_id,
			            F_Expenditure_Item_Id,
                                    X_Actual_Project_Id,
                                    X_Actual_Task_Id,
                                    X_Expenditure_Org_Id,
                                    X_Revenue_Accumulated,
                                    X_Creation_Date,
                                    X_Err_Code,
                                    X_Err_Buff);

            If X_Err_Code <> 0 then
                 RAISE FND_API.G_EXC_ERROR;
            End If;

            If F_Rev_Accumulated ='Y' then

                /* Create negative entry in gms_billing_cancellations
                   for ASI to backout revenue accumulated */
                 INSERT_BILL_CANCEL(F_Award_Project_id,
                                   F_Event_Num,
                                   F_Expenditure_Item_Id,
                                   F_Adl_Line_No,
                                   -1 * F_Raw_Revenue_Amount,
                                   X_Calling_Process,
                                   NULL,                -- burden_exp_type
                                   NULL,                -- burden_cost_code
                                   X_Creation_Date,
                                   X_Actual_Project_Id,
                                   X_Actual_Task_Id,
                                   X_Expenditure_Org_Id,
                                   sysdate,             -- deletion_date
                                   NULL,                -- rlmi
                                   X_Err_Code,
                                   X_Err_Buff);

            	If X_Err_Code <> 0 then
                 	RAISE FND_API.G_EXC_ERROR;
            	End If;

            End if;

       End LOOP;
           CLOSE IDENT_REV_INTRSCT_ITEMS;

                X_Err_Code := 0;

              /* Updating GMS_SUMMARY_PROJECT_FUNDINGS Revenue Accrued Amount */
                   MANIP_BILLREV_AMOUNT(F_Award_Project_id,
				        F_Event_Num,
                                        X_Calling_Process,
                                        X_Err_Code,
                                        X_Err_Buff);

                              If X_Err_Code <> 0 then
                                 RAISE FND_API.G_EXC_ERROR;
                              End If;

	       /* Delete entries from GMS_EVENT_ATTRIBUTE */
               /* Bug 2979125 : added parameter calling_process */
		  DELETE_GMS_EVENT_ATTRIBUTE(F_Award_Project_id,
					     F_Event_Num,
                                             X_Calling_Process,
                                             X_Err_Code,
                                             X_Err_Buff);

                              If X_Err_Code <> 0 then
                                 RAISE FND_API.G_EXC_ERROR;
                              End If;

  End; -- Raw Component Processing

  Elsif (X_Burden_Evt_Flag = 'Y') then----------------------------------------------------
   Begin -- Burden Component Processing

    open BURDEN_REV_INTRSCT_ITEMS;
       LOOP
        FETCH BURDEN_REV_INTRSCT_ITEMS into
        F_Rev_Burd_Expend_Item_Id,
	F_Rev_Adl_Line_No,
        F_Rev_Burd_Intrsct_Amt,
        F_Rev_Actual_Project_Id,
        F_Rev_Actual_Task_Id,
        F_Rev_Burden_Exp_Type,
        F_Rev_Burden_Cost_Code,
        F_Rev_Burd_Exp_Org_Id,
	F_Rev_Creation_Date,
	F_Rev_Revenue_Accumulated,
	F_request_id; -- 4594090
                 EXIT WHEN BURDEN_REV_INTRSCT_ITEMS%NOTFOUND;

		 -- Bug 2477972, Start
		 /* On GMS_AWARD_DISTRIBUTIONS setting the Revenue Accrued Flag to 'N' */
                     UPD_PA_EXP_AND_ADL(F_Award_Project_id,
                                        F_Rev_Burd_Expend_Item_Id,
                                        F_Rev_Adl_Line_No,
                                        X_Calling_Process,
                                        X_Err_Code,
                                        X_Err_Buff);

                     If X_Err_Code <> 0 then
                        RAISE FND_API.G_EXC_ERROR;
                     End If;

		 -- Bug 2477972, end

           /* Deleting items from GMS_BURDEN_COMPONENTS table */

       DELETE_GMS_BURDEN_INTRSCT(F_Rev_Burd_Expend_Item_Id ,
                                 F_Award_Project_Id,
                                 F_Event_Num,
				 F_Rev_Adl_Line_No,
                                 X_Calling_Process,
                                 F_Rev_Burden_Cost_Code,              -- Bug 1193080
                                 X_Err_Code,
                                 X_Err_Buff);

                            If X_Err_Code <> 0 then
                                 RAISE FND_API.G_EXC_ERROR;
                            End If;

            If F_Rev_Revenue_Accumulated ='Y' then

                /* Create negative entry in gms_billing_cancellations
                   for ASI to backout revenue accumulated */
                 INSERT_BILL_CANCEL(F_Award_Project_id,
                                   F_Event_Num,
                                   F_Rev_Burd_Expend_Item_Id,
                                   F_Rev_Adl_Line_No,
                                   -1 * F_Rev_Burd_Intrsct_Amt,
                                   X_Calling_Process,
                                   F_Rev_Burden_Exp_Type,
                                   F_Rev_Burden_Cost_Code,
                                   F_Rev_Creation_Date,
                                   F_Rev_Actual_Project_Id,
                                   F_Rev_Actual_Task_Id,
                                   F_Rev_Burd_Exp_Org_Id,
                                   sysdate,             -- deletion_date
                                   NULL,                -- rlmi
                                   X_Err_Code,
                                   X_Err_Buff);

                If X_Err_Code <> 0 then
                        RAISE FND_API.G_EXC_ERROR;
                End If;

            End if;

       END LOOP;

    close BURDEN_REV_INTRSCT_ITEMS;

              /* Updating GMS_SUMMARY_PROJECT_FUNDINGS Revenue Accrued Amount */
                   MANIP_BILLREV_AMOUNT(F_Award_Project_id,
				        F_Event_Num,
                                        X_Calling_Process,
                                        X_Err_Code,
                                        X_Err_Buff);

                              If X_Err_Code <> 0 then
                                 RAISE FND_API.G_EXC_ERROR;
                              End If;

	       /* Delete entries from GMS_EVENT_ATTRIBUTE */
               /* Bug 2979125 : added parameter calling_process */
		  DELETE_GMS_EVENT_ATTRIBUTE(F_Award_Project_id,
					     F_Event_Num,
                                             X_Calling_Process,
                                             X_Err_Code,
                                             X_Err_Buff);

                              If X_Err_Code <> 0 then
                                 RAISE FND_API.G_EXC_ERROR;
                              End If;

    End; -- Burden Component Processing


  End If;
----------------------------------------------------------------------------------------------
/*   -- Handle net zero events .... (4594090)
  HANDLE_NET_ZERO_EVENTS (P_AWARD_PROJECT_ID => F_Award_Project_id,
                          P_REQUEST_ID       => F_request_id,
                          P_CALLING_PROCESS  => 'REVENUE');
Changing this call to the End of the procedure for perfomance reasons. bug 5060427 */
----------------------------------------------------------------------------------------------
 Elsif (X_Event_Type_Class = 'MANUAL') then
    Begin

              /* Updating GMS_SUMMARY_PROJECT_FUNDINGS Revenue Accrued Amount */
                   MANIP_BILLREV_AMOUNT(F_Award_Project_id,
				        F_Event_Num,
                                        X_Calling_Process,
                                        X_Err_Code,
                                        X_Err_Buff);

            If X_Err_Code <> 0 then
                 RAISE FND_API.G_EXC_ERROR;
            End If;

	   /* Get Event Information */
	        GET_EVENT_PROJ_TASK(F_Event_Num,
				    F_Award_Project_id,
				    NULL,
				    X_Actual_Project_Id,
				    X_Actual_Task_Id,
				    X_Expenditure_Org_Id,
                                    X_Revenue_Accumulated,
                                    X_Creation_Date,
                                    X_Err_Code,
                                    X_Err_Buff);

            If X_Err_Code <> 0 then
                 RAISE FND_API.G_EXC_ERROR;
            End If;

	    If X_Revenue_Accumulated ='Y' then

		/* Create negative entry in gms_billing_cancellations
		   for ASI to backout revenue accumulated */
		INSERT_BILL_CANCEL(F_Award_Project_id,
				   F_Event_Num,
				   NULL,                -- expenditure_id
				   NULL, 		-- adl_line_num
				   -1 * F_amount, 	-- negative entry
				   X_Calling_Process,
				   NULL,  		-- burden_exp_type
				   NULL,  		-- burden_cost_code
				   X_Creation_Date,
				   X_Actual_Project_Id,
				   X_Actual_Task_Id,
				   X_Expenditure_Org_Id,
				   sysdate, 		-- deletion_date
				   NULL,		-- rlmi
                                   X_Err_Code,
                                   X_Err_Buff);

            	If X_Err_Code <> 0 then
                 	RAISE FND_API.G_EXC_ERROR;
            	End If;

	    End if;
    End;

 End If; -- End of If for Event_Type_Classification('Manual' or 'Automatic')

 End LOOP;
         CLOSE GET_REV_ITEMS_RDL;
            X_Err_Code := 0;

-- Handle net zero events .... (4594090)
-- Moved this call from an earlier point to here for bug 5060427
  HANDLE_NET_ZERO_EVENTS (P_AWARD_PROJECT_ID => F_Award_Project_id,
                          P_REQUEST_ID       => F_request_id,
                          P_CALLING_PROCESS  => 'REVENUE');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
           ROLLBACK;
              RETURN;
End  DO_REV_ITEM_PROCESSING;


Procedure PERFORM_REV_BILL_ADJS(X_Adj_Action                     IN VARCHAR2,
                                X_calling_process                IN VARCHAR2,
                                X_Award_Project_Id               IN NUMBER   DEFAULT NULL,
                                X_Draft_Invoice_Num              IN NUMBER   DEFAULT NULL,
			        X_Start_Award_Project_Number     IN VARCHAR2 DEFAULT NULL,
			        X_End_Award_Project_Number       IN VARCHAR2 DEFAULT NULL,
			        X_Mass_Gen_Flag                  IN VARCHAR2 DEFAULT NULL,
                                X_Adj_Amount                     IN NUMBER DEFAULT NULL,
                                RETCODE                          OUT NOCOPY VARCHAR2,
                                ERRBUF                           OUT NOCOPY VARCHAR2) IS

-- X_Adj_Amount Uncommented out NOCOPY to pass Write Off Amount

X_Err_Code NUMBER(1);
X_Err_Buff VARCHAR2(2000);

X_Award_Number VARCHAR2(25);


/*=======================NOT NEEDED FOR R11 .PA will pass the Project Id For Revenue Deletion======
--Cursor to Select Projects which could have potential revenues to be
--deleted

CURSOR GET_TO_BE_DEL_REV_PROJECTS IS
SELECT p.project_id, p.segment1, p.project_level_funding_flag
        FROM pa_projects p, pa_draft_revenues r
       WHERE p.segment1 BETWEEN X_Start_Award_Project_Number
             AND X_End_Award_Project_Number
         AND r.project_id = p.project_id
         AND r.released_date||'' is null
         AND r.generation_error_flag||'' = 'Y'
      GROUP BY p.project_id, p.segment1, p.project_level_funding_flag;

X_Rev_Project_Id                  NUMBER(15);
X_Rev_Segment1                    VARCHAR2(30);
X_Rev_Proj_Level_Fund_Flag        VARCHAR2(1);
====================================================================================*/

/* Cursor to Select Revenues that could be potentially deleted for a Project */
 CURSOR GET_TO_BE_DEL_REVENUES(X_Project_Id NUMBER) IS
 SELECT
    draft_revenue_num
  , agreement_id
     FROM
 PA_BILLING_REV_DELETION_V 	--View Made available from R11
 WHERE PROJECT_ID = X_Project_Id
 FOR UPDATE NOWAIT;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/* The code below is used only in 10.7 */
--pa_draft_revenues r
-- WHERE r.project_id = X_Project_Id
--      AND (    r.released_date||'' is NULL
--               AND X_Mass_Gen_Flag = 'N'
--            OR     r.generation_error_flag||'' = 'Y'
--               AND X_Mass_Gen_Flag = 'Y'
--          )
-- FOR UPDATE NOWAIT;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++

X_Draft_Revenue_Num   NUMBER(15);
X_Rev_Agreement_Id    NUMBER(15);

/* Cursor to Select Invoices that could be deleted as a result of unreleased revenues being
   deleted. This should not be applicable in the case of GMS where separete events are
   created for Revenue and Invoices hence won't be used */
/*---------------------------------------------------------------------+
CURSOR GET_REV_REL_DEL_INVOICES IS					|
SELECT 									|
di.draft_invoice_num							|
    FROM pa_draft_invoices di  						|
    WHERE di.project_id = :project_id 					|
      AND di.agreement_id+0 = :agreement_id				|
      AND di.released_date||'' is null					|
      AND (EXISTS							|
               (SELECT NULL						|
                  FROM pa_cust_rev_dist_lines l				|
                 WHERE l.project_id = :project_id			|
                   AND l.draft_revenue_num = :draft_revenue_num		|
                   AND l.draft_invoice_num = di.draft_invoice_num)	|
             OR								|
           EXISTS							|
               (SELECT NULL						|
                  FROM pa_cust_event_rev_dist_lines l			|
                 WHERE l.project_id = :project_id			|
                   AND l.draft_revenue_num = :draft_revenue_num		|
                   AND l.draft_invoice_num = di.draft_invoice_num)	|
          );								|
									|
X_Rev_Draft_Invoice_Num  NUMBER(15);           				|
------------------------------------------------------------------------*/



/* Cursor to Select Draft Invoices which could be deleted for a particular
   Project */
CURSOR GET_DRAFT_INVOICES is
Select
draft_invoice_num
from
PA_BILLING_INV_DELETION_V --View made available in R11
WHERE PROJECT_ID = X_Award_Project_Id
FOR UPDATE NOWAIT;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--The code below is used only in 10.7 as the view above is not available
pa_draft_invoices I,
pa_projects       P
where     I.project_id  = X_Award_Project_Id
AND       P.project_id  = I.project_id
AND       I.Released_By_Person_Id IS NULL
AND       nvl(I.CANCEL_CREDIT_MEMO_FLAG, 'N') = 'N'
ORDER BY I.Draft_Invoice_Num
FOR UPDATE NOWAIT;
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

F_Draft_Invoice_Num   NUMBER(15);

ROW_LOCKED  EXCEPTION;
PRAGMA EXCEPTION_INIT(ROW_LOCKED,-00054);
X_Locked_Row     NUMBER;

Begin

 fnd_msg_pub.initialize;

If X_Award_Project_Id is NOT NULL THEN
 Begin
   select award_number into
   X_Award_Number from gms_awards
   where award_project_id = X_Award_Project_Id;
 End;
End If;


If X_Calling_Process = 'Invoice' then -- BEGIN OF IF FOR CALLING PROCESS

/*-------------------Processing Begins for Invoice Adjustments--------------------------*/

Begin
If X_Adj_Action = 'CANCEL' then
  Begin
    If X_Draft_Invoice_Num is NULL then
      gms_error_pkg.gms_message('GMS_DRAFT_INV_NUM_NULL',
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      RETCODE := 'E';
      RAISE_APPLICATION_ERROR(-20221,X_Err_Buff);
      --RAISE FND_API.G_EXC_ERROR;
      RETURN;
    Else

      /* Lock the Invoice Row so that another process doesn't use it */
       Begin
          Select
          draft_invoice_num
          into
          X_Locked_Row
          from
          pa_draft_invoices
          where
           draft_invoice_num = X_Draft_Invoice_Num
          and project_id        = X_Award_Project_Id
          FOR UPDATE NOWAIT;
       EXCEPTION
         WHEN ROW_LOCKED THEN
           gms_error_pkg.gms_message('GMS_INV_FOR_CANCEL_LOCKED',
				'INVOICE_NUM',
				X_Draft_Invoice_Num,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
  	   RETCODE := 'E';
           --RAISE_APPLICATION_ERROR(-20222,X_Err_Buff);
                 /* pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '3 - CANINV'
                                          ,x_message => 'GMS_INV_FOR_CANCEL_LOCKED'
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status); */

           RETURN;
         WHEN OTHERS THEN
           RETCODE := 'U';
           gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
           --RAISE_APPLICATION_ERROR(-20223,X_Err_Buff);
                /* pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '4 - CANINV'
                                          ,x_message => SQLCODE||' - '||SQLERRM
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status); */

           RETURN;
      End;

       F_Draft_Invoice_Num := X_Draft_Invoice_Num;

        DO_INV_ITEM_PROCESSING(X_Award_Project_Id,
				F_Draft_Invoice_Num,
                                'CANCEL',
                                NULL, --X_Adj_Amount,
                                X_Calling_Process,
                                X_Err_Code,
                                X_Err_Buff);

               If X_Err_Code <> 0 then
                  RAISE FND_API.G_EXC_ERROR;
               End If;
    End If;
 End;

Elsif X_Adj_Action = 'DELETE' then
 Begin
    open GET_DRAFT_INVOICES;
     LOOP

      Begin

        SAVEPOINT NEXT_INVOICE;

      FETCH GET_DRAFT_INVOICES into
      F_Draft_Invoice_Num;
        EXIT WHEN GET_DRAFT_INVOICES%NOTFOUND;

        DO_INV_ITEM_PROCESSING(X_Award_Project_Id,
                                F_Draft_Invoice_Num,
                                'DELETE',
                                NULL,--X_Adj_Amount,
                                X_Calling_Process,
                                X_Err_Code,
                                X_Err_Buff);
               If X_Err_Code <> 0 then
                  RAISE FND_API.G_EXC_ERROR;
               End If;
           EXCEPTION
             WHEN ROW_LOCKED THEN
               ROLLBACK to NEXT_INVOICE;
             WHEN OTHERS THEN
               ROLLBACK to NEXT_INVOICE;
     End;

    End LOOP;
        CLOSE GET_DRAFT_INVOICES;
 End;

Elsif X_Adj_Action = 'WRITE_OFF' THEN

      /* Lock the Invoice Row so that another process doesn't use it */
       Begin
          Select
          draft_invoice_num
          into
          X_Locked_Row
          from
          pa_draft_invoices
          where
           draft_invoice_num = X_Draft_Invoice_Num
          and project_id     = X_Award_Project_Id
          FOR UPDATE NOWAIT;
       EXCEPTION
          WHEN ROW_LOCKED THEN
 	    RETCODE := 'E';
            gms_error_pkg.gms_message('GMS_INV_FOR_WRITE_OFF_LOCK',
				'INVOICE_NUM',
				X_Draft_Invoice_Num,
				'AWARD_NUMBER',
				X_Award_Number,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
            --RAISE_APPLICATION_ERROR(-20224,X_Err_Buff);
            RETURN;
          WHEN OTHERS THEN
            RETCODE := 'U';
            gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
            --RAISE_APPLICATION_ERROR(-20225,X_Err_Buff);
            RETURN;
      End;
 Begin

   If (X_Draft_Invoice_Num is NULL ) then
          RAISE FND_API.G_EXC_ERROR;
   Else

      F_Draft_Invoice_Num := X_Draft_Invoice_Num;

        DO_INV_ITEM_PROCESSING(X_Award_Project_Id,
                                F_Draft_Invoice_Num,
                                'WRITE_OFF',
                                X_Adj_Amount,
                                X_Calling_Process,
                                X_Err_Code,
                                X_Err_Buff);

/*        pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '6 - WRIINV'
                                          ,x_message => '6 - After DO_INV_ITEM '||X_Err_Code||' '||X_Err_Buff
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status);

*/
               If X_Err_Code <> 0 then
                  RAISE FND_API.G_EXC_ERROR;
               End If;
   End If;
 End;
End If;

End;

/*--------------------Processing Ends for Invoice Adjustments----------------------*/

Elsif X_Calling_Process = 'Revenue' then

/*--------------------Processing Begins for Revenue Adjustments--------------------*/
 If X_Adj_Action = 'DELETE' then
 Begin


  If X_Mass_Gen_Flag = 'Y' then
   Begin
 /*=========================================Commented out NOCOPY for R11=========================
--Commented out NOCOPY for R11 as PA will run the extension in a loop for all potential projects
--So the code to actually fetch the projects which will have potential revenues to be deleted
--is not necessary
    OPEN GET_TO_BE_DEL_REV_PROJECTS;
     LOOP
      FETCH GET_TO_BE_DEL_REV_PROJECTS into
      X_Rev_Project_Id,
      X_Rev_Segment1,
      X_Rev_Proj_Level_Fund_Flag;
         EXIT WHEN GET_TO_BE_DEL_REV_PROJECTS%NOTFOUND;

======================================================================================*/

        OPEN GET_TO_BE_DEL_REVENUES(X_Award_Project_Id);
         LOOP
          Begin

             SAVEPOINT NEXT_REVENUE;

          FETCH GET_TO_BE_DEL_REVENUES into
          X_Draft_Revenue_Num,
          X_Rev_Agreement_Id;
            EXIT WHEN GET_TO_BE_DEL_REVENUES%NOTFOUND;

  		DO_REV_ITEM_PROCESSING(X_Award_Project_Id,
				       X_Draft_Revenue_Num,
				       X_Calling_Process,
				       X_Err_Code,
				       X_Err_Buff);

                         If X_Err_Code <> 0 then
                            RAISE FND_API.G_EXC_ERROR;
                         End If;
               EXCEPTION
                    WHEN ROW_LOCKED THEN
                        ROLLBACK to NEXT_REVENUE;
                    WHEN OTHERS THEN
                        ROLLBACK to NEXT_REVENUE;
          End;
         End LOOP;
            CLOSE GET_TO_BE_DEL_REVENUES;
                 X_Err_Code := 0;
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--The code below  is commented out NOCOPY for R11 as PA individually passed the Project Id to
-- the extension.
     End LOOP;
    --   dbms_output.put_line('After Loop for GET_TO_BE_DEL_REV_PROJECTS');
          CLOSE GET_TO_BE_DEL_REV_PROJECTS;
               X_Err_Code := 'S';
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
   End;
  Elsif X_Mass_Gen_Flag = 'N' then
   Begin
     OPEN GET_TO_BE_DEL_REVENUES(X_Award_Project_Id);

      LOOP
       FETCH GET_TO_BE_DEL_REVENUES into
       X_Draft_Revenue_Num,
       X_Rev_Agreement_Id;

          EXIT WHEN GET_TO_BE_DEL_REVENUES%NOTFOUND;

  		DO_REV_ITEM_PROCESSING(X_Award_Project_Id,
				       X_Draft_Revenue_Num,
				       X_Calling_Process,
				       X_Err_Code,
				       X_Err_Buff);

                         If X_Err_Code <> 0 then
                            RAISE FND_API.G_EXC_ERROR;
                         End If;
      End LOOP;
	 CLOSE GET_TO_BE_DEL_REVENUES;
           X_Err_Code := 0;
   End;
  End If;

 End;
 End If;
/*--------------------Processing Ends for Revenue Adjustments----------------------*/


End If; -- END OF CHECK FOR X_CALLING_PROCESS( INVOICE OR REVENUE)

     RETCODE := 'S';

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       RETCODE := 'E';
       ERRBUF  := X_Err_Buff;
       ROLLBACK;
       RETURN;

End PERFORM_REV_BILL_ADJS;


Procedure DELINV(X_project_id           IN NUMBER,
                 X_top_Task_id          IN NUMBER DEFAULT NULL,
                 X_calling_process      IN VARCHAR2 DEFAULT NULL,
                 X_calling_place        IN VARCHAR2 DEFAULT NULL,
                 X_amount               IN NUMBER DEFAULT NULL,
                 X_percentage           IN NUMBER DEFAULT NULL,
                 X_rev_or_bill_date     IN DATE DEFAULT NULL,
                 X_bill_extn_assignment_id IN NUMBER DEFAULT NULL,
                 X_bill_extension_id    IN NUMBER DEFAULT NULL,
                 X_request_id           IN NUMBER DEFAULT NULL) IS
X_retcode VARCHAR2(1);
X_errbuf VARCHAR2(2000);

Begin

  gms_error_pkg.set_debug_context; -- Added for Bug: 2510024

  IF L_DEBUG = 'Y' THEN
  	gms_error_pkg.gms_debug('DELINV - Start GMS process for Invoice Deletion','C');
  END IF;
/* GMS INSTALLATION CHECK */
If gms_install.enabled then

 GMS_BILLING_ADJUSTMENTS.PERFORM_REV_BILL_ADJS('DELETE',
                                               'Invoice',
                                               X_project_id,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               X_retcode,
                                               X_errbuf);
 If X_retcode <> 'S' then
        /* pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => 'GMS_BILLING_ADJUSTMENTS.DELINV'
                                          ,x_message => X_errbuf
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status); */
        RAISE_APPLICATION_ERROR(-20226,X_errbuf);

 End If;

End if;
  IF L_DEBUG = 'Y' THEN
  	gms_error_pkg.gms_debug('DELINV - End GMS process for Invoice Deletion','C');
  END IF;

End DELINV;

Procedure CANINV(X_project_id           IN NUMBER,
                 X_top_Task_id          IN NUMBER DEFAULT NULL,
                 X_calling_process      IN VARCHAR2 DEFAULT NULL,
                 X_calling_place        IN VARCHAR2 DEFAULT NULL,
                 X_amount               IN NUMBER DEFAULT NULL,
                 X_percentage           IN NUMBER DEFAULT NULL,
                 X_rev_or_bill_date     IN DATE DEFAULT NULL,
                 X_bill_extn_assignment_id IN NUMBER DEFAULT NULL,
                 X_bill_extension_id    IN NUMBER DEFAULT NULL,
                 X_request_id           IN NUMBER DEFAULT NULL) IS

X_retcode VARCHAR2(1);
X_errbuf VARCHAR2(2000);

X_Draft_Invoice_Num_Credited  NUMBER;

X_Err_Code NUMBER(1);
X_Err_Buff VARCHAR2(2000);

Begin

  gms_error_pkg.set_debug_context; -- Added for Bug: 2510024

  IF L_DEBUG = 'Y' THEN
  	gms_error_pkg.gms_debug('CANINV - Start GMS process for Invoice Cancellation','C');
  END IF;

/* GMS INSTALLATION CHECK */
If gms_install.enabled then

  Begin
   select
   b.DRAFT_INVOICE_NUM_CREDITED
   into
   X_Draft_Invoice_Num_Credited
   from
   PA_BILLING_INV_PROCESSED_V a
  ,PA_DRAFT_INVOICES b
   where a.project_id = X_project_id
   and   b.project_id = a.project_id
   and   b.draft_invoice_num = a.draft_invoice_num;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      gms_error_pkg.gms_message('GMS_NO_INV_FOR_CANCEL',
				'PRJ',
				X_Project_Id,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
/*             pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '1 - CANINV'
                                          ,x_message => 'No Invoice found for Cancellation'
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status); */
             RAISE_APPLICATION_ERROR(-20027,X_Err_Buff);
  End;

  GMS_BILLING_ADJUSTMENTS.PERFORM_REV_BILL_ADJS('CANCEL',
                                                   'Invoice',
                                                    X_project_id,
                                                    X_Draft_Invoice_Num_Credited,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    X_retcode,
                                                    X_errbuf);

/*  pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => 'GMS_BILLING_ADJUSTMENTS.CANINV'
                                          ,x_message => 'Retcode is '||X_retcode
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status);
*/
  If X_retcode <> 'S' then

 /*   pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => 'GMS_BILLING_ADJUSTMENTS.CANINV'
                                          ,x_message => X_Errbuf
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status); */
    RAISE_APPLICATION_ERROR(-20228,X_Errbuf);
  End If;

End if;
  IF L_DEBUG = 'Y' THEN
  	gms_error_pkg.gms_debug('CANINV - End GMS process for Invoice Cancellation','C');
  END IF;
End CANINV;


Procedure WRIINV(X_project_id        IN NUMBER,
                 X_top_Task_id          IN NUMBER DEFAULT NULL,
                 X_calling_process      IN VARCHAR2 DEFAULT NULL,
                 X_calling_place        IN VARCHAR2 DEFAULT NULL,
                 X_amount               IN NUMBER DEFAULT NULL,
                 X_percentage           IN NUMBER DEFAULT NULL,
                 X_rev_or_bill_date     IN DATE DEFAULT NULL,
                 X_bill_extn_assignment_id IN NUMBER DEFAULT NULL,
                 X_bill_extension_id    IN NUMBER DEFAULT NULL,
                 X_request_id           IN NUMBER DEFAULT NULL) IS

X_retcode VARCHAR2(1);
X_errbuf VARCHAR2(2000);
X_Draft_Invoice_Num_Credited  NUMBER;
X_Err_Msg VARCHAR2(2000);
X_status NUMBER;
X_Err_Code NUMBER(1);
X_Err_Buff VARCHAR2(2000);

Begin

  gms_error_pkg.set_debug_context; -- Added for Bug: 2510024

/* GMS INSTALLATION CHECK */
If gms_install.enabled then

  Begin

   select draft_invoice_num_credited
   into   X_Draft_Invoice_Num_Credited
   from   pa_draft_invoices_all
   where  project_id = X_project_id
   and    request_id = X_request_id
   and    (nvl(write_off_flag,'N') = 'Y' OR
           nvl(concession_flag,'N') = 'Y');

   g_request_id := X_request_id;

     GMS_BILLING_ADJUSTMENTS.PERFORM_REV_BILL_ADJS('WRITE_OFF',
                                               'Invoice',
                                               X_project_id,
                                               X_Draft_Invoice_Num_Credited,
                                               NULL,
                                               NULL,
                                               NULL,
					       NULL,
                                               X_retcode,
                                               X_errbuf);

     /* pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '7 - WRIINV'
                                          ,x_message => 'AFTER ADJUSTMENTS Retcode '||x_retcode||' '||X_errbuf
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status); */

     If X_retcode <> 'S' then
         /* pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '8 - WRIINV'
                                          ,x_message => 'Failure '
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status); */

         RAISE_APPLICATION_ERROR(-20230,X_errbuf);

     End If;
   EXCEPTION
     WHEN OTHERS  THEN
 /*       pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => '9 - WRIINV'
                                          ,x_message => 'Failure - When Others'
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status);
*/
      gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
				'SQLCODE',
			        SQLCODE,
				'SQLERRM',
				SQLERRM,
				X_Exec_Type => 'C',
				X_Err_Code => X_Err_Code,
				X_Err_Buff => X_Err_Buff);
      RAISE_APPLICATION_ERROR(-20231,X_Err_Buff);
   End;

End if;

End WRIINV;


Procedure DELREV(X_project_id          IN NUMBER,
                 X_top_Task_id          IN NUMBER DEFAULT NULL,
                 X_calling_process      IN VARCHAR2 DEFAULT NULL,
                 X_calling_place        IN VARCHAR2 DEFAULT NULL,
                 X_amount               IN NUMBER DEFAULT NULL,
                 X_percentage           IN NUMBER DEFAULT NULL,
                 X_rev_or_bill_date     IN DATE DEFAULT NULL,
                 X_bill_extn_assignment_id IN NUMBER DEFAULT NULL,
                 X_bill_extension_id    IN NUMBER DEFAULT NULL,
                 X_request_id           IN NUMBER DEFAULT NULL) IS

X_retcode VARCHAR2(1);
X_errbuf VARCHAR2(2000);

X_Err_Msg VARCHAR2(2000);
X_Status NUMBER;
X_Err_Code NUMBER(1);
X_Err_Buff VARCHAR2(2000);

Begin

  gms_error_pkg.set_debug_context; -- Added for Bug: 2510024

  IF L_DEBUG = 'Y' THEN
  	gms_error_pkg.gms_debug('DELREV - Start GMS process for Revenue Deletion','C');
  END IF;

/* GMS INSTALLATION CHECK */
If gms_install.enabled then

 GMS_BILLING_ADJUSTMENTS.PERFORM_REV_BILL_ADJS('DELETE',
                                               'Revenue',
                                               X_project_id,
                                               NULL,
                                               NULL,
                                               NULL,
                                               'N',
					       NULL,
                                               X_retcode,
                                               X_errbuf);
 If X_retcode <> 'S' then
 /*   pa_billing_pub.insert_message(X_INSERTING_PROCEDURE_NAME => 'GMS_BILLING_ADJUSTMENTS.DELREV'
                                          ,x_message => X_errbuf
                                          ,x_error_message => X_Err_Msg
                                          ,x_status => X_Status);
*/
    RAISE_APPLICATION_ERROR(-20232,X_errbuf);

 End If;

End if;
  IF L_DEBUG = 'Y' THEN
  	gms_error_pkg.gms_debug('DELREV - End GMS process for Revenue Deletion','C');
  END IF;

End DELREV;

End GMS_BILLING_ADJUSTMENTS;

/
