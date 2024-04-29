--------------------------------------------------------
--  DDL for Package AMW_OBJECT_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_OBJECT_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: amwlobrs.pls 120.0 2005/05/31 22:02:12 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_OBJECT_RULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_APPROVAL_TYPE in VARCHAR2,
  X_RULE_USED_BY in VARCHAR2,
  X_OBJECT_TYPE in VARCHAR2,
  X_RULE_TYPE in VARCHAR2,
  X_API_TYPE in VARCHAR2,
  X_PACKAGE_NAME in VARCHAR2,
  X_PROCEDURE_NAME in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_OBJECT_RULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_APPROVAL_TYPE in VARCHAR2,
  X_RULE_USED_BY in VARCHAR2,
  X_OBJECT_TYPE in VARCHAR2,
  X_RULE_TYPE in VARCHAR2,
  X_API_TYPE in VARCHAR2,
  X_PACKAGE_NAME in VARCHAR2,
  X_PROCEDURE_NAME in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER
);
procedure UPDATE_ROW (
  X_OBJECT_RULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_APPROVAL_TYPE in VARCHAR2,
  X_RULE_USED_BY in VARCHAR2,
  X_OBJECT_TYPE in VARCHAR2,
  X_RULE_TYPE in VARCHAR2,
  X_API_TYPE in VARCHAR2,
  X_PACKAGE_NAME in VARCHAR2,
  X_PROCEDURE_NAME in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_OBJECT_RULE_ID in NUMBER
);


procedure LOAD_ROW (
  X_OBJECT_RULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_APPROVAL_TYPE in VARCHAR2,
  X_RULE_USED_BY in VARCHAR2,
  X_OBJECT_TYPE in VARCHAR2,
  X_RULE_TYPE in VARCHAR2,
  X_API_TYPE in VARCHAR2,
  X_PACKAGE_NAME in VARCHAR2,
  X_PROCEDURE_NAME in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_OWNER   in VARCHAR2
);

end amw_OBJECT_RULES_PKG;

 

/