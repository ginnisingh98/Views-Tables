--------------------------------------------------------
--  DDL for Package FND_REQUEST_SET_STAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_REQUEST_SET_STAGES_PKG" AUTHID CURRENT_USER as
/* $Header: AFRSRSSS.pls 120.2 2005/08/19 20:21:06 ckclark ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_REQUEST_SET_ID in NUMBER,
  X_SET_APPLICATION_ID in NUMBER,
  X_REQUEST_SET_STAGE_ID in NUMBER,
  X_STAGE_NAME in VARCHAR2,
  X_CRITICAL in VARCHAR2,
  X_OUTCOME in VARCHAR2,
  X_ALLOW_CONSTRAINTS_FLAG in VARCHAR2,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_FUNCTION_APPLICATION_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_SUCCESS_LINK in NUMBER,
  X_WARNING_LINK in NUMBER,
  X_ERROR_LINK in NUMBER,
  X_CONCURRENT_PROGRAM_ID in NUMBER,
  X_X in NUMBER,
  X_Y in NUMBER,
  X_ICON_NAME in VARCHAR2,
  X_USER_STAGE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_REQUEST_SET_ID in NUMBER,
  X_SET_APPLICATION_ID in NUMBER,
  X_REQUEST_SET_STAGE_ID in NUMBER,
  X_STAGE_NAME in VARCHAR2,
  X_CRITICAL in VARCHAR2,
  X_OUTCOME in VARCHAR2,
  X_ALLOW_CONSTRAINTS_FLAG in VARCHAR2,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_FUNCTION_APPLICATION_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_SUCCESS_LINK in NUMBER,
  X_WARNING_LINK in NUMBER,
  X_ERROR_LINK in NUMBER,
  X_CONCURRENT_PROGRAM_ID in NUMBER,
  X_X in NUMBER,
  X_Y in NUMBER,
  X_ICON_NAME in VARCHAR2,
  X_USER_STAGE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_REQUEST_SET_ID in NUMBER,
  X_SET_APPLICATION_ID in NUMBER,
  X_REQUEST_SET_STAGE_ID in NUMBER,
  X_STAGE_NAME in VARCHAR2,
  X_CRITICAL in VARCHAR2,
  X_OUTCOME in VARCHAR2,
  X_ALLOW_CONSTRAINTS_FLAG in VARCHAR2,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_FUNCTION_APPLICATION_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_SUCCESS_LINK in NUMBER,
  X_WARNING_LINK in NUMBER,
  X_ERROR_LINK in NUMBER,
  X_CONCURRENT_PROGRAM_ID in NUMBER,
  X_X in NUMBER,
  X_Y in NUMBER,
  X_ICON_NAME in VARCHAR2,
  X_USER_STAGE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_REQUEST_SET_ID in NUMBER,
  X_SET_APPLICATION_ID in NUMBER,
  X_REQUEST_SET_STAGE_ID in NUMBER
);
procedure ADD_LANGUAGE;
end FND_REQUEST_SET_STAGES_PKG;

 

/