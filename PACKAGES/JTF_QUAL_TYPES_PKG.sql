--------------------------------------------------------
--  DDL for Package JTF_QUAL_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_QUAL_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: jtfvqtys.pls 120.0 2005/06/02 18:22:17 appldev ship $ */

PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_QUAL_TYPE_ID                   IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_NAME                           IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_SELECT_CLAUSE                  IN     VARCHAR2,
                  x_WHERE_CLAUSE                   IN     VARCHAR2,
                  x_VIEW_NAME                      IN     VARCHAR2,
                  x_VIEW_DDL_FILENAME              IN     VARCHAR2,
                  x_RELATED_ID1                    IN     NUMBER,
                  x_RELATED_ID2                    IN     NUMBER,
                  x_RELATED_ID3                    IN     NUMBER,
                  x_RELATED_ID4                    IN     NUMBER,
                  x_RELATED_ID5                    IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_QUAL_TYPE_ID                   IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_NAME                           IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_SELECT_CLAUSE                  IN     VARCHAR2,
                  x_WHERE_CLAUSE                   IN     VARCHAR2,
                  x_VIEW_NAME                      IN     VARCHAR2,
                  x_VIEW_DDL_FILENAME              IN     VARCHAR2,
                  x_RELATED_ID1                    IN     NUMBER,
                  x_RELATED_ID2                    IN     NUMBER,
                  x_RELATED_ID3                    IN     NUMBER,
                  x_RELATED_ID4                    IN     NUMBER,
                  x_RELATED_ID5                    IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_QUAL_TYPE_ID                   IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_NAME                           IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_SELECT_CLAUSE                  IN     VARCHAR2,
                  x_WHERE_CLAUSE                   IN     VARCHAR2,
                  x_VIEW_NAME                      IN     VARCHAR2,
                  x_VIEW_DDL_FILENAME              IN     VARCHAR2,
                  x_RELATED_ID1                    IN     NUMBER,
                  x_RELATED_ID2                    IN     NUMBER,
                  x_RELATED_ID3                    IN     NUMBER,
                  x_RELATED_ID4                    IN     NUMBER,
                  x_RELATED_ID5                    IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER);


PROCEDURE Delete_Row(                  x_QUAL_TYPE_ID                   IN     NUMBER);

END JTF_QUAL_TYPES_PKG;

 

/
