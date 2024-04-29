--------------------------------------------------------
--  DDL for Package Body IEC_P_VDU_PORT_PARAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_P_VDU_PORT_PARAMS_PKG" as
/* $Header: IECHVPPB.pls 115.10 2003/08/22 20:41:50 hhuang ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_VDU_PORT_PARAM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VDU_TYPE_ID in NUMBER,
  X_MIDDLEWARE_TYPE_ID in NUMBER,
  X_PARAM_CODE in VARCHAR2,
  X_VALUE_TYPE in VARCHAR2,
  X_VALUE_LENGTH in VARCHAR2,
  X_AUTO_GEN_FLAG in VARCHAR2,
  X_PARAM_NAME in VARCHAR2,
  X_PARAM_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from IEC_P_VDU_PORT_PARAMS_B
    where VDU_PORT_PARAM_ID = X_VDU_PORT_PARAM_ID
    ;
begin
  insert into IEC_P_VDU_PORT_PARAMS_B (
    VDU_PORT_PARAM_ID,
    OBJECT_VERSION_NUMBER,
    VDU_TYPE_ID,
    MIDDLEWARE_TYPE_ID,
    PARAM_CODE,
    VALUE_TYPE,
    VALUE_LENGTH,
    AUTO_GEN_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_VDU_PORT_PARAM_ID,
    X_OBJECT_VERSION_NUMBER,
    X_VDU_TYPE_ID,
    X_MIDDLEWARE_TYPE_ID,
    X_PARAM_CODE,
    X_VALUE_TYPE,
    X_VALUE_LENGTH,
    X_AUTO_GEN_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into IEC_P_VDU_PORT_PARAMS_TL (
    VDU_PORT_PARAM_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    PARAM_NAME,
    PARAM_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_VDU_PORT_PARAM_ID,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_PARAM_NAME,
    X_PARAM_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from IEC_P_VDU_PORT_PARAMS_TL T
    where T.VDU_PORT_PARAM_ID = X_VDU_PORT_PARAM_ID
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
  X_VDU_PORT_PARAM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VDU_TYPE_ID in NUMBER,
  X_MIDDLEWARE_TYPE_ID in NUMBER,
  X_PARAM_CODE in VARCHAR2,
  X_VALUE_TYPE in VARCHAR2,
  X_VALUE_LENGTH in VARCHAR2,
  X_AUTO_GEN_FLAG in VARCHAR2,
  X_PARAM_NAME in VARCHAR2,
  X_PARAM_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      VDU_TYPE_ID,
      MIDDLEWARE_TYPE_ID,
      PARAM_CODE,
      VALUE_TYPE,
      VALUE_LENGTH,
      AUTO_GEN_FLAG
    from IEC_P_VDU_PORT_PARAMS_B
    where VDU_PORT_PARAM_ID = X_VDU_PORT_PARAM_ID
    for update of VDU_PORT_PARAM_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      PARAM_NAME,
      PARAM_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IEC_P_VDU_PORT_PARAMS_TL
    where VDU_PORT_PARAM_ID = X_VDU_PORT_PARAM_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of VDU_PORT_PARAM_ID nowait;
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
      AND (recinfo.VDU_TYPE_ID = X_VDU_TYPE_ID)
      AND ((recinfo.MIDDLEWARE_TYPE_ID = X_MIDDLEWARE_TYPE_ID)
           OR ((recinfo.MIDDLEWARE_TYPE_ID is null) AND (X_MIDDLEWARE_TYPE_ID is null)))
      AND (recinfo.PARAM_CODE = X_PARAM_CODE)
      AND ((recinfo.VALUE_TYPE = X_VALUE_TYPE)
           OR ((recinfo.VALUE_TYPE is null) AND (X_VALUE_TYPE is null)))
      AND ((recinfo.VALUE_LENGTH = X_VALUE_LENGTH)
           OR ((recinfo.VALUE_LENGTH is null) AND (X_VALUE_LENGTH is null)))
      AND ((recinfo.AUTO_GEN_FLAG = X_AUTO_GEN_FLAG)
           OR ((recinfo.AUTO_GEN_FLAG is null) AND (X_AUTO_GEN_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.PARAM_NAME = X_PARAM_NAME)
          AND ((tlinfo.PARAM_DESCRIPTION = X_PARAM_DESCRIPTION)
               OR ((tlinfo.PARAM_DESCRIPTION is null) AND (X_PARAM_DESCRIPTION is null)))
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
  X_VDU_PORT_PARAM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VDU_TYPE_ID in NUMBER,
  X_MIDDLEWARE_TYPE_ID in NUMBER,
  X_PARAM_CODE in VARCHAR2,
  X_VALUE_TYPE in VARCHAR2,
  X_VALUE_LENGTH in VARCHAR2,
  X_AUTO_GEN_FLAG in VARCHAR2,
  X_PARAM_NAME in VARCHAR2,
  X_PARAM_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update IEC_P_VDU_PORT_PARAMS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    VDU_TYPE_ID = X_VDU_TYPE_ID,
    MIDDLEWARE_TYPE_ID = X_MIDDLEWARE_TYPE_ID,
    PARAM_CODE = X_PARAM_CODE,
    VALUE_TYPE = X_VALUE_TYPE,
    VALUE_LENGTH = X_VALUE_LENGTH,
    AUTO_GEN_FLAG = X_AUTO_GEN_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where VDU_PORT_PARAM_ID = X_VDU_PORT_PARAM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IEC_P_VDU_PORT_PARAMS_TL set
    PARAM_NAME = X_PARAM_NAME,
    PARAM_DESCRIPTION = X_PARAM_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where VDU_PORT_PARAM_ID = X_VDU_PORT_PARAM_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_VDU_PORT_PARAM_ID in NUMBER
) is
begin
  delete from IEC_P_VDU_PORT_PARAMS_TL
  where VDU_PORT_PARAM_ID = X_VDU_PORT_PARAM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IEC_P_VDU_PORT_PARAMS_B
  where VDU_PORT_PARAM_ID = X_VDU_PORT_PARAM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IEC_P_VDU_PORT_PARAMS_TL T
  where not exists
    (select NULL
    from IEC_P_VDU_PORT_PARAMS_B B
    where B.VDU_PORT_PARAM_ID = T.VDU_PORT_PARAM_ID
    );

  update IEC_P_VDU_PORT_PARAMS_TL T set (
      PARAM_NAME,
      PARAM_DESCRIPTION
    ) = (select
      B.PARAM_NAME,
      B.PARAM_DESCRIPTION
    from IEC_P_VDU_PORT_PARAMS_TL B
    where B.VDU_PORT_PARAM_ID = T.VDU_PORT_PARAM_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.VDU_PORT_PARAM_ID,
      T.LANGUAGE
  ) in (select
      SUBT.VDU_PORT_PARAM_ID,
      SUBT.LANGUAGE
    from IEC_P_VDU_PORT_PARAMS_TL SUBB, IEC_P_VDU_PORT_PARAMS_TL SUBT
    where SUBB.VDU_PORT_PARAM_ID = SUBT.VDU_PORT_PARAM_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PARAM_NAME <> SUBT.PARAM_NAME
      or SUBB.PARAM_DESCRIPTION <> SUBT.PARAM_DESCRIPTION
      or (SUBB.PARAM_DESCRIPTION is null and SUBT.PARAM_DESCRIPTION is not null)
      or (SUBB.PARAM_DESCRIPTION is not null and SUBT.PARAM_DESCRIPTION is null)
  ));

  insert into IEC_P_VDU_PORT_PARAMS_TL (
    VDU_PORT_PARAM_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    PARAM_NAME,
    PARAM_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.VDU_PORT_PARAM_ID,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.PARAM_NAME,
    B.PARAM_DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEC_P_VDU_PORT_PARAMS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEC_P_VDU_PORT_PARAMS_TL T
    where T.VDU_PORT_PARAM_ID = B.VDU_PORT_PARAM_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_VDU_PORT_PARAM_ID in NUMBER,
  X_VDU_TYPE_ID in NUMBER,
  X_MIDDLEWARE_TYPE_ID in NUMBER,
  X_PARAM_CODE in VARCHAR2,
  X_VALUE_TYPE in VARCHAR2,
  X_VALUE_LENGTH in VARCHAR2,
  X_AUTO_GEN_FLAG in VARCHAR2,
  X_PARAM_NAME in VARCHAR2,
  X_PARAM_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
) is

  USER_ID NUMBER := 0;
  ROW_ID  VARCHAR2(500);
begin

  if (X_OWNER = 'SEED') then
    USER_ID := 1;
  end if;

  UPDATE_ROW ( X_VDU_PORT_PARAM_ID
             , 0
             , X_VDU_TYPE_ID
             , X_MIDDLEWARE_TYPE_ID
             , X_PARAM_CODE
             , X_VALUE_TYPE
             , X_VALUE_LENGTH
             , X_AUTO_GEN_FLAG
             , X_PARAM_NAME
             , X_PARAM_DESCRIPTION
             , SYSDATE
             , USER_ID
             , 0);

exception
  when no_data_found then
    INSERT_ROW ( ROW_ID
               , X_VDU_PORT_PARAM_ID
               , 0
               , X_VDU_TYPE_ID
               , X_MIDDLEWARE_TYPE_ID
               , X_PARAM_CODE
               , X_VALUE_TYPE
               , X_VALUE_LENGTH
               , X_AUTO_GEN_FLAG
               , X_PARAM_NAME
               , X_PARAM_DESCRIPTION
               , SYSDATE
               , USER_ID
               , SYSDATE
               , USER_ID
               , 0);

end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_VDU_PORT_PARAM_ID in NUMBER,
  X_PARAM_NAME in VARCHAR2,
  X_PARAM_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
) is
begin

  -- only UPDATE rows that have not been altered by user

  update IEC_P_VDU_PORT_PARAMS_TL set
  PARAM_NAME = X_PARAM_NAME,
  PARAM_DESCRIPTION = X_PARAM_DESCRIPTION,
  SOURCE_LANG = userenv('LANG'),
  LAST_UPDATE_DATE = SYSDATE,
  LAST_UPDATED_BY = DECODE(X_OWNER, 'SEED', 1, 0),
  LAST_UPDATE_LOGIN = 0
  where VDU_PORT_PARAM_ID = X_VDU_PORT_PARAM_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

end TRANSLATE_ROW;

end IEC_P_VDU_PORT_PARAMS_PKG;

/
