--------------------------------------------------------
--  DDL for Package Body FND_MO_PRODUCT_INIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_MO_PRODUCT_INIT_PKG" as
/* $Header: AFMOPINB.pls 115.6 2003/09/26 15:11:21 kmaheswa noship $ */

--
-- REGISTER_APPLICATION (PUBLIC)
--   Called by product teams to register their application as
--   access enabled
-- Input
--   p_appl_short_name: application short name
--   p_owner: for seed or custom data
procedure register_application(p_appl_short_name    in varchar2,
                               p_owner              in varchar2 ) is
begin
  register_application(p_appl_short_name,
                       p_owner,
                       'N',
                       NULL,
                       NULL);
end register_application;

--
-- REMOVE_APPLICATION (PUBLIC)
--   Called by product teams to delete their application registered
--   as access enabled
-- Input
--   p_appl_short_name: application short name
procedure remove_application(p_appl_short_name in varchar2) is
begin
  begin
    delete from FND_MO_PRODUCT_INIT
    where APPLICATION_SHORT_NAME = upper(p_appl_short_name);

  exception
    when others then
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'REMOVE_APPLICATION');
      fnd_message.set_token('ERRNO', to_char(sqlcode));
      fnd_message.set_token('REASON', sqlerrm);
      app_exception.raise_exception;
  end;

end remove_application;

--
-- REGISTER_APPLICATION (PUBLIC)
--   Called by product teams to register their application as
--   access enabled
-- Input
--   p_appl_short_name: application short name
--   p_owner: for seed or custom data
--   p_enabled_flag: flag to indicate if access control is enabled
procedure register_application(p_appl_short_name    in varchar2,
                               p_owner              in varchar2,
                               p_status             in varchar2 ) is
begin
  register_application(p_appl_short_name,
                       p_owner,
                       p_status,
                       NULL,
                       NULL);
end register_application;

--
-- REGISTER_APPLICATION (PUBLIC)
--   Called by product teams to register their application as
--   access enabled
-- Input
--   p_appl_short_name: application short name
--   p_owner: for seed or custom data
--   p_enabled_flag: flag to indicate if access control is enabled
--   p_last_update_date:  last updated date for the row
procedure register_application(p_appl_short_name    in varchar2,
                               p_owner              in varchar2,
                               p_status             in varchar2,
                               p_last_update_date   in varchar2,
			       p_custom_mode        in varchar2) is
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin
  f_luby := fnd_load_util.owner_id(p_owner);
  f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'),
			sysdate);
  begin
         select LAST_UPDATED_BY, LAST_UPDATE_DATE
           into db_luby, db_ludate
           from FND_MO_PRODUCT_INIT
          where application_short_name = upper(p_appl_short_name);
    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, p_custom_mode)) then
      update FND_MO_PRODUCT_INIT
      set LAST_UPDATED_BY = f_luby,
          LAST_UPDATE_DATE = f_ludate,
          LAST_UPDATE_LOGIN = 0,
          STATUS = nvl(p_status,'N')
      where APPLICATION_SHORT_NAME = upper(p_appl_short_name);
    end if;


  exception
    when no_data_found then
      insert into FND_MO_PRODUCT_INIT(
            APPLICATION_SHORT_NAME,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            STATUS)
      values(
            upper(p_appl_short_name),
            f_ludate,
            f_luby,
            f_ludate,
            f_luby,
            0,
            nvl(upper(p_status),'N'));

    when others then
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'REGISTER_APPLICATION');
      fnd_message.set_token('ERRNO', to_char(sqlcode));
      fnd_message.set_token('REASON', sqlerrm);
      app_exception.raise_exception;
    end;

end register_application;

end fnd_mo_product_init_pkg;

/
