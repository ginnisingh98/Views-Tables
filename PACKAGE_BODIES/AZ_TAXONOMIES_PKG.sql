--------------------------------------------------------
--  DDL for Package Body AZ_TAXONOMIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AZ_TAXONOMIES_PKG" as
/* $Header: azttaxonomyb.pls 120.2 2008/03/26 11:30:55 hboda noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TAXONOMY_CODE in VARCHAR2,
  X_USER_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_TAXONOMY_NAME in VARCHAR2,
  X_TAXONOMY_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AZ_TAXONOMIES_B
    where TAXONOMY_CODE = X_TAXONOMY_CODE
    and USER_ID = X_USER_ID   ;

begin
  insert into AZ_TAXONOMIES_B (
	TAXONOMY_CODE,
	USER_ID ,
	ENABLED_FLAG,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN
  ) values (
	X_TAXONOMY_CODE,
	X_USER_ID,
	X_ENABLED_FLAG,
	X_CREATION_DATE,
	X_CREATED_BY,
	X_LAST_UPDATE_DATE,
	X_LAST_UPDATED_BY,
	X_LAST_UPDATE_LOGIN
  );

  insert into AZ_TAXONOMIES_TL (
    TAXONOMY_CODE,
    USER_ID,
    TAXONOMY_NAME,
    TAXONOMY_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TAXONOMY_CODE,
    X_USER_ID,
    X_TAXONOMY_NAME,
    X_TAXONOMY_DESC,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AZ_TAXONOMIES_TL T
    where T.TAXONOMY_CODE = X_TAXONOMY_CODE
    and T.USER_ID = X_USER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE) ;

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;


procedure UPDATE_ROW (
  X_TAXONOMY_CODE in VARCHAR2,
  X_USER_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_TAXONOMY_NAME in VARCHAR2,
  X_TAXONOMY_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AZ_TAXONOMIES_B set
    ENABLED_FLAG = X_ENABLED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where TAXONOMY_CODE = X_TAXONOMY_CODE
  and USER_ID = X_USER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AZ_TAXONOMIES_TL set
    TAXONOMY_NAME = X_TAXONOMY_NAME,
    TAXONOMY_DESC = X_TAXONOMY_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TAXONOMY_CODE = X_TAXONOMY_CODE
  and USER_ID = X_USER_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TAXONOMY_CODE in VARCHAR2,
  X_USER_ID in NUMBER
) is
begin
  delete from AZ_TAXONOMIES_TL
  where TAXONOMY_CODE = X_TAXONOMY_CODE
  and USER_ID = X_USER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AZ_TAXONOMIES_B
  where TAXONOMY_CODE = X_TAXONOMY_CODE
  and USER_ID = X_USER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AZ_TAXONOMIES_TL T
  where not exists
    (select NULL
    from AZ_TAXONOMIES_B B
    where B.TAXONOMY_CODE = T.TAXONOMY_CODE
    and B.USER_ID = T.USER_ID
    );

  update AZ_TAXONOMIES_TL T set (
      TAXONOMY_NAME,
      TAXONOMY_DESC
    ) = (select
      B.TAXONOMY_NAME,
      B.TAXONOMY_DESC
    from AZ_TAXONOMIES_TL B
    where B.TAXONOMY_CODE = T.TAXONOMY_CODE
    and B.USER_ID = T.USER_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TAXONOMY_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.TAXONOMY_CODE,
      SUBT.LANGUAGE
    from AZ_TAXONOMIES_TL SUBB, AZ_TAXONOMIES_TL SUBT
    where SUBB.TAXONOMY_CODE = SUBT.TAXONOMY_CODE
    and SUBB.USER_ID = SUBT.USER_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TAXONOMY_NAME <> SUBT.TAXONOMY_NAME
      or (SUBB.TAXONOMY_NAME is null and SUBT.TAXONOMY_NAME is not null)
      or (SUBB.TAXONOMY_NAME is not null and SUBT.TAXONOMY_NAME is null)
      or SUBB.TAXONOMY_DESC <> SUBT.TAXONOMY_DESC
      or (SUBB.TAXONOMY_DESC is null and SUBT.TAXONOMY_DESC is not null)
      or (SUBB.TAXONOMY_DESC is not null and SUBT.TAXONOMY_DESC is null)
  ));

  insert into AZ_TAXONOMIES_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    TAXONOMY_NAME,
    TAXONOMY_DESC,
    TAXONOMY_CODE,
    USER_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.TAXONOMY_NAME,
    B.TAXONOMY_DESC,
    B.TAXONOMY_CODE,
    B.USER_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AZ_TAXONOMIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AZ_TAXONOMIES_TL T
    where T.TAXONOMY_CODE = B.TAXONOMY_CODE
    and T.USER_ID = B.USER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
        X_TAXONOMY_CODE    in   VARCHAR2,
        X_USER_ID               in   NUMBER,
	X_OWNER                 in   VARCHAR2,
        X_TAXONOMY_NAME    in   VARCHAR2,
        X_TAXONOMY_DESC    in   VARCHAR2  ) is
begin
     update AZ_TAXONOMIES_TL set
        TAXONOMY_NAME = X_TAXONOMY_NAME,
        TAXONOMY_DESC = X_TAXONOMY_DESC,
        last_update_date   = sysdate,
        last_updated_by    = decode(X_OWNER, 'SEED', 1, 0),
        last_update_login  = 0,
        source_lang        = userenv('LANG')
      where TAXONOMY_CODE = X_TAXONOMY_CODE
      and   USER_ID = X_USER_ID
      and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

procedure LOAD_ROW (
        X_TAXONOMY_CODE    in   VARCHAR2,
        X_USER_ID               in   NUMBER,
        X_OWNER                 in   VARCHAR2,
        X_ENABLED_FLAG        in   VARCHAR2,
        X_TAXONOMY_NAME    in   VARCHAR2,
        X_TAXONOMY_DESC    in   VARCHAR2) IS
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
     from AZ_TAXONOMIES_B
     where TAXONOMY_CODE = X_TAXONOMY_CODE
     and   USER_ID = X_USER_ID;

     if (luby = 1) then
         AZ_TAXONOMIES_PKG.UPDATE_ROW(
                   X_TAXONOMY_CODE => X_TAXONOMY_CODE,
                   X_USER_ID => X_USER_ID,
		   X_ENABLED_FLAG => X_ENABLED_FLAG,
                   X_TAXONOMY_NAME => X_TAXONOMY_NAME,
                   X_TAXONOMY_DESC => X_TAXONOMY_DESC,
                   X_LAST_UPDATE_DATE => sysdate,
                   X_LAST_UPDATED_BY => l_owner_id,
                   X_LAST_UPDATE_LOGIN => 0
                );
     end if; -- if luby = 1

    exception
    when NO_DATA_FOUND then

         AZ_TAXONOMIES_PKG.INSERT_ROW(
                   X_ROWID => l_row_id,
                   X_TAXONOMY_CODE => X_TAXONOMY_CODE,
                   X_USER_ID => X_USER_ID,
		   X_ENABLED_FLAG => X_ENABLED_FLAG,
                   X_TAXONOMY_NAME => X_TAXONOMY_NAME,
                   X_TAXONOMY_DESC => X_TAXONOMY_DESC,
                   X_CREATION_DATE => sysdate,
                   X_CREATED_BY => l_owner_id,
                   X_LAST_UPDATE_DATE => sysdate,
                   X_LAST_UPDATED_BY => l_owner_id,
                   X_LAST_UPDATE_LOGIN => 0
                 );

    end;

end LOAD_ROW;

end AZ_TAXONOMIES_PKG;

/
