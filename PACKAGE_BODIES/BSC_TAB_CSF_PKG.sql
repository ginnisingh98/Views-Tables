--------------------------------------------------------
--  DDL for Package Body BSC_TAB_CSF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_TAB_CSF_PKG" as
/* $Header: BSCTABCB.pls 115.6 2003/02/12 14:29:45 adeulgao ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TAB_ID in NUMBER,
  X_CSF_ID in NUMBER,
  X_CSF_TYPE in NUMBER,
  X_INTERMEDIATE_FLAG in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2
) is
  cursor C is select ROWID from BSC_TAB_CSF_B
    where TAB_ID = X_TAB_ID
    and CSF_ID = X_CSF_ID
    ;
begin
  insert into BSC_TAB_CSF_B (
    TAB_ID,
    CSF_ID,
    CSF_TYPE,
    INTERMEDIATE_FLAG
  ) values (
    X_TAB_ID,
    X_CSF_ID,
    X_CSF_TYPE,
    X_INTERMEDIATE_FLAG
  );

  insert into BSC_TAB_CSF_TL (
    TAB_ID,
    CSF_ID,
    NAME,
    HELP,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TAB_ID,
    X_CSF_ID,
    X_NAME,
    X_HELP,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BSC_TAB_CSF_TL T
    where T.TAB_ID = X_TAB_ID
    and T.CSF_ID = X_CSF_ID
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
  X_TAB_ID in NUMBER,
  X_CSF_ID in NUMBER,
  X_CSF_TYPE in NUMBER,
  X_INTERMEDIATE_FLAG in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2
) is
  cursor c is select
      CSF_TYPE,
      INTERMEDIATE_FLAG
    from BSC_TAB_CSF_B
    where TAB_ID = X_TAB_ID
    and CSF_ID = X_CSF_ID
    for update of TAB_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      HELP,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BSC_TAB_CSF_TL
    where TAB_ID = X_TAB_ID
    and CSF_ID = X_CSF_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TAB_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.CSF_TYPE = X_CSF_TYPE)
           OR ((recinfo.CSF_TYPE is null) AND (X_CSF_TYPE is null)))
      AND (recinfo.INTERMEDIATE_FLAG = X_INTERMEDIATE_FLAG)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.NAME = X_NAME)
               OR ((tlinfo.NAME is null) AND (X_NAME is null)))
          AND ((tlinfo.HELP = X_HELP)
               OR ((tlinfo.HELP is null) AND (X_HELP is null)))
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
  X_TAB_ID in NUMBER,
  X_CSF_ID in NUMBER,
  X_CSF_TYPE in NUMBER,
  X_INTERMEDIATE_FLAG in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2
) is
begin
  update BSC_TAB_CSF_B set
    CSF_TYPE = X_CSF_TYPE,
    INTERMEDIATE_FLAG = X_INTERMEDIATE_FLAG
  where TAB_ID = X_TAB_ID
  and CSF_ID = X_CSF_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BSC_TAB_CSF_TL set
    NAME = X_NAME,
    HELP = X_HELP,
    SOURCE_LANG = userenv('LANG')
  where TAB_ID = X_TAB_ID
  and CSF_ID = X_CSF_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TAB_ID in NUMBER,
  X_CSF_ID in NUMBER
) is
begin
  delete from BSC_TAB_CSF_TL
  where TAB_ID = X_TAB_ID
  and CSF_ID = X_CSF_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BSC_TAB_CSF_B
  where TAB_ID = X_TAB_ID
  and CSF_ID = X_CSF_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BSC_TAB_CSF_TL T
  where not exists
    (select NULL
    from BSC_TAB_CSF_B B
    where B.TAB_ID = T.TAB_ID
    and B.CSF_ID = T.CSF_ID
    );

  update BSC_TAB_CSF_TL T set (
      NAME,
      HELP
    ) = (select
      B.NAME,
      B.HELP
    from BSC_TAB_CSF_TL B
    where B.TAB_ID = T.TAB_ID
    and B.CSF_ID = T.CSF_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TAB_ID,
      T.CSF_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TAB_ID,
      SUBT.CSF_ID,
      SUBT.LANGUAGE
    from BSC_TAB_CSF_TL SUBB, BSC_TAB_CSF_TL SUBT
    where SUBB.TAB_ID = SUBT.TAB_ID
    and SUBB.CSF_ID = SUBT.CSF_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
      or SUBB.HELP <> SUBT.HELP
      or (SUBB.HELP is null and SUBT.HELP is not null)
      or (SUBB.HELP is not null and SUBT.HELP is null)
  ));

  insert into BSC_TAB_CSF_TL (
    TAB_ID,
    CSF_ID,
    NAME,
    HELP,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TAB_ID,
    B.CSF_ID,
    B.NAME,
    B.HELP,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BSC_TAB_CSF_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BSC_TAB_CSF_TL T
    where T.TAB_ID = B.TAB_ID
    and T.CSF_ID = B.CSF_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end BSC_TAB_CSF_PKG;

/
