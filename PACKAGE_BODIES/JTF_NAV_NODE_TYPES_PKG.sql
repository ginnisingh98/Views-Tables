--------------------------------------------------------
--  DDL for Package Body JTF_NAV_NODE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_NAV_NODE_TYPES_PKG" as
/* $Header: jtfnntb.pls 120.1 2005/07/02 00:50:04 appldev ship $ */

procedure INSERT_ROW
(X_tree_root_id in number,
 X_NODE_TYPE in VARCHAR2,
 X_AK_FLOW_NAME in VARCHAR2,
 X_AK_PARENT_PAGE_NAME in VARCHAR2,
 X_AK_PK_NAME in VARCHAR2,
 X_AK_WHERE_CLAUSE in VARCHAR2,
 X_AK_WHERE_BINDS in VARCHAR2,
 X_ICON_NAME in VARCHAR2,
 X_FORM_NAME in VARCHAR2,
 X_FORM_PARAM_LIST in VARCHAR2,
 X_STATIC_CHILD_FLAG in VARCHAR2,
 X_CREATION_DATE in DATE,
 X_CREATED_BY in NUMBER,
 X_LAST_UPDATE_DATE in DATE,
 X_LAST_UPDATED_BY in NUMBER,
 X_LAST_UPDATE_LOGIN in NUMBER) IS

   l_node_type_id number := 0;
BEGIN
   SELECT jtf_nav_node_types_s.nextval
     INTO l_node_type_id
     FROM dual;

   insert into JTF_NAV_NODE_TYPES(
     node_type_id,
     tree_root_id,
     NODE_TYPE,
     AK_FLOW_NAME,
     AK_PARENT_PAGE_NAME,
     AK_PK_NAME,
     AK_WHERE_CLAUSE,
     AK_WHERE_BINDS,
     ICON_NAME,
     FORM_NAME,
     FORM_PARAM_LIST,
     STATIC_CHILD_FLAG,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATE_LOGIN,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY) values (
     l_node_type_id,
     X_tree_root_id,
     X_NODE_TYPE,
     X_AK_FLOW_NAME,
     X_AK_PARENT_PAGE_NAME,
     X_AK_PK_NAME,
     X_AK_WHERE_CLAUSE,
     X_AK_WHERE_BINDS,
     X_ICON_NAME,
     X_FORM_NAME,
     X_FORM_PARAM_LIST,
     X_STATIC_CHILD_FLAG,
     X_CREATED_BY,
     X_CREATION_DATE,
     X_LAST_UPDATE_LOGIN,
     X_LAST_UPDATE_DATE,
     X_LAST_UPDATED_BY);

end INSERT_ROW;

procedure LOCK_ROW
  (x_node_type_id IN number,
  X_tree_root_id in number,
  X_NODE_TYPE in VARCHAR2,
  X_AK_FLOW_NAME in VARCHAR2,
  X_AK_PARENT_PAGE_NAME in VARCHAR2,
  X_AK_PK_NAME in VARCHAR2,
  X_AK_WHERE_CLAUSE in VARCHAR2,
  X_AK_WHERE_BINDS in VARCHAR2,
  X_ICON_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_FORM_PARAM_LIST in VARCHAR2,
  X_STATIC_CHILD_FLAG in VARCHAR2
) is
  cursor c1 is select
      AK_FLOW_NAME,
      AK_PARENT_PAGE_NAME,
      AK_PK_NAME,
      AK_WHERE_CLAUSE,
      AK_WHERE_BINDS,
      ICON_NAME,
      FORM_NAME,
      FORM_PARAM_LIST,
      STATIC_CHILD_FLAG
    from JTF_NAV_NODE_TYPES
    WHERE NODE_type_id = X_NODE_type_id
    for update of node_type_id nowait;
