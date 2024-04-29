--------------------------------------------------------
--  DDL for Package Body JL_BR_AR_BANK_RETURNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AR_BANK_RETURNS_PKG" as
/* $Header: jlbrremb.pls 120.4 2003/09/15 21:51:54 vsidhart ship $ */

  PROCEDURE Insert_Row(X_rowid                   IN OUT NOCOPY VARCHAR2,

                          X_RETURN_ID                                NUMBER,
                          X_BANK_OCCURRENCE_CODE                     NUMBER,
                          X_OCCURRENCE_DATE                          DATE,
                          X_FILE_CONTROL                             VARCHAR2,
                          X_ENTRY_SEQUENTIAL_NUMBER                  NUMBER,
                          X_GENERATION_DATE                          DATE,
                          X_PROCESSING_DATE                          DATE,
                          X_DOCUMENT_ID                              NUMBER,
                          --X_BANK_NUMBER                            VARCHAR2,
                          X_BANK_PARTY_ID                            NUMBER,
                          X_BATCH_SOURCE_ID                          NUMBER,
                          X_OUR_NUMBER                               VARCHAR2,
                          X_TRADE_NOTE_NUMBER                        VARCHAR2,
                          X_DUE_DATE                                 DATE,
                          X_TRADE_NOTE_AMOUNT                        NUMBER,
                          X_COLLECTOR_BANK_PARTY_ID                  NUMBER,
                          X_COLLECTOR_BRANCH_PARTY_ID                NUMBER,
                          X_BANK_CHARGE_AMOUNT                       NUMBER,
                          X_ABATEMENT_AMOUNT                         NUMBER,
                          X_DISCOUNT_AMOUNT                          NUMBER,
                          X_CREDIT_AMOUNT                            NUMBER,
                          X_INTEREST_AMOUNT_RECEIVED                 NUMBER,
                          X_CUSTOMER_ID                              NUMBER,
                          X_RETURN_INFO                              VARCHAR2,
                          X_BANK_USE                                 VARCHAR2,
                          X_COMPANY_USE                              NUMBER,
                          X_LAST_UPDATE_DATE                         DATE,
                          X_LAST_UPDATED_BY                          NUMBER,
                          X_CREATION_DATE                            DATE,
                          X_CREATED_BY                               NUMBER,
                          X_LAST_UPDATE_LOGIN                        NUMBER,
                      X_calling_sequence        IN  VARCHAR2,
                          X_ORG_ID                                   NUMBER
  ) IS
    CURSOR C IS SELECT rowid
                FROM   jl_br_ar_bank_returns
                WHERE  return_id = X_return_id;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

    BEGIN
--     Update the calling sequence
--
      current_calling_sequence := 'JL_BR_AR_BANK_RETURNS_PKG.INSERT_ROW<-' ||
                                   X_calling_sequence;
