--------------------------------------------------------
--  DDL for Package Body QPR_POLICIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_POLICIES_PKG" as
/* $Header: QPRUPLCB.pls 120.0 2007/12/24 20:03:24 vinnaray noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_POLICY_ID in NUMBER,
  X_ACTIVE_FLAG in VARCHAR2,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from QPR_POLICIES_B
    where POLICY_ID = X_POLICY_ID
    ;
begin
  insert into QPR_POLICIES_B (
    POLICY_ID,
    ACTIVE_FLAG,
    PROGRAM_LOGIN_ID,
    REQUEST_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_POLICY_ID,
    X_ACTIVE_FLAG,
    X_PROGRAM_LOGIN_ID,
    X_REQUEST_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into QPR_POLICIES_TL (
    DESCRIPTION,
    POLICY_ID,
    NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    --PROGRAM_ID,
    PROGRAM_LOGIN_ID,
    --PROGRAM_APPLICATION_ID,
    REQUEST_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DESCRIPTION,
    X_POLICY_ID,
    X_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    --X_PROGRAM_ID,
    X_PROGRAM_LOGIN_ID,
    --X_PROGRAM_APPLICATION_ID,
    X_REQUEST_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from QPR_POLICIES_TL T
    where T.POLICY_ID = X_POLICY_ID
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
  X_POLICY_ID in NUMBER,
  X_ACTIVE_FLAG in VARCHAR2,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_NAME in VARCHAR2
) is
  cursor c is select
      ACTIVE_FLAG,
      PROGRAM_LOGIN_ID,
      REQUEST_ID
    from QPR_POLICIES_B
    where POLICY_ID = X_POLICY_ID
    for update of POLICY_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from QPR_POLICIES_TL
    where POLICY_ID = X_POLICY_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of POLICY_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ACTIVE_FLAG = X_ACTIVE_FLAG)
           OR ((recinfo.ACTIVE_FLAG is null) AND (X_ACTIVE_FLAG is null)))
      AND ((recinfo.PROGRAM_LOGIN_ID = X_PROGRAM_LOGIN_ID)
           OR ((recinfo.PROGRAM_LOGIN_ID is null) AND (X_PROGRAM_LOGIN_ID is null)))
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
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
  X_POLICY_ID in NUMBER,
  X_ACTIVE_FLAG in VARCHAR2,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update QPR_POLICIES_B set
    ACTIVE_FLAG = X_ACTIVE_FLAG,
    PROGRAM_LOGIN_ID = X_PROGRAM_LOGIN_ID,
    REQUEST_ID = X_REQUEST_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where POLICY_ID = X_POLICY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update QPR_POLICIES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where POLICY_ID = X_POLICY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_POLICY_ID in NUMBER
) is
begin
  delete from QPR_POLICIES_TL
  where POLICY_ID = X_POLICY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from QPR_POLICIES_B
  where POLICY_ID = X_POLICY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from QPR_POLICIES_TL T
  where not exists
    (select NULL
    from QPR_POLICIES_B B
    where B.POLICY_ID = T.POLICY_ID
    );

  update QPR_POLICIES_TL T set (
      NAME
    ) = (select
      B.NAME
    from QPR_POLICIES_TL B
    where B.POLICY_ID = T.POLICY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.POLICY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.POLICY_ID,
      SUBT.LANGUAGE
    from QPR_POLICIES_TL SUBB, QPR_POLICIES_TL SUBT
    where SUBB.POLICY_ID = SUBT.POLICY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
  ));

  insert into QPR_POLICIES_TL (
    DESCRIPTION,
    POLICY_ID,
    NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PROGRAM_ID,
    PROGRAM_LOGIN_ID,
    PROGRAM_APPLICATION_ID,
    REQUEST_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.DESCRIPTION,
    B.POLICY_ID,
    B.NAME,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.PROGRAM_ID,
    B.PROGRAM_LOGIN_ID,
    B.PROGRAM_APPLICATION_ID,
    B.REQUEST_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from QPR_POLICIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from QPR_POLICIES_TL T
    where T.POLICY_ID = B.POLICY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end QPR_POLICIES_PKG;

/
