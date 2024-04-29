--------------------------------------------------------
--  DDL for Package FA_FORMULAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FORMULAS_PKG" AUTHID CURRENT_USER as
/* $Header: faxifors.pls 120.5.12010000.2 2009/07/19 10:34:29 glchen ship $ */

procedure INSERT_ROW (
  X_ROWID             IN OUT NOCOPY VARCHAR2,
  X_METHOD_ID         IN NUMBER,
  X_FORMULA_ACTUAL    IN VARCHAR2,
  X_FORMULA_DISPLAYED IN VARCHAR2,
  X_FORMULA_PARSED    IN VARCHAR2,
  X_CREATION_DATE     IN DATE,
  X_CREATED_BY        IN NUMBER,
  X_LAST_UPDATE_DATE  IN DATE,
  X_LAST_UPDATED_BY   IN NUMBER,
  X_LAST_UPDATE_LOGIN IN NUMBER,
  X_ORIGINAL_RATE     IN NUMBER DEFAULT NULL,
  X_REVISED_RATE      IN NUMBER DEFAULT NULL,
  X_GUARANTEE_RATE    IN NUMBER DEFAULT NULL, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
procedure LOCK_ROW (
  X_METHOD_ID         IN NUMBER,
  X_FORMULA_ACTUAL    IN VARCHAR2,
  X_FORMULA_DISPLAYED IN VARCHAR2,
  X_FORMULA_PARSED    IN VARCHAR2,
  X_ORIGINAL_RATE     IN NUMBER,
  X_REVISED_RATE      IN NUMBER,
  X_GUARANTEE_RATE    IN NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
procedure UPDATE_ROW (
  X_METHOD_ID         IN NUMBER,
  X_FORMULA_ACTUAL    IN VARCHAR2,
  X_FORMULA_DISPLAYED IN VARCHAR2,
  X_FORMULA_PARSED    IN VARCHAR2,
  X_LAST_UPDATE_DATE  IN DATE,
  X_LAST_UPDATED_BY   IN NUMBER,
  X_LAST_UPDATE_LOGIN IN NUMBER,
  X_ORIGINAL_RATE     IN NUMBER,
  X_REVISED_RATE      IN NUMBER,
  X_GUARANTEE_RATE    IN NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
procedure DELETE_ROW (
  X_METHOD_ID in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

procedure LOAD_ROW (
  X_METHOD_ID         IN NUMBER,
  X_OWNER             IN VARCHAR2,
  X_FORMULA_ACTUAL    IN VARCHAR2,
  X_FORMULA_DISPLAYED IN VARCHAR2,
  X_FORMULA_PARSED    IN VARCHAR2,
  X_ORIGINAL_RATE     IN NUMBER DEFAULT NULL,
  X_REVISED_RATE      IN NUMBER DEFAULT NULL,
  X_GUARANTEE_RATE    IN NUMBER DEFAULT NULL
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

/*Bug 8355119 overloading function for release specific signatures*/
procedure LOAD_ROW (
  X_CUSTOM_MODE in VARCHAR2,
  X_METHOD_ID in NUMBER,
  X_DB_LAST_UPDATED_BY NUMBER,
  X_DB_LAST_UPDATE_DATE DATE,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_FORMULA_ACTUAL in VARCHAR2,
  X_FORMULA_DISPLAYED in VARCHAR2,
  X_FORMULA_PARSED in VARCHAR2,
  X_ORIGINAL_RATE     IN NUMBER DEFAULT NULL,
  X_REVISED_RATE      IN NUMBER DEFAULT NULL,
  X_GUARANTEE_RATE    IN NUMBER DEFAULT NULL,
  p_log_level_rec    in      fa_api_types.log_level_rec_type default null
);
/*bug 8355119 adding R12 specific funtion LOAD_SEED_ROW*/
procedure LOAD_SEED_ROW (
               x_upload_mode            IN VARCHAR2,
               x_custom_mode            IN VARCHAR2,
               x_method_code            IN VARCHAR2,
               x_life_in_months         IN NUMBER,
               x_owner                  IN VARCHAR2,
               x_last_update_date       IN DATE,
               x_formula_actual         IN VARCHAR2,
               x_formula_displayed      IN VARCHAR2,
               x_formula_parsed         IN VARCHAR2,
               x_original_rate          IN NUMBER DEFAULT NULL,
               x_revised_rate           IN NUMBER DEFAULT NULL,
               x_guarantee_rate         IN NUMBER DEFAULT NULL);

END FA_FORMULAS_PKG;

/
