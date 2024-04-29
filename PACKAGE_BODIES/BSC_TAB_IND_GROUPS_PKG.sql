--------------------------------------------------------
--  DDL for Package Body BSC_TAB_IND_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_TAB_IND_GROUPS_PKG" as
/* $Header: BSCTABGB.pls 115.6 2003/02/12 14:29:48 adeulgao ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TAB_ID in NUMBER,
  X_CSF_ID in NUMBER,
  X_IND_GROUP_ID in NUMBER,
  X_GROUP_TYPE in NUMBER,
  X_NAME_POSITION in NUMBER,
  X_NAME_JUSTIFICATION in NUMBER,
  X_LEFT_POSITION in NUMBER,
  X_TOP_POSITION in NUMBER,
  X_WIDTH in NUMBER,
  X_HEIGHT in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2
) is
  cursor C is select ROWID from BSC_TAB_IND_GROUPS_B
    where TAB_ID = X_TAB_ID
    and CSF_ID = X_CSF_ID
    and IND_GROUP_ID = X_IND_GROUP_ID
    ;
begin
  insert into BSC_TAB_IND_GROUPS_B (
    TAB_ID,
    CSF_ID,
    IND_GROUP_ID,
    GROUP_TYPE,
    NAME_POSITION,
    NAME_JUSTIFICATION,
    LEFT_POSITION,
    TOP_POSITION,
    WIDTH,
    HEIGHT
  ) values (
    X_TAB_ID,
    X_CSF_ID,
    X_IND_GROUP_ID,
    X_GROUP_TYPE,
    X_NAME_POSITION,
    X_NAME_JUSTIFICATION,
    X_LEFT_POSITION,
    X_TOP_POSITION,
    X_WIDTH,
    X_HEIGHT
  );

  insert into BSC_TAB_IND_GROUPS_TL (
    TAB_ID,
    CSF_ID,
    IND_GROUP_ID,
    NAME,
    HELP,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TAB_ID,
    X_CSF_ID,
    X_IND_GROUP_ID,
    X_NAME,
    X_HELP,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BSC_TAB_IND_GROUPS_TL T
    where T.TAB_ID = X_TAB_ID
    and T.CSF_ID = X_CSF_ID
    and T.IND_GROUP_ID = X_IND_GROUP_ID
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
  X_IND_GROUP_ID in NUMBER,
  X_GROUP_TYPE in NUMBER,
  X_NAME_POSITION in NUMBER,
  X_NAME_JUSTIFICATION in NUMBER,
  X_LEFT_POSITION in NUMBER,
  X_TOP_POSITION in NUMBER,
  X_WIDTH in NUMBER,
  X_HEIGHT in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2
) is
  cursor c is select
      GROUP_TYPE,
      NAME_POSITION,
      NAME_JUSTIFICATION,
      LEFT_POSITION,
      TOP_POSITION,
      WIDTH,
      HEIGHT
    from BSC_TAB_IND_GROUPS_B
    where TAB_ID = X_TAB_ID
    and CSF_ID = X_CSF_ID
    and IND_GROUP_ID = X_IND_GROUP_ID
    for update of TAB_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      HELP,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BSC_TAB_IND_GROUPS_TL
    where TAB_ID = X_TAB_ID
    and CSF_ID = X_CSF_ID
    and IND_GROUP_ID = X_IND_GROUP_ID
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
  if (    ((recinfo.GROUP_TYPE = X_GROUP_TYPE)
           OR ((recinfo.GROUP_TYPE is null) AND (X_GROUP_TYPE is null)))
      AND ((recinfo.NAME_POSITION = X_NAME_POSITION)
           OR ((recinfo.NAME_POSITION is null) AND (X_NAME_POSITION is null)))
      AND ((recinfo.NAME_JUSTIFICATION = X_NAME_JUSTIFICATION)
           OR ((recinfo.NAME_JUSTIFICATION is null) AND (X_NAME_JUSTIFICATION is null)))
      AND ((recinfo.LEFT_POSITION = X_LEFT_POSITION)
           OR ((recinfo.LEFT_POSITION is null) AND (X_LEFT_POSITION is null)))
      AND ((recinfo.TOP_POSITION = X_TOP_POSITION)
           OR ((recinfo.TOP_POSITION is null) AND (X_TOP_POSITION is null)))
      AND ((recinfo.WIDTH = X_WIDTH)
           OR ((recinfo.WIDTH is null) AND (X_WIDTH is null)))
      AND ((recinfo.HEIGHT = X_HEIGHT)
           OR ((recinfo.HEIGHT is null) AND (X_HEIGHT is null)))
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
  X_IND_GROUP_ID in NUMBER,
  X_GROUP_TYPE in NUMBER,
  X_NAME_POSITION in NUMBER,
  X_NAME_JUSTIFICATION in NUMBER,
  X_LEFT_POSITION in NUMBER,
  X_TOP_POSITION in NUMBER,
  X_WIDTH in NUMBER,
  X_HEIGHT in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2
) is
begin
  update BSC_TAB_IND_GROUPS_B set
    GROUP_TYPE = X_GROUP_TYPE,
    NAME_POSITION = X_NAME_POSITION,
    NAME_JUSTIFICATION = X_NAME_JUSTIFICATION,
    LEFT_POSITION = X_LEFT_POSITION,
    TOP_POSITION = X_TOP_POSITION,
    WIDTH = X_WIDTH,
    HEIGHT = X_HEIGHT
  where TAB_ID = X_TAB_ID
  and CSF_ID = X_CSF_ID
  and IND_GROUP_ID = X_IND_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BSC_TAB_IND_GROUPS_TL set
    NAME = X_NAME,
    HELP = X_HELP,
    SOURCE_LANG = userenv('LANG')
  where TAB_ID = X_TAB_ID
  and CSF_ID = X_CSF_ID
  and IND_GROUP_ID = X_IND_GROUP_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TAB_ID in NUMBER,
  X_CSF_ID in NUMBER,
  X_IND_GROUP_ID in NUMBER
) is
begin
  delete from BSC_TAB_IND_GROUPS_TL
  where TAB_ID = X_TAB_ID
  and CSF_ID = X_CSF_ID
  and IND_GROUP_ID = X_IND_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BSC_TAB_IND_GROUPS_B
  where TAB_ID = X_TAB_ID
  and CSF_ID = X_CSF_ID
  and IND_GROUP_ID = X_IND_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BSC_TAB_IND_GROUPS_TL T
  where not exists
    (select NULL
    from BSC_TAB_IND_GROUPS_B B
    where B.TAB_ID = T.TAB_ID
    and B.CSF_ID = T.CSF_ID
    and B.IND_GROUP_ID = T.IND_GROUP_ID
    );

  update BSC_TAB_IND_GROUPS_TL T set (
      NAME,
      HELP
    ) = (select
      B.NAME,
      B.HELP
    from BSC_TAB_IND_GROUPS_TL B
    where B.TAB_ID = T.TAB_ID
    and B.CSF_ID = T.CSF_ID
    and B.IND_GROUP_ID = T.IND_GROUP_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TAB_ID,
      T.CSF_ID,
      T.IND_GROUP_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TAB_ID,
      SUBT.CSF_ID,
      SUBT.IND_GROUP_ID,
      SUBT.LANGUAGE
    from BSC_TAB_IND_GROUPS_TL SUBB, BSC_TAB_IND_GROUPS_TL SUBT
    where SUBB.TAB_ID = SUBT.TAB_ID
    and SUBB.CSF_ID = SUBT.CSF_ID
    and SUBB.IND_GROUP_ID = SUBT.IND_GROUP_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
      or SUBB.HELP <> SUBT.HELP
      or (SUBB.HELP is null and SUBT.HELP is not null)
      or (SUBB.HELP is not null and SUBT.HELP is null)
  ));

  insert into BSC_TAB_IND_GROUPS_TL (
    TAB_ID,
    CSF_ID,
    IND_GROUP_ID,
    NAME,
    HELP,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TAB_ID,
    B.CSF_ID,
    B.IND_GROUP_ID,
    B.NAME,
    B.HELP,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BSC_TAB_IND_GROUPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BSC_TAB_IND_GROUPS_TL T
    where T.TAB_ID = B.TAB_ID
    and T.CSF_ID = B.CSF_ID
    and T.IND_GROUP_ID = B.IND_GROUP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end BSC_TAB_IND_GROUPS_PKG;

/
