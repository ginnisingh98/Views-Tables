--------------------------------------------------------
--  DDL for Package Body HR_KI_INT_LOAD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KI_INT_LOAD_API" as
/* $Header: hrkiintl.pkb 120.1 2006/06/27 16:03:22 avarri noship $ */
--
-- Package Variables
--
g_package  varchar2(31) := 'HR_KI_INT_LOAD_API';
--


procedure UPDATE_ROW (
  X_INTEGRATION_ID        in NUMBER
 ,X_PARTY_TYPE            in VARCHAR2
 ,X_PARTY_NAME            in VARCHAR2
 ,X_PARTY_SITE_NAME       in VARCHAR2
 ,X_TRANSACTION_TYPE      in VARCHAR2
 ,X_TRANSACTION_SUBTYPE   in VARCHAR2
 ,X_STANDARD_CODE         in VARCHAR2
 ,X_EXT_TRANS_TYPE        in VARCHAR2
 ,X_EXT_TRANS_SUBTYPE     in VARCHAR2
 ,X_TRANS_DIRECTION       in VARCHAR2
 ,X_URL                   in VARCHAR2
 ,X_SYNCHED               in VARCHAR2
 ,X_APPLICATION_NAME      in VARCHAR2
 ,X_APPLICATION_TYPE      in VARCHAR2
 ,X_APPLICATION_URL       in VARCHAR2
 ,X_LOGOUT_URL            in VARCHAR2
 ,X_USER_FIELD            in VARCHAR2
 ,X_PASSWORD_FIELD        in VARCHAR2
 ,X_AUTHENTICATION_NEEDED in VARCHAR2
 ,X_FIELD_NAME1           in VARCHAR2
 ,X_FIELD_VALUE1          in VARCHAR2
 ,X_FIELD_NAME2           in VARCHAR2
 ,X_FIELD_VALUE2          in VARCHAR2
 ,X_FIELD_NAME3           in VARCHAR2
 ,X_FIELD_VALUE3          in VARCHAR2
 ,X_FIELD_NAME4           in VARCHAR2
 ,X_FIELD_VALUE4          in VARCHAR2
 ,X_FIELD_NAME5           in VARCHAR2
 ,X_FIELD_VALUE5          in VARCHAR2
 ,X_FIELD_NAME6           in VARCHAR2
 ,X_FIELD_VALUE6          in VARCHAR2
 ,X_FIELD_NAME7           in VARCHAR2
 ,X_FIELD_VALUE7          in VARCHAR2
 ,X_FIELD_NAME8           in VARCHAR2
 ,X_FIELD_VALUE8          in VARCHAR2
 ,X_FIELD_NAME9           in VARCHAR2
 ,X_FIELD_VALUE9          in VARCHAR2
 ,X_PARTNER_NAME          in VARCHAR2
 ,X_SERVICE_NAME          in VARCHAR2
 ,X_LAST_UPDATE_DATE      in DATE
 ,X_LAST_UPDATED_BY       in NUMBER
 ,X_LAST_UPDATE_LOGIN     in NUMBER
 ,X_OBJECT_VERSION_NUMBER in NUMBER

) is

