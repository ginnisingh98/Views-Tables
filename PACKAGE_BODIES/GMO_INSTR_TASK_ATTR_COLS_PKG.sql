--------------------------------------------------------
--  DDL for Package Body GMO_INSTR_TASK_ATTR_COLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_INSTR_TASK_ATTR_COLS_PKG" as
/* $Header: GMOTSACB.pls 120.1 2005/06/29 07:03 shthakke noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_ATTR_COL_SEQ in NUMBER,
  X_TASK_NAME in VARCHAR2,
  X_COLUMN_NO in NUMBER,
  X_ENTITY_NAME in VARCHAR2,
  X_COLUMN_HEADING in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from GMO_INSTR_TASK_ATTR_COLS_B
    where ATTR_COL_SEQ = X_ATTR_COL_SEQ
    ;
begin
  insert into GMO_INSTR_TASK_ATTR_COLS_B (
    TASK_NAME,
    COLUMN_NO,
    ATTR_COL_SEQ,
    ENTITY_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_TASK_NAME,
    X_COLUMN_NO,
    X_ATTR_COL_SEQ,
    X_ENTITY_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

 insert into GMO_INSTR_TASK_ATTR_COLS_TL (
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    ATTR_COL_SEQ,
    COLUMN_HEADING,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_ATTR_COL_SEQ,
    X_COLUMN_HEADING,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from GMO_INSTR_TASK_ATTR_COLS_TL T
    where T.ATTR_COL_SEQ = X_ATTR_COL_SEQ
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
  X_ATTR_COL_SEQ in NUMBER,
  X_TASK_NAME in VARCHAR2,
  X_COLUMN_NO in NUMBER,
  X_ENTITY_NAME in VARCHAR2,
  X_COLUMN_HEADING in VARCHAR2
) is
  cursor c is select
      TASK_NAME,
      COLUMN_NO,
      ENTITY_NAME
    from GMO_INSTR_TASK_ATTR_COLS_B
    where ATTR_COL_SEQ = X_ATTR_COL_SEQ
    for update of ATTR_COL_SEQ nowait;
  recinfo c%rowtype;

  cursor c1 is select
      COLUMN_HEADING,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from GMO_INSTR_TASK_ATTR_COLS_TL
    where ATTR_COL_SEQ = X_ATTR_COL_SEQ
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ATTR_COL_SEQ nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.TASK_NAME = X_TASK_NAME)
      AND (recinfo.COLUMN_NO = X_COLUMN_NO)
      AND (recinfo.ENTITY_NAME = X_ENTITY_NAME)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.COLUMN_HEADING = X_COLUMN_HEADING)
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
  X_ATTR_COL_SEQ in NUMBER,
  X_TASK_NAME in VARCHAR2,
  X_COLUMN_NO in NUMBER,
  X_ENTITY_NAME in VARCHAR2,
  X_COLUMN_HEADING in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update GMO_INSTR_TASK_ATTR_COLS_B set
    TASK_NAME = X_TASK_NAME,
    COLUMN_NO = X_COLUMN_NO,
    ENTITY_NAME = X_ENTITY_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ATTR_COL_SEQ = X_ATTR_COL_SEQ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update GMO_INSTR_TASK_ATTR_COLS_TL set
    COLUMN_HEADING = X_COLUMN_HEADING,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ATTR_COL_SEQ = X_ATTR_COL_SEQ
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ATTR_COL_SEQ in NUMBER
) is
begin
  delete from GMO_INSTR_TASK_ATTR_COLS_TL
  where ATTR_COL_SEQ = X_ATTR_COL_SEQ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from GMO_INSTR_TASK_ATTR_COLS_B
  where ATTR_COL_SEQ = X_ATTR_COL_SEQ;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from GMO_INSTR_TASK_ATTR_COLS_TL T
  where not exists
    (select NULL
    from GMO_INSTR_TASK_ATTR_COLS_B B
    where B.ATTR_COL_SEQ = T.ATTR_COL_SEQ
    );

  update GMO_INSTR_TASK_ATTR_COLS_TL T set (
      COLUMN_HEADING
    ) = (select
      B.COLUMN_HEADING
    from GMO_INSTR_TASK_ATTR_COLS_TL B
    where B.ATTR_COL_SEQ = T.ATTR_COL_SEQ
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ATTR_COL_SEQ,
      T.LANGUAGE
  ) in (select
      SUBT.ATTR_COL_SEQ,
      SUBT.LANGUAGE
    from GMO_INSTR_TASK_ATTR_COLS_TL SUBB, GMO_INSTR_TASK_ATTR_COLS_TL SUBT
    where SUBB.ATTR_COL_SEQ = SUBT.ATTR_COL_SEQ
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.COLUMN_HEADING <> SUBT.COLUMN_HEADING
  ));

  insert into GMO_INSTR_TASK_ATTR_COLS_TL (
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    ATTR_COL_SEQ,
    COLUMN_HEADING,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.ATTR_COL_SEQ,
    B.COLUMN_HEADING,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GMO_INSTR_TASK_ATTR_COLS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GMO_INSTR_TASK_ATTR_COLS_TL T
    where T.ATTR_COL_SEQ = B.ATTR_COL_SEQ
    and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;

end GMO_INSTR_TASK_ATTR_COLS_PKG;

/
