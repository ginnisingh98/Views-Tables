--------------------------------------------------------
--  DDL for Package Body ARP_CROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CROL_PKG" as
/* $Header: AROCROLB.pls 120.1 2005/08/11 00:59:39 hyu noship $ */
--
--
--
-- PROCEDURE
--     check_unique
--
-- DESCRIPTION
--	Generates error if contact role is not unique
-- SCOPE -
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--			- p_contact_role_id
--			- p_contact_id
--			- p_usage_code
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
PROCEDURE check_unique( p_contact_role_id 	in number,
			  p_contact_id		in number,
			  p_usage_code		in varchar2) is
begin
   NULL;
end check_unique;
  --
  --
--
-- FUNCTION
--
--
-- DESCRIPTION
--	Checks to see if a contact role exists
-- SCOPE -
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:     p_contact_id
--			p_usage_code
--
--              OUT:
--
--
-- RETURNS    : Boolean - TRUE if contact role exists
--			  FALSE if contact role does not exists
--
-- NOTES
--
-- MODIFICATION HISTORY - Created by Kevin Hudson
--
--
FUNCTION contact_role_exists(p_contact_id in number ,p_usage_code in varchar2 ) return Boolean is
begin
	RETURN TRUE;
end contact_role_exists;
--
-- PROCEDURE
--     check_primary
--
-- DESCRIPTION
--		A contact may only have one primary role
-- SCOPE -
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--			p_contact_role_id
--			p_contact_id
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
PROCEDURE check_primary (p_contact_role_id	in number,
			   p_contact_id		in number ) is
  --
begin
  NULL;
end check_primary;
  --
PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Contact_Role_Id         IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Usage_Code                     VARCHAR2,
                       X_Contact_Id                     NUMBER,
                       X_Last_Update_Login              NUMBER,
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
END Insert_Row;
  --
  --

PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Contact_Role_Id                  NUMBER,
                     X_Usage_Code                       VARCHAR2,
                     X_Contact_Id                       NUMBER,
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
                       X_Contact_Role_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Usage_Code                     VARCHAR2,
                       X_Contact_Id                     NUMBER,
                       X_Last_Update_Login              NUMBER,
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
  --
  --
PROCEDURE delete_row(x_contact_id in number ,x_usage_code in varchar2) is
BEGIN
  NULL;
END delete_row;
  --
  --
  --
PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  NULL;
END Delete_Row;


END arp_crol_pkg;

/
