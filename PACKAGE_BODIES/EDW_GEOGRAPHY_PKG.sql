--------------------------------------------------------
--  DDL for Package Body EDW_GEOGRAPHY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_GEOGRAPHY_PKG" AS
/* $Header: poafkge.pkb 120.1 2005/06/13 12:37:19 sriswami noship $  */

  Function HR_Location_fk
               (p_location_id in NUMBER,
                p_instance_code in VARCHAR2 :=NULL) return VARCHAR2 IS

  l_location VARCHAR2(240) := 'NA_EDW';
  l_instance VARCHAR2(30)  := NULL;

  BEGIN
      IF(p_location_id is NULL) then
        return 'NA_EDW';
      END IF;

      IF (p_instance_code is NOT NULL) then
        l_instance := p_instance_code;
      ELSE
        select instance_code into l_instance
          from edw_local_instance;
      END IF;

      l_location := p_location_id || '-' || l_instance
                                  || '-' || 'HR_LOC';

      return l_location;

  EXCEPTION
        when others then

	return 'NA_EDW';

  END HR_Location_fk;


  Function HZ_Postcode_City_fk
                    (p_location_id in NUMBER) return VARCHAR2 IS

  l_postcode_city VARCHAR2(240) := 'NA_EDW';
  l_city VARCHAR2(60);
  l_postal_code VARCHAR2(60);
  l_state VARCHAR2(60);
  l_country VARCHAR2(60);

  BEGIN
      IF(p_location_id is NULL) then
        return 'NA_EDW';
      END IF;

      select city, postal_code, decode(state, null, province, state), country
      into   l_city, l_postal_code, l_state, l_country
      from   hz_locations
      where  location_id = p_location_id;

      l_postcode_city := l_city || '-' || l_postal_code || '-' ||
                         l_state || '-' || l_country;

      return l_postcode_city;

  EXCEPTION
      when others then

      return 'NA_EDW';

  END HZ_Postcode_City_fk;

/* This API returns the PK in Party Site for this customer site use id
   by joining to HZ_CUST_ACCT_SITES_ALL to get party_site_id */

  Function Customer_Site_Location_fk
               (p_site_use_id   in NUMBER,
                p_instance_code in VARCHAR2 :=NULL) return VARCHAR2 IS

  l_location VARCHAR2(240) := 'NA_EDW';
  l_instance VARCHAR2(30)  := NULL;
  l_party_site_id NUMBER   := NULL;

  BEGIN

      IF(p_site_use_id is NULL) then
        return 'NA_EDW';
      END IF;

      IF (p_instance_code is NOT NULL) then

        l_instance := p_instance_code;

      ELSE

        select instance_code into l_instance
          from edw_local_instance;

      END IF;

      select party_site_id into l_party_site_id
        from HZ_CUST_ACCT_SITES_ALL     hcas,
             HZ_CUST_SITE_USES_ALL      hcsu
       where hcsu.site_use_id = p_site_use_id
         and hcsu.cust_acct_site_id = hcas.cust_acct_site_id;


      l_location := l_party_site_id || '-' || l_instance
                                    || '-' || 'PARTY_SITE';

      return l_location;


  EXCEPTION
        when others then

	return 'NA_EDW';

  END Customer_Site_Location_fk;



  Function Supplier_Site_Location_fk
               (p_vendor_site_id in NUMBER,
                p_org_id         in NUMBER,
                p_instance_code  in VARCHAR2 :=NULL) return VARCHAR2 IS

  l_location VARCHAR2(240) := 'NA_EDW';
  l_instance VARCHAR2(30)  := NULL;

  BEGIN

      IF(p_vendor_site_id is NULL) then
        return 'NA_EDW';
      END IF;

      IF (p_instance_code is NOT NULL) then
        l_instance := p_instance_code;
      ELSE
        select instance_code into l_instance
          from edw_local_instance;
      END IF;

      l_location := p_vendor_site_id || '-' || p_org_id
                                     || '-' || l_instance
                                     || '-' || 'SUPPLIER_SITE';

      return l_location;

  EXCEPTION
        when others then

	return 'NA_EDW';

  END Supplier_Site_Location_fk;


/* For 11.5, new customer model, used by CRM */
  Function Party_Site_Location_fk
               (p_party_site_id in NUMBER,
                p_instance_code in VARCHAR2 :=NULL) return VARCHAR2 IS

  l_location VARCHAR2(240) := 'NA_EDW';
  l_instance VARCHAR2(30)  := NULL;

  BEGIN

      IF(p_party_site_id is NULL) then
        return 'NA_EDW';
      END IF;

      IF (p_instance_code is NOT NULL) then
        l_instance := p_instance_code;
      ELSE
        select instance_code into l_instance
          from edw_local_instance;
      END IF;

      l_location := p_party_site_id || '-' || l_instance
                                    || '-' || 'PARTY_SITE';

      return l_location;

  EXCEPTION
        when others then

	return 'NA_EDW';

  END Party_Site_Location_fk;


END; --package body

/
