--------------------------------------------------------
--  DDL for Package Body JTF_AMV_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_AMV_ITEMS_PKG" as
/* $Header: jtfvitmb.pls 120.4 2006/01/16 01:42:50 vimohan ship $ */
procedure Load_Row(
  X_ITEM_ID in VARCHAR2,
  x_object_version_number in varchar2,
  X_STATUS_CODE in VARCHAR2,
  X_EFFECTIVE_START_DATE in VARCHAR2,
  X_EXPIRATION_DATE in VARCHAR2,
  X_APPLICATION_ID in VARCHAR2,
  X_EXTERNAL_ACCESS_FLAG in VARCHAR2,
  X_PRIORITY in VARCHAR2,
  X_PUBLICATION_DATE in VARCHAR2,
  X_LANGUAGE_CODE in VARCHAR2,
  X_ITEM_TYPE in VARCHAR2,
  X_URL_STRING in VARCHAR2,
  X_CONTENT_TYPE_ID in VARCHAR2,
  X_OWNER_ID in VARCHAR2,
  X_DEFAULT_APPROVER_ID in VARCHAR2,
  X_ITEM_DESTINATION_TYPE in VARCHAR2,
  X_ACCESS_NAME in VARCHAR2,
  X_DELIVERABLE_TYPE_CODE in VARCHAR2,
  X_APPLICABLE_TO_CODE in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ITEM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TEXT_STRING in VARCHAR2,
  X_OWNER  in  VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2 DEFAULT NULL,
  X_LAST_UPDATE_DATE in VARCHAR2 DEFAULT NULL
) AS
l_user_id number :=  fnd_load_util.owner_id(x_owner);
L_ITEM_ID NUMBER;
L_OBJECT_VERSION_NUMBER NUMBER;
L_APPLICATION_ID NUMBER;
L_EFFECTIVE_START_DATE DATE;
L_EXPIRATION_DATE DATE;
L_PUBLICATION_DATE DATE;
L_CONTENT_TYPE_ID NUMBER;
L_OWNER_ID NUMBER;
L_DEFAULT_APPROVER_ID NUMBER;
l_row_id VARCHAR2(2000);

f_luby    number;  -- entity owner in file
f_ludate  date;    -- entity update date in file
db_luby   number;  -- entity owner in db
db_ludate date;    -- entity update date in db



