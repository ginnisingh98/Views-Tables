--------------------------------------------------------
--  DDL for Package FA_ITC_RATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_ITC_RATES_PKG" AUTHID CURRENT_USER as
/* $Header: faxiitcs.pls 120.4.12010000.2 2009/07/19 10:35:27 glchen ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_ITC_AMOUNT_ID in NUMBER,
  X_TAX_YEAR in NUMBER,
  X_LIFE_IN_MONTHS in NUMBER,
  X_ITC_AMOUNT_RATE in NUMBER,
  X_BASIS_REDUCTION_RATE in NUMBER,
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
  X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
procedure LOCK_ROW (
  X_ITC_AMOUNT_ID in NUMBER,
  X_TAX_YEAR in NUMBER,
  X_LIFE_IN_MONTHS in NUMBER,
  X_ITC_AMOUNT_RATE in NUMBER,
  X_BASIS_REDUCTION_RATE in NUMBER,
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
  X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
procedure UPDATE_ROW (
  X_ITC_AMOUNT_ID in NUMBER,
  X_TAX_YEAR in NUMBER,
  X_LIFE_IN_MONTHS in NUMBER,
  X_ITC_AMOUNT_RATE in NUMBER,
  X_BASIS_REDUCTION_RATE in NUMBER,
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
  X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
procedure DELETE_ROW (
  X_ITC_AMOUNT_ID in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

procedure LOAD_ROW (
  X_ITC_AMOUNT_ID in NUMBER,
  X_OWNER in VARCHAR2,
  X_TAX_YEAR in NUMBER,
  X_LIFE_IN_MONTHS in NUMBER,
  X_ITC_AMOUNT_RATE in NUMBER,
  X_BASIS_REDUCTION_RATE in NUMBER,
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
  X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

/*Bug 8355119 overloading function for release specific signatures*/
procedure LOAD_ROW (
  X_CUSTOM_MODE in VARCHAR2,
  X_ITC_AMOUNT_ID in NUMBER,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_TAX_YEAR in NUMBER,
  X_LIFE_IN_MONTHS in NUMBER,
  X_ITC_AMOUNT_RATE in NUMBER,
  X_BASIS_REDUCTION_RATE in NUMBER,
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
  X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2,
  p_log_level_rec    in      fa_api_types.log_level_rec_type default null
);

/*bug 8355119 adding R12 specific funtion LOAD_SEED_ROW*/
procedure LOAD_SEED_ROW (
          x_upload_mode                 IN VARCHAR2,
          x_custom_mode                 IN VARCHAR2,
          x_itc_amount_id               IN NUMBER,
          x_owner                       IN VARCHAR2,
          x_last_update_date            IN DATE,
          x_tax_year                    IN NUMBER,
          x_life_in_months              IN NUMBER,
          x_itc_amount_rate             IN NUMBER,
          x_basis_reduction_rate        IN NUMBER,
          x_attribute1                  IN VARCHAR2,
          x_attribute2                  IN VARCHAR2,
          x_attribute3                  IN VARCHAR2,
          x_attribute4                  IN VARCHAR2,
          x_attribute5                  IN VARCHAR2,
          x_attribute6                  IN VARCHAR2,
          x_attribute7                  IN VARCHAR2,
          x_attribute8                  IN VARCHAR2,
          x_attribute9                  IN VARCHAR2,
          x_attribute10                 IN VARCHAR2,
          x_attribute11                 IN VARCHAR2,
          x_attribute12                 IN VARCHAR2,
          x_attribute13                 IN VARCHAR2,
          x_attribute14                 IN VARCHAR2,
          x_attribute15                 IN VARCHAR2,
          x_attribute_category_code     IN VARCHAR2);
END FA_ITC_RATES_PKG;

/
