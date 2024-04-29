--------------------------------------------------------
--  DDL for Package Body JL_BR_AR_RET_INTERFACE_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AR_RET_INTERFACE_EXT_PKG" AS
/*$Header: jlbrrcbb.pls 120.2 2005/02/23 23:28:15 vsidhart noship $*/
PROCEDURE Update_Row(X_Rowid                             VARCHAR2,
                     X_FILE_CONTROL                      VARCHAR2,
                     X_ENTRY_SEQUENTIAL_NUMBER           NUMBER,
                     X_COMPANY_CODE                      NUMBER,
                     X_COMPANY_NAME                      VARCHAR2,
                     X_GENERATION_DATE                   DATE,
                     X_REMITTANCE_CODE                   NUMBER,
                     --X_BANK_NUMBER                     VARCHAR2,
                     X_BANK_PARTY_ID                     NUMBER ,
                     X_BANK_OCCURRENCE_CODE              NUMBER,
                     X_OCCURRENCE_DATE                   DATE,
                     X_PROCESSING_DATE                   DATE,
                     X_LAST_VALIDATION_DATE              DATE,
                     X_INSCRIPTION_NUMBER                NUMBER,
                     X_COMPANY_USE                       NUMBER,
                     X_OUR_NUMBER                        VARCHAR2,
                     X_PORTFOLIO_CODE                    NUMBER,
                     X_YOUR_NUMBER                       VARCHAR2,
                     X_DUE_DATE                          DATE,
                     X_TRADE_NOTE_AMOUNT                 NUMBER,
                     X_COLLECTOR_BANK_PARTY_ID           NUMBER,
                     X_COLLECTOR_BRANCH_PARTY_ID         NUMBER,
                     X_TRADE_NOTE_TYPE                   VARCHAR2,
                     X_BANK_CHARGE_AMOUNT                NUMBER,
                     X_ABATEMENT_AMOUNT                  NUMBER,
                     X_DISCOUNT_AMOUNT                   NUMBER,
                     X_CREDIT_AMOUNT                     NUMBER,
                     X_INTEREST_AMOUNT_RECEIVED          NUMBER,
                     X_CUSTOMER_NAME                     VARCHAR2,
                     X_RETURN_INFO                       VARCHAR2,
                     X_BANK_USE                          VARCHAR2,
                     X_ERROR_CODE                        VARCHAR2,
                     X_CANCELLATION_CODE                 VARCHAR2,
                     X_ORG_ID                            NUMBER,
                     X_LAST_UPDATE_DATE                  DATE,
                     X_LAST_UPDATED_BY                   NUMBER,
                     X_CREATION_DATE                     DATE,
                     X_CREATED_BY                        NUMBER,
                     X_LAST_UPDATE_LOGIN                 NUMBER,
                     X_CALLING_SEQUENCE              IN  VARCHAR2) IS
 CURRENT_CALLING_SEQUENCE   VARCHAR2(2000);
 DEBUG_INFO                 VARCHAR2(100);
