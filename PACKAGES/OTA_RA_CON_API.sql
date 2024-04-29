--------------------------------------------------------
--  DDL for Package OTA_RA_CON_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_RA_CON_API" AUTHID CURRENT_USER as
/* $Header: otcon01t.pkh 120.0.12000000.1 2007/01/18 03:59:45 appldev noship $ */

--
-- |--------------------------------------------------------------------------|
-- |-------------------------< insert_contact >-------------------------------|
-- |--------------------------------------------------------------------------|
--
-- PUBLIC
-- Inserts a Contact into RA_CONTACTS using name and customer ID
-- Currently only used by Delegate Bookings
--
procedure insert_contact (p_contact_id        out nocopy number,
                          p_customer_id       in  number,
                          p_last_name         in  varchar2,
                          p_first_name        in  varchar2,
                          p_title             in  varchar2,
                          p_administrator     in  number);

-- |--------------------------------------------------------------------------|
-- |-------------------------< update_contact >-------------------------------|
-- |--------------------------------------------------------------------------|
--
-- PUBLIC
-- Updates a given Contact in RA_CONTACTS
-- Currently only used by Delegate Bookings
--
--
procedure update_contact (p_contact_id        in number,
                          p_last_name         in varchar2,
                          p_first_name        in varchar2,
                          p_title             in varchar2);

-- |--------------------------------------------------------------------------|
-- |-------------------------< insert_row >-----------------------------------|
-- |--------------------------------------------------------------------------|
--
-- PUBLIC
--
PROCEDURE Insert_Row(
                       X_Contact_Id              IN OUT NOCOPY NUMBER,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE     DEFAULT sysdate,
                       X_Customer_Id                    NUMBER,
                       X_Last_Name                      VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE     DEFAULT sysdate,
                       X_Orig_System_Reference  IN OUT NOCOPY  VARCHAR2 ,
                       X_Status                         VARCHAR2 DEFAULT 'A',
                       X_Address_Id                     NUMBER   DEFAULT NULL,
                       X_Contact_Key                    VARCHAR2 DEFAULT NULL,
                       X_First_Name                     VARCHAR2,
                       X_Job_Title                      VARCHAR2 DEFAULT NULL,
                       X_Last_Update_Login              NUMBER   DEFAULT NULL,
                       X_Mail_Stop                      VARCHAR2 DEFAULT NULL,
                       X_Title                          VARCHAR2,
                       X_Attribute_Category             VARCHAR2 DEFAULT NULL,
                       X_Attribute1                     VARCHAR2 DEFAULT NULL,
                       X_Attribute2                     VARCHAR2 DEFAULT NULL,
                       X_Attribute3                     VARCHAR2 DEFAULT NULL,
                       X_Attribute4                     VARCHAR2 DEFAULT NULL,
                       X_Attribute5                     VARCHAR2 DEFAULT NULL,
                       X_Attribute6                     VARCHAR2 DEFAULT NULL,
                       X_Attribute7                     VARCHAR2 DEFAULT NULL,
                       X_Attribute8                     VARCHAR2 DEFAULT NULL,
                       X_Attribute9                     VARCHAR2 DEFAULT NULL,
                       X_Attribute10                    VARCHAR2 DEFAULT NULL,
                       X_Attribute11                    VARCHAR2 DEFAULT NULL,
                       X_Attribute12                    VARCHAR2 DEFAULT NULL,
                       X_Attribute13                    VARCHAR2 DEFAULT NULL,
                       X_Attribute14                    VARCHAR2 DEFAULT NULL,
                       X_Attribute15                    VARCHAR2 DEFAULT NULL,
                       X_Attribute16                    VARCHAR2 DEFAULT NULL,
                       X_Attribute17                    VARCHAR2 DEFAULT NULL,
                       X_Attribute18                    VARCHAR2 DEFAULT NULL,
                       X_Attribute19                    VARCHAR2 DEFAULT NULL,
                       X_Attribute20                    VARCHAR2 DEFAULT NULL,
                       X_Attribute21                    VARCHAR2 DEFAULT NULL,
                       X_Attribute22                    VARCHAR2 DEFAULT NULL,
                       X_Attribute23                    VARCHAR2 DEFAULT NULL,
                       X_Attribute24                    VARCHAR2 DEFAULT NULL,
                       X_Attribute25                    VARCHAR2 DEFAULT NULL,
                       X_Email_Address                  VARCHAR2 DEFAULT NULL,
                       X_Last_Name_Alt                  VARCHAR2 DEFAULT NULL,
                       X_First_Name_Alt                 VARCHAR2 DEFAULT NULL,
                       X_Contact_Number        IN OUT NOCOPY   VARCHAR2 ,
                       X_Party_Id                       NUMBER DEFAULT NULL,
                       X_Party_Site_Id                  NUMBER DEFAULT NULL,
                       X_Contact_Party_Id     IN OUT NOCOPY    NUMBER ,
                       X_Rel_Party_Id         IN OUT NOCOPY    NUMBER ,
                       X_Org_Contact_Id       IN OUT NOCOPY    NUMBER ,
                       X_Contact_Point_Id               NUMBER DEFAULT NULL,
                       X_Cust_Account_Role_Id   IN OUT NOCOPY  NUMBER ,
                       X_Return_Status             OUT NOCOPY  VARCHAR2,
                       X_Msg_Count                 OUT NOCOPY  NUMBER,
                       X_Msg_Data                  OUT NOCOPY  VARCHAR2
  );


end ota_ra_con_api;

 

/
