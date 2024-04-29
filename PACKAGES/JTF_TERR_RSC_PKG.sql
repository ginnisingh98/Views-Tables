--------------------------------------------------------
--  DDL for Package JTF_TERR_RSC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_RSC_PKG" AUTHID CURRENT_USER AS
/* $Header: jtfvtrcs.pls 120.2.12010000.2 2009/09/07 07:08:37 vpalle ship $ */
-- 02/22/00  JDOCHERT  Passing in ORG_ID to Insert/Update/Lock
-- 03/16/00  VNEDUNGA  Adding Full access flag
-- 06/08/00  VNEDUNGA  Adding group_id column
-- 06/26/02  ARPATEL   Adding person_id column
-- 01/09/03  JDOCHERT  BUG#2739970

PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_TERR_RSC_ID                    IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_ID                        IN     NUMBER,
                  x_RESOURCE_ID                    IN     NUMBER,
                  x_GROUP_ID                       IN     NUMBER,
                  x_RESOURCE_TYPE                  IN     VARCHAR2,
                  x_ROLE                           IN     VARCHAR2,
                  x_PRIMARY_CONTACT_FLAG           IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_FULL_ACCESS_FLAG               IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER
 );


PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_TERR_RSC_ID                    IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_ID                        IN     NUMBER,
                  x_RESOURCE_ID                    IN     NUMBER,
                  x_GROUP_ID                       IN     NUMBER,
                  x_RESOURCE_TYPE                  IN     VARCHAR2,
                  x_ROLE                           IN     VARCHAR2,
                  x_PRIMARY_CONTACT_FLAG           IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_FULL_ACCESS_FLAG               IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER,
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
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_RSC_ID                    IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_ID                        IN     NUMBER,
                  x_RESOURCE_ID                    IN     NUMBER,
                  x_GROUP_ID                       IN     NUMBER,
                  x_RESOURCE_TYPE                  IN     VARCHAR2,
                  x_ROLE                           IN     VARCHAR2,
                  x_PRIMARY_CONTACT_FLAG           IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_FULL_ACCESS_FLAG               IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER
 );



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_RSC_ID                    IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_ID                        IN     NUMBER,
                  x_RESOURCE_ID                    IN     NUMBER,
                  x_GROUP_ID                       IN     NUMBER,
                  x_RESOURCE_TYPE                  IN     VARCHAR2,
                  x_ROLE                           IN     VARCHAR2,
                  x_PRIMARY_CONTACT_FLAG           IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_FULL_ACCESS_FLAG               IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER,
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



PROCEDURE Delete_Row(                  x_TERR_RSC_ID                    IN     NUMBER);

END JTF_TERR_RSC_PKG;

/
