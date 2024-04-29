--------------------------------------------------------
--  DDL for Package Body CTO_WIP_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_WIP_WRAPPER" as
/* $Header: CTOWIPWB.pls 120.12.12010000.4 2010/07/21 08:03:35 abhissri ship $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : CTOWIPWB.pls                                                  |
|                                                                             |
| DESCRIPTION:                                                                |
|               This file creates the utilities that are required to create   |
|                work orders for ATO configurations.                          |
|                                                                             |
|               insert_wip_interface - inserts a record into                  |
|                                    WIP_JOB_SCHEDULE_INTERFACE for           |
|                                    WIP_MASS_LOAD to create work orders      |
|                                                                             |
| To Do:        Handle Errors.  Need to discuss with Usha and Girish what     |
|               error information to include in Notification.                 |
|                                                                             |
| HISTORY     :                                                               |
|               August 14, 99    Angela Makalintal   Initial version          |
|               February 26, 01  Shashi Bhaskaran    bugfix 1642355	      |
|		May 7, 01	 Sajani Sheth	     Support for partial FAS  |
|		June 16, 01      Shashi Bhaskaran    bugfix 1835357           |
|                                Replaced fnd_file calls with oe_debug_pub    |
|               August 16,2001   Kiran Konada, fix for bug#1874380            |
|		                 to support ATO item under a PTO.             |
|                                item_type_code for an ato item under PTO     |
|			         is 'OPTION' and top_model_line_id will NOT be|
|				 null, UNLIKE an ato item order, where        |
|				 item_type_code = 'Standard' and              |
|				 top_model_lined_id is null                   |
|                                This fix has actually been provided in       |
|                                branched code  115.15.1155.4                 |
|                                                                             |
|                                                                             |
|               08/29/2001       Renga Kannan                                 |
|                                Modified the code for Porcuring config       |
|                                This batch program should not pick up        |
|                                the Buy config/ATO item orders               |
|                                This check is added to get_order_lines       |
|                                procedure.                                   |
|                                                                             |
|               Sep 26, 01   Shashi Bhaskaran   Fixed bug 2017099             |
|                            Check with ordered_quantity(OQ) instead of OQ-CQ |
|                            where CQ=cancelled_quantity. When a line is      |
|                            is canceled, OQ gets reflected.                  |
|                                                                             |
|               Oct 24, 01   Shashi Bhaskaran   Fixed bug 2074290             |
|                            Convert the ordered_quantity into Primary UOM for|
|                            comparing with get_reserved_qty.                 |
|                                                                             |
|               Feb 18, 02   Shashi Bhaskaran   Fixed bug 2227841             |
|                            Performance: Removed call to GET_NOTINV_QTY and  |
|                            GET_RESERVED_QTY from get_order_lines main cursor|
|                            and added soon after fetching the  cursor.       |
|                                                                             |
|               Feb 27, 02   Shashi Bhaskaran   Fixed bug 2243672             |
|                            Set the org context using OM's API               |
|                                                                             |
|               Jun 05, 02   Shashi Bhaskaran   Fixed bug 2388802             |
|                            Because of the earlier fix (2227841), the cursor |
|                            picked up the non-eligbile rows and locked them. |
|                            Removed the for update clause from the cursor and|
|                            locked it for the real eligible row.             |
|									      |
|               Oct 24, 02   Kundan Sarkar      Fixed bug 2628896             |
|                            To propagate fix 2420381 from branch to main     |
|                                                                             |
|               Oct 25, 02   Kundan Sarkar      Bugfix 2644849 (2620282 in br)|
|                            Sales order not seen in LOV while doing WIP      |
|                            completion as revision info is not passed 	      |
|                            while reserving the sales order against work     |
|                            order.				              |
|                                                                             |
|               Dec 06, 02   Kundan Sarkar      Bugfix 2698837 (2681321 in br)|
|                            Not creating work order in shipping org if the   |
|			     item is sourced from a different org and sourcing|
|			     rule is "TRANSFER FROM".			      |
|                                                                             |
|               May 07, 03   Kundan Sarkar      Bugfix 2930170 		      |
|		May 09, 03   (2868148 and 2946071 in br)		      |
|			     2868148:					      |
|                            Considering supply from Flow Schedule before     |
|			     creating supply through AFAS  to prevent multiple|
|			     work order creation.			      |
|			     2946071:					      |
|			     Need to handle null condition when flow_supply   |
|			     returns NO_DATA_FOUND			      |


               Sep 23, 2003  Renga Kannan                                    |
|                               Changed the following two table acecss to     |
|                               view. This change is recommended by shipping  |
|                               team to avoid getting inbound/dropship lines.
V
                                WSH_DELIVERY_DETAILS to WSH_DELIVERY_DETAILS_OB_
GRP_V
                                This changes brings a wsh dependency to our code
                                the wsh pre-req for this change is 3125046

|24-SEP-2003   : Kiran Konada
|                Chnages for patchset-J
|                with mutiple sources enhancement ,
|                expected error from query sourcing org has been removed
|                source_type =66 refers to mutiple sourcing
|
|               statements after call to query org has been modified to look at
|               source type =66 instead of   expected error status
|
|
|19-Nov-2003  : Kiran Konada
|              		   bugfix 2885568
|                           There was a full table scan on wip_discrete_jobs
|                           unique index present on wip_enity_id and organization_id
|                           hece, joined oe_order_lines_all and got the ship_from _org_id
|
|                          original query
|                              select  dj.wip_entity_id,  we.wip_entity_name
|		        	  into    l_wip_entity_id, l_job_name
|				from    wip_discrete_jobs dj, wip_entities we|
|			       where   dj.wip_entity_id = we.wip_entity_id
|				and     dj.source_line_id = l_line_id
|				  and	  dj.source_code = 'WICDOL'
|
|                          Changed query
|
|                            added follwoing where clause
|
|				and     oel.line_id = l_line_id
|                               and     dj.primary_item_id = oel.inventory_item_id
|                               and     oel.ship_from_org_id = dj.organization_id ;
|
|
|25-Nov-2003   Bugfix 3202934 :
|                            Reservation getting created even if job creation
|                            fails
|
|10-JUN-2003   KIran Konada
|              -- bugfix 3618441 (front port bug#3631702) :
|                      This is also dependent on WIP valuset change
|                      front port fix #3682313
|
|
|13-AUG-2004   Sushant Sawant
|              -- bugfix 3828248
|              front ported bug 3718374 to improve performance for cursor c_work_order_eligible.
|
|
|
|
|20-AUG-2004   Sushant Sawant
|        /* Fix for bug 3777065
|        ** Original cursor c_work_order_eligible had performance issues due to additional conditions for workflow status.
|        ** repetition of conditions related to offset days has been removed.
|        ** This cursor has been split. The new approach is to insert the data into a temp table using the same sql statement
|        ** without the workflow conditions and then filter the data with the additional conditions for work flow status.
|        ** The cursor c_work_order_eligible will now be using bom_cto_order_lines_gt, wf_item_activity_statuses
|        ** and wf_process_activities tables.
|        */
/*=============================================================================*/

PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);



-- bugfix 3136206
PROCEDURE unlock_line_id(p_line_id IN  NUMBER)
IS

BEGIN


    UPDATE oe_order_lines_all oel
    SET    oel.program_id = null
    WHERE  oel.line_id = p_line_id
    AND    oel.program_id = -99;

    IF (sql%rowcount > 0) THEN
        IF (PG_DEBUG <> 0) THEN
    	     oe_debug_pub.add ('unlock_line_id: ' || 'unlocked line_id '||p_line_id);
        END IF;
    END IF;

EXCEPTION

    when others then
	IF PG_DEBUG <> 0 THEN
		OE_DEBUG_PUB.add ('unlock_line_id: error: ' || sqlerrm);

        END IF;

END UnLock_Line_Id;

-- end bugfix 3136206

/*****************************************************************************
   Procedure:  get_order_lines

   Parameters:
                p_org_id - Organization ID from user input
                p_offset_days - Number of days added to the current date
                                and compared to the release date
                p_load_type - Load Type values are:
                               1.  1 - Configuration Items
                               2.  2 - ATO Items
                               3.  3 - Configuration Items and ATO Items
                p_class_code - Accounting Class code for job creation (user
                               parameter)
                p_status_type - Unreleased, Released (user input)
                p_order_number - Specific order number to process (user input)
                p_conc_request_id - concurrent request ID
                p_conc_program_id - concurrent program ID
                p_conc_login_id - concurrent login ID
                p_user_id - User ID
                p_appl_conc_program_id  - Application Concurrent Program ID
                x_orders_loaded - Number of rows inserted into interface table
                x_wip_seq i - Group ID in interface table
                x_message_name - Error message name
                x_message_text - Error message text

   Description:  This function inserts a record into the
                 WIP_JOB_SCHEDULE_INTERFACE table for the creation of
                 work orders through AutoCreate FAS in OM.

*****************************************************************************/




FUNCTION get_order_lines(p_org_id                IN  NUMBER,
                         p_offset_days           IN  NUMBER,
                         p_load_type             IN  NUMBER,
                         p_class_code            IN  varchar2,
                         p_status_type           IN  NUMBER,
                         p_order_number          IN  NUMBER,
                         p_line_id               IN  NUMBER,
                         p_conc_request_id       IN  NUMBER,
                         p_conc_program_id       IN  NUMBER,
                         p_conc_login_id         IN  NUMBER,
                         p_user_id               IN  NUMBER,
                         p_appl_conc_program_id  IN  NUMBER,
                         x_orders_loaded         OUT NoCopy NUMBER,
                         x_wip_seq               OUT NoCopy NUMBER,
                         x_message_name          OUT NoCopy VARCHAR2,
                         x_message_text          OUT NoCopy VARCHAR2
)
return integer

