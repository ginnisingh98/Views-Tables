--------------------------------------------------------
--  DDL for Package Body FUN_RICH_MESSAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_RICH_MESSAGES_PKG" as
/* $Header: FUNXTMRULRTMTBB.pls 120.0 2005/06/20 04:30:09 ammishra noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_MESSAGE_NAME in VARCHAR2,
  X_CREATED_BY_MODULE in VARCHAR2,
  X_MESSAGE_TEXT in CLOB
) is
  cursor C is select ROWID from FUN_RICH_MESSAGES_B
    where APPLICATION_ID = X_APPLICATION_ID
    and MESSAGE_NAME = X_MESSAGE_NAME;
begin
  insert into FUN_RICH_MESSAGES_B (
    APPLICATION_ID,
    MESSAGE_NAME,
    OBJECT_VERSION_NUMBER,
    CREATED_BY_MODULE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPLICATION_ID,
    X_MESSAGE_NAME,
    1,
    X_CREATED_BY_MODULE,
    FUN_RULE_UTILITY_PKG.CREATION_DATE,
    FUN_RULE_UTILITY_PKG.CREATED_BY,
    FUN_RULE_UTILITY_PKG.LAST_UPDATE_DATE,
    FUN_RULE_UTILITY_PKG.LAST_UPDATED_BY,
    FUN_RULE_UTILITY_PKG.LAST_UPDATE_LOGIN
  );

  insert into FUN_RICH_MESSAGES_TL (
    APPLICATION_ID,
    MESSAGE_NAME,
    MESSAGE_TEXT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APPLICATION_ID,
    X_MESSAGE_NAME,
    X_MESSAGE_TEXT,
    FUN_RULE_UTILITY_PKG.CREATION_DATE,
    FUN_RULE_UTILITY_PKG.CREATED_BY,
    FUN_RULE_UTILITY_PKG.LAST_UPDATE_DATE,
    FUN_RULE_UTILITY_PKG.LAST_UPDATED_BY,
    FUN_RULE_UTILITY_PKG.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FUN_RICH_MESSAGES_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.MESSAGE_NAME = X_MESSAGE_NAME
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
  X_APPLICATION_ID in NUMBER,
  X_MESSAGE_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is

  cursor c is select
      OBJECT_VERSION_NUMBER
    from FUN_RICH_MESSAGES_B
    where APPLICATION_ID = X_APPLICATION_ID
    and MESSAGE_NAME = X_MESSAGE_NAME
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;


procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_MESSAGE_NAME in VARCHAR2,
  X_CREATED_BY_MODULE in VARCHAR2,
  X_MESSAGE_TEXT in CLOB
) is
begin
  update FUN_RICH_MESSAGES_B set
    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1,
    CREATED_BY_MODULE = X_CREATED_BY_MODULE,
    LAST_UPDATE_DATE = FUN_RULE_UTILITY_PKG.LAST_UPDATE_DATE,
    LAST_UPDATED_BY = FUN_RULE_UTILITY_PKG.LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = FUN_RULE_UTILITY_PKG.LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and MESSAGE_NAME = X_MESSAGE_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FUN_RICH_MESSAGES_TL set
    MESSAGE_TEXT = X_MESSAGE_TEXT,
    LAST_UPDATE_DATE = FUN_RULE_UTILITY_PKG.LAST_UPDATE_DATE,
    LAST_UPDATED_BY = FUN_RULE_UTILITY_PKG.LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = FUN_RULE_UTILITY_PKG.LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and MESSAGE_NAME = X_MESSAGE_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_MESSAGE_NAME in VARCHAR2
) is
begin
  delete from FUN_RICH_MESSAGES_B
  where APPLICATION_ID = X_APPLICATION_ID
  and MESSAGE_NAME = X_MESSAGE_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FUN_RICH_MESSAGES_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and MESSAGE_NAME = X_MESSAGE_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;



procedure SELECT_ROW (
  X_APPLICATION_ID in out nocopy NUMBER,
  X_MESSAGE_NAME in out nocopy VARCHAR2,
  X_CREATED_BY_MODULE out nocopy VARCHAR2,
  X_MESSAGE_TEXT out nocopy CLOB
) is
begin
  SELECT created_by_module, message_text
  INTO x_created_by_module, x_message_text
  FROM fun_rich_messages_vl;
end SELECT_ROW;


procedure ADD_LANGUAGE
is
begin
  delete from FUN_RICH_MESSAGES_TL T
  where not exists
    (select NULL
    from FUN_RICH_MESSAGES_B B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.MESSAGE_NAME = T.MESSAGE_NAME
    );

  update FUN_RICH_MESSAGES_TL T set
    ( MESSAGE_TEXT )
      = (select B.MESSAGE_TEXT
         from FUN_RICH_MESSAGES_TL B
         where B.APPLICATION_ID = T.APPLICATION_ID
         and B.MESSAGE_NAME = T.MESSAGE_NAME
         and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPLICATION_ID,
      T.MESSAGE_NAME,
      T.LANGUAGE
  ) in (
      select SUBT.APPLICATION_ID,
             SUBT.MESSAGE_NAME,
             SUBT.LANGUAGE
      from FUN_RICH_MESSAGES_TL SUBB, FUN_RICH_MESSAGES_TL SUBT
      where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
      and SUBB.MESSAGE_NAME = SUBT.MESSAGE_NAME
      and SUBB.LANGUAGE = SUBT.SOURCE_LANG
--      and SUBB.MESSAGE_TEXT <> SUBT.MESSAGE_TEXT
  );


  insert into FUN_RICH_MESSAGES_TL (
    APPLICATION_ID,
    MESSAGE_NAME,
    MESSAGE_TEXT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.APPLICATION_ID,
    B.MESSAGE_NAME,
    B.MESSAGE_TEXT,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FUN_RICH_MESSAGES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FUN_RICH_MESSAGES_TL T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.MESSAGE_NAME = B.MESSAGE_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


PROCEDURE TRANSLATE_ROW(
  X_APP_SHORT_NAME in VARCHAR2,
  X_MESSAGE_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_MESSAGE_TEXT in CLOB,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2
)
IS
  appid number;

  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
BEGIN
  SELECT application_id INTO appid
  FROM fnd_application
  WHERE application_short_name = X_APP_SHORT_NAME;

  select last_updated_by, last_update_date
  into db_luby, db_ludate
  from FUN_RICH_MESSAGES_TL
  where application_id = appid
  and message_name = x_message_name
  and language = userenv('LANG');

  -- c. owners are the same, and file_date > db_date
  if (fnd_load_util.UPLOAD_TEST(
             p_file_id     => f_luby,
             p_file_lud    => f_ludate,
             p_db_id       => db_luby,
             p_db_lud      => db_ludate,
             p_custom_mode => x_custom_mode))
  then
    update FUN_RICH_MESSAGES_TL
    set message_text = nvl(x_message_text, message_text)
    where application_id = appid
    and message_name = x_message_name
    and language = userenv('LANG');
  end if;
END TRANSLATE_ROW;



procedure LOAD_ROW (
  X_APP_SHORT_NAME in VARCHAR2,
  X_MESSAGE_NAME in VARCHAR2,
  X_MESSAGE_TEXT in CLOB,
  X_OWNER                       IN VARCHAR2,
  X_LAST_UPDATE_DATE            IN VARCHAR2,
  X_CUSTOM_MODE                 IN VARCHAR2)
is
   appid number;

  row_id varchar2(64);
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

  roid number;
begin
  SELECT application_id INTO appid
  FROM fnd_application
  WHERE application_short_name = X_APP_SHORT_NAME;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  select LAST_UPDATED_BY, LAST_UPDATE_DATE
  into db_luby, db_ludate
  from FUN_RICH_MESSAGES_TL
  where APPLICATION_ID = appid
  and MESSAGE_NAME = X_MESSAGE_NAME;


  if (fnd_load_util.UPLOAD_TEST(
      p_file_id     => f_luby,
      p_file_lud    => f_ludate,
      p_db_id       => db_luby,
      p_db_lud      => db_ludate,
      p_custom_mode => x_custom_mode))
  then
    UPDATE_ROW (
      appid,
      X_MESSAGE_NAME,
      'ORACLE',
      X_MESSAGE_TEXT);
  end if;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  INSERT_ROW (
    row_id,
    appid,
    X_MESSAGE_NAME,
    'ORACLE',
    X_MESSAGE_TEXT);
end LOAD_ROW;

end FUN_RICH_MESSAGES_PKG;

/
