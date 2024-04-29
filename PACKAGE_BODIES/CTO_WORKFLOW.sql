--------------------------------------------------------
--  DDL for Package Body CTO_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_WORKFLOW" as
/* $Header: CTOWKFLB.pls 120.13.12010000.6 2010/07/21 08:05:55 abhissri ship $ */

/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : CTOWKFLB.pls                                                  |
| DESCRIPTION :                                                               |
|                     create_config_item_wf( )                                |
|                     check_reservation_status_wf( )                          |
|                     create_bom_and_routing_wf( )                            |
|                     calculate_cost_rollup_wf( )                             |
|                     calculate_cost_rollup_wf_ml( )                          |
|                     set_parameter_lead_time_wf_ml( )                           |
|           	      set_parameter_lead_time_wf_ml()                         |
|                     check_supply_type_wf(  )                                |
|                     set_parameter_work_order_wf( )                          |
|                     submit_conc_prog_wf( )                                  |
|                     submit_and_continue_wf( )                               |
|                     validate_line ( )                                       |
|                     validate_config_line( )                                 |
|                     config_line_exists ( )                                  |
|                     reservation_exists( )                                   |
|                     check_inv_rsv_exists( )                                 |
|                     flow_sch_exists( )                                      |
|                     rsv_before_booking_wf( )                                |
|                                                                             |
|                                                                             |
| HISTORY     : 03/26/99      Initial Version                                 |
|               12/14/00      Renga Kannan, Create_config_item_wf is          |
|                             fixed to handle link_item also. This is part    |
|                             bug fix for bug#  1381938                       |
|                                                                             |
|               06/26/01      Sushant fixed bug 1853597. query should retrieve|
|                             only one row                                    |
|                                                                             |
|                07/12/01       Kiran Konada ,fix for bug#1861812             |
|                               logic added to rsv_before_booking_wf so that  |
|                               it gets executed only for ato item            |
|                               NOTE: oexwford.wft also changed for this fix  |
|                               This fix has actually been provided in        |
|                               branched code 115.57.1155.3                   |
|                                                                             |
|                07/18/01       Shashi Bhaskaran, bugfix 1799874              |
|                               Modified code to fix demand_source_type for   |
|                               internal orders.			      |
|                                                                             |
|                08/16/2001     Kiran Konada, fix for bug#1874380             |
|                               to support ATO item under a PTO.              |
|                               item_type_code for an ato item under PTO      |
|                                is 'OPTION' and top_model_line_id will NOT be|
|                                null, UNLIKE an ato item order, where        |
|				item_type_code = 'Standard' and               |
|				top_model_lined_id is null                    |
|                                This fix has actually been provided in       |
|                                branched code  115.57.1155.5                 |
|                                                                             |
|                                                                             |
|                08/29/01       Modified check_supply_type_wf                 |
|                               For procuring configuration                   |
|                                                                             |
|               Sep 26, 01   Shashi Bhaskaran   Fixed bug 2017099             |
|                            Check with ordered_quantity(OQ) instead of OQ-CQ |
|                            where CQ=cancelled_quantity. When a line is      |
|                            is canceled, OQ gets reflected.                  |
|									      |
|                11/16/2001  bugfix#2111718                                   |
|                             added the check for ato item in proceudre       |
|                            validate_config_line( ). Ato item with flow      |
|                            routing was erroing out in this procedure        |
|                                                                             |
|                03/08/2002  bugfix#2234858                                   |
|                            added new functionality to support DROP SHIP     |
|                                                                             |
|                03/22/2002  bugfix#2234858                                   |
|                            removed dependency on schedule status code       |
|                            and visible demand flag for external source type |
|                            items to support DROP SHIP                       |
|                                                                             |
|                03/22/2002  bugfix#2313475 ( 2286525 in br )                 |
|                            Replace top_model_line_id with ato_line_id       |
|                04/18/2002  bugfix 2320488                                   |
|                            replace org_id in message with org_name          |
|                                                                             |
|                05/03/2002  bugfix#2342412                                   |
|                            error message needs to be displayed in case of   |
|                            reservation error.
|
|                 06/04/02    bugfix2327972--Kiran Konada
|                             added a new function node which calls procedure
|                             chk_rsv_after_afas_wf
|                             This nodes checks if any type of reservation
|                             exists. Node has been added in warning path after
|                             autocreate fas node
|
|                 10/31/02    Sushant Sawant
|                             Added Enhanced costing functionality for matched items
|
|                 11/03/2003   Kiran Konada
|                             added a call to Update_Flow_Status_Code in check_supply_
|                              creation_wf
|
|		  11/04/2003   Kiran Konada
|                             added a call to display_wf_status instead of
|                             Update_Flow_Status_Code in check_supply_
|                              creation_wf
|
|                 11/14/2003    Kiran Konada
|                            removed procedu set_parameter_lead_time_wf
|                            bcos of bug#3202825
|
|
|
|                 12/11/03    Sushant Sawant
|                             removed update_flow_status_code calls in create_config_item_wf
|                             and added display_wf_status
|
|
|                 01/19/04    Sushant Sawant
|                             Fixed Bug 3380730, 3380874 to provide proper status code on config line
|                             and corrected use of cto_workflow_api_pk.display_wf_status
|
|
|                 01/23/04    Sushant Sawant
|                             Fixed Bug 3388135 to provide message for match in case of dropship models.
|
|                02/23/2004  Sushant Sawant fixed Bug 3419221
|                            New LINE_FLOW_STATUS code 'SUPPLY_ELIGIBLE' was introduced.
|                            Config Lines with Internal and External source types will be assigned this status.
|                            when the config line reached check supply creation workflow activity.
|
|
|                03/01/2004  Kiran Konada
|                            Bugfix 2318060
|                            'N' value to BUILD_IN_WIP_FLAG is caught as expected error
|                            when workflow moves through set_parameter_work_order node
|
|
|                04/06/2004  KKONADA   removed fullstop after BOM , bugfix#3554874
|
|                05/10/2004  Sushant Sawant
|                            fixed bug 3548069 in procedure validate_line.
|                            model lines with schedule ship date null should not
|                            be picked for config creation.
|
|               04/04/2005   Renga Kannan
|                            Fixed bug 4197665 in procedure check_supply_type_wf
|                            The to_char function had a wrong parameter in it.
|                            It was erroring out only in 10G instance. Fixed it.
|
|
|              06/01/2005    Renga Kannan
|
|                            Added nocopy Hint to all out parameters.
|
|
|
|              06/16/2005   Kiran Konada :
|			    chnaged for OPM project
|			    change comment : OPM
|		            check_supply_type:
|				check for p_source_type in (1,66) is replaced by
|				l_can_create_supply = N
|				check_cto_can_create_supply new parameters l_sourcing_org
|				and l_message
|
|			    check_supply_creation api
|				check_cto_can_create_supply new parameters l_sourcing_org
|				and l_message
|
|
|           07/05/2005     Renga Kannan
|                          Changed for MOAC project
|                          Code change for ONT RESERVATION TIME FENCE
|
|
|
|           18-AUG-2005    Kiran Konada
|                          bugfix#4556596
|                          when Check_supply_type_wf node detects that
|                          multiple sources are present workflow moves
|                          shipline. But there is no call to display_wf_status
|                          so line status remains at "supply eligible"
|                          Fix is to call display_wf_status
|
|
|
=============================================================================*/
G_PKG_NAME CONSTANT VARCHAR2(30) := 'CTO_WORKFLOW';


/*
procedure send_oid_notification ;


procedure get_planner_code( p_inventory_item_id   in	      number
                         , p_organization_id      in	      number
                         , x_planner_code         out  Nocopy fnd_user.user_name%type ) ;

procedure handle_expected_error( p_error_type           in number
                     , p_inventory_item_id    in number
                     , p_organization_id      in number
                     , p_line_id              in number
                     , p_sales_order_num      in number
                     , p_top_model_name       in number
                     , p_top_model_line_num   in varchar2
                     , p_top_config_name       in number default null
                     , p_top_config_line_num   in varchar2 default null
                     , p_msg_count            in number
                     , p_planner_code         in varchar2
                     , p_request_id           in varchar2
                     , p_process              in varchar2 ) ;

*/


/*============================================================================
        Procedure:    	create_config_item_wf
        Description:  	This API gets called from create configuration activity
			in "Create Configuration, Line Manual" process.

     	Parameters:
============================================================================*/
PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);

PROCEDURE create_config_item_wf(
        p_itemtype   in         VARCHAR2, /* internal name for the item type */
        p_itemkey    in         VARCHAR2, /* sales order line id             */
        p_actid      in         NUMBER,   /* ID number of WF activity        */
        p_funcmode   in         VARCHAR2, /* execution mode of WF activity   */
        x_result     out NoCopy VARCHAR2  /* result of activity              */
        )
IS

        l_stmt_num              number := 0;
        l_x_error_msg_name      varchar2(30);
        l_x_error_msg           varchar2(500);  	--bugfix 2776026: increased the var size
        l_x_error_msg_count     number;
	l_x_table_name          varchar2(150);
        l_x_hold_result_out     varchar2(1);
        l_x_hold_return_status  varchar2(1);
        l_status                integer;
        l_activity_name         varchar2(30);
        l_model_line_id         number;
        l_model_id              number;
        l_mfg_org_id            number;
        l_x_bill_seq_id         number;
        l_return_status         VARCHAR2(1);
        l_flow_status_code      VARCHAR2(30);
        l_perform_flow_calc     number := 1;

        lTopAtoLineId		number;				-- 2313475 lTopModelLineId
	l_header_id		number;
	l_config_line_id	number;
	l_config_id		number;
	l_xReturnStatus		varchar2(1);
	l_xMsgCount		number;
	l_xMsgData		varchar2(2000);
        l_program_id            number;

        l_tree_id               integer;
        l_perform_match         varchar2(2) ;

        l_x_qoh                 number;
        l_x_rqoh                number;
        l_x_qs                  number;
        l_x_qr                  number;
        l_x_att                 number;

        l_reservation_uom_code  varchar2(3);
        l_primary_uom_code      varchar2(3);
        l_quantity_to_reserve   number;
        l_schedule_ship_date    DATE;

        l_automatic_reservation  varchar2(2) ;
        l_diff_days              number ;
        l_reservation_time_fence number;

        x_available_qty     	number ;
        x_quantity_reserved 	number ;
        x_msg_count          	number ;
        x_msg_data           	varchar2(200) ;
        x_error_message      	varchar2(200) ;
        x_message_name       	varchar2(200) ;
        x_reserve_status     	varchar2(200) ;
        x_return_status     	varchar2(200) ;

        l_active_activity 	varchar2(30);
        lMatchProfile           varchar2(10);

        v_source_type_code      oe_order_lines_all.source_type_code%type ;
	x_oper_unit_list	cto_auto_procure_pk.oper_unit_tbl;
	l_batch_no		Number;


        l_config_item_id        number ;
        lPerformPPRollup        varchar2(10) ;
        lPerformCSTRollup       varchar2(10) ;
        lPerformLTCalc          varchar2(10) ;
        lPerformFWCalc          varchar2(10) ;
        lNotifyUsers            varchar2(10) ;

        l_requestId             number ;

        v_order_number          number ;
        v_top_model_name        varchar2(100);
        v_top_model_line_num    varchar2(100);
        v_top_config_name        varchar2(100);
        v_top_config_line_num    varchar2(100);

   l_msg_data   Varchar2(2000);



   v_top_model_id      number ;
   v_ship_from_org_id     number ;
   v_planner_code      fnd_user.user_name%type ;
   v_recipient         varchar2(200) ;

   lFlowStatusCode     varchar2(200) ;
  return_value    NUMBER;

	l_token 		CTO_MSG_PUB.token_tbl;
   l_config_item_name          varchar2(1000) ;
