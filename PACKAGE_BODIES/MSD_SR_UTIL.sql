--------------------------------------------------------
--  DDL for Package Body MSD_SR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_SR_UTIL" AS
/* $Header: msdutilb.pls 120.8 2006/07/04 12:17:38 sjagathe noship $ */

/* Public Constants */
NULL_VALUE_CONST constant varchar2(10) := 'Other';
NULL_VALUE_PK_CONST constant number := -777;
ALL_CHANNELS_CONST constant varchar(20) := 'All Channels';
ALL_CHANNELS_PK_CONST constant number := -5 ;
ALL_GEOGRAPHY_CONST constant varchar(20) := 'All Geography';
ALL_GEOGRAPHY_PK_CONST constant number := -3 ;
ALL_ORGANIZATIONS_CONST constant varchar(20) := 'All Organizations';
ALL_ORGANIZATIONS_PK_CONST constant number := -2 ;
ALL_PRODUCTS_CONST constant varchar(20) := 'All Products';
ALL_PRODUCTS_PK_CONST constant number := -1 ;
ALL_SALESREP_CONST constant varchar(20) := 'All Sales Rep';
ALL_SALESREP_PK_CONST constant number := -4 ;

ALL_DEMANDCLASS_CONST constant varchar(20) := 'All Demand Class';
ALL_DEMANDCLASS_PK_CONST constant number := -6 ;

SUPPLIERS_CONST constant varchar2(20) := 'Suppliers'; --jarorad
SUPPLIERS_PK_CONST constant number := -999; --jarorad

/* For Liability */
ALL_SUPPLIER_PK_CONST constant number := -3 ; ---vinekuma
ALL_AUTHORIZATION_PK_CONST  constant number := -6 ; ----vinekuma


C_YES constant number := 1;
C_NO  constant number := 2;


/* BOM ITEM TYPE */
C_MODEL           constant number := 1;
C_OPTION_CLASS    constant number := 2;
C_PLANNING        constant number := 3;
C_STANDARD        constant number := 4;
C_PRODUCT_FAMILY  constant number := 5;



/* Public Functions */

/*  This function is not being used in anywhere.
function org(p_org_id in NUMBER) return VARCHAR2 IS
l_org VARCHAR2(240);
BEGIN

 if p_org_id is NULL then
    return 'Other';
 end if;

-- DWK Replaced by the following sql stmt. Performance Tunned
-- select organization_name
-- into l_org
-- from org_organization_definitions
-- where organization_id = p_org_id;

 select name
 into l_org
 from HR_ORGANIZATION_UNITS
 where organization_id = p_org_id;

 return l_org;

EXCEPTION when others then return NULL;

END org;
*/

function item(p_item_id in NUMBER, p_org_id in NUMBER) return VARCHAR2 IS
l_item VARCHAR2(40);
BEGIN
 if p_item_id is NULL then return 'Other'; end if;
 if p_org_id is NULL then
  select concatenated_segments
  into l_item
  from mtl_system_items_kfv
  where inventory_item_id = p_item_id AND organization_id is NULL;
 else
  select concatenated_segments
  into l_item
  from mtl_system_items_kfv
  where inventory_item_id = p_item_id AND organization_id = p_org_id;
 end if;
 return l_item;

EXCEPTION when others then return NULL;

END item;

function cust(p_cust_id in NUMBER) return VARCHAR2 IS
l_cust varchar2(50);
BEGIN
 if p_cust_id is NULL then return 'Other'; end if;

 --Bug 4585376 - RA_CUSTOMERS replaced by HZ_PARTIES and HZ_CUST_ACCOUNTS
   select substrb(PARTY.PARTY_NAME,1,50) customer_name
   into l_cust
   from HZ_PARTIES PARTY, HZ_CUST_ACCOUNTS CUST_ACCT
   WHERE CUST_ACCT.PARTY_ID = PARTY.PARTY_ID
   and CUST_ACCT.CUST_ACCOUNT_ID = p_cust_id;

 return l_cust;

EXCEPTION when others then return NULL;

END cust;

function schn(p_schn_id in VARCHAR2) return VARCHAR2 IS
BEGIN
 return NVL(p_schn_id, 'Other');

EXCEPTION when others then return NULL;

END schn;

function srep(p_srep_id in NUMBER, p_org_id in NUMBER) return VARCHAR2 IS
l_ret varchar2(240);
BEGIN
 if p_srep_id is NULL then return 'Other'; end if;
 select name
 into l_ret
 from ra_salesreps_all
 where (salesrep_id = p_srep_id) AND
   ((org_id is NULL) OR (org_id = p_org_id));
 return l_ret;

EXCEPTION when others then return NULL;

END srep;

-- slightly modified version of edw source.
function uom_conv (uom_code varchar2,
                   item_id  number)   return number as

     base_uom                varchar2(3);
     conv_rate                number:=1;
     l_master_org            number;
     l_master_uom                varchar2(3);

    cursor base_uom_code_conversion(p_item_id number, p_uom_code varchar2) is
        select  t.conversion_rate      std_conv_rate
        from  mtl_uom_conversions t
        where t.inventory_item_id in (p_item_id, 0)
        and   t.uom_code= p_uom_code
        and   nvl(t.disable_date, trunc(sysdate) + 1) > trunc(sysdate)
	and   t.conversion_rate is not null
        order by t.inventory_item_id desc;

begin

    /*
    ** Conversion between between two UOMS.
    **
    ** 1. The conversion always starts from the conversion defined, if exists,
    **    for an specified item.
    ** 2. If the conversion id not defined for that specific item, then the
    **    standard conversion, which is defined for all items, is used.
    */

/*
         open base_uom_code_conversion(item_id, uom_code);
         fetch base_uom_code_conversion into conv_rate;
         close base_uom_code_conversion;
*/

      select to_number(parameter_value)
      into l_master_org
      from msd_setup_parameters
      where parameter_name = 'MSD_MASTER_ORG';

     select NVL(primary_uom_code,'Ea')
     into   l_master_uom
     from mtl_system_items
     where inventory_item_id = item_id
     and   organization_id = l_master_org;

     conv_rate := inv_convert.inv_um_convert(item_id,NULL,NULL,uom_code,l_master_uom,NULL,NULL);

     if (conv_rate = -99999) then
        conv_rate := 1;
     end if;

    return conv_rate;


  exception

       when others then

          return 1;

 end uom_conv;

