--------------------------------------------------------
--  DDL for Package Body GMO_INSTR_TASK_DEFN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_INSTR_TASK_DEFN_PKG" as
/* $Header: GMOTSKDB.pls 120.0.12000000.2 2007/03/14 12:06:17 rvsingh ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TASK_ID in NUMBER,
  X_ENTITY_NAME in VARCHAR2,
  X_INSTRUCTION_TYPE in VARCHAR2,
  X_TASK_NAME in VARCHAR2,
  X_TASK_TYPE in VARCHAR2,
  X_TARGET in VARCHAR2,
  X_ATTRIBUTE_SQL in VARCHAR2,
  X_ATTRIBUTE_DISPLAY_COL_COUNT in NUMBER,
  X_MAX_ALLOWED_TASK in NUMBER,
  X_ENTITY_KEY_PATTERN in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from GMO_INSTR_TASK_DEFN_B
    where TASK_ID = X_TASK_ID
    ;
begin
  insert into GMO_INSTR_TASK_DEFN_B (
    TASK_ID,
    ENTITY_NAME,
    INSTRUCTION_TYPE,
    TASK_NAME,
    TASK_TYPE,
    TARGET,
    ATTRIBUTE_SQL,
    ATTRIBUTE_DISPLAY_COL_COUNT,
    ENTITY_KEY_PATTERN,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    MAX_ALLOWED_TASK
  ) values (
    X_TASK_ID,
    X_ENTITY_NAME,
    X_INSTRUCTION_TYPE,
    X_TASK_NAME,
    X_TASK_TYPE,
    X_TARGET,
    X_ATTRIBUTE_SQL,
    X_ATTRIBUTE_DISPLAY_COL_COUNT,
    X_ENTITY_KEY_PATTERN,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_MAX_ALLOWED_TASK
  );

  insert into GMO_INSTR_TASK_DEFN_TL (
    TASK_ID,
    DISPLAY_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TASK_ID,
    X_DISPLAY_NAME,
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
    from GMO_INSTR_TASK_DEFN_TL T
    where T.TASK_ID = X_TASK_ID
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
  X_TASK_ID in NUMBER,
  X_ENTITY_NAME in VARCHAR2,
  X_INSTRUCTION_TYPE in VARCHAR2,
  X_TASK_NAME in VARCHAR2,
  X_TASK_TYPE in VARCHAR2,
  X_TARGET in VARCHAR2,
  X_ATTRIBUTE_SQL in VARCHAR2,
  X_ATTRIBUTE_DISPLAY_COL_COUNT in NUMBER,
  X_MAX_ALLOWED_TASK in NUMBER,
  X_ENTITY_KEY_PATTERN in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2
) is
  cursor c is select
      ENTITY_NAME,
      INSTRUCTION_TYPE,
      TASK_NAME,
      TASK_TYPE,
      TARGET,
      ATTRIBUTE_SQL,
      ATTRIBUTE_DISPLAY_COL_COUNT,
      MAX_ALLOWED_TASK,
      ENTITY_KEY_PATTERN
    from GMO_INSTR_TASK_DEFN_B
    where TASK_ID = X_TASK_ID
    for update of TASK_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from GMO_INSTR_TASK_DEFN_TL
    where TASK_ID = X_TASK_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TASK_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.ENTITY_NAME = X_ENTITY_NAME)
      AND (recinfo.INSTRUCTION_TYPE = X_INSTRUCTION_TYPE)
      AND (recinfo.TASK_NAME = X_TASK_NAME)
      AND (recinfo.TASK_TYPE = X_TASK_TYPE)
      AND (recinfo.TARGET = X_TARGET)
      AND ((recinfo.ATTRIBUTE_SQL = X_ATTRIBUTE_SQL)
           OR ((recinfo.ATTRIBUTE_SQL is null) AND (X_ATTRIBUTE_SQL is null)))
      AND ((recinfo.ATTRIBUTE_DISPLAY_COL_COUNT = X_ATTRIBUTE_DISPLAY_COL_COUNT)
           OR ((recinfo.ATTRIBUTE_DISPLAY_COL_COUNT is null) AND (X_ATTRIBUTE_DISPLAY_COL_COUNT is null)))
      AND ((recinfo.MAX_ALLOWED_TASK = X_MAX_ALLOWED_TASK)
           OR ((recinfo.MAX_ALLOWED_TASK is null) AND (X_MAX_ALLOWED_TASK is null)))
      AND ((recinfo.ENTITY_KEY_PATTERN = X_ENTITY_KEY_PATTERN)
           OR ((recinfo.ENTITY_KEY_PATTERN is null) AND (X_ENTITY_KEY_PATTERN is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
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
  X_TASK_ID in NUMBER,
  X_ENTITY_NAME in VARCHAR2,
  X_INSTRUCTION_TYPE in VARCHAR2,
  X_TASK_NAME in VARCHAR2,
  X_TASK_TYPE in VARCHAR2,
  X_TARGET in VARCHAR2,
  X_ATTRIBUTE_SQL in VARCHAR2,
  X_ATTRIBUTE_DISPLAY_COL_COUNT in NUMBER,
  X_MAX_ALLOWED_TASK in NUMBER,
  X_ENTITY_KEY_PATTERN in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update GMO_INSTR_TASK_DEFN_B set
    ENTITY_NAME = X_ENTITY_NAME,
    INSTRUCTION_TYPE = X_INSTRUCTION_TYPE,
    TASK_NAME = X_TASK_NAME,
    TASK_TYPE = X_TASK_TYPE,
    TARGET = X_TARGET,
    ATTRIBUTE_SQL = X_ATTRIBUTE_SQL,
    ATTRIBUTE_DISPLAY_COL_COUNT = X_ATTRIBUTE_DISPLAY_COL_COUNT,
    MAX_ALLOWED_TASK = X_MAX_ALLOWED_TASK,
    ENTITY_KEY_PATTERN = X_ENTITY_KEY_PATTERN,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where TASK_ID = X_TASK_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update GMO_INSTR_TASK_DEFN_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TASK_ID = X_TASK_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TASK_ID in NUMBER
) is
begin
  delete from GMO_INSTR_TASK_DEFN_TL
  where TASK_ID = X_TASK_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from GMO_INSTR_TASK_DEFN_B
  where TASK_ID = X_TASK_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from GMO_INSTR_TASK_DEFN_TL T
  where not exists
    (select NULL
    from GMO_INSTR_TASK_DEFN_B B
    where B.TASK_ID = T.TASK_ID
    );

  update GMO_INSTR_TASK_DEFN_TL T set (
      DISPLAY_NAME
    ) = (select
      B.DISPLAY_NAME
    from GMO_INSTR_TASK_DEFN_TL B
    where B.TASK_ID = T.TASK_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TASK_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TASK_ID,
      SUBT.LANGUAGE
    from GMO_INSTR_TASK_DEFN_TL SUBB, GMO_INSTR_TASK_DEFN_TL SUBT
    where SUBB.TASK_ID = SUBT.TASK_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
  ));

  insert into GMO_INSTR_TASK_DEFN_TL (
    TASK_ID,
    DISPLAY_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.TASK_ID,
    B.DISPLAY_NAME,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GMO_INSTR_TASK_DEFN_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GMO_INSTR_TASK_DEFN_TL T
    where T.TASK_ID = B.TASK_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end GMO_INSTR_TASK_DEFN_PKG;

/
