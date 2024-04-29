--------------------------------------------------------
--  DDL for Package IGC_CC_OPEN_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_OPEN_INTERFACE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGCCOPIS.pls 120.4.12000000.3 2007/11/07 11:54:42 bmaddine ship $ */

-- Main program which selects all the records from Header Interface table
-- and calls other programs for processing
  PROCEDURE HEADER_INTERFACE_MAIN
     ( ERRBUF    		OUT NOCOPY VARCHAR2,
       RETCODE   		OUT NOCOPY VARCHAR2,
       P_Process_Phase 		IN  VARCHAR2,
       P_Batch_Id 		IN  NUMBER);

-- Validate the interface header record and return the result
  PROCEDURE HEADER_INTERFACE_VALIDATE
     ( P_Interface_Header_Id IN NUMBER,
       P_Org_Id IN NUMBER,
       P_Cc_Type IN VARCHAR2,
       P_Cc_Num IN VARCHAR2,
       P_Cc_Version_Num IN NUMBER,
       p_Interface_Parent_Header_Id IN NUMBER,
       P_Cc_State IN VARCHAR2,
       P_Cc_Ctrl_Status IN VARCHAR2,
       P_Cc_Encmbrnc_Status IN VARCHAR2,
       P_Cc_Apprvl_Status IN VARCHAR2,
       P_Vendor_Id IN NUMBER,
       P_Vendor_Site_Id IN NUMBER,
       P_Vendor_Contact_Id IN NUMBER,
       P_Term_Id IN NUMBER,
       P_Location_Id IN NUMBER,
       P_Set_of_Books_Id IN NUMBER,
       P_Cc_Acct_Date IN DATE,
       P_Cc_Start_Date IN DATE,
       P_Cc_End_Date IN DATE,
       P_Cc_Owner_User_Id IN NUMBER,
       P_Cc_Preparer_User_Id IN NUMBER,
       P_Currency_Code IN VARCHAR2,
       P_Conversion_Type IN VARCHAR2,
       P_Conversion_Rate IN NUMBER,
       P_Conversion_Date IN DATE,
       P_Created_By IN NUMBER,
       P_CC_Guarantee_Flag IN VARCHAR2,
       P_CC_Current_User_Id IN NUMBER,
       P_X_Error_Status IN OUT NOCOPY VARCHAR2,
       P_Current_Org_Id IN  NUMBER,
       P_Current_Set_of_Books_Id IN  NUMBER,
       P_Func_Currency_Code IN VARCHAR2,
       P_Cbc_Enable_Flag IN VARCHAR2);

-- Program which selects all the records from Acct Lines Interface table
-- for a particular Header record and calls other programs for processing
  PROCEDURE ACCT_LINE_INTERFACE_MAIN
     ( P_Interface_Header_Id IN NUMBER,
       P_Header_Id IN NUMBER,
       P_Int_Head_Parent_Header_Id IN NUMBER,
       P_Parent_Header_Id IN NUMBER,
       P_Org_Id IN NUMBER,
       P_Set_of_Books_Id IN NUMBER,
       P_Cc_Type IN VARCHAR2,
       P_Cc_Encmbrnc_Status IN VARCHAR2,
       P_Cc_Start_Date IN DATE,
       P_Cc_End_Date IN DATE,
       P_Cc_Acct_Date IN DATE,
       P_User_Id IN NUMBER,
       P_Login_Id IN NUMBER,
       P_CC_State IN VARCHAR2,
       P_CC_Apprvl_Status IN VARCHAR2,
       P_X_Error_Status IN OUT NOCOPY VARCHAR2);