BEGIN
   CURRENT_CALLING_SEQUENCE := 'JL_BR_AR_RET_INTERFACE_EXT_PKG.UPDATE_ROW <-'||X_CALLING_SEQUENCE;
   DEBUG_INFO := 'UPDATE JL_BR_AR_RET_INTERFACE_EXT';

               UPDATE JL_BR_AR_RET_INTERFACE_EXT
               SET
                     FILE_CONTROL            = X_FILE_CONTROL,
                     ENTRY_SEQUENTIAL_NUMBER = X_ENTRY_SEQUENTIAL_NUMBER,
                     COMPANY_CODE            = X_COMPANY_CODE,
                     COMPANY_NAME            = X_COMPANY_NAME,
                     GENERATION_DATE         = X_GENERATION_DATE,
                     REMITTANCE_CODE         = X_REMITTANCE_CODE,
                     --BANK_NUMBER           = X_BANK_NUMBER,
                     BANK_PARTY_ID           = X_BANK_PARTY_ID,
                     BANK_OCCURRENCE_CODE    = X_BANK_OCCURRENCE_CODE,
                     OCCURRENCE_DATE         = X_OCCURRENCE_DATE,
                     PROCESSING_DATE         = X_PROCESSING_DATE,
                     LAST_VALIDATION_DATE    = X_LAST_VALIDATION_DATE,
                     INSCRIPTION_NUMBER      = X_INSCRIPTION_NUMBER,
                     COMPANY_USE             = X_COMPANY_USE,
                     OUR_NUMBER              = X_OUR_NUMBER,
                     PORTFOLIO_CODE          = X_PORTFOLIO_CODE,
                     YOUR_NUMBER             = X_YOUR_NUMBER,
                     DUE_DATE                = X_DUE_DATE,
                     TRADE_NOTE_AMOUNT       = X_TRADE_NOTE_AMOUNT,
                     COLLECTOR_BANK_PARTY_ID   = X_COLLECTOR_BANK_PARTY_ID,
                     COLLECTOR_BRANCH_PARTY_ID = X_COLLECTOR_BRANCH_PARTY_ID,
                     TRADE_NOTE_TYPE         = X_TRADE_NOTE_TYPE,
                     BANK_CHARGE_AMOUNT      = X_BANK_CHARGE_AMOUNT,
                     ABATEMENT_AMOUNT        = X_ABATEMENT_AMOUNT,
                     DISCOUNT_AMOUNT         = X_DISCOUNT_AMOUNT,
                     CREDIT_AMOUNT           = X_CREDIT_AMOUNT,
                     INTEREST_AMOUNT_RECEIVED = X_INTEREST_AMOUNT_RECEIVED,
                     CUSTOMER_NAME           = X_CUSTOMER_NAME,
                     RETURN_INFO             = X_RETURN_INFO,
                     BANK_USE                = X_BANK_USE,
                     ERROR_CODE              = X_ERROR_CODE,
                     CANCELLATION_CODE       = X_CANCELLATION_CODE,
                     ORG_ID                  = X_ORG_ID,
                     LAST_UPDATE_DATE        = X_LAST_UPDATE_DATE,
                     LAST_UPDATED_BY         = X_LAST_UPDATED_BY,
                     CREATION_DATE           = X_CREATION_DATE,
                     CREATED_BY              = X_CREATED_BY,
                     LAST_UPDATE_LOGIN       = X_LAST_UPDATE_LOGIN
                WHERE rowid = X_Rowid;
                if (SQL%NOTFOUND) then
                   Raise NO_DATA_FOUND;
                end if;
EXCEPTION WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
       FND_MESSAGE.SET_NAME('SQLGL','GL_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',CURRENT_CALLING_SEQUENCE);
       FND_MESSAGE.SET_TOKEN('PARAMETERS','Rowid = '||X_Rowid);
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO',DEBUG_INFO);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2,
                     X_CALLING_SEQUENCE IN VARCHAR2) IS
