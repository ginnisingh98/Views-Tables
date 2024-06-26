--------------------------------------------------------
--  DDL for Package PO_DISTRIBUTIONS_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DISTRIBUTIONS_PKG1" AUTHID CURRENT_USER as
/* $Header: POXP1PDS.pls 120.0 2005/06/02 15:11:38 appldev noship $ */


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
                       X_Recovery_Rate                 	NUMBER,
                       X_Recoverable_Tax               	NUMBER,
                       X_Nonrecoverable_Tax            	NUMBER,
                       X_Tax_Recovery_Override_Flag    	VARCHAR2,
		       X_award_id			NUMBER DEFAULT NULL, -- OGM_0.0 changes
		       --togeorge 09/28/2000
		       --added  oke variables
		       X_oke_contract_line_id           IN NUMBER default null,
		       X_oke_contract_deliverable_id    IN NUMBER default null,
                       X_amount_ordered                 IN NUMBER default null,  -- <SERVICES FPJ>
                       X_distribution_type              IN VARCHAR2 default null, -- <ENCUMBRNACE FPJ>
                       X_amount_to_encumber             IN NUMBER default null,  -- <ENCUMBRNACE FPJ>
                       p_org_id                         IN NUMBER DEFAULT NULL   -- <R12 MOAC>
);

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
		       X_need_to_approve       IN OUT NOCOPY   NUMBER,
                       X_End_Item_Unit_Number           VARCHAR2 DEFAULT NULL,
                       X_Recovery_Rate                 	NUMBER,
                       X_Recoverable_Tax               	NUMBER,
                       X_Nonrecoverable_Tax            	NUMBER,
                       X_Tax_Recovery_Override_Flag    	VARCHAR2,
		       X_award_id			NUMBER DEFAULT NULL,  --OGM_0.0 changes..
		       --togeorge 09/28/2000
		       --added  oke variables
		       X_oke_contract_line_id           IN NUMBER default null,
		       X_oke_contract_deliverable_id    IN NUMBER default null,
                       X_amount_ordered                 IN NUMBER default null,  -- <SERVICES FPJ>
                       X_distribution_type              IN VARCHAR2 default null, -- <ENCUMBRANCE FPJ>
                       X_amount_to_encumber             IN NUMBER default null    -- <ENCUMBRANCE FPJ>
		       );

END PO_DISTRIBUTIONS_PKG1;

 

/
