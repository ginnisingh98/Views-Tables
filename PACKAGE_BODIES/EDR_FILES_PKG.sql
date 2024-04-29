--------------------------------------------------------
--  DDL for Package Body EDR_FILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_FILES_PKG" as
/* $Header: EDRGFILB.pls 120.2.12000000.1 2007/01/18 05:53:25 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_FILE_ID in NUMBER,
  X_FILE_NAME in VARCHAR2,
  X_ORIGINAL_FILE_NAME in VARCHAR2,
  X_VERSION_LABEL in VARCHAR2,
  X_CATEGORY_ID in NUMBER,
  X_CONTENT_TYPE in VARCHAR2,
  X_FILE_FORMAT in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_FND_DOCUMENT_ID in NUMBER,
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
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER)
is
  cursor C is select ROWID from EDR_FILES_B
    where FILE_ID = X_FILE_ID
    ;
begin
  insert into EDR_FILES_B (
    FILE_ID,
    FILE_NAME,
    ORIGINAL_FILE_NAME,
    VERSION_LABEL,
    CATEGORY_ID,
    CONTENT_TYPE,
    ATTRIBUTE4,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    FILE_FORMAT,
    STATUS,
    VERSION_NUMBER,
    FND_DOCUMENT_ID,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_FILE_ID,
    X_FILE_NAME,
    X_ORIGINAL_FILE_NAME,
    X_VERSION_LABEL,
    X_CATEGORY_ID,
    X_CONTENT_TYPE,
    X_ATTRIBUTE4,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_FILE_FORMAT,
    X_STATUS,
    X_VERSION_NUMBER,
    X_FND_DOCUMENT_ID,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into EDR_FILES_TL (
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    FILE_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_FILE_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from EDR_FILES_TL T
    where T.FILE_ID = X_FILE_ID
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
  X_FILE_ID in NUMBER,
  X_FILE_NAME in VARCHAR2,
  X_ORIGINAL_FILE_NAME in VARCHAR2,
  X_VERSION_LABEL in VARCHAR2,
  X_CATEGORY_ID in NUMBER,
  X_CONTENT_TYPE in VARCHAR2,
  X_FILE_FORMAT in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_FND_DOCUMENT_ID in NUMBER,
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
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      FILE_NAME,
      ORIGINAL_FILE_NAME,
      VERSION_LABEL,
      CATEGORY_ID,
      CONTENT_TYPE,
      ATTRIBUTE4,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      FILE_FORMAT,
      STATUS,
      VERSION_NUMBER,
      FND_DOCUMENT_ID,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15
    from EDR_FILES_B
    where FILE_ID = X_FILE_ID
    for update of FILE_ID nowait;
  recinfo c%rowtype;
  cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from EDR_FILES_TL
    where FILE_ID = X_FILE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of FILE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.FILE_NAME = X_FILE_NAME)
      AND (recinfo.ORIGINAL_FILE_NAME = X_ORIGINAL_FILE_NAME)
      AND (recinfo.VERSION_LABEL = X_VERSION_LABEL)
      AND (recinfo.CATEGORY_ID = X_CATEGORY_ID)
      AND (recinfo.CONTENT_TYPE = X_CONTENT_TYPE)
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND (recinfo.FILE_FORMAT = X_FILE_FORMAT)
      AND ((recinfo.STATUS = X_STATUS)
           OR ((recinfo.STATUS is null) AND (X_STATUS is null)))
      AND (recinfo.VERSION_NUMBER = X_VERSION_NUMBER)
      AND ((recinfo.FND_DOCUMENT_ID = X_FND_DOCUMENT_ID)
           OR ((recinfo.FND_DOCUMENT_ID is null) AND (X_FND_DOCUMENT_ID is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
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
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
  ) then
    null;
  else
	NULL;
--    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
--    app_exception.raise_exception;
  end if;
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      ) then
        null;
      else
	  null;
--        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
--        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_FILE_ID in NUMBER,
  X_FILE_NAME in VARCHAR2,
  X_ORIGINAL_FILE_NAME in VARCHAR2,
  X_VERSION_LABEL in VARCHAR2,
  X_CATEGORY_ID in NUMBER,
  X_CONTENT_TYPE in VARCHAR2,
  X_FILE_FORMAT in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_FND_DOCUMENT_ID in NUMBER,
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
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update EDR_FILES_B set
    FILE_NAME = X_FILE_NAME,
    ORIGINAL_FILE_NAME = X_ORIGINAL_FILE_NAME,
    VERSION_LABEL = X_VERSION_LABEL,
    CATEGORY_ID = X_CATEGORY_ID,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    STATUS = X_STATUS,
    VERSION_NUMBER = X_VERSION_NUMBER,
    FND_DOCUMENT_ID = X_FND_DOCUMENT_ID,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where FILE_ID = X_FILE_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  update EDR_FILES_TL set
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where FILE_ID = X_FILE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_FILE_ID in NUMBER
) is
begin
  delete from EDR_FILES_TL
  where FILE_ID = X_FILE_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  delete from EDR_FILES_B
  where FILE_ID = X_FILE_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from EDR_FILES_TL T
  where not exists
    (select NULL
    from EDR_FILES_B B
    where B.FILE_ID = T.FILE_ID
    );
  update EDR_FILES_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from EDR_FILES_TL B
    where B.FILE_ID = T.FILE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.FILE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.FILE_ID,
      SUBT.LANGUAGE
    from EDR_FILES_TL SUBB, EDR_FILES_TL SUBT
    where SUBB.FILE_ID = SUBT.FILE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
  insert into EDR_FILES_TL (
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    FILE_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.FILE_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from EDR_FILES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from EDR_FILES_TL T
    where T.FILE_ID = B.FILE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
-- Bug 4472517 : start

FUNCTION check_document_references(X_Document_id NUMBER,X_ENTITY_NAME VARCHAR2)
RETURN NUMBER IS
 reference_count NUMBER;
BEGIN

SELECT count(*) INTO reference_count   FROM fnd_attached_documents
   WHERE document_id = X_document_id and ENTITY_NAME <>  X_ENTITY_NAME;

  IF (reference_count > 0) THEN
	 reference_count := 1;
  ELSE
      reference_count := 0;
  END IF;
   RETURN reference_count;
END;

-- Bug 4472517 : End

end EDR_FILES_PKG;

/
