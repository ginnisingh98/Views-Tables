--------------------------------------------------------
--  DDL for Package Body DOM_DOCUMENT_REVISIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DOM_DOCUMENT_REVISIONS_PKG" as
 /* $Header: DOMREVB.pls 120.2 2006/03/24 17:32:26 dedatta noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_DOCUMENT_ID in NUMBER,
  X_REVISION_ID in NUMBER,
  X_CATEGORY_ID in NUMBER,
  X_REVISION in VARCHAR2,
  X_CHECKOUT_STATUS in VARCHAR2,
  X_CHECKED_OUT_BY in NUMBER,
  X_CREATION_REASON in VARCHAR2,
  X_LIFECYCLE_PHASE_ID in NUMBER,
  X_LIFECYCLE_TRACKING_ID in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from DOM_DOCUMENT_REVISIONS
    where DOCUMENT_ID = X_DOCUMENT_ID
    and REVISION_ID = X_REVISION_ID
    ;
begin
  insert into DOM_DOCUMENT_REVISIONS (
    CATEGORY_ID,
    DOCUMENT_ID,
    REVISION_ID,
    REVISION,
    CHECKOUT_STATUS,
    CHECKED_OUT_BY,
    CREATION_REASON,
    LIFECYCLE_PHASE_ID,
    LIFECYCLE_TRACKING_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_CATEGORY_ID,
    X_DOCUMENT_ID,
    X_REVISION_ID,
    X_REVISION,
    X_CHECKOUT_STATUS,
    X_CHECKED_OUT_BY,
    X_CREATION_REASON,
    X_LIFECYCLE_PHASE_ID,
    X_LIFECYCLE_TRACKING_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into DOM_DOCUMENT_REVISIONS_TL (
    DOCUMENT_ID,
    CATEGORY_ID,
    REVISION_ID,
    COMMENTS,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DOCUMENT_ID,
    X_CATEGORY_ID,
    X_REVISION_ID,
    X_COMMENTS,
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
    from DOM_DOCUMENT_REVISIONS_TL T
    where T.DOCUMENT_ID = X_DOCUMENT_ID
    and T.REVISION_ID = X_REVISION_ID
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
  X_REVISION_ID in NUMBER,
  X_CATEGORY_ID in NUMBER,
  X_REVISION in VARCHAR2,
  X_CHECKOUT_STATUS in VARCHAR2,
  X_CHECKED_OUT_BY in NUMBER,
  X_CREATION_REASON in VARCHAR2,
  X_LIFECYCLE_PHASE_ID in NUMBER,
  X_LIFECYCLE_TRACKING_ID in NUMBER,
  X_COMMENTS in VARCHAR2
) is
  cursor c is select
      CATEGORY_ID,
      REVISION,
      CHECKOUT_STATUS,
      CHECKED_OUT_BY,
      CREATION_REASON,
      LIFECYCLE_PHASE_ID,
      LIFECYCLE_TRACKING_ID
    from DOM_DOCUMENT_REVISIONS
    where DOCUMENT_ID = X_DOCUMENT_ID
    and REVISION_ID = X_REVISION_ID
    for update of DOCUMENT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      COMMENTS,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from DOM_DOCUMENT_REVISIONS_TL
    where DOCUMENT_ID = X_DOCUMENT_ID
    and REVISION_ID = X_REVISION_ID
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
  if (    ((recinfo.CATEGORY_ID = X_CATEGORY_ID)
           OR ((recinfo.CATEGORY_ID is null) AND (X_CATEGORY_ID is null)))
      AND ((recinfo.REVISION = X_REVISION)
           OR ((recinfo.REVISION is null) AND (X_REVISION is null)))
      AND ((recinfo.CHECKOUT_STATUS = X_CHECKOUT_STATUS)
           OR ((recinfo.CHECKOUT_STATUS is null) AND (X_CHECKOUT_STATUS is null)))
      AND ((recinfo.CHECKED_OUT_BY = X_CHECKED_OUT_BY)
           OR ((recinfo.CHECKED_OUT_BY is null) AND (X_CHECKED_OUT_BY is null)))
      AND ((recinfo.CREATION_REASON = X_CREATION_REASON)
           OR ((recinfo.CREATION_REASON is null) AND (X_CREATION_REASON is null)))
      AND ((recinfo.LIFECYCLE_PHASE_ID = X_LIFECYCLE_PHASE_ID)
           OR ((recinfo.LIFECYCLE_PHASE_ID is null) AND (X_LIFECYCLE_PHASE_ID is null)))
      AND ((recinfo.LIFECYCLE_TRACKING_ID = X_LIFECYCLE_TRACKING_ID)
           OR ((recinfo.LIFECYCLE_TRACKING_ID is null) AND (X_LIFECYCLE_TRACKING_ID is null)))
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
  X_DOCUMENT_ID in NUMBER,
  X_REVISION_ID in NUMBER,
  X_CATEGORY_ID in NUMBER,
  X_REVISION in VARCHAR2,
  X_CHECKOUT_STATUS in VARCHAR2,
  X_CHECKED_OUT_BY in NUMBER,
  X_CREATION_REASON in VARCHAR2,
  X_LIFECYCLE_PHASE_ID in NUMBER,
  X_LIFECYCLE_TRACKING_ID in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update DOM_DOCUMENT_REVISIONS set
    CATEGORY_ID = X_CATEGORY_ID,
    REVISION = X_REVISION,
    CHECKOUT_STATUS = X_CHECKOUT_STATUS,
    CHECKED_OUT_BY = X_CHECKED_OUT_BY,
    CREATION_REASON = X_CREATION_REASON,
    LIFECYCLE_PHASE_ID = X_LIFECYCLE_PHASE_ID,
    LIFECYCLE_TRACKING_ID = X_LIFECYCLE_TRACKING_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where DOCUMENT_ID = X_DOCUMENT_ID
  and REVISION_ID = X_REVISION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update DOM_DOCUMENT_REVISIONS_TL set
    COMMENTS = X_COMMENTS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DOCUMENT_ID = X_DOCUMENT_ID
  and REVISION_ID = X_REVISION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DOCUMENT_ID in NUMBER,
  X_REVISION_ID in NUMBER
) is
begin
  delete from DOM_DOCUMENT_REVISIONS_TL
  where DOCUMENT_ID = X_DOCUMENT_ID
  and REVISION_ID = X_REVISION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from DOM_DOCUMENT_REVISIONS
  where DOCUMENT_ID = X_DOCUMENT_ID
  and REVISION_ID = X_REVISION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from DOM_DOCUMENT_REVISIONS_TL T
  where not exists
    (select NULL
    from DOM_DOCUMENT_REVISIONS B
    where B.DOCUMENT_ID = T.DOCUMENT_ID
    and B.REVISION_ID = T.REVISION_ID
    );

  update DOM_DOCUMENT_REVISIONS_TL T set (
      COMMENTS
    ) = (select
      B.COMMENTS
    from DOM_DOCUMENT_REVISIONS_TL B
    where B.DOCUMENT_ID = T.DOCUMENT_ID
    and B.REVISION_ID = T.REVISION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DOCUMENT_ID,
      T.REVISION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DOCUMENT_ID,
      SUBT.REVISION_ID,
      SUBT.LANGUAGE
    from DOM_DOCUMENT_REVISIONS_TL SUBB, DOM_DOCUMENT_REVISIONS_TL SUBT
    where SUBB.DOCUMENT_ID = SUBT.DOCUMENT_ID
    and SUBB.REVISION_ID = SUBT.REVISION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.COMMENTS <> SUBT.COMMENTS
      or (SUBB.COMMENTS is null and SUBT.COMMENTS is not null)
      or (SUBB.COMMENTS is not null and SUBT.COMMENTS is null)
  ));

  insert into DOM_DOCUMENT_REVISIONS_TL (
    DOCUMENT_ID,
    CATEGORY_ID,
    REVISION_ID,
    COMMENTS,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.DOCUMENT_ID,
    B.CATEGORY_ID,
    B.REVISION_ID,
    B.COMMENTS,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from DOM_DOCUMENT_REVISIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from DOM_DOCUMENT_REVISIONS_TL T
    where T.DOCUMENT_ID = B.DOCUMENT_ID
    and T.REVISION_ID = B.REVISION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end DOM_DOCUMENT_REVISIONS_PKG;

/
