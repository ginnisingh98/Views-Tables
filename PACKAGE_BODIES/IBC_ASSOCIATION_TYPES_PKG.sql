--------------------------------------------------------
--  DDL for Package Body IBC_ASSOCIATION_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_ASSOCIATION_TYPES_PKG" AS
/* $Header: ibctatyb.pls 120.3 2006/06/22 09:21:46 sharma ship $*/

-- Purpose: Table Handler for IBC_ASSOCIATION_TYPES table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- shitij.vatsa      11/04/2002      Updated for FND_API.G_MISS_XXX
-- Siva Devaki       12/01/2003      Added Overloaded procedures for OA UI
-- Siva Devaki       06/24/2005      NOCOPY changes made to fix#4399469
-- SHARMA 	     07/04/2005	     Modified LOAD_ROW, TRANSLATE_ROW and created
-- 			             LOAD_SEED_ROW for R12 LCT standards bug 4411674

PROCEDURE insert_row (
 p_association_type_code           IN VARCHAR2
,p_search_page                     IN VARCHAR2
,p_object_version_number           IN NUMBER
,p_call_back_pkg                   IN VARCHAR2
,p_association_type_name           IN VARCHAR2
,p_description                     IN VARCHAR2
,p_creation_date                   IN DATE          --DEFAULT NULL
,p_created_by                      IN NUMBER        --DEFAULT NULL
,p_last_update_date                IN DATE          --DEFAULT NULL
,p_last_updated_by                 IN NUMBER        --DEFAULT NULL
,p_last_update_login               IN NUMBER        --DEFAULT NULL
,x_rowid                           OUT NOCOPY VARCHAR2
) IS
  CURSOR c IS SELECT ROWID FROM ibc_association_types_b
    WHERE association_type_code = p_association_type_code
    ;
