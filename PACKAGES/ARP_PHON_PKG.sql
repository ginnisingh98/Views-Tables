--------------------------------------------------------
--  DDL for Package ARP_PHON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PHON_PKG" AUTHID CURRENT_USER as
/* $Header: AROPHONS.pls 120.1 2005/08/11 01:06:31 hyu noship $ */
  PROCEDURE check_primary(p_phone_id in number,
			  p_type     in varchar2,
			  p_id       in number);


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Phone_Id                IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Phone_Number                   VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Phone_Type                     VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Customer_Id                    NUMBER,
                       X_Address_Id                     NUMBER,
                       X_Contact_Id                     NUMBER,
                       X_Area_Code                      VARCHAR2,
                       X_Extension                      VARCHAR2,
                       X_Primary_Flag                   VARCHAR2,
                       X_Orig_System_Reference    IN OUT NOCOPY VARCHAR2,
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
                     X_Phone_Number                     VARCHAR2,
                     X_Status                           VARCHAR2,
                     X_Phone_Type                       VARCHAR2,
                     X_Area_Code                        VARCHAR2,
                     X_Extension                        VARCHAR2,
                     X_Primary_Flag                     VARCHAR2,
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
 		       X_phone_id			NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Phone_Number                   VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Phone_Type                     VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_customer_id			NUMBER,
		       X_address_id			NUMBER,
		       X_contact_id			NUMBER,
		       X_Area_Code                      VARCHAR2,
                       X_Extension                      VARCHAR2,
                       X_Primary_Flag                   VARCHAR2,
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
PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END arp_phon_pkg;

 

/
