--------------------------------------------------------
--  DDL for Package Body CTO_WIP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_WIP_UTIL" as
/* $Header: CTOWIPUB.pls 120.4 2006/06/28 01:31:37 rekannan noship $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : CTOWIPUB.pls                                                  |
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
|               June 7, 99  Angela Makalintal   Initial version		      |
|		May 7,  01   Sajani Sheth	Support for partial FAS       |
|		Sep 14, 01   Shashi Bhaskaran   Fixed bug 1988967             |
|		             While selecting from wsh_delivery_details        |
|		             we should check source_code='OE'                 |
|               Sep 26, 01   Shashi Bhaskaran   Fixed bug 2017099             |
|                            Check with ordered_quantity(OQ) instead of OQ-CQ |
|                            where CQ=cancelled_quantity. When a line is      |
|                            is canceled, OQ gets reflected.                  |
|                                                                             |
|               Oct 24, 01   Shashi Bhaskaran   Fixed bug 2074290             |
|                            Convert the ordered_quantity into Primary UOM for|
|                            comparing with get_reserved_qty.                 |
|									      |
|               Oct 25, 02   Kundan Sarkar      Bugfix 2644849 (2620282 in br)|
|                            Insert bom revision info in 		      |
|                            wip_job_schedule_interface 		      |
|
|		DEC 12, 2002  Kiran Konada
|				Added code for ML SUPPLy fetaure
|
|               Sep 23, 2003  Renga Kannan                                    |
|                               Changed the following two table acecss to     |
|                               view. This change is recommended by shipping  |
|                               team to avoid getting inbound/dropship lines.
|                               WSH_NEW_DELIVERIES to WSH_NEW_DELIVERIES_OB_GRP_V
                                WSH_DELIVERY_DETAILS to WSH_DELIVERY_DETAILS_OB_GRP_V
                                This changes brings a wsh dependency to our code
                                the wsh pre-req for this change is 3125046
|               June 1, 05  Renga  Kannann      Added nocopy hint
=============================================================================*/


--  Global constant holding the package name
G_PKG_NAME                      CONSTANT VARCHAR2(30) := 'OE_ORDER_BOOK_UTIL';

/*****************************************************************************
   Procedure:  insert_wip_interface
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


PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);

PROCEDURE insert_wip_interface(
	p_line_id               in  number,
	p_wip_seq               in  number,
        p_status_type           in  number,
        p_class_code            in  varchar2,
        p_conc_request_id       IN  NUMBER,
        p_conc_program_id       IN  NUMBER,
        p_conc_login_id         IN  NUMBER,
        p_user_id               IN  NUMBER,
        p_appl_conc_program_id  IN  NUMBER,
        x_return_status         out  NOCOPY varchar2,
        x_error_message         out  NOCOPY VARCHAR2,  /* 70 bytes to hold  msg */
        x_message_name          out  NOCOPY VARCHAR2 /* 30 bytes to hold  name */
	)

IS

         --ml supply var's
	l_mlsupply_parameter  number  := 0;
        l_return_status       varchar2(1);
	l_error_message       varchar2(400) := null;
	l_message_name        varchar2(30) := null;

	x_groupID  number := null;

	l_sch_method number;
	l_status     number;



        l_stmt_num     		number := 0;
        l_user_id      		varchar2(255);
	lDepPlanFlag		varchar2(1);
	l_ordered_qty		number := 0;	-- order line qty
	l_partial_qty		number := 0;	-- order qty - reserved qty
	l_wo_created_qty 	number := 0;	--
	l_current_qty		number := 0;



        insert_error    	exception;

	CURSOR c_delivery_lines IS
	select  sum(wdd.requested_quantity) pQuantity,
						-- Note: bug 1661094: wdd.requested_quantity is in primary uom
		wda.delivery_id, wdd.load_seq_number lsn
	from 	WSH_DELIVERY_DETAILS_OB_GRP_V wdd,
		wsh_delivery_assignments wda
	where 	wdd.source_line_id = p_line_id
	and 	wda.delivery_detail_id = wdd.delivery_detail_id
        and  	wdd.source_code = 'OE' 	-- bugfix 1988967: only OE lines should be picked since
                                        -- wsh_delivery_details can have lines related to
                                        -- containers (source_code=WSH)
	group by wdd.load_seq_number, wda.delivery_id
	order by wda.delivery_id, wdd.load_seq_number;

