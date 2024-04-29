--------------------------------------------------------
--  DDL for Package Body GL_DAILY_CONV_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_DAILY_CONV_TYPES_PKG" AS
/* $Header: glirtctb.pls 120.7 2005/05/05 01:20:52 kvora ship $ */

--
-- PRIVATE FUNCTIONS
--

  --
  -- Procedure
  --   select_row
  -- Purpose
  --   Used to select a particular source row
  -- History
  --   11-02-93  D. J. Ogg    Created
  -- Arguments
  --   recinfo			Various information about the row
  -- Example
  --   gl_daily_conv_types_pkg.select_row(recinfo)
  -- Notes
  --
  PROCEDURE select_row( recinfo IN OUT NOCOPY gl_daily_conversion_types%ROWTYPE) IS
  BEGIN
    SELECT *
    INTO recinfo
    FROM gl_daily_conversion_types
    WHERE conversion_type     = recinfo.conversion_type;
  END SELECT_ROW;

--
-- PUBLIC FUNCTIONS
--

  PROCEDURE select_columns(
			x_conversion_type		       	VARCHAR2,
			x_user_conversion_type		IN OUT NOCOPY 	VARCHAR2) IS

    recinfo gl_daily_conversion_types%ROWTYPE;

  BEGIN
    recinfo.conversion_type    := x_conversion_type;

    select_row(recinfo);

    x_user_conversion_type := recinfo.user_conversion_type;
  END select_columns;

  PROCEDURE Check_Unique_User_Type(user_conversion_type VARCHAR2,
                                                x_rowid VARCHAR2) IS

  CURSOR check_dups is
    SELECT  1
      FROM  GL_DAILY_CONVERSION_TYPES dct
     WHERE  dct.user_conversion_type =
                check_unique_user_type.user_conversion_type
       AND  ( x_rowid is NULL
             OR dct.rowid <> x_rowid );

  dummy  NUMBER;

  BEGIN
    OPEN check_dups;
    FETCH check_dups INTO dummy;

    IF check_dups%FOUND THEN
       CLOSE  check_dups;
       fnd_message.set_name('SQLGL', 'GL_DUP_USER_CONVERSION_TYPE');
       app_exception.raise_exception;
    END IF;

    CLOSE check_dups;
  EXCEPTION
    WHEN app_exception.application_exception THEN RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL','Unhandled Exception');
      fnd_message.set_token('PROCEDURE', 'Check_Unique_User_Type');
      RAISE;
