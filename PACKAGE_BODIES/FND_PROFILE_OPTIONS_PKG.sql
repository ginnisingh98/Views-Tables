--------------------------------------------------------
--  DDL for Package Body FND_PROFILE_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_PROFILE_OPTIONS_PKG" as
/* $Header: AFPOMPOB.pls 120.4 2008/01/24 16:14:07 pdeluna ship $ */

-- ### OVERLOADED!
procedure INSERT_ROW (
  X_ROWID                        in out   NOCOPY VARCHAR2,
  X_PROFILE_OPTION_NAME          in    VARCHAR2,
  X_APPLICATION_ID               in NUMBER,
  X_PROFILE_OPTION_ID            in    NUMBER,
  X_WRITE_ALLOWED_FLAG           in    VARCHAR2,
  X_READ_ALLOWED_FLAG            in    VARCHAR2,
  X_USER_CHANGEABLE_FLAG         in    VARCHAR2,
  X_USER_VISIBLE_FLAG            in    VARCHAR2,
  X_SITE_ENABLED_FLAG            in    VARCHAR2,
  X_SITE_UPDATE_ALLOWED_FLAG     in    VARCHAR2,
  X_APP_ENABLED_FLAG             in    VARCHAR2,
  X_APP_UPDATE_ALLOWED_FLAG      in    VARCHAR2,
  X_RESP_ENABLED_FLAG            in    VARCHAR2,
  X_RESP_UPDATE_ALLOWED_FLAG     in    VARCHAR2,
  X_USER_ENABLED_FLAG            in    VARCHAR2,
  X_USER_UPDATE_ALLOWED_FLAG     in    VARCHAR2,
  X_START_DATE_ACTIVE            in    DATE,
  X_SQL_VALIDATION               in    VARCHAR2,
  X_END_DATE_ACTIVE              in    DATE,
  X_USER_PROFILE_OPTION_NAME     in    VARCHAR2,
  X_DESCRIPTION                  in    VARCHAR2,
  X_CREATION_DATE                in    DATE,
  X_CREATED_BY                   in    NUMBER,
  X_LAST_UPDATE_DATE             in    DATE,
  X_LAST_UPDATED_BY              in    NUMBER,
  X_LAST_UPDATE_LOGIN            in    NUMBER,
  X_HIERARCHY_TYPE               in      VARCHAR2 default 'SECURITY',
  X_SERVER_ENABLED_FLAG          in      VARCHAR2 default 'N',
  X_SERVER_UPDATE_ALLOWED_FLAG   in      VARCHAR2 default 'N',
  X_ORG_ENABLED_FLAG             in      VARCHAR2 default 'N',
  X_ORG_UPDATE_ALLOWED_FLAG      in      VARCHAR2 default 'N',
  X_SERVERRESP_ENABLED_FLAG      in      VARCHAR2,
  X_SERVERRESP_UPD_ALLOW_FL      in      VARCHAR2
) is

  L_PROFILE_OPTION_NAME    VARCHAR2(80) := UPPER(X_PROFILE_OPTION_NAME);
  cursor C is select ROWID from FND_PROFILE_OPTIONS
    where PROFILE_OPTION_NAME = L_PROFILE_OPTION_NAME;
