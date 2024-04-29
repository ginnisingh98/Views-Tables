--------------------------------------------------------
--  DDL for Package Body CSF_MAP_ACC_HRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_MAP_ACC_HRS_PKG" as
/* $Header: csfmaccb.pls 120.1.12010000.2 2009/12/22 02:47:10 hhaugeru ship $ */


PROCEDURE Query_Row(
          p_customer_id          in number,
          p_customer_site_id     in number,
          p_customer_location_id in number,
          x_access_hours			out nocopy access_hours_rec) is
  cursor c_access_hours(c_customer_id number,
                        c_customer_site_id number,
                        c_customer_location_id number) is
    select ACCESS_HOUR_MAP_ID,
          CUSTOMER_ID,
          CUSTOMER_SITE_ID,
          CUSTOMER_LOCATION_ID,
          ACCESSHOUR_REQUIRED,
          AFTER_HOURS_FLAG,
          MONDAY_FIRST_START,
          MONDAY_FIRST_END,
          MONDAY_SECOND_START,
          MONDAY_SECOND_END,
          TUESDAY_FIRST_START,
          TUESDAY_FIRST_END,
          TUESDAY_SECOND_START,
          TUESDAY_SECOND_END,
          WEDNESDAY_FIRST_START,
          WEDNESDAY_FIRST_END,
          WEDNESDAY_SECOND_START,
          WEDNESDAY_SECOND_END,
          THURSDAY_FIRST_START,
          THURSDAY_FIRST_END,
          THURSDAY_SECOND_START,
          THURSDAY_SECOND_END,
          FRIDAY_FIRST_START,
          FRIDAY_FIRST_END,
          FRIDAY_SECOND_START,
          FRIDAY_SECOND_END,
          SATURDAY_FIRST_START,
          SATURDAY_FIRST_END,
          SATURDAY_SECOND_START,
          SATURDAY_SECOND_END,
          SUNDAY_FIRST_START,
          SUNDAY_FIRST_END,
          SUNDAY_SECOND_START,
          SUNDAY_SECOND_END,
          DESCRIPTION,
          OBJECT_VERSION_NUMBER,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          security_group_id
    from  csf_map_access_hours_vl
    where (c_customer_location_id is not null
           and   customer_location_id = customer_location_id)
       or (c_customer_site_id is not null
           and   c_customer_id is not null
           and   customer_id = c_customer_id
           and   customer_site_id = c_customer_site_id)
       or (c_customer_id is not null
           and   c_customer_site_id is null
           and   customer_id = c_customer_id
           and   customer_site_id is null);
begin
  if p_customer_location_id is not null then
    open  c_access_hours(c_customer_id          => null,
                         c_customer_site_id     => null,
                         c_customer_location_id => p_customer_location_id);
    fetch c_access_hours into x_access_hours;
    close c_access_hours;
  end if;
  if p_customer_site_id is not null
     and p_customer_id is not null
     and x_access_hours.access_hour_map_id is null then
    open  c_access_hours(c_customer_id          => p_customer_id,
                         c_customer_site_id     => p_customer_site_id,
                         c_customer_location_id => null);
    fetch c_access_hours into x_access_hours;
    close c_access_hours;
  end if;
  if p_customer_id is not null
     and x_access_hours.access_hour_map_id is null then
    open  c_access_hours(c_customer_id          => p_customer_id,
                         c_customer_site_id     => null,
                         c_customer_location_id => null);
    fetch c_access_hours into x_access_hours;
    close c_access_hours;
  end if;
end;

