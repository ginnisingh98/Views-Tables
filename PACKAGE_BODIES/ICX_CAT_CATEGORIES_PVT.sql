--------------------------------------------------------
--  DDL for Package Body ICX_CAT_CATEGORIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_CATEGORIES_PVT" AS
/* $Header: ICXVCATB.pls 120.0 2005/10/20 06:48:08 srmani noship $ */

procedure INSERT_ROW (
  X_RT_CATEGORY_ID in NUMBER,
  X_CATEGORY_NAME in VARCHAR2,
  X_UPPER_CATEGORY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TYPE in NUMBER,
  X_KEY in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_ITEM_COUNT in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE
) is
  cursor C is select ROWID from ICX_CAT_CATEGORIES_TL
    where RT_CATEGORY_ID = X_RT_CATEGORY_ID
    and LANGUAGE = userenv('LANG');
   X_ROWID   VARCHAR2(64);
begin
  insert into ICX_CAT_CATEGORIES_TL (
    RT_CATEGORY_ID,
    CATEGORY_NAME,
    UPPER_CATEGORY_NAME,
    DESCRIPTION,
    TYPE,
    KEY,
    UPPER_KEY,
    TITLE,
    ITEM_COUNT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_RT_CATEGORY_ID,
    X_CATEGORY_NAME,
    upper(X_CATEGORY_NAME),
    X_DESCRIPTION,
    X_TYPE,
    X_KEY,
    upper(X_KEY),
    X_TITLE,
    X_ITEM_COUNT,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_ID,
    X_PROGRAM_UPDATE_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from ICX_CAT_CATEGORIES_TL T
    where T.RT_CATEGORY_ID = X_RT_CATEGORY_ID
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
  X_RT_CATEGORY_ID in NUMBER,
  X_CATEGORY_NAME in VARCHAR2,
  X_UPPER_CATEGORY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TYPE in NUMBER,
  X_KEY in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_ITEM_COUNT in NUMBER
) is
  cursor c1 is select
      RT_CATEGORY_ID,
      CATEGORY_NAME,
      UPPER_CATEGORY_NAME,
      DESCRIPTION,
      TYPE,
      KEY,
      TITLE,
      ITEM_COUNT,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ICX_CAT_CATEGORIES_TL
    where RT_CATEGORY_ID = X_RT_CATEGORY_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of RT_CATEGORY_ID nowait;
begin
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.CATEGORY_NAME = X_CATEGORY_NAME)
          AND (tlinfo.UPPER_CATEGORY_NAME = X_UPPER_CATEGORY_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
          AND (tlinfo.TYPE = X_TYPE)
          AND (tlinfo.KEY = X_KEY)
          AND ((tlinfo.TITLE = X_TITLE)
               OR ((tlinfo.TITLE is null) AND (X_TITLE is null)))
          AND ((tlinfo.ITEM_COUNT = X_ITEM_COUNT)
               OR ((tlinfo.ITEM_COUNT is null) AND (X_ITEM_COUNT is null)))
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
  X_RT_CATEGORY_ID in NUMBER,
  X_CATEGORY_NAME in VARCHAR2,
  X_UPPER_CATEGORY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TYPE in NUMBER,
  X_KEY in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_ITEM_COUNT in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE
) is
begin
  update ICX_CAT_CATEGORIES_TL set
    CATEGORY_NAME = X_CATEGORY_NAME,
    UPPER_CATEGORY_NAME = upper(X_CATEGORY_NAME),
    DESCRIPTION = X_DESCRIPTION,
    TYPE = X_TYPE,
    KEY = X_KEY,
    UPPER_KEY = upper(X_KEY),
    TITLE = X_TITLE,
    ITEM_COUNT = X_ITEM_COUNT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
    SOURCE_LANG = userenv('LANG')
  where RT_CATEGORY_ID = X_RT_CATEGORY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_RT_CATEGORY_ID in NUMBER
) is
begin
  delete from ICX_CAT_CATEGORIES_TL
  where RT_CATEGORY_ID = X_RT_CATEGORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


