--------------------------------------------------------
--  DDL for Package Body WIP_PREF_VALUE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_PREF_VALUE_PKG" as
/* $Header: WIPPRFVB.pls 120.0 2005/06/20 18:06:28 asuherma noship $ */

procedure LOAD_SEED_ROW(
          x_upload_mode                         in      varchar2,
          x_custom_mode                         in      varchar2,
          x_preference_value_id                 in      number,
          x_preference_id                       in      number,
          x_level_id                            in      number,
          x_sequence_number                     in      number,
          x_attribute_name                      in      varchar2,
          x_attribute_value_code                in      varchar2,
          x_owner                               in      varchar2,
          x_last_update_date                    in      varchar2) is
begin
   if (x_upload_mode = 'NLS') then
      return;
   else
      WIP_PREF_VALUE_PKG.LOAD_ROW(
         x_custom_mode,
	 x_preference_value_id,
	 x_preference_id,
         x_level_id,
	 x_sequence_number,
	 x_attribute_name,
	 x_attribute_value_code,
	 x_owner,
	 x_last_update_date);
   end if;
end LOAD_SEED_ROW;

procedure LOAD_ROW(
          x_custom_mode                         in      varchar2,
          x_preference_value_id                 in      number,
          x_preference_id                       in      number,
          x_level_id                            in      number,
          x_sequence_number                     in      number,
          x_attribute_name                      in      varchar2,
          x_attribute_value_code                in      varchar2,
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
   from   WIP_PREFERENCE_VALUES
   where  PREFERENCE_VALUE_ID = x_preference_value_id;

   if (fnd_load_util.upload_test(user_id, f_ludate, db_luby,
                                 db_ludate, x_custom_mode)) then
      update WIP_PREFERENCE_VALUES set
             PREFERENCE_ID = x_preference_id,
             LEVEL_ID = x_level_id,
             SEQUENCE_NUMBER = x_sequence_number,
             ATTRIBUTE_NAME = x_attribute_name,
             ATTRIBUTE_VALUE_CODE = x_attribute_value_code,
             LAST_UPDATE_DATE = f_ludate,
             LAST_UPDATED_BY = user_id,
             LAST_UPDATE_LOGIN = 0
      where  PREFERENCE_VALUE_ID = x_preference_value_id;
   end if;

exception
   when no_data_found then
      -- Row doesn't exist yet.  Now this insert statement is placed here.
      insert into WIP_PREFERENCE_VALUES (
                  PREFERENCE_VALUE_ID,
                  PREFERENCE_ID,
                  LEVEL_ID,
                  SEQUENCE_NUMBER,
                  ATTRIBUTE_NAME,
                  ATTRIBUTE_VALUE_CODE,
                  OBJECT_VERSION_NUMBER,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_LOGIN )
           values (
                  x_preference_value_id,
                  x_preference_id,
                  x_level_id,
                  x_sequence_number,
                  x_attribute_name,
                  x_attribute_value_code,
                  1,
                  f_ludate,
                  user_id,
                  f_ludate,
                  user_id,
                  0 );

end LOAD_ROW;


end WIP_PREF_VALUE_PKG;

/