PROCEDURE Insert_Row(
          px_ACCESS_HOUR_MAP_ID  IN OUT NOCOPY NUMBER,
          p_CUSTOMER_ID          IN NUMBER,
          p_CUSTOMER_SITE_ID     IN NUMBER,
          p_CUSTOMER_LOCATION_ID IN NUMBER,
          p_ACCESSHOUR_REQUIRED IN VARCHAR2,
          p_AFTER_HOURS_FLAG IN VARCHAR2,
          p_MONDAY_FIRST_START IN DATE,
          p_MONDAY_FIRST_END IN DATE,
          p_MONDAY_SECOND_START IN DATE,
          p_MONDAY_SECOND_END IN DATE,
          p_TUESDAY_FIRST_START IN DATE,
          p_TUESDAY_FIRST_END IN DATE,
          p_TUESDAY_SECOND_START IN DATE,
          p_TUESDAY_SECOND_END IN DATE,
          p_WEDNESDAY_FIRST_START IN DATE,
          p_WEDNESDAY_FIRST_END IN DATE,
          p_WEDNESDAY_SECOND_START IN DATE,
          p_WEDNESDAY_SECOND_END IN DATE,
          p_THURSDAY_FIRST_START IN DATE,
          p_THURSDAY_FIRST_END IN DATE,
          p_THURSDAY_SECOND_START IN DATE,
          p_THURSDAY_SECOND_END IN DATE,
          p_FRIDAY_FIRST_START IN DATE,
          p_FRIDAY_FIRST_END IN DATE,
          p_FRIDAY_SECOND_START IN DATE,
          p_FRIDAY_SECOND_END IN DATE,
          p_SATURDAY_FIRST_START IN DATE,
          p_SATURDAY_FIRST_END IN DATE,
          p_SATURDAY_SECOND_START IN DATE,
          p_SATURDAY_SECOND_END IN DATE,
          p_SUNDAY_FIRST_START IN DATE,
          p_SUNDAY_FIRST_END IN DATE,
          p_SUNDAY_SECOND_START IN DATE,
          p_SUNDAY_SECOND_END IN DATE,
          p_DESCRIPTION IN VARCHAR2,
          X_OBJECT_VERSION_NUMBER Out NOCOPY NUMBER,
          p_CREATED_BY    IN NUMBER,
          p_CREATION_DATE    IN DATE,
          p_LAST_UPDATED_BY    IN NUMBER,
          p_LAST_UPDATE_DATE    IN DATE,
          p_LAST_UPDATE_LOGIN    IN NUMBER,
          p_security_group_id    IN NUMBER) is

 l_object_version_number NUMBER := 1;

begin

  insert into CSF_MAP_ACCESS_HOURS_B (
          ACCESS_HOUR_MAP_ID,
          CUSTOMER_ID,
          CUSTOMER_SITE_ID,
          CUSTOMER_LOCATION_ID,
          ACCESSHOUR_REQUIRED,
          AFTER_HOURS_FLAG,
          MONDAY_FIRST_START,
          MONDAY_FIRST_END,
          MONDAY_SECOND_START,
          MONDAY_SECOND_END,
          TUESDAY_FIRST_START,
          TUESDAY_FIRST_END,
          TUESDAY_SECOND_START,
          TUESDAY_SECOND_END,
          WEDNESDAY_FIRST_START,
          WEDNESDAY_FIRST_END,
          WEDNESDAY_SECOND_START,
          WEDNESDAY_SECOND_END,
          THURSDAY_FIRST_START,
          THURSDAY_FIRST_END,
          THURSDAY_SECOND_START,
          THURSDAY_SECOND_END,
          FRIDAY_FIRST_START,
          FRIDAY_FIRST_END,
          FRIDAY_SECOND_START,
          FRIDAY_SECOND_END,
          SATURDAY_FIRST_START,
          SATURDAY_FIRST_END,
          SATURDAY_SECOND_START,
          SATURDAY_SECOND_END,
          SUNDAY_FIRST_START,
          SUNDAY_FIRST_END,
          SUNDAY_SECOND_START,
          SUNDAY_SECOND_END,
          OBJECT_VERSION_NUMBER,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          security_group_id
  ) values (
          px_ACCESS_HOUR_MAP_ID,
          p_CUSTOMER_ID,
          p_CUSTOMER_SITE_ID,
          p_CUSTOMER_LOCATION_ID,
          p_ACCESSHOUR_REQUIRED,
          p_AFTER_HOURS_FLAG,
          p_MONDAY_FIRST_START,
          p_MONDAY_FIRST_END,
          p_MONDAY_SECOND_START,
          p_MONDAY_SECOND_END,
          p_TUESDAY_FIRST_START,
          p_TUESDAY_FIRST_END,
          p_TUESDAY_SECOND_START,
          p_TUESDAY_SECOND_END,
          p_WEDNESDAY_FIRST_START,
          p_WEDNESDAY_FIRST_END,
          p_WEDNESDAY_SECOND_START,
          p_WEDNESDAY_SECOND_END,
          p_THURSDAY_FIRST_START,
          p_THURSDAY_FIRST_END,
          p_THURSDAY_SECOND_START,
          p_THURSDAY_SECOND_END,
          p_FRIDAY_FIRST_START,
          p_FRIDAY_FIRST_END,
          p_FRIDAY_SECOND_START,
          p_FRIDAY_SECOND_END,
          p_SATURDAY_FIRST_START,
          p_SATURDAY_FIRST_END,
          p_SATURDAY_SECOND_START,
          p_SATURDAY_SECOND_END,
          p_SUNDAY_FIRST_START,
          p_SUNDAY_FIRST_END,
          p_SUNDAY_SECOND_START,
          p_SUNDAY_SECOND_END,
          l_OBJECT_VERSION_NUMBER,
    decode(P_CREATION_DATE,NULL,SYSDATE,P_CREATION_DATE),
    P_CREATED_BY,
    decode(P_LAST_UPDATE_DATE,NULL,SYSDATE,P_LAST_UPDATE_DATE),
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN,
    p_security_group_id
   ) ;

  insert into CSF_MAP_ACCESS_HOURS_TL (
          ACCESS_HOUR_MAP_ID,
          DESCRIPTION,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          security_group_id,
    LANGUAGE,
    SOURCE_LANG
  ) select
    PX_ACCESS_HOUR_MAP_ID,
    P_DESCRIPTION,
    P_CREATED_BY,
    P_CREATION_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATE_LOGIN,
    p_security_group_id,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CSF_MAP_ACCESS_HOURS_TL T
    where T.ACCESS_HOUR_MAP_ID = PX_ACCESS_HOUR_MAP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

     X_OBJECT_VERSION_NUMBER := l_object_Version_number;
