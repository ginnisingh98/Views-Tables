--------------------------------------------------------
--  DDL for Package Body CTO_FLOW_SCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_FLOW_SCHEDULE" as
/* $Header: CTOFLSCB.pls 120.3 2006/06/26 23:02:23 rekannan noship $ */
/*----------------------------------------------------------------------------+
|  Copyright (c) 1998 Oracle Corporation    Belmont, California, USA          |
|                     All rights reserved.                                    |
|                     Oracle Manufacturing                                    |
+-----------------------------------------------------------------------------+
|
| FILE NAME   :
| DESCRIPTION :
|               This file creates a packaged Procedures which create
|               flow schedules  for ATO items/ configured items.
|               To remain a 'noship' file till further decision
|
| HISTORY     : June 30, 1999    Initial Version     Angela Makalintal
|
|		DEc 12, 2002	Kiran Konada
|				Added code for ML supply enchancement
|		Feb 18,2002     Kiran Konada
|				bugfix 2803881
|				user_id (cetaed by) is passed
|				to create_subassembly_jobs program
|
|               June 1 , 2005    Added Nocopy Hint   Renga  Kannan
|
|               Mar 07, 2005	Kiran Konada
|                               performance bugfix 4905864
|                               removed dependency on mrp_unscheduled_orders_v
|
*============================================================================*/
PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);

PROCEDURE cto_fs(
   p_config_line_id        in         varchar2,
   x_return_status         out NoCopy varchar2,
   x_msg_name              out NoCopy varchar2,
   x_msg_txt               out NoCopy varchar2 )
IS
   l_stmt_num                number := 0;
   l_line_id                 number;
   l_mfg_org_id              number;
   l_x_wip_entity_id         number;
   l_x_org_id                number;
   l_x_return_status         varchar2(1);
   l_x_msg_count             number;
   l_x_msg_data              varchar2(240);

   l_return_status       varchar2(1);

    --ml supply var's
   l_mlsupply_parameter  number  := 1; --may need to chnage later 1 =auto-created , 2 =a toiutem and autocreated
   l_created_by   number := null ;  --bugfix 2803881
   l_error_message      varchar2(70) := null;
   l_message_name        varchar2(30) := null;

   CREATE_FLOW_SCHED_ERROR   exception;
   SCHEDULE_FLOW_SCHED_ERROR exception;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_stmt_num := 100;
   cto_create_fs(p_config_line_id,
                 l_x_wip_entity_id,
                 l_x_return_status,
                 l_x_msg_count,
                 l_x_msg_data,
                 x_msg_name);

   if (l_x_return_status =  FND_API.G_RET_STS_ERROR) then
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('cto_fs: ' || 'Expected error in cto_create_fs.', 1);
       END IF;
       raise FND_API.G_EXC_ERROR;

   elsif (l_x_return_status =  FND_API.G_RET_STS_UNEXP_ERROR) then
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('cto_fs: ' || 'UnExpected error in cto_create_fs.', 1);
       END IF;
       raise FND_API.G_EXC_UNEXPECTED_ERROR;

   end if;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('cto_fs: ' || 'Success in cto_create_fs.', 1);
   END IF;

   l_stmt_num := 110;
   cto_schedule_fs (p_config_line_id,
                    l_x_wip_entity_id,
                    l_x_return_status,
                    l_x_msg_count,
                    l_x_msg_data,
                    x_msg_name);

   if (l_x_return_status =  FND_API.G_RET_STS_ERROR) then
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('cto_fs: ' || 'Expected error in cto_schedule_fs.', 1);
       END IF;
       raise FND_API.G_EXC_ERROR;

   elsif (l_x_return_status =  FND_API.G_RET_STS_UNEXP_ERROR) then
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('cto_fs: ' || 'UnExpected error in cto_schedule_fs.', 1);
       END IF;
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;


    --looking for ML supply org parameter value
	    --change the if clause after sajani changes her code
	    SELECT  ENABLE_LOWER_LEVEL_SUPPLY,oel.created_by
	    INTO l_mlsupply_parameter,l_created_by --bugfix 2803881
	    FROM bom_parameters bp,
	         oe_order_lines_all oel
	    WHERE oel.line_id = p_config_line_id
	    AND   oel.ship_from_org_id 	= bp.organization_id;

   --ml supply code

   IF (l_mlsupply_parameter in (2,3)) THEN    --auto created config =2, auto created configs + ato items = 3

			oe_debug_pub.add ('cto_fs: ' || 'before calling create sub-assembly jobs',1);

			l_stmt_num := 111;
			CTO_SUBASSEMBLY_SUP_PK.create_subassembly_jobs(
			l_mlsupply_parameter,
			p_config_line_id,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			l_created_by,--bugfix 2803881
			null,
		        l_return_status,
			l_error_message,
			l_message_name
			);


			IF l_return_status = FND_API.G_RET_STS_ERROR THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add ('cto_fs: ' || 'failed after CTO_SUBASSEMBLY_SUP_PK.create_subassembly_jobs ' || l_return_status ,1);
					oe_debug_pub.add ('cto_fs: ' || 'error message' || l_error_message ,1);
				END IF;
				RAISE FND_API.G_EXC_ERROR;
		       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add ('cto_fs: ' || ' failed after CTO_SUBASSEMBLY_SUP_PK.create_subassembly_jobs' || l_return_status ,1);
					oe_debug_pub.add ('cto_fs: ' || 'error message' || l_error_message ,1);
				END IF;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	               ELSE
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add('cto_fs: ' || 'success from CTO_SUBASSEMBLY_SUP_PK.create_subassembly_jobs' ,1);
					oe_debug_pub.add('cto_fs: ' || l_error_message ,1);

				END IF;
	               END IF;



   END IF; --l_mlsupply_parameter





   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('cto_fs: ' || 'Success in cto_schedule_fs.', 1);

   	oe_debug_pub.add('cto_fs: ' || 'Msg Data:' || l_x_msg_data, 1);
   END IF;