--
      debug_info := 'Insert into JL_BR_AR_BANK_RETURNS';
      insert into jl_br_ar_bank_returns(
                                       RETURN_ID,
                                        BANK_OCCURRENCE_CODE,
                                        OCCURRENCE_DATE,
                                        FILE_CONTROL,
                                        ENTRY_SEQUENTIAL_NUMBER,
                                        GENERATION_DATE,
                                        PROCESSING_DATE,
                                        DOCUMENT_ID,
                                        --BANK_NUMBER,
                                        BANK_PARTY_ID,
                                        BATCH_SOURCE_ID,
                                        OUR_NUMBER,
                                        TRADE_NOTE_NUMBER,
                                        DUE_DATE,
                                        TRADE_NOTE_AMOUNT,
                                        COLLECTOR_BANK_PARTY_ID,
                                        COLLECTOR_BRANCH_PARTY_ID,
                                        BANK_CHARGE_AMOUNT,
                                        ABATEMENT_AMOUNT,
                                        DISCOUNT_AMOUNT,
                                        CREDIT_AMOUNT,
                                        INTEREST_AMOUNT_RECEIVED,
                                        CUSTOMER_ID,
                                        RETURN_INFO,
                                        BANK_USE,
                                        COMPANY_USE,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_LOGIN,
                                        ORG_ID )
       VALUES        (                  X_RETURN_ID,
                                        X_BANK_OCCURRENCE_CODE,
                                        X_OCCURRENCE_DATE,
                                        X_FILE_CONTROL,
                                        X_ENTRY_SEQUENTIAL_NUMBER,
                                        X_GENERATION_DATE,
                                        X_PROCESSING_DATE,
                                        X_DOCUMENT_ID,
                                        --X_BANK_NUMBER,
                                        X_BANK_PARTY_ID,
                                        X_BATCH_SOURCE_ID,
                                        X_OUR_NUMBER,
                                        X_TRADE_NOTE_NUMBER,
                                        X_DUE_DATE,
                                        X_TRADE_NOTE_AMOUNT,
                                        X_COLLECTOR_BANK_PARTY_ID,
                                        X_COLLECTOR_BRANCH_PARTY_ID,
                                        X_BANK_CHARGE_AMOUNT,
                                        X_ABATEMENT_AMOUNT,
                                        X_DISCOUNT_AMOUNT,
                                        X_CREDIT_AMOUNT,
                                        X_INTEREST_AMOUNT_RECEIVED,
                                        X_CUSTOMER_ID,
                                        X_RETURN_INFO,
                                        X_BANK_USE,
                                        X_COMPANY_USE,
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
    FETCH C INTO X_rowid;
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
           FND_MESSAGE.SET_TOKEN('PARAMETERS',
                                'return_id = ' || X_return_id);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;

  PROCEDURE Lock_Row(  X_rowid                   VARCHAR2,

                       X_RETURN_ID                                NUMBER,
                       X_BANK_OCCURRENCE_CODE                     NUMBER,
                       X_OCCURRENCE_DATE                          DATE,
                       X_FILE_CONTROL                             VARCHAR2,
                       X_ENTRY_SEQUENTIAL_NUMBER                  NUMBER,
                       X_GENERATION_DATE                          DATE,
                       X_PROCESSING_DATE                          DATE,
                       X_DOCUMENT_ID                              NUMBER,
                       --X_BANK_NUMBER                            VARCHAR2,
                       X_BANK_PARTY_ID                            NUMBER,
                       X_BATCH_SOURCE_ID                          NUMBER,
                       X_OUR_NUMBER                               VARCHAR2,
                       X_TRADE_NOTE_NUMBER                        VARCHAR2,
                       X_DUE_DATE                                 DATE,
                       X_TRADE_NOTE_AMOUNT                        NUMBER,
                       X_COLLECTOR_BANK_PARTY_ID                  NUMBER,
                       X_COLLECTOR_BRANCH_PARTY_ID                NUMBER,
                       X_BANK_CHARGE_AMOUNT                       NUMBER,
                       X_ABATEMENT_AMOUNT                         NUMBER,
                       X_DISCOUNT_AMOUNT                          NUMBER,
                       X_CREDIT_AMOUNT                            NUMBER,
                       X_INTEREST_AMOUNT_RECEIVED                 NUMBER,
                       X_CUSTOMER_ID                              NUMBER,
                       X_RETURN_INFO                              VARCHAR2,
                       X_BANK_USE                                 VARCHAR2,
                       X_COMPANY_USE                              NUMBER,
                       X_LAST_UPDATE_DATE                         DATE,
                       X_LAST_UPDATED_BY                          NUMBER,
                       X_CREATION_DATE                            DATE,
                       X_CREATED_BY                               NUMBER,
                       X_LAST_UPDATE_LOGIN                        NUMBER,

                       X_calling_sequence        IN    VARCHAR2
  ) IS
    CURSOR C IS SELECT *
                FROM   jl_br_ar_bank_returns
                WHERE  return_id = X_return_id
                FOR UPDATE of return_id
                NOWAIT;

    Recinfo C%ROWTYPE;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'JL_BR_AR_BANK_RETURNS_PKG.LOCK_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND)
    THEN
      debug_info := 'Close cursor C - DATA NOTFOUND';
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
    debug_info := 'Close cursor C';
    CLOSE C;
    IF (Recinfo.return_id = X_return_id       AND
        Recinfo.bank_occurrence_code = X_bank_occurrence_code AND
	Recinfo.occurrence_date = X_occurrence_date AND
        Recinfo.file_control = X_file_control AND
	Recinfo.entry_sequential_number = X_entry_sequential_number AND
	Recinfo.generation_date = X_generation_date AND
	Recinfo.processing_date = X_processing_date AND
	Recinfo.document_id = X_document_id AND
	Recinfo.trade_note_number = X_trade_note_number AND
	Recinfo.last_updated_by = X_last_updated_by AND
	Recinfo.last_update_date = X_last_update_date AND
	--(Recinfo.bank_number = X_bank_number OR
	--   X_bank_number IS NULL) AND
 	(Recinfo.bank_party_id = X_bank_party_id OR
	   X_bank_party_id IS NULL) AND
	(Recinfo.batch_source_id = X_batch_source_id OR
	   X_batch_source_id IS NULL) AND
	(Recinfo.our_number = X_our_number OR
	   X_our_number IS NULL) AND
	(Recinfo.due_date = X_due_date OR
	   X_due_date IS NULL) AND
	(Recinfo.trade_note_amount = X_trade_note_amount OR
	   X_trade_note_amount IS NULL) AND
	(Recinfo.COLLECTOR_BANK_PARTY_ID = X_COLLECTOR_BANK_PARTY_ID OR
	   X_COLLECTOR_BANK_PARTY_ID IS NULL) AND
	(Recinfo.COLLECTOR_BRANCH_PARTY_ID = X_COLLECTOR_BRANCH_PARTY_ID OR
	   X_COLLECTOR_BRANCH_PARTY_ID IS NULL) AND
	(Recinfo.bank_charge_amount = X_bank_charge_amount OR
	   X_bank_charge_amount IS NULL) AND
	(Recinfo.abatement_amount = X_abatement_amount OR
	   X_abatement_amount IS NULL) AND
	(Recinfo.discount_amount = X_discount_amount OR
	   X_discount_amount IS NULL) AND
	(Recinfo.credit_amount = X_credit_amount OR
	   X_credit_amount IS NULL) AND
	(Recinfo.interest_amount_received = X_interest_amount_received OR
	   X_interest_amount_received IS NULL) AND
	(Recinfo.customer_id = X_customer_id OR
	   X_customer_id IS NULL) AND
	(Recinfo.return_info = X_return_info OR
	   X_return_info IS NULL) AND
	(Recinfo.bank_use = X_bank_use OR
	   X_bank_use IS NULL) AND
	(Recinfo.company_use = X_company_use OR
	   X_company_use IS NULL) AND
	(Recinfo.last_update_login = X_last_update_login OR
	   X_last_update_login IS NULL) AND
	(Recinfo.creation_date = X_creation_date OR
	   X_creation_date IS NULL) AND
	(Recinfo.created_by = X_created_by OR
	   X_created_by IS NULL)
        )
    THEN
      return;
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
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
	                        'return_id = ' || X_return_id);
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        END IF;
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Lock_Row;

  PROCEDURE Update_Row(X_rowid                   VARCHAR2,

                       X_RETURN_ID                                NUMBER,
                       X_BANK_OCCURRENCE_CODE                     NUMBER,
                       X_OCCURRENCE_DATE                          DATE,
                       X_FILE_CONTROL                             VARCHAR2,
                       X_ENTRY_SEQUENTIAL_NUMBER                  NUMBER,
                       X_GENERATION_DATE                          DATE,
                       X_PROCESSING_DATE                          DATE,
                       X_DOCUMENT_ID                              NUMBER,
                       --X_BANK_NUMBER                            VARCHAR2,
                       X_BANK_PARTY_ID                            NUMBER,
                       X_BATCH_SOURCE_ID                          NUMBER,
                       X_OUR_NUMBER                               VARCHAR2,
                       X_TRADE_NOTE_NUMBER                        VARCHAR2,
                       X_DUE_DATE                                 DATE,
                       X_TRADE_NOTE_AMOUNT                        NUMBER,
                       X_COLLECTOR_BANK_PARTY_ID                  NUMBER,
                       X_COLLECTOR_BRANCH_PARTY_ID                NUMBER,
                       X_BANK_CHARGE_AMOUNT                       NUMBER,
                       X_ABATEMENT_AMOUNT                         NUMBER,
                       X_DISCOUNT_AMOUNT                          NUMBER,
                       X_CREDIT_AMOUNT                            NUMBER,
                       X_INTEREST_AMOUNT_RECEIVED                 NUMBER,
                       X_CUSTOMER_ID                              NUMBER,
                       X_RETURN_INFO                              VARCHAR2,
                       X_BANK_USE                                 VARCHAR2,
                       X_COMPANY_USE                              NUMBER,
                       X_LAST_UPDATE_DATE                         DATE,
                       X_LAST_UPDATED_BY                          NUMBER,
                       X_CREATION_DATE                            DATE,
                       X_CREATED_BY                               NUMBER,
                       X_LAST_UPDATE_LOGIN                        NUMBER,

                       X_calling_sequence        IN    VARCHAR2
  ) IS

  BEGIN
    UPDATE jl_br_ar_bank_returns
    SET   RETURN_ID               = X_RETURN_ID,
          BANK_OCCURRENCE_CODE    = X_BANK_OCCURRENCE_CODE,
          OCCURRENCE_DATE         = X_OCCURRENCE_DATE,
          FILE_CONTROL            = X_FILE_CONTROL,
          ENTRY_SEQUENTIAL_NUMBER = X_ENTRY_SEQUENTIAL_NUMBER,
          GENERATION_DATE         = X_GENERATION_DATE,
          PROCESSING_DATE         = X_PROCESSING_DATE,
          DOCUMENT_ID             = X_DOCUMENT_ID,
          --BANK_NUMBER           = X_BANK_NUMBER,
          BANK_PARTY_ID           = X_BANK_PARTY_ID,
          BATCH_SOURCE_ID         = X_BATCH_SOURCE_ID,
          OUR_NUMBER              = X_OUR_NUMBER,
          TRADE_NOTE_NUMBER       = X_TRADE_NOTE_NUMBER,
          DUE_DATE                = X_DUE_DATE,
          TRADE_NOTE_AMOUNT       = X_TRADE_NOTE_AMOUNT,
          COLLECTOR_BANK_PARTY_ID   = X_COLLECTOR_BANK_PARTY_ID,
          COLLECTOR_BRANCH_PARTY_ID = X_COLLECTOR_BRANCH_PARTY_ID,
          BANK_CHARGE_AMOUNT      = X_BANK_CHARGE_AMOUNT,
          ABATEMENT_AMOUNT        = X_ABATEMENT_AMOUNT,
          DISCOUNT_AMOUNT         = X_DISCOUNT_AMOUNT,
          CREDIT_AMOUNT           = X_CREDIT_AMOUNT,
          INTEREST_AMOUNT_RECEIVED = X_INTEREST_AMOUNT_RECEIVED,
          CUSTOMER_ID             = X_CUSTOMER_ID,
          RETURN_INFO             = X_RETURN_INFO,
          BANK_USE                = X_BANK_USE,
          COMPANY_USE             = X_COMPANY_USE,
          LAST_UPDATE_DATE        = X_LAST_UPDATE_DATE,
          LAST_UPDATED_BY         = X_LAST_UPDATED_BY,
          CREATION_DATE           = X_CREATION_DATE,
          CREATED_BY              = X_CREATED_BY,
          LAST_UPDATE_LOGIN       = X_LAST_UPDATE_LOGIN
    WHERE  rowid = X_rowid;

    IF (SQL%NOTFOUND)
    THEN
      raise NO_DATA_FOUND;
    END IF;
  END Update_Row;

  PROCEDURE Delete_Row(  X_rowid                   VARCHAR2
  ) IS
  BEGIN
    DELETE
    FROM   jl_br_ar_bank_returns
    WHERE  rowid = X_rowid;

    IF (SQL%NOTFOUND)
    THEN
      raise NO_DATA_FOUND;
    END IF;
  END Delete_Row;

END JL_BR_AR_BANK_RETURNS_PKG;

/
