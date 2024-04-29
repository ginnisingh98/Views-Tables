--------------------------------------------------------
--  DDL for Package FA_PERIOD_MAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_PERIOD_MAPS_PKG" AUTHID CURRENT_USER as
/* $Header: faxipdms.pls 120.4.12010000.2 2009/07/19 10:30:38 glchen ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_QUARTER in NUMBER,
  X_QTR_FIRST_PERIOD in NUMBER,
  X_QTR_LAST_PERIOD in NUMBER,
  X_YEAR_FIRST_PERIOD in NUMBER,
  X_YEAR_LAST_PERIOD in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
procedure LOCK_ROW (
  X_QUARTER in NUMBER,
  X_QTR_FIRST_PERIOD in NUMBER,
  X_QTR_LAST_PERIOD in NUMBER,
  X_YEAR_FIRST_PERIOD in NUMBER,
  X_YEAR_LAST_PERIOD in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
procedure UPDATE_ROW (
  X_QUARTER in NUMBER,
  X_QTR_FIRST_PERIOD in NUMBER,
  X_QTR_LAST_PERIOD in NUMBER,
  X_YEAR_FIRST_PERIOD in NUMBER,
  X_YEAR_LAST_PERIOD in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
procedure DELETE_ROW (
  X_YEAR_LAST_PERIOD in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

procedure LOAD_ROW (
  X_OWNER in VARCHAR2,
  X_QUARTER in NUMBER,
  X_QTR_FIRST_PERIOD in NUMBER,
  X_QTR_LAST_PERIOD in NUMBER,
  X_YEAR_FIRST_PERIOD in NUMBER,
  X_YEAR_LAST_PERIOD in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

/*Bug 8355119 overloading function for release specific signatures*/
procedure LOAD_ROW (
  X_CUSTOM_MODE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_QUARTER in NUMBER,
  X_QTR_FIRST_PERIOD in NUMBER,
  X_QTR_LAST_PERIOD in NUMBER,
  X_YEAR_FIRST_PERIOD in NUMBER,
  X_YEAR_LAST_PERIOD in NUMBER,
  p_log_level_rec IN FA_API_TYPES.log_level_rec_type default null
);
/*bug 8355119 adding R12 specific funtion LOAD_SEED_ROW*/
procedure LOAD_SEED_ROW (
          x_upload_mode                 IN VARCHAR2,
          x_custom_mode                 IN VARCHAR2,
          x_owner                       IN VARCHAR2,
          x_last_update_date            IN DATE,
          x_quarter                     IN NUMBER,
          x_qtr_first_period            IN NUMBER,
          x_qtr_last_period             IN NUMBER,
          x_year_first_period           IN NUMBER,
          x_year_last_period            IN NUMBER);

END FA_PERIOD_MAPS_PKG;

/