PROCEDURE TRANSLATE_ROW
     (X_RT_CATEGORY_ID       IN VARCHAR2,
      X_OWNER                IN VARCHAR2,
      X_CATEGORY_NAME        IN VARCHAR2,
      X_UPPER_CATEGORY_NAME  IN VARCHAR2,
      X_DESCRIPTION          IN VARCHAR2,
      X_CUSTOM_MODE          IN VARCHAR2,
      X_LAST_UPDATE_DATE     IN VARCHAR2)
IS
BEGIN
  DECLARE
     F_LUBY     NUMBER; -- entity owner in file
     F_LUDATE   DATE; -- entity update in file
     DB_LUBY    NUMBER; -- entity owner in db
     DB_LUDATE  DATE; -- entity update in db

  BEGIN
  -- Translate owner to file_last_updated_by
    F_LUBY := FND_LOAD_UTIL.OWNER_ID(X_OWNER);
    F_LUDATE := NVL(TO_DATE(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), SYSDATE);

    SELECT LAST_UPDATED_BY,
           LAST_UPDATE_DATE
    INTO   DB_LUBY,
           DB_LUDATE
    FROM   ICX_CAT_CATEGORIES_TL
    WHERE  LANGUAGE = USERENV('LANG')
           AND RT_CATEGORY_ID = TO_NUMBER(X_RT_CATEGORY_ID); -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date

    IF (FND_LOAD_UTIL.UPLOAD_TEST(P_FILE_ID => F_LUBY,
                                  P_FILE_LUD => F_LUDATE,
                                  P_DB_ID => DB_LUBY,
                                  P_DB_LUD => DB_LUDATE,
                                  P_CUSTOM_MODE => X_CUSTOM_MODE)) THEN
      UPDATE ICX_CAT_CATEGORIES_TL
      SET    CATEGORY_NAME = X_CATEGORY_NAME,
             UPPER_CATEGORY_NAME = UPPER(X_CATEGORY_NAME),
             DESCRIPTION = X_DESCRIPTION,
             LAST_UPDATE_DATE = SYSDATE,
             LAST_UPDATED_BY = F_LUBY,
             LAST_UPDATE_LOGIN = 0,
             SOURCE_LANG = USERENV('LANG')
      WHERE  RT_CATEGORY_ID = TO_NUMBER(X_RT_CATEGORY_ID)
             AND USERENV('LANG') IN (LANGUAGE,
                                     SOURCE_LANG);
    END IF;
  END;
END TRANSLATE_ROW;


PROCEDURE LOAD_ROW
     (X_RT_CATEGORY_ID       IN VARCHAR2,
      X_OWNER                IN VARCHAR2,
      X_CATEGORY_NAME        IN VARCHAR2,
      X_UPPER_CATEGORY_NAME  IN VARCHAR2,
      X_DESCRIPTION          IN VARCHAR2,
      X_TYPE                 IN VARCHAR2,
      X_KEY                  IN VARCHAR2,
      X_TITLE                IN VARCHAR2,
      X_ITEM_COUNT           IN VARCHAR2,
      X_CUSTOM_MODE          IN VARCHAR2,
      X_LAST_UPDATE_DATE     IN VARCHAR2)