BEGIN
  INSERT INTO ibc_association_types_b (
     association_type_code
    ,search_page
    ,object_version_number
    ,call_back_pkg
    ,creation_date
    ,created_by
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ) VALUES (
     p_association_type_code
    ,DECODE(p_search_page,FND_API.G_MISS_CHAR,NULL,p_search_page)
    ,DECODE(p_object_version_number,FND_API.G_MISS_NUM,1,NULL,1,p_object_version_number)
    ,DECODE(p_call_back_pkg,FND_API.G_MISS_CHAR,NULL,p_call_back_pkg)
    ,DECODE(p_creation_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_creation_date)
    ,DECODE(p_created_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_created_by)
    ,DECODE(p_last_update_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
    ,DECODE(p_last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
    ,DECODE(p_last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,p_last_update_login)
  );

  INSERT INTO ibc_association_types_tl (
     association_type_code
    ,association_type_name
    ,description
    ,creation_date
    ,created_by
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,language
    ,source_lang
  ) SELECT
     p_association_type_code
    ,DECODE(p_association_type_name,FND_API.G_MISS_CHAR,NULL,p_association_type_name)
    ,DECODE(p_description,FND_API.G_MISS_CHAR,NULL,p_description)
    ,DECODE(p_creation_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_creation_date)
    ,DECODE(p_created_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_created_by)
    ,DECODE(p_last_update_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
    ,DECODE(p_last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
    ,DECODE(p_last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,p_last_update_login)
    ,l.language_code
    ,USERENV('lang')
  FROM fnd_languages l
  WHERE l.installed_flag IN ('I', 'B')
  AND NOT EXISTS
    (SELECT NULL
    FROM ibc_association_types_tl t
    WHERE t.association_type_code = p_association_type_code
    AND t.LANGUAGE = l.language_code);

  OPEN c;
  FETCH c INTO x_rowid;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END insert_row;

PROCEDURE lock_row (
  p_association_type_code IN VARCHAR2,
  p_search_page IN VARCHAR2,
  p_object_version_number IN NUMBER,
  p_association_type_name IN VARCHAR2,
  p_description IN VARCHAR2
) IS
  CURSOR c IS SELECT
      search_page,
      object_version_number
     FROM ibc_association_types_b
    WHERE association_type_code = p_association_type_code
    FOR UPDATE OF association_type_code NOWAIT;
  recinfo c%ROWTYPE;

  CURSOR c1 IS SELECT
      association_type_name,
      description,
      DECODE(LANGUAGE, USERENV('LANG'), 'Y', 'N') baselang
    FROM ibc_association_types_tl
    WHERE association_type_code = p_association_type_code
    AND USERENV('lang') IN (LANGUAGE, source_lang)
    FOR UPDATE OF association_type_code NOWAIT;
BEGIN
  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    fnd_message.set_name('fnd', 'form_record_deleted');
    app_exception.raise_exception;
  END IF;
  CLOSE c;
  IF (    (recinfo.search_page = p_search_page)
      AND (recinfo.object_version_number = p_object_version_number)

  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('fnd', 'form_record_changed');
    app_exception.raise_exception;
  END IF;

  FOR tlinfo IN c1 LOOP
    IF (tlinfo.baselang = 'Y') THEN
      IF (    (tlinfo.association_type_name = p_association_type_name)
          AND ((tlinfo.description = p_description)
               OR ((tlinfo.description IS NULL) AND (p_description IS NULL)))
      ) THEN
        NULL;
      ELSE
        fnd_message.set_name('fnd', 'form_record_changed');
        app_exception.raise_exception;
      END IF;
    END IF;
  END LOOP;
  RETURN;
END lock_row;

PROCEDURE update_row (
 p_association_type_code           IN VARCHAR2
,p_association_type_name           IN VARCHAR2      --DEFAULT NULL
,p_call_back_pkg                   IN VARCHAR2
,p_description                     IN VARCHAR2      --DEFAULT NULL
,p_last_updated_by                 IN NUMBER        --DEFAULT NULL
,p_last_update_date                IN DATE          --DEFAULT NULL
,p_last_update_login               IN NUMBER        --DEFAULT NULL
,p_object_version_number           IN NUMBER        --DEFAULT NULL
,p_search_page                     IN VARCHAR2      --DEFAULT NULL
)
IS
BEGIN
  UPDATE ibc_association_types_b SET
      search_page               = DECODE(p_search_page,FND_API.G_MISS_CHAR,NULL,NULL,search_page,p_search_page)
     ,object_version_number     = NVL(object_version_number,0) + 1
     ,call_back_pkg             = DECODE(p_call_back_pkg,FND_API.G_MISS_CHAR,NULL,NULL,call_back_pkg,p_call_back_pkg)
     ,last_update_date          = DECODE(p_last_update_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
     ,last_updated_by           = DECODE(p_last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
     ,last_update_login         = DECODE(p_last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,p_last_update_login)
  WHERE association_type_code = p_association_type_code
  AND object_version_number = DECODE(p_object_version_number,
                                       FND_API.g_miss_num,
                                       object_version_number,
                                       NULL,
                                       object_version_number,
                                       p_object_version_number);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  UPDATE ibc_association_types_tl SET
     association_type_name     = DECODE(p_association_type_name,FND_API.G_MISS_CHAR,NULL,NULL,association_type_name,p_association_type_name)
    ,description               = DECODE(p_description,FND_API.G_MISS_CHAR,NULL,NULL,description,p_description)
    ,last_update_date          = DECODE(p_last_update_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
    ,last_updated_by           = DECODE(p_last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
    ,last_update_login         = DECODE(p_last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,p_last_update_login)
    ,source_lang               = USERENV('LANG')
  WHERE association_type_code = p_association_type_code
  AND USERENV('LANG') IN (LANGUAGE, source_lang);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END update_row;

PROCEDURE delete_row (
  p_association_type_code IN VARCHAR2
) IS
BEGIN
  DELETE FROM ibc_association_types_tl
  WHERE association_type_code = p_association_type_code;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  DELETE FROM ibc_association_types_b
  WHERE association_type_code = p_association_type_code;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END delete_row;

PROCEDURE add_language
IS
BEGIN
  DELETE FROM ibc_association_types_tl t
  WHERE NOT EXISTS
    (SELECT NULL
    FROM ibc_association_types_b b
    WHERE b.association_type_code = t.association_type_code
    );

  UPDATE ibc_association_types_tl t SET (
      association_type_name,
      description
    ) = (SELECT
      b.association_type_name,
      b.description
    FROM ibc_association_types_tl b
    WHERE b.association_type_code = t.association_type_code
    AND b.LANGUAGE = t.source_lang)
  WHERE (
      t.association_type_code,
      t.LANGUAGE
  ) IN (SELECT
      subt.association_type_code,
      subt.LANGUAGE
    FROM ibc_association_types_tl subb, ibc_association_types_tl subt
    WHERE subb.association_type_code = subt.association_type_code
    AND subb.LANGUAGE = subt.source_lang
    AND (subb.association_type_name <> subt.association_type_name
      OR subb.description <> subt.description
      OR (subb.description IS NULL AND subt.description IS NOT NULL)
      OR (subb.description IS NOT NULL AND subt.description IS NULL)
  ));

  INSERT INTO ibc_association_types_tl (
    association_type_code,
    association_type_name,
    description,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    LANGUAGE,
    source_lang
  ) SELECT /*+ ordered */
    b.association_type_code,
    b.association_type_name,
    b.description,
    b.created_by,
    b.creation_date,
    b.last_updated_by,
    b.last_update_date,
    b.last_update_login,
    l.language_code,
    b.source_lang
  FROM ibc_association_types_tl b, fnd_languages l
  WHERE l.installed_flag IN ('I', 'B')
  AND b.LANGUAGE = USERENV('LANG')
  AND NOT EXISTS
    (SELECT NULL
    FROM ibc_association_types_tl t
    WHERE t.association_type_code = b.association_type_code
    AND t.LANGUAGE = l.language_code);
END add_language;

PROCEDURE LOAD_SEED_ROW (
 p_upload_mode			IN VARCHAR2
,p_association_type_code           IN VARCHAR2
,p_association_type_name           IN VARCHAR2
,p_call_back_pkg                   IN VARCHAR2
,p_description                     IN VARCHAR2
,p_search_page                     IN VARCHAR2
,p_owner                           IN VARCHAR2
,p_last_update_date		IN VARCHAR2
) IS
BEGIN
	IF ( p_UPLOAD_MODE = 'NLS') THEN
		IBC_ASSOCIATION_TYPES_PKG.TRANSLATE_ROW (
			p_upload_mode => p_upload_mode,
			p_association_type_code	=> p_association_type_code,
			p_association_type_name	=> p_association_type_name,
			p_description	=>	p_description,
			p_owner	 => p_owner,
			p_last_update_date => p_last_update_date);
	ELSE
		IBC_ASSOCIATION_TYPES_PKG.LOAD_ROW(
			p_upload_mode	=> p_upload_mode,
			p_association_type_code  => p_association_type_code,
			p_association_type_name => p_association_type_name,
			p_call_back_pkg => p_call_back_pkg,
			p_description => p_description,
			p_search_page => p_search_page,
			p_owner => p_owner,
			p_last_update_date => p_last_update_date );
	END IF;
END;

PROCEDURE LOAD_ROW (
  p_UPLOAD_MODE IN VARCHAR2,
  p_ASSOCIATION_TYPE_CODE IN VARCHAR2,
  p_ASSOCIATION_TYPE_NAME IN VARCHAR2,
  p_CALL_BACK_PKG   IN VARCHAR2,
  p_DESCRIPTION    IN VARCHAR2,
  p_SEARCH_PAGE    IN VARCHAR2,
  p_OWNER      IN VARCHAR2,
  p_LAST_UPDATE_DATE IN VARCHAR2) IS
BEGIN
  DECLARE
    l_user_id    NUMBER := 0;
    l_row_id     VARCHAR2(64);
    l_last_update_date DATE;

    db_user_id    NUMBER := 0;
    db_last_update_date DATE;

  BEGIN
	--get last updated by user id
	l_user_id := FND_LOAD_UTIL.OWNER_ID(p_OWNER);

	--translate data type VARCHAR2 to DATE for last_update_date
	l_last_update_date := nvl(TO_DATE(p_last_update_date, 'YYYY/MM/DD'),SYSDATE);

	-- get updatedby  and update_date values if existing in db
	SELECT LAST_UPDATED_BY, LAST_UPDATE_DATE INTO db_user_id, db_last_update_date
	FROM ibc_association_types_b
	WHERE association_type_code = p_association_type_code;

	IF (FND_LOAD_UTIL.UPLOAD_TEST(l_user_id, l_last_update_date,
		db_user_id, db_last_update_date, p_upload_mode )) THEN

		Ibc_Association_Types_Pkg.UPDATE_ROW (
			p_association_type_code        => NVL(p_association_type_code,FND_API.G_MISS_CHAR)
		       ,p_association_type_name        => NVL(p_association_type_name,FND_API.G_MISS_CHAR)
		       ,p_call_back_pkg                => NVL(p_call_back_pkg,FND_API.G_MISS_CHAR)
		       ,p_description                  => NVL(p_description,FND_API.G_MISS_CHAR)
		       ,p_search_page                  => NVL(p_search_page,FND_API.G_MISS_CHAR)
		       ,p_last_updated_by              => l_user_id
		       ,p_last_update_date             => l_last_update_date
		       ,p_last_update_login            => 0
		       ,p_object_version_number        => NULL
		       );
	END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
 DECLARE
 lx_rowid VARCHAR2(240);
 BEGIN
       Ibc_Association_Types_Pkg.INSERT_ROW (
       x_rowid     => lx_rowid,
          p_ASSOCIATION_TYPE_CODE => p_ASSOCIATION_TYPE_CODE,
          p_ASSOCIATION_TYPE_NAME => p_ASSOCIATION_TYPE_NAME,
          p_CALL_BACK_PKG   => p_CALL_BACK_PKG,
          p_DESCRIPTION    => p_DESCRIPTION,
          p_SEARCH_PAGE    => p_SEARCH_PAGE,
          p_CREATION_DATE       => l_last_update_date,
          p_CREATED_BY        => l_user_id,
          p_LAST_UPDATE_DATE      => l_last_update_date,
          p_LAST_UPDATED_BY      => l_user_id,
          p_LAST_UPDATE_LOGIN      => 0,
    p_OBJECT_VERSION_NUMBER   => 1);
  END;

   END;
END LOAD_ROW;

PROCEDURE TRANSLATE_ROW (
  p_UPLOAD_MODE IN VARCHAR2,
  p_ASSOCIATION_TYPE_CODE IN VARCHAR2,
  p_ASSOCIATION_TYPE_NAME IN VARCHAR2,
  p_DESCRIPTION    IN VARCHAR2,
  p_OWNER      IN  VARCHAR2,
  p_LAST_UPDATE_DATE IN VARCHAR2) IS

    l_user_id    NUMBER := 0;
    l_row_id     VARCHAR2(64);
    l_last_update_date DATE;

    db_user_id    NUMBER := 0;
    db_last_update_date DATE;


BEGIN
	--get last updated by user id
	l_user_id := FND_LOAD_UTIL.OWNER_ID(p_OWNER);

	--translate data type VARCHAR2 to DATE for last_update_date
	l_last_update_date := nvl(TO_DATE(p_last_update_date, 'YYYY/MM/DD'),SYSDATE);

	-- get updatedby  and update_date values if existing in db
	SELECT LAST_UPDATED_BY, LAST_UPDATE_DATE INTO db_user_id, db_last_update_date
	FROM ibc_association_types_tl
	WHERE association_type_code = p_association_type_code
	AND USERENV('LANG') IN (LANGUAGE, source_lang);

	IF (FND_LOAD_UTIL.UPLOAD_TEST(l_user_id, l_last_update_date,
		db_user_id, db_last_update_date, p_upload_mode )) THEN

		  -- Only update rows which have not been altered by user
		  UPDATE ibc_association_types_tl t SET
		    association_type_name = p_association_type_name,
		    description     = p_description,
		    source_lang     = USERENV('LANG'),
		    last_update_date    = l_last_update_date,
		    last_updated_by    = l_user_id,
		    last_update_login    = 0
		  WHERE Association_type_code    = p_association_type_code
		  AND USERENV('LANG') IN (LANGUAGE, source_lang);

	END IF;
END TRANSLATE_ROW;


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ASSOCIATION_TYPE_CODE in VARCHAR2,
  X_CALL_BACK_PKG in VARCHAR2,
  X_SEARCH_PAGE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ASSOCIATION_TYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER
) IS
  cursor C is select ROWID from IBC_ASSOCIATION_TYPES_B
    where ASSOCIATION_TYPE_CODE = X_ASSOCIATION_TYPE_CODE
    ;
begin
  insert into IBC_ASSOCIATION_TYPES_B (
    ASSOCIATION_TYPE_CODE,
    CALL_BACK_PKG,
    SEARCH_PAGE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID
  ) values (
    X_ASSOCIATION_TYPE_CODE,
    X_CALL_BACK_PKG,
    X_SEARCH_PAGE,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_SECURITY_GROUP_ID
  );

  insert into IBC_ASSOCIATION_TYPES_TL (
    ASSOCIATION_TYPE_CODE,
    ASSOCIATION_TYPE_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
    SECURITY_GROUP_ID
  ) select
    X_ASSOCIATION_TYPE_CODE,
    X_ASSOCIATION_TYPE_NAME,
    X_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    X_SECURITY_GROUP_ID
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from IBC_ASSOCIATION_TYPES_TL T
    where T.ASSOCIATION_TYPE_CODE = X_ASSOCIATION_TYPE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_ASSOCIATION_TYPE_CODE in VARCHAR2,
  X_CALL_BACK_PKG in VARCHAR2,
  X_SEARCH_PAGE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ASSOCIATION_TYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER
) is
  cursor c is select
      CALL_BACK_PKG,
      SEARCH_PAGE,
      OBJECT_VERSION_NUMBER
    from IBC_ASSOCIATION_TYPES_B
    where ASSOCIATION_TYPE_CODE = X_ASSOCIATION_TYPE_CODE
    for update of ASSOCIATION_TYPE_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      ASSOCIATION_TYPE_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IBC_ASSOCIATION_TYPES_TL
    where ASSOCIATION_TYPE_CODE = X_ASSOCIATION_TYPE_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ASSOCIATION_TYPE_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.CALL_BACK_PKG = X_CALL_BACK_PKG)
           OR ((recinfo.CALL_BACK_PKG is null) AND (X_CALL_BACK_PKG is null)))
      AND ((recinfo.SEARCH_PAGE = X_SEARCH_PAGE)
           OR ((recinfo.SEARCH_PAGE is null) AND (X_SEARCH_PAGE is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.ASSOCIATION_TYPE_NAME = X_ASSOCIATION_TYPE_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ASSOCIATION_TYPE_CODE in VARCHAR2,
  X_CALL_BACK_PKG in VARCHAR2,
  X_SEARCH_PAGE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ASSOCIATION_TYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER
) is
begin
  update IBC_ASSOCIATION_TYPES_B set
    CALL_BACK_PKG = X_CALL_BACK_PKG,
    SEARCH_PAGE = X_SEARCH_PAGE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID
  where ASSOCIATION_TYPE_CODE = X_ASSOCIATION_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IBC_ASSOCIATION_TYPES_TL set
    ASSOCIATION_TYPE_NAME = X_ASSOCIATION_TYPE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG'),
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID
  where ASSOCIATION_TYPE_CODE = X_ASSOCIATION_TYPE_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ASSOCIATION_TYPE_CODE in VARCHAR2
) is
begin
  delete from IBC_ASSOCIATION_TYPES_TL
  where ASSOCIATION_TYPE_CODE = X_ASSOCIATION_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IBC_ASSOCIATION_TYPES_B
  where ASSOCIATION_TYPE_CODE = X_ASSOCIATION_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;



END Ibc_Association_Types_Pkg;

/