function get_item_cost(p_item_id in number, p_org_id in number) return number IS
l_ret number;
BEGIN
 if p_item_id is null then return NULL; end if;
 select list_price_per_unit
 into l_ret
 from mtl_system_items
 where (p_item_id = inventory_item_id) and
   ((organization_id = p_org_id) OR (organization_id is null));
 return l_ret;

EXCEPTION when others then return NULL;

END get_item_cost;

function convert_global_amt(p_curr_code in varchar2, p_date in date) return number IS
l_ret number;
c_global_currency_code varchar2(40);
c_global_rate_type varchar2(40);
BEGIN

select parameter_value
into c_global_currency_code
from msd_setup_parameters
where parameter_name = 'MSD_CURRENCY_CODE';

select parameter_value
into c_global_rate_type
from msd_setup_parameters
where parameter_name = 'MSD_CONVERSION_TYPE';

 if (p_curr_code = c_global_currency_code) then
  l_ret := 1;
 else
  l_ret := GL_CURRENCY_API.convert_amount_sql (
    p_curr_code,
    c_global_currency_code,
    p_date,
    c_global_rate_type,
    1
  );
 end if;
 return l_ret;

EXCEPTION when others then return NULL;

END convert_global_amt;

function shipped_date(p_departure_id in number) return date IS
l_ret date;
BEGIN
 if p_departure_id is null then return null; end if;
 select actual_departure_date
 into l_ret
 from wsh_departures
 where departure_id = p_departure_id;
 return l_ret;

EXCEPTION when others then return NULL;

END shipped_date ;

function booked_date(p_header_id in number) return date IS
l_ret date;
BEGIN
--  The commented out code was used at one point; however, now OE's datamodel
--  has changed, they added the booked_date column to their base table
--  and it is just more convenient to go directly their. However, just in case
--  I'm saving the old code. mostrovs. 02/17/00
--
--  SELECT end_date
--  INTO l_ret
--  FROM wf_item_activity_statuses
--  WHERE item_type = OE_GLOBALS.G_WFI_HDR
--    AND item_key = p_header_id
--    AND process_activity IN (SELECT wpa.instance_id
--                         FROM  wf_process_activities wpa
--                         WHERE wpa.activity_item_type = OE_GLOBALS.G_WFI_HDR
--                         AND wpa.activity_name = 'BOOK_ORDER');
--
select booked_date
into l_ret
from oe_order_headers_all
where header_id = p_header_id;
return l_ret;

EXCEPTION when others then return NULL;

END Booked_Date;


function location(p_loc_id in number) return varchar2 IS
l_ret varchar2(240);
BEGIN
 if p_loc_id is null then return 'Other'; end if;

 --Bug 4585376 RA_CUSTOMERS, RA_ADDRESSES_ALL and RA_SITE_USES_ALL replaced by HZ_CUST_SITE_USES_ALL, HZ_CUST_ACCOUNTS, HZ_PARTIES and HZ_CUST_ACCT_SITES_ALL
   select substrb(hp.PARTY_NAME,1,50) || '-' || csu.location
   into  l_ret
   from HZ_CUST_SITE_USES_ALL csu,
        HZ_CUST_ACCOUNTS ca,
	HZ_PARTIES hp,
	HZ_CUST_ACCT_SITES_ALL cas
   where csu.site_use_id = p_loc_id
   and csu.cust_acct_site_id = cas.cust_acct_site_id
   and cas.cust_account_id = ca.cust_account_id
   and ca.cust_account_id = hp.party_id;

 return l_ret;

EXCEPTION when others then return NULL;

END location;

function Master_Organization return number is
x_master_org  number;
x_product_group_type varchar2(1) ;
x_out boolean;
begin

  begin

  select fpg.MULTI_ORG_FLAG into x_product_group_type
  from fnd_product_groups fpg
  where fpg.product_group_type='Standard' ;

  exception

    when others then
	x_product_group_type := 'Y' ;

  end ;

    /* Get the profile option MSD_MASTER_ORG */

        x_master_org := fnd_profile.value('MSD_MASTER_ORG') ;

  if (x_product_group_type = 'Y') then
    if (x_master_org is NULL) then
        select organization_id into x_master_org
        from mtl_parameters
        where organization_id = master_organization_id
        and   rownum < 2 ;
    end if;

     /* Single Master Organization OE Instance */
  else
        select organization_id into x_master_org
        from mtl_parameters
        where organization_id = master_organization_id
        and   rownum < 2 ;
  end if;


  return x_master_org ;


EXCEPTION when others then return NULL;

End Master_Organization ;

/* Bug# 4157588 */
function Item_Organization return varchar2 is
x_item_org varchar2(255);

begin

  /* Get the profile option MSD_ITEM_ORG */

  x_item_org := fnd_profile.value('MSD_ITEM_ORG') ;

  return x_item_org;

  exception

    when others then return NULL;

End Item_Organization ;

function get_category_set_id return number is
x_cat_set_id  number;
begin

    /* Get the profile option MSD_CATEGORY_SET_NAME */

        x_cat_set_id := fnd_profile.value('MSD_CATEGORY_SET_NAME') ;

  return x_cat_set_id ;

  exception

    when others then return NULL;

end get_category_set_id;


function get_conversion_type return varchar2 is
x_conv_type  varchar2(100);
begin

    /* Get the profile option MSD_CONVERSION_TYPE */

        x_conv_type := fnd_profile.value('MSD_CONVERSION_TYPE') ;

  return x_conv_type;

  exception

    when others then return NULL;

end get_conversion_type;

function get_customer_attr return varchar2 is
x_cust_attr  varchar2(100);
begin

    /* Get the profile option MSD_CUSTOMER_ATTRIBUTE */

        x_cust_attr := fnd_profile.value('MSD_CUSTOMER_ATTRIBUTE') ;

  return x_cust_attr;

  exception

    when others then return NULL;

end get_customer_attr;



function get_null_pk return number IS
BEGIN
 return NULL_VALUE_PK_CONST;
END;

function get_null_desc return VARCHAR2 IS
BEGIN
 return get_dimension_desc('MSD_DIM_ALL_DESC','OTH');
END;

