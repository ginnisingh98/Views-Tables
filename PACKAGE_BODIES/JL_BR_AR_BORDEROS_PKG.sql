--------------------------------------------------------
--  DDL for Package Body JL_BR_AR_BORDEROS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AR_BORDEROS_PKG" as
/* $Header: jlbrrbdb.pls 120.5 2003/09/18 20:24:26 vsidhart ship $ */

  PROCEDURE Insert_Row ( X_Rowid                             IN OUT NOCOPY VARCHAR2,

			 X_BORDERO_ID                               NUMBER,
			 X_SELECTION_CONTROL_ID                     NUMBER,
			 X_BANK_ACCT_USE_ID                         NUMBER,
			 X_BORDERO_STATUS                           VARCHAR2,
			 X_SEQUENTIAL_NUMBER_GENERATION             NUMBER,
			 X_BORDERO_TYPE                             VARCHAR2,
			 X_TOTAL_COUNT                              NUMBER,
			 X_TOTAL_AMOUNT                             NUMBER,
			 X_SELECTION_DATE                           DATE,
			 X_REMITTANCE_DATE                          DATE,
			 X_REFUSED_DATE                             DATE,
			 X_CANCELLATION_DATE                        DATE,
			 X_COLLECTION_DATE                          DATE,
			 X_WRITE_OFF_DATE                           DATE,
			 X_DATE_IN_RECEIPT                          DATE,
			 X_RECEIVED_DATE                            DATE,
			 X_OUTPUT_PROGRAM_ID                        NUMBER,
			 X_SELECT_ACCOUNT_ID                        NUMBER,
			 X_OUTPUT_FORMAT                            VARCHAR2,
			 X_LAST_UPDATE_DATE                         DATE,
			 X_LAST_UPDATED_BY                          NUMBER,
			 X_CREATION_DATE                            DATE,
			 X_CREATED_BY                               NUMBER,
			 X_LAST_UPDATE_LOGIN                        NUMBER,

		         X_calling_sequence		            VARCHAR2,
                         X_ORG_ID                                   NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM JL_BR_AR_BORDEROS
                 WHERE bordero_id = X_bordero_id;
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

   BEGIN
--     Update the calling sequence
--
       current_calling_sequence := 'JL_BR_AR_BORDEROS_PKG.INSERT_ROW<-' ||
                                    X_calling_sequence;

       debug_info := 'Insert into JL_BR_AR_BORDEROS';
       INSERT INTO JL_BR_AR_BORDEROS
              (
		 BORDERO_ID,
		 SELECTION_CONTROL_ID,
		 BANK_ACCT_USE_ID,
		 BORDERO_STATUS,
		 SEQUENTIAL_NUMBER_GENERATION,
		 BORDERO_TYPE,
		 TOTAL_COUNT,
		 TOTAL_AMOUNT,
		 SELECTION_DATE,
		 REMITTANCE_DATE,
		 REFUSED_DATE,
		 CANCELLATION_DATE,
		 COLLECTION_DATE,
		 WRITE_OFF_DATE,
		 DATE_IN_RECEIPT,
		 RECEIVED_DATE,
		 OUTPUT_PROGRAM_ID,
		 SELECT_ACCOUNT_ID,
		 OUTPUT_FORMAT,
		 LAST_UPDATE_DATE,
		 LAST_UPDATED_BY,
		 CREATION_DATE,
		 CREATED_BY,
		 LAST_UPDATE_LOGIN,
                 ORG_ID
              )
       VALUES (
		 X_BORDERO_ID,
		 X_SELECTION_CONTROL_ID,
		 X_BANK_ACCT_USE_ID,
		 X_BORDERO_STATUS,
		 X_SEQUENTIAL_NUMBER_GENERATION,
		 X_BORDERO_TYPE,
		 X_TOTAL_COUNT,
		 X_TOTAL_AMOUNT,
		 X_SELECTION_DATE,
		 X_REMITTANCE_DATE,
		 X_REFUSED_DATE,
		 X_CANCELLATION_DATE,
		 X_COLLECTION_DATE,
		 X_WRITE_OFF_DATE,
		 X_DATE_IN_RECEIPT,
		 X_RECEIVED_DATE,
		 X_OUTPUT_PROGRAM_ID,
		 X_SELECT_ACCOUNT_ID,
		 X_OUTPUT_FORMAT,
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
              FND_MESSAGE.SET_TOKEN('PARAMETERS','bordero_id = ' ||
                                    X_bordero_id );
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;


  PROCEDURE Lock_Row (   X_Rowid                                    VARCHAR2,

			 X_BORDERO_ID                               NUMBER,
			 X_SELECTION_CONTROL_ID                     NUMBER,
			 X_BANK_ACCT_USE_ID                         NUMBER,
			 X_BORDERO_STATUS                           VARCHAR2,
			 X_SEQUENTIAL_NUMBER_GENERATION             NUMBER,
			 X_BORDERO_TYPE                             VARCHAR2,
			 X_TOTAL_COUNT                              NUMBER,
			 X_TOTAL_AMOUNT                             NUMBER,
			 X_SELECTION_DATE                           DATE,
			 X_REMITTANCE_DATE                          DATE,
			 X_REFUSED_DATE                             DATE,
			 X_CANCELLATION_DATE                        DATE,
			 X_COLLECTION_DATE                          DATE,
			 X_WRITE_OFF_DATE                           DATE,
			 X_DATE_IN_RECEIPT                          DATE,
			 X_RECEIVED_DATE                            DATE,
			 X_OUTPUT_PROGRAM_ID                        NUMBER,
			 X_SELECT_ACCOUNT_ID                        NUMBER,
			 X_OUTPUT_FORMAT                            VARCHAR2,
			 X_LAST_UPDATE_DATE                         DATE,
			 X_LAST_UPDATED_BY                          NUMBER,
			 X_CREATION_DATE                            DATE,
			 X_CREATED_BY                               NUMBER,
			 X_LAST_UPDATE_LOGIN                        NUMBER,

		         X_calling_sequence		            VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   JL_BR_AR_BORDEROS
        WHERE  rowid = X_Rowid
        FOR UPDATE of bordero_id NOWAIT;
    Recinfo C%ROWTYPE;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'JL_BR_AR_BORDEROS_PKG.LOCK_ROW<-' ||
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
           (Recinfo.bordero_id =  X_bordero_id)
           AND (Recinfo.selection_control_id =  X_selection_control_id)
           AND (Recinfo.bank_acct_use_id =  X_bank_acct_use_id)
           AND (Recinfo.bordero_status =  X_bordero_status)
           AND (   (Recinfo.SEQUENTIAL_NUMBER_GENERATION =  X_SEQUENTIAL_NUMBER_GENERATION)
                OR (    (Recinfo.SEQUENTIAL_NUMBER_GENERATION IS NULL)
                    AND (X_SEQUENTIAL_NUMBER_GENERATION IS NULL)))
           AND (   (Recinfo.BORDERO_TYPE =  X_BORDERO_TYPE)
                OR (    (Recinfo.BORDERO_TYPE IS NULL)
                    AND (X_BORDERO_TYPE IS NULL)))
           AND (   (Recinfo.TOTAL_COUNT =  X_TOTAL_COUNT)
                OR (    (Recinfo.TOTAL_COUNT IS NULL)
                    AND (X_TOTAL_COUNT IS NULL)))
           AND (   (Recinfo.TOTAL_AMOUNT =  X_TOTAL_AMOUNT)
                OR (    (Recinfo.TOTAL_AMOUNT IS NULL)
                    AND (X_TOTAL_AMOUNT IS NULL)))
           AND (   (Recinfo.SELECTION_DATE =  X_SELECTION_DATE)
                OR (    (Recinfo.SELECTION_DATE IS NULL)
                    AND (X_SELECTION_DATE IS NULL)))
           AND (   (Recinfo.REMITTANCE_DATE =  X_REMITTANCE_DATE)
                OR (    (Recinfo.REMITTANCE_DATE IS NULL)
                    AND (X_REMITTANCE_DATE IS NULL)))
           AND (   (Recinfo.REFUSED_DATE =  X_REFUSED_DATE)
                OR (    (Recinfo.REFUSED_DATE IS NULL)
                    AND (X_REFUSED_DATE IS NULL)))
           AND (   (Recinfo.CANCELLATION_DATE =  X_CANCELLATION_DATE)
                OR (    (Recinfo.CANCELLATION_DATE IS NULL)
                    AND (X_CANCELLATION_DATE IS NULL)))
           AND (   (Recinfo.COLLECTION_DATE =  X_COLLECTION_DATE)
                OR (    (Recinfo.COLLECTION_DATE IS NULL)
                    AND (X_COLLECTION_DATE IS NULL)))
           AND (   (Recinfo.WRITE_OFF_DATE =  X_WRITE_OFF_DATE)
                OR (    (Recinfo.WRITE_OFF_DATE IS NULL)
                    AND (X_WRITE_OFF_DATE IS NULL)))
           AND (   (Recinfo.DATE_IN_RECEIPT =  X_DATE_IN_RECEIPT)
                OR (    (Recinfo.DATE_IN_RECEIPT IS NULL)
                    AND (X_DATE_IN_RECEIPT IS NULL)))
           AND (   (Recinfo.RECEIVED_DATE =  X_RECEIVED_DATE)
                OR (    (Recinfo.RECEIVED_DATE IS NULL)
                    AND (X_RECEIVED_DATE IS NULL)))
           AND (   (Recinfo.OUTPUT_PROGRAM_ID =  X_OUTPUT_PROGRAM_ID)
                OR (    (Recinfo.OUTPUT_PROGRAM_ID IS NULL)
                    AND (X_OUTPUT_PROGRAM_ID IS NULL)))
           AND (   (Recinfo.SELECT_ACCOUNT_ID =  X_SELECT_ACCOUNT_ID)
                OR (    (Recinfo.SELECT_ACCOUNT_ID IS NULL)
                    AND (X_SELECT_ACCOUNT_ID IS NULL)))
           AND (   (Recinfo.OUTPUT_FORMAT =  X_OUTPUT_FORMAT)
                OR (    (Recinfo.OUTPUT_FORMAT IS NULL)
                    AND (X_OUTPUT_FORMAT IS NULL)))
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
             FND_MESSAGE.SET_TOKEN('PARAMETERS','bordero_id = ' ||
                                    X_bordero_id );
             FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
	 END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

  END Lock_Row;



  PROCEDURE Update_Row ( X_Rowid                                    VARCHAR2,

			 X_BORDERO_ID                               NUMBER,
			 X_SELECTION_CONTROL_ID                     NUMBER,
			 X_BANK_ACCT_USE_ID                         NUMBER,
			 X_BORDERO_STATUS                           VARCHAR2,
			 X_SEQUENTIAL_NUMBER_GENERATION             NUMBER,
			 X_BORDERO_TYPE                             VARCHAR2,
			 X_TOTAL_COUNT                              NUMBER,
			 X_TOTAL_AMOUNT                             NUMBER,
			 X_SELECTION_DATE                           DATE,
			 X_REMITTANCE_DATE                          DATE,
			 X_REFUSED_DATE                             DATE,
			 X_CANCELLATION_DATE                        DATE,
			 X_COLLECTION_DATE                          DATE,
			 X_WRITE_OFF_DATE                           DATE,
			 X_DATE_IN_RECEIPT                          DATE,
			 X_RECEIVED_DATE                            DATE,
			 X_OUTPUT_PROGRAM_ID                        NUMBER,
			 X_SELECT_ACCOUNT_ID                        NUMBER,
			 X_OUTPUT_FORMAT                            VARCHAR2,
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
    current_calling_sequence := 'JL_BR_AR_BORDEROS_PKG.UPDATE_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Update JL_BR_AR_BORDEROS';
    UPDATE JL_BR_AR_BORDEROS
    SET
	 BORDERO_ID                     =	 X_BORDERO_ID                       ,
	 SELECTION_CONTROL_ID           =	 X_SELECTION_CONTROL_ID             ,
	 BANK_ACCT_USE_ID               =	 X_BANK_ACCT_USE_ID                  ,
	 BORDERO_STATUS                 =	 X_BORDERO_STATUS                   ,
	 SEQUENTIAL_NUMBER_GENERATION   =	 X_SEQUENTIAL_NUMBER_GENERATION     ,
	 BORDERO_TYPE                   =	 X_BORDERO_TYPE                     ,
	 TOTAL_COUNT                    =	 X_TOTAL_COUNT                      ,
	 TOTAL_AMOUNT                   =	 X_TOTAL_AMOUNT                     ,
	 SELECTION_DATE                 =	 X_SELECTION_DATE                   ,
	 REMITTANCE_DATE                =	 X_REMITTANCE_DATE                  ,
	 REFUSED_DATE                   =	 X_REFUSED_DATE                     ,
	 CANCELLATION_DATE              =	 X_CANCELLATION_DATE                ,
	 COLLECTION_DATE                =	 X_COLLECTION_DATE                  ,
	 WRITE_OFF_DATE                 =	 X_WRITE_OFF_DATE                   ,
	 DATE_IN_RECEIPT                =	 X_DATE_IN_RECEIPT                  ,
	 RECEIVED_DATE                  =	 X_RECEIVED_DATE                    ,
	 OUTPUT_PROGRAM_ID              =	 X_OUTPUT_PROGRAM_ID                ,
	 SELECT_ACCOUNT_ID              =	 X_SELECT_ACCOUNT_ID                ,
	 OUTPUT_FORMAT                  =	 X_OUTPUT_FORMAT                    ,
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
             FND_MESSAGE.SET_TOKEN('PARAMETERS','bordero_id = ' ||
                                    X_bordero_id );
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
    current_calling_sequence := 'JL_BR_AR_BORDEROS_PKG.DELETE_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Delete from JL_BR_AR_BORDEROS';
    DELETE FROM JL_BR_AR_BORDEROS
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


END JL_BR_AR_BORDEROS_PKG;

/
