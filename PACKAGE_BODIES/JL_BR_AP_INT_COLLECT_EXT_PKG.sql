--------------------------------------------------------
--  DDL for Package Body JL_BR_AP_INT_COLLECT_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AP_INT_COLLECT_EXT_PKG" as
/* $Header: jlbrpccb.pls 120.3.12010000.2 2009/11/19 16:09:33 gmeni ship $ */

  PROCEDURE Insert_Row (X_Rowid               IN OUT NOCOPY VARCHAR2,
                     X_FILE_CONTROL                  VARCHAR2,
                     X_ENTRY_SEQUENTIAL_NUMBER       NUMBER,
                     X_REGISTRY_CODE                 VARCHAR2 DEFAULT NULL,
                     X_RETURN_CODE                   NUMBER DEFAULT NULL,
                     X_SERVICE_CODE                  NUMBER DEFAULT NULL,
                     X_RECORDING_DATE                DATE DEFAULT NULL,
                     X_ISSUE_DATE                    DATE DEFAULT NULL,
                     X_DOCUMENT_NUMBER               VARCHAR2 DEFAULT NULL,
                     X_DRAWER_GUARANTOR              VARCHAR2 DEFAULT NULL,
                     X_INSTRUCTION_1                 VARCHAR2 DEFAULT NULL,
                     X_INSTRUCTION_2                 VARCHAR2 DEFAULT NULL,
                     X_CNAB_CODE                     VARCHAR2 DEFAULT NULL,
                     X_DUE_DATE                      DATE DEFAULT NULL,
                     X_AMOUNT                        NUMBER DEFAULT NULL,
                     X_DISCOUNT_DATE                 DATE DEFAULT NULL,
                     X_DISCOUNT_AMOUNT               NUMBER DEFAULT NULL,
                     X_ARREARS_DATE                  DATE DEFAULT NULL,
                     X_ARREARS_CODE                  VARCHAR2 DEFAULT NULL,
                     X_ARREARS_INTEREST              NUMBER DEFAULT NULL,
                     X_ABATE_AMOUNT                  NUMBER DEFAULT NULL,
                     X_PAID_AMOUNT                   NUMBER DEFAULT NULL,
                     X_PAYMENT_LOCATION              VARCHAR2 DEFAULT NULL,
                     X_DOCUMENT_TYPE                 VARCHAR2 DEFAULT NULL,
                     X_ACCEPTANCE                    VARCHAR2 DEFAULT NULL,
                     X_PROCESSING_DATE               DATE DEFAULT NULL,
                     X_BANK_USE                      VARCHAR2 DEFAULT NULL,
                     X_PORTFOLIO                     VARCHAR2 DEFAULT NULL,
                     X_PENALTY_FEE_AMOUNT            NUMBER DEFAULT NULL,
                     X_PENALTY_FEE_DATE              DATE DEFAULT NULL,
                     X_OTHER_ACCRETIONS              NUMBER DEFAULT NULL,
                     X_OUR_NUMBER                    VARCHAR2 DEFAULT NULL,
                     X_TRANSFEROR_CODE               VARCHAR2 DEFAULT NULL,
                     X_OCCURRENCE                    VARCHAR2 DEFAULT NULL,
                     X_OCCURRENCE_DATE               DATE DEFAULT NULL,
                     X_DRAWEE_NAME                   VARCHAR2 DEFAULT NULL,
                     X_DRAWEE_BANK_CODE              VARCHAR2 DEFAULT NULL,
                     X_DRAWEE_BANK_NAME              VARCHAR2 DEFAULT NULL,
                     X_DRAWEE_BRANCH_CODE            VARCHAR2 DEFAULT NULL,
                     X_DRAWEE_ACCOUNT_NUMBER         VARCHAR2 DEFAULT NULL,
                     X_DRAWEE_INSCRIPTION_TYPE       NUMBER DEFAULT NULL,
                     X_DRAWEE_INSCRIPTION_NUMBER     VARCHAR2 DEFAULT NULL,
                     X_TRANSFEROR_NAME               VARCHAR2 DEFAULT NULL,
                     X_TRANSFEROR_BANK_CODE          VARCHAR2 DEFAULT NULL,
                     X_TRANSFEROR_BRANCH_CODE        VARCHAR2 DEFAULT NULL,
                     X_TRANSFEROR_ACCOUNT_NUMBER     VARCHAR2 DEFAULT NULL,
                     X_TRANSFEROR_INSCRIPTION_TYPE   NUMBER DEFAULT NULL,
                     X_TRANSFEROR_INSCRIPTION_NUM    VARCHAR2 DEFAULT NULL,
                     X_ACCOUNTING_BALANCING_SEGMENT  VARCHAR2 DEFAULT NULL,
                     X_SET_OF_BOOKS_ID               NUMBER DEFAULT NULL,
                     X_ERROR_CODE                    VARCHAR2 DEFAULT NULL,
                     X_LAST_UPDATE_DATE              DATE,
                     X_LAST_UPDATED_BY               NUMBER,
                     X_CREATION_DATE                 DATE,
                     X_CREATED_BY                    NUMBER,
                     X_LAST_UPDATE_LOGIN             NUMBER,
                     X_ATTRIBUTE_CATEGORY            VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE1                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE2                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE3                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE4                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE5                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE6                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE7                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE8                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE9                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE10                   VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE11                   VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE12                   VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE13                   VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE14                   VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE15                   VARCHAR2 DEFAULT NULL,
                     X_calling_sequence              VARCHAR2,
                     X_ORG_ID	           	           VARCHAR2 DEFAULT NULL,
                     X_BARCODE		                     VARCHAR2 DEFAULT NULL,
                     X_ELECTRONIC_FORMAT_FLAG 		     VARCHAR2 DEFAULT NULL
                     ) IS

    CURSOR C IS SELECT rowid FROM JL_BR_AP_INT_COLLECT_EXT
                 WHERE file_control = X_file_control
                 AND entry_sequential_number = X_entry_sequential_number;
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

   BEGIN
