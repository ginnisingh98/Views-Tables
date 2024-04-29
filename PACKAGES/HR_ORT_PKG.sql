--------------------------------------------------------
--  DDL for Package HR_ORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORT_PKG" AUTHID CURRENT_USER as
/* $Header: hrortlct.pkh 115.1 2002/11/20 13:18:32 tabedin noship $ */
procedure INSERT_ROW (
  X_ORGANIZATION_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure UPDATE_ROW (
  X_ORGANIZATION_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_ORGANIZATION_ID in NUMBER
);
procedure ADD_LANGUAGE;
procedure LOAD_ROW(
 X_ORGANIZATION_ID                IN VARCHAR2,
 X_OWNER          	        IN VARCHAR2,
 X_NAME                         IN VARCHAR2);

procedure TRANSLATE_ROW(
 X_ORGANIZATION_ID                IN VARCHAR2,
 X_OWNER          	        IN VARCHAR2,
 X_NAME                         IN VARCHAR2);
end HR_ORT_PKG;

 

/
