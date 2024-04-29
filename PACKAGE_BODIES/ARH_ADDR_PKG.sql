--------------------------------------------------------
--  DDL for Package Body ARH_ADDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARH_ADDR_PKG" as
/* $Header: ARHADDRB.pls 120.20.12000000.2 2007/07/03 11:38:13 nemani ship $*/

-- Local specification

--{BUG#4037614
----------------------------
-- This procedure if the updation of a physical location is not allowed
--  and the location has been updated.
--  -> system option setting
--  -> the data of location really updated
--  -> transaction has been printed with this location
----------------------------
PROCEDURE check_printed_trx
(p_location_id   IN NUMBER,
 p_location_rec  IN hz_location_v2pub.location_rec_type,
 x_return_status IN OUT NOCOPY  VARCHAR2,
 x_msg_data      IN OUT NOCOPY  VARCHAR2,
 x_msg_count     IN OUT NOCOPY  NUMBER);
--}

--{BUG#4058639
-- Take the location_id to return
--    the existing location data in x_exist_loc_rec
--    if the location does not exist x_exist_loc_rec is empty record
-- x_loc_updated
--    return 'Y' if the data in p_location_rec is different to the existing location
--    return 'N' if the data in p_location_rec is equal to the existing location
--    return 'X' if the no existing location found
PROCEDURE compare_location_existing
(p_location_id   IN  NUMBER,
 p_location_rec  IN  hz_location_v2pub.location_rec_type,
 x_exist_loc_rec IN OUT NOCOPY hz_location_v2pub.location_rec_type,
 x_loc_updated   IN OUT NOCOPY VARCHAR2);

ar_miss_char  VARCHAR2(1) := '}';

ar_null_char  VARCHAR2(1) := '{';
--}
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
			 default_country_code IN VARCHAR2,
                         default_country_desc IN VARCHAR2,
                         print_home_country_flag IN VARCHAR2,
                         print_default_attn_flag IN VARCHAR2,
			 width IN NUMBER,
			 height_min IN NUMBER,
			 height_max IN NUMBER
		        )return VARCHAR2 IS

    l_fmt_bkwd_compatible    VARCHAR2(10) :='Y';
    l_formatted_address      VARCHAR2(2000);
    l_formatted_lines_cnt    NUMBER;
    l_formatted_address_tbl  hz_format_pub.string_tbl_type;
    l_return_status	     VARCHAR2(1);
    l_msg_count	             NUMBER;
    l_msg_data               VARCHAR2(2000);

BEGIN

    l_fmt_bkwd_compatible := FND_PROFILE.VALUE('HZ_FMT_BKWD_COMPATIBLE');
    IF l_fmt_bkwd_compatible = 'Y' THEN
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
    ELSE

        hz_format_pub.format_address (
            p_line_break		=> ', ',
            p_from_territory_code	=> 'x',   -- force country short name be displayed
            p_address_line_1		=> address1,
            p_address_line_2		=> address2,
            p_address_line_3		=> address3,
            p_address_line_4		=> address4,
            p_city			=> city,
            p_postal_code		=> postal_code,
            p_state			=> state,
            p_province			=> province,
            p_county			=> county,
            p_country			=> country_code,
            -- output parameters
            x_return_status		=> l_return_status,
            x_msg_count			=> l_msg_count,
            x_msg_data			=> l_msg_data,
            x_formatted_address		=> l_formatted_address,
            x_formatted_lines_cnt	=> l_formatted_lines_cnt,
            x_formatted_address_tbl	=> l_formatted_address_tbl
          );

        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
           return l_formatted_address;
        ELSE
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
        END IF;
   END IF;


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
    l_address varchar2(1000);
BEGIN
   --
   -- ra addresses.address1 is a NOT NULL field.
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
--
FUNCTION INIT_SWITCH
( p_date   IN DATE,
  p_switch IN VARCHAR2 DEFAULT 'NULL_GMISS')
RETURN DATE
IS
 res_date date;
BEGIN
 IF    p_switch = 'NULL_GMISS' THEN
   IF p_date IS NULL THEN
     res_date := FND_API.G_MISS_DATE;
   ELSE
     res_date := p_date;
   END IF;
 ELSIF p_switch = 'GMISS_NULL' THEN
   IF p_date = FND_API.G_MISS_DATE THEN
     res_date := NULL;
   ELSE
     res_date := p_date;
   END IF;
 ELSE
   res_date := TO_DATE('31/12/1800','DD/MM/RRRR');
 END IF;
 RETURN res_date;
END;

FUNCTION INIT_SWITCH
( p_char   IN VARCHAR2,
  p_switch IN VARCHAR2 DEFAULT 'NULL_GMISS')
RETURN VARCHAR2
IS
 res_char varchar2(2000);
BEGIN
 IF    p_switch = 'NULL_GMISS' THEN
   IF p_char IS NULL THEN
     return FND_API.G_MISS_CHAR;
   ELSE
     return p_char;
   END IF;
 ELSIF p_switch = 'GMISS_NULL' THEN
   IF p_char = FND_API.G_MISS_CHAR THEN
     return NULL;
   ELSE
     return p_char;
   END IF;
 ELSE
   return ('INCORRECT_P_SWITCH');
 END IF;
END;

FUNCTION INIT_SWITCH
( p_num   IN NUMBER,
  p_switch IN VARCHAR2 DEFAULT 'NULL_GMISS')
RETURN NUMBER
IS
 BEGIN
 IF    p_switch = 'NULL_GMISS' THEN
   IF p_num IS NULL THEN
     return FND_API.G_MISS_NUM;
   ELSE
     return p_num;
   END IF;
 ELSIF p_switch = 'GMISS_NULL' THEN
   IF p_num = FND_API.G_MISS_NUM THEN
     return NULL;
   ELSE
     return p_num;
   END IF;
 ELSE
   return ('9999999999');
 END IF;
END;
--
-- PROCEDURE
--     insert_site_use
--
-- DESCRIPTION
--    This procedure calls arh_csu_pkg.insert_row to create a site use for
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
PROCEDURE insert_site_use(    p_customer_id   in  number,
			            p_address_id    in  number,
                              p_site_use_code in  varchar2,
                              x_msg_count     OUT NOCOPY number,
                              x_msg_data      OUT NOCOPY VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2
) is
  --
  l_rowid varchar2(18);
  l_site_use_id number;
  l_location varchar2(40);
  --
  begin
  --
  --
	arh_csu_pkg.insert_row(
                      	X_Site_Use_Id      	 => l_site_use_id,
                       	X_Last_Update_Date 	 => sysdate,
                       	x_Last_Updated_By        => fnd_global.user_id,
                       	X_Creation_Date          => sysdate,
                       	X_Created_By             => fnd_global.user_id,
                       	X_Site_Use_Code          => p_site_use_code,
				X_customer_id		 => p_customer_id,
                       	X_Address_Id             => p_address_id,
                       	X_Primary_Flag           => 'N',
                       	X_Status                 => 'A',
                       	X_Location               => l_location,
                       	X_Last_Update_Login      => fnd_global.Login_id,
                       	X_Contact_Id             => null,
                       	X_Bill_To_Site_Use_Id    => null,
                       	X_Sic_Code               => null,
                       	X_Payment_Term_Id        => null,
                       	X_Gsa_Indicator          => null,
                       	X_Ship_Partial           => null,
                       	X_Ship_Via               => null,
                       	X_Fob_Point              => null,
                       	X_Order_Type_Id          => null,
                       	X_Price_List_Id          => null,
                       	X_Freight_Term           => null,
                       	X_Warehouse_Id           => null,
                       	X_Territory_Id           => null,
                       	X_Tax_Code               => null,
                       	X_Tax_Reference          => null,
                       	X_Demand_Class_Code      => null,
				x_inventory_location_id  => null,
				x_inventory_organization_id => null,
                       	X_Attribute_Category     => null,
                       	X_Attribute1             => null,
                      	X_Attribute2             => null,
                       	X_Attribute3             => null,
                       	X_Attribute4             => null,
                      	X_Attribute5             => null,
                       	X_Attribute6             => null,
                       	X_Attribute7             => null,
                       	X_Attribute8             => null,
                       	X_Attribute9             => null,
                       	X_Attribute10            => null,
                       	X_Attribute11            => null,
                       	X_Attribute12            => null,
                       	X_Attribute13            => null,
                       	X_Attribute14            => null,
                       	X_Attribute15            => null,
                       	X_Attribute16            => null,
                       	X_Attribute17            => null,
                       	X_Attribute18            => null,
                       	X_Attribute19            => null,
                       	X_Attribute20            => null,
                       	X_Attribute21            => null,
                       	X_Attribute22            => null,
                       	X_Attribute23            => null,
                       	X_Attribute24            => null,
                      	X_Attribute25            => null,
                        X_Tax_Classification     => null,
                        X_Tax_Header_Level_Flag  => null,
                        X_Tax_Rounding_Rule      => null,
                       	X_Global_Attribute_Category => null,
                       	X_Global_Attribute1      => null,
                      	X_Global_Attribute2      => null,
                       	X_Global_Attribute3      => null,
                       	X_Global_Attribute4      => null,
                      	X_Global_Attribute5      => null,
                       	X_Global_Attribute6      => null,
                       	X_Global_Attribute7      => null,
                       	X_Global_Attribute8      => null,
                       	X_Global_Attribute9      => null,
                       	X_Global_Attribute10     => null,
                       	X_Global_Attribute11     => null,
                       	X_Global_Attribute12     => null,
                       	X_Global_Attribute13     => null,
                       	X_Global_Attribute14     => null,
                       	X_Global_Attribute15     => null,
                       	X_Global_Attribute16     => null,
                       	X_Global_Attribute17     => null,
                       	X_Global_Attribute18     => null,
                       	X_Global_Attribute19     => null,
                       	X_Global_Attribute20     => null,
                        X_Primary_Salesrep_Id    => null,
                        X_Finchrg_Receivables_Trx_Id => null,
                        X_GL_ID_Rec	         => null,
		     		X_GL_ID_Rev	  	 => null,
		       	X_GL_ID_Tax	         => null,
		       	X_GL_ID_Freight		 => null,
		       	X_GL_ID_Clearing	 => null,
		       	X_GL_ID_Unbilled	 => null,
		      	X_GL_ID_Unearned 	 => null,
                        X_GL_ID_Unpaid_rec       => null,
                        X_GL_ID_Remittance       => null,
                        X_GL_ID_Factor           => null,
                        X_DATES_NEGATIVE_TOLERANCE    => null,
                        X_DATES_POSITIVE_TOLERANCE    => null,
                        X_DATE_TYPE_PREFERENCE        => null,
                        X_OVER_SHIPMENT_TOLERANCE     => null,
                        X_UNDER_SHIPMENT_TOLERANCE    => null,
                        X_ITEM_CROSS_REF_PREF         => null,
                        X_OVER_RETURN_TOLERANCE       => null,
                        X_UNDER_RETURN_TOLERANCE       => null,
                        X_SHIP_SETS_INCLUDE_LINES_FLAG  => null,
                        X_ARRIVALSETS_INCL_LINES_FLAG   => null,
                                X_SCHED_DATE_PUSH_FLAG          => null,
                                X_INVOICE_QUANTITY_RULE         => null,
                                x_msg_count              => x_msg_count,
                                x_msg_data               => x_msg_data,
                                x_return_status          => x_return_status

			);
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
-- 07/25/01    Suresh P                 Bug No : 1348423 Changed the call
--                                      from arp_csu_pkg.update_su_status
--                                      to arh_csu_pkg.update_su_status .

  Procedure manage_site_use ( 	p_customer_id   in number,
				p_address_id    in number,
				p_site_use_flag in varchar2,
				p_site_use_code   in varchar2,
                                x_msg_count                  OUT NOCOPY NUMBER,
                                x_msg_data                   OUT NOCOPY VARCHAR2,
                                x_return_status              OUT NOCOPY VARCHAR2
 ) is
l_site_use_id number;
l_site_use_status varchar2(1);
begin
	--
	arh_csu_pkg.site_use_exists(	p_address_id 	  => 	p_address_id,
					p_site_use_code	  =>	p_site_use_code,
					p_site_use_id	  =>	l_site_use_id,
					p_site_use_status => 	l_site_use_status,
                                x_msg_count              => x_msg_count,
                                x_msg_data               => x_msg_data,
                                x_return_status          => x_return_status
 );
	--
	--
	--
	if ( p_site_use_flag = 'Y' ) then
	--
        --
        --
		if ( l_site_use_status = 'A') then
			null;
		elsif ( l_site_use_status = 'I') then
-- Bug Fix : 1348423
			arh_csu_pkg.update_su_status(p_customer_id   => p_customer_id,
					          p_address_id    => p_address_id,
						  p_site_use_id   => l_site_use_id,
					          p_site_use_code => p_site_use_code,
						  p_status	  =>'A');
		else
                         null;
                insert_site_use(p_customer_id, p_address_id,p_site_use_code,x_msg_count,
                                x_msg_data,x_return_status);

		end if;
	--
        --
	elsif ( p_site_use_flag = 'N' ) then
		if ( l_site_use_status = 'A' ) then
-- Bug Fix : 1348423
			arh_csu_pkg.update_su_status(p_customer_id   => p_customer_id,
					          p_address_id    => p_address_id,
						  p_site_use_id   => l_site_use_id,
					          p_site_use_code => p_site_use_code,
						  p_status	  => 'I');
		elsif ( l_site_use_status = 'I' ) then
			null;
		else
			null;
		end if;
	end if;

	--
    	--

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
--
 procedure identifying_address_flag(x_party_id in number ) is

