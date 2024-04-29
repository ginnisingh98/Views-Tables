--------------------------------------------------------
--  DDL for Package Body HR_KI_UCX_LOAD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KI_UCX_LOAD_API" as
/* $Header: hrkiucxl.pkb 120.1 2006/06/27 16:08:10 avarri noship $ */
--
-- Package Variables
--
g_package  varchar2(31) := 'HR_KI_UCX_LOAD_API';
--
procedure UPDATE_ROW (
                 X_UI_CONTEXT_ID            in number
                ,X_LABEL                    in varchar
                ,X_LOCATION                 in varchar
                ,X_LAST_UPDATE_DATE         in DATE
                ,X_LAST_UPDATED_BY          in NUMBER
                ,X_LAST_UPDATE_LOGIN        in NUMBER
                ,X_OBJECT_VERSION_NUMBER    in NUMBER
) is

begin

   update HR_KI_UI_CONTEXTS
   set
   LABEL = X_LABEL,
   LOCATION=X_LOCATION,
   LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
   LAST_UPDATED_BY = X_LAST_UPDATED_BY,
   LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
   OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER+1
  where UI_CONTEXT_ID = X_UI_CONTEXT_ID;

end UPDATE_ROW;

procedure INSERT_ROW (
  X_ROWID                    in out nocopy VARCHAR2,
  X_UI_CONTEXT_ID            in out nocopy NUMBER,
  X_USER_INTERFACE_ID        in NUMBER,
  X_UI_CONTEXT_KEY           in VARCHAR,
  X_LABEL                    in VARCHAR,
  X_LOCATION                 in VARCHAR,
  X_CREATED_BY               in NUMBER,
  X_CREATION_DATE            in DATE,
  X_LAST_UPDATE_DATE         in DATE,
  X_LAST_UPDATED_BY          in NUMBER,
  X_LAST_UPDATE_LOGIN        in NUMBER

) is

  cursor C is select ROWID from HR_KI_UI_CONTEXTS
    where ui_context_id = x_ui_context_id;

begin

select HR_KI_UI_CONTEXTS_S.NEXTVAL into x_ui_context_id from sys.dual;

  insert into HR_KI_UI_CONTEXTS (
    ui_context_id,
    ui_context_key,
    user_interface_id,
    label,
    location,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER
  ) values (
    X_UI_CONTEXT_ID,
    X_UI_CONTEXT_KEY,
    X_USER_INTERFACE_ID,
    X_LABEL,
    X_LOCATION,
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
                                   'HR_KI_UI_CONTEXTS.insert_row');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
  end if;
  close c;


end INSERT_ROW;

procedure validate_keys
(
 X_USER_INTERFACE_KEY in VARCHAR2
,X_USER_INTERFACE_ID  in out nocopy number
)
is

  l_proc VARCHAR2(35) := 'HR_KI_UCX_LOAD_API.VALIDATE_KEYS';

  CURSOR C_VAL_INT IS
        select user_interface_id
        from HR_KI_USER_INTERFACES
        where upper(user_interface_key) = upper(X_USER_INTERFACE_KEY);

begin

   open C_VAL_INT;
   fetch C_VAL_INT into X_USER_INTERFACE_ID;

   If C_VAL_INT%NOTFOUND then
      close C_VAL_INT;
      fnd_message.set_name( 'PER','PER_449569_UCX_UI_ID_ABSENT');
      fnd_message.raise_error;
   End If;

   close C_VAL_INT;


end validate_keys;

procedure LOAD_ROW
  (
   X_USER_INTERFACE_KEY in VARCHAR2,
   X_UI_CONTEXT_KEY     in VARCHAR2,
   X_LABEL              in VARCHAR2,
   X_LOCATION           in VARCHAR2,
   X_LAST_UPDATE_DATE   in VARCHAR2,
   X_CUSTOM_MODE        in VARCHAR2,
   X_OWNER              in VARCHAR2

   )