begin


   update HR_KI_INTEGRATIONS
   set
    PARTY_TYPE            = X_PARTY_TYPE
   ,PARTY_NAME            = X_PARTY_NAME
   ,PARTY_SITE_NAME       = X_PARTY_SITE_NAME
   ,TRANSACTION_TYPE      = X_TRANSACTION_TYPE
   ,TRANSACTION_SUBTYPE   = X_TRANSACTION_SUBTYPE
   ,STANDARD_CODE         = X_STANDARD_CODE
   ,EXT_TRANS_TYPE        = X_EXT_TRANS_TYPE
   ,EXT_TRANS_SUBTYPE     = X_EXT_TRANS_SUBTYPE
   ,TRANS_DIRECTION       = X_TRANS_DIRECTION
   ,URL                   = X_URL
   ,SYNCHED               = X_SYNCHED
   ,APPLICATION_NAME      = X_APPLICATION_NAME
   ,APPLICATION_TYPE      = X_APPLICATION_TYPE
   ,APPLICATION_URL       = X_APPLICATION_URL
   ,LOGOUT_URL            = X_LOGOUT_URL
   ,USER_FIELD            = X_USER_FIELD
   ,PASSWORD_FIELD        = X_PASSWORD_FIELD
   ,AUTHENTICATION_NEEDED = X_AUTHENTICATION_NEEDED
   ,FIELD_NAME1           = X_FIELD_NAME1
   ,FIELD_VALUE1          = X_FIELD_VALUE1
   ,FIELD_NAME2           = X_FIELD_NAME2
   ,FIELD_VALUE2          = X_FIELD_VALUE2
   ,FIELD_NAME3           = X_FIELD_NAME3
   ,FIELD_VALUE3          = X_FIELD_VALUE3
   ,FIELD_NAME4           = X_FIELD_NAME4
   ,FIELD_VALUE4          = X_FIELD_VALUE4
   ,FIELD_NAME5           = X_FIELD_NAME5
   ,FIELD_VALUE5          = X_FIELD_VALUE5
   ,FIELD_NAME6           = X_FIELD_NAME6
   ,FIELD_VALUE6          = X_FIELD_VALUE6
   ,FIELD_NAME7           = X_FIELD_NAME7
   ,FIELD_VALUE7          = X_FIELD_VALUE7
   ,FIELD_NAME8           = X_FIELD_NAME8
   ,FIELD_VALUE8          = X_FIELD_VALUE8
   ,FIELD_NAME9           = X_FIELD_NAME9
   ,FIELD_VALUE9          = X_FIELD_VALUE9
   ,LAST_UPDATE_DATE      = X_LAST_UPDATE_DATE
   ,LAST_UPDATED_BY       = X_LAST_UPDATED_BY
   ,LAST_UPDATE_LOGIN     = X_LAST_UPDATE_LOGIN
   ,OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER+1
  where
  INTEGRATION_ID = X_INTEGRATION_ID;

 --Update TL table
  update HR_KI_INTEGRATIONS_TL set
    PARTNER_NAME = X_PARTNER_NAME,
    SERVICE_NAME = X_SERVICE_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where INTEGRATION_ID = X_INTEGRATION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then

        insert into HR_KI_INTEGRATIONS_TL (
                        INTEGRATION_ID,
                        PARTNER_NAME,
                        SERVICE_NAME,
                        CREATED_BY,
                        CREATION_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATE_LOGIN,
                        LANGUAGE,
                        SOURCE_LANG
          ) select
                X_INTEGRATION_ID,
                X_PARTNER_NAME,
                X_SERVICE_NAME,
                1 ,
                SYSDATE,
                X_LAST_UPDATED_BY,
                X_LAST_UPDATE_DATE,
                X_LAST_UPDATE_LOGIN,
                L.LANGUAGE_CODE,
                userenv('LANG')
          from FND_LANGUAGES L
          where L.INSTALLED_FLAG in ('I', 'B')
          and not exists
            (select NULL
                    from HR_KI_INTEGRATIONS_TL T
                    where T.integration_id = X_integration_id
                    and T.LANGUAGE = L.LANGUAGE_CODE);

  end if;

end UPDATE_ROW;


procedure INSERT_ROW (
  X_ROWID                 in out nocopy  VARCHAR2
 ,X_INTEGRATION_ID        in out nocopy NUMBER
 ,X_INTEGRATION_KEY       in VARCHAR2
 ,X_PARTY_TYPE            in VARCHAR2
 ,X_PARTY_NAME            in VARCHAR2
 ,X_PARTY_SITE_NAME       in VARCHAR2
 ,X_TRANSACTION_TYPE      in VARCHAR2
 ,X_TRANSACTION_SUBTYPE   in VARCHAR2
 ,X_STANDARD_CODE         in VARCHAR2
 ,X_EXT_TRANS_TYPE        in VARCHAR2
 ,X_EXT_TRANS_SUBTYPE     in VARCHAR2
 ,X_TRANS_DIRECTION       in VARCHAR2
 ,X_URL                   in VARCHAR2
 ,X_SYNCHED               in VARCHAR2
 ,X_APPLICATION_NAME      in VARCHAR2
 ,X_APPLICATION_TYPE      in VARCHAR2
 ,X_APPLICATION_URL       in VARCHAR2
 ,X_LOGOUT_URL            in VARCHAR2
 ,X_USER_FIELD            in VARCHAR2
 ,X_PASSWORD_FIELD        in VARCHAR2
 ,X_AUTHENTICATION_NEEDED in VARCHAR2
 ,X_FIELD_NAME1           in VARCHAR2
 ,X_FIELD_VALUE1          in VARCHAR2
 ,X_FIELD_NAME2           in VARCHAR2
 ,X_FIELD_VALUE2          in VARCHAR2
 ,X_FIELD_NAME3           in VARCHAR2
 ,X_FIELD_VALUE3          in VARCHAR2
 ,X_FIELD_NAME4           in VARCHAR2
 ,X_FIELD_VALUE4          in VARCHAR2
 ,X_FIELD_NAME5           in VARCHAR2
 ,X_FIELD_VALUE5          in VARCHAR2
 ,X_FIELD_NAME6           in VARCHAR2
 ,X_FIELD_VALUE6          in VARCHAR2
 ,X_FIELD_NAME7           in VARCHAR2
 ,X_FIELD_VALUE7          in VARCHAR2
 ,X_FIELD_NAME8           in VARCHAR2
 ,X_FIELD_VALUE8          in VARCHAR2
 ,X_FIELD_NAME9           in VARCHAR2
 ,X_FIELD_VALUE9          in VARCHAR2
 ,X_PARTNER_NAME          in VARCHAR2
 ,X_SERVICE_NAME          in VARCHAR2
 ,X_CREATED_BY            in NUMBER
 ,X_CREATION_DATE         in DATE
 ,X_LAST_UPDATE_DATE      in DATE
 ,X_LAST_UPDATED_BY       in NUMBER
 ,X_LAST_UPDATE_LOGIN     in NUMBER


) is

  cursor C is select ROWID from HR_KI_INTEGRATIONS
    where integration_id = X_INTEGRATION_ID;