EXCEPTION

   when FND_API.G_EXC_ERROR then
       x_msg_txt := 'CTOFLSCB.cto_fs: raised expected error in stmt:' || to_char(l_stmt_num) || ':' ||
                     l_x_msg_data;
       if (x_msg_name is null) then
           x_msg_name := 'CTO_CREATE_FLOW_SCHED_ERROR';
       end if;
       x_return_status :=FND_API.G_RET_STS_ERROR;


   when FND_API.G_EXC_UNEXPECTED_ERROR then
       x_msg_txt := 'CTOFLSCB.cto_fs: raised Unexpected error in stmt:' || to_char(l_stmt_num) || ':' ||
                     l_x_msg_data;
       if (x_msg_name is null) then
           x_msg_name := 'CTO_CREATE_FLOW_SCHED_ERROR';
       end if;
       x_return_status :=FND_API.G_RET_STS_UNEXP_ERROR;
       raise;

   when OTHERS then
       x_msg_txt := 'CTOFLSCB.cto_fs: ' || to_char(l_stmt_num) || ':' ||
                     substrb(sqlerrm, 1, 100);
       if (x_msg_name is null) then
           x_msg_name := 'CTO_CREATE_FLOW_SCHED_ERROR';
       end if;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       raise;

END cto_fs;



PROCEDURE cto_create_fs (
   p_config_line_id     in         varchar2,
   x_wip_entity_id      out NoCopy number,
   x_return_status      out NoCopy varchar2,
   x_msg_count          out NoCopy number,
   x_msg_data           out NoCopy varchar2,
   x_msg_name           out NoCopy varchar2  )


