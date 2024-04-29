--------------------------------------------------------
--  DDL for Package Body GL_JE_SOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_JE_SOURCES_PKG" AS
/* $Header: glijesrb.pls 120.10 2005/05/05 01:09:58 kvora ship $ */

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
  --   gl_je_sources_pkg.select_row(recinfo)
  -- Notes
  --
  PROCEDURE select_row( recinfo IN OUT NOCOPY gl_je_sources%ROWTYPE) IS
  BEGIN
    SELECT *
    INTO recinfo
    FROM gl_je_sources
    WHERE je_source_name = recinfo.je_source_name;
  END SELECT_ROW;

  PROCEDURE select_columns(x_je_source_name		       VARCHAR2,
			   x_user_je_source_name	IN OUT NOCOPY VARCHAR2,
			   x_effective_date_rule_code	IN OUT NOCOPY VARCHAR2,
			   x_frozen_source_flag		IN OUT NOCOPY VARCHAR2,
			   x_journal_approval_flag      IN OUT NOCOPY VARCHAR2) IS
    recinfo gl_je_sources%ROWTYPE;

  BEGIN
    recinfo.je_source_name := x_je_source_name;
    select_row(recinfo);
    x_user_je_source_name := recinfo.user_je_source_name;
    x_effective_date_rule_code := recinfo.effective_date_rule_code;
    x_frozen_source_flag := recinfo.override_edits_flag;
    x_journal_approval_flag := recinfo.journal_approval_flag;
  END select_columns;

  PROCEDURE check_unique_name(x_je_source_name VARCHAR2,
                              x_row_id VARCHAR2) IS
    CURSOR chk_duplicates_name is
      SELECT 'Duplicate'
      FROM   GL_JE_SOURCES jes
      WHERE  jes.je_source_name = x_je_source_name
      AND    (   x_row_id is null
              OR jes.rowid <> chartorowid(x_row_id)) ;
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_duplicates_name;
    FETCH chk_duplicates_name INTO dummy;
    IF chk_duplicates_name%FOUND THEN
      CLOSE chk_duplicates_name;
      fnd_message.set_name('SQLGL', 'GL_DUPLICATE_JE_SOURCE_NAME');
      app_exception.raise_exception;
    END IF;
    CLOSE chk_duplicates_name;
  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_je_sources_pkg.check_unique_name');
      RAISE;
  END check_unique_name;

  PROCEDURE check_unique_user_name(x_user_je_source_name VARCHAR2,
                                   x_row_id VARCHAR2) IS
    CURSOR chk_duplicates_user_name is
      SELECT 'Duplicate'
      FROM   GL_JE_SOURCES jes
      WHERE  jes.user_je_source_name = x_user_je_source_name
      AND    (   x_row_id is null
              OR jes.rowid <> x_row_id);
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_duplicates_user_name;
    FETCH chk_duplicates_user_name INTO dummy;
    IF chk_duplicates_user_name%FOUND THEN
      CLOSE chk_duplicates_user_name;
      fnd_message.set_name('SQLGL', 'GL_DUPLICATE_JE_SOURCE_NAME');
      app_exception.raise_exception;
    END IF;
    CLOSE chk_duplicates_user_name;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                 'gl_je_sources_pkg.check_unique_user_name');
      RAISE;
  END check_unique_user_name;

  PROCEDURE check_unique_key(x_je_source_key VARCHAR2,
                             x_row_id VARCHAR2) IS
    CURSOR chk_duplicates_key is
      SELECT 'Duplicate'
      FROM   GL_JE_SOURCES jes
      WHERE  jes.je_source_key = x_je_source_key
      AND    (   x_row_id is null
              OR jes.rowid <> x_row_id);
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_duplicates_key;
    FETCH chk_duplicates_key INTO dummy;
    IF chk_duplicates_key%FOUND THEN
      CLOSE chk_duplicates_key;
      fnd_message.set_name('SQLGL', 'GL_DUPLICATE_JE_SOURCE_KEY');
      app_exception.raise_exception;
    END IF;
    CLOSE chk_duplicates_key;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                 'gl_je_sources_pkg.check_unique_key');
      RAISE;
  END check_unique_key;

  FUNCTION get_unique_id RETURN NUMBER IS
    CURSOR get_new_id IS
      SELECT gl_je_sources_s.NEXTVAL
      FROM sys.dual;
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
      fnd_message.set_token('SEQUENCE', 'GL_JE_SOURCES_S');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_je_sources_pkg.get_unique_id');
      RAISE;
  END get_unique_id;

  FUNCTION is_sla_source( X_je_source  VARCHAR2) RETURN BOOLEAN IS
    CURSOR chk_sla_source IS
      SELECT 'Is SLA Source'
      FROM
	     XLA_SUBLEDGERS sla
      WHERE  sla.je_source_name = X_je_source;
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_sla_source;
    FETCH chk_sla_source INTO dummy;

    IF ( chk_sla_source%FOUND ) THEN
      CLOSE chk_sla_source;
      RETURN(TRUE);
    ELSE
      CLOSE chk_sla_source;
      return(FALSE);
    END IF;
  END is_sla_source;


  PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
		     X_Je_Source_Name	IN OUT NOCOPY		   VARCHAR2,
		     X_Language		IN OUT NOCOPY		   VARCHAR2,
		     X_Source_Lang	IN OUT NOCOPY		   VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
		     X_Override_Edits_Flag		   VARCHAR2,
		     X_User_Je_Source_Name		   VARCHAR2,
                     X_Je_Source_Key                       VARCHAR2,
		     X_Journal_Reference_Flag		   VARCHAR2,
                     X_Journal_Approval_Flag               VARCHAR2,
                     X_Effective_Date_Rule_Code            VARCHAR2,
                     X_Import_Using_Key_Flag               VARCHAR2,
                     X_Creation_Date			   DATE,
		     X_Last_Update_Login		   NUMBER,
		     X_Description			   VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Context                             VARCHAR2) IS
     CURSOR C IS SELECT rowid, language, source_lang
		  FROM GL_JE_SOURCES_TL
                 WHERE je_source_name = X_Je_Source_Name
			and Language = userenv('LANG');
     CURSOR C2 IS SELECT gl_je_headers_s.nextval FROM dual;
  BEGIN

    if (X_Je_Source_Name is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Je_Source_Name;
     CLOSE C2;
    end if;
    INSERT INTO GL_JE_SOURCES_TL(
		je_source_name,
                je_source_key,
		language,
		source_lang,
		last_update_date,
		last_updated_by,
		override_edits_flag,
		user_je_source_name,
		journal_reference_flag,
                journal_approval_flag,
                effective_date_rule_code,
                import_using_key_flag,
		creation_date,
		created_by,
		last_update_login,
		description,
		attribute1,
		attribute2,
		attribute3,
		attribute4,
		attribute5,
		context)
    SELECT
		     X_Je_Source_Name,
                     X_Je_Source_Key,
		     L.Language_Code,
		     userenv('LANG'),
                     X_Last_Update_Date,
                     X_Last_Updated_By,
		     X_Override_Edits_Flag,
		     X_User_Je_Source_Name,
		     X_Journal_Reference_Flag,
                     X_Journal_Approval_Flag,
                     X_Effective_Date_Rule_Code,
                     X_Import_Using_Key_Flag,
                     X_Creation_Date,
-- workaround for passing in created_by information w/o changing the spec
                     X_Last_Updated_By,
		     X_Last_Update_Login,
		     X_Description,
                     X_Attribute1,
                     X_Attribute2,
                     X_Attribute3,
                     X_Attribute4,
                     X_Attribute5,
                     X_Context
    FROM  FND_LANGUAGES L
    WHERE L.Installed_Flag in ('I', 'B')
    AND not exists
	( select NULL
	  from	 GL_JE_SOURCES_TL B
	  where  B.Je_Source_Name = X_Je_Source_Name
	  and	 B.Language = L.Language_Code);
    OPEN C;
    FETCH C INTO X_Rowid, X_Language, X_Source_Lang;
    if (C%NOTFOUND) then
      CLOSE C;
      RAISE NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
		     X_Je_Source_Name			   VARCHAR2,
		     X_Override_Edits_Flag		   VARCHAR2,
		     X_User_Je_Source_Name		   VARCHAR2,
                     X_Je_Source_Key			   VARCHAR2,
		     X_Journal_Reference_Flag		   VARCHAR2,
                     X_Journal_Approval_Flag               VARCHAR2,
                     X_Effective_Date_Rule_Code            VARCHAR2,
                     X_Import_Using_Key_Flag               VARCHAR2,
		     X_Description			   VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Context                             VARCHAR2) IS
    CURSOR C IS
      SELECT * FROM GL_JE_SOURCES_TL
      WHERE Je_Source_Name = X_Je_Source_Name
        and Language = userenv('LANG')
      FOR UPDATE OF JE_SOURCE_NAME NOWAIT;
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
         (    (   (Recinfo.je_source_name = X_je_source_name)
           OR (    (Recinfo.je_source_name IS NULL)
               AND (X_je_source_name IS NULL))))
         AND
         (    (   (Recinfo.override_edits_flag = X_override_edits_flag )
           OR (    (Recinfo.override_edits_flag IS NULL)
               AND (X_override_edits_flag IS NULL))))
         AND
         (    (   (Recinfo.user_je_source_name = X_user_je_source_name )
           OR (    (Recinfo.user_je_source_name IS NULL)
               AND (X_user_je_source_name IS NULL))))
         AND
         (    (   (Recinfo.je_source_key = X_je_source_key )
           OR (    (Recinfo.je_source_key IS NULL)
               AND (X_je_source_key IS NULL))))
         AND
         (    (   (Recinfo.journal_reference_flag = X_journal_reference_flag )
           OR (    (Recinfo.journal_reference_flag IS NULL)
               AND (X_journal_reference_flag IS NULL))))
         AND
         (    (   (Recinfo.journal_approval_flag = X_journal_approval_flag)
           OR (    (Recinfo.journal_approval_flag IS NULL)
               AND (X_journal_approval_flag IS NULL))))
         AND
         (    (   (Recinfo.effective_date_rule_code = X_effective_date_rule_code)
           OR (    (Recinfo.effective_date_rule_code IS NULL)
               AND (X_effective_date_rule_code IS NULL))))
         AND
         (    (   (Recinfo.import_using_key_flag = X_import_using_key_flag)
           OR (    (Recinfo.import_using_key_flag IS NULL)
               AND (X_import_using_key_flag IS NULL))))
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
               AND (X_context IS NULL))))) THEN
        return;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  END Lock_Row;


  PROCEDURE Update_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
		     X_Je_Source_Name			   VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
		     X_Override_Edits_Flag		   VARCHAR2,
		     X_User_Je_Source_Name		   VARCHAR2,
                     X_Je_Source_Key                       VARCHAR2,
		     X_Journal_Reference_Flag		   VARCHAR2,
                     X_Journal_Approval_Flag               VARCHAR2,
                     X_Effective_Date_Rule_Code            VARCHAR2,
                     X_Import_Using_Key_Flag               VARCHAR2,
                     X_Creation_Date			   DATE,
		     X_Last_Update_Login		   NUMBER,
		     X_Description			   VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Context                             VARCHAR2) IS
  BEGIN
    -- update non-translatable columns
    UPDATE GL_JE_SOURCES_TL
    SET
	je_source_name			= 	x_je_source_name,
        je_source_key                   =       x_je_source_key,
	override_edits_flag		= 	x_override_edits_flag,
	journal_reference_flag		= 	x_journal_reference_flag,
        journal_approval_flag           =       x_journal_approval_flag,
        effective_date_rule_code        =       x_effective_date_rule_code,
        import_using_key_flag           =       x_import_using_key_flag,
	creation_date			= 	x_creation_date,
	last_update_date		= 	x_last_update_date,
	last_updated_by			= 	x_last_updated_by,
	last_update_login		= 	x_last_update_login,
	attribute1			= 	x_attribute1,
	attribute2			= 	x_attribute2,
	attribute3			= 	x_attribute3,
	attribute4			= 	x_attribute4,
	attribute5			= 	x_attribute5,
	context				= 	x_context
    WHERE
	Je_Source_Name = X_Je_Source_Name;

    if (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
    end if;

    -- update the translatable columns
    UPDATE GL_JE_SOURCES_TL
    SET
	user_je_source_name		= 	x_user_je_source_name,
	description			= 	x_description,
	source_lang 			= 	userenv('LANG')
    WHERE je_source_name = X_je_source_name
      and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    if (sql%notfound) then
    	raise no_data_found;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Je_Source_Name VARCHAR2) IS
  BEGIN
    DELETE FROM GL_JE_SOURCES_TL
    WHERE  Je_Source_Name = X_Je_Source_Name;

    if (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
    end if;
  END Delete_Row;

  PROCEDURE Load_Row(X_Je_Source_Name	    IN OUT NOCOPY  VARCHAR2,
		     X_Override_Edits_Flag		   VARCHAR2,
		     X_User_Je_Source_Name		   VARCHAR2,
                     X_Je_Source_Key                       VARCHAR2,
		     X_Journal_Reference_Flag		   VARCHAR2,
                     X_Journal_Approval_Flag               VARCHAR2,
                     X_Effective_Date_Rule_Code            VARCHAR2,
                     X_Import_Using_Key_Flag               VARCHAR2,
		     X_Description			   VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Context                             VARCHAR2,
		     X_Owner				   VARCHAR2,
		     X_Force_Edits			   VARCHAR2 ) IS
    user_id number := 0;
    v_creation_date date;
    v_rowid rowid := null;
    v_language VARCHAR2(4) := null;
    v_source_lang VARCHAR2(4) := null;
  BEGIN

    -- validate input parameters
    if (	X_Override_Edits_Flag is NULL
	or	X_User_Je_Source_Name is NULL
	or	X_Journal_Reference_Flag is NULL
	or	X_Effective_Date_Rule_Code is NULL
	or	X_Journal_Approval_Flag is NULL) then
      fnd_message.set_name('SQLGL', 'GL_LOAD_ROW_NO_DATA');
      app_exception.raise_exception;
    end if;

    if (X_OWNER = 'SEED') then
      user_id := 1;
    end if;

    begin
    /* When je_source_name is null, we assume it to be a new row. */
    if (X_je_source_name is null) then
    	raise no_data_found;
    end if;

    /* Check if the row exists in the database. If it does, retrieves
       the creation date for update_row. */
    select creation_date
    into   v_creation_date
    from   gl_je_sources
    where  je_source_name = X_je_source_name;

    /* Update only if force_edits is 'Y' or if user_id = 1 */
    if ( user_id = 1 or X_Force_Edits = 'Y' ) then
       -- update row if present
       GL_JE_SOURCES_PKG.Update_Row(
          X_Rowid                => v_rowid,
          X_je_source_name       => X_Je_Source_Name,
          X_last_update_date     => sysdate,
          X_last_updated_by      => user_id,
          X_override_edits_flag  => X_Override_Edits_Flag,
          X_user_je_source_name  => X_user_je_source_name,
          X_je_source_key        => nvl(X_Je_Source_Key, X_Je_Source_Name),
          X_journal_reference_flag => X_journal_reference_flag,
          X_journal_approval_flag  => X_journal_approval_flag,
          X_effective_date_rule_code => X_effective_date_rule_code,
          X_import_using_key_flag => nvl(X_import_using_key_flag, 'N'),
          X_creation_date        => v_creation_date,
          X_last_update_login    => 0,
          X_Description          => X_Description,
          X_Attribute1           => X_Attribute1,
          X_Attribute2           => X_Attribute2,
          X_Attribute3           => X_Attribute3,
          X_Attribute4           => X_Attribute4,
          X_Attribute5           => X_Attribute5,
          X_context		 => X_Context);
    end if;
    exception
	when NO_DATA_FOUND then
	  GL_JE_SOURCES_PKG.Insert_Row(
          X_Rowid                => v_rowid,
          X_je_source_name       => X_Je_Source_Name,
	  X_language		 => v_language,
	  X_source_lang		 => v_source_lang,
          X_last_update_date     => sysdate,
          X_last_updated_by      => user_id,
          X_override_edits_flag  => X_Override_Edits_Flag,
          X_user_je_source_name  => X_user_je_source_name,
          X_je_source_key        => nvl(X_Je_Source_Key, X_Je_Source_Name),
          X_journal_reference_flag => X_journal_reference_flag,
          X_journal_approval_flag  => X_journal_approval_flag,
          X_effective_date_rule_code => X_effective_date_rule_code,
          X_import_using_key_flag => nvl(X_import_using_key_flag, 'N'),
          X_creation_date        => sysdate,
          X_last_update_login    => 0,
          X_Description          => X_Description,
          X_Attribute1           => X_Attribute1,
          X_Attribute2           => X_Attribute2,
          X_Attribute3           => X_Attribute3,
          X_Attribute4           => X_Attribute4,
          X_Attribute5           => X_Attribute5,
          X_context		 => X_Context);
    end;
  END Load_Row;

  PROCEDURE Translate_Row(
		     X_Je_Source_Name			   VARCHAR2,
		     X_User_Je_Source_Name		   VARCHAR2,
		     X_Description			   VARCHAR2,
		     X_Owner				   VARCHAR2,
		     X_Force_Edits			   VARCHAR2 ) IS
    user_id number := 0;
  BEGIN
    if (X_OWNER = 'SEED') then
      user_id := 1;
    end if;

    /* Update only if force_edits is 'Y' or user_id = 1 */
    if ( user_id = 1 or X_Force_Edits = 'Y' ) then
      UPDATE GL_JE_SOURCES_TL
      SET
	user_je_source_name		= 	x_user_je_source_name,
	description			= 	x_description,
	last_update_date		= 	sysdate,
	last_updated_by			= 	user_id,
	last_update_login		= 	0,
	source_lang 			= 	userenv('LANG')
      WHERE userenv('LANG') in (LANGUAGE, SOURCE_LANG)
	and je_source_name = X_je_source_name;
    end if;
    /*If base language is not set to the language being uploaded, then
     do nothing.*/
    if (sql%notfound) then
    	null;
    end if;
  END Translate_Row;

procedure ADD_LANGUAGE
is
begin


  update GL_JE_SOURCES_TL T
  set (      	user_je_source_name,
		DESCRIPTION    )
  =   (	select
      	  	B.user_je_source_name,
      	  	B.DESCRIPTION
    	from gl_je_sources_tl B
    	where B.je_source_name = T.je_source_name
    	  and B.LANGUAGE = T.SOURCE_LANG )
  where (	T.je_source_name,
      		T.LANGUAGE  ) in
	( select
      		SUBT.je_source_name,
      		SUBT.LANGUAGE
	  from 	gl_je_sources_tl SUBB,
		gl_je_sources_tl SUBT
    	  where SUBB.je_source_name = SUBT.je_source_name
    	    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
	    and (SUBB.USER_JE_SOURCE_NAME <> SUBT.USER_JE_SOURCE_NAME
    	        or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      		or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      		or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null))
  	);

  insert into gl_je_sources_tl (
    je_source_name,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    override_edits_flag,
    user_je_source_name,
    je_source_key,
    journal_reference_flag,
    journal_approval_flag,
    effective_date_rule_code,
    import_using_key_flag,
    LANGUAGE,
    SOURCE_LANG,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    context
  )
  select
    B.je_source_name,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    B.override_edits_flag,
    B.user_je_source_name,
    B.je_source_key,
    B.journal_reference_flag,
    B.journal_approval_flag,
    B.effective_date_rule_code,
    B.import_using_key_flag,
    L.LANGUAGE_CODE,
    B.source_lang,
    B.attribute1,
    B.attribute2,
    B.attribute3,
    B.attribute4,
    B.attribute5,
    B.context
  from gl_je_sources_tl B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from gl_je_sources_tl T
    where T.je_source_name = B.je_source_name
    and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;

END gl_je_sources_pkg;

/
