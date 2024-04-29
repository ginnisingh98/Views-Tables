--------------------------------------------------------
--  DDL for Package JTF_TERR_RSC_ACCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_RSC_ACCESS_PKG" AUTHID CURRENT_USER AS
/* $Header: jtfvrsas.pls 120.2 2005/09/08 17:54:44 applrt ship $ */
-- 02/22/00  JDOCHERT   Passing in ORG_ID to Insert/Update/Lock
-- 09/01/05  mhtran	passing trans_access_code to Insert/Update for R12

PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_TERR_RSC_ACCESS_ID             IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_RSC_ID                    IN     NUMBER,
                  x_ACCESS_TYPE                    IN     VARCHAR2,
		  x_TRANS_ACCESS_CODE 		   IN	  VARCHAR2,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_RSC_ACCESS_ID             IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_RSC_ID                    IN     NUMBER,
                  x_ACCESS_TYPE                    IN     VARCHAR2,
		  x_TRANS_ACCESS_CODE 		   IN	  VARCHAR2,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_RSC_ACCESS_ID             IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_RSC_ID                    IN     NUMBER,
                  x_ACCESS_TYPE                    IN     VARCHAR2,
		  x_TRANS_ACCESS_CODE 		   IN	  VARCHAR2,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Delete_Row(                  x_TERR_RSC_ACCESS_ID             IN     NUMBER);

END JTF_TERR_RSC_ACCESS_PKG;

 

/
