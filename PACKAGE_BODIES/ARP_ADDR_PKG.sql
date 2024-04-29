--------------------------------------------------------
--  DDL for Package Body ARP_ADDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_ADDR_PKG" as
/* $Header: AROADDRB.pls 120.6.12010000.3 2009/01/09 14:04:24 pbapna ship $ */

/*--------------------------------------------------------------------+
PUBLIC FUNCTION
  format_address

DESCRIPTION
  This function returns a sigle string of concatenated address
  segments. The segments and their display order may vary according
  to a given address format. Line breaks are inserted in order for the
  segments to be allocated inside the given box dimension.

  If the box size is not big enough to contain all the required
  segment together with segment joint characters(spaces/commas),
  or the box width is not long enough to contain any segment,
  then the function truncates the string to provide the possible output.

REQUIRES
  address_style			: address format style
  address1			: address line 1
  address2			: address line 2
  address3			: address line 3
  address4			: address line 4
  city				: name of city
  county			: name of county
  state				: name of state
  province			: name of province
  postal_code			: postal code
  territory_short_name		: territory short name

OPTIONAL REQUIRES
  country_code			: country code
  customer_name			: customer name
  first_name			: contact first name
  last_name			: contact last name
  mail_stop			: mailing informatioin
  default_country_code 		: default country code
  default_country_desc		: default territory short name
  print_home_country_flag	: flag to control home county printing
  print_default_attn_flag	: flag to control default attention message
  width NUMBER			: address box width
  height_min			: address box minimum height
  height_max			: address box maximum height

RETURN
  formatted address string

+--------------------------------------------------------------------*/
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
		        )return VARCHAR2 IS
BEGIN
    return( arxtw_format_address(  address_style,
                                   address1,
                                   address2,
                                   address3,
                                   address4,
                                   city,
                                   county,
                                   state,
                                   province,
                                   postal_code,
                                   territory_short_name ) );

END format_address;



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
                        )return VARCHAR2 IS
    l_address varchar2(2000);         /*bug 7687922.Increased the variable
                                      length*/
BEGIN
   --
   -- ra_addresses.address1 is a NOT NULL field.
   --
   l_address := address1;

   IF ( address2 IS NOT NULL ) THEN
      l_address := l_address || ', ' || address2;
   END IF;

   IF ( address3 IS NOT NULL ) THEN
      l_address := l_address || ', ' || address3;
   END IF;

   IF ( address4 IS NOT NULL ) THEN
      l_address := l_address || ', ' || address4;
   END IF;

   IF ( city IS NOT NULL ) THEN
      l_address := l_address || ', ' || city;
   END IF;

   IF ( county IS NOT NULL ) THEN
      l_address := l_address || ', ' || county;
   END IF;

   IF ( state IS NOT NULL ) THEN
      l_address := l_address || ', ' || state;
   END IF;

   IF ( province IS NOT NULL ) THEN
      l_address := l_address || ', ' || province;
   END IF;

   IF ( postal_code IS NOT NULL ) THEN
      l_address := l_address || ', ' || postal_code;
   END IF;

   IF ( territory_short_name IS NOT NULL ) THEN
      l_address := l_address || ', ' || territory_short_name;
   END IF;

   RETURN( l_address );
END arxtw_format_address;



FUNCTION format_last_address_line(p_address_style  varchar2,
                                  p_address3       varchar2,
                                  p_address4       varchar2,
                                  p_city           varchar2,
                                  p_county         varchar2,
                                  p_state          varchar2,
                                  p_province       varchar2,
                                  p_country        varchar2,
                                  p_postal_code    varchar2 )
                            RETURN varchar2 IS


        l_address varchar2(1000);
