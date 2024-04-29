--------------------------------------------------------
--  DDL for Package Body IEC_O_RELEASE_CTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_O_RELEASE_CTLS_PKG" as
/* $Header: IECHRLCB.pls 115.11 2004/02/12 18:41:43 jcmoore ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RELEASE_CONTROL_ID in NUMBER,
  X_SOURCE_TYPE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_RELEASE_CONTROL_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PARENT_ID in NUMBER
) is
  cursor C is select ROWID from IEC_O_RELEASE_CTLS_B
    where RELEASE_CONTROL_ID = X_RELEASE_CONTROL_ID
    ;
begin
  insert into IEC_O_RELEASE_CTLS_B (
    RELEASE_CONTROL_ID,
    SOURCE_TYPE_CODE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PARENT_ID
  ) values (
    X_RELEASE_CONTROL_ID,
    X_SOURCE_TYPE_CODE,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_PARENT_ID
  );

  insert into IEC_O_RELEASE_CTLS_TL (
    RELEASE_CONTROL_ID,
    RELEASE_CONTROL_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_RELEASE_CONTROL_ID,
    X_RELEASE_CONTROL_NAME,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from IEC_O_RELEASE_CTLS_TL T
    where T.RELEASE_CONTROL_ID = X_RELEASE_CONTROL_ID
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
  X_RELEASE_CONTROL_ID in NUMBER,
  X_SOURCE_TYPE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_RELEASE_CONTROL_NAME in VARCHAR2
) is
  cursor c is select
      SOURCE_TYPE_CODE,
      OBJECT_VERSION_NUMBER
    from IEC_O_RELEASE_CTLS_B
    where RELEASE_CONTROL_ID = X_RELEASE_CONTROL_ID
    for update of RELEASE_CONTROL_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      RELEASE_CONTROL_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IEC_O_RELEASE_CTLS_TL
    where RELEASE_CONTROL_ID = X_RELEASE_CONTROL_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of RELEASE_CONTROL_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.SOURCE_TYPE_CODE = X_SOURCE_TYPE_CODE)
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.RELEASE_CONTROL_NAME = X_RELEASE_CONTROL_NAME)
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
  X_RELEASE_CONTROL_ID in NUMBER,
  X_SOURCE_TYPE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_RELEASE_CONTROL_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update IEC_O_RELEASE_CTLS_B set
    SOURCE_TYPE_CODE = X_SOURCE_TYPE_CODE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where RELEASE_CONTROL_ID = X_RELEASE_CONTROL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IEC_O_RELEASE_CTLS_TL set
    RELEASE_CONTROL_NAME = X_RELEASE_CONTROL_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where RELEASE_CONTROL_ID = X_RELEASE_CONTROL_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_RELEASE_CONTROL_ID in NUMBER
) is
begin
  delete from IEC_O_RELEASE_CTLS_TL
  where RELEASE_CONTROL_ID = X_RELEASE_CONTROL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IEC_O_RELEASE_CTLS_B
  where RELEASE_CONTROL_ID = X_RELEASE_CONTROL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IEC_O_RELEASE_CTLS_TL T
  where not exists
    (select NULL
    from IEC_O_RELEASE_CTLS_B B
    where B.RELEASE_CONTROL_ID = T.RELEASE_CONTROL_ID
    );

  update IEC_O_RELEASE_CTLS_TL T set (
      RELEASE_CONTROL_NAME
    ) = (select
      B.RELEASE_CONTROL_NAME
    from IEC_O_RELEASE_CTLS_TL B
    where B.RELEASE_CONTROL_ID = T.RELEASE_CONTROL_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RELEASE_CONTROL_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RELEASE_CONTROL_ID,
      SUBT.LANGUAGE
    from IEC_O_RELEASE_CTLS_TL SUBB, IEC_O_RELEASE_CTLS_TL SUBT
    where SUBB.RELEASE_CONTROL_ID = SUBT.RELEASE_CONTROL_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.RELEASE_CONTROL_NAME <> SUBT.RELEASE_CONTROL_NAME
  ));

  insert into IEC_O_RELEASE_CTLS_TL (
    RELEASE_CONTROL_ID,
    RELEASE_CONTROL_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.RELEASE_CONTROL_ID,
    B.RELEASE_CONTROL_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEC_O_RELEASE_CTLS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEC_O_RELEASE_CTLS_TL T
    where T.RELEASE_CONTROL_ID = B.RELEASE_CONTROL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end IEC_O_RELEASE_CTLS_PKG;

/
