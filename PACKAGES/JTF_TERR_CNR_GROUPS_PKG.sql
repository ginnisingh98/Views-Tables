--------------------------------------------------------
--  DDL for Package JTF_TERR_CNR_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_CNR_GROUPS_PKG" AUTHID CURRENT_USER AS
/* $Header: jtfvtcgs.pls 120.0 2005/06/02 18:22:39 appldev ship $ */

-- 01/23/01  Amit Patel - Created package specs for JTF_TERR_CNR_GROUPS_PKG

PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_CNR_GROUP_ID                   IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_NAME                           IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
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
                  x_ATTRIBUTE15                    IN     VARCHAR2
 );


PROCEDURE Delete_Row(
                  x_CNR_GROUP_ID                   IN     NUMBER
 );


PROCEDURE Update_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_CNR_GROUP_ID                   IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_NAME                           IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
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
                  x_ATTRIBUTE15                    IN     VARCHAR2
 );



PROCEDURE Lock_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_CNR_GROUP_ID                   IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_NAME                           IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
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
                  x_ATTRIBUTE15                    IN     VARCHAR2
 );

END JTF_TERR_CNR_GROUPS_PKG;

 

/
