--------------------------------------------------------
--  DDL for Package AR_BPA_AREA_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BPA_AREA_ITEMS_PKG" AUTHID CURRENT_USER as
/* $Header: ARBPAIS.pls 120.1 2004/12/03 01:44:56 orashid noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_AREA_ITEM_ID in NUMBER,
  X_SECONDARY_APP_ID in NUMBER,
  X_ITEM_ID in NUMBER,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_TEMPLATE_ID in NUMBER,
  X_DISPLAY_LEVEL in VARCHAR2,
  X_PARENT_AREA_CODE in VARCHAR2,
  X_DATA_SOURCE_ID in NUMBER,
  X_FLEXFIELD_ITEM_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_AREA_ITEM_ID in NUMBER,
  X_SECONDARY_APP_ID in NUMBER,
  X_ITEM_ID in NUMBER,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_TEMPLATE_ID in NUMBER,
  X_DISPLAY_LEVEL in VARCHAR2,
  X_PARENT_AREA_CODE in VARCHAR2,
  X_DATA_SOURCE_ID in NUMBER,
  X_FLEXFIELD_ITEM_FLAG in VARCHAR2
);
procedure UPDATE_ROW (
  X_AREA_ITEM_ID in NUMBER,
  X_SECONDARY_APP_ID in NUMBER,
  X_ITEM_ID in NUMBER,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_TEMPLATE_ID in NUMBER,
  X_DISPLAY_LEVEL in VARCHAR2,
  X_PARENT_AREA_CODE in VARCHAR2,
  X_DATA_SOURCE_ID in NUMBER,
  X_FLEXFIELD_ITEM_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_AREA_ITEM_ID in NUMBER
);
procedure LOAD_ROW (
        X_AREA_ITEM_ID                   IN NUMBER,
        X_DISPLAY_LEVEL                  IN VARCHAR2,
        X_DISPLAY_SEQUENCE               IN NUMBER,
        X_ITEM_ID                        IN NUMBER,
        X_PARENT_AREA_CODE               IN VARCHAR2,
        X_SECONDARY_APP_ID               IN NUMBER,
        X_TEMPLATE_ID                    IN NUMBER,
        X_DATA_SOURCE_ID                 IN NUMBER,
        X_FLEXFIELD_ITEM_FLAG            IN VARCHAR2,
        X_OWNER                 IN VARCHAR2
);
end AR_BPA_AREA_ITEMS_PKG;

 

/