--------------------------------------------------------
--  DDL for Package Body GL_STORAGE_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_STORAGE_PARAMETERS_PKG" AS
/* $Header: glistpab.pls 120.8 2005/05/05 01:23:50 kvora ship $ */

--
-- PUBLIC FUNCTIONS
--

  PROCEDURE check_unique(X_object_name      VARCHAR2,
			 X_row_id	    VARCHAR2) IS
    CURSOR chk_duplicates is
      SELECT 'Duplicate'
      FROM   GL_STORAGE_PARAMETERS s
      WHERE  s.object_name        = X_object_name
      AND    (   X_row_id is null
              OR s.rowid <> chartorowid(X_row_id));
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_duplicates;
    FETCH chk_duplicates INTO dummy;

    IF chk_duplicates%FOUND THEN
      CLOSE chk_duplicates;
      fnd_message.set_name('SQLGL', 'GL_DUPLICATE_STORAGE_PARAMETER');
      app_exception.raise_exception;
    END IF;

    CLOSE chk_duplicates;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_storage_parameters_pkg.check_unique');
      RAISE;
  END check_unique;


  PROCEDURE Insert_Row(	X_Rowid                        	IN OUT NOCOPY VARCHAR2,
			X_object_name			VARCHAR2,
 			X_last_update_date 		DATE,
 			X_last_updated_by 		NUMBER,
 			X_creation_date 		DATE,
 			X_created_by 			NUMBER,
 			X_last_update_login 		NUMBER,
			X_object_type 			VARCHAR2,
			X_tablespace_name		VARCHAR2,
			X_initial_extent_size_kb	NUMBER,
			X_next_extent_size_kb		NUMBER,
			X_max_extents			NUMBER,
			X_pct_increase			NUMBER,
			X_pct_free    			NUMBER,
			X_description 			VARCHAR2) IS
     CURSOR C IS SELECT rowid FROM GL_STORAGE_PARAMETERS
                 WHERE 	object_name = X_object_name;
  BEGIN

    INSERT INTO GL_STORAGE_PARAMETERS( 	OBJECT_NAME,
 					LAST_UPDATE_DATE,
					LAST_UPDATED_BY,
					CREATION_DATE,
					CREATED_BY,
 					LAST_UPDATE_LOGIN,
					OBJECT_TYPE,
					TABLESPACE_NAME,
 					INITIAL_EXTENT_SIZE_KB,
 					NEXT_EXTENT_SIZE_KB,
 					MAX_EXTENTS,
 					PCT_INCREASE,
 					PCT_FREE,
 					DESCRIPTION)
    VALUES 				(X_object_name,
 					X_last_update_date,
 					X_last_updated_by,
 					X_creation_date,
 					X_created_by,
 					X_last_update_login,
					X_object_type,
					X_tablespace_name,
					X_initial_extent_size_kb,
					X_next_extent_size_kb,
					X_max_extents,
					X_pct_increase,
					X_pct_free,
					X_description);
    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      RAISE NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(	X_Rowid                        	IN OUT NOCOPY VARCHAR2,
			X_object_name			VARCHAR2,
			X_object_type 			VARCHAR2,
			X_tablespace_name		VARCHAR2,
			X_initial_extent_size_kb	NUMBER,
			X_next_extent_size_kb		NUMBER,
			X_max_extents			NUMBER,
			X_pct_increase			NUMBER,
			X_pct_free    			NUMBER,
			X_description 			VARCHAR2) IS
    CURSOR C IS
      SELECT * FROM GL_STORAGE_PARAMETERS
      WHERE rowid = X_rowid
      FOR UPDATE OF object_name NOWAIT;
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
    IF (  (    (   (Recinfo.object_name = X_object_name )
           OR (    (Recinfo.object_name IS NULL)
               AND (X_object_name IS NULL))))
         AND
	(    (   (Recinfo.object_type = X_object_type )
           OR (    (Recinfo.object_type IS NULL)
               AND (X_object_type IS NULL))))
         AND
	(    (   (Recinfo.tablespace_name = X_tablespace_name)
           OR (    (Recinfo.tablespace_name IS NULL)
               AND (X_tablespace_name IS NULL))))
         AND
	(    (   (Recinfo.initial_extent_size_kb = X_initial_extent_size_kb )
           OR (    (Recinfo.initial_extent_size_kb IS NULL)
               AND (X_initial_extent_size_kb IS NULL))))
         AND
	(    (   (Recinfo.next_extent_size_kb = X_next_extent_size_kb )
           OR (    (Recinfo.next_extent_size_kb IS NULL)
               AND (X_next_extent_size_kb IS NULL))))
         AND
	(    (   (Recinfo.max_extents = X_max_extents )
           OR (    (Recinfo.max_extents IS NULL)
               AND (X_max_extents IS NULL))))
         AND
	(    (   (Recinfo.pct_increase = X_pct_increase )
           OR (    (Recinfo.pct_increase IS NULL)
               AND (X_pct_increase IS NULL))))
	  AND
        (    (   (Recinfo.pct_free = X_pct_free )
           OR (    (Recinfo.pct_free IS NULL)
               AND (X_pct_free IS NULL))))
         AND
	(    (   (Recinfo.description = X_description )
           OR (    (Recinfo.description IS NULL)
               AND (X_description IS NULL))))) THEN
    	return;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  END Lock_Row;


  PROCEDURE Update_Row(	X_Rowid                        	IN OUT NOCOPY VARCHAR2,
			X_object_name			VARCHAR2,
 			X_last_update_date 		DATE,
 			X_last_updated_by 		NUMBER,
 			X_creation_date 		DATE,
 			X_created_by 			NUMBER,
 			X_last_update_login 		NUMBER,
			X_object_type 			VARCHAR2,
			X_tablespace_name		VARCHAR2,
			X_initial_extent_size_kb	NUMBER,
			X_next_extent_size_kb		NUMBER,
			X_max_extents			NUMBER,
			X_pct_increase			NUMBER,
			X_pct_free    			NUMBER,
			X_description 			VARCHAR2) IS
  BEGIN
    UPDATE GL_STORAGE_PARAMETERS
    SET
	object_name			= 	x_object_name,
	last_update_date 		= 	x_last_update_date,
	last_updated_by 		= 	x_last_updated_by,
	creation_date 			= 	x_creation_date,
	created_by 			= 	x_created_by,
	last_update_login 		= 	x_last_update_login,
	object_type 			= 	x_object_type,
	tablespace_name			= 	x_tablespace_name,
	initial_extent_size_kb		= 	x_initial_extent_size_kb,
	next_extent_size_kb		= 	x_next_extent_size_kb,
	max_extents			= 	x_max_extents,
	pct_increase			= 	x_pct_increase,
	pct_free    			= 	x_pct_free,
	description			= 	x_description
    WHERE
	rowid = x_rowid;
    if (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
    end if;

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM GL_STORAGE_PARAMETERS
    WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
    end if;
  END Delete_Row;

Procedure load_row(
                x_object_name               in out NOCOPY varchar2,
                x_object_type                   in varchar2,
                x_tablespace_name               in varchar2,
                x_initial_extent_size_kb        in number,
                x_next_extent_size_kb           in number,
                x_max_extents                   in number,
                x_pct_increase                  in number,
                x_description                   in varchar2,
                x_pct_free                      in number,
                x_owner                         in varchar2,
                x_force_edits                   in varchar2
           ) as
    user_id            number := 0;
    v_creation_date    date;
    v_rowid            rowid  := null;
    v_language         varchar2(4) := null;
    v_source_lang      varchar2(4) := null;

  begin

    -- validate input parameters
    if ( x_object_name      is null ) Then
      fnd_message.set_name('SQLGL', 'GL_LOAD_ROW_NO_DATA');
      app_exception.raise_exception;
    end if;

   if (X_OWNER = 'CUSTOM') then
      user_id := -1;
   else
      user_id := FND_LOAD_UTIL.owner_id(X_OWNER);
   end if;

   /* Update/Insert only if force_edits is 'Y'  or user_id is 1 or 2 */
   if ( user_id IN (1,2) OR x_force_edits = 'Y' )  then
     begin
       /* Check if the row exists in the database. If it does, retrieves
         the creation date for update_row. */

       select creation_date,rowid
       into   v_creation_date, v_rowid
       from   gl_storage_parameters
       where  object_name = x_object_name;

       gl_storage_parameters_pkg.update_row (
                x_rowid                        => v_rowid,
                x_object_name                   => x_object_name,
                x_last_update_date              => sysdate,
                x_last_updated_by               => user_id,
                x_creation_date                 => v_creation_date,
                x_created_by                    => user_id,
                x_last_update_login             => 0,
                x_object_type                   => x_object_type,
                x_tablespace_name               => x_tablespace_name ,
                x_initial_extent_size_kb        => x_initial_extent_size_kb,
                x_next_extent_size_kb           => x_next_extent_size_kb,
                x_max_extents                   => x_max_extents,
                x_pct_increase                  => x_pct_increase,
                x_pct_free                      => x_pct_free,
                x_description                   => x_description
             );

     exception
     when NO_DATA_FOUND then
        gl_storage_parameters_pkg.insert_row (
                x_rowid                        => v_rowid ,
                x_object_name                   => x_object_name,
                x_last_update_date              => sysdate,
                x_last_updated_by               => user_id,
                x_creation_date                 => sysdate,
                x_created_by                    => user_id,
                x_last_update_login             => 0,
                x_object_type                   => x_object_type,
                x_tablespace_name               => x_tablespace_name ,
                x_initial_extent_size_kb        => x_initial_extent_size_kb,
                x_next_extent_size_kb           => x_next_extent_size_kb,
                x_max_extents                   => x_max_extents,
                x_pct_increase                  => x_pct_increase,
                x_pct_free                      => x_pct_free,
                x_description                   => x_description
            );
    end;
   end if;
 end load_row  ;

 Procedure translate_row (
                x_object_name                   in varchar2,
                x_description                   in varchar2,
                x_owner                         in varchar2,
                x_force_edits                   in varchar2
           ) as
    user_id number := 0;
 begin

   if (X_OWNER = 'CUSTOM') then
      user_id := -1;
   else
      user_id := FND_LOAD_UTIL.owner_id(X_OWNER);
   end if;

   /* Update only if force_edits is 'Y' or if user id is 1 or 2 */
   if ( user_id IN (1,2) OR x_force_edits = 'Y' )  then
     UPDATE gl_storage_parameters
       SET
       description                     = x_description,
       last_update_date                = sysdate,
       last_updated_by                 = user_id,
       last_update_login               = 0
    WHERE object_name = x_object_name
    AND    USERENV('LANG') =
         ( SELECT language_code
           FROM  FND_LANGUAGES
           WHERE  installed_flag = 'B' );

   end if;

/* If base language is not set to the language being uploaded, then do nothing.
   if (sql%notfound) then
        raise no_data_found;
    end if;
 */

 end translate_row ;

END gl_storage_parameters_pkg;

/
