--------------------------------------------------------
--  DDL for Package Body FND_OAM_BF_CUST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_BF_CUST_PKG" as
/* $Header: AFOAMFCB.pls 115.0 2003/10/31 03:56:58 ppradhan noship $ */
procedure LOAD_ROW (
    X_BIZ_FLOW_KEY     in  VARCHAR2,
    X_MONITORED_FLAG	          in 	VARCHAR2,
    X_IS_TOP_LEVEL   in VARCHAR2,
    X_OWNER               in	VARCHAR2,
    X_FLOW_DISPLAY_NAME	in	VARCHAR2,
    X_DESCRIPTION		in	VARCHAR2) is
  begin

     fnd_oam_bf_cust_pkg.LOAD_ROW (
       X_BIZ_FLOW_KEY => X_BIZ_FLOW_KEY,
       X_MONITORED_FLAG => X_MONITORED_FLAG,
       X_IS_TOP_LEVEL => X_IS_TOP_LEVEL,
       X_OWNER => X_OWNER,
       X_FLOW_DISPLAY_NAME => X_FLOW_DISPLAY_NAME,
       X_DESCRIPTION => X_DESCRIPTION,
       x_custom_mode => '',
       x_last_update_date => '');
end LOAD_ROW;

procedure LOAD_ROW (
    X_BIZ_FLOW_KEY     in  VARCHAR2,
    X_MONITORED_FLAG	          in 	VARCHAR2,
    X_IS_TOP_LEVEL	          in 	VARCHAR2,
    X_OWNER               in	VARCHAR2,
    X_FLOW_DISPLAY_NAME	in	VARCHAR2,
    X_DESCRIPTION		in	VARCHAR2,
    x_custom_mode         in      varchar2,
    x_last_update_date    in      varchar2) is


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
        from   fnd_oam_bf_cust
        where  biz_flow_key = X_BIZ_FLOW_KEY;

      if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
        fnd_oam_bf_cust_pkg.UPDATE_ROW (
          X_BIZ_FLOW_KEY => X_BIZ_FLOW_KEY,
          X_MONITORED_FLAG => X_MONITORED_FLAG,
	  X_IS_TOP_LEVEL => X_IS_TOP_LEVEL,
          X_FLOW_DISPLAY_NAME => X_FLOW_DISPLAY_NAME,
          X_DESCRIPTION => X_DESCRIPTION,
          X_LAST_UPDATE_DATE => f_ludate,
          X_LAST_UPDATED_BY => f_luby,
          X_LAST_UPDATE_LOGIN => 0 );
        end if;
      exception
        when NO_DATA_FOUND then

        fnd_oam_bf_cust_pkg.INSERT_ROW (
          X_ROWID => row_id,
          X_BIZ_FLOW_KEY => X_BIZ_FLOW_KEY,
          X_MONITORED_FLAG => X_MONITORED_FLAG,
	  X_IS_TOP_LEVEL => X_IS_TOP_LEVEL,
          X_FLOW_DISPLAY_NAME => X_FLOW_DISPLAY_NAME,
          X_DESCRIPTION => X_DESCRIPTION,
          X_CREATION_DATE => f_ludate,
          X_CREATED_BY => f_luby,
          X_LAST_UPDATE_DATE => f_ludate,
          X_LAST_UPDATED_BY => f_luby,
          X_LAST_UPDATE_LOGIN => 0 );
    end;
end LOAD_ROW;

procedure TRANSLATE_ROW (
    X_BIZ_FLOW_KEY	          in 	VARCHAR2,
    X_OWNER                     in	VARCHAR2,
    X_FLOW_DISPLAY_NAME	in	VARCHAR2,
    X_DESCRIPTION		in	VARCHAR2) is
  begin

  FND_OAM_BF_CUST_PKG.translate_row(
    x_biz_flow_key => x_biz_flow_key,
    x_owner => x_owner,
    x_flow_display_name => x_flow_display_name,
    x_description => x_description,
    x_custom_mode => '',
    x_last_update_date => '');

end TRANSLATE_ROW;


procedure TRANSLATE_ROW (
    X_BIZ_FLOW_KEY	    in 	VARCHAR2,
    X_OWNER               in	VARCHAR2,
    X_FLOW_DISPLAY_NAME	in	VARCHAR2,
    X_DESCRIPTION		in	VARCHAR2,
    X_CUSTOM_MODE		in	VARCHAR2,
    X_LAST_UPDATE_DATE	in	VARCHAR2) is

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
      from fnd_oam_bf_cust_tl
      where biz_flow_key = X_BIZ_FLOW_KEY
      and LANGUAGE = userenv('LANG');

      if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
        update fnd_oam_bf_cust_tl set
          flow_display_name = nvl(X_FLOW_DISPLAY_NAME, flow_display_name),
          description         = nvl(X_DESCRIPTION, description),
          source_lang         = userenv('LANG'),
          last_update_date    = f_ludate,
          last_updated_by     = f_luby,
          last_update_login   = 0
        where biz_flow_key = X_BIZ_FLOW_KEY
          and userenv('LANG') in (language, source_lang);
      end if;
    exception
      when no_data_found then
        null;
    end;

