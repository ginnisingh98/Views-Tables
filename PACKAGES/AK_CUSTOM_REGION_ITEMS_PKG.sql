--------------------------------------------------------
--  DDL for Package AK_CUSTOM_REGION_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_CUSTOM_REGION_ITEMS_PKG" AUTHID CURRENT_USER as
/* $Header: AKDCRITS.pls 120.2 2005/09/29 13:59:37 tshort noship $ */
procedure INSERT_ROW (
X_ROWID                        in out NOCOPY VARCHAR2,
X_CUSTOMIZATION_APPLICATION_ID in     NUMBER,
X_CUSTOMIZATION_CODE           in     VARCHAR2,
X_REGION_APPLICATION_ID        in     NUMBER,
X_REGION_CODE                  in     VARCHAR2,
X_ATTRIBUTE_APPLICATION_ID     in     NUMBER,
X_ATTRIBUTE_CODE               in     VARCHAR2,
X_PROPERTY_NAME                in     VARCHAR2,
X_PROPERTY_VARCHAR2_VALUE      in     VARCHAR2,
X_PROPERTY_NUMBER_VALUE        in     NUMBER,
X_PROPERTY_DATE_VALUE          in     DATE,
X_CREATED_BY                   in     NUMBER,
X_CREATION_DATE                in     DATE,
X_LAST_UPDATED_BY              in     NUMBER,
X_LAST_UPDATE_DATE             in     DATE,
X_LAST_UPDATE_LOGIN            in     NUMBER
);

procedure LOCK_ROW (
X_CUSTOMIZATION_APPLICATION_ID in     NUMBER,
X_CUSTOMIZATION_CODE           in     VARCHAR2,
X_REGION_APPLICATION_ID        in     NUMBER,
X_REGION_CODE                  in     VARCHAR2,
X_ATTRIBUTE_APPLICATION_ID     in     NUMBER,
X_ATTRIBUTE_CODE               in     VARCHAR2,
X_PROPERTY_NAME                in     VARCHAR2,
X_PROPERTY_VARCHAR2_VALUE      in     VARCHAR2,
X_PROPERTY_NUMBER_VALUE        in     NUMBER,
X_PROPERTY_DATE_VALUE          in     DATE,
X_CREATED_BY                   in     NUMBER,
X_CREATION_DATE                in     DATE,
X_LAST_UPDATED_BY              in     NUMBER,
X_LAST_UPDATE_DATE             in     DATE,
X_LAST_UPDATE_LOGIN            in     NUMBER
);

procedure UPDATE_ROW (
X_CUSTOMIZATION_APPLICATION_ID in     NUMBER,
X_CUSTOMIZATION_CODE           in     VARCHAR2,
X_REGION_APPLICATION_ID        in     NUMBER,
X_REGION_CODE                  in     VARCHAR2,
X_ATTRIBUTE_APPLICATION_ID     in     NUMBER,
X_ATTRIBUTE_CODE               in     VARCHAR2,
X_PROPERTY_NAME                in     VARCHAR2,
X_PROPERTY_VARCHAR2_VALUE      in     VARCHAR2,
X_PROPERTY_NUMBER_VALUE        in     NUMBER,
X_PROPERTY_DATE_VALUE          in     DATE,
X_LAST_UPDATED_BY              in     NUMBER,
X_LAST_UPDATE_DATE             in     DATE,
X_LAST_UPDATE_LOGIN            in     NUMBER
);

procedure DELETE_ROW (
X_CUSTOMIZATION_APPLICATION_ID in NUMBER,
X_CUSTOMIZATION_CODE           in VARCHAR2,
X_REGION_APPLICATION_ID        in NUMBER,
X_REGION_CODE                  in VARCHAR2,
X_ATTRIBUTE_APPLICATION_ID     in NUMBER,
X_ATTRIBUTE_CODE               in VARCHAR2,
X_PROPERTY_NAME                in VARCHAR2
);

procedure ADD_LANGUAGE;

end AK_CUSTOM_REGION_ITEMS_PKG;

 

/
