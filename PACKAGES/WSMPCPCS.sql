--------------------------------------------------------
--  DDL for Package WSMPCPCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSMPCPCS" AUTHID CURRENT_USER as
/* $Header: WSMCPCSS.pls 120.1 2005/06/29 04:33:17 abgangul noship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_co_product_group_id            NUMBER,
                       X_substitute_component_id        NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Substitute_Item_Quantity       NUMBER,
                       X_attribute_category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Request_Id                     NUMBER,
                       X_Program_Application_Id         NUMBER,
                       X_Program_Id                     NUMBER,
                       X_Program_Update_Date            DATE,
                       X_basis_type                     NUMBER      ---LBM enh
                      );

  PROCEDURE Update_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_co_product_group_id            NUMBER,
                       X_substitute_component_id        NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Substitute_Item_Quantity       NUMBER,
                       X_attribute_category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Request_Id                     NUMBER,
                       X_Program_Application_Id         NUMBER,
                       X_Program_Id                     NUMBER,
                       X_Program_Update_Date            DATE,
                       X_basis_type                     NUMBER      ---LBM enh
                      );


  PROCEDURE Lock_Row  (X_Rowid                          VARCHAR2,
                       X_co_product_group_id            NUMBER,
                       X_substitute_component_id        NUMBER,
                       X_Substitute_Item_Quantity       NUMBER,
                       X_attribute_category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_basis_type                     NUMBER      ---LBM enh
                      );


  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

  PROCEDURE Check_Unique(X_rowid	           VARCHAR2,
			 X_co_product_group_id	   NUMBER,
                         X_substitute_component_id NUMBER,
                         X_organization_id         NUMBER);

END WSMPCPCS;

 

/
