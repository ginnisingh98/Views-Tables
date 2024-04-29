--------------------------------------------------------
--  DDL for Package JL_ZZ_AR_TX_LGL_MSG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_AR_TX_LGL_MSG_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzztlms.pls 120.2 2003/03/03 19:36:29 opedrega ship $ */

  PROCEDURE Insert_Row
       (X_rowid                     IN OUT NOCOPY VARCHAR2,
        X_rule_id                                 NUMBER,
        X_rule_data_id                            NUMBER,
        X_exception_code                          VARCHAR2,
        X_message_id                              NUMBER,
        X_inventory_item_flag                     VARCHAR2,
        X_inventory_organization_id               NUMBER,
        X_start_date_active                       DATE,
        X_end_date_active                         DATE,
        X_org_id                                  NUMBER,
        X_last_update_date                        DATE,
        X_last_updated_by                         NUMBER,
        X_last_update_login                       NUMBER,
        X_creation_date                           DATE,
        X_created_by                              NUMBER,
        X_calling_sequence          IN            VARCHAR2);

  PROCEDURE Lock_Row
       (X_rowid                                   VARCHAR2,
        X_rule_id                                 NUMBER,
        X_rule_data_id                            NUMBER,
        X_exception_code                          VARCHAR2,
        X_message_id                              NUMBER,
        X_inventory_item_flag                     VARCHAR2,
        X_inventory_organization_id               NUMBER,
        X_start_date_active                       DATE,
        X_end_date_active                         DATE,
        X_org_id                                  NUMBER,
        X_last_update_date                        DATE,
        X_last_updated_by                         NUMBER,
        X_last_update_login                       NUMBER,
        X_creation_date                           DATE,
        X_created_by                              NUMBER,
        X_calling_sequence          IN            VARCHAR2);

  PROCEDURE Update_Row
       (X_rowid                                   VARCHAR2,
        X_rule_id                                 NUMBER,
        X_rule_data_id                            NUMBER,
        X_exception_code                          VARCHAR2,
        X_message_id                              NUMBER,
        X_inventory_item_flag                     VARCHAR2,
        X_inventory_organization_id               NUMBER,
        X_start_date_active                       DATE,
        X_end_date_active                         DATE,
        X_org_id                                  NUMBER,
        X_last_update_date                        DATE,
        X_last_updated_by                         NUMBER,
        X_last_update_login                       NUMBER,
        X_creation_date                           DATE,
        X_created_by                              NUMBER,
        X_calling_sequence          IN            VARCHAR2);

  PROCEDURE Delete_Row
       (X_rowid         VARCHAR2) ;

  PROCEDURE Check_Unique
       (X_rowid                                   VARCHAR2,
        X_rule_id                                 NUMBER,
        X_rule_data_id                            NUMBER,
        X_exception_code                          VARCHAR2,
        X_org_id                                  NUMBER);

END JL_ZZ_AR_TX_LGL_MSG_PKG;

 

/