function get_all_scs_pk return number IS
BEGIN
 return ALL_CHANNELS_PK_CONST ;
END;

function get_all_scs_desc return VARCHAR2 IS
BEGIN
  return get_dimension_desc('MSD_DIM_ALL_DESC','CHN');
END;

function get_all_geo_pk return number IS
BEGIN
 return ALL_GEOGRAPHY_PK_CONST ;
END;

function get_all_geo_desc return VARCHAR2 IS
BEGIN
 return get_dimension_desc('MSD_DIM_ALL_DESC','GEO');
END;

function get_all_org_pk return number IS
BEGIN
 return ALL_ORGANIZATIONS_PK_CONST ;
END;

function get_all_org_desc return VARCHAR2 IS
BEGIN
 return get_dimension_desc('MSD_DIM_ALL_DESC','ORG');
END;

function get_all_prd_pk return number IS
BEGIN
 return ALL_PRODUCTS_PK_CONST ;
END;

function get_all_prd_desc return VARCHAR2 IS
BEGIN
  return get_dimension_desc('MSD_DIM_ALL_DESC','PRD');
END;

function get_all_rep_pk return number IS
BEGIN
 return ALL_SALESREP_PK_CONST ;
END;

function get_all_rep_desc return VARCHAR2 IS
BEGIN
  return get_dimension_desc('MSD_DIM_ALL_DESC','REP');
END;

function get_all_dcs_pk return number IS
BEGIN
 return ALL_DEMANDCLASS_PK_CONST ;
END;

function get_all_dcs_desc return VARCHAR2 IS
BEGIN
  return get_dimension_desc('MSD_DIM_ALL_DESC','DCS');
END;


FUNCTION get_dimension_desc(p_type varchar2,
                            p_code varchar2) return VARCHAR2 IS


CURSOR c_dim_desc(l_type varchar2, l_code varchar2) IS
select meaning from fnd_lookup_values
where lookup_type = l_type
and language = userenv('LANG')
and lookup_code = l_code;

l_dim_desc   varchar2(240) := NULL;

BEGIN

   OPEN  c_dim_desc(p_type, p_code);
   FETCH c_dim_desc INTO l_dim_desc;
   CLOSE c_dim_desc;

   IF l_dim_desc is NULL THEN
      RETURN p_code;
   ELSE
      RETURN l_dim_desc;
   END IF;

END get_dimension_desc;



FUNCTION IS_ITEM_OPTIONAL_FOR_LVL(p_component_item_id  in  NUMBER) RETURN NUMBER IS

CURSOR c_optional IS
select 1
from
   msd_app_instance_orgs     morg,
   bom_bill_of_materials     bbm,
   mtl_system_items          msi,  -- Parent
   bom_inventory_components  bic
where
   bic.bill_sequence_id = bbm.bill_sequence_id
   and bbm.organization_id = morg.organization_id
   and msi.organization_id = bbm.organization_id
   and msi.inventory_item_id = bbm.assembly_item_id
   and msi.bom_item_type not in (C_PLANNING, C_STANDARD, C_PRODUCT_FAMILY)
   and bic.optional = C_YES
   and ( msi.bom_item_type = 2 or
         ( msi.bom_item_type = 1 and msi.ato_forecast_control in (1, 2) )
       )
   and bic.component_item_id = p_component_item_id;

l_count NUMBER := 0;


BEGIN

   IF p_component_item_id is NOT NULL THEN
      OPEN c_optional;
      FETCH c_optional INTO l_count;
      CLOSE c_optional;
   END IF;

   IF l_count = 0 THEN
      return C_NO;
   ELSE
      return C_YES;
   END IF;

END IS_ITEM_OPTIONAL_FOR_LVL;


/* Bug# 4157588 */
FUNCTION IS_ITEM_OPTIONAL_FOR_LVL(p_component_item_id  in  NUMBER, p_org_id in NUMBER) RETURN NUMBER IS

CURSOR c_optional IS
select 1
from
   msd_app_instance_orgs     morg,
   bom_bill_of_materials     bbm,
   mtl_system_items          msi,  -- Parent
   bom_inventory_components  bic
where
   bic.bill_sequence_id = bbm.bill_sequence_id
   and bbm.organization_id = morg.organization_id
   and msi.organization_id = bbm.organization_id
   and msi.inventory_item_id = bbm.assembly_item_id
   and msi.bom_item_type not in (C_PLANNING, C_STANDARD, C_PRODUCT_FAMILY)
   and bic.optional = C_YES
   and ( msi.bom_item_type = 2 or
         ( msi.bom_item_type = 1 and msi.ato_forecast_control in (1, 2) )
       )
   and bic.component_item_id = p_component_item_id
   and bbm.organization_id = p_org_id;

l_count NUMBER := 0;


BEGIN

   IF p_component_item_id is NOT NULL THEN
      OPEN c_optional;
      FETCH c_optional INTO l_count;
      CLOSE c_optional;
   END IF;

   IF l_count = 0 THEN
      return C_NO;
   ELSE
      return C_YES;
   END IF;

END IS_ITEM_OPTIONAL_FOR_LVL;



/* We only execute this funciton when items in OM has
   ato_forecast_control = NONE
   First, we check whether the given component is
   optional component in the BOM or not.
   IF so, then find the parent's component sequence id
   and then check whether the parent is either
   (optional with forecast control = none or
   consume and drive)
*/

FUNCTION IS_ITEM_OPTIONAL_FOR_FACT(p_component_item_id  in  NUMBER,
                                   p_component_sequence_id in NUMBER,
                                   p_parent_line_id        in NUMBER) RETURN NUMBER IS


l_component_seq_id          NUMBER := p_component_sequence_id;
l_parent_component_seq_id   NUMBER := NULL;


CURSOR c_optional IS
select 1
from
   msd_app_instance_orgs     morg,
   bom_bill_of_materials     bbm,
   mtl_system_items          msi,   -- Parent
   bom_inventory_components  bic
where
   bic.component_sequence_id = l_component_seq_id
   and bic.bill_sequence_id = bbm.bill_sequence_id
   and bbm.organization_id = morg.organization_id
   and msi.organization_id = bbm.organization_id
   and msi.inventory_item_id = bbm.assembly_item_id
   and msi.bom_item_type not in (C_PLANNING, C_STANDARD, C_PRODUCT_FAMILY)
   and bic.optional = C_YES;



