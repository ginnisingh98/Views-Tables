--------------------------------------------------------
--  DDL for Package Body FLM_SEQ_ATTRIBUTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FLM_SEQ_ATTRIBUTES_PKG" as
/* $Header: FLMSQATB.pls 120.1 2006/11/03 02:25:44 ksuleman noship $ */

procedure LOAD_SEED_ROW(
          x_upload_mode                 in      varchar2,
          x_custom_mode                 in      varchar2,
          x_attribute_id                in      number,
          x_attribute_name              in      varchar2,
          x_description                 in      varchar2,
          x_user_defined_flag           in      varchar2,
          x_attribute_type              in      number,
          x_attribute_source            in      varchar2,
          x_attribute_value_type        in      number,
          x_owner                       in      varchar2,
          x_last_update_date            in      varchar2) is
begin
   if (x_upload_mode = 'NLS') then
      FLM_SEQ_ATTRIBUTES_PKG.TRANSLATE_ROW(
         x_custom_mode,
	 x_attribute_id,
         x_description,
	 x_owner,
	 x_last_update_date);
   else
      FLM_SEQ_ATTRIBUTES_PKG.LOAD_ROW(
         x_custom_mode,
	 x_attribute_id,
	 x_attribute_name,
         x_description,
	 x_user_defined_flag,
	 x_attribute_type,
	 x_attribute_source,
	 x_attribute_value_type,
	 x_owner,
	 x_last_update_date);
   end if;
end LOAD_SEED_ROW;

procedure TRANSLATE_ROW(
          x_custom_mode                 in      varchar2,
          x_attribute_id                in      number,
          x_description                 in      varchar2,
          x_owner                       in      varchar2,
          x_last_update_date            in      varchar2) is
   user_id NUMBER := 0;
   f_ludate  date;    -- entity update date in file
   db_luby   number;  -- entity owner in db
   db_ludate date;    -- entity update date in db
begin
   user_id := fnd_load_util.owner_id(x_owner);

   -- Translate char last_update_date to date
   f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

   -- Row exists, test if it should be over-written.
   select LAST_UPDATED_BY, LAST_UPDATE_DATE
   into   db_luby, db_ludate
   from   FLM_SEQ_ATTRIBUTES
   where  ATTRIBUTE_ID = x_attribute_id;

   if (fnd_load_util.upload_test(user_id, f_ludate, db_luby,
                                 db_ludate, x_custom_mode)) then
      update FLM_SEQ_ATTRIBUTES set
             DESCRIPTION = x_description,
             LAST_UPDATED_BY = user_id,
             LAST_UPDATE_DATE = f_ludate,
             LAST_UPDATE_LOGIN = 0
      where  ATTRIBUTE_ID = x_attribute_id
        and  userenv('LANG') = (select  LANGUAGE_CODE
                               from     FND_LANGUAGES
                               where    INSTALLED_FLAG = 'B' );
   end if;

exception
   when no_data_found then
       -- Do not insert missing translations, skip this row.
       null;

end TRANSLATE_ROW;

procedure LOAD_ROW(
          x_custom_mode                 in      varchar2,
          x_attribute_id                in      number,
          x_attribute_name              in      varchar2,
          x_description                 in      varchar2,
          x_user_defined_flag           in      varchar2,
          x_attribute_type              in      number,
          x_attribute_source            in      varchar2,
          x_attribute_value_type        in      number,
          x_owner                       in      varchar2,
          x_last_update_date            in      varchar2) is
   user_id NUMBER := 0;
   f_ludate  date;    -- entity update date in file
   db_luby   number;  -- entity owner in db
   db_ludate date;    -- entity update date in db
   other_att number;
begin
   user_id := fnd_load_util.owner_id(x_owner);

   -- Translate char last_update_date to date
   f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

   select count(*)
     into other_att
     from FLM_SEQ_ATTRIBUTES
    where ATTRIBUTE_NAME = x_attribute_name
      and ATTRIBUTE_ID > 1000;

   if other_att > 0 then
      return;
   end if;

   select LAST_UPDATED_BY, LAST_UPDATE_DATE
   into   db_luby, db_ludate
   from   FLM_SEQ_ATTRIBUTES
   where  ATTRIBUTE_ID = x_attribute_id;

   if (fnd_load_util.upload_test(user_id, f_ludate, db_luby,
                                 db_ludate, x_custom_mode)) then
      update FLM_SEQ_ATTRIBUTES set
             ATTRIBUTE_NAME = x_attribute_name,
             DESCRIPTION = x_description,
             USER_DEFINED_FLAG = x_user_defined_flag,
             ATTRIBUTE_TYPE = x_attribute_type,
             ATTRIBUTE_SOURCE = x_attribute_source,
             ATTRIBUTE_VALUE_TYPE = x_attribute_value_type,
             LAST_UPDATE_DATE = f_ludate,
             LAST_UPDATED_BY = user_id,
             LAST_UPDATE_LOGIN = 0
      where  ATTRIBUTE_ID = x_attribute_id;
   end if;

exception
   when no_data_found then
      -- Row doesn't exist yet.  Now this insert statement is placed here.
      insert into FLM_SEQ_ATTRIBUTES (
                  ATTRIBUTE_ID,
                  ATTRIBUTE_NAME,
                  DESCRIPTION,
                  USER_DEFINED_FLAG,
                  ATTRIBUTE_TYPE,
                  ATTRIBUTE_SOURCE,
                  ATTRIBUTE_VALUE_TYPE,
                  OBJECT_VERSION_NUMBER,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_LOGIN )
           values (
                  x_attribute_id,
                  x_attribute_name,
                  x_description,
                  x_user_defined_flag,
                  x_attribute_type,
                  x_attribute_source,
                  x_attribute_value_type,
                  1,
                  f_ludate,
                  user_id,
                  f_ludate,
                  user_id,
                  0 );

end LOAD_ROW;


end FLM_SEQ_ATTRIBUTES_PKG;

/
