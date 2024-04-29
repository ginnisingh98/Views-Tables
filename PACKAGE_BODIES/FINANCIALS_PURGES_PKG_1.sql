--------------------------------------------------------
--  DDL for Package Body FINANCIALS_PURGES_PKG_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FINANCIALS_PURGES_PKG_1" as
/* $Header: apifip1b.pls 120.3 2004/10/28 00:02:20 pjena noship $ */


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
		       X_calling_sequence	IN	VARCHAR2
  ) IS

    current_calling_sequence	VARCHAR2(2000);
    debug_info			VARCHAR2(100);

  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'FINANCIALS_PURGES_PKG.UPDATE_ROW<-' ||
                                 X_calling_sequence;

    debug_info := 'Update FINANCIALS_PURGES';
    UPDATE FINANCIALS_PURGES
    SET
       purge_name                      =     X_Purge_Name,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       category                        =     X_Category,
       status                          =     X_Status,
       activity_date                   =     X_Activity_Date,
       ap_checks                       =     X_Ap_Checks,
       ap_invoice_payments             =     X_Ap_Invoice_Payments,
       ap_payment_schedules            =     X_Ap_Payment_Schedules,
       ap_recurring_payments           =     X_Ap_Recurring_Payments,
       ap_trial_balance                =     X_Ap_Trial_Balance,
       ap_holds                        =     X_Ap_Holds,
       ap_invoice_distributions        =     X_Ap_Invoice_Distributions,
       ap_batches                      =     X_Ap_Batches,
       ap_invoices                     =     X_Ap_Invoices,
       po_requisition_headers          =     X_Po_Requisition_Headers,
       po_requisition_lines            =     X_Po_Requisition_Lines,
       po_req_distributions            =     X_Po_Req_Distributions,
       po_approvals                    =     X_Po_Approvals,
       po_headers                      =     X_Po_Headers,
       po_lines                        =     X_Po_Lines,
       po_line_locations               =     X_Po_Line_Locations,
       po_distributions                =     X_Po_Distributions,
       po_releases                     =     X_Po_Releases,
       po_item_history                 =     X_Po_Item_History,
       po_acceptances                  =     X_Po_Acceptances,
       po_notes                        =     X_Po_Notes,
       po_note_references              =     X_Po_Note_References,
       po_receipts                     =     X_Po_Receipts,
       po_deliveries                   =     X_Po_Deliveries,
       po_quality_inspections          =     X_Po_Quality_Inspections,
       po_vendors                      =     X_Po_Vendors,
       po_vendor_sites                 =     X_Po_Vendor_Sites,
       po_vendor_contacts              =     X_Po_Vendor_Contacts,
       po_headers_archive              =     X_Po_Headers_Archive,
       po_lines_archive                =     X_Po_Lines_Archive,
       po_line_locations_archive       =     X_Po_Line_Locations_Archive,
       po_vendor_list_headers          =     X_Po_Vendor_List_Headers,
       po_vendor_list_entries          =     X_Po_Vendor_List_Entries,
       po_notifications                =     X_Po_Notifications,
       po_accrual_reconcile_temp       =     X_Po_Accrual_Reconcile_Temp,
       po_blanket_items                =     X_Po_Blanket_Items,
       po_receipt_headers              =     X_Po_Receipt_Headers,
       Organization_Id                 =     X_Organization_Id,
       Po_Approved_Supplier_List       =     X_Po_Approved_Supplier_List,
       Po_Asl_Attributes               =     X_Po_Asl_Attributes,
       Po_Asl_Documents                =     X_Po_Asl_Documents,
       Chv_Authorizations              =     X_Chv_Authorizations,
       Chv_Cum_Adjustments             =     X_Chv_Cum_Adjustments,
       Chv_Cum_Periods                 =     X_Chv_Cum_Periods,
       Chv_Cum_Period_Items            =     X_Chv_Cum_Period_Items,
       Chv_Horizontal_Schedules        =     X_Chv_Horizontal_Schedules,
       Chv_Item_Orders                 =     X_Chv_Item_Orders,
       Chv_Schedule_Headers            =     X_Chv_Schedule_Headers,
       Chv_Schedule_Items              =     X_Chv_Schedule_Items,
       Mrp_Sr_Source_Org               =     X_Mrp_Sr_Source_Org,
       Mrp_Item_Sourcing               =     X_Mrp_Item_Sourcing,
       action                          =     X_Action
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    EXCEPTION
        WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_Rowid ||
                                    ', PURGE_NAME = ' || X_Purge_name);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Update_Row;

END FINANCIALS_PURGES_PKG_1;

/
