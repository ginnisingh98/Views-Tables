--------------------------------------------------------
--  DDL for Package JTF_QUAL_TYPE_USGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_QUAL_TYPE_USGS_PKG" AUTHID CURRENT_USER AS
/* $Header: jtfvqtus.pls 120.0 2005/06/02 18:22:16 appldev ship $ */


PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_QUAL_TYPE_USG_ID               IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_QUAL_TYPE_ID                   IN     NUMBER,
                  x_SOURCE_ID                      IN     NUMBER,

--                  x_PACKAGE_FILENAME               IN     VARCHAR2,
                  x_PACKAGE_NAME                   IN     VARCHAR2,
                  x_PACKAGE_SPOOL_FILENAME         IN     VARCHAR2,

                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_QUAL_TYPE_USG_ID               IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_QUAL_TYPE_ID                   IN     NUMBER,
                  x_SOURCE_ID                      IN     NUMBER,
--                  x_PACKAGE_FILENAME               IN     VARCHAR2,
                  x_PACKAGE_NAME                   IN     VARCHAR2,
                  x_PACKAGE_SPOOL_FILENAME         IN     VARCHAR2,

                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_QUAL_TYPE_USG_ID               IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_QUAL_TYPE_ID                   IN     NUMBER,
                  x_SOURCE_ID                      IN     NUMBER,
--                  x_PACKAGE_FILENAME               IN     VARCHAR2,
                  x_PACKAGE_NAME                   IN     VARCHAR2,
                  x_PACKAGE_SPOOL_FILENAME         IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Delete_Row(                  x_QUAL_TYPE_USG_ID               IN     NUMBER);

END JTF_QUAL_TYPE_USGS_PKG;

 

/
