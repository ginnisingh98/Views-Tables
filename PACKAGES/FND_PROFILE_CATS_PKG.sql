--------------------------------------------------------
--  DDL for Package FND_PROFILE_CATS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_PROFILE_CATS_PKG" AUTHID CURRENT_USER as
/* $Header: FNDPRCAS.pls 120.2 2005/08/05 12:38:34 stadepal noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_NAME in VARCHAR2,
  X_ENABLED in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_NAME in VARCHAR2,
  X_ENABLED in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_NAME in VARCHAR2,
  X_ENABLED in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER
);
procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_NAME                        in      VARCHAR2,
  X_APPLICATION_SHORT_NAME      in      VARCHAR2,
  X_DESCRIPTION                 in      VARCHAR2,
  X_DISPLAY_NAME                in      VARCHAR2,
  X_CUSTOM_MODE                 in      VARCHAR2,
  X_OWNER                       in      VARCHAR2,
  X_LAST_UPDATE_DATE            in      VARCHAR2);

procedure LOAD_ROW (
  X_NAME                        in      VARCHAR2,
  X_DESCRIPTION			in	VARCHAR2,
  X_DISPLAY_NAME                in      VARCHAR2,
  X_ENABLED                in      VARCHAR2,
  X_APPLICATION_SHORT_NAME      in      VARCHAR2,
  X_OWNER                       in      VARCHAR2,
  X_CUSTOM_MODE                 in      VARCHAR2,
  X_LAST_UPDATE_DATE            in      VARCHAR2);

end FND_PROFILE_CATS_PKG;

 

/
