--------------------------------------------------------
--  DDL for Package Body JL_BR_AR_COLLECTION_DOC2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AR_COLLECTION_DOC2_PKG" as
/* $Header: jlbrrc2b.pls 120.3 2005/02/23 23:27:47 vsidhart ship $ */

  PROCEDURE Lock_Row (   X_Rowid                                    VARCHAR2,

			 X_DOCUMENT_ID                              NUMBER,
			 X_BORDERO_ID                               NUMBER,
			 X_PAYMENT_SCHEDULE_ID                      NUMBER,
			 X_DOCUMENT_STATUS                          VARCHAR2,
			 X_ORIGIN_TYPE                              VARCHAR2,
			 X_DUE_DATE                                 DATE,
			 X_SELECTION_DATE                           DATE,
			 X_PORTFOLIO_CODE                           NUMBER,
			 X_BATCH_SOURCE_ID                          NUMBER,
			 X_RECEIPT_METHOD_ID                        NUMBER,
			 X_CUSTOMER_TRX_ID                          NUMBER,
			 X_TERMS_SEQUENCE_NUMBER                    NUMBER,
			 X_DOCUMENT_TYPE                            VARCHAR2,
			 X_BANK_ACCT_USE_ID                         NUMBER DEFAULT NULL,
			 X_PREVIOUS_DOC_STATUS                      VARCHAR2 DEFAULT NULL,
			 X_OUR_NUMBER                               VARCHAR2 DEFAULT NULL,
			 X_BANK_USE                                 VARCHAR2 DEFAULT NULL,
			 X_COLLECTOR_BANK_PARTY_ID                  NUMBER DEFAULT NULL,
			 X_COLLECTOR_BRANCH_PARTY_ID                NUMBER DEFAULT NULL,
			 X_FACTORING_RATE                           NUMBER DEFAULT NULL,
			 X_FACTORING_RATE_PERIOD                    NUMBER DEFAULT NULL,
			 X_FACTORING_AMOUNT                         NUMBER DEFAULT NULL,
			 X_FACTORING_DATE                           DATE DEFAULT NULL,
			 X_CANCELLATION_DATE                        DATE DEFAULT NULL,
			 X_BANK_INSTRUCTION_CODE1                   NUMBER DEFAULT NULL,
			 X_BANK_INSTRUCTION_CODE2                   NUMBER DEFAULT NULL,
			 X_NUM_DAYS_INSTRUCTION                     NUMBER DEFAULT NULL,
			 X_BANK_CHARGE_AMOUNT                       NUMBER DEFAULT NULL,
			 X_CASH_CCID                                NUMBER DEFAULT NULL,
			 X_BANK_CHARGES_CCID                        NUMBER DEFAULT NULL,
			 X_COLL_ENDORSEMENTS_CCID                   NUMBER DEFAULT NULL,
			 X_BILLS_COLLECTION_CCID                    NUMBER DEFAULT NULL,
			 X_CALCULATED_INTEREST_CCID                 NUMBER DEFAULT NULL,
			 X_INTEREST_WRITEOFF_CCID                   NUMBER DEFAULT NULL,
			 X_ABATEMENT_WRITEOFF_CCID                  NUMBER DEFAULT NULL,
			 X_ABATEMENT_REVENUE_CCID                   NUMBER DEFAULT NULL,
			 X_INTEREST_REVENUE_CCID                    NUMBER DEFAULT NULL,
			 X_CALCULATED_INT_RECTRX_ID                 NUMBER DEFAULT NULL,
			 X_INTEREST_WRITEOFF_RECTRX_ID              NUMBER DEFAULT NULL,
			 X_INTEREST_REVENUE_RECTRX_ID               NUMBER DEFAULT NULL,
			 X_ABATEMENT_WRITEOFF_RECTRX_ID             NUMBER DEFAULT NULL,
			 X_ABATE_REVENUE_RECTRX_ID                  NUMBER DEFAULT NULL,
			 X_ATTRIBUTE_CATEGORY                       VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE1                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE2                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE3                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE4                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE5                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE6                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE7                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE8                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE9                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE10                              VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE11                              VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE12                              VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE13                              VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE14                              VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE15                              VARCHAR2 DEFAULT NULL,
			 X_LAST_UPDATE_DATE                         DATE,
			 X_LAST_UPDATED_BY                          NUMBER,
			 X_CREATION_DATE                            DATE,
			 X_CREATED_BY                               NUMBER,
			 X_LAST_UPDATE_LOGIN                        NUMBER,
	         X_calling_sequence		                    VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   JL_BR_AR_COLLECTION_DOCS
        WHERE  rowid = X_Rowid
        FOR UPDATE of document_id NOWAIT;
    Recinfo C%ROWTYPE;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'JL_BR_AR_COLLECTION_DOC2_PKG.LOCK_ROW<-' ||
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
           (Recinfo.document_id =  X_document_id)
           AND (Recinfo.bordero_id =  X_bordero_id)
           AND (Recinfo.payment_schedule_id =  X_payment_schedule_id)
           AND (Recinfo.document_status =  X_document_status)
           AND (Recinfo.origin_type =  X_origin_type)
           AND (Recinfo.due_date =  X_due_date)
           AND (Recinfo.selection_date =  X_selection_date)
           AND (Recinfo.portfolio_code =  X_portfolio_code)
           AND (Recinfo.batch_source_id =  X_batch_source_id)
           AND (Recinfo.receipt_method_id =  X_receipt_method_id)
           AND (Recinfo.customer_trx_id =  X_customer_trx_id)
           AND (Recinfo.terms_sequence_number =  X_terms_sequence_number)
           AND (Recinfo.document_type =  X_document_type)
           AND (   (Recinfo.BANK_ACCT_USE_ID =  X_BANK_ACCT_USE_ID)
                OR (    (Recinfo.BANK_ACCT_USE_ID IS NULL)
                    AND (X_BANK_ACCT_USE_ID IS NULL)))
           AND (   (Recinfo.PREVIOUS_DOC_STATUS =  X_PREVIOUS_DOC_STATUS)
                OR (    (Recinfo.PREVIOUS_DOC_STATUS IS NULL)
                    AND (X_PREVIOUS_DOC_STATUS IS NULL)))
           AND (   (Recinfo.OUR_NUMBER =  X_OUR_NUMBER)
                OR (    (Recinfo.OUR_NUMBER IS NULL)
                    AND (X_OUR_NUMBER IS NULL)))
           AND (   (Recinfo.BANK_USE =  X_BANK_USE)
                OR (    (Recinfo.BANK_USE IS NULL)
                    AND (X_BANK_USE IS NULL)))
           AND (   (Recinfo.COLLECTOR_BANK_PARTY_ID =  X_COLLECTOR_BANK_PARTY_ID)
                OR (    (Recinfo.COLLECTOR_BANK_PARTY_ID IS NULL)
                    AND (X_COLLECTOR_BANK_PARTY_ID IS NULL)))
           AND (   (Recinfo.COLLECTOR_BRANCH_PARTY_ID =  X_COLLECTOR_BRANCH_PARTY_ID)
                OR (    (Recinfo.COLLECTOR_BRANCH_PARTY_ID IS NULL)
                    AND (X_COLLECTOR_BRANCH_PARTY_ID IS NULL)))
           AND (   (Recinfo.FACTORING_RATE =  X_FACTORING_RATE)
                OR (    (Recinfo.FACTORING_RATE IS NULL)
                    AND (X_FACTORING_RATE IS NULL)))
           AND (   (Recinfo.FACTORING_RATE_PERIOD =  X_FACTORING_RATE_PERIOD)
                OR (    (Recinfo.FACTORING_RATE_PERIOD IS NULL)
                    AND (X_FACTORING_RATE_PERIOD IS NULL)))
           AND (   (Recinfo.FACTORING_AMOUNT =  X_FACTORING_AMOUNT)
                OR (    (Recinfo.FACTORING_AMOUNT IS NULL)
                    AND (X_FACTORING_AMOUNT IS NULL)))
           AND (   (Recinfo.FACTORING_DATE =  X_FACTORING_DATE)
                OR (    (Recinfo.FACTORING_DATE IS NULL)
                    AND (X_FACTORING_DATE IS NULL)))
           AND (   (Recinfo.CANCELLATION_DATE =  X_CANCELLATION_DATE)
                OR (    (Recinfo.CANCELLATION_DATE IS NULL)
                    AND (X_CANCELLATION_DATE IS NULL)))
           AND (   (Recinfo.BANK_INSTRUCTION_CODE1 =  X_BANK_INSTRUCTION_CODE1)
                OR (    (Recinfo.BANK_INSTRUCTION_CODE1 IS NULL)
                    AND (X_BANK_INSTRUCTION_CODE1 IS NULL)))
           AND (   (Recinfo.BANK_INSTRUCTION_CODE2 =  X_BANK_INSTRUCTION_CODE2)
                OR (    (Recinfo.BANK_INSTRUCTION_CODE2 IS NULL)
                    AND (X_BANK_INSTRUCTION_CODE2 IS NULL)))
           AND (   (Recinfo.NUM_DAYS_INSTRUCTION =  X_NUM_DAYS_INSTRUCTION)
                OR (    (Recinfo.NUM_DAYS_INSTRUCTION IS NULL)
                    AND (X_NUM_DAYS_INSTRUCTION IS NULL)))
           AND (   (Recinfo.BANK_CHARGE_AMOUNT =  X_BANK_CHARGE_AMOUNT)
                OR (    (Recinfo.BANK_CHARGE_AMOUNT IS NULL)
                    AND (X_BANK_CHARGE_AMOUNT IS NULL)))
           AND (   (Recinfo.CASH_CCID =  X_CASH_CCID)
                OR (    (Recinfo.CASH_CCID IS NULL)
                    AND (X_CASH_CCID IS NULL)))
           AND (   (Recinfo.BANK_CHARGES_CCID =  X_BANK_CHARGES_CCID)
                OR (    (Recinfo.BANK_CHARGES_CCID IS NULL)
                    AND (X_BANK_CHARGES_CCID IS NULL)))
           AND (   (Recinfo.COLL_ENDORSEMENTS_CCID =  X_COLL_ENDORSEMENTS_CCID)
                OR (    (Recinfo.COLL_ENDORSEMENTS_CCID IS NULL)
                    AND (X_COLL_ENDORSEMENTS_CCID IS NULL)))
           AND (   (Recinfo.BILLS_COLLECTION_CCID =  X_BILLS_COLLECTION_CCID)
                OR (    (Recinfo.BILLS_COLLECTION_CCID IS NULL)
                    AND (X_BILLS_COLLECTION_CCID IS NULL)))
           AND (   (Recinfo.CALCULATED_INTEREST_CCID =  X_CALCULATED_INTEREST_CCID)
                OR (    (Recinfo.CALCULATED_INTEREST_CCID IS NULL)
                    AND (X_CALCULATED_INTEREST_CCID IS NULL)))
           AND (   (Recinfo.INTEREST_WRITEOFF_CCID =  X_INTEREST_WRITEOFF_CCID)
                OR (    (Recinfo.INTEREST_WRITEOFF_CCID IS NULL)
                    AND (X_INTEREST_WRITEOFF_CCID IS NULL)))
           AND (   (Recinfo.ABATEMENT_WRITEOFF_CCID =  X_ABATEMENT_WRITEOFF_CCID)
                OR (    (Recinfo.ABATEMENT_WRITEOFF_CCID IS NULL)
                    AND (X_ABATEMENT_WRITEOFF_CCID IS NULL)))
           AND (   (Recinfo.ABATEMENT_REVENUE_CCID =  X_ABATEMENT_REVENUE_CCID)
                OR (    (Recinfo.ABATEMENT_REVENUE_CCID IS NULL)
                    AND (X_ABATEMENT_REVENUE_CCID IS NULL)))
           AND (   (Recinfo.INTEREST_REVENUE_CCID =  X_INTEREST_REVENUE_CCID)
                OR (    (Recinfo.INTEREST_REVENUE_CCID IS NULL)
                    AND (X_INTEREST_REVENUE_CCID IS NULL)))
           AND (   (Recinfo.CALCULATED_INTEREST_RECTRX_ID =  X_CALCULATED_INT_RECTRX_ID)
                OR (    (Recinfo.CALCULATED_INTEREST_RECTRX_ID IS NULL)
                    AND (X_CALCULATED_INT_RECTRX_ID IS NULL)))
           AND (   (Recinfo.INTEREST_WRITEOFF_RECTRX_ID =  X_INTEREST_WRITEOFF_RECTRX_ID)
                OR (    (Recinfo.INTEREST_WRITEOFF_RECTRX_ID IS NULL)
                    AND (X_INTEREST_WRITEOFF_RECTRX_ID IS NULL)))
           AND (   (Recinfo.INTEREST_REVENUE_RECTRX_ID =  X_INTEREST_REVENUE_RECTRX_ID)
                OR (    (Recinfo.INTEREST_REVENUE_RECTRX_ID IS NULL)
                    AND (X_INTEREST_REVENUE_RECTRX_ID IS NULL)))
           AND (   (Recinfo.ABATEMENT_WRITEOFF_RECTRX_ID =  X_ABATEMENT_WRITEOFF_RECTRX_ID)
                OR (    (Recinfo.ABATEMENT_WRITEOFF_RECTRX_ID IS NULL)
                    AND (X_ABATEMENT_WRITEOFF_RECTRX_ID IS NULL)))
           AND (   (Recinfo.ABATE_REVENUE_RECTRX_ID =  X_ABATE_REVENUE_RECTRX_ID)
                OR (    (Recinfo.ABATE_REVENUE_RECTRX_ID IS NULL)
                    AND (X_ABATE_REVENUE_RECTRX_ID IS NULL)))
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
             FND_MESSAGE.SET_TOKEN('PARAMETERS','document_id = ' ||
                                    X_document_id );
             FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
	 END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

  END Lock_Row;

  PROCEDURE Delete_Row (X_Rowid 	        	VARCHAR2,
		        X_calling_sequence	IN	VARCHAR2
  ) IS
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);
  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'JL_BR_AR_COLLECTION_DOC2_PKG.DELETE_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Delete from JL_BR_AR_COLLECTION_DOCS';
    DELETE FROM JL_BR_AR_COLLECTION_DOCS
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


END JL_BR_AR_COLLECTION_DOC2_PKG;

/