BEGIN

     --if (X_OWNER = 'SEED') then
      --    l_user_id := 1;
     --end if;
     L_ITEM_ID := to_number(X_ITEM_ID);
     L_OBJECT_VERSION_NUMBER := to_number(X_OBJECT_VERSION_NUMBER);
     L_APPLICATION_ID := to_number(X_APPLICATION_ID);
     L_EFFECTIVE_START_DATE := TO_DATE(X_EFFECTIVE_START_DATE, 'DD-MM-YYYY');
     L_EXPIRATION_DATE := TO_DATE(X_EXPIRATION_DATE, 'DD-MM-YYYY');
     L_PUBLICATION_DATE := TO_DATE(X_PUBLICATION_DATE, 'DD-MM-YYYY');
     L_CONTENT_TYPE_ID := to_number(X_CONTENT_TYPE_ID);
     L_OWNER_ID := to_number(X_OWNER_ID);
     L_DEFAULT_APPROVER_ID := to_number(X_DEFAULT_APPROVER_ID);

  -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

    -- This select stmnt also checks if
    -- there is a row for this app_id and this app_short_name
    -- Exception is thrown otherwise.

    select LAST_UPDATED_BY, LAST_UPDATE_DATE
      into db_luby, db_ludate
      FROM JTF_AMV_ITEMS_B
     where ITEM_ID = X_ITEM_ID;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then

     UPDATE_ROW (
            X_ITEM_ID => l_ITEM_ID,
            X_OBJECT_VERSION_NUMBER => l_OBJECT_VERSION_NUMBER,
            X_LAST_UPDATE_DATE => f_ludate,
            X_LAST_UPDATED_BY => f_luby,
            X_LAST_UPDATE_LOGIN => l_user_id,
            X_APPLICATION_ID => l_APPLICATION_ID,
            X_EXTERNAL_ACCESS_FLAG => X_EXTERNAL_ACCESS_FLAG,
            X_ITEM_NAME => X_ITEM_NAME,
            X_DESCRIPTION => X_DESCRIPTION,
            X_TEXT_STRING => X_TEXT_STRING,
            X_LANGUAGE_CODE => X_LANGUAGE_CODE,
            X_STATUS_CODE => X_STATUS_CODE,
            X_EFFECTIVE_START_DATE => l_EFFECTIVE_START_DATE,
            X_EXPIRATION_DATE => l_EXPIRATION_DATE,
            X_ITEM_TYPE => X_ITEM_TYPE,
            X_URL_STRING => X_URL_STRING,
            X_PUBLICATION_DATE => l_PUBLICATION_DATE,
            X_PRIORITY => X_PRIORITY,
            X_CONTENT_TYPE_ID => l_CONTENT_TYPE_ID,
            X_OWNER_ID => l_OWNER_ID,
            X_DEFAULT_APPROVER_ID => l_DEFAULT_APPROVER_ID,
            X_ITEM_DESTINATION_TYPE => X_ITEM_DESTINATION_TYPE,
            X_ACCESS_NAME => X_ACCESS_NAME,
            X_DELIVERABLE_TYPE_CODE => X_DELIVERABLE_TYPE_CODE,
            X_APPLICABLE_TO_CODE => X_APPLICABLE_TO_CODE,
            X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY,
            X_ATTRIBUTE1 => X_ATTRIBUTE1,
            X_ATTRIBUTE2 => X_ATTRIBUTE2,
            X_ATTRIBUTE3 => X_ATTRIBUTE3,
            X_ATTRIBUTE4 => X_ATTRIBUTE4,
            X_ATTRIBUTE5 => X_ATTRIBUTE5,
            X_ATTRIBUTE6 => X_ATTRIBUTE6,
            X_ATTRIBUTE7 => X_ATTRIBUTE7,
            X_ATTRIBUTE8 => X_ATTRIBUTE8,
            X_ATTRIBUTE9 => X_ATTRIBUTE9,
            X_ATTRIBUTE10 => X_ATTRIBUTE10,
            X_ATTRIBUTE11 => X_ATTRIBUTE11,
            X_ATTRIBUTE12 => X_ATTRIBUTE12,
            X_ATTRIBUTE13 => X_ATTRIBUTE13,
            X_ATTRIBUTE14 => X_ATTRIBUTE14,
            X_ATTRIBUTE15 => X_ATTRIBUTE15
     );
     end if;
exception
     when NO_DATA_FOUND then
         INSERT_ROW (
            X_ROWID => l_row_id,
            X_ITEM_ID => l_ITEM_ID,
            X_OBJECT_VERSION_NUMBER => l_OBJECT_VERSION_NUMBER,
            X_CREATION_DATE => f_ludate,
            X_CREATED_BY => f_luby,
            X_LAST_UPDATE_DATE => f_ludate,
            X_LAST_UPDATED_BY => f_luby,
            X_LAST_UPDATE_LOGIN => l_user_id,
            X_APPLICATION_ID => l_APPLICATION_ID,
            X_EXTERNAL_ACCESS_FLAG => X_EXTERNAL_ACCESS_FLAG,
            X_ITEM_NAME => X_ITEM_NAME,
            X_DESCRIPTION => X_DESCRIPTION,
            X_TEXT_STRING => X_TEXT_STRING,
            X_LANGUAGE_CODE => X_LANGUAGE_CODE,
            X_STATUS_CODE => X_STATUS_CODE,
            X_EFFECTIVE_START_DATE => l_EFFECTIVE_START_DATE,
            X_EXPIRATION_DATE => l_EXPIRATION_DATE,
            X_ITEM_TYPE => X_ITEM_TYPE,
            X_URL_STRING => X_URL_STRING,
            X_PUBLICATION_DATE => l_PUBLICATION_DATE,
            X_PRIORITY => X_PRIORITY,
            X_CONTENT_TYPE_ID => l_CONTENT_TYPE_ID,
            X_OWNER_ID => l_OWNER_ID,
            X_DEFAULT_APPROVER_ID => l_DEFAULT_APPROVER_ID,
            X_ITEM_DESTINATION_TYPE => X_ITEM_DESTINATION_TYPE,
            X_ACCESS_NAME => X_ACCESS_NAME,
            X_DELIVERABLE_TYPE_CODE => X_DELIVERABLE_TYPE_CODE,
            X_APPLICABLE_TO_CODE => X_APPLICABLE_TO_CODE,
            X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY,
            X_ATTRIBUTE1 => X_ATTRIBUTE1,
            X_ATTRIBUTE2 => X_ATTRIBUTE2,
            X_ATTRIBUTE3 => X_ATTRIBUTE3,
            X_ATTRIBUTE4 => X_ATTRIBUTE4,
            X_ATTRIBUTE5 => X_ATTRIBUTE5,
            X_ATTRIBUTE6 => X_ATTRIBUTE6,
            X_ATTRIBUTE7 => X_ATTRIBUTE7,
            X_ATTRIBUTE8 => X_ATTRIBUTE8,
            X_ATTRIBUTE9 => X_ATTRIBUTE9,
            X_ATTRIBUTE10 => X_ATTRIBUTE10,
            X_ATTRIBUTE11 => X_ATTRIBUTE11,
            X_ATTRIBUTE12 => X_ATTRIBUTE12,
            X_ATTRIBUTE13 => X_ATTRIBUTE13,
            X_ATTRIBUTE14 => X_ATTRIBUTE14,
            X_ATTRIBUTE15 => X_ATTRIBUTE15
         );