CURRENT_CALLING_SEQUENCE VARCHAR2(2000);
DEBUG_INFO    VARCHAR2(100);
BEGIN
CURRENT_CALLING_SEQUENCE := 'JL_BR_AR_RET_INTERFACE_EXT_PKG.DELETE_ROW<-'||X_CALLING_SEQUENCE;
DEBUG_INFO := 'DELETE FROM JL_BR_AR_RET_INTERFACE_EXT';
    DELETE FROM JL_BR_AR_RET_INTERFACE_EXT
    WHERE rowid = X_Rowid;
    if (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
    end if;
EXCEPTION WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
       FND_MESSAGE.SET_NAME('SQLGL','GL_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',CURRENT_CALLING_SEQUENCE);
       FND_MESSAGE.SET_TOKEN('PARAMETERS','FILE_CONTROL = '||X_ROWID);
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO',DEBUG_INFO);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Delete_Row;


PROCEDURE Lock_Row(X_ROWID                                    VARCHAR2,
                   X_FILE_CONTROL                             VARCHAR2,
                   X_ENTRY_SEQUENTIAL_NUMBER                  NUMBER,
                   X_COMPANY_CODE                             NUMBER    DEFAULT NULL,
                   X_COMPANY_NAME                             VARCHAR2,
                   X_GENERATION_DATE                          DATE,
                   X_REMITTANCE_CODE                          NUMBER,
                   --X_BANK_NUMBER                            VARCHAR2,
                   X_BANK_PARTY_ID                            NUMBER,
                   X_BANK_OCCURRENCE_CODE                     NUMBER,
                   X_OCCURRENCE_DATE                          DATE,
                   X_PROCESSING_DATE                          DATE,
                   X_LAST_VALIDATION_DATE                     DATE,
                   X_INSCRIPTION_NUMBER                       NUMBER    DEFAULT NULL,
                   X_COMPANY_USE                              NUMBER    DEFAULT NULL,
                   X_OUR_NUMBER                               VARCHAR2  DEFAULT NULL,
                   X_PORTFOLIO_CODE                           NUMBER    DEFAULT NULL,
                   X_YOUR_NUMBER                              VARCHAR2  DEFAULT NULL,
                   X_DUE_DATE                                 DATE      DEFAULT NULL,
                   X_TRADE_NOTE_AMOUNT                        NUMBER    DEFAULT NULL,
                   X_COLLECTOR_BANK_PARTY_ID                  NUMBER    DEFAULT NULL,
                   X_COLLECTOR_BRANCH_PARTY_ID                NUMBER    DEFAULT NULL,
                   X_TRADE_NOTE_TYPE                          VARCHAR2  DEFAULT NULL,
                   X_BANK_CHARGE_AMOUNT                       NUMBER    DEFAULT NULL,
                   X_ABATEMENT_AMOUNT                         NUMBER    DEFAULT NULL,
                   X_DISCOUNT_AMOUNT                          NUMBER    DEFAULT NULL,
                   X_CREDIT_AMOUNT                            NUMBER    DEFAULT NULL,
                   X_INTEREST_AMOUNT_RECEIVED                 NUMBER    DEFAULT NULL,
                   X_CUSTOMER_NAME                            VARCHAR2  DEFAULT NULL,
                   X_RETURN_INFO                              VARCHAR2  DEFAULT NULL,
                   X_BANK_USE                                 VARCHAR2  DEFAULT NULL,
                   X_ERROR_CODE                               VARCHAR2  DEFAULT NULL,
                   X_CANCELLATION_CODE                        VARCHAR2  DEFAULT NULL,
                   X_ORG_ID                                   NUMBER    DEFAULT NULL,
                   X_LAST_UPDATE_DATE                         DATE,
                   X_LAST_UPDATED_BY                          NUMBER,
                   X_CREATION_DATE                            DATE     DEFAULT NULL,
                   X_CREATED_BY                               NUMBER   DEFAULT NULL,
                   X_LAST_UPDATE_LOGIN                        NUMBER   DEFAULT NULL,
                   X_CALLING_SEQUENCE                         VARCHAR2) IS
--
CURSOR C IS
  SELECT *
  FROM   JL_BR_AR_RET_INTERFACE_EXT
  WHERE  rowid = X_Rowid
  FOR UPDATE of File_Control NOWAIT;
  Recinfo C%ROWTYPE;
--
  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(100);

BEGIN
  --  Update the calling sequence
  current_calling_sequence := 'JL_BR_AR_RET_INTERFACE_EXT_PKG.LOCK_ROW<-' ||
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
  IF      ((Recinfo.file_control =  X_file_control)
     AND   (Recinfo.entry_sequential_number =  X_entry_sequential_number)
     AND  ((Recinfo.company_code =  X_company_code)
          OR ((Recinfo.company_code IS NULL)
          AND (X_company_code IS NULL)))
     AND (Recinfo.COMPANY_NAME  =  X_COMPANY_NAME )
     AND (Recinfo.REMITTANCE_CODE =  X_REMITTANCE_CODE)
     AND (Recinfo.GENERATION_DATE =  X_GENERATION_DATE)
     --AND (Recinfo.bank_number =  X_bank_number)
     AND (Recinfo.bank_party_id =  X_bank_party_id)
     AND (Recinfo.bank_occurrence_code =  X_bank_occurrence_code)
     AND (Recinfo.occurrence_date =  X_Occurrence_Date)
     AND (Recinfo.processing_date =  X_processing_date)
     AND (Recinfo.last_validation_date =  X_last_validation_date)
     AND ((Recinfo.inscription_number =  X_inscription_number)
         OR ((Recinfo.inscription_number IS NULL)
         AND (X_inscription_number IS NULL)))
     AND ((Recinfo.company_use =  X_company_use)
         OR ((Recinfo.company_use IS NULL)
         AND (X_company_use IS NULL)))
     AND ((Recinfo.OUR_NUMBER =  X_OUR_NUMBER)
         OR ((Recinfo.OUR_NUMBER IS NULL)
         AND (X_OUR_NUMBER IS NULL)))
     AND ((Recinfo.portfolio_code =  X_Portfolio_Code)
         OR ((Recinfo.portfolio_code IS NULL)
         AND (X_Portfolio_Code IS NULL)))
     AND ((Recinfo.your_number =  X_your_number)
         OR ((Recinfo.your_number IS NULL)
         AND (X_your_number IS NULL)))
     AND ((Recinfo.due_date =  X_Due_Date)
         OR ((Recinfo.due_date IS NULL)
         AND (X_Due_Date IS NULL)))
     AND ((Recinfo.trade_note_amount =  X_trade_note_amount)
         OR ((Recinfo.trade_note_amount IS NULL)
         AND (X_trade_note_amount IS NULL)))
     AND ((Recinfo.COLLECTOR_BANK_PARTY_ID =  X_COLLECTOR_BANK_PARTY_ID)
         OR ((Recinfo.COLLECTOR_BANK_PARTY_ID IS NULL)
         AND (X_COLLECTOR_BANK_PARTY_ID IS NULL)))
     AND ((Recinfo.COLLECTOR_BRANCH_PARTY_ID =  X_COLLECTOR_BRANCH_PARTY_ID)
         OR ((Recinfo.COLLECTOR_BRANCH_PARTY_ID IS NULL)
         AND (X_COLLECTOR_BRANCH_PARTY_ID IS NULL)))
     AND ((Recinfo.trade_note_type =  X_trade_note_type)
         OR ((Recinfo.trade_note_type IS NULL)
         AND (X_trade_note_type IS NULL)))
     AND ((Recinfo.bank_charge_amount =  X_bank_charge_amount)
         OR ((Recinfo.bank_charge_amount IS NULL)
         AND (X_bank_charge_amount IS NULL)))
     AND ((Recinfo.abatement_amount =  X_abatement_amount)
         OR ((Recinfo.abatement_amount IS NULL)
         AND (X_abatement_amount IS NULL)))
     AND ((Recinfo.discount_amount =  X_Discount_Amount)
         OR ((Recinfo.discount_amount IS NULL)
         AND (X_Discount_Amount IS NULL)))
     AND ((Recinfo.credit_amount =  X_credit_amount)
         OR ((Recinfo.credit_amount IS NULL)
         AND (X_credit_amount IS NULL)))
     AND ((Recinfo.interest_amount_received =  X_interest_amount_received)
         OR ((Recinfo.interest_amount_received IS NULL)
         AND (X_interest_amount_received IS NULL)))
     AND ((Recinfo.customer_name =  X_customer_name)
         OR ((Recinfo.customer_name IS NULL)
         AND (X_customer_name IS NULL)))
     AND ((Recinfo.return_info =  X_return_info)
         OR ((Recinfo.return_info IS NULL)
         AND (X_return_info IS NULL)))
     AND ((Recinfo.bank_use =  X_bank_use)
         OR ((Recinfo.bank_use IS NULL)
         AND (X_bank_use IS NULL)))
     AND ((Recinfo.error_code =  X_error_code)
         OR ((Recinfo.error_code IS NULL)
         AND (X_error_code IS NULL)))
     AND ((Recinfo.cancellation_code =  X_cancellation_code)
         OR ((Recinfo.cancellation_code IS NULL)
         AND (X_cancellation_code IS NULL)))
     AND ((Recinfo.org_id =  X_Org_Id)
         OR ((Recinfo.org_id IS NULL)
         AND (X_Org_Id IS NULL)))
     AND ((Recinfo.creation_date =  X_Creation_Date)
         OR ((Recinfo.creation_date IS NULL)
         AND (X_Creation_Date IS NULL)))
     AND ((Recinfo.created_by =  X_Created_By)
         OR ((Recinfo.created_by IS NULL)
         AND (X_Created_By IS NULL)))) THEN
     return;
   ELSE
     FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
     APP_EXCEPTION.Raise_Exception;
   END IF;
   --
   EXCEPTION
     WHEN OTHERS THEN
       IF (SQLCODE <> -20001) THEN
          IF (SQLCODE = -54) THEN
             FND_MESSAGE.SET_NAME('SQLAP','AP_RESOURCE_BUSY');
          ELSE
             FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
             FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
             FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
             FND_MESSAGE.SET_TOKEN('PARAMETERS','FILE_CONTROL = ' ||
                                   X_FILE_CONTROL);
             FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
          END IF;
       END IF;
       APP_EXCEPTION.RAISE_EXCEPTION;
  --
END Lock_Row;

END JL_BR_AR_RET_INTERFACE_EXT_PKG;

/
