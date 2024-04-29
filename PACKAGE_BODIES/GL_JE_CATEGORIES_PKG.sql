--------------------------------------------------------
--  DDL for Package Body GL_JE_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_JE_CATEGORIES_PKG" AS
/*  $Header: glijectb.pls 120.14 2005/05/05 01:09:27 kvora ship $ */


--
-- PRIVATE FUNCTIONS
--

  --
  -- Procedure
  --   select_row
  -- Purpose
  --   Used to select a particular category row
  -- History
  --   28-MAR-94  D. J. Ogg    Created
  -- Arguments
  --   recinfo			Various information about the row
  -- Example
  --   gl_je_categories_pkg.select_row(recinfo)
  -- Notes
  --
  PROCEDURE select_row( recinfo IN OUT NOCOPY gl_je_categories%ROWTYPE) IS
  BEGIN
    SELECT *
    INTO recinfo
    FROM gl_je_categories
    WHERE je_category_name = recinfo.je_category_name;
  END SELECT_ROW;


  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE check_unique( x_rowid VARCHAR2,
                          x_name  VARCHAR2 ) IS
    CURSOR c_dup IS
      SELECT 'Duplicate'
      FROM   gl_je_categories cat
      WHERE  cat.user_je_category_name = x_name
      AND    ( x_rowid is NULL
               OR
               cat.rowid <> x_rowid );
    dummy VARCHAR2(100);

  BEGIN
    OPEN  c_dup;
    FETCH c_dup INTO dummy;

    IF c_dup%FOUND THEN
      CLOSE c_dup;
      fnd_message.set_name( 'SQLGL', 'GL_DUPLICATE_JE_CATEGORY' );
      app_exception.raise_exception;
    END IF;

    CLOSE c_dup;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_JE_CATEGORIES_PKG.check_unique');
      RAISE;

  END check_unique;


  PROCEDURE check_unique_key( x_rowid VARCHAR2,
                              x_key  VARCHAR2 ) IS
    CURSOR c_dup IS
      SELECT 'Duplicate'
      FROM   gl_je_categories cat
      WHERE  cat.je_category_key = x_key
      AND    ( x_rowid is NULL
               OR
               cat.rowid <> x_rowid );
    dummy VARCHAR2(100);

  BEGIN
    OPEN  c_dup;
    FETCH c_dup INTO dummy;

    IF c_dup%FOUND THEN
      CLOSE c_dup;
      fnd_message.set_name( 'SQLGL', 'GL_DUPLICATE_JE_CATEGORY_KEY' );
      app_exception.raise_exception;
    END IF;

    CLOSE c_dup;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_JE_CATEGORIES_PKG.check_unique_key');
      RAISE;

  END check_unique_key;

-- ************************************************************************

  FUNCTION get_unique_id RETURN NUMBER IS
    CURSOR c_getid IS
      SELECT gl_je_categories_s.NEXTVAL
      FROM   dual;
    id number;

  BEGIN
    OPEN  c_getid;
    FETCH c_getid INTO id;

    IF c_getid%FOUND THEN
      CLOSE c_getid;
      RETURN( id );
    ELSE
      CLOSE c_getid;
      fnd_message.set_name('SQLGL', 'GL_ERROR_GETTING_UNIQUE_ID');
      fnd_message.set_token('SEQUENCE', 'gl_je_categories_s');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_JE_CATEGORIES_PKG.get_unique_id');
      RAISE;

  END get_unique_id;

-- ************************************************************************

  PROCEDURE insert_fnd_cat( x_je_category_name       VARCHAR2,
                            x_user_je_category_name  VARCHAR2,
                            x_description            VARCHAR2,
                            x_last_updated_by        NUMBER,
                            x_created_by             NUMBER,
                            x_last_update_login      NUMBER )  IS
    CURSOR c_dup IS
      SELECT 'Duplicate'
      FROM   fnd_doc_sequence_categories fcat
      WHERE  fcat.application_id = 101
      AND    fcat.code = x_je_category_name ;
    dummy VARCHAR2(100);

  BEGIN
    OPEN  c_dup;
    FETCH c_dup INTO dummy;

    IF c_dup%NOTFOUND THEN
      INSERT INTO fnd_doc_sequence_categories (
             application_id, last_update_date, last_updated_by,
             code, name, description,
             table_name, created_by, creation_date,
             last_update_login )
      SELECT 101, sysdate, x_last_updated_by,
             x_je_category_name, x_user_je_category_name, x_description,
             'GL_JE_HEADERS', x_created_by, sysdate,
             x_last_update_login
      FROM   dual ;
    END IF;

    CLOSE c_dup;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_JE_CATEGORIES_PKG.insert_fnd_cat');
      RAISE;

  END insert_fnd_cat;

