--------------------------------------------------------
--  DDL for Package JTF_TERR_TYPE_QUAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_TYPE_QUAL_PKG" AUTHID CURRENT_USER AS
/* $Header: jtfvttqs.pls 120.0 2005/06/02 18:23:06 appldev ship $ */

-----------------------------------------------------------------------
--    HISTORY
--      11/20/99    VNEDUNGA   Changing qualifer Mode form
--                             number to varchar2
--      02/17/00    VNEDUNGA   Changing Table handler to accept ORG_ID
--
--    End of Comments
------------------------------------------------------------------------

PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_TERR_TYPE_QUAL_ID              IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_QUAL_USG_ID                    IN     NUMBER,
                  x_TERR_TYPE_ID                   IN     NUMBER,
                  x_EXCLUSIVE_USE_FLAG             IN     VARCHAR2,
                  x_OVERLAP_ALLOWED_FLAG           IN     VARCHAR2,
                  x_IN_USE_FLAG                    IN     VARCHAR2,
                  x_QUALIFIER_MODE                 IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_TYPE_QUAL_ID              IN     NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_QUAL_USG_ID                    IN     NUMBER,
                  x_TERR_TYPE_ID                   IN     NUMBER,
                  x_EXCLUSIVE_USE_FLAG             IN     VARCHAR2,
                  x_OVERLAP_ALLOWED_FLAG           IN     VARCHAR2,
                  x_IN_USE_FLAG                    IN     VARCHAR2,
                  x_QUALIFIER_MODE                 IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_TYPE_QUAL_ID              IN     NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_QUAL_USG_ID                    IN     NUMBER,
                  x_TERR_TYPE_ID                   IN     NUMBER,
                  x_EXCLUSIVE_USE_FLAG             IN     VARCHAR2,
                  x_OVERLAP_ALLOWED_FLAG           IN     VARCHAR2,
                  x_IN_USE_FLAG                    IN     VARCHAR2,
                  x_QUALIFIER_MODE                 IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER);


PROCEDURE Delete_Row(                  x_TERR_TYPE_QUAL_ID              IN     NUMBER);

END JTF_TERR_TYPE_QUAL_PKG;

 

/
