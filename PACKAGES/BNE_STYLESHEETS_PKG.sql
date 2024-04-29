--------------------------------------------------------
--  DDL for Package BNE_STYLESHEETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_STYLESHEETS_PKG" AUTHID CURRENT_USER as
/* $Header: bnesshts.pls 120.3 2005/08/18 07:23:49 dagroves noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_STYLESHEET_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DEFAULT_FLAG in VARCHAR2 DEFAULT NULL,
  X_READ_ONLY_FLAG in VARCHAR2 DEFAULT NULL,
  X_DESCRIPTION in VARCHAR2 DEFAULT NULL);
procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_STYLESHEET_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_NAME in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2 DEFAULT NULL,
  X_READ_ONLY_FLAG in VARCHAR2 DEFAULT NULL,
  X_DESCRIPTION in VARCHAR2 DEFAULT NULL
);
procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_STYLESHEET_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DEFAULT_FLAG in VARCHAR2 DEFAULT NULL,
  X_READ_ONLY_FLAG in VARCHAR2 DEFAULT NULL,
  X_DESCRIPTION in VARCHAR2 DEFAULT NULL
);
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_STYLESHEET_CODE in VARCHAR2
);
procedure ADD_LANGUAGE;
procedure LOAD_ROW(
  x_stylesheet_asn        IN VARCHAR2,
  x_stylesheet_code       IN VARCHAR2,
  x_object_version_number IN VARCHAR2,
  x_user_name             IN VARCHAR2,
  x_owner                 IN VARCHAR2,
  x_last_update_date      IN VARCHAR2,
  x_custom_mode           IN VARCHAR2,
  x_default_flag          IN VARCHAR2 DEFAULT NULL,
  x_read_only_flag        IN VARCHAR2 DEFAULT NULL,
  x_description           IN VARCHAR2 DEFAULT NULL
);
procedure TRANSLATE_ROW(
  x_stylesheet_asn        IN VARCHAR2,
  x_stylesheet_code       IN VARCHAR2,
  x_user_name             IN VARCHAR2,
  x_owner                 IN VARCHAR2,
  x_last_update_date      IN VARCHAR2,
  x_custom_mode           IN VARCHAR2,
  x_description           IN VARCHAR2 DEFAULT NULL
);

end BNE_STYLESHEETS_PKG;

 

/
