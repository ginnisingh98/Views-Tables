--------------------------------------------------------
--  DDL for Package Body HR_KI_TPC_LOAD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KI_TPC_LOAD_API" as
/* $Header: hrkitpcl.pkb 120.1 2006/06/27 16:08:26 avarri noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'HR_KI_TOPICS_API';
--
procedure UPDATE_ROW (
  X_TOPIC_ID in NUMBER,
  X_NAME  in VARCHAR2,
  X_HANDLER in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER

) is

begin


   update HR_KI_TOPICS set
    HANDLER = X_HANDLER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER+1
  where TOPIC_ID = X_TOPIC_ID;

  update HR_KI_TOPICS_TL set
    NAME = X_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TOPIC_ID = X_TOPIC_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then

        insert into HR_KI_TOPICS_TL (
                    TOPIC_ID,
                        NAME,
                    CREATED_BY,
                        CREATION_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATE_LOGIN,
                        LANGUAGE,
                        SOURCE_LANG
          ) select
                X_TOPIC_ID,
                X_NAME,
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
                    from HR_KI_TOPICS_TL T
                    where T.TOPIC_ID = X_TOPIC_ID
                    and T.LANGUAGE = L.LANGUAGE_CODE);

  end if;

end UPDATE_ROW;


procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TOPIC_ID in out nocopy NUMBER,
  X_TOPIC_KEY in VARCHAR2,
  X_HANDLER in VARCHAR2,
  X_NAME in varchar2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from HR_KI_TOPICS
    where topic_id = X_TOPIC_ID;

begin

  select HR_KI_TOPICS_S.NEXTVAL into X_TOPIC_ID from SYS.DUAL;

  insert into HR_KI_TOPICS (
    TOPIC_ID,
    TOPIC_KEY,
    HANDLER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER
  ) values (
    X_TOPIC_ID,
    X_TOPIC_KEY,
    X_HANDLER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    1
  );


  insert into HR_KI_TOPICS_TL (
    TOPIC_ID,
    NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TOPIC_ID,
    X_NAME,
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
    from HR_KI_TOPICS_TL T
    where T.TOPIC_ID = X_TOPIC_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
      close c;
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE',
                                   'hr_ki_topics.insert_row');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
  end if;
  close c;


end INSERT_ROW;

procedure LOAD_ROW
  (
   X_TOPIC_KEY  in VARCHAR2,
   X_HANDLER     in VARCHAR2,
   X_NAME      in VARCHAR2,
   X_OWNER   in varchar2,
   X_CUSTOM_MODE in varchar2,
   X_LAST_UPDATE_DATE in varchar2

  )
is
  l_proc               VARCHAR2(61) := 'HR_KI_TPC_LOAD_API.LOAD_ROW';
  l_rowid              rowid;
  l_created_by         HR_KI_TOPICS.created_by%TYPE             := 0;
  l_creation_date      HR_KI_TOPICS.creation_date%TYPE          := SYSDATE;
  l_last_update_date   HR_KI_TOPICS.last_update_date%TYPE       := SYSDATE;
  l_last_updated_by    HR_KI_TOPICS.last_updated_by%TYPE         := 0;
  l_last_update_login  HR_KI_TOPICS.last_update_login%TYPE       := 0;
  l_topic_id           HR_KI_TOPICS.topic_id%TYPE;
  l_object_version_number HR_KI_TOPICS.object_version_number%TYPE;

  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db


  CURSOR C_APPL IS
        select topic_id,object_version_number
        from HR_KI_TOPICS
        where upper(topic_key) = upper(X_TOPIC_KEY);

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
  FETCH C_APPL INTO l_topic_id,l_object_version_number;

  if C_APPL%notfound then
  close C_APPL;
      INSERT_ROW
        (X_ROWID                    => l_rowid
            ,X_TOPIC_ID                 => l_topic_id
            ,X_TOPIC_KEY                => X_TOPIC_KEY
        ,X_HANDLER                  => X_HANDLER
            ,X_NAME                     => X_NAME
        ,X_CREATED_BY               => l_created_by
        ,X_CREATION_DATE            => l_creation_date
        ,X_LAST_UPDATE_DATE         => l_last_update_date
        ,X_LAST_UPDATED_BY          => l_last_updated_by
        ,X_LAST_UPDATE_LOGIN        => l_last_update_login
        );
 else
  -- start update part
  close C_APPL;
  select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from HR_KI_TOPICS
          where topic_id = l_topic_id;


  if (fnd_load_util.upload_test(l_last_updated_by, l_last_update_date, db_luby,
                                        db_ludate, X_CUSTOM_MODE)) then

      UPDATE_ROW
      ( X_TOPIC_ID                 => l_topic_id
       ,X_NAME                     => X_NAME
       ,X_HANDLER                  => X_HANDLER
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
  (X_TOPIC_KEY in varchar2,
  X_NAME in VARCHAR2,
  X_OWNER in varchar2,
  X_CUSTOM_MODE in varchar2,
  X_LAST_UPDATE_DATE in varchar2
  )
is
  l_topic_id     HR_KI_TOPICS.topic_id%TYPE;

  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db


begin
  --
  -- added for 5354277
     hr_general.g_data_migrator_mode := 'Y';
  --


  select topic_id into l_topic_id
  from HR_KI_TOPICS
  where upper(topic_key) = upper(X_TOPIC_KEY);


  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(X_OWNER);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD hh24:mi:ss'), sysdate);

  begin
          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from HR_KI_TOPICS_TL
          where
          LANGUAGE = userenv('LANG')
          and topic_id = l_topic_id;

          -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate,X_CUSTOM_MODE)) then

          UPDATE HR_KI_TOPICS_TL
          SET
            NAME = X_NAME,
            LAST_UPDATE_DATE = f_ludate ,
            LAST_UPDATED_BY = f_luby,
            LAST_UPDATE_LOGIN = 0,
            SOURCE_LANG = userenv('LANG')
            where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
               and  topic_id = l_topic_id;

         end if;
         exception
          when no_data_found then
            -- Do not insert missing translations, skip this row
            null;
  end;

end TRANSLATE_ROW;
END HR_KI_TPC_LOAD_API;

/
