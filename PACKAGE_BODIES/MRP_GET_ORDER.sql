--------------------------------------------------------
--  DDL for Package Body MRP_GET_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_GET_ORDER" AS
/* $Header: MRPXORDB.pls 115.1 99/07/16 12:43:40 porting ship $ */


FUNCTION supply_order (arg_order_type IN NUMBER,
			   arg_disp_id IN NUMBER,
			   arg_compile_desig IN VARCHAR2,
			   arg_org_id IN NUMBER,
			   arg_item_id IN NUMBER,
			   arg_by_prod_assy_id IN NUMBER DEFAULT NULL)
    return varchar2
IS

order_num      varchar2(240);
wip_ent_name   varchar2(240);

cursor C1 is
  select po_number
  from mrp_item_purchase_orders
  where transaction_id = arg_disp_id
  and compile_designator = arg_compile_desig
  and organization_id = arg_org_id
  and inventory_item_id = arg_item_id;

cursor C2 is
  select wip_entity_name
  from mrp_item_wip_entities
  where wip_entity_id = arg_disp_id
  and compile_designator = arg_compile_desig
  and organization_id = arg_org_id
  and inventory_item_id = arg_item_id;

cursor C3 is
  select wip_entity_name
  from mrp_item_wip_entities
  where wip_entity_id = arg_disp_id
  and compile_designator = arg_compile_desig
  and organization_id = arg_org_id
  and inventory_item_id = arg_by_prod_assy_id;

BEGIN

if (arg_order_type is NULL)  THEN
  return NULL;
END IF;

if (arg_order_type in (1, 2, 8, 11, 12)) then

   if (arg_disp_id is NULL) then
	 return NULL;
   end if;


   OPEN C1;
   LOOP
      FETCH C1 INTO order_num;
   EXIT;
   END LOOP;

   return (order_num);

end if;

if (arg_order_type in (3, 7, 18)) then

   if (arg_disp_id is NULL) then
	  return NULL;
   end if;

   OPEN C2;
   LOOP
	  FETCH C2 into wip_ent_name;
	  EXIT;
   END LOOP;

   return (wip_ent_name);

end if;

if (arg_order_type in (14, 15)) then

  if (arg_disp_id is NULL) then
	 return NULL;
  end if;

  OPEN C3;
  LOOP
	 FETCH C3 into wip_ent_name;
	 EXIT;
  END LOOP;

  return (wip_ent_name);

end if;

return NULL;

END SUPPLY_ORDER;


FUNCTION sales_order (arg_demand_id IN NUMBER)
    return varchar2
IS

order_number      varchar2(240);

cursor C4 is
  select so.segment1||':'||so.segment2||':'||so.segment3
  from
        mtl_sales_orders so, mrp_schedule_dates msd
  where
        msd.mps_transaction_id = arg_demand_id
        and msd.schedule_level =3
        and so.sales_order_id = msd.source_sales_order_id;
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

END MRP_GET_ORDER;

/
