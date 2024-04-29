--------------------------------------------------------
--  DDL for Package Body JL_BR_AP_CONSOLID_INVOICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AP_CONSOLID_INVOICES_PKG" as
/* $Header: jlbrpcib.pls 120.2 2003/04/26 00:29:12 thwon ship $ */

  PROCEDURE Insert_Row(X_Rowid                    IN OUT NOCOPY VARCHAR2,

		       X_Consolidated_Invoice_Id         NUMBER,
 		       X_Vendor_Id                       NUMBER,
 		       X_Invoice_Num                     VARCHAR2,
		       X_Set_Of_Books_Id                 NUMBER,
		       X_Invoice_Currency_Code           VARCHAR2,
		       X_Invoice_Amount                  NUMBER DEFAULT NULL,
		       X_Vendor_Site_Id                  NUMBER DEFAULT NULL,
		       X_Invoice_Date                    DATE DEFAULT NULL,
		       X_Description                     VARCHAR2 DEFAULT NULL,
		       X_Terms_Id                        NUMBER DEFAULT NULL,
		       X_Terms_Date                      DATE DEFAULT NULL,
		       X_Cancelled_Date                  DATE DEFAULT NULL,
		       X_Cancelled_By                    NUMBER DEFAULT NULL,
		       X_Cancelled_Amount                NUMBER DEFAULT NULL,
                       X_Amt_Applicable_To_Discount   NUMBER DEFAULT NULL,
		       X_Attribute_Category              VARCHAR2 DEFAULT NULL,
		       X_Attribute1                      VARCHAR2 DEFAULT NULL,
		       X_Attribute2                      VARCHAR2 DEFAULT NULL,
		       X_Attribute3                      VARCHAR2 DEFAULT NULL,
		       X_Attribute4                      VARCHAR2 DEFAULT NULL,
		       X_Attribute5                      VARCHAR2 DEFAULT NULL,
		       X_Attribute6                      VARCHAR2 DEFAULT NULL,
		       X_Attribute7                      VARCHAR2 DEFAULT NULL,
		       X_Attribute8                      VARCHAR2 DEFAULT NULL,
		       X_Attribute9                      VARCHAR2 DEFAULT NULL,
		       X_Attribute10                     VARCHAR2 DEFAULT NULL,
		       X_Attribute11                     VARCHAR2 DEFAULT NULL,
		       X_Attribute12                     VARCHAR2 DEFAULT NULL,
		       X_Attribute13                     VARCHAR2 DEFAULT NULL,
		       X_Attribute14                     VARCHAR2 DEFAULT NULL,
		       X_Attribute15                     VARCHAR2 DEFAULT NULL,
		       X_Last_Update_Date                DATE,
		       X_Last_Updated_By                 NUMBER,
		       X_Creation_Date                   DATE DEFAULT NULL,
		       X_Created_By                      NUMBER DEFAULT NULL,
		       X_Last_Update_Login               NUMBER DEFAULT NULL,
		       X_Pay_Group_Lookup_Code           VARCHAR2 DEFAULT NULL,
		       X_Pay_Group_Flag                  VARCHAR2 DEFAULT NULL,
		       X_Org_ID                          NUMBER DEFAULT NULL,
		       X_calling_sequence	      IN VARCHAR2
  ) IS
    CURSOR C IS SELECT rowid FROM JL_BR_AP_CONSOLID_INVOICES
                 WHERE consolidated_invoice_id = X_Consolidated_Invoice_Id;
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

   BEGIN
