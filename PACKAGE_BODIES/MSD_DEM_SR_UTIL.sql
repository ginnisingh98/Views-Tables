--------------------------------------------------------
--  DDL for Package Body MSD_DEM_SR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DEM_SR_UTIL" AS
/* $Header: msddemsub.pls 120.4.12010000.3 2008/11/04 11:37:10 sjagathe ship $ */

   NULL_VALUE_PK_CONST constant number := -777;
   NULL_VALUE_CODE_CONST constant varchar2(2) := '0';
   NULL_VALUE_CONST constant varchar2(20) := 'unassociated';

   C_YES constant number := 1;
   C_NO  constant number := 2;

   /* BOM ITEM TYPE */
   C_MODEL           constant number := 1;
   C_OPTION_CLASS    constant number := 2;
   C_PLANNING        constant number := 3;
   C_STANDARD        constant number := 4;
   C_PRODUCT_FAMILY  constant number := 5;


   /*** PUBLIC PROCEDURES ***
   * EXECUTE_REMOTE_QUERY
   */

      /*
       * This procedure executes a query passed from a remote database.
       */

	procedure EXECUTE_REMOTE_QUERY(query IN VARCHAR2)
	IS
	BEGIN
	  EXECUTE IMMEDIATE query;
	EXCEPTION
	WHEN others THEN
	  RETURN;
	END EXECUTE_REMOTE_QUERY;


   /*** FUNCTIONS ***
    * SET_CUSTOMER_ATTRIBUTE
    * GET_CATEGORY_SET_ID
    * GET_CONVERSION_TYPE
    * GET_MASTER_ORGANIZATION
    * GET_CUSTOMER_ATTRIBUTE
    * GET_NULL_PK
    * GET_NULL_CODE
    * GET_NULL_DESC
    * UOM_CONV
    * IS_ITEM_OPTIONAL_FOR_LVL
    * IS_PRODUCT_FAMILY_FORECASTABLE
    * CONFIG_ITEM_EXISTS
    * CONVERT_GLOBAL_AMT
    * GET_ZONE_ATTR
    * GET_SR_ZONE_DESC
    * GET_SR_ZONE_PK
    * IS_TXN_DEPOT_REPAIR
    * GET_SERVICE_REQ_ORG_ID
    * FIND_PARENT_ITEM
    * FIND_BASE_MODEL
    * IS_ITEM_OPTIONAL_FOR_FACT
    */


      /*
       * Usability Enhancements. Bug # 3509147.
       * This function sets the value of profile MSD_DEM_CUSTOMER_ATTRIBUTE to NONE
       * if collecting for the first time
       */
      FUNCTION SET_CUSTOMER_ATTRIBUTE (
      			p_profile_code 		IN	VARCHAR2,
      			p_profile_value		IN	VARCHAR2,
      			p_profile_level		IN	VARCHAR2)
      RETURN NUMBER
      IS
         x_return_value		BOOLEAN;
      BEGIN
         x_return_value := fnd_profile.save (
         			p_profile_code,
         			p_profile_value,
         			p_profile_level);
         IF (x_return_value)
         THEN
            RETURN 1;
         ELSE
            RETURN 2;
         END IF;

         RETURN 2;

      EXCEPTION
         WHEN OTHERS THEN
            RETURN 2;

      END SET_CUSTOMER_ATTRIBUTE;


      /*
       * This function gets the value of the source profile MSD_DEM_CATEGORY_SET_NAME
       */
      FUNCTION GET_CATEGORY_SET_ID
      RETURN NUMBER
      IS
         x_category_set_id	NUMBER 	 := -1;
      BEGIN
         x_category_set_id := fnd_profile.value ('MSD_DEM_CATEGORY_SET_NAME');
         RETURN x_category_set_id;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END GET_CATEGORY_SET_ID;


      /*
       * This function gets the value of the source profile MSD_DEM_CONVERSION_TYPE
       */
      FUNCTION GET_CONVERSION_TYPE
      RETURN VARCHAR2
      IS
         x_conversion_type	VARCHAR2(100) := NULL;
      BEGIN
         x_conversion_type := fnd_profile.value ('MSD_DEM_CONVERSION_TYPE');
         RETURN x_conversion_type;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END GET_CONVERSION_TYPE;


      /*
       * This function gets the ID of the master organization in the source instance.
       */
      FUNCTION GET_MASTER_ORGANIZATION
      RETURN NUMBER
      IS
         x_master_organization		NUMBER	 := NULL;
         x_multi_org_flag		VARCHAR2(1) := NULL;
      BEGIN

         BEGIN

            SELECT multi_org_flag
               INTO x_multi_org_flag
               FROM fnd_product_groups
               WHERE product_group_type = 'Standard';

         EXCEPTION
            WHEN OTHERS THEN
               x_multi_org_flag := 'Y';

         END;

         x_master_organization := fnd_profile.value ('MSD_DEM_MASTER_ORG');

         IF (x_multi_org_flag = 'Y')
         THEN
            IF (x_master_organization IS NULL)
            THEN

               SELECT organization_id
                  INTO x_master_organization
                  FROM mtl_parameters
                  WHERE organization_id = master_organization_id
                    AND rownum <2;
            END IF;

         ELSE /* Single Master Organization OE Instance */

            SELECT organization_id
               INTO x_master_organization
               FROM mtl_parameters
               WHERE organization_id = master_organization_id
                 AND rownum <2;

         END IF;

         RETURN x_master_organization;

      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;

      END GET_MASTER_ORGANIZATION;


      /*
       * This function gets the value of the source profile MSD_DEM_CUSTOMER_ATTRIBUTE
       */
      FUNCTION GET_CUSTOMER_ATTRIBUTE
      RETURN VARCHAR2
      IS
         x_customer_attribute		VARCHAR2(100)  := NULL;
      BEGIN
         x_customer_attribute := fnd_profile.value ('MSD_DEM_CUSTOMER_ATTRIBUTE');
         RETURN x_customer_attribute;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END GET_CUSTOMER_ATTRIBUTE;



