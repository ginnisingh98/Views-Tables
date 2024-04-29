--------------------------------------------------------
--  DDL for Package Body AHL_UE_RELATIONSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UE_RELATIONSHIPS_PKG" as
/* $Header: AHLLUERB.pls 115.1 2002/12/04 22:38:15 sracha noship $ */

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
) is

  cursor C is select ROWID from AHL_UE_RELATIONSHIPS
    where UE_RELATIONSHIP_ID = X_UE_RELATIONSHIP_ID
    ;

  l_ROWID  ROWID;

begin
  insert into AHL_UE_RELATIONSHIPS (
     UE_RELATIONSHIP_ID,
     UE_ID,
     RELATED_UE_ID,
     RELATIONSHIP_CODE,
     ORIGINATOR_UE_ID ,
     ATTRIBUTE_CATEGORY,
     ATTRIBUTE1,
     ATTRIBUTE2,
     ATTRIBUTE3,
     ATTRIBUTE4,
     ATTRIBUTE5,
     ATTRIBUTE6,
     ATTRIBUTE7,
     ATTRIBUTE8,
     ATTRIBUTE9,
     ATTRIBUTE10,
     ATTRIBUTE11,
     ATTRIBUTE12,
     ATTRIBUTE13,
     ATTRIBUTE14,
     ATTRIBUTE15,
     OBJECT_VERSION_NUMBER,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_LOGIN
    ) values (
     AHL_UE_RELATIONSHIPS_S.NEXTVAL,
     X_UE_ID,
     X_RELATED_UE_ID,
     X_RELATIONSHIP_CODE,
     X_ORIGINATOR_UE_ID,
     X_ATTRIBUTE_CATEGORY,
     X_ATTRIBUTE1,
     X_ATTRIBUTE2,
     X_ATTRIBUTE3,
     X_ATTRIBUTE4,
     X_ATTRIBUTE5,
     X_ATTRIBUTE6,
     X_ATTRIBUTE7,
     X_ATTRIBUTE8,
     X_ATTRIBUTE9,
     X_ATTRIBUTE10,
     X_ATTRIBUTE11,
     X_ATTRIBUTE12,
     X_ATTRIBUTE13,
     X_ATTRIBUTE14,
     X_ATTRIBUTE15,
     X_OBJECT_VERSION_NUMBER,
     X_LAST_UPDATE_DATE,
     X_LAST_UPDATED_BY,
     X_CREATION_DATE,
     X_CREATED_BY,
     X_LAST_UPDATE_LOGIN
) RETURNING UE_RELATIONSHIP_ID INTO X_UE_RELATIONSHIP_ID;

  open c;
  fetch c into l_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;


end INSERT_ROW;


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
) is

begin
  update AHL_UE_RELATIONSHIPS set
    UE_ID           = X_UE_ID,
    RELATED_UE_ID   = X_RELATED_UE_ID,
    RELATIONSHIP_CODE = X_RELATIONSHIP_CODE,
    ORIGINATOR_UE_ID  = X_ORIGINATOR_UE_ID,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1         = X_ATTRIBUTE1,
    ATTRIBUTE2         = X_ATTRIBUTE2,
    ATTRIBUTE3         = X_ATTRIBUTE3,
    ATTRIBUTE4         = X_ATTRIBUTE4,
    ATTRIBUTE5         = X_ATTRIBUTE5,
    ATTRIBUTE6         = X_ATTRIBUTE6,
    ATTRIBUTE7         = X_ATTRIBUTE7,
    ATTRIBUTE8         = X_ATTRIBUTE8,
    ATTRIBUTE9         = X_ATTRIBUTE9,
    ATTRIBUTE10        = X_ATTRIBUTE10,
    ATTRIBUTE11        = X_ATTRIBUTE11,
    ATTRIBUTE12        = X_ATTRIBUTE12,
    ATTRIBUTE13        = X_ATTRIBUTE13,
    ATTRIBUTE14        = X_ATTRIBUTE14,
    ATTRIBUTE15        = X_ATTRIBUTE15,
    OBJECT_VERSION_NUMBER  = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE   = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY    = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN  = X_LAST_UPDATE_LOGIN

  where UE_RELATIONSHIP_ID = X_UE_RELATIONSHIP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_UE_RELATIONSHIP_ID in NUMBER
) is

begin

  delete from AHL_UE_RELATIONSHIPS
  where UE_RELATIONSHIP_ID = X_UE_RELATIONSHIP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

END AHL_UE_RELATIONSHIPS_PKG;

/