-- ************************************************************************

  PROCEDURE update_fnd_cat( x_je_category_name       VARCHAR2,
                            x_user_je_category_name  VARCHAR2,
                            x_description            VARCHAR2,
                            x_last_updated_by        NUMBER )  IS
    CURSOR c_dup IS
      SELECT 'Duplicate'
      FROM   fnd_doc_sequence_categories fcat
      WHERE  fcat.application_id = 101
      AND    fcat.code = x_je_category_name ;
    dummy VARCHAR2(100);

  BEGIN
    OPEN  c_dup;
    FETCH c_dup INTO dummy;

    IF c_dup%FOUND THEN
      UPDATE  fnd_doc_sequence_categories fcat
      SET     fcat.description = x_description,
              fcat.last_update_date = sysdate,
              fcat.last_updated_by = x_last_updated_by,
              fcat.name = x_user_je_category_name
      WHERE   fcat.application_id = 101
      AND     fcat.code = x_je_category_name;
    END IF;

    CLOSE c_dup;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_JE_CATEGORIES_PKG.update_fnd_cat');
      RAISE;

  END update_fnd_cat;

-- ************************************************************************

  PROCEDURE update_fnd_cat_all ( x_last_updated_by        NUMBER )  IS
    dummy VARCHAR2(100);

  BEGIN

      UPDATE  fnd_doc_sequence_categories fcat
      SET     ( fcat.description,
                fcat.last_update_date,
                fcat.last_updated_by,
                fcat.name ) =
                              ( select gcat.description,
                                       sysdate,
                                       x_last_updated_by,
                                       gcat.user_je_category_name
                                from   gl_je_categories_tl gcat
                                where  gcat.language = FND_GLOBAL.BASE_LANGUAGE
                                AND    gcat.je_category_name = fcat.code )
      WHERE   fcat.application_id = 101
      and     fcat.code  in (   select fcat2.code
                                from   gl_je_categories_tl gcat2,
                                       fnd_doc_sequence_categories fcat2
                                where  gcat2.language = FND_GLOBAL.BASE_LANGUAGE
                                AND    fcat2.application_id = 101
                                AND    gcat2.je_category_name = fcat2.code
                                AND    (    gcat2.user_je_category_name <> fcat2.name
                                         or gcat2.description <> fcat2.description ) );

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_JE_CATEGORIES_PKG.update_fnd_cat_all');
      RAISE;

  END update_fnd_cat_all;

-- ************************************************************************

  PROCEDURE insert_other_cat( x_je_category_name       VARCHAR2,
                            x_user_je_category_name  VARCHAR2,
                            x_description            VARCHAR2,
                            x_last_updated_by        NUMBER,
                            x_created_by             NUMBER,
                            x_last_update_login      NUMBER )  IS
  BEGIN
        insert_fnd_cat( x_je_category_name,
                        x_user_je_category_name,
                        x_description,
                        x_last_updated_by,
                        x_created_by,
                        x_last_update_login);

        GL_AUTOREVERSE_OPTIONS_PKG.insert_reversal_cat(
                        x_je_category_name,
                        x_created_by,
                        x_last_updated_by,
                        x_last_update_login);
  END;


-- ************************************************************************


  PROCEDURE select_columns(
			x_je_category_name		       VARCHAR2,
			x_user_je_category_name		IN OUT NOCOPY VARCHAR2 ) IS

    recinfo gl_je_categories%ROWTYPE;

  BEGIN
    recinfo.je_category_name := x_je_category_name;

    select_row(recinfo);

    x_user_je_category_name := recinfo.user_je_category_name;
    -- x_reversal_option_code := recinfo.reversal_option_code;
  END select_columns;

-- ************************************************************************

  PROCEDURE Insert_Row(X_Rowid              IN OUT NOCOPY  VARCHAR2,
                     X_Je_Category_Name     IN OUT NOCOPY  VARCHAR2,
                     X_Language             IN OUT NOCOPY  VARCHAR2,
                     X_Source_Lang          IN OUT NOCOPY  VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_User_Je_Category_Name               VARCHAR2,
                     X_Je_Category_Key                     VARCHAR2,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Description                         VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Consolidation_Flag                  VARCHAR2) IS
     CURSOR C IS SELECT rowid, language, source_lang
		 FROM gl_je_categories_tl
                 WHERE je_category_name = X_Je_Category_Name
                        and Language = userenv('LANG');
  BEGIN

    if (X_Je_Category_Name is NULL) then
