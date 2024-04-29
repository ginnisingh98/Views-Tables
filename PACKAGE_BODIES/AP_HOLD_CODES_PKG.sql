--------------------------------------------------------
--  DDL for Package Body AP_HOLD_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_HOLD_CODES_PKG" as
/* $Header: apihdcob.pls 120.5.12010000.2 2009/11/30 05:20:27 asansari ship $ */




  PROCEDURE Check_Unique(X_Rowid                    VARCHAR2,
                         X_Hold_Lookup_Code         VARCHAR2,
			 X_calling_sequence	IN  VARCHAR2
                        ) IS
    Dummy NUMBER;
    current_calling_sequence	VARCHAR2(2000);
    debug_info			VARCHAR2(100);
  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'AP_HOLD_CODES_PKG.CHECK_UNIQUE<-' ||
                                 X_calling_sequence;

--  Check if hold_lookup_code is unique
--
    debug_info := 'Checking hold_lookup_code uniqueness';

    SELECT count(1)
    INTO   Dummy
    FROM   ap_hold_codes
    WHERE  upper(hold_lookup_code) = upper(X_Hold_Lookup_Code)
    AND    ((X_Rowid IS NULL) OR (rowid <> X_Rowid));

    IF (Dummy >= 1) then
      FND_MESSAGE.SET_NAME('SQLAP', 'AP_ALL_DUPLICATE_VALUE');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    EXCEPTION
	WHEN OTHERS THEN
	   IF (SQLCODE <> -20001) THEN
	      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
	      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
	      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
	      FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_Rowid ||
				    ', HOLD_LOOKUP_CODE = ' || X_Hold_Lookup_Code);
	      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
	   END IF;
	   APP_EXCEPTION.RAISE_EXCEPTION;

  END CHECK_UNIQUE;



  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Hold_Type                      VARCHAR2,
                       X_Hold_Lookup_Code               VARCHAR2,
                       X_Description                    VARCHAR2 DEFAULT NULL,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_User_Releaseable_Flag          VARCHAR2,
                       X_User_Updateable_Flag           VARCHAR2,
                       X_Inactive_Date                  DATE DEFAULT NULL,
                       X_Postable_Flag                  VARCHAR2,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Creation_Date                  DATE DEFAULT NULL,
                       X_Created_By                     NUMBER DEFAULT NULL,
                       /* Bug 5206670. Hold Workflow related change */
                       X_Initiate_Workflow_Flag         VARCHAR2 DEFAULT NULL,
                       X_Wait_Before_Notify_Days        NUMBER DEFAULT NULL,
                       X_Reminder_Days                  NUMBER DEFAULT NULL,
                       X_Hold_Instruction               VARCHAR2 DEFAULT NULL,
		       X_calling_sequence	 IN	VARCHAR2
  ) IS
    CURSOR C IS SELECT rowid FROM ap_hold_codes
                 WHERE hold_lookup_code = X_Hold_Lookup_Code;
    current_calling_sequence	VARCHAR2(2000);
    debug_info			VARCHAR2(100);
   BEGIN

--     Update the calling sequence
--
       current_calling_sequence := 'AP_HOLD_CODES_PKG.INSERT_ROW<-' ||
                                    X_calling_sequence;

--     Check if unique values
       AP_HOLD_CODES_PKG.check_unique(X_Rowid, X_Hold_Lookup_Code, current_calling_sequence);

--     Insert values into ap_hold_codes
--
       debug_info := 'Inserting in ap_hold_codes';

       INSERT INTO ap_hold_codes(
              hold_type,
              hold_lookup_code,
              description,
              last_update_date,
              last_updated_by,
              user_releaseable_flag,
              user_updateable_flag,
              inactive_date,
              postable_flag,
              last_update_login,
              creation_date,
              created_by,
              initiate_workflow_flag,
              wait_before_notify_days,
              reminder_days,
              hold_instruction
             ) VALUES (

              X_Hold_Type,
              X_Hold_Lookup_Code,
              X_Description,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_User_Releaseable_Flag,
              X_User_Updateable_Flag,
              X_Inactive_Date,
              X_Postable_Flag,
              X_Last_Update_Login,
              X_Creation_Date,
              X_Created_By,
              X_initiate_workflow_flag,
              X_wait_before_notify_days,
              X_reminder_days,
              X_Hold_Instruction
             );


