--------------------------------------------------------
--  DDL for Package Body ARP_CONT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CONT_PKG" as
/* $Header: AROCONTB.pls 120.1 2005/08/11 00:42:38 hyu noship $ */
--
-- PROCEDURE
--     check_unique_contact_name
--
-- DESCRIPTION
--		This procedure checks that a contact name is unique.
--		If it is not it sets a message on the stack and returns
--		a warning flag.
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:     x_rowid 		- uid of row
--			x_customer_id		- customer_id
--			x_first_name		-
--			x_last_name
--              OUT:
--                     	x_warning_flag  	-  W - Warning generated
--					         null - no warning genrated
-- NOTES
--
--
--
--
PROCEDURE check_unique_contact_name (	x_rowid 	IN VARCHAR2,
					x_customer_id	IN NUMBER,
					x_first_name 	IN VARCHAR2,
					x_last_name     IN VARCHAR2,
					x_warning_flag  IN OUT NOCOPY VARCHAR2 )	IS
begin
 NULL;
END check_unique_contact_name;
--
--
--
--
--
-- PROCEDURE
--     check_unique_orig_system_ref
--
-- DESCRIPTION
--		This procedure checks that orig_system_reference  is unique.
--		If it is not it sets a message on the stack and returns
--		failure.
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:     x_rowid 		- uid of row
--			x_orig_system_reference - value to check
--              OUT:

-- NOTES
--
--
--
--
PROCEDURE check_unique_orig_system_ref(	x_rowid IN VARCHAR2,
					x_orig_system_reference IN VARCHAR2 ) IS
--
--
begin
NULL;
end check_unique_orig_system_ref;

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Contact_Id              IN OUT NOCOPY NUMBER,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE,
                       X_Customer_Id                    NUMBER,
                       X_Last_Name                      VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Orig_System_Reference   IN OUT NOCOPY VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Address_Id                     NUMBER,
                       X_Contact_Key                    VARCHAR2,
                       X_First_Name                     VARCHAR2,
                       X_Job_Title                      VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Mail_Stop                      VARCHAR2,
                       X_Title                          VARCHAR2,
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
                       X_Attribute21                    VARCHAR2,
                       X_Attribute22                    VARCHAR2,
                       X_Attribute23                    VARCHAR2,
                       X_Attribute24                    VARCHAR2,
                       X_Attribute25                    VARCHAR2,
                       X_Email_Address                  VARCHAR2,
                       X_Last_Name_Alt                  VARCHAR2 default null,
                       X_First_Name_Alt                 VARCHAR2 default null
  ) IS

BEGIN
  NULL;
END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
		     X_contact_id			number,
                     X_Last_Name                        VARCHAR2,
                     X_Status                           VARCHAR2,
                     X_Contact_Key                      VARCHAR2,
                     X_First_Name                       VARCHAR2,
                     X_Job_Title                        VARCHAR2,
                     X_Mail_Stop                        VARCHAR2,
                     X_Title                            VARCHAR2,
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
                     X_Attribute15                      VARCHAR2,
                     X_Attribute16                      VARCHAR2,
                     X_Attribute17                      VARCHAR2,
                     X_Attribute18                      VARCHAR2,
                     X_Attribute19                      VARCHAR2,
                     X_Attribute20                      VARCHAR2,
                     X_Attribute21                      VARCHAR2,
                     X_Attribute22                      VARCHAR2,
                     X_Attribute23                      VARCHAR2,
                     X_Attribute24                      VARCHAR2,
                     X_Attribute25                      VARCHAR2,
                     X_Email_Address                    VARCHAR2,
                     X_Last_Name_Alt                    VARCHAR2 default g_varchar2,
                     X_First_Name_Alt                   VARCHAR2 default g_varchar2
  ) IS
BEGIN
  NULL;
END Lock_Row;



PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
		       X_contact_id			number,
                       X_Last_Name                      VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Status                         VARCHAR2,
                       X_Contact_Key                    VARCHAR2,
                       X_First_Name                     VARCHAR2,
                       X_Job_Title                      VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Mail_Stop                      VARCHAR2,
                       X_Title                          VARCHAR2,
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
                       X_Attribute21                    VARCHAR2,
                       X_Attribute22                    VARCHAR2,
                       X_Attribute23                    VARCHAR2,
                       X_Attribute24                    VARCHAR2,
                       X_Attribute25                    VARCHAR2,
                       X_Email_Address                  VARCHAR2,
                       X_Last_Name_Alt                  VARCHAR2 default g_varchar2,
                       X_First_Name_Alt                 VARCHAR2 default g_varchar2
  ) IS
BEGIN
  NULL;
END Update_Row;



END arp_cont_pkg;

/