IS

   l_flow_schedule_rec       mrp_flow_schedule_pub.flow_schedule_rec_type;
   l_x_flow_schedule_rec     mrp_flow_schedule_pub.flow_schedule_rec_type;
   l_x_flow_schedule_val_rec mrp_flow_schedule_pub.flow_schedule_val_rec_type;
   l_config_item_id          number;
   l_org_id                  number;
   l_return_status           varchar2(1);
   l_msg_count               number;
   l_msg_data                varchar2(240);
   l_stmt_num                number := 0;

   CREATE_FLOW_SCHED_ERROR   exception;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_stmt_num := 90;
  select inventory_item_id, ship_from_org_id
  into   l_config_item_id, l_org_id
  from   oe_order_lines_all oel
  where  oel.line_id = p_config_line_id;

  --perf bugfix 4905864 (high shared memory)sql id 14505192(drop4)
  --replacing mrp_unscheduled_orders_v with query on BOR,wip_line and oe_order_lines_all
  --Verified with Yun.lin

   l_stmt_num := 95;
  SELECT wl.LINE_ID
  INTO   l_flow_schedule_rec.line_id
  FROM BOM_OPERATIONAL_ROUTINGS BOR,
       wip_lines wl
  WHERE BOR.ASSEMBLY_ITEM_ID = l_config_item_id
  AND BOR.ORGANIZATION_ID = l_org_id
  AND BOR.CFM_ROUTING_FLAG = 1
  AND BOR.alternate_routing_designator IS NULL
  AND wl.line_id = bor.line_id
  AND wl.organization_id = bor.organization_id;

  l_stmt_num := 100;
  --get demand_source_header_id from mtl_sales order ,similar to mrp_unscheduled_orders_v
  --planned qty should be converted to primary uom as flow  honors only primary uom
  --planned qty conversion is done by same INV api being used in view mrp_unscheduled_orders_v
  --demand_source_type is 2 as in mrp_unscheduled_orders_v

  SELECT INV_SALESORDER.GET_SALESORDER_FOR_OEHEADER(HEADER_ID),
         line_id,
	 to_char(NULL),
	 2,
	 inventory_item_id,
	 INV_DECIMALS_PUB.GET_PRIMARY_QUANTITY(SHIP_FROM_ORG_ID ,INVENTORY_ITEM_ID,ORDER_QUANTITY_UOM ,ORDERED_QUANTITY),
	 ship_from_org_id,
	 project_id,
	 schedule_ship_date,
	 task_id
  INTO   l_flow_schedule_rec.demand_source_header_id,
         l_flow_schedule_rec.demand_source_line,
         l_flow_schedule_rec.demand_source_delivery,
         l_flow_schedule_rec.demand_source_type,
         l_flow_schedule_rec.primary_item_id,
         l_flow_schedule_rec.planned_quantity,
         l_flow_schedule_rec.organization_id,
         l_flow_schedule_rec.project_id,
         l_flow_schedule_rec.scheduled_completion_date,
         l_flow_schedule_rec.task_id
  FROM    oe_order_lines_all
  WHERE   line_id = p_config_line_id;



  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('cto_create_fs: ' || 'Header ID: ' ||
                    to_char(l_flow_schedule_rec.demand_source_header_id),2);

  	oe_debug_pub.add('cto_create_fs: ' || 'Demand Source Line ID: ' ||
                    l_flow_schedule_rec.demand_source_line,1);
  END IF;