begin

select HR_KI_INTEGRATIONS_S.NEXTVAL into X_INTEGRATION_ID from sys.dual;

  insert into HR_KI_INTEGRATIONS (
    INTEGRATION_ID,
    INTEGRATION_KEY,
    PARTY_TYPE,
    PARTY_NAME,
    PARTY_SITE_NAME,
    TRANSACTION_TYPE,
    TRANSACTION_SUBTYPE,
    STANDARD_CODE,
    EXT_TRANS_TYPE,
    EXT_TRANS_SUBTYPE,
    TRANS_DIRECTION,
    URL,
    SYNCHED,
    APPLICATION_NAME,
    APPLICATION_TYPE,
    APPLICATION_URL,
    LOGOUT_URL,
    USER_FIELD,
    PASSWORD_FIELD,
    AUTHENTICATION_NEEDED,
    FIELD_NAME1,
    FIELD_VALUE1,
    FIELD_NAME2,
    FIELD_VALUE2,
    FIELD_NAME3,
    FIELD_VALUE3,
    FIELD_NAME4,
    FIELD_VALUE4,
    FIELD_NAME5,
    FIELD_VALUE5,
    FIELD_NAME6,
    FIELD_VALUE6,
    FIELD_NAME7,
    FIELD_VALUE7,
    FIELD_NAME8,
    FIELD_VALUE8,
    FIELD_NAME9,
    FIELD_VALUE9,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER
  ) values (
    X_INTEGRATION_ID
   ,X_INTEGRATION_KEY
   ,X_PARTY_TYPE
   ,X_PARTY_NAME
   ,X_PARTY_SITE_NAME
   ,X_TRANSACTION_TYPE
   ,X_TRANSACTION_SUBTYPE
   ,X_STANDARD_CODE
   ,X_EXT_TRANS_TYPE
   ,X_EXT_TRANS_SUBTYPE
   ,X_TRANS_DIRECTION
   ,X_URL
   ,X_SYNCHED
   ,X_APPLICATION_NAME
   ,X_APPLICATION_TYPE
   ,X_APPLICATION_URL
   ,X_LOGOUT_URL
   ,X_USER_FIELD
   ,X_PASSWORD_FIELD
   ,X_AUTHENTICATION_NEEDED
   ,X_FIELD_NAME1
   ,X_FIELD_VALUE1
   ,X_FIELD_NAME2
   ,X_FIELD_VALUE2
   ,X_FIELD_NAME3
   ,X_FIELD_VALUE3
   ,X_FIELD_NAME4
   ,X_FIELD_VALUE4
   ,X_FIELD_NAME5
   ,X_FIELD_VALUE5
   ,X_FIELD_NAME6
   ,X_FIELD_VALUE6
   ,X_FIELD_NAME7
   ,X_FIELD_VALUE7
   ,X_FIELD_NAME8
   ,X_FIELD_VALUE8
   ,X_FIELD_NAME9
   ,X_FIELD_VALUE9
   ,X_CREATION_DATE
   ,X_CREATED_BY
   ,X_LAST_UPDATE_DATE
   ,X_LAST_UPDATED_BY
   ,X_LAST_UPDATE_LOGIN
   ,1
  );


  insert into HR_KI_INTEGRATIONS_TL (
    INTEGRATION_ID,
    PARTNER_NAME,
    SERVICE_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_INTEGRATION_ID,
    X_PARTNER_NAME,
    X_SERVICE_NAME,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from HR_KI_INTEGRATIONS_TL T
    where T.integration_id = X_integration_id
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
      close c;
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE',
                                   'HR_KI_INTEGRATIONS.insert_row');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
  end if;
  close c;


