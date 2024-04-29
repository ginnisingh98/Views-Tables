--------------------------------------------------------
--  DDL for Package Body CTO_WORKBENCH_UTIL_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_WORKBENCH_UTIL_PK" as
/* $Header: CTOWBUTB.pls 120.11.12010000.4 2010/07/21 07:55:31 abhissri ship $ */
/********************************************************************************************************
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA                                      |
|                         All rights reserved,                                                          |
|                         Oracle Manufacturing                                                          |
|   File Name           : CTOWBUTB.pls                                                                |
|                                                                                                       |
|   Description         :  This is the Utility pkg for CTO workbench. CTO work bench is the             |
|                          Self service application and we need lot of funtions to call in the sql      |
|                          This file is not having any other product dependency.                        |
|   History             : Created on 11-NOV-2002 by Renga Kannan                                        |
|
|
|                         28-Jan-2003    Renga Kannan
|                                        Modified the code for numeric value error.
|                         30-Jun-2005    Renga Kannan
|                                        Modified code for Cross docking project.
********************************************************************************************************/


FUNCTION get_line_number
					    (
                                            p_ato_line_id    IN Number,
                                            p_line_id        IN NUMBER,
                                            p_item_type_code IN VARCHAR2,
					    p_Line_Number      IN NUMBER,
					    p_Shipment_Number  IN NUMBER,
					    p_Option_Number    IN NUMBER,
					    p_Component_Number IN NUMBER ,
					    p_Service_Number   IN NUMBER
					    ) Return varchar2 IS
l_concat_value   Varchar2(100);
line_number      oe_order_lines_all.line_number%type;
shipment_number  oe_order_lines_all.shipment_number%type;
option_number    oe_order_lines_all.option_number%type;
component_number oe_order_lines_all.component_number%type;
service_number  oe_order_lines_all.service_number%type;

BEGIN

    If p_ato_line_id = p_line_id and p_item_type_code in ('MODEL','CLASS') then

      BEGIN -- fp-J : added BEGIN/END block
      Select Line_number,
             shipment_number,
             option_number,
             Component_number,
             Service_number
      into   line_number,
             shipment_number,
             option_number,
             component_number,
             service_number
      from   oe_order_lines_all
      where  ato_line_id = p_ato_line_id
      and    item_type_code = 'CONFIG';

      EXCEPTION		--- fp-J: added EXCEPTION block
      when no_data_found then    	-- if config does not exist.
         line_number       := p_line_number;
         shipment_number   := p_shipment_number;
         option_number     := p_option_number;
         component_number  := p_component_number;
         service_number    := p_service_number;
      END;

    else

      line_number       := p_line_number;
      shipment_number   := p_shipment_number;
      option_number     := p_option_number;
      component_number  := p_component_number;
      service_number    := p_service_number;

    end if;

    return get_order_line_number(p_line_number      =>line_number,
                                 p_service_number   => service_number,
                                 p_option_number    => option_number,
				 p_component_number => component_number,
				 p_shipment_number  => shipment_number);

end get_line_number;


--Modified by Renga Kannan on 02/12/03. Calling OM API to get the flow status. We have dependency
-- With  OM for this and OM gave a pre-req ARU on this. The Prereq ARU no is 2748513

FUNCTION get_line_status (
                           p_Line_Id         IN   NUMBER,
                           p_Ato_Line_Id     IN   NUMBER,
                           p_Item_Type_code  IN   Varchar2,
                           p_flow_status     IN   Varchar2) Return Varchar2 is
       l_flow_status      Varchar2(100):=null;
       l_line_id          oe_order_lines_all.line_id%type;
       l_flow_status_code oe_order_lines_all.flow_status_code%type;
