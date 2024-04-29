--------------------------------------------------------
--  DDL for Package Body AHL_MR_ROUTE_SEQUENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MR_ROUTE_SEQUENCES_PKG" as
/* $Header: AHLLMRSB.pls 115.2 2003/10/30 02:59:05 rtadikon noship $ */
procedure INSERT_ROW (
  X_MR_ROUTE_SEQUENCE_ID in out NOCOPY NUMBER,
  X_ATTRIBUTE15 in VARCHAR2,
  X_RELATED_MR_ROUTE_ID in NUMBER,
  X_SEQUENCE_CODE in VARCHAR2,
  X_MR_ROUTE_ID in NUMBER,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into AHL_MR_ROUTE_SEQUENCES (
    ATTRIBUTE15,
    RELATED_MR_ROUTE_ID,
    SEQUENCE_CODE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    MR_ROUTE_ID,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    MR_ROUTE_SEQUENCE_ID,
    OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4
  )
values(
    X_ATTRIBUTE15,
    X_RELATED_MR_ROUTE_ID,
    X_SEQUENCE_CODE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_MR_ROUTE_ID,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    AHL_MR_ROUTE_SEQUENCES_S.NEXTVAL,
    X_OBJECT_VERSION_NUMBER,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4)
    RETURNING MR_ROUTE_SEQUENCE_ID INTO X_MR_ROUTE_SEQUENCE_ID;

end INSERT_ROW;


procedure UPDATE_ROW (
  X_MR_ROUTE_SEQUENCE_ID in NUMBER,
  X_ATTRIBUTE15 in VARCHAR2,
  X_RELATED_MR_ROUTE_ID in NUMBER,
  X_SEQUENCE_CODE in VARCHAR2,
  X_MR_ROUTE_ID in NUMBER,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AHL_MR_ROUTE_SEQUENCES set
    ATTRIBUTE15 = X_ATTRIBUTE15,
    RELATED_MR_ROUTE_ID = X_RELATED_MR_ROUTE_ID,
    SEQUENCE_CODE = X_SEQUENCE_CODE,
    MR_ROUTE_ID = X_MR_ROUTE_ID,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    MR_ROUTE_SEQUENCE_ID = X_MR_ROUTE_SEQUENCE_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where MR_ROUTE_SEQUENCE_ID = X_MR_ROUTE_SEQUENCE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_MR_ROUTE_SEQUENCE_ID in NUMBER
) is
begin
  delete from AHL_MR_ROUTE_SEQUENCES
  where MR_ROUTE_SEQUENCE_ID = X_MR_ROUTE_SEQUENCE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end AHL_MR_ROUTE_SEQUENCES_PKG;

/