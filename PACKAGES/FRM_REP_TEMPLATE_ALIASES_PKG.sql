--------------------------------------------------------
--  DDL for Package FRM_REP_TEMPLATE_ALIASES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FRM_REP_TEMPLATE_ALIASES_PKG" AUTHID CURRENT_USER as
/* $Header: frmrepaliass.pls 120.2 2005/09/29 00:19:16 ghooker noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_CONCURRENT_PROGRAM_NAME in VARCHAR2,
  X_ELEMENT_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_CONCURRENT_PROGRAM_NAME in VARCHAR2,
  X_ELEMENT_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_NAME in VARCHAR2
);
procedure UPDATE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_CONCURRENT_PROGRAM_NAME in VARCHAR2,
  X_ELEMENT_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_CONCURRENT_PROGRAM_NAME in VARCHAR2,
  X_ELEMENT_NAME in VARCHAR2
);
procedure ADD_LANGUAGE;

procedure LOAD_ROW(
  x_application_short_name   IN VARCHAR2,
  x_concurrent_program_name  IN VARCHAR2,
  x_element_name             IN VARCHAR2,
  x_object_version_number    IN VARCHAR2,
  x_user_name                IN VARCHAR2,
  x_owner                    IN VARCHAR2,
  x_last_update_date         IN VARCHAR2,
  x_custom_mode              IN VARCHAR2
);

procedure TRANSLATE_ROW(
  x_application_short_name   IN VARCHAR2,
  x_concurrent_program_name  IN VARCHAR2,
  x_element_name             IN VARCHAR2,
  x_user_name                IN VARCHAR2,
  x_owner                    IN VARCHAR2,
  x_last_update_date         IN VARCHAR2,
  x_custom_mode              IN VARCHAR2
);

end FRM_REP_TEMPLATE_ALIASES_PKG;

 

/