--    Insert values into fnd_lookup_values
--
      debug_info := 'Inserting in fnd_lookup_values';

      INSERT INTO fnd_lookup_values(
	      lookup_type,
              security_group_id,
              view_application_id,
              language,
              lookup_code,
              meaning,
              description,
              enabled_flag,
              end_date_active,
              created_by,
              creation_date,
              last_updated_by,
              last_update_login,
              last_update_date,
              source_lang,
              attribute_category,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15
	) select
	      'HOLD CODE',
	      0,
              200,
              L.LANGUAGE_CODE,
              X_Hold_Lookup_Code,
	      X_Hold_Lookup_Code,
	      X_Description,
              'Y',
              X_Inactive_Date,
              X_Created_By,
              X_Creation_Date,
              X_Last_Updated_By,
              X_Last_Update_Login,
              X_Last_Update_Date,
	      userenv('LANG'),
	      '',
	      '',
	      '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              ''
	  from FND_LANGUAGES L
          where L.INSTALLED_FLAG in ('I', 'B')
	  and not exists
 	     (select NULL
              from fnd_lookup_values FLV
              where FLV.lookup_type = 'HOLD CODE'
              and   FLV.lookup_code = X_Hold_Lookup_Code
	      and   FLV.language = L.LANGUAGE_CODE);


--  Open cursor to check existence of hold_lookup_code in ap_hold_codes
--
    debug_info := 'Open cursor C on ap_hold_codes';

    OPEN C;

    debug_info := 'Fetch cursor C';

    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
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
	      FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_Rowid ||
                       		    ', HOLD_LOOKUP_CODE = ' || X_Hold_Lookup_Code);
	      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
	   END IF;
	   APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Hold_Type                        VARCHAR2,
                     X_Hold_Lookup_Code                 VARCHAR2,
                     X_Description                      VARCHAR2 DEFAULT NULL,
                     X_User_Releaseable_Flag            VARCHAR2,
                     X_User_Updateable_Flag             VARCHAR2,
                     X_Inactive_Date                    DATE DEFAULT NULL,
                     X_Postable_Flag                    VARCHAR2,
                     /* Bug 5206670. Hold Workflow related change */
                     X_Initiate_Workflow_Flag         VARCHAR2 DEFAULT NULL,
                     X_Wait_Before_Notify_Days        NUMBER DEFAULT NULL,
                     X_Reminder_Days                  NUMBER DEFAULT NULL,
                     X_Hold_Instruction               VARCHAR2 DEFAULT NULL,
		     X_calling_sequence		IN	VARCHAR2
  ) IS
    --Bug9009032: Modified cursor C.
    CURSOR C IS
        SELECT  AHC.HOLD_TYPE HOLD_TYPE
		, AHC.HOLD_LOOKUP_CODE HOLD_LOOKUP_CODE
		,ALC.DESCRIPTION DESCRIPTION
		, AHC.USER_RELEASEABLE_FLAG USER_RELEASEABLE_FLAG
		, AHC.USER_UPDATEABLE_FLAG USER_UPDATEABLE_FLAG
		, AHC.INACTIVE_DATE INACTIVE_DATE
		, AHC.POSTABLE_FLAG POSTABLE_FLAG
		, AHC.INITIATE_WORKFLOW_FLAG INITIATE_WORKFLOW_FLAG
		, AHC.WAIT_BEFORE_NOTIFY_DAYS WAIT_BEFORE_NOTIFY_DAYS
		, AHC.REMINDER_DAYS REMINDER_DAYS
		, AHC.HOLD_INSTRUCTION HOLD_INSTRUCTION
	FROM  ap_hold_codes ahc,
              ap_lookup_codes alc
        WHERE  ahc.rowid = X_Rowid
	and  ahc.hold_lookup_code = alc.lookup_code
	and alc.LOOKUP_TYPE = 'HOLD CODE'
        FOR UPDATE of ahc.hold_lookup_code NOWAIT;
    Recinfo C%ROWTYPE;
    current_calling_sequence	VARCHAR2(2000);
    debug_info			VARCHAR2(100);

  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'AP_HOLD_CODES_PKG.LOCK_ROW<-' ||
                                 X_calling_sequence;