--      app_exception.raise_exception;
      RAISE NO_DATA_FOUND;
    end if;

    -- update previously existing columns
    UPDATE GL_JE_CATEGORIES_TL
    SET
        consolidation_flag              =       UPPER(x_consolidation_flag)
    WHERE
	je_category_name = X_je_category_name;

    -- insert new columns
    INSERT INTO GL_JE_CATEGORIES_TL(
		je_category_name,
		language,
		source_lang,
		last_update_date,
		last_updated_by,
		user_je_category_name,
                je_category_key,
		creation_date,
		created_by,
		last_update_login,
		description,
		attribute1,
		attribute2,
		attribute3,
		attribute4,
		attribute5,
		context,
                consolidation_flag)
    SELECT
		     X_Je_Category_Name,
		     L.Language_Code,
		     userenv('LANG'),
                     X_Last_Update_Date,
                     X_Last_Updated_By,
		     X_User_Je_Category_Name,
                     X_Je_Category_Key,
                     X_Creation_Date,
                     X_Created_By,
		     X_Last_Update_Login,
		     X_Description,
                     X_Attribute1,
                     X_Attribute2,
                     X_Attribute3,
                     X_Attribute4,
                     X_Attribute5,
                     X_Context,
                     UPPER(X_Consolidation_Flag)
    FROM  FND_LANGUAGES L
    WHERE L.Installed_Flag in ('I', 'B')
    AND not exists
	( select NULL
	  from	 GL_JE_CATEGORIES_TL B
	  where  B.Je_Category_Name = X_Je_Category_Name
	  and	 B.Language = L.Language_Code);
    OPEN C;
    FETCH C INTO X_Rowid, X_Language, X_Source_lang;
    if (C%NOTFOUND) then
      CLOSE C;
      RAISE NO_DATA_FOUND;
    end if;
    CLOSE C;

    GL_JE_CATEGORIES_PKG.insert_other_cat( x_je_category_name,
                                           x_user_je_category_name,
                                           x_description,
                                           x_last_updated_by,
                                           x_created_by,
                                           x_last_update_login);

  END Insert_Row;

-- ************************************************************************

  PROCEDURE Lock_Row(X_Rowid                 IN OUT NOCOPY VARCHAR2,
		     X_Je_Category_Name			   VARCHAR2,
		     X_User_Je_Category_Name		   VARCHAR2,
                     X_Je_Category_Key                     VARCHAR2,
		     X_Description			   VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Consolidation_Flag                  VARCHAR2) IS
    CURSOR C IS
      SELECT * FROM GL_JE_CATEGORIES_TL
      WHERE je_category_name = X_je_category_name
        and Language = userenv('LANG')
      FOR UPDATE OF JE_CATEGORY_NAME NOWAIT;
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
         (    (   (Recinfo.je_category_name = X_je_category_name)
           OR (    (Recinfo.je_category_name IS NULL)
               AND (X_je_category_name IS NULL))))
         AND
         (    (   (Recinfo.user_je_category_name = X_user_je_category_name )
           OR (    (Recinfo.user_je_category_name IS NULL)
               AND (X_user_je_category_name IS NULL))))
         AND
         (    (   (Recinfo.je_category_key = X_je_category_key )
           OR (    (Recinfo.je_category_key IS NULL)
               AND (X_je_category_key IS NULL))))
         AND
         (    (   (Recinfo.description = X_description )
           OR (    (Recinfo.description IS NULL)
               AND (X_description IS NULL))))
         AND
         (    (   (Recinfo.attribute1 = X_attribute1 )
           OR (    (Recinfo.attribute1 IS NULL)
               AND (X_attribute1 IS NULL))))
         AND
         (    (   (Recinfo.attribute2 = X_attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (X_attribute2 IS NULL))))
         AND
         (    (   (Recinfo.attribute3 = X_attribute3 )
           OR (    (Recinfo.attribute3 IS NULL)
               AND (X_attribute3 IS NULL))))
         AND
         (    (   (Recinfo.attribute4 = X_attribute4 )
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_attribute4 IS NULL))))
         AND
         (    (   (Recinfo.attribute5 = X_attribute5 )
           OR (    (Recinfo.attribute5 IS NULL)
               AND (X_attribute5 IS NULL))))
         AND
         (    (   (Recinfo.context = X_context )
           OR (    (Recinfo.context IS NULL)
               AND (X_context IS NULL))))
         AND
         (    (   (Recinfo.consolidation_flag = UPPER(X_consolidation_flag) )
           OR (    (Recinfo.consolidation_flag IS NULL)
               AND (UPPER(X_consolidation_flag) IS NULL))))) THEN
        return;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  END Lock_Row;

