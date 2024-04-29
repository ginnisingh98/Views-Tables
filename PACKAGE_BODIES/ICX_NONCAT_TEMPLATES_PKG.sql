--------------------------------------------------------
--  DDL for Package Body ICX_NONCAT_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_NONCAT_TEMPLATES_PKG" AS
/* $Header: ICXNTMPB.pls 120.2 2006/03/09 03:36:26 rdey noship $ */

procedure INSERT_ROW (
  X_ROWID             in out NOCOPY VARCHAR2,
  X_TEMPLATE_ID       in NUMBER,
  X_ORG_ID            in NUMBER,
  X_TEMPLATE_NAME     in VARCHAR2,
  X_ITEM_DESCRIPTION  in VARCHAR2,
  X_CREATION_DATE     in DATE,
  X_CREATED_BY        in NUMBER,
  X_LAST_UPDATE_DATE  in DATE,
  X_LAST_UPDATED_BY   in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from POR_NONCAT_TEMPLATES_ALL_B
    where TEMPLATE_ID = X_TEMPLATE_ID;
begin

  insert into POR_NONCAT_TEMPLATES_ALL_B (
    TEMPLATE_ID,
    ORG_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    RFQ_REQUIRED_FLAG,
    RFQ_REQ_EDITABLE_FLAG
  ) values (
    X_TEMPLATE_ID,
    X_ORG_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    'N',
    'Y'
  );

  insert into POR_NONCAT_TEMPLATES_ALL_TL (
    TEMPLATE_ID,
    TEMPLATE_NAME,
    ITEM_DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TEMPLATE_ID,
    X_TEMPLATE_NAME,
    X_ITEM_DESCRIPTION,
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
    from  POR_NONCAT_TEMPLATES_ALL_TL T
    where T.TEMPLATE_ID = X_TEMPLATE_ID
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
  X_TEMPLATE_ID       in NUMBER,
  X_ORG_ID            in NUMBER,
  X_TEMPLATE_NAME     in VARCHAR2,
  X_ITEM_DESCRIPTION  in VARCHAR2,
  X_LAST_UPDATE_DATE  in DATE,
  X_LAST_UPDATED_BY   in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update POR_NONCAT_TEMPLATES_ALL_B set
    ORG_ID = X_ORG_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where TEMPLATE_ID = X_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update POR_NONCAT_TEMPLATES_ALL_TL set
    TEMPLATE_NAME = X_TEMPLATE_NAME,
    ITEM_DESCRIPTION = X_ITEM_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TEMPLATE_ID = X_TEMPLATE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    insert into POR_NONCAT_TEMPLATES_ALL_TL (
      TEMPLATE_ID,
      TEMPLATE_NAME,
      ITEM_DESCRIPTION,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG
    ) values (
      X_TEMPLATE_ID,
      X_TEMPLATE_NAME,
      X_ITEM_DESCRIPTION,
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
  X_TEMPLATE_ID       in VARCHAR2,
  X_OWNER             in VARCHAR2,
  X_TEMPLATE_NAME     in VARCHAR2,
  X_ITEM_DESCRIPTION  in VARCHAR2,
  X_CUSTOM_MODE       in VARCHAR2,
  X_LAST_UPDATE_DATE  in VARCHAR2) IS
begin
  declare
    f_luby	number;	-- entity owner in file
    f_ludate  date;  -- entity update in file
    db_luby	number;	-- entity owner in db
    db_ludate	date;   -- entity update in db
  begin
    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.OWNER_ID(X_OWNER);
    f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into   db_luby, db_ludate
    from   POR_NONCAT_TEMPLATES_ALL_TL
    where  LANGUAGE = userenv('LANG')
    and    TEMPLATE_ID = to_number(X_TEMPLATE_ID);

    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date
    if (fnd_load_util.UPLOAD_TEST(
        p_file_id     => f_luby,
        p_file_lud     => f_ludate,
        p_db_id        => db_luby,
        p_db_lud       => db_ludate,
        p_custom_mode  => X_CUSTOM_MODE))
    then
      update POR_NONCAT_TEMPLATES_ALL_TL set
        TEMPLATE_NAME          = nvl(X_TEMPLATE_NAME, TEMPLATE_NAME),
        ITEM_DESCRIPTION   = nvl(X_ITEM_DESCRIPTION, ITEM_DESCRIPTION),
        last_update_date    = f_ludate,
        last_updated_by     = f_luby,
        last_update_login   = 0,
        source_lang         = userenv('LANG')
      where TEMPLATE_ID  = to_number(X_TEMPLATE_ID)
        and userenv('LANG') in (language, source_lang);
    end if;
  end;

end TRANSLATE_ROW;


procedure LOAD_ROW(
  X_TEMPLATE_ID       in VARCHAR2,
  X_OWNER             in VARCHAR2,
  X_ORG_ID            in VARCHAR2,
  X_TEMPLATE_NAME     in VARCHAR2,
  X_ITEM_DESCRIPTION  in VARCHAR2,
  X_CUSTOM_MODE       in VARCHAR2,
  X_LAST_UPDATE_DATE  in VARCHAR2) IS
begin

  declare
    row_id  varchar2(64);
    f_luby	number;	-- entity owner in file
    f_ludate  date;  -- entity update in file
    db_luby	number;	-- entity owner in db
    db_ludate	date;   -- entity update in db

  begin
    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.OWNER_ID(X_OWNER);
    f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into   db_luby, db_ludate
    from   POR_NONCAT_TEMPLATES_ALL_TL
    where  LANGUAGE = userenv('LANG')
    and    TEMPLATE_ID = to_number(X_TEMPLATE_ID);

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
      ICX_NONCAT_TEMPLATES_PKG.UPDATE_ROW (
        X_TEMPLATE_ID	=> to_number(X_TEMPLATE_ID),
        X_ORG_ID        => to_number(X_ORG_ID),
        X_TEMPLATE_NAME        => X_TEMPLATE_NAME,
        X_ITEM_DESCRIPTION => X_ITEM_DESCRIPTION,
      	X_LAST_UPDATE_DATE	=> f_ludate,
        X_LAST_UPDATED_BY	  => f_luby,
       	X_LAST_UPDATE_LOGIN	=> 0 );
    end if;
  exception
     when NO_DATA_FOUND then

       ICX_NONCAT_TEMPLATES_PKG.INSERT_ROW (
          X_ROWID			=> row_id,
          X_TEMPLATE_ID	=> to_number(X_TEMPLATE_ID),
          X_ORG_ID   => to_number(X_ORG_ID),
          X_TEMPLATE_NAME        => X_TEMPLATE_NAME,
          X_ITEM_DESCRIPTION => X_ITEM_DESCRIPTION,
          X_CREATION_DATE		=> f_ludate,
          X_CREATED_BY		=> f_luby,
          X_LAST_UPDATE_DATE	=> f_ludate,
          X_LAST_UPDATED_BY	=> f_luby,
          X_LAST_UPDATE_LOGIN	=> 0 );
  end;
end LOAD_ROW;


procedure ADD_LANGUAGE
is
begin
  delete from POR_NONCAT_TEMPLATES_ALL_TL T
  where not exists
    (select NULL
    from POR_NONCAT_TEMPLATES_ALL_B B
    where B.TEMPLATE_ID = T.TEMPLATE_ID
    );

  insert into POR_NONCAT_TEMPLATES_ALL_TL (
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    TEMPLATE_ID,
    TEMPLATE_NAME,
    ITEM_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.TEMPLATE_ID,
    B.TEMPLATE_NAME,
    B.ITEM_DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from POR_NONCAT_TEMPLATES_ALL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from POR_NONCAT_TEMPLATES_ALL_TL T
    where T.TEMPLATE_ID = B.TEMPLATE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end ICX_NONCAT_TEMPLATES_PKG;

/