BEGIN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('create_config_item_wf: ' || 'Function Mode: ' || p_funcmode, 1);
        	oe_debug_pub.add('create_config_item_wf: ' || 'Item Key : ' || p_itemkey , 1);
        	oe_debug_pub.add('create_config_item_wf: ' || 'Item Type : ' || p_itemtype , 1);
        	oe_debug_pub.add('create_config_item_wf: ' || 'activity id : ' || p_actid , 1);

        	oe_debug_pub.add('create_config_item_wf: ' || 'CTO Activity: Create Config Item', 1);

		oe_debug_pub.add('create_config_item_wf: ' ||  'Time Stamp ' || to_char( sysdate , 'dd-mon-yyyy hh24:mi:ss' ));
	END IF;


        OE_STANDARD_WF.Set_Msg_Context(p_actid);

        savepoint before_item_creation;

	if (p_funcmode = 'RUN') then

           /*-----------------------------------------------------+
             Do the following before creating config item:
                      1.  Check for existence of config line
                      2.  Validate model line
                      3.  Check Holds
            +-----------------------------------------------------*/

            l_stmt_num := 100;

            IF (config_line_exists(to_number(p_itemkey))) THEN
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('create_config_item_wf: ' || 'Configuration Line exists for this model.', 1);
                END IF;
                l_stmt_num := 102;

		--       The exception block for the following select statement is added by Renga Kannan
		--       on 12/14/00. This part of the bug fix # 1381938
		--       When the start Model workflow is called and it is having configuration item
		--       in Oe_order_lines_all, it can be becasue of two things. One is the Auto create config
		--       batch program is running and the other is due to link_item
		--       In the case of Auto create config process we will get the program_id value in bcol table.
		--       But in the case of link item the data may not be there in bcol table at all. So in the
		--       case of link_item in the when_no_data_found exception we will set the l_program_id value to 0.
		--       This will move the model work flow as well as the config line workflow.

                begin
                  select program_id
                  into   l_program_id
                  from   bom_cto_order_lines
                  where  line_id = to_number(p_itemkey);
                exception
		  when no_data_found then
                    IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('create_config_item_wf: ' || 'The configuration item is created by the link_item process...',1);
                    END IF;
                	-- Set the l_program_id to zero so that the config workflow is moved further...
                    l_program_id := 0;
                end;

		--        End of change by Renga kannan 12/14/00

                --
                -- Return if this line is being processed by AutoCreate Config.
                --
                if (l_program_id = 31881) then
                    x_result := 'COMPLETE';
                    return;
                end if;

                l_stmt_num := 103;
                select line_id
                into   l_config_line_id
                from   oe_order_lines_all
                where  ato_line_id = to_number(p_itemkey)
                and    item_type_code = 'CONFIG';

                /* ATO Line Workflow will not have individual activities to be bypassed
                l_stmt_num := 104;
                wf_engine.CompleteActivityInternalName(
                                                   'OEOL',
                                                   l_config_line_id,
                                                   'CREATE_CONFIG_BOM_ELIGIBLE',
                                                   'CREATED');
                */


                x_result := 'COMPLETE';
                return;
            END IF;   /* end if check config item */

            l_stmt_num := 105;
            IF (validate_line(to_number(p_itemkey)) <> TRUE) THEN
                cto_msg_pub.cto_message('BOM','CTO_LINE_STATUS_NOT_ELIGIBLE');
                raise FND_API.G_EXC_ERROR;
            END IF;

            l_stmt_num := 110;

	    IF PG_DEBUG <> 0 THEN
	    	oe_debug_pub.add('create_config_item_wf: ' ||  'Time Stamp ' || to_char( sysdate , 'dd-mon-yyyy hh24:mi:ss' ));

            	oe_debug_pub.add('create_config_item_wf: ' || 'Calling Check Holds.',1);
            END IF;
            /* bugfix 4051282: check for activity hold and generic hold */
            OE_HOLDS_PUB.Check_Holds(p_api_version   => 1.0,
                                     p_line_id       => to_number(p_itemkey),
                                     p_wf_item       => 'OEOL',
                                     p_wf_activity   => 'CREATE_CONFIG',
                                     x_result_out    => l_x_hold_result_out,
                                     x_return_status => l_x_hold_return_status,
                                     x_msg_count     => l_x_error_msg_count,
                                     x_msg_data      => l_x_error_msg);

            IF (l_x_hold_return_status = FND_API.G_RET_STS_ERROR) THEN
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('create_config_item_wf: ' || 'Failed in Check Holds with expected error.' ,1);
                END IF;
                raise FND_API.G_EXC_ERROR;

            ELSIF (l_x_hold_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('create_config_item_wf: ' || 'Failed in Check Holds with unexpected error.' ,1);
                END IF;
                raise FND_API.G_EXC_UNEXPECTED_ERROR;

            ELSE
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('create_config_item_wf: ' || 'Success in Check Holds. ' || l_x_hold_return_status,1);
                END IF;
                IF (l_x_hold_result_out = FND_API.G_TRUE) THEN
                    IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('create_config_item_wf: ' || 'Order Line ID ' || p_itemkey ||
                                     'is on HOLD. ' ||l_x_hold_result_out);
                    END IF;
                    cto_msg_pub.cto_message('BOM', 'CTO_ORDER_LINE_ON_HOLD');
                    x_result := 'COMPLETE:ON_HOLD';
                    return;

                END IF; -- end to check hold = TRUE
            END IF; -- end to check hold return status



             oe_debug_pub.add('create_config_item_wf: ' || 'Getting Profile Values ' , 1);


             lPerformPPRollup := nvl( FND_PROFILE.Value('CTO_PERFORM_PURCHASE_PRICE_ROLLUP'), 1 ) ;
             lPerformCSTRollup := nvl( FND_PROFILE.Value('CTO_PERFORM_COST_ROLLUP') , 1 ) ;
             --Bugfix 6737389
             --lPerformFWCalc := nvl( FND_PROFILE.Value('CTO_PERFORM_FLOW_CALC') , 1 );
             lPerformFWCalc := nvl( FND_PROFILE.Value('CTO_PERFORM_FLOW_CALC') , 2 );
             lPerformLTCalc := nvl( FND_PROFILE.Value('BOM:ATO_PERFORM_LEADTIME_CALC' ) , 1 ) ;
             lNotifyUsers := nvl( FND_PROFILE.Value('CTO_NOTIFY_USER_FOR_ERRORS'), 1) ;

             oe_debug_pub.add('create_config_item_wf: ' || 'Done Getting Profile Values ' , 1);

             IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('create_config_item_wf: ' || 'Profile Perform Purchase Price Rollup ' || lPerformPPRollup , 1);
                	oe_debug_pub.add('create_config_item_wf: ' || 'Profile Perform Cost Rollup ' || lPerformCSTRollup , 1);
                	oe_debug_pub.add('create_config_item_wf: ' || 'Profile Perform Lead Time Calculations ' || lPerformLTCalc , 1);
                	oe_debug_pub.add('create_config_item_wf: ' || 'Profile Perform Flow Calculations ' || lPerformFWCalc , 1);
                	oe_debug_pub.add('create_config_item_wf: ' || 'Profile Notify User for Errors ' || lNotifyUsers , 1);
             END IF;


            if( lPerformFWCalc = 1 ) then
                 l_perform_flow_calc := 1;
                 oe_debug_pub.add('create_config_item_wf: ' || 'Flow Calc is 1 ' , 1);
            else
            --Begin Bugfix 6737389
                 if( lPerformFWCalc = 2 ) then
                        l_perform_flow_calc := 2;
                        oe_debug_pub.add('create_config_item_wf: ' || 'Flow Calc is 2 ' , 1);
                 else
                        l_perform_flow_calc := 3;
                        oe_debug_pub.add('create_config_item_wf: ' || 'Flow Calc is 3 ' , 1);
                 end if;
            --End Bugfix 6737389
            end if ;


            l_stmt_num := 115;

	    --
	    -- get the top ato_line_id for this model line
	    -- Bugfix 2313475 replace top_model_line_id with ato_line_id
	    --
            /* BUG#2234858 Added new functionality for drop ship
            ** need to retrieve source_type_code to find whether
            ** line is dropshipped
            */
	    select ato_line_id
                   , order_quantity_uom , ordered_quantity -- added by sushant for reservation
                   , schedule_ship_date                    -- added by sushant for reservation
                   , source_type_code                      -- added by sushant for drop ship
	    into lTopAtoLineId
                 , l_reservation_uom_code , l_quantity_to_reserve
                 , l_schedule_ship_date
                 , v_source_type_code
	    from oe_order_lines_all
	    where line_id = to_number(p_itemkey);

	    IF PG_DEBUG <> 0 THEN
	    	oe_debug_pub.add('create_config_item_wf: ' || 'lTopATOLineId::'||to_char(lTopAtoLineId));
	    END IF;






           /* Additional Code for Error Processing */
           /* COLLECT DATA for ERROR PROCESSING */



	   oe_debug_pub.add('create_config_item_wf: ' ||  'Going to Collect Data for Error Processing '  , 1 );



            select  oeh.order_number , msi.segment1, oel.line_number || '.' || oel.shipment_number
                  , msi.inventory_item_id , msi.organization_id
            into  v_order_number, v_top_model_name, v_top_model_line_num
                  , v_top_model_id, v_ship_from_org_id
            from  oe_order_headers_all oeh , oe_order_lines_all  oel , mtl_system_items msi
            where  oeh.header_id = oel.header_id
            and  oel.line_id = lTopAtoLineId
            and  oel.inventory_item_id = msi.inventory_item_id
            and  oel.ship_from_org_id = msi.organization_id ;





	   oe_debug_pub.add('create_config_item_wf: ' ||  'Going to get planner code ' , 1 );

            CTO_UTILITY_PK.get_planner_code( v_top_model_id, v_ship_from_org_id , v_planner_code ) ;


	   oe_debug_pub.add('create_config_item_wf: ' ||  'planner code is '  || v_planner_code , 1 );









            /*--------------------------------------------------------+
            Call API to create config item.  The API will create config
	    items for all ATO models. The top model config item will be
	    linked in oe_order_lines_all AFTER BOM creation.
	    Depending on the "Match" profile, it will create new items
	    or match to existing items.
            +---------------------------------------------------------*/

            l_stmt_num := 120;

	    IF PG_DEBUG <> 0 THEN
	    	oe_debug_pub.add('create_config_item_wf: ' ||  'Time Stamp ' || to_char( sysdate , 'dd-mon-yyyy hh24:mi:ss' ));

            	oe_debug_pub.add('create_config_item_wf: ' || 'Calling Create and Link Item.', 1);
            END IF;

            l_status := CTO_ITEM_PK.create_and_link_item
                                       (pTopAtoLineId 	=> to_number(p_itemkey),
					xReturnStatus	=> l_xReturnStatus,
					xMsgCount	=> l_xMsgCount,
					xMsgData	=> l_xMsgData );


                	oe_debug_pub.add('create_config_item_wf: ' || 'done create and link Item .');

            if (l_status = 0 and l_xReturnStatus =  FND_API.G_RET_STS_ERROR ) then
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('create_config_item_wf: ' || 'Failed in Create and Link Item with expected error.');
                END IF;



                /* EXPECTED ERROR PROCESSING */

                    if( lNotifyUsers = 1  ) then
                           IF PG_DEBUG <> 0 THEN
                              oe_debug_pub.add('create_config_item_wf: ' || 'Going to Call CTO_UTILITY_PK.handle_expected_error ..',3);
                           END IF;

                           CTO_UTILITY_PK.handle_expected_error( p_error_type => CTO_UTILITY_PK.EXP_ERROR_AND_ITEM_NOT_CREATED
                                                , p_inventory_item_id   => v_top_model_id
                                                , p_organization_id     => v_ship_from_org_id
                                                , p_line_id             => lTopAtoLineId
                                                , p_sales_order_num     => v_order_number
                                                , p_top_model_name      => v_top_model_name
                                                , p_top_model_line_num  => v_top_model_line_num
                                                , p_msg_count           => l_xMsgCount
                                                , p_planner_code        => v_planner_code
                                                , p_request_id          => null
                                                , p_process             => 'NOTIFY_OEE_INC' ) ;



                    end if; /* lNotifyUsers */




                raise FND_API.G_EXC_ERROR;

            elsif (l_status = 0 and l_xReturnStatus =  FND_API.G_RET_STS_UNEXP_ERROR ) then
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('create_config_item_wf: ' || 'Failed in Create and Link Item with unexpected error.');
                END IF;
                raise FND_API.G_EXC_UNEXPECTED_ERROR;

            else
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('create_config_item_wf: ' || 'Success in Create And Link Item.', 1);
                END IF;
            end if;


            oe_debug_pub.add('create_config_item_wf: ' || 'going for bom and routing .');


            /*----------------------------------------------------------+
            Create BOM and Routing
            +-----------------------------------------------------------*/

	    -- rkaza. bug 4524248. bom structure import enhancements. 11/05/05.
	    l_stmt_num := 125;

	    IF PG_DEBUG <> 0 THEN
	    	oe_debug_pub.add('create_config_item_wf: About to generate bom batch ID', 5);
            end if;

            cto_msutil_pub.set_bom_batch_id(x_return_status => l_xReturnStatus);
            if l_xReturnStatus <> fnd_api.G_RET_STS_SUCCESS then
               IF PG_DEBUG <> 0 THEN
            	    	oe_debug_pub.add('create_config_item_wf: ' || 'Failed in set_bom_batch_id with unexp error.', 1);
               END IF;
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
            end if;


	    oe_debug_pub.add('create_config_item_wf: ' ||  ' resetting CTO_CONFIG_BOM_PK.g_t_dropped_item_type ' , 1 );

            CTO_CONFIG_BOM_PK.g_t_dropped_item_type.delete ;



	    IF PG_DEBUG <> 0 THEN
	    	oe_debug_pub.add('create_config_item_wf: ' ||  'Time Stamp ' || to_char( sysdate , 'dd-mon-yyyy hh24:mi:ss' ));

            	oe_debug_pub.add('create_config_item_wf: ' || 'Calling Create BOM and Routing ', 1);
            END IF;






	    l_stmt_num := 130;
            CTO_BOM_RTG_PK.create_all_boms_and_routings(
					pAtoLineId	=> to_number(p_itemkey),
        				pFlowCalc	=> l_perform_flow_calc,
        				xReturnStatus	=> l_xReturnStatus,
        				xMsgCount	=> l_xMsgCount,
        				xMsgData	=> l_xMsgData);




               if( CTO_CONFIG_BOM_PK.g_t_dropped_item_type.count > 0 ) then
                    oe_debug_pub.add( 'DROPPED component count > 0 ' , 1 ) ;

                        select  oeh.order_number , msi.segment1, oel.line_number || '.' || oel.shipment_number
                          into  v_order_number, v_top_model_name, v_top_model_line_num
                          from  oe_order_headers_all oeh , oe_order_lines_all  oel , mtl_system_items msi
                         where  oeh.header_id = oel.header_id
                           and  oel.line_id = lTopAtoLineId
                           and  oel.inventory_item_id = msi.inventory_item_id
                           and  oel.ship_from_org_id = msi.organization_id ;


                    for i in 1..CTO_CONFIG_BOM_PK.g_t_dropped_item_type.count
                    loop

                         CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).SALES_ORDER_NUM       := v_order_number ;
                         CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).TOP_MODEL_NAME        := v_top_model_name ;
                         CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).TOP_MODEL_LINE_NUM    := v_top_model_line_num ;
                         CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).TOP_CONFIG_NAME       := null ;
                         CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).TOP_CONFIG_LINE_NUM   := null ;
                         CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).REQUEST_ID             := null    ;

                    end loop ;

               end if ;





            IF (l_xReturnStatus = fnd_api.G_RET_STS_ERROR) THEN
            	    IF PG_DEBUG <> 0 THEN
            	    	oe_debug_pub.add('create_config_item_wf: ' || 'Failed in Create BOM and Routing with exp error.', 1);
            	    END IF;


                    if( CTO_CONFIG_BOM_PK.g_t_dropped_item_type.count > 0 ) then

                       if( lNotifyUsers = 1 ) then
            	    	   oe_debug_pub.add('create_config_item_wf: ' || '********** ******* Will be Sending Notifications .', 1);
                           CTO_UTILITY_PK.send_oid_notification ;  /* DROPPED COMPONENTS BOM NOT CREATED NOTIFICATION */

                       else
            	    	   oe_debug_pub.add('create_config_item_wf: ' || '********** ******* Will not be Sending Notifications .', 1);

                       end if;



                    end if;









                    /* EXPECTED ERROR NOTIFICATION */


                    if( lNotifyUsers = 1  ) then
                           IF PG_DEBUG <> 0 THEN
                              oe_debug_pub.add('create_config_item_wf: ' || 'Going to Call CTO_UTILITY_PK.handle_expected_error ..',3);
                           END IF;

                           CTO_UTILITY_PK.handle_expected_error( p_error_type => CTO_UTILITY_PK.EXP_ERROR_AND_ITEM_NOT_CREATED
                                                , p_inventory_item_id   => v_top_model_id
                                                , p_organization_id     => v_ship_from_org_id
                                                , p_line_id             => lTopAtoLineId
                                                , p_sales_order_num     => v_order_number
                                                , p_top_model_name      => v_top_model_name
                                                , p_top_model_line_num  => v_top_model_line_num
                                                , p_msg_count           => l_xMsgCount
                                                , p_planner_code        => v_planner_code
                                                , p_request_id          => null
                                                , p_process             => 'NOTIFY_OEE_INC' ) ;



                    end if; /* lNotifyUsers */



                    raise FND_API.G_EXC_ERROR;




            ELSIF (l_xReturnStatus = fnd_api.G_RET_STS_UNEXP_ERROR) THEN
            	    IF PG_DEBUG <> 0 THEN
            	    	oe_debug_pub.add('create_config_item_wf: ' || 'Failed in Create BOM and Routing with unexp error.', 1);
            	    END IF;
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSE
                    IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('create_config_item_wf: ' || 'Success in Create BOM and Routing ', 1);
                    END IF;
            END IF;



	    --
	    -- Get the config item id to be linked
	    --

	    l_stmt_num := 140;
	    select bcol.config_item_id,
		bcol.inventory_item_id,
		bcol.ship_from_org_id,
                perform_match -- Sushant added this to check full item match
	    into l_config_id,
		l_model_id,
		l_mfg_org_id,
                l_perform_match  -- Sushant added this to check full item match
	    from bom_cto_order_lines bcol
	    where bcol.line_id = to_number(p_itemkey);



	    --
	    -- Link the top level config item in oe_order_lines_all
	    --

	    l_stmt_num := 150;
	    IF PG_DEBUG <> 0 THEN
	    	oe_debug_pub.add ('create_config_item_wf: ' || 'CALLING LINK_ITEM');
	    END IF;

  	    l_status := CTO_CONFIG_ITEM_PK.link_item(
                 		pOrgId		=> l_mfg_org_id,
                 		pModelId	=> l_model_id,
                 		pConfigId	=> l_config_id,
                 		pLineId		=> to_number(p_itemkey),
                 		xMsgCount	=> l_xMsgCount,
                 		xMsgData	=> l_xMsgData );

  	    if l_status <> 1 then
     		IF PG_DEBUG <> 0 THEN
     			oe_debug_pub.add ('create_config_item_wf: ' || 'Failed in link_item function', 1);
     		END IF;


                    /* EXPECTED ERROR NOTIFICATION */


                    if( lNotifyUsers = 1  ) then
                           IF PG_DEBUG <> 0 THEN
                              oe_debug_pub.add('create_config_item_wf: ' || 'Going to Call CTO_UTILITY_PK.handle_expected_error ..',3);
                           END IF;

                           CTO_UTILITY_PK.handle_expected_error( p_error_type => CTO_UTILITY_PK.EXP_ERROR_AND_ITEM_NOT_CREATED
                                                , p_inventory_item_id   => v_top_model_id
                                                , p_organization_id     => v_ship_from_org_id
                                                , p_line_id             => lTopAtoLineId
                                                , p_sales_order_num     => v_order_number
                                                , p_top_model_name      => v_top_model_name
                                                , p_top_model_line_num  => v_top_model_line_num
                                                , p_msg_count           => l_xMsgCount
                                                , p_planner_code        => v_planner_code
                                                , p_request_id          => null
                                                , p_process             => 'NOTIFY_OEE_INC' ) ;



                    end if; /* lNotifyUsers */


		raise FND_API.G_EXC_ERROR;
  	    end if;

  	    IF PG_DEBUG <> 0 THEN
  	    	oe_debug_pub.add ('create_config_item_wf: ' || 'Success in link_item function', 1);

            	oe_debug_pub.add ('create_config_item_wf: ' || 'Getting config line id.', 1);
            END IF;

            l_stmt_num := 152;

            select line_id, header_id, inventory_item_id
            into   l_config_line_id, l_header_id, l_config_item_id
            from   oe_order_lines_all
            where  ato_line_id = to_number(p_itemkey)
            and    item_type_code = 'CONFIG';

            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add ('create_config_item_wf: ' || 'Config line id is ' || to_char(l_config_line_id), 1);

            	oe_debug_pub.add('create_config_item_wf: ' || 'header ID: ' || to_char(l_header_id), 1);
            END IF;


            l_stmt_num := 155;

            CTO_WORKFLOW_API_PK.query_wf_activity_status(
					p_itemtype		=> 'OEOL' ,
					p_itemkey		=> to_char(l_config_line_id ) ,
					p_activity_label	=> 'CREATE_CONFIG_BOM_ELIGIBLE',
					p_activity_name		=> 'CREATE_CONFIG_BOM_ELIGIBLE',
					p_activity_status	=> l_active_activity );

            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('create_config_item_wf: ' || 'Workflow CREATE_CONFIG_BOM_ELIGIBLE Status is: ' ||
                             l_active_activity, 1);

            	oe_debug_pub.add('create_config_item_wf: ' ||  ' updating config bom eligible to complete:created ' , 1);
            END IF;



           /* Additional Code for Error Processing */
            /* COLLECT CONFIG DATA for ERROR PROCESSING */







                        select  msi.segment1, oel.line_number || '.' || oel.shipment_number || '.'  || nvl( oel.option_number , '' )
                                || '.' || nvl(component_number , '' )
                          into  v_top_config_name, v_top_config_line_num
                          from  oe_order_lines_all  oel , mtl_system_items msi
                         where  oel.ato_line_id = lTopAtoLineId
                           and  item_type_code = 'CONFIG'
                           and  oel.inventory_item_id = msi.inventory_item_id
                           and  oel.ship_from_org_id = msi.organization_id ;






            l_stmt_num := 160;


            /*
            lMatchProfile := FND_PROFILE.Value('BOM:MATCH_CONFIG');
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('create_config_item_wf: ' || 'Match Profile is ' || lMatchProfile, 1 );
            END IF;
            removed lMatchProfile check as this fix has been made in CTOUTILB.pls
            */


	    IF PG_DEBUG <> 0 THEN
	    	oe_debug_pub.add('create_config_item_wf: ' ||  'Time Stamp ' || to_char( sysdate , 'dd-mon-yyyy hh24:mi:ss' ));
	    END IF;





              if( CTO_CONFIG_BOM_PK.g_t_dropped_item_type.count > 0 ) then
                    oe_debug_pub.add( 'DROPPED component count > 0 ' , 1 ) ;

                        select  msi.segment1, oel.line_number || '.' || oel.shipment_number || '.'  || nvl( oel.option_number , '' )
                                || '.' || nvl(component_number , '' )
                          into  v_top_config_name, v_top_config_line_num
                          from  oe_order_lines_all  oel , mtl_system_items msi
                         where  oel.ato_line_id = lTopAtoLineId
                           and  item_type_code = 'CONFIG'
                           and  oel.inventory_item_id = msi.inventory_item_id
                           and  oel.ship_from_org_id = msi.organization_id ;


                    for i in 1..CTO_CONFIG_BOM_PK.g_t_dropped_item_type.count
                    loop

                         CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).TOP_CONFIG_NAME       := v_top_config_name ;
                         CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).TOP_CONFIG_LINE_NUM   := v_top_config_line_num ;
                         CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).REQUEST_ID             := null    ;

                    end loop ;


                       if( lNotifyUsers = 1 ) then
                           CTO_UTILITY_PK.send_oid_notification ;  /* DROPPED COMPONENTS ITEM CREATED NOTIFICATION */

                       else
                           oe_debug_pub.add('create_config_item_wf: ' || '********** ******* Will not be Sending Notifications .', 1);

                       end if;



               end if ;













                l_stmt_num := 163;
                /* ATO Line Workflow will not have individual activities to be bypassed
                wf_engine.CompleteActivityInternalName(
                                                   'OEOL',
                                                   l_config_line_id,
                                                   'CREATE_CONFIG_BOM_ELIGIBLE',
                                                   'CREATED');

               */






             if( lPerformPPRollup = 1  ) then

                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('create_config_item_wf: ' || 'Will Perform Purchase Price Rollup as profile is Yes ', 1);
                END IF;

		-- Added by Renga Kannan on 03/26/02 to call
                -- Create purchase doc code for match case. In the  case of
                -- match the workflow will be moved to create config eligible directly

                CTO_AUTO_PROCURE_PK.Create_Purchasing_Doc(
                                                p_config_item_id => l_config_item_id ,
                                                p_overwrite_list_price  => 'N',
                                                p_called_in_batch       => 'N',
                                                p_batch_number          => l_batch_no,
						p_ato_line_id           => to_number(p_itemKey),
                                                x_oper_unit_list        => x_oper_unit_list,
                                                x_return_status         => x_Return_Status,
                                                x_msg_count             => X_Msg_Count,
                                                x_msg_data              => x_msg_data);







                    IF (x_Return_Status = fnd_api.G_RET_STS_ERROR) THEN
                          IF PG_DEBUG <> 0 THEN
                             oe_debug_pub.add('create_config_item_wf: ' || 'Failed in Purchase Price ROLLUP .', 1);
                          END IF;


                          /* EXPECTED ERROR NOTIFICATION */


                          if( lNotifyUsers = 1  ) then
                              IF PG_DEBUG <> 0 THEN
                                 oe_debug_pub.add('create_config_item_wf: ' || 'Going to Call CTO_UTILITY_PK.handle_expected_error ..',3);
                              END IF;

                              CTO_UTILITY_PK.handle_expected_error( p_error_type => CTO_UTILITY_PK.EXP_ERROR_AND_ITEM_NOT_CREATED
                                                   , p_inventory_item_id   => v_top_model_id
                                                   , p_organization_id     => v_ship_from_org_id
                                                   , p_line_id             => lTopAtoLineId
                                                   , p_sales_order_num     => v_order_number
                                                   , p_top_model_name      => v_top_model_name
                                                   , p_top_model_line_num  => v_top_model_line_num
                                                   , p_top_config_name     => v_top_config_name
                                                   , p_top_config_line_num => v_top_config_line_num
                                                   , p_msg_count           => l_xMsgCount
                                                   , p_planner_code        => v_planner_code
                                                   , p_request_id          => null
                                                   , p_process             => 'NOTIFY_OEE_IC' ) ;



                          end if; /* lNotifyUsers */





                          raise FND_API.G_EXC_ERROR;




                   ELSIF ( x_Return_Status = fnd_api.G_RET_STS_UNEXP_ERROR) THEN
                          IF PG_DEBUG <> 0 THEN
                             oe_debug_pub.add('create_config_item_wf: ' || 'Failed in Purchase Price ROllup .', 1);
                          END IF;

                          raise FND_API.G_EXC_UNEXPECTED_ERROR;
                   ELSE
                       IF PG_DEBUG <> 0 THEN
                           oe_debug_pub.add('create_config_item_wf: ' || 'Success in Purchase Price Rollup ', 1);
                       END IF;
                   END IF;





             else

                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('create_config_item_wf: ' || 'Will Not Perform Purchase Price Rollup as profile is No ', 1);
                END IF;

             end if ;







             if( lPerformCSTRollup = 1  ) then

                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('create_config_item_wf: ' || 'Will Perform Cost Rollup as profile is Yes  ', 1);
                END IF;



                l_status := CTO_CONFIG_COST_PK.cost_rollup_ml(
                                        pTopAtoLineId   => p_itemkey,
                                        x_msg_count     => l_xmsgcount,
                                        x_msg_data      => l_xmsgdata);

                if (l_status = 0) then
                    IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('create_config_item_wf: ' || 'Failure in cost_rollup ', 1);
                    END IF;
                    --cto_msg_pub.cto_message('BOM', l_xmsgdata);
                    raise FND_API.G_EXC_ERROR;


                elsif( l_status = -1 ) then
                    IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('create_config_item_wf: ' || 'Unexpected Failure in cost_rollup ', 1);
                    END IF;
                    cto_msg_pub.cto_message('BOM', l_xmsgdata);
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;

                else
                    IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('create_config_item_wf: ' || 'Success in cost_rollup ', 1);
                    END IF;
                end if;



            else

                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('create_config_item_wf: ' || 'Will Not perform cost_rollup as profile is No ', 1);
                END IF;

            end if ;





                /*
                **
                **   LEAD TIME CALCULATION CHANGES GO HERE
                **
                */

             if( lPerformLTCalc = 1 ) then

                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('create_config_item_wf: ' || 'Will perform Lead Time Calc  as profile is Yes ' || lTopAtoLineId , 1);
                END IF;



                 l_requestId := fnd_request.submit_request( application => 'BOM',
                                              program => 'CTOCLT',
                                              description => null,
                                              start_time => null,
                                              sub_request => false,
                                              argument1 => lTopAtoLineId  );

                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('create_config_item_wf: ' || ' request id  ' || l_requestid , 1);
                END IF;

                                /*
                               |      FUNCTION submit_request (
                               |               application IN varchar2,
                               |               program     IN varchar2,
                               |               description IN varchar2,
                               |               start_time  IN varchar2,
                               |               sub_request IN boolean,
                               |               argument1   IN varchar2,
                               |               argument2   IN varchar2,
                               |               .........
                               |               argument100 IN varchar2) return number
                               |
                               */


             else

                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('create_config_item_wf: ' || 'Will Not perform Lead Time Calc  as profile is No ', 1);
                END IF;

             end if ;





           	--
            	-- Bugfix 2234858 Drop SHIPMENT Project Enhancement
            	-- Sushant Modified this code to allow reservation only for non drop shipped items
            	--
                --Bugfix 6046572: No reservation getting created in case of custom match. Replaced
                --l_perform_match = 'Y' with l_perform_match in ('Y', 'C')
            	IF ( v_source_type_code = 'INTERNAL' AND   l_perform_match in ('Y', 'C')) THEN

                l_stmt_num := 167;


                create_reservation(
                                l_mfg_org_id,
                                lTopAtoLineId,
                                l_config_id,
                                l_reservation_uom_code,
                                l_quantity_to_reserve,
                                l_schedule_ship_date,
                                'ONLINE' ,
                                x_reserve_status ,
                                x_msg_count ,
                                x_msg_data ,
                                x_return_status ) ;

                -- Complete the block activity in the config flow
                l_stmt_num := 170;

                if( x_return_status = FND_API.G_RET_STS_SUCCESS ) then


	             IF PG_DEBUG <> 0 THEN
	             	oe_debug_pub.add('create_config_item_wf: ' ||  'Time Stamp ' || to_char( sysdate , 'dd-mon-yyyy hh24:mi:ss' ));

                     	oe_debug_pub.add('create_config_item_wf: ' ||  ' create_reservation status success ' , 1 );

                     	oe_debug_pub.add('create_config_item_wf: ' ||  ' reserve status ' || x_reserve_status  , 1 );
                     END IF;


                         l_stmt_num := 175;


                         IF PG_DEBUG <> 0 THEN
                         	oe_debug_pub.add('create_config_item_wf: ' || 'going to get Workflow Status for config line : ' ||
                                to_char( l_config_line_id )  , 1 );
                         END IF;

                         CTO_WORKFLOW_API_PK.get_activity_status(
						itemtype	=> 'OEOL',
                                                itemkey		=> to_char(l_config_line_id),
                                                linetype	=> 'CONFIG',
                                                activity_name	=> l_active_activity);

                         IF PG_DEBUG <> 0 THEN
                         	oe_debug_pub.add('create_config_item_wf: ' || 'Workflow Status is: ' ||
                             l_active_activity, 1);
                         END IF;


                         l_stmt_num := 178;

            		 CTO_WORKFLOW_API_PK.query_wf_activity_status(
					p_itemtype		=> 'OEOL' ,
					p_itemkey		=> to_char(l_config_line_id ) ,
					p_activity_label	=> 'SHIP_LINE',
					p_activity_name		=> 'SHIP_LINE',
					p_activity_status	=> l_active_activity );

                         IF PG_DEBUG <> 0 THEN
                         	oe_debug_pub.add('create_config_item_wf: ' || 'Workflow SHIP_LINE Status is: ' ||
                             l_active_activity, 1);
                         END IF;



                else /* create reservation not successful */

                   IF PG_DEBUG <> 0 THEN
                   	oe_debug_pub.add('create_config_item_wf: ' ||  ' create_reservation status failure ' , 1 );
                   END IF;



                end if ;


            elsif v_source_type_code = 'INTERNAL' then  /* end if source type code INTERNAL */

                l_stmt_num := 220;
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('create_config_item_wf: ' ||  ' No Reservation attempted as match not successful ' , 1 );
                END IF;



           elsif v_source_type_code = 'EXTERNAL' then  /* end if source type code INTERNAL */

               IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('create_reservation: ' ||  'Drop Ship Scenario ' , 1 );
               END IF ;



                oe_debug_pub.add('create_reservation: ' ||  'Drop Ship Scenario perform match ' || l_perform_match  , 1 );



                 if( l_perform_match = 'Y' ) then

               IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('create_reservation: ' ||  'Time Stamp ' || to_char( sysdate , 'dd-mon-yyyy hh24:mi:ss' ));

                oe_debug_pub.add('create_reservation: ' ||  'DropShip Matched item ' ||
                                 l_config_id, 1  );
               END IF;


               select segment1
               into   l_config_item_name
               from   mtl_system_items
               where  inventory_item_id = l_config_id
               and    organization_id = l_mfg_org_id ;
                /* fixed bug 1853597 to retrieve only one row for each item */

               l_stmt_num := 235;

               IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('create_reservation: ' ||  'CTO_CONFIG_MATCH for item ' || l_config_item_name , 1  );
               END IF;


                   l_token(1).token_name  := 'CONFIG_ITEM';
                   l_token(1).token_value := l_config_item_name;

                   cto_msg_pub.cto_message('BOM', 'CTO_CONFIG_MATCH', l_token);
                   --fnd_message.set_token('CONFIG_ITEM', l_config_item_name );

                   l_token := CTO_MSG_PUB.G_MISS_TOKEN_TBL;     -- initialize

                   OE_STANDARD_WF.Save_Messages;
                   OE_STANDARD_WF.Clear_Msg_Context;


              end if ; /* l_perform_match = 'Y' */



           end if ; /* v_source_type_code = 'INTERNAL' */


	   IF PG_DEBUG <> 0 THEN
	    	   oe_debug_pub.add('create_config_item_wf: ' ||  'Time Stamp '
                                                              || to_char( sysdate , 'dd-mon-yyyy hh24:mi:ss' )) ;


	   END IF;


           l_stmt_num := 230;
	   	                -- Added by Renga Kannan 03/30/06
            -- This is a wrapper API to call PLM team's to sync up item media index
            -- With out this sync up the item cannot be searched in Simple item search page
            -- This is fixed for bug 4656048

            CTO_MSUTIL_PUB.syncup_item_media_index;
		-- Start Bugfix 8305535
	        -- Calling RAISE EVENT to push items to Siebel
		l_stmt_num := 231;
		CTO_MSUTIL_PUB.Raise_event_for_seibel;
		-- End Bugfix 8305535


           x_result := 'COMPLETE';





        end if; /* end of p_funcmode = 'RUN' */

	CTO_CONFIG_BOM_PK.gApplyHold  := 'N';	-- bugfix 2899529: Reset this global variable.

        OE_STANDARD_WF.Save_Messages;
        OE_STANDARD_WF.Clear_Msg_Context;


