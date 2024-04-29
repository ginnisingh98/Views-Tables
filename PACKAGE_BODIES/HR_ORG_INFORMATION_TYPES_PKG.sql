--------------------------------------------------------
--  DDL for Package Body HR_ORG_INFORMATION_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORG_INFORMATION_TYPES_PKG" as
/* $Header: peoit01t.pkb 120.3 2006/05/25 08:14:28 srenukun noship $ */
--
function APPLICATION_ID (
  X_APPLICATION_SHORT_NAME in VARCHAR2
) return NUMBER is
  cursor CSR_APPLICATION (
    X_APPLICATION_SHORT_NAME in VARCHAR2
  ) is
    select APPLICATION_ID
    from   FND_APPLICATION
    where  APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME;
  X_APPLICATION CSR_APPLICATION%rowtype;
begin
  open CSR_APPLICATION(X_APPLICATION_SHORT_NAME);
  fetch CSR_APPLICATION into X_APPLICATION;
  close CSR_APPLICATION;
  return(X_APPLICATION.APPLICATION_ID);
end APPLICATION_ID;
--
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
--
procedure INSERT_ROW (
  X_ORG_INFORMATION_TYPE in VARCHAR2,
  X_DESTINATION in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_NAVIGATION_METHOD in VARCHAR2,
  X_FND_APPLICATION_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_DISPLAYED_ORG_INFORMATION_TP in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into HR_ORG_INFORMATION_TYPES (
    ORG_INFORMATION_TYPE,
    DESTINATION,
    LEGISLATION_CODE,
    NAVIGATION_METHOD,
    FND_APPLICATION_ID,
    DESCRIPTION,
    DISPLAYED_ORG_INFORMATION_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ORG_INFORMATION_TYPE,
    X_DESTINATION,
    X_LEGISLATION_CODE,
    X_NAVIGATION_METHOD,
    X_FND_APPLICATION_ID,
    X_DESCRIPTION,
    X_DISPLAYED_ORG_INFORMATION_TP,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into HR_ORG_INFORMATION_TYPES_TL (
    ORG_INFORMATION_TYPE,
    DISPLAYED_ORG_INFORMATION_TYPE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_ORG_INFORMATION_TYPE,
    X_DISPLAYED_ORG_INFORMATION_TP,
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
    from HR_ORG_INFORMATION_TYPES_TL T
    where T.ORG_INFORMATION_TYPE = X_ORG_INFORMATION_TYPE
    and T.LANGUAGE = L.LANGUAGE_CODE);

end INSERT_ROW;
--
procedure LOCK_ROW (
  X_ORG_INFORMATION_TYPE in VARCHAR2,
  X_DESTINATION in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_NAVIGATION_METHOD in VARCHAR2,
  X_FND_APPLICATION_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_DISPLAYED_ORG_INFORMATION_TP in VARCHAR2
) is
  cursor CSR_ORG_INFORMATION_TYPE (
    X_ORG_INFORMATION_TYPE in VARCHAR2
  ) is
    select DESTINATION
          ,LEGISLATION_CODE
          ,NAVIGATION_METHOD
          ,FND_APPLICATION_ID
          ,DESCRIPTION
    from   HR_ORG_INFORMATION_TYPES
    where  ORG_INFORMATION_TYPE = X_ORG_INFORMATION_TYPE
    for update of ORG_INFORMATION_TYPE nowait;
  RECINFO CSR_ORG_INFORMATION_TYPE%rowtype;

  cursor CSR_ORG_INFORMATION_TYPE_TL is
    select DISPLAYED_ORG_INFORMATION_TYPE,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from HR_ORG_INFORMATION_TYPES_TL
    where ORG_INFORMATION_TYPE = X_ORG_INFORMATION_TYPE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ORG_INFORMATION_TYPE nowait;

begin
  open CSR_ORG_INFORMATION_TYPE(X_ORG_INFORMATION_TYPE);
  fetch CSR_ORG_INFORMATION_TYPE into RECINFO;
  if (CSR_ORG_INFORMATION_TYPE%notfound) then
    close CSR_ORG_INFORMATION_TYPE;
    fnd_message.set_name('FND','FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close CSR_ORG_INFORMATION_TYPE;
  if (   (  (RECINFO.DESTINATION = X_DESTINATION)
         or (RECINFO.DESTINATION is null and X_DESTINATION is null))
     and (  (RECINFO.LEGISLATION_CODE = X_LEGISLATION_CODE)
         or (RECINFO.LEGISLATION_CODE is null and X_LEGISLATION_CODE is null))
     and (  (RECINFO.NAVIGATION_METHOD = X_NAVIGATION_METHOD)
         or (RECINFO.NAVIGATION_METHOD is null and X_NAVIGATION_METHOD is null))
     and (  (RECINFO.NAVIGATION_METHOD = X_NAVIGATION_METHOD)
         or (RECINFO.NAVIGATION_METHOD is null and X_NAVIGATION_METHOD is null))
     and (  (RECINFO.DESCRIPTION = X_DESCRIPTION)
         or (RECINFO.DESCRIPTION is null and X_DESCRIPTION is null))
     ) then
    null;
  else
    fnd_message.set_name('FND','FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in CSR_ORG_INFORMATION_TYPE_TL loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DISPLAYED_ORG_INFORMATION_TYPE = X_DISPLAYED_ORG_INFORMATION_TP)
               OR ((tlinfo.DISPLAYED_ORG_INFORMATION_TYPE is null) AND (X_DISPLAYED_ORG_INFORMATION_TP is null)))
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
--
procedure UPDATE_ROW (
  X_ORG_INFORMATION_TYPE in VARCHAR2,
  X_DESTINATION in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_NAVIGATION_METHOD in VARCHAR2,
  X_FND_APPLICATION_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_DISPLAYED_ORG_INFORMATION_TP in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update HR_ORG_INFORMATION_TYPES set
    DESTINATION = X_DESTINATION,
    LEGISLATION_CODE = X_LEGISLATION_CODE,
    NAVIGATION_METHOD = X_NAVIGATION_METHOD,
    FND_APPLICATION_ID = X_FND_APPLICATION_ID,
    DESCRIPTION = X_DESCRIPTION,
    DISPLAYED_ORG_INFORMATION_TYPE = X_DISPLAYED_ORG_INFORMATION_TP,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ORG_INFORMATION_TYPE = X_ORG_INFORMATION_TYPE;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  update HR_ORG_INFORMATION_TYPES_TL set
    DISPLAYED_ORG_INFORMATION_TYPE = X_DISPLAYED_ORG_INFORMATION_TP,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ORG_INFORMATION_TYPE = X_ORG_INFORMATION_TYPE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;
--
procedure DELETE_ROW (
  X_ORG_INFORMATION_TYPE in VARCHAR2
) is
begin
  delete from HR_ORG_INFORMATION_TYPES_TL
  where ORG_INFORMATION_TYPE = X_ORG_INFORMATION_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from HR_ORG_INFORMATION_TYPES
  where ORG_INFORMATION_TYPE = X_ORG_INFORMATION_TYPE;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
--
procedure ADD_LANGUAGE
is
begin
  delete from HR_ORG_INFORMATION_TYPES_TL T
  where not exists
    (select NULL
    from HR_ORG_INFORMATION_TYPES B
    where B.ORG_INFORMATION_TYPE = T.ORG_INFORMATION_TYPE
    );

  update HR_ORG_INFORMATION_TYPES_TL T set (
      DISPLAYED_ORG_INFORMATION_TYPE
    ) = (select
      B.DISPLAYED_ORG_INFORMATION_TYPE
    from HR_ORG_INFORMATION_TYPES_TL B
    where B.ORG_INFORMATION_TYPE = T.ORG_INFORMATION_TYPE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ORG_INFORMATION_TYPE,
      T.LANGUAGE
  ) in (select
      SUBT.ORG_INFORMATION_TYPE,
      SUBT.LANGUAGE
    from HR_ORG_INFORMATION_TYPES_TL SUBB, HR_ORG_INFORMATION_TYPES_TL SUBT
    where SUBB.ORG_INFORMATION_TYPE = SUBT.ORG_INFORMATION_TYPE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAYED_ORG_INFORMATION_TYPE <> SUBT.DISPLAYED_ORG_INFORMATION_TYPE
      or (SUBB.DISPLAYED_ORG_INFORMATION_TYPE is null and SUBT.DISPLAYED_ORG_INFORMATION_TYPE is not null)
      or (SUBB.DISPLAYED_ORG_INFORMATION_TYPE is not null and SUBT.DISPLAYED_ORG_INFORMATION_TYPE is null)
  ));

  insert into HR_ORG_INFORMATION_TYPES_TL (
    ORG_INFORMATION_TYPE,
    DISPLAYED_ORG_INFORMATION_TYPE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ORG_INFORMATION_TYPE,
    B.DISPLAYED_ORG_INFORMATION_TYPE,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from HR_ORG_INFORMATION_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from HR_ORG_INFORMATION_TYPES_TL T
    where T.ORG_INFORMATION_TYPE = B.ORG_INFORMATION_TYPE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

--
procedure LOAD_ROW (
  X_ORG_INFORMATION_TYPE in VARCHAR2,
  X_DESTINATION in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_NAVIGATION_METHOD in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DISPLAYED_ORG_INFORMATION_TP in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE IN varchar2 default sysdate,
  X_CUSTOM_MODE IN VARCHAR2 default null
) is
  X_CREATION_DATE DATE;
  X_CREATED_BY NUMBER;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  X_APPLICATION_ID NUMBER;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin
--This has been commented as LAST_UPDATE_DATE is passed as an parameter
/*OWNER_TO_WHO (
    X_OWNER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );*/

 X_APPLICATION_ID := APPLICATION_ID(X_APPLICATION_SHORT_NAME);
   -- Translate owner to file_last_updated_by
 f_luby := fnd_load_util.owner_id(X_OWNER);
   -- Translate char last_update_date to date
 f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
        select LAST_UPDATED_BY, LAST_UPDATE_DATE
        into db_luby, db_ludate
        from HR_ORG_INFORMATION_TYPES
        where ORG_INFORMATION_TYPE = X_ORG_INFORMATION_TYPE;

        -- Test for customization and version
        if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, X_CUSTOM_MODE)) then
            -- Update existing row
                   HR_ORG_INFORMATION_TYPES_PKG.Update_Row(
                                  X_ORG_INFORMATION_TYPE,
                                  X_DESTINATION,
                                  X_LEGISLATION_CODE,
                                  X_NAVIGATION_METHOD,
                                  X_APPLICATION_ID,
                                  X_DESCRIPTION,
                                  X_DISPLAYED_ORG_INFORMATION_TP,
                                  f_ludate,
                                  f_luby,
                                  0);
        END IF;
    exception
    when no_data_found then
     -- Record doesn't exist - insert in all cases
                HR_ORG_INFORMATION_TYPES_PKG.Insert_Row(
                                 X_ORG_INFORMATION_TYPE,
                                 X_DESTINATION,
                                 X_LEGISLATION_CODE,
                                 X_NAVIGATION_METHOD,
                                 X_APPLICATION_ID,
                                 X_DESCRIPTION,
                                 X_DISPLAYED_ORG_INFORMATION_TP,
                                 f_ludate,
                                 f_luby,
                                 f_ludate,
                                 f_luby,
                                 0);

end LOAD_ROW;
--
procedure TRANSLATE_ROW (
  X_ORG_INFORMATION_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DISPLAYED_ORG_INFORMATION_TP in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2 default sysdate,
  X_CUSTOM_MODE IN VARCHAR2 default null
) is
  X_CREATION_DATE DATE;
  X_CREATED_BY NUMBER;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin
--This has been commented as LAST_UPDATE_DATE is passed as an parameter
/*OWNER_TO_WHO (
    X_OWNER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );*/
   -- Translate owner to file_last_updated_by
 f_luby := fnd_load_util.owner_id(X_OWNER);
    -- Translate char last_update_date to date
 f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

-- added the check as per Bug 5092005 to make sure that only
-- the correct row is fetched instead of multiple rows

          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from HR_ORG_INFORMATION_TYPES_TL
          where ORG_INFORMATION_TYPE = X_ORG_INFORMATION_TYPE
          and LANGUAGE=userenv('LANG');

          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate,X_CUSTOM_MODE)) then
            -- Update translations for this language
            -- bug 5235538 nls date issue, changed to  LAST_UPDATE_DATE = f_ludate, LAST_UPDATED_BY = f_luby

             update HR_ORG_INFORMATION_TYPES_TL
                  set DISPLAYED_ORG_INFORMATION_TYPE = X_DISPLAYED_ORG_INFORMATION_TP
                   , LAST_UPDATE_DATE = f_ludate
                   , LAST_UPDATED_BY = f_luby
                   , LAST_UPDATE_LOGIN = 0
                   , SOURCE_LANG = userenv('LANG')
                  where ORG_INFORMATION_TYPE = X_ORG_INFORMATION_TYPE
                  and userenv('LANG') in (LANGUAGE,SOURCE_LANG);
        end if;
        exception
          when no_data_found then
            -- Do not insert missing translations, skip this row
            null;

end TRANSLATE_ROW;
--
end HR_ORG_INFORMATION_TYPES_PKG;

/
