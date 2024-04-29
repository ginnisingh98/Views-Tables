--------------------------------------------------------
--  DDL for Package Body PA_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_EVENTS_PKG" as
/* $Header: PAXPREVB.pls 120.2 2007/02/07 10:45:13 rgandhi ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Event_Id                IN OUT NOCOPY NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Event_Num                      NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Event_Type                     VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Bill_Amount                    NUMBER,
                       X_Revenue_Amount                 NUMBER,
                       X_Revenue_Distributed_Flag       VARCHAR2,
		       X_Zero_Revenue_Amount_Flag       VARCHAR2 DEFAULT 'N',
                       X_Bill_Hold_Flag                 VARCHAR2,
                       X_Completion_Date                DATE,
                       X_Rev_Dist_Rejection_Code        VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Project_Id                     NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Billing_Assignment_Id          NUMBER,
                       X_Event_Num_Reversed             NUMBER,
                       X_Calling_Place                  VARCHAR2,
                       X_Calling_Process                VARCHAR2,
                       X_Bill_Trans_Currency_Code       VARCHAR2,/* All the 36 columns from here is added for MCB2 */
                       X_Bill_Trans_Bill_Amount         NUMBER,
                       X_Bill_Trans_rev_Amount          NUMBER,
                       X_Project_Currency_Code          VARCHAR2,
                       X_Project_Rate_Type              VARCHAR2,
                       X_Project_Rate_Date              DATE,
                       X_Project_Exchange_Rate          NUMBER,
                       X_Project_Inv_Rate_Date          DATE,
                       X_Project_Inv_Exchange_Rate      NUMBER,
                       X_Project_Bill_Amount            NUMBER,
                       X_Project_Rev_Rate_Date          DATE,
                       X_Project_Rev_Exchange_Rate      NUMBER,
                       X_Project_Revenue_Amount         NUMBER,
                       X_ProjFunc_Currency_Code         VARCHAR2,
                       X_ProjFunc_Rate_Type             VARCHAR2,
                       X_ProjFunc_Rate_Date             DATE,
                       X_ProjFunc_Exchange_Rate         NUMBER,
                       X_ProjFunc_Inv_Rate_Date         DATE,
                       X_ProjFunc_Inv_Exchange_Rate     NUMBER,
                       X_ProjFunc_Bill_Amount           NUMBER,
                       X_ProjFunc_Rev_Rate_Date         DATE,
                       X_Projfunc_Rev_Exchange_Rate     NUMBER,
                       X_ProjFunc_Revenue_Amount        NUMBER,
                       X_Funding_Rate_Type              VARCHAR2,
                       X_Funding_Rate_Date              DATE,
                       X_Funding_Exchange_Rate          NUMBER,
                       X_Invproc_Currency_Code          VARCHAR2,
                       X_Invproc_Rate_Type              VARCHAR2,
                       X_Invproc_Rate_Date              DATE,
                       X_Invproc_Exchange_Rate          NUMBER,
                       X_Revproc_Currency_Code          VARCHAR2,
                       X_Revproc_Rate_Type              VARCHAR2,
                       X_Revproc_Rate_Date              DATE,
                       X_Revproc_Exchange_Rate          NUMBER,
                       X_Inv_Gen_Rejection_Code         VARCHAR2,
                       X_Adjusting_Revenue_Flag         VARCHAR2 DEFAULT 'N',  /* Added default for Bug 2483089 - For Bug 2261314 */
                       X_non_updateable_flag            VARCHAR2  DEFAULT 'N',
                       X_revenue_hold_flag              VARCHAR2  DEFAULT 'N',
                       X_project_funding_id             NUMBER    DEFAULT NULL,
		--Start of changes for events amg
                       X_product_code                   VARCHAR2 DEFAULT NULL,
                       X_event_reference                VARCHAR2 DEFAULT NULL,
                       X_inventory_org_id               NUMBER   DEFAULT NULL,
                       X_inventory_item_id              NUMBER   DEFAULT NULL,
                       X_quantity_billed                NUMBER     DEFAULT NULL,
			X_uom_code			VARCHAR2   DEFAULT NULL,
			X_unit_price			NUMBER	   DEFAULT NULL,
                        X_reference1                    VARCHAR2   DEFAULT NULL,
                        X_reference2                    VARCHAR2   DEFAULT NULL,
                        X_reference3                    VARCHAR2   DEFAULT NULL,
                        X_reference4                    VARCHAR2   DEFAULT NULL,
                        X_reference5                    VARCHAR2   DEFAULT NULL,
                        X_reference6                    VARCHAR2   DEFAULT NULL,
                        X_reference7                    VARCHAR2   DEFAULT NULL,
                        X_reference8                    VARCHAR2   DEFAULT NULL,
                        X_reference9                    VARCHAR2   DEFAULT NULL,
                        X_reference10                   VARCHAR2   DEFAULT NULL,
                        X_Deliverable_Id                NUMBER     DEFAULT NULL,
                        X_Action_Id                     NUMBER     DEFAULT NULL,
                        X_Record_Version_Number         NUMBER     DEFAULT NULL,
		--End of changes for events amg
                        X_Agreement_ID                  NUMBER     DEFAULT NULL   -- Federal Uptake
  ) IS
    CURSOR C IS SELECT rowid FROM PA_EVENTS
                 WHERE project_id = X_Project_Id
                 AND   (    (task_id = X_Task_Id)
                        or (task_id is NULL and X_Task_Id is NULL))
                 AND   event_num = X_Event_Num;
    CURSOR C2 IS SELECT pa_events_s.nextval FROM sys.dual;

   BEGIN
       if (X_Event_Id is NULL) then
         OPEN C2;
         FETCH C2 INTO X_Event_Id;
         CLOSE C2;
       end if;


       INSERT INTO PA_EVENTS(

              event_id,
              task_id,
              event_num,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              event_type,
              description,
              bill_amount,
              revenue_amount,
              revenue_distributed_flag,
	      Zero_Revenue_Amount_Flag,
              bill_hold_flag,
              completion_date,
              rev_dist_rejection_code,
              attribute_category,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              project_id,
              organization_id,
              billing_assignment_id,
              event_num_reversed,
              calling_place,
              calling_process,
              bill_trans_currency_code,   /* All the 36 columns from here is added for MCB2 */
              bill_trans_bill_amount,
              bill_trans_rev_amount,
              project_currency_code,
              project_rate_type,
              project_rate_date,
              project_exchange_rate,
              project_inv_rate_date,
              project_inv_exchange_rate,
              project_bill_amount,
              project_rev_rate_date,
              project_rev_exchange_rate,
              project_revenue_amount,
              projfunc_currency_code,
              projfunc_rate_type,
              projfunc_rate_date,
              projfunc_exchange_rate,
              projfunc_inv_rate_date,
              projfunc_inv_exchange_rate,
              projfunc_bill_amount,
              projfunc_rev_rate_date,
              projfunc_rev_exchange_rate,
              projfunc_revenue_amount,
              funding_rate_type,
              funding_rate_date,
              funding_exchange_rate,
              invproc_currency_code,
              invproc_rate_type,
              invproc_rate_date,
              invproc_exchange_rate,
              revproc_currency_code,
              revproc_rate_type,
              revproc_rate_date,
              revproc_exchange_rate,
              inv_gen_rejection_code,
              adjusting_revenue_flag,  /* For Bug 2261314 */
              non_updateable_flag,
              revenue_hold_flag,
              project_funding_id,
	--Start of changes for events amg
              pm_product_code,
              pm_event_reference,
              inventory_org_id,
              inventory_item_id,
                quantity_billed,
                uom_code,
                unit_price,
                reference1,
                reference2,
                reference3,
                reference4,
                reference5,
                reference6,
                reference7,
                reference8,
                reference9,
                reference10,
                deliverable_id,
                action_id,
                record_version_number,

        --End of changes for events amg.
                agreement_id  -- Federal Uptake

             ) VALUES (

              X_Event_Id,
              X_Task_Id,
              X_Event_Num,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Event_Type,
              X_Description,
              X_Bill_Amount,
              X_Revenue_Amount,
              X_Revenue_Distributed_Flag,
	      X_Zero_Revenue_Amount_Flag,
              X_Bill_Hold_Flag,
              X_Completion_Date,
              X_Rev_Dist_Rejection_Code,
              X_Attribute_Category,
              X_Attribute1,
              X_Attribute2,
              X_Attribute3,
              X_Attribute4,
              X_Attribute5,
              X_Attribute6,
              X_Attribute7,
              X_Attribute8,
              X_Attribute9,
              X_Attribute10,
              X_Project_Id,
              X_Organization_Id,
              X_Billing_Assignment_Id,
              X_Event_Num_Reversed,
              X_Calling_Place,
              X_Calling_Process,
              X_Bill_Trans_Currency_Code,/* All the 36 columns from here is added for MCB2 */
              X_Bill_Trans_Bill_Amount,
              X_Bill_Trans_rev_Amount,
              X_Project_Currency_Code,
              X_Project_Rate_Type,
              X_Project_Rate_Date,
              X_Project_Exchange_Rate,
              X_Project_Inv_Rate_Date,
              X_Project_Inv_Exchange_Rate,
              X_Project_Bill_Amount,
              X_Project_Rev_Rate_Date,
              X_Project_Rev_Exchange_Rate,
              X_Project_Revenue_Amount,
              X_ProjFunc_Currency_Code,
              X_ProjFunc_Rate_Type,
              X_ProjFunc_Rate_Date,
              X_ProjFunc_Exchange_Rate,
              X_ProjFunc_Inv_Rate_Date,
              X_ProjFunc_Inv_Exchange_Rate,
              X_ProjFunc_Bill_Amount,
              X_Projfunc_Rev_Rate_Date,
              X_Projfunc_Rev_Exchange_Rate,
              X_ProjFunc_Revenue_Amount,
              X_Funding_Rate_Type,
              X_Funding_Rate_Date,
              X_Funding_Exchange_Rate,
              X_Invproc_Currency_Code,
              X_Invproc_Rate_Type,
              X_Invproc_Rate_Date,
              X_Invproc_Exchange_Rate,
              X_Revproc_Currency_Code,
              X_Revproc_Rate_Type,
              X_Revproc_Rate_Date,
              X_Revproc_Exchange_Rate,
              X_Inv_Gen_Rejection_Code,
              X_Adjusting_Revenue_Flag,         /* For Bug 2261314 */
              X_non_updateable_flag,
              X_revenue_hold_flag,
              X_project_funding_id,
	--Start of changes for events amg
              X_product_code,
              X_event_reference,
              X_inventory_org_id,
              X_inventory_item_id,
		X_quantity_billed,
		X_uom_code,
		X_unit_price,
		X_reference1,
		X_reference2,
		X_reference3,
		X_reference4,
		X_reference5,
		X_reference6,
		X_reference7,
		X_reference8,
		X_reference9,
		X_reference10,
		X_Deliverable_Id,
		X_Action_Id,
		X_Record_Version_Number,

	--End of changes for events amg
                X_Agreement_ID  --Federal Uptake
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
 /* Added the below for NOCOPY mandate */
  EXCEPTION WHEN OTHERS THEN
   X_Rowid := NULL;
   X_Event_Id := NULL;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
		     X_Event_Id			        NUMBER,
                     X_Task_Id                          NUMBER,
                     X_Event_Num                        NUMBER,
                     X_Event_Type                       VARCHAR2,
                     X_Description                      VARCHAR2,
                     X_Bill_Amount                      NUMBER,
                     X_Revenue_Amount                   NUMBER,
                     X_Revenue_Distributed_Flag         VARCHAR2,
		     --X_Zero_Revenue_Amount_Flag         VARCHAR2,
                     X_Bill_Hold_Flag                   VARCHAR2,
                     X_Completion_Date                  DATE,
                     X_Rev_Dist_Rejection_Code          VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Project_Id                       NUMBER,
                     X_Organization_Id                  NUMBER,
                     X_Billing_Assignment_Id            NUMBER,
                     X_Event_Num_Reversed               NUMBER,
                     X_Calling_Place                    VARCHAR2,
                     X_Calling_Process                  VARCHAR2,
                     X_Bill_Trans_Currency_Code         VARCHAR2,/* All the 36 columns from here is added for MCB2 */
                     X_Bill_Trans_Bill_Amount           NUMBER,
                     X_Bill_Trans_rev_Amount            NUMBER,
                     X_Project_Currency_Code            VARCHAR2,
                     X_Project_Rate_Type                VARCHAR2,
                     X_Project_Rate_Date                DATE,
                     X_Project_Exchange_Rate            NUMBER,
                     X_Project_Inv_Rate_Date            DATE,
                     X_Project_Inv_Exchange_Rate        NUMBER,
                     X_Project_Bill_Amount              NUMBER,
                     X_Project_Rev_Rate_Date            DATE,
                     X_Project_Rev_Exchange_Rate        NUMBER,
                     X_Project_Revenue_Amount           NUMBER,
                     X_ProjFunc_Currency_Code           VARCHAR2,
                     X_ProjFunc_Rate_Type               VARCHAR2,
                     X_ProjFunc_Rate_Date               DATE,
                     X_ProjFunc_Exchange_Rate           NUMBER,
                     X_ProjFunc_Inv_Rate_Date           DATE,
                     X_ProjFunc_Inv_Exchange_Rate       NUMBER,
                     X_ProjFunc_Bill_Amount             NUMBER,
                     X_ProjFunc_Rev_Rate_Date           DATE,
                     X_Projfunc_Rev_Exchange_Rate       NUMBER,
                     X_ProjFunc_Revenue_Amount          NUMBER,
                     X_Funding_Rate_Type                VARCHAR2,
                     X_Funding_Rate_Date                DATE,
                     X_Funding_Exchange_Rate            NUMBER,
                     X_Invproc_Currency_Code            VARCHAR2,
                     X_Invproc_Rate_Type                VARCHAR2,
                     X_Invproc_Rate_Date                DATE,
                     X_Invproc_Exchange_Rate            NUMBER,
                     X_Revproc_Currency_Code            VARCHAR2,
                     X_Revproc_Rate_Type                VARCHAR2,
                     X_Revproc_Rate_Date                DATE,
                     X_Revproc_Exchange_Rate            NUMBER,
                     X_Inv_Gen_Rejection_Code           VARCHAR2,
                     X_Adjusting_Revenue_Flag           VARCHAR2,  /* For Bug 2261314 */
                     X_Agreement_ID                     NUMBER DEFAULT NULL   -- Federal Uptake
  ) IS
    CURSOR C IS
        SELECT A.*, B.event_type_classification
        FROM   PA_EVENTS A, PA_EVENT_TYPES B
        WHERE  A.rowid = X_Rowid
	   and A.event_type = B.event_type
        FOR UPDATE of Project_Id NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (

	       (Recinfo.Event_Id = X_Event_Id)
           AND (   (Recinfo.task_id =  X_Task_Id)
                OR (    (Recinfo.task_id IS NULL)
                    AND (X_Task_Id IS NULL)))
           AND (Recinfo.event_num =  X_Event_Num)
           AND (RTRIM(Recinfo.event_type) =  RTRIM(X_Event_Type))
           AND (RTRIM(Recinfo.description) = RTRIM(X_Description))
           AND ( (Recinfo.bill_amount =  X_Bill_Amount) -- Make changes for MCB2
              OR ( (Recinfo.bill_amount IS NULL)
                 AND (X_Bill_Amount IS NULL)))
           AND ( (Recinfo.revenue_amount =  X_Revenue_Amount)
                 OR ( (Recinfo.revenue_amount IS NULL)
                     AND (X_Revenue_Amount IS NULL)))
           AND (RTRIM(Recinfo.revenue_distributed_flag) =  RTRIM(X_Revenue_Distributed_Flag))
           --AND (   (RTRIM(Recinfo.Zero_Revenue_Amount_Flag) =  RTRIM(X_Zero_Revenue_Amount_Flag))
                --OR (    (Recinfo.Zero_Revenue_Amount_Flag IS NULL)
                    --AND (X_Zero_Revenue_Amount_Flag IS NULL)))
           AND (   (RTRIM(Recinfo.bill_hold_flag) =  RTRIM(X_Bill_Hold_Flag))
                OR (    (Recinfo.bill_hold_flag IS NULL)
                    AND (X_Bill_Hold_Flag IS NULL)))
           AND (   (Recinfo.completion_date =  X_Completion_Date)
                OR (    (Recinfo.completion_date IS NULL)
                    AND (X_Completion_Date IS NULL)))
           AND (   (RTRIM(Recinfo.attribute_category) =  RTRIM(X_Attribute_Category))
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (RTRIM(Recinfo.attribute1) =  RTRIM(X_Attribute1))
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (RTRIM(Recinfo.attribute2) =  RTRIM(X_Attribute2))
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (RTRIM(Recinfo.attribute3) =  RTRIM(X_Attribute3))
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (RTRIM(Recinfo.attribute4) =  RTRIM(X_Attribute4))
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (RTRIM(Recinfo.attribute5) =  RTRIM(X_Attribute5))
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (RTRIM(Recinfo.attribute6) =  RTRIM(X_Attribute6))
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (RTRIM(Recinfo.attribute7) =  RTRIM(X_Attribute7))
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (RTRIM(Recinfo.attribute8) =  RTRIM(X_Attribute8))
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (RTRIM(Recinfo.attribute9) =  rtrim(X_Attribute9))
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (RTRIM(Recinfo.attribute10) =  RTRIM(X_Attribute10))
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (Recinfo.project_id =  X_Project_Id)
           AND (Recinfo.organization_id =  X_Organization_Id)
           AND (   (Recinfo.billing_assignment_id =  X_Billing_Assignment_Id)
                OR (    (Recinfo.billing_assignment_id IS NULL)
                    AND (X_Billing_Assignment_Id IS NULL))
		OR (	(RTRIM(Recinfo.event_type_classification) = 'AUTOMATIC')
		    AND (X_Billing_Assignment_Id IS NULL)))
           AND (   (Recinfo.event_num_reversed =  X_Event_Num_Reversed)
                OR (    (Recinfo.event_num_reversed IS NULL)
                    AND (X_Event_Num_Reversed IS NULL))
		OR (	(RTRIM(Recinfo.event_type_classification) = 'AUTOMATIC')
                    AND (X_Event_Num_Reversed IS NULL)))
           AND (   (RTRIM(Recinfo.calling_place) =  RTRIM(X_Calling_Place))
                OR (    (Recinfo.calling_place IS NULL)
                    AND (X_Calling_Place IS NULL))
		OR (	(RTRIM(Recinfo.event_type_classification) = 'AUTOMATIC')
                    AND (X_Calling_Place IS NULL)))
           AND (   (RTRIM(Recinfo.calling_process) =  RTRIM(X_Calling_Process))
                OR (    (Recinfo.calling_process IS NULL)
                    AND (X_Calling_Process IS NULL))
		OR (	(RTRIM(Recinfo.event_type_classification) = 'AUTOMATIC')
                    AND (X_Calling_Process IS NULL)))
           AND (   (RTRIM(Recinfo.bill_trans_currency_code) =  RTRIM(X_Bill_Trans_Currency_Code)) -- The following checks has been added for MCB2
                OR (    (Recinfo.bill_trans_currency_code IS NULL)
                    AND (X_Bill_Trans_Currency_Code IS NULL)))
           AND (   ((Recinfo.bill_trans_bill_amount) =  (X_Bill_Trans_Bill_Amount))
                OR (    (Recinfo.bill_trans_bill_amount IS NULL)
                    AND (X_Bill_Trans_Bill_Amount IS NULL)))
           AND (   ((Recinfo.bill_trans_rev_amount) =  (X_Bill_Trans_Rev_Amount))
                OR (    (Recinfo.bill_trans_rev_amount IS NULL)
                    AND (X_Bill_Trans_Rev_Amount IS NULL)))
           AND (   (RTRIM(Recinfo.project_currency_code) =  RTRIM(X_Project_Currency_Code))
                OR (    (Recinfo.project_currency_code IS NULL)
                    AND (X_Project_Currency_Code IS NULL)))
           AND (   (RTRIM(Recinfo.project_rate_type) =  RTRIM(X_Project_Rate_Type))
                OR (    (Recinfo.project_rate_type IS NULL)
                    AND (X_Project_Rate_Type IS NULL)))
           AND (   ((Recinfo.project_rate_date) =  (X_Project_Rate_Date))
                OR (    (Recinfo.project_rate_date IS NULL)
                    AND (X_Project_Rate_Date IS NULL)))
           AND (   ((Recinfo.project_exchange_rate) =  (X_Project_Exchange_Rate))
                OR (    (Recinfo.project_exchange_rate IS NULL)
                    AND (X_Project_Exchange_Rate IS NULL)))
           AND (   (Recinfo.project_inv_rate_date =  X_Project_Inv_Rate_Date)
                OR (    (Recinfo.project_inv_rate_date IS NULL)
                    AND (X_Project_Inv_Rate_Date IS NULL)))
           AND (   ((Recinfo.project_inv_exchange_rate) =  (X_Project_Inv_Exchange_Rate))
                OR (    (Recinfo.project_inv_exchange_rate IS NULL)
                    AND (X_Project_Inv_Exchange_Rate IS NULL)))
         AND (   ((Recinfo.Project_Bill_Amount) =  (X_Project_Bill_Amount))
                OR (    (Recinfo.Project_Bill_Amount IS NULL)
                    AND (X_Project_Bill_Amount IS NULL)))
           AND (   (Recinfo.project_rev_rate_date =  X_Project_Rev_Rate_Date)
                OR (    (Recinfo.project_rev_rate_date IS NULL)
                    AND (X_Project_Rev_Rate_Date IS NULL)))
           AND (   ((Recinfo.project_rev_exchange_rate) =  (X_Project_Rev_Exchange_Rate))
                OR (    (Recinfo.project_rev_exchange_rate IS NULL)
                    AND (X_Project_Rev_Exchange_Rate IS NULL)))
           AND (   ((Recinfo.project_revenue_amount) =  (X_Project_Revenue_Amount))
                OR (    (Recinfo.project_revenue_amount IS NULL)
                    AND (X_Project_Revenue_Amount IS NULL)))
           AND (   (RTRIM(Recinfo.projfunc_currency_code) =  RTRIM(X_ProjFunc_Currency_Code))
                OR (    (Recinfo.projfunc_currency_code IS NULL)
                    AND (X_ProjFunc_Currency_Code IS NULL)))
           AND (   (RTRIM(Recinfo.projfunc_rate_type) =  RTRIM(X_ProjFunc_Rate_Type))
                OR (    (Recinfo.projfunc_rate_type IS NULL)
                    AND (X_ProjFunc_Rate_Type IS NULL)))
           AND (   ((Recinfo.projfunc_rate_date) =  (X_ProjFunc_Rate_Date))
                OR (    (Recinfo.projfunc_rate_date IS NULL)
                    AND (X_ProjFunc_Rate_Date IS NULL)))
           AND (   ((Recinfo.projfunc_exchange_rate) =  (X_ProjFunc_Exchange_Rate))
                OR (    (Recinfo.projfunc_exchange_rate IS NULL)
                    AND (X_ProjFunc_Exchange_Rate IS NULL)))
          AND (   (Recinfo.projfunc_inv_rate_date =  X_ProjFunc_Inv_Rate_Date)
                OR (    (Recinfo.projfunc_inv_rate_date IS NULL)
                    AND (X_ProjFunc_Inv_Rate_Date IS NULL)))
           AND (   ((Recinfo.projfunc_inv_exchange_rate) =  (X_ProjFunc_Inv_Exchange_Rate))
                OR (    (Recinfo.projfunc_inv_exchange_rate IS NULL)
                    AND (X_ProjFunc_Inv_Exchange_Rate IS NULL)))
           AND (   ((Recinfo.projfunc_bill_amount) =  (X_ProjFunc_Bill_Amount))
                OR (    (Recinfo.projfunc_bill_amount IS NULL)
                    AND (X_ProjFunc_Bill_Amount IS NULL)))
           AND (   (Recinfo.projfunc_rev_rate_date =  X_ProjFunc_Rev_Rate_Date)
                OR (    (Recinfo.projfunc_rev_rate_date IS NULL)
                    AND (X_ProjFunc_Rev_Rate_Date IS NULL)))
           AND (   ((Recinfo.projfunc_rev_exchange_rate) =  (X_ProjFunc_Rev_Exchange_Rate))
                OR (    (Recinfo.projfunc_rev_exchange_rate IS NULL)
                    AND (X_ProjFunc_Rev_Exchange_Rate IS NULL)))
           AND (   ((Recinfo.projfunc_revenue_amount) =  (X_ProjFunc_Revenue_Amount))
                OR (    (Recinfo.projfunc_revenue_amount IS NULL)
                    AND (X_ProjFunc_Revenue_Amount IS NULL)))
           AND (   (RTRIM(Recinfo.funding_rate_type) =  RTRIM(X_Funding_Rate_Type))
                OR (    (Recinfo.Funding_Rate_Type IS NULL)
                    AND (X_Funding_Rate_Type IS NULL)))
           AND (   ((Recinfo.funding_rate_date) =  (X_Funding_Rate_Date))
                OR (    (Recinfo.funding_rate_date IS NULL)
                    AND (X_Funding_Rate_Date IS NULL)))
           AND (   ((Recinfo.funding_exchange_rate) =  (X_Funding_Exchange_Rate))
                OR (    (Recinfo.funding_exchange_rate IS NULL)
                    AND (X_Funding_Exchange_Rate IS NULL)))
           AND (   (RTRIM(Recinfo.invproc_currency_code) =  RTRIM(X_InvProc_Currency_Code))
                OR (    (Recinfo.invproc_currency_code IS NULL)
                    AND (X_InvProc_Currency_Code IS NULL)))
           AND (   (RTRIM(Recinfo.invproc_rate_type) =  RTRIM(X_InvProc_Rate_Type))
                OR (    (Recinfo.invproc_rate_type IS NULL)
                    AND (X_InvProc_Rate_Type IS NULL)))
           AND (   ((Recinfo.invproc_rate_date) =  (X_InvProc_Rate_Date))
                OR (    (Recinfo.InvProc_Rate_Date IS NULL)
                    AND (X_InvProc_Rate_Date IS NULL)))
           AND (   ((Recinfo.invproc_exchange_rate) =  (X_InvProc_Exchange_Rate))
                OR (    (Recinfo.invproc_exchange_rate IS NULL)
                    AND (X_InvProc_Exchange_Rate IS NULL)))
           AND (   (RTRIM(Recinfo.revproc_currency_code) =  RTRIM(X_RevProc_Currency_Code))
                OR (    (Recinfo.revproc_currency_code IS NULL)
                    AND (X_RevProc_Currency_Code IS NULL)))
           AND (   (RTRIM(Recinfo.revproc_rate_type) =  RTRIM(X_RevProc_Rate_Type))
                OR (    (Recinfo.revproc_rate_type IS NULL)
                    AND (X_RevProc_Rate_Type IS NULL)))
           AND (   ((Recinfo.revproc_rate_date) =  (X_RevProc_Rate_Date))
                OR (    (Recinfo.revproc_rate_date IS NULL)
                    AND (X_RevProc_Rate_Date IS NULL)))
           AND (   ((Recinfo.revproc_exchange_rate) =  (X_RevProc_Exchange_Rate))
                OR (    (Recinfo.revproc_exchange_rate IS NULL)
                    AND (X_RevProc_Exchange_Rate IS NULL)))
           AND (   (RTRIM(Recinfo.inv_gen_rejection_code) =  RTRIM(X_Inv_Gen_Rejection_Code))
                OR (    (Recinfo.inv_gen_rejection_code IS NULL)
                    AND (X_Inv_Gen_Rejection_Code IS NULL)))
           AND (   (RTRIM(Recinfo.adjusting_revenue_flag) =  RTRIM(X_Adjusting_Revenue_Flag)) /* Bug 2261314 */
                OR (    (Recinfo.adjusting_revenue_flag IS NULL)         /* Bug 2554232*/
	            AND (x_adjusting_Revenue_Flag IS NULL)))
           AND (   (RTRIM(Recinfo.agreement_id) =  RTRIM(X_Agreement_ID)) --Federal Uptake
                OR (    (Recinfo.agreement_id IS NULL)          -- Federal Uptake
                    AND (x_agreement_id IS NULL)))              -- Federal Uptake
--   pd_msg('Hello')
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Event_Id                       NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Event_Num                      NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Event_Type                     VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Bill_Amount                    NUMBER,
                       X_Revenue_Amount                 NUMBER,
                       X_Revenue_Distributed_Flag       VARCHAR2,
		       /*  X_Zero_Revenue_Amount_Flag       VARCHAR2,  */
                       X_Bill_Hold_Flag                 VARCHAR2,
                       X_Completion_Date                DATE,
                       X_Rev_Dist_Rejection_Code        VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Project_Id                     NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Billing_Assignment_Id          NUMBER,
                       X_Event_Num_Reversed             NUMBER,
                       X_Calling_Place                  VARCHAR2,
                       X_Calling_Process                VARCHAR2,
                       X_Bill_Trans_Currency_Code       VARCHAR2,/* All the 36 columns from here is added for MCB2 */
                       X_Bill_Trans_Bill_Amount         NUMBER,
                       X_Bill_Trans_Rev_Amount          NUMBER,
                       X_Project_Currency_Code          VARCHAR2,
                       X_Project_Rate_Type              VARCHAR2,
                       X_Project_Rate_Date              DATE,
                       X_Project_Exchange_Rate          NUMBER,
                       X_Project_Inv_Rate_Date          DATE,
                       X_Project_Inv_Exchange_Rate      NUMBER,
                       X_Project_Bill_Amount            NUMBER,
                       X_Project_Rev_Rate_Date          DATE,
                       X_Project_Rev_Exchange_Rate      NUMBER,
                       X_Project_Revenue_Amount         NUMBER,
                       X_ProjFunc_Currency_Code         VARCHAR2,
                       X_ProjFunc_Rate_Type             VARCHAR2,
                       X_ProjFunc_Rate_Date             DATE,
                       X_ProjFunc_Exchange_Rate         NUMBER,
                       X_ProjFunc_Inv_Rate_Date         DATE,
                       X_ProjFunc_Inv_Exchange_Rate     NUMBER,
                       X_ProjFunc_Bill_Amount           NUMBER,
                       X_ProjFunc_Rev_Rate_Date         DATE,
                       X_ProjFunc_Rev_Exchange_Rate     NUMBER,
                       X_ProjFunc_Revenue_Amount        NUMBER,
                       X_Funding_Rate_Type              VARCHAR2,
                       X_Funding_Rate_Date              DATE,
                       X_Funding_Exchange_Rate          NUMBER,
                       X_Invproc_Currency_Code          VARCHAR2,
                       X_Invproc_Rate_Type              VARCHAR2,
                       X_Invproc_Rate_Date              DATE,
                       X_Invproc_Exchange_Rate          NUMBER,
                       X_Revproc_Currency_Code          VARCHAR2,
                       X_Revproc_Rate_Type              VARCHAR2,
                       X_Revproc_Rate_Date              DATE,
                       X_Revproc_Exchange_Rate          NUMBER,
                       X_Inv_Gen_Rejection_Code         VARCHAR2,
                       X_Adjusting_Revenue_Flag         VARCHAR2,  /* For Bug 2261314 */
                --Start of changes for events amg
                       X_inventory_org_id               NUMBER   DEFAULT NULL,
                       X_inventory_item_id              NUMBER   DEFAULT NULL,
                       X_quantity_billed                NUMBER     DEFAULT NULL,
                        X_uom_code                      VARCHAR2   DEFAULT NULL,
                        X_unit_price                    NUMBER     DEFAULT NULL,
                        X_reference1                    VARCHAR2   DEFAULT NULL,
                        X_reference2                    VARCHAR2   DEFAULT NULL,
                        X_reference3                    VARCHAR2   DEFAULT NULL,
                        X_reference4                    VARCHAR2   DEFAULT NULL,
                        X_reference5                    VARCHAR2   DEFAULT NULL,
                        X_reference6                    VARCHAR2   DEFAULT NULL,
                        X_reference7                    VARCHAR2   DEFAULT NULL,
                        X_reference8                    VARCHAR2   DEFAULT NULL,
                        X_reference9                    VARCHAR2   DEFAULT NULL,
                        X_reference10                   VARCHAR2   DEFAULT NULL,
		--End of changes for events amg
                        X_Agreement_ID                  NUMBER     DEFAULT NULL -- Federal Uptake
  ) IS
  BEGIN
    UPDATE PA_EVENTS
    SET
       event_id			       =     X_Event_Id,
       task_id                         =     X_Task_Id,
       event_num                       =     X_Event_Num,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       event_type                      =     X_Event_Type,
       description                     =     X_Description,
       bill_trans_bill_amount          =     X_Bill_Trans_Bill_Amount, /* Added for MCB2 */
       bill_trans_rev_amount           =     X_Bill_Trans_Rev_Amount, /* Added for MCB2 */
       /*  revenue_distributed_flag        =     X_Revenue_Distributed_Flag,  Added for bug 4114532 */
       --Zero_Revenue_Amount_Flag        =     X_Zero_Revenue_Amount_Flag,
       bill_hold_flag                  =     X_Bill_Hold_Flag,
       completion_date                 =     X_Completion_Date,
       rev_dist_rejection_code         =     X_Rev_Dist_Rejection_Code,
       attribute_category              =     X_Attribute_Category,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       project_id                      =     X_Project_Id,
       organization_id                 =     X_Organization_Id,
       billing_assignment_id           =     X_Billing_Assignment_Id,
       event_num_reversed              =     X_Event_Num_Reversed,
       calling_place                   =     X_Calling_Place,
       calling_process                 =     X_Calling_Process,
       bill_trans_currency_code        =     X_Bill_Trans_Currency_Code,/* Total 36 columns is added for MCB2 */
       project_currency_code           =     X_Project_Currency_Code,
       project_rate_type               =     X_Project_Rate_Type,
       project_rate_date               =     X_Project_Rate_Date,
       project_exchange_rate           =     X_Project_Exchange_Rate,
       project_inv_rate_date           =     X_Project_Inv_Rate_Date,
       project_inv_exchange_rate       =     X_Project_Inv_Exchange_Rate,
       project_bill_amount             =     X_Project_Bill_Amount,
       project_rev_rate_date           =     X_Project_Rev_Rate_Date,
       project_rev_exchange_rate       =     X_Project_Rev_Exchange_Rate,
       project_revenue_amount          =     X_Project_Revenue_Amount,
       projfunc_currency_code          =     X_ProjFunc_Currency_Code,
       projfunc_rate_type              =     X_ProjFunc_Rate_Type,
       projfunc_rate_date              =     X_ProjFunc_Rate_Date,
       projfunc_exchange_rate          =     X_ProjFunc_Exchange_Rate,
       projfunc_inv_rate_date          =     X_ProjFunc_Inv_Rate_Date,
       projfunc_inv_exchange_rate      =     X_ProjFunc_Inv_Exchange_rate,
       projfunc_bill_amount            =     X_ProjFunc_Bill_Amount,
       projfunc_rev_rate_date          =     X_ProjFunc_Rev_Rate_Date,
       projfunc_rev_exchange_rate      =     X_ProjFunc_Rev_Exchange_Rate,
       projfunc_revenue_amount         =     X_ProjFunc_Revenue_Amount,
       funding_rate_type               =     X_Funding_Rate_Type,
       funding_rate_date               =     X_Funding_Rate_Date,
       funding_exchange_rate           =     X_Funding_Exchange_Rate,
       invproc_currency_code           =     X_InvProc_Currency_Code,
       invproc_rate_type               =     X_InvProc_Rate_Type,
       invproc_rate_date               =     X_InvProc_Rate_Date,
       invproc_exchange_rate           =     X_InvProc_Exchange_Rate,
       revproc_currency_code           =     X_RevProc_Currency_Code,
       revproc_rate_type               =     X_RevProc_Rate_Type,
       revproc_rate_date               =     X_RevProc_Rate_Date,
       revproc_exchange_rate           =     X_RevProc_Exchange_Rate,
       inv_gen_rejection_code          =     X_Inv_Gen_Rejection_Code,
       adjusting_revenue_flag          =     X_Adjusting_Revenue_Flag,   /* For Bug 2261314 */
	--Start of changes for events amg
       inventory_org_id                =     X_inventory_org_id,
       inventory_item_id               =     X_inventory_item_id,
	quantity_billed		       =       X_quantity_billed,
	uom_code		       =       X_uom_code,
	unit_price		       =       X_unit_price,
	reference1		       =       X_reference1,
	reference2		       =       X_reference2,
	reference3		       =       X_reference3,
	reference4		       =       X_reference4,
	reference5		       =       X_reference5,
	reference6		       =       X_reference6,
	reference7		       =       X_reference7,
	reference8		       =       X_reference8,
	reference9		       =       X_reference9,
	reference10		       =       X_reference10,
        record_version_number          =       record_version_number + 1,
	--End of changes for events amg
        agreement_id                   =       X_Agreement_ID  -- Federal Uptake
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM PA_EVENTS
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

  FUNCTION Is_Event_Processed( X_Project_Id 		NUMBER,
				X_Task_Id		NUMBER,
				X_Event_Num		NUMBER,
				X_Revenue_Distributed	VARCHAR2,
				X_Bill_Amount		NUMBER)
  RETURN VARCHAR2 IS
  V_Is_Event_Processed		VARCHAR2(1) := 'N';
  CURSOR C_Invoiced IS
    SELECT 'Y'
      FROM sys.dual
     WHERE EXISTS(
    	   SELECT 'Event is on invoice item'
	   FROM   pa_draft_invoice_items dii
	   WHERE  dii.project_id 	    = X_project_id
	   AND    NVL(dii.event_task_id,-1) = NVL(X_Task_Id,-1)
	   AND    dii.event_num		    = X_Event_Num
	   );
  CURSOR C_Revenue_Distributed IS
    SELECT 'Y'
      FROM sys.dual
     WHERE EXISTS(
	   SELECT 'Event is on Revenue dist line'
	   FROM    pa_cust_event_rev_dist_lines erdl
	   WHERE   erdl.project_id 	= X_Project_Id
	   AND 	   NVL(erdl.task_id,-1) = NVL(X_Task_Id,-1)
	   AND	   erdl.event_num 	= X_Event_Num
	   );
  BEGIN
IF (NVl(X_Revenue_Distributed,'N') = 'Y') THEN

       -- if the event distributed flag is Yes then

      V_Is_Event_Processed := 'Y';
      RETURN V_Is_Event_Processed;

    ELSIF  NVL(X_Bill_Amount,0) = 0 THEN

      -- if the bill amount is zero

      V_Is_Event_Processed := 'N';

      RETURN V_Is_Event_Processed;

    ELSE
    --
    -- Check if the event is on an invoice item
    --
    OPEN C_Invoiced;
    FETCH C_Invoiced INTO V_Is_Event_Processed;
    CLOSE C_Invoiced;

    end if;

    if (nvl(V_Is_Event_Processed,'N') = 'Y') then

      RETURN V_Is_Event_Processed;

     end if;

    --
    -- Check if the event is on a Revenue Distribution line
    --
    -- OPEN C_Revenue_Distributed;
    -- FETCH C_Revenue_Distributed INTO V_Is_Event_Processed;
    -- CLOSE C_Revenue_Distributed;
    RETURN nvl(V_Is_Event_Processed,'N');
  EXCEPTION when others then
    raise;
  END Is_Event_Processed;
-----------------------------------------------------------------------------
  function Is_Event_Billed( x_project_id        in      number,
                          x_task_id     in      number,
                          x_event_num   in      number,
                          x_bill_amount in      number) return varchar2 IS
  v_IsEventBilled       varchar2(1);
  begin
     IF  nvl(x_bill_amount,0) <> 0 THEN
                if ( x_task_id is not null ) then
                        SELECT decode(nvl(sum(dii.amount),0),0,'N','Y')
                        INTO v_IsEventBilled
                        FROM pa_draft_invoice_items dii
                        WHERE dii.project_id = x_project_id
                                AND dii.event_task_id    = x_task_id
                                AND dii.event_num  = x_event_num;
                else
                        SELECT decode(nvl(sum(dii.amount),0),0,'N','Y')
                        INTO v_IsEventBilled
                        FROM pa_draft_invoice_items dii
                        WHERE dii.project_id = x_project_id
                                AND dii.event_num  = x_event_num
                                AND dii.event_task_id IS NULL;
                end if;
    ELSE
                v_IsEventBilled := 'N';
    END IF;
    return v_IsEventBilled;
  exception when others then
    raise;
  end Is_Event_Billed;
------------------------------------------------------------------------------
END PA_EVENTS_PKG;

/
