--------------------------------------------------------
--  DDL for Package Body AHL_DOCUMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DOCUMENTS_PKG" as
/* $Header: AHLLDIXB.pls 115.6 2002/12/04 08:22:47 pbarman noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DOCUMENT_ID in NUMBER,
  X_SUBSCRIBE_AVAIL_FLAG in VARCHAR2,
  X_SUBSCRIBE_TO_FLAG in VARCHAR2,
  X_DOC_TYPE_CODE in VARCHAR2,
  X_DOC_SUB_TYPE_CODE in VARCHAR2,
  X_OPERATOR_CODE in VARCHAR2,
  X_PRODUCT_TYPE_CODE in VARCHAR2,
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
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SOURCE_PARTY_ID in NUMBER,
  X_DOCUMENT_NO in VARCHAR2,
  X_DOCUMENT_TITLE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AHL_DOCUMENTS_B
    where DOCUMENT_ID = X_DOCUMENT_ID
    ;
begin
  insert into AHL_DOCUMENTS_B (
    SUBSCRIBE_AVAIL_FLAG,
    SUBSCRIBE_TO_FLAG,
    DOC_TYPE_CODE,
    DOC_SUB_TYPE_CODE,
    OPERATOR_CODE,
    PRODUCT_TYPE_CODE,
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
    OBJECT_VERSION_NUMBER,
    DOCUMENT_ID,
    SOURCE_PARTY_ID,
    DOCUMENT_NO,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_SUBSCRIBE_AVAIL_FLAG,
    X_SUBSCRIBE_TO_FLAG,
    X_DOC_TYPE_CODE,
    X_DOC_SUB_TYPE_CODE,
    X_OPERATOR_CODE,
    X_PRODUCT_TYPE_CODE,
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
    X_OBJECT_VERSION_NUMBER,
    X_DOCUMENT_ID,
    X_SOURCE_PARTY_ID,
    X_DOCUMENT_NO,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AHL_DOCUMENTS_TL (
    CREATED_BY,
    CREATION_DATE,
    DOCUMENT_TITLE,
    LAST_UPDATED_BY,
    DOCUMENT_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREATED_BY,
    X_CREATION_DATE,
    X_DOCUMENT_TITLE,
    X_LAST_UPDATED_BY,
    X_DOCUMENT_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AHL_DOCUMENTS_TL T
    where T.DOCUMENT_ID = X_DOCUMENT_ID
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
  X_DOCUMENT_ID in NUMBER,
  X_SUBSCRIBE_AVAIL_FLAG in VARCHAR2,
  X_SUBSCRIBE_TO_FLAG in VARCHAR2,
  X_DOC_TYPE_CODE in VARCHAR2,
  X_DOC_SUB_TYPE_CODE in VARCHAR2,
  X_OPERATOR_CODE in VARCHAR2,
  X_PRODUCT_TYPE_CODE in VARCHAR2,
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
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SOURCE_PARTY_ID in NUMBER,
  X_DOCUMENT_NO in VARCHAR2,
  X_DOCUMENT_TITLE in VARCHAR2
) is
  cursor c is select
      SUBSCRIBE_AVAIL_FLAG,
      SUBSCRIBE_TO_FLAG,
      DOC_TYPE_CODE,
      DOC_SUB_TYPE_CODE,
      OPERATOR_CODE,
      PRODUCT_TYPE_CODE,
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
      OBJECT_VERSION_NUMBER,
      SOURCE_PARTY_ID,
      DOCUMENT_NO
    from AHL_DOCUMENTS_B
    where DOCUMENT_ID = X_DOCUMENT_ID
    for update of DOCUMENT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DOCUMENT_TITLE,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AHL_DOCUMENTS_TL
    where DOCUMENT_ID = X_DOCUMENT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DOCUMENT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.SUBSCRIBE_AVAIL_FLAG = X_SUBSCRIBE_AVAIL_FLAG)
      AND (recinfo.SUBSCRIBE_TO_FLAG = X_SUBSCRIBE_TO_FLAG)
      AND (recinfo.DOC_TYPE_CODE = X_DOC_TYPE_CODE)
      AND ((recinfo.DOC_SUB_TYPE_CODE = X_DOC_SUB_TYPE_CODE)
           OR ((recinfo.DOC_SUB_TYPE_CODE is null) AND (X_DOC_SUB_TYPE_CODE is null)))
      AND ((recinfo.OPERATOR_CODE = X_OPERATOR_CODE)
           OR ((recinfo.OPERATOR_CODE is null) AND (X_OPERATOR_CODE is null)))
      AND ((recinfo.PRODUCT_TYPE_CODE = X_PRODUCT_TYPE_CODE)
           OR ((recinfo.PRODUCT_TYPE_CODE is null) AND (X_PRODUCT_TYPE_CODE is null)))
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
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.SOURCE_PARTY_ID = X_SOURCE_PARTY_ID)
      AND (recinfo.DOCUMENT_NO = X_DOCUMENT_NO)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DOCUMENT_TITLE = X_DOCUMENT_TITLE)
               OR ((tlinfo.DOCUMENT_TITLE is null) AND (X_DOCUMENT_TITLE is null)))
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
  X_DOCUMENT_ID in NUMBER,
  X_SUBSCRIBE_AVAIL_FLAG in VARCHAR2,
  X_SUBSCRIBE_TO_FLAG in VARCHAR2,
  X_DOC_TYPE_CODE in VARCHAR2,
  X_DOC_SUB_TYPE_CODE in VARCHAR2,
  X_OPERATOR_CODE in VARCHAR2,
  X_PRODUCT_TYPE_CODE in VARCHAR2,
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
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SOURCE_PARTY_ID in NUMBER,
  X_DOCUMENT_NO in VARCHAR2,
  X_DOCUMENT_TITLE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AHL_DOCUMENTS_B set
    SUBSCRIBE_AVAIL_FLAG = X_SUBSCRIBE_AVAIL_FLAG,
    SUBSCRIBE_TO_FLAG = X_SUBSCRIBE_TO_FLAG,
    DOC_TYPE_CODE = X_DOC_TYPE_CODE,
    DOC_SUB_TYPE_CODE = X_DOC_SUB_TYPE_CODE,
    OPERATOR_CODE = X_OPERATOR_CODE,
    PRODUCT_TYPE_CODE = X_PRODUCT_TYPE_CODE,
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
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    SOURCE_PARTY_ID = X_SOURCE_PARTY_ID,
    DOCUMENT_NO = X_DOCUMENT_NO,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where DOCUMENT_ID = X_DOCUMENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AHL_DOCUMENTS_TL set
    DOCUMENT_TITLE = X_DOCUMENT_TITLE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DOCUMENT_ID = X_DOCUMENT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DOCUMENT_ID in NUMBER
) is
begin
  delete from AHL_DOCUMENTS_TL
  where DOCUMENT_ID = X_DOCUMENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AHL_DOCUMENTS_B
  where DOCUMENT_ID = X_DOCUMENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AHL_DOCUMENTS_TL T
  where not exists
    (select NULL
    from AHL_DOCUMENTS_B B
    where B.DOCUMENT_ID = T.DOCUMENT_ID
    );

  update AHL_DOCUMENTS_TL T set (
      DOCUMENT_TITLE
    ) = (select
      B.DOCUMENT_TITLE
    from AHL_DOCUMENTS_TL B
    where B.DOCUMENT_ID = T.DOCUMENT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DOCUMENT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DOCUMENT_ID,
      SUBT.LANGUAGE
    from AHL_DOCUMENTS_TL SUBB, AHL_DOCUMENTS_TL SUBT
    where SUBB.DOCUMENT_ID = SUBT.DOCUMENT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DOCUMENT_TITLE <> SUBT.DOCUMENT_TITLE
      or (SUBB.DOCUMENT_TITLE is null and SUBT.DOCUMENT_TITLE is not null)
      or (SUBB.DOCUMENT_TITLE is not null and SUBT.DOCUMENT_TITLE is null)
  ));

  insert into AHL_DOCUMENTS_TL (
    CREATED_BY,
    CREATION_DATE,
    DOCUMENT_TITLE,
    LAST_UPDATED_BY,
    DOCUMENT_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CREATED_BY,
    B.CREATION_DATE,
    B.DOCUMENT_TITLE,
    B.LAST_UPDATED_BY,
    B.DOCUMENT_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AHL_DOCUMENTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AHL_DOCUMENTS_TL T
    where T.DOCUMENT_ID = B.DOCUMENT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
X_DOCUMENT_NO                  in VARCHAR2,
X_SOURCE_PARTY_ID              in NUMBER,
X_SUBSCRIBE_AVAIL_FLAG         in VARCHAR2,
X_SUBSCRIBE_TO_FLAG            in VARCHAR2,
X_DOC_TYPE_CODE                in VARCHAR2,
X_DOC_SUB_TYPE_CODE            in VARCHAR2,
X_OPERATOR_CODE                in VARCHAR2,
X_PRODUCT_TYPE_CODE            in VARCHAR2,
X_OBJECT_VERSION_NUMBER        in NUMBER,
X_ATTRIBUTE_CATEGORY           in VARCHAR2,
X_ATTRIBUTE1                   in VARCHAR2,
X_ATTRIBUTE2                   in VARCHAR2,
X_ATTRIBUTE3                   in VARCHAR2,
X_ATTRIBUTE4                   in VARCHAR2,
X_ATTRIBUTE5                   in VARCHAR2,
X_ATTRIBUTE6                   in VARCHAR2,
X_ATTRIBUTE7                   in VARCHAR2,
X_ATTRIBUTE8                   in VARCHAR2,
X_ATTRIBUTE9                   in VARCHAR2,
X_ATTRIBUTE10                  in VARCHAR2,
X_ATTRIBUTE11                  in VARCHAR2,
X_ATTRIBUTE12                  in VARCHAR2,
X_ATTRIBUTE13                  in VARCHAR2,
X_ATTRIBUTE14                  in VARCHAR2,
X_ATTRIBUTE15                  in VARCHAR2,
X_DOCUMENT_TITLE               in VARCHAR2,
X_OWNER                        in VARCHAR2
) is
 user_id number := 0;
 doc_id  number;
 row_id  varchar2(64);
begin
  if (X_OWNER = 'SEED') then
    user_id := 1;
  end if;

  select document_id into doc_id
  from   ahl_documents_b
  where  document_no = X_DOCUMENT_NO;

AHL_DOCUMENTS_PKG.UPDATE_ROW (
  X_DOCUMENT_ID                    => doc_id,
  X_SUBSCRIBE_AVAIL_FLAG 	   => X_SUBSCRIBE_AVAIL_FLAG,
  X_SUBSCRIBE_TO_FLAG              => X_SUBSCRIBE_TO_FLAG,
  X_DOC_TYPE_CODE                  => X_DOC_TYPE_CODE,
  X_DOC_SUB_TYPE_CODE              => X_DOC_SUB_TYPE_CODE,
  X_OPERATOR_CODE                  => X_OPERATOR_CODE,
  X_PRODUCT_TYPE_CODE		   => X_PRODUCT_TYPE_CODE,
  X_ATTRIBUTE_CATEGORY             => X_ATTRIBUTE_CATEGORY,
  X_ATTRIBUTE1			   => X_ATTRIBUTE1,
  X_ATTRIBUTE2                     => X_ATTRIBUTE2,
  X_ATTRIBUTE3 			   => X_ATTRIBUTE3,
  X_ATTRIBUTE4 			   => X_ATTRIBUTE4,
  X_ATTRIBUTE5 			   => X_ATTRIBUTE5,
  X_ATTRIBUTE6 			   => X_ATTRIBUTE6,
  X_ATTRIBUTE7 			   => X_ATTRIBUTE7,
  X_ATTRIBUTE8 			   => X_ATTRIBUTE8,
  X_ATTRIBUTE9 			   => X_ATTRIBUTE9,
  X_ATTRIBUTE10 		   => X_ATTRIBUTE10,
  X_ATTRIBUTE11 		   => X_ATTRIBUTE11,
  X_ATTRIBUTE12 		   => X_ATTRIBUTE12,
  X_ATTRIBUTE13 		   => X_ATTRIBUTE13,
  X_ATTRIBUTE14 		   => X_ATTRIBUTE14,
  X_ATTRIBUTE15 		   => X_ATTRIBUTE15,
  X_OBJECT_VERSION_NUMBER          => X_OBJECT_VERSION_NUMBER+1,
  X_SOURCE_PARTY_ID 		   => X_SOURCE_PARTY_ID,
  X_DOCUMENT_NO 		   => X_DOCUMENT_NO,
  X_DOCUMENT_TITLE                 => X_DOCUMENT_TITLE,
  X_LAST_UPDATE_DATE 		   => sysdate,
  X_LAST_UPDATED_BY 		   => user_id,
  X_LAST_UPDATE_LOGIN 	           => 0
);

exception
  when NO_DATA_FOUND then

 SELECT  AHL_DOCUMENTS_B_S.Nextval INTO
           doc_id from DUAL;

AHL_DOCUMENTS_PKG.INSERT_ROW (
  X_ROWID                          => row_id,
  X_DOCUMENT_ID                    => doc_id,
  X_SUBSCRIBE_AVAIL_FLAG           => X_SUBSCRIBE_AVAIL_FLAG,
  X_SUBSCRIBE_TO_FLAG              => X_SUBSCRIBE_TO_FLAG,
  X_DOC_TYPE_CODE                  => X_DOC_TYPE_CODE,
  X_DOC_SUB_TYPE_CODE              => X_DOC_SUB_TYPE_CODE,
  X_OPERATOR_CODE                  => X_OPERATOR_CODE,
  X_PRODUCT_TYPE_CODE              => X_PRODUCT_TYPE_CODE,
  X_ATTRIBUTE_CATEGORY             => X_ATTRIBUTE_CATEGORY,
  X_ATTRIBUTE1                     => X_ATTRIBUTE1,
  X_ATTRIBUTE2                     => X_ATTRIBUTE2,
  X_ATTRIBUTE3                     => X_ATTRIBUTE3,
  X_ATTRIBUTE4                     => X_ATTRIBUTE4,
  X_ATTRIBUTE5                     => X_ATTRIBUTE5,
  X_ATTRIBUTE6                     => X_ATTRIBUTE6,
  X_ATTRIBUTE7                     => X_ATTRIBUTE7,
  X_ATTRIBUTE8                     => X_ATTRIBUTE8,
  X_ATTRIBUTE9                     => X_ATTRIBUTE9,
  X_ATTRIBUTE10                    => X_ATTRIBUTE10,
  X_ATTRIBUTE11                    => X_ATTRIBUTE11,
  X_ATTRIBUTE12                    => X_ATTRIBUTE12,
  X_ATTRIBUTE13                    => X_ATTRIBUTE13,
  X_ATTRIBUTE14                    => X_ATTRIBUTE14,
  X_ATTRIBUTE15                    => X_ATTRIBUTE15,
  X_OBJECT_VERSION_NUMBER          => 1,
  X_SOURCE_PARTY_ID                => X_SOURCE_PARTY_ID,
  X_DOCUMENT_NO                    => X_DOCUMENT_NO,
  X_DOCUMENT_TITLE                 => X_DOCUMENT_TITLE,
  X_CREATION_DATE                  => sysdate,
  X_CREATED_BY                     => user_id,
  X_LAST_UPDATE_DATE               => sysdate,
  X_LAST_UPDATED_BY                => user_id,
  X_LAST_UPDATE_LOGIN              => 0
);
end LOAD_ROW;

procedure TRANSLATE_ROW (
X_DOCUMENT_NO                  in VARCHAR2,
X_DOCUMENT_TITLE               in VARCHAR2,
X_OWNER                        in VARCHAR2
) is
begin
update AHl_DOCUMENTS_TL set
 document_title     = nvl(X_DOCUMENT_TITLE, document_title),
 source_lang       = userenv('LANG'),
 last_update_date  = sysdate,
 last_updated_by   = decode(X_OWNER, 'SEED', 1, 0),
 last_update_login = 0
where document_id =
	(select document_id
         from ahl_documents_b
         where document_no = X_DOCUMENT_NO)
and userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

end AHL_DOCUMENTS_PKG;

/