begin
	update hz_party_sites set identifying_address_flag = 'N'
        where party_id = x_party_id and identifying_address_flag = 'Y';

end identifying_address_flag;
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

--Bug Fix:1956757,hz_locations table is replaced by hz_cust_acct_sites in the following select statement.
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
        --
        if (
--                ( nvl ( fnd_profile.value('AR_ALT_NAME_SEARCH') , 'N' ) = 'Y' ) and
                ( p_status = 'I')
            ) then
              --
              select status
                into l_status
                from hz_cust_acct_sites
               where rowid = p_rowid;
              --
              if ( l_status = 'A' ) then
                 --
                 select site_use_id
                 into l_site_use_id
                 from hz_cust_site_uses
                 where cust_acct_site_id = p_address_id
                 and site_use_code = 'BILL_TO'
                 and status = 'A';

                 --
                 arp_cust_alt_match_pkg.lock_match ( p_customer_id, l_site_use_id ,
                              l_lock_status );
                 --
                 if ( l_lock_status = 1 ) then
                    --
                    -- Bug 928111:  added additional parameter alt_name to
                    -- since it is not derivable passing as null.
                    arp_cust_alt_match_pkg.delete_match ( p_customer_id, l_site_use_id , NULL) ;
                    --
                 end if;
              --
              end if;
              --
        end if;
        --
        --
exception
        when OTHERS then
              arp_standard.debug('EXCEPTION: arh_addr_pkg.delete_customer_alt_names');
end delete_customer_alt_names;
--
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
                       X_Address_warning        out     NOCOPY boolean,
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
                       X_Cust_acct_site_id    in out           NOCOPY NUMBER,
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
                       X_ORG_ID                     IN  NUMBER  DEFAULT NULL

)


IS

  location_rec       hz_location_v2pub.location_rec_type;
  psite_rec          hz_party_site_v2pub.party_site_rec_type;
  asite_rec          hz_cust_account_site_v2pub.cust_acct_site_rec_type;
  tmp_var            VARCHAR2(2000);
  i                  number;
  x_loc_id           number;
  tmp_var1           VARCHAR2(2000);
  i_create_location  VARCHAR2(1) := 'Y';
  l_count            NUMBER;
  invalid_location   EXCEPTION;
  pragma             EXCEPTION_INIT(invalid_location, -20000);

BEGIN

   ---------------------------------------------------
   -- Preparation of the flag used by the real process
   ---------------------------------------------------
   -- Party Site and Related Location
   --
   IF x_shared_party_site = 'N' THEN
     IF x_location_id is null THEN
        l_count := 1;

        WHILE l_count > 0 loop
            select hr_locations_s.nextval into x_location_id from dual;

            select count(*) into l_count
            from hz_locations
            where location_id = x_location_id;

        END LOOP;
     ELSE
        i_create_location := 'N';
     END IF;
   END IF;
   --
   IF x_shared_party_site = 'Y' THEN
     i_create_location := 'N';
   END IF;
   --
   --
   IF ( x_orig_system_reference is null ) THEN
     x_orig_system_reference := x_address_id;
   END IF;
   --
   --
   IF x_create_location_party_site = 'Y' THEN

      l_count := 1;

      WHILE l_count > 0 loop
           select hr_locations_s.nextval into x_location_id from dual;

           select count(*) into l_count
           from hz_locations
           where location_id = x_location_id;

      END LOOP;
        i_create_location := 'Y';
   END IF;
   --
   IF x_create_location_party_site = 'N' THEN
       check_unique_orig_system_ref(p_orig_system_reference => x_orig_system_reference);
       --
       check_unique_edi_location(p_edi_location          => X_ece_tp_location_code,
                                 p_customer_id           => x_cust_account_id,
                                 p_orig_system_reference => x_orig_system_reference
                                );
   END IF;
   --
   ---------------------------------
   -- Fill the required Record types
   ---------------------------------
   -- Locations REC TYPE
   --
   location_rec.location_id := X_location_Id;
   location_rec.orig_system_reference  := x_location_id ;
   location_rec.country     := X_Country;
   location_rec.address1    := X_Address1;
   location_rec.address2    := X_Address2;
   location_rec.address3    := X_Address3;
   location_rec.address4    := X_Address4;
   location_rec.city        := X_City;
   location_rec.postal_code := X_Postal_Code;
   location_rec.state       := X_State;
   location_rec.province    := X_Province;
   location_rec.county      := X_County;
   location_rec.address_key := X_Address_Key;
   location_rec.language    := X_Language;
   location_rec.sales_tax_geocode      := x_sales_tax_geo_code;
   location_rec.sales_tax_inside_city_limits := x_sale_tax_inside_city_limits;
   location_rec.address_lines_phonetic := X_Address_Lines_Phonetic;
--Start bug fix 2910364, Commented the following lines of code
--   location_rec.Attribute_Category     := X_Attribute_Category;
--   location_rec.attribute1   := X_Attribute1;
--   location_rec.attribute2   := X_Attribute2;
--   location_rec.attribute3   := X_Attribute3;
--   location_rec.attribute4   := X_Attribute4;
--   location_rec.attribute5   := X_Attribute5;
--   location_rec.attribute6   := X_Attribute6;
--   location_rec.attribute7   := X_Attribute7;
--   location_rec.attribute8   := X_Attribute8;
--   location_rec.attribute9   := X_Attribute9;
--   location_rec.attribute10  := X_Attribute10;
--   location_rec.attribute11  := X_Attribute11;
--   location_rec.attribute12  := X_Attribute12;
--   location_rec.attribute13  := X_Attribute13;
--   location_rec.attribute14  := X_Attribute14;
--   location_rec.attribute15  := X_Attribute15;
--   location_rec.attribute16  := X_Attribute16;
--   location_rec.attribute17  := X_Attribute17;
--   location_rec.attribute18  := X_Attribute18;
--   location_rec.attribute19  := X_Attribute19;
--   location_rec.attribute20  := X_Attribute20;
--End bug fix 2910364
--Bug#2689667 {
  location_rec.description              := x_description;
  location_rec.short_description        := x_short_description;
  location_rec.location_directions      := x_location_directions;
  location_rec.postal_plus4_code        := x_postal_plus4_code;
--{HYU BUG#5209119
--  location_rec.floor                    := x_floor;
--  location_rec.house_number             := x_house_number;
--  location_rec.po_box_number            := x_po_box_number;
--  location_rec.street                   := x_street;
--  location_rec.street_number            := x_street_number;
--  location_rec.street_suffix            := x_street_suffix;
--  location_rec.suite                    := x_suite;
--}
   location_rec.created_by_module   := 'TCA_FORM_WRAPPER';
   --
   -- Party Site REC TYPE
   --
   psite_rec.party_site_id         := X_Party_site_id;
   psite_rec.party_id              := X_Party_id;
   psite_rec.location_id           := x_location_id;
   psite_rec.party_site_number     := x_party_site_number;
   psite_rec.orig_system_reference := x_party_site_id;
   psite_rec.identifying_address_flag := x_identifying_address_flag;
   --{HYUBUG#5209119
   --psite_rec.language              := x_language;
   --}
   psite_rec.status                := x_status;
--Start bug fix 2910364, Commented the following lines of code
--   psite_rec.Attribute_Category    := X_Attribute_Category;
--   psite_rec.attribute1            := X_Attribute1;
--   psite_rec.attribute2            := X_Attribute2;
--   psite_rec.attribute3            := X_Attribute3;
--   psite_rec.attribute4            := X_Attribute4;
--   psite_rec.attribute5            := X_Attribute5;
--   psite_rec.attribute6            := X_Attribute6;
--   psite_rec.attribute7            := X_Attribute7;
--   psite_rec.attribute8            := X_Attribute8;
--   psite_rec.attribute9            := X_Attribute9;
--   psite_rec.attribute10           := X_Attribute10;
--   psite_rec.attribute11           := X_Attribute11;
--   psite_rec.attribute12           := X_Attribute12;
--   psite_rec.attribute13           := X_Attribute13;
--   psite_rec.attribute14           := X_Attribute14;
--   psite_rec.attribute15           := X_Attribute15;
--   psite_rec.attribute16           := X_Attribute16;
--   psite_rec.attribute17           := X_Attribute17;
--   psite_rec.attribute18           := X_Attribute18;
--   psite_rec.attribute19           := X_Attribute19;
--   psite_rec.attribute20           := X_Attribute20;
--End bug fix 2910364
   psite_rec.ADDRESSEE             := X_ADDRESSEE;
   psite_rec.created_by_module     := 'TCA_FORM_WRAPPER';
   --
   -- Customer Account Site REC TYPE
   --
   asite_rec.cust_acct_site_id     := X_Cust_acct_site_id;
   asite_rec.cust_account_id       := X_Cust_account_id;
   asite_rec.party_site_id         := X_Party_site_id;
-- fix for bug 1449356
-- odified to pass X_Orig_System_Reference instead of X_Cust_acct_site_id
-- so that if user passed reference no, that will be saved.
-- previously - asite_rec.orig_system_reference := X_Cust_acct_site_id;
   asite_rec.orig_system_reference := X_Orig_System_Reference;
   asite_rec.status                := x_status;
   asite_rec.customer_category_code:= X_Customer_Category;

--   asite_rec.language              := X_language;

   asite_rec.key_account_flag      := X_Key_Account_Flag;
   asite_rec.territory_id          := X_Territory_id;
   asite_rec.Attribute_Category    := X_Attribute_Category;
   asite_rec.attribute1            := X_Attribute1;
   asite_rec.attribute2            := X_Attribute2;
   asite_rec.attribute3            := X_Attribute3;
   asite_rec.attribute4            := X_Attribute4;
   asite_rec.attribute5            := X_Attribute5;
   asite_rec.attribute6            := X_Attribute6;
   asite_rec.attribute7            := X_Attribute7;
   asite_rec.attribute8            := X_Attribute8;
   asite_rec.attribute9            := X_Attribute9;
   asite_rec.attribute10           := X_Attribute10;
   asite_rec.attribute11           := X_Attribute11;
   asite_rec.attribute12           := X_Attribute12;
   asite_rec.attribute13           := X_Attribute13;
   asite_rec.attribute14           := X_Attribute14;
   asite_rec.attribute15           := X_Attribute15;
   asite_rec.attribute16           := X_Attribute16;
   asite_rec.attribute17           := X_Attribute17;
   asite_rec.attribute18           := X_Attribute18;
   asite_rec.attribute19           := X_Attribute19;
   asite_rec.attribute20           := X_Attribute20;
   asite_rec.Global_Attribute_Category := X_Global_Attribute_Category;
   asite_rec.Global_Attribute1     := X_Global_Attribute1;
   asite_rec.Global_Attribute2     := X_Global_Attribute2;
   asite_rec.Global_Attribute3     := X_Global_Attribute3;
   asite_rec.Global_Attribute4     := X_Global_Attribute4;
   asite_rec.Global_Attribute5     := X_Global_Attribute5;
   asite_rec.Global_Attribute6     := X_Global_Attribute6;
   asite_rec.Global_Attribute7     := X_Global_Attribute7;
   asite_rec.Global_Attribute8     := X_Global_Attribute8;
   asite_rec.Global_Attribute9     := X_Global_Attribute9;
   asite_rec.Global_Attribute10    := X_Global_Attribute10;
   asite_rec.Global_Attribute11    := X_Global_Attribute11;
   asite_rec.Global_Attribute12    := X_Global_Attribute12;
   asite_rec.Global_Attribute13    := X_Global_Attribute13;
   asite_rec.Global_Attribute14    := X_Global_Attribute14;
   asite_rec.Global_Attribute15    := X_Global_Attribute15;
   asite_rec.Global_Attribute16    := X_Global_Attribute16;
   asite_rec.Global_Attribute17    := X_Global_Attribute17;
   asite_rec.Global_Attribute18    := X_Global_Attribute18;
   asite_rec.Global_Attribute19    := X_Global_Attribute19;
   asite_rec.Global_Attribute20    := X_Global_Attribute20;
   asite_rec.ece_tp_location_code  := X_ece_tp_location_code;
   asite_rec.territory             := X_Territory;
   asite_rec.translated_customer_name := X_Translated_Customer_Name;
   asite_rec.created_by_module     := 'TCA_FORM_WRAPPER';