IS

       l_x_hold_result_out 	VARCHAR2(1);
       l_x_hold_return_status 	VARCHAR(1);
       l_x_error_msg_count 	NUMBER;
       l_x_error_msg       	VARCHAR2(240);
       l_x_result_out 		VARCHAR2(1);
       l_x_return_status  	VARCHAR2(1);
       l_x_error_message  	VARCHAR2(1000);
       l_x_message_name   	VARCHAR2(30);
       l_x_msg_count 		NUMBER;
       l_x_msg_data		VARCHAR2(2000);
       l_rows_selected 		NUMBER := 0;
       l_rows_inserted 		NUMBER := 0;
       l_rows_on_hold  		NUMBER := 0;
       l_rows_dep_plan 		NUMBER := 0;
       l_rows_errored 		NUMBER := 0;
       l_line_id       		NUMBER := p_line_id;
       l_org_id        		NUMBER := p_org_id;
       l_order_number  		NUMBER := p_order_number;
       -- bugfix 4056151: commented out lSourceCode since its no longer used.
       -- lSourceCode		VARCHAR2(30);
       l_dep_plan_flag		VARCHAR2(1);
       l_planned		VARCHAR2(10);
       l_stmt_num		NUMBER;

       Not_Planned		EXCEPTION;

-- Begin Bugfix 4056151: Added REF Cursor and new variables

       TYPE WorkOrderCurTyp is REF CURSOR ;
       WorkOrder 	WorkOrderCurTyp;

       TYPE WorkOrderRecTyp is RECORD (
	   line_id            number,
	   ship_from_org_id   number,
           header_id          number,
	   org_id	      number,
	   ato_line_id        number,
	   inventory_item_id  number);
       WorkOrder_Rec	WorkOrderRecTyp;

       sql_stmt		VARCHAR2(5000);
       drive_mark	NUMBER := 0;

-- End Bugfix 4056151: Added REF Cursor.

         -- The following variable declaration is added by Renga Kannan for
	 -- Procuring Configuration Project
         -- Added on 08/29/01

         l_sourcing_rule_exists        varchar2(1);
         l_inventory_item_id           mtl_system_items.inventory_item_id%type;
         l_ship_from_org_id            mtl_system_items.organization_id%type;
         l_source_type                 Number;
         l_sourcing_org                Number;
         l_transit_lead_time           Number;
         l_exp_error_code              Number;

        -- End of Addition

        -- bugfix 2053360 : declare a new exception
         record_locked          	EXCEPTION;
         pragma exception_init (record_locked, -54);

        -- bugfix 2243672 : declare new variables
         lOperUnit              	Number := -1;	-- bugfix 3014000: default value changed to -1
	 xUserId			Number;
	 xRespId			Number;
	 xRespApplId			Number;

	-- bugfix 3014000
         l_client_org_id		Number;
         l_offset_days  		NUMBER; 	-- bugfix 4064726

	 --as part of OPM project
	 l_can_create_supply            varchar2(1);
	 l_message                      varchar2(100);
BEGIN
        /****************************************************************
         Select Eligible Records based on parameters and workflow status.
        ****************************************************************/

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('get_order_lines: ' ||  'Begin Get Order Lines.', 1);

        	oe_debug_pub.add('get_order_lines: ' ||  'Organization ID: '||to_char(p_org_id), 1);

        	oe_debug_pub.add('get_order_lines: ' ||  'Offset: '||to_char(p_offset_days), 1);

        	oe_debug_pub.add('get_order_lines: ' ||  'Load Type: '||to_char(p_load_type), 1);

        	oe_debug_pub.add('get_order_lines: ' ||  'Class Code: '||p_class_code, 1);

        	oe_debug_pub.add('get_order_lines: ' ||  'Status Type: '||to_char(p_status_type), 1);

        	oe_debug_pub.add('get_order_lines: ' ||  'Order Number: '||to_char(p_order_number), 1);

        	oe_debug_pub.add('get_order_lines: ' ||  'Line ID: ' ||to_char(p_line_id), 1);
        END IF;

        x_wip_seq := -1;
        x_orders_loaded := 0;
        /*------------------------------------------------+
         If IN parameter equal -1, then parameter value was not
         entered.  We NULL out the equivalent local variable
         so that it will not be used in the SQL.
        +-------------------------------------------------*/
	if (p_line_id = -1) then
            l_line_id := NULL;
        end if;

        if (p_org_id = -1) then
            l_org_id := NULL;
        end if;

        if (p_order_number = -1) then
            l_order_number := NULL;
        end if;

	--begin bugfix 4064726
        if p_offset_days = -10000 then
           l_offset_days := null ;

           IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add('get_order_lines: ' ||  'initialized Offset to null : '||to_char(l_offset_days), 1);
           END IF;

        else
           l_offset_days := p_offset_days ;
        end if;
	--end bugfix 4064726

-- Begin Bugfix 4056151: Added Dynamic Clause

	if (l_order_number IS NOT NULL) or (l_line_id IS NOT NULL) then
	   sql_stmt := 'select /*+ ordered index (WAS WF_ITEM_ACTIVITY_STATUSES_PK) */  '||
                       '    oel.line_id              line_id, '||
	               '    oel.ship_from_org_id     ship_from_org_id, '||
                       '    oel.header_id            header_id, '||
	               '    nvl(oel.org_id,-1)	     org_id, ' ||
		       '    oel.ato_line_id          ato_line_id, '||
		       '    oel.inventory_item_id    inventory_item_id '||
                       'from   '||
                       '    oe_order_lines_all OEL, '||
                       '    wf_item_activity_statuses WAS, '||
                       '    wf_process_activities WPA, '||
                       '    mtl_system_items MSI ';
	else
	   -- Use a different order sequence of tables


	   -- (FP 5510153) bug 5409829: Added the hint for index WF_ITEM_ACTIVITY_STATUSES_N1. This will improve performance
           -- only if WF_ITEM_ACTIVITY_STATUSES_N1 has the column process_activity. So WF patch 4730872 is a prereq.
	   -- for FP we do not need that WF patch as a pre-req as System Test env's already show that required column PROCESS_ACTIVITY is part
	   -- of index WF_ITEM_ACTIVITY_STATUSES_N1. Also, latest version of file afwfnp.odf in fnd_top has this change

	   sql_stmt := 'select /*+ ordered index (WPA WF_PROCESS_ACTIVITIES_N1) index (WAS WF_ITEM_ACTIVITY_STATUSES_N1) */ '||
                       '    oel.line_id              line_id, '||
	               '    oel.ship_from_org_id     ship_from_org_id, '||
                       '    oel.header_id            header_id, '||
	               '    nvl(oel.org_id,-1)	     org_id, ' ||
		       '    oel.ato_line_id          ato_line_id, '||
		       '    oel.inventory_item_id    inventory_item_id '||
                       'from   '||
                       '    wf_process_activities WPA, '||
                       '    wf_item_activity_statuses WAS, '||
                       '    oe_order_lines_all OEL, '||
                       '    mtl_system_items MSI ';
	end if;


        -- rkaza. 07/29/2005. bug 4438574. Item type code will be standard for
        -- independent ato item and option for ato under pto.

        sql_stmt := sql_stmt ||
            'where  oel.inventory_item_id = msi.inventory_item_id '||
            'and    oel.ship_from_org_id = msi.organization_id '||
            'and    msi.bom_item_type = 4 '|| -- STANDARD
            'and    oel.open_flag = ''Y'' '||
	    'and    oel.ato_line_id is not null '||
            'and   (oel.item_type_code = ''CONFIG'' ' ||
                   'or (oel.ato_line_id = oel.line_id ' ||
                       'and oel.item_type_code = ''OPTION'') ' ||
		   --Adding INCLUDED item type code for SUN ER#9793792
		   'or (oel.ato_line_id = oel.line_id ' ||
                       'and oel.item_type_code = ''INCLUDED'') ' ||
                   'or (oel.ato_line_id = oel.line_id ' ||
                       'and oel.item_type_code = ''STANDARD'' ' ||
                       'and oel.top_model_line_id is null)) ' ||
            'and    nvl(oel.cancelled_flag, ''N'') =  ''N'' '||
            'and    oel.booked_flag = ''Y'' '||
            'and    oel.schedule_status_code = ''SCHEDULED'' '||
	    'and    oel.ordered_quantity  > 0 '||
            'and    msi.replenish_to_order_flag = ''Y'' '||
            'and    msi.build_in_wip_flag = ''Y'' '||
            'and    msi.pick_components_flag = ''N'' '||
            'and    was.item_type = ''OEOL'' '||
            'and    was.activity_status = ''NOTIFIED'' '||
	    'and    was.item_type = wpa.activity_item_type  '||
	    'and    was.process_activity = wpa.instance_id '||
	    'and    wpa.activity_name in '||
	    '(''EXECUTECONCPROGAFAS'', ''CREATE_SUPPLY_ORDER_ELIGIBLE'', ''SHIP_LINE'') '||
            'and ((wpa.activity_name = ''EXECUTECONCPROGAFAS'' and oel.program_id = -99) ' ||
  				-- spawned thru workflow
	    '    OR '||
            '   (wpa.activity_name<>''EXECUTECONCPROGAFAS'' and nvl(oel.program_id,0)<>-99)) '||
  				-- spawned thru SRS
            'and    not exists (select ''1''  '||
                       'from   bom_operational_routings bor ' ||
                       'where  bor.assembly_item_id = oel.inventory_item_id '||
                       'and    bor.organization_id = oel.ship_from_org_id ' ||
                       'and    bor.alternate_routing_designator is NULL '||
                       'and    nvl(bor.cfm_routing_flag, 2) = 1) ' ;