Begin

        l_flow_status := p_flow_status;
        if (p_Line_id = p_ato_line_id and p_item_type_code in ('MODEL', 'CLASS')) then

           select line_id,
                  flow_status_code
           into   l_line_id,
                  l_flow_status_code
           from  oe_order_lines_all oel
           where oel.ato_line_id = p_ato_line_id
           and   oel.item_type_code = 'CONFIG';
         else

           l_line_id := p_line_id;
           l_flow_status_code := p_flow_status;
         end if;
           l_flow_status := oe_line_status_pub.get_line_status(p_line_id => l_line_id,
                                                               p_flow_status_code => l_flow_status_code);
        return l_flow_status;
End Get_line_status;


Function Get_supply_type (P_line_id       IN Number,
                          p_ato_line_id   IN Number,
	                  p_item_type     IN Varchar2,
			  p_source_type   IN Varchar2) return Varchar2 is
    l_demand_line_id   	Number;
    l_source_type_id   	Number;
    l_supply_type 	Number := 0;
    l_source_document_type_id	Number;
    v_wip_quantity	Number;
    v_flow_count	Number;
    v_po_quantity	Number;
    v_req_quantity	Number;
    v_ireq_quantity	Number;
    v_ds_po_quantity	Number;
    v_ds_req_quantity	Number;
    v_asn_quantity      Number;
    l_result		Number;
    x_result		Varchar2(200);


