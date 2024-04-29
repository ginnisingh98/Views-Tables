--------------------------------------------------------
--  DDL for Package FRM_DOCUMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FRM_DOCUMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: frmdocs.pls 120.2 2005/09/29 00:09:20 ghooker noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DOCUMENT_ID in NUMBER,
  X_DIRECTORY_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_EXPANDED_FLAG in VARCHAR2,
  X_DS_APP_SHORT_NAME in VARCHAR2,
  X_DATA_SOURCE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_DOCUMENT_ID in NUMBER,
  X_DIRECTORY_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_EXPANDED_FLAG in VARCHAR2,
  X_DS_APP_SHORT_NAME in VARCHAR2,
  X_DATA_SOURCE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_NAME in VARCHAR2
);
procedure UPDATE_ROW (
  X_DOCUMENT_ID in NUMBER,
  X_DIRECTORY_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_EXPANDED_FLAG in VARCHAR2,
  X_DS_APP_SHORT_NAME in VARCHAR2,
  X_DATA_SOURCE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_DOCUMENT_ID in NUMBER
);
procedure ADD_LANGUAGE;

procedure LOAD_ROW(
  x_document_id           IN VARCHAR2,
  x_directory_id          IN VARCHAR2,
  x_sequence_number       IN VARCHAR2,
  x_expanded_flag         IN VARCHAR2,
  x_ds_app_short_name     IN VARCHAR2,
  x_data_source_code      IN VARCHAR2,
  x_object_version_number IN VARCHAR2,
  x_user_name             IN VARCHAR2,
  x_owner                 IN VARCHAR2,
  x_last_update_date      IN VARCHAR2,
  x_custom_mode           IN VARCHAR2
);

procedure TRANSLATE_ROW(
  x_document_id           IN VARCHAR2,
  x_user_name             IN VARCHAR2,
  x_owner                 IN VARCHAR2,
  x_last_update_date      IN VARCHAR2,
  x_custom_mode           IN VARCHAR2
);

end FRM_DOCUMENTS_PKG;

 

/