end INSERT_ROW;

procedure LOAD_ROW
  (
   X_INTEGRATION_KEY       in VARCHAR2,
   X_PARTY_TYPE            in VARCHAR2,
   X_PARTY_NAME            in VARCHAR2,
   X_PARTY_SITE_NAME       in VARCHAR2,
   X_TRANSACTION_TYPE      in VARCHAR2,
   X_TRANSACTION_SUBTYPE   in VARCHAR2,
   X_STANDARD_CODE         in VARCHAR2,
   X_EXT_TRANS_TYPE        in VARCHAR2,
   X_EXT_TRANS_SUBTYPE     in VARCHAR2,
   X_TRANS_DIRECTION       in VARCHAR2,
   X_URL                   in VARCHAR2,
   X_SYNCHED               in VARCHAR2,
   X_APPLICATION_NAME      in VARCHAR2,
   X_APPLICATION_TYPE      in VARCHAR2,
   X_APPLICATION_URL       in VARCHAR2,
   X_LOGOUT_URL            in VARCHAR2,
   X_USER_FIELD            in VARCHAR2,
   X_PASSWORD_FIELD        in VARCHAR2,
   X_AUTHENTICATION_NEEDED in VARCHAR2,
   X_FIELD_NAME1           in VARCHAR2,
   X_FIELD_VALUE1          in VARCHAR2,
   X_FIELD_NAME2           in VARCHAR2,
   X_FIELD_VALUE2          in VARCHAR2,
   X_FIELD_NAME3           in VARCHAR2,
   X_FIELD_VALUE3          in VARCHAR2,
   X_FIELD_NAME4           in VARCHAR2,
   X_FIELD_VALUE4          in VARCHAR2,
   X_FIELD_NAME5           in VARCHAR2,
   X_FIELD_VALUE5          in VARCHAR2,
   X_FIELD_NAME6           in VARCHAR2,
   X_FIELD_VALUE6          in VARCHAR2,
   X_FIELD_NAME7           in VARCHAR2,
   X_FIELD_VALUE7          in VARCHAR2,
   X_FIELD_NAME8           in VARCHAR2,
   X_FIELD_VALUE8          in VARCHAR2,
   X_FIELD_NAME9           in VARCHAR2,
   X_FIELD_VALUE9          in VARCHAR2,
   X_PARTNER_NAME          in VARCHAR2,
   X_SERVICE_NAME          in VARCHAR2,
   X_LAST_UPDATE_DATE      in VARCHAR2,
   X_CUSTOM_MODE           in VARCHAR2,
   X_OWNER                 in VARCHAR2

  )
