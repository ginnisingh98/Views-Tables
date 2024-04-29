--------------------------------------------------------
--  DDL for Package Body IEU_UWQ_RES_CATS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQ_RES_CATS_PKG" as
/* $Header: IEURCATB.pls 120.2 2005/06/20 08:12:00 appldev ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_RES_CAT_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_WHERE_CLAUSE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from IEU_UWQ_RES_CATS_B
    where RES_CAT_ID = X_RES_CAT_ID
    ;
begin

  insert into IEU_UWQ_RES_CATS_B (
    RES_CAT_ID,
    OBJECT_VERSION_NUMBER,
    APPLICATION_ID,
    WHERE_CLAUSE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_RES_CAT_ID,
    X_OBJECT_VERSION_NUMBER,
    X_APPLICATION_ID,
    X_WHERE_CLAUSE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into IEU_UWQ_RES_CATS_TL (
    RES_CAT_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_RES_CAT_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from IEU_UWQ_RES_CATS_TL T
    where T.RES_CAT_ID = X_RES_CAT_ID
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
  X_RES_CAT_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_WHERE_CLAUSE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      APPLICATION_ID,
      WHERE_CLAUSE
    from IEU_UWQ_RES_CATS_B
    where RES_CAT_ID = X_RES_CAT_ID
    for update of RES_CAT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IEU_UWQ_RES_CATS_TL
    where RES_CAT_ID = X_RES_CAT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of RES_CAT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND (recinfo.WHERE_CLAUSE = X_WHERE_CLAUSE)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
          AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
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
  X_RES_CAT_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_WHERE_CLAUSE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update IEU_UWQ_RES_CATS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    APPLICATION_ID = X_APPLICATION_ID,
    WHERE_CLAUSE = X_WHERE_CLAUSE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where RES_CAT_ID = X_RES_CAT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IEU_UWQ_RES_CATS_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where RES_CAT_ID = X_RES_CAT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_RES_CAT_ID in NUMBER
) is
begin
  delete from IEU_UWQ_RES_CATS_TL
  where RES_CAT_ID = X_RES_CAT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IEU_UWQ_RES_CATS_B
  where RES_CAT_ID = X_RES_CAT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IEU_UWQ_RES_CATS_TL T
  where not exists
    (select NULL
    from IEU_UWQ_RES_CATS_B B
    where B.RES_CAT_ID = T.RES_CAT_ID
    );

  update IEU_UWQ_RES_CATS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from IEU_UWQ_RES_CATS_TL B
    where B.RES_CAT_ID = T.RES_CAT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RES_CAT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RES_CAT_ID,
      SUBT.LANGUAGE
    from IEU_UWQ_RES_CATS_TL SUBB, IEU_UWQ_RES_CATS_TL SUBT
    where SUBB.RES_CAT_ID = SUBT.RES_CAT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into IEU_UWQ_RES_CATS_TL (
    RES_CAT_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.RES_CAT_ID,
    B.OBJECT_VERSION_NUMBER,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEU_UWQ_RES_CATS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEU_UWQ_RES_CATS_TL T
    where T.RES_CAT_ID = B.RES_CAT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_RES_CAT_ID in NUMBER,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_WHERE_CLAUSE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
) is
  l_user_id  number := 0;
  l_rowid    varchar2(50);
  l_app_id   number;

begin

  IF (x_owner = 'SEED') then
    l_user_id := 1;
  end if;

  select
    application_id
  into
    l_app_id
  from
    fnd_application
  where
    application_short_name = x_application_short_name;

  begin

    UPDATE_ROW(
      X_RES_CAT_ID => x_res_cat_id,
      X_OBJECT_VERSION_NUMBER => 0,
      X_APPLICATION_ID => l_app_id,
      X_WHERE_CLAUSE => x_where_clause,
      X_NAME => x_name,
      X_DESCRIPTION => x_description,
      X_LAST_UPDATE_DATE => SYSDATE,
      --X_LAST_UPDATED_BY => l_user_id,
      X_LAST_UPDATED_BY => fnd_load_util.owner_id(X_OWNER),
      X_LAST_UPDATE_LOGIN => 0
    );

    if (sql%notfound) then
      raise no_data_found;
    end if;

  exception
    when no_data_found then

      INSERT_ROW(
        X_ROWID => l_rowid,
        X_RES_CAT_ID => x_res_cat_id,
        X_OBJECT_VERSION_NUMBER => 0,
        X_APPLICATION_ID => l_app_id,
        X_WHERE_CLAUSE => x_where_clause,
        X_NAME => x_name,
        X_DESCRIPTION => x_description,
        X_CREATION_DATE => SYSDATE,
        --X_CREATED_BY => l_user_id,
	   X_CREATED_BY => fnd_load_util.owner_id(X_OWNER),
        X_LAST_UPDATE_DATE => SYSDATE,
        --X_LAST_UPDATED_BY => l_user_id,
        X_LAST_UPDATED_BY => fnd_load_util.owner_id(X_OWNER),
        X_LAST_UPDATE_LOGIN => 0
      );

  end;

end LOAD_ROW;


procedure TRANSLATE_ROW (
  X_RES_CAT_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
) is
begin

  -- only UPDATE rows that have not been altered by user

  UPDATE
    IEU_UWQ_RES_CATS_TL
  SET
    source_lang = userenv('LANG'),
    name = x_name,
    description = x_description,
    last_update_date = sysdate,
    --last_updated_by = decode(x_owner, 'SEED', 1, 0),
    last_updated_by = fnd_load_util.owner_id(X_OWNER),
    last_update_login = 0
  WHERE
    (res_cat_id = x_res_cat_id) and
    (userenv('LANG') IN (language, source_lang));

  if (sql%notfound) then
    raise no_data_found;
  end if;

end TRANSLATE_ROW;

procedure LOAD_SEED_ROW(
  X_UPLOAD_MODE in VARCHAR2,
  X_RES_CAT_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_WHERE_CLAUSE in VARCHAR2
) is
begin

  if (X_UPLOAD_MODE = 'NLS') then
    TRANSLATE_ROW (
      X_RES_CAT_ID,
      X_NAME,
      X_DESCRIPTION,
      X_OWNER);
  else
    LOAD_ROW (
      X_RES_CAT_ID,
      X_APPLICATION_SHORT_NAME,
      X_WHERE_CLAUSE,
      X_NAME,
      X_DESCRIPTION,
      X_OWNER);
  end if;

end LOAD_SEED_ROW;


end IEU_UWQ_RES_CATS_PKG;

/
