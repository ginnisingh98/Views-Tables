--------------------------------------------------------
--  DDL for Package AHL_UF_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UF_HEADERS_PKG" AUTHID CURRENT_USER as
/* $Header: AHLLUFHS.pls 115.2 2002/12/04 22:59:19 sracha noship $ */
PROCEDURE INSERT_ROW (
        X_UF_HEADER_ID            IN OUT NOCOPY NUMBER,
        X_OBJECT_VERSION_NUMBER   IN     NUMBER,
        X_CREATED_BY              IN     NUMBER,
        X_CREATION_DATE           IN     DATE,
        X_LAST_UPDATED_BY         IN     NUMBER,
        X_LAST_UPDATE_DATE        IN     DATE,
        X_LAST_UPDATE_LOGIN       IN     NUMBER,
        X_UNIT_CONFIG_HEADER_ID   IN     NUMBER,
        X_PC_NODE_ID              IN     NUMBER,
        X_INVENTORY_ITEM_ID		  IN     NUMBER,
        X_INVENTORY_ORG_ID        IN     NUMBER,
        X_CSI_ITEM_INSTANCE_ID    IN     NUMBER,
        X_USE_UNIT_FLAG           IN     VARCHAR2,
        X_ATTRIBUTE_CATEGORY      IN     VARCHAR2,
        X_ATTRIBUTE1              IN     VARCHAR2,
        X_ATTRIBUTE2              IN     VARCHAR2,
        X_ATTRIBUTE3              IN     VARCHAR2,
        X_ATTRIBUTE4              IN     VARCHAR2,
        X_ATTRIBUTE5              IN     VARCHAR2,
        X_ATTRIBUTE6              IN     VARCHAR2,
        X_ATTRIBUTE7              IN     VARCHAR2,
        X_ATTRIBUTE8              IN     VARCHAR2,
        X_ATTRIBUTE9              IN     VARCHAR2,
        X_ATTRIBUTE10             IN     VARCHAR2,
        X_ATTRIBUTE11             IN     VARCHAR2,
        X_ATTRIBUTE12             IN     VARCHAR2,
        X_ATTRIBUTE13             IN     VARCHAR2,
        X_ATTRIBUTE14             IN     VARCHAR2,
        X_ATTRIBUTE15             IN     VARCHAR2
);

PROCEDURE UPDATE_ROW (

        X_UF_HEADER_ID            IN     NUMBER,
        X_OBJECT_VERSION_NUMBER   IN     NUMBER,
        X_LAST_UPDATED_BY         IN     NUMBER,
        X_LAST_UPDATE_DATE        IN     DATE,
        X_LAST_UPDATE_LOGIN       IN     NUMBER,
        X_UNIT_CONFIG_HEADER_ID   IN     NUMBER,
        X_PC_NODE_ID              IN     NUMBER,
        X_INVENTORY_ITEM_ID		  IN     NUMBER,
        X_INVENTORY_ORG_ID        IN     NUMBER,
        X_CSI_ITEM_INSTANCE_ID    IN     NUMBER,
        X_USE_UNIT_FLAG           IN     VARCHAR2,
        X_ATTRIBUTE_CATEGORY      IN     VARCHAR2,
        X_ATTRIBUTE1              IN     VARCHAR2,
        X_ATTRIBUTE2              IN     VARCHAR2,
        X_ATTRIBUTE3              IN     VARCHAR2,
        X_ATTRIBUTE4              IN     VARCHAR2,
        X_ATTRIBUTE5              IN     VARCHAR2,
        X_ATTRIBUTE6              IN     VARCHAR2,
        X_ATTRIBUTE7              IN     VARCHAR2,
        X_ATTRIBUTE8              IN     VARCHAR2,
        X_ATTRIBUTE9              IN     VARCHAR2,
        X_ATTRIBUTE10             IN     VARCHAR2,
        X_ATTRIBUTE11             IN     VARCHAR2,
        X_ATTRIBUTE12             IN     VARCHAR2,
        X_ATTRIBUTE13             IN     VARCHAR2,
        X_ATTRIBUTE14             IN     VARCHAR2,
        X_ATTRIBUTE15             IN     VARCHAR2
);


PROCEDURE DELETE_ROW (
  X_UF_HEADER_ID in NUMBER
);

END AHL_UF_HEADERS_PKG;

 

/
