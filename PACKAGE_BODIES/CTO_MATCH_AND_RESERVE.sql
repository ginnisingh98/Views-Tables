--------------------------------------------------------
--  DDL for Package Body CTO_MATCH_AND_RESERVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_MATCH_AND_RESERVE" as
/* $Header: CTOMCRSB.pls 120.1.12010000.2 2008/08/26 19:14:04 ntungare ship $ */

/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : CTOMCRSB.pls                                                  |
| DESCRIPTION:                                                                |
|               This file creates a package that containst procedures called  |
|               from the Match and Reserve menu from Order Entry's Enter      |
|               Orders form.                                                  |
|                                                                             |
|               match_inquiry -                                               |
|               This function is called when the Match and Reserve            |
|               menu is  invoked.  It does the following:                     |
|               1.  Checks if the order line is eligible to be matched        |
|                   and reserved.                                             |
|               2.  If it is, it determines if the order line is already      |
|                   linked to a configuration item.  If it is, it uses that   |
|                   config item in the available quantity inquiry.  If it     |
|                   does not, it attempts to match the configuration from     |
|                   oe_order_lines_all against bom_ato_configurations.        |
|                3.  If a configuration item exists, it calls Inventory's     |
|                   API to query available quantity (on-hand and available    |
|                   to reserve).  If it has any quantity available to reserve |
|                   it returns true.                                          |
|                                                                             |
|                                                                             |
| To Do:        Handle Errors.  Need to discuss with Usha and Girish what     |
|               error information to include in Notification.                 |
|                                                                             |
| HISTORY     :                                                               |
|               May 10, 99  Angela Makalintal   Initial version               |
|                                                                             |
|               APR 01, 02  Renga Kannan        Added call to Purchase        |
|                                               price rollup                  |
|               05/03/2002  Sushant Sawant                                    |
|                                               BUGFIX#2342412                |
|                                               update config line status     |
|                                               after matched item is linked  |
|               05/09/2002  Sushant Sawant                                    |
|                                               BUGFIX#2367720                |
|                                               match_inquiry should return   |
|                                               available qty as 0 for        |
|                                               dropshipped items             |
|									      |
|               10/25/2002  Kundan Sarkar       Bugfix 2644849 (2620282 in br)|
|                                               Passing bom revision info     |
|									      |
|               10/31/2002  Sushant Sawant      Added Enhanced costing functionality
|                                               for matched items .
|
|
|
|               Modified   :    13-APR-2004     Sushant Sawant
|                                               Fixed Bug 3523260
|                                               Match and Reserve should work for unbooked orders that are scheduled.
|                                               No reservation should take place for unbooked orders.
|

|
|               Modified   :    14-MAY-2004     Sushant Sawant
|                                               Fixed bug 3484511.
|
|               Modified  : Kiran Konada
|                           Fixed bug 3692727
|                           ship_from_org_id was bein inserted during call to match_configured_item
|                           (-->calls CTOMCFGB.insert_into_bcol_gt)
|                           as ship_from_org_id attribute was not initialzed , during runtime
|                           we were landing into datafound at element(1) of ship_from_org_id attr
|                           Modified the insert statment to populate null vale for attr shiP-from_org_id

*****************************************************************************
Dependencies introduced
Date     : Patchset  : Introduced by   : File           : Reason
10/31/02   11.5.9      Kundan Sarkar     CTORCFGS.pls     2620282
10/31/02   11.5.9      Kundan Sarkar     CTORCFGB.pls

=============================================================================*/

/*****************************************************************************
   Function:  match_inquiry

   Description:

                 This function is called from the 'Match' action from the
                 Sales Order Pad form.

                 p_model_line_id - top model line id from oe_order_lines
                 p_automatic_reservation - true if reservation is done
                                           automatically, without user
                                           intervention.  used by order import.
                 p_quantity_to_reserve - quantity to be reserved. used only
                                         when p_automatic_reservation is true
                 p_reservation_uom_code - uom in which to make the reservation.
                                          the x_available_qty returned is
                                          in this uom.
                 x_match_config_id - config id of the matching configuration
                                  from bom_ato_configurations
                 x_available_qty - available quantity for reservation
                                   in p_reservation_uom_code.
                 x_error_message   - error message if match function fails
                 x_message_name    - name of error message if match
                                    function fails


                 match_inquiry returns TRUE if the process is successful
                 (no process errors).  If a match is found,
                 x_config_match_id is populated with the inventory item
                 id of the matching config item.

                 If a match is not found, match_inquiry returns true and
                 x_config_match_id is NULL.

                 x_available_qty is the quantity available to reserve for
                 the configuration item.  If it is zero, the user is not
                 given the option to reserve.

                 x_quantity_reserved returns the total quantity reserved.

                 match_inquiry returns FALSE if the process encounters
                 any errors.

                 if p_automatic_reseravation is true, match_inquiry returns
                 TRUE if a reservation is successful.  otherwise, it returns
                 FALSE.

     12/2/99:    Product Management wants Match and Reserve to do
                 a link to the matching item even if reservation cannot
                 be made due to insufficient available quantity.

                 The change has been made.  Match_inquiry now performs
                 a link if a matching item is found.

      05/01/00:  Modifying match_inquiry to work for multilevel
                 configurations.
*****************************************************************************/

PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);

function match_inquiry(
	p_model_line_id         in  NUMBER,
        p_automatic_reservation in  BOOLEAN,
        p_quantity_to_reserve   in  NUMBER,
        p_reservation_uom_code  in  VARCHAR2,
        x_config_id             out nocopy NUMBER,
        x_available_qty         out nocopy NUMBER,
        x_quantity_reserved     out nocopy NUMBER,
        x_error_message         out nocopy VARCHAR2,
        x_message_name          out nocopy varchar2
	)
RETURN boolean

