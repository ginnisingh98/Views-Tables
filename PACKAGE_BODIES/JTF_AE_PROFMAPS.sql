--------------------------------------------------------
--  DDL for Package Body JTF_AE_PROFMAPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_AE_PROFMAPS" as
/* $Header: JTFAEPMB.pls 120.1 2005/07/02 01:59:54 appldev ship $ */
procedure INSERT_ROW (
  X_PROFILE_MAPPINGS_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OWNERID in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_BASETABLE in VARCHAR2,
  X_PROFILENAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_PROFILE_MAPPINGS_B
    where PROFILE_MAPPINGS_ID = X_PROFILE_MAPPINGS_ID
    ;
begin
  insert into JTF_PROFILE_MAPPINGS_B (
    SECURITY_GROUP_ID,
    PROFILE_MAPPINGS_ID,
    OWNERID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_SECURITY_GROUP_ID,
    X_PROFILE_MAPPINGS_ID,
    X_OWNERID,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_PROFILE_MAPPINGS_TL (
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    SECURITY_GROUP_ID,
    PROFILE_MAPPINGS_ID,
    BASETABLE,
    PROFILENAME,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_SECURITY_GROUP_ID,
    X_PROFILE_MAPPINGS_ID,
    X_BASETABLE,
    X_PROFILENAME,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_PROFILE_MAPPINGS_TL T
    where T.PROFILE_MAPPINGS_ID = X_PROFILE_MAPPINGS_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_PROFILE_MAPPINGS_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OWNERID in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_BASETABLE in VARCHAR2,
  X_PROFILENAME in VARCHAR2
) is
  cursor c is select
      SECURITY_GROUP_ID,
      OWNERID,
      OBJECT_VERSION_NUMBER
    from JTF_PROFILE_MAPPINGS_B
    where PROFILE_MAPPINGS_ID = X_PROFILE_MAPPINGS_ID
    for update of PROFILE_MAPPINGS_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      BASETABLE,
      PROFILENAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_PROFILE_MAPPINGS_TL
    where PROFILE_MAPPINGS_ID = X_PROFILE_MAPPINGS_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PROFILE_MAPPINGS_ID nowait;
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
      AND (recinfo.OWNERID = X_OWNERID)
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
      if (    ((tlinfo.BASETABLE = X_BASETABLE)
               OR ((tlinfo.BASETABLE is null) AND (X_BASETABLE is null)))
          AND ((tlinfo.PROFILENAME = X_PROFILENAME)
               OR ((tlinfo.PROFILENAME is null) AND (X_PROFILENAME is null)))
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
  X_PROFILE_MAPPINGS_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OWNERID in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_BASETABLE in VARCHAR2,
  X_PROFILENAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_PROFILE_MAPPINGS_B set
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    OWNERID = X_OWNERID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PROFILE_MAPPINGS_ID = X_PROFILE_MAPPINGS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_PROFILE_MAPPINGS_TL set
    BASETABLE = X_BASETABLE,
    PROFILENAME = X_PROFILENAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PROFILE_MAPPINGS_ID = X_PROFILE_MAPPINGS_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PROFILE_MAPPINGS_ID in NUMBER
) is
begin
  delete from JTF_PROFILE_MAPPINGS_TL
  where PROFILE_MAPPINGS_ID = X_PROFILE_MAPPINGS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_PROFILE_MAPPINGS_B
  where PROFILE_MAPPINGS_ID = X_PROFILE_MAPPINGS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_PROFILE_MAPPINGS_TL T
  where not exists
    (select NULL
    from JTF_PROFILE_MAPPINGS_B B
    where B.PROFILE_MAPPINGS_ID = T.PROFILE_MAPPINGS_ID
    );

  update JTF_PROFILE_MAPPINGS_TL T set (
      BASETABLE,
      PROFILENAME
    ) = (select
      B.BASETABLE,
      B.PROFILENAME
    from JTF_PROFILE_MAPPINGS_TL B
    where B.PROFILE_MAPPINGS_ID = T.PROFILE_MAPPINGS_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PROFILE_MAPPINGS_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PROFILE_MAPPINGS_ID,
      SUBT.LANGUAGE
    from JTF_PROFILE_MAPPINGS_TL SUBB, JTF_PROFILE_MAPPINGS_TL SUBT
    where SUBB.PROFILE_MAPPINGS_ID = SUBT.PROFILE_MAPPINGS_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.BASETABLE <> SUBT.BASETABLE
      or (SUBB.BASETABLE is null and SUBT.BASETABLE is not null)
      or (SUBB.BASETABLE is not null and SUBT.BASETABLE is null)
      or SUBB.PROFILENAME <> SUBT.PROFILENAME
      or (SUBB.PROFILENAME is null and SUBT.PROFILENAME is not null)
      or (SUBB.PROFILENAME is not null and SUBT.PROFILENAME is null)
  ));

  insert into JTF_PROFILE_MAPPINGS_TL (
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    SECURITY_GROUP_ID,
    PROFILE_MAPPINGS_ID,
    BASETABLE,
    PROFILENAME,
    DESCRIPTION,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.SECURITY_GROUP_ID,
    B.PROFILE_MAPPINGS_ID,
    B.BASETABLE,
    B.PROFILENAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_PROFILE_MAPPINGS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_PROFILE_MAPPINGS_TL T
    where T.PROFILE_MAPPINGS_ID = B.PROFILE_MAPPINGS_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  X_PROFILE_MAPPINGS_ID in NUMBER,
  X_BASETABLE in VARCHAR2,
  X_PROFILENAME in VARCHAR2,
  X_OWNER in VARCHAR2
) is
begin

  update JTF_PROFILE_MAPPINGS_TL set
  BASETABLE                = X_BASETABLE,
  PROFILENAME              = X_PROFILENAME,
  SOURCE_LANG              = userenv('LANG'),
  last_update_date         = sysdate,
  last_updated_by          = decode(X_OWNER,'SEED',1,0),
  last_update_login        = 0
  where PROFILE_MAPPINGS_ID = to_number(X_PROFILE_MAPPINGS_ID)
        and userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

procedure LOAD_ROW(
  X_PROFILE_MAPPINGS_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OWNERID in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_BASETABLE in VARCHAR2,
  X_PROFILENAME in VARCHAR2,
  X_OWNER in VARCHAR2
) is

l_rowid  VARCHAR2(64);
l_user_id NUMBER := 0;

begin
        if(x_owner = 'SEED') then
                l_user_id := 1;
        end if;

      -- Update row if present
      JTF_AE_PROFMAPS.UPDATE_ROW (
        X_PROFILE_MAPPINGS_ID    => X_PROFILE_MAPPINGS_ID,
        X_SECURITY_GROUP_ID      => X_SECURITY_GROUP_ID,
        X_OWNERID                => X_OWNERID,
        X_OBJECT_VERSION_NUMBER  => X_OBJECT_VERSION_NUMBER,
        X_BASETABLE              => X_BASETABLE,
        X_PROFILENAME            => X_PROFILENAME,
        X_LAST_UPDATE_DATE       => sysdate,
        X_LAST_UPDATED_BY        => l_user_id,
        X_LAST_UPDATE_LOGIN      => 0);
   exception
   when NO_DATA_FOUND then
      -- Insert a row
      JTF_AE_PROFMAPS.INSERT_ROW (
        X_PROFILE_MAPPINGS_ID    => X_PROFILE_MAPPINGS_ID,
        X_SECURITY_GROUP_ID      => X_SECURITY_GROUP_ID,
        X_OWNERID                => X_OWNERID,
        X_OBJECT_VERSION_NUMBER  => X_OBJECT_VERSION_NUMBER,
        X_BASETABLE              => X_BASETABLE,
        X_PROFILENAME            => X_PROFILENAME,
        X_CREATION_DATE          => sysdate,
        X_CREATED_BY             => l_user_id,
        X_LAST_UPDATE_DATE       => sysdate,
        X_LAST_UPDATED_BY        => l_user_id,
        X_LAST_UPDATE_LOGIN      => 0
      );


end LOAD_ROW;

end JTF_AE_PROFMAPS;

/
