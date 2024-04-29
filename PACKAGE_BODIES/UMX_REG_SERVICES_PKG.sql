--------------------------------------------------------
--  DDL for Package Body UMX_REG_SERVICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."UMX_REG_SERVICES_PKG" as
/* $Header: UMXRGSVB.pls 120.3.12000000.2 2007/04/10 04:56:23 vimohan ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_REG_SERVICE_CODE in VARCHAR2,
  X_REG_SERVICE_TYPE in VARCHAR2,
  X_WF_NOTIFICATION_EVENT_GUID in RAW,
  X_EMAIL_VERIFICATION_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_START_DATE in DATE,
  X_SECURITY_GROUP_ID in NUMBER,
  X_END_DATE in DATE,
  X_WF_ROLE_NAME in VARCHAR2,
  X_REG_FUNCTION_ID in NUMBER,
  X_AME_APPLICATION_ID in NUMBER,
  X_AME_TRANSACTION_TYPE_ID in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_USAGE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_WF_BUS_LOGIC_EVENT_GUID in RAW
) is
  cursor C is select ROWID from UMX_REG_SERVICES_B
    where REG_SERVICE_CODE = X_REG_SERVICE_CODE
    ;
begin


  insert into UMX_REG_SERVICES_B (
    REG_SERVICE_CODE,
    REG_SERVICE_TYPE,
    WF_NOTIFICATION_EVENT_GUID,
    EMAIL_VERIFICATION_FLAG,
    APPLICATION_ID,
    START_DATE,
    SECURITY_GROUP_ID,
    END_DATE,
    WF_ROLE_NAME,
    REG_FUNCTION_ID,
    AME_APPLICATION_ID,
    AME_TRANSACTION_TYPE_ID,
    WF_BUS_LOGIC_EVENT_GUID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_REG_SERVICE_CODE,
    X_REG_SERVICE_TYPE,
    X_WF_NOTIFICATION_EVENT_GUID,
    nvl(X_EMAIL_VERIFICATION_FLAG,'N'),
    X_APPLICATION_ID,
    X_START_DATE,
    X_SECURITY_GROUP_ID,
    X_END_DATE,
    X_WF_ROLE_NAME,
    X_REG_FUNCTION_ID,
    X_AME_APPLICATION_ID,
    X_AME_TRANSACTION_TYPE_ID,
    X_WF_BUS_LOGIC_EVENT_GUID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into UMX_REG_SERVICES_TL (
    REG_SERVICE_CODE,
    DISPLAY_NAME,
    DESCRIPTION,
    USAGE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_REG_SERVICE_CODE,
    X_DISPLAY_NAME,
    X_DESCRIPTION,
    X_USAGE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from UMX_REG_SERVICES_TL T
    where T.REG_SERVICE_CODE = X_REG_SERVICE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_REG_SERVICE_CODE in VARCHAR2,
  X_REG_SERVICE_TYPE in VARCHAR2,
  X_WF_NOTIFICATION_EVENT_GUID in RAW,
  X_EMAIL_VERIFICATION_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_START_DATE in DATE,
  X_SECURITY_GROUP_ID in NUMBER,
  X_END_DATE in DATE,
  X_WF_ROLE_NAME in VARCHAR2,
  X_REG_FUNCTION_ID in NUMBER,
  X_AME_APPLICATION_ID in NUMBER,
  X_AME_TRANSACTION_TYPE_ID in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_USAGE in VARCHAR2,
  X_WF_BUS_LOGIC_EVENT_GUID in RAW
) is
  cursor c is select
      REG_SERVICE_TYPE,
      WF_NOTIFICATION_EVENT_GUID,
      EMAIL_VERIFICATION_FLAG,
      APPLICATION_ID,
      START_DATE,
      SECURITY_GROUP_ID,
      END_DATE,
      WF_ROLE_NAME,
      REG_FUNCTION_ID,
      AME_APPLICATION_ID,
      AME_TRANSACTION_TYPE_ID,
      WF_BUS_LOGIC_EVENT_GUID
    from UMX_REG_SERVICES_B
    where REG_SERVICE_CODE = X_REG_SERVICE_CODE
    for update of REG_SERVICE_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION,
      USAGE,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from UMX_REG_SERVICES_TL
    where REG_SERVICE_CODE = X_REG_SERVICE_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of REG_SERVICE_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.REG_SERVICE_TYPE = X_REG_SERVICE_TYPE)
      AND (recinfo.WF_NOTIFICATION_EVENT_GUID = X_WF_NOTIFICATION_EVENT_GUID)
      AND (recinfo.EMAIL_VERIFICATION_FLAG = X_EMAIL_VERIFICATION_FLAG)
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND (recinfo.START_DATE = X_START_DATE)
      AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND ((recinfo.END_DATE = X_END_DATE)
           OR ((recinfo.END_DATE is null) AND (X_END_DATE is null)))
      AND ((recinfo.WF_ROLE_NAME = X_WF_ROLE_NAME)
           OR ((recinfo.WF_ROLE_NAME is null) AND (X_WF_ROLE_NAME is null)))
      AND ((recinfo.REG_FUNCTION_ID = X_REG_FUNCTION_ID)
           OR ((recinfo.REG_FUNCTION_ID is null) AND (X_REG_FUNCTION_ID is null)))
      AND ((recinfo.AME_APPLICATION_ID = X_AME_APPLICATION_ID)
           OR ((recinfo.AME_APPLICATION_ID is null) AND (X_AME_APPLICATION_ID is null)))
      AND ((recinfo.AME_TRANSACTION_TYPE_ID = X_AME_TRANSACTION_TYPE_ID)
           OR ((recinfo.AME_TRANSACTION_TYPE_ID is null) AND (X_AME_TRANSACTION_TYPE_ID is null)))
      AND ((recinfo.WF_BUS_LOGIC_EVENT_GUID = X_WF_BUS_LOGIC_EVENT_GUID)
           OR ((recinfo.WF_BUS_LOGIC_EVENT_GUID is null) AND (X_WF_BUS_LOGIC_EVENT_GUID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
          AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
          AND ((tlinfo.USAGE = X_USAGE)
           OR ((tlinfo.USAGE is null) AND (X_USAGE is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_REG_SERVICE_CODE in VARCHAR2,
  X_REG_SERVICE_TYPE in VARCHAR2,
  X_WF_NOTIFICATION_EVENT_GUID in RAW,
  X_EMAIL_VERIFICATION_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_START_DATE in DATE,
  X_SECURITY_GROUP_ID in NUMBER,
  X_END_DATE in DATE,
  X_WF_ROLE_NAME in VARCHAR2,
  X_REG_FUNCTION_ID in NUMBER,
  X_AME_APPLICATION_ID in NUMBER,
  X_AME_TRANSACTION_TYPE_ID in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_USAGE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_WF_BUS_LOGIC_EVENT_GUID in RAW
) is
begin
  update UMX_REG_SERVICES_B set
    REG_SERVICE_TYPE = X_REG_SERVICE_TYPE,
    WF_NOTIFICATION_EVENT_GUID = X_WF_NOTIFICATION_EVENT_GUID,
    EMAIL_VERIFICATION_FLAG = X_EMAIL_VERIFICATION_FLAG,
    APPLICATION_ID = X_APPLICATION_ID,
    START_DATE = X_START_DATE,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    END_DATE = X_END_DATE,
    WF_ROLE_NAME = X_WF_ROLE_NAME,
    REG_FUNCTION_ID = X_REG_FUNCTION_ID,
    AME_APPLICATION_ID = X_AME_APPLICATION_ID,
    AME_TRANSACTION_TYPE_ID = X_AME_TRANSACTION_TYPE_ID,
    WF_BUS_LOGIC_EVENT_GUID = X_WF_BUS_LOGIC_EVENT_GUID ,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where REG_SERVICE_CODE = X_REG_SERVICE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update UMX_REG_SERVICES_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    USAGE = X_USAGE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where REG_SERVICE_CODE = X_REG_SERVICE_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_REG_SERVICE_CODE in VARCHAR2
) is
begin
  delete from UMX_REG_SERVICES_TL
  where REG_SERVICE_CODE = X_REG_SERVICE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from UMX_REG_SERVICES_B
  where REG_SERVICE_CODE = X_REG_SERVICE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from UMX_REG_SERVICES_TL T
  where not exists
    (select NULL
    from UMX_REG_SERVICES_B B
    where B.REG_SERVICE_CODE = T.REG_SERVICE_CODE
    );

  update UMX_REG_SERVICES_TL T set (
      DISPLAY_NAME,
      DESCRIPTION,
      USAGE
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION,
      B.USAGE
    from UMX_REG_SERVICES_TL B
    where B.REG_SERVICE_CODE = T.REG_SERVICE_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.REG_SERVICE_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.REG_SERVICE_CODE,
      SUBT.LANGUAGE
    from UMX_REG_SERVICES_TL SUBB, UMX_REG_SERVICES_TL SUBT
    where SUBB.REG_SERVICE_CODE = SUBT.REG_SERVICE_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or SUBB.USAGE <> SUBT.USAGE
  ));

  insert into UMX_REG_SERVICES_TL (
    REG_SERVICE_CODE,
    DISPLAY_NAME,
    DESCRIPTION,
    USAGE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.REG_SERVICE_CODE,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    B.USAGE,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from UMX_REG_SERVICES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from UMX_REG_SERVICES_TL T
    where T.REG_SERVICE_CODE = B.REG_SERVICE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


Procedure LOAD_ROW(
  X_REG_SERVICE_CODE in VARCHAR2,
  X_REG_SERVICE_TYPE in VARCHAR2,
  X_WF_NOTIFICATION_EVENT_GUID in VARCHAR2,
  X_EMAIL_VERIFICATION_FLAG in VARCHAR2,
  X_APP_SHORT_NAME in VARCHAR2,
  X_START_DATE in VARCHAR2,
  X_END_DATE in  VARCHAR2,
  X_WF_ROLE_NAME in VARCHAR2,
  X_REG_FUNCTION_NAME in VARCHAR2,
  X_AME_APP_SHORT_NAME in VARCHAR2,
  X_AME_TRANSACTION_TYPE_ID in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_USAGE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_WF_BUS_LOGIC_EVENT_GUID in VARCHAR2

) IS
 app_id  number;
 ame_app_id number;
 row_id  varchar2(64);
 f_luby NUMBER;
 f_ludate  date;    -- entity update date in file
 db_luby   number;  -- entity owner in db
 db_ludate date;    -- entity update date in db

 l_ntf_guid_raw WF_EVENTS.guid%type;
 l_BUS_LOGIC_guid_raw WF_EVENTS.guid%type;
 l_event_name WF_EVENTS.name%type;
 l_wf_role_name wf_local_roles.name%type;
 l_reg_function_id fnd_form_functions.function_id%type;
 l_transaction_type_id AME_TRANSACTION_TYPES_V.transaction_type_id%type;

 l_start_date date;
 l_end_date date;

 CURSOR regfunction is
   select function_id
   from fnd_form_functions
   where function_name = X_REG_FUNCTION_NAME;

 CURSOR roleName is
   select name from WF_LOCAL_ROLES
   where name = X_WF_ROLE_NAME;

 CURSOR eventName(x_guid_raw in RAW) is
   select name
   from wf_events
   where  guid = HEXTORAW(x_guid_raw);

 CURSOR ame is
  select ame.TRANSACTION_TYPE_ID, fa.APPLICATION_ID
  from  AME_TRANSACTION_TYPES_V ame, fnd_application fa
  where nvl(END_DATE,SYSDATE+1) > SYSDATE
  and fa.application_short_name = X_AME_APP_SHORT_NAME
  and ame.TRANSACTION_TYPE_ID = X_AME_TRANSACTION_TYPE_ID;

 CURSOR application is
  select application_id
  from   fnd_application
  where  application_short_name = X_APP_SHORT_NAME;

BEGIN

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);



  --validate ame,event_guid,reg_function_name, role_name
  --convert date or default to sysdate

  --application id
  if(X_APP_SHORT_NAME is not null) then
   open application;
   fetch application into app_id;

   if(application%notfound) then
    close application;
    raise_application_error(-20001,'Upload failed, illegal appname for:'||X_REG_SERVICE_CODE);
   else
    close application;
   end if;
  end if;

  --  notification event guid validation
  if (X_WF_NOTIFICATION_EVENT_GUID is not null) then
   l_ntf_guid_raw := hextoraw(X_WF_NOTIFICATION_EVENT_GUID);

   open eventName(l_ntf_guid_raw);
   fetch eventName into l_event_name;
   if (eventName%notfound) then
    close eventName;
    raise_application_error(-20001,'Upload failed, illegal notficationguid for:'||X_REG_SERVICE_CODE|| '. Make sure that the event exists in the target schema. If error persists download the ldt file using the latest lct file');
   else
    close eventName;
   end if;

  end if;
  --  BUS_LOGIC event guid validation
  if (X_WF_BUS_LOGIC_EVENT_GUID is not null) then
   l_BUS_LOGIC_guid_raw := hextoraw(X_WF_BUS_LOGIC_EVENT_GUID);

   open eventName(l_BUS_LOGIC_guid_raw);
   fetch eventName into l_event_name;
   if (eventName%notfound) then
    close eventName;
    raise_application_error(-20001,'Upload failed, illegal BUS_LOGICguid for:'||X_REG_SERVICE_CODE || '. Make sure that the event exists in the target schema. If error persists download the ldt file using the latest lct file');
   else
    close eventName;
   end if;

  end if;


  -- role name validation
  if(X_WF_ROLE_NAME is NOT NULL) then
   open roleName;
   fetch roleName into L_WF_ROLE_NAME;

   if (roleName%notfound) then
    close roleName;
    raise_application_error(-20001,'Upload failed,illegal rolename for:'||X_REG_SERVICE_CODE);
   else
    close roleName;
   end if;

  end if;

  -- reg function validation
  if(X_REG_FUNCTION_NAME IS NOT NULL) then
   open regFunction;
   fetch regFunction into l_reg_function_id;

   if(regFunction%notfound) then
    close regFunction;
    raise_application_error(-20001,'Upload failed,illegal formfunction for:'||X_REG_SERVICE_CODE ||'. Make sure that the function exists in the target schema');
   else
    close regFunction;
   end if;

  end if;

  -- ame validation

  if(X_AME_TRANSACTION_TYPE_ID IS NOT NULL and
     X_AME_APP_SHORT_NAME IS NOT NULL)  then

     open ame;
     fetch ame into l_transaction_type_id, ame_app_id;
     if (ame%notfound) then
      close ame;
      raise_application_error(-20001,'Upload failed,illegal ame for:'||X_REG_SERVICE_CODE ||'. Make sure that the AME transaction type exists in the target schema');
     else
      close ame;
     end if;

  end if;

  --start date and end_date conversion
  if(X_START_DATE is not null) then
   l_start_date := to_date(X_START_DATE, 'YYYY/MM/DD');
  end if;

  if(X_END_DATE is not null) then
   l_end_date := to_date(X_END_DATE, 'YYYY/MM/DD');
  end if;

 --db last update date and updated by for this regsvc code
 select last_updated_by, last_update_date
 into db_luby, db_ludate
 from umx_reg_services_b
 where reg_service_code = X_REG_SERVICE_CODE;
 -- test if this is a update and if it fails then create a new entry
  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then

    UMX_REG_SERVICES_PKG.UPDATE_ROW(
       X_REG_SERVICE_CODE => X_REG_SERVICE_CODE,
       X_REG_SERVICE_TYPE => X_REG_SERVICE_TYPE,
       X_WF_NOTIFICATION_EVENT_GUID => l_ntf_guid_raw,
       X_EMAIL_VERIFICATION_FLAG => X_EMAIL_VERIFICATION_FLAG,
       X_APPLICATION_ID => app_id,
       X_START_DATE => l_start_date,
       X_END_DATE => l_end_date,
       X_WF_ROLE_NAME => X_WF_ROLE_NAME,
       X_REG_FUNCTION_ID => l_reg_function_id,
       X_AME_APPLICATION_ID => ame_app_id,
       X_AME_TRANSACTION_TYPE_ID => X_AME_TRANSACTION_TYPE_ID,
       X_WF_BUS_LOGIC_EVENT_GUID => l_BUS_LOGIC_guid_raw,
       X_DISPLAY_NAME => X_DISPLAY_NAME,
       X_DESCRIPTION => X_DESCRIPTION,
       X_USAGE => X_USAGE,
       X_LAST_UPDATE_DATE => f_ludate,
       X_LAST_UPDATED_BY => f_luby,
       X_LAST_UPDATE_LOGIN => 0
    );
  end if;

 exception
  when NO_DATA_FOUND then
  UMX_REG_SERVICES_PKG.INSERT_ROW(
    X_ROWID => row_id,
    X_REG_SERVICE_CODE => X_REG_SERVICE_CODE,
    X_REG_SERVICE_TYPE => X_REG_SERVICE_TYPE,
    X_WF_NOTIFICATION_EVENT_GUID  => l_ntf_guid_raw,
    X_EMAIL_VERIFICATION_FLAG => X_EMAIL_VERIFICATION_FLAG,
    X_APPLICATION_ID => app_id,
    X_START_DATE => l_start_date,
    X_END_DATE => l_end_date,
    X_WF_ROLE_NAME => X_WF_ROLE_NAME,
    X_REG_FUNCTION_ID => l_reg_function_id,
    X_AME_APPLICATION_ID => ame_app_id,
    X_AME_TRANSACTION_TYPE_ID => X_AME_TRANSACTION_TYPE_ID,
    X_WF_BUS_LOGIC_EVENT_GUID => l_BUS_LOGIC_guid_raw,
    X_DISPLAY_NAME =>X_DISPLAY_NAME,
    X_DESCRIPTION => X_DESCRIPTION,
    X_USAGE => X_USAGE,
    X_CREATION_DATE => f_ludate,
    X_CREATED_BY => f_luby,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0
  );

END LOAD_ROW;


Procedure TRANSLATE_ROW(
  X_REG_SERVICE_CODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_USAGE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
)IS
 f_luby number;
 f_ludate  date;    -- entity update date in file
 db_luby   number;  -- entity owner in db
 db_ludate date;    -- entity update date in db
 BEGIN

 -- Translate owner to file_last_updated_by
 f_luby := fnd_load_util.owner_id(x_owner);

 -- Translate char last_update_date to date
 f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

 select LAST_UPDATED_BY, LAST_UPDATE_DATE
 into db_luby, db_ludate
 from umx_reg_services_tl
 where reg_service_code = X_REG_SERVICE_CODE
 and userenv('LANG') = LANGUAGE;

 if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then

     update umx_reg_services_tl
     set
     display_name        = nvl(X_DISPLAY_NAME, display_name),
     description         = nvl(X_DESCRIPTION, description),
     usage               = nvl(X_USAGE,usage),
     source_lang         = userenv('LANG'),
     last_update_date    = f_ludate,
     last_updated_by     = f_luby,
     last_update_login   = 0
     where reg_service_code = X_REG_SERVICE_CODE
     and userenv('LANG') in (language, source_lang);

  end if;


 END TRANSLATE_ROW;

Procedure LOAD_ROW(
  X_REG_SERVICE_CODE in VARCHAR2,
  X_REG_SERVICE_TYPE in VARCHAR2,
  X_WF_NOTIFICATION_EVENT_GUID in VARCHAR2,
  X_EMAIL_VERIFICATION_FLAG in VARCHAR2,
  X_APP_SHORT_NAME in VARCHAR2,
  X_START_DATE in VARCHAR2,
  X_END_DATE in  VARCHAR2,
  X_WF_ROLE_NAME in VARCHAR2,
  X_REG_FUNCTION_NAME in VARCHAR2,
  X_AME_APP_SHORT_NAME in VARCHAR2,
  X_AME_TRANSACTION_TYPE_ID in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_USAGE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_WF_BUS_LOGIC_EVENT_GUID in VARCHAR2,
  X_WF_NOTIFICATION_EVENT_NAME in VARCHAR2,
  X_WF_BUS_LOGIC_EVENT_NAME in VARCHAR2

) IS

  cursor get_notification_guid is
  select guid from wf_events
  where name = X_WF_NOTIFICATION_EVENT_NAME;

  cursor get_bus_guid is
  select guid from wf_events
  where name = X_WF_BUS_LOGIC_EVENT_NAME;

  l_wf_notification_guid wf_events.guid%type;
  l_wf_bus_logic_event_guid wf_events.guid%type;


  begin

     if  X_WF_NOTIFICATION_EVENT_NAME is not null then
       open  get_notification_guid;
       fetch get_notification_guid into l_wf_notification_guid;
       close get_notification_guid;
     else
       l_wf_notification_guid := X_WF_NOTIFICATION_EVENT_GUID;
     end if;

      if  X_WF_BUS_LOGIC_EVENT_NAME is not null then
       open  get_bus_guid;
       fetch get_bus_guid into l_wf_bus_logic_event_guid;
       close get_bus_guid;
     else
       l_wf_bus_logic_event_guid := X_WF_BUS_LOGIC_EVENT_GUID;
     end if;


  LOAD_ROW(
  X_REG_SERVICE_CODE => X_REG_SERVICE_CODE,
  X_REG_SERVICE_TYPE => X_REG_SERVICE_TYPE,
  X_WF_NOTIFICATION_EVENT_GUID => l_wf_notification_guid,
  X_EMAIL_VERIFICATION_FLAG => X_EMAIL_VERIFICATION_FLAG,
  X_APP_SHORT_NAME => X_APP_SHORT_NAME,
  X_START_DATE => X_START_DATE,
  X_END_DATE => X_END_DATE,
  X_WF_ROLE_NAME => X_WF_ROLE_NAME,
  X_REG_FUNCTION_NAME => X_REG_FUNCTION_NAME,
  X_AME_APP_SHORT_NAME => X_AME_APP_SHORT_NAME,
  X_AME_TRANSACTION_TYPE_ID => X_AME_TRANSACTION_TYPE_ID,
  X_LAST_UPDATE_DATE => X_LAST_UPDATE_DATE,
  X_DISPLAY_NAME => X_DISPLAY_NAME,
  X_DESCRIPTION => X_DESCRIPTION,
  X_USAGE => X_USAGE,
  X_OWNER => X_OWNER,
  X_CUSTOM_MODE => X_CUSTOM_MODE,
  X_WF_BUS_LOGIC_EVENT_GUID => l_wf_bus_logic_event_guid
  );

  end load_row;

end UMX_REG_SERVICES_PKG;

/
