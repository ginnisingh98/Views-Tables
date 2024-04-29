--------------------------------------------------------
--  DDL for Package JL_ZZ_AR_TX_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_AR_TX_RULES_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzztxrs.pls 120.2 2003/03/03 19:39:50 opedrega ship $ */

  PROCEDURE Insert_Row
       (X_rowid             IN OUT NOCOPY VARCHAR2,
        X_rule_id                         NUMBER,
        X_tax_rule_level                  VARCHAR2,
        X_rule                            VARCHAR2,
        X_tax_category_id                 NUMBER,
        X_contributor_type                VARCHAR2,
        X_cust_trx_type_id                NUMBER,
        X_last_update_date                DATE,
        X_last_updated_by                 NUMBER,
        X_priority                        NUMBER,
        X_description                     VARCHAR2,
        X_org_id                          NUMBER,
        X_last_update_login               NUMBER,
        X_creation_date                   DATE,
        X_created_by                      NUMBER,
        X_calling_sequence  IN            VARCHAR2);

  PROCEDURE Lock_Row
       (X_rowid                           VARCHAR2,
        X_rule_id                         NUMBER,
        X_tax_rule_level                  VARCHAR2,
        X_rule                            VARCHAR2,
        X_tax_category_id                 NUMBER,
        X_contributor_type                VARCHAR2,
        X_cust_trx_type_id                NUMBER,
        X_last_update_date                DATE,
        X_last_updated_by                 NUMBER,
        X_priority                        NUMBER,
        X_description                     VARCHAR2,
        X_org_id                          NUMBER,
        X_last_update_login               NUMBER,
        X_creation_date                   DATE,
        X_created_by                      NUMBER,
        X_calling_sequence   IN           VARCHAR2);

  PROCEDURE Update_Row
       (X_rowid                           VARCHAR2,
        X_rule_id                         NUMBER,
        X_tax_rule_level                  VARCHAR2,
        X_rule                            VARCHAR2,
        X_tax_category_id                 NUMBER,
        X_contributor_type                VARCHAR2,
        X_cust_trx_type_id                NUMBER,
        X_last_update_date                DATE,
        X_last_updated_by                 NUMBER,
        X_priority                        NUMBER,
        X_description                     VARCHAR2,
        X_org_id                          NUMBER,
        X_last_update_login               NUMBER,
        X_creation_date                   DATE,
        X_created_by                      NUMBER,
        X_calling_sequence        IN      VARCHAR2);

  PROCEDURE Delete_Row
       (X_rowid                           VARCHAR2);

END JL_ZZ_AR_TX_RULES_PKG;

 

/