IS

   l_stmt_num       	number := 0;
   l_cfm_value      	number;
   l_config_line_id 	number;
   l_tree_id        	integer;
   l_return_status  	varchar2(1);
   l_x_error_msg_count  number;
   l_x_error_msg        varchar2(500);		--bugfix 2776026: increased the var size
   l_x_error_msg_name   varchar2(30);
   l_x_table_name   	varchar2(30);
   l_match_profile  	varchar2(10);
   l_custom_match_profile varchar2(10);
   l_org_id         	number;
   l_model_id       	number;
   l_primary_uom_code   varchar(3);
   l_x_config_id    	number;
   l_top_model_line_id  number;


   l_header_id             number;

   l_x_qoh          number;
   l_x_rqoh         number;
   l_x_qs           number;
   l_x_qr           number;
   l_x_att          number;
   l_active_activity varchar2(30);
   l_x_bill_seq_id  number;
   l_status         integer;

   x_return_status  varchar2(1);
   x_msg_count      number;
   x_msg_data       varchar2(500);		-- bugfix 2776026: increased the var size

   PROCESS_ERROR      EXCEPTION;
   INVALID_LINE       EXCEPTION;
   BOM_NOT_DEFINED    EXCEPTION;
   INVALID_WORKFLOW_STATUS EXCEPTION;
   RESERVATION_ERROR  EXCEPTION;



   l_source_type_code oe_order_lines_all.source_type_code%type ;
   l_booked_flag      oe_order_lines_all.booked_flag%type ;



   cursor c_model_lines is
          select line_id, parent_ato_line_id
          from   bom_cto_order_lines
          where  bom_item_type = 1
          --and    top_model_line_id = p_model_line_id
          and    ato_line_id = p_model_line_id
          and    nvl(wip_supply_type,0) <> 6
          and    ato_line_id is not null
          order by plan_level desc;

    -- Added by Renga Kannan on 04/01/2002 for Purchase Price rollup
    x_oper_unit_list        cto_auto_procure_pk.oper_unit_tbl;
    l_batch_no              Number;


    v_cto_match_rec  CTO_CONFIGURED_ITEM_GRP.CTO_MATCH_REC_TYPE ;


    l_match_found     varchar2(1) ;

    lValidationOrg    number ;

    v_model_item_name varchar2(2000) ;
    l_top_model_item_id number ;


    l_token CTO_MSG_PUB.token_tbl ;



        lPerformPPRollup        varchar2(10) ;
        lPerformCSTRollup       varchar2(10) ;
        lPerformFWCalc          varchar2(10) ;

        l_perform_match         varchar2(2) ;

        l_perform_flow_calc     number := 1;


  return_value    NUMBER;


