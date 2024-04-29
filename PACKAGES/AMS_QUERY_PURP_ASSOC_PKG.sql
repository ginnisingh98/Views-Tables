--------------------------------------------------------
--  DDL for Package AMS_QUERY_PURP_ASSOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_QUERY_PURP_ASSOC_PKG" AUTHID CURRENT_USER as
/* $Header: amstqpas.pls 120.0 2005/05/31 16:00:12 appldev noship $ */
procedure INSERT_ROW (
  X_TEMP_PURPOSE_ASSOC_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_QUERY_TEMPLATE_ID in NUMBER,
  X_PURPOSE_CODE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_TEMP_PURPOSE_ASSOC_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_QUERY_TEMPLATE_ID in NUMBER,
  X_PURPOSE_CODE in VARCHAR2
);
procedure UPDATE_ROW (
  X_TEMP_PURPOSE_ASSOC_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_QUERY_TEMPLATE_ID in NUMBER,
  X_PURPOSE_CODE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_TEMP_PURPOSE_ASSOC_ID in NUMBER
);

PROCEDURE load_row (
  X_TEMP_PURPOSE_ASSOC_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_QUERY_TEMPLATE_ID in NUMBER,
  X_PURPOSE_CODE in VARCHAR2,
  x_owner IN VARCHAR2,
  x_custom_mode IN VARCHAR2
);

end AMS_QUERY_PURP_ASSOC_PKG;

 

/