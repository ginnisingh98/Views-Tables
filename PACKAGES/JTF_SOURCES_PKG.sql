--------------------------------------------------------
--  DDL for Package JTF_SOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_SOURCES_PKG" AUTHID CURRENT_USER AS
/* $Header: jtfvsrcs.pls 120.5 2006/03/28 18:20:36 achanda ship $ */
--
-- arpatel   06/25/01 - Added related_id columns (1-5) to insert/update/lock procedures
--


PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_SOURCE_ID                      IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_LOOKUP_CODE                    IN     VARCHAR2,
                  x_LOOKUP_TYPE                    IN     VARCHAR2,
                  x_MEANING                        IN     VARCHAR2,
                  x_ENABLED_FLAG                   IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_RELATED_ID1                    IN	  NUMBER,
                  x_RELATED_ID2                    IN	  NUMBER,
                  x_RELATED_ID3                    IN	  NUMBER,
                  x_RELATED_ID4                    IN	  NUMBER,
                  x_RELATED_ID5                    IN	  NUMBER,
                  X_RSC_COL_NAME                   IN     VARCHAR2,
                  X_ROLE_COL_NAME                  IN     VARCHAR2,
                  X_GROUP_COL_NAME                 IN     VARCHAR2,
                  X_RSC_LOV_SQL                    IN     VARCHAR2,
                  X_RSC_ACCESS_LKUP                IN     VARCHAR2,
                  X_DENORM_VALUE_TABLE_NAME        IN     VARCHAR2,
                  X_DENORM_DEA_VALUE_TABLE_NAME    IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_SOURCE_ID                      IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_LOOKUP_CODE                    IN     VARCHAR2,
                  x_LOOKUP_TYPE                    IN     VARCHAR2,
                  x_MEANING                        IN     VARCHAR2,
                  x_ENABLED_FLAG                   IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_RELATED_ID1                    IN	  NUMBER,
                  x_RELATED_ID2                    IN	  NUMBER,
                  x_RELATED_ID3                    IN	  NUMBER,
                  x_RELATED_ID4                    IN	  NUMBER,
                  x_RELATED_ID5                    IN	  NUMBER,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_SOURCE_ID                      IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_LOOKUP_CODE                    IN     VARCHAR2,
                  x_LOOKUP_TYPE                    IN     VARCHAR2,
                  x_MEANING                        IN     VARCHAR2,
                  x_ENABLED_FLAG                   IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_RELATED_ID1                    IN	  NUMBER,
                  x_RELATED_ID2                    IN	  NUMBER,
                  x_RELATED_ID3                    IN	  NUMBER,
                  x_RELATED_ID4                    IN	  NUMBER,
                  x_RELATED_ID5                    IN	  NUMBER,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Delete_Row(                  x_SOURCE_ID                      IN     NUMBER);


END JTF_SOURCES_PKG;

 

/
