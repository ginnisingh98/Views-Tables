--------------------------------------------------------
--  DDL for Package Body GL_PERIOD_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_PERIOD_SETS_PKG" AS
/* $Header: gliprseb.pls 120.10 2005/05/05 01:18:26 kvora ship $ */

--
-- PUBLIC FUNCTIONS
--

  PROCEDURE check_unique(calendar_name VARCHAR2, row_id VARCHAR2) IS
    CURSOR chk_duplicates is
      SELECT 'Duplicate'
      FROM   GL_PERIOD_SETS gps
      WHERE  gps.period_set_name = calendar_name
      AND    (   row_id is null
              OR gps.rowid <> row_id);
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_duplicates;
    FETCH chk_duplicates INTO dummy;

    IF chk_duplicates%FOUND THEN
      CLOSE chk_duplicates;
      fnd_message.set_name('SQLGL', 'GL_DUPLICATE_CALENDAR_NAME');
      app_exception.raise_exception;
    END IF;

    CLOSE chk_duplicates;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_period_sets_pkg.check_unique');
      RAISE;
  END check_unique;



  FUNCTION get_unique_id RETURN NUMBER IS
    CURSOR get_new_id IS
      SELECT gl_period_sets_s.NEXTVAL
      FROM dual;
    new_id number;
  BEGIN
    OPEN get_new_id;
    FETCH get_new_id INTO new_id;

    IF get_new_id%FOUND THEN
      CLOSE get_new_id;
      return(new_id);
    ELSE
      CLOSE get_new_id;
      fnd_message.set_name('SQLGL', 'GL_ERROR_GETTING_UNIQUE_ID');
      fnd_message.set_token('SEQUENCE', 'GL_PERIOD_SETS_S');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_period_sets_pkg.get_unique_id');
      RAISE;
  END get_unique_id;


  PROCEDURE Insert_Row(X_Rowid           IN OUT NOCOPY VARCHAR2,
                       X_Period_Set_Name               VARCHAR2,
                       X_Security_Flag                 VARCHAR2,
                       X_Creation_Date                 DATE,
                       X_Created_By                    NUMBER,
                       X_Last_Updated_By               NUMBER,
                       X_Last_Update_Login             NUMBER,
                       X_Last_Update_Date              DATE,
                       X_Description                   VARCHAR2,
                       X_Context                       VARCHAR2,
                       X_Attribute1                    VARCHAR2,
                       X_Attribute2                    VARCHAR2,
                       X_Attribute3                    VARCHAR2,
                       X_Attribute4                    VARCHAR2,
                       X_Attribute5                    VARCHAR2) IS
    CURSOR period_sets_row IS
      SELECT rowid
      FROM   gl_period_sets
      WHERE  period_set_name = X_Period_Set_Name;
  BEGIN
    IF ( X_Period_Set_Name is NULL ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    INSERT INTO GL_PERIOD_SETS (
		period_set_name,
		security_flag,
		description,
		last_update_date,
		last_update_login,
		last_updated_by,
		created_by,
		creation_date,
		context,
		attribute1,
		attribute2,
		attribute3,
		attribute4,
		attribute5 )
    SELECT
                X_Period_Set_Name,
		X_Security_Flag,
		X_Description,
		X_Last_Update_Date,
		X_Last_Update_Login,
		X_Last_Updated_By,
		X_Created_By,
		X_Creation_Date,
		X_Context,
		X_Attribute1,
		X_Attribute2,
		X_Attribute3,
		X_Attribute4,
		X_Attribute5
    FROM  DUAL
    WHERE NOT EXISTS
         ( SELECT NULL
	   FROM   gl_period_sets  GPS
	   WHERE  GPS.period_set_name = X_Period_Set_Name);

    OPEN period_sets_row;
    FETCH period_sets_row into X_Rowid;
    IF ( period_sets_row%notfound ) THEN
      CLOSE period_sets_row;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE period_sets_row;
  END Insert_Row;

  PROCEDURE Update_Row(X_Rowid                         VARCHAR2,
                       X_Period_Set_Name               VARCHAR2,
                       X_Security_Flag                 VARCHAR2,
                       X_Last_Updated_By               NUMBER,
                       X_Last_Update_Login             NUMBER,
                       X_Last_Update_Date              DATE,
                       X_Description                   VARCHAR2,
                       X_Context                       VARCHAR2,
                       X_Attribute1                    VARCHAR2,
                       X_Attribute2                    VARCHAR2,
                       X_Attribute3                    VARCHAR2,
                       X_Attribute4                    VARCHAR2,
                       X_Attribute5                    VARCHAR2) IS
  BEGIN
    UPDATE gl_period_sets
    SET    period_set_name	=	X_Period_Set_Name,
           security_flag	=	X_Security_Flag,
           description		=	X_Description,
           last_updated_by	=	X_Last_Updated_By,
           last_update_date	=	X_Last_Update_Date,
           last_update_login	=	X_Last_Update_Login,
           context		=	X_Context,
           attribute1		=	X_Attribute1,
           attribute2		=	X_Attribute2,
           attribute3		=	X_Attribute3,
           attribute4		=	X_Attribute4,
           attribute5		=	X_Attribute5
    WHERE  period_set_name	=	X_Period_Set_Name;

    IF ( sql%notfound ) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END Update_Row;

  PROCEDURE Load_Row(X_Period_Set_Name                 VARCHAR2,
                     X_Owner                           VARCHAR2,
                     X_Description                     VARCHAR2,
                     X_Context                         VARCHAR2,
                     X_Attribute1                      VARCHAR2,
                     X_Attribute2                      VARCHAR2,
                     X_Attribute3                      VARCHAR2,
                     X_Attribute4                      VARCHAR2,
                     X_Attribute5                      VARCHAR2) IS
    v_user_id           NUMBER := 0;
    v_creation_date     DATE;
    v_rowid             ROWID := null;
    v_security_flag     VARCHAR2(1);
  BEGIN
    IF ( X_Period_Set_Name IS NULL ) THEN
      fnd_message.set_name ('SQLGL','GL_LOAD_ROW_NO_DATA');
      app_exception.raise_exception;
    END IF;

    IF ( X_Owner = 'SEED' ) THEN
      v_user_id := 1;
    END IF;

    BEGIN
      SELECT creation_date, rowid, security_flag
      INTO   v_creation_date, v_rowid, v_security_flag
      FROM   gl_period_sets
      WHERE  period_set_name = X_Period_Set_Name;

      IF ( X_Owner = 'SEED' ) THEN
        gl_period_sets_pkg.Update_Row(
		X_Rowid			=>	v_rowid,
		X_Period_Set_Name	=>	X_Period_Set_Name,
		X_Security_Flag		=>	v_security_flag,
		X_Last_Updated_By	=>	v_user_id,
		X_Last_Update_Login	=>	0,
		X_Last_Update_Date	=>	sysdate,
		X_Description		=>	X_Description,
		X_Context		=>	X_Context,
		X_Attribute1		=>	X_Attribute1,
		X_Attribute2		=>	X_Attribute2,
		X_Attribute3		=>	X_Attribute3,
		X_Attribute4		=>	X_Attribute4,
		X_Attribute5		=>	X_Attribute5 );
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        gl_period_sets_pkg.Insert_Row(
		X_Rowid			=>	v_rowid,
		X_Period_Set_Name	=>	X_Period_Set_Name,
		X_Security_Flag		=>	'N',
		X_Creation_Date		=>	sysdate,
		X_Created_By		=>	v_user_id,
		X_Last_Updated_By	=>	v_user_id,
		X_Last_Update_Login	=>	0,
		X_Last_Update_Date	=>	sysdate,
		X_Description		=>	X_Description,
		X_Context		=>	X_Context,
		X_Attribute1		=>	X_Attribute1 ,
		X_Attribute2		=>	X_Attribute2 ,
		X_Attribute3		=>	X_Attribute3 ,
		X_Attribute4		=>	X_Attribute4 ,
		X_Attribute5		=>	X_Attribute5 );
    END;
  END Load_Row;

  PROCEDURE Lock_Row(X_Rowid                IN OUT NOCOPY VARCHAR2,
                     X_Period_Set_Name             VARCHAR2,
                     X_Last_Update_Date            DATE,
                     X_Last_Updated_By             NUMBER,
                     X_Creation_Date               DATE,
                     X_Created_By                  NUMBER,
                     X_Last_Update_Login           NUMBER,
                     X_Description                 VARCHAR2,
                     X_Attribute1                  VARCHAR2,
                     X_Attribute2                  VARCHAR2,
                     X_Attribute3                  VARCHAR2,
                     X_Attribute4                  VARCHAR2,
                     X_Attribute5                  VARCHAR2,
                     X_Context                     VARCHAR2,
                     X_Security_Flag               VARCHAR2) IS
     CURSOR C IS
       SELECT *
       FROM gl_period_sets
       WHERE rowid = X_Rowid
       FOR UPDATE of period_set_name NOWAIT;
     Recinfo C%ROWTYPE;
  BEGIN
     OPEN C;
     FETCH C INTO Recinfo;
     if (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
     end if;
     CLOSE C;
     if (
           ( (Recinfo.period_set_name = X_Period_Set_Name )
           OR ( (Recinfo.period_set_name IS NULL)
               AND (X_Period_Set_Name IS NULL)))
     AND   ( (Recinfo.last_update_date = X_Last_Update_Date)
           OR ( (Recinfo.last_update_date IS NULL)
               AND (X_Last_Update_Date IS NULL)))
     AND   ( (Recinfo.last_updated_by = X_Last_Updated_By)
           OR ( (Recinfo.last_updated_by IS NULL)
               AND (X_Last_Updated_By IS NULL)))
     AND   ( (Recinfo.creation_date = X_Creation_Date)
           OR ( (Recinfo.creation_date IS NULL)
               AND (X_Creation_Date IS NULL)))
     AND   ( (Recinfo.created_by = X_Created_By)
           OR ( (Recinfo.created_by IS NULL)
               AND (X_Created_By IS NULL)))
     AND   ( (Recinfo.last_update_login = X_Last_Update_Login)
           OR ( (Recinfo.last_update_login IS NULL)
               AND (X_Last_Update_Login IS NULL)))
     AND   ( (Recinfo.description = X_Description)
           OR ( (Recinfo.description IS NULL)
               AND (X_Description IS NULL)))
     AND   ( (Recinfo.attribute1 = X_Attribute1)
           OR ( (Recinfo.attribute1 IS NULL)
               AND (X_Attribute1 IS NULL)))
     AND   ( (Recinfo.attribute2 = X_Attribute2)
           OR ( (Recinfo.attribute2 IS NULL)
               AND (X_Attribute2 IS NULL)))
     AND   ( (Recinfo.attribute3 = X_Attribute3)
           OR ( (Recinfo.attribute3 IS NULL)
               AND (X_Attribute3 IS NULL)))
     AND   ( (Recinfo.attribute4 = X_Attribute4)
           OR ( (Recinfo.attribute4 IS NULL)
               AND (X_Attribute4 IS NULL)))
     AND   ( (Recinfo.attribute5 = X_Attribute5)
           OR ( (Recinfo.attribute5 IS NULL)
               AND (X_Attribute5 IS NULL)))
     AND   ( (Recinfo.context = X_Context)
           OR ( (Recinfo.context IS NULL)
               AND (X_Context IS NULL)))
     AND   ( (Recinfo.security_flag = X_Security_Flag)
           OR ( (Recinfo.security_flag IS NULL)
               AND (X_Security_Flag IS NULL)))
    ) THEN
        return;
    ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END lock_row;

  FUNCTION submit_concurrent(ledger_id       NUMBER,
                             period_set_name VARCHAR2) RETURN NUMBER IS
    req_id NUMBER := 0;
  BEGIN
    req_id := FND_REQUEST.submit_request (
                            'SQLGL','GLXCLVAL','','',FALSE,
                            period_set_name, chr(0),
                            '','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','');

    return req_id;
  END submit_concurrent;

END gl_period_sets_pkg;

/
