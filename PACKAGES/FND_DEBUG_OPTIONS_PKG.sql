--------------------------------------------------------
--  DDL for Package FND_DEBUG_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_DEBUG_OPTIONS_PKG" AUTHID CURRENT_USER as
-- $Header: AFOAMDOS.pls 120.1 2005/07/02 03:02:41 appldev noship $


    procedure LOAD_ROW (
           X_DEBUG_OPTION_NAME in VARCHAR2,
           X_ENABLED_FLAG in VARCHAR2,
           X_TYPE in VARCHAR2,
           X_SEPARATOR in VARCHAR2,
           X_TRACE_FILE_TOKEN in VARCHAR2,
           X_DESCRIPTION in VARCHAR2,
           X_OWNER in VARCHAR2);

   procedure LOAD_ROW (
    X_DEBUG_OPTION_NAME in VARCHAR2,
          X_ENABLED_FLAG in VARCHAR2,
          X_TYPE in VARCHAR2,
          X_SEPARATOR in VARCHAR2,
          X_TRACE_FILE_TOKEN in VARCHAR2,
          X_DESCRIPTION in VARCHAR2,
    x_custom_mode         in      varchar2,
    x_last_update_date    in      varchar2,
    X_OWNER               in         VARCHAR2);

    procedure INSERT_ROW (
           X_ROWID in out nocopy VARCHAR2,
           X_DEBUG_OPTION_NAME in VARCHAR2,
           X_ENABLED_FLAG in VARCHAR2,
           X_TYPE in VARCHAR2,
           X_SEPARATOR in VARCHAR2,
           X_TRACE_FILE_TOKEN in VARCHAR2,
           X_DESCRIPTION in VARCHAR2,
           X_CREATION_DATE in DATE,
           X_CREATED_BY in NUMBER,
           X_LAST_UPDATE_DATE in DATE,
           X_LAST_UPDATED_BY in NUMBER,
           X_LAST_UPDATE_LOGIN in NUMBER
);



         procedure UPDATE_ROW (
           X_DEBUG_OPTION_NAME in VARCHAR2,
           X_ENABLED_FLAG in VARCHAR2,
           X_TYPE in VARCHAR2,
           X_SEPARATOR in VARCHAR2,
           X_TRACE_FILE_TOKEN in VARCHAR2,
           X_DESCRIPTION in VARCHAR2,
           X_LAST_UPDATE_DATE in DATE,
           X_LAST_UPDATED_BY in NUMBER,
           X_LAST_UPDATE_LOGIN in NUMBER);


  procedure LOCK_ROW (
    X_DEBUG_OPTION_NAME in VARCHAR2,
    X_ENABLED_FLAG in VARCHAR2,
    X_TYPE in VARCHAR2,
    X_SEPARATOR in VARCHAR2,
    X_TRACE_FILE_TOKEN in VARCHAR2,
    X_DESCRIPTION in VARCHAR2
  );

  procedure DELETE_ROW (
    X_DEBUG_OPTION_NAME in VARCHAR2
  );
  procedure ADD_LANGUAGE;

   procedure TRANSLATE_ROW (
     X_DEBUG_OPTION_NAME in VARCHAR2,
     X_OWNER                     in         VARCHAR2,
     X_DESCRIPTION in VARCHAR2);

   procedure TRANSLATE_ROW (
     X_DEBUG_OPTION_NAME in VARCHAR2,
     X_OWNER in VARCHAR2,
     X_DESCRIPTION in VARCHAR2,
     X_CUSTOM_MODE in VARCHAR2,
     X_LAST_UPDATE_DATE         in VARCHAR2);





end FND_DEBUG_OPTIONS_PKG;

 

/
