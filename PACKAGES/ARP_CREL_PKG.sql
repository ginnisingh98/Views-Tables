--------------------------------------------------------
--  DDL for Package ARP_CREL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CREL_PKG" AUTHID CURRENT_USER as
/* $Header: AROCRELS.pls 115.0 99/07/17 00:01:46 porting ship $ */
  --
  PROCEDURE  check_unique(x_customer_id in number ,x_related_customer_id in number );
  --
  PROCEDURE Insert_Row(X_Rowid                   IN OUT VARCHAR2,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE,
                       X_Customer_Id                    NUMBER,
                       X_Customer_Reciprocal_Flag       VARCHAR2,
		       X_relationship_type		VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Related_Customer_Id            NUMBER,
                       X_Status                         VARCHAR2,
                       X_Comments                       VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Attribute_Category             VARCHAR2,
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
                       X_Attribute15                    VARCHAR2
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Customer_Id                      NUMBER,
                     X_Customer_Reciprocal_Flag         VARCHAR2,
                     X_Related_Customer_Id              NUMBER,
                     X_Status                           VARCHAR2,
                     X_Comments                         VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Customer_Id                    NUMBER,
                       X_Customer_Reciprocal_Flag       VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Related_Customer_Id            NUMBER,
                       X_Status                         VARCHAR2,
                       X_Comments                       VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Attribute_Category             VARCHAR2,
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
                       X_Attribute15                    VARCHAR2
                      );
END arp_crel_pkg;

 

/
