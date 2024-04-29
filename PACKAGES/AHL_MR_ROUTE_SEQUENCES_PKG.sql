--------------------------------------------------------
--  DDL for Package AHL_MR_ROUTE_SEQUENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MR_ROUTE_SEQUENCES_PKG" AUTHID CURRENT_USER as
/* $Header: AHLLMRSS.pls 115.2 2003/10/30 02:59:01 rtadikon noship $ */
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
  X_LAST_UPDATE_LOGIN in NUMBER);

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
);
procedure DELETE_ROW (
  X_MR_ROUTE_SEQUENCE_ID in NUMBER
);
end AHL_MR_ROUTE_SEQUENCES_PKG;

 

/