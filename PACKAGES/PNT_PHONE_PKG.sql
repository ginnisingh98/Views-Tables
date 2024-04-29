--------------------------------------------------------
--  DDL for Package PNT_PHONE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PNT_PHONE_PKG" AUTHID CURRENT_USER as
  -- $Header: PNTPHONS.pls 120.1 2005/07/25 05:51:22 appldev ship $

  PROCEDURE check_primary (p_phone_id    IN NUMBER,
			               p_contact_id  IN NUMBER,
			               p_org_id      IN NUMBER default NULL
                          );

  PROCEDURE Insert_Row ( X_Rowid                   IN OUT NOCOPY VARCHAR2,
                         X_Phone_Id                IN OUT NOCOPY NUMBER,
                         X_Last_Update_Date               DATE,
                         X_Last_Updated_By                NUMBER,
                         X_Creation_Date                  DATE,
                         X_Created_By                     NUMBER,
                         X_Phone_Number                   VARCHAR2,
                         X_Status                         VARCHAR2,
                         X_Phone_Type                     VARCHAR2,
                         X_Last_Update_Login              NUMBER,
                         X_Contact_Id                     NUMBER,
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
                         X_Attribute15                    VARCHAR2,
                         X_Org_id                         NUMBER default NULL
                      );

  PROCEDURE Update_Row ( X_Rowid                          VARCHAR2,
 		                 X_phone_id			              NUMBER,
                         X_Last_Update_Date               DATE,
                         X_Last_Updated_By                NUMBER,
                         X_Phone_Number                   VARCHAR2,
                         X_Status                         VARCHAR2,
                         X_Phone_Type                     VARCHAR2,
                         X_Last_Update_Login              NUMBER,
                         X_Contact_Id                     NUMBER,
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

  PROCEDURE lock_row   ( X_Rowid                          VARCHAR2,
                         X_Phone_Number                   VARCHAR2,
                         X_Status                         VARCHAR2,
                         X_Phone_Type                     VARCHAR2,
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

PROCEDURE delete_row ( x_rowid                         VARCHAR2
                     );

PROCEDURE delete_row ( x_phone_id                         NUMBER
                     );

END PNT_PHONE_PKG;

 

/
