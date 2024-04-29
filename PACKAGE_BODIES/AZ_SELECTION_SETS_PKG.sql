--------------------------------------------------------
--  DDL for Package Body AZ_SELECTION_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AZ_SELECTION_SETS_PKG" as
/* $Header: aztssetb.pls 120.3.12000000.2 2007/03/02 10:57:29 sbandi ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SELECTION_SET_CODE in VARCHAR2,
  X_USER_ID in NUMBER,
  X_STRUCTURE_CODE in VARCHAR2,
  X_ACTIVE in VARCHAR2,
  X_HIERARCHICAL_FLAG in VARCHAR2,
  X_PARTIAL_SELECTION in VARCHAR2,
  X_SOURCE_INSTANCE in VARCHAR2,
  X_PREDEFINED_FLAG in VARCHAR2,
  X_SELECTION_SET_NAME in VARCHAR2,
  X_SELECTION_SET_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AZ_SELECTION_SETS_B
    where SELECTION_SET_CODE = X_SELECTION_SET_CODE
    and USER_ID = X_USER_ID
    ;
begin
  insert into AZ_SELECTION_SETS_B (
    SELECTION_SET_CODE,
    USER_ID,
    STRUCTURE_CODE,
    ACTIVE,
    HIERARCHICAL_FLAG,
    PARTIAL_SELECTION,
    SOURCE_INSTANCE,
    PREDEFINED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_SELECTION_SET_CODE,
    X_USER_ID,
    X_STRUCTURE_CODE,
    X_ACTIVE,
    X_HIERARCHICAL_FLAG,
    X_PARTIAL_SELECTION,
    X_SOURCE_INSTANCE,
    X_PREDEFINED_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AZ_SELECTION_SETS_TL (
    LAST_UPDATE_LOGIN,
    SELECTION_SET_CODE,
    USER_ID,
    SELECTION_SET_NAME,
    SELECTION_SET_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_LOGIN,
    X_SELECTION_SET_CODE,
    X_USER_ID,
    X_SELECTION_SET_NAME,
    X_SELECTION_SET_DESC,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AZ_SELECTION_SETS_TL T
    where T.SELECTION_SET_CODE = X_SELECTION_SET_CODE
    and T.USER_ID = X_USER_ID
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
  X_SELECTION_SET_CODE in VARCHAR2,
  X_USER_ID in NUMBER,
  X_STRUCTURE_CODE in VARCHAR2,
  X_SOURCE_INSTANCE in VARCHAR2,
  X_PREDEFINED_FLAG in VARCHAR2,
  X_SELECTION_SET_NAME in VARCHAR2,
  X_SELECTION_SET_DESC in VARCHAR2
) is
  cursor c is select
      STRUCTURE_CODE,
      SOURCE_INSTANCE,
      PREDEFINED_FLAG
    from AZ_SELECTION_SETS_B
    where SELECTION_SET_CODE = X_SELECTION_SET_CODE
    and USER_ID = X_USER_ID
    for update of SELECTION_SET_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      SELECTION_SET_NAME,
      SELECTION_SET_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AZ_SELECTION_SETS_TL
    where SELECTION_SET_CODE = X_SELECTION_SET_CODE
    and USER_ID = X_USER_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of SELECTION_SET_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.STRUCTURE_CODE = X_STRUCTURE_CODE)
      AND ((recinfo.SOURCE_INSTANCE = X_SOURCE_INSTANCE)
           OR ((recinfo.SOURCE_INSTANCE is null) AND (X_SOURCE_INSTANCE is null)))
      AND (recinfo.PREDEFINED_FLAG = X_PREDEFINED_FLAG)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.SELECTION_SET_NAME = X_SELECTION_SET_NAME)
          AND ((tlinfo.SELECTION_SET_DESC = X_SELECTION_SET_DESC)
               OR ((tlinfo.SELECTION_SET_DESC is null) AND (X_SELECTION_SET_DESC is null)))
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
  X_SELECTION_SET_CODE in VARCHAR2,
  X_USER_ID in NUMBER,
  X_STRUCTURE_CODE in VARCHAR2,
  X_ACTIVE in VARCHAR2,
  X_HIERARCHICAL_FLAG in VARCHAR2,
  X_PARTIAL_SELECTION in VARCHAR2,
  X_SOURCE_INSTANCE in VARCHAR2,
  X_PREDEFINED_FLAG in VARCHAR2,
  X_SELECTION_SET_NAME in VARCHAR2,
  X_SELECTION_SET_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AZ_SELECTION_SETS_B set
    STRUCTURE_CODE = X_STRUCTURE_CODE,
    ACTIVE = X_ACTIVE,
    HIERARCHICAL_FLAG = X_HIERARCHICAL_FLAG,
    PARTIAL_SELECTION = X_PARTIAL_SELECTION,
    SOURCE_INSTANCE = X_SOURCE_INSTANCE,
    PREDEFINED_FLAG = X_PREDEFINED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where SELECTION_SET_CODE = X_SELECTION_SET_CODE
  and USER_ID = X_USER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AZ_SELECTION_SETS_TL set
    SELECTION_SET_NAME = X_SELECTION_SET_NAME,
    SELECTION_SET_DESC = X_SELECTION_SET_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where SELECTION_SET_CODE = X_SELECTION_SET_CODE
  and USER_ID = X_USER_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_SELECTION_SET_CODE in VARCHAR2,
  X_USER_ID in NUMBER
) is
begin
  delete from AZ_SELECTION_SETS_TL
  where SELECTION_SET_CODE = X_SELECTION_SET_CODE
  and USER_ID = X_USER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AZ_SELECTION_SETS_B
  where SELECTION_SET_CODE = X_SELECTION_SET_CODE
  and USER_ID = X_USER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AZ_SELECTION_SETS_TL T
  where not exists
    (select NULL
    from AZ_SELECTION_SETS_B B
    where B.SELECTION_SET_CODE = T.SELECTION_SET_CODE
    and B.USER_ID = T.USER_ID
    );

  update AZ_SELECTION_SETS_TL T set (
      SELECTION_SET_NAME,
      SELECTION_SET_DESC
    ) = (select
      B.SELECTION_SET_NAME,
      B.SELECTION_SET_DESC
    from AZ_SELECTION_SETS_TL B
    where B.SELECTION_SET_CODE = T.SELECTION_SET_CODE
    and B.USER_ID = T.USER_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SELECTION_SET_CODE,
      T.USER_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SELECTION_SET_CODE,
      SUBT.USER_ID,
      SUBT.LANGUAGE
    from AZ_SELECTION_SETS_TL SUBB, AZ_SELECTION_SETS_TL SUBT
    where SUBB.SELECTION_SET_CODE = SUBT.SELECTION_SET_CODE
    and SUBB.USER_ID = SUBT.USER_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SELECTION_SET_NAME <> SUBT.SELECTION_SET_NAME
      or SUBB.SELECTION_SET_DESC <> SUBT.SELECTION_SET_DESC
      or (SUBB.SELECTION_SET_DESC is null and SUBT.SELECTION_SET_DESC is not null)
      or (SUBB.SELECTION_SET_DESC is not null and SUBT.SELECTION_SET_DESC is null)
  ));

  insert into AZ_SELECTION_SETS_TL (
    LAST_UPDATE_LOGIN,
    SELECTION_SET_CODE,
    USER_ID,
    SELECTION_SET_NAME,
    SELECTION_SET_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_LOGIN,
    B.SELECTION_SET_CODE,
    B.USER_ID,
    B.SELECTION_SET_NAME,
    B.SELECTION_SET_DESC,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AZ_SELECTION_SETS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AZ_SELECTION_SETS_TL T
    where T.SELECTION_SET_CODE = B.SELECTION_SET_CODE
    and T.USER_ID = B.USER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
     X_SELECTION_SET_CODE      in VARCHAR2,
     X_USER_ID                 in NUMBER ,
     X_SELECTION_SET_NAME      in VARCHAR2,
     X_OWNER                   in VARCHAR2,
     X_SELECTION_SET_DESC      in VARCHAR2 ) is
begin
     update AZ_SELECTION_SETS_TL set
        SELECTION_SET_NAME = X_SELECTION_SET_NAME,
        SELECTION_SET_DESC = X_SELECTION_SET_DESC,
        last_update_date   = sysdate,
        last_updated_by    = decode(X_OWNER, 'SEED', 1, 0),
        last_update_login  = 0,
        source_lang        = userenv('LANG')
      where SELECTION_SET_CODE = X_SELECTION_SET_CODE
      and   USER_ID = X_USER_ID
      and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

procedure LOAD_ROW (
        X_SELECTION_SET_CODE    in   VARCHAR2,
        X_USER_ID               in   NUMBER,
        X_OWNER                 in   VARCHAR2,
        X_STRUCTURE_CODE        in   VARCHAR2,
        X_ACTIVE                in   VARCHAR2,
        X_HIERARCHICAL_FLAG     in   VARCHAR2,
	X_PARTIAL_SELECTION	in   VARCHAR2,
        X_SOURCE_INSTANCE       in   VARCHAR2,
        X_PREDEFINED_FLAG       in   VARCHAR2,
        X_SELECTION_SET_NAME    in   VARCHAR2,
        X_SELECTION_SET_DESC    in   VARCHAR2) IS
begin
    declare
        l_owner_id  number := 0;
        l_row_id    varchar2(64);
        luby        number := null;
    begin
     if (X_OWNER = 'SEED') then
       l_owner_id := 1;
     end if;

     select last_updated_by into luby
     from AZ_SELECTION_SETS_B
     where SELECTION_SET_CODE = X_SELECTION_SET_CODE
     and   USER_ID = X_USER_ID;

     IF luby = 1 THEN
         AZ_SELECTION_SETS_PKG.UPDATE_ROW(
                   X_SELECTION_SET_CODE => X_SELECTION_SET_CODE,
                   X_USER_ID => X_USER_ID,
                   X_STRUCTURE_CODE => X_STRUCTURE_CODE,
                   X_ACTIVE => X_ACTIVE,
                   X_HIERARCHICAL_FLAG => X_HIERARCHICAL_FLAG,
		   X_PARTIAL_SELECTION => X_PARTIAL_SELECTION,
                   X_SOURCE_INSTANCE => X_SOURCE_INSTANCE,
                   X_PREDEFINED_FLAG => X_PREDEFINED_FLAG,
                   X_SELECTION_SET_NAME => X_SELECTION_SET_NAME,
                   X_SELECTION_SET_DESC => X_SELECTION_SET_DESC,
                   X_LAST_UPDATE_DATE => sysdate,
                   X_LAST_UPDATED_BY => l_owner_id,
                   X_LAST_UPDATE_LOGIN => 0
                );
     END IF; -- if luby = 1

    exception
    when NO_DATA_FOUND then

         AZ_SELECTION_SETS_PKG.INSERT_ROW(
                   X_ROWID => l_row_id,
                   X_SELECTION_SET_CODE => X_SELECTION_SET_CODE,
                   X_USER_ID => X_USER_ID,
                   X_STRUCTURE_CODE => X_STRUCTURE_CODE,
                   X_ACTIVE => X_ACTIVE,
                   X_HIERARCHICAL_FLAG => X_HIERARCHICAL_FLAG,
		   X_PARTIAL_SELECTION => X_PARTIAL_SELECTION,
                   X_SOURCE_INSTANCE => X_SOURCE_INSTANCE,
                   X_PREDEFINED_FLAG => X_PREDEFINED_FLAG,
                   X_SELECTION_SET_NAME => X_SELECTION_SET_NAME,
                   X_SELECTION_SET_DESC => X_SELECTION_SET_DESC,
                   X_CREATION_DATE => sysdate,
                   X_CREATED_BY => l_owner_id,
                   X_LAST_UPDATE_DATE => sysdate,
                   X_LAST_UPDATED_BY => l_owner_id,
                   X_LAST_UPDATE_LOGIN => 0
                 );

    end;

end LOAD_ROW;

end AZ_SELECTION_SETS_PKG;

/
