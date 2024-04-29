--------------------------------------------------------
--  DDL for Package Body AHL_DOC_TITLE_ASSOS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DOC_TITLE_ASSOS_PKG" as
/* $Header: AHLLDASB.pls 115.5 2002/12/04 00:56:03 jeli noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DOC_TITLE_ASSO_ID in NUMBER,
  X_SERIAL_NO in VARCHAR2,
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
  X_ASO_OBJECT_TYPE_CODE in VARCHAR2,
  X_SOURCE_REF_CODE in VARCHAR2,
  X_ASO_OBJECT_ID in NUMBER,
  X_DOCUMENT_ID in NUMBER,
  X_USE_LATEST_REV_FLAG in VARCHAR2,
  X_DOC_REVISION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CHAPTER in VARCHAR2,
  X_SECTION in VARCHAR2,
  X_SUBJECT in VARCHAR2,
  X_FIGURE in VARCHAR2,
  X_PAGE in VARCHAR2,
  X_NOTE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AHL_DOC_TITLE_ASSOS_B
    where DOC_TITLE_ASSO_ID = X_DOC_TITLE_ASSO_ID
    ;
begin
  insert into AHL_DOC_TITLE_ASSOS_B (
    SERIAL_NO,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
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
    ASO_OBJECT_TYPE_CODE,
    SOURCE_REF_CODE,
    ASO_OBJECT_ID,
    DOCUMENT_ID,
    USE_LATEST_REV_FLAG,
    DOC_REVISION_ID,
    DOC_TITLE_ASSO_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_SERIAL_NO,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
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
    X_ASO_OBJECT_TYPE_CODE,
    X_SOURCE_REF_CODE,
    X_ASO_OBJECT_ID,
    X_DOCUMENT_ID,
    X_USE_LATEST_REV_FLAG,
    X_DOC_REVISION_ID,
    X_DOC_TITLE_ASSO_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AHL_DOC_TITLE_ASSOS_TL (
    FIGURE,
    NOTE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    CHAPTER,
    SECTION,
    SUBJECT,
    PAGE,
    DOC_TITLE_ASSO_ID,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_FIGURE,
    X_NOTE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CHAPTER,
    X_SECTION,
    X_SUBJECT,
    X_PAGE,
    X_DOC_TITLE_ASSO_ID,
    X_LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AHL_DOC_TITLE_ASSOS_TL T
    where T.DOC_TITLE_ASSO_ID = X_DOC_TITLE_ASSO_ID
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
  X_DOC_TITLE_ASSO_ID in NUMBER,
  X_SERIAL_NO in VARCHAR2,
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
  X_ASO_OBJECT_TYPE_CODE in VARCHAR2,
  X_SOURCE_REF_CODE in VARCHAR2,
  X_ASO_OBJECT_ID in NUMBER,
  X_DOCUMENT_ID in NUMBER,
  X_USE_LATEST_REV_FLAG in VARCHAR2,
  X_DOC_REVISION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CHAPTER in VARCHAR2,
  X_SECTION in VARCHAR2,
  X_SUBJECT in VARCHAR2,
  X_FIGURE in VARCHAR2,
  X_PAGE in VARCHAR2,
  X_NOTE in VARCHAR2
) is
  cursor c is select
      SERIAL_NO,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
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
      ASO_OBJECT_TYPE_CODE,
      SOURCE_REF_CODE,
      ASO_OBJECT_ID,
      DOCUMENT_ID,
      USE_LATEST_REV_FLAG,
      DOC_REVISION_ID,
      OBJECT_VERSION_NUMBER
    from AHL_DOC_TITLE_ASSOS_B
    where DOC_TITLE_ASSO_ID = X_DOC_TITLE_ASSO_ID
    for update of DOC_TITLE_ASSO_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      CHAPTER,
      SECTION,
      SUBJECT,
      FIGURE,
      PAGE,
      NOTE,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AHL_DOC_TITLE_ASSOS_TL
    where DOC_TITLE_ASSO_ID = X_DOC_TITLE_ASSO_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DOC_TITLE_ASSO_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.SERIAL_NO = X_SERIAL_NO)
           OR ((recinfo.SERIAL_NO is null) AND (X_SERIAL_NO is null)))
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
      AND (recinfo.ASO_OBJECT_TYPE_CODE = X_ASO_OBJECT_TYPE_CODE)
      AND (recinfo.ASO_OBJECT_ID = X_ASO_OBJECT_ID)
      AND (recinfo.DOCUMENT_ID = X_DOCUMENT_ID)
      AND ((recinfo.USE_LATEST_REV_FLAG = X_USE_LATEST_REV_FLAG)
           OR ((recinfo.USE_LATEST_REV_FLAG is null) AND (X_USE_LATEST_REV_FLAG is null)))
      AND ((recinfo.DOC_REVISION_ID = X_DOC_REVISION_ID)
           OR ((recinfo.DOC_REVISION_ID is null) AND (X_DOC_REVISION_ID is null)))
      AND ((recinfo.SOURCE_REF_CODE = X_SOURCE_REF_CODE)
           OR ((recinfo.SOURCE_REF_CODE is null) AND (X_SOURCE_REF_CODE is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.CHAPTER = X_CHAPTER)
               OR ((tlinfo.CHAPTER is null) AND (X_CHAPTER is null)))
          AND ((tlinfo.SECTION = X_SECTION)
               OR ((tlinfo.SECTION is null) AND (X_SECTION is null)))
          AND ((tlinfo.SUBJECT = X_SUBJECT)
               OR ((tlinfo.SUBJECT is null) AND (X_SUBJECT is null)))
          AND ((tlinfo.FIGURE = X_FIGURE)
               OR ((tlinfo.FIGURE is null) AND (X_FIGURE is null)))
          AND ((tlinfo.PAGE = X_PAGE)
               OR ((tlinfo.PAGE is null) AND (X_PAGE is null)))
          AND ((tlinfo.NOTE = X_NOTE)
               OR ((tlinfo.NOTE is null) AND (X_NOTE is null)))
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
  X_DOC_TITLE_ASSO_ID in NUMBER,
  X_SERIAL_NO in VARCHAR2,
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
  X_ASO_OBJECT_TYPE_CODE in VARCHAR2,
  X_SOURCE_REF_CODE in VARCHAR2,
  X_ASO_OBJECT_ID in NUMBER,
  X_DOCUMENT_ID in NUMBER,
  X_USE_LATEST_REV_FLAG in VARCHAR2,
  X_DOC_REVISION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CHAPTER in VARCHAR2,
  X_SECTION in VARCHAR2,
  X_SUBJECT in VARCHAR2,
  X_FIGURE in VARCHAR2,
  X_PAGE in VARCHAR2,
  X_NOTE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AHL_DOC_TITLE_ASSOS_B set
    SERIAL_NO = X_SERIAL_NO,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
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
    ASO_OBJECT_TYPE_CODE = X_ASO_OBJECT_TYPE_CODE,
    SOURCE_REF_CODE = X_SOURCE_REF_CODE,
    ASO_OBJECT_ID = X_ASO_OBJECT_ID,
    DOCUMENT_ID = X_DOCUMENT_ID,
    USE_LATEST_REV_FLAG = X_USE_LATEST_REV_FLAG,
    DOC_REVISION_ID = X_DOC_REVISION_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where DOC_TITLE_ASSO_ID = X_DOC_TITLE_ASSO_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AHL_DOC_TITLE_ASSOS_TL set
    CHAPTER = X_CHAPTER,
    SECTION = X_SECTION,
    SUBJECT = X_SUBJECT,
    FIGURE = X_FIGURE,
    PAGE = X_PAGE,
    NOTE = X_NOTE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DOC_TITLE_ASSO_ID = X_DOC_TITLE_ASSO_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DOC_TITLE_ASSO_ID in NUMBER
) is
begin
  delete from AHL_DOC_TITLE_ASSOS_TL
  where DOC_TITLE_ASSO_ID = X_DOC_TITLE_ASSO_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AHL_DOC_TITLE_ASSOS_B
  where DOC_TITLE_ASSO_ID = X_DOC_TITLE_ASSO_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AHL_DOC_TITLE_ASSOS_TL T
  where not exists
    (select NULL
    from AHL_DOC_TITLE_ASSOS_B B
    where B.DOC_TITLE_ASSO_ID = T.DOC_TITLE_ASSO_ID
    );

  update AHL_DOC_TITLE_ASSOS_TL T set (
      CHAPTER,
      SECTION,
      SUBJECT,
      FIGURE,
      PAGE,
      NOTE
    ) = (select
      B.CHAPTER,
      B.SECTION,
      B.SUBJECT,
      B.FIGURE,
      B.PAGE,
      B.NOTE
    from AHL_DOC_TITLE_ASSOS_TL B
    where B.DOC_TITLE_ASSO_ID = T.DOC_TITLE_ASSO_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DOC_TITLE_ASSO_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DOC_TITLE_ASSO_ID,
      SUBT.LANGUAGE
    from AHL_DOC_TITLE_ASSOS_TL SUBB, AHL_DOC_TITLE_ASSOS_TL SUBT
    where SUBB.DOC_TITLE_ASSO_ID = SUBT.DOC_TITLE_ASSO_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CHAPTER <> SUBT.CHAPTER
      or (SUBB.CHAPTER is null and SUBT.CHAPTER is not null)
      or (SUBB.CHAPTER is not null and SUBT.CHAPTER is null)
      or SUBB.SECTION <> SUBT.SECTION
      or (SUBB.SECTION is null and SUBT.SECTION is not null)
      or (SUBB.SECTION is not null and SUBT.SECTION is null)
      or SUBB.SUBJECT <> SUBT.SUBJECT
      or (SUBB.SUBJECT is null and SUBT.SUBJECT is not null)
      or (SUBB.SUBJECT is not null and SUBT.SUBJECT is null)
      or SUBB.FIGURE <> SUBT.FIGURE
      or (SUBB.FIGURE is null and SUBT.FIGURE is not null)
      or (SUBB.FIGURE is not null and SUBT.FIGURE is null)
      or SUBB.PAGE <> SUBT.PAGE
      or (SUBB.PAGE is null and SUBT.PAGE is not null)
      or (SUBB.PAGE is not null and SUBT.PAGE is null)
      or SUBB.NOTE <> SUBT.NOTE
      or (SUBB.NOTE is null and SUBT.NOTE is not null)
      or (SUBB.NOTE is not null and SUBT.NOTE is null)
  ));

  insert into AHL_DOC_TITLE_ASSOS_TL (
    FIGURE,
    NOTE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    CHAPTER,
    SECTION,
    SUBJECT,
    PAGE,
    DOC_TITLE_ASSO_ID,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.FIGURE,
    B.NOTE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CHAPTER,
    B.SECTION,
    B.SUBJECT,
    B.PAGE,
    B.DOC_TITLE_ASSO_ID,
    B.LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AHL_DOC_TITLE_ASSOS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AHL_DOC_TITLE_ASSOS_TL T
    where T.DOC_TITLE_ASSO_ID = B.DOC_TITLE_ASSO_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_DOC_TITLE_ASSO_ID      in NUMBER,
  X_SERIAL_NO              in VARCHAR2,
  X_ASO_OBJECT_TYPE_CODE   in VARCHAR2,
  X_SOURCE_REF_CODE        in VARCHAR2,
  X_ASO_OBJECT_ID          in NUMBER,
  X_DOCUMENT_ID            in NUMBER,
  X_USE_LATEST_REV_FLAG    in VARCHAR2,
  X_DOC_REVISION_ID        in NUMBER,
  X_OBJECT_VERSION_NUMBER  in NUMBER,
  X_ATTRIBUTE_CATEGORY     in VARCHAR2,
  X_ATTRIBUTE1             in VARCHAR2,
  X_ATTRIBUTE2             in VARCHAR2,
  X_ATTRIBUTE3             in VARCHAR2,
  X_ATTRIBUTE4             in VARCHAR2,
  X_ATTRIBUTE5             in VARCHAR2,
  X_ATTRIBUTE6             in VARCHAR2,
  X_ATTRIBUTE7             in VARCHAR2,
  X_ATTRIBUTE8             in VARCHAR2,
  X_ATTRIBUTE9             in VARCHAR2,
  X_ATTRIBUTE10            in VARCHAR2,
  X_ATTRIBUTE11            in VARCHAR2,
  X_ATTRIBUTE12            in VARCHAR2,
  X_ATTRIBUTE13            in VARCHAR2,
  X_ATTRIBUTE14            in VARCHAR2,
  X_ATTRIBUTE15            in VARCHAR2,
  X_CHAPTER                in VARCHAR2,
  X_SECTION                in VARCHAR2,
  X_SUBJECT                in VARCHAR2,
  X_FIGURE                 in VARCHAR2,
  X_PAGE                   in VARCHAR2,
  X_NOTE                   in VARCHAR2,
  X_OWNER                  in VARCHAR2
) is
 user_id number := 0;
 doc_title_id  number;
 row_id  varchar2(64);
begin
  if (X_OWNER = 'SEED') then
    user_id := 1;
  end if;

  select doc_title_asso_id into doc_title_id
  from   ahl_doc_title_assos_b
  where  doc_title_asso_id = X_DOC_TITLE_ASSO_ID;

AHL_DOC_TITLE_ASSOS_PKG.UPDATE_ROW (
  X_DOC_TITLE_ASSO_ID          => doc_title_id,
  X_SERIAL_NO                  => X_SERIAL_NO,
  X_ATTRIBUTE_CATEGORY         => X_ATTRIBUTE_CATEGORY,
  X_ATTRIBUTE1                 => X_ATTRIBUTE1,
  X_ATTRIBUTE2                 =>X_ATTRIBUTE2,
  X_ATTRIBUTE3                 =>X_ATTRIBUTE3,
  X_ATTRIBUTE4                 =>X_ATTRIBUTE4,
  X_ATTRIBUTE5                 =>X_ATTRIBUTE5,
  X_ATTRIBUTE6                 =>X_ATTRIBUTE6,
  X_ATTRIBUTE7                 =>X_ATTRIBUTE7,
  X_ATTRIBUTE8                 => X_ATTRIBUTE8,
  X_ATTRIBUTE9                 =>X_ATTRIBUTE9,
  X_ATTRIBUTE10                =>X_ATTRIBUTE10,
  X_ATTRIBUTE11                =>X_ATTRIBUTE11,
  X_ATTRIBUTE12                =>X_ATTRIBUTE12,
  X_ATTRIBUTE13                =>X_ATTRIBUTE13,
  X_ATTRIBUTE14                => X_ATTRIBUTE14,
  X_ATTRIBUTE15                => X_ATTRIBUTE15,
  X_ASO_OBJECT_TYPE_CODE       => X_ASO_OBJECT_TYPE_CODE,
  X_SOURCE_REF_CODE            => X_SOURCE_REF_CODE,
  X_ASO_OBJECT_ID              => X_ASO_OBJECT_ID,
  X_DOCUMENT_ID                => X_DOCUMENT_ID,
  X_USE_LATEST_REV_FLAG        => X_USE_LATEST_REV_FLAG,
  X_DOC_REVISION_ID            => X_DOC_REVISION_ID,
  X_OBJECT_VERSION_NUMBER      => X_OBJECT_VERSION_NUMBER+1,
  X_CHAPTER                    => X_CHAPTER,
  X_SECTION                    => X_SECTION,
  X_SUBJECT                    => X_SUBJECT,
  X_FIGURE                     => X_FIGURE,
  X_PAGE                       => X_PAGE,
  X_NOTE                       => X_NOTE,
  X_LAST_UPDATE_DATE 	       => sysdate,
  X_LAST_UPDATED_BY            => user_id,
  X_LAST_UPDATE_LOGIN 	       => 0
);

exception
  when NO_DATA_FOUND then

 SELECT  AHL_DOC_TITLE_ASSOS_B_S.Nextval INTO
           doc_title_id from DUAL;

AHL_DOC_TITLE_ASSOS_PKG.INSERT_ROW (
  X_ROWID                      => row_id,
  X_DOC_TITLE_ASSO_ID          => doc_title_id,
  X_SERIAL_NO                  => X_SERIAL_NO,
  X_ATTRIBUTE_CATEGORY         => X_ATTRIBUTE_CATEGORY,
  X_ATTRIBUTE1                 => X_ATTRIBUTE1,
  X_ATTRIBUTE2                 =>X_ATTRIBUTE2,
  X_ATTRIBUTE3                 =>X_ATTRIBUTE3,
  X_ATTRIBUTE4                 =>X_ATTRIBUTE4,
  X_ATTRIBUTE5                 =>X_ATTRIBUTE5,
  X_ATTRIBUTE6                 =>X_ATTRIBUTE6,
  X_ATTRIBUTE7                 =>X_ATTRIBUTE7,
  X_ATTRIBUTE8                 => X_ATTRIBUTE8,
  X_ATTRIBUTE9                 =>X_ATTRIBUTE9,
  X_ATTRIBUTE10                =>X_ATTRIBUTE10,
  X_ATTRIBUTE11                =>X_ATTRIBUTE11,
  X_ATTRIBUTE12                =>X_ATTRIBUTE12,
  X_ATTRIBUTE13                =>X_ATTRIBUTE13,
  X_ATTRIBUTE14                => X_ATTRIBUTE14,
  X_ATTRIBUTE15                => X_ATTRIBUTE15,
  X_ASO_OBJECT_TYPE_CODE       => X_ASO_OBJECT_TYPE_CODE,
  X_SOURCE_REF_CODE            => X_SOURCE_REF_CODE,
  X_ASO_OBJECT_ID              => X_ASO_OBJECT_ID,
  X_DOCUMENT_ID                => X_DOCUMENT_ID,
  X_USE_LATEST_REV_FLAG        => X_USE_LATEST_REV_FLAG,
  X_DOC_REVISION_ID            => X_DOC_REVISION_ID,
  X_OBJECT_VERSION_NUMBER      => 1,
  X_CHAPTER                    => X_CHAPTER,
  X_SECTION                    => X_SECTION,
  X_SUBJECT                    => X_SUBJECT,
  X_FIGURE                     => X_FIGURE,
  X_PAGE                       => X_PAGE,
  X_NOTE                       => X_NOTE,
  X_CREATION_DATE              => sysdate,
  X_CREATED_BY                 => user_id,
  X_LAST_UPDATE_DATE           => sysdate,
  X_LAST_UPDATED_BY            => user_id,
  X_LAST_UPDATE_LOGIN          => 0
);
end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_DOC_TITLE_ASSO_ID      in NUMBER,
  X_CHAPTER                in VARCHAR2,
  X_SECTION                in VARCHAR2,
  X_SUBJECT                in VARCHAR2,
  X_FIGURE                 in VARCHAR2,
  X_PAGE                   in VARCHAR2,
  X_NOTE                   in VARCHAR2,
  X_OWNER                  in VARCHAR2
) is
begin
update AHl_DOC_TITLE_ASSOS_TL set
 chapter           = nvl(X_CHAPTER, chapter),
 section           = nvl(X_SECTION, section),
 subject           = nvl(X_SUBJECT, subject),
 figure            = nvl(X_FIGURE, figure),
 page              = nvl(X_PAGE, page),
 note              = nvl(X_NOTE, note),
 source_lang       = userenv('LANG'),
 last_update_date  = sysdate,
 last_updated_by   = decode(X_OWNER, 'SEED', 1, 0),
 last_update_login = 0
where doc_title_asso_id =
	(select doc_title_asso_id
         from ahl_doc_title_assos_b
         where doc_title_asso_id = X_DOC_TITLE_ASSO_ID)
and userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;


end AHL_DOC_TITLE_ASSOS_PKG;

/