Begin

  --
  -- Get demand line
  --
  If (p_ato_line_id is not null) then

    --Adding INCLUDED item type code for SUN ER#9793792
    --if (p_item_type in ('OPTION','STANDARD')) then
    if (p_item_type in ('OPTION','STANDARD','INCLUDED')) then

      	l_demand_line_id := p_line_id;

    elsif (p_ato_line_id = p_line_id and p_item_type in ('MODEL', 'CLASS')) then

      	select line_id
      	into   l_demand_line_id
      	from   oe_order_lines_all
      	where  ato_line_id = p_ato_line_id
      	and    item_type_code = 'CONFIG';

    else
      	return null;
    end if;
  else
    	l_demand_line_id := p_line_id;
  end if;

  --
  -- Dropship line
  --
  IF nvl(p_source_type, 'INTERNAL') = 'EXTERNAL' THEN

	select count(*)
	into v_ds_po_quantity
	from oe_drop_ship_sources ods
	where ods.line_id = l_demand_line_id
	--and ods.drop_ship_source_id = 2
  	and ods.po_header_id is not null;

	IF (v_ds_po_quantity > 0) THEN
		l_result := 5;
	END IF;

	select count(*)
	into v_ds_req_quantity
	from oe_drop_ship_sources ods
	where ods.line_id = l_demand_line_id
	--and ods.drop_ship_source_id = 2
	and ods.po_header_id is null;

	IF (v_ds_req_quantity > 0) THEN
		IF (l_result <> 0) THEN
			l_result := 7;
			select meaning
			into x_result
			from mfg_lookups
			where lookup_type = 'CTO_WB_SUPPLY_TYPE'
			and lookup_code = l_result;

			return x_result;
		ELSE
			l_result := 6;
		END IF;
	END IF;

	select meaning
	into x_result
	from mfg_lookups
	where lookup_type = 'CTO_WB_SUPPLY_TYPE'
	and lookup_code = l_result;

  --
  -- Internal line
  --
  ELSE

  	--
  	-- Get source document id
  	--
  	l_source_document_type_id := CTO_WORKBENCH_UTIL_PK.get_source_document_id ( pLineId => l_demand_line_id );


	select nvl(sum(reservation_quantity),0)
        into v_wip_quantity
        from mtl_reservations
        where  demand_source_type_id = decode (l_source_document_type_id, 10,
						   inv_reservation_global.g_source_type_internal_ord,
						   inv_reservation_global.g_source_type_oe )
        and    demand_source_line_id = l_demand_line_id
        and    supply_source_type_id = inv_reservation_global.g_source_type_wip;

	IF (v_wip_quantity > 0) THEN
		l_result := 1;
     	END IF;

	select count(*)
        into v_flow_count
        from wip_flow_schedules
        where demand_source_type = inv_reservation_global.g_source_type_oe
        and   demand_source_line =to_char(l_demand_line_id)
        and   status = 1;

	IF (v_flow_count > 0) THEN
		IF (l_result <> 0) THEN
			l_result := 7;
			select meaning
			into x_result
			from mfg_lookups
			where lookup_type = 'CTO_WB_SUPPLY_TYPE'
			and lookup_code = l_result;

			return x_result;
		ELSE
			l_result := 2;
		END IF;
	END IF;

	select nvl(sum(reservation_quantity),0)
        into   v_po_quantity
        from   mtl_reservations
        where  demand_source_type_id = decode (l_source_document_type_id,
                                    		10, inv_reservation_global.g_source_type_internal_ord,
         					    inv_reservation_global.g_source_type_oe )
        and    demand_source_line_id = l_demand_line_id
        and    supply_source_type_id = inv_reservation_global.g_source_type_po;

	IF (v_po_quantity > 0) THEN
		IF (l_result <> 0) THEN
			l_result := 7;
			select meaning
			into x_result
			from mfg_lookups
			where lookup_type = 'CTO_WB_SUPPLY_TYPE'
			and lookup_code = l_result;

			return x_result;
		ELSE
			l_result := 3;
		END IF;
	END IF;

	select nvl(sum(reservation_quantity), 0)
           into   v_req_quantity
           from   mtl_reservations
           where  demand_source_type_id = decode (l_source_document_type_id,
                                                  10, inv_reservation_global.g_source_type_internal_ord,
         		   		          inv_reservation_global.g_source_type_oe )
           and    demand_source_line_id = l_demand_line_id
           and    supply_source_type_id = inv_reservation_global.g_source_type_req;

	IF (v_req_quantity > 0) THEN
		IF (l_result <> 0) THEN
			l_result := 7;
			select meaning
			into x_result
			from mfg_lookups
			where lookup_type = 'CTO_WB_SUPPLY_TYPE'
			and lookup_code = l_result;

			return x_result;
		ELSE
			l_result := 4;
		END IF;
	END IF;

        -- rkaza. 05/19/2005. ireq project.
	select nvl(sum(reservation_quantity), 0)
           into   v_ireq_quantity
           from   mtl_reservations
           where  demand_source_type_id = decode (l_source_document_type_id,
                                                  10, inv_reservation_global.g_source_type_internal_ord,
         		   		          inv_reservation_global.g_source_type_oe )
           and    demand_source_line_id = l_demand_line_id
           and    supply_source_type_id = inv_reservation_global.g_source_type_internal_req;

	IF (v_ireq_quantity > 0) THEN
		IF (l_result <> 0) THEN
			l_result := 7;
			select meaning
			into x_result
			from mfg_lookups
			where lookup_type = 'CTO_WB_SUPPLY_TYPE'
			and lookup_code = l_result;

			return x_result;
		ELSE
			l_result := 8; -- IR
		END IF;
	END IF;
        -- Added by Renga Kannan on 30-Jun-2005 for Cross docking project

	select nvl(sum(reservation_quantity), 0)
           into   v_asn_quantity
           from   mtl_reservations
           where  demand_source_type_id = decode (l_source_document_type_id,
                                                  10, inv_reservation_global.g_source_type_internal_ord,
         		   		          inv_reservation_global.g_source_type_oe )
           and    demand_source_line_id = l_demand_line_id
           and    supply_source_type_id = inv_reservation_global.g_source_type_asn;

	IF (v_asn_quantity > 0) THEN
		IF (l_result <> 0) THEN
			l_result := 7;
			select meaning
			into x_result
			from mfg_lookups
			where lookup_type = 'CTO_WB_SUPPLY_TYPE'
			and lookup_code = l_result;

			return x_result;
		ELSE
			l_result := 9; -- ASN
		END IF;
	END IF;

	select meaning
	into x_result
	from mfg_lookups
	where lookup_type = 'CTO_WB_SUPPLY_TYPE'
	and lookup_code = l_result;

   END IF; /* internal source type */

   return x_result;

