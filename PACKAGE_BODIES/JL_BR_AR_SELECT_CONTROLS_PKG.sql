--------------------------------------------------------
--  DDL for Package Body JL_BR_AR_SELECT_CONTROLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AR_SELECT_CONTROLS_PKG" as
/* $Header: jlbrrscb.pls 120.4 2003/07/11 18:58:15 appradha ship $ */

  PROCEDURE Insert_Row ( X_Rowid                             IN OUT NOCOPY VARCHAR2,

			 X_SELECTION_CONTROL_ID                     NUMBER,
			 X_SELECTION_STATUS                         VARCHAR2,
			 X_SELECTION_TYPE                           VARCHAR2,
			 X_NAME                                     VARCHAR2 ,
			 X_BORDERO_TYPE                             VARCHAR2 ,
			 X_SELECTION_DATE                           DATE ,
			 X_CANCELLATION_DATE                        DATE ,
			 X_GENERATION_DATE                          DATE ,
			 X_REMITTANCE_DATE                          DATE ,
			 X_DUE_DATE_BREAK_FLAG                      VARCHAR2 ,
			 X_INITIAL_DUE_DATE                         DATE ,
			 X_FINAL_DUE_DATE                           DATE ,
			 X_INITIAL_TRX_DATE                         DATE ,
			 X_FINAL_TRX_DATE                           DATE ,
			 X_CUST_TRX_TYPE_ID                         NUMBER ,
			 X_INITIAL_TRX_NUMBER                       VARCHAR2 ,
			 X_FINAL_TRX_NUMBER                         VARCHAR2 ,
			 X_INITIAL_CUSTOMER_NUMBER                  VARCHAR2 ,
			 X_FINAL_CUSTOMER_NUMBER                    VARCHAR2 ,
			 X_REQUEST_ID                               NUMBER ,
			 X_RECEIPT_METHOD_ID                        NUMBER ,
			 X_INITIAL_TRX_AMOUNT                       NUMBER ,
			 X_FINAL_TRX_AMOUNT                         NUMBER ,
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
    CURSOR C IS SELECT rowid FROM JL_BR_AR_SELECT_CONTROLS
                 WHERE selection_control_id = X_selection_control_id;
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

   BEGIN
--     Update the calling sequence
--
       current_calling_sequence := 'JL_BR_AR_SELECT_CONTROLS_PKG.INSERT_ROW<-' ||
                                    X_calling_sequence;

       debug_info := 'Insert into JL_BR_AR_SELECT_CONTROLS';
       INSERT INTO JL_BR_AR_SELECT_CONTROLS
              (
		 SELECTION_CONTROL_ID,
		 SELECTION_STATUS,
		 SELECTION_TYPE,
		 NAME,
		 BORDERO_TYPE,
		 SELECTION_DATE,
		 CANCELLATION_DATE,
		 GENERATION_DATE,
		 REMITTANCE_DATE,
		 DUE_DATE_BREAK_FLAG,
		 INITIAL_DUE_DATE,
		 FINAL_DUE_DATE,
		 INITIAL_TRX_DATE,
		 FINAL_TRX_DATE,
		 CUST_TRX_TYPE_ID,
		 INITIAL_TRX_NUMBER,
		 FINAL_TRX_NUMBER,
		 INITIAL_CUSTOMER_NUMBER,
		 FINAL_CUSTOMER_NUMBER,
		 REQUEST_ID,
		 RECEIPT_METHOD_ID,
		 INITIAL_TRX_AMOUNT,
		 FINAL_TRX_AMOUNT,
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
		 X_SELECTION_CONTROL_ID,
		 X_SELECTION_STATUS,
		 X_SELECTION_TYPE,
		 X_NAME,
		 X_BORDERO_TYPE,
		 X_SELECTION_DATE,
		 X_CANCELLATION_DATE,
		 X_GENERATION_DATE,
		 X_REMITTANCE_DATE,
		 X_DUE_DATE_BREAK_FLAG,
		 X_INITIAL_DUE_DATE,
		 X_FINAL_DUE_DATE,
		 X_INITIAL_TRX_DATE,
		 X_FINAL_TRX_DATE,
		 X_CUST_TRX_TYPE_ID,
		 X_INITIAL_TRX_NUMBER,
		 X_FINAL_TRX_NUMBER,
		 X_INITIAL_CUSTOMER_NUMBER,
		 X_FINAL_CUSTOMER_NUMBER,
		 X_REQUEST_ID,
		 X_RECEIPT_METHOD_ID,
		 X_INITIAL_TRX_AMOUNT,
		 X_FINAL_TRX_AMOUNT,
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
              FND_MESSAGE.SET_TOKEN('PARAMETERS','selection_control_id = ' ||
                                    X_selection_control_id );
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;


  PROCEDURE Lock_Row (   X_Rowid                                    VARCHAR2,

			 X_SELECTION_CONTROL_ID                     NUMBER,
			 X_SELECTION_STATUS                         VARCHAR2,
			 X_SELECTION_TYPE                           VARCHAR2,
			 X_NAME                                     VARCHAR2 ,
			 X_BORDERO_TYPE                             VARCHAR2 ,
			 X_SELECTION_DATE                           DATE ,
			 X_CANCELLATION_DATE                        DATE ,
			 X_GENERATION_DATE                          DATE ,
			 X_REMITTANCE_DATE                          DATE ,
			 X_DUE_DATE_BREAK_FLAG                      VARCHAR2 ,
			 X_INITIAL_DUE_DATE                         DATE ,
			 X_FINAL_DUE_DATE                           DATE ,
			 X_INITIAL_TRX_DATE                         DATE ,
			 X_FINAL_TRX_DATE                           DATE ,
			 X_CUST_TRX_TYPE_ID                         NUMBER ,
			 X_INITIAL_TRX_NUMBER                       VARCHAR2 ,
			 X_FINAL_TRX_NUMBER                         VARCHAR2 ,
			 X_INITIAL_CUSTOMER_NUMBER                  VARCHAR2 ,
			 X_FINAL_CUSTOMER_NUMBER                    VARCHAR2 ,
			 X_REQUEST_ID                               NUMBER ,
			 X_RECEIPT_METHOD_ID                        NUMBER ,
			 X_INITIAL_TRX_AMOUNT                       NUMBER ,
			 X_FINAL_TRX_AMOUNT                         NUMBER ,
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
        FROM   JL_BR_AR_SELECT_CONTROLS
        WHERE  rowid = X_Rowid
        FOR UPDATE of selection_control_id NOWAIT;
    Recinfo C%ROWTYPE;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'JL_BR_AR_SELECT_CONTROLS_PKG.LOCK_ROW<-' ||
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
           (Recinfo.selection_control_id =  X_selection_control_id)
           AND (Recinfo.selection_status =  X_selection_status)
           AND (Recinfo.selection_type =  X_selection_type)
           AND (   (Recinfo.NAME =  X_NAME)
                OR (    (Recinfo.NAME IS NULL)
                    AND (X_NAME IS NULL)))
           AND (   (Recinfo.BORDERO_TYPE =  X_BORDERO_TYPE)
                OR (    (Recinfo.BORDERO_TYPE IS NULL)
                    AND (X_BORDERO_TYPE IS NULL)))
           AND (   (Recinfo.SELECTION_DATE =  X_SELECTION_DATE)
                OR (    (Recinfo.SELECTION_DATE IS NULL)
                    AND (X_SELECTION_DATE IS NULL)))
           AND (   (Recinfo.CANCELLATION_DATE =  X_CANCELLATION_DATE)
                OR (    (Recinfo.CANCELLATION_DATE IS NULL)
                    AND (X_CANCELLATION_DATE IS NULL)))
           AND (   (Recinfo.GENERATION_DATE =  X_GENERATION_DATE)
                OR (    (Recinfo.GENERATION_DATE IS NULL)
                    AND (X_GENERATION_DATE IS NULL)))
           AND (   (Recinfo.REMITTANCE_DATE =  X_REMITTANCE_DATE)
                OR (    (Recinfo.REMITTANCE_DATE IS NULL)
                    AND (X_REMITTANCE_DATE IS NULL)))
           AND (   (Recinfo.DUE_DATE_BREAK_FLAG =  X_DUE_DATE_BREAK_FLAG)
                OR (    (Recinfo.DUE_DATE_BREAK_FLAG IS NULL)
                    AND (X_DUE_DATE_BREAK_FLAG IS NULL)))
           AND (   (Recinfo.INITIAL_DUE_DATE =  X_INITIAL_DUE_DATE)
                OR (    (Recinfo.INITIAL_DUE_DATE IS NULL)
                    AND (X_INITIAL_DUE_DATE IS NULL)))
           AND (   (Recinfo.FINAL_DUE_DATE =  X_FINAL_DUE_DATE)
                OR (    (Recinfo.FINAL_DUE_DATE IS NULL)
                    AND (X_FINAL_DUE_DATE IS NULL)))
           AND (   (Recinfo.INITIAL_TRX_DATE =  X_INITIAL_TRX_DATE)
                OR (    (Recinfo.INITIAL_TRX_DATE IS NULL)
                    AND (X_INITIAL_TRX_DATE IS NULL)))
           AND (   (Recinfo.FINAL_TRX_DATE =  X_FINAL_TRX_DATE)
                OR (    (Recinfo.FINAL_TRX_DATE IS NULL)
                    AND (X_FINAL_TRX_DATE IS NULL)))
           AND (   (Recinfo.INITIAL_TRX_NUMBER =  X_INITIAL_TRX_NUMBER)
                OR (    (Recinfo.INITIAL_TRX_NUMBER IS NULL)
                    AND (X_INITIAL_TRX_NUMBER IS NULL)))
           AND (   (Recinfo.FINAL_TRX_NUMBER =  X_FINAL_TRX_NUMBER)
                OR (    (Recinfo.FINAL_TRX_NUMBER IS NULL)
                    AND (X_FINAL_TRX_NUMBER IS NULL)))
           AND (   (Recinfo.INITIAL_CUSTOMER_NUMBER =  X_INITIAL_CUSTOMER_NUMBER)
                OR (    (Recinfo.INITIAL_CUSTOMER_NUMBER IS NULL)
                    AND (X_INITIAL_CUSTOMER_NUMBER IS NULL)))
           AND (   (Recinfo.FINAL_CUSTOMER_NUMBER =  X_FINAL_CUSTOMER_NUMBER)
                OR (    (Recinfo.FINAL_CUSTOMER_NUMBER IS NULL)
                    AND (X_FINAL_CUSTOMER_NUMBER IS NULL)))
           AND (   (Recinfo.REQUEST_ID =  X_REQUEST_ID)
                OR (    (Recinfo.REQUEST_ID IS NULL)
                    AND (X_REQUEST_ID IS NULL)))
           AND (   (Recinfo.RECEIPT_METHOD_ID =  X_RECEIPT_METHOD_ID)
                OR (    (Recinfo.RECEIPT_METHOD_ID IS NULL)
                    AND (X_RECEIPT_METHOD_ID IS NULL)))
           AND (   (Recinfo.INITIAL_TRX_AMOUNT =  X_INITIAL_TRX_AMOUNT)
                OR (    (Recinfo.INITIAL_TRX_AMOUNT IS NULL)
                    AND (X_INITIAL_TRX_AMOUNT IS NULL)))
           AND (   (Recinfo.FINAL_TRX_AMOUNT =  X_FINAL_TRX_AMOUNT)
                OR (    (Recinfo.FINAL_TRX_AMOUNT IS NULL)
                    AND (X_FINAL_TRX_AMOUNT IS NULL)))
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
             FND_MESSAGE.SET_TOKEN('PARAMETERS','selection_control_id = ' ||
                                    X_selection_control_id );
             FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
	 END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

  END Lock_Row;



  PROCEDURE Update_Row ( X_Rowid                                    VARCHAR2,

			 X_SELECTION_CONTROL_ID                     NUMBER,
			 X_SELECTION_STATUS                         VARCHAR2,
			 X_SELECTION_TYPE                           VARCHAR2,
			 X_NAME                                     VARCHAR2 ,
			 X_BORDERO_TYPE                             VARCHAR2 ,
			 X_SELECTION_DATE                           DATE ,
			 X_CANCELLATION_DATE                        DATE ,
			 X_GENERATION_DATE                          DATE ,
			 X_REMITTANCE_DATE                          DATE ,
			 X_DUE_DATE_BREAK_FLAG                      VARCHAR2 ,
			 X_INITIAL_DUE_DATE                         DATE ,
			 X_FINAL_DUE_DATE                           DATE ,
			 X_INITIAL_TRX_DATE                         DATE ,
			 X_FINAL_TRX_DATE                           DATE ,
			 X_CUST_TRX_TYPE_ID                         NUMBER ,
			 X_INITIAL_TRX_NUMBER                       VARCHAR2 ,
			 X_FINAL_TRX_NUMBER                         VARCHAR2 ,
			 X_INITIAL_CUSTOMER_NUMBER                  VARCHAR2 ,
			 X_FINAL_CUSTOMER_NUMBER                    VARCHAR2 ,
			 X_REQUEST_ID                               NUMBER ,
			 X_RECEIPT_METHOD_ID                        NUMBER ,
			 X_INITIAL_TRX_AMOUNT                       NUMBER ,
			 X_FINAL_TRX_AMOUNT                         NUMBER ,
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
    current_calling_sequence := 'JL_BR_AR_SELECT_CONTROLS_PKG.UPDATE_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Update JL_BR_AR_SELECT_CONTROLS';
    UPDATE JL_BR_AR_SELECT_CONTROLS
    SET
	 SELECTION_CONTROL_ID           =	 X_SELECTION_CONTROL_ID           ,
	 SELECTION_STATUS               =	 X_SELECTION_STATUS               ,
	 SELECTION_TYPE                 =	 X_SELECTION_TYPE                 ,
	 NAME                           =	 X_NAME                           ,
	 BORDERO_TYPE                   =	 X_BORDERO_TYPE                   ,
	 SELECTION_DATE                 =	 X_SELECTION_DATE                 ,
	 CANCELLATION_DATE              =	 X_CANCELLATION_DATE              ,
	 GENERATION_DATE                =	 X_GENERATION_DATE                ,
	 REMITTANCE_DATE                =	 X_REMITTANCE_DATE                ,
	 DUE_DATE_BREAK_FLAG            =	 X_DUE_DATE_BREAK_FLAG            ,
	 INITIAL_DUE_DATE               =	 X_INITIAL_DUE_DATE               ,
	 FINAL_DUE_DATE                 =	 X_FINAL_DUE_DATE                 ,
	 INITIAL_TRX_DATE               =	 X_INITIAL_TRX_DATE               ,
	 FINAL_TRX_DATE                 =	 X_FINAL_TRX_DATE                 ,
	 CUST_TRX_TYPE_ID               =	 X_CUST_TRX_TYPE_ID               ,
	 INITIAL_TRX_NUMBER             =	 X_INITIAL_TRX_NUMBER             ,
	 FINAL_TRX_NUMBER               =	 X_FINAL_TRX_NUMBER               ,
	 INITIAL_CUSTOMER_NUMBER        =	 X_INITIAL_CUSTOMER_NUMBER        ,
	 FINAL_CUSTOMER_NUMBER          =	 X_FINAL_CUSTOMER_NUMBER          ,
	 REQUEST_ID                     =	 X_REQUEST_ID                     ,
	 RECEIPT_METHOD_ID              =	 X_RECEIPT_METHOD_ID              ,
	 INITIAL_TRX_AMOUNT             =	 X_INITIAL_TRX_AMOUNT             ,
	 FINAL_TRX_AMOUNT               =	 X_FINAL_TRX_AMOUNT               ,
	 ATTRIBUTE_CATEGORY             =	 X_ATTRIBUTE_CATEGORY             ,
	 ATTRIBUTE1                     =	 X_ATTRIBUTE1                     ,
	 ATTRIBUTE2                     =	 X_ATTRIBUTE2                     ,
	 ATTRIBUTE3                     =	 X_ATTRIBUTE3                     ,
	 ATTRIBUTE4                     =	 X_ATTRIBUTE4                     ,
	 ATTRIBUTE5                     =	 X_ATTRIBUTE5                     ,
	 ATTRIBUTE6                     =	 X_ATTRIBUTE6                     ,
	 ATTRIBUTE7                     =	 X_ATTRIBUTE7                     ,
	 ATTRIBUTE8                     =	 X_ATTRIBUTE8                     ,
	 ATTRIBUTE9                     =	 X_ATTRIBUTE9                     ,
	 ATTRIBUTE10                    =	 X_ATTRIBUTE10                    ,
	 ATTRIBUTE11                    =	 X_ATTRIBUTE11                    ,
	 ATTRIBUTE12                    =	 X_ATTRIBUTE12                    ,
	 ATTRIBUTE13                    =	 X_ATTRIBUTE13                    ,
	 ATTRIBUTE14                    =	 X_ATTRIBUTE14                    ,
	 ATTRIBUTE15                    =	 X_ATTRIBUTE15                    ,
	 LAST_UPDATE_DATE               =	 X_LAST_UPDATE_DATE               ,
	 LAST_UPDATED_BY                =	 X_LAST_UPDATED_BY                ,
	 CREATION_DATE                  =	 X_CREATION_DATE                  ,
	 CREATED_BY                     =	 X_CREATED_BY                     ,
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
             FND_MESSAGE.SET_TOKEN('PARAMETERS','selection_control_id = ' ||
                                    X_selection_control_id );
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
    current_calling_sequence := 'JL_BR_AR_SELECT_CONTROLS_PKG.DELETE_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Delete from JL_BR_AR_SELECT_CONTROLS';
    DELETE FROM JL_BR_AR_SELECT_CONTROLS
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


END JL_BR_AR_SELECT_CONTROLS_PKG;

/