CURSOR c_parent_item IS
select component_sequence_id
from   oe_order_lines_all
where  line_id = p_parent_line_id;


/* The parent of optional item has to be
   either consume and drive or
   none with optional = YES */

CURSOR c_parent_optional IS
select 1
from
   msd_app_instance_orgs     morg,
   bom_bill_of_materials     bbm,
   mtl_system_items          msi,
   bom_inventory_components  bic
where
   bic.bill_sequence_id = bbm.bill_sequence_id
   and bbm.organization_id = morg.organization_id
   and msi.organization_id = bbm.organization_id
   and msi.inventory_item_id = bic.component_item_id
   and
   ( (msi.ato_forecast_control = 3 and   bic.optional = C_YES)
      or
      msi.ato_forecast_control in (1, 2)
   )
   and bic.component_sequence_id = l_component_seq_id;

l_count  NUMBER := 0;

BEGIN


   IF l_component_seq_id IS NOT NULL THEN
      OPEN c_optional;
      FETCH c_optional INTO l_count;
      CLOSE c_optional;
      IF (l_count <> 0 and p_parent_line_id is not null) THEN

         IF (p_parent_line_id is not null) THEN
            OPEN c_parent_item;
            FETCH c_parent_item INTO l_parent_component_seq_id;
            CLOSE c_parent_item;

            l_component_seq_id := l_parent_component_seq_id;

            IF l_component_seq_id IS NOT NULL THEN
               OPEN  c_parent_optional;
               FETCH c_parent_optional INTO l_count;
               CLOSE c_parent_optional;
            END IF;
         END IF;
      ELSE  /* if there was no parent_line_id then return NO */
         l_count := 0;
      END IF;
   END IF;

   IF l_count = 0 THEN
      return C_NO;
   ELSE
      return C_YES;
   END IF;

END IS_ITEM_OPTIONAL_FOR_FACT;


/*
FUNCTION FIND_PARENT_FOR_PTO(  p_comp_seq_id     IN NUMBER,
                               p_link_to_line_id IN NUMBER,
                               p_include_class   IN VARCHAR2) RETURN NUMBER IS


CURSOR c_parent IS
SELECT assemb.assembly_item_id, msi.bom_item_type
FROM bom_bill_of_materials assemb,
     bom_inventory_components  comp,
     mtl_system_items          msi
WHERE
     assemb.bill_sequence_id = comp.bill_sequence_id
     and comp.component_sequence_id = p_comp_seq_id
     and assemb.assembly_item_id = msi.inventory_item_id
     and assemb.organization_id = msi.organization_id;

l_parent_id   NUMBER := NULL;
l_bom_item_type  NUMBER := NULL;

BEGIN

   OPEN c_parent;
   FETCH c_parent INTO l_parent_id, l_bom_item_type;
   CLOSE c_parent;

   IF (l_parent_id is not null AND l_bom_item_type is not null) THEN

      IF p_include_class = 'N' THEN

         IF l_bom_item_type = C_OPTION_CLASS THEN
            l_parent_id := FIND_PARENT_ITEM(p_link_to_line_id, p_include_class);
         END IF;

      END IF;

      return l_parent_id;

   ELSE

      return -1;

   END IF;


END FIND_PARENT_FOR_PTO;

*/



FUNCTION FIND_PARENT_ITEM (p_link_to_line_id  in  NUMBER,
                           p_include_class    in  varchar2) RETURN NUMBER IS


l_line_id  NUMBER := p_link_to_line_id;

CURSOR c_parent_id IS
select
inventory_item_id, item_type_code, link_to_line_id, ato_line_id
from oe_order_lines_all
where line_id = l_line_id;

l_item_type_code   VARCHAR2(10);
l_parent_item_id   NUMBER := NULL;
l_link_to_line_id  NUMBER := 0;
l_ato_line_id      NUMBER := 0;
b_loop             BOOLEAN := TRUE;

BEGIN

   WHILE (b_loop) LOOP
      IF (p_include_class = 'Y') THEN
         b_loop := FALSE;
      END IF;

      IF (l_line_id is not NULL) THEN
         OPEN  c_parent_id;
         FETCH c_parent_id INTO l_parent_item_id, l_item_type_code, l_link_to_line_id, l_ato_line_id;
         CLOSE c_parent_id;

         IF (l_item_type_code = 'CLASS' and
             (nvl(l_ato_line_id, -999)  <>  l_line_id) ) THEN
            l_line_id := l_link_to_line_id;
         ELSE
            b_loop := FALSE;
         END IF;
      ELSE
         b_loop := FALSE;
      END IF;
   END LOOP;

   return l_parent_item_id;

END FIND_PARENT_ITEM;




FUNCTION IS_PRODUCT_FAMILY_FORECASTABLE (p_org_id  in  NUMBER,
                                         p_inventory_item_id in  NUMBER,
                                         p_check_optional in NUMBER) RETURN NUMBER IS


CURSOR c_count IS
SELECT
count(1)
FROM
mtl_system_items parent,
bom_inventory_components bic,
bom_bill_of_materials bom
WHERE
parent.bom_item_type = 5 and
parent.organization_id = bom.organization_id and
bom.ASSEMBLY_ITEM_ID = parent.inventory_item_id and
bom.bill_sequence_id = bic.bill_sequence_id and
bic.component_item_id = p_inventory_item_id and
bom.organization_id = p_org_id and
nvl(parent.ato_forecast_control, 3) <> 3;

l_count NUMBER := 0;
l_optional NUMBER := C_NO;

BEGIN

   OPEN c_count;
   FETCH c_count INTO l_count;
   IF c_count%ISOPEN THEN
      CLOSE c_count;
   END IF;

   IF l_count > 0 THEN
      return C_YES;
   ELSE
      IF p_check_optional = C_YES THEN
         l_optional := IS_ITEM_OPTIONAL_FOR_LVL(p_inventory_item_id);
      END IF;

      IF l_optional = C_YES THEN
         return C_YES;
      ELSE
         return C_NO;
      END IF;
   END IF;

EXCEPTION
    when others then
        return NULL;

END IS_PRODUCT_FAMILY_FORECASTABLE;


