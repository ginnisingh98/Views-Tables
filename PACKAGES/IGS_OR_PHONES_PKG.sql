--------------------------------------------------------
--  DDL for Package IGS_OR_PHONES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_PHONES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSOI25S.pls 115.5 2003/05/06 09:30:58 ssawhney ship $ */
/******************************************************************
Change History

Who                          When                            What
npalanis                     15-feb-2002                  Bug ID - 2225917  : SWCR008  Removed  parameters
                                                                       Customer_Id ,Address_Id,Contact_Id, in
                                                                       Insert_row and Update Row Procedure ,
ssawhney                     30-APR-2003		  OVN changes for V2API

***************************************************************** */


  PROCEDURE Insert_Row(
                       X_Phone_Id                IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Phone_Number                   VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Phone_Type                     VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Country_code                   VARCHAR2,
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
                       X_Attribute15                    VARCHAR2,
                       X_Attribute16                    VARCHAR2,
                       X_Attribute17                    VARCHAR2,
                       X_Attribute18                    VARCHAR2,
                       X_Attribute19                    VARCHAR2,
                       X_Attribute20                    VARCHAR2,
                       x_party_id                       NUMBER,
                       x_party_site_id                  NUMBER,
                       x_msg_count                  OUT NOCOPY NUMBER,
                       x_msg_data                   OUT NOCOPY VARCHAR2,
                       x_return_status              OUT NOCOPY VARCHAR2,
		       x_contact_point_ovn          IN OUT NOCOPY NUMBER);


  PROCEDURE Update_Row(
 		       X_phone_id			NUMBER,
                       X_Last_Update_Date          IN OUT NOCOPY     DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Phone_Number                   VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Phone_Type                     VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_country_code                   VARCHAR2,
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
                       X_Attribute16                    VARCHAR2,
                       X_Attribute17                    VARCHAR2,
                       X_Attribute18                    VARCHAR2,
                       X_Attribute19                    VARCHAR2,
                       X_Attribute20                    VARCHAR2,
                       x_msg_count                  OUT NOCOPY NUMBER,
                       x_msg_data                   OUT NOCOPY VARCHAR2,
                       x_return_status              OUT NOCOPY VARCHAR2,
		       x_contact_point_ovn          IN OUT NOCOPY NUMBER);


PROCEDURE Delete_Row(X_phoneid   VARCHAR2);

END igs_or_phones_pkg;

 

/
