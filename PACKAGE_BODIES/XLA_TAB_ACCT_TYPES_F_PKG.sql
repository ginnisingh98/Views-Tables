--------------------------------------------------------
--  DDL for Package Body XLA_TAB_ACCT_TYPES_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_TAB_ACCT_TYPES_F_PKG" AS
/* $Header: xlathtabact.pkb 120.6.12010000.1 2008/07/29 10:10:36 appldev ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_tab_acct_types                                                 |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_tab_acct_types                        |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|    01-SEP-2005 Jorge Larre                                            |
|       Add procedure translate_row and load_row to use with FNDLOAD in |
|       conjunction with the file xlatabseed.lct. Bug 4590464.          |
|                                                                       |
+======================================================================*/

--=======================================================================
--               *********** Local Trace Routine **********
--=======================================================================
C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_acctg_methods_f_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
  (p_msg                        IN VARCHAR2
  ,p_module                     IN VARCHAR2
  ,p_level                      IN NUMBER) IS
BEGIN
  ------------------------------------------------------------------------
  -- Following is for FND log.
  ------------------------------------------------------------------------
  IF (p_msg IS NULL AND p_level >= g_log_level) THEN
    fnd_log.message(p_level, p_module);
  ELSIF p_level >= g_log_level THEN
    fnd_log.string(p_level, p_module, p_msg);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;

  WHEN OTHERS THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_acctg_methods_f_pkg.trace');
END trace;


/*======================================================================+
|                                                                       |
|  Procedure insert_row                                                 |
|                                                                       |
+======================================================================*/

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ACCOUNT_TYPE_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_RULE_ASSIGNMENT_CODE in VARCHAR2,
  X_COMPILE_STATUS_CODE in VARCHAR2,
  X_OBJECT_NAME_AFFIX in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from XLA_TAB_ACCT_TYPES_B
    where APPLICATION_ID = X_APPLICATION_ID
    and ACCOUNT_TYPE_CODE = X_ACCOUNT_TYPE_CODE
    ;
begin
  insert into XLA_TAB_ACCT_TYPES_B (
    APPLICATION_ID,
    ACCOUNT_TYPE_CODE,
    ENABLED_FLAG,
    RULE_ASSIGNMENT_CODE,
    COMPILE_STATUS_CODE,
    OBJECT_NAME_AFFIX,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPLICATION_ID,
    X_ACCOUNT_TYPE_CODE,
    X_ENABLED_FLAG,
    X_RULE_ASSIGNMENT_CODE,
    X_COMPILE_STATUS_CODE,
    X_OBJECT_NAME_AFFIX,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into XLA_TAB_ACCT_TYPES_TL (
    APPLICATION_ID,
    ACCOUNT_TYPE_CODE,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APPLICATION_ID,
    X_ACCOUNT_TYPE_CODE,
    X_NAME,
    X_DESCRIPTION,
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
    from XLA_TAB_ACCT_TYPES_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.ACCOUNT_TYPE_CODE = X_ACCOUNT_TYPE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;


/*======================================================================+
|                                                                       |
|  Procedure lock_row                                                   |
|                                                                       |
+======================================================================*/

procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ACCOUNT_TYPE_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_RULE_ASSIGNMENT_CODE in VARCHAR2,
  X_COMPILE_STATUS_CODE in VARCHAR2,
  X_OBJECT_NAME_AFFIX in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ENABLED_FLAG,
      RULE_ASSIGNMENT_CODE,
      COMPILE_STATUS_CODE,
      OBJECT_NAME_AFFIX
    from XLA_TAB_ACCT_TYPES_B
    where APPLICATION_ID = X_APPLICATION_ID
    and ACCOUNT_TYPE_CODE = X_ACCOUNT_TYPE_CODE
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from XLA_TAB_ACCT_TYPES_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and ACCOUNT_TYPE_CODE = X_ACCOUNT_TYPE_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of APPLICATION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.RULE_ASSIGNMENT_CODE = X_RULE_ASSIGNMENT_CODE)
      AND (    (recinfo.COMPILE_STATUS_CODE = X_COMPILE_STATUS_CODE)
            OR (recinfo.COMPILE_STATUS_CODE IS NULL AND X_COMPILE_STATUS_CODE IS NULL)
          )
      AND (    (recinfo.OBJECT_NAME_AFFIX = X_OBJECT_NAME_AFFIX)
            OR (recinfo.OBJECT_NAME_AFFIX IS NULL AND X_OBJECT_NAME_AFFIX IS NULL)
          )
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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


/*======================================================================+
|                                                                       |
|  Procedure update_row                                                 |
|                                                                       |
+======================================================================*/

procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ACCOUNT_TYPE_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_RULE_ASSIGNMENT_CODE in VARCHAR2,
  X_COMPILE_STATUS_CODE in VARCHAR2,
  X_OBJECT_NAME_AFFIX in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update XLA_TAB_ACCT_TYPES_B set
    ENABLED_FLAG = X_ENABLED_FLAG,
    RULE_ASSIGNMENT_CODE = X_RULE_ASSIGNMENT_CODE,
    COMPILE_STATUS_CODE  = X_COMPILE_STATUS_CODE,
    OBJECT_NAME_AFFIX    = X_OBJECT_NAME_AFFIX,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and ACCOUNT_TYPE_CODE = X_ACCOUNT_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update XLA_TAB_ACCT_TYPES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and ACCOUNT_TYPE_CODE = X_ACCOUNT_TYPE_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


/*======================================================================+
|                                                                       |
|  Procedure delete_row                                                 |
|                                                                       |
+======================================================================*/
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ACCOUNT_TYPE_CODE in VARCHAR2
) is
begin
  delete from XLA_TAB_ACCT_TYPES_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and ACCOUNT_TYPE_CODE = X_ACCOUNT_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from XLA_TAB_ACCT_TYPES_B
  where APPLICATION_ID = X_APPLICATION_ID
  and ACCOUNT_TYPE_CODE = X_ACCOUNT_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


