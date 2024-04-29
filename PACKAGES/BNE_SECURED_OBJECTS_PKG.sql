--------------------------------------------------------
--  DDL for Package BNE_SECURED_OBJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_SECURED_OBJECTS_PKG" AUTHID CURRENT_USER as
/* $Header: bnesecuredobjs.pls 120.2 2005/06/29 03:40:58 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_CODE in VARCHAR2,
  X_OBJECT_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_RULE_APP_ID in NUMBER,
  X_SECURITY_RULE_CODE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_CODE in VARCHAR2,
  X_OBJECT_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_RULE_APP_ID in NUMBER,
  X_SECURITY_RULE_CODE in VARCHAR2
);

procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_CODE in VARCHAR2,
  X_OBJECT_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_RULE_APP_ID in NUMBER,
  X_SECURITY_RULE_CODE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_CODE in VARCHAR2,
  X_OBJECT_TYPE in VARCHAR2
);

procedure ADD_LANGUAGE;

procedure LOAD_ROW(
  x_secured_object_asn          in VARCHAR2,
  x_secured_object_code         in VARCHAR2,
  x_secured_object_type         in VARCHAR2,
  x_object_version_number       in VARCHAR2,
  x_security_rule_app_id        in VARCHAR2,
  x_security_rule_code          in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_custom_mode                 in VARCHAR2
);

end BNE_SECURED_OBJECTS_PKG;

 

/
