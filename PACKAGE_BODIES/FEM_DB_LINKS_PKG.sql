--------------------------------------------------------
--  DDL for Package Body FEM_DB_LINKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_DB_LINKS_PKG" as
/* $Header: fem_db_links_pkb.plb 120.0 2005/06/06 20:34:48 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_DATABASE_LINK in VARCHAR2,
  X_MIG_WF_OUT_AGENT_IN_LOCAL_DB in VARCHAR2,
  X_MIG_WF_IN_AGENT_IN_LINKED_DB in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DB_LINK_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FEM_DB_LINKS_B
    where DATABASE_LINK = X_DATABASE_LINK
    ;
begin
  insert into FEM_DB_LINKS_B (
    MIG_WF_OUT_AGENT_IN_LOCAL_DB,
    DATABASE_LINK,
    MIG_WF_IN_AGENT_IN_LINKED_DB,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_MIG_WF_OUT_AGENT_IN_LOCAL_DB,
    X_DATABASE_LINK,
    X_MIG_WF_IN_AGENT_IN_LINKED_DB,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FEM_DB_LINKS_TL (
    DATABASE_LINK,
    DB_LINK_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DATABASE_LINK,
    X_DB_LINK_NAME,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FEM_DB_LINKS_TL T
    where T.DATABASE_LINK = X_DATABASE_LINK
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
  X_DATABASE_LINK in VARCHAR2,
  X_MIG_WF_OUT_AGENT_IN_LOCAL_DB in VARCHAR2,
  X_MIG_WF_IN_AGENT_IN_LINKED_DB in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DB_LINK_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      MIG_WF_OUT_AGENT_IN_LOCAL_DB,
      MIG_WF_IN_AGENT_IN_LINKED_DB,
      OBJECT_VERSION_NUMBER
    from FEM_DB_LINKS_B
    where DATABASE_LINK = X_DATABASE_LINK
    for update of DATABASE_LINK nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DB_LINK_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FEM_DB_LINKS_TL
    where DATABASE_LINK = X_DATABASE_LINK
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DATABASE_LINK nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.MIG_WF_OUT_AGENT_IN_LOCAL_DB = X_MIG_WF_OUT_AGENT_IN_LOCAL_DB)
           OR ((recinfo.MIG_WF_OUT_AGENT_IN_LOCAL_DB is null) AND (X_MIG_WF_OUT_AGENT_IN_LOCAL_DB is null)))
      AND ((recinfo.MIG_WF_IN_AGENT_IN_LINKED_DB = X_MIG_WF_IN_AGENT_IN_LINKED_DB)
           OR ((recinfo.MIG_WF_IN_AGENT_IN_LINKED_DB is null) AND (X_MIG_WF_IN_AGENT_IN_LINKED_DB is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DB_LINK_NAME = X_DB_LINK_NAME)
               OR ((tlinfo.DB_LINK_NAME is null) AND (X_DB_LINK_NAME is null)))
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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
  X_DATABASE_LINK in VARCHAR2,
  X_MIG_WF_OUT_AGENT_IN_LOCAL_DB in VARCHAR2,
  X_MIG_WF_IN_AGENT_IN_LINKED_DB in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DB_LINK_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FEM_DB_LINKS_B set
    MIG_WF_OUT_AGENT_IN_LOCAL_DB = X_MIG_WF_OUT_AGENT_IN_LOCAL_DB,
    MIG_WF_IN_AGENT_IN_LINKED_DB = X_MIG_WF_IN_AGENT_IN_LINKED_DB,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where DATABASE_LINK = X_DATABASE_LINK;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FEM_DB_LINKS_TL set
    DB_LINK_NAME = X_DB_LINK_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DATABASE_LINK = X_DATABASE_LINK
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DATABASE_LINK in VARCHAR2
) is
begin
  delete from FEM_DB_LINKS_TL
  where DATABASE_LINK = X_DATABASE_LINK;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FEM_DB_LINKS_B
  where DATABASE_LINK = X_DATABASE_LINK;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FEM_DB_LINKS_TL T
  where not exists
    (select NULL
    from FEM_DB_LINKS_B B
    where B.DATABASE_LINK = T.DATABASE_LINK
    );

  update FEM_DB_LINKS_TL T set (
      DB_LINK_NAME,
      DESCRIPTION
    ) = (select
      B.DB_LINK_NAME,
      B.DESCRIPTION
    from FEM_DB_LINKS_TL B
    where B.DATABASE_LINK = T.DATABASE_LINK
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DATABASE_LINK,
      T.LANGUAGE
  ) in (select
      SUBT.DATABASE_LINK,
      SUBT.LANGUAGE
    from FEM_DB_LINKS_TL SUBB, FEM_DB_LINKS_TL SUBT
    where SUBB.DATABASE_LINK = SUBT.DATABASE_LINK
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DB_LINK_NAME <> SUBT.DB_LINK_NAME
      or (SUBB.DB_LINK_NAME is null and SUBT.DB_LINK_NAME is not null)
      or (SUBB.DB_LINK_NAME is not null and SUBT.DB_LINK_NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FEM_DB_LINKS_TL (
    DATABASE_LINK,
    DB_LINK_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.DATABASE_LINK,
    B.DB_LINK_NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FEM_DB_LINKS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FEM_DB_LINKS_TL T
    where T.DATABASE_LINK = B.DATABASE_LINK
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
PROCEDURE TRANSLATE_ROW(
        x_DATABASE_LINK in varchar2,
        x_owner in varchar2,
        x_last_update_date in varchar2,
        x_DB_LINK_NAME in varchar2,
        x_description in varchar2,
        x_custom_mode in varchar2) is

        owner_id number;
        ludate date;
        row_id varchar2(64);
        f_luby    number;  -- entity owner in file
        f_ludate  date;    -- entity update date in file
        db_luby   number;  -- entity owner in db
        db_ludate date;    -- entity update date in db
    begin


        -- Translate owner to file_last_updated_by
        f_luby := fnd_load_util.owner_id(x_owner);

        -- Translate char last_update_date to date
        f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
        begin
          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from FEM_DB_LINKS_TL
          where DATABASE_LINK = x_DATABASE_LINK
          and LANGUAGE = userenv('LANG');

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, x_custom_mode)) then
            -- Update translations for this language
            update FEM_DB_LINKS_TL set
              DB_LINK_NAME = decode(x_DB_LINK_NAME,
			       fnd_load_util.null_value, null, -- Real null
			       null, x_DB_LINK_NAME,                  -- No change
			       x_DB_LINK_NAME),
              DESCRIPTION = nvl(x_description, DESCRIPTION),
              LAST_UPDATE_DATE = f_ludate,
              LAST_UPDATED_BY = f_luby,
              LAST_UPDATE_LOGIN = 0,
              SOURCE_LANG = userenv('LANG')
            where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
            and DATABASE_LINK = x_DATABASE_LINK;
         end if;
        exception
          when no_data_found then
            -- Do not insert missing translations, skip this row
            null;
        end;
     end TRANSLATE_ROW;


end FEM_DB_LINKS_PKG;

/