End Get_supply_type;


Function Get_config_line_id (P_ato_line_id IN Number,
                            p_line_id      IN Number,
                            p_item_type    IN Varchar2) return number as

l_config_line_id	oe_order_lines_all.line_id%type;

Begin
    l_config_line_id := p_line_id;

    if p_ato_line_id = p_line_id  and p_item_type in ('MODEL', 'CLASS') then

       if config_line_id_tbl.exists(p_ato_line_id) then
          l_config_line_id := config_line_id_tbl(p_ato_line_id);
       else

          select line_id into   l_config_line_id
          from   oe_order_lines_all
          where  ato_line_id = p_ato_line_id
          and    item_type_code = 'CONFIG';

          config_line_id_tbl(p_ato_line_id) := l_config_line_id;

      end if;

    end if;

    return l_config_line_id;

Exception When Others then
   return p_line_id;

End Get_Config_Line_id;


Function Get_Item_Name (P_ato_line_id  IN Number,
                        p_line_id      IN Number,
                        p_item_type    IN Varchar2,
                        p_item_name    IN Varchar2,
                        p_config_item  IN Number,
                        p_ship_org_id  IN Number) return Varchar2 as
    l_item_name  varchar2(1000);
Begin
    l_item_name := p_item_name;
    If p_ato_line_id is not null and  p_config_item is not null and p_item_type in ('MODEL','CLASS') then
          -- Fixed bug 5447062
      -- replaced org condition with rownum

      select concatenated_segments
      into   l_item_name
      from   mtl_system_items_kfv
      where  inventory_item_id = p_config_item
      and    rownum =1;

    elsif p_ato_line_id is not null and p_config_item is null and p_item_type in ('MODEL','CLASS') then

      select concatenated_segments
      into  l_item_name
      from  mtl_system_items_kfv mtl,
            oe_order_lines_all oel
      where oel.ato_line_id = p_ato_line_id
      and   oel.item_type_code = 'CONFIG'
      and   oel.inventory_item_id = mtl.inventory_item_id
      and   mtl.organization_id = p_ship_org_id;

    end if;

    return l_item_name;
End Get_item_name;


Function Get_Item_Desc (P_ato_line_id  IN Number,
                        p_line_id      IN Number,
                        p_item_type    IN Varchar2,
                        p_item_desc    IN Varchar2,
                        p_config_item  IN Number,
                        p_ship_org_id  IN Number) return Varchar2 as
    l_item_desc  mtl_system_items_kfv.description%type;
Begin

    -- Commenting as part of bugfix 8453372
    -- l_item_desc := p_item_desc;

    If p_ato_line_id is not null and  p_config_item is not null and p_item_type in ('MODEL','CLASS') then

      -- Changed this sql as part of bugfix 8453372. The sql now picks up data from tl table.
      -- Fixed bug 5447062
      -- replaced org condition with rownum
      /*select description
      into   l_item_desc
      from   mtl_system_items_kfv
      where  inventory_item_id = p_config_item
      and    rownum = 1;*/

      select description
      into   l_item_desc
      from   mtl_system_items_tl
      where  inventory_item_id = p_config_item
      and    language          = userenv('LANG')
      and    rownum            = 1;

    elsif p_ato_line_id is not null and p_config_item is null and p_item_type in ('MODEL','CLASS') then

      -- Changed this sql as part of bugfix 8453372. The sql now picks up data from tl table.
      /*select description
      into   l_item_desc
      from   mtl_system_items_kfv mtl,
             oe_order_lines_all oel
      where  mtl.inventory_item_id = oel.inventory_item_id
      and    mtl.organization_id   = p_ship_org_id
      and    oel.ato_line_id = p_ato_line_id
      and    oel.item_type_code = 'CONFIG';*/

      select description
      into   l_item_desc
      from   mtl_system_items_tl mtl,
             oe_order_lines_all oel
      where  mtl.inventory_item_id = oel.inventory_item_id
      and    mtl.organization_id   = p_ship_org_id
      and    mtl.language          = userenv('LANG')
      and    oel.ato_line_id       = p_ato_line_id
      and    oel.item_type_code    = 'CONFIG';

    -- Added this condition for ATO Item ordered independently. Done as part of bugfix 8453372.
    --elsif p_ato_line_id is not null and p_item_type in ('STANDARD', 'OPTION') then
    --Adding INCLUDED item type code for SUN ER#9793792
    elsif p_ato_line_id is not null and p_item_type in ('STANDARD', 'OPTION', 'INCLUDED') then
      select description
      into   l_item_desc
      from   mtl_system_items_tl mtl,
             oe_order_lines_all oel
      where  mtl.inventory_item_id = oel.inventory_item_id
      and    mtl.organization_id   = p_ship_org_id
      and    oel.ato_line_id       = p_ato_line_id
      and    mtl.language          = userenv('LANG');

    end if;

    return l_item_desc;
