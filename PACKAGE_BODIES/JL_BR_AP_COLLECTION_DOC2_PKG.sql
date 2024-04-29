--------------------------------------------------------
--  DDL for Package Body JL_BR_AP_COLLECTION_DOC2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AP_COLLECTION_DOC2_PKG" as
/* $Header: jlbrpe2b.pls 120.2.12010000.2 2009/11/19 16:03:05 gmeni ship $ */

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

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
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);
  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'JL_BR_AP_COLLECTION_DOCS_PKG.UPDATE_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Update JL_BR_AP_COLLECTION_DOCS';
    UPDATE JL_BR_AP_COLLECTION_DOCS
    SET
	BANK_COLLECTION_ID             =	X_BANK_COLLECTION_ID,
	LAST_UPDATED_BY                =	X_LAST_UPDATED_BY,
 	LAST_UPDATE_DATE               = 	X_LAST_UPDATE_DATE,
 	CREATED_BY                     = 	X_CREATED_BY,
 	CREATION_DATE                  = 	X_CREATION_DATE,
 	LAST_UPDATE_LOGIN              = 	X_LAST_UPDATE_LOGIN,
 	INVOICE_ID                     = 	X_INVOICE_ID,
 	PAYMENT_NUM                    = 	X_PAYMENT_NUM,
 	HOLD_FLAG                      = 	X_HOLD_FLAG,
 	ISSUE_DATE                     = 	X_ISSUE_DATE,
 	DOCUMENT_NUMBER                = 	X_DOCUMENT_NUMBER,
 	DRAWER_GUARANTOR               = 	X_DRAWER_GUARANTOR,
 	INSTRUCTION_1                  = 	X_INSTRUCTION_1,
 	INSTRUCTION_2                  = 	X_INSTRUCTION_2,
 	CURRENCY_CODE                  = 	X_CURRENCY_CODE,
 	DUE_DATE                       = 	X_DUE_DATE,
 	AMOUNT                         = 	X_AMOUNT,
 	DISCOUNT_DATE                  = 	X_DISCOUNT_DATE,
 	DISCOUNT_AMOUNT                = 	X_DISCOUNT_AMOUNT,
 	ARREARS_DATE                   = 	X_ARREARS_DATE,
 	ARREARS_CODE                   = 	X_ARREARS_CODE,
 	ARREARS_INTEREST               = 	X_ARREARS_INTEREST,
 	ABATE_AMOUNT                   = 	X_ABATE_AMOUNT,
 	PAID_AMOUNT                    = 	X_PAID_AMOUNT,
 	PAYMENT_LOCATION               = 	X_PAYMENT_LOCATION,
 	DOCUMENT_TYPE                  = 	X_DOCUMENT_TYPE,
 	ACCEPTANCE                     = 	X_ACCEPTANCE,
 	PROCESSING_DATE                = 	X_PROCESSING_DATE,
 	BANK_USE                       = 	X_BANK_USE,
 	PORTFOLIO                      = 	X_PORTFOLIO,
 	PENALTY_FEE_AMOUNT             = 	X_PENALTY_FEE_AMOUNT,
 	PENALTY_FEE_DATE               = 	X_PENALTY_FEE_DATE,
 	OTHER_ACCRETIONS               = 	X_OTHER_ACCRETIONS,
 	OUR_NUMBER                     = 	X_OUR_NUMBER,
 	TRANSFEROR_CODE                = 	X_TRANSFEROR_CODE,
 	VENDOR_SITE_ID                 = 	X_VENDOR_SITE_ID,
 	FILE_CONTROL                   = 	X_FILE_CONTROL,
 	STATUS_LOOKUP_CODE             = 	X_STATUS_LOOKUP_CODE,
 	ATTRIBUTE_CATEGORY             = 	X_ATTRIBUTE_CATEGORY,
 	ATTRIBUTE1                     = 	X_ATTRIBUTE1,
 	ATTRIBUTE2                     = 	X_ATTRIBUTE2,
 	ATTRIBUTE3                     = 	X_ATTRIBUTE3,
 	ATTRIBUTE4                     = 	X_ATTRIBUTE4,
 	ATTRIBUTE5                     = 	X_ATTRIBUTE5,
 	ATTRIBUTE6                     = 	X_ATTRIBUTE6,
	ATTRIBUTE7                     = 	X_ATTRIBUTE7,
	ATTRIBUTE8                     = 	X_ATTRIBUTE8,
 	ATTRIBUTE9                     = 	X_ATTRIBUTE9,
 	ATTRIBUTE10                    = 	X_ATTRIBUTE10,
 	ATTRIBUTE11                    = 	X_ATTRIBUTE11,
 	ATTRIBUTE12                    = 	X_ATTRIBUTE12,
 	ATTRIBUTE13                    = 	X_ATTRIBUTE13,
 	ATTRIBUTE14                    = 	X_ATTRIBUTE14,
 	ATTRIBUTE15                    = 	X_ATTRIBUTE15,
 	ATTRIBUTE16                    = 	X_ATTRIBUTE16,
 	ATTRIBUTE17                    = 	X_ATTRIBUTE17,
 	ATTRIBUTE18                    = 	X_ATTRIBUTE18,
 	ATTRIBUTE19                    = 	X_ATTRIBUTE19,
 	ATTRIBUTE20                    = 	X_ATTRIBUTE20,
 	ATTRIBUTE21                    = 	X_ATTRIBUTE21,
 	ATTRIBUTE22                    = 	X_ATTRIBUTE22,
 	ATTRIBUTE23                    = 	X_ATTRIBUTE23,
 	ATTRIBUTE24                    = 	X_ATTRIBUTE24,
 	ATTRIBUTE25                    = 	X_ATTRIBUTE25,
 	ATTRIBUTE26                    = 	X_ATTRIBUTE26,
 	ATTRIBUTE27                    = 	X_ATTRIBUTE27,
 	ATTRIBUTE28                    = 	X_ATTRIBUTE28,
 	ATTRIBUTE29                    = 	X_ATTRIBUTE29,
 	ATTRIBUTE30                    = 	X_ATTRIBUTE30,
 	ENTRY_SEQUENTIAL_NUMBER        = 	X_ENTRY_SEQUENTIAL_NUMBER,
 	SET_OF_BOOKS_ID                = 	X_SET_OF_BOOKS_ID,
 	VENDOR_ID                      = 	X_VENDOR_ID,
 	BANK_BRANCH_ID                 = 	X_BANK_BRANCH_ID,
 	BANK_PARTY_ID                  = 	X_BANK_PARTY_ID,
 	BRANCH_PARTY_ID                = 	X_BRANCH_PARTY_ID,
 	BARCODE                        =  X_BARCODE,
  ELECTRONIC_FORMAT_FLAG         =  X_ELECTRONIC_FORMAT_FLAG
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
              FND_MESSAGE.SET_TOKEN('PARAMETERS','bank_collection_id = ' ||
                                    X_bank_collection_id);
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
    current_calling_sequence := 'JL_BR_AP_COLLECTION_DOCS_PKG.DELETE_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Delete from JL_BR_AP_COLLECTION_DOCS';
    DELETE FROM JL_BR_AP_COLLECTION_DOCS
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

END JL_BR_AP_COLLECTION_DOC2_PKG;

/
