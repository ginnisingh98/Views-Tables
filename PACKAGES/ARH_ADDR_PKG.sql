--------------------------------------------------------
--  DDL for Package ARH_ADDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARH_ADDR_PKG" AUTHID CURRENT_USER as
/* $Header: ARHADDRS.pls 120.8 2005/06/24 18:11:40 apandit ship $*/
  --
  --
  FUNCTION format_address( address_style IN VARCHAR2,
  			   address1 IN VARCHAR2,
			   address2 IN VARCHAR2,
			   address3 IN VARCHAR2,
			   address4 IN VARCHAR2,
			   city IN VARCHAR2,
			   county IN VARCHAR2,
			   state IN VARCHAR2,
			   province IN VARCHAR2,
			   postal_code IN VARCHAR2,
			   territory_short_name IN VARCHAR2,
  			   country_code IN VARCHAR2 default NULL,
			   customer_name IN VARCHAR2 default NULL,
			   first_name IN VARCHAR2 default NULL,
			   last_name IN VARCHAR2 default NULL,
			   mail_stop IN VARCHAR2 default NULL,
			   default_country_code IN VARCHAR2 default NULL,
                     default_country_desc IN VARCHAR2 default NULL,
                     print_home_country_flag IN VARCHAR2 default 'Y',
  			   print_default_attn_flag IN VARCHAR2 default 'N',
			   width IN NUMBER default 1000,
			   height_min IN NUMBER default 1,
			   height_max IN NUMBER default 1

		        )return VARCHAR2;


  FUNCTION arxtw_format_address( address_style IN VARCHAR2,
  			   address1 IN VARCHAR2,
			   address2 IN VARCHAR2,
			   address3 IN VARCHAR2,
			   address4 IN VARCHAR2,
			   city IN VARCHAR2,
			   county IN VARCHAR2,
			   state IN VARCHAR2,
			   province IN VARCHAR2,
			   postal_code IN VARCHAR2,
			   territory_short_name IN VARCHAR2
		        )return VARCHAR2;


  FUNCTION format_last_address_line(p_address_style  varchar2,
                                    p_address3       varchar2,
                                    p_address4       varchar2,
                                    p_city           varchar2,
                                    p_county         varchar2,
                                    p_state          varchar2,
                                    p_province       varchar2,
                                    p_country        varchar2,
                                    p_postal_code    varchar2 )
                              RETURN varchar2;



  procedure check_unique_orig_system_ref(p_orig_system_reference in varchar2 );
  procedure identifying_address_flag(x_party_id in number );
  --
  --
  procedure update_site_use_flag ( p_address_id    in  number,
				 p_site_use_code in varchar2,
				 p_site_use_flag in varchar2 );
  --
  --
  PROCEDURE insert_row (
                       X_Address_Id              IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Status                         VARCHAR2,
                       X_Orig_System_Reference  IN OUT  NOCOPY VARCHAR2,
                       X_Country                        VARCHAR2,
                       X_Address1                       VARCHAR2,
                       X_Address2                       VARCHAR2,
                       X_Address3                       VARCHAR2,
                       X_Address4                       VARCHAR2,
                       X_City                           VARCHAR2,
                       X_Postal_Code                    VARCHAR2,
                       X_State                          VARCHAR2,
                       X_Province                       VARCHAR2,
                       X_County                         VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Address_Key                    VARCHAR2,
                       X_Language                       VARCHAR2,
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
		       X_Address_warning	out	NOCOPY boolean,
                       X_Address_Lines_Phonetic         VARCHAR2,
                       X_Global_Attribute_Category      VARCHAR2,
                       X_Global_Attribute1              VARCHAR2,
                       X_Global_Attribute2              VARCHAR2,
                       X_Global_Attribute3              VARCHAR2,
                       X_Global_Attribute4              VARCHAR2,
                       X_Global_Attribute5              VARCHAR2,
                       X_Global_Attribute6              VARCHAR2,
                       X_Global_Attribute7              VARCHAR2,
                       X_Global_Attribute8              VARCHAR2,
                       X_Global_Attribute9              VARCHAR2,
                       X_Global_Attribute10             VARCHAR2,
                       X_Global_Attribute11             VARCHAR2,
                       X_Global_Attribute12             VARCHAR2,
                       X_Global_Attribute13             VARCHAR2,
                       X_Global_Attribute14             VARCHAR2,
                       X_Global_Attribute15             VARCHAR2,
                       X_Global_Attribute16             VARCHAR2,
                       X_Global_Attribute17             VARCHAR2,
                       X_Global_Attribute18             VARCHAR2,
                       X_Global_Attribute19             VARCHAR2,
                       X_Global_Attribute20             VARCHAR2,
                       X_Party_site_id             IN OUT     NOCOPY NUMBER,
                       X_Party_id                       NUMBER,
                       X_Location_id               IN OUT     NOCOPY NUMBER,
                       X_Party_Site_Number         IN OUT     NOCOPY VARCHAR2,
                       X_Identifying_address_flag       VARCHAR2,
                       X_Cust_acct_site_id   in out            NOCOPY NUMBER,
                       X_Cust_account_id                NUMBER,
                       X_su_Bill_To_Flag                VARCHAR2,
                       X_su_Ship_To_Flag                VARCHAR2,
                       X_su_Market_Flag                 VARCHAR2,
                       X_su_stmt_flag                   VARCHAR2,
                       X_su_dun_flag                    VARCHAR2,
                       X_su_legal_flag                  VARCHAR2,
                       X_Customer_Category              VARCHAR2,
                       X_Key_Account_Flag               VARCHAR2,
                       X_Territory_id                   NUMBER,
                       X_ece_tp_location_code           VARCHAR2,
                       x_address_mode                   VARCHAR2,
                       x_territory                      VARCHAR2,
                       x_translated_customer_name       VARCHAR2,
                       x_sales_tax_geo_code             VARCHAR2,
                       x_sale_tax_inside_city_limits    VARCHAR2,
                       x_ADDRESSEE                      VARCHAR2,
                       x_shared_party_site          IN  VARCHAR2,
                       x_update_account_site        IN  VARCHAR2,
                       x_create_location_party_site IN  VARCHAR2,
                       x_msg_count                  OUT NOCOPY NUMBER,
                       x_msg_data                   OUT NOCOPY VARCHAR2,
                       x_return_status              OUT NOCOPY VARCHAR2,
--Bug#2689667 {
                       x_description                IN  VARCHAR2 DEFAULT NULL,
                       x_short_description          IN  VARCHAR2 DEFAULT NULL,
                       x_floor                      IN  VARCHAR2 DEFAULT NULL,
                       x_house_number               IN  VARCHAR2 DEFAULT NULL,
                       x_location_directions        IN  VARCHAR2 DEFAULT NULL,
                       x_postal_plus4_code          IN  VARCHAR2 DEFAULT NULL,
                       x_po_box_number              IN  VARCHAR2 DEFAULT NULL,
                       x_street                     IN  VARCHAR2 DEFAULT NULL,
                       x_street_number              IN  VARCHAR2 DEFAULT NULL,
                       x_street_suffix              IN  VARCHAR2 DEFAULT NULL,
                       x_suite                      IN  VARCHAR2 DEFAULT NULL,
--}
/*Bug 3976386 MOAC changes*/
                       X_ORG_ID                     IN  NUMBER DEFAULT NULL

);