/*Bug 3976386 MOAC changes*/
   asite_rec.ORG_ID                := X_ORG_ID;
   --
   --
   --
   IF x_create_location_party_site = 'Y' THEN
      psite_rec.party_site_id         := null;
      psite_rec.orig_system_reference := null;
      psite_rec.party_site_number     := null;
   END IF;

   --
   --
   -- { Party Site and Related Location creation process
   --
   IF i_create_location = 'Y' THEN

       HZ_LOCATION_V2PUB.create_location (
          p_location_rec                     => location_rec,
          x_location_id                      => x_location_id,
          x_return_status                    => x_return_status,
          x_msg_count                        => x_msg_count,
          x_msg_data                         => x_msg_data );

      IF x_msg_count > 1 THEN
        FOR i IN 1..x_msg_count  LOOP
          tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
          tmp_var1 := tmp_var1 || ' '|| tmp_var;
        END LOOP;
        x_msg_data := tmp_var1;
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          return;
      END IF;


      HZ_PARTY_SITE_V2PUB.create_party_site (
        p_party_site_rec                   => psite_rec,
        x_party_site_id                    => x_party_site_id,
        x_party_site_number                => x_party_site_number,
        x_return_status                    => x_return_status,
        x_msg_count                        => x_msg_count,
        x_msg_data                         => x_msg_data );

      IF x_msg_count > 1 THEN
        FOR i IN 1..x_msg_count  LOOP
         tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
          tmp_var1 := tmp_var1 || ' '|| tmp_var;
        END LOOP;
        x_msg_data := tmp_var1;
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          return;
      END IF;


   END IF; -- if i_create_location = 'Y'
   -- }


  --
  -- Tax Assignment based on party site
  -- {
  IF x_update_account_site = 'Y' THEN

    HZ_TAX_ASSIGNMENT_V2PUB.create_loc_assignment(
        p_location_id                  => x_location_id,
        p_lock_flag                    => FND_API.G_TRUE,
        p_created_by_module            => 'FORM-WRAPPER',
        p_application_id               => -222,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        x_loc_id                       => x_loc_id );

    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;


    UPDATE hz_cust_acct_sites
       SET party_site_id     =  x_party_site_id
     WHERE cust_acct_site_id =  x_cust_acct_site_id;

  END IF;
  -- }


  IF i_create_location = 'Y' THEN
    asite_rec.party_site_id   := X_Party_site_id;
  END IF;

  --
  -- Customer Account Site can either be related to a party site or new
  -- {
  IF x_update_account_site = 'N' THEN

    HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_acct_site (
        p_cust_acct_site_rec                => asite_rec,
        x_cust_acct_site_id                 => x_cust_acct_site_id,
        x_return_status                     => x_return_status,
        x_msg_count                         => x_msg_count,
        x_msg_data                          => x_msg_data  );

    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;


    x_address_id := x_cust_acct_site_id;

  END IF;
  --}

  arp_standard.debug('ARHADDRB:Insert Row: After Insert into hz_cust_Acct_sites');

  IF ( x_address_mode = 'QUICK' ) THEN
     IF ( x_su_bill_to_flag = 'Y' ) THEN
         insert_site_use (X_Cust_account_id,x_address_id,'BILL_TO',x_msg_count,x_msg_data, x_return_status);
     END IF;
     --
     arp_standard.debug('After insert_site_use bill_to  call ');
     --
     IF ( x_su_ship_to_flag = 'Y' ) THEN
         insert_site_use (X_Cust_account_id,x_address_id,'SHIP_TO',x_msg_count,x_msg_data, x_return_status);
     END IF;
     --
     arp_standard.debug('After insert_site_use ship_to  call ');
     --
     IF ( x_su_market_flag = 'Y' ) THEN
         insert_site_use (X_Cust_account_id,x_address_id,'MARKET',x_msg_count,x_msg_data, x_return_status);
     END IF;
     --
     arp_standard.debug('After insert_site_use market  call ');
     --
     IF ( x_su_stmt_flag = 'Y' ) THEN
         insert_site_use (X_Cust_account_id,x_address_id,'STMTS',x_msg_count,x_msg_data, x_return_status);
     END IF;
     --
     arp_standard.debug('After insert_site_use stmts  call ');
     --
     IF ( x_su_dun_flag = 'Y' ) THEN
         insert_site_use (X_Cust_account_id,x_address_id,'DUN',x_msg_count,x_msg_data,  x_return_status);
     END IF;
     --
     arp_standard.debug('After insert_site_use dun  call ');
     --
     IF ( x_su_legal_flag = 'Y' ) THEN
         insert_site_use (X_Cust_account_id,x_address_id,'LEGAL',x_msg_count,x_msg_data, x_return_status);
     END IF;
     --
     arp_standard.debug('After insert_site_use legal  call ');
     --
  ELSIF ( x_address_mode = 'STANDARD' ) then
           null;
  ELSE
      app_exception.invalid_argument('arp_addr_pkg.Insert_Row', 'x_address_mode', x_address_mode);
  END IF;
  --
  --
  IF ( arp_standard.sysparm.address_validation = 'WARN' ) THEN
        x_address_warning := arp_adds.location_segment_inserted;
  END IF;
  --
  --
  arp_standard.debug('AROADDRB:Insert Row: END');
  --
  END Insert_Row;


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
                       x_object_version             IN  NUMBER,
                       x_object_version_party_site  IN  NUMBER,
                       x_object_version_location    IN  NUMBER,
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
)

IS
  --
  --
  l_site_use_id number;
  l_site_use_status  VARCHAR2(1);
  location_rec       hz_location_v2pub.location_rec_type;
  psite_rec          hz_party_site_v2pub.party_site_rec_type;
  asite_rec          hz_cust_account_site_v2pub.cust_acct_site_rec_type;
  tmp_var            VARCHAR2(2000);
  i                  number;
  tmp_var1           VARCHAR2(2000);
  --
  --
  CURSOR cu_version_location IS
    SELECT ROWID,
           OBJECT_VERSION_NUMBER,
           LAST_UPDATE_DATE
      FROM HZ_LOCATIONS
     WHERE LOCATION_ID  = x_location_id;

  CURSOR cu_version_party_site IS
    SELECT ROWID,
           OBJECT_VERSION_NUMBER,
           LAST_UPDATE_DATE
      FROM HZ_PARTY_SITES
     WHERE PARTY_SITE_ID  = X_Party_site_id;

  CURSOR cu_version_account_site IS
    SELECT ROWID,
           OBJECT_VERSION_NUMBER,
           LAST_UPDATE_DATE
      FROM HZ_CUST_ACCT_SITES
     WHERE CUST_ACCT_SITE_ID = X_address_id;

  l_object_version_number       NUMBER;
  l_rowid                       ROWID;
  l_last_update_date            DATE;
  l_object_version_location     NUMBER;
  l_object_version_party_site   NUMBER;
  l_object_version_account_site NUMBER;
  --
  --
  invalid_location EXCEPTION;
  pragma exception_init(invalid_location, -20000);
  --
  --
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

 -----------------------------------------------------------------------
 --{ For Backward compatibility when Object Version Number is not entered
 -----------------------------------------------------------------------
   -----------
   -- Location
   -----------
   IF x_object_version_location = -1 THEN

     OPEN cu_version_location;
     FETCH cu_version_location INTO
           l_rowid            ,
           l_object_version_number,
           l_last_update_date ;
     IF cu_version_location%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('AR','HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD','hz_locations');
        FND_MESSAGE.SET_TOKEN('ID',x_location_id);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
     ELSE
        l_object_version_location := l_object_version_number;
     END IF;
     CLOSE cu_version_location;
     --
     IF TO_CHAR(X_loc_Last_Update_Date,'DD-MON-YYYY HH:MI:SS') <>
        TO_CHAR(l_last_update_date,'DD-MON-YYYY HH:MI:SS')
     THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', 'hz_locations');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   ELSE
     l_object_version_location := x_object_version_location;
   END IF;
   --
   IF    x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -------------
   -- Party Site
   --------------
   IF x_object_version_party_site = -1 THEN
     OPEN cu_version_party_site;
     FETCH cu_version_party_site INTO
           l_rowid            ,
           l_object_version_number,
           l_last_update_date ;
     IF cu_version_party_site%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('AR','HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD','hz_party_sites');
        FND_MESSAGE.SET_TOKEN('ID',x_party_site_id);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
     ELSE
        l_object_version_party_site := l_object_version_number;
     END IF;
     CLOSE cu_version_party_site;
     --
     IF TO_CHAR(X_party_site_Last_Update_Date,'DD-MON-YYYY HH:MI:SS') <>
        TO_CHAR(l_last_update_date,'DD-MON-YYYY HH:MI:SS')
     THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', 'hz_party_sites');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   ELSE
     l_object_version_party_site := x_object_version_party_site;
   END IF;
   --

   IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
   END IF;

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
   END IF;


   ---------------
   -- Account Site
   ---------------
   IF x_object_version = -1 THEN

     OPEN cu_version_account_site;
     FETCH cu_version_account_site INTO
           l_rowid            ,
           l_object_version_number,
           l_last_update_date ;
     IF cu_version_account_site%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('AR','HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD','hz_cust_acct_sites');
        FND_MESSAGE.SET_TOKEN('ID',x_cust_acct_site_id);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
     ELSE
        l_object_version_account_site := l_object_version_number;
     END IF;
     CLOSE cu_version_account_site;
     --
     IF TO_CHAR(X_Last_Update_Date,'DD-MON-YYYY HH:MI:SS') <>
        TO_CHAR(l_last_update_date,'DD-MON-YYYY HH:MI:SS')
     THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', 'hz_account_sites');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   ELSE
     l_object_version_account_site := x_object_version;
   END IF;
   --
   IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
   END IF;

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
   END IF;


 -----------------------------------------------------------------------
 --} For Backward compatibility when Object Version Number is not entered
 -----------------------------------------------------------------------

  check_unique_edi_location(p_edi_location          => X_ece_tp_location_code,
                            p_customer_id           => x_cust_account_id,
                            p_orig_system_reference => x_orig_system_reference
                           );

  --------------------------
  -- Location V2 Record Type
  --------------------------
  location_rec.location_id := X_location_Id;
  location_rec.country     := INIT_SWITCH(X_Country);
  location_rec.address1    := INIT_SWITCH(X_Address1);
  location_rec.address2    := INIT_SWITCH(X_Address2);
  location_rec.address3    := INIT_SWITCH(X_Address3);
  location_rec.address4    := INIT_SWITCH(X_Address4);
  location_rec.city        := INIT_SWITCH(X_City);
  location_rec.postal_code := INIT_SWITCH(X_Postal_Code);
  location_rec.state       := INIT_SWITCH(X_State);
  location_rec.province    := INIT_SWITCH(X_Province);
  location_rec.county      := INIT_SWITCH(X_County);
  location_rec.address_key := INIT_SWITCH(X_Address_Key);
  location_rec.language    := INIT_SWITCH(X_Language);
  location_rec.address_lines_phonetic := INIT_SWITCH(X_Address_Lines_Phonetic);
--Start bug fix 2910364, Commented the following lines of code
--  location_rec.Attribute_Category     := INIT_SWITCH(X_Attribute_Category);
--  location_rec.attribute1  := INIT_SWITCH(X_Attribute1);
--  location_rec.attribute2  := INIT_SWITCH(X_Attribute2);
--  location_rec.attribute3  := INIT_SWITCH(X_Attribute3);
--  location_rec.attribute4  := INIT_SWITCH(X_Attribute4);
--  location_rec.attribute5  := INIT_SWITCH(X_Attribute5);
--  location_rec.attribute6  := INIT_SWITCH(X_Attribute6);
--  location_rec.attribute7  := INIT_SWITCH(X_Attribute7);
--  location_rec.attribute8  := INIT_SWITCH(X_Attribute8);
--  location_rec.attribute9  := INIT_SWITCH(X_Attribute9);
--  location_rec.attribute10 := INIT_SWITCH(X_Attribute10);
--  location_rec.attribute11 := INIT_SWITCH(X_Attribute11);
--  location_rec.attribute12 := INIT_SWITCH(X_Attribute12);
--  location_rec.attribute13 := INIT_SWITCH(X_Attribute13);
--  location_rec.attribute14 := INIT_SWITCH(X_Attribute14);
--  location_rec.attribute15 := INIT_SWITCH(X_Attribute15);
--  location_rec.attribute16 := INIT_SWITCH(X_Attribute16);
--  location_rec.attribute17 := INIT_SWITCH(X_Attribute17);
--  location_rec.attribute18 := INIT_SWITCH(X_Attribute18);
--  location_rec.attribute19 := INIT_SWITCH(X_Attribute19);
--  location_rec.attribute20 := INIT_SWITCH(X_Attribute20);
--End bug fix 2910364
--Bug#2689667 {
  location_rec.description              := INIT_SWITCH(x_description);
  location_rec.short_description        := INIT_SWITCH(x_short_description);
--  location_rec.floor                    := INIT_SWITCH(x_floor);
--  location_rec.house_number            := INIT_SWITCH(x_house_number) ;
  location_rec.location_directions     := INIT_SWITCH(x_location_directions) ;
  location_rec.postal_plus4_code       := INIT_SWITCH(x_postal_plus4_code) ;
--  location_rec.po_box_number            := INIT_SWITCH(x_po_box_number) ;
--  location_rec.street                  := INIT_SWITCH(x_street);
--  location_rec.street_number           := INIT_SWITCH(x_street_number);
--  location_rec.street_suffix          := INIT_SWITCH(x_street_suffix) ;
--  location_rec.suite                  := INIT_SWITCH(x_suite) ;
--}
-- Bug - 1330693. Added the 1 line so that sales_tax_inside_city_limits is populated
-- Bug - 1433433. Added the 1 line so that geocode is populated
  location_rec.Sales_Tax_Inside_City_Limits := INIT_SWITCH(X_Sales_Tax_Inside_City_Limits);
  location_rec.Sales_Tax_Geocode            := INIT_SWITCH(X_Sales_Tax_Geocode);


--{BUG#4037614
   check_printed_trx
   (p_location_id   => X_location_Id,
    p_location_rec  => location_rec,
    x_return_status => x_return_status,
    x_msg_data      => x_msg_data,
    x_msg_count     => x_msg_count);

    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;
--}

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;
    --}

  ----------------------------
  -- Party Site V2 Record Type
  ----------------------------
  psite_rec.party_site_id            := INIT_SWITCH(X_Party_site_id);
