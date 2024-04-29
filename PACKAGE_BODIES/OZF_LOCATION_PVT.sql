--------------------------------------------------------
--  DDL for Package Body OZF_LOCATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_LOCATION_PVT" as
/* $Header: ozfvlocb.pls 120.1 2005/09/15 19:47:45 appldev ship $ */

g_pkg_name   CONSTANT VARCHAR2(30):='OZF_LOCATION_PVT';

FUNCTION ozfx_format_address( address_style IN VARCHAR2,
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
   -- address1 is a NOT NULL field.
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
END ozfx_format_address;

/*--------------------------------------------------------------------+
PUBLIC FUNCTION
  format_address

DESCRIPTION
  This function returns a single string of concatenated address
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
    return( ozfx_format_address(   address_style,
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



-- the following is not needed right now but may be useful later. CHECK WHILE CODING.
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


FUNCTION get_location (p_location_id         IN NUMBER,
                       p_cust_site_use_code  IN VARCHAR2 := NULL)
         return VARCHAR2 IS

 CURSOR locations (c_location_id NUMBER) IS
   SELECT
      loc.address_style, loc.address1, loc.address2, loc.address3, loc.address4, loc.city,
      loc.county, loc.state, loc.province, loc.postal_code, terr.territory_short_name
   FROM
      hz_locations loc,
      fnd_territories_vl terr
   WHERE
       loc.location_id = c_location_id
   AND loc.country = terr.territory_code(+);

 locations_rec locations%rowtype;
 l_cust_site_use_code ozf_account_allocations.site_use_code%TYPE;

BEGIN
 OPEN locations (p_location_id);
 FETCH locations into locations_rec;
 CLOSE locations;

 IF p_cust_site_use_code IS NULL THEN

    return( ozfx_format_address(   locations_rec.address_style,
                                   locations_rec.address1,
                                   locations_rec.address2,
                                   locations_rec.address3,
                                   locations_rec.address4,
                                   locations_rec.city,
                                   locations_rec.county,
                                   locations_rec.state,
                                   locations_rec.province,
                                   locations_rec.postal_code,
                                   locations_rec.territory_short_name ) );

 ELSE

    l_cust_site_use_code := INITCAP(LOWER(p_cust_site_use_code));

    return( l_cust_site_use_code || ': '||
            ozfx_format_address(   locations_rec.address_style,
                                   locations_rec.address1,
                                   locations_rec.address2,
                                   locations_rec.address3,
                                   locations_rec.address4,
                                   locations_rec.city,
                                   locations_rec.county,
                                   locations_rec.state,
                                   locations_rec.province,
                                   locations_rec.postal_code,
                                   locations_rec.territory_short_name ) );

 END IF;

END get_location;


FUNCTION get_location_id (p_site_use_id      IN NUMBER)
         return NUMBER IS

 CURSOR location_csr
  IS
  SELECT
    hzps.location_id   location_id
  FROM
    hz_cust_site_uses_all hzcsu,
    hz_cust_acct_sites_all hzcas,
    hz_party_sites hzps
  WHERE
        hzcsu.site_use_id = p_site_use_id
    AND hzcsu.cust_acct_site_id = hzcas.cust_acct_site_id
    AND hzcas.party_site_id = hzps.party_site_id;

 -- The following is commented because _all tables are not used
 -- Instead org-striped views are used
 ---- AND hzcas.org_id = p_org_id
 ---- AND hzcsu.org_id = p_org_id;

 l_location_id  NUMBER;
 l_site_use_id  NUMBER;
 l_api_name      CONSTANT VARCHAR2(30) := 'get_location_id';
 l_full_api_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

BEGIN
 l_site_use_id := p_site_use_id;

 OPEN location_csr;
 FETCH location_csr into l_location_id;
 CLOSE location_csr;

 return l_location_id;

EXCEPTION
     WHEN OTHERS THEN
          OZF_UTILITY_PVT.debug_message(l_full_api_name||' : OTHERS EXCEPTION = '||sqlerrm(sqlcode));
     return NULL;
END get_location_id;


FUNCTION get_party_name(p_party_id    IN NUMBER,
                        p_site_use_id IN NUMBER)
  RETURN VARCHAR2
  IS
    x_party_name   VARCHAR2(250);
    x_location     VARCHAR2(250);
  BEGIN

/*
      SELECT hz.party_name||' '||hzcsu.location into x_party_name
        FROM hz_parties hz,
             hz_cust_site_uses_all hzcsu
       WHERE hzcsu.site_use_id = p_site_use_id
         AND hz.party_id = p_party_id;
*/
    BEGIN
      SELECT hz.party_name into x_party_name
        FROM hz_parties hz
       WHERE hz.party_id = p_party_id;
    EXCEPTION
       WHEN OTHERS THEN
           x_party_name := TO_CHAR(p_party_id);
    END;
    IF p_party_id = -9999 THEN
       x_party_name := fnd_message.get_string('OZF', 'OZF_TP_UNALLOC_ACCOUNT_TXT');
    END IF;
    BEGIN
      SELECT hzcsu.location into x_location
        FROM hz_cust_site_uses_all hzcsu
       WHERE hzcsu.site_use_id = p_site_use_id;
    EXCEPTION
       WHEN OTHERS THEN
           x_location := TO_CHAR(p_site_use_id);
    END;

    RETURN x_party_name||' '||x_location;
  EXCEPTION
     WHEN OTHERS THEN
          --RETURN 'Target Sausalito (OPS)';
          RETURN NULL;
  END;


END ozf_location_pvt;

/
