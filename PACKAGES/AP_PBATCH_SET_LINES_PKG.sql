--------------------------------------------------------
--  DDL for Package AP_PBATCH_SET_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_PBATCH_SET_LINES_PKG" AUTHID CURRENT_USER as
/* $Header: apbsetls.pls 120.3 2003/09/25 22:35:26 pjena noship $ */
/* BUG 2124337: Parameters X_attribute_category to X_attribute15 added */

PROCEDURE Insert_Row(
          X_Rowid                 IN OUT NOCOPY   VARCHAR2,
          X_Batch_Name                     VARCHAR2,
          X_Batch_Set_Id                   NUMBER,
          X_Batch_Set_Line_Id              NUMBER,
          X_Include_In_Set                 VARCHAR2 DEFAULT NULL,
          X_Printer                        VARCHAR2 DEFAULT NULL,
          X_Check_Stock_Id                 NUMBER DEFAULT NULL,
          X_Ce_Bank_Acct_Use_Id            NUMBER DEFAULT NULL,
          X_Vendor_Pay_Group               VARCHAR2 DEFAULT NULL,
          X_Hi_Payment_Priority            NUMBER DEFAULT NULL,
          X_Low_Payment_Priority           NUMBER DEFAULT NULL,
          X_Max_Payment_Amount             NUMBER DEFAULT NULL,
          X_Min_Check_Amount               NUMBER DEFAULT NULL,
          X_Max_Outlay                     NUMBER DEFAULT NULL,
          X_Pay_Only_When_Due_Flag         VARCHAR2 DEFAULT NULL,
          X_Payment_Currency_Code          VARCHAR2,
          X_Exchange_Rate_Type             VARCHAR2 DEFAULT NULL,
          X_Document_Order_Lookup_Code     VARCHAR2 DEFAULT NULL,
          X_Audit_Required_Flag            VARCHAR2 DEFAULT NULL,
          X_Interval                       NUMBER DEFAULT NULL,
          X_Volume_Serial_Number           VARCHAR2 DEFAULT NULL,
          X_Zero_Amounts_Allowed           VARCHAR2 DEFAULT NULL,
          X_Zero_Invoices_Allowed          VARCHAR2 DEFAULT NULL,
          X_Org_Id                         NUMBER DEFAULT NULL,
          X_Future_Pmts_Allowed            VARCHAR2 DEFAULT NULL,
          X_Transfer_Priority              VARCHAR2 DEFAULT NULL,
          X_Last_Update_Date               DATE,
          X_Last_Updated_By                NUMBER,
          X_Last_Update_Login              NUMBER DEFAULT NULL,
          X_Creation_Date                  DATE DEFAULT NULL,
          X_Created_By                     NUMBER DEFAULT NULL,
          X_Inactive_Date                  DATE DEFAULT NULL,
	  X_calling_sequence	  IN	   VARCHAR2,
	  X_attribute_category		   VARCHAR2, /* BUG 2124337 */
	  X_attribute1			   VARCHAR2,
	  X_attribute2			   VARCHAR2,
	  X_attribute3			   VARCHAR2,
	  X_attribute4			   VARCHAR2,
	  X_attribute5			   VARCHAR2,
	  X_attribute6			   VARCHAR2,
	  X_attribute7			   VARCHAR2,
	  X_attribute8			   VARCHAR2,
	  X_attribute9			   VARCHAR2,
	  X_attribute10			   VARCHAR2,
	  X_attribute11			   VARCHAR2,
	  X_attribute12			   VARCHAR2,
	  X_attribute13			   VARCHAR2,
	  X_attribute14			   VARCHAR2,
	  X_attribute15			   VARCHAR2,  /* BUG 2124337 */
          X_Vendor_Id                      NUMBER,
          X_days_between_check_cycles      NUMBER
  ) ;

/* BUG 2124337: Parameters X_attribute_category to X_attribute15 added */
    PROCEDURE Lock_Row(
              X_Rowid                          VARCHAR2,
              X_Batch_Name                     VARCHAR2,
              X_Batch_Set_Id                   NUMBER,
              X_Batch_Set_Line_Id              NUMBER,
              X_Include_In_Set                 VARCHAR2 DEFAULT NULL,
              X_Printer                        VARCHAR2 DEFAULT NULL,
              X_Check_Stock_Id                 NUMBER DEFAULT NULL,
              X_Ce_Bank_Acct_Use_Id            NUMBER DEFAULT NULL,
              X_Vendor_Pay_Group               VARCHAR2 DEFAULT NULL,
              X_Hi_Payment_Priority            NUMBER DEFAULT NULL,
              X_Low_Payment_Priority           NUMBER DEFAULT NULL,
              X_Max_Payment_Amount             NUMBER DEFAULT NULL,
              X_Min_Check_Amount               NUMBER DEFAULT NULL,
              X_Max_Outlay                     NUMBER DEFAULT NULL,
              X_Pay_Only_When_Due_Flag         VARCHAR2 DEFAULT NULL,
              X_Currency_Code                  VARCHAR2,
              X_Exchange_Rate_Type             VARCHAR2 DEFAULT NULL,
              X_Document_Order_Lookup_Code     VARCHAR2 DEFAULT NULL,
              X_Audit_Required_Flag            VARCHAR2 DEFAULT NULL,
              X_Interval                       NUMBER DEFAULT NULL,
              X_Volume_Serial_Number           VARCHAR2 DEFAULT NULL,
              X_Zero_Amounts_Allowed           VARCHAR2 DEFAULT NULL,
              X_Zero_Invoices_Allowed          VARCHAR2 DEFAULT NULL,
              X_Org_Id                         NUMBER DEFAULT NULL,
              X_Future_Pmts_Allowed            VARCHAR2 DEFAULT NULL,
              X_transfer_priority              VARCHAR2 DEFAULT NULL,
              X_Inactive_Date                  DATE DEFAULT NULL,
	      X_calling_sequence	IN     VARCHAR2,
	      X_attribute_category		   VARCHAR2, /* BUG 2124337 */
	      X_attribute1			   VARCHAR2,
	      X_attribute2			   VARCHAR2,
	      X_attribute3			   VARCHAR2,
	      X_attribute4			   VARCHAR2,
	      X_attribute5			   VARCHAR2,
	      X_attribute6			   VARCHAR2,
	      X_attribute7			   VARCHAR2,
	      X_attribute8			   VARCHAR2,
	      X_attribute9			   VARCHAR2,
	      X_attribute10			   VARCHAR2,
	      X_attribute11			   VARCHAR2,
	      X_attribute12			   VARCHAR2,
	      X_attribute13			   VARCHAR2,
	      X_attribute14			   VARCHAR2,
	      X_attribute15			   VARCHAR2,  /* BUG 2124337 */
              X_Vendor_Id                          NUMBER,
              X_days_between_check_cycles          NUMBER
  ) ;