-- psite_rec.party_id                := X_Party_id;
-- psite_rec.location_id             := x_location_id;
  psite_rec.identifying_address_flag := INIT_SWITCH(x_identifying_address_flag);

--{HYU evaluation bug#5209119
--  psite_rec.language                 := INIT_SWITCH(x_language);
--}
--Bug #1402584  de-activating a cust_acct_site from the customer standard form also de-activates the corresponding party_site.Hence commenting the psite_rec.status.
--psite_rec.status                   := x_status;
--Start bug fix 2910364, Commented the following lines of code
--  psite_rec.Attribute_Category       := INIT_SWITCH(X_Attribute_Category);
--  psite_rec.attribute1               := INIT_SWITCH(X_Attribute1);
--  psite_rec.attribute2               := INIT_SWITCH(X_Attribute2);
--  psite_rec.attribute3               := INIT_SWITCH(X_Attribute3);
--  psite_rec.attribute4               := INIT_SWITCH(X_Attribute4);
--  psite_rec.attribute5               := INIT_SWITCH(X_Attribute5);
--  psite_rec.attribute6               := INIT_SWITCH(X_Attribute6);
--  psite_rec.attribute7               := INIT_SWITCH(X_Attribute7);
--  psite_rec.attribute8               := INIT_SWITCH(X_Attribute8);
--  psite_rec.attribute9               := INIT_SWITCH(X_Attribute9);
--  psite_rec.attribute10              := INIT_SWITCH(X_Attribute10);
--  psite_rec.attribute11              := INIT_SWITCH(X_Attribute11);
--  psite_rec.attribute12              := INIT_SWITCH(X_Attribute12);
--  psite_rec.attribute13              := INIT_SWITCH(X_Attribute13);
--  psite_rec.attribute14              := INIT_SWITCH(X_Attribute14);
--  psite_rec.attribute15              := INIT_SWITCH(X_Attribute15);
--  psite_rec.attribute16              := INIT_SWITCH(X_Attribute16);
--  psite_rec.attribute17              := INIT_SWITCH(X_Attribute17);
--  psite_rec.attribute18              := INIT_SWITCH(X_Attribute18);
--  psite_rec.attribute19              := INIT_SWITCH(X_Attribute19);
--  psite_rec.attribute20              := INIT_SWITCH(X_Attribute20);
--End bug fix 2910364
  psite_rec.ADDRESSEE                := INIT_SWITCH(X_ADDRESSEE);

  -----------------------------------
  -- Cust Account Site V2 Record Type
  -----------------------------------
  asite_rec.cust_acct_site_id     := INIT_SWITCH(X_Cust_acct_site_id);
-- asite_rec.cust_account_id        := X_Cust_account_id;
  asite_rec.party_site_id          := INIT_SWITCH(X_Party_site_id);
  asite_rec.status                 := INIT_SWITCH(x_status);
-- asite_rec.bill_to_flag           := X_su_Bill_To_Flag;
-- asite_rec.market_flag            := X_su_Market_Flag;
-- asite_rec.ship_to_flag           := X_su_Ship_To_Flag;
  asite_rec.customer_category_code := INIT_SWITCH(X_Customer_Category);
--{HYU BUG#5209119
--  asite_rec.language               := INIT_SWITCH(X_language);
--}
  asite_rec.key_account_flag       := INIT_SWITCH(X_Key_Account_Flag);
  asite_rec.territory_id           := INIT_SWITCH(X_Territory_id);
  asite_rec.Attribute_Category     := INIT_SWITCH(X_Attribute_Category);
  asite_rec.attribute1             := INIT_SWITCH(X_Attribute1);
  asite_rec.attribute2             := INIT_SWITCH(X_Attribute2);
  asite_rec.attribute3             := INIT_SWITCH(X_Attribute3);
  asite_rec.attribute4             := INIT_SWITCH(X_Attribute4);
  asite_rec.attribute5             := INIT_SWITCH(X_Attribute5);
  asite_rec.attribute6             := INIT_SWITCH(X_Attribute6);
  asite_rec.attribute7             := INIT_SWITCH(X_Attribute7);
  asite_rec.attribute8             := INIT_SWITCH(X_Attribute8);
  asite_rec.attribute9             := INIT_SWITCH(X_Attribute9);
  asite_rec.attribute10            := INIT_SWITCH(X_Attribute10);
  asite_rec.attribute11            := INIT_SWITCH(X_Attribute11);
  asite_rec.attribute12            := INIT_SWITCH(X_Attribute12);
  asite_rec.attribute13            := INIT_SWITCH(X_Attribute13);
  asite_rec.attribute14            := INIT_SWITCH(X_Attribute14);
  asite_rec.attribute15            := INIT_SWITCH(X_Attribute15);
  asite_rec.attribute16            := INIT_SWITCH(X_Attribute16);
  asite_rec.attribute17            := INIT_SWITCH(X_Attribute17);
  asite_rec.attribute18            := INIT_SWITCH(X_Attribute18);
  asite_rec.attribute19            := INIT_SWITCH(X_Attribute19);
  asite_rec.attribute20            := INIT_SWITCH(X_Attribute20);
  asite_rec.Global_Attribute_Category := INIT_SWITCH(X_Global_Attribute_Category);
  asite_rec.Global_Attribute1      := INIT_SWITCH(X_Global_Attribute1);
  asite_rec.Global_Attribute2      := INIT_SWITCH(X_Global_Attribute2);
  asite_rec.Global_Attribute3      := INIT_SWITCH(X_Global_Attribute3);
  asite_rec.Global_Attribute4      := INIT_SWITCH(X_Global_Attribute4);
  asite_rec.Global_Attribute5      := INIT_SWITCH(X_Global_Attribute5);
  asite_rec.Global_Attribute6      := INIT_SWITCH(X_Global_Attribute6);
  asite_rec.Global_Attribute7      := INIT_SWITCH(X_Global_Attribute7);
  asite_rec.Global_Attribute8      := INIT_SWITCH(X_Global_Attribute8);
  asite_rec.Global_Attribute9      := INIT_SWITCH(X_Global_Attribute9);
  asite_rec.Global_Attribute10     := INIT_SWITCH(X_Global_Attribute10);
  asite_rec.Global_Attribute11     := INIT_SWITCH(X_Global_Attribute11);
  asite_rec.Global_Attribute12     := INIT_SWITCH(X_Global_Attribute12);
  asite_rec.Global_Attribute13     := INIT_SWITCH(X_Global_Attribute13);
  asite_rec.Global_Attribute14     := INIT_SWITCH(X_Global_Attribute14);
  asite_rec.Global_Attribute15     := INIT_SWITCH(X_Global_Attribute15);
  asite_rec.Global_Attribute16     := INIT_SWITCH(X_Global_Attribute16);
  asite_rec.Global_Attribute17     := INIT_SWITCH(X_Global_Attribute17);
  asite_rec.Global_Attribute18     := INIT_SWITCH(X_Global_Attribute18);
  asite_rec.Global_Attribute19     := INIT_SWITCH(X_Global_Attribute19);
  asite_rec.Global_Attribute20     := INIT_SWITCH(X_Global_Attribute20);
  asite_rec.ece_tp_location_code   := INIT_SWITCH(X_ece_tp_location_code);
  asite_rec.territory              := INIT_SWITCH(X_Territory);
  asite_rec.translated_customer_name := INIT_SWITCH(X_Translated_Customer_Name);
/*Bug 3976386 MOAC changes*/
  asite_rec.ORG_ID                 := INIT_SWITCH(X_ORG_ID);
  ------------------
  -- Location update
  ------------------
    HZ_LOCATION_V2PUB.update_location (
        p_location_rec                      => location_rec,
        p_object_version_number             => l_object_version_location,
        x_return_status                     => x_return_status,
        x_msg_count                         => x_msg_count,
        x_msg_data                          => x_msg_data );

    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;

    SELECT last_update_date
      INTO x_loc_last_update_date
      FROM hz_locations
     WHERE location_id = x_location_id;

  --------------------
  -- Party_Site update
  --------------------
    HZ_PARTY_SITE_V2PUB.update_party_site (
        p_party_site_rec                    => psite_rec,
        p_object_version_number             => l_object_version_party_site,
        x_return_status                     => x_return_status,
        x_msg_count                         => x_msg_count,
        x_msg_data                          => x_msg_data );

    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;

    SELECT last_update_date
      INTO x_party_site_last_update_date
      FROM hz_party_sites
     WHERE party_site_id = x_party_site_id;

  ----------------------
  -- Account_Site update
  ----------------------
    HZ_CUST_ACCOUNT_SITE_V2PUB.update_cust_acct_site (
        p_cust_acct_site_rec                => asite_rec,
        p_object_version_number             => l_object_version_account_site,
        x_return_status                     => x_return_status,
        x_msg_count                         => x_msg_count,
        x_msg_data                          => x_msg_data );

    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;

    SELECT last_update_date
      INTO x_last_update_date
      FROM hz_cust_acct_sites
     WHERE cust_acct_site_id = x_address_id;

   --
   --
   -- Update the site use rows if running in QUICK_MODE
   --
   --
   IF ( x_address_mode = 'QUICK'  ) THEN
	  manage_site_use(p_customer_id      => X_Cust_account_id,
                         p_address_id       => x_address_id,
                         p_site_use_flag    => x_su_bill_to_flag,
                         p_site_use_code    => 'BILL_TO',
                         x_msg_count        => x_msg_count,
                         x_msg_data         => x_msg_data,
                         x_return_status    => x_return_status );
   	  --
	  manage_site_use(p_customer_id      => X_Cust_account_id,
                         p_address_id       => x_address_id,
                         p_site_use_flag    => x_su_ship_to_flag,
                         p_site_use_code    => 'SHIP_TO',
                         x_msg_count        => x_msg_count,
                         x_msg_data         => x_msg_data,
                         x_return_status    => x_return_status );
	   --
        manage_site_use(p_customer_id     => X_Cust_account_id,
                        p_address_id      => x_address_id,
                        p_site_use_flag   => x_su_market_flag,
                        p_site_use_code   => 'MARKET',
                        x_msg_count       => x_msg_count,
                        x_msg_data        => x_msg_data,
                        x_return_status   => x_return_status );
	   --
        manage_site_use(p_customer_id     => X_Cust_account_id,
                        p_address_id      => x_address_id,
                        p_site_use_flag   => x_su_stmt_flag,
                        p_site_use_code   => 'STMTS',
                        x_msg_count       => x_msg_count,
                        x_msg_data        => x_msg_data,
                        x_return_status   => x_return_status);
	   --
	  manage_site_use(p_customer_id     => X_Cust_account_id,
                         p_address_id      => x_address_id,
                         p_site_use_flag   => x_su_dun_flag,
                         p_site_use_code   => 'DUN',
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data,
                         x_return_status   => x_return_status);
	   --
	  manage_site_use(p_customer_id     => X_Cust_account_id,
                         p_address_id      => x_address_id,
                         p_site_use_flag   => x_su_legal_flag,
                         p_site_use_code   => 'LEGAL',
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data,
                         x_return_status   => x_return_status);

    ELSIF ( x_address_mode = 'STANDARD' ) THEN
           null;
    ELSE
          app_exception.invalid_argument('arp_addr_pkg.Insert_Row', 'x_address_mode',
                                          x_address_mode);

    END IF;
    --
    --
    IF ( arp_standard.sysparm.address_validation = 'WARN' ) THEN
	x_address_warning := arp_adds.location_segment_inserted;
    END IF;
    --
    --
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

  select loc_assign.loc_id
  into   location_identifier
  from   hz_cust_acct_sites acct_site,
         hz_party_sites party_site,
         hz_locations loc,
         hz_loc_assignments loc_assign
  where  acct_site.party_site_id = party_site.party_site_id
    and  loc.location_id = party_site.location_id
    and  loc.location_id = loc_assign.location_id
    and  nvl(acct_site.org_id,-99) = nvl(loc_assign.org_id, -99)
    and  acct_site.cust_acct_site_id  = p_address_id;

  if location_identifier is NULL then
    RETURN (FALSE);
  else
    RETURN (TRUE);
  end if;
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
invoice_count varchar2(1);
check_value    varchar2(1);
--
cursor ship_to_site is
       select site_use_id
       from   hz_cust_site_uses
       where  cust_acct_site_id     = p_address_id
       and    site_use_code         = 'SHIP_TO';
--
cursor bill_to_site is
       select site_use_id
       from   hz_cust_site_uses
       where  cust_acct_site_id     = p_address_id
       and    site_use_code         = 'BILL_TO';
BEGIN

--
   BEGIN

      -- check  the flag: allow change to printed transaction  is set to 'Y' or 'N'
      -- If it is set to 'Y', exit the function and customers are able to update the address
      -- If it is set to 'N', then check whether printed or posted transaction exits for
      -- bill-to or ship-to site,and the transaction has been applied
      -- and the transaction has any txa lines, if yes for above conditions, restrict update
      -- for customers on address component..

      -- Note : This FUNCTION could have lived without customer_id argument i.e site_use_id
      --        was enough but then it would have meant to create two new indexes on :
      --        bill_to_site_use_id and ship_to_site_use_id. We have avoided this by using
      --        site_use_id (bill/ship) in conjunction with customer_id.

    BEGIN
       select change_printed_invoice_flag
       into   check_value
       from   ar_system_parameters_all
       where org_id =
       (select org_id from hz_cust_acct_sites_all where cust_acct_site_id = p_address_id);

