--------------------------------------------------------
--  DDL for Package JTF_TERR_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: jtfvtrts.pls 120.0 2005/06/02 18:23:00 appldev ship $ */

-- 02/17/00 	VNEDUNGA   Changing Table handler to accept ORG_ID

PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_TERR_TYPE_ID                   IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_APPLICATION_SHORT_NAME         IN     VARCHAR2,
                  x_NAME                           IN     VARCHAR2,
                  x_ENABLED_FLAG                   IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_ATTRIBUTE_CATEGORY             IN     VARCHAR2,
                  x_ATTRIBUTE1                     IN     VARCHAR2,
                  x_ATTRIBUTE2                     IN     VARCHAR2,
                  x_ATTRIBUTE3                     IN     VARCHAR2,
                  x_ATTRIBUTE4                     IN     VARCHAR2,
                  x_ATTRIBUTE5                     IN     VARCHAR2,
                  x_ATTRIBUTE6                     IN     VARCHAR2,
                  x_ATTRIBUTE7                     IN     VARCHAR2,
                  x_ATTRIBUTE8                     IN     VARCHAR2,
                  x_ATTRIBUTE9                     IN     VARCHAR2,
                  x_ATTRIBUTE10                    IN     VARCHAR2,
                  x_ATTRIBUTE11                    IN     VARCHAR2,
                  x_ATTRIBUTE12                    IN     VARCHAR2,
                  x_ATTRIBUTE13                    IN     VARCHAR2,
                  x_ATTRIBUTE14                    IN     VARCHAR2,
                  x_ATTRIBUTE15                    IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_TYPE_ID                   IN     NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_APPLICATION_SHORT_NAME         IN     VARCHAR2,
                  x_NAME                           IN     VARCHAR2,
                  x_ENABLED_FLAG                   IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_ATTRIBUTE_CATEGORY             IN     VARCHAR2,
                  x_ATTRIBUTE1                     IN     VARCHAR2,
                  x_ATTRIBUTE2                     IN     VARCHAR2,
                  x_ATTRIBUTE3                     IN     VARCHAR2,
                  x_ATTRIBUTE4                     IN     VARCHAR2,
                  x_ATTRIBUTE5                     IN     VARCHAR2,
                  x_ATTRIBUTE6                     IN     VARCHAR2,
                  x_ATTRIBUTE7                     IN     VARCHAR2,
                  x_ATTRIBUTE8                     IN     VARCHAR2,
                  x_ATTRIBUTE9                     IN     VARCHAR2,
                  x_ATTRIBUTE10                    IN     VARCHAR2,
                  x_ATTRIBUTE11                    IN     VARCHAR2,
                  x_ATTRIBUTE12                    IN     VARCHAR2,
                  x_ATTRIBUTE13                    IN     VARCHAR2,
                  x_ATTRIBUTE14                    IN     VARCHAR2,
                  x_ATTRIBUTE15                    IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_TYPE_ID                   IN     NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_APPLICATION_SHORT_NAME         IN     VARCHAR2,
                  x_NAME                           IN     VARCHAR2,
                  x_ENABLED_FLAG                   IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_ATTRIBUTE_CATEGORY             IN     VARCHAR2,
                  x_ATTRIBUTE1                     IN     VARCHAR2,
                  x_ATTRIBUTE2                     IN     VARCHAR2,
                  x_ATTRIBUTE3                     IN     VARCHAR2,
                  x_ATTRIBUTE4                     IN     VARCHAR2,
                  x_ATTRIBUTE5                     IN     VARCHAR2,
                  x_ATTRIBUTE6                     IN     VARCHAR2,
                  x_ATTRIBUTE7                     IN     VARCHAR2,
                  x_ATTRIBUTE8                     IN     VARCHAR2,
                  x_ATTRIBUTE9                     IN     VARCHAR2,
                  x_ATTRIBUTE10                    IN     VARCHAR2,
                  x_ATTRIBUTE11                    IN     VARCHAR2,
                  x_ATTRIBUTE12                    IN     VARCHAR2,
                  x_ATTRIBUTE13                    IN     VARCHAR2,
                  x_ATTRIBUTE14                    IN     VARCHAR2,
                  x_ATTRIBUTE15                    IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Delete_Row(                  x_TERR_TYPE_ID                   IN     NUMBER);

END JTF_TERR_TYPES_PKG;

 

/