FUNCTION CONFIG_ITEM_EXISTS ( p_header_id IN NUMBER,
                              p_org_id IN NUMBER,
                              p_ato_line_id IN NUMBER) RETURN NUMBER IS

CURSOR c_config_model (p_header_id IN NUMBER,
                       p_org_id IN NUMBER,
                       p_ato_line_id IN NUMBER) IS
select count(1)
from mtl_system_items itm
where inventory_item_id = (select inventory_item_id
    from oe_order_lines_all l
    where l.item_type_code = 'CONFIG'
    and l.header_id = p_header_id
    and l.org_id = p_org_id
    and l.ato_line_id = p_ato_line_id )
and itm.organization_id = p_org_id
and nvl(itm.ato_forecast_control, 3) <> 3
and itm.base_item_id is not null;

l_item_count NUMBER := 0;

BEGIN

   IF p_header_id is NOT NULL THEN
      OPEN c_config_model (p_header_id,
                           p_org_id,
                           p_ato_line_id);
      FETCH c_config_model INTO l_item_count;
      CLOSE c_config_model;

      IF nvl(l_item_count, 0) = 1 THEN
        return C_YES;
      ELSE
        return C_NO;
      END IF;
   ELSE
      return C_NO;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
        return C_NO;

END CONFIG_ITEM_EXISTS;



FUNCTION on_hold(p_header_id in NUMBER, p_line_id in NUMBER) return VARCHAR2
IS
l_on_hold VARCHAR2(1) := 'N';

Cursor on_hold_flag IS
select decode(min(nvl(released_flag,'Y')),'N','Y','N')
from   oe_order_holds_all
where  header_id = p_header_id
AND    nvl(line_id,p_line_id) = p_line_id
group by header_id,nvl(line_id,p_line_id);

BEGIN

 OPEN on_hold_flag;
    FETCH on_hold_flag into l_on_hold;

 CLOSE on_hold_flag;

 return l_on_hold;

EXCEPTION
  when no_data_found then return l_on_hold;
  when others then return NULL;

END on_hold;

function get_zone_attr return varchar2 is
x_zone_attr  varchar2(100);
x_wsh_application_id number := 665;
x_end_user_column_name varchar2(100) := 'Zone Usage';
x_des_fname varchar2(100) := 'WSH_REGIONS';

cursor c1 is
select application_column_name
from fnd_descr_flex_column_usages
where end_user_column_name  = x_end_user_column_name
and descriptive_flexfield_name = x_des_fname
and application_id = x_wsh_application_id;

begin
  open c1;
  fetch c1 into x_zone_attr;
  close c1;

  return x_zone_attr;

  exception
    when others then return NULL;
end get_zone_attr;

/* Usability Enhancements. Bug # 3509147. This function sets the value of profile MSD_CUSTOMER_ATTRIBUTE to NONE
if collecting for the first time */
function set_customer_attr(	p_profile_name IN VARCHAR2,
				p_profile_value IN VARCHAR2,
				p_profile_Level IN VARCHAR2) return number is
x_ret_value boolean;
begin
x_ret_value := fnd_profile.save(p_profile_name,p_profile_value,p_profile_Level);
if x_ret_value then
 return 0;
else
 return 2;
end if;
end;

FUNCTION get_sr_zone_pk ( p_location_id IN NUMBER,
                               p_zone_attr IN VARCHAR2) return number IS

cursor c1 is
select wrv.region_id
from wsh_region_locations wrl,
wsh_zone_regions wzr,
wsh_regions_v wrv
where wrl.location_id = p_location_id
and wrl.region_id = wzr.region_id
and wzr.parent_region_id = wrv.region_id
and wrv.region_type = 10
and decode(nvl(lower(p_zone_attr), '2'), 'attribute1', wrv.attribute1,
'attribute2', wrv.attribute2, 'attribute3',wrv.attribute3, 'attribute4',
wrv.attribute4, 'attribute5', wrv.attribute5, 'attribute6', wrv.attribute6,
'attribute7', wrv.attribute7, 'attribute8', wrv.attribute8, 'attribute9',
wrv.attribute9, 'attribute10', wrv.attribute10, 'attribute11', wrv.attribute11,
'attribute12', wrv.attribute12, 'attribute13', wrv.attribute13, 'attribute14',
wrv.attribute14, 'attribute15', wrv.attribute15, '2') = '1'
order by wrv.region_id;

x_region_id number:= null;

begin

  if ((p_location_id is null) or (p_zone_attr is null)) then
    return -777;
  else
    open c1;
    fetch c1 into x_region_id;
    close c1;

    if (x_region_id is not null) then
       return x_region_id;
    else
       return -777;
    end if;
  end if;
    EXCEPTION
       when no_data_found then return -777;
end get_sr_zone_pk;

/* This function is used in MSD_SR_SERVICE_PARTS_USAGE_V.
 * It is required in flow Depot Repair WIP, because
 * a repair job can be submitted for several orders
 * and vice versa.
 *
 * Arg : p_txn_source_id is the material transaction source id
 */
FUNCTION get_service_req_org_id (p_txn_source_id IN NUMBER) return NUMBER is
x_org_id number;

cursor c1 is
select organization_id
from csd_repair_job_xref crjx
where wip_entity_id = p_txn_source_id
order by repair_job_xref_id desc;

begin

  if (p_txn_source_id is null) then
    return -777;
  else
    open c1;
    fetch c1 into x_org_id;
    close c1;

    if (x_org_id is not null) then
      return x_org_id;
    else
      return -777;
    end if;
  end if;
EXCEPTION
    when no_data_found then return -777;
end get_service_req_org_id;

/* This function is used in MSD_SR_SERVICE_PARTS_USAGE_V.
 * It is required in flow Depot Repair WIP, because
 * a repair job can be submitted for several orders
 * and vice versa.
 *
 * Arg : p_txn_source_id is the material transaction source id
 * Arg : p_cust_filter is the profile value for Customer Attribute
 */

FUNCTION get_service_req_acct_id (p_txn_source_id IN NUMBER,
                                  p_cust_filter in varchar2) return NUMBER is
x_rpr_line_id number;
x_acct_id number;

cursor c1 is
select repair_line_id
  from csd_repair_job_xref
 where wip_entity_id = p_txn_source_id
order by repair_job_xref_id desc;

