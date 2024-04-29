--------------------------------------------------------
--  DDL for Package Body AP_DUPLICATE_VENDORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_DUPLICATE_VENDORS_PKG" as
/* $Header: apiduveb.pls 120.3 2004/10/28 00:01:41 pjena noship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,

                       X_Entry_Id                       NUMBER DEFAULT NULL,
                       X_Vendor_Id                      NUMBER DEFAULT NULL,
                       X_Duplicate_Vendor_Id            NUMBER DEFAULT NULL,
                       X_Vendor_Site_Id                 NUMBER DEFAULT NULL,
                       X_Duplicate_Vendor_Site_Id       NUMBER DEFAULT NULL,
                       X_Number_Unpaid_Invoices         NUMBER DEFAULT NULL,
                       X_Number_Paid_Invoices           NUMBER DEFAULT NULL,
                       X_Number_Po_Headers_Changed      NUMBER DEFAULT NULL,
                       X_Amount_Unpaid_Invoices         NUMBER DEFAULT NULL,
                       X_Amount_Paid_Invoices           NUMBER DEFAULT NULL,
                       X_Last_Update_Date               DATE DEFAULT NULL,
                       X_Last_Updated_By                NUMBER DEFAULT NULL,
                       X_Process_Flag                   VARCHAR2 DEFAULT NULL,
                       X_Process                        VARCHAR2 DEFAULT NULL,
                       X_Keep_Site_Flag                 VARCHAR2 DEFAULT NULL,
                       X_Paid_Invoices_Flag             VARCHAR2 DEFAULT NULL,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Creation_Date                  DATE DEFAULT NULL,
                       X_Created_By                     NUMBER DEFAULT NULL,
                       X_Org_Id                         NUMBER,
		       X_calling_sequence	IN	VARCHAR2
  ) IS
    CURSOR C IS SELECT rowid FROM AP_DUPLICATE_VENDORS
                 WHERE (   (entry_id = X_Entry_Id)
                        or (entry_id is NULL and X_Entry_Id is NULL));

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);
 BEGIN

--     Update the calling sequence
--
       current_calling_sequence := 'AP_DUPLICATE_VENDORS_PKG.INSERT_ROW<-' ||
                                    X_calling_sequence;

       debug_info := 'Insert into AP_DUPLICATE_VENDORS';
       INSERT INTO AP_DUPLICATE_VENDORS(

              entry_id,
              vendor_id,
              duplicate_vendor_id,
              vendor_site_id,
              duplicate_vendor_site_id,
              number_unpaid_invoices,
              number_paid_invoices,
              number_po_headers_changed,
              amount_unpaid_invoices,
              amount_paid_invoices,
              last_update_date,
              last_updated_by,
              process_flag,
              process,
              keep_site_flag,
              paid_invoices_flag,
              last_update_login,
              creation_date,
              created_by,
              org_id
             ) VALUES (

              X_Entry_Id,
              X_Vendor_Id,
              X_Duplicate_Vendor_Id,
              X_Vendor_Site_Id,
              X_Duplicate_Vendor_Site_Id,
              X_Number_Unpaid_Invoices,
              X_Number_Paid_Invoices,
              X_Number_Po_Headers_Changed,
              X_Amount_Unpaid_Invoices,
              X_Amount_Paid_Invoices,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Process_Flag,
              X_Process,
              X_Keep_Site_Flag,
              X_Paid_Invoices_Flag,
              X_Last_Update_Login,
              X_Creation_Date,
              X_Created_By,
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
                                    ', ENTRY_ID = ' || X_Entry_Id);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

                     X_Entry_Id                         NUMBER DEFAULT NULL,
                     X_Vendor_Id                        NUMBER DEFAULT NULL,
                     X_Duplicate_Vendor_Id              NUMBER DEFAULT NULL,
                     X_Vendor_Site_Id                   NUMBER DEFAULT NULL,
                     X_Duplicate_Vendor_Site_Id         NUMBER DEFAULT NULL,
                     X_Number_Unpaid_Invoices           NUMBER DEFAULT NULL,
                     X_Number_Paid_Invoices             NUMBER DEFAULT NULL,
                     X_Number_Po_Headers_Changed        NUMBER DEFAULT NULL,
                     X_Amount_Unpaid_Invoices           NUMBER DEFAULT NULL,
                     X_Amount_Paid_Invoices             NUMBER DEFAULT NULL,
                     X_Process_Flag                     VARCHAR2 DEFAULT NULL,
                     X_Process                          VARCHAR2 DEFAULT NULL,
                     X_Keep_Site_Flag                   VARCHAR2 DEFAULT NULL,
                     X_Paid_Invoices_Flag               VARCHAR2 DEFAULT NULL,
                     X_Org_Id                           NUMBER,
		     X_calling_sequence		IN	VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   AP_DUPLICATE_VENDORS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Entry_Id NOWAIT;
    Recinfo C%ROWTYPE;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'AP_DUPLICATE_VENDORS_PKG.LOCK_ROW<-' ||
                                 X_calling_sequence;

    debug_info := 'Open cursor C';
    OPEN C;
    debug_info :=- 'Fetch cursor C';
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      debug_info := 'Close cursor  C - DATA NOT FOUND';
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    debug_info := 'Close cursor C';
    CLOSE C;
    if (

               (   (Recinfo.entry_id =  X_Entry_Id)
                OR (    (Recinfo.entry_id IS NULL)
                    AND (X_Entry_Id IS NULL)))
           AND (   (Recinfo.vendor_id =  X_Vendor_Id)
                OR (    (Recinfo.vendor_id IS NULL)
                    AND (X_Vendor_Id IS NULL)))
           AND (   (Recinfo.duplicate_vendor_id =  X_Duplicate_Vendor_Id)
                OR (    (Recinfo.duplicate_vendor_id IS NULL)
                    AND (X_Duplicate_Vendor_Id IS NULL)))
           AND (   (Recinfo.vendor_site_id =  X_Vendor_Site_Id)
                OR (    (Recinfo.vendor_site_id IS NULL)
                    AND (X_Vendor_Site_Id IS NULL)))
           AND (   (Recinfo.duplicate_vendor_site_id =  X_Duplicate_Vendor_Site_Id)
                OR (    (Recinfo.duplicate_vendor_site_id IS NULL)
                    AND (X_Duplicate_Vendor_Site_Id IS NULL)))
           AND (   (Recinfo.number_unpaid_invoices =  X_Number_Unpaid_Invoices)
                OR (    (Recinfo.number_unpaid_invoices IS NULL)
                    AND (X_Number_Unpaid_Invoices IS NULL)))
           AND (   (Recinfo.number_paid_invoices =  X_Number_Paid_Invoices)
                OR (    (Recinfo.number_paid_invoices IS NULL)
                    AND (X_Number_Paid_Invoices IS NULL)))
           AND (   (Recinfo.number_po_headers_changed =  X_Number_Po_Headers_Changed)
                OR (    (Recinfo.number_po_headers_changed IS NULL)
                    AND (X_Number_Po_Headers_Changed IS NULL)))
           AND (   (Recinfo.amount_unpaid_invoices =  X_Amount_Unpaid_Invoices)
                OR (    (Recinfo.amount_unpaid_invoices IS NULL)
                    AND (X_Amount_Unpaid_Invoices IS NULL)))
           AND (   (Recinfo.amount_paid_invoices =  X_Amount_Paid_Invoices)
                OR (    (Recinfo.amount_paid_invoices IS NULL)
                    AND (X_Amount_Paid_Invoices IS NULL)))
           AND (   (Recinfo.process_flag =  X_Process_Flag)
                OR (    (Recinfo.process_flag IS NULL)
                    AND (X_Process_Flag IS NULL)))
           AND (   (Recinfo.process =  X_Process)
                OR (    (Recinfo.process IS NULL)
                    AND (X_Process IS NULL)))
           AND (   (Recinfo.keep_site_flag =  X_Keep_Site_Flag)
                OR (    (Recinfo.keep_site_flag IS NULL)
                    AND (X_Keep_Site_Flag IS NULL)))
           AND (   (Recinfo.paid_invoices_flag =  X_Paid_Invoices_Flag)
                OR (    (Recinfo.paid_invoices_flag IS NULL)
                    AND (X_Paid_Invoices_Flag IS NULL)))
           AND (   (Recinfo.org_id =  X_Org_Id)
                OR (    (Recinfo.org_id IS NULL)
                    AND (X_Org_Id IS NULL)))

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
                                   ', ENTRY_ID = ' || X_Entry_Id);
             FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
	 END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Entry_Id                       NUMBER DEFAULT NULL,
                       X_Vendor_Id                      NUMBER DEFAULT NULL,
                       X_Duplicate_Vendor_Id            NUMBER DEFAULT NULL,
                       X_Vendor_Site_Id                 NUMBER DEFAULT NULL,
                       X_Duplicate_Vendor_Site_Id       NUMBER DEFAULT NULL,
                       X_Number_Unpaid_Invoices         NUMBER DEFAULT NULL,
                       X_Number_Paid_Invoices           NUMBER DEFAULT NULL,
                       X_Number_Po_Headers_Changed      NUMBER DEFAULT NULL,
                       X_Amount_Unpaid_Invoices         NUMBER DEFAULT NULL,
                       X_Amount_Paid_Invoices           NUMBER DEFAULT NULL,
                       X_Last_Update_Date               DATE DEFAULT NULL,
                       X_Last_Updated_By                NUMBER DEFAULT NULL,
                       X_Process_Flag                   VARCHAR2 DEFAULT NULL,
                       X_Process                        VARCHAR2 DEFAULT NULL,
                       X_Keep_Site_Flag                 VARCHAR2 DEFAULT NULL,
                       X_Paid_Invoices_Flag             VARCHAR2 DEFAULT NULL,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Org_Id                         NUMBER,
		       X_calling_sequence	IN	VARCHAR2

  ) IS

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

  BEGIN

--  Update the calling sequence
--
    current_calling_sequence := 'AP_DUPLICATE_VENDORS_PKG.UPDATE_ROW<-' ||
                                 X_calling_sequence;

    debug_info := 'Update AP_DUPLICATE_VENDORS';

    UPDATE AP_DUPLICATE_VENDORS
    SET
       entry_id                        =     X_Entry_Id,
       vendor_id                       =     X_Vendor_Id,
       duplicate_vendor_id             =     X_Duplicate_Vendor_Id,
       vendor_site_id                  =     X_Vendor_Site_Id,
       duplicate_vendor_site_id        =     X_Duplicate_Vendor_Site_Id,
       number_unpaid_invoices          =     X_Number_Unpaid_Invoices,
       number_paid_invoices            =     X_Number_Paid_Invoices,
       number_po_headers_changed       =     X_Number_Po_Headers_Changed,
       amount_unpaid_invoices          =     X_Amount_Unpaid_Invoices,
       amount_paid_invoices            =     X_Amount_Paid_Invoices,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       process_flag                    =     X_Process_Flag,
       process                         =     X_Process,
       keep_site_flag                  =     X_Keep_Site_Flag,
       paid_invoices_flag              =     X_Paid_Invoices_Flag,
       last_update_login               =     X_Last_Update_Login,
       org_id                          =     X_Org_Id
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
                                    ', ENTRY_ID = ' || X_Entry_Id);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid 				VARCHAR2,
		       X_calling_sequence	IN	VARCHAR2
  ) IS

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

  BEGIN

--  Update the calling sequence
--
    current_calling_sequence := 'AP_DUPLICATE_VENDORS_PKG.DELETE_ROW<-' ||
                                 X_calling_sequence;

    debug_info := 'Delete from AP_DUPLICATE_VENDORS';
    DELETE FROM AP_DUPLICATE_VENDORS
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


END AP_DUPLICATE_VENDORS_PKG;

/
