--------------------------------------------------------
--  DDL for Package HR_FORM_WINDOWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_WINDOWS_PKG" AUTHID CURRENT_USER as
/* $Header: hrfwnlct.pkh 115.1 2002/12/10 11:56:42 hjonnala noship $ */
procedure OWNER_TO_WHO (
  X_OWNER in VARCHAR2,
  X_CREATION_DATE out nocopy DATE,
  X_CREATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_DATE out nocopy DATE,
  X_LAST_UPDATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_LOGIN out nocopy NUMBER
);
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_FORM_WINDOW_ID in NUMBER,
  X_WINDOW_NAME in VARCHAR2,
  X_FORM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_USER_WINDOW_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_FORM_WINDOW_ID in NUMBER,
  X_WINDOW_NAME in VARCHAR2,
  X_FORM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_USER_WINDOW_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_FORM_WINDOW_ID in NUMBER,
  X_WINDOW_NAME in VARCHAR2,
  X_FORM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_USER_WINDOW_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_FORM_WINDOW_ID in NUMBER
);
procedure ADD_LANGUAGE;
procedure TRANSLATE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_WINDOW_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_USER_WINDOW_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2);
procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_WINDOW_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in VARCHAR2,
  X_USER_WINDOW_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2);
end HR_FORM_WINDOWS_PKG;

 

/
