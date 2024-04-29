--------------------------------------------------------
--  DDL for Package PA_TXN_INTERFACE_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TXN_INTERFACE_ITEMS_PKG" AUTHID CURRENT_USER as
/* $Header: PAXRTXNS.pls 120.2 2005/08/03 12:32:33 aaggarwa noship $ */

   -- PA.K changes
   TYPE Txn_Interface_Id_Typ              IS TABLE OF Pa_Transaction_Interface_All.Txn_Interface_Id%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Transaction_Source_Typ            IS TABLE OF Pa_Transaction_Interface_All.Transaction_Source%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE User_Transaction_Source_Typ       IS TABLE OF Pa_Transaction_Interface_All.User_Transaction_Source%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Batch_Name_Typ                    IS TABLE OF Pa_Transaction_Interface_All.Batch_Name%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Expenditure_End_Date_Typ          IS TABLE OF Pa_Transaction_Interface_All.Expenditure_Ending_Date%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Person_Business_Group_Name_Typ    IS TABLE OF Pa_Transaction_Interface_All.Person_Business_Group_Name%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Person_Business_Group_Id_Typ      IS TABLE OF Pa_Transaction_Interface_All.Person_Business_Group_Id%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Employee_Number_Typ               IS TABLE OF Pa_Transaction_Interface_All.Employee_Number%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Person_Id_Typ                     IS TABLE OF Pa_Transaction_Interface_All.Person_Id%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Organization_Name_Typ             IS TABLE OF Pa_Transaction_Interface_All.Organization_Name%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Organization_Id_Typ               IS TABLE OF Pa_Transaction_Interface_All.Organization_Id%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Expenditure_Item_Date_Typ         IS TABLE OF Pa_Transaction_Interface_All.Expenditure_Item_Date%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Project_Number_Typ                IS TABLE OF Pa_Transaction_Interface_All.Project_Number%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Project_Id_Typ      		  IS TABLE OF Pa_Transaction_Interface_All.Project_Id%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Task_Number_Typ                   IS TABLE OF Pa_Transaction_Interface_All.Task_Number%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Task_Id_Typ                       IS TABLE OF Pa_Transaction_Interface_All.Task_Id%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Expenditure_Type_Typ              IS TABLE OF Pa_Transaction_Interface_All.Expenditure_Type%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE System_Linkage_Typ                IS TABLE OF Pa_Transaction_Interface_All.System_Linkage%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Non_Labor_Resource_Typ            IS TABLE OF Pa_Transaction_Interface_All.Non_Labor_Resource%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Non_Labor_Res_Org_Name_Typ        IS TABLE OF Pa_Transaction_Interface_All.Non_Labor_Resource_Org_Name%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Non_Labor_Res_Org_Id_Typ          IS TABLE OF Pa_Transaction_Interface_All.Non_Labor_Resource_Org_Id%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Quantity_Typ                      IS TABLE OF Pa_Transaction_Interface_All.Quantity%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Raw_Cost_Typ                      IS TABLE OF Pa_Transaction_Interface_All.Raw_Cost%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Raw_Cost_Rate_Typ                 IS TABLE OF Pa_Transaction_Interface_All.Raw_Cost_Rate%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Burden_Cost_Typ                   IS TABLE OF Pa_Transaction_Interface_All.Burdened_Cost%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Burden_Cost_Rate_Typ              IS TABLE OF Pa_Transaction_Interface_All.Burdened_Cost_Rate%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Expenditure_Comment_Typ           IS TABLE OF Pa_Transaction_Interface_All.Expenditure_Comment%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Gl_Date_Typ                       IS TABLE OF Pa_Transaction_Interface_All.Gl_Date%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Transaction_Status_Code_Typ       IS TABLE OF Pa_Transaction_Interface_All.Transaction_Status_Code%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Transaction_Rejection_Code_Typ    IS TABLE OF Pa_Transaction_Interface_All.Transaction_Rejection_Code%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Orig_Transaction_Reference_Typ    IS TABLE OF Pa_Transaction_Interface_All.Orig_Transaction_Reference%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Unmatched_Neg_Txn_Flag_Typ        IS TABLE OF Pa_Transaction_Interface_All.Unmatched_Negative_Txn_Flag%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Expenditure_Id_Typ                IS TABLE OF Pa_Transaction_Interface_All.Expenditure_Id%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Attribute_Category_Typ            IS TABLE OF Pa_Transaction_Interface_All.Attribute_Category%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Attribute1_Typ                    IS TABLE OF Pa_Transaction_Interface_All.Attribute1%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Attribute2_Typ                    IS TABLE OF Pa_Transaction_Interface_All.Attribute2%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Attribute3_Typ                    IS TABLE OF Pa_Transaction_Interface_All.Attribute3%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Attribute4_Typ                    IS TABLE OF Pa_Transaction_Interface_All.Attribute4%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Attribute5_Typ                    IS TABLE OF Pa_Transaction_Interface_All.Attribute5%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Attribute6_Typ                    IS TABLE OF Pa_Transaction_Interface_All.Attribute6%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Attribute7_Typ                    IS TABLE OF Pa_Transaction_Interface_All.Attribute7%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Attribute8_Typ                    IS TABLE OF Pa_Transaction_Interface_All.Attribute8%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Attribute9_Typ                    IS TABLE OF Pa_Transaction_Interface_All.Attribute9%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Attribute10_Typ                   IS TABLE OF Pa_Transaction_Interface_All.Attribute10%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Dr_Code_Combination_Id_Typ        IS TABLE OF Pa_Transaction_Interface_All.Dr_Code_Combination_Id%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Cr_Code_Combination_Id_Typ        IS TABLE OF Pa_Transaction_Interface_All.Cr_Code_Combination_Id%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Cdl_System_Reference1_Typ         IS TABLE OF Pa_Transaction_Interface_All.Cdl_System_Reference1%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Cdl_System_Reference2_Typ         IS TABLE OF Pa_Transaction_Interface_All.Cdl_System_Reference2%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Cdl_System_Reference3_Typ         IS TABLE OF Pa_Transaction_Interface_All.Cdl_System_Reference3%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Interface_Id_Typ                  IS TABLE OF Pa_Transaction_Interface_All.Interface_Id%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE	Receipt_Currency_Amount_Typ       IS TABLE OF Pa_Transaction_Interface_All.Receipt_Currency_Amount%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Receipt_Currency_Code_Typ         IS TABLE OF Pa_Transaction_Interface_All.Receipt_Currency_Code%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Receipt_Exchange_Rate_Typ         IS TABLE OF Pa_Transaction_Interface_All.Receipt_Exchange_Rate%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Denom_Currency_Code_Typ           IS TABLE OF Pa_Transaction_Interface_All.Denom_Currency_Code%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Denom_Raw_Cost_Typ                IS TABLE OF Pa_Transaction_Interface_All.Denom_Raw_Cost%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Denom_Burdened_Cost_Typ           IS TABLE OF Pa_Transaction_Interface_All.Denom_Burdened_Cost%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Acct_Rate_Date_Typ                IS TABLE OF Pa_Transaction_Interface_All.Acct_Rate_Date%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Acct_Rate_Type_Typ                IS TABLE OF Pa_Transaction_Interface_All.Acct_Rate_Type%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Acct_Exchange_Rate_Typ            IS TABLE OF Pa_Transaction_Interface_All.Acct_Exchange_Rate%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Acct_Raw_Cost_Typ                 IS TABLE OF Pa_Transaction_Interface_All.Acct_Raw_Cost%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Acct_Burdened_Cost_Typ            IS TABLE OF Pa_Transaction_Interface_All.Acct_Burdened_Cost%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Acct_Exch_Rounding_Limit_Typ      IS TABLE OF Pa_Transaction_Interface_All.Acct_Exchange_Rounding_Limit%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Project_Currency_Code_Typ         IS TABLE OF Pa_Transaction_Interface_All.Project_Currency_Code%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Project_Rate_Date_Typ             IS TABLE OF Pa_Transaction_Interface_All.Project_Rate_Date%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Project_Rate_Type_Typ             IS TABLE OF Pa_Transaction_Interface_All.Project_Rate_Type%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Project_Exchange_Rate_Typ         IS TABLE OF Pa_Transaction_Interface_All.Project_Exchange_Rate%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Orig_Exp_Txn_Reference1_Typ       IS TABLE OF Pa_Transaction_Interface_All.Orig_Exp_Txn_Reference1%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Orig_Exp_Txn_Reference2_Typ       IS TABLE OF Pa_Transaction_Interface_All.Orig_Exp_Txn_Reference2%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Orig_Exp_Txn_Reference3_Typ       IS TABLE OF Pa_Transaction_Interface_All.Orig_Exp_Txn_Reference2%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Orig_User_Exp_Txn_Ref_Typ         IS TABLE OF Pa_Transaction_Interface_All.Orig_User_Exp_Txn_Reference%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Vendor_Number_Typ                 IS TABLE OF Pa_Transaction_Interface_All.Vendor_Number%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE	Vendor_Id_Typ                     IS TABLE OF Pa_Transaction_Interface_All.Vendor_Id%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Override_To_Org_Name_Typ          IS TABLE OF Pa_Transaction_Interface_All.Override_To_Organization_Name%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE	Override_To_Org_Id_Typ            IS TABLE OF Pa_Transaction_Interface_All.Override_To_Organization_Id%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Reversed_Orig_Txn_Ref_Typ         IS TABLE OF Pa_Transaction_Interface_All.Reversed_Orig_Txn_Reference%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Billable_Flag_Typ                 IS TABLE OF Pa_Transaction_Interface_All.Billable_Flag%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE ProjFunc_Currency_Code_Typ        IS TABLE OF Pa_Transaction_Interface_All.ProjFunc_Currency_Code%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE ProjFunc_Cost_Rate_Date_Typ       IS TABLE OF Pa_Transaction_Interface_All.ProjFunc_Cost_Rate_Date%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE ProjFunc_Cost_Rate_Type_Typ       IS TABLE OF Pa_Transaction_Interface_All.ProjFunc_Cost_Rate_Type%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE ProjFunc_Cost_Exch_Rate_Typ       IS TABLE OF Pa_Transaction_Interface_All.ProjFunc_Cost_Exchange_Rate%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Project_Raw_Cost_Typ              IS TABLE OF Pa_Transaction_Interface_All.Project_Raw_Cost%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Project_Burdened_Cost_Typ         IS TABLE OF Pa_Transaction_Interface_All.Project_Burdened_Cost%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Assignment_Name_Typ               IS TABLE OF Pa_Transaction_Interface_All.Assignment_Name%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE	Assignment_Id_Typ                 IS TABLE OF Pa_Transaction_Interface_All.Assignment_Id%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Work_Type_Name_Typ                IS TABLE OF Pa_Transaction_Interface_All.Work_Type_Name%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Work_Type_Id_Typ                  IS TABLE OF Pa_Transaction_Interface_All.Work_Type_Id%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Cdl_System_Reference4_Typ         IS TABLE OF Pa_Transaction_Interface_All.Cdl_System_Reference4%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Accrual_flag_Typ                  IS TABLE OF Pa_Transaction_Interface_All.Accrual_Flag%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Last_Update_Date_Typ              IS TABLE OF Pa_Transaction_Interface_All.Last_Update_Date%TYPE
        INDEX BY BINARY_INTEGER;
   TYPE Last_Updated_By_Typ               IS TABLE OF Pa_Transaction_Interface_All.Last_Updated_By%TYPE
        INDEX BY BINARY_INTEGER;
   TYPE Creation_Date_Typ                 IS TABLE OF Pa_Transaction_Interface_All.Creation_Date%TYPE
        INDEX BY BINARY_INTEGER;
   TYPE Created_By_Typ                    IS TABLE OF Pa_Transaction_Interface_All.Created_By%TYPE
        INDEX BY BINARY_INTEGER;
   -- Begin PA.M/CWK changes
   TYPE PO_Number_Typ			  IS TABLE OF Pa_Transaction_Interface_All.PO_Number%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE PO_Header_Id_Typ		  IS TABLE OF Pa_Transaction_Interface_All.PO_Header_Id%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE PO_Line_Num_Typ		  	  IS TABLE OF Pa_Transaction_Interface_All.PO_Line_Num%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE PO_Line_Id_Typ			  IS TABLE OF Pa_Transaction_Interface_All.PO_Line_Id%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE PO_Price_Type_Typ		  IS TABLE OF Pa_Transaction_Interface_All.PO_Price_Type%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Person_Type_Typ			  IS TABLE OF Pa_Transaction_Interface_All.Person_Type%TYPE
	INDEX BY BINARY_INTEGER;
   -- End PA.M/CWK changes
   TYPE Inventory_Item_Id_Typ		  IS TABLE OF Pa_Transaction_Interface_All.Inventory_Item_Id%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE WIP_Resource_Id_Typ		  IS TABLE OF Pa_Transaction_Interface_All.WIP_Resource_Id%TYPE
	INDEX BY BINARY_INTEGER;
   TYPE Unit_Of_Measure_Typ		  IS TABLE OF Pa_Transaction_Interface_All.Unit_Of_Measure%TYPE
	INDEX BY BINARY_INTEGER;
   -- 12i MOAC changes
   Type OU_Id_Typ                 IS TABLE OF Pa_Transaction_Interface_All.Org_Id%TYPE
    INDEX BY BINARY_INTEGER;

  Procedure Insert_Row (
	x_rowid		    IN OUT NOCOPY VARCHAR2,
        x_txn_interface_id  IN OUT NOCOPY NUMBER,
        x_last_update_date	       IN DATE,
        x_last_updated_by	       IN NUMBER,
        x_creation_date		       IN DATE,
        x_created_by		       IN NUMBER,
        x_transaction_source           IN VARCHAR2,
        x_user_txn_source              IN VARCHAR2,
        x_batch_name                   IN VARCHAR2,
        x_expenditure_end_date         IN DATE    ,
        x_person_business_group_name   IN VARCHAR2 default NULL,
        x_employee_number              IN VARCHAR2,
        x_organization_name            IN VARCHAR2,
        x_expenditure_item_date        IN DATE,
        x_project_number               IN VARCHAR2,
        x_task_number                  IN VARCHAR2,
        x_expenditure_type             IN VARCHAR2,
        x_system_linkage               IN VARCHAR2,
        x_non_labor_resource           IN VARCHAR2,
        x_non_labor_res_org            IN VARCHAR2,
        x_quantity                     IN NUMBER,
        x_raw_cost                     IN NUMBER,
        x_raw_cost_rate                IN NUMBER,
        x_burden_cost                  IN NUMBER,
        x_burden_cost_rate             IN NUMBER,
        x_expenditure_comment          IN VARCHAR2,
        x_gl_date                      IN DATE,
        x_txn_status_code              IN VARCHAR2,
        x_txn_rejection_code           IN VARCHAR2,
        x_org_txn_reference            IN VARCHAR2,
        x_unmatched_txn_flag           IN VARCHAR2,
        x_expenditure_id               IN NUMBER,
        x_attribute_category           IN VARCHAR2,
        x_attribute1                   IN VARCHAR2,
        x_attribute2                   IN VARCHAR2,
        x_attribute3                   IN VARCHAR2,
        x_attribute4                   IN VARCHAR2,
        x_attribute5                   IN VARCHAR2,
        x_attribute6                   IN VARCHAR2,
        x_attribute7                   IN VARCHAR2,
        x_attribute8                   IN VARCHAR2,
        x_attribute9                   IN VARCHAR2,
        x_attribute10                  IN VARCHAR2,
        x_dr_ccid                      IN NUMBER,
        x_cr_ccid                      IN NUMBER,
        x_cdl_sys_ref1                 IN VARCHAR2,
        x_cdl_sys_ref2                 IN VARCHAR2,
        x_cdl_sys_ref3                 IN VARCHAR2,
        x_xface_id                     IN NUMBER,
	    x_receipt_currency_amount      IN NUMBER,
        x_receipt_currency_code        IN VARCHAR2,
        x_receipt_exchange_rate        IN NUMBER,
        x_denom_currency_code          IN VARCHAR2,
        x_denom_raw_cost               IN NUMBER,
        x_denom_burdened_cost          IN NUMBER,
        x_acct_rate_date               IN DATE,
        x_acct_rate_type               IN VARCHAR2,
        x_acct_exchange_rate           IN NUMBER,
        x_acct_raw_cost                IN NUMBER,
        x_acct_burdened_cost           IN NUMBER,
        x_acct_exchange_rounding_limit IN NUMBER,
        x_project_currency_code        IN VARCHAR2,
        x_project_rate_date            IN DATE,
        x_project_rate_type            IN VARCHAR2,
        x_project_exchange_rate        IN NUMBER,
        x_orig_exp_txn_reference1      IN VARCHAR2,
        x_orig_exp_txn_reference2      IN VARCHAR2,
        x_orig_exp_txn_reference3      IN VARCHAR2,
        x_orig_user_exp_txn_reference  IN VARCHAR2,
        x_vendor_number                IN VARCHAR2,
        x_override_to_oname            IN VARCHAR2,
        -- SST Changes
        x_reversed_orig_txn_reference  IN VARCHAR2 							DEFAULT NULL,
        x_billable_flag                IN VARCHAR2 							DEFAULT NULL,
        -- PA-I Changes
        X_Projfunc_currency_code       IN VARCHAR2 							DEFAULT NULL,
        X_Projfunc_cost_rate_date      IN DATE 								DEFAULT NULL,
        X_Projfunc_cost_rate_type      IN VARCHAR2 							DEFAULT NULL,
        X_Projfunc_cost_exchange_rate  IN NUMBER 							DEFAULT NULL,
        X_project_raw_cost             IN NUMBER 							DEFAULT NULL,
        X_project_burdened_cost        IN NUMBER 							DEFAULT NULL,
        X_Assignment_Name              IN VARCHAR2 							DEFAULT NULL,
        X_Work_Type_Name               IN VARCHAR2 							DEFAULT NULL,
        -- AP Discounts
        x_cdl_sys_ref4                 IN VARCHAR2 							DEFAULT NULL,
        -- PA-J changes
        x_Accrual_flag                 IN VARCHAR2 							DEFAULT NULL,
	    -- Pa-K Changes
	    P_Project_Id                   IN Pa_Transaction_Interface_All.Project_Id%TYPE 			DEFAULT NULL,
	    P_Task_Id                      IN Pa_Transaction_Interface_All.Task_Id%TYPE 			DEFAULT NULL,
	    P_Person_Business_Group_Id     IN Pa_Transaction_Interface_All.Person_Business_Group_Id%TYPE 	DEFAULT NULL,
	    P_Person_Id                    IN Pa_Transaction_Interface_All.Person_Id%TYPE 			DEFAULT NULL,
	    P_Organization_Id              IN Pa_Transaction_Interface_All.Organization_Id%TYPE 		DEFAULT NULL,
	    P_Non_Labor_Res_Org_Id         IN Pa_Transaction_Interface_All.Non_Labor_Resource_Org_Id%TYPE 	DEFAULT NULL,
	    P_Override_To_Org_Id           IN Pa_Transaction_Interface_All.Override_To_Organization_Id%TYPE DEFAULT NULL,
	    P_Assignment_Id                IN Pa_Transaction_Interface_All.Assignment_Id%TYPE 		DEFAULT NULL,
	    P_Work_Type_Id                 IN Pa_Transaction_Interface_All.Work_Type_Id%TYPE 		DEFAULT NULL,
	    P_Vendor_Id                    IN Pa_Transaction_Interface_All.Vendor_Id%TYPE 			DEFAULT NULL,
	    -- PA.M/CWK changes
        P_PO_Number		               IN Pa_Transaction_Interface_All.PO_Number%TYPE 			DEFAULT NULL,
        P_PO_Header_Id   	           IN Pa_Transaction_Interface_All.PO_Header_Id%TYPE 		DEFAULT NULL,
        P_PO_Line_Num		           IN Pa_Transaction_Interface_All.PO_Line_Num%TYPE 		DEFAULT NULL,
        P_PO_Line_Id    	           IN Pa_Transaction_Interface_All.PO_Line_Id%TYPE 			DEFAULT NULL,
        P_PO_Price_Type 	           IN Pa_Transaction_Interface_All.PO_Price_Type%TYPE 		DEFAULT NULL,
        P_Person_Type   	           IN Pa_Transaction_Interface_All.Person_Type%TYPE 		DEFAULT NULL,
	    -- End PA.M/CWK changes
	    P_Inventory_Item_Id	           IN Pa_Transaction_Interface_All.Inventory_Item_Id%TYPE 		DEFAULT NULL,
	    P_WIP_Resource_Id	           IN Pa_Transaction_Interface_All.WIP_Resource_Id%TYPE 		DEFAULT NULL,
	    P_Unit_Of_Measure	           IN Pa_Transaction_Interface_All.Unit_Of_Measure%TYPE 		DEFAULT NULL,
        -- 12i MOAC changes
        P_Org_Id                       IN Pa_Transaction_Interface_All.Org_Id%TYPE                  DEFAULT NULL);

 Procedure Update_Row (
	X_RowId                        IN VARCHAR2,
	X_Txn_Interface_Id	           IN NUMBER,
	X_Last_Update_Date	           IN DATE,
	X_Last_Updated_By	           IN NUMBER,
	X_Creation_Date		           IN DATE,
	X_Created_By		           IN NUMBER,
	X_Transaction_Source           IN VARCHAR2,
	X_User_Txn_Source              IN VARCHAR2,
	X_Batch_Name                   IN VARCHAR2,
	X_Expenditure_End_Date         IN DATE,
	X_Person_Business_Group_Name   IN VARCHAR2 							default NULL,
	X_Employee_Number              IN VARCHAR2,
	X_Organization_Name            IN VARCHAR2,
	X_Expenditure_Item_Date        IN DATE,
	X_Project_Number               IN VARCHAR2,
	X_Task_Number                  IN VARCHAR2,
	X_Expenditure_Type             IN VARCHAR2,
	X_System_Linkage               IN VARCHAR2,
	X_Non_Labor_Resource           IN VARCHAR2,
	X_Non_Labor_Res_Org            IN VARCHAR2,
	X_Quantity                     IN NUMBER,
	X_Raw_Cost                     IN NUMBER,
	X_Raw_Cost_Rate                IN NUMBER,
	X_Burden_Cost                  IN NUMBER,
	X_Burden_Cost_Rate             IN NUMBER,
	X_Expenditure_Comment          IN VARCHAR2,
	X_Gl_Date                      IN DATE,
	X_Txn_Status_Code              IN VARCHAR2,
	X_Txn_Rejection_Code           IN VARCHAR2,
	X_Org_Txn_Reference            IN VARCHAR2,
	X_Unmatched_Txn_Flag           IN VARCHAR2,
	X_Expenditure_Id               IN NUMBER,
	X_Attribute_Category           IN VARCHAR2,
	X_Attribute1                   IN VARCHAR2,
	X_Attribute2                   IN VARCHAR2,
	X_Attribute3                   IN VARCHAR2,
	X_Attribute4                   IN VARCHAR2,
	X_Attribute5                   IN VARCHAR2,
	X_Attribute6                   IN VARCHAR2,
	X_Attribute7                   IN VARCHAR2,
	X_Attribute8                   IN VARCHAR2,
	X_Attribute9                   IN VARCHAR2,
	X_Attribute10                  IN VARCHAR2,
	X_Dr_Ccid                      IN NUMBER,
	X_Cr_Ccid                      IN NUMBER,
	X_Cdl_Sys_Ref1                 IN VARCHAR2,
	X_Cdl_Sys_Ref2                 IN VARCHAR2,
	X_Cdl_Sys_Ref3                 IN VARCHAR2,
	X_Receipt_Currency_Amount      IN NUMBER,
	X_Receipt_Currency_Code        IN VARCHAR2,
	X_Receipt_Exchange_Rate        IN NUMBER,
	X_Denom_Currency_Code          IN VARCHAR2,
	X_Denom_Raw_Cost               IN NUMBER,
	X_Denom_Burdened_Cost          IN NUMBER,
	X_Acct_Rate_Date               IN DATE,
	X_Acct_Rate_Type               IN VARCHAR2,
	X_Acct_Exchange_Rate           IN NUMBER,
	X_Acct_Raw_Cost                IN NUMBER,
	X_Acct_Burdened_Cost           IN NUMBER,
	X_Acct_Exchange_Rounding_Limit IN NUMBER,
	X_Project_Currency_Code        IN VARCHAR2,
	X_Project_Rate_Date            IN DATE,
	X_Project_Rate_Type            IN VARCHAR2,
	X_Project_Exchange_Rate        IN NUMBER,
	X_Orig_Exp_Txn_Reference1      IN VARCHAR2,
	X_Orig_Exp_Txn_Reference2      IN VARCHAR2,
	X_Orig_Exp_Txn_Reference3      IN VARCHAR2,
	X_Orig_User_Exp_Txn_Reference  IN VARCHAR2,
	X_Vendor_Number                IN VARCHAR2,
	X_Override_To_Oname            IN VARCHAR2,
	-- SST Changes
	X_Reversed_Orig_Txn_Reference  IN VARCHAR2 							DEFAULT NULL,
	X_Billable_Flag                IN VARCHAR2 							DEFAULT NULL,
	-- PA-I Changes
	X_ProjFunc_Currency_Code       IN VARCHAR2 							DEFAULT NULL,
	X_ProjFunc_Cost_Rate_Date      IN DATE 								DEFAULT NULL,
	X_ProjFunc_Cost_Rate_Type      IN VARCHAR2 							DEFAULT NULL,
	X_ProjFunc_Cost_Exchange_Rate  IN NUMBER 							DEFAULT NULL,
	X_Project_Raw_Cost             IN NUMBER 							DEFAULT NULL,
	X_Project_Burdened_Cost        IN NUMBER 							DEFAULT NULL,
	X_Assignment_Name              IN VARCHAR2 							DEFAULT NULL,
	X_Work_Type_Name               IN VARCHAR2 							DEFAULT NULL,
	-- AP Discounts
	X_Cdl_Sys_Ref4                 IN VARCHAR2 							DEFAULT NULL,
	-- PA-J changes
    X_Accrual_flag                 IN VARCHAR2 							DEFAULT NULL,
	-- PA-K Changes
	P_Project_Id                   IN Pa_Transaction_Interface_All.Project_Id%TYPE 			DEFAULT NULL,
	P_Task_Id                      IN Pa_Transaction_Interface_All.Task_Id%TYPE 			DEFAULT NULL,
	P_Person_Business_Group_Id     IN Pa_Transaction_Interface_All.Person_Business_Group_Id%TYPE 	DEFAULT NULL,
	P_Person_Id                    IN Pa_Transaction_Interface_All.Person_Id%TYPE 			DEFAULT NULL,
	P_Organization_Id              IN Pa_Transaction_Interface_All.Organization_Id%TYPE 		DEFAULT NULL,
	P_Non_Labor_Res_Org_Id         IN Pa_Transaction_Interface_All.Non_Labor_Resource_Org_Id%TYPE 	DEFAULT NULL,
	P_Override_To_Org_Id           IN Pa_Transaction_Interface_All.Override_To_Organization_Id%TYPE DEFAULT NULL,
	P_Assignment_Id                IN Pa_Transaction_Interface_All.Assignment_Id%TYPE 		DEFAULT NULL,
	P_Work_Type_Id                 IN Pa_Transaction_Interface_All.Work_Type_Id%TYPE 		DEFAULT NULL,
	P_Vendor_Id                    IN Pa_Transaction_Interface_All.Vendor_Id%TYPE 			DEFAULT NULL,
	-- PA.M/CWK changes
    P_PO_Number		               IN Pa_Transaction_Interface_All.PO_Number%TYPE 			DEFAULT NULL,
    P_PO_Header_Id  	           IN Pa_Transaction_Interface_All.PO_Header_Id%TYPE 		DEFAULT NULL,
    P_PO_Line_Num		           IN Pa_Transaction_Interface_All.PO_Line_Num%TYPE 		DEFAULT NULL,
    P_PO_Line_Id    	           IN Pa_Transaction_Interface_All.PO_Line_Id%TYPE 			DEFAULT NULL,
    P_PO_Price_Type 	           IN Pa_Transaction_Interface_All.PO_Price_Type%TYPE 		DEFAULT NULL,
    P_Person_Type   	           IN Pa_Transaction_Interface_All.Person_Type%TYPE 		DEFAULT NULL,
	-- PA.M/CWK changes
	P_Inventory_Item_Id	           IN Pa_Transaction_Interface_All.Inventory_Item_Id%TYPE 		DEFAULT NULL,
	P_WIP_Resource_Id	           IN Pa_Transaction_Interface_All.WIP_Resource_Id%TYPE 		DEFAULT NULL,
	P_Unit_Of_Measure	           IN Pa_Transaction_Interface_All.Unit_Of_Measure%TYPE 		DEFAULT NULL );

 Procedure Delete_Row (X_RowId  IN VARCHAR2);

 Procedure Lock_Row (X_RowId	IN VARCHAR2);

 Procedure Bulk_Insert (
		   P_Txn_Interface_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Txn_Interface_Id_Typ,
		   P_Transaction_Source_Tbl IN Pa_Txn_Interface_Items_Pkg.Transaction_Source_Typ,
		   P_User_Transaction_Source_Tbl IN Pa_Txn_Interface_Items_Pkg.User_Transaction_Source_Typ,
		   P_Batch_Name_Tbl IN Pa_Txn_Interface_Items_Pkg.Batch_Name_Typ,
		   P_Expenditure_End_Date_Tbl IN Pa_Txn_Interface_Items_Pkg.Expenditure_End_Date_Typ,
		   P_Person_Bus_Grp_Name_Tbl IN Pa_Txn_Interface_Items_Pkg.Person_Business_Group_Name_Typ,
		   P_Person_Bus_Grp_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Person_Business_Group_Id_Typ,
		   P_Employee_Number_Tbl IN Pa_Txn_Interface_Items_Pkg.Employee_Number_Typ,
		   P_Person_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Person_Id_Typ,
		   P_Organization_Name_Tbl IN Pa_Txn_Interface_Items_Pkg.Organization_Name_Typ,
		   P_Organization_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Organization_Id_Typ,
		   P_Expenditure_Item_Date_Tbl IN Pa_Txn_Interface_Items_Pkg.Expenditure_Item_Date_Typ,
		   P_Project_Number_Tbl IN Pa_Txn_Interface_Items_Pkg.Project_Number_Typ,
		   P_Project_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Project_Id_Typ,
		   P_Task_Number_Tbl IN Pa_Txn_Interface_Items_Pkg.Task_Number_Typ,
		   P_Task_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Task_Id_Typ,
		   P_Expenditure_Type_Tbl IN Pa_Txn_Interface_Items_Pkg.Expenditure_Type_Typ,
		   P_System_Linkage_Tbl IN Pa_Txn_Interface_Items_Pkg.System_Linkage_Typ,
		   P_Non_Labor_Resource_Tbl IN Pa_Txn_Interface_Items_Pkg.Non_Labor_Resource_Typ,
		   P_Non_Labor_Res_Org_Name_Tbl IN Pa_Txn_Interface_Items_Pkg.Non_Labor_Res_Org_Name_Typ,
		   P_Non_Labor_Res_Org_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Non_Labor_Res_Org_Id_Typ,
		   P_Quantity_Tbl IN Pa_Txn_Interface_Items_Pkg.Quantity_Typ,
		   P_Raw_Cost_Tbl IN Pa_Txn_Interface_Items_Pkg.Raw_Cost_Typ,
		   P_Raw_Cost_Rate_Tbl IN Pa_Txn_Interface_Items_Pkg.Raw_Cost_Rate_Typ,
		   P_Burden_Cost_Tbl IN Pa_Txn_Interface_Items_Pkg.Burden_Cost_Typ,
		   P_Burden_Cost_Rate_Tbl IN Pa_Txn_Interface_Items_Pkg.Burden_Cost_Rate_Typ,
		   P_Expenditure_Comment_Tbl IN Pa_Txn_Interface_Items_Pkg.Expenditure_Comment_Typ,
		   P_Gl_Date_Tbl IN Pa_Txn_Interface_Items_Pkg.Gl_Date_Typ,
		   P_Transaction_Status_Code_Tbl IN Pa_Txn_Interface_Items_Pkg.Transaction_Status_Code_Typ,
		   P_Trans_Rejection_Code_Tbl IN Pa_Txn_Interface_Items_Pkg.Transaction_Rejection_Code_Typ,
		   P_Orig_Trans_Reference_Tbl IN Pa_Txn_Interface_Items_Pkg.Orig_Transaction_Reference_Typ,
		   P_Unmatched_Neg_Txn_Flag_Tbl IN Pa_Txn_Interface_Items_Pkg.Unmatched_Neg_Txn_Flag_Typ,
		   P_Expenditure_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Expenditure_Id_Typ,
		   P_Attribute_Category_Tbl IN Pa_Txn_Interface_Items_Pkg.Attribute_Category_Typ,
		   P_Attribute1_Tbl IN Pa_Txn_Interface_Items_Pkg.Attribute1_Typ,
		   P_Attribute2_Tbl IN Pa_Txn_Interface_Items_Pkg.Attribute2_Typ,
		   P_Attribute3_Tbl IN Pa_Txn_Interface_Items_Pkg.Attribute3_Typ,
		   P_Attribute4_Tbl IN Pa_Txn_Interface_Items_Pkg.Attribute4_Typ,
		   P_Attribute5_Tbl IN Pa_Txn_Interface_Items_Pkg.Attribute5_Typ,
		   P_Attribute6_Tbl IN Pa_Txn_Interface_Items_Pkg.Attribute6_Typ,
		   P_Attribute7_Tbl IN Pa_Txn_Interface_Items_Pkg.Attribute7_Typ,
		   P_Attribute8_Tbl IN Pa_Txn_Interface_Items_Pkg.Attribute8_Typ,
		   P_Attribute9_Tbl IN Pa_Txn_Interface_Items_Pkg.Attribute9_Typ,
		   P_Attribute10_Tbl IN Pa_Txn_Interface_Items_Pkg.Attribute10_Typ,
		   P_Dr_Code_Combination_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Dr_Code_Combination_Id_Typ,
		   P_Cr_Code_Combination_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Cr_Code_Combination_Id_Typ,
		   P_Cdl_System_Reference1_Tbl IN Pa_Txn_Interface_Items_Pkg.Cdl_System_Reference1_Typ,
		   P_Cdl_System_Reference2_Tbl IN Pa_Txn_Interface_Items_Pkg.Cdl_System_Reference2_Typ,
		   P_Cdl_System_Reference3_Tbl IN Pa_Txn_Interface_Items_Pkg.Cdl_System_Reference3_Typ,
		   P_Interface_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Interface_Id_Typ,
		   P_Receipt_Currency_Amount_Tbl IN Pa_Txn_Interface_Items_Pkg.Receipt_Currency_Amount_Typ,
		   P_Receipt_Currency_Code_Tbl IN Pa_Txn_Interface_Items_Pkg.Receipt_Currency_Code_Typ,
		   P_Receipt_Exchange_Rate_Tbl IN Pa_Txn_Interface_Items_Pkg.Receipt_Exchange_Rate_Typ,
		   P_Denom_Currency_Code_Tbl IN Pa_Txn_Interface_Items_Pkg.Denom_Currency_Code_Typ,
		   P_Denom_Raw_Cost_Tbl IN Pa_Txn_Interface_Items_Pkg.Denom_Raw_Cost_Typ,
		   P_Denom_Burdened_Cost_Tbl IN Pa_Txn_Interface_Items_Pkg.Denom_Burdened_Cost_Typ,
		   P_Acct_Rate_Date_Tbl IN Pa_Txn_Interface_Items_Pkg.Acct_Rate_Date_Typ,
		   P_Acct_Rate_Type_Tbl IN Pa_Txn_Interface_Items_Pkg.Acct_Rate_Type_Typ,
		   P_Acct_Exchange_Rate_Tbl IN Pa_Txn_Interface_Items_Pkg.Acct_Exchange_Rate_Typ,
		   P_Acct_Raw_Cost_Tbl IN Pa_Txn_Interface_Items_Pkg.Acct_Raw_Cost_Typ,
		   P_Acct_Burdened_Cost_Tbl IN Pa_Txn_Interface_Items_Pkg.Acct_Burdened_Cost_Typ,
		   P_Acct_Exch_Rounding_Limit_Tbl IN Pa_Txn_Interface_Items_Pkg.Acct_Exch_Rounding_Limit_Typ,
		   P_Project_Currency_Code_Tbl IN Pa_Txn_Interface_Items_Pkg.Project_Currency_Code_Typ,
		   P_Project_Rate_Date_Tbl IN Pa_Txn_Interface_Items_Pkg.Project_Rate_Date_Typ,
		   P_Project_Rate_Type_Tbl IN Pa_Txn_Interface_Items_Pkg.Project_Rate_Type_Typ,
		   P_Project_Exchange_Rate_Tbl IN Pa_Txn_Interface_Items_Pkg.Project_Exchange_Rate_Typ,
		   P_Orig_Exp_Txn_Reference1_Tbl IN Pa_Txn_Interface_Items_Pkg.Orig_Exp_Txn_Reference1_Typ,
		   P_Orig_Exp_Txn_Reference2_Tbl IN Pa_Txn_Interface_Items_Pkg.Orig_Exp_Txn_Reference2_Typ,
		   P_Orig_Exp_Txn_Reference3_Tbl IN Pa_Txn_Interface_Items_Pkg.Orig_Exp_Txn_Reference3_Typ,
		   P_Orig_User_Exp_Txn_Ref_Tbl IN Pa_Txn_Interface_Items_Pkg.Orig_User_Exp_Txn_Ref_Typ,
		   P_Vendor_Number_Tbl IN Pa_Txn_Interface_Items_Pkg.Vendor_Number_Typ,
		   P_Vendor_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Vendor_Id_Typ,
		   P_Override_To_Org_Name_Tbl IN Pa_Txn_Interface_Items_Pkg.Override_To_Org_Name_Typ,
		   P_Override_To_Org_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Override_To_Org_Id_Typ,
		   P_Reversed_Orig_Txn_Ref_Tbl IN Pa_Txn_Interface_Items_Pkg.Reversed_Orig_Txn_Ref_Typ,
		   P_Billable_Flag_Tbl IN Pa_Txn_Interface_Items_Pkg.Billable_Flag_Typ,
		   P_ProjFunc_Currency_Code_Tbl IN Pa_Txn_Interface_Items_Pkg.ProjFunc_Currency_Code_Typ,
		   P_ProjFunc_Cost_Rate_Date_Tbl IN Pa_Txn_Interface_Items_Pkg.ProjFunc_Cost_Rate_Date_Typ,
		   P_ProjFunc_Cost_Rate_Type_Tbl IN Pa_Txn_Interface_Items_Pkg.ProjFunc_Cost_Rate_Type_Typ,
		   P_ProjFunc_Cost_Exch_Rate_Tbl IN Pa_Txn_Interface_Items_Pkg.ProjFunc_Cost_Exch_Rate_Typ,
		   P_Project_Raw_Cost_Tbl IN Pa_Txn_Interface_Items_Pkg.Project_Raw_Cost_Typ,
		   P_Project_Burdened_Cost_Tbl IN Pa_Txn_Interface_Items_Pkg.Project_Burdened_Cost_Typ,
		   P_Assignment_Name_Tbl IN Pa_Txn_Interface_Items_Pkg.Assignment_Name_Typ,
		   P_Assignment_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Assignment_Id_Typ,
		   P_Work_Type_Name_Tbl IN Pa_Txn_Interface_Items_Pkg.Work_Type_Name_Typ,
		   P_Work_Type_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Work_Type_Id_Typ,
		   P_Cdl_System_Reference4_Tbl IN Pa_Txn_Interface_Items_Pkg.Cdl_System_Reference4_Typ,
		   P_Accrual_Flag_Tbl IN Pa_Txn_Interface_Items_Pkg.Accrual_Flag_Typ,
   		   P_Last_Update_Date_Tbl IN Pa_Txn_Interface_Items_Pkg.Last_Update_Date_Typ,
   		   P_Last_Updated_By_Tbl IN Pa_Txn_Interface_Items_Pkg.Last_Updated_By_Typ,
   		   P_Creation_Date_Tbl IN Pa_Txn_Interface_Items_Pkg.Creation_Date_Typ,
   		   P_Created_By_Tbl IN Pa_Txn_Interface_Items_Pkg.Created_By_Typ,
		   -- Begin PA.M/CWK changes
		   P_PO_Number_Tbl IN Pa_Txn_Interface_Items_Pkg.PO_Number_Typ,
		   P_PO_Header_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.PO_Header_Id_Typ,
		   P_PO_Line_Num_Tbl IN Pa_Txn_Interface_Items_Pkg.PO_Line_Num_Typ,
		   P_PO_Line_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.PO_Line_Id_Typ,
		   P_PO_Price_Type_Tbl IN Pa_Txn_Interface_Items_Pkg.PO_Price_Type_Typ,
		   P_Person_Type_Tbl IN Pa_Txn_Interface_Items_Pkg.Person_Type_Typ,
		   -- End PA.M/CWK changes
		   P_Inventory_Item_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Inventory_Item_Id_Typ,
		   P_WIP_Resource_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.WIP_Resource_Id_Typ,
		   P_Unit_Of_Measure_Tbl IN Pa_Txn_Interface_Items_Pkg.Unit_Of_Measure_Typ,
           -- 12i MOAC changes
           P_Org_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.OU_Id_Typ );

 Procedure Bulk_Update (
           P_Txn_Interface_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Txn_Interface_Id_Typ,
           P_Transaction_Source_Tbl IN Pa_Txn_Interface_Items_Pkg.Transaction_Source_Typ,
           P_User_Transaction_Source_Tbl IN Pa_Txn_Interface_Items_Pkg.User_Transaction_Source_Typ,
           P_Batch_Name_Tbl IN Pa_Txn_Interface_Items_Pkg.Batch_Name_Typ,
           P_Expenditure_End_Date_Tbl IN Pa_Txn_Interface_Items_Pkg.Expenditure_End_Date_Typ,
           P_Person_Bus_Grp_Name_Tbl IN Pa_Txn_Interface_Items_Pkg.Person_Business_Group_Name_Typ,
           P_Person_Bus_Grp_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Person_Business_Group_Id_Typ,
           P_Employee_Number_Tbl IN Pa_Txn_Interface_Items_Pkg.Employee_Number_Typ,
           P_Person_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Person_Id_Typ,
           P_Organization_Name_Tbl IN Pa_Txn_Interface_Items_Pkg.Organization_Name_Typ,
           P_Organization_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Organization_Id_Typ,
           P_Expenditure_Item_Date_Tbl IN Pa_Txn_Interface_Items_Pkg.Expenditure_Item_Date_Typ,
           P_Project_Number_Tbl IN Pa_Txn_Interface_Items_Pkg.Project_Number_Typ,
           P_Project_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Project_Id_Typ,
           P_Task_Number_Tbl IN Pa_Txn_Interface_Items_Pkg.Task_Number_Typ,
           P_Task_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Task_Id_Typ,
           P_Expenditure_Type_Tbl IN Pa_Txn_Interface_Items_Pkg.Expenditure_Type_Typ,
           P_System_Linkage_Tbl IN Pa_Txn_Interface_Items_Pkg.System_Linkage_Typ,
           P_Non_Labor_Resource_Tbl IN Pa_Txn_Interface_Items_Pkg.Non_Labor_Resource_Typ,
           P_Non_Labor_Res_Org_Name_Tbl IN Pa_Txn_Interface_Items_Pkg.Non_Labor_Res_Org_Name_Typ,
           P_Non_Labor_Res_Org_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Non_Labor_Res_Org_Id_Typ,
           P_Quantity_Tbl IN Pa_Txn_Interface_Items_Pkg.Quantity_Typ,
           P_Raw_Cost_Tbl IN Pa_Txn_Interface_Items_Pkg.Raw_Cost_Typ,
           P_Raw_Cost_Rate_Tbl IN Pa_Txn_Interface_Items_Pkg.Raw_Cost_Rate_Typ,
           P_Burden_Cost_Tbl IN Pa_Txn_Interface_Items_Pkg.Burden_Cost_Typ,
           P_Burden_Cost_Rate_Tbl IN Pa_Txn_Interface_Items_Pkg.Burden_Cost_Rate_Typ,
           P_Expenditure_Comment_Tbl IN Pa_Txn_Interface_Items_Pkg.Expenditure_Comment_Typ,
           P_Gl_Date_Tbl IN Pa_Txn_Interface_Items_Pkg.Gl_Date_Typ,
           P_Transaction_Status_Code_Tbl IN Pa_Txn_Interface_Items_Pkg.Transaction_Status_Code_Typ,
           P_Trans_Rejection_Code_Tbl IN Pa_Txn_Interface_Items_Pkg.Transaction_Rejection_Code_Typ,
           P_Orig_Trans_Reference_Tbl IN Pa_Txn_Interface_Items_Pkg.Orig_Transaction_Reference_Typ,
           P_Unmatched_Neg_Txn_Flag_Tbl IN Pa_Txn_Interface_Items_Pkg.Unmatched_Neg_Txn_Flag_Typ,
           P_Expenditure_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Expenditure_Id_Typ,
           P_Attribute_Category_Tbl IN Pa_Txn_Interface_Items_Pkg.Attribute_Category_Typ,
           P_Attribute1_Tbl IN Pa_Txn_Interface_Items_Pkg.Attribute1_Typ,
           P_Attribute2_Tbl IN Pa_Txn_Interface_Items_Pkg.Attribute2_Typ,
           P_Attribute3_Tbl IN Pa_Txn_Interface_Items_Pkg.Attribute3_Typ,
           P_Attribute4_Tbl IN Pa_Txn_Interface_Items_Pkg.Attribute4_Typ,
           P_Attribute5_Tbl IN Pa_Txn_Interface_Items_Pkg.Attribute5_Typ,
           P_Attribute6_Tbl IN Pa_Txn_Interface_Items_Pkg.Attribute6_Typ,
           P_Attribute7_Tbl IN Pa_Txn_Interface_Items_Pkg.Attribute7_Typ,
           P_Attribute8_Tbl IN Pa_Txn_Interface_Items_Pkg.Attribute8_Typ,
           P_Attribute9_Tbl IN Pa_Txn_Interface_Items_Pkg.Attribute9_Typ,
           P_Attribute10_Tbl IN Pa_Txn_Interface_Items_Pkg.Attribute10_Typ,
           P_Dr_Code_Combination_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Dr_Code_Combination_Id_Typ,
           P_Cr_Code_Combination_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Cr_Code_Combination_Id_Typ,
           P_Cdl_System_Reference1_Tbl IN Pa_Txn_Interface_Items_Pkg.Cdl_System_Reference1_Typ,
           P_Cdl_System_Reference2_Tbl IN Pa_Txn_Interface_Items_Pkg.Cdl_System_Reference2_Typ,
           P_Cdl_System_Reference3_Tbl IN Pa_Txn_Interface_Items_Pkg.Cdl_System_Reference3_Typ,
           P_Interface_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Interface_Id_Typ,
           P_Receipt_Currency_Amount_Tbl IN Pa_Txn_Interface_Items_Pkg.Receipt_Currency_Amount_Typ,
           P_Receipt_Currency_Code_Tbl IN Pa_Txn_Interface_Items_Pkg.Receipt_Currency_Code_Typ,
           P_Receipt_Exchange_Rate_Tbl IN Pa_Txn_Interface_Items_Pkg.Receipt_Exchange_Rate_Typ,
           P_Denom_Currency_Code_Tbl IN Pa_Txn_Interface_Items_Pkg.Denom_Currency_Code_Typ,
           P_Denom_Raw_Cost_Tbl IN Pa_Txn_Interface_Items_Pkg.Denom_Raw_Cost_Typ,
           P_Denom_Burdened_Cost_Tbl IN Pa_Txn_Interface_Items_Pkg.Denom_Burdened_Cost_Typ,
           P_Acct_Rate_Date_Tbl IN Pa_Txn_Interface_Items_Pkg.Acct_Rate_Date_Typ,
           P_Acct_Rate_Type_Tbl IN Pa_Txn_Interface_Items_Pkg.Acct_Rate_Type_Typ,
           P_Acct_Exchange_Rate_Tbl IN Pa_Txn_Interface_Items_Pkg.Acct_Exchange_Rate_Typ,
           P_Acct_Raw_Cost_Tbl IN Pa_Txn_Interface_Items_Pkg.Acct_Raw_Cost_Typ,
           P_Acct_Burdened_Cost_Tbl IN Pa_Txn_Interface_Items_Pkg.Acct_Burdened_Cost_Typ,
           P_Acct_Exch_Rounding_Limit_Tbl IN Pa_Txn_Interface_Items_Pkg.Acct_Exch_Rounding_Limit_Typ,
           P_Project_Currency_Code_Tbl IN Pa_Txn_Interface_Items_Pkg.Project_Currency_Code_Typ,
           P_Project_Rate_Date_Tbl IN Pa_Txn_Interface_Items_Pkg.Project_Rate_Date_Typ,
           P_Project_Rate_Type_Tbl IN Pa_Txn_Interface_Items_Pkg.Project_Rate_Type_Typ,
           P_Project_Exchange_Rate_Tbl IN Pa_Txn_Interface_Items_Pkg.Project_Exchange_Rate_Typ,
           P_Orig_Exp_Txn_Reference1_Tbl IN Pa_Txn_Interface_Items_Pkg.Orig_Exp_Txn_Reference1_Typ,
           P_Orig_Exp_Txn_Reference2_Tbl IN Pa_Txn_Interface_Items_Pkg.Orig_Exp_Txn_Reference2_Typ,
           P_Orig_Exp_Txn_Reference3_Tbl IN Pa_Txn_Interface_Items_Pkg.Orig_Exp_Txn_Reference3_Typ,
           P_Orig_User_Exp_Txn_Ref_Tbl IN Pa_Txn_Interface_Items_Pkg.Orig_User_Exp_Txn_Ref_Typ,
           P_Vendor_Number_Tbl IN Pa_Txn_Interface_Items_Pkg.Vendor_Number_Typ,
           P_Vendor_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Vendor_Id_Typ,
           P_Override_To_Org_Name_Tbl IN Pa_Txn_Interface_Items_Pkg.Override_To_Org_Name_Typ,
           P_Override_To_Org_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Override_To_Org_Id_Typ,
           P_Reversed_Orig_Txn_Ref_Tbl IN Pa_Txn_Interface_Items_Pkg.Reversed_Orig_Txn_Ref_Typ,
           P_Billable_Flag_Tbl IN Pa_Txn_Interface_Items_Pkg.Billable_Flag_Typ,
           P_ProjFunc_Currency_Code_Tbl IN Pa_Txn_Interface_Items_Pkg.ProjFunc_Currency_Code_Typ,
           P_ProjFunc_Cost_Rate_Date_Tbl IN Pa_Txn_Interface_Items_Pkg.ProjFunc_Cost_Rate_Date_Typ,
           P_ProjFunc_Cost_Rate_Type_Tbl IN Pa_Txn_Interface_Items_Pkg.ProjFunc_Cost_Rate_Type_Typ,
           P_ProjFunc_Cost_Exch_Rate_Tbl IN Pa_Txn_Interface_Items_Pkg.ProjFunc_Cost_Exch_Rate_Typ,
           P_Project_Raw_Cost_Tbl IN Pa_Txn_Interface_Items_Pkg.Project_Raw_Cost_Typ,
           P_Project_Burdened_Cost_Tbl IN Pa_Txn_Interface_Items_Pkg.Project_Burdened_Cost_Typ,
           P_Assignment_Name_Tbl IN Pa_Txn_Interface_Items_Pkg.Assignment_Name_Typ,
           P_Assignment_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Assignment_Id_Typ,
           P_Work_Type_Name_Tbl IN Pa_Txn_Interface_Items_Pkg.Work_Type_Name_Typ,
           P_Work_Type_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Work_Type_Id_Typ,
           P_Cdl_System_Reference4_Tbl IN Pa_Txn_Interface_Items_Pkg.Cdl_System_Reference4_Typ,
           P_Accrual_flag_Tbl IN Pa_Txn_Interface_Items_Pkg.Accrual_flag_Typ,
           P_Last_Update_Date_Tbl IN Pa_Txn_Interface_Items_Pkg.Last_Update_Date_Typ,
           P_Last_Updated_By_Tbl IN Pa_Txn_Interface_Items_Pkg.Last_Updated_By_Typ,
           P_Creation_Date_Tbl IN Pa_Txn_Interface_Items_Pkg.Creation_Date_Typ,
           P_Created_By_Tbl IN Pa_Txn_Interface_Items_Pkg.Created_By_Typ,
		   -- Begin PA.M/CWK changes
		   P_PO_Number_Tbl IN Pa_Txn_Interface_Items_Pkg.PO_Number_Typ,
		   P_PO_Header_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.PO_Header_Id_Typ,
		   P_PO_Line_Num_Tbl IN Pa_Txn_Interface_Items_Pkg.PO_Line_Num_Typ,
		   P_PO_Line_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.PO_Line_Id_Typ,
		   P_PO_Price_Type_Tbl IN Pa_Txn_Interface_Items_Pkg.PO_Price_Type_Typ,
		   P_Person_Type_Tbl IN Pa_Txn_Interface_Items_Pkg.Person_Type_Typ,
		   -- End PA.M/CWK changes
		   P_Inventory_Item_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.Inventory_Item_Id_Typ,
		   P_WIP_Resource_Id_Tbl IN Pa_Txn_Interface_Items_Pkg.WIP_Resource_Id_Typ,
		   P_Unit_Of_Measure_Tbl IN Pa_Txn_Interface_Items_Pkg.Unit_Of_Measure_Typ );

END Pa_Txn_Interface_Items_Pkg;

 

/
