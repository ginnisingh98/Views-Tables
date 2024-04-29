--------------------------------------------------------
--  DDL for Package CN_CW_WORKBENCH_ITEMS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CW_WORKBENCH_ITEMS_ALL_PKG" AUTHID CURRENT_USER as
/* $Header: cntcwwis.pls 120.0 2005/09/08 04:09 raramasa noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_WORKBENCH_ITEM_CODE in VARCHAR2,
  X_WORKBENCH_ITEM_SEQUENCE in NUMBER,
  X_WORKBENCH_PARENT_ITEM_CODE in VARCHAR2,
  X_WORKBENCH_ITEM_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_WORKBENCH_ITEM_NAME in VARCHAR2,
  X_WORKBENCH_ITEM_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ORG_ID IN NUMBER);
procedure LOCK_ROW (
  X_WORKBENCH_ITEM_CODE in VARCHAR2,
  X_WORKBENCH_ITEM_SEQUENCE in NUMBER,
  X_WORKBENCH_PARENT_ITEM_CODE in VARCHAR2,
  X_WORKBENCH_ITEM_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_WORKBENCH_ITEM_NAME in VARCHAR2,
  X_WORKBENCH_ITEM_DESCRIPTION in VARCHAR2,
  X_ORG_ID IN NUMBER
);
procedure UPDATE_ROW (
  X_WORKBENCH_ITEM_CODE in VARCHAR2,
  X_WORKBENCH_ITEM_SEQUENCE in NUMBER,
  X_WORKBENCH_PARENT_ITEM_CODE in VARCHAR2,
  X_WORKBENCH_ITEM_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_WORKBENCH_ITEM_NAME in VARCHAR2,
  X_WORKBENCH_ITEM_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ORG_ID IN NUMBER
);
procedure DELETE_ROW (
  X_WORKBENCH_ITEM_CODE in VARCHAR2,
  X_ORG_ID IN NUMBER
);
PROCEDURE TRANSLATE_ROW
  ( X_WORKBENCH_ITEM_CODE IN VARCHAR2,
    X_WORKBENCH_ITEM_NAME IN VARCHAR2,
    X_WORKBENCH_ITEM_DESCRIPTION IN VARCHAR2,
    X_OWNER IN VARCHAR2
   );
PROCEDURE LOAD_ROW
  ( X_WORKBENCH_ITEM_CODE IN VARCHAR2,
    X_WORKBENCH_ITEM_SEQUENCE IN NUMBER,
    X_WORKBENCH_PARENT_ITEM_CODE IN VARCHAR2,
    X_WORKBENCH_ITEM_TYPE IN VARCHAR2,
    X_ORG_ID IN NUMBER,
    X_WORKBENCH_ITEM_NAME IN VARCHAR2,
    X_WORKBENCH_ITEM_DESCRIPTION IN VARCHAR2,
    X_OWNER IN VARCHAR2);

PROCEDURE LOAD_SEED_ROW (
x_upload_mode in varchar2,
x_owner in varchar2,
x_workbench_item_code  in varchar2,
x_workbench_item_name  in varchar2,
x_workbench_item_description  in varchar2,
x_workbench_item_sequence  in varchar2,
x_workbench_parent_item_code  in varchar2,
x_workbench_item_type  in varchar2,
x_org_id  in varchar2
);

procedure ADD_LANGUAGE;

end CN_CW_WORKBENCH_ITEMS_ALL_PKG;
 

/