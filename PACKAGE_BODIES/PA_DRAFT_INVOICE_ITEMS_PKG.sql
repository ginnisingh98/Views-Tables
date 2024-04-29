--------------------------------------------------------
--  DDL for Package Body PA_DRAFT_INVOICE_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DRAFT_INVOICE_ITEMS_PKG" as
/* $Header: PAINDIIB.pls 120.4 2005/08/19 16:34:57 mwasowic noship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_Project_Id                     NUMBER,
                       X_Draft_Invoice_Num              NUMBER,
                       X_Line_Num                       NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Amount                         NUMBER,
                       X_Text                           VARCHAR2,
                       X_Invoice_Line_Type              VARCHAR2,
                       X_Unearned_Revenue_Cr            NUMBER,
                       X_Unbilled_Receivable_Dr         NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Event_Task_Id                  NUMBER,
                       X_Event_Num                      NUMBER,
                       X_Ship_To_Address_Id             NUMBER,
                       X_Taxable_Flag                   VARCHAR2,
                       X_Draft_Inv_Line_Num_Credited    NUMBER,
                       X_Last_Update_Login              NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM PA_DRAFT_INVOICE_ITEMS
                 WHERE project_id = X_Project_Id
                 AND   draft_invoice_num = X_Draft_Invoice_Num
                 AND   line_num = X_Line_Num;


    l_rowid      VARCHAR2(30);


   BEGIN

       /* ATG Changes */

       l_rowid  := x_rowid;



       INSERT INTO PA_DRAFT_INVOICE_ITEMS(

              project_id,
              draft_invoice_num,
              line_num,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              amount,
              text,
              invoice_line_type,
              unearned_revenue_cr,
              unbilled_receivable_dr,
              task_id,
              event_task_id,
              event_num,
              ship_to_address_id,
              taxable_flag,
              draft_inv_line_num_credited,
              last_update_login
             ) VALUES (

              X_Project_Id,
              X_Draft_Invoice_Num,
              X_Line_Num,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Amount,
              X_Text,
              X_Invoice_Line_Type,
              X_Unearned_Revenue_Cr,
              X_Unbilled_Receivable_Dr,
              X_Task_Id,
              X_Event_Task_Id,
              X_Event_Num,
              X_Ship_To_Address_Id,
              X_Taxable_Flag,
              X_Draft_Inv_Line_Num_Credited,
              X_Last_Update_Login

             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;

     /* ATG Changes */
       x_rowid  := l_rowid;

      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Project_Id                       NUMBER,
                     X_Draft_Invoice_Num                NUMBER,
                     X_Line_Num                         NUMBER,
                     X_Amount                           NUMBER,
                     X_Text                             VARCHAR2,
                     X_Invoice_Line_Type                VARCHAR2,
                     X_Unearned_Revenue_Cr              NUMBER,
                     X_Unbilled_Receivable_Dr           NUMBER,
                     X_Task_Id                          NUMBER,
                     X_Event_Task_Id                    NUMBER,
                     X_Event_Num                        NUMBER,
                     X_Ship_To_Address_Id               NUMBER,
                     X_Taxable_Flag                     VARCHAR2,
                     X_Draft_Inv_Line_Num_Credited      NUMBER,
                     X_output_tax_code                  VARCHAR2,
                     X_output_tax_exempt_flag           VARCHAR2,
                     X_out_tax_exempt_reason_code       VARCHAR2,
                     X_output_tax_exempt_number         VARCHAR2,
                     X_translated_text                  VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   PA_DRAFT_INVOICE_ITEMS
        WHERE  rowid = X_Rowid
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

               (Recinfo.project_id =  X_Project_Id)
           AND (Recinfo.draft_invoice_num =  X_Draft_Invoice_Num)
           AND (Recinfo.line_num =  X_Line_Num)
           AND (Recinfo.amount =  X_Amount)
           AND (rtrim(Recinfo.text) =  rtrim(X_Text))
           AND (rtrim(Recinfo.invoice_line_type) =  rtrim(X_Invoice_Line_Type))
           AND (   (Recinfo.unearned_revenue_cr =  X_Unearned_Revenue_Cr)
                OR (    (Recinfo.unearned_revenue_cr IS NULL)
                    AND (X_Unearned_Revenue_Cr IS NULL)))
           AND (   (Recinfo.unbilled_receivable_dr =  X_Unbilled_Receivable_Dr)
                OR (    (Recinfo.unbilled_receivable_dr IS NULL)
                    AND (X_Unbilled_Receivable_Dr IS NULL)))
           AND (   (Recinfo.task_id =  X_Task_Id)
                OR (    (Recinfo.task_id IS NULL)
                    AND (X_Task_Id IS NULL)))
           AND (   (Recinfo.event_task_id =  X_Event_Task_Id)
                OR (    (Recinfo.event_task_id IS NULL)
                    AND (X_Event_Task_Id IS NULL)))
           AND (   (Recinfo.event_num =  X_Event_Num)
                OR (    (Recinfo.event_num IS NULL)
                    AND (X_Event_Num IS NULL)))
           AND (   (Recinfo.ship_to_address_id =  X_Ship_To_Address_Id)
                OR (    (Recinfo.ship_to_address_id IS NULL)
                    AND (X_Ship_To_Address_Id IS NULL)))
           AND (   (Recinfo.taxable_flag =  X_Taxable_Flag)
                OR (    (Recinfo.taxable_flag IS NULL)
                    AND (X_Taxable_Flag IS NULL)))
           AND (   (Recinfo.draft_inv_line_num_credited
			=  X_Draft_Inv_Line_Num_Credited)
                OR (    (Recinfo.draft_inv_line_num_credited IS NULL)
                    AND (X_Draft_Inv_Line_Num_Credited IS NULL)))
/* --etax changes
           AND (   (Recinfo.output_vat_tax_id
			=  X_output_vat_tax_id)
                OR (    (Recinfo.output_vat_tax_id IS NULL)
                    AND (X_output_vat_tax_id IS NULL)))
*/
           AND (   (Recinfo.output_tax_classification_code
			=  X_output_tax_code)
                OR (    (Recinfo.output_tax_classification_code IS NULL)
                    AND (X_output_tax_code IS NULL)))
           AND (   (rtrim(Recinfo.output_tax_exempt_flag)
			=  rtrim(X_output_tax_exempt_flag))
                OR (    (Recinfo.output_tax_exempt_flag IS NULL)
                    AND (X_output_tax_exempt_flag IS NULL)))
           AND (   (rtrim(Recinfo.output_tax_exempt_reason_code)
			=  rtrim(X_out_tax_exempt_reason_code))
                OR (    (Recinfo.output_tax_exempt_reason_code IS NULL)
                    AND (X_out_tax_exempt_reason_code IS NULL)))
           AND (   (rtrim(Recinfo.output_tax_exempt_number)
			=  rtrim(X_output_tax_exempt_number))
                OR (    (Recinfo.output_tax_exempt_number IS NULL)
                    AND (X_output_tax_exempt_number IS NULL)))
           AND (   (rtrim(Recinfo.translated_text)
			=  rtrim(X_translated_text))
                OR (    (Recinfo.translated_text IS NULL)
                    AND (X_translated_text IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Project_Id                     NUMBER,
                       X_Draft_Invoice_Num              NUMBER,
                       X_Line_Num                       NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Amount                         NUMBER,
                       X_Text                           VARCHAR2,
                       X_Invoice_Line_Type              VARCHAR2,
                       X_Unearned_Revenue_Cr            NUMBER,
                       X_Unbilled_Receivable_Dr         NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Event_Task_Id                  NUMBER,
                       X_Event_Num                      NUMBER,
                       X_Ship_To_Address_Id             NUMBER,
                       X_Taxable_Flag                   VARCHAR2,
                       X_Draft_Inv_Line_Num_Credited    NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_output_tax_code                VARCHAR2,
                       X_output_tax_exempt_flag         VARCHAR2,
                       X_out_tax_exempt_reason_code     VARCHAR2,
                       X_output_tax_exempt_number       VARCHAR2,
                       X_translated_text                VARCHAR2

  ) IS
  BEGIN
    UPDATE PA_DRAFT_INVOICE_ITEMS
    SET
       project_id                      =     X_Project_Id,
       draft_invoice_num               =     X_Draft_Invoice_Num,
       line_num                        =     X_Line_Num,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       amount                          =     X_Amount,
       text                            =     X_Text,
       invoice_line_type               =     X_Invoice_Line_Type,
       unearned_revenue_cr             =     X_Unearned_Revenue_Cr,
       unbilled_receivable_dr          =     X_Unbilled_Receivable_Dr,
       task_id                         =     X_Task_Id,
       event_task_id                   =     X_Event_Task_Id,
       event_num                       =     X_Event_Num,
       ship_to_address_id              =     X_Ship_To_Address_Id,
       taxable_flag                    =     X_Taxable_Flag,
       draft_inv_line_num_credited     =     X_Draft_Inv_Line_Num_Credited,
       last_update_login               =     X_Last_Update_Login,
--       output_vat_tax_id               =     X_output_vat_tax_id,
       output_tax_classification_code  =     X_output_tax_code,
       output_tax_exempt_flag          =     X_output_tax_exempt_flag,
       output_tax_exempt_reason_code   =     X_out_tax_exempt_reason_code,
       output_tax_exempt_number        =     X_output_tax_exempt_number,
       translated_text                 =     X_translated_text
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM PA_DRAFT_INVOICE_ITEMS
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END PA_DRAFT_INVOICE_ITEMS_PKG;

/