--     Update the calling sequence
--
       current_calling_sequence := 'JL_BR_AP_CONSOLID_INVOICES_PKG.INSERT_ROW<-' ||
                                    X_calling_sequence;

       debug_info := 'Insert into JL_BR_AP_CONSOLID_INVOICES';
       INSERT INTO JL_BR_AP_CONSOLID_INVOICES(
 		consolidated_invoice_id,
 		vendor_id,
 		invoice_num,
 		set_of_books_id,
 		invoice_currency_code,
 		invoice_amount,
 		vendor_site_id,
 		invoice_date,
 		description,
 		terms_id,
 		terms_date,
 		cancelled_date,
 		cancelled_by,
 		cancelled_amount,
 		amount_applicable_to_discount,
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
 		last_update_date,
 		last_updated_by,
 		creation_date,
 		created_by,
 		last_update_login,
 		pay_group_lookup_code,
                pay_group_flag,
                org_id
             ) VALUES (
 		X_Consolidated_Invoice_Id,
 		X_Vendor_Id,
 		X_Invoice_Num,
 		X_Set_Of_Books_Id,
 		X_Invoice_Currency_Code,
 		X_Invoice_Amount,
 		X_Vendor_Site_Id,
 		X_Invoice_Date,
 		X_Description,
 		X_Terms_Id,
 		X_Terms_Date,
 		X_Cancelled_Date,
 		X_Cancelled_By,
 		X_Cancelled_Amount,
                X_Amt_Applicable_To_Discount,
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
 		X_Last_Update_Date,
 		X_Last_Updated_By,
 		X_Creation_Date,
 		X_Created_By,
 		X_Last_Update_Login,
 		X_Pay_Group_Lookup_Code,
 		X_Pay_Group_Flag,
                X_Org_ID
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
              FND_MESSAGE.SET_TOKEN('PARAMETERS','CONSOLIDATED_INVOICE_ID = ' ||
                                    X_Consolidated_Invoice_Id);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;

  PROCEDURE Lock_Row(X_Rowid                           VARCHAR2,

		     X_Consolidated_Invoice_Id         NUMBER,
 		     X_Vendor_Id                       NUMBER,
 		     X_Invoice_Num                     VARCHAR2,
		     X_Set_Of_Books_Id                 NUMBER,
		     X_Invoice_Currency_Code           VARCHAR2,
		     X_Invoice_Amount                  NUMBER DEFAULT NULL,
		     X_Vendor_Site_Id                  NUMBER DEFAULT NULL,
		     X_Invoice_Date                    DATE DEFAULT NULL,
		     X_Description                     VARCHAR2 DEFAULT NULL,
		     X_Terms_Id                        NUMBER DEFAULT NULL,
		     X_Terms_Date                      DATE DEFAULT NULL,
		     X_Cancelled_Date                  DATE DEFAULT NULL,
		     X_Cancelled_By                    NUMBER DEFAULT NULL,
		     X_Cancelled_Amount                NUMBER DEFAULT NULL,
                     X_Amt_Applicable_To_Discount   NUMBER DEFAULT NULL,
		     X_Attribute_Category              VARCHAR2 DEFAULT NULL,
		     X_Attribute1                      VARCHAR2 DEFAULT NULL,
		     X_Attribute2                      VARCHAR2 DEFAULT NULL,
		     X_Attribute3                      VARCHAR2 DEFAULT NULL,
		     X_Attribute4                      VARCHAR2 DEFAULT NULL,
		     X_Attribute5                      VARCHAR2 DEFAULT NULL,
		     X_Attribute6                      VARCHAR2 DEFAULT NULL,
		     X_Attribute7                      VARCHAR2 DEFAULT NULL,
		     X_Attribute8                      VARCHAR2 DEFAULT NULL,
		     X_Attribute9                      VARCHAR2 DEFAULT NULL,
		     X_Attribute10                     VARCHAR2 DEFAULT NULL,
		     X_Attribute11                     VARCHAR2 DEFAULT NULL,
		     X_Attribute12                     VARCHAR2 DEFAULT NULL,
		     X_Attribute13                     VARCHAR2 DEFAULT NULL,
		     X_Attribute14                     VARCHAR2 DEFAULT NULL,
		     X_Attribute15                     VARCHAR2 DEFAULT NULL,
		     X_Last_Update_Date                DATE,
		     X_Last_Updated_By                 NUMBER,
		     X_Creation_Date                   DATE DEFAULT NULL,
		     X_Created_By                      NUMBER DEFAULT NULL,
		     X_Last_Update_Login               NUMBER DEFAULT NULL,
		     X_Pay_Group_Lookup_Code           VARCHAR2 DEFAULT NULL,
		     X_Pay_Group_Flag                  VARCHAR2 DEFAULT NULL,
		     X_calling_sequence		IN     VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   JL_BR_AP_CONSOLID_INVOICES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Consolidated_Invoice_Id NOWAIT;
    Recinfo C%ROWTYPE;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'JL_BR_AP_CONSOLID_INVOICES_PKG.LOCK_ROW<-' ||
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
               (Recinfo.consolidated_invoice_id =  X_Consolidated_Invoice_Id)
           AND (Recinfo.vendor_id =  X_Vendor_Id)
           AND (Recinfo.invoice_num =  X_Invoice_Num)
           AND (Recinfo.set_of_books_id =  X_Set_Of_Books_Id)
           AND (Recinfo.invoice_currency_code =  X_Invoice_Currency_Code)
           AND (   (Recinfo.invoice_amount =  X_Invoice_Amount)
                OR (    (Recinfo.invoice_amount IS NULL)
                    AND (X_Invoice_Amount IS NULL)))
           AND (   (Recinfo.vendor_site_id =  X_Vendor_Site_Id)
                OR (    (Recinfo.vendor_site_id IS NULL)
                    AND (X_Vendor_Site_Id IS NULL)))
           AND (   (Recinfo.invoice_date =  X_Invoice_Date)
                OR (    (Recinfo.invoice_date IS NULL)
                    AND (X_Invoice_Date IS NULL)))
           AND (   (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
           AND (   (Recinfo.terms_id =  X_Terms_Id)
                OR (    (Recinfo.terms_id IS NULL)
                    AND (X_Terms_Id IS NULL)))
           AND (   (Recinfo.terms_date =  X_Terms_Date)
                OR (    (Recinfo.terms_date IS NULL)
                    AND (X_Terms_Date IS NULL)))
           AND (   (Recinfo.cancelled_date =  X_Cancelled_Date)
                OR (    (Recinfo.cancelled_date IS NULL)
                    AND (X_Cancelled_Date IS NULL)))
           AND (   (Recinfo.cancelled_by =  X_Cancelled_By)
                OR (    (Recinfo.cancelled_by IS NULL)
                    AND (X_Cancelled_By IS NULL)))
           AND (   (Recinfo.cancelled_amount =  X_Cancelled_Amount)
                OR (    (Recinfo.cancelled_amount IS NULL)
                    AND (X_Cancelled_Amount IS NULL)))
           AND (   (Recinfo.amount_applicable_to_discount =  X_Amt_Applicable_To_Discount)
                OR (    (Recinfo.amount_applicable_to_discount IS NULL)
                    AND (X_Amt_Applicable_To_Discount IS NULL)))
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 =  X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
           AND (   (Recinfo.creation_date =  X_Creation_Date)
                OR (    (Recinfo.creation_date IS NULL)
                    AND (X_Creation_Date IS NULL)))
           AND (   (Recinfo.created_by =  X_Created_By)
                OR (    (Recinfo.created_by IS NULL)
                    AND (X_Created_By IS NULL)))
           AND (   (Recinfo.pay_group_lookup_code =  X_Pay_Group_Lookup_Code)
                OR (    (Recinfo.pay_group_lookup_code IS NULL)
                    AND (X_Pay_Group_Lookup_Code IS NULL)))
           AND (   (Recinfo.pay_group_flag =  X_Pay_Group_Flag)
                OR (    (Recinfo.pay_group_flag IS NULL)
                    AND (X_Pay_Group_Flag IS NULL)))
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
             FND_MESSAGE.SET_TOKEN('PARAMETERS','CONSOLIDATED_INVOICE_ID = ' ||
                                   X_Consolidated_Invoice_Id);
             FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
	 END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

  END Lock_Row;


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

		       X_Consolidated_Invoice_Id         NUMBER,
 		       X_Vendor_Id                       NUMBER,
 		       X_Invoice_Num                     VARCHAR2,
		       X_Set_Of_Books_Id                 NUMBER,
		       X_Invoice_Currency_Code           VARCHAR2,
		       X_Invoice_Amount                  NUMBER DEFAULT NULL,
		       X_Vendor_Site_Id                  NUMBER DEFAULT NULL,
		       X_Invoice_Date                    DATE DEFAULT NULL,
		       X_Description                     VARCHAR2 DEFAULT NULL,
		       X_Terms_Id                        NUMBER DEFAULT NULL,
		       X_Terms_Date                      DATE DEFAULT NULL,
		       X_Cancelled_Date                  DATE DEFAULT NULL,
		       X_Cancelled_By                    NUMBER DEFAULT NULL,
		       X_Cancelled_Amount                NUMBER DEFAULT NULL,
		       X_Amt_Applicable_To_Discount   NUMBER DEFAULT NULL,
		       X_Attribute_Category              VARCHAR2 DEFAULT NULL,
		       X_Attribute1                      VARCHAR2 DEFAULT NULL,
		       X_Attribute2                      VARCHAR2 DEFAULT NULL,
		       X_Attribute3                      VARCHAR2 DEFAULT NULL,
		       X_Attribute4                      VARCHAR2 DEFAULT NULL,
		       X_Attribute5                      VARCHAR2 DEFAULT NULL,
		       X_Attribute6                      VARCHAR2 DEFAULT NULL,
		       X_Attribute7                      VARCHAR2 DEFAULT NULL,
		       X_Attribute8                      VARCHAR2 DEFAULT NULL,
		       X_Attribute9                      VARCHAR2 DEFAULT NULL,
		       X_Attribute10                     VARCHAR2 DEFAULT NULL,
		       X_Attribute11                     VARCHAR2 DEFAULT NULL,
		       X_Attribute12                     VARCHAR2 DEFAULT NULL,
		       X_Attribute13                     VARCHAR2 DEFAULT NULL,
		       X_Attribute14                     VARCHAR2 DEFAULT NULL,
		       X_Attribute15                     VARCHAR2 DEFAULT NULL,
		       X_Last_Update_Date                DATE,
		       X_Last_Updated_By                 NUMBER,
		       X_Creation_Date                   DATE DEFAULT NULL,
		       X_Created_By                      NUMBER DEFAULT NULL,
		       X_Last_Update_Login               NUMBER DEFAULT NULL,
		       X_Pay_Group_Lookup_Code           VARCHAR2 DEFAULT NULL,
		       X_Pay_Group_Flag                  VARCHAR2 DEFAULT NULL,
		       X_calling_sequence	IN	 VARCHAR2

  ) IS
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);
  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'JL_BR_AP_CONSOLID_INVOICES_PKG.UPDATE_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Update JL_BR_AP_CONSOLID_INVOICES';
    UPDATE JL_BR_AP_CONSOLID_INVOICES
    SET
       consolidated_invoice_id	       =     X_Consolidated_Invoice_Id,
       vendor_id                       =     X_Vendor_Id,
       invoice_num                     =     X_Invoice_Num,
       set_of_books_id                 =     X_Set_Of_Books_Id,
       invoice_currency_code           =     X_Invoice_Currency_Code,
       invoice_amount                  =     X_Invoice_Amount,
       vendor_site_id                  =     X_Vendor_Site_Id,
       invoice_date                    =     X_Invoice_Date,
       description                     =     X_Description,
       terms_id                        =     X_Terms_Id,
       terms_date                      =     X_Terms_Date,
       cancelled_date                  =     X_Cancelled_Date,
       cancelled_by                    =     X_Cancelled_By,
       cancelled_amount                =     X_Cancelled_Amount,
       amount_applicable_to_discount   =     X_Amt_Applicable_To_Discount,
       attribute_category              =     X_Attribute_Category,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       attribute11                     =     X_Attribute11,
       attribute12                     =     X_Attribute12,
       attribute13                     =     X_Attribute13,
       attribute14                     =     X_Attribute14,
       attribute15                     =     X_Attribute15,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       creation_date                   =     X_Creation_Date,
       created_by                      =     X_Created_by,
       last_update_login               =     X_Last_Update_Login,
       pay_group_lookup_code	       =     X_Pay_Group_Lookup_Code,
       pay_group_flag    	       =     X_Pay_Group_Flag

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
              FND_MESSAGE.SET_TOKEN('PARAMETERS','CONSOLIDATED_INVOICE_ID = ' ||
                                    X_Consolidated_Invoice_Id);
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
    current_calling_sequence := 'JL_BR_AP_CONSOLID_INVOICES_PKG.DELETE_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Delete from JL_BR_AP_CONSOLID_INVOICES';
    DELETE FROM JL_BR_AP_CONSOLID_INVOICES
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


END JL_BR_AP_CONSOLID_INVOICES_PKG;

/