--  Open cursor on ap_hold_codes
--
    debug_info := 'Open cursor C  on ap_hold_codes';

    OPEN C;

    debug_info := 'Fetch cursor C';

    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;

    debug_info := 'Close cursor C';

    CLOSE C;
    if (
               (Recinfo.hold_type =  X_Hold_Type)
           AND (Recinfo.hold_lookup_code =  X_Hold_Lookup_Code)
           AND (   (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
           AND (   (Recinfo.user_releaseable_flag =  X_User_Releaseable_Flag)
                OR (    (Recinfo.user_releaseable_flag IS NULL)
                    AND (X_User_Releaseable_Flag IS NULL)))
           AND (   (Recinfo.user_updateable_flag =  X_User_Updateable_Flag)
                OR (    (Recinfo.user_updateable_flag IS NULL)
                    AND (X_User_Updateable_Flag IS NULL)))
           AND (   (Recinfo.inactive_date =  X_Inactive_Date)
                OR (    (Recinfo.inactive_date IS NULL)
                    AND (X_Inactive_Date IS NULL)))
           AND (   (Recinfo.postable_flag =  X_Postable_Flag)
                OR (    (Recinfo.postable_flag IS NULL)
                    AND (X_Postable_Flag IS NULL)))
           AND (   (Recinfo.initiate_workflow_flag =  X_Initiate_Workflow_Flag)
                OR (    (Recinfo.initiate_workflow_flag IS NULL)
                    AND (X_Initiate_Workflow_Flag IS NULL)))
           AND (   (Recinfo.wait_before_notify_days =  X_Wait_Before_Notify_Days)
                OR (    (Recinfo.wait_before_notify_days IS NULL)
                    AND (X_Wait_Before_Notify_Days IS NULL)))
           AND (   (Recinfo.reminder_days =  X_reminder_Days)
                OR (    (Recinfo.reminder_days IS NULL)
                    AND (X_Reminder_Days IS NULL)))
           AND (   (Recinfo.hold_instruction =  X_Hold_Instruction)
                OR (    (Recinfo.hold_instruction IS NULL)
                    AND (X_hold_instruction IS NULL)))
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
	     FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_Rowid ||
                 		   ', HOLD_LOOKUP_CODE = ' || X_Hold_Lookup_Code);
	     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
	   END IF;
	 END IF;
	 APP_EXCEPTION.RAISE_EXCEPTION;

  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Hold_Type                      VARCHAR2,
                       X_Hold_Lookup_Code               VARCHAR2,
                       X_Description                    VARCHAR2 DEFAULT NULL,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_User_Releaseable_Flag          VARCHAR2,
                       X_User_Updateable_Flag           VARCHAR2,
                       X_Inactive_Date                  DATE DEFAULT NULL,
                       X_Postable_Flag                  VARCHAR2,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Creation_Date                  DATE DEFAULT NULL,
                       X_Created_By                     NUMBER DEFAULT NULL,
                       /* Bug 5206670. Hold Workflow related change */
                       X_Initiate_Workflow_Flag         VARCHAR2 DEFAULT NULL,
                       X_Wait_Before_Notify_Days        NUMBER DEFAULT NULL,
                       X_Reminder_Days                  NUMBER DEFAULT NULL,
                       X_Hold_Instruction               VARCHAR2 DEFAULT NULL,
		       X_calling_sequence	IN	VARCHAR2
  ) IS

  current_calling_sequence	VARCHAR2(2000);
  debug_info			VARCHAR2(100);

  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'AP_HOLD_CODES_PKG.UPDATE_ROW<-' ||
                                 X_calling_sequence;

--  Updating ap_hold_codes
--
    debug_info := 'Updating ap_hold_codes';

    UPDATE ap_hold_codes
    SET
       hold_type                       =     X_Hold_Type,
       hold_lookup_code                =     X_Hold_Lookup_Code,
       description                     =     X_Description,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       user_releaseable_flag           =     X_User_Releaseable_Flag,
       user_updateable_flag            =     X_User_Updateable_Flag,
       inactive_date                   =     X_Inactive_Date,
       postable_flag                   =     X_Postable_Flag,
       last_update_login               =     X_Last_Update_Login,
       creation_date                   =     X_Creation_Date,
       created_by                      =     X_Created_By,
       initiate_workflow_flag          =     X_initiate_workflow_flag,
       wait_before_notify_days         =     X_wait_before_notify_days,
       reminder_days                   =     X_reminder_days,
       hold_instruction                =     X_Hold_Instruction
    WHERE rowid = X_Rowid;


--  Updating fnd_lookup_values
--
    debug_info := 'Updating fnd_lookup_values';

    UPDATE fnd_lookup_values
    SET
       description		       =     X_Description,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       end_date_active                 =     X_Inactive_Date,
       last_update_login               =     X_Last_Update_Login,
       creation_date                   =     X_Creation_Date,
       created_by                      =     X_Created_By
    WHERE lookup_code = X_Hold_Lookup_Code
    AND   lookup_type = 'HOLD CODE'
    AND   view_application_id = 200
    AND   userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    EXCEPTION
	WHEN OTHERS THEN
	   IF (SQLCODE <> -20001) THEN
	      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
	      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
	      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
	      FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_Rowid ||
                       		    ', HOLD_LOOKUP_CODE = ' || X_Hold_Lookup_Code);
	      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
	   END IF;
	   APP_EXCEPTION.RAISE_EXCEPTION;

  END Update_Row;

/*
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM ap_hold_codes
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;
*/

END AP_HOLD_CODES_PKG;

/
