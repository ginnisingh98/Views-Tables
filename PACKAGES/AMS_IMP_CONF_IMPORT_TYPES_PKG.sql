--------------------------------------------------------
--  DDL for Package AMS_IMP_CONF_IMPORT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IMP_CONF_IMPORT_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: amsvcits.pls 115.3 2004/04/08 16:26:50 usingh ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_IMP_CONFIG_IMPORT_TYPE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_IMPORT_TYPE in VARCHAR2,
  X_ACCESS_ALLOWED in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_IMP_CONFIG_IMPORT_TYPE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_IMPORT_TYPE in VARCHAR2,
  X_ACCESS_ALLOWED in VARCHAR2
);
procedure UPDATE_ROW (
  X_IMP_CONFIG_IMPORT_TYPE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_IMPORT_TYPE in VARCHAR2,
  X_ACCESS_ALLOWED in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_IMP_CONFIG_IMPORT_TYPE_ID in NUMBER
);

procedure LOAD_ROW (
  X_IMP_CONFIG_IMPORT_TYPE_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_IMPORT_TYPE in VARCHAR2,
  X_ACCESS_ALLOWED in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
  );

end AMS_IMP_CONF_IMPORT_TYPES_PKG;

 

/
