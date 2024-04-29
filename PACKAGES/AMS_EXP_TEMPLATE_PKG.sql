--------------------------------------------------------
--  DDL for Package AMS_EXP_TEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_EXP_TEMPLATE_PKG" AUTHID CURRENT_USER as
/* $Header: amsextms.pls 115.2 2002/11/12 23:33:22 jieli noship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_EXP_TEMPLATE_ID in NUMBER,
  X_SET_CLAUSE in VARCHAR2,
  X_EXPORT_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TEMPLATE_NAME in VARCHAR2,
  X_SEEDED_SELECT_CLAUSE in LONG,
  X_FROM_CLAUSE in VARCHAR2,
  X_JOIN_CONDITION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_EXP_TEMPLATE_ID in NUMBER,
  X_SET_CLAUSE in VARCHAR2,
  X_EXPORT_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TEMPLATE_NAME in VARCHAR2,
  X_SEEDED_SELECT_CLAUSE in LONG,
  X_FROM_CLAUSE in VARCHAR2,
  X_JOIN_CONDITION in VARCHAR2
);
procedure UPDATE_ROW (
  X_EXP_TEMPLATE_ID in NUMBER,
  X_SET_CLAUSE in VARCHAR2,
  X_EXPORT_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TEMPLATE_NAME in VARCHAR2,
  X_SEEDED_SELECT_CLAUSE in LONG,
  X_FROM_CLAUSE in VARCHAR2,
  X_JOIN_CONDITION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_EXP_TEMPLATE_ID in NUMBER
);
procedure LOAD_ROW (
  X_EXP_TEMPLATE_ID in NUMBER,
  X_SET_CLAUSE in VARCHAR2,
  X_EXPORT_TYPE in VARCHAR2,
  X_TEMPLATE_NAME in VARCHAR2,
  X_SEEDED_SELECT_CLAUSE in LONG,
  X_FROM_CLAUSE in VARCHAR2,
  X_JOIN_CONDITION in VARCHAR2,
  X_OWNER in VARCHAR2
);
end AMS_EXP_TEMPLATE_PKG;

 

/
