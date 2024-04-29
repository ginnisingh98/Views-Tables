--------------------------------------------------------
--  DDL for Package Body WIP_PREF_LEVEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_PREF_LEVEL_PKG" as
/* $Header: WIPPRFLB.pls 120.0 2005/06/20 18:05:05 asuherma noship $ */

procedure LOAD_SEED_ROW(
          x_upload_mode                         in      varchar2,
          x_custom_mode                         in      varchar2,
          x_level_id                            in      number,
          x_level_code                          in      number,
          x_resp_key                            in      varchar2,
          x_organization_id                     in      number,
          x_department_id                       in      number,
          x_module_id                           in      number,
          x_owner                               in      varchar2,
          x_last_update_date                    in      varchar2) is
begin
   if (x_upload_mode = 'NLS') then
      return;
   else
      WIP_PREF_LEVEL_PKG.LOAD_ROW(
         x_custom_mode,
	 x_level_id,
	 x_level_code,
         x_resp_key,
	 x_organization_id,
	 x_department_id,
	 x_module_id,
	 x_owner,
	 x_last_update_date);
   end if;
end LOAD_SEED_ROW;

procedure LOAD_ROW(
          x_custom_mode                         in      varchar2,
          x_level_id                            in      number,
          x_level_code                          in      number,
          x_resp_key                            in      varchar2,
          x_organization_id                     in      number,
          x_department_id                       in      number,
          x_module_id                           in      number,
          x_owner                               in      varchar2,
          x_last_update_date                    in      varchar2) is
   user_id NUMBER := 0;
   f_ludate  date;    -- entity update date in file
   db_luby   number;  -- entity owner in db
   db_ludate date;    -- entity update date in db
begin
   user_id := fnd_load_util.owner_id(x_owner);

   -- Translate char last_update_date to date
   f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

   select LAST_UPDATED_BY, LAST_UPDATE_DATE
   into   db_luby, db_ludate
   from   WIP_PREFERENCE_LEVELS
   where  LEVEL_ID = x_level_id;

   if (fnd_load_util.upload_test(user_id, f_ludate, db_luby,
                                 db_ludate, x_custom_mode)) then
      update WIP_PREFERENCE_LEVELS set
             LEVEL_CODE = x_level_code,
             RESP_KEY = x_resp_key,
             ORGANIZATION_ID = x_organization_id,
             DEPARTMENT_ID = x_department_id,
             MODULE_ID = x_module_id,
             LAST_UPDATE_DATE = f_ludate,
             LAST_UPDATED_BY = user_id,
             LAST_UPDATE_LOGIN = 0
      where  LEVEL_ID = x_level_id;
   end if;

exception
   when no_data_found then
      -- Row doesn't exist yet.  Now this insert statement is placed here.
      insert into WIP_PREFERENCE_LEVELS (
                  LEVEL_ID,
                  LEVEL_CODE,
                  RESP_KEY,
                  ORGANIZATION_ID,
                  DEPARTMENT_ID,
                  MODULE_ID,
                  OBJECT_VERSION_NUMBER,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_LOGIN )
           values (
                  x_level_id,
                  x_level_code,
                  x_resp_key,
                  x_organization_id,
                  x_department_id,
                  x_module_id,
                  1,
                  f_ludate,
                  user_id,
                  f_ludate,
                  user_id,
                  0 );

end LOAD_ROW;


end WIP_PREF_LEVEL_PKG;

/
