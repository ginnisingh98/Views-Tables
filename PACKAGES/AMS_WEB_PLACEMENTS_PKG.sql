--------------------------------------------------------
--  DDL for Package AMS_WEB_PLACEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_WEB_PLACEMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: amstwpls.pls 120.1 2005/06/27 05:40:44 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_PLACEMENT_ID in NUMBER,
  X_PLACEMENT_CATEGORY in VARCHAR2,
  X_SITE_ID in NUMBER,
  X_SITE_REF_CODE in VARCHAR2,
  X_PAGE_ID in NUMBER,
  X_PAGE_REF_CODE in VARCHAR2,
  X_LOCATION_CODE in VARCHAR2,
  X_SITE_PARAM1 in NUMBER,
  X_SITE_PARAM2 in NUMBER,
  X_SITE_PARAM3 in NUMBER,
  X_SITE_PARAM4 in NUMBER,
  X_SITE_PARAM5 in NUMBER,
  X_DEFAULT_CONTENT_ITEM_ID in NUMBER,
  X_DEFAULT_CITEM_VER_ID in NUMBER,
  X_DEFAULT_STYLESHEET_ID in NUMBER,
  X_DEFAULT_STYLESHEET_VER_ID in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_AUTO_PUBLISH_FLAG in VARCHAR2,
  X_DISPLAY_SELECTION_CODE in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_PLACEMENT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_PLACEMENT_ID in NUMBER,
  X_PLACEMENT_CATEGORY in VARCHAR2,
  X_SITE_ID in NUMBER,
  X_SITE_REF_CODE in VARCHAR2,
  X_PAGE_ID in NUMBER,
  X_PAGE_REF_CODE in VARCHAR2,
  X_LOCATION_CODE in VARCHAR2,
  X_SITE_PARAM1 in NUMBER,
  X_SITE_PARAM2 in NUMBER,
  X_SITE_PARAM3 in NUMBER,
  X_SITE_PARAM4 in NUMBER,
  X_SITE_PARAM5 in NUMBER,
  X_DEFAULT_CONTENT_ITEM_ID in NUMBER,
  X_DEFAULT_CITEM_VER_ID in NUMBER,
  X_DEFAULT_STYLESHEET_ID in NUMBER,
  X_DEFAULT_STYLESHEET_VER_ID in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_AUTO_PUBLISH_FLAG in VARCHAR2,
  X_DISPLAY_SELECTION_CODE in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_PLACEMENT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_PLACEMENT_ID in NUMBER,
  X_PLACEMENT_CATEGORY in VARCHAR2,
  X_SITE_ID in NUMBER,
  X_SITE_REF_CODE in VARCHAR2,
  X_PAGE_ID in NUMBER,
  X_PAGE_REF_CODE in VARCHAR2,
  X_LOCATION_CODE in VARCHAR2,
  X_SITE_PARAM1 in NUMBER,
  X_SITE_PARAM2 in NUMBER,
  X_SITE_PARAM3 in NUMBER,
  X_SITE_PARAM4 in NUMBER,
  X_SITE_PARAM5 in NUMBER,
  X_DEFAULT_CONTENT_ITEM_ID in NUMBER,
  X_DEFAULT_CITEM_VER_ID in NUMBER,
  X_DEFAULT_STYLESHEET_ID in NUMBER,
  X_DEFAULT_STYLESHEET_VER_ID in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_AUTO_PUBLISH_FLAG in VARCHAR2,
  X_DISPLAY_SELECTION_CODE in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_PLACEMENT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_PLACEMENT_ID in NUMBER
);
procedure ADD_LANGUAGE;
end AMS_WEB_PLACEMENTS_PKG;

 

/