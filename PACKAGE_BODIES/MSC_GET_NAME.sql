--------------------------------------------------------
--  DDL for Package Body MSC_GET_NAME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_GET_NAME" AS
	/* $Header: MSCGPRJB.pls 120.50.12010000.21 2010/04/23 17:49:23 hulu ship $*/
 g_plan_type number; -- Global variable to cache plan type
FUNCTION project (arg_project_id 	IN NUMBER,
                  arg_org_id IN NUMBER,
                  arg_plan_id IN NUMBER,
                  arg_instance_id IN NUMBER)	return varchar2 IS
var_project_num		VARCHAR2(30);
BEGIN

	IF arg_project_id is null or
           arg_plan_id is null or
           arg_instance_id is null THEN
		return null;
        ELSIF arg_org_id IS NULL THEN
	  select distinct project_number
          into  var_project_num
	  from  msc_projects
	  where project_id = arg_project_id
          and   plan_id = -1
          and   sr_instance_id=arg_instance_id
          and   rownum = 1;
        ELSE
	  select project_number
          into  var_project_num
	  from	msc_projects
	  where project_id = arg_project_id
          and   plan_id = -1
          and   sr_instance_id=arg_instance_id
          and   organization_id = arg_org_id;
	END IF;

	return var_project_num;
END project;

FUNCTION task(arg_task_id 	IN NUMBER,
              arg_project_id 	IN NUMBER,
              arg_org_id IN NUMBER,
              arg_plan_id IN NUMBER,
              arg_instance_id IN NUMBER)	return varchar2 IS
var_task_num		varchar2(25);
BEGIN
	IF arg_task_id is null or
           arg_plan_id is null or
           arg_instance_id is null THEN
	  return null;
        ELSIF (arg_org_id is null or arg_project_id is null) THEN
	  select distinct task_number
          into var_task_num
	  from msc_project_tasks
	  where	task_id = arg_task_id
          and plan_id = -1
          and sr_instance_id=arg_instance_id
          and rownum = 1;
        ELSE
	  select task_number
          into var_task_num
	  from msc_project_tasks
	  where	project_id = arg_project_id
          and task_id = arg_task_id
          and plan_id = -1
          and sr_instance_id=arg_instance_id
          and organization_id = arg_org_id;
	END IF;

	return var_task_num;
END task;



 FUNCTION  process_priority(arg_plan_id IN NUMBER,
                            arg_sr_instance_id IN NUMBER,
                            arg_organization_id IN NUMBER,
                            arg_inventory_item_id IN NUMBER,
                            arg_process_sequence_id IN NUMBER)
 return NUMBER IS
var_process_priority NUMBER;

BEGIN

     IF arg_plan_id is NULL or
        arg_sr_instance_id is NULL or
        arg_organization_id is NULL or
        arg_inventory_item_id  is NULL or
        arg_process_sequence_id is NULL THEN

     return NULL;

    END IF;

 select preference
 into var_process_priority
 from  msc_process_effectivity
 where plan_id = arg_plan_id
 and process_sequence_id = arg_process_sequence_id
 and sr_instance_id = arg_sr_instance_id
 and organization_id = arg_organization_id
 and item_id = arg_inventory_item_id;

return var_process_priority;

END  process_priority;

--bug#8299062
FUNCTION CUSTOMER_PO_NUMBER (arg_demand_id IN NUMBER,
                             arg_sr_instance_id IN NUMBER) return varchar2 is
  CURSOR customer_po_number_c IS
   SELECT cust_po_number
     FROM msc_sales_orders
    WHERE demand_id = arg_demand_id
      AND sr_instance_id = arg_sr_instance_id;
  l_customer_po_number varchar2(50);
begin
   open customer_po_number_c;
   fetch customer_po_number_c into l_customer_po_number;
   close customer_po_number_c;

   return l_customer_po_number;

   exception when no_data_found then
     return null;
end CUSTOMER_PO_NUMBER;

FUNCTION CUST_LINE_NUMBER (arg_demand_id IN NUMBER,
                                  arg_sr_instance_id IN NUMBER) return varchar2 is

  CURSOR customer_po_line_number_c IS
   SELECT customer_line_number
     FROM msc_sales_orders
    WHERE demand_id = arg_demand_id
      AND sr_instance_id = arg_sr_instance_id;

  l_customer_po_line_number varchar2(50);

begin
   open customer_po_line_number_c;
   fetch customer_po_line_number_c into l_customer_po_line_number;
   close customer_po_line_number_c;

   return l_customer_po_line_number;

   exception when no_data_found then
     return null;
end CUST_LINE_NUMBER;

FUNCTION planning_group(arg_project_id 	IN NUMBER,
              arg_org_id IN NUMBER,
              arg_plan_id IN NUMBER,
              arg_instance_id IN NUMBER)	return varchar2 IS
var_plng_grp		varchar2(30);
BEGIN

	IF arg_project_id is null or
           arg_plan_id is null or
           arg_instance_id is null or
           arg_org_id is null
        THEN
		return null;
	END IF;

	select	DISTINCT planning_group
	into	var_plng_grp
	from	msc_projects
	where 	project_id = arg_project_id
        and     plan_id = -1
        and     sr_instance_id=arg_instance_id
        and     organization_id = arg_org_id;

	return var_plng_grp;
END planning_group;

FUNCTION demand_date (arg_pegging_id 	IN NUMBER,
                  arg_plan_id IN NUMBER)	return DATE IS
var_date		Date;
BEGIN

	IF arg_pegging_id is null or
           arg_plan_id is null THEN
		return null;
	END IF;

	select	md.using_assembly_demand_date
        into    var_date
	from	msc_demands md,
                msc_full_pegging mfp
	where 	mfp.pegging_id = arg_pegging_id
        and     mfp.plan_id=arg_plan_id
        and     md.demand_id = mfp.demand_id
        and     md.plan_id = mfp.plan_id;

	return var_date;
END demand_date;


FUNCTION resource_over_util_cost(arg_resource_id IN NUMBER,
                                 arg_department_id IN NUMBER,
                                 arg_org_id IN NUMBER,
                                 arg_plan_id IN NUMBER,
                                 arg_instance_id IN NUMBER)return number IS
v_resource_over_util_cost number;

BEGIN

  if arg_resource_id = -1 or
     arg_resource_id is NULL or
     arg_department_id is NULL or
     arg_org_id is NULL or
     arg_instance_id is NULL then
     return NULL;
 end if;

     select resource_over_util_cost
     into v_resource_over_util_cost
     from msc_department_resources
     where department_id = arg_department_id
     and resource_id = arg_resource_id
     and organization_id = arg_org_id
     and sr_instance_id = arg_instance_id
     and plan_id = arg_plan_id;
     v_resource_over_util_cost:= v_resource_over_util_cost/100;
  return v_resource_over_util_cost;

END resource_over_util_cost;




FUNCTION supply_date (arg_pegging_id 	IN NUMBER,
                  arg_plan_id IN NUMBER)	return DATE IS
var_date		Date;
BEGIN

	IF arg_pegging_id is null or
           arg_plan_id is null THEN
		return null;
	END IF;

	select	ms.new_schedule_date
        into    var_date
	from	msc_supplies ms,
                msc_full_pegging mfp
	where 	ms.transaction_id = mfp.transaction_id
        and     ms.plan_id=mfp.plan_id
        and     mfp.pegging_id = arg_pegging_id
        and     mfp.plan_id = arg_plan_id;

	return var_date;
END supply_date;

FUNCTION lookup_meaning(arg_lookup_type IN varchar2,
                        arg_lookup_code IN NUMBER) return varchar2 IS
meaning_text varchar2(80);
BEGIN

   if arg_lookup_code is null then
      return null;
   end if;

   select meaning
   into meaning_text
   from mfg_lookups
   where lookup_type = arg_lookup_type
     and lookup_code = arg_lookup_code;
/*
   select lv.meaning
   into meaning_text
   from fnd_lookup_values lv
   where lv.language = userenv('LANG')
   and   lv.view_application_id =700
   and   lv.lookup_type = arg_lookup_type
   and   lv.lookup_code = to_char(arg_lookup_code)
   and   lv.security_group_id =
(select max(SECURITY_GROUP_ID)
               from FND_LOOKUP_TYPES LT
               where LT.VIEW_APPLICATION_ID = LV.VIEW_APPLICATION_ID
               and LT.LOOKUP_TYPE = LV.LOOKUP_TYPE
               and LT.SECURITY_GROUP_ID in (0,
                     to_number(decode(substr(userenv('CLIENT_INFO'),55,1),
                                      ' ', '0',
                                      null, '0',
                                      substr(userenv('CLIENT_INFO'),55,10)))));
*/
     return meaning_text;

EXCEPTION when no_data_found THEN
    return null;
END lookup_meaning;

FUNCTION lookup_by_plan(arg_lookup_type IN varchar2,
                        arg_lookup_code IN NUMBER,
                        arg_plan_type IN NUMBER,
                        arg_source_org_id IN NUMBER DEFAULT null) return varchar2 IS
meaning_text varchar2(80);
p_lookup_type varchar2(50);
p_lookup_code number;

cursor cur_lookup is
   select meaning
   from mfg_lookups
   where lookup_type = p_lookup_type
     and lookup_code = p_lookup_code;
BEGIN

   if arg_lookup_code is null or
      arg_lookup_type is null then
      return null;
   end if;

   p_lookup_type := arg_lookup_type;
   p_lookup_code := arg_lookup_code;

   if arg_plan_type = 5 and
      arg_lookup_type = 'MSC_DEMAND_ORIGINATION' and
      arg_lookup_code in (8) then
         p_lookup_type := 'MSC_DRP_CHANGED_DEMAND_NAME';
   elsif  arg_plan_type = 5 and
          arg_lookup_type = 'MRP_ORDER_TYPE' and
          arg_lookup_code = 2 and
          arg_source_org_id is not null then
              p_lookup_code := 53; -- internal req
   elsif arg_plan_type in (8,9) and
         arg_lookup_type = 'MRP_ORDER_TYPE' and
         arg_lookup_code in (1,2,51) then
         if arg_lookup_code = 2 and
            arg_source_org_id is not null then
            p_lookup_code := 53; -- internal req
         else
            p_lookup_type := 'SRP_CHANGED_ORDER_TYPE';
         end if;
   end if;

   open cur_lookup;
   fetch cur_lookup into meaning_text;
   close cur_lookup;

   return meaning_text;

END lookup_by_plan;

FUNCTION fnd_lookup_meaning(arg_lookup_type IN varchar2,
                        arg_lookup_code IN NUMBER)
return varchar2 IS
meaning_text varchar2(255);

cursor cur_lookup(l_arg_lookup_type  varchar2 ,l_arg_lookup_code  NUMBER) is
select meaning from fnd_lookups
 where lookup_type = l_arg_lookup_type
   and lookup_code = l_arg_lookup_code;

BEGIN
open cur_lookup(arg_lookup_type ,arg_lookup_code);
fetch cur_lookup into meaning_text;
close cur_lookup;
return meaning_text;
END fnd_lookup_meaning;

FUNCTION location_code(  arg_org_id          IN NUMBER,
                         arg_location_id     IN NUMBER,
                         arg_instance_id     IN NUMBER) return VARCHAR2
IS
loc_code VARCHAR2(60);

BEGIN
   IF (arg_org_id is NULL or
      arg_org_id  = -1 )  and
      arg_location_id is not NULL   THEN
     select  location_code
     into    loc_code
     from    msc_location_associations
     where   location_id = arg_location_id
     and     sr_instance_id = arg_instance_id;
   ELSE
     select location
     into loc_code
     from  msc_trading_partner_sites s
     where s.sr_tp_id = arg_org_id
     and   s.sr_instance_id = arg_instance_id;
   END IF;

    return loc_code;
EXCEPTION when others THEN
    return null;
END  location_code;



FUNCTION org_code(arg_org_id IN NUMBER,
                  arg_instance_id IN NUMBER) return varchar2 IS
org_text varchar2(15);
BEGIN

 IF arg_org_id is null or
    arg_org_id < 0 or
    arg_instance_id is null or
    arg_instance_id < 0 THEN
   return null;
 END IF;
   select organization_code
   into org_text
   from msc_trading_partners
   where partner_type=3
   and sr_tp_id=arg_org_id
   and sr_instance_id = arg_instance_id;

   return org_text;
EXCEPTION when others THEN
    return null;
END org_code;

--For SRP
FUNCTION org_code(arg_org_inst_id IN varchar2) return varchar2 is
	CURSOR ORG_CUR(P_ORG_ID IN NUMBER, P_INST_ID IN NUMBER) IS
	SELECT ORGANIZATION_CODE
	FROM msc_trading_partners
	WHERE SR_TP_ID  = P_ORG_ID
	AND SR_INSTANCE_ID = P_INST_ID
	AND PARTNER_TYPE= 3;

	L_ORG_CODE VARCHAR2(250);
	L_ORG_ID NUMBER ;
	L_INST_ID NUMBER ;
	L_POS NUMBER;
BEGIN
	L_POS := INSTR(arg_org_inst_id, ':');
	L_ORG_ID := SUBSTR(arg_org_inst_id,1,L_POS-1);
	L_INST_ID := SUBSTR(arg_org_inst_id,L_POS+1);
	IF L_ORG_ID IS NULL OR L_iNST_ID IS NULL THEN
		RETURN '';
	ELSE
		OPEN ORG_CUR(L_ORG_iD, L_INST_iD);
		FETCH ORG_CUR INTO L_ORG_CODE;
		CLOSE ORG_CUR;
	END IF;
	RETURN L_ORG_CODE;
EXCEPTION
	WHEN OTHERS THEN
		RETURN '';
end org_code;

FUNCTION instance_code(arg_instance_id IN NUMBER) return varchar2 IS
 instance_text varchar2(5);
BEGIN

 IF arg_instance_id is null THEN
    return null;
 END IF;
   select instance_code
   into instance_text
   from msc_apps_instances
   where instance_id = arg_instance_id;

   return instance_text;
EXCEPTION when others THEN
    return null;
END instance_code;

FUNCTION supply_order (arg_demand_type IN NUMBER,
			   arg_disp_id IN NUMBER,
			   arg_org_id IN NUMBER,
			   arg_plan_id IN NUMBER,
			   arg_instance_id IN NUMBER,
                           arg_supply_type IN NUMBER  DEFAULT NULL)
	return varchar2
IS

order_num      varchar2(240);

cursor order_number_c is
select order_number
  from msc_supplies
  where disposition_id in
      (select disposition_id
       from msc_demands
       where plan_id = arg_plan_id
       and demand_id =  arg_disp_id)
  and sr_instance_id = arg_instance_id
  and plan_id = arg_plan_id
  and organization_id = arg_org_id
  and order_type in (1,2,8,11,12);

cursor wip_entity_name_c is
  select wip_entity_name
  from msc_supplies
  where disposition_id in
      (select disposition_id
       from msc_demands
       where plan_id = arg_plan_id
       and demand_id =  arg_disp_id)
  and sr_instance_id = arg_instance_id
  and plan_id = arg_plan_id
  and organization_id = arg_org_id
  and order_type in (3,7,14,15,27,28);

cursor designator_c is
  select desig.designator
  from msc_designators desig,
       msc_demands mgr
  where desig.designator_id = mgr.schedule_designator_id
    and mgr.demand_id = arg_disp_id
    and mgr.sr_instance_id = arg_instance_id
    and mgr.plan_id = arg_plan_id
    and mgr.organization_id = arg_org_id;


BEGIN
-- note : arg_disp_id contains the demand_id,
-- since plan_id, org, instance, disposition cannot be unique in msc_demands
--bug 2038727

if ((arg_demand_type is NULL and arg_supply_type is NULL) or
    arg_disp_id is null or
    arg_instance_id is null or
    arg_plan_id is null or
    arg_org_id is null )  THEN

  return NULL;
END IF;

if (arg_demand_type in (18,19,20,23,24) or
    arg_supply_type in (1,2,8,11,12)) then

  OPEN order_number_c;
  FETCH order_number_c INTO order_num;
  CLOSE order_number_c;

elsif (arg_demand_type in (2,3,17,25,26) or
       arg_supply_type in (3,7,14,15,27,28)) then

  OPEN wip_entity_name_c;
  FETCH wip_entity_name_c INTO order_num;
  CLOSE wip_entity_name_c;

elsif (arg_demand_type in (7,8,11,12,15)) then

  OPEN designator_c;
  FETCH designator_c INTO order_num;
  CLOSE designator_c;

end if;

  return (order_num);

END SUPPLY_ORDER;

FUNCTION job_name (arg_transaction_id IN NUMBER,
			   arg_plan_id IN NUMBER,
                           arg_sr_instance_id in number default null)
    return varchar2
IS
    order_num      varchar2(240);
    v_type number;
BEGIN

if  arg_transaction_id is null or
    arg_plan_id is null then
  return NULL;
END IF;
--  if arg_sr_instance_id is null  then
    select order_number, order_type
    into order_num, v_type
    from msc_supplies
    where transaction_id = arg_transaction_id
    and plan_id = arg_plan_id;
--  else
    select order_number, order_type
    into order_num, v_type
    from msc_supplies
    where transaction_id = arg_transaction_id
    and plan_id = arg_plan_id
    and sr_instance_id = arg_sr_instance_id;
--  end if;

  order_num := replace(order_num,'~','^');

  if v_type = 5 then
     if order_num is not null then
        return order_num ||' '|| to_char(arg_transaction_id);
     else
        return to_char(arg_transaction_id);
     end if;
  else
      return (order_num);
  end if;

END job_name;

FUNCTION supply_type (arg_transaction_id IN NUMBER,
			   arg_plan_id IN NUMBER)
    return varchar2
IS
    v_order_type      varchar2(240);
BEGIN

if  arg_transaction_id is null or
    arg_plan_id is null then
  return NULL;
END IF;

  select lookup_meaning('MRP_ORDER_TYPE', order_type)
  into v_order_type
  from msc_supplies
  where transaction_id = arg_transaction_id
  and plan_id = arg_plan_id;

  return (v_order_type);

END supply_type;

FUNCTION order_type (arg_plan_id IN number,
                     arg_transaction_id IN NUMBER,
                     arg_instance_id IN NUMBER) RETURN number IS
   v_order_type number;
BEGIN

if  arg_transaction_id is null or
    arg_plan_id is null or
    arg_instance_id is null then
  return NULL;
END IF;

  select order_type
  into v_order_type
  from msc_supplies
  where transaction_id = arg_transaction_id
  and plan_id = arg_plan_id
  and sr_instance_id = arg_instance_id;

  return (v_order_type);

END order_type;


FUNCTION item_desc(arg_item_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER) return varchar2 IS
  item_description varchar2(240);
  CURSOR item_desc IS
   SELECT description
     FROM msc_system_items
    WHERE inventory_item_id = arg_item_id
      AND plan_id = arg_plan_id
      AND sr_instance_id = arg_instance_id
      AND  (new_plan_id = -1 OR new_plan_id IS NULL )
      AND  (SIMULATION_SET_ID IS NULL);

BEGIN
  if ( arg_item_id is null ) or
     ( arg_item_id < 0 ) or
     ( arg_plan_id is null ) or
     ( arg_instance_id is null ) then
     return null;
  end if;
  if arg_org_id is not null and arg_org_id > 0 then
    select description
    into item_description
    from msc_system_items
    where inventory_item_id = arg_item_id
    and   plan_id = arg_plan_id
    and   organization_id = arg_org_id
    and   sr_instance_id = arg_instance_id
    AND  (new_plan_id = -1 OR new_plan_id IS NULL )
    AND  (SIMULATION_SET_ID IS NULL);
    return item_description;
  else
     OPEN item_desc;
     LOOP
       FETCH item_desc INTO item_description;
       EXIT WHEN item_desc%NOTFOUND;
       if item_description is not null then
          exit;
       end if;
     END LOOP;
     CLOSE item_desc;
     return item_description;
   end if;

  exception when no_data_found then
     OPEN item_desc;
     LOOP
       FETCH item_desc INTO item_description;
       EXIT WHEN item_desc%NOTFOUND;
       if item_description is not null then
          exit;
       end if;
     END LOOP;
     CLOSE item_desc;
     return item_description;

END item_desc;


FUNCTION department_code(arg_line_flag IN NUMBER,
                   arg_dept_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER) return varchar2 IS
  v_department_code varchar2(10);
BEGIN

  if arg_line_flag is null or
     arg_dept_id is null or
     arg_plan_id is null or
     arg_instance_id is null then

     return null;

  elsif arg_org_id is null then

    select distinct department_code
    into   v_department_code
    from   msc_department_resources
    where department_id = arg_dept_id
    and   plan_id = arg_plan_id
    and   sr_instance_id = arg_instance_id
    and   line_flag = arg_line_flag;

  else

    select distinct department_code
    into   v_department_code
    from   msc_department_resources
    where department_id = arg_dept_id
    and   plan_id = arg_plan_id
    and   organization_id = arg_org_id
    and   sr_instance_id = arg_instance_id
    and   line_flag = arg_line_flag;

  end if;

  return v_department_code;
exception when no_data_found then
    return null;
END department_code;

FUNCTION resource_code(arg_resource_id IN NUMBER,
                   arg_dept_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER) return varchar2 IS
  v_resource_code varchar2(30);