end INSERT_ROW;



PROCEDURE Update_Row(
          p_ACCESS_HOUR_MAP_ID  IN NUMBER,
          p_CUSTOMER_ID          IN NUMBER,
          p_CUSTOMER_SITE_ID     IN NUMBER,
          p_CUSTOMER_LOCATION_ID IN NUMBER,
          p_ACCESSHOUR_REQUIRED IN VARCHAR2,
          p_AFTER_HOURS_FLAG IN VARCHAR2,
          p_MONDAY_FIRST_START IN DATE,
          p_MONDAY_FIRST_END IN DATE,
          p_MONDAY_SECOND_START IN DATE,
          p_MONDAY_SECOND_END IN DATE,
          p_TUESDAY_FIRST_START IN DATE,
          p_TUESDAY_FIRST_END IN DATE,
          p_TUESDAY_SECOND_START IN DATE,
          p_TUESDAY_SECOND_END IN DATE,
          p_WEDNESDAY_FIRST_START IN DATE,
          p_WEDNESDAY_FIRST_END IN DATE,
          p_WEDNESDAY_SECOND_START IN DATE,
          p_WEDNESDAY_SECOND_END IN DATE,
          p_THURSDAY_FIRST_START IN DATE,
          p_THURSDAY_FIRST_END IN DATE,
          p_THURSDAY_SECOND_START IN DATE,
          p_THURSDAY_SECOND_END IN DATE,
          p_FRIDAY_FIRST_START IN DATE,
          p_FRIDAY_FIRST_END IN DATE,
          p_FRIDAY_SECOND_START IN DATE,
          p_FRIDAY_SECOND_END IN DATE,
          p_SATURDAY_FIRST_START IN DATE,
          p_SATURDAY_FIRST_END IN DATE,
          p_SATURDAY_SECOND_START IN DATE,
          p_SATURDAY_SECOND_END IN DATE,
          p_SUNDAY_FIRST_START IN DATE,
          p_SUNDAY_FIRST_END IN DATE,
          p_SUNDAY_SECOND_START IN DATE,
          p_SUNDAY_SECOND_END IN DATE,
          p_DESCRIPTION IN VARCHAR2,
          X_OBJECT_VERSION_NUMBER Out NOCOPY NUMBER,
          p_LAST_UPDATED_BY    IN NUMBER,
          p_LAST_UPDATE_DATE    IN DATE,
          p_LAST_UPDATE_LOGIN    IN NUMBER,
          p_security_group_id    IN NUMBER) is

l_object_Version_number number;