BEGIN

	x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_stmt_num := 100;

	select nvl(oel.dep_plan_required_flag, 'N')
	into lDepPlanFlag
	from oe_order_lines_all oel
	where oel.line_id = p_line_id;

	--
	-- Changes to support supply creation for partial qty
	-- Getting qty for which supply needs to be created
	--
	l_stmt_num := 130;

	--
	-- bugfix 2095043: Added call to CTO_WIP_WRAPPER.Get_NotInv_Qty
	-- Get_NotInv_Qty will return ordered_quantity (in primary UOM) if shipping_interface_flag is Y
	-- Otherwise, it will return qty that has NOT been inventory interfaced.
	--
	-- All quantities are in primary UOM.
	--

	l_partial_qty := CTO_WIP_WRAPPER.Get_NotInv_Qty(p_line_id) - CTO_WIP_WRAPPER.Get_Reserved_Qty(p_line_id);


	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('insert_wip_interface: ' || 'Partial qty for WO creation (in primary UOM) : '||to_char(l_partial_qty), 2);

		oe_debug_pub.add('insert_wip_interface: ' || 'Dep Plan Flag for line_id '||to_char(p_line_id)||' is '||lDepPlanFlag, 2);
	END IF;


	IF lDepPlanFlag = 'N' THEN
	--
	-- No departure planning.
	-- Create 1 work order for order line
	--

		  l_stmt_num := 140;

	    --looking for ML supply org parameter value

	    SELECT  ENABLE_LOWER_LEVEL_SUPPLY
	    INTO l_mlsupply_parameter
	    FROM bom_parameters bp,
	         oe_order_lines_all oel
	    WHERE oel.line_id = p_line_id
	    AND   oel.ship_from_org_id 	= bp.organization_id;

	    IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('insert_wip_interface: ' || 'enavle lower level supply value is  '|| l_mlsupply_parameter , 4);


	    END IF;

	   IF (l_mlsupply_parameter in (2,3)) THEN    --auto created config =2, auto created configs + ato items = 3




			   IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('insert_wip_interface: ' || 'Before call to create_subassembly_jobs with enable lower supply param  '|| l_mlsupply_parameter , 4);


			   END IF;


			l_stmt_num := 141;
			CTO_SUBASSEMBLY_SUP_PK.create_subassembly_jobs(
							l_mlsupply_parameter,
							p_line_id,
							l_partial_qty,
							p_wip_seq ,
							p_status_type ,
							p_class_code ,
							p_conc_request_id ,
							p_conc_program_id ,
							p_conc_login_id ,
							p_user_id ,
							p_appl_conc_program_id ,
							l_return_status,
							l_error_message,
							l_message_name
							);

		       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add ('insert_wip_interface: ' || 'failed after get_wroking_day' || l_return_status ,1);
					oe_debug_pub.add ('insert_wip_interface: ' || 'error message' || l_error_message ,1);
				END IF;
				RAISE FND_API.G_EXC_ERROR;
		       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add ('insert_wip_interface: ' || ' failed after call to get_working_day' || l_return_status ,1);
					oe_debug_pub.add ('insert_wip_interface: ' || 'error message' || l_error_message ,1);
				END IF;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	               ELSE
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add('insert_wip_interface: ' || 'success from create_Subassembly_jobs ' ,1);
					oe_debug_pub.add('insert_wip_interface: ' || l_error_message ,1);
				END IF;
	               END IF;





	    END IF; --l_mlsupply_parameter


                -- Fixed bug 5346922
		-- Removed the decode stmt for status type column in the insert
		l_stmt_num := 150;
        	insert into wip_job_schedule_interface
                    	(last_update_date,
                     	last_updated_by,
                     	creation_date,
                     	created_by,
                     	last_update_login,
                     	request_id,
                     	program_id,
                     	program_application_id,
                     	program_update_date,
                     	group_id,
                     	source_code,
                     	source_line_id,
                     	process_phase,
                     	process_status,
                     	organization_id,
                     	load_type,
                     	status_type,
                     	last_unit_completion_date,
                     	primary_item_id,
                     	wip_supply_type,
                     	class_code,
                     	firm_planned_flag,
                     	demand_class,
                     	start_quantity,
                     	bom_revision_date,
                     	routing_revision_date,
                     	project_id,
                     	task_id,
                     	due_date,
                     	bom_revision			/* 2620282 : Insert bom revision info */
                    	)
         	select SYSDATE,                		/* Last_Updated_Date */
                	p_user_id,              	/* Last_Updated_By */
                	SYSDATE,                	/* Creation_Date */
                	p_user_id,              	/* Created_By */
                	p_conc_login_id,        	/* Last_Update_Login */
                	p_conc_request_id,      	/* Request_ID */
                	p_conc_program_id,      	/* Program_ID */
                	p_appl_conc_program_id, 	/* Program_Application_ID */
                	SYSDATE,                	/* Last Update Date */
                	p_wip_seq,              	/* group_id */
                	'WICDOL',               	/* source_code */
                	oel.line_id,            	/* source line id */
                	WIP_CONSTANTS.ML_VALIDATION, 	/* process_phase */
                	WIP_CONSTANTS.PENDING,       	/* process_status */
                	oel.ship_from_org_id,        	/* organization id */
                	WIP_CONSTANTS.CREATE_JOB,    	/* Load_Type */
                	nvl(p_status_type, WIP_CONSTANTS.UNRELEASED),/* Status_Type */
                	oel.schedule_ship_date,      	/* Date Completed */
                	oel.inventory_item_id,       	/* Primary_Item_Id */
                	WIP_CONSTANTS.BASED_ON_BOM,  	/* Wip_Supply_Type */
                	decode(p_class_code, null, null
                	           , p_class_code),	/* Accouting Class */
                	2,                     		/* Firm_Planned_Flag */
                	oel.demand_class_code,     	/* Demand Class */
			l_partial_qty,          	/* Start Quantity: (in primary uom) */    --bugfix 2074290
                	trunc(greatest(nvl(cal.calendar_date,SYSDATE), SYSDATE),
                	      'MI')+1/(60*24), 		/* BOM_Revision_Date */
	                greatest(nvl(cal.calendar_date,SYSDATE), SYSDATE),
	                                       		/* Routing_Revision_Date */
	                oel.project_id,        		/* Project_ID */
	                oel.task_id,            	/* Task_ID */
	                oel.schedule_ship_date,
	                BOM_REVISIONS.get_item_revision_fn
	                		( 'ALL',
	                		  'ALL',
	                		  oel.ship_from_org_id,
					  oel.inventory_item_id,
					  (trunc (greatest(nvl(cal.calendar_date,SYSDATE),
					  				SYSDATE),'MI')+1/(60*24) )
					) /* 2620282 : Insert bom revision info */
	        from    bom_calendar_dates cal,
	                mtl_parameters     mp,
	                wip_parameters     wp,
	                mtl_system_items   msi,
	                oe_order_lines_all oel
	        where   oel.line_id = p_line_id
	        and     mp.organization_id = oel.ship_from_org_id
	        and     wp.organization_id = mp.organization_id
	        and     msi.organization_id = oel.ship_from_org_id
	        and     msi.inventory_item_id = oel.inventory_item_id
	        and     cal.calendar_code = mp.calendar_code
	        and     cal.exception_set_id = mp.calendar_exception_set_id
	        and     cal.seq_num =
	                 (select greatest(1, (cal2.prior_seq_num -
	                                       (ceil(nvl(msi.fixed_lead_time,0) +
	                                        nvl(msi.variable_lead_time,0) *
						l_partial_qty			--bugfix 2074290: this is in primary uom
						))))
	                  from   bom_calendar_dates cal2
	                  where  cal2.calendar_code = mp.calendar_code
	                  and    cal2.exception_set_id =
	                               mp.calendar_exception_set_id
	                  and    cal2.calendar_date =
	                               trunc(oel.schedule_ship_date)
	                  );

        	if (SQL%ROWCOUNT > 0) then
        	    	IF PG_DEBUG <> 0 THEN
        	    		oe_debug_pub.add('insert_wip_interface: ' || 'Number of Rows Inserted in WJSI: ' || to_char(SQL%ROWCOUNT));
        	    	END IF;
            		x_return_status := FND_API.G_RET_STS_SUCCESS;
        	else
            		x_return_status := FND_API.G_RET_STS_ERROR;
            		cto_msg_pub.cto_message('BOM', 'BOM_ATO_PROCESS_ERROR');
            		raise INSERT_ERROR ;
        	end if;








        ELSE
		--
        	-- Departure planned order line
		-- Create 1 work order for each unique combination of
		-- delivery_id and load_seq_number.
		-- The requested quantity should be a sum of all the lines for
		-- each combination
		--

		l_stmt_num := 160;
		l_wo_created_qty := 0;
          	l_current_qty := 0;

		for lNextRec IN c_delivery_lines LOOP

			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('insert_wip_interface: ' || 'line_id = '||to_char(p_line_id), 2);

				oe_debug_pub.add('insert_wip_interface: ' || 'delivery_id = '||to_char(lNextRec.delivery_id), 2);

				oe_debug_pub.add('insert_wip_interface: ' || 'lsn = '||to_char(lNextRec.lsn), 2);

				oe_debug_pub.add('insert_wip_interface: ' || 'Qty = '||to_char(lNextRec.pQuantity), 2);
			END IF;

			l_current_qty := lNextRec.pQuantity;
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('insert_wip_interface: ' || 'l_current_qty::'||to_char(l_current_qty), 2);
			END IF;

			IF l_current_qty > l_partial_qty - l_wo_created_qty THEN
				l_current_qty := l_partial_qty - l_wo_created_qty;
			END IF;
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('insert_wip_interface: ' || 'New l_current_qty::'||to_char(l_current_qty), 2);
			END IF;


	     --looking for ML supply org parameter value

	    l_stmt_num := 169;

	    SELECT  ENABLE_LOWER_LEVEL_SUPPLY
	    INTO l_mlsupply_parameter
	    FROM bom_parameters bp,
	         oe_order_lines_all oel
	    WHERE oel.line_id = p_line_id
	    AND   oel.ship_from_org_id 	= bp.organization_id;

	    IF (l_mlsupply_parameter in (2,3)) THEN    --auto created config =2, auto created configs + ato items = 3


			l_stmt_num := 169;
			CTO_SUBASSEMBLY_SUP_PK.create_subassembly_jobs(
							l_mlsupply_parameter,
							p_line_id,
							l_current_qty ,
							p_wip_seq ,
							p_status_type ,
							p_class_code ,
							p_conc_request_id ,
							p_conc_program_id ,
							p_conc_login_id ,
							p_user_id ,
							p_appl_conc_program_id ,
							l_return_status,
							l_error_message,
							l_message_name
							);

		       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add ('insert_wip_interface: ' || 'failed after get_wroking_day' || l_return_status ,1);
					oe_debug_pub.add ('insert_wip_interface: ' || 'error message' || l_error_message ,1);
				END IF;
				RAISE FND_API.G_EXC_ERROR;
		       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add ('insert_wip_interface: ' || ' failed after call to get_working_day' || l_return_status ,1);
					oe_debug_pub.add ('insert_wip_interface: ' || 'error message' || l_error_message ,1);
				END IF;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	               ELSE
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add('insert_wip_interface: ' || 'success from get_working_day ' ,1);
					oe_debug_pub.add('insert_wip_interface: ' || l_error_message ,1);
				END IF;
	               END IF;





	  END IF; --l_mlsupply_parameter


                         -- Fixed bug 5346922
			 -- Removed the decode for supply type
			l_stmt_num := 170;
	        	insert into wip_job_schedule_interface
                	    	(last_update_date,
                	     	last_updated_by,
                	     	creation_date,
                	     	created_by,
                	     	last_update_login,
                	     	request_id,
                	     	program_id,
                	     	program_application_id,
                	     	program_update_date,
                	     	group_id,
                	     	source_code,
                	     	source_line_id,
                	     	process_phase,
                	     	process_status,
                	     	organization_id,
                	     	load_type,
                	     	status_type,
                	     	last_unit_completion_date,
                	     	primary_item_id,
                	     	wip_supply_type,
                	     	class_code,
                	     	firm_planned_flag,
                	     	demand_class,
                	     	start_quantity,
                	     	bom_revision_date,
                	     	routing_revision_date,
                	     	project_id,
                	     	task_id,
                	     	due_date,
				delivery_id,
				build_sequence,
				bom_revision			/* 2620282 : Insert bom revision info */
                	    	)
         		select SYSDATE,                 	/* Last_Updated_Date */
                		p_user_id,              	/* Last_Updated_By */
                		SYSDATE,                	/* Creation_Date */
                		p_user_id,              	/* Created_By */
                		p_conc_login_id,        	/* Last_Update_Login */
                		p_conc_request_id,      	/* Request_ID */
                		p_conc_program_id,      	/* Program_ID */
                		p_appl_conc_program_id, 	/* Program_Application_ID */
                		SYSDATE,                	/* Last Update Date */
                		p_wip_seq,              	/* group_id */
                		'WICDOL',               	/* source_code */
                		oel.line_id,            	/* source line id */
                		WIP_CONSTANTS.ML_VALIDATION, 	/* process_phase */
                		WIP_CONSTANTS.PENDING,       	/* process_status */
                		oel.ship_from_org_id,        	/* organization id */
                		WIP_CONSTANTS.CREATE_JOB,    	/* Load_Type */
                		nvl(p_status_type, WIP_CONSTANTS.UNRELEASED),/* Status_Type */
                		oel.schedule_ship_date,      	/* Date Completed */
                		oel.inventory_item_id,       	/* Primary_Item_Id */
                		WIP_CONSTANTS.BASED_ON_BOM,  	/* Wip_Supply_Type */
                		decode(p_class_code, null, null
                		                   , p_class_code),
								/* Accouting Class */
                		2,                     		/* Firm_Planned_Flag */
                		oel.demand_class_code,     	/* Demand Class */
                		INV_CONVERT.inv_um_convert(oel.inventory_item_id, 	--item_id
                        			   5,		-- bugfix 2204376: pass precision of 5
						   l_current_qty,
						   oel.order_quantity_uom,	--from uom
						   msi.primary_uom_code,	--to uom
						   null,			--from name
						   null				--to name
						  ),		/* start qty */
                		trunc(greatest(nvl(cal.calendar_date,SYSDATE), SYSDATE),
					'MI')+1/(60*24), 	/* BOM_Revision_Date */
	                	greatest(nvl(cal.calendar_date,SYSDATE), SYSDATE),
	                	                       		/* Routing_Revision_Date */
	                	oel.project_id,        		/* Project_ID */
	                	oel.task_id,            	/* Task_ID */
	                	oel.schedule_ship_date,
				lNextRec.delivery_id,
				lNextRec.lsn,
				BOM_REVISIONS.get_item_revision_fn
	                		( 'ALL',
	                		  'ALL',
	                		  oel.ship_from_org_id,
					  oel.inventory_item_id,
					  (trunc (greatest(nvl(cal.calendar_date,SYSDATE),
					  				SYSDATE),'MI')+1/(60*24) )
					)			/* 2620282 : Insert bom revision info */
	        	from    bom_calendar_dates cal,
	        	        mtl_parameters     mp,
	        	        wip_parameters     wp,
	        	        mtl_system_items   msi,
	        	        oe_order_lines_all oel
	        	where   oel.line_id = p_line_id
	        	and     mp.organization_id = oel.ship_from_org_id
	        	and     wp.organization_id = mp.organization_id
	        	and     msi.organization_id = oel.ship_from_org_id
	        	and     msi.inventory_item_id = oel.inventory_item_id
	        	and     cal.calendar_code = mp.calendar_code
	        	and     cal.exception_set_id = mp.calendar_exception_set_id
	        	and     cal.seq_num =
	        	         (select greatest(1, (cal2.prior_seq_num -
	        	                               (ceil(nvl(msi.fixed_lead_time,0) +
	        	                                nvl(msi.variable_lead_time,0) *
                                         		INV_CONVERT.inv_um_convert    	-- bugfix 1661094:
                                                      		(oel.inventory_item_id,	-- added conversion logic
                        					5,		-- bugfix 2204376: pass precision of 5
                                                       		l_current_qty,
                                                       		oel.order_quantity_uom,
                                                       		msi.primary_uom_code,
                                                       		null,
                                                       		null)
							))))
	        	          from   bom_calendar_dates cal2
	        	          where  cal2.calendar_code = mp.calendar_code
	        	          and    cal2.exception_set_id =
	        	                       mp.calendar_exception_set_id
	        	          and    cal2.calendar_date =
	        	                       trunc(oel.schedule_ship_date)
	                  );


        		if (SQL%ROWCOUNT > 0) then
        		    	IF PG_DEBUG <> 0 THEN
        		    		oe_debug_pub.add('insert_wip_interface: ' || 'Number of Rows Inserted in WJSI for departure planned : ' ||
						  to_char(SQL%ROWCOUNT),1);
        		    	END IF;
            			x_return_status := FND_API.G_RET_STS_SUCCESS;
        		else
            			x_return_status := FND_API.G_RET_STS_ERROR;
            			cto_msg_pub.cto_message('BOM', 'BOM_ATO_PROCESS_ERROR');
            			raise INSERT_ERROR ;
        		end if;

			l_stmt_num := 180;
			l_wo_created_qty := l_wo_created_qty + l_current_qty;

			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('insert_wip_interface: ' || 'Qty of wo created::'||to_char(l_wo_created_qty),2);
			END IF;

			IF (l_wo_created_qty >= l_partial_qty) THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add('insert_wip_interface: ' || 'Exiting out of partial qty loop',2);
				END IF;
				EXIT;
			END IF;

		END LOOP;
	END IF;

