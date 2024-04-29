--------------------------------------------------------
--  DDL for Package JTF_TYPE_QTYPE_USGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TYPE_QTYPE_USGS_PKG" AUTHID CURRENT_USER as
/* $Header: jtfvtqus.pls 115.1 2000/02/29 18:25:52 pkm ship      $ */


-- 02/17/00 	VNEDUNGA   Changing Table handler to accept ORG_ID

PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT VARCHAR2,
                  x_TYPE_QTYPE_USG_ID              IN OUT NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_TYPE_ID                   IN     NUMBER,
                  x_QUAL_TYPE_USG_ID               IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TYPE_QTYPE_USG_ID              IN     NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_TYPE_ID                   IN     NUMBER,
                  x_QUAL_TYPE_USG_ID               IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TYPE_QTYPE_USG_ID              IN     NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_TYPE_ID                   IN     NUMBER,
                  x_QUAL_TYPE_USG_ID               IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Delete_Row(                  x_TYPE_QTYPE_USG_ID              IN     NUMBER);


END JTF_TYPE_QTYPE_USGS_PKG;

 

/
