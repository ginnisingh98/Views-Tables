--------------------------------------------------------
--  DDL for Package FA_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CATEGORIES_PKG" AUTHID CURRENT_USER as
/* $Header: faxicas.pls 120.4.12010000.2 2009/07/19 13:19:55 glchen ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CATEGORY_ID in NUMBER,
  X_SUMMARY_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_OWNED_LEASED in VARCHAR2,
  X_CATEGORY_TYPE in VARCHAR2,
  X_CAPITALIZE_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SEGMENT1 in VARCHAR2,
  X_SEGMENT2 in VARCHAR2,
  X_SEGMENT3 in VARCHAR2,
  X_SEGMENT4 in VARCHAR2,
  X_SEGMENT5 in VARCHAR2,
  X_SEGMENT6 in VARCHAR2,
  X_SEGMENT7 in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_PROPERTY_TYPE_CODE in VARCHAR2,
  X_PROPERTY_1245_1250_CODE in VARCHAR2,
  X_DATE_INEFFECTIVE in DATE,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2 DEFAULT NULL,
  X_PRODUCTION_CAPACITY in NUMBER DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE16 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE17 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE18 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE19 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE20 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_INVENTORIAL in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

procedure LOCK_ROW (
  X_CATEGORY_ID in NUMBER,
  X_SUMMARY_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_OWNED_LEASED in VARCHAR2,
  X_CATEGORY_TYPE in VARCHAR2,
  X_CAPITALIZE_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SEGMENT1 in VARCHAR2,
  X_SEGMENT2 in VARCHAR2,
  X_SEGMENT3 in VARCHAR2,
  X_SEGMENT4 in VARCHAR2,
  X_SEGMENT5 in VARCHAR2,
  X_SEGMENT6 in VARCHAR2,
  X_SEGMENT7 in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_PROPERTY_TYPE_CODE in VARCHAR2,
  X_PROPERTY_1245_1250_CODE in VARCHAR2,
  X_DATE_INEFFECTIVE in DATE,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2 DEFAULT NULL,
  X_PRODUCTION_CAPACITY in NUMBER DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE16 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE17 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE18 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE19 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE20 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_INVENTORIAL in VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

procedure UPDATE_ROW (
  X_CATEGORY_ID in NUMBER,
  X_SUMMARY_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_OWNED_LEASED in VARCHAR2,
  X_CATEGORY_TYPE in VARCHAR2,
  X_CAPITALIZE_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SEGMENT1 in VARCHAR2,
  X_SEGMENT2 in VARCHAR2,
  X_SEGMENT3 in VARCHAR2,
  X_SEGMENT4 in VARCHAR2,
  X_SEGMENT5 in VARCHAR2,
  X_SEGMENT6 in VARCHAR2,
  X_SEGMENT7 in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_PROPERTY_TYPE_CODE in VARCHAR2,
  X_PROPERTY_1245_1250_CODE in VARCHAR2,
  X_DATE_INEFFECTIVE in DATE,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2 DEFAULT NULL,
  X_PRODUCTION_CAPACITY in NUMBER DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE16 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE17 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE18 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE19 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE20 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_INVENTORIAL in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

procedure DELETE_ROW (
  X_CATEGORY_ID in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

procedure ADD_LANGUAGE;

procedure LOAD_ROW (
  X_CATEGORY_ID in NUMBER,
  X_SUMMARY_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_OWNED_LEASED in VARCHAR2,
  X_PRODUCTION_CAPACITY in NUMBER DEFAULT NULL,
  X_CATEGORY_TYPE in VARCHAR2,
  X_CAPITALIZE_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SEGMENT1 in VARCHAR2,
  X_SEGMENT2 in VARCHAR2,
  X_SEGMENT3 in VARCHAR2,
  X_SEGMENT4 in VARCHAR2,
  X_SEGMENT5 in VARCHAR2,
  X_SEGMENT6 in VARCHAR2,
  X_SEGMENT7 in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_PROPERTY_TYPE_CODE in VARCHAR2,
  X_PROPERTY_1245_1250_CODE in VARCHAR2,
  X_DATE_INEFFECTIVE in DATE,
  X_INVENTORIAL in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE16 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE17 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE18 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE19 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE20 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

/*Bug 8355119 overloading function for release specific signatures*/
procedure LOAD_ROW (
  X_CUSTOM_MODE in VARCHAR2,
  X_CATEGORY_ID in NUMBER,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_SUMMARY_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_OWNED_LEASED in VARCHAR2,
  X_PRODUCTION_CAPACITY in NUMBER DEFAULT NULL,
  X_CATEGORY_TYPE in VARCHAR2,
  X_CAPITALIZE_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SEGMENT1 in VARCHAR2,
  X_SEGMENT2 in VARCHAR2,
  X_SEGMENT3 in VARCHAR2,
  X_SEGMENT4 in VARCHAR2,
  X_SEGMENT5 in VARCHAR2,
  X_SEGMENT6 in VARCHAR2,
  X_SEGMENT7 in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_PROPERTY_TYPE_CODE in VARCHAR2,
  X_PROPERTY_1245_1250_CODE in VARCHAR2,
  X_DATE_INEFFECTIVE in DATE,
  X_INVENTORIAL in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE16 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE17 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE18 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE19 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE20 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  p_log_level_rec    in      fa_api_types.log_level_rec_type default null
);


