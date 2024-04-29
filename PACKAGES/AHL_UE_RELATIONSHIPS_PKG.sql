--------------------------------------------------------
--  DDL for Package AHL_UE_RELATIONSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UE_RELATIONSHIPS_PKG" AUTHID CURRENT_USER as
/* $Header: AHLLUERS.pls 115.1 2002/12/04 22:39:51 sracha noship $ */

procedure INSERT_ROW (
   X_UE_RELATIONSHIP_ID    IN OUT NOCOPY NUMBER,
   X_UE_ID                 IN NUMBER,
   X_RELATED_UE_ID         IN NUMBER,
   X_RELATIONSHIP_CODE     IN VARCHAR2,
   X_ORIGINATOR_UE_ID      IN NUMBER,
   X_ATTRIBUTE_CATEGORY    IN VARCHAR2,
   X_ATTRIBUTE1            IN VARCHAR2,
   X_ATTRIBUTE2            IN VARCHAR2,
   X_ATTRIBUTE3            IN VARCHAR2,
   X_ATTRIBUTE4            IN VARCHAR2,
   X_ATTRIBUTE5            IN VARCHAR2,
   X_ATTRIBUTE6            IN VARCHAR2,
   X_ATTRIBUTE7            IN VARCHAR2,
   X_ATTRIBUTE8            IN VARCHAR2,
   X_ATTRIBUTE9            IN VARCHAR2,
   X_ATTRIBUTE10           IN VARCHAR2,
   X_ATTRIBUTE11           IN VARCHAR2,
   X_ATTRIBUTE12           IN VARCHAR2,
   X_ATTRIBUTE13           IN VARCHAR2,
   X_ATTRIBUTE14           IN VARCHAR2,
   X_ATTRIBUTE15           IN VARCHAR2,
   X_OBJECT_VERSION_NUMBER IN NUMBER,
   X_LAST_UPDATE_DATE      IN DATE,
   X_LAST_UPDATED_BY       IN NUMBER,
   X_CREATION_DATE         IN DATE,
   X_CREATED_BY            IN NUMBER,
   X_LAST_UPDATE_LOGIN     IN NUMBER
);


procedure UPDATE_ROW (
   X_UE_RELATIONSHIP_ID    IN NUMBER,
   X_UE_ID                 IN NUMBER,
   X_RELATED_UE_ID         IN NUMBER,
   X_RELATIONSHIP_CODE     IN VARCHAR2,
   X_ORIGINATOR_UE_ID      IN NUMBER,
   X_ATTRIBUTE_CATEGORY    IN VARCHAR2,
   X_ATTRIBUTE1            IN VARCHAR2,
   X_ATTRIBUTE2            IN VARCHAR2,
   X_ATTRIBUTE3            IN VARCHAR2,
   X_ATTRIBUTE4            IN VARCHAR2,
   X_ATTRIBUTE5            IN VARCHAR2,
   X_ATTRIBUTE6            IN VARCHAR2,
   X_ATTRIBUTE7            IN VARCHAR2,
   X_ATTRIBUTE8            IN VARCHAR2,
   X_ATTRIBUTE9            IN VARCHAR2,
   X_ATTRIBUTE10           IN VARCHAR2,
   X_ATTRIBUTE11           IN VARCHAR2,
   X_ATTRIBUTE12           IN VARCHAR2,
   X_ATTRIBUTE13           IN VARCHAR2,
   X_ATTRIBUTE14           IN VARCHAR2,
   X_ATTRIBUTE15           IN VARCHAR2,
   X_OBJECT_VERSION_NUMBER IN NUMBER,
   X_LAST_UPDATE_DATE      IN DATE,
   X_LAST_UPDATED_BY       IN NUMBER,
   X_LAST_UPDATE_LOGIN     IN NUMBER
);

procedure DELETE_ROW (
  X_UE_RELATIONSHIP_ID in NUMBER
);

END AHL_UE_RELATIONSHIPS_PKG;

 

/