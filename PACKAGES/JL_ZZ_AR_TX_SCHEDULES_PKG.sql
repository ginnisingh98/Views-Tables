--------------------------------------------------------
--  DDL for Package JL_ZZ_AR_TX_SCHEDULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_AR_TX_SCHEDULES_PKG" AUTHID CURRENT_USER as
/* $Header: jlzztscs.pls 120.2 2003/03/03 19:41:02 opedrega ship $ */

  PROCEDURE Insert_Row
       (X_rowid              IN OUT NOCOPY VARCHAR2,
        X_tax_categ_slab_id                NUMBER,
        X_tax_category_id                  NUMBER,
        X_end_date_active                  DATE,
        X_min_taxable_basis                NUMBER,
        X_last_update_date                 DATE,
        X_last_updated_by                  NUMBER,
        X_max_taxable_basis                NUMBER    DEFAULT NULL,
        X_tax_code                         VARCHAR2  DEFAULT NULL,
        X_start_date_active                DATE      DEFAULT NULL,
        X_org_id                           NUMBER,
        X_last_update_login                NUMBER    DEFAULT NULL,
        X_creation_date                    DATE      DEFAULT NULL,
        X_created_by                       NUMBER    DEFAULT NULL,
        X_attribute_category               VARCHAR2  DEFAULT NULL,
        X_attribute1                       VARCHAR2  DEFAULT NULL,
        X_attribute2                       VARCHAR2  DEFAULT NULL,
        X_attribute3                       VARCHAR2  DEFAULT NULL,
        X_attribute4                       VARCHAR2  DEFAULT NULL,
        X_attribute5                       VARCHAR2  DEFAULT NULL,
        X_attribute6                       VARCHAR2  DEFAULT NULL,
        X_attribute7                       VARCHAR2  DEFAULT NULL,
        X_attribute8                       VARCHAR2  DEFAULT NULL,
        X_attribute9                       VARCHAR2  DEFAULT NULL,
        X_attribute10                      VARCHAR2  DEFAULT NULL,
        X_attribute11                      VARCHAR2  DEFAULT NULL,
        X_attribute12                      VARCHAR2  DEFAULT NULL,
        X_attribute13                      VARCHAR2  DEFAULT NULL,
        X_attribute14                      VARCHAR2  DEFAULT NULL,
        X_attribute15                      VARCHAR2  DEFAULT NULL,
        X_calling_sequence   IN            VARCHAR2);

  PROCEDURE Lock_Row
       (X_rowid                            VARCHAR2,
        X_tax_categ_slab_id                NUMBER,
        X_tax_category_id                  NUMBER,
        X_end_date_active                  DATE,
        X_min_taxable_basis                NUMBER,
        X_last_update_date                 DATE,
        X_last_updated_by                  NUMBER,
        X_max_taxable_basis                NUMBER    DEFAULT NULL,
        X_tax_code                         VARCHAR2  DEFAULT NULL,
        X_start_date_active                DATE      DEFAULT NULL,
        X_org_id                           NUMBER,
        X_last_update_login                NUMBER    DEFAULT NULL,
        X_creation_date                    DATE      DEFAULT NULL,
        X_created_by                       NUMBER    DEFAULT NULL,
        X_attribute_category               VARCHAR2  DEFAULT NULL,
        X_attribute1                       VARCHAR2  DEFAULT NULL,
        X_attribute2                       VARCHAR2  DEFAULT NULL,
        X_attribute3                       VARCHAR2  DEFAULT NULL,
        X_attribute4                       VARCHAR2  DEFAULT NULL,
        X_attribute5                       VARCHAR2  DEFAULT NULL,
        X_attribute6                       VARCHAR2  DEFAULT NULL,
        X_attribute7                       VARCHAR2  DEFAULT NULL,
        X_attribute8                       VARCHAR2  DEFAULT NULL,
        X_attribute9                       VARCHAR2  DEFAULT NULL,
        X_attribute10                      VARCHAR2  DEFAULT NULL,
        X_attribute11                      VARCHAR2  DEFAULT NULL,
        X_attribute12                      VARCHAR2  DEFAULT NULL,
        X_attribute13                      VARCHAR2  DEFAULT NULL,
        X_attribute14                      VARCHAR2  DEFAULT NULL,
        X_attribute15                      VARCHAR2  DEFAULT NULL,
        X_calling_sequence    IN           VARCHAR2);

  PROCEDURE UpDate_Row
       (X_rowid                            VARCHAR2,
        X_tax_categ_slab_id                NUMBER,
        X_tax_category_id                  NUMBER,
        X_end_date_active                  DATE,
        X_min_taxable_basis                NUMBER,
        X_last_update_date                 DATE,
        X_last_updated_by                  NUMBER,
        X_max_taxable_basis                NUMBER    DEFAULT NULL,
        X_tax_code                         VARCHAR2  DEFAULT NULL,
        X_start_date_active                DATE      DEFAULT NULL,
        X_org_id                           NUMBER,
        X_last_update_login                NUMBER    DEFAULT NULL,
        X_creation_date                    DATE      DEFAULT NULL,
        X_created_by                       NUMBER    DEFAULT NULL,
        X_attribute_category               VARCHAR2  DEFAULT NULL,
        X_attribute1                       VARCHAR2  DEFAULT NULL,
        X_attribute2                       VARCHAR2  DEFAULT NULL,
        X_attribute3                       VARCHAR2  DEFAULT NULL,
        X_attribute4                       VARCHAR2  DEFAULT NULL,
        X_attribute5                       VARCHAR2  DEFAULT NULL,
        X_attribute6                       VARCHAR2  DEFAULT NULL,
        X_attribute7                       VARCHAR2  DEFAULT NULL,
        X_attribute8                       VARCHAR2  DEFAULT NULL,
        X_attribute9                       VARCHAR2  DEFAULT NULL,
        X_attribute10                      VARCHAR2  DEFAULT NULL,
        X_attribute11                      VARCHAR2  DEFAULT NULL,
        X_attribute12                      VARCHAR2  DEFAULT NULL,
        X_attribute13                      VARCHAR2  DEFAULT NULL,
        X_attribute14                      VARCHAR2  DEFAULT NULL,
        X_attribute15                      VARCHAR2  DEFAULT NULL,
        X_calling_sequence   IN            VARCHAR2);

  PROCEDURE Delete_Row
       (X_rowid                            VARCHAR2,
        X_tax_categ_slab_id                NUMBER,
        X_tax_category_id                  NUMBER,
        X_end_date_active                  DATE,
        X_calling_sequence   IN            VARCHAR2);

  PROCEDURE Check_Unique
       (X_rowid                            VARCHAR2,
        X_tax_categ_slab_id                NUMBER,
        X_tax_category_id                  NUMBER,
        X_end_date_active                  DATE,
        X_calling_sequence   IN            VARCHAR2);

  PROCEDURE Check_Overlapped_Dates
       (X_rowid                            VARCHAR2,
        X_tax_categ_slab_id                NUMBER,
        X_tax_category_id                  NUMBER,
        X_end_date_active                  DATE,
        X_start_date_active                DATE,
        X_calling_sequence   IN            VARCHAR2);

  PROCEDURE Check_Gaps
       (X_rowid                            VARCHAR2,
        X_tax_categ_slab_id                NUMBER,
        X_tax_category_id                  NUMBER,
        X_end_date_active                  DATE,
        X_start_date_active                DATE,
        X_calling_sequence   IN            VARCHAR2);

END JL_ZZ_AR_TX_SCHEDULES_PKG;

 

/
