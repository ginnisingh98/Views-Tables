--------------------------------------------------------
--  DDL for Package IEX_CASE_DEFINITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_CASE_DEFINITIONS_PKG" AUTHID CURRENT_USER as
/* $Header: iextcdfs.pls 120.0 2004/01/24 03:21:21 appldev noship $*/
-- Start of Comments
-- Package name     : IEX_CASE_DEFINITIONS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          X_ROWID                   in out NOCOPY VARCHAR2,
          x_CASE_DEFINITION_ID      IN  NUMBER,
          x_TABLE_NAME              IN  VARCHAR2,
          x_COLUMN_NAME             IN  VARCHAR2,
          x_COLUMN_VALUE            IN  VARCHAR2,
          x_ACTIVE_FLAG             IN  VARCHAR2,
          x_OBJECT_VERSION_NUMBER   IN  NUMBER,
          x_CAS_ID                  IN  NUMBER,
          X_REQUEST_ID              in  NUMBER,
          X_PROGRAM_APPLICATION_ID  in  NUMBER,
          X_PROGRAM_ID              in  NUMBER,
          X_PROGRAM_UPDATE_DATE     in  DATE,
          X_ATTRIBUTE_CATEGORY      in VARCHAR2,
          X_ATTRIBUTE1              in VARCHAR2,
          X_ATTRIBUTE2              in VARCHAR2,
          X_ATTRIBUTE3              in VARCHAR2,
          X_ATTRIBUTE4              in VARCHAR2,
          X_ATTRIBUTE5              in VARCHAR2,
          X_ATTRIBUTE6              in VARCHAR2,
          X_ATTRIBUTE7              in VARCHAR2,
          X_ATTRIBUTE8              in VARCHAR2,
          X_ATTRIBUTE9              in VARCHAR2,
          X_ATTRIBUTE10             in VARCHAR2,
          X_ATTRIBUTE11             in VARCHAR2,
          X_ATTRIBUTE12             in VARCHAR2,
          X_ATTRIBUTE13             in VARCHAR2,
          X_ATTRIBUTE14             in VARCHAR2,
          X_ATTRIBUTE15             in VARCHAR2,
          X_CREATION_DATE           in DATE,
          X_CREATED_BY              in NUMBER,
          X_LAST_UPDATE_DATE        in DATE,
          X_LAST_UPDATED_BY         in NUMBER,
          X_LAST_UPDATE_LOGIN       in NUMBER);

PROCEDURE Update_Row(
          x_CASE_DEFINITION_ID      IN  NUMBER,
          x_TABLE_NAME              IN  VARCHAR2,
          x_COLUMN_NAME             IN  VARCHAR2,
          x_COLUMN_VALUE            IN  VARCHAR2,
          x_ACTIVE_FLAG             IN  VARCHAR2,
          x_OBJECT_VERSION_NUMBER   IN  NUMBER,
          x_CAS_ID                  IN  NUMBER,
          X_REQUEST_ID              in  NUMBER,
          X_PROGRAM_APPLICATION_ID  in  NUMBER,
          X_PROGRAM_ID              in  NUMBER,
          X_PROGRAM_UPDATE_DATE     in  DATE,
          X_ATTRIBUTE_CATEGORY      in VARCHAR2,
          X_ATTRIBUTE1              in VARCHAR2,
          X_ATTRIBUTE2              in VARCHAR2,
          X_ATTRIBUTE3              in VARCHAR2,
          X_ATTRIBUTE4              in VARCHAR2,
          X_ATTRIBUTE5              in VARCHAR2,
          X_ATTRIBUTE6              in VARCHAR2,
          X_ATTRIBUTE7              in VARCHAR2,
          X_ATTRIBUTE8              in VARCHAR2,
          X_ATTRIBUTE9              in VARCHAR2,
          X_ATTRIBUTE10             in VARCHAR2,
          X_ATTRIBUTE11             in VARCHAR2,
          X_ATTRIBUTE12             in VARCHAR2,
          X_ATTRIBUTE13             in VARCHAR2,
          X_ATTRIBUTE14             in VARCHAR2,
          X_ATTRIBUTE15             in VARCHAR2,
          X_LAST_UPDATE_DATE        in DATE,
          X_LAST_UPDATED_BY         in NUMBER,
          X_LAST_UPDATE_LOGIN       in NUMBER);

/*PROCEDURE Lock_Row(
 x_CASE_DEFINITION_ID      IN  NUMBER,
          x_TABLE_NAME              IN  VARCHAR2,
          x_COLUMN_NAME             IN  VARCHAR2,
          x_COLUMN_VALUE            IN  VARCHAR2,
          x_ACTIVE_FLAG             IN  VARCHAR2,
          x_OBJECT_VERSION_NUMBER   IN  NUMBER,
          x_CAS_ID                  IN  NUMBER,
          X_REQUEST_ID              in  NUMBER,
          X_PROGRAM_APPLICATION_ID  in  NUMBER,
          X_PROGRAM_ID              in  NUMBER,
          X_PROGRAM_UPDATE_DATE     in  DATE,
          X_ATTRIBUTE_CATEGORY      in VARCHAR2,
          X_ATTRIBUTE1              in VARCHAR2,
          X_ATTRIBUTE2              in VARCHAR2,
          X_ATTRIBUTE3              in VARCHAR2,
          X_ATTRIBUTE4              in VARCHAR2,
          X_ATTRIBUTE4              in VARCHAR2,
          X_ATTRIBUTE5              in VARCHAR2,
          X_ATTRIBUTE6              in VARCHAR2,
          X_ATTRIBUTE7              in VARCHAR2,
          X_ATTRIBUTE8              in VARCHAR2,
          X_ATTRIBUTE9              in VARCHAR2,
          X_ATTRIBUTE10             in VARCHAR2,
          X_ATTRIBUTE11             in VARCHAR2,
          X_ATTRIBUTE12             in VARCHAR2,
          X_ATTRIBUTE13             in VARCHAR2,
          X_ATTRIBUTE14             in VARCHAR2,
          X_ATTRIBUTE15             in VARCHAR2,
          X_CREATION_DATE           in DATE,
          X_CREATED_BY              in NUMBER,
          X_LAST_UPDATE_DATE        in DATE,
          X_LAST_UPDATED_BY         in NUMBER,
          X_LAST_UPDATE_LOGIN       in NUMBER);
*/
procedure LOCK_ROW (
  x_CASE_DEFINITION_ID IN NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER);

PROCEDURE Delete_Row(
       x_CASE_DEFINITION_ID IN NUMBER);

End IEX_CASE_DEFINITIONS_PKG;

 

/