BEGIN

  if arg_dept_id = -1 then -- from undo, arg_org_id will pass transaction_id
    select distinct mdr.resource_code
    into   v_resource_code
    from   msc_department_resources mdr,
           msc_resource_requirements mrr
    where mdr.department_id = mrr.department_id
    and   mdr.resource_id = arg_resource_id
    and   mdr.plan_id = mrr.plan_id
    and   mdr.organization_id = mrr.organization_id
    and   mdr.sr_instance_id = mrr.sr_instance_id
    and   mrr.plan_id = arg_plan_id
    and   mrr.sr_instance_id = arg_instance_id
    and   mrr.transaction_id = arg_org_id;

  elsif  arg_resource_id =-1 or
     arg_resource_id is null or
     arg_dept_id is null or
     arg_org_id is null or
     arg_plan_id is null or
     arg_instance_id is null then

     return null;

  else

    select distinct resource_code
    into   v_resource_code
    from   msc_department_resources
    where department_id = arg_dept_id
    and   resource_id = arg_resource_id
    and   plan_id = arg_plan_id
    and   organization_id = arg_org_id
    and   sr_instance_id = arg_instance_id;

  end if;
  return v_resource_code;
END resource_code;

FUNCTION resource_util_pct(arg_resource_id IN NUMBER,
                   arg_dept_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER) return number IS
   util_pct number;
BEGIN
  if  arg_resource_id =-1 or
     arg_resource_id is null or
     arg_dept_id is null or
     arg_org_id is null or
     arg_plan_id is null or
     arg_instance_id is null then
   util_pct := 1;
   return util_pct;
  else
    select utilization
    into   util_pct
    from   msc_department_resources
    where department_id = arg_dept_id
    and   resource_id = arg_resource_id
    and   plan_id = arg_plan_id
    and   organization_id = arg_org_id
    and   sr_instance_id = arg_instance_id;
  end if;
   if  util_pct is null then
     return 1;
   else
     return util_pct/100;
   end if;
END resource_util_pct;


FUNCTION resource_type(arg_resource_id IN NUMBER,
                   arg_dept_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER) return NUMBER IS
  v_resource_type NUMBER;
BEGIN

  if arg_resource_id =-1 or
     arg_resource_id is null or
     arg_dept_id is null or
     arg_org_id is null or
     arg_plan_id is null or
     arg_instance_id is null then

     return null;
  end if;

  select resource_type
  into   v_resource_type
  from   msc_department_resources
  where department_id = arg_dept_id
  and   resource_id = arg_resource_id
  and   plan_id = arg_plan_id
  and   organization_id = arg_org_id
  and   sr_instance_id = arg_instance_id;

  return v_resource_type;
END resource_type;

FUNCTION department_resource_code(arg_resource_id IN NUMBER,
                   arg_dept_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER) return varchar2 IS
  v_dept_resource_code varchar2(30);
  v_org_code varchar2(15);
BEGIN

  if arg_resource_id =-1 or
     arg_resource_id is null or
     arg_dept_id is null or
     arg_org_id is null or
     arg_plan_id is null or
     arg_instance_id is null then

     return null;
  end if;

  v_org_code := msc_get_name.org_code(arg_org_id, arg_instance_id);

  select department_code || '/' || resource_code
  into   v_dept_resource_code
  from   msc_department_resources
  where department_id = arg_dept_id
  and   resource_id = arg_resource_id
  and   plan_id = arg_plan_id
  and   organization_id = arg_org_id
  and   sr_instance_id = arg_instance_id;

  return v_org_code||':'||v_dept_resource_code;
END department_resource_code;


FUNCTION resource_batchable_flag(arg_resource_id IN NUMBER,
                   arg_dept_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER) return number IS
  v_resource_batchable_flag number;
  v_org_code varchar2(15);

  CURSOR flag_c IS
  select nvl(Batchable_flag,2)
  from   msc_department_resources
  where department_id = arg_dept_id
  and   resource_id = arg_resource_id
  and   plan_id = arg_plan_id
  and   organization_id = arg_org_id
  and   sr_instance_id = arg_instance_id;

BEGIN

  if arg_resource_id =-1 or
     arg_resource_id is null or
     arg_dept_id is null or
     arg_org_id is null or
     arg_plan_id is null or
     arg_instance_id is null then
     return null;
  end if;

  OPEN flag_c;
  FETCH flag_c INTO v_resource_batchable_flag;
  CLOSE flag_c;
  return nvl(v_resource_batchable_flag,2);

END resource_batchable_flag;

FUNCTION resource_min_capacity(arg_resource_id IN NUMBER,
                   arg_dept_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER) return number is
    v_res_min_capacity number;
BEGIN

  if arg_resource_id =-1 or
     arg_resource_id is null or
     arg_dept_id is null or
     arg_org_id is null or
     arg_plan_id is null or
     arg_instance_id is null then
     return null;
  end if;

  select decode(min_capacity,0,null, min_capacity)
  into   v_res_min_capacity
  from   msc_department_resources
  where department_id = arg_dept_id
  and   resource_id = arg_resource_id
  and   plan_id = arg_plan_id
  and   organization_id = arg_org_id
  and   sr_instance_id = arg_instance_id;

  return v_res_min_capacity;
END resource_min_capacity;

FUNCTION resource_max_capacity(arg_resource_id IN NUMBER,
                   arg_dept_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER,
                   arg_supply_id IN NUMBER,
                   arg_batch_number IN NUMBER) return number is

  v_res_max_capacity number;
  v_assigned_units number;

BEGIN

  if arg_resource_id =-1 or
     arg_resource_id is null or
     arg_dept_id is null or
     arg_org_id is null or
     arg_plan_id is null or
     arg_batch_number is null or
     arg_supply_id is null or
     arg_instance_id is null then
     return null;
  end if;

  select assigned_units
  into v_assigned_units
  from msc_resource_requirements
  where department_id = arg_dept_id
  and   resource_id = arg_resource_id
  and   plan_id = arg_plan_id
  and   organization_id = arg_org_id
  and   sr_instance_id = arg_instance_id
  and   supply_id = arg_supply_id
  and   batch_number = arg_batch_number
  and   parent_id = 2
  and   rownum = 1;

  select decode(max_capacity,0 , null,max_capacity)
  into   v_res_max_capacity
  from   msc_department_resources
  where department_id = arg_dept_id
  and   resource_id = arg_resource_id
  and   plan_id = arg_plan_id
  and   organization_id = arg_org_id
  and   sr_instance_id = arg_instance_id;

  return v_res_max_capacity * v_assigned_units;

END resource_max_capacity;

/*
FUNCTION sales_order (arg_demand_id IN NUMBER)
    return varchar2
IS

order_number      varchar2(240);

cursor C4 is
  select sales_order_number
  from msc_demands
  where demand_id = arg_demand_id;
BEGIN
if arg_demand_id is null
then return null;
end if;
        OPEN C4;
        Loop
         Fetch C4 into order_number;
        Exit;
        END Loop;
        Close C4;
        return(order_number);
END sales_order;
*/

FUNCTION from_org(arg_plan_id IN NUMBER,
		  arg_transaction_id IN NUMBER,
 	     	  arg_instance_id IN NUMBER) return varchar2 IS
  l_org_id  NUMBER;
BEGIN
   if arg_plan_id is null OR arg_transaction_id is null then
     return null;
   else
    select from_organization_id
    into   l_org_id
    from   msc_interorg_ship_methods
    where  transaction_id = arg_transaction_id
    and    plan_id  = arg_plan_id;

    return msc_get_name.org_code(l_org_id,arg_instance_id);
  end if;
END;

FUNCTION to_org(arg_plan_id IN NUMBER,
		  arg_transaction_id IN NUMBER,
 	     	  arg_instance_id IN NUMBER) return varchar2 IS
  l_org_id  NUMBER;
BEGIN
   if arg_plan_id is null OR arg_transaction_id is null then
     return null;
   else
    select to_organization_id
    into   l_org_id
    from   msc_interorg_ship_methods
    where  transaction_id = arg_transaction_id
    and    plan_id  = arg_plan_id;

    return msc_get_name.org_code(l_org_id,arg_instance_id);
  end if;
END to_org;

FUNCTION from_org_id(arg_plan_id IN NUMBER,
		  arg_transaction_id IN NUMBER,
 	     	  arg_instance_id IN NUMBER) return number IS
  l_org_id  NUMBER;
BEGIN
   if arg_plan_id is null OR arg_transaction_id is null then
     return null;
   else
    select from_organization_id
    into   l_org_id
    from   msc_interorg_ship_methods
    where  transaction_id = arg_transaction_id
    and    plan_id  = arg_plan_id;

    return l_org_id;
  end if;
END;

FUNCTION to_org_id(arg_plan_id IN NUMBER,
		  arg_transaction_id IN NUMBER,
 	     	  arg_instance_id IN NUMBER) return number IS
  l_org_id  NUMBER;
BEGIN
   if arg_plan_id is null OR arg_transaction_id is null then
     return null;
   else
    select to_organization_id
    into   l_org_id
    from   msc_interorg_ship_methods
    where  transaction_id = arg_transaction_id
    and    plan_id  = arg_plan_id;

    return l_org_id;
  end if;
END;

FUNCTION ship_method(arg_plan_id IN NUMBER,
		  arg_transaction_id IN NUMBER,
 	     	  arg_instance_id IN NUMBER) return varchar2 IS
  l_ship_method  varchar2(100);
BEGIN
   if arg_plan_id is null OR arg_transaction_id is null then
     return null;
   else
    select ship_method
    into   l_ship_method
    from   msc_interorg_ship_methods
    where  transaction_id = arg_transaction_id
    and    plan_id  = arg_plan_id;

    return l_ship_method;
  end if;
END;

FUNCTION item_name(arg_item_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER) return varchar2 IS
  v_item_name varchar2(250);
BEGIN
  if arg_item_id is null or
     arg_item_id < 0 then
     return null;
  elsif arg_org_id is null or
     arg_plan_id is null or
     arg_instance_id is null then
    select item_name
    into v_item_name
    from msc_items
    where inventory_item_id = arg_item_id;
    return v_item_name;
  end if;

  select item_name
  into v_item_name
  from msc_system_items
  where inventory_item_id = arg_item_id
  and   plan_id = arg_plan_id
  and   organization_id = arg_org_id
  and   sr_instance_id = arg_instance_id
  AND  (new_plan_id = -1 OR new_plan_id IS NULL )
  AND  (SIMULATION_SET_ID IS NULL);
  return v_item_name;

  exception when no_data_found then
    select item_name
    into v_item_name
    from msc_items
    where inventory_item_id = arg_item_id;
  return v_item_name;

END item_name;

--For SRP
FUNCTION item_name(arg_item_id IN NUMBER) return varchar2 IS
	CURSOR ITEM_CUR(P_INV_ITEM_ID IN NUMBER) IS
    select ITEM_NAME
	from MSC_SYSTEM_ITEMS
	WHERE INVENTORY_ITEM_ID = P_INV_ITEM_ID
	AND PLAN_ID =-1;

    L_ITEM_NAME VARCHAR2(250);
BEGIN
	OPEN ITEM_CUR(arg_item_id);
	FETCH ITEM_cUR INTO L_ITEM_NAME;
	CLOSE ITEM_cUR;
	RETURN L_ITEM_NAME;
END item_name;

FUNCTION planner_code(arg_item_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER) return varchar2 IS
  v_planner_code varchar2(40);
BEGIN
  if ( arg_item_id is null ) or
     ( arg_item_id < 0 ) or
     ( arg_plan_id is null ) or
     ( arg_org_id is null ) or
     ( arg_instance_id is null ) then
     return null;
  end if;

  select planner_code
  into v_planner_code
  from msc_system_items
  where inventory_item_id = arg_item_id
  and   plan_id = arg_plan_id
  and   organization_id = arg_org_id
  and   sr_instance_id = arg_instance_id
  AND  (new_plan_id = -1 OR new_plan_id IS NULL )
  AND  (SIMULATION_SET_ID IS NULL);
  return v_planner_code;

  exception when no_data_found then
  return null;

END planner_code;

FUNCTION supplier(arg_supplier_id IN NUMBER) return varchar2 IS
supplier_name varchar2(240);

cursor c_supplier_name is
select partner_name
from msc_trading_partners
where partner_type=1 and
partner_id=arg_supplier_id;
BEGIN

  if arg_supplier_id is null then
     return null;
  end if;
   /*select partner_name
   into supplier_name
   from msc_trading_partners
   where partner_type=1
   and partner_id=arg_supplier_id;
*/
	open c_supplier_name;
	fetch c_supplier_name into supplier_name;
	close c_supplier_name;

   return supplier_name;

END supplier;

FUNCTION supplier_site(arg_supplier_site_id IN NUMBER) return varchar2 IS
supplier_site varchar2(240);

cursor c_supplier_site is
select tp_site_code
   from msc_trading_partner_sites
   where partner_site_id=arg_supplier_site_id;


BEGIN

  if arg_supplier_site_id is null then
     return null;
  end if;

	open c_supplier_site;
	fetch c_supplier_site into supplier_site;
	close c_supplier_site;

   return supplier_site;

END supplier_site;

FUNCTION customer(arg_customer_id IN NUMBER) return varchar2 IS
customer_name varchar2(240);
BEGIN

  if arg_customer_id is null then
     return null;
  end if;
   select partner_name
   into customer_name
   from msc_trading_partners
   where partner_type=2
   and partner_id=arg_customer_id;

   return customer_name;

END customer;

FUNCTION customer_site(arg_customer_site_id IN NUMBER) return varchar2 IS
customer_site varchar2(240);
BEGIN
  if arg_customer_site_id is null or
     arg_customer_site_id <= 0 then
     return null;
  end if;
   select location
   into customer_site
   from msc_trading_partner_sites
   where partner_site_id=arg_customer_site_id;

   return customer_site;

END customer_site;

FUNCTION customer_address(arg_customer_site_id IN NUMBER) return varchar2 IS
customer_address varchar2(1600);
BEGIN
  if arg_customer_site_id is null or
     arg_customer_site_id <= 0 then
     return null;
  end if;
   select PARTNER_ADDRESS
   into customer_address
   from msc_trading_partner_sites
   where partner_site_id=arg_customer_site_id;

   return customer_address;

END customer_address;

FUNCTION action(arg_source_table IN VARCHAR2,
                arg_bom_item_type IN NUMBER DEFAULT NULL,
                arg_base_item_id IN NUMBER DEFAULT NULL,
                arg_wip_supply_type IN NUMBER DEFAULT NULL,
                arg_order_type IN NUMBER DEFAULT NULL,
                arg_rescheduled_flag IN NUMBER DEFAULT NULL,
                arg_disposition_status_type IN NUMBER DEFAULT NULL,
                arg_new_due_date IN DATE DEFAULT NULL,
                arg_old_due_date IN DATE DEFAULT NULL,
                arg_implemented_quantity IN NUMBER DEFAULT NULL,
                arg_quantity_in_process IN NUMBER DEFAULT NULL,
                arg_quantity_rate IN NUMBER DEFAULT NULL,
		arg_release_time_fence_code IN NUMBER DEFAULT NULL,
                arg_reschedule_days IN NUMBER DEFAULT NULL,
                arg_firm_quantity IN NUMBER DEFAULT NULL,
                arg_plan_id  IN NUMBER DEFAULT NULL,
                arg_critical_component IN NUMBER DEFAULT NULL,
                arg_mrp_planning_code  IN NUMBER DEFAULT NULL,
                arg_lots_exist IN NUMBER DEFAULT NULL,
                arg_part_condition IN NUMBER DEFAULT NULL) RETURN varchar2

IS

  --CURSOR OPTIONS_C IS
  --SELECT NVL(orders_release_configs,'N'),
 	--NVL(orders_release_phantoms,'N')
  --FROM msc_workbench_display_options
  --WHERE user_id = fnd_global.user_id;

  CURSOR internal_sales(p_plan_id number,
                         p_tran_id number, p_inst_id number) IS
     select ms.disposition_status_type,
            msc_get_name.action('MSC_SUPPLIES', msi.bom_item_type,
                msi.base_item_id, msi.wip_supply_type, ms.order_type,
                DECODE(ms.firm_planned_type,1,1,ms.reschedule_flag),
                ms.disposition_status_type,
                ms.new_schedule_date, ms.old_schedule_date,
                ms.implemented_quantity, ms.quantity_in_process,
                ms.new_order_quantity,
                msi.release_time_fence_code, ms.reschedule_days,
                ms.firm_quantity,ms.plan_id,
                msi.critical_component_flag, msi.mrp_planning_code,
                msi.lots_exist)
       from msc_supplies ms,
            msc_system_items msi
       where ms.plan_id = p_plan_id
         and ms.transaction_id = p_tran_id
         and ms.sr_instance_id = p_inst_id
         and ms.plan_id = msi.plan_id
         and ms.sr_instance_id = msi.sr_instance_id
         and ms.organization_id = msi.organization_id
         and ms.inventory_item_id  = msi.inventory_item_id ;

  CURSOR excp_exist(p_plan_id number,
                         p_demand_id number) IS
     select 1
       from msc_exception_details med,
            msc_demands md
       where med.plan_id = md.plan_id
         and med.organization_id = md.organization_id
         and med.sr_instance_id = md.sr_instance_id
         and med.inventory_item_id = md.inventory_item_id
         and med.number1 = md.demand_id
         and med.exception_type in (70,71)
         and md.plan_id = p_plan_id
         and md.demand_id = p_demand_id
         and (nvl(md.source_organization_id, -1) < 0 or -- can not release ISO
               (md.source_organization_id >0 and
                md.source_org_instance_id <> md.sr_instance_id));

  CURSOR type_of_plan(p_plan_id number) IS
  select plan_type
  from   msc_plans
  where  plan_id = p_plan_id;


  l_action	VARCHAR2(80);
  l_configs	VARCHAR2(3) := 'X';
  l_phantoms	VARCHAR2(3) := 'X';
  v_temp number;
  l_plan_type   NUMBER;
  v_ir_action varchar2(80);
  l_pref_id number;

  CURSOR bkt_c(p_date date) IS
  select bucket_index
    from msc_plan_buckets mpb,
         msc_plans mp
   where mp.plan_id = arg_plan_id
     and mp.plan_id = mpb.plan_id
     and mp.organization_id = mpb.organization_id
     and mp.sr_instance_id = mpb.sr_instance_id
     and p_date between mpb.bkt_start_date and mpb.bkt_end_date;

  p_new_date_index number;
  p_old_date_index number;

