--------------------------------------------------------
--  DDL for Package Body PO_REQ_DISTRIBUTIONS_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQ_DISTRIBUTIONS_PKG2" as
/* $Header: POXRID2B.pls 120.2.12010000.2 2012/08/31 09:08:09 hliao ship $ */
g_fnd_debug CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

c_log_head    CONSTANT VARCHAR2(35) := 'po.plsql.PO_REQ_DISTRIBUTIONS_PKG2.';

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Distribution_Id                  NUMBER,
                     X_Requisition_Line_Id              NUMBER,
                     X_Set_Of_Books_Id                  NUMBER,
                     X_Code_Combination_Id              NUMBER,
                     X_Req_Line_Quantity                NUMBER,
                     X_Req_Line_Amount                  NUMBER,  -- <SERVICES FPJ>
                     X_Encumbered_Flag                  VARCHAR2,
                     X_Gl_Encumbered_Date               DATE,
                     X_Gl_Encumbered_Period_Name        VARCHAR2,
                     X_Gl_Cancelled_Date                DATE,
                     X_Failed_Funds_Lookup_Code         VARCHAR2,
                     X_Encumbered_Amount                NUMBER,
                     X_Budget_Account_Id                NUMBER,
                     X_Accrual_Account_Id               NUMBER,
                     X_Variance_Account_Id              NUMBER,
                     X_Prevent_Encumbrance_Flag         VARCHAR2,
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
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Ussgl_Transaction_Code           VARCHAR2,
                     X_Government_Context               VARCHAR2,
                     X_Project_Id                       NUMBER,
                     X_Task_Id                          NUMBER,
                     X_Expenditure_Type                 VARCHAR2,
                     X_Project_Accounting_Context       VARCHAR2,
                     X_Expenditure_Organization_Id      NUMBER,
                     X_Gl_Closed_Date                   DATE,
                     X_Source_Req_Distribution_Id       NUMBER,
                     X_Distribution_Num                 NUMBER,
                     X_Project_Related_Flag             VARCHAR2,
                     X_Expenditure_Item_Date            DATE,
                     X_End_Item_Unit_Number             VARCHAR2 DEFAULT NULL,
	             X_Recovery_Rate			NUMBER,
		     X_Tax_Recovery_Override_Flag	VARCHAR2

  ) IS
    CURSOR C IS
        SELECT *
        FROM   PO_REQ_DISTRIBUTIONS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Distribution_Id NOWAIT;
    Recinfo C%ROWTYPE;
	 l_api_name CONSTANT VARCHAR2(30) := 'Lock_Row';
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;

      IF
               (Recinfo.distribution_id = X_Distribution_Id)
           AND (Recinfo.requisition_line_id = X_Requisition_Line_Id)
           AND (Recinfo.set_of_books_id = X_Set_Of_Books_Id)
           AND (Recinfo.code_combination_id = X_Code_Combination_Id)

           -- <SERVICES FPJ START>
           AND (   ( Recinfo.req_line_quantity = X_Req_Line_Quantity )
               OR  (   ( Recinfo.req_line_quantity IS NULL )
                   AND ( X_Req_Line_Quantity IS NULL ) ) )
           AND (   ( Recinfo.req_line_amount = X_Req_Line_Amount )
               OR  (   ( Recinfo.req_line_amount IS NULL )
                   AND ( X_Req_Line_Amount IS NULL ) ) )
           -- <SERVICES FPJ END>

           AND (   (TRIM(Recinfo.encumbered_flag) = TRIM(X_Encumbered_Flag))
                OR (    (TRIM(Recinfo.encumbered_flag) IS NULL)
                    AND (TRIM(X_Encumbered_Flag) IS NULL)))
           AND (   (trunc(Recinfo.gl_encumbered_date) = trunc(X_Gl_Encumbered_Date))
                OR (    (Recinfo.gl_encumbered_date IS NULL)
                    AND (X_Gl_Encumbered_Date IS NULL)))
           AND (   (TRIM(Recinfo.gl_encumbered_period_name) = TRIM(X_Gl_Encumbered_Period_Name))
                OR (    (TRIM(Recinfo.gl_encumbered_period_name) IS NULL)
                    AND (TRIM(X_Gl_Encumbered_Period_Name) IS NULL)))
           AND (   (trunc(Recinfo.gl_cancelled_date) = trunc(X_Gl_Cancelled_Date))
                OR (    (Recinfo.gl_cancelled_date IS NULL)
                    AND (X_Gl_Cancelled_Date IS NULL)))
           AND (   (TRIM(Recinfo.failed_funds_lookup_code) = TRIM(X_Failed_Funds_Lookup_Code))
                OR (    (TRIM(Recinfo.failed_funds_lookup_code) IS NULL)
                    AND (TRIM(X_Failed_Funds_Lookup_Code) IS NULL)))
           AND (   (Recinfo.encumbered_amount = X_Encumbered_Amount)
                OR (    (Recinfo.encumbered_amount IS NULL)
                    AND (X_Encumbered_Amount IS NULL)))
           AND (   (Recinfo.budget_account_id = X_Budget_Account_Id)
                OR (    (Recinfo.budget_account_id IS NULL)
                    AND (X_Budget_Account_Id IS NULL)))
           AND (   (Recinfo.accrual_account_id = X_Accrual_Account_Id)
                OR (    (Recinfo.accrual_account_id IS NULL)
                    AND (X_Accrual_Account_Id IS NULL)))
           AND (   (Recinfo.variance_account_id = X_Variance_Account_Id)
                OR (    (Recinfo.variance_account_id IS NULL)
                    AND (X_Variance_Account_Id IS NULL)))
           AND (   (TRIM(Recinfo.prevent_encumbrance_flag) = TRIM(X_Prevent_Encumbrance_Flag))
                OR (    (TRIM(Recinfo.prevent_encumbrance_flag) IS NULL)
                    AND (TRIM(X_Prevent_Encumbrance_Flag) IS NULL)))  THEN


          IF
              (   (TRIM(Recinfo.attribute_category) = TRIM(X_Attribute_Category))
                OR (    (TRIM(Recinfo.attribute_category) IS NULL)
                    AND (TRIM(X_Attribute_Category) IS NULL)))
           AND (   (TRIM(Recinfo.attribute1) = TRIM(X_Attribute1))
                OR (    (TRIM(Recinfo.attribute1) IS NULL)
                    AND (TRIM(X_Attribute1) IS NULL)))
           AND (   (TRIM(Recinfo.attribute2) = TRIM(X_Attribute2))
                OR (    (TRIM(Recinfo.attribute2) IS NULL)
                    AND (TRIM(X_Attribute2) IS NULL)))
           AND (   (TRIM(Recinfo.attribute3) = TRIM(X_Attribute3))
                OR (    (TRIM(Recinfo.attribute3) IS NULL)
                    AND (TRIM(X_Attribute3)IS NULL)))
           AND (   (TRIM(Recinfo.attribute4) = TRIM(X_Attribute4))
                OR (    (TRIM(Recinfo.attribute4) IS NULL)
                    AND (TRIM(X_Attribute4) IS NULL)))
           AND (   (TRIM(Recinfo.attribute5) = TRIM(X_Attribute5))
                OR (    (TRIM(Recinfo.attribute5) IS NULL)
                    AND (TRIM(X_Attribute5) IS NULL)))
           AND (   (TRIM(Recinfo.attribute6) = TRIM(X_Attribute6))
                OR (    (TRIM(Recinfo.attribute6) IS NULL)
                    AND (TRIM(X_Attribute6) IS NULL)))
           AND (   (TRIM(Recinfo.attribute7) = TRIM(X_Attribute7))
                OR (    (TRIM(Recinfo.attribute7) IS NULL)
                    AND (TRIM(X_Attribute7) IS NULL)))
           AND (   (TRIM(Recinfo.attribute8) = TRIM(X_Attribute8))
                OR (    (TRIM(Recinfo.attribute8) IS NULL)
                    AND (TRIM(X_Attribute8) IS NULL)))
           AND (   (TRIM(Recinfo.attribute9) = TRIM(X_Attribute9))
                OR (    (TRIM(Recinfo.attribute9) IS NULL)
                    AND (TRIM(X_Attribute9) IS NULL)))
           AND (   (TRIM(Recinfo.attribute10) = TRIM(X_Attribute10))
                OR (    (TRIM(Recinfo.attribute10) IS NULL)
                    AND (TRIM(X_Attribute10) IS NULL)))
           AND (   (TRIM(Recinfo.attribute11) = TRIM(X_Attribute11))
                OR (    (TRIM(Recinfo.attribute11) IS NULL)
                    AND (TRIM(X_Attribute11) IS NULL)))
           AND (   (TRIM(Recinfo.attribute12) = TRIM(X_Attribute12))
                OR (    (TRIM(Recinfo.attribute12) IS NULL)
                    AND (TRIM(X_Attribute12) IS NULL)))
           AND (   (TRIM(Recinfo.attribute13) = TRIM(X_Attribute13))
                OR (    (TRIM(Recinfo.attribute13) IS NULL)
                    AND (TRIM(X_Attribute13) IS NULL)))
           AND (   (TRIM(Recinfo.attribute14) = TRIM(X_Attribute14))
                OR (    (TRIM(Recinfo.attribute14) IS NULL)
                    AND (TRIM(X_Attribute14) IS NULL)))
           AND (   (TRIM(Recinfo.attribute15) = TRIM(X_Attribute15))
                OR (    (TRIM(Recinfo.attribute15) IS NULL)
                    AND (TRIM(X_Attribute15) IS NULL)))
           AND (   (TRIM(Recinfo.government_context) = TRIM(X_Government_Context))
                OR (    (TRIM(Recinfo.government_context) IS NULL)
                    AND (TRIM(X_Government_Context) IS NULL)))
           AND (   (Recinfo.project_id = X_Project_Id)
                OR (    (Recinfo.project_id IS NULL)
                    AND (X_Project_Id IS NULL)))
           AND (   (Recinfo.task_id = X_Task_Id)
                OR (    (Recinfo.task_id IS NULL)
                    AND (X_Task_Id IS NULL)))
           AND (   (TRIM(Recinfo.end_item_unit_number) = TRIM(X_End_Item_Unit_Number))
                OR (    (TRIM(Recinfo.end_item_unit_number) IS NULL)
                    AND (TRIM(X_End_Item_Unit_Number) IS NULL)))
           AND (   (Recinfo.Recovery_Rate = X_Recovery_Rate)
                OR (    (Recinfo.Recovery_Rate IS NULL)
                    AND (X_Recovery_Rate IS NULL)))
           AND (   (TRIM(Recinfo.tax_recovery_override_flag) = TRIM(X_Tax_Recovery_Override_Flag))
                OR (    (TRIM(Recinfo.tax_recovery_override_flag) IS NULL)
                    AND (TRIM(X_Tax_Recovery_Override_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.expenditure_type) = TRIM(X_Expenditure_Type))
                OR (    (TRIM(Recinfo.expenditure_type) IS NULL)
                    AND (TRIM(X_Expenditure_Type) IS NULL)))
           AND (   (TRIM(Recinfo.project_accounting_context) = TRIM(X_Project_Accounting_Context))
                OR (    (TRIM(Recinfo.project_accounting_context) IS NULL)
                    AND (TRIM(X_Project_Accounting_Context) IS NULL)))
           AND (   (Recinfo.expenditure_organization_id = X_Expenditure_Organization_Id)
                OR (    (Recinfo.expenditure_organization_id IS NULL)
                    AND (X_Expenditure_Organization_Id IS NULL)))
           AND (   (trunc(Recinfo.gl_closed_date) = trunc(X_Gl_Closed_Date))
                OR (    (Recinfo.gl_closed_date IS NULL)
                    AND (X_Gl_Closed_Date IS NULL)))
           AND (   (Recinfo.source_req_distribution_id = X_Source_Req_Distribution_Id)
                OR (    (Recinfo.source_req_distribution_id IS NULL)
                    AND (X_Source_Req_Distribution_Id IS NULL)))
           AND (Recinfo.distribution_num = X_Distribution_Num)
           AND (   (TRIM(Recinfo.project_related_flag) = TRIM(X_Project_Related_Flag))
                OR (    (TRIM(Recinfo.project_related_flag) IS NULL)
                    AND (TRIM(X_Project_Related_Flag) IS NULL)))
           AND (   (trunc(Recinfo.expenditure_item_date) = trunc(X_Expenditure_Item_Date))
                OR (    (Recinfo.expenditure_item_date IS NULL)
                    AND (X_Expenditure_Item_Date IS NULL)))      THEN

                 return;

         END IF;

       END IF;

      /*
     ** If we get to this point then a column has been changed.
     */

	 IF (g_fnd_debug = 'Y') THEN
	 if (nvl(X_Distribution_Id,-999) <> nvl(Recinfo.Distribution_Id,-999)   ) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Distribution_Id '||X_Distribution_Id ||' Database  Distribution_Id '||Recinfo.Distribution_Id);
     end if;
     if (nvl(X_requisition_Line_Id,-999) <> nvl(Recinfo.requisition_Line_Id,-999)) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form requisition_Line_Id '||X_requisition_Line_Id||' Database  requisition_Line_Id '||Recinfo.requisition_Line_Id);
     end if;
     if (nvl(X_Set_Of_Books_Id,-999) <> nvl( Recinfo.Set_Of_Books_Id,-999)) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Set_Of_Books_Id '||X_Set_Of_Books_Id ||' Database  Set_Of_Books_Id '||Recinfo.Set_Of_Books_Id);
     end if;
     if (nvl(X_Code_Combination_Id,-999) <> nvl( Recinfo.Code_Combination_Id,-999)) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Code_Combination_Id '||X_Code_Combination_Id ||' Database  Code_Combination_Id '||Recinfo.Code_Combination_Id);
     end if;
     if (nvl(X_Req_Line_Quantity ,-999) <> nvl( Recinfo.Req_Line_Quantity ,-999)) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Req_Line_Quantity '||X_Req_Line_Quantity ||' Database  Req_Line_Quantity '||Recinfo.Req_Line_Quantity);
     end if;
     if (nvl(X_Req_Line_Amount ,-999) <> nvl( Recinfo.Req_Line_Amount ,-999)) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Req_Line_Amount '||X_Req_Line_Amount ||' Database  Req_Line_Amount '||Recinfo.Req_Line_Amount);
     end if;
     if (nvl(X_Encumbered_Flag,'-999') <>  nvl(Recinfo.Encumbered_Flag ,'-999')) then
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Encumbered_Flag '||X_Encumbered_Flag ||' Database  Encumbered_Flag '||Recinfo.Encumbered_Flag);
     end if;
     if (trunc(X_Gl_Encumbered_Date) <>  trunc(Recinfo.Gl_Encumbered_Date) ) then
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Gl_Encumbered_Date '||X_Gl_Encumbered_Date ||' Database  Gl_Encumbered_Date '||Recinfo.Gl_Encumbered_Date);
     end if;
     if (nvl(X_Gl_Encumbered_Period_Name,'-999') <> nvl(Recinfo.Gl_Encumbered_Period_Name,'-999')) then
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Gl_Encumbered_Period_Name '||X_Gl_Encumbered_Period_Name ||' Database  Gl_Encumbered_Period_Name '||Recinfo.Gl_Encumbered_Period_Name);
     end if;
     if (trunc(X_Gl_Cancelled_Date) <>  trunc(Recinfo.Gl_Cancelled_Date) ) then
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Gl_Cancelled_Date '||X_Gl_Cancelled_Date ||' Database  Gl_Cancelled_Date '||Recinfo.Gl_Cancelled_Date);
     end if;
     if (nvl(X_Failed_Funds_Lookup_Code,'-999') <> nvl(Recinfo.Failed_Funds_Lookup_Code,'-999')) then
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Failed_Funds_Lookup_Code '||X_Failed_Funds_Lookup_Code ||' Database  Failed_Funds_Lookup_Code '||Recinfo.Failed_Funds_Lookup_Code);
     end if;
     if (nvl(X_Encumbered_Amount,-999) <> nvl(Recinfo.Encumbered_Amount,-999)) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Encumbered_Amount '||X_Encumbered_Amount ||' Database  Encumbered_Amount '||Recinfo.Encumbered_Amount);
     end if;
     if (nvl(X_Budget_Account_Id,-999) <> nvl(Recinfo.Budget_Account_Id,-999)) then
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Budget_Account_Id '||X_Budget_Account_Id ||' Database  Budget_Account_Id '||Recinfo.Budget_Account_Id);
     end if;
     if (nvl(X_Accrual_Account_Id,-999) <> nvl(Recinfo.Accrual_Account_Id,-999)   ) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Accrual_Account_Id '||X_Accrual_Account_Id ||' Database  Accrual_Account_Id '||Recinfo.Accrual_Account_Id);
     end if;
     if (nvl(X_Variance_Account_Id ,-999) <> nvl(Recinfo.Variance_Account_Id,-999)   ) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Variance_Account_Id '||X_Variance_Account_Id ||' Database  Variance_Account_Id '||Recinfo.Variance_Account_Id);
     end if;
     if (nvl(X_Prevent_Encumbrance_Flag,'-999') <> nvl(Recinfo.Prevent_Encumbrance_Flag,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Prevent_Encumbrance_Flag '||X_Prevent_Encumbrance_Flag||' Database  Prevent_Encumbrance_Flag '||Recinfo.Prevent_Encumbrance_Flag);
     end if;
     if (nvl(X_Attribute_Category,'-999') <> nvl( Recinfo.Attribute_Category,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Attribute_Category '||X_Attribute_Category ||' Database  Attribute_Category '||Recinfo.Attribute_Category);
     end if;
     if (nvl(X_Attribute1,'-999') <> nvl( Recinfo.Attribute1,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Attribute1 '||X_Attribute1 ||' Database  Attribute1 '||Recinfo.Attribute1);
     end if;
     if (nvl(X_Attribute2,'-999') <> nvl( Recinfo.Attribute2,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Attribute2 '||X_Attribute2 ||' Database  Attribute2 '||Recinfo.Attribute2);
     end if;
     if (nvl(X_Attribute3,'-999') <> nvl( Recinfo.Attribute3,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Attribute3 '||X_Attribute3 ||' Database  Attribute3 '||Recinfo.Attribute3);
     end if;
     if (nvl(X_Attribute4,'-999')  <> nvl( Recinfo.Attribute4,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Attribute4 '||X_Attribute4 ||' Database  Attribute4 '||Recinfo.Attribute4);
     end if;
     if (nvl(X_Attribute5,'-999')  <> nvl( Recinfo.Attribute5,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Attribute5 '||X_Attribute5 ||' Database  Attribute5 '||Recinfo.Attribute5);
     end if;
     if (nvl(X_Attribute6,'-999')   <> nvl( Recinfo.Attribute6,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Attribute6 '||X_Attribute6 ||' Database  Attribute6 '||Recinfo.Attribute6);
     end if;
     if (nvl(X_Attribute7,'-999')  <> nvl( Recinfo.Attribute7,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Attribute7 '||X_Attribute7 ||' Database  Attribute7 '||Recinfo.Attribute7);
     end if;
     if (nvl(X_Attribute8,'-999')  <> nvl( Recinfo.Attribute8,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Attribute8 '||X_Attribute8 ||' Database  Attribute8 '||Recinfo.Attribute8);
     end if;
     if (nvl(X_Attribute9,'-999')  <> nvl( Recinfo.Attribute9,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Attribute9 '||X_Attribute9 ||' Database  Attribute9 '||Recinfo.Attribute9);
     end if;
     if (nvl(X_Attribute10,'-999')  <> nvl( Recinfo.Attribute10,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Attribute10 '||X_Attribute10 ||' Database  Attribute10 '||Recinfo.Attribute10);
     end if;
     if (nvl(X_Attribute11,'-999')  <> nvl( Recinfo.Attribute11,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Attribute11 '||X_Attribute11 ||' Database  Attribute11 '||Recinfo.Attribute11);
     end if;
     if (nvl(X_Attribute12,'-999')  <> nvl( Recinfo.Attribute12,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Attribute12 '||X_Attribute12 ||' Database  Attribute12 '||Recinfo.Attribute12);
     end if;
     if (nvl(X_Attribute13,'-999')  <> nvl( Recinfo.Attribute13,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Attribute13 '||X_Attribute13 ||' Database  Attribute13 '||Recinfo.Attribute13);
     end if;
     if (nvl(X_Attribute14,'-999')  <> nvl( Recinfo.Attribute14,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Attribute14 '||X_Attribute14 ||' Database  Attribute14 '||Recinfo.Attribute14);
     end if;
     if (nvl(X_Attribute15,'-999')  <> nvl( Recinfo.Attribute15,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Attribute15 '||X_Attribute15 ||' Database  Attribute15 '||Recinfo.Attribute15);
     end if;
     if (nvl(X_Government_Context,'-999') <> nvl( Recinfo.Government_Context,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Government_Context '||X_Government_Context ||' Database  Government_Context '||Recinfo.Government_Context);
     end if;
     if (nvl(X_Project_Id ,-999) <> nvl( Recinfo.Project_Id ,-999)) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Project_Id '||X_Project_Id ||' Database  Project_Id '||Recinfo.Project_Id);
     end if;
     if (nvl(X_Task_Id,-999) <> nvl( Recinfo.Task_Id,-999)) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Task_Id '||X_Task_Id ||' Database  Task_Id '||Recinfo.Task_Id);
     end if;
     if (nvl(X_Expenditure_Type,'-999') <> nvl( Recinfo.Expenditure_Type,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Expenditure_Type '||X_Expenditure_Type ||' Database  Expenditure_Type '||Recinfo.Expenditure_Type);
     end if;
     if (nvl(X_Project_Accounting_Context,'-999') <> nvl( Recinfo.Project_Accounting_Context,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Project_Accounting_Context '||X_Project_Accounting_Context ||' Database  Project_Accounting_Context '||Recinfo.Project_Accounting_Context);
     end if;
     if (nvl(X_Expenditure_Organization_Id,-999) <> nvl( Recinfo.Expenditure_Organization_Id   ,-999)) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Expenditure_Organization_Id '||X_Expenditure_Organization_Id ||' Database  Expenditure_Organization_Id '||Recinfo.Expenditure_Organization_Id);
     end if;
     if (trunc(X_Gl_Closed_Date) <> trunc(Recinfo.Gl_Closed_Date) ) then
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Gl_Closed_Date '||X_Gl_Closed_Date ||' Database  Gl_Closed_Date '||Recinfo.Gl_Closed_Date);
     end if;
     if (nvl(X_Source_Req_Distribution_Id,-999) <> nvl(Recinfo.Source_Req_Distribution_Id,-999)   ) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Source_Req_Distribution_Id '||X_Source_Req_Distribution_Id ||' Database  Source_Req_Distribution_Id '||Recinfo.Source_Req_Distribution_Id);
     end if;
     if (nvl(X_Distribution_Num,-999) <> nvl( Recinfo.Distribution_Num,-999)) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Distribution_Num '||X_Distribution_Num ||' Database  Distribution_Num '||Recinfo.Distribution_Num);
     end if;
     if (nvl(X_Project_Related_flag,'-999') <>  nvl(Recinfo.Project_Related_flag ,'-999')) then
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Project_Related_flag '||X_Project_Related_flag ||' Database  Project_Related_flag '||Recinfo.Project_Related_flag);
     end if;
     if ( trunc(X_Expenditure_Item_Date)  <> trunc(Recinfo.Expenditure_Item_Date) ) then
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Expenditure_Item_Date '||X_Expenditure_Item_Date ||' Database  Expenditure_Item_Date '||Recinfo.Expenditure_Item_Date);
     end if;
     if (nvl(X_End_Item_Unit_Number,-999) <> nvl(Recinfo.End_Item_Unit_Number,-999)) then
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form End_Item_Unit_Number '||X_End_Item_Unit_Number ||' Database  End_Item_Unit_Number '||Recinfo.End_Item_Unit_Number);
     end if;
     if (nvl(X_Recovery_Rate,-999) <> nvl(Recinfo.Recovery_Rate,-999)) then
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Recovery_Rate '||X_Recovery_Rate ||' Database  Recovery_Rate '||Recinfo.Recovery_Rate);
     end if;
     if (nvl(X_Tax_Recovery_Override_Flag,'-999') <>  nvl(Recinfo.Tax_Recovery_Override_Flag ,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Tax_Recovery_Override_Flag '||X_Tax_Recovery_Override_Flag ||' Database  Tax_Recovery_Override_Flag '||Recinfo.Tax_Recovery_Override_Flag);
     end if;
	 END IF;

      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;

  END Lock_Row;



  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM PO_REQ_DISTRIBUTIONS
    WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;


  END Delete_Row;

END PO_REQ_DISTRIBUTIONS_PKG2;

/