END Check_Unique_User_Type;

  PROCEDURE Check_Unique_Type(conversion_type VARCHAR2,
                                      x_rowid VARCHAR2) IS

  CURSOR chk_dups is
    SELECT  1
      FROM  GL_DAILY_CONVERSION_TYPES dct
     WHERE  dct.conversion_type =
                check_unique_type.conversion_type
       AND  ( x_rowid is NULL
             OR dct.rowid <> x_rowid );

  t_var  NUMBER;

  BEGIN
    OPEN chk_dups;
    FETCH chk_dups INTO t_var;

    IF chk_dups%FOUND THEN
       CLOSE  chk_dups;
       fnd_message.set_name('SQLGL', 'GL_DUP_UNIQUE_ID');
       fnd_message.set_token('TAB_S', 'GL_DAILY_CONVERSION_TYPES_S');
       app_exception.raise_exception;
    END IF;

    CLOSE chk_dups;
  EXCEPTION
    WHEN app_exception.application_exception THEN RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL','Unhandled Exception');
      fnd_message.set_token('PROCEDURE', 'Check_Unique_Type');
      RAISE;
  END Check_Unique_Type;

  PROCEDURE Get_New_Id(next_val IN OUT NOCOPY VARCHAR2) IS

  BEGIN
    select GL_DAILY_CONVERSION_TYPES_S.NEXTVAL
    into   next_val
    from   dual;

    IF (next_val is NULL) THEN
      fnd_message.set_name('SQLGL', 'GL_SEQUENCE_NOT_FOUND');
      fnd_message.set_token('TAB_S', 'GL_DAILY_CONVERSION_TYPES_S');
      app_exception.raise_exception;
    END IF;
  EXCEPTION
    WHEN app_exception.application_exception THEN RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL','Unhandled Exception');
      fnd_message.set_token('PROCEDURE', 'Get_New_Id');
      RAISE;
  END Get_New_Id;

  /* Added X_Security_Flag for Definition Access Sets Project */
  PROCEDURE Insert_Row(X_Rowid                    IN OUT NOCOPY   VARCHAR2,
                     X_Conversion_Type                     VARCHAR2,
                     X_User_Conversion_Type                VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Creation_Date                       DATE,
		     X_Created_By		   	   NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Description                         VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Security_Flag                       VARCHAR2) IS
	CURSOR C IS SELECT rowid
		     FROM GL_DAILY_CONVERSION_TYPES
		    WHERE conversion_type = X_Conversion_Type
		     AND user_conversion_type = X_User_Conversion_Type;

  BEGIN

    INSERT INTO GL_DAILY_CONVERSION_TYPES(
		conversion_type,
		user_conversion_type,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		description,
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
		attribute15,
		context,
		security_flag)
    VALUES(
		X_Conversion_Type,
		X_User_Conversion_Type,
		X_Last_Update_Date,
		X_Last_Updated_By,
		X_Creation_Date,
		X_Created_By,
		X_Last_Update_Login,
                X_Description,
                X_Attribute1,
                X_Attribute2,
                X_Attribute3,
                X_Attribute4,
                X_Attribute5,
                X_Attribute6,
                X_Attribute7,
                X_Attribute8,
                X_Attribute9,
                X_Attribute10,
                X_Attribute11,
                X_Attribute12,
                X_Attribute13,
                X_Attribute14,
		X_Attribute15,
		X_Context,
		X_Security_Flag );

    OPEN C;
    FETCH C INTO X_Rowid;

    if (C%NOTFOUND) then
      CLOSE C;
      RAISE NO_DATA_FOUND;
    end if;
    CLOSE C;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
      		'GL_DAILY_CONV_TYPES_PKG.Insert_Row');
      RAISE;

  END Insert_Row;

  /* Added for Definition Access Sets Project */
  PROCEDURE lock_row(X_Rowid               IN OUT NOCOPY   VARCHAR2,
                     X_Conversion_Type                     VARCHAR2,
                     X_User_Conversion_Type                VARCHAR2,
                     X_Description                         VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Security_Flag                       VARCHAR2) IS
  CURSOR C IS SELECT
	        conversion_type,
		user_conversion_type,
		description,
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
		attribute15,
		context,
		security_flag
    FROM GL_DAILY_CONVERSION_TYPES
    WHERE ROWID = X_Rowid
    FOR UPDATE OF conversion_type NOWAIT;
  recinfo C%ROWTYPE;

  BEGIN
    OPEN C;
    FETCH C INTO recinfo;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    END IF;
    CLOSE C;

    IF (
        (recinfo.conversion_type = x_conversion_type)
        AND (recinfo.user_conversion_type = x_user_conversion_type)
        AND (recinfo.security_flag = x_security_flag)

        AND ((recinfo.description = x_description)
             OR ((recinfo.description is null)
                 AND (x_description is null)))

        AND ((recinfo.context = x_context)
             OR ((recinfo.context is null)
                 AND (x_context is null)))

        AND ((recinfo.attribute1 = x_attribute1)
             OR ((recinfo.attribute1 is null)
                 AND (x_attribute1 is null)))

        AND ((recinfo.attribute2 = x_attribute2)
             OR ((recinfo.attribute2 is null)
                 AND (x_attribute2 is null)))

        AND ((recinfo.attribute3 = x_attribute3)
             OR ((recinfo.attribute3 is null)
                 AND (x_attribute3 is null)))

        AND ((recinfo.attribute4 = x_attribute4)
             OR ((recinfo.attribute4 is null)
                 AND (x_attribute4 is null)))

        AND ((recinfo.attribute5 = x_attribute5)
             OR ((recinfo.attribute5 is null)
                 AND (x_attribute5 is null)))

        AND ((recinfo.attribute6 = x_attribute6)
             OR ((recinfo.attribute6 is null)
                 AND (x_attribute6 is null)))

        AND ((recinfo.attribute7 = x_attribute7)
             OR ((recinfo.attribute7 is null)
                 AND (x_attribute7 is null)))

        AND ((recinfo.attribute8 = x_attribute8)
             OR ((recinfo.attribute8 is null)
                 AND (x_attribute8 is null)))

        AND ((recinfo.attribute9 = x_attribute9)
             OR ((recinfo.attribute9 is null)
                 AND (x_attribute9 is null)))

        AND ((recinfo.attribute10 = x_attribute10)
             OR ((recinfo.attribute10 is null)
                 AND (x_attribute10 is null)))

        AND ((recinfo.attribute11 = x_attribute11)
             OR ((recinfo.attribute11 is null)
                 AND (x_attribute11 is null)))

        AND ((recinfo.attribute12 = x_attribute12)
             OR ((recinfo.attribute12 is null)
                 AND (x_attribute12 is null)))

        AND ((recinfo.attribute13 = x_attribute13)
             OR ((recinfo.attribute13 is null)
                 AND (x_attribute13 is null)))

        AND ((recinfo.attribute14 = x_attribute14)
             OR ((recinfo.attribute14 is null)
                 AND (x_attribute14 is null)))

        AND ((recinfo.attribute15 = x_attribute15)
             OR ((recinfo.attribute15 is null)
                 AND (x_attribute15 is null)))
    ) THEN
        return;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    END IF;

  END lock_row;

  /* Added X_Security_Flag for Definition Access Sets Project */
  PROCEDURE Update_Row(X_Conversion_Type                   VARCHAR2,
		     X_User_Conversion_Type		   VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Description                         VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Security_Flag                       VARCHAR2) IS
  BEGIN
    UPDATE gl_daily_conversion_types
    SET
	user_conversion_type	=	X_User_Conversion_Type,
	last_update_date	=	X_Last_Update_Date,
	last_updated_by		=	X_Last_Updated_By,
	last_update_login	=	X_Last_Update_Login,
	description		= 	X_Description,
        attribute1              =    	X_Attribute1,
	attribute2              =    	X_Attribute2,
        attribute3              =    	X_Attribute3,
	attribute4              =    	X_Attribute4,
        attribute5              =    	X_Attribute5,
	attribute6              =    	X_Attribute6,
        attribute7              =    	X_Attribute7,
	attribute8              =    	X_Attribute8,
        attribute9              =    	X_Attribute9,
	attribute10             =    	X_Attribute10,
        attribute11             =    	X_Attribute11,
	attribute12             =    	X_Attribute12,
        attribute13             =    	X_Attribute13,
	attribute14             =    	X_Attribute14,
        attribute15             =    	X_Attribute15,
        context                 =    	X_Context,
        security_flag           =       X_Security_Flag
    WHERE conversion_type = X_Conversion_Type;

    if (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
    end if;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
      	'GL_DAILY_CONV_TYPES_PKG.Update_Row');
      RAISE;

  END Update_Row;

  /* Modified calls to Insert_Row and Update_Row to include Security_Flag
     (for Definition Access Sets Project) */
  PROCEDURE Load_Row(
                     V_Conversion_Type		           VARCHAR2,
		     V_User_Conversion_Type		   VARCHAR2,
                     V_Description                         VARCHAR2,
                     V_Attribute1                          VARCHAR2,
                     V_Attribute2                          VARCHAR2,
                     V_Attribute3                          VARCHAR2,
                     V_Attribute4                          VARCHAR2,
                     V_Attribute5                          VARCHAR2,
                     V_Attribute6                          VARCHAR2,
                     V_Attribute7                          VARCHAR2,
                     V_Attribute8                          VARCHAR2,
                     V_Attribute9                          VARCHAR2,
                     V_Attribute10                         VARCHAR2,
                     V_Attribute11                         VARCHAR2,
                     V_Attribute12                         VARCHAR2,
                     V_Attribute13                         VARCHAR2,
                     V_Attribute14                         VARCHAR2,
                     V_Attribute15                         VARCHAR2,
                     V_Context                             VARCHAR2,
		     V_Owner				   VARCHAR2,
		     V_Force_Edits			   VARCHAR2) IS

    user_id		NUMBER		:= 0;
    V_Rowid		ROWID		:= null;
    Force_Edits		VARCHAR2(1) 	:= 'N';
    x_creation_date	DATE;
    x_security_flag     VARCHAR2(1);
  BEGIN

    -- validate input parameter
    IF ((V_User_Conversion_Type is NULL) OR
	(V_Conversion_Type is NULL)) THEN
      FND_MESSAGE.set_name('SQLGL', 'GL_LOAD_ROW_NO_DATA');
      APP_EXCEPTION.raise_exception;
    END IF;

    IF (V_Owner = 'SEED') THEN
      user_id := 1;
    END IF;

    IF (V_Force_Edits = 'Y') THEN
      Force_Edits := 'Y';
    END IF;

    BEGIN

      /* Check if the row exists in the database. If it does, retrieves
         the creation date for update_row. */
      -- Added security_flag for DAS project
      select creation_date, security_flag
      into   x_creation_date, x_security_flag
      from   gl_daily_conversion_types
      where  conversion_type = V_Conversion_Type;

      /* Update only if Force_Edits is 'Y' or user_id = 1  */
      IF ( Force_Edits = 'Y' OR user_id = 1 ) THEN
	-- update row if present
	GL_DAILY_CONV_TYPES_PKG.Update_Row(
	  X_Conversion_Type		=>	V_Conversion_Type,
	  X_User_Conversion_Type	=>	V_User_Conversion_Type,
	  X_Last_Update_Date		=>	sysdate,
	  X_Last_Updated_By		=>	user_id,
	  X_Last_Update_Login		=>	0,
	  X_Description			=>	V_Description,
	  X_Attribute1			=>	V_Attribute1,
	  X_Attribute2			=>	V_Attribute2,
	  X_Attribute3			=>	V_Attribute3,
	  X_Attribute4			=>	V_Attribute4,
	  X_Attribute5			=>	V_Attribute5,
	  X_Attribute6			=>	V_Attribute6,
	  X_Attribute7			=>	V_Attribute7,
	  X_Attribute8			=>	V_Attribute8,
	  X_Attribute9			=>	V_Attribute9,
	  X_Attribute10			=>	V_Attribute10,
	  X_Attribute11			=>	V_Attribute11,
	  X_Attribute12			=>	V_Attribute12,
	  X_Attribute13			=>	V_Attribute13,
	  X_Attribute14			=>	V_Attribute14,
	  X_Attribute15			=>	V_Attribute15,
	  X_Context			=>	V_Context,
	  X_Security_Flag               =>      x_security_flag);
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
  	GL_DAILY_CONV_TYPES_PKG.Insert_Row(
	  X_Rowid			=>	V_Rowid,
	  X_Conversion_Type		=>	V_Conversion_Type,
	  X_User_Conversion_Type	=>	V_User_Conversion_Type,
	  X_Last_Update_Date		=>	sysdate,
	  X_Last_Updated_By		=>	user_id,
	  X_Creation_Date		=>	x_creation_date,
	  X_Created_By			=>	user_id,
	  X_Last_Update_Login		=>	0,
	  X_Description			=>	V_Description,
	  X_Attribute1			=>	V_Attribute1,
	  X_Attribute2			=>	V_Attribute2,
	  X_Attribute3			=>	V_Attribute3,
	  X_Attribute4			=>	V_Attribute4,
	  X_Attribute5			=>	V_Attribute5,
	  X_Attribute6			=>	V_Attribute6,
	  X_Attribute7			=>	V_Attribute7,
	  X_Attribute8			=>	V_Attribute8,
	  X_Attribute9			=>	V_Attribute9,
	  X_Attribute10			=>	V_Attribute10,
	  X_Attribute11			=>	V_Attribute11,
	  X_Attribute12			=>	V_Attribute12,
	  X_Attribute13			=>	V_Attribute13,
	  X_Attribute14			=>	V_Attribute14,
	  X_Attribute15			=>	V_Attribute15,
	  X_Context			=>	V_Context,
	  X_Security_Flag               =>      'N');

    END;

  END Load_Row;

  PROCEDURE Translate_Row(
                     V_Conversion_Type		           VARCHAR2,
		     V_User_Conversion_Type		   VARCHAR2,
                     V_Description                         VARCHAR2,
		     V_Owner				   VARCHAR2,
		     V_Force_Edits			   VARCHAR2) IS

    user_id		NUMBER		:= 0;
    Force_Edits		VARCHAR2(1)	:= 'N';

  BEGIN
    IF (V_Owner = 'SEED') THEN
      user_id := 1;
    END IF;

    IF (V_Force_Edits = 'Y') THEN
      Force_Edits := 'Y';
    END IF;

    /* Update only if Force_Edits is 'Y' or user_id = 1  */
    IF ( Force_Edits = 'Y' OR user_id = 1 ) THEN
      UPDATE GL_DAILY_CONVERSION_TYPES
      SET
	user_conversion_type		=	V_User_Conversion_Type,
	description			=	V_Description,
	last_update_date		=	sysdate,
	last_updated_by			=	user_id,
	last_update_login		=	0
      WHERE conversion_type = V_Conversion_Type
      AND   userenv('LANG') =
	    ( SELECT language_code
		FROM FND_LANGUAGES
	      WHERE installed_flag = 'B');
    END IF;
 /*If base language is not set to the language being uploaded, then do nothing.*/
    IF (SQL%NOTFOUND) THEN
      NULL;
    END IF;

  END Translate_Row;

END GL_DAILY_CONV_TYPES_PKG;

/
