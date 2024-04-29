--------------------------------------------------------
--  DDL for Package Body AMS_PROD_TEMPLATE_ATTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_PROD_TEMPLATE_ATTR_PKG" as
/* $Header: amstptab.pls 115.5 2003/03/11 00:25:59 mukumar ship $ */


procedure  LOAD_ROW(
  X_template_attribute_id	IN        NUMBER
 ,X_template_id			IN        NUMBER
 ,X_parent_attribute_code	IN       VARCHAR2
 ,X_parent_select_all		IN       VARCHAR2
 ,X_attribute_code		IN       VARCHAR2
 ,X_default_flag		IN       VARCHAR2
 ,X_editable_flag		IN       VARCHAR2
 ,X_hide_flag			IN       VARCHAR2
 ,X_Owner			IN       VARCHAR2
 ,X_CUSTOM_MODE                 IN       VARCHAR2
) is

l_user_id   number := 0;
l_obj_verno  number;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);
l_template_attribute_id   number;
l_db_luby_id number;


cursor  c_obj_verno is
  select object_version_number
  from    ams_prod_template_attr
  where  template_attribute_id =  X_TEMPLATE_attribute_ID;

cursor c_chk_temp_attr_exists is
  select 'x'
  from   ams_prod_template_attr
  where  template_attribute_id =  X_TEMPLATE_attribute_ID;

cursor c_get_temp_attr_id is
   select ams_prod_template_attr_S.nextval
   from dual;

cursor  c_db_data_details is
  select last_updated_by, nvl(object_version_number,1)
  from   ams_prod_template_attr
  where  template_attribute_id =  X_TEMPLATE_attribute_ID;


BEGIN

  -- set the last_updated_by to be used while updating the data in customer data.
  if X_OWNER = 'SEED' then
    l_user_id := 1;
  elsif X_OWNER = 'ORACLE' THEN
    l_user_id := 2;
  elsif X_OWNER = 'SYSADMIN' THEN
    l_user_id := 0;
  end if ;

 open c_chk_temp_attr_exists;
 fetch c_chk_temp_attr_exists into l_dummy_char;

 if c_chk_temp_attr_exists%notfound
 then
    close c_chk_temp_attr_exists;
    if X_TEMPLATE_attribute_ID is null
    then
      open  c_get_temp_attr_id;
      fetch c_get_temp_attr_id into l_template_attribute_id;
      close c_get_temp_attr_id;
    else
       l_template_attribute_id := X_TEMPLATE_attribute_ID;
    end if;

    l_obj_verno := 1;

    INSERT INTO ams_prod_template_attr(
           TEMPLATE_ATTRIBUTE_ID,
           template_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           object_version_number,
           last_update_login,
           PARENT_ATTRIBUTE_CODE,
	   PARENT_SELECT_ALL  ,
	   ATTRIBUTE_CODE ,
	   DEFAULT_FLAG ,
	   EDITABLE_FLAG ,
	   HIDE_FLAG
     ) VALUES (
            l_template_attribute_id
            ,x_template_id
           ,SYSDATE
           ,l_user_id
           ,SYSDATE
           ,l_user_id
           ,1
           ,0
           ,x_PARENT_ATTRIBUTE_CODE
	   ,x_PARENT_SELECT_ALL
	   ,x_ATTRIBUTE_CODE
	   ,x_DEFAULT_FLAG
	   ,x_EDITABLE_FLAG
	   ,x_HIDE_FLAG );


  else
   close c_chk_temp_attr_exists;
/*   open c_obj_verno;
   fetch c_obj_verno into l_obj_verno;
   close c_obj_verno;
   */
   open c_db_data_details;
   fetch c_db_data_details into l_db_luby_id, l_obj_verno;
   close c_db_data_details;
   if (l_db_luby_id IN (1,2,0)
      OR NVL(x_custom_mode,'PRESERVE') = 'FORCE') THEN
        Update ams_prod_template_attr
        SET  last_update_date = sysdate,
           last_updated_by = l_user_id,
           object_version_number = l_obj_verno +1,
           last_update_login = 0,
           PARENT_ATTRIBUTE_CODE = x_PARENT_ATTRIBUTE_CODE ,
	   PARENT_SELECT_ALL  =   x_PARENT_SELECT_ALL,
	   ATTRIBUTE_CODE   =     x_ATTRIBUTE_CODE ,
	   DEFAULT_FLAG    =      x_DEFAULT_FLAG  ,
	   EDITABLE_FLAG   =      x_EDITABLE_FLAG  ,
	   HIDE_FLAG =        x_HIDE_FLAG
        WHERE TEMPLATE_attribute_ID =  X_template_attribute_id
        AND   object_version_number = l_obj_verno;
   end if;
end if;

END LOAD_ROW;

end AMS_PROD_TEMPLATE_ATTR_PKG;

/
