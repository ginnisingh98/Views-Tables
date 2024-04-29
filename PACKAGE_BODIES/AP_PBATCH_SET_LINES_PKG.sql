--------------------------------------------------------
--  DDL for Package Body AP_PBATCH_SET_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_PBATCH_SET_LINES_PKG" as
/* $Header: apbsetlb.pls 120.3 2003/09/25 22:34:58 pjena noship $ */
/* BUG 2124337 :Parameters X_attribute_category to X_attribute15 added */
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
	  X_attribute15			   VARCHAR2, /* BUG 2124337 */
          X_Vendor_Id                      NUMBER,
          X_days_between_check_cycles      NUMBER
  ) IS
    l_batch_set_line_id      NUMBER;
    CURSOR C IS SELECT rowid FROM ap_pbatch_set_lines
                 WHERE batch_name = X_Batch_Name
                 AND   batch_set_line_id = l_Batch_Set_Line_Id;
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

   BEGIN
    -- Update the calling sequence
    --
       current_calling_sequence :=
       'AP_PBATCH_SET_LINES_PKG.INSERT_ROW<-'||X_Calling_Sequence;

       -- Get next batch set line id
       debug_info := 'Get next Batch set line Id';

       --
       -- Bugfix 2146760: generate a new batch_set_line_id only
       -- if it is passed in as NULL
       --
       l_batch_set_line_id := X_Batch_Set_Line_Id;

       if (l_batch_set_line_id is NULL) then
         select ap_pbatch_set_lines_s.nextval
         into l_batch_set_line_id
         from sys.dual;
       end if;

       debug_info := 'Insert into ap_pbatch_set_lines';
       INSERT INTO ap_pbatch_set_lines (
              batch_name,
              batch_set_id,
              batch_set_line_id,
              include_in_set,
              printer,
              check_stock_id,
              ce_bank_acct_use_id,
              vendor_pay_group,
              hi_payment_priority,
              low_payment_priority,
              max_payment_amount,
              min_check_amount,
              max_outlay,
              pay_only_when_due_flag,
              payment_currency_code,
              exchange_rate_type,
              document_order_lookup_code,
              audit_required_flag,
              interval,
              volume_serial_number,
              zero_amounts_allowed,
              zero_invoices_allowed,
              future_pmts_allowed,
              transfer_priority,
              inactive_date,
              last_update_date,
              last_updated_by,
              last_update_login,
              creation_date,
              created_by,
              attribute_category,		   /* BUG 2124337 */
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
	      attribute15,			  /* BUG 2124337 */
              vendor_id,
              org_id,
              days_between_check_cycles
             ) VALUES (

              X_Batch_Name,
              X_Batch_Set_Id,
              l_Batch_Set_Line_Id,
              X_Include_In_Set,
              X_Printer,
              X_Check_Stock_Id,
              X_Ce_Bank_Acct_Use_Id,
              X_Vendor_Pay_Group,
              X_Hi_Payment_Priority,
              X_Low_Payment_Priority,
              X_Max_Payment_amount,
              X_Min_Check_Amount,
              X_Max_Outlay,
              X_Pay_Only_When_Due_Flag,
              X_Payment_Currency_Code,
              X_Exchange_Rate_Type,
              X_Document_Order_Lookup_Code,
              X_Audit_Required_Flag,
              X_Interval,
              X_Volume_Serial_Number,
              X_Zero_Amounts_Allowed,
              X_Zero_Invoices_Allowed,
              X_Future_Pmts_Allowed,
              X_Transfer_Priority,
              X_Inactive_Date,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Last_Update_Login,
              X_Creation_Date,
              X_Created_By,
              X_attribute_category,		   /* BUG 2124337 */
	      X_attribute1,
	      X_attribute2,
	      X_attribute3,
	      X_attribute4,
	      X_attribute5,
	      X_attribute6,
	      X_attribute7,
	      X_attribute8,
	      X_attribute9,
	      X_attribute10,
	      X_attribute11,
	      X_attribute12,
	      X_attribute13,
	      X_attribute14,
	      X_attribute15,			     /* BUG 2124337 */
              X_Vendor_Id,
              X_Org_Id,
              X_days_between_check_cycles
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
      if (SQLCODE <> -20001) then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Batch Name = '||X_Batch_Name
                               ||', Batch Set Line Id ='||l_Batch_Set_Line_Id
                               ||', ROWID = '||X_ROWID);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      end if;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;