end TRANSLATE_ROW;

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_BIZ_FLOW_KEY in VARCHAR2,
  X_MONITORED_FLAG in VARCHAR2,
  X_IS_TOP_LEVEL in VARCHAR2,
  X_FLOW_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_OAM_BF_CUST
    where BIZ_FLOW_KEY = X_BIZ_FLOW_KEY
    ;
begin
  insert into FND_OAM_BF_CUST (
    BIZ_FLOW_KEY,
    MONITORED_FLAG,
    IS_TOP_LEVEL,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_BIZ_FLOW_KEY,
    X_MONITORED_FLAG,
    X_IS_TOP_LEVEL,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_OAM_BF_CUST_TL (
    BIZ_FLOW_KEY,
    FLOW_DISPLAY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_BIZ_FLOW_KEY,
    X_FLOW_DISPLAY_NAME,
    X_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_OAM_BF_CUST_TL T
    where T.BIZ_FLOW_KEY = X_BIZ_FLOW_KEY
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
  X_BIZ_FLOW_KEY in VARCHAR2,
  X_MONITORED_FLAG in VARCHAR2,
  X_IS_TOP_LEVEL in VARCHAR2,
  X_FLOW_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      MONITORED_FLAG,
      IS_TOP_LEVEL
    from FND_OAM_BF_CUST
    where BIZ_FLOW_KEY = X_BIZ_FLOW_KEY
    for update of BIZ_FLOW_KEY nowait;
  recinfo c%rowtype;

  cursor c1 is select
      FLOW_DISPLAY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_OAM_BF_CUST_TL
    where BIZ_FLOW_KEY = X_BIZ_FLOW_KEY
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of BIZ_FLOW_KEY nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.MONITORED_FLAG = X_MONITORED_FLAG)
      AND (recinfo.IS_TOP_LEVEL = X_IS_TOP_LEVEL)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.FLOW_DISPLAY_NAME = X_FLOW_DISPLAY_NAME)
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
  X_BIZ_FLOW_KEY in VARCHAR2,
  X_MONITORED_FLAG in VARCHAR2,
  X_IS_TOP_LEVEL in VARCHAR2,
  X_FLOW_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_OAM_BF_CUST set
    MONITORED_FLAG = X_MONITORED_FLAG,
    IS_TOP_LEVEL = X_IS_TOP_LEVEL,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where BIZ_FLOW_KEY = X_BIZ_FLOW_KEY;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_OAM_BF_CUST_TL set
    FLOW_DISPLAY_NAME = X_FLOW_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where BIZ_FLOW_KEY = X_BIZ_FLOW_KEY
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_BIZ_FLOW_KEY in VARCHAR2
) is
begin
  delete from FND_OAM_BF_CUST_TL
  where BIZ_FLOW_KEY = X_BIZ_FLOW_KEY;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_OAM_BF_CUST
  where BIZ_FLOW_KEY = X_BIZ_FLOW_KEY;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FND_OAM_BF_CUST_TL T
  where not exists
    (select NULL
    from FND_OAM_BF_CUST B
    where B.BIZ_FLOW_KEY = T.BIZ_FLOW_KEY
    );

  update FND_OAM_BF_CUST_TL T set (
      FLOW_DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.FLOW_DISPLAY_NAME,
      B.DESCRIPTION
    from FND_OAM_BF_CUST_TL B
    where B.BIZ_FLOW_KEY = T.BIZ_FLOW_KEY
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.BIZ_FLOW_KEY,
      T.LANGUAGE
  ) in (select
      SUBT.BIZ_FLOW_KEY,
      SUBT.LANGUAGE
    from FND_OAM_BF_CUST_TL SUBB, FND_OAM_BF_CUST_TL SUBT
    where SUBB.BIZ_FLOW_KEY = SUBT.BIZ_FLOW_KEY
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.FLOW_DISPLAY_NAME <> SUBT.FLOW_DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FND_OAM_BF_CUST_TL (
    BIZ_FLOW_KEY,
    FLOW_DISPLAY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.BIZ_FLOW_KEY,
    B.FLOW_DISPLAY_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_OAM_BF_CUST_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_OAM_BF_CUST_TL T
    where T.BIZ_FLOW_KEY = B.BIZ_FLOW_KEY
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end FND_OAM_BF_CUST_PKG;

/