--Bug fix 2183072 Handled the exception.
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.SET_NAME( 'AR','AR_NO_ROW_IN_SYSTEM_PARAMETERS');
         FND_MSG_PUB.ADD;
   END ;

       if check_value = 'Y' then
          RETURN (FALSE);
       end if;
      --
       for i in ship_to_site
       loop
--
         select 'x'
         into   invoice_count
         from   dual
         where  exists ( select 'y'
                         from   ra_cust_trx_types         ctt,
                                ra_customer_trx_lines     ctl,
                                ra_customer_trx           ct
                         where  ct.cust_trx_type_id       = ctt.cust_trx_type_id
                         and    ct.customer_trx_id        = ctl.customer_trx_id
                         and    'TAX'                     = ctl.line_type
                         and    (
                                 'Y'                      = arpt_sql_func_util.get_posted_flag
                                                            ( ct.customer_trx_id,
                                                              ctt.post_to_gl,
                                                              ct.complete_flag
                                                            )  -- posted_flag
                         OR      'Y'                      = arpt_sql_func_util.get_activity_flag
                                                            ( ct.customer_trx_id,
                                                              ctt.accounting_affect_flag,
                                                              ct.complete_flag,
                                                              ctt.type,
                                                              ct.initial_customer_trx_id,
                                                              ct.previous_customer_trx_id
                                                            ) -- activity_flag
                         OR      DECODE(ct.printing_last_printed,
                                        NULL,'N', 'Y')    = 'Y'
                                )
                         and    ct.ship_to_customer_id    = p_customer_id
                         and    ct.ship_to_site_use_id    = i.site_use_id
                       );

           RETURN (TRUE);
           exit;

       end loop;

       if invoice_count is NULL then
--
         for j in bill_to_site
           loop
             select 'x'
             into   invoice_count
             from   dual
             where  exists ( select 'y'
                             from   ra_cust_trx_types         ctt,
                                    ra_customer_trx_lines     ctl,
                                    ra_customer_trx           ct
                             where  ct.cust_trx_type_id       = ctt.cust_trx_type_id
                             and    ct.customer_trx_id        = ctl.customer_trx_id
                             and    'TAX'                     = ctl.line_type
                             and    (
                                     'Y'                      = arpt_sql_func_util.get_posted_flag
                                                                ( ct.customer_trx_id,
                                                                  ctt.post_to_gl,
                                                                  ct.complete_flag
                                                                )  -- posted_flag
                             OR      'Y'                      = arpt_sql_func_util.get_activity_flag
                                                                ( ct.customer_trx_id,
                                                                  ctt.accounting_affect_flag,
                                                                  ct.complete_flag,
                                                                  ctt.type,
                                                                  ct.initial_customer_trx_id,
                                                                  ct.previous_customer_trx_id
                                                                ) -- activity_flag
                             OR      DECODE(ct.printing_last_printed,
                                            NULL,'N', 'Y')    = 'Y'
                                    )
                             and    ct.bill_to_customer_id    = p_customer_id
                             and    ct.bill_to_site_use_id    = j.site_use_id
                           );

               RETURN (TRUE);
               exit;

           end loop;
--
       end if;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           RETURN (FALSE);
--
    END;

--
  if invoice_count is NULL then
    RETURN (FALSE);
  end if;
--
END transaction_exists;
--

/* New Function created so that we check for transactions in all orgs */
FUNCTION transaction_morg_exists
(p_address_id  IN number,
 p_customer_id IN number)
RETURN BOOLEAN
IS
--
invoice_count varchar2(1);
check_value    varchar2(1);
--
--{BUG#4037614 the tables accessed need to be all on site uses
cursor ship_to_site is
       select site_use_id
       from   hz_cust_site_uses_all
       where  cust_acct_site_id     = p_address_id
       and    site_use_code         = 'SHIP_TO';
--
cursor bill_to_site is
       select site_use_id
       from   hz_cust_site_uses_all
       where  cust_acct_site_id     = p_address_id
       and    site_use_code         = 'BILL_TO';
BEGIN

arp_debug.debug('transaction_morg_exists +');
arp_debug.debug(' p_customer_id:'||p_customer_id);
--
   BEGIN

      -- check  the flag: allow change to printed transaction  is set to 'Y' or 'N'
      -- If it is set to 'Y', exit the function and customers are able to update the address
      -- If it is set to 'N', then check whether printed or posted transaction exits for
      -- bill-to or ship-to site,and the transaction has been applied
      -- and the transaction has any txa lines, if yes for above conditions, restrict update
      -- for customers on address component..

      -- Note : This FUNCTION could have lived without customer_id argument i.e site_use_id
      --        was enough but then it would have meant to create two new indexes on :
      --        bill_to_site_use_id and ship_to_site_use_id. We have avoided this by using
      --        site_use_id (bill/ship) in conjunction with customer_id.

   BEGIN
       arp_debug.debug('transaction_morg_exists.p_address_id: ' || p_address_id);
       select change_printed_invoice_flag
       into   check_value
       from   ar_system_parameters_all
       where org_id =
       (select org_id from hz_cust_acct_sites_all where cust_acct_site_id = p_address_id);

--Bug fix 2183072 Handled the exception.
   EXCEPTION
    WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.SET_NAME( 'AR','AR_NO_ROW_IN_SYSTEM_PARAMETERS');
         FND_MSG_PUB.ADD;
         arp_debug.debug(' EXCEPTION AR_NO_ROW_IN_SYSTEM_PARAMETERS in transaction_morg_exists ');
   END ;
   arp_debug.debug(' check_value :'||check_value);

   IF check_value = 'Y' THEN
        arp_debug.debug('transaction_morg_exists - RESULT : FALSE');
        RETURN (FALSE);
   END IF;
      --
       for i in ship_to_site
       loop
--
       BEGIN
         arp_debug.debug(' cursor SHIP_TO_SITE site_use_id retrieved:'||i.site_use_id);
         select 'x'
         into   invoice_count
         from   dual
         where  exists ( select 'y'
                         from   ra_cust_trx_types_all         ctt,
                                ra_customer_trx_lines_all     ctl,
                                ra_customer_trx_all           ct
                         where  ct.cust_trx_type_id       = ctt.cust_trx_type_id
                         and    nvl(ct.org_id, -99)       = nvl(ctt.org_id, -99)
                         and    ct.customer_trx_id        = ctl.customer_trx_id
                         and    'TAX'                     = ctl.line_type
                         and    (
                                 'Y'                      = arpt_sql_func_util.get_posted_flag
                                                            ( ct.customer_trx_id,
                                                              ctt.post_to_gl,
                                                              ct.complete_flag
                                                            )  -- posted_flag
                         OR      'Y'                      = arpt_sql_func_util.get_activity_flag
                                                            ( ct.customer_trx_id,
                                                              ctt.accounting_affect_flag,
                                                              ct.complete_flag,
                                                              ctt.type,
                                                              ct.initial_customer_trx_id,
                                                              ct.previous_customer_trx_id
                                                            ) -- activity_flag
                         OR      DECODE(ct.printing_last_printed,
                                        NULL,'N', 'Y')    = 'Y'
                                )
                         and    ct.ship_to_customer_id    = p_customer_id
                         and    ct.ship_to_site_use_id    = i.site_use_id
                       );

           arp_debug.debug(' find existing data meeting existing of trx with posted or with activity or printed for ship_to site');
           arp_debug.debug('transaction_morg_exists RESULT : TRUE  -');
           RETURN (TRUE);
           exit;
--Bug Fix :1552964
           EXCEPTION
             when NO_DATA_FOUND  then
              null;
           END;
       end loop;

       if invoice_count is NULL then
--
         for j in bill_to_site

           loop
             arp_debug.debug(' cursor BILL_TO_SITE site_use_id retrieved:'||j.site_use_id);
             select 'x'
             into   invoice_count
             from   dual
             where  exists ( select 'y'
                             from   ra_cust_trx_types_all         ctt,
                                    ra_customer_trx_lines_all     ctl,
                                    ra_customer_trx_all           ct
                             where  ct.cust_trx_type_id       = ctt.cust_trx_type_id
 			     and    nvl(ct.org_id,-99)        = nvl(ctt.org_id, -99)
                             and    ct.customer_trx_id        = ctl.customer_trx_id
                             and    'TAX'                     = ctl.line_type
                             and    (
                                     'Y'                      = arpt_sql_func_util.get_posted_flag
                                                                ( ct.customer_trx_id,
                                                                  ctt.post_to_gl,
                                                                  ct.complete_flag
                                                                )  -- posted_flag
                             OR      'Y'                      = arpt_sql_func_util.get_activity_flag
                                                                ( ct.customer_trx_id,
                                                                  ctt.accounting_affect_flag,
                                                                  ct.complete_flag,
                                                                  ctt.type,
                                                                  ct.initial_customer_trx_id,
                                                                  ct.previous_customer_trx_id
                                                                ) -- activity_flag
                             OR      DECODE(ct.printing_last_printed,
                                            NULL,'N', 'Y')    = 'Y'
                                    )
                             and    ct.bill_to_customer_id    = p_customer_id
                             and    ct.bill_to_site_use_id    = j.site_use_id
                           );

               arp_debug.debug(' find existing data meeting existing of trx with posted or with activity or printed for bill_to site');
              arp_debug.debug('transaction_morg_exists RESULT : TRUE -');
               RETURN (TRUE);
               exit;

           end loop;
--
       end if;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           arp_debug.debug('No Ship To or Bill To SITE with posted trx or trx with activity or printed invoice');
           arp_debug.debug('transaction_morg_exists RESULT : FALSE  -');
           RETURN (FALSE);
--
    END;

--
  if invoice_count is NULL then
    arp_debug.debug('No Ship To or Bill To SITE found');
    arp_debug.debug('transaction_morg_exists RESULT : FALSE  -');
    RETURN (FALSE);
  end if;
--
END transaction_morg_exists;



--{BUG#4037614
----------------------------
-- This procedure if the updation of a physical location is not allowed
--  and the location has been updated.
--  -> system option setting
--  -> the data of location really updated
--  -> transaction has been printed with this location
----------------------------
PROCEDURE check_printed_trx
(p_location_id   IN NUMBER,
 p_location_rec  IN hz_location_v2pub.location_rec_type,
 x_return_status IN OUT NOCOPY  VARCHAR2,
 x_msg_data      IN OUT NOCOPY  VARCHAR2,
 x_msg_count     IN OUT NOCOPY  NUMBER)
IS
  l_customer_id NUMBER;
  l_address_id  NUMBER;
  l_org_id number;
  --
  invoice_count VARCHAR2(1);
  check_value   VARCHAR2(1);

  -- find all possible customer accounts which use this location
  CURSOR c_cust_addrs IS
     SELECT acct_site.cust_account_id,
            acct_site.cust_acct_site_id
     FROM hz_locations           loc,
          hz_party_sites         party_site,
          hz_cust_acct_sites_all acct_site
     WHERE loc.location_id           =  party_site.location_id
       AND party_site.party_site_id  =  acct_site.party_site_id
       AND loc.location_id           =  p_location_id;
  --
  l_exist_location  hz_location_v2pub.location_rec_type;
  --
/*Bug 4605384*/
/*
  CURSOR c_check IS
  SELECT change_printed_invoice_flag
    FROM ar_system_parameters;
*/
  --
  CURSOR c_org_for_loc IS
     select distinct acct_site.org_id
     from hz_locations      loc,
          hz_party_sites    party_site,
          hz_cust_acct_sites_all acct_site
     where loc.location_id         =   party_site.location_id
     and party_site.party_site_id  =   acct_site.party_site_id
     and loc.location_id =  p_location_id;

  loc_modified  VARCHAR2(1) := 'N';
  AR_NO_ROW_IN_SYSTEM_PARAMETERS   EXCEPTION;
  --
BEGIN
   --Check system option
/*commented for bug 4605384*/
/*
   OPEN c_check;
   FETCH c_check INTO check_value;
   IF c_check%NOTFOUND THEN
     RAISE AR_NO_ROW_IN_SYSTEM_PARAMETERS;
   END IF;
   CLOSE c_check;
*/
/*start Bug 4605384*/
       open c_org_for_loc;
       LOOP
       fetch c_org_for_loc into l_org_id;
       exit when c_org_for_loc%NOTFOUND;
       BEGIN
            select change_printed_invoice_flag
            into   check_value
            from   ar_system_parameters_all where org_id=l_org_id;

       EXCEPTION
       WHEN NO_DATA_FOUND THEN
            close c_org_for_loc;
            RAISE AR_NO_ROW_IN_SYSTEM_PARAMETERS;
       END ;

       if check_value = 'N' then
          exit;
       end if;
       END LOOP;
       close c_org_for_loc;
/*End bug 4605384*/

   arp_debug.debug('  check_value:'||check_value);
   -- if check_value = 'Y' no processing required user can update addresses

   IF check_value = 'N' THEN

     --{BUG#4058539
     compare_location_existing
     (p_location_id   => p_location_id,
      p_location_rec  => p_location_rec,
      x_exist_loc_rec => l_exist_location,
      x_loc_updated   => loc_modified );
     --}
     --
     arp_debug.debug('  loc_modified:'||loc_modified);

     -- any transaction printed with this location
     IF loc_modified = 'Y' THEN
       --
       OPEN c_cust_addrs;
       LOOP
       FETCH c_cust_addrs INTO l_customer_id,
                             l_address_id;
       EXIT WHEN c_cust_addrs%NOTFOUND;

       -- changed to call transaction_morg_exists
       IF transaction_morg_exists(l_address_id,l_customer_id) THEN
         -- transaction existing printed
         x_return_status := fnd_api.g_ret_sts_error;
         FND_MESSAGE.SET_NAME( 'AR','4600');
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);
         EXIT;
       END IF;

       END LOOP;
       CLOSE c_cust_addrs ;

       IF   c_cust_addrs%ISOPEN THEN
         CLOSE  c_cust_addrs;
       END IF;
     END IF;
   END IF;
   --
EXCEPTION
  WHEN AR_NO_ROW_IN_SYSTEM_PARAMETERS THEN
      IF c_org_for_loc%ISOPEN THEN CLOSE c_org_for_loc; END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME( 'AR','AR_NO_ROW_IN_SYSTEM_PARAMETERS');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);
  WHEN OTHERS THEN
      IF c_org_for_loc%ISOPEN THEN CLOSE c_org_for_loc; END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME( 'FND','FND_GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE',SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);
