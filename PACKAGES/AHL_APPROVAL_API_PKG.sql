--------------------------------------------------------
--  DDL for Package AHL_APPROVAL_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_APPROVAL_API_PKG" AUTHID CURRENT_USER as
/* $Header: AHLLAPIS.pls 115.3 2002/12/04 00:04:29 ssurapan noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPROVAL_API_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_API_USED_BY in VARCHAR2,
  X_APPROVAL_OBJECT_TYPE in VARCHAR2,
  X_APPROVAL_TYPE in VARCHAR2,
  X_ACTIVITY_TYPE in VARCHAR2,
  X_PACKAGE_NAME in VARCHAR2,
  X_PROCEDURE_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure UPDATE_ROW (
  X_APPROVAL_API_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_API_USED_BY in VARCHAR2,
  X_APPROVAL_OBJECT_TYPE in VARCHAR2,
  X_APPROVAL_TYPE in VARCHAR2,
  X_ACTIVITY_TYPE in VARCHAR2,
  X_PACKAGE_NAME in VARCHAR2,
  X_PROCEDURE_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW
(
  X_APPROVAL_API_ID in NUMBER
);


procedure  LOAD_ROW(
  X_APPROVAL_API_ID in NUMBER,
  X_API_USED_BY in VARCHAR2,
  X_APPROVAL_OBJECT_TYPE in VARCHAR2,
  X_APPROVAL_TYPE in VARCHAR2,
  X_ACTIVITY_TYPE in VARCHAR2,
  X_PACKAGE_NAME in VARCHAR2,
  X_PROCEDURE_NAME in VARCHAR2,
  X_OWNER in VARCHAR2
    ) ;



END ahl_approval_api_pkg;

 

/
