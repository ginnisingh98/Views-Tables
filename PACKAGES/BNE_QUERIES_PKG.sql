--------------------------------------------------------
--  DDL for Package BNE_QUERIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_QUERIES_PKG" AUTHID CURRENT_USER as
/* $Header: bnequeriess.pls 120.2 2005/06/29 03:40:49 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_QUERY_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_QUERY_CLASS in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DIRECTIVE_APP_ID in NUMBER DEFAULT NULL,
  X_DIRECTIVE_CODE in VARCHAR2 DEFAULT NULL
);

procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_QUERY_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_QUERY_CLASS in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_DIRECTIVE_APP_ID in NUMBER DEFAULT NULL,
  X_DIRECTIVE_CODE in VARCHAR2 DEFAULT NULL
);

procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_QUERY_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_QUERY_CLASS in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DIRECTIVE_APP_ID in NUMBER DEFAULT NULL,
  X_DIRECTIVE_CODE in VARCHAR2 DEFAULT NULL
);

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_QUERY_CODE in VARCHAR2
);

procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  x_query_asn             IN VARCHAR2,
  x_query_code            IN VARCHAR2,
  x_user_name             IN VARCHAR2,
  x_owner                 IN VARCHAR2,
  x_last_update_date      IN VARCHAR2,
  x_custom_mode           IN VARCHAR2
);
procedure LOAD_ROW(
  x_query_asn             IN VARCHAR2,
  x_query_code            IN VARCHAR2,
  x_object_version_number IN VARCHAR2,
  x_query_class           IN VARCHAR2,
  x_user_name             IN VARCHAR2,
  x_owner                 IN VARCHAR2,
  x_last_update_date      IN VARCHAR2,
  x_custom_mode           IN VARCHAR2,
  x_directive_asn         IN VARCHAR2 DEFAULT NULL,
  x_directive_code        IN VARCHAR2 DEFAULT NULL
);

end BNE_QUERIES_PKG;

 

/
