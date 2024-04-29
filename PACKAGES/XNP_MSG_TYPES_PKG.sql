--------------------------------------------------------
--  DDL for Package XNP_MSG_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_MSG_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: XNPMSGTS.pls 120.2 2005/07/19 05:28:29 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_MSG_CODE in VARCHAR2,
  X_MSG_TYPE in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_PRIORITY in NUMBER,
  X_QUEUE_NAME in VARCHAR2,
  X_PROTECTED_FLAG in VARCHAR2,
  X_ROLE_NAME in VARCHAR2,
  X_LAST_COMPILED_DATE in DATE,
  X_VALIDATE_LOGIC in VARCHAR2,
  X_IN_PROCESS_LOGIC in VARCHAR2,
  X_OUT_PROCESS_LOGIC in VARCHAR2,
  X_DEFAULT_PROCESS_LOGIC in VARCHAR2,
  X_DTD_URL in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_MSG_CODE in VARCHAR2,
  X_MSG_TYPE in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_PRIORITY in NUMBER,
  X_QUEUE_NAME in VARCHAR2,
  X_PROTECTED_FLAG in VARCHAR2,
  X_ROLE_NAME in VARCHAR2,
  X_LAST_COMPILED_DATE in DATE,
  X_VALIDATE_LOGIC in VARCHAR2,
  X_IN_PROCESS_LOGIC in VARCHAR2,
  X_OUT_PROCESS_LOGIC in VARCHAR2,
  X_DEFAULT_PROCESS_LOGIC in VARCHAR2,
  X_DTD_URL in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_MSG_CODE in VARCHAR2,
  X_MSG_TYPE in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_PRIORITY in NUMBER,
  X_QUEUE_NAME in VARCHAR2,
  X_PROTECTED_FLAG in VARCHAR2,
  X_ROLE_NAME in VARCHAR2,
  X_LAST_COMPILED_DATE in DATE,
  X_VALIDATE_LOGIC in VARCHAR2,
  X_IN_PROCESS_LOGIC in VARCHAR2,
  X_OUT_PROCESS_LOGIC in VARCHAR2,
  X_DEFAULT_PROCESS_LOGIC in VARCHAR2,
  X_DTD_URL in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_MSG_CODE in VARCHAR2
);
procedure ADD_LANGUAGE;
procedure LOAD_ROW (
  X_MSG_CODE in VARCHAR2,
  X_MSG_TYPE in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_PRIORITY in NUMBER,
  X_QUEUE_NAME in VARCHAR2,
  X_PROTECTED_FLAG in VARCHAR2,
  X_ROLE_NAME in VARCHAR2,
  X_LAST_COMPILED_DATE in DATE,
  X_VALIDATE_LOGIC in VARCHAR2,
  X_IN_PROCESS_LOGIC in VARCHAR2,
  X_OUT_PROCESS_LOGIC in VARCHAR2,
  X_DEFAULT_PROCESS_LOGIC in VARCHAR2,
  X_DTD_URL in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
);
procedure TRANSLATE_ROW (
  X_MSG_CODE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
);
end XNP_MSG_TYPES_PKG;

 

/