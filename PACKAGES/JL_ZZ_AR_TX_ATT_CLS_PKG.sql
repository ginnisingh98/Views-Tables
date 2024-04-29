--------------------------------------------------------
--  DDL for Package JL_ZZ_AR_TX_ATT_CLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_AR_TX_ATT_CLS_PKG" AUTHID CURRENT_USER as
/* $Header: jlzztcls.pls 120.2 2003/03/03 19:33:49 opedrega ship $ */

  PROCEDURE Populate_All_Rows
       (X_class_type                            VARCHAR2,
        X_class_code                            VARCHAR2,
        X_enabled_flag                          VARCHAR2,
        X_org_id                                NUMBER);

  PROCEDURE Populate_Mandatory_Rows
       (X_class_type                            VARCHAR2,
        X_class_code                            VARCHAR2,
        X_enabled_flag                          VARCHAR2,
        X_org_id                                NUMBER);

  PROCEDURE Insert_Row
       (X_rowid                   IN OUT NOCOPY VARCHAR2,
        X_attribute_class_id                    NUMBER,
        X_tax_attr_class_type                   VARCHAR2,
        X_tax_attr_class_code                   VARCHAR2,
        X_tax_category_id                       NUMBER,
        X_tax_attribute_type                    VARCHAR2,
        X_tax_attribute_name                    VARCHAR2,
        X_tax_attribute_value                   VARCHAR2,
        X_enabled_flag                          VARCHAR2,
        X_org_id                                NUMBER,
        X_last_updated_by                       NUMBER,
        X_last_update_date                      DATE,
        X_last_update_login                     NUMBER,
        X_creation_date                         DATE,
        X_created_by                            NUMBER,
        X_attribute_category                    VARCHAR2,
        X_attribute1                            VARCHAR2,
        X_attribute2                            VARCHAR2,
        X_attribute3                            VARCHAR2,
        X_attribute4                            VARCHAR2,
        X_attribute5                            VARCHAR2,
        X_attribute6                            VARCHAR2,
        X_attribute7                            VARCHAR2,
        X_attribute8                            VARCHAR2,
        X_attribute9                            VARCHAR2,
        X_attribute10                           VARCHAR2,
        X_attribute11                           VARCHAR2,
        X_attribute12                           VARCHAR2,
        X_attribute13                           VARCHAR2,
        X_attribute14                           VARCHAR2,
        X_attribute15                           VARCHAR2,
        X_calling_sequence        IN            VARCHAR2);

  PROCEDURE Update_Row
       (X_rowid                                 VARCHAR2,
        X_tax_attr_class_type                   VARCHAR2,
        X_tax_attr_class_code                   VARCHAR2,
        X_tax_category_id                       NUMBER,
        X_tax_attribute_type                    VARCHAR2,
        X_tax_attribute_name                    VARCHAR2,
        X_tax_attribute_value                   VARCHAR2,
        X_enabled_flag                          VARCHAR2,
        X_org_id                                NUMBER,
        X_last_updated_by                       NUMBER,
        X_last_update_date                      DATE,
        X_last_update_login                     NUMBER,
        X_creation_date                         DATE,
        X_created_by                            NUMBER,
        X_attribute_category                    VARCHAR2,
        X_attribute1                            VARCHAR2,
        X_attribute2                            VARCHAR2,
        X_attribute3                            VARCHAR2,
        X_attribute4                            VARCHAR2,
        X_attribute5                            VARCHAR2,
        X_attribute6                            VARCHAR2,
        X_attribute7                            VARCHAR2,
        X_attribute8                            VARCHAR2,
        X_attribute9                            VARCHAR2,
        X_attribute10                           VARCHAR2,
        X_attribute11                           VARCHAR2,
        X_attribute12                           VARCHAR2,
        X_attribute13                           VARCHAR2,
        X_attribute14                           VARCHAR2,
        X_attribute15                           VARCHAR2,
        X_calling_sequence        IN            VARCHAR2);

  PROCEDURE Delete_Row
       (X_rowid                                 VARCHAR2);

  PROCEDURE Lock_Row
       (X_rowid                                 VARCHAR2,
        X_tax_attr_class_type                   VARCHAR2,
        X_tax_attr_class_code                   VARCHAR2,
        X_tax_category_id                       NUMBER,
        X_tax_attribute_type                    VARCHAR2,
        X_tax_attribute_name                    VARCHAR2,
        X_tax_attribute_value                   VARCHAR2,
        X_enabled_flag                          VARCHAR2,
        X_org_id                                NUMBER,
        X_last_updated_by                       NUMBER,
        X_last_update_date                      DATE,
        X_last_update_login                     NUMBER,
        X_creation_date                         DATE,
        X_created_by                            NUMBER,
        X_attribute_category                    VARCHAR2,
        X_attribute1                            VARCHAR2,
        X_attribute2                            VARCHAR2,
        X_attribute3                            VARCHAR2,
        X_attribute4                            VARCHAR2,
        X_attribute5                            VARCHAR2,
        X_attribute6                            VARCHAR2,
        X_attribute7                            VARCHAR2,
        X_attribute8                            VARCHAR2,
        X_attribute9                            VARCHAR2,
        X_attribute10                           VARCHAR2,
        X_attribute11                           VARCHAR2,
        X_attribute12                           VARCHAR2,
        X_attribute13                           VARCHAR2,
        X_attribute14                           VARCHAR2,
        X_attribute15                           VARCHAR2,
        X_calling_sequence        IN            VARCHAR2);

  PROCEDURE Check_Unique
       (X_rowid                                 VARCHAR2,
        X_tax_attr_class_type                   VARCHAR2,
        X_tax_attr_class_code                   VARCHAR2,
        X_tax_category_id                       NUMBER,
        X_tax_attribute_type                    VARCHAR2,
        X_tax_attribute_name                    VARCHAR2,
        X_org_id                                NUMBER,
        X_calling_sequence        IN            VARCHAR2);

  FUNCTION Check_Unique_Detail
       (X_lookup_type                           VARCHAR2,
        X_lookup_code                           VARCHAR2,
        X_lookup_code_out           OUT NOCOPY  VARCHAR2,
	    X_org_id                                NUMBER,
        X_calling_sequence        IN            VARCHAR2) RETURN NUMBER;

END JL_ZZ_AR_TX_ATT_CLS_PKG;

 

/