/* BUG 2124337: Parameters X_attribute_category to X_attribute15 added */
  PROCEDURE Update_Row(
            X_Rowid                          VARCHAR2,
            X_Batch_Name                     VARCHAR2,
            X_Batch_Set_Id                   NUMBER,
            X_Batch_Set_Line_Id              NUMBER,
            X_Include_In_Set                 VARCHAR2 DEFAULT NULL,
            X_Printer                        VARCHAR2 DEFAULT NULL,
            X_Check_Stock_Id                 NUMBER DEFAULT NULL,
            X_Ce_Bank_Acct_Use_Id            NUMBER,
            X_Vendor_Pay_Group               VARCHAR2 DEFAULT NULL,
            X_Hi_Payment_Priority            NUMBER DEFAULT NULL,
            X_Low_Payment_Priority           NUMBER DEFAULT NULL,
            X_Max_Payment_Amount             NUMBER DEFAULT NULL,
            X_Min_Check_Amount               NUMBER DEFAULT NULL,
            X_Max_Outlay                     NUMBER DEFAULT NULL,
            X_Pay_Only_When_Due_Flag         VARCHAR2 DEFAULT NULL,
            X_Payment_Currency_Code          VARCHAR2,
            X_Exchange_Rate_Type             VARCHAR2 DEFAULT NULL,
            X_Document_Order_Lookup_Code     VARCHAR2 DEFAULT NULL,
            X_Audit_Required_Flag            VARCHAR2 DEFAULT NULL,
            X_Interval                       NUMBER DEFAULT NULL,
            X_Volume_Serial_Number           VARCHAR2 DEFAULT NULL,
            X_Zero_Amounts_Allowed           VARCHAR2 DEFAULT NULL,
            X_Zero_Invoices_Allowed          VARCHAR2 DEFAULT NULL,
            X_Org_Id                         NUMBER DEFAULT NULL,
            X_Future_Pmts_Allowed            VARCHAR2 DEFAULT NULL,
            X_transfer_priority              VARCHAR2 DEFAULT NULL,
            X_Last_Update_Date               DATE,
            X_Last_Updated_By                NUMBER,
            X_Last_Update_Login              NUMBER DEFAULT NULL,
            X_Creation_Date                  DATE DEFAULT NULL,
            X_Created_By                     NUMBER DEFAULT NULL,
            X_Inactive_Date                  DATE DEFAULT NULL,
            X_calling_sequence	IN	     VARCHAR2,
            X_attribute_category             VARCHAR2, /* BUG 2124337 */
	    X_attribute1	             VARCHAR2,
	    X_attribute2	             VARCHAR2,
	    X_attribute3	     	     VARCHAR2,
	    X_attribute4		     VARCHAR2,
	    X_attribute5		     VARCHAR2,
	    X_attribute6		     VARCHAR2,
	    X_attribute7		     VARCHAR2,
	    X_attribute8		     VARCHAR2,
	    X_attribute9		     VARCHAR2,
	    X_attribute10		     VARCHAR2,
	    X_attribute11		     VARCHAR2,
	    X_attribute12		     VARCHAR2,
	    X_attribute13		     VARCHAR2,
	    X_attribute14		     VARCHAR2,
	    X_attribute15		     VARCHAR2,  /* BUG 2124337 */
            X_Vendor_Id                      NUMBER,
            X_days_between_check_cycles      NUMBER
  ) ;

/*
  PROCEDURE Delete_Row(X_Rowid 				VARCHAR2,
		       X_calling_sequence	IN	VARCHAR2) ;
*/


  Procedure Check_Unique_Run(X_Batch_set_id		VARCHAR2,
                             X_Batch_Run_Name 		VARCHAR2,
                             X_Calling_Sequence   IN	VARCHAR2) ;

  Procedure Check_Unique_Batch(X_Batch_Run_Name 	VARCHAR2,
                               X_Batch_Name		VARCHAR2,
                               X_Calling_Sequence   IN  VARCHAR2) ;

END AP_PBATCH_SET_LINES_PKG;

 

/