END check_printed_trx;



-- This is a overloaded procedure for check_printed_trx
-- bug#4058539
-- this procedure check_printed_trx
-- Return in the input parameters the existing location data if location exist
-- Return in the x_printed_trx_loc_modified
--      * 'N' : No violation to transaction about the printed invoice on location update
--      * 'Y'  : Violation to transaction about the printed invoice on location update
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
 x_printed_trx_loc_modified  IN OUT  NOCOPY VARCHAR2,
 x_return_status             IN OUT NOCOPY  VARCHAR2,
 x_msg_data                  IN OUT NOCOPY  VARCHAR2,
 x_msg_count                 IN OUT NOCOPY  NUMBER)
IS
  l_customer_id NUMBER;
  l_address_id  NUMBER;
  l_org_id     NUMBER;
  --
  invoice_count VARCHAR2(1);
  check_value   VARCHAR2(1);

  -- find all possible customer accounts which use this location
  CURSOR c_cust_addrs IS
     SELECT acct_site.cust_account_id,
            acct_site.cust_acct_site_id
     FROM hz_locations           loc,
          hz_party_sites         party_site,
          hz_cust_acct_sites_all acct_site
     WHERE loc.location_id           =  party_site.location_id
       AND party_site.party_site_id  =  acct_site.party_site_id
       AND loc.location_id           =  p_location_id;
  --
  l_exist_location  hz_location_v2pub.location_rec_type;
  --
/*Bug 4605384*/
/*
  CURSOR c_check IS
  SELECT change_printed_invoice_flag
    FROM ar_system_parameters;
*/
  CURSOR c_org_for_loc IS
     select distinct acct_site.org_id
     from hz_locations      loc,
          hz_party_sites    party_site,
          hz_cust_acct_sites_all acct_site
     where loc.location_id         =   party_site.location_id
     and party_site.party_site_id  =   acct_site.party_site_id
     and loc.location_id =  p_location_id;
  --
  loc_modified  VARCHAR2(1) := 'N';
  AR_NO_ROW_IN_SYSTEM_PARAMETERS   EXCEPTION;
  --
  l_location_rec   hz_location_v2pub.location_rec_type;
  tmp_var          VARCHAR2(2000);
  tmp_var1         VARCHAR2(2000);
BEGIN
   arp_standard.debug('check_printed_trx +');
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_printed_trx_loc_modified  := 'N';
   --Check system option
/* Commented for bug 4605384*/
/*
   OPEN c_check;
   FETCH c_check INTO check_value;
   IF c_check%NOTFOUND THEN
     RAISE AR_NO_ROW_IN_SYSTEM_PARAMETERS;
   END IF;
   CLOSE c_check;
*/
/*start Bug 4605384*/
       open c_org_for_loc;
       LOOP
       fetch c_org_for_loc into l_org_id;
       exit when c_org_for_loc%NOTFOUND;
       BEGIN
            select change_printed_invoice_flag
            into   check_value
            from   ar_system_parameters_all where org_id=l_org_id;

       EXCEPTION
       WHEN NO_DATA_FOUND THEN
            close c_org_for_loc;
            RAISE AR_NO_ROW_IN_SYSTEM_PARAMETERS;
       END ;

       if check_value = 'N' then
          exit;
       end if;
       END LOOP;
       close c_org_for_loc;
/*End bug 4605384*/
   arp_standard.debug('  check_value:'||check_value);
   -- if check_value = 'Y' no processing required user can update addresses

   IF check_value = 'N' THEN

     compare_location_existing
     (p_location_id              => p_location_id,
      x_Country                  => x_country,
      x_Address1                 => x_address1,
      x_Address2                 => x_address2,
      x_Address3                 => x_address3,
      x_Address4                 => x_address4,
      x_City                     => x_city,
      x_Postal_Code              => x_postal_code,
      x_State                    => x_state,
      x_Province                 => x_province,
      x_County                   => x_county,
      x_description              => x_description,
      x_short_description        => x_short_description,
      x_floor                    => x_floor,
      x_house_number             => x_house_number,
      x_location_directions      => x_location_directions,
      x_postal_plus4_code        => x_postal_plus4_code,
      x_po_box_number            => x_po_box_number,
      x_street                   => x_street,
      x_street_number            => x_street_number,
      x_street_suffix            => x_street_suffix,
      x_suite                    => x_suite,
      x_Language                 => x_language,
      x_Address_Lines_Phonetic   => x_Address_Lines_Phonetic,
      x_Sales_Tax_Geocode        => x_Sales_Tax_Geocode,
      x_Sales_Tax_Inside_City_Limits   => x_Sales_Tax_Inside_City_Limits,
      x_loc_updated              => loc_modified);
     --}
     --
     arp_standard.debug('  loc_modified:'||loc_modified);

     -- any transaction printed with this location
     IF loc_modified = 'Y' THEN
       --
       OPEN c_cust_addrs;
       LOOP
       FETCH c_cust_addrs INTO l_customer_id,
                             l_address_id;
       EXIT WHEN c_cust_addrs%NOTFOUND;

       /* changed to call transaction_morg_exists  */
       IF transaction_morg_exists(l_address_id,l_customer_id) THEN
         -- transaction existing printed
         x_printed_trx_loc_modified := 'Y';
         EXIT;
       END IF;

       END LOOP;
       CLOSE c_cust_addrs ;

       IF   c_cust_addrs%ISOPEN THEN
         CLOSE  c_cust_addrs;
       END IF;
     END IF;
   END IF;
   arp_standard.debug('check_printed_trx -');
   --
EXCEPTION
  WHEN AR_NO_ROW_IN_SYSTEM_PARAMETERS THEN
      IF c_org_for_loc%ISOPEN THEN CLOSE c_org_for_loc; END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME( 'AR','AR_NO_ROW_IN_SYSTEM_PARAMETERS');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);
      arp_standard.debug('EXCEPTION AR_NO_ROW_IN_SYSTEM_PARAMETERS in check_printed_trx');
    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;
  WHEN OTHERS THEN
      IF c_org_for_loc%ISOPEN THEN CLOSE c_org_for_loc; END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME( 'FND','FND_GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE',SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);
      arp_standard.debug('EXCEPTION OTHERS in check_printed_trx :'||SQLERRM);
    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;
END check_printed_trx;


PROCEDURE check_addr_modif_allowed
(p_location_id               IN NUMBER,
 x_loc_modif_allowed         IN OUT NOCOPY  VARCHAR2,
 x_return_status             IN OUT NOCOPY  VARCHAR2,
 x_msg_data                  IN OUT NOCOPY  VARCHAR2,
 x_msg_count                 IN OUT NOCOPY  NUMBER)
IS
  l_customer_id NUMBER;
  l_address_id  NUMBER;
  l_org_id      NUMBER;
  --
  invoice_count VARCHAR2(1);
  check_value   VARCHAR2(1);

  -- find all possible customer accounts which use this location
  CURSOR c_cust_addrs IS
     SELECT acct_site.cust_account_id,
            acct_site.cust_acct_site_id
     FROM hz_locations           loc,
          hz_party_sites         party_site,
          hz_cust_acct_sites_all acct_site
     WHERE loc.location_id           =  party_site.location_id
       AND party_site.party_site_id  =  acct_site.party_site_id
       AND loc.location_id           =  p_location_id;
  --
  l_exist_location  hz_location_v2pub.location_rec_type;
  --
/*Bug 4605384 Changed as per consistency for changes allowed in address*/
 /*
 CURSOR c_check IS
  SELECT change_printed_invoice_flag
    FROM ar_system_parameters;
*/
  CURSOR c_org_for_loc IS
     select distinct acct_site.org_id
     from hz_locations      loc,
          hz_party_sites    party_site,
          hz_cust_acct_sites_all acct_site
     where loc.location_id         =   party_site.location_id
     and party_site.party_site_id  =   acct_site.party_site_id
     and loc.location_id =  p_location_id;

  --
  loc_modified  VARCHAR2(1) := 'N';
  AR_NO_ROW_IN_SYSTEM_PARAMETERS   EXCEPTION;
  --
  l_location_rec   hz_location_v2pub.location_rec_type;
  tmp_var          VARCHAR2(2000);
  tmp_var1         VARCHAR2(2000);
BEGIN
   arp_standard.debug('check_addr_modif_allowed +');
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loc_modif_allowed  := 'Y';
   --Check system option
/*Bug 4605384 as per consistency check for modification of address allowed*/
/*
   OPEN c_check;
   FETCH c_check INTO check_value;
   IF c_check%NOTFOUND THEN
     RAISE AR_NO_ROW_IN_SYSTEM_PARAMETERS;
   END IF;
   CLOSE c_check;
*/
/*start Bug 4605384*/
       open c_org_for_loc;
       LOOP
       fetch c_org_for_loc into l_org_id;
       exit when c_org_for_loc%NOTFOUND;
       BEGIN
            select change_printed_invoice_flag
            into   check_value
            from   ar_system_parameters_all where org_id=l_org_id;

       EXCEPTION
       WHEN NO_DATA_FOUND THEN
            close c_org_for_loc;
            RAISE AR_NO_ROW_IN_SYSTEM_PARAMETERS;
       END ;

       if check_value = 'N' then
          exit;
       end if;
       END LOOP;
       close c_org_for_loc;
/*End bug 4605384*/

   arp_standard.debug('  check_value:'||check_value);
   -- if check_value = 'Y' no processing required user can update addresses

   IF check_value = 'N' THEN

       --
       OPEN c_cust_addrs;
       LOOP
       FETCH c_cust_addrs INTO l_customer_id,
                             l_address_id;
       EXIT WHEN c_cust_addrs%NOTFOUND;

       /* changed to call transaction_morg_exists  */
       IF transaction_morg_exists(l_address_id,l_customer_id) THEN
         -- transaction existing printed
         x_loc_modif_allowed := 'N';
         EXIT;
       END IF;

       END LOOP;
       CLOSE c_cust_addrs ;

       IF   c_cust_addrs%ISOPEN THEN
         CLOSE  c_cust_addrs;
       END IF;

   END IF;
   arp_standard.debug('check_addr_modif_allowed -');
   --
EXCEPTION
  WHEN AR_NO_ROW_IN_SYSTEM_PARAMETERS THEN
      IF c_org_for_loc%ISOPEN THEN CLOSE c_org_for_loc; END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME( 'AR','AR_NO_ROW_IN_SYSTEM_PARAMETERS');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);
      arp_standard.debug('EXCEPTION AR_NO_ROW_IN_SYSTEM_PARAMETERS in check_addr_modif_allowed');
    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;
  WHEN OTHERS THEN
      IF c_org_for_loc%ISOPEN THEN CLOSE c_org_for_loc; END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME( 'FND','FND_GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE',SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);
      arp_standard.debug('EXCEPTION OTHERS in check_addr_modif_allowed :'||SQLERRM);
    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;
END check_addr_modif_allowed;

--}


