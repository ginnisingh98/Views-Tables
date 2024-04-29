--------------------------------------------------------
--  DDL for Package AMW_OBJECT_OPINION_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_OBJECT_OPINION_TYPES_PKG" AUTHID CURRENT_USER as
/*$Header: amwtopos.pls 115.4 2003/10/31 01:33:10 cpetriuc noship $*/

procedure INSERT_ROW (
  X_OBJECT_OPINION_TYPE_ID in NUMBER,
  X_OBJECT_ID in NUMBER,
  X_OPINION_TYPE_ID in NUMBER,
  X_VIEW_FUNCTION_ID in NUMBER,
  X_PERFORM_FUNCTION_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure UPDATE_ROW (
  X_OBJECT_OPINION_TYPE_ID in NUMBER,
  X_OBJECT_ID in NUMBER,
  X_OPINION_TYPE_ID in NUMBER,
  X_VIEW_FUNCTION_ID in NUMBER,
  X_PERFORM_FUNCTION_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure DELETE_ROW (
  X_OBJECT_OPINION_TYPE_ID in NUMBER);

procedure LOAD_ROW (
  X_OBJECT_OPINION_TYPE_ID in NUMBER,
  X_OBJECT_NAME in VARCHAR2,
  X_OPINION_TYPE_ID in NUMBER,
  X_VIEW_FUNCTION_ID in NUMBER,
  X_PERFORM_FUNCTION_ID in NUMBER,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2);

end AMW_OBJECT_OPINION_TYPES_PKG;

 

/