/*  We want to do an explicit to_char() when order_number or line_id
 *  parameter is passed because we are driving from OEL->WAS. If we are driving
 *  from WF tables into OE then to_char() should not be used.
 *
 *  Here, the problem was because of the implicit type conversion that was happening on the WAS side.
 *  That was preventing the item_key column of the WAS PK index from being used during index access.
 *  It was effectively using the index only on the item_type column and that is the reason why it was slow.
 */

	if (l_order_number IS NOT NULL) or (l_line_id IS NOT NULL) then
	   sql_stmt := sql_stmt ||
                       'and    was.item_key = to_char(oel.line_id) ';
	else
	   sql_stmt := sql_stmt ||
                       'and    was.item_key = oel.line_id ';
	end if;


	if (l_order_number IS NOT NULL) then
	   sql_stmt := sql_stmt ||
	               'and oel.header_id in (select oeh.header_id '||
		       			     'from  oe_order_headers_all oeh ' ||
					     'where oeh.order_number = :l_order_number) ';
           drive_mark := drive_mark + 1;
	end if;

	if (l_line_id is NOT NULL) then
	   sql_stmt := sql_stmt ||
	               'and oel.line_id in '||
                              '(select oelc.line_id '||
                              ' from   oe_order_lines_all oelc '||
                              ' where  (oelc.ato_line_id = :l_line_id '||--5108885
                                       'and oelc.item_type_code = ''CONFIG'') '||
                               'or     (oelc.line_id = :l_line_id '||
                                       'and oelc.item_type_code = ''STANDARD'' ' ||
                                       'and oelc.top_model_line_id is null) '||
			       --Adding INCLUDED item type code for SUN ER#9793792
			       'or     (oelc.line_id = :l_line_id '||
			               'and oelc.ato_line_id = oelc.line_id '||
                                       'and oelc.item_type_code = ''INCLUDED'') ' ||
                               'or     (oelc.line_id = :l_line_id '||			-- ATO item within PTO
                                       'and oelc.ato_line_id = oelc.line_id '||
                                       'and oelc.item_type_code = ''OPTION'')) ';	-- fix for bug#1874380
           drive_mark := drive_mark + 2;
	end if;

	if (l_org_id is NOT NULL) then
	   sql_stmt := sql_stmt ||
	               'and oel.ship_from_org_id = :l_org_id ';
           drive_mark := drive_mark + 4;
	end if;

	if (l_line_id is NULL AND p_load_type IS NOT NULL) then
	  if (p_load_type = 1) then
            --
            -- Given Load Type = 1:  Config Items
            --
	    sql_stmt := sql_stmt ||
                 'and  oel.item_type_code = ''CONFIG'' '||
                 'and  msi.base_item_id is not null ';

	  elsif (p_load_type = 2) then
            --
            -- Given Load Type = 2:  ATO items
            --
	    sql_stmt := sql_stmt ||
                 --Adding INCLUDED item type code for SUN ER#9793792
		 --'and oel.item_type_code in (''STANDARD'', ''OPTION'') '||
		 'and oel.item_type_code in (''STANDARD'', ''OPTION'', ''INCLUDED'') '||
                 'and oel.ato_line_id = oel.line_id ';

	  elsif (p_load_type = 3) then
            --
            -- Given Load Type = 3:  Both Config and ATO items
            --
	    sql_stmt := sql_stmt ||
                 'and (oel.item_type_code = ''CONFIG'' '||
                      --Adding INCLUDED item type code for SUN ER#9793792
		      --'or (oel.item_type_code in (''STANDARD'', ''OPTION'') '||
		      'or (oel.item_type_code in (''STANDARD'', ''OPTION'', ''INCLUDED'') '||
                           'and oel.ato_line_id = oel.line_id)) ';
	  end if;

	end if;

	-- bugfix 4064726 : Include offset days condition only when offset days parameter is passed.

	if (l_line_id is NULL AND l_offset_days IS NOT NULL) then
          drive_mark := drive_mark + 8;
	  sql_stmt := sql_stmt ||
                 'and  SYSDATE  >= '||
                        '(select CAL.CALENDAR_DATE '||
                         'from   bom_calendar_dates cal, '||
                                'mtl_parameters     mp '||
                         'where  mp.organization_id = oel.ship_from_org_id '||
                         'and    cal.calendar_code  = mp.calendar_code '||
                         'and    cal.exception_set_id = mp.calendar_exception_set_id '||
                         'and    cal.seq_num = '||
                                   '(select cal2.prior_seq_num '||
				      '- nvl(:p_offset_days, 0) '||
                                      '- (ceil(nvl(msi.fixed_lead_time,0) '||
                                      '+  nvl(msi.variable_lead_time,0) '||
                		      '*  (INV_CONVERT.inv_um_convert( '||
						'oel.inventory_item_id, '||
						'5, '||
						-- bugfix 2204376: pass precision of 5
						'oel.ordered_quantity, '||
						'oel.order_quantity_uom, '||
						'msi.primary_uom_code, '||
						'null, '||
						'null ) '||
						'- CTO_WIP_WRAPPER.GET_RESERVED_QTY(oel.line_id)) ))	'||
						--bugfix 3034619: added parenthesis
						--bugfix 2074290: convert the OQ and then
						--       subtract from get_reserved_qty
                                    'from   bom_calendar_dates cal2 '||
                                    'where  cal2.calendar_code = mp.calendar_code '||
                                    'and    cal2.exception_set_id = mp.calendar_exception_set_id '||
                                    'and    cal2.calendar_date    = trunc(oel.schedule_ship_date))) ';
	end if; /* load_type check ends */

	sql_stmt := sql_stmt ||
	            'order by oel.org_id, oel.line_id';

	IF PG_DEBUG <> 0 THEN
	   oe_debug_pub.add ('SQL: ' || substr(sql_stmt,1, 1500));
	   oe_debug_pub.add (substr(sql_stmt,1501,3000));
	   oe_debug_pub.add ('drive_mark = '||drive_mark );
	END IF;

    /*
       Below, we execute the sql statement according to which parameters
       we have selected.  The drive_mark variable tells us which parameters
       we are using, so we are sure to send the right ones to SQL.
    */

        if (drive_mark = 0) then
	-- No (optional) parameter is passed
	    Open WorkOrder FOR sql_stmt;

        elsif (drive_mark = 1) then
	-- Only Order_Number is passed
	    Open WorkOrder FOR sql_stmt USING l_order_number;

        elsif (drive_mark = 2) then
	-- Only Line_Id is passed
	    --ER#9793792
	    --Open WorkOrder FOR sql_stmt USING l_line_id, l_line_id, l_line_id;
	    Open WorkOrder FOR sql_stmt USING l_line_id, l_line_id, l_line_id, l_line_id;

        elsif (drive_mark = 3) then
	-- Order Number and Line_Id is passed
	    --ER#9793792
	    --Open WorkOrder FOR sql_stmt USING l_order_number, l_line_id, l_line_id, l_line_id;
	    Open WorkOrder FOR sql_stmt USING l_order_number, l_line_id, l_line_id, l_line_id, l_line_id;

        elsif (drive_mark = 4) then
	-- Only Orgn_Id is passed
	    Open WorkOrder FOR sql_stmt USING l_org_id;

        elsif (drive_mark = 5) then
	-- Order_Number and Orgn_Id is passed
	    Open WorkOrder FOR sql_stmt USING l_order_number, l_org_id;

        elsif (drive_mark = 6) then
	-- Line_id and Orgn_Id is passed
	    --ER#9793792
	    --Open WorkOrder FOR sql_stmt USING l_line_id, l_line_id, l_line_id, l_org_id;
	    Open WorkOrder FOR sql_stmt USING l_line_id, l_line_id, l_line_id, l_line_id, l_org_id;

        elsif (drive_mark = 7) then
	-- Order_number, Line_Id and Orgn_Id is passed
	    --ER#9793792
	    --Open WorkOrder FOR sql_stmt USING l_order_number, l_line_id, l_line_id, l_line_id, l_org_id;
	    Open WorkOrder FOR sql_stmt USING l_order_number, l_line_id, l_line_id, l_line_id, l_line_id, l_org_id;

        elsif (drive_mark = 8) then
	-- Offset_Days is passed
	    Open WorkOrder FOR sql_stmt USING p_offset_days;

        elsif (drive_mark = 9) then
	-- Order_Number and Offset_Days is passed
	    Open WorkOrder FOR sql_stmt USING l_order_number, p_offset_days;

        elsif (drive_mark = 10) then
	-- Line_id and Offset_Days is passed
	    Open WorkOrder FOR sql_stmt USING l_line_id, p_offset_days;

        elsif (drive_mark = 11) then
	-- Order_Number, Line_id and Offset_Days is passed
	    Open WorkOrder FOR sql_stmt USING l_order_number, l_line_id, p_offset_days;

        elsif (drive_mark = 12) then
	-- Organization_id and Offset_Days is passed
	    Open WorkOrder FOR sql_stmt USING l_org_id, p_offset_days;

        elsif (drive_mark = 13) then
	-- Order_Number, Organization_id and Offset_Days is passed
	    Open WorkOrder FOR sql_stmt USING l_order_number, l_org_id, p_offset_days;

        elsif (drive_mark = 14) then
	-- Line_id, Organization_id and Offset_Days is passed
	    --ER#9793792
	    --Open WorkOrder FOR sql_stmt USING l_line_id, l_line_id, l_line_id, l_org_id, p_offset_days;
	    Open WorkOrder FOR sql_stmt USING l_line_id, l_line_id, l_line_id, l_line_id, l_org_id, p_offset_days;

        elsif (drive_mark = 15) then
	-- Order_Number, Line_id, Organization_id and Offset_Days is passed
	    --ER#9793792
	    --Open WorkOrder FOR sql_stmt USING l_order_number, l_line_id, l_line_id, l_line_id, l_org_id, p_offset_days;
	    Open WorkOrder FOR sql_stmt USING l_order_number, l_line_id, l_line_id, l_line_id, l_line_id, l_org_id, p_offset_days;

        else
	   IF PG_DEBUG <> 0 THEN
	    oe_debug_pub.add ('INCORRECT COMBINATION of parameters');
	   END IF;

        end if;

