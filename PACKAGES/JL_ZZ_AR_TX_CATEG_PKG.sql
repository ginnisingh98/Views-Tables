--------------------------------------------------------
--  DDL for Package JL_ZZ_AR_TX_CATEG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_AR_TX_CATEG_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzztcts.pls 120.3 2003/09/02 21:58:46 opedrega ship $ */

  PROCEDURE Insert_Row
       (X_rowid                   IN OUT NOCOPY VARCHAR2,
        X_tax_category_id                       NUMBER,
        X_tax_category                          VARCHAR2,
        X_end_date_active                       DATE,
        X_last_updated_by                       NUMBER,
        X_last_update_date                      DATE,
        X_created_by                            NUMBER,
        X_creation_date                         DATE,
        X_last_update_login                     NUMBER,
        X_threshold_check_level                 VARCHAR2,
        X_threshold_check_grp_by                VARCHAR2,
        --X_description                           VARCHAR2  DEFAULT NULL,
        X_min_amount                            NUMBER    DEFAULT NULL,
        X_min_taxable_basis                     NUMBER    DEFAULT NULL,
        X_min_percentage                        NUMBER    DEFAULT NULL,
        X_tax_inclusive                         VARCHAR2  DEFAULT NULL,
        X_org_tax_attribute                     VARCHAR2  DEFAULT NULL,
        X_cus_tax_attribute                     VARCHAR2  DEFAULT NULL,
        X_txn_tax_attribute                     VARCHAR2  DEFAULT NULL,
        X_tributary_substitution                VARCHAR2  DEFAULT NULL,
        X_used_to_reduce                        VARCHAR2  DEFAULT NULL,
        X_tax_categ_to_reduce_id                NUMBER    DEFAULT NULL,
        X_tax_code                              VARCHAR2  DEFAULT NULL,
        X_tax_authority_code                    VARCHAR2  DEFAULT NULL,
        X_mandatory_in_class                    VARCHAR2  DEFAULT NULL,
        X_print_flag                            VARCHAR2  DEFAULT NULL,
        X_tax_rule_set                          VARCHAR2  DEFAULT NULL,
        X_start_date_active                     DATE      DEFAULT NULL,
        X_tax_regime                            VARCHAR2  DEFAULT NULL,
        X_org_id                                NUMBER    DEFAULT NULL,
        X_attribute_category                    VARCHAR2  DEFAULT NULL,
        X_attribute1                            VARCHAR2  DEFAULT NULL,
        X_attribute2                            VARCHAR2  DEFAULT NULL,
        X_attribute3                            VARCHAR2  DEFAULT NULL,
        X_attribute4                            VARCHAR2  DEFAULT NULL,
        X_attribute5                            VARCHAR2  DEFAULT NULL,
        X_attribute6                            VARCHAR2  DEFAULT NULL,
        X_attribute7                            VARCHAR2  DEFAULT NULL,
        X_attribute8                            VARCHAR2  DEFAULT NULL,
        X_attribute9                            VARCHAR2  DEFAULT NULL,
        X_attribute10                           VARCHAR2  DEFAULT NULL,
        X_attribute11                           VARCHAR2  DEFAULT NULL,
        X_attribute12                           VARCHAR2  DEFAULT NULL,
        X_attribute13                           VARCHAR2  DEFAULT NULL,
        X_attribute14                           VARCHAR2  DEFAULT NULL,
        X_attribute15                           VARCHAR2  DEFAULT NULL,
        X_calling_sequence                   IN VARCHAR2);

  PROCEDURE Lock_Row
       (X_rowid                                 VARCHAR2,
        X_tax_category_id                       NUMBER,
        X_tax_category                          VARCHAR2,
        X_end_date_active                       DATE,
        X_last_updated_by                       NUMBER,
        X_last_update_date                      DATE,
        X_created_by                            NUMBER,
        X_creation_date                         DATE,
        X_last_update_login                     NUMBER,
        X_threshold_check_level                 VARCHAR2,
        X_threshold_check_grp_by                VARCHAR2,
        --X_description                           VARCHAR2  DEFAULT NULL,
        X_min_amount                            NUMBER    DEFAULT NULL,
        X_min_taxable_basis                     NUMBER    DEFAULT NULL,
        X_min_percentage                        NUMBER    DEFAULT NULL,
        X_tax_inclusive                         VARCHAR2  DEFAULT NULL,
        X_org_tax_attribute                     VARCHAR2  DEFAULT NULL,
        X_cus_tax_attribute                     VARCHAR2  DEFAULT NULL,
        X_txn_tax_attribute                     VARCHAR2  DEFAULT NULL,
        X_tributary_substitution                VARCHAR2  DEFAULT NULL,
        X_used_to_reduce                        VARCHAR2  DEFAULT NULL,
        X_tax_categ_to_reduce_id                NUMBER    DEFAULT NULL,
        X_tax_code                              VARCHAR2  DEFAULT NULL,
        X_tax_authority_code                    VARCHAR2  DEFAULT NULL,
        X_mandatory_in_class                    VARCHAR2  DEFAULT NULL,
        X_print_flag                            VARCHAR2  DEFAULT NULL,
        X_tax_rule_set                          VARCHAR2  DEFAULT NULL,
        X_start_date_active                     DATE      DEFAULT NULL,
        X_tax_regime                            VARCHAR2  DEFAULT NULL,
        X_org_id                             IN NUMBER    DEFAULT NULL,
        X_attribute_category                    VARCHAR2  DEFAULT NULL,
        X_attribute1                            VARCHAR2  DEFAULT NULL,
        X_attribute2                            VARCHAR2  DEFAULT NULL,
        X_attribute3                            VARCHAR2  DEFAULT NULL,
        X_attribute4                            VARCHAR2  DEFAULT NULL,
        X_attribute5                            VARCHAR2  DEFAULT NULL,
        X_attribute6                            VARCHAR2  DEFAULT NULL,
        X_attribute7                            VARCHAR2  DEFAULT NULL,
        X_attribute8                            VARCHAR2  DEFAULT NULL,
        X_attribute9                            VARCHAR2  DEFAULT NULL,
        X_attribute10                           VARCHAR2  DEFAULT NULL,
        X_attribute11                           VARCHAR2  DEFAULT NULL,
        X_attribute12                           VARCHAR2  DEFAULT NULL,
        X_attribute13                           VARCHAR2  DEFAULT NULL,
        X_attribute14                           VARCHAR2  DEFAULT NULL,
        X_attribute15                           VARCHAR2  DEFAULT NULL,
        X_calling_sequence                   IN VARCHAR2);


  PROCEDURE UpDate_Row
       (X_rowid                                 VARCHAR2,
        X_tax_category_id                       NUMBER,
        X_tax_category                          VARCHAR2,
        X_end_date_active                       DATE,
        X_last_updated_by                       NUMBER,
        X_last_update_date                      DATE,
        X_created_by                            NUMBER,
        X_creation_date                         DATE,
        X_last_update_login                     NUMBER,
        X_threshold_check_level                 VARCHAR2,
        X_threshold_check_grp_by                VARCHAR2,
        --X_description                           VARCHAR2  DEFAULT NULL,
        X_min_amount                            NUMBER    DEFAULT NULL,
        X_min_taxable_basis                     NUMBER    DEFAULT NULL,
        X_min_percentage                        NUMBER    DEFAULT NULL,
        X_tax_inclusive                         VARCHAR2  DEFAULT NULL,
        X_org_tax_attribute                     VARCHAR2  DEFAULT NULL,
        X_cus_tax_attribute                     VARCHAR2  DEFAULT NULL,
        X_txn_tax_attribute                     VARCHAR2  DEFAULT NULL,
        X_tributary_substitution                VARCHAR2  DEFAULT NULL,
        X_used_to_reduce                        VARCHAR2  DEFAULT NULL,
        X_tax_categ_to_reduce_id                NUMBER    DEFAULT NULL,
        X_tax_code                              VARCHAR2  DEFAULT NULL,
        X_tax_authority_code                    VARCHAR2  DEFAULT NULL,
        X_mandatory_in_class                    VARCHAR2  DEFAULT NULL,
        X_print_flag                            VARCHAR2  DEFAULT NULL,
        X_tax_rule_set                          VARCHAR2  DEFAULT NULL,
        X_start_date_active                     DATE      DEFAULT NULL,
        X_tax_regime                            VARCHAR2  DEFAULT NULL,
        X_org_id                             IN NUMBER    DEFAULT NULL,
        X_attribute_category                    VARCHAR2  DEFAULT NULL,
        X_attribute1                            VARCHAR2  DEFAULT NULL,
        X_attribute2                            VARCHAR2  DEFAULT NULL,
        X_attribute3                            VARCHAR2  DEFAULT NULL,
        X_attribute4                            VARCHAR2  DEFAULT NULL,
        X_attribute5                            VARCHAR2  DEFAULT NULL,
        X_attribute6                            VARCHAR2  DEFAULT NULL,
        X_attribute7                            VARCHAR2  DEFAULT NULL,
        X_attribute8                            VARCHAR2  DEFAULT NULL,
        X_attribute9                            VARCHAR2  DEFAULT NULL,
        X_attribute10                           VARCHAR2  DEFAULT NULL,
        X_attribute11                           VARCHAR2  DEFAULT NULL,
        X_attribute12                           VARCHAR2  DEFAULT NULL,
        X_attribute13                           VARCHAR2  DEFAULT NULL,
        X_attribute14                           VARCHAR2  DEFAULT NULL,
        X_attribute15                           VARCHAR2  DEFAULT NULL,
        X_calling_sequence                   IN VARCHAR2) ;


  PROCEDURE Delete_Row
       (X_rowid                                 VARCHAR2,
        X_tax_category_id                       NUMBER,
        X_end_date_active                       DATE,
        X_calling_sequence                   IN VARCHAR2);

  PROCEDURE Check_Unique
       (X_rowid                                 VARCHAR2,
        X_tax_category_id                       NUMBER,
        X_end_Date_active                       DATE,
        X_calling_sequence                   IN VARCHAR2);

  PROCEDURE Check_Overlapped_Dates
       (X_rowid                                 VARCHAR2,
        X_tax_category_id                       NUMBER,
        X_end_date_active                       DATE,
        X_start_date_active                     DATE,
        X_org_id                                NUMBER,
        X_calling_sequence                   IN VARCHAR2);


  PROCEDURE Check_Gaps
       (X_rowid                                 VARCHAR2,
        X_tax_category_id                       NUMBER,
        X_end_date_active                       DATE,
        X_start_date_active                     DATE,
        X_calling_sequence                   IN VARCHAR2);

END JL_ZZ_AR_TX_CATEG_PKG;

 

/