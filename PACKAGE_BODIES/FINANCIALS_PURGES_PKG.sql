--------------------------------------------------------
--  DDL for Package Body FINANCIALS_PURGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FINANCIALS_PURGES_PKG" as
/* $Header: apifipub.pls 120.3 2004/10/28 00:02:56 pjena noship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,

                       X_Purge_Name                     VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
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
		       X_calling_sequence	IN	VARCHAR2,
                       X_Org_Id                         NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM FINANCIALS_PURGES
                 WHERE purge_name = X_Purge_Name;
    current_calling_sequence	VARCHAR2(2000);
    debug_info			VARCHAR2(100);
   BEGIN

--     Update the calling sequence
--
       current_calling_sequence := 'FINANCIALS_PURGES_PKG.INSERT_ROW<-' ||
                                    X_calling_sequence;


       debug_info := 'Insert into FINANCIALS_PURGES';

       INSERT INTO FINANCIALS_PURGES(

              purge_name,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login,
              category,
              status,
              activity_date,
              ap_checks,
              ap_invoice_payments,
              ap_payment_schedules,
              ap_recurring_payments,
              ap_trial_balance,
              ap_holds,
              ap_invoice_distributions,
              ap_batches,
              ap_invoices,
              po_requisition_headers,
              po_requisition_lines,
              po_req_distributions,
              po_approvals,
              po_headers,
              po_lines,
              po_line_locations,
              po_distributions,
              po_releases,
              po_item_history,
              po_acceptances,
              po_notes,
              po_note_references,
              po_receipts,
              po_deliveries,
              po_quality_inspections,
              po_vendors,
              po_vendor_sites,
              po_vendor_contacts,
              po_headers_archive,
              po_lines_archive,
              po_line_locations_archive,
              po_vendor_list_headers,
              po_vendor_list_entries,
              po_notifications,
              po_accrual_reconcile_temp,
              po_blanket_items,
              po_receipt_headers,
              Organization_Id,
              Po_Approved_Supplier_List,
              Po_Asl_Attributes,
              Po_Asl_Documents,
              Chv_Authorizations,
              Chv_Cum_Adjustments,
              Chv_Cum_Periods,
              Chv_Cum_Period_Items,
              Chv_Horizontal_Schedules,
              Chv_Item_Orders,
              Chv_Schedule_Headers,
              Chv_Schedule_Items,
              Mrp_Sr_Source_Org,
              Mrp_Item_Sourcing,
              action,
              org_id
             ) VALUES (

              X_Purge_Name,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Last_Update_Login,
              X_Category,
              X_Status,
              X_Activity_Date,
              X_Ap_Checks,
              X_Ap_Invoice_Payments,
              X_Ap_Payment_Schedules,
              X_Ap_Recurring_Payments,
              X_Ap_Trial_Balance,
              X_Ap_Holds,
              X_Ap_Invoice_Distributions,
              X_Ap_Batches,
              X_Ap_Invoices,
              X_Po_Requisition_Headers,
              X_Po_Requisition_Lines,
              X_Po_Req_Distributions,
              X_Po_Approvals,
              X_Po_Headers,
              X_Po_Lines,
              X_Po_Line_Locations,
              X_Po_Distributions,
              X_Po_Releases,
              X_Po_Item_History,
              X_Po_Acceptances,
              X_Po_Notes,
              X_Po_Note_References,
              X_Po_Receipts,
              X_Po_Deliveries,
              X_Po_Quality_Inspections,
              X_Po_Vendors,
              X_Po_Vendor_Sites,
              X_Po_Vendor_Contacts,
              X_Po_Headers_Archive,
              X_Po_Lines_Archive,
              X_Po_Line_Locations_Archive,
              X_Po_Vendor_List_Headers,
              X_Po_Vendor_List_Entries,
              X_Po_Notifications,
              X_Po_Accrual_Reconcile_Temp,
              X_Po_Blanket_Items,
              X_Po_Receipt_Headers,
              X_Organization_Id,
              X_Po_Approved_Supplier_List,
              X_Po_Asl_Attributes,
              X_Po_Asl_Documents,
              X_Chv_Authorizations,
              X_Chv_Cum_Adjustments,
              X_Chv_Cum_Periods,
              X_Chv_Cum_Period_Items,
              X_Chv_Horizontal_Schedules,
              X_Chv_Item_Orders,
              X_Chv_Schedule_Headers,
              X_Chv_Schedule_Items,
              X_Mrp_Sr_Source_Org,
              X_Mrp_Item_Sourcing,
              X_Action,
              X_Org_Id
             );

    debug_info := 'Open cursor C';
    OPEN C;

    debug_info := 'Fetch cursor C';
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      debug_info := 'Close cursor C - DATA NOTFOUND';
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    debug_info := 'Close cursor C';
    CLOSE C;


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

  END Insert_Row;

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

                     X_Purge_Name                       VARCHAR2,
                     X_Category                         VARCHAR2,
                     X_Status                           VARCHAR2,
                     X_Activity_Date                    DATE DEFAULT NULL,
                     X_Ap_Checks                        NUMBER DEFAULT NULL,
                     X_Ap_Invoice_Payments              NUMBER DEFAULT NULL,
                     X_Ap_Payment_Schedules             NUMBER DEFAULT NULL,
                     X_Ap_Recurring_Payments            NUMBER DEFAULT NULL,
                     X_Ap_Trial_Balance                 NUMBER DEFAULT NULL,
                     X_Ap_Holds                         NUMBER DEFAULT NULL,
                     X_Ap_Invoice_Distributions         NUMBER DEFAULT NULL,
                     X_Ap_Batches                       NUMBER DEFAULT NULL,
                     X_Ap_Invoices                      NUMBER DEFAULT NULL,
                     X_Po_Requisition_Headers           NUMBER DEFAULT NULL,
                     X_Po_Requisition_Lines             NUMBER DEFAULT NULL,
                     X_Po_Req_Distributions             NUMBER DEFAULT NULL,
                     X_Po_Approvals                     NUMBER DEFAULT NULL,
                     X_Po_Headers                       NUMBER DEFAULT NULL,
                     X_Po_Lines                         NUMBER DEFAULT NULL,
                     X_Po_Line_Locations                NUMBER DEFAULT NULL,
                     X_Po_Distributions                 NUMBER DEFAULT NULL,
                     X_Po_Releases                      NUMBER DEFAULT NULL,
                     X_Po_Item_History                  NUMBER DEFAULT NULL,
                     X_Po_Acceptances                   NUMBER DEFAULT NULL,
                     X_Po_Notes                         NUMBER DEFAULT NULL,
                     X_Po_Note_References               NUMBER DEFAULT NULL,
                     X_Po_Receipts                      NUMBER DEFAULT NULL,
                     X_Po_Deliveries                    NUMBER DEFAULT NULL,
                     X_Po_Quality_Inspections           NUMBER DEFAULT NULL,
                     X_Po_Vendors                       NUMBER DEFAULT NULL,
                     X_Po_Vendor_Sites                  NUMBER DEFAULT NULL,
                     X_Po_Vendor_Contacts               NUMBER DEFAULT NULL,
                     X_Po_Headers_Archive               NUMBER DEFAULT NULL,
                     X_Po_Lines_Archive                 NUMBER DEFAULT NULL,
                     X_Po_Line_Locations_Archive        NUMBER DEFAULT NULL,
                     X_Po_Vendor_List_Headers           NUMBER DEFAULT NULL,
                     X_Po_Vendor_List_Entries           NUMBER DEFAULT NULL,
                     X_Po_Notifications                 NUMBER DEFAULT NULL,
                     X_Po_Accrual_Reconcile_Temp        NUMBER DEFAULT NULL,
                     X_Po_Blanket_Items                 NUMBER DEFAULT NULL,
                     X_Po_Receipt_Headers               NUMBER DEFAULT NULL,
                     X_Organization_Id			NUMBER DEFAULT NULL,
                     X_Po_Approved_Supplier_List	NUMBER DEFAULT NULL,
                     X_Po_Asl_Attributes		NUMBER DEFAULT NULL,
                     X_Po_Asl_Documents			NUMBER DEFAULT NULL,
                     X_Chv_Authorizations		NUMBER DEFAULT NULL,
                     X_Chv_Cum_Adjustments		NUMBER DEFAULT NULL,
                     X_Chv_Cum_Periods			NUMBER DEFAULT NULL,
                     X_Chv_Cum_Period_Items		NUMBER DEFAULT NULL,
                     X_Chv_Horizontal_Schedules		NUMBER DEFAULT NULL,
                     X_Chv_Item_Orders			NUMBER DEFAULT NULL,
                     X_Chv_Schedule_Headers		NUMBER DEFAULT NULL,
                     X_Chv_Schedule_Items		NUMBER DEFAULT NULL,
                     X_Mrp_Sr_Source_Org		NUMBER DEFAULT NULL,
                     X_Mrp_Item_Sourcing		NUMBER DEFAULT NULL,
                     X_Action                           VARCHAR2 DEFAULT NULL,
                     X_calling_sequence			VARCHAR2,
                     X_Org_Id                           NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   FINANCIALS_PURGES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Purge_Name NOWAIT;
    Recinfo C%ROWTYPE;

    current_calling_sequence	VARCHAR2(2000);
    debug_info			VARCHAR2(100);

  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'FINANCIALS_PURGES_PKG.LOCK_ROW<-' ||
                                 X_calling_sequence;

    debug_info := 'Open cursor C';
    OPEN C;

    debug_info := 'Fetch cursor C';
    FETCH C INTO Recinfo;

    if (C%NOTFOUND) then
      debug_info := 'Close cursor C - DATA NOTFOUND';
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    debug_info := 'Close cursor C';
    CLOSE C;
    if (

               (Recinfo.purge_name =  X_Purge_Name)
           AND (Recinfo.category =  X_Category)
           AND (Recinfo.status =  X_Status)
           AND (Recinfo.org_id =  X_Org_Id)
           AND (   (Recinfo.activity_date =  X_Activity_Date)
                OR (    (Recinfo.activity_date IS NULL)
                    AND (X_Activity_Date IS NULL)))
           AND (   (Recinfo.ap_checks =  X_Ap_Checks)
                OR (    (Recinfo.ap_checks IS NULL)
                    AND (X_Ap_Checks IS NULL)))
           AND (   (Recinfo.ap_invoice_payments =  X_Ap_Invoice_Payments)
                OR (    (Recinfo.ap_invoice_payments IS NULL)
                    AND (X_Ap_Invoice_Payments IS NULL)))
           AND (   (Recinfo.ap_payment_schedules =  X_Ap_Payment_Schedules)
                OR (    (Recinfo.ap_payment_schedules IS NULL)
                    AND (X_Ap_Payment_Schedules IS NULL)))
           AND (   (Recinfo.ap_recurring_payments =  X_Ap_Recurring_Payments)
                OR (    (Recinfo.ap_recurring_payments IS NULL)
                    AND (X_Ap_Recurring_Payments IS NULL)))
           AND (   (Recinfo.ap_trial_balance =  X_Ap_Trial_Balance)
                OR (    (Recinfo.ap_trial_balance IS NULL)
                    AND (X_Ap_Trial_Balance IS NULL)))
           AND (   (Recinfo.ap_holds =  X_Ap_Holds)
                OR (    (Recinfo.ap_holds IS NULL)
                    AND (X_Ap_Holds IS NULL)))
           AND (   (Recinfo.ap_invoice_distributions =
						X_Ap_Invoice_Distributions)
                OR (    (Recinfo.ap_invoice_distributions IS NULL)
                    AND (X_Ap_Invoice_Distributions IS NULL)))
           AND (   (Recinfo.ap_batches =  X_Ap_Batches)
                OR (    (Recinfo.ap_batches IS NULL)
                    AND (X_Ap_Batches IS NULL)))
           AND (   (Recinfo.ap_invoices =  X_Ap_Invoices)
                OR (    (Recinfo.ap_invoices IS NULL)
                    AND (X_Ap_Invoices IS NULL)))
           AND (   (Recinfo.po_requisition_headers =  X_Po_Requisition_Headers)
                OR (    (Recinfo.po_requisition_headers IS NULL)
                    AND (X_Po_Requisition_Headers IS NULL)))
           AND (   (Recinfo.po_requisition_lines =  X_Po_Requisition_Lines)
                OR (    (Recinfo.po_requisition_lines IS NULL)
                    AND (X_Po_Requisition_Lines IS NULL)))
           AND (   (Recinfo.po_req_distributions =  X_Po_Req_Distributions)
                OR (    (Recinfo.po_req_distributions IS NULL)
                    AND (X_Po_Req_Distributions IS NULL)))
           AND (   (Recinfo.po_approvals =  X_Po_Approvals)
                OR (    (Recinfo.po_approvals IS NULL)
                    AND (X_Po_Approvals IS NULL)))
           AND (   (Recinfo.po_headers =  X_Po_Headers)
                OR (    (Recinfo.po_headers IS NULL)
                    AND (X_Po_Headers IS NULL)))
           AND (   (Recinfo.po_lines =  X_Po_Lines)
                OR (    (Recinfo.po_lines IS NULL)
                    AND (X_Po_Lines IS NULL)))
           AND (   (Recinfo.po_line_locations =  X_Po_Line_Locations)
                OR (    (Recinfo.po_line_locations IS NULL)
                    AND (X_Po_Line_Locations IS NULL)))
           AND (   (Recinfo.po_distributions =  X_Po_Distributions)
                OR (    (Recinfo.po_distributions IS NULL)
                    AND (X_Po_Distributions IS NULL)))
           AND (   (Recinfo.po_releases =  X_Po_Releases)
                OR (    (Recinfo.po_releases IS NULL)
                    AND (X_Po_Releases IS NULL)))
           AND (   (Recinfo.po_item_history =  X_Po_Item_History)
                OR (    (Recinfo.po_item_history IS NULL)
                    AND (X_Po_Item_History IS NULL)))
           AND (   (Recinfo.po_acceptances =  X_Po_Acceptances)
                OR (    (Recinfo.po_acceptances IS NULL)
                    AND (X_Po_Acceptances IS NULL)))
           AND (   (Recinfo.po_notes =  X_Po_Notes)
                OR (    (Recinfo.po_notes IS NULL)
                    AND (X_Po_Notes IS NULL)))
           AND (   (Recinfo.po_note_references =  X_Po_Note_References)
                OR (    (Recinfo.po_note_references IS NULL)
                    AND (X_Po_Note_References IS NULL)))
           AND (   (Recinfo.po_receipts =  X_Po_Receipts)
                OR (    (Recinfo.po_receipts IS NULL)
                    AND (X_Po_Receipts IS NULL)))
           AND (   (Recinfo.po_deliveries =  X_Po_Deliveries)
                OR (    (Recinfo.po_deliveries IS NULL)
                    AND (X_Po_Deliveries IS NULL)))
           AND (   (Recinfo.po_quality_inspections =  X_Po_Quality_Inspections)
                OR (    (Recinfo.po_quality_inspections IS NULL)
                    AND (X_Po_Quality_Inspections IS NULL)))
           AND (   (Recinfo.po_vendors =  X_Po_Vendors)
                OR (    (Recinfo.po_vendors IS NULL)
                    AND (X_Po_Vendors IS NULL)))
           AND (   (Recinfo.po_vendor_sites =  X_Po_Vendor_Sites)
                OR (    (Recinfo.po_vendor_sites IS NULL)
                    AND (X_Po_Vendor_Sites IS NULL)))
           AND (   (Recinfo.po_vendor_contacts =  X_Po_Vendor_Contacts)
                OR (    (Recinfo.po_vendor_contacts IS NULL)
                    AND (X_Po_Vendor_Contacts IS NULL)))
           AND (   (Recinfo.po_headers_archive =  X_Po_Headers_Archive)
                OR (    (Recinfo.po_headers_archive IS NULL)
                    AND (X_Po_Headers_Archive IS NULL)))
           AND (   (Recinfo.po_lines_archive =  X_Po_Lines_Archive)
                OR (    (Recinfo.po_lines_archive IS NULL)
                    AND (X_Po_Lines_Archive IS NULL)))
           AND (   (Recinfo.po_line_locations_archive =  X_Po_Line_Locations_Archive)
                OR (    (Recinfo.po_line_locations_archive IS NULL)
                    AND (X_Po_Line_Locations_Archive IS NULL)))
           AND (   (Recinfo.po_vendor_list_headers =  X_Po_Vendor_List_Headers)
                OR (    (Recinfo.po_vendor_list_headers IS NULL)
                    AND (X_Po_Vendor_List_Headers IS NULL)))
           AND (   (Recinfo.po_vendor_list_entries =  X_Po_Vendor_List_Entries)
                OR (    (Recinfo.po_vendor_list_entries IS NULL)
                    AND (X_Po_Vendor_List_Entries IS NULL)))
           AND (   (Recinfo.po_notifications =  X_Po_Notifications)
                OR (    (Recinfo.po_notifications IS NULL)
                    AND (X_Po_Notifications IS NULL)))
           AND (   (Recinfo.po_accrual_reconcile_temp =  X_Po_Accrual_Reconcile_Temp)
                OR (    (Recinfo.po_accrual_reconcile_temp IS NULL)
                    AND (X_Po_Accrual_Reconcile_Temp IS NULL)))
           AND (   (Recinfo.po_blanket_items =  X_Po_Blanket_Items)
                OR (    (Recinfo.po_blanket_items IS NULL)
                    AND (X_Po_Blanket_Items IS NULL)))
           AND (   (Recinfo.po_receipt_headers =  X_Po_Receipt_Headers)
                OR (    (Recinfo.po_receipt_headers IS NULL)
                    AND (X_Po_Receipt_Headers IS NULL)))
           AND (   (Recinfo.action =  X_Action)
                OR (    (Recinfo.action IS NULL)
                    AND (X_Action IS NULL)))
           AND (    (Recinfo.Organization_Id =   X_Organization_Id)
                OR (    (Recinfo.Organization_Id IS NULL)
                    AND (X_Organization_Id IS NULL)))
           AND (    (Recinfo.Po_Approved_Supplier_List =   X_Po_Approved_Supplier_List)
                OR (    (Recinfo.Po_Approved_Supplier_List IS NULL)
                    AND (X_Po_Approved_Supplier_List IS NULL)))
           AND (    (Recinfo.Po_Asl_Attributes =   X_Po_Asl_Attributes)
                OR (    (Recinfo.Po_Asl_Attributes IS NULL)
                    AND (X_Po_Asl_Attributes IS NULL)))
           AND (    (Recinfo.Po_Asl_Documents =   X_Po_Asl_Documents)
                OR (    (Recinfo.Po_Asl_Documents IS NULL)
                    AND (X_Po_Asl_Documents IS NULL)))
           AND (    (Recinfo.Chv_Authorizations =   X_Chv_Authorizations)
                OR (    (Recinfo.Chv_Authorizations IS NULL)
                    AND (X_Chv_Authorizations IS NULL)))
           AND (    (Recinfo.Chv_Cum_Adjustments =   X_Chv_Cum_Adjustments)
                OR (    (Recinfo.Chv_Cum_Adjustments IS NULL)
                    AND (X_Chv_Cum_Adjustments IS NULL)))
           AND (    (Recinfo.Chv_Cum_Periods =   X_Chv_Cum_Periods)
                OR (    (Recinfo.Chv_Cum_Periods IS NULL)
                    AND (X_Chv_Cum_Periods IS NULL)))
           AND (    (Recinfo.Chv_Cum_Period_Items =   X_Chv_Cum_Period_Items)
                OR (    (Recinfo.Chv_Cum_Period_Items IS NULL)
                    AND (X_Chv_Cum_Period_Items IS NULL)))
           AND (    (Recinfo.Chv_Horizontal_Schedules =   X_Chv_Horizontal_Schedules)
                OR (    (Recinfo.Chv_Horizontal_Schedules IS NULL)
                    AND (X_Chv_Horizontal_Schedules IS NULL)))
           AND (    (Recinfo.Chv_Item_Orders =   X_Chv_Item_Orders)
                OR (    (Recinfo.Chv_Item_Orders IS NULL)
                    AND (X_Chv_Item_Orders IS NULL)))
           AND (    (Recinfo.Chv_Schedule_Headers =   X_Chv_Schedule_Headers)
                OR (    (Recinfo.Chv_Schedule_Headers IS NULL)
                    AND (X_Chv_Schedule_Headers IS NULL)))
           AND (    (Recinfo.Chv_Schedule_Items =   X_Chv_Schedule_Items)
                OR (    (Recinfo.Chv_Schedule_Items IS NULL)
                    AND (X_Chv_Schedule_Items IS NULL)))
           AND (    (Recinfo.Mrp_Sr_Source_Org =   X_Mrp_Sr_Source_Org)
                OR (    (Recinfo.Mrp_Sr_Source_Org IS NULL)
                    AND (X_Mrp_Sr_Source_Org IS NULL)))
           AND (    (Recinfo.Mrp_Item_Sourcing =   X_Mrp_Item_Sourcing)
                OR (    (Recinfo.Mrp_Item_Sourcing IS NULL)
                    AND (X_Mrp_Item_Sourcing IS NULL)))


      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

    EXCEPTION
      WHEN OTHERS THEN
         IF (SQLCODE <> -20001) THEN
           IF (SQLCODE = -54) THEN
             FND_MESSAGE.SET_NAME('SQLAP','AP_RESOURCE_BUSY');
           ELSE
             FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
             FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
             FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
             FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_Rowid ||
                                   ', PURGE_NAME = ' || X_Purge_name);
             FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
	 END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

  END Lock_Row;


  PROCEDURE Delete_Row(X_Rowid				VARCHAR2,
		       X_calling_sequence	IN	VARCHAR2
  ) IS
    current_calling_sequence	VARCHAR2(2000);
    debug_info			VARCHAR2(100);
  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'FINANCIALS_PURGES_PKG.DELETE_ROW<-' ||
                                 X_calling_sequence;

    debug_info := 'Delete from FINANCIALS_PURGES';
    DELETE FROM FINANCIALS_PURGES
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
              FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_Rowid);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Delete_Row;


END FINANCIALS_PURGES_PKG;

/