begin
  for tlinfo in c1 loop
    if (((tlinfo.ICON_NAME = X_ICON_NAME)
     OR ((tlinfo.ICON_NAME is null) AND (X_ICON_NAME is null)))
    AND ((tlinfo.AK_FLOW_NAME = X_AK_FLOW_NAME)
     OR ((tlinfo.AK_FLOW_NAME is null) AND (X_AK_FLOW_NAME is null)))
    AND ((tlinfo.AK_PARENT_PAGE_NAME = X_AK_PARENT_PAGE_NAME)
     OR ((tlinfo.AK_PARENT_PAGE_NAME is null) AND (X_AK_PARENT_PAGE_NAME is null)))
    AND ((tlinfo.AK_PK_NAME = X_AK_PK_NAME)
     OR ((tlinfo.AK_PK_NAME is null) AND (X_AK_PK_NAME is null)))
    AND ((tlinfo.AK_WHERE_CLAUSE = X_AK_WHERE_CLAUSE)
     OR ((tlinfo.AK_WHERE_CLAUSE is null) AND (X_AK_WHERE_CLAUSE is null)))
    AND ((tlinfo.AK_WHERE_BINDS = X_AK_WHERE_BINDS)
     OR ((tlinfo.AK_WHERE_BINDS is null) AND (X_AK_WHERE_BINDS is null)))
    AND ((tlinfo.FORM_NAME = X_FORM_NAME)
     OR ((tlinfo.FORM_NAME is null) AND (X_FORM_NAME is null)))
    AND ((tlinfo.FORM_PARAM_LIST = X_FORM_PARAM_LIST)
     OR ((tlinfo.FORM_PARAM_LIST is null) AND (X_FORM_PARAM_LIST is null)))
    AND ((tlinfo.STATIC_CHILD_FLAG = X_STATIC_CHILD_FLAG)
     OR ((tlinfo.STATIC_CHILD_FLAG is null) AND (X_STATIC_CHILD_FLAG is null)))
    AND ((tlinfo.ICON_NAME = X_ICON_NAME)
     OR ((tlinfo.ICON_NAME is null) AND (X_ICON_NAME is null)))
    AND ((tlinfo.FORM_NAME = X_FORM_NAME)
     OR ((tlinfo.FORM_NAME is null) AND (X_FORM_NAME is null)))
    AND ((tlinfo.FORM_PARAM_LIST = X_FORM_PARAM_LIST)
     OR ((tlinfo.FORM_PARAM_LIST is null) AND (X_FORM_PARAM_LIST is null)))
    AND ((tlinfo.STATIC_CHILD_FLAG = X_STATIC_CHILD_FLAG)
     OR ((tlinfo.STATIC_CHILD_FLAG is null) AND (X_STATIC_CHILD_FLAG is null)))
      ) then
        null;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW
  (x_node_type_id IN number,
  X_tree_root_id in number,
  X_NODE_TYPE in VARCHAR2,
  X_AK_FLOW_NAME in VARCHAR2,
  X_AK_PARENT_PAGE_NAME in VARCHAR2,
  X_AK_PK_NAME in VARCHAR2,
  X_AK_WHERE_CLAUSE in VARCHAR2,
  X_AK_WHERE_BINDS in VARCHAR2,
  X_ICON_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_FORM_PARAM_LIST in VARCHAR2,
  X_STATIC_CHILD_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
   update JTF_NAV_NODE_TYPES SET
     node_type = x_node_type,
    AK_FLOW_NAME = X_AK_FLOW_NAME,
    AK_PARENT_PAGE_NAME = X_AK_PARENT_PAGE_NAME,
    AK_PK_NAME = X_AK_PK_NAME,
    AK_WHERE_CLAUSE = X_AK_WHERE_CLAUSE,
    AK_WHERE_BINDS = X_AK_WHERE_BINDS,
    ICON_NAME = X_ICON_NAME,
    FORM_NAME = X_FORM_NAME,
    FORM_PARAM_LIST = X_FORM_PARAM_LIST,
    STATIC_CHILD_FLAG = X_STATIC_CHILD_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where node_type_id = x_node_type_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW
  (X_NODE_type_ID in number) is
begin
  delete from JTF_NAV_NODE_TYPES
  where node_type_id = x_node_type_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end JTF_NAV_NODE_TYPES_PKG;

/
