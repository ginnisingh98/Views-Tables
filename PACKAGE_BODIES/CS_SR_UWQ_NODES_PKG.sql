--------------------------------------------------------
--  DDL for Package Body CS_SR_UWQ_NODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_UWQ_NODES_PKG" as
/* $Header: csnodesb.pls 120.0 2006/02/28 12:03:57 spusegao noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_NODE_ID in NUMBER,
  X_NODE_VIEW in VARCHAR2,
  X_DATA_SOURCE in VARCHAR2,
  X_MEDIA_TYPE_ID in NUMBER,
  X_WHERE_CLAUSE in VARCHAR2,
  X_RES_CAT_ENUM_FLAG in VARCHAR2,
  X_NODE_TYPE in VARCHAR2,
  X_HIDE_IF_EMPTY in VARCHAR2,
  X_NODE_DEPTH in NUMBER,
  X_PARENT_ID in NUMBER,
  X_NODE_QUERY in VARCHAR2,
  X_CURSOR_SQL in VARCHAR2,
  X_CURSOR_KEY_COL in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_NODE_LABEL in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from CS_SR_UWQ_NODES_B
    where NODE_ID = X_NODE_ID
    ;
begin
  insert into CS_SR_UWQ_NODES_B (
    NODE_ID,
    NODE_VIEW,
    DATA_SOURCE,
    MEDIA_TYPE_ID,
    WHERE_CLAUSE,
    RES_CAT_ENUM_FLAG,
    NODE_TYPE,
    HIDE_IF_EMPTY,
    NODE_DEPTH,
    PARENT_ID,
    NODE_QUERY,
    CURSOR_SQL,
    CURSOR_KEY_COL,
    ENABLED_FLAG,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_NODE_ID,
    X_NODE_VIEW,
    X_DATA_SOURCE,
    X_MEDIA_TYPE_ID,
    X_WHERE_CLAUSE,
    X_RES_CAT_ENUM_FLAG,
    X_NODE_TYPE,
    X_HIDE_IF_EMPTY,
    X_NODE_DEPTH,
    X_PARENT_ID,
    X_NODE_QUERY,
    X_CURSOR_SQL,
    X_CURSOR_KEY_COL,
    X_ENABLED_FLAG,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into CS_SR_UWQ_NODES_TL (
    NODE_ID,
    NODE_LABEL,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_NODE_ID,
    X_NODE_LABEL,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CS_SR_UWQ_NODES_TL T
    where T.NODE_ID = X_NODE_ID
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
  X_NODE_ID in NUMBER,
  X_NODE_VIEW in VARCHAR2,
  X_DATA_SOURCE in VARCHAR2,
  X_MEDIA_TYPE_ID in NUMBER,
  X_WHERE_CLAUSE in VARCHAR2,
  X_RES_CAT_ENUM_FLAG in VARCHAR2,
  X_NODE_TYPE in VARCHAR2,
  X_HIDE_IF_EMPTY in VARCHAR2,
  X_NODE_DEPTH in NUMBER,
  X_PARENT_ID in NUMBER,
  X_NODE_QUERY in VARCHAR2,
  X_CURSOR_SQL in VARCHAR2,
  X_CURSOR_KEY_COL in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_NODE_LABEL in VARCHAR2
) is
  cursor c is select
      NODE_VIEW,
      DATA_SOURCE,
      MEDIA_TYPE_ID,
      WHERE_CLAUSE,
      RES_CAT_ENUM_FLAG,
      NODE_TYPE,
      HIDE_IF_EMPTY,
      NODE_DEPTH,
      PARENT_ID,
      NODE_QUERY,
      CURSOR_SQL,
      CURSOR_KEY_COL,
      ENABLED_FLAG,
      OBJECT_VERSION_NUMBER,
      SECURITY_GROUP_ID
    from CS_SR_UWQ_NODES_B
    where NODE_ID = X_NODE_ID
    for update of NODE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NODE_LABEL,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CS_SR_UWQ_NODES_TL
    where NODE_ID = X_NODE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of NODE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.NODE_VIEW = X_NODE_VIEW)
      AND (recinfo.DATA_SOURCE = X_DATA_SOURCE)
      AND ((recinfo.MEDIA_TYPE_ID = X_MEDIA_TYPE_ID)
           OR ((recinfo.MEDIA_TYPE_ID is null) AND (X_MEDIA_TYPE_ID is null)))
      AND ((recinfo.WHERE_CLAUSE = X_WHERE_CLAUSE)
           OR ((recinfo.WHERE_CLAUSE is null) AND (X_WHERE_CLAUSE is null)))
      AND ((recinfo.RES_CAT_ENUM_FLAG = X_RES_CAT_ENUM_FLAG)
           OR ((recinfo.RES_CAT_ENUM_FLAG is null) AND (X_RES_CAT_ENUM_FLAG is null)))
      AND ((recinfo.NODE_TYPE = X_NODE_TYPE)
           OR ((recinfo.NODE_TYPE is null) AND (X_NODE_TYPE is null)))
      AND ((recinfo.HIDE_IF_EMPTY = X_HIDE_IF_EMPTY)
           OR ((recinfo.HIDE_IF_EMPTY is null) AND (X_HIDE_IF_EMPTY is null)))
      AND ((recinfo.NODE_DEPTH = X_NODE_DEPTH)
           OR ((recinfo.NODE_DEPTH is null) AND (X_NODE_DEPTH is null)))
      AND ((recinfo.PARENT_ID = X_PARENT_ID)
           OR ((recinfo.PARENT_ID is null) AND (X_PARENT_ID is null)))
      AND ((recinfo.NODE_QUERY = X_NODE_QUERY)
           OR ((recinfo.NODE_QUERY is null) AND (X_NODE_QUERY is null)))
      AND ((recinfo.CURSOR_SQL = X_CURSOR_SQL)
           OR ((recinfo.CURSOR_SQL is null) AND (X_CURSOR_SQL is null)))
      AND ((recinfo.CURSOR_KEY_COL = X_CURSOR_KEY_COL)
           OR ((recinfo.CURSOR_KEY_COL is null) AND (X_CURSOR_KEY_COL is null)))
      AND ((recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
           OR ((recinfo.ENABLED_FLAG is null) AND (X_ENABLED_FLAG is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NODE_LABEL = X_NODE_LABEL)
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
  X_NODE_ID in NUMBER,
  X_NODE_VIEW in VARCHAR2,
  X_DATA_SOURCE in VARCHAR2,
  X_MEDIA_TYPE_ID in NUMBER,
  X_WHERE_CLAUSE in VARCHAR2,
  X_RES_CAT_ENUM_FLAG in VARCHAR2,
  X_NODE_TYPE in VARCHAR2,
  X_HIDE_IF_EMPTY in VARCHAR2,
  X_NODE_DEPTH in NUMBER,
  X_PARENT_ID in NUMBER,
  X_NODE_QUERY in VARCHAR2,
  X_CURSOR_SQL in VARCHAR2,
  X_CURSOR_KEY_COL in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_NODE_LABEL in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin

  update CS_SR_UWQ_NODES_B set
    ENABLED_FLAG = X_ENABLED_FLAG
  where NODE_ID = X_NODE_ID
  and LAST_UPDATED_BY = X_LAST_UPDATED_BY;

  update CS_SR_UWQ_NODES_B set
    NODE_VIEW = X_NODE_VIEW,
    DATA_SOURCE = X_DATA_SOURCE,
    MEDIA_TYPE_ID = X_MEDIA_TYPE_ID,
    WHERE_CLAUSE = X_WHERE_CLAUSE,
    RES_CAT_ENUM_FLAG = X_RES_CAT_ENUM_FLAG,
    NODE_TYPE = X_NODE_TYPE,
    HIDE_IF_EMPTY = X_HIDE_IF_EMPTY,
    NODE_DEPTH = X_NODE_DEPTH,
    PARENT_ID = X_PARENT_ID,
    NODE_QUERY = X_NODE_QUERY,
    CURSOR_SQL = X_CURSOR_SQL,
    CURSOR_KEY_COL = X_CURSOR_KEY_COL,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where NODE_ID = X_NODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CS_SR_UWQ_NODES_TL set
    NODE_LABEL = X_NODE_LABEL,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where NODE_ID = X_NODE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);


  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_NODE_ID in NUMBER
) is
begin
  delete from CS_SR_UWQ_NODES_TL
  where NODE_ID = X_NODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CS_SR_UWQ_NODES_B
  where NODE_ID = X_NODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CS_SR_UWQ_NODES_TL T
  where not exists
    (select NULL
    from CS_SR_UWQ_NODES_B B
    where B.NODE_ID = T.NODE_ID
    );

  update CS_SR_UWQ_NODES_TL T set (
      NODE_LABEL
    ) = (select
      B.NODE_LABEL
    from CS_SR_UWQ_NODES_TL B
    where B.NODE_ID = T.NODE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.NODE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.NODE_ID,
      SUBT.LANGUAGE
    from CS_SR_UWQ_NODES_TL SUBB, CS_SR_UWQ_NODES_TL SUBT
    where SUBB.NODE_ID = SUBT.NODE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NODE_LABEL <> SUBT.NODE_LABEL
  ));

  insert into CS_SR_UWQ_NODES_TL (
    NODE_ID,
    NODE_LABEL,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.NODE_ID,
    B.NODE_LABEL,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CS_SR_UWQ_NODES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CS_SR_UWQ_NODES_TL T
    where T.NODE_ID = B.NODE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

Procedure Translate_Row
    (x_node_id      IN NUMBER,
     x_node_label   IN VARCHAR2,
     x_owner        IN VARCHAR2)
is
Begin
 UPDATE CS_SR_UWQ_NODES_TL
        set
           NODE_LABEL        = X_NODE_LABEL,
           LAST_UPDATE_DATE  = SYSDATE,
           LAST_UPDATED_BY   = decode(X_OWNER,'SEED',1,0),
           LAST_UPDATE_LOGIN = 0,
           SOURCE_LANG       = userenv('LANG')
        where node_id = x_node_id
        and userenv('LANG') in (language, source_lang);
End Translate_Row;

end CS_SR_UWQ_NODES_PKG;

/