EXCEPTION


         when FND_API.G_EXC_ERROR then

              x_return_status := FND_API.G_RET_STS_ERROR;
             x_error_message := 'CTOWIPUB.insert wip interface expected  excpn: ';


             	IF PG_DEBUG <> 0 THEN
             		oe_debug_pub.add('insert_wip_interface: ' || ' expected excpn:  ' || x_error_message,1);
             	END IF;



	 when FND_API.G_EXC_UNEXPECTED_ERROR then
	     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_error_message := 'CTOWIPUB.insert wip interface N expected  excpn: '|| ':' ||
                                substrb(sqlerrm,1,100) ;


             	IF PG_DEBUG <> 0 THEN
             		oe_debug_pub.add('insert_wip_inetrface: ' || ' UN expected excpn:  ' || x_error_message,1);
             	END IF;



        when NO_DATA_FOUND then
           x_error_message := 'CTOWIPUB.insert_wip_interface raised no-data-found: '|| ':' ||
                                substrb(sqlerrm,1,100);
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('insert_wip_interface: ' || x_error_message,1);
           END IF;
           cto_msg_pub.cto_message('BOM', 'BOM_ATO_PROCESS_ERROR');

        when INSERT_ERROR then
           x_return_status := FND_API.G_RET_STS_ERROR;
           x_error_message := 'CTOWIPUB.insert_wip_interface raised INSERT_ERROR:' || to_char(l_stmt_num)|| ':' ||
                                substrb(sqlerrm,1,100);
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('insert_wip_interface: ' || x_error_message,1);
           END IF;

        when OTHERS then
           x_return_status := FND_API.G_RET_STS_ERROR;
           x_error_message := 'CTOWIPUB.insert_wip_interface raised OTHERS excpn: ' || to_char(l_stmt_num)|| ':' ||
                                substrb(sqlerrm,1,100) ;

           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('insert_wip_interface: ' || x_error_message,1);
           END IF;
           cto_msg_pub.cto_message('BOM', 'BOM_ATO_PROCESS_ERROR');
           OE_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME
                        ,   'insert_wip_interface'
                        );

