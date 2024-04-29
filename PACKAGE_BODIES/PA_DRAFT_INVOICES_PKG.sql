--------------------------------------------------------
--  DDL for Package Body PA_DRAFT_INVOICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DRAFT_INVOICES_PKG" as
/* $Header: PAINDINB.pls 120.2.12010000.2 2008/11/27 09:37:16 rdegala ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895

                       X_Project_Id                     NUMBER,
                       X_Draft_Invoice_Num              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Transfer_Status_Code           VARCHAR2,
                       X_Generation_Error_Flag          VARCHAR2,
                       X_Agreement_Id                   NUMBER,
                       X_Pa_Date                        DATE,
                       X_Customer_Bill_Split            NUMBER,
                       X_Bill_Through_Date              DATE,
                       X_Invoice_Comment                VARCHAR2,
                       X_Approved_Date                  DATE,
                       X_Approved_By_Person_Id          NUMBER,
                       X_Released_Date                  DATE,
                       X_Released_By_Person_Id          NUMBER,
                       X_Invoice_Date                   DATE,
                       X_Ra_Invoice_Number              VARCHAR2,
                       X_Transferred_Date               DATE,
                       X_Transfer_Rejection_Reason      VARCHAR2,
                       X_Unearned_Revenue_Cr            NUMBER,
                       X_Unbilled_Receivable_Dr         NUMBER,
                       X_Gl_Date                        DATE,
                       X_System_Reference               NUMBER,
                       X_Draft_Invoice_Num_Credited     NUMBER,
                       X_Canceled_Flag                  VARCHAR2,
                       X_Cancel_Credit_Memo_Flag        VARCHAR2,
                       X_Write_Off_Flag                 VARCHAR2,
                       X_Converted_Flag                 VARCHAR2,
                       X_Extracted_Date                 DATE,
                       X_Last_Update_Login              NUMBER,
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
                       X_Retention_Percentage           NUMBER,
                       X_Invoice_Set_Id                 NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM PA_DRAFT_INVOICES
                 WHERE project_id = X_Project_Id
                 AND   draft_invoice_num = X_Draft_Invoice_Num;

   l_rowid    varchar2(30);


   BEGIN


       /* ATG Changes */
       l_rowid  :=  x_rowid;


       INSERT INTO PA_DRAFT_INVOICES(

              project_id,
              draft_invoice_num,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              transfer_status_code,
              generation_error_flag,
              agreement_id,
              pa_date,
              customer_bill_split,
              bill_through_date,
              invoice_comment,
              approved_date,
              approved_by_person_id,
              released_date,
              released_by_person_id,
              invoice_date,
              ra_invoice_number,
              transferred_date,
              transfer_rejection_reason,
              unearned_revenue_cr,
              unbilled_receivable_dr,
              gl_date,
              system_reference,
              draft_invoice_num_credited,
              canceled_flag,
              cancel_credit_memo_flag,
              write_off_flag,
              converted_flag,
              extracted_date,
              last_update_login,
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
              retention_percentage,
              invoice_set_id
             ) VALUES (

              X_Project_Id,
              X_Draft_Invoice_Num,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Transfer_Status_Code,
              X_Generation_Error_Flag,
              X_Agreement_Id,
              X_Pa_Date,
              X_Customer_Bill_Split,
              X_Bill_Through_Date,
              X_Invoice_Comment,
              X_Approved_Date,
              X_Approved_By_Person_Id,
              X_Released_Date,
              X_Released_By_Person_Id,
              X_Invoice_Date,
              X_Ra_Invoice_Number,
              X_Transferred_Date,
              X_Transfer_Rejection_Reason,
              X_Unearned_Revenue_Cr,
              X_Unbilled_Receivable_Dr,
              X_Gl_Date,
              X_System_Reference,
              X_Draft_Invoice_Num_Credited,
              X_Canceled_Flag,
              X_Cancel_Credit_Memo_Flag,
              X_Write_Off_Flag,
              X_Converted_Flag,
              X_Extracted_Date,
              X_Last_Update_Login,
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
              X_Retention_Percentage,
              X_Invoice_Set_Id

             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;

   /* ATG Changes */
      x_rowid := l_rowid;

      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

                     X_Project_Id                       NUMBER,
                     X_Draft_Invoice_Num                NUMBER,
                     X_Transfer_Status_Code             VARCHAR2,
                     X_Generation_Error_Flag            VARCHAR2,
                     X_Agreement_Id                     NUMBER,
                     X_Pa_Date                          DATE,
                     X_Customer_Bill_Split              NUMBER,
                     X_Bill_Through_Date                DATE,
                     X_Invoice_Comment                  VARCHAR2,
                     X_Approved_Date                    DATE,
                     X_Approved_By_Person_Id            NUMBER,
                     X_Released_Date                    DATE,
                     X_Released_By_Person_Id            NUMBER,
                     X_Invoice_Date                     DATE,
                     X_Ra_Invoice_Number                VARCHAR2,
                     X_Transferred_Date                 DATE,
                     X_Transfer_Rejection_Reason        VARCHAR2,
                     X_Unearned_Revenue_Cr              NUMBER,
                     X_Unbilled_Receivable_Dr           NUMBER,
                     X_Gl_Date                          DATE,
                     X_System_Reference                 NUMBER,
                     X_Draft_Invoice_Num_Credited       NUMBER,
                     X_Canceled_Flag                    VARCHAR2,
                     X_Cancel_Credit_Memo_Flag          VARCHAR2,
                     X_Write_Off_Flag                   VARCHAR2,
                     X_Converted_Flag                   VARCHAR2,
                     X_Extracted_Date                   DATE,
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
                     X_Retention_Percentage             NUMBER,
                     X_Invoice_Set_Id                   NUMBER,
                     X_Inv_currency_code                VARCHAR2,
                     X_Inv_rate_type                    VARCHAR2,
                     X_Inv_rate_date                    DATE,
                     X_Inv_exchange_rate                NUMBER,
	       	     X_Credit_Memo_Reason_Code          VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   PA_DRAFT_INVOICES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Project_Id NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
   /*  pd_msg(' 1-'||Recinfo.inv_currency_code ||
           ' -2-' || X_inv_currency_code);  */
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (

               (Recinfo.project_id =  X_Project_Id)
           AND (Recinfo.draft_invoice_num =  X_Draft_Invoice_Num)
           AND (RTRIM(Recinfo.transfer_status_code) =  RTRIM(X_Transfer_Status_Code))
           AND (RTRIM(Recinfo.generation_error_flag) =  RTRIM(X_Generation_Error_Flag))
           AND (Recinfo.agreement_id =  X_Agreement_Id)
           AND (trunc(Recinfo.pa_date) =  trunc(X_Pa_Date))
           AND (   (Recinfo.customer_bill_split =  X_Customer_Bill_Split)
                OR (    (Recinfo.customer_bill_split IS NULL)
                    AND (X_Customer_Bill_Split IS NULL)))
           AND (   (Recinfo.bill_through_date =  X_Bill_Through_Date)
                OR (    (Recinfo.bill_through_date IS NULL)
                    AND (X_Bill_Through_Date IS NULL)))
           AND (   (rtrim(Recinfo.invoice_comment) =  rtrim(X_Invoice_Comment))
                OR (    (Recinfo.invoice_comment IS NULL)
                    AND (X_Invoice_Comment IS NULL))
		OR  rtrim(X_Invoice_Comment) = 'NO CHANGE')
           AND (   (Recinfo.approved_date =  X_Approved_Date)
                OR (    (Recinfo.approved_date IS NULL)
                    AND (X_Approved_Date IS NULL))
		OR X_Approved_By_Person_Id = -1)
           AND (   (Recinfo.approved_by_person_id =  X_Approved_By_Person_Id)
                OR (    (Recinfo.approved_by_person_id IS NULL)
                    AND (X_Approved_By_Person_Id IS NULL))
		OR X_Approved_By_Person_Id = -1)
           AND (   (Recinfo.released_date =  X_Released_Date)
                OR (    (Recinfo.released_date IS NULL)
                    AND (X_Released_Date IS NULL))
		OR X_Released_By_Person_Id = -1)
           AND (   (Recinfo.released_by_person_id =  X_Released_By_Person_Id)
                OR (    (Recinfo.released_by_person_id IS NULL)
                    AND (X_Released_By_Person_Id IS NULL))
		OR X_Released_By_Person_Id = -1)
           AND (   (Recinfo.invoice_date =  X_Invoice_Date)
                OR (    (Recinfo.invoice_date IS NULL)
                    AND (X_Invoice_Date IS NULL))
		OR X_Released_By_Person_Id = -1)
           AND (   (RTRIM(Recinfo.ra_invoice_number) =  RTRIM(X_Ra_Invoice_Number))
                OR (    (Recinfo.ra_invoice_number IS NULL)
                    AND (X_Ra_Invoice_Number IS NULL))
		OR X_Released_By_Person_Id = -1)
           AND (   (Recinfo.transferred_date =  X_Transferred_Date)
                OR (    (Recinfo.transferred_date IS NULL)
                    AND (X_Transferred_Date IS NULL)))
           AND (   (RTRIM(Recinfo.transfer_rejection_reason)
			 =  RTRIM(X_Transfer_Rejection_Reason))
                OR (    (Recinfo.transfer_rejection_reason IS NULL)
                    AND (X_Transfer_Rejection_Reason IS NULL)))
/* AND (   (Recinfo.unearned_revenue_cr =  X_Unearned_Revenue_Cr)
                OR (    (Recinfo.unearned_revenue_cr IS NULL)
                    AND (X_Unearned_Revenue_Cr IS NULL)))
           AND (   (Recinfo.unbilled_receivable_dr =  X_Unbilled_Receivable_Dr)
                OR (    (Recinfo.unbilled_receivable_dr IS NULL)
                    AND (X_Unbilled_Receivable_Dr IS NULL))) */
           AND (   (Recinfo.gl_date =  X_Gl_Date)
                OR (    (Recinfo.gl_date IS NULL)
                    AND (X_Gl_Date IS NULL)))
           AND (   (Recinfo.system_reference =  X_System_Reference)
                OR (    (Recinfo.system_reference IS NULL)
                    AND (X_System_Reference IS NULL)))
           AND (   (Recinfo.draft_invoice_num_credited
			 =  X_Draft_Invoice_Num_Credited)
                OR (    (Recinfo.draft_invoice_num_credited IS NULL)
                    AND (X_Draft_Invoice_Num_Credited IS NULL)))
           AND (   (RTRIM(Recinfo.canceled_flag) =  RTRIM(X_Canceled_Flag))
                OR (    (Recinfo.canceled_flag IS NULL)
                    AND (X_Canceled_Flag IS NULL)))
           AND (   (RTRIM(Recinfo.cancel_credit_memo_flag) = RTRIM(X_Cancel_Credit_Memo_Flag))
                OR (    (Recinfo.cancel_credit_memo_flag IS NULL)
                    AND (X_Cancel_Credit_Memo_Flag IS NULL)))
           AND (   (RTRIM(Recinfo.write_off_flag) =  RTRIM(X_Write_Off_Flag))
                OR (    (Recinfo.write_off_flag IS NULL)
                    AND (X_Write_Off_Flag IS NULL)))
           AND (   (RTRIM(Recinfo.converted_flag) =  RTRIM(X_Converted_Flag))
                OR (    (Recinfo.converted_flag IS NULL)
                    AND (X_Converted_Flag IS NULL)))
           AND (   (Recinfo.extracted_date =  X_Extracted_Date)
                OR (    (Recinfo.extracted_date IS NULL)
                    AND (X_Extracted_Date IS NULL)))
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
           AND (   (RTRIM(Recinfo.attribute9) =  RTRIM(X_Attribute9))
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (RTRIM(Recinfo.attribute10) =  RTRIM(X_Attribute10))
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.retention_percentage =  X_Retention_Percentage)
                OR (    (Recinfo.retention_percentage IS NULL)
                    AND (X_Retention_Percentage IS NULL)))
           AND (   (Recinfo.invoice_set_id =  X_Invoice_Set_Id)
                OR (    (Recinfo.invoice_set_id IS NULL)
                    AND (X_Invoice_Set_Id IS NULL)))
           AND (   (RTRIM(Recinfo.inv_currency_code) =  RTRIM(X_Inv_currency_code)) /* fix bug 2082864 */
                OR (    (Recinfo.inv_currency_code IS NULL)
                    AND (X_Inv_currency_code IS NULL)))
           AND (   (RTRIM(Recinfo.inv_rate_type) =  RTRIM(X_Inv_rate_type)) /* fix bug 2082845 */
                OR (    (Recinfo.inv_rate_type IS NULL)
                    AND (X_Inv_rate_type IS NULL)))
           AND (   (TRUNC(Recinfo.inv_rate_date) =  TRUNC(X_Inv_rate_date))
                OR (    (Recinfo.inv_rate_date IS NULL)
                    AND (X_Inv_rate_date IS NULL)))  /* Added trunc to fix bug 2082864 */
           AND   (   (TO_NUMBER(SUBSTR(Recinfo.inv_exchange_rate,1,17)) =
                TO_NUMBER(SUBSTR( X_Inv_exchange_rate,1,17)))
               OR  (    (Recinfo.inv_exchange_rate IS NULL)
                    AND (X_Inv_exchange_rate IS NULL)))
	  AND (   (RTRIM(Recinfo.credit_memo_reason_code) =  RTRIM(X_credit_memo_reason_code))
                OR (    (Recinfo.credit_memo_reason_code IS NULL)
                    AND (X_credit_memo_reason_code IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;

/* overloaded procedure Lock_row*/
PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

                     X_Project_Id                       NUMBER,
                     X_Draft_Invoice_Num                NUMBER,
                     X_Transfer_Status_Code             VARCHAR2,
                     X_Generation_Error_Flag            VARCHAR2,
                     X_Agreement_Id                     NUMBER,
                     X_Pa_Date                          DATE,
                     X_Customer_Bill_Split              NUMBER,
                     X_Bill_Through_Date                DATE,
                     X_Invoice_Comment                  VARCHAR2,
                     X_Approved_Date                    DATE,
                     X_Approved_By_Person_Id            NUMBER,
                     X_Released_Date                    DATE,
                     X_Released_By_Person_Id            NUMBER,
                     X_Invoice_Date                     DATE,
                     X_Ra_Invoice_Number                VARCHAR2,
                     X_Transferred_Date                 DATE,
                     X_Transfer_Rejection_Reason        VARCHAR2,
                     X_Unearned_Revenue_Cr              NUMBER,
                     X_Unbilled_Receivable_Dr           NUMBER,
                     X_Gl_Date                          DATE,
                     X_System_Reference                 NUMBER,
                     X_Draft_Invoice_Num_Credited       NUMBER,
                     X_Canceled_Flag                    VARCHAR2,
                     X_Cancel_Credit_Memo_Flag          VARCHAR2,
                     X_Write_Off_Flag                   VARCHAR2,
                     X_Converted_Flag                   VARCHAR2,
                     X_Extracted_Date                   DATE,
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
                     X_Retention_Percentage             NUMBER,
                     X_Invoice_Set_Id                   NUMBER,
                     X_Inv_currency_code                VARCHAR2,
                     X_Inv_rate_type                    VARCHAR2,
                     X_Inv_rate_date                    DATE,
                     X_Inv_exchange_rate                NUMBER
  ) IS
new_excp        exception;
BEGIN
Raise new_excp;

END Lock_row;




  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Project_Id                     NUMBER,
                       X_Draft_Invoice_Num              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Transfer_Status_Code           VARCHAR2,
                       X_Generation_Error_Flag          VARCHAR2,
                       X_Agreement_Id                   NUMBER,
                       X_Pa_Date                        DATE,
                       X_Customer_Bill_Split            NUMBER,
                       X_Bill_Through_Date              DATE,
                       X_Invoice_Comment                VARCHAR2,
                       X_Approved_Date                  DATE,
                       X_Approved_By_Person_Id          NUMBER,
                       X_Released_Date                  DATE,
                       X_Released_By_Person_Id          NUMBER,
                       X_Invoice_Date                   DATE,
                       X_Ra_Invoice_Number              VARCHAR2,
                       X_Transferred_Date               DATE,
                       X_Transfer_Rejection_Reason      VARCHAR2,
                       X_Unearned_Revenue_Cr            NUMBER,
                       X_Unbilled_Receivable_Dr         NUMBER,
                       X_Gl_Date                        DATE,
		       X_Gl_period_name			VARCHAR2, /* Added for bug 6819782*/
                       X_System_Reference               NUMBER,
                       X_Draft_Invoice_Num_Credited     NUMBER,
                       X_Canceled_Flag                  VARCHAR2,
                       X_Cancel_Credit_Memo_Flag        VARCHAR2,
                       X_Write_Off_Flag                 VARCHAR2,
                       X_Converted_Flag                 VARCHAR2,
                       X_Extracted_Date                 DATE,
                       X_Last_Update_Login              NUMBER,
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
                       X_Retention_Percentage           NUMBER,
                       X_Invoice_Set_Id                 NUMBER,
		       X_Credit_Memo_Reason_Code        VARCHAR2

  ) IS
  BEGIN
    UPDATE PA_DRAFT_INVOICES
    SET
       project_id                      =     X_Project_Id,
       draft_invoice_num               =     X_Draft_Invoice_Num,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       transfer_status_code            =     X_Transfer_Status_Code,
       generation_error_flag           =     X_Generation_Error_Flag,
       agreement_id                    =     X_Agreement_Id,
       pa_date                         =     X_Pa_Date,
       customer_bill_split             =     X_Customer_Bill_Split,
       bill_through_date               =     X_Bill_Through_Date,
       invoice_comment                 =     decode(X_Invoice_Comment,
			'NO CHANGE', invoice_comment, X_Invoice_Comment),
       approved_date                   =     decode(X_Approved_By_Person_Id,
			-1, approved_date, X_Approved_Date),
       approved_by_person_id           =     decode(X_Approved_By_Person_Id,
			-1, approved_by_person_id, X_Approved_By_Person_Id),
       released_date                   =     decode(X_Released_By_Person_Id,
			-1, released_date, X_Released_Date),
       released_by_person_id           =     decode(X_Released_By_Person_Id,
                        -1, released_by_person_id, X_Released_By_Person_Id),
       invoice_date                    =     decode(X_Released_By_Person_Id,
                        -1, invoice_date, X_Invoice_Date),
       ra_invoice_number               =     decode(X_Released_By_Person_Id,
                        -1, ra_invoice_number, X_Ra_Invoice_Number),
       transferred_date                =     X_Transferred_Date,
       transfer_rejection_reason       =     X_Transfer_Rejection_Reason,
       unearned_revenue_cr             =     X_Unearned_Revenue_Cr,
       unbilled_receivable_dr          =     X_Unbilled_Receivable_Dr,
       gl_date                         =     X_Gl_Date,
       gl_period_name		       =     NVL(X_Gl_period_name,gl_period_name), /* Added for bug 6819782*/
       system_reference                =     X_System_Reference,
       draft_invoice_num_credited      =     X_Draft_Invoice_Num_Credited,
       canceled_flag                   =     X_Canceled_Flag,
       cancel_credit_memo_flag         =     X_Cancel_Credit_Memo_Flag,
       write_off_flag                  =     X_Write_Off_Flag,
       converted_flag                  =     X_Converted_Flag,
       extracted_date                  =     X_Extracted_Date,
       last_update_login               =     X_Last_Update_Login,
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
       retention_percentage            =     X_Retention_Percentage,
       invoice_set_id                  =     X_Invoice_Set_Id,
       credit_memo_reason_code         =     X_Credit_Memo_Reason_Code
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

/*Overloaded procedure update_row */
  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Project_Id                     NUMBER,
                       X_Draft_Invoice_Num              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Transfer_Status_Code           VARCHAR2,
                       X_Generation_Error_Flag          VARCHAR2,
                       X_Agreement_Id                   NUMBER,
                       X_Pa_Date                        DATE,
                       X_Customer_Bill_Split            NUMBER,
                       X_Bill_Through_Date              DATE,
                       X_Invoice_Comment                VARCHAR2,
                       X_Approved_Date                  DATE,
                       X_Approved_By_Person_Id          NUMBER,
                       X_Released_Date                  DATE,
                       X_Released_By_Person_Id          NUMBER,
                       X_Invoice_Date                   DATE,
                       X_Ra_Invoice_Number              VARCHAR2,
                       X_Transferred_Date               DATE,
                       X_Transfer_Rejection_Reason      VARCHAR2,
                       X_Unearned_Revenue_Cr            NUMBER,
                       X_Unbilled_Receivable_Dr         NUMBER,
                       X_Gl_Date                        DATE,
                       X_System_Reference               NUMBER,
                       X_Draft_Invoice_Num_Credited     NUMBER,
                       X_Canceled_Flag                  VARCHAR2,
                       X_Cancel_Credit_Memo_Flag        VARCHAR2,
                       X_Write_Off_Flag                 VARCHAR2,
                       X_Converted_Flag                 VARCHAR2,
                       X_Extracted_Date                 DATE,
                       X_Last_Update_Login              NUMBER,
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
                       X_Retention_Percentage           NUMBER,
                       X_Invoice_Set_Id                 NUMBER
 ) IS

  new_excp        exception;
BEGIN
Raise new_excp;

END Update_row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM PA_DRAFT_INVOICES
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END PA_DRAFT_INVOICES_PKG;

/