--
FUNCTION location_exists (p_address_id  IN Number
                         ) return BOOLEAN;
--
--
FUNCTION transaction_exists (p_address_id  IN Number,
                             p_customer_id IN Number
                            ) return BOOLEAN;

FUNCTION transaction_morg_exists (p_address_id  IN Number,
                                  p_customer_id IN Number
                                 ) return BOOLEAN;

FUNCTION check_tran_for_all_accts(p_location_id in number) return BOOLEAN;
--
--
procedure check_unique_edi_location(p_edi_location          in varchar2,
                                    p_customer_id           in number,
                                    p_orig_system_reference in varchar2);



  PROCEDURE delete_customer_alt_names(p_rowid in varchar2,
                                    p_status in varchar2,
                                    p_customer_id in number,
                                    p_address_id in number );
--

  PROCEDURE update_row (
                       X_Address_Id                     NUMBER,
                       X_Last_Update_Date            IN OUT NOCOPY DATE,
                       X_party_site_Last_Update_Date IN OUT NOCOPY DATE,
                       X_loc_Last_Update_Date        IN OUT NOCOPY DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Status                         VARCHAR2,
                       X_Orig_System_Reference          VARCHAR2,
                       X_Country                        VARCHAR2,
                       X_Address1                       VARCHAR2,
                       X_Address2                       VARCHAR2,
                       X_Address3                       VARCHAR2,
                       X_Address4                       VARCHAR2,
                       X_City                           VARCHAR2,
                       X_Postal_Code                    VARCHAR2,
                       X_State                          VARCHAR2,
                       X_Province                       VARCHAR2,
                       X_County                         VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Address_Key                    VARCHAR2,
                       X_Language                       VARCHAR2,
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
                       X_Address_warning          OUT   NOCOPY BOOLEAN,
                       X_Address_Lines_Phonetic         VARCHAR2,
                       X_Global_Attribute_Category      VARCHAR2,
                       X_Global_Attribute1              VARCHAR2,
                       X_Global_Attribute2              VARCHAR2,
                       X_Global_Attribute3              VARCHAR2,
                       X_Global_Attribute4              VARCHAR2,
                       X_Global_Attribute5              VARCHAR2,
                       X_Global_Attribute6              VARCHAR2,
                       X_Global_Attribute7              VARCHAR2,
                       X_Global_Attribute8              VARCHAR2,
                       X_Global_Attribute9              VARCHAR2,
                       X_Global_Attribute10             VARCHAR2,
                       X_Global_Attribute11             VARCHAR2,
                       X_Global_Attribute12             VARCHAR2,
                       X_Global_Attribute13             VARCHAR2,
                       X_Global_Attribute14             VARCHAR2,
                       X_Global_Attribute15             VARCHAR2,
                       X_Global_Attribute16             VARCHAR2,
                       X_Global_Attribute17             VARCHAR2,
                       X_Global_Attribute18             VARCHAR2,
                       X_Global_Attribute19             VARCHAR2,
                       X_Global_Attribute20             VARCHAR2,
                       X_Party_site_id                  NUMBER,
                       X_Party_id                       NUMBER,
                       X_Location_id                    NUMBER,
                       X_Party_Site_Number              VARCHAR2,
                       X_Identifying_address_flag       VARCHAR2,
                       X_Cust_acct_site_id              NUMBER,
                       X_Cust_account_id                NUMBER,
                       X_su_Bill_To_Flag                VARCHAR2,
                       X_su_Ship_To_Flag                VARCHAR2,
                       X_su_Market_Flag                 VARCHAR2,
                       X_su_stmt_flag                   VARCHAR2,
                       X_su_dun_flag                    VARCHAR2,
                       X_su_legal_flag                  VARCHAR2,
                       X_Customer_Category              VARCHAR2,
                       X_Key_Account_Flag               VARCHAR2,
                       X_Territory_id                   NUMBER,
                       X_ece_tp_location_code           VARCHAR2,
                       x_address_mode                   VARCHAR2,
                       X_Territory                      VARCHAR2,
                       X_Translated_Customer_Name       VARCHAR2,
                       X_Sales_Tax_Geocode              VARCHAR2,
                       X_Sales_Tax_Inside_City_Limits   VARCHAR2,
                       x_ADDRESSEE                      VARCHAR2,
                       x_msg_count                  OUT NOCOPY NUMBER,
                       x_msg_data                   OUT NOCOPY VARCHAR2,
                       x_return_status              OUT NOCOPY VARCHAR2,
                       x_object_version             IN  NUMBER DEFAULT -1,
                       x_object_version_party_site  IN  NUMBER DEFAULT -1,
                       x_object_version_location    IN  NUMBER DEFAULT -1,
--Bug#2689667 {
                       x_description                IN  VARCHAR2 DEFAULT NULL,
                       x_short_description          IN  VARCHAR2 DEFAULT NULL,
                       x_floor                      IN  VARCHAR2 DEFAULT NULL,
                       x_house_number               IN  VARCHAR2 DEFAULT NULL,
                       x_location_directions        IN  VARCHAR2 DEFAULT NULL,
                       x_postal_plus4_code          IN  VARCHAR2 DEFAULT NULL,
                       x_po_box_number              IN  VARCHAR2 DEFAULT NULL,
                       x_street                     IN  VARCHAR2 DEFAULT NULL,
                       x_street_number              IN  VARCHAR2 DEFAULT NULL,
                       x_street_suffix              IN  VARCHAR2 DEFAULT NULL,
                       x_suite                      IN  VARCHAR2 DEFAULT NULL,

--}
/*Bug 3976386 MOAC changes*/
                       X_ORG_ID                     IN NUMBER DEFAULT NULL
);

