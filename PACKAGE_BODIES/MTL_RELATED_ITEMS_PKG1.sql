--------------------------------------------------------
--  DDL for Package Body MTL_RELATED_ITEMS_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_RELATED_ITEMS_PKG1" as
/* $Header: INVISRIB.pls 120.3 2005/08/16 04:28:23 anmurali noship $ */


FUNCTION site_to_address(X_site_id IN NUMBER) return varchar2 IS
  address_name varchar2(240);
BEGIN

   if X_site_id is null then
      return null;
   end if;

 /* Changing the query as RA_ADDRESSES has been scrapped -Anmurali
   select raa.address1
   into address_name
   from ra_addresses_all raa,
        ra_site_uses_all rasu
   where  rasu.site_use_id = X_site_id
     and  raa.address_id = rasu.address_id; */

     SELECT LOC.ADDRESS1
     INTO ADDRESS_NAME
     FROM HZ_PARTY_SITES PARTY_SITE, HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
          HZ_LOCATIONS LOC, HZ_CUST_ACCT_SITES_ALL ACCT_SITE , HZ_CUST_SITE_USES_ALL SITE_USER
     WHERE SITE_USER.SITE_USE_ID = X_site_id
       AND ACCT_SITE.CUST_ACCT_SITE_ID = SITE_USER.CUST_ACCT_SITE_ID
       AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
       AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
       AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
       AND NVL(ACCT_SITE.ORG_ID, -99) = NVL(LOC_ASSIGN.ORG_ID, -99)
       AND NVL(SITE_USER.ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB( USERENV('CLIENT_INFO'),1,1),' ', NULL,
                                                     SUBSTRB( USERENV('CLIENT_INFO'),1,10))),-99)) =
                                NVL(TO_NUMBER(DECODE(SUBSTRB( USERENV('CLIENT_INFO'),1,1),' ', NULL,
				                     SUBSTRB( USERENV( 'CLIENT_INFO'),1,10))),-99);


   return address_name;

EXCEPTION when no_data_found THEN
    return null;

END site_to_address;

END MTL_RELATED_ITEMS_PKG1;

/
