--------------------------------------------------------
--  DDL for Package Body IGW_ROLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_ROLES_PKG" as
/* $Header: igwstrob.pls 115.7 2002/11/15 00:48:08 ashkumar ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ROLE_ID in NUMBER,
  X_SEEDED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ROLE_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from IGW_ROLES
    where ROLE_ID = X_ROLE_ID
    ;
begin
  insert into IGW_ROLES (
    SEEDED_FLAG,
    ROLE_ID,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_SEEDED_FLAG,
    X_ROLE_ID,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into IGW_ROLES_TL (
    CREATION_DATE,
    LAST_UPDATED_BY,
    ROLE_NAME,
    LAST_UPDATE_LOGIN,
    ROLE_ID,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_ROLE_NAME,
    X_LAST_UPDATE_LOGIN,
    X_ROLE_ID,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from IGW_ROLES_TL T
    where T.ROLE_ID = X_ROLE_ID
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
  X_ROLE_ID in NUMBER,
  X_SEEDED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ROLE_NAME in VARCHAR2
) is
  cursor c is select
      SEEDED_FLAG,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE
    from IGW_ROLES
    where ROLE_ID = X_ROLE_ID
    for update of ROLE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      ROLE_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IGW_ROLES_TL
    where ROLE_ID = X_ROLE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ROLE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.SEEDED_FLAG = X_SEEDED_FLAG)
           OR ((recinfo.SEEDED_FLAG is null) AND (X_SEEDED_FLAG is null)))
      AND (recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.ROLE_NAME = X_ROLE_NAME)
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
  X_ROLE_ID in NUMBER,
  X_SEEDED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ROLE_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update IGW_ROLES set
    SEEDED_FLAG = X_SEEDED_FLAG,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROLE_ID = X_ROLE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IGW_ROLES_TL set
    ROLE_NAME = X_ROLE_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ROLE_ID = X_ROLE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ROLE_ID in NUMBER
) is
begin
  delete from IGW_ROLES_TL
  where ROLE_ID = X_ROLE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IGW_ROLES
  where ROLE_ID = X_ROLE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IGW_ROLES_TL T
  where not exists
    (select NULL
    from IGW_ROLES B
    where B.ROLE_ID = T.ROLE_ID
    );

  update IGW_ROLES_TL T set (
      ROLE_NAME
    ) = (select
      B.ROLE_NAME
    from IGW_ROLES_TL B
    where B.ROLE_ID = T.ROLE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ROLE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ROLE_ID,
      SUBT.LANGUAGE
    from IGW_ROLES_TL SUBB, IGW_ROLES_TL SUBT
    where SUBB.ROLE_ID = SUBT.ROLE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.ROLE_NAME <> SUBT.ROLE_NAME
  ));

  insert into IGW_ROLES_TL (
    CREATION_DATE,
    LAST_UPDATED_BY,
    ROLE_NAME,
    LAST_UPDATE_LOGIN,
    ROLE_ID,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.ROLE_NAME,
    B.LAST_UPDATE_LOGIN,
    B.ROLE_ID,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IGW_ROLES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IGW_ROLES_TL T
    where T.ROLE_ID = B.ROLE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_ROLE_ID in NUMBER,
  X_ROLE_NAME in VARCHAR2,
  X_OWNER  in  VARCHAR2)  is
begin
    update igw_roles_tl set
      role_name = nvl(X_ROLE_NAME, role_name),
      last_update_date = sysdate,
      last_updated_by = decode (X_OWNER, 'SEED', 1, 0),
      last_update_login = 0,
      source_lang = userenv ('LANG')
    where role_id = X_ROLE_ID  and
          userenv('LANG') in (language, source_lang);
end TRANSLATE_ROW;

end IGW_ROLES_PKG;

/
