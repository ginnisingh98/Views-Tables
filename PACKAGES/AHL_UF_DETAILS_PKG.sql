--------------------------------------------------------
--  DDL for Package AHL_UF_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UF_DETAILS_PKG" AUTHID CURRENT_USER as
/* $Header: AHLLUFDS.pls 115.1 2002/12/04 22:47:16 sracha noship $ */
PROCEDURE INSERT_ROW (
        X_UF_DETAIL_ID            IN OUT NOCOPY NUMBER,
        X_OBJECT_VERSION_NUMBER   IN     NUMBER,
        X_CREATED_BY              IN     NUMBER,
        X_CREATION_DATE           IN     DATE,
        X_LAST_UPDATED_BY         IN     NUMBER,
        X_LAST_UPDATE_DATE        IN     DATE,
        X_LAST_UPDATE_LOGIN       IN     NUMBER,
        X_UF_HEADER_ID            IN     NUMBER,
        X_UOM_CODE                IN     VARCHAR2,
        X_START_DATE              IN     DATE,
        X_END_DATE                IN     DATE,
        X_USAGE_PER_DAY           IN     NUMBER,
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

        X_UF_DETAIL_ID            IN     NUMBER,
        X_OBJECT_VERSION_NUMBER   IN     NUMBER,
        X_LAST_UPDATED_BY         IN     NUMBER,
        X_LAST_UPDATE_DATE        IN     DATE,
        X_LAST_UPDATE_LOGIN       IN     NUMBER,
        X_UF_HEADER_ID            IN     NUMBER,
        X_UOM_CODE                IN     VARCHAR2,
        X_START_DATE              IN     DATE,
        X_END_DATE                IN     DATE,
        X_USAGE_PER_DAY           IN     NUMBER,
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
  X_UF_DETAIL_ID in NUMBER
);

END AHL_UF_DETAILS_PKG;


 

/