function get_null_pk return number IS
BEGIN
 return NULL_VALUE_PK_CONST;
END;

function get_null_code return VARCHAR2 IS
BEGIN
 return NULL_VALUE_CODE_CONST;
END;

function get_null_desc return VARCHAR2 IS
BEGIN
 return NULL_VALUE_CONST;
END;


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
      from msd_dem_setup_parameters
      where parameter_name = 'MSD_DEM_MASTER_ORG';

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


FUNCTION IS_ITEM_OPTIONAL_FOR_LVL(p_component_item_id  in  NUMBER) RETURN NUMBER IS

CURSOR c_optional IS
select 1
from
   msd_dem_app_instance_orgs morg,
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


function convert_global_amt(p_curr_code in varchar2, p_date in date) return number IS
l_ret number;
c_global_currency_code varchar2(40);
c_global_rate_type varchar2(40);
BEGIN

select parameter_value
into c_global_currency_code
from msd_dem_setup_parameters
where parameter_name = 'MSD_DEM_CURRENCY_CODE';

select parameter_value
into c_global_rate_type
from msd_dem_setup_parameters
where parameter_name = 'MSD_DEM_CONVERSION_TYPE';

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

function get_zone_attr return varchar2 is  --jarora
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

FUNCTION get_sr_zone_desc ( p_location_id IN NUMBER,
                            p_zone_attr IN VARCHAR2) return varchar2 IS --jarora

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

FUNCTION get_sr_zone_pk ( p_location_id IN NUMBER,
                               p_zone_attr IN VARCHAR2) return number IS   --jarora

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

FUNCTION is_txn_depot_repair(p_txn_source_id IN NUMBER) return VARCHAR2 is --jarora

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

FUNCTION get_service_req_org_id (p_txn_source_id IN NUMBER) return NUMBER is --jarora
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

/* This function checks if data has to be collected for a given customer(party).
 * Returns 1 (true) if all the customer accounts associated with the customer are enabled,
 * returns 2 (false) if any of the customer accounts associated is disabled.
 */
FUNCTION get_data_for_customer(p_party_id in number, p_cust_attribute in varchar2) return NUMBER --syenamar
is

x_sql varchar2(2000) := null;
x_disabled_accnts number;

begin

x_sql := 'select count(cust_account_id) from hz_cust_accounts' ||
            ' where party_id = ' || p_party_id ||
            ' and ( ' || p_cust_attribute  || ' <> ''1'' or ' || p_cust_attribute || ' is null)';
execute immediate x_sql into x_disabled_accnts;

if x_disabled_accnts <> 0 then
    return 2;
else
    return 1;
end if;

