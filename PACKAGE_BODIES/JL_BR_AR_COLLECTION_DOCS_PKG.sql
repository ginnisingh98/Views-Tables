--------------------------------------------------------
--  DDL for Package Body JL_BR_AR_COLLECTION_DOCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AR_COLLECTION_DOCS_PKG" as
/* $Header: jlbrrcdb.pls 120.5 2003/09/15 21:52:25 vsidhart ship $ */

  PROCEDURE Insert_Row ( X_Rowid                             IN OUT NOCOPY VARCHAR2,

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
			 X_BANK_ACCT_USE_ID                         NUMBER ,
			 X_PREVIOUS_DOC_STATUS                      VARCHAR2 ,
			 X_OUR_NUMBER                               VARCHAR2 ,
			 X_BANK_USE                                 VARCHAR2 ,
			 X_COLLECTOR_BANK_PARTY_ID                  NUMBER ,
			 X_COLLECTOR_BRANCH_PARTY_ID                NUMBER ,
			 X_FACTORING_RATE                           NUMBER ,
			 X_FACTORING_RATE_PERIOD                    NUMBER ,
			 X_FACTORING_AMOUNT                         NUMBER ,
			 X_FACTORING_DATE                           DATE ,
			 X_CANCELLATION_DATE                        DATE ,
			 X_BANK_INSTRUCTION_CODE1                   NUMBER ,
			 X_BANK_INSTRUCTION_CODE2                   NUMBER ,
			 X_NUM_DAYS_INSTRUCTION                     NUMBER ,
			 X_BANK_CHARGE_AMOUNT                       NUMBER ,
			 X_CASH_CCID                                NUMBER ,
			 X_BANK_CHARGES_CCID                        NUMBER ,
			 X_COLL_ENDORSEMENTS_CCID                   NUMBER ,
			 X_BILLS_COLLECTION_CCID                    NUMBER ,
			 X_CALCULATED_INTEREST_CCID                 NUMBER ,
			 X_INTEREST_WRITEOFF_CCID                   NUMBER ,
			 X_ABATEMENT_WRITEOFF_CCID                  NUMBER ,
			 X_ABATEMENT_REVENUE_CCID                   NUMBER ,
			 X_INTEREST_REVENUE_CCID                    NUMBER ,
			 X_CALCULATED_INT_RECTRX_ID                 NUMBER ,
			 X_INTEREST_WRITEOFF_RECTRX_ID              NUMBER ,
			 X_INTEREST_REVENUE_RECTRX_ID               NUMBER ,
			 X_ABATEMENT_WRITEOFF_RECTRX_ID             NUMBER ,
			 X_ABATE_REVENUE_RECTRX_ID                  NUMBER ,
			 X_ATTRIBUTE_CATEGORY                       VARCHAR2 ,
			 X_ATTRIBUTE1                               VARCHAR2 ,
			 X_ATTRIBUTE2                               VARCHAR2 ,
			 X_ATTRIBUTE3                               VARCHAR2 ,
			 X_ATTRIBUTE4                               VARCHAR2 ,
			 X_ATTRIBUTE5                               VARCHAR2 ,
			 X_ATTRIBUTE6                               VARCHAR2 ,
			 X_ATTRIBUTE7                               VARCHAR2 ,
			 X_ATTRIBUTE8                               VARCHAR2 ,
			 X_ATTRIBUTE9                               VARCHAR2 ,
			 X_ATTRIBUTE10                              VARCHAR2 ,
			 X_ATTRIBUTE11                              VARCHAR2 ,
			 X_ATTRIBUTE12                              VARCHAR2 ,
			 X_ATTRIBUTE13                              VARCHAR2 ,
			 X_ATTRIBUTE14                              VARCHAR2 ,
			 X_ATTRIBUTE15                              VARCHAR2 ,
			 X_LAST_UPDATE_DATE                         DATE,
			 X_LAST_UPDATED_BY                          NUMBER,
			 X_CREATION_DATE                            DATE,
			 X_CREATED_BY                               NUMBER,
			 X_LAST_UPDATE_LOGIN                        NUMBER,

		         X_calling_sequence		            VARCHAR2,
                         X_ORG_ID                                   NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM JL_BR_AR_COLLECTION_DOCS
                 WHERE document_id = X_document_id;
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

   BEGIN
--     Update the calling sequence
--
       current_calling_sequence := 'JL_BR_AR_COLLECTION_DOCS_PKG.INSERT_ROW<-' ||
                                    X_calling_sequence;

       debug_info := 'Insert into JL_BR_AR_COLLECTION_DOCS';
       INSERT INTO JL_BR_AR_COLLECTION_DOCS
              (
		 DOCUMENT_ID,
		 BORDERO_ID,
		 PAYMENT_SCHEDULE_ID,
		 DOCUMENT_STATUS,
		 ORIGIN_TYPE,
		 DUE_DATE,
		 SELECTION_DATE,
		 PORTFOLIO_CODE,
		 BATCH_SOURCE_ID,
		 RECEIPT_METHOD_ID,
		 CUSTOMER_TRX_ID,
		 TERMS_SEQUENCE_NUMBER,
		 DOCUMENT_TYPE,
		 BANK_ACCT_USE_ID,
		 PREVIOUS_DOC_STATUS,
		 OUR_NUMBER,
		 BANK_USE,
		 COLLECTOR_BANK_PARTY_ID,
		 COLLECTOR_BRANCH_PARTY_ID,
		 FACTORING_RATE,
		 FACTORING_RATE_PERIOD,
		 FACTORING_AMOUNT,
		 FACTORING_DATE,
		 CANCELLATION_DATE,
		 BANK_INSTRUCTION_CODE1,
		 BANK_INSTRUCTION_CODE2,
		 NUM_DAYS_INSTRUCTION,
		 BANK_CHARGE_AMOUNT,
		 CASH_CCID,
		 BANK_CHARGES_CCID,
		 COLL_ENDORSEMENTS_CCID,
		 BILLS_COLLECTION_CCID,
		 CALCULATED_INTEREST_CCID,
		 INTEREST_WRITEOFF_CCID,
		 ABATEMENT_WRITEOFF_CCID,
		 ABATEMENT_REVENUE_CCID,
		 INTEREST_REVENUE_CCID,
		 CALCULATED_INTEREST_RECTRX_ID,
		 INTEREST_WRITEOFF_RECTRX_ID,
		 INTEREST_REVENUE_RECTRX_ID,
		 ABATEMENT_WRITEOFF_RECTRX_ID,
		 ABATE_REVENUE_RECTRX_ID,
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
		 LAST_UPDATE_DATE,
		 LAST_UPDATED_BY,
		 CREATION_DATE,
		 CREATED_BY,
		 LAST_UPDATE_LOGIN,
                 ORG_ID
              )
       VALUES (
		 X_DOCUMENT_ID,
		 X_BORDERO_ID,
		 X_PAYMENT_SCHEDULE_ID,
		 X_DOCUMENT_STATUS,
		 X_ORIGIN_TYPE,
		 X_DUE_DATE,
		 X_SELECTION_DATE,
		 X_PORTFOLIO_CODE,
		 X_BATCH_SOURCE_ID,
		 X_RECEIPT_METHOD_ID,
		 X_CUSTOMER_TRX_ID,
		 X_TERMS_SEQUENCE_NUMBER,
		 X_DOCUMENT_TYPE,
		 X_BANK_ACCT_USE_ID,
		 X_PREVIOUS_DOC_STATUS,
		 X_OUR_NUMBER,
		 X_BANK_USE,
		 X_COLLECTOR_BANK_PARTY_ID,
		 X_COLLECTOR_BRANCH_PARTY_ID,
		 X_FACTORING_RATE,
		 X_FACTORING_RATE_PERIOD,
		 X_FACTORING_AMOUNT,
		 X_FACTORING_DATE,
		 X_CANCELLATION_DATE,
		 X_BANK_INSTRUCTION_CODE1,
		 X_BANK_INSTRUCTION_CODE2,
		 X_NUM_DAYS_INSTRUCTION,
		 X_BANK_CHARGE_AMOUNT,
		 X_CASH_CCID,
		 X_BANK_CHARGES_CCID,
		 X_COLL_ENDORSEMENTS_CCID,
		 X_BILLS_COLLECTION_CCID,
		 X_CALCULATED_INTEREST_CCID,
		 X_INTEREST_WRITEOFF_CCID,
		 X_ABATEMENT_WRITEOFF_CCID,
		 X_ABATEMENT_REVENUE_CCID,
		 X_INTEREST_REVENUE_CCID,
		 X_CALCULATED_INT_RECTRX_ID,
		 X_INTEREST_WRITEOFF_RECTRX_ID,
		 X_INTEREST_REVENUE_RECTRX_ID,
		 X_ABATEMENT_WRITEOFF_RECTRX_ID,
		 X_ABATE_REVENUE_RECTRX_ID,
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
		 X_LAST_UPDATE_DATE,
		 X_LAST_UPDATED_BY,
		 X_CREATION_DATE,
		 X_CREATED_BY,
		 X_LAST_UPDATE_LOGIN,
                 X_ORG_ID
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
              FND_MESSAGE.SET_TOKEN('PARAMETERS','document_id = ' ||
                                    X_document_id );
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;

  PROCEDURE Update_Row ( X_Rowid                                    VARCHAR2,

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
			 X_BANK_ACCT_USE_ID                         NUMBER ,
			 X_PREVIOUS_DOC_STATUS                      VARCHAR2 ,
			 X_OUR_NUMBER                               VARCHAR2 ,
			 X_BANK_USE                                 VARCHAR2 ,
			 X_COLLECTOR_BANK_PARTY_ID                  NUMBER ,
			 X_COLLECTOR_BRANCH_PARTY_ID                NUMBER ,
			 X_FACTORING_RATE                           NUMBER ,
			 X_FACTORING_RATE_PERIOD                    NUMBER ,
			 X_FACTORING_AMOUNT                         NUMBER ,
			 X_FACTORING_DATE                           DATE ,
			 X_CANCELLATION_DATE                        DATE ,
			 X_BANK_INSTRUCTION_CODE1                   NUMBER ,
			 X_BANK_INSTRUCTION_CODE2                   NUMBER ,
			 X_NUM_DAYS_INSTRUCTION                     NUMBER ,
			 X_BANK_CHARGE_AMOUNT                       NUMBER ,
			 X_CASH_CCID                                NUMBER ,
			 X_BANK_CHARGES_CCID                        NUMBER ,
			 X_COLL_ENDORSEMENTS_CCID                   NUMBER ,
			 X_BILLS_COLLECTION_CCID                    NUMBER ,
			 X_CALCULATED_INTEREST_CCID                 NUMBER ,
			 X_INTEREST_WRITEOFF_CCID                   NUMBER ,
			 X_ABATEMENT_WRITEOFF_CCID                  NUMBER ,
			 X_ABATEMENT_REVENUE_CCID                   NUMBER ,
			 X_INTEREST_REVENUE_CCID                    NUMBER ,
			 X_CALCULATED_INT_RECTRX_ID                 NUMBER ,
			 X_INTEREST_WRITEOFF_RECTRX_ID              NUMBER ,
			 X_INTEREST_REVENUE_RECTRX_ID               NUMBER ,
			 X_ABATEMENT_WRITEOFF_RECTRX_ID             NUMBER ,
			 X_ABATE_REVENUE_RECTRX_ID                  NUMBER ,
			 X_ATTRIBUTE_CATEGORY                       VARCHAR2 ,
			 X_ATTRIBUTE1                               VARCHAR2 ,
			 X_ATTRIBUTE2                               VARCHAR2 ,
			 X_ATTRIBUTE3                               VARCHAR2 ,
			 X_ATTRIBUTE4                               VARCHAR2 ,
			 X_ATTRIBUTE5                               VARCHAR2 ,
			 X_ATTRIBUTE6                               VARCHAR2 ,
			 X_ATTRIBUTE7                               VARCHAR2 ,
			 X_ATTRIBUTE8                               VARCHAR2 ,
			 X_ATTRIBUTE9                               VARCHAR2 ,
			 X_ATTRIBUTE10                              VARCHAR2 ,
			 X_ATTRIBUTE11                              VARCHAR2 ,
			 X_ATTRIBUTE12                              VARCHAR2 ,
			 X_ATTRIBUTE13                              VARCHAR2 ,
			 X_ATTRIBUTE14                              VARCHAR2 ,
			 X_ATTRIBUTE15                              VARCHAR2 ,
			 X_LAST_UPDATE_DATE                         DATE,
			 X_LAST_UPDATED_BY                          NUMBER,
			 X_CREATION_DATE                            DATE,
			 X_CREATED_BY                               NUMBER,
			 X_LAST_UPDATE_LOGIN                        NUMBER,

		         X_calling_sequence		            VARCHAR2
  ) IS
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);
  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'JL_BR_AR_COLLECTION_DOCS_PKG.UPDATE_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Update JL_BR_AR_COLLECTION_DOCS';
    UPDATE JL_BR_AR_COLLECTION_DOCS
    SET
	 DOCUMENT_ID                    =	 X_DOCUMENT_ID                      ,
	 BORDERO_ID                     =	 X_BORDERO_ID                       ,
	 PAYMENT_SCHEDULE_ID            =	 X_PAYMENT_SCHEDULE_ID              ,
	 DOCUMENT_STATUS                =	 X_DOCUMENT_STATUS                  ,
	 ORIGIN_TYPE                    =	 X_ORIGIN_TYPE                      ,
	 DUE_DATE                       =	 X_DUE_DATE                         ,
	 SELECTION_DATE                 =	 X_SELECTION_DATE                   ,
	 PORTFOLIO_CODE                 =	 X_PORTFOLIO_CODE                   ,
	 BATCH_SOURCE_ID                =	 X_BATCH_SOURCE_ID                  ,
	 RECEIPT_METHOD_ID              =	 X_RECEIPT_METHOD_ID                ,
	 CUSTOMER_TRX_ID                =	 X_CUSTOMER_TRX_ID                  ,
	 TERMS_SEQUENCE_NUMBER          =	 X_TERMS_SEQUENCE_NUMBER            ,
	 DOCUMENT_TYPE                  =	 X_DOCUMENT_TYPE                    ,
         BANK_ACCT_USE_ID               =        X_BANK_ACCT_USE_ID                 ,
	 PREVIOUS_DOC_STATUS            =	 X_PREVIOUS_DOC_STATUS              ,
	 OUR_NUMBER                     =	 X_OUR_NUMBER                       ,
	 BANK_USE                       =	 X_BANK_USE                         ,
	 COLLECTOR_BANK_PARTY_ID        =	 X_COLLECTOR_BANK_PARTY_ID          ,
	 COLLECTOR_BRANCH_PARTY_ID      =	 X_COLLECTOR_BRANCH_PARTY_ID        ,
	 FACTORING_RATE                 =	 X_FACTORING_RATE                   ,
	 FACTORING_RATE_PERIOD          =	 X_FACTORING_RATE_PERIOD            ,
	 FACTORING_AMOUNT               =	 X_FACTORING_AMOUNT                 ,
	 FACTORING_DATE                 =	 X_FACTORING_DATE                   ,
	 CANCELLATION_DATE              =	 X_CANCELLATION_DATE                ,
	 BANK_INSTRUCTION_CODE1         =	 X_BANK_INSTRUCTION_CODE1           ,
	 BANK_INSTRUCTION_CODE2         =	 X_BANK_INSTRUCTION_CODE2           ,
	 NUM_DAYS_INSTRUCTION           =	 X_NUM_DAYS_INSTRUCTION             ,
	 BANK_CHARGE_AMOUNT             =	 X_BANK_CHARGE_AMOUNT               ,
	 CASH_CCID                      =	 X_CASH_CCID                        ,
	 BANK_CHARGES_CCID              =	 X_BANK_CHARGES_CCID                ,
	 COLL_ENDORSEMENTS_CCID         =	 X_COLL_ENDORSEMENTS_CCID           ,
	 BILLS_COLLECTION_CCID          =	 X_BILLS_COLLECTION_CCID            ,
	 CALCULATED_INTEREST_CCID       =	 X_CALCULATED_INTEREST_CCID         ,
	 INTEREST_WRITEOFF_CCID         =	 X_INTEREST_WRITEOFF_CCID           ,
	 ABATEMENT_WRITEOFF_CCID        =	 X_ABATEMENT_WRITEOFF_CCID          ,
	 ABATEMENT_REVENUE_CCID         =	 X_ABATEMENT_REVENUE_CCID           ,
	 INTEREST_REVENUE_CCID          =	 X_INTEREST_REVENUE_CCID            ,
	 CALCULATED_INTEREST_RECTRX_ID  =	 X_CALCULATED_INT_RECTRX_ID         ,
	 INTEREST_WRITEOFF_RECTRX_ID    =	 X_INTEREST_WRITEOFF_RECTRX_ID      ,
	 INTEREST_REVENUE_RECTRX_ID     =	 X_INTEREST_REVENUE_RECTRX_ID       ,
	 ABATEMENT_WRITEOFF_RECTRX_ID   =	 X_ABATEMENT_WRITEOFF_RECTRX_ID     ,
	 ABATE_REVENUE_RECTRX_ID        =	 X_ABATE_REVENUE_RECTRX_ID          ,
	 ATTRIBUTE_CATEGORY             =	 X_ATTRIBUTE_CATEGORY               ,
	 ATTRIBUTE1                     =	 X_ATTRIBUTE1                       ,
	 ATTRIBUTE2                     =	 X_ATTRIBUTE2                       ,
	 ATTRIBUTE3                     =	 X_ATTRIBUTE3                       ,
	 ATTRIBUTE4                     =	 X_ATTRIBUTE4                       ,
	 ATTRIBUTE5                     =	 X_ATTRIBUTE5                       ,
	 ATTRIBUTE6                     =	 X_ATTRIBUTE6                       ,
	 ATTRIBUTE7                     =	 X_ATTRIBUTE7                       ,
	 ATTRIBUTE8                     =	 X_ATTRIBUTE8                       ,
	 ATTRIBUTE9                     =	 X_ATTRIBUTE9                       ,
	 ATTRIBUTE10                    =	 X_ATTRIBUTE10                      ,
	 ATTRIBUTE11                    =	 X_ATTRIBUTE11                      ,
	 ATTRIBUTE12                    =	 X_ATTRIBUTE12                      ,
	 ATTRIBUTE13                    =	 X_ATTRIBUTE13                      ,
	 ATTRIBUTE14                    =	 X_ATTRIBUTE14                      ,
	 ATTRIBUTE15                    =	 X_ATTRIBUTE15                      ,
	 LAST_UPDATE_DATE               =	 X_LAST_UPDATE_DATE                 ,
	 LAST_UPDATED_BY                =	 X_LAST_UPDATED_BY                  ,
	 CREATION_DATE                  =	 X_CREATION_DATE                    ,
	 CREATED_BY                     =	 X_CREATED_BY                       ,
	 LAST_UPDATE_LOGIN              =	 X_LAST_UPDATE_LOGIN
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
             FND_MESSAGE.SET_TOKEN('PARAMETERS','document_id = ' ||
                                    X_document_id );
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Update_Row;

END JL_BR_AR_COLLECTION_DOCS_PKG;

/
