--------------------------------------------------------
--  DDL for Package Body ICX_POR_ITEM_SOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_POR_ITEM_SOURCES_PKG" AS
/* $Header: ICXSRCB.pls 115.8 2004/03/31 18:47:15 vkartik ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ITEM_SOURCE_ID in NUMBER,
  X_TYPE in VARCHAR2,
  X_PROTOCOL_SUPPORTED in VARCHAR2,
  X_URL in VARCHAR2,
  X_IMAGE_URL in VARCHAR2,
  X_ITEM_SOURCE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ICX_POR_ITEM_SOURCES
    where ITEM_SOURCE_ID = X_ITEM_SOURCE_ID
    ;
begin

  insert into ICX_POR_ITEM_SOURCES (
    ITEM_SOURCE_ID,
    TYPE,
    PROTOCOL_SUPPORTED,
    URL,
    IMAGE_URL,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ITEM_SOURCE_ID,
    X_TYPE,
    X_PROTOCOL_SUPPORTED,
    X_URL,
    X_IMAGE_URL,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into ICX_POR_ITEM_SOURCES_TL (
    ITEM_SOURCE_ID,
    ITEM_SOURCE_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_ITEM_SOURCE_ID,
    X_ITEM_SOURCE_NAME,
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
    from ICX_POR_ITEM_SOURCES_TL T
    where T.ITEM_SOURCE_ID = X_ITEM_SOURCE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure UPDATE_ROW (
  X_ITEM_SOURCE_ID in NUMBER,
  X_TYPE in VARCHAR2,
  X_PROTOCOL_SUPPORTED in VARCHAR2,
  X_URL in VARCHAR2,
  X_IMAGE_URL in VARCHAR2,
  X_ITEM_SOURCE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ICX_POR_ITEM_SOURCES_TL set
    ITEM_SOURCE_NAME = X_ITEM_SOURCE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ITEM_SOURCE_ID = X_ITEM_SOURCE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    insert into ICX_POR_ITEM_SOURCES_TL (
     ITEM_SOURCE_ID,
     ITEM_SOURCE_NAME,
     DESCRIPTION,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN,
     LANGUAGE,
     SOURCE_LANG
    ) values (
     X_ITEM_SOURCE_ID,
     X_ITEM_SOURCE_NAME,
     X_DESCRIPTION,
     X_LAST_UPDATE_DATE,
     X_LAST_UPDATED_BY,
     X_LAST_UPDATE_DATE,
     X_LAST_UPDATED_BY,
     X_LAST_UPDATE_LOGIN,
     userenv('LANG'),
     userenv('LANG'));
  end if;
end UPDATE_ROW;

procedure TRANSLATE_ROW(
  X_ITEM_SOURCE_ID      in  VARCHAR2,
  X_OWNER               in  VARCHAR2,
  X_ITEM_SOURCE_NAME    in  VARCHAR2,
  X_DESCRIPTION         in  VARCHAR2,
  X_CUSTOM_MODE         in  VARCHAR2,
  X_LAST_UPDATE_DATE    in  VARCHAR2) IS
begin
 declare
    f_luby	  number;	-- entity owner in file
    f_ludate  date;  -- entity update in file
    db_luby	  number;	-- entity owner in db
    db_ludate	date; -- entity update in db
 begin
    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.OWNER_ID(X_OWNER);
    f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from   ICX_POR_ITEM_SOURCES_TL
    where  LANGUAGE = userenv('LANG')
    and    ITEM_SOURCE_ID = to_number(X_ITEM_SOURCE_ID);

    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date
    if (fnd_load_util.UPLOAD_TEST(
        p_file_id      => f_luby,
        p_file_lud     => f_ludate,
        p_db_id        => db_luby,
        p_db_lud       => db_ludate,
        p_custom_mode  => X_CUSTOM_MODE))
    then
      update icx_por_item_sources_tl set
        item_source_name    = nvl(X_ITEM_SOURCE_NAME, ITEM_SOURCE_NAME),
        description         = nvl(X_DESCRIPTION, DESCRIPTION),
        last_update_date    = sysdate,
        last_updated_by     = f_luby,
        last_update_login   = 0,
        source_lang         = userenv('LANG')
      where ITEM_SOURCE_ID  = to_number(X_ITEM_SOURCE_ID)
        and userenv('LANG') in (language, source_lang);
    end if;
  end;

end TRANSLATE_ROW;


procedure LOAD_ROW(
  X_ITEM_SOURCE_ID      in VARCHAR2,
  X_OWNER	              in VARCHAR2,
  X_ITEM_SOURCE_NAME    in VARCHAR2,
  X_DESCRIPTION         in VARCHAR2,
  X_TYPE                in VARCHAR2,
  X_PROTOCOL_SUPPORTED  in VARCHAR2,
  X_URL                 in VARCHAR2,
  X_IMAGE_URL           in VARCHAR2,
  X_CUSTOM_MODE         in VARCHAR2,
  X_LAST_UPDATE_DATE    in VARCHAR2) IS
begin

  declare
    row_id     varchar2(64);
    f_luby	number;	-- entity owner in file
    f_ludate  date;  -- entity update in file
    db_luby	number;	-- entity owner in db
    db_ludate	date;   -- entity update in db

  begin
    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.OWNER_ID(X_OWNER);
    f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from   ICX_POR_ITEM_SOURCES_TL
    where  LANGUAGE = userenv('LANG')
    and    ITEM_SOURCE_ID = to_number(X_ITEM_SOURCE_ID);

    -- Bug#3219138
    -- Always update the Type+Protocol_supported
    -- irrespective of customization. Cst should not change the
    -- type+protocol_supported values.
    update ICX_POR_ITEM_SOURCES set
      TYPE = X_TYPE,
      PROTOCOL_SUPPORTED = X_PROTOCOL_SUPPORTED,
      URL = X_URL,
      IMAGE_URL = X_IMAGE_URL,
      LAST_UPDATE_DATE = sysdate,
      LAST_UPDATED_BY = f_luby,
      LAST_UPDATE_LOGIN = 0
    where ITEM_SOURCE_ID = X_ITEM_SOURCE_ID;

    if (sql%notfound) then
      raise no_data_found;
    end if;

    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date
    if (fnd_load_util.UPLOAD_TEST(
        p_file_id      => f_luby,
        p_file_lud     => f_ludate,
        p_db_id        => db_luby,
        p_db_lud       => db_ludate,
        p_custom_mode  => X_CUSTOM_MODE))
    then
      ICX_POR_ITEM_SOURCES_PKG.UPDATE_ROW (
        X_ITEM_SOURCE_ID	    => to_number(X_ITEM_SOURCE_ID),
        X_TYPE			          => X_TYPE,
        X_PROTOCOL_SUPPORTED  => X_PROTOCOL_SUPPORTED,
        X_URL			            => X_URL,
        X_IMAGE_URL		        => X_IMAGE_URL,
        X_ITEM_SOURCE_NAME	  => X_ITEM_SOURCE_NAME,
        X_DESCRIPTION		      => X_DESCRIPTION,
        X_LAST_UPDATE_DATE	  => sysdate,
        X_LAST_UPDATED_BY	    => f_luby,
        X_LAST_UPDATE_LOGIN	  => 0 );
    end if;
  exception
    when NO_DATA_FOUND then
      ICX_POR_ITEM_SOURCES_PKG.INSERT_ROW (
        X_ROWID			          => row_id,
        X_ITEM_SOURCE_ID	    => to_number(X_ITEM_SOURCE_ID),
        X_TYPE			          => X_TYPE,
        X_PROTOCOL_SUPPORTED  => X_PROTOCOL_SUPPORTED,
        X_URL			            => X_URL,
        X_IMAGE_URL		        => X_IMAGE_URL,
        X_ITEM_SOURCE_NAME	  => X_ITEM_SOURCE_NAME,
        X_DESCRIPTION		      => X_DESCRIPTION,
        X_CREATION_DATE		    => sysdate,
        X_CREATED_BY		      => f_luby,
        X_LAST_UPDATE_DATE	  => sysdate,
        X_LAST_UPDATED_BY	    => f_luby,
        X_LAST_UPDATE_LOGIN	  => 0 );
  end;
end LOAD_ROW;


procedure ADD_LANGUAGE
is
begin
  delete from ICX_POR_ITEM_SOURCES_TL T
  where not exists
    (select NULL
    from ICX_POR_ITEM_SOURCES B
    where B.ITEM_SOURCE_ID = T.ITEM_SOURCE_ID
    );

/*
  update ICX_POR_ITEM_SOURCES_TL T set (
      ITEM_SOURCE_NAME,
      DESCRIPTION
    ) = (select
      B.ITEM_SOURCE_NAME,
      B.DESCRIPTION
    from ICX_POR_ITEM_SOURCES_TL B
    where B.ITEM_SOURCE_ID = T.ITEM_SOURCE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ITEM_SOURCE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ITEM_SOURCE_ID,
      SUBT.LANGUAGE
    from ICX_POR_ITEM_SOURCES_TL SUBB, ICX_POR_ITEM_SOURCES_TL SUBT
    where SUBB.ITEM_SOURCE_ID = SUBT.ITEM_SOURCE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.ITEM_SOURCE_NAME <> SUBT.ITEM_SOURCE_NAME
      or (SUBB.ITEM_SOURCE_NAME is null and SUBT.ITEM_SOURCE_NAME is not null)
      or (SUBB.ITEM_SOURCE_NAME is not null and SUBT.ITEM_SOURCE_NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/

  insert into ICX_POR_ITEM_SOURCES_TL (
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    ITEM_SOURCE_ID,
    ITEM_SOURCE_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.ITEM_SOURCE_ID,
    B.ITEM_SOURCE_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ICX_POR_ITEM_SOURCES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ICX_POR_ITEM_SOURCES_TL T
    where T.ITEM_SOURCE_ID = B.ITEM_SOURCE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end ICX_POR_ITEM_SOURCES_PKG;

/
