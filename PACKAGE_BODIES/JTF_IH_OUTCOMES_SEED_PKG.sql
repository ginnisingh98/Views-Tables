--------------------------------------------------------
--  DDL for Package Body JTF_IH_OUTCOMES_SEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_IH_OUTCOMES_SEED_PKG" as
/* $Header: JTFIHOSB.pls 120.4 2006/04/18 13:01:20 rdday ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_OUTCOME_ID in NUMBER,
  X_GENERATE_PUBLIC_CALLBACK in VARCHAR2,
  X_GENERATE_PRIVATE_CALLBACK in VARCHAR2,
  X_SCORE in NUMBER,
  X_POSITIVE_OUTCOME_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_RESULT_REQUIRED in VARCHAR2,
  X_VERSATILITY_CODE in NUMBER,
  X_OUTCOME_CODE in VARCHAR2,
  X_MEDIA_TYPE in VARCHAR2,
  X_SHORT_DESCRIPTION in VARCHAR2,
  X_LONG_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ACTIVE in VARCHAR2
) is
  cursor C is select ROWID from JTF_IH_OUTCOMES_B
    where OUTCOME_ID = X_OUTCOME_ID
    ;
    --Added for performance issue due to literals -  27-Jul-2004
    L_ACTIVE_FLAG VARCHAR2(1);
    L_INSTALLED_FLAG1 VARCHAR2(1);
    L_INSTALLED_FLAG2 VARCHAR2(1);
    L_LANG VARCHAR2(25);
begin
    --Added for performance issue due to literals -  27-Jul-2004
    L_ACTIVE_FLAG := 'Y';
    L_INSTALLED_FLAG1 := 'I';
    L_INSTALLED_FLAG2 := 'B';
    L_LANG := userenv('LANG');

  insert into JTF_IH_OUTCOMES_B (
    GENERATE_PUBLIC_CALLBACK,
    GENERATE_PRIVATE_CALLBACK,
    SCORE,
    POSITIVE_OUTCOME_FLAG,
    OUTCOME_ID,
    OBJECT_VERSION_NUMBER,
    RESULT_REQUIRED,
    VERSATILITY_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ACTIVE
  ) values (
    X_GENERATE_PUBLIC_CALLBACK,
    X_GENERATE_PRIVATE_CALLBACK,
    X_SCORE,
    X_POSITIVE_OUTCOME_FLAG,
    X_OUTCOME_ID,
    X_OBJECT_VERSION_NUMBER,
    X_RESULT_REQUIRED,
    X_VERSATILITY_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    --NVL(X_ACTIVE,'Y')
    --Added for performance issue due to literals -  27-Jul-2004
    NVL(X_ACTIVE,L_ACTIVE_FLAG)
  );

  insert into JTF_IH_OUTCOMES_TL (
    OUTCOME_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LONG_DESCRIPTION,
    SHORT_DESCRIPTION,
    OUTCOME_CODE,
    MEDIA_TYPE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_OUTCOME_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_LONG_DESCRIPTION,
    X_SHORT_DESCRIPTION,
    X_OUTCOME_CODE,
    X_MEDIA_TYPE,
    L.LANGUAGE_CODE,
    --Added for performance issue due to literals -  27-Jul-2004
    --userenv('LANG')
    L_LANG
  from FND_LANGUAGES L
  --Added for performance issue due to literals -  27-Jul-2004
  --where L.INSTALLED_FLAG in ('I', 'B')
  where L.INSTALLED_FLAG in ( L_INSTALLED_FLAG1,  L_INSTALLED_FLAG2)
  and not exists
    (select NULL
    from JTF_IH_OUTCOMES_TL T
    where T.OUTCOME_ID = X_OUTCOME_ID
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
  X_OUTCOME_ID in NUMBER,
  X_GENERATE_PUBLIC_CALLBACK in VARCHAR2,
  X_GENERATE_PRIVATE_CALLBACK in VARCHAR2,
  X_SCORE in NUMBER,
  X_POSITIVE_OUTCOME_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_RESULT_REQUIRED in VARCHAR2,
  X_VERSATILITY_CODE in NUMBER,
  X_OUTCOME_CODE in VARCHAR2,
  X_MEDIA_TYPE in VARCHAR2,
  X_SHORT_DESCRIPTION in VARCHAR2,
  X_LONG_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      GENERATE_PUBLIC_CALLBACK,
      GENERATE_PRIVATE_CALLBACK,
      SCORE,
      POSITIVE_OUTCOME_FLAG,
      OBJECT_VERSION_NUMBER,
      RESULT_REQUIRED,
      VERSATILITY_CODE
    from JTF_IH_OUTCOMES_B
    where OUTCOME_ID = X_OUTCOME_ID
    for update of OUTCOME_ID nowait;
  recinfo c%rowtype;

  --Added for performance issue due to literals -  28-Jul-2004
  L_LANG VARCHAR2(25);
  L_YES VARCHAR2(1);
  L_NO VARCHAR2(1);

  cursor c1 is select
      OUTCOME_CODE,
      MEDIA_TYPE,
      SHORT_DESCRIPTION,
      LONG_DESCRIPTION,
      --Added for performance issue due to literals -  28-Jul-2004
      --decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
      decode(LANGUAGE, L_LANG, L_YES, L_NO) BASELANG
    from JTF_IH_OUTCOMES_TL
    where OUTCOME_ID = X_OUTCOME_ID
    --and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    --Added for performance issue due to literals -  28-Jul-2004
    and L_LANG in (LANGUAGE, SOURCE_LANG)
    for update of OUTCOME_ID nowait;
begin
  --Added for performance issue due to literals -  28-Jul-2004
  L_LANG := userenv('LANG');
  L_YES := 'Y';
  L_NO := 'N';

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.GENERATE_PUBLIC_CALLBACK = X_GENERATE_PUBLIC_CALLBACK)
           OR ((recinfo.GENERATE_PUBLIC_CALLBACK is null) AND (X_GENERATE_PUBLIC_CALLBACK is null)))
      AND ((recinfo.GENERATE_PRIVATE_CALLBACK = X_GENERATE_PRIVATE_CALLBACK)
           OR ((recinfo.GENERATE_PRIVATE_CALLBACK is null) AND (X_GENERATE_PRIVATE_CALLBACK is null)))
      AND ((recinfo.SCORE = X_SCORE)
           OR ((recinfo.SCORE is null) AND (X_SCORE is null)))
      AND (recinfo.POSITIVE_OUTCOME_FLAG = X_POSITIVE_OUTCOME_FLAG)
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.RESULT_REQUIRED = X_RESULT_REQUIRED)
           OR ((recinfo.RESULT_REQUIRED is null) AND (X_RESULT_REQUIRED is null)))
      AND ((recinfo.VERSATILITY_CODE = X_VERSATILITY_CODE)
           OR ((recinfo.VERSATILITY_CODE is null) AND (X_VERSATILITY_CODE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.OUTCOME_CODE = X_OUTCOME_CODE)
          AND ((tlinfo.MEDIA_TYPE = X_MEDIA_TYPE)
               OR ((tlinfo.MEDIA_TYPE is null) AND (X_MEDIA_TYPE is null)))
          AND (tlinfo.SHORT_DESCRIPTION = X_SHORT_DESCRIPTION)
          AND ((tlinfo.LONG_DESCRIPTION = X_LONG_DESCRIPTION)
               OR ((tlinfo.LONG_DESCRIPTION is null) AND (X_LONG_DESCRIPTION is null)))
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
  X_OUTCOME_ID in NUMBER,
  X_GENERATE_PUBLIC_CALLBACK in VARCHAR2,
  X_GENERATE_PRIVATE_CALLBACK in VARCHAR2,
  X_SCORE in NUMBER,
  X_POSITIVE_OUTCOME_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_RESULT_REQUIRED in VARCHAR2,
  X_VERSATILITY_CODE in NUMBER,
  X_OUTCOME_CODE in VARCHAR2,
  X_MEDIA_TYPE in VARCHAR2,
  X_SHORT_DESCRIPTION in VARCHAR2,
  X_LONG_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ACTIVE in VARCHAR2
) is
--Added for performance issue due to literals -  27-Jul-2004
L_ACTIVE_FLAG VARCHAR2(1);
L_LANG VARCHAR2(25);

begin
  --Added for performance issue due to literals -  27-Jul-2004
  L_ACTIVE_FLAG := 'Y';
  L_LANG := userenv('LANG');

  update JTF_IH_OUTCOMES_B set
    GENERATE_PUBLIC_CALLBACK = X_GENERATE_PUBLIC_CALLBACK,
    GENERATE_PRIVATE_CALLBACK = X_GENERATE_PRIVATE_CALLBACK,
    SCORE = X_SCORE,
    POSITIVE_OUTCOME_FLAG = X_POSITIVE_OUTCOME_FLAG,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    RESULT_REQUIRED = X_RESULT_REQUIRED,
    VERSATILITY_CODE = X_VERSATILITY_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    --Added for performance issue due to literals -  27-Jul-2004
    --ACTIVE = NVL(X_ACTIVE,'Y')
    ACTIVE = NVL(X_ACTIVE,L_ACTIVE_FLAG)
  where OUTCOME_ID = X_OUTCOME_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_IH_OUTCOMES_TL set
    OUTCOME_CODE = X_OUTCOME_CODE,
    MEDIA_TYPE = X_MEDIA_TYPE,
    SHORT_DESCRIPTION = X_SHORT_DESCRIPTION,
    LONG_DESCRIPTION = X_LONG_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    --Added for performance issue due to literals -  27-Jul-2004
    --SOURCE_LANG = userenv('LANG')
    SOURCE_LANG = L_LANG
  where OUTCOME_ID = X_OUTCOME_ID
  --Added for performance issue due to literals -  27-Jul-2004
  --and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
  and L_LANG in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_OUTCOME_ID in NUMBER
) is
begin
  delete from JTF_IH_OUTCOMES_TL
  where OUTCOME_ID = X_OUTCOME_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_IH_OUTCOMES_B
  where OUTCOME_ID = X_OUTCOME_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
    --Added for performance issue due to literals -  28-Jul-2004
    L_INSTALLED_FLAG1 VARCHAR2(1);
    L_INSTALLED_FLAG2 VARCHAR2(1);
    L_LANG VARCHAR2(25);
begin
    --Added for performance issue due to literals -  28-Jul-2004
    L_INSTALLED_FLAG1 := 'I';
    L_INSTALLED_FLAG2 := 'B';
    L_LANG := userenv('LANG');

  delete from JTF_IH_OUTCOMES_TL T
  where not exists
    (select NULL
    from JTF_IH_OUTCOMES_B B
    where B.OUTCOME_ID = T.OUTCOME_ID
    );

  update JTF_IH_OUTCOMES_TL T set (
      OUTCOME_CODE,
      MEDIA_TYPE,
      SHORT_DESCRIPTION,
      LONG_DESCRIPTION
    ) = (select
      B.OUTCOME_CODE,
      B.MEDIA_TYPE,
      B.SHORT_DESCRIPTION,
      B.LONG_DESCRIPTION
    from JTF_IH_OUTCOMES_TL B
    where B.OUTCOME_ID = T.OUTCOME_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.OUTCOME_ID,
      T.LANGUAGE
  ) in (select
      SUBT.OUTCOME_ID,
      SUBT.LANGUAGE
    from JTF_IH_OUTCOMES_TL SUBB, JTF_IH_OUTCOMES_TL SUBT
    where SUBB.OUTCOME_ID = SUBT.OUTCOME_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.OUTCOME_CODE <> SUBT.OUTCOME_CODE
      or SUBB.MEDIA_TYPE <> SUBT.MEDIA_TYPE
      or (SUBB.MEDIA_TYPE is null and SUBT.MEDIA_TYPE is not null)
      or (SUBB.MEDIA_TYPE is not null and SUBT.MEDIA_TYPE is null)
      or SUBB.SHORT_DESCRIPTION <> SUBT.SHORT_DESCRIPTION
      or SUBB.LONG_DESCRIPTION <> SUBT.LONG_DESCRIPTION
      or (SUBB.LONG_DESCRIPTION is null and SUBT.LONG_DESCRIPTION is not null)
      or (SUBB.LONG_DESCRIPTION is not null and SUBT.LONG_DESCRIPTION is null)
  ));

  insert into JTF_IH_OUTCOMES_TL (
    OUTCOME_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LONG_DESCRIPTION,
    SHORT_DESCRIPTION,
    OUTCOME_CODE,
    MEDIA_TYPE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.OUTCOME_ID,
    B.OBJECT_VERSION_NUMBER,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.LONG_DESCRIPTION,
    B.SHORT_DESCRIPTION,
    B.OUTCOME_CODE,
    B.MEDIA_TYPE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_IH_OUTCOMES_TL B, FND_LANGUAGES L
  where  L.INSTALLED_FLAG in (L_INSTALLED_FLAG1, L_INSTALLED_FLAG2)
  and B.LANGUAGE = L_LANG
  and not exists
    (select NULL
    from JTF_IH_OUTCOMES_TL T
    where T.OUTCOME_ID = B.OUTCOME_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_OUTCOME_ID in NUMBER,
  X_GENERATE_PUBLIC_CALLBACK in VARCHAR2,
  X_GENERATE_PRIVATE_CALLBACK in VARCHAR2,
  X_SCORE in NUMBER,
  X_POSITIVE_OUTCOME_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_RESULT_REQUIRED in VARCHAR2,
  X_VERSATILITY_CODE in NUMBER,
  X_OUTCOME_CODE in VARCHAR2,
  X_MEDIA_TYPE in VARCHAR2,
  X_SHORT_DESCRIPTION in VARCHAR2,
  X_LONG_DESCRIPTION in VARCHAR2,
  X_OWNER IN VARCHAR2,
  X_ACTIVE in VARCHAR2
) IS
begin
declare
	user_id			NUMBER := 0;
	row_id			VARCHAR2(64);
	l_api_version		NUMBER := 1.0;
	l_return_status		VARCHAR2(1);
	l_msg_count		NUMBER;
	l_msg_data		VARCHAR2(100);
	l_init_msg_list		VARCHAR2(1) := 'F';
	l_commit		VARCHAR2(1) := 'F';
	l_validation_level 	NUMBER := 100;
  	l_outcome_id 		NUMBER;
  	l_generate_public_callback VARCHAR2(1);
  	l_generate_private_callback VARCHAR2(1);
  	l_score			NUMBER;
  	l_positive_outcome_flag VARCHAR2(1);
  	l_object_version_number NUMBER;
  	l_result_required	VARCHAR2(1);
  	l_versatility_code	NUMBER;
  	l_outcome_code		VARCHAR2(80);
  	l_media_type 		VARCHAR2(240);
  	l_short_description 	VARCHAR2(240);
  	l_long_description 	VARCHAR2(1000);
	l_last_update_date	DATE;
	l_last_updated_by	NUMBER;
	l_last_update_login	NUMBER;
	l_creation_date		DATE;
	l_created_by		NUMBER;
	l_active		VARCHAR2(1);

begin
	--if (x_owner = 'SEED') then
	--	user_id := 1;
	--end if;
        user_id := fnd_load_util.owner_id(x_owner);
  	l_outcome_id := X_OUTCOME_ID;
  	l_generate_public_callback := X_GENERATE_PUBLIC_CALLBACK;
  	l_generate_private_callback := X_GENERATE_PRIVATE_CALLBACK;
  	l_score := X_SCORE;
  	l_positive_outcome_flag := X_POSITIVE_OUTCOME_FLAG;
  	l_object_version_number := 1;
  	l_result_required := X_RESULT_REQUIRED;
  	l_versatility_code := X_VERSATILITY_CODE;
  	l_outcome_code := X_OUTCOME_CODE;
  	l_media_type := X_MEDIA_TYPE;
  	l_short_description := X_SHORT_DESCRIPTION;
  	l_long_description := X_LONG_DESCRIPTION;
	l_last_update_date := sysdate;
	l_last_updated_by := user_id;
	l_last_update_login := 0;
	l_active := NVL(X_ACTIVE,'Y');

	UPDATE_ROW(
  			X_OUTCOME_ID => l_outcome_id,
  			X_GENERATE_PUBLIC_CALLBACK => l_generate_public_callback,
  			X_GENERATE_PRIVATE_CALLBACK => l_generate_private_callback,
  			X_SCORE => l_score,
  			X_POSITIVE_OUTCOME_FLAG => l_positive_outcome_flag,
  			X_OBJECT_VERSION_NUMBER => l_object_version_number,
  			X_RESULT_REQUIRED => l_result_required,
  			X_VERSATILITY_CODE => l_versatility_code,
  			X_OUTCOME_CODE => l_outcome_code,
  			X_MEDIA_TYPE => l_media_type,
  			X_SHORT_DESCRIPTION => l_short_description,
  			X_LONG_DESCRIPTION => l_long_description,
  			X_LAST_UPDATE_DATE => l_last_update_date,
  			X_LAST_UPDATED_BY => l_last_updated_by,
  			X_LAST_UPDATE_LOGIN => l_last_update_login,
			X_ACTIVE => l_active);
	EXCEPTION
		when no_data_found then
			l_creation_date := sysdate;
			l_created_by := user_id;
			INSERT_ROW(
			row_id,
  			X_OUTCOME_ID => l_outcome_id,
  			X_GENERATE_PUBLIC_CALLBACK => l_generate_public_callback,
  			X_GENERATE_PRIVATE_CALLBACK => l_generate_private_callback,
  			X_SCORE => l_score,
  			X_POSITIVE_OUTCOME_FLAG => l_positive_outcome_flag,
  			X_OBJECT_VERSION_NUMBER => l_object_version_number,
  			X_RESULT_REQUIRED => l_result_required,
  			X_VERSATILITY_CODE => l_versatility_code,
  			X_OUTCOME_CODE => l_outcome_code,
  			X_MEDIA_TYPE => l_media_type,
  			X_SHORT_DESCRIPTION => l_short_description,
  			X_LONG_DESCRIPTION => l_long_description,
			X_CREATION_DATE => l_creation_date,
			X_CREATED_BY => l_created_by,
  			X_LAST_UPDATE_DATE => l_last_update_date,
  			X_LAST_UPDATED_BY => l_last_updated_by,
  			X_LAST_UPDATE_LOGIN => l_last_update_login,
			X_ACTIVE => l_active);
	end;
end LOAD_ROW;
procedure TRANSLATE_ROW (
  X_OUTCOME_ID in NUMBER,
  X_OUTCOME_CODE in VARCHAR2,
  X_MEDIA_TYPE in VARCHAR2,
  X_SHORT_DESCRIPTION in VARCHAR2,
  X_LONG_DESCRIPTION in VARCHAR2,
  X_OWNER IN VARCHAR2) is

  --Added for performance issue due to literals -  28-Jul-2004
  L_LANG VARCHAR2(25);
  L_SEED VARCHAR2(25);
  L_UPDATEDBY1 NUMBER;
  L_UPDATEDBY0 NUMBER;
begin
        --Added for performance issue due to literals -  28-Jul-2004
	L_LANG := userenv('LANG');
	L_SEED := 'SEED';
	L_UPDATEDBY1 := 1;
	L_UPDATEDBY0 := 0;

	UPDATE jtf_ih_outcomes_tl SET
		outcome_id = X_OUTCOME_ID,
		outcome_code = X_OUTCOME_CODE,
		media_type = X_MEDIA_TYPE,
		short_description = X_SHORT_DESCRIPTION,
		long_description = X_LONG_DESCRIPTION,
		last_update_date = sysdate,
		--Added for performance issue due to literals -  28-Jul-2004
		--last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
		--last_updated_by = decode(X_OWNER, L_SEED, L_UPDATEDBY1, L_UPDATEDBY0),
                last_updated_by = fnd_load_util.owner_id(x_owner),
		last_update_login = 0,
		--Added for performance issue due to literals -  28-Jul-2004
		--source_lang = userenv('LANG')
		source_lang = L_LANG
	--WHERE userenv('LANG') in (LANGUAGE, SOURCE_LANG) AND
	WHERE L_LANG in (LANGUAGE, SOURCE_LANG) AND
		outcome_id = X_OUTCOME_ID;
end TRANSLATE_ROW;

procedure  LOAD_SEED_ROW (
  X_OUTCOME_ID in NUMBER,
  X_GENERATE_PUBLIC_CALLBACK in VARCHAR2,
  X_GENERATE_PRIVATE_CALLBACK in VARCHAR2,
  X_SCORE in NUMBER,
  X_POSITIVE_OUTCOME_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_RESULT_REQUIRED in VARCHAR2,
  X_VERSATILITY_CODE in NUMBER,
  X_OUTCOME_CODE in VARCHAR2,
  X_MEDIA_TYPE in VARCHAR2,
  X_SHORT_DESCRIPTION in VARCHAR2,
  X_LONG_DESCRIPTION in VARCHAR2,
  X_OWNER IN VARCHAR2,
  X_ACTIVE in VARCHAR2,
  X_UPLOAD_MODE in VARCHAR2
) is
begin
	if (X_UPLOAD_MODE = 'NLS') then
                JTF_IH_OUTCOMES_SEED_PKG.TRANSLATE_ROW (
                        X_OUTCOME_ID,
                        X_OUTCOME_CODE,
                        X_MEDIA_TYPE,
                        X_SHORT_DESCRIPTION,
                        X_LONG_DESCRIPTION,
                        X_OWNER);

        else
                JTF_IH_OUTCOMES_SEED_PKG.LOAD_ROW (
                        X_OUTCOME_ID,
                        X_GENERATE_PUBLIC_CALLBACK,
                        X_GENERATE_PRIVATE_CALLBACK,
                        X_SCORE,
                        X_POSITIVE_OUTCOME_FLAG,
                        X_OBJECT_VERSION_NUMBER,
                        X_RESULT_REQUIRED,
                        X_VERSATILITY_CODE,
                        X_OUTCOME_CODE,
                        X_MEDIA_TYPE,
                        X_SHORT_DESCRIPTION,
                        X_LONG_DESCRIPTION,
                        X_OWNER,
                        X_ACTIVE);
        end if;
end LOAD_SEED_ROW;

end JTF_IH_OUTCOMES_SEED_PKG;

/