/*======================================================================+
|                                                                       |
|  Procedure add_language                                               |
|                                                                       |
+======================================================================*/

procedure ADD_LANGUAGE
is
begin
  delete from XLA_TAB_ACCT_TYPES_TL T
  where not exists
    (select NULL
    from XLA_TAB_ACCT_TYPES_B B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.ACCOUNT_TYPE_CODE = T.ACCOUNT_TYPE_CODE
    );

  update XLA_TAB_ACCT_TYPES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from XLA_TAB_ACCT_TYPES_TL B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.ACCOUNT_TYPE_CODE = T.ACCOUNT_TYPE_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPLICATION_ID,
      T.ACCOUNT_TYPE_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.APPLICATION_ID,
      SUBT.ACCOUNT_TYPE_CODE,
      SUBT.LANGUAGE
    from XLA_TAB_ACCT_TYPES_TL SUBB, XLA_TAB_ACCT_TYPES_TL SUBT
    where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.ACCOUNT_TYPE_CODE = SUBT.ACCOUNT_TYPE_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into XLA_TAB_ACCT_TYPES_TL (
    APPLICATION_ID,
    ACCOUNT_TYPE_CODE,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.APPLICATION_ID,
    B.ACCOUNT_TYPE_CODE,
    B.NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from XLA_TAB_ACCT_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from XLA_TAB_ACCT_TYPES_TL T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.ACCOUNT_TYPE_CODE = B.ACCOUNT_TYPE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

/*======================================================================+
|                                                                       |
|  Procedure translate_row                                              |
|  To be used by FNDLOAD                                                |
|                                                                       |
+======================================================================*/
PROCEDURE translate_row
  (p_application_short_name      IN VARCHAR2
  ,p_account_type_code           IN VARCHAR2
  ,p_name                        IN VARCHAR2
  ,p_description                 IN VARCHAR2
  ,p_owner                       IN VARCHAR2
  ,p_last_update_date            IN VARCHAR2
  ,p_custom_mode                 IN VARCHAR2)
IS
  CURSOR c_app_id IS
  SELECT application_id
  FROM   fnd_application
  WHERE  application_short_name          = p_application_short_name;

  l_application_id        INTEGER;
  l_rowid                 ROWID;
  l_exist                 VARCHAR2(1);
  f_luby                  NUMBER;      -- entity owner in file
  f_ludate                DATE;        -- entity update date in file
  db_luby                 NUMBER;      -- entity owner in db
  db_ludate               DATE;        -- entity update date in db
  l_log_module            VARCHAR2(240);
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.translate_row';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure translate_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(p_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

  OPEN c_app_id;
  FETCH c_app_id INTO l_application_id;
  CLOSE c_app_id;

  BEGIN
    SELECT last_updated_by, last_update_date
      INTO db_luby, db_ludate
      FROM xla_tab_acct_types_tl
     WHERE application_id               = l_application_id
       AND account_type_code            = p_account_type_code
       AND language                     = userenv('LANG');

    IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                               db_ludate, p_custom_mode)) then
      UPDATE xla_tab_acct_types_tl
         SET name                   = p_name
            ,description            = p_description
            ,last_update_date       = f_ludate
            ,last_updated_by        = f_luby
            ,last_update_login      = 0
            ,source_lang            = userenv('LANG')
       WHERE userenv('LANG')        IN (language, source_lang)
         AND application_id         = l_application_id
         AND account_type_code      = p_account_type_code;

    END IF;



  END;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure translate_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;



