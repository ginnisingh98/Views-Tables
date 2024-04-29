--------------------------------------------------------
--  DDL for Package Body HR_SOURCE_FORM_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SOURCE_FORM_TEMPLATES_PKG" as
/* $Header: hrsftlct.pkb 115.3 2002/12/11 06:50:42 raranjan noship $ */
procedure OWNER_TO_WHO (
  X_OWNER in VARCHAR2,
  X_CREATION_DATE out nocopy DATE,
  X_CREATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_DATE out nocopy DATE,
  X_LAST_UPDATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_LOGIN out nocopy NUMBER
) is
begin
  if X_OWNER = 'SEED' then
    X_CREATED_BY := 1;
    X_LAST_UPDATED_BY := 1;
  else
    X_CREATED_BY := 0;
    X_LAST_UPDATED_BY := 0;
  end if;
  X_CREATION_DATE := sysdate;
  X_LAST_UPDATE_DATE := sysdate;
  X_LAST_UPDATE_LOGIN := 0;
end OWNER_TO_WHO;
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_SOURCE_FORM_TEMPLATE_ID in NUMBER,
  X_FORM_TEMPLATE_ID_FROM in NUMBER,
  X_FORM_TEMPLATE_ID_TO in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from HR_SOURCE_FORM_TEMPLATES
    where SOURCE_FORM_TEMPLATE_ID = X_SOURCE_FORM_TEMPLATE_ID
    ;
begin
  insert into HR_SOURCE_FORM_TEMPLATES (
    FORM_TEMPLATE_ID_FROM,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    FORM_TEMPLATE_ID_TO,
    SOURCE_FORM_TEMPLATE_ID)
  values (
    X_FORM_TEMPLATE_ID_FROM,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_FORM_TEMPLATE_ID_TO,
    X_SOURCE_FORM_TEMPLATE_ID);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_SOURCE_FORM_TEMPLATE_ID in NUMBER,
  X_FORM_TEMPLATE_ID_FROM in NUMBER,
  X_FORM_TEMPLATE_ID_TO in NUMBER
) is
  cursor c1 is select
      FORM_TEMPLATE_ID_FROM,
      FORM_TEMPLATE_ID_TO
    from HR_SOURCE_FORM_TEMPLATES
    where SOURCE_FORM_TEMPLATE_ID = X_SOURCE_FORM_TEMPLATE_ID
    for update of SOURCE_FORM_TEMPLATE_ID nowait;
begin
  for tlinfo in c1 loop
          if ((tlinfo.FORM_TEMPLATE_ID_FROM = X_FORM_TEMPLATE_ID_FROM)
               OR ((tlinfo.FORM_TEMPLATE_ID_FROM is null) AND (X_FORM_TEMPLATE_ID_FROM is null)))
          AND (tlinfo.FORM_TEMPLATE_ID_TO = X_FORM_TEMPLATE_ID_TO)
       then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_SOURCE_FORM_TEMPLATE_ID in NUMBER,
  X_FORM_TEMPLATE_ID_FROM in NUMBER,
  X_FORM_TEMPLATE_ID_TO in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update HR_SOURCE_FORM_TEMPLATES set
    FORM_TEMPLATE_ID_FROM = X_FORM_TEMPLATE_ID_FROM,
    FORM_TEMPLATE_ID_TO = X_FORM_TEMPLATE_ID_TO,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where SOURCE_FORM_TEMPLATE_ID = X_SOURCE_FORM_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_SOURCE_FORM_TEMPLATE_ID in NUMBER
) is
begin
  delete from HR_SOURCE_FORM_TEMPLATES
  where SOURCE_FORM_TEMPLATE_ID = X_SOURCE_FORM_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME_TO in VARCHAR2,
  X_FORM_NAME_TO in VARCHAR2,
  X_TEMPLATE_NAME_TO in VARCHAR2,
  X_TERRITORY_SHORT_NAME_TO in VARCHAR2 ,
  X_APPLICATION_SHORT_NAME_FROM in VARCHAR2,
  X_FORM_NAME_FROM in VARCHAR2,
  X_TEMPLATE_NAME_FROM in VARCHAR2,
  X_TERRITORY_SHORT_NAME_FROM in VARCHAR2,
  X_OWNER in VARCHAR2) is
  X_ROWID ROWID;
  X_CREATION_DATE DATE;
  X_CREATED_BY NUMBER;
  X_LAST_UPDATE_DATE DATE;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  X_FORM_ID NUMBER;
  X_LEGISLATION_CODE VARCHAR2(4);
  X_APPLICATION_ID NUMBER;
  X_FORM_TEMPLATE_ID_TO NUMBER;
  X_FORM_TEMPLATE_ID_FROM NUMBER;
  X_SOURCE_FORM_TEMPLATE_ID NUMBER;
begin

  OWNER_TO_WHO (
    X_OWNER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

 select application_id
 into x_application_id
 from fnd_application
 where application_short_name = x_application_short_name_to;

 select form_id
 into x_form_id
 from fnd_form
 where form_name = x_form_name_to
 and application_id = x_application_id;

 select form_template_id
 into x_form_template_id_to
 from hr_form_templates_b
 where template_name =  x_template_name_to
 and (  (legislation_code is null and x_territory_short_name_to is null)
     or (legislation_code = x_territory_short_name_to) )
 and application_id = x_application_id
 and form_id = x_form_id;

 IF ( ltrim(rtrim(x_application_short_name_from)) IS NOT NULL ) AND
    ( ltrim(rtrim(x_form_name_from)) IS NOT NULL ) AND
    ( ltrim(rtrim(x_template_name_from)) IS NOT NULL ) THEN

 select application_id
 into x_application_id
 from fnd_application
 where application_short_name = x_application_short_name_from;

 select form_id
 into x_form_id
 from fnd_form
 where form_name = x_form_name_from
 and application_id = x_application_id;

 select form_template_id
 into x_form_template_id_from
 from hr_form_templates_b
 where template_name =  x_template_name_from
 and (  (legislation_code is null and x_territory_short_name_from is null)
     or (legislation_code = x_territory_short_name_from) )
 and application_id = x_application_id
 and form_id = x_form_id;

 ELSE
  x_form_template_id_from := null;
 END IF;

 begin

 select source_form_template_id
 into x_source_form_template_id
 from hr_source_form_templates
  where form_template_id_to = x_form_template_id_to
  and nvl(form_template_id_from,hr_api.g_number) = nvl(x_form_template_id_from,hr_api.g_number);

 exception
   when no_data_found then
     select hr_source_form_templates_s.nextval
     into x_source_form_template_id
     from dual;
 end;


 begin
   UPDATE_ROW (
     X_SOURCE_FORM_TEMPLATE_ID,
     X_FORM_TEMPLATE_ID_FROM,
     X_FORM_TEMPLATE_ID_TO,
     X_LAST_UPDATE_DATE,
     X_LAST_UPDATED_BY,
     X_LAST_UPDATE_LOGIN
   );
 exception
   when no_data_found then
     INSERT_ROW (
       X_ROWID,
       X_SOURCE_FORM_TEMPLATE_ID,
       X_FORM_TEMPLATE_ID_FROM,
       X_FORM_TEMPLATE_ID_TO,
       X_CREATION_DATE,
       X_CREATED_BY,
       X_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN);
 end;

end LOAD_ROW;
end HR_SOURCE_FORM_TEMPLATES_PKG;

/
