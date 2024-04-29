--------------------------------------------------------
--  DDL for Package Body AZ_STRUCTURE_APIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AZ_STRUCTURE_APIS_PKG" as
/* $Header: aztstrctapb.pls 115.1 2003/01/20 17:52:37 rpanda noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_STRUCTURE_CODE in VARCHAR2,
  X_ENTITY_CODE in VARCHAR2,
  X_PARENT_ENTITY_CODE in VARCHAR2,
  X_FILTERING_PARAMETER in LONG,
  X_DISPLAY_RECORDS_FLAG in VARCHAR2,
  X_API_CODE in VARCHAR2,
  X_ENTITY_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AZ_STRUCTURE_APIS_B
    where STRUCTURE_CODE = X_STRUCTURE_CODE
    and ENTITY_CODE = X_ENTITY_CODE
    ;
begin
  insert into AZ_STRUCTURE_APIS_B (
    PARENT_ENTITY_CODE,
    FILTERING_PARAMETER,
    DISPLAY_RECORDS_FLAG,
    STRUCTURE_CODE,
    ENTITY_CODE,
    API_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PARENT_ENTITY_CODE,
    X_FILTERING_PARAMETER,
    X_DISPLAY_RECORDS_FLAG,
    X_STRUCTURE_CODE,
    X_ENTITY_CODE,
    X_API_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AZ_STRUCTURE_APIS_TL (
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    ENTITY_NAME,
    ENTITY_CODE,
    STRUCTURE_CODE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_ENTITY_NAME,
    X_ENTITY_CODE,
    X_STRUCTURE_CODE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AZ_STRUCTURE_APIS_TL T
    where T.STRUCTURE_CODE = X_STRUCTURE_CODE
    and T.ENTITY_CODE = X_ENTITY_CODE
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
  X_ENTITY_CODE in VARCHAR2,
  X_PARENT_ENTITY_CODE in VARCHAR2,
  X_FILTERING_PARAMETER in LONG,
  X_DISPLAY_RECORDS_FLAG in VARCHAR2,
  X_API_CODE in VARCHAR2,
  X_ENTITY_NAME in VARCHAR2
) is
  cursor c is select
      PARENT_ENTITY_CODE,
      FILTERING_PARAMETER,
      DISPLAY_RECORDS_FLAG,
      API_CODE
    from AZ_STRUCTURE_APIS_B
    where STRUCTURE_CODE = X_STRUCTURE_CODE
    and ENTITY_CODE = X_ENTITY_CODE
    for update of STRUCTURE_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      ENTITY_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AZ_STRUCTURE_APIS_TL
    where STRUCTURE_CODE = X_STRUCTURE_CODE
    and ENTITY_CODE = X_ENTITY_CODE
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
  if (    ((recinfo.PARENT_ENTITY_CODE = X_PARENT_ENTITY_CODE)
           OR ((recinfo.PARENT_ENTITY_CODE is null) AND (X_PARENT_ENTITY_CODE is null)))
      AND ((recinfo.FILTERING_PARAMETER = X_FILTERING_PARAMETER)
           OR ((recinfo.FILTERING_PARAMETER is null) AND (X_FILTERING_PARAMETER is null)))
      AND (recinfo.DISPLAY_RECORDS_FLAG = X_DISPLAY_RECORDS_FLAG)
      AND ((recinfo.API_CODE = X_API_CODE)
           OR ((recinfo.API_CODE is null) AND (X_API_CODE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.ENTITY_NAME = X_ENTITY_NAME)
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
  X_ENTITY_CODE in VARCHAR2,
  X_PARENT_ENTITY_CODE in VARCHAR2,
  X_FILTERING_PARAMETER in LONG,
  X_DISPLAY_RECORDS_FLAG in VARCHAR2,
  X_API_CODE in VARCHAR2,
  X_ENTITY_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AZ_STRUCTURE_APIS_B set
    PARENT_ENTITY_CODE = X_PARENT_ENTITY_CODE,
    FILTERING_PARAMETER = X_FILTERING_PARAMETER,
    DISPLAY_RECORDS_FLAG = X_DISPLAY_RECORDS_FLAG,
    API_CODE = X_API_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where STRUCTURE_CODE = X_STRUCTURE_CODE
  and ENTITY_CODE = X_ENTITY_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AZ_STRUCTURE_APIS_TL set
    ENTITY_NAME = X_ENTITY_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where STRUCTURE_CODE = X_STRUCTURE_CODE
  and ENTITY_CODE = X_ENTITY_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_STRUCTURE_CODE in VARCHAR2,
  X_ENTITY_CODE in VARCHAR2
) is
begin
  delete from AZ_STRUCTURE_APIS_TL
  where STRUCTURE_CODE = X_STRUCTURE_CODE
  and ENTITY_CODE = X_ENTITY_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AZ_STRUCTURE_APIS_B
  where STRUCTURE_CODE = X_STRUCTURE_CODE
  and ENTITY_CODE = X_ENTITY_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AZ_STRUCTURE_APIS_TL T
  where not exists
    (select NULL
    from AZ_STRUCTURE_APIS_B B
    where B.STRUCTURE_CODE = T.STRUCTURE_CODE
    and B.ENTITY_CODE = T.ENTITY_CODE
    );

  update AZ_STRUCTURE_APIS_TL T set (
      ENTITY_NAME
    ) = (select
      B.ENTITY_NAME
    from AZ_STRUCTURE_APIS_TL B
    where B.STRUCTURE_CODE = T.STRUCTURE_CODE
    and B.ENTITY_CODE = T.ENTITY_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.STRUCTURE_CODE,
      T.ENTITY_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.STRUCTURE_CODE,
      SUBT.ENTITY_CODE,
      SUBT.LANGUAGE
    from AZ_STRUCTURE_APIS_TL SUBB, AZ_STRUCTURE_APIS_TL SUBT
    where SUBB.STRUCTURE_CODE = SUBT.STRUCTURE_CODE
    and SUBB.ENTITY_CODE = SUBT.ENTITY_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.ENTITY_NAME <> SUBT.ENTITY_NAME
  ));

  insert into AZ_STRUCTURE_APIS_TL (
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    ENTITY_NAME,
    ENTITY_CODE,
    STRUCTURE_CODE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.ENTITY_NAME,
    B.ENTITY_CODE,
    B.STRUCTURE_CODE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AZ_STRUCTURE_APIS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AZ_STRUCTURE_APIS_TL T
    where T.STRUCTURE_CODE = B.STRUCTURE_CODE
    and T.ENTITY_CODE = B.ENTITY_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
	X_STRUCTURE_CODE    in   VARCHAR2,
        X_ENTITY_CODE       in   VARCHAR2,
        X_ENTITY_NAME       in   VARCHAR2,
        X_OWNER             in   VARCHAR2
        ) IS
begin
    update AZ_STRUCTURE_APIS_TL set
        ENTITY_NAME = X_ENTITY_NAME,
        last_update_date   = sysdate,
        last_updated_by    = decode(X_OWNER, 'SEED', 1, 0),
        last_update_login  = 0,
        source_lang        = userenv('LANG')
      where STRUCTURE_CODE = X_STRUCTURE_CODE
      and   ENTITY_CODE = X_ENTITY_CODE
      and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

procedure LOAD_ROW (
        X_STRUCTURE_CODE    in   VARCHAR2,
        X_ENTITY_CODE       in   VARCHAR2,
        X_OWNER             in   VARCHAR2,
        X_API_CODE          in   VARCHAR2,
        X_FILTERING_PARAMETER  in   VARCHAR2,
        X_DISPLAY_RECORDS_FLAG in   VARCHAR2,
        X_PARENT_ENTITY_CODE   in VARCHAR2,
        X_ENTITY_NAME       in   VARCHAR2
      ) IS
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
     from AZ_STRUCTURE_APIS_B
     where STRUCTURE_CODE = X_STRUCTURE_CODE
     and   ENTITY_CODE = X_ENTITY_CODE;

     IF luby = 1 THEN
        AZ_STRUCTURE_APIS_PKG.UPDATE_ROW(
		X_STRUCTURE_CODE => X_STRUCTURE_CODE,
  		X_ENTITY_CODE    => X_ENTITY_CODE,
  		X_PARENT_ENTITY_CODE => X_PARENT_ENTITY_CODE,
  		X_FILTERING_PARAMETER => X_FILTERING_PARAMETER,
  		X_DISPLAY_RECORDS_FLAG => X_DISPLAY_RECORDS_FLAG,
  		X_API_CODE => X_API_CODE,
  		X_ENTITY_NAME => X_ENTITY_NAME,
  		X_LAST_UPDATE_DATE => sysdate,
  		X_LAST_UPDATED_BY => l_owner_id,
  		X_LAST_UPDATE_LOGIN => 0
            );
     END IF;  -- if luby = 1

   exception
    when NO_DATA_FOUND then
	AZ_STRUCTURE_APIS_PKG.INSERT_ROW(
		   X_ROWID => l_row_id,
                   X_STRUCTURE_CODE => X_STRUCTURE_CODE,
                   X_ENTITY_CODE => X_ENTITY_CODE,
                   X_PARENT_ENTITY_CODE => X_PARENT_ENTITY_CODE,
                   X_FILTERING_PARAMETER => X_FILTERING_PARAMETER,
                   X_DISPLAY_RECORDS_FLAG => X_DISPLAY_RECORDS_FLAG,
                   X_API_CODE => X_API_CODE,
                   X_ENTITY_NAME => X_ENTITY_NAME,
                   X_CREATION_DATE => sysdate,
                   X_CREATED_BY => l_owner_id,
                   X_LAST_UPDATE_DATE => sysdate,
                   X_LAST_UPDATED_BY => l_owner_id,
                   X_LAST_UPDATE_LOGIN => 0

             );

   end;

end LOAD_ROW;

end AZ_STRUCTURE_APIS_PKG;

/