procedure TRANSLATE_ROW (
  X_CATEGORY_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

/*Bug 8355119 overloading function for release specific signatures*/
procedure TRANSLATE_ROW (
  X_CUSTOM_MODE in VARCHAR2,
  X_CATEGORY_ID in NUMBER,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_DESCRIPTION in VARCHAR2,
  p_log_level_rec    in      fa_api_types.log_level_rec_type default null
);

/*bug 8355119 adding R12 specific funtion LOAD_SEED_ROW*/
procedure LOAD_SEED_ROW (
             x_upload_mode              IN VARCHAR2,
             x_custom_mode              IN VARCHAR2,
             x_category_id              IN NUMBER,
             x_owner                    IN VARCHAR2,
             x_last_update_date         IN DATE,
             x_summary_flag             IN VARCHAR2,
             x_enabled_flag             IN VARCHAR2,
             x_owned_leased             IN VARCHAR2,
             x_production_capacity      IN NUMBER,
             x_category_type            IN VARCHAR2,
             x_capitalize_flag          IN VARCHAR2,
             x_description              IN VARCHAR2,
             x_segment1                 IN VARCHAR2,
             x_segment2                 IN VARCHAR2,
             x_segment3                 IN VARCHAR2,
             x_segment4                 IN VARCHAR2,
             x_segment5                 IN VARCHAR2,
             x_segment6                 IN VARCHAR2,
             x_segment7                 IN VARCHAR2,
             x_start_date_active        IN DATE,
             x_end_date_active          IN DATE,
             x_property_type_code       IN VARCHAR2,
             x_property_1245_1250_code  IN VARCHAR2,
             x_date_ineffective         IN DATE,
             x_inventorial              IN VARCHAR2,
             x_attribute1               IN VARCHAR2,
             x_attribute2               IN VARCHAR2,
             x_attribute3               IN VARCHAR2,
             x_attribute4               IN VARCHAR2,
             x_attribute5               IN VARCHAR2,
             x_attribute6               IN VARCHAR2,
             x_attribute7               IN VARCHAR2,
             x_attribute8               IN VARCHAR2,
             x_attribute9               IN VARCHAR2,
             x_attribute10              IN VARCHAR2,
             x_attribute11              IN VARCHAR2,
             x_attribute12              IN VARCHAR2,
             x_attribute13              IN VARCHAR2,
             x_attribute14              IN VARCHAR2,
             x_attribute15              IN VARCHAR2,
             x_attribute_category_code  IN VARCHAR2,
             x_gf_attribute1            IN VARCHAR2,
             x_gf_attribute2            IN VARCHAR2,
             x_gf_attribute3            IN VARCHAR2,
             x_gf_attribute4            IN VARCHAR2,
             x_gf_attribute5            IN VARCHAR2,
             x_gf_attribute6            IN VARCHAR2,
             x_gf_attribute7            IN VARCHAR2,
             x_gf_attribute8            IN VARCHAR2,
             x_gf_attribute9            IN VARCHAR2,
             x_gf_attribute10           IN VARCHAR2,
             x_gf_attribute11           IN VARCHAR2,
             x_gf_attribute12           IN VARCHAR2,
             x_gf_attribute13           IN VARCHAR2,
             x_gf_attribute14           IN VARCHAR2,
             x_gf_attribute15           IN VARCHAR2,
             x_gf_attribute16           IN VARCHAR2,
             x_gf_attribute17           IN VARCHAR2,
             x_gf_attribute18           IN VARCHAR2,
             x_gf_attribute19           IN VARCHAR2,
             x_gf_attribute20           IN VARCHAR2,
             x_gf_attribute_category    IN VARCHAR2);

end FA_CATEGORIES_PKG;

/
