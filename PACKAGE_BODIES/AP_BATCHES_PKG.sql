--------------------------------------------------------
--  DDL for Package Body AP_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_BATCHES_PKG" as
/* $Header: apibatcb.pls 120.3.12010000.2 2008/12/11 10:58:00 rseeta ship $ */


  -----------------------------------------------------------------------
  -- Function get_actual_inv_count returns the total number of invoices
  -- in the given batch.
  FUNCTION get_actual_inv_count(l_batch_id IN NUMBER)
      RETURN NUMBER
  IS
      invoice_count	NUMBER := 0;

  BEGIN

       SELECT COUNT(*)
       INTO   invoice_count
       --bug 7606664 changed ap_invoices to ap_invoices_all
       FROM   ap_invoices_all
       WHERE  batch_id = l_batch_id;

       RETURN(invoice_count);

  END get_actual_inv_count;


  -----------------------------------------------------------------------
  -- Function get_actual_inv_amount returns the total of all invoice amounts
  -- in the given batch.
  FUNCTION get_actual_inv_amount(l_batch_id IN NUMBER)
      RETURN NUMBER
  IS
      invoice_amount	NUMBER := 0;

  BEGIN

       SELECT SUM(nvl(invoice_amount,0))
       INTO   invoice_amount
       --bug 7606664 changed ap_invoices to ap_invoices_all
       FROM   ap_invoices_all
       WHERE  batch_id = l_batch_id;

       RETURN(invoice_amount);

  END get_actual_inv_amount;

PROCEDURE CHECK_UNIQUE (X_ROWID             	VARCHAR2,
                        X_BATCH_NAME        	VARCHAR2,
			X_calling_sequence  IN	VARCHAR2) IS
  dummy number;
  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(100);

begin
--Update the calling sequence
--
  current_calling_sequence := 'AP_BATCHES_PKG.CHECK_UNIQUE<-' ||
                               X_calling_sequence;

  debug_info := 'Count rows with this batch_name';
  select count(1)
  into   dummy
  from   ap_batches_all
  where  batch_name = X_BATCH_NAME
  and    ((X_ROWID is null) or (rowid <> X_ROWID));

  if (dummy >= 1) then
    fnd_message.set_name('SQLAP','AP_ALL_DUPLICATE_VALUE');
    app_exception.raise_exception;
  end if;

  EXCEPTION
       WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_ROWID ||
                        		', BATCH_NAME = ' || X_BATCH_NAME);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;


end CHECK_UNIQUE;



  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Batch_Id                       NUMBER,
                       X_Batch_Name                     VARCHAR2,
                       X_Batch_Date                     DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Control_Invoice_Count          NUMBER,
                       X_Control_Invoice_Total          NUMBER,
                       X_Invoice_Currency_Code          VARCHAR2,
                       X_Payment_Currency_Code          VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Pay_Group_Lookup_Code          VARCHAR2,
                       X_Payment_Priority               NUMBER,
                       X_Batch_Code_Combination_Id      NUMBER,
                       X_Terms_Id                       NUMBER,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
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
                       X_Invoice_Type_Lookup_Code       VARCHAR2,
                       X_Hold_Lookup_Code               VARCHAR2,
                       X_Hold_Reason                    VARCHAR2,
                       X_Doc_Category_Code              VARCHAR2,
                       X_Org_Id                         NUMBER,
		       X_calling_sequence	IN	VARCHAR2,
		       X_gl_date			DATE        -- **1
  ) IS
    CURSOR C IS SELECT rowid FROM AP_BATCHES_ALL
                 WHERE batch_id = X_Batch_Id;
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

   BEGIN
