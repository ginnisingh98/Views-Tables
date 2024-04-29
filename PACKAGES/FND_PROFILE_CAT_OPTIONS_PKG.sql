--------------------------------------------------------
--  DDL for Package FND_PROFILE_CAT_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_PROFILE_CAT_OPTIONS_PKG" AUTHID CURRENT_USER as
/* $Header: FNDPRCTS.pls 120.5 2006/05/12 02:40:53 stadepal noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_PROFILE_OPTION_ID in NUMBER,
  X_CATEGORY_NAME in VARCHAR2,
  X_PROFILE_OPTION_APPLICATION_I in NUMBER,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_DISPLAY_TYPE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_APPLICATION_ID in NUMBER);
procedure LOCK_ROW (
  X_PROFILE_OPTION_ID in NUMBER,
  X_CATEGORY_NAME in VARCHAR2,
  X_PROFILE_OPTION_APPLICATION_I in NUMBER,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_DISPLAY_TYPE in VARCHAR2,
  X_APPLICATION_ID in NUMBER
);
procedure UPDATE_ROW (
  X_PROFILE_OPTION_ID in NUMBER,
  X_CATEGORY_NAME in VARCHAR2,
  X_PROFILE_OPTION_APPLICATION_I in NUMBER,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_DISPLAY_TYPE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_APPLICATION_ID in NUMBER
);
procedure DELETE_ROW (
  X_PROFILE_OPTION_ID in NUMBER,
  X_CATEGORY_NAME in VARCHAR2,
  X_PROFILE_OPTION_APPLICATION_I in NUMBER,
  X_APPLICATION_ID in NUMBER
);
/** Uncommented ADD_LANGUAGE api to remove the dependency between dropping
 ** this api and FNDNLINS.sql
 **/
procedure ADD_LANGUAGE;
/**** Not Required as TL table is dropped
procedure TRANSLATE_ROW (
  X_PROFILE_OPTION_APP_NAME    in      VARCHAR2,
  X_PROFILE_OPTION_NAME		   in      VARCHAR2,
  X_CATEGORY_NAME 		   in      VARCHAR2,
  X_DESCRIPTION_OVERRIDE         in      VARCHAR2,
  X_CUSTOM_MODE                  in      VARCHAR2,
  X_OWNER                        in      VARCHAR2,
  X_LAST_UPDATE_DATE             in      VARCHAR2);
*************/

/*** Bug 5060938. Added default param X_PROF_APPL_SHORT_NAME to LOAD_ROW api.
 *** This is required to create a Dummy profile option in Fnd_Profile_Options
 *** table when category ldt is uploaded before it's corresponding profile ldt
 *** to handle No-Data-Found issues.
 ***/
procedure LOAD_ROW (
  X_PROFILE_OPTION_NAME		   in      VARCHAR2,
  X_CATEGORY_NAME 		   in      VARCHAR2,
  X_DISPLAY_SEQUENCE 		   in      VARCHAR2,
  X_DISPLAY_TYPE 		   in      VARCHAR2,
  X_OWNER                        in      VARCHAR2,
  X_CUSTOM_MODE                  in      VARCHAR2,
  X_LAST_UPDATE_DATE         	   in      VARCHAR2,
  X_APPLICATION_SHORT_NAME       in VARCHAR2,
  X_PROF_APPL_SHORT_NAME           in      VARCHAR2 default NULL);
end FND_PROFILE_CAT_OPTIONS_PKG;

 

/
