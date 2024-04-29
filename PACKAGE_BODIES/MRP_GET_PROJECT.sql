--------------------------------------------------------
--  DDL for Package Body MRP_GET_PROJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_GET_PROJECT" AS
	/* $Header: MRPGPRJB.pls 120.2 2005/08/18 03:30:40 gmalhotr noship $*/
FUNCTION 	project (arg_project_id 	IN NUMBER)
			return varchar2 IS
			var_project_num		VARCHAR2(30);
			cursor C1 is
				select	segment1
				from	pa_projects_all
				where 	project_id = arg_project_id
				union
				select	project_number
				from	mrp_seiban_numbers
				where 	project_id = arg_project_id;

BEGIN

	IF arg_project_id is null THEN
		return null;
	END IF;

	OPEN C1;
	LOOP
		FETCH C1 INTO var_project_num;
		EXIT;
	END LOOP;

	return var_project_num;
END project;

FUNCTION 	task 	(arg_task_id 	IN NUMBER)
			return varchar2 IS
			var_task_num		varchar2(25);
BEGIN
	IF arg_task_id is null THEN
		return null;
	END IF;

	select	task_number
	into	var_task_num
	from	pa_tasks
	where	task_id = arg_task_id;

	return var_task_num;
END task;

FUNCTION 	planning_group (arg_project_id 	IN NUMBER)
			return varchar2 IS
			var_plng_grp		varchar2(30);
BEGIN

	IF arg_project_id is null THEN
		return null;
	END IF;

	select	DISTINCT planning_group
	into	var_plng_grp
	from	mrp_project_parameters
	where	project_id = arg_project_id;

	return var_plng_grp;
END planning_group;


FUNCTION    lookup_fnd  (arg_lookup_type IN varchar2, arg_lookup_code IN varchar2)
                   return fnd_lookups.meaning%type IS
                   meaning_text fnd_lookups.meaning%type;
        CURSOR c1 is
               select meaning
               from   fnd_lookups
               where  lookup_type = arg_lookup_type and lookup_code = arg_lookup_code;
BEGIN
        IF arg_lookup_code is null or arg_lookup_code is null THEN
           return null;
        END IF;
        OPEN c1;
        FETCH c1 into meaning_text;
        CLOSE c1;
        return meaning_text;

EXCEPTION WHEN OTHERS THEN
        IF c1%ISOPEN THEN
           CLOSE c1;
        END IF;
        return null;
END lookup_fnd;

FUNCTION lookup_meaning(arg_lookup_type IN varchar2,
                        arg_lookup_code IN NUMBER) return varchar2 IS
meaning_text varchar2(80);
BEGIN
   select lv.meaning
   into meaning_text
   from mfg_lookups lv
   where   lv.lookup_type = arg_lookup_type
   and   lv.lookup_code = arg_lookup_code;

     return meaning_text;

EXCEPTION when no_data_found THEN
    return null;
END lookup_meaning;

FUNCTION org_code(arg_org_id IN NUMBER) return varchar2 IS
  org_code varchar2(3);
BEGIN

   if arg_org_id is null then
      return null;
   end if;
   select organization_code
   into org_code
   from mtl_parameters
   where  organization_id = arg_org_id;

   return org_code;

EXCEPTION when no_data_found THEN
    return null;
END org_code;

FUNCTION item_name(arg_org_id IN NUMBER,
                       arg_item_id IN NUMBER) return varchar2 IS
  item_text varchar2(40);
BEGIN

   if arg_org_id is null or
      arg_item_id is null then
      return null;
   end if;
   select concatenated_segments
   into item_text
   from mtl_system_items_kfv
   where  organization_id = arg_org_id
     and  inventory_item_id = arg_item_id;

   return item_text;

EXCEPTION when no_data_found THEN
    return null;
END item_name;

FUNCTION item_desc(arg_org_id IN NUMBER,
                       arg_item_id IN NUMBER) return varchar2 IS
  item_desc varchar2(240);
BEGIN

   if arg_org_id is null or
      arg_item_id is null then
      return null;
   end if;
   select description
   into item_desc
   from mtl_system_items_kfv
   where  organization_id = arg_org_id
     and  inventory_item_id = arg_item_id;

   return item_desc;

EXCEPTION when no_data_found THEN
    return null;
END item_desc;

FUNCTION category_desc(arg_cat_set_id IN NUMBER,
                       arg_cat_id IN NUMBER) return varchar2 IS
  category_desc varchar2(240);
BEGIN

   if arg_cat_set_id is null or
      arg_cat_id is null then
      return null;
   end if;
   select mcvl.description
   into category_desc
   from mtl_categories_vl mcvl,
        mtl_category_sets mcs
   where  mcs.category_set_id = arg_cat_set_id
     and  mcs.structure_id = mcvl.structure_id
     and  mcvl.category_id = arg_cat_id;


   return category_desc;

EXCEPTION when no_data_found THEN
    return null;
END category_desc;

FUNCTION category_name(arg_cat_id IN NUMBER) return varchar2 IS
  category_name varchar2(122);
BEGIN

   if arg_cat_id is null then
      return null;
   end if;
   select concatenated_segments
   into category_name
   from mtl_categories_kfv
   where  category_id = arg_cat_id;

   return category_name;

EXCEPTION when no_data_found THEN
    return null;
END category_name;

FUNCTION customer_name(arg_cust_id IN NUMBER) return varchar2 IS
  cust_name varchar2(255);
BEGIN

   if arg_cust_id is null then
      return null;
   end if;
   select P.party_name
   into cust_name
   from HZ_CUST_ACCOUNTS  A,
        HZ_PARTIES P
   where  A.cust_account_id = arg_cust_id
   AND    A.PARTY_ID = P.PARTY_ID ;

   return cust_name;

EXCEPTION when no_data_found THEN
    return null;
END customer_name;

FUNCTION ship_to_address(arg_site_id IN NUMBER) return varchar2 IS
  address_name varchar2(240);
BEGIN

   if arg_site_id is null then
      return null;
   end if;
   select A.address1
   into address_name
   from   hz_locations A,
          HZ_PARTY_SITES PS1,
          HZ_CUST_ACCT_SITES_ALL AS1,
          hz_cust_site_uses_all SU
   where  SU.site_use_id = arg_site_id
    AND SU.CUST_ACCT_SITE_ID = AS1.CUST_ACCT_SITE_ID
    AND AS1.PARTY_SITE_ID = PS1.PARTY_SITE_ID
    AND PS1.LOCATION_ID = A.LOCATION_ID ;
   return address_name;

EXCEPTION when no_data_found THEN
    return null;
END ship_to_address;

FUNCTION vendor_site_code(arg_org_id IN NUMBER,
                          arg_vendor_site_id IN NUMBER) return varchar2 IS
   v_vendor_site_code po_vendor_sites_all.vendor_site_code%type;
BEGIN

   IF arg_vendor_site_id IS NULL THEN
      RETURN(NULL);
   END IF;

   SELECT vendor_site_code INTO v_vendor_site_code
   FROM po_vendor_sites_all site,
        org_organization_definitions ood
   WHERE site.vendor_site_id = arg_vendor_site_id
   AND     nvl(site.org_id,nvl(ood.operating_unit,-1)) =
                                 nvl(ood.operating_unit,-1)
   AND     ood.organization_id = arg_org_id;


   RETURN(v_vendor_site_code);

EXCEPTION when no_data_found THEN
    return NULL;
END vendor_site_code;

END;

/
