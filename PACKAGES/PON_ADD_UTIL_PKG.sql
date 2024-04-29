--------------------------------------------------------
--  DDL for Package PON_ADD_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_ADD_UTIL_PKG" AUTHID CURRENT_USER as
/*$Header: PONADDUTS.pls 120.0 2005/06/01 13:55:39 appldev noship $ */

--This ref cursor type is used for any cursors we need to pass out
--to Java.

HZ_FAIL_EXCEPTION EXCEPTION;

type hrAddrRecTyp IS RECORD (
  address_name  	HR_LOCATIONS.location_code%TYPE
, address1      	HR_LOCATIONS.address_line_1%TYPE
, address2      	HR_LOCATIONS.address_line_2%TYPE
, city         		HR_LOCATIONS.town_or_city%TYPE
, state  		HR_LOCATIONS.region_2%TYPE
, province  		HR_LOCATIONS.region_3%TYPE
, zip  			HR_LOCATIONS.postal_code%TYPE
, postal_code  		HR_LOCATIONS.postal_code%TYPE
, country  		HR_LOCATIONS.country%TYPE
, county       		HR_LOCATIONS.region_1%TYPE
, bill_to_site_flag  	HR_LOCATIONS.bill_to_site_flag%TYPE
, ship_to_site_flag  	HR_LOCATIONS.ship_to_site_flag%TYPE
, mail_to_site_flag  	HR_LOCATIONS.receiving_site_flag%TYPE
);

type tcaAddrRecTyp IS RECORD (
  address_name  HZ_PARTY_SITES.party_site_name%TYPE
, address1      HZ_LOCATIONS.address1%TYPE
, address2      HZ_LOCATIONS.address2%TYPE
, city  HZ_LOCATIONS.city%TYPE
, state  HZ_LOCATIONS.state%TYPE
, province  HZ_LOCATIONS.province%TYPE
, zip  HZ_LOCATIONS.postal_plus4_code%TYPE
, postal_code  HZ_LOCATIONS.postal_code%TYPE
, country  HZ_LOCATIONS.country%TYPE
, county       HZ_LOCATIONS.county%TYPE
, over_sea_flag 	HZ_LOCATIONS.overseas_address_flag%TYPE
, bill_to_site_flag	VARCHAR2(1)
, ship_to_site_flag	VARCHAR2(1)
, mail_to_site_flag	VARCHAR2(1));

type hrRefAddressCurTyp is Ref Cursor RETURN hrAddrRecTyp;

type tcaRefAddressCurTyp is Ref Cursor RETURN tcaAddrRecTyp;


PROCEDURE retrieve_hr_address (
  p_location_id 	IN NUMBER
, x_address 		OUT NOCOPY hrRefAddressCurTyp
, x_status		OUT NOCOPY VARCHAR2
, x_exception_msg	OUT NOCOPY VARCHAR2
);

PROCEDURE retrieve_tca_address (
  p_location_id 	IN NUMBER
, x_address 		OUT NOCOPY tcaRefAddressCurTyp
, x_status		OUT NOCOPY VARCHAR2
, x_exception_msg	OUT NOCOPY VARCHAR2
);

PROCEDURE retrieve_hr_location_code (
  p_location_id 	IN NUMBER
, p_language    	IN VARCHAR2
, x_address_name 	OUT NOCOPY VARCHAR2
);

END PON_ADD_UTIL_PKG;

 

/