End Get_item_desc;


 FUNCTION get_source_document_id (pLineId in number) RETURN NUMBER
 IS
	  l_source_document_type_id  number;
 BEGIN

	  select h.source_document_type_id
	  into   l_source_document_type_id
	  from   oe_order_headers_all h, oe_order_lines_all l
	  where  h.header_id =  l.header_id
	  and    l.line_id = pLineId
	  and    rownum = 1;

	  return (l_source_document_type_id);

 END get_source_document_id;


 FUNCTION convert_uom(from_uom IN VARCHAR2,
                       to_uom  IN VARCHAR2,
                     quantity  IN NUMBER,
                      item_id  IN NUMBER )
 RETURN NUMBER
 IS
  this_item     NUMBER;
  to_rate       NUMBER;
  from_rate     NUMBER;
  result        NUMBER;

 BEGIN
  IF from_uom = to_uom THEN
     result := quantity;
  ELSIF    from_uom IS NULL
        OR to_uom   IS NULL THEN
     result := 0;
  ELSE
     result := INV_CONVERT.inv_um_convert(item_id,
                                  	  5,
                                          quantity,
                                          from_uom,
                                          to_uom,
                                          NULL,
                                          NULL);

     if result = -99999 then
        result := 0;
     end if;
  END IF;
  RETURN result;

 END convert_uom;

FUNCTION Get_Buyer_Name (P_suggested_buyer_id  IN Varchar2)
RETURN Varchar2 IS

l_buyer_name Varchar2(2000);

BEGIN

	l_buyer_name := null;

      	select full_name
      	into   l_buyer_name
      	from   per_people_f
      	where  person_id = P_suggested_buyer_id;

	return l_buyer_name;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		return l_buyer_name;

	WHEN OTHERS THEN
		return l_buyer_name;

END Get_Buyer_Name;

/* fp-J project: Added a new function Get_Workbench_Item_Type */

FUNCTION Get_WorkBench_Item_Type
	( p_header_id         IN  NUMBER
 	,p_top_model_line_id  IN  NUMBER
 	,p_ato_line_id        IN  NUMBER
 	,p_line_id            IN  NUMBER
 	,p_item_type_code     IN  VARCHAR2
	) RETURN varchar2
IS
  x_wb_item_type  	VARCHAR2(20) := null;
BEGIN


  IF p_header_id is not null AND
     p_line_id is null THEN

     x_wb_item_type := 'HEAD';

  ElSIF p_top_model_line_id is not null AND
        p_ato_line_id is null AND
        p_item_type_code = 'MODEL' THEN

    x_wb_item_type := 'PTO';

  ElSIF p_ato_line_id = p_line_id AND
        (p_item_type_code = 'MODEL' OR
         p_item_type_code = 'CLASS') THEN

    x_wb_item_type := 'MDL';

  ELSE

     IF p_ato_line_id = p_line_id AND
        (p_item_type_code = 'STANDARD' OR
         --Adding INCLUDED item type code for SUN ER#9793792
	 p_item_type_code = 'OPTION' OR
	 p_item_type_code = 'INCLUDED') THEN

       x_wb_item_type := 'ATO';

     ELSIF p_item_type_code = 'CONFIG' THEN

       x_wb_item_type := 'CFG';

     ELSE

       x_wb_item_type := 'STD';

     END IF;

  END IF;

  RETURN x_wb_item_type;