--     Update the calling sequence
--
       current_calling_sequence := 'JL_BR_AP_INT_COLLECT_EXT_PKG.INSERT_ROW<-' ||
                                    X_calling_sequence;

       debug_info := 'Insert into JL_BR_AP_INT_COLLECT_EXT';
       INSERT INTO JL_BR_AP_INT_COLLECT_EXT(
		 FILE_CONTROL,
		 ENTRY_SEQUENTIAL_NUMBER,
		 REGISTRY_CODE,
		 RETURN_CODE,
		 SERVICE_CODE,
		 RECORDING_DATE,
		 ISSUE_DATE,
		 DOCUMENT_NUMBER,
		 DRAWER_GUARANTOR,
		 INSTRUCTION_1,
		 INSTRUCTION_2,
		 CNAB_CODE,
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
		 OCCURRENCE,
		 OCCURRENCE_DATE,
		 DRAWEE_NAME,
		 DRAWEE_BANK_CODE,
		 DRAWEE_BANK_NAME,
		 DRAWEE_BRANCH_CODE,
		 DRAWEE_ACCOUNT_NUMBER,
		 DRAWEE_INSCRIPTION_TYPE,
		 DRAWEE_INSCRIPTION_NUMBER,
		 TRANSFEROR_NAME,
		 TRANSFEROR_BANK_CODE,
		 TRANSFEROR_BRANCH_CODE,
		 TRANSFEROR_ACCOUNT_NUMBER,
		 TRANSFEROR_INSCRIPTION_TYPE,
		 TRANSFEROR_INSCRIPTION_NUMBER,
		 ACCOUNTING_BALANCING_SEGMENT,
		 SET_OF_BOOKS_ID,
		 ERROR_CODE,
		 LAST_UPDATE_DATE,
		 LAST_UPDATED_BY,
		 CREATION_DATE,
		 CREATED_BY,
		 LAST_UPDATE_LOGIN,
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
   ORG_ID,
   BARCODE,
   ELECTRONIC_FORMAT_FLAG
   )
       VALUES (
		 X_FILE_CONTROL,
		 X_ENTRY_SEQUENTIAL_NUMBER,
		 X_REGISTRY_CODE,
		 X_RETURN_CODE,
		 X_SERVICE_CODE,
		 X_RECORDING_DATE,
		 X_ISSUE_DATE,
		 X_DOCUMENT_NUMBER,
		 X_DRAWER_GUARANTOR,
		 X_INSTRUCTION_1,
		 X_INSTRUCTION_2,
		 X_CNAB_CODE,
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
		 X_OCCURRENCE,
		 X_OCCURRENCE_DATE,
		 X_DRAWEE_NAME,
		 X_DRAWEE_BANK_CODE,
		 X_DRAWEE_BANK_NAME,
		 X_DRAWEE_BRANCH_CODE,
		 X_DRAWEE_ACCOUNT_NUMBER,
		 X_DRAWEE_INSCRIPTION_TYPE,
		 X_DRAWEE_INSCRIPTION_NUMBER,
		 X_TRANSFEROR_NAME,
		 X_TRANSFEROR_BANK_CODE,
		 X_TRANSFEROR_BRANCH_CODE,
		 X_TRANSFEROR_ACCOUNT_NUMBER,
		 X_TRANSFEROR_INSCRIPTION_TYPE,
		 X_TRANSFEROR_INSCRIPTION_NUM,
		 X_ACCOUNTING_BALANCING_SEGMENT,
		 X_SET_OF_BOOKS_ID,
		 X_ERROR_CODE,
		 X_LAST_UPDATE_DATE,
		 X_LAST_UPDATED_BY,
		 X_CREATION_DATE,
		 X_CREATED_BY,
		 X_LAST_UPDATE_LOGIN,
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
   X_ORG_ID,
   X_BARCODE,
   X_ELECTRONIC_FORMAT_FLAG
   );

    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO X_Rowid;
    IF (C%NOTFOUND) THEN
      debug_info := 'Close cursor C - DATA NOTFOUND';
      CLOSE C;
      Raise NO_DATA_FOUND;
    END IF;
    debug_info := 'Close cursor C';
    CLOSE C;

    EXCEPTION
        WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS', 'file_control = ' ||
                                    X_file_control ||
                                    ' entry_sequential_number = ' ||
                                    X_entry_sequential_number);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
           END IF;

           APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                         VARCHAR2,
                     X_FILE_CONTROL                  VARCHAR2,
                     X_ENTRY_SEQUENTIAL_NUMBER       NUMBER,
                     X_REGISTRY_CODE                 VARCHAR2 DEFAULT NULL,
                     X_RETURN_CODE                   NUMBER DEFAULT NULL,
                     X_SERVICE_CODE                  NUMBER DEFAULT NULL,
                     X_RECORDING_DATE                DATE DEFAULT NULL,
                     X_ISSUE_DATE                    DATE DEFAULT NULL,
                     X_DOCUMENT_NUMBER               VARCHAR2 DEFAULT NULL,
                     X_DRAWER_GUARANTOR              VARCHAR2 DEFAULT NULL,
                     X_INSTRUCTION_1                 VARCHAR2 DEFAULT NULL,
                     X_INSTRUCTION_2                 VARCHAR2 DEFAULT NULL,
                     X_CNAB_CODE                     VARCHAR2 DEFAULT NULL,
                     X_DUE_DATE                      DATE DEFAULT NULL,
                     X_AMOUNT                        NUMBER DEFAULT NULL,
                     X_DISCOUNT_DATE                 DATE DEFAULT NULL,
                     X_DISCOUNT_AMOUNT               NUMBER DEFAULT NULL,
                     X_ARREARS_DATE                  DATE DEFAULT NULL,
                     X_ARREARS_CODE                  VARCHAR2 DEFAULT NULL,
                     X_ARREARS_INTEREST              NUMBER DEFAULT NULL,
                     X_ABATE_AMOUNT                  NUMBER DEFAULT NULL,
                     X_PAID_AMOUNT                   NUMBER DEFAULT NULL,
                     X_PAYMENT_LOCATION              VARCHAR2 DEFAULT NULL,
                     X_DOCUMENT_TYPE                 VARCHAR2 DEFAULT NULL,
                     X_ACCEPTANCE                    VARCHAR2 DEFAULT NULL,
                     X_PROCESSING_DATE               DATE DEFAULT NULL,
                     X_BANK_USE                      VARCHAR2 DEFAULT NULL,
                     X_PORTFOLIO                     VARCHAR2 DEFAULT NULL,
                     X_PENALTY_FEE_AMOUNT            NUMBER DEFAULT NULL,
                     X_PENALTY_FEE_DATE              DATE DEFAULT NULL,
                     X_OTHER_ACCRETIONS              NUMBER DEFAULT NULL,
                     X_OUR_NUMBER                    VARCHAR2 DEFAULT NULL,
                     X_TRANSFEROR_CODE               VARCHAR2 DEFAULT NULL,
                     X_OCCURRENCE                    VARCHAR2 DEFAULT NULL,
                     X_OCCURRENCE_DATE               DATE DEFAULT NULL,
                     X_DRAWEE_NAME                   VARCHAR2 DEFAULT NULL,
                     X_DRAWEE_BANK_CODE              VARCHAR2 DEFAULT NULL,
                     X_DRAWEE_BANK_NAME              VARCHAR2 DEFAULT NULL,
                     X_DRAWEE_BRANCH_CODE            VARCHAR2 DEFAULT NULL,
                     X_DRAWEE_ACCOUNT_NUMBER         VARCHAR2 DEFAULT NULL,
                     X_DRAWEE_INSCRIPTION_TYPE       NUMBER DEFAULT NULL,
                     X_DRAWEE_INSCRIPTION_NUMBER     VARCHAR2 DEFAULT NULL,
                     X_TRANSFEROR_NAME               VARCHAR2 DEFAULT NULL,
                     X_TRANSFEROR_BANK_CODE          VARCHAR2 DEFAULT NULL,
                     X_TRANSFEROR_BRANCH_CODE        VARCHAR2 DEFAULT NULL,
                     X_TRANSFEROR_ACCOUNT_NUMBER     VARCHAR2 DEFAULT NULL,
                     X_TRANSFEROR_INSCRIPTION_TYPE   NUMBER DEFAULT NULL,
                     X_TRANSFEROR_INSCRIPTION_NUM    VARCHAR2 DEFAULT NULL,
                     X_ACCOUNTING_BALANCING_SEGMENT  VARCHAR2 DEFAULT NULL,
                     X_SET_OF_BOOKS_ID               NUMBER DEFAULT NULL,
                     X_ERROR_CODE                    VARCHAR2 DEFAULT NULL,
                     X_LAST_UPDATE_DATE              DATE,
                     X_LAST_UPDATED_BY               NUMBER,
                     X_CREATION_DATE                 DATE,
                     X_CREATED_BY                    NUMBER,
                     X_LAST_UPDATE_LOGIN             NUMBER,
                     X_ATTRIBUTE_CATEGORY            VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE1                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE2                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE3                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE4                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE5                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE6                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE7                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE8                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE9                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE10                   VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE11                   VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE12                   VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE13                   VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE14                   VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE15                   VARCHAR2 DEFAULT NULL,
                     X_calling_sequence	             VARCHAR2,
                     X_BARCODE		                     VARCHAR2 DEFAULT NULL,
                     X_ELECTRONIC_FORMAT_FLAG 		     VARCHAR2 DEFAULT NULL
                     ) IS
    CURSOR C IS
        SELECT *
        FROM   JL_BR_AP_INT_COLLECT_EXT
        WHERE  rowid = X_Rowid
        FOR UPDATE OF file_control NOWAIT;

    Recinfo C%ROWTYPE;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'JL_BR_AP_INT_COLLECT_EXT_PKG.LOCK_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO Recinfo;

    IF (C%NOTFOUND) THEN
      debug_info := 'Close cursor C - DATA NOTFOUND';
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;

    debug_info := 'Close cursor C';
    CLOSE C;
    IF (
           (Recinfo.file_control =  X_file_control)
           AND (Recinfo.entry_sequential_number =  X_entry_sequential_number)
           AND (   (Recinfo.REGISTRY_CODE =  X_REGISTRY_CODE)
                OR (    (Recinfo.REGISTRY_CODE IS NULL)
                    AND (X_REGISTRY_CODE IS NULL)))
           AND (   (Recinfo.RETURN_CODE =  X_RETURN_CODE)
                OR (    (Recinfo.RETURN_CODE IS NULL)
                    AND (X_RETURN_CODE IS NULL)))
           AND (   (Recinfo.SERVICE_CODE =  X_SERVICE_CODE)
                OR (    (Recinfo.SERVICE_CODE IS NULL)
                    AND (X_SERVICE_CODE IS NULL)))
           AND (   (Recinfo.RECORDING_DATE =  X_RECORDING_DATE)
                OR (    (Recinfo.RECORDING_DATE IS NULL)
                    AND (X_RECORDING_DATE IS NULL)))
           AND (   (Recinfo.ISSUE_DATE =  X_ISSUE_DATE)
                OR (    (Recinfo.ISSUE_DATE IS NULL)
                    AND (X_ISSUE_DATE IS NULL)))
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
           AND (   (Recinfo.CNAB_CODE =  X_CNAB_CODE)
                OR (    (Recinfo.CNAB_CODE IS NULL)
                    AND (X_CNAB_CODE IS NULL)))
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
           AND (   (Recinfo.OCCURRENCE =  X_OCCURRENCE)
                OR (    (Recinfo.OCCURRENCE IS NULL)
                    AND (X_OCCURRENCE IS NULL)))
           AND (   (Recinfo.OCCURRENCE_DATE =  X_OCCURRENCE_DATE)
                OR (    (Recinfo.OCCURRENCE_DATE IS NULL)
                    AND (X_OCCURRENCE_DATE IS NULL)))
           AND (   (Recinfo.DRAWEE_NAME =  X_DRAWEE_NAME)
                OR (    (Recinfo.DRAWEE_NAME IS NULL)
                    AND (X_DRAWEE_NAME IS NULL)))
           AND (   (Recinfo.DRAWEE_BANK_CODE =  X_DRAWEE_BANK_CODE)
                OR (    (Recinfo.DRAWEE_BANK_CODE IS NULL)
                    AND (X_DRAWEE_BANK_CODE IS NULL)))
           AND (   (Recinfo.DRAWEE_BANK_NAME =  X_DRAWEE_BANK_NAME)
                OR (    (Recinfo.DRAWEE_BANK_NAME IS NULL)
                    AND (X_DRAWEE_BANK_NAME IS NULL)))
           AND (   (Recinfo.DRAWEE_BRANCH_CODE =  X_DRAWEE_BRANCH_CODE)
                OR (    (Recinfo.DRAWEE_BRANCH_CODE IS NULL)
                    AND (X_DRAWEE_BRANCH_CODE IS NULL)))
           AND (   (Recinfo.DRAWEE_ACCOUNT_NUMBER =  X_DRAWEE_ACCOUNT_NUMBER)
                OR (    (Recinfo.DRAWEE_ACCOUNT_NUMBER IS NULL)
                    AND (X_DRAWEE_ACCOUNT_NUMBER IS NULL)))
           AND (   (Recinfo.TRANSFEROR_INSCRIPTION_TYPE =  X_TRANSFEROR_INSCRIPTION_TYPE)
                OR (    (Recinfo.TRANSFEROR_INSCRIPTION_TYPE IS NULL)
                    AND (X_TRANSFEROR_INSCRIPTION_TYPE IS NULL)))
           AND (   (Recinfo.TRANSFEROR_INSCRIPTION_NUMBER =  X_TRANSFEROR_INSCRIPTION_NUM)
                OR (    (Recinfo.TRANSFEROR_INSCRIPTION_NUMBER IS NULL)
                    AND (X_TRANSFEROR_INSCRIPTION_NUM IS NULL)))
           AND (   (Recinfo.ACCOUNTING_BALANCING_SEGMENT =  X_ACCOUNTING_BALANCING_SEGMENT)
                OR (    (Recinfo.ACCOUNTING_BALANCING_SEGMENT IS NULL)
                    AND (X_ACCOUNTING_BALANCING_SEGMENT IS NULL)))
           AND (   (Recinfo.SET_OF_BOOKS_ID =  X_SET_OF_BOOKS_ID)
                OR (    (Recinfo.SET_OF_BOOKS_ID IS NULL)
                    AND (X_SET_OF_BOOKS_ID IS NULL)))
           AND (   (Recinfo.ERROR_CODE =  X_ERROR_CODE)
                OR (    (Recinfo.ERROR_CODE IS NULL)
                    AND (X_ERROR_CODE IS NULL)))
           AND (   (Recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
                OR (    (Recinfo.ATTRIBUTE_CATEGORY IS NULL)
                    AND (X_ATTRIBUTE_CATEGORY IS NULL)))
           AND (   (Recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
                OR (    (Recinfo.ATTRIBUTE1 IS NULL)
                    AND (X_ATTRIBUTE1 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
                OR (    (Recinfo.ATTRIBUTE2 IS NULL)
                    AND (X_ATTRIBUTE2 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
                OR (    (Recinfo.ATTRIBUTE3 IS NULL)
                    AND (X_ATTRIBUTE3 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
                OR (    (Recinfo.ATTRIBUTE4 IS NULL)
                    AND (X_ATTRIBUTE4 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
                OR (    (Recinfo.ATTRIBUTE5 IS NULL)
                    AND (X_ATTRIBUTE5 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
                OR (    (Recinfo.ATTRIBUTE6 IS NULL)
                    AND (X_ATTRIBUTE6 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
                OR (    (Recinfo.ATTRIBUTE7 IS NULL)
                    AND (X_ATTRIBUTE7 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
                OR (    (Recinfo.ATTRIBUTE8 IS NULL)
                    AND (X_ATTRIBUTE8 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
                OR (    (Recinfo.ATTRIBUTE9 IS NULL)
                    AND (X_ATTRIBUTE9 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
                OR (    (Recinfo.ATTRIBUTE10 IS NULL)
                    AND (X_ATTRIBUTE10 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
                OR (    (Recinfo.ATTRIBUTE11 IS NULL)
                    AND (X_ATTRIBUTE11 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
                OR (    (Recinfo.ATTRIBUTE12 IS NULL)
                    AND (X_ATTRIBUTE12 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
                OR (    (Recinfo.ATTRIBUTE13 IS NULL)
                    AND (X_ATTRIBUTE13 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
                OR (    (Recinfo.ATTRIBUTE14 IS NULL)
                    AND (X_ATTRIBUTE14 IS NULL)))
           AND (   (Recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
                OR (    (Recinfo.ATTRIBUTE15 IS NULL)
                    AND (X_ATTRIBUTE15 IS NULL)))
           AND (   (recinfo.barcode =  x_barcode)
                OR (    (recinfo.barcode IS NULL)
                    AND (x_barcode IS NULL)))
           AND (   (recinfo.electronic_format_flag =  x_electronic_format_flag)
                OR (    (recinfo.electronic_format_flag IS NULL)
                    AND (x_electronic_format_flag IS NULL)))
      ) THEN
      RETURN;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    END IF;

    EXCEPTION
       WHEN OTHERS THEN
         IF (SQLCODE <> -20001) THEN
           IF (SQLCODE = -54) THEN
             FND_MESSAGE.SET_NAME('SQLAP','AP_RESOURCE_BUSY');
           ELSE
             FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
             FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
             FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
             FND_MESSAGE.SET_TOKEN('PARAMETERS','file_control = ' ||
                                    X_file_control ||
                                    ' entry_sequential_number = ' ||
                                    X_entry_sequential_number);
             FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
           END IF;
	 END IF;

     APP_EXCEPTION.RAISE_EXCEPTION;
  END Lock_Row;


  PROCEDURE Update_Row(X_Rowid                       VARCHAR2,
                     X_FILE_CONTROL                  VARCHAR2,
                     X_ENTRY_SEQUENTIAL_NUMBER       NUMBER,
                     X_REGISTRY_CODE                 VARCHAR2 DEFAULT NULL,
                     X_RETURN_CODE                   NUMBER DEFAULT NULL,
                     X_SERVICE_CODE                  NUMBER DEFAULT NULL,
                     X_RECORDING_DATE                DATE DEFAULT NULL,
                     X_ISSUE_DATE                    DATE DEFAULT NULL,
                     X_DOCUMENT_NUMBER               VARCHAR2 DEFAULT NULL,
                     X_DRAWER_GUARANTOR              VARCHAR2 DEFAULT NULL,
                     X_INSTRUCTION_1                 VARCHAR2 DEFAULT NULL,
                     X_INSTRUCTION_2                 VARCHAR2 DEFAULT NULL,
                     X_CNAB_CODE                     VARCHAR2 DEFAULT NULL,
                     X_DUE_DATE                      DATE DEFAULT NULL,
                     X_AMOUNT                        NUMBER DEFAULT NULL,
                     X_DISCOUNT_DATE                 DATE DEFAULT NULL,
                     X_DISCOUNT_AMOUNT               NUMBER DEFAULT NULL,
                     X_ARREARS_DATE                  DATE DEFAULT NULL,
                     X_ARREARS_CODE                  VARCHAR2 DEFAULT NULL,
                     X_ARREARS_INTEREST              NUMBER DEFAULT NULL,
                     X_ABATE_AMOUNT                  NUMBER DEFAULT NULL,
                     X_PAID_AMOUNT                   NUMBER DEFAULT NULL,
                     X_PAYMENT_LOCATION              VARCHAR2 DEFAULT NULL,
                     X_DOCUMENT_TYPE                 VARCHAR2 DEFAULT NULL,
                     X_ACCEPTANCE                    VARCHAR2 DEFAULT NULL,
                     X_PROCESSING_DATE               DATE DEFAULT NULL,
                     X_BANK_USE                      VARCHAR2 DEFAULT NULL,
                     X_PORTFOLIO                     VARCHAR2 DEFAULT NULL,
                     X_PENALTY_FEE_AMOUNT            NUMBER DEFAULT NULL,
                     X_PENALTY_FEE_DATE              DATE DEFAULT NULL,
                     X_OTHER_ACCRETIONS              NUMBER DEFAULT NULL,
                     X_OUR_NUMBER                    VARCHAR2 DEFAULT NULL,
                     X_TRANSFEROR_CODE               VARCHAR2 DEFAULT NULL,
                     X_OCCURRENCE                    VARCHAR2 DEFAULT NULL,
                     X_OCCURRENCE_DATE               DATE DEFAULT NULL,
                     X_DRAWEE_NAME                   VARCHAR2 DEFAULT NULL,
                     X_DRAWEE_BANK_CODE              VARCHAR2 DEFAULT NULL,
                     X_DRAWEE_BANK_NAME              VARCHAR2 DEFAULT NULL,
                     X_DRAWEE_BRANCH_CODE            VARCHAR2 DEFAULT NULL,
                     X_DRAWEE_ACCOUNT_NUMBER         VARCHAR2 DEFAULT NULL,
                     X_DRAWEE_INSCRIPTION_TYPE       NUMBER DEFAULT NULL,
                     X_DRAWEE_INSCRIPTION_NUMBER     VARCHAR2 DEFAULT NULL,
                     X_TRANSFEROR_NAME               VARCHAR2 DEFAULT NULL,
                     X_TRANSFEROR_BANK_CODE          VARCHAR2 DEFAULT NULL,
                     X_TRANSFEROR_BRANCH_CODE        VARCHAR2 DEFAULT NULL,
                     X_TRANSFEROR_ACCOUNT_NUMBER     VARCHAR2 DEFAULT NULL,
                     X_TRANSFEROR_INSCRIPTION_TYPE   NUMBER DEFAULT NULL,
                     X_TRANSFEROR_INSCRIPTION_NUM    VARCHAR2 DEFAULT NULL,
                     X_ACCOUNTING_BALANCING_SEGMENT  VARCHAR2 DEFAULT NULL,
                     X_SET_OF_BOOKS_ID               NUMBER DEFAULT NULL,
                     X_ERROR_CODE                    VARCHAR2 DEFAULT NULL,
                     X_LAST_UPDATE_DATE              DATE,
                     X_LAST_UPDATED_BY               NUMBER,
                     X_CREATION_DATE                 DATE,
                     X_CREATED_BY                    NUMBER,
                     X_LAST_UPDATE_LOGIN             NUMBER,
                     X_ATTRIBUTE_CATEGORY            VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE1                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE2                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE3                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE4                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE5                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE6                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE7                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE8                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE9                    VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE10                   VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE11                   VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE12                   VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE13                   VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE14                   VARCHAR2 DEFAULT NULL,
                     X_ATTRIBUTE15                   VARCHAR2 DEFAULT NULL,
                     X_calling_sequence		            VARCHAR2,
                     X_BARCODE		                     VARCHAR2 DEFAULT NULL,
                     X_ELECTRONIC_FORMAT_FLAG 		     VARCHAR2 DEFAULT NULL
                     ) IS

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);
  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'JL_BR_AP_INT_COLLECT_EXT_PKG.UPDATE_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Update JL_BR_AP_INT_COLLECT_EXT';
    UPDATE JL_BR_AP_INT_COLLECT_EXT
    SET
	 FILE_CONTROL                           =	 X_FILE_CONTROL,
	 ENTRY_SEQUENTIAL_NUMBER                =	 X_ENTRY_SEQUENTIAL_NUMBER,
	 REGISTRY_CODE                          =	 X_REGISTRY_CODE,
	 RETURN_CODE                            =	 X_RETURN_CODE,
	 SERVICE_CODE                           =	 X_SERVICE_CODE,
	 RECORDING_DATE                         =	 X_RECORDING_DATE,
	 ISSUE_DATE                             =	 X_ISSUE_DATE,
	 DOCUMENT_NUMBER                        =	 X_DOCUMENT_NUMBER,
	 DRAWER_GUARANTOR                       =	 X_DRAWER_GUARANTOR,
	 INSTRUCTION_1                          =	 X_INSTRUCTION_1,
	 INSTRUCTION_2                          =	 X_INSTRUCTION_2,
	 CNAB_CODE                              =	 X_CNAB_CODE,
	 DUE_DATE                               =	 X_DUE_DATE,
	 AMOUNT                                 =	 X_AMOUNT,
	 DISCOUNT_DATE                          =	 X_DISCOUNT_DATE,
	 DISCOUNT_AMOUNT                        =	 X_DISCOUNT_AMOUNT,
	 ARREARS_DATE                           =	 X_ARREARS_DATE,
	 ARREARS_CODE                           =	 X_ARREARS_CODE,
	 ARREARS_INTEREST                       =	 X_ARREARS_INTEREST,
	 ABATE_AMOUNT                           =	 X_ABATE_AMOUNT,
	 PAID_AMOUNT                            =	 X_PAID_AMOUNT,
	 PAYMENT_LOCATION                       =	 X_PAYMENT_LOCATION,
	 DOCUMENT_TYPE                          =	 X_DOCUMENT_TYPE,
	 ACCEPTANCE                             =	 X_ACCEPTANCE,
	 PROCESSING_DATE                        =	 X_PROCESSING_DATE,
	 BANK_USE                               =	 X_BANK_USE,
	 PORTFOLIO                              =	 X_PORTFOLIO,
	 PENALTY_FEE_AMOUNT                     =	 X_PENALTY_FEE_AMOUNT,
	 PENALTY_FEE_DATE                       =	 X_PENALTY_FEE_DATE,
	 OTHER_ACCRETIONS                       =	 X_OTHER_ACCRETIONS,
	 OUR_NUMBER                             =	 X_OUR_NUMBER,
	 TRANSFEROR_CODE                        =	 X_TRANSFEROR_CODE,
	 OCCURRENCE                             =	 X_OCCURRENCE,
	 OCCURRENCE_DATE                        =	 X_OCCURRENCE_DATE,
	 DRAWEE_NAME                            =	 X_DRAWEE_NAME,
	 DRAWEE_BANK_CODE                       =	 X_DRAWEE_BANK_CODE,
	 DRAWEE_BANK_NAME                       =	 X_DRAWEE_BANK_NAME,
	 DRAWEE_BRANCH_CODE                     =	 X_DRAWEE_BRANCH_CODE,
	 DRAWEE_ACCOUNT_NUMBER                  =	 X_DRAWEE_ACCOUNT_NUMBER,
	 DRAWEE_INSCRIPTION_TYPE                =	 X_DRAWEE_INSCRIPTION_TYPE,
	 DRAWEE_INSCRIPTION_NUMBER              =	 X_DRAWEE_INSCRIPTION_NUMBER,
	 TRANSFEROR_NAME                        =	 X_TRANSFEROR_NAME,
	 TRANSFEROR_BANK_CODE                   =	 X_TRANSFEROR_BANK_CODE,
	 TRANSFEROR_BRANCH_CODE                 =	 X_TRANSFEROR_BRANCH_CODE,
	 TRANSFEROR_ACCOUNT_NUMBER              =	 X_TRANSFEROR_ACCOUNT_NUMBER,
	 TRANSFEROR_INSCRIPTION_TYPE            =	 X_TRANSFEROR_INSCRIPTION_TYPE,
	 TRANSFEROR_INSCRIPTION_NUMBER          =	 X_TRANSFEROR_INSCRIPTION_NUM,
	 ACCOUNTING_BALANCING_SEGMENT           =	 X_ACCOUNTING_BALANCING_SEGMENT,
	 SET_OF_BOOKS_ID                        =	 X_SET_OF_BOOKS_ID,
	 ERROR_CODE                             =	 X_ERROR_CODE,
	 LAST_UPDATE_DATE                       =	 X_LAST_UPDATE_DATE,
	 LAST_UPDATED_BY                        =	 X_LAST_UPDATED_BY,
	 CREATION_DATE                          =	 X_CREATION_DATE,
	 CREATED_BY                             =	 X_CREATED_BY,
	 LAST_UPDATE_LOGIN                      =	 X_LAST_UPDATE_LOGIN,
  ATTRIBUTE_CATEGORY                     =  X_ATTRIBUTE_CATEGORY,
  ATTRIBUTE1                             =  X_ATTRIBUTE1,
  ATTRIBUTE2                             =  X_ATTRIBUTE2,
  ATTRIBUTE3                             =  X_ATTRIBUTE3,
  ATTRIBUTE4                             =  X_ATTRIBUTE4,
  ATTRIBUTE5                             =  X_ATTRIBUTE5,
  ATTRIBUTE6                             =  X_ATTRIBUTE6,
  ATTRIBUTE7                             =  X_ATTRIBUTE7,
  ATTRIBUTE8                             =  X_ATTRIBUTE8,
  ATTRIBUTE9                             =  X_ATTRIBUTE9,
  ATTRIBUTE10                            =  X_ATTRIBUTE10,
  ATTRIBUTE11                            =  X_ATTRIBUTE11,
  ATTRIBUTE12                            =  X_ATTRIBUTE12,
  ATTRIBUTE13                            =  X_ATTRIBUTE13,
  ATTRIBUTE14                            =  X_ATTRIBUTE14,
  ATTRIBUTE15                            =  X_ATTRIBUTE15,
  BARCODE                                =  X_BARCODE,
  ELECTRONIC_FORMAT_FLAG                 =  X_ELECTRONIC_FORMAT_FLAG
WHERE rowid = X_Rowid;

    IF (SQL%NOTFOUND) THEN
      Raise NO_DATA_FOUND;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
             FND_MESSAGE.SET_TOKEN('PARAMETERS','file_control = ' ||
                                    X_file_control ||
                                                ' entry_sequential_number = ' ||
                                    X_entry_sequential_number);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid               VARCHAR2,
                       X_calling_sequence IN VARCHAR2) IS
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);
  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'JL_BR_AP_INT_COLLECT_EXT_PKG.DELETE_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Delete from JL_BR_AP_INT_COLLECT_EXT';
    DELETE FROM JL_BR_AP_INT_COLLECT_EXT
    WHERE rowid = X_Rowid;

    IF (SQL%NOTFOUND) THEN
      Raise NO_DATA_FOUND;
    END IF;

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

END JL_BR_AP_INT_COLLECT_EXT_PKG;

/