is
  l_proc               VARCHAR2(31) := 'HR_KI_INT_LOAD_API.LOAD_ROW';
  l_rowid              rowid;
  l_created_by         HR_KI_INTEGRATIONS.created_by%TYPE             := 0;
  l_creation_date      HR_KI_INTEGRATIONS.creation_date%TYPE          := SYSDATE;
  l_last_update_date   HR_KI_INTEGRATIONS.last_update_date%TYPE       := SYSDATE;
  l_last_updated_by    HR_KI_INTEGRATIONS.last_updated_by%TYPE         := 0;
  l_last_update_login  HR_KI_INTEGRATIONS.last_update_login%TYPE       := 0;
  l_integration_id       HR_KI_INTEGRATIONS.integration_id%TYPE;
  l_object_version_number HR_KI_INTEGRATIONS.object_version_number%TYPE;
  l_synched HR_KI_INTEGRATIONS.synched%TYPE;

  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db



  CURSOR C_APPL IS
        select integration_id,object_version_number
        from HR_KI_INTEGRATIONS
        where upper(integration_key) = upper(X_INTEGRATION_KEY);

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


  --Setting the synch flag
  --When we are inserting /updating data in integrations table via loaders,we will set
  --the synched flag to N for SSO and ECX type of integrations
  --For URL it will be always set to Y
  if X_URL is not null then
     l_synched := 'Y';
  else
     l_synched := 'N';
  end if;

  -- Update or insert row as appropriate

  OPEN C_APPL;
  FETCH C_APPL INTO l_integration_id,l_object_version_number;


  if C_APPL%notfound then
  close C_APPL;
      INSERT_ROW
        (
         X_ROWID                 => l_rowid
        ,X_INTEGRATION_ID        => l_integration_id
        ,X_INTEGRATION_KEY       => X_INTEGRATION_KEY
        ,X_PARTY_TYPE            => X_PARTY_TYPE
        ,X_PARTY_NAME            => X_PARTY_NAME
        ,X_PARTY_SITE_NAME       => X_PARTY_SITE_NAME
        ,X_TRANSACTION_TYPE      => X_TRANSACTION_TYPE
        ,X_TRANSACTION_SUBTYPE   => X_TRANSACTION_SUBTYPE
        ,X_STANDARD_CODE         => X_STANDARD_CODE
        ,X_EXT_TRANS_TYPE        => X_EXT_TRANS_TYPE
        ,X_EXT_TRANS_SUBTYPE     => X_EXT_TRANS_SUBTYPE
        ,X_TRANS_DIRECTION       => X_TRANS_DIRECTION
        ,X_URL                   => X_URL
        ,X_SYNCHED               => l_synched
        ,X_APPLICATION_NAME      => X_APPLICATION_NAME
        ,X_APPLICATION_TYPE      => X_APPLICATION_TYPE
        ,X_APPLICATION_URL       => X_APPLICATION_URL
        ,X_LOGOUT_URL            => X_LOGOUT_URL
        ,X_USER_FIELD            => X_USER_FIELD
        ,X_PASSWORD_FIELD        => X_PASSWORD_FIELD
        ,X_AUTHENTICATION_NEEDED => X_AUTHENTICATION_NEEDED
        ,X_FIELD_NAME1           => X_FIELD_NAME1
        ,X_FIELD_VALUE1          => X_FIELD_VALUE1
        ,X_FIELD_NAME2           => X_FIELD_NAME2
        ,X_FIELD_VALUE2          => X_FIELD_VALUE2
        ,X_FIELD_NAME3           => X_FIELD_NAME3
        ,X_FIELD_VALUE3          => X_FIELD_VALUE3
        ,X_FIELD_NAME4           => X_FIELD_NAME4
        ,X_FIELD_VALUE4          => X_FIELD_VALUE4
        ,X_FIELD_NAME5           => X_FIELD_NAME5
        ,X_FIELD_VALUE5          => X_FIELD_VALUE5
        ,X_FIELD_NAME6           => X_FIELD_NAME6
        ,X_FIELD_VALUE6          => X_FIELD_VALUE6
        ,X_FIELD_NAME7           => X_FIELD_NAME7
        ,X_FIELD_VALUE7          => X_FIELD_VALUE7
        ,X_FIELD_NAME8           => X_FIELD_NAME8
        ,X_FIELD_VALUE8          => X_FIELD_VALUE8
        ,X_FIELD_NAME9           => X_FIELD_NAME9
        ,X_FIELD_VALUE9          => X_FIELD_VALUE9
        ,X_PARTNER_NAME          => X_PARTNER_NAME
        ,X_SERVICE_NAME          => X_SERVICE_NAME
        ,X_CREATED_BY            => l_created_by
        ,X_CREATION_DATE         => l_creation_date
        ,X_LAST_UPDATE_DATE      => l_last_update_date
        ,X_LAST_UPDATED_BY       => l_last_updated_by
        ,X_LAST_UPDATE_LOGIN     => l_last_update_login
        );


  else
  close C_APPL;
  --start of update part
  select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from HR_KI_INTEGRATIONS
          where integration_id = l_integration_id;


          if (fnd_load_util.upload_test(l_last_updated_by, l_last_update_date, db_luby,
                                                db_ludate, X_CUSTOM_MODE)) then

              UPDATE_ROW
              (
               X_INTEGRATION_ID        => l_integration_id
              ,X_PARTY_TYPE            => X_PARTY_TYPE
              ,X_PARTY_NAME            => X_PARTY_NAME
              ,X_PARTY_SITE_NAME       => X_PARTY_SITE_NAME
              ,X_TRANSACTION_TYPE      => X_TRANSACTION_TYPE
              ,X_TRANSACTION_SUBTYPE   => X_TRANSACTION_SUBTYPE
              ,X_STANDARD_CODE         => X_STANDARD_CODE
              ,X_EXT_TRANS_TYPE        => X_EXT_TRANS_TYPE
              ,X_EXT_TRANS_SUBTYPE     => X_EXT_TRANS_SUBTYPE
              ,X_TRANS_DIRECTION       => X_TRANS_DIRECTION
              ,X_URL                   => X_URL
              ,X_SYNCHED               => l_synched
              ,X_APPLICATION_NAME      => X_APPLICATION_NAME
              ,X_APPLICATION_TYPE      => X_APPLICATION_TYPE
              ,X_APPLICATION_URL       => X_APPLICATION_URL
              ,X_LOGOUT_URL            => X_LOGOUT_URL
              ,X_USER_FIELD            => X_USER_FIELD
              ,X_PASSWORD_FIELD        => X_PASSWORD_FIELD
              ,X_AUTHENTICATION_NEEDED => X_AUTHENTICATION_NEEDED
              ,X_FIELD_NAME1           => X_FIELD_NAME1
              ,X_FIELD_VALUE1          => X_FIELD_VALUE1
              ,X_FIELD_NAME2           => X_FIELD_NAME2
              ,X_FIELD_VALUE2          => X_FIELD_VALUE2
              ,X_FIELD_NAME3           => X_FIELD_NAME3
              ,X_FIELD_VALUE3          => X_FIELD_VALUE3
              ,X_FIELD_NAME4           => X_FIELD_NAME4
              ,X_FIELD_VALUE4          => X_FIELD_VALUE4
              ,X_FIELD_NAME5           => X_FIELD_NAME5
              ,X_FIELD_VALUE5          => X_FIELD_VALUE5
              ,X_FIELD_NAME6           => X_FIELD_NAME6
              ,X_FIELD_VALUE6          => X_FIELD_VALUE6
              ,X_FIELD_NAME7           => X_FIELD_NAME7
              ,X_FIELD_VALUE7          => X_FIELD_VALUE7
              ,X_FIELD_NAME8           => X_FIELD_NAME8
              ,X_FIELD_VALUE8          => X_FIELD_VALUE8
              ,X_FIELD_NAME9           => X_FIELD_NAME9
              ,X_FIELD_VALUE9          => X_FIELD_VALUE9
              ,X_PARTNER_NAME          => X_PARTNER_NAME
              ,X_SERVICE_NAME          => X_SERVICE_NAME
              ,X_LAST_UPDATE_DATE      => l_last_update_date
              ,X_LAST_UPDATED_BY       => l_last_updated_by
              ,X_LAST_UPDATE_LOGIN     => l_last_update_login
              ,X_OBJECT_VERSION_NUMBER => l_object_version_number
              );

          end if;

  end if;