END Get_WorkBench_Item_Type;

FUNCTION Get_Rsvd_on_hand_qty(
                              p_line_id        IN Number,
			      p_ato_line_id    IN Number,
			      p_item_type_code IN varchar2) RETURN Number is
   l_prim_rsv_qty     Number;
   l_rsv_qty          Number;
   l_prim_uom_code    mtl_reservations.primary_uom_code%type;
   l_line_id          Number;

Begin
      -- -- Fixed bug 5199341
      -- Added code to derive the config line id incase of ato model order lines
      If p_ato_line_id is not null then
         if p_ato_line_id = p_line_id and p_item_type_code in ('MODEL','CLASS') then
            select line_id
	    into   l_line_id
	    from   oe_order_lines_all
	    where  ato_line_id = p_ato_line_id
	    and    item_type_code = 'CONFIG';
	  End if;
      end if;
      If l_line_id is null then
         l_line_id := p_line_id;
      End if;

      select sum(primary_reservation_quantity),primary_uom_code
      into   l_prim_rsv_qty, l_prim_uom_code
      from   mtl_reservations
      where  demand_source_line_id  = l_line_id
      and    supply_source_TYpe_id  = 13
      group by primary_uom_code;

      If l_prim_rsv_qty <> 0 then
      select CTO_WORKBENCH_UTIL_PK.convert_uom(l_prim_uom_code,
                                               oel.order_quantity_uom,
                                               nvl(l_prim_rsv_qty,0),
                                               oel.inventory_item_id)
      into l_rsv_qty
      from oe_order_lines_all oel
      where oel.line_id = l_line_id;
      else
         l_rsv_qty := 0;
      End if;
      return l_rsv_qty;
Exception when no_data_found then --4752854,code review bug
				  --return 0 when no on-hand qty
      return 0;
End Get_Rsvd_on_hand_qty;



FUNCTION get_last_available_date(p_ato_line_id IN number,
                                 p_line_id IN Number,
                                 p_item_type IN varchar2) RETURN date is

l_date     date := null;
l_config_line_id number;
l_line_level varchar2(10);
l_return_status varchar2(20);

Begin

find_config_line_and_level(p_ato_line_id => p_ato_line_id,
                           p_line_id => p_line_id,
                           p_item_type => p_item_type,
                           x_config_line_id => l_config_line_id,
                           x_line_level => l_line_level,
                           x_return_status => l_return_status);

-- no config line id, return null.
if l_return_status in (fnd_api.g_ret_sts_error,
                       fnd_api.g_ret_sts_unexp_error) then
   return null;
end if;

-- No need to process for lower level items.
if l_line_level = 'Lower' then
   return null;
end if;