BEGIN

        x_available_qty := 0;
        x_config_id := NULL;
        x_quantity_reserved := 0;

        l_stmt_num := 50;
        l_match_profile := FND_PROFILE.Value('BOM:MATCH_CONFIG');
        l_custom_match_profile := FND_PROFILE.Value('BOM:CUSTOM_MATCH');

        IF PG_DEBUG <> 0 THEN
        oe_debug_pub.add('MATCH_CONFIG: ' || l_match_profile, 1);
        oe_debug_pub.add('CUSTOM_MATCH: ' || l_custom_match_profile, 1);
        END IF;


        --
        -- Do not match if config line exists.
        --
        l_stmt_num := 110;
        if (config_line_exists(p_model_line_id,
                               l_config_line_id,
                               l_x_config_id) = TRUE)
        then
            IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add('Config Line Already Exists.', 1);
            END IF;

            x_message_name := 'CTO_CONFIG_ITEM_EXISTS';
            return FALSE;
        end if;

        --
        -- Validate model line.  Check that model line has ship from org and
        --  that bill is defined in the ship from  org.
        --

        l_stmt_num := 100;
        IF (cto_workflow.validate_line(p_model_line_id) = FALSE) THEN
            raise INVALID_LINE;
        END IF;

        -- call to populate_bom_cto_order_lines with top_model_line_id
	-- populating bcol using ato_line_id instead of top_model_line_id
	-- change to support multiple ATO models under a PTO model, sajani

        l_stmt_num := 101;
        select top_model_line_id, inventory_item_id
        into   l_top_model_line_id, l_top_model_item_id
        from   oe_order_lines_all
        where  line_id = p_model_line_id;

        IF PG_DEBUG <> 0 THEN
        oe_debug_pub.add('Top Model Line Id: ' || to_char(l_top_model_line_id));
        END IF;


        l_stmt_num := 102;

        IF PG_DEBUG <> 0 THEN
        oe_debug_pub.add('Before populate_bcol.', 1);
        END IF;

        delete from bom_cto_order_lines where ato_line_id = p_model_line_id ;

        IF PG_DEBUG <> 0 THEN
        oe_debug_pub.add('CTOMCRSB: deleted bcol: ' || to_char(SQL%ROWCOUNT));
        END IF;

        delete from bom_cto_src_orgs_b where top_model_line_id = p_model_line_id ;

        IF PG_DEBUG <> 0 THEN
        oe_debug_pub.add('CTOMCRSB: deleted bcso_b : ' || to_char(SQL%ROWCOUNT));
        END IF;



	CTO_UTILITY_PK.Populate_Bcol(p_bcol_line_id	=> p_model_line_id,
                                     x_return_status	=> x_Return_Status,
                                     x_msg_count	=> X_Msg_Count,
                                     x_msg_data		=> X_Msg_Data);

  	if x_return_status = FND_API.G_RET_STS_ERROR then
              IF PG_DEBUG <> 0 THEN
     		oe_debug_pub.add ('Failed in populate_bcol with expected error.', 1);
              END IF;

                cto_msg_pub.cto_message('BOM','CTO_MATCH_AND_RESERVE');
		raise FND_API.G_EXC_ERROR;

  	elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               IF PG_DEBUG <> 0 THEN
     		oe_debug_pub.add ('Failed in populate_bcol with unexpected error.', 1);
               END IF;

                cto_msg_pub.cto_message('BOM','CTO_MATCH_AND_RESERVE');
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
  	end if;

        IF PG_DEBUG <> 0 THEN
        oe_debug_pub.add('After populate_bcol.', 1);
        END IF;


        l_stmt_num := 105;
        select bcol.inventory_item_id, bcol.ship_from_org_id, perform_match
        into   l_model_id, l_org_id , l_perform_match
        from   bom_cto_order_lines bcol
        where  bcol.line_id = p_model_line_id;


         --
         -- Check Workflow status of model line.
         -- Workflow needs to be at Create Config Item Eligible.
         --

         l_stmt_num := 120;
         IF PG_DEBUG <> 0 THEN
         oe_debug_pub.add('Configuration Line does not exist.', 1);
         END IF;

         CTO_WORKFLOW_API_PK.get_activity_status(
				itemtype	=> 'OEOL',
				itemkey		=> to_char(p_model_line_id),
				linetype	=> 'MODEL',
				activity_name	=> l_active_activity);

         IF PG_DEBUG <> 0 THEN
         oe_debug_pub.add('Workflow Status is: ' ||
                             l_active_activity, 1);
         END IF;


         /*
         if (l_active_activity = 'NULL') then
            IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add('Model Workflow Status not Eligible for MR.', 1);
            END IF;

            raise INVALID_WORKFLOW_STATUS;
         end if;


         Commented for Patchset J as match can be invoked after order is scheduled

        */


        -- This is the part that will change.  We need to do the following:
        --    1.  Select and mark the lines in oe_order_lines_all
        --    2.  Add lines in bom_cto_order_lines
        --    3.  Match up the tree (stop as soon as an assly does not match)
        --    4.  If the final assembly matches,
        --          a.  add sourcing info in bom_cto_src_orgs
        --          b.  call create items, which will create all the items
        --              in all the relevant orgs
        --          c.  link top config item to top model
        --    5.  Unmark the records


        --
        -- This is the loop that traverses bom_cto_order_lines to match
        -- each configured assembly from bottom to top.  The loop
        -- exits as soon as an assembly does not match.
        --


        if( l_perform_match = 'N' ) then

            oe_debug_pub.add('Top Model is not Eligible for MR as match is ' || l_perform_match , 1);
            oe_debug_pub.add('Top Model is not Eligible for MR iid is ' || l_top_model_item_id , 1);


            select concatenated_segments into v_model_item_name
            from mtl_system_items_kfv
            where inventory_item_id = l_top_model_item_id
              and rownum = 1 ;

            oe_debug_pub.add('Top Model is not Eligible for MR name is ' || v_model_item_name , 1);

            -- l_token(1).token_name := 'MODEL_NAME' ;
            -- l_token(1).token_value := v_model_item_name  ;

            x_message_name := 'CTO_MATCH_NA' ;

            l_stmt_num := 137;
            delete from bom_cto_order_lines
            where  top_model_line_id = l_top_model_line_id;

            IF PG_DEBUG <> 0 THEN
               oe_debug_pub.add(x_error_message,1);
            END IF;


            return TRUE ;

        end if ;



          /* BUGFIX# 3484511 */
            select nvl( oe_sys_parameters.value( 'MASTER_ORGANIZATION_ID' , oel.org_id) ,-99)
            into   lValidationOrg
            from   oe_order_lines_all oel
            where  oel.line_id = p_model_line_id  ;




        select
                line_id,
                link_to_line_id,
                ato_line_id,
                top_model_line_id,
                inventory_item_id,
                component_code,
                component_sequence_id,
                lValidationOrg,
                qty_per_parent_model,
                ordered_quantity,
                order_quantity_uom,
                parent_ato_line_id,
                perform_match,
                plan_level,
                bom_item_type,
                wip_supply_type,
                null           --bugfix 3692727 ,null as shippig org doesnot matter
		               --during matching
        bulk collect into
                v_cto_match_rec.line_id,
                v_cto_match_rec.link_to_line_id,
                v_cto_match_rec.ato_line_id,
                v_cto_match_rec.top_model_line_id,
                v_cto_match_rec.inventory_item_id,
                v_cto_match_rec.component_code,
                v_cto_match_rec.component_sequence_id,
                v_cto_match_rec.validation_org,
                v_cto_match_rec.qty_per_parent_model,
                v_cto_match_rec.ordered_quantity,
                v_cto_match_rec.order_quantity_uom,
                v_cto_match_rec.parent_ato_line_id,
                v_cto_match_rec.perform_match,
                v_cto_match_rec.plan_level,
                v_cto_match_rec.bom_item_type,
                v_cto_match_rec.wip_supply_type,
		v_cto_match_rec.ship_from_org_id --bugfix 3692727
        from    bom_cto_order_lines
        where   ato_line_id = p_model_line_id
        order by plan_level ;



        oe_debug_pub.add ('match_inquiry:  GOING TO CALL CTO_CONFIGURED_ITEM_GRP.match_configured_item ' , 1) ;

        CTO_CONFIGURED_ITEM_GRP.match_configured_item (
                                           p_api_version  =>  1.0,
                                           /*
                                           p_init_msg_list =>
                                           p_commit      =>
                                           p_validation_level =>
                                           */
                                           x_return_status   =>  x_return_status ,
                                           x_msg_count  =>    x_msg_count ,
                                           x_msg_data  =>   x_msg_data ,
                                           p_action    =>   'CTO' ,
                                           p_source   =>   'CTO' ,
                                           p_cto_match_rec => v_cto_match_rec ) ;




        oe_debug_pub.add ('match_inquiry:  CTO_CONFIGURED_ITEM_GRP.match_configured_item done ' , 1) ;

        IF ( x_return_status = fnd_api.G_RET_STS_ERROR) THEN
                        IF PG_DEBUG <> 0 THEN
                           oe_debug_pub.add ('Create_Item: ' ||
                           'CTO_CONFIGURED_ITEM_GRP.match_configured_item returned with expected error.');
                        END IF;
                        raise FND_API.G_EXC_ERROR;

        ELSIF ( x_return_status = fnd_api.G_RET_STS_UNEXP_ERROR) THEN
                        IF PG_DEBUG <> 0 THEN
                           oe_debug_pub.add ('Create_Item: ' ||
                           'CTO_CONFIGURED_ITEM_GRP.match_configured_item returned with unexp error.');
                        END IF;
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;





        l_x_config_id := null ;
        for i in 1..v_cto_match_rec.line_id.count
        loop

            if( v_cto_match_rec.line_id(i) = p_model_line_id ) then
                l_x_config_id := v_cto_match_rec.config_item_id(i) ;
                exit ;
            end if;

        end loop ;



        --
        -- If match is found for top assembly, link it to top model line.
        -- This starts the configuration line workflow.  We then call
        -- an API to move the model line workflow.
        --
        -- We then check if the configuration item can be reserved.
        --


        if (l_x_config_id is NULL) then
               x_message_name := 'CTO_MR_NO_MATCH';
               x_error_message := 'No matching configurations for line '
                                   || to_char(l_top_model_line_id);

               l_stmt_num := 137;
               delete from bom_cto_order_lines
               where  top_model_line_id = l_top_model_line_id;

               IF PG_DEBUG <> 0 THEN
               oe_debug_pub.add(x_error_message,1);
               END IF;



        else

             oe_debug_pub.add('CTOMCRSB: ' || 'Getting Profile Values ' , 1);

             lPerformPPRollup := nvl( FND_PROFILE.Value('CTO_PERFORM_PURCHASE_PRICE_ROLLUP'), 1 ) ;
             lPerformCSTRollup := nvl( FND_PROFILE.Value('CTO_PERFORM_COST_ROLLUP') , 1 ) ;
             --Bugfix 6716677
             --lPerformFWCalc := nvl( FND_PROFILE.Value('CTO_PERFORM_FLOW_CALC') , 1 );
             lPerformFWCalc := nvl( FND_PROFILE.Value('CTO_PERFORM_FLOW_CALC') , 2 );

             oe_debug_pub.add('CTOMCRSB: ' || 'Done Getting Profile Values ' , 1);

             IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('CTOMCRSB: ' || 'Profile Perform Purchase Price Rollup
' || lPerformPPRollup , 1);
                        oe_debug_pub.add('CTOMCRSB: ' || 'Profile Perform Cost Rollup ' || lPerformCSTRollup , 1);
                        oe_debug_pub.add('CTOMCRSB: ' || 'Profile Perform Flow Calculations ' || lPerformFWCalc , 1);
             END IF;





            if( lPerformFWCalc = 1 ) then
                 l_perform_flow_calc := 1;
                 oe_debug_pub.add('CTOMCSRB: ' || 'Flow Calc is 1 ' , 1);
            else
            --Begin Bugfix 6716677
                 if( lPerformFWCalc = 2 ) then
                        l_perform_flow_calc := 2;
                        oe_debug_pub.add('CTOMCRSB: ' || 'Flow Calc is 2 ' , 1);
                 else
                        l_perform_flow_calc := 3;
                        oe_debug_pub.add('CTOMCRSB: ' || 'Flow Calc is 3 ' , 1);
                 end if;
            --End Bugfix 6716677
            end if ;


            -- populate bom_cto_src_orgs to create items and boms
            IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add('Before Populate_Src_Orgs');
            END IF;

            l_stmt_num := 140;

	    l_Status := CTO_MSUTIL_PUB.Populate_Src_Orgs(
					pTopAtoLineId	=> p_model_line_id,
					x_return_status	=> x_return_status,
                                	x_msg_count	=> x_msg_count,
                                	x_msg_data	=> x_msg_data);

	    IF ( l_Status <> 1 and X_Return_Status = FND_API.G_RET_STS_ERROR) THEN
                IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('CTO_MSUTIL_PUB.Populate_src_orgs returned with exp error',1);
                END IF;

		raise FND_API.G_EXC_ERROR;

	    ELSIF ( l_Status <> 1  and X_Return_Status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('CTO_MSUTIL_PUB.Populate_src_orgs returned with unexp error',1);
                END IF;

		raise FND_API.G_EXC_UNEXPECTED_ERROR;

	    END IF;


            IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add('Ater CTO_MSUTIL_PUB.Populate_Src_Orgs', 2);
            END IF;


            -- call create_all_items, which will go through
            -- bom_cto_order_lines and create all items in all src orgs

            IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add('Calling Create_All_Items');
            END IF;


            l_stmt_num := 145;

            l_status := CTO_ITEM_PK.Create_All_Items(
						pTopAtoLineId	=> p_model_line_id,
						xReturnStatus	=> x_Return_Status,
                                                xMsgCount	=> x_msg_count,
                                                XMsgData	=> x_msg_data);

            IF (l_status <> 1 and x_Return_Status = fnd_api.g_ret_sts_error ) then
                IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add ('Create_All_Items returned with 0', 1);
                END IF;


                --cto_msg_pub.cto_message('BOM','CTO_MATCH_AND_RESERVE');
                raise FND_API.G_EXC_ERROR;

            ELSIF (l_status <> 1 and x_Return_Status = fnd_api.g_ret_sts_unexp_error ) then
               IF PG_DEBUG <> 0 THEN
	       oe_debug_pub.add ('Create_All_Items returned with 0', 1);
               END IF ;


               --cto_msg_pub.cto_message('BOM','CTO_MATCH_AND_RESERVE');
               raise FND_API.G_EXC_UNEXPECTED_ERROR;

            END IF;










            -- call create_all_boms_and_rtgs
            l_stmt_num := 146;
            CTO_BOM_RTG_PK.create_all_boms_and_routings(
					pAtoLineId	=> p_model_line_id,
					pFlowCalc	=> l_perform_flow_calc ,
					xReturnStatus	=> x_return_status,
                                        xMsgCount	=> x_msg_count,
                                        xMsgData	=> x_msg_data);

            IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add('Matching Final Assy Item is: ' ||
                              to_char(l_x_config_id),1);
            END IF;




            l_stmt_num := 147;
            l_status := CTO_CONFIG_ITEM_PK.link_item(
                                         pOrgId		=> l_org_id,
                                         pModelId	=> l_model_id,
                                         pConfigId	=> l_x_config_id,
                                         pLineId	=> p_model_line_id,
                                         xMsgCount	=> x_msg_count,
                                         xMsgData	=> x_msg_data);

            if (l_status <> 1) then

                IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add ('Failed in link_item function', 1);
                END IF;

                raise PROCESS_ERROR;

            end if;
            IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add ('Success in link_item function', 1);
            END IF;




            if (CTO_WORKFLOW_API_PK.start_model_workflow(p_model_line_id) = FALSE)
            then
                IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('Failed in call to start_model_workflow',1);
                END IF;

                raise PROCESS_ERROR;
            end if;

            x_config_id := l_x_config_id;
            x_message_name := 'CTO_CONFIG_LINKED';


            l_stmt_num := 149;


            /* BUGFIX#2342412 */
            select line_id, header_id , source_type_code , booked_flag
            into   l_config_line_id, l_header_id , l_source_type_code , l_booked_flag
            from   oe_order_lines_all
            where  ato_line_id = p_model_line_id
            and    item_type_code = 'CONFIG';


            IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add('Calling flow status API ',1);
            END IF;


            /*

              IMPORTANT!!!!
              FLOW STATUS CODE needs to be changed using CTO API

            */




          return_value:= CTO_WORKFLOW_API_PK.display_wf_status(l_config_line_id);


           IF PG_DEBUG <> 0 THEN
                   oe_debug_pub.add('CTOMCRSB: ' || 'return value from display_wf_status' ||return_value ,5);
           END IF;

           if return_value <> 1 then
                IF PG_DEBUG <> 0 THEN
                   oe_debug_pub.add('CTOMCRSB: ' || 'return value from display_wf_status' ||return_value ,1);
                END IF;
                cto_msg_pub.cto_message('CTO', 'CTO_ERROR_FROM_DISPLAY_STATUS');
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
           end if;





            /* BUGFIX#2342412
            OE_Order_WF_Util.Update_Flow_Status_Code(
                           p_header_id         => l_header_id,
                           p_line_id           => l_config_line_id,
                           p_flow_status_code  => 'BOM_AND_RTG_CREATED',
                           x_return_status     => l_return_status);

            IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add('Return from flow status API ' ||l_return_status,1);
            END IF;


            */



            /* BUG#2367720 */
           if( l_source_type_code = 'INTERNAL' AND l_booked_flag = 'Y' ) then







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
                      , p_organization_id      => l_org_id
                      , p_inventory_item_id    => x_config_id
                      , p_tree_mode => inv_quantity_tree_pub.g_reservation_mode
                      , p_is_revision_control  => FALSE
                      , p_is_lot_control       => FALSE
                      , p_is_serial_control    => FALSE
                      , x_tree_id              => l_tree_id);

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('Failed in create_tree with status: ' ||
                             l_return_status, 1);
                END IF;

                raise PROCESS_ERROR;
            ELSE
                IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('Success in create_tree.',1);
                oe_debug_pub.add('Tree ID:' || to_char(l_tree_id),1);
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
                oe_debug_pub.add('Failed in create_tree with status: ' ||
                                  l_return_status, 1);
                END IF;
                raise PROCESS_ERROR;
            end if;

            IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add('Success in query_tree.', 1);
            oe_debug_pub.add('l_x_qoh: ' || to_char(l_x_qoh));
            oe_debug_pub.add('l_x_rqoh: ' || to_char(l_x_rqoh));
            oe_debug_pub.add('x_available_qty: ' || to_char(x_available_qty));
            END IF;


            l_stmt_num := 170;
            select msi.primary_uom_code
            into   l_primary_uom_code
            from   mtl_system_items msi
            where  msi.inventory_item_id = x_config_id
            and    msi.organization_id = l_org_id;

            /*------------------------------------------------------
             The quantity query gives ATR in the primary uom code
             so we need to convert it to the same uom as the
             p_reservation_uom_code.
            +------------------------------------------------------*/
            IF (l_primary_uom_code <> p_reservation_uom_code) THEN
                l_stmt_num := 175;
                x_available_qty := inv_convert.inv_um_convert(
                               x_config_id,
                               5,                      -- bugfix 2204376: pass precision of 5
                               x_available_qty,        -- from qty
                               l_primary_uom_code,     -- from uom
                               p_reservation_uom_code, -- to uom
                               null,
                               null);
            END IF;

            /*---------------------------------------------------------+
              p_automatic_reservation is TRUE when match and reserve is
              called from Order Import.  From Order Import, if a match
              is found, a reservation is made automatically if there
              is sufficient quantity.
            +---------------------------------------------------------*/
            if (x_available_qty >= p_quantity_to_reserve and
                p_automatic_reservation = TRUE)
            then
                l_stmt_num := 180;
                IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('Entering Create Reservation. ',1);
                oe_debug_pub.add('Quantity Available to Rsrv: '
                                  || to_char(x_available_qty),1);
                END IF;


                if (create_config_reservation(p_model_line_id,
                                       x_config_id,
                                       p_quantity_to_reserve,
                                       p_reservation_uom_code,
                                       x_quantity_reserved,
                                       l_x_error_msg,
                                       l_x_error_msg_name) = TRUE)
                then
                    IF PG_DEBUG <> 0 THEN
                    oe_debug_pub.add('Success in Create Reservation. ',1);
                    END IF;
                else
                    IF PG_DEBUG <> 0 THEN
                    oe_debug_pub.add('Failed in Create Reservation. ',1);
                    END IF;

                    raise RESERVATION_ERROR;
                end if;

            end if; --x_available_qty >= p_quantity_to_reserve

            /*--------------------------------------------------+
              If available quantity to reserve is less than
              zero, return with no option to reserve.
              Otherwise, user has the option to reserve against
              the ATR quantity.
             +--------------------------------------------------*/
             if (x_available_qty <= 0) then
                 l_stmt_num := 190;
                 IF PG_DEBUG <> 0 THEN
                 oe_debug_pub.add('Not Enough Qty to reserve. ',1);
                 oe_debug_pub.add('Quantity Available to Rsrv: '
                          || to_char(x_available_qty),1);
                 END IF;


                 x_message_name := 'CTO_CONFIG_LINKED';
                 x_error_message := 'Config Item Linked.  No Qty to Rsrv';
                 --return TRUE;

             else
                 IF PG_DEBUG <> 0 THEN
                 oe_debug_pub.add
                     ('Matching Config Item: ' || to_char(x_config_id),1 );
                 oe_debug_pub.add
                     ('Quantity On-Hand: ' || to_char(x_available_qty),1);
                 END IF ;


                 x_message_name := 'CTO_RESERVE';

             end if;



          else

                 /* IMPORTANT!! */

                 oe_debug_pub.add
                     ('Matching Config Item: ' || ' Will Not attempt Reservation as Order is either not booked or is Dropship ' ,1 );


            /* BUG#2367720 */
           end if; /* code to be restricted to INTERNAL source type only */












             if( lPerformPPRollup = 1  ) then


	     -- Added by Renga Kannan on 04/01/02 to call the Purchase price rollup API

             IF PG_DEBUG <> 0 THEN
	     oe_debug_pub.add('Calling Purchase doc creation..',1);
             END IF;



                CTO_AUTO_PROCURE_PK.Create_Purchasing_Doc(
                                                p_config_item_id => l_x_config_id,
                                                p_overwrite_list_price  => 'N',
                                                p_called_in_batch       => 'N',
                                                p_batch_number          => l_batch_no,
						p_mode                  => 'ORDER',
						p_ato_line_id           => p_model_line_id,
                                                x_oper_unit_list        => x_oper_unit_list,
                                                x_return_status         => x_Return_Status,
                                                x_msg_count             => X_Msg_Count,
                                                x_msg_data              => x_msg_data);






             if x_return_status = FND_API.G_RET_STS_ERROR then
                        IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add(' Failed in Create_purchasing_doc call...',1);
                        END IF ;


                        -- raise FND_API.G_EXC_ERROR;
             elsif x_return_status =  FND_API.G_RET_STS_UNEXP_ERROR then
                        IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add(' Failed in Create_purchasing_doc call...',1);
                        END IF;


                        --  raise FND_API.G_EXC_UNEXPECTED_ERROR;
             end if;


             else

                IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('CTOMCRSB: ' || 'Will Not perform PP Rollup as profile is No ', 1);
                END IF;



             end if; /* pp rollup based on profile */




            if( lPerformCSTRollup = 1  ) then





             /* Changes for enhanced cost rollup */

             IF PG_DEBUG <> 0 THEN
             oe_debug_pub.add('going to call cost rollup in CTOMCRSB for matched items.',1);
             END IF;


             l_status := CTO_CONFIG_COST_PK.cost_rollup_ml(
                                        pTopAtoLineId   => p_model_line_id,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data);

             if (l_status = 0) then
                 IF PG_DEBUG <> 0 THEN
                 oe_debug_pub.add('Failure in cost_rollup ', 1);
                 END IF;

                 cto_msg_pub.cto_message('BOM', x_msg_data);
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
             else
                 IF PG_DEBUG <> 0 THEN
                 oe_debug_pub.add('Success in cost_rollup ', 1);
                 END IF;

             end if;



             else

                IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('CTOMCRSB: ' || 'Will Not perform Cost Rollup as profile is No ', 1);
                END IF;



             end if ; /* cost rollup based on profile */















        end if; -- end l_x_config_id is not null

        -- clean up oe_order_lines_all batch_id column

        return TRUE;

EXCEPTION

       when INVALID_LINE then
           x_message_name := 'CTO_LINE_STATUS_NOT_ELIGIBLE';
           x_error_message := 'CTOMCRSB:match_inquiry: ' ||
                              to_char(l_stmt_num) || ':' ||
                              substrb(sqlerrm,1,100);
           IF PG_DEBUG <> 0 THEN
           oe_debug_pub.add(x_error_message, 1);
           END IF;

           return FALSE;

       when BOM_NOT_DEFINED then
           x_message_name := 'CTO_BOM_NOT_DEFINED';
           x_error_message := 'CTOMCRSB:match_inquiry: ' ||
                              to_char(l_stmt_num) || ':' ||
                              substrb(sqlerrm,1,100);
           IF PG_DEBUG <> 0 THEN
           oe_debug_pub.add(x_error_message, 1);
           END IF;

           return FALSE;

       when INVALID_WORKFLOW_STATUS then
           x_message_name:= 'CTO_INVALID_WORKFLOW_STATUS';
           x_error_message := 'CTOMCRSB:match_inquiry: ' ||
                              to_char(l_stmt_num) || ':' ||
                              substrb(sqlerrm,1,100);
           IF PG_DEBUG <> 0 THEN
           oe_debug_pub.add(x_error_message, 1);
           END IF;

           return FALSE;

       when PROCESS_ERROR then
           x_message_name := 'CTO_MATCH_ERROR';
           x_error_message := 'CTOMCRSB:match_inquiry: ' ||
                              to_char(l_stmt_num) || ':' ||
                              substrb(sqlerrm,1,100);
           IF PG_DEBUG <> 0 THEN
           oe_debug_pub.add(x_error_message, 1);
           END IF;

           return FALSE;

       when RESERVATION_ERROR then
           x_message_name := 'CTO_RESERVE_ERROR';
           x_error_message := 'CTOMCRSB:match_inquiry: ' ||
                              to_char(l_stmt_num) || ':' ||
                              substrb(sqlerrm,1,100);
           IF PG_DEBUG <> 0 THEN
           oe_debug_pub.add(x_error_message, 1);
           END IF;

           return FALSE;

        WHEN FND_API.G_EXC_ERROR THEN
           x_error_message := 'CTOMCRSB:match_inquiry failed with expected error in stmt '
                            ||to_char(l_stmt_num);
           IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add ('match_inquiry: exp_error ' || to_char(l_stmt_num) ||sqlerrm,1);
           END IF;

           return FALSE;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           x_error_message := 'CTOMCRSB:match_inquiry failed with unexpected error in stmt '
                            ||to_char(l_stmt_num);
           IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add ('match_inquiry: unexp_error ' || to_char(l_stmt_num) ||sqlerrm,1);
           END IF;

           return FALSE;


       when OTHERS then
           x_message_name := 'CTO_MATCH_ERROR';
           x_error_message := 'CTOMCRSB:match_inquiry: '
                              || to_char(l_stmt_num) || ':' ||
                              substrb(sqlerrm,1,100);
           IF PG_DEBUG <> 0 THEN
           oe_debug_pub.add(x_error_message, 1);
           END IF;

           return FALSE;
END match_inquiry ;


/*****************************************************************************
   Function:  create_config_reservation
   Parameters:  p_model_line_id   - line id of the top model in oe_order_lines_all
                p_config_item_id - config id of the matching configuration
                                  from bom_ato_configurations
                p_quantity_to_reserve - quantity to reserve in ordered_quantity_uom
                x_error_message   - error message if match function fails
                x_message_name    - name of error message if match
                                    function fails

   Description:   This function is called after a match inquiry
                  has been done and the user attempts to reserve
                  available inventory.  This is called from
                  the Match and Reserve menu item.

                 match_and_reserve returns TRUE if the process is successful
                 (no process errors) and a reservation is successully made.

                 match_and_reserve returns FALSE if the process fails to create
                 the reservation.
*****************************************************************************/


function create_config_reservation(
	p_model_line_id       IN  NUMBER,
	p_config_item_id      IN  NUMBER,
	p_quantity_to_reserve IN  NUMBER,
        p_reservation_uom_code IN VARCHAR2,
        x_quantity_reserved   OUT nocopy NUMBER,
	x_error_msg           OUT nocopy VARCHAR2,
	x_error_msg_name      OUT nocopy VARCHAR2
    )
return boolean

IS

   l_stmt_num         NUMBER := 0;
   l_rec_reserve      CTO_RESERVE_CONFIG.rec_reserve;
   l_x_reserved_qty   NUMBER := 0;
   l_x_reservation_id NUMBER;
   l_x_status         VARCHAR(1);
   l_x_error_msg      VARCHAR2(2000);
   l_x_error_msg_name VARCHAR2(30);
   l_x_error_msg_count NUMBER;
   l_x_table_name     VARCHAR2(30);
   l_x_qoh            NUMBER;
   l_x_rqoh           NUMBER;
   l_x_qr            NUMBER;
   l_x_qs            NUMBER;
   l_x_att           NUMBER;
   l_x_atr           NUMBER;
   l_config_line_id  NUMBER;
   l_config_id       NUMBER;
   l_workflow_itemkey VARCHAR2(30);
   l_activity_result VARCHAR2(30);
   l_active_activity VARCHAR2(30);
   l_status          NUMBER;
   lSourceCode		varchar2(30);

   -- 2620282 : New variable to store bom revision date
   l_rev_date		date;

   /*  Handled Exceptions */
   PARAMETER_ERROR     EXCEPTION;
   RESERVATION_ERROR   EXCEPTION;
   PROCESS_ERROR       EXCEPTION;
   INVALID_WORKFLOW_STATUS EXCEPTION;

BEGIN
    l_stmt_num := 100;
    IF (p_config_item_id is NULL or
        p_quantity_to_reserve is NULL or
        p_model_line_id is NULL)
    THEN
	raise PARAMETER_ERROR;
    END IF;

    /*---------------------------------------------------+
     Link happens as part of the Match Inquiry.  Verify
     that the configuration item has been linked.
    +---------------------------------------------------*/
    l_stmt_num := 110;
    IF (config_line_exists(p_model_line_id,
                           l_config_line_id,
                           l_config_id) = FALSE)
    THEN
       /*----------------------------------------------+
         Config line does not exist.  Raise error.
       +-----------------------------------------------*/
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('create_config_reservation: ' || 'Config line does not exist. ', 1);
       END IF;
       l_stmt_num := 115;
       raise PROCESS_ERROR;

    END IF;

     /* 2620282 : Selecting bom revision date to pass it in the
    call to BOM_REVISIONS.get_item_revision_fn while getting config line
    information to perform reservation */

    /* 4162494 : Join with wip_parameters assumes mfg org is the distribution org
       which is incorrect. */

    l_stmt_num := 139;
    select 	trunc(greatest(nvl(cal.calendar_date,SYSDATE), SYSDATE),
                	      'MI')+1/(60*24)
    into	l_rev_date
    from    	bom_calendar_dates cal,
	        mtl_parameters     mp,
	        -- 4162494 wip_parameters     wp,
	        mtl_system_items   msi,
	        oe_order_lines_all oel
     where   oel.line_id = l_config_line_id
     and     mp.organization_id = oel.ship_from_org_id
     -- 4162494 and     wp.organization_id = mp.organization_id
     and     msi.organization_id = oel.ship_from_org_id
     and     msi.inventory_item_id = oel.inventory_item_id
     and     cal.calendar_code = mp.calendar_code
     and     cal.exception_set_id = mp.calendar_exception_set_id
     and     cal.seq_num =
                 (select greatest(1, (cal2.prior_seq_num -
                                       (ceil(nvl(msi.fixed_lead_time,0) +
                                        nvl(msi.variable_lead_time,0) *
					p_quantity_to_reserve
					))))
	                  from   bom_calendar_dates cal2
	                  where  cal2.calendar_code = mp.calendar_code
	                  and    cal2.exception_set_id =
	                               mp.calendar_exception_set_id
	                  and    cal2.calendar_date =
	                               trunc(oel.schedule_ship_date)
	                  );

    /*-----------------------------------------------------------------+
     Get necessary information from order line to perform reservation.
     The reservation against the configuration item is made against the
     configuration line, not the model line.
    +------------------------------------------------------------------*/
    l_stmt_num := 140;
    lSourceCode := fnd_profile.value('ONT_SOURCE_CODE');
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('create_config_reservation: ' || 'lSourceCode is '||lSourceCode, 2);
    END IF;
    select mso.sales_order_id,
           oel.line_id,   -- config line id
           oel.ship_from_org_id,
           oel.inventory_item_id,
           oel.order_quantity_uom,
           p_quantity_to_reserve,
           inv_reservation_global.g_source_type_inv,
           NULL,
           oel.schedule_ship_date,
           oeh.source_document_type_id,		-- bugfix 1799874: to check if it is an internal SO or regular
               -- 2776026: Pass revision only if item is revision contol.
	       -- 2620282: Selecting bom revision information
           decode( nvl(msi.revision_qty_control_code, 1), 1, NULL ,
           						BOM_REVISIONS.get_item_revision_fn (
											'ALL',
	                		  						'ALL',
	                		  						oel.ship_from_org_id,
					  						oel.inventory_item_id,
					  						l_rev_date
											))
    into   l_rec_reserve
    from   oe_order_lines_all oel,
           oe_order_headers_all oeh,
           --oe_order_types_v oet,
	   oe_transaction_types_tl oet,
           mtl_sales_orders mso,
           mtl_system_items msi
    where  oel.line_id = l_config_line_id
    and    oel.open_flag = 'Y'
    and    item_type_code = 'CONFIG'
    and    oeh.header_id = oel.header_id
    and    oet.transaction_type_id = oeh.order_type_id
    and    mso.segment1 = to_char(oeh.order_number)
    and    mso.segment2 = oet.name
    and    oet.language = (select language_code
			from fnd_languages
			where installed_flag = 'B')
    and    mso.segment3 = lSourceCode
    -- and    mso.segment3 = 'ORDER ENTRY'
    and    oel.inventory_item_id = p_config_item_id
    and    msi.inventory_item_id = oel.inventory_item_id
    and    msi.organization_id = oel.ship_from_org_id
    and    msi.base_item_id is not NULL;


    if (SQL%ROWCOUNT = 1) then
        l_stmt_num := 150;
        CTO_RESERVE_CONFIG.reserve_config(l_rec_reserve,
                                          l_x_reserved_qty,
                                          l_x_reservation_id,
                                          l_x_status,
                                          l_x_error_msg,
                                          l_x_error_msg_name);
    else
	raise PROCESS_ERROR;
    end if;

    if (l_x_status = FND_API.g_ret_sts_success) then
        l_stmt_num := 160;
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add
            ('create_config_reservation: ' || 'Success in reserve_config with reservation id:' ||
              to_char(l_x_reservation_id),1);
        END IF;
    else
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('create_config_reservation: ' || 'Failed in reserve_config.',1);
        END IF;
        raise PROCESS_ERROR;

    end if;

    x_error_msg_name := 'CTO_MR_SUCCESS';
    return TRUE;

EXCEPTION
    when PROCESS_ERROR then
            /* BUG#2367720 */
         if( l_x_error_msg_name is null ) then
         x_error_msg_name := 'CTO_RESERVE_ERROR';

         else

         x_error_msg_name := l_x_error_msg_name  ;

         end if ;

         x_error_msg := 'CTOMCRSB:create_config_reservation: ' ||
                        l_x_status || ': ' ||
                        l_x_error_msg;
         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('create_config_reservation: ' || x_error_msg, 1);
         END IF;
         return FALSE;

    when OTHERS then
         x_error_msg_name := 'CTO_RESERVE_ERROR';
         x_error_msg := 'CTOMCRSB:create_config_reservation: ' ||
                        to_char(l_stmt_num) || ':' ||
                        substrb(sqlerrm,1,100);
         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('create_config_reservation: ' || x_error_msg, 1);
         END IF;
	 return FALSE;

END create_config_reservation;


function config_line_exists(p_model_line_id IN NUMBER,
                            x_config_line_id OUT nocopy NUMBER,
                            x_config_item_id OUT nocopy NUMBER)
return boolean

is

begin
        /***************************************************************
         If config line already exists, do not match.  If a config
         line already exists, verify that the status of the configuration
         line allows a Match and Reserve to be performed.
         ***************************************************************/
         select oel.line_id, oel.inventory_item_id
         into   x_config_line_id, x_config_item_id
         from   oe_order_lines_all oel,
                mtl_system_items msi
         where  oel.link_to_line_id = p_model_line_id
         and    oel.item_type_code = 'CONFIG'
         and    oel.inventory_item_id = msi.inventory_item_id
         and    oel.ship_from_org_id = msi.organization_id
         and    msi.base_item_id is not null
         and    msi.bom_item_type = 4; --standard item

         return TRUE;

exception

when NO_DATA_FOUND then
     return FALSE;

when OTHERS then
     return FALSE;

end;

end CTO_MATCH_AND_RESERVE;

/
