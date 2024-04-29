--------------------------------------------------------
--  DDL for Package Body HR_KI_HRC_LOAD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KI_HRC_LOAD_API" as
/* $Header: hrkihrcl.pkb 120.1 2006/06/27 16:03:09 avarri noship $ */
--
-- Package Variables
--
g_package  varchar2(31) := 'HR_KI_HRC_LOAD_API';
--


procedure UPDATE_ROW (
  X_HIERARCHY_ID in NUMBER,
  X_PARENT_HIERARCHY_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER

) is

begin


   update HR_KI_HIERARCHIES
   set
   PARENT_HIERARCHY_ID = X_PARENT_HIERARCHY_ID,
   LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
   LAST_UPDATED_BY = X_LAST_UPDATED_BY,
   LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
   OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER+1
  where HIERARCHY_ID = X_HIERARCHY_ID;


  update HR_KI_HIERARCHIES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where HIERARCHY_ID = X_HIERARCHY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then

        insert into HR_KI_HIERARCHIES_TL (
                        HIERARCHY_ID,
                        NAME,
                        DESCRIPTION,
                        CREATED_BY,
                        CREATION_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATE_LOGIN,
                        LANGUAGE,
                        SOURCE_LANG
          ) select
                X_HIERARCHY_ID,
                X_NAME,
                X_DESCRIPTION,
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
                    from HR_KI_HIERARCHIES_TL T
                    where T.hierarchy_id = X_hierarchy_id
                    and T.LANGUAGE = L.LANGUAGE_CODE);

  end if;

end UPDATE_ROW;


procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_HIERARCHY_ID in out nocopy NUMBER,
  X_HIERARCHY_KEY in VARCHAR2,
  X_PARENT_HIERARCHY_ID in NUMBER,
  X_NAME in varchar2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER

) is

  cursor C is select ROWID from HR_KI_HIERARCHIES
    where hierarchy_id = X_HIERARCHY_ID;

begin

select HR_KI_HIERARCHIES_S.NEXTVAL into X_HIERARCHY_ID from sys.dual;

  insert into HR_KI_HIERARCHIES (
    HIERARCHY_ID,
    HIERARCHY_KEY,
    PARENT_HIERARCHY_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER
  ) values (
    X_HIERARCHY_ID,
    X_HIERARCHY_KEY,
    X_PARENT_HIERARCHY_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    1
  );


  insert into HR_KI_HIERARCHIES_TL (
    HIERARCHY_ID,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_HIERARCHY_ID,
    X_NAME,
    X_DESCRIPTION,
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
    from HR_KI_HIERARCHIES_TL T
    where T.hierarchy_id = X_hierarchy_id
    and T.LANGUAGE = L.LANGUAGE_CODE);

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

procedure validate_parent_key
(
X_PARENT_HIERARCHY_KEY in VARCHAR2,
X_PARENT_HIERARCHY_ID  in out nocopy number
)
is

  l_proc               VARCHAR2(61) := 'HR_KI_HRC_LOAD_API.VALIDATE_PARENT_KEY';
  l_hierarchy_id       HR_KI_HIERARCHIES.hierarchy_id%TYPE;

  CURSOR C_VAL IS
        select hierarchy_id
        from HR_KI_HIERARCHIES
        where upper(hierarchy_key) = upper(X_PARENT_HIERARCHY_KEY);

begin

  --For Global hierarchy_node parent_hierarchy_key will be null
  --Hence at the time of downloading,we will be
  --selecting fnd_load_util.null_value for Global Node,Here we need
  --to ignore validation for this value

    if (X_PARENT_HIERARCHY_KEY <> substrb(fnd_load_util.null_value,1,30) ) then
       open C_VAL;
       fetch C_VAL into X_PARENT_HIERARCHY_ID;

       If C_VAL%NOTFOUND then
         close C_VAL;
         fnd_message.set_name( 'PER','PER_449916_HRC_PARNT_ID_ABSNT');
       fnd_message.raise_error;
       End If;

       close C_VAL;
    end if;


end validate_parent_key;

procedure LOAD_ROW
  (
   X_HIERARCHY_KEY        in VARCHAR2,
   X_PARENT_HIERARCHY_KEY in VARCHAR2,
   X_NAME                 in VARCHAR2,
   X_DESCRIPTION          in VARCHAR2,
   X_LAST_UPDATE_DATE     in VARCHAR2,
   X_CUSTOM_MODE          in VARCHAR2,
   X_OWNER                in VARCHAR2

  )
