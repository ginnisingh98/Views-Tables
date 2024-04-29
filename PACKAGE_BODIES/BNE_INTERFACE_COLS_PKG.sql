--------------------------------------------------------
--  DDL for Package Body BNE_INTERFACE_COLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_INTERFACE_COLS_PKG" as
/* $Header: bneintrcb.pls 120.3 2005/08/18 07:47:18 dagroves noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_INTERFACE_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_INTERFACE_COL_TYPE in NUMBER,
  X_INTERFACE_COL_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_DISPLAY_FLAG in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_NOT_NULL_FLAG in VARCHAR2,
  X_SUMMARY_FLAG in VARCHAR2,
  X_MAPPING_ENABLED_FLAG in VARCHAR2,
  X_DATA_TYPE in NUMBER,
  X_FIELD_SIZE in NUMBER,
  X_DEFAULT_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_SEGMENT_NUMBER in NUMBER,
  X_GROUP_NAME in VARCHAR2,
  X_OA_FLEX_CODE in VARCHAR2,
  X_OA_CONCAT_FLEX in VARCHAR2,
  X_VAL_TYPE in VARCHAR2,
  X_VAL_ID_COL in VARCHAR2,
  X_VAL_MEAN_COL in VARCHAR2,
  X_VAL_DESC_COL in VARCHAR2,
  X_VAL_OBJ_NAME in VARCHAR2,
  X_VAL_ADDL_W_C in VARCHAR2,
  X_VAL_COMPONENT_APP_ID in NUMBER,
  X_VAL_COMPONENT_CODE in VARCHAR2,
  X_OA_FLEX_NUM in VARCHAR2,
  X_OA_FLEX_APPLICATION_ID in NUMBER,
  X_DISPLAY_ORDER in NUMBER,
  X_UPLOAD_PARAM_LIST_ITEM_NUM in NUMBER,
  X_EXPANDED_SQL_QUERY in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_HINT in VARCHAR2,
  X_PROMPT_LEFT in VARCHAR2,
  X_USER_HELP_TEXT in VARCHAR2,
  X_PROMPT_ABOVE in VARCHAR2,
  X_LOV_TYPE in VARCHAR2,
  X_OFFLINE_LOV_ENABLED_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_VARIABLE_DATA_TYPE_CLASS in VARCHAR2,
  X_VIEWER_GROUP in VARCHAR2,
  X_EDIT_TYPE in VARCHAR2,
  X_VAL_QUERY_APP_ID in NUMBER,
  X_VAL_QUERY_CODE IN VARCHAR2,
  X_EXPANDED_SQL_QUERY_APP_ID in NUMBER,
  X_EXPANDED_SQL_QUERY_CODE in VARCHAR2,
  X_DISPLAY_WIDTH in NUMBER
) is
  cursor C is select ROWID from BNE_INTERFACE_COLS_B
    where APPLICATION_ID = X_APPLICATION_ID
    and INTERFACE_CODE = X_INTERFACE_CODE
    and SEQUENCE_NUM = X_SEQUENCE_NUM
    ;
begin
  insert into BNE_INTERFACE_COLS_B (
    INTERFACE_COL_TYPE,
    INTERFACE_COL_NAME,
    ENABLED_FLAG,
    REQUIRED_FLAG,
    DISPLAY_FLAG,
    READ_ONLY_FLAG,
    NOT_NULL_FLAG,
    SUMMARY_FLAG,
    MAPPING_ENABLED_FLAG,
    DATA_TYPE,
    FIELD_SIZE,
    DEFAULT_TYPE,
    DEFAULT_VALUE,
    SEGMENT_NUMBER,
    GROUP_NAME,
    OA_FLEX_CODE,
    OA_CONCAT_FLEX,
    VAL_TYPE,
    VAL_ID_COL,
    VAL_MEAN_COL,
    VAL_DESC_COL,
    VAL_OBJ_NAME,
    VAL_ADDL_W_C,
    VAL_COMPONENT_APP_ID,
    VAL_COMPONENT_CODE,
    OA_FLEX_NUM,
    OA_FLEX_APPLICATION_ID,
    DISPLAY_ORDER,
    UPLOAD_PARAM_LIST_ITEM_NUM,
    EXPANDED_SQL_QUERY,
    APPLICATION_ID,
    INTERFACE_CODE,
    OBJECT_VERSION_NUMBER,
    SEQUENCE_NUM,
    LOV_TYPE,
    OFFLINE_LOV_ENABLED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    VARIABLE_DATA_TYPE_CLASS,
    VIEWER_GROUP,
    EDIT_TYPE,
    VAL_QUERY_APP_ID,
    VAL_QUERY_CODE,
    EXPANDED_SQL_QUERY_APP_ID,
    EXPANDED_SQL_QUERY_CODE,
	DISPLAY_WIDTH
  ) values (
    X_INTERFACE_COL_TYPE,
    X_INTERFACE_COL_NAME,
    X_ENABLED_FLAG,
    X_REQUIRED_FLAG,
    X_DISPLAY_FLAG,
    X_READ_ONLY_FLAG,
    X_NOT_NULL_FLAG,
    X_SUMMARY_FLAG,
    X_MAPPING_ENABLED_FLAG,
    X_DATA_TYPE,
    X_FIELD_SIZE,
    X_DEFAULT_TYPE,
    X_DEFAULT_VALUE,
    X_SEGMENT_NUMBER,
    X_GROUP_NAME,
    X_OA_FLEX_CODE,
    X_OA_CONCAT_FLEX,
    X_VAL_TYPE,
    X_VAL_ID_COL,
    X_VAL_MEAN_COL,
    X_VAL_DESC_COL,
    X_VAL_OBJ_NAME,
    X_VAL_ADDL_W_C,
    X_VAL_COMPONENT_APP_ID,
    X_VAL_COMPONENT_CODE,
    X_OA_FLEX_NUM,
    X_OA_FLEX_APPLICATION_ID,
    X_DISPLAY_ORDER,
    X_UPLOAD_PARAM_LIST_ITEM_NUM,
    X_EXPANDED_SQL_QUERY,
    X_APPLICATION_ID,
    X_INTERFACE_CODE,
    X_OBJECT_VERSION_NUMBER,
    X_SEQUENCE_NUM,
    X_LOV_TYPE,
    X_OFFLINE_LOV_ENABLED_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_VARIABLE_DATA_TYPE_CLASS,
    X_VIEWER_GROUP,
    X_EDIT_TYPE,
    X_VAL_QUERY_APP_ID,
    X_VAL_QUERY_CODE,
    X_EXPANDED_SQL_QUERY_APP_ID,
    X_EXPANDED_SQL_QUERY_CODE,
	X_DISPLAY_WIDTH
  );

  insert into BNE_INTERFACE_COLS_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    USER_HINT,
    PROMPT_LEFT,
    USER_HELP_TEXT,
    PROMPT_ABOVE,
    INTERFACE_CODE,
    SEQUENCE_NUM,
    APPLICATION_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE,
    X_USER_HINT,
    X_PROMPT_LEFT,
    X_USER_HELP_TEXT,
    X_PROMPT_ABOVE,
    X_INTERFACE_CODE,
    X_SEQUENCE_NUM,
    X_APPLICATION_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BNE_INTERFACE_COLS_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.INTERFACE_CODE = X_INTERFACE_CODE
    and T.SEQUENCE_NUM = X_SEQUENCE_NUM
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
  X_APPLICATION_ID in NUMBER,
  X_INTERFACE_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_INTERFACE_COL_TYPE in NUMBER,
  X_INTERFACE_COL_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_DISPLAY_FLAG in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_NOT_NULL_FLAG in VARCHAR2,
  X_SUMMARY_FLAG in VARCHAR2,
  X_MAPPING_ENABLED_FLAG in VARCHAR2,
  X_DATA_TYPE in NUMBER,
  X_FIELD_SIZE in NUMBER,
  X_DEFAULT_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_SEGMENT_NUMBER in NUMBER,
  X_GROUP_NAME in VARCHAR2,
  X_OA_FLEX_CODE in VARCHAR2,
  X_OA_CONCAT_FLEX in VARCHAR2,
  X_VAL_TYPE in VARCHAR2,
  X_VAL_ID_COL in VARCHAR2,
  X_VAL_MEAN_COL in VARCHAR2,
  X_VAL_DESC_COL in VARCHAR2,
  X_VAL_OBJ_NAME in VARCHAR2,
  X_VAL_ADDL_W_C in VARCHAR2,
  X_VAL_COMPONENT_APP_ID in NUMBER,
  X_VAL_COMPONENT_CODE in VARCHAR2,
  X_OA_FLEX_NUM in VARCHAR2,
  X_OA_FLEX_APPLICATION_ID in NUMBER,
  X_DISPLAY_ORDER in NUMBER,
  X_UPLOAD_PARAM_LIST_ITEM_NUM in NUMBER,
  X_EXPANDED_SQL_QUERY in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_HINT in VARCHAR2,
  X_PROMPT_LEFT in VARCHAR2,
  X_USER_HELP_TEXT in VARCHAR2,
  X_PROMPT_ABOVE in VARCHAR2,
  X_LOV_TYPE in VARCHAR2,
  X_OFFLINE_LOV_ENABLED_FLAG in VARCHAR2,
  X_VARIABLE_DATA_TYPE_CLASS in VARCHAR2,
  X_VIEWER_GROUP in VARCHAR2,
  X_EDIT_TYPE in VARCHAR2,
  X_VAL_QUERY_APP_ID in NUMBER,
  X_VAL_QUERY_CODE in VARCHAR2,
  X_EXPANDED_SQL_QUERY_APP_ID in NUMBER,
  X_EXPANDED_SQL_QUERY_CODE in VARCHAR2,
  X_DISPLAY_WIDTH in NUMBER
) is
  cursor c is select
      INTERFACE_COL_TYPE,
      INTERFACE_COL_NAME,
      ENABLED_FLAG,
      REQUIRED_FLAG,
      DISPLAY_FLAG,
      READ_ONLY_FLAG,
      NOT_NULL_FLAG,
      SUMMARY_FLAG,
      MAPPING_ENABLED_FLAG,
      DATA_TYPE,
      FIELD_SIZE,
      DEFAULT_TYPE,
      DEFAULT_VALUE,
      SEGMENT_NUMBER,
      GROUP_NAME,
      OA_FLEX_CODE,
      OA_CONCAT_FLEX,
      VAL_TYPE,
      VAL_ID_COL,
      VAL_MEAN_COL,
      VAL_DESC_COL,
      VAL_OBJ_NAME,
      VAL_ADDL_W_C,
      VAL_COMPONENT_APP_ID,
      VAL_COMPONENT_CODE,
      OA_FLEX_NUM,
      OA_FLEX_APPLICATION_ID,
      DISPLAY_ORDER,
      UPLOAD_PARAM_LIST_ITEM_NUM,
      EXPANDED_SQL_QUERY,
      LOV_TYPE,
      OFFLINE_LOV_ENABLED_FLAG,
      OBJECT_VERSION_NUMBER,
      VARIABLE_DATA_TYPE_CLASS,
      VIEWER_GROUP,
      EDIT_TYPE,
      VAL_QUERY_APP_ID,
      VAL_QUERY_CODE,
      EXPANDED_SQL_QUERY_APP_ID,
      EXPANDED_SQL_QUERY_CODE,
	  DISPLAY_WIDTH
    from BNE_INTERFACE_COLS_B
    where APPLICATION_ID = X_APPLICATION_ID
    and INTERFACE_CODE = X_INTERFACE_CODE
    and SEQUENCE_NUM = X_SEQUENCE_NUM
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_HINT,
      PROMPT_LEFT,
      USER_HELP_TEXT,
      PROMPT_ABOVE,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BNE_INTERFACE_COLS_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and INTERFACE_CODE = X_INTERFACE_CODE
    and SEQUENCE_NUM = X_SEQUENCE_NUM
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of APPLICATION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.INTERFACE_COL_TYPE = X_INTERFACE_COL_TYPE)
      AND (recinfo.INTERFACE_COL_NAME = X_INTERFACE_COL_NAME)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.REQUIRED_FLAG = X_REQUIRED_FLAG)
      AND (recinfo.DISPLAY_FLAG = X_DISPLAY_FLAG)
      AND (recinfo.READ_ONLY_FLAG = X_READ_ONLY_FLAG)
      AND (recinfo.NOT_NULL_FLAG = X_NOT_NULL_FLAG)
      AND (recinfo.SUMMARY_FLAG = X_SUMMARY_FLAG)
      AND (recinfo.MAPPING_ENABLED_FLAG = X_MAPPING_ENABLED_FLAG)
      AND ((recinfo.DATA_TYPE = X_DATA_TYPE)
           OR ((recinfo.DATA_TYPE is null) AND (X_DATA_TYPE is null)))
      AND ((recinfo.FIELD_SIZE = X_FIELD_SIZE)
           OR ((recinfo.FIELD_SIZE is null) AND (X_FIELD_SIZE is null)))
      AND ((recinfo.DEFAULT_TYPE = X_DEFAULT_TYPE)
           OR ((recinfo.DEFAULT_TYPE is null) AND (X_DEFAULT_TYPE is null)))
      AND ((recinfo.DEFAULT_VALUE = X_DEFAULT_VALUE)
           OR ((recinfo.DEFAULT_VALUE is null) AND (X_DEFAULT_VALUE is null)))
      AND ((recinfo.SEGMENT_NUMBER = X_SEGMENT_NUMBER)
           OR ((recinfo.SEGMENT_NUMBER is null) AND (X_SEGMENT_NUMBER is null)))
      AND ((recinfo.GROUP_NAME = X_GROUP_NAME)
           OR ((recinfo.GROUP_NAME is null) AND (X_GROUP_NAME is null)))
      AND ((recinfo.OA_FLEX_CODE = X_OA_FLEX_CODE)
           OR ((recinfo.OA_FLEX_CODE is null) AND (X_OA_FLEX_CODE is null)))
      AND ((recinfo.OA_CONCAT_FLEX = X_OA_CONCAT_FLEX)
           OR ((recinfo.OA_CONCAT_FLEX is null) AND (X_OA_CONCAT_FLEX is null)))
      AND ((recinfo.VAL_TYPE = X_VAL_TYPE)
           OR ((recinfo.VAL_TYPE is null) AND (X_VAL_TYPE is null)))
      AND ((recinfo.VAL_ID_COL = X_VAL_ID_COL)
           OR ((recinfo.VAL_ID_COL is null) AND (X_VAL_ID_COL is null)))
      AND ((recinfo.VAL_MEAN_COL = X_VAL_MEAN_COL)
           OR ((recinfo.VAL_MEAN_COL is null) AND (X_VAL_MEAN_COL is null)))
      AND ((recinfo.VAL_DESC_COL = X_VAL_DESC_COL)
           OR ((recinfo.VAL_DESC_COL is null) AND (X_VAL_DESC_COL is null)))
      AND ((recinfo.VAL_OBJ_NAME = X_VAL_OBJ_NAME)
           OR ((recinfo.VAL_OBJ_NAME is null) AND (X_VAL_OBJ_NAME is null)))
      AND ((recinfo.VAL_ADDL_W_C = X_VAL_ADDL_W_C)
           OR ((recinfo.VAL_ADDL_W_C is null) AND (X_VAL_ADDL_W_C is null)))
      AND ((recinfo.VAL_COMPONENT_APP_ID = X_VAL_COMPONENT_APP_ID)
           OR ((recinfo.VAL_COMPONENT_APP_ID is null) AND (X_VAL_COMPONENT_APP_ID is null)))
      AND ((recinfo.VAL_COMPONENT_CODE = X_VAL_COMPONENT_CODE)
           OR ((recinfo.VAL_COMPONENT_CODE is null) AND (X_VAL_COMPONENT_CODE is null)))
      AND ((recinfo.OA_FLEX_NUM = X_OA_FLEX_NUM)
           OR ((recinfo.OA_FLEX_NUM is null) AND (X_OA_FLEX_NUM is null)))
      AND ((recinfo.OA_FLEX_APPLICATION_ID = X_OA_FLEX_APPLICATION_ID)
           OR ((recinfo.OA_FLEX_APPLICATION_ID is null) AND (X_OA_FLEX_APPLICATION_ID is null)))
      AND ((recinfo.DISPLAY_ORDER = X_DISPLAY_ORDER)
           OR ((recinfo.DISPLAY_ORDER is null) AND (X_DISPLAY_ORDER is null)))
      AND ((recinfo.DISPLAY_WIDTH = X_DISPLAY_WIDTH)
           OR ((recinfo.DISPLAY_WIDTH is null) AND (X_DISPLAY_WIDTH is null)))
      AND ((recinfo.UPLOAD_PARAM_LIST_ITEM_NUM = X_UPLOAD_PARAM_LIST_ITEM_NUM)
           OR ((recinfo.UPLOAD_PARAM_LIST_ITEM_NUM is null) AND (X_UPLOAD_PARAM_LIST_ITEM_NUM is null)))
      AND ((recinfo.EXPANDED_SQL_QUERY = X_EXPANDED_SQL_QUERY)
           OR ((recinfo.EXPANDED_SQL_QUERY is null) AND (X_EXPANDED_SQL_QUERY is null)))
      AND ((recinfo.LOV_TYPE = X_LOV_TYPE)
           OR ((recinfo.LOV_TYPE is null) AND (X_LOV_TYPE is null)))
      AND ((recinfo.OFFLINE_LOV_ENABLED_FLAG = X_OFFLINE_LOV_ENABLED_FLAG)
           OR ((recinfo.OFFLINE_LOV_ENABLED_FLAG is null) AND (X_OFFLINE_LOV_ENABLED_FLAG is null)))
      AND ((recinfo.VARIABLE_DATA_TYPE_CLASS = X_VARIABLE_DATA_TYPE_CLASS)
           OR ((recinfo.VARIABLE_DATA_TYPE_CLASS is null) AND (X_VARIABLE_DATA_TYPE_CLASS is null)))
      AND ((recinfo.VIEWER_GROUP = X_VIEWER_GROUP)
           OR ((recinfo.VIEWER_GROUP is null) AND (X_VIEWER_GROUP is null)))
      AND ((recinfo.EDIT_TYPE = X_EDIT_TYPE)
           OR ((recinfo.EDIT_TYPE is null) AND (X_EDIT_TYPE is null)))
      AND ((recinfo.VAL_QUERY_APP_ID = X_VAL_QUERY_APP_ID)
           OR ((recinfo.VAL_QUERY_APP_ID is null) AND (X_VAL_QUERY_APP_ID is null)))
      AND ((recinfo.VAL_QUERY_CODE = X_VAL_QUERY_CODE)
           OR ((recinfo.VAL_QUERY_CODE is null) AND (X_VAL_QUERY_CODE is null)))
      AND ((recinfo.EXPANDED_SQL_QUERY_APP_ID = X_EXPANDED_SQL_QUERY_APP_ID)
           OR ((recinfo.EXPANDED_SQL_QUERY_APP_ID is null) AND (X_EXPANDED_SQL_QUERY_APP_ID is null)))
      AND ((recinfo.EXPANDED_SQL_QUERY_CODE = X_EXPANDED_SQL_QUERY_CODE)
           OR ((recinfo.EXPANDED_SQL_QUERY_CODE is null) AND (X_EXPANDED_SQL_QUERY_CODE is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.USER_HINT = X_USER_HINT)
               OR ((tlinfo.USER_HINT is null) AND (X_USER_HINT is null)))
          AND ((tlinfo.PROMPT_LEFT = X_PROMPT_LEFT)
               OR ((tlinfo.PROMPT_LEFT is null) AND (X_PROMPT_LEFT is null)))
          AND ((tlinfo.USER_HELP_TEXT = X_USER_HELP_TEXT)
               OR ((tlinfo.USER_HELP_TEXT is null) AND (X_USER_HELP_TEXT is null)))
          AND ((tlinfo.PROMPT_ABOVE = X_PROMPT_ABOVE)
               OR ((tlinfo.PROMPT_ABOVE is null) AND (X_PROMPT_ABOVE is null)))
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
  X_APPLICATION_ID in NUMBER,
  X_INTERFACE_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_INTERFACE_COL_TYPE in NUMBER,
  X_INTERFACE_COL_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_DISPLAY_FLAG in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_NOT_NULL_FLAG in VARCHAR2,
  X_SUMMARY_FLAG in VARCHAR2,
  X_MAPPING_ENABLED_FLAG in VARCHAR2,
  X_DATA_TYPE in NUMBER,
  X_FIELD_SIZE in NUMBER,
  X_DEFAULT_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_SEGMENT_NUMBER in NUMBER,
  X_GROUP_NAME in VARCHAR2,
  X_OA_FLEX_CODE in VARCHAR2,
  X_OA_CONCAT_FLEX in VARCHAR2,
  X_VAL_TYPE in VARCHAR2,
  X_VAL_ID_COL in VARCHAR2,
  X_VAL_MEAN_COL in VARCHAR2,
  X_VAL_DESC_COL in VARCHAR2,
  X_VAL_OBJ_NAME in VARCHAR2,
  X_VAL_ADDL_W_C in VARCHAR2,
  X_VAL_COMPONENT_APP_ID in NUMBER,
  X_VAL_COMPONENT_CODE in VARCHAR2,
  X_OA_FLEX_NUM in VARCHAR2,
  X_OA_FLEX_APPLICATION_ID in NUMBER,
  X_DISPLAY_ORDER in NUMBER,
  X_UPLOAD_PARAM_LIST_ITEM_NUM in NUMBER,
  X_EXPANDED_SQL_QUERY in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_HINT in VARCHAR2,
  X_PROMPT_LEFT in VARCHAR2,
  X_USER_HELP_TEXT in VARCHAR2,
  X_PROMPT_ABOVE in VARCHAR2,
  X_LOV_TYPE in VARCHAR2,
  X_OFFLINE_LOV_ENABLED_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_VARIABLE_DATA_TYPE_CLASS in VARCHAR2,
  X_VIEWER_GROUP in VARCHAR2,
  X_EDIT_TYPE in VARCHAR2,
  X_VAL_QUERY_APP_ID in NUMBER,
  X_VAL_QUERY_CODE in VARCHAR2,
  X_EXPANDED_SQL_QUERY_APP_ID in NUMBER,
  X_EXPANDED_SQL_QUERY_CODE in VARCHAR2,
  X_DISPLAY_WIDTH in NUMBER
) is
begin
  update BNE_INTERFACE_COLS_B set
    INTERFACE_COL_TYPE = X_INTERFACE_COL_TYPE,
    INTERFACE_COL_NAME = X_INTERFACE_COL_NAME,
    ENABLED_FLAG = X_ENABLED_FLAG,
    REQUIRED_FLAG = X_REQUIRED_FLAG,
    DISPLAY_FLAG = X_DISPLAY_FLAG,
    READ_ONLY_FLAG = X_READ_ONLY_FLAG,
    NOT_NULL_FLAG = X_NOT_NULL_FLAG,
    SUMMARY_FLAG = X_SUMMARY_FLAG,
    MAPPING_ENABLED_FLAG = X_MAPPING_ENABLED_FLAG,
    DATA_TYPE = X_DATA_TYPE,
    FIELD_SIZE = X_FIELD_SIZE,
    DEFAULT_TYPE = X_DEFAULT_TYPE,
    DEFAULT_VALUE = X_DEFAULT_VALUE,
    SEGMENT_NUMBER = X_SEGMENT_NUMBER,
    GROUP_NAME = X_GROUP_NAME,
    OA_FLEX_CODE = X_OA_FLEX_CODE,
    OA_CONCAT_FLEX = X_OA_CONCAT_FLEX,
    VAL_TYPE = X_VAL_TYPE,
    VAL_ID_COL = X_VAL_ID_COL,
    VAL_MEAN_COL = X_VAL_MEAN_COL,
    VAL_DESC_COL = X_VAL_DESC_COL,
    VAL_OBJ_NAME = X_VAL_OBJ_NAME,
    VAL_ADDL_W_C = X_VAL_ADDL_W_C,
    VAL_COMPONENT_APP_ID = X_VAL_COMPONENT_APP_ID,
    VAL_COMPONENT_CODE = X_VAL_COMPONENT_CODE,
    OA_FLEX_NUM = X_OA_FLEX_NUM,
    OA_FLEX_APPLICATION_ID = X_OA_FLEX_APPLICATION_ID,
    DISPLAY_ORDER = X_DISPLAY_ORDER,
    DISPLAY_WIDTH = X_DISPLAY_WIDTH,
    UPLOAD_PARAM_LIST_ITEM_NUM = X_UPLOAD_PARAM_LIST_ITEM_NUM,
    EXPANDED_SQL_QUERY = X_EXPANDED_SQL_QUERY,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LOV_TYPE = X_LOV_TYPE,
    OFFLINE_LOV_ENABLED_FLAG = X_OFFLINE_LOV_ENABLED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    VARIABLE_DATA_TYPE_CLASS = X_VARIABLE_DATA_TYPE_CLASS,
    VIEWER_GROUP = X_VIEWER_GROUP,
    EDIT_TYPE = X_EDIT_TYPE,
    VAL_QUERY_APP_ID = X_VAL_QUERY_APP_ID,
    VAL_QUERY_CODE = X_VAL_QUERY_CODE,
    EXPANDED_SQL_QUERY_APP_ID = X_EXPANDED_SQL_QUERY_APP_ID,
    EXPANDED_SQL_QUERY_CODE = X_EXPANDED_SQL_QUERY_CODE
  where APPLICATION_ID = X_APPLICATION_ID
  and INTERFACE_CODE = X_INTERFACE_CODE
  and SEQUENCE_NUM = X_SEQUENCE_NUM;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BNE_INTERFACE_COLS_TL set
    USER_HINT = X_USER_HINT,
    PROMPT_LEFT = X_PROMPT_LEFT,
    USER_HELP_TEXT = X_USER_HELP_TEXT,
    PROMPT_ABOVE = X_PROMPT_ABOVE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and INTERFACE_CODE = X_INTERFACE_CODE
  and SEQUENCE_NUM = X_SEQUENCE_NUM
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_INTERFACE_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER
) is
begin
  delete from BNE_INTERFACE_COLS_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and INTERFACE_CODE = X_INTERFACE_CODE
  and SEQUENCE_NUM = X_SEQUENCE_NUM;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BNE_INTERFACE_COLS_B
  where APPLICATION_ID = X_APPLICATION_ID
  and INTERFACE_CODE = X_INTERFACE_CODE
  and SEQUENCE_NUM = X_SEQUENCE_NUM;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BNE_INTERFACE_COLS_TL T
  where not exists
    (select NULL
    from BNE_INTERFACE_COLS_B B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.INTERFACE_CODE = T.INTERFACE_CODE
    and B.SEQUENCE_NUM = T.SEQUENCE_NUM
    );

  update BNE_INTERFACE_COLS_TL T set (
      USER_HINT,
      PROMPT_LEFT,
      USER_HELP_TEXT,
      PROMPT_ABOVE
    ) = (select
      B.USER_HINT,
      B.PROMPT_LEFT,
      B.USER_HELP_TEXT,
      B.PROMPT_ABOVE
    from BNE_INTERFACE_COLS_TL B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.INTERFACE_CODE = T.INTERFACE_CODE
    and B.SEQUENCE_NUM = T.SEQUENCE_NUM
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPLICATION_ID,
      T.INTERFACE_CODE,
      T.SEQUENCE_NUM,
      T.LANGUAGE
  ) in (select
      SUBT.APPLICATION_ID,
      SUBT.INTERFACE_CODE,
      SUBT.SEQUENCE_NUM,
      SUBT.LANGUAGE
    from BNE_INTERFACE_COLS_TL SUBB, BNE_INTERFACE_COLS_TL SUBT
    where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.INTERFACE_CODE = SUBT.INTERFACE_CODE
    and SUBB.SEQUENCE_NUM = SUBT.SEQUENCE_NUM
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_HINT <> SUBT.USER_HINT
      or (SUBB.USER_HINT is null and SUBT.USER_HINT is not null)
      or (SUBB.USER_HINT is not null and SUBT.USER_HINT is null)
      or SUBB.PROMPT_LEFT <> SUBT.PROMPT_LEFT
      or (SUBB.PROMPT_LEFT is null and SUBT.PROMPT_LEFT is not null)
      or (SUBB.PROMPT_LEFT is not null and SUBT.PROMPT_LEFT is null)
      or SUBB.USER_HELP_TEXT <> SUBT.USER_HELP_TEXT
      or (SUBB.USER_HELP_TEXT is null and SUBT.USER_HELP_TEXT is not null)
      or (SUBB.USER_HELP_TEXT is not null and SUBT.USER_HELP_TEXT is null)
      or SUBB.PROMPT_ABOVE <> SUBT.PROMPT_ABOVE
      or (SUBB.PROMPT_ABOVE is null and SUBT.PROMPT_ABOVE is not null)
      or (SUBB.PROMPT_ABOVE is not null and SUBT.PROMPT_ABOVE is null)
  ));

  insert into BNE_INTERFACE_COLS_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    USER_HINT,
    PROMPT_LEFT,
    USER_HELP_TEXT,
    PROMPT_ABOVE,
    INTERFACE_CODE,
    SEQUENCE_NUM,
    APPLICATION_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATE_DATE,
    B.USER_HINT,
    B.PROMPT_LEFT,
    B.USER_HELP_TEXT,
    B.PROMPT_ABOVE,
    B.INTERFACE_CODE,
    B.SEQUENCE_NUM,
    B.APPLICATION_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BNE_INTERFACE_COLS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BNE_INTERFACE_COLS_TL T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.INTERFACE_CODE = B.INTERFACE_CODE
    and T.SEQUENCE_NUM = B.SEQUENCE_NUM
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

--------------------------------------------------------------------------------
--  PROCEDURE:   TRANSLATE_ROW                                                --
--                                                                            --
--  DESCRIPTION: Load a translation into the BNE_INTERFACE_COLS entity.       --
--               This proc is called from the apps loader.                    --
--                                                                            --
--  SEE:   http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt         --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  1-Oct-02   DGROVES   CREATED                                              --
--------------------------------------------------------------------------------
procedure TRANSLATE_ROW(
  x_interface_asn         in VARCHAR2,
  x_interface_code        in VARCHAR2,
  x_sequence_num          in VARCHAR2,
  x_user_hint             in VARCHAR2,
  x_prompt_left           in VARCHAR2,
  x_prompt_above          in VARCHAR2,
  x_user_help_text        in VARCHAR2,
  x_owner                 in VARCHAR2,
  x_last_update_date      in VARCHAR2,
  x_custom_mode           in VARCHAR2
)
is
  l_app_id          number;
  f_luby            number;  -- entity owner in file
  f_ludate          date;    -- entity update date in file
  db_luby           number;  -- entity owner in db
  db_ludate         date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id        := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_interface_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_INTERFACE_COLS_TL
    where APPLICATION_ID  = l_app_id
    and   INTERFACE_CODE  = x_interface_code
    and   SEQUENCE_NUM    = x_sequence_num
    and   LANGUAGE        = userenv('LANG');

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then

      update BNE_INTERFACE_COLS_TL
      set USER_HINT         = x_user_hint,
          PROMPT_LEFT       = x_prompt_left,
          PROMPT_ABOVE      = x_prompt_above,
          USER_HELP_TEXT    = x_user_help_text,
          LAST_UPDATE_DATE  = f_ludate,
          LAST_UPDATED_BY   = f_luby,
          LAST_UPDATE_LOGIN = 0,
          SOURCE_LANG       = userenv('LANG')
      where APPLICATION_ID   = l_app_id
      AND   INTERFACE_CODE   = x_interface_code
      AND   SEQUENCE_NUM     = x_sequence_num
      AND   userenv('LANG') in (LANGUAGE, SOURCE_LANG)
      ;
    end if;
  exception
    when no_data_found then
      -- Do not insert missing translations, skip this row
      null;
  end;
end TRANSLATE_ROW;

--------------------------------------------------------------------------------
--  PROCEDURE:     LOAD_ROW                                                   --
--                                                                            --
--  DESCRIPTION:   Load a row into the BNE_INTERFACE_COLS entity.             --
--                 This proc is called from the apps loader.                  --
--                                                                            --
--  SEE:     http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt       --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  1-Oct-02   DGROVES   CREATED                                              --
--------------------------------------------------------------------------------
procedure LOAD_ROW(
  x_interface_asn               in VARCHAR2,
  x_interface_code              in VARCHAR2,
  x_sequence_num                in VARCHAR2,
  x_interface_col_type          in VARCHAR2,
  x_interface_col_name          in VARCHAR2,
  x_enabled_flag                in VARCHAR2,
  x_required_flag               in VARCHAR2,
  x_display_flag                in VARCHAR2,
  x_read_only_flag              in VARCHAR2,
  x_not_null_flag               in VARCHAR2,
  x_summary_flag                in VARCHAR2,
  x_mapping_enabled_flag        in VARCHAR2,
  x_data_type                   in VARCHAR2,
  x_field_size                  in VARCHAR2,
  x_default_type                in VARCHAR2,
  x_default_value               in VARCHAR2,
  x_segment_number              in VARCHAR2,
  x_group_name                  in VARCHAR2,
  x_oa_flex_code                in VARCHAR2,
  x_oa_concat_flex              in VARCHAR2,
  x_val_type                    in VARCHAR2,
  x_val_id_col                  in VARCHAR2,
  x_val_mean_col                in VARCHAR2,
  x_val_desc_col                in VARCHAR2,
  x_val_obj_name                in VARCHAR2,
  x_val_addl_w_c                in VARCHAR2,
  x_val_component_asn           in VARCHAR2,
  x_val_component_code          in VARCHAR2,
  x_oa_flex_num                 in VARCHAR2,
  x_oa_flex_application_id      in VARCHAR2,
  x_display_order               in VARCHAR2,
  x_upload_param_list_item_num  in VARCHAR2,
  x_expanded_sql_query          in VARCHAR2,
  x_object_version_number       in VARCHAR2,
  x_user_hint                   in VARCHAR2,
  x_prompt_left                 in VARCHAR2,
  x_user_help_text              in VARCHAR2,
  x_prompt_above                in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_lov_type                    in VARCHAR2,
  x_offline_lov_enabled_flag    in VARCHAR2,
  x_custom_mode                 in VARCHAR2,
  x_variable_data_type_class    in VARCHAR2,
  x_viewer_group                in VARCHAR2,
  x_edit_type                   in VARCHAR2,
  x_val_query_asn               in VARCHAR2,
  x_val_query_code              in VARCHAR2,
  x_expanded_sql_query_asn      in VARCHAR2,
  x_expanded_sql_query_code     in VARCHAR2,
  x_display_width               in VARCHAR2
)
is
  l_app_id                    number;
  l_val_component_app_id      number;
  l_val_query_app_id          number;
  l_expanded_sql_query_app_id number;
  l_row_id                    varchar2(64);
  f_luby                      number;  -- entity owner in file
  f_ludate                    date;    -- entity update date in file
  db_luby                     number;  -- entity owner in db
  db_ludate                   date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id                    := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_interface_asn);
  l_val_component_app_id      := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_val_component_asn);
  l_val_query_app_id          := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_val_query_asn);
  l_expanded_sql_query_app_id := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_expanded_sql_query_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_INTERFACE_COLS_B
    where APPLICATION_ID = l_app_id
    and   SEQUENCE_NUM   = x_sequence_num
    and   INTERFACE_CODE = x_interface_code;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_INTERFACE_COLS_PKG.Update_Row(
        X_APPLICATION_ID               => l_app_id,
        X_INTERFACE_CODE               => x_interface_code,
        X_SEQUENCE_NUM                 => x_sequence_num,
        X_INTERFACE_COL_TYPE           => x_interface_col_type,
        X_INTERFACE_COL_NAME           => x_interface_col_name,
        X_ENABLED_FLAG                 => x_enabled_flag,
        X_REQUIRED_FLAG                => x_required_flag,
        X_DISPLAY_FLAG                 => x_display_flag,
        X_READ_ONLY_FLAG               => x_read_only_flag,
        X_NOT_NULL_FLAG                => x_not_null_flag,
        X_SUMMARY_FLAG                 => x_summary_flag,
        X_MAPPING_ENABLED_FLAG         => x_mapping_enabled_flag,
        X_DATA_TYPE                    => x_data_type,
        X_FIELD_SIZE                   => x_field_size,
        X_DEFAULT_TYPE                 => x_default_type,
        X_DEFAULT_VALUE                => x_default_value,
        X_SEGMENT_NUMBER               => x_segment_number,
        X_GROUP_NAME                   => x_group_name,
        X_OA_FLEX_CODE                 => x_oa_flex_code,
        X_OA_CONCAT_FLEX               => x_oa_concat_flex,
        X_VAL_TYPE                     => x_val_type,
        X_VAL_ID_COL                   => x_val_id_col,
        X_VAL_MEAN_COL                 => x_val_mean_col,
        X_VAL_DESC_COL                 => x_val_desc_col,
        X_VAL_OBJ_NAME                 => x_val_obj_name,
        X_VAL_ADDL_W_C                 => x_val_addl_w_c,
        X_VAL_COMPONENT_APP_ID         => l_val_component_app_id,
        X_VAL_COMPONENT_CODE           => x_val_component_code,
        X_OA_FLEX_NUM                  => x_oa_flex_num,
        X_OA_FLEX_APPLICATION_ID       => x_oa_flex_application_id,
        X_DISPLAY_ORDER                => x_display_order,
        X_DISPLAY_WIDTH                => x_display_width,
        X_UPLOAD_PARAM_LIST_ITEM_NUM   => x_upload_param_list_item_num,
        X_EXPANDED_SQL_QUERY           => x_expanded_sql_query,
        X_OBJECT_VERSION_NUMBER        => x_object_version_number,
        X_USER_HINT                    => x_user_hint,
        X_PROMPT_LEFT                  => x_prompt_left,
        X_USER_HELP_TEXT               => x_user_help_text,
        X_PROMPT_ABOVE                 => x_prompt_above,
        X_LOV_TYPE                     => x_lov_type,
        X_OFFLINE_LOV_ENABLED_FLAG     => x_offline_lov_enabled_flag,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0,
        X_VARIABLE_DATA_TYPE_CLASS     => x_variable_data_type_class,
        X_VIEWER_GROUP                 => x_viewer_group,
        X_EDIT_TYPE                    => x_edit_type,
        X_VAL_QUERY_APP_ID             => l_val_query_app_id,
        X_VAL_QUERY_CODE               => x_val_query_code,
        X_EXPANDED_SQL_QUERY_APP_ID    => l_expanded_sql_query_app_id,
        X_EXPANDED_SQL_QUERY_CODE      => x_expanded_sql_query_code
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_INTERFACE_COLS_PKG.Insert_Row(
        X_ROWID                        => l_row_id,
        X_APPLICATION_ID               => l_app_id,
        X_INTERFACE_CODE               => x_interface_code,
        X_SEQUENCE_NUM                 => x_sequence_num,
        X_INTERFACE_COL_TYPE           => x_interface_col_type,
        X_INTERFACE_COL_NAME           => x_interface_col_name,
        X_ENABLED_FLAG                 => x_enabled_flag,
        X_REQUIRED_FLAG                => x_required_flag,
        X_DISPLAY_FLAG                 => x_display_flag,
        X_READ_ONLY_FLAG               => x_read_only_flag,
        X_NOT_NULL_FLAG                => x_not_null_flag,
        X_SUMMARY_FLAG                 => x_summary_flag,
        X_MAPPING_ENABLED_FLAG         => x_mapping_enabled_flag,
        X_DATA_TYPE                    => x_data_type,
        X_FIELD_SIZE                   => x_field_size,
        X_DEFAULT_TYPE                 => x_default_type,
        X_DEFAULT_VALUE                => x_default_value,
        X_SEGMENT_NUMBER               => x_segment_number,
        X_GROUP_NAME                   => x_group_name,
        X_OA_FLEX_CODE                 => x_oa_flex_code,
        X_OA_CONCAT_FLEX               => x_oa_concat_flex,
        X_VAL_TYPE                     => x_val_type,
        X_VAL_ID_COL                   => x_val_id_col,
        X_VAL_MEAN_COL                 => x_val_mean_col,
        X_VAL_DESC_COL                 => x_val_desc_col,
        X_VAL_OBJ_NAME                 => x_val_obj_name,
        X_VAL_ADDL_W_C                 => x_val_addl_w_c,
        X_VAL_COMPONENT_APP_ID         => l_val_component_app_id,
        X_VAL_COMPONENT_CODE           => x_val_component_code,
        X_OA_FLEX_NUM                  => x_oa_flex_num,
        X_OA_FLEX_APPLICATION_ID       => x_oa_flex_application_id,
        X_DISPLAY_ORDER                => x_display_order,
        X_DISPLAY_WIDTH                => x_display_width,
        X_UPLOAD_PARAM_LIST_ITEM_NUM   => x_upload_param_list_item_num,
        X_EXPANDED_SQL_QUERY           => x_expanded_sql_query,
        X_OBJECT_VERSION_NUMBER        => x_object_version_number,
        X_USER_HINT                    => x_user_hint,
        X_PROMPT_LEFT                  => x_prompt_left,
        X_USER_HELP_TEXT               => x_user_help_text,
        X_PROMPT_ABOVE                 => x_prompt_above,
        X_LOV_TYPE                     => x_lov_type,
        X_OFFLINE_LOV_ENABLED_FLAG     => x_offline_lov_enabled_flag,
        X_CREATION_DATE                => f_ludate,
        X_CREATED_BY                   => f_luby,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0,
        X_VARIABLE_DATA_TYPE_CLASS     => x_variable_data_type_class,
        X_VIEWER_GROUP                 => x_viewer_group,
        X_EDIT_TYPE                    => x_edit_type,
        X_VAL_QUERY_APP_ID             => l_val_query_app_id,
        X_VAL_QUERY_CODE               => x_val_query_code,
        X_EXPANDED_SQL_QUERY_APP_ID    => l_expanded_sql_query_app_id,
        X_EXPANDED_SQL_QUERY_CODE      => x_expanded_sql_query_code
      );
  end;
end LOAD_ROW;

end BNE_INTERFACE_COLS_PKG;

/