begin
  update CSF_MAP_ACCESS_HOURS_B set
    CUSTOMER_ID  = p_CUSTOMER_ID,
    CUSTOMER_SITE_ID = p_CUSTOMER_SITE_ID,
    CUSTOMER_LOCATION_ID =      p_CUSTOMER_LOCATION_ID,
    ACCESSHOUR_REQUIRED =     p_ACCESSHOUR_REQUIRED,
    AFTER_HOURS_FLAG =     p_AFTER_HOURS_FLAG,
    MONDAY_FIRST_START =      p_MONDAY_FIRST_START,
    MONDAY_FIRST_END =     p_MONDAY_FIRST_END,
    MONDAY_SECOND_START =       p_MONDAY_SECOND_START,
    MONDAY_SECOND_END =     p_MONDAY_SECOND_END,
    TUESDAY_FIRST_START =      p_TUESDAY_FIRST_START,
    TUESDAY_FIRST_END =      p_TUESDAY_FIRST_END,
    TUESDAY_SECOND_START =      p_TUESDAY_SECOND_START,
    TUESDAY_SECOND_END =      p_TUESDAY_SECOND_END,
    WEDNESDAY_FIRST_START =     p_WEDNESDAY_FIRST_START,
    WEDNESDAY_FIRST_END =      p_WEDNESDAY_FIRST_END,
    WEDNESDAY_SECOND_START =     p_WEDNESDAY_SECOND_START,
    WEDNESDAY_SECOND_END =      p_WEDNESDAY_SECOND_END,
    THURSDAY_FIRST_START = p_THURSDAY_FIRST_START,
     THURSDAY_FIRST_END=      p_THURSDAY_FIRST_END,
     THURSDAY_SECOND_START =      p_THURSDAY_SECOND_START,
     THURSDAY_SECOND_END =     p_THURSDAY_SECOND_END,
     FRIDAY_FIRST_START =     p_FRIDAY_FIRST_START,
     FRIDAY_FIRST_END =     p_FRIDAY_FIRST_END,
     FRIDAY_SECOND_START =     p_FRIDAY_SECOND_START,
     FRIDAY_SECOND_END =     p_FRIDAY_SECOND_END,
     SATURDAY_FIRST_START =     p_SATURDAY_FIRST_START,
     SATURDAY_FIRST_END =     p_SATURDAY_FIRST_END,
     SATURDAY_SECOND_START =     p_SATURDAY_SECOND_START,
     SATURDAY_SECOND_END =     p_SATURDAY_SECOND_END,
     SUNDAY_FIRST_START =    p_SUNDAY_FIRST_START,
     SUNDAY_FIRST_END =     p_SUNDAY_FIRST_END,
     SUNDAY_SECOND_START =     p_SUNDAY_SECOND_START,
     SUNDAY_SECOND_END =      p_SUNDAY_SECOND_END,
    OBJECT_VERSION_NUMBER 	= OBJECT_VERSION_NUMBER + 1,
    LAST_UPDATE_DATE 		= P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY 		= P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN 		= P_LAST_UPDATE_LOGIN,
    security_group_id =          p_security_group_id
  where ACCESS_HOUR_MAP_ID 		= p_ACCESS_HOUR_MAP_ID
  RETURNING OBJECT_VERSION_NUMBER INTO L_OBJECT_VERSION_NUMBER;

  X_OBJECT_VERSION_NUMBER := l_object_version_number;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CSF_MAP_ACCESS_HOURS_TL set
    DESCRIPTION 	= P_DESCRIPTION,
    LAST_UPDATE_DATE 	= P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY 	= P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN 	= P_LAST_UPDATE_LOGIN,
    SOURCE_LANG 	= userenv('LANG')
  where ACCESS_HOUR_MAP_ID 		= p_ACCESS_HOUR_MAP_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;





PROCEDURE Lock_Row(
          p_ACCESS_HOUR_MAP_ID  IN NUMBER,
          P_OBJECT_VERSION_NUMBER in NUMBER) is

  cursor c is select
      OBJECT_VERSION_NUMBER
    from CSF_MAP_ACCESS_HOURS_VL
    where ACCESS_HOUR_MAP_ID 		= p_ACCESS_HOUR_MAP_ID
    for update of ACCESS_HOUR_MAP_ID nowait;

  l_object_Version_number number := 0;

begin
  open c;
  fetch c into l_object_Version_number;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  if (l_object_version_number = P_OBJECT_VERSION_NUMBER) then
    	null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;



PROCEDURE Delete_Row(
    p_ACCESS_HOUR_MAP_ID  IN NUMBER) is
begin
  delete from CSF_MAP_ACCESS_HOURS_TL
  where ACCESS_HOUR_MAP_ID 		= p_ACCESS_HOUR_MAP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CSF_MAP_ACCESS_HOURS_B
  where ACCESS_HOUR_MAP_ID 		= p_ACCESS_HOUR_MAP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;



