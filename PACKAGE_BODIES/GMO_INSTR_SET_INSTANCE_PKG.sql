--------------------------------------------------------
--  DDL for Package Body GMO_INSTR_SET_INSTANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_INSTR_SET_INSTANCE_PKG" as
/* $Header: GMOINSIB.pls 120.0 2005/06/29 04:22 shthakke noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_INSTRUCTION_SET_ID in NUMBER,
  X_INSTR_SET_STATUS in VARCHAR2,
  X_INSTRUCTION_TYPE in VARCHAR2,
  X_INSTR_SET_NAME in VARCHAR2,
  X_ENTITY_NAME in VARCHAR2,
  X_ENTITY_KEY in VARCHAR2,
  X_ACKN_STATUS in VARCHAR2,
  X_ORIG_SOURCE in VARCHAR2,
  X_ORIG_SOURCE_ID in NUMBER,
  X_INSTR_SET_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from GMO_INSTR_SET_INSTANCE_B
    where INSTRUCTION_SET_ID = X_INSTRUCTION_SET_ID
    ;
begin
  insert into GMO_INSTR_SET_INSTANCE_B (
    INSTR_SET_STATUS,
    INSTRUCTION_SET_ID,
    INSTRUCTION_TYPE,
    INSTR_SET_NAME,
    ENTITY_NAME,
    ENTITY_KEY,
    ACKN_STATUS,
    ORIG_SOURCE,
    ORIG_SOURCE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_INSTR_SET_STATUS,
    X_INSTRUCTION_SET_ID,
    X_INSTRUCTION_TYPE,
    X_INSTR_SET_NAME,
    X_ENTITY_NAME,
    X_ENTITY_KEY,
    X_ACKN_STATUS,
    X_ORIG_SOURCE,
    X_ORIG_SOURCE_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into GMO_INSTR_SET_INSTANCE_TL (
    INSTRUCTION_SET_ID,
    INSTR_SET_DESC,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_INSTRUCTION_SET_ID,
    X_INSTR_SET_DESC,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from GMO_INSTR_SET_INSTANCE_TL T
    where T.INSTRUCTION_SET_ID = X_INSTRUCTION_SET_ID
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
  X_INSTRUCTION_SET_ID in NUMBER,
  X_INSTR_SET_STATUS in VARCHAR2,
  X_INSTRUCTION_TYPE in VARCHAR2,
  X_INSTR_SET_NAME in VARCHAR2,
  X_ENTITY_NAME in VARCHAR2,
  X_ENTITY_KEY in VARCHAR2,
  X_ACKN_STATUS in VARCHAR2,
  X_ORIG_SOURCE in VARCHAR2,
  X_ORIG_SOURCE_ID in NUMBER,
  X_INSTR_SET_DESC in VARCHAR2
) is
  cursor c is select
      INSTR_SET_STATUS,
      INSTRUCTION_TYPE,
      INSTR_SET_NAME,
      ENTITY_NAME,
      ENTITY_KEY,
      ACKN_STATUS,
      ORIG_SOURCE,
      ORIG_SOURCE_ID
    from GMO_INSTR_SET_INSTANCE_B
    where INSTRUCTION_SET_ID = X_INSTRUCTION_SET_ID
    for update of INSTRUCTION_SET_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      INSTR_SET_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from GMO_INSTR_SET_INSTANCE_TL
    where INSTRUCTION_SET_ID = X_INSTRUCTION_SET_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of INSTRUCTION_SET_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.INSTR_SET_STATUS = X_INSTR_SET_STATUS)
           OR ((recinfo.INSTR_SET_STATUS is null) AND (X_INSTR_SET_STATUS is null)))
      AND ((recinfo.INSTRUCTION_TYPE = X_INSTRUCTION_TYPE)
           OR ((recinfo.INSTRUCTION_TYPE is null) AND (X_INSTRUCTION_TYPE is null)))
      AND ((recinfo.INSTR_SET_NAME = X_INSTR_SET_NAME)
           OR ((recinfo.INSTR_SET_NAME is null) AND (X_INSTR_SET_NAME is null)))
      AND ((recinfo.ENTITY_NAME = X_ENTITY_NAME)
           OR ((recinfo.ENTITY_NAME is null) AND (X_ENTITY_NAME is null)))
      AND ((recinfo.ENTITY_KEY = X_ENTITY_KEY)
           OR ((recinfo.ENTITY_KEY is null) AND (X_ENTITY_KEY is null)))
      AND ((recinfo.ACKN_STATUS = X_ACKN_STATUS)
           OR ((recinfo.ACKN_STATUS is null) AND (X_ACKN_STATUS is null)))
      AND ((recinfo.ORIG_SOURCE = X_ORIG_SOURCE)
           OR ((recinfo.ORIG_SOURCE is null) AND (X_ORIG_SOURCE is null)))
      AND ((recinfo.ORIG_SOURCE_ID = X_ORIG_SOURCE_ID)
           OR ((recinfo.ORIG_SOURCE_ID is null) AND (X_ORIG_SOURCE_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.INSTR_SET_DESC = X_INSTR_SET_DESC)
               OR ((tlinfo.INSTR_SET_DESC is null) AND (X_INSTR_SET_DESC is null)))
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
  X_INSTRUCTION_SET_ID in NUMBER,
  X_INSTR_SET_STATUS in VARCHAR2,
  X_INSTRUCTION_TYPE in VARCHAR2,
  X_INSTR_SET_NAME in VARCHAR2,
  X_ENTITY_NAME in VARCHAR2,
  X_ENTITY_KEY in VARCHAR2,
  X_ACKN_STATUS in VARCHAR2,
  X_ORIG_SOURCE in VARCHAR2,
  X_ORIG_SOURCE_ID in NUMBER,
  X_INSTR_SET_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update GMO_INSTR_SET_INSTANCE_B set
    INSTR_SET_STATUS = X_INSTR_SET_STATUS,
    INSTRUCTION_TYPE = X_INSTRUCTION_TYPE,
    INSTR_SET_NAME = X_INSTR_SET_NAME,
    ENTITY_NAME = X_ENTITY_NAME,
    ENTITY_KEY = X_ENTITY_KEY,
    ACKN_STATUS = X_ACKN_STATUS,
    ORIG_SOURCE = X_ORIG_SOURCE,
    ORIG_SOURCE_ID = X_ORIG_SOURCE_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where INSTRUCTION_SET_ID = X_INSTRUCTION_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update GMO_INSTR_SET_INSTANCE_TL set
    INSTR_SET_DESC = X_INSTR_SET_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where INSTRUCTION_SET_ID = X_INSTRUCTION_SET_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_INSTRUCTION_SET_ID in NUMBER
) is
begin
  delete from GMO_INSTR_SET_INSTANCE_TL
  where INSTRUCTION_SET_ID = X_INSTRUCTION_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from GMO_INSTR_SET_INSTANCE_B
  where INSTRUCTION_SET_ID = X_INSTRUCTION_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from GMO_INSTR_SET_INSTANCE_TL T
  where not exists
    (select NULL
    from GMO_INSTR_SET_INSTANCE_B B
    where B.INSTRUCTION_SET_ID = T.INSTRUCTION_SET_ID
    );

  update GMO_INSTR_SET_INSTANCE_TL T set (
      INSTR_SET_DESC
    ) = (select
      B.INSTR_SET_DESC
    from GMO_INSTR_SET_INSTANCE_TL B
    where B.INSTRUCTION_SET_ID = T.INSTRUCTION_SET_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.INSTRUCTION_SET_ID,
      T.LANGUAGE
  ) in (select
      SUBT.INSTRUCTION_SET_ID,
      SUBT.LANGUAGE
    from GMO_INSTR_SET_INSTANCE_TL SUBB, GMO_INSTR_SET_INSTANCE_TL SUBT
    where SUBB.INSTRUCTION_SET_ID = SUBT.INSTRUCTION_SET_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.INSTR_SET_DESC <> SUBT.INSTR_SET_DESC
      or (SUBB.INSTR_SET_DESC is null and SUBT.INSTR_SET_DESC is not null)
      or (SUBB.INSTR_SET_DESC is not null and SUBT.INSTR_SET_DESC is null)
  ));

  insert into GMO_INSTR_SET_INSTANCE_TL (
    INSTRUCTION_SET_ID,
    INSTR_SET_DESC,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.INSTRUCTION_SET_ID,
    B.INSTR_SET_DESC,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GMO_INSTR_SET_INSTANCE_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GMO_INSTR_SET_INSTANCE_TL T
    where T.INSTRUCTION_SET_ID = B.INSTRUCTION_SET_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end GMO_INSTR_SET_INSTANCE_PKG;

/
