--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_STATUSES_PKG" as
/* $Header: ENGUSTSB.pls 120.1 2006/01/30 02:38:20 pdutta noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_STATUS_CODE in NUMBER,
  X_SORT_SEQUENCE_NUM in NUMBER,
  X_DISABLE_DATE in DATE,
  X_STATUS_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_STATUS_TYPE in NUMBER,
  X_OBJECT_NAME in VARCHAR2)
 is
  l_object_name  VARCHAR2(30);
  cursor C is select ROWID from ENG_CHANGE_STATUSES
    where STATUS_CODE = X_STATUS_CODE
    ;
begin
  l_object_name := substr(X_OBJECT_NAME, 1, 30);
  IF ( l_object_name = 'ENG')
  THEN
    l_object_name := 'ENG_CHANGE';
  ELSIF (l_object_name = 'DOM')
  THEN
    l_object_name := 'DOM_DOCUMENT_REVISION';
  END IF;

  insert into ENG_CHANGE_STATUSES (
    STATUS_CODE,
    SORT_SEQUENCE_NUM,
    DISABLE_DATE,
    SEEDED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    STATUS_TYPE,
    OBJECT_NAME
  ) values (
    X_STATUS_CODE,
    X_SORT_SEQUENCE_NUM,
    X_DISABLE_DATE,
    X_SEEDED_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_STATUS_TYPE,
    l_object_name
  );

  insert into ENG_CHANGE_STATUSES_TL (
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    STATUS_NAME,
    DESCRIPTION,
    STATUS_CODE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_STATUS_NAME,
    X_DESCRIPTION,
    X_STATUS_CODE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from ENG_CHANGE_STATUSES_TL T
    where T.STATUS_CODE = X_STATUS_CODE
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
  X_STATUS_CODE in NUMBER,
  X_SORT_SEQUENCE_NUM in NUMBER,
  X_DISABLE_DATE in DATE,
  X_STATUS_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_STATUS_TYPE in NUMBER,
  X_OBJECT_NAME in VARCHAR2
) is
  l_object_name  VARCHAR2(30);
  cursor c is select
      SORT_SEQUENCE_NUM,
      DISABLE_DATE,
      SEEDED_FLAG,
      OBJECT_NAME
    from ENG_CHANGE_STATUSES
    where STATUS_CODE = X_STATUS_CODE
    for update of STATUS_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      STATUS_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ENG_CHANGE_STATUSES_TL
    where STATUS_CODE = X_STATUS_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of STATUS_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  l_object_name := substr(X_OBJECT_NAME, 1, 30);
  IF ( l_object_name = 'ENG')
  THEN
    l_object_name := 'ENG_CHANGE';
  ELSIF (l_object_name = 'DOM')
  THEN
    l_object_name := 'DOM_DOCUMENT_REVISION';
  END IF;

  if (    ((recinfo.SORT_SEQUENCE_NUM = X_SORT_SEQUENCE_NUM)
           OR ((recinfo.SORT_SEQUENCE_NUM is null) AND (X_SORT_SEQUENCE_NUM is null)))
      AND ((recinfo.DISABLE_DATE = X_DISABLE_DATE)
           OR ((recinfo.DISABLE_DATE is null) AND (X_DISABLE_DATE is null)))
      AND ((recinfo.OBJECT_NAME = l_object_name)
           OR ((recinfo.OBJECT_NAME is null) AND (l_object_name is null)))
      AND ((recinfo.SEEDED_FLAG = X_SEEDED_FLAG)
           OR ((recinfo.SEEDED_FLAG is null) AND (X_SEEDED_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.STATUS_NAME = X_STATUS_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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
  X_STATUS_CODE in NUMBER,
  X_SORT_SEQUENCE_NUM in NUMBER,
  X_DISABLE_DATE in DATE,
  X_STATUS_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_STATUS_TYPE in NUMBER,
  X_OBJECT_NAME in VARCHAR2
) is
  l_object_name  VARCHAR2(30);
begin

  l_object_name := substr(X_OBJECT_NAME, 1, 30);
  IF ( l_object_name = 'ENG')
  THEN
    l_object_name := 'ENG_CHANGE';
  ELSIF (l_object_name = 'DOM')
  THEN
    l_object_name := 'DOM_DOCUMENT_REVISION';
  END IF;

  update ENG_CHANGE_STATUSES set
    SORT_SEQUENCE_NUM = X_SORT_SEQUENCE_NUM,
    DISABLE_DATE = X_DISABLE_DATE,
    SEEDED_FLAG = X_SEEDED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    STATUS_TYPE =  X_STATUS_TYPE,
    OBJECT_NAME = l_object_name
  where STATUS_CODE = X_STATUS_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update ENG_CHANGE_STATUSES_TL set
    STATUS_NAME = X_STATUS_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where STATUS_CODE = X_STATUS_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_STATUS_CODE in NUMBER
) is
begin
  delete from ENG_CHANGE_STATUSES_TL
  where STATUS_CODE = X_STATUS_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from ENG_CHANGE_STATUSES
  where STATUS_CODE = X_STATUS_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from ENG_CHANGE_STATUSES_TL T
  where not exists
    (select NULL
    from ENG_CHANGE_STATUSES B
    where B.STATUS_CODE = T.STATUS_CODE
    );

  update ENG_CHANGE_STATUSES_TL T set (
      STATUS_NAME,
      DESCRIPTION
    ) = (select
      B.STATUS_NAME,
      B.DESCRIPTION
    from ENG_CHANGE_STATUSES_TL B
    where B.STATUS_CODE = T.STATUS_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.STATUS_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.STATUS_CODE,
      SUBT.LANGUAGE
    from ENG_CHANGE_STATUSES_TL SUBB, ENG_CHANGE_STATUSES_TL SUBT
    where SUBB.STATUS_CODE = SUBT.STATUS_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.STATUS_NAME <> SUBT.STATUS_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into ENG_CHANGE_STATUSES_TL (
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    STATUS_NAME,
    DESCRIPTION,
    STATUS_CODE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.STATUS_NAME,
    B.DESCRIPTION,
    B.STATUS_CODE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ENG_CHANGE_STATUSES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ENG_CHANGE_STATUSES_TL T
    where T.STATUS_CODE = B.STATUS_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end ENG_CHANGE_STATUSES_PKG;

/