--  oe_debug_pub.add('Demand Source Delivery: ' ||
--                    to_char(l_flow_schedule_rec.demand_source_delivery),1);
  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('cto_create_fs: ' || 'Demand Source Type: ' ||
                    to_char(l_flow_schedule_rec.demand_source_type),2);

  	oe_debug_pub.add('cto_create_fs: ' || 'Line ID: ' ||
                    to_char(l_flow_schedule_rec.line_id),2);

  	oe_debug_pub.add('cto_create_fs: ' || 'Organization ID: ' ||
                    to_char(l_flow_schedule_rec.organization_id),2);

  	oe_debug_pub.add('cto_create_fs: ' || 'Planed Quantity: ' ||
                    to_char(l_flow_schedule_rec.planned_quantity),2);

  	oe_debug_pub.add('cto_create_fs: ' || 'Primary Item ID: ' ||
                    to_char(l_flow_schedule_rec.primary_item_id),2);

  	oe_debug_pub.add('cto_create_fs: ' || 'Project ID: ' ||
                    to_char(l_flow_schedule_rec.project_id),2);

  	oe_debug_pub.add('cto_create_fs: ' || 'Schedule Completion Date: ' ||
                    to_char(l_flow_schedule_rec.scheduled_completion_date),2);

  	oe_debug_pub.add('cto_create_fs: ' || 'Task ID: ' ||
                    to_char(l_flow_schedule_rec.task_id),2);
  END IF;

  /** the following sql%rowcount does not make sense
      since the above select will raise no-data-found
      if no rows are selected.

  -- if (SQL%ROWCOUNT <= 0) then
  --    raise FND_API.G_EXC_ERROR;
  -- end if;

  ***/

  l_flow_schedule_rec.operation := MRP_GLOBALS.G_OPR_CREATE;
  l_flow_schedule_rec.scheduled_flag := 3;
  -- Fixed bug 5153755
  -- In R12, Flow team mandated the Calling APIs to ass the request id
  -- It is mandatroy field. As per Yun Lin, we are adding the following stmt
  l_flow_schedule_rec.request_id := USERENV('SESSIONID');



  l_stmt_num := 110;
  MRP_Flow_Schedule_PUB.Process_Flow_Schedule(
        p_api_version_number => 1.0,
        p_init_msg_list      => FND_API.G_TRUE,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data,
        p_flow_schedule_rec => l_flow_schedule_rec,
        x_flow_schedule_rec => l_x_flow_schedule_rec,
        x_flow_schedule_val_rec => l_x_flow_schedule_val_rec
    );


   if (x_return_status = FND_API.G_RET_STS_ERROR) then
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('cto_create_fs: ' || 'Expected error in Process Flow Schedule with status: ' || l_return_status, 1);
        END IF;
	raise FND_API.G_EXC_ERROR;

   elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('cto_create_fs: ' || 'UnExpected error in Process Flow Schedule with status: ' || l_return_status, 1);
        END IF;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;

   else
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('cto_create_fs: ' || 'Success in Process Flow Schedule.',1);
       END IF;
       if (l_x_flow_schedule_rec.wip_entity_id is not NULL) then
           x_wip_entity_id := l_x_flow_schedule_rec.wip_entity_id;
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('cto_create_fs: ' || 'WIP Entity ID: ' || to_char(x_wip_entity_id),2);
           END IF;
       end if;

   end if;   /* Create Flow Schedule Success */

EXCEPTION

    when FND_API.G_EXC_ERROR then

        x_msg_data := 'CTOFLSCB.cto_create_fs raised expected error: ' || to_char(l_stmt_num) || ':' || l_msg_data;
	x_msg_name := 'CTO_CREATE_FLOW_SCHED_ERROR';
        x_return_status := FND_API.G_RET_STS_ERROR;
	cto_msg_pub.cto_message('BOM', x_msg_name);
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('cto_create_fs: ' || x_msg_data,1);
        END IF;
	CTO_MSG_PUB.Count_And_Get
        	(p_msg_count => x_msg_count
        	,p_msg_data  => x_msg_data
        	);



    when FND_API.G_EXC_UNEXPECTED_ERROR then

        x_msg_data := 'CTOFLSCB.cto_create_fs raised unexp error: ' || to_char(l_stmt_num) || ':' || l_msg_data;
	x_msg_name := 'CTO_CREATE_FLOW_SCHED_ERROR';
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	cto_msg_pub.cto_message('BOM', x_msg_name);
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('cto_create_fs: ' || x_msg_data, 1);
        END IF;
	CTO_MSG_PUB.Count_And_Get
        	(p_msg_count => x_msg_count
        	,p_msg_data  => x_msg_data
        	);


    when NO_DATA_FOUND then
        x_msg_data := 'CTOFLSCB.cto_create_fs: raised no-data-found' || to_char(l_stmt_num);
	x_msg_name := 'CTO_CREATE_FLOW_SCHED_ERROR';
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	cto_msg_pub.cto_message('BOM', x_msg_name);
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('cto_create_fs: ' || x_msg_data,1);
        END IF;
	CTO_MSG_PUB.Count_And_Get
        	(p_msg_count => x_msg_count
        	,p_msg_data  => x_msg_data
        	);
	raise;


    when OTHERS then
        x_msg_data := 'CTOFLSCB.cto_create_fs: ' ||
                       to_char(l_stmt_num) || ':' ||
                       substrb(sqlerrm, 1, 100);
	x_msg_name := 'CTO_CREATE_FLOW_SCHED_ERROR';
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	cto_msg_pub.cto_message('BOM', x_msg_name);
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('cto_create_fs: ' || x_msg_data,1);
        END IF;
	CTO_MSG_PUB.Count_And_Get
        	(p_msg_count => x_msg_count
        	,p_msg_data  => x_msg_data
        	);
	raise;