cursor c2 (p_repair_line_id in number) is
 --Bug 4585376 RA_CUSTOMERS replaced by HZ_CUST_ACCOUNTS
  select decode(decode(nvl(lower(p_cust_filter), '1'), '1', '1', 'attribute1',
       cust.attribute1, 'attribute2', cust.attribute2, 'attribute3', cust.attribute3,
       'attribute4', cust.attribute4, 'attribute5', cust.attribute5, 'attribute6',
       cust.attribute6, 'attribute7', cust.attribute7, 'attribute8', cust.attribute8,
       'attribute9', cust.attribute9, 'attribute10', cust.attribute10, 'attribute11',
       cust.attribute11, 'attribute12', cust.attribute12, 'attribute13',cust.attribute13,
       'attribute14', cust.attribute14, 'attribute15', cust.attribute15, '2'), '1',
       nvl(cia.account_id, msd_sr_util.get_null_pk), msd_sr_util.get_null_pk)
  from cs_incidents_all_b cia,
       hz_cust_accounts cust,
       csd_repairs crp
  where crp.repair_line_id = p_repair_line_id
  and cia.incident_id = crp.incident_id
  and cust.cust_account_id = cia.account_id;

begin

  if (p_txn_source_id is null) then
    return -777;
  else
    open c1;
    fetch c1 into x_rpr_line_id;
    close c1;

    if (x_rpr_line_id is not null) then
      open c2(x_rpr_line_id);
      fetch c2 into x_acct_id;
      close c2;

      if (x_acct_id is null) then
        return -777;
      else
        return x_acct_id;
      end if;
    else
      return -777;
    end if;
  end if;
EXCEPTION
    when no_data_found then return -777;
end get_service_req_acct_id;

/* This function is used in MSD_SR_SERVICE_PARTS_USAGE_V.
 * It is required in flow Depot Repair WIP, because
 * a repair job can be submitted for several orders
 * and vice versa.
 *
 * Arg : p_txn_source_id is the material transaction source id
 * Arg : p_zone_filter is the profile value for Customer Attribute
 */

FUNCTION get_service_req_zone_id (p_txn_source_id IN NUMBER,
                                  p_zone_filter in VARCHAR2) return NUMBER is
x_rpr_line_id number;
x_zone_id  number;

cursor c1 is
select repair_line_id
  from csd_repair_job_xref
 where wip_entity_id = p_txn_source_id
order by repair_job_xref_id desc;

cursor c2 (p_repair_line_id in number) is
select get_sr_zone_pk(hps.location_id, p_zone_filter)
from cs_incidents_all_b cia,
     hz_party_sites hps,
     csd_repairs crp
where crp.repair_line_id = p_repair_line_id
  and cia.incident_id = crp.incident_id
  and cia.install_site_id = hps.party_site_id (+);

begin

  if (p_txn_source_id is null) then
    return -777;
  else
    open c1;
    fetch c1 into x_rpr_line_id;
    close c1;

    if (x_rpr_line_id is not null) then
      open c2(x_rpr_line_id);
      fetch c2 into x_zone_id;
      close c2;

      if (x_zone_id is null) then
        return -777;
      else
        return x_zone_id;
      end if;
    else
      return -777;
    end if;
  end if;
EXCEPTION
    when no_data_found then return -777;
end get_service_req_zone_id;

FUNCTION is_txn_depot_repair(p_txn_source_id IN NUMBER) return VARCHAR2 is

x_row_num number;
cursor c1 is
select 1
from csd_repair_job_xref crjx
where wip_entity_id = p_txn_source_id
order by repair_job_xref_id;

begin

  if (p_txn_source_id is null) then
    return 'N';
  else
    open c1;
    fetch c1 into x_row_num;
    close c1;

    if (x_row_num is not null) then
      return 'Y';
    else
      return 'N';
    end if;
  end if;
EXCEPTION
    when no_data_found then return 'N';
end is_txn_depot_repair;

/* This function has been added for the view MSD_SR_SALES_FCST_V  to fix bug#3785195 which is forward port of Bug#3733193 */
/* This function returns the customer_id for a given party_id */
/* arg : p_party_id is the party_id of the customer */

FUNCTION get_customer_id( p_party_id IN NUMBER) return NUMBER is

x_customer_id number ;


cursor c_customer_id is
--Bug 4585376 RA_CUSTOMERS replaced by HZ_CUST_ACCOUNTS
select  decode( decode(nvl(lower(filtercust.parameter_value), '1'), '1', '1',
                                                                   'attribute1', cust.attribute1,
                                                                   'attribute2', cust.attribute2,
                                                                   'attribute3', cust.attribute3,
                                                                   'attribute4', cust.attribute4,
                                                                   'attribute5', cust.attribute5,
                                                                   'attribute6', cust.attribute6,
                                                                   'attribute7', cust.attribute7,
                                                                   'attribute8', cust.attribute8,
                                                                   'attribute9', cust.attribute9,
                                                                   'attribute10', cust.attribute10,
                                                                   'attribute11', cust.attribute11,
                                                                   'attribute12', cust.attribute12,
                                                                   'attribute13',cust.attribute13,
                                                                   'attribute14', cust.attribute14,
                                                                   'attribute15', cust.attribute15, '2')
                                                                 ,  '1',  nvl(cust.cust_account_id,msd_sr_util.get_null_pk), msd_sr_util.get_null_pk)
from
hz_cust_accounts cust,
(select parameter_value from msd_setup_parameters where parameter_name = 'MSD_CUSTOMER_ATTRIBUTE')  filtercust
where cust.party_id = p_party_id
order by cust.cust_account_id ASC;


BEGIN

    open c_customer_id ;
    fetch c_customer_id into x_customer_id ;
    close c_customer_id ;

    if( x_customer_id  is not null) then
       return x_customer_id ;
    else
       return NULL_VALUE_PK_CONST ;
    end if ;

EXCEPTION
   when others then return NULL_VALUE_PK_CONST ;
end get_customer_id ;

/* jarorad */
FUNCTION dp_enabled_item (p_inventory_item_id in NUMBER,
                          p_organization_id in NUMBER)
RETURN NUMBER
is
lv_dp_enabled_item          number      := 0;
lv_mrp_planning_code     number      := NULL;
lv_pick_components_flag  varchar2(1) := to_char(NULL);

