--------------------------------------------------------
--  DDL for Package JL_ZZ_AR_TX_CUS_CLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_AR_TX_CUS_CLS_PKG" AUTHID CURRENT_USER as
/* $Header: jlzztacs.pls 120.2 2003/03/03 19:32:17 opedrega ship $ */

  PROCEDURE Populate_Cus_Cls_Rows
       (X_address_id                        NUMBER,
        X_class_code                        VARCHAR2,
        X_org_id                            NUMBER);

  PROCEDURE Insert_Row
       (X_rowid               IN OUT NOCOPY VARCHAR2,
        X_cus_class_id                      NUMBER,
        X_address_id                        NUMBER,
        X_tax_attr_class_code               VARCHAR2,
        X_tax_category_id                   NUMBER,
        X_tax_attribute_name                VARCHAR2,
        X_tax_attribute_value               VARCHAR2,
        X_enabled_flag                      VARCHAR2,
        X_org_id                            NUMBER,
        X_last_updated_by                   NUMBER,
        X_last_update_date                  DATE,
        X_last_update_login                 NUMBER,
        X_creation_date                     DATE,
        X_created_by                        NUMBER,
        X_calling_sequence    IN            VARCHAR2);

  PROCEDURE Update_Row
       (X_rowid                             VARCHAR2,
        X_cus_class_id                      NUMBER,
        X_address_id                        NUMBER,
        X_tax_attr_class_code               VARCHAR2,
        X_tax_category_id                   NUMBER,
        X_tax_attribute_name                VARCHAR2,
        X_tax_attribute_value               VARCHAR2,
        X_enabled_flag                      VARCHAR2,
        X_org_id                            NUMBER,
        X_last_updated_by                   NUMBER,
        X_last_update_date                  DATE,
        X_last_update_login                 NUMBER,
        X_creation_date                     DATE,
        X_created_by                        NUMBER,
        X_calling_sequence    IN            VARCHAR2);

  PROCEDURE Delete_Row
       (X_rowid                             VARCHAR2);

  PROCEDURE Lock_Row
       (X_rowid                             VARCHAR2,
        X_cus_class_id                      NUMBER,
        X_address_id                        NUMBER,
        X_tax_attr_class_code               VARCHAR2,
        X_tax_category_id                   NUMBER,
        X_tax_attribute_name                VARCHAR2,
        X_tax_attribute_value               VARCHAR2,
        X_enabled_flag                      VARCHAR2,
        X_org_id                            NUMBER,
        X_last_updated_by                   NUMBER,
        X_last_update_date                  DATE,
        X_last_update_login                 NUMBER,
        X_creation_date                     DATE,
        X_created_by                        NUMBER,
        X_calling_sequence    IN            VARCHAR2);

  PROCEDURE Check_Unique
       (X_rowid                             VARCHAR2,
        X_address_id                        NUMBER,
        X_tax_attr_class_code               VARCHAR2,
        X_tax_category_id                   NUMBER,
        X_tax_attribute_name                VARCHAR2,
        X_org_id                            NUMBER,
        X_calling_sequence    IN            VARCHAR2);

END JL_ZZ_AR_TX_CUS_CLS_PKG;

 

/
