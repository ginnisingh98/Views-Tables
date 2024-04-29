--------------------------------------------------------
--  DDL for Package ZX_FORMULA_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_FORMULA_DETAILS_PKG" AUTHID CURRENT_USER as
/* $Header: zxdformuladtls.pls 120.2 2003/12/19 03:51:28 ssekuri ship $ */

TYPE T_FORMULA_ID is TABLE of zx_formula_details.formula_id%type
                     index by binary_integer;
TYPE T_COMPOUNDING_TAX is TABLE of zx_formula_details.compounding_tax%type
                          index by binary_integer;
TYPE T_COMPOUNDING_TAX_REGIME_CODE
                is TABLE of zx_formula_details.compounding_tax_regime_code%type
                   index by binary_integer;
TYPE T_COMPOUNDING_TYPE is TABLE of zx_formula_details.Compounding_Type_Code%type
                           index by binary_integer;
TYPE T_RECORD_TYPE is TABLE of zx_formula_details.Record_Type_Code%type
                      index by binary_integer;
TYPE T_ATTRIBUTE_CATEGORY is TABLE of zx_formula_details.attribute_category%type
                      index by binary_integer;
TYPE T_ATTRIBUTE1 is TABLE of zx_formula_details.attribute1%type
                      index by binary_integer;
TYPE T_ATTRIBUTE2 is TABLE of zx_formula_details.attribute2%type
                      index by binary_integer;
TYPE T_ATTRIBUTE3 is TABLE of zx_formula_details.attribute3%type
                      index by binary_integer;
TYPE T_ATTRIBUTE4 is TABLE of zx_formula_details.attribute4%type
                      index by binary_integer;
TYPE T_ATTRIBUTE5 is TABLE of zx_formula_details.attribute5%type
                      index by binary_integer;
TYPE T_ATTRIBUTE6 is TABLE of zx_formula_details.attribute6%type
                      index by binary_integer;
TYPE T_ATTRIBUTE7 is TABLE of zx_formula_details.attribute7%type
                      index by binary_integer;
TYPE T_ATTRIBUTE8 is TABLE of zx_formula_details.attribute8%type
                      index by binary_integer;
TYPE T_ATTRIBUTE9 is TABLE of zx_formula_details.attribute9%type
                      index by binary_integer;
TYPE T_ATTRIBUTE10 is TABLE of zx_formula_details.attribute10%type
                      index by binary_integer;
TYPE T_ATTRIBUTE11 is TABLE of zx_formula_details.attribute11%type
                      index by binary_integer;
TYPE T_ATTRIBUTE12 is TABLE of zx_formula_details.attribute12%type
                      index by binary_integer;
TYPE T_ATTRIBUTE13 is TABLE of zx_formula_details.attribute13%type
                      index by binary_integer;
TYPE T_ATTRIBUTE14 is TABLE of zx_formula_details.attribute14%type
                      index by binary_integer;
TYPE T_ATTRIBUTE15 is TABLE of zx_formula_details.attribute15%type
                      index by binary_integer;
TYPE T_ATTRIBUTE16 is TABLE of zx_formula_details.attribute16%type
                      index by binary_integer;
TYPE T_ATTRIBUTE17 is TABLE of zx_formula_details.attribute17%type
                      index by binary_integer;
TYPE T_ATTRIBUTE18 is TABLE of zx_formula_details.attribute18%type
                      index by binary_integer;
TYPE T_ATTRIBUTE19 is TABLE of zx_formula_details.attribute19%type
                      index by binary_integer;
TYPE T_ATTRIBUTE20 is TABLE of zx_formula_details.attribute20%type
                      index by binary_integer;

procedure bulk_insert_formula_details (
  X_FORMULA_ID                     IN t_formula_id,
  X_COMPOUNDING_TAX                IN t_compounding_tax,
  X_COMPOUNDING_TAX_REGIME_CODE    IN t_compounding_tax_regime_code,
  X_Compounding_Type_Code               IN t_compounding_type,
  X_Record_Type_Code                    IN t_record_type,
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
  X_ATTRIBUTE20                    IN t_attribute20);

end ZX_FORMULA_DETAILS_PKG;

 

/
