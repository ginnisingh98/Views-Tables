--------------------------------------------------------
--  DDL for Package Body WIP_PREF_DEF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_PREF_DEF_PKG" as
/* $Header: WIPPRFDB.pls 120.1 2005/06/24 17:10:42 asuherma noship $ */

procedure LOAD_SEED_ROW(
          x_upload_mode                         in      varchar2,
          x_custom_mode                         in      varchar2,
          x_preference_id                       in      number,
          x_preference_code                     in      number,
          x_preference_type                     in      number,
          x_preference_source                   in      varchar2,
          x_preference_value_lookup_type        in      varchar2,
          x_module_id                           in      number,
          x_usage_level                         in      number,
          x_owner                               in      varchar2,
          x_last_update_date                    in      varchar2) is
begin
   if (x_upload_mode = 'NLS') then
      return;
   else
      WIP_PREF_DEF_PKG.LOAD_ROW(
         x_custom_mode,
	 x_preference_id,
	 x_preference_code,
         x_preference_type,
	 x_preference_source,
	 x_preference_value_lookup_type,
	 x_module_id,
	 x_usage_level,
	 x_owner,
	 x_last_update_date);
   end if;
end LOAD_SEED_ROW;

procedure LOAD_ROW(
          x_custom_mode                         in      varchar2,
          x_preference_id                       in      number,
          x_preference_code                     in      number,
          x_preference_type                     in      number,
          x_preference_source                   in      varchar2,
          x_preference_value_lookup_type        in      varchar2,
          x_module_id                           in      number,
          x_usage_level                           in      number,
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
   from   WIP_PREFERENCE_DEFINITIONS
   where  PREFERENCE_ID = x_preference_id;

   if (fnd_load_util.upload_test(user_id, f_ludate, db_luby,
                                 db_ludate, x_custom_mode)) then
      update WIP_PREFERENCE_DEFINITIONS set
             PREFERENCE_CODE = x_preference_code,
             PREFERENCE_TYPE = x_preference_type,
             PREFERENCE_SOURCE = x_preference_source,
             PREFERENCE_VALUE_LOOKUP_TYPE = x_preference_value_lookup_type,
             MODULE_ID = x_module_id,
             USAGE_LEVEL = x_usage_level,
             LAST_UPDATE_DATE = f_ludate,
             LAST_UPDATED_BY = user_id,
             LAST_UPDATE_LOGIN = 0
      where  PREFERENCE_ID = x_preference_id;
   end if;

exception
   when no_data_found then
      -- Row doesn't exist yet.  Now this insert statement is placed here.
      insert into WIP_PREFERENCE_DEFINITIONS (
                  PREFERENCE_ID,
                  PREFERENCE_CODE,
                  PREFERENCE_TYPE,
                  PREFERENCE_SOURCE,
                  PREFERENCE_VALUE_LOOKUP_TYPE,
                  MODULE_ID,
                  USAGE_LEVEL,
                  OBJECT_VERSION_NUMBER,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_LOGIN )
           values (
                  x_preference_id,
                  x_preference_code,
                  x_preference_type,
                  x_preference_source,
                  x_preference_value_lookup_type,
                  x_module_id,
                  x_usage_level,
                  1,
                  f_ludate,
                  user_id,
                  f_ludate,
                  user_id,
                  0 );

end LOAD_ROW;


end WIP_PREF_DEF_PKG;

/
