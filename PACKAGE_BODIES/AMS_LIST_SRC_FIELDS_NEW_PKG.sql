--------------------------------------------------------
--  DDL for Package Body AMS_LIST_SRC_FIELDS_NEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_SRC_FIELDS_NEW_PKG" as
/* $Header: amstdsab.pls 120.2 2005/08/31 13:37:18 vbhandar ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_LIST_SOURCE_FIELD_ID in NUMBER,
  X_FIELD_LOOKUP_TYPE in VARCHAR2,
  X_FIELD_LOOKUP_TYPE_VIEW_NAME in VARCHAR2,
  X_ALLOW_LABEL_OVERRIDE in VARCHAR2,
  X_FIELD_USAGE_TYPE in VARCHAR2,
  X_DIALOG_ENABLED in VARCHAR2,
  X_ANALYTICS_FLAG in VARCHAR2,
  X_AUTO_BINNING_FLAG in VARCHAR2,
  X_NO_OF_BUCKETS in NUMBER,
  X_ATTB_LOV_ID in NUMBER,
  X_TCA_COLUMN_ID in NUMBER,
  X_USED_IN_LIST_ENTRIES in VARCHAR2,
  X_CHART_ENABLED_FLAG in VARCHAR2,
  X_DEFAULT_CHART_TYPE in VARCHAR2,
  X_LOV_DEFINED_FLAG in VARCHAR2,
  X_USE_FOR_SPLITTING_FLAG in VARCHAR2,
  X_DEFAULT_UI_CONTROL in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DE_LIST_SOURCE_TYPE_CODE in VARCHAR2,
  X_LIST_SOURCE_TYPE_ID in NUMBER,
  X_FIELD_TABLE_NAME in VARCHAR2,
  X_FIELD_COLUMN_NAME in VARCHAR2,
  X_SOURCE_COLUMN_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_POSITION in NUMBER,
  X_END_POSITION in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_FIELD_DATA_TYPE in VARCHAR2,
  X_FIELD_DATA_SIZE in NUMBER,
  X_SOURCE_COLUMN_MEANING in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_COLUMN_TYPE IN VARCHAR2
) is
  cursor C is select ROWID from AMS_LIST_SRC_FIELDS
    where LIST_SOURCE_FIELD_ID = X_LIST_SOURCE_FIELD_ID
    ;
begin
  insert into AMS_LIST_SRC_FIELDS (
    FIELD_LOOKUP_TYPE,
    FIELD_LOOKUP_TYPE_VIEW_NAME,
    ALLOW_LABEL_OVERRIDE,
    FIELD_USAGE_TYPE,
    DIALOG_ENABLED,
    ANALYTICS_FLAG,
    AUTO_BINNING_FLAG,
    NO_OF_BUCKETS,
    ATTB_LOV_ID,
    TCA_COLUMN_ID,
    USED_IN_LIST_ENTRIES,
    CHART_ENABLED_FLAG,
    DEFAULT_CHART_TYPE,
    LOV_DEFINED_FLAG,
    USE_FOR_SPLITTING_FLAG,
    DEFAULT_UI_CONTROL,
    LIST_SOURCE_FIELD_ID,
    OBJECT_VERSION_NUMBER,
    DE_LIST_SOURCE_TYPE_CODE,
    LIST_SOURCE_TYPE_ID,
    FIELD_TABLE_NAME,
    FIELD_COLUMN_NAME,
    SOURCE_COLUMN_NAME,
    ENABLED_FLAG,
    START_POSITION,
    END_POSITION,
    SECURITY_GROUP_ID,
    FIELD_DATA_TYPE,
    FIELD_DATA_SIZE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    COLUMN_TYPE
  ) values (
    X_FIELD_LOOKUP_TYPE,
    X_FIELD_LOOKUP_TYPE_VIEW_NAME,
    X_ALLOW_LABEL_OVERRIDE,
    X_FIELD_USAGE_TYPE,
    X_DIALOG_ENABLED,
    X_ANALYTICS_FLAG,
    X_AUTO_BINNING_FLAG,
    X_NO_OF_BUCKETS,
    X_ATTB_LOV_ID,
    X_TCA_COLUMN_ID,
    X_USED_IN_LIST_ENTRIES,
    X_CHART_ENABLED_FLAG,
    X_DEFAULT_CHART_TYPE,
    X_LOV_DEFINED_FLAG,
    X_USE_FOR_SPLITTING_FLAG,
    X_DEFAULT_UI_CONTROL,
    X_LIST_SOURCE_FIELD_ID,
    X_OBJECT_VERSION_NUMBER,
    X_DE_LIST_SOURCE_TYPE_CODE,
    X_LIST_SOURCE_TYPE_ID,
    X_FIELD_TABLE_NAME,
    X_FIELD_COLUMN_NAME,
    X_SOURCE_COLUMN_NAME,
    X_ENABLED_FLAG,
    X_START_POSITION,
    X_END_POSITION,
    X_SECURITY_GROUP_ID,
    X_FIELD_DATA_TYPE,
    X_FIELD_DATA_SIZE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_COLUMN_TYPE
  );

  insert into AMS_LIST_SRC_FIELDS_TL (
    LIST_SOURCE_FIELD_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATE_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    SOURCE_COLUMN_MEANING,
    SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LIST_SOURCE_FIELD_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_SOURCE_COLUMN_MEANING,
    X_SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMS_LIST_SRC_FIELDS_TL T
    where T.LIST_SOURCE_FIELD_ID = X_LIST_SOURCE_FIELD_ID
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
  X_LIST_SOURCE_FIELD_ID in NUMBER,
  X_FIELD_LOOKUP_TYPE in VARCHAR2,
  X_FIELD_LOOKUP_TYPE_VIEW_NAME in VARCHAR2,
  X_ALLOW_LABEL_OVERRIDE in VARCHAR2,
  X_FIELD_USAGE_TYPE in VARCHAR2,
  X_DIALOG_ENABLED in VARCHAR2,
  X_ANALYTICS_FLAG in VARCHAR2,
  X_AUTO_BINNING_FLAG in VARCHAR2,
  X_NO_OF_BUCKETS in NUMBER,
  X_ATTB_LOV_ID in NUMBER,
  X_TCA_COLUMN_ID in NUMBER,
  X_USED_IN_LIST_ENTRIES in VARCHAR2,
  X_CHART_ENABLED_FLAG in VARCHAR2,
  X_DEFAULT_CHART_TYPE in VARCHAR2,
  X_LOV_DEFINED_FLAG in VARCHAR2,
  X_USE_FOR_SPLITTING_FLAG in VARCHAR2,
  X_DEFAULT_UI_CONTROL in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DE_LIST_SOURCE_TYPE_CODE in VARCHAR2,
  X_LIST_SOURCE_TYPE_ID in NUMBER,
  X_FIELD_TABLE_NAME in VARCHAR2,
  X_FIELD_COLUMN_NAME in VARCHAR2,
  X_SOURCE_COLUMN_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_POSITION in NUMBER,
  X_END_POSITION in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_FIELD_DATA_TYPE in VARCHAR2,
  X_FIELD_DATA_SIZE in NUMBER,
  X_SOURCE_COLUMN_MEANING in VARCHAR2,
  X_COLUMN_TYPE IN VARCHAR2
) is
  cursor c is select
      FIELD_LOOKUP_TYPE,
      FIELD_LOOKUP_TYPE_VIEW_NAME,
      ALLOW_LABEL_OVERRIDE,
      FIELD_USAGE_TYPE,
      DIALOG_ENABLED,
      ANALYTICS_FLAG,
      AUTO_BINNING_FLAG,
      NO_OF_BUCKETS,
      ATTB_LOV_ID,
      TCA_COLUMN_ID,
      USED_IN_LIST_ENTRIES,
      CHART_ENABLED_FLAG,
      DEFAULT_CHART_TYPE,
      LOV_DEFINED_FLAG,
      USE_FOR_SPLITTING_FLAG,
      DEFAULT_UI_CONTROL,
      OBJECT_VERSION_NUMBER,
      DE_LIST_SOURCE_TYPE_CODE,
      LIST_SOURCE_TYPE_ID,
      FIELD_TABLE_NAME,
      FIELD_COLUMN_NAME,
      SOURCE_COLUMN_NAME,
      ENABLED_FLAG,
      START_POSITION,
      END_POSITION,
      SECURITY_GROUP_ID,
      FIELD_DATA_TYPE,
      FIELD_DATA_SIZE,
      COLUMN_TYPE
    from AMS_LIST_SRC_FIELDS
    where LIST_SOURCE_FIELD_ID = X_LIST_SOURCE_FIELD_ID
    for update of LIST_SOURCE_FIELD_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      SOURCE_COLUMN_MEANING,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMS_LIST_SRC_FIELDS_TL
    where LIST_SOURCE_FIELD_ID = X_LIST_SOURCE_FIELD_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of LIST_SOURCE_FIELD_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.FIELD_LOOKUP_TYPE = X_FIELD_LOOKUP_TYPE)
           OR ((recinfo.FIELD_LOOKUP_TYPE is null) AND (X_FIELD_LOOKUP_TYPE is null)))
      AND ((recinfo.FIELD_LOOKUP_TYPE_VIEW_NAME = X_FIELD_LOOKUP_TYPE_VIEW_NAME)
           OR ((recinfo.FIELD_LOOKUP_TYPE_VIEW_NAME is null) AND (X_FIELD_LOOKUP_TYPE_VIEW_NAME is null)))
      AND ((recinfo.ALLOW_LABEL_OVERRIDE = X_ALLOW_LABEL_OVERRIDE)
           OR ((recinfo.ALLOW_LABEL_OVERRIDE is null) AND (X_ALLOW_LABEL_OVERRIDE is null)))
      AND ((recinfo.FIELD_USAGE_TYPE = X_FIELD_USAGE_TYPE)
           OR ((recinfo.FIELD_USAGE_TYPE is null) AND (X_FIELD_USAGE_TYPE is null)))
      AND ((recinfo.DIALOG_ENABLED = X_DIALOG_ENABLED)
           OR ((recinfo.DIALOG_ENABLED is null) AND (X_DIALOG_ENABLED is null)))
      AND ((recinfo.ANALYTICS_FLAG = X_ANALYTICS_FLAG)
           OR ((recinfo.ANALYTICS_FLAG is null) AND (X_ANALYTICS_FLAG is null)))
      AND ((recinfo.AUTO_BINNING_FLAG = X_AUTO_BINNING_FLAG)
           OR ((recinfo.AUTO_BINNING_FLAG is null) AND (X_AUTO_BINNING_FLAG is null)))
      AND ((recinfo.NO_OF_BUCKETS = X_NO_OF_BUCKETS)
           OR ((recinfo.NO_OF_BUCKETS is null) AND (X_NO_OF_BUCKETS is null)))
      AND ((recinfo.ATTB_LOV_ID = X_ATTB_LOV_ID)
           OR ((recinfo.ATTB_LOV_ID is null) AND (X_ATTB_LOV_ID is null)))
      AND ((recinfo.TCA_COLUMN_ID = X_TCA_COLUMN_ID)
           OR ((recinfo.TCA_COLUMN_ID is null) AND (X_TCA_COLUMN_ID is null)))
      AND ((recinfo.USED_IN_LIST_ENTRIES = X_USED_IN_LIST_ENTRIES)
           OR ((recinfo.USED_IN_LIST_ENTRIES is null) AND (X_USED_IN_LIST_ENTRIES is null)))
      AND ((recinfo.CHART_ENABLED_FLAG = X_CHART_ENABLED_FLAG)
           OR ((recinfo.CHART_ENABLED_FLAG is null) AND (X_CHART_ENABLED_FLAG is null)))
      AND ((recinfo.DEFAULT_CHART_TYPE = X_DEFAULT_CHART_TYPE)
           OR ((recinfo.DEFAULT_CHART_TYPE is null) AND (X_DEFAULT_CHART_TYPE is null)))
      AND ((recinfo.LOV_DEFINED_FLAG = X_LOV_DEFINED_FLAG)
           OR ((recinfo.LOV_DEFINED_FLAG is null) AND (X_LOV_DEFINED_FLAG is null)))
      AND ((recinfo.USE_FOR_SPLITTING_FLAG = X_USE_FOR_SPLITTING_FLAG)
           OR ((recinfo.USE_FOR_SPLITTING_FLAG is null) AND (X_USE_FOR_SPLITTING_FLAG is null)))
      AND ((recinfo.DEFAULT_UI_CONTROL = X_DEFAULT_UI_CONTROL)
           OR ((recinfo.DEFAULT_UI_CONTROL is null) AND (X_DEFAULT_UI_CONTROL is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND (recinfo.DE_LIST_SOURCE_TYPE_CODE = X_DE_LIST_SOURCE_TYPE_CODE)
      AND (recinfo.LIST_SOURCE_TYPE_ID = X_LIST_SOURCE_TYPE_ID)
      AND ((recinfo.FIELD_TABLE_NAME = X_FIELD_TABLE_NAME)
           OR ((recinfo.FIELD_TABLE_NAME is null) AND (X_FIELD_TABLE_NAME is null)))
      AND ((recinfo.FIELD_COLUMN_NAME = X_FIELD_COLUMN_NAME)
           OR ((recinfo.FIELD_COLUMN_NAME is null) AND (X_FIELD_COLUMN_NAME is null)))
      AND (recinfo.SOURCE_COLUMN_NAME = X_SOURCE_COLUMN_NAME)
      AND ((recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
           OR ((recinfo.ENABLED_FLAG is null) AND (X_ENABLED_FLAG is null)))
      AND ((recinfo.START_POSITION = X_START_POSITION)
           OR ((recinfo.START_POSITION is null) AND (X_START_POSITION is null)))
      AND ((recinfo.END_POSITION = X_END_POSITION)
           OR ((recinfo.END_POSITION is null) AND (X_END_POSITION is null)))
      AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND ((recinfo.FIELD_DATA_TYPE = X_FIELD_DATA_TYPE)
           OR ((recinfo.FIELD_DATA_TYPE is null) AND (X_FIELD_DATA_TYPE is null)))
      AND ((recinfo.FIELD_DATA_SIZE = X_FIELD_DATA_SIZE)
           OR ((recinfo.FIELD_DATA_SIZE is null) AND (X_FIELD_DATA_SIZE is null)))
      AND ((recinfo.COLUMN_TYPE = X_COLUMN_TYPE)
           OR ((recinfo.COLUMN_TYPE is null) AND (X_COLUMN_TYPE is null)))

  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.SOURCE_COLUMN_MEANING = X_SOURCE_COLUMN_MEANING)
               OR ((tlinfo.SOURCE_COLUMN_MEANING is null) AND (X_SOURCE_COLUMN_MEANING is null)))
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
  X_LIST_SOURCE_FIELD_ID in NUMBER,
  X_FIELD_LOOKUP_TYPE in VARCHAR2,
  X_FIELD_LOOKUP_TYPE_VIEW_NAME in VARCHAR2,
  X_ALLOW_LABEL_OVERRIDE in VARCHAR2,
  X_FIELD_USAGE_TYPE in VARCHAR2,
  X_DIALOG_ENABLED in VARCHAR2,
  X_ANALYTICS_FLAG in VARCHAR2,
  X_AUTO_BINNING_FLAG in VARCHAR2,
  X_NO_OF_BUCKETS in NUMBER,
  X_ATTB_LOV_ID in NUMBER,
  X_TCA_COLUMN_ID in NUMBER,
  X_USED_IN_LIST_ENTRIES in VARCHAR2,
  X_CHART_ENABLED_FLAG in VARCHAR2,
  X_DEFAULT_CHART_TYPE in VARCHAR2,
  X_LOV_DEFINED_FLAG in VARCHAR2,
  X_USE_FOR_SPLITTING_FLAG in VARCHAR2,
  X_DEFAULT_UI_CONTROL in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DE_LIST_SOURCE_TYPE_CODE in VARCHAR2,
  X_LIST_SOURCE_TYPE_ID in NUMBER,
  X_FIELD_TABLE_NAME in VARCHAR2,
  X_FIELD_COLUMN_NAME in VARCHAR2,
  X_SOURCE_COLUMN_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_POSITION in NUMBER,
  X_END_POSITION in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_FIELD_DATA_TYPE in VARCHAR2,
  X_FIELD_DATA_SIZE in NUMBER,
  X_SOURCE_COLUMN_MEANING in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_COLUMN_TYPE IN VARCHAR2
) is
begin
  update AMS_LIST_SRC_FIELDS set
    FIELD_LOOKUP_TYPE = X_FIELD_LOOKUP_TYPE,
    FIELD_LOOKUP_TYPE_VIEW_NAME = X_FIELD_LOOKUP_TYPE_VIEW_NAME,
    ALLOW_LABEL_OVERRIDE = X_ALLOW_LABEL_OVERRIDE,
    FIELD_USAGE_TYPE = X_FIELD_USAGE_TYPE,
    DIALOG_ENABLED = X_DIALOG_ENABLED,
    ANALYTICS_FLAG = X_ANALYTICS_FLAG,
    AUTO_BINNING_FLAG = X_AUTO_BINNING_FLAG,
    NO_OF_BUCKETS = X_NO_OF_BUCKETS,
    ATTB_LOV_ID = X_ATTB_LOV_ID,
    TCA_COLUMN_ID = X_TCA_COLUMN_ID,
    USED_IN_LIST_ENTRIES = X_USED_IN_LIST_ENTRIES,
    CHART_ENABLED_FLAG = X_CHART_ENABLED_FLAG,
    DEFAULT_CHART_TYPE = X_DEFAULT_CHART_TYPE,
    LOV_DEFINED_FLAG = X_LOV_DEFINED_FLAG,
    USE_FOR_SPLITTING_FLAG = X_USE_FOR_SPLITTING_FLAG,
    DEFAULT_UI_CONTROL = X_DEFAULT_UI_CONTROL,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    DE_LIST_SOURCE_TYPE_CODE = X_DE_LIST_SOURCE_TYPE_CODE,
    LIST_SOURCE_TYPE_ID = X_LIST_SOURCE_TYPE_ID,
    FIELD_TABLE_NAME = X_FIELD_TABLE_NAME,
    FIELD_COLUMN_NAME = X_FIELD_COLUMN_NAME,
    SOURCE_COLUMN_NAME = X_SOURCE_COLUMN_NAME,
    ENABLED_FLAG = X_ENABLED_FLAG,
    START_POSITION = X_START_POSITION,
    END_POSITION = X_END_POSITION,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    FIELD_DATA_TYPE = X_FIELD_DATA_TYPE,
    FIELD_DATA_SIZE = X_FIELD_DATA_SIZE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    COLUMN_TYPE =X_COLUMN_TYPE
  where LIST_SOURCE_FIELD_ID = X_LIST_SOURCE_FIELD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMS_LIST_SRC_FIELDS_TL set
    SOURCE_COLUMN_MEANING = X_SOURCE_COLUMN_MEANING,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATE_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where LIST_SOURCE_FIELD_ID = X_LIST_SOURCE_FIELD_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_LIST_SOURCE_FIELD_ID in NUMBER
) is
begin
  delete from AMS_LIST_SRC_FIELDS_TL
  where LIST_SOURCE_FIELD_ID = X_LIST_SOURCE_FIELD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMS_LIST_SRC_FIELDS
  where LIST_SOURCE_FIELD_ID = X_LIST_SOURCE_FIELD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_LIST_SRC_FIELDS_TL T
  where not exists
    (select NULL
    from AMS_LIST_SRC_FIELDS B
    where B.LIST_SOURCE_FIELD_ID = T.LIST_SOURCE_FIELD_ID
    );

  update AMS_LIST_SRC_FIELDS_TL T set (
      SOURCE_COLUMN_MEANING
    ) = (select
      B.SOURCE_COLUMN_MEANING
    from AMS_LIST_SRC_FIELDS_TL B
    where B.LIST_SOURCE_FIELD_ID = T.LIST_SOURCE_FIELD_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LIST_SOURCE_FIELD_ID,
      T.LANGUAGE
  ) in (select
      SUBT.LIST_SOURCE_FIELD_ID,
      SUBT.LANGUAGE
    from AMS_LIST_SRC_FIELDS_TL SUBB, AMS_LIST_SRC_FIELDS_TL SUBT
    where SUBB.LIST_SOURCE_FIELD_ID = SUBT.LIST_SOURCE_FIELD_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SOURCE_COLUMN_MEANING <> SUBT.SOURCE_COLUMN_MEANING
      or (SUBB.SOURCE_COLUMN_MEANING is null and SUBT.SOURCE_COLUMN_MEANING is not null)
      or (SUBB.SOURCE_COLUMN_MEANING is not null and SUBT.SOURCE_COLUMN_MEANING is null)
  ));

  insert into AMS_LIST_SRC_FIELDS_TL (
    LIST_SOURCE_FIELD_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATE_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    SOURCE_COLUMN_MEANING,
    SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.LIST_SOURCE_FIELD_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.SOURCE_COLUMN_MEANING,
    B.SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_LIST_SRC_FIELDS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_LIST_SRC_FIELDS_TL T
    where T.LIST_SOURCE_FIELD_ID = B.LIST_SOURCE_FIELD_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end AMS_LIST_SRC_FIELDS_NEW_PKG;

/