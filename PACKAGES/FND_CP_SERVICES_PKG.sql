--------------------------------------------------------
--  DDL for Package FND_CP_SERVICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CP_SERVICES_PKG" AUTHID CURRENT_USER as
/* $Header: AFCPSERS.pls 120.2 2005/08/19 14:35:15 susghosh ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SERVICE_ID in NUMBER,
  X_DEBUG_TYPE in VARCHAR2,
  X_DEBUG_CHANGE_ACTION in VARCHAR2,
  X_ALLOW_MULTIPLE_PROC_SI in VARCHAR2,
  X_DEFAULT_DEBUG_LEVEL in VARCHAR2,
  X_ENABLED in VARCHAR2,
  X_CARTRIDGE_APPLICATION_ID in NUMBER,
  X_ALLOW_MULTIPLE_PROC_INSTANCE in VARCHAR2,
  X_ALLOW_MULTIPLE_PROC_NODE in VARCHAR2,
  X_MIGRATE_ON_FAILURE in VARCHAR2,
  X_SERVER_TYPE in VARCHAR2,
  X_ALLOW_SUSPEND in VARCHAR2,
  X_ALLOW_VERIFY in VARCHAR2,
  X_ALLOW_PARAMETER in VARCHAR2,
  X_ALLOW_START in VARCHAR2,
  X_ALLOW_EDIT in VARCHAR2,
  X_CARTRIDGE_HANDLE in VARCHAR2,
  X_SERVICE_HANDLE in VARCHAR2,
  X_ALLOW_CREATE in VARCHAR2,
  X_SERVICE_CLASS in VARCHAR2,
  X_SERVICE_INSTANCE_CLASS in VARCHAR2,
  X_ALLOW_RCG in VARCHAR2,
  X_OAM_DISPLAY_ORDER in NUMBER,
  X_ALLOW_RESTART in VARCHAR2,
  X_PARAMETER_CHANGE_ACTION in VARCHAR2,
  X_DEVELOPER_PARAMETERS in VARCHAR2,
  X_ENV_FILE_NAME in VARCHAR2,
  X_SERVICE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SERVICE_PLURAL_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_SERVICE_ID in NUMBER,
  X_DEBUG_TYPE in VARCHAR2,
  X_DEBUG_CHANGE_ACTION in VARCHAR2,
  X_ALLOW_MULTIPLE_PROC_SI in VARCHAR2,
  X_DEFAULT_DEBUG_LEVEL in VARCHAR2,
  X_ENABLED in VARCHAR2,
  X_CARTRIDGE_APPLICATION_ID in NUMBER,
  X_ALLOW_MULTIPLE_PROC_INSTANCE in VARCHAR2,
  X_ALLOW_MULTIPLE_PROC_NODE in VARCHAR2,
  X_MIGRATE_ON_FAILURE in VARCHAR2,
  X_SERVER_TYPE in VARCHAR2,
  X_ALLOW_SUSPEND in VARCHAR2,
  X_ALLOW_VERIFY in VARCHAR2,
  X_ALLOW_PARAMETER in VARCHAR2,
  X_ALLOW_START in VARCHAR2,
  X_ALLOW_EDIT in VARCHAR2,
  X_CARTRIDGE_HANDLE in VARCHAR2,
  X_SERVICE_HANDLE in VARCHAR2,
  X_ALLOW_CREATE in VARCHAR2,
  X_SERVICE_CLASS in VARCHAR2,
  X_SERVICE_INSTANCE_CLASS in VARCHAR2,
  X_ALLOW_RCG in VARCHAR2,
  X_OAM_DISPLAY_ORDER in NUMBER,
  X_ALLOW_RESTART in VARCHAR2,
  X_PARAMETER_CHANGE_ACTION in VARCHAR2,
  X_DEVELOPER_PARAMETERS in VARCHAR2,
  X_ENV_FILE_NAME in VARCHAR2,
  X_SERVICE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SERVICE_PLURAL_NAME in VARCHAR2
);
procedure UPDATE_ROW (
  X_SERVICE_ID in NUMBER,
  X_DEBUG_TYPE in VARCHAR2,
  X_DEBUG_CHANGE_ACTION in VARCHAR2,
  X_ALLOW_MULTIPLE_PROC_SI in VARCHAR2,
  X_DEFAULT_DEBUG_LEVEL in VARCHAR2,
  X_ENABLED in VARCHAR2,
  X_CARTRIDGE_APPLICATION_ID in NUMBER,
  X_ALLOW_MULTIPLE_PROC_INSTANCE in VARCHAR2,
  X_ALLOW_MULTIPLE_PROC_NODE in VARCHAR2,
  X_MIGRATE_ON_FAILURE in VARCHAR2,
  X_SERVER_TYPE in VARCHAR2,
  X_ALLOW_SUSPEND in VARCHAR2,
  X_ALLOW_VERIFY in VARCHAR2,
  X_ALLOW_PARAMETER in VARCHAR2,
  X_ALLOW_START in VARCHAR2,
  X_ALLOW_EDIT in VARCHAR2,
  X_CARTRIDGE_HANDLE in VARCHAR2,
  X_SERVICE_HANDLE in VARCHAR2,
  X_ALLOW_CREATE in VARCHAR2,
  X_SERVICE_CLASS in VARCHAR2,
  X_SERVICE_INSTANCE_CLASS in VARCHAR2,
  X_ALLOW_RCG in VARCHAR2,
  X_OAM_DISPLAY_ORDER in NUMBER,
  X_ALLOW_RESTART in VARCHAR2,
  X_PARAMETER_CHANGE_ACTION in VARCHAR2,
  X_DEVELOPER_PARAMETERS in VARCHAR2,
  X_ENV_FILE_NAME in VARCHAR2,
  X_SERVICE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SERVICE_PLURAL_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_SERVICE_ID in NUMBER
);
procedure ADD_LANGUAGE;
end FND_CP_SERVICES_PKG;

 

/
