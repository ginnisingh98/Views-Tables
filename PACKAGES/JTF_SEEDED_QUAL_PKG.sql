--------------------------------------------------------
--  DDL for Package JTF_SEEDED_QUAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_SEEDED_QUAL_PKG" AUTHID CURRENT_USER AS
/* $Header: jtfvsqls.pls 120.0 2005/06/02 18:22:27 appldev ship $ */


PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_SEEDED_QUAL_ID                 IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_NAME                           IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_SEEDED_QUAL_ID                 IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_NAME                           IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_SEEDED_QUAL_ID                 IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_NAME                           IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Delete_Row( x_SEEDED_QUAL_ID             IN     NUMBER);

PROCEDURE ADD_LANGUAGE;

PROCEDURE LOAD_ROW
  ( x_SEEDED_QUAL_ID IN NUMBER,
    x_description IN VARCHAR2,
    x_name IN VARCHAR2,
    x_owner IN VARCHAR2);

PROCEDURE TRANSLATE_ROW
  ( x_SEEDED_QUAL_ID IN NUMBER,
    x_name IN VARCHAR2,
    x_Description IN VARCHAR2,
    x_owner IN VARCHAR2);



END JTF_SEEDED_QUAL_PKG;

 

/
