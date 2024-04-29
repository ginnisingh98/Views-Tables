--------------------------------------------------------
--  DDL for Package Body PO_REQ_DISTRIBUTIONS_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQ_DISTRIBUTIONS_PKG1" as
/* $Header: POXRID1B.pls 120.2 2005/06/09 23:56:58 sjadhav noship $ */

       /**
	* For now, nonrecoverable and recoverable tax are not inserted and updated.
	* These values are set by the tax engine.
	**/

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Distribution_Id                IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Requisition_Line_Id            NUMBER,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Code_Combination_Id            NUMBER,
                       X_Req_Line_Quantity              NUMBER,
                       X_Req_Line_Amount                NUMBER, -- <SERVICES FPJ>
                       X_Req_Line_Currency_Amount       NUMBER, -- <SERVICES FPJ>
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Encumbered_Flag                VARCHAR2,
                       X_Gl_Encumbered_Date             DATE,
                       X_Gl_Encumbered_Period_Name      VARCHAR2,
                       X_Gl_Cancelled_Date              DATE,
                       X_Failed_Funds_Lookup_Code       VARCHAR2,
                       X_Encumbered_Amount              NUMBER,
                       X_Budget_Account_Id              NUMBER,
                       X_Accrual_Account_Id             NUMBER,
                       X_Variance_Account_Id            NUMBER,
                       X_Prevent_Encumbrance_Flag       VARCHAR2,
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
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Government_Context             VARCHAR2,
                       X_Project_Id                     NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Expenditure_Type               VARCHAR2,
                       X_Project_Accounting_Context     VARCHAR2,
                       X_Expenditure_Organization_Id    NUMBER,
                       X_Gl_Closed_Date                 DATE,
                       X_Source_Req_Distribution_Id     NUMBER,
                       X_Distribution_Num               NUMBER,
                       X_Project_Related_Flag           VARCHAR2,
                       X_Expenditure_Item_Date          DATE,
                       X_End_Item_Unit_Number           VARCHAR2 DEFAULT NULL,
		       X_Recovery_Rate			NUMBER,
		       X_Recoverable_Tax		NUMBER,
		       X_Nonrecoverable_Tax		NUMBER,
		       X_Tax_Recovery_Override_Flag	VARCHAR2,
		       -- OGM_0.0 change
		       X_award_id			NUMBER DEFAULT NULL ,
		       --togeorge 10/03/2000
		       -- added oke columns
		       x_oke_contract_line_id	   	NUMBER default null,
	               x_oke_contract_deliverable_id  	NUMBER default null,
                       p_org_id                  IN     NUMBER default null     -- <R12 MOAC>
		       )
   IS

     x_unique BOOLEAN := TRUE;

     CURSOR C IS SELECT rowid FROM PO_REQ_DISTRIBUTIONS
                 WHERE distribution_id = X_Distribution_Id;





      CURSOR C2 IS SELECT po_req_distributions_s.nextval FROM sys.dual;

    BEGIN

      /* Check if the distribution_number entered by user is unique */
      po_req_dist_sv.check_unique_insert(x_rowid,x_distribution_num,x_requisition_line_id);


      if (X_Distribution_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Distribution_Id;
        CLOSE C2;
      end if;

       INSERT INTO PO_REQ_DISTRIBUTIONS(
               distribution_id,
               last_update_date,
               last_updated_by,
               requisition_line_id,
               set_of_books_id,
               code_combination_id,
               req_line_quantity,
               req_line_amount,                               -- <SERVICES FPJ>
               req_line_currency_amount,                      -- <SERVICES FPJ>
               last_update_login,
               creation_date,
               created_by,
               encumbered_flag,
               gl_encumbered_date,
               gl_encumbered_period_name,
               gl_cancelled_date,
               failed_funds_lookup_code,
               encumbered_amount,
               budget_account_id,
               accrual_account_id,
               variance_account_id,
               prevent_encumbrance_flag,
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
               government_context,
               project_id,
               task_id,
               expenditure_type,
               project_accounting_context,
               expenditure_organization_id,
               gl_closed_date,
               source_req_distribution_id,
               distribution_num,
               project_related_flag,
               expenditure_item_date,
               end_item_unit_number,
	       recovery_rate,
	       -- JFMIP START
	       recoverable_tax,
	       nonrecoverable_tax,
	       -- JFMIP END
	       tax_recovery_override_flag,
		   award_id,  -- OGM_0.0 Changes
	       --togeorge 10/03/2000
	       -- added oke columns
	       oke_contract_line_id,
	       oke_contract_deliverable_id,
               Org_Id                  -- <R12 MOAC>
             ) VALUES (
               X_Distribution_Id,
               X_Last_Update_Date,
               X_Last_Updated_By,
               X_Requisition_Line_Id,
               X_Set_Of_Books_Id,
               X_Code_Combination_Id,
               X_Req_Line_Quantity,
               X_Req_Line_Amount,                             -- <SERVICES FPJ>
               X_Req_Line_Currency_Amount,                    -- <SERVICES FPJ>
               X_Last_Update_Login,
               X_Creation_Date,
               X_Created_By,
               X_Encumbered_Flag,
               X_Gl_Encumbered_Date,
               X_Gl_Encumbered_Period_Name,
               X_Gl_Cancelled_Date,
               X_Failed_Funds_Lookup_Code,
               X_Encumbered_Amount,
               X_Budget_Account_Id,
               X_Accrual_Account_Id,
               X_Variance_Account_Id,
               X_Prevent_Encumbrance_Flag,
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
               X_Government_Context,
               X_Project_Id,
               X_Task_Id,
               X_Expenditure_Type,
               X_Project_Accounting_Context,
               X_Expenditure_Organization_Id,
               X_Gl_Closed_Date,
               X_Source_Req_Distribution_Id,
               X_Distribution_Num,
               X_Project_Related_Flag,
               X_Expenditure_Item_Date,
               X_End_Item_Unit_Number,
	       X_Recovery_Rate,
	       -- JFMIP START
	       X_Recoverable_Tax,
	       X_Nonrecoverable_Tax,
	       -- JFMIP END
	       X_Tax_Recovery_Override_Flag,
		   X_Award_id,  -- OGM_0.0 Changes
	       --togeorge 10/03/2000
	       -- added oke columns
	       x_oke_contract_line_id,
	       x_oke_contract_deliverable_id,
               p_org_id                 -- <R12 MOAC>
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
                       X_Distribution_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Requisition_Line_Id            NUMBER,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Code_Combination_Id            NUMBER,
                       X_Req_Line_Quantity              NUMBER,
                       X_Req_Line_Amount                NUMBER, -- <SERVICES FPJ>
                       X_Req_Line_Currency_Amount       NUMBER, -- <SERVICES FPJ>
                       X_Last_Update_Login              NUMBER,
                       X_Encumbered_Flag                VARCHAR2,
                       X_Gl_Encumbered_Date             DATE,
                       X_Gl_Encumbered_Period_Name      VARCHAR2,
                       X_Gl_Cancelled_Date              DATE,
                       X_Failed_Funds_Lookup_Code       VARCHAR2,
                       X_Encumbered_Amount              NUMBER,
                       X_Budget_Account_Id              NUMBER,
                       X_Accrual_Account_Id             NUMBER,
                       X_Variance_Account_Id            NUMBER,
                       X_Prevent_Encumbrance_Flag       VARCHAR2,
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
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Government_Context             VARCHAR2,
                       X_Project_Id                     NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Expenditure_Type               VARCHAR2,
                       X_Project_Accounting_Context     VARCHAR2,
                       X_Expenditure_Organization_Id    NUMBER,
                       X_Gl_Closed_Date                 DATE,
                       X_Source_Req_Distribution_Id     NUMBER,
                       X_Distribution_Num               NUMBER,
                       X_Project_Related_Flag           VARCHAR2,
                       X_Expenditure_Item_Date          DATE,
                       X_End_Item_Unit_Number           VARCHAR2 DEFAULT NULL,
		       X_Recovery_Rate			NUMBER,
		       X_Recoverable_Tax		NUMBER,
		       X_Nonrecoverable_Tax		NUMBER,
		       X_Tax_Recovery_Override_Flag	VARCHAR2,
			-- OGM_0.0 changes..
		   X_Award_id				NUMBER DEFAULT NULL,
		       --togeorge 10/03/2000
		       -- added oke columns
		       x_oke_contract_line_id	   	NUMBER default null,
	               x_oke_contract_deliverable_id  	NUMBER default null) IS


 BEGIN
/*sugupta 760675 To avoid insynchronity between the client and server variables,
which caused the encumbered_flag and encumbered_amount passed from the client
as a variable (but was different from the values in the database, we update
encumbered_flag and encumbered_amount using database values rather than client
varables.
*/

   UPDATE PO_REQ_DISTRIBUTIONS
   SET
     distribution_id                   =     X_Distribution_Id,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     requisition_line_id               =     X_Requisition_Line_Id,
     set_of_books_id                   =     X_Set_Of_Books_Id,
     code_combination_id               =     X_Code_Combination_Id,
     req_line_quantity                 =     X_Req_Line_Quantity,
     req_line_amount                   =     X_Req_Line_Amount,          -- <SERVICES FPJ>
     req_line_currency_amount          =     X_Req_Line_Currency_Amount, -- <SERVICES FPJ>
     last_update_login                 =     X_Last_Update_Login,
     encumbered_flag                   =     encumbered_Flag,
     gl_encumbered_date                =     X_Gl_Encumbered_Date,
     gl_encumbered_period_name         =     X_Gl_Encumbered_Period_Name,
     gl_cancelled_date                 =     X_Gl_Cancelled_Date,
     failed_funds_lookup_code          =     X_Failed_Funds_Lookup_Code,
     encumbered_amount                 =     encumbered_Amount,
     budget_account_id                 =     X_Budget_Account_Id,
     accrual_account_id                =     X_Accrual_Account_Id,
     variance_account_id               =     X_Variance_Account_Id,
     prevent_encumbrance_flag          =     X_Prevent_Encumbrance_Flag,
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
     government_context                =     X_Government_Context,
     project_id                        =     X_Project_Id,
     task_id                           =     X_Task_Id,
     expenditure_type                  =     X_Expenditure_Type,
     project_accounting_context        =     X_Project_Accounting_Context,
     expenditure_organization_id       =     X_Expenditure_Organization_Id,
     gl_closed_date                    =     X_Gl_Closed_Date,
     source_req_distribution_id        =     X_Source_Req_Distribution_Id,
     distribution_num                  =     X_Distribution_Num,
     project_related_flag              =     X_Project_Related_Flag,
     expenditure_item_date             =     X_Expenditure_Item_Date,
     end_item_unit_number              =     X_End_Item_Unit_Number,
     recovery_rate		       =     X_Recovery_Rate,
     tax_recovery_override_flag	       =     X_Tax_Recovery_Override_Flag,
	 Award_id	               =     X_Award_id,
     --togeorge 10/03/2000
     -- added oke columns
     oke_contract_line_id	       =     x_oke_contract_line_id,
     oke_contract_deliverable_id       =     x_oke_contract_deliverable_id
   WHERE rowid = X_rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;


  END Update_Row;

END PO_REQ_DISTRIBUTIONS_PKG1;

/
