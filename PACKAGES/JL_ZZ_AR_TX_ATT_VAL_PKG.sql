--------------------------------------------------------
--  DDL for Package JL_ZZ_AR_TX_ATT_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_AR_TX_ATT_VAL_PKG" AUTHID CURRENT_USER as
/* $Header: jlzztavs.pls 120.2 2003/03/03 19:31:13 opedrega ship $ */

  PROCEDURE Insert_Row
       (X_rowid                 IN OUT NOCOPY VARCHAR2,
        X_tax_categ_attr_val_id               NUMBER,
        X_tax_category_id                     NUMBER,
        X_tax_attribute_type                  VARCHAR2,
        X_tax_attribute_name                  VARCHAR2,
        X_tax_attribute_value                 VARCHAR2,
        X_tax_attr_value_code                 VARCHAR2,
        X_default_to_class                    VARCHAR2,
        X_org_id                              NUMBER,
        X_LAST_UPDATE_DATE                    DATE,
        X_LAST_UPDATED_BY                     NUMBER,
        X_CREATION_DATE                       DATE,
        X_CREATED_BY                          NUMBER,
        X_LAST_UPDATE_LOGIN                   NUMBER,
        X_attribute_category                  VARCHAR2,
        X_attribute1                          VARCHAR2,
        X_attribute2                          VARCHAR2,
        X_attribute3                          VARCHAR2,
        X_attribute4                          VARCHAR2,
        X_attribute5                          VARCHAR2,
        X_attribute6                          VARCHAR2,
        X_attribute7                          VARCHAR2,
        X_attribute8                          VARCHAR2,
        X_attribute9                          VARCHAR2,
        X_attribute10                         VARCHAR2,
        X_attribute11                         VARCHAR2,
        X_attribute12                         VARCHAR2,
        X_attribute13                         VARCHAR2,
        X_attribute14                         VARCHAR2,
        X_attribute15                         VARCHAR2,
        X_calling_sequence        IN          VARCHAR2);

  PROCEDURE Lock_Row
       (X_rowid                               VARCHAR2,
        X_tax_categ_attr_val_id               NUMBER,
        X_tax_category_id                     NUMBER,
        X_tax_attribute_type                  VARCHAR2,
        X_tax_attribute_name                  VARCHAR2,
        X_tax_attribute_value                 VARCHAR2,
        X_tax_attr_value_code                 VARCHAR2,
        X_default_to_class                    VARCHAR2,
        X_org_id                              NUMBER,
        X_LAST_UPDATE_DATE                    DATE,
        X_LAST_UPDATED_BY                     NUMBER,
        X_CREATION_DATE                       DATE,
        X_CREATED_BY                          NUMBER,
        X_LAST_UPDATE_LOGIN                   NUMBER,
        X_attribute_category                  VARCHAR2,
        X_attribute1                          VARCHAR2,
        X_attribute2                          VARCHAR2,
        X_attribute3                          VARCHAR2,
        X_attribute4                          VARCHAR2,
        X_attribute5                          VARCHAR2,
        X_attribute6                          VARCHAR2,
        X_attribute7                          VARCHAR2,
        X_attribute8                          VARCHAR2,
        X_attribute9                          VARCHAR2,
        X_attribute10                         VARCHAR2,
        X_attribute11                         VARCHAR2,
        X_attribute12                         VARCHAR2,
        X_attribute13                         VARCHAR2,
        X_attribute14                         VARCHAR2,
        X_attribute15                         VARCHAR2,
        X_calling_sequence        IN          VARCHAR2);

  PROCEDURE Update_Row
       (X_rowid                               VARCHAR2,
        X_tax_categ_attr_val_id               NUMBER,
        X_tax_category_id                     NUMBER,
        X_tax_attribute_type                  VARCHAR2,
        X_tax_attribute_name                  VARCHAR2,
        X_tax_attribute_value                 VARCHAR2,
        X_tax_attr_value_code                 VARCHAR2,
        X_default_to_class                    VARCHAR2,
        X_org_id                              NUMBER,
        X_LAST_UPDATE_DATE                    DATE,
        X_LAST_UPDATED_BY                     NUMBER,
        X_CREATION_DATE                       DATE,
        X_CREATED_BY                          NUMBER,
        X_LAST_UPDATE_LOGIN                   NUMBER,
        X_attribute_category                  VARCHAR2,
        X_attribute1                          VARCHAR2,
        X_attribute2                          VARCHAR2,
        X_attribute3                          VARCHAR2,
        X_attribute4                          VARCHAR2,
        X_attribute5                          VARCHAR2,
        X_attribute6                          VARCHAR2,
        X_attribute7                          VARCHAR2,
        X_attribute8                          VARCHAR2,
        X_attribute9                          VARCHAR2,
        X_attribute10                         VARCHAR2,
        X_attribute11                         VARCHAR2,
        X_attribute12                         VARCHAR2,
        X_attribute13                         VARCHAR2,
        X_attribute14                         VARCHAR2,
        X_attribute15                         VARCHAR2,
        X_calling_sequence        IN          VARCHAR2);

  PROCEDURE Delete_Row
       (X_rowid                               VARCHAR2);

  PROCEDURE Check_Unique
       (X_rowid                               VARCHAR2,
        X_tax_category_id                     NUMBER,
        X_tax_attribute_type                  VARCHAR2,
        X_tax_attribute_name                  VARCHAR2,
        X_tax_attribute_value                 VARCHAR2,
        X_org_id                              NUMBER,
        X_calling_sequence        IN          VARCHAR2);

  PROCEDURE Check_Default_To_Class
       (X_rowid                               VARCHAR2,
        X_tax_category_id                     NUMBER,
        X_tax_attribute_type                  VARCHAR2,
        X_tax_attribute_name                  VARCHAR2,
        X_default_to_class                    VARCHAR2,
        X_org_id                              NUMBER,
        X_calling_sequence        IN          VARCHAR2);

END JL_ZZ_AR_TX_ATT_VAL_PKG;

 

/
