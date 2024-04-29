--------------------------------------------------------
--  DDL for Package Body XLA_TAB_ACCT_DEFS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_TAB_ACCT_DEFS_F_PKG" AS
/* $Header: xlathtabacd.pkb 120.2 2003/10/02 01:57:54 dcshah noship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_tab_acct_defs                                                  |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_tab_acct_defs                         |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|                                                                       |
+======================================================================*/



/*======================================================================+
|                                                                       |
|  Procedure insert_row                                                 |
|                                                                       |
+======================================================================*/
procedure INSERT_ROW (
  X_ROWID                        in out NOCOPY VARCHAR2,
  X_APPLICATION_ID               in NUMBER,
  X_AMB_CONTEXT_CODE             in VARCHAR2,
  X_ACCOUNT_DEFINITION_TYPE_CODE in VARCHAR2,
  X_ACCOUNT_DEFINITION_CODE      in VARCHAR2,
  X_REQUEST_ID                   in NUMBER,
  X_CHART_OF_ACCOUNTS_ID         in NUMBER,
  X_COMPILE_STATUS_CODE          in VARCHAR2,
  X_LOCKING_STATUS_FLAG          in VARCHAR2,
  X_ENABLED_FLAG                 in VARCHAR2,
  X_NAME                         in VARCHAR2,
  X_DESCRIPTION                  in VARCHAR2,
  X_CREATION_DATE                in DATE,
  X_CREATED_BY                   in NUMBER,
  X_LAST_UPDATE_DATE             in DATE,
  X_LAST_UPDATED_BY              in NUMBER,
  X_LAST_UPDATE_LOGIN            in NUMBER
) is

  cursor C is
  select ROWID from XLA_TAB_ACCT_DEFS_B
    where APPLICATION_ID = X_APPLICATION_ID
    and AMB_CONTEXT_CODE = X_AMB_CONTEXT_CODE
    and ACCOUNT_DEFINITION_TYPE_CODE = X_ACCOUNT_DEFINITION_TYPE_CODE
    and ACCOUNT_DEFINITION_CODE = X_ACCOUNT_DEFINITION_CODE
    ;