-- Validate the interface acct line record and return the result
  PROCEDURE ACCT_LINE_INTERFACE_VALIDATE
     ( P_Interface_Header_Id IN NUMBER,
       P_Int_Head_Parent_Header_Id IN NUMBER,
       P_Interface_Acct_Line_Id IN NUMBER,
       P_Org_Id IN NUMBER,
       P_Set_of_Books_Id IN NUMBER,
       P_Cc_Type IN VARCHAR2,
       P_Cc_Encmbrnc_Status IN VARCHAR2,
       P_Cc_Start_Date IN DATE,
       P_Cc_End_Date IN DATE,
       P_Cc_Acct_Date IN DATE,
       P_Interface_Parent_Header_Id IN NUMBER,
       P_Interface_Parent_AcctLine_Id IN NUMBER,
       P_Charge_Code_Combination_Id IN NUMBER,
       P_Budget_Code_Combination_Id IN NUMBER,
       P_Cc_Acct_Entered_Amt IN NUMBER,
       P_Cc_Acct_Func_Amt IN NUMBER,
       P_Cc_Acct_Encmbrnc_Amt IN NUMBER,
       P_Cc_Acct_Encmbrnc_Date IN DATE,
       P_Cc_Acct_Encmbrnc_Status IN VARCHAR2,
       P_Project_Id IN NUMBER,
       P_Task_Id IN NUMBER,
       P_Expenditure_Type IN VARCHAR2,
       P_Expenditure_Org_Id IN NUMBER,
       P_Expenditure_Item_Date IN DATE,
       P_Created_By IN NUMBER,
       P_CC_Ent_Withheld_Amt IN NUMBER,
       P_CC_Func_Withheld_Amt IN NUMBER,
       P_CC_State IN VARCHAR2,
       P_CC_Apprvl_Status  IN VARCHAR2,
       P_X_Error_Status IN OUT NOCOPY VARCHAR2);

-- Program which selects all the records from Det Pf Interface table for
-- a particular acct line and calls other programs for processing
  PROCEDURE DET_PF_INTERFACE_MAIN
     ( P_Interface_Header_Id IN NUMBER,
       P_Interface_Acct_Line_Id IN NUMBER,
       P_Acct_Line_Id IN NUMBER,
       P_Int_Acct_Parent_AcctLine_Id IN NUMBER,
       P_Parent_Acct_Line_Id IN NUMBER,
       P_Org_Id IN NUMBER,
       P_Set_of_Books_Id IN NUMBER,
       P_Cc_Type IN VARCHAR2,
       P_Cc_Encmbrnc_Status IN VARCHAR2,
       P_Cc_Start_Date IN DATE,
       P_Cc_End_Date IN DATE,
       P_User_Id IN NUMBER,
       P_Login_Id IN NUMBER,
       P_header_Id IN NUMBER,
       P_Project_Id IN NUMBER,
       p_task_id               IN NUMBER,
       p_expenditure_type      IN VARCHAR2,
       p_expenditure_item_date IN DATE,
       p_expenditure_org_id    IN NUMBER,
       p_cc_budget_ccid IN NUMBER,
       P_X_Error_Status IN OUT NOCOPY VARCHAR2);

-- Validate the interface det pf record and return the result
  PROCEDURE DET_PF_INTERFACE_VALIDATE
     ( P_Interface_Header_Id IN NUMBER,
       P_Interface_Acct_Line_Id IN NUMBER,
       P_Int_Acct_Parent_AcctLine_Id IN NUMBER,
       P_Interface_Det_Pf_Id IN NUMBER,
       P_Org_Id IN NUMBER,
       P_Set_of_Books_Id IN NUMBER,
       P_Cc_Type IN VARCHAR2,
       P_Cc_Encmbrnc_Status IN VARCHAR2,
       P_Cc_Start_Date IN DATE,
       P_Cc_End_Date IN DATE,
       P_Interface_Parent_AcctLine_Id IN NUMBER,
       P_Interface_Parent_Det_Pf_Id IN NUMBER,
       P_Cc_Det_Pf_Date IN DATE,
       P_Cc_Det_Pf_Entered_Amt IN NUMBER,
       P_Cc_Det_Pf_Func_Amt IN NUMBER,
       P_Cc_Det_Pf_Encmbrnc_Amt IN NUMBER,
       P_Cc_Det_Pf_Encmbrnc_Date IN DATE,
       P_Cc_Det_Pf_Encmbrnc_Status IN VARCHAR2,
       P_Created_By IN NUMBER,
       P_X_Error_Status IN OUT NOCOPY VARCHAR2);

END IGC_CC_OPEN_INTERFACE_PKG;

 

/
