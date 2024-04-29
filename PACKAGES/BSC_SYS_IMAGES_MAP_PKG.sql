--------------------------------------------------------
--  DDL for Package BSC_SYS_IMAGES_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_SYS_IMAGES_MAP_PKG" AUTHID CURRENT_USER as
/* $Header: BSCSSIMS.pls 115.4 2003/02/12 14:29:41 adeulgao ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SOURCE_TYPE in NUMBER,
  X_SOURCE_CODE in NUMBER,
  X_TYPE in NUMBER,
  X_IMAGE_ID in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure LOCK_ROW (
  X_SOURCE_TYPE in NUMBER,
  X_SOURCE_CODE in NUMBER,
  X_TYPE in NUMBER,
  X_IMAGE_ID in NUMBER
);
procedure UPDATE_ROW (
  X_SOURCE_TYPE in NUMBER,
  X_SOURCE_CODE in NUMBER,
  X_TYPE in NUMBER,
  X_IMAGE_ID in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_SOURCE_TYPE in NUMBER,
  X_SOURCE_CODE in NUMBER,
  X_TYPE in NUMBER
);
procedure ADD_LANGUAGE;
end BSC_SYS_IMAGES_MAP_PKG;

 

/
