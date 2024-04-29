--------------------------------------------------------
--  DDL for Package Body BSC_KPIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_KPIS_PKG" as
/* $Header: BSCKPIB.pls 115.6 2003/02/12 14:25:54 adrao ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_INDICATOR in NUMBER,
  X_SHARE_FLAG in NUMBER,
  X_PERIODICITY_ID in NUMBER,
  X_BM_GROUP_ID in NUMBER,
  X_APPLY_COLOR_FLAG in NUMBER,
  X_PROTOTYPE_COLOR in VARCHAR2,
  X_DISP_ORDER in NUMBER,
  X_PROTOTYPE_FLAG in NUMBER,
  X_INDICATOR_TYPE in NUMBER,
  X_CONFIG_TYPE in NUMBER,
  X_SOURCE_INDICATOR in NUMBER,
  X_CSF_ID in NUMBER,
  X_IND_GROUP_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2
) is
  cursor C is select ROWID from BSC_KPIS_B
    where INDICATOR = X_INDICATOR
    ;
begin
  insert into BSC_KPIS_B (
    SHARE_FLAG,
    PERIODICITY_ID,
    BM_GROUP_ID,
    APPLY_COLOR_FLAG,
    PROTOTYPE_COLOR,
    DISP_ORDER,
    PROTOTYPE_FLAG,
    INDICATOR_TYPE,
    CONFIG_TYPE,
    SOURCE_INDICATOR,
    CSF_ID,
    IND_GROUP_ID,
    INDICATOR
  ) values (
    X_SHARE_FLAG,
    X_PERIODICITY_ID,
    X_BM_GROUP_ID,
    X_APPLY_COLOR_FLAG,
    X_PROTOTYPE_COLOR,
    X_DISP_ORDER,
    X_PROTOTYPE_FLAG,
    X_INDICATOR_TYPE,
    X_CONFIG_TYPE,
    X_SOURCE_INDICATOR,
    X_CSF_ID,
    X_IND_GROUP_ID,
    X_INDICATOR
  );

  insert into BSC_KPIS_TL (
    NAME,
    HELP,
    INDICATOR,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_NAME,
    X_HELP,
    X_INDICATOR,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BSC_KPIS_TL T
    where T.INDICATOR = X_INDICATOR
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
  X_INDICATOR in NUMBER,
  X_SHARE_FLAG in NUMBER,
  X_PERIODICITY_ID in NUMBER,
  X_BM_GROUP_ID in NUMBER,
  X_APPLY_COLOR_FLAG in NUMBER,
  X_PROTOTYPE_COLOR in VARCHAR2,
  X_DISP_ORDER in NUMBER,
  X_PROTOTYPE_FLAG in NUMBER,
  X_INDICATOR_TYPE in NUMBER,
  X_CONFIG_TYPE in NUMBER,
  X_SOURCE_INDICATOR in NUMBER,
  X_CSF_ID in NUMBER,
  X_IND_GROUP_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2
) is
  cursor c is select
      SHARE_FLAG,
      PERIODICITY_ID,
      BM_GROUP_ID,
      APPLY_COLOR_FLAG,
      PROTOTYPE_COLOR,
      DISP_ORDER,
      PROTOTYPE_FLAG,
      INDICATOR_TYPE,
      CONFIG_TYPE,
      SOURCE_INDICATOR,
      CSF_ID,
      IND_GROUP_ID
    from BSC_KPIS_B
    where INDICATOR = X_INDICATOR
    for update of INDICATOR nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      HELP,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BSC_KPIS_TL
    where INDICATOR = X_INDICATOR
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of INDICATOR nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.SHARE_FLAG = X_SHARE_FLAG)
      AND (recinfo.PERIODICITY_ID = X_PERIODICITY_ID)
      AND (recinfo.BM_GROUP_ID = X_BM_GROUP_ID)
      AND (recinfo.APPLY_COLOR_FLAG = X_APPLY_COLOR_FLAG)
      AND ((recinfo.PROTOTYPE_COLOR = X_PROTOTYPE_COLOR)
           OR ((recinfo.PROTOTYPE_COLOR is null) AND (X_PROTOTYPE_COLOR is null)))
      AND (recinfo.DISP_ORDER = X_DISP_ORDER)
      AND (recinfo.PROTOTYPE_FLAG = X_PROTOTYPE_FLAG)
      AND (recinfo.INDICATOR_TYPE = X_INDICATOR_TYPE)
      AND (recinfo.CONFIG_TYPE = X_CONFIG_TYPE)
      AND ((recinfo.SOURCE_INDICATOR = X_SOURCE_INDICATOR)
           OR ((recinfo.SOURCE_INDICATOR is null) AND (X_SOURCE_INDICATOR is null)))
      AND (recinfo.CSF_ID = X_CSF_ID)
      AND (recinfo.IND_GROUP_ID = X_IND_GROUP_ID)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
          AND (tlinfo.HELP = X_HELP)
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
  X_INDICATOR in NUMBER,
  X_SHARE_FLAG in NUMBER,
  X_PERIODICITY_ID in NUMBER,
  X_BM_GROUP_ID in NUMBER,
  X_APPLY_COLOR_FLAG in NUMBER,
  X_PROTOTYPE_COLOR in VARCHAR2,
  X_DISP_ORDER in NUMBER,
  X_PROTOTYPE_FLAG in NUMBER,
  X_INDICATOR_TYPE in NUMBER,
  X_CONFIG_TYPE in NUMBER,
  X_SOURCE_INDICATOR in NUMBER,
  X_CSF_ID in NUMBER,
  X_IND_GROUP_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2
) is
begin
  update BSC_KPIS_B set
    SHARE_FLAG = X_SHARE_FLAG,
    PERIODICITY_ID = X_PERIODICITY_ID,
    BM_GROUP_ID = X_BM_GROUP_ID,
    APPLY_COLOR_FLAG = X_APPLY_COLOR_FLAG,
    PROTOTYPE_COLOR = X_PROTOTYPE_COLOR,
    DISP_ORDER = X_DISP_ORDER,
    PROTOTYPE_FLAG = X_PROTOTYPE_FLAG,
    INDICATOR_TYPE = X_INDICATOR_TYPE,
    CONFIG_TYPE = X_CONFIG_TYPE,
    SOURCE_INDICATOR = X_SOURCE_INDICATOR,
    CSF_ID = X_CSF_ID,
    IND_GROUP_ID = X_IND_GROUP_ID
  where INDICATOR = X_INDICATOR;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BSC_KPIS_TL set
    NAME = X_NAME,
    HELP = X_HELP,
    SOURCE_LANG = userenv('LANG')
  where INDICATOR = X_INDICATOR
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_INDICATOR in NUMBER
) is
begin
  delete from BSC_KPIS_TL
  where INDICATOR = X_INDICATOR;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BSC_KPIS_B
  where INDICATOR = X_INDICATOR;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BSC_KPIS_TL T
  where not exists
    (select NULL
    from BSC_KPIS_B B
    where B.INDICATOR = T.INDICATOR
    );

  update BSC_KPIS_TL T set (
      NAME,
      HELP
    ) = (select
      B.NAME,
      B.HELP
    from BSC_KPIS_TL B
    where B.INDICATOR = T.INDICATOR
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.INDICATOR,
      T.LANGUAGE
  ) in (select
      SUBT.INDICATOR,
      SUBT.LANGUAGE
    from BSC_KPIS_TL SUBB, BSC_KPIS_TL SUBT
    where SUBB.INDICATOR = SUBT.INDICATOR
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.HELP <> SUBT.HELP
  ));

  insert into BSC_KPIS_TL (
    NAME,
    HELP,
    INDICATOR,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.NAME,
    B.HELP,
    B.INDICATOR,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BSC_KPIS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BSC_KPIS_TL T
    where T.INDICATOR = B.INDICATOR
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end BSC_KPIS_PKG;

/
