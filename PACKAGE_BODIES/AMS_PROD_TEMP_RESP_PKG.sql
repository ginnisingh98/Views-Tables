--------------------------------------------------------
--  DDL for Package Body AMS_PROD_TEMP_RESP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_PROD_TEMP_RESP_PKG" as
/* $Header: amstptrb.pls 115.4 2003/03/11 00:26:01 mukumar noship $ */


procedure  LOAD_ROW(
   X_TEMPL_RESPONSIBILITY_ID  IN NUMBER
  ,X_TEMPLATE_ID              IN NUMBER
  ,X_RESPONSIBILITY_ID        IN NUMBER
  ,X_Owner                    IN VARCHAR2
 ,X_CUSTOM_MODE               IN       VARCHAR2
) is

l_user_id   number := 0;
l_obj_verno  number;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);
L_TEMPL_RESPONSIBILITY_ID   number;
l_db_luby_id number;

cursor  c_obj_verno is
  select object_version_number
  from    AMS_TEMPL_RESPONSIBILITY
  where  TEMPL_RESPONSIBILITY_ID =  X_TEMPL_RESPONSIBILITY_ID;

cursor c_chk_temp_resp_exists is
  select 'x'
  from   AMS_TEMPL_RESPONSIBILITY
  where  TEMPL_RESPONSIBILITY_ID =  X_TEMPL_RESPONSIBILITY_ID;

cursor c_get_temp_resp_id is
   select AMS_TEMPL_RESPONSIBILITY_S.nextval
   from dual;

cursor  c_db_data_details is
  select last_updated_by, nvl(object_version_number,1)
  from    AMS_TEMPL_RESPONSIBILITY
  where  TEMPL_RESPONSIBILITY_ID =  X_TEMPL_RESPONSIBILITY_ID;

BEGIN

  if X_OWNER = 'SEED' then
    l_user_id := 1;
  elsif X_OWNER = 'ORACLE' THEN
    l_user_id := 2;
  elsif X_OWNER = 'SYSADMIN' THEN
    l_user_id := 0;
  end if ;

 open c_chk_temp_resp_exists;
 fetch c_chk_temp_resp_exists into l_dummy_char;

 if c_chk_temp_resp_exists%notfound
 then
    close c_chk_temp_resp_exists;
    if X_TEMPL_RESPONSIBILITY_ID is null
    then
      open  c_get_temp_resp_id;
      fetch c_get_temp_resp_id into L_TEMPL_RESPONSIBILITY_ID;
      close c_get_temp_resp_id;
    else
       L_TEMPL_RESPONSIBILITY_ID := X_TEMPL_RESPONSIBILITY_ID;
    end if;

    l_obj_verno := 1;


    INSERT INTO AMS_TEMPL_RESPONSIBILITY(
           TEMPL_RESPONSIBILITY_ID,
           template_id,
           RESPONSIBILITY_ID,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           object_version_number,
           last_update_login
     ) VALUES (
            L_TEMPL_RESPONSIBILITY_ID
            ,x_template_id
	    ,x_RESPONSIBILITY_ID
           ,SYSDATE
           ,l_user_id
           ,SYSDATE
           ,l_user_id
           ,1
           ,0);


  else
     close c_chk_temp_resp_exists;
   open c_db_data_details;
   fetch c_db_data_details into l_db_luby_id, l_obj_verno;
   close c_db_data_details;
   if (l_db_luby_id IN (1,2,0)
      OR NVL(x_custom_mode,'PRESERVE') = 'FORCE') THEN
         Update AMS_TEMPL_RESPONSIBILITY
         SET  last_update_date = sysdate,
           last_updated_by = l_user_id,
           object_version_number = l_obj_verno +1,
           last_update_login = 0,
	   template_id = x_template_id,
           RESPONSIBILITY_ID = x_RESPONSIBILITY_ID
        WHERE TEMPL_RESPONSIBILITY_ID =  X_TEMPL_RESPONSIBILITY_ID
        AND   object_version_number = l_obj_verno;
   end if;
end if;

END LOAD_ROW;

end AMS_PROD_TEMP_RESP_PKG;

/