BEGIN

  select mrp_planning_code,pick_components_flag
  into lv_mrp_planning_code,lv_pick_components_flag
  from mtl_system_items_kfv
  where inventory_item_id = p_inventory_item_id
  and     organization_id = p_organization_id;

  If  ( lv_mrp_planning_code <> 6 OR (lv_mrp_planning_code = 6 and lv_pick_components_flag ='Y')) THEN
     lv_dp_enabled_item := C_YES;
  else
    lv_dp_enabled_item  := C_NO;
  end if;

  return lv_dp_enabled_item;

EXCEPTION
   WHEN OTHERS THEN
        RETURN C_YES;

END dp_enabled_item;
/* jarorad */

/* vinekuma */
/* The following Functions are used in Liability View */
function get_all_sup_pk return number
IS
BEGIN
  return ALL_SUPPLIER_PK_CONST  ;
END;

function get_all_sup_desc return varchar2
IS
BEGIN
  return get_dimension_desc('MSD_DIM_ALL_DESC','SUP');
END;

function get_all_auth_pk return number
IS
BEGIN
return  ALL_AUTHORIZATION_PK_CONST ;
END;


function get_all_auth_desc return varchar2
IS
BEGIN
  return get_dimension_desc('MSD_DIM_ALL_DESC','AUTH');
END;
/* vinekuma */

FUNCTION get_onhand_quantity(
                             p_organization_id in number,
                             p_inventory_item_id in number,
                             p_transaction_date in date
                           ) return number is

cursor c2 (p_organization_id IN number, p_inventory_item_id IN NUMBER,p_transaction_date IN DATE)
IS
SELECT c_onhand_qty
FROM (select fact.item_org_id,
             sum(decode(cal.report_date, p_transaction_date, onhand_qty, null)) c_onhand_qty
      from opi_inv_val_sum_mv fact,
           fii_time_rpt_struct_v cal
      where fact.time_id = cal.time_id
      and fact.item_org_id = (p_inventory_item_id||'-'||p_organization_id)
      and fact.organization_id = p_organization_id
      and fact.aggregation_level_flag = 0
      and cal.report_date = p_transaction_date
      and bitand(cal.record_type_id, 1143) = cal.record_type_id
      group by  fact.item_org_id );

    l_onhand_qty number := 0;

Begin

      open c2 (p_organization_id, p_inventory_item_id, p_transaction_date);
      fetch c2 into l_onhand_qty;
      close c2;

      return l_onhand_qty;

    EXCEPTION when others then return NULL;

End get_onhand_quantity;

function get_suppliers_pk return number IS
BEGIN
 return SUPPLIERS_PK_CONST ;
END;

function get_suppliers_desc return VARCHAR2 IS
BEGIN
  return get_dimension_desc('MSD_DIM_ALL_DESC','SUPP');
END;

function get_internal_customers_desc return VARCHAR2 is
BEGIN
	return get_dimension_desc('MSD_DIM_ALL_DESC','ICUS');
END;

FUNCTION get_eol_category_set_id
RETURN NUMBER
IS
   x_cat_set_id  number;
BEGIN
   /* Get the profile option MSD_EOL_CATEGORY_SET_NAME */
   x_cat_set_id := fnd_profile.value('MSD_EOL_CATEGORY_SET_NAME') ;

  RETURN x_cat_set_id ;

EXCEPTION
   WHEN OTHERS THEN RETURN NULL;
END get_eol_category_set_id;

/* Bug# 5367784 */
/* This function is used in Zone hierarchy views
 * to return Source Level Value Pks for Customer Zone Level Values.
 */

FUNCTION get_sr_custzone_pk ( p_location_id IN NUMBER,
                              p_customer_id IN NUMBER,
                 			  p_zone_attr IN VARCHAR2) RETURN VARCHAR2 is

l_sql_stmt varchar2(2000);

x_region_id number:= null;

