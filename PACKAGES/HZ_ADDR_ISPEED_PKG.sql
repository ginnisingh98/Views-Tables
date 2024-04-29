--------------------------------------------------------
--  DDL for Package HZ_ADDR_ISPEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ADDR_ISPEED_PKG" AUTHID CURRENT_USER as
/* $Header: ARHADISS.pls 120.2 2005/06/16 21:08:30 jhuang ship $*/
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
                       Orig_System_Reference  IN OUT  NOCOPY VARCHAR2,
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
                       Party_site_id             IN OUT     NOCOPY NUMBER,
                       Party_id                       NUMBER,
                       Location_id               IN OUT     NOCOPY NUMBER,
                       Party_Site_Number         IN OUT     NOCOPY VARCHAR2,
                       Identifying_address_flag       VARCHAR2,
                       Cust_acct_site_id   in out            NOCOPY NUMBER,
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
                       msg_count                  OUT NOCOPY NUMBER,
                       msg_data                   OUT NOCOPY VARCHAR2,
                       return_status              OUT NOCOPY VARCHAR2);

/*

--
 PROCEDURE update_row (
                       Address_Id                     NUMBER,
                       Last_Update_Date        in out       NOCOPY DATE,
                       party_site_Last_Update_Date        in out        NOCOPY DATE,
                       loc_Last_Update_Date        in out        NOCOPY DATE,
                       Last_Updated_By                NUMBER,
                       Status                         VARCHAR2,
                       Orig_System_Reference          VARCHAR2,
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
                       Party_site_id                  NUMBER,
                       Party_id                       NUMBER,
                       Location_id                    NUMBER,
                       Party_Site_Number              VARCHAR2,
                       Identifying_address_flag       VARCHAR2,
                       Cust_acct_site_id              NUMBER,
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
                       Territory                      VARCHAR2,
                       Translated_Customer_Name       VARCHAR2,
                       Sales_Tax_Geocode              VARCHAR2,
                       Sales_Tax_Inside_City_Limits   VARCHAR2,
                       addressee                      VARCHAR2,
                       msg_count                  OUT NOCOPY NUMBER,
                       msg_data                   OUT NOCOPY VARCHAR2,
                       return_status              OUT NOCOPY VARCHAR2);

*/

END hz_addr_ispeed_pkg;

 

/