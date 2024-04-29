--------------------------------------------------------
--  DDL for Package ZX_FORMULA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_FORMULA_PKG" AUTHID CURRENT_USER as
/* $Header: zxdformulas.pls 120.5 2005/03/17 12:19:12 shmangal ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_FORMULA_ID in NUMBER,
  X_Formula_Type_Code in VARCHAR2,
  X_FORMULA_CODE in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_TAX in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_Taxable_Basis_Type_Code in VARCHAR2,
  X_Record_Type_Code in VARCHAR2,
  X_BASE_RATE_MODIFIER in NUMBER,
  X_Cash_Discount_Appl_Flag in VARCHAR2,
  X_Volume_Discount_Appl_Flag in VARCHAR2,
  X_Trading_Discount_Appl_Flag in VARCHAR2,
  X_Transfer_Charge_Appl_Flag in VARCHAR2,
  X_TRANSPORT_CHARGE_APPL_FLAG in VARCHAR2,
  X_Insurance_Charge_Appl_Flag in VARCHAR2,
  X_Other_Charge_Appl_Flag in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_FORMULA_NAME in VARCHAR2,
  X_FORMULA_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_Enabled_Flag in VARCHAR2,
  X_CONTENT_OWNER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER);

procedure LOCK_ROW (
  X_FORMULA_ID in NUMBER,
  X_Formula_Type_Code in VARCHAR2,
  X_FORMULA_CODE in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_TAX in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_Taxable_Basis_Type_Code in VARCHAR2,
  X_Record_Type_Code in VARCHAR2,
  X_BASE_RATE_MODIFIER in NUMBER,
  X_Cash_Discount_Appl_Flag in VARCHAR2,
  X_Volume_Discount_Appl_Flag in VARCHAR2,
  X_Trading_Discount_Appl_Flag in VARCHAR2,
  X_Transfer_Charge_Appl_Flag in VARCHAR2,
  X_TRANSPORT_CHARGE_APPL_FLAG in VARCHAR2,
  X_Insurance_Charge_Appl_Flag in VARCHAR2,
  X_Other_Charge_Appl_Flag in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_FORMULA_NAME in VARCHAR2,
  X_FORMULA_DESCRIPTION in VARCHAR2,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_Enabled_Flag in VARCHAR2,
  X_CONTENT_OWNER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER);


procedure UPDATE_ROW (
  X_FORMULA_ID in NUMBER,
  X_Formula_Type_Code in VARCHAR2,
  X_FORMULA_CODE in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_TAX in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_Taxable_Basis_Type_Code in VARCHAR2,
  X_Record_Type_Code in VARCHAR2,
  X_BASE_RATE_MODIFIER in NUMBER,
  X_Cash_Discount_Appl_Flag in VARCHAR2,
  X_Volume_Discount_Appl_Flag in VARCHAR2,
  X_Trading_Discount_Appl_Flag in VARCHAR2,
  X_Transfer_Charge_Appl_Flag in VARCHAR2,
  X_TRANSPORT_CHARGE_APPL_FLAG in VARCHAR2,
  X_Insurance_Charge_Appl_Flag in VARCHAR2,
  X_Other_Charge_Appl_Flag in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_FORMULA_NAME in VARCHAR2,
  X_FORMULA_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_Enabled_Flag in VARCHAR2,
  X_CONTENT_OWNER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER);


procedure DELETE_ROW (
  X_FORMULA_ID in NUMBER);

procedure ADD_LANGUAGE;

TYPE T_FORMULA_ID is TABLE of zx_formula_b.formula_id%type
                     index by binary_integer;
TYPE T_FORMULA_TYPE is TABLE of zx_formula_b.Formula_Type_Code%type
                       index by binary_integer;
TYPE T_FORMULA_CODE is TABLE of zx_formula_b.formula_code%type
                       index by binary_integer;
TYPE T_TAX_REGIME_CODE is TABLE of zx_formula_b.tax_regime_code%type
                       index by binary_integer;
TYPE T_TAX            is TABLE of zx_formula_b.tax%type
                       index by binary_integer;
TYPE T_EFFECTIVE_FROM is TABLE of zx_formula_b.effective_from%type
                       index by binary_integer;
TYPE T_EFFECTIVE_TO  is TABLE of zx_formula_b.effective_to%type
                       index by binary_integer;
TYPE T_TAXABLE_BASIS_TYPE   is TABLE of zx_formula_b.Taxable_Basis_Type_Code%type
                       index by binary_integer;
TYPE T_RECORD_TYPE         is TABLE of zx_formula_b.Record_Type_Code%type
                       index by binary_integer;
TYPE T_BASE_RATE_MODIFIER is TABLE of zx_formula_b.base_rate_modifier%type
                       index by binary_integer;
TYPE T_CASH_DISCOUNT_APPL_FLG
                    is TABLE of zx_formula_b.Cash_Discount_Appl_Flag%type
                       index by binary_integer;
TYPE T_VOLUME_DISCOUNT_APPL_FLG
                    is TABLE of zx_formula_b.Volume_Discount_Appl_Flag%type
                       index by binary_integer;
TYPE T_TRADING_DISCOUNT_APPL_FLG
                    is TABLE of zx_formula_b.Trading_Discount_Appl_Flag%type
                       index by binary_integer;
TYPE T_TRANSFER_CHARGE_APPL_FLG
                    is TABLE of zx_formula_b.Transfer_Charge_Appl_Flag%type
                       index by binary_integer;
TYPE T_TRANSPORT_CHARGE_APPL_FLG
                    is TABLE of zx_formula_b.Transport_Charge_Appl_Flag%type
                       index by binary_integer;
TYPE T_INSURANCE_CHARGE_APPL_FLG
                    is TABLE of zx_formula_b.Insurance_Charge_Appl_Flag%type
                       index by binary_integer;
TYPE T_OTHER_CHARGE_APPL_FLG is TABLE of zx_formula_b.Other_Charge_Appl_Flag%type
                       index by binary_integer;
TYPE T_ATTRIBUTE_CATEGORY is TABLE of zx_formula_b.attribute_category%type
                             index by binary_integer;
TYPE T_ATTRIBUTE1 is TABLE of zx_formula_b.attribute1%type
                     index by binary_integer;
TYPE T_ATTRIBUTE2 is TABLE of zx_formula_b.attribute2%type
                     index by binary_integer;
TYPE T_ATTRIBUTE3 is TABLE of zx_formula_b.attribute3%type
                     index by binary_integer;
TYPE T_ATTRIBUTE4 is TABLE of zx_formula_b.attribute4%type
                     index by binary_integer;
TYPE T_ATTRIBUTE5 is TABLE of zx_formula_b.attribute5%type
                     index by binary_integer;
TYPE T_ATTRIBUTE6 is TABLE of zx_formula_b.attribute6%type
                     index by binary_integer;
TYPE T_ATTRIBUTE7 is TABLE of zx_formula_b.attribute7%type
                     index by binary_integer;
TYPE T_ATTRIBUTE8 is TABLE of zx_formula_b.attribute8%type
                     index by binary_integer;
TYPE T_ATTRIBUTE9 is TABLE of zx_formula_b.attribute9%type
                     index by binary_integer;
TYPE T_ATTRIBUTE10 is TABLE of zx_formula_b.attribute10%type
                      index by binary_integer;
TYPE T_ATTRIBUTE11 is TABLE of zx_formula_b.attribute11%type
                      index by binary_integer;
TYPE T_ATTRIBUTE12 is TABLE of zx_formula_b.attribute12%type
                      index by binary_integer;
TYPE T_ATTRIBUTE13 is TABLE of zx_formula_b.attribute13%type
                      index by binary_integer;
TYPE T_ATTRIBUTE14 is TABLE of zx_formula_b.attribute14%type
                      index by binary_integer;
TYPE T_ATTRIBUTE15 is TABLE of zx_formula_b.attribute15%type
                      index by binary_integer;
TYPE T_ATTRIBUTE16 is TABLE of zx_formula_b.attribute16%type
                      index by binary_integer;
TYPE T_ATTRIBUTE17 is TABLE of zx_formula_b.attribute17%type
                      index by binary_integer;
TYPE T_ATTRIBUTE18 is TABLE of zx_formula_b.attribute18%type
                      index by binary_integer;
TYPE T_ATTRIBUTE19 is TABLE of zx_formula_b.attribute19%type
                      index by binary_integer;
TYPE T_ATTRIBUTE20 is TABLE of zx_formula_b.attribute20%type
                      index by binary_integer;
TYPE T_FORMULA_NAME is TABLE of zx_formula_tl.formula_name%type
                       index by binary_integer;
TYPE T_FORMULA_DESCRIPTION is TABLE of zx_formula_tl.formula_description%type
                              index by binary_integer;
TYPE T_ENABLED_FLG is TABLE of zx_formula_b.Enabled_Flag%type
                      index by binary_integer;
TYPE T_CONTENT_OWNER_ID is TABLE of zx_formula_b.content_owner_id%type
                           index by binary_integer;

procedure bulk_insert_formula (
  X_FORMULA_ID                     IN t_formula_id,
  X_Formula_Type_Code                   IN t_formula_type,
  X_FORMULA_CODE                   IN t_formula_code,
  X_TAX_REGIME_CODE                IN t_tax_regime_code,
  X_TAX                            IN t_tax,
  X_EFFECTIVE_FROM                 IN t_effective_from,
  X_EFFECTIVE_TO                   IN t_effective_to,
  X_Taxable_Basis_Type_Code             IN t_taxable_basis_type,
  X_Record_Type_Code                    IN t_record_type,
  X_BASE_RATE_MODIFIER             IN t_base_rate_modifier,
  X_Cash_Discount_Appl_Flag         IN t_cash_discount_appl_flg,
  X_Volume_Discount_Appl_Flag       IN t_volume_discount_appl_flg,
  X_Trading_Discount_Appl_Flag      IN t_trading_discount_appl_flg,
  X_Transfer_Charge_Appl_Flag       IN t_transfer_charge_appl_flg,
  X_TRANSPORT_CHARGE_APPL_FLG      IN t_transport_charge_appl_flg,
  X_Insurance_Charge_Appl_Flag      IN t_insurance_charge_appl_flg,
  X_Other_Charge_Appl_Flag          IN t_other_charge_appl_flg,
  X_ATTRIBUTE_CATEGORY             IN t_attribute_category,
  X_ATTRIBUTE1                     IN t_attribute1,
  X_ATTRIBUTE2                     IN t_attribute2,
  X_ATTRIBUTE3                     IN t_attribute3,
  X_ATTRIBUTE4                     IN t_attribute4,
  X_ATTRIBUTE5                     IN t_attribute5,
  X_ATTRIBUTE6                     IN t_attribute6,
  X_ATTRIBUTE7                     IN t_attribute7,
  X_ATTRIBUTE8                     IN t_attribute8,
  X_ATTRIBUTE9                     IN t_attribute9,
  X_ATTRIBUTE10                    IN t_attribute10,
  X_ATTRIBUTE11                    IN t_attribute11,
  X_ATTRIBUTE12                    IN t_attribute12,
  X_ATTRIBUTE13                    IN t_attribute13,
  X_ATTRIBUTE14                    IN t_attribute14,
  X_ATTRIBUTE15                    IN t_attribute15,
  X_ATTRIBUTE16                    IN t_attribute16,
  X_ATTRIBUTE17                    IN t_attribute17,
  X_ATTRIBUTE18                    IN t_attribute18,
  X_ATTRIBUTE19                    IN t_attribute19,
  X_ATTRIBUTE20                    IN t_attribute20,
  X_FORMULA_NAME                   IN t_formula_name,
  X_FORMULA_DESCRIPTION            IN t_formula_description,
  X_Enabled_Flag                    IN t_enabled_flg,
  X_CONTENT_OWNER_ID               IN t_content_owner_id);

end ZX_FORMULA_PKG;

 

/
