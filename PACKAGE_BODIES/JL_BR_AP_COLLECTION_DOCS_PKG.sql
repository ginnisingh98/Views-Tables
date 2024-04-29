--------------------------------------------------------
--  DDL for Package Body JL_BR_AP_COLLECTION_DOCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AP_COLLECTION_DOCS_PKG" as
/* $Header: jlbrpecb.pls 120.4.12010000.2 2009/11/19 16:05:14 gmeni ship $ */

PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,

                       X_BANK_COLLECTION_ID             NUMBER,
                       X_LAST_UPDATED_BY                NUMBER,
                       X_LAST_UPDATE_DATE               DATE,
                       X_CREATED_BY                     NUMBER,
                       X_CREATION_DATE                  DATE,
                       X_LAST_UPDATE_LOGIN              NUMBER,
                       X_INVOICE_ID                     NUMBER DEFAULT NULL,
                       X_PAYMENT_NUM                    NUMBER DEFAULT NULL,
                       X_HOLD_FLAG                      VARCHAR2 DEFAULT NULL,
                       X_ISSUE_DATE                     DATE DEFAULT NULL,
                       X_DOCUMENT_NUMBER                VARCHAR2 DEFAULT NULL,
                       X_DRAWER_GUARANTOR               VARCHAR2 DEFAULT NULL,
                       X_INSTRUCTION_1                  VARCHAR2 DEFAULT NULL,
                       X_INSTRUCTION_2                  VARCHAR2 DEFAULT NULL,
                       X_CURRENCY_CODE                  VARCHAR2,
                       X_DUE_DATE                       DATE DEFAULT NULL,
                       X_AMOUNT                         NUMBER DEFAULT NULL,
                       X_DISCOUNT_DATE                  DATE DEFAULT NULL,
                       X_DISCOUNT_AMOUNT                NUMBER DEFAULT NULL,
                       X_ARREARS_DATE                   DATE DEFAULT NULL,
                       X_ARREARS_CODE                   VARCHAR2 DEFAULT NULL,
                       X_ARREARS_INTEREST               NUMBER DEFAULT NULL,
                       X_ABATE_AMOUNT                   NUMBER DEFAULT NULL,
                       X_PAID_AMOUNT                    NUMBER DEFAULT NULL,
                       X_PAYMENT_LOCATION               VARCHAR2 DEFAULT NULL,
                       X_DOCUMENT_TYPE                  VARCHAR2 DEFAULT NULL,
                       X_ACCEPTANCE                     VARCHAR2 DEFAULT NULL,
                       X_PROCESSING_DATE                DATE DEFAULT NULL,
                       X_BANK_USE                       VARCHAR2 DEFAULT NULL,
                       X_PORTFOLIO                      VARCHAR2 DEFAULT NULL,
                       X_PENALTY_FEE_AMOUNT             NUMBER DEFAULT NULL,
                       X_PENALTY_FEE_DATE               DATE DEFAULT NULL,
                       X_OTHER_ACCRETIONS               NUMBER DEFAULT NULL,
                       X_OUR_NUMBER                     VARCHAR2 DEFAULT NULL,
                       X_TRANSFEROR_CODE                VARCHAR2 DEFAULT NULL,
                       X_VENDOR_SITE_ID                 NUMBER,
                       X_FILE_CONTROL                   VARCHAR2 DEFAULT NULL,
                       X_STATUS_LOOKUP_CODE             VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE_CATEGORY             VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE1                     VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE2                     VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE3                     VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE4                     VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE5                     VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE6                     VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE7                     VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE8                     VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE9                     VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE10                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE11                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE12                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE13                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE14                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE15                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE16                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE17                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE18                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE19                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE20                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE21                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE22                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE23                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE24                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE25                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE26                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE27                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE28                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE29                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE30                    VARCHAR2 DEFAULT NULL,
                       X_ENTRY_SEQUENTIAL_NUMBER        NUMBER DEFAULT NULL,
                       X_SET_OF_BOOKS_ID                NUMBER,
                       X_VENDOR_ID                      NUMBER,
                       X_BANK_BRANCH_ID                 NUMBER,
                       X_BANK_PARTY_ID                  NUMBER,
                       X_BRANCH_PARTY_ID                NUMBER,
                       X_ORG_ID                         NUMBER DEFAULT NULL,
               	       X_calling_sequence		             VARCHAR2,
                       X_BARCODE		                      VARCHAR2 DEFAULT NULL,
                       X_ELECTRONIC_FORMAT_FLAG 		      VARCHAR2 DEFAULT NULL
  ) IS
    CURSOR C IS SELECT rowid FROM JL_BR_AP_COLLECTION_DOCS
                 WHERE bank_collection_id = X_bank_collection_id;
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

   BEGIN