/* BUG 2124337 :Parameters X_attribute_category to X_attribute15 added */
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
	      X_attribute_category	       VARCHAR2, /* BUG 2124337 */
	      X_attribute1		       VARCHAR2,
	      X_attribute2		       VARCHAR2,
	      X_attribute3		       VARCHAR2,
	      X_attribute4		       VARCHAR2,
	      X_attribute5		       VARCHAR2,
	      X_attribute6	               VARCHAR2,
	      X_attribute7		       VARCHAR2,
	      X_attribute8		       VARCHAR2,
	      X_attribute9	               VARCHAR2,
	      X_attribute10		       VARCHAR2,
	      X_attribute11		       VARCHAR2,
	      X_attribute12		       VARCHAR2,
	      X_attribute13		       VARCHAR2,
	      X_attribute14		       VARCHAR2,
	      X_attribute15		       VARCHAR2,  /* BUG 2124337 */
              X_Vendor_Id                      NUMBER,
              X_days_between_check_cycles      NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   ap_pbatch_set_lines
        WHERE  rowid = X_Rowid
        FOR UPDATE of Batch_Name NOWAIT;
    Recinfo C%ROWTYPE;
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);


  BEGIN
    -- Update the calling sequence
    --
    current_calling_sequence :=
     'AP_PBATCH_SET_LINES_PKG.LOCK_ROW<-'||X_Calling_Sequence;

    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      debug_info := 'Close cursor C -ROW NOTFOUND';
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    debug_info := 'Close cursor C';
    CLOSE C;
    if (

               (Recinfo.batch_name =  X_Batch_Name)
           AND (Recinfo.batch_set_id =  X_Batch_Set_Id)
           AND (Recinfo.batch_set_line_id =  X_Batch_Set_Line_Id)
           AND (   (Recinfo.include_in_set = X_Include_In_Set)
                OR (    (Recinfo.include_in_set IS NULL)
                    AND (X_Include_In_Set IS NULL)))
           AND (   (Recinfo.printer = X_Printer)
                OR (    (Recinfo.printer IS NULL)
                    AND (X_Printer IS NULL)))
          AND (   (Recinfo.check_stock_id = X_Check_Stock_Id)
                OR (    (Recinfo.check_stock_id IS NULL)
                    AND (X_Check_Stock_Id IS NULL)))
          AND (   (Recinfo.ce_bank_acct_use_id = X_Ce_Bank_Acct_Use_Id)
                OR (    (Recinfo.ce_bank_acct_use_id IS NULL)
                    AND (X_Ce_Bank_Acct_Use_Id IS NULL)))
           AND (   (Recinfo.vendor_pay_group = X_Vendor_Pay_Group)
                OR (    (Recinfo.vendor_pay_group IS NULL)
                    AND (X_Vendor_Pay_Group IS NULL)))
           AND (   (Recinfo.hi_payment_priority = X_Hi_Payment_Priority)
                OR (    (Recinfo.hi_payment_priority IS NULL)
                    AND (X_Hi_Payment_Priority IS NULL)))
           AND (   (Recinfo.low_payment_priority = X_Low_Payment_Priority)
                OR (    (Recinfo.low_payment_priority IS NULL)
                    AND (X_Low_Payment_Priority IS NULL)))
           AND (   (Recinfo.max_payment_amount = X_Max_Payment_Amount)
                OR (    (Recinfo.max_payment_amount IS NULL)
                    AND (X_Max_Payment_Amount IS NULL)))
           AND (   (Recinfo.min_check_amount = X_Min_Check_Amount)
                OR (    (Recinfo.min_check_amount IS NULL)
                    AND (X_Min_Check_Amount IS NULL)))
           AND (   (Recinfo.max_outlay = X_Max_Outlay)
                OR (    (Recinfo.max_outlay IS NULL)
                    AND (X_Max_Outlay IS NULL)))
           AND (   (Recinfo.pay_only_when_due_flag = X_Pay_Only_When_Due_flag)
                OR (    (Recinfo.pay_only_when_due_flag IS NULL)
                    AND (X_Pay_Only_When_Due_Flag IS NULL)))
           AND (Recinfo.payment_currency_code =  X_Currency_Code)
           AND (   (Recinfo.exchange_rate_type = X_Exchange_Rate_Type)
                OR (    (Recinfo.exchange_rate_type IS NULL)
                    AND (X_Exchange_Rate_Type IS NULL)))
           AND (   (Recinfo.document_order_lookup_code =
                         X_Document_Order_Lookup_Code)
                OR (    (Recinfo.document_order_lookup_code IS NULL)
                    AND (X_Document_Order_Lookup_Code IS NULL)))
           AND (   (Recinfo.audit_required_flag= X_Audit_Required_Flag)
                OR (    (Recinfo.audit_required_flag IS NULL)
                    AND (X_Audit_Required_Flag IS NULL)))
           AND (   (Recinfo.interval = X_Interval)
                OR (    (Recinfo.interval IS NULL)
                    AND (X_Interval IS NULL)))
           AND (   (Recinfo.volume_serial_number = X_Volume_Serial_Number)
                OR (    (Recinfo.volume_serial_number IS NULL)
                    AND (X_Volume_Serial_Number IS NULL)))
           AND (   (Recinfo.zero_amounts_allowed = X_Zero_Amounts_Allowed)
                OR (    (Recinfo.zero_amounts_allowed IS NULL)
                    AND (X_Zero_Amounts_Allowed IS NULL)))
           AND (   (Recinfo.zero_invoices_allowed = X_Zero_Invoices_Allowed)
                OR (    (Recinfo.zero_invoices_allowed IS NULL)
                    AND (X_Zero_Invoices_Allowed IS NULL)))
           AND (   (Recinfo.Future_Pmts_Allowed = X_Future_Pmts_Allowed)
                OR (    (Recinfo.Future_Pmts_Allowed IS NULL)
                    AND (X_Future_Pmts_Allowed IS NULL)))
           AND (   (Recinfo.transfer_priority = X_Transfer_Priority)
                OR (    (Recinfo.transfer_priority IS NULL)
                    AND (X_Transfer_Priority IS NULL)))
           AND (   (Recinfo.inactive_date = X_Inactive_Date)
                OR (    (Recinfo.inactive_date IS NULL)
                    AND (X_Inactive_Date IS NULL)))
           AND (   (Recinfo.attribute_category = X_attribute_category) /* Bug 2124337 */
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_attribute_category IS NULL)))
           AND (   (Recinfo.attribute1 = X_attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 = X_attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 = X_attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 = X_attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 = X_attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 = X_attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 = X_attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 = X_attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 = X_attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 = X_attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 = X_attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 = X_attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 = X_attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 = X_attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 = X_attribute15)      /* Bug 2124337 */
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_attribute15 IS NULL)))
           AND (   (Recinfo.vendor_id = X_Vendor_Id)
                OR (    (Recinfo.vendor_id IS NULL)
                    AND (X_Vendor_Id IS NULL)))
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
         FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
         FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
         FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
         FND_MESSAGE.SET_TOKEN('PARAMETERS','Batch Name = '||X_Batch_Name
                                        ||', ROWID = '||X_Rowid);
         FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
       END IF;
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END Lock_Row;
/* BUG 2124337 :Parameters X_attribute_category to X_attribute15 added */
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
            X_attribute_category	     VARCHAR2, /* BUG 2124337 */
	    X_attribute1		     VARCHAR2,
	    X_attribute2		     VARCHAR2,
	    X_attribute3		     VARCHAR2,
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
  ) IS
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);
  BEGIN
    -- Update the calling sequence
    --
    current_calling_sequence :=
     'AP_PBATCH_SET_LINES_PKG.UPDATE_ROW<-'||X_Calling_Sequence;


    debug_info := 'Update ap_pbatch_set_lines';
    UPDATE ap_pbatch_set_lines
    SET
       batch_name                      =     X_Batch_Name,
       batch_set_id                    =     X_Batch_Set_Id,
       batch_set_line_id               =     X_Batch_Set_Line_Id,
       include_in_set                  =     X_Include_in_Set,
       printer                         =     X_Printer,
       check_stock_id                  =     X_Check_Stock_Id,
       vendor_pay_group                =     X_Vendor_Pay_Group,
       hi_payment_priority             =     X_Hi_Payment_Priority,
       low_payment_priority            =     X_Low_Payment_Priority,
       max_payment_amount              =     X_Max_Payment_Amount,
       min_check_amount                =     X_Min_Check_Amount,
       max_outlay                      =     X_Max_Outlay,
       pay_only_when_due_flag          =     X_Pay_Only_When_Due_Flag,
       payment_currency_code           =     X_Payment_Currency_Code,
       exchange_rate_type              =     X_Exchange_Rate_Type,
       document_order_lookup_code      =     X_Document_Order_Lookup_Code,
       audit_required_flag             =     X_Audit_Required_Flag,
       interval                        =     X_Interval,
       volume_serial_number            =     X_Volume_Serial_Number,
       zero_amounts_allowed            =     X_Zero_Amounts_Allowed,
       zero_invoices_allowed           =     X_Zero_Invoices_Allowed,
       future_pmts_allowed             =     X_Future_Pmts_Allowed,
       ce_bank_acct_use_id             =     X_Ce_Bank_Acct_Use_Id,
       transfer_priority               =     X_transfer_priority,
       inactive_date                   =     X_Inactive_Date,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       attribute_category              =     X_attribute_category,	   /* BUG 2124337 */
       attribute1                      =     X_attribute1,
       attribute2                      =     X_attribute2,
       attribute3                      =     X_attribute3,
       attribute4                      =     X_attribute4,
       attribute5                      =     X_attribute5,
       attribute6                      =     X_attribute6,
       attribute7                      =     X_attribute7,
       attribute8                      =     X_attribute8,
       attribute9                      =     X_attribute9,
       attribute10                     =     X_attribute10,
       attribute11                     =     X_attribute11,
       attribute12                     =     X_attribute12,
       attribute13                     =     X_attribute13,
       attribute14                     =     X_attribute14,
       attribute15                     =     X_attribute15,		   /* BUG 2124337 */
       vendor_id                       =     X_Vendor_Id,
       days_between_check_cycles       =     X_days_between_check_cycles
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    EXCEPTION
     WHEN OTHERS THEN
      if (SQLCODE <> -20001) then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Batch Name = '||X_Batch_Name
                               ||', Batch Set Line Id ='||X_Batch_Set_Line_Id
                               ||', ROWID = '||X_Rowid);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      end if;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Update_Row;