-- ************************************************************************

  PROCEDURE Update_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
		     X_Je_Category_Name			   VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
		     X_User_Je_Category_Name		   VARCHAR2,
                     X_Je_Category_Key			   VARCHAR2,
                     X_Creation_Date			   DATE,
		     X_Last_Update_Login		   NUMBER,
		     X_Description			   VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Consolidation_Flag                  VARCHAR2) IS
  BEGIN
    -- update non-translatable columns
    UPDATE GL_JE_CATEGORIES_TL
    SET
	je_category_name		= 	x_je_category_name,
        je_category_key                 =       x_je_category_key,
	last_update_date		= 	x_last_update_date,
	last_updated_by			= 	x_last_updated_by,
	creation_date			= 	x_creation_date,
	last_update_login		= 	x_last_update_login,
	attribute1			= 	x_attribute1,
	attribute2			= 	x_attribute2,
	attribute3			= 	x_attribute3,
	attribute4			= 	x_attribute4,
	attribute5			= 	x_attribute5,
	context				= 	x_context,
        consolidation_flag              =       UPPER(x_consolidation_flag)
    WHERE
	je_category_name = X_je_category_name;

    if (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
    end if;

    -- update the translatable columns
    UPDATE GL_JE_CATEGORIES_TL
    SET
	user_je_category_name		= 	x_user_je_category_name,
	description			= 	x_description,
	source_lang 			= 	userenv('LANG')
    WHERE je_category_name = x_je_category_name
      and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    if (sql%notfound) then
    	raise no_data_found;
    end if;
  END Update_Row;

-- ************************************************************************

  PROCEDURE Load_Row(X_Je_Category_Name        IN OUT NOCOPY      VARCHAR2,
                     X_Je_Category_Key                     VARCHAR2,
                     X_User_Je_Category_Name               VARCHAR2,
                     X_Description                         VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Owner                               VARCHAR2,
		     X_Force_Edits			   VARCHAR2) IS
    user_id number := 0;
    v_creation_date date;
    v_rowid rowid := null;
    v_language VARCHAR2(4) := null;
    v_source_lang VARCHAR2(4) := null;
  BEGIN

    -- validate input parameters
    if ( X_User_Je_Category_Name is NULL ) then
      fnd_message.set_name('SQLGL', 'GL_LOAD_ROW_NO_DATA');
      app_exception.raise_exception;
    end if;

    if (X_OWNER = 'SEED') then
      user_id := 1;
    end if;

    begin
    /* When je_category_name is null, we assume it to be a new row. */
    if (X_je_category_name is null) then
	SELECT gl_je_categories_s.NEXTVAL
	INTO   X_je_category_name
	FROM   dual;
        raise no_data_found;
    end if;

    /* Check if the row exists in the database. If it does, retrieves
       the creation date for update_row. */
    select creation_date
    into   v_creation_date
    from   gl_je_categories
    where  je_category_name = X_je_category_name;

    /* Update only if force_edits is 'Y' or if user_id = 1 */
    if ( user_id = 1 or X_Force_Edits = 'Y' ) then
       -- update row in GL_JE_CATEGORIES_TL if present
       GL_JE_CATEGORIES_PKG.Update_Row(
          X_Rowid                  => v_rowid,
          X_je_category_name       => X_Je_Category_Name,
          X_last_update_date       => sysdate,
          X_last_updated_by        => user_id,
          X_user_je_category_name  => X_user_je_category_name,
          X_je_category_key        => nvl(X_Je_Category_Key,
                                          X_Je_Category_Name),
          X_creation_date          => v_creation_date,
          X_last_update_login      => 0,
          X_Description            => X_Description,
          X_Attribute1             => X_Attribute1,
          X_Attribute2             => X_Attribute2,
          X_Attribute3             => X_Attribute3,
          X_Attribute4             => X_Attribute4,
          X_Attribute5             => X_Attribute5,
          X_context                => X_Context,
          X_Consolidation_Flag     => null);

       -- update FND_DOC_SEQUENCE_CATEGORIES if change is made in
       -- the base language
       if ( userenv('LANG') = FND_GLOBAL.BASE_LANGUAGE ) then
          GL_JE_CATEGORIES_PKG.update_fnd_cat( x_je_category_name,
                                               x_user_je_category_name,
                                               x_description,
                                               user_id );
       end if;
    end if;
    exception
        when NO_DATA_FOUND then
          GL_JE_CATEGORIES_PKG.Insert_Row(
          X_Rowid                  => v_rowid,
          X_je_category_name       => X_Je_Category_Name,
          X_language               => v_language,
          X_source_lang            => v_source_lang,
          X_last_update_date       => sysdate,
          X_last_updated_by        => user_id,
          X_user_je_category_name  => X_user_je_category_name,
          X_je_category_key        => Nvl(X_Je_Category_Key,
                                          X_Je_Category_Name),
          X_creation_date          => sysdate,
	  X_created_by		   => user_id,
          X_last_update_login      => 0,
          X_Description            => X_Description,
          X_Attribute1             => X_Attribute1,
          X_Attribute2             => X_Attribute2,
          X_Attribute3             => X_Attribute3,
          X_Attribute4             => X_Attribute4,
          X_Attribute5             => X_Attribute5,
          X_context                => X_Context,
          X_Consolidation_Flag     => null);
    end;
  END Load_Row;

-- ************************************************************************
  PROCEDURE Translate_Row(
                     X_Je_Category_Name                    VARCHAR2,
                     X_User_Je_Category_Name               VARCHAR2,
                     X_Description                         VARCHAR2,
                     X_Owner                               VARCHAR2,
		     X_Force_Edits			   VARCHAR2 ) IS
    user_id number := 0;
  BEGIN
    if (X_OWNER = 'SEED') then
      user_id := 1;
    end if;

    /* Update only if force_edits is 'Y' or if user_id = 1 */
    if ( user_id = 1 or X_Force_Edits = 'Y' ) then
      UPDATE GL_JE_CATEGORIES_TL
      SET
        user_je_category_name           =       x_user_je_category_name,
        description                     =       x_description,
        last_update_date                =       sysdate,
        last_updated_by                 =       user_id,
        last_update_login               =       0,
        source_lang                     =       userenv('LANG')
      WHERE userenv('LANG') in (LANGUAGE, SOURCE_LANG)
        and je_category_name = X_je_category_name;

      -- update FND_DOC_SEQUENCE_CATEGORIES if change is made in
      -- the base language
      if ( userenv('LANG') = FND_GLOBAL.BASE_LANGUAGE ) then
         GL_JE_CATEGORIES_PKG.update_fnd_cat( x_je_category_name,
                                              x_user_je_category_name,
                                              x_description,
                                              user_id );
      end if;
    end if;
  /*If base language is not set to the language being uploaded, then do nothing.*/
    if (sql%notfound) then
        null;
    end if;
  END Translate_Row;

-- ************************************************************************

procedure ADD_LANGUAGE
is
begin

  update GL_JE_CATEGORIES_TL T
  set (      	user_je_category_name,
		DESCRIPTION    )
  =   (	select
      	  	B.user_je_category_name,
      	  	B.DESCRIPTION
    	from gl_je_categories_tl B
    	where B.je_category_name = T.je_category_name
    	  and B.LANGUAGE = T.SOURCE_LANG )
  where (	T.je_category_name,
      		T.LANGUAGE  ) in
	( select
      		SUBT.je_category_name,
      		SUBT.LANGUAGE
	  from 	gl_je_categories_tl SUBB,
		gl_je_categories_tl SUBT
    	  where SUBB.je_category_name = SUBT.je_category_name
    	    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    	    and (SUBB.USER_JE_CATEGORY_NAME <> SUBT.USER_JE_CATEGORY_NAME
		or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      		or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      		or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null))
  	);

  insert into gl_je_categories_tl (
    je_category_name,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    user_je_category_name,
    je_category_key,
    LANGUAGE,
    SOURCE_LANG,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    context,
    consolidation_flag
  )
  select
    B.je_category_name,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    B.user_je_category_name,
    B.je_category_key,
    L.LANGUAGE_CODE,
    B.source_lang,
    B.attribute1,
    B.attribute2,
    B.attribute3,
    B.attribute4,
    B.attribute5,
    B.context,
    B.consolidation_flag
  from gl_je_categories_tl B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from gl_je_categories_tl T
    where T.je_category_name = B.je_category_name
    and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;

-- ************************************************************************

END GL_JE_CATEGORIES_PKG;

/
