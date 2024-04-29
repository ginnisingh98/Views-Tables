--------------------------------------------------------
--  DDL for Package ARP_ADDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_ADDR_PKG" AUTHID CURRENT_USER as
/* $Header: AROADDRS.pls 115.4 99/10/11 16:15:21 porting sh $ */
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
  --
  --
  procedure update_site_use_flag ( p_address_id    in  number,
				 p_site_use_code in varchar2,
				 p_site_use_flag in varchar2 );
  --
  --
  PROCEDURE Insert_Row(X_Rowid                   IN OUT VARCHAR2,
                       X_Address_Id              IN OUT NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Customer_Id                    NUMBER,
                       X_Status                         VARCHAR2,
                       X_Orig_System_Reference  IN OUT  VARCHAR2,
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
                       X_Territory_Id                   NUMBER,
                       X_Address_Key                    VARCHAR2,
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
                       X_Key_Account_Flag               VARCHAR2,
                       X_Language                       VARCHAR2,
		       X_address_mode			VARCHAR2,
                       X_su_Bill_To_Flag                VARCHAR2,
                       X_su_Ship_To_Flag                VARCHAR2,
                       X_su_Market_Flag                 VARCHAR2,
		       X_su_stmt_flag			VARCHAR2,
		       X_su_dun_flag			VARCHAR2,
		       X_su_legal_flag			VARCHAR2,
		       X_Address_warning	out	boolean,
                       X_Address_Lines_Phonetic         VARCHAR2,
                       X_Customer_Category              VARCHAR2,
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
                       X_EDI_Location                   VARCHAR2,
                       X_Territory                      VARCHAR2,
                       X_Translated_Customer_Name       VARCHAR2,
                       X_Sales_Tax_Geocode              VARCHAR2,
                       X_Sales_Tax_Inside_City_Limits   VARCHAR2
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Address_Id                       NUMBER,
                     X_Customer_Id                      NUMBER,
                     X_Status                           VARCHAR2,
                     X_Orig_System_Reference            VARCHAR2,
                     X_Country                          VARCHAR2,
                     X_Address1                         VARCHAR2,
                     X_Address2                         VARCHAR2,
                     X_Address3                         VARCHAR2,
                     X_Address4                         VARCHAR2,
                     X_City                             VARCHAR2,
                     X_Postal_Code                      VARCHAR2,
                     X_State                            VARCHAR2,
                     X_Province                         VARCHAR2,
                     X_County                           VARCHAR2,
                     X_Territory_Id                     NUMBER,
                     X_Address_Key                      VARCHAR2,
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
                     X_Key_Account_Flag                 VARCHAR2,
                     X_Language                         VARCHAR2,
                     X_su_Bill_To_Flag                  VARCHAR2,
                     X_su_Ship_To_Flag                  VARCHAR2,
                     X_su_Market_Flag                   VARCHAR2,
		     X_su_stmt_flag			VARCHAR2,
		     X_su_dun_flag			VARCHAR2,
		     X_su_legal_flag			VARCHAR2,
                     X_Address_Lines_Phonetic           VARCHAR2,
                     X_Customer_Category                VARCHAR2,
                     X_Global_Attribute_Category        VARCHAR2,
                     X_Global_Attribute1                VARCHAR2,
                     X_Global_Attribute2                VARCHAR2,
                     X_Global_Attribute3                VARCHAR2,
                     X_Global_Attribute4                VARCHAR2,
                     X_Global_Attribute5                VARCHAR2,
                     X_Global_Attribute6                VARCHAR2,
                     X_Global_Attribute7                VARCHAR2,
                     X_Global_Attribute8                VARCHAR2,
                     X_Global_Attribute9                VARCHAR2,
                     X_Global_Attribute10               VARCHAR2,
                     X_Global_Attribute11               VARCHAR2,
                     X_Global_Attribute12               VARCHAR2,
                     X_Global_Attribute13               VARCHAR2,
                     X_Global_Attribute14               VARCHAR2,
                     X_Global_Attribute15               VARCHAR2,
                     X_Global_Attribute16               VARCHAR2,
                     X_Global_Attribute17               VARCHAR2,
                     X_Global_Attribute18               VARCHAR2,
                     X_Global_Attribute19               VARCHAR2,
                     X_Global_Attribute20               VARCHAR2,
                     X_EDI_Location                     VARCHAR2,
                     X_Territory                        VARCHAR2,
                     X_Translated_Customer_Name         VARCHAR2,
                     X_Sales_Tax_Geocode                VARCHAR2,
                     X_Sales_Tax_Inside_City_Limits     VARCHAR2
		    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Address_Id                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Customer_Id                    NUMBER,
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
                       X_Territory_Id                   NUMBER,
                       X_Address_Key                    VARCHAR2,
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
                       X_Key_Account_Flag               VARCHAR2,
                       X_Language                       VARCHAR2,
		       x_address_mode			VARCHAR2,
                       X_su_Bill_To_Flag                VARCHAR2,
                       X_su_Ship_To_Flag                VARCHAR2,
                       X_su_Market_Flag                 VARCHAR2,
		       X_su_stmt_flag			VARCHAR2,
		       X_su_dun_flag			VARCHAR2,
		       X_su_legal_flag			VARCHAR2,
		       X_address_warning	out	boolean,
                       X_Address_Lines_Phonetic         VARCHAR2,
                       X_Customer_Category              VARCHAR2,
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
                       X_EDI_Location                   VARCHAR2,
                       X_Territory                      VARCHAR2,
                       X_Translated_Customer_Name       VARCHAR2,
                       X_Sales_Tax_Geocode              VARCHAR2,
                       X_Sales_Tax_Inside_City_Limits   VARCHAR2
                      );
--
FUNCTION location_exists (p_address_id  IN Number
                         ) return BOOLEAN;
--
--
FUNCTION transaction_exists (p_address_id  IN Number,
                             p_customer_id IN Number
                            ) return BOOLEAN;
--
--
procedure check_unique_edi_location(p_edi_location          in varchar2,
                                    p_customer_id           in number,
                                    p_orig_system_reference in varchar2);
--
END arp_addr_pkg;

 

/
