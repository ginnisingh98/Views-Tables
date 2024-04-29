--------------------------------------------------------
--  DDL for Package Body HZ_ADDR_ISPEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ADDR_ISPEED_PKG" as
/* $Header: ARHADISB.pls 120.4 2005/10/30 03:50:39 appldev ship $*/

--
--
--
  PROCEDURE insert_row (
                       Address_Id              IN OUT NOCOPY NUMBER,
                       Last_Update_Date               DATE,
                       Last_Updated_By                NUMBER,
                       Creation_Date                  DATE,
                       Created_By                     NUMBER,
                       Status                         VARCHAR2,
                       Orig_System_Reference  IN OUT NOCOPY VARCHAR2,
                       Country                        VARCHAR2,
                       Address1                       VARCHAR2,
                       Address2                       VARCHAR2,
                       Address3                       VARCHAR2,
                       Address4                       VARCHAR2,
                       City                           VARCHAR2,
                       Postal_Code                    VARCHAR2,
                       State                          VARCHAR2,
                       Province                       VARCHAR2,
                       County                         VARCHAR2,
                       Last_Update_Login              NUMBER,
                       Address_Key                    VARCHAR2,
                       Language                       VARCHAR2,
                       Attribute_Category             VARCHAR2,
                       Attribute1                     VARCHAR2,
                       Attribute2                     VARCHAR2,
                       Attribute3                     VARCHAR2,
                       Attribute4                     VARCHAR2,
                       Attribute5                     VARCHAR2,
                       Attribute6                     VARCHAR2,
                       Attribute7                     VARCHAR2,
                       Attribute8                     VARCHAR2,
                       Attribute9                     VARCHAR2,
                       Attribute10                    VARCHAR2,
                       Attribute11                    VARCHAR2,
                       Attribute12                    VARCHAR2,
                       Attribute13                    VARCHAR2,
                       Attribute14                    VARCHAR2,
                       Attribute15                    VARCHAR2,
                       Attribute16                    VARCHAR2,
                       Attribute17                    VARCHAR2,
                       Attribute18                    VARCHAR2,
                       Attribute19                    VARCHAR2,
                       Attribute20                    VARCHAR2,
                       Address_Lines_Phonetic         VARCHAR2,
                       Global_Attribute_Category      VARCHAR2,
                       Global_Attribute1              VARCHAR2,
                       Global_Attribute2              VARCHAR2,
                       Global_Attribute3              VARCHAR2,
                       Global_Attribute4              VARCHAR2,
                       Global_Attribute5              VARCHAR2,
                       Global_Attribute6              VARCHAR2,
                       Global_Attribute7              VARCHAR2,
                       Global_Attribute8              VARCHAR2,
                       Global_Attribute9              VARCHAR2,
                       Global_Attribute10             VARCHAR2,
                       Global_Attribute11             VARCHAR2,
                       Global_Attribute12             VARCHAR2,
                       Global_Attribute13             VARCHAR2,
                       Global_Attribute14             VARCHAR2,
                       Global_Attribute15             VARCHAR2,
                       Global_Attribute16             VARCHAR2,
                       Global_Attribute17             VARCHAR2,
                       Global_Attribute18             VARCHAR2,
                       Global_Attribute19             VARCHAR2,
                       Global_Attribute20             VARCHAR2,
                       Party_site_id             IN OUT  NOCOPY    NUMBER,
                       Party_id                       NUMBER,
                       Location_id               IN OUT    NOCOPY  NUMBER,
                       Party_Site_Number         IN OUT    NOCOPY  VARCHAR2,
                       Identifying_address_flag       VARCHAR2,
                       Cust_acct_site_id    in out         NOCOPY   NUMBER,
                       Cust_account_id                NUMBER,
                       su_Bill_To_Flag                VARCHAR2,
                       su_Ship_To_Flag                VARCHAR2,
                       su_Market_Flag                 VARCHAR2,
                       su_stmt_flag                   VARCHAR2,
                       su_dun_flag                    VARCHAR2,
                       su_legal_flag                  VARCHAR2,
                       Customer_Category              VARCHAR2,
                       Key_Account_Flag               VARCHAR2,
                       Territory_id                   NUMBER,
                       ece_tp_location_code           VARCHAR2,
                       address_mode                   VARCHAR2,
                       territory                      VARCHAR2,
                       translated_customer_name       VARCHAR2,
                       sales_tax_geo_code             VARCHAR2,
                       sale_tax_inside_city_limits    VARCHAR2,
                       shared_party_site          IN  VARCHAR2,
                       update_account_site        IN  VARCHAR2,
                       create_location_party_site IN  VARCHAR2,
                       addressee                      VARCHAR2,
		       org_id			  IN  NUMBER,
                       msg_count                  OUT  NOCOPY NUMBER,
                       msg_data                   OUT NOCOPY VARCHAR2,
                       return_status              OUT NOCOPY VARCHAR2)

 IS

