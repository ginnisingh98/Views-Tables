--------------------------------------------------------
--  DDL for Package Body HZ_ACT_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ACT_UTIL_PUB" AS
/* $Header: ARHACUIB.pls 120.1 2005/05/25 14:59:39 dmmehta noship $ */

function get_active_act_site_use(
    p_act_site_id                         IN     NUMBER) RETURN VARCHAR2 IS

  l_site_use_purpose    VARCHAR2(100);
  l_top5_site_use_purposes    VARCHAR2(2000) := '';
  l_count                     NUMBER := 0;

  cursor c_site_use_purposes (l_act_site_id  IN NUMBER) is
  select al.MEANING
  from hz_cust_acct_sites asite,
       hz_cust_site_uses asu,
       ar_lookups  al
  where asite.cust_acct_site_id = l_act_site_id
  and   asu.status = 'A'
  and   asu.cust_acct_site_id = asite.cust_acct_site_id
  and   al.lookup_type  = 'SITE_USE_CODE'
  and   al.lookup_code  =  asu.site_use_code
  order by primary_flag DESC;

BEGIN

  OPEN c_site_use_purposes(p_act_site_id);
  LOOP
  FETCH c_site_use_purposes INTO l_site_use_purpose;

    IF c_site_use_purposes%NOTFOUND THEN
      EXIT;
    END IF;


    IF l_count = 5 THEN
      l_top5_site_use_purposes := concat(l_top5_site_use_purposes, ', ... ');
      EXIT;
    END IF;

    IF l_top5_site_use_purposes is not null THEN
      l_top5_site_use_purposes := concat(l_top5_site_use_purposes, ', ');
    END IF;

    l_top5_site_use_purposes := concat(l_top5_site_use_purposes, l_site_use_purpose);

    l_count := l_count + 1;
  END LOOP;
  CLOSE c_site_use_purposes;

  RETURN l_top5_site_use_purposes;


end get_active_act_site_use;

function get_all_act_site_use(
    p_act_site_id                         IN     NUMBER) RETURN VARCHAR2 IS

  l_site_use_purpose    VARCHAR2(100);
  l_top5_site_use_purposes    VARCHAR2(2000) := '';
  l_count                     NUMBER := 0;

  cursor c_site_use_purposes (l_act_site_id  IN NUMBER) is
  select al.MEANING
  from hz_cust_acct_sites asite,
       hz_cust_site_uses asu,
       ar_lookups  al
  where asite.cust_acct_site_id = l_act_site_id
  and   asu.cust_acct_site_id = asite.cust_acct_site_id
  and   al.lookup_type  = 'SITE_USE_CODE'
  and   al.lookup_code  =  asu.site_use_code
  order by primary_flag DESC, asu.status ASC ;

BEGIN

  OPEN c_site_use_purposes(p_act_site_id);
  LOOP
  FETCH c_site_use_purposes INTO l_site_use_purpose;

    IF c_site_use_purposes%NOTFOUND THEN
      EXIT;
    END IF;


    IF l_count = 5 THEN
      l_top5_site_use_purposes := concat(l_top5_site_use_purposes, ', ...');
      EXIT;
    END IF;

    IF l_top5_site_use_purposes is not null THEN
      l_top5_site_use_purposes := concat(l_top5_site_use_purposes, ', ');
    END IF;

    l_top5_site_use_purposes := concat(l_top5_site_use_purposes, l_site_use_purpose);

    l_count := l_count + 1;
  END LOOP;
  CLOSE c_site_use_purposes;

  RETURN l_top5_site_use_purposes;

end get_all_act_site_use;

function get_location_id (
    p_act_site_id                         IN     NUMBER) RETURN NUMBER IS

   l_location_id HZ_PARTY_SITES.location_id%type := NULL;
begin

   select ps.location_id into l_location_id
   from hz_party_sites ps, hz_cust_acct_sites  asite
   where ps.party_site_id = asite.party_site_id
   and  asite.cust_acct_site_id = p_act_site_id;

  RETURN l_location_id;

  exception
  when no_data_found then
  return null;
  when others then return null;


end get_location_id;

function get_act_contact_roles(
    p_cust_account_role_id                   IN     NUMBER) RETURN VARCHAR2 IS

  l_contact_role    VARCHAR2(100);
  l_top5_contact_roles   VARCHAR2(2000) := '';
  l_count                     NUMBER := 0;

-- Account CPUI : Modify to get roles for INACTIVE contact also
  cursor c_get_act_contact_roles (l_cust_account_role_id  IN NUMBER) is
  select al.MEANING
  from --hz_cust_account_roles roles,
       hz_role_responsibility role_type,
       ar_lookups  al
  where role_type.cust_account_role_id = l_cust_account_role_id
--  and   roles.cust_account_role_id = role_type.cust_account_role_id
  and   al.lookup_type = 'SITE_USE_CODE'
  and   al.lookup_code = role_type.responsibility_type
  order by role_type.primary_flag DESC;

BEGIN

  OPEN c_get_act_contact_roles(p_cust_account_role_id);
  LOOP
  FETCH c_get_act_contact_roles INTO l_contact_role;

    IF c_get_act_contact_roles%NOTFOUND THEN
      EXIT;
    END IF;


    IF l_count = 5 THEN
      l_top5_contact_roles := concat(l_top5_contact_roles, ', ...');
      EXIT;
    END IF;

    IF l_top5_contact_roles is not null THEN
      l_top5_contact_roles := concat(l_top5_contact_roles, ', ');
    END IF;

    l_top5_contact_roles := concat(l_top5_contact_roles, l_contact_role);

    l_count := l_count + 1;
  END LOOP;
  CLOSE c_get_act_contact_roles;

  RETURN l_top5_contact_roles;


end get_act_contact_roles;


END HZ_ACT_UTIL_PUB;

/