EXCEPTION

        when FND_API.G_EXC_ERROR then
           IF PG_DEBUG <> 0 THEN
           	OE_DEBUG_PUB.add('create_config_item_wf: ' || 'CTO_WORKFLOW.create_config_item_wf ' ||
                            to_char(l_stmt_num) || ':' ||
                            l_x_error_msg);
           END IF;
	   fnd_msg_pub.count_and_get(p_data=>x_msg_data,p_count=>x_msg_count);
           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;
           x_result := 'COMPLETE:INCOMPLETE';
           rollback to savepoint before_item_creation;

        when FND_API.G_EXC_UNEXPECTED_ERROR then
           IF PG_DEBUG <> 0 THEN
           	OE_DEBUG_PUB.add('create_config_item_wf: ' || 'CTO_WORKFLOW.create_config_item_wf ' ||
                            to_char(l_stmt_num) || ':' ||
                            l_x_error_msg);
           END IF;
           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;
           wf_core.context('CTO_WORKFLOW', 'create_config_item_wf',
                           p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
           raise;

        when OTHERS then
           cto_msg_pub.cto_message('BOM', 'CTO_CREATE_ITEM_ERROR');
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('create_config_item_wf: ' || 'CTO_WORKFLOW.create_config_item_wf' ||
                            to_char(l_stmt_num) || ':' ||
                            substrb(sqlerrm, 1, 100));
           END IF;
           wf_core.context('CTO_WORKFLOW', 'create_config_item_wf',
                           p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);

           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;

           raise;

END create_config_item_wf;



/*============================================================================
        Procedure:    	create_reservation
        Description:  	This API gets called from create_config_item_wf

     	Parameters:
============================================================================*/
PROCEDURE create_reservation(
        p_mfg_org_id           in     number ,
        p_top_model_line_id    in     number,
        p_config_id            in     number ,
        p_reservation_uom_code in     varchar2 ,
        p_quantity_to_reserve  in     number,
        p_schedule_ship_date   in     DATE,
        p_mode                 in     varchar2 ,
        x_reserve_status       out    NoCopy    varchar2,
        x_msg_count            out    NoCopy    number ,
        x_msg_data             out    NoCopy    varchar2,
        x_return_status        out    NoCopy    varchar2
)
IS

	l_tree_id   		integer ;
	l_return_status    	varchar2(1) ;


        l_x_qoh                 number;
        l_x_rqoh                number;
        l_x_qs                  number;
        l_x_qr                  number;
        l_x_att                 number;

        l_primary_uom_code  	varchar2(3);
        l_automatic_reservation varchar2(2) ;
        l_diff_days             number ;
        l_reservation_time_fence number;

        l_quantity_to_reserve 	number ;
        x_available_qty     	number ;
        x_quantity_reserved 	number ;
        -- x_msg_count          number ;
        -- x_msg_data           varchar2(200) ;
        x_error_message      	varchar2(200) ;
        x_message_name       	varchar2(200) ;

        l_stmt_num           	number := 0 ;

        PROCESS_ERROR           exception;
        RESERVATION_ERROR       exception;

        l_x_error_msg_name      varchar2(30);
        l_x_error_msg           varchar2(500);  	--bugfix 2776026: increased the var size


        l_organization_name     varchar2(200) ;
        l_config_item_name      varchar2(200) ;
        lMatchProfile           varchar2(10);

        l_partial_reservation   boolean := FALSE ;
	l_token 		CTO_MSG_PUB.token_tbl;

        l_current_org_id        Number;
BEGIN
        /*
        ** Check whether full match was successful for top model to create reservations
        */

         x_return_status  := FND_API.G_RET_STS_SUCCESS ;
         x_reserve_status := 'MATCH' ;


         /*
         ** x_reserve_status := { 'MATCH', 'NOQTY' , 'PARTIAL' , 'COMPLETE' }
         */

         l_quantity_to_reserve := p_quantity_to_reserve ;


         /* use this to override l_automatic_reservation := 'Y' ;*/


         l_automatic_reservation := FND_PROFILE.VALUE('CTO_AUTOMATIC_RESERVATION');

         -- Code change for MOAC


         l_current_org_id := MO_GLOBAL.get_current_org_id;
         l_reservation_time_fence :=
                                oe_sys_parameters.value('ONT_RESERVATION_TIME_FENCE',l_current_org_id);

         -- End of MOAC code Change

         l_diff_days := trunc( p_schedule_ship_date ) - trunc( sysdate ) ;



	 IF PG_DEBUG <> 0 THEN
	 	oe_debug_pub.add('create_reservation: ' ||  'Time Stamp ' || to_char( sysdate , 'dd-mon-yyyy hh24:mi:ss' ));

         	oe_debug_pub.add('create_reservation: ' ||  ' going to check for reservation ' , 1 );

         	oe_debug_pub.add('create_reservation: ' ||  ' going to check for reservation ' || to_char(l_diff_days) ||
                           ' time fence ' || to_char(l_reservation_time_fence)
                          , 1 );

         	oe_debug_pub.add('create_reservation: ' ||  ' going to check for automatic reservation ' ||
                          l_automatic_reservation , 1 );
         END IF;

         if( l_automatic_reservation  = '1' and
            l_diff_days <= l_reservation_time_fence
           )
         then

         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('create_reservation: ' ||  ' going to attempt reservation ' , 1 );
         END IF;

         /*-------------------------------------------------+
             Create a quantity tree to get atr for reservation.
         +--------------------------------------------------*/
            l_stmt_num := 150;

            INV_QUANTITY_TREE_GRP.create_tree
                     (  p_api_version_number   => 1.0
                      , p_init_msg_lst         => fnd_api.g_false
                      , x_return_status        => l_return_status
                      , x_msg_count            => x_msg_count
                      , x_msg_data             => x_msg_data
                      , p_organization_id      => p_mfg_org_id
                      , p_inventory_item_id    => p_config_id
                      , p_tree_mode 	       => inv_quantity_tree_pub.g_reservation_mode
                      , p_is_revision_control  => FALSE
                      , p_is_lot_control       => FALSE
                      , p_is_serial_control    => FALSE
                      , x_tree_id              => l_tree_id);

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('create_reservation: ' || 'Failed in create_tree with status: ' ||
                             l_return_status, 1);
                END IF;
                raise PROCESS_ERROR;
            ELSE
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('create_reservation: ' || 'Success in create_tree.',1);

                	oe_debug_pub.add('create_reservation: ' || 'Tree ID:' || to_char(l_tree_id),1);
                END IF;
            END IF;

            /*-----------------------------------------------------+
             Query quantity tree get quantity available to reserve.
            +------------------------------------------------------*/
            l_stmt_num := 160;

            INV_QUANTITY_TREE_GRP.query_tree
                      (p_api_version_number => 1.0,
                       p_init_msg_lst       => fnd_api.g_false,
                       x_return_status      => l_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data,
                       p_tree_id            => l_tree_id,
                       p_revision           => NULL,
                       p_lot_number         => NULL,
                       p_subinventory_code  => NULL,
                       p_locator_id         => NULL,
                       x_qoh                => l_x_qoh,
                       x_rqoh               => l_x_rqoh,
                       x_qr                 => l_x_qr,
                       x_qs                 => l_x_qs,
                       x_att                => l_x_att,
                       x_atr                => x_available_qty);

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('create_reservation: ' || 'Failed in create_tree with status: ' ||
                                  l_return_status, 1);
                END IF;
                raise PROCESS_ERROR;
            end if;
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('create_reservation: ' || 'Success in query_tree.', 1);

            	oe_debug_pub.add('create_reservation: ' || 'l_x_qoh: ' || to_char(l_x_qoh));

            	oe_debug_pub.add('create_reservation: ' || 'l_x_rqoh: ' || to_char(l_x_rqoh));

            	oe_debug_pub.add('create_reservation: ' || 'x_available_qty: ' || to_char(x_available_qty));

            	oe_debug_pub.add('create_reservation: ' ||  ' config id ' || to_char(p_config_id ) ||
                               ' mfg_org_id ' || to_char( p_mfg_org_id ) , 1);
            END IF;

            l_stmt_num := 170;

            select msi.primary_uom_code
            into   l_primary_uom_code
            from   mtl_system_items msi
            where  msi.inventory_item_id = p_config_id
            and    msi.organization_id = p_mfg_org_id;

            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('create_reservation: ' ||  ' pri uom ' || l_primary_uom_code  ||
                               ' res uom ' || p_reservation_uom_code , 1);
            END IF;


            /*------------------------------------------------------
             The quantity query gives ATR in the primary uom code
             so we need to convert it to the same uom as the
             p_reservation_uom_code.
            +------------------------------------------------------*/
            IF (l_primary_uom_code <> p_reservation_uom_code) THEN
                l_stmt_num := 175;
                x_available_qty := INV_CONVERT.inv_um_convert
				( item_id	=> p_config_id,
                                  precision	=> 5,                      -- bugfix 2204376: pass precision of 5
                               	  from_quantity	=> x_available_qty,        -- from qty
                               	  from_unit	=> l_primary_uom_code,     -- from uom
                                  to_unit	=> p_reservation_uom_code, -- to uom
                               	  from_name	=> null,
                                  to_name	=> null);
            END IF;

            /*---------------------------------------------------------+
              p_automatic_reservation is TRUE when match and reserve is
              called from Order Import.  From Order Import, if a match
              is found, a reservation is made automatically if there
              is sufficient quantity.
            +---------------------------------------------------------*/
            if (x_available_qty > 0  )
            then
                l_stmt_num := 180;
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('create_reservation: ' || 'Entering Create Reservation. ',1);

                	oe_debug_pub.add('create_reservation: ' || 'Quantity to Rsrv: '
                                  || to_char(l_quantity_to_reserve ),1);

                	oe_debug_pub.add('create_reservation: ' || 'Quantity Available to Rsrv: '
                                  || to_char(x_available_qty),1);
                END IF;

                if( l_quantity_to_reserve > x_available_qty ) then

                    l_quantity_to_reserve := x_available_qty ;

                    l_partial_reservation := TRUE ;

                    IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('create_reservation: ' ||  'Going to attempt reservation for' ||
                                       to_char(l_quantity_to_reserve ));
                    END IF;


                end if ;

                l_stmt_num := 185;

		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('create_reservation: ' ||  'Time Stamp ' || to_char( sysdate , 'dd-mon-yyyy hh24:mi:ss' ));
		END IF;


                if (CTO_MATCH_AND_RESERVE.create_config_reservation
					(p_model_line_id	=> p_top_model_line_id,
                                       	 p_config_item_id	=> p_config_id,
                                       	 p_quantity_to_reserve	=> l_quantity_to_reserve,
                                         p_reservation_uom_code => p_reservation_uom_code,
                                         x_quantity_reserved	=> x_quantity_reserved,
                                       	 x_error_msg		=> l_x_error_msg,
                                         x_error_msg_name	=> l_x_error_msg_name) = TRUE)
                then
                    IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('create_reservation: ' || 'Success in Create Reservation. ',1);

                    	oe_debug_pub.add('create_reservation: ' || 'Matching Config Item: ' || to_char(p_config_id),1 );

                    	oe_debug_pub.add ('create_reservation: ' || 'Quantity On-Hand: ' || to_char(x_available_qty),1);

		    	oe_debug_pub.add('create_reservation: ' ||  'Time Stamp ' || to_char( sysdate , 'dd-mon-yyyy hh24:mi:ss' ));
		    END IF;


                    l_stmt_num := 190;

                    select segment1
		    into   l_config_item_name
                    from   mtl_system_items
                    where  inventory_item_id = p_config_id
		    and    organization_id = p_mfg_org_id ;


                    l_stmt_num := 195;

                    /*
                      BUG 1870761 commented for some time as
                       mtl_organizations view has severe performance
                       issues in TST115 environment 07-10-2001

                    select organization_name into l_organization_name
                    from mtl_organizations
                    where organization_id = p_mfg_org_id ;

                    */

                    /* reintroduced the organization_name in the message
                    ** as per bug#2320488 by using table
                    ** inv_organization_name_v
                    */
                    begin

                       select organization_name into l_organization_name
                         from inv_organization_name_v
                        where organization_id = p_mfg_org_id ;

                    exception
                    when others then

                        l_organization_name := to_char( p_mfg_org_id ) ;

                    end ;




                    IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('create_reservation: ' ||  'CTO_RESERVATION_SUCCESS for ' ||
                                       to_char(l_quantity_to_reserve) ||
                                       ' units for item ' || l_config_item_name ||
                                       ' in org ' || l_organization_name , 1 );
                    END IF;


                    l_stmt_num := 200;

                    if( p_mode = 'ONLINE' ) then


		       l_token(1).token_name  := 'QUANTITY';
		       l_token(1).token_value := l_quantity_to_reserve;
		       l_token(2).token_name  := 'CONFIG_ITEM';
		       l_token(2).token_value := l_config_item_name;
		       l_token(3).token_name  := 'SHIP_ORG';
		       l_token(3).token_value := l_organization_name;


                       cto_msg_pub.cto_message('BOM', 'CTO_RESERVATION_SUCCESS', l_token );
                       --fnd_message.set_token('QUANTITY', l_quantity_to_reserve );
                       --fnd_message.set_token('CONFIG_ITEM', l_config_item_name );
                       --fnd_message.set_token('SHIP_ORG', l_organization_name );

 		       l_token := CTO_MSG_PUB.G_MISS_TOKEN_TBL;	-- initialize


                       OE_STANDARD_WF.Save_Messages;
                       OE_STANDARD_WF.Clear_Msg_Context;

                    end if ;


                    l_stmt_num := 205;

                    if( l_partial_reservation ) then
                           x_reserve_status := 'PARTIAL' ;
                    else
                           x_reserve_status := 'COMPLETE' ;
                    end if ;

                    x_message_name := 'CTO_RESERVE';

                else
                    IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('create_reservation: ' || 'Failed in Create Reservation. ',1);
                    END IF;
                    cto_msg_pub.cto_message('BOM', l_x_error_msg ); /* BUGFIX#2342412 */
                    raise RESERVATION_ERROR;
                end if;

            else
                 /*--------------------------------------------------+
                 If available quantity to reserve is less than
                 zero, return with no option to reserve.
                 Otherwise, user has the option to reserve against
                 the ATR quantity.
                 +--------------------------------------------------*/

                 l_stmt_num := 210;

		 IF PG_DEBUG <> 0 THEN
		 	oe_debug_pub.add('create_reservation: ' ||  'Time Stamp ' || to_char( sysdate , 'dd-mon-yyyy hh24:mi:ss' ));

                 	oe_debug_pub.add('create_reservation: ' || 'Not Enough Qty to reserve. ',1);

                 	oe_debug_pub.add('create_reservation: ' || 'Quantity Available to Rsrv: '
                          || to_char(x_available_qty),1);
                 END IF;

                 x_message_name := 'CTO_CONFIG_LINKED';
                 x_error_message := 'Config Item Linked.  No Qty to Rsrv';

                 l_stmt_num := 215;

                 select segment1
		 into  l_config_item_name
                 from  mtl_system_items
                 where inventory_item_id = p_config_id
         	 and   organization_id = p_mfg_org_id ;


                 l_stmt_num := 220;

                 /*
                      BUG 1870761 commented for some time as
                       mtl_organizations view has severe performance
                       issues in TST115 environment 07-10-2001

                 select organization_name into l_organization_name
                 from mtl_organizations
                 where organization_id = p_mfg_org_id ;

                 */

                 /* reintroduced the organization_name in the message
                 ** as per bug#2320488 by using table
                 ** inv_organization_name_v
                 */
                 begin

                       select organization_name into l_organization_name
                         from inv_organization_name_v
                        where organization_id = p_mfg_org_id ;

                 exception
                 when others then

                        l_organization_name := to_char( p_mfg_org_id ) ;

                 end ;



                 IF PG_DEBUG <> 0 THEN
                 	oe_debug_pub.add('create_reservation: ' ||  'CTO_RESERVATION_FAILURE for ' || l_config_item_name ||
                                   ' in org ' || l_organization_name , 1 );
                 END IF;

                 l_stmt_num := 225;

                 if( p_mode = 'ONLINE' ) then

		     l_token(1).token_name  := 'CONFIG_ITEM';
		     l_token(1).token_value := l_config_item_name;
		     l_token(2).token_name  := 'SHIP_ORG';
		     l_token(2).token_value := l_organization_name;

                     cto_msg_pub.cto_message('BOM', 'CTO_RESERVATION_FAILURE', l_token);
                     --fnd_message.set_token('CONFIG_ITEM', l_config_item_name );
                     --fnd_message.set_token('SHIP_ORG', l_organization_name );

 		     l_token := CTO_MSG_PUB.G_MISS_TOKEN_TBL;	-- initialize

                     OE_STANDARD_WF.Save_Messages;
                     OE_STANDARD_WF.Clear_Msg_Context;

                 end if;

                 x_reserve_status := 'NOQTY' ;

             end if ;


        else

               l_stmt_num := 230;

	       IF PG_DEBUG <> 0 THEN
	       	oe_debug_pub.add('create_reservation: ' ||  'Time Stamp ' || to_char( sysdate , 'dd-mon-yyyy hh24:mi:ss' ));

               	oe_debug_pub.add('create_reservation: ' ||  'No reservation could be attempted for ' ||
                                 l_config_item_name , 1  );
               END IF;


               select segment1
	       into   l_config_item_name
               from   mtl_system_items
               where  inventory_item_id = p_config_id
	       and    organization_id = p_mfg_org_id ;
                /* fixed bug 1853597 to retrieve only one row for each item */

               l_stmt_num := 235;

               IF PG_DEBUG <> 0 THEN
               	oe_debug_pub.add('create_reservation: ' ||  'CTO_CONFIG_MATCH for item ' || l_config_item_name , 1  );
               END IF;

               if( p_mode = 'ONLINE' ) then

		   l_token(1).token_name  := 'CONFIG_ITEM';
		   l_token(1).token_value := l_config_item_name;

                   cto_msg_pub.cto_message('BOM', 'CTO_CONFIG_MATCH', l_token);
                   --fnd_message.set_token('CONFIG_ITEM', l_config_item_name );

 		   l_token := CTO_MSG_PUB.G_MISS_TOKEN_TBL;	-- initialize

                   OE_STANDARD_WF.Save_Messages;
                   OE_STANDARD_WF.Clear_Msg_Context;

               end if ;

               x_reserve_status := 'MATCH' ;

        end if ; /* check for full match */


	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('create_reservation: ' ||  'Time Stamp ' || to_char( sysdate , 'dd-mon-yyyy hh24:mi:ss' ));
	END IF;


EXCEPTION
        when RESERVATION_ERROR then
           --rollback to savepoint before_item_creation;
           IF PG_DEBUG <> 0 THEN
           	OE_DEBUG_PUB.add('create_reservation: ' || 'RESERVATION_ERROR ' , 1  );

           	OE_DEBUG_PUB.add('create_reservation: ' || 'CTO_WORKFLOW.create_reservation ' || to_char(l_stmt_num) );
           END IF;
           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;

           x_return_status := FND_API.G_RET_STS_ERROR ;


	when NO_DATA_FOUND then
           --rollback to savepoint before_item_creation;
           cto_msg_pub.cto_message('BOM', 'CTO_CREATE_ITEM_ERROR');
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('create_reservation: ' || 'CTO_WORKFLOW.create_reservation::ndf::' || to_char(l_stmt_num) );
           END IF;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


        when PROCESS_ERROR then
           --rollback to savepoint before_item_creation;

           IF PG_DEBUG <> 0 THEN
           	OE_DEBUG_PUB.add('create_reservation: ' || 'CTO_WORKFLOW.create_reservation ' || to_char(l_stmt_num) );
           END IF;

           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;

           x_return_status := FND_API.G_RET_STS_ERROR ;

        when FND_API.G_EXC_UNEXPECTED_ERROR then
           --rollback to savepoint before_item_creation;
           IF PG_DEBUG <> 0 THEN
           	OE_DEBUG_PUB.add('create_reservation: ' || 'CTO_WORKFLOW.create_reservation ' ||
                            to_char(l_stmt_num) || ':' ||
                            l_x_error_msg);
           END IF;
           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        when OTHERS then
           --rollback to savepoint before_item_creation;
           cto_msg_pub.cto_message('BOM', 'CTO_CREATE_ITEM_ERROR');
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('create_reservation: ' || 'CTO_WORKFLOW.create_reservation' ||
                            to_char(l_stmt_num) || ':' ||
                            substrb(sqlerrm, 1, 100));
           END IF;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


END CREATE_RESERVATION ;




/*============================================================================
        Procedure:    	rsv_before_booking_wf
        Description:  	This works only for an ATO item .
			This procedure gets called just before "Create supply order Eligble"
			activity  in the ATO workflow.
			The format follows the standard Workflow API format.

     	Parameters:
=============================================================================*/

PROCEDURE rsv_before_booking_wf (
        p_itemtype        in      VARCHAR2, /* item type */
        p_itemkey         in      VARCHAR2, /* config line id   */
        p_actid           in      NUMBER,   /* ID number of WF activity */
        p_funcmode        in      VARCHAR2, /* execution mode of WF activity */
        x_result      out NoCopy  VARCHAR2  /* result of activity    */
        )
IS

        l_stmt_num           	NUMBER;
        l_ResultStatus  	boolean;
        l_msg_count  		number;
        l_msg_data  		varchar2(2000);
        l_return_status  	varchar2(1);
        return_value 		INTEGER;

        --start bug#1861812

        v_item_type_code 	oe_order_lines_all.item_type_code%TYPE;
        v_ato_line_id 		oe_order_lines_all.ato_line_id%TYPE;


        v_header_id             oe_order_lines_all.header_id%type ;
        v_config_line_id        oe_order_lines_all.line_id%type ;


        l_hold_source_rec           OE_Holds_PVT.Hold_Source_REC_type;
        l_hold_release_rec           OE_Holds_PVT.Hold_release_REC_type;

        l_x_hold_result_out         Varchar2(30);
        l_x_hold_return_status      Varchar2(30);
        l_x_error_msg_count         Number;
        l_x_error_msg               Varchar2(2000);

        v_aps_version               number ;
BEGIN
        OE_STANDARD_WF.Set_Msg_Context(p_actid);
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('rsv_before_booking_wf: ' || 'CTO Activity: Check Reservation before booking activity ', 1);
        END IF;

        if (p_funcmode = 'RUN') then


          --
          -- start bugfix 1861812
          --
              l_stmt_num := 98;
              SELECT  item_type_code, ato_line_id , header_id, line_id
              INTO    v_item_type_code, v_ato_line_id, v_header_id , v_config_line_id
              FROM    oe_order_lines_all
              WHERE   line_id =  p_itemkey;





          /* Check for Activity Hold and convert it to regular hold
          ** Check where create_supply hold exists on the config line. Remove the create_supply hold
          ** apply regular AutoCreate Config Exception Hold.
          */







         v_aps_version := msc_atp_global.get_aps_version  ;

         oe_debug_pub.add('link_config: ' || 'APS version::'|| v_aps_version , 2);

         if( v_aps_version = 10 ) then


         oe_debug_pub.add( '*************************CHECKING HOLDS IN CHECK_RESERVATION_BEFORE_BOOKING ACTIVITY************ ' , 1) ;



          OE_HOLDS_PUB.Check_Holds (
                 p_api_version          => 1.0
                ,p_line_id              => v_config_line_id
                ,p_hold_id              => 61
                ,p_wf_item              => 'OEOL'
                ,p_wf_activity          => 'CREATE_SUPPLY'
                ,p_chk_act_hold_only    => 'Y'
                ,x_result_out           => l_x_hold_result_out
                ,x_return_status        => l_x_hold_return_status
                ,x_msg_count            => l_x_error_msg_count
                ,x_msg_data             => l_x_error_msg);

          IF (l_x_hold_return_status = FND_API.G_RET_STS_ERROR) THEN
                    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('CTOCITMB:Failed in Check Holds with expected error.' ,1);
                    END IF;
                    raise FND_API.G_EXC_ERROR;

          ELSIF (l_x_hold_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('CTOCITMB:Failed in Check Holds with unexpected error.' ,1);
                    END IF;
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;

          ELSE
                    IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('CTOCITMB:Success in Check Holds.' ,1);
                    END IF;

                    if l_x_hold_result_out = FND_API.G_TRUE then
                       IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('CTOCITMB:Create Supply Activity Hold exists on Config Line .' ,1);
                       END IF;

                       l_hold_source_rec.hold_entity_code   := 'O';
                       l_hold_source_rec.hold_id            := 61 ;
                       l_hold_source_rec.hold_entity_id     := v_header_id;
                       l_hold_source_rec.header_id          := v_header_id;
                       l_hold_source_rec.line_id            := v_config_line_id ;

                       l_hold_release_rec.release_reason_code :='CTO_AUTOMATIC';
                       --set created_by = 1  to indicate automatic hold release
                       l_hold_release_rec.created_by := 1;


                       OE_HOLDS_PUB.Release_Holds (
                            p_api_version          => 1.0
                           -- ,p_line_id              => v_config_line_id
                           -- ,p_hold_id              => 1063
                           ,p_hold_source_rec     => l_hold_source_rec
                           ,p_hold_release_rec     => l_hold_release_rec
                           ,x_return_status        => l_x_hold_return_status
                           ,x_msg_count            => l_x_error_msg_count
                           ,x_msg_data             => l_x_error_msg);

                       IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                           IF PG_DEBUG <> 0 THEN
                              oe_debug_pub.add('CTOCITMB:Failed in Release Holds with expected error.' ,1);
                           END IF;
                           raise FND_API.G_EXC_ERROR;

                       ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                           IF PG_DEBUG <> 0 THEN
                              oe_debug_pub.add('CTOCITMB:Failed in Release Holds with unexpected error.' ,1);
                           END IF;
                           raise FND_API.G_EXC_UNEXPECTED_ERROR;
                       END IF;

                       IF PG_DEBUG <> 0 THEN
                          oe_debug_pub.add('CTOCITMB: Hold Released on config line.' ,1);
                       END IF;




                       IF PG_DEBUG <> 0 THEN
                          oe_debug_pub.add('CTOCITMB:Calling OM api to apply hold.' ,1);
                       END IF;

                       l_hold_source_rec.hold_entity_code   := 'O';
                       l_hold_source_rec.hold_id            := 55 ;
                       l_hold_source_rec.hold_entity_id     := v_header_id;
                       l_hold_source_rec.header_id          := v_header_id;
                       l_hold_source_rec.line_id            := v_config_line_id;

                       OE_Holds_PUB.Apply_Holds (
                                   p_api_version        => 1.0
                               ,   p_hold_source_rec    => l_hold_source_rec
                               ,   x_return_status      => l_return_status
                               ,   x_msg_count          => l_msg_count
                               ,   x_msg_data           => l_msg_data);

                       IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                           IF PG_DEBUG <> 0 THEN
                              oe_debug_pub.add('CTOCITMB:Failed in Apply Holds with expected error.' ,1);
                           END IF;
                           raise FND_API.G_EXC_ERROR;

                       ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                           IF PG_DEBUG <> 0 THEN
                              oe_debug_pub.add('CTOCITMB:Failed in Apply Holds with unexpected error.' ,1);
                           END IF;
                           raise FND_API.G_EXC_UNEXPECTED_ERROR;
                       END IF;

                       IF PG_DEBUG <> 0 THEN
                          oe_debug_pub.add('CTOCITMB: An Exception Hold applied to config line.' ,1);
                       END IF;

                    else


                       IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('CTOCITMB:Create Supply Activity Hold does not exist on Config Line .' ,1);
                       END IF;

                    end if; /* if activity hold exists */


          END IF ; /* success in check holds */

          end if ; /* check for aps version */


             --if an ato item

              IF  ((upper(v_item_type_code) = 'STANDARD')
	           OR (upper(v_item_type_code) = 'OPTION')  --bug#1874380
	           --Adding INCLUDED item type code for SUN ER#9793792
		   OR (upper(v_item_type_code) = 'INCLUDED')
		  )
                   AND (v_ato_line_id = p_itemkey)
   	      THEN

             --end bug#1861812

 		/*-------------------------------------------------------------+
   			1.call procedure check_reservation_exists_ato_item  to see
			  if the reservation exists before "create supply order eligible" activity.
   			2.If the reservation exists , the work flow goes to "Ship_line" status
   			3.If reservation does not exists then the workflow goes to "Create
                  	  Supply Order Eligible" status.

		+--------------------------------------------------------------*/
                   l_stmt_num := 99;
		/* Bugfix 3075105: Instead of check_inv_rsv_exists, call check_rsv_exists
		   to check all reservations. If a reservation is found, progress thru
		   the Reserved path.

                   check_inv_rsv_exists(to_number(p_itemkey),
					l_ResultStatus,
					l_msg_count,
					l_msg_data,
					l_return_status);
		**/
		-- Bugfix 3075105 begin
                   check_rsv_exists(to_number(p_itemkey),
					l_ResultStatus,
					l_msg_count,
					l_msg_data,
					l_return_status);
		-- Bugfix 3075105 end

                   if ((l_ResultStatus=TRUE) and (l_return_status=FND_API.G_RET_STS_SUCCESS)) then

			  IF PG_DEBUG <> 0 THEN
			  	oe_debug_pub.add('rsv_before_booking_wf: ' || 'Reservation exists, completing flow with reserved', 2);
			  END IF;
                          x_result :='COMPLETE:RESERVED';

           		  --
			  --below code calls display_wf_status to update the correct
           		  --before booking and scheduling if item is reserved
           		  --
			  l_stmt_num := 100;
           		  return_value:= CTO_WORKFLOW_API_PK.display_wf_status(to_number(p_itemkey));

			  if return_value <> 1 then
	     			cto_msg_pub.cto_message('CTO', 'CTO_ERROR_FROM_DISPLAY_STATUS');
	       			raise FND_API.G_EXC_UNEXPECTED_ERROR;
          		  end if;

                   elsif ((l_ResultStatus=FALSE) and (l_return_status=FND_API.G_RET_STS_SUCCESS)) then
			  IF PG_DEBUG <> 0 THEN
			  	oe_debug_pub.add('rsv_before_booking_wf: ' || 'Reservation does not exist, completing flow with complete.', 2);
			  END IF;
                          x_result :='COMPLETE';

             	   elsif(l_return_status=FND_API.G_RET_STS_ERROR) then
			  IF PG_DEBUG <> 0 THEN
			  	oe_debug_pub.add('rsv_before_booking_wf: ' || 'returning from check_rsv_exists with expected error.', 2);
			  END IF;
                          RAISE FND_API.G_EXC_ERROR;

             	   elsif(l_return_status=FND_API.G_RET_STS_UNEXP_ERROR) then
			  IF PG_DEBUG <> 0 THEN
			  	oe_debug_pub.add('rsv_before_booking_wf: ' || 'returning from check_rsv_exists with unexpected error.', 2);
			  END IF;
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

             	   end if;
           --start bug#1861812

           --
           --if not an ato item complete with default flow
           --
           ELSE
                x_result :='COMPLETE';
           END IF;
           --end bug#1861812

    end if ; /*p_funcmode ='RUN"*/

    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;

EXCEPTION
        when FND_API.G_EXC_ERROR then
           IF PG_DEBUG <> 0 THEN
           	OE_DEBUG_PUB.add('rsv_before_booking_wf: ' || 'CTO_WORKFLOW.rsv_before_booking_wf ' || to_char(l_stmt_num) );
           END IF;
           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;
	   raise;	-- can be re-tried

        when FND_API.G_EXC_UNEXPECTED_ERROR then
           if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
           	FND_MSG_PUB.Add_Exc_Msg
            			(G_PKG_NAME
            			,'rsv_before_booking_wf'
            			);
           end if;

           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('rsv_before_booking_wf: ' || 'corresponds to unexpected error at called program check_inv_rsv_exists  '||'
					l_stmt_num :'|| l_stmt_num ||sqlerrm, 1);
           END IF;
           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;
           wf_core.context('CTO_WORKFLOW', 'rsv_before_booking_wf', p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
           raise;

         when OTHERS then
           if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
            	     FND_MSG_PUB.Add_Exc_Msg
            			(G_PKG_NAME
            			,'rsv_before_booking_wf'
            			);
           end if;
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('rsv_before_booking_wf: ' || 'error at rsv_before_booking_wf  ' || to_char(l_stmt_num)|| sqlerrm);
           END IF;
             /*-------------------------------------------+
              Error Information for Notification.
             +--------------------------------------------*/
           wf_core.context('CTO_WORKFLOW','rsv_before_booking_wf',p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
           raise;

END rsv_before_booking_wf;




/*============================================================================
        Procedure:    check_inv_rsv_exists
        Description:
		This procedure is being called from rsv_before_booking_wf API.
		This checks if inventory reservations exist for an
		ATO item before booking
===========================================================================*/
PROCEDURE  check_inv_rsv_exists
 (
         pLineId          in     number    ,
         x_ResultStatus   out    NoCopy  boolean  ,
         x_msg_count      out    NoCopy  number  ,
         x_msg_data       out    NoCopy  varchar2,
         x_return_status  out    NoCopy  varchar2
 )

is

	lReserveId   number;

BEGIN

    select reservation_id
    into   lReserveId
    from   mtl_reservations     mr,
           oe_order_lines_all   oel,
           oe_order_headers_all oeh,
           oe_transaction_types_all ota,
           oe_transaction_types_tl  otl,
           mtl_sales_orders     mso
    where  mr.demand_source_line_id = oel.line_id    --ato item line id
    and    oel.line_id              = pLineId
    and    oeh.header_id            = oel.header_id
    and    oeh.order_type_id        = ota.transaction_type_id
    and    ota.transaction_type_code='ORDER'
    and    ota.transaction_type_id  = otl.transaction_type_id
    and    oeh.order_number         = mso.segment1
    and    otl.name                 = mso.segment2
    and    otl.language 	    = (select language_code
					from fnd_languages
					where installed_flag = 'B')
    and    mso.sales_order_id       = mr.demand_source_header_id
    --and    mr.demand_source_type_id = INV_RESERVATION_GLOBAL.g_source_type_oe
    and    mr.demand_source_type_id = decode(oeh.source_document_type_id, 10,
						INV_RESERVATION_GLOBAL.g_source_type_internal_ord,
                                             	INV_RESERVATION_GLOBAL.g_source_type_oe)	--bugfix 1799874
    and    mr.reservation_quantity  > 0
    and supply_source_type_id     = INV_RESERVATION_GLOBAL.g_source_type_inv
    and rownum = 1;

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('check_inv_rsv_exists: ' || 'found that reservation exists before booking', 1);
    END IF;
    x_ResultStatus := TRUE;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

       when no_data_found then
              x_ResultStatus := FALSE;
              x_return_status := FND_API.G_RET_STS_SUCCESS;
              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add ('check_inv_rsv_exists: ' || 'no reservations before booking, this is not an error', 1);
              END IF;

      when others then
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add ('check_inv_rsv_exists: ' || 'unexpected error in called program check_inv_rsv_exists'|| sqlerrm , 1);
              END IF;
              if fnd_msg_pub.check_msg_level
                  (fnd_msg_pub.g_msg_lvl_unexp_error)
              then
                  fnd_msg_pub.Add_Exc_msg
                   ( 'CTO_WORKFLOW',
                     'check_inv_rsv_exists'
                    );
              end if;
              cto_msg_pub.count_and_get
                (
                   p_msg_count=>x_msg_count,
                   p_msg_data=>x_msg_data
                 );
end check_inv_rsv_exists;


--begin bugfix 3075105
/*============================================================================
        Procedure:    check_rsv_exists
        Description:
		This procedure is being called from rsv_before_booking_wf API.
		This checks if inventory reservations exist for an
		ATO item before booking
===========================================================================*/
PROCEDURE  check_rsv_exists
 (
         pLineId          in     number    ,
         x_ResultStatus   out    NoCopy  boolean  ,
         x_msg_count      out    NoCopy  number  ,
         x_msg_data       out    NoCopy  varchar2,
         x_return_status  out    NoCopy  varchar2
 )

is

	lRsvCount   number := 0;
	lFloCount   number := 0;

BEGIN

    select count(*)
    into   lRsvCount
    from   mtl_reservations     mr,
           oe_order_lines_all   oel,
           oe_order_headers_all oeh,
           oe_transaction_types_all ota,
           oe_transaction_types_tl  otl,
           mtl_sales_orders     mso
    where  mr.demand_source_line_id = oel.line_id    --ato item line id
    and    oel.line_id              = pLineId
    and    oeh.header_id            = oel.header_id
    and    oeh.order_type_id        = ota.transaction_type_id
    and    ota.transaction_type_code='ORDER'
    and    ota.transaction_type_id  = otl.transaction_type_id
    and    oeh.order_number         = mso.segment1
    and    otl.name                 = mso.segment2
    and    otl.language 	    = (select language_code
					from fnd_languages
					where installed_flag = 'B')
    and    mso.sales_order_id       = mr.demand_source_header_id
    --and    mr.demand_source_type_id = INV_RESERVATION_GLOBAL.g_source_type_oe
    and    mr.demand_source_type_id = decode(oeh.source_document_type_id, 10,
						INV_RESERVATION_GLOBAL.g_source_type_internal_ord,
                                             	INV_RESERVATION_GLOBAL.g_source_type_oe)
    and    mr.reservation_quantity  > 0
    and rownum = 1;


    if lRsvCount = 0  then
    	-- Check to see if reservns exist in wip_flow_schedules
    	select count(*)
    	into   lFloCount
    	from   wip_flow_schedules
    	where  demand_source_type = inv_reservation_global.g_source_type_oe
    	and    demand_source_line = to_char(pLineId)
    	and    status <> 2;    -- Flow Schedule status : 1 = Open  2 = Closed/Completed
    else
    	x_ResultStatus := TRUE;
    	x_return_status := FND_API.G_RET_STS_SUCCESS;
        IF PG_DEBUG <> 0 THEN
    	       oe_debug_pub.add ('check_rsv_exists: ' || 'MTL reservation exists before booking', 1);
        END IF;
	return;
    end if;

    if lFloCount > 0 then
    	x_ResultStatus := TRUE;
    	x_return_status := FND_API.G_RET_STS_SUCCESS;
        IF PG_DEBUG <> 0 THEN
    	       oe_debug_pub.add ('check_rsv_exists: ' || 'FLOW reservation exists before booking', 1);
        END IF;
    else
    	x_ResultStatus := FALSE;
    	x_return_status := FND_API.G_RET_STS_SUCCESS;
        IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add ('check_rsv_exists: ' || 'NO reservations before booking, this is not an error', 1);
        END IF;
    end if;

EXCEPTION

       when no_data_found then
              x_ResultStatus := FALSE;
              x_return_status := FND_API.G_RET_STS_SUCCESS;
              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add ('check_rsv_exists: ' || 'no reservations before booking, this is not an error', 1);
              END IF;

      when others then
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add ('check_rsv_exists: ' || 'unexpected error in called program check_inv_rsv_exists'|| sqlerrm , 1);
              END IF;
              if fnd_msg_pub.check_msg_level
                  (fnd_msg_pub.g_msg_lvl_unexp_error)
              then
                  fnd_msg_pub.Add_Exc_msg
                   ( 'CTO_WORKFLOW',
                     'check_inv_rsv_exists'
                    );
              end if;
              cto_msg_pub.count_and_get
                (
                   p_msg_count=>x_msg_count,
                   p_msg_data=>x_msg_data
                 );
end check_rsv_exists;

--end bugfix 3075105

/*============================================================================
obsolete ?
        Procedure:    check_reservation_status_wf
        Description:  This procedure gets called when executing the
                      Check Reservation activity in the ATO workflow.  The
                      format is follows the standard Workflow API format.

                      More to come...
     	Parameters:
=============================================================================*/
PROCEDURE check_reservation_status_wf(
        p_itemtype        in      VARCHAR2, /* item type */
        p_itemkey         in      VARCHAR2, /* config line id   */
        p_actid           in      number,   /* ID number of WF activity */
        p_funcmode        in      VARCHAR2, /* execution mode of WF activity */
        x_result      out NoCopy  VARCHAR2  /* result of activity    */
        )
IS

        l_stmt_num           NUMBER;
        l_mfg_org_id         NUMBER;
        l_config_item_id     NUMBER;
        l_x_bill_seq_id      NUMBER;
        l_status             INTEGER;
        l_return_status      VARCHAR2(1);
        l_header_id          NUMBER;
        l_flow_status_code   VARCHAR2(30);
        l_reserved_qty       NUMBER;
        l_qty                NUMBER;

        PROCESS_ERROR        EXCEPTION;
        UNEXP_ERROR          EXCEPTION;
BEGIN
        OE_STANDARD_WF.Set_Msg_Context(p_actid);
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('check_reservation_status_wf: ' || 'CTO Activity: Check Reservation', 1);
        END IF;

        if (p_funcmode = 'RUN') then

            /*-------------------------------------------------------------+
             Check the status of the configuration line.
             2.  If the Config BOM exists for this configuration
                  item.  This can happen if a match was performed.
                  If the BOM exists, the workflow goes to "Create
                  Supply Order Eligible" status.
             3.  Otherwise, workflow goes to Create Mfg Config Data Eligible.
            +--------------------------------------------------------------*/
            l_stmt_num := 50;
            select oel.inventory_item_id, oel.ship_from_org_id,
                   oel.header_id,
                   --(oel.ordered_quantity - oel.cancelled_quantity)		--bugfix 2017099
                   oel.ordered_quantity
            into   l_config_item_id, l_mfg_org_id, l_header_id,
                   l_qty
            from   oe_order_lines_all oel
            where  oel.line_id = to_number(p_itemkey);

            /*------------------------------------+
              Check if Config BOM exists.
             +------------------------------------*/

            l_stmt_num := 110;
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('check_reservation_status_wf: ' || 'Check For Config BOM ', 1);
            END IF;

            l_status := CTO_CONFIG_BOM_PK.check_bom(pItemId	=> l_config_item_id,
                                                    pOrgId	=> l_mfg_org_id,
                                                    xBillId	=> l_x_bill_seq_id);

            IF (l_status = 1) THEN
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('check_reservation_status_wf: ' || 'Config Data Created.', 1);
                END IF;
                x_result := 'COMPLETE:CREATED';
                l_flow_status_code := 'BOM_AND_RTG_CREATED';

            ELSE

                l_stmt_num := 130;
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('check_reservation_status_wf: ' || 'Config Data Not Created.',1);
                END IF;
                x_result := 'COMPLETE';
                l_flow_status_code := 'ITEM_CREATED';

            END IF;


            --
            -- It was agreed with OM that if we cannot get a lock
            -- on this line for update, we will not error out.
            --

            l_stmt_num := 140;
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('check_reservation_status_wf: ' || 'Calling flow status API ',1);
            END IF;
            OE_Order_WF_Util.Update_Flow_Status_Code(
                      p_header_id         => l_header_id,
                      p_line_id           => to_number(p_itemkey),
                      p_flow_status_code  => l_flow_status_code,
                      x_return_status     => l_return_status);

            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('check_reservation_status_wf: ' || 'Return from flow status API '
                              ||l_return_status,1);
            END IF;

       end if; /* p_funcmode = 'RUN' */

       OE_STANDARD_WF.Save_Messages;
       OE_STANDARD_WF.Clear_Msg_Context;

EXCEPTION
        when NO_DATA_FOUND then
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('check_reservation_status_wf: ' || 'Configuration Line Not Reserved.', 1);
             END IF;
             OE_STANDARD_WF.Save_Messages;
             OE_STANDARD_WF.Clear_Msg_Context;
             x_result := 'COMPLETE';

        when PROCESS_ERROR then
             IF PG_DEBUG <> 0 THEN
             	OE_DEBUG_PUB.add('check_reservation_status_wf: ' || 'CTO_WORKFLOW.check_reservation_status_wf ' ||
                              to_char(l_stmt_num) || ':' ||
                              substrb(sqlerrm, 1, 100));
             END IF;
             OE_STANDARD_WF.Save_Messages;
             OE_STANDARD_WF.Clear_Msg_Context;

        when UNEXP_ERROR then
             IF PG_DEBUG <> 0 THEN
             	OE_DEBUG_PUB.add('check_reservation_status_wf: ' || 'CTO_WORKFLOW.create_config_item_wf ' ||
                            to_char(l_stmt_num) || ':' ||
                            l_return_status);
             END IF;
             OE_STANDARD_WF.Save_Messages;
             OE_STANDARD_WF.Clear_Msg_Context;
             wf_core.context('CTO_WORKFLOW', 'create_config_item_wf',
                           p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
             raise;

        when OTHERS then
             cto_msg_pub.cto_message('BOM', 'CTO_CHECK_STATUS_ERROR');
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('check_reservation_status_wf: ' || 'CTO_WORKFLOW.check_reservation_status_wf ' ||
                              to_char(l_stmt_num) || ':' ||
                              substrb(sqlerrm, 1, 100));
             END IF;
             /*-------------------------------------------+
              Error Information for Notification.
             +--------------------------------------------*/
             wf_core.context('CTO_WORKFLOW', 'check_reservation_status_wf',
                             p_itemtype, p_itemkey, to_char(p_actid),
                             p_funcmode);
             raise;
END check_reservation_status_wf;



--
-- Procedure for multilevel testing
-- To be renamed after tested completely
--

PROCEDURE calculate_cost_rollup_wf_ml(
        p_itemtype        in      VARCHAR2, /*item type */
        p_itemkey         in      VARCHAR2, /* config line id    */
        p_actid           in      number,   /* ID number of WF activity  */
        p_funcmode        in      VARCHAR2, /* execution mode of WF activity*/
        x_result      out NoCopy  VARCHAR2  /* result of activity    */
        )
IS
        l_stmt_num              number := 0;
        l_x_msg_count		number;
        l_x_msg_data        	varchar2(2000);
        l_top_ato_line_id       number;
        l_status                integer;
	UNEXP_ERROR             exception;

BEGIN
       OE_STANDARD_WF.Set_Msg_Context(p_actid);
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('calculate_cost_rollup_wf_ml: ' || 'CTO Activity: Calculate Cost Rollup', 1);
       END IF;

       if (p_funcmode = 'RUN') then

          l_stmt_num := 135;

          select oel.ato_line_id
          into   l_top_ato_line_id
          from   oe_order_lines_all oel
          where  oel.line_id = to_number(p_itemkey);

	  IF PG_DEBUG <> 0 THEN
	  	oe_debug_pub.add('calculate_cost_rollup_wf_ml: ' || 'Cost rollup::top_ato_line_id::'||to_char(l_top_ato_line_id));
	  END IF;

          l_stmt_num := 140;
          l_status := CTO_CONFIG_COST_PK.cost_rollup_ml(
					pTopAtoLineId	=> l_top_ato_line_id,
                                        x_msg_count	=> l_x_msg_count,
                                        x_msg_data	=> l_x_msg_data);

          if (l_status = 0) then
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('calculate_cost_rollup_wf_ml: ' || 'Failure in cost_rollup ', 1);
             END IF;
             cto_msg_pub.cto_message('BOM', l_x_msg_data);
             raise UNEXP_ERROR;
          else
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('calculate_cost_rollup_wf_ml: ' || 'Success in cost_rollup ', 1);
             END IF;
          end if;

          x_result := 'COMPLETE';

       end if; /* end p_funcmode = 'RUN' */

       OE_STANDARD_WF.Save_Messages;
       OE_STANDARD_WF.Clear_Msg_Context;

EXCEPTION
    when UNEXP_ERROR then
       IF PG_DEBUG <> 0 THEN
       	OE_DEBUG_PUB.add('calculate_cost_rollup_wf_ml: ' || 'CTO_WORKFLOW.calculate_cost_rollup_wf' ||
                        to_char(l_stmt_num) || ':' ||
                        l_x_msg_data);
       END IF;
       OE_STANDARD_WF.Save_Messages;
       OE_STANDARD_WF.Clear_Msg_Context;
       wf_core.context('CTO_WORKFLOW', 'calculate_cost_rollup_wf',
                       p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
       raise;

    when NO_DATA_FOUND then
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('calculate_cost_rollup_wf_ml: ' || 'CTO_WORKFLOW.calculate_cost_rollup_wf ' ||
                         to_char(l_stmt_num) || ':' ||
                         substrb(sqlerrm, 1, 100),1);
       END IF;
       cto_msg_pub.cto_message('BOM', 'CTO_CALC_COST_ROLLUP_ERROR');
       OE_STANDARD_WF.Save_Messages;
       OE_STANDARD_WF.Clear_Msg_Context;

    when OTHERS then
       cto_msg_pub.cto_message('BOM', 'CTO_CALC_COST_ROLLUP_ERROR');
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('calculate_cost_rollup_wf_ml: ' || 'CTO_WORKFLOW.calculate_cost_rollup_wf ' ||
                         to_char(l_stmt_num) || ':' ||
                         substrb(sqlerrm, 1, 100),1);
       END IF;
       wf_core.context('CTO_WORKFLOW', 'calculate_cost_rollup_wf',
                       p_itemtype, p_itemkey, to_char(p_actid),
                       p_funcmode);
       raise;

END calculate_cost_rollup_wf_ml;




/*============================================================================
        Procedure:    set_parameter_lead_time_wf_ml
        Description:  This procedure gets called when executing the Calculate
                      Leadtime activity in the ATO workflow.  The
                      format is follows the standard Workflow API format.

                      More to come...
	Parameters:
=============================================================================*/
PROCEDURE set_parameter_lead_time_wf_ml(
        p_itemtype        in      VARCHAR2, /* workflow item type */
        p_itemkey         in      VARCHAR2, /* sales order line id */
        p_actid           in      number,   /* ID number of WF activity */
        p_funcmode        in      VARCHAR2, /* execution mode of WF activity */
        x_result      out NoCopy  VARCHAR2  /* result of activity */
        )
IS

        l_stmt_num             number := 0;
        l_config_item_id       number;
        l_mfg_org_code         varchar2(3);
        l_mfg_org_id           number;
        l_item_name            varchar2(40);
        l_x_error_msg_name     varchar2(30);
        l_x_error_msg          varchar2(2000);
        l_routing_count        number;
        l_x_rtg_id             number;
        l_x_rtg_type           number;


        /* Variables for the Workflow Item Attributes */
        l_req_id               number;
        lAtoLineId             number;

        l_status               integer;
        l_x_error_msg_count    number;
        l_x_hold_result_out    varchar2(1);
        l_x_hold_return_status varchar2(1);

        UNEXP_ERROR       exception;

BEGIN

        OE_STANDARD_WF.Set_Msg_Context(p_actid);
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('set_parameter_lead_time_wf_ml: ' || 'CTO Activity: Set Parameter lead Time', 1);
        END IF;

	if (p_funcmode = 'RUN') then

              /*-----------------------------------------------------+
               Prepare to calculate. Launch Calculate Manufacturing
               Lead Time concurrent program. Set Item Attributes
               as Parameters to Calculate Mfg Lead Time concurrent prg.
               +----------------------------------------------------*/

               /*----------------------------------------------+
                Assign Parameter Values to Parameters for
                Concurrent Program.
                +----------------------------------------------*/
               -- Line ID - We are using the Org parameter from
               -- the 11.5.1 workflow activity.

               select oel.ato_line_id
               into   lAtoLineId
               from   oe_order_lines_all oel
               where  line_id = to_number(p_itemkey);

               --wf_engine.SetItemAttrText(p_itemtype, p_itemkey,
               --                      'LEAD_TIME_ROLLUP_ORG', p_itemkey);
               wf_engine.SetItemAttrText(p_itemtype, p_itemkey,
                                   'LEAD_TIME_ROLLUP_ORG', to_char(lAtoLineId));

               IF PG_DEBUG <> 0 THEN
               	oe_debug_pub.add('set_parameter_lead_time_wf_ml: ' || 'Line ID: ' || p_itemkey, 1);

               	oe_debug_pub.add('set_parameter_lead_time_wf_ml: ' || 'ATO Line ID: ' || to_char(lAtoLineId), 1);
               END IF;

               x_result := 'COMPLETE';
	end if; /* p_funcmode = 'RUN' */

        OE_STANDARD_WF.Save_Messages;
        OE_STANDARD_WF.Clear_Msg_Context;

EXCEPTION

        when UNEXP_ERROR then
           IF PG_DEBUG <> 0 THEN
           	OE_DEBUG_PUB.add('set_parameter_lead_time_wf_ml: ' || 'CTO_WORKFLOW.set_parameter_lead_time_wf_ml' ||
                        to_char(l_stmt_num) || ':' ||
                        l_x_error_msg);
           END IF;
           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;
           wf_core.context('CTO_WORKFLOW', 'set_parameter_lead_time_wf_ml',
                           p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
           raise;

        when NO_DATA_FOUND then
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('set_parameter_lead_time_wf_ml: ' || 'CTO_WORKFLOW.set_parameter_lead_time_wf_ml'
                             || to_char(l_stmt_num) || ':' ||
                             substrb(sqlerrm, 1, 100),1);
           END IF;
           cto_msg_pub.cto_message('BOM', 'CTO_CALC_LEAD_TIME_ERROR');
           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;

         when OTHERS then
             cto_msg_pub.cto_message('BOM', 'CTO_CALC_LEAD_TIME_ERROR');
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('set_parameter_lead_time_wf_ml: ' || 'CTO_WORKFLOW.set_parameter_lead_time_wf_ml'
                               || to_char(l_stmt_num) || ':' ||
                               substrb(sqlerrm, 1, 100),1);
             END IF;
             wf_core.context('CTO_WORKFLOW', 'set_parameter_lead_time_wf_ml',
                             p_itemtype, p_itemkey, to_char(p_actid),
                             p_funcmode);
             raise;

END set_parameter_lead_time_wf_ml;


/*============================================================================
        Procedure:    check_supply_type_wf
        Description:  This procedure gets called when executing the Reserve
                      Configuration activity in the ATO workflow.  The
                      format is follows the standard Workflow API format.

                      More to come...
	Parameters:
=============================================================================*/



 -- The following procedure is modified by Renga Kannan on 08/29/01
 -- This procedure now looks at the Buy ATO item and Config item also.


PROCEDURE check_supply_type_wf(
        p_itemtype   in           VARCHAR2, /*item type */
        p_itemkey    in           VARCHAR2, /* config line id    */
        p_actid      in           number,   /* ID number of WF activity  */
        p_funcmode   in           VARCHAR2, /* execution mode of WF activity*/
        x_result     out  NoCopy  VARCHAR2  /* result of activity    */
        )
IS
        l_stmt_num             number := 0;
        l_supply_type          number;

        l_msg_name             varchar2(30);
        l_msg_txt              varchar2(2000);
        l_msg_count            number;
        l_inventory_item_id    Mtl_system_items.inventory_item_id%type;
        l_ship_from_org_id     Mtl_system_items.organization_id%type;
        l_item_type_code       Oe_order_lines_all.item_type_code%type;
        x_return_status        Varchar2(1);
        P_source_type          Number;
        p_sourcing_rule_exists Varchar2(1);

        p_transit_lead_time    Number;
        x_exp_error_code       Number;

        l_source_type_code     oe_order_lines.source_type_code%type ;

	--added by kkonada OPM
	 l_can_create_supply VARCHAR2(1);
	 l_return_status     VARCHAR2(1);
	 l_msg_data          VARCHAR2(2000);
	 l_sourcing_org	     number;
	 l_message           Varchar2(100);

	 l_ret_stat          number; --bugfix 4556596
         v_x_error_msg_count       NUMBER;
         v_x_hold_result_out       VARCHAR2(1);
         v_x_hold_return_status    VARCHAR2(1);
         v_x_error_msg             VARCHAR2(150);
BEGIN
    OE_STANDARD_WF.Set_Msg_Context(p_actid);
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('check_supply_type_wf: ' || 'CTO Activity: Check Supply Type', 1);

    	oe_debug_pub.add('check_supply_type_wf: ' || 'Item key = '||p_itemkey,1);

    	oe_debug_pub.add('check_supply_type_wf: ' || 'Func Mode ='||p_funcmode,1);
    END IF;

    if (p_funcmode = 'RUN') then
       l_stmt_num := 100;

      /*
      ** BUG#2234858
      ** need to retrieve source type code
      */
       BEGIN
         select inventory_item_id, ship_from_org_id,item_type_code, source_type_code
         into   l_inventory_item_id, l_ship_from_org_id,l_item_type_code, l_source_type_code
         from   oe_order_lines_all
         where  line_id = to_number(p_itemkey)
         and    ato_line_id is not null;
         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('check_supply_type_wf: ' || 'Inventory_item_id ='||to_char(l_inventory_item_id),1);

         	oe_debug_pub.add('check_supply_type_wf: ' || 'Ship from org id  ='||to_char(l_ship_from_org_id),1);

         	oe_debug_pub.add('check_supply_type_wf: ' || 'Item type code    ='||l_item_type_code,1);
         END IF;
      EXCEPTION
	WHEN NO_DATA_FOUND THEN
         	Null;
      END;

          -- check for hold on the line.
          -- Bug fix 5261330
	  -- Started checking for hold in this node
	  -- As this node will allways get executed for all supply types
	  -- It is more effecient to check in this node and remove the hold check
	  -- from  the respective supply creation nodes


          OE_HOLDS_PUB.Check_Holds(p_api_version   => 1.0,
                                   p_line_id       => to_number(p_itemkey),
				   p_wf_item       => 'OEOL',
                                   p_wf_activity   => 'CREATE_SUPPLY',
                                   x_result_out    => v_x_hold_result_out,
                                   x_return_status => v_x_hold_return_status,
                                   x_msg_count     => v_x_error_msg_count,
                                   x_msg_data      => v_x_error_msg);

          IF (v_x_hold_return_status = FND_API.G_RET_STS_ERROR) THEN
              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('Check_supply_type_wf: ' || 'Expected error in Check Hold: ' || v_x_hold_return_status, 1);
              END IF;
              RAISE FND_API.G_EXC_ERROR;

          ELSIF (v_x_hold_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('Check_supply_type_wf: ' || 'Unexp error in Check Hold ' || v_x_hold_return_status, 1);
              END IF;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

          ELSE
              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('Check_supply_type_wf: ' || 'Success in Check Hold ' || v_x_hold_return_status, 5);
              END IF;

              IF (v_x_hold_result_out = FND_API.G_TRUE) THEN
                  IF PG_DEBUG <> 0 THEN
                  	oe_debug_pub.add('Check_supply_type_wf: ' || 'Order Line ID ' || p_itemkey || 'is on HOLD. ' ||v_x_hold_result_out, 1);
                  END IF;
                  cto_msg_pub.cto_message('BOM', 'CTO_ORDER_LINE_ON_HOLD');
           	  x_result := 'COMPLETE:INCOMPLETE';
                  return;
              END IF;
          END IF;



      /*
      ** BUG#2234858
      ** need to branch on source type for drop ship functionality
      */
      IF( l_source_type_code = 'EXTERNAL' )
      THEN

         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('check_supply_type_wf: ' || 'It is Config item Drop Ship case...',1);
         END IF;
         x_result := 'COMPLETE:DROPSHIP';
         OE_STANDARD_WF.Save_Messages;
         OE_STANDARD_WF.Clear_Msg_Context;
         return;


      END IF ;



      -- get the sourcing type of the item in the specified organization.
      l_stmt_num := 200;
      -- Call the procedure to return the sourcing rule.

        l_stmt_num := 200;
      --OPM
      --Check if Cto can create supply
      --query sourcing org is replaced with this new prcoedure
      --by KKONADA
       CTO_UTILITY_PK.check_cto_can_create_supply
			(
			P_config_item_id    =>	l_inventory_item_id,
			P_org_id 	    =>	l_ship_from_org_id,
			x_can_create_supply =>  l_can_create_supply,
			p_source_type       =>  p_source_type,
			x_return_status     =>  l_return_status,
			X_msg_count	    =>	l_msg_count,
			X_msg_data          =>	l_msg_data,
			x_sourcing_org	    =>  l_sourcing_org,
			x_message           =>  l_message
			);

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('check_supply_type_wf: ' ||
					'Expected Error in check_cto_can_create_supply.',1);
         END IF;
         raise FND_API.G_EXC_ERROR;

      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('check_supply_type_wf: ' ||
					'Unexpected Error in check_cto_can_create_supply.',1);
         END IF;
         raise FND_API.G_EXC_UNEXPECTED_ERROR;

      END IF;

      l_stmt_num := 210;

      -- rkaza. ireq project. 05/02/2005.
      -- if CTO cannot create supply, let planning create the supply and
      -- move the workflow to ship line.

      --Kiran Konada
      --If code flow is at this point , it means L-return_status was a SUCCESS

      IF l_can_create_supply = 'N' THEN
         IF PG_DEBUG <> 0 THEN

		oe_debug_pub.add('check_supply_type_wf: ' ||l_message,1);

         END IF;
         x_result := 'COMPLETE:PLANNING';

         l_stmt_num := 220;

         --start bugfix 4556596
         IF PG_DEBUG <> 0 THEN
	   oe_debug_pub.add('check_supply_type_wf: ' ||'calling display_wf_status with status',1);
	 END IF;

         l_ret_stat :=CTO_WORKFLOW_API_PK.display_wf_status
	               (p_order_line_id=>p_itemkey
			);

         IF l_ret_stat = 1 THEN
	        oe_debug_pub.add('check_supply_type_wf: ' ||'call to display_wf_status success',1);
                cto_wip_workflow_api_pk.cto_debug('DISPLAY_WF_STATUS', 'call to display_wf_status success.');

	 Elsif l_ret_stat = 0 THEN

            IF PG_DEBUG <> 0 THEN

		oe_debug_pub.add('check_supply_type_wf: ' ||'call to display_wf_status failed',1);
		oe_debug_pub.add('check_supply_type_wf: ' ||'l_ret_stat=> '||l_ret_stat,1);

		cto_wip_workflow_api_pk.cto_debug('DISPLAY_WF_STATUS', 'call to display_wf_status failed.');
		cto_wip_workflow_api_pk.cto_debug('DISPLAY_WF_STATUS', 'l_ret_stat=> '||l_ret_stat);

		raise FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
	 END IF;

         --end bugfix 4556596

         OE_STANDARD_WF.Save_Messages;
         OE_STANDARD_WF.Clear_Msg_Context;
         return;
      END IF;



      l_stmt_num := 300;


      -- Modified by Renga Kannan on 02/06/02 for autocreate req for model
      -- rkaza. Use buy branch for 100% transfer rule case also.

      IF p_source_type in (1, 3) THEN   /* ATO Buy and IR cases */
         IF PG_DEBUG <> 0 THEN
	    if p_source_type = 3 then
         	oe_debug_pub.add('check_supply_type_wf: ' || 'It is ATO Buy case...',1);
	    else
         	oe_debug_pub.add('check_supply_type_wf: ' || 'It is ATO internal transfer case...',1);
	    end if;
         END IF;
         x_result := 'COMPLETE:BUY';
         OE_STANDARD_WF.Save_Messages;
         OE_STANDARD_WF.Clear_Msg_Context;
         return;
      END IF;

      l_stmt_num := 400;

      select NVL(cfm_routing_flag,2)
      into   l_supply_type
      from   oe_order_lines_all oel,
             bom_operational_routings bor
      where  oel.line_id = to_number(p_itemkey)
      and    oel.inventory_item_id = bor.assembly_item_id (+)
      and    oel.ship_from_org_id = bor.organization_id (+)
      and    bor.alternate_routing_designator (+) is NULL;

      --- Fixed bug 4197665
      --- replaced to_char(l_supply_type,1) with to_char(l_supply_type)

      if (l_supply_type = 1) then
          -- Flow Schedule
          IF PG_DEBUG <> 0 THEN
          	oe_debug_pub.add('check_supply_type_wf: ' || 'Routing Type is Flow Schedule. ' ||
                         to_char (l_supply_type),1);
          END IF;
          x_result := 'COMPLETE:FLOW_SCHEDULE';
      else
          -- Discrete Job
          IF PG_DEBUG <> 0 THEN
          	oe_debug_pub.add('check_supply_type_wf: ' || 'Routing Type is Discrete Job or No Routing. ' ||
                           to_char (l_supply_type),1);
          END IF;
          x_result := 'COMPLETE:WORK_ORDER';
      end if;

      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('check_supply_type_wf: ' || 'Success in Check Supply Type', 1);
      END IF;

    end if; /* end p_funcmode = 'RUN'*/
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;

EXCEPTION

        when FND_API.G_EXC_ERROR then
           IF PG_DEBUG <> 0 THEN
           	OE_DEBUG_PUB.add('check_supply_type_wf: ' || 'CTO_WORKFLOW.check_supply_type_wf ' ||
                            to_char(l_stmt_num));
           END IF;
           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;
           x_result := 'COMPLETE:INCOMPLETE';


        when FND_API.G_EXC_UNEXPECTED_ERROR then
           IF PG_DEBUG <> 0 THEN
           	OE_DEBUG_PUB.add('check_supply_type_wf: ' || 'CTO_WORKFLOW.check_supply_type_wf ' ||
                            to_char(l_stmt_num));
           END IF;
           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;
           wf_core.context('CTO_WORKFLOW', 'check_supply_type_wf',
                           p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
           raise;

        when OTHERS then
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('check_supply_type_wf: ' || 'CTO_WORKFLOW.check_supply_type_wf' ||
                            to_char(l_stmt_num)||':'||sqlerrm);       --bugfix 3136206
           END IF;
           wf_core.context('CTO_WORKFLOW', 'check_supply_type_wf',
                           p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);

           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;

           raise;

END check_supply_type_wf;




/*============================================================================
        Procedure:    create_flow_schedule__wf
        Description:  This procedure gets called when executing the
                      Create Flow Schedule  activity in the CTO workflow.


                      More to come...
	Parameters:
=============================================================================*/
PROCEDURE create_flow_schedule_wf(
        p_itemtype        in      VARCHAR2, /* workflow item type */
        p_itemkey         in      VARCHAR2, /* sales order line id */
        p_actid           in      number,   /* ID number of WF activity */
        p_funcmode        in      VARCHAR2, /* execution mode of WF activity */
        x_result      out NoCopy  VARCHAR2  /* result of activity */
        )
IS

        l_stmt_num                number := 0;
        l_msg_count               number;
        l_msg_txt                 varchar2(2000);
        l_msg_name                varchar2(60);
        l_quantity                number := 0;
	l_sch_ship_date		  date;
        l_header_id               number;
        l_ship_iface_flag         varchar2(1);
        l_x_return_status         varchar2(1);
        l_x_error_msg_count       number;
        l_x_hold_result_out       varchar2(1);
        l_x_hold_return_status    varchar2(1);
        l_x_error_msg             varchar2(150);
	l_source_document_type_id number;	--bugfix 1799874


BEGIN
      SAVEPOINT before_process;

      OE_STANDARD_WF.Set_Msg_Context(p_actid);
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('create_flow_schedule_wf: ' || 'CTO Activity: Create Flow Schedule', 1);
      END IF;

      if (p_funcmode = 'RUN') then
          /*----------------------------------------------------------+
          Check order line status and check order line  for holds.
          Do not process the order if status is invalid or
          if a hold is found.
          +-----------------------------------------------------------*/
          if (validate_config_line(to_number(p_itemkey)) <> TRUE) then
              cto_msg_pub.cto_message('BOM','CTO_LINE_STATUS_NOT_ELIGIBLE');
              raise FND_API.G_EXC_ERROR;
          end if;

	  --bugfix 1799874 start
	  l_source_document_type_id := CTO_UTILITY_PK.get_source_document_id ( pLineId => to_number(p_itemkey) );
	  --bugfix 1799874 end


          l_stmt_num := 110;
          --select (oel.ordered_quantity - nvl(oel.cancelled_quantity, 0))
          select oel.ordered_quantity 						--bufix 2017099
          into   l_quantity
          from   oe_order_lines_all oel
          where  oel.line_id = to_number(p_itemkey)
          and    exists (select '1'
                         from   bom_operational_routings bor
                         where  bor.assembly_item_id = oel.inventory_item_id
                         and    bor.organization_id = oel.ship_from_org_id
                         and    bor.alternate_routing_designator is null
                         and    nvl(bor.cfm_routing_flag, 2) = 1)
          and    not exists (select '1'
                         from   mtl_reservations mr
                         where  mr.demand_source_line_id = oel.line_id
                         and    mr.organization_id = oel.ship_from_org_id
                         --and    mr.demand_source_type_id  =  inv_reservation_global.g_source_type_oe
                         and    mr.demand_source_type_id  =
                                   decode (l_source_document_type_id, 10, inv_reservation_global.g_source_type_internal_ord,
					   inv_reservation_global.g_source_type_oe )	-- bugfix 1799874
                         and    mr.reservation_quantity > 0);

          if (l_quantity <= 0) then
      	      IF PG_DEBUG <> 0 THEN
      	      	oe_debug_pub.add('create_flow_schedule_wf: ' || 'l_quantity <= 0', 1);
      	      END IF;
              cto_msg_pub.cto_message('BOM','CTO_CREATE_FLOW_SCHED_ERROR');
              raise FND_API.G_EXC_ERROR;
          end if;

          l_stmt_num := 120;
          -- Removed check hold API call from here as we are going to check for
	  -- hold in check_supply_type_wf workflow activity, which is just before this workflow
	  -- node
	  -- Removed as part of bug fix 5261330

          l_stmt_num := 130;
	  --
	  -- MRP will not create flow schedules if the scheduled ship date is
	  -- earlier than today
	  --
	  select schedule_ship_date, header_id
	  into l_sch_ship_date, l_header_id
	  from oe_order_lines_all oel
	  where line_id = to_number(p_itemkey);

	  if  (trunc(l_sch_ship_date) < trunc(sysdate)) then
	       IF PG_DEBUG <> 0 THEN
	       	oe_debug_pub.add('create_flow_schedule_wf: ' || 'Schedule ship date '||
                                 to_char(l_sch_ship_date)||',
                                 is earlier than sysdate');
	       END IF;
               cto_msg_pub.cto_message('BOM', 'CTO_INVALID_SCH_DATE');
	       x_result := 'COMPLETE:INCOMPLETE';
	       return;

          end if;

          CTO_FLOW_SCHEDULE.cto_fs(
				p_config_line_id	=> p_itemkey,
                                x_return_status		=> l_x_return_status,
                                x_msg_name		=> l_msg_name,
                                x_msg_txt		=> l_msg_txt);



          IF (l_x_return_status = FND_API.G_RET_STS_ERROR) THEN
              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('create_flow_schedule_wf: ' || 'Expected error in cto_fs. ', 1);
              END IF;
              cto_msg_pub.cto_message('BOM', l_msg_name);
              raise FND_API.G_EXC_ERROR;

          ELSIF (l_x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('create_flow_schedule_wf: ' || 'Unexpected error in Create Flow Schedule for line id ' || p_itemkey, 1);
              END IF;
              cto_msg_pub.cto_message('BOM', l_msg_name);
              raise FND_API.G_EXC_UNEXPECTED_ERROR;

          END IF;

	  --
	  -- check if flow schedules have been scheduled for this line
	  --

	  if Flow_Sch_Exists(to_number(p_itemkey)) then
                OE_Order_WF_Util.Update_Flow_Status_Code(
                      p_header_id         => l_header_id,
                      p_line_id           => to_number(p_itemkey),
                      p_flow_status_code  => 'PRODUCTION_OPEN',
                      x_return_status     => l_x_return_status);

          	x_result := 'COMPLETE';
	  else
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('create_flow_schedule_wf: ' || 'Flow schedules not created');
		END IF;
              	cto_msg_pub.cto_message('BOM', 'CTO_NO_FLOW_SCHEDULE');
		x_result := 'COMPLETE:INCOMPLETE';
		return;
	  end if;
     end if; /* p_funcmode = 'RUN' */

     OE_STANDARD_WF.Save_Messages;
     OE_STANDARD_WF.Clear_Msg_Context;

EXCEPTION

        when FND_API.G_EXC_ERROR then
           IF PG_DEBUG <> 0 THEN
           	OE_DEBUG_PUB.add('create_flow_schedule_wf: ' || 'CTO_WORKFLOW.create_flow_schedule_wf raised exp error in stmt ' ||
                            to_char(l_stmt_num) || ':' || l_x_error_msg);
           END IF;
           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;
	   x_result := 'COMPLETE:INCOMPLETE';
           rollback to savepoint before_process;
	   return;

        when NO_DATA_FOUND then
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('create_flow_schedule_wf: ' || 'CTO_WORKFLOW.create_flow_schedule_wf '
                               || to_char(l_stmt_num) || ':' ||
                               substrb(sqlerrm, 1, 100),1);
           END IF;
           cto_msg_pub.cto_message('BOM', 'CTO_CREATE_FLOW_SCHED_ERROR');
           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;
	   x_result := 'COMPLETE:INCOMPLETE';
           rollback to savepoint before_process;
	   return;

        when FND_API.G_EXC_UNEXPECTED_ERROR then
           IF PG_DEBUG <> 0 THEN
           	OE_DEBUG_PUB.add('create_flow_schedule_wf: ' || 'CTO_WORKFLOW.create_flow_schedule_wf raised unexp error in stmt ' ||
                            to_char(l_stmt_num) || ':' || l_x_error_msg);
           END IF;
           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;
	   raise;

         when OTHERS then
           cto_msg_pub.cto_message('BOM', 'CTO_CREATE_FLOW_SCHED_ERROR');
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('create_flow_schedule_wf: ' || 'CTO_WORKFLOW.create_flow_schedule_wf '
                               || to_char(l_stmt_num) || ':' ||
                               substrb(sqlerrm, 1, 250),1);
           END IF;
           wf_core.context('CTO_WORKFLOW', 'create_flow_schedule_wf',
                             p_itemtype, p_itemkey, to_char(p_actid),
                             p_funcmode);
           raise;

END create_flow_schedule_wf;


--  begin bugfix 2105156

--  PROCEDURE   Lock_Line_Id
--
--  Usage   	Used by set_parameter_work_order_wf API to update the program_id
--              This is done to manually 'lock' the line.
--
--  Desc	This procedure is set for autonomous transaction.
--              This procedure accepts line_id.
--
--  Note        This procedure uses autonomous transaction.That means
--              commit or rollback with in this procedure will not affect
--              the callers transaction.

PROCEDURE lock_line_id(p_line_id IN  NUMBER,
                       x_result  OUT NoCopy VARCHAR2 )
IS
    Pragma AUTONOMOUS_TRANSACTION;

    record_locked          EXCEPTION;
    pragma exception_init (record_locked, -54);
    l_dummy 		   VARCHAR2(2);

BEGIN

    x_result := null;

    -- select to see if we can acquire lock. If we cannot, it will raise RECORD_LOCKED exception.

    SELECT '1' into l_dummy
    FROM   oe_order_lines_all
    WHERE  line_id = p_line_id
    FOR UPDATE NOWAIT;

    UPDATE oe_order_lines_all oel
    SET    oel.program_id = -99
    WHERE  oel.line_id = p_line_id
    AND    nvl(oel.program_id, 0) <> -99;

    COMMIT;
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('lock_line_id: ' || 'committed program_id with -99');
    END IF;

EXCEPTION
    when no_data_found then
	null;

    when record_locked then
	IF PG_DEBUG <> 0 THEN
		OE_DEBUG_PUB.add ('lock_line_id: ' || 'CTO_WORKFLOW.Lock_Line_Id: Could not lock line id '|| p_line_id ||' for update.');

        	OE_DEBUG_PUB.add ('lock_line_id: ' || 'This line is being processed by another process.');
        END IF;
	x_result := 'COMPLETE:INCOMPLETE';

    when others then
	IF PG_DEBUG <> 0 THEN
		OE_DEBUG_PUB.add ('lock_line_id: ' || 'CTO_WORKFLOW.Lock_Line_Id: Unexpected Error : '||sqlerrm);
	END IF;
	x_result := 'COMPLETE:INCOMPLETE';

END Lock_Line_Id;

--  end bugfix 2105156


-- bugfix 3136206: we want to make this as autonomous txn, otherwise, these changes will get rolledback due
-- to exception in main api which does a rollback to savepoint.

PROCEDURE unlock_line_id(p_line_id IN  NUMBER,
                         x_result  OUT NoCopy VARCHAR2 )
IS
    Pragma AUTONOMOUS_TRANSACTION;

    record_locked          EXCEPTION;
    pragma exception_init (record_locked, -54);
    l_dummy 		   VARCHAR2(2);

BEGIN

    x_result := null;

    UPDATE oe_order_lines_all oel
    SET    oel.program_id = null
    WHERE  oel.line_id = p_line_id
    AND    nvl(oel.program_id, 0) = -99;

    IF (sql%rowcount > 0) THEN
	COMMIT;
        IF (PG_DEBUG <> 0) THEN
    	     oe_debug_pub.add ('unlock_line_id: ' || 'unlocked line_id '||p_line_id);
        END IF;
    END IF;

EXCEPTION

    when others then
	IF PG_DEBUG <> 0 THEN
		OE_DEBUG_PUB.add ('unlock_line_id: error: ' || sqlerrm);

        END IF;
	x_result := 'COMPLETE:INCOMPLETE';

END UnLock_Line_Id;

-- end bugfix 3136206

/*============================================================================
        Procedure:    set_parameter_work_order_wf

        Description:  This procedure gets called when executing the Set
                      Parameter Work Order activity in the ATO workflow.

                      More to come...
	Parameters:
=============================================================================*/
PROCEDURE set_parameter_work_order_wf(
        p_itemtype        in      VARCHAR2, /* workflow item type */
        p_itemkey         in      VARCHAR2, /* sales order line id */
        p_actid           in      number,   /* ID number of WF activity */
        p_funcmode        in      VARCHAR2, /* execution mode of WF activity */
        x_result      out NoCopy  VARCHAR2  /* result of activity */
        )
IS

        l_stmt_num        	number := 0;
        l_quantity        	number := 0;
        l_class_code      	number;
        l_wip_group_id    	number;
        l_mfg_org_id      	number;
        l_afas_line_id    	number;
        l_msg_name        	varchar2(30);
        l_msg_txt         	varchar2(500);		--bugfix 2776026: increased the var size
	l_return_status   	varchar2(1);
        l_user_id         	varchar2(30);
        l_msg_count       	number;
        l_hold_result_out 	varchar2(1);
        l_hold_return_status  	varchar2(1);
        l_ship_iface_flag 	varchar2(1);

	l_source_document_type_id number;	-- bugfix 1799874

        --fix for bug#1874380
        l_item_type_code    	varchar2(30);
        l_ato_line_id       	number;
        l_line_id            	number;
	l_top_model_line_id  	number;
        --end of  fix for bug#1874380



        -- bugfix 2053360 : declare a new exception
        record_locked          	exception;
        pragma exception_init (record_locked, -54);

  	l_result 		varchar2(20) := null; 		--bugfix 2105156

	l_build_in_wip varchar2(1); --bugfix 2318060

BEGIN

        savepoint before_process;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('set_parameter_work_order_wf: ' || 'Function Mode: ' || p_funcmode, 1);

        	oe_debug_pub.add('set_parameter_work_order_wf: ' || 'CTO Activity: Set Parameter Work Order', 1);
        END IF;
        OE_STANDARD_WF.Set_Msg_Context(p_actid);

        if (p_funcmode = 'RUN') then

           -- Note: bugfix 3136206: The Lock_Line_Id api should be called BEFORE the SELECT FOR UPDATE
	  -- since it is executed in autonomous transaction mode. Autonomous txns are run in
	  -- different sessions. If this api is called after SELECT FOR UPDATE, then it will fail.

	  --
	  -- begin bugfix 2105156: Call lock_line_Id to manually lock the row if possible.
	  -- Lock_Line_Id API will update the program_id in oeol to -99.
	  -- if you cannot, raise RECORD_LOCKED exception
	  --


	  Lock_Line_Id ( to_number(p_itemkey), l_result );
	  if ( l_result is not null ) then
		raise record_locked;
	  end if;


	  --bugfix 1799874 start
	  l_source_document_type_id := CTO_UTILITY_PK.get_source_document_id ( pLineId => to_number(p_itemkey) );
	  --bugfix 1799874 end

            /*----------------------------------------------------------+
             Check order line status and check order line  for holds.
             Do not process the order if status is invalid or
             if a hold is found.
            +-----------------------------------------------------------*/
            l_stmt_num := 100;
            --select oel.ordered_quantity - nvl(oel.cancelled_quantity, 0),
            select oel.ordered_quantity, 					-- bugfix 2017099
                   oel.ship_from_org_id,
                   oel.ato_line_id,--5108885
		   oel.ato_line_id, oel.line_id,oel.top_model_line_id, oel.item_type_code          --fix for bug#1874380
            into   l_quantity, l_mfg_org_id, l_afas_line_id, l_ato_line_id, l_line_id,
                   l_top_model_line_id,l_item_type_code
            from   mtl_system_items msi,
                   oe_order_lines_all oel
            where  oel.line_id = to_number(p_itemkey)
            and    (oel.open_flag is null
                   or oel.open_flag = 'Y')
            and    oel.ordered_quantity > 0
            and    oel.inventory_item_id = msi.inventory_item_id
            and    msi.organization_id = oel.ship_from_org_id
            and    oel.schedule_status_code = 'SCHEDULED'
            and    oel.booked_flag = 'Y'
            and    oel.ato_line_id is not null
            --and    oel.shipping_interfaced_flag = 'Y'
            and    msi.replenish_to_order_flag = 'Y'
            and    msi.pick_components_flag = 'N'
            and    msi.build_in_wip_flag = 'Y'
            and    msi.bom_item_type = 4
            /*----------------------------------+
              ATO items do not have to have
              a base model.
            and    msi.base_item_id is not NULL
            +-----------------------------------*/
            and    not exists
                     (select '1'
                      from   oe_order_lines_all oel2
                      where  oel2.ship_from_org_id = oel.ship_from_org_id
                      and    oel2.header_id      = oel.header_id
                      and    oel2.line_id        = oel.line_id
                      and    rownum = 1
                      and    WIP_ATO_UTILS.check_wip_supply_type(
						oel2.header_id,
                             			oel2.line_id,
						NULL,
						oel2.ship_from_org_id)
                             not in (0,1)
                      )
            and    not exists
                     (select '1'
                      from   bom_operational_routings bor
                      where  bor.assembly_item_id = oel.inventory_item_id
                      and    bor.organization_id = oel.ship_from_org_id
                      and    bor.alternate_routing_designator is null
                      and    nvl(bor.cfm_routing_flag, 2) = 1)
            and    not exists
                     (select '1'
                      from   mtl_reservations mr
                      where  mr.demand_source_line_id = oel.line_id
                      and    mr.organization_id = oel.ship_from_org_id
                      --and    mr.demand_source_type_id  = inv_reservation_global.g_source_type_oe
                      and    mr.demand_source_type_id  =
                                   decode (l_source_document_type_id, 10, inv_reservation_global.g_source_type_internal_ord,
					   inv_reservation_global.g_source_type_oe )	-- bugfix 1799874
                      and    mr.reservation_quantity > 0)
	    FOR UPDATE OF oel.line_id NOWAIT;		--bugfix 2053360



            if (l_quantity <= 0) then
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('set_parameter_work_order_wf: ' || 'Ordered quantity is zero.', 1);
                END IF;
                cto_msg_pub.cto_message('BOM', 'CTO_CREATE_WORK_ORDER_ERROR');
                raise FND_API.G_EXC_ERROR;
            end if;

            l_stmt_num := 101;

            -- Removed check hold API call from here as we are going to check for
	  -- hold in check_supply_type_wf workflow activity, which is just before this workflow
	  -- node
	  -- Removed as part of bug fix 5261330
--            wf_engine.SetItemAttrNumber(p_itemtype, p_itemkey,
--                                    'AFAS_ORG_ID',l_mfg_org_id);
--            oe_debug_pub.add('mfg_org_id: ' || to_char(l_mfg_org_id),1);

            wf_engine.SetItemAttrNumber(p_itemtype, p_itemkey,
                                    'AFAS_LINE_ID', l_afas_line_id);
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('set_parameter_work_order_wf: ' || 'order_line_id: ' || p_itemkey,1);

            	oe_debug_pub.add('set_parameter_work_order_wf: ' || 'l_afas_line_id: ' || l_afas_line_id);
            END IF;

            x_result := 'COMPLETE';
        end if; /* p_funcmode = 'RUN' */

        OE_STANDARD_WF.Save_Messages;
        OE_STANDARD_WF.Clear_Msg_Context;

EXCEPTION

	 --
	 -- begin bugfix 2053360: handle the record_locked exception
	 --

         when record_locked then
           cto_msg_pub.cto_message('BOM', 'CTO_ORDER_LINE_LOCKED');
           IF PG_DEBUG <> 0 THEN
           	OE_DEBUG_PUB.add ('set_parameter_work_order_wf: ' || 'CTO_WORKFLOW.set_parameter_work_order_wf: Could not lock line id '||
				 p_itemkey ||' for update.');

           	OE_DEBUG_PUB.add ('set_parameter_work_order_wf: ' || 'This line is being processed by another process.');
           END IF;

           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;
           x_result := 'COMPLETE:INCOMPLETE';
           return;


        when FND_API.G_EXC_ERROR then
	   unlock_line_id (p_itemkey, x_result);	-- bugfix 3136206
           IF PG_DEBUG <> 0 THEN
           	OE_DEBUG_PUB.add('set_parameter_work_order_wf: ' || 'CTO_WORKFLOW.set_parameter_work_order_wf raised exc error. ' ||
                            to_char(l_stmt_num) );
           END IF;
           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;
           x_result := 'COMPLETE:INCOMPLETE';
           rollback to savepoint before_process;
	   return;


        when FND_API.G_EXC_UNEXPECTED_ERROR then
	   unlock_line_id (p_itemkey, x_result);	-- bugfix 3136206
           cto_msg_pub.cto_message('BOM', 'CTO_CREATE_WORK_ORDER_ERROR');
           IF PG_DEBUG <> 0 THEN
           	OE_DEBUG_PUB.add('set_parameter_work_order_wf: ' || 'CTO_WORKFLOW.set_parameter_work_order_wf raised unexc error. ' ||
                            to_char(l_stmt_num) );
           END IF;
           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;
           wf_core.context('CTO_WORKFLOW', 'set_parameter_work_order_wf',
                           p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
           raise;


         when NO_DATA_FOUND then
	      unlock_line_id (p_itemkey, x_result);	-- bugfix 3136206

	      --start bugfix 2318060
	      BEGIN
	         SELECT build_in_wip_flag
		 INTO   l_build_in_wip
		 FROM   mtl_system_items mtl,
		        Oe_order_lines_all oel
		 WHERE  oel.line_id = to_number(p_itemkey)
		 AND    oel.inventory_item_id = mtl.inventory_item_id
		 AND    oel.ship_from_org_id  = mtl.organization_id;
	      EXCEPTION
	         WHEN others THEN
                   null;

	      END;

	      IF l_build_in_wip = 'N' THEN
	        --set the build in wip flag
	        cto_msg_pub.cto_message('BOM', 'CTO_BUILD_IN_WIP_FLAG');
		IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('set_parameter_work_order_wf: ' || 'CTO_WORKFLOW.set_parameter_work_order_wf:'
                               ||'ERROR : Buld_in_wip_flag needs to be checked',1  );
	        END IF;

	      ELSE--no_data_found is for someother reason

                cto_msg_pub.cto_message('BOM', 'CTO_CREATE_WORK_ORDER_ERROR');
		IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('set_parameter_work_order_wf: ' || 'CTO_WORKFLOW.set_parameter_work_order_wf'
                               || to_char(l_stmt_num) || ':' ||
                               substrb(sqlerrm, 1, 100),1);
	        END IF;
              END IF;

	      --end bugfix 2318060

              OE_STANDARD_WF.Save_Messages;
              OE_STANDARD_WF.Clear_Msg_Context;

		-- Begin bugfix 2053360:
		-- Set the result to INCOMPLETE so that the wf returns to Create Supply Order Eligible
              x_result := 'COMPLETE:INCOMPLETE';
	      return;

         when OTHERS then
	      unlock_line_id (p_itemkey, x_result);	-- bugfix 3136206
              cto_msg_pub.cto_message('BOM', 'CTO_CREATE_WORK_ORDER_ERROR');
              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('set_parameter_work_order_wf: ' || 'CTO_WORKFLOW.set_parameter_work_order_wf: '
                               || to_char(l_stmt_num) || ':' ||
                               substrb(sqlerrm, 1, 100));
              END IF;
              wf_core.context('CTO_WORKFLOW', 'set_parameter_work_order_wf',
                              p_itemtype, p_itemkey, to_char(p_actid),
                              p_funcmode);

              raise;

END set_parameter_work_order_wf;


/*============================================================================
        Procedure:    submit_conc_prog_wf
        Description:  This procedure gets called for the Lead Time Calculate and
                      the AutoCreate FAS workflow activities.  It is a wrapper
                      around the Workflow activity that submits the concurrent
                      program via Workflow.  The wrapper is needed to retrieve
                      and display the concurrent request ID after Workflow
                      submits the request.
=============================================================================*/
PROCEDURE submit_conc_prog_wf(
        p_itemtype        in      VARCHAR2, /* workflow item type */
        p_itemkey         in      VARCHAR2, /* sales order line id */
        p_actid           in      number,   /* ID number of WF activity */
        p_funcmode        in      VARCHAR2, /* execution mode of WF activity */
        x_result      out NoCopy  VARCHAR2  /* result of activity */

        )
IS

        l_stmt_num            number := 0;
        l_req_id              number := 0;
        l_msg_name            varchar2(30);
        l_msg_txt             varchar2(2000);
	l_token 	      CTO_MSG_PUB.token_tbl;
	l_cnt                 number;  --bug 9679523

BEGIN

        OE_STANDARD_WF.Set_Msg_Context(p_actid);
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('submit_conc_prog_wf: ' || 'CTO Activity:  submit_conc_prog_wf.',1);
		oe_debug_pub.add('submit_conc_prog_wf: ' || 'p_item_type: ' || p_itemtype, 1);
                oe_debug_pub.add('submit_conc_prog_wf: ' || 'p_itemkey: ' || p_itemkey, 1);
                oe_debug_pub.add('submit_conc_prog_wf: ' || 'p_actid: ' || p_actid, 1);
                oe_debug_pub.add('submit_conc_prog_wf: ' || 'p_funcmode: ' || p_funcmode, 1);
        END IF;

	-- Bugfix 9288692
	-- An update is needed again in case of retry activity. During the first run of AFAS, if there is
        -- an error, the program_id is updated to null. When the AFAS activity is retried, the line
        -- doesn't get picked up because the program_id is null.

	UPDATE oe_order_lines_all
          SET program_id = -99
            WHERE line_id = to_number(p_itemkey)
              AND NVL(program_id, 0) <> -99;

        IF PG_DEBUG <> 0 THEN
	   if sql%rowcount > 0 then
	       oe_debug_pub.add ('submit_conc_prog_wf: ' || 'updated program_id to -99');
           end if;
	END IF;

	--
        -- bug 9679523
        -- Delete completed data from WJSI to support retry
        --
        DELETE FROM WIP_INTERFACE_ERRORS
         WHERE INTERFACE_ID IN (
           SELECT INTERFACE_ID
             FROM   WIP_JOB_SCHEDULE_INTERFACE
             WHERE  source_line_id = to_number(p_itemkey)
             AND    PROCESS_PHASE = 4
             AND    PROCESS_STATUS = 4);

	l_cnt := sql%rowcount;
	IF PG_DEBUG <> 0 THEN
	   if sql%rowcount > 0 then
	       oe_debug_pub.add ('submit_conc_prog_wf: ' || 'Rows deleted from wie:' || l_cnt);
           end if;
	END IF;

        DELETE FROM WIP_JOB_SCHEDULE_INTERFACE I
         WHERE source_line_id = to_number(p_itemkey)
            AND   I.PROCESS_PHASE = 4
            AND   I.PROCESS_STATUS = 4;

	l_cnt := sql%rowcount;
	IF PG_DEBUG <> 0 THEN
	   if sql%rowcount > 0 then
	       oe_debug_pub.add ('submit_conc_prog_wf: ' || 'Rows deleted from wjsi:' || l_cnt);
           end if;
	END IF;


        if (p_funcmode = 'RUN') then

            l_stmt_num := 100;
            fnd_wf_standard.ExecuteConcProgram(p_itemtype,
                                               p_itemkey,
                                               p_actid,
                                               p_funcmode,
                                               x_result);

            /*---------------------------------------------------------------+
               Get Request ID - We are using the same item attribute to store
               the request ID of the Lead Time conc prog and AFAS conc prog.
            +-----------------------------------------------------------------*/
            l_stmt_num := 110;
            l_req_id := wf_engine.GetItemAttrNumber(p_itemtype, p_itemkey,
                                   'LEAD_TIME_REQUEST_ID');

            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('submit_conc_prog_wf: ' || 'Request ID: ' || to_char(l_req_id), 1);
            END IF;

	    l_token(1).token_name  := 'REQUEST_ID';
	    l_token(1).token_value := l_req_id;

	    --oe_debug_pub.add ('1. l_token(1).name = '|| l_token(1).token_name);
	    --oe_debug_pub.add ('1. l_token(1).value = '|| l_token(1).token_value);

            cto_msg_pub.cto_message('BOM', 'CTO_CONCURRENT_REQUEST', l_token);
            --fnd_message.set_token('REQUEST_ID', l_req_id);

 	    l_token := CTO_MSG_PUB.G_MISS_TOKEN_TBL;	-- initialize

            OE_STANDARD_WF.Save_Messages;
            OE_STANDARD_WF.Clear_Msg_Context;

        end if;

EXCEPTION

     when NO_DATA_FOUND then
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('submit_conc_prog_wf: ' || 'CTO_WORKFLOW.submit_conc_prog_wf: '
                        || to_char(l_stmt_num) || ':' ||
                        substrb(sqlerrm, 1, 100));
       END IF;
       wf_core.context('CTO_WORKFLOW', 'submit_conc_prog_wf',
                       p_itemtype, p_itemkey, to_char(p_actid),
                       p_funcmode);
       raise;

     when OTHERS then
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('submit_conc_prog_wf: ' || 'CTO_WORKFLOW.submit_conc_prog_wf: '
                        || to_char(l_stmt_num) || ':' ||
                        substrb(sqlerrm, 1, 100));
       END IF;
       wf_core.context('CTO_WORKFLOW', 'submit_conc_prog_wf',
                       p_itemtype, p_itemkey, to_char(p_actid),
                       p_funcmode);
       raise;

END submit_conc_prog_wf;

/*============================================================================
        Procedure:    submit_and_continue_wf
        Description:  This procedure gets called for the Lead Time Calculate and
                      the AutoCreate FAS workflow activities.  It is a wrapper
                      around the Workflow activity that submits the concurrent
                      program via Workflow.  The wrapper is needed to retrieve
                      and display the concurrent request ID after Workflow
                      submits the request.
=============================================================================*/
PROCEDURE submit_and_continue_wf(
        p_itemtype        in      VARCHAR2, /* workflow item type */
        p_itemkey         in      VARCHAR2, /* sales order line id */
        p_actid           in      number,   /* ID number of WF activity */
        p_funcmode        in      VARCHAR2, /* execution mode of WF activity */
        x_result     out  NoCopy  VARCHAR2  /* result of activity */

        )
IS

        l_stmt_num            number := 0;
        l_req_id              number := 0;
        l_msg_name            varchar2(30);
        l_msg_txt             varchar2(2000);
	l_token 	      CTO_MSG_PUB.token_tbl;

	l_activity_status	varchar2(100);

	l_conc_msg		number := 0;

BEGIN

        OE_STANDARD_WF.Set_Msg_Context(p_actid);
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('submit_and_continue_wf: ' || 'CTO Activity:  submit_conc_prog_wf.',1);
        END IF;

        if (p_funcmode = 'RUN') then

		l_stmt_num := 10;
		CTO_WORKFLOW_API_PK.query_wf_activity_status(
					p_itemtype		=> p_itemtype,
					p_itemkey		=> p_itemkey,
					p_activity_label	=> 'EXECLEADTIME',
					p_activity_name		=> 'EXECLEADTIME',
					p_activity_status	=> l_activity_status);

		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('submit_and_continue_wf: ' || 'EXECLEADTIME activity status:'||l_activity_status,1);
		END IF;

		IF l_activity_status = 'ACTIVE' THEN
			l_conc_msg := 1;
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('submit_and_continue_wf: ' || 'Show message for Lead Time conc program',1);
			END IF;
		ELSE
			CTO_WORKFLOW_API_PK.query_wf_activity_status(
					p_itemtype		=> p_itemtype,
					p_itemkey		=> p_itemkey,
					p_activity_label	=> 'EXECUTECONCPROGAFAS',
					p_activity_name		=> 'EXECUTECONCPROGAFAS',
					p_activity_status	=> l_activity_status);
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('submit_and_continue_wf: ' || 'EXECUTECONCPROGAFAS activity status:'||l_activity_status,1);
			END IF;
			IF l_activity_status = 'ACTIVE' THEN
				l_conc_msg := 2;
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add('submit_and_continue_wf: ' || 'Show message for AFAS conc program',1);
				END IF;
			ELSE
				l_conc_msg := 1;
			END IF;
		END IF;

            	l_stmt_num := 100;
            	fnd_wf_standard.SubmitConcProgram(p_itemtype,
                                               p_itemkey,
                                               p_actid,
                                               p_funcmode,
                                               x_result);

            	/*---------------------------------------------------------------+
            	   Get Request ID - We are using the same item attribute to store
            	   the request ID of the Lead Time conc prog and AFAS conc prog.
            	+-----------------------------------------------------------------*/
            	l_stmt_num := 110;
            	l_req_id := wf_engine.GetItemAttrNumber(p_itemtype, p_itemkey,
            	                       'LEAD_TIME_REQUEST_ID');

            	IF PG_DEBUG <> 0 THEN
            		oe_debug_pub.add('submit_and_continue_wf: ' || 'Request ID: ' || to_char(l_req_id), 1);
            	END IF;

	    	l_token(1).token_name  := 'REQUEST_ID';
	    	l_token(1).token_value := l_req_id;

            	--oe_debug_pub.add('l_token(1).token_name = '||l_token(1).token_name );
            	--oe_debug_pub.add('l_token(1).token_value = '||l_token(1).token_value );
		IF l_conc_msg = 2 THEN
			cto_msg_pub.cto_message('BOM', 'CTO_CONCURRENT_REQUEST',l_token);
		ELSE
            		cto_msg_pub.cto_message('BOM', 'CTO_CONCURRENT_REQUEST_ID',l_token);
		END IF;

            	--fnd_message.set_token('REQUEST_ID', l_req_id);

 	    	l_token := CTO_MSG_PUB.G_MISS_TOKEN_TBL;	-- initialize

            	OE_STANDARD_WF.Save_Messages;
            	OE_STANDARD_WF.Clear_Msg_Context;

        end if;

EXCEPTION

     when NO_DATA_FOUND then
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('submit_and_continue_wf: ' || 'CTO_WORKFLOW.submit_conc_prog_wf: '
                        || to_char(l_stmt_num) || ':' ||
                        substrb(sqlerrm, 1, 100));
       END IF;
       wf_core.context('CTO_WORKFLOW', 'submit_conc_prog_wf',
                       p_itemtype, p_itemkey, to_char(p_actid),
                       p_funcmode);
       raise;

     when OTHERS then
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('submit_and_continue_wf: ' || 'CTO_WORKFLOW.submit_conc_prog_wf: '
                        || to_char(l_stmt_num) || ':' ||
                        substrb(sqlerrm, 1, 100));
       END IF;
       wf_core.context('CTO_WORKFLOW', 'submit_conc_prog_wf',
                       p_itemtype, p_itemkey, to_char(p_actid),
                       p_funcmode);
       raise;

END submit_and_continue_wf;


/*============================================================================
	Procedure:    validate_line
	Description:

	      More to come...
	Parameters:
=============================================================================*/
FUNCTION validate_line(
        p_line_id   in number

        )
RETURN boolean

IS

	l_valid_model_line NUMBER := 0;
        v_aps_version number ;

BEGIN


          v_aps_version := msc_atp_global.get_aps_version ;

          /*------------------------------------------------------------+
          Select line details to make sure the model line is valid.
          +------------------------------------------------------------*/
          select 1
	  into   l_valid_model_line
	  from   oe_order_lines_all oel,
		 mtl_system_items msi
          where  oel.line_id = p_line_id
	  and    msi.organization_id = oel.ship_from_org_id
          and    msi.inventory_item_id = oel.inventory_item_id
	  and    msi.bom_item_type = 1
          --and    msi.build_in_wip_flag = 'Y'
          and    msi.replenish_to_order_flag = 'Y'
	  and    oel.open_flag = 'Y'
	  and    (oel.cancelled_flag = 'N'
              or  oel.cancelled_flag is null)
          and    ( oel.booked_flag = 'Y'   or v_aps_version >= 10 )
          and   schedule_ship_date is not null  /* Fixed bug 3548069 */
          and    (
                      (      oel.schedule_status_code = 'SCHEDULED'
                      and    oel.source_type_code = 'INTERNAL'
                      and    oel.visible_demand_flag = 'Y'
                      )
                 OR  ( oel.source_type_code = 'EXTERNAL' )
                 ) ; /* BUG#2234858 additional changes  Made by sushant for Drop Ship */

          --and    oel.item_type_code = 'MODEL';

          if (l_valid_model_line > 0 ) then
              return TRUE;
          else
              return FALSE;
          end if;

EXCEPTION

      when NO_DATA_FOUND then
         return FALSE;


      when OTHERS then
          return FALSE;

END validate_line;


/*============================================================================
	Procedure:    validate_config_line
	Description:  This procedure gets called when executing the Match
                      Configuration activity in the ATO workflow.  The
                      format is follows the standard Workflow API format.

		      More to come...
	Parameters:
=============================================================================*/
FUNCTION validate_config_line(
        p_config_line_id   in number
        )
RETURN boolean

IS

	l_valid_config_line NUMBER := 0;


BEGIN

          /*------------------------------------------------------------+
          Select line details to make sure the config line is valid.
          +------------------------------------------------------------*/
          select 1
	  into   l_valid_config_line
	  from   oe_order_lines_all oel,
		 mtl_system_items msi
          where  oel.line_id = p_config_line_id
	  and    msi.organization_id = oel.ship_from_org_id
          and    oel.inventory_item_id = msi.inventory_item_id
	  and    msi.bom_item_type = 4
          and    msi.build_in_wip_flag = 'Y'
          and    msi.replenish_to_order_flag = 'Y'
	  and    oel.open_flag = 'Y'
	  and    (oel.cancelled_flag = 'N'
               or oel.cancelled_flag is null)
          and    oel.visible_demand_flag = 'Y'
          and    oel.booked_flag = 'Y'
          and    oel.schedule_status_code = 'SCHEDULED'
          and    ( oel.item_type_code = 'CONFIG' OR
                    --Adding INCLUDED item type code for SUN ER#9793792
		    ( oel.item_type_code in ('STANDARD','OPTION','INCLUDED') AND  --bugfix#2111718
                        oel.ato_line_id = p_config_line_id ) );

          if (l_valid_config_line > 0 ) then
              return TRUE;
          else
              return FALSE;
          end if;

EXCEPTION

     when NO_DATA_FOUND then
         return FALSE;

     when OTHERS then
         return FALSE;
END validate_config_line;



/*============================================================================
        Procedure:    config_line_exists
        Description:  This procedure gets called when executing the Match
                      Configuration activity in the ATO workflow.  The
                      format is follows the standard Workflow API format.

                      More to come...

        Parameters:
=============================================================================*/
FUNCTION config_line_exists(
        p_model_line_id   in number
        )
RETURN boolean

IS
       l_config_item NUMBER := 0;

BEGIN
       select 1
       into   l_config_item
       from   oe_order_lines_all oelM,
              oe_order_lines_all oelC
       where  oelM.line_id = p_model_line_id
       and    oelC.ato_line_id = oelM.line_id
       and    oelC.item_type_code = 'CONFIG';

       if (l_config_item > 0) then
           return TRUE;
       end if;

EXCEPTION
    when NO_DATA_FOUND then
         return FALSE;

     when OTHERS then
         return FALSE;

end config_line_exists;





procedure config_item_created_wf(
        p_itemtype        in      VARCHAR2, /*w workflow item type */
        p_itemkey         in      VARCHAR2, /* config line id */
        p_actid           in      NUMBER,   /* ID number of WF activity */
        p_funcmode        in      VARCHAR2, /* execution mode of WF activity */
        x_result    out NoCopy    VARCHAR2  /* result of activity */
        )
is
begin
   if( config_line_exists( p_itemkey) ) then
       -- x_result := 'COMPLETE:COMPLETE' ;
        x_result := 'COMPLETE:CONFIG_CREATED' ;

   else

       -- x_result := 'COMPLETE:INCOMPLETE' ;
        x_result := 'COMPLETE:CONFIG_NOT_CREATED' ;

   end if;



end config_item_created_wf ;

/*============================================================================
        Procedure:    reservation_exists
        Description:  This procedure gets called when executing the Match
                      Configuration activity in the ATO workflow.  The
                      format is follows the standard Workflow API format.

                      More to come...

        Parameters:
=============================================================================*/
FUNCTION reservation_exists(
        p_config_line_id   in number,
        x_reserved_qty     out NoCopy number
        )
RETURN boolean

IS
        x_reserved_quantity  NUMBER := 0;
	l_source_document_type_id NUMBER;	-- bugfix 1799874

BEGIN

       --bugfix 1799874 start
       l_source_document_type_id := CTO_UTILITY_PK.get_source_document_id ( pLineId => p_config_line_id );
       --bugfix 1799874 end

       select sum(nvl(mrs.reservation_quantity,0))
       into   x_reserved_quantity
       from   mtl_system_items msi,
              oe_order_lines_all oel,
              mtl_reservations mrs
       where  oel.line_id = p_config_line_id
       and    oel.open_flag = 'Y'
       --and    (oel.ordered_quantity - oel.cancelled_quantity) > 0
       and    oel.ordered_quantity  > 0					-- bugfix 2017099
       and    oel.inventory_item_id = msi.inventory_item_id
       and    msi.organization_id = oel.ship_from_org_id
       and    oel.item_type_code = 'CONFIG'
       and    oel.schedule_status_code = 'SCHEDULED'
       and    oel.booked_flag = 'Y'
       and    (oel.cancelled_flag = 'N'
           or  oel.cancelled_flag is null)
       and    msi.replenish_to_order_flag = 'Y'
       and    msi.pick_components_flag = 'N'
       and    msi.bom_item_type = 4
       and    msi.base_item_id is not NULL
       and    mrs.demand_source_line_id = oel.line_id
       and    mrs.demand_source_header_id is not NULL
       and    mrs.organization_id = oel.ship_from_org_id
       --and    mrs.demand_source_type_id  = inv_reservation_global.g_source_type_oe
       and    mrs.demand_source_type_id  =
                    decode (l_source_document_type_id, 10, inv_reservation_global.g_source_type_internal_ord,
			    inv_reservation_global.g_source_type_oe )	-- bugfix 1799874
       and    mrs.supply_source_type_id =
                    inv_reservation_global.g_source_type_inv
       and    mrs.reservation_quantity > 0
       group by oel.line_id;

       return TRUE;

EXCEPTION
    when NO_DATA_FOUND then
         return FALSE;

     when OTHERS then
         return FALSE;

end reservation_exists;

function flow_sch_exists(pLineId  in number)
return boolean
is

	lWipEntityId   number;

begin

    select wip_entity_id
    into   lWipEntityId
    from   wip_flow_schedules   wfs,
           oe_order_lines_all   oel,
           oe_order_headers_all oeh,
           oe_transaction_types_all ota,
           oe_transaction_types_tl  otl,
           mtl_sales_orders     mso
    where  wfs.demand_source_line   = to_char(pLineId)    --config line id
    and    oel.line_id              = pLineId
    and    oeh.header_id            = oel.header_id
    and    oeh.order_type_id        = ota.transaction_type_id
    and    ota.transaction_type_code='ORDER'
    and    ota.transaction_type_id  = otl.transaction_type_id
    and    oeh.order_number         = mso.segment1
    and    otl.name                 = mso.segment2
    and    otl.language = (select language_code
			from fnd_languages
			where installed_flag = 'B')
    and    mso.sales_order_id       = wfs.demand_source_header_id
    and    oel.inventory_item_id    = wfs.primary_item_id
    and rownum = 1;

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('flow_sch_exists: ' || 'Flow Schedule Exists!', 1);
    END IF;
    return TRUE;  -- Flow Schedule  exists

exception
    when no_data_found then

         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add ('flow_sch_exists: ' || 'Flow Schedules does not exist ', 1);
         END IF;
         return FALSE;     -- Flow Schedule does not exist

    when  others then
         return FALSE;

end flow_sch_exists;



PROCEDURE Purchase_price_calc_wf(
        p_itemtype        in      VARCHAR2, /* workflow item type */
        p_itemkey         in      VARCHAR2, /* sales order line id */
        p_actid           in      number,   /* ID number of WF activity */
        p_funcmode        in      VARCHAR2, /* execution mode of WF activity */
        x_result     out  NoCopy  VARCHAR2  /* result of activity */

        )
IS
	xreturnstatus		varchar2(1);
	xmsgcount	        Number;
	xmsgdata     		Varchar2(800);
	x_oper_unit_list        cto_auto_procure_pk.oper_unit_tbl;
	L_STMT_NUM	        Number;
	l_ato_line_id     	Number;
	l_batch_no	  	Number;
BEGIN

        OE_STANDARD_WF.Set_Msg_Context(p_actid);
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('Purchase_price_calc_wf: ' || 'CTO Activity:  Purchase Price Calc wf.',1);
        END IF;

	select ato_line_id
	into   l_ato_line_id
	from   oe_order_lines_all
	where  line_id  = p_itemkey;

        if (p_funcmode = 'RUN') then
               /*
        	CTO_AUTO_PROCURE_PK.Create_Purchasing_Doc(
                                                p_top_model_line_id     => l_ato_line_id,
                                                p_overwrite_list_price  => 'N',
                                                p_called_in_batch       => 'N',
                                                p_batch_number          => l_batch_no,
						p_ato_line_id           => l_ato_line_id,
                                                x_oper_unit_list        => x_oper_unit_list,
                                                x_return_status         => xReturnStatus,
                                                x_msg_count             => XMsgCount,
                                                x_msg_data              => xmsgdata);

        	if xreturnstatus = FND_API.G_RET_STS_ERROR then
           		IF PG_DEBUG <> 0 THEN
           			oe_debug_pub.add('Purchase_price_calc_wf: ' || ' Failed in Create_purchasing_doc call...',1);
           		END IF;
          		-- raise FND_API.G_EXC_ERROR;
        	elsif xreturnstatus =  FND_API.G_RET_STS_UNEXP_ERROR then
          		IF PG_DEBUG <> 0 THEN
          			oe_debug_pub.add('Purchase_price_calc_wf: ' || ' Failed in Create_purchasing_doc call...',1);
          		END IF;
        		--  raise FND_API.G_EXC_UNEXPECTED_ERROR;
        	end if;
              */

           			oe_debug_pub.add('Purchase_price_calc_wf: ' || ' Failed to call Create_purchasing_doc call...',1);


        end if;
        OE_STANDARD_WF.Save_Messages;
        OE_STANDARD_WF.Clear_Msg_Context;

Exception     when OTHERS then
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('Purchase_price_calc_wf: ' || 'CTO_WORKFLOW.Purchase_Price_calc_wf: '
                        || to_char(l_stmt_num) || ':' ||
                        substrb(sqlerrm, 1, 100));
       END IF;
       wf_core.context('CTO_WORKFLOW', 'Purchase_Price_calc_wf',
                       p_itemtype, p_itemkey, to_char(p_actid),
                       p_funcmode);
       raise;

End Purchase_Price_calc_wf;


/*============================================================================
        Procedure:    	chk_rsv_after_afas_wf
        Description:
			The format follows the standard Workflow API format.
                         06/04/02      bugfix2327972
|                             added a new function node which calls procedure
|                             chk_rsv_after_afas_wf.
|                             This nodes checks if any type of reservation
|                             exists. Node has been added in warning path after
|                             autocreate fas node
|                         This calls CTO_UTILITY_PK.chk_all_rsv_details to
|                         check if any reservations exits for this line
|

     	Parameters:
=============================================================================*/

PROCEDURE chk_rsv_after_afas_wf (
        p_itemtype        in      VARCHAR2, /* item type */
        p_itemkey         in      VARCHAR2, /* config line id   */
        p_actid           in      NUMBER,   /* ID number of WF activity */
        p_funcmode        in      VARCHAR2, /* execution mode of WF activity */
        x_result     out  NoCopy  VARCHAR2  /* result of activity    */
        )
IS

        l_stmt_num           	NUMBER;

        l_msg_count  		number;
        l_msg_data  		varchar2(2000);
        l_return_status  	varchar2(1);
        l_rsv_details           CTO_UTILITY_PK.t_resv_details;




BEGIN
        OE_STANDARD_WF.Set_Msg_Context(p_actid);
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('chk_rsv_after_afas_wf: ' || 'CTO Activity: Check Reservation after afas  activity ', 1);
        END IF;

        IF (p_funcmode = 'RUN') then

            	l_stmt_num := 260;

         	CTO_UTILITY_PK.chk_all_rsv_details
         	( 	p_itemkey,
           		l_rsv_details,
           		l_msg_count,
           		l_msg_data,
           		l_return_status
          	);

          	IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
               	        x_result :='COMPLETE:RESERVED';
         	ELSE
               		x_result := 'COMPLETE';
          	END IF;

      END IF ; /*p_funcmode ='RUN"*/

    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;

EXCEPTION
        when FND_API.G_EXC_ERROR then
           IF PG_DEBUG <> 0 THEN
           	OE_DEBUG_PUB.add('chk_rsv_after_afas_wf: ' || 'CTO_WORKFLOW.chk_rsv_after_afas_wf' || to_char(l_stmt_num) );
           END IF;
           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;
	   raise;	-- can be re-tried

        when FND_API.G_EXC_UNEXPECTED_ERROR then
           if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
           	FND_MSG_PUB.Add_Exc_Msg
            			(G_PKG_NAME
            			,'chk_rsv_after_afas_wf'
            			);
           end if;

           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('chk_rsv_after_afas_wf: ' || 'corresponds to unexpected error at called program chk_rsv_after_afas_wf  '||'
					l_stmt_num :'|| l_stmt_num ||sqlerrm, 1);
           END IF;
           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;
           wf_core.context('CTO_WORKFLOW', 'chk_rsv_after_afas_wf', p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
           raise;

         when OTHERS then
           if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
            	     FND_MSG_PUB.Add_Exc_Msg
            			(G_PKG_NAME
            			,'chk_rsv_after_afas_wf'
            			);
           end if;
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('chk_rsv_after_afas_wf: ' || 'error at chk_rsv_after_afas_wf' || to_char(l_stmt_num)|| sqlerrm);
           END IF;
             /*-------------------------------------------+
              Error Information for Notification.
             +--------------------------------------------*/
           wf_core.context('CTO_WORKFLOW','chk_rsv_after_afas_wf',p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
           raise;

END chk_rsv_after_afas_wf;


--This will get called from a new node in create supply subprocess
--added fro DMF-J
--new node is : Check supply creation which befor create supply order
--block activity
--create by KKONADA
PROCEDURE check_supply_creation_wf(
        p_itemtype   in           VARCHAR2, /*item type */
        p_itemkey    in           VARCHAR2, /* config line id    */
        p_actid      in           number,   /* ID number of WF activity  */
        p_funcmode   in           VARCHAR2, /* execution mode of WF activity*/
        x_result     out  NoCopy  VARCHAR2  /* result of activity    */
        )
IS
  l_can_create_supply VARCHAR2(1);
  l_source_type       NUMBER;
  l_return_status     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);
  l_stmt_num          NUMBER;

  l_inventory_item_id number;
  l_ship_from_org_id  number;
  l_item_type_code    Oe_order_lines_all.item_type_code%type;
  l_source_type_code  oe_order_lines.source_type_code%type ;

  l_status NUMBER;
 -- l_return_status VARCHAR2(1);
  l_header_id     NUMBER;
  return_value    NUMBER;

  --opm
  l_sourcing_org number;
  l_message      varchar2(100);

BEGIN

    OE_STANDARD_WF.Set_Msg_Context(p_actid);
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('check_supply_creation_wf: ' || 'CTO Activity: Check Supply Type', 1);

    	oe_debug_pub.add('check_supply_creation_wf: ' || 'Item key = '||p_itemkey,1);

    	oe_debug_pub.add('check_supply_creation_wf: ' || 'Func Mode ='||p_funcmode,1);
    END IF;

   IF (p_funcmode = 'RUN') THEN



         l_stmt_num:=10;
         select inventory_item_id, ship_from_org_id,item_type_code, source_type_code,header_id
         into   l_inventory_item_id, l_ship_from_org_id,l_item_type_code, l_source_type_code,l_header_id
         from   oe_order_lines_all
         where  line_id = to_number(p_itemkey)
         and    ato_line_id is not null;
         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('check_supply_creation_wf: ' || 'Inventory_item_id ='||to_char(l_inventory_item_id),1);

         	oe_debug_pub.add('check_supply_creation_wf: ' || 'Ship from org id  ='||to_char(l_ship_from_org_id),1);

         	oe_debug_pub.add('check_supply_creation_wf: ' || 'Item type code    ='||l_item_type_code,1);


         	oe_debug_pub.add('check_supply_creation_wf: ' || 'l_source_type_code    ='||l_source_type_code,1);
         END IF;

      /*

      ** need to branch on source type for drop ship functionality
      */
      l_stmt_num:=20;
      IF( l_source_type_code = 'EXTERNAL' )
      THEN

         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('check_supply_creation_wf: ' || 'It is Config item Drop Ship case...',1);
         END IF;
         x_result := 'COMPLETE';
         OE_STANDARD_WF.Save_Messages;
         OE_STANDARD_WF.Clear_Msg_Context;







            l_stmt_num:=25;
           return_value:= CTO_WORKFLOW_API_PK.display_wf_status(to_number(p_itemkey));


           IF PG_DEBUG <> 0 THEN
                   oe_debug_pub.add('check_supply_creation_wf: ' || 'return value from display_wf_status'
                                     ||return_value ,5);
           END IF;

           if return_value <> 1 then
                IF PG_DEBUG <> 0 THEN
                   oe_debug_pub.add('check_supply_creation_wf: ' || 'return value from display_wf_status'
                                     ||return_value ,1);
                END IF;
                cto_msg_pub.cto_message('CTO', 'CTO_ERROR_FROM_DISPLAY_STATUS');
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
           end if;




         return;


      END IF ;

      l_stmt_num:=30;
      CTO_UTILITY_PK.check_cto_can_create_supply
			(
			P_config_item_id    =>	l_inventory_item_id,
			P_org_id 	    =>	l_ship_from_org_id,
			x_can_create_supply =>  l_can_create_supply,
			p_source_type       =>  l_source_type,
			x_return_status     =>  l_return_status,
			X_msg_count	    =>	l_msg_count,
			X_msg_data          =>	l_msg_data,
			x_sourcing_org	    =>  l_sourcing_org, --new param R12 OPM
			x_message	    =>  l_message       --new param R12 OPM
			);

      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
         IF l_can_create_supply = 'N' THEN

	   IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('check_supply_creation_wf: ' || 'It is Config item Planning case...',1);
		oe_debug_pub.add('check_supply_creation_wf: ' || l_message,1);
           END IF;

	   l_stmt_num:=40;
           x_result := 'COMPLETE:PLANNING';

	   IF PG_DEBUG <> 0 THEN
         	   oe_debug_pub.add('check_supply_creation_wf: ' || 'wrkflow result code'
		                     ||x_result ,5);
           END IF;



	 ELSE

	   l_stmt_num:=60;
	   x_result := 'COMPLETE';

	   IF PG_DEBUG <> 0 THEN
         	   oe_debug_pub.add('check_supply_creation_wf: ' || 'wrkflow result code'
		                     ||x_result ,5);
           END IF;

	 END IF;--l_can_create_supply

      ELSIF l_return_status = FND_API.G_RET_STS_ERROR  THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSE
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;--l_return_status


            l_stmt_num:=70;
	   return_value:= CTO_WORKFLOW_API_PK.display_wf_status(to_number(p_itemkey));


	   IF PG_DEBUG <> 0 THEN
         	   oe_debug_pub.add('check_supply_creation_wf: ' || 'return value from display_wf_status'
		                     ||return_value ,5);
           END IF;

	   if return_value <> 1 then
	        IF PG_DEBUG <> 0 THEN
         	   oe_debug_pub.add('check_supply_creation_wf: ' || 'return value from display_wf_status'
		                     ||return_value ,1);
                END IF;
	     	cto_msg_pub.cto_message('CTO', 'CTO_ERROR_FROM_DISPLAY_STATUS');
	        raise FND_API.G_EXC_UNEXPECTED_ERROR;
           end if;

  END IF;--run

   OE_STANDARD_WF.Save_Messages;
   OE_STANDARD_WF.Clear_Msg_Context;

EXCEPTION

   when FND_API.G_EXC_ERROR then
           IF PG_DEBUG <> 0 THEN
           	OE_DEBUG_PUB.add('check_supply_creation_wf: ' || 'CTO_WORKFLOW.check_supply_creation_wf ' ||
                            to_char(l_stmt_num));
           END IF;
           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;
           --x_result := 'COMPLETE:INCOMPLETE';
	   wf_core.context('CTO_WORKFLOW', 'check_supply_creation_wf',
                           p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
           raise;


   when FND_API.G_EXC_UNEXPECTED_ERROR then
           IF PG_DEBUG <> 0 THEN
           	OE_DEBUG_PUB.add('check_supply_creation_wf: ' || 'CTO_WORKFLOW.check_supply_creation_wf ' ||
                            to_char(l_stmt_num));
           END IF;
           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;
           wf_core.context('CTO_WORKFLOW', 'check_supply_creation_wf',
                           p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
           raise;

   when OTHERS then
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('check_supply_creation_wf: ' || 'CTO_WORKFLOW.check_supply_creation_wf' ||
                            to_char(l_stmt_num));
	        oe_debug_pub.add('check_supply_creation_wf: ' || 'errmsg' ||sqlerrm,1);
           END IF;
           wf_core.context('CTO_WORKFLOW', 'check_supply_creation_wf',
                           p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);

           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;

           raise;


END check_supply_creation_wf;






END CTO_WORKFLOW;

/
