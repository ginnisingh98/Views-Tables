--------------------------------------------------------
--  DDL for Package BNE_STORED_SQL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_STORED_SQL_PKG" AUTHID CURRENT_USER as
/* $Header: bnestsqls.pls 120.2 2005/06/29 03:41:07 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_CODE in VARCHAR2,
  X_QUERY in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_QUERY_APP_ID in NUMBER,
  X_QUERY_CODE in VARCHAR2);
procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_CODE in VARCHAR2,
  X_QUERY in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_QUERY_APP_ID in NUMBER,
  X_QUERY_CODE in VARCHAR2
);
procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_CODE in VARCHAR2,
  X_QUERY in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_QUERY_APP_ID in NUMBER,
  X_QUERY_CODE in VARCHAR2
);
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_CODE in VARCHAR2
);
procedure ADD_LANGUAGE;
procedure LOAD_ROW(
  x_content_asn           in VARCHAR2,
  x_content_code          in VARCHAR2,
  x_object_version_number in VARCHAR2,
  x_query                 in VARCHAR2,
  x_owner                 in VARCHAR2,
  x_last_update_date      in VARCHAR2,
  x_custom_mode           in VARCHAR2,
  x_query_app_asn         in VARCHAR2 DEFAULT NULL,
  x_query_code            in VARCHAR2 DEFAULT NULL
);

end BNE_STORED_SQL_PKG;

 

/
