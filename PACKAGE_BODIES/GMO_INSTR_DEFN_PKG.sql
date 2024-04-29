--------------------------------------------------------
--  DDL for Package Body GMO_INSTR_DEFN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_INSTR_DEFN_PKG" as
/* $Header: GMOINDPB.pls 120.1 2005/06/29 07:02 shthakke noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_INSTRUCTION_ID in NUMBER,
  X_INSTRUCTION_SET_ID in NUMBER,
  X_INSTR_SEQ in NUMBER,
  X_TASK_ID in NUMBER,
  X_TASK_ATTRIBUTE_ID in VARCHAR2,
  X_TASK_ATTRIBUTE in VARCHAR2,
  X_INSTR_ACKN_TYPE in VARCHAR2,
  X_INSTR_NUMBER in VARCHAR2,
  X_INSTRUCTION_TEXT in VARCHAR2,
  X_TASK_LABEL in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from GMO_INSTR_DEFN_B
    where INSTRUCTION_ID = X_INSTRUCTION_ID
    ;
begin
  insert into GMO_INSTR_DEFN_B (
    INSTRUCTION_ID,
    INSTRUCTION_SET_ID,
    INSTR_SEQ,
    TASK_ID,
    TASK_ATTRIBUTE_ID,
    TASK_ATTRIBUTE,
    INSTR_ACKN_TYPE,
    INSTR_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_INSTRUCTION_ID,
    X_INSTRUCTION_SET_ID,
    X_INSTR_SEQ,
    X_TASK_ID,
    X_TASK_ATTRIBUTE_ID,
    X_TASK_ATTRIBUTE,
    X_INSTR_ACKN_TYPE,
    X_INSTR_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into GMO_INSTR_DEFN_TL (
    TASK_LABEL,
    INSTRUCTION_ID,
    INSTRUCTION_TEXT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TASK_LABEL,
    X_INSTRUCTION_ID,
    X_INSTRUCTION_TEXT,
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
    from GMO_INSTR_DEFN_TL T
    where T.INSTRUCTION_ID = X_INSTRUCTION_ID
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
  X_INSTRUCTION_ID in NUMBER,
  X_INSTRUCTION_SET_ID in NUMBER,
  X_INSTR_SEQ in NUMBER,
  X_TASK_ID in NUMBER,
  X_TASK_ATTRIBUTE_ID in VARCHAR2,
  X_TASK_ATTRIBUTE in VARCHAR2,
  X_INSTR_ACKN_TYPE in VARCHAR2,
  X_INSTR_NUMBER in VARCHAR2,
  X_INSTRUCTION_TEXT in VARCHAR2,
  X_TASK_LABEL in VARCHAR2
) is
  cursor c is select
      INSTRUCTION_SET_ID,
      INSTR_SEQ,
      TASK_ID,
      TASK_ATTRIBUTE_ID,
      TASK_ATTRIBUTE,
      INSTR_ACKN_TYPE,
      INSTR_NUMBER
    from GMO_INSTR_DEFN_B
    where INSTRUCTION_ID = X_INSTRUCTION_ID
    for update of INSTRUCTION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      INSTRUCTION_TEXT,
      TASK_LABEL,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from GMO_INSTR_DEFN_TL
    where INSTRUCTION_ID = X_INSTRUCTION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of INSTRUCTION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.INSTRUCTION_SET_ID = X_INSTRUCTION_SET_ID)
      AND (recinfo.INSTR_SEQ = X_INSTR_SEQ)
      AND ((recinfo.TASK_ID = X_TASK_ID)
           OR ((recinfo.TASK_ID is null) AND (X_TASK_ID is null)))
      AND ((recinfo.TASK_ATTRIBUTE_ID = X_TASK_ATTRIBUTE_ID)
           OR ((recinfo.TASK_ATTRIBUTE_ID is null) AND (X_TASK_ATTRIBUTE_ID is null)))
      AND ((recinfo.TASK_ATTRIBUTE = X_TASK_ATTRIBUTE)
           OR ((recinfo.TASK_ATTRIBUTE is null) AND (X_TASK_ATTRIBUTE is null)))
      AND ((recinfo.INSTR_ACKN_TYPE = X_INSTR_ACKN_TYPE)
           OR ((recinfo.INSTR_ACKN_TYPE is null) AND (X_INSTR_ACKN_TYPE is null)))
      AND ((recinfo.INSTR_NUMBER = X_INSTR_NUMBER)
           OR ((recinfo.INSTR_NUMBER is null) AND (X_INSTR_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.INSTRUCTION_TEXT = X_INSTRUCTION_TEXT)
               OR ((tlinfo.INSTRUCTION_TEXT is null) AND (X_INSTRUCTION_TEXT is null)))
          AND ((tlinfo.TASK_LABEL = X_TASK_LABEL)
               OR ((tlinfo.TASK_LABEL is null) AND (X_TASK_LABEL is null)))
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
  X_INSTRUCTION_ID in NUMBER,
  X_INSTRUCTION_SET_ID in NUMBER,
  X_INSTR_SEQ in NUMBER,
  X_TASK_ID in NUMBER,
  X_TASK_ATTRIBUTE_ID in VARCHAR2,
  X_TASK_ATTRIBUTE in VARCHAR2,
  X_INSTR_ACKN_TYPE in VARCHAR2,
  X_INSTR_NUMBER in VARCHAR2,
  X_INSTRUCTION_TEXT in VARCHAR2,
  X_TASK_LABEL in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update GMO_INSTR_DEFN_B set
    INSTRUCTION_SET_ID = X_INSTRUCTION_SET_ID,
    INSTR_SEQ = X_INSTR_SEQ,
    TASK_ID = X_TASK_ID,
    TASK_ATTRIBUTE_ID = X_TASK_ATTRIBUTE_ID,
    TASK_ATTRIBUTE = X_TASK_ATTRIBUTE,
    INSTR_ACKN_TYPE = X_INSTR_ACKN_TYPE,
    INSTR_NUMBER = X_INSTR_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where INSTRUCTION_ID = X_INSTRUCTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update GMO_INSTR_DEFN_TL set
    INSTRUCTION_TEXT = X_INSTRUCTION_TEXT,
    TASK_LABEL = X_TASK_LABEL,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where INSTRUCTION_ID = X_INSTRUCTION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_INSTRUCTION_ID in NUMBER
) is
begin
  delete from GMO_INSTR_DEFN_TL
  where INSTRUCTION_ID = X_INSTRUCTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from GMO_INSTR_DEFN_B
  where INSTRUCTION_ID = X_INSTRUCTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from GMO_INSTR_DEFN_TL T
  where not exists
    (select NULL
    from GMO_INSTR_DEFN_B B
    where B.INSTRUCTION_ID = T.INSTRUCTION_ID
    );

  update GMO_INSTR_DEFN_TL T set (
      INSTRUCTION_TEXT,
      TASK_LABEL
    ) = (select
      B.INSTRUCTION_TEXT,
      B.TASK_LABEL
    from GMO_INSTR_DEFN_TL B
    where B.INSTRUCTION_ID = T.INSTRUCTION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.INSTRUCTION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.INSTRUCTION_ID,
      SUBT.LANGUAGE
    from GMO_INSTR_DEFN_TL SUBB, GMO_INSTR_DEFN_TL SUBT
    where SUBB.INSTRUCTION_ID = SUBT.INSTRUCTION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.INSTRUCTION_TEXT <> SUBT.INSTRUCTION_TEXT
      or (SUBB.INSTRUCTION_TEXT is null and SUBT.INSTRUCTION_TEXT is not null)
      or (SUBB.INSTRUCTION_TEXT is not null and SUBT.INSTRUCTION_TEXT is null)
      or SUBB.TASK_LABEL <> SUBT.TASK_LABEL
      or (SUBB.TASK_LABEL is null and SUBT.TASK_LABEL is not null)
      or (SUBB.TASK_LABEL is not null and SUBT.TASK_LABEL is null)
  ));

  insert into GMO_INSTR_DEFN_TL (
    TASK_LABEL,
    INSTRUCTION_ID,
    INSTRUCTION_TEXT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.TASK_LABEL,
    B.INSTRUCTION_ID,
    B.INSTRUCTION_TEXT,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GMO_INSTR_DEFN_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GMO_INSTR_DEFN_TL T
    where T.INSTRUCTION_ID = B.INSTRUCTION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end GMO_INSTR_DEFN_PKG;

/
