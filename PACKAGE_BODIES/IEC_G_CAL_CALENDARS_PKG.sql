--------------------------------------------------------
--  DDL for Package Body IEC_G_CAL_CALENDARS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_G_CAL_CALENDARS_PKG" as
/* $Header: IECCCALB.pls 115.7 2003/08/22 20:41:17 hhuang noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CALENDAR_ID in NUMBER,
  X_CALENDAR_TYPE_CODE in VARCHAR2,
  X_TERRITORY_CODE in VARCHAR2,
  X_OVERRIDE_CC_CAL_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CALENDAR_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from IEC_G_CAL_CALENDARS_B
    where CALENDAR_ID = X_CALENDAR_ID
    ;
begin
  insert into IEC_G_CAL_CALENDARS_B (
    CALENDAR_ID,
    CALENDAR_TYPE_CODE,
    TERRITORY_CODE,
    OVERRIDE_CC_CAL_FLAG,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_CALENDAR_ID,
    X_CALENDAR_TYPE_CODE,
    X_TERRITORY_CODE,
    X_OVERRIDE_CC_CAL_FLAG,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into IEC_G_CAL_CALENDARS_TL (
    CALENDAR_ID,
    CALENDAR_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CALENDAR_ID,
    X_CALENDAR_NAME,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from IEC_G_CAL_CALENDARS_TL T
    where T.CALENDAR_ID = X_CALENDAR_ID
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
  X_CALENDAR_ID in NUMBER,
  X_CALENDAR_TYPE_CODE in VARCHAR2,
  X_TERRITORY_CODE in VARCHAR2,
  X_OVERRIDE_CC_CAL_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CALENDAR_NAME in VARCHAR2
) is
  cursor c is select
      CALENDAR_TYPE_CODE,
      TERRITORY_CODE,
      OVERRIDE_CC_CAL_FLAG,
      OBJECT_VERSION_NUMBER
    from IEC_G_CAL_CALENDARS_B
    where CALENDAR_ID = X_CALENDAR_ID
    for update of CALENDAR_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      CALENDAR_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IEC_G_CAL_CALENDARS_TL
    where CALENDAR_ID = X_CALENDAR_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CALENDAR_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.CALENDAR_TYPE_CODE = X_CALENDAR_TYPE_CODE)
      AND ((recinfo.TERRITORY_CODE = X_TERRITORY_CODE)
           OR ((recinfo.TERRITORY_CODE is null) AND (X_TERRITORY_CODE is null)))
      AND (recinfo.OVERRIDE_CC_CAL_FLAG = X_OVERRIDE_CC_CAL_FLAG)
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.CALENDAR_NAME = X_CALENDAR_NAME)
               OR ((tlinfo.CALENDAR_NAME is null) AND (X_CALENDAR_NAME is null)))
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
  X_CALENDAR_ID in NUMBER,
  X_CALENDAR_TYPE_CODE in VARCHAR2,
  X_TERRITORY_CODE in VARCHAR2,
  X_OVERRIDE_CC_CAL_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CALENDAR_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update IEC_G_CAL_CALENDARS_B set
    CALENDAR_TYPE_CODE = X_CALENDAR_TYPE_CODE,
    TERRITORY_CODE = X_TERRITORY_CODE,
    OVERRIDE_CC_CAL_FLAG = X_OVERRIDE_CC_CAL_FLAG,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CALENDAR_ID = X_CALENDAR_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IEC_G_CAL_CALENDARS_TL set
    CALENDAR_NAME = X_CALENDAR_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CALENDAR_ID = X_CALENDAR_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CALENDAR_ID in NUMBER
) is
begin
  delete from IEC_G_CAL_CALENDARS_TL
  where CALENDAR_ID = X_CALENDAR_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IEC_G_CAL_CALENDARS_B
  where CALENDAR_ID = X_CALENDAR_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IEC_G_CAL_CALENDARS_TL T
  where not exists
    (select NULL
    from IEC_G_CAL_CALENDARS_B B
    where B.CALENDAR_ID = T.CALENDAR_ID
    );

  update IEC_G_CAL_CALENDARS_TL T set (
      CALENDAR_NAME
    ) = (select
      B.CALENDAR_NAME
    from IEC_G_CAL_CALENDARS_TL B
    where B.CALENDAR_ID = T.CALENDAR_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CALENDAR_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CALENDAR_ID,
      SUBT.LANGUAGE
    from IEC_G_CAL_CALENDARS_TL SUBB, IEC_G_CAL_CALENDARS_TL SUBT
    where SUBB.CALENDAR_ID = SUBT.CALENDAR_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CALENDAR_NAME <> SUBT.CALENDAR_NAME
      or (SUBB.CALENDAR_NAME is null and SUBT.CALENDAR_NAME is not null)
      or (SUBB.CALENDAR_NAME is not null and SUBT.CALENDAR_NAME is null)
  ));

  insert into IEC_G_CAL_CALENDARS_TL (
    CALENDAR_ID,
    CALENDAR_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CALENDAR_ID,
    B.CALENDAR_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEC_G_CAL_CALENDARS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEC_G_CAL_CALENDARS_TL T
    where T.CALENDAR_ID = B.CALENDAR_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_CALENDAR_ID in NUMBER,
  X_CALENDAR_TYPE_CODE in VARCHAR2,
  X_TERRITORY_CODE in VARCHAR2,
  X_OVERRIDE_CC_CAL_FLAG in VARCHAR2,
  X_CALENDAR_NAME in VARCHAR2,
  X_OWNER in VARCHAR2
) is

  USER_ID NUMBER := 0;
  ROW_ID  VARCHAR2(500);

begin

  if (X_OWNER = 'SEED') then
    USER_ID := 1;
  end if;

  UPDATE_ROW ( X_CALENDAR_ID
             , X_CALENDAR_TYPE_CODE
             , X_TERRITORY_CODE
             , X_OVERRIDE_CC_CAL_FLAG
             , 0
             , X_CALENDAR_NAME
             , SYSDATE
             , USER_ID
             , 0);

exception
  when no_data_found then
    INSERT_ROW ( ROW_ID
               , X_CALENDAR_ID
               , X_CALENDAR_TYPE_CODE
               , X_TERRITORY_CODE
               , X_OVERRIDE_CC_CAL_FLAG
               , 0
               , X_CALENDAR_NAME
               , SYSDATE
               , USER_ID
               , SYSDATE
               , USER_ID
               , 0);

end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_CALENDAR_ID in NUMBER,
  X_CALENDAR_NAME in VARCHAR2,
  X_OWNER in VARCHAR2
) is
begin

  -- only UPDATE rows that have not been altered by user

  update IEC_G_CAL_CALENDARS_TL set
  SOURCE_LANG = userenv('LANG'),
  CALENDAR_NAME = X_CALENDAR_NAME,
  LAST_UPDATE_DATE = SYSDATE,
  LAST_UPDATED_BY = DECODE(X_OWNER, 'SEED', 1, 0),
  LAST_UPDATE_LOGIN = 0
  where CALENDAR_ID = X_CALENDAR_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

end TRANSLATE_ROW;

end IEC_G_CAL_CALENDARS_PKG;

/