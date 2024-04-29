--------------------------------------------------------
--  DDL for Package Body WMS_PAGE_TEMPLATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_PAGE_TEMPLATES_PVT" as
/* $Header: WMSPTPVB.pls 115.1 2003/10/31 05:16:07 sthamman noship $ */

G_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

PROCEDURE DEBUG(p_message IN VARCHAR2) IS
BEGIN
   inv_log_util.TRACE( P_MESSAGE => P_MESSAGE
                       ,p_module => 'WMS_PAGE_TEMPLATES_PVT'
                       ,p_level => 9
                       );
END; -- DEBUG

PROCEDURE CREATE_TEMPLATE(
  X_ROWID in out nocopy VARCHAR2,
  X_PAGE_ID in NUMBER,
  X_TEMPLATE_ID in NUMBER,
  X_TEMPLATE_NAME in VARCHAR2,
  X_CREATING_ORGANIZATION_ID in NUMBER,
  X_CREATING_ORGANIZATION_CODE in VARCHAR2,
  X_COMMON_TO_ALL_ORGS in VARCHAR2,
  X_ENABLED in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_USER_TEMPLATE_NAME in VARCHAR2,
  X_TEMPLATE_DESCRIPTION in VARCHAR2,
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
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DEFAULT_FIELDS in varchar2) is

begin

  WMS_PAGE_TEMPLATES_PKG.INSERT_ROW(
    X_ROWID => X_ROWID,
    X_TEMPLATE_ID => X_TEMPLATE_ID,
    X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1 => X_ATTRIBUTE1,
    X_ATTRIBUTE2 => X_ATTRIBUTE2,
    X_ATTRIBUTE3 => X_ATTRIBUTE3,
    X_ATTRIBUTE4 => X_ATTRIBUTE4,
    X_ATTRIBUTE5 => X_ATTRIBUTE5,
    X_ATTRIBUTE6 => X_ATTRIBUTE6,
    X_ATTRIBUTE7 => X_ATTRIBUTE7,
    X_ATTRIBUTE8 => X_ATTRIBUTE8,
    X_ATTRIBUTE9 => X_ATTRIBUTE9,
    X_ATTRIBUTE10 => X_ATTRIBUTE10,
    X_ATTRIBUTE11 => X_ATTRIBUTE11,
    X_ATTRIBUTE12 => X_ATTRIBUTE12,
    X_ATTRIBUTE13 => X_ATTRIBUTE13,
    X_ATTRIBUTE14 => X_ATTRIBUTE14,
    X_ATTRIBUTE15 => X_ATTRIBUTE15,
    X_PAGE_ID => X_PAGE_ID,
    X_TEMPLATE_NAME => X_TEMPLATE_NAME,
    X_CREATING_ORGANIZATION_ID => X_CREATING_ORGANIZATION_ID,
    X_CREATING_ORGANIZATION_CODE => X_CREATING_ORGANIZATION_CODE,
    X_COMMON_TO_ALL_ORGS => X_COMMON_TO_ALL_ORGS,
    X_ENABLED => X_ENABLED,
    X_DEFAULT_FLAG => X_DEFAULT_FLAG,
    X_USER_TEMPLATE_NAME => X_USER_TEMPLATE_NAME,
    X_TEMPLATE_DESCRIPTION => X_TEMPLATE_DESCRIPTION,
    X_CREATION_DATE => X_CREATION_DATE,
    X_CREATED_BY => X_CREATED_BY,
    X_LAST_UPDATE_DATE => X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY => X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN => X_LAST_UPDATE_LOGIN);

  IF X_DEFAULT_FIELDS = 'Y' THEN

       INSERT INTO WMS_PAGE_TEMPLATE_FIELDS(PAGE_ID,
                    TEMPLATE_ID,
                    FIELD_ID,
                    FIELD_PROPERTY1_VALUE,
                    FIELD_PROPERTY2_VALUE,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN)
            SELECT PAGE_ID
                    , X_TEMPLATE_ID
                    , FIELD_ID
                    , FIELD_PROPERTY1_DEFAULT_VALUE
                    , FIELD_PROPERTY2_DEFAULT_VALUE
                    , X_CREATION_DATE
                    , X_CREATED_BY
                    , X_LAST_UPDATE_DATE
                    , X_LAST_UPDATED_BY
                    , X_LAST_UPDATE_LOGIN
            FROM WMS_PAGE_FIELDS_B
		WHERE (X_PAGE_ID = 1 AND PAGE_ID in (1,2))
		AND FIELD_IS_CONFIGURABLE = 'Y';
  END IF;

end CREATE_TEMPLATE;

end WMS_PAGE_TEMPLATES_PVT;

/