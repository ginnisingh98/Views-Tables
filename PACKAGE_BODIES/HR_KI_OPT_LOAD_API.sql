--------------------------------------------------------
--  DDL for Package Body HR_KI_OPT_LOAD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KI_OPT_LOAD_API" as
/* $Header: hrkioptl.pkb 120.3 2008/03/20 07:44:12 avarri ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'HR_KI_OPT_LOAD_API';
--
procedure UPDATE_ROW (

   X_OPTION_ID               in number
  ,X_VALUE                   in varchar2
  ,X_ENCRYPTED               in varchar2
  ,X_LAST_UPDATE_DATE        in DATE
  ,X_LAST_UPDATED_BY         in NUMBER
  ,X_LAST_UPDATE_LOGIN       in NUMBER
  ,X_OBJECT_VERSION_NUMBER   in NUMBER

) is

l_integration_id number;
l_option_type_id number;
l_option_level_id varchar2(50);
l_value varchar2(1000);

begin

  select integration_id,option_type_id,option_level_id
    into l_integration_id,l_option_type_id,l_option_level_id
      from hr_ki_options
    where OPTION_ID = X_OPTION_ID;

  if X_ENCRYPTED = 'Y' then
    l_value :=   l_integration_id  || '#'
              || l_option_type_id  || '#'
              || l_option_level_id || '#'
              || X_OPTION_ID;
    FND_VAULT.PUT('KI',l_value,X_VALUE);
  else
    l_value := X_VALUE;
  end if;

   update HR_KI_OPTIONS
   set
    VALUE = l_value ,
    ENCRYPTED = X_ENCRYPTED,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER+1
  where OPTION_ID = X_OPTION_ID;




end UPDATE_ROW;


procedure INSERT_ROW (

  X_ROWID in out nocopy VARCHAR2,
  X_OPTION_ID in out nocopy NUMBER,
  X_OPTION_TYPE_ID in number,
  X_OPTION_LEVEL in number,
  X_OPTION_LEVEL_ID in varchar2,
  X_INTEGRATION_ID in number,
  X_VALUE in varchar2,
  X_ENCRYPTED in varchar2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER

) is
  cursor C is select ROWID from HR_KI_OPTIONS
    where option_id = X_OPTION_ID;

  l_value varchar2(1000);

begin
  select HR_KI_OPTIONS_S.NEXTVAL into X_OPTION_ID from sys.dual;
  if X_ENCRYPTED = 'Y' then
    l_value :=   X_INTEGRATION_ID  || '#'
              || X_OPTION_TYPE_ID  || '#'
              || X_OPTION_LEVEL_ID || '#'
              || X_OPTION_ID;
    FND_VAULT.PUT('KI',l_value,X_VALUE);

  else
    l_value := X_VALUE;
  end if;

  insert into HR_KI_OPTIONS (
    OPTION_ID,
    OPTION_TYPE_ID,
    OPTION_LEVEL,
    OPTION_LEVEL_ID,
    INTEGRATION_ID,
    VALUE,
    ENCRYPTED,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER
  ) values (
    X_OPTION_ID,
    X_OPTION_TYPE_ID,
    X_OPTION_LEVEL,
    X_OPTION_LEVEL_ID,
    X_INTEGRATION_ID,
    l_value,
    X_ENCRYPTED,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    1
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
      close c;
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE',
                                   'hr_ki_options.insert_row');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
  end if;
  close c;




end INSERT_ROW;

procedure validate_row(
   X_OPTION_TYPE_KEY  in varchar2,
   X_OPTION_LEVEL     in number,
   X_OPTION_LEVEL_KEY in varchar2,
   X_INTEGRATION_KEY  in varchar2,
   X_INTEGRATION_ID   in out nocopy number,
   X_OPTION_TYPE_ID   in out nocopy number,
   X_OPTION_LEVEL_ID  in out nocopy varchar2
   )
  is
  CURSOR CUR_VALIDATE_INT IS
        select integration_id
        from
        hr_ki_integrations
        where
        upper(integration_key) = upper(X_INTEGRATION_KEY);

  CURSOR CUR_VALIDATE_OTY IS
        select option_type_id
        from
        hr_ki_option_types
        where
        upper(option_type_key) = upper(X_OPTION_TYPE_KEY);

  CURSOR CUR_VALIDATE_LEVEL_APP IS
        select application_id from fnd_application
        where
        application_short_name = X_OPTION_LEVEL_KEY;

  CURSOR CUR_VALIDATE_LEVEL_RESP IS
        select responsibility_id||'#'||application_id from fnd_responsibility
        where
        responsibility_key = X_OPTION_LEVEL_KEY;

  CURSOR CUR_VALIDATE_LEVEL_USR IS
        select user_id from fnd_user
        where
        user_name = X_OPTION_LEVEL_KEY;


  begin

  OPEN CUR_VALIDATE_INT;
  FETCH CUR_VALIDATE_INT INTO X_INTEGRATION_ID;
  if (CUR_VALIDATE_INT%notfound) then
    close CUR_VALIDATE_INT;
    fnd_message.set_name('PER','PER_449955_OPT_INT_ID_ABSENT');
    fnd_message.raise_error;
  end if;
  close CUR_VALIDATE_INT;

  OPEN CUR_VALIDATE_OTY;
  FETCH CUR_VALIDATE_OTY INTO X_OPTION_TYPE_ID;
  if (CUR_VALIDATE_OTY%notfound) then
    close CUR_VALIDATE_OTY;
    fnd_message.set_name('PER','PER_449953_OPT_OP_TY_ID_ABSENT');
    fnd_message.raise_error;
  end if;
  close CUR_VALIDATE_OTY;

  if X_OPTION_LEVEL=100 then

     X_OPTION_LEVEL_ID :=null;

  elsif X_OPTION_LEVEL=80 then
      OPEN CUR_VALIDATE_LEVEL_APP;
      FETCH CUR_VALIDATE_LEVEL_APP INTO X_OPTION_LEVEL_ID;
      if (CUR_VALIDATE_LEVEL_APP%notfound) then
      close CUR_VALIDATE_LEVEL_APP;
      fnd_message.set_name('PER','PER_449958_OPT_OP_APP_ID_ERR');
      fnd_message.raise_error;
      end if;
      close CUR_VALIDATE_LEVEL_APP;

  elsif X_OPTION_LEVEL=60 then
      OPEN CUR_VALIDATE_LEVEL_RESP;
      FETCH CUR_VALIDATE_LEVEL_RESP INTO X_OPTION_LEVEL_ID;
      if (CUR_VALIDATE_LEVEL_RESP%notfound) then
      close CUR_VALIDATE_LEVEL_RESP;
      fnd_message.set_name('PER','PER_449959_OPT_OP_RESP_ID_ERR');
      fnd_message.raise_error;
      end if;
      close CUR_VALIDATE_LEVEL_RESP;

  elsif X_OPTION_LEVEL=20 then
      OPEN CUR_VALIDATE_LEVEL_USR;
      FETCH CUR_VALIDATE_LEVEL_USR INTO X_OPTION_LEVEL_ID;
      if (CUR_VALIDATE_LEVEL_USR%notfound) then
      close CUR_VALIDATE_LEVEL_USR;
      fnd_message.set_name('PER','PER_449960_OPT_OP_US_ID_ERR');
      fnd_message.raise_error;
      end if;
      close CUR_VALIDATE_LEVEL_USR;

  end if;

  end validate_row;

procedure LOAD_ROW
  (
   X_OPTION_TYPE_KEY  in VARCHAR2,
   X_OPTION_LEVEL     in VARCHAR2,
   X_OPTION_LEVEL_KEY in VARCHAR2,
   X_INTEGRATION_KEY  in VARCHAR2,
   X_VALUE            in VARCHAR2,
   X_ENCRYPTED        in VARCHAR2,
   X_OWNER            in VARCHAR2,
   X_CUSTOM_MODE      in VARCHAR2,
   X_LAST_UPDATE_DATE in VARCHAR2
  )
is
  l_proc               VARCHAR2(31) := 'HR_KI_OPTIONS_API.LOAD_ROW';
  l_rowid              rowid;
  l_created_by         HR_KI_OPTIONS.created_by%TYPE             := 0;
  l_creation_date      HR_KI_OPTIONS.creation_date%TYPE          := SYSDATE;
  l_last_update_date   HR_KI_OPTIONS.last_update_date%TYPE       := SYSDATE;
  l_last_updated_by    HR_KI_OPTIONS.last_updated_by%TYPE         := 0;
  l_last_update_login  HR_KI_OPTIONS.last_update_login%TYPE       := 0;
  l_option_id          HR_KI_OPTIONS.option_id%TYPE;
  l_option_level_id    HR_KI_OPTIONS.option_level_id%TYPE;
  l_option_type_id     HR_KI_OPTION_TYPES.option_type_id%TYPE;
  l_integration_id     HR_KI_INTEGRATIONS.integration_id%TYPE;
  l_object_version_number HR_KI_OPTIONS.object_version_number%TYPE;

  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

  CURSOR CUR_VALIDATE_SITE IS
        select
        distinct opt.option_id,opt.object_version_number
        from HR_KI_OPTIONS opt,HR_KI_OPTION_TYPES oty,
        hr_ki_integrations int
        where
        opt.option_type_id=oty.option_type_id
        and int.integration_id=opt.integration_id
        and upper(int.integration_key) = upper(X_INTEGRATION_KEY)
        and upper(oty.option_type_key)=upper(X_OPTION_TYPE_KEY)
        and opt.option_level=to_number(X_OPTION_LEVEL)
        and opt.option_level_id is null;

  CURSOR CUR_VALIDATE_ROLE IS
        select
        distinct opt.option_id,opt.object_version_number
        from HR_KI_OPTIONS opt,HR_KI_OPTION_TYPES oty,
        hr_ki_integrations int
        where
        opt.option_type_id=oty.option_type_id
        and int.integration_id=opt.integration_id
        and upper(int.integration_key) = upper(X_INTEGRATION_KEY)
        and upper(oty.option_type_key) =upper(X_OPTION_TYPE_KEY)
        and opt.option_level=to_number(X_OPTION_LEVEL);


  CURSOR CUR_VALIDATE_USER IS
        select
        distinct opt.option_id,opt.object_version_number
        from HR_KI_OPTIONS opt,HR_KI_OPTION_TYPES oty,
        hr_ki_integrations int,
        fnd_user usr
        where
        opt.option_type_id=oty.option_type_id
        and int.integration_id=opt.integration_id
        and upper(int.integration_key) = upper(X_INTEGRATION_KEY)
        and upper(oty.option_type_key) =upper(X_OPTION_TYPE_KEY)
        and opt.option_level=to_number(X_OPTION_LEVEL)
        and usr.user_name=X_OPTION_LEVEL_KEY
        and to_char(usr.user_id)=opt.OPTION_LEVEL_ID;

  CURSOR CUR_VALIDATE_RESP IS
        select
        distinct opt.option_id,opt.object_version_number
        from HR_KI_OPTIONS opt,HR_KI_OPTION_TYPES oty,
        hr_ki_integrations int,
        fnd_responsibility resp
        where
        opt.option_type_id=oty.option_type_id
        and int.integration_id=opt.integration_id
        and upper(int.integration_key) = upper(X_INTEGRATION_KEY)
        and upper(oty.option_type_key) = upper(X_OPTION_TYPE_KEY)
        and opt.option_level=to_number(X_OPTION_LEVEL)
        and resp.responsibility_key= X_OPTION_LEVEL_KEY
        and resp.responsibility_id =
        (substr(option_level_id, 0, instr(option_level_id, '#') - 1))
        and resp.application_id =
        (substr(option_level_id, instr(option_level_id, '#') + 1));

  CURSOR CUR_VALIDATE_APP IS
        select
        distinct opt.option_id,opt.object_version_number
        from HR_KI_OPTIONS opt,HR_KI_OPTION_TYPES oty,
        hr_ki_integrations int,
        fnd_application app
        where
        opt.option_type_id=oty.option_type_id
        and int.integration_id=opt.integration_id
        and upper(int.integration_key) = upper(X_INTEGRATION_KEY)
        and upper(oty.option_type_key) =upper(X_OPTION_TYPE_KEY)
        and opt.option_level=to_number(X_OPTION_LEVEL)
        and app.application_short_name=X_OPTION_LEVEL_KEY
        and to_char(app.application_id)=opt.OPTION_LEVEL_ID;

  begin
  --
  -- added for 5354277
     hr_general.g_data_migrator_mode := 'Y';
  --

  -- Translate owner to file_last_updated_by
  l_last_updated_by := fnd_load_util.owner_id(X_OWNER);
  l_created_by := fnd_load_util.owner_id(X_OWNER);

  -- Translate char last_update_date to date
  l_last_update_date := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD hh24:mi:ss'), sysdate);


  -- Update or insert row as appropriate
  if X_OPTION_LEVEL =100 then
  OPEN CUR_VALIDATE_SITE;
  FETCH CUR_VALIDATE_SITE INTO l_option_id,l_object_version_number;
  close CUR_VALIDATE_SITE;

  elsif X_OPTION_LEVEL =80 then
  OPEN CUR_VALIDATE_APP;
  FETCH CUR_VALIDATE_APP INTO l_option_id,l_object_version_number;
  close CUR_VALIDATE_APP;

  elsif X_OPTION_LEVEL =60 then
  OPEN CUR_VALIDATE_RESP;
  FETCH CUR_VALIDATE_RESP INTO l_option_id,l_object_version_number;
  close CUR_VALIDATE_RESP;

  elsif X_OPTION_LEVEL =40 then
  OPEN CUR_VALIDATE_ROLE;
  FETCH CUR_VALIDATE_ROLE INTO l_option_id,l_object_version_number;
  close CUR_VALIDATE_ROLE;

  elsif X_OPTION_LEVEL =20 then
  OPEN CUR_VALIDATE_USER;
  FETCH CUR_VALIDATE_USER INTO l_option_id,l_object_version_number;
  close CUR_VALIDATE_USER;

  end if;

  select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from HR_KI_OPTIONS
          where option_id = l_option_id;


  if (fnd_load_util.upload_test(l_last_updated_by, l_last_update_date, db_luby,
                                        db_ludate, X_CUSTOM_MODE)) then

      UPDATE_ROW
      (
        X_OPTION_ID                => l_option_id
       ,X_VALUE                    => X_VALUE
       ,X_ENCRYPTED                => X_ENCRYPTED
       ,X_LAST_UPDATE_DATE         => l_last_update_date
       ,X_LAST_UPDATED_BY          => l_last_updated_by
       ,X_LAST_UPDATE_LOGIN        => l_last_update_login
       ,X_OBJECT_VERSION_NUMBER    => l_object_version_number
      );

  end if;
  exception
  when no_data_found then


      validate_row
      (
       X_OPTION_TYPE_KEY  => X_OPTION_TYPE_KEY,
       X_OPTION_LEVEL     => to_number(X_OPTION_LEVEL),
       X_OPTION_LEVEL_KEY => X_OPTION_LEVEL_KEY,
       X_INTEGRATION_KEY  => X_INTEGRATION_KEY,
       X_INTEGRATION_ID   => l_integration_id,
       X_OPTION_TYPE_ID   => l_option_type_id,
       X_OPTION_LEVEL_ID  => l_option_level_id
       );


      INSERT_ROW
        (X_ROWID                    => l_rowid
        ,X_OPTION_ID                => l_option_id
        ,X_OPTION_TYPE_ID           => l_option_type_id
        ,X_OPTION_LEVEL             => to_number(X_OPTION_LEVEL)
        ,X_OPTION_LEVEL_ID          => l_option_level_id
        ,X_INTEGRATION_ID           => l_integration_id
        ,X_VALUE                    => X_VALUE
        ,X_ENCRYPTED                => X_ENCRYPTED
        ,X_CREATED_BY               => l_created_by
        ,X_CREATION_DATE            => l_creation_date
        ,X_LAST_UPDATE_DATE         => l_last_update_date
        ,X_LAST_UPDATED_BY          => l_last_updated_by
        ,X_LAST_UPDATE_LOGIN        => l_last_update_login
        );

--
end LOAD_ROW;

END HR_KI_OPT_LOAD_API;

/