IS
BEGIN
  DECLARE
    ROW_ID     VARCHAR2(64);
     F_LUBY     NUMBER; -- entity owner in file
     F_LUDATE   DATE; -- entity update in file
     DB_LUBY    NUMBER; -- entity owner in db
     DB_LUDATE  DATE; -- entity update in db
  BEGIN
  -- Translate owner to file_last_updated_by
    F_LUBY := FND_LOAD_UTIL.OWNER_ID(X_OWNER);

    F_LUDATE := NVL(TO_DATE(X_LAST_UPDATE_DATE,
                            'YYYY/MM/DD'),
                    SYSDATE);

    SELECT LAST_UPDATED_BY,
           LAST_UPDATE_DATE
    INTO   DB_LUBY,
           DB_LUDATE
    FROM   ICX_CAT_CATEGORIES_TL
    WHERE  LANGUAGE = USERENV('LANG')
           AND RT_CATEGORY_ID = TO_NUMBER(X_RT_CATEGORY_ID); -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date

    IF (FND_LOAD_UTIL.UPLOAD_TEST(P_FILE_ID => F_LUBY,
                                  P_FILE_LUD => F_LUDATE,
                                  P_DB_ID => DB_LUBY,
                                  P_DB_LUD => DB_LUDATE,
                                  P_CUSTOM_MODE => X_CUSTOM_MODE)) THEN
      ICX_CAT_CATEGORIES_PVT.UPDATE_ROW(X_RT_CATEGORY_ID => TO_NUMBER(X_RT_CATEGORY_ID),
                                        X_CATEGORY_NAME => X_CATEGORY_NAME,
                                        X_UPPER_CATEGORY_NAME => X_UPPER_CATEGORY_NAME,
                                        X_DESCRIPTION => X_DESCRIPTION,
                                        X_TYPE => TO_NUMBER(X_TYPE),
                                        X_KEY => X_KEY,
                                        X_TITLE => X_TITLE,
                                        X_ITEM_COUNT => TO_NUMBER(X_ITEM_COUNT),
                                        X_LAST_UPDATE_DATE => SYSDATE,
                                        X_LAST_UPDATED_BY => F_LUBY,
                                        X_LAST_UPDATE_LOGIN => 0,
                                        X_REQUEST_ID => NULL,
                                        X_PROGRAM_APPLICATION_ID => NULL,
                                        X_PROGRAM_ID => NULL,
                                        X_PROGRAM_UPDATE_DATE => NULL);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND  THEN
      ICX_CAT_CATEGORIES_PVT.INSERT_ROW(X_RT_CATEGORY_ID => TO_NUMBER(X_RT_CATEGORY_ID),
                                        X_CATEGORY_NAME => X_CATEGORY_NAME,
                                        X_UPPER_CATEGORY_NAME => X_UPPER_CATEGORY_NAME,
                                        X_DESCRIPTION => X_DESCRIPTION,
                                        X_TYPE => TO_NUMBER(X_TYPE),
                                        X_KEY => X_KEY,
                                        X_TITLE => X_TITLE,
                                        X_ITEM_COUNT => TO_NUMBER(X_ITEM_COUNT),
                                        X_CREATION_DATE => SYSDATE,
                                        X_CREATED_BY => F_LUBY,
                                        X_LAST_UPDATE_DATE => SYSDATE,
                                        X_LAST_UPDATED_BY => F_LUBY,
                                        X_LAST_UPDATE_LOGIN => 0,
                                        X_REQUEST_ID => NULL,
                                        X_PROGRAM_APPLICATION_ID => NULL,
                                        X_PROGRAM_ID => NULL,
                                        X_PROGRAM_UPDATE_DATE => NULL);
  END;
END LOAD_ROW;




procedure ADD_LANGUAGE
is
begin
  insert into ICX_CAT_CATEGORIES_TL (
    RT_CATEGORY_ID,
    CATEGORY_NAME,
    UPPER_CATEGORY_NAME,
    DESCRIPTION,
    TYPE,
    KEY,
    UPPER_KEY,
    TITLE,
    ITEM_COUNT,
    SECTION_MAP,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.RT_CATEGORY_ID,
    B.CATEGORY_NAME,
    upper(B.CATEGORY_NAME),
    B.DESCRIPTION,
    B.TYPE,
    B.KEY,
    upper(B.KEY),
    B.TITLE,
    B.ITEM_COUNT,
    B.SECTION_MAP,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.REQUEST_ID,
    B.PROGRAM_APPLICATION_ID,
    B.PROGRAM_ID,
    B.PROGRAM_UPDATE_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ICX_CAT_CATEGORIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ICX_CAT_CATEGORIES_TL T
    where T.RT_CATEGORY_ID = B.RT_CATEGORY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;


end ICX_CAT_CATEGORIES_PVT;

/
