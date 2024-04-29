--------------------------------------------------------
--  DDL for Package Body IEC_O_RECYCLING_ALGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_O_RECYCLING_ALGS_PKG" as
/* $Header: IECHRCYB.pls 115.10 2004/02/12 18:41:16 jcmoore ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ALGORITHM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SOURCE_TYPE_CODE in VARCHAR2,
  X_ALGORITHM_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PARENT_ID in NUMBER
) is
  cursor C is select ROWID from IEC_O_RECYCLING_ALGS_B
    where ALGORITHM_ID = X_ALGORITHM_ID
    ;
begin
  insert into IEC_O_RECYCLING_ALGS_B (
    OBJECT_VERSION_NUMBER,
    ALGORITHM_ID,
    SOURCE_TYPE_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PARENT_ID
  ) values (
    X_OBJECT_VERSION_NUMBER,
    X_ALGORITHM_ID,
    X_SOURCE_TYPE_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_PARENT_ID
  );

  insert into IEC_O_RECYCLING_ALGS_TL (
    OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    CREATED_BY,
    CREATION_DATE,
    ALGORITHM_ID,
    ALGORITHM_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_OBJECT_VERSION_NUMBER,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATED_BY,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_ALGORITHM_ID,
    X_ALGORITHM_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from IEC_O_RECYCLING_ALGS_TL T
    where T.ALGORITHM_ID = X_ALGORITHM_ID
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
  X_ALGORITHM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SOURCE_TYPE_CODE in VARCHAR2,
  X_ALGORITHM_NAME in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      SOURCE_TYPE_CODE
    from IEC_O_RECYCLING_ALGS_B
    where ALGORITHM_ID = X_ALGORITHM_ID
    for update of ALGORITHM_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      ALGORITHM_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IEC_O_RECYCLING_ALGS_TL
    where ALGORITHM_ID = X_ALGORITHM_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ALGORITHM_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND ((recinfo.SOURCE_TYPE_CODE = X_SOURCE_TYPE_CODE)
           OR ((recinfo.SOURCE_TYPE_CODE is null) AND (X_SOURCE_TYPE_CODE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.ALGORITHM_NAME = X_ALGORITHM_NAME)
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
  X_ALGORITHM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SOURCE_TYPE_CODE in VARCHAR2,
  X_ALGORITHM_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update IEC_O_RECYCLING_ALGS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    SOURCE_TYPE_CODE = X_SOURCE_TYPE_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ALGORITHM_ID = X_ALGORITHM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IEC_O_RECYCLING_ALGS_TL set
    ALGORITHM_NAME = X_ALGORITHM_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ALGORITHM_ID = X_ALGORITHM_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ALGORITHM_ID in NUMBER
) is
begin
  delete from IEC_O_RECYCLING_ALGS_TL
  where ALGORITHM_ID = X_ALGORITHM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IEC_O_RECYCLING_ALGS_B
  where ALGORITHM_ID = X_ALGORITHM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IEC_O_RECYCLING_ALGS_TL T
  where not exists
    (select NULL
    from IEC_O_RECYCLING_ALGS_B B
    where B.ALGORITHM_ID = T.ALGORITHM_ID
    );

  update IEC_O_RECYCLING_ALGS_TL T set (
      ALGORITHM_NAME
    ) = (select
      B.ALGORITHM_NAME
    from IEC_O_RECYCLING_ALGS_TL B
    where B.ALGORITHM_ID = T.ALGORITHM_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ALGORITHM_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ALGORITHM_ID,
      SUBT.LANGUAGE
    from IEC_O_RECYCLING_ALGS_TL SUBB, IEC_O_RECYCLING_ALGS_TL SUBT
    where SUBB.ALGORITHM_ID = SUBT.ALGORITHM_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.ALGORITHM_NAME <> SUBT.ALGORITHM_NAME
  ));

  insert into IEC_O_RECYCLING_ALGS_TL (
    OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    CREATED_BY,
    CREATION_DATE,
    ALGORITHM_ID,
    ALGORITHM_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.OBJECT_VERSION_NUMBER,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATED_BY,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.ALGORITHM_ID,
    B.ALGORITHM_NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEC_O_RECYCLING_ALGS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEC_O_RECYCLING_ALGS_TL T
    where T.ALGORITHM_ID = B.ALGORITHM_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end IEC_O_RECYCLING_ALGS_PKG;

/