/*
  PROCEDURE Delete_Row(X_Rowid 				VARCHAR2,
		       X_calling_sequence	IN	VARCHAR2) IS

    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    -- Update the calling sequence
    --
    current_calling_sequence :=
     'AP_PBATCH_SET_LINES_PKG.DELETE_ROW<-'||X_Calling_Sequence;

    debug_info := 'Delete from ap_pbatch_set_lines';
    DELETE FROM ap_pbatch_set_lines
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    EXCEPTION
     WHEN OTHERS THEN
      if (SQLCODE <> -20001) then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'ROWID = ' || X_Rowid);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      end if;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Delete_Row;
*/

  Procedure Check_Unique_Run(X_Batch_set_id		VARCHAR2,
                             X_Batch_Run_Name 		VARCHAR2,
                             X_Calling_Sequence   IN	VARCHAR2) IS
  dummy                    NUMBER;
  current_calling_sequence VARCHAR2(2000);
  debug_info               VARCHAR2(100);

  BEGIN
    -- Update the calling sequence
    --
    current_calling_sequence :=
     'AP_PBATCH_SET_LINES_PKG.CHECK_UNIQUE_RUN<-'||X_Calling_Sequence;

    debug_info := 'Count for batch run name';
    select count(1)
    into dummy
    from   ap_invoice_selection_criteria
    where batch_run_name = X_batch_run_name
    and batch_set_id = X_batch_set_id;

    if (dummy >= 1) then
      fnd_message.set_name('SQLAP','AP_ALL_DUPLICATE_VALUE');
      app_exception.raise_exception;
    end if;

    EXCEPTION
     WHEN OTHERS THEN
      if (SQLCODE <> -20001) then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Batch run Name = '||
                              X_Batch_run_Name ||', Batch_set_id = '
                              ||X_Batch_Set_Id);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      end if;
      APP_EXCEPTION.RAISE_EXCEPTION;

  end Check_Unique_Run;

  Procedure Check_Unique_Batch(X_Batch_Run_Name 	VARCHAR2,
                               X_Batch_Name		VARCHAR2,
                               X_Calling_Sequence   IN  VARCHAR2) IS
  dummy                    NUMBER;
  current_calling_sequence VARCHAR2(2000);
  debug_info               VARCHAR2(100);

  BEGIN
    -- Update the calling sequence
    --
    current_calling_sequence :=
     'AP_PBATCH_SET_LINES_PKG.CHECK_UNIQUE_BATCH<-'||X_Calling_Sequence;

    debug_info := 'Count for check run name';
    select count(1)
    into dummy
    from   ap_invoice_selection_criteria
    where checkrun_name = X_batch_name||X_batch_run_name;

     if (dummy >= 1) then
      fnd_message.set_name('SQLAP','AP_ALL_DUPLICATE_VALUE');
      app_exception.raise_exception;
    end if;

    EXCEPTION
     WHEN OTHERS THEN
      if (SQLCODE <> -20001) then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Batch run Name = '||
                              X_Batch_run_Name ); --**||', ROWID = '||X_Rowid);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      end if;
      APP_EXCEPTION.RAISE_EXCEPTION;

  end Check_Unique_Batch;

END AP_PBATCH_SET_LINES_PKG;

/
