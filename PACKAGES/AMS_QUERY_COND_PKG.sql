--------------------------------------------------------
--  DDL for Package AMS_QUERY_COND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_QUERY_COND_PKG" AUTHID CURRENT_USER as
/* $Header: amstqcos.pls 120.0 2005/05/31 22:50:04 appldev noship $ */
procedure INSERT_ROW (
  X_QUERY_CONDITION_ID in NUMBER,
  X_PARAMETER_KEY in VARCHAR2,
  X_TEMPLATE_ID in NUMBER,
  X_JOIN_CONDITION in VARCHAR2,
  X_OPERAND_DATA_TYPE in VARCHAR2,
  X_MANDATORY_FLAG in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_CONDITION_IN_USE_FLAG in VARCHAR2,
  X_LEFT_OPERAND_TYPE in VARCHAR2,
  X_VALUE1_TYPE in VARCHAR2,
  X_VALUE2_TYPE in VARCHAR2,
  X_DISPLAY_COL_NUMBER in NUMBER,
  X_MAX_TOKEN_COUNT in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_COND_KEYWORD in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_QUERY_CONDITION_ID in NUMBER,
  X_PARAMETER_KEY in VARCHAR2,
  X_TEMPLATE_ID in NUMBER,
  X_JOIN_CONDITION in VARCHAR2,
  X_OPERAND_DATA_TYPE in VARCHAR2,
  X_MANDATORY_FLAG in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_CONDITION_IN_USE_FLAG in VARCHAR2,
  X_LEFT_OPERAND_TYPE in VARCHAR2,
  X_VALUE1_TYPE in VARCHAR2,
  X_VALUE2_TYPE in VARCHAR2,
  X_DISPLAY_COL_NUMBER in NUMBER,
  X_MAX_TOKEN_COUNT in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_COND_KEYWORD in VARCHAR2
);
procedure UPDATE_ROW (
  X_QUERY_CONDITION_ID in NUMBER,
  X_PARAMETER_KEY in VARCHAR2,
  X_TEMPLATE_ID in NUMBER,
  X_JOIN_CONDITION in VARCHAR2,
  X_OPERAND_DATA_TYPE in VARCHAR2,
  X_MANDATORY_FLAG in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_CONDITION_IN_USE_FLAG in VARCHAR2,
  X_LEFT_OPERAND_TYPE in VARCHAR2,
  X_VALUE1_TYPE in VARCHAR2,
  X_VALUE2_TYPE in VARCHAR2,
  X_DISPLAY_COL_NUMBER in NUMBER,
  X_MAX_TOKEN_COUNT in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_COND_KEYWORD in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_QUERY_CONDITION_ID in NUMBER
);

PROCEDURE load_row (
  X_QUERY_CONDITION_ID in NUMBER,
  X_PARAMETER_KEY in VARCHAR2,
  X_TEMPLATE_ID in NUMBER,
  X_JOIN_CONDITION in VARCHAR2,
  X_OPERAND_DATA_TYPE in VARCHAR2,
  X_MANDATORY_FLAG in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_CONDITION_IN_USE_FLAG in VARCHAR2,
  X_LEFT_OPERAND_TYPE in VARCHAR2,
  X_VALUE1_TYPE in VARCHAR2,
  X_VALUE2_TYPE in VARCHAR2,
  X_DISPLAY_COL_NUMBER in NUMBER,
  X_MAX_TOKEN_COUNT in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_COND_KEYWORD in VARCHAR2,
  x_owner IN VARCHAR2,
  x_custom_mode IN VARCHAR2
);

end AMS_QUERY_COND_PKG;

 

/