is
  l_proc               VARCHAR2(31) := 'HR_KI_HRC_LOAD_API.LOAD_ROW';
  l_rowid              rowid;
  l_created_by         HR_KI_HIERARCHIES.created_by%TYPE             := 0;
  l_creation_date      HR_KI_HIERARCHIES.creation_date%TYPE          := SYSDATE;
  l_last_update_date   HR_KI_HIERARCHIES.last_update_date%TYPE       := SYSDATE;
  l_last_updated_by    HR_KI_HIERARCHIES.last_updated_by%TYPE         := 0;
  l_last_update_login  HR_KI_HIERARCHIES.last_update_login%TYPE       := 0;
  l_hierarchy_id       HR_KI_HIERARCHIES.hierarchy_id%TYPE;
  l_parent_hierarchy_id HR_KI_HIERARCHIES.parent_hierarchy_id%TYPE;
  l_object_version_number HR_KI_HIERARCHIES.object_version_number%TYPE;

  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db



  CURSOR C_APPL IS
        select hierarchy_id,object_version_number
        from HR_KI_HIERARCHIES
        where upper(hierarchy_key) = upper(X_HIERARCHY_KEY);

  begin
  --
  -- added for 5354277
     hr_general.g_data_migrator_mode := 'Y';
  --
  --validate parent_hierarchy_key
  validate_parent_key(
   X_PARENT_HIERARCHY_KEY  => X_PARENT_HIERARCHY_KEY
  ,X_PARENT_HIERARCHY_ID   => l_parent_hierarchy_id
  );

  -- Translate owner to file_last_updated_by
  l_last_updated_by := fnd_load_util.owner_id(X_OWNER);
  l_created_by := fnd_load_util.owner_id(X_OWNER);

  -- Translate char last_update_date to date
  l_last_update_date := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD hh24:mi:ss'), sysdate);


  -- Update or insert row as appropriate

  OPEN C_APPL;
  FETCH C_APPL INTO l_hierarchy_id,l_object_version_number;


  if C_APPL%notfound then
  close C_APPL;
      INSERT_ROW
        (
         X_ROWID                    => l_rowid
        ,X_HIERARCHY_ID             => l_hierarchy_id
        ,X_HIERARCHY_KEY            => X_HIERARCHY_KEY
        ,X_PARENT_HIERARCHY_ID      => l_parent_hierarchy_id
        ,X_NAME                     => X_NAME
        ,X_DESCRIPTION              => X_DESCRIPTION
        ,X_CREATED_BY               => l_created_by
        ,X_CREATION_DATE            => l_creation_date
        ,X_LAST_UPDATE_DATE         => l_last_update_date
        ,X_LAST_UPDATED_BY          => l_last_updated_by
        ,X_LAST_UPDATE_LOGIN        => l_last_update_login
        );


  else
  close C_APPL;
  --start of update part
  select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from HR_KI_HIERARCHIES
          where hierarchy_id = l_hierarchy_id;


          if (fnd_load_util.upload_test(l_last_updated_by, l_last_update_date, db_luby,
                                                db_ludate, X_CUSTOM_MODE)) then

              UPDATE_ROW
              (
                X_HIERARCHY_ID             => l_hierarchy_id
               ,X_PARENT_HIERARCHY_ID      => l_parent_hierarchy_id
               ,X_NAME                     => X_NAME
               ,X_DESCRIPTION              => X_DESCRIPTION
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
  (
  X_HIERARCHY_KEY in varchar2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in varchar2,
  X_CUSTOM_MODE in varchar2,
  X_LAST_UPDATE_DATE in varchar2
  )
is
  l_hierarchy_id     HR_KI_HIERARCHIES.hierarchy_id%TYPE;

  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db


begin
  --
  -- added for 5354277
     hr_general.g_data_migrator_mode := 'Y';
  --
  select hierarchy_id into l_hierarchy_id
  from HR_KI_HIERARCHIES
  where upper(hierarchy_key) = upper(X_HIERARCHY_KEY);


  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(X_OWNER);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD hh24:mi:ss'), sysdate);

  begin
          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from HR_KI_HIERARCHIES_TL
          where
          LANGUAGE = userenv('LANG')
          and hierarchy_id = l_hierarchy_id;

          -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate,X_CUSTOM_MODE)) then

          UPDATE HR_KI_HIERARCHIES_TL
          SET
            NAME = X_NAME,
            DESCRIPTION = X_DESCRIPTION,
            LAST_UPDATE_DATE = f_ludate ,
            LAST_UPDATED_BY = f_luby,
            LAST_UPDATE_LOGIN = 0,
            SOURCE_LANG = userenv('LANG')
            where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
               and  hierarchy_id = l_hierarchy_id;

         end if;
         exception
          when no_data_found then
            -- Do not insert missing translations, skip this row
            null;
  end;

end TRANSLATE_ROW;

END HR_KI_HRC_LOAD_API;

/
