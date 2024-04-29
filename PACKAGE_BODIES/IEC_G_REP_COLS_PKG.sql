--------------------------------------------------------
--  DDL for Package Body IEC_G_REP_COLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_G_REP_COLS_PKG" as
/* $Header: IECREPCB.pls 115.12 2003/08/22 20:42:25 hhuang ship $ */

procedure INSERT_ROW (
  X_ROWID out nocopy VARCHAR2,
  X_COLUMN_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VALUE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_INTERNAL_COLUMN_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from IEC_G_REP_COLS_B
    where COLUMN_ID = X_COLUMN_ID
    ;
begin
  x_rowid := NULL;

  insert into IEC_G_REP_COLS_B (
    COLUMN_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_COLUMN_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into IEC_G_REP_COLS_TL (
    VALUE,
    NAME,
    INTERNAL_COLUMN_NAME,
    COLUMN_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_VALUE,
    X_NAME,
    X_INTERNAL_COLUMN_NAME,
    X_COLUMN_ID,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from IEC_G_REP_COLS_TL T
    where T.COLUMN_ID = X_COLUMN_ID
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
  X_COLUMN_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VALUE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_INTERNAL_COLUMN_NAME in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER
    from IEC_G_REP_COLS_B
    where COLUMN_ID = X_COLUMN_ID
    for update of COLUMN_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      VALUE,
      NAME,
      INTERNAL_COLUMN_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IEC_G_REP_COLS_TL
    where COLUMN_ID = X_COLUMN_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of COLUMN_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.VALUE = X_VALUE)
               OR ((tlinfo.VALUE is null) AND (X_VALUE is null)))
          AND ((tlinfo.NAME = X_NAME)
               OR ((tlinfo.NAME is null) AND (X_NAME is null)))
          AND (tlinfo.INTERNAL_COLUMN_NAME = X_INTERNAL_COLUMN_NAME)
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
  X_COLUMN_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VALUE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_INTERNAL_COLUMN_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update IEC_G_REP_COLS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where COLUMN_ID = X_COLUMN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IEC_G_REP_COLS_TL set
    VALUE = X_VALUE,
    NAME = X_NAME,
    INTERNAL_COLUMN_NAME = X_INTERNAL_COLUMN_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where COLUMN_ID = X_COLUMN_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_COLUMN_ID in NUMBER
) is
begin
  delete from IEC_G_REP_COLS_TL
  where COLUMN_ID = X_COLUMN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IEC_G_REP_COLS_B
  where COLUMN_ID = X_COLUMN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IEC_G_REP_COLS_TL T
  where not exists
    (select NULL
    from IEC_G_REP_COLS_B B
    where B.COLUMN_ID = T.COLUMN_ID
    );

  update IEC_G_REP_COLS_TL T set (
      VALUE,
      NAME,
      INTERNAL_COLUMN_NAME
    ) = (select
      B.VALUE,
      B.NAME,
      B.INTERNAL_COLUMN_NAME
    from IEC_G_REP_COLS_TL B
    where B.COLUMN_ID = T.COLUMN_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.COLUMN_ID,
      T.LANGUAGE
  ) in (select
      SUBT.COLUMN_ID,
      SUBT.LANGUAGE
    from IEC_G_REP_COLS_TL SUBB, IEC_G_REP_COLS_TL SUBT
    where SUBB.COLUMN_ID = SUBT.COLUMN_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.VALUE <> SUBT.VALUE
      or (SUBB.VALUE is null and SUBT.VALUE is not null)
      or (SUBB.VALUE is not null and SUBT.VALUE is null)
      or SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
      or SUBB.INTERNAL_COLUMN_NAME <> SUBT.INTERNAL_COLUMN_NAME
  ));

  insert into IEC_G_REP_COLS_TL (
    VALUE,
    NAME,
    INTERNAL_COLUMN_NAME,
    COLUMN_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.VALUE,
    B.NAME,
    B.INTERNAL_COLUMN_NAME,
    B.COLUMN_ID,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEC_G_REP_COLS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEC_G_REP_COLS_TL T
    where T.COLUMN_ID = B.COLUMN_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_COLUMN_ID in NUMBER,
  X_VALUE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_INTERNAL_COLUMN_NAME in VARCHAR2,
  X_OWNER in VARCHAR2
) is

  USER_ID NUMBER := 0;
  ROW_ID  VARCHAR2(500);
begin

  if (X_OWNER = 'SEED') then
    USER_ID := 1;
  end if;

  UPDATE_ROW (X_COLUMN_ID, 0, X_VALUE, X_NAME, X_INTERNAL_COLUMN_NAME, SYSDATE, USER_ID, 0);

exception
  when no_data_found then
    INSERT_ROW (ROW_ID, X_COLUMN_ID, 0, X_VALUE, X_NAME, X_INTERNAL_COLUMN_NAME, SYSDATE, USER_ID, SYSDATE, USER_ID, 0);

end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_COLUMN_ID in NUMBER,
  X_VALUE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_INTERNAL_COLUMN_NAME in VARCHAR2,
  X_OWNER in VARCHAR2
) is
begin

  -- only UPDATE rows that have not been altered by user

  update IEC_G_REP_COLS_TL set
  VALUE = X_VALUE,
  SOURCE_LANG = userenv('LANG'),
  NAME = X_NAME,
  INTERNAL_COLUMN_NAME = X_INTERNAL_COLUMN_NAME,
  LAST_UPDATE_DATE = SYSDATE,
  LAST_UPDATED_BY = DECODE(X_OWNER, 'SEED', 1, 0),
  LAST_UPDATE_LOGIN = 0
  where COLUMN_ID = X_COLUMN_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

end TRANSLATE_ROW;

end IEC_G_REP_COLS_PKG;

/
