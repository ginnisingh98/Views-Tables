--------------------------------------------------------
--  DDL for Package Body AMS_PROD_TEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_PROD_TEMPLATE_PKG" as
/* $Header: amstptmb.pls 115.4 2003/03/11 00:26:00 mukumar ship $ */

procedure ADD_LANGUAGE
is
begin
  delete from AMS_PROD_TEMPLATES_TL T
  where not exists
    (select NULL
    from AMS_PROD_TEMPLATES_B B
    where B.TEMPLATE_ID = T.TEMPLATE_ID
    );

  update AMS_PROD_TEMPLATES_TL T set (
      TEMPLATE_NAME,
      DESCRIPTION
    ) = (select
		B.TEMPLATE_NAME,
		B.DESCRIPTION
    from AMS_PROD_TEMPLATES_TL B
    where B.TEMPLATE_ID = T.TEMPLATE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
     where (
      T.TEMPLATE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TEMPLATE_ID,
      SUBT.LANGUAGE
    from AMS_PROD_TEMPLATES_TL SUBB, AMS_PROD_TEMPLATES_TL SUBT
    where SUBB.template_ID = SUBT.template_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TEMPLATE_NAME <> SUBT.TEMPLATE_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_PROD_TEMPLATES_TL (
    template_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    template_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.template_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.template_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_PROD_TEMPLATES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_PROD_TEMPLATES_TL T
    where T.template_ID = B.template_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;


procedure TRANSLATE_ROW(
       x_template_id    in NUMBER
     , x_template_name  in VARCHAR2
     , x_description    in VARCHAR2
     , x_owner          in VARCHAR2
 ) is
 begin
    update AMS_PROD_TEMPLATES_TL set
       template_name = nvl(x_template_name, template_name),
       description = nvl(x_description, description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(x_owner, 'SEED', 1, 0),
       last_update_login = 0
    where  template_id = x_template_id
    and      userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;


procedure  LOAD_ROW(
 X_TEMPLATE_ID                IN   NUMBER,
 X_PRODUCT_SERVICE_FLAG       IN   VARCHAR2,
 X_TEMPLATE_NAME              IN   VARCHAR2,
 X_DESCRIPTION                IN   VARCHAR2 ,
 X_Owner                       in  VARCHAR2,
 X_CUSTOM_MODE                 IN       VARCHAR2

) is

l_user_id   number := 0;
l_obj_verno  number;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);
l_template_id   number;
l_db_luby_id number;

cursor  c_obj_verno is
  select object_version_number
  from    AMS_PROD_TEMPLATES_B
  where  template_id =  X_TEMPLATE_ID;

cursor c_chk_temp_exists is
  select 'x'
  from   AMS_PROD_TEMPLATES_B
  where  template_id =  X_TEMPLATE_ID;

cursor c_get_tempid is
   select AMS_PROD_TEMPLATES_B_S.nextval
   from dual;

cursor  c_db_data_details is
  select last_updated_by, nvl(object_version_number,1)
  from    AMS_PROD_TEMPLATES_B
  where  template_id =  X_TEMPLATE_ID;

BEGIN

  if X_OWNER = 'SEED' then
    l_user_id := 1;
  elsif X_OWNER = 'ORACLE' THEN
    l_user_id := 2;
  elsif X_OWNER = 'SYSADMIN' THEN
    l_user_id := 0;
  end if ;

 open c_chk_temp_exists;
 fetch c_chk_temp_exists into l_dummy_char;

 if c_chk_temp_exists%notfound
 then
    close c_chk_temp_exists;
    if X_TEMPLATE_ID is null
    then
      open  c_get_tempid;
      fetch c_get_tempid into l_template_id;
      close c_get_tempid;
    else
       l_template_id := X_TEMPLATE_ID;
    end if;

    l_obj_verno := 1;

    INSERT INTO AMS_PROD_TEMPLATES_B(
           template_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           object_version_number,
           last_update_login,
           product_service_flag
     ) VALUES (
            l_template_id
           ,SYSDATE
           ,l_user_id
           ,SYSDATE
           ,l_user_id
           ,1
           ,0
           ,X_PRODUCT_SERVICE_FLAG);

    INSERT  INTO AMS_PROD_TEMPLATES_TL(
            template_id
           ,language
           ,source_lang
           ,last_update_date
           ,last_updated_by
           ,last_update_login
           ,creation_date
           ,created_by
           ,template_name
           ,description
       )   SELECT
           l_template_id,
           l.language_code,
           USERENV('LANG'),
           sysdate,
           l_user_id,
           0,
           sysdate,
           l_user_id,
	   X_TEMPLATE_NAME,
	   X_DESCRIPTION
   FROM    fnd_languages l
   WHERE   l.installed_flag IN ('I','B')
   AND     NOT EXISTS(
                      SELECT NULL
                      FROM   AMS_PROD_TEMPLATES_TL t
                      WHERE  t.template_id = DECODE( l_template_id, FND_API.g_miss_num, NULL, l_template_id)
                      AND    t.language = l.language_code ) ;

else
   close c_chk_temp_exists;
   open c_db_data_details;
   fetch c_db_data_details into l_db_luby_id, l_obj_verno;
   close c_db_data_details;

   if (l_db_luby_id IN (1,2,0)
      OR NVL(x_custom_mode,'PRESERVE') = 'FORCE') THEN
        Update AMS_PROD_TEMPLATES_B
        SET  last_update_date = sysdate,
           last_updated_by = l_user_id,
           object_version_number = l_obj_verno +1,
           last_update_login = 0,
           product_service_flag = X_PRODUCT_SERVICE_FLAG
        WHERE TEMPLATE_ID =  X_TEMPLATE_ID
        AND   object_version_number = l_obj_verno;

        UPDATE  AMS_PROD_TEMPLATES_TL
        SET      template_name = X_TEMPLATE_NAME
	      ,description   = X_DESCRIPTION
	      ,last_update_date = sysdate
	      ,last_updated_by = l_user_id
	      ,last_update_login = 0
	      ,source_lang = USERENV('LANG')
        WHERE  TEMPLATE_ID =  X_TEMPLATE_ID
        AND    USERENV('LANG') IN (language, source_lang);
    end if;
end if;

END LOAD_ROW;

end AMS_PROD_TEMPLATE_PKG;

/
