--------------------------------------------------------
--  DDL for Package EGO_CATG_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_CATG_MAP_PKG" AUTHID CURRENT_USER as
/* $Header: EGOCTMPS.pls 120.1 2005/12/08 01:54:25 lparihar noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CATG_MAP_ID in NUMBER,
  X_SOURCE_CATG_SET_ID in NUMBER,
  X_TARGET_CATG_SET_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_CATG_MAP_NAME in VARCHAR2,
  X_CATG_MAP_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure LOCK_ROW (
  X_CATG_MAP_ID in NUMBER,
  X_SOURCE_CATG_SET_ID in NUMBER,
  X_TARGET_CATG_SET_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
 X_CATG_MAP_NAME in VARCHAR2,
  X_CATG_MAP_DESC in VARCHAR2
);

procedure UPDATE_ROW (
  X_CATG_MAP_ID in NUMBER,
  X_SOURCE_CATG_SET_ID in NUMBER,
  X_TARGET_CATG_SET_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_CATG_MAP_NAME in VARCHAR2,
  X_CATG_MAP_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_CATG_MAP_ID in NUMBER
);

PROCEDURE Load_Row
(
  X_CATG_MAP_ID          in NUMBER,
  X_SOURCE_CATG_SET_NAME in VARCHAR2,
  X_TARGET_CATG_SET_NAME in VARCHAR2,
  X_ENABLED_FLAG         in VARCHAR2,
  X_OWNER                in VARCHAR2,
  X_LAST_UPDATE_DATE     in VARCHAR2,
  X_CATG_MAP_NAME        in VARCHAR2,
  X_CATG_MAP_DESC        in VARCHAR2
);

PROCEDURE Load_Row
(
  X_CATG_MAP_ID          in NUMBER,
  X_SOURCE_CATG_SET_NAME in VARCHAR2,
  X_TARGET_CATG_SET_NAME in VARCHAR2,
  X_OWNER                in VARCHAR2,
  X_LAST_UPDATE_DATE     in VARCHAR2,
  X_SOURCE_CATG_NAME     in VARCHAR2,
  X_TARGET_CATG_NAME     in VARCHAR2
);

PROCEDURE Translate_Row
(
  X_CATG_MAP_ID          in NUMBER,
  X_SOURCE_CATG_SET_NAME in VARCHAR2,
  X_TARGET_CATG_SET_NAME in VARCHAR2,
  X_ENABLED_FLAG         in VARCHAR2,
  X_OWNER                in VARCHAR2,
  X_LAST_UPDATE_DATE     in VARCHAR2,
  X_CATG_MAP_NAME        in VARCHAR2,
  X_CATG_MAP_DESC        in VARCHAR2
);

procedure ADD_LANGUAGE;

end EGO_CATG_MAP_PKG;

 

/