--{BUG#4058539
PROCEDURE get_location_data
(p_location_id              IN NUMBER,
 x_Country                  IN OUT NOCOPY  VARCHAR2,
 x_Address1                 IN OUT NOCOPY  VARCHAR2,
 x_Address2                 IN OUT NOCOPY  VARCHAR2,
 x_Address3                 IN OUT NOCOPY  VARCHAR2,
 x_Address4                 IN OUT NOCOPY  VARCHAR2,
 x_City                     IN OUT NOCOPY  VARCHAR2,
 x_Postal_Code              IN OUT NOCOPY  VARCHAR2,
 x_State                    IN OUT NOCOPY  VARCHAR2,
 x_Province                 IN OUT NOCOPY  VARCHAR2,
 x_County                   IN OUT NOCOPY  VARCHAR2,
 x_description              IN OUT NOCOPY  VARCHAR2,
 x_short_description        IN OUT NOCOPY  VARCHAR2,
 x_floor                    IN OUT NOCOPY  VARCHAR2,
 x_house_number             IN OUT NOCOPY  VARCHAR2,
 x_location_directions      IN OUT NOCOPY  VARCHAR2,
 x_postal_plus4_code        IN OUT NOCOPY  VARCHAR2,
 x_po_box_number            IN OUT NOCOPY  VARCHAR2,
 x_street                   IN OUT NOCOPY  VARCHAR2,
 x_street_number            IN OUT NOCOPY  VARCHAR2,
 x_street_suffix            IN OUT NOCOPY  VARCHAR2,
 x_suite                    IN OUT NOCOPY  VARCHAR2,
 x_Address_Key              IN OUT NOCOPY  VARCHAR2,
 x_Language                 IN OUT NOCOPY  VARCHAR2,
 x_Address_Lines_Phonetic   IN OUT NOCOPY  VARCHAR2,
 x_Sales_Tax_Geocode        IN OUT NOCOPY  VARCHAR2,
 x_Sales_Tax_Inside_City_Limits   IN OUT NOCOPY  VARCHAR2,
 --
 x_return_status IN OUT NOCOPY  VARCHAR2,
 x_msg_data      IN OUT NOCOPY  VARCHAR2,
 x_msg_count     IN OUT NOCOPY  NUMBER);

--
-- This procedure compare_location_existing overloaded
--   return x_loc_updated
--     'Y' if the location data is different to the existing one
--     'N' if the location data is the same as to the existing one
--     'X' if the p_location_id is no hitting any existing location
--   In the case of
--     x_loc_updated = 'Y', all the x_<attribute_name> will return the existing data
--     otherwise they stay the same as inputs
--
PROCEDURE compare_location_existing
(p_location_id              IN NUMBER,
 x_Country                  IN OUT NOCOPY  VARCHAR2,
 x_Address1                 IN OUT NOCOPY  VARCHAR2,
 x_Address2                 IN OUT NOCOPY  VARCHAR2,
 x_Address3                 IN OUT NOCOPY  VARCHAR2,
 x_Address4                 IN OUT NOCOPY  VARCHAR2,
 x_City                     IN OUT NOCOPY  VARCHAR2,
 x_Postal_Code              IN OUT NOCOPY  VARCHAR2,
 x_State                    IN OUT NOCOPY  VARCHAR2,
 x_Province                 IN OUT NOCOPY  VARCHAR2,
 x_County                   IN OUT NOCOPY  VARCHAR2,
 x_description              IN OUT NOCOPY  VARCHAR2,
 x_short_description        IN OUT NOCOPY  VARCHAR2,
 x_floor                    IN OUT NOCOPY  VARCHAR2,
 x_house_number             IN OUT NOCOPY  VARCHAR2,
 x_location_directions      IN OUT NOCOPY  VARCHAR2,
 x_postal_plus4_code        IN OUT NOCOPY  VARCHAR2,
 x_po_box_number            IN OUT NOCOPY  VARCHAR2,
 x_street                   IN OUT NOCOPY  VARCHAR2,
 x_street_number            IN OUT NOCOPY  VARCHAR2,
 x_street_suffix            IN OUT NOCOPY  VARCHAR2,
 x_suite                    IN OUT NOCOPY  VARCHAR2,
 x_Language                 IN OUT NOCOPY  VARCHAR2,
 x_Address_Lines_Phonetic   IN OUT NOCOPY  VARCHAR2,
 x_Sales_Tax_Geocode        IN OUT NOCOPY  VARCHAR2,
 x_Sales_Tax_Inside_City_Limits   IN OUT NOCOPY  VARCHAR2,
 x_loc_updated              IN OUT  NOCOPY VARCHAR2);
--}

