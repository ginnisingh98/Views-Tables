--------------------------------------------------------
--  DDL for Package Body JTF_IH_ACTIONS_SEED_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_IH_ACTIONS_SEED_PVT" as
/* $Header: JTFIHACB.pls 115.1 2000/02/15 12:25:07 pkm ship     $ */
procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_ACTION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ACTION in VARCHAR2,
  X_SHORT_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_IH_ACTIONS_B
    where ACTION_ID = X_ACTION_ID
    ;
begin
  insert into JTF_IH_ACTIONS_B (
    ACTION_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ACTION_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_IH_ACTIONS_TL (
    ACTION_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    ACTION,
    SHORT_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_ACTION_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_ACTION,
    X_SHORT_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_IH_ACTIONS_TL T
    where T.ACTION_ID = X_ACTION_ID
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
  X_ACTION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ACTION in VARCHAR2,
  X_SHORT_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER
    from JTF_IH_ACTIONS_B
    where ACTION_ID = X_ACTION_ID
    for update of ACTION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      ACTION,
      SHORT_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_IH_ACTIONS_TL
    where ACTION_ID = X_ACTION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ACTION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.ACTION = X_ACTION)
               OR ((tlinfo.ACTION is null) AND (X_ACTION is null)))
          AND ((tlinfo.SHORT_DESCRIPTION = X_SHORT_DESCRIPTION)
               OR ((tlinfo.SHORT_DESCRIPTION is null) AND (X_SHORT_DESCRIPTION is null)))
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
  X_ACTION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ACTION in VARCHAR2,
  X_SHORT_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_IH_ACTIONS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ACTION_ID = X_ACTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_IH_ACTIONS_TL set
    ACTION = X_ACTION,
    SHORT_DESCRIPTION = X_SHORT_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ACTION_ID = X_ACTION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ACTION_ID in NUMBER
) is
begin
  delete from JTF_IH_ACTIONS_TL
  where ACTION_ID = X_ACTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_IH_ACTIONS_B
  where ACTION_ID = X_ACTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_IH_ACTIONS_TL T
  where not exists
    (select NULL
    from JTF_IH_ACTIONS_B B
    where B.ACTION_ID = T.ACTION_ID
    );

  update JTF_IH_ACTIONS_TL T set (
      ACTION,
      SHORT_DESCRIPTION
    ) = (select
      B.ACTION,
      B.SHORT_DESCRIPTION
    from JTF_IH_ACTIONS_TL B
    where B.ACTION_ID = T.ACTION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ACTION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ACTION_ID,
      SUBT.LANGUAGE
    from JTF_IH_ACTIONS_TL SUBB, JTF_IH_ACTIONS_TL SUBT
    where SUBB.ACTION_ID = SUBT.ACTION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.ACTION <> SUBT.ACTION
      or (SUBB.ACTION is null and SUBT.ACTION is not null)
      or (SUBB.ACTION is not null and SUBT.ACTION is null)
      or SUBB.SHORT_DESCRIPTION <> SUBT.SHORT_DESCRIPTION
      or (SUBB.SHORT_DESCRIPTION is null and SUBT.SHORT_DESCRIPTION is not null)
      or (SUBB.SHORT_DESCRIPTION is not null and SUBT.SHORT_DESCRIPTION is null)
  ));

  insert into JTF_IH_ACTIONS_TL (
    ACTION_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    ACTION,
    SHORT_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ACTION_ID,
    B.OBJECT_VERSION_NUMBER,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.ACTION,
    B.SHORT_DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_IH_ACTIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_IH_ACTIONS_TL T
    where T.ACTION_ID = B.ACTION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_ACTION_ID in NUMBER,
  X_ACTION in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SHORT_DESCRIPTION in VARCHAR2,
  X_OWNER IN VARCHAR2
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
  	l_action_id 		NUMBER;
  	l_object_version_number NUMBER;
  	l_action		VARCHAR2(80);
  	l_short_description 	VARCHAR2(240);
	l_last_update_date	DATE;
	l_last_updated_by	NUMBER;
	l_last_update_login	NUMBER;
	l_creation_date		DATE;
	l_created_by		NUMBER;

begin
	if (x_owner = 'SEED') then
		user_id := -1;
	end if;
  	l_action_id := X_ACTION_ID;
  	l_object_version_number := 1;
  	l_action := X_ACTION;
  	l_short_description := X_SHORT_DESCRIPTION;
	l_last_update_date := sysdate;
	l_last_updated_by := user_id;
	l_last_update_login := 0;

	UPDATE_ROW(
  			X_ACTION_ID => l_action_id,
			X_OBJECT_VERSION_NUMBER => l_object_version_number,
  			X_ACTION => l_action,
  			X_SHORT_DESCRIPTION => l_short_description,
  			X_LAST_UPDATE_DATE => l_last_update_date,
  			X_LAST_UPDATED_BY => l_last_updated_by,
  			X_LAST_UPDATE_LOGIN => l_last_update_login);
	EXCEPTION
		when no_data_found then
			l_creation_date := sysdate;
			l_created_by := user_id;
			INSERT_ROW(
			row_id,
  			X_ACTION_ID => l_action_id,
  			X_OBJECT_VERSION_NUMBER => l_object_version_number,
  			X_ACTION => l_action,
  			X_SHORT_DESCRIPTION => l_short_description,
			X_CREATION_DATE => l_creation_date,
			X_CREATED_BY => l_created_by,
  			X_LAST_UPDATE_DATE => l_last_update_date,
  			X_LAST_UPDATED_BY => l_last_updated_by,
  			X_LAST_UPDATE_LOGIN => l_last_update_login);
	end;
end LOAD_ROW;
procedure TRANSLATE_ROW (
  X_ACTION_ID in NUMBER,
  X_ACTION in VARCHAR2,
  X_SHORT_DESCRIPTION in VARCHAR2,
  X_OWNER IN VARCHAR2) is
begin
	UPDATE jtf_ih_actions_tl SET
		action_id = X_ACTION_ID,
		action = X_ACTION,
		short_description = X_SHORT_DESCRIPTION,
		last_update_date = sysdate,
		last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
		last_update_login = 0,
		source_lang = userenv('LANG')
	WHERE userenv('LANG') in (LANGUAGE, SOURCE_LANG) AND
		action_id = X_ACTION_ID;
end TRANSLATE_ROW;

end JTF_IH_ACTIONS_SEED_PVT;

/