begin

  insert into FND_PROFILE_OPTIONS (
    APPLICATION_ID,
    PROFILE_OPTION_ID,
    PROFILE_OPTION_NAME,
    WRITE_ALLOWED_FLAG,
    READ_ALLOWED_FLAG,
    USER_CHANGEABLE_FLAG,
    USER_VISIBLE_FLAG,
    SITE_ENABLED_FLAG,
    SITE_UPDATE_ALLOWED_FLAG,
    APP_ENABLED_FLAG,
    APP_UPDATE_ALLOWED_FLAG,
    RESP_ENABLED_FLAG,
    RESP_UPDATE_ALLOWED_FLAG,
    USER_ENABLED_FLAG,
    USER_UPDATE_ALLOWED_FLAG,
    START_DATE_ACTIVE,
    SQL_VALIDATION,
    END_DATE_ACTIVE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    HIERARCHY_TYPE,
    SERVER_ENABLED_FLAG,
    SERVER_UPDATE_ALLOWED_FLAG,
    ORG_ENABLED_FLAG,
    ORG_UPDATE_ALLOWED_FLAG,
    SERVERRESP_ENABLED_FLAG,
    SERVERRESP_UPDATE_ALLOWED_FLAG
  ) values (
    X_APPLICATION_ID,
    X_PROFILE_OPTION_ID,
    L_PROFILE_OPTION_NAME,
    X_WRITE_ALLOWED_FLAG,
    X_READ_ALLOWED_FLAG,
    X_USER_CHANGEABLE_FLAG,
    X_USER_VISIBLE_FLAG,
    X_SITE_ENABLED_FLAG,
    X_SITE_UPDATE_ALLOWED_FLAG,
    X_APP_ENABLED_FLAG,
    X_APP_UPDATE_ALLOWED_FLAG,
    X_RESP_ENABLED_FLAG,
    X_RESP_UPDATE_ALLOWED_FLAG,
    X_USER_ENABLED_FLAG,
    X_USER_UPDATE_ALLOWED_FLAG,
    X_START_DATE_ACTIVE,
    X_SQL_VALIDATION,
    X_END_DATE_ACTIVE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_HIERARCHY_TYPE,
    X_SERVER_ENABLED_FLAG,
    X_SERVER_UPDATE_ALLOWED_FLAG,
    X_ORG_ENABLED_FLAG,
    X_ORG_UPDATE_ALLOWED_FLAG,
    X_SERVERRESP_ENABLED_FLAG,
    X_SERVERRESP_UPD_ALLOW_FL
  );

  insert into FND_PROFILE_OPTIONS_TL (
    PROFILE_OPTION_NAME,
    USER_PROFILE_OPTION_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    L_PROFILE_OPTION_NAME,
    X_USER_PROFILE_OPTION_NAME,
    X_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from  FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and   not exists
    (select NULL
     from   FND_PROFILE_OPTIONS_TL T
     where  T.PROFILE_OPTION_NAME = L_PROFILE_OPTION_NAME
     and    T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

-- ### OVERLOADED!
procedure INSERT_ROW (
  X_ROWID                        in out   NOCOPY VARCHAR2,
  X_PROFILE_OPTION_NAME          in VARCHAR2,
  X_APPLICATION_ID               in NUMBER,
  X_PROFILE_OPTION_ID            in NUMBER,
  X_WRITE_ALLOWED_FLAG           in VARCHAR2,
  X_READ_ALLOWED_FLAG            in VARCHAR2,
  X_USER_CHANGEABLE_FLAG         in VARCHAR2,
  X_USER_VISIBLE_FLAG            in VARCHAR2,
  X_SITE_ENABLED_FLAG            in VARCHAR2,
  X_SITE_UPDATE_ALLOWED_FLAG     in VARCHAR2,
  X_APP_ENABLED_FLAG             in VARCHAR2,
  X_APP_UPDATE_ALLOWED_FLAG      in VARCHAR2,
  X_RESP_ENABLED_FLAG            in VARCHAR2,
  X_RESP_UPDATE_ALLOWED_FLAG     in VARCHAR2,
  X_USER_ENABLED_FLAG            in VARCHAR2,
  X_USER_UPDATE_ALLOWED_FLAG     in VARCHAR2,
  X_START_DATE_ACTIVE            in DATE,
  X_SQL_VALIDATION               in VARCHAR2,
  X_END_DATE_ACTIVE              in DATE,
  X_USER_PROFILE_OPTION_NAME     in VARCHAR2,
  X_DESCRIPTION                  in VARCHAR2,
  X_CREATION_DATE                in DATE,
  X_CREATED_BY                   in NUMBER,
  X_LAST_UPDATE_DATE             in DATE,
  X_LAST_UPDATED_BY              in NUMBER,
  X_LAST_UPDATE_LOGIN            in NUMBER,
  X_HIERARCHY_TYPE               in      VARCHAR2 default 'SECURITY',
  X_SERVER_ENABLED_FLAG          in      VARCHAR2 default 'N',
  X_SERVER_UPDATE_ALLOWED_FLAG   in      VARCHAR2 default 'N',
  X_ORG_ENABLED_FLAG             in      VARCHAR2 default 'N',
  X_ORG_UPDATE_ALLOWED_FLAG      in      VARCHAR2 default 'N'
) is
begin
fnd_profile_options_pkg.INSERT_ROW(
  X_ROWID                        => X_ROWID,
  X_PROFILE_OPTION_NAME          => X_PROFILE_OPTION_NAME,
  X_APPLICATION_ID               => X_APPLICATION_ID,
  X_PROFILE_OPTION_ID            => X_PROFILE_OPTION_ID,
  X_WRITE_ALLOWED_FLAG           => X_WRITE_ALLOWED_FLAG,
  X_READ_ALLOWED_FLAG            => X_READ_ALLOWED_FLAG,
  X_USER_CHANGEABLE_FLAG         => X_USER_CHANGEABLE_FLAG,
  X_USER_VISIBLE_FLAG            => X_USER_VISIBLE_FLAG,
  X_SITE_ENABLED_FLAG            => X_SITE_ENABLED_FLAG,
  X_SITE_UPDATE_ALLOWED_FLAG     => X_SITE_UPDATE_ALLOWED_FLAG,
  X_APP_ENABLED_FLAG             => X_APP_ENABLED_FLAG,
  X_APP_UPDATE_ALLOWED_FLAG      => X_APP_UPDATE_ALLOWED_FLAG,
  X_RESP_ENABLED_FLAG            => X_RESP_ENABLED_FLAG,
  X_RESP_UPDATE_ALLOWED_FLAG     => X_RESP_UPDATE_ALLOWED_FLAG,
  X_USER_ENABLED_FLAG            => X_USER_ENABLED_FLAG,
  X_USER_UPDATE_ALLOWED_FLAG     => X_USER_UPDATE_ALLOWED_FLAG,
  X_START_DATE_ACTIVE            => X_START_DATE_ACTIVE,
  X_SQL_VALIDATION               => X_SQL_VALIDATION,
  X_END_DATE_ACTIVE              => X_END_DATE_ACTIVE,
  X_USER_PROFILE_OPTION_NAME     => X_USER_PROFILE_OPTION_NAME,
  X_DESCRIPTION                  => X_DESCRIPTION,
  X_CREATION_DATE                => X_CREATION_DATE,
  X_CREATED_BY                   => X_CREATED_BY,
  X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
  X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
  X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN,
  X_HIERARCHY_TYPE               => X_HIERARCHY_TYPE,
  X_SERVER_ENABLED_FLAG          => X_SERVER_ENABLED_FLAG,
  X_SERVER_UPDATE_ALLOWED_FLAG   => X_SERVER_UPDATE_ALLOWED_FLAG,
  X_ORG_ENABLED_FLAG             => X_ORG_ENABLED_FLAG,
  X_ORG_UPDATE_ALLOWED_FLAG      => X_ORG_UPDATE_ALLOWED_FLAG,
  X_SERVERRESP_ENABLED_FLAG      => 'N',
  X_SERVERRESP_UPD_ALLOW_FL      => 'N'
);
end INSERT_ROW;

-- ### OVERLOADED!
procedure LOCK_ROW (
  X_PROFILE_OPTION_NAME         in VARCHAR2,
  X_APPLICATION_ID              in NUMBER,
  X_PROFILE_OPTION_ID           in NUMBER,
  X_WRITE_ALLOWED_FLAG          in VARCHAR2,
  X_READ_ALLOWED_FLAG           in VARCHAR2,
  X_USER_CHANGEABLE_FLAG        in VARCHAR2,
  X_USER_VISIBLE_FLAG           in VARCHAR2,
  X_SITE_ENABLED_FLAG           in VARCHAR2,
  X_SITE_UPDATE_ALLOWED_FLAG    in VARCHAR2,
  X_APP_ENABLED_FLAG            in VARCHAR2,
  X_APP_UPDATE_ALLOWED_FLAG     in VARCHAR2,
  X_RESP_ENABLED_FLAG           in VARCHAR2,
  X_RESP_UPDATE_ALLOWED_FLAG    in VARCHAR2,
  X_USER_ENABLED_FLAG           in VARCHAR2,
  X_USER_UPDATE_ALLOWED_FLAG    in VARCHAR2,
  X_START_DATE_ACTIVE           in DATE,
  X_SQL_VALIDATION              in VARCHAR2,
  X_END_DATE_ACTIVE             in DATE,
  X_USER_PROFILE_OPTION_NAME    in VARCHAR2,
  X_DESCRIPTION                 in VARCHAR2,
  X_HIERARCHY_TYPE              in VARCHAR2 default 'SECURITY',
  X_SERVER_ENABLED_FLAG         in VARCHAR2 default 'N',
  X_SERVER_UPDATE_ALLOWED_FLAG  in VARCHAR2 default 'N',
  X_ORG_ENABLED_FLAG            in VARCHAR2 default 'N',
  X_ORG_UPDATE_ALLOWED_FLAG     in VARCHAR2 default 'N'
) is
begin
fnd_profile_options_pkg.LOCK_ROW(
  X_PROFILE_OPTION_NAME         =>   X_PROFILE_OPTION_NAME,
  X_APPLICATION_ID              =>   X_APPLICATION_ID,
  X_PROFILE_OPTION_ID           =>   X_PROFILE_OPTION_ID,
  X_WRITE_ALLOWED_FLAG          =>   X_WRITE_ALLOWED_FLAG,
  X_READ_ALLOWED_FLAG           =>   X_READ_ALLOWED_FLAG,
  X_USER_CHANGEABLE_FLAG        =>   X_USER_CHANGEABLE_FLAG,
  X_USER_VISIBLE_FLAG           =>   X_USER_VISIBLE_FLAG,
  X_SITE_ENABLED_FLAG           =>   X_SITE_ENABLED_FLAG,
  X_SITE_UPDATE_ALLOWED_FLAG    =>   X_SITE_UPDATE_ALLOWED_FLAG ,
  X_APP_ENABLED_FLAG            =>   X_APP_ENABLED_FLAG,
  X_APP_UPDATE_ALLOWED_FLAG     =>   X_APP_UPDATE_ALLOWED_FLAG,
  X_RESP_ENABLED_FLAG           =>   X_RESP_ENABLED_FLAG,
  X_RESP_UPDATE_ALLOWED_FLAG    =>   X_RESP_UPDATE_ALLOWED_FLAG,
  X_USER_ENABLED_FLAG           =>   X_USER_ENABLED_FLAG,
  X_USER_UPDATE_ALLOWED_FLAG    =>   X_USER_UPDATE_ALLOWED_FLAG,
  X_START_DATE_ACTIVE           =>   X_START_DATE_ACTIVE,
  X_SQL_VALIDATION              =>   X_SQL_VALIDATION,
  X_END_DATE_ACTIVE             =>   X_END_DATE_ACTIVE,
  X_USER_PROFILE_OPTION_NAME    =>   X_USER_PROFILE_OPTION_NAME,
  X_DESCRIPTION                 =>   X_DESCRIPTION,
  X_HIERARCHY_TYPE              =>   X_HIERARCHY_TYPE,
  X_SERVER_ENABLED_FLAG         =>   X_SERVER_ENABLED_FLAG,
  X_SERVER_UPDATE_ALLOWED_FLAG  =>   X_SERVER_UPDATE_ALLOWED_FLAG,
  X_ORG_ENABLED_FLAG            =>   X_ORG_ENABLED_FLAG,
  X_ORG_UPDATE_ALLOWED_FLAG     =>   X_ORG_UPDATE_ALLOWED_FLAG,
  X_SERVERRESP_ENABLED_FLAG     =>   'N',
  X_SERVERRESP_UPD_ALLOW_FL     =>   'N'
);
end LOCK_ROW;

-- ### OVERLOADED!
procedure LOCK_ROW (
  X_PROFILE_OPTION_NAME         in VARCHAR2,
  X_APPLICATION_ID              in NUMBER,
  X_PROFILE_OPTION_ID           in NUMBER,
  X_WRITE_ALLOWED_FLAG          in VARCHAR2,
  X_READ_ALLOWED_FLAG           in VARCHAR2,
  X_USER_CHANGEABLE_FLAG        in VARCHAR2,
  X_USER_VISIBLE_FLAG           in VARCHAR2,
  X_SITE_ENABLED_FLAG           in VARCHAR2,
  X_SITE_UPDATE_ALLOWED_FLAG    in VARCHAR2,
  X_APP_ENABLED_FLAG            in VARCHAR2,
  X_APP_UPDATE_ALLOWED_FLAG     in VARCHAR2,
  X_RESP_ENABLED_FLAG           in VARCHAR2,
  X_RESP_UPDATE_ALLOWED_FLAG    in VARCHAR2,
  X_USER_ENABLED_FLAG           in VARCHAR2,
  X_USER_UPDATE_ALLOWED_FLAG    in VARCHAR2,
  X_START_DATE_ACTIVE           in DATE,
  X_SQL_VALIDATION              in VARCHAR2,
  X_END_DATE_ACTIVE             in DATE,
  X_USER_PROFILE_OPTION_NAME    in VARCHAR2,
  X_DESCRIPTION                 in VARCHAR2,
  X_HIERARCHY_TYPE              in VARCHAR2 default 'SECURITY',
  X_SERVER_ENABLED_FLAG         in VARCHAR2 default 'N',
  X_SERVER_UPDATE_ALLOWED_FLAG  in VARCHAR2 default 'N',
  X_ORG_ENABLED_FLAG            in VARCHAR2 default 'N',
  X_ORG_UPDATE_ALLOWED_FLAG     in VARCHAR2 default 'N',
  X_SERVERRESP_ENABLED_FLAG     in VARCHAR2,
  X_SERVERRESP_UPD_ALLOW_FL     in VARCHAR2
) is

  L_PROFILE_OPTION_NAME    VARCHAR2(80):= UPPER(X_PROFILE_OPTION_NAME);
  cursor c is select
      APPLICATION_ID,
      PROFILE_OPTION_ID,
      WRITE_ALLOWED_FLAG,
      READ_ALLOWED_FLAG,
      USER_CHANGEABLE_FLAG,
      USER_VISIBLE_FLAG,
      SITE_ENABLED_FLAG,
      SITE_UPDATE_ALLOWED_FLAG,
      APP_ENABLED_FLAG,
      APP_UPDATE_ALLOWED_FLAG,
      RESP_ENABLED_FLAG,
      RESP_UPDATE_ALLOWED_FLAG,
      USER_ENABLED_FLAG,
      USER_UPDATE_ALLOWED_FLAG,
      START_DATE_ACTIVE,
      SQL_VALIDATION,
      END_DATE_ACTIVE,
      HIERARCHY_TYPE,
      SERVER_ENABLED_FLAG,
      SERVER_UPDATE_ALLOWED_FLAG,
      ORG_ENABLED_FLAG,
      ORG_UPDATE_ALLOWED_FLAG,
      SERVERRESP_ENABLED_FLAG,
      SERVERRESP_UPDATE_ALLOWED_FLAG
    from  FND_PROFILE_OPTIONS
    where PROFILE_OPTION_NAME = L_PROFILE_OPTION_NAME
    for   update of PROFILE_OPTION_NAME nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_PROFILE_OPTION_NAME,
      DESCRIPTION
    from  FND_PROFILE_OPTIONS_TL
    where PROFILE_OPTION_NAME = L_PROFILE_OPTION_NAME
    and   LANGUAGE = userenv('LANG')
    for   update of PROFILE_OPTION_NAME nowait;
  tlinfo c1%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND (recinfo.PROFILE_OPTION_ID = X_PROFILE_OPTION_ID)
      AND (recinfo.WRITE_ALLOWED_FLAG = X_WRITE_ALLOWED_FLAG)
      AND (recinfo.READ_ALLOWED_FLAG = X_READ_ALLOWED_FLAG)
      AND (recinfo.USER_CHANGEABLE_FLAG = X_USER_CHANGEABLE_FLAG)
      AND (recinfo.USER_VISIBLE_FLAG = X_USER_VISIBLE_FLAG)
      AND (recinfo.SITE_ENABLED_FLAG = X_SITE_ENABLED_FLAG)
      AND (recinfo.SITE_UPDATE_ALLOWED_FLAG = X_SITE_UPDATE_ALLOWED_FLAG)
      AND (recinfo.APP_ENABLED_FLAG = X_APP_ENABLED_FLAG)
      AND (recinfo.APP_UPDATE_ALLOWED_FLAG = X_APP_UPDATE_ALLOWED_FLAG)
      AND (recinfo.RESP_ENABLED_FLAG = X_RESP_ENABLED_FLAG)
      AND (recinfo.RESP_UPDATE_ALLOWED_FLAG = X_RESP_UPDATE_ALLOWED_FLAG)
      AND (recinfo.USER_ENABLED_FLAG = X_USER_ENABLED_FLAG)
      AND (recinfo.USER_UPDATE_ALLOWED_FLAG = X_USER_UPDATE_ALLOWED_FLAG)
      AND (recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
      AND ((recinfo.SQL_VALIDATION = X_SQL_VALIDATION)
           OR ((recinfo.SQL_VALIDATION is null) AND (X_SQL_VALIDATION is null)))
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
      AND (recinfo.HIERARCHY_TYPE = X_HIERARCHY_TYPE)
      AND (recinfo.SERVER_ENABLED_FLAG = X_SERVER_ENABLED_FLAG)
      AND (recinfo.SERVER_UPDATE_ALLOWED_FLAG = X_SERVER_UPDATE_ALLOWED_FLAG)
      AND (recinfo.ORG_ENABLED_FLAG = X_ORG_ENABLED_FLAG)
      AND (recinfo.ORG_UPDATE_ALLOWED_FLAG = X_ORG_UPDATE_ALLOWED_FLAG)
      AND (recinfo.SERVERRESP_ENABLED_FLAG = X_SERVERRESP_ENABLED_FLAG)
      AND (recinfo.SERVERRESP_UPDATE_ALLOWED_FLAG = X_SERVERRESP_UPD_ALLOW_FL)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    return;
  end if;
  close c1;

  if (    (tlinfo.USER_PROFILE_OPTION_NAME = X_USER_PROFILE_OPTION_NAME)
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;

end LOCK_ROW;

--Forward declaration
PROCEDURE UPDATE_APPL_ID_PK_COLUMNS( x_profile_option_name varchar2,
                                     x_profile_id varchar2,
                                     x_appl_id    varchar2);

-- Bug 5060938.
-- This api is used to propagate updation of profile from Application1 to
-- Application2 to Fnd_Profile_cat_Options table.
-- Drop this api after finding out a way to create Foreign_Key and
-- Primary_Key info in FND_FOREIGN_KEYS and FND_PRIMARY_KEYS AOL meta data
-- through fnd_profile_cat_options.xdf.
PROCEDURE UPDATE_CAT_OPTIONS_APPL_ID( x_profile_option_name varchar2,
                                      x_profile_id varchar2,
                                      x_appl_id    number);

-- ### OVERLOADED!
procedure UPDATE_ROW (
  X_PROFILE_OPTION_NAME         in VARCHAR2,
  X_APPLICATION_ID              in NUMBER,
  X_PROFILE_OPTION_ID           in NUMBER,
  X_WRITE_ALLOWED_FLAG          in VARCHAR2,
  X_READ_ALLOWED_FLAG           in VARCHAR2,
  X_USER_CHANGEABLE_FLAG        in VARCHAR2,
  X_USER_VISIBLE_FLAG           in VARCHAR2,
  X_SITE_ENABLED_FLAG           in VARCHAR2,
  X_SITE_UPDATE_ALLOWED_FLAG    in VARCHAR2,
  X_APP_ENABLED_FLAG            in VARCHAR2,
  X_APP_UPDATE_ALLOWED_FLAG     in VARCHAR2,
  X_RESP_ENABLED_FLAG           in VARCHAR2,
  X_RESP_UPDATE_ALLOWED_FLAG    in VARCHAR2,
  X_USER_ENABLED_FLAG           in VARCHAR2,
  X_USER_UPDATE_ALLOWED_FLAG    in VARCHAR2,
  X_START_DATE_ACTIVE           in DATE,
  X_SQL_VALIDATION              in VARCHAR2,
  X_END_DATE_ACTIVE             in DATE,
  X_USER_PROFILE_OPTION_NAME    in VARCHAR2,
  X_DESCRIPTION                 in VARCHAR2,
  X_LAST_UPDATE_DATE            in DATE,
  X_LAST_UPDATED_BY             in NUMBER,
  X_LAST_UPDATE_LOGIN           in NUMBER,
  X_HIERARCHY_TYPE              in VARCHAR2 default 'SECURITY',
  X_SERVER_ENABLED_FLAG         in VARCHAR2 default 'N',
  X_SERVER_UPDATE_ALLOWED_FLAG  in VARCHAR2 default 'N',
  X_ORG_ENABLED_FLAG            in VARCHAR2 default 'N',
  X_ORG_UPDATE_ALLOWED_FLAG     in VARCHAR2 default 'N',
  X_SERVERRESP_ENABLED_FLAG     in VARCHAR2,
  X_SERVERRESP_UPD_ALLOW_FL     in VARCHAR2,
  X_HIERARCHY_SWITCH_MODE       in FND_PROFILE_HIERARCHY_PKG.SWITCH_MODE
) is
  L_PROFILE_OPTION_NAME    VARCHAR2(80):= UPPER(X_PROFILE_OPTION_NAME);
begin

  update_appl_id_pk_columns(L_PROFILE_OPTION_NAME,x_profile_option_id,x_application_id);

  /** Remove this call after finding a way to create Foreign_Key info in AOL
   ** Meta data (Fnd_Foreign_Key and Fnd_Foreign_key_Columns table) using
   ** Fnd_Profile_Cat_Options.xdf. Right now though foreign key info is
   ** available in fnd_profile_cat_options.xdf, data is not uploaded into
   ** FND_FOREIGN_KEYS, FND_PRIMARY_KEYS (and it's COLUMN's table) when the
   ** above xdf is uploaded.
   **/
  UPDATE_CAT_OPTIONS_APPL_ID(L_PROFILE_OPTION_NAME,x_profile_option_id,x_application_id);

  FND_PROFILE_HIERARCHY_PKG.carry_profile_values(
         X_PROFILE_OPTION_NAME => L_PROFILE_OPTION_NAME,
         X_APPLICATION_ID      => X_APPLICATION_ID,
         X_PROFILE_OPTION_ID   => X_PROFILE_OPTION_ID,
         X_TO_HIERARCHY_TYPE   => X_HIERARCHY_TYPE,
         X_LAST_UPDATE_DATE    => X_LAST_UPDATE_DATE,
         X_LAST_UPDATED_BY     => X_LAST_UPDATED_BY,
         X_CREATION_DATE       => X_LAST_UPDATE_DATE,
         X_CREATED_BY          => X_LAST_UPDATED_BY,
         X_LAST_UPDATE_LOGIN   => X_LAST_UPDATE_LOGIN,
         X_MODE                => X_HIERARCHY_SWITCH_MODE
      );

  update FND_PROFILE_OPTIONS set
    APPLICATION_ID = X_APPLICATION_ID,
    PROFILE_OPTION_ID = X_PROFILE_OPTION_ID,
    WRITE_ALLOWED_FLAG = X_WRITE_ALLOWED_FLAG,
    READ_ALLOWED_FLAG = X_READ_ALLOWED_FLAG,
    USER_CHANGEABLE_FLAG = X_USER_CHANGEABLE_FLAG,
    USER_VISIBLE_FLAG = X_USER_VISIBLE_FLAG,
    SITE_ENABLED_FLAG = X_SITE_ENABLED_FLAG,
    SITE_UPDATE_ALLOWED_FLAG = X_SITE_UPDATE_ALLOWED_FLAG,
    APP_ENABLED_FLAG = X_APP_ENABLED_FLAG,
    APP_UPDATE_ALLOWED_FLAG = X_APP_UPDATE_ALLOWED_FLAG,
    RESP_ENABLED_FLAG = X_RESP_ENABLED_FLAG,
    RESP_UPDATE_ALLOWED_FLAG = X_RESP_UPDATE_ALLOWED_FLAG,
    USER_ENABLED_FLAG = X_USER_ENABLED_FLAG,
    USER_UPDATE_ALLOWED_FLAG = X_USER_UPDATE_ALLOWED_FLAG,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    SQL_VALIDATION = X_SQL_VALIDATION,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    HIERARCHY_TYPE = X_HIERARCHY_TYPE,
    SERVER_ENABLED_FLAG = X_SERVER_ENABLED_FLAG,
    SERVER_UPDATE_ALLOWED_FLAG = X_SERVER_UPDATE_ALLOWED_FLAG,
    ORG_ENABLED_FLAG = X_ORG_ENABLED_FLAG,
    ORG_UPDATE_ALLOWED_FLAG = X_ORG_UPDATE_ALLOWED_FLAG,
    SERVERRESP_ENABLED_FLAG = X_SERVERRESP_ENABLED_FLAG,
    SERVERRESP_UPDATE_ALLOWED_FLAG = X_SERVERRESP_UPD_ALLOW_FL
  where PROFILE_OPTION_NAME = L_PROFILE_OPTION_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_PROFILE_OPTIONS_TL set
    USER_PROFILE_OPTION_NAME = X_USER_PROFILE_OPTION_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PROFILE_OPTION_NAME = L_PROFILE_OPTION_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

-- ### OVERLOADED!
procedure UPDATE_ROW (
  X_PROFILE_OPTION_NAME    in VARCHAR2,
  X_APPLICATION_ID      in NUMBER,
  X_PROFILE_OPTION_ID      in NUMBER,
  X_WRITE_ALLOWED_FLAG     in VARCHAR2,
  X_READ_ALLOWED_FLAG      in VARCHAR2,
  X_USER_CHANGEABLE_FLAG   in VARCHAR2,
  X_USER_VISIBLE_FLAG      in VARCHAR2,
  X_SITE_ENABLED_FLAG      in VARCHAR2,
  X_SITE_UPDATE_ALLOWED_FLAG  in VARCHAR2,
  X_APP_ENABLED_FLAG       in VARCHAR2,
  X_APP_UPDATE_ALLOWED_FLAG   in VARCHAR2,
  X_RESP_ENABLED_FLAG      in VARCHAR2,
  X_RESP_UPDATE_ALLOWED_FLAG  in VARCHAR2,
  X_USER_ENABLED_FLAG      in VARCHAR2,
  X_USER_UPDATE_ALLOWED_FLAG  in VARCHAR2,
  X_START_DATE_ACTIVE      in DATE,
  X_SQL_VALIDATION      in VARCHAR2,
  X_END_DATE_ACTIVE     in DATE,
  X_USER_PROFILE_OPTION_NAME  in VARCHAR2,
  X_DESCRIPTION      in VARCHAR2,
  X_LAST_UPDATE_DATE       in DATE,
  X_LAST_UPDATED_BY     in NUMBER,
  X_LAST_UPDATE_LOGIN      in NUMBER,
  X_HIERARCHY_TYPE              in      VARCHAR2 default 'SECURITY',
  X_SERVER_ENABLED_FLAG         in      VARCHAR2 default 'N',
  X_SERVER_UPDATE_ALLOWED_FLAG  in      VARCHAR2 default 'N',
  X_ORG_ENABLED_FLAG            in      VARCHAR2 default 'N',
  X_ORG_UPDATE_ALLOWED_FLAG     in      VARCHAR2 default 'N'

) is

begin

  fnd_profile_options_pkg.update_row(
    X_PROFILE_OPTION_NAME => X_PROFILE_OPTION_NAME,
    X_APPLICATION_ID => X_APPLICATION_ID,
    X_PROFILE_OPTION_ID => X_PROFILE_OPTION_ID,
    X_WRITE_ALLOWED_FLAG => X_WRITE_ALLOWED_FLAG,
    X_READ_ALLOWED_FLAG => X_READ_ALLOWED_FLAG,
    X_USER_CHANGEABLE_FLAG => X_USER_CHANGEABLE_FLAG,
    X_USER_VISIBLE_FLAG => X_USER_VISIBLE_FLAG,
    X_SITE_ENABLED_FLAG => X_SITE_ENABLED_FLAG,
    X_SITE_UPDATE_ALLOWED_FLAG => X_SITE_UPDATE_ALLOWED_FLAG,
    X_APP_ENABLED_FLAG => X_APP_ENABLED_FLAG,
    X_APP_UPDATE_ALLOWED_FLAG => X_APP_UPDATE_ALLOWED_FLAG,
    X_RESP_ENABLED_FLAG => X_RESP_ENABLED_FLAG,
    X_RESP_UPDATE_ALLOWED_FLAG => X_RESP_UPDATE_ALLOWED_FLAG,
    X_USER_ENABLED_FLAG => X_USER_ENABLED_FLAG,
    X_USER_UPDATE_ALLOWED_FLAG => X_USER_UPDATE_ALLOWED_FLAG,
    X_START_DATE_ACTIVE => X_START_DATE_ACTIVE,
    X_SQL_VALIDATION => X_SQL_VALIDATION,
    X_END_DATE_ACTIVE => X_END_DATE_ACTIVE,
    X_USER_PROFILE_OPTION_NAME => X_USER_PROFILE_OPTION_NAME,
    X_DESCRIPTION => X_DESCRIPTION,
    X_LAST_UPDATE_DATE => X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY => X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN => X_LAST_UPDATE_LOGIN,
    X_HIERARCHY_TYPE => X_HIERARCHY_TYPE,
    X_SERVER_ENABLED_FLAG => X_SERVER_ENABLED_FLAG,
    X_SERVER_UPDATE_ALLOWED_FLAG => X_SERVER_UPDATE_ALLOWED_FLAG,
    X_ORG_ENABLED_FLAG => X_ORG_ENABLED_FLAG,
    X_ORG_UPDATE_ALLOWED_FLAG => X_ORG_UPDATE_ALLOWED_FLAG,
    X_SERVERRESP_ENABLED_FLAG => 'N',
    X_SERVERRESP_UPD_ALLOW_FL => 'N');


end UPDATE_ROW;

-- ### OVERLOADED!
procedure UPDATE_ROW (
  X_PROFILE_OPTION_NAME         in VARCHAR2,
  X_APPLICATION_ID              in NUMBER,
  X_PROFILE_OPTION_ID           in NUMBER,
  X_WRITE_ALLOWED_FLAG          in VARCHAR2,
  X_READ_ALLOWED_FLAG           in VARCHAR2,
  X_USER_CHANGEABLE_FLAG        in VARCHAR2,
  X_USER_VISIBLE_FLAG           in VARCHAR2,
  X_SITE_ENABLED_FLAG           in VARCHAR2,
  X_SITE_UPDATE_ALLOWED_FLAG    in VARCHAR2,
  X_APP_ENABLED_FLAG            in VARCHAR2,
  X_APP_UPDATE_ALLOWED_FLAG     in VARCHAR2,
  X_RESP_ENABLED_FLAG           in VARCHAR2,
  X_RESP_UPDATE_ALLOWED_FLAG    in VARCHAR2,
  X_USER_ENABLED_FLAG           in VARCHAR2,
  X_USER_UPDATE_ALLOWED_FLAG    in VARCHAR2,
  X_START_DATE_ACTIVE           in DATE,
  X_SQL_VALIDATION              in VARCHAR2,
  X_END_DATE_ACTIVE             in DATE,
  X_USER_PROFILE_OPTION_NAME    in VARCHAR2,
  X_DESCRIPTION                 in VARCHAR2,
  X_LAST_UPDATE_DATE            in DATE,
  X_LAST_UPDATED_BY             in NUMBER,
  X_LAST_UPDATE_LOGIN           in NUMBER,
  X_HIERARCHY_TYPE              in      VARCHAR2 default 'SECURITY',
  X_SERVER_ENABLED_FLAG         in      VARCHAR2 default 'N',
  X_SERVER_UPDATE_ALLOWED_FLAG  in      VARCHAR2 default 'N',
  X_ORG_ENABLED_FLAG            in      VARCHAR2 default 'N',
  X_ORG_UPDATE_ALLOWED_FLAG     in      VARCHAR2 default 'N',
  X_SERVERRESP_ENABLED_FLAG     in      VARCHAR2,
  X_SERVERRESP_UPD_ALLOW_FL     in      VARCHAR2
) is
begin
 fnd_profile_options_pkg.update_row(
    X_PROFILE_OPTION_NAME       =>  X_PROFILE_OPTION_NAME       ,
    X_APPLICATION_ID            =>  X_APPLICATION_ID            ,
    X_PROFILE_OPTION_ID         =>  X_PROFILE_OPTION_ID         ,
    X_WRITE_ALLOWED_FLAG        =>  X_WRITE_ALLOWED_FLAG        ,
    X_READ_ALLOWED_FLAG         =>  X_READ_ALLOWED_FLAG         ,
    X_USER_CHANGEABLE_FLAG      =>  X_USER_CHANGEABLE_FLAG      ,
    X_USER_VISIBLE_FLAG         =>  X_USER_VISIBLE_FLAG         ,
    X_SITE_ENABLED_FLAG         =>  X_SITE_ENABLED_FLAG         ,
    X_SITE_UPDATE_ALLOWED_FLAG  =>  X_SITE_UPDATE_ALLOWED_FLAG  ,
    X_APP_ENABLED_FLAG          =>  X_APP_ENABLED_FLAG          ,
    X_APP_UPDATE_ALLOWED_FLAG   =>  X_APP_UPDATE_ALLOWED_FLAG   ,
    X_RESP_ENABLED_FLAG         =>  X_RESP_ENABLED_FLAG         ,
    X_RESP_UPDATE_ALLOWED_FLAG  =>  X_RESP_UPDATE_ALLOWED_FLAG  ,
    X_USER_ENABLED_FLAG         =>  X_USER_ENABLED_FLAG         ,
    X_USER_UPDATE_ALLOWED_FLAG  =>  X_USER_UPDATE_ALLOWED_FLAG  ,
    X_START_DATE_ACTIVE         =>  X_START_DATE_ACTIVE         ,
    X_SQL_VALIDATION            =>  X_SQL_VALIDATION            ,
    X_END_DATE_ACTIVE           =>  X_END_DATE_ACTIVE           ,
    X_USER_PROFILE_OPTION_NAME  =>  X_USER_PROFILE_OPTION_NAME  ,
    X_DESCRIPTION               =>  X_DESCRIPTION               ,
    X_LAST_UPDATE_DATE          =>  X_LAST_UPDATE_DATE          ,
    X_LAST_UPDATED_BY           =>  X_LAST_UPDATED_BY           ,
    X_LAST_UPDATE_LOGIN         =>  X_LAST_UPDATE_LOGIN         ,
    X_HIERARCHY_TYPE            =>  X_HIERARCHY_TYPE            ,
    X_SERVER_ENABLED_FLAG       =>  X_SERVER_ENABLED_FLAG       ,
    X_SERVER_UPDATE_ALLOWED_FLAG=>  X_SERVER_UPDATE_ALLOWED_FLAG,
    X_ORG_ENABLED_FLAG          =>  X_ORG_ENABLED_FLAG          ,
    X_ORG_UPDATE_ALLOWED_FLAG   =>  X_ORG_UPDATE_ALLOWED_FLAG   ,
    X_SERVERRESP_ENABLED_FLAG   =>  X_SERVERRESP_ENABLED_FLAG   ,
    X_SERVERRESP_UPD_ALLOW_FL   =>  X_SERVERRESP_UPD_ALLOW_FL   ,
    X_HIERARCHY_SWITCH_MODE     =>  FND_PROFILE_HIERARCHY_PKG.INSERT_UPDATE );

end UPDATE_ROW;

-- ### OVERLOADED!

procedure UPDATE_ROW (
  X_PROFILE_OPTION_NAME         in      VARCHAR2,
  X_HIERARCHY_TYPE              in      VARCHAR2,
  X_SITE_ENABLED_FLAG           in      VARCHAR2 default NULL,
  X_SITE_UPDATE_ALLOWED_FLAG    in      VARCHAR2 default NULL,
  X_APP_ENABLED_FLAG            in      VARCHAR2 default NULL,
  X_APP_UPDATE_ALLOWED_FLAG     in      VARCHAR2 default NULL,
  X_RESP_ENABLED_FLAG           in      VARCHAR2 default NULL,
  X_RESP_UPDATE_ALLOWED_FLAG    in      VARCHAR2 default NULL,
  X_USER_ENABLED_FLAG           in      VARCHAR2 default NULL,
  X_USER_UPDATE_ALLOWED_FLAG    in      VARCHAR2 default NULL,
  X_SERVER_ENABLED_FLAG         in      VARCHAR2 default NULL,
  X_SERVER_UPDATE_ALLOWED_FLAG  in      VARCHAR2 default NULL,
  X_ORG_ENABLED_FLAG            in      VARCHAR2 default NULL,
  X_ORG_UPDATE_ALLOWED_FLAG     in      VARCHAR2 default NULL,
  X_SERVERRESP_ENABLED_FLAG     in      VARCHAR2 default NULL,
  X_SERVERRESP_UPD_ALLOW_FL     in      VARCHAR2 default NULL)
is
  prof_name VARCHAR2(80) := upper(X_PROFILE_OPTION_NAME);
  h_type VARCHAR2(8) := upper(X_HIERARCHY_TYPE);
  s_v_flag1 VARCHAR2(1) := upper(X_SITE_ENABLED_FLAG);
  s_u_flag1 VARCHAR2(1) := upper(X_SITE_UPDATE_ALLOWED_FLAG);
  a_v_flag1 VARCHAR2(1) := upper(X_APP_ENABLED_FLAG);
  a_u_flag1 VARCHAR2(1) := upper(X_APP_UPDATE_ALLOWED_FLAG);
  r_v_flag1 VARCHAR2(1) := upper(X_RESP_ENABLED_FLAG);
  r_u_flag1 VARCHAR2(1) := upper(X_RESP_UPDATE_ALLOWED_FLAG);
  u_v_flag1  VARCHAR2(1) := upper(X_USER_ENABLED_FLAG);
  u_u_flag1  VARCHAR2(1) := upper(X_USER_UPDATE_ALLOWED_FLAG);
  o_v_flag1  VARCHAR2(1) := upper(X_ORG_ENABLED_FLAG);
  o_u_flag1  VARCHAR2(1) := upper(X_ORG_UPDATE_ALLOWED_FLAG);
  sv_v_flag1  VARCHAR2(1) := upper(X_SERVER_ENABLED_FLAG);
  sv_u_flag1  VARCHAR2(1) := upper(X_SERVER_UPDATE_ALLOWED_FLAG);
  sr_v_flag1 VARCHAR2(1) := upper(X_SERVERRESP_ENABLED_FLAG);
  sr_u_flag1 VARCHAR2(1) := upper(X_SERVERRESP_UPD_ALLOW_FL);
  prof_doesnotexist_exception EXCEPTION;
  invalid_input_exception EXCEPTION;

  cursor profname_cursor is
   select application_id,
      profile_option_id,
      WRITE_ALLOWED_FLAG,
      READ_ALLOWED_FLAG,
      USER_CHANGEABLE_FLAG,
      USER_VISIBLE_FLAG,
      START_DATE_ACTIVE,
      SQL_VALIDATION,
      END_DATE_ACTIVE,
      HIERARCHY_TYPE,
      SITE_ENABLED_FLAG,
      SITE_UPDATE_ALLOWED_FLAG,
      APP_ENABLED_FLAG,
      APP_UPDATE_ALLOWED_FLAG,
      RESP_ENABLED_FLAG,
      RESP_UPDATE_ALLOWED_FLAG,
      USER_ENABLED_FLAG,
      USER_UPDATE_ALLOWED_FLAG,
      SERVER_ENABLED_FLAG,
      ORG_ENABLED_FLAG,
      SERVER_UPDATE_ALLOWED_FLAG,
      ORG_UPDATE_ALLOWED_FLAG,
      SERVERRESP_ENABLED_FLAG,
      SERVERRESP_UPDATE_ALLOWED_FLAG,
      USER_PROFILE_OPTION_NAME,
      DESCRIPTION
   from FND_PROFILE_OPTIONS_VL
   where PROFILE_OPTION_NAME=prof_name;

   profname_val profname_cursor%ROWTYPE;
begin

 -- first check arguments are well formed
 if (prof_name is NULL or h_type is NULL) then
    raise  invalid_input_exception;
 end if;

 if (h_type <> 'SECURITY' and h_type <> 'SERVER'
     and h_type <> 'ORG' and h_type <> 'SERVRESP') then
   raise invalid_input_exception;
 end if;

 if ((s_v_flag1 is not NULL and s_v_flag1 <> 'Y' and s_v_flag1 <> 'N') or
     (s_u_flag1 is not NULL and s_u_flag1 <> 'Y' and s_u_flag1 <> 'N') or
     (a_v_flag1 is not NULL and a_v_flag1 <> 'Y' and a_v_flag1 <> 'N') or
     (a_u_flag1 is not NULL and a_u_flag1 <> 'Y' and a_u_flag1 <> 'N') or
     (r_v_flag1 is not NULL and r_v_flag1 <> 'Y' and r_v_flag1 <> 'N') or
     (r_u_flag1 is not NULL and r_u_flag1 <> 'Y' and r_u_flag1 <> 'N') or
     (sr_v_flag1 is not NULL and sr_v_flag1 <> 'Y' and sr_v_flag1 <> 'N') or
     (sr_u_flag1 is not NULL and sr_u_flag1 <> 'Y' and sr_u_flag1 <> 'N') or
     (o_v_flag1 is not NULL and o_v_flag1 <> 'Y' and o_v_flag1 <> 'N') or
     (o_u_flag1 is not NULL and o_u_flag1 <> 'Y' and o_u_flag1 <> 'N') or
     (sv_v_flag1 is not NULL and sv_v_flag1 <> 'Y' and sv_v_flag1 <> 'N') or
     (sv_u_flag1 is not NULL and sv_u_flag1 <> 'Y' and sv_u_flag1 <> 'N')) then
   raise invalid_input_exception;
 end if;
 -- done checking arguments are well formed

 -- make sure profile exists
 open profname_cursor;
 fetch profname_cursor into profname_val;
 if (profname_cursor%NOTFOUND) then
   raise prof_doesnotexist_exception;
 end if;

 -- figure out the values for the enabled and updatable flags. use
 -- existing value if NULL
  if (s_v_flag1 is NULL) then
    s_v_flag1 := profname_val.SITE_ENABLED_FLAG;
  end if;
  if (s_u_flag1 is NULL) then
    s_u_flag1 := profname_val.SITE_UPDATE_ALLOWED_FLAG;
  end if;
  if (u_v_flag1 is NULL) then
    u_v_flag1 := profname_val.USER_ENABLED_FLAG;
  end if;
  if (u_u_flag1 is NULL) then
    u_u_flag1 := profname_val.USER_UPDATE_ALLOWED_FLAG;
  end if;
  if (h_type = 'SECURITY') then
   if (a_v_flag1 is NULL) then
    a_v_flag1 := profname_val.APP_ENABLED_FLAG;
   end if;
   if (a_u_flag1 is NULL) then
    a_u_flag1 := profname_val.APP_UPDATE_ALLOWED_FLAG;
   end if;
   if (r_v_flag1 is NULL) then
    r_v_flag1 := profname_val.RESP_ENABLED_FLAG;
   end if;
   if (r_u_flag1 is NULL) then
    r_u_flag1 := profname_val.RESP_UPDATE_ALLOWED_FLAG;
   end if;
   o_v_flag1 := 'N';
   o_u_flag1 := 'N';
   sv_v_flag1 := 'N';
   sv_u_flag1 := 'N';
   sr_v_flag1 := 'N';
   sr_u_flag1 := 'N';
  elsif (h_type = 'ORG') then
   a_v_flag1 := 'N';
   a_u_flag1 := 'N';
   r_v_flag1 := 'N';
   r_u_flag1 := 'N';
   if (o_v_flag1 is NULL) then
    o_v_flag1 := profname_val.ORG_ENABLED_FLAG;
   end if;
   if (o_u_flag1 is NULL) then
    o_u_flag1 := profname_val.ORG_UPDATE_ALLOWED_FLAG;
   end if;
   sv_v_flag1 := 'N';
   sv_u_flag1 := 'N';
   sr_v_flag1 := 'N';
   sr_u_flag1 := 'N';
  elsif (h_type = 'SERVER') then
   a_v_flag1 := 'N';
   a_u_flag1 := 'N';
   r_v_flag1 := 'N';
   r_u_flag1 := 'N';
   o_v_flag1 := 'N';
   o_u_flag1 := 'N';
   if (sv_v_flag1 is NULL) then
    sv_v_flag1 := profname_val.SERVER_ENABLED_FLAG;
   end if;
   if (sv_u_flag1 is NULL) then
    sv_u_flag1 :=  profname_val.SERVER_UPDATE_ALLOWED_FLAG;
   end if;
   sr_v_flag1 := 'N';
   sr_u_flag1 := 'N';
  elsif (h_type = 'SERVRESP') then
   a_v_flag1 := 'N';
   a_u_flag1 := 'N';
   r_v_flag1 := 'N';
   r_u_flag1 := 'N';
   o_v_flag1 := 'N';
   o_u_flag1 := 'N';
   sv_v_flag1 := 'N';
   sv_u_flag1 := 'N';
   if (sr_v_flag1 is NULL) then
    sr_v_flag1 := profname_val.SERVERRESP_ENABLED_FLAG;
   end if;
   if (sr_u_flag1 is NULL) then
    sr_u_flag1 := profname_val.SERVERRESP_UPDATE_ALLOWED_FLAG;
   end if;
  end if;

  -- invoke table handler to update the profile
  FND_PROFILE_OPTIONS_PKG.UPDATE_ROW (
   X_PROFILE_OPTION_NAME => prof_name,
   X_APPLICATION_ID => profname_val.application_id,
   X_PROFILE_OPTION_ID => profname_val.profile_option_id,
   X_WRITE_ALLOWED_FLAG => profname_val.WRITE_ALLOWED_FLAG,
   X_READ_ALLOWED_FLAG => profname_val.READ_ALLOWED_FLAG,
   X_USER_CHANGEABLE_FLAG => profname_val.USER_CHANGEABLE_FLAG,
   X_USER_VISIBLE_FLAG => profname_val.USER_VISIBLE_FLAG,
   X_SITE_ENABLED_FLAG => s_v_flag1,
   X_SITE_UPDATE_ALLOWED_FLAG => s_u_flag1,
   X_APP_ENABLED_FLAG => a_v_flag1,
   X_APP_UPDATE_ALLOWED_FLAG => a_u_flag1,
   X_RESP_ENABLED_FLAG => r_v_flag1,
   X_RESP_UPDATE_ALLOWED_FLAG => r_u_flag1,
   X_USER_ENABLED_FLAG => u_v_flag1,
   X_USER_UPDATE_ALLOWED_FLAG => u_u_flag1,
   X_START_DATE_ACTIVE => profname_val.START_DATE_ACTIVE,
   X_SQL_VALIDATION => profname_val.SQL_VALIDATION,
   X_END_DATE_ACTIVE => profname_val.END_DATE_ACTIVE,
   X_USER_PROFILE_OPTION_NAME => profname_val.USER_PROFILE_OPTION_NAME,
   X_DESCRIPTION => profname_val.DESCRIPTION,
   X_LAST_UPDATE_DATE => sysdate,
   X_LAST_UPDATED_BY => -1,
   X_LAST_UPDATE_LOGIN => -1,
   X_HIERARCHY_TYPE => h_type,
   X_SERVER_ENABLED_FLAG => sv_v_flag1,
   X_SERVER_UPDATE_ALLOWED_FLAG => sv_u_flag1,
   X_ORG_ENABLED_FLAG => o_v_flag1,
   X_ORG_UPDATE_ALLOWED_FLAG => o_u_flag1,
   X_SERVERRESP_ENABLED_FLAG => sr_v_flag1,
   X_SERVERRESP_UPD_ALLOW_FL => sr_u_flag1);

end UPDATE_ROW;

-- ### OVERLOADED!
procedure TRANSLATE_ROW (
  x_profile_name     in    varchar2,
  x_owner         in varchar2,
  x_user_profile_option_name  in    varchar2,
  x_description         in    varchar2) is
begin
  fnd_profile_options_pkg.translate_row(
    x_profile_name => x_profile_name,
    x_owner => x_owner,
    x_user_profile_option_name => x_user_profile_option_name,
    x_description => x_description,
    x_custom_mode => null,
    x_last_update_date => null);
end TRANSLATE_ROW;

-- ### OVERLOADED!
procedure TRANSLATE_ROW (
  x_profile_name     in    varchar2,
  x_owner         in varchar2,
  x_user_profile_option_name  in    varchar2,
  x_description         in    varchar2,
  x_custom_mode                 in      varchar2,
  x_last_update_date            in      varchar2)
is
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
  L_PROFILE_OPTION_NAME    VARCHAR2(80):= UPPER(x_profile_name);

begin

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from FND_PROFILE_OPTIONS_TL
    where PROFILE_OPTION_NAME = L_PROFILE_OPTION_NAME
    and LANGUAGE = userenv('LANG');

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
      update FND_PROFILE_OPTIONS_TL set
        USER_PROFILE_OPTION_NAME = nvl(x_user_profile_option_name,
                                   USER_PROFILE_OPTION_NAME),
        DESCRIPTION              = nvl(x_description, DESCRIPTION),
        SOURCE_LANG              = userenv('LANG'),
        LAST_UPDATE_DATE         = f_ludate,
        LAST_UPDATED_BY          = f_luby,
        LAST_UPDATE_LOGIN        = 0
      where PROFILE_OPTION_NAME = L_PROFILE_OPTION_NAME
      and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
    end if;
  exception
    when no_data_found then
      null;
  end;
end TRANSLATE_ROW;

-- ### Overloaded!
procedure LOAD_ROW (
  x_profile_name     in    varchar2,
  x_owner         in varchar2,
  x_application_short_name in    varchar2,
  x_user_profile_option_name  in    varchar2,
  x_description         in    varchar2,
  x_user_changeable_flag   in    varchar2,
  x_user_visible_flag      in    varchar2,
  x_read_allowed_flag      in    varchar2,
  x_write_allowed_flag     in    varchar2,
  x_site_enabled_flag      in    varchar2,
  x_site_update_allowed_flag  in    varchar2,
  x_app_enabled_flag    in    varchar2,
  x_app_update_allowed_flag   in    varchar2,
  x_resp_enabled_flag      in    varchar2,
  x_resp_update_allowed_flag  in    varchar2,
  x_user_enabled_flag      in    varchar2,
  x_user_update_allowed_flag  in    varchar2,
  x_start_date_active      in    varchar2,
  x_end_date_active     in    varchar2,
  x_sql_validation      in    varchar2)
is
begin
  fnd_profile_options_pkg.load_row(
  x_profile_name => x_profile_name,
  x_owner => x_owner,
  x_application_short_name => x_application_short_name,
  x_user_profile_option_name => x_user_profile_option_name,
  x_description => x_description,
  x_user_changeable_flag => x_user_changeable_flag,
  x_user_visible_flag => x_user_visible_flag,
  x_read_allowed_flag => x_read_allowed_flag,
  x_write_allowed_flag => x_write_allowed_flag,
  x_site_enabled_flag => x_site_enabled_flag,
  x_site_update_allowed_flag => x_site_update_allowed_flag,
  x_app_enabled_flag => x_app_enabled_flag,
  x_app_update_allowed_flag => x_app_update_allowed_flag,
  x_resp_enabled_flag => x_resp_enabled_flag,
  x_resp_update_allowed_flag => x_resp_update_allowed_flag,
  x_user_enabled_flag => x_user_enabled_flag,
  x_user_update_allowed_flag => x_user_update_allowed_flag,
  x_start_date_active => x_start_date_active,
  x_end_date_active => x_end_date_active,
  x_sql_validation => x_sql_validation,
  x_hierarchy_type => 'SECURITY',
  x_custom_mode => '',
  x_last_update_date => '',
  x_server_enabled_flag => 'N',
  x_server_update_allowed_flag => 'N',
  x_org_enabled_flag => 'N',
  x_org_update_allowed_flag => 'N');
end LOAD_ROW;

-- ### Overloaded!
procedure LOAD_ROW (
  x_profile_name     in    varchar2,
  x_owner         in varchar2,
  x_application_short_name in    varchar2,
  x_user_profile_option_name  in    varchar2,
  x_description         in    varchar2,
  x_user_changeable_flag   in    varchar2,
  x_user_visible_flag      in    varchar2,
  x_read_allowed_flag      in    varchar2,
  x_write_allowed_flag     in    varchar2,
  x_site_enabled_flag      in    varchar2,
  x_site_update_allowed_flag  in    varchar2,
  x_app_enabled_flag    in    varchar2,
  x_app_update_allowed_flag   in    varchar2,
  x_resp_enabled_flag      in    varchar2,
  x_resp_update_allowed_flag  in    varchar2,
  x_user_enabled_flag      in    varchar2,
  x_user_update_allowed_flag  in    varchar2,
  x_start_date_active      in    varchar2,
  x_end_date_active     in    varchar2,
  x_sql_validation      in    varchar2,
  x_hierarchy_type      in varchar2,
  x_custom_mode                 in      varchar2,
  x_last_update_date            in      varchar2,
  x_server_enabled_flag    in varchar2,
  x_server_update_allowed_flag   in varchar2,
  x_org_enabled_flag    in varchar2,
  x_org_update_allowed_flag   in varchar2)
is
begin
  fnd_profile_options_pkg.load_row(
  x_profile_name => x_profile_name,
  x_owner => x_owner,
  x_application_short_name => x_application_short_name,
  x_user_profile_option_name => x_user_profile_option_name,
  x_description => x_description,
  x_user_changeable_flag => x_user_changeable_flag,
  x_user_visible_flag => x_user_visible_flag,
  x_read_allowed_flag => x_read_allowed_flag,
  x_write_allowed_flag => x_write_allowed_flag,
  x_site_enabled_flag => x_site_enabled_flag,
  x_site_update_allowed_flag => x_site_update_allowed_flag,
  x_app_enabled_flag => x_app_enabled_flag,
  x_app_update_allowed_flag => x_app_update_allowed_flag,
  x_resp_enabled_flag => x_resp_enabled_flag,
  x_resp_update_allowed_flag => x_resp_update_allowed_flag,
  x_user_enabled_flag => x_user_enabled_flag,
  x_user_update_allowed_flag => x_user_update_allowed_flag,
  x_start_date_active => x_start_date_active,
  x_end_date_active => x_end_date_active,
  x_sql_validation => x_sql_validation,
  x_hierarchy_type => x_hierarchy_type,
  x_custom_mode => x_custom_mode,
  x_last_update_date => x_last_update_date,
  x_server_enabled_flag => x_server_enabled_flag,
  x_server_update_allowed_flag => x_server_update_allowed_flag,
  x_org_enabled_flag => x_org_enabled_flag,
  x_org_update_allowed_flag => x_org_update_allowed_flag,
  x_serverresp_enabled_flag => 'N',
  x_serverresp_upd_allow_fl => 'N');
end LOAD_ROW;

-- ### Overloaded!
procedure LOAD_ROW (
  x_profile_name     in    varchar2,
  x_owner         in varchar2,
  x_application_short_name in    varchar2,
  x_user_profile_option_name  in    varchar2,
  x_description         in    varchar2,
  x_user_changeable_flag   in    varchar2,
  x_user_visible_flag      in    varchar2,
  x_read_allowed_flag      in    varchar2,
  x_write_allowed_flag     in    varchar2,
  x_site_enabled_flag      in    varchar2,
  x_site_update_allowed_flag  in    varchar2,
  x_app_enabled_flag    in    varchar2,
  x_app_update_allowed_flag   in    varchar2,
  x_resp_enabled_flag      in    varchar2,
  x_resp_update_allowed_flag  in    varchar2,
  x_user_enabled_flag      in    varchar2,
  x_user_update_allowed_flag  in    varchar2,
  x_start_date_active      in    varchar2,
  x_end_date_active     in    varchar2,
  x_sql_validation      in    varchar2,
  x_hierarchy_type      in    varchar2,
  x_custom_mode                 in      varchar2,
  x_last_update_date            in      varchar2,
  x_server_enabled_flag    in varchar2,
  x_server_update_allowed_flag   in varchar2,
  x_org_enabled_flag    in varchar2,
  x_org_update_allowed_flag     in  varchar2,
  x_serverresp_enabled_flag     IN      varchar2,
  x_serverresp_upd_allow_fl     in      varchar2)
is
  app_id    number := 0;
  profo_id  number := 0;
  user_id       number := 0;
  row_id    varchar2(64);
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
  L_HIERARCHY_TYPE VARCHAR2(8);
  L_SERVER_ENABLED_FLAG VARCHAR2(1);
  L_SERVER_UPDATE_ALLOWED_FLAG VARCHAR2(1);
  L_ORG_ENABLED_FLAG VARCHAR(1);
  L_ORG_UPDATE_ALLOWED_FLAG VARCHAR2(1);
  L_SERVERRESP_ENABLED_FLAG VARCHAR2(1);
  L_SERVERRESP_UPD_ALLOW_FL VARCHAR2(1);
  L_PROFILE_OPTION_NAME    VARCHAR2(80):= UPPER(x_profile_name);

begin
  /* For Org and Server Profile options default the hierarchy_type
     to maintain compatibility with old loader data files that
     don't have GRANT_FLAG */

  if (X_HIERARCHY_TYPE is NULL) then
    L_HIERARCHY_TYPE := 'SECURITY';
  else
    L_HIERARCHY_TYPE := X_HIERARCHY_TYPE;
  end if;

  if (X_SERVER_ENABLED_FLAG is NULL) then
    L_SERVER_ENABLED_FLAG := 'N';
  else
    L_SERVER_ENABLED_FLAG := X_SERVER_ENABLED_FLAG;
  end if;

  if (X_SERVER_UPDATE_ALLOWED_FLAG is NULL) then
    L_SERVER_UPDATE_ALLOWED_FLAG := 'N';
  else
    L_SERVER_UPDATE_ALLOWED_FLAG := X_SERVER_UPDATE_ALLOWED_FLAG;
  end if;

   if (X_ORG_ENABLED_FLAG is NULL) then
    L_ORG_ENABLED_FLAG := 'N';
  else
    L_ORG_ENABLED_FLAG := X_ORG_ENABLED_FLAG;
  end if;

  if (X_ORG_UPDATE_ALLOWED_FLAG is NULL) then
    L_ORG_UPDATE_ALLOWED_FLAG := 'N';
  else
    L_ORG_UPDATE_ALLOWED_FLAG := X_ORG_UPDATE_ALLOWED_FLAG;
  end if;

  if (X_SERVERRESP_ENABLED_FLAG is NULL) then
    L_SERVERRESP_ENABLED_FLAG := 'N';
  else
    L_SERVERRESP_ENABLED_FLAG := X_SERVERRESP_ENABLED_FLAG;
  end if;

  if (X_SERVERRESP_UPD_ALLOW_FL is NULL) then
    L_SERVERRESP_UPD_ALLOW_FL := 'N';
  else
    L_SERVERRESP_UPD_ALLOW_FL := X_SERVERRESP_UPD_ALLOW_FL;
  end if;

  select application_id into app_id
  from   fnd_application
  where  application_short_name = X_APPLICATION_SHORT_NAME;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  begin
    select PROFILE_OPTION_ID, LAST_UPDATED_BY, LAST_UPDATE_DATE
    into profo_id, db_luby, db_ludate
    from FND_PROFILE_OPTIONS
    where PROFILE_OPTION_NAME = L_PROFILE_OPTION_NAME;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then

      fnd_profile_options_pkg.update_row(
        x_profile_option_name=>         L_PROFILE_OPTION_NAME,
        x_application_id =>             app_id,
        x_profile_option_id =>          profo_id,
        x_write_allowed_flag =>         x_write_allowed_flag,
        x_read_allowed_flag =>          x_read_allowed_flag,
        x_user_changeable_flag =>       x_user_changeable_flag,
        x_user_visible_flag =>          x_user_visible_flag,
        x_site_enabled_flag =>          x_site_enabled_flag,
        x_site_update_allowed_flag =>   x_site_update_allowed_flag,
        x_app_enabled_flag =>           x_app_enabled_flag,
        x_app_update_allowed_flag =>    x_app_update_allowed_flag,
        x_resp_enabled_flag =>          x_resp_enabled_flag,
        x_resp_update_allowed_flag =>   x_resp_update_allowed_flag,
        x_user_enabled_flag =>          x_user_enabled_flag,
        x_user_update_allowed_flag =>   x_user_update_allowed_flag,
        x_start_date_active =>  to_date(x_start_date_active, 'YYYY/MM/DD'),
        x_sql_validation =>             x_sql_validation,
        x_end_date_active =>    to_date(x_end_date_active, 'YYYY/MM/DD'),
        x_user_profile_option_name =>   x_user_profile_option_name,
        x_description =>                x_description,
        x_last_update_date =>           f_ludate,
        x_last_updated_by =>            f_luby,
        x_last_update_login =>          0,
        x_hierarchy_type =>      l_hierarchy_type,
        x_server_enabled_flag => l_server_enabled_flag,
        x_server_update_allowed_flag => l_server_update_allowed_flag,
        x_org_enabled_flag =>    l_org_enabled_flag,
        x_org_update_allowed_flag =>    l_org_update_allowed_flag,
        x_serverresp_enabled_flag =>    l_serverresp_enabled_flag,
        x_serverresp_upd_allow_fl =>    l_serverresp_upd_allow_fl);

    end if;
  exception
     when no_data_found then
       select fnd_profile_options_s.nextval
       into profo_id
       from dual;

       fnd_profile_options_pkg.insert_row (
          x_rowid =>                    row_id,
          x_profile_option_name =>      L_PROFILE_OPTION_NAME,
          x_application_id =>           app_id,
          x_profile_option_id =>        profo_id,
          x_write_allowed_flag =>       x_write_allowed_flag,
          x_read_allowed_flag =>        x_read_allowed_flag,
          x_user_changeable_flag =>     x_user_changeable_flag,
          x_user_visible_flag =>        x_user_visible_flag,
          x_site_enabled_flag =>        x_site_enabled_flag,
          x_site_update_allowed_flag => x_site_update_allowed_flag,
          x_app_enabled_flag =>         x_app_enabled_flag,
          x_app_update_allowed_flag =>  x_app_update_allowed_flag,
          x_resp_enabled_flag =>        x_resp_enabled_flag,
          x_resp_update_allowed_flag => x_resp_update_allowed_flag,
          x_user_enabled_flag =>        x_user_enabled_flag,
          x_user_update_allowed_flag => x_user_update_allowed_flag,
          x_start_date_active =>to_date(x_start_date_active, 'YYYY/MM/DD'),
          x_sql_validation =>           x_sql_validation,
          x_end_date_active =>  to_date(x_end_date_active, 'YYYY/MM/DD'),
          x_user_profile_option_name => x_user_profile_option_name,
          x_description =>              x_description,
          x_creation_date =>            f_ludate,
          x_created_by =>               f_luby,
          x_last_update_date =>         f_ludate,
          x_last_updated_by =>          f_luby,
          x_last_update_login =>        0,
          x_hierarchy_type =>    l_hierarchy_type,
          x_server_enabled_flag =>      l_server_enabled_flag,
          x_server_update_allowed_flag => l_server_update_allowed_flag,
          x_org_enabled_flag => l_org_enabled_flag,
          x_org_update_allowed_flag => l_org_update_allowed_flag,
          x_serverresp_enabled_flag =>    l_serverresp_enabled_flag,
          x_serverresp_upd_allow_fl =>    l_serverresp_upd_allow_fl);
  end;
end LOAD_ROW;

procedure DELETE_ROW (
  X_PROFILE_OPTION_NAME in VARCHAR2
) is
  L_PROFILE_OPTION_NAME    VARCHAR2(80):= UPPER(X_PROFILE_OPTION_NAME);
begin

  -- Delete profile option values first, so that there are no residual
  -- profile option values to a non-existent profile option. This introduces
  -- a dependency to FND_PROFILE_OPTION_VALUES_PKG.
  FND_PROFILE_OPTION_VALUES_PKG.DELETE_PROFILE_OPTION_VALUES(
     L_PROFILE_OPTION_NAME);

  delete from FND_PROFILE_OPTIONS
  where PROFILE_OPTION_NAME = L_PROFILE_OPTION_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_PROFILE_OPTIONS_TL
  where PROFILE_OPTION_NAME = L_PROFILE_OPTION_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

  delete from FND_PROFILE_OPTIONS_TL T
  where not exists
    (select NULL
    from FND_PROFILE_OPTIONS B
    where B.PROFILE_OPTION_NAME = T.PROFILE_OPTION_NAME
    );

  update FND_PROFILE_OPTIONS_TL T set (
      USER_PROFILE_OPTION_NAME,
      DESCRIPTION
    ) = (select
      B.USER_PROFILE_OPTION_NAME,
      B.DESCRIPTION
    from FND_PROFILE_OPTIONS_TL B
    where B.PROFILE_OPTION_NAME = T.PROFILE_OPTION_NAME
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PROFILE_OPTION_NAME,
      T.LANGUAGE
  ) in (select
      SUBT.PROFILE_OPTION_NAME,
      SUBT.LANGUAGE
    from FND_PROFILE_OPTIONS_TL SUBB, FND_PROFILE_OPTIONS_TL SUBT
    where SUBB.PROFILE_OPTION_NAME = SUBT.PROFILE_OPTION_NAME
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_PROFILE_OPTION_NAME <> SUBT.USER_PROFILE_OPTION_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/

  insert into FND_PROFILE_OPTIONS_TL (
    PROFILE_OPTION_NAME,
    USER_PROFILE_OPTION_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PROFILE_OPTION_NAME,
    B.USER_PROFILE_OPTION_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_PROFILE_OPTIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_PROFILE_OPTIONS_TL T
    where T.PROFILE_OPTION_NAME = B.PROFILE_OPTION_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

/*
**  UPDATE_APPL_ID_PK_COLUMNS - Updates the fk references of
**                             APPLICATION_ID in FND_PROFILE_OTPION_VALUES.
**
**
**  AOL_INTERNAL ONLY
**
** If the profile is moved to a different application, replace old
** application_id with the new value.
**
** Check if this update call is for the update of
** foreign key application_id i.e., this profile option is moved
** to a different applicatjion. If so, replace
** all references of application_id of this profile option
** in FND_PROFILE_OTPION_VALUES to the new value.
*/
PROCEDURE UPDATE_APPL_ID_PK_COLUMNS( x_profile_option_name varchar2,
                                     x_profile_id varchar2,
                                     x_appl_id    varchar2)
IS
     db_appl_id number;
     col  Fnd_Dictionary_Pkg.NameArrayTyp;
     old_val  Fnd_Dictionary_Pkg.NameArrayTyp;
     new_val  Fnd_Dictionary_Pkg.NameArrayTyp;

     result boolean;
     L_PROFILE_OPTION_NAME    VARCHAR2(80):= UPPER(X_PROFILE_OPTION_NAME);

BEGIN
 select application_id
    into db_appl_id
  from fnd_profile_options
  where profile_option_name = L_PROFILE_OPTION_NAME;


  if (db_appl_id = x_appl_id) then
      return;
  else
     col(0) := upper('APPLICATION_ID');
     col(1) := upper('PROFILE_OPTION_ID');
     col(2) := null;
     old_val(0) := db_appl_id;
     old_val(1) := x_profile_id;
     old_val(2) := null;
     new_val(0) := x_appl_id;
     new_val(1) := x_profile_id;
     new_val(2) := null;
     result:=Fnd_Dictionary_Pkg.UpdatePKColumns('FND','FND_PROFILE_OPTIONS',
                                        col, old_val, new_val
                                      );
  end if;
EXCEPTION
     when no_data_found then
        return;
END UPDATE_APPL_ID_PK_COLUMNS;


/*
**  UPDATE_APPL_ID_CAT_OPTIONS - Updates the fk references of
**                             APPLICATION_ID in FND_PROFILE_CAT_OPTIONS.
**
**
**  AOL_INTERNAL ONLY
**
**  Bug 5060938.
**  This api is used to propagate updation of profile from Application1 to
**  Application2 to Fnd_Profile_cat_Options table.
**  DROP/DELETE this api after finding out a way to create Foreign_Key and
**  Primary_Key info in FND_FOREIGN_KEYS and FND_PRIMARY_KEYS AOL meta data
**  through fnd_profile_cat_options.xdf.
**
** If the profile is moved to a different application, replace old
** application_id with the new value.
**
** Check if Fnd_Profile_Cat_Options table and Profile_Option_Application_Id
** column exists. If so, update the Profile_Option_Application_Id for all the
** profiles in Fnd_Profile_Cat_Options table with the new value.
*/
PROCEDURE UPDATE_CAT_OPTIONS_APPL_ID( x_profile_option_name varchar2,
                                      x_profile_id varchar2,
                                      x_appl_id    number)
IS
     db_appl_id number;
     l_appl_id  number;
     result boolean;

     profOptApplId number;
     L_PROFILE_OPTION_NAME    VARCHAR2(80):= UPPER(X_PROFILE_OPTION_NAME);

     COL_NOT_FOUND      EXCEPTION;
     TAB_NOT_FOUND      EXCEPTION;

  PRAGMA EXCEPTION_INIT(COL_NOT_FOUND, -904);
  PRAGMA EXCEPTION_INIT(TAB_NOT_FOUND, -942);
BEGIN
 select application_id
    into db_appl_id
  from fnd_profile_options
  where profile_option_name = L_PROFILE_OPTION_NAME;

  begin
    SELECT profile_option_application_id
    INTO l_appl_id
    FROM   fnd_profile_cat_options
    WHERE  ROWNUM < 2;
  exception
   when COL_NOT_FOUND then
     return;
   when TAB_NOT_FOUND then
     return;
   when others then
     null;
  end;

  if (db_appl_id = x_appl_id) then
      return;
  else
     UPDATE fnd_profile_cat_options
     SET    profile_option_application_id = x_appl_id
     WHERE  profile_option_id = x_profile_id
     AND    profile_option_application_id = db_appl_id;
  end if;
EXCEPTION
     when no_data_found then
        return;
END UPDATE_CAT_OPTIONS_APPL_ID;

end FND_PROFILE_OPTIONS_PKG;

/