-- process for Top, Ato, Std items.
--
-- bug 6833994
-- Added a to_char() clause on the l_config_line_id
-- while querying from wip_flow_schedules
-- ntungare
--
Select max(exp_comp_date) into l_date
from
   (SELECT wdj.scheduled_completion_date exp_comp_date
    FROM mtl_reservations mr, wip_discrete_jobs wdj
    WHERE mr.demand_source_type_id = decode(CTO_WORKBENCH_UTIL_PK.get_source_document_id(l_config_line_id), 10,8,2)
    AND mr.demand_source_line_id = l_config_line_id
    AND mr.supply_source_type_id = 5
    AND wdj.wip_entity_id = mr.supply_source_header_id
    AND wdj.organization_id = mr.organization_id

    UNION

    SELECT wfs.scheduled_completion_date exp_comp_date
    FROM wip_flow_schedules wfs
    WHERE wfs.demand_source_line = to_char(l_config_line_id)
    AND wfs.status = 1

    UNION

    select nvl(poll.promised_date,poll.need_by_date) exp_comp_date
    from mtl_reservations mr, po_line_locations_all poll
    where mr.demand_source_type_id =  2
    and mr.demand_source_line_id = l_config_line_id
    and mr.supply_source_type_id =  1
    and mr.supply_source_header_id = poll.po_header_id
    and mr.supply_source_line_id = poll.line_location_id

    UNION

    select porl.need_by_date exp_comp_date
    from mtl_reservations mr, po_requisition_lines_all porl
    where mr.demand_source_type_id = 2
    and mr.demand_source_line_id = l_config_line_id
    and mr.supply_source_type_id in (7, 17)
    and mr.supply_source_header_id = porl.requisition_header_id
    and mr.supply_source_line_id = porl.requisition_line_id

    UNION

    select nvl(poll.promised_date,poll.need_by_date) exp_comp_date
    from oe_drop_ship_sources ods, po_line_locations_all poll
    where ods.line_id = l_config_line_id
    and ods.po_header_id = poll.po_header_id
    and ods.line_location_id = poll.line_location_id

    UNION

    select porl.need_by_date exp_comp_date
    from oe_drop_ship_sources ods, po_requisition_lines_all porl
    where ods.line_id = l_config_line_id
    and ods.po_header_id is null
    and ods.requisition_header_id = porl.requisition_header_id
    and ods.requisition_line_id = porl.requisition_line_id

    UNION

    select asn_headers.expected_receipt_date exp_comp_date
    from mtl_reservations mr,
         rcv_shipment_lines ASN_LINES,
         rcv_shipment_headers asn_headers
    where mr.demand_source_type_id = 2
    and mr.demand_source_line_id = l_config_line_id
    and mr.supply_source_type_id = 25
    and mr.supply_source_line_detail = ASN_LINES.shipment_line_id
    and asn_headers.shipment_header_id = asn_lines.shipment_header_id
    and ASN_LINES.asn_line_flag = 'Y');

return l_date;

Exception

When Others then
return null;

End get_last_available_date;


/*******************************************************************************************
-- API name : get_rsvd_inrcv_qty
-- Type     : Public
-- Pre-reqs : INVRSVGS.pls
-- Function : Given config/ato item line id  it returns
--            the qty reserved to in receiving supply
-- Parameters:
-- IN       : p_line_id           Expects the config/ato item order line id       Required
--
-- Version  :
--
--
******************************************************************************************/


FUNCTION Get_Rsvd_inrcv_qty(
                              p_line_id        IN Number,
			      p_ato_line_id    IN Number,
			      p_item_type_code IN varchar2) RETURN Number is
   l_prim_rsv_qty     Number;
   l_rsv_qty          Number;
   l_prim_uom_code    mtl_reservations.primary_uom_code%type;
   l_line_id          Number;

Begin

      -- -- Fixed bug 5199341
      -- Added code to derive the config line id incase of ato model order lines

      If p_ato_line_id is not null then
         if p_ato_line_id = p_line_id and p_item_type_code in ('MODEL','CLASS') then
            select line_id
	    into   l_line_id
	    from   oe_order_lines_all
	    where  ato_line_id = p_ato_line_id
	    and    item_type_code = 'CONFIG';
	  End if;
      end if;
      If l_line_id is null then
         l_line_id := p_line_id;
      End if;

      select sum(primary_reservation_quantity),primary_uom_code
      into   l_prim_rsv_qty, l_prim_uom_code
      from   mtl_reservations
      where  demand_source_line_id  = l_line_id
      and    supply_source_TYpe_id  = 27
      group by primary_uom_code;

      If l_prim_rsv_qty <> 0 then
      select CTO_WORKBENCH_UTIL_PK.convert_uom(l_prim_uom_code,
                                               oel.order_quantity_uom,
                                               nvl(l_prim_rsv_qty,0),
                                               oel.inventory_item_id)
      into l_rsv_qty
      from oe_order_lines_all oel
      where oel.line_id = l_line_id;
      else
         l_rsv_qty := 0;
      End if;
      return l_rsv_qty;
