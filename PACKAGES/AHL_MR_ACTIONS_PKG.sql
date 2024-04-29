--------------------------------------------------------
--  DDL for Package AHL_MR_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MR_ACTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: AHLLMRAS.pls 115.2 2002/12/04 19:21:00 rtadikon noship $ */
procedure INSERT_ROW (
  X_ROWID                       in out nocopy     VARCHAR2,
  X_MR_ACTION_ID                in      NUMBER,
  X_OBJECT_VERSION_NUMBER       in      NUMBER,
  X_MR_HEADER_ID                in      NUMBER,
  X_MR_ACTION_CODE              in      VARCHAR2,
  X_PLAN_ID                     in      NUMBER,
  X_ATTRIBUTE_CATEGORY          in      VARCHAR2,
  X_ATTRIBUTE1                  in      VARCHAR2,
  X_ATTRIBUTE2                  in      VARCHAR2,
  X_ATTRIBUTE3                  in      VARCHAR2,
  X_ATTRIBUTE4                  in      VARCHAR2,
  X_ATTRIBUTE5                  in      VARCHAR2,
  X_ATTRIBUTE6                  in      VARCHAR2,
  X_ATTRIBUTE7                  in      VARCHAR2,
  X_ATTRIBUTE8                  in      VARCHAR2,
  X_ATTRIBUTE9                  in      VARCHAR2,
  X_ATTRIBUTE10                 in      VARCHAR2,
  X_ATTRIBUTE11                 in      VARCHAR2,
  X_ATTRIBUTE12                 in      VARCHAR2,
  X_ATTRIBUTE13                 in      VARCHAR2,
  X_ATTRIBUTE14                 in      VARCHAR2,
  X_ATTRIBUTE15                 in      VARCHAR2,
  X_DESCRIPTION                 in      VARCHAR2,
  X_CREATION_DATE               in      DATE,
  X_CREATED_BY                  in      NUMBER,
  X_LAST_UPDATE_DATE            in      DATE,
  X_LAST_UPDATED_BY             in      NUMBER,
  X_LAST_UPDATE_LOGIN           in      NUMBER);
procedure UPDATE_ROW (
  X_MR_ACTION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER       in      NUMBER,
  X_MR_HEADER_ID                in      NUMBER,
  X_MR_ACTION_CODE              in      VARCHAR2,
  X_PLAN_ID                     in      NUMBER,
  X_ATTRIBUTE_CATEGORY          in      VARCHAR2,
  X_ATTRIBUTE1                  in      VARCHAR2,
  X_ATTRIBUTE2                  in      VARCHAR2,
  X_ATTRIBUTE3                  in      VARCHAR2,
  X_ATTRIBUTE4                  in      VARCHAR2,
  X_ATTRIBUTE5                  in      VARCHAR2,
  X_ATTRIBUTE6                  in      VARCHAR2,
  X_ATTRIBUTE7                  in      VARCHAR2,
  X_ATTRIBUTE8                  in      VARCHAR2,
  X_ATTRIBUTE9                  in      VARCHAR2,
  X_ATTRIBUTE10                 in      VARCHAR2,
  X_ATTRIBUTE11                 in      VARCHAR2,
  X_ATTRIBUTE12                 in      VARCHAR2,
  X_ATTRIBUTE13                 in      VARCHAR2,
  X_ATTRIBUTE14                 in      VARCHAR2,
  X_ATTRIBUTE15                 in      VARCHAR2,
  X_DESCRIPTION                 in      VARCHAR2,
  X_LAST_UPDATE_DATE            in      DATE,
  X_LAST_UPDATED_BY             in      NUMBER,
  X_LAST_UPDATE_LOGIN           in      NUMBER
);
procedure DELETE_ROW (
  X_MR_ACTION_ID in NUMBER
);
procedure ADD_LANGUAGE;
end AHL_MR_ACTIONS_PKG;

 

/