BEGIN
  OPEN type_of_plan(arg_plan_id);
  FETCH type_of_plan INTO l_plan_type;
  CLOSE type_of_plan;
  IF arg_source_table = 'MSC_SUPPLIES' THEN
    IF arg_lots_exist = 2 and
       arg_order_type =5 and
       arg_quantity_rate <> 0 then
       -- plan generated planned order from supply schedule
       return msc_get_name.lookup_meaning('MRP_ACTIONS',6);
    END IF;

    IF NVL(arg_release_time_fence_code,-1) = 7 THEN
        -- Shikyu item
        return msc_get_name.lookup_meaning('MRP_ACTIONS',6);
    END IF;

    IF arg_base_item_id IS NOT NULL
	OR arg_wip_supply_type = 6 THEN
           l_pref_id := get_default_pref_id(fnd_global.user_id,l_plan_type);
           l_configs := GET_preference('ORDERS_RELEASE_CONFIGS',
                          l_pref_id,
                          l_plan_type );
           l_phantoms := GET_preference('ORDERS_RELEASE_PHANTOMS',
                          l_pref_id,
                          l_plan_type );
        --OPEN OPTIONS_C;
        --FETCH OPTIONS_C INTO l_configs, l_phantoms;
        --CLOSE OPTIONS_C;
    END IF;

    IF arg_bom_item_type IN (1, 2, 3, 5) OR
       (arg_base_item_id IS NOT NULL AND
        l_configs = 'N') OR
       (arg_wip_supply_type = 6 AND
        l_phantoms = 'N') OR
        arg_order_type IN (7, 14, 15, 16, 17, 18, 19, 27, 28)
        THEN

      -- Model Option Class
      l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',6);

    ELSE

      IF arg_rescheduled_flag = 1 and arg_order_type not in (5,51) THEN

        -- already took action
        l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',6);

      ELSIF arg_disposition_status_type = 2 THEN
        -- Cancel order
        l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',1);

      --pabram.srp.changes.added 76,77,78
      ELSIF arg_order_type in (5,51,13,76,77,78) THEN
        IF (NVL(arg_implemented_quantity, 0) +
           NVL(arg_quantity_in_process, 0) >=
           nvl(arg_firm_quantity,arg_quantity_rate))
	  OR NVL(arg_release_time_fence_code,-1) = 6 THEN

          -- nvl(arg_firm_quantity, is added for partial release
          -- Planned order has been released
          -- set action to none
          l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',6);

        ELSIF arg_order_type = 51 and
              nvl(arg_part_condition,1) = 2 THEN
          declare
            l_profile varchar2(1);
          begin
            l_profile := fnd_profile.value('MSC_ENABLE_REL_DFCT_PLAN_TRNSFRS');
            if nvl(l_profile,'N') = 'Y' Then
                -- Release
                l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',4);
            ELSE
                -- 6676007, defective part, set action to none
                l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',6);
            END IF;
          end;
        ELSE
          -- Release
          l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',4);

        END IF;

      ELSIF nvl(arg_reschedule_days,0) <> 0 THEN
--bug#1979161, new_due_date might differ from old_due_date due to nonworking
-- day issue
        IF (arg_order_type in  (8,11,12) ) then
          l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',6);
        ELSE
 --bug5984599, need to check if they are in same planning bucket
          OPEN bkt_c(trunc(arg_new_due_date));
          FETCH bkt_c INTO p_new_date_index;
          CLOSE bkt_c;

          OPEN bkt_c(trunc(arg_old_due_date));
          FETCH bkt_c INTO p_old_date_index;
          CLOSE bkt_c;

          IF p_new_date_index = p_old_date_index THEN

            l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',6);

          ELSIF trunc(arg_new_due_date) > trunc(arg_old_due_date) THEN
          -- p_old_date_index could be null, if so, use old logic

        -- Reschedule out
            l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',3);

          ELSIF trunc(arg_new_due_date) < trunc(arg_old_due_date) THEN

        -- Reschedule in
            l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',2);
          END IF;
        END IF;
      ELSIF arg_order_type in (4,13) THEN
        IF arg_bom_item_type IN (1, 2, 3, 5) THEN

          -- Model option class
          l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',6);

        ELSE

          -- Release
          l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',4);
        END IF;
      ELSE

        -- Action is not required.
        l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',6);
      END IF;
    END IF;
    -- action should be set to NONE for the critical components
    -- Plan type = MPS, item attribute <>( MPS planning  or  MPS/DRP planning),
    -- Plan type = DRP, item attribute <> (DRP planning
                    --       or MRP/DRP planning or  MPS/DRP  planning) .
    -- ASCP UI displays action NONE for all critical components.
    IF arg_critical_component  = 1  THEN
       --OPEN type_of_plan(arg_plan_id);
       --FETCH type_of_plan INTO l_plan_type;
       --CLOSE type_of_plan;

       IF l_plan_type = 2  and  -- MPS
          arg_mrp_planning_code not in (4,8 ) THEN

           l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',6);

       ELSIF l_plan_type = 3  and -- DRP
             arg_mrp_planning_code NOT in (9, 7, 8)   THEN

           l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',6);

       END IF;
    END IF;

  ELSE

    -- This record does note come from MSC_SUPPLIES
    l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',6);
    IF NVL(arg_release_time_fence_code,-1) = 7 THEN
        -- Shikyu item
        RETURN l_action;
    END IF;

    if arg_source_table = 'MSC_DEMANDS' and
         arg_plan_id <> -1 and -- plan_id <> -1
         arg_order_type in (30,6) then -- sales order
         OPEN internal_sales(arg_plan_id, -- plan_id
                             arg_base_item_id,  -- disposition_id
                             arg_wip_supply_type); -- sr_instance_id
         FETCH internal_sales INTO v_temp, v_ir_action;
         CLOSE internal_sales;
         -- IRproject
         --if v_temp = 2 then -- cancel
         --   l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',1);
         if arg_bom_item_type in ( 5, 1)  and -- plan_type
               v_ir_action is not null then -- use action from related IR
            l_action := v_ir_action;
         else
            if  arg_rescheduled_flag = 1 then -- already reschedule
                -- none
                l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',6);
            elsif arg_quantity_rate <>
                      nvl(arg_firm_quantity, -- old_demand_qty
                          arg_quantity_rate) then
                -- can not release split so, bug6122088
                -- none
                l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',6);
            elsif arg_release_time_fence_code <> -- inventory_item_id
                  arg_reschedule_days and
                  arg_reschedule_days <> 0 then -- original_item_id
                    -- release, bug5972090
                    -- item_id <> original_item_id and not split
                    l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',4);
            else
                if arg_bom_item_type = 5 then -- plan_type
                   if nvl(arg_implemented_quantity,2) =1 or --sales_order_line_split
                      nvl(arg_quantity_in_process,2) =1 then --fill_kill_flag
                      l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',6);
                      return l_action;
                   end if;
                end if;
                v_temp :=0;
                OPEN excp_exist(arg_plan_id, -- plan_id
                        arg_disposition_status_type); -- demand_id
                FETCH excp_exist INTO v_temp;
                CLOSE excp_exist;

                if v_temp = 1 then -- Sales Order changes excp exists
                    -- release
                    l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',4);
                else
                    -- none
                    l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',6);
                end if;
            end if; -- if  arg_rescheduled_flag = 1
         end if; -- if v_temp = 2 then -- cancel
    end if; -- if arg_source_table = 'MSC_DEMANDS'


  END IF;
  return l_action;
END action;

/* this function takes a date and a number (seconds to represent the
   time since 00:00:00 of this date) and return a date */
FUNCTION Date_Timenum_to_DATE(dt dATE, time number)
  RETURN DATE
  IS
BEGIN
  return float_to_DT(DT_to_float(dt) + time/86400);
END Date_Timenum_to_DATE;

/* this function returns the julian date in floating point format */
FUNCTION DT_to_float(dt DATE)
  RETURN NUMBER
  IS
BEGIN
   RETURN to_number(dt - to_date(1,'J'))+1;

END DT_to_float;

/* this function takes a julian date in a floating point format and returns a date */
FUNCTION float_to_DT(fdt NUMBER)
  RETURN DATE
  IS
BEGIN
   RETURN to_date(1,'J')+(fdt-1);

END float_to_DT;

-- This procedure executes dynamic sql because we cannot run
-- it on the client
PROCEDURE execute_dsql(arg_sql_stmt VARCHAR2) IS

BEGIN

  EXECUTE IMMEDIATE arg_sql_stmt;

END execute_dsql;

FUNCTION cfm_routing_flag(p_plan_id IN NUMBER,
        p_org_id IN NUMBER,
        p_instance_id IN NUMBER,
        p_item_id IN NUMBER,
        p_alt_rtg_desig IN VARCHAR2) return number IS

  CURSOR ALT_RTG_C IS
  SELECT cfm_routing_flag
  FROM msc_routings
  WHERE plan_id = p_plan_id
    AND sr_instance_id = p_instance_id
    AND organization_id = p_org_id
    AND assembly_item_id  = p_item_id
    AND alternate_routing_designator = p_alt_rtg_desig;

  CURSOR NULL_ALT_RTG_C IS
  SELECT cfm_routing_flag
  FROM msc_routings
  WHERE plan_id = p_plan_id
    AND sr_instance_id = p_instance_id
    AND organization_id = p_org_id
    AND assembly_item_id  = p_item_id
    AND alternate_routing_designator IS NULL;

  l_cfm_routing_flag	NUMBER;

BEGIN

  IF p_alt_rtg_desig IS NULL THEN
    OPEN NULL_ALT_RTG_C;
    FETCH NULL_ALT_RTG_C INTO l_cfm_routing_flag;
    CLOSE NULL_ALT_RTG_C;
  ELSE
    OPEN ALT_RTG_C;
    FETCH ALT_RTG_C INTO l_cfm_routing_flag;
    CLOSE ALT_RTG_C;
  END IF;

  return(l_cfm_routing_flag);

END cfm_routing_flag;

FUNCTION alternate_bom(p_plan_id IN NUMBER,
        p_instance_id IN NUMBER,
        p_seq_id IN NUMBER) return varchar2 IS

  CURSOR ALT_BOM_C IS
  SELECT alternate_bom_designator
  FROM msc_boms
  WHERE plan_id = p_plan_id
    AND sr_instance_id = p_instance_id
    AND bill_sequence_id = p_seq_id;

  l_alt_bom	VARCHAR2(40); --5338566 bugfix, length changed to 40

BEGIN

  if p_seq_id is null then
     return null;
  end if;

  OPEN ALT_BOM_C;
  FETCH ALT_BOM_C INTO l_alt_bom;
  CLOSE ALT_BOM_C;

  return(l_alt_bom);

END alternate_bom;

FUNCTION alternate_rtg(p_plan_id IN NUMBER,
        p_instance_id IN NUMBER,
        p_seq_id IN NUMBER) return varchar2 IS

  CURSOR ALT_RTG_C IS
  SELECT alternate_routing_designator
  FROM msc_routings
  WHERE plan_id = p_plan_id
    AND sr_instance_id = p_instance_id
    AND routing_sequence_id = p_seq_id;

  l_alt_rtg	VARCHAR2(40); --5338566 bugfix, length changed to 40


BEGIN

  if p_seq_id is null then
     return null;
  end if;

  OPEN ALT_RTG_C;
  FETCH ALT_RTG_C INTO l_alt_rtg;
  CLOSE ALT_RTG_C;

  return(l_alt_rtg);

END alternate_rtg;

FUNCTION cfm_routing_flag(p_plan_id IN NUMBER,
        p_instance_id IN NUMBER,
        p_seq_id IN NUMBER) return number IS

  CURSOR ALT_RTG_C IS
  SELECT cfm_routing_flag
  FROM msc_routings
  WHERE plan_id = p_plan_id
    AND sr_instance_id = p_instance_id
    AND routing_sequence_id = p_seq_id;

  l_cfm_routing_flag	NUMBER;

BEGIN

  if p_seq_id is null then
     return null;
  end if;

  OPEN ALT_RTG_C;
  FETCH ALT_RTG_C INTO l_cfm_routing_flag;
  CLOSE ALT_RTG_C;

  return(l_cfm_routing_flag);

END cfm_routing_flag;

--#2479454 bug-fix
--p_fcst_set_id param added
--so that if this is passed,return fcst name designator , else return the designator
FUNCTION designator(p_desig_id IN NUMBER,
	p_fcst_set_id IN NUMBER default NULL,
        p_plan_id     IN NUMBER default NULL ) return varchar2 IS

  CURSOR DESIG_C(v_desig_id number) IS
  SELECT designator, forecast_set_id
  FROM msc_designators
  WHERE designator_id = v_desig_id;

  CURSOR DESIG_FC IS
  SELECT designator
  FROM msc_designators
  WHERE forecast_set_id = p_fcst_set_id
  and designator_id = p_desig_id;

  v_fcst_set_id number;
  v_fcst_set varchar2(30);
  l_desig	VARCHAR2(30);

-- modification for bug 2765939
-- Return null if it is a dp scenario and the plan_id is passed in function call
  cursor is_forecast_c is
  select 1
  from msc_designators desig,
       msc_plan_schedules sch
  where desig.designator_id = p_desig_id
  and   desig.designator_type = 6
  and   sch.plan_id=p_plan_id
  and   sch.input_schedule_id = desig.forecast_set_id;

  is_forecast number;

BEGIN
if p_plan_id is null then
  if p_desig_id is null then
     return null;
  end if;

  if ( p_fcst_set_id is not null ) then

    OPEN DESIG_FC;
    FETCH DESIG_FC INTO l_desig;
    CLOSE DESIG_FC;

    return(l_desig);
  end if;

  OPEN DESIG_C(p_desig_id);
  FETCH DESIG_C INTO l_desig, v_fcst_set_id;
  CLOSE DESIG_C;

  IF v_fcst_set_id is not null and
     p_fcst_set_id is null THEN
     -- 5496276, if p_fcst_set_id is not null,
     -- fcst_name might be shown arleady in function scenario_designator
     OPEN DESIG_C(v_fcst_set_id);
     FETCH DESIG_C INTO v_fcst_set, v_fcst_set_id;
     CLOSE DESIG_C;
     l_desig := v_fcst_set||'/'||l_desig;
  END IF;

  return(l_desig);
else -- if p_plan_id is not null then
  if (p_desig_id is null ) then
    return null;
  end if;

 is_forecast := 0;

    OPEN   is_forecast_c;
    FETCH  is_forecast_c into is_forecast;
    CLOSE  is_forecast_c;

    if is_forecast = 1 then -- forecast
      OPEN DESIG_C(p_desig_id);
      FETCH DESIG_C INTO l_desig, v_fcst_set_id;
      CLOSE DESIG_C;

      return(l_desig);
    else
      return null;
    end if;

end if;
END designator;
-- Rama Rao
-- 04/12/01
-- Modified the scenario_designator function to remove the organization_id condition
-- from the where clause of c_scenario_name cursor. Made the same change to the
-- forecastsetname function.

FUNCTION scenario_designator(p_desig_id IN NUMBER,
                             p_plan_id IN NUMBER,
                             p_organization_id IN NUMBER,
                             p_instance_id IN NUMBER) RETURN VARCHAR2 IS


  cursor c_designator_type_g is
  SELECT designator_type
  FROM msc_plan_schedules
  WHERE plan_id = p_plan_id
  AND organization_id = -1
  AND sr_instance_id = p_instance_id
  AND input_schedule_id = p_desig_id;

  CURSOR c_designator_type IS
  SELECT designator_type
  FROM msc_plan_schedules
  WHERE plan_id = p_plan_id
  AND organization_id = p_organization_id
  AND sr_instance_id = p_instance_id
  AND input_schedule_id = p_desig_id;

 CURSOR c_coll_designator_type IS
  SELECT designator_type
  FROM msc_plan_schedules
  WHERE organization_id = p_organization_id
  AND sr_instance_id = p_instance_id
  AND input_schedule_id = p_desig_id;

  CURSOR DESIG_C IS
  SELECT designator
  FROM msc_designators
  WHERE designator_id = p_desig_id;

  CURSOR c_scenario_name IS
  SELECT scenario_name
  FROM msd_dp_ascp_scenarios_v
  WHERE scenario_id = p_desig_id
 -- AND organization_id = p_organization_id
  -- AND sr_instance_id = p_instance_id; for bug 6040537
  and decode(sr_instance_id,
-23453, p_instance_id, sr_instance_id) = p_instance_id;

  l_desig	VARCHAR2(30);
  l_designator_type NUMBER;

  cursor l_count_c is
  SELECT count(*)
  FROM msc_plan_schedules
  WHERE plan_id = p_plan_id
  AND organization_id = p_organization_id
  AND sr_instance_id = p_instance_id
  AND input_schedule_id = p_desig_id;

  l_count number;

BEGIN

  if p_desig_id is null then
     return null;
  end if;

  if p_plan_id <> -1 then
    open l_count_c;
    fetch l_count_c into l_count;
    close l_count_c;
--    dbms_output.put_line('count is' || l_count);
    if l_count = 0 then
      OPEN c_designator_type_g;
      FETCH c_designator_type_g INTO l_designator_type;
      close c_designator_type_g;
    else
      OPEN c_designator_type;
      FETCH c_designator_type INTO l_designator_type;
      CLOSE c_designator_type;
    end if;
  else
    OPEN c_coll_designator_type;
    FETCH c_coll_designator_type INTO l_designator_type;
    CLOSE c_coll_designator_type;
  end if;


--    dbms_output.put_line('designator type is ' || l_designator_type);
  IF l_designator_type = 6 THEN
     OPEN DESIG_C;
     FETCH DESIG_C INTO l_desig;
     CLOSE DESIG_C;
  ELSIF l_designator_type = 7 THEN
     OPEN c_scenario_name;
     FETCH c_scenario_name INTO l_desig;
     CLOSE c_scenario_name;
  END IF;

  return(l_desig);

END scenario_designator;

FUNCTION forecastsetname(p_desig_id IN NUMBER,
                         p_plan_id IN NUMBER,
                         p_organization_id IN NUMBER,
                         p_instance_id IN NUMBER) RETURN VARCHAR2 IS
-- This cursor will return data only if p_desig_id is not forecast
-- cnazarma

  CURSOR c_designator_type IS
  SELECT designator_type
  FROM msc_plan_schedules
  WHERE plan_id = p_plan_id
  AND organization_id = p_organization_id
  AND sr_instance_id = p_instance_id
  AND input_schedule_id = p_desig_id;

  CURSOR forecastset_name IS
  SELECT designator
  FROM msc_designators
  WHERE designator_id = (SELECT NVL(forecast_set_id,p_desig_id)
                         FROM msc_designators
                         WHERE designator_id = p_desig_id
                         AND designator_type = 6);

  CURSOR c_scenario_name IS
  SELECT scenario_name
  FROM msd_dp_ascp_scenarios_v
  WHERE scenario_id = p_desig_id
 -- AND organization_id = p_organization_id
 -- AND sr_instance_id = p_instance_id; -- for bug 6040537
 and decode(sr_instance_id,
-23453, p_instance_id, sr_instance_id) = p_instance_id;

  l_forecastset_name VARCHAR2(80);
  l_designator_type NUMBER;

BEGIN

  IF p_desig_id is null then
     return null;
  END IF;

  OPEN c_designator_type;
  FETCH c_designator_type INTO l_designator_type;
  CLOSE c_designator_type;


IF l_designator_type = 7 THEN

   OPEN c_scenario_name;
     FETCH c_scenario_name INTO l_forecastset_name;
     CLOSE c_scenario_name;
ELSE

   OPEN FORECASTSET_NAME;
     FETCH FORECASTSET_NAME INTO l_forecastset_name;
     CLOSE FORECASTSET_NAME;
END IF;


  return(l_forecastset_name);

END forecastsetname;


FUNCTION wip_status(p_transaction_id IN NUMBER) return number IS

  CURSOR wip_cur IS
  SELECT wip_status_code
  FROM msc_supplies
  WHERE plan_id = -1
   and transaction_id = p_transaction_id;
  l_status number;

BEGIN
  Open wip_cur;
  Fetch wip_cur Into l_status;
  Close wip_cur;

  return(l_status);

END wip_status;

FUNCTION source_demand_priority(p_plan_id number,
                                p_demand_id NUMBER) return number IS

  CURSOR dmd_cur IS
  SELECT order_priority
  FROM msc_demands
  WHERE plan_id = p_plan_id
   and demand_id = p_demand_id;
  l_priority number;

BEGIN
  Open dmd_cur;
  Fetch dmd_cur Into l_priority;
  Close dmd_cur;

  return(l_priority);

END source_demand_priority;

FUNCTION batchable_uom(p_organization_id number,
                       p_department_id   number,
                       p_resource_id     number) return varchar2 IS

  CURSOR batchable_uom_cur IS
  SELECT unit_of_measure
  FROM msc_department_resources
  WHERE plan_id > -1
   and  organization_id = p_organization_id
   and  department_id   = p_department_id
   and  resource_id     = p_resource_id;

  l_batchable_uom varchar2(3);

BEGIN
  Open batchable_uom_cur;
  Fetch batchable_uom_cur Into l_batchable_uom;
  Close batchable_uom_cur;

  return(l_batchable_uom);

END batchable_uom;

FUNCTION plan_name(p_plan_id number) return varchar2  IS

  CURSOR plan_name_cur IS
  SELECT compile_designator
  FROM msc_plans
  WHERE plan_id = p_plan_id;
  l_plan_name varchar2(30);

BEGIN
  Open plan_name_cur;
  Fetch plan_name_cur Into l_plan_name;
  Close plan_name_cur;

  return(l_plan_name);

END plan_name;
-- new function to calculate the number of workdays between two dates
FUNCTION get_number_work_days(start_date date,
                              end_date date,
                              p_org_id number,
                              p_inst_id number) return number IS
v_start_seq NUMBER;
v_end_seq   NUMBER;
calendar_code     VARCHAR2(14);
exc_set_id        NUMBER;


CURSOR seqnum_cursor(p_date DATE) IS
    SELECT next_seq_num
    FROM   msc_calendar_dates
    WHERE  calendar_code = calendar_code
    AND    exception_set_id = exc_set_id
    AND    sr_instance_id = p_inst_id
    AND    calendar_date = p_date;

CURSOR prior_seqnum_cursor(p_date DATE) IS
    SELECT prior_seq_num
    FROM   msc_calendar_dates
    WHERE  calendar_code = calendar_code
    AND    exception_set_id = exc_set_id
    AND    sr_instance_id = p_inst_id
    AND    calendar_date = p_date;

BEGIN
  -- --------------------------
  -- initialize calendar code
  -- --------------------------
  SELECT calendar_code, calendar_exception_set_id
  INTO   calendar_code, exc_set_id
  FROM   msc_trading_partners
  WHERE  sr_tp_id = p_org_id
    AND  sr_instance_id = p_inst_id
    AND  partner_type = 3;

  IF (trunc(start_date) <= trunc(end_date)) THEN
    OPEN seqnum_cursor(trunc(start_date));
    FETCH seqnum_cursor INTO v_start_seq;
    CLOSE seqnum_cursor;
    OPEN prior_seqnum_cursor(trunc(end_date));
    FETCH prior_seqnum_cursor INTO v_end_seq;
    CLOSE prior_seqnum_cursor;
    if ( v_end_seq - v_start_seq + 1) <= 0 then return 1; end if;
    return (v_end_seq - v_start_seq + 1);
  ELSE
    return(0);
  END IF;

END get_number_work_days;

FUNCTION demand_quantity(p_plan_id number,
                         p_inst_id number,
                         p_demand_id NUMBER) return number IS


  l_qty number;
  l_group_id NUMBER;

  CURSOR grp_cur IS
  SELECT group_id
  FROM   msc_demands
  WHERE  plan_id = p_plan_id
  AND    sr_instance_id = p_inst_id
  AND    demand_id = p_demand_id;


  -- bug 2740285. Add check for group_id before
  -- opening the expensive dmd_cur.

  CURSOR dmd_cur IS
  SELECT sum(using_requirement_quantity)
  FROM   msc_demands
  WHERE  plan_id = p_plan_id
  and    sr_instance_id = p_inst_id
  and    group_id = l_group_id;

BEGIN
  if ( p_plan_id is null OR p_inst_id is null or p_demand_id is null ) then
    return null;
  end if;
  OPEN grp_cur;
  FETCH grp_cur INTO l_group_id;
  CLOSE grp_cur;
  IF l_group_id IS NOT NULL THEN
    Open dmd_cur;
    Fetch dmd_cur Into l_qty;
    Close dmd_cur;
    return(l_qty);
  ELSE
    return NULL;
  END IF;
END demand_quantity;

  FUNCTION demand_order_number (p_plan_id number,
                           p_inst_id number,
                           p_demand_id NUMBER) return varchar2 IS

   cursor c_demand_order_number is
   SELECT NVL(dem.order_number,
   decode(dem.origination_type,1, to_char(dem.disposition_id),
     3, msc_get_name.job_name(dem.disposition_id, dem.plan_id, dem.sr_instance_id),
      22, to_char(dem.disposition_id),
      29,decode(dem.plan_id, -11,   msc_get_name.designator(dem.schedule_designator_id) ,
                       decode(msi.in_source_plan,1,msc_get_name.designator(dem.schedule_designator_id,
                                                                                                                                    dem.forecast_set_id ),
	msc_get_name.scenario_designator(dem.forecast_set_id,	dem.plan_id, dem.organization_id, dem.sr_instance_id)
	|| decode(msc_get_name.designator(dem.schedule_designator_id,dem.forecast_set_id ), null, null,  '/'||msc_get_name.designator(dem.schedule_designator_id,dem.forecast_set_id )))),
   msc_get_name.designator(dem.schedule_designator_id))) order_number
   from msc_demands dem, msc_system_items msi
   where dem.plan_id = p_plan_id
   and dem.sr_instance_id = p_inst_id
   and dem.demand_id = p_demand_id
   AND dem.plan_id = msi.plan_id
   AND dem.sr_instance_id = msi.sr_instance_id
   AND dem.ORGANIZATION_ID = msi.ORGANIZATION_ID
  AND dem.INVENTORY_ITEM_ID = msi.INVENTORY_ITEM_ID ;

  cursor c_so_number is
  select sales_order_number
  from msc_sales_orders
  where sr_instance_id = p_inst_id
  and demand_id = p_demand_id;

  l_order_number varchar2(200);

  BEGIN
    if ( p_plan_id is null OR p_inst_id is null or p_demand_id is null ) then
      return null;
    end if;
    Open c_demand_order_number;
    Fetch c_demand_order_number Into l_order_number;
    Close c_demand_order_number;

    if (l_order_number is null) then
      Open c_so_number;
      Fetch c_so_number Into l_order_number;
      Close c_so_number;
    end if;

    return(l_order_number);

  END demand_order_number ;

FUNCTION ABC_CLASS_ID (p_org_id number,
                      p_inst_id number) return number is
l_abc_class_id number;
cursor abc_class_c (lp_org_id number,
                     lp_inst_id number) is
SELECT abc_class_id
 FROM msc_abc_classes
 WHERE organization_id =  lp_org_id
 AND sr_instance_id =   lp_inst_id
 ;
begin
   open abc_class_c(p_org_id, p_inst_id);
   fetch abc_class_c into l_abc_class_id;
   close abc_class_c;

   return l_abc_class_id;

end ABC_CLASS_ID;

FUNCTION DEMAND_CLASS (p_inst_id number,
                       p_org_id number,
                       p_plan  varchar2) return varchar2 is

     cursor c_dmdclass is
     select d.demand_class
     from msc_designators d
     where NVL(D.DESIGNATOR_TYPE,3) IN (2, 3, 4,5,-99)
     AND D.SR_INSTANCE_ID = p_inst_id
     AND D.ORGANIZATION_ID = p_org_id
     AND D.DESIGNATOR = p_plan ;

  l_temp varchar2(100);
begin
  if (p_inst_id is null or p_org_id is null or p_plan is null) then
    return null;
  else
   open c_dmdclass;
   fetch c_dmdclass into l_temp;
   close c_dmdclass;
  end if;
   return l_temp;
end ;


FUNCTION DMD_PRIORITY_RULE (p_rule_id number) return varchar2 is
  cursor c_rule is
  select msr.meaning
  from msc_scheduling_rules msr
  where msr.rule_id = p_RULE_ID
  and nvl(msr.enabled_flag, 'Y') = 'Y';

  l_temp varchar2(240);
begin
  if (p_rule_id is null) then
    return null;
  else
    open c_rule;
    fetch c_rule into l_temp;
    close c_rule;
  end if;
   return l_temp;
end ;

FUNCTION OP_SEQ_NUM (p_plan_id number,
                     p_inst_id number,
                     p_org_id number,
                     p_comp_seq_id number,
                     p_bill_seq_id number,
                     p_arg_1 number ) return varchar2 is
cursor c_op_seq_num is
   select distinct mro.operation_seq_num
   from msc_operation_components moc,
     msc_routing_operations mro, msc_bom_components assy
   where moc.plan_id(+)= -1
     and moc.component_sequence_id(+)= assy.component_sequence_id
     and moc.sr_instance_id(+)= assy.sr_instance_id
     and moc.bill_sequence_id(+)= assy.bill_sequence_id
     and moc.plan_id=mro.plan_id(+)
     and moc.operation_sequence_id = mro.operation_sequence_id(+)
     and moc.sr_instance_id = mro.sr_instance_id(+)
     and moc.routing_sequence_id = mro.routing_sequence_id(+)
     and assy.plan_id = p_plan_id
     and assy.sr_instance_id = p_inst_id
     and assy.organization_id = p_org_id
     and assy.component_sequence_id = p_comp_seq_id
     and assy.bill_sequence_id = p_bill_seq_id ;
  l_temp varchar2(240);
begin
  if (p_plan_id is null or
      p_inst_id is null or
      p_org_id is null or
      p_comp_seq_id is null or
      p_bill_seq_id is null) then
    return null;
  else
    open c_op_seq_num;
    fetch c_op_seq_num into l_temp;
    close c_op_seq_num;
  end if;
   return l_temp;
exception
  when no_data_found then
    return null;
end ;


FUNCTION ss_method_text (p_plan_id in number,
         p_org_id in number, p_inst_id in number, p_item_id in number)
  return VARCHAR2 IS
  cursor l_ss_method is
  select decode(safety_stock_code,
        1,'Non-MRP Planned Percent',
        2,'MRP Planned Percent',null)
  from msc_system_items
  where plan_id = p_plan_id
  and sr_instancE_id = p_inst_id
  and organization_id = p_org_id
  and inventory_item_id = p_item_id;

  l_ss_method_text varchar2(100);

BEGIN
  open l_ss_method;
  fetch l_ss_method into l_ss_method_text;
  close l_ss_method;

  return l_ss_method_text;
END ss_method_text;

FUNCTION demand_name (p_plan_id number, p_demand_id number)
               return varchar2 IS
 v_txt varchar2(100);
 cursor demand_c is
   select nvl(order_number,
              decode(origination_type,
                1,to_char(disposition_id),
               29, msc_get_name.scenario_designator(
                     forecast_set_id,plan_id,organization_id,sr_instance_id),
               msc_get_name.designator(schedule_designator_id)
                    )
               )
     from msc_demands
    where plan_id = p_plan_id
      and demand_id = p_demand_id;
BEGIN
 if p_plan_id is null or
    p_demand_id is null then
    return null;
 end if;
   OPEN demand_c;
   FETCH demand_c INTO v_txt;
   CLOSE demand_c;

   return v_txt;
END demand_name;

FUNCTION forward_backward_days(p_plan_id number,
                               p_schedule_desig_id number,
                               p_fb_type number)
               return number  IS
-- Modified to check the existance of forecast by joining msc_designators
-- to msc_plan_schedules
-- Also modified  to remove the sub queries
  cursor is_forecast_c is
  select 1
  from msc_designators desig,
       msc_plan_schedules sch
  where desig.designator_id = p_schedule_desig_id
  and   desig.designator_type = 6
  and   sch.plan_id=p_plan_id
  and   sch.input_schedule_id = desig.forecast_set_id;

  cursor is_forecast_cwb_c is
  select 1
  from msc_designators desig
  where desig.designator_id = p_schedule_desig_id
  and   desig.designator_type = 6;

  CURSOR is_dp_scenario_c is
  SELECT 1
  from  msc_plan_schedules
  where plan_id = p_plan_id
  and   input_schedule_id=p_schedule_desig_id
  and   designator_type=7;

  CURSOR forward_backward_days_c1 IS
  SELECT FORWARD_UPDATE_TIME_FENCE,
         BACKWARD_UPDATE_TIME_FENCE
  FROM msc_designators
  WHERE designator_id = p_schedule_desig_id;

  CURSOR forward_backward_days_c2 IS
  SELECT curr_FORWARD_days,
         curr_BACKWARD_days
  FROM msc_plans
  WHERE plan_id = p_plan_id;

  l_forward_days number;
  l_backward_days number;

  is_forecast number;
  is_dp_scenario number;

BEGIN
 if (p_plan_id is null or
     p_schedule_desig_id is null  or
     p_fb_type not in (1,2)) then
    return null;
 end if;

 is_forecast := 0;
 is_dp_scenario := 0;
    if p_plan_id = -1 then
      OPEN   is_forecast_cwb_c;
      FETCH  is_forecast_cwb_c into is_forecast;
      CLOSE  is_forecast_cwb_c;
    else
      OPEN   is_forecast_c;
      FETCH  is_forecast_c into is_forecast;
      CLOSE  is_forecast_c;
    end if;

    if is_forecast = 1 then -- forecast
      OPEN   forward_backward_days_c1;
      FETCH  forward_backward_days_c1 INTO l_forward_days, l_backward_days;
      CLOSE  forward_backward_days_c1;
    else
      OPEN   is_dp_scenario_c;
      FETCH  is_dp_scenario_c into is_dp_scenario;
      CLOSE  is_dp_scenario_c;

      if is_dp_scenario = 1 then -- dp scenario
        OPEN   forward_backward_days_c2;
        FETCH  forward_backward_days_c2 INTO l_forward_days, l_backward_days;
        CLOSE  forward_backward_days_c2;
      else
        l_forward_days := null;
        l_backward_days := null;
      end if;
    end if;


    if p_fb_type = 1 then
      return(l_forward_days);
    else
      return(l_backward_days);
    end if;

end forward_backward_days;

FUNCTION category_desc(arg_category_name IN VARCHAR2,
                       arg_category_set_id IN NUMBER,
                       arg_org_id IN NUMBER,
                       arg_instance_id IN NUMBER) return varchar2 IS

  category_description msc_item_categories.description%type;

 CURSOR category_desc_org IS
   SELECT description
     FROM msc_item_categories
    WHERE category_set_id = arg_category_set_id
      AND category_name = arg_category_name
      AND sr_instance_id = arg_instance_id
      AND organization_id = arg_org_id
      AND description is NOT NULL
      AND rownum<2;

 CURSOR category_desc_ins IS
   SELECT description
     FROM msc_item_categories
    WHERE category_set_id = arg_category_set_id
      AND category_name = arg_category_name
      AND sr_instance_id = arg_instance_id
      AND description is NOT NULL
      AND rownum<2;

  CURSOR category_desc IS
   SELECT description
     FROM msc_item_categories
    WHERE category_set_id = arg_category_set_id
      AND category_name = arg_category_name
      AND description is NOT NULL
      AND rownum<2;

   BEGIN

  if ( arg_category_name is null ) or
     ( arg_category_set_id is null ) then
     return null;
  end if;

  IF arg_org_id is NOT NULL AND arg_instance_id is not NULL THEN

     OPEN category_desc_org;
       FETCH category_desc_org INTO category_description;
     CLOSE category_desc_org;
     return category_description;

   ELSIF arg_org_id is NULL AND arg_instance_id is not NULL THEN

     OPEN category_desc_ins;
       FETCH category_desc_ins INTO category_description;
     CLOSE category_desc_ins;
     return category_description;

 ELSIF arg_org_id is NULL AND arg_instance_id is NULL THEN

     OPEN category_desc;
       FETCH category_desc INTO category_description;
     CLOSE category_desc;
     return category_description;

  ELSE
    return NULL;
   END IF;

  exception when no_data_found then
     return null;

END category_desc;

FUNCTION MSCX_CUST_SHIP_DATE(arg_exception_id IN NUMBER) return date is
  l_date date;
BEGIN
   if arg_exception_id is null OR
     arg_exception_id <1000 then
     return to_date(null);
   end if;

   select decode(exception_column,
        'DATE1',date1,'DATE2',date2,'DATE3',date3,'DATE4',date4,
		'DATE5',date5,'DATE6',date6,'DATE7',date7)
   into l_date
   from msc_user_exception_components muec,
        msc_x_exception_details mxed
   where muec.exception_id = mxed.exception_type
   and mxed.exception_detail_id = arg_exception_id
   and muec.component_type = 1
   and muec.ak_attribute_code = 'MSCX_CUST_SHIP_DATE';
   return l_date;
exception
  when no_data_found then
     return to_date(null);
END MSCX_CUST_SHIP_DATE;

FUNCTION MSCX_UDE_PUB_ORDER_TYPE (arg_exception_id IN NUMBER) return number is
  l_temp number;
BEGIN
   if arg_exception_id is null OR
     arg_exception_id <1000 then
     return to_number(null);
   end if;

   select decode(muec.exception_column, 'NUMBER1',NUMBER1,'NUMBER2',NUMBER2,
	'NUMBER3',NUMBER3,'NUMBER4',NUMBER4,'NUMBER5',NUMBER5,'NUMBER6',NUMBER6,'NUMBER7',NUMBER7)
   into l_temp
   from msc_user_exception_components muec,
        msc_x_exception_details mxed
   where muec.exception_id = mxed.exception_type
   and mxed.exception_detail_id = arg_exception_id
   and muec.component_type = 1
   and muec.ak_attribute_code = 'MSCX_UDE_PUB_ORDER_TYPE';
   return l_temp;
exception
  when no_data_found then
     return to_number(null);
END MSCX_UDE_PUB_ORDER_TYPE;

FUNCTION MSCX_PLANNER_CODE (arg_exception_id IN NUMBER) return varchar2 is
  l_temp varchar2(250);
BEGIN
   if arg_exception_id is null OR
     arg_exception_id <1000 then
     return null;
   end if;

   select decode(muec.exception_column,
	'USER_ATTRIBUTE1',USER_ATTRIBUTE1,'USER_ATTRIBUTE2',USER_ATTRIBUTE2,
	'USER_ATTRIBUTE3',USER_ATTRIBUTE3,'USER_ATTRIBUTE4',USER_ATTRIBUTE4,
	'USER_ATTRIBUTE5',USER_ATTRIBUTE5,'USER_ATTRIBUTE6',USER_ATTRIBUTE6,
	'USER_ATTRIBUTE7',USER_ATTRIBUTE7)
   into l_temp
   from msc_user_exception_components muec,
        msc_x_exception_details mxed
   where muec.exception_id = mxed.exception_type
   and mxed.exception_detail_id = arg_exception_id
   and muec.component_type = 1
   and muec.ak_attribute_code = 'MSCX_PLANNER_CODE';
   return l_temp;
exception
  when no_data_found then
     return null;
END MSCX_PLANNER_CODE;

FUNCTION MSCX_QUANTITY (arg_exception_id IN NUMBER) return number is
  l_temp number;
BEGIN
   if arg_exception_id is null OR
     arg_exception_id <1000 then
     return to_number(null);
   end if;

   select decode(muec.exception_column, 'NUMBER1',NUMBER1,'NUMBER2',NUMBER2,
	'NUMBER3',NUMBER3,'NUMBER4',NUMBER4,'NUMBER5',NUMBER5,
	'NUMBER6',NUMBER6,'NUMBER7',NUMBER7)
   into l_temp
   from msc_user_exception_components muec,
        msc_x_exception_details mxed
   where muec.exception_id = mxed.exception_type
   and mxed.exception_detail_id = arg_exception_id
   and muec.component_type = 1
   and muec.ak_attribute_code = 'MSCX_QUANTITY';
   return l_temp;
exception
   when no_data_found then
     return to_number(null);
END MSCX_QUANTITY;

FUNCTION MSCX_COMP_RECEIPT_DATE (arg_exception_id IN NUMBER) return date is
  l_temp date;
BEGIN
   if arg_exception_id is null OR
     arg_exception_id <1000 then
     return to_date(null);
   end if;

   select decode(muec.exception_column, 'DATE1',date1,'DATE2',date2,'DATE3',date3,
	'DATE4',date4,'DATE5',date5,'DATE6',date6,'DATE7',date7)
   into l_temp
   from msc_user_exception_components muec,
        msc_x_exception_details mxed
   where muec.exception_id = mxed.exception_type
   and mxed.exception_detail_id = arg_exception_id
   and muec.component_type = 1
   and muec.ak_attribute_code = 'MSCX_COMP_RECEIPT_DATE';
   return l_temp;
exception
   when no_data_found then
     return to_date(null);
END MSCX_COMP_RECEIPT_DATE;

FUNCTION MSCX_COMP_REQUEST_DATE (arg_exception_id IN NUMBER) return date is
  l_temp date;
BEGIN
   if arg_exception_id is null OR
     arg_exception_id <1000 then
     return to_date(null);
   end if;

   select decode(muec.exception_column, 'DATE1',date1,'DATE2',date2,'DATE3',date3,
	'DATE4',date4,'DATE5',date5,'DATE6',date6,'DATE7',date7)
   into l_temp
   from msc_user_exception_components muec,
        msc_x_exception_details mxed
   where muec.exception_id = mxed.exception_type
   and muec.exception_id = arg_exception_id
   and mxed.exception_detail_id = arg_exception_id
   and muec.component_type = 1
   and muec.ak_attribute_code = 'MSCX_COMP_REQUEST_DATE';
   return l_temp;
exception
   when no_data_found then
     return to_date(null);
END MSCX_COMP_REQUEST_DATE;

FUNCTION cp_exception_type_text (arg_exception_type IN NUMBER) return varchar2 is
  l_text varchar2(300);
begin
  if arg_exception_type is null then
	return null;
  end if;

  if arg_exception_type < 999 then
    select meaning
    into l_text
    from mfg_lookups
    where lookup_type = 'MSC_X_EXCEPTION_TYPE'
      and lookup_code = arg_exception_type;
  else
    select EXCEPTION_TYPE exception_type_text
    into l_text
    from MSC_EXCEPTION_LOOKUP_V
    where  to_number(EXCEPTION_TYPE_ID) = arg_exception_type;
  end if;

  return l_text;
exception
  when no_data_found then
     return null;
end cp_exception_type_text;

FUNCTION resource_code_all(arg_resource_id IN NUMBER,
                   arg_dept_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER,
		   arg_resource_type in number) return varchar2 IS
  v_resource_code varchar2(30);
BEGIN
 if  arg_resource_id =-1 or
     arg_resource_id is null or
     arg_dept_id is null or
     arg_org_id is null or
     arg_plan_id is null or
     arg_instance_id is null then
     return null;
 elsif arg_resource_type = 100 then
   select resource_code
    into   v_resource_code
    from   msc_planned_resources_v
    where department_id = arg_dept_id
    and   resource_id = arg_resource_id
    and   plan_id = arg_plan_id
    and   organization_id = arg_org_id
    and   sr_instance_id = arg_instance_id
    and  resource_type = resource_type;
  else
    v_resource_code := resource_code(arg_resource_id, arg_dept_id, arg_org_id, arg_plan_id, arg_instance_id);
  end if;
  return v_resource_code;
exception
  when no_data_found then
     return null;
END resource_code_all;

FUNCTION resource_desc_all(arg_resource_id IN NUMBER,
                   arg_dept_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER,
		   arg_resource_type in number) return varchar2 IS
  v_resource_desc varchar2(250);
BEGIN
 if  arg_resource_id =-1 or
     arg_resource_id is null or
     arg_dept_id is null or
     arg_org_id is null or
     arg_plan_id is null or
     arg_instance_id is null then
     return null;
 else
   select distinct resource_desc
    into   v_resource_desc
    from   msc_planned_resources_v
    where department_id = arg_dept_id
    and   resource_id = arg_resource_id
    and   plan_id = arg_plan_id
    and   organization_id = arg_org_id
    and   sr_instance_id = arg_instance_id
    and  resource_type = resource_type;
  end if;
  return v_resource_desc;
exception
  when no_data_found then
     return null;
END resource_desc_all;

--Get the source_vendor_name in PWB   ( added by Shailendra)
FUNCTION source_supplier(arg_sr_instance_id IN NUMBER,arg_plan_id IN NUMBER,arg_supplier_id IN NUMBER,arg_source_supplier_id IN NUMBER,arg_source_org_id IN NUMBER,arg_order_type IN NUMBER) return varchar2 IS
l_supp_id NUMBER;
cursor c1(l_source_org_id IN NUMBER,l_sr_instance_id IN NUMBER) IS
select tp.modeled_supplier_id
      from   msc_trading_partners tp
      where  tp.partner_type =3 and
             tp.sr_tp_id = l_source_org_id and
             tp.sr_instance_id = l_sr_instance_id;
BEGIN
   if(arg_sr_instance_id is null OR arg_plan_id is null ) then
       return null;
   end if;

   if(arg_plan_id = -1 OR  (arg_order_type in (1,2,8) AND arg_source_org_id IS NULL)) then
       return supplier(arg_supplier_id);
   end if;

   if(arg_source_org_id IS NOT NULL) then
      open c1(arg_source_org_id,arg_sr_instance_id);
      fetch c1 into l_supp_id;
      close c1;

   else
      return supplier(arg_source_supplier_id);
   end if;

   return supplier(l_supp_id);
EXCEPTION
    WHEN OTHERS THEN
       return null;
END source_supplier;


--Get the source_vendor_site in PWB    ( added by Shailendra)
FUNCTION source_supplier_site(arg_sr_instance_id IN NUMBER,arg_plan_id IN NUMBER,arg_supplier_site_id IN NUMBER,arg_source_supplier_site_id IN NUMBER,arg_source_org_id IN NUMBER,arg_order_type IN NUMBER) return varchar2 IS
l_supp_site_id NUMBER;
cursor c1(l_source_org_id IN NUMBER,l_sr_instance_id IN NUMBER) IS
select tp.modeled_supplier_site_id
      from   msc_trading_partners tp
      where  tp.partner_type =3 and
             tp.sr_tp_id = l_source_org_id and
             tp.sr_instance_id = l_sr_instance_id;
BEGIN
   if(arg_sr_instance_id is null OR arg_plan_id is null ) then
       return null;
   end if;

   if(arg_plan_id = -1 OR  (arg_order_type in (1,2,8) AND arg_source_org_id IS NULL)) then
       return supplier_site(arg_supplier_site_id);
   end if;

   if(arg_source_org_id IS NOT NULL) then
      open c1(arg_source_org_id,arg_sr_instance_id);
      fetch c1 into l_supp_site_id;
      close c1;

   else
      return supplier_site(arg_source_supplier_site_id);
   end if;

   return supplier_site(l_supp_site_id);

EXCEPTION
    WHEN OTHERS THEN
       return null;
END source_supplier_site;


FUNCTION category_name(arg_category_id IN number,
                       arg_category_set_id IN NUMBER,
                       arg_org_id IN NUMBER default null,
                       arg_instance_id IN NUMBER default null) return varchar2 IS

  category_name msc_item_categories.category_name%type;

 CURSOR category_name_org IS
   SELECT category_name
     FROM msc_item_categories
    WHERE category_set_id = arg_category_set_id
      AND sr_category_id = arg_category_id
      AND sr_instance_id = arg_instance_id
      AND organization_id = arg_org_id
      AND description is NOT NULL
      AND rownum<2;

 CURSOR category_name_ins IS
   SELECT category_name
     FROM msc_item_categories
    WHERE category_set_id = decode(arg_category_set_id, -1, category_set_id, arg_category_set_id)
      AND sr_category_id= arg_category_id
      AND sr_instance_id = arg_instance_id
      AND description is NOT NULL
      AND rownum<2;

  CURSOR category_name_c IS
   SELECT category_name
     FROM msc_item_categories
    WHERE category_set_id = arg_category_set_id
      AND sr_category_id= arg_category_id
      AND description is NOT NULL
      AND rownum<2;

  CURSOR cur_category_name IS
   SELECT category_name
     FROM msc_item_categories
    WHERE sr_category_id= arg_category_id
      AND description is NOT NULL
      AND rownum<2;

   BEGIN

  if ( arg_category_id is null ) or
     ( arg_category_set_id is null ) then
     return null;
  end if;

  if (arg_category_set_id = -1 and arg_org_id = -1
     and arg_category_id <> -1 and arg_instance_id <> -1 ) then
       OPEN category_name_ins;
       FETCH category_name_ins INTO category_name;
       CLOSE category_name_ins;
       return category_name;
  elsif arg_category_set_id = -1 then
       OPEN cur_category_name;
       FETCH cur_category_name INTO category_name;
       CLOSE cur_category_name;
       return category_name;
  end if;

  IF arg_org_id is NOT NULL AND arg_instance_id is not NULL THEN

     OPEN category_name_org;
       FETCH category_name_org INTO category_name;
     CLOSE category_name_org;
     return category_name;

   ELSIF arg_org_id is NULL AND arg_instance_id is not NULL THEN

     OPEN category_name_ins;
       FETCH category_name_ins INTO category_name;
     CLOSE category_name_ins;
     return category_name;

 ELSIF arg_org_id is NULL AND arg_instance_id is NULL THEN

     OPEN category_name_c;
       FETCH category_name_c INTO category_name;
     CLOSE category_name_c;
     return category_name;

  ELSE
    return NULL;
   END IF;

  exception when no_data_found then
     return null;

END category_name;


function budget_name(arg_budget_id number)  return varchar2 is
budget_name varchar2(30);

cursor budget_name_c is
select name
from msc_inventory_budgets
where budget_id=arg_budget_id;


begin
  if arg_budget_id is null then
    return null;
  end if;
  open budget_name_c;
  fetch budget_name_c into budget_name;
  close budget_name_c;

  return budget_name;
exception when no_data_found then
    return null;

end budget_name;


function drp_alloc_name(arg_rule_id number)  return varchar2 is

rule_name varchar2(10);

cursor rule_name_c is
select name
from msc_drp_alloc_rules
where rule_id=arg_rule_id;


begin
  if arg_rule_id is null then
    return null;
  end if;
  open rule_name_c;
  fetch rule_name_c into rule_name;
  close rule_name_c;

  return rule_name;
exception when no_data_found then
    return null;

end drp_alloc_name;



function drp_pri_rule_name(arg_rule_id number)  return varchar2 is

rule_name varchar2(30);

cursor rule_name_c is
select meaning
from msc_drp_dmd_pri_rules
where rule_set_id=arg_rule_id;


begin
  if arg_rule_id is null then
    return null;
  end if;

  if arg_rule_id = -1 then
    rule_name := lookup_meaning('USER_DEFINED_DMD_PRIORITY',-1);
  else
    open rule_name_c;
    fetch rule_name_c into rule_name;
    close rule_name_c;
  end if;
  return rule_name;
exception when no_data_found then
    return null;

end drp_pri_rule_name;


function get_category_id (p_category_name in varchar2,
                          p_org_id  in number,
                          p_inst_id in number) return number is
cursor category_id_c is
select sr_category_id
from msc_item_categories
where category_name = p_category_name
and category_set_id = fnd_profile.value('MSR_BUDGET_CATEGORY_SET')
and rownum =1 ;


cursor category_id_c1 is
select sr_category_id
from msc_item_categories
where category_name = p_category_name
and category_set_id = fnd_profile.value('MSR_BUDGET_CATEGORY_SET')
and organization_id=p_org_id
and sr_instance_id=p_inst_id
and rownum =1 ;

cursor category_id_inst is
select sr_category_id
from msc_item_categories
where category_name = p_category_name
and category_set_id = fnd_profile.value('MSR_BUDGET_CATEGORY_SET')
and sr_instance_id=p_inst_id
and rownum =1 ;

l_category_id number;

begin
if ( nvl(p_org_id,-1) = -1 and nvl(p_inst_id,-1) <> -1 ) then
  open category_id_inst;
  fetch category_id_inst into l_category_id;
  close category_id_inst;
elsif (p_org_id is not null and p_inst_id is not null
    and p_org_id <> -1 and p_inst_id <> -1) then
  open category_id_c1;
  fetch category_id_c1 into l_category_id;
  close category_id_c1;
else
  open category_id_c;
  fetch category_id_c into l_category_id;
  close category_id_c;
end if;

if l_category_id is null then
   l_category_id  := -1;
end if;

return l_category_id;

end;


-- This function is to be used for calling from msc_orders_v in the
-- union that gets records from msc_job_requirement_ops
function get_order_number(p_inst_id in number,
                          p_plan_id in number,
                          p_transaction_id in number,
                          p_coprod in number default 0) return varchar2 is
cursor order_num_c is
select wip_entity_name , order_number
from msc_supplies
where plan_id=p_plan_id
and   sr_instance_id = p_inst_id
and   transaction_id= p_transaction_id;

l_order_num varchar2(240);
l_order_num1 varchar2(240);

begin

if (p_inst_id is null or p_plan_id is null or p_transaction_id is null) then
  return null;
else
  open order_num_c;
  fetch order_num_c into l_order_num,l_order_num1;
  close order_num_c;

  if p_coprod = 1 then
    return l_order_num1;
  else
    return  l_order_num;
  end if;

end if;
end get_order_number;

function get_trans_mode(p_ship_method_code in varchar2,
                        p_instance_id in number ) return varchar2 is
cursor trans_mode_c is
select mode_of_transport
from msc_carrier_services
where ship_method_code = p_ship_method_code
and   sr_instance_id=p_instance_id;
l_trans_mode varchar2(30);
begin
  if p_ship_method_code is null then
     return null;
  end if;

  open trans_mode_c;
  fetch trans_mode_c into l_trans_mode;
  close trans_mode_c;

  return l_trans_mode;

end get_trans_mode;



FUNCTION lookup_meaning1(arg_lookup_type IN varchar2,
                        arg_lookup_code IN varchar2,
                        arg_application_id in number,
                        arg_security_group_id in number) return varchar2 IS
meaning_text varchar2(80);
BEGIN
   if arg_lookup_code is null then
      return null;
   end if;

   select meaning
   into meaning_text
   from fnd_lookup_values
   where lookup_type = arg_lookup_type
     and lookup_code = arg_lookup_code
     and view_application_id = arg_application_id
     and language = userenv('LANG')
     and security_group_id = arg_security_group_id;

     return meaning_text;

EXCEPTION when no_data_found THEN
    return null;
END lookup_meaning1;

function res_req_capacity(p_plan_id in number,
                          p_transaction_id in number) return number is
    l_req_capacity number;
begin
  if (p_plan_id is null or p_transaction_id is null) then
    return to_number(null);
  end if;

  select (mif.unit_weight * mr.new_order_quantity)
    into l_req_capacity
  from msc_supplies mr,
     msc_system_items mif
  where mr.plan_id = mif.plan_id
    and mr.sr_instance_id = mif.sr_instance_id
    and mr.organization_id = mif.organization_id
    and mr.inventory_item_id = mif.inventory_item_id
    and mr.plan_id = p_plan_id
    and mr.transaction_id = p_transaction_id
     AND  (mif.new_plan_id = -1 OR mif.new_plan_id IS NULL )
    AND  (mif.SIMULATION_SET_ID IS NULL);

  return l_req_capacity;
EXCEPTION when others THEN
  return to_number(null);
end res_req_capacity;

FUNCTION set_name(p_inst_id in number,
                  p_so_line_id in number,
                  p_set_type in number) return varchar2 IS
  CURSOR set_c is
    select decode(p_set_type, 1, ship_set_name, arrival_set_name)
      from msc_sales_orders
     where sr_instance_id = p_inst_id
       and demand_source_line = p_so_line_id;
  v_set_name varchar2(30);
BEGIN
  if p_inst_id is null or p_so_line_id is null or p_set_type is null then
     return null;
  end if;
  open set_c;
  fetch set_c into v_set_name;
  close set_c;
  return v_set_name;
EXCEPTION when others THEN
  return null;
END set_name;

function get_bom_item_type(p_item_id in number) return number is
 cursor bom_item_c is
 select bom_item_type
 from msc_system_items
 where inventory_item_id = p_item_id
 and rownum < 2;
 l_bom_item_type number;
begin

 open bom_item_c;
 fetch bom_item_c into l_bom_item_type;
 close bom_item_c;

 return l_bom_item_type;
exception when others then
 return null;
end get_bom_item_type;

FUNCTION get_other_customers(p_plan_id number,
                               p_schedule_desig_id number) return varchar2 is
  l_count number;
begin
  if (p_plan_id is null or p_schedule_desig_id is null) then
    return null;
  end if;

  select count(*)
  into l_count
  from msd_dp_scn_output_levels_v dp,
     msc_plan_schedules ps
  where ps.input_schedule_id = dp.scenario_id
    and ps.designator_type = 7
    and dp.level_id in (11, 15, 41)
    and ps.plan_id = p_plan_id
    and ps.input_schedule_id = p_schedule_desig_id;

  if l_count = 0 then
    return null;
  else
   return 'OTHER';
  end if;

exception when others then
 return null;
end get_other_customers;

FUNCTION get_days_on_arrival(p_plan_id number,
                              p_exception_id number,
                              p_exception_type number,
                              p_demand_id number,
                              p_schedule_by number,
			      p_late_early_flag number) return number is
-- 1 schedule ship date
-- 2 schedule arrival date
-- 3 request ship date
-- 4 request arival date
-- 5 promise ship date
-- 6 promise arrival date

-- 25 Early replenishment for sales order
-- 27 Early replenishment for forecast

-- 24 Late replenishment for sales order
-- 26 Late replenishment for forecast
-- 69 Late Replenishment for MPP/MPS Demands

   cursor c_dem (l_plan number, l_dem number) is
   select schedule_arrival_date, planned_arrival_date, promise_date, request_date
    ,using_assembly_demand_date, planned_ship_date, origination_type
   from msc_demands
   where plan_id = l_plan
   and demand_id = l_dem;

   l_sched_arrival date;
   l_plnd_arrival date;
   l_promise  date;
   l_request date;

   l_new_due_date date;
   l_plnd_ship_date date;
   l_orig_type number;

   retval number;
BEGIN
  if (p_plan_id is null or p_exception_id is null
	or p_exception_type is null or p_demand_id is null
	or p_schedule_by is null  or p_late_early_flag is null ) then
    return to_number(null);
  end if;

  if (p_late_early_flag = 1) then  -- late
    if (p_exception_type not in (24, 26, 69) ) then
      return to_number(null);
    end if;
  elsif (p_late_early_flag = -1) then  --early
    if (p_exception_type not in (25, 27) ) then
      return to_number(null);
    end if;
  else
    return to_number(null);
  end if;

  open c_dem(p_plan_id, p_demand_id);
  fetch c_dem into l_sched_arrival, l_plnd_arrival, l_promise, l_request,
   l_new_due_date, l_plnd_ship_date, l_orig_type;
  close c_dem;

  if (l_orig_type = 29 and p_exception_id = -1) then
    return  round(l_plnd_ship_date - l_new_due_date, 2) ;
  end if;

  if (p_schedule_by in (1,2) ) then  --by schedule dates
    retval := l_plnd_arrival - l_sched_arrival;
  elsif (p_schedule_by in (3,4) ) then  --by request dates
    retval := l_plnd_arrival - l_request;
  elsif (p_schedule_by in (5,6) ) then  --by promise dates
    retval := l_plnd_arrival - l_promise;
  else
    return to_number(null);
  end if;

  if (p_late_early_flag = 1) then  -- late
    if retval = 0 then
      return 0;
    elsif round(p_late_early_flag * retval, 2) = 0 then
      return 0.01;
    else
      return round(p_late_early_flag * retval, 2);
    end if;
  elsif (p_late_early_flag = -1) then  --early
    if retval = 0 then
      return 0;
    elsif round(p_late_early_flag * retval, 2) = 0 then
      return 0.01;
    else
     return round(p_late_early_flag * retval, 2);
    end if;
  end if;

END  get_days_on_arrival;

function get_cat_id (p_inventory_item_id number,
                     p_organization_id number,
                     p_instance_id number) return number  is
l_cat_set_id number;
cursor cat_set_id_c is
select sr_category_id
from msc_item_categories
where inventory_item_id=p_inventory_item_id
and   sr_instance_id=p_instance_id
and   organization_id=decode(p_organization_id, -1,organization_id, p_organization_id)
and   rownum < 2;

begin

open cat_set_id_c;
fetch cat_set_id_c into l_cat_set_id;
close cat_set_id_c;

return l_cat_set_id;

end get_cat_id;

function get_cat_set_id (p_inventory_item_id number,
                     p_organization_id number,
                     p_instance_id number) return number is

l_cat_id number;
cursor cat_id_c is
select category_set_id
from msc_item_categories
where inventory_item_id=p_inventory_item_id
and   sr_instance_id=p_instance_id
and   organization_id=decode(p_organization_id, -1,  organization_id, p_organization_id)
and   rownum < 2;

begin

open cat_id_c;
fetch cat_id_c into l_cat_id;
close cat_id_c;

return l_cat_id;
end get_cat_set_id;

FUNCTION resource_group_name(arg_resource_id IN NUMBER,
                   arg_dept_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER) return varchar2 is
  l_group varchar2(30);
begin
  if arg_resource_id =-1 or
     arg_resource_id is null or
     arg_dept_id is null or
     arg_org_id is null or
     arg_plan_id is null or
     arg_instance_id is null then
     return null;
  end if;

  select resource_group_name
  into l_group
  from   msc_department_resources
  where department_id = arg_dept_id
  and   resource_id = arg_resource_id
  and   plan_id = arg_plan_id
  and   organization_id = arg_org_id
  and   sr_instance_id = arg_instance_id;

  return l_group;
end resource_group_name;

FUNCTION new_schedule_date (arg_plan_id IN NUMBER,
                  arg_trx_id IN NUMBER)   return DATE is
  l_date date;
begin
	IF arg_trx_id is null or arg_plan_id is null THEN
	  return to_date(null);
	END IF;

	select	new_schedule_date
        into    l_date
	from	msc_supplies
	where 	transaction_id = arg_trx_id
        and     plan_id = arg_plan_id;

        return l_date;

end new_schedule_date;

FUNCTION Get_Zone_Name(p_zone_id IN NUMBER,
		       p_sr_instance_id IN NUMBER )
		       return varchar2 is

l_zone_name varchar2(255) ;

cursor cur_zone(l_zone_id number , l_sr_instance_id number) is
select zone
from msc_regions
where  region_id   = l_zone_id
and region_type    = 10
and sr_instance_id = l_sr_instance_id ;

begin
 If p_zone_id is null then
	  l_zone_name := null ;
 else
	 open cur_zone(p_zone_id , p_sr_instance_id) ;
	 fetch cur_zone into l_zone_name ;
	 close cur_zone ;
 end if;
 return l_zone_name ;
End Get_Zone_Name;


function alternate_bom_eff(p_process_seq_id number,
                               p_plan_id number,
                               p_sr_instance_id number) return varchar2 is
  CURSOR ALT_bom_C IS
  SELECT bom.alternate_bom_designator
  FROM msc_boms bom,
       msc_process_effectivity eff
  WHERE bom.plan_id = eff.plan_id
    AND bom.sr_instance_id = eff.sr_instance_id
    AND bom.bill_sequence_id = eff.bill_sequence_id
    AND eff.plan_id=p_plan_id
    and eff.sr_instance_id=p_sr_instance_id
    and eff.process_sequence_id=p_process_seq_id;

  l_alt_bom     VARCHAR2(40); --5338566 bugfix, length changed to 40

BEGIN

  if p_process_seq_id is null then
     return null;
  end if;

  OPEN ALT_bom_C;
  FETCH ALT_bom_C INTO l_alt_bom;
  CLOSE ALT_bom_C;

  return(l_alt_bom);

end alternate_bom_eff;

function alternate_rtg_eff(p_process_seq_id number,
                               p_plan_id number,
                               p_sr_instance_id number) return varchar2 is
  CURSOR ALT_RTG_C IS
  SELECT rt.alternate_routing_designator
  FROM msc_routings rt,
       msc_process_effectivity eff
  WHERE rt.plan_id = eff.plan_id
    AND rt.sr_instance_id = eff.sr_instance_id
    AND rt.routing_sequence_id = eff.routing_sequence_id
    AND eff.plan_id=p_plan_id
    and eff.sr_instance_id=p_sr_instance_id
    and eff.process_sequence_id=p_process_seq_id;

  l_alt_rtg     VARCHAR2(40); --5338566 bugfix, length changed to 40

BEGIN

  if p_process_seq_id is null then
     return null;
  end if;

  OPEN ALT_RTG_C;
  FETCH ALT_RTG_C INTO l_alt_rtg;
  CLOSE ALT_RTG_C;

  return(l_alt_rtg);

end alternate_rtg_eff;

function supply_order_number(p_order_type number,
				p_order_number varchar2,
				p_plan_id number ,
				p_sr_instance_id number,
				p_transaction_id number ,
				p_disposition_id number ) return varchar2
is

cursor cur_sup_ord(l_order_type number,
				l_order_number varchar2,
				l_plan_id number ,
				l_sr_instance_id number,
				l_transaction_id number ,
				l_disposition_id number ) is
	select
			DECODE(l_order_type, 5,
					decode( l_order_number, NULL,
										  to_char(l_transaction_id),
										 l_order_number||' '||to_char(l_transaction_id)) ,
  14, decode(l_plan_id,
        -1, l_order_number,
        decode(substr(msc_get_name.get_order_number( l_sr_instance_id,
	     l_plan_id, l_disposition_id, 1),1,240),
           null, to_char(l_disposition_id),
           substr(msc_get_name.get_order_number(l_sr_instance_id, l_plan_id,
	     l_disposition_id, 1),1,240)||' ' || to_char(l_disposition_id))),
					   17, decode(substr(msc_get_name.get_order_number(
								l_sr_instance_id,
								l_plan_id,
								l_disposition_id,
							       1),1,240), null, to_char(l_disposition_id),
								substr(msc_get_name.get_order_number(
								l_sr_instance_id,
								l_plan_id,
								l_disposition_id,
							       1),1,240)||' ' || to_char(l_disposition_id)),
				15,to_char(l_DISPOSITION_ID),
					 16,to_char(l_DISPOSITION_ID),
					 28,to_char(l_DISPOSITION_ID),
				       l_order_number)
	from dual;

l_return varchar2(2000);
begin
  if p_order_type in (51,52,76,77,78,79) then
     return to_char(p_transaction_id);
  end if;
	open cur_sup_ord(p_order_type ,	p_order_number , p_plan_id ,p_sr_instance_id ,	p_transaction_id ,p_disposition_id );
	fetch cur_sup_ord into l_return ;
	if cur_sup_ord%notfound then
		l_return := null;
	end if;
	close cur_sup_ord;

return l_return;

end supply_order_number;

FUNCTION operation_code(p_plan_id IN NUMBER,
                  p_sr_instance_id IN NUMBER,
                  p_standard_operation_id IN NUMBER) return varchar2 IS

  v_operation_code varchar2(50);

  CURSOR Operation_Code_C IS
    select operation_code
    from msc_std_op_resources
    where plan_id = p_plan_id
    and sr_instance_id = p_sr_instance_id
    and standard_operation_id = p_standard_operation_id;

BEGIN
 IF p_plan_id is null or
    p_sr_instance_id is null or
    p_standard_operation_id is null THEN
   return null;
 END IF;
     OPEN Operation_Code_C;
     FETCH Operation_Code_C INTO v_operation_code;
     CLOSE Operation_Code_C;
     return v_operation_code;

EXCEPTION when others THEN
    return null;
END operation_code;


FUNCTION setup_code(p_plan_id IN NUMBER,
                  p_sr_instance_id IN NUMBER,
                  p_resource_id IN NUMBER,
                  p_organization_id IN NUMBER,
                  p_setup_id IN NUMBER
                  ) return varchar2 IS
  v_setup_code varchar2(50);


  CURSOR Setup_Code_C IS
    select setup_code
    from msc_resource_setups
    where
        plan_id=p_plan_id
    AND sr_instance_id=p_sr_instance_id
    AND resource_id = p_resource_id
    AND organization_id = p_organization_id
    AND setup_id = p_setup_id;

BEGIN
 IF p_plan_id is null or
    p_sr_instance_id is null or
    p_organization_id is null or
    p_setup_id is null THEN
   return null;
 END IF;
     OPEN Setup_Code_C;
     FETCH Setup_Code_C INTO v_setup_code;
     CLOSE Setup_Code_C;
     return v_setup_code;

EXCEPTION when others THEN
    return null;
END setup_code;


function get_mfd_order_number(p_order_type     in number,
                              p_order_number   in varchar2,
                              p_transaction_id in number,
                              p_sr_instance_id in number,
                              p_plan_id        in number,
                              p_disposition_id in number)
      return varchar2 is

    l_order_num varchar2(240);
    l_order_num_temp varchar2(240);

begin

    if (  p_sr_instance_id is null
       or p_plan_id is null
       or p_transaction_id is null) then
      l_order_num:=  null;
    else
        IF p_order_type = 5 THEN
            IF p_order_number IS NULL THEN
                l_order_num := to_char(p_transaction_id);
            else
                l_order_num := p_order_number||' '||to_char(p_transaction_id);
            end if;
        Elsif p_order_type in (14, 17) THEN
            l_order_num_temp:= substr(msc_get_name.get_order_number
                                      (p_sr_instance_id,
                                       p_plan_id,
                                       p_disposition_id, 1), 1, 240);
            if l_order_num_temp is null then
                    l_order_num:= to_char(p_disposition_id);
            else
               l_order_num:= l_order_num_temp||' '||to_char(p_disposition_id);
            end if;
        Elsif p_order_type in (51, 52) THEN
            l_order_num := to_char(p_transaction_id);
        Elsif p_order_type in (15, 16, 28) THEN
            l_order_num:= to_char(p_disposition_id);
        else
            l_order_num:= p_order_number;
        end if;
    end if;

    return l_order_num;

exception
    when others then
        return null;
end get_mfd_order_number;

/****************************************************************************************/

-- -----------------------------------------------------
-- This function returns
-- Resource_transaction_id,resource_id Or Resource_code :
-- if p_column_name is 'TI'
--                   > Resource_transaction_id
-- elsif p_column_name is 'RI'
--                   > resource_id
-- elsif p_column_name is 'RC'
--                   > Resource_code
-- elsif p_column_name is 'DI'
--                   > Department_id
-- elsif p_column_name is 'DC'
--                   > Department_code
-- ------------------------------------------------------

function get_res_and_dept_details(p_plan_id             in number,
                                  p_sr_instance_id      in number,
                                  P_res_transaction_id  in number,
                                  P_column_name      in varchar2)
         return varchar2 is

    Cursor Cur_Resource_Details Is
    Select Mrr.Transaction_Id,
           Mrr.Resource_Id,
           Mdr.Resource_Code,
           Mrr.Department_Id,
           Mdr.Department_Code
    From Msc_Department_Resources Mdr,
         Msc_Resource_Requirements Mrr
    Where Mrr.Transaction_Id = P_Res_Transaction_Id
    And Mrr.Plan_Id         = P_Plan_Id
    And Mrr.Sr_Instance_Id  = P_Sr_Instance_Id
    And Mdr.Plan_Id         = Mrr.Plan_Id
    And Mdr.Sr_Instance_Id  = Mrr.Sr_Instance_Id
    And Mdr.Organization_Id = Mrr.Organization_Id
    And Mdr.Department_Id   = Mrr.Department_Id
    And Mdr.Resource_Id     = Mrr.Resource_Id;

    rec_Resource_Details Cur_Resource_Details%rowtype;

begin

    if (P_res_transaction_id is null
        or p_column_name is null) then
        return null;
    else
      open cur_resource_details;
      fetch cur_resource_details
      into rec_Resource_Details;
      if cur_resource_details%notfound then
        close cur_resource_details;
        return null;
      end if;
      close cur_resource_details;
    end if;
    if(p_column_name = 'TI') then
     return rec_Resource_Details.Transaction_Id;
    elsif(p_column_name = 'RI') then
     return rec_Resource_Details.Resource_id;
    elsif(p_column_name = 'RC') then
     return rec_Resource_Details.resource_code;
    elsif(p_column_name = 'DI') then
     return rec_Resource_Details.department_id;
    elsif(p_column_name = 'DC') then
     return rec_Resource_Details.department_code;
    else
        return null;
    end if;
exception
    when others then
        if cur_resource_details%isopen then
            close cur_resource_details;
        end if;
        return null;
end get_res_and_dept_details;

-- -----------------------------------------------------
-- This function returns
-- Minimum_transfer_qty,Minimum_time_offset,Maximum_time_offset:
-- if p_column_name is 'DTYPE'
--                   > Dependency_Type
-- elsif p_column_name is 'MTQTY'
--                   > Minimum_transfer_qty
-- elsif p_column_name is 'MINTT'
--                   > Minimum_time_offset
-- elsif p_column_name is 'MAXTT'
--                   > Maximum_time_offset
-- ------------------------------------------------------

function get_mtq_details(p_plan_id  	     in number,
                          p_sr_instance_id   in number,
                          p_routing_seq_id   in number,
                          p_operation_seq_id in number,
                          p_item_id          in number,
                          p_cfm_routing_flag in number,
                          p_column_name      in varchar2)
     return number is

     cursor cur_mtq_details_mon is
     select dependency_type,
            minimum_transfer_qty,
            minimum_time_offset,
            maximum_time_offset
     from msc_operation_networks
     where plan_id              = p_plan_id        and
           sr_instance_id       = p_sr_instance_id and
           routing_sequence_id  = p_routing_seq_id and
	   from_op_seq_id       = p_operation_seq_id and
	   from_item_id         = p_item_id;

     cursor cur_mtq_details_mro is
     select minimum_transfer_quantity
     from msc_routing_operations
     where plan_id              = p_plan_id        and
           sr_instance_id       = p_sr_instance_id and
           routing_sequence_id  = p_routing_seq_id and
	   operation_sequence_id  = p_operation_seq_id;

   l_dependency_type          number(10);
   l_minimum_transfer_qty     number(10);
   l_minimum_time_offset      number(10);
   l_maximum_time_offset      number(10);

   rec_mtq_details_mon cur_mtq_details_mon%rowtype;
   rec_mtq_details_mro cur_mtq_details_mro%rowtype;

 begin
 if p_cfm_routing_flag is not null and
     p_cfm_routing_flag = 3 then

     if (p_sr_instance_id is null
        or p_plan_id is null
        or P_Routing_Seq_Id is null
        or P_Operation_Seq_Id is null
        or p_item_id is null
        or p_column_name is null) then
        return null;
    else
      open cur_mtq_details_mon ;
      fetch cur_mtq_details_mon into rec_mtq_details_mon;
      if cur_mtq_details_mon%notfound then
        close cur_mtq_details_mon;
        --If the details are not available in msc_operation_networks then
        --get it from msc_routing_operations.
            open cur_mtq_details_mro;
	    fetch cur_mtq_details_mro into rec_mtq_details_mro;
	    if cur_mtq_details_mro%notfound then
	        close cur_mtq_details_mro;
	        return null;
	    end if;
	    close cur_mtq_details_mro;
	    if(p_column_name = 'MTQTY') then
	       return rec_mtq_details_mro.minimum_transfer_quantity;
	    else
	       return null;
	    end if;
      end if;
      close cur_mtq_details_mon;
    end if;

    if(p_column_name = 'DTYPE') then
       return rec_mtq_details_mon.dependency_type;
    elsif(p_column_name = 'MTQTY') then
       return rec_mtq_details_mon.minimum_transfer_qty;
    elsif(p_column_name = 'MINTT') then
       return rec_mtq_details_mon.minimum_time_offset;
    elsif(p_column_name = 'MAXTT') then
       return rec_mtq_details_mon.maximum_time_offset;
    else
       return null;
    end if;
 else
    --Always get it from msc_routing_operations table.
    open cur_mtq_details_mro;
    fetch cur_mtq_details_mro into rec_mtq_details_mro;
    if cur_mtq_details_mro%notfound then
        close cur_mtq_details_mro;
        return null;
    end if;
    close cur_mtq_details_mro;
    if(p_column_name = 'MTQTY') then
       return rec_mtq_details_mro.minimum_transfer_quantity;
    else
       return null;
    end if;
 end if;
exception
    when others then
        if cur_mtq_details_mon%isopen then
            close cur_mtq_details_mon;
        end if;
        if cur_mtq_details_mro%isopen then
            close cur_mtq_details_mro;
        end if;
        return null;
end get_mtq_details;

function eam_parent_work_order(	p_plan_id number ,
				p_sr_instance_id number,
				p_transaction_id number
				) return number
is
l_eam_parent_order_number number;

cursor cur_parent_order is
	select  to_transaction_id
	from msc_job_operation_networks
	where plan_id = p_plan_id
	and sr_instance_id = p_sr_instance_id
	and transaction_id = p_transaction_id
	and dependency_type = 3	;
Begin
open cur_parent_order ;
fetch cur_parent_order into l_eam_parent_order_number;
if cur_parent_order%notfound then
	null;
end if;
close cur_parent_order;

return l_eam_parent_order_number;

End eam_parent_work_order;

FUNCTION standard_operation_code(p_plan_id IN NUMBER,
                  p_sr_instance_id IN NUMBER,
                  p_resource_id IN NUMBER,
                  p_org_id IN NUMBER,
                  p_from_setup_id IN NUMBER,
                  p_to_setup_id IN NUMBER
                  ) return varchar2 IS
  v_operation_code varchar2(50);

  CURSOR Operation_Code_C IS
    select res.operation_code
    from msc_std_op_resources res, msc_setup_transitions mst
    where res.plan_id = p_plan_id
    and res.sr_instance_id = p_sr_instance_id
    and mst.resource_id=p_resource_id
    and mst.organization_id=p_org_id
    and mst.from_setup_id=p_from_setup_id
    and mst.to_setup_id=p_to_setup_id
    and res.plan_id=mst.plan_id
    and res.sr_instance_id=mst.sr_instance_id
    and res.organization_id=mst.organization_id
    and res.standard_operation_id =mst.standard_operation_id;

BEGIN
 IF p_plan_id is null or
    p_sr_instance_id is null or
    p_resource_id is null or
    p_org_id is null or
    p_from_setup_id is null or
    p_to_setup_id is null or
    p_plan_id < 0 THEN
   return null;
 END IF;
     OPEN Operation_Code_C;
     FETCH Operation_Code_C INTO v_operation_code;
     CLOSE Operation_Code_C;
     return v_operation_code;

EXCEPTION when others THEN
    return null;
END standard_operation_code;

function get_op_seq_id(p_plan_id  	    in number,
                       p_sr_instance_id   in number,
                       p_routing_seq_id   in number,
                       p_op_seq_num in number)
     return number is

     cursor cur_routing_op_seq_num is
     select operation_sequence_id
     from msc_routing_operations
     where plan_id = p_plan_id
          and sr_instance_id = p_sr_instance_id
          and routing_sequence_id = p_routing_seq_id
          and operation_seq_num = p_op_seq_num;

   l_op_seq_id          number(10);

  begin
      open cur_routing_op_seq_num ;
      fetch cur_routing_op_seq_num
      into l_op_seq_id;
      if cur_routing_op_seq_num%notfound then
        close cur_routing_op_seq_num ;
        return null;
      end if;
      close cur_routing_op_seq_num;
      return l_op_seq_id;
exception
    when others then
        if cur_routing_op_seq_num%isopen then
            close cur_routing_op_seq_num;
        end if;
        return null;
end get_op_seq_id;

function get_mtq_coprod_details(p_plan_id  	     in number,
                          p_sr_instance_id   in number,
                          p_routing_seq_id   in number,
                          p_operation_seq_id in number,
                          p_item_id          in number,
                          p_column_name      in varchar2)
     return number is

     cursor cur_mtq_details is
     select dependency_type,
            minimum_transfer_qty,
            minimum_time_offset,
            maximum_time_offset
     from msc_operation_networks
     where plan_id              = p_plan_id        and
           sr_instance_id       = p_sr_instance_id and
           routing_sequence_id  = p_routing_seq_id and
	       from_op_seq_id       = p_operation_seq_id and
	       from_item_id         = p_item_id;

   l_dependency_type          number(10);
   l_minimum_transfer_qty     number(10);
   l_minimum_time_offset      number(10);
   l_maximum_time_offset      number(10);

   rec_mtq_details cur_mtq_details%rowtype;

  begin

     if (p_sr_instance_id is null
        or p_plan_id is null
        or P_Routing_Seq_Id is null
        or P_Operation_Seq_Id is null
        or p_item_id is null
        or p_column_name is null) then
        return null;
    else
      open cur_mtq_details ;
      fetch cur_mtq_details
      into rec_mtq_details;
      if cur_mtq_details%notfound then
        close cur_mtq_details ;
        return null;
      end if;
      close cur_mtq_details;
    end if;

    if(p_column_name = 'DTYPE') then
       return rec_mtq_details.dependency_type;
    elsif(p_column_name = 'MTQTY') then
       return rec_mtq_details.minimum_transfer_qty;
    elsif(p_column_name = 'MINTT') then
       return rec_mtq_details.minimum_time_offset;
    elsif(p_column_name = 'MAXTT') then
       return rec_mtq_details.maximum_time_offset;
    else
       return null;
    end if;
exception
    when others then
        if cur_mtq_details%isopen then
            close cur_mtq_details;
        end if;
        return null;
end get_mtq_coprod_details;

function get_mfd_details(p_plan_id number,
                         p_trans_id number,
                         p_inst_id number,
                         p_routing_seq_id number,
                         p_op_seq_id number,
                         p_item_id  number,
                         c_trans_id number,
                         c_inst_id number,
                         c_op_seq_id number,
                         p_column_name varchar2) return number is

  cursor c_intra_rtg is
  select distinct dependency_type,
            minimum_transfer_qty,
            minimum_time_offset,
            maximum_time_offset
  from  msc_operation_networks
  where plan_id                              = p_plan_id
    and sr_instance_id                       = p_inst_id
    and routing_sequence_id                  = p_routing_seq_id
    and transition_type                      = 1
    and nvl(from_op_seq_id, -23453)          = nvl(p_op_seq_id, -23453)
    and nvl(to_op_seq_id, -23453)            = nvl(c_op_seq_id, -23453);


  cursor c_inter_rtg is
  select dependency_type,
            minimum_transfer_qty,
            minimum_time_offset,
            maximum_time_offset
  from msc_job_operation_networks
  where plan_id                         = p_plan_id
    and sr_instance_id                  = p_inst_id
    and transaction_id                  = p_trans_id
    and to_transaction_id               = c_trans_id
    and transition_type                 = 1
    and from_item_id                    = p_item_id
    and nvl(from_op_seq_id, -23453)     = nvl(p_op_seq_id, -23453)
    and nvl(to_op_seq_id, -23453)       = nvl(c_op_seq_id, -23453);

   rec_intra_rtg_details c_intra_rtg%rowtype;
   rec_inter_rtg_details c_inter_rtg%rowtype;

begin
  if ( p_inst_id = c_inst_id and p_trans_id = c_trans_id ) then
    --intra-routing
    open c_intra_rtg;
    fetch c_intra_rtg into rec_intra_rtg_details;
    close c_intra_rtg;

    if(p_column_name = 'DTYPE') then
       return rec_intra_rtg_details.dependency_type;
    elsif(p_column_name = 'MTQTY') then
       return rec_intra_rtg_details.minimum_transfer_qty;
    elsif(p_column_name = 'MINTT') then
       return rec_intra_rtg_details.minimum_time_offset;
    elsif(p_column_name = 'MAXTT') then
       return rec_intra_rtg_details.maximum_time_offset;
    else
       return null;
    end if;

  else
    --inter-routing
    open c_inter_rtg;
    fetch c_inter_rtg  into rec_inter_rtg_details;
    close c_inter_rtg;

    if(p_column_name = 'DTYPE') then
       return rec_inter_rtg_details.dependency_type;
    elsif(p_column_name = 'MTQTY') then
       return rec_inter_rtg_details.minimum_transfer_qty;
    elsif(p_column_name = 'MINTT') then
       return rec_inter_rtg_details.minimum_time_offset;
    elsif(p_column_name = 'MAXTT') then
       return rec_inter_rtg_details.maximum_time_offset;
    else
       return null;
    end if;
  end if;
 exception
   when others then
     return null;
end get_mfd_details;

function get_supply_order_number(p_plan_id number,
                                 p_inst_id number,
                                 p_trans_id number)
         return varchar2
is
l_order_number varchar2(2000);
l_order_type number;
l_disposition_id number;
l_supply_order_number varchar2(2000);

cursor curr_supply(p_curr_plan_id number , p_curr_inst_id number , p_curr_trans_id number) is
select order_number , order_type , disposition_id
from msc_supplies
where plan_id        = p_curr_plan_id
and sr_instance_id   = p_curr_inst_id
and transaction_id   = p_curr_trans_id;
begin
open curr_supply(p_plan_id,p_inst_id ,p_trans_id) ;
fetch curr_supply into l_order_number ,l_order_type ,l_disposition_id;
close curr_supply;

l_supply_order_number := msc_get_name.supply_order_number(l_order_type,
								l_order_number,
								p_plan_id  ,
								p_inst_id,
								p_trans_id ,
								l_disposition_id);
return l_supply_order_number ;

end get_supply_order_number;

function get_supply_item(p_plan_id number,
                                 p_inst_id number,
                                 p_trans_id number)
         return varchar2
is
l_inventory_item_id number;
l_organization_id number;
l_supply_item varchar2(2000);

cursor curr_supply(p_curr_plan_id number , p_curr_inst_id number , p_curr_trans_id number) is
select inventory_item_id , organization_id
from msc_supplies
where plan_id        = p_curr_plan_id
and sr_instance_id   = p_curr_inst_id
and transaction_id   = p_curr_trans_id;
begin
open curr_supply(p_plan_id,p_inst_id ,p_trans_id) ;
fetch curr_supply into l_inventory_item_id ,l_organization_id;
close curr_supply;

l_supply_item :=    msc_get_name.item_name(l_inventory_item_id,
					   l_organization_id,
					   p_trans_id,
					   p_inst_id);
return l_supply_item ;

end get_supply_item;

function get_supply_org_code(p_plan_id number,
				 p_inst_id number,
				 p_trans_id number)
         return varchar2
is
l_supply_org_code varchar2(100);

cursor curr_supply(p_curr_plan_id number , p_curr_inst_id number , p_curr_trans_id number) is
select msc_get_name.org_code(organization_id , sr_instance_id )
from msc_supplies
where plan_id        = p_curr_plan_id
and sr_instance_id   = p_curr_inst_id
and transaction_id   = p_curr_trans_id;

begin

open curr_supply(p_plan_id,p_inst_id ,p_trans_id) ;
fetch curr_supply into l_supply_org_code;
close curr_supply;

return l_supply_org_code;
end get_supply_org_code;

function get_min_max_offset_time(p_plan_id number,
				 p_inst_id number,
				 p_from_trans_id number,
				 p_to_trans_id number,
				 p_from_op_seq_num number,
				 p_to_op_seq_num number ,
				 p_from_res_seq_num number,
				 p_to_res_seq_num number ,
				 p_min_max_flag varchar2)
         return number
is
l_minimum_offset_time number;
l_maximum_offset_time number;
l_offset_time number;
l_from_routing_seq_id number;
l_to_routing_seq_id number;
l_from_operation_seq_id number;
l_to_operation_seq_id number;
l_from_inventory_item_id number;
l_to_inventory_item_id number;
l_column_name varchar2(255);

cursor curr_supply(p_curr_plan_id number , p_curr_inst_id number
                  , p_curr_trans_id number ,p_operation_seq_num number ,p_resource_seq_num number) is
select mrr.operation_sequence_id , ms.routing_sequence_id  , ms.inventory_item_id
from msc_supplies ms ,msc_resource_requirements mrr
where   ms.transaction_id = mrr.supply_id
and ms.plan_id            = mrr.plan_id
and mrr.operation_seq_num = p_operation_seq_num
and mrr.resource_seq_num  = p_resource_seq_num
and mrr.operation_seq_num is not null
and ms.plan_id            = p_curr_plan_id
and ms.sr_instance_id     = p_curr_inst_id
and ms.transaction_id     = p_curr_trans_id;

begin
open curr_supply(p_plan_id ,p_inst_id ,p_from_trans_id ,p_from_op_seq_num ,p_from_res_seq_num);
fetch curr_supply into l_from_operation_seq_id ,l_from_routing_seq_id ,l_from_inventory_item_id;
close curr_supply;

open curr_supply(p_plan_id ,p_inst_id ,p_to_trans_id ,p_to_op_seq_num ,p_to_res_seq_num);
fetch curr_supply into l_to_operation_seq_id ,l_to_routing_seq_id ,l_to_inventory_item_id;
close curr_supply;

if p_min_max_flag = 'MINIMUM' then
	l_column_name := 'MINTT' ;
elsif p_min_max_flag = 'MAXIMUM' then
	l_column_name := 'MAXTT' ;
end if;

l_offset_time := get_mfd_details(p_plan_id,
				 p_from_trans_id,
				 p_inst_id,
				 l_from_routing_seq_id,
				 l_from_operation_seq_id,
				 l_from_inventory_item_id,
				 p_to_trans_id,
				 p_inst_id,
				 l_to_operation_seq_id,
				 l_column_name);
return l_offset_time;

end get_min_max_offset_time;

function get_load_ratio_diff_threshold(p_plan_id number,
					p_sr_instance_id number,
					p_organization_id number,
					p_department_id number,
					p_resource_id number)
	return number
is
l_return number;

cursor cur(l_plan_id number ,l_sr_instance_id number ,l_organization_id number
                            ,l_department_id number ,l_resource_id number) is
select utilization_change_percent
	from msc_department_resources
	where plan_id        = l_plan_id
	and sr_instance_id   = l_sr_instance_id
	and organization_id  = l_organization_id
	and department_id    = l_department_id
	and resource_id      = l_resource_id ;

begin
open cur(p_plan_id  ,p_sr_instance_id  ,p_organization_id
                            ,p_department_id  ,p_resource_id );
fetch cur into l_return;
close cur;

return l_return;
end get_load_ratio_diff_threshold;

function get_ship_to_consumption_level(p_demand_plan_id number,
				       p_scenario_id  number
				       )
	return number
is
l_level number;
l_ship_to_code number ;

cursor cur_ship_to(l_demand_plan_id number ,l_scenario_id  number) is
select decode(level_id ,1,6
                       ,11,7
		       ,12,5
		       ,15,4
		       ,34,10
		       ,41,9
		       ,42,8,1)
 from msd_dp_scn_output_levels_v
where demand_plan_id = l_demand_plan_id
and scenario_id    = l_scenario_id
and level_id in(1,11,12,15,34,41,42);
begin
/*----------------------------------------------------------------------
Mapping of demand scenarios with ship to consumption level is
Ship_to	Ship_to_code	Level_id
Ship		2	7
Bill		3	7
Customer	4	15
Region		5	12
Item		6	1
Customer Site	7	11
Zone		8	42
Customer Zone	9	41
Demand Class	10	34
------------------------------------------------------------------------*/
open cur_ship_to(p_demand_plan_id  ,p_scenario_id  );
fetch cur_ship_to into l_ship_to_code ;
close cur_ship_to;
return l_ship_to_code;
end get_ship_to_consumption_level;


function GET_preference(p_key varchar2,
                        p_pref_id number,
                        p_plan_type number)  return varchar2 is

 cursor get_pref_c is
 select key, value
 from msc_user_preference_values
 where key= p_key
 and   preference_id = p_pref_id;

 l_key varchar2(80);
 l_plan_type number;

 cursor pref_def_c is
 select preference_key,default_value
 from msc_user_preference_keys
 where preference_key= p_key
 and   plan_type = l_plan_type;

 l_value varchar2(2000);


  cursor c_default_cat is
  select to_char(category_set_id)
  from msc_category_sets
  where default_flag = 1;

begin
  if p_pref_id is not null then
     open get_pref_c;
     fetch get_pref_c into l_key, l_value;
     CLOSE get_pref_c;
  end if;

  if l_key is null or -- pref_id exists but no pref_key
     p_pref_id is null then

    -- get default value
     l_plan_type := p_plan_type;

     if p_plan_type not in (4,5,8) then
         l_plan_type := 1;
     end if;

    if p_key = 'CATEGORY_SET_ID' then
      open c_default_cat;
      fetch c_default_cat into l_value;
      close c_default_cat;
      if l_value is null then
         l_value := fnd_profile.value('MSC_SRA_CATEGORY_SET');
      end if;
    else
      l_key := null;
      open pref_def_c;
      fetch pref_def_c into l_key,l_value;
      CLOSE pref_def_c;
      if l_key is null then
         -- find the common one from plan_type 1
         l_plan_type := 1;
         open pref_def_c;
         fetch pref_def_c into l_key,l_value;
         CLOSE pref_def_c;
      end if;
    end if;
  end if;
  return trim(l_value);
end GET_preference;

FUNCTION lookup_fnd(arg_lookup_type IN varchar2, arg_lookup_code IN varchar2) return varchar2 IS
  meaning_text varchar2(80);
BEGIN
   if arg_lookup_code is null or  arg_lookup_code is null then
      return null;
   end if;

   select meaning
   into meaning_text
   from fnd_lookups
   where lookup_type = arg_lookup_type
     and lookup_code = arg_lookup_code;

   return meaning_text;

EXCEPTION when no_data_found THEN
  return null;
END lookup_fnd;



function get_default_pref_id(p_user_id number,p_plan_type in number default
null) return number is
cursor get_default_pref_id_c(p_user_id number) is
select preference_id
from msc_user_preferences
where default_flag =1
and   user_id = p_user_id;

cursor get_default_srppref_id_c(p_user_id number, p_plan_type in number) is
select preference_id
from msc_user_preferences
where default_flag =1
and   user_id = p_user_id
and  plan_type=p_plan_type;

l_def_pref_id number;
begin
    g_plan_type:= p_plan_type;
    if nvl(g_plan_type,0) = 8 then
        open get_default_srppref_id_c(p_user_id, g_plan_type);
        fetch get_default_srppref_id_c into l_def_pref_id;
        if get_default_srppref_id_c%notfound then
            close get_default_srppref_id_c;
            return to_number(null);
        end if;
        Close get_default_srppref_id_c;
    else
        open get_default_pref_id_c(p_user_id);
        fetch get_default_pref_id_c into l_def_pref_id;
        if get_default_pref_id_c%notfound then
            close get_default_pref_id_c;
            return to_number(null);
        end if;
        close get_default_pref_id_c;
    end if;

return l_def_pref_id;

end get_default_pref_id;


FUNCTION get_std_op_code(p_plan_id              number,
                         p_sr_instance_id       number,
                         p_routing_sequence_id  number,
                         p_op_seq_id         number) return varchar2 is
cursor get_std_op_code_c(p_plan_id              number,
                         p_sr_instance_id       number,
                         p_routing_sequence_id  number,
                         p_op_seq_id            number) is
select standard_operation_code
from msc_routing_operations
where plan_id             = p_plan_id
and   sr_instance_id      = p_sr_instance_id
and   routing_sequence_id = p_routing_sequence_id
and   operation_sequence_id = p_op_seq_id;

l_std_op_code varchar2(4);
begin
open get_std_op_code_c(p_plan_id,p_sr_instance_id,p_routing_sequence_id,p_op_seq_id);
fetch get_std_op_code_c into l_std_op_code;
if get_std_op_code_c%notfound then
  return null;
end if;
close get_std_op_code_c;
return l_std_op_code;
EXCEPTION
  WHEN OTHERS THEN
  IF get_std_op_code_c%ISOPEN THEN
     CLOSE get_std_op_code_c;
     return null;
  END IF;
end get_std_op_code;

function res_instance_data(p_req_column IN varchar2,
    p_plan_id IN number,
    p_sr_instance_id IN number,
    p_organization_id IN number,
    p_department_id IN number,
    p_resource_id IN Number,
    p_supply_id IN Number,
    p_operation_seq_num IN Number,
    p_resource_seq_num IN Number,
    p_orig_resource_seq_num IN Number,
    p_parent_seq_num IN Number,
    p_parent_Id IN Number) return varchar2
is
begin
    return null;
end res_instance_data;

FUNCTION get_processing_leadtime(p_plan_id number,
                                  p_org number,
		                          p_inst number,
		                          p_item number,
		                          p_supplier number,
		                          p_supplier_site number) return number
IS

CURSOR c_processing_lt_suppliers (p_plan_id number,
                                  p_org number,
		                          p_inst number,
		                          p_item number,
		                          p_supplier number,
		                          p_supplier_site number) is
    select processing_lead_time
    from msc_item_suppliers
	where plan_id = p_plan_id
	and organization_id = p_org
	and sr_instance_id = p_inst
	and inventory_item_id = p_item
    and using_organization_id = -1
	and supplier_id = p_supplier
	and supplier_site_id = p_supplier_site;

cursor c_processing_lt_items(p_plan_id in number,
                       p_sr_instance_id in number,
                       p_organization_id in number,
                       p_inventory_item_id in number)
is
select full_lead_time
from msc_system_items
where plan_id  = p_plan_id
and sr_instance_id  = p_sr_instance_id
and organization_id = p_organization_id
and inventory_item_id = p_inventory_item_id;

l_processing_leadtime number;

begin

	IF p_item IS NOT NULL and p_org IS NOT NULL THEN
         OPEN c_processing_lt_suppliers( p_plan_id,
                                         p_org,
    	                                 p_inst,
                                         p_item,
    	                                 p_supplier,
    	                                 p_supplier_site);
         FETCH c_processing_lt_suppliers into l_processing_leadtime;
         CLOSE c_processing_lt_suppliers;
         if l_processing_leadtime is null then
             OPEN c_processing_lt_items( p_plan_id,
                                         p_org,
    	                                 p_inst,
                                         p_item);
             FETCH c_processing_lt_items into l_processing_leadtime;
             CLOSE c_processing_lt_items;
         end if;
   end if;
   return  l_processing_leadtime;
end get_processing_leadtime;

FUNCTION check_cfm(p_plan_id number,p_org_id number,
                   p_instance_id number, p_item_id number,
                   p_transaction_id number,
                   p_impl_alt_routing varchar2) return number is
  CURSOR CFM_C IS
   select cfm_routing_flag
     from msc_supplies
    where plan_id = p_plan_id
      and transaction_id = p_transaction_id
      and sr_instance_id = p_instance_id;

  CURSOR routing_c IS
      select cfm_routing_flag
        from msc_routings
      where plan_id = p_plan_id
      and organization_id = p_org_id
      and assembly_item_id = p_item_id
      and sr_instance_id = p_instance_id
      and (alternate_routing_designator = p_impl_alt_routing or
           (p_impl_alt_routing is null and
            alternate_routing_designator is null));

  v_temp number;
BEGIN

       if p_transaction_id is null then
-- unsaved new planned order won't have transaction_id yet when this is called

        -- for manually create planned order,
        -- if impl_alt_routing is entered, use it first,
        -- otherwise, use primary routing
             OPEN routing_c;
             FETCH routing_c into v_temp;
             CLOSE routing_c;
       else
             OPEN CFM_C;
             FETCH CFM_C into v_temp;
             CLOSE CFM_C;

       end if;

       return v_temp;

END check_cfm;

FUNCTION load_type ( p_plan_type IN NUMBER
                   , p_plan_id IN NUMBER
                   , p_source_table IN VARCHAR2  -- MSC_SUPPLIES or MSC_DEMANDS
                   , p_transaction_id IN NUMBER  -- or demand_id
                   , p_organization_id IN NUMBER
                   , p_sr_instance_id IN NUMBER  -- not reqd, but can hit U1 index with this
                   , p_order_type IN NUMBER
                   , p_implement_as IN NUMBER
                   , p_source_organization_id IN NUMBER
                   , p_source_sr_instance_id IN NUMBER
                   , p_cfm_routing_flag IN NUMBER
                   , p_item_id IN NUMBER DEFAULT NULL
                   , p_impl_alt_routing IN VARCHAR2 DEFAULT NULL
                   ) RETURN NUMBER IS

  v_cfm_routing_flag NUMBER;
  v_load_type NUMBER;

 -- IRproject
 cursor iso_exists  IS
 select 1
 from msc_demands
 where disposition_id = p_transaction_id
 and plan_id = p_plan_id
 and organization_id  = p_source_organization_id
 and origination_type = 30
 and sr_instance_id = p_sr_instance_id;

 cursor ir_exists IS
 select 1
 from msc_supplies
 where plan_id = p_plan_id
 and sr_instance_id = p_sr_instance_id
 and order_type = 2
 and transaction_id in
        (select  disposition_id
         from msc_demands
         where demand_id = p_transaction_id
         and  plan_id = p_plan_id
         and organization_id = p_organization_id
         and sr_instance_id = p_sr_instance_id) ;

l_iso_in_plan number := 0;
l_ir_in_plan number := 0;

BEGIN

    IF p_source_table = 'MSC_SUPPLIES' THEN

      -- not passed in manual release (MSCFNORD)
      -- select-all will always pass this
      IF p_cfm_routing_flag IS NULL and
         ((p_order_type = 5 and p_implement_as = 3) or
           p_order_type = 3) THEN
           v_cfm_routing_flag :=
              msc_get_name.check_cfm(
                 p_plan_id,
                 p_organization_id,
                 p_sr_instance_id,
                 p_item_id,
                 p_transaction_id,
                 p_impl_alt_routing);
      ELSE
        v_cfm_routing_flag := p_cfm_routing_flag;
      END IF;

      IF p_order_type = 5 THEN
        -- planned order
        IF p_implement_as = 3 THEN
            IF v_cfm_routing_flag = 3 THEN
              -- Load Lot_based Job
              v_load_type := 5;
            ELSE
              -- WIP discrete mass load
              v_load_type := 1;
            END IF;
        ELSIF p_implement_as = 2 THEN
          -- PO requisition mass load
          v_load_type := 8;
        ELSIF p_implement_as = 4 THEN
          -- WIP repetitive mass load
          v_load_type := 2;
        ELSE
          v_load_type := NULL;
        END IF;
      ELSIF p_order_type = 3 THEN
        IF v_cfm_routing_flag = 3 THEN
          -- Reschedule Lot_based Job
          v_load_type := 6;
        ELSE
          -- WIP discrete reschedule
          v_load_type := 4;
        END IF;
      ELSIF p_order_type = 2 THEN
        -- PO requisition reschedule

        --IRproject
        -- IR/ISO enhancement
        -- if both IR and ISO are in the plan ,
        -- set load_type = 64, else to 16
        IF p_source_organization_id <> p_organization_id THEN -- means IR
            open iso_exists;
            fetch iso_exists  into l_iso_in_plan;
            close iso_exists;
            IF l_iso_in_plan  = 1 THEN
                v_load_type := 64;
            ELSE
               v_load_type := 16;
            END IF;
        ELSE -- for all non-internal reqs
               v_load_type := 16;
        END IF;

      ELSIF p_order_type = 1 THEN
        -- Purchase order reschedule
        v_load_type := 20;
      ELSIF p_order_type IN (4,13) THEN
        -- WIP repetitive mass load
        v_load_type := 2;
      ELSE
        v_load_type := NULL;
      END IF;
      IF p_plan_type = 5 THEN  -- DRP
        IF p_order_type = 51 THEN
          IF p_implement_as = 2 THEN
            -- PO requisition mass load
            v_load_type := 8;
          ELSIF p_implement_as = 5 THEN
              -- internal req mass load
              v_load_type := 32;
          END IF;
        ELSIF p_order_type = 53 and p_source_organization_id <> p_organization_id THEN

          --IRproject
            open iso_exists;
            fetch iso_exists  into l_iso_in_plan;
            close iso_exists;
            if l_iso_in_plan = 1  then
                -- internal req reschedule
                v_load_type := 64;
            else
                v_load_type := 16;
            end if;
        END IF;
      END IF; --  IF p_plan_type = 5 THEN

      --pabram.srp.release.changes.begins
      IF p_plan_type in (8) THEN  -- srp
        IF p_order_type = 76 THEN
            -- Planned New Buy Order
            v_load_type := 8;
        ELSIF p_order_type = 51 THEN
              -- Planned Transfer
              v_load_type := 32;
        ELSIF p_order_type = 77 THEN
              -- Planned Internal Repair Order
              v_load_type := 256;
	ELSIF p_order_type = 78 THEN
            -- Planned External Repair Order
            v_load_type := 128;
        END IF;
      END IF; --  IF p_plan_type in (8)
      --pabram.srp.release.changes.ends

    ELSE -- p_source_table = 'MSC_DEMANDS'
       IF p_order_type in (30) THEN
   --     v_load_type := 30;
        IF p_plan_type = 1 THEN -- ASCP
           open ir_exists;
           fetch ir_exists into l_ir_in_plan;
           close ir_exists;
           IF  l_ir_in_plan = 1  THEN
              v_load_type := 64;
           ELSE
               v_load_type := 30;
           END IF;
         ELSE -- other plans,in DRP if IR does not exist order type of ISO = 30
             v_load_type := 30;
        END IF;

      ELSIF p_order_type =53 THEN -- planned shipment
          IF p_implement_as = 2 THEN
            -- PO requisition mass load
            v_load_type := 8;
          ELSIF p_implement_as = 5 THEN
              -- internal req mass load
              v_load_type := 32;
          END IF;
      ELSIF p_order_type =54 THEN -- ISO
          -- internal req reschedule
          v_load_type := 64;
      ELSE
        v_load_type := NULL;
      END IF;
    END IF;
    RETURN v_load_type;
    EXCEPTION
      when others THEN
        RETURN null;
END load_type;

FUNCTION get_equipment_desc(arg_plan_id IN NUMBER,
                            arg_org_id IN NUMBER,
                            arg_instance_id IN NUMBER,
                            arg_item_id IN NUMBER) return varchar2 is
 v_item_desc varchar2(2000);

BEGIN
  if arg_item_id is null or
     arg_item_id < 0 then
     return null;
  elsif arg_org_id is null or
     arg_plan_id is null or
     arg_instance_id is null then
    select description
    into v_item_desc
    from msc_items
    where inventory_item_id = arg_item_id;
    return v_item_desc;
  end if;

  select description
  into v_item_desc
  from msc_system_items
  where inventory_item_id = arg_item_id
  and   plan_id = arg_plan_id
  and   organization_id = arg_org_id
  and   sr_instance_id = arg_instance_id
  AND  (new_plan_id = -1 OR new_plan_id IS NULL )
  AND  (SIMULATION_SET_ID IS NULL);
  return v_item_desc;

  exception when no_data_found then
    select description
    into v_item_desc
    from msc_items
    where inventory_item_id = arg_item_id;
  return v_item_desc;

END get_equipment_desc;

   function isResReqSegments_Available(p_plan_id          in number,
                                   p_sr_instance_id        in number,
                                   p_trans_id              in number)
     return number is
        cursor cur_res_req_records(p_plan_id               in number,
                                   p_sr_instance_id        in number,
                                   p_trans_id              in number) is
        select count(*)
        from  msc_segment_allocations
        where   plan_id = p_plan_id
            and ((producer_sr_instance_id = p_sr_instance_id and
                  from_res_transaction_id = p_trans_id)
              or (consumer_sr_instance_id = p_sr_instance_id and
                  to_res_transaction_id = p_trans_id));

        l_count          number;

    begin
              open cur_res_req_records(p_plan_id,
                                       p_sr_instance_id,
                                       p_trans_id);
              fetch cur_res_req_records into l_count;
              if cur_res_req_records%notfound then
                close cur_res_req_records;
              end if;
              close cur_res_req_records;

              return l_count;
    end;

FUNCTION get_application_id(arg_application_name in varchar2) return number IS
application_id number;
BEGIN
   if arg_application_name is null then
      return null;
   end if;

    select application_id into application_id
    from fnd_application
    where application_short_name = arg_application_name;

     return application_id;

EXCEPTION when no_data_found THEN
    return null;
END get_application_id;

FUNCTION setup_std_op_code(
                  p_plan_id IN NUMBER,
                  p_sr_instance_id IN NUMBER,
                  p_department_id IN NUMBER,
                  p_org_id IN NUMBER,
                  p_supply_id IN Number,
                  p_operation_seq_num IN Number,
                  p_resource_seq_num IN number,
                  p_parent_seq_num IN Number,
                  p_setup_id IN Number,
                  p_schedule_flag IN Number
                  ) return varchar2 IS

  v_from_setup_id Number;
  v_to_setup_id Number;
  v_resource_id Number;
  v_operation_code varchar2(50):=null;
  v_count number := 0;
  CURSOR setup_c IS
    select
        res.from_setup_id
        ,res.setup_id
        ,res.resource_id
    from
        msc_resource_requirements res
    where res.plan_id = p_plan_id
    and res.sr_instance_id = p_sr_instance_id
    and res.department_id=p_department_id
    and res.organization_id = p_org_id
    and res.supply_id=p_supply_id
    and nvl(res.operation_seq_num,-23453)=nvl(p_operation_seq_num,-23453)
    and nvl(res.resource_seq_num,-23453)=nvl(p_resource_seq_num,-23453)
--  and nvl(res.orig_resource_seq_num, -23453)=nvl(p_parent_seq_num,-23453) -- get setup id's from parent
    and nvl(res.parent_seq_num, -23453)=nvl(p_parent_seq_num,-23453) -- instead get from setup activity
    and nvl(res.parent_id,2)=2
    and res.setup_id is not null
    and res.from_setup_id is not null;

BEGIN

    IF  p_plan_id is null or
        p_sr_instance_id is null or
        p_department_id is null or
        p_org_id is null or
        p_supply_id is null
    THEN
        return null;
    END IF;


    IF p_setup_id is not null -- SDS activity, so no need to show operation
    or p_schedule_flag = 1 -- YES activity, not a setup activity
    THEN
        return null;
    END IF;

    OPEN setup_c;
    FETCH setup_c INTO v_from_setup_id, v_to_setup_id, v_resource_id;
    v_count := setup_c%ROWCOUNT;
    CLOSE setup_c;


    IF v_count > 0 THEN
        v_operation_code := standard_operation_code(p_plan_id,
                      p_sr_instance_id,
                      v_resource_id,
                      p_org_id,
                      v_from_setup_id,
                      v_to_setup_id
                      );
        return v_operation_code;
    END IF;
    return null;

EXCEPTION when others THEN
    return null;

END setup_std_op_code;

    FUNCTION is_within_rel_time_fence(p_plan_start_date  IN DATE,
                                      P_order_start_date IN DATE,
                                      p_release_time_fence_code     IN NUMBER,
                                      P_cumulative_total_lead_time  IN NUMBER,
                                      P_cum_manufacturing_lead_time IN NUMBER,
                                      P_full_lead_time              IN NUMBER,
                                      P_release_time_fence_days     IN NUMBER
                                    ) RETURN NUMBER IS
        l_days NUMBER;
        l_start_date date;
    BEGIN
        l_days :=0;
        IF p_release_time_fence_code = 1 THEN
            l_days:= NVL(p_cumulative_total_lead_time,0);
        ELSIF p_release_time_fence_code = 2 THEN
            l_days:= NVL(P_cum_manufacturing_lead_time,0);
        ELSIF p_release_time_fence_code = 3 THEN
            l_days:= NVL(P_full_lead_time,0);
        ELSIF p_release_time_fence_code = 4 THEN
            l_days:= NVL(P_release_time_fence_days,0);
        END IF;
        l_start_date := trunc(p_plan_start_date);
        IF P_order_start_date between l_start_date and (p_plan_start_date+l_days) THEN
            RETURN 1;
        ELSE
            RETURN 2;
        END IF;
    EXCEPTION
        WHEN others THEN
            RETURN 2;
    END is_within_rel_time_fence;

-- This function executes dynamic sql and returns count.

function execute_sql_getcount(arg_sql_stmt VARCHAR2) return number IS
   v_count number := 0;
BEGIN

  EXECUTE IMMEDIATE arg_sql_stmt;

  if (SQL%ROWCOUNT) > 0 then
    v_count := SQL%ROWCOUNT;
  else
    v_count := 0;
  end if;

  return v_count;

END execute_sql_getcount;

FUNCTION implement_as(p_order_type number,
                      p_org_id number,
                      p_source_org_id number,
                      p_source_supplier_id number,
                      p_build_in_wip_flag number,
                      p_planning_make_buy_code number,
                      p_purchasing_enabled_flag number,
                      p_cfm_routing_flag number) RETURN number IS
  v_out number;
BEGIN
  IF p_order_type = 13 then
     v_out := 104; --'Repetitive Schedules';
  ELSIF p_order_type in (51,77) then
-- Planned Internal Repair Order
     v_out := 200; -- Internal Requisition
  ELSIF p_order_type in (76,78) then
-- Planned New Buy Order,Planned External Repair Order
     v_out := 101; -- purchase req
  ELSIF p_order_type = 79 then
   -- Planned Repair Work Order
     v_out := 102; -- discrete job
  ELSE -- p_order_type = 5
     if p_org_id = p_source_org_id then
        if p_build_in_wip_flag = 1 then
           v_out := 102;  -- discrete job
        end if;
     elsif p_org_id <> p_source_org_id then
           v_out := 101; -- purchase req
     elsif p_source_supplier_id is not null then
           if p_purchasing_enabled_flag = 1 then
              v_out := 101; -- purchase req
           end if;
     elsif p_source_supplier_id is null and
           p_source_org_id is null then
           if p_planning_make_buy_code =1 then
              if p_build_in_wip_flag = 1 then
                 v_out := 102;  -- discrete job
              end if;
           else -- p_planning_make_buy_code =2
              if p_purchasing_enabled_flag =1 then
                 v_out := 101; -- purchase req
              end if;
           end if; --if p_planning_make_buy_code =1 then
     end if;
  END IF; -- IF p_order_type = 13 then

  if v_out = 102 and p_cfm_routing_flag =1 then
     v_out := 103; -- Flow Schedules
  end if;

  return v_out;
END implement_as;

FUNCTION get_res_units(p_plan_id     IN NUMBER,
                  p_sr_instance_id   IN NUMBER,
                  p_org_id           IN NUMBER,
                  p_department_id    IN NUMBER,
                  p_resource_id      IN NUMBER,
                  p_batch_start_date IN DATE,
                  p_batch_end_date   IN DATE) RETURN number
IS
   CURSOR c_capacity_units IS
   select capacity_units
   from msc_net_resource_avail
   where plan_id = p_plan_id
       and sr_instance_id = p_sr_instance_id
       and organization_id = p_org_id
       and department_id = p_department_id
       and resource_id = p_resource_id
       and trunc(shift_date)  between trunc(p_batch_start_date)
                                  and trunc(p_batch_end_date)
       and rownum = 1;

   v_capacity_units number;
BEGIN
    OPEN c_capacity_units;
    FETCH c_capacity_units INTO v_capacity_units;
    CLOSE c_capacity_units;

    return v_capacity_units;
end get_res_units;

FUNCTION category_set_name(p_cat_set_id NUMBER) return varchar2 is

  cursor c_cat_set_name is
  select category_set_name
  from msc_category_sets
  where category_set_id = p_cat_set_id;

  l_cat_set_name varchar2(30);
begin
  if (p_cat_set_id is null) then
    return null;
  end if;
  open c_cat_set_name;
  fetch c_cat_set_name into l_cat_set_name;
  close c_cat_set_name;
  return l_cat_set_name;
exception
  when others then
    return null;
end category_set_name;

FUNCTION get_default_dem_pri_rule_id  return number
is
cursor dem_pri is
	select rule_id
	from msc_scheduling_rules
	where default_flag = 'Y'
	and enabled_flag   = 'Y';

l_rule_id number;
Begin
open dem_pri;
fetch dem_pri into l_rule_id;
close dem_pri;

return l_rule_id ;
End get_default_dem_pri_rule_id ;


FUNCTION get_default_dem_pri_rule
  return varchar2 is

cursor dem_pri is
	select meaning
	from msc_scheduling_rules
	where default_flag = 'Y'
	and enabled_flag   = 'Y';

l_dem_rule varchar2(255);
Begin
open dem_pri;
fetch dem_pri into l_dem_rule;
close dem_pri;

return l_dem_rule;
End get_default_dem_pri_rule ;

  --5375991bugfix
  function op_desc(p_plan_id number, p_sr_instance_id number,
        p_routing_seq_id number, p_op_seq_id number) return varchar2 is

    cursor c_op_desc_cur is
    select mro.operation_description
    from msc_routing_operations mro
    where mro.plan_id = p_plan_id
      and mro.sr_instance_id = p_sr_instance_id
      and mro.routing_sequence_id = nvl(p_routing_seq_id, mro.routing_sequence_id)
      and mro.operation_sequence_id = p_op_seq_id;

    l_op_desc varchar2(240);
  begin
    open c_op_desc_cur;
    fetch c_op_desc_cur into l_op_desc;
    close c_op_desc_cur;

    return l_op_desc;
  exception
    when others then
        return null;
  end op_desc;

FUNCTION get_order_view(p_plan_type number, p_plan_id number)
         return varchar2 IS
  v_view varchar2(100);
BEGIN
  if p_plan_type = 5 then
     if p_plan_id = -1 then
        v_view := 'MSC_ORDERS_DRP_COL_V';
     else
        v_view := 'MSC_ORDERS_DRP_V';
     end if;
  else
     if p_plan_id = -1 then
        v_view := 'MSC_ORDERS_COL_V';
     else
        v_view := 'MSC_ORDERS_V';
     end if;
  end if;
  return v_view;
END get_order_view;


function get_srp_group_name(p_group_id number default null, p_user_id number default null, p_planned_by number default null)
return varchar2 is

cursor group_by_id (c_group_id number) is
    select
        group_name
    from
        msc_srp_groups
    where group_id = c_group_id;

cursor group_by_owner(c_owner varchar2, c_planner varchar2) is
    select
        g.group_name
    from
        msc_srp_user_groups owner,
        msc_srp_groups g
    where
        owner.user_id = c_owner
        and owner.group_id=g.group_id
        and exists -- check if the query owner and the planner belong to the currently fetched group
        ( select 1 from msc_srp_user_groups planner
          where planner.user_id = c_planner
          and owner.group_id=planner.group_id
        )
        and rownum=1;

l_group_name varchar2(240);

begin
    if p_group_id is null and p_user_id is null then
        return null;
    end if;

    if p_group_id is not null then
        open group_by_id(p_group_id);
            fetch group_by_id into l_group_name;
        close group_by_id;
        return l_group_name;
    end if;

    if p_user_id is not null then
        open group_by_owner(p_user_id, nvl(p_planned_by,p_user_id));
            fetch group_by_owner into l_group_name;
        close group_by_owner;
        return l_group_name;
    end if;

    return null;

exception
  when others then return null;
end;

  function forecast_rule_name(p_forecast_rule_id number) return varchar2 is
    cursor c_rule is
    select forecast_rule_name
    from msc_forecast_rules
    where forecast_rule_id = p_forecast_rule_id;
    l_rule varchar2(30);
  begin
    if (p_forecast_rule_id is null) then
      return null;
    end if;
    open c_rule;
    fetch c_rule into l_rule;
    close c_rule;
    return l_rule;
  exception
    when others then return null;
  end forecast_rule_name;


 Function get_order_Comments(p_plan_id in number,
                            p_entity_type  in varchar2,
                            p_transaction_id in number)
                       return varchar2 is

    CURSOR get_notes_details(lp_entity_type     VARCHAR2,
                             lp_plan_id         NUMBER,
                             lp_transaction_id  NUMBER) IS
    SELECT note_text1
    from msc_user_notes
    where entity_type    = lp_entity_type
    and   plan_id        = lp_plan_id
    and   transaction_id = lp_transaction_id;
    l_notes_text         varchar2(4000);
 begin
    --User notes enhancement

    if p_plan_id is null
      or p_entity_type is null
      or p_transaction_id is null then
        return null;
    end if;

    open get_notes_details(p_entity_type,
                           p_plan_id,
                           p_transaction_id);
    fetch get_notes_details into l_notes_text;
    close get_notes_details;
    return l_notes_text;
 Exception
    when others then
        return null;
 END get_order_Comments;

FUNCTION action_id(arg_source_table IN VARCHAR2,
                arg_bom_item_type IN NUMBER DEFAULT NULL,
                arg_base_item_id IN NUMBER DEFAULT NULL,
                arg_wip_supply_type IN NUMBER DEFAULT NULL,
                arg_order_type IN NUMBER DEFAULT NULL,
                arg_rescheduled_flag IN NUMBER DEFAULT NULL,
                arg_disposition_status_type IN NUMBER DEFAULT NULL,
                arg_new_due_date IN DATE DEFAULT NULL,
                arg_old_due_date IN DATE DEFAULT NULL,
                arg_implemented_quantity IN NUMBER DEFAULT NULL,
                arg_quantity_in_process IN NUMBER DEFAULT NULL,
                arg_quantity_rate IN NUMBER DEFAULT NULL,
		arg_release_time_fence_code IN NUMBER DEFAULT NULL,
                arg_reschedule_days IN NUMBER DEFAULT NULL,
                arg_firm_quantity IN NUMBER DEFAULT NULL,
                arg_plan_id  IN NUMBER DEFAULT NULL,
                arg_critical_component IN NUMBER DEFAULT NULL,
                arg_mrp_planning_code  IN NUMBER DEFAULT NULL,
                arg_lots_exist IN NUMBER DEFAULT NULL,
                arg_part_condition IN NUMBER DEFAULT NULL) RETURN Number

IS

  --CURSOR OPTIONS_C IS
  --SELECT NVL(orders_release_configs,'N'),
  --	NVL(orders_release_phantoms,'N')
  --FROM msc_workbench_display_options
  --WHERE user_id = fnd_global.user_id;

  CURSOR internal_sales(p_plan_id number,
                         p_tran_id number, p_inst_id number) IS
     select ms.disposition_status_type,
            msc_get_name.action_id('MSC_SUPPLIES', msi.bom_item_type,
                msi.base_item_id, msi.wip_supply_type, ms.order_type,
                DECODE(ms.firm_planned_type,1,1,ms.reschedule_flag),
                ms.disposition_status_type,
                ms.new_schedule_date, ms.old_schedule_date,
                ms.implemented_quantity, ms.quantity_in_process,
                ms.new_order_quantity,
                msi.release_time_fence_code, ms.reschedule_days,
                ms.firm_quantity,ms.plan_id,
                msi.critical_component_flag, msi.mrp_planning_code,
                msi.lots_exist)
       from msc_supplies ms,
            msc_system_items msi
       where ms.plan_id = p_plan_id
         and ms.transaction_id = p_tran_id
         and ms.sr_instance_id = p_inst_id
         and ms.plan_id = msi.plan_id
         and ms.sr_instance_id = msi.sr_instance_id
         and ms.organization_id = msi.organization_id
         and ms.inventory_item_id  = msi.inventory_item_id ;

  CURSOR excp_exist(p_plan_id number,
                         p_demand_id number) IS
     select 1
       from msc_exception_details med,
            msc_demands md
       where med.plan_id = md.plan_id
         and med.organization_id = md.organization_id
         and med.sr_instance_id = md.sr_instance_id
         and med.inventory_item_id = md.inventory_item_id
         and med.number1 = md.demand_id
         and med.exception_type in (70,71)
         and md.plan_id = p_plan_id
         and md.demand_id = p_demand_id
         and (nvl(md.source_organization_id, -1) < 0 or -- can not release ISO
               (md.source_organization_id >0 and
                md.source_org_instance_id <> md.sr_instance_id));

  CURSOR type_of_plan(p_plan_id number) IS
  select plan_type
  from   msc_plans
  where  plan_id = p_plan_id;


  l_action	Number;
  l_configs	VARCHAR2(3) := 'X';
  l_phantoms	VARCHAR2(3) := 'X';
  v_temp number;
  l_plan_type   NUMBER;
  v_ir_action number;
  l_pref_id number;

  CURSOR bkt_c(p_date date) IS
  select bucket_index
    from msc_plan_buckets mpb,
         msc_plans mp
   where mp.plan_id = arg_plan_id
     and mp.plan_id = mpb.plan_id
     and mp.organization_id = mpb.organization_id
     and mp.sr_instance_id = mpb.sr_instance_id
     and p_date between mpb.bkt_start_date and mpb.bkt_end_date;

  p_new_date_index number;
  p_old_date_index number;

BEGIN
  OPEN type_of_plan(arg_plan_id);
  FETCH type_of_plan INTO l_plan_type;
  CLOSE type_of_plan;

  IF arg_source_table = 'MSC_SUPPLIES' THEN
    IF arg_lots_exist = 2 and
       arg_order_type =5 and
       arg_quantity_rate <> 0 then
       -- plan generated planned order from supply schedule
       return 6;
    END IF;

    IF NVL(arg_release_time_fence_code,-1) = 7 THEN
        -- Shikyu item
        return 6;
    END IF;

    IF arg_base_item_id IS NOT NULL
	OR arg_wip_supply_type = 6 THEN
        if (l_plan_type in (101,102,103,104,105)) then
           l_configs := 'Y';
           l_phantoms := 'N';
         else

          l_pref_id := get_default_pref_id(fnd_global.user_id,l_plan_type);
           l_configs := GET_preference('ORDERS_RELEASE_CONFIGS',
                          l_pref_id,
                          l_plan_type );
           l_phantoms := GET_preference('ORDERS_RELEASE_PHANTOMS',
                          l_pref_id,
                          l_plan_type );
         end if;
        --OPEN OPTIONS_C;
        --FETCH OPTIONS_C INTO l_configs, l_phantoms;
        --CLOSE OPTIONS_C;
    END IF;

    IF arg_bom_item_type IN (1, 2, 3, 5) OR
       (arg_base_item_id IS NOT NULL AND
        l_configs = 'N') OR
       (arg_wip_supply_type = 6 AND
        l_phantoms = 'N') OR
        arg_order_type IN (7, 14, 15, 16, 17, 18, 19, 27, 28)
        THEN

      -- Model Option Class
      l_action := 6;

    ELSE

      IF arg_rescheduled_flag = 1 and arg_order_type not in (5,51) THEN

        -- already took action
        l_action := 6;

      ELSIF arg_disposition_status_type = 2 THEN
        -- Cancel order
        l_action := 1;

      --pabram.srp.changes.added 76,77,78
      ELSIF arg_order_type in (5,51,13,76,77,78) THEN
        IF (NVL(arg_implemented_quantity, 0) +
           NVL(arg_quantity_in_process, 0) >=
           nvl(arg_firm_quantity,arg_quantity_rate))
	  OR NVL(arg_release_time_fence_code,-1) = 6 THEN

          -- nvl(arg_firm_quantity, is added for partial release
          -- Planned order has been released
          -- set action to none
          l_action := 6;

        ELSIF arg_order_type = 51 and
              nvl(arg_part_condition,1) = 2 THEN
          declare
	    l_profile varchar2(1);
          begin
            l_profile := fnd_profile.value('MSC_ENABLE_REL_DFCT_PLAN_TRNSFRS');
            if nvl(l_profile,'N') = 'Y' Then
                -- Release
                l_action := 4;
            ELSE
                -- 6676007, defective part, set action to none
                l_action := 6;
            END IF;
          end;
        ELSE
          -- Release
          l_action := 4;

        END IF;

      ELSIF nvl(arg_reschedule_days,0) <> 0 THEN
--bug#1979161, new_due_date might differ from old_due_date due to nonworking
-- day issue
        IF (arg_order_type in  (8,11,12) ) then
          l_action := 6;
        ELSE
 --bug5984599, need to check if they are in same planning bucket
          OPEN bkt_c(trunc(arg_new_due_date));
          FETCH bkt_c INTO p_new_date_index;
          CLOSE bkt_c;

          OPEN bkt_c(trunc(arg_old_due_date));
          FETCH bkt_c INTO p_old_date_index;
          CLOSE bkt_c;

          IF p_new_date_index = p_old_date_index THEN

            l_action := 6;

          ELSIF trunc(arg_new_due_date) > trunc(arg_old_due_date) THEN
          -- p_old_date_index could be null, if so, use old logic

        -- Reschedule out
            l_action := 3;

          ELSIF trunc(arg_new_due_date) < trunc(arg_old_due_date) THEN

        -- Reschedule in
            l_action := 2;
          END IF;
        END IF;
      ELSIF arg_order_type in (4,13) THEN
        IF arg_bom_item_type IN (1, 2, 3, 5) THEN

          -- Model option class
          l_action := 6;

        ELSE

          -- Release
          l_action :=4;
        END IF;
      ELSE

        -- Action is not required.
        l_action := 6;
      END IF;
    END IF;
    -- action should be set to NONE for the critical components
    -- Plan type = MPS, item attribute <>( MPS planning  or  MPS/DRP planning),
    -- Plan type = DRP, item attribute <> (DRP planning
                    --       or MRP/DRP planning or  MPS/DRP  planning) .
    -- ASCP UI displays action NONE for all critical components.
    IF arg_critical_component  = 1  THEN
       --OPEN type_of_plan(arg_plan_id);
       --FETCH type_of_plan INTO l_plan_type;
       --CLOSE type_of_plan;

       IF l_plan_type = 2  and  -- MPS
          arg_mrp_planning_code not in (4,8 ) THEN

           l_action :=6;

       ELSIF l_plan_type = 3  and -- DRP
             arg_mrp_planning_code NOT in (9, 7, 8)   THEN

           l_action := 6;

       END IF;
    END IF;

  ELSE

    -- This record does note come from MSC_SUPPLIES
    l_action := 6;
    IF NVL(arg_release_time_fence_code,-1) = 7 THEN
        -- Shikyu item
        RETURN l_action;
    END IF;

    if arg_source_table = 'MSC_DEMANDS' and
         arg_plan_id <> -1 and -- plan_id <> -1
         arg_order_type in (30,6) then -- sales order
         OPEN internal_sales(arg_plan_id, -- plan_id
                             arg_base_item_id,  -- disposition_id
                             arg_wip_supply_type); -- sr_instance_id
         FETCH internal_sales INTO v_temp, v_ir_action;
         CLOSE internal_sales;
         -- IRproject
         --if v_temp = 2 then -- cancel
         --   l_action := msc_get_name.lookup_meaning('MRP_ACTIONS',1);
         if arg_bom_item_type in ( 5, 1)  and -- plan_type
               v_ir_action is not null then -- use action from related IR
            l_action := v_ir_action;
          else
            if  arg_rescheduled_flag = 1 then -- already reschedule
                -- none
                l_action := 6;

            elsif (arg_bom_item_type >100)
                  and  (arg_implemented_quantity is not null)
                       -- original_demand_id
                  and (arg_quantity_rate <> nvl(arg_firm_quantity,
                        -- old_demand_qty
                      arg_quantity_rate)) then
                    --original demand_id
                  l_action := 6;

             /*elsif arg_quantity_rate <>
 *                       nvl(arg_firm_quantity, -- old_demand_qty
 *                                                 arg_quantity_rate) then
 *                                                                 -- can not
 *                                                                 release split
 *                                                                 so,
 *                                                                 bug6122088
 *                                                                                 --
 *                                                                                 none
 *                                                                                                 l_action
 *                                                                                                 :=
 *                                                                                                 6;
 *                                                                                                             */
            elsif arg_release_time_fence_code <> -- inventory_item_id
                  arg_reschedule_days and
                  arg_reschedule_days <> 0 then -- original_item_id
                    -- release, bug5972090
                    -- item_id <> original_item_id and not split
                    l_action := 4;
            else
                if arg_bom_item_type = 5 then -- plan_type
                   if nvl(arg_implemented_quantity,2) =1 or
--sales_order_line_split
                      nvl(arg_quantity_in_process,2) =1 then --fill_kill_flag
                      l_action :=6;
                      return l_action;
                   end if;
                end if;
                v_temp :=0;
                OPEN excp_exist(arg_plan_id, -- plan_id
                        arg_disposition_status_type); -- demand_id
                FETCH excp_exist INTO v_temp;
                CLOSE excp_exist;

                if v_temp = 1 then -- Sales Order changes excp exists
                    -- release
                    l_action := 4;
                else
                    -- none
                    l_action := 6;
                end if;
            end if; -- if  arg_rescheduled_flag = 1
         end if; -- if v_temp = 2 then -- cancel
    end if; -- if arg_source_table = 'MSC_DEMANDS'


  END IF;
  return l_action;
END action_id;
FUNCTION carrier(arg_carrier_id IN NUMBER) return varchar2 IS
carrier_name varchar2(240);
BEGIN

  if arg_carrier_id is null then
     return null;
  end if;
   select partner_name
   into carrier_name
   from msc_trading_partners
   where partner_type=4
   and partner_id=arg_carrier_id;

   return carrier_name;
END carrier;
END Msc_GET_name;

/
