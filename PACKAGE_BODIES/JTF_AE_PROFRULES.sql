--------------------------------------------------------
--  DDL for Package Body JTF_AE_PROFRULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_AE_PROFRULES" as
/* $Header: JTFAEPRB.pls 120.1 2005/07/02 02:00:09 appldev ship $ */
procedure INSERT_ROW (
  X_PROFILE_RULES_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_PROFILE_METADATA_ID in NUMBER,
  X_RULE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_BASE_PROPERTY_VALUE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_PROFILE_RULES_B
    where PROFILE_RULES_ID = X_PROFILE_RULES_ID
    ;
begin
  insert into JTF_PROFILE_RULES_B (
    SECURITY_GROUP_ID,
    PROFILE_RULES_ID,
    PROFILE_METADATA_ID,
    RULE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_SECURITY_GROUP_ID,
    X_PROFILE_RULES_ID,
    X_PROFILE_METADATA_ID,
    X_RULE,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_PROFILE_RULES_TL (
    SECURITY_GROUP_ID,
    PROFILE_RULES_ID,
    BASE_PROPERTY_VALUE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_SECURITY_GROUP_ID,
    X_PROFILE_RULES_ID,
    X_BASE_PROPERTY_VALUE,
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
    from JTF_PROFILE_RULES_TL T
    where T.PROFILE_RULES_ID = X_PROFILE_RULES_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_PROFILE_RULES_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_PROFILE_METADATA_ID in NUMBER,
  X_RULE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_BASE_PROPERTY_VALUE in VARCHAR2
) is
  cursor c is select
      SECURITY_GROUP_ID,
      PROFILE_METADATA_ID,
      RULE,
      OBJECT_VERSION_NUMBER
    from JTF_PROFILE_RULES_B
    where PROFILE_RULES_ID = X_PROFILE_RULES_ID
    for update of PROFILE_RULES_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      BASE_PROPERTY_VALUE,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_PROFILE_RULES_TL
    where PROFILE_RULES_ID = X_PROFILE_RULES_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PROFILE_RULES_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND (recinfo.PROFILE_METADATA_ID = X_PROFILE_METADATA_ID)
      AND ((recinfo.RULE = X_RULE)
           OR ((recinfo.RULE is null) AND (X_RULE is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.BASE_PROPERTY_VALUE = X_BASE_PROPERTY_VALUE)
               OR ((tlinfo.BASE_PROPERTY_VALUE is null) AND (X_BASE_PROPERTY_VALUE is null)))
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
  X_PROFILE_RULES_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_PROFILE_METADATA_ID in NUMBER,
  X_RULE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_BASE_PROPERTY_VALUE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_PROFILE_RULES_B set
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    PROFILE_METADATA_ID = X_PROFILE_METADATA_ID,
    RULE = X_RULE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PROFILE_RULES_ID = X_PROFILE_RULES_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_PROFILE_RULES_TL set
    BASE_PROPERTY_VALUE = X_BASE_PROPERTY_VALUE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PROFILE_RULES_ID = X_PROFILE_RULES_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PROFILE_RULES_ID in NUMBER
) is
begin
  delete from JTF_PROFILE_RULES_TL
  where PROFILE_RULES_ID = X_PROFILE_RULES_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_PROFILE_RULES_B
  where PROFILE_RULES_ID = X_PROFILE_RULES_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_PROFILE_RULES_TL T
  where not exists
    (select NULL
    from JTF_PROFILE_RULES_B B
    where B.PROFILE_RULES_ID = T.PROFILE_RULES_ID
    );

  update JTF_PROFILE_RULES_TL T set (
      BASE_PROPERTY_VALUE
    ) = (select
      B.BASE_PROPERTY_VALUE
    from JTF_PROFILE_RULES_TL B
    where B.PROFILE_RULES_ID = T.PROFILE_RULES_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PROFILE_RULES_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PROFILE_RULES_ID,
      SUBT.LANGUAGE
    from JTF_PROFILE_RULES_TL SUBB, JTF_PROFILE_RULES_TL SUBT
    where SUBB.PROFILE_RULES_ID = SUBT.PROFILE_RULES_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.BASE_PROPERTY_VALUE <> SUBT.BASE_PROPERTY_VALUE
      or (SUBB.BASE_PROPERTY_VALUE is null and SUBT.BASE_PROPERTY_VALUE is not null)
      or (SUBB.BASE_PROPERTY_VALUE is not null and SUBT.BASE_PROPERTY_VALUE is null)
  ));

  insert into JTF_PROFILE_RULES_TL (
    SECURITY_GROUP_ID,
    PROFILE_RULES_ID,
    BASE_PROPERTY_VALUE,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.SECURITY_GROUP_ID,
    B.PROFILE_RULES_ID,
    B.BASE_PROPERTY_VALUE,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_PROFILE_RULES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_PROFILE_RULES_TL T
    where T.PROFILE_RULES_ID = B.PROFILE_RULES_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  X_PROFILE_RULES_ID in NUMBER,
  X_BASE_PROPERTY_VALUE in VARCHAR2,
  X_OWNER in VARCHAR2
) is

begin
  update JTF_PROFILE_RULES_TL set
  BASE_PROPERTY_VALUE      = X_BASE_PROPERTY_VALUE,
  SOURCE_LANG              = userenv('LANG'),
  last_update_date         = sysdate,
  last_updated_by          = decode(X_OWNER,'SEED',1,0),
  last_update_login        = 0
  where PROFILE_RULES_ID = to_number(X_PROFILE_RULES_ID) and
        userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

procedure LOAD_ROW(
  X_PROFILE_RULES_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_PROFILE_METADATA_ID in NUMBER,
  X_RULE in VARCHAR2,
  X_BASE_PROPERTY_VALUE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2
) is

l_rowid  VARCHAR2(64);
l_user_id NUMBER := 0;

begin
        if(x_owner = 'SEED') then
                l_user_id := 1;
        end if;

      -- Update row if present
      JTF_AE_PROFRULES.UPDATE_ROW (
        X_PROFILE_RULES_ID       => X_PROFILE_RULES_ID,
        X_SECURITY_GROUP_ID      => X_SECURITY_GROUP_ID,
        X_PROFILE_METADATA_ID    => X_PROFILE_METADATA_ID,
        X_RULE                   => X_RULE,
        X_OBJECT_VERSION_NUMBER  => X_OBJECT_VERSION_NUMBER,
        X_BASE_PROPERTY_VALUE    => X_BASE_PROPERTY_VALUE,
        X_LAST_UPDATE_DATE       => sysdate,
        X_LAST_UPDATED_BY        => l_user_id,
        X_LAST_UPDATE_LOGIN      => 0);
   exception
   when NO_DATA_FOUND then
      -- Insert a row
      JTF_AE_PROFRULES.INSERT_ROW (
        X_PROFILE_RULES_ID       => X_PROFILE_RULES_ID,
        X_SECURITY_GROUP_ID      => X_SECURITY_GROUP_ID,
        X_PROFILE_METADATA_ID    => X_PROFILE_METADATA_ID,
        X_RULE                   => X_RULE,
        X_OBJECT_VERSION_NUMBER  => X_OBJECT_VERSION_NUMBER,
        X_BASE_PROPERTY_VALUE    => X_BASE_PROPERTY_VALUE,
        X_CREATION_DATE          => sysdate,
        X_CREATED_BY             => l_user_id,
        X_LAST_UPDATE_DATE       => sysdate,
        X_LAST_UPDATED_BY        => l_user_id,
        X_LAST_UPDATE_LOGIN      => 0
      );

end LOAD_ROW;

end JTF_AE_PROFRULES;

/
