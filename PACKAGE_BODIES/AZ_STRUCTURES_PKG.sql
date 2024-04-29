--------------------------------------------------------
--  DDL for Package Body AZ_STRUCTURES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AZ_STRUCTURES_PKG" as
/* $Header: aztstrctb.pls 120.2 2006/01/13 07:39:58 sbandi noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_STRUCTURE_CODE in VARCHAR2,
  X_HIERARCHICAL_FLAG in VARCHAR2,
  X_ACTIVE in VARCHAR2,
  X_STRUCTURE_NAME in VARCHAR2,
  X_STRUCTURE_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AZ_STRUCTURES_B
    where STRUCTURE_CODE = X_STRUCTURE_CODE
    ;
begin
  insert into AZ_STRUCTURES_B (
    STRUCTURE_CODE,
    HIERARCHICAL_FLAG,
    ACTIVE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_STRUCTURE_CODE,
    X_HIERARCHICAL_FLAG,
    X_ACTIVE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AZ_STRUCTURES_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    STRUCTURE_DESC,
    STRUCTURE_CODE,
    STRUCTURE_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_STRUCTURE_DESC,
    X_STRUCTURE_CODE,
    X_STRUCTURE_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AZ_STRUCTURES_TL T
    where T.STRUCTURE_CODE = X_STRUCTURE_CODE
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
  X_STRUCTURE_CODE in VARCHAR2,
  X_HIERARCHICAL_FLAG in VARCHAR2,
  X_STRUCTURE_NAME in VARCHAR2,
  X_STRUCTURE_DESC in VARCHAR2
) is
  cursor c is select
      HIERARCHICAL_FLAG
    from AZ_STRUCTURES_B
    where STRUCTURE_CODE = X_STRUCTURE_CODE
    for update of STRUCTURE_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      STRUCTURE_NAME,
      STRUCTURE_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AZ_STRUCTURES_TL
    where STRUCTURE_CODE = X_STRUCTURE_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of STRUCTURE_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.HIERARCHICAL_FLAG = X_HIERARCHICAL_FLAG)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.STRUCTURE_NAME = X_STRUCTURE_NAME)
               OR ((tlinfo.STRUCTURE_NAME is null) AND (X_STRUCTURE_NAME is null)))
          AND ((tlinfo.STRUCTURE_DESC = X_STRUCTURE_DESC)
               OR ((tlinfo.STRUCTURE_DESC is null) AND (X_STRUCTURE_DESC is null)))
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
  X_STRUCTURE_CODE in VARCHAR2,
  X_HIERARCHICAL_FLAG in VARCHAR2,
  X_ACTIVE in VARCHAR2,
  X_STRUCTURE_NAME in VARCHAR2,
  X_STRUCTURE_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AZ_STRUCTURES_B set
    HIERARCHICAL_FLAG = X_HIERARCHICAL_FLAG,
    ACTIVE = X_ACTIVE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where STRUCTURE_CODE = X_STRUCTURE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AZ_STRUCTURES_TL set
    STRUCTURE_NAME = X_STRUCTURE_NAME,
    STRUCTURE_DESC = X_STRUCTURE_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where STRUCTURE_CODE = X_STRUCTURE_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_STRUCTURE_CODE in VARCHAR2
) is
begin
  delete from AZ_STRUCTURES_TL
  where STRUCTURE_CODE = X_STRUCTURE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AZ_STRUCTURES_B
  where STRUCTURE_CODE = X_STRUCTURE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AZ_STRUCTURES_TL T
  where not exists
    (select NULL
    from AZ_STRUCTURES_B B
    where B.STRUCTURE_CODE = T.STRUCTURE_CODE
    );

  update AZ_STRUCTURES_TL T set (
      STRUCTURE_NAME,
      STRUCTURE_DESC
    ) = (select
      B.STRUCTURE_NAME,
      B.STRUCTURE_DESC
    from AZ_STRUCTURES_TL B
    where B.STRUCTURE_CODE = T.STRUCTURE_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.STRUCTURE_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.STRUCTURE_CODE,
      SUBT.LANGUAGE
    from AZ_STRUCTURES_TL SUBB, AZ_STRUCTURES_TL SUBT
    where SUBB.STRUCTURE_CODE = SUBT.STRUCTURE_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.STRUCTURE_NAME <> SUBT.STRUCTURE_NAME
      or (SUBB.STRUCTURE_NAME is null and SUBT.STRUCTURE_NAME is not null)
      or (SUBB.STRUCTURE_NAME is not null and SUBT.STRUCTURE_NAME is null)
      or SUBB.STRUCTURE_DESC <> SUBT.STRUCTURE_DESC
      or (SUBB.STRUCTURE_DESC is null and SUBT.STRUCTURE_DESC is not null)
      or (SUBB.STRUCTURE_DESC is not null and SUBT.STRUCTURE_DESC is null)
  ));

  insert into AZ_STRUCTURES_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    STRUCTURE_DESC,
    STRUCTURE_CODE,
    STRUCTURE_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.STRUCTURE_DESC,
    B.STRUCTURE_CODE,
    B.STRUCTURE_NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AZ_STRUCTURES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AZ_STRUCTURES_TL T
    where T.STRUCTURE_CODE = B.STRUCTURE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
     X_STRUCTURE_CODE      in VARCHAR2,
     X_STRUCTURE_NAME      in VARCHAR2,
     X_OWNER               in VARCHAR2,
     X_STRUCTURE_DESC      in VARCHAR2 ) is
begin
     update AZ_STRUCTURES_TL set
        STRUCTURE_NAME = X_STRUCTURE_NAME,
        STRUCTURE_DESC = X_STRUCTURE_DESC,
        last_update_date   = sysdate,
        last_updated_by    = decode(X_OWNER, 'SEED', 1, 0),
        last_update_login  = 0,
        source_lang        = userenv('LANG')
      where STRUCTURE_CODE = X_STRUCTURE_CODE
      and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

procedure LOAD_ROW (
        X_STRUCTURE_CODE        in   VARCHAR2,
        X_OWNER                 in   VARCHAR2,
        X_HIERARCHICAL_FLAG     in   VARCHAR2,
	X_ACTIVE                in   VARCHAR2,
        X_STRUCTURE_NAME        in   VARCHAR2,
        X_STRUCTURE_DESC        in   VARCHAR2) IS
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
     from AZ_STRUCTURES_B
     where STRUCTURE_CODE = X_STRUCTURE_CODE;

     IF luby = 1 THEN
         AZ_STRUCTURES_PKG.UPDATE_ROW(
                   X_STRUCTURE_CODE => X_STRUCTURE_CODE,
                   X_HIERARCHICAL_FLAG => X_HIERARCHICAL_FLAG,
		   X_ACTIVE => X_ACTIVE,
                   X_STRUCTURE_NAME => X_STRUCTURE_NAME,
                   X_STRUCTURE_DESC => X_STRUCTURE_DESC,
                   X_LAST_UPDATE_DATE => sysdate,
                   X_LAST_UPDATED_BY => l_owner_id,
                   X_LAST_UPDATE_LOGIN => 0
                );
     END IF; -- if luby = 1

    exception
    when NO_DATA_FOUND then

         AZ_STRUCTURES_PKG.INSERT_ROW(
                   X_ROWID => l_row_id,
                   X_STRUCTURE_CODE => X_STRUCTURE_CODE,
                   X_HIERARCHICAL_FLAG => X_HIERARCHICAL_FLAG,
		   X_ACTIVE => X_ACTIVE,
                   X_STRUCTURE_NAME => X_STRUCTURE_NAME,
                   X_STRUCTURE_DESC => X_STRUCTURE_DESC,
                   X_CREATION_DATE => sysdate,
                   X_CREATED_BY => l_owner_id,
                   X_LAST_UPDATE_DATE => sysdate,
                   X_LAST_UPDATED_BY => l_owner_id,
                   X_LAST_UPDATE_LOGIN => 0
                 );

    end;

end LOAD_ROW;

end AZ_STRUCTURES_PKG;

/