X_Address_warning    boolean;



BEGIN

  fnd_client_info.set_org_context(org_id);

  arh_addr_pkg.insert_row (
		X_Address_Id => Address_Id,
		X_Last_Update_Date => Last_Update_Date,
		X_Last_Updated_By => Last_Updated_By,
		X_Creation_Date => Creation_Date,
		X_Created_By => Created_By,
		X_Status => Status,
		X_Orig_System_Reference => Orig_System_Reference,
		X_Country => Country,
		X_Address1 => Address1,
		X_Address2 => Address2,
		X_Address3 => Address3,
		X_Address4 => Address4,
		X_City => City,
		X_Postal_Code => Postal_Code,
		X_State => State,
		X_Province => Province,
		X_County => County,
		X_Last_Update_Login => Last_Update_Login,
		X_Address_Key => Address_Key,
		X_Language => Language,
		X_Attribute_Category => Attribute_Category,
		X_Attribute1 => Attribute1,
		X_Attribute2 => Attribute2,
		X_Attribute3 => Attribute3,
		X_Attribute4 => Attribute4,
		X_Attribute5 => Attribute5,
		X_Attribute6 => Attribute6,
		X_Attribute7 => Attribute7,
		X_Attribute8 => Attribute8,
		X_Attribute9 => Attribute9,
		X_Attribute10 => Attribute10,
		X_Attribute11 => Attribute11,
		X_Attribute12 => Attribute12,
		X_Attribute13 => Attribute13,
		X_Attribute14 => Attribute14,
		X_Attribute15 => Attribute15,
		X_Attribute16 => Attribute16,
		X_Attribute17 => Attribute17,
		X_Attribute18 => Attribute18,
		X_Attribute19 => Attribute19,
		X_Attribute20 => Attribute20,
		X_Address_warning => X_Address_warning,
		X_Address_Lines_Phonetic => Address_Lines_Phonetic,
		X_Global_Attribute_Category => Global_Attribute_Category,
		X_Global_Attribute1 => Global_Attribute1,
		X_Global_Attribute2 => Global_Attribute2,
		X_Global_Attribute3 => Global_Attribute3,
		X_Global_Attribute4 => Global_Attribute4,
		X_Global_Attribute5 => Global_Attribute5,
		X_Global_Attribute6 => Global_Attribute6,
		X_Global_Attribute7 => Global_Attribute7,
		X_Global_Attribute8 => Global_Attribute8,
		X_Global_Attribute9 => Global_Attribute9,
		X_Global_Attribute10 => Global_Attribute10,
		X_Global_Attribute11 => Global_Attribute11,
		X_Global_Attribute12 => Global_Attribute12,
		X_Global_Attribute13 => Global_Attribute13,
		X_Global_Attribute14 => Global_Attribute14,
		X_Global_Attribute15 => Global_Attribute15,
		X_Global_Attribute16 => Global_Attribute16,
		X_Global_Attribute17 => Global_Attribute17,
		X_Global_Attribute18 => Global_Attribute18,
		X_Global_Attribute19 => Global_Attribute19,
		X_Global_Attribute20 => Global_Attribute20,
		X_Party_site_id => Party_site_id,
		X_Party_id => Party_id,
		X_Location_id => Location_id,
		X_Party_Site_Number => Party_Site_Number,
		X_Identifying_address_flag => Identifying_address_flag,
		X_Cust_acct_site_id => Cust_acct_site_id,
		X_Cust_account_id => Cust_account_id,
		X_su_Bill_To_Flag => su_Bill_To_Flag,
		X_su_Ship_To_Flag => su_Ship_To_Flag,
		X_su_Market_Flag => su_Market_Flag,
		X_su_stmt_flag => su_stmt_flag,
		X_su_dun_flag => su_dun_flag,
		X_su_legal_flag => su_legal_flag,
		X_Customer_Category => Customer_Category,
		X_Key_Account_Flag => Key_Account_Flag,
		X_Territory_id => Territory_id,
		X_ece_tp_location_code => ece_tp_location_code,
		x_address_mode => address_mode,
		x_territory => territory,
		x_translated_customer_name => translated_customer_name,
		x_sales_tax_geo_code => sales_tax_geo_code,
		x_sale_tax_inside_city_limits => sale_tax_inside_city_limits,
		x_ADDRESSEE => addressee,
		x_shared_party_site => shared_party_site,
		x_update_account_site => update_account_site,
		x_create_location_party_site => create_location_party_site,
		x_msg_count => msg_count,
		x_msg_data => msg_data,
		x_return_status => return_status);

  exception
        when others then
                NULL;

  END Insert_Row;

--
END hz_addr_ispeed_pkg;

/
