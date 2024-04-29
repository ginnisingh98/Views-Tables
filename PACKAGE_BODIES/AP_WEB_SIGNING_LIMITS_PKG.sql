--------------------------------------------------------
--  DDL for Package Body AP_WEB_SIGNING_LIMITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_SIGNING_LIMITS_PKG" as
/* $Header: apiwsltb.pls 120.3 2005/12/08 13:17:19 srinvenk ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Document_Type                  VARCHAR2,
                       X_Employee_Id                    NUMBER,
                       X_Cost_Center                    VARCHAR2,
                       X_Signing_Limit                  NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Org_Id                         NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM ap_web_signing_limits
                 WHERE X_Document_Type = Document_Type
                 AND   X_Employee_Id = Employee_Id
                 AND   X_Cost_Center = Cost_Center;

   BEGIN

       CHECK_UNIQUE(X_rowid, X_document_type, X_employee_id, X_cost_center,
			'AP_WEB_SIGNING_LIMITS_PKG.Insert_Row');

       INSERT INTO ap_web_signing_limits_all(
              document_type,
              employee_id,
              cost_center,
              signing_limit,
              last_update_date,
              last_updated_by,
              last_update_login,
              creation_date,
              created_by,
              org_id
             ) VALUES (
              X_Document_Type,
              X_Employee_Id,
              X_Cost_Center,
              X_Signing_Limit,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Last_Update_Login,
              X_Creation_Date,
              X_Created_By,
              X_Org_Id
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

    EXCEPTION
      WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
	  FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
 	  FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
	  FND_MESSAGE.SET_TOKEN('PARAMENTERS','X_ROWID='||X_ROWID||
	 	',X_DOCUMENT_TYPE='||X_DOCUMENT_TYPE||
		',X_EMPLOYEE_ID='||X_EMPLOYEE_ID||
		',X_COST_CENTER='||X_COST_CENTER||
		',X_SIGNING_LIMIT='||X_SIGNING_LIMIT||
		',X_LAST_UPDATE_DATE='||X_LAST_UPDATE_DATE||
		',X_LAST_UPDATED_BY='||X_LAST_UPDATED_BY||
		',X_LAST_UPDATE_LOGIN='||X_LAST_UPDATE_LOGIN||
		',X_CREATION_DATE='||X_CREATION_DATE||
		',X_CREATED_BY='||X_CREATED_BY||
		',X_ORG_ID='||X_ORG_ID);
	  FND_MESSAGE.SET_TOKEN('DEBUG_INFO','INSERT_ROW HAS EXCEPTION');
        END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Document_Type                    VARCHAR2,
                     X_Employee_Id                      NUMBER,
                     X_Cost_Center                      VARCHAR2,
                     X_Signing_Limit                    NUMBER,
                     X_Org_Id                           NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   ap_web_signing_limits
        WHERE  rowid = X_Rowid
        FOR UPDATE of employee_id NOWAIT;
    Recinfo C%ROWTYPE;

  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
               (Recinfo.document_type =  X_Document_Type)
           AND (Recinfo.employee_id =  X_Employee_Id)
           AND (Recinfo.cost_center =  X_Cost_Center)
           AND (   (Recinfo.signing_limit =  X_Signing_Limit)
                    OR (X_Signing_Limit IS NULL))
           AND (   (Recinfo.org_id =  X_Org_Id)
                    OR (X_Org_Id IS NULL))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

    EXCEPTION
      WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
          FND_MESSAGE.SET_TOKEN('PARAMENTERS','X_ROWID='||X_ROWID||
                ',X_DOCUMENT_TYPE='||X_DOCUMENT_TYPE||
                ',X_EMPLOYEE_ID='||X_EMPLOYEE_ID||
                ',X_COST_CENTER='||X_COST_CENTER||
                ',X_SIGNING_LIMIT='||X_SIGNING_LIMIT||
                ',X_ORG_ID='||X_ORG_ID);
	  FND_MESSAGE.SET_TOKEN('DEBUG_INFO','LOCK_ROW HAS EXCEPTION');
        END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;
  END Lock_Row;


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Document_Type                  VARCHAR2,
                       X_Employee_Id                    NUMBER,
                       X_Cost_Center                    VARCHAR2,
                       X_Signing_Limit                  NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Org_Id                         NUMBER

  ) IS
  BEGIN
    UPDATE ap_web_signing_limits
    SET
       document_type                   =     X_Document_Type,
       employee_id                     =     X_Employee_Id,
       cost_center                     =     X_Cost_Center,
       signing_limit                   =     X_Signing_Limit,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       org_id                          =     X_Org_Id
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    EXCEPTION
      WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
          FND_MESSAGE.SET_TOKEN('PARAMENTERS','X_ROWID='||X_ROWID||
                ',X_DOCUMENT_TYPE='||X_DOCUMENT_TYPE||
                ',X_EMPLOYEE_ID='||X_EMPLOYEE_ID||
                ',X_COST_CENTER='||X_COST_CENTER||
                ',X_SIGNING_LIMIT='||X_SIGNING_LIMIT||
                ',X_LAST_UPDATE_DATE='||X_LAST_UPDATE_DATE||
                ',X_LAST_UPDATED_BY='||X_LAST_UPDATED_BY||
                ',X_LAST_UPDATE_LOGIN='||X_LAST_UPDATE_LOGIN||
                ',X_ORG_ID='||X_ORG_ID);
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO','UPDATE_ROW HAS EXCEPTION');
        END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM ap_web_signing_limits
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    EXCEPTION
      WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
          FND_MESSAGE.SET_TOKEN('PARAMENTERS','X_ROWID='||X_ROWID);
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO','DELETE_ROW HAS EXCEPTION');
        END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;
  END Delete_Row;

  PROCEDURE CHECK_UNIQUE (X_Rowid             VARCHAR2,
                          X_Document_Type     VARCHAR2,
                          X_Employee_Id       NUMBER,
                          X_Cost_Center       VARCHAR2,
                          X_calling_sequence  VARCHAR2) IS
    dummy_a number := 0;
    current_calling_sequence 	VARCHAR2(2000);
    debug_info			VARCHAR2(100);

  begin

    -- update the calling sequence
    --
    current_calling_sequence :=
		'AP_WEB_SIGNING_LIMIT_PKG.CHECK_UNIQUE<-'||X_calling_sequence;

    debug_info := 'Count for same document_type, employee_id, and cost_center';

    select count(1)
    into   dummy_a
    from   AP_WEB_SIGNING_LIMITS
    where  document_type = X_document_type
    and    employee_id = X_employee_id
    and    cost_center = X_cost_center
    and    ((X_rowid is null) or (rowid <> X_rowid));

    if (dummy_a >= 1) then
      fnd_message.set_name('SQLAP', 'AP_ALL_DUPLICATE_VALUE');
      app_exception.raise_exception;
    end if;

    EXCEPTION
      when OTHERS then
        if (SQLCODE <> -20001) then
          fnd_message.set_name('SQLAP', 'AP_DEBUG');
          fnd_message.set_token('ERROR', sqlerrm);
          fnd_message.set_token('CALLING_SEQUENCE', current_calling_sequence);
          fnd_message.set_token('PARAMETERS',
	    'X_Rowid = '	   || X_Rowid
	  ||', X_Document_Type = ' || X_Document_Type
          ||', X_Employee_Id = '   || X_Employee_Id
          ||', X_Cost_Center = '   || X_Cost_Center );
	  fnd_message.set_token('DEBUG_INFO', debug_info);
	end if;
      app_exception.raise_exception;

  end CHECK_UNIQUE;

END AP_WEB_SIGNING_LIMITS_PKG;

/