PROCEDURE ADD_LANGUAGE is
begin
  delete from CSF_MAP_ACCESS_HOURS_TL T
  where not exists
    (select NULL
    from CSF_MAP_ACCESS_HOURS_B B
    where B.ACCESS_HOUR_MAP_ID = T.ACCESS_HOUR_MAP_ID
    );

  update CSF_MAP_ACCESS_HOURS_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from CSF_MAP_ACCESS_HOURS_TL B
    where B.ACCESS_HOUR_MAP_ID = T.ACCESS_HOUR_MAP_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ACCESS_HOUR_MAP_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ACCESS_HOUR_MAP_ID,
      SUBT.LANGUAGE
    from CSF_MAP_ACCESS_HOURS_TL SUBB, CSF_MAP_ACCESS_HOURS_TL SUBT
    where SUBB.ACCESS_HOUR_MAP_ID = SUBT.ACCESS_HOUR_MAP_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (
      SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into CSF_MAP_ACCESS_HOURS_TL (
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ACCESS_HOUR_MAP_ID,
    security_group_id,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.ACCESS_HOUR_MAP_ID,
    B.security_group_id,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CSF_MAP_ACCESS_HOURS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CSF_MAP_ACCESS_HOURS_TL T
    where T.ACCESS_HOUR_MAP_ID = B.ACCESS_HOUR_MAP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;



PROCEDURE Load_Row(
          p_ACCESS_HOUR_MAP_ID  IN NUMBER,
          p_CUSTOMER_ID          IN NUMBER,
          p_CUSTOMER_SITE_ID     IN NUMBER,
          p_CUSTOMER_LOCATION_ID IN NUMBER,
          p_ACCESSHOUR_REQUIRED IN VARCHAR2,
          p_AFTER_HOURS_FLAG IN VARCHAR2,
          p_MONDAY_FIRST_START IN DATE,
          p_MONDAY_FIRST_END IN DATE,
          p_MONDAY_SECOND_START IN DATE,
          p_MONDAY_SECOND_END IN DATE,
          p_TUESDAY_FIRST_START IN DATE,
          p_TUESDAY_FIRST_END IN DATE,
          p_TUESDAY_SECOND_START IN DATE,
          p_TUESDAY_SECOND_END IN DATE,
          p_WEDNESDAY_FIRST_START IN DATE,
          p_WEDNESDAY_FIRST_END IN DATE,
          p_WEDNESDAY_SECOND_START IN DATE,
          p_WEDNESDAY_SECOND_END IN DATE,
          p_THURSDAY_FIRST_START IN DATE,
          p_THURSDAY_FIRST_END IN DATE,
          p_THURSDAY_SECOND_START IN DATE,
          p_THURSDAY_SECOND_END IN DATE,
          p_FRIDAY_FIRST_START IN DATE,
          p_FRIDAY_FIRST_END IN DATE,
          p_FRIDAY_SECOND_START IN DATE,
          p_FRIDAY_SECOND_END IN DATE,
          p_SATURDAY_FIRST_START IN DATE,
          p_SATURDAY_FIRST_END IN DATE,
          p_SATURDAY_SECOND_START IN DATE,
          p_SATURDAY_SECOND_END IN DATE,
          p_SUNDAY_FIRST_START IN DATE,
          p_SUNDAY_FIRST_END IN DATE,
          p_SUNDAY_SECOND_START IN DATE,
          p_SUNDAY_SECOND_END IN DATE,
          p_DESCRIPTION IN VARCHAR2,
          P_OBJECT_VERSION_NUMBER IN NUMBER,
          P_OWNER                      IN VARCHAR2,
          p_CREATED_BY    IN NUMBER,
          p_CREATION_DATE    IN DATE,
          p_LAST_UPDATED_BY    IN NUMBER,
          p_LAST_UPDATE_DATE    IN DATE,
          p_LAST_UPDATE_LOGIN    IN NUMBER,
          p_security_group_id    IN NUMBER)
IS

 -- Out local variables for the update / insert row procedures.
   lx_object_version_number  NUMBER := 0;
   l_user_id                 NUMBER := 0;

   -- needed to be passed as the parameter value for the insert's in/out
   -- parameter.
   l_action_code             VARCHAR2(30);

BEGIN

   if ( p_owner = 'SEED' ) then
         l_user_id := 1;
   end if;

end Load_Row;



PROCEDURE Translate_Row( X_ACCESS_HOUR_MAP_ID  in  NUMBER,
                          X_DESCRIPTION  in varchar2,
                          X_LAST_UPDATE_DATE in date,
                          X_LAST_UPDATE_LOGIN in number,
                          X_OWNER in varchar2)
is

l_user_id  number;

begin

if X_OWNER = 'SEED' then
  l_user_id := 1;
else
  l_user_id := 0;
end if;

update CSF_MAP_ACCESS_HOURS_TL set
 description = nvl(x_description,'none'),
 last_update_date = nvl(x_last_update_date,sysdate),
 last_updated_by = l_user_id,
 last_update_login = 0,
 source_lang = userenv('LANG')
 where ACCESS_HOUR_MAP_ID = X_ACCESS_HOUR_MAP_ID
 and userenv('LANG') in (LANGUAGE,SOURCE_LANG);

end TRANSLATE_ROW;


END CSF_MAP_ACC_HRS_PKG;


/