--     Update the calling sequence
--
       current_calling_sequence := 'JL_BR_AP_COLLECTION_DOCS_PKG.INSERT_ROW<-' ||
                                    X_calling_sequence;

       debug_info := 'Insert into JL_BR_AP_COLLECTION_DOCS';
       INSERT INTO JL_BR_AP_COLLECTION_DOCS
              (
		BANK_COLLECTION_ID,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_LOGIN,
		INVOICE_ID,
		PAYMENT_NUM,
		HOLD_FLAG,
		ISSUE_DATE,
		DOCUMENT_NUMBER,
		DRAWER_GUARANTOR,
		INSTRUCTION_1,
		INSTRUCTION_2,
		CURRENCY_CODE,
		DUE_DATE,
		AMOUNT,
		DISCOUNT_DATE,
		DISCOUNT_AMOUNT,
		ARREARS_DATE,
		ARREARS_CODE,
		ARREARS_INTEREST,
		ABATE_AMOUNT,
		PAID_AMOUNT,
		PAYMENT_LOCATION,
		DOCUMENT_TYPE,
		ACCEPTANCE,
		PROCESSING_DATE,
		BANK_USE,
		PORTFOLIO,
		PENALTY_FEE_AMOUNT,
		PENALTY_FEE_DATE,
		OTHER_ACCRETIONS,
		OUR_NUMBER,
		TRANSFEROR_CODE,
		VENDOR_SITE_ID,
		FILE_CONTROL,
		STATUS_LOOKUP_CODE,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		ATTRIBUTE16,
		ATTRIBUTE17,
		ATTRIBUTE18,
		ATTRIBUTE19,
		ATTRIBUTE20,
		ATTRIBUTE21,
		ATTRIBUTE22,
		ATTRIBUTE23,
		ATTRIBUTE24,
		ATTRIBUTE25,
		ATTRIBUTE26,
		ATTRIBUTE27,
		ATTRIBUTE28,
		ATTRIBUTE29,
		ATTRIBUTE30,
		ENTRY_SEQUENTIAL_NUMBER,
		SET_OF_BOOKS_ID,
		VENDOR_ID,
		BANK_BRANCH_ID,
		BANK_PARTY_ID,
		BRANCH_PARTY_ID,
  ORG_ID,
  BARCODE,
  ELECTRONIC_FORMAT_FLAG
              )
       VALUES (
		X_BANK_COLLECTION_ID,
		X_LAST_UPDATED_BY,
		X_LAST_UPDATE_DATE,
		X_CREATED_BY,
		X_CREATION_DATE,
		X_LAST_UPDATE_LOGIN,
		X_INVOICE_ID,
		X_PAYMENT_NUM,
		X_HOLD_FLAG,
		X_ISSUE_DATE,
		X_DOCUMENT_NUMBER,
		X_DRAWER_GUARANTOR,
		X_INSTRUCTION_1,
		X_INSTRUCTION_2,
		X_CURRENCY_CODE,
		X_DUE_DATE,
		X_AMOUNT,
		X_DISCOUNT_DATE,
		X_DISCOUNT_AMOUNT,
		X_ARREARS_DATE,
		X_ARREARS_CODE,
		X_ARREARS_INTEREST,
		X_ABATE_AMOUNT,
		X_PAID_AMOUNT,
		X_PAYMENT_LOCATION,
		X_DOCUMENT_TYPE,
		X_ACCEPTANCE,
		X_PROCESSING_DATE,
		X_BANK_USE,
		X_PORTFOLIO,
		X_PENALTY_FEE_AMOUNT,
		X_PENALTY_FEE_DATE,
		X_OTHER_ACCRETIONS,
		X_OUR_NUMBER,
		X_TRANSFEROR_CODE,
		X_VENDOR_SITE_ID,
		X_FILE_CONTROL,
		X_STATUS_LOOKUP_CODE,
		X_ATTRIBUTE_CATEGORY,
		X_ATTRIBUTE1,
		X_ATTRIBUTE2,
		X_ATTRIBUTE3,
		X_ATTRIBUTE4,
		X_ATTRIBUTE5,
		X_ATTRIBUTE6,
		X_ATTRIBUTE7,
		X_ATTRIBUTE8,
		X_ATTRIBUTE9,
		X_ATTRIBUTE10,
		X_ATTRIBUTE11,
		X_ATTRIBUTE12,
		X_ATTRIBUTE13,
		X_ATTRIBUTE14,
		X_ATTRIBUTE15,
		X_ATTRIBUTE16,
		X_ATTRIBUTE17,
		X_ATTRIBUTE18,
		X_ATTRIBUTE19,
		X_ATTRIBUTE20,
		X_ATTRIBUTE21,
		X_ATTRIBUTE22,
		X_ATTRIBUTE23,
		X_ATTRIBUTE24,
		X_ATTRIBUTE25,
		X_ATTRIBUTE26,
		X_ATTRIBUTE27,
		X_ATTRIBUTE28,
		X_ATTRIBUTE29,
		X_ATTRIBUTE30,
		X_ENTRY_SEQUENTIAL_NUMBER,
		X_SET_OF_BOOKS_ID,
		X_VENDOR_ID,
		X_BANK_BRANCH_ID,
		X_BANK_PARTY_ID,
		X_BRANCH_PARTY_ID,
  X_ORG_ID,
  X_BARCODE,
  X_ELECTRONIC_FORMAT_FLAG
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
              FND_MESSAGE.SET_TOKEN('PARAMETERS','bank_collection_id = ' ||
                                    X_bank_collection_id);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;


  PROCEDURE Lock_Row(  X_Rowid                          VARCHAR2,

                       X_BANK_COLLECTION_ID             NUMBER,
                       X_LAST_UPDATED_BY                NUMBER,
                       X_LAST_UPDATE_DATE               DATE,
                       X_CREATED_BY                     NUMBER,
                       X_CREATION_DATE                  DATE,
                       X_LAST_UPDATE_LOGIN              NUMBER,
                       X_INVOICE_ID                     NUMBER DEFAULT NULL,
                       X_PAYMENT_NUM                    NUMBER DEFAULT NULL,
                       X_HOLD_FLAG                      VARCHAR2 DEFAULT NULL,
                       X_ISSUE_DATE                     DATE DEFAULT NULL,
                       X_DOCUMENT_NUMBER                VARCHAR2 DEFAULT NULL,
                       X_DRAWER_GUARANTOR               VARCHAR2 DEFAULT NULL,
                       X_INSTRUCTION_1                  VARCHAR2 DEFAULT NULL,
                       X_INSTRUCTION_2                  VARCHAR2 DEFAULT NULL,
                       X_CURRENCY_CODE                  VARCHAR2,
                       X_DUE_DATE                       DATE DEFAULT NULL,
                       X_AMOUNT                         NUMBER DEFAULT NULL,
                       X_DISCOUNT_DATE                  DATE DEFAULT NULL,
                       X_DISCOUNT_AMOUNT                NUMBER DEFAULT NULL,
                       X_ARREARS_DATE                   DATE DEFAULT NULL,
                       X_ARREARS_CODE                   VARCHAR2 DEFAULT NULL,
                       X_ARREARS_INTEREST               NUMBER DEFAULT NULL,
                       X_ABATE_AMOUNT                   NUMBER DEFAULT NULL,
                       X_PAID_AMOUNT                    NUMBER DEFAULT NULL,
                       X_PAYMENT_LOCATION               VARCHAR2 DEFAULT NULL,
                       X_DOCUMENT_TYPE                  VARCHAR2 DEFAULT NULL,
                       X_ACCEPTANCE                     VARCHAR2 DEFAULT NULL,
                       X_PROCESSING_DATE                DATE DEFAULT NULL,
                       X_BANK_USE                       VARCHAR2 DEFAULT NULL,
                       X_PORTFOLIO                      VARCHAR2 DEFAULT NULL,
                       X_PENALTY_FEE_AMOUNT             NUMBER DEFAULT NULL,
                       X_PENALTY_FEE_DATE               DATE DEFAULT NULL,
                       X_OTHER_ACCRETIONS               NUMBER DEFAULT NULL,
                       X_OUR_NUMBER                     VARCHAR2 DEFAULT NULL,
                       X_TRANSFEROR_CODE                VARCHAR2 DEFAULT NULL,
                       X_VENDOR_SITE_ID                 NUMBER,
                       X_FILE_CONTROL                   VARCHAR2 DEFAULT NULL,
                       X_STATUS_LOOKUP_CODE             VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE_CATEGORY             VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE1                     VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE2                     VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE3                     VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE4                     VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE5                     VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE6                     VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE7                     VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE8                     VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE9                     VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE10                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE11                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE12                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE13                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE14                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE15                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE16                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE17                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE18                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE19                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE20                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE21                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE22                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE23                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE24                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE25                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE26                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE27                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE28                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE29                    VARCHAR2 DEFAULT NULL,
                       X_ATTRIBUTE30                    VARCHAR2 DEFAULT NULL,
                       X_ENTRY_SEQUENTIAL_NUMBER        NUMBER DEFAULT NULL,
                       X_SET_OF_BOOKS_ID                NUMBER,
                       X_VENDOR_ID                      NUMBER,
                       X_BANK_BRANCH_ID                 NUMBER,
                       X_BANK_PARTY_ID                  NUMBER,
                       X_BRANCH_PARTY_ID                NUMBER,
               	       X_calling_sequence		             VARCHAR2,
                       X_BARCODE		                      VARCHAR2 DEFAULT NULL,
                       X_ELECTRONIC_FORMAT_FLAG 		      VARCHAR2 DEFAULT NULL
  ) IS
    CURSOR C IS
        SELECT *
        FROM   JL_BR_AP_COLLECTION_DOCS
        WHERE  rowid = X_Rowid
        FOR UPDATE of bank_collection_id NOWAIT;
    Recinfo C%ROWTYPE;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'JL_BR_AP_COLLECTION_DOCS_PKG.LOCK_ROW<-' ||
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
           (Recinfo.bank_collection_id =  X_bank_collection_id)
           AND (   (Recinfo.invoice_id =  X_invoice_id)
                OR (    (Recinfo.invoice_id IS NULL)
                    AND (X_invoice_id IS NULL)))
           AND (   (Recinfo.payment_num =  X_payment_num)
                OR (    (Recinfo.payment_num IS NULL)
                    AND (X_payment_num IS NULL)))
           AND (   (Recinfo.hold_flag =  X_hold_flag)
                OR (    (Recinfo.hold_flag IS NULL)
                    AND (X_hold_flag IS NULL)))
           AND (   (Recinfo.issue_date =  X_issue_date)
                OR (    (Recinfo.issue_date IS NULL)
                    AND (X_issue_date IS NULL)))
           AND (   (Recinfo.DOCUMENT_NUMBER =  X_DOCUMENT_NUMBER)
                OR (    (Recinfo.DOCUMENT_NUMBER IS NULL)
                    AND (X_DOCUMENT_NUMBER IS NULL)))
           AND (   (Recinfo.DRAWER_GUARANTOR =  X_DRAWER_GUARANTOR)
                OR (    (Recinfo.DRAWER_GUARANTOR IS NULL)
                    AND (X_DRAWER_GUARANTOR IS NULL)))
           AND (   (Recinfo.INSTRUCTION_1 =  X_INSTRUCTION_1)
                OR (    (Recinfo.INSTRUCTION_1 IS NULL)
                    AND (X_INSTRUCTION_1 IS NULL)))
           AND (   (Recinfo.INSTRUCTION_2 =  X_INSTRUCTION_2)
                OR (    (Recinfo.INSTRUCTION_2 IS NULL)
                    AND (X_INSTRUCTION_2 IS NULL)))
           AND (Recinfo.CURRENCY_CODE =  X_CURRENCY_CODE)
           AND (   (Recinfo.DUE_DATE =  X_DUE_DATE)
                OR (    (Recinfo.DUE_DATE IS NULL)
                    AND (X_DUE_DATE IS NULL)))
           AND (   (Recinfo.AMOUNT =  X_AMOUNT)
                OR (    (Recinfo.AMOUNT IS NULL)
                    AND (X_AMOUNT IS NULL)))
           AND (   (Recinfo.DISCOUNT_DATE =  X_DISCOUNT_DATE)
                OR (    (Recinfo.DISCOUNT_DATE IS NULL)
                    AND (X_DISCOUNT_DATE IS NULL)))
           AND (   (Recinfo.DISCOUNT_AMOUNT =  X_DISCOUNT_AMOUNT)
                OR (    (Recinfo.DISCOUNT_AMOUNT IS NULL)
                    AND (X_DISCOUNT_AMOUNT IS NULL)))
           AND (   (Recinfo.ARREARS_DATE =  X_ARREARS_DATE)
                OR (    (Recinfo.ARREARS_DATE IS NULL)
                    AND (X_ARREARS_DATE IS NULL)))
           AND (   (Recinfo.ARREARS_CODE =  X_ARREARS_CODE)
                OR (    (Recinfo.ARREARS_CODE IS NULL)
                    AND (X_ARREARS_CODE IS NULL)))
           AND (   (Recinfo.ARREARS_INTEREST =  X_ARREARS_INTEREST)
                OR (    (Recinfo.ARREARS_INTEREST IS NULL)
                    AND (X_ARREARS_INTEREST IS NULL)))
           AND (   (Recinfo.ABATE_AMOUNT =  X_ABATE_AMOUNT)
                OR (    (Recinfo.ABATE_AMOUNT IS NULL)
                    AND (X_ABATE_AMOUNT IS NULL)))
           AND (   (Recinfo.PAID_AMOUNT =  X_PAID_AMOUNT)
                OR (    (Recinfo.PAID_AMOUNT IS NULL)
                    AND (X_PAID_AMOUNT IS NULL)))
           AND (   (Recinfo.PAYMENT_LOCATION =  X_PAYMENT_LOCATION)
                OR (    (Recinfo.PAYMENT_LOCATION IS NULL)
                    AND (X_PAYMENT_LOCATION IS NULL)))
           AND (   (Recinfo.DOCUMENT_TYPE =  X_DOCUMENT_TYPE)
                OR (    (Recinfo.DOCUMENT_TYPE IS NULL)
                    AND (X_DOCUMENT_TYPE IS NULL)))
           AND (   (Recinfo.ACCEPTANCE =  X_ACCEPTANCE)
                OR (    (Recinfo.ACCEPTANCE IS NULL)
                    AND (X_ACCEPTANCE IS NULL)))
           AND (   (Recinfo.PROCESSING_DATE =  X_PROCESSING_DATE)
                OR (    (Recinfo.PROCESSING_DATE IS NULL)
                    AND (X_PROCESSING_DATE IS NULL)))
           AND (   (Recinfo.BANK_USE =  X_BANK_USE)
                OR (    (Recinfo.BANK_USE IS NULL)
                    AND (X_BANK_USE IS NULL)))
           AND (   (Recinfo.PORTFOLIO =  X_PORTFOLIO)
                OR (    (Recinfo.PORTFOLIO IS NULL)
                    AND (X_PORTFOLIO IS NULL)))
           AND (   (Recinfo.PENALTY_FEE_AMOUNT =  X_PENALTY_FEE_AMOUNT)
                OR (    (Recinfo.PENALTY_FEE_AMOUNT IS NULL)
                    AND (X_PENALTY_FEE_AMOUNT IS NULL)))
           AND (   (Recinfo.PENALTY_FEE_DATE =  X_PENALTY_FEE_DATE)
                OR (    (Recinfo.PENALTY_FEE_DATE IS NULL)
                    AND (X_PENALTY_FEE_DATE IS NULL)))
           AND (   (Recinfo.OTHER_ACCRETIONS =  X_OTHER_ACCRETIONS)
                OR (    (Recinfo.OTHER_ACCRETIONS IS NULL)
                    AND (X_OTHER_ACCRETIONS IS NULL)))
           AND (   (Recinfo.OUR_NUMBER =  X_OUR_NUMBER)
                OR (    (Recinfo.OUR_NUMBER IS NULL)
                    AND (X_OUR_NUMBER IS NULL)))
           AND (   (Recinfo.TRANSFEROR_CODE =  X_TRANSFEROR_CODE)
                OR (    (Recinfo.TRANSFEROR_CODE IS NULL)
                    AND (X_TRANSFEROR_CODE IS NULL)))
           AND (Recinfo.VENDOR_SITE_ID =  X_VENDOR_SITE_ID)
           AND (   (Recinfo.FILE_CONTROL =  X_FILE_CONTROL)
                OR (    (Recinfo.FILE_CONTROL IS NULL)
                    AND (X_FILE_CONTROL IS NULL)))
           AND (   (Recinfo.STATUS_LOOKUP_CODE =  X_STATUS_LOOKUP_CODE)
                OR (    (Recinfo.STATUS_LOOKUP_CODE IS NULL)
                    AND (X_STATUS_LOOKUP_CODE IS NULL)))
           AND (   (Recinfo.ATTRIBUTE_CATEGORY =  X_ATTRIBUTE_CATEGORY)
                OR (    (Recinfo.ATTRIBUTE_CATEGORY IS NULL)
                    AND (X_ATTRIBUTE_CATEGORY IS NULL)))
           AND (   (Recinfo.ATTRIBUTE1 =  X_ATTRIBUTE1)
                OR (    (Recinfo.ATTRIBUTE1 IS NULL)
                    AND (X_ATTRIBUTE1 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE2 =  X_ATTRIBUTE2)
                OR (    (Recinfo.ATTRIBUTE2 IS NULL)
                    AND (X_ATTRIBUTE2 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE3 =  X_ATTRIBUTE3)
                OR (    (Recinfo.ATTRIBUTE3 IS NULL)
                    AND (X_ATTRIBUTE3 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE4 =  X_ATTRIBUTE4)
                OR (    (Recinfo.ATTRIBUTE4 IS NULL)
                    AND (X_ATTRIBUTE4 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE5 =  X_ATTRIBUTE5)
                OR (    (Recinfo.ATTRIBUTE5 IS NULL)
                    AND (X_ATTRIBUTE5 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE6 =  X_ATTRIBUTE6)
                OR (    (Recinfo.ATTRIBUTE6 IS NULL)
                    AND (X_ATTRIBUTE6 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE7 =  X_ATTRIBUTE7)
                OR (    (Recinfo.ATTRIBUTE7 IS NULL)
                    AND (X_ATTRIBUTE7 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE8 =  X_ATTRIBUTE8)
                OR (    (Recinfo.ATTRIBUTE8 IS NULL)
                    AND (X_ATTRIBUTE8 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE9 =  X_ATTRIBUTE9)
                OR (    (Recinfo.ATTRIBUTE9 IS NULL)
                    AND (X_ATTRIBUTE9 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE10 =  X_ATTRIBUTE10)
                OR (    (Recinfo.ATTRIBUTE10 IS NULL)
                    AND (X_ATTRIBUTE10 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE11 =  X_ATTRIBUTE11)
                OR (    (Recinfo.ATTRIBUTE11 IS NULL)
                    AND (X_ATTRIBUTE11 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE12 =  X_ATTRIBUTE12)
                OR (    (Recinfo.ATTRIBUTE12 IS NULL)
                    AND (X_ATTRIBUTE12 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE13 =  X_ATTRIBUTE13)
                OR (    (Recinfo.ATTRIBUTE13 IS NULL)
                    AND (X_ATTRIBUTE13 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE14 =  X_ATTRIBUTE14)
                OR (    (Recinfo.ATTRIBUTE14 IS NULL)
                    AND (X_ATTRIBUTE14 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE15 =  X_ATTRIBUTE15)
                OR (    (Recinfo.ATTRIBUTE15 IS NULL)
                    AND (X_ATTRIBUTE15 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE16 =  X_ATTRIBUTE16)
                OR (    (Recinfo.ATTRIBUTE16 IS NULL)
                    AND (X_ATTRIBUTE16 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE17 =  X_ATTRIBUTE17)
                OR (    (Recinfo.ATTRIBUTE17 IS NULL)
                    AND (X_ATTRIBUTE17 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE18 =  X_ATTRIBUTE18)
                OR (    (Recinfo.ATTRIBUTE18 IS NULL)
                    AND (X_ATTRIBUTE18 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE19 =  X_ATTRIBUTE19)
                OR (    (Recinfo.ATTRIBUTE19 IS NULL)
                    AND (X_ATTRIBUTE19 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE20 =  X_ATTRIBUTE20)
                OR (    (Recinfo.ATTRIBUTE20 IS NULL)
                    AND (X_ATTRIBUTE20 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE21 =  X_ATTRIBUTE21)
                OR (    (Recinfo.ATTRIBUTE21 IS NULL)
                    AND (X_ATTRIBUTE21 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE22 =  X_ATTRIBUTE22)
                OR (    (Recinfo.ATTRIBUTE22 IS NULL)
                    AND (X_ATTRIBUTE22 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE23 =  X_ATTRIBUTE23)
                OR (    (Recinfo.ATTRIBUTE23 IS NULL)
                    AND (X_ATTRIBUTE23 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE24 =  X_ATTRIBUTE24)
                OR (    (Recinfo.ATTRIBUTE24 IS NULL)
                    AND (X_ATTRIBUTE24 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE25 =  X_ATTRIBUTE25)
                OR (    (Recinfo.ATTRIBUTE25 IS NULL)
                    AND (X_ATTRIBUTE25 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE26 =  X_ATTRIBUTE26)
                OR (    (Recinfo.ATTRIBUTE26 IS NULL)
                    AND (X_ATTRIBUTE26 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE27 =  X_ATTRIBUTE27)
                OR (    (Recinfo.ATTRIBUTE27 IS NULL)
                    AND (X_ATTRIBUTE27 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE28 =  X_ATTRIBUTE28)
                OR (    (Recinfo.ATTRIBUTE28 IS NULL)
                    AND (X_ATTRIBUTE28 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE29 =  X_ATTRIBUTE29)
                OR (    (Recinfo.ATTRIBUTE29 IS NULL)
                    AND (X_ATTRIBUTE29 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE30 =  X_ATTRIBUTE30)
                OR (    (Recinfo.ATTRIBUTE30 IS NULL)
                    AND (X_ATTRIBUTE30 IS NULL)))
           AND (   (Recinfo.ENTRY_SEQUENTIAL_NUMBER =  X_ENTRY_SEQUENTIAL_NUMBER)
                OR (    (Recinfo.ENTRY_SEQUENTIAL_NUMBER IS NULL)
                    AND (X_ENTRY_SEQUENTIAL_NUMBER IS NULL)))
           AND (Recinfo.SET_OF_BOOKS_ID =  X_SET_OF_BOOKS_ID)
           AND (Recinfo.VENDOR_ID =  X_VENDOR_ID)
           AND (   (Recinfo.BANK_BRANCH_ID =  X_BANK_BRANCH_ID)
                OR (    (Recinfo.BANK_BRANCH_ID IS NULL)
                    AND (X_BANK_BRANCH_ID IS NULL)))
           AND (   (Recinfo.BANK_PARTY_ID =  X_BANK_PARTY_ID)
                OR (    (Recinfo.BANK_PARTY_ID IS NULL)
                    AND (X_BANK_PARTY_ID IS NULL)))
           AND (Recinfo.BRANCH_PARTY_ID =  X_BRANCH_PARTY_ID)

           AND (   (recinfo.barcode =  x_barcode)
                OR (    (recinfo.barcode IS NULL)
                    AND (x_barcode IS NULL)))
           AND (   (recinfo.electronic_format_flag =  x_electronic_format_flag)
                OR (    (recinfo.electronic_format_flag IS NULL)
                    AND (x_electronic_format_flag IS NULL)))
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
             FND_MESSAGE.SET_TOKEN('PARAMETERS','bank_collection_id = ' ||
                                   X_bank_collection_id);
             FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
	 END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

  END Lock_Row;


END JL_BR_AP_COLLECTION_DOCS_PKG;

/