is
  l_proc               VARCHAR2(31) := 'HR_KI_UCX_LOAD_API.LOAD_ROW';
  l_rowid              rowid;
  l_created_by         HR_KI_UI_CONTEXTS.created_by%TYPE             := 0;
  l_creation_date      HR_KI_UI_CONTEXTS.creation_date%TYPE          := SYSDATE;
  l_last_update_date   HR_KI_UI_CONTEXTS.last_update_date%TYPE       := SYSDATE;
  l_last_updated_by    HR_KI_UI_CONTEXTS.last_updated_by%TYPE         := 0;
  l_last_update_login  HR_KI_UI_CONTEXTS.last_update_login%TYPE       := 0;
  l_ui_context_id      HR_KI_UI_CONTEXTS.ui_context_id%TYPE;
  l_user_interface_id  HR_KI_USER_INTERFACES.user_interface_id%TYPE;
  l_object_version_number HR_KI_OPTION_TYPES.object_version_number%TYPE;


  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

  CURSOR C_APPL IS
    select uic.ui_context_id,uic.object_version_number
        from HR_KI_UI_CONTEXTS uic,
        hr_ki_user_interfaces uit
   where uic.user_interface_id = uit.user_interface_id
     and upper(uic.ui_context_key)=upper(x_ui_context_key)
     and upper(uit.user_interface_key)=upper(x_user_interface_key);

  begin
  --
  -- added for 5354277
     hr_general.g_data_migrator_mode := 'Y';
  --
  --validate Keys
  validate_keys(
   X_USER_INTERFACE_KEY       => x_user_interface_key
  ,X_USER_INTERFACE_ID        => l_user_interface_id
  );

  -- Translate owner to file_last_updated_by
  l_last_updated_by := fnd_load_util.owner_id(X_OWNER);
  l_created_by := fnd_load_util.owner_id(X_OWNER);

  -- Translate char last_update_date to date
  l_last_update_date := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD hh24:mi:ss'), sysdate);


  -- Update or insert row as appropriate

  OPEN C_APPL;
  FETCH C_APPL INTO l_ui_context_id,l_object_version_number;


  if C_APPL%notfound then
  close C_APPL;
      INSERT_ROW
        (
         X_ROWID                    => l_rowid
        ,X_UI_CONTEXT_ID            => l_ui_context_id
        ,X_USER_INTERFACE_ID        => l_user_interface_id
        ,X_UI_CONTEXT_KEY           => x_ui_context_key
        ,X_LABEL                    => x_label
        ,X_LOCATION                 => x_location
        ,X_CREATED_BY               => l_created_by
        ,X_CREATION_DATE            => l_creation_date
        ,X_LAST_UPDATE_DATE         => l_last_update_date
        ,X_LAST_UPDATED_BY          => l_last_updated_by
        ,X_LAST_UPDATE_LOGIN        => l_last_update_login
        );


 else
   close C_APPL;
   select LAST_UPDATED_BY, LAST_UPDATE_DATE
           into db_luby, db_ludate
           from HR_KI_UI_CONTEXTS
           where ui_context_id = l_ui_context_id;


           if (fnd_load_util.upload_test(l_last_updated_by, l_last_update_date, db_luby,
                                                 db_ludate, X_CUSTOM_MODE)) then

-- Updating label is allowed but the UI_CONTEXT_KEY will not be updated
-- by convention UI_CONTEXT_KEY should be <ui_key>::<label>

-- Ideally we should not allow to update,but chances are
-- that we need way to handle updation of label
-- Recommended way is to create new row

               UPDATE_ROW
               (
                 X_UI_CONTEXT_ID            => l_ui_context_id
                ,X_LABEL                    => X_LABEL
                ,X_LOCATION                 => X_LOCATION
                ,X_LAST_UPDATE_DATE         => l_last_update_date
                ,X_LAST_UPDATED_BY          => l_last_updated_by
                ,X_LAST_UPDATE_LOGIN        => l_last_update_login
                ,X_OBJECT_VERSION_NUMBER    => l_object_version_number
               );

           end if;

   end if;

--
end LOAD_ROW;

END HR_KI_UCX_LOAD_API;

/
