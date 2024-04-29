--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_MGMT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_MGMT_TYPES_PKG" as
/* $Header: ENGTYPEB.pls 115.2 2002/12/03 19:43:12 sshrikha noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CHANGE_MGMT_TYPE_CODE in VARCHAR2,
  X_ENABLE_REV_ITEMS_FLAG in VARCHAR2,
  X_ENABLE_TASKS_FLAG in VARCHAR2,
  X_DISABLE_FLAG in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TAB_TEXT in VARCHAR2,
  X_FORM_FUNCTION_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ENG_CHANGE_MGMT_TYPES
    where CHANGE_MGMT_TYPE_CODE = X_CHANGE_MGMT_TYPE_CODE
    ;
begin
  insert into ENG_CHANGE_MGMT_TYPES (
    ENABLE_REV_ITEMS_FLAG,
    ENABLE_TASKS_FLAG,
    DISABLE_FLAG,
    CHANGE_MGMT_TYPE_CODE,
    SEQUENCE_NUMBER,
    FORM_FUNCTION_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ENABLE_REV_ITEMS_FLAG,
    X_ENABLE_TASKS_FLAG,
    X_DISABLE_FLAG,
    X_CHANGE_MGMT_TYPE_CODE,
    X_SEQUENCE_NUMBER,
    X_FORM_FUNCTION_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into ENG_CHANGE_MGMT_TYPES_TL (
    TAB_TEXT,
    NAME,
    CHANGE_MGMT_TYPE_CODE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TAB_TEXT,
    X_NAME,
    X_CHANGE_MGMT_TYPE_CODE,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from ENG_CHANGE_MGMT_TYPES_TL T
    where T.CHANGE_MGMT_TYPE_CODE = X_CHANGE_MGMT_TYPE_CODE
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
  X_CHANGE_MGMT_TYPE_CODE in VARCHAR2,
  X_ENABLE_REV_ITEMS_FLAG in VARCHAR2,
  X_ENABLE_TASKS_FLAG in VARCHAR2,
  X_DISABLE_FLAG in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TAB_TEXT in VARCHAR2,
  X_FORM_FUNCTION_NAME in VARCHAR2
)
 is
  cursor c is select
      ENABLE_REV_ITEMS_FLAG,
      ENABLE_TASKS_FLAG,
      DISABLE_FLAG,
      SEQUENCE_NUMBER,
      FORM_FUNCTION_NAME
    from ENG_CHANGE_MGMT_TYPES
    where CHANGE_MGMT_TYPE_CODE = X_CHANGE_MGMT_TYPE_CODE
    for update of CHANGE_MGMT_TYPE_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      TAB_TEXT,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ENG_CHANGE_MGMT_TYPES_TL
    where CHANGE_MGMT_TYPE_CODE = X_CHANGE_MGMT_TYPE_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CHANGE_MGMT_TYPE_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ENABLE_REV_ITEMS_FLAG = X_ENABLE_REV_ITEMS_FLAG)
           OR ((recinfo.ENABLE_REV_ITEMS_FLAG is null) AND (X_ENABLE_REV_ITEMS_FLAG is null)))
      AND ((recinfo.ENABLE_TASKS_FLAG = X_ENABLE_TASKS_FLAG)
           OR ((recinfo.ENABLE_TASKS_FLAG is null) AND (X_ENABLE_TASKS_FLAG is null)))
      AND ((recinfo.DISABLE_FLAG = X_DISABLE_FLAG)
           OR ((recinfo.DISABLE_FLAG is null) AND (X_DISABLE_FLAG is null)))
      AND ((recinfo.SEQUENCE_NUMBER = X_SEQUENCE_NUMBER)
           OR ((recinfo.SEQUENCE_NUMBER is null) AND (X_SEQUENCE_NUMBER is null)))
      AND ((recinfo.FORM_FUNCTION_NAME = X_FORM_FUNCTION_NAME)
           OR ((recinfo.FORM_FUNCTION_NAME is null) AND (X_FORM_FUNCTION_NAME is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.NAME = X_NAME)
               OR ((tlinfo.NAME is null) AND (X_NAME is null)))
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
          AND ((tlinfo.TAB_TEXT = X_TAB_TEXT)
               OR ((tlinfo.TAB_TEXT is null) AND (X_TAB_TEXT is null)))
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
  X_CHANGE_MGMT_TYPE_CODE in VARCHAR2,
  X_ENABLE_REV_ITEMS_FLAG in VARCHAR2,
  X_ENABLE_TASKS_FLAG in VARCHAR2,
  X_DISABLE_FLAG in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TAB_TEXT in VARCHAR2,
  X_FORM_FUNCTION_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
)
 is
begin
  update ENG_CHANGE_MGMT_TYPES set
    ENABLE_REV_ITEMS_FLAG = X_ENABLE_REV_ITEMS_FLAG,
    ENABLE_TASKS_FLAG = X_ENABLE_TASKS_FLAG,
    DISABLE_FLAG = X_DISABLE_FLAG,
    SEQUENCE_NUMBER = X_SEQUENCE_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    FORM_FUNCTION_NAME = X_FORM_FUNCTION_NAME
  where CHANGE_MGMT_TYPE_CODE = X_CHANGE_MGMT_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update ENG_CHANGE_MGMT_TYPES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    TAB_TEXT = X_TAB_TEXT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CHANGE_MGMT_TYPE_CODE = X_CHANGE_MGMT_TYPE_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CHANGE_MGMT_TYPE_CODE in VARCHAR2
) is
begin
  delete from ENG_CHANGE_MGMT_TYPES_TL
  where CHANGE_MGMT_TYPE_CODE = X_CHANGE_MGMT_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from ENG_CHANGE_MGMT_TYPES
  where CHANGE_MGMT_TYPE_CODE = X_CHANGE_MGMT_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from ENG_CHANGE_MGMT_TYPES_TL T
  where not exists
    (select NULL
    from ENG_CHANGE_MGMT_TYPES B
    where B.CHANGE_MGMT_TYPE_CODE = T.CHANGE_MGMT_TYPE_CODE
    );

  update ENG_CHANGE_MGMT_TYPES_TL T set (
      NAME,
      DESCRIPTION,
      TAB_TEXT
    ) = (select
      B.NAME,
      B.DESCRIPTION,
      B.TAB_TEXT
    from ENG_CHANGE_MGMT_TYPES_TL B
    where B.CHANGE_MGMT_TYPE_CODE = T.CHANGE_MGMT_TYPE_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CHANGE_MGMT_TYPE_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.CHANGE_MGMT_TYPE_CODE,
      SUBT.LANGUAGE
    from ENG_CHANGE_MGMT_TYPES_TL SUBB, ENG_CHANGE_MGMT_TYPES_TL SUBT
    where SUBB.CHANGE_MGMT_TYPE_CODE = SUBT.CHANGE_MGMT_TYPE_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
      or SUBB.TAB_TEXT <> SUBT.TAB_TEXT
      or (SUBB.TAB_TEXT is null and SUBT.TAB_TEXT is not null)
      or (SUBB.TAB_TEXT is not null and SUBT.TAB_TEXT is null)
  ));

  insert into ENG_CHANGE_MGMT_TYPES_TL (
    TAB_TEXT,
    NAME,
    CHANGE_MGMT_TYPE_CODE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TAB_TEXT,
    B.NAME,
    B.CHANGE_MGMT_TYPE_CODE,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ENG_CHANGE_MGMT_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ENG_CHANGE_MGMT_TYPES_TL T
    where T.CHANGE_MGMT_TYPE_CODE = B.CHANGE_MGMT_TYPE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end ENG_CHANGE_MGMT_TYPES_PKG;

/