--
end LOAD_ROW;

procedure TRANSLATE_ROW
  (
  X_INTEGRATION_KEY  in varchar2,
  X_PARTNER_NAME     in VARCHAR2,
  X_SERVICE_NAME     in VARCHAR2,
  X_OWNER            in varchar2,
  X_CUSTOM_MODE      in varchar2,
  X_LAST_UPDATE_DATE in varchar2
  )
is
  l_integration_id     HR_KI_INTEGRATIONS.integration_id%TYPE;

  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db


begin
  --
  -- added for 5354277
     hr_general.g_data_migrator_mode := 'Y';
  --

  select integration_id into l_integration_id
  from HR_KI_INTEGRATIONS
  where upper(integration_key) = upper(X_INTEGRATION_KEY);


  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(X_OWNER);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD hh24:mi:ss'), sysdate);

  begin
          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from HR_KI_INTEGRATIONS_TL
          where
          LANGUAGE = userenv('LANG')
          and integration_id = l_integration_id;

          -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate,X_CUSTOM_MODE)) then

          UPDATE HR_KI_INTEGRATIONS_TL
          SET
            PARTNER_NAME = X_PARTNER_NAME,
            SERVICE_NAME = X_SERVICE_NAME,
            LAST_UPDATE_DATE = f_ludate ,
            LAST_UPDATED_BY = f_luby,
            LAST_UPDATE_LOGIN = 0,
            SOURCE_LANG = userenv('LANG')
            where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
               and  integration_id = l_integration_id;

         end if;
         exception
          when no_data_found then
            -- Do not insert missing translations, skip this row
            null;
  end;

end TRANSLATE_ROW;

END HR_KI_INT_LOAD_API;

/