END insert_wip_interface;

function departure_plan_required(p_line_id       IN NUMBER
) return integer

IS
     l_eligible_line NUMBER := 0;
BEGIN
     select 1
     into   l_eligible_line
     from   oe_order_lines_all oel,
            mtl_customer_items mci
     where  oel.line_id = p_line_id
     and    oel.ordered_item_id = mci.customer_item_id (+)
     and    ((oel.item_identifier_type <> 'CUST')
     or      (oel.item_identifier_type = 'CUST'
         and  mci.dep_plan_prior_bld_flag <> 'Y')
     or      (validate_delivery_id(to_number(p_line_id)) = 1));

     -- Do not need to be departure planned
     return 0;

EXCEPTION

     when NO_DATA_FOUND then
         return 1;

     when OTHERS then
         OE_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME
                        ,   'departure_plan_required'
                        );
         return 2;

END departure_plan_required;

function validate_delivery_id(p_line_id       IN NUMBER
) return integer

IS

     l_eligible_line NUMBER := 0;

BEGIN

     select 1
     into   l_eligible_line
     from   oe_order_lines_all oel
     where  exists (select 'Exists'
                         from   WSH_DELIVERY_DETAILS_OB_GRP_V wdd,
                                wsh_delivery_assignments wda,
                                mtl_customer_items mci
                         where  wdd.source_line_id  = oel.line_id
                         and    mci.customer_item_id = oel.ordered_item_id
                         and    wda.delivery_detail_id = wdd.delivery_detail_id
                         and    mci.dep_plan_prior_bld_flag = 'Y'
                         and    oel.shipping_interfaced_flag = 'Y'
                         and    wda.delivery_id is not NULL
			 and    wdd.source_code = 'OE'		-- bugfix 1988967
                      )
     and  oel.line_id = p_line_id;

     return 1;


