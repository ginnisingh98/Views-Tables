--------------------------------------------------------
--  DDL for Package Body JL_BR_AR_REC_MET_ACCTS_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AR_REC_MET_ACCTS_EXT_PKG" as
/* $Header: jlbrrdpb.pls 120.6 2005/06/22 04:25:15 appradha ship $ */

  PROCEDURE Insert_Row ( X_Rowid                             IN OUT NOCOPY VARCHAR2,

			 X_BANK_ACCT_USE_ID                         NUMBER,
			 X_RECEIPT_METHOD_ID                        NUMBER,
			 X_BANK_CHARGES_CCID                        NUMBER ,
			 X_COLL_ENDORSEMENT_CCID                    NUMBER ,
			 X_BILLS_COLLECTION_CCID                    NUMBER ,
			 X_OTHER_CREDITS_CCID                       NUMBER ,
			 X_FACTORING_DOCS_CCID                      NUMBER ,
                         X_BILLS_DISCOUNT_CCID                      NUMBER ,
                         X_DISC_ENDORSEMENT_CCID                    NUMBER ,
                         X_FACTORING_CHARGES_CCID                   NUMBER ,
                         X_DISCOUNTED_BILLS_CCID                    NUMBER ,
			 X_PORTFOLIO_CODE                           NUMBER ,
			 X_MIN_DOCUMENT_AMOUNT                      NUMBER ,
			 X_MAX_DOCUMENT_AMOUNT                      NUMBER ,
			 X_MIN_REMITTANCE_AMOUNT                    NUMBER ,
			 X_MAX_REMITTANCE_AMOUNT                    NUMBER ,
			 X_BANK_INSTRUCTION_CODE1                   NUMBER ,
			 X_BANK_INSTRUCTION_CODE2                   NUMBER ,
			 X_BANK_CHARGE_AMOUNT                       NUMBER ,
			 X_FACTORING_RATE                           NUMBER ,
			 X_FACTORING_RATE_PERIOD                    NUMBER ,
			 X_BATCH_SOURCE_ID                          NUMBER ,
			 X_CALCULATED_INTEREST_CCID                 NUMBER ,
			 X_INTEREST_WRITEOFF_CCID                   NUMBER ,
			 X_FACTORING_INTEREST_CCID                  NUMBER ,
			 X_ABATEMENT_WRITEOFF_CCID                  NUMBER ,
			 X_ABATEMENT_REVENUE_CCID                   NUMBER ,
			 X_INTEREST_REVENUE_CCID                    NUMBER ,
			 X_CALC_INTEREST_RECTRX_ID                  NUMBER ,
			 X_INTEREST_WRITEOFF_RECTRX_ID              NUMBER ,
			 X_INTEREST_REVENUE_RECTRX_ID               NUMBER ,
			 X_ABATEMENT_WRITEOFF_RECTRX_ID             NUMBER ,
			 X_ABATEMENT_REVENUE_RECTRX_ID              NUMBER ,
			 X_WRITEOFF_PERC_TOLERANCE                  NUMBER ,
			 X_WRITEOFF_AMOUNT_TOLERANCE                NUMBER ,
			 X_GL_DATE_BANK_RETURN                      VARCHAR2 ,
			 X_FLOATING                                 NUMBER ,
			 X_LAST_UPDATE_DATE                         DATE,
			 X_LAST_UPDATED_BY                          NUMBER,
			 X_CREATION_DATE                            DATE,
			 X_CREATED_BY                               NUMBER,
			 X_LAST_UPDATE_LOGIN                        NUMBER,
                         X_COLL_REMITTANCE_MEDIA                    VARCHAR2,
                         X_COLL_FORMAT_PGM_ID                       NUMBER,
                         X_FACTOR_REMITTANCE_MEDIA                  VARCHAR2,
                         X_FACTOR_FORMAT_PGM_ID                     NUMBER,
                         X_OCC_REP_FORMAT_PGM_ID                    NUMBER,
                         X_OCC_FILE_FORMAT_PGM_ID                   NUMBER,
                         X_MAX_COLLECTION_DOCS                      NUMBER,
         	         X_calling_sequence		            VARCHAR2,
			 X_ORG_ID                                   NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM JL_BR_AR_REC_MET_ACCTS_EXT
                 WHERE receipt_method_id = X_receipt_method_id
                   AND bank_acct_use_id   = X_bank_acct_use_id;
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

   BEGIN
--     Update the calling sequence
--
       current_calling_sequence := 'JL_BR_AR_REC_MET_ACCTS_EXT_PKG.INSERT_ROW<-' ||
                                    X_calling_sequence;

       debug_info := 'Insert into JL_BR_AR_REC_MET_ACCTS_EXT';
       INSERT INTO JL_BR_AR_REC_MET_ACCTS_EXT
              (
		 BANK_ACCT_USE_ID,
		 RECEIPT_METHOD_ID,
		 BANK_CHARGES_CCID,
		 COLL_ENDORSEMENT_CCID,
		 BILLS_COLLECTION_CCID,
		 OTHER_CREDITS_CCID,
		 FACTORING_DOCS_CCID,
                 BILLS_DISCOUNT_CCID,
                 DISC_ENDORSEMENT_CCID,
                 DISCOUNTED_BILLS_CCID,
		 PORTFOLIO_CODE,
		 MIN_DOCUMENT_AMOUNT,
		 MAX_DOCUMENT_AMOUNT,
		 MIN_REMITTANCE_AMOUNT,
		 MAX_REMITTANCE_AMOUNT,
		 BANK_INSTRUCTION_CODE1,
		 BANK_INSTRUCTION_CODE2,
		 BANK_CHARGE_AMOUNT,
		 FACTORING_RATE,
		 FACTORING_RATE_PERIOD,
		 BATCH_SOURCE_ID,
		 CALCULATED_INTEREST_CCID,
		 INTEREST_WRITEOFF_CCID,
		 FACTORING_INTEREST_CCID,
		 ABATEMENT_WRITEOFF_CCID,
		 ABATEMENT_REVENUE_CCID,
		 INTEREST_REVENUE_CCID,
		 CALCULATED_INTEREST_RECTRX_ID,
		 INTEREST_WRITEOFF_RECTRX_ID,
		 INTEREST_REVENUE_RECTRX_ID,
		 ABATEMENT_WRITEOFF_RECTRX_ID,
		 ABATEMENT_REVENUE_RECTRX_ID,
		 WRITEOFF_PERC_TOLERANCE,
		 WRITEOFF_AMOUNT_TOLERANCE,
		 GL_DATE_BANK_RETURN,
		 FLOATING,
		 LAST_UPDATE_DATE,
		 LAST_UPDATED_BY,
		 CREATION_DATE,
		 CREATED_BY,
		 LAST_UPDATE_LOGIN,
		 COLL_REMITTANCE_MEDIA,
                 COLL_FORMAT_PGM_ID,
                 FACTOR_REMITTANCE_MEDIA,
                 FACTOR_FORMAT_PGM_ID,
                 OCC_REP_FORMAT_PGM_ID,
                 OCC_FILE_FORMAT_PGM_ID,
                 MAX_COLLECTION_DOCS,
                 ORG_ID
              )
       VALUES (
		 X_BANK_ACCT_USE_ID,
		 X_RECEIPT_METHOD_ID,
		 X_BANK_CHARGES_CCID,
		 X_COLL_ENDORSEMENT_CCID,
		 X_BILLS_COLLECTION_CCID,
		 X_OTHER_CREDITS_CCID,
		 X_FACTORING_DOCS_CCID,
                 X_BILLS_DISCOUNT_CCID,
                 X_DISC_ENDORSEMENT_CCID,
                 X_DISCOUNTED_BILLS_CCID,
		 X_PORTFOLIO_CODE,
		 X_MIN_DOCUMENT_AMOUNT,
		 X_MAX_DOCUMENT_AMOUNT,
		 X_MIN_REMITTANCE_AMOUNT,
		 X_MAX_REMITTANCE_AMOUNT,
		 X_BANK_INSTRUCTION_CODE1,
		 X_BANK_INSTRUCTION_CODE2,
		 X_BANK_CHARGE_AMOUNT,
		 X_FACTORING_RATE,
		 X_FACTORING_RATE_PERIOD,
		 X_BATCH_SOURCE_ID,
		 X_CALCULATED_INTEREST_CCID,
		 X_INTEREST_WRITEOFF_CCID,
		 X_FACTORING_INTEREST_CCID,
		 X_ABATEMENT_WRITEOFF_CCID,
		 X_ABATEMENT_REVENUE_CCID,
		 X_INTEREST_REVENUE_CCID,
		 X_CALC_INTEREST_RECTRX_ID,
		 X_INTEREST_WRITEOFF_RECTRX_ID,
		 X_INTEREST_REVENUE_RECTRX_ID,
		 X_ABATEMENT_WRITEOFF_RECTRX_ID,
		 X_ABATEMENT_REVENUE_RECTRX_ID,
		 X_WRITEOFF_PERC_TOLERANCE,
		 X_WRITEOFF_AMOUNT_TOLERANCE,
		 X_GL_DATE_BANK_RETURN,
		 X_FLOATING,
		 X_LAST_UPDATE_DATE,
		 X_LAST_UPDATED_BY,
		 X_CREATION_DATE,
		 X_CREATED_BY,
		 X_LAST_UPDATE_LOGIN,
		 X_COLL_REMITTANCE_MEDIA,
                 X_COLL_FORMAT_PGM_ID,
                 X_FACTOR_REMITTANCE_MEDIA,
                 X_FACTOR_FORMAT_PGM_ID,
                 X_OCC_REP_FORMAT_PGM_ID,
                 X_OCC_FILE_FORMAT_PGM_ID,
                 X_MAX_COLLECTION_DOCS,
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
              FND_MESSAGE.SET_TOKEN('PARAMETERS','receipt_method_id = ' ||
                                    X_receipt_method_id ||
                                    'bank_acct_use_id = ' ||
                                    X_bank_acct_use_id );
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;


  PROCEDURE Lock_Row (   X_Rowid                                    VARCHAR2,

			 X_BANK_ACCT_USE_ID                         NUMBER,
			 X_RECEIPT_METHOD_ID                        NUMBER,
			 X_BANK_CHARGES_CCID                        NUMBER ,
			 X_COLL_ENDORSEMENT_CCID                    NUMBER ,
			 X_BILLS_COLLECTION_CCID                    NUMBER ,
			 X_OTHER_CREDITS_CCID                       NUMBER ,
			 X_FACTORING_DOCS_CCID                      NUMBER ,
                         X_BILLS_DISCOUNT_CCID                      NUMBER,
                         X_DISC_ENDORSEMENT_CCID                    NUMBER,
                         X_FACTORING_CHARGES_CCID                   NUMBER ,
                         X_DISCOUNTED_BILLS_CCID                    NUMBER,
			 X_PORTFOLIO_CODE                           NUMBER ,
			 X_MIN_DOCUMENT_AMOUNT                      NUMBER ,
			 X_MAX_DOCUMENT_AMOUNT                      NUMBER ,
			 X_MIN_REMITTANCE_AMOUNT                    NUMBER ,
			 X_MAX_REMITTANCE_AMOUNT                    NUMBER ,
			 X_BANK_INSTRUCTION_CODE1                   NUMBER ,
			 X_BANK_INSTRUCTION_CODE2                   NUMBER ,
			 X_BANK_CHARGE_AMOUNT                       NUMBER ,
			 X_FACTORING_RATE                           NUMBER ,
			 X_FACTORING_RATE_PERIOD                    NUMBER ,
			 X_BATCH_SOURCE_ID                          NUMBER ,
			 X_CALCULATED_INTEREST_CCID                 NUMBER ,
			 X_INTEREST_WRITEOFF_CCID                   NUMBER ,
			 X_FACTORING_INTEREST_CCID                  NUMBER ,
			 X_ABATEMENT_WRITEOFF_CCID                  NUMBER ,
			 X_ABATEMENT_REVENUE_CCID                   NUMBER ,
			 X_INTEREST_REVENUE_CCID                    NUMBER ,
			 X_CALC_INTEREST_RECTRX_ID                  NUMBER ,
			 X_INTEREST_WRITEOFF_RECTRX_ID              NUMBER ,
			 X_INTEREST_REVENUE_RECTRX_ID               NUMBER ,
			 X_ABATEMENT_WRITEOFF_RECTRX_ID             NUMBER ,
			 X_ABATEMENT_REVENUE_RECTRX_ID              NUMBER ,
			 X_WRITEOFF_PERC_TOLERANCE                  NUMBER ,
			 X_WRITEOFF_AMOUNT_TOLERANCE                NUMBER ,
			 X_GL_DATE_BANK_RETURN                      VARCHAR2 ,
			 X_FLOATING                                 NUMBER ,
			 X_LAST_UPDATE_DATE                         DATE,
			 X_LAST_UPDATED_BY                          NUMBER,
			 X_CREATION_DATE                            DATE,
			 X_CREATED_BY                               NUMBER,
			 X_LAST_UPDATE_LOGIN                        NUMBER,
                         X_COLL_REMITTANCE_MEDIA                    VARCHAR2,
                         X_COLL_FORMAT_PGM_ID                       NUMBER,
                         X_FACTOR_REMITTANCE_MEDIA                  VARCHAR2,
                         X_FACTOR_FORMAT_PGM_ID                     NUMBER,
                         X_OCC_REP_FORMAT_PGM_ID                    NUMBER,
                         X_OCC_FILE_FORMAT_PGM_ID                   NUMBER,
                         X_MAX_COLLECTION_DOCS                      NUMBER,
		         X_calling_sequence		            VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   JL_BR_AR_REC_MET_ACCTS_EXT
        WHERE  rowid = X_Rowid
        FOR UPDATE of receipt_method_id NOWAIT;
    Recinfo C%ROWTYPE;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'JL_BR_AR_REC_MET_ACCTS_EXT_PKG.LOCK_ROW<-' ||
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
           (Recinfo.receipt_method_id =  X_receipt_method_id)
           AND (Recinfo.bank_acct_use_id =  X_bank_acct_use_id)
           AND (   (Recinfo.BANK_CHARGES_CCID =  X_BANK_CHARGES_CCID)
                OR (    (Recinfo.BANK_CHARGES_CCID IS NULL)
                    AND (X_BANK_CHARGES_CCID IS NULL)))
           AND (   (Recinfo.COLL_ENDORSEMENT_CCID =  X_COLL_ENDORSEMENT_CCID)
                OR (    (Recinfo.COLL_ENDORSEMENT_CCID IS NULL)
                    AND (X_COLL_ENDORSEMENT_CCID IS NULL)))
           AND (   (Recinfo.BILLS_COLLECTION_CCID =  X_BILLS_COLLECTION_CCID)
                OR (    (Recinfo.BILLS_COLLECTION_CCID IS NULL)
                    AND (X_BILLS_COLLECTION_CCID IS NULL)))
           AND (   (Recinfo.OTHER_CREDITS_CCID =  X_OTHER_CREDITS_CCID)
                OR (    (Recinfo.OTHER_CREDITS_CCID IS NULL)
                    AND (X_OTHER_CREDITS_CCID IS NULL)))
           AND (   (Recinfo.FACTORING_DOCS_CCID =  X_FACTORING_DOCS_CCID)
                OR (    (Recinfo.FACTORING_DOCS_CCID IS NULL)
                    AND (X_FACTORING_DOCS_CCID IS NULL)))
           AND (   (Recinfo.BILLS_DISCOUNT_CCID =  X_BILLS_DISCOUNT_CCID)
                OR (    (Recinfo.BILLS_DISCOUNT_CCID IS NULL)
                    AND (X_BILLS_DISCOUNT_CCID IS NULL)))
           AND (   (Recinfo.DISC_ENDORSEMENT_CCID =  X_DISC_ENDORSEMENT_CCID)
                OR (    (Recinfo.DISC_ENDORSEMENT_CCID IS NULL)
                    AND (X_DISC_ENDORSEMENT_CCID IS NULL)))
           AND (   (Recinfo.DISCOUNTED_BILLS_CCID =  X_DISCOUNTED_BILLS_CCID)
                OR (    (Recinfo.DISCOUNTED_BILLS_CCID IS NULL)
                    AND (X_DISCOUNTED_BILLS_CCID IS NULL)))
           AND (   (Recinfo.PORTFOLIO_CODE =  X_PORTFOLIO_CODE)
                OR (    (Recinfo.PORTFOLIO_CODE IS NULL)
                    AND (X_PORTFOLIO_CODE IS NULL)))
           AND (   (Recinfo.MIN_DOCUMENT_AMOUNT =  X_MIN_DOCUMENT_AMOUNT)
                OR (    (Recinfo.MIN_DOCUMENT_AMOUNT IS NULL)
                    AND (X_MIN_DOCUMENT_AMOUNT IS NULL)))
           AND (   (Recinfo.MAX_DOCUMENT_AMOUNT =  X_MAX_DOCUMENT_AMOUNT)
                OR (    (Recinfo.MAX_DOCUMENT_AMOUNT IS NULL)
                    AND (X_MAX_DOCUMENT_AMOUNT IS NULL)))
           AND (   (Recinfo.MIN_REMITTANCE_AMOUNT =  X_MIN_REMITTANCE_AMOUNT)
                OR (    (Recinfo.MIN_REMITTANCE_AMOUNT IS NULL)
                    AND (X_MIN_REMITTANCE_AMOUNT IS NULL)))
           AND (   (Recinfo.MAX_REMITTANCE_AMOUNT =  X_MAX_REMITTANCE_AMOUNT)
                OR (    (Recinfo.MAX_REMITTANCE_AMOUNT IS NULL)
                    AND (X_MAX_REMITTANCE_AMOUNT IS NULL)))
           AND (   (Recinfo.BANK_INSTRUCTION_CODE1 =  X_BANK_INSTRUCTION_CODE1)
                OR (    (Recinfo.BANK_INSTRUCTION_CODE1 IS NULL)
                    AND (X_BANK_INSTRUCTION_CODE1 IS NULL)))
           AND (   (Recinfo.BANK_INSTRUCTION_CODE2 =  X_BANK_INSTRUCTION_CODE2)
                OR (    (Recinfo.BANK_INSTRUCTION_CODE2 IS NULL)
                    AND (X_BANK_INSTRUCTION_CODE2 IS NULL)))
           AND (   (Recinfo.BANK_CHARGE_AMOUNT =  X_BANK_CHARGE_AMOUNT)
                OR (    (Recinfo.BANK_CHARGE_AMOUNT IS NULL)
                    AND (X_BANK_CHARGE_AMOUNT IS NULL)))
           AND (   (Recinfo.FACTORING_RATE =  X_FACTORING_RATE)
                OR (    (Recinfo.FACTORING_RATE IS NULL)
                    AND (X_FACTORING_RATE IS NULL)))
           AND (   (Recinfo.FACTORING_RATE_PERIOD =  X_FACTORING_RATE_PERIOD)
                OR (    (Recinfo.FACTORING_RATE_PERIOD IS NULL)
                    AND (X_FACTORING_RATE_PERIOD IS NULL)))
           AND (   (Recinfo.BATCH_SOURCE_ID =  X_BATCH_SOURCE_ID)
                OR (    (Recinfo.BATCH_SOURCE_ID IS NULL)
                    AND (X_BATCH_SOURCE_ID IS NULL)))
           AND (   (Recinfo.CALCULATED_INTEREST_CCID =  X_CALCULATED_INTEREST_CCID)
                OR (    (Recinfo.CALCULATED_INTEREST_CCID IS NULL)
                    AND (X_CALCULATED_INTEREST_CCID IS NULL)))
           AND (   (Recinfo.INTEREST_WRITEOFF_CCID =  X_INTEREST_WRITEOFF_CCID)
                OR (    (Recinfo.INTEREST_WRITEOFF_CCID IS NULL)
                    AND (X_INTEREST_WRITEOFF_CCID IS NULL)))
           AND (   (Recinfo.FACTORING_INTEREST_CCID =  X_FACTORING_INTEREST_CCID)
                OR (    (Recinfo.FACTORING_INTEREST_CCID IS NULL)
                    AND (X_FACTORING_INTEREST_CCID IS NULL)))
           AND (   (Recinfo.ABATEMENT_WRITEOFF_CCID =  X_ABATEMENT_WRITEOFF_CCID)
                OR (    (Recinfo.ABATEMENT_WRITEOFF_CCID IS NULL)
                    AND (X_ABATEMENT_WRITEOFF_CCID IS NULL)))
           AND (   (Recinfo.ABATEMENT_REVENUE_CCID =  X_ABATEMENT_REVENUE_CCID)
                OR (    (Recinfo.ABATEMENT_REVENUE_CCID IS NULL)
                    AND (X_ABATEMENT_REVENUE_CCID IS NULL)))
           AND (   (Recinfo.INTEREST_REVENUE_CCID =  X_INTEREST_REVENUE_CCID)
                OR (    (Recinfo.INTEREST_REVENUE_CCID IS NULL)
                    AND (X_INTEREST_REVENUE_CCID IS NULL)))
           AND (   (Recinfo.CALCULATED_INTEREST_RECTRX_ID =  X_CALC_INTEREST_RECTRX_ID)
                OR (    (Recinfo.CALCULATED_INTEREST_RECTRX_ID IS NULL)
                    AND (X_CALC_INTEREST_RECTRX_ID IS NULL)))
           AND (   (Recinfo.INTEREST_WRITEOFF_RECTRX_ID =  X_INTEREST_WRITEOFF_RECTRX_ID)
                OR (    (Recinfo.INTEREST_WRITEOFF_RECTRX_ID IS NULL)
                    AND (X_INTEREST_WRITEOFF_RECTRX_ID IS NULL)))
           AND (   (Recinfo.INTEREST_REVENUE_RECTRX_ID =  X_INTEREST_REVENUE_RECTRX_ID)
                OR (    (Recinfo.INTEREST_REVENUE_RECTRX_ID IS NULL)
                    AND (X_INTEREST_REVENUE_RECTRX_ID IS NULL)))
           AND (   (Recinfo.ABATEMENT_WRITEOFF_RECTRX_ID =  X_ABATEMENT_WRITEOFF_RECTRX_ID)
                OR (    (Recinfo.ABATEMENT_WRITEOFF_RECTRX_ID IS NULL)
                    AND (X_ABATEMENT_WRITEOFF_RECTRX_ID IS NULL)))
           AND (   (Recinfo.ABATEMENT_REVENUE_RECTRX_ID =  X_ABATEMENT_REVENUE_RECTRX_ID)
                OR (    (Recinfo.ABATEMENT_REVENUE_RECTRX_ID IS NULL)
                    AND (X_ABATEMENT_REVENUE_RECTRX_ID IS NULL)))
           AND (   (Recinfo.WRITEOFF_PERC_TOLERANCE =  X_WRITEOFF_PERC_TOLERANCE)
                OR (    (Recinfo.WRITEOFF_PERC_TOLERANCE IS NULL)
                    AND (X_WRITEOFF_PERC_TOLERANCE IS NULL)))
           AND (   (Recinfo.WRITEOFF_AMOUNT_TOLERANCE =  X_WRITEOFF_AMOUNT_TOLERANCE)
                OR (    (Recinfo.WRITEOFF_AMOUNT_TOLERANCE IS NULL)
                    AND (X_WRITEOFF_AMOUNT_TOLERANCE IS NULL)))
           AND (   (Recinfo.GL_DATE_BANK_RETURN =  X_GL_DATE_BANK_RETURN)
                OR (    (Recinfo.GL_DATE_BANK_RETURN IS NULL)
                    AND (X_GL_DATE_BANK_RETURN IS NULL)))
           AND (   (Recinfo.FLOATING =  X_FLOATING)
                OR (    (Recinfo.FLOATING IS NULL)
                    AND (X_FLOATING IS NULL)))
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
             FND_MESSAGE.SET_TOKEN('PARAMETERS','receipt_method_id = ' ||
                                    X_receipt_method_id ||
                                    'bank_acct_use_id = ' ||
                                    X_bank_acct_use_id);
             FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
	 END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

  END Lock_Row;



  PROCEDURE Update_Row ( X_Rowid                                    VARCHAR2,

			 X_BANK_ACCT_USE_ID                         NUMBER,
			 X_RECEIPT_METHOD_ID                        NUMBER,
			 X_BANK_CHARGES_CCID                        NUMBER ,
			 X_COLL_ENDORSEMENT_CCID                    NUMBER ,
			 X_BILLS_COLLECTION_CCID                    NUMBER ,
			 X_OTHER_CREDITS_CCID                       NUMBER ,
			 X_FACTORING_DOCS_CCID                      NUMBER ,
                         X_BILLS_DISCOUNT_CCID                      NUMBER ,
                         X_DISC_ENDORSEMENT_CCID                    NUMBER ,
                         X_FACTORING_CHARGES_CCID                   NUMBER ,
                         X_DISCOUNTED_BILLS_CCID                    NUMBER ,
			 X_PORTFOLIO_CODE                           NUMBER ,
			 X_MIN_DOCUMENT_AMOUNT                      NUMBER ,
			 X_MAX_DOCUMENT_AMOUNT                      NUMBER ,
			 X_MIN_REMITTANCE_AMOUNT                    NUMBER ,
			 X_MAX_REMITTANCE_AMOUNT                    NUMBER ,
			 X_BANK_INSTRUCTION_CODE1                   NUMBER ,
			 X_BANK_INSTRUCTION_CODE2                   NUMBER ,
			 X_BANK_CHARGE_AMOUNT                       NUMBER ,
			 X_FACTORING_RATE                           NUMBER ,
			 X_FACTORING_RATE_PERIOD                    NUMBER ,
			 X_BATCH_SOURCE_ID                          NUMBER ,
			 X_CALCULATED_INTEREST_CCID                 NUMBER ,
			 X_INTEREST_WRITEOFF_CCID                   NUMBER ,
			 X_FACTORING_INTEREST_CCID                  NUMBER ,
			 X_ABATEMENT_WRITEOFF_CCID                  NUMBER ,
			 X_ABATEMENT_REVENUE_CCID                   NUMBER ,
			 X_INTEREST_REVENUE_CCID                    NUMBER ,
			 X_CALC_INTEREST_RECTRX_ID                  NUMBER ,
			 X_INTEREST_WRITEOFF_RECTRX_ID              NUMBER ,
			 X_INTEREST_REVENUE_RECTRX_ID               NUMBER ,
			 X_ABATEMENT_WRITEOFF_RECTRX_ID             NUMBER ,
			 X_ABATEMENT_REVENUE_RECTRX_ID              NUMBER ,
			 X_WRITEOFF_PERC_TOLERANCE                  NUMBER ,
			 X_WRITEOFF_AMOUNT_TOLERANCE                NUMBER ,
			 X_GL_DATE_BANK_RETURN                      VARCHAR2 ,
			 X_FLOATING                                 NUMBER ,
			 X_LAST_UPDATE_DATE                         DATE,
			 X_LAST_UPDATED_BY                          NUMBER,
			 X_CREATION_DATE                            DATE,
			 X_CREATED_BY                               NUMBER,
			 X_LAST_UPDATE_LOGIN                        NUMBER,
                         X_COLL_REMITTANCE_MEDIA                    VARCHAR2,
                         X_COLL_FORMAT_PGM_ID                       NUMBER,
                         X_FACTOR_REMITTANCE_MEDIA                  VARCHAR2,
                         X_FACTOR_FORMAT_PGM_ID                     NUMBER,
                         X_OCC_REP_FORMAT_PGM_ID                    NUMBER,
                         X_OCC_FILE_FORMAT_PGM_ID                   NUMBER,
                         X_MAX_COLLECTION_DOCS                      NUMBER,
		         X_calling_sequence		            VARCHAR2
  ) IS
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);
  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'JL_BR_AR_REC_MET_ACCTS_EXT_PKG.UPDATE_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Update JL_BR_AR_REC_MET_ACCTS_EXT';
    UPDATE JL_BR_AR_REC_MET_ACCTS_EXT
    SET
	 BANK_ACCT_USE_ID               =  	 X_BANK_ACCT_USE_ID                 ,
	 RECEIPT_METHOD_ID              =  	 X_RECEIPT_METHOD_ID                ,
	 BANK_CHARGES_CCID              =        X_BANK_CHARGES_CCID                ,
	 COLL_ENDORSEMENT_CCID          =        X_COLL_ENDORSEMENT_CCID            ,
	 BILLS_COLLECTION_CCID          =        X_BILLS_COLLECTION_CCID            ,
	 OTHER_CREDITS_CCID             =        X_OTHER_CREDITS_CCID               ,
	 FACTORING_DOCS_CCID            =        X_FACTORING_DOCS_CCID              ,
        BILLS_DISCOUNT_CCID            =        X_BILLS_DISCOUNT_CCID
    ,
         DISC_ENDORSEMENT_CCID          =        X_DISC_ENDORSEMENT_CCID
    ,
         DISCOUNTED_BILLS_CCID          =        X_DISCOUNTED_BILLS_CCID
    ,
	 PORTFOLIO_CODE                 =	 X_PORTFOLIO_CODE                   ,
	 MIN_DOCUMENT_AMOUNT            =	 X_MIN_DOCUMENT_AMOUNT              ,
	 MAX_DOCUMENT_AMOUNT            =	 X_MAX_DOCUMENT_AMOUNT              ,
	 MIN_REMITTANCE_AMOUNT          =	 X_MIN_REMITTANCE_AMOUNT            ,
	 MAX_REMITTANCE_AMOUNT          =	 X_MAX_REMITTANCE_AMOUNT            ,
	 BANK_INSTRUCTION_CODE1         =	 X_BANK_INSTRUCTION_CODE1           ,
	 BANK_INSTRUCTION_CODE2         =	 X_BANK_INSTRUCTION_CODE2           ,
	 BANK_CHARGE_AMOUNT             =	 X_BANK_CHARGE_AMOUNT               ,
	 FACTORING_RATE                 =        X_FACTORING_RATE                   ,
 	 FACTORING_RATE_PERIOD          =        X_FACTORING_RATE_PERIOD            ,
	 BATCH_SOURCE_ID                =	 X_BATCH_SOURCE_ID                  ,
	 CALCULATED_INTEREST_CCID       =        X_CALCULATED_INTEREST_CCID         ,
	 INTEREST_WRITEOFF_CCID         =        X_INTEREST_WRITEOFF_CCID           ,
	 FACTORING_INTEREST_CCID        =        X_FACTORING_INTEREST_CCID          ,
	 ABATEMENT_WRITEOFF_CCID        =        X_ABATEMENT_WRITEOFF_CCID          ,
	 ABATEMENT_REVENUE_CCID         =        X_ABATEMENT_REVENUE_CCID           ,
	 INTEREST_REVENUE_CCID          =        X_INTEREST_REVENUE_CCID            ,
	 CALCULATED_INTEREST_RECTRX_ID  =        X_CALC_INTEREST_RECTRX_ID          ,
	 INTEREST_WRITEOFF_RECTRX_ID    =        X_INTEREST_WRITEOFF_RECTRX_ID      ,
	 INTEREST_REVENUE_RECTRX_ID     =        X_INTEREST_REVENUE_RECTRX_ID       ,
	 ABATEMENT_WRITEOFF_RECTRX_ID   =        X_ABATEMENT_WRITEOFF_RECTRX_ID     ,
	 ABATEMENT_REVENUE_RECTRX_ID    =        X_ABATEMENT_REVENUE_RECTRX_ID      ,
	 WRITEOFF_PERC_TOLERANCE        =        X_WRITEOFF_PERC_TOLERANCE          ,
	 WRITEOFF_AMOUNT_TOLERANCE      =        X_WRITEOFF_AMOUNT_TOLERANCE        ,
	 GL_DATE_BANK_RETURN            =        X_GL_DATE_BANK_RETURN              ,
	 FLOATING                       =        X_FLOATING                         ,
	 LAST_UPDATE_DATE               =	 X_LAST_UPDATE_DATE                 ,
	 LAST_UPDATED_BY                =	 X_LAST_UPDATED_BY                  ,
	 CREATION_DATE                  =	 X_CREATION_DATE                    ,
	 CREATED_BY                     =	 X_CREATED_BY                       ,
	 LAST_UPDATE_LOGIN              =	 X_LAST_UPDATE_LOGIN                ,
	 COLL_REMITTANCE_MEDIA     	=	 X_COLL_REMITTANCE_MEDIA            ,
	 COLL_FORMAT_PGM_ID             =        X_COLL_FORMAT_PGM_ID               ,
         FACTOR_REMITTANCE_MEDIA        =        X_FACTOR_REMITTANCE_MEDIA          ,
         FACTOR_FORMAT_PGM_ID           =        X_FACTOR_FORMAT_PGM_ID             ,
         OCC_REP_FORMAT_PGM_ID          =        X_OCC_REP_FORMAT_PGM_ID            ,
         OCC_FILE_FORMAT_PGM_ID         =        X_OCC_FILE_FORMAT_PGM_ID           ,
         MAX_COLLECTION_DOCS            =        X_MAX_COLLECTION_DOCS

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
             FND_MESSAGE.SET_TOKEN('PARAMETERS','receipt_method_id = ' ||
                                    X_receipt_method_id  ||
                                    'bank_acct_use_id = ' ||
                                    X_bank_acct_use_id );
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Update_Row;

  PROCEDURE Delete_Row (X_Rowid 	        	VARCHAR2,
		        X_calling_sequence	IN	VARCHAR2
  ) IS
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);
  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'JL_BR_AR_REC_MET_ACCTS_EXT_PKG.DELETE_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Delete from JL_BR_AR_REC_MET_ACCTS_EXT';
    DELETE FROM JL_BR_AR_REC_MET_ACCTS_EXT
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



END JL_BR_AR_REC_MET_ACCTS_EXT_PKG;

/