BEGIN
        IF ( p_address3  IS NOT NULL )
        THEN
                l_address := p_address3;
	END IF;

        IF ( p_address4  IS NOT NULL )
        THEN
              IF (l_address IS NOT NULL)
              THEN
                    l_address := l_address || ', ' || p_address4;
              ELSE  l_address := p_address4;
              END IF;
        END IF;

        IF ( p_city  IS NOT NULL )
        THEN
              IF (l_address IS NOT NULL)
              THEN
                    l_address := l_address || ', ' || p_city;
              ELSE  l_address := p_city;
              END IF;
        END IF;

        IF ( p_state  IS NOT NULL )
        THEN
              IF (l_address IS NOT NULL)
              THEN
                    l_address := l_address || ', ' || p_state;
              ELSE  l_address := p_state;
              END IF;
        END IF;

        IF ( p_province  IS NOT NULL )
        THEN
              IF (l_address IS NOT NULL)
              THEN
                    l_address := l_address || ', ' || p_province;
              ELSE  l_address := p_province;
              END IF;
        END IF;

        IF ( p_postal_code  IS NOT NULL )
        THEN
              IF (l_address IS NOT NULL)
              THEN
                    l_address := l_address || ' ' || p_postal_code;
              ELSE  l_address := p_postal_code;
              END IF;
        END IF;

        IF ( p_country  IS NOT NULL )
        THEN
              IF (l_address IS NOT NULL)
              THEN
                    l_address := l_address || ' ' || p_country;
              ELSE  l_address := p_country;
              END IF;
        END IF;

        RETURN(l_address);

END format_last_address_line;
--
-- PROCEDURE
--     insert_site_use
--
-- DESCRIPTION
--    This procedure calls arp_csu_pkg.insert_row to create a site use for
--    an address
--
-- SCOPE - PRIVATE
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--			p_address_id -
--			p_site_use_code  - type of site use to create
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
  PROCEDURE insert_site_use(	p_customer_id in number,
			    	p_address_id  in number,
				p_site_use_code in varchar2) is
  --
  l_rowid varchar2(18);
  l_site_use_id number;
  l_location varchar2(40);
  --
  begin
  --
  --Stub out
    NULL;
  end insert_site_use;
--
-- PROCEDURE
--     manage_site_use
--
-- DESCRIPTION
--    This procedure manages the update/creations of site uses
--
-- SCOPE - PRIVATE
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:     p_custoemr_id
--			p_address_id
--			p_site_use_flag	 - Y = create/activate  a site use of this type
--					   N = Inactive a site use ods this type if it exists
--			p_site_use_code  - type of site use
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
  Procedure manage_site_use ( 	p_customer_id   in number,
				p_address_id    in number,
				p_site_use_flag in varchar2,
				p_site_use_code   in varchar2 ) is
begin
	--	Stub out
        NULL;

end manage_site_use;
--
-- PROCEDURE
--     update_site_use_flag
--
-- DESCRIPTION
--    This procedure updates the denormalized site_use flags
--    on address.  It should only be called from arp_csu_pkg.
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--			p_address_id -
--			p_site_use_code  -
--			p_site_use_flag -  Y = Active
--					   P - Active and Primary
--				           null - Inactive
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
procedure update_site_use_flag ( p_address_id    in  number,
				 p_site_use_code in varchar2,
				 p_site_use_flag in varchar2 ) is
--
--
begin
        --
        -- The procedure is only callled if one of the flags requires updating
	-- therfore the if then else logic has been pushed into the sql
	--
	update 	hz_cust_acct_sites
	set	bill_to_flag = decode(p_site_use_code,
				      'BILL_TO',p_site_use_flag,
				    bill_to_flag),
                ship_to_flag = decode(p_site_use_code,
				      'SHIP_TO',p_site_use_flag,
				      ship_to_flag),
		market_flag  = decode(p_site_use_code,
				      'MARKET',p_site_use_flag,
				     market_flag)
	where  cust_acct_site_id = p_address_id;
	--
        if (SQL%NOTFOUND) then
		raise NO_DATA_FOUND;
	end if;
	--
	--
