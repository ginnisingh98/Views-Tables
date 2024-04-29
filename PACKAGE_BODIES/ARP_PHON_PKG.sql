--------------------------------------------------------
--  DDL for Package Body ARP_PHON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PHON_PKG" as
/* $Header: AROPHONB.pls 120.1 2005/08/11 01:08:20 hyu noship $ */
--
-- PROCEDURE
--     get_level
--
-- DESCRIPTION
--		This procedure detemermins which level the phone
--		is connected to cust|addr|cont
--
-- SCOPE - PROVATE
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--			p_customer_id
--			p_address_id
--			p_contact_id
--			p_type
--			p_id
--              OUT:
--                    None
--
-- RETURNS    : NONE
--
-- NOTES
--
-- MODIFICATION HISTORY - Created by Kevin Hudson
-- 21-Jan-00  Satheesh Nambiar  Bug 1171262
--
procedure get_level(	p_customer_id 	in number,
			p_address_id 	in number,
			p_contact_id 	in number,
			p_type 		out nocopy varchar2,
			p_id 		out nocopy number ) is
begin
  NULL;
end get_level;
--
--
-- PROCEDURE
--
--     check_primary
--
-- DESCRIPTION
--		This procedure ensure that a cust|addr|cont only
--		has one primary telephone.
--
-- SCOPE -
--		PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:     p_phone_id
--			p_type      (CUST|ADDR|CONT)
--			p_id
--              OUT:
--                    None
--
-- RETURNS    : NONE
--
-- NOTES
--
-- MODIFICATION HISTORY - Created by Kevin Hudson
--
--
PROCEDURE check_primary(p_phone_id 	in number,
			  p_type	in varchar2,
			  p_id 		in number ) is
BEGIN
   NULL;
END check_primary;
  --
  --
  --
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
                       X_Orig_System_Reference   IN OUT NOCOPY VARCHAR2,
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
  ) IS
BEGIN
  NULL;
END Insert_Row;


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
  ) IS
BEGIN
  NULL;
END Lock_Row;



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
  ) IS
BEGIN
  NULL;
END Update_Row;


PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  NULL;
END Delete_Row;


END arp_phon_pkg;

/
