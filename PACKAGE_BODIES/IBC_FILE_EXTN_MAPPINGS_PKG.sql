--------------------------------------------------------
--  DDL for Package Body IBC_FILE_EXTN_MAPPINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_FILE_EXTN_MAPPINGS_PKG" as
/* $Header: ibctfexb.pls 120.5 2006/06/22 09:34:02 sharma ship $ */
procedure INSERT_ROW (
  X_ROWID in out  NOCOPY VARCHAR2,
  X_MAPPING_ID in  NUMBER,
  X_CONTENT_TYPE_CODE in  VARCHAR2,
  X_EXTENSION in  VARCHAR2,
  X_DESCRIPTION in  VARCHAR2,
  X_CREATION_DATE in   DATE,
  X_CREATED_BY in   NUMBER,
  X_LAST_UPDATE_DATE in   DATE,
  X_LAST_UPDATED_BY in   NUMBER,
  X_LAST_UPDATE_LOGIN in   NUMBER
) is
  cursor C is select ROWID from IBC_FILE_EXTN_MAPPINGS_B
    where MAPPING_ID = X_MAPPING_ID
    ;
begin
  insert into IBC_FILE_EXTN_MAPPINGS_B (
    MAPPING_ID,
    CONTENT_TYPE_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_MAPPING_ID,
    X_CONTENT_TYPE_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into IBC_FILE_EXTN_MAPPINGS_TL (
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    MAPPING_ID,
    EXTENSION,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATED_BY,
    X_MAPPING_ID,
    X_EXTENSION,
    X_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from IBC_FILE_EXTN_MAPPINGS_TL T
    where T.MAPPING_ID = X_MAPPING_ID
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
  X_MAPPING_ID in   NUMBER,
  X_CONTENT_TYPE_CODE in   VARCHAR2,
  X_EXTENSION in   VARCHAR2,
  X_DESCRIPTION in   VARCHAR2
) is
  cursor c is select
      CONTENT_TYPE_CODE
    from IBC_FILE_EXTN_MAPPINGS_B
    where MAPPING_ID = X_MAPPING_ID
    for update of MAPPING_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      EXTENSION,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IBC_FILE_EXTN_MAPPINGS_TL
    where MAPPING_ID = X_MAPPING_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of MAPPING_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.CONTENT_TYPE_CODE = X_CONTENT_TYPE_CODE)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.EXTENSION = X_EXTENSION)
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
  X_MAPPING_ID in   NUMBER,
  X_CONTENT_TYPE_CODE in   VARCHAR2,
  X_EXTENSION in   VARCHAR2,
  X_DESCRIPTION in   VARCHAR2,
  X_LAST_UPDATE_DATE in   DATE,
  X_LAST_UPDATED_BY in   NUMBER,
  X_LAST_UPDATE_LOGIN in   NUMBER
) is
begin
  update IBC_FILE_EXTN_MAPPINGS_B set
    CONTENT_TYPE_CODE = X_CONTENT_TYPE_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where MAPPING_ID = X_MAPPING_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IBC_FILE_EXTN_MAPPINGS_TL set
    EXTENSION = X_EXTENSION,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where MAPPING_ID = X_MAPPING_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_MAPPING_ID in   NUMBER
) is
begin
  delete from IBC_FILE_EXTN_MAPPINGS_TL
  where MAPPING_ID = X_MAPPING_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IBC_FILE_EXTN_MAPPINGS_B
  where MAPPING_ID = X_MAPPING_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IBC_FILE_EXTN_MAPPINGS_TL T
  where not exists
    (select NULL
    from IBC_FILE_EXTN_MAPPINGS_B B
    where B.MAPPING_ID = T.MAPPING_ID
    );

  update IBC_FILE_EXTN_MAPPINGS_TL T set (
      EXTENSION,
      DESCRIPTION
    ) = (select
      B.EXTENSION,
      B.DESCRIPTION
    from IBC_FILE_EXTN_MAPPINGS_TL B
    where B.MAPPING_ID = T.MAPPING_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.MAPPING_ID,
      T.LANGUAGE
  ) in (select
      SUBT.MAPPING_ID,
      SUBT.LANGUAGE
    from IBC_FILE_EXTN_MAPPINGS_TL SUBB, IBC_FILE_EXTN_MAPPINGS_TL SUBT
    where SUBB.MAPPING_ID = SUBT.MAPPING_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.EXTENSION <> SUBT.EXTENSION
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into IBC_FILE_EXTN_MAPPINGS_TL (
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    MAPPING_ID,
    EXTENSION,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATED_BY,
    B.MAPPING_ID,
    B.EXTENSION,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IBC_FILE_EXTN_MAPPINGS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IBC_FILE_EXTN_MAPPINGS_TL T
    where T.MAPPING_ID = B.MAPPING_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE LOAD_SEED_ROW(
	p_UPLOAD_MODE IN VARCHAR2,
	p_mapping_id   IN VARCHAR2,
	p_content_type_code  IN VARCHAR2,
	p_extension    IN VARCHAR2,
	p_description  IN VARCHAR2,
	p_OWNER	 IN VARCHAR2,
	p_LAST_UPDATE_DATE IN VARCHAR2 ) IS
BEGIN
	IF (p_UPLOAD_MODE = 'NLS') THEN
		IBC_FILE_EXTN_MAPPINGS_PKG.TRANSLATE_ROW (
			p_UPLOAD_MODE => p_UPLOAD_MODE,
			p_mapping_id	=> p_mapping_id,
			p_extension => p_extension,
			p_description => p_description,
			p_OWNER	=>p_OWNER,
			p_LAST_UPDATE_DATE => p_LAST_UPDATE_DATE );
	ELSE
		IBC_FILE_EXTN_MAPPINGS_PKG.LOAD_ROW (
			p_UPLOAD_MODE => p_UPLOAD_MODE,
			p_mapping_id	=> p_mapping_id,
			p_content_type_code	=> p_content_type_code,
			p_extension => p_extension,
			p_description => p_description,
			p_OWNER	=>p_OWNER,
			p_LAST_UPDATE_DATE => p_LAST_UPDATE_DATE );
	END IF;
END LOAD_SEED_ROW;

PROCEDURE LOAD_ROW(
	p_UPLOAD_MODE IN VARCHAR2,
	p_mapping_id   IN VARCHAR2,
	p_content_type_code  IN VARCHAR2,
	p_extension    IN VARCHAR2,
	p_description  IN VARCHAR2,
	p_OWNER	 IN VARCHAR2,
	p_LAST_UPDATE_DATE IN VARCHAR2 ) IS

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
	FROM IBC_FILE_EXTN_MAPPINGS_B
	WHERE  MAPPING_ID = p_mapping_id;

	IF (FND_LOAD_UTIL.UPLOAD_TEST(l_user_id, l_last_update_date,
		db_user_id, db_last_update_date, p_upload_mode )) THEN

		IBC_FILE_EXTN_MAPPINGS_PKG.Update_row (
			x_mapping_id          =>TO_NUMBER(p_mapping_id)
		       ,x_content_type_code   =>p_content_type_code
		       ,x_extension           =>NVL(p_extension,Fnd_Api.G_MISS_CHAR)
		       ,x_description         =>NVL(p_description,Fnd_Api.G_MISS_CHAR)
		       ,x_last_update_date    =>l_last_update_date
		       ,x_last_updated_by     =>l_user_id
		       ,x_last_update_login   =>0);
	END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN

	IBC_FILE_EXTN_MAPPINGS_Pkg.insert_row (
		x_rowid  =>l_row_id,
		x_mapping_id      =>TO_NUMBER(p_mapping_id)
		,x_content_type_code   =>p_content_type_code
		,x_extension      =>NVL(p_extension,Fnd_Api.G_MISS_CHAR)
		,x_description    =>NVL(p_description,Fnd_Api.G_MISS_CHAR),
		x_creation_date =>l_last_update_date,
		x_created_by 	=>l_user_id,
		x_last_update_date    =>l_last_update_date,
		x_last_updated_by     =>l_user_id,
		x_last_update_login   =>0);

END LOAD_ROW;


PROCEDURE TRANSLATE_ROW(
	p_UPLOAD_MODE IN VARCHAR2,
	p_mapping_id   IN VARCHAR2,
	p_extension    IN VARCHAR2,
	p_description  IN VARCHAR2,
	p_OWNER	 IN VARCHAR2,
	p_LAST_UPDATE_DATE IN VARCHAR2 ) IS

    l_user_id    NUMBER := 0;
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
	FROM IBC_FILE_EXTN_MAPPINGS_TL
	WHERE  MAPPING_ID = p_mapping_id
	AND  USERENV('LANG') IN (LANGUAGE, source_lang);

	IF (FND_LOAD_UTIL.UPLOAD_TEST(l_user_id, l_last_update_date,
		db_user_id, db_last_update_date, p_upload_mode )) THEN
		  -- Only update rows which have not been altered by user
		  UPDATE IBC_FILE_EXTN_MAPPINGS_TL
		  SET description = p_description,
		      Extension =  p_Extension,
		      source_lang = USERENV('LANG'),
		      last_update_date = l_last_update_date,
		      last_updated_by = l_user_id,
		      last_update_login = 0
		  WHERE mapping_id = p_mapping_id
		  AND USERENV('LANG') IN (LANGUAGE, source_lang);
	END IF;
END TRANSLATE_ROW;

END IBC_FILE_EXTN_MAPPINGS_PKG;

/