--{BUG#4058639
-- Take the location_id to return
--    the existing location data in x_exist_loc_rec the column
--      * in the case column to compare between existing and entered are alike
--       the column set to fnd_api.g_miss_char
--      * in the case column to compare between existing and entered are different
--       the column contents the existing value
--    if the location does not exist x_exist_loc_rec is empty record
-- x_loc_updated
--    return 'Y' if the data in p_location_rec is different to the existing location
--    return 'N' if the data in p_location_rec is equal to the existing location
--    return 'X' if the no existing location found
PROCEDURE compare_location_existing
(p_location_id   IN  NUMBER,
 p_location_rec  IN  hz_location_v2pub.location_rec_type,
 x_exist_loc_rec IN OUT NOCOPY hz_location_v2pub.location_rec_type,
 x_loc_updated   IN OUT NOCOPY VARCHAR2)
IS
  CURSOR c_exist_loc IS
  SELECT  loc.country     ,
          loc.address1    ,
          loc.address2    ,
          loc.address3    ,
          loc.address4    ,
          loc.city        ,
          loc.postal_code ,
          loc.state       ,
          loc.province    ,
          loc.county      ,
          loc.language    ,
          loc.address_lines_phonetic,
          loc.description           ,
          loc.short_description     ,
          loc.floor       ,
          loc.house_number,
          loc.location_directions,
          loc.postal_plus4_code,
          loc.po_box_number,
          loc.street       ,
          loc.street_number,
          loc.street_suffix,
          loc.suite        ,
          loc.Sales_Tax_Inside_City_Limits,
          loc.Sales_Tax_Geocode
     FROM hz_locations loc
    WHERE location_id = p_location_id;
  l_location_rec      hz_location_v2pub.location_rec_type;
  loc_modified        VARCHAR2(1) := 'N';
BEGIN
 arp_standard.debug('compare_location_existing +');
 arp_standard.debug('  p_location_id :'||p_location_id);
 IF p_location_id IS NULL THEN
   x_loc_updated := 'X';
 ELSE
   OPEN c_exist_loc;
   FETCH c_exist_loc INTO   l_location_rec.country     ,
                            l_location_rec.address1    ,
                            l_location_rec.address2    ,
                            l_location_rec.address3    ,
                            l_location_rec.address4    ,
                            l_location_rec.city        ,
                            l_location_rec.postal_code ,
                            l_location_rec.state       ,
                            l_location_rec.province    ,
                            l_location_rec.county      ,
                            l_location_rec.language    ,
                            l_location_rec.address_lines_phonetic,
                            l_location_rec.description           ,
                            l_location_rec.short_description     ,
                            l_location_rec.floor       ,
                            l_location_rec.house_number,
                            l_location_rec.location_directions,
                            l_location_rec.postal_plus4_code,
                            l_location_rec.po_box_number,
                            l_location_rec.street       ,
                            l_location_rec.street_number,
                            l_location_rec.street_suffix,
                            l_location_rec.suite        ,
                            l_location_rec.Sales_Tax_Inside_City_Limits,
                            l_location_rec.Sales_Tax_Geocode;
   IF c_exist_loc%FOUND THEN
       arp_standard.debug('  p_location_rec.country :'||p_location_rec.country);
       arp_standard.debug('  l_location_rec.country :'||l_location_rec.country);
       IF   NVL(p_location_rec.country,fnd_api.g_miss_char)  <> NVL(l_location_rec.country,fnd_api.g_miss_char)  THEN
         loc_modified := 'Y';
       ELSE
         l_location_rec.country := ar_miss_char;
       END IF;
       arp_standard.debug('  p_location_rec.address1 :'||p_location_rec.address1);
       arp_standard.debug('  l_location_rec.address1 :'||l_location_rec.address1);
       IF   NVL(p_location_rec.address1,fnd_api.g_miss_char) <> NVL(l_location_rec.address1,fnd_api.g_miss_char) THEN
         loc_modified := 'Y';
       ELSE
         l_location_rec.address1 := ar_miss_char;
       END IF;
       arp_standard.debug('  p_location_rec.address2 :'||p_location_rec.address2);
       arp_standard.debug('  l_location_rec.address2 :'||l_location_rec.address2);
       IF   NVL(p_location_rec.address2,fnd_api.g_miss_char) <> NVL(l_location_rec.address2,fnd_api.g_miss_char) THEN
        loc_modified := 'Y';
       ELSE
         l_location_rec.address2 := ar_miss_char;
       END IF;
       arp_standard.debug('  p_location_rec.address3 :'||p_location_rec.address3);
       arp_standard.debug('  l_location_rec.address3 :'||l_location_rec.address3);
       IF   NVL(p_location_rec.address3,fnd_api.g_miss_char) <> NVL(l_location_rec.address3,fnd_api.g_miss_char) THEN
        loc_modified := 'Y';
       ELSE
         l_location_rec.address3 := ar_miss_char;
       END IF;
       arp_standard.debug('  p_location_rec.address4 :'||p_location_rec.address4);
       arp_standard.debug('  l_location_rec.address4 :'||l_location_rec.address4);
       IF   NVL(p_location_rec.address4,fnd_api.g_miss_char) <> NVL(l_location_rec.address4,fnd_api.g_miss_char) THEN
         loc_modified := 'Y';
       ELSE
         l_location_rec.address4 := ar_miss_char;
       END IF;
       arp_standard.debug('  p_location_rec.city :'||p_location_rec.city);
       arp_standard.debug('  l_location_rec.city :'||l_location_rec.city);
       IF   NVL(p_location_rec.city,fnd_api.g_miss_char)     <> NVL(l_location_rec.city,fnd_api.g_miss_char) THEN
         loc_modified := 'Y';
       ELSE
         l_location_rec.city := ar_miss_char;
       END IF;
       arp_standard.debug('  p_location_rec.postal_code :'||p_location_rec.postal_code);
       arp_standard.debug('  l_location_rec.postal_code :'||l_location_rec.postal_code);
       IF   NVL(p_location_rec.postal_code,fnd_api.g_miss_char) <> NVL(l_location_rec.postal_code,fnd_api.g_miss_char) THEN
         loc_modified := 'Y';
       ELSE
         l_location_rec.postal_code := ar_miss_char;
       END IF;
       arp_standard.debug('  p_location_rec.state :'||p_location_rec.state);
       arp_standard.debug('  l_location_rec.state :'||l_location_rec.state);
       IF   NVL(p_location_rec.state,fnd_api.g_miss_char)    <> NVL(l_location_rec.state,fnd_api.g_miss_char) THEN
         loc_modified := 'Y';
       ELSE
         l_location_rec.state := ar_miss_char;
       END IF;
       arp_standard.debug('  p_location_rec.province :'||p_location_rec.province);
       arp_standard.debug('  l_location_rec.province :'||l_location_rec.province);
       IF   NVL(p_location_rec.province,fnd_api.g_miss_char) <> NVL(l_location_rec.province,fnd_api.g_miss_char) THEN
         loc_modified := 'Y';
       ELSE
         l_location_rec.province := ar_miss_char;
       END IF;
       arp_standard.debug('  p_location_rec.county :'||p_location_rec.county);
       arp_standard.debug('  l_location_rec.county :'||l_location_rec.county);
       IF   NVL(p_location_rec.county,fnd_api.g_miss_char)   <> NVL(l_location_rec.county,fnd_api.g_miss_char) THEN
         loc_modified := 'Y';
       ELSE
         l_location_rec.county := ar_miss_char;
       END IF;
       arp_standard.debug('  p_location_rec.language :'||p_location_rec.language);
       arp_standard.debug('  l_location_rec.language :'||l_location_rec.language);
       IF   NVL(p_location_rec.language,fnd_api.g_miss_char) <> NVL(l_location_rec.language,fnd_api.g_miss_char) THEN
         loc_modified := 'Y';
       ELSE
         l_location_rec.language := ar_miss_char;
       END IF;
       arp_standard.debug('  p_location_rec.address_lines_phonetic :'||p_location_rec.address_lines_phonetic);
       arp_standard.debug('  l_location_rec.address_lines_phonetic :'||l_location_rec.address_lines_phonetic);
       IF   NVL(p_location_rec.address_lines_phonetic,fnd_api.g_miss_char) <> NVL(l_location_rec.address_lines_phonetic,fnd_api.g_miss_char) THEN
         loc_modified := 'Y';
       ELSE
         l_location_rec.address_lines_phonetic:= ar_miss_char;
       END IF;
       arp_standard.debug('  p_location_rec.description :'||p_location_rec.description);
       arp_standard.debug('  l_location_rec.description :'||l_location_rec.description);
       IF   NVL(p_location_rec.description,fnd_api.g_miss_char) <> NVL(l_location_rec.description,fnd_api.g_miss_char) THEN
         loc_modified := 'Y';
       ELSE
         l_location_rec.description:= ar_miss_char;
       END IF;
       arp_standard.debug('  p_location_rec.short_description :'||p_location_rec.short_description);
       arp_standard.debug('  l_location_rec.short_description :'||l_location_rec.short_description);
       IF   NVL(p_location_rec.short_description,fnd_api.g_miss_char) <> NVL(l_location_rec.short_description,fnd_api.g_miss_char) THEN
         loc_modified := 'Y';
       ELSE
         l_location_rec.short_description:= ar_miss_char;
       END IF;
       arp_standard.debug('  p_location_rec.floor :'||p_location_rec.floor);
       arp_standard.debug('  l_location_rec.floor :'||l_location_rec.floor);
       IF   NVL(p_location_rec.floor,fnd_api.g_miss_char)       <> NVL(l_location_rec.floor,fnd_api.g_miss_char) THEN
         loc_modified := 'Y';
       ELSE
         l_location_rec.floor:= ar_miss_char;
       END IF;
       arp_standard.debug('  p_location_rec.house_number :'||p_location_rec.house_number);
       arp_standard.debug('  l_location_rec.house_number :'||l_location_rec.house_number);
       IF   NVL(p_location_rec.house_number,fnd_api.g_miss_char)<> NVL(l_location_rec.house_number,fnd_api.g_miss_char) THEN
         loc_modified := 'Y';
       ELSE
         l_location_rec.house_number:= ar_miss_char;
       END IF;
       arp_standard.debug('  p_location_rec.location_directions :'||p_location_rec.location_directions);
       arp_standard.debug('  l_location_rec.location_directions :'||l_location_rec.location_directions);
       IF   NVL(p_location_rec.location_directions,fnd_api.g_miss_char) <> NVL(l_location_rec.location_directions,fnd_api.g_miss_char) THEN
         loc_modified := 'Y';
       ELSE
         l_location_rec.location_directions:= ar_miss_char;
       END IF;
       arp_standard.debug('  p_location_rec.postal_plus4_code :'||p_location_rec.postal_plus4_code);
       arp_standard.debug('  l_location_rec.postal_plus4_code :'||l_location_rec.postal_plus4_code);
       IF   NVL(p_location_rec.postal_plus4_code,fnd_api.g_miss_char) <> NVL(l_location_rec.postal_plus4_code,fnd_api.g_miss_char) THEN
         loc_modified := 'Y';
       ELSE
         l_location_rec.postal_plus4_code:= ar_miss_char;
       END IF;
       arp_standard.debug('  p_location_rec.po_box_number :'||p_location_rec.po_box_number);
       arp_standard.debug('  l_location_rec.po_box_number :'||l_location_rec.po_box_number);

       IF   NVL(p_location_rec.po_box_number,fnd_api.g_miss_char) <> NVL(l_location_rec.po_box_number,fnd_api.g_miss_char) THEN
         loc_modified := 'Y';
       ELSE
         l_location_rec.po_box_number:= ar_miss_char;
       END IF;

       arp_standard.debug('  p_location_rec.street :'||p_location_rec.street);
       arp_standard.debug('  l_location_rec.street :'||l_location_rec.street);
       IF   NVL(p_location_rec.street,fnd_api.g_miss_char)        <> NVL(l_location_rec.street,fnd_api.g_miss_char) THEN
         loc_modified := 'Y';
       ELSE
         l_location_rec.street:= ar_miss_char;
       END IF;
       arp_standard.debug('  p_location_rec.street_number :'||p_location_rec.street_number);
       arp_standard.debug('  l_location_rec.street_number :'||l_location_rec.street_number);
       IF   NVL(p_location_rec.street_number,fnd_api.g_miss_char) <> NVL(l_location_rec.street_number,fnd_api.g_miss_char) THEN
         loc_modified := 'Y';
       ELSE
         l_location_rec.street_number:= ar_miss_char;
       END IF;
       arp_standard.debug('  p_location_rec.street_suffix :'||p_location_rec.street_suffix);
       arp_standard.debug('  l_location_rec.street_suffix :'||l_location_rec.street_suffix);
       IF   NVL(p_location_rec.street_suffix,fnd_api.g_miss_char) <> NVL(l_location_rec.street_suffix,fnd_api.g_miss_char) THEN
         loc_modified := 'Y';
       ELSE
         l_location_rec.street_suffix := ar_miss_char;
       END IF;
       arp_standard.debug('  p_location_rec.suite :'||p_location_rec.suite);
       arp_standard.debug('  l_location_rec.suite :'||l_location_rec.suite);
       IF   NVL(p_location_rec.suite,fnd_api.g_miss_char)         <> NVL(l_location_rec.suite,fnd_api.g_miss_char)  THEN
         loc_modified := 'Y';
       ELSE
         l_location_rec.suite:= ar_miss_char;
       END IF;
   ELSE
       loc_modified := 'X';
   END IF;
   CLOSE c_exist_loc;
   x_loc_updated := loc_modified;
   x_exist_loc_rec  := l_location_rec;
   arp_standard.debug(' x_loc_updated :'||x_loc_updated);
 END IF;
 arp_standard.debug('compare_location_existing -');
EXCEPTION
  WHEN OTHERS THEN
    IF c_exist_loc%ISOPEN THEN CLOSE c_exist_loc; END IF;
    arp_standard.debug('EXCEPTION OTHERS compare_location_existing :'||SQLERRM);
    RAISE;
END compare_location_existing;

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
 --
 x_loc_updated              IN OUT  NOCOPY VARCHAR2)
IS
  l_location_rec       hz_location_v2pub.location_rec_type;
  l_exist_loc_rec      hz_location_v2pub.location_rec_type;