--Update the calling sequence
--
  current_calling_sequence := 'AP_BATCHES_PKG.INSERT_ROW<-' ||
                               X_calling_sequence;

  -- Check uniqueness first
  ap_batches_pkg.check_unique(X_ROWID,
                              X_BATCH_NAME,
			      X_calling_sequence => current_calling_sequence);

       debug_info := 'Insert into AP_BATCHES';
       INSERT INTO AP_BATCHES_ALL(
              batch_id,
              batch_name,
              batch_date,
              last_update_date,
              last_updated_by,
              control_invoice_count,
              control_invoice_total,
              invoice_currency_code,
              payment_currency_code,
              last_update_login,
              creation_date,
              created_by,
              pay_group_lookup_code,
              payment_priority,
              batch_code_combination_id,
              terms_id,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute_category,
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
              invoice_type_lookup_code,
              hold_lookup_code,
              hold_reason,
              doc_category_code,
	      gl_date,					 -- **1
              org_id
              ) VALUES (
              X_Batch_Id,
              X_Batch_Name,
              X_Batch_Date,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Control_Invoice_Count,
              X_Control_Invoice_Total,
              X_Invoice_Currency_Code,
              X_Payment_Currency_Code,
              X_Last_Update_Login,
              X_Creation_Date,
              X_Created_By,
              X_Pay_Group_Lookup_Code,
              X_Payment_Priority,
              X_Batch_Code_Combination_Id,
              X_Terms_Id,
              X_Attribute1,
              X_Attribute2,
              X_Attribute3,
              X_Attribute4,
              X_Attribute_Category,
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
              X_Invoice_Type_Lookup_Code,
              X_Hold_Lookup_Code,
              X_Hold_Reason,
              X_Doc_Category_Code,
	      X_gl_date,					 -- **1
              X_org_id
             );

    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      debug_info := 'Close cursor C - ROW NOTFOUND';
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
              FND_MESSAGE.SET_TOKEN('PARAMETERS','BATCH_ID = ' || TO_CHAR(X_Batch_Id) ||
						', ROWID = ' || X_Rowid);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Batch_Id                         NUMBER,
                     X_Batch_Name                       VARCHAR2,
                     X_Batch_Date                       DATE,
                     X_Control_Invoice_Count            NUMBER,
                     X_Control_Invoice_Total            NUMBER,
                     X_Invoice_Currency_Code            VARCHAR2,
                     X_Payment_Currency_Code            VARCHAR2,
                     X_Pay_Group_Lookup_Code            VARCHAR2,
                     X_Payment_Priority                 NUMBER,
                     X_Batch_Code_Combination_Id        NUMBER,
                     X_Terms_Id                         NUMBER,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Invoice_Type_Lookup_Code         VARCHAR2,
                     X_Hold_Lookup_Code                 VARCHAR2,
                     X_Hold_Reason                      VARCHAR2,
                     X_Doc_Category_Code                VARCHAR2,
                     X_Org_Id                           NUMBER,
		     X_calling_sequence		IN	VARCHAR2,
		     X_gl_date				DATE		 -- **1
  ) IS
    CURSOR C IS
        SELECT *
        FROM   AP_BATCHES_ALL
        WHERE  rowid = X_Rowid
        FOR UPDATE of Batch_Id NOWAIT;
    Recinfo C%ROWTYPE;
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);


  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'AP_BATCHES_PKG.LOCK_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      debug_info := 'Close cursor C - ROW NOTFOUND';
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    debug_info := 'Close cursor C';
    CLOSE C;
    if (

               (Recinfo.batch_id =  X_Batch_Id)
           AND (Recinfo.batch_name =  X_Batch_Name)
           AND (Recinfo.batch_date =  X_Batch_Date)
           AND (   (Recinfo.control_invoice_count =  X_Control_Invoice_Count)
                OR (    (Recinfo.control_invoice_count IS NULL)
                    AND (X_Control_Invoice_Count IS NULL)))
           AND (   (Recinfo.control_invoice_total =  X_Control_Invoice_Total)
                OR (    (Recinfo.control_invoice_total IS NULL)
                    AND (X_Control_Invoice_Total IS NULL)))
           AND (   (Recinfo.invoice_currency_code =  X_Invoice_Currency_Code)
                OR (    (Recinfo.invoice_currency_code IS NULL)
                    AND (X_Invoice_Currency_Code IS NULL)))
           AND (   (Recinfo.payment_currency_code =  X_Payment_Currency_Code)
                OR (    (Recinfo.payment_currency_code IS NULL)
                    AND (X_Payment_Currency_Code IS NULL)))
           AND (   (Recinfo.pay_group_lookup_code =  X_Pay_Group_Lookup_Code)
                OR (    (Recinfo.pay_group_lookup_code IS NULL)
                    AND (X_Pay_Group_Lookup_Code IS NULL)))
           AND (   (Recinfo.payment_priority =  X_Payment_Priority)
                OR (    (Recinfo.payment_priority IS NULL)
                    AND (X_Payment_Priority IS NULL)))
           AND (   (Recinfo.batch_code_combination_id =  X_Batch_Code_Combination_Id)
                OR (    (Recinfo.batch_code_combination_id IS NULL)
                    AND (X_Batch_Code_Combination_Id IS NULL)))
           AND (   (Recinfo.terms_id =  X_Terms_Id)
                OR (    (Recinfo.terms_id IS NULL)
                    AND (X_Terms_Id IS NULL)))
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
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
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
           AND (   (Recinfo.invoice_type_lookup_code =  X_Invoice_Type_Lookup_Code)
                OR (    (Recinfo.invoice_type_lookup_code IS NULL)
                    AND (X_Invoice_Type_Lookup_Code IS NULL)))
           AND (   (Recinfo.hold_lookup_code =  X_Hold_Lookup_Code)
                OR (    (Recinfo.hold_lookup_code IS NULL)
                    AND (X_Hold_Lookup_Code IS NULL)))
           AND (   (Recinfo.hold_reason =  X_Hold_Reason)
                OR (    (Recinfo.hold_reason IS NULL)
                    AND (X_Hold_Reason IS NULL)))
           AND (   (Recinfo.doc_category_code =  X_Doc_Category_Code)
                OR (    (Recinfo.doc_category_code IS NULL)
                    AND (X_Doc_Category_Code IS NULL)))
	   AND (   (Recinfo.gl_date =  X_gl_date)             	-- **1
                OR (    (Recinfo.gl_date IS NULL)
                    AND (X_gl_date IS NULL)))
           AND (   (Recinfo.org_id =  X_org_id)               -- **1
                OR (    (Recinfo.org_id IS NULL)
                    AND (X_org_id IS NULL)))
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
                    			', BATCH_ID = ' || TO_CHAR(X_Batch_Id));
             FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Batch_Id                       NUMBER,
                       X_Batch_Name                     VARCHAR2,
                       X_Batch_Date                     DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Control_Invoice_Count          NUMBER,
                       X_Control_Invoice_Total          NUMBER,
                       X_Invoice_Currency_Code          VARCHAR2,
                       X_Payment_Currency_Code          VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Pay_Group_Lookup_Code          VARCHAR2,
                       X_Payment_Priority               NUMBER,
                       X_Batch_Code_Combination_Id      NUMBER,
                       X_Terms_Id                       NUMBER,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
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
                       X_Invoice_Type_Lookup_Code       VARCHAR2,
                       X_Hold_Lookup_Code               VARCHAR2,
                       X_Hold_Reason                    VARCHAR2,
                       X_Doc_Category_Code              VARCHAR2,
                       X_Org_Id                         NUMBER,
		       X_calling_sequence	IN	VARCHAR2,
		       X_gl_date			DATE		-- **1

  ) IS
  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(100);
  BEGIN
    --Update the calling sequence
    --
    current_calling_sequence := 'AP_BATCHES_PKG.UPDATE_ROW<-' ||
                                 X_calling_sequence;

    -- Check uniqueness first
    ap_batches_pkg.check_unique(X_ROWID,
                                X_BATCH_NAME,
				X_calling_sequence => current_calling_sequence);

    debug_info := 'Update AP_BATCHES_ALL';
    UPDATE AP_BATCHES_ALL
    SET
       batch_id                        =     X_Batch_Id,
       batch_name                      =     X_Batch_Name,
       batch_date                      =     X_Batch_Date,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       control_invoice_count           =     X_Control_Invoice_Count,
       control_invoice_total           =     X_Control_Invoice_Total,
       invoice_currency_code           =     X_Invoice_Currency_Code,
       payment_currency_code           =     X_Payment_Currency_Code,
       last_update_login               =     X_Last_Update_Login,
       pay_group_lookup_code           =     X_Pay_Group_Lookup_Code,
       payment_priority                =     X_Payment_Priority,
       batch_code_combination_id       =     X_Batch_Code_Combination_Id,
       terms_id                        =     X_Terms_Id,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute_category              =     X_Attribute_Category,
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
       invoice_type_lookup_code        =     X_Invoice_Type_Lookup_Code,
       hold_lookup_code                =     X_Hold_Lookup_Code,
       hold_reason                     =     X_Hold_Reason,
       doc_category_code               =     X_Doc_Category_Code,
       gl_date			       =     X_gl_date,              -- **1
       org_id                          =     X_org_id
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
                       			', BATCH_ID = ' || TO_CHAR(X_Batch_Id));
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid 				VARCHAR2,
		       X_calling_sequence	IN	VARCHAR2) IS
  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(100);
  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'AP_BATCHES_PKG.DELETE_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Delete from AP_BATCHES';
    DELETE FROM AP_BATCHES_ALL
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
              FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_Rowid );
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Delete_Row;


END AP_BATCHES_PKG;

/
