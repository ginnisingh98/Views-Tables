--------------------------------------------------------
--  DDL for Package Body IEC_O_VALIDATION_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_O_VALIDATION_RULES_PKG" as
/* $Header: IECOVRLB.pls 115.8 2003/08/22 20:42:08 hhuang noship $ */

procedure INSERT_ROW (
  X_ROWID out nocopy VARCHAR2,
  X_VALIDATION_RULE_ID in NUMBER,
  X_BLOCK_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VALIDATION_RULE_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from IEC_O_VALIDATION_RULES_B
    where VALIDATION_RULE_ID = X_VALIDATION_RULE_ID
    ;
begin
  x_rowid := NULL;

  insert into IEC_O_VALIDATION_RULES_B (
    VALIDATION_RULE_ID,
    BLOCK_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_VALIDATION_RULE_ID,
    X_BLOCK_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into IEC_O_VALIDATION_RULES_TL (
    VALIDATION_RULE_ID,
    VALIDATION_RULE_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_VALIDATION_RULE_ID,
    X_VALIDATION_RULE_NAME,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from IEC_O_VALIDATION_RULES_TL T
    where T.VALIDATION_RULE_ID = X_VALIDATION_RULE_ID
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
  X_VALIDATION_RULE_ID in NUMBER,
  X_BLOCK_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VALIDATION_RULE_NAME in VARCHAR2
) is
  cursor c is select
      BLOCK_ID,
      OBJECT_VERSION_NUMBER
    from IEC_O_VALIDATION_RULES_B
    where VALIDATION_RULE_ID = X_VALIDATION_RULE_ID
    for update of VALIDATION_RULE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      VALIDATION_RULE_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IEC_O_VALIDATION_RULES_TL
    where VALIDATION_RULE_ID = X_VALIDATION_RULE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of VALIDATION_RULE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.BLOCK_ID = X_BLOCK_ID)
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.VALIDATION_RULE_NAME = X_VALIDATION_RULE_NAME)
               OR ((tlinfo.VALIDATION_RULE_NAME is null) AND (X_VALIDATION_RULE_NAME is null)))
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
  X_VALIDATION_RULE_ID in NUMBER,
  X_BLOCK_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VALIDATION_RULE_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update IEC_O_VALIDATION_RULES_B set
    BLOCK_ID = X_BLOCK_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where VALIDATION_RULE_ID = X_VALIDATION_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IEC_O_VALIDATION_RULES_TL set
    VALIDATION_RULE_NAME = X_VALIDATION_RULE_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where VALIDATION_RULE_ID = X_VALIDATION_RULE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_VALIDATION_RULE_ID in NUMBER
) is
begin
  delete from IEC_O_VALIDATION_RULES_TL
  where VALIDATION_RULE_ID = X_VALIDATION_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IEC_O_VALIDATION_RULES_B
  where VALIDATION_RULE_ID = X_VALIDATION_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IEC_O_VALIDATION_RULES_TL T
  where not exists
    (select NULL
    from IEC_O_VALIDATION_RULES_B B
    where B.VALIDATION_RULE_ID = T.VALIDATION_RULE_ID
    );

  update IEC_O_VALIDATION_RULES_TL T set (
      VALIDATION_RULE_NAME
    ) = (select
      B.VALIDATION_RULE_NAME
    from IEC_O_VALIDATION_RULES_TL B
    where B.VALIDATION_RULE_ID = T.VALIDATION_RULE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.VALIDATION_RULE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.VALIDATION_RULE_ID,
      SUBT.LANGUAGE
    from IEC_O_VALIDATION_RULES_TL SUBB, IEC_O_VALIDATION_RULES_TL SUBT
    where SUBB.VALIDATION_RULE_ID = SUBT.VALIDATION_RULE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.VALIDATION_RULE_NAME <> SUBT.VALIDATION_RULE_NAME
      or (SUBB.VALIDATION_RULE_NAME is null and SUBT.VALIDATION_RULE_NAME is not null)
      or (SUBB.VALIDATION_RULE_NAME is not null and SUBT.VALIDATION_RULE_NAME is null)
  ));

  insert into IEC_O_VALIDATION_RULES_TL (
    VALIDATION_RULE_ID,
    VALIDATION_RULE_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.VALIDATION_RULE_ID,
    B.VALIDATION_RULE_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEC_O_VALIDATION_RULES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEC_O_VALIDATION_RULES_TL T
    where T.VALIDATION_RULE_ID = B.VALIDATION_RULE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_VALIDATION_RULE_ID in NUMBER,
  X_BLOCK_ID in NUMBER,
  X_VALIDATION_RULE_NAME in VARCHAR2,
  X_OWNER in VARCHAR2
) is

  USER_ID NUMBER := 0;
  ROW_ID  VARCHAR2(500);

begin

  if (X_OWNER = 'SEED') then
    USER_ID := 1;
  end if;

  UPDATE_ROW ( X_VALIDATION_RULE_ID
             , X_BLOCK_ID
             , 0
             , X_VALIDATION_RULE_NAME
             , SYSDATE
             , USER_ID
             , 0);

exception
  when no_data_found then
    INSERT_ROW ( ROW_ID
               , X_VALIDATION_RULE_ID
               , X_BLOCK_ID
               , 0
               , X_VALIDATION_RULE_NAME
               , SYSDATE
               , USER_ID
               , SYSDATE
               , USER_ID
               , 0);

end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_VALIDATION_RULE_ID in NUMBER,
  X_VALIDATION_RULE_NAME in VARCHAR2,
  X_OWNER in VARCHAR2
) is
begin

  -- only UPDATE rows that have not been altered by user

  update IEC_O_VALIDATION_RULES_TL set
  SOURCE_LANG = userenv('LANG'),
  VALIDATION_RULE_NAME = X_VALIDATION_RULE_NAME,
  LAST_UPDATE_DATE = SYSDATE,
  LAST_UPDATED_BY = DECODE(X_OWNER, 'SEED', 1, 0),
  LAST_UPDATE_LOGIN = 0
  where VALIDATION_RULE_ID = X_VALIDATION_RULE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

end TRANSLATE_ROW;

end IEC_O_VALIDATION_RULES_PKG;

/