-- This is a overloaded procedure for check_printed_trx
-- bug#4058539
-- this procedure check_printed_trx
-- Return in the input parameters the existing location data if location exist
-- Return in the x_printed_trx_loc_modified
--      * FALSE : No violation to transaction about the printed invoice on location update
--      * TRUE  : Violation to transaction about the printed invoice on location update
-- The x_return_status is set to error only other error are detected
--
PROCEDURE check_printed_trx
(p_location_id              IN NUMBER,
 x_Country                  IN OUT NOCOPY  VARCHAR2,
 x_Address1                 IN OUT NOCOPY  VARCHAR2,
 x_Address2                 IN OUT NOCOPY  VARCHAR2,
 x_Address3                 IN OUT NOCOPY  VARCHAR2,
 x_Address4                 IN OUT NOCOPY  VARCHAR2,
 x_City                     IN OUT NOCOPY  VARCHAR2,
 x_Postal_Code              IN OUT NOCOPY  VARCHAR2,
 x_State                    IN OUT NOCOPY  VARCHAR2,
 x_Province                 IN OUT NOCOPY  VARCHAR2,
 x_County                   IN OUT NOCOPY  VARCHAR2,
 x_description              IN OUT NOCOPY  VARCHAR2,
 x_short_description        IN OUT NOCOPY  VARCHAR2,
 x_floor                    IN OUT NOCOPY  VARCHAR2,
 x_house_number             IN OUT NOCOPY  VARCHAR2,
 x_location_directions      IN OUT NOCOPY  VARCHAR2,
 x_postal_plus4_code        IN OUT NOCOPY  VARCHAR2,
 x_po_box_number            IN OUT NOCOPY  VARCHAR2,
 x_street                   IN OUT NOCOPY  VARCHAR2,
 x_street_number            IN OUT NOCOPY  VARCHAR2,
 x_street_suffix            IN OUT NOCOPY  VARCHAR2,
 x_suite                    IN OUT NOCOPY  VARCHAR2,
 x_Language                 IN OUT NOCOPY  VARCHAR2,
 x_Address_Lines_Phonetic   IN OUT NOCOPY  VARCHAR2,
 x_Sales_Tax_Geocode        IN OUT NOCOPY  VARCHAR2,
 x_Sales_Tax_Inside_City_Limits   IN OUT NOCOPY  VARCHAR2,
 --
 x_printed_trx_loc_modified  IN OUT    NOCOPY VARCHAR2,
 x_return_status             IN OUT NOCOPY  VARCHAR2,
 x_msg_data                  IN OUT NOCOPY  VARCHAR2,
 x_msg_count                 IN OUT NOCOPY  NUMBER);

PROCEDURE check_addr_modif_allowed
(p_location_id               IN NUMBER,
 x_loc_modif_allowed         IN OUT NOCOPY  VARCHAR2,
 x_return_status             IN OUT NOCOPY  VARCHAR2,
 x_msg_data                  IN OUT NOCOPY  VARCHAR2,
 x_msg_count                 IN OUT NOCOPY  NUMBER);

FUNCTION the_ar_miss_char RETURN VARCHAR2;

FUNCTION the_ar_null_char RETURN VARCHAR2;
--}

END arh_addr_pkg;

 

/