END Load_Row;



procedure Translate_row (
  X_ITEM_ID in NUMBER,
  X_ITEM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TEXT_STRING in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in  VARCHAR2 DEFAULT NULL,
  X_LAST_UPDATE_DATE in  VARCHAR2 DEFAULT NULL
) AS
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin

    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from JTF_AMV_ITEMS_TL
    where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    and ITEM_ID = X_ITEM_ID;

     if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then

         update JTF_AMV_ITEMS_TL set
              ITEM_NAME = X_ITEM_NAME,
              DESCRIPTION       = x_description,
              TEXT_STRING       = X_TEXT_STRING,
              LAST_UPDATE_DATE  = f_ludate,
              LAST_UPDATED_BY   = f_luby,
              LAST_UPDATE_LOGIN = 0,
              SOURCE_LANG = userenv('LANG')
         where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
         and ITEM_ID = X_ITEM_ID;
     end if;

EXCEPTION
    when no_data_found then
      null;
END Translate_row;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ITEM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_EXTERNAL_ACCESS_FLAG in VARCHAR2,
  X_ITEM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TEXT_STRING in VARCHAR2,
  X_LANGUAGE_CODE in VARCHAR2,
  X_STATUS_CODE in VARCHAR2,
  X_EFFECTIVE_START_DATE in DATE,
  X_EXPIRATION_DATE in DATE,
  X_ITEM_TYPE in VARCHAR2,
  X_URL_STRING in VARCHAR2,
  X_PUBLICATION_DATE in DATE,
  X_PRIORITY in VARCHAR2,
  X_CONTENT_TYPE_ID in NUMBER,
  X_OWNER_ID in NUMBER,
  X_DEFAULT_APPROVER_ID in NUMBER,
  X_ITEM_DESTINATION_TYPE in VARCHAR2,
  X_ACCESS_NAME in VARCHAR2,
  X_DELIVERABLE_TYPE_CODE in VARCHAR2,
  X_APPLICABLE_TO_CODE in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2
) is
  cursor C is select ROWID from JTF_AMV_ITEMS_B
    where ITEM_ID = X_ITEM_ID
    ;