begin

  if ((p_location_id is null) or (p_zone_attr is null)) then
    return msd_sr_util.get_null_pk;
  else

    l_sql_stmt := ' select wrv.region_id ' ||
		  ' from wsh_region_locations wrl, ' ||
                  ' wsh_zone_regions wzr, ' ||
		  ' wsh_regions_v wrv ' ||
		  ' where wrl.location_id = ''' || p_location_id  || '''' ||
		  ' and wrl.region_id = wzr.region_id  ' ||
		  ' and wzr.parent_region_id = wrv.region_id ' ||
		  ' and wrv.region_type = 10  ' ||
		  ' and decode(nvl(lower( ''' || p_zone_attr || ''' ), ''2''), ''attribute1'', wrv.attribute1,  ' ||
		  ' ''attribute2'', wrv.attribute2, ''attribute3'',wrv.attribute3, ''attribute4'',  ' ||
		  ' wrv.attribute4, ''attribute5'', wrv.attribute5, ''attribute6'', wrv.attribute6,  ' ||
		  ' ''attribute7'', wrv.attribute7, ''attribute8'', wrv.attribute8, ''attribute9'',  ' ||
		  ' wrv.attribute9, ''attribute10'', wrv.attribute10, ''attribute11'', wrv.attribute11,  ' ||
		  ' ''attribute12'', wrv.attribute12, ''attribute13'', wrv.attribute13, ''attribute14'',  ' ||
		  ' wrv.attribute14, ''attribute15'', wrv.attribute15, ''2'') = ''1'' ' ||
		  ' order by wrv.region_id';

    execute immediate l_sql_stmt into x_region_id;

    if (x_region_id is not null) then
       return to_char(p_customer_id) || ':' || to_char(x_region_id);
    else
       return msd_sr_util.get_null_pk;
    end if;
  end if;
    EXCEPTION
       when no_data_found then return msd_sr_util.get_null_pk;
end get_sr_custzone_pk;

/* This function is used in Zone hierarchy views
 * to return description for Customer Zone Level Values.
 */

FUNCTION get_sr_custzone_desc ( p_location_id IN NUMBER,
                                p_customer_name IN VARCHAR2,
			        p_zone_attr IN VARCHAR2) RETURN VARCHAR2 is

l_sql_stmt varchar2(2000);

x_region_id varchar2(240):= null;

begin

  if ((p_location_id is null) or (p_zone_attr is null)) then
    return msd_sr_util.get_null_desc;
  else

    l_sql_stmt := ' select wrv.zone ' ||
		  ' from wsh_region_locations wrl, ' ||
                  ' wsh_zone_regions wzr, ' ||
		  ' wsh_regions_v wrv ' ||
		  ' where wrl.location_id = ''' || p_location_id  || '''' ||
		  ' and wrl.region_id = wzr.region_id  ' ||
		  ' and wzr.parent_region_id = wrv.region_id ' ||
		  ' and wrv.region_type = 10  ' ||
		  ' and decode(nvl(lower( ''' || p_zone_attr || ''' ), ''2''), ''attribute1'', wrv.attribute1,  ' ||
		  ' ''attribute2'', wrv.attribute2, ''attribute3'',wrv.attribute3, ''attribute4'',  ' ||
		  ' wrv.attribute4, ''attribute5'', wrv.attribute5, ''attribute6'', wrv.attribute6,  ' ||
		  ' ''attribute7'', wrv.attribute7, ''attribute8'', wrv.attribute8, ''attribute9'',  ' ||
		  ' wrv.attribute9, ''attribute10'', wrv.attribute10, ''attribute11'', wrv.attribute11,  ' ||
		  ' ''attribute12'', wrv.attribute12, ''attribute13'', wrv.attribute13, ''attribute14'',  ' ||
		  ' wrv.attribute14, ''attribute15'', wrv.attribute15, ''2'') = ''1'' ' ||
		  ' order by wrv.region_id';

    execute immediate l_sql_stmt into x_region_id;

    if (x_region_id is not null) then
       return p_customer_name || ':' || x_region_id;
    else
       return msd_sr_util.get_null_desc;
    end if;
  end if;
    EXCEPTION
       when no_data_found then return msd_sr_util.get_null_desc;
end get_sr_custzone_desc;

/* This function is used in Zone hierarchy views
 * to return Source Level Value Pks for Zone Level Values.
 * It is also used in Service Part Planning Server Views.
 */

FUNCTION get_sr_zone_pk1 ( p_location_id IN NUMBER,
                          p_zone_attr IN VARCHAR2) return number IS

l_sql_stmt varchar2(2000);

x_region_id number:= null;

begin

  if ((p_location_id is null) or (p_zone_attr is null)) then
    return msd_sr_util.get_null_pk;
  else

    l_sql_stmt := ' select wrv.region_id ' ||
		  ' from wsh_region_locations wrl, ' ||
                  ' wsh_zone_regions wzr, ' ||
		  ' wsh_regions_v wrv ' ||
		  ' where wrl.location_id = ''' || p_location_id  || '''' ||
		  ' and wrl.region_id = wzr.region_id  ' ||
		  ' and wzr.parent_region_id = wrv.region_id ' ||
		  ' and wrv.region_type = 10  ' ||
		  ' and decode(nvl(lower( ''' || p_zone_attr || ''' ), ''2''), ''attribute1'', wrv.attribute1,  ' ||
		  ' ''attribute2'', wrv.attribute2, ''attribute3'',wrv.attribute3, ''attribute4'',  ' ||
		  ' wrv.attribute4, ''attribute5'', wrv.attribute5, ''attribute6'', wrv.attribute6,  ' ||
		  ' ''attribute7'', wrv.attribute7, ''attribute8'', wrv.attribute8, ''attribute9'',  ' ||
		  ' wrv.attribute9, ''attribute10'', wrv.attribute10, ''attribute11'', wrv.attribute11,  ' ||
		  ' ''attribute12'', wrv.attribute12, ''attribute13'', wrv.attribute13, ''attribute14'',  ' ||
		  ' wrv.attribute14, ''attribute15'', wrv.attribute15, ''2'') = ''1'' ' ||
		  ' order by wrv.region_id';

    execute immediate l_sql_stmt into x_region_id;

    if (x_region_id is not null) then
       return x_region_id;
    else
       return msd_sr_util.get_null_pk;
    end if;
  end if;
    EXCEPTION
       when others then return msd_sr_util.get_null_pk;
end get_sr_zone_pk1;


/* This function is used in Zone hierarchy views
 * to return description for Zone Level Values.
 */

FUNCTION get_sr_zone_desc ( p_location_id IN NUMBER,
                            p_zone_attr IN VARCHAR2) return varchar2 IS

l_sql_stmt varchar2(2000);

x_region_id varchar2(240):= null;

begin

  if ((p_location_id is null) or (p_zone_attr is null)) then
    return msd_sr_util.get_null_desc;
  else

    l_sql_stmt := ' select wrv.zone ' ||
		  ' from wsh_region_locations wrl, ' ||
                  ' wsh_zone_regions wzr, ' ||
		  ' wsh_regions_v wrv ' ||
		  ' where wrl.location_id = ''' || p_location_id  || '''' ||
		  ' and wrl.region_id = wzr.region_id  ' ||
		  ' and wzr.parent_region_id = wrv.region_id ' ||
		  ' and wrv.region_type = 10  ' ||
		  ' and decode(nvl(lower(''' || p_zone_attr || ''' ), ''2''), ''attribute1'', wrv.attribute1,  ' ||
		  ' ''attribute2'', wrv.attribute2, ''attribute3'',wrv.attribute3, ''attribute4'',  ' ||
		  ' wrv.attribute4, ''attribute5'', wrv.attribute5, ''attribute6'', wrv.attribute6,  ' ||
		  ' ''attribute7'', wrv.attribute7, ''attribute8'', wrv.attribute8, ''attribute9'',  ' ||
		  ' wrv.attribute9, ''attribute10'', wrv.attribute10, ''attribute11'', wrv.attribute11,  ' ||
		  ' ''attribute12'', wrv.attribute12, ''attribute13'', wrv.attribute13, ''attribute14'',  ' ||
		  ' wrv.attribute14, ''attribute15'', wrv.attribute15, ''2'') = ''1'' ' ||
		  ' order by wrv.region_id';

    execute immediate l_sql_stmt into x_region_id;

    if (x_region_id is not null) then
       return x_region_id;
    else
       return msd_sr_util.get_null_desc;
    end if;
  end if;
    EXCEPTION
       when others then return msd_sr_util.get_null_desc;
end get_sr_zone_desc;

END MSD_SR_UTIL;

/