-- End Bugfix 4056151: End of Dynamic SQL creation

       IF PG_DEBUG <> 0 THEN
	oe_debug_pub.add ('Opened. System Time : '||to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));
       END IF;


	-- begin bugfix 3014000
        -- Added for MOAC project.
	-- Deriving the current org using MO GLOBAL API
	lOperUnit := nvl(MO_GLOBAL.get_current_org_id,-99);

	IF PG_DEBUG <> 0 THEN
           oe_debug_pub.add('get_order_lines: '|| 'MO:operating Unit :' || lOperUnit, 2);
	END IF;
	-- end bugfix 3014000

        --
        -- Bugfix 4056151: Replaced implicit cursor with explicit cursor.
        -- Replaced "WorkOrder_Rec" with "WorkOrder_Rec" through out the code.
        --


        /* After discussions with performance team, it was decided to use bugfix 4056151
           instead of bugfix 3777065. To view the fix for 3777065, please checkout
	   the previous version.
        */


	l_stmt_num := 1;
	LOOP
		FETCH  WorkOrder INTO WorkOrder_Rec;
		EXIT WHEN WorkOrder%NOTFOUND;
               IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add ('Fetched. System Time : '||to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));
	       END IF;
		-- begin bugfix 3014000: Moved the debug stmt here

		IF PG_DEBUG <> 0 THEN
                   oe_debug_pub.add('----------------------------------------', 5);
                   oe_debug_pub.add('Processing line_id: '||WorkOrder_Rec.line_id, 5);
                   oe_debug_pub.add('----------------------------------------', 5);
		END IF;


     		--
     		-- Begin Bugfix 2243672
     		--
         	if (lOperUnit <> WorkOrder_Rec.org_id ) then
			--
     			-- Bugfix 2310559: We will call regular fnd_client_info.set_org_context instead of
     			-- OM's API Set_Created_By_Context because the conc programs submitted via WF, call
     			-- the FND_WF_STANDARD.callback function at the end. This program tries to
			-- retrieve the value of the profile - CONC_REQUEST_ID but cannot find the
			-- profile value as it was cleared during apps_initialize call. Thus resulting in
			-- failures later.
			--

			--
			-- We will call this API only when there is a change in the org.
			--

			-- Bugfix 3014000: When called from WF, there's no need to set the context since
			--                 its already set by workflow.
			--                 When called from SRS, set the context only when ORG_ID is different
			--		   from OEL.org_id.
			-- Caveat: Single org customers should NOT set the MO:Operating unit for the resp
			--         which is used to run autocreate FAS. If so, OM will defer the activity.

		-- begin bugfix 3014000
			-- commenting out...  : FND_CLIENT_INFO.Set_Org_Context ( WorkOrder_Rec.org_id );

			IF PG_DEBUG <> 0 THEN
        		   oe_debug_pub.add('get_order_lines: '|| 'Setting the Org Context to '||WorkOrder_Rec.org_id ||
					 ' by calling OE_Order_Context_GRP.Set_Created_By_Context.', 5);
			END IF;

	     		OE_Order_Context_GRP.Set_Created_By_Context (
					 p_header_id		=> NULL
					,p_line_id		=> WorkOrder_Rec.line_id
					,x_orig_user_id         => xUserId
					,x_orig_resp_id         => xRespId
					,x_orig_resp_appl_id    => xRespApplId
					,x_return_status        => l_x_return_status
					,x_msg_count            => l_x_msg_count
					,x_msg_data             => l_x_msg_data );

  			if    l_x_return_status = FND_API.G_RET_STS_ERROR THEN
			      IF PG_DEBUG <> 0 THEN
     				oe_debug_pub.add('get_order_lines: '|| 'Expected Error in Set_Created_By_Context.');
			      END IF;
     				raise FND_API.G_EXC_ERROR;

  			elsif l_x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			      IF PG_DEBUG <> 0 THEN
     				oe_debug_pub.add('get_order_lines: '|| 'UnExpected Error in Set_Created_By_Context.');
			      END IF;
     				raise FND_API.G_EXC_UNEXPECTED_ERROR;

  			end if;
         	else
			IF PG_DEBUG <> 0 THEN
        		   oe_debug_pub.add('get_order_lines: '|| 'NOT Setting the Org Context since MO:Operating Unit = OEL.org_id.', 5);
			END IF;
         	end if;
		-- end bugfix 3014000


		lOperUnit := WorkOrder_Rec.org_id;	-- bugfix 3014000 : OE api will set the mo oper unit in cache.
						-- Instead of again querying up profile, we can safely use WorkOrder_Rec.org_id

     		--
     		-- End Bugfix 2243672
     		--

		--
		-- bugfix 2227841: Moved the function calls from the cursor for
		-- performance reasons.
		--


		-- bugfix 2868148
		-- added new function GET_FLOW_QTY to consider flow supply during discrete job creation
		/***************************************************************************************************
		Scenarios
		Order Qty = 10

		Pln Qty  Compl Qty   Flow_Qty      Get_Reserved_qty   Total Supply   Get_Notinv_qty  Net Supply
		(PQ)       (CQ)	    FQ = PQ- CQ	        (RQ)	      TS = RQ + FQ	 (WDD)       WDD - TS
                    		    = 0    if <=0                                                    Create supply
                    		    = PQ-CQ if >0                                                    if > 0

  		6	    6		0		 6		  6		 10		10-6 = 4
  		6	    1		5		 1		  6		 10		10-6 = 4
  		6	    0		6		 0		  6		 10		10-6 = 4
  		6	    8		0*		 8		  8		 10		10-8 = 2
  		10	    10		0		 10		  10		 10		10-10 = 0
  		10	    1		9		 1		  10		 10		10-10 = 0
  		10	    0		10		 0		  10		 10		10-10 = 0
  		10	    12		0*		 10		  10		 10		10-10 = 0

		* 0 since FQ = -2
		****************************************************************************************************/
		--Bugfix 6146803: Checking of GET_NOTINV_QTY - GET_RESERVED_QTY and locking the corresponding order
                -- line has to be atomic. So commenting out the following part.
                /*if  ( GET_NOTINV_QTY(WorkOrder_Rec.line_id) - GET_RESERVED_QTY(WorkOrder_Rec.line_id) <= 0 )
		then
                	IF PG_DEBUG <> 0 THEN
                		oe_debug_pub.add('get_order_lines: ' || 'get_notinv_qty() - get_reserved_qty() <= 0.',2);

                		oe_debug_pub.add('get_order_lines: ' || 'This line ('||WorkOrder_Rec.line_id||
					') is not eligible for creation of workorder.',2);
                	END IF;
			goto end_of_loop;
		end if;
                */   --Bugfix 6146803
		-- Check wip supply type. If it is not 1=Discrete or 0=None, then, ignore this line.
		if WIP_ATO_UTILS.check_wip_supply_type (
				p_so_header_id		=>  WorkOrder_Rec.header_id,
				p_so_line		=>  WorkOrder_Rec.line_id,
				p_so_delivery		=>  NULL,
				p_org_id		=>  WorkOrder_Rec.ship_from_org_id)  not in (0,1)
		then
                	IF PG_DEBUG <> 0 THEN
                		oe_debug_pub.add('get_order_lines: ' || 'check_wip_supply_type() returned a value not in (0,1). ',2);

                		oe_debug_pub.add('get_order_lines: ' || 'This line ('||WorkOrder_Rec.line_id||
					') is not eligible for creation of workorder.', 2);
                	END IF;
			goto end_of_loop;
		end if;

		-- end bugfix 2227841

		-- This should be the incremented only after the line has passed the previous checks.
                -- bug 6146803: Move this line to after obtaining the lock.
       		--l_rows_selected := l_rows_selected + 1;

                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('get_order_lines: ' || 'Looking the sourcing information...',1);
                END IF;

		l_stmt_num := 2;

                -- Bug 6146803: Checking of GET_NOTINV_QTY - GET_RESERVED_QTY and locking the corresponding order
                -- line has to be atomic.

                begin
                    SELECT ship_from_org_id
                    INTO   l_ship_from_org_id
                    FROM   OE_ORDER_LINES_ALL
                    WHERE  line_id = WorkOrder_Rec.ato_line_id --- bug fix 5207010 . We should lock based on ATO line id
                    and    (GET_NOTINV_QTY(WorkOrder_Rec.line_id) - GET_RESERVED_QTY(WorkOrder_Rec.line_id)) > 0
		    FOR UPDATE NOWAIT;		-- bugfix 2388802: lock the row which is really eligible
		    l_inventory_item_id := WorkOrder_Rec.inventory_item_id;
		exception
        	    WHEN record_locked THEN
                       IF PG_DEBUG <> 0 THEN
                       	OE_DEBUG_PUB.add ('get_order_lines: ' || 'Could not lock line id '|| to_char(WorkOrder_Rec.line_id) ||' for update.');

                       	OE_DEBUG_PUB.add ('get_order_lines: ' || 'This line is being processed by another process.',1);
                       END IF;
		       goto end_of_loop;
		    -- bugfix 2420381: added the excpn for better handling of error.

                    -- Bug 6146803: No data found shall happen if GET_NOTINV_QTY - GET_RESERVED_QTY <= 0
                    WHEN NO_DATA_FOUND THEN
                	IF PG_DEBUG <> 0 THEN
                		oe_debug_pub.add('get_order_lines: ' || 'get_notinv_qty() - get_reserved_qty() <= 0.',2);

                		oe_debug_pub.add('get_order_lines: ' || 'This line ('||WorkOrder_Rec.line_id||
					') is not eligible for creation of workorder.',2);
                	END IF;
			goto end_of_loop;

                    WHEN others THEN
                       IF PG_DEBUG <> 0 THEN
                       	oe_debug_pub.add('get_order_lines: ' || 'others exception while locking line '||WorkOrder_Rec.line_id||':'||sqlerrm,1);
                       END IF;
		       goto end_of_loop;
                end;

		l_rows_selected := l_rows_selected + 1;  --Bugfix 6146803

                /* bugfix 3136206: added the following debug stmt */
                IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('get_order_lines: ' || 'successfully locked line '|| WorkOrder_Rec.line_id);
                END IF;

		l_stmt_num := 3;

		--replaced query_socuring_org call (change done as part of OPM project)
		--check_cto_can_creat_supply is a wrapper over query_socuring_org
		--and custom api CTO_CUSTOM_SUPPLY_CHECK_PK.Check_Supply.
		--Enhacement for R12 is, AFAS should not create supply
		--if custom api returns 'N'

	        CTO_UTILITY_PK.check_cto_can_create_supply (
			P_config_item_id    => l_inventory_item_id,
			P_org_id            => l_ship_from_org_id,
			x_can_create_supply => l_can_create_supply,--declare
			p_source_type       =>l_source_type,
			x_return_status     =>l_x_return_status,
			X_msg_count	    =>l_x_msg_count,
			X_msg_data          =>l_x_msg_data,
			x_sourcing_org      =>l_sourcing_org,
			X_message         =>l_message --declare
			);

                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('get_order_lines: ' || 'Return status from Query_sourcing_org = '||l_x_return_status,1);
                END IF;

                IF l_x_return_status = FND_API.G_RET_STS_SUCCESS THEN

		  IF l_can_create_supply = 'N' THEN --opm
                    IF PG_DEBUG <> 0 THEN
		        --would identify if line is skipped becuase of custom hook
                     	oe_debug_pub.add('get_order_lines: ' ||l_message,1);
                    END IF;

                    IF nvl(l_source_type,1) = 66 THEN --Kiran Konada
                      IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('get_order_lines: ' || 'Multiple sourcing defined for this item in this org...Supply will be created by planning. ',1);
                      END IF;
		      l_rows_errored := l_rows_errored + 1;
		      goto end_of_loop;
                    END IF;

                  END IF; --l_can_create_supply

                ELSIF l_x_return_status = FND_API.G_RET_STS_ERROR THEN
                    IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('get_order_lines: ' || 'Expected error occurred in Query_sourcing_org...',1);
                    END IF;
		    l_rows_errored := l_rows_errored + 1;
		    -- we do not want to raise error here, since we want to process remaining lines
		    goto end_of_loop;

                ELSIF l_x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  IF PG_DEBUG <> 0 THEN
                  	oe_debug_pub.add('get_order_lines: ' || 'Unexpected error occurred in Query_sourcing_org procedure...',1);
                  END IF;
		  l_rows_errored := l_rows_errored + 1;
		  -- we do not want to raise error here, since we want to process remaining lines
		  goto end_of_loop;
                END IF;

              IF l_can_create_supply = 'Y' THEN --as part of OPM enhancement
                if nvl(l_source_type,1) = 3
   		then
                	IF PG_DEBUG <> 0 THEN
                		oe_debug_pub.add('get_order_lines: ' || 'It is a BUY configuration Need not process this...',1);
                	END IF;
			l_rows_selected := l_rows_selected - 1;

                -- Start 2681321: if the source type is TRANSFER FROM, we should not create a workorder

		elsif nvl(l_source_type,2) = 1 then
		       IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('TRANSFER FROM sourcing rule exists. Work order need not be created.',1);
		       END IF;
			l_rows_selected := l_rows_selected - 1;

		-- End 2681321
                else

			l_stmt_num := 4;
			--Bugfix 9319883: Commenting the IF condition.
			--The sequence will be generated just before calling insert_wip_interface.
			/*
			if (l_rows_selected - l_rows_errored = 1) then
                	   select wip_job_schedule_interface_s.nextval
                	   into   x_wip_seq
                	   from   dual;
            		end if;
			*/

           	        IF PG_DEBUG <> 0 THEN
           	        	OE_DEBUG_PUB.add('get_order_lines: ' || 'Get_Order_lines: ' ||
                             ' Procesing Order Line ' ||
                             to_char(WorkOrder_Rec.line_id), 2);
           	        END IF;


			l_stmt_num := 5;

          		/* bugfix 4051282: check for activity hold and generic hold */
           		OE_HOLDS_PUB.Check_Holds(p_api_version   => 1.0,
                                    p_line_id       => WorkOrder_Rec.line_id,
                                    p_wf_item       => 'OEOL',
                                    p_wf_activity   => 'CREATE_SUPPLY',
                                    x_result_out    => l_x_hold_result_out,
                                    x_return_status => l_x_return_status,
                                    x_msg_count     => l_x_error_msg_count,
                                    x_msg_data      => l_x_error_msg);

           		if (l_x_return_status <> FND_API.G_RET_STS_SUCCESS) then

               			IF PG_DEBUG <> 0 THEN
               				OE_DEBUG_PUB.add('get_order_lines: ' || 'FAILED in Hold Check: ' || l_x_return_status ||
                                 	' For Order Line '  || to_char(WorkOrder_Rec.line_id), 1);

               				OE_DEBUG_PUB.add('get_order_lines: ' || 'Continuing with next line..',3);
               			END IF;
           		else

               			IF PG_DEBUG <> 0 THEN
               				OE_DEBUG_PUB.add('get_order_lines: ' || 'Success in Hold Check: ' || l_x_return_status ||
                                 	' For Order Line '  || to_char(WorkOrder_Rec.line_id), 1);
               			END IF;

               			if (l_x_hold_result_out = FND_API.G_TRUE) then

                   		     IF PG_DEBUG <> 0 THEN
                   		     	OE_DEBUG_PUB.add('get_order_lines: ' || 'Hold Found on order line ' || to_char(WorkOrder_Rec.line_id), 1);

               			     	OE_DEBUG_PUB.add('get_order_lines: ' || 'Continuing with next line..',3);
               			     END IF;

                   		     l_rows_on_hold := l_rows_on_hold + 1;

               			else

				/* If Departure Planning is required, check if deliveries have been assigned and planned */

			    	     BEGIN
					IF PG_DEBUG <> 0 THEN
						OE_DEBUG_PUB.add('get_order_lines: ' || 'before dep plan',1);
					END IF;

					l_stmt_num := 6;

					select nvl(oel.dep_plan_required_flag,'N')
					into l_dep_plan_flag
					from oe_order_lines_all oel
					where oel.line_id = WorkOrder_Rec.line_id;

					IF PG_DEBUG <> 0 THEN
						OE_DEBUG_PUB.add('get_order_lines: ' || 'l_dep_plan_flag::'||l_dep_plan_flag, 2);
					END IF;

					if l_dep_plan_flag = 'Y' then

						l_stmt_num := 7;

						--
						-- For partially reserved sales orders, we will
						-- still check if the order line is Delivery
						-- Planned for the entire quantity
						--
				    		CTO_WIP_UTIL.Delivery_Planned(
							p_line_id 	=> WorkOrder_Rec.line_id,
							x_result_out 	=> l_x_result_out,
							x_return_status => l_x_return_status,
							x_msg_count 	=> l_x_msg_count,
							x_msg_data 	=> l_x_msg_data);

				    		if (l_x_return_status =  FND_API.G_RET_STS_ERROR) then
               				    	    IF PG_DEBUG <> 0 THEN
               				    	    	OE_DEBUG_PUB.add('get_order_lines: ' ||
							'Expected error in Delivery_Planned: '
							|| l_x_return_status
							|| ' For Order Line '
							||to_char(WorkOrder_Rec.line_id), 1);
               				    	    END IF;
					    	    raise FND_API.G_EXC_ERROR;

				    		elsif (l_x_return_status =  FND_API.G_RET_STS_UNEXP_ERROR) then
               				    	    IF PG_DEBUG <> 0 THEN
               				    	    	OE_DEBUG_PUB.add('get_order_lines: ' ||
							'UnExpected error in Delivery_Planned: '
							|| l_x_return_status
							|| ' For Order Line '
							||to_char(WorkOrder_Rec.line_id), 1);
               				    	    END IF;
					    	    raise FND_API.G_EXC_UNEXPECTED_ERROR;

           			        	else
               				    	    IF PG_DEBUG <> 0 THEN
               				    	    	OE_DEBUG_PUB.add('get_order_lines: ' ||
							'Success in Delivery_Planned: '
							|| l_x_return_status
							|| ' For Order Line '
							||to_char(WorkOrder_Rec.line_id), 1);
               				    	    END IF;

               				    	    if (l_x_result_out = FND_API.G_FALSE) then
                   					IF PG_DEBUG <> 0 THEN
                   						OE_DEBUG_PUB.add('get_order_lines: ' ||
						  	'Order line not delivery planned'
						  	||to_char(WorkOrder_Rec.line_id), 1);
                   					END IF;

							l_rows_dep_plan := l_rows_dep_plan+1;
							raise NOT_PLANNED;
					    	    end if;
				       		end if;
					end if; /* dep_plan_flag = Y */

					l_stmt_num := 8;

					--Bugfix 9319883: Moved the sequence generation logic here.
					if x_wip_seq = -1 then
                                          select wip_job_schedule_interface_s.nextval
                                          into   x_wip_seq
                                          from   dual;
                                        end if;

					CTO_WIP_UTIL.insert_wip_interface(
						     p_line_id			=> WorkOrder_Rec.line_id,
                                               	     p_wip_seq			=> x_wip_seq,
                                                     p_status_type		=> p_status_type,
                                                     p_class_code		=> p_class_code,
                                                     p_conc_request_id		=> p_conc_request_id,
                                                     p_conc_program_id		=> p_conc_program_id,
                                                     p_conc_login_id		=> p_conc_login_id,
                                                     p_user_id			=> p_user_id,
                                                     p_appl_conc_program_id	=> p_appl_conc_program_id,
                                                     x_return_status		=> l_x_return_status,
                                                     x_error_message		=> l_x_error_message,
                                                     x_message_name		=> l_x_message_name);

                   			if (l_x_return_status <> FND_API.G_RET_STS_SUCCESS) then
					-- We dont want to raise error here, since we want to process other lines.

                       				IF PG_DEBUG <> 0 THEN
                       					oe_debug_pub.add('get_order_lines: ' ||  'Insert Error Message: ' || l_x_error_message,1);

                       					OE_DEBUG_PUB.add('get_order_lines: ' || 'FAILED in Insert WIP Interface: ' || l_x_return_status ||
                                 			'For Order Line '  || to_char(WorkOrder_Rec.line_id), 1);
                       				END IF;

                   			else

                      				IF PG_DEBUG <> 0 THEN
                      					OE_DEBUG_PUB.add('get_order_lines: ' || 'Success in Insert WIP Interface: ' || l_x_return_status ||
                                 			'For Order Line '  || to_char(WorkOrder_Rec.line_id), 1);
                      				END IF;

                      				l_rows_inserted := l_rows_inserted + 1;

                   			end if; /* end of insert into wip_job_schedule_interface*/

			     	     EXCEPTION
				   	when NOT_PLANNED then
				       		IF PG_DEBUG <> 0 THEN
				       			OE_DEBUG_PUB.add('get_order_lines: ' || 'Deliveries not planned, not inserting into wjsi', 2);
				       		END IF;

			     	     END; /*sub-block for delivery planned lines*/

                		end if; /* end of l_x_hold_result_out = TRUE */

            		end if;  /* end of hold return status = success */

                end if; /* End of Buy sourcing check l_source_type = 3 */

	      END IF;--l_can_create_supply

	<< end_of_loop>>
		null;
        end loop;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('get_order_lines: ' || '****************************************', 5);

        	OE_DEBUG_PUB.add('get_order_lines: ' || 'Number of Order Lines Selected: ' ||
                          to_char(l_rows_selected), 1);

        	OE_DEBUG_PUB.add('get_order_lines: ' || 'Number of Rows on Hold: ' ||
                          to_char(l_rows_on_hold), 1);

        	OE_DEBUG_PUB.add('get_order_lines: ' || 'Number of Rows not Departure Planned: ' ||
                          to_char(l_rows_dep_plan), 1);

        	OE_DEBUG_PUB.add('get_order_lines: ' || 'Number of Rows in error: ' ||
                          to_char(l_rows_errored), 1);

        	OE_DEBUG_PUB.add('get_order_lines: ' || 'Number of Order Lines Inserted: ' ||
                          to_char(l_rows_inserted), 1);

        	OE_DEBUG_PUB.add('get_order_lines: ' || 'WIP Group ID: ' ||
                           to_char(x_wip_seq), 1);

        	oe_debug_pub.add('get_order_lines: ' || '****************************************', 5);
        END IF;

        x_orders_loaded := l_rows_inserted;

        -- Begin Bugfix 2019487:
        --       If run thru SO pad (progress order), the cursor should pick that record for progressing.
        --       If not, return FAILURE. If we dont return FAILURE, the WF will end normal and
        --       move to Ship Line Notified without creating work-order and reservations.
        --       This could happen if this line was picked by FAS earlier but was terminated  (as in PAXAR's case)
        --       Also, if insert into wip_job_schedule_interface fails for this order line, we will error out.



	if (l_line_id is not null AND x_orders_loaded = 0) then

		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add ('get_order_lines: ' || 'CTOWIPWB.get_order_lines: Line '||l_line_id||
				' is NOT eligible for Autocreate FAS anymore.',1);
		END IF;

		-- Try to get the job info if it was created..
 		declare
		  l_job_name 		wip_entities.wip_entity_name%type;
		  l_wip_entity_id	wip_entities.wip_entity_id%type;
		begin

		  l_stmt_num := 9;

		  select  dj.wip_entity_id,  we.wip_entity_name
		  into    l_wip_entity_id, l_job_name
		  from    wip_discrete_jobs dj, wip_entities we,
		          oe_order_lines_all oel
		  where   dj.wip_entity_id = we.wip_entity_id
		  and     dj.source_line_id = l_line_id
		  and	  dj.source_code = 'WICDOL'
		  --bugfix 2885568 to remove full table scan on wip_discrete_jobs
		  --use unique index of wip_enitity _id and organization_id
		  and     oel.line_id = l_line_id
		  and     dj.primary_item_id = oel.inventory_item_id --for using index wdj_N1
		  and     oel.ship_from_org_id = dj.organization_id ;--for using index wdj_u1
                  --end bugfix 2885568

		  IF PG_DEBUG <> 0 THEN
		  	oe_debug_pub.add ('get_order_lines: ' || 'Info:  A WIP job ( '||l_job_name||' ) was created for this line already.',1);
		  END IF;

		exception
		  when no_data_found then
		        IF PG_DEBUG <> 0 THEN
		        	oe_debug_pub.add ('get_order_lines: ' || 'Could not find a WIP job. Records probably stuck in wip job schedule interface.',1);
		        END IF;

		  when others then
		        IF PG_DEBUG <> 0 THEN
		        	oe_debug_pub.add ('get_order_lines: ' || 'Error while fetching the WIP job. : '||substr(sqlerrm,1,200),1);

		        	oe_debug_pub.add ('get_order_lines: ' || 'Continuing..',1);
		        END IF;
		end;
		--return 0;		-- bugfix 2105156: no need to return an error
	end if;
	-- End Bugfix 2019487:
        return 1;

EXCEPTION
        -- bugfix 2053360 : handle the record_locked exception.

        WHEN record_locked THEN
           IF PG_DEBUG <> 0 THEN
           	OE_DEBUG_PUB.add ('get_order_lines: ' || 'Could not lock line id '|| to_char(p_line_id) ||' for update.',1);

           	OE_DEBUG_PUB.add ('get_order_lines: ' || 'This line is being processed by another process.',1);
           END IF;
	    unlock_line_id (p_line_id); 		-- bugfix 3136206
	   return 1;	-- return success otherwise, w/f will be in retry mode !	--bugfix 2105156


	WHEN FND_API.G_EXC_ERROR THEN
           IF PG_DEBUG <> 0 THEN
           	OE_DEBUG_PUB.add('get_order_lines: ' || 'Expected Error in CTOWIPWB.get_order_lines (stmt: '||l_stmt_num||')' ,1);
           END IF;
	   unlock_line_id (p_line_id); 		-- bugfix 3136206
           return 1;	-- should not error out in case of excpected error

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           IF PG_DEBUG <> 0 THEN
           	OE_DEBUG_PUB.add('get_order_lines: ' || 'Unxpected Error in CTOWIPWB.get_order_lines (stmt: '||l_stmt_num||')' ,1);
           END IF;
	   unlock_line_id (p_line_id); 		-- bugfix 3136206
           return 0;

	WHEN NO_DATA_FOUND THEN
           IF PG_DEBUG <> 0 THEN
           	OE_DEBUG_PUB.add('get_order_lines: ' || 'CTOWIPWB.get_order_lines :: No Rows Found.',1);
           END IF;
           -- bugfix 2420381: commented out the re-initialization of x_orders_loaded.
	   -- x_orders_loaded := 0;
	   unlock_line_id (p_line_id); 		-- bugfix 3136206
           return 1;


        WHEN OTHERS THEN
           IF PG_DEBUG <> 0 THEN
           	OE_DEBUG_PUB.add('get_order_lines: ' || 'Error in CTOWIPWB.get_order_lines (stmt: '||l_stmt_num||'):'||
                             substrb(sqlerrm, 1, 150),1);
           END IF;
	   unlock_line_id (p_line_id); 		-- bugfix 3136206
           return 0;


END get_order_lines;


/*****************************************************************************
   Procedure:  reserve_work_order
   Parameters:  p_model_line_id   - line id of the configuration item in
                                   oe_order_lines_all
                p_wip_seq - group id to be used in interface table
                x_error_message   - error message if insert fails
                x_message_name    - name of error message if insert
                                    fails

   Description:  This function inserts a record into the
                 WIP_JOB_SCHEDULE_INTERFACE table for the creation of
                 work orders.

*****************************************************************************/

FUNCTION reserve_wo_to_so(p_wip_seq IN NUMBER,
                          p_message_text VARCHAR2,
                          p_message_name VARCHAR2
)

RETURN integer


IS
--        WorkOrder_Rec            number;

        /* Reservation Variables */
        l_rec_reserve         CTO_RESERVE_CONFIG.rec_reserve;
        l_rsv_rec             inv_reservation_global.mtl_reservation_rec_type;
        l_dummy_sn  	      inv_reservation_global.serial_number_tbl_type;
        l_rsrv_qty            number := 0;
        l_rsrv_id             number;
        l_status              varchar2(1);
        l_activity_status     varchar2(8);
        l_status_type         number;

        l_err_num             number;
        l_msg_txt             varchar(240);
        l_msg_name            varchar(30);
        l_msg_count           number;
        l_stmt_num            number;
	lSourceCode	      varchar2(30);

	-- begin bugfix 3014000
	lOperUnit	      number;
	l_client_org_id	      number;
	xUserId		      number;
	xRespId		      number;
	xRespApplId	      number;
        l_x_return_status     varchar2(1);
        l_x_msg_count 	      number;
        l_x_msg_data	      varchar2(2000);
	-- end bugfix 3014000

        lLineId		      number;		-- bugfix 3136206
	resv_counter	      number := 0;	-- bugfix 3136206

	-- Bugfix 1661094: We will use the inventory API to convert wei.start_quantity, which is in
	-- primary UOM back to ordered UOM. Otherwise we will be passing primary_quantity and ordered UOM.
	-- eg. If ordered_quantity was 1 and ordered_uom was 'DZ', then,
	--     wei.start_quanity will be 12 (if primary_uom  is 'EA').
	-- Without converting, we will be passing 12 and 'DZ' which is incorrect.

        /* Cursor to select records to reserve */

        cursor c_wip_job_records is
        select mso.sales_order_id,
               oel.line_id,
               oel.ship_from_org_id,
               oel.inventory_item_id,
               oel.order_quantity_uom,
               --oel.ordered_quantity,
               oel.source_document_type_id,	-- bugfix 1799874: to check if it is an internal SO or regular
               INV_CONVERT.inv_um_convert	-- bugfix 1661094: added conversion logic
                   (oel.inventory_item_id,
                    5,	-- bugfix 2204376: pass precision of 5
                    wei.start_quantity,
                    msi.primary_uom_code,
                    oel.order_quantity_uom,
                    null,
                    null)   start_quantity,
               inv_reservation_global.g_source_type_wip,
               wei.wip_entity_id,
               oel.schedule_ship_date,
               -- Passing revision info only if revision_qty_control_code
               -- is not equal to 1
               -- wei.bom_revision
               -- 2620282: Selecting bom revision info
               decode( nvl(msi.revision_qty_control_code , 1 ) , 1, NULL , wei.bom_revision) bom_revision,
	       oel.org_id	-- bugfix 3014000
        from   wip_job_schedule_interface wei,
               oe_order_lines_all oel,
               mtl_sales_orders mso,
               oe_order_headers_all oeh,
               --oe_order_types_v oet
	       oe_transaction_types_tl oet,
	       mtl_system_items msi		-- bugfix 1661094:
        where  wei.group_id = p_wip_seq
        and    wei.source_line_id = oel.line_id
        and    oeh.header_id = oel.header_id
        and    oet.transaction_type_id = oeh.order_type_id
        and    mso.segment1 = to_char(oeh.order_number)
        and    mso.segment2 = oet.name
 	and    oet.language = (select language_code
				from fnd_languages
				where installed_flag = 'B')
        and    mso.segment3 = lSourceCode
        and    wei.load_type = WIP_CONSTANTS.CREATE_JOB
        and    wei.organization_id = oel.ship_from_org_id
        and    wei.process_phase = WIP_CONSTANTS.ML_COMPLETE
        -- bug 9314772.added warning status jobs for creating reservations.pdube
        -- and    wei.process_status = WIP_CONSTANTS.COMPLETED              -- 3202934
	and    wei.process_status IN (WIP_CONSTANTS.COMPLETED,WIP_CONSTANTS.WARNING)
	and    msi.inventory_item_id = oel.inventory_item_id
	and    msi.organization_id = oel.ship_from_org_id;

BEGIN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('reserve_wo_to_so: ' ||  'Beginning Reservation Loop.',1);
        END IF;
	lSourceCode := fnd_profile.value('ONT_SOURCE_CODE');
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('reserve_wo_to_so: ' ||  'lSourceCode: ' ||lSourceCode,2);
	END IF;

	-- begin bugfix 3014000

        -- Change for MOAC
	lOperUnit := nvl(MO_GLOBAL.get_current_org_id,-99);
        -- End of MOAC change
	IF PG_DEBUG <> 0 THEN
           oe_debug_pub.add('reserve_wo_to_so: '|| 'MO:operating Unit :' || lOperUnit, 2);
	END IF;

	-- end bugfix 3014000

        for WorkOrder_Rec in c_wip_job_records loop

	        resv_counter := resv_counter + 1;	-- bugfix 3136206
	        lLineId := WorkOrder_Rec.line_id;	-- bugfix 3136206

		-- begin bugfix 3014000
         	if ( lOperUnit <> WorkOrder_Rec.org_id) then
			--
			-- Bugfix 3104000: When called from WF, there's no need to set the context since
			--                 its already set by workflow.
			--                 When called from SRS, set the context only when ORG_ID is different
			--		   from OEL.org_id.
			-- Caveat: Single org customers should NOT set the MO:Operating unit for the resp
			--         which is used to run autocreate FAS. If so, OM will defer the activity.

	    		IF PG_DEBUG <> 0 THEN
        		   oe_debug_pub.add('reserve_wo_to_so: '|| 'Setting the Org Context again to '||WorkOrder_Rec.org_id ||
					 ' by calling OE_Order_Context_GRP.Set_Created_By_Context.', 5);
	    		END IF;

	     		OE_Order_Context_GRP.Set_Created_By_Context (
					 p_header_id		=> NULL
					,p_line_id		=> WorkOrder_Rec.line_id
					,x_orig_user_id         => xUserId
					,x_orig_resp_id         => xRespId
					,x_orig_resp_appl_id    => xRespApplId
					,x_return_status        => l_x_return_status
					,x_msg_count            => l_x_msg_count
					,x_msg_data             => l_x_msg_data );

  			if    l_x_return_status = FND_API.G_RET_STS_ERROR THEN
     				oe_debug_pub.add('reserve_wo_to_so: '|| 'Expected Error in Set_Created_By_Context.');
     				raise FND_API.G_EXC_ERROR;

  			elsif l_x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     				oe_debug_pub.add('reserve_wo_to_so: '|| 'UnExpected Error in Set_Created_By_Context.');
     				raise FND_API.G_EXC_UNEXPECTED_ERROR;

  			end if;

         	else
	    		IF PG_DEBUG <> 0 THEN
        		    oe_debug_pub.add('reserve_wo_to_so: '|| 'NOT Setting the Org Context since MO:Operating Unit = OEL.org_id.', 5);
	    		END IF;
         	end if;

		lOperUnit := WorkOrder_Rec.org_id;	-- OE api will set the mo oper unit in cache.
						-- Instead of again querying up profile, we can safely use WorkOrder_Rec.org_id

		-- end bugfix 3014000

	    IF PG_DEBUG <> 0 THEN
	    	oe_debug_pub.add('reserve_wo_to_so: ' ||  'ss::in loop::qty::'||WorkOrder_Rec.start_quantity,2);
	    END IF;

            l_rec_reserve.f_header_id 			:= WorkOrder_Rec.sales_order_id;
            l_rec_reserve.f_line_id 			:= WorkOrder_Rec.line_id;
            l_rec_reserve.f_mfg_org_id 			:= WorkOrder_Rec.ship_from_org_id;
            l_rec_reserve.f_item_id 			:= WorkOrder_Rec.inventory_item_id;
            l_rec_reserve.f_order_qty_uom 		:= WorkOrder_Rec.order_quantity_uom;
            --l_rec_reserve.f_quantity 			:= WorkOrder_Rec.ordered_quantity;
	    l_rec_reserve.f_quantity 			:= WorkOrder_Rec.start_quantity;
            l_rec_reserve.f_supply_source 		:= inv_reservation_global.g_source_type_wip;
            l_rec_reserve.f_supply_header_id 		:= WorkOrder_Rec.wip_entity_id;
            l_rec_reserve.f_ship_date 			:= WorkOrder_Rec.schedule_ship_date;
            l_rec_reserve.f_source_document_type_id 	:= WorkOrder_Rec.source_document_type_id;	-- bugfix 1799874
	    l_rec_reserve.f_bom_revision		:= WorkOrder_Rec.bom_revision; 		-- 2620282 : Passing bom revision info

           /*----------------------------------------------------------+
            Reserve the sales order against the work order.
            If reservation is unsuccessful, purge discrete jobs created.
            +----------------------------------------------------------*/

           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('reserve_wo_to_so: ' ||  'Reserving Line ID ' ||
                                        to_char(WorkOrder_Rec.line_id) ||
                                        'to WIP Entitiy ID ' ||
                                        to_char(WorkOrder_Rec.wip_entity_id),2);
           END IF;


           CTO_RESERVE_CONFIG.reserve_config(
				p_rec_reserve	=> l_rec_reserve,
                                x_rsrv_qty	=> l_rsrv_qty,
                                x_rsrv_id	=> l_rsrv_id,
                                x_return_status	=> l_status,
                                x_msg_txt	=> l_msg_txt,
                                x_msg_name	=> l_msg_name );

           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('reserve_wo_to_so: ' ||  'Reservation Result: ' || l_status,1);

           	oe_debug_pub.add('reserve_wo_to_so: ' ||  'Reservation Msg: ' || l_msg_txt,1);
           END IF;

           if (l_status <> FND_API.G_RET_STS_SUCCESS) then
                /*---------------------------------------------------+
                   Reservation unsuccessful.  We had originally discussed
                   purging the work order if reservation failed, but
                   Biju Baby had explained that there were accounting
                   periods that had to be considered if we did that, which
                   made the process too complicated.  Instead, we will
                   cancel the work order created.
                 +---------------------------------------------------*/
                  IF PG_DEBUG <> 0 THEN
                  	oe_debug_pub.add('reserve_wo_to_so: ' ||
                                'Reservation FAILED for line id ' ||
                                     to_char(WorkOrder_Rec.line_id) ||
                                     ' and WIP Entity ID: ' ||
                                     to_char(WorkOrder_Rec.wip_entity_id) ||
                                     '.',1);

                  	oe_debug_pub.add('reserve_wo_to_so: ' || 'Message Text = '||l_msg_txt,1);
                  END IF;

                   l_stmt_num := 100;
                   update wip_discrete_jobs
                   set    status_type = 7	-- CANCELLED
                   where  wip_entity_id = WorkOrder_Rec.wip_entity_id;

                   l_stmt_num := 110;
                   update wip_job_schedule_interface
                   set    process_phase = WIP_CONSTANTS.ML_VALIDATION,
                          process_status = WIP_CONSTANTS.RUNNING
                   where  wip_entity_id = WorkOrder_Rec.wip_entity_id
                   and    group_id = p_wip_seq;

            else
               /*--------------------------------------------------+
                 This is the equivalent of the feedback loop in 11.0.
                 If the order is placed on hold during AutoCreate FAS,
                 WIP will put the corresponding work order on hold.
               +--------------------------------------------------*/
               IF PG_DEBUG <> 0 THEN
               	oe_debug_pub.add('reserve_wo_to_so: ' ||
                                'Reservation Success for line id ' ||
                                 to_char(WorkOrder_Rec.line_id) ||
                                ' and WIP Entity ID: ' ||
                                 to_char(WorkOrder_Rec.wip_entity_id) ||
                                  '.',1);
               END IF;
               BEGIN

               l_stmt_num := 115;
               select status_type
               into   l_status_type
               from   wip_job_schedule_interface
               where  group_id = p_wip_seq
               and    source_line_id = WorkOrder_Rec.line_id
               and    last_update_date <> creation_date
               and    rownum = 1;

               if (l_status_type = 6) then	-- ON HOLD

                   WIP_SO_RESERVATIONS.respond_to_change_order(
                                    p_org_id	=> WorkOrder_Rec.ship_from_org_id,
                                    p_header_id	=> WorkOrder_Rec.sales_order_id,
                                    p_line_id	=> WorkOrder_Rec.line_id,
                                    x_status	=> l_status,
                                    x_msg_count	=> l_msg_count,
                                    x_msg_data	=> l_msg_txt);

                   IF PG_DEBUG <> 0 THEN
                   	oe_debug_pub.add('reserve_wo_to_so: ' ||  'Return Status from respond to change order ' || l_status,1);

                   	oe_debug_pub.add('reserve_wo_to_so: ' ||  'Message Txt from respond to change order: ' || l_msg_txt,2);
                   END IF;

                   if (l_status <> FND_API.G_RET_STS_SUCCESS) then

                       IF PG_DEBUG <> 0 THEN
                       	oe_debug_pub.add('reserve_wo_to_so: ' ||
                             'Deleting Reservation for ' ||
                             'line ID: ' ||
                              to_char(WorkOrder_Rec.line_id) ||
                             'to WIP Entity ID ' ||
                              to_char(WorkOrder_Rec.wip_entity_id),2);
                       END IF;

                       l_rsv_rec.reservation_id := l_rsrv_id;

                       INV_RESERVATION_PUB.delete_reservation
                                (
                                p_api_version_number  => 1.0
                                , p_init_msg_lst      => fnd_api.g_true
                                , x_return_status     => l_status
                                , x_msg_count         => l_msg_count
                                , x_msg_data          => l_msg_txt
                                , p_rsv_rec           => l_rsv_rec
                                , p_serial_number     => l_dummy_sn
                                );

                       IF PG_DEBUG <> 0 THEN
                       	oe_debug_pub.add('reserve_wo_to_so: ' ||  'Return Status from delete reservation: ' || l_status,1);

                       	oe_debug_pub.add('reserve_wo_to_so: ' ||  'Msg Txt from delete reservation: ' || l_msg_txt,1);
                       END IF;

                       l_stmt_num := 130;
                       update wip_discrete_jobs
                       set    status_type = 7     -- CANCEL
                       where  wip_entity_id = WorkOrder_Rec.wip_entity_id;

                       l_stmt_num := 140;
                       update wip_job_schedule_interface
                       set    process_phase = WIP_CONSTANTS.ML_VALIDATION,
                              process_status = WIP_CONSTANTS.RUNNING
                       where  wip_entity_id = WorkOrder_Rec.wip_entity_id
                       and    group_id = p_wip_seq;

                   end if; /* respond to change order not successful */

               end if; /* status_type = 6 */

               EXCEPTION

               when NO_DATA_FOUND then

                    if (l_stmt_num <> 115) then
                        IF PG_DEBUG <> 0 THEN
                        	oe_debug_pub.add('reserve_wo_to_so: ' ||
                             'No data found in feedback loop. '
                             || 'Statement: ' || to_char(l_stmt_num)
                             || substrb(sqlerrm, 1, 150),1);
                        END IF;

                    end if;

               END;

            end if; /* reservation status not successful */

	   /* Bugfix 2105156 : Release the manual lock */
	   UPDATE oe_order_lines_all
	   SET    program_id = null
	   WHERE  line_id = WorkOrder_Rec.line_id
	   AND    program_id = -99;

        end loop; /* loop through wip job schedules for order line */

	-- begin bugfix 3136206
	if resv_counter = 0 then
		oe_debug_pub.add('Warning: No reservations made. Check for errors in WJSI');
		-- unlock the lines. Update the program_id to null.
		update oe_order_lines_all
		set    program_id = null
		where  program_id = -99
		and    line_id in (select wei.source_line_id
				   from   wip_job_schedule_interface wei
				   where  wei.group_id = p_wip_seq);
	end if;
	-- end bugfix 3136206

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('reserve_wo_to_so: ' ||  'End of Reservation',1);
        END IF;

        return 1;

EXCEPTION

--begin bugfix 3014000
    WHEN FND_API.G_EXC_ERROR THEN
           OE_DEBUG_PUB.add('reserve_wo_to_so: '|| 'Expected Error in CTOWIPWB.reserve_wo_to_so (stmt: '||l_stmt_num||')' );
	   unlock_line_id (lLineId); 		-- bugfix 3136206
           return 1;	-- should not error out in case of excpected error

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           OE_DEBUG_PUB.add('reserve_wo_to_so: '|| 'Unxpected Error in CTOWIPWB.reserve_wo_to_so (stmt: '||l_stmt_num||')' );
           unlock_line_id (lLineId); 		-- bugfix 3136206
	   return 0;

-- end bugfix 3014000

    when NO_DATA_FOUND then
           OE_DEBUG_PUB.ADD('reserve_wo_to_so: ' || 'Error in CTOWIPWB.reserve_wo_to_so: '
                             || 'Statement: ' || to_char(l_stmt_num)
                             || substrb(sqlerrm, 1, 150),1);
           unlock_line_id (lLineId); 		-- bugfix 3136206
	   return 0;

    when OTHERS then
        OE_DEBUG_PUB.add('reserve_wo_to_so: ' || 'Error in CTOWIPWB.reserve_wo_to_so: '
                             || substrb(sqlerrm, 1, 150),1);

        unlock_line_id (lLineId); 		-- bugfix 3136206
	return 0;

END reserve_wo_to_so;

/***********************************************************************************************
   Function: Get_Reserved_Qty

   Parameters:
                pLineId - Line id of order line being processed

   Description: This function is to support AutoCreate Supply for
		Partial Order Qty
		It returns the quantity for which supply has been created.
		Reserved Qty = Qty in mtl_reservations
				+ Qty in wip_job_schedule_interface
		In case of an error, 0 qty will be returned.

   Modified by :
 		Renga Kannan   	09/20/01 	removed the debug messages
		SBhaskaran 	11/02/01	Bugfix 2074290
						Note: All quantities here are in Primary UOM.
*************************************************************************************************/

FUNCTION Get_Reserved_Qty(pLineId IN NUMBER)
RETURN number

IS

	-- Cursor to get reserved qty
	cursor c_mtl_rsv_qty is

        -- bugfix 2074290: convert the reservation_quantity into primary UOM.
        -- Reservation_Quantity will not be in primary UOM in case of manual reservation.
        -- If the reservations are created by autocreate FAS, it will be in primary uom.

        select nvl(sum(INV_CONVERT.inv_um_convert
                           (oel.inventory_item_id,
                            5,	-- bugfix 2204376: pass precision of 5
                            mr.reservation_quantity,
                            mr.reservation_uom_code,
                            msi.primary_uom_code,
                            null,
                            null)),0)
	from   mtl_reservations mr,
		oe_order_headers_all oeh,
		oe_order_lines_all oel,
		mtl_system_items msi				--bugfix 2074290: added msi
	where  oel.line_id = pLineId
	and    oel.header_id = oeh.header_id
	and    mr.demand_source_line_id = oel.line_id
        and    mr.organization_id = oel.ship_from_org_id
	and    oel.inventory_item_id = msi.inventory_item_id	--bugfix 2074290: added joins
	and    oel.ship_from_org_id = msi.organization_id
	and    mr.demand_source_type_id = decode(oeh.source_document_type_id, 10,
						INV_RESERVATION_GLOBAL.g_source_type_internal_ord,
						INV_RESERVATION_GLOBAL.g_source_type_oe);	--bugfix 1799874


	-- Cursor to get qty in wip_job_schedule_interface
    -- This cursor was modified for bugs 2074290, 2435875, 2455900
    -- Bugfix 4254404: We should treat COMPLETED records as supply due to concurrency reasons.

	cursor c_wjsi_qty is
	select nvl(sum(wjs.start_quantity), 0)
	from   wip_job_schedule_interface wjs,
		oe_order_lines_all oel
	where  oel.line_id = pLineId
	and 	wjs.source_line_id = oel.line_id
        and    (wjs.process_status = WIP_CONSTANTS.PENDING
		or  wjs.process_status = WIP_CONSTANTS.RUNNING
        or  wjs.process_status = WIP_CONSTANTS.COMPLETED);

	/* begin bugfix 2868148 : This cursor calculates supply created by flow schedule.  */

	cursor flow_supply is
	select nvl(sum(planned_quantity - quantity_completed),0)	-- 2946071
	from   wip_flow_schedules
	where  demand_source_line = to_char(pLineId)
        and    demand_source_type = inv_reservation_global.g_source_type_oe;

	/* end bugfix 2868148 */

	l_mtl_rsv_qty	number := 0;
	l_wjsi_qty	number := 0;
	l_flow_qty	number := 0;		--bugfix 2868148
	l_reserved_qty	number := 0;
	lStmtNum	number := 0;

BEGIN

	--oe_debug_pub.add('Entering Get_Reserved_Qty', 6);

	lStmtNum := 10;
	OPEN c_mtl_rsv_qty;
	FETCH c_mtl_rsv_qty INTO l_mtl_rsv_qty;
	CLOSE c_mtl_rsv_qty;


	lStmtNum := 20;
	OPEN c_wjsi_qty;
	FETCH c_wjsi_qty INTO l_wjsi_qty;
	CLOSE c_wjsi_qty;


	lStmtNum := 30;

	-- begin bugfix 2868148

	lStmtNum := 30;
	OPEN flow_supply;
	FETCH flow_supply INTO l_flow_qty;
	CLOSE flow_supply;

	/**
	  In case of overcompletion  when
	  sum (planned_qty - quantity_completed) is < 0 ,
	  flow_qty will be returned as 0 to prevent extra
	  supply creation with discrete jobs.
	**/

	if l_flow_qty < 0 then	/* planned_qty - qty_completed can be less than 0 in case of over-compl*/
	  l_flow_qty := 0;
	end if;


	l_reserved_qty := l_mtl_rsv_qty + l_wjsi_qty + l_flow_qty;


	-- end bugfix 2868148


	return(l_reserved_qty);

EXCEPTION
	WHEN others THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Get_Reserved_Qty: ' || 'Others exception in Get_Reserved_Qty::'||to_char(lStmtNum)||'::'||sqlerrm, 1);
		END IF;
		unlock_line_id (pLineId); 		-- bugfix 3136206
		return(0);

END Get_Reserved_Qty;


-- begin bugfix 2095043
/*****************************************************************************
   Function        	: GET_NOTINV_QTY
   Parameters		: pLineId - Line id of order line being processed

   Description		:
	If shipping_interfaced flag is 'Y', then, return OQ in primary UOM.

	If shipping_interfaced flag is 'N', then, loop thru wsh_delivery_detail
	to find out how much has been NOT been inventory-interfaced.
	If it fails to find a record in WDD, return 0.

	All quantities are in primary UOM.

*****************************************************************************/

FUNCTION Get_NotInv_Qty(pLineId IN NUMBER)
RETURN number
IS
	l_quantity	NUMBER;	/* in primary UOM */

BEGIN
	-- If shipping_interfaced_flag is 'N', it means WDD is not populated.
	-- Pick ordered_quantity (in primary UOM) from OEOL in that case.
	--
	-- If shipping_interfaced_flag is 'Y', it means WDD is populated.
	-- Sum the requested_quantity in WDD for which inv interface is NOT run.
	-- If it returns null, all of them has been interfaced to inventory.
	-- Return 0 in that case.
	--
	-- Note : Requested_Quantity in WDD is in primary UOM

	select  decode( max(shipping_interfaced_flag),
			'N', max(INV_CONVERT.inv_um_convert
                        		(oel.inventory_item_id,
                                        5,	-- bugfix 2204376: pass precision of 5
                         		oel.ordered_quantity,
                         		oel.order_quantity_uom,
                         		msi.primary_uom_code,
                         		null,
                         		null)),
			'Y', nvl(sum(wdd.requested_quantity), 0)  )
	into    l_quantity
	from	WSH_DELIVERY_DETAILS_OB_GRP_V wdd,
		oe_order_lines_all oel,
		mtl_system_items msi
	where   oel.line_id = pLineId
	and	oel.inventory_item_id = msi.inventory_item_id
	and	oel.ship_from_org_id = msi.organization_id
	and     wdd.source_line_id(+) = oel.line_id
	and     wdd.source_code(+) = 'OE'
	and	nvl(wdd.inv_interfaced_flag(+),'N') = 'N'
	and     nvl(released_status(+),'N') <> 'D';

	return (l_quantity);

EXCEPTION
	when OTHERS then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Get_NotInv_Qty: ' || 'Others exception in Get_NotInv_Qty::'||sqlerrm, 1);
		END IF;
		unlock_line_id (pLineId); 		-- bugfix 3136206
		return(0);
END Get_NotInv_Qty;
-- end bugfix 2095043


end CTO_WIP_WRAPPER;

/
