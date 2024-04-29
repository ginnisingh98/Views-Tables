--------------------------------------------------------
--  DDL for Package FA_LOOKUP_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_LOOKUP_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: faxilts.pls 120.4.12010000.2 2009/07/19 10:40:12 glchen ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_USER_MAINTAINABLE in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
procedure LOCK_ROW (
  X_LOOKUP_TYPE in VARCHAR2,
  X_USER_MAINTAINABLE in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
procedure UPDATE_ROW (
  X_LOOKUP_TYPE in VARCHAR2,
  X_USER_MAINTAINABLE in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
procedure DELETE_ROW (
  X_LOOKUP_TYPE in VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
/* bug 8355119 procedure ADD_LANGUAGE;*/
/*Bug 8355119 overloading function for release specific signatures*/
procedure ADD_LANGUAGE(p_log_level_rec    in      fa_api_types.log_level_rec_type default null);
procedure TRANSLATE_ROW (
  X_LOOKUP_TYPE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

/*Bug 8355119 overloading function for release specific signatures*/
procedure TRANSLATE_ROW (
  X_CUSTOM_MODE in VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  p_log_level_rec    in      fa_api_types.log_level_rec_type default null
);

procedure LOAD_ROW (
  X_LOOKUP_TYPE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_USER_MAINTAINABLE in VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

/*Bug 8355119 overloading function for release specific signatures*/
procedure LOAD_ROW (
  X_CUSTOM_MODE in VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE IN DATE,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_USER_MAINTAINABLE in VARCHAR2,
  p_log_level_rec    in      fa_api_types.log_level_rec_type default null
);

/*bug 8355119 adding R12 specific funtion LOAD_SEED_ROW*/
procedure LOAD_SEED_ROW (
             x_upload_mode              IN VARCHAR2,
             x_custom_mode              IN VARCHAR2,
             x_lookup_type              IN VARCHAR2,
             x_owner                    IN VARCHAR2,
             x_last_update_date         IN DATE,
             x_meaning                  IN VARCHAR2,
             x_description              IN VARCHAR2,
             x_user_maintainable        IN VARCHAR2);


end FA_LOOKUP_TYPES_PKG;

/