begin
  insert into JTF_AMV_ITEMS_B (
    ITEM_ID,
    EXTERNAL_ACCESS_FLAG,
    PUBLICATION_DATE,
    OBJECT_VERSION_NUMBER,
    LANGUAGE_CODE,
    APPLICATION_ID,
    STATUS_CODE,
    EFFECTIVE_START_DATE,
    EXPIRATION_DATE,
    ITEM_TYPE,
    URL_STRING,
    ATTRIBUTE14,
    CONTENT_TYPE_ID,
    OWNER_ID,
    DEFAULT_APPROVER_ID,
    ITEM_DESTINATION_TYPE,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE15,
    PRIORITY,
    ACCESS_NAME,
    DELIVERABLE_TYPE_CODE,
    APPLICABLE_TO_CODE,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ITEM_ID,
    X_EXTERNAL_ACCESS_FLAG,
    X_PUBLICATION_DATE,
    X_OBJECT_VERSION_NUMBER,
    X_LANGUAGE_CODE,
    X_APPLICATION_ID,
    X_STATUS_CODE,
    X_EFFECTIVE_START_DATE,
    X_EXPIRATION_DATE,
    X_ITEM_TYPE,
    X_URL_STRING,
    X_ATTRIBUTE14,
    X_CONTENT_TYPE_ID,
    X_OWNER_ID,
    X_DEFAULT_APPROVER_ID,
    X_ITEM_DESTINATION_TYPE,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE15,
    X_PRIORITY,
    X_ACCESS_NAME,
    X_DELIVERABLE_TYPE_CODE,
    X_APPLICABLE_TO_CODE,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_AMV_ITEMS_TL (
    ITEM_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    ITEM_NAME,
    DESCRIPTION,
    TEXT_STRING,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_ITEM_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ITEM_NAME,
    X_DESCRIPTION,
    X_TEXT_STRING,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_AMV_ITEMS_TL T
    where T.ITEM_ID = X_ITEM_ID
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
  X_ITEM_ID in NUMBER,
  X_PRIORITY in VARCHAR2,
  X_ACCESS_NAME in VARCHAR2,
  X_DELIVERABLE_TYPE_CODE in VARCHAR2,
  X_APPLICABLE_TO_CODE in VARCHAR2,
  X_ITEM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TEXT_STRING in VARCHAR2,
  X_EXTERNAL_ACCESS_FLAG in VARCHAR2,
  X_PUBLICATION_DATE in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LANGUAGE_CODE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_EFFECTIVE_START_DATE in DATE,
  X_EXPIRATION_DATE in DATE,
  X_ITEM_TYPE in VARCHAR2,
  X_URL_STRING in VARCHAR2,
  X_CONTENT_TYPE_ID in NUMBER,
  X_OWNER_ID in NUMBER,
  X_DEFAULT_APPROVER_ID in NUMBER,
  X_ITEM_DESTINATION_TYPE in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2
) is
  cursor c is select
      EXTERNAL_ACCESS_FLAG,
      PUBLICATION_DATE,
      OBJECT_VERSION_NUMBER,
      LANGUAGE_CODE,
      APPLICATION_ID,
      STATUS_CODE,
      EFFECTIVE_START_DATE,
      EXPIRATION_DATE,
      ITEM_TYPE,
      URL_STRING,
      ATTRIBUTE14,
      CONTENT_TYPE_ID,
      OWNER_ID,
      DEFAULT_APPROVER_ID,
      ITEM_DESTINATION_TYPE,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE15,
      PRIORITY,
      ACCESS_NAME,
      DELIVERABLE_TYPE_CODE,
      APPLICABLE_TO_CODE,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13
    from JTF_AMV_ITEMS_B
    where ITEM_ID = X_ITEM_ID
    for update of ITEM_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      ITEM_NAME,
      DESCRIPTION,
      TEXT_STRING,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_AMV_ITEMS_TL
    where ITEM_ID = X_ITEM_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ITEM_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.EXTERNAL_ACCESS_FLAG = X_EXTERNAL_ACCESS_FLAG)
      AND ((recinfo.PUBLICATION_DATE = X_PUBLICATION_DATE)
           OR ((recinfo.PUBLICATION_DATE is null) AND (X_PUBLICATION_DATE is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.LANGUAGE_CODE = X_LANGUAGE_CODE)
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND ((recinfo.STATUS_CODE = X_STATUS_CODE)
           OR ((recinfo.STATUS_CODE is null) AND (X_STATUS_CODE is null)))
      AND ((recinfo.EFFECTIVE_START_DATE = X_EFFECTIVE_START_DATE)
           OR ((recinfo.EFFECTIVE_START_DATE is null) AND (X_EFFECTIVE_START_DATE is null)))
      AND ((recinfo.EXPIRATION_DATE = X_EXPIRATION_DATE)
           OR ((recinfo.EXPIRATION_DATE is null) AND (X_EXPIRATION_DATE is null)))
      AND ((recinfo.ITEM_TYPE = X_ITEM_TYPE)
           OR ((recinfo.ITEM_TYPE is null) AND (X_ITEM_TYPE is null)))
      AND ((recinfo.URL_STRING = X_URL_STRING)
           OR ((recinfo.URL_STRING is null) AND (X_URL_STRING is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.CONTENT_TYPE_ID = X_CONTENT_TYPE_ID)
           OR ((recinfo.CONTENT_TYPE_ID is null) AND (X_CONTENT_TYPE_ID is null)))
      AND ((recinfo.OWNER_ID = X_OWNER_ID)
           OR ((recinfo.OWNER_ID is null) AND (X_OWNER_ID is null)))
      AND ((recinfo.DEFAULT_APPROVER_ID = X_DEFAULT_APPROVER_ID)
           OR ((recinfo.DEFAULT_APPROVER_ID is null) AND (X_DEFAULT_APPROVER_ID is null)))
      AND ((recinfo.ITEM_DESTINATION_TYPE = X_ITEM_DESTINATION_TYPE)
           OR ((recinfo.ITEM_DESTINATION_TYPE is null) AND (X_ITEM_DESTINATION_TYPE is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.PRIORITY = X_PRIORITY)
           OR ((recinfo.PRIORITY is null) AND (X_PRIORITY is null)))
      AND ((recinfo.ACCESS_NAME = X_ACCESS_NAME)
           OR ((recinfo.ACCESS_NAME is null) AND (X_ACCESS_NAME is null)))
      AND ((recinfo.DELIVERABLE_TYPE_CODE = X_DELIVERABLE_TYPE_CODE)
           OR ((recinfo.DELIVERABLE_TYPE_CODE is null) AND (X_DELIVERABLE_TYPE_CODE is null)))
      AND ((recinfo.APPLICABLE_TO_CODE = X_APPLICABLE_TO_CODE)
           OR ((recinfo.APPLICABLE_TO_CODE is null) AND (X_APPLICABLE_TO_CODE is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.ITEM_NAME = X_ITEM_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
          AND ((tlinfo.TEXT_STRING = X_TEXT_STRING)
               OR ((tlinfo.TEXT_STRING is null) AND (X_TEXT_STRING is null)))
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
  X_ITEM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_EXTERNAL_ACCESS_FLAG in VARCHAR2,
  X_ITEM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TEXT_STRING in VARCHAR2,
  X_LANGUAGE_CODE in VARCHAR2,
  X_STATUS_CODE in VARCHAR2,
  X_EFFECTIVE_START_DATE in DATE,
  X_EXPIRATION_DATE in DATE,
  X_ITEM_TYPE in VARCHAR2,
  X_URL_STRING in VARCHAR2,
  X_PUBLICATION_DATE in DATE,
  X_PRIORITY in VARCHAR2,
  X_CONTENT_TYPE_ID in NUMBER,
  X_OWNER_ID in NUMBER,
  X_DEFAULT_APPROVER_ID in NUMBER,
  X_ITEM_DESTINATION_TYPE in VARCHAR2,
  X_ACCESS_NAME in VARCHAR2,
  X_DELIVERABLE_TYPE_CODE in VARCHAR2,
  X_APPLICABLE_TO_CODE in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2
) is
begin
  update JTF_AMV_ITEMS_B set
   OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
   LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
   LAST_UPDATED_BY = X_LAST_UPDATED_BY,
   LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
   APPLICATION_ID = X_APPLICATION_ID,
   EXTERNAL_ACCESS_FLAG = X_EXTERNAL_ACCESS_FLAG,
   LANGUAGE_CODE = X_LANGUAGE_CODE,
   STATUS_CODE = X_STATUS_CODE,
   EFFECTIVE_START_DATE = X_EFFECTIVE_START_DATE,
   EXPIRATION_DATE = X_EXPIRATION_DATE,
   ITEM_TYPE = X_ITEM_TYPE,
   URL_STRING = X_URL_STRING,
   PUBLICATION_DATE = X_PUBLICATION_DATE,
   PRIORITY = X_PRIORITY,
   CONTENT_TYPE_ID = X_CONTENT_TYPE_ID,
   OWNER_ID = X_OWNER_ID,
   DEFAULT_APPROVER_ID = X_DEFAULT_APPROVER_ID,
   ITEM_DESTINATION_TYPE = X_ITEM_DESTINATION_TYPE,
   ACCESS_NAME = X_ACCESS_NAME,
   DELIVERABLE_TYPE_CODE = X_DELIVERABLE_TYPE_CODE,
   APPLICABLE_TO_CODE = X_APPLICABLE_TO_CODE,
   ATTRIBUTE_CATEGORY = decode(X_ATTRIBUTE_CATEGORY,FND_API.G_MISS_CHAR,
                        ATTRIBUTE_CATEGORY, X_ATTRIBUTE_CATEGORY),
   ATTRIBUTE1 =decode(X_ATTRIBUTE1,FND_API.G_MISS_CHAR,ATTRIBUTE1,X_ATTRIBUTE1),
   ATTRIBUTE2 =decode(X_ATTRIBUTE2,FND_API.G_MISS_CHAR,ATTRIBUTE2,X_ATTRIBUTE2),
   ATTRIBUTE3 =decode(X_ATTRIBUTE3,FND_API.G_MISS_CHAR,ATTRIBUTE3,X_ATTRIBUTE3),
   ATTRIBUTE4 =decode(X_ATTRIBUTE4,FND_API.G_MISS_CHAR,ATTRIBUTE4,X_ATTRIBUTE4),
   ATTRIBUTE5 =decode(X_ATTRIBUTE5,FND_API.G_MISS_CHAR,ATTRIBUTE5,X_ATTRIBUTE5),
   ATTRIBUTE6 =decode(X_ATTRIBUTE6,FND_API.G_MISS_CHAR,ATTRIBUTE6,X_ATTRIBUTE6),
   ATTRIBUTE7 =decode(X_ATTRIBUTE7,FND_API.G_MISS_CHAR,ATTRIBUTE7,X_ATTRIBUTE7),
   ATTRIBUTE8 =decode(X_ATTRIBUTE8,FND_API.G_MISS_CHAR,ATTRIBUTE8,X_ATTRIBUTE8),
   ATTRIBUTE9 =decode(X_ATTRIBUTE9,FND_API.G_MISS_CHAR,ATTRIBUTE9,X_ATTRIBUTE9),
   ATTRIBUTE10 = decode(X_ATTRIBUTE10,FND_API.G_MISS_CHAR,
                        ATTRIBUTE10, X_ATTRIBUTE10),
   ATTRIBUTE11 = decode(X_ATTRIBUTE11,FND_API.G_MISS_CHAR,
                        ATTRIBUTE11, X_ATTRIBUTE11),
   ATTRIBUTE12 = decode(X_ATTRIBUTE12,FND_API.G_MISS_CHAR,
                        ATTRIBUTE12, X_ATTRIBUTE12),
   ATTRIBUTE13 = decode(X_ATTRIBUTE13,FND_API.G_MISS_CHAR,
                        ATTRIBUTE13, X_ATTRIBUTE13),
   ATTRIBUTE14 = decode(X_ATTRIBUTE14,FND_API.G_MISS_CHAR,
                        ATTRIBUTE14, X_ATTRIBUTE14),
   ATTRIBUTE15 = decode(X_ATTRIBUTE15,FND_API.G_MISS_CHAR,
                        ATTRIBUTE15, X_ATTRIBUTE15)
  where ITEM_ID = X_ITEM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_AMV_ITEMS_TL set
    ITEM_NAME = decode( X_ITEM_NAME,
               FND_API.G_MISS_CHAR, ITEM_NAME, X_ITEM_NAME),
    DESCRIPTION = decode( X_DESCRIPTION,
               FND_API.G_MISS_CHAR, DESCRIPTION, X_DESCRIPTION),
    TEXT_STRING = decode (X_TEXT_STRING,
               FND_API.G_MISS_CHAR, TEXT_STRING, X_TEXT_STRING),
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ITEM_ID = X_ITEM_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW ;

procedure DELETE_ROW (
  X_ITEM_ID in NUMBER
) is
begin
  delete from JTF_AMV_ITEMS_TL
  where ITEM_ID = X_ITEM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_AMV_ITEMS_B
  where ITEM_ID = X_ITEM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_AMV_ITEMS_TL T
  where not exists
    (select NULL
    from JTF_AMV_ITEMS_B B
    where B.ITEM_ID = T.ITEM_ID
    );

  update JTF_AMV_ITEMS_TL T set (
      ITEM_NAME,
      DESCRIPTION,
      TEXT_STRING
    ) = (select
      B.ITEM_NAME,
      B.DESCRIPTION,
      B.TEXT_STRING
    from JTF_AMV_ITEMS_TL B
    where B.ITEM_ID = T.ITEM_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ITEM_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ITEM_ID,
      SUBT.LANGUAGE
    from JTF_AMV_ITEMS_TL SUBB, JTF_AMV_ITEMS_TL SUBT
    where SUBB.ITEM_ID = SUBT.ITEM_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.ITEM_NAME <> SUBT.ITEM_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
      or SUBB.TEXT_STRING <> SUBT.TEXT_STRING
      or (SUBB.TEXT_STRING is null and SUBT.TEXT_STRING is not null)
      or (SUBB.TEXT_STRING is not null and SUBT.TEXT_STRING is null)
  ));

  insert into JTF_AMV_ITEMS_TL (
    ITEM_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    ITEM_NAME,
    DESCRIPTION,
    TEXT_STRING,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ITEM_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.ITEM_NAME,
    B.DESCRIPTION,
    B.TEXT_STRING,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_AMV_ITEMS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_AMV_ITEMS_TL T
    where T.ITEM_ID = B.ITEM_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_SEED_ROW(
  x_upload_mode       in varchar2,
  x_item_id           in varchar2,
  x_item_name         in varchar2,
  x_description       in varchar2,
  x_text_string       in varchar2,
  x_owner             in varchar2,
  x_object_version_number in varchar2,
  x_status_code           in varchar2,
  x_effective_start_date in varchar2,
  x_expiration_date      in varchar2,
  x_application_id       in varchar2,
  x_external_access_flag in varchar2,
  x_priority             in varchar2,
  x_publication_date      in varchar2,
  x_language_code in varchar2,
  x_item_type     in varchar2,
  x_url_string    in varchar2,
  x_content_type_id       in varchar2,
  x_owner_id              in varchar2,
  x_default_approver_id   in varchar2,
  x_item_destination_type in varchar2,
  x_access_name           in varchar2,
  x_deliverable_type_code in varchar2,
  x_applicable_to_code    in varchar2,
  x_attribute_category    in varchar2,
  x_attribute1 in varchar2,
  x_attribute2 in varchar2,
  x_attribute3 in varchar2,
  x_attribute4 in varchar2,
  x_attribute5 in varchar2,
  x_attribute6 in varchar2,
  x_attribute7 in varchar2,
  x_attribute8 in varchar2,
  x_attribute9 in varchar2,
  x_attribute10 in varchar2,
  x_attribute11 in varchar2,
  x_attribute12  in varchar2,
  x_attribute13  in varchar2,
  x_attribute14  in varchar2,
  x_attribute15  in varchar2,
  x_custom_mode in varchar2 ,
  x_last_update_date in varchar2
  )

  is

  v_db_owner_id number;

  begin
     if (x_upload_mode = 'NLS') then
         JTF_AMV_ITEMS_PKG.TRANSLATE_ROW (
              X_ITEM_ID       => x_item_id
            , X_ITEM_NAME     => x_item_name
            , x_description   => x_description
            , X_TEXT_STRING   => x_text_string
            , x_owner         =>    x_owner
            , x_last_update_date => x_last_update_date
            );
     else

         JTF_AMV_ITEMS_PKG.LOAD_ROW (
            X_ITEM_ID => x_item_id,
            x_object_version_number => x_object_version_number,
            X_STATUS_CODE => x_status_code,
            X_EFFECTIVE_START_DATE => x_effective_start_date,
            X_EXPIRATION_DATE => x_expiration_date,
            X_APPLICATION_ID => x_application_id,
            X_EXTERNAL_ACCESS_FLAG => x_external_access_flag,
            X_PRIORITY =>         x_priority,
            X_PUBLICATION_DATE => x_publication_date,
            X_LANGUAGE_CODE =>    x_language_code,
            X_ITEM_TYPE =>        x_item_type,
            X_URL_STRING =>       x_url_string,
            X_CONTENT_TYPE_ID =>  x_content_type_id,
            X_OWNER_ID =>         x_owner_id,
            X_DEFAULT_APPROVER_ID =>   x_default_approver_id,
            X_ITEM_DESTINATION_TYPE => x_item_destination_type,
            X_ACCESS_NAME =>           x_access_name,
            X_DELIVERABLE_TYPE_CODE => x_deliverable_type_code,
            X_APPLICABLE_TO_CODE =>    x_applicable_to_code,
            X_ATTRIBUTE_CATEGORY =>    x_attribute_category,
            X_ATTRIBUTE1 => x_attribute1,
            X_ATTRIBUTE2 => x_attribute2,
            X_ATTRIBUTE3 => x_attribute3,
            X_ATTRIBUTE4 => x_attribute4,
            X_ATTRIBUTE5 => x_attribute5,
            X_ATTRIBUTE6 => x_attribute6,
            X_ATTRIBUTE7 => x_attribute7,
            X_ATTRIBUTE8 => x_attribute8,
            X_ATTRIBUTE9 => x_attribute9,
            X_ATTRIBUTE10 => x_attribute10,
            X_ATTRIBUTE11 => x_attribute11,
            X_ATTRIBUTE12 => x_attribute12,
            X_ATTRIBUTE13 => x_attribute13,
            X_ATTRIBUTE14 => x_attribute14,
            X_ATTRIBUTE15 => x_attribute15,
            X_ITEM_NAME => x_item_name,
            X_DESCRIPTION => x_description,
            X_TEXT_STRING => x_text_string,
            X_Owner            => x_owner,
	    x_custom_mode => x_custom_mode,
	   x_last_update_date=>x_last_update_date
            );

     end if;

      exception
        when no_data_found then
         JTF_AMV_ITEMS_PKG.LOAD_ROW (
            X_ITEM_ID => x_item_id,
            x_object_version_number => x_object_version_number,
            X_STATUS_CODE => x_status_code,
            X_EFFECTIVE_START_DATE => x_effective_start_date,
            X_EXPIRATION_DATE => x_expiration_date,
            X_APPLICATION_ID => x_application_id,
            X_EXTERNAL_ACCESS_FLAG => x_external_access_flag,
            X_PRIORITY => x_priority,
            X_PUBLICATION_DATE => x_publication_date,
            X_LANGUAGE_CODE => x_language_code,
            X_ITEM_TYPE => x_item_type,
            X_URL_STRING => x_url_string,
            X_CONTENT_TYPE_ID => x_content_type_id,
            X_OWNER_ID => x_owner_id,
            X_DEFAULT_APPROVER_ID => x_default_approver_id,
            X_ITEM_DESTINATION_TYPE => x_item_destination_type,
            X_ACCESS_NAME => x_access_name,
            X_DELIVERABLE_TYPE_CODE => x_deliverable_type_code,
            X_APPLICABLE_TO_CODE => x_applicable_to_code,
            X_ATTRIBUTE_CATEGORY => x_attribute_category,
            X_ATTRIBUTE1 => x_attribute1,
            X_ATTRIBUTE2 => x_attribute2,
            X_ATTRIBUTE3 => x_attribute3,
            X_ATTRIBUTE4 => x_attribute4,
            X_ATTRIBUTE5 => x_attribute5,
            X_ATTRIBUTE6 => x_attribute6,
            X_ATTRIBUTE7 => x_attribute7,
            X_ATTRIBUTE8 => x_attribute8,
            X_ATTRIBUTE9 => x_attribute9,
            X_ATTRIBUTE10 => x_attribute10,
            X_ATTRIBUTE11 => x_attribute11,
            X_ATTRIBUTE12 => x_attribute12,
            X_ATTRIBUTE13 => x_attribute13,
            X_ATTRIBUTE14 => x_attribute14,
            X_ATTRIBUTE15 => x_attribute15,
            X_ITEM_NAME => x_item_name,
            X_DESCRIPTION => x_description,
            X_TEXT_STRING => x_text_string,
            X_Owner            => x_owner,
	    x_custom_mode => x_custom_mode,
	    x_last_update_date=>x_last_update_date
            );

 end LOAD_SEED_ROW;

end JTF_AMV_ITEMS_PKG;

/
