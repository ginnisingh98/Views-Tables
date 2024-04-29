--------------------------------------------------------
--  DDL for Package AK_CUSTOM_REGISTRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_CUSTOM_REGISTRY_PKG" AUTHID CURRENT_USER as
/* $Header: AKRGSTYS.pls 120.2 2005/10/14 14:24:18 tshort noship $ */

procedure INSERT_ROW (
X_ROWID                  in out NOCOPY VARCHAR2,
X_CUSTOMIZATION_LEVEL_ID in     NUMBER,
X_CUSTOM_LEVEL           in     VARCHAR2,
X_PROPERTY_NAME          in     VARCHAR2,
X_TRANSLATABLE           in     VARCHAR2,
X_CREATED_BY             in     NUMBER,
X_CREATION_DATE          in     DATE,
X_LAST_UPDATED_BY        in     NUMBER,
X_LAST_UPDATE_DATE       in     DATE,
X_LAST_UPDATE_LOGIN      in     NUMBER
);

procedure LOCK_ROW (
X_CUSTOMIZATION_LEVEL_ID in NUMBER,
X_CUSTOM_LEVEL           in VARCHAR2,
X_PROPERTY_NAME          in VARCHAR2,
X_TRANSLATABLE           in VARCHAR2,
X_CREATED_BY             in NUMBER,
X_CREATION_DATE          in DATE,
X_LAST_UPDATED_BY        in NUMBER,
X_LAST_UPDATE_DATE       in DATE,
X_LAST_UPDATE_LOGIN      in NUMBER
);

procedure UPDATE_ROW (
X_CUSTOMIZATION_LEVEL_ID in NUMBER,
X_CUSTOM_LEVEL           in VARCHAR2,
X_PROPERTY_NAME          in VARCHAR2,
X_TRANSLATABLE           in VARCHAR2,
X_CREATED_BY             in NUMBER,
X_CREATION_DATE          in DATE,
X_LAST_UPDATED_BY        in NUMBER,
X_LAST_UPDATE_DATE       in DATE,
X_LAST_UPDATE_LOGIN      in NUMBER
);

procedure DELETE_ROW (
X_CUSTOMIZATION_LEVEL_ID in NUMBER,
X_CUSTOM_LEVEL           in VARCHAR2,
X_PROPERTY_NAME          in VARCHAR2
);

end AK_CUSTOM_REGISTRY_PKG;

 

/
