--------------------------------------------------------
--  DDL for Package Body AHL_DOC_REVISIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DOC_REVISIONS_PKG" as
/* $Header: AHLLDORB.pls 115.5 2002/12/04 08:23:07 pbarman noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DOC_REVISION_ID in NUMBER,
  X_APPROVED_DATE in DATE,
  X_EFFECTIVE_DATE in DATE,
  X_OBSOLETE_DATE in DATE,
  X_ISSUE_DATE in DATE,
  X_RECEIVED_DATE in DATE,
  X_URL in VARCHAR2,
  X_MEDIA_TYPE_CODE in VARCHAR2,
  X_VOLUME in VARCHAR2,
  X_ISSUE in VARCHAR2,
  X_ISSUE_NUMBER in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_REVISION_DATE in DATE,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_DOCUMENT_ID in NUMBER,
  X_REVISION_NO in VARCHAR2,
  X_APPROVED_BY_PARTY_ID in NUMBER,
  X_REVISION_TYPE_CODE in VARCHAR2,
  X_REVISION_STATUS_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AHL_DOC_REVISIONS_B
    where DOC_REVISION_ID = X_DOC_REVISION_ID
    ;
begin
  insert into AHL_DOC_REVISIONS_B (
    APPROVED_DATE,
    EFFECTIVE_DATE,
    OBSOLETE_DATE,
    ISSUE_DATE,
    RECEIVED_DATE,
    URL,
    MEDIA_TYPE_CODE,
    VOLUME,
    ISSUE,
    ISSUE_NUMBER,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    REVISION_DATE,
    ATTRIBUTE15,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    DOCUMENT_ID,
    REVISION_NO,
    APPROVED_BY_PARTY_ID,
    REVISION_TYPE_CODE,
    REVISION_STATUS_CODE,
    OBJECT_VERSION_NUMBER,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE14,
    DOC_REVISION_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPROVED_DATE,
    X_EFFECTIVE_DATE,
    X_OBSOLETE_DATE,
    X_ISSUE_DATE,
    X_RECEIVED_DATE,
    X_URL,
    X_MEDIA_TYPE_CODE,
    X_VOLUME,
    X_ISSUE,
    X_ISSUE_NUMBER,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_REVISION_DATE,
    X_ATTRIBUTE15,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_DOCUMENT_ID,
    X_REVISION_NO,
    X_APPROVED_BY_PARTY_ID,
    X_REVISION_TYPE_CODE,
    X_REVISION_STATUS_CODE,
    X_OBJECT_VERSION_NUMBER,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE14,
    X_DOC_REVISION_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AHL_DOC_REVISIONS_TL (
    LAST_UPDATE_LOGIN,
    COMMENTS,
    CREATION_DATE,
    CREATED_BY,
    DOC_REVISION_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_LOGIN,
    X_COMMENTS,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_DOC_REVISION_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AHL_DOC_REVISIONS_TL T
    where T.DOC_REVISION_ID = X_DOC_REVISION_ID
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
  X_DOC_REVISION_ID in NUMBER,
  X_APPROVED_DATE in DATE,
  X_EFFECTIVE_DATE in DATE,
  X_OBSOLETE_DATE in DATE,
  X_ISSUE_DATE in DATE,
  X_RECEIVED_DATE in DATE,
  X_URL in VARCHAR2,
  X_MEDIA_TYPE_CODE in VARCHAR2,
  X_VOLUME in VARCHAR2,
  X_ISSUE in VARCHAR2,
  X_ISSUE_NUMBER in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_REVISION_DATE in DATE,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_DOCUMENT_ID in NUMBER,
  X_REVISION_NO in VARCHAR2,
  X_APPROVED_BY_PARTY_ID in NUMBER,
  X_REVISION_TYPE_CODE in VARCHAR2,
  X_REVISION_STATUS_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_COMMENTS in VARCHAR2
) is
  cursor c is select
      APPROVED_DATE,
      EFFECTIVE_DATE,
      OBSOLETE_DATE,
      ISSUE_DATE,
      RECEIVED_DATE,
      URL,
      MEDIA_TYPE_CODE,
      VOLUME,
      ISSUE,
      ISSUE_NUMBER,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      REVISION_DATE,
      ATTRIBUTE15,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      DOCUMENT_ID,
      REVISION_NO,
      APPROVED_BY_PARTY_ID,
      REVISION_TYPE_CODE,
      REVISION_STATUS_CODE,
      OBJECT_VERSION_NUMBER,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE14
    from AHL_DOC_REVISIONS_B
    where DOC_REVISION_ID = X_DOC_REVISION_ID
    for update of DOC_REVISION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      COMMENTS,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AHL_DOC_REVISIONS_TL
    where DOC_REVISION_ID = X_DOC_REVISION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DOC_REVISION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.APPROVED_DATE = X_APPROVED_DATE)
           OR ((recinfo.APPROVED_DATE is null) AND (X_APPROVED_DATE is null)))
      AND ((recinfo.EFFECTIVE_DATE = X_EFFECTIVE_DATE)
           OR ((recinfo.EFFECTIVE_DATE is null) AND (X_EFFECTIVE_DATE is null)))
      AND ((recinfo.OBSOLETE_DATE = X_OBSOLETE_DATE)
           OR ((recinfo.OBSOLETE_DATE is null) AND (X_OBSOLETE_DATE is null)))
      AND ((recinfo.ISSUE_DATE = X_ISSUE_DATE)
           OR ((recinfo.ISSUE_DATE is null) AND (X_ISSUE_DATE is null)))
      AND ((recinfo.RECEIVED_DATE = X_RECEIVED_DATE)
           OR ((recinfo.RECEIVED_DATE is null) AND (X_RECEIVED_DATE is null)))
      AND ((recinfo.URL = X_URL)
           OR ((recinfo.URL is null) AND (X_URL is null)))
      AND ((recinfo.MEDIA_TYPE_CODE = X_MEDIA_TYPE_CODE)
           OR ((recinfo.MEDIA_TYPE_CODE is null) AND (X_MEDIA_TYPE_CODE is null)))
      AND ((recinfo.VOLUME = X_VOLUME)
           OR ((recinfo.VOLUME is null) AND (X_VOLUME is null)))
      AND ((recinfo.ISSUE = X_ISSUE)
           OR ((recinfo.ISSUE is null) AND (X_ISSUE is null)))
      AND ((recinfo.ISSUE_NUMBER = X_ISSUE_NUMBER)
           OR ((recinfo.ISSUE_NUMBER is null) AND (X_ISSUE_NUMBER is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.REVISION_DATE = X_REVISION_DATE)
           OR ((recinfo.REVISION_DATE is null) AND (X_REVISION_DATE is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
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
      AND (recinfo.DOCUMENT_ID = X_DOCUMENT_ID)
      AND (recinfo.REVISION_NO = X_REVISION_NO)
      AND ((recinfo.APPROVED_BY_PARTY_ID = X_APPROVED_BY_PARTY_ID)
           OR ((recinfo.APPROVED_BY_PARTY_ID is null) AND (X_APPROVED_BY_PARTY_ID is null)))
      AND (recinfo.REVISION_TYPE_CODE = X_REVISION_TYPE_CODE)
      AND (recinfo.REVISION_STATUS_CODE = X_REVISION_STATUS_CODE)
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
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
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.COMMENTS = X_COMMENTS)
               OR ((tlinfo.COMMENTS is null) AND (X_COMMENTS is null)))
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
  X_DOC_REVISION_ID in NUMBER,
  X_APPROVED_DATE in DATE,
  X_EFFECTIVE_DATE in DATE,
  X_OBSOLETE_DATE in DATE,
  X_ISSUE_DATE in DATE,
  X_RECEIVED_DATE in DATE,
  X_URL in VARCHAR2,
  X_MEDIA_TYPE_CODE in VARCHAR2,
  X_VOLUME in VARCHAR2,
  X_ISSUE in VARCHAR2,
  X_ISSUE_NUMBER in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_REVISION_DATE in DATE,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_DOCUMENT_ID in NUMBER,
  X_REVISION_NO in VARCHAR2,
  X_APPROVED_BY_PARTY_ID in NUMBER,
  X_REVISION_TYPE_CODE in VARCHAR2,
  X_REVISION_STATUS_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AHL_DOC_REVISIONS_B set
    APPROVED_DATE = X_APPROVED_DATE,
    EFFECTIVE_DATE = X_EFFECTIVE_DATE,
    OBSOLETE_DATE = X_OBSOLETE_DATE,
    ISSUE_DATE = X_ISSUE_DATE,
    RECEIVED_DATE = X_RECEIVED_DATE,
    URL = X_URL,
    MEDIA_TYPE_CODE = X_MEDIA_TYPE_CODE,
    VOLUME = X_VOLUME,
    ISSUE = X_ISSUE,
    ISSUE_NUMBER = X_ISSUE_NUMBER,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    REVISION_DATE = X_REVISION_DATE,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    DOCUMENT_ID = X_DOCUMENT_ID,
    REVISION_NO = X_REVISION_NO,
    APPROVED_BY_PARTY_ID = X_APPROVED_BY_PARTY_ID,
    REVISION_TYPE_CODE = X_REVISION_TYPE_CODE,
    REVISION_STATUS_CODE = X_REVISION_STATUS_CODE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where DOC_REVISION_ID = X_DOC_REVISION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AHL_DOC_REVISIONS_TL set
    COMMENTS = X_COMMENTS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DOC_REVISION_ID = X_DOC_REVISION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DOC_REVISION_ID in NUMBER
) is
begin
  delete from AHL_DOC_REVISIONS_TL
  where DOC_REVISION_ID = X_DOC_REVISION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AHL_DOC_REVISIONS_B
  where DOC_REVISION_ID = X_DOC_REVISION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AHL_DOC_REVISIONS_TL T
  where not exists
    (select NULL
    from AHL_DOC_REVISIONS_B B
    where B.DOC_REVISION_ID = T.DOC_REVISION_ID
    );

  update AHL_DOC_REVISIONS_TL T set (
      COMMENTS
    ) = (select
      B.COMMENTS
    from AHL_DOC_REVISIONS_TL B
    where B.DOC_REVISION_ID = T.DOC_REVISION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DOC_REVISION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DOC_REVISION_ID,
      SUBT.LANGUAGE
    from AHL_DOC_REVISIONS_TL SUBB, AHL_DOC_REVISIONS_TL SUBT
    where SUBB.DOC_REVISION_ID = SUBT.DOC_REVISION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.COMMENTS <> SUBT.COMMENTS
      or (SUBB.COMMENTS is null and SUBT.COMMENTS is not null)
      or (SUBB.COMMENTS is not null and SUBT.COMMENTS is null)
  ));

  insert into AHL_DOC_REVISIONS_TL (
    LAST_UPDATE_LOGIN,
    COMMENTS,
    CREATION_DATE,
    CREATED_BY,
    DOC_REVISION_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.LAST_UPDATE_LOGIN,
    B.COMMENTS,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.DOC_REVISION_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AHL_DOC_REVISIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AHL_DOC_REVISIONS_TL T
    where T.DOC_REVISION_ID = B.DOC_REVISION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_DOC_REVISION_ID        in NUMBER,
  X_APPROVED_DATE          in DATE,
  X_EFFECTIVE_DATE         in DATE,
  X_OBSOLETE_DATE          in DATE,
  X_ISSUE_DATE             in DATE,
  X_RECEIVED_DATE          in DATE,
  X_URL                    in VARCHAR2,
  X_MEDIA_TYPE_CODE        in VARCHAR2,
  X_VOLUME                 in VARCHAR2,
  X_ISSUE                  in VARCHAR2,
  X_ISSUE_NUMBER           in NUMBER,
  X_REVISION_DATE          in DATE,
  X_DOCUMENT_ID            in NUMBER,
  X_REVISION_NO            in VARCHAR2,
  X_APPROVED_BY_PARTY_ID   in NUMBER,
  X_REVISION_TYPE_CODE     in VARCHAR2,
  X_REVISION_STATUS_CODE   in VARCHAR2,
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
  X_COMMENTS               in VARCHAR2,
  X_OWNER                  in VARCHAR2
) is
 user_id number := 0;
 doc_revision_id  number;
 row_id  varchar2(64);
begin
  if (X_OWNER = 'SEED') then
    user_id := 1;
  end if;

  select doc_revision_id into doc_revision_id
  from   ahl_doc_revisions_b
  where  doc_revision_id = X_DOC_REVISION_ID;

AHL_DOC_REVISIONS_PKG.UPDATE_ROW (

  X_DOC_REVISION_ID       => doc_revision_id,
  X_APPROVED_DATE         => X_APPROVED_DATE,
  X_EFFECTIVE_DATE        => X_EFFECTIVE_DATE,
  X_OBSOLETE_DATE         => X_OBSOLETE_DATE,
  X_ISSUE_DATE            => X_ISSUE_DATE,
  X_RECEIVED_DATE         => X_RECEIVED_DATE,
  X_URL                   => X_URL,
  X_MEDIA_TYPE_CODE       => X_MEDIA_TYPE_CODE,
  X_VOLUME                => X_VOLUME,
  X_ISSUE                 => X_ISSUE,
  X_ISSUE_NUMBER          => X_ISSUE_NUMBER,
  X_ATTRIBUTE_CATEGORY    =>X_ATTRIBUTE_CATEGORY,
  X_ATTRIBUTE1            =>X_ATTRIBUTE1,
  X_ATTRIBUTE2            =>X_ATTRIBUTE2,
  X_REVISION_DATE         =>X_REVISION_DATE,
  X_ATTRIBUTE15           =>X_ATTRIBUTE15,
  X_ATTRIBUTE9            =>X_ATTRIBUTE9,
  X_ATTRIBUTE10           => X_ATTRIBUTE10,
  X_ATTRIBUTE11           => X_ATTRIBUTE11,
  X_ATTRIBUTE12           => X_ATTRIBUTE12,
  X_ATTRIBUTE13           => X_ATTRIBUTE13,
  X_DOCUMENT_ID           => X_DOCUMENT_ID,
  X_REVISION_NO           => X_REVISION_NO,
  X_APPROVED_BY_PARTY_ID  => X_APPROVED_BY_PARTY_ID,
  X_REVISION_TYPE_CODE    => X_REVISION_TYPE_CODE,
  X_REVISION_STATUS_CODE  => X_REVISION_STATUS_CODE,
  X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
  X_ATTRIBUTE3            => X_ATTRIBUTE3,
  X_ATTRIBUTE4            => X_ATTRIBUTE4,
  X_ATTRIBUTE5            => X_ATTRIBUTE5,
  X_ATTRIBUTE6            => X_ATTRIBUTE6,
  X_ATTRIBUTE7            => X_ATTRIBUTE7,
  X_ATTRIBUTE8            => X_ATTRIBUTE8,
  X_ATTRIBUTE14           => X_ATTRIBUTE14,
  X_COMMENTS              => X_COMMENTS,
  X_LAST_UPDATE_DATE      => sysdate,
  X_LAST_UPDATED_BY       => user_id,
  X_LAST_UPDATE_LOGIN 	  => 0
);

exception
  when NO_DATA_FOUND then

 SELECT  AHL_DOC_REVISIONS_B_S.Nextval INTO
           doc_revision_id from DUAL;

AHL_DOC_REVISIONS_PKG.INSERT_ROW (
  X_ROWID                 => row_id,
  X_DOC_REVISION_ID       => doc_revision_id,
  X_APPROVED_DATE         => X_APPROVED_DATE,
  X_EFFECTIVE_DATE        => X_EFFECTIVE_DATE,
  X_OBSOLETE_DATE         => X_OBSOLETE_DATE,
  X_ISSUE_DATE            => X_ISSUE_DATE,
  X_RECEIVED_DATE         => X_RECEIVED_DATE,
  X_URL                   => X_URL,
  X_MEDIA_TYPE_CODE       => X_MEDIA_TYPE_CODE,
  X_VOLUME                => X_VOLUME,
  X_ISSUE                 => X_ISSUE,
  X_ISSUE_NUMBER          => X_ISSUE_NUMBER,
  X_ATTRIBUTE_CATEGORY    =>X_ATTRIBUTE_CATEGORY,
  X_ATTRIBUTE1            =>X_ATTRIBUTE1,
  X_ATTRIBUTE2            =>X_ATTRIBUTE2,
  X_REVISION_DATE         =>X_REVISION_DATE,
  X_ATTRIBUTE15           =>X_ATTRIBUTE15,
  X_ATTRIBUTE9            =>X_ATTRIBUTE9,
  X_ATTRIBUTE10           => X_ATTRIBUTE10,
  X_ATTRIBUTE11           => X_ATTRIBUTE11,
  X_ATTRIBUTE12           => X_ATTRIBUTE12,
  X_ATTRIBUTE13           => X_ATTRIBUTE13,
  X_DOCUMENT_ID           => X_DOCUMENT_ID,
  X_REVISION_NO           => X_REVISION_NO,
  X_APPROVED_BY_PARTY_ID  => X_APPROVED_BY_PARTY_ID,
  X_REVISION_TYPE_CODE    => X_REVISION_TYPE_CODE,
  X_REVISION_STATUS_CODE  => X_REVISION_STATUS_CODE,
  X_OBJECT_VERSION_NUMBER => 1,
  X_ATTRIBUTE3            => X_ATTRIBUTE3,
  X_ATTRIBUTE4            => X_ATTRIBUTE4,
  X_ATTRIBUTE5            => X_ATTRIBUTE5,
  X_ATTRIBUTE6            => X_ATTRIBUTE6,
  X_ATTRIBUTE7            => X_ATTRIBUTE7,
  X_ATTRIBUTE8            => X_ATTRIBUTE8,
  X_ATTRIBUTE14           => X_ATTRIBUTE14,
  X_COMMENTS              => X_COMMENTS,
  X_CREATION_DATE         => sysdate,
  X_CREATED_BY            => user_id,
  X_LAST_UPDATE_DATE      => sysdate,
  X_LAST_UPDATED_BY       => user_id,
  X_LAST_UPDATE_LOGIN     => 0
);
end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_DOC_REVISION_ID        in NUMBER,
  X_COMMENTS               in VARCHAR2,
  X_OWNER                  in VARCHAR2
) is
begin
update AHl_DOC_REVISIONS_TL set
 comments          = nvl(X_COMMENTS, comments),
 source_lang       = userenv('LANG'),
 last_update_date  = sysdate,
 last_updated_by   = decode(X_OWNER, 'SEED', 1, 0),
 last_update_login = 0
where doc_revision_id =
	(select doc_revision_id
         from ahl_doc_revisions_b
         where doc_revision_id = X_DOC_REVISION_ID)
and userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

end AHL_DOC_REVISIONS_PKG;

/