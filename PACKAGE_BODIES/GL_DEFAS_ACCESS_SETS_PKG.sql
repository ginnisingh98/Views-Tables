--------------------------------------------------------
--  DDL for Package Body GL_DEFAS_ACCESS_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_DEFAS_ACCESS_SETS_PKG" AS
/* $Header: glistdab.pls 120.5 2006/03/13 19:56:21 cma ship $ */

  --
  -- PUBLIC FUNCTIONS
  --

  FUNCTION get_unique_id RETURN NUMBER IS
    CURSOR get_new_id IS
      SELECT GL_DEFAS_ACCESS_SETS_S.NEXTVAL
      FROM dual;
    new_id NUMBER;
  BEGIN
    OPEN get_new_id;
    FETCH get_new_id INTO new_id;

    IF get_new_id%FOUND THEN
      CLOSE get_new_id;
      RETURN (new_id);
    ELSE
      CLOSE get_new_id;
      fnd_message.set_name('SQLGL', 'GL_ERROR_GETTING_UNIQUE_ID');
      fnd_message.set_token('SEQUENCE', 'GL_DEFAS_ACCESS_SETS_S');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_defas_access_sets_pkg.get_unique_id');
      RAISE;
  END get_unique_id;


  FUNCTION get_dbname_id RETURN NUMBER IS
    CURSOR get_new_id IS
      SELECT GL.GL_DEFAS_DBNAME_S.NEXTVAL
      FROM dual;
    new_id NUMBER;
  BEGIN
    OPEN get_new_id;
    FETCH get_new_id INTO new_id;

    IF get_new_id%FOUND THEN
      CLOSE get_new_id;
      RETURN (new_id);
    ELSE
      CLOSE get_new_id;
      fnd_message.set_name('SQLGL', 'GL_ERROR_GETTING_UNIQUE_ID');
      fnd_message.set_token('SEQUENCE', 'GL_DEFAS_DBNAME_S');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_defas_access_sets_pkg.get_dbname_id');
      RAISE;
  END get_dbname_id;

  --
  -- PUBLIC FUNCTIONS
  --
  PROCEDURE check_unique_name(x_name  IN VARCHAR2 ) IS

    CURSOR c_dup IS
      SELECT 'Duplicate'
      FROM   GL_DEFAS_ACCESS_SETS a
      WHERE  a.user_definition_access_set = x_name;

    dummy VARCHAR2(100);

  BEGIN
    OPEN  c_dup;
    FETCH c_dup INTO dummy;

    IF c_dup%FOUND THEN
      CLOSE c_dup;
      fnd_message.set_name( 'SQLGL', 'GL_DEFAS_DUPLICATE' );
      app_exception.raise_exception;
    END IF;

    CLOSE c_dup;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_DEFAS_ACCESS_SETS_PKG.check_unique_name');
      RAISE;
  END check_unique_name;

  PROCEDURE check_assign (X_Definition_Access_Set_Id   IN NUMBER,
                          X_Assign_Flag              IN OUT NOCOPY VARCHAR2) IS
    CURSOR assign IS
       SELECT 'Y'
       FROM DUAL
       WHERE exists (
             SELECT *
             FROM gl_defas_resp_assign
             WHERE definition_access_set_id = X_Definition_Access_Set_Id);

  BEGIN
    OPEN assign;
    FETCH assign INTO X_Assign_Flag;
    CLOSE assign;

    EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_DEFAS_ACCESS_SETS_PKG.check_assign');
      RAISE;

  END check_assign;

  PROCEDURE translate_row(X_Definition_Access_Set      VARCHAR2,
                          X_User_Definition_Access_Set VARCHAR2,
                          X_Description                VARCHAR2,
                          X_Owner                      VARCHAR2,
                          X_Force_Edits                VARCHAR2) IS
     user_id number := 0;
  BEGIN
     if (X_Owner = 'SEED') then
        user_id := 1;
     end if;

     /* Update only if force_edits is 'Y' or if user_id = 1 */
     if ( user_id = 1 or X_Force_Edits = 'Y' ) then
        UPDATE GL_DEFAS_ACCESS_SETS
        SET
           user_definition_access_set      =       X_User_Definition_Access_Set,
           description                     =       X_Description,
           last_update_date                =       sysdate,
           last_updated_by                 =       user_id,
           last_update_login               =       0
        WHERE definition_access_set = X_Definition_Access_Set
        and   userenv('LANG') IN
              ( select language_code
                from   fnd_languages
                where  installed_flag = 'B' );
     end if;

     if (sql%notfound) then
         null;
     end if;

  END translate_row;

  PROCEDURE load_row(X_Definition_Access_Set      VARCHAR2,
                     X_User_Definition_Access_Set VARCHAR2,
                     X_Description                VARCHAR2,
                     X_Attribute1                 VARCHAR2,
                     X_Attribute2                 VARCHAR2,
                     X_Attribute3                 VARCHAR2,
                     X_Attribute4                 VARCHAR2,
                     X_Attribute5                 VARCHAR2,
                     X_Attribute6                 VARCHAR2,
                     X_Attribute7                 VARCHAR2,
                     X_Attribute8                 VARCHAR2,
                     X_Attribute9                 VARCHAR2,
                     X_Attribute10                VARCHAR2,
                     X_Attribute11                VARCHAR2,
                     X_Attribute12                VARCHAR2,
                     X_Attribute13                VARCHAR2,
                     X_Attribute14                VARCHAR2,
                     X_Attribute15                VARCHAR2,
                     X_Context                    VARCHAR2,
                     X_Owner                      VARCHAR2,
                     X_Force_Edits                VARCHAR2) IS
     user_id            number := 0;
     v_creation_date    date;
     v_rowid            rowid := null;
  BEGIN

     -- validate input parameters
     if ( X_User_Definition_Access_Set IS NULL) then
        fnd_message.set_name('SQLGL', 'GL_LOAD_ROW_NO_DATA');
        app_exception.raise_exception;
     end if;

     if (X_OWNER = 'SEED') then
        user_id := 1;
     end if;

     /* Check if the row exists in the database. If it does, retrieves
        the creation date for update_row. */
     select creation_date
     into   v_creation_date
     from   gl_defas_access_sets
     where  definition_access_set = X_Definition_Access_Set;

     if (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
     end if;

     /* Update only if force_edits is 'Y' or if user_id = 1 */
     if ( user_id = 1 or X_Force_Edits = 'Y' ) then
        UPDATE GL_DEFAS_ACCESS_SETS
        SET
	  user_definition_access_set    = 	X_Definition_Access_Set,
     	  last_update_date		= 	sysdate,
	  last_updated_by		= 	user_id,
	  last_update_login		= 	0,
          attribute1			= 	X_Attribute1,
  	  attribute2			= 	X_Attribute2,
	  attribute3			= 	X_Attribute3,
	  attribute4			= 	X_Attribute4,
	  attribute5			= 	X_Attribute5,
          attribute6			=	X_Attribute6,
          attribute7			=	X_Attribute7,
	  attribute8			=	X_Attribute8,
          attribute9			=	X_Attribute9,
          attribute10			=	X_Attribute10,
          attribute11			=	X_Attribute11,
          attribute12			=	X_Attribute12,
          attribute13			=	X_Attribute13,
          attribute14			=	X_Attribute14,
          attribute15			=	X_Attribute15,
  	  context			= 	X_Context,
          description			=	X_Description
       WHERE definition_access_set = X_Definition_Access_Set;

       if (SQL%NOTFOUND) then
          RAISE NO_DATA_FOUND;
       end if;
     end if;
   EXCEPTION
     when NO_DATA_FOUND then
       INSERT INTO GL_DEFAS_ACCESS_SETS
        (definition_access_set_id,
         definition_access_set,
         user_definition_access_set,
         description,
         last_update_date,
         last_updated_by,
         last_update_login,
         creation_date,
         created_by,
         context,
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
         attribute15)
       VALUES
        (gl_defas_access_sets_pkg.get_unique_id,
         X_Definition_Access_Set,
         X_User_Definition_Access_Set,
         X_Description,
         sysdate,
         user_id,
         0,
         sysdate,
         user_id,
         X_Context,
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
	 X_Attribute15);

 END load_row;


END gl_defas_access_sets_pkg;

/