EXCEPTION

     when NO_DATA_FOUND then
        return 0;

     when OTHERS then
        return 0;

END validate_delivery_id;


PROCEDURE Delivery_Planned(p_line_id 	IN 	   NUMBER,
			x_result_out	OUT NOCOPY VARCHAR2,
			x_return_status OUT NOCOPY VARCHAR2,
			x_msg_count	OUT NOCOPY NUMBER,
			x_msg_data	OUT NOCOPY VARCHAR2)
IS

l_assigned	varchar2(100);
l_planned 	varchar2(100);
l_imported	varchar2(100);

Delivery_Not_Planned EXCEPTION;

BEGIN

	--
	-- Verify that delivery lines have been imported and quantities
	-- for all delivey lines add up to the total requested qty
	--

	BEGIN
	select 'IMPORTED'
	into 	l_imported
	from 	oe_order_lines_all oel,
		WSH_DELIVERY_DETAILS_OB_GRP_V wdd,
		mtl_system_items msi						--bugfix 2074290: added msi
	where 	oel.line_id = p_line_id
	and  	wdd.source_line_id = oel.line_id
	and     oel.inventory_item_id = msi.inventory_item_id			--bugfix 2074290: added joins
	and     oel.ship_from_org_id = msi.organization_id
	and    	wdd.source_code = 'OE'		-- bugfix 1988967
        -- begin bugfix 2074290:  convert OQ to primary uom since WDD stores requested qty in primary uom
        and     INV_CONVERT.inv_um_convert
                        (oel.inventory_item_id,
                         5,		-- bugfix 2204376: pass precision of 5
                         oel.ordered_quantity,
                         oel.order_quantity_uom,
                         msi.primary_uom_code,
                         null,
                         null) = (select nvl(sum(wdd1.requested_quantity), 0)   -- bugfix 2017099
        --end bugfix 2074290
				from  WSH_DELIVERY_DETAILS_OB_GRP_V wdd1
				where wdd1.source_line_id = oel.line_id
				and   wdd1.source_code = 'OE')			--bugfix 1988967
	and 	rownum = 1;

	EXCEPTION
		when NO_DATA_FOUND then
		   IF PG_DEBUG <> 0 THEN
		   	oe_debug_pub.add('Delivery_Planned: ' || 'Delivery lines HAVE NOT BEEN IMPORTED for order line '||to_char(p_line_id), 2);
		   END IF;
		   RAISE Delivery_Not_Planned;

	END; /* Block checking if delivery lines are imported*/


	--
	-- Verify that deliveries have been assigned to all delivery lines
	--

	BEGIN

	select 'NOTASSIGNED'
	into 	l_assigned
	from 	oe_order_lines_all oel,
		WSH_DELIVERY_DETAILS_OB_GRP_V wdd,
		wsh_delivery_assignments wda
	where 	oel.line_id = p_line_id
	and 	wdd.source_line_id = oel.line_id
	and 	wdd.source_code = 'OE'	--bugfix 1988967
	--and oel.ordered_quantity - nvl(oel.cancelled_quantity, 0) = (select nvl(sum(wdd1.requested_quantity), 0)
		--from wsh_delivery_details wdd1
		--where wdd1.source_line_id = oel.line_id)
	and wda.delivery_detail_id = wdd.delivery_detail_id
	and wda.delivery_id is null
	and rownum = 1;

	IF l_assigned = 'NOTASSIGNED' THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Delivery_Planned: ' || 'Deliveries have NOT BEEN ASSIGNED for line '||to_char(p_line_id), 1);
		END IF;
		RAISE Delivery_Not_Planned;
	END IF; /* if delivery not assigned for any delivery line*/

	EXCEPTION
		when no_data_found then
		     IF PG_DEBUG <> 0 THEN
		     	oe_debug_pub.add('Delivery_Planned: ' || 'Deliveries HAVE BEEN ASSIGNED for all delivery lines for order line '||to_char(p_line_id), 2);
		     END IF;

	END; /* Block checking for delivery assignments*/

	--
	-- Deliveries have been assigned for all delivery lines.
	-- Check if all deliveries are planned
	--

	BEGIN

	select 'NOTPLANNED'
	into 	l_planned
	from  	oe_order_lines_all oel,
		WSH_DELIVERY_DETAILS_OB_GRP_V wdd,
		wsh_delivery_assignments wda,
		WSH_NEW_DELIVERIES_OB_GRP_V wnd
	where 	oel.line_id = p_line_id
	and 	wdd.source_line_id = oel.line_id
	and 	wdd.source_code = 'OE'		--bugfix 1988967
	and 	wda.delivery_detail_id = wdd.delivery_detail_id
	and 	wda.delivery_id = wnd.delivery_id
	and 	nvl(wnd.planned_flag,'N') = 'N'
	and 	rownum=1;

	IF l_planned = 'NOTPLANNED' THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Delivery_Planned: ' || 'Deliveries have been assigned, but NOT PLANNED yet for line '||to_char(p_line_id), 1);
		END IF;
		RAISE Delivery_Not_Planned;
	END IF; /* if delivery not planned*/

	EXCEPTION
		when NO_DATA_FOUND then
		     IF PG_DEBUG <> 0 THEN
		     	oe_debug_pub.add('Delivery_Planned: ' || 'Deliveries HAVE BEEN PLANNED for order line '||to_char(p_line_id), 2);
		     END IF;

	END; /* Block checking if deliveries planned */

	--
	-- Deliveries have been assigned and planned
	--

	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_result_out :=  FND_API.G_TRUE;

EXCEPTION
	when DELIVERY_NOT_PLANNED then
	     x_return_status := FND_API.G_RET_STS_SUCCESS;
	     x_result_out := FND_API.G_FALSE;

    	when FND_API.G_EXC_ERROR then
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('Delivery_Planned: ' || 'CTO_WIP_UTIL.Delivery_Planned::exp error', 1);
             END IF;
	     x_return_status := FND_API.G_RET_STS_ERROR;
	     CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);

    	when FND_API.G_EXC_UNEXPECTED_ERROR then
	     IF PG_DEBUG <> 0 THEN
	     	oe_debug_pub.add('Delivery_Planned: ' || 'CTO_WIP_UTIL.Delivery_Planned::unexp error', 1);
	     END IF;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	     CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);

    	when OTHERS then
	     IF PG_DEBUG <> 0 THEN
	     	oe_debug_pub.add('Delivery_Planned: ' || 'CTO_WIP_UTIL.Delivery_Planned::others', 1);
	     END IF;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             if	FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
             then
        	FND_MSG_PUB.Add_Exc_Msg
        		(   'CTO_WIP_UTIL'
                	,   'Delivery_Planned'
                	);
             end if;
	     CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);

END Delivery_Planned;



end CTO_WIP_UTIL;

/
