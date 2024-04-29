--------------------------------------------------------
--  DDL for Package Body HR_KI_OTY_LOAD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KI_OTY_LOAD_API" as
/* $Header: hrkiotyl.pkb 120.1 2006/06/27 16:06:30 avarri noship $ */
--
-- Package Variables
--
g_package  varchar2(31) := 'HR_KI_OTY_LOAD_API';
--


procedure UPDATE_ROW (
  X_OPTION_TYPE_ID in NUMBER,
  X_DISPLAY_TYPE in VARCHAR2,
  X_OPTION_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER

) is

begin


   update HR_KI_OPTION_TYPES
   set
   DISPLAY_TYPE = X_DISPLAY_TYPE,
   LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
   LAST_UPDATED_BY = X_LAST_UPDATED_BY,
   LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
   OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER+1
  where OPTION_TYPE_ID = X_OPTION_TYPE_ID;


  update HR_KI_OPTION_TYPES_TL set
    OPTION_NAME = X_OPTION_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where OPTION_TYPE_ID = X_OPTION_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then

        insert into HR_KI_OPTION_TYPES_TL (
                        OPTION_TYPE_ID,
                        OPTION_NAME,
                        CREATED_BY,
                        CREATION_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATE_LOGIN,
                        LANGUAGE,
                        SOURCE_LANG
          ) select
                X_OPTION_TYPE_ID,
                X_OPTION_NAME,
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
                    from HR_KI_OPTION_TYPES_TL T
                    where T.OPTION_TYPE_ID = X_OPTION_TYPE_ID
                    and T.LANGUAGE = L.LANGUAGE_CODE);

  end if;

end UPDATE_ROW;


procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_OPTION_TYPE_ID in out nocopy NUMBER,
  X_OPTION_TYPE_KEY in VARCHAR2,
  X_DISPLAY_TYPE in VARCHAR2,
  X_OPTION_NAME in varchar2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is

  cursor C is select ROWID from HR_KI_OPTION_TYPES
    where option_type_id = X_OPTION_TYPE_ID;

begin

select HR_KI_OPTION_TYPES_S.NEXTVAL into X_OPTION_TYPE_ID from sys.dual;

  insert into HR_KI_OPTION_TYPES (
    OPTION_TYPE_ID,
    OPTION_TYPE_KEY,
    DISPLAY_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER
  ) values (
    X_OPTION_TYPE_ID,
    X_OPTION_TYPE_KEY,
    X_DISPLAY_TYPE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    1
  );


  insert into HR_KI_OPTION_TYPES_TL (
    OPTION_TYPE_ID,
    OPTION_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_OPTION_TYPE_ID,
    X_OPTION_NAME,
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
    from HR_KI_OPTION_TYPES_TL T
    where T.OPTION_TYPE_ID = X_OPTION_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
      close c;
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE',
                                   'hr_ki_option_types.insert_row');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
  end if;
  close c;


end INSERT_ROW;

procedure LOAD_ROW
  (
   X_OPTION_TYPE_KEY  in VARCHAR2,
   X_DISPLAY_TYPE     in VARCHAR2,
   X_OPTION_NAME      in VARCHAR2,
   X_OWNER   in varchar2,
   X_CUSTOM_MODE in varchar2,
   X_LAST_UPDATE_DATE in varchar2

  )
is
  l_proc               VARCHAR2(31) := 'HR_KI_OTY_LOAD_API.LOAD_ROW';
  l_rowid              rowid;
  l_created_by         HR_KI_OPTION_TYPES.created_by%TYPE             := 0;
  l_creation_date      HR_KI_OPTION_TYPES.creation_date%TYPE          := SYSDATE;
  l_last_update_date   HR_KI_OPTION_TYPES.last_update_date%TYPE       := SYSDATE;
  l_last_updated_by    HR_KI_OPTION_TYPES.last_updated_by%TYPE         := 0;
  l_last_update_login  HR_KI_OPTION_TYPES.last_update_login%TYPE       := 0;
  l_option_type_id     HR_KI_OPTION_TYPES.option_type_id%TYPE;
  l_object_version_number HR_KI_OPTION_TYPES.object_version_number%TYPE;

  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db


  CURSOR C_APPL IS
        select option_type_id,object_version_number
        from HR_KI_OPTION_TYPES
        where upper(option_type_key) = upper(X_OPTION_TYPE_KEY);

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

  OPEN C_APPL;
  FETCH C_APPL INTO l_option_type_id,l_object_version_number;


  if C_APPL%notfound then
  close C_APPL;
      INSERT_ROW
        (X_ROWID                    => l_rowid
        ,X_OPTION_TYPE_ID           => l_option_type_id
        ,X_OPTION_TYPE_KEY          => X_OPTION_TYPE_KEY
        ,X_DISPLAY_TYPE             => X_DISPLAY_TYPE
        ,X_OPTION_NAME              => X_OPTION_NAME
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
          from HR_KI_OPTION_TYPES
          where option_type_id = l_option_type_id;


          if (fnd_load_util.upload_test(l_last_updated_by, l_last_update_date, db_luby,
                                                db_ludate, X_CUSTOM_MODE)) then

              UPDATE_ROW
              (        X_OPTION_TYPE_ID           => l_option_type_id
               ,X_OPTION_NAME              => X_OPTION_NAME
               ,X_DISPLAY_TYPE             => X_DISPLAY_TYPE
               ,X_LAST_UPDATE_DATE         => l_last_update_date
               ,X_LAST_UPDATED_BY          => l_last_updated_by
               ,X_LAST_UPDATE_LOGIN        => l_last_update_login
               ,X_OBJECT_VERSION_NUMBER    => l_object_version_number
              );

          end if;

  end if;

--
end LOAD_ROW;

procedure TRANSLATE_ROW
  (X_OPTION_TYPE_KEY in varchar2,
  X_OPTION_NAME in VARCHAR2,
  X_OWNER in varchar2,
  X_CUSTOM_MODE in varchar2,
  X_LAST_UPDATE_DATE in varchar2
  )
is
  l_option_type_id     HR_KI_OPTION_TYPES.option_type_id%TYPE;

  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db


begin
  --
  -- added for 5354277
     hr_general.g_data_migrator_mode := 'Y';
  --

  select option_type_id into l_option_type_id
  from HR_KI_OPTION_TYPES
  where upper(option_type_key) = upper(X_OPTION_TYPE_KEY);


  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(X_OWNER);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD hh24:mi:ss'), sysdate);

  begin
          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from HR_KI_OPTION_TYPES_TL
          where
          LANGUAGE = userenv('LANG')
          and option_type_id = l_option_type_id;

          -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate,X_CUSTOM_MODE)) then

          UPDATE HR_KI_OPTION_TYPES_TL
          SET
            OPTION_NAME = X_OPTION_NAME,
            LAST_UPDATE_DATE = f_ludate ,
            LAST_UPDATED_BY = f_luby,
            LAST_UPDATE_LOGIN = 0,
            SOURCE_LANG = userenv('LANG')
            where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
               and  option_type_id = l_option_type_id;

         end if;
         exception
          when no_data_found then
            -- Do not insert missing translations, skip this row
            null;
  end;

end TRANSLATE_ROW;

END HR_KI_OTY_LOAD_API;

/