end update_site_use_flag;

--
--
-- PROCEDURE
--     check_unique_orig_system_ref
--
-- DESCRIPTION
-- 	This procedure checks that the orig_system_reference of an address
--  	is unique
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:     p_address_id
--			p_orig_system_reference
--              OUT:
--                    None
--
-- RETURNS    : NONE
--			The system does not allow update of orig_system_reference
--
-- NOTES
--
-- MODIFICATION HISTORY - Created by Kevin Hudson
--
--
procedure check_unique_orig_system_ref(p_orig_system_reference in varchar2) is
--
dummy number;
--
begin
	select 	count(1)
	into   	dummy
	from 	hz_cust_acct_sites addr
	where	addr.orig_system_reference = p_orig_system_reference;
	--
	--
	if ( dummy >=1 ) then
		fnd_message.set_name('AR','AR_CUST_ADDR_REF_EXISTS');
		app_exception.raise_exception;
	end if;
	--

end check_unique_orig_system_ref;
--
--
  PROCEDURE delete_customer_alt_names(p_rowid in varchar2,
                                    p_status in varchar2,
                                    p_customer_id in number,
                                    p_address_id in number ) is
l_status varchar2(1);
l_lock_status number;
l_site_use_id number;
begin
        --
        --Stub out
        NULL;
        --
end delete_customer_alt_names;
--
--
--
  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Address_Id              IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Customer_Id                    NUMBER,
                       X_Status                         VARCHAR2,
                       X_Orig_System_Reference   IN OUT NOCOPY VARCHAR2,
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
		       x_address_warning	out nocopy	boolean,
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
  ) IS

   BEGIN
       --Stub out
        NULL;
  END Insert_Row;


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
  ) IS
  BEGIN
--Stub out
   NULL;
  END Lock_Row;



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
		       x_address_warning	out nocopy	boolean,
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
  ) IS
  --
  --
  BEGIN
  --Stub out
  NULL;

  END Update_Row;
--
-----------------------------------------------------------------------------
-- If a location_id is populated for an address record, it means the setup
-- for tax is of type Sales Tax
-----------------------------------------------------------------------------
--
FUNCTION location_exists (p_address_id  IN Number
                         ) return BOOLEAN is
--
  location_identifier number;
--
BEGIN
 --Stub out
    RETURN (FALSE);
--
END location_exists;
--
---------------------------------------------------------------------------------------
-- Receivable will not let you modify a customer address if:
--
-- (a) You have disabled: "Allow Change to Printed Transactions" (In AR System Options)
--     Note: Using this option, you protect the invoice from direct and indirect changes
--
--  AND
--
-- (b) At least one PRINTED OR POSTED OR APPLIED transaction exists for this bill-to
--     or ship-to site in Receivables and that transaction has Tax lines (Automatic
--     or Manually entered).
--     Reason: manual tax lines are audited in the same way that automatic tax lines
--     are
---------------------------------------------------------------------------------------
--
FUNCTION transaction_exists (p_address_id  IN number,
                             p_customer_id IN number)
         return BOOLEAN is
--
BEGIN
--Stub out
    RETURN (FALSE);
END transaction_exists;
--
----------------------------------------------------------------------------------
-- The procedure is called from insert_row/update_row. A check is made for the
-- existance of edi location for all the addresses of the customer. The business
	-- rule is, "THE EDI LOCATION SHOULD BE UNIQUE FOR A CUSTOMER". Insert and Update
	-- are rejected with an error message if a duplicate is provided. Release-11
	-- change for EDI.
	----------------------------------------------------------------------------------
	--
	procedure check_unique_edi_location(p_edi_location          in varchar2,
					    p_customer_id           in number,
					    p_orig_system_reference in varchar2) is
	dummy number;
	--
	begin
           -- Stub out
           NULL;
	end check_unique_edi_location;
	--

	END arp_addr_pkg;

/