BEGIN

  insert into XLA_TAB_ACCT_DEFS_B (
    AMB_CONTEXT_CODE,
    REQUEST_ID,
    APPLICATION_ID,
    ACCOUNT_DEFINITION_TYPE_CODE,
    ACCOUNT_DEFINITION_CODE,
    CHART_OF_ACCOUNTS_ID,
    COMPILE_STATUS_CODE,
    LOCKING_STATUS_FLAG,
    ENABLED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_AMB_CONTEXT_CODE,
    X_REQUEST_ID,
    X_APPLICATION_ID,
    X_ACCOUNT_DEFINITION_TYPE_CODE,
    X_ACCOUNT_DEFINITION_CODE,
    X_CHART_OF_ACCOUNTS_ID,
    X_COMPILE_STATUS_CODE,
    X_LOCKING_STATUS_FLAG,
    X_ENABLED_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into XLA_TAB_ACCT_DEFS_TL (
    APPLICATION_ID,
    ACCOUNT_DEFINITION_TYPE_CODE,
    ACCOUNT_DEFINITION_CODE,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    AMB_CONTEXT_CODE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APPLICATION_ID,
    X_ACCOUNT_DEFINITION_TYPE_CODE,
    X_ACCOUNT_DEFINITION_CODE,
    X_NAME,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_AMB_CONTEXT_CODE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from XLA_TAB_ACCT_DEFS_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.AMB_CONTEXT_CODE = X_AMB_CONTEXT_CODE
    and T.ACCOUNT_DEFINITION_TYPE_CODE = X_ACCOUNT_DEFINITION_TYPE_CODE
    and T.ACCOUNT_DEFINITION_CODE = X_ACCOUNT_DEFINITION_CODE
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
  X_APPLICATION_ID               in NUMBER,
  X_AMB_CONTEXT_CODE             in VARCHAR2,
  X_ACCOUNT_DEFINITION_TYPE_CODE in VARCHAR2,
  X_ACCOUNT_DEFINITION_CODE      in VARCHAR2,
  X_REQUEST_ID                   in NUMBER,
  X_CHART_OF_ACCOUNTS_ID         in NUMBER,
  X_COMPILE_STATUS_CODE          in VARCHAR2,
  X_LOCKING_STATUS_FLAG          in VARCHAR2,
  X_ENABLED_FLAG                 in VARCHAR2,
  X_NAME                         in VARCHAR2,
  X_DESCRIPTION                  in VARCHAR2
) is

  cursor c is select
      REQUEST_ID,
      CHART_OF_ACCOUNTS_ID,
      COMPILE_STATUS_CODE,
      LOCKING_STATUS_FLAG,
      ENABLED_FLAG
    from XLA_TAB_ACCT_DEFS_B
    where APPLICATION_ID = X_APPLICATION_ID
    and AMB_CONTEXT_CODE = X_AMB_CONTEXT_CODE
    and ACCOUNT_DEFINITION_TYPE_CODE = X_ACCOUNT_DEFINITION_TYPE_CODE
    and ACCOUNT_DEFINITION_CODE = X_ACCOUNT_DEFINITION_CODE
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from XLA_TAB_ACCT_DEFS_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and AMB_CONTEXT_CODE = X_AMB_CONTEXT_CODE
    and ACCOUNT_DEFINITION_TYPE_CODE = X_ACCOUNT_DEFINITION_TYPE_CODE
    and ACCOUNT_DEFINITION_CODE = X_ACCOUNT_DEFINITION_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of APPLICATION_ID nowait;

BEGIN
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  if (    ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
      AND ((recinfo.CHART_OF_ACCOUNTS_ID = X_CHART_OF_ACCOUNTS_ID)
           OR ((recinfo.CHART_OF_ACCOUNTS_ID is null) AND (X_CHART_OF_ACCOUNTS_ID is null)))
      AND (recinfo.COMPILE_STATUS_CODE = X_COMPILE_STATUS_CODE)
      AND (recinfo.LOCKING_STATUS_FLAG = X_LOCKING_STATUS_FLAG)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
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

END LOCK_ROW;

/*======================================================================+
|                                                                       |
|  Procedure update_row                                                 |
|                                                                       |
+======================================================================*/

procedure UPDATE_ROW (
  X_APPLICATION_ID               in NUMBER,
  X_AMB_CONTEXT_CODE             in VARCHAR2,
  X_ACCOUNT_DEFINITION_TYPE_CODE in VARCHAR2,
  X_ACCOUNT_DEFINITION_CODE      in VARCHAR2,
  X_REQUEST_ID                   in NUMBER,
  X_CHART_OF_ACCOUNTS_ID         in NUMBER,
  X_COMPILE_STATUS_CODE          in VARCHAR2,
  X_LOCKING_STATUS_FLAG          in VARCHAR2,
  X_ENABLED_FLAG                 in VARCHAR2,
  X_NAME                         in VARCHAR2,
  X_DESCRIPTION                  in VARCHAR2,
  X_LAST_UPDATE_DATE             in DATE,
  X_LAST_UPDATED_BY              in NUMBER,
  X_LAST_UPDATE_LOGIN            in NUMBER
) is

BEGIN

  UPDATE XLA_TAB_ACCT_DEFS_B set
    REQUEST_ID = X_REQUEST_ID,
    CHART_OF_ACCOUNTS_ID = X_CHART_OF_ACCOUNTS_ID,
    COMPILE_STATUS_CODE = X_COMPILE_STATUS_CODE,
    LOCKING_STATUS_FLAG = X_LOCKING_STATUS_FLAG,
    ENABLED_FLAG = X_ENABLED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and AMB_CONTEXT_CODE = X_AMB_CONTEXT_CODE
  and ACCOUNT_DEFINITION_TYPE_CODE = X_ACCOUNT_DEFINITION_TYPE_CODE
  and ACCOUNT_DEFINITION_CODE = X_ACCOUNT_DEFINITION_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update XLA_TAB_ACCT_DEFS_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and AMB_CONTEXT_CODE = X_AMB_CONTEXT_CODE
  and ACCOUNT_DEFINITION_TYPE_CODE = X_ACCOUNT_DEFINITION_TYPE_CODE
  and ACCOUNT_DEFINITION_CODE = X_ACCOUNT_DEFINITION_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

END UPDATE_ROW;


/*======================================================================+
|                                                                       |
|  Procedure delete_row                                                 |
|                                                                       |
+======================================================================*/

procedure DELETE_ROW (
  X_APPLICATION_ID               in NUMBER,
  X_AMB_CONTEXT_CODE             in VARCHAR2,
  X_ACCOUNT_DEFINITION_TYPE_CODE in VARCHAR2,
  X_ACCOUNT_DEFINITION_CODE      in VARCHAR2
) is

BEGIN

  delete from XLA_TAB_ACCT_DEFS_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and AMB_CONTEXT_CODE = X_AMB_CONTEXT_CODE
  and ACCOUNT_DEFINITION_TYPE_CODE = X_ACCOUNT_DEFINITION_TYPE_CODE
  and ACCOUNT_DEFINITION_CODE = X_ACCOUNT_DEFINITION_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from XLA_TAB_ACCT_DEFS_B
  where APPLICATION_ID = X_APPLICATION_ID
  and AMB_CONTEXT_CODE = X_AMB_CONTEXT_CODE
  and ACCOUNT_DEFINITION_TYPE_CODE = X_ACCOUNT_DEFINITION_TYPE_CODE
  and ACCOUNT_DEFINITION_CODE = X_ACCOUNT_DEFINITION_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

END DELETE_ROW;

/*======================================================================+
|                                                                       |
|  Procedure add_language                                               |
|                                                                       |
+======================================================================*/

procedure ADD_LANGUAGE
is

BEGIN
  delete from XLA_TAB_ACCT_DEFS_TL T
  where not exists
    (select NULL
    from XLA_TAB_ACCT_DEFS_B B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.AMB_CONTEXT_CODE = T.AMB_CONTEXT_CODE
    and B.ACCOUNT_DEFINITION_TYPE_CODE = T.ACCOUNT_DEFINITION_TYPE_CODE
    and B.ACCOUNT_DEFINITION_CODE = T.ACCOUNT_DEFINITION_CODE
    );

  update XLA_TAB_ACCT_DEFS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from XLA_TAB_ACCT_DEFS_TL B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.AMB_CONTEXT_CODE = T.AMB_CONTEXT_CODE
    and B.ACCOUNT_DEFINITION_TYPE_CODE = T.ACCOUNT_DEFINITION_TYPE_CODE
    and B.ACCOUNT_DEFINITION_CODE = T.ACCOUNT_DEFINITION_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPLICATION_ID,
      T.AMB_CONTEXT_CODE,
      T.ACCOUNT_DEFINITION_TYPE_CODE,
      T.ACCOUNT_DEFINITION_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.APPLICATION_ID,
      SUBT.AMB_CONTEXT_CODE,
      SUBT.ACCOUNT_DEFINITION_TYPE_CODE,
      SUBT.ACCOUNT_DEFINITION_CODE,
      SUBT.LANGUAGE
    from XLA_TAB_ACCT_DEFS_TL SUBB, XLA_TAB_ACCT_DEFS_TL SUBT
    where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.AMB_CONTEXT_CODE = SUBT.AMB_CONTEXT_CODE
    and SUBB.ACCOUNT_DEFINITION_TYPE_CODE = SUBT.ACCOUNT_DEFINITION_TYPE_CODE
    and SUBB.ACCOUNT_DEFINITION_CODE = SUBT.ACCOUNT_DEFINITION_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into XLA_TAB_ACCT_DEFS_TL (
    APPLICATION_ID,
    ACCOUNT_DEFINITION_TYPE_CODE,
    ACCOUNT_DEFINITION_CODE,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    AMB_CONTEXT_CODE,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.APPLICATION_ID,
    B.ACCOUNT_DEFINITION_TYPE_CODE,
    B.ACCOUNT_DEFINITION_CODE,
    B.NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.AMB_CONTEXT_CODE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from XLA_TAB_ACCT_DEFS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from XLA_TAB_ACCT_DEFS_TL T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.AMB_CONTEXT_CODE = B.AMB_CONTEXT_CODE
    and T.ACCOUNT_DEFINITION_TYPE_CODE = B.ACCOUNT_DEFINITION_TYPE_CODE
    and T.ACCOUNT_DEFINITION_CODE = B.ACCOUNT_DEFINITION_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end xla_tab_acct_defs_f_PKG;

/
