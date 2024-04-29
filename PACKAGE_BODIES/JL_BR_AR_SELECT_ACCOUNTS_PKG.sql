--------------------------------------------------------
--  DDL for Package Body JL_BR_AR_SELECT_ACCOUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AR_SELECT_ACCOUNTS_PKG" as
/* $Header: jlbrrsab.pls 120.5 2003/09/18 21:03:34 vsidhart ship $ */

  PROCEDURE Insert_Row ( X_Rowid                             IN OUT NOCOPY VARCHAR2,

			 X_SELECT_ACCOUNT_ID                        NUMBER,
			 X_SELECTION_CONTROL_ID                     NUMBER,
			 X_BANK_ACCT_USE_ID                         NUMBER,
			 X_GL_DATE                                  DATE ,
			 X_SELECTION_DATE                           DATE ,
			 X_CANCELLATION_DATE                        DATE ,
			 X_FORMAT_DATE                              DATE ,
			 X_REMITTANCE_DATE                          DATE ,
			 X_PORTFOLIO_CODE                           NUMBER ,
			 X_MIN_DOCUMENT_AMOUNT                      NUMBER ,
			 X_MAX_DOCUMENT_AMOUNT                      NUMBER ,
			 X_MIN_REMITTANCE_AMOUNT                    NUMBER ,
			 X_MAX_REMITTANCE_AMOUNT                    NUMBER ,
			 X_BANK_INSTRUCTION_CODE1                   NUMBER ,
			 X_BANK_INSTRUCTION_CODE2                   NUMBER ,
			 X_BANK_CHARGE_AMOUNT                       NUMBER ,
			 X_BATCH_SOURCE_ID                          NUMBER ,
			 X_PERCENTAGE_DISTRIBUTION                  NUMBER ,
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
    CURSOR C IS SELECT rowid FROM JL_BR_AR_SELECT_ACCOUNTS
                 WHERE select_account_id = X_select_account_id;
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

   BEGIN
--     Update the calling sequence
--
       current_calling_sequence := 'JL_BR_AR_SELECT_ACCOUNTS_PKG.INSERT_ROW<-' ||
                                    X_calling_sequence;

       debug_info := 'Insert into JL_BR_AR_SELECT_ACCOUNTS';
       INSERT INTO JL_BR_AR_SELECT_ACCOUNTS
              (
		 SELECT_ACCOUNT_ID,
		 SELECTION_CONTROL_ID,
		 BANK_ACCT_USE_ID,
		 GL_DATE,
		 SELECTION_DATE,
		 CANCELLATION_DATE,
		 FORMAT_DATE,
		 REMITTANCE_DATE,
		 PORTFOLIO_CODE,
		 MIN_DOCUMENT_AMOUNT,
		 MAX_DOCUMENT_AMOUNT,
		 MIN_REMITTANCE_AMOUNT,
		 MAX_REMITTANCE_AMOUNT,
		 BANK_INSTRUCTION_CODE1,
		 BANK_INSTRUCTION_CODE2,
		 BANK_CHARGE_AMOUNT,
		 BATCH_SOURCE_ID,
		 PERCENTAGE_DISTRIBUTION,
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
		 X_SELECT_ACCOUNT_ID,
		 X_SELECTION_CONTROL_ID,
		 X_BANK_ACCT_USE_ID,
		 X_GL_DATE,
		 X_SELECTION_DATE,
		 X_CANCELLATION_DATE,
		 X_FORMAT_DATE,
		 X_REMITTANCE_DATE,
		 X_PORTFOLIO_CODE,
		 X_MIN_DOCUMENT_AMOUNT,
		 X_MAX_DOCUMENT_AMOUNT,
		 X_MIN_REMITTANCE_AMOUNT,
		 X_MAX_REMITTANCE_AMOUNT,
		 X_BANK_INSTRUCTION_CODE1,
		 X_BANK_INSTRUCTION_CODE2,
		 X_BANK_CHARGE_AMOUNT,
		 X_BATCH_SOURCE_ID,
		 X_PERCENTAGE_DISTRIBUTION,
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
              FND_MESSAGE.SET_TOKEN('PARAMETERS','select_account_id = ' ||
                                    X_select_account_id );
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;


  PROCEDURE Lock_Row (   X_Rowid                                    VARCHAR2,

			 X_SELECT_ACCOUNT_ID                        NUMBER,
			 X_SELECTION_CONTROL_ID                     NUMBER,
			 X_BANK_ACCT_USE_ID                         NUMBER,
			 X_GL_DATE                                  DATE ,
			 X_SELECTION_DATE                           DATE ,
			 X_CANCELLATION_DATE                        DATE ,
			 X_FORMAT_DATE                              DATE ,
			 X_REMITTANCE_DATE                          DATE ,
			 X_PORTFOLIO_CODE                           NUMBER ,
			 X_MIN_DOCUMENT_AMOUNT                      NUMBER ,
			 X_MAX_DOCUMENT_AMOUNT                      NUMBER ,
			 X_MIN_REMITTANCE_AMOUNT                    NUMBER ,
			 X_MAX_REMITTANCE_AMOUNT                    NUMBER ,
			 X_BANK_INSTRUCTION_CODE1                   NUMBER ,
			 X_BANK_INSTRUCTION_CODE2                   NUMBER ,
			 X_BANK_CHARGE_AMOUNT                       NUMBER ,
			 X_BATCH_SOURCE_ID                          NUMBER ,
			 X_PERCENTAGE_DISTRIBUTION                  NUMBER ,
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
    CURSOR C IS
        SELECT *
        FROM   JL_BR_AR_SELECT_ACCOUNTS
        WHERE  rowid = X_Rowid
        FOR UPDATE of select_account_id NOWAIT;
    Recinfo C%ROWTYPE;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'JL_BR_AR_SELECT_ACCOUNTS_PKG.LOCK_ROW<-' ||
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
           (Recinfo.select_account_id =  X_select_account_id)
           AND (Recinfo.selection_control_id =  X_selection_control_id)
           AND (Recinfo.bank_acct_use_id =  X_bank_acct_use_id)
           AND (   (Recinfo.GL_DATE =  X_GL_DATE)
                OR (    (Recinfo.GL_DATE IS NULL)
                    AND (X_GL_DATE IS NULL)))
           AND (   (Recinfo.SELECTION_DATE =  X_SELECTION_DATE)
                OR (    (Recinfo.SELECTION_DATE IS NULL)
                    AND (X_SELECTION_DATE IS NULL)))
           AND (   (Recinfo.CANCELLATION_DATE =  X_CANCELLATION_DATE)
                OR (    (Recinfo.CANCELLATION_DATE IS NULL)
                    AND (X_CANCELLATION_DATE IS NULL)))
           AND (   (Recinfo.FORMAT_DATE =  X_FORMAT_DATE)
                OR (    (Recinfo.FORMAT_DATE IS NULL)
                    AND (X_FORMAT_DATE IS NULL)))
           AND (   (Recinfo.REMITTANCE_DATE =  X_REMITTANCE_DATE)
                OR (    (Recinfo.REMITTANCE_DATE IS NULL)
                    AND (X_REMITTANCE_DATE IS NULL)))
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
           AND (   (Recinfo.BATCH_SOURCE_ID =  X_BATCH_SOURCE_ID)
                OR (    (Recinfo.BATCH_SOURCE_ID IS NULL)
                    AND (X_BATCH_SOURCE_ID IS NULL)))
           AND (   (Recinfo.PERCENTAGE_DISTRIBUTION =  X_PERCENTAGE_DISTRIBUTION)
                OR (    (Recinfo.PERCENTAGE_DISTRIBUTION IS NULL)
                    AND (X_PERCENTAGE_DISTRIBUTION IS NULL)))
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
             FND_MESSAGE.SET_TOKEN('PARAMETERS','select_account_id = ' ||
                                    X_select_account_id );
             FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
	 END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

  END Lock_Row;



  PROCEDURE Update_Row ( X_Rowid                                    VARCHAR2,

			 X_SELECT_ACCOUNT_ID                        NUMBER,
			 X_SELECTION_CONTROL_ID                     NUMBER,
			 X_BANK_ACCT_USE_ID                         NUMBER,
			 X_GL_DATE                                  DATE ,
			 X_SELECTION_DATE                           DATE ,
			 X_CANCELLATION_DATE                        DATE ,
			 X_FORMAT_DATE                              DATE ,
			 X_REMITTANCE_DATE                          DATE ,
			 X_PORTFOLIO_CODE                           NUMBER ,
			 X_MIN_DOCUMENT_AMOUNT                      NUMBER ,
			 X_MAX_DOCUMENT_AMOUNT                      NUMBER ,
			 X_MIN_REMITTANCE_AMOUNT                    NUMBER ,
			 X_MAX_REMITTANCE_AMOUNT                    NUMBER ,
			 X_BANK_INSTRUCTION_CODE1                   NUMBER ,
			 X_BANK_INSTRUCTION_CODE2                   NUMBER ,
			 X_BANK_CHARGE_AMOUNT                       NUMBER ,
			 X_BATCH_SOURCE_ID                          NUMBER ,
			 X_PERCENTAGE_DISTRIBUTION                  NUMBER ,
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
    current_calling_sequence := 'JL_BR_AR_SELECT_ACCOUNTS_PKG.UPDATE_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Update JL_BR_AR_SELECT_ACCOUNTS';
    UPDATE JL_BR_AR_SELECT_ACCOUNTS
    SET
	 SELECT_ACCOUNT_ID              =	 X_SELECT_ACCOUNT_ID                ,
	 SELECTION_CONTROL_ID           =	 X_SELECTION_CONTROL_ID             ,
	 BANK_ACCT_USE_ID                =	 X_BANK_ACCT_USE_ID                  ,
	 GL_DATE                        =	 X_GL_DATE                          ,
	 SELECTION_DATE                 =	 X_SELECTION_DATE                   ,
	 CANCELLATION_DATE              =	 X_CANCELLATION_DATE                ,
	 FORMAT_DATE                    =	 X_FORMAT_DATE                      ,
	 REMITTANCE_DATE                =	 X_REMITTANCE_DATE                  ,
	 PORTFOLIO_CODE                 =	 X_PORTFOLIO_CODE                   ,
	 MIN_DOCUMENT_AMOUNT            =	 X_MIN_DOCUMENT_AMOUNT              ,
	 MAX_DOCUMENT_AMOUNT            =	 X_MAX_DOCUMENT_AMOUNT              ,
	 MIN_REMITTANCE_AMOUNT          =	 X_MIN_REMITTANCE_AMOUNT            ,
	 MAX_REMITTANCE_AMOUNT          =	 X_MAX_REMITTANCE_AMOUNT            ,
	 BANK_INSTRUCTION_CODE1         =	 X_BANK_INSTRUCTION_CODE1           ,
	 BANK_INSTRUCTION_CODE2         =	 X_BANK_INSTRUCTION_CODE2           ,
	 BANK_CHARGE_AMOUNT             =	 X_BANK_CHARGE_AMOUNT               ,
	 BATCH_SOURCE_ID                =	 X_BATCH_SOURCE_ID                  ,
	 PERCENTAGE_DISTRIBUTION        =	 X_PERCENTAGE_DISTRIBUTION          ,
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
             FND_MESSAGE.SET_TOKEN('PARAMETERS','select_account_id = ' ||
                                    X_select_account_id );
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
    current_calling_sequence := 'JL_BR_AR_SELECT_ACCOUNTS_PKG.DELETE_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Delete from JL_BR_AR_SELECT_ACCOUNTS';
    DELETE FROM JL_BR_AR_SELECT_ACCOUNTS
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


END JL_BR_AR_SELECT_ACCOUNTS_PKG;

/
