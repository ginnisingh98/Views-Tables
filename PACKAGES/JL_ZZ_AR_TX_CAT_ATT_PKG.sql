--------------------------------------------------------
--  DDL for Package JL_ZZ_AR_TX_CAT_ATT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_AR_TX_CAT_ATT_PKG" AUTHID CURRENT_USER as
/* $Header: jlzztats.pls 120.3 2005/10/30 02:08:58 appldev ship $ */

  PROCEDURE Insert_Row
       (X_rowid              IN OUT NOCOPY VARCHAR2,
        X_tax_categ_attr_id                NUMBER,
        X_tax_category_id                  NUMBER,
        X_tax_attribute_type               VARCHAR2,
        X_tax_attribute_name               VARCHAR2,
        X_mandatory_in_class               VARCHAR2,
        X_determining_factor               VARCHAR2,
        X_grouping_attribute               VARCHAR2,
        X_priority_number                  NUMBER,
        X_org_id                           NUMBER,
        X_last_update_date                 DATE,
        X_last_updated_by                  NUMBER,
        X_creation_date                    DATE,
        X_created_by                       NUMBER,
        X_last_update_login                NUMBER,
        X_attribute_category               VARCHAR2,
        X_attribute1                       VARCHAR2,
        X_attribute2                       VARCHAR2,
        X_attribute3                       VARCHAR2,
        X_attribute4                       VARCHAR2,
        X_attribute5                       VARCHAR2,
        X_attribute6                       VARCHAR2,
        X_attribute7                       VARCHAR2,
        X_attribute8                       VARCHAR2,
        X_attribute9                       VARCHAR2,
        X_attribute10                      VARCHAR2,
        X_attribute11                      VARCHAR2,
        X_attribute12                      VARCHAR2,
        X_attribute13                      VARCHAR2,
        X_attribute14                      VARCHAR2,
        X_attribute15                      VARCHAR2,
        X_calling_sequence        IN       VARCHAR2);

  PROCEDURE Lock_Row
       (X_rowid                            VARCHAR2,
        X_tax_categ_attr_id                NUMBER,
        X_tax_category_id                  NUMBER,
        X_tax_attribute_type               VARCHAR2,
        X_tax_attribute_name               VARCHAR2,
        X_mandatory_in_class               VARCHAR2,
        X_determining_factor               VARCHAR2,
        X_grouping_attribute               VARCHAR2,
        X_priority_number                  NUMBER,
        X_org_id                           NUMBER,
        X_last_update_date                 DATE,
        X_last_updated_by                  NUMBER,
        X_creation_date                    DATE,
        X_created_by                       NUMBER,
        X_last_update_login                NUMBER,
        X_attribute_category               VARCHAR2,
        X_attribute1                       VARCHAR2,
        X_attribute2                       VARCHAR2,
        X_attribute3                       VARCHAR2,
        X_attribute4                       VARCHAR2,
        X_attribute5                       VARCHAR2,
        X_attribute6                       VARCHAR2,
        X_attribute7                       VARCHAR2,
        X_attribute8                       VARCHAR2,
        X_attribute9                       VARCHAR2,
        X_attribute10                      VARCHAR2,
        X_attribute11                      VARCHAR2,
        X_attribute12                      VARCHAR2,
        X_attribute13                      VARCHAR2,
        X_attribute14                      VARCHAR2,
        X_attribute15                      VARCHAR2,
        X_calling_sequence        IN       VARCHAR2);

  PROCEDURE Update_Row
       (X_rowid                            VARCHAR2,
        X_tax_categ_attr_id                NUMBER,
        X_tax_category_id                  NUMBER,
        X_tax_attribute_type               VARCHAR2,
        X_tax_attribute_name               VARCHAR2,
        X_mandatory_in_class               VARCHAR2,
        X_determining_factor               VARCHAR2,
        X_grouping_attribute               VARCHAR2,
        X_priority_number                  NUMBER,
        X_org_id                           NUMBER,
        X_last_update_date                 DATE,
        X_last_updated_by                  NUMBER,
        X_creation_date                    DATE,
        X_created_by                       NUMBER,
        X_last_update_login                NUMBER,
        X_attribute_category               VARCHAR2,
        X_attribute1                       VARCHAR2,
        X_attribute2                       VARCHAR2,
        X_attribute3                       VARCHAR2,
        X_attribute4                       VARCHAR2,
        X_attribute5                       VARCHAR2,
        X_attribute6                       VARCHAR2,
        X_attribute7                       VARCHAR2,
        X_attribute8                       VARCHAR2,
        X_attribute9                       VARCHAR2,
        X_attribute10                      VARCHAR2,
        X_attribute11                      VARCHAR2,
        X_attribute12                      VARCHAR2,
        X_attribute13                      VARCHAR2,
        X_attribute14                      VARCHAR2,
        X_attribute15                      VARCHAR2,
        X_calling_sequence        IN       VARCHAR2);

  PROCEDURE Delete_Row
       (X_rowid                            VARCHAR2);

  PROCEDURE Check_Unique
       (X_rowid                            VARCHAR2,
        X_tax_category_id                  NUMBER,
        X_tax_attribute_type               VARCHAR2,
        X_tax_attribute_name               VARCHAR2,
        X_org_id                           NUMBER,
        X_calling_sequence        IN       VARCHAR2);

  PROCEDURE Check_Determining_Factor
       (X_rowid                            VARCHAR2,
        X_tax_category_id                  NUMBER,
        X_tax_attribute_type               VARCHAR2,
        X_determining_factor               VARCHAR2,
        X_org_id                           NUMBER,
        X_calling_sequence        IN       VARCHAR2);

  PROCEDURE Lock_Row_Priority_Number
       (X_Rowid                            VARCHAR2,
        X_priority_number                  NUMBER,
        X_last_update_date                 DATE,
        X_last_updated_by                  NUMBER,
        X_creation_date                    DATE,
        X_created_by                       NUMBER,
        X_last_update_login                NUMBER,
        X_calling_sequence                 VARCHAR2);

  PROCEDURE Update_Row_Priority_Number
       (X_Rowid                            VARCHAR2,
        X_priority_number                  NUMBER,
        X_last_update_date                 DATE,
        X_last_updated_by                  NUMBER,
        X_creation_date                    DATE,
        X_created_by                       NUMBER,
        X_last_update_login                NUMBER,
        X_calling_sequence                 VARCHAR2);

END JL_ZZ_AR_TX_CAT_ATT_PKG;

 

/