BEGIN
  arp_standard.debug('compare_location_existing overload +');

  arp_standard.debug('IN VALUES + ');
  arp_standard.debug('   x_Country                  :'|| x_country);
  arp_standard.debug('   x_Address1                 :'|| x_address1);
  arp_standard.debug('   x_Address2                 :'|| x_address2);
  arp_standard.debug('   x_Address3                 :'|| x_address3);
  arp_standard.debug('   x_Address4                 :'|| x_address4);
  arp_standard.debug('   x_City                     :'|| x_city);
  arp_standard.debug('   x_Postal_Code              :'|| x_postal_code);
  arp_standard.debug('   x_State                    :'|| x_state);
  arp_standard.debug('   x_Province                 :'|| x_province);
  arp_standard.debug('   x_County                   :'|| x_county);
  arp_standard.debug('   x_description              :'|| x_description);
  arp_standard.debug('   x_short_description        :'|| x_short_description);
  arp_standard.debug('   x_floor                    :'|| x_floor);
  arp_standard.debug('   x_house_number             :'|| x_house_number);
  arp_standard.debug('   x_location_directions      :'|| x_location_directions);
  arp_standard.debug('   x_postal_plus4_code        :'|| x_postal_plus4_code);
  arp_standard.debug('   x_po_box_number            :'|| x_po_box_number);
  arp_standard.debug('   x_street                   :'|| x_street);
  arp_standard.debug('   x_street_number            :'|| x_street_number);
  arp_standard.debug('   x_street_suffix            :'|| x_street_suffix);
  arp_standard.debug('   x_suite                    :'|| x_suite);
  arp_standard.debug('   x_Language                 :'|| x_language);
  arp_standard.debug('   x_Address_Lines_Phonetic   :'|| x_Address_Lines_Phonetic);
  arp_standard.debug('   x_Sales_Tax_Geocode        :'|| x_sales_tax_geocode);
  arp_standard.debug('   x_Sales_Tax_Inside_City_Limits   :'|| x_Sales_Tax_Inside_City_Limits);
  arp_standard.debug('IN VALUES - ');


  l_location_rec.Country                  := x_country;
  l_location_rec.Address1                 := x_address1;
  l_location_rec.Address2                 := x_address2;
  l_location_rec.Address3                 := x_address3;
  l_location_rec.Address4                 := x_address4;
  l_location_rec.City                     := x_city;
  l_location_rec.Postal_Code              := x_postal_code;
  l_location_rec.State                    := x_state;
  l_location_rec.Province                 := x_province;
  l_location_rec.County                   := x_county;
  l_location_rec.description              := x_description;
  l_location_rec.short_description        := x_short_description;
  l_location_rec.floor                    := x_floor;
  l_location_rec.house_number             := x_house_number;
  l_location_rec.location_directions      := x_location_directions;
  l_location_rec.postal_plus4_code        := x_postal_plus4_code;
  l_location_rec.po_box_number            := x_po_box_number;
  l_location_rec.street                   := x_street;
  l_location_rec.street_number            := x_street_number;
  l_location_rec.street_suffix            := x_street_suffix;
  l_location_rec.suite                    := x_suite;
  l_location_rec.Language                 := x_language;
  l_location_rec.Address_Lines_Phonetic   := x_Address_Lines_Phonetic;
  l_location_rec.Sales_Tax_Geocode        := x_Sales_Tax_Geocode;
  l_location_rec.Sales_Tax_Inside_City_Limits := x_Sales_Tax_Inside_City_Limits;

  compare_location_existing
  (p_location_id   => p_location_id,
   p_location_rec  => l_location_rec,
   x_exist_loc_rec => l_exist_loc_rec,
   x_loc_updated   => x_loc_updated);

  IF x_loc_updated = 'Y' THEN
    x_country               :=  l_exist_loc_rec.Country;
    x_address1              :=  l_exist_loc_rec.Address1;
    x_address2              :=  l_exist_loc_rec.Address2;
    x_address3              :=  l_exist_loc_rec.Address3;
    x_address4              :=  l_exist_loc_rec.Address4;
    x_city                  :=  l_exist_loc_rec.City;
    x_postal_code           :=  l_exist_loc_rec.Postal_Code;
    x_state                 :=  l_exist_loc_rec.State;
    x_province              :=  l_exist_loc_rec.Province;
    x_county                :=  l_exist_loc_rec.County;
    x_description           :=  l_exist_loc_rec.description;
    x_short_description     :=  l_exist_loc_rec.short_description;
    x_floor                 :=  l_exist_loc_rec.floor;
    x_house_number          :=  l_exist_loc_rec.house_number;
    x_location_directions   :=  l_exist_loc_rec.location_directions;
    x_postal_plus4_code     :=  l_exist_loc_rec.postal_plus4_code;
    x_po_box_number         :=  l_exist_loc_rec.po_box_number;
    x_street                :=  l_exist_loc_rec.street;
    x_street_number         :=  l_exist_loc_rec.street_number;
    x_street_suffix         :=  l_exist_loc_rec.street_suffix;
    x_suite                 :=  l_exist_loc_rec.suite;
    x_language              :=  l_exist_loc_rec.Language;
    x_Address_Lines_Phonetic :=  l_exist_loc_rec.Address_Lines_Phonetic;
    x_Sales_Tax_Geocode     :=  l_exist_loc_rec.Sales_Tax_Geocode;
    x_Sales_Tax_Inside_City_Limits :=  l_exist_loc_rec.Sales_Tax_Inside_City_Limits;
  END IF;
  arp_standard.debug('OUT VALUES + ');
  arp_standard.debug('   x_Country                  :'|| x_country);
  arp_standard.debug('   x_Address1                 :'|| x_address1);
  arp_standard.debug('   x_Address2                 :'|| x_address2);
  arp_standard.debug('   x_Address3                 :'|| x_address3);
  arp_standard.debug('   x_Address4                 :'|| x_address4);
  arp_standard.debug('   x_City                     :'|| x_city);
  arp_standard.debug('   x_Postal_Code              :'|| x_postal_code);
  arp_standard.debug('   x_State                    :'|| x_state);
  arp_standard.debug('   x_Province                 :'|| x_province);
  arp_standard.debug('   x_County                   :'|| x_county);
  arp_standard.debug('   x_description              :'|| x_description);
  arp_standard.debug('   x_short_description        :'|| x_short_description);
  arp_standard.debug('   x_floor                    :'|| x_floor);
  arp_standard.debug('   x_house_number             :'|| x_house_number);
  arp_standard.debug('   x_location_directions      :'|| x_location_directions);
  arp_standard.debug('   x_postal_plus4_code        :'|| x_postal_plus4_code);
  arp_standard.debug('   x_po_box_number            :'|| x_po_box_number);
  arp_standard.debug('   x_street                   :'|| x_street);
  arp_standard.debug('   x_street_number            :'|| x_street_number);
  arp_standard.debug('   x_street_suffix            :'|| x_street_suffix);
  arp_standard.debug('   x_suite                    :'|| x_suite);
  arp_standard.debug('   x_Language                 :'|| x_language);
  arp_standard.debug('   x_Address_Lines_Phonetic   :'|| x_Address_Lines_Phonetic);
  arp_standard.debug('   x_Sales_Tax_Geocode        :'|| x_sales_tax_geocode);
  arp_standard.debug('   x_Sales_Tax_Inside_City_Limits   :'|| x_Sales_Tax_Inside_City_Limits);
  arp_standard.debug('OUT VALUES - ');

  arp_standard.debug('compare_location_existing overload -');
END compare_location_existing;


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
 x_msg_count     IN OUT NOCOPY  NUMBER)
IS
  l_exist_loc_rec   hz_location_v2pub.LOCATION_REC_TYPE;
  tmp_var           VARCHAR2(2000);
  tmp_var1          VARCHAR2(2000);
BEGIN
   hz_location_v2pub.get_location_rec(
    p_location_id      => p_location_id,
    x_location_rec     => l_exist_loc_rec,
    x_return_status    => x_return_status,
    x_msg_count        => x_msg_count,
    x_msg_data         => x_msg_data);

    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;

    x_country               :=  l_exist_loc_rec.Country;
    x_address1              :=  l_exist_loc_rec.Address1;
    x_address2              :=  l_exist_loc_rec.Address2;
    x_address3              :=  l_exist_loc_rec.Address3;
    x_address4              :=  l_exist_loc_rec.Address4;
    x_city                  :=  l_exist_loc_rec.City;
    x_postal_code           :=  l_exist_loc_rec.Postal_Code;
    x_state                 :=  l_exist_loc_rec.State;
    x_province              :=  l_exist_loc_rec.Province;
    x_county                :=  l_exist_loc_rec.County;
    x_description           :=  l_exist_loc_rec.description;
    x_short_description     :=  l_exist_loc_rec.short_description;
    x_floor                 :=  l_exist_loc_rec.floor;
    x_house_number          :=  l_exist_loc_rec.house_number;
    x_location_directions   :=  l_exist_loc_rec.location_directions;
    x_postal_plus4_code     :=  l_exist_loc_rec.postal_plus4_code;
    x_po_box_number         :=  l_exist_loc_rec.po_box_number;
    x_street                :=  l_exist_loc_rec.street;
    x_street_number         :=  l_exist_loc_rec.street_number;
    x_street_suffix         :=  l_exist_loc_rec.street_suffix;
    x_suite                 :=  l_exist_loc_rec.suite;
    x_address_key           :=  l_exist_loc_rec.Address_Key;
    x_language              :=  l_exist_loc_rec.Language;
    x_Address_Lines_Phonetic :=  l_exist_loc_rec.Address_Lines_Phonetic;
    x_Sales_Tax_Geocode     :=  l_exist_loc_rec.Sales_Tax_Geocode;
    x_Sales_Tax_Inside_City_Limits :=  l_exist_loc_rec.Sales_Tax_Inside_City_Limits;

END get_location_data;


FUNCTION the_ar_miss_char RETURN VARCHAR2 IS
BEGIN
  RETURN ar_miss_char;
END;

FUNCTION the_ar_null_char RETURN VARCHAR2 IS
BEGIN
  RETURN ar_null_char;
END;

--}

FUNCTION check_tran_for_all_accts(p_location_id in number
) return BOOLEAN
IS
   l_customer_id number;
   l_address_id number;
   l_org_id     number;

--
invoice_count varchar2(1);
check_value    varchar2(1);

   -- find all possible customer accounts which use this location
   cursor c_cust_addrs is
     select acct_site.cust_account_id, acct_site.cust_acct_site_id
     from hz_locations      loc,
          hz_party_sites    party_site,
          hz_cust_acct_sites_all acct_site
     where loc.location_id         =   party_site.location_id
     and party_site.party_site_id  =   acct_site.party_site_id
     and loc.location_id =  p_location_id;
/*bug 4605384 cursor for loc*/
     cursor c_org_for_loc is
     select distinct acct_site.org_id
     from hz_locations      loc,
          hz_party_sites    party_site,
          hz_cust_acct_sites_all acct_site
     where loc.location_id         =   party_site.location_id
     and party_site.party_site_id  =   acct_site.party_site_id
     and loc.location_id =  p_location_id;
BEGIN


  BEGIN

      -- check  the flag: allow change to printed transaction  is set to 'Y' or 'N'
      -- If it is set to 'Y', exit the function and customers are able to update the address
      -- If it is set to 'N', then check whether printed or posted transaction exits for
      -- bill-to or ship-to site,and the transaction has been applied
      -- and the transaction has any txa lines, if yes for above conditions, restrict update
      -- for customers on address component..

      -- Note : This FUNCTION could have lived without customer_id argument i.e site_use_id
      --        was enough but then it would have meant to create two new indexes on :
      --        bill_to_site_use_id and ship_to_site_use_id. We have avoided this by using
      --        site_use_id (bill/ship) in conjunction with customer_id.


/*start Bug 4605384*/
       open c_org_for_loc;
       LOOP
       fetch c_org_for_loc into l_org_id;
       exit when c_org_for_loc%NOTFOUND;
       BEGIN
            select change_printed_invoice_flag
            into   check_value
            from   ar_system_parameters_all where org_id=l_org_id;

--Bug fix 2183072 Handled the exception.
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME( 'AR','AR_NO_ROW_IN_SYSTEM_PARAMETERS');
             FND_MSG_PUB.ADD;
       END ;

       if check_value = 'N' then
          exit;
       end if;
       END LOOP;
      --
       close c_org_for_loc;
       if check_value='Y' then
          return(FALSE);
       end if;
/*End bug 4605384*/
   open c_cust_addrs;
    LOOP
     fetch c_cust_addrs into
      l_customer_id,
      l_address_id;
     exit when c_cust_addrs%notfound;

/* changed to call transaction_morg_exists  */
      if transaction_morg_exists(l_address_id,l_customer_id) then
          return (TRUE);  -- null;  -- transaction exists
      else -- transaction exists for the location
          return (FALSE);  -- transaction does not exists
      end if;

    END LOOP;
   close c_cust_addrs ;

   -- return (TRUE);
      return (FALSE);  -- transaction does not exists

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
     NULL;
  END;

END check_tran_for_all_accts;


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

	  select  count(1)
	  into    dummy
	  from    hz_cust_acct_sites addr
	  where   addr.cust_account_id        = p_customer_id
	  and     addr.ece_tp_location_code   = p_edi_location
	  and     addr.orig_system_reference <> p_orig_system_reference;
	--
	  if ( dummy >=1 ) then
	    fnd_message.set_name('AR','AR_CUST_ADDR_EDI_LOC_EXISTS');
	    app_exception.raise_exception;
	  end if;
	--
	end check_unique_edi_location;
	--

	END arh_addr_pkg;

/
