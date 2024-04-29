--------------------------------------------------------
--  DDL for Package JTF_AM_SCREEN_SETUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_AM_SCREEN_SETUPS_PKG" AUTHID CURRENT_USER as
/* $Header: jtfamtss.pls 115.2 2002/12/03 21:02:02 sroychou ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SCREEN_SETUP_ID in NUMBER,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_ATTRIBUTE11 in VARCHAR2,
  X_MODE_ASSIST in VARCHAR2,
  X_MODE_UNASSIST in VARCHAR2,
  X_CONTRACTS in VARCHAR2,
  X_INSTALLED_BASE in VARCHAR2,
  X_TERRITORY in VARCHAR2,
  X_AVAILABILITY in VARCHAR2,
  X_DOCUMENT_TYPE in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_WINDOW_WIDTH in NUMBER,
  X_WINDOW_HEIGHT in NUMBER,
  X_WINDOW_X_POSITION in NUMBER,
  X_WINDOW_Y_POSITION in NUMBER,
  X_DOC_DTLS_USER_VALUES in VARCHAR2,
  X_SHOW_SELECTED_TIME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_ID in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_DOC_DETAILS in VARCHAR2,
  X_PREFERENCE_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_SCREEN_SETUP_ID in NUMBER,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_ATTRIBUTE11 in VARCHAR2,
  X_MODE_ASSIST in VARCHAR2,
  X_MODE_UNASSIST in VARCHAR2,
  X_CONTRACTS in VARCHAR2,
  X_INSTALLED_BASE in VARCHAR2,
  X_TERRITORY in VARCHAR2,
  X_AVAILABILITY in VARCHAR2,
  X_DOCUMENT_TYPE in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_WINDOW_WIDTH in NUMBER,
  X_WINDOW_HEIGHT in NUMBER,
  X_WINDOW_X_POSITION in NUMBER,
  X_WINDOW_Y_POSITION in NUMBER,
  X_DOC_DTLS_USER_VALUES in VARCHAR2,
  X_SHOW_SELECTED_TIME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_ID in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_DOC_DETAILS in VARCHAR2,
  X_PREFERENCE_NAME in VARCHAR2
);
procedure UPDATE_ROW (
  X_SCREEN_SETUP_ID in NUMBER,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_ATTRIBUTE11 in VARCHAR2,
  X_MODE_ASSIST in VARCHAR2,
  X_MODE_UNASSIST in VARCHAR2,
  X_CONTRACTS in VARCHAR2,
  X_INSTALLED_BASE in VARCHAR2,
  X_TERRITORY in VARCHAR2,
  X_AVAILABILITY in VARCHAR2,
  X_DOCUMENT_TYPE in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_WINDOW_WIDTH in NUMBER,
  X_WINDOW_HEIGHT in NUMBER,
  X_WINDOW_X_POSITION in NUMBER,
  X_WINDOW_Y_POSITION in NUMBER,
  X_DOC_DTLS_USER_VALUES in VARCHAR2,
  X_SHOW_SELECTED_TIME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_ID in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_DOC_DETAILS in VARCHAR2,
  X_PREFERENCE_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_SCREEN_SETUP_ID in NUMBER
);
procedure ADD_LANGUAGE;
procedure LOAD_ROW (
  X_OWNER           in VARCHAR2,
  X_SCREEN_SETUP_ID in NUMBER,
  X_MODE_ASSIST in VARCHAR2,
  X_MODE_UNASSIST in VARCHAR2,
  X_CONTRACTS in VARCHAR2,
  X_INSTALLED_BASE in VARCHAR2,
  X_TERRITORY in VARCHAR2,
  X_AVAILABILITY in VARCHAR2,
  X_DOCUMENT_TYPE in VARCHAR2,
  X_WINDOW_WIDTH in NUMBER,
  X_WINDOW_HEIGHT in NUMBER,
  X_WINDOW_X_POSITION in NUMBER,
  X_WINDOW_Y_POSITION in NUMBER,
  X_DOC_DTLS_USER_VALUES in VARCHAR2,
  X_SHOW_SELECTED_TIME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_ID in NUMBER,
  X_DOC_DETAILS in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_PREFERENCE_NAME in VARCHAR2);

Procedure TRANSLATE_ROW
(X_screen_setup_id  in number,
 X_preference_name in varchar2,
 x_Last_update_date in date,
 x_last_updated_by in number,
 x_last_update_login in number);

end JTF_AM_SCREEN_SETUPS_PKG;

 

/