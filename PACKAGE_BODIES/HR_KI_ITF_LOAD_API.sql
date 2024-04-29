--------------------------------------------------------
--  DDL for Package Body HR_KI_ITF_LOAD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KI_ITF_LOAD_API" as
/* $Header: hrkiitfl.pkb 120.1 2006/06/27 16:04:45 avarri noship $ */
--
-- Package Variables
--
g_package  varchar2(31) := 'HR_KI_ITF_LOAD_API';
--

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_USER_INTERFACE_ID in out nocopy NUMBER,
  X_USER_INTERFACE_KEY in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_FORM_NAME in varchar2,
  X_PAGE_REGION_CODE in VARCHAR2,
  X_REGION_CODE in VARCHAR2,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER

) is

cursor C is select ROWID from HR_KI_USER_INTERFACES
    where user_interface_id = X_USER_INTERFACE_ID;

begin

select HR_KI_USER_INTERFACES_S.NEXTVAL into X_USER_INTERFACE_ID from sys.dual;

  insert into HR_KI_USER_INTERFACES (
    USER_INTERFACE_ID,
    USER_INTERFACE_KEY,
    TYPE,
    FORM_NAME,
    PAGE_REGION_CODE,
    REGION_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER
  ) values (
    X_USER_INTERFACE_ID,
    X_USER_INTERFACE_KEY,
    X_TYPE,
    X_FORM_NAME,
    X_PAGE_REGION_CODE,
    X_REGION_CODE,
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
                                   'HR_KI_HIERARCHIES.insert_row');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
  end if;
  close c;

end INSERT_ROW;

procedure LOAD_ROW
  (
   X_USER_INTERFACE_KEY   in VARCHAR2,
   X_TYPE                 in VARCHAR2,
   X_FORM_NAME            in VARCHAR2,
   X_PAGE_REGION_CODE     in VARCHAR2,
   X_REGION_CODE          in VARCHAR2,
   X_LAST_UPDATE_DATE     in VARCHAR2,
   X_CUSTOM_MODE          in VARCHAR2,
   X_OWNER                in VARCHAR2
  )

is
  l_proc               VARCHAR2(31) := 'HR_KI_ITF_LOAD_API.LOAD_ROW';
  l_rowid              rowid;
  l_created_by         HR_KI_USER_INTERFACES.created_by%TYPE             := 0;
  l_creation_date      HR_KI_USER_INTERFACES.creation_date%TYPE          := SYSDATE;
  l_last_update_date   HR_KI_USER_INTERFACES.last_update_date%TYPE       := SYSDATE;
  l_last_updated_by    HR_KI_USER_INTERFACES.last_updated_by%TYPE         := 0;
  l_last_update_login  HR_KI_USER_INTERFACES.last_update_login%TYPE       := 0;
  l_user_interface_id  HR_KI_USER_INTERFACES.user_interface_id%TYPE;

  l_object_version_number HR_KI_USER_INTERFACES.object_version_number%TYPE;

  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db



  CURSOR C_APPL IS
        select user_interface_id,object_version_number
        from HR_KI_USER_INTERFACES
        where upper(user_interface_key) = upper(X_USER_INTERFACE_KEY);

  begin
  --
  -- added for 5354277
     hr_general.g_data_migrator_mode := 'Y';
  --

  --
  -- do any validations if necessary

  -- Translate owner to file_last_updated_by
  l_last_updated_by := fnd_load_util.owner_id(X_OWNER);
  l_created_by := fnd_load_util.owner_id(X_OWNER);

  -- Translate char last_update_date to date
  l_last_update_date := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD hh24:mi:ss'), sysdate);


  -- Update or insert row as appropriate

  OPEN C_APPL;
  FETCH C_APPL INTO l_user_interface_id,l_object_version_number;


  if C_APPL%notfound then
  close C_APPL;
      INSERT_ROW
        (
         X_ROWID                    => l_rowid
        ,X_USER_INTERFACE_ID        => l_user_interface_id
        ,X_USER_INTERFACE_KEY       => X_USER_INTERFACE_KEY
        ,X_TYPE                     => X_TYPE
        ,X_FORM_NAME                => X_FORM_NAME
        ,X_PAGE_REGION_CODE         => X_PAGE_REGION_CODE
	,X_REGION_CODE              => X_REGION_CODE
        ,X_CREATED_BY               => l_created_by
        ,X_CREATION_DATE            => l_creation_date
        ,X_LAST_UPDATE_DATE         => l_last_update_date
        ,X_LAST_UPDATED_BY          => l_last_updated_by
        ,X_LAST_UPDATE_LOGIN        => l_last_update_login
        );


  else
  close C_APPL;

  -- we do not provide update functionality as developer keys can never be updated
  -- and the user_interface_key depends on values that can potentially be updated
  -- a combination is always treated as a changed combination
  end if;
--
end LOAD_ROW;

END HR_KI_ITF_LOAD_API;

/
