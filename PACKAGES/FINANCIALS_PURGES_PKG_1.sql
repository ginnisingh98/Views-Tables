--------------------------------------------------------
--  DDL for Package FINANCIALS_PURGES_PKG_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FINANCIALS_PURGES_PKG_1" AUTHID CURRENT_USER as
/* $Header: apifip1s.pls 120.4 2004/10/28 00:02:40 pjena noship $ */


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Purge_Name                     VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Category                       VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Activity_Date                  DATE DEFAULT NULL,
                       X_Ap_Checks                      NUMBER DEFAULT NULL,
                       X_Ap_Invoice_Payments            NUMBER DEFAULT NULL,
                       X_Ap_Payment_Schedules           NUMBER DEFAULT NULL,
                       X_Ap_Recurring_Payments          NUMBER DEFAULT NULL,
                       X_Ap_Trial_Balance               NUMBER DEFAULT NULL,
                       X_Ap_Holds                       NUMBER DEFAULT NULL,
                       X_Ap_Invoice_Distributions       NUMBER DEFAULT NULL,
                       X_Ap_Batches                     NUMBER DEFAULT NULL,
                       X_Ap_Invoices                    NUMBER DEFAULT NULL,
                       X_Po_Requisition_Headers         NUMBER DEFAULT NULL,
                       X_Po_Requisition_Lines           NUMBER DEFAULT NULL,
                       X_Po_Req_Distributions           NUMBER DEFAULT NULL,
                       X_Po_Approvals                   NUMBER DEFAULT NULL,
                       X_Po_Headers                     NUMBER DEFAULT NULL,
                       X_Po_Lines                       NUMBER DEFAULT NULL,
                       X_Po_Line_Locations              NUMBER DEFAULT NULL,
                       X_Po_Distributions               NUMBER DEFAULT NULL,
                       X_Po_Releases                    NUMBER DEFAULT NULL,
                       X_Po_Item_History                NUMBER DEFAULT NULL,
                       X_Po_Acceptances                 NUMBER DEFAULT NULL,
                       X_Po_Notes                       NUMBER DEFAULT NULL,
                       X_Po_Note_References             NUMBER DEFAULT NULL,
                       X_Po_Receipts                    NUMBER DEFAULT NULL,
                       X_Po_Deliveries                  NUMBER DEFAULT NULL,
                       X_Po_Quality_Inspections         NUMBER DEFAULT NULL,
                       X_Po_Vendors                     NUMBER DEFAULT NULL,
                       X_Po_Vendor_Sites                NUMBER DEFAULT NULL,
                       X_Po_Vendor_Contacts             NUMBER DEFAULT NULL,
                       X_Po_Headers_Archive             NUMBER DEFAULT NULL,
                       X_Po_Lines_Archive               NUMBER DEFAULT NULL,
                       X_Po_Line_Locations_Archive      NUMBER DEFAULT NULL,
                       X_Po_Vendor_List_Headers         NUMBER DEFAULT NULL,
                       X_Po_Vendor_List_Entries         NUMBER DEFAULT NULL,
                       X_Po_Notifications               NUMBER DEFAULT NULL,
                       X_Po_Accrual_Reconcile_Temp      NUMBER DEFAULT NULL,
                       X_Po_Blanket_Items               NUMBER DEFAULT NULL,
                       X_Po_Receipt_Headers             NUMBER DEFAULT NULL,
                       X_Organization_Id                NUMBER DEFAULT NULL,
                       X_Po_Approved_Supplier_List      NUMBER DEFAULT NULL,
                       X_Po_Asl_Attributes              NUMBER DEFAULT NULL,
                       X_Po_Asl_Documents               NUMBER DEFAULT NULL,
                       X_Chv_Authorizations             NUMBER DEFAULT NULL,
                       X_Chv_Cum_Adjustments            NUMBER DEFAULT NULL,
                       X_Chv_Cum_Periods                NUMBER DEFAULT NULL,
                       X_Chv_Cum_Period_Items           NUMBER DEFAULT NULL,
                       X_Chv_Horizontal_Schedules       NUMBER DEFAULT NULL,
                       X_Chv_Item_Orders                NUMBER DEFAULT NULL,
                       X_Chv_Schedule_Headers           NUMBER DEFAULT NULL,
                       X_Chv_Schedule_Items             NUMBER DEFAULT NULL,
                       X_Mrp_Sr_Source_Org              NUMBER DEFAULT NULL,
                       X_Mrp_Item_Sourcing              NUMBER DEFAULT NULL,
                       X_Action                         VARCHAR2 DEFAULT NULL,
		       X_calling_sequence		VARCHAR2
                      );

END FINANCIALS_PURGES_PKG_1;

 

/