END cto_create_fs;

PROCEDURE cto_schedule_fs (p_config_line_id IN         varchar2,
                           p_wip_entity_id  IN         NUMBER,
                           x_return_status  OUT NoCopy VARCHAR2,
                           x_msg_count      OUT NoCopy NUMBER,
                           x_msg_data       OUT NoCopy VARCHAR2,
                           x_msg_name       out NoCopy varchar2  )

IS

   l_stmt_num                NUMBER := 0;
   l_x_msg_count               NUMBER;
   l_x_msg_data              VARCHAR2(240);
   l_x_return_status         VARCHAR2(1);
   l_line_id                 NUMBER;
   l_org_id                  NUMBER;
   l_ship_date               DATE;
   l_rule_id                 NUMBER;
   l_planned_qty             NUMBER;
   l_config_item_id          NUMBER;
   l_completion_date     DATE;
   --SCHEDULE_FLOW_SCHED_ERROR exception;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_stmt_num := 100;
   -- Verify SQL.
   select wfs.line_id, wfs.organization_id, oel.schedule_ship_date,
          wfs.primary_item_id, wfs.planned_quantity
   into   l_line_id, l_org_id, l_ship_date, l_config_item_id, l_planned_qty
   from   wip_flow_schedules wfs,
          oe_order_lines_all oel
   where  oel.line_id = to_number(p_config_line_id)
   and    wfs.organization_id = oel.ship_from_org_id
   and    wfs.wip_entity_id = p_wip_entity_id
   and    scheduled_flag = 3;

   l_stmt_num := 110;

   --
   -- bugfix 2306314: Corrected the logic. Instead of checking rule_id is null in an IF condn,
   -- we shoud check for no-data-found
   --
   begin
     select rule_id
     into   l_rule_id
     from   mrp_scheduling_rules
     where  default_flag = 'Y'
     and    rownum = 1;

   exception
     when no_data_found then
       -- No Default Rule so cannot schedule a flow schedule
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add ('cto_schedule_fs: ' || 'Error: Default Rule does not exist. Cannot schedule a flow schedule.',1);
       END IF;
       raise FND_API.G_EXC_ERROR;

   end;

       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('cto_schedule_fs: ' || 'Rule ID: ' || to_char(l_rule_id),1);

       	oe_debug_pub.add('cto_schedule_fs: ' || 'Line ID: ' || to_char(l_line_id),1);

       	oe_debug_pub.add('cto_schedule_fs: ' || 'Order Line ID: ' || p_config_line_id,2);

       	oe_debug_pub.add('cto_schedule_fs: ' || 'WIP Entity ID: ' || to_char(p_wip_entity_id),2);
       END IF;

       l_stmt_num := 115;
       l_completion_date := MRP_FLOW_SCHEDULE_PUB.get_first_unit_completion_date(
                              p_api_version_number => 1.0,
                              x_return_status      => l_x_return_status,
                              x_msg_count          => l_x_msg_count,
                              x_msg_data           => l_x_msg_data,
                              p_org_id             => l_org_id,
                              p_item_id            => l_config_item_id,
                              p_qty                => l_planned_qty,
                              p_line_id            => l_line_id,
                              p_start_date         => sysdate);

       if (x_return_status = FND_API.G_RET_STS_ERROR) then
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('cto_schedule_fs: ' || 'Expected error in Get Completion Date with status ' || l_x_return_status,1);
           END IF;
	   raise FND_API.G_EXC_ERROR;

       elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('cto_schedule_fs: ' || 'UnExpected error in Get Completion Date with status ' || l_x_return_status,1);
           END IF;
           raise FND_API.G_EXC_UNEXPECTED_ERROR;

       end if;


       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('cto_schedule_fs: ' || 'Success in getting completion date: Completion Date is '
                             || to_char(l_completion_date), 1);
       END IF;

       if (trunc(l_completion_date) > trunc(l_ship_date)) then

           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('cto_schedule_fs: ' || 'Completion date is greater than ship date.',1);

           	oe_debug_pub.add('cto_schedule_fs: ' || 'Completion date is: ' || to_char(l_completion_date), 1);

           	oe_debug_pub.add('cto_schedule_fs: ' || 'Ship Date is: ' || to_char(l_ship_date),1);
           END IF;

           x_msg_name := 'CTO_LATE_COMPLETION_DATE';
           raise FND_API.G_EXC_ERROR;

       end if;


       l_stmt_num := 120;
       MRP_FLOW_SCHEDULE_PUB.Line_Schedule(
                             p_api_version_number => 1.0,
                             x_return_status      => l_x_return_status,
                             x_msg_count          => l_x_msg_count,
                             x_msg_data           => l_x_msg_data,
                             p_rule_id            => l_rule_id,
                             p_line_id            => l_line_id,
                             p_org_id             => l_org_id,
                             p_sched_start_date   => l_completion_date,
                             p_sched_end_date     => l_ship_date,
                             p_update             => 1.0);

       if (x_return_status = FND_API.G_RET_STS_ERROR) then
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('cto_schedule_fs: ' || 'Expected error in MRP_FLOW_SCHEDULE_PUB.Line Schedule with status ' || l_x_return_status,1);
           END IF;
	   raise FND_API.G_EXC_ERROR;

       elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('cto_schedule_fs: ' || 'UnExpected error in MRP_FLOW_SCHEDULE_PUB.Line Schedule with status ' || l_x_return_status,1);
           END IF;
           raise FND_API.G_EXC_UNEXPECTED_ERROR;

       else
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('cto_schedule_fs: ' || 'Success in MRP_FLOW_SCHEDULE_PUB.Line_Schedule.', 1);
           END IF;
       end if;

EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN

        x_msg_data := 'CTOFLSCB.cto_schedule_fs raised exp error: ' || to_char(l_stmt_num) || ':' || l_x_msg_data;
	if x_msg_name is null then
	    x_msg_name := 'CTO_CREATE_FLOW_SCHED_ERROR';
	end if;
        x_return_status := FND_API.G_RET_STS_ERROR;
	cto_msg_pub.cto_message('BOM', x_msg_name);
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('cto_schedule_fs: ' || x_msg_data, 1);
        END IF;
	CTO_MSG_PUB.Count_And_Get
        	(p_msg_count => x_msg_count
        	,p_msg_data  => x_msg_data
        	);


     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_msg_data := 'CTOFLSCB.cto_schedule_fs raised unexp error: ' || to_char(l_stmt_num) || ':' || l_x_msg_data;
	if x_msg_name is null then
	    x_msg_name := 'CTO_CREATE_FLOW_SCHED_ERROR';
	end if;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	cto_msg_pub.cto_message('BOM', x_msg_name);
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('cto_schedule_fs: ' || x_msg_data, 1);
        END IF;
	CTO_MSG_PUB.Count_And_Get
        	(p_msg_count => x_msg_count
        	,p_msg_data  => x_msg_data
        	);


     when OTHERS then
        x_msg_data := 'CTOFLSCB.cto_schedule_fs: ' || to_char(l_stmt_num) || ':'
                     || substrb(sqlerrm, 1, 100);
	if x_msg_name is null then
	    x_msg_name := 'CTO_CREATE_FLOW_SCHED_ERROR';
	end if;
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('cto_schedule_fs: ' || x_msg_data,1);
        END IF;
	cto_msg_pub.cto_message('BOM', x_msg_name);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	CTO_MSG_PUB.Count_And_Get
        	(p_msg_count => x_msg_count
        	,p_msg_data  => x_msg_data
        	);

END cto_schedule_fs;

end CTO_FLOW_SCHEDULE;

/
