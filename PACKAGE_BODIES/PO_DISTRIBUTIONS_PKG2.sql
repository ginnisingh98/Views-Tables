--------------------------------------------------------
--  DDL for Package Body PO_DISTRIBUTIONS_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DISTRIBUTIONS_PKG2" as
/* $Header: POXP2PDB.pls 120.5.12010000.3 2012/08/31 08:53:01 hliao ship $ */
c_log_head    CONSTANT VARCHAR2(35) := 'po.plsql.PO_DISTRIBUTIONS_PKG2.';

g_fnd_debug CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Po_Distribution_Id               NUMBER,
                     X_Po_Header_Id                     NUMBER,
                     X_Po_Line_Id                       NUMBER,
                     X_Line_Location_Id                 NUMBER,
                     X_Set_Of_Books_Id                  NUMBER,
                     X_Code_Combination_Id              NUMBER,
                     X_Quantity_Ordered                 NUMBER,
                     X_Po_Release_Id                    NUMBER,
                     X_Quantity_Delivered               NUMBER,
                     X_Quantity_Billed                  NUMBER,
                     X_Quantity_Cancelled               NUMBER,
                     X_Req_Header_Reference_Num         VARCHAR2,
                     X_Req_Line_Reference_Num           VARCHAR2,
                     X_Req_Distribution_Id              NUMBER,
                     X_Deliver_To_Location_Id           NUMBER,
                     X_Deliver_To_Person_Id             NUMBER,
                     X_Rate_Date                        DATE,
                     X_Rate                             NUMBER,
                     X_Amount_Billed                    NUMBER,
                     X_Accrued_Flag                     VARCHAR2,
                     X_Encumbered_Flag                  VARCHAR2,
                     X_Encumbered_Amount                NUMBER,
                     X_Unencumbered_Quantity            NUMBER,
                     X_Unencumbered_Amount              NUMBER,
                     X_Failed_Funds_Lookup_Code         VARCHAR2,
                     X_Gl_Encumbered_Date               DATE,
                     X_Gl_Encumbered_Period_Name        VARCHAR2,
                     X_Gl_Cancelled_Date                DATE,
                     X_Destination_Type_Code            VARCHAR2,
                     X_Destination_Organization_Id      NUMBER,
                     X_Destination_Subinventory         VARCHAR2,
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
                     X_Wip_Entity_Id                    NUMBER,
                     X_Wip_Operation_Seq_Num            NUMBER,
                     X_Wip_Resource_Seq_Num             NUMBER,
                     X_Wip_Repetitive_Schedule_Id       NUMBER,
                     X_Wip_Line_Id                      NUMBER,
                     X_Bom_Resource_Id                  NUMBER,
                     X_Budget_Account_Id                NUMBER,
                     X_Accrual_Account_Id               NUMBER,
                     X_Variance_Account_Id              NUMBER,

                     --< Shared Proc FPJ Start >
                     p_dest_charge_account_id           NUMBER,
                     p_dest_variance_account_id         NUMBER,
                     --< Shared Proc FPJ End >

                     X_Prevent_Encumbrance_Flag         VARCHAR2,
                     X_Ussgl_Transaction_Code           VARCHAR2,
                     X_Government_Context               VARCHAR2,
                     X_Destination_Context              VARCHAR2,
                     X_Distribution_Num                 NUMBER,
                     X_Source_Distribution_Id           NUMBER,
                     X_Project_Id                       NUMBER,
                     X_Task_Id                          NUMBER,
                     X_Expenditure_Type                 VARCHAR2,
                     X_Project_Accounting_Context       VARCHAR2,
                     X_Expenditure_Organization_Id      NUMBER,
                     X_Gl_Closed_Date                   DATE,
                     X_Accrue_On_Receipt_Flag           VARCHAR2,
                     X_Expenditure_Item_Date            DATE,
                     X_End_Item_Unit_Number             VARCHAR2 DEFAULT NULL,
                     X_Recovery_Rate                    NUMBER,
                     X_Tax_Recovery_Override_Flag       VARCHAR2,
                     X_amount_ordered                   NUMBER,  -- <SERVICES FPJ>
                     X_amount_to_encumber               NUMBER DEFAULT NULL, --<ENCUMBRANCE FPJ>
                     X_distribution_type                VARCHAR2 DEFAULT NULL --<ENCUMBRANCE FPJ>
  ) IS
    CURSOR C IS
        SELECT *
        FROM   PO_DISTRIBUTIONS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Po_Distribution_Id NOWAIT;
    Recinfo C%ROWTYPE;
    -- For debug purposes(lswamy)
    l_api_name CONSTANT VARCHAR2(30) := 'Lock_Row';
  BEGIN
    IF (g_fnd_debug = 'Y') THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name || '.begin','lock rows');
    END IF;

    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;

    IF
               (Recinfo.po_distribution_id = X_Po_Distribution_Id)
           AND (Recinfo.po_header_id = X_Po_Header_Id)
   --<ENCUMBRANCE FPJ START>
           AND (   (Recinfo.po_line_id = X_Po_Line_Id)
               OR  (    (Recinfo.po_line_id IS NULL)
                    AND (X_Po_Line_Id IS NULL)))
           AND (   (Recinfo.line_location_id = X_Line_Location_Id)
               OR  (    (Recinfo.line_location_id IS NULL)
                    AND (X_Line_Location_Id IS NULL)))
  --<ENCUMBRANCE FPJ END>
           AND (Recinfo.set_of_books_id = X_Set_Of_Books_Id)
   --<ENCUMBRANCE FPJ START>
           AND (   (Recinfo.code_combination_id = X_Code_Combination_Id)
               OR  (    (Recinfo.code_combination_id IS NULL)
                    AND (X_Code_Combination_Id IS NULL)))
           AND (   (Recinfo.quantity_ordered = X_Quantity_Ordered)
               OR  (    (Recinfo.quantity_ordered IS NULL)
                    AND (X_Quantity_Ordered IS NULL)))
  --<ENCUMBRANCE FPJ END>
           AND (   (Recinfo.po_release_id = X_Po_Release_Id)
                OR (    (Recinfo.po_release_id IS NULL)
                    AND (X_Po_Release_Id IS NULL)))
         /*  AND (   (Recinfo.quantity_delivered = X_Quantity_Delivered)
                OR (    (Recinfo.quantity_delivered IS NULL)
                    AND (X_Quantity_Delivered IS NULL)))
           AND (   (Recinfo.quantity_billed = X_Quantity_Billed)
                OR (    (Recinfo.quantity_billed IS NULL)
                    AND (X_Quantity_Billed IS NULL)))
           <Bug# 3464561> Following three lines commented out too.
           AND (   (Recinfo.quantity_cancelled = X_Quantity_Cancelled)
                OR (    (Recinfo.quantity_cancelled IS NULL)
                    AND (X_Quantity_Cancelled IS NULL))) */
           AND (   (TRIM(Recinfo.req_header_reference_num) = TRIM(X_Req_Header_Reference_Num))
                OR (    (TRIM(Recinfo.req_header_reference_num) IS NULL)
                    AND (TRIM(X_Req_Header_Reference_Num) IS NULL)))
           AND (   (TRIM(Recinfo.req_line_reference_num) = TRIM(X_Req_Line_Reference_Num))
                OR (    (TRIM(Recinfo.req_line_reference_num) IS NULL)
                    AND (TRIM(X_Req_Line_Reference_Num) IS NULL)))
           AND (   (Recinfo.req_distribution_id = X_Req_Distribution_Id)
                OR (    (Recinfo.req_distribution_id IS NULL)
                    AND (X_Req_Distribution_Id IS NULL)))
           AND (   (Recinfo.deliver_to_location_id = X_Deliver_To_Location_Id)
                OR (    (Recinfo.deliver_to_location_id IS NULL)
                    AND (X_Deliver_To_Location_Id IS NULL)))
           AND (   (Recinfo.deliver_to_person_id = X_Deliver_To_Person_Id)
                OR (    (Recinfo.deliver_to_person_id IS NULL)
                    AND (X_Deliver_To_Person_Id IS NULL)))
           AND (   (trunc(Recinfo.rate_date) = trunc(X_Rate_Date))
                OR (    (Recinfo.rate_date IS NULL)
                    AND (X_Rate_Date IS NULL)))
           AND (   (Recinfo.rate = X_Rate)
                OR (    (Recinfo.rate IS NULL)
                    AND (X_Rate IS NULL)))
           AND (   (Recinfo.amount_billed = X_Amount_Billed)
                OR (    (Recinfo.amount_billed IS NULL)
                    AND (X_Amount_Billed IS NULL)))
           AND (   (Recinfo.recovery_rate = X_Recovery_Rate)
                OR (    (Recinfo.recovery_rate IS NULL)
                    AND (X_Recovery_Rate IS NULL)))
           AND (   (TRIM(Recinfo.accrued_flag) = TRIM(X_Accrued_Flag))
                OR (    (TRIM(Recinfo.accrued_flag) IS NULL)
                    AND (TRIM(X_Accrued_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.encumbered_flag) = TRIM(X_Encumbered_Flag))
                OR (    (TRIM(Recinfo.encumbered_flag) IS NULL)
                    AND (TRIM(X_Encumbered_Flag) IS NULL)))
           AND (   (Recinfo.encumbered_amount = X_Encumbered_Amount)
                OR (    (Recinfo.encumbered_amount IS NULL)
                    AND (X_Encumbered_Amount IS NULL)))
           AND (   (Recinfo.unencumbered_quantity = X_Unencumbered_Quantity)
                OR (    (Recinfo.unencumbered_quantity IS NULL)
                    AND (X_Unencumbered_Quantity IS NULL)))
           AND (   (Recinfo.unencumbered_amount = X_Unencumbered_Amount)
                OR (    (Recinfo.unencumbered_amount IS NULL)
                    AND (X_Unencumbered_Amount IS NULL)))
   --<ENCUMBRANCE FPJ START>
           AND (   (Recinfo.amount_to_encumber = X_amount_to_encumber)
                OR (    (Recinfo.amount_to_encumber IS NULL)
                    AND (X_amount_to_encumber IS NULL)))
           AND (   (TRIM(Recinfo.distribution_type) = TRIM(X_distribution_type))
                OR (    (TRIM(Recinfo.distribution_type) IS NULL)
                    AND (TRIM(X_distribution_type) IS NULL)))
   --<ENCUMBRANCE FPJ END>
           AND (   (TRIM(Recinfo.failed_funds_lookup_code) = TRIM(X_Failed_Funds_Lookup_Code))
                OR (    (TRIM(Recinfo.failed_funds_lookup_code) IS NULL)
                    AND (TRIM(X_Failed_Funds_Lookup_Code) IS NULL)))
           AND (   (trunc(Recinfo.gl_encumbered_date) = trunc(X_Gl_Encumbered_Date))
                OR (    (Recinfo.gl_encumbered_date IS NULL)
                    AND (X_Gl_Encumbered_Date IS NULL)))
           AND (   (TRIM(Recinfo.gl_encumbered_period_name) = TRIM(X_Gl_Encumbered_Period_Name))
                OR (    (TRIM(Recinfo.gl_encumbered_period_name) IS NULL)
                    AND (TRIM(X_Gl_Encumbered_Period_Name) IS NULL)))
           AND (   (trunc(Recinfo.gl_cancelled_date) = trunc(X_Gl_Cancelled_Date))
                OR (    (Recinfo.gl_cancelled_date IS NULL)
                    AND (X_Gl_Cancelled_Date IS NULL)))
           AND (   (TRIM(Recinfo.destination_type_code) = TRIM(X_Destination_Type_Code))
                OR (    (TRIM(Recinfo.destination_type_code) IS NULL)
                    AND (TRIM(X_Destination_Type_Code) IS NULL)))
           AND (   (Recinfo.destination_organization_id = X_Destination_Organization_Id)
                OR (    (Recinfo.destination_organization_id IS NULL)
                    AND (X_Destination_Organization_Id IS NULL)))
           AND (   (TRIM(Recinfo.destination_subinventory) = TRIM(X_Destination_Subinventory))
                OR (    (TRIM(Recinfo.destination_subinventory) IS NULL)
                    AND (TRIM(X_Destination_Subinventory) IS NULL)))
           -- <SERVICES FPJ START>
           AND (   (Recinfo.amount_ordered = X_amount_ordered)
                OR (    (Recinfo.amount_ordered IS NULL)
                    AND (X_amount_ordered IS NULL)))
           -- <SERVICES FPJ END>
           THEN
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
                    AND (TRIM(X_Attribute3) IS NULL)))
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
                     AND (TRIM(X_Attribute15) IS NULL)))           THEN

          IF
              (   (Recinfo.wip_entity_id = X_Wip_Entity_Id)
                OR (    (Recinfo.wip_entity_id IS NULL)
                    AND (X_Wip_Entity_Id IS NULL)))
           AND (   (Recinfo.wip_operation_seq_num = X_Wip_Operation_Seq_Num)
                OR (    (Recinfo.wip_operation_seq_num IS NULL)
                    AND (X_Wip_Operation_Seq_Num IS NULL)))
           AND (   (Recinfo.wip_resource_seq_num = X_Wip_Resource_Seq_Num)
                OR (    (Recinfo.wip_resource_seq_num IS NULL)
                    AND (X_Wip_Resource_Seq_Num IS NULL)))
           AND (   (Recinfo.wip_repetitive_schedule_id = X_Wip_Repetitive_Schedule_Id)
                OR (    (Recinfo.wip_repetitive_schedule_id IS NULL)
                    AND (X_Wip_Repetitive_Schedule_Id IS NULL)))
           AND (   (Recinfo.wip_line_id = X_Wip_Line_Id)
                OR (    (Recinfo.wip_line_id IS NULL)
                    AND (X_Wip_Line_Id IS NULL)))
           AND (   (Recinfo.bom_resource_id = X_Bom_Resource_Id)
                OR (    (Recinfo.bom_resource_id IS NULL)
                    AND (X_Bom_Resource_Id IS NULL)))
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
                    AND (TRIM(X_Prevent_Encumbrance_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.government_context)= TRIM(X_Government_Context))
                OR (    (TRIM(Recinfo.government_context) IS NULL)
                    AND (TRIM(X_Government_Context) IS NULL)))
           AND (   (TRIM(Recinfo.destination_context) = TRIM(X_Destination_Context))
                OR (    (TRIM(Recinfo.destination_context) IS NULL)
                    AND (TRIM(X_Destination_Context) IS NULL)))
           AND (Recinfo.distribution_num = X_Distribution_Num)
           AND (   (Recinfo.source_distribution_id = X_Source_Distribution_Id)
                OR (    (Recinfo.source_distribution_id IS NULL)
                    AND (X_Source_Distribution_Id IS NULL)))
           AND (   (Recinfo.project_id = X_Project_Id)
                OR (    (Recinfo.project_id IS NULL)
                    AND (X_Project_Id IS NULL)))
           AND (   (Recinfo.task_id = X_Task_Id)
                OR (    (Recinfo.task_id IS NULL)
                    AND (X_Task_Id IS NULL)))
           AND (   (TRIM(Recinfo.end_item_unit_number) = TRIM(X_End_Item_Unit_Number))
                OR (    (TRIM(Recinfo.end_item_unit_number) IS NULL)
                    AND (TRIM(X_End_Item_Unit_Number) IS NULL)))
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
           AND (   (TRIM(Recinfo.accrue_on_receipt_flag) = TRIM(X_Accrue_On_Receipt_Flag))
                OR (    (TRIM(Recinfo.accrue_on_receipt_flag) IS NULL)
                    AND (TRIM(X_Accrue_On_Receipt_Flag) IS NULL)))
           AND (   (trunc(Recinfo.expenditure_item_date) = trunc(X_Expenditure_Item_Date))
                OR (    (Recinfo.expenditure_item_date IS NULL)
                    AND (X_Expenditure_Item_Date IS NULL)))

           --< Shared Proc FPJ Start >
           AND ( (RECINFO.dest_charge_account_id = p_dest_charge_account_id)
                OR (    (RECINFO.dest_charge_account_id IS NULL)
                    AND (p_dest_charge_account_id IS NULL)))
           AND ( (RECINFO.dest_variance_account_id = p_dest_variance_account_id)
                OR (    (RECINFO.dest_variance_account_id IS NULL)
                    AND (p_dest_variance_account_id IS NULL)))
           --< Shared Proc FPJ End >


                     THEN
                  IF (g_fnd_debug = 'Y') THEN
                    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name || '.end','no lock error');
                  END IF;

                  return;

              END IF;
            END IF;
         END IF;
    /*
    ** If we get to this point then a column has been changed.
    */

    --only display discrepancy when fnd debug is enabled
    IF (g_fnd_debug = 'Y') THEN


    if (nvl(X_Po_Distribution_Id,-999) <> nvl(Recinfo.Po_Distribution_Id,-999)   ) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Po_Distribution_Id '||X_Po_Distribution_Id ||' Database  Po_Distribution_Id '||Recinfo.Po_Distribution_Id);
    end if;
    if (nvl(X_Po_Header_Id ,-999) <> nvl(Recinfo.Po_Header_Id,-999)   ) then
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Po_Header_Id '||X_Po_Header_Id ||' Database  Po_Header_Id '||Recinfo.Po_Header_Id);
    end if;
    if (nvl(X_Po_Line_Id,-999) <> nvl(Recinfo.Po_Line_Id,-999)) then
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Po_Line_Id '||X_Po_Line_Id||' Database  Po_Line_Id '||Recinfo.Po_Line_Id);
    end if;
    if (nvl(X_Line_Location_Id ,-999) <> nvl( Recinfo.Line_Location_Id,-999)) then
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Line_Location_Id '||X_Line_Location_Id ||' Database  Line_Location_Id '||Recinfo.Line_Location_Id);
    end if;
    if (nvl(X_Set_Of_Books_Id,-999) <> nvl( Recinfo.Set_Of_Books_Id,-999)) then
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Set_Of_Books_Id '||X_Set_Of_Books_Id ||' Database  Set_Of_Books_Id '||Recinfo.Set_Of_Books_Id);
    end if;
    if (nvl(X_Code_Combination_Id,-999) <> nvl( Recinfo.Code_Combination_Id,-999)) then
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Code_Combination_Id '||X_Code_Combination_Id ||' Database  Code_Combination_Id '||Recinfo.Code_Combination_Id);
    end if;

    po_wf_debug_pkg.insert_Debug('lak','lak','foloing should fail 1');
    if (nvl(X_Quantity_Ordered ,-999) <> nvl( Recinfo.Quantity_Ordered ,-999)) then
    po_wf_debug_pkg.insert_Debug('lak','lak','foloing should fail 5');
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Quantity_Ordered '||X_Quantity_Ordered ||' Database  Quantity_Ordered '||Recinfo.Quantity_Ordered);
    end if;
    if (nvl(X_Po_Release_Id ,-999) <> nvl( Recinfo.Po_Release_Id ,-999)) then
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Po_Release_Id '||X_Po_Release_Id ||' Database  Po_Release_Id '||Recinfo.Po_Release_Id);
    end if;
    if (nvl(X_Req_Header_Reference_Num,-999) <> nvl( Recinfo.Req_Header_Reference_Num,-999)) then
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Req_Header_Reference_Num '||X_Req_Header_Reference_Num ||' Database  Req_Header_Reference_Num '||Recinfo.Req_Header_Reference_Num);
    end if;
    if (nvl(X_Req_Line_Reference_Num,-999) <> nvl( Recinfo.Req_Line_Reference_Num,-999)) then
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Req_Line_Reference_Num '||X_Req_Line_Reference_Num ||' Database  Req_Line_Reference_Num '||Recinfo.Req_Line_Reference_Num);
    end if;
    if (nvl(X_Req_Distribution_Id,-999) <> nvl( Recinfo.Req_Distribution_Id,-999)) then
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Req_Distribution_Id '||X_Req_Distribution_Id ||' Database  Req_Distribution_Id '||Recinfo.Req_Distribution_Id);
    end if;
    if (nvl(X_Deliver_To_Location_Id,-999) <> nvl( Recinfo.Deliver_To_Location_Id   ,-999)) then
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Deliver_To_Location_Id '||X_Deliver_To_Location_Id ||' Database  Deliver_To_Location_Id '||Recinfo.Deliver_To_Location_Id);
    end if;
    if (nvl(X_Deliver_To_Person_Id,-999) <> nvl( Recinfo.Deliver_To_Person_Id,-999)) then
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Deliver_To_Person_Id '||X_Deliver_To_Person_Id ||' Database  Deliver_To_Person_Id '||Recinfo.Deliver_To_Person_Id);
    end if;
    if (trunc(X_Rate_Date)  <>  trunc(Recinfo.Rate_Date) ) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Rate_Date '||X_Rate_Date ||' Database  Rate_Date '||Recinfo.Rate_Date);
    end if;
    if (nvl(X_Rate,-999) <> nvl(Recinfo.Rate,-999)) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Rate '||X_Rate ||' Database  Rate '||Recinfo.Rate);
    end if;
    if (nvl(X_Amount_Billed,-999) <> nvl(Recinfo.Amount_Billed,-999)) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Amount_Billed '||X_Amount_Billed ||' Database  Amount_Billed '||Recinfo.Amount_Billed);
    end if;
    if (nvl(X_Accrued_Flag,'-999') <> nvl(Recinfo.Accrued_Flag,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Accrued_Flag '||X_Accrued_Flag ||' Database  Accrued_Flag '||Recinfo.Accrued_Flag);
    end if;
    if (nvl(X_Encumbered_Flag,'-999') <>  nvl(Recinfo.Encumbered_Flag ,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Encumbered_Flag '||X_Encumbered_Flag ||' Database  Encumbered_Flag '||Recinfo.Encumbered_Flag);
    end if;
    if (nvl(X_Encumbered_Amount,-999) <> nvl(Recinfo.Encumbered_Amount,-999)) then
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Encumbered_Amount '||X_Encumbered_Amount ||' Database  Encumbered_Amount '||Recinfo.Encumbered_Amount);
    end if;
    if (nvl(X_Unencumbered_Quantity,-999) <> nvl(Recinfo.Unencumbered_Quantity,-999)) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Unencumbered_Quantity '||X_Unencumbered_Quantity ||' Database  Unencumbered_Quantity '||Recinfo.Unencumbered_Quantity);
    end if;
    if (nvl(X_Unencumbered_Amount,-999)  <>  nvl(Recinfo.Unencumbered_Amount,-999)) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Unencumbered_Amount '||X_Unencumbered_Amount ||' Database  Unencumbered_Amount '||Recinfo.Unencumbered_Amount);
    end if;
    if (nvl(X_Failed_Funds_Lookup_Code,'-999') <> nvl(Recinfo.Failed_Funds_Lookup_Code,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Failed_Funds_Lookup_Code '||X_Failed_Funds_Lookup_Code ||' Database  Failed_Funds_Lookup_Code '||Recinfo.Failed_Funds_Lookup_Code);
    end if;
    if ( trunc(X_Gl_Encumbered_Date) <> trunc(Recinfo.Gl_Encumbered_Date) ) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Gl_Encumbered_Date '||X_Gl_Encumbered_Date ||' Database  Gl_Encumbered_Date '||Recinfo.Gl_Encumbered_Date);
    end if;
    if (nvl(X_Gl_Encumbered_Period_Name,'-999') <> nvl(Recinfo.Gl_Encumbered_Period_Name,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Gl_Encumbered_Period_Name '||X_Gl_Encumbered_Period_Name ||' Database  Gl_Encumbered_Period_Name '||Recinfo.Gl_Encumbered_Period_Name);
    end if;
    if ( trunc(X_Gl_Cancelled_Date) <>  trunc(Recinfo.Gl_Cancelled_Date) ) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Gl_Cancelled_Date '||X_Gl_Cancelled_Date ||' Database  Gl_Cancelled_Date '||Recinfo.Gl_Cancelled_Date);
    end if;
    if (nvl(X_Destination_Type_Code,'-999') <> nvl(Recinfo.Destination_Type_Code,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Destination_Type_Code '||X_Destination_Type_Code ||' Database  Destination_Type_Code '||Recinfo.Destination_Type_Code);
    end if;
    if (nvl(X_Destination_Organization_Id,-999) <> nvl(Recinfo.Destination_Organization_Id,-999)) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Destination_Organization_Id '||X_Destination_Organization_Id ||' Database  Destination_Organization_Id '||Recinfo.Destination_Organization_Id);
    end if;
    if (nvl(X_Destination_Subinventory,'-999') <> nvl(Recinfo.Destination_Subinventory,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Destination_Subinventory '||X_Destination_Subinventory ||' Database  Destination_Subinventory '||Recinfo.Destination_Subinventory);
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
    if (nvl(X_Wip_Entity_Id,-999)  <>  nvl(Recinfo.Wip_Entity_Id,-999)) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Wip_Entity_Id '||X_Wip_Entity_Id ||' Database  Wip_Entity_Id '||Recinfo.Wip_Entity_Id);
    end if;
    if (nvl(X_Wip_Operation_Seq_Num,-999) <> nvl(Recinfo.Wip_Operation_Seq_Num,-999)) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Wip_Operation_Seq_Num '||X_Wip_Operation_Seq_Num ||' Database  Wip_Operation_Seq_Num '||Recinfo.Wip_Operation_Seq_Num);
    end if;
    if (nvl(X_Wip_Resource_Seq_Num,-999) <> nvl(Recinfo.Wip_Resource_Seq_Num,-999)) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Wip_Resource_Seq_Num '||X_Wip_Resource_Seq_Num ||' Database  Wip_Resource_Seq_Num '||Recinfo.Wip_Resource_Seq_Num);
    end if;
    if (nvl(X_Wip_Repetitive_Schedule_Id,-999) <> nvl(Recinfo.Wip_Repetitive_Schedule_Id,-999)) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Wip_Repetitive_Schedule_Id '||X_Wip_Repetitive_Schedule_Id ||' Database  Wip_Repetitive_Schedule_Id '||Recinfo.Wip_Repetitive_Schedule_Id);
    end if;
    if (nvl(X_Wip_Line_Id,-999) <>  nvl(Recinfo.Wip_Line_Id ,-999)) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Wip_Line_Id '||X_Wip_Line_Id ||' Database  Wip_Line_Id '||Recinfo.Wip_Line_Id);
    end if;
    if (nvl(X_Bom_Resource_Id,-999) <> nvl(Recinfo.Bom_Resource_Id,-999)) then
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Bom_Resource_Id '||X_Bom_Resource_Id ||' Database  Bom_Resource_Id '||Recinfo.Bom_Resource_Id);
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
    if (nvl(X_Ussgl_Transaction_Code ,'-999') <> nvl( Recinfo.Ussgl_Transaction_Code,'-999')) then
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Ussgl_Transaction_Code '||X_Ussgl_Transaction_Code ||' Database  Ussgl_Transaction_Code '||Recinfo.Ussgl_Transaction_Code);
    end if;
    if (nvl(X_Government_Context,'-999') <> nvl( Recinfo.Government_Context,'-999')) then
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Government_Context '||X_Government_Context ||' Database  Government_Context '||Recinfo.Government_Context);
    end if;
    if (nvl(X_Destination_Context,'-999') <> nvl( Recinfo.Destination_Context,'-999')) then
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Destination_Context '||X_Destination_Context ||' Database  Destination_Context '||Recinfo.Destination_Context);
    end if;
    if (nvl(X_Distribution_Num,-999) <> nvl( Recinfo.Distribution_Num,-999)) then
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Distribution_Num '||X_Distribution_Num ||' Database  Distribution_Num '||Recinfo.Distribution_Num);
    end if;
    if (nvl(X_Source_Distribution_Id ,-999) <> nvl( Recinfo.Source_Distribution_Id ,-999)) then
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Source_Distribution_Id '||X_Source_Distribution_Id ||' Database  Source_Distribution_Id '||Recinfo.Source_Distribution_Id);
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
    if ( trunc(X_Gl_Closed_Date)  <>  trunc(Recinfo.Gl_Closed_Date) ) then
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Gl_Closed_Date '||X_Gl_Closed_Date ||' Database  Gl_Closed_Date '||Recinfo.Gl_Closed_Date);
    end if;
    if (nvl(X_Accrue_On_Receipt_Flag,'-999')  <>  nvl(Recinfo.Accrue_On_Receipt_Flag,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Accrue_On_Receipt_Flag '||X_Accrue_On_Receipt_Flag ||' Database  Accrue_On_Receipt_Flag '||Recinfo.Accrue_On_Receipt_Flag);
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
    if (nvl(p_dest_charge_account_id,-999)  <>  nvl(Recinfo.dest_charge_account_id,-999)) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form dest_charge_account_id '||p_dest_charge_account_id ||' Database  dest_charge_account_id '||Recinfo.dest_charge_account_id);
    end if;
    if (nvl(trunc(p_dest_variance_account_id),-999) <> nvl(trunc(Recinfo.dest_variance_account_id),-999)) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form dest_variance_account_id '||p_dest_variance_account_id ||' Database  dest_variance_account_id '||Recinfo.dest_variance_account_id);
    end if;
    if (nvl(X_amount_ordered,-999) <> nvl(Recinfo.amount_ordered,-999)) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form amount_ordered '||X_amount_ordered ||' Database  amount_ordered '||Recinfo.amount_ordered);
    end if;
    if (nvl(X_amount_to_encumber,-999) <> nvl(Recinfo.Recovery_Rate,-999)) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form amount_to_encumber '||X_amount_to_encumber ||' Database  amount_to_encumber '||Recinfo.amount_to_encumber);
    end if;
    if (nvl(X_distribution_type,'-999') <>  nvl(Recinfo.distribution_type ,'-999')) then
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form distribution_type '||X_distribution_type ||' Database  distribution_type '||Recinfo.distribution_type);
    end if;

     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name || '.end','Failed when comparing fields');

    END IF;       --end g_fnd_debug = 'Y'

          FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
          APP_EXCEPTION.RAISE_EXCEPTION;

      END Lock_Row;


      PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS

    l_return_status VARCHAR2(1);
    l_msg_data VARCHAR2(2000);
    l_msg_count NUMBER;
    l_distribution_id PO_DISTRIBUTIONS_ALL.po_distribution_id%TYPE;

    --<eTax Integration R12 Start>
    l_transaction_line_rec_type ZX_API_PUB.transaction_line_rec_type;
    l_distribution_type   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE;
    l_line_location_id    PO_DISTRIBUTIONS_ALL.line_location_id%TYPE;
    l_po_header_id        PO_DISTRIBUTIONS_ALL.po_header_id%TYPE;
    l_po_release_id       PO_DISTRIBUTIONS_ALL.po_release_id%TYPE;
    l_distribution_count  NUMBER;
    l_org_id              PO_DISTRIBUTIONS_ALL.org_id%type;
    --<eTax Integration R12 End>

  BEGIN
    DELETE FROM PO_DISTRIBUTIONS
    WHERE  rowid = X_Rowid
    RETURNING po_distribution_id, line_location_id, po_header_id, po_release_id, distribution_type, org_id
    INTO l_distribution_id, l_line_location_id, l_po_header_id, l_po_release_id, l_distribution_type, l_org_id; --<eTax Integration R12>

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    --<eTax Integration R12 Start> If any sibling distributions left, mark
    -- parent shipment as DIST_DELETE so that its tax distributions get
    -- redistributed with a call to determine_recovery later on.
    -- If there are no sibling distributions left then call
    -- delete_tax_distributions eTax API to delete corrsponding tax
    -- distributions
    IF l_distribution_type IN ('STANDARD','PLANNED','BLANKET','SCHEDULED') THEN

      -- count number of distributions
      SELECT COUNT(1) INTO l_distribution_count
      FROM po_distributions_all pd
      WHERE pd.line_location_id=l_line_location_id;

      IF (l_distribution_count = 0) THEN -- there are no sibling distributions

        l_transaction_line_rec_type.internal_organization_id := l_org_id;
        l_transaction_line_rec_type.application_id           := PO_CONSTANTS_SV.APPLICATION_ID;
        /* Bug 14004400: Applicaton id being passed to EB Tax was responsibility id rather than 201 which
               is pased when the tax lines are created. Same should be passed when they are deleted.  */
        l_transaction_line_rec_type.entity_code              := PO_CONSTANTS_SV.PO_ENTITY_CODE ;
        l_transaction_line_rec_type.event_class_code         := PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE;
        l_transaction_line_rec_type.event_type_code          := PO_CONSTANTS_SV.PO_ADJUSTED;
        l_transaction_line_rec_type.trx_id                   := NVL(l_po_release_id, l_po_header_id);
        l_transaction_line_rec_type.trx_level_type           := 'SHIPMENT';
        l_transaction_line_rec_type.trx_line_id              := l_line_location_id;

        -- Call eTax API to delete corrsponding tax distributions
        ZX_API_PUB.delete_tax_distributions(
          p_api_version             =>  1.0,
          p_init_msg_list           =>  FND_API.G_TRUE,
          p_commit                  =>  FND_API.G_FALSE,
          p_validation_level        =>  FND_API.G_VALID_LEVEL_FULL,
          x_return_status           =>  l_return_status,
          x_msg_count               =>  l_msg_count,
          x_msg_data                =>  l_msg_data,
          p_transaction_line_rec    =>  l_transaction_line_rec_type
        );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      ELSE -- there are sibling distributions

        -- Mark parent shipment as DIST_DELETE so that its tax distributions
        -- get redistributed with a call to determine_recovery later on
        UPDATE po_line_locations
        SET tax_attribute_update_code = 'DIST_DELETE'
        WHERE tax_attribute_update_code IS NULL
        AND line_location_id=l_line_location_id;

      END IF; --IF (l_distribution_count = 0)
    END IF; --IF l_distribution_type IN ...
    --<eTax Integration R12 End>


EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- Bug 3529594: vinokris
        -- Had to remove the sql_error procedure, since
        -- that was looking for a sql error number.
        PO_MESSAGE_S.app_error(
          error_name => 'PO_CUSTOM_MSG',
          token1     => 'TRANSLATED_TOKEN',
          value1     => l_msg_data);
        -- End Bug 3529594
        RAISE;

  END Delete_Row;


END PO_DISTRIBUTIONS_PKG2;

/
