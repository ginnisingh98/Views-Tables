--------------------------------------------------------
--  DDL for Package ASO_DEPENDENCY_MAPPINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_DEPENDENCY_MAPPINGS_PKG" AUTHID CURRENT_USER as
/* $Header: asotdeps.pls 120.1 2005/06/29 12:38:46 appldev noship $ */
-- Start of Comments
-- Package name     : ASO_DEPENDENCY_MAPPINGS_PKG
-- Purpose          :
-- History          :
--	  01-28-2005 hyang - created
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
    PX_DEPENDENCY_ID          IN OUT NOCOPY /* file.sql.39 change */  NUMBER
  , P_TRIGGER_ATTRIBUTE_ID    IN      NUMBER
  , P_DEPENDENT_ATTRIBUTE_ID  IN      NUMBER
  , P_ENABLED_FLAG            IN      VARCHAR2
  , P_DATABASE_OBJECT_NAME    IN      VARCHAR2
  , P_APPLICATION_ID          IN      NUMBER
  , P_SEED_TAG                IN      VARCHAR2
  , P_CREATION_DATE           IN      DATE
  , P_CREATED_BY              IN      NUMBER
  , P_LAST_UPDATE_DATE        IN      DATE
  , P_LAST_UPDATE_LOGIN       IN      NUMBER
  , P_LAST_UPDATED_BY         IN      NUMBER
  , P_REQUEST_ID              IN      NUMBER
  , P_PROGRAM_APPLICATION_ID  IN      NUMBER
  , P_PROGRAM_ID              IN      NUMBER
  , P_PROGRAM_UPDATE_DATE     IN      DATE
);

PROCEDURE Update_Row(
    P_DEPENDENCY_ID           IN      NUMBER
  , P_TRIGGER_ATTRIBUTE_ID    IN      NUMBER
  , P_DEPENDENT_ATTRIBUTE_ID  IN      NUMBER
  , P_ENABLED_FLAG            IN      VARCHAR2
  , P_DATABASE_OBJECT_NAME    IN      VARCHAR2
  , P_APPLICATION_ID          IN      NUMBER
  , P_SEED_TAG                IN      VARCHAR2
  , P_CREATION_DATE           IN      DATE
  , P_CREATED_BY              IN      NUMBER
  , P_LAST_UPDATE_DATE        IN      DATE
  , P_LAST_UPDATE_LOGIN       IN      NUMBER
  , P_LAST_UPDATED_BY         IN      NUMBER
  , P_REQUEST_ID              IN      NUMBER
  , P_PROGRAM_APPLICATION_ID  IN      NUMBER
  , P_PROGRAM_ID              IN      NUMBER
  , P_PROGRAM_UPDATE_DATE     IN      DATE
);

PROCEDURE Lock_Row(
    P_DEPENDENCY_ID           IN      NUMBER
  , P_TRIGGER_ATTRIBUTE_ID    IN      NUMBER
  , P_DEPENDENT_ATTRIBUTE_ID  IN      NUMBER
  , P_ENABLED_FLAG            IN      VARCHAR2
  , P_DATABASE_OBJECT_NAME    IN      VARCHAR2
  , P_APPLICATION_ID          IN      NUMBER
  , P_SEED_TAG                IN      VARCHAR2
  , P_CREATION_DATE           IN      DATE
  , P_CREATED_BY              IN      NUMBER
  , P_LAST_UPDATE_DATE        IN      DATE
  , P_LAST_UPDATE_LOGIN       IN      NUMBER
  , P_LAST_UPDATED_BY         IN      NUMBER
  , P_REQUEST_ID              IN      NUMBER
  , P_PROGRAM_APPLICATION_ID  IN      NUMBER
  , P_PROGRAM_ID              IN      NUMBER
  , P_PROGRAM_UPDATE_DATE     IN      DATE
);

PROCEDURE Delete_Row(
    P_DEPENDENCY_ID           IN      NUMBER);

PROCEDURE Load_Row (
    X_DEPENDENCY_ID           IN      NUMBER
  , X_TRIGGER_ATTRIBUTE_ID    IN      NUMBER
  , X_DEPENDENT_ATTRIBUTE_ID  IN      NUMBER
  , X_ENABLED_FLAG            IN      VARCHAR2
  , X_DATABASE_OBJECT_NAME    IN      VARCHAR2
  , X_APPLICATION_ID          IN      NUMBER
  , X_SEED_TAG                IN      VARCHAR2
  , X_OWNER                   IN      VARCHAR2
);


End ASO_DEPENDENCY_MAPPINGS_PKG;


 

/