Exception when no_data_found then
      return 0;
End Get_Rsvd_inrcv_qty;



Procedure find_config_line_and_level(P_ato_line_id IN Number,
                                    p_line_id      IN Number,
                                    p_item_type    IN Varchar2,
                                    x_config_line_id OUT NOCOPY number,
                                    x_line_level OUT NOCOPY varchar2,
                                    x_return_status OUT NOCOPY varchar2) IS

Begin

x_return_status := fnd_api.g_ret_sts_success;

-- Std item
If p_ato_line_id is null then
   x_config_line_id := p_line_id;
   x_line_level := 'Std';
   return;
end if;

-- Lower level. p_ato_line_id not null
if p_ato_line_id <> p_line_id then
   x_config_line_id := p_line_id;
   x_line_level := 'Lower';
   return;
end if;

-- Top level or Ato case. p_ato_line_id not null and equal to p_line_id
if p_item_type in ('MODEL', 'CLASS') then

   if config_line_id_tbl.exists(p_ato_line_id) then
      x_config_line_id := config_line_id_tbl(p_ato_line_id);
   else
      select line_id into x_config_line_id
      from   oe_order_lines_all
      where  ato_line_id = p_ato_line_id
      and    item_type_code = 'CONFIG';

      config_line_id_tbl(p_ato_line_id) := x_config_line_id;
   end if;

   x_line_level := 'Top';

else -- Ato item

   x_config_line_id := p_line_id;
   x_line_level := 'Ato';

end if; -- if item_type in (model, class)

Exception

when FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_config_line_id := null;
   x_line_level := null;

when FND_API.G_EXC_UNEXPECTED_ERROR then
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_config_line_id := null;
   x_line_level := null;

when others then
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_config_line_id := null;
   x_line_level := null;

End find_config_line_and_level;


/* Added by Renga Kannan for bug 5348842 */

Function get_order_line_number(p_line_number       Number,
                                p_service_number    Number,
                                p_option_number     Number,
				p_component_number  Number,
				p_shipment_number   Number) return varchar2 is
l_concat_value   Varchar2(100);
Begin
 --=========================================
    -- Added for identifying Service Lines
    --=========================================
    IF P_service_number is not null then
	 IF p_option_number is not null then
	   IF p_component_number is not null then
	     l_concat_value := p_line_number||'.'||p_shipment_number||'.'||
					   p_option_number||'.'||p_component_number||'.'||
					   p_service_number;
        ELSE
	     l_concat_value := p_line_number||'.'||p_shipment_number||'.'||
					   p_option_number||'..'||p_service_number;
        END IF;

      --- if a option is not attached
      ELSE
	   IF p_component_number is not null then
	     l_concat_value := p_line_number||'.'||p_shipment_number||'..'||
					   p_component_number||'.'||p_service_number;
        ELSE
	     l_concat_value := p_line_number||'.'||p_shipment_number||
					   '...'||p_service_number;
        END IF;

	 END IF; /* if option number is not null */

    -- if the service number is null
    ELSE
	 IF p_option_number is not null then
	   IF p_component_number is not null then
	     l_concat_value := p_line_number||'.'||p_shipment_number||'.'||
					   p_option_number||'.'||p_component_number;
        ELSE
	     l_concat_value := p_line_number||'.'||p_shipment_number||'.'||
					   p_option_number;
        END IF;

      --- if a option is not attached
      ELSE
	   IF p_component_number is not null then
	     l_concat_value := p_line_number||'.'||p_shipment_number||'..'||
					   p_component_number;
        ELSE
	     l_concat_value := p_line_number||'.'||p_shipment_number;
        END IF;

	 END IF; /* if option number is not null */

    END IF; /* if service number is not null */
    return l_concat_value;
End Get_order_line_number;
End CTO_WORKBENCH_UTIL_PK;

/
