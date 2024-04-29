--------------------------------------------------------
--  DDL for Package Body IEU_SH_ACT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_SH_ACT_TYPES_PKG" as
/* $Header: IEUSHATB.pls 120.2 2005/06/20 02:19:43 appldev ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_ACTIVITY_TYPE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_ACTIVITY_TYPE_CODE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from IEU_SH_ACT_TYPES_B
    where ACTIVITY_TYPE_ID = X_ACTIVITY_TYPE_ID
    ;
begin
  insert into IEU_SH_ACT_TYPES_B (
    ACTIVITY_TYPE_ID,
    OBJECT_VERSION_NUMBER,
    ACTIVITY_TYPE_CODE,
    APPLICATION_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ACTIVITY_TYPE_ID,
    X_OBJECT_VERSION_NUMBER,
    X_ACTIVITY_TYPE_CODE,
    X_APPLICATION_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into IEU_SH_ACT_TYPES_TL (
    APPLICATION_ID,
    NAME,
    DESCRIPTION,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    ACTIVITY_TYPE_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APPLICATION_ID,
    X_NAME,
    X_DESCRIPTION,
    X_OBJECT_VERSION_NUMBER,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_ACTIVITY_TYPE_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from IEU_SH_ACT_TYPES_TL T
    where T.ACTIVITY_TYPE_ID = X_ACTIVITY_TYPE_ID
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
  X_ACTIVITY_TYPE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_ACTIVITY_TYPE_CODE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      ACTIVITY_TYPE_CODE,
      APPLICATION_ID
    from IEU_SH_ACT_TYPES_B
    where ACTIVITY_TYPE_ID = X_ACTIVITY_TYPE_ID
    for update of ACTIVITY_TYPE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IEU_SH_ACT_TYPES_TL
    where ACTIVITY_TYPE_ID = X_ACTIVITY_TYPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ACTIVITY_TYPE_ID nowait;
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
      AND (recinfo.ACTIVITY_TYPE_CODE = X_ACTIVITY_TYPE_CODE)
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
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
  X_ACTIVITY_TYPE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_ACTIVITY_TYPE_CODE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update IEU_SH_ACT_TYPES_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ACTIVITY_TYPE_CODE = X_ACTIVITY_TYPE_CODE,
    APPLICATION_ID = X_APPLICATION_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ACTIVITY_TYPE_ID = X_ACTIVITY_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IEU_SH_ACT_TYPES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ACTIVITY_TYPE_ID = X_ACTIVITY_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ACTIVITY_TYPE_ID in NUMBER
) is
begin
  delete from IEU_SH_ACT_TYPES_TL
  where ACTIVITY_TYPE_ID = X_ACTIVITY_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IEU_SH_ACT_TYPES_B
  where ACTIVITY_TYPE_ID = X_ACTIVITY_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IEU_SH_ACT_TYPES_TL T
  where not exists
    (select NULL
    from IEU_SH_ACT_TYPES_B B
    where B.ACTIVITY_TYPE_ID = T.ACTIVITY_TYPE_ID
    );

  update IEU_SH_ACT_TYPES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from IEU_SH_ACT_TYPES_TL B
    where B.ACTIVITY_TYPE_ID = T.ACTIVITY_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ACTIVITY_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ACTIVITY_TYPE_ID,
      SUBT.LANGUAGE
    from IEU_SH_ACT_TYPES_TL SUBB, IEU_SH_ACT_TYPES_TL SUBT
    where SUBB.ACTIVITY_TYPE_ID = SUBT.ACTIVITY_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into IEU_SH_ACT_TYPES_TL (
    APPLICATION_ID,
    NAME,
    DESCRIPTION,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    ACTIVITY_TYPE_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.APPLICATION_ID,
    B.NAME,
    B.DESCRIPTION,
    B.OBJECT_VERSION_NUMBER,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.ACTIVITY_TYPE_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEU_SH_ACT_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEU_SH_ACT_TYPES_TL T
    where T.ACTIVITY_TYPE_ID = B.ACTIVITY_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_ACTIVITY_TYPE_ID in NUMBER,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_ACTIVITY_TYPE_CODE in VARCHAR2,
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
      X_ACTIVITY_TYPE_ID => X_ACTIVITY_TYPE_ID,
      X_OBJECT_VERSION_NUMBER => 0,
      X_APPLICATION_ID => l_app_id,
      X_ACTIVITY_TYPE_CODE => X_ACTIVITY_TYPE_CODE,
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
        X_ACTIVITY_TYPE_ID => X_ACTIVITY_TYPE_ID,
        X_OBJECT_VERSION_NUMBER => 0,
        X_APPLICATION_ID => l_app_id,
        X_ACTIVITY_TYPE_CODE => X_ACTIVITY_TYPE_CODE,
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
  X_ACTIVITY_TYPE_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
) is
begin

  -- only UPDATE rows that have not been altered by user

  UPDATE
    IEU_SH_ACT_TYPES_TL
  SET
    source_lang = userenv('LANG'),
    name = x_name,
    description = x_description,
    last_update_date = sysdate,
    --last_updated_by = decode(x_owner, 'SEED', 1, 0),
    last_updated_by = fnd_load_util.owner_id(x_owner),
    last_update_login = 0
  WHERE
    (ACTIVITY_TYPE_ID = X_ACTIVITY_TYPE_ID) and
    (userenv('LANG') IN (language, source_lang));

  if (sql%notfound) then
    raise no_data_found;
  end if;

end TRANSLATE_ROW;

procedure LOAD_SEED_ROW (
  X_UPLOAD_MODE in VARCHAR2,
  X_ACTIVITY_TYPE_ID in NUMBER,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_ACTIVITY_TYPE_CODE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
) is
begin

if (X_UPLOAD_MODE  = 'NLS') then
       TRANSLATE_ROW (
             X_ACTIVITY_TYPE_ID,
             X_NAME,
             X_DESCRIPTION,
             X_OWNER);
else
       LOAD_ROW (
             X_ACTIVITY_TYPE_ID,
             X_APPLICATION_SHORT_NAME,
             X_ACTIVITY_TYPE_CODE,
             X_NAME,
             X_DESCRIPTION,
             X_OWNER);
end if;

end LOAD_SEED_ROW;

end IEU_SH_ACT_TYPES_PKG;

/
