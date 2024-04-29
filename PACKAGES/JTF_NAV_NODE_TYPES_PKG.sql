--------------------------------------------------------
--  DDL for Package JTF_NAV_NODE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_NAV_NODE_TYPES_PKG" AUTHID CURRENT_USER as
-- $Header: jtfnnts.pls 120.1 2005/07/02 00:50:07 appldev ship $
--
-- Package Name
-- JTF_NAV_NODE_TYPES_PKG
-- Purpose
--  Table Handler for JTF_NAV_NODE_TYPES

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
   X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW
  (x_node_type_id IN number,
   x_tree_root_id in number,
   X_NODE_TYPE in VARCHAR2,
   X_AK_FLOW_NAME in VARCHAR2,
   X_AK_PARENT_PAGE_NAME in VARCHAR2,
   X_AK_PK_NAME in VARCHAR2,
   X_AK_WHERE_CLAUSE in VARCHAR2,
   X_AK_WHERE_BINDS in VARCHAR2,
   X_ICON_NAME in VARCHAR2,
   X_FORM_NAME in VARCHAR2,
   X_FORM_PARAM_LIST in VARCHAR2,
   X_STATIC_CHILD_FLAG in VARCHAR2);

procedure UPDATE_ROW
  (x_node_type_id IN number,
  x_tree_root_id in number,
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
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure DELETE_ROW
  (X_NODE_type_ID in number);

end JTF_NAV_NODE_TYPES_PKG;
 

/