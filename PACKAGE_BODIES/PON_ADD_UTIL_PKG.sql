--------------------------------------------------------
--  DDL for Package Body PON_ADD_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_ADD_UTIL_PKG" as
/*$Header: PONADDUTB.pls 120.0 2005/06/01 14:09:45 appldev noship $ */

-- Given location id, retrieve the address information

PROCEDURE retrieve_hr_address (
  p_location_id IN NUMBER
, x_address OUT NOCOPY hrRefAddressCurTyp
, x_status	OUT NOCOPY VARCHAR2
, x_exception_msg	OUT NOCOPY VARCHAR2
)
IS

BEGIN

  OPEN x_address FOR

  SELECT
    hl.location_code
  , hl.address_line_1
  , hl.address_line_2
  , hl.town_or_city
  , hl.region_2
  , hl.region_3
  , hl.postal_code
  , hl.postal_code
  , hl.country
  , hl.region_1
  , hl.bill_to_site_flag
  , hl.ship_to_site_flag
  , hl.receiving_site_flag

  FROM hr_locations hl

  WHERE hl.location_id = p_location_id;

  x_status  :='S';
  x_exception_msg       :=NULL;

EXCEPTION

    WHEN OTHERS THEN
      x_status  :='U';
      x_exception_msg  := 'no such location id';
      --dbms_output.put_line('Other failure -- '||x_exception_msg);

    RAISE;

END retrieve_hr_address;

PROCEDURE retrieve_tca_address (
  p_location_id IN NUMBER
, x_address OUT NOCOPY tcaRefAddressCurTyp
, x_status	OUT NOCOPY VARCHAR2
, x_exception_msg	OUT NOCOPY VARCHAR2
)

IS
   l_exception_msg           varchar2(100);
   l_bill_to      	hz_party_site_uses.SITE_USE_TYPE%TYPE;
   l_ship_to    	hz_party_site_uses.SITE_USE_TYPE%TYPE;
   l_mail_to	      	hz_party_site_uses.SITE_USE_TYPE%TYPE;

BEGIN

  l_bill_to := 'BILL_TO';
  l_ship_to := 'SHIP_TO';
  l_mail_to := 'GENERAL_MAIL_TO';

  OPEN x_address FOR

  SELECT
    hps.party_site_name
  , hl.ADDRESS1
  , hl.ADDRESS2
  , hl.CITY
  , hl.STATE
  , hl.PROVINCE
  , hl.POSTAL_PLUS4_CODE
  , hl.POSTAL_CODE
  , hl.COUNTRY
  , hl.county
  , hl.overseas_address_flag
  , DECODE (hpsu_bill_to.site_use_type, l_bill_to,'Y','N')
  , DECODE (hpsu_ship_to.site_use_type, l_ship_to,'Y','N')
  , DECODE (hpsu_mail_to.site_use_type, l_mail_to,'Y','N')

  FROM hz_locations hl
  , hz_party_sites hps
  , hz_party_site_uses hpsu_ship_to
  , hz_party_site_uses hpsu_bill_to
  , hz_party_site_uses hpsu_mail_to

  WHERE hl.location_id = p_location_id
  AND   hps.location_id = hl.location_id
  AND   hpsu_ship_to.party_site_id(+) = hps.party_site_id
  AND   hpsu_ship_to.site_use_type(+) = l_ship_to
  AND   hpsu_bill_to.party_site_id(+) = hps.party_site_id
  AND   hpsu_bill_to.site_use_type(+) = l_bill_to
  AND   hpsu_mail_to.party_site_id(+) = hps.party_site_id
  AND   hpsu_mail_to.site_use_type(+) = l_mail_to

  ORDER by hps.party_site_name;

  X_STATUS  :='S';
  x_exception_msg       :=NULL;
EXCEPTION

    WHEN OTHERS THEN
      --dbms_output.put_line('Other failure -- '||x_exception_msg);
      X_STATUS  :='U';
      RAISE;

END retrieve_tca_address;

PROCEDURE retrieve_hr_location_code (
  p_location_id IN NUMBER
, p_language    IN VARCHAR2
, x_address_name OUT NOCOPY VARCHAR2
)

IS

BEGIN

  SELECT location_code
  INTO   x_address_name
  FROM   hr_locations_all_tl
  WHERE  location_id = p_location_id
  AND    language = p_language;

END retrieve_hr_location_code;

--we do not need store functionality at this time
--PROCEDURE store_hr_address()
--PROCEDURE store_tca_address()

END PON_ADD_UTIL_PKG;

/
