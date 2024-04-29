--------------------------------------------------------
--  DDL for Package Body PO_DISTRIBUTIONS_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DISTRIBUTIONS_PKG1" as
/* $Header: POXP1PDB.pls 120.10.12000000.2 2007/10/17 11:53:41 ppadilam ship $ */


       /**
	* For now, nonrecoverable and recoverable tax are not inserted and updated.
	* These values are set by the tax engine.
	**/


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Po_Distribution_Id             IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Po_Header_Id                   NUMBER,
                       X_Po_Line_Id                     NUMBER,
                       X_Line_Location_Id               NUMBER,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Code_Combination_Id            NUMBER,
                       X_Quantity_Ordered               NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Po_Release_Id                  NUMBER,
                       X_Quantity_Delivered             NUMBER,
                       X_Quantity_Billed                NUMBER,
                       X_Quantity_Cancelled             NUMBER,
                       X_Req_Header_Reference_Num       VARCHAR2,
                       X_Req_Line_Reference_Num         VARCHAR2,
                       X_Req_Distribution_Id            NUMBER,
                       X_Deliver_To_Location_Id         NUMBER,
                       X_Deliver_To_Person_Id           NUMBER,
                       X_Rate_Date                      DATE,
                       X_Rate                           NUMBER,
                       X_Amount_Billed                  NUMBER,
                       X_Accrued_Flag                   VARCHAR2,
                       X_Encumbered_Flag                VARCHAR2,
                       X_Encumbered_Amount              NUMBER,
                       X_Unencumbered_Quantity          NUMBER,
                       X_Unencumbered_Amount            NUMBER,
                       X_Failed_Funds_Lookup_Code       VARCHAR2,
                       X_Gl_Encumbered_Date             DATE,
                       X_Gl_Encumbered_Period_Name      VARCHAR2,
                       X_Gl_Cancelled_Date              DATE,
                       X_Destination_Type_Code          VARCHAR2,
                       X_Destination_Organization_Id    NUMBER,
                       X_Destination_Subinventory       VARCHAR2,
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
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Wip_Entity_Id                  NUMBER,
                       X_Wip_Operation_Seq_Num          NUMBER,
                       X_Wip_Resource_Seq_Num           NUMBER,
                       X_Wip_Repetitive_Schedule_Id     NUMBER,
                       X_Wip_Line_Id                    NUMBER,
                       X_Bom_Resource_Id                NUMBER,
                       X_Budget_Account_Id              NUMBER,
                       X_Accrual_Account_Id             NUMBER,
                       X_Variance_Account_Id            NUMBER,

                       --< Shared Proc FPJ Start >
                       p_dest_charge_account_id           NUMBER,
                       p_dest_variance_account_id         NUMBER,
                       --< Shared Proc FPJ End >

                       X_Prevent_Encumbrance_Flag       VARCHAR2,
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Government_Context             VARCHAR2,
                       X_Destination_Context            VARCHAR2,
                       X_Distribution_Num               NUMBER,
                       X_Source_Distribution_Id         NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Expenditure_Type               VARCHAR2,
                       X_Project_Accounting_Context     VARCHAR2,
                       X_Expenditure_Organization_Id    NUMBER,
                       X_Gl_Closed_Date                 DATE,
                       X_Accrue_On_Receipt_Flag         VARCHAR2,
                       X_Expenditure_Item_Date          DATE,
                       X_End_Item_Unit_Number           VARCHAR2 DEFAULT NULL,
                       X_Recovery_Rate                  NUMBER,
                       X_Recoverable_Tax                NUMBER,
                       X_Nonrecoverable_Tax             NUMBER,
                       X_Tax_Recovery_Override_Flag     VARCHAR2,
                       -- OGM_0.0 Changes..
                       X_award_id                       NUMBER DEFAULT NULL,
                       --togeorge 09/28/2000
                       --added  oke variables
                       X_oke_contract_line_id         IN NUMBER default null,
                       X_oke_contract_deliverable_id  IN NUMBER default null,
                       X_amount_ordered               IN NUMBER default null,  -- <SERVICES FPJ>
                       X_distribution_type            IN VARCHAR2 default null, -- <ENCUMBRNACE FPJ>
                       X_amount_to_encumber           IN NUMBER default null,   -- <ENCUMBRNACE FPJ>
                       p_org_id                       IN NUMBER DEFAULT NULL   -- <R12 MOAC>
   ) IS
     CURSOR C IS SELECT rowid FROM PO_DISTRIBUTIONS
                 WHERE po_distribution_id = X_Po_Distribution_Id;



      CURSOR C2 IS SELECT po_distributions_s.nextval FROM sys.dual;

    l_tax_attribute_update_code PO_DISTRIBUTIONS_ALL.tax_attribute_update_code%type; --<eTax Integration R12>

    BEGIN
      if (X_Po_Distribution_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Po_Distribution_Id;
        CLOSE C2;
      end if;

      -- Bug: 1788262 insert 0 instead of NULL as that causes problem while querying the PO.

      --<eTax Integration R12>
      IF X_Distribution_Type IN ('STANDARD', 'PLANNED', 'BLANKET', 'SCHEDULED') THEN
        l_tax_attribute_update_code := 'CREATE';
      END IF;

   INSERT INTO PO_DISTRIBUTIONS(
               po_distribution_id,
               last_update_date,
               last_updated_by,
               po_header_id,
               po_line_id,
               line_location_id,
               set_of_books_id,
               code_combination_id,
               quantity_ordered,
               last_update_login,
               creation_date,
               created_by,
               po_release_id,
               quantity_delivered,
               quantity_billed,
               quantity_cancelled,
               req_header_reference_num,
               req_line_reference_num,
               req_distribution_id,
               deliver_to_location_id,
               deliver_to_person_id,
               rate_date,
               rate,
               amount_billed,
               accrued_flag,
               encumbered_flag,
               encumbered_amount,
               unencumbered_quantity,
               unencumbered_amount,
               failed_funds_lookup_code,
               gl_encumbered_date,
               gl_encumbered_period_name,
               gl_cancelled_date,
               destination_type_code,
               destination_organization_id,
               destination_subinventory,
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
               attribute11,
               attribute12,
               attribute13,
               attribute14,
               attribute15,
               wip_entity_id,
               wip_operation_seq_num,
               wip_resource_seq_num,
               wip_repetitive_schedule_id,
               wip_line_id,
               bom_resource_id,
               budget_account_id,
               accrual_account_id,
               variance_account_id,

               --< Shared Proc FPJ Start >
               dest_charge_account_id,
               dest_variance_account_id,
               --< Shared Proc FPJ End >

               prevent_encumbrance_flag,
               government_context,
               destination_context,
               distribution_num,
               source_distribution_id,
               project_id,
               task_id,
               expenditure_type,
               project_accounting_context,
               expenditure_organization_id,
               gl_closed_date,
               accrue_on_receipt_flag,
               expenditure_item_date,
               end_item_unit_number,
               recovery_rate,
               tax_recovery_override_flag,
               award_id,
               --togeorge 09/28/2000
               --added  oke variables
               oke_contract_line_id,
               oke_contract_deliverable_id,
               amount_ordered,  -- <SERVICES FPJ>
               distribution_type,  -- <ENCUMBRANCE FPJ>
               amount_to_encumber,  -- <ENCUMBRANCE FPJ>
               Org_Id,             -- <R12 MOAC>
               tax_attribute_update_code  --<eTax Integration R12>
             )
      VALUES (
               X_Po_Distribution_Id,
               X_Last_Update_Date,
               X_Last_Updated_By,
               X_Po_Header_Id,
               X_Po_Line_Id,
               X_Line_Location_Id,
               X_Set_Of_Books_Id,
               X_Code_Combination_Id,
               X_Quantity_ordered,                -- Bug 3202973
               X_Last_Update_Login,
               X_Creation_Date,
               X_Created_By,
               X_Po_Release_Id,
               -- X_Quantity_Delivered,
               -- X_Quantity_Billed,
               -- X_Quantity_Cancelled,
               nvl(X_Quantity_delivered,0),       -- Bug: 1788262
               nvl(X_Quantity_billed,0),          -- Bug: 1788262
               nvl(X_Quantity_cancelled,0),       -- Bug: 1788262
               X_Req_Header_Reference_Num,
               X_Req_Line_Reference_Num,
               X_Req_Distribution_Id,
               X_Deliver_To_Location_Id,
               X_Deliver_To_Person_Id,
               X_Rate_Date,
               X_Rate,
               X_Amount_Billed,
               X_Accrued_Flag,
               X_Encumbered_Flag,
               X_Encumbered_Amount,
               X_Unencumbered_Quantity,
               X_Unencumbered_Amount,
               X_Failed_Funds_Lookup_Code,
               X_Gl_Encumbered_Date,
               X_Gl_Encumbered_Period_Name,
               X_Gl_Cancelled_Date,
               X_Destination_Type_Code,
               X_Destination_Organization_Id,
               X_Destination_Subinventory,
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
               X_Attribute11,
               X_Attribute12,
               X_Attribute13,
               X_Attribute14,
               X_Attribute15,
               X_Wip_Entity_Id,
               X_Wip_Operation_Seq_Num,
               X_Wip_Resource_Seq_Num,
               X_Wip_Repetitive_Schedule_Id,
               X_Wip_Line_Id,
               X_Bom_Resource_Id,
               X_Budget_Account_Id,
               X_Accrual_Account_Id,
               X_Variance_Account_Id,

               --< Shared Proc FPJ Start >
               p_dest_charge_account_id,
               p_dest_variance_account_id,
               --< Shared Proc FPJ End >

               X_Prevent_Encumbrance_Flag,
               X_Government_Context,
               X_Destination_Context,
               X_Distribution_Num,
               X_Source_Distribution_Id,
               X_Project_Id,
               X_Task_Id,
               X_Expenditure_Type,
               X_Project_Accounting_Context,
               X_Expenditure_Organization_Id,
               X_Gl_Closed_Date,
               X_Accrue_On_Receipt_Flag,
               X_Expenditure_Item_Date,
               X_End_Item_Unit_Number,
               X_Recovery_Rate,
               X_Tax_Recovery_Override_Flag,
               X_Award_id,
               --togeorge 09/28/2000
               --added  oke variables
               X_oke_contract_line_id,
               X_oke_contract_deliverable_id,
               X_amount_ordered,  -- <SERVICES FPJ>
               X_distribution_type,  -- <ENCUMBRANCE FPJ>
               X_amount_to_encumber,  -- <ENCUMBRANCE FPJ>
               p_org_id,             -- <R12 MOAC>
               l_tax_attribute_update_code --<eTax Integration R12>
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

END Insert_Row;

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Po_Distribution_Id             NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Po_Header_Id                   NUMBER,
                       X_Po_Line_Id                     NUMBER,
                       X_Line_Location_Id               NUMBER,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Code_Combination_Id            NUMBER,
                       X_Quantity_Ordered               NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Po_Release_Id                  NUMBER,
                       X_Quantity_Delivered             NUMBER,
                       X_Quantity_Billed                NUMBER,
                       X_Quantity_Cancelled             NUMBER,
                       X_Req_Header_Reference_Num       VARCHAR2,
                       X_Req_Line_Reference_Num         VARCHAR2,
                       X_Req_Distribution_Id            NUMBER,
                       X_Deliver_To_Location_Id         NUMBER,
                       X_Deliver_To_Person_Id           NUMBER,
                       X_Rate_Date                      DATE,
                       X_Rate                           NUMBER,
                       X_Amount_Billed                  NUMBER,
                       X_Accrued_Flag                   VARCHAR2,
                       X_Encumbered_Flag                VARCHAR2,
                       X_Encumbered_Amount              NUMBER,
                       X_Unencumbered_Quantity          NUMBER,
                       X_Unencumbered_Amount            NUMBER,
                       X_Failed_Funds_Lookup_Code       VARCHAR2,
                       X_Gl_Encumbered_Date             DATE,
                       X_Gl_Encumbered_Period_Name      VARCHAR2,
                       X_Gl_Cancelled_Date              DATE,
                       X_Destination_Type_Code          VARCHAR2,
                       X_Destination_Organization_Id    NUMBER,
                       X_Destination_Subinventory       VARCHAR2,
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
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Wip_Entity_Id                  NUMBER,
                       X_Wip_Operation_Seq_Num          NUMBER,
                       X_Wip_Resource_Seq_Num           NUMBER,
                       X_Wip_Repetitive_Schedule_Id     NUMBER,
                       X_Wip_Line_Id                    NUMBER,
                       X_Bom_Resource_Id                NUMBER,
                       X_Budget_Account_Id              NUMBER,
                       X_Accrual_Account_Id             NUMBER,
                       X_Variance_Account_Id            NUMBER,

                       --< Shared Proc FPJ Start >
                       p_dest_charge_account_id           NUMBER,
                       p_dest_variance_account_id         NUMBER,
                       --< Shared Proc FPJ End >

                       X_Prevent_Encumbrance_Flag       VARCHAR2,
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Government_Context             VARCHAR2,
                       X_Destination_Context            VARCHAR2,
                       X_Distribution_Num               NUMBER,
                       X_Source_Distribution_Id         NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Expenditure_Type               VARCHAR2,
                       X_Project_Accounting_Context     VARCHAR2,
                       X_Expenditure_Organization_Id    NUMBER,
                       X_Gl_Closed_Date                 DATE,
                       X_Accrue_On_Receipt_Flag         VARCHAR2,
                       X_Expenditure_Item_Date          DATE,
		       X_need_to_approve        IN OUT NOCOPY  NUMBER,
                       X_End_Item_Unit_Number           VARCHAR2 DEFAULT NULL,
                       X_Recovery_Rate                 	NUMBER,
                       X_Recoverable_Tax               	NUMBER,
                       X_Nonrecoverable_Tax            	NUMBER,
                       X_Tax_Recovery_Override_Flag    	VARCHAR2,
		       -- OGM_0.0 changes..
		       X_award_id			NUMBER DEFAULT NULL,
		       --togeorge 09/28/2000
		       --added  oke variables
		       X_oke_contract_line_id         IN NUMBER default null,
		       X_oke_contract_deliverable_id  IN NUMBER default null,
                       X_amount_ordered               IN NUMBER default null,  -- <SERVICES FPJ>
                       X_distribution_type            IN VARCHAR2 default null, -- <ENCUMBRANCE FPJ>
                       X_amount_to_encumber           IN NUMBER default null    -- <ENCUMBRANCE FPJ>
) IS

    l_tax_attribute_update_code PO_DISTRIBUTIONS_ALL.tax_attribute_update_code%type; --<eTax integration R12>

 BEGIN


    --  Check if shipment needs to be unapproved.
    /* passed two extra parameters into this function
       Distribution_Num         - bug 1046786
       Destination_Subinventory - bug 1001768 */

    X_need_to_approve := po_dist_s.val_approval_status(
                                        X_Po_Distribution_Id,
                                        X_Distribution_Num ,
                                        X_Deliver_To_Person_Id,
                                        X_Quantity_Ordered,
                                        X_amount_ordered, -- Bug 5409088
                                        X_Rate,
                                        X_Rate_Date,
                                        X_Gl_Encumbered_Date,
                                        X_Code_Combination_Id,
					X_Project_Id  ,       -- Bug # 6408034
                                        --< Shared Proc FPJ Start >
                                        p_dest_charge_account_id,
                                        --< Shared Proc FPJ End >

                                        X_Recovery_Rate,
                                        X_Destination_Subinventory);

    --<eTax Integration R12 Start>
    IF X_Distribution_Type IN ('STANDARD', 'PLANNED', 'BLANKET', 'SCHEDULED') AND
      PO_TAX_INTERFACE_PVT.any_tax_attributes_updated(
        p_doc_type     => 'PO',
        p_doc_level    => 'DISTRIBUTION',
        p_doc_level_id => X_Po_Distribution_Id,
        p_ccid         => X_Code_Combination_Id,
        p_tax_rec_rate => X_Recovery_Rate,
        p_project      => X_Project_Id,
        p_task         => X_Task_Id,
        p_award        => X_award_id,
        p_exp_type     => X_Expenditure_Type,
        p_exp_org      => X_Expenditure_Organization_Id,
        p_exp_date     => X_Expenditure_Item_Date,
        p_dist_quantity_ordered => X_Quantity_Ordered,
        p_dist_amount_ordered => X_amount_ordered
      ) THEN
          l_tax_attribute_update_code := 'UPDATE';
    END IF;
    --<eTax Integration R12 End>

   UPDATE PO_DISTRIBUTIONS
   SET
     po_distribution_id                =     X_Po_Distribution_Id,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     po_header_id                      =     X_Po_Header_Id,
     po_line_id                        =     X_Po_Line_Id,
     line_location_id                  =     X_Line_Location_Id,
     set_of_books_id                   =     X_Set_Of_Books_Id,
     code_combination_id               =     X_Code_Combination_Id,
     quantity_ordered                  =     X_Quantity_Ordered,
     last_update_login                 =     X_Last_Update_Login,
     po_release_id                     =     X_Po_Release_Id,
     quantity_delivered                =     X_Quantity_Delivered,
     quantity_billed                   =     X_Quantity_Billed,
     quantity_cancelled                =     X_Quantity_Cancelled,
     req_header_reference_num          =     X_Req_Header_Reference_Num,
     req_line_reference_num            =     X_Req_Line_Reference_Num,
     req_distribution_id               =     X_Req_Distribution_Id,
     deliver_to_location_id            =     X_Deliver_To_Location_Id,
     deliver_to_person_id              =     X_Deliver_To_Person_Id,
     rate_date                         =     X_Rate_Date,
     rate                              =     X_Rate,
     amount_billed                     =     X_Amount_Billed,
     accrued_flag                      =     X_Accrued_Flag,
     encumbered_flag                   =     X_Encumbered_Flag,
     encumbered_amount                 =     X_Encumbered_Amount,
     unencumbered_quantity             =     X_Unencumbered_Quantity,
     unencumbered_amount               =     X_Unencumbered_Amount,
     failed_funds_lookup_code          =     X_Failed_Funds_Lookup_Code,
     gl_encumbered_date                =     X_Gl_Encumbered_Date,
     gl_encumbered_period_name         =     X_Gl_Encumbered_Period_Name,
     gl_cancelled_date                 =     X_Gl_Cancelled_Date,
     destination_type_code             =     X_Destination_Type_Code,
     destination_organization_id       =     X_Destination_Organization_Id,
     destination_subinventory          =     X_Destination_Subinventory,
     attribute_category                =     X_Attribute_Category,
     attribute1                        =     X_Attribute1,
     attribute2                        =     X_Attribute2,
     attribute3                        =     X_Attribute3,
     attribute4                        =     X_Attribute4,
     attribute5                        =     X_Attribute5,
     attribute6                        =     X_Attribute6,
     attribute7                        =     X_Attribute7,
     attribute8                        =     X_Attribute8,
     attribute9                        =     X_Attribute9,
     attribute10                       =     X_Attribute10,
     attribute11                       =     X_Attribute11,
     attribute12                       =     X_Attribute12,
     attribute13                       =     X_Attribute13,
     attribute14                       =     X_Attribute14,
     attribute15                       =     X_Attribute15,
     wip_entity_id                     =     X_Wip_Entity_Id,
     wip_operation_seq_num             =     X_Wip_Operation_Seq_Num,
     wip_resource_seq_num              =     X_Wip_Resource_Seq_Num,
     wip_repetitive_schedule_id        =     X_Wip_Repetitive_Schedule_Id,
     wip_line_id                       =     X_Wip_Line_Id,
     bom_resource_id                   =     X_Bom_Resource_Id,
     budget_account_id                 =     X_Budget_Account_Id,
     accrual_account_id                =     X_Accrual_Account_Id,
     variance_account_id               =     X_Variance_Account_Id,

     --< Shared Proc FPJ Start >
     dest_charge_account_id            =     p_dest_charge_account_id,
     dest_variance_account_id          =     p_dest_variance_account_id,
     --< Shared Proc FPJ End >

     prevent_encumbrance_flag          =     X_Prevent_Encumbrance_Flag,
     government_context                =     X_Government_Context,
     destination_context               =     X_Destination_Context,
     distribution_num                  =     X_Distribution_Num,
     source_distribution_id            =     X_Source_Distribution_Id,
     project_id                        =     X_Project_Id,
     task_id                           =     X_Task_Id,
     expenditure_type                  =     X_Expenditure_Type,
     project_accounting_context        =     X_Project_Accounting_Context,
     expenditure_organization_id       =     X_Expenditure_Organization_Id,
     gl_closed_date                    =     X_Gl_Closed_Date,
     accrue_on_receipt_flag            =     X_Accrue_On_Receipt_Flag,
     expenditure_item_date             =     X_Expenditure_Item_Date,
     end_item_unit_number              =     X_End_Item_Unit_Number,
     recovery_rate                     =     X_Recovery_Rate,
     tax_recovery_override_flag	       =     X_Tax_Recovery_Override_Flag,
     award_id			       =     X_award_id, -- OGM_0.0 changes...
     --togeorge 09/28/2000
     --added  oke variables
     oke_contract_line_id  	       =     X_oke_contract_line_id,
     oke_contract_deliverable_id       =     X_oke_contract_deliverable_id,
     amount_ordered                    =     X_amount_ordered,   -- <SERVICES FPJ>
     distribution_type                 =     X_distribution_type, -- <ENCUMBRANCE FPJ>
     amount_to_encumber                =     X_amount_to_encumber,  -- <ENCUMBRANCE FPJ>
     tax_attribute_update_code         =     NVL(tax_attribute_update_code, --<eTax Integration R12>
                                                 l_tax_attribute_update_code)
   WHERE rowid = X_rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

END Update_Row;

END PO_DISTRIBUTIONS_PKG1;

/