end get_data_for_customer;

      /*
       * This function gets the parent item for the given item. If profile MSD_DEM: Calculate
       * Planning Percentage is set to 'Yes, for "Consume & Derive" Options only' then it gets
       * nearest parent model.
       */
      FUNCTION FIND_PARENT_ITEM ( p_link_to_line_id 	IN 	NUMBER,
                                  p_include_class	IN	VARCHAR2 )
         RETURN NUMBER
         IS

            x_line_id		NUMBER		:= p_link_to_line_id;
            x_item_type_code	VARCHAR2(10)	:= NULL;
            x_parent_item_id	NUMBER		:= NULL;
            x_link_to_line_id	NUMBER		:= 0;
            x_ato_line_id	NUMBER		:= 0;
            x_loop		BOOLEAN		:= TRUE;

            CURSOR C_PARENT
            IS
               SELECT
                  inventory_item_id,
                  item_type_code,
                  link_to_line_id,
                  ato_line_id
               FROM
                  oe_order_lines_all
               WHERE
                  line_id = x_line_id;

         BEGIN

            WHILE (x_loop)
            LOOP

               IF (p_include_class = 'Y')
               THEN
                  x_loop := FALSE;
               END IF;

               OPEN C_PARENT;
               FETCH C_PARENT INTO x_parent_item_id,
                                   x_item_type_code,
                                   x_link_to_line_id,
                                   x_ato_line_id;
               CLOSE C_PARENT;

               IF (x_item_type_code = 'CLASS'
                   AND (nvl(x_ato_line_id, -999)  <>  x_line_id))
               THEN
                  x_line_id := x_link_to_line_id;
               ELSE
                  x_loop := FALSE;
               END IF;

            END LOOP;

            RETURN x_parent_item_id;

         END FIND_PARENT_ITEM;


      /*
       * This function get the inventory_item_id of the base model in the configuration.
       */
      FUNCTION FIND_BASE_MODEL ( p_top_model_line_id	IN	NUMBER )
         RETURN NUMBER
         IS

            x_base_model_id	NUMBER	:= NULL;

         BEGIN

            SELECT inventory_item_id
            INTO x_base_model_id
            FROM oe_order_lines_all
            WHERE line_id = p_top_model_line_id;

            RETURN x_base_model_id;

         END FIND_BASE_MODEL;


      /*
       * This function is called when item has ato_forecast_control = NONE.
       * First, check whether the given component is optional component in the BOM or not.
       * If so, then find the parent's component sequence id and then check whether the
       * parent is either ((optional with forecast control = none) or (consume and derive))
       */
      FUNCTION IS_ITEM_OPTIONAL_FOR_FACT ( p_component_item_id		IN	NUMBER,
                                           p_component_sequence_id	IN	NUMBER,
                                           p_parent_line_id		IN	NUMBER )
         RETURN NUMBER
         IS

            x_component_sequence_id 		NUMBER		:= p_component_sequence_id;
            x_parent_component_sequence_id	NUMBER		:= NULL;
            x_count				NUMBER		:= 0;

            CURSOR C_IS_OPTIONAL
            IS
               SELECT 1
               FROM msd_dem_app_instance_orgs mdaio,
                    bom_bill_of_materials     bbm,
                    mtl_system_items          msi,
                    bom_inventory_components  bic
               WHERE
                      bic.component_sequence_id = x_component_sequence_id
                  AND bic.bill_sequence_id = bbm.bill_sequence_id
                  AND bbm.organization_id = mdaio.organization_id
                  AND msi.organization_id = bbm.organization_id
                  AND msi.inventory_item_id = bbm.assembly_item_id
                  AND msi.bom_item_type not in (C_PLANNING, C_STANDARD, C_PRODUCT_FAMILY)
                  AND bic.optional = C_YES;

            CURSOR C_PARENT_ITEM
            IS
               SELECT component_sequence_id
               FROM oe_order_lines_all
               WHERE line_id = p_parent_line_id;

            /* The parent of optional item has to be either consume and drive or none with optional = YES */
            CURSOR C_IS_PARENT_OPTIONAL
            IS
               SELECT
                  1
               FROM msd_dem_app_instance_orgs     mdaio,
                    bom_bill_of_materials         bbm,
                    mtl_system_items              msi,
                    bom_inventory_components      bic
               WHERE
                      bic.component_sequence_id = x_component_sequence_id
                  AND bic.bill_sequence_id = bbm.bill_sequence_id
                  AND bbm.organization_id = mdaio.organization_id
                  AND msi.organization_id = bbm.organization_id
                  AND msi.inventory_item_id = bic.component_item_id
                  AND (( msi.ato_forecast_control = 3
                         AND   bic.optional = C_YES)
                        OR
                         msi.ato_forecast_control in (1, 2));

         BEGIN

            OPEN C_IS_OPTIONAL;
            FETCH C_IS_OPTIONAL INTO x_count;
            CLOSE C_IS_OPTIONAL;

            IF (x_count <> 0)
            THEN

               OPEN C_PARENT_ITEM;
               FETCH C_PARENT_ITEM INTO x_parent_component_sequence_id;
               CLOSE C_PARENT_ITEM;

               x_component_sequence_id := x_parent_component_sequence_id;

               IF (x_component_sequence_id IS NOT NULL)
               THEN
                  x_count := 0;
                  OPEN C_IS_PARENT_OPTIONAL;
                  FETCH C_IS_PARENT_OPTIONAL INTO x_count;
                  CLOSE C_IS_PARENT_OPTIONAL;
               END IF;
            END IF;

            IF (x_count <> 0)
            THEN
               RETURN C_YES;
            END IF;

            RETURN C_NO;

         END IS_ITEM_OPTIONAL_FOR_FACT;







END MSD_DEM_SR_UTIL;

/
