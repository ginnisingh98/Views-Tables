--------------------------------------------------------
--  DDL for Package FA_RATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RATES_PKG" AUTHID CURRENT_USER as
/* $Header: faxirats.pls 120.4.12010000.2 2009/07/19 10:31:38 glchen ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_METHOD_ID in NUMBER,
  X_YEAR in NUMBER,
  X_PERIOD_PLACED_IN_SERVICE in NUMBER,
  X_RATE in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
procedure LOCK_ROW (
  X_METHOD_ID in NUMBER,
  X_YEAR in NUMBER,
  X_PERIOD_PLACED_IN_SERVICE in NUMBER,
  X_RATE in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
procedure UPDATE_ROW (
  X_METHOD_ID in NUMBER,
  X_YEAR in NUMBER,
  X_PERIOD_PLACED_IN_SERVICE in NUMBER,
  X_RATE in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
procedure DELETE_ROW (
  X_METHOD_ID in NUMBER,
  X_YEAR in NUMBER,
  X_PERIOD_PLACED_IN_SERVICE in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

procedure LOAD_ROW (
   X_METHOD_ID in NUMBER,
   X_OWNER in VARCHAR2,
   X_YEAR in NUMBER,
   X_PERIOD_PLACED_IN_SERVICE in NUMBER,
   X_RATE in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

/*Bug 8355119 overloading function for release specific signatures*/
procedure LOAD_ROW (
   X_CUSTOM_MODE in VARCHAR2,
   X_METHOD_ID in NUMBER,
   X_DB_LAST_UPDATED_BY NUMBER,
   X_DB_LAST_UPDATE_DATE DATE,
   X_OWNER in VARCHAR2,
   X_LAST_UPDATE_DATE in DATE,
   X_YEAR in NUMBER,
   X_PERIOD_PLACED_IN_SERVICE in NUMBER,
   X_RATE in NUMBER,
   p_log_level_rec IN FA_API_TYPES.log_level_rec_type default null
);
/*bug 8355119 adding R12 specific funtion LOAD_SEED_ROW*/
procedure LOAD_SEED_ROW (
   x_upload_mode                         IN VARCHAR2,
   x_custom_mode                         IN VARCHAR2,
   x_method_code                         IN VARCHAR2,
   x_life_in_months                      IN NUMBER,
   x_owner                               IN VARCHAR2,
   x_last_update_date                    IN DATE,
   x_year                                IN NUMBER,
   x_period_placed_in_service            IN NUMBER,
   x_rate                                IN NUMBER);

END FA_RATES_PKG;

/