END translate_row;

/*======================================================================+
|                                                                       |
|  Procedure load_row                                                   |
|  To be used by FNDLOAD                                                |
|                                                                       |
+======================================================================*/
PROCEDURE load_row
  (p_application_short_name      IN VARCHAR2
  ,p_account_type_code           IN VARCHAR2
  ,p_enabled_flag                IN VARCHAR2
  ,p_rule_assignment_code        IN VARCHAR2
  ,p_compile_status_code         IN VARCHAR2
  ,p_object_name_affix           IN VARCHAR2
  ,p_name                        IN VARCHAR2
  ,p_description                 IN VARCHAR2
  ,p_owner                       IN VARCHAR2
  ,p_last_update_date            IN VARCHAR2)

IS
  CURSOR c_app_id IS
  SELECT application_id
  FROM   fnd_application
  WHERE  application_short_name          = p_application_short_name;

  l_application_id        INTEGER;
  l_rowid                 ROWID;
  l_exist                 VARCHAR2(1);
  f_luby                  NUMBER;      -- entity owner in file
  f_ludate                DATE;        -- entity update date in file
  db_luby                 NUMBER;      -- entity owner in db
  db_ludate               DATE;        -- entity update date in db
  l_log_module            VARCHAR2(240);
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.load_row';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure load_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(p_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

  OPEN c_app_id;
  FETCH c_app_id INTO l_application_id;
  CLOSE c_app_id;

  BEGIN

    SELECT last_updated_by, last_update_date
      INTO db_luby, db_ludate
      FROM xla_tab_acct_types_vl
     WHERE application_id               = l_application_id
       AND account_type_code         = p_account_type_code;

    IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, NULL)) THEN
      xla_tab_acct_types_f_pkg.update_row
          (x_application_id                => l_application_id
          ,x_account_type_code             => p_account_type_code
          ,x_enabled_flag                  => p_enabled_flag
          ,x_rule_assignment_code          => p_rule_assignment_code
          ,x_compile_status_code           => p_compile_status_code
          ,x_object_name_affix             => p_object_name_affix
          ,x_name                          => p_name
          ,x_description                   => p_description
          ,x_last_update_date              => f_ludate
          ,x_last_updated_by               => f_luby
          ,x_last_update_login             => 0);

    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      xla_tab_acct_types_f_pkg.insert_row
          (x_rowid                         => l_rowid
          ,x_application_id                => l_application_id
          ,x_account_type_code             => p_account_type_code
          ,x_enabled_flag                  => p_enabled_flag
          ,x_rule_assignment_code          => p_rule_assignment_code
          ,x_compile_status_code           => p_compile_status_code
          ,x_object_name_affix             => p_object_name_affix
          ,x_name                          => p_name
          ,x_description                   => p_description
          ,x_creation_date                 => f_ludate
          ,x_created_by                    => f_luby
          ,x_last_update_date              => f_ludate
          ,x_last_updated_by               => f_luby
          ,x_last_update_login             => 0);
  END;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure load_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      null;
   WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_tab_acct_types_f_pkg.load_row');

END load_row;

end xla_tab_acct_types_f_pkg;

/
