--------------------------------------------------------
--  DDL for Package JTF_TERR_USGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_USGS_PKG" AUTHID CURRENT_USER AS
/* $Header: jtfvtuss.pls 120.0 2005/06/02 18:23:10 appldev ship $ */

PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_TERR_USG_ID                    IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_ID                        IN     NUMBER,
                  x_SOURCE_ID                      IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_USG_ID                    IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_ID                        IN     NUMBER,
                  x_SOURCE_ID                      IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_USG_ID                    IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_ID                        IN     NUMBER,
                  x_SOURCE_ID                      IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Delete_Row(                  x_TERR_USG_ID                    IN     NUMBER);


END JTF_TERR_USGS_PKG;

 

/
