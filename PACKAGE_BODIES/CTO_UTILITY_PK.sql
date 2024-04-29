--------------------------------------------------------
--  DDL for Package Body CTO_UTILITY_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_UTILITY_PK" as
/* $Header: CTOUTILB.pls 120.15.12010000.7 2010/08/24 12:50:50 abhissri ship $*/

/*----------------------------------------------------------------------------+
| Copyright (c) 1993 Oracle Corporation    Belmont, California, USA
|                       All rights reserved.
|                       Oracle Manufacturing
|
|FILE NAME   : CTOUTILB.pls
|
|DESCRIPTION : Contains modules to :
|		1. Populate temporary tables bom_cto_order_lines and
|		bom_cto_src_orgs, used for intermediate CTO processing
|		2. Update these tables with the config_item_id
|		3. Copy sourcing rule assignments from model to config item
|
|HISTORY     : Created on 04-MAY-2000  by Sajani Sheth
|              Modified on 18-MAY-2000 by Sushant Sawant
|              Modified on 23-JUN-2000 by Sushant Sawant
|              Modified on 08-AUG-2000 by Sushant Sawant
|              Modified on 11-JAN-2001 by Sushant Sawant
|                                         removed multilevel profile query
|              Modified on 30-APR-2001 By Renga Kannan
|                                         FiXed the where condition in MRP_SOURCES_V query.
|                                         The where condition for the field source_type is added
|                                         with nvl function.
|
|
|              Modified on 14-MAY-2001 by Sushant Sawant
|                                         changes made to trunc to reflect
|                                         changes made to branch due to BUG
|                                         1728383 for performance.
|
|              Modified on 05-JUN-2001 by Sushant Sawant
|                                         changes made to derive perform_match value
|                                         through BOM:MATCH_CONFIG profile.
|              Modified on 15-JUN-2001 by Renga Kannan
|                                         Moved the get_model_sourcing_org code from
|                                         CTO_ATP_INTERFACE_PK to CTO_UTILITY_PK
|                                         This decision is taken by CTO team on
|                                         06/15/2001 to avoid the dependency
|                                         with CTOATPIB.pls for this procedure
|                                         This procedure is used in change order
|                                         package. We are expecting this procedure to
|                                         be used in future also.
|              Modified on 22-JUN-2001 by Shashi Bhaskaran : bugfix 1811007
|                                         Added a new function convert_uom for wt/vol
|                                         calculation.
|	       Modified on 18-JUL-2001 by Kundan Sarkar
|					  fixed bug 1876618 to improve performance
|	       Modified on 18-JUL-2001 by Shashi Bhaskaran : bugfix 1799874
|					  Added a new function get_source_document_id
|					  to know if it is a regular SO or internal SO.
|
|              Modified on 21-AUG-21001 by Renga Kannan
|
|                                          Get_model_sourcing_org and related procedures
|                                          are modified to handle BUY model type also. This
|                                          change is done as part of 'Procuring config' and
|                                          Auto create Req for ATO item project(Patch set G)
|                                          The changes made in the CTOATPIB.pls file is replicated
|                                          here .Look at the individual places for Further comments.
|                                          Get_all_item_orgs procedure is modified as part of this
|                                          Project
|              Modified on 24-AUG-2001 by Sushant Sawant: BUG #1957336
|                                         Added a new functionality for preconfigure bom.

|              Modified on 02-NOV-2001 by Renga Kannan
|                                         Modified Generate_routing_attachment_text
|                                         Operation code was incorrect. One more join
|                                         is added to it. This bug was found during
|                                         Patch set G system testing.
|
|
|
|              Modified on 08-NOV-2001 by Renga Kannan
|                                         Modified the populate_src_orgs procedure
|                                         Added one more exception for invalid sourcing
|                                         When the item is not defined in the sourcing
|                                         org it will error out saying invalid sourcing
|
|
|              Modified on 13-NOV-2001 by Renga Kannan
|
|                                         The error message handling for this file is
|                                         changed completely. The FND_MESSAGE.SET_NAME
|                                         needs to be called twice in all the error handling
|                                         exception. And there should be one add for OE and
|                                         one add for FND. IN the exception block we need
|                                         to call the fnd_msg_pub.count_and_get and
|                                         oe_msg_pub.count_and_get.
|
|
|              Modified on 13-NOV-2001 By Renga Kannan
|
|
|                                         Modified the procedure Create_sourcing_rule
|                                         to have a filter condition to choose only
|                                         assignment_type 3 and 6.
|
|              Modified on 08-MAR-2002 By Sushant Sawant
|
|                                         BUG#2234858
|                                         Added new functionality for Drop Shipment
|                                         organization_type = 3 ,4 BUY
|                                         organization_type = 5 ,6 DROP SHIP
|              Modified on 27-MAR-2002 By Kiran Konada
|                                         removed the procedure GENERATE_ROUTING_ATTACH_TEXT
|                                         changed the signature and modified the logic of
|                                         GENERATE_BOM_ATTACH_TEXT to get bom from BCOL
|                                         above changes have been made as part of patchset-H
|                                         to be in sync with decisions made for cto-isp page
|
|              Modified on 12-APR-2002 By Sushant Sawant
|                                         Fixed BUG2310356
|                                         Drop Ship should respect buy sourcing rules.
|
|              Modified on 04-JUN-2002 BY Kiran Konada--bug fix 2327972
|                                         added a new procedure chk_all_rsv_details
|                                         This returns reservation details all types of
|                                         reservation for a given line_id in a table of records
|
|              Modified on 16-SEP-2002 By Sushant Sawant
|                                         Added New Function isModelMLMO copied from G branch
|                                         This function checks whether a model
|                                         is ML/MO.
|
|              Modified on 14-FEB-2003 By Kundan Sarkar
|                                         Bugfix 2804321 : Propagating customer bugfix 2774570
|                                         to main.
|
|              Modified on 14-MAR-2003 By Sushant Sawant
|                                         Decimal-Qty Support for Option Items.
|
|
|              Modified on 22-Aug-2003 By Kiran Konada
|                                         for enabling multiple soucres from DMF-J
|					  removed the error_code =66 in query sourcing org
|					  P_source_type will be 66 for multiple sources
|
|
|              Modified on 26-Mar-2004 By Sushant Sawant
|                                         Fixed Bug#3484511
|                                         all queries referencing oe_system_parameters_all
|                                         should be replaced with a function call to oe_sys_parameters.value
|
|
|             modified on 17-May-2004     Kiran Konada
|
|                                               inserted ship_from_org-id from BCOL into the
|                                               validation_org col on BCOL_GT
|                                               code has been changed in CTO_REUSE for
|                                               3555026 to look at validation_org, and so
|                                               validation-org cannot be null
|
|             on 07/09/2004 Kiran Konada
|                             --bugfix#3756670, added delte before insert in bcol_gt
|
|
|              Modified on 21-APR-2005 By Sushant Sawant
|                                         Fixed Bug#4044709
|                                         added validate_oe_data procedure to validate bcol/bcol_gt
|                                         data against OEL.
|
|
|			16-Jun-2005	Kiran Konada
|					changes for OPM and Ireq
|					chaneg comment : OPM
|					check_cto_can_create_supply_api
|					--two new parameters l_sourcing_org and l_message
|					--new logic to set x_can_create_supply for processorg
|					and make combination.
|					Hard dependency:
|					INV_GMI_RSV_BRANCH.Process_Branch
|
|
|
+-----------------------------------------------------------------------------*/

 G_PKG_NAME CONSTANT VARCHAR2(30) := 'CTO_UTILITY_PK';
 --Bugfix 9148706: Indexing by LONG
 --TYPE TAB_BCOL is TABLE of bom_cto_order_lines%rowtype index by binary_integer   ;
 TYPE TAB_BCOL is TABLE of bom_cto_order_lines%rowtype index by LONG;
 gMrpAssignmentSet        number ;


  --
  -- Forward Declarations
  --
  PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);

  G_ERROR_SEQ Number := 1 ; /* This number will increment for each session and will help to provide unique item key for notification for model lines resulting in multiple error messages */

PROCEDURE populate_plan_level ( p_t_bcol  in out NOCOPY TAB_BCOL ) ;
  PROCEDURE populate_parent_ato (
				p_t_bcol  	in out 	NOCOPY TAB_BCOL ,
  				p_bcol_line_id  in  	bom_cto_order_lines.line_id%type ) ;
  PROCEDURE initialize_assignment_set( x_return_status out NOCOPY varchar2)  ;





/*--------------------------------------------------------------------------+
   This function identifies the model items for which configuration items need
   to be created and populates the temporary table bom_cto_src_orgs with all the
   organizations that each configuration item needs to be created in.
+-------------------------------------------------------------------------*/

FUNCTION Populate_Src_Orgs(pTopAtoLineId in number,
				x_return_status	out	NOCOPY varchar2,
				x_msg_count	out	NOCOPY number,
				x_msg_data	out	NOCOPY varchar2)
RETURN integer
IS

   lStmtNumber 	number;
   lLineId		number;
   lShipFromOrgId	number;
   lStatus		number;

   cursor c_model_lines is
      select line_id,
             ato_line_id,
             inventory_item_id,
             plan_level
      from bom_cto_order_lines
      where ato_line_id = pTopAtoLineId
      and bom_item_type = 1
      and nvl(wip_supply_type,0) <> 6
      order by plan_level;

   cursor c_parent_src_orgs is
      select distinct bcso.organization_id
      from bom_cto_src_orgs bcso,
           bom_cto_order_lines bcol
      where bcol.line_id = lLineId
      and bcol.parent_ato_line_id = bcso.line_id
      and bcso.create_bom = 'Y';

   cursor c_debug is
      select line_id,
             model_item_id,
             rcv_org_id,
             organization_id,
             create_bom,
             create_src_rules
      from bom_cto_src_orgs
      where top_model_line_id = pTopAtoLineId;

BEGIN

   	IF PG_DEBUG <> 0 THEN
   		oe_debug_pub.add('populate_plan_level: ' || 'Populate_Src_Orgs::pTopAtoLineId::'||to_char(pTopAtoLineId),1);
   	END IF;

	--
	-- For each model item in all possible receiving orgs, call
	-- get_all_item_orgs to populate bom_cto_src_orgs
	--

	lStmtNumber := 20;
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('populate_plan_level: ' || 'before loop',2);
	END IF;


	FOR v_model_lines IN c_model_lines LOOP


		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'loop::item::'||to_char(v_model_lines.inventory_item_id)||
				'::line_id::'||to_char(v_model_lines.line_id),2);
		END IF;
		lStmtNumber := 30;

		IF v_model_lines.ato_line_id = v_model_lines.line_id THEN
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('populate_plan_level: ' || 'ato_line_id = line_id',2);
			END IF;


			lStmtNumber := 40;
			select ship_from_org_id
			into lShipFromOrgId
			from bom_cto_order_lines
			where line_id = v_model_lines.line_id;

			lStmtNumber := 50;
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('populate_plan_level: ' || 'before calling GAIO',2);

				oe_debug_pub.add('populate_plan_level: ' || 'line_id::'||to_char(v_model_lines.line_id)||
					'::inv_id::'||to_char(v_model_lines.inventory_item_id)||
					'::ship_from_org::'||to_char(lShipFromOrgId),2);
			END IF;


			lStatus := get_all_item_orgs(v_model_lines.line_id,
					v_model_lines.inventory_item_id,
					lShipFromOrgId,
					x_return_status,
					x_msg_count,
					x_msg_data);

			IF (lStatus <> 1) AND (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add('populate_plan_level: ' || 'GAIO returned with unexp error',1);
				END IF;
				raise FND_API.G_EXC_UNEXPECTED_ERROR;

			ELSIF (lStatus <> 1) AND (x_return_status = FND_API.G_RET_STS_ERROR) THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add('populate_plan_level: ' || 'GAIO returned with exp error',1);
				END IF;
				raise FND_API.G_EXC_ERROR;
			END IF;
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('populate_plan_level: ' || 'after calling GAIO::lStatus::'||to_char(lStatus),2);
			END IF;
		ELSE
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('populate_plan_level: ' || 'ato_line_id <> line_id',2);
			END IF;
			lStmtNumber := 60;
			lLineId := v_model_lines.line_id;
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('populate_plan_level: ' || 'before PSO loop',2);
			END IF;

			FOR v_parent_src_ogs IN c_parent_src_orgs LOOP
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add('populate_plan_level: ' || 'in PSO loop::rcv org::'||
						to_char(v_parent_src_ogs.organization_id),2);

					oe_debug_pub.add('populate_plan_level: ' || 'in PSO loop::item id::'||
						to_char(v_model_lines.inventory_item_id),2);

					oe_debug_pub.add('populate_plan_level: ' || 'in PSO loop::line id::'||
						to_char(v_model_lines.line_id),2);
				END IF;
				lStmtNumber := 70;
				lStatus := get_all_item_orgs(v_model_lines.line_id,
					v_model_lines.inventory_item_id,
					v_parent_src_ogs.organization_id,
					x_return_status,
					x_msg_count,
					x_msg_data);

				IF (lStatus <> 1) AND (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					IF PG_DEBUG <> 0 THEN
						oe_debug_pub.add('populate_plan_level: ' || 'GAIO returned with unexp error',1);
					END IF;
					raise FND_API.G_EXC_UNEXPECTED_ERROR;

				ELSIF (lStatus <> 1) AND (x_return_status = FND_API.G_RET_STS_ERROR) THEN
					IF PG_DEBUG <> 0 THEN
						oe_debug_pub.add('populate_plan_level: ' || 'GAIO returned with exp error',1);
					END IF;
					raise FND_API.G_EXC_ERROR;
				END IF;

			END LOOP;
		END IF;

	END LOOP;

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('populate_plan_level: ' || 'end of loop',1);

		oe_debug_pub.add('populate_plan_level: ' || 'printing out bcso :', 2);

		oe_debug_pub.add('populate_plan_level: ' || 'line_id  model_item_id  rcv_org_id  org_id  create_bom create_src_rules', 2);
	END IF;

	FOR v_debug IN c_debug LOOP
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || to_char(v_debug.line_id)||'  '||
					to_char(v_debug.model_item_id)||'  '||
					nvl(to_char(v_debug.rcv_org_id),null)||'  '||
					to_char(v_debug.organization_id)||'  '||
					nvl(v_debug.create_bom, null)||'  '||
					nvl(v_debug.create_src_rules, null), 2);
		END IF;
	END LOOP;

	return(1);

EXCEPTION

	when FND_API.G_EXC_UNEXPECTED_ERROR then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'Populate_Src_Orgs::unexp error::'||lStmtNumber||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);
		return(0);

	when FND_API.G_EXC_ERROR then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'Populate_Src_Orgs::exp error::'||lStmtNumber||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;
		CTO_MSG_PUB.Count_And_Get
			(p_msg_count => x_msg_count
			,p_msg_data  => x_msg_data);
		return(0);

	when others then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'Populate_Src_Orgs::others::'||lStmtNumber||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            		FND_MSG_PUB.Add_Exc_Msg
            			(G_PKG_NAME
            			,'populate_src_orgs'
            			);
        	END IF;
		CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);
		return(0);

END Populate_Src_Orgs;




/*--------------------------------------------------------------------------+
   This function populates the table bom_cto_src_orgs with all the organizations
   in which a configuration item needs to be created.
   The organizations include all potential sourcing orgs, receiving orgs,
   OE validation org and PO validation org.
   The line_id, rcv_org_id, organization_id combination is unique.
   It is called by Populate_Src_Orgs.
+-------------------------------------------------------------------------*/


/*--------------------------------------------------------------------------+
 --- Modified by Renga Kannan on 08/21/01 for procuring configuration Phase I
 --- This function is modified to support Buy sourcing and source type

    The following is the main logic for Procuring Configuration

       1. The sourcing rule should not ignore the BUY sourcing rules.
       2. You can have more than one buy sourcing rule. But you cannot have any combinations
       3. For the Buy model and its children in bcol the Buy_item_type_flag is populated with Y.
	  Otherwise it will be 'N'
       4. For Top Buy model in bcso the source_type is populated with 3.
          All of its child it is populated with 4.
       5. For the given parent_ato_model there will be only one row in the combination
	  of create_bom = 'y' and source_type = 3.
          That will be the top buy model in that level.
       6. For Buy model and its lower level components the copy_src_rule will
	  allways set to be 'Y' in bcol.

+-------------------------------------------------------------------------*/


FUNCTION Get_All_Item_Orgs( pLineId            in  number,
		            pModelItemId       in  number,
			    pRcvOrgId          in  number,
			    x_return_status    out NOCOPY varchar2,
			    x_msg_count	       out NOCOPY number,
			    x_msg_data	       out NOCOPY varchar2)
RETURN integer
IS

   gUserId		number;
   gLoginId		number;
   lStmtNumber		number;
   lMrpAssignmentSet	number;
   lTopAtoLineId	number;
   lExists		varchar2(10);
   lProfileVal		number;
   lValidationOrg	number;
   lPoVAlidationOrg	number;
   l_curr_RcvOrgId	number;
   l_curr_src_org	number;
   l_curr_assg_type	number;
   l_curr_rank		number;
   l_circular_src	varchar2(1);

   -- Added by Renga Kannan to get the source_type value

   l_source_type           number;
   l_sourcing_rule_count   number;
   l_parent_ato_line_id    Number;
   l_make_buy_code         number;

   -- End of addition on 08/26/01 for procuring configuration

   multiorg_error	exception;
   po_multiorg_error	exception;
   lProgramId           bom_cto_order_lines.program_id%type ;

   v_source_type_code   oe_order_lines_all.source_type_code%type ;

   CURSOR c_circular_src IS
      select 'Y'
      from bom_cto_src_orgs bcso
      where line_id = pLineId
      and model_item_id = pModelItemId
      and rcv_org_id = l_curr_src_org;


BEGIN


	--
	-- pLineId is the line_id of the model line
	--

	lStmtNumber := 10;
	gUserId := nvl(fnd_global.user_id, -1);
	gLoginId := nvl(fnd_global.login_id, -1);

	/* get top model's ato_line_id */
	--
	-- The column top_model_line_id in bom_cto_src_orgs is being used
	-- to store the ato_line_id of the top ATO model
	-- This change was required in order to support multiple ATO models
	-- under a PTO model
	--

        -- Added by Renga Kannan on 08/26/01
        -- Get the buy_item_flag from bcol for the given line id.
        -- If the buy_item_flag = 'Y' that means this part of some buy model
        -- In that case we should not look for sourcing rules for this model
        -- We need to create the item in its parents org.

	lStmtNumber := 20;

/*
        select ato_line_id,
               program_id
        into lTopAtoLineId,
             lProgramId
        from bom_cto_order_lines
        where line_id = pLineId;
*/


        /* BUG#1957336 Changes introduced by sushant for preconfigure bom */

	select ato_line_id,parent_ato_line_id, nvl(program_id,0) /* added by sushant for preconfigure bom identification */
	into lTopAtoLineId,l_parent_ato_line_id, lProgramId
	from bom_cto_order_lines
	where line_id = pLineId;

        -- Get the source type of its  parent Model line
        -- If the parent model is of buy type we should not look for
        -- sourcing this model

        lStmtNumber := 25;

        BEGIN
           Select organization_type
           Into   l_source_type
           from   bom_cto_src_orgs bcso
           where  bcso.line_id = l_parent_ato_line_id
           and    bcso.create_bom         = 'Y';
        EXCEPTION WHEN NO_DATA_FOUND THEN
           Null;
        END;

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('populate_plan_level: ' || 'top ato line id::'||to_char(lTopAtoLineId),2);

		oe_debug_pub.add('populate_plan_level: ' || 'rcv org id::'||to_char(pRcvOrgId),2);

		oe_debug_pub.add('populate_plan_level: ' || 'model item id::'||to_char(pModelItemId),2);
	END IF;

        -- Added by Renga Kannan on 08/23/01 for procuring configuration

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_plan_level: ' || 'Parent ATO line id = '||l_parent_ato_line_id,1);

        	oe_debug_pub.add('populate_plan_level: ' || 'Parent source type = '||l_source_type,1);
        END IF;




        lStmtNumber := 28 ;

        if( lProgramId = CTO_UTILITY_PK.PC_BOM_PROGRAM_ID ) then

            v_source_type_code := 'INTERNAL' ;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_plan_level: ' || ' pc bom source type code = '|| v_source_type_code ,1);
        END IF;
        else

            select source_type_code
              into v_source_type_code
              from oe_order_lines_all
              where line_id = pLineId ;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_plan_level: ' || ' non pc bom source type code = '|| v_source_type_code ,1);
        END IF;

        end if ;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_plan_level: ' || 'source type code = '|| v_source_type_code ,1);
        END IF;


	lStmtNumber := 30;
	/* get MRP's default assignment set */
	lMrpAssignmentSet := to_number(FND_PROFILE.VALUE('MRP_DEFAULT_ASSIGNMENT_SET'));

        --- The following if condition is added by Renga Kannan
        --- If the line is part of buy model then we need not look at the sourcing info
        --- we can keep the parents rcv org as the org for this item also. This can be identified
        --- from the bom_cto_order_lines_table flag


        lStmtNumber := 32;

        IF nvl(l_source_type,'2') in (3,4)  THEN
           -- Since this is part of existing buy model
           -- Set the source_type to 4 which is the indication for child buy model
           -- Since we are not looking at the sourcing here we need to set this flag as Y so that the sourcing rule
           -- will be copied
           lStmtNumber := 35;
           l_source_type    := 4;
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('populate_plan_level: ' || ' This is part of Buy model... No need to look for sourcing...',1);
           END IF;





        /* BUG# 2234858
        ** BUG# 2310356
        ** Sushant Added this for Drop Shipment Project
        */

        ELSIF nvl(l_source_type,'2') in (5,6)  THEN



           l_source_type := 6 ;
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('populate_plan_level: ' || ' This is part of Drop Ship model...',1);
           END IF;




        ELSE

	IF lMrpAssignmentSet is null THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'Default assignment set is null',1);
		END IF;


                 -- added by Renga Kannan on 08/21/01
                 -- When there is no sourcing rule defined we need to check for the make_buy_type of the
                 -- item to determine the buy model

                 lStmtNumber := 38;

                 -- The following select statement is modified by Renga Kannan
                 -- On 12/21/01. The where condition organization_id is modified


            if( v_source_type_code = 'INTERNAL' ) then
                 select planning_make_buy_code
                 into   l_make_buy_code
                 from   MTL_SYSTEM_ITEMS
                 where  inventory_item_id = pModelItemId
                 and    organization_id   = pRcvOrgId;


                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('populate_plan_level: ' || 'Make buy code:: 1 means make 2 means buy',1);

                	oe_debug_pub.add('populate_plan_level: ' || 'Planning make buy code for this item is ='||to_char(l_make_buy_code),1);
                END IF;

                 IF l_make_buy_code = 2 then
                   l_source_type := 3; ----- Buy Type
                 END IF;


            else


                   l_source_type := 5; ----- Drop Ship Type -- BUG#2310356


            end if ;


	ELSE
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'Default assignment set is '||to_char(lMrpAssignmentSet),2);
		END IF;


		--
		-- For the given model_item_id, receiving org and default
		-- assignment set, traverse the chain of sourcing rules and
		-- populate bom_cto_src_orgs with each source, till the final
		-- source is reached.
		-- Set the create_bom flag in the final source only
		-- Error out if multiple or circular src rules are found
		--

		lStmtNumber := 40;

		l_curr_RcvOrgId := pRcvOrgId;

		LOOP 	--for chain sourcing

		-- The following sql statement is modified by Renga Kannan on 04/30/2001.
                -- If the sourcing rule is assingned in the oganization paramerter the source_type
                -- will be null. But we need to consider that sourcing rule also. So the where condition
                -- is changed to have nvl function in the query.

		BEGIN

		lStmtNumber := 50;
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'Getting source for rcv org::'||to_char(l_curr_RcvOrgId), 2);
		END IF;

                -- Modified by Renga Kannan on 08/21/01 to honor the BUY sourcing and make_buy_code also
                -- The where condition in the select statement for source_type is removed. The source_type
                -- is selected to local variable for further evaluation


		select
			nvl(msv.source_organization_id,l_curr_RcvOrgId),
			msv.assignment_type,
			msv.rank,
                        nvl(msv.source_type,1)
		into
			l_curr_src_org,
			l_curr_assg_type,
			l_curr_rank,
                        l_source_type
		from mrp_sources_v msv
		where msv.assignment_set_id = lMrpAssignmentSet
		and msv.inventory_item_id = pModelItemId
		and msv.organization_id = l_curr_RcvOrgId
		--and nvl(msv.source_type,1) <> 3                 -- Commented by Renga Kannan on 08/21/01
		and nvl(effective_date,sysdate) <= nvl(disable_date, sysdate)
		and nvl(disable_date, sysdate+1) > sysdate;




                /* Special Processing needs to be incorporated for Drop Ship
                   If a single make or buy rule exists in the case of drop shipped orders
                   you should be ignoring it and still be consistent with buy functionality
                */
                /* BUG#2310356 Always default source type to 5 in case of dropship */
                if( v_source_type_code = 'EXTERNAL' ) then
                    if(  l_source_type =  3  ) then
                      l_source_type    := 5; --- Drop Ship sourcing Type
                      l_curr_src_org   := l_curr_RcvOrgId;
                      l_curr_rank      := null;
                    else
                       raise NO_DATA_FOUND ;
                    end if ;

                end if ;

		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'Source for this rcv org::'||to_char(l_curr_src_org),2);

                	oe_debug_pub.add('populate_plan_level: ' || 'Source type = '||to_char(l_source_type),2);
                END IF;

		EXCEPTION

		WHEN TOO_MANY_ROWS THEN

                        -- Modified by Renga Kannan on 08/21/01
                        -- We can define more than one buy sourcing rule. But all the sourcing should
                        -- be of 'BUY' type. If not then it is treated as multiple sourcing error.
                        -- This can be verified by the following query. count the no of sourcing rules other than
                        -- Buy sourcing. If it is more than zero that means multiple sourcing found.


                       lStmtNumber := 52;

                       select count(*)
                       into l_sourcing_rule_count
                       from mrp_sources_v msv
                       where msv.assignment_set_id = lMrpAssignmentSet
                       and msv.inventory_item_id = pModelItemId
                       and msv.organization_id = l_curr_RcvOrgId
                       and nvl(msv.source_type,1) <> 3
                       and nvl(effective_date,sysdate) <= nvl(disable_date, sysdate)
                       /* Nvl fun is added by Renga Kannan on 05/05/2001 */
                       and nvl(disable_date, sysdate+1) > sysdate;

                       IF l_sourcing_rule_count > 0 then

			-- multiple sources defined
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('populate_plan_level: ' || 'Multiple sources defined for model '||to_char(pModelItemId)
                                                                              ||', org '||to_char(l_curr_RcvOrgId), 1);
			END IF;


                        -- The following message handling is modified by Renga Kannan
                        -- We need to give the add for once to FND function and other
                        -- to OE, in both cases we need to set the message again
                        -- This is because if we not set the token once again the
                        -- second add will not get the message.

                        cto_msg_pub.cto_message('BOM','CTO_INVALID_SOURCING');
			raise FND_API.G_EXC_ERROR;
                      ELSE

                        IF PG_DEBUG <> 0 THEN
                        	oe_debug_pub.add('populate_plan_level: ' || 'This model is having buy sourcing rule...',1);
                        END IF;


                        if( v_source_type_code = 'INTERNAL' ) then
                            l_source_type    := 3; --- Buy sourcing Type
                            l_curr_src_org   := l_curr_RcvOrgId;
                            l_curr_rank      := null;

                        else
                            l_source_type    := 5; --- Drop Ship sourcing Type
                            l_curr_src_org   := l_curr_RcvOrgId;
                            l_curr_rank      := null;


                        end if ;


                        -- The assignment set is defaulted to 6 cuz, this will force the
                        -- Create_src_rules flag to 'Y' in bcso
                        -- the create sourcing rule will create the sourcing for buy
                        -- Sourcing rules.

                        l_curr_assg_type := 6;

                      END IF;


		WHEN NO_DATA_FOUND THEN



                     if( v_source_type_code = 'INTERNAL' ) then



			-- end of chain, exit out of loop
			-- update final src for BOM creation
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('populate_plan_level: ' || 'NDF::End of chain for model '||to_char(pModelItemId), 1);
			END IF;

                        -- added by Renga Kannan on 08/21/01
                        -- When there is no sourcing rule defined we need to check for the make_buy_type of the
                        -- item to determine the buy model

                        lStmtNumber := 57;

                       -- The following block of sql is modified by Renga Kannan on 11/08/01
                       -- I've added an NO DATA FOUDN excpetion to this sql
                       -- When the item is not defined in the sourcing org it needs to be
                       -- treated as INVALID sourcing
                       -- I've also modified the CTO_INVALID_SOURCING message to have this as one of the
                       -- Causes.

                        BEGIN

                           SELECT planning_make_buy_code
                           INTO   l_make_buy_code
                           FROM   MTL_SYSTEM_ITEMS
                           WHERE  inventory_item_id = pModelItemId
                           AND    organization_id   = l_curr_RcvOrgId;

                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN

                           IF PG_DEBUG <> 0 THEN
                           	oe_debug_pub.add('populate_plan_level: ' || 'Inventory_item_id  = '|| to_char(pModelItemId),1);

                           	oe_debug_pub.add('populate_plan_level: ' || 'Organization id    = '|| to_char(l_curr_RcvOrgId),1);

                           	oe_debug_pub.add('populate_plan_level: ' || 'ERROR::The item is not defined in the sourcing org',1);
                           END IF;


                           -- The following message handling is modified by Renga Kannan
                           -- We need to give the add for once to FND function and other
                           -- to OE, in both cases we need to set the message again
                           -- This is because if we not set the token once again the
                           -- second add will not get the message.

                           cto_msg_pub.cto_message('BOM','CTO_INVALID_SOURCING');
                           raise FND_API.G_EXC_ERROR;

                        END;

                        -- End of addition by Renga on 11/07/01

                        IF PG_DEBUG <> 0 THEN
                        	oe_debug_pub.add('populate_plan_level: ' || 'Planning Make_buy_code for this model = '||l_make_buy_code,1);
                        END IF;

                        IF l_make_buy_code = 2 then
                          l_source_type := 3; ----- Buy Type
                          IF PG_DEBUG <> 0 THEN
                          	oe_debug_pub.add('populate_plan_level: ' || 'This model is a buy model...',1);
                          END IF;
                        END IF;


                      else


                          l_source_type := 5; ----- Drop Ship  Type
                          l_curr_src_org   := l_curr_RcvOrgId;
                          l_curr_rank      := null;
                          IF PG_DEBUG <> 0 THEN
                          	oe_debug_pub.add('populate_plan_level: ' || 'This model is a buy model...',1);
                          END IF;

                      end if ;

                          /* This statement needs to be there to account for all passess except first pass */

			  lStmtNumber := 60;
			  update bom_cto_src_orgs
			  set create_bom = 'Y',organization_type = l_source_type
			  where line_id = pLineId
			  and model_item_id = pModelItemId
			  and organization_id = l_curr_src_org;

			  IF PG_DEBUG <> 0 THEN
			  	oe_debug_pub.add('populate_plan_level: ' || 'Rows updated::'||sql%rowcount,2);
			  END IF;
			  EXIT;



		END;

		lStmtNumber := 90;
		OPEN c_circular_src;
		FETCH c_circular_src into l_circular_src;
		CLOSE c_circular_src;

		lStmtNumber := 100;
		IF l_circular_src = 'Y' THEN
			-- circular sourcing defined
			lStmtNumber := 110;
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('populate_plan_level: ' || 'Circular sourcing defined for model '
                                         ||to_char(pModelItemId)
                                         ||' in org '
                                         ||to_char(pRcvOrgId), 1);
			END IF;

                        cto_msg_pub.cto_message('BOM','CTO_INVALID_SOURCING');
			raise FND_API.G_EXC_ERROR;
		END IF;

		lStmtNumber := 120;
		insert into bom_cto_src_orgs
				(
				top_model_line_id,
				line_id,
				model_item_id,
				rcv_org_id,
				organization_id,
				create_bom,
				cost_rollup,
				organization_type, -- Used to store the source type
				config_item_id,
				create_src_rules,
				rank,
				creation_date,
				created_by,
				last_update_date,
				last_updated_by,
				last_update_login,
				program_application_id,
				program_id,
				program_update_date
				)
		select -- distinct
				lTopAtoLineId,
				pLineId,
				pModelItemId,
				l_curr_RcvOrgId,
				l_curr_src_org,
				'N',		-- create_bom
				'Y',		-- cost_rollup
				l_source_type,	-- org_type is used to store the source type
				NULL,		-- config_item_id
				decode(l_curr_assg_type, 6, 'Y', 3, 'Y', 'N'),
				l_curr_rank,
				sysdate,	-- creation_date
				gUserId,	-- created_by
				sysdate,	-- last_update_date
				gUserId,	-- last_updated_by
				gLoginId,	-- last_update_login
				null, 		-- program_application_id,??
				null, 		-- program_id,??
				sysdate		-- program_update_date
		from dual;

                /*
                This statement has to be there to exit after the first pass
                for buy and dropship to avoid pursuing make/transfer, make/transfer chains
                */

		lStmtNumber := 130;
		IF (l_curr_src_org = l_curr_RcvOrgId) THEN
			-- end of chain, exit out of loop
			-- update final src for BOM creation
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('populate_plan_level: ' || 'End of chain for model '||to_char(pModelItemId), 1);
			END IF;


                        --- The source type column is added by Renga Kannan on 08/21/01

			lStmtNumber := 140;
			update bom_cto_src_orgs
			set create_bom = 'Y', organization_type = l_source_type
			where line_id = pLineId
			and model_item_id = pModelItemId
			and organization_id = l_curr_src_org
			and rcv_org_id = l_curr_RcvOrgId;

			EXIT;
		END IF;

		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'inserted rcv org::'||to_char(l_curr_RcvOrgId)||' src org::'||to_char(l_curr_src_org), 2);
		END IF;
		l_curr_RcvOrgId := l_curr_src_org;

		END LOOP;
		--<<chain_loop>>
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'after insert 1',2);
		END IF;
	END IF; /* MRP profile is not null */

        END IF; /* check for DROP SHIP , BUY_ITEM_FLAG is not Y */

	--
	-- If mrp_sources_v does not insert any rows into
	-- bom_cto_src_orgs, this means that no sourcing rules are set-up
	-- for this model item in this org. Assuming that in this case
	-- the item in this org is sourced from itself, inserting a row
	-- with the receiving org as the sourcing org

	lStmtNumber := 150;
	insert into bom_cto_src_orgs
		(
		top_model_line_id,
		line_id,
		model_item_id,
		rcv_org_id,
		organization_id,
		create_bom,
		cost_rollup,
		organization_type,
		config_item_id,
		create_src_rules,
		rank,
		creation_date,
		created_by,
		last_update_date,
		last_updated_by,
		last_update_login,
		program_application_id,
		program_id,
		program_update_date
		)
	select
		lTopAtoLineId,
		pLineId,
		pModelItemId,
		pRcvOrgId,
		pRcvOrgId,
		'Y',		-- create_bom
		decode( l_source_type , 4 , 'N' , 6 , 'N' , 'Y' ) , -- cost_rollup
		l_source_type,	-- org_type is used to store the source_type
		NULL,		-- config_item_id
		decode(l_curr_assg_type,6,'Y',3,'Y','N'), -- create_src_rules
		NULL,		-- rank, n/a
		sysdate,	-- creation_date
		gUserId,	-- created_by
		sysdate,	-- last_update_date
		gUserId,	-- last_updated_by
		gLoginId,	-- last_update_login
		null, 		-- program_application_id,??
		null, 		-- program_id,??
		sysdate		-- program_update_date
	from dual
	where NOT EXISTS
		(select NULL
		from bom_cto_src_orgs
		where line_id = pLineId
		and model_item_id = pModelItemId);

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('populate_plan_level: ' || 'after insert 2',2);
	END IF;

	--
	-- Next, populate bom_cto_src_orgs with the
	-- receiving org for the model item
	-- If the org already exists for this item,
	-- do nothing, else insert a new row

        -- Added by Renga Kannan to include one more column source_type to it.

	lStmtNumber := 160;

	insert into bom_cto_src_orgs
		(
		top_model_line_id,
		line_id,
		model_item_id,
		rcv_org_id,
		organization_id,
		create_bom,
		cost_rollup,
		organization_type, -- Used to store the Source type
		config_item_id,
		create_src_rules,
		rank,
		creation_date,
		created_by,
		last_update_date,
		last_updated_by,
		last_update_login,
		program_application_id,
		program_id,
		program_update_date
		)
	select
		lTopAtoLineId,
		pLineId,
		pModelItemId,
		NULL,		-- rec_org_id
		pRcvOrgId,
		'N',		-- create_bom
		'N',		-- cost_rollup
		l_source_type,	-- org_type is used to store the source type
		NULL,		-- config_item_id
		NULL,		-- create_src_rules, n/a
		NULL,		-- rank, n/a
		sysdate,	-- creation_date
		gUserId,	-- created_by
		sysdate,	-- last_update_date
		gUserId,	-- last_updated_by
		gLoginId,	-- last_update_login
		null, 		-- program_application_id,??
		null, 		-- program_id,??
		sysdate		-- program_update_date
	from dual
	where NOT EXISTS
		(select NULL
		from bom_cto_src_orgs
		where line_id = pLineId
		and model_item_id = pModelItemId
		and organization_id = pRcvOrgId);

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('populate_plan_level: ' || 'after insert 3',2);
	END IF;

	--
	-- Next, get the OE validation org and populate it in
	-- bom_cto_src_orgs
	-- If the org already exists for this item,
	-- do nothing, else insert a new row
	--
	lStmtNumber := 170;
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('populate_plan_level: ' ||  'Before getting validation org',2);
	END IF;

	lStmtNumber := 180;


        /* BUG#1957336 Changes introduced by sushant for preconfigure bom */
        /* Added by Sushant for preconfigure bom module */
        if( lProgramId = PC_BOM_PROGRAM_ID ) then
            lValidationOrg := PC_BOM_VALIDATION_ORG ;

        else

          /*
            Bug#3484511
            Code has been replaced due to 11.5.10 OM data model change
            ----------------------------------------------------------
            select nvl(master_organization_id,-99)	-- bugfix 2646849: master_organization_id can be 0
            into   lValidationOrg
            from   oe_order_lines_all oel,
                   oe_system_parameters_all ospa
            where  oel.line_id = pLineid
            and    nvl(oel.org_id, -1) = nvl(ospa.org_id, -1)  --bug 1531691
            and    oel.inventory_item_id = pModelItemId;

          */

  	   IF PG_DEBUG <> 0 THEN
  		oe_debug_pub.add('populate_plan_level: ' ||  'Going to fetch Validation Org ' ,2);
  	   END IF;


           select nvl( oe_sys_parameters.value( 'MASTER_ORGANIZATION_ID' , oel.org_id) , -99)
              into lValidationOrg from oe_order_lines_all oel
           where oel.line_id = pLineId ;



        end if ;


     	if lVAlidationOrg = -99 then			-- bugfix 2646849
                cto_msg_pub.cto_message('BOM','CTO_INVALID_SOURCING');
       		raise FND_API.G_EXC_ERROR;
    	end if;
  	IF PG_DEBUG <> 0 THEN
  		oe_debug_pub.add('populate_plan_level: ' ||  'Validation Org is :' ||  lValidationOrg,2);
  	END IF;

	lStmtNumber := 190;

	insert into bom_cto_src_orgs
		(
		top_model_line_id,
		line_id,
		model_item_id,
		rcv_org_id,
		organization_id,
		create_bom,
		cost_rollup,
		organization_type,
		config_item_id,
		create_src_rules,
		rank,
		creation_date,
		created_by,
		last_update_date,
		last_updated_by,
		last_update_login,
		program_application_id,
		program_id,
		program_update_date
		)
	select
		lTopAtoLineId,
		pLineId,
		pModelItemId,
		NULL,		-- rec_org_id
		lValidationOrg,
		'N',		-- create_bom
		'N',		-- cost_rollup
		NULL,		-- org_type, pending
		NULL,		-- config_item_id
		NULL,		-- create_src_rules, n/a
		NULL,		-- rank, n/a
		sysdate,	-- creation_date
		gUserId,	-- created_by
		sysdate,	-- last_update_date
		gUserId,	-- last_updated_by
		gLoginId,	-- last_update_login
		null, 		-- program_application_id,??
		null, 		-- program_id,??
		sysdate		-- program_update_date
	from dual
	where NOT EXISTS
		(select NULL
		from bom_cto_src_orgs
		where line_id = pLineId
		and model_item_id = pModelItemId
		and organization_id = lVAlidationOrg);

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('populate_plan_level: ' || 'after insert 4',2);
	END IF;

	--
	-- Next, get the PO validation org and populate it in
	-- bom_cto_src_orgs. If PO val org is -99, (bugfix 2646849: changed from 0 to -99) null or not setup,
	-- we will not populate a row for PO val org, and will not
	-- error out.
	-- If the org already exists for this item,
	-- do nothing, else insert a new row
	--
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('populate_plan_level: ' ||  'Before getting validation org',2);
	END IF;

	lStmtNumber := 200;
	BEGIN



        /* BUG#1957336 Changes introduced by sushant for preconfigure bom */
        /* Added by sushant for preconfigure bom */

        if( lProgramId = PC_BOM_PROGRAM_ID ) then
            lPoValidationOrg := PC_BOM_VALIDATION_ORG ;

        else

 	    -- Modifying the following sql statment.
            -- Right now the po validation org is derived from
            -- order_lines operating unit. This is wrong
            -- We should derive the Po_validation org for a model
            -- based on receiving organizations operating unit.
            -- I am changing the select to get the row from bcso with create_bom = 'Y'
            -- which will give me the last receiving organization.

	    -- We have made this decision after revisiting the Operating unit issue
            -- for Procured configurations.
   	    -- Modified by Renga Kannan  03/08/01

	    begin
            -- rkaza. 3742393. 08/12/2004.
            -- Replacing org_organization_definitions with
            -- inv_organziation_info_v

            select 	nvl(fsp.inventory_organization_id,-99)		--bugfix 2646849: 0 can be a valid orgn_id.
            into 	lPoValidationOrg
            from 	bom_cto_src_orgs bcso,
            		financials_system_params_all fsp,
			inv_organization_info_v org
            where 	bcso.line_id = pLineId
            and 	bcso.create_bom = 'Y'
	    and 	bcso.organization_id = org.organization_id
            and 	nvl(fsp.org_id, -1) = nvl(org.Operating_unit, -1);  --bug 1531691
            Exception when no_data_found then
	          lPoValidationOrg := -99; 				-- bugfix 2646849
            End;

        end if ;


        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_plan_level: ' || 'Po Validation Org ='||to_char(lpovalidationorg),1);
        END IF;



        /* Added By Renga Kannan on 10/23/01

           IF the po_validation org is not set then out program needs to error out
           as part of Procuring design. When I discussed this with USHA ARORA, We foudn
           that we need to check only if there is any procuring models. For make model
           case even if the po validation org is not setup we need not error out. That is the
           existing funtionality. Hence I am making a check for procuring model here.

        */

        IF l_source_type in (3,4, 5, 6 ) THEN

	   if lPoVAlidationOrg = -99 then		--bugfix 2646849
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('populate_plan_level: ' || 'No Povalidation org is defined .. Need to error out..',1);
                END IF;
               	cto_msg_pub.cto_message('BOM','CTO_PO_VALIDATION');
       		raise po_multiorg_error;
    	   end if;

        END IF;

        --- Added by Renga Kannan storing the po validation org in pkg variable for further use
        --- Added on 08/24/01

        CTO_UTILITY_PK.PO_VALIDATION_ORG := lPoValidationOrg;

        -- End of addition

  	IF PG_DEBUG <> 0 THEN
  		oe_debug_pub.add('populate_plan_level: ' ||  'PO Validation Org is :' ||lPoValidationOrg,2);
  	END IF;

	lStmtNumber := 210;

	insert into bom_cto_src_orgs
		(
		top_model_line_id,
		line_id,
		model_item_id,
		rcv_org_id,
		organization_id,
		create_bom,
		cost_rollup,
		organization_type,
		config_item_id,
		create_src_rules,
		rank,
		creation_date,
		created_by,
		last_update_date,
		last_updated_by,
		last_update_login,
		program_application_id,
		program_id,
		program_update_date
		)
	select
		lTopAtoLineId,
		pLineId,
		pModelItemId,
		NULL,		-- rec_org_id
		lPoValidationOrg,
		'N',		-- create_bom
		'N',		-- cost_rollup
		NULL,		-- org_type, pending
		NULL,		-- config_item_id
		NULL,		-- create_src_rules, n/a
		NULL,		-- rank, n/a
		sysdate,	-- creation_date
		gUserId,	-- created_by
		sysdate,	-- last_update_date
		gUserId,	-- last_updated_by
		gLoginId,	-- last_update_login
		null, 		-- program_application_id,??
		null, 		-- program_id,??
		sysdate		-- program_update_date
	from dual
	where NOT EXISTS
		(select NULL
		from bom_cto_src_orgs
		where line_id = pLineId
		and model_item_id = pModelItemId
		and organization_id = lPoVAlidationOrg);

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('populate_plan_level: ' || 'after insert 5',2);
	END IF;


        -- Added By Renga Kannan on 10/31/02 for Global Purchase agreement
        -- apart from enabling the config in all the sourcing chain orgs, we need
        -- to enable it in all the org where model item is active
        -- This is used for global purchase agreement

        insert into bom_cto_src_orgs
                (
                top_model_line_id,
                line_id,
                model_item_id,
                rcv_org_id,
                organization_id,
                create_bom,
                cost_rollup,
                organization_type,
                config_item_id,
                create_src_rules,
                rank,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login,
                program_application_id,
                program_id,
                program_update_date
                )
        select
                lTopAtoLineId,
                pLineId,
                pModelItemId,
                NULL,           -- rec_org_id
                mtl.organization_id,
                'N',            -- create_bom
                'N',            -- cost_rollup
                NULL,           -- org_type, pending
                NULL,           -- config_item_id
                NULL,           -- create_src_rules, n/a
                NULL,           -- rank, n/a
                sysdate,        -- creation_date
                gUserId,        -- created_by
                sysdate,        -- last_update_date
                gUserId,        -- last_updated_by
                gLoginId,       -- last_update_login
                null,           -- program_application_id,??
                null,           -- program_id,??
                sysdate         -- program_update_date
        from    mtl_system_items mtl
        where   inventory_item_id = pModelItemId
        and     INVENTORY_ITEM_STATUS_CODE = 'Active'
        and     organization_id not in
                (select organization_id
                 from   bom_cto_src_orgs
                 where  line_id = plineid
                 and    top_model_line_id = lTopAtoLineId);

	EXCEPTION
		WHEN no_data_found THEN
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('populate_plan_level: ' || 'PO validation org is NULL, not inserting row for PO val org',2);
			END IF;
			null;
		WHEN po_multiorg_error THEN
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('populate_plan_level: ' || 'po_multiorg_error, not inserting row for PO val org',2);
			END IF;
			Raise FND_API.G_EXC_ERROR;
		WHEN others THEN
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('populate_plan_level: ' || 'others exception in PO validation block, not inserting row for PO val org',2);
			END IF;
			null;
	END;
	return(1);

EXCEPTION
	when FND_API.G_EXC_ERROR then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'Get_All_item_orgs::exp error::'||to_char(lStmtNumber)||'::'||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;
		CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);
		return(0);

	when FND_API.G_EXC_UNEXPECTED_ERROR then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'Get_All_item_orgs::unexp error::'||to_char(lStmtNumber)||'::'||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		CTO_MSG_PUB.Count_And_Get (
			 p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);
		return(0);

	when OTHERS then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'Get_All_item_orgs::others::'||to_char(lStmtNumber)||'::'||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            		FND_MSG_PUB.Add_Exc_Msg
            			(G_PKG_NAME
            			,'Get_All_Item_Orgs'
            			);
        	END IF;
        	CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);
		return(0);

end Get_All_Item_Orgs;


/*--------------------------------------------------------------------------+
This function updates table bom_cto_order_lines with the config_item_id for
a given model item.
It is called by "Match" and "Create_Item" programs.
+-------------------------------------------------------------------------*/
FUNCTION Update_Order_Lines(pLineId	in 	number,
			pModelId	in	number,
			pConfigId	in	number)
RETURN integer
IS

lStmtNumber		number;


BEGIN

	--
	-- If line exists, update it with the config item id
	--
	lStmtNumber := 20;
	update  bom_cto_order_lines
	set     config_item_id = pConfigId
	where   line_id = pLineId
	and     inventory_item_id = pModelId;

	if sql%notfound then
	   IF PG_DEBUG <> 0 THEN
	   	oe_debug_pub.add('populate_plan_level: ' || 'Update_Order_Lines:: ndf::model line does not exist in bcol'||to_char(lStmtNumber)||sqlerrm,1);
	   END IF;
	   return(0);
	else
	   return(1);
	end if;

EXCEPTION
	when others then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'Update_Order_Lines:: others exception'||to_char(lStmtNumber)||sqlerrm,1);
		END IF;
		return(0);

END Update_Order_Lines;


/*--------------------------------------------------------------------------+
This function updates table bom_cto_src_orgs with the config_item_id for
a given model item.
It is called by "Match" and "Create_Item" programs.
+-------------------------------------------------------------------------*/
FUNCTION Update_Src_Orgs(pLineId	in 	number,
			pModelId	in	number,
			pConfigId	in	number)
RETURN integer
IS

BEGIN

	--
	-- Update all lines for the model item with the config item id
	--

	update bom_cto_src_orgs
	set    config_item_id = pConfigId
	where  line_id = pLineId
	and    model_item_id = pModelId;

        if sql%notfound then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'Update_Src_Orgs:: Could not update the config item: '||sqlerrm,1);
		END IF;
		return(0);
	else
		return(1);
	end if;


EXCEPTION

	when others then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'Update_Src_Orgs:: others exception'||sqlerrm,1);
		END IF;
		return(0);

END Update_Src_Orgs;


/*--------------------------------------------------------------------------+
This procedure creates sourcing information for a configuration item.
It copies the sourcing rule assignment of the model into the configuration
item and adds this assignment to the MRP default assignment set.
+-------------------------------------------------------------------------*/

--- Modified by Renga Kannan on 08/22/01
--- This change is done as part of procuring configuration change

PROCEDURE Create_Sourcing_Rules(pModelItemId	in	number,
				pConfigId	in	number,
				pRcvOrgId	in	number,
				x_return_status	out	NOCOPY varchar2,
				x_msg_count	out	NOCOPY number,
				x_msg_data	out	NOCOPY varchar2)
IS

lStmtNum		number;
lMrpAssignmentSet	number;
lAssignmentId		number;
lAssignmentType		number;
lConfigAssignmentId	number;
lAssignmentExists	number;
lAssignmentRec		MRP_Src_Assignment_PUB.Assignment_Rec_Type;
lAssignmentTbl		MRP_Src_Assignment_PUB.Assignment_Tbl_Type;
lAssignmentSetRec	MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type;
xAssignmentSetRec	MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type;
xAssignmentSetValRec	MRP_Src_Assignment_PUB.Assignment_Set_Val_Rec_Type;
xAssignmentTbl		MRP_Src_Assignment_PUB.Assignment_Tbl_Type;
xAssignmentValTbl	MRP_Src_Assignment_PUB.Assignment_Val_Tbl_Type;
l_return_status		varchar2(1);
l_msg_count		number;
l_msg_data		varchar2(2000);

No_sourcing_defined     Exception;

BEGIN

	x_return_status := FND_API.G_RET_STS_SUCCESS;
	lAssignmentExists := 0;

	lStmtNum := 10;
	/* get MRP's default assignment set */
	lMrpAssignmentSet := to_number(FND_PROFILE.VALUE('MRP_DEFAULT_ASSIGNMENT_SET'));

	IF lMrpAssignmentSet is null THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'Default assignment set is null, returning from create_sourcing_rules procedure',1);
		END IF;
		return;
	ELSE
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'Default assignment set is '||to_char(lMrpAssignmentSet),2);
		END IF;
	END IF;

	--
	-- from mrp view, get Assignment_id of assignment to be copied
	--

        -- The buy sourcing rules are also need to be selected.
        -- The where condition source_type <> 3 needs to be removed
        -- Changes are made by Renga Kannan on 08/22/01 for procuring config Change



        -- Modified by Renga Kannan on 13-NOV-2001
        -- Added condition for assignment type = 3,6
        -- Previously it was erroring out if the assignment type is not of 3, 6
        -- It should not error out, rather it should igonre this
        -- this is required becasue of multiple buy support


	lStmtNum := 20;


        -- When no data found it not an exception in this case
        -- It may not have any sourcing for assignment_type 3,6 so we need not error out for this

        BEGIN

	   select distinct assignment_id, assignment_type
	   into lAssignmentId, lAssignmentType
	   from mrp_sources_v msv
	   where msv.assignment_set_id = lMrpAssignmentSet
	   and msv.inventory_item_id = pModelItemId
	   and msv.organization_id = pRcvOrgId
	   and effective_date <= nvl(disable_date, sysdate)
	   and nvl(disable_date, sysdate+1) > sysdate
           and assignment_type in (3,6);

        EXCEPTION
	WHEN NO_DATA_FOUND THEN

           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('populate_plan_level: ' || 'There is no sourcing rule defined ',1);
           END IF;
           raise no_sourcing_defined;

        END;


	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('populate_plan_level: ' || 'lAssnType::'||to_char(lAssignmentType)||'::lAssnId::'||to_char(lAssignmentId),2);
	END IF;

	--
	-- copy assignment into lAssignmentRec
	--
	lStmtNum := 30;

        --
        -- bug 6617686
        -- The MRP API uses a  ASSIGNMENT_ID = p_Assignment_Id OR
        -- ASSIGNMENT_SET_ID = p_Assignment_Set_Id that leads to
        -- a full table scan on MRP_SR_ASSIGNMENTS and consequent
        -- performance issues. Since CTO does not pass ASSIGNMENT_SET_ID
        -- into the procedure, it is performance effective to directly
        -- query the MRP table
        -- ntungare
        --
        -- lAssignmentRec := MRP_Assignment_Handlers.Query_Row(lAssignmentId);

        SELECT  ASSIGNMENT_ID
             ,       ASSIGNMENT_SET_ID
             ,       ASSIGNMENT_TYPE
             ,       ATTRIBUTE1
             ,       ATTRIBUTE10
             ,       ATTRIBUTE11
             ,       ATTRIBUTE12
             ,       ATTRIBUTE13
             ,       ATTRIBUTE14
             ,       ATTRIBUTE15
             ,       ATTRIBUTE2
             ,       ATTRIBUTE3
             ,       ATTRIBUTE4
             ,       ATTRIBUTE5
             ,       ATTRIBUTE6
             ,       ATTRIBUTE7
             ,       ATTRIBUTE8
             ,       ATTRIBUTE9
             ,       ATTRIBUTE_CATEGORY
             ,       CATEGORY_ID
             ,       CATEGORY_SET_ID
             ,       CREATED_BY
             ,       CREATION_DATE
             ,       CUSTOMER_ID
             ,       INVENTORY_ITEM_ID
             ,       LAST_UPDATED_BY
             ,       LAST_UPDATE_DATE
             ,       LAST_UPDATE_LOGIN
             ,       ORGANIZATION_ID
             ,       PROGRAM_APPLICATION_ID
             ,       PROGRAM_ID
             ,       PROGRAM_UPDATE_DATE
             ,       REQUEST_ID
             ,       SECONDARY_INVENTORY
             ,       SHIP_TO_SITE_ID
             ,       SOURCING_RULE_ID
             ,       SOURCING_RULE_TYPE
             into    lAssignmentRec.ASSIGNMENT_ID
             ,       lAssignmentRec.ASSIGNMENT_SET_ID
             ,       lAssignmentRec.ASSIGNMENT_TYPE
             ,       lAssignmentRec.ATTRIBUTE1
             ,       lAssignmentRec.ATTRIBUTE10
             ,       lAssignmentRec.ATTRIBUTE11
             ,       lAssignmentRec.ATTRIBUTE12
             ,       lAssignmentRec.ATTRIBUTE13
             ,       lAssignmentRec.ATTRIBUTE14
             ,       lAssignmentRec.ATTRIBUTE15
             ,       lAssignmentRec.ATTRIBUTE2
             ,       lAssignmentRec.ATTRIBUTE3
             ,       lAssignmentRec.ATTRIBUTE4
             ,       lAssignmentRec.ATTRIBUTE5
             ,       lAssignmentRec.ATTRIBUTE6
             ,       lAssignmentRec.ATTRIBUTE7
             ,       lAssignmentRec.ATTRIBUTE8
             ,       lAssignmentRec.ATTRIBUTE9
             ,       lAssignmentRec.ATTRIBUTE_CATEGORY
             ,       lAssignmentRec.CATEGORY_ID
             ,       lAssignmentRec.CATEGORY_SET_ID
             ,       lAssignmentRec.CREATED_BY
             ,       lAssignmentRec.CREATION_DATE
             ,       lAssignmentRec.CUSTOMER_ID
             ,       lAssignmentRec.INVENTORY_ITEM_ID
             ,       lAssignmentRec.LAST_UPDATED_BY
             ,       lAssignmentRec.LAST_UPDATE_DATE
             ,       lAssignmentRec.LAST_UPDATE_LOGIN
             ,       lAssignmentRec.ORGANIZATION_ID
             ,       lAssignmentRec.PROGRAM_APPLICATION_ID
             ,       lAssignmentRec.PROGRAM_ID
             ,       lAssignmentRec.PROGRAM_UPDATE_DATE
             ,       lAssignmentRec.REQUEST_ID
             ,       lAssignmentRec.SECONDARY_INVENTORY
             ,       lAssignmentRec.SHIP_TO_SITE_ID
             ,       lAssignmentRec.SOURCING_RULE_ID
             ,       lAssignmentRec.SOURCING_RULE_TYPE
             FROM    MRP_SR_ASSIGNMENTS
             WHERE   ASSIGNMENT_ID = lAssignmentId;

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('populate_plan_level: ' || 'after query row',2);
	END IF;

	--
	-- check if this assignment already exists for config item
	--
	lStmtNum := 35;
	BEGIN

		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'assignment_set_id::'||to_char(lAssignmentRec.assignment_set_id),2);

			oe_debug_pub.add('populate_plan_level: ' || 'assignment_type::'||to_char(lAssignmentRec.assignment_type),2);

			oe_debug_pub.add('populate_plan_level: ' || 'organization_id::'||to_char(lAssignmentRec.organization_id),2);

			oe_debug_pub.add('populate_plan_level: ' || 'customer_id::'||to_char(lAssignmentRec.customer_id),2);

			oe_debug_pub.add('populate_plan_level: ' || 'ship_to_site_id::'||to_char(lAssignmentRec.ship_to_site_id),2);

			oe_debug_pub.add('populate_plan_level: ' || 'sourcing_rule_type::'||to_char(lAssignmentRec.sourcing_rule_type),2);

			oe_debug_pub.add('populate_plan_level: ' || 'inventory_item_id:: '||to_char(pConfigId),2);

			oe_debug_pub.add('populate_plan_level: ' || 'category_id:: '||to_char(lAssignmentRec.category_id),2);
		END IF;

                -- bug 6617686
                IF pConfigId IS NOT NULL THEN
                        select 1
                        into lAssignmentExists
                        from mrp_sr_assignments
                        where assignment_set_id = lAssignmentRec.assignment_set_id
                        and assignment_type = lAssignmentRec.assignment_type
                        and nvl(organization_id,-1) = nvl(lAssignmentRec.organization_id,-1)
                        and nvl(customer_id,-1) = nvl(lAssignmentRec.customer_id,-1)
                        and nvl(ship_to_site_id,-1) = nvl(lAssignmentRec.ship_to_site_id,-1)
                        and sourcing_rule_type = lAssignmentRec.sourcing_rule_type
                        and nvl(inventory_item_id,-1) = pConfigId
                        and nvl(category_id,-1) = nvl(lAssignmentRec.category_id,-1);
               ELSE
                         select 1
                         into lAssignmentExists
                         from mrp_sr_assignments
                         where assignment_set_id = lAssignmentRec.assignment_set_id
                         and assignment_type = lAssignmentRec.assignment_type
                         and nvl(organization_id,-1) = nvl(lAssignmentRec.organization_id,-1)
                         and nvl(customer_id,-1) = nvl(lAssignmentRec.customer_id,-1)
                         and nvl(ship_to_site_id,-1) = nvl(lAssignmentRec.ship_to_site_id,-1)
                         and sourcing_rule_type = lAssignmentRec.sourcing_rule_type
                         and inventory_item_id is null
                         and nvl(category_id,-1) = nvl(lAssignmentRec.category_id,-1);
                END IF;
                 -- end: bug 6617686

		IF lAssignmentExists = 1 THEN
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('populate_plan_level: ' || 'assignment exists already, do not recreate',2);
			END IF;
			return;
		END IF;

	EXCEPTION
		when NO_DATA_FOUND then
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('populate_plan_level: ' || 'assignment does not exist, create it',2);
			END IF;
		when OTHERS then
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('populate_plan_level: ' || 'others exception while checking ifassignment exists, not handling, creating assignment:: '||sqlerrm,2);
			END IF;
	END;

	--
	-- get assignment id for config item
	--
	SELECT mrp_sr_assignments_s.nextval
    	INTO   lConfigAssignmentId
    	FROM   DUAL;

	--
	-- form lAssignmentTbl from lAssignmentRec
	--
	lStmtNum := 40;
	lAssignmentTbl(1).Assignment_Id 	:= lConfigAssignmentId;
	lAssignmentTbl(1).Assignment_Set_Id	:= lAssignmentRec.Assignment_Set_Id;
	lAssignmentTbl(1).Assignment_Type	:= lAssignmentRec.Assignment_Type;
	lAssignmentTbl(1).Attribute1		:= lAssignmentRec.Attribute1;
	lAssignmentTbl(1).Attribute10 		:= lAssignmentRec.Attribute10;
	lAssignmentTbl(1).Attribute11		:= lAssignmentRec.Attribute11;
	lAssignmentTbl(1).Attribute12		:= lAssignmentRec.Attribute12;
	lAssignmentTbl(1).Attribute13		:= lAssignmentRec.Attribute13;
	lAssignmentTbl(1).Attribute14		:= lAssignmentRec.Attribute14;
	lAssignmentTbl(1).Attribute15		:= lAssignmentRec.Attribute15;
	lAssignmentTbl(1).Attribute2		:= lAssignmentRec.Attribute2;
	lAssignmentTbl(1).Attribute3		:= lAssignmentRec.Attribute3;
	lAssignmentTbl(1).Attribute4		:= lAssignmentRec.Attribute4;
	lAssignmentTbl(1).Attribute5		:= lAssignmentRec.Attribute5;
	lAssignmentTbl(1).Attribute6		:= lAssignmentRec.Attribute6;
	lAssignmentTbl(1).Attribute7		:= lAssignmentRec.Attribute7;
	lAssignmentTbl(1).Attribute8		:= lAssignmentRec.Attribute8;
	lAssignmentTbl(1).Attribute9		:= lAssignmentRec.Attribute9;
	lAssignmentTbl(1).Attribute_Category	:= lAssignmentRec.Attribute_Category;
	lAssignmentTbl(1).Category_Id 		:= lAssignmentRec.Category_Id ;
	lAssignmentTbl(1).Category_Set_Id	:= lAssignmentRec.Category_Set_Id;
	lAssignmentTbl(1).Created_By		:= lAssignmentRec.Created_By;
	lAssignmentTbl(1).Creation_Date		:= lAssignmentRec.Creation_Date;
	lAssignmentTbl(1).Customer_Id		:= lAssignmentRec.Customer_Id;
	lAssignmentTbl(1).Inventory_Item_Id	:= pConfigId;
	lAssignmentTbl(1).Last_Updated_By	:= lAssignmentRec.Last_Updated_By;
	lAssignmentTbl(1).Last_Update_Date	:= lAssignmentRec.Last_Update_Date;
	lAssignmentTbl(1).Last_Update_Login	:= lAssignmentRec.Last_Update_Login;
	lAssignmentTbl(1).Organization_Id	:= lAssignmentRec.Organization_Id;
	lAssignmentTbl(1).Program_Application_Id:= lAssignmentRec.Program_Application_Id;
	lAssignmentTbl(1).Program_Id		:= lAssignmentRec.Program_Id;
	lAssignmentTbl(1).Program_Update_Date	:= lAssignmentRec.Program_Update_Date;
	lAssignmentTbl(1).Request_Id		:= lAssignmentRec.Request_Id;
	lAssignmentTbl(1).Secondary_Inventory	:= lAssignmentRec.Secondary_Inventory;
	lAssignmentTbl(1).Ship_To_Site_Id	:= lAssignmentRec.Ship_To_Site_Id;
	lAssignmentTbl(1).Sourcing_Rule_Id	:= lAssignmentRec.Sourcing_Rule_Id;
	lAssignmentTbl(1).Sourcing_Rule_Type	:= lAssignmentRec.Sourcing_Rule_Type;
	lAssignmentTbl(1).return_status		:= NULL;
	lAssignmentTbl(1).db_flag    		:= NULL;
	lAssignmentTbl(1).operation 		:= MRP_Globals.G_OPR_CREATE;

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('populate_plan_level: ' || 'after forming lAssignmentTbl',2);
	END IF;

	--
	-- form lAssignmentSetRec
	--
	lStmtNum := 50;
	lAssignmentSetRec.operation := MRP_Globals.G_OPR_NONE;
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('populate_plan_level: ' || 'after forming lAssignmentSetRec',2);
	END IF;

	--
	-- call mrp API to insert rec into assignment set
	--
	lStmtNum := 60;
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('populate_plan_level: ' || 'before Process_Assignment',2);
	END IF;

	-- currently, not passing commented out parameters, need to
	-- confirm with raghu, confirmed with stupe

	MRP_Src_Assignment_PUB.Process_Assignment
		(   p_api_version_number	=> 1.0
		--,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
		--,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
		--,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
		,   x_return_status		=> l_return_status
		,   x_msg_count 		=> l_msg_count
		,   x_msg_data  		=> l_msg_data
		,   p_Assignment_Set_rec 	=> lAssignmentSetRec
		--,   p_Assignment_Set_val_rec        IN  Assignment_Set_Val_Rec_Type :=  G_MISS_ASSIGNMENT_SET_VAL_REC
		,   p_Assignment_tbl  		=> lAssignmentTbl
		--,   p_Assignment_val_tbl            IN  Assignment_Val_Tbl_Type := G_MISS_ASSIGNMENT_VAL_TBL
		,   x_Assignment_Set_rec  	=> xAssignmentSetRec
		,   x_Assignment_Set_val_rec	=> xAssignmentSetValRec
		,   x_Assignment_tbl   		=> xAssignmentTbl
		,   x_Assignment_val_tbl  	=> xAssignmentValTbl
		);

	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'unexp error in process_assignment::'||sqlerrm,1);
		END IF;
		raise FND_API.G_EXC_UNEXPECTED_ERROR;

	ELSIF	l_return_status = FND_API.G_RET_STS_ERROR THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'error in process_assignment::'||sqlerrm,1);
		END IF;
		raise FND_API.G_EXC_ERROR;

	END IF;
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('populate_plan_level: ' || 'success in process_assignment',2);
	END IF;

EXCEPTION
        When NO_sourcing_defined THEN
                null;

	when FND_API.G_EXC_ERROR then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'Create_Src_Rules::exp error::'||to_char(lStmtNum)||'::'||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;
		CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);

	when FND_API.G_EXC_UNEXPECTED_ERROR then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'Create_Src_Rules::unexp error::'||to_char(lStmtNum)||'::'||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);

	when OTHERS then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'Create_Src_Rules::others::'||to_char(lStmtNum)||'::'||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            		FND_MSG_PUB.Add_Exc_Msg
            			(G_PKG_NAME
            			,'Create_Sourcing_Rules'
            			);
        	END IF;
        	CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);


END Create_Sourcing_Rules;


 PROCEDURE populate_bcol
 ( p_bcol_line_id        bom_cto_order_lines.line_id%type,
   x_return_status   out   NOCOPY varchar2,
   x_msg_count       out   NOCOPY number,
   x_msg_data	     out   NOCOPY varchar2,
   p_reschedule      in    varchar2 default 'N')
 is


 --cursor for retrieving components of a given top level ato model
 --added decode statement to populate wip supply type of null for top model ato


 cursor c1 ( c_organization_id oe_system_parameters_all.master_organization_id%type )
    is
    select OEOL.line_id
         , OEOL.top_model_line_id
         , OEOL.ato_line_id
         , OEOL.link_to_line_id
         , OEOL.inventory_item_id
         , OEOL.ship_from_org_id
         , OEOL.component_sequence_id
         , OEOL.component_code
         , OEOL.item_type_code
         , OEOL.schedule_ship_date
         , MSYI.bom_item_type
         , decode( OEOL.line_id, OEOL.ato_line_id , null , BIC.wip_supply_type )
         , OEOL.header_id
         , OEOL.ordered_quantity
         , OEOL.order_quantity_uom
         , nvl( MSYI.config_orgs , 1)
         , MSYI.config_match
    from oe_order_lines_all OEOL , bom_inventory_components BIC , mtl_system_items MSYI
    where ato_line_id = p_bcol_line_id
      and OEOL.component_sequence_id = BIC.component_sequence_id
      and OEOL.inventory_item_id = MSYI.inventory_item_id
      and MSYI.organization_id = c_organization_id
      and OEOL.open_flag='Y'  -- bugfix 1876618: look at only open orders
    order by line_id ;

 t_bcol TAB_BCOL ;

/*
** Table to store information for top level item and all its descendants.
** This table is a sparsely populated array. Each item is populated in a location identified
** by its line_id. This helps us directly access the item in the table rather than search for it.
*/


 v_kount   			 number(9) ;
 l_return_status 		 varchar2(10) ;
 v_bcol_line_id             	 bom_cto_order_lines.line_id%type ;
 v_bcol_header_id           	 bom_cto_order_lines.header_id%type ;
 v_bcol_top_model_line_id   	 bom_cto_order_lines.top_model_line_id%type ;
 v_bcol_ato_line_id         	 bom_cto_order_lines.ato_line_id%type ;
 v_bcol_link_to_line_id     	 bom_cto_order_lines.link_to_line_id%type ;
 v_bcol_inventory_item_id        bom_cto_order_lines.inventory_item_id%type ;
 v_bcol_ship_from_org_id         bom_cto_order_lines.ship_from_org_id%type ;
 v_bcol_component_sequence_id    bom_cto_order_lines.component_sequence_id%type ;
 v_bcol_component_code           bom_cto_order_lines.component_code%type ;
 v_bcol_item_type_code           bom_cto_order_lines.item_type_code%type ;
 v_bcol_schedule_ship_date       bom_cto_order_lines.schedule_ship_date%type ;
 v_bcol_bom_item_type            bom_cto_order_lines.bom_item_type%type ;
 v_bcol_wip_supply_type          bom_cto_order_lines.wip_supply_type%type ;
 v_bcol_ordered_quantity         bom_cto_order_lines.ordered_quantity%type ;
 v_bcol_order_quantity_uom       bom_cto_order_lines.order_quantity_uom%type ;
 v_bcol_config_creation          bom_cto_order_lines.config_creation%type ;
 v_bcol_perform_match            bom_cto_order_lines.perform_match%type ;

 v_top_level_found          	 boolean ;


 /* sequence used in this program
 ** BOM_EXPLOSION_TEMP_S
 */

 gUserID         number       ;
 gLoginId        number       ;

 v_inventory_item_id     oe_order_lines_all.inventory_item_id%type ;
 v_organization_id       oe_system_parameters_all.master_organization_id%type ;

 v_ato_line_id         NUMBER;
 v_request_id          NUMBER;
 v_program_id          NUMBER;
 v_prog_update_date    DATE;
 v_prog_appl_id        NUMBER;
 v_mfg_comp_seq_id     NUMBER ;
 v_step                VARCHAR2(10) ;

 i                     number := 0 ; /* bug 1728383 for performance to use .next */
 lMatchProfile         number ; /* changes made for match and reserve enhancements */
 l_custom_match_profile         number ; /* changes made for match and reserve enhancements */



 v_match_flag_tab     CTO_MATCH_CONFIG.MATCH_FLAG_TBL_TYPE ;
 v_sparse_tab         CTO_MATCH_CONFIG.MATCH_FLAG_TBL_TYPE ;



 begin

        gUserId          := nvl(Fnd_Global.USER_ID, -1);
        gLoginId         := nvl(Fnd_Global.LOGIN_ID, -1);

	x_return_status := FND_API.G_RET_STS_SUCCESS;

        v_step := 'Step A1' ;

        select bom_explosion_temp_s.nextval
        into  v_mfg_comp_seq_id
        from dual;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_bcol: ' ||  ' sequence ' || v_mfg_comp_seq_id , 3);
        END IF;


        v_step := 'Step A2' ;

        select inventory_item_id
        into v_inventory_item_id
        from oe_order_lines_all
        where ato_line_id = p_bcol_line_id
        and line_id = p_bcol_line_id ;


       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('populate_bcol: ' ||  ' inventory item id ' || v_inventory_item_id , 3);
       END IF;


        v_step := 'Step A3' ;

        /*
        BUG:3484511
        ---------------
        select master_organization_id
        into   v_organization_id
        from   oe_order_lines_all oel,
           oe_system_parameters_all ospa
        where  oel.line_id = p_bcol_line_id
        and    nvl(oel.org_id, -1) = nvl(ospa.org_id, -1)  --bug 1531691
        and    oel.inventory_item_id = v_inventory_item_id ;
        */




           IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('populate_bcol: ' ||  'Going to fetch Validation Org ' ,2);
           END IF;


           select nvl( oe_sys_parameters.value( 'MASTER_ORGANIZATION_ID' , oel.org_id) , -99)
              into v_organization_id from oe_order_lines_all oel
           where oel.line_id = p_bcol_line_id;





        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_bcol: ' ||  ' master org id ' || v_organization_id , 3 );
        END IF;

    /*
    ** If the profile BOM:Allow Multilevel ATO is set to "NO" then
    ** we need to set wip_supply_type = 6 for lower level models
    ** This is done in the cursor c1
    */

    /*    v_multilevel := FND_PROFILE.VALUE('BOM:MULTILEVEL_ATO');
    **    v_multilevel := nvl(v_multilevel , 'N' ) ;


    **    oe_debug_pub.add('ML profile is '||v_multilevel, 2);
    */


    lMatchProfile := FND_PROFILE.Value('BOM:MATCH_CONFIG');

    l_custom_match_profile := FND_PROFILE.Value('BOM:CUSTOM_MATCH');

    /*
    ** retrieve information related to top level ato model being passed.
    */
        v_step := 'Step A4' ;

    begin
       select OEOL.line_id
            , OEOL.top_model_line_id
            , OEOL.ato_line_id
            , OEOL.link_to_line_id
            , OEOL.inventory_item_id
            , OEOL.ship_from_org_id
            , OEOL.component_sequence_id
            , OEOL.component_code
            , OEOL.item_type_code
            , OEOL.schedule_ship_date
            , MSYI.bom_item_type
            , OEOL.header_id
            , OEOL.ordered_quantity
            , null
            , OEOL.order_quantity_uom
            , nvl( MSYI.config_orgs , 1 )
            , MSYI.config_match
       into   v_bcol_line_id
            , v_bcol_top_model_line_id
            , v_bcol_ato_line_id
            , v_bcol_link_to_line_id
            , v_bcol_inventory_item_id
            , v_bcol_ship_from_org_id
            , v_bcol_component_sequence_id
            , v_bcol_component_code
            , v_bcol_item_type_code
            , v_bcol_schedule_ship_date
            , v_bcol_bom_item_type
            , v_bcol_header_id
            , v_bcol_ordered_quantity
            , v_bcol_wip_supply_type
            , v_bcol_order_quantity_uom
            , v_bcol_config_creation
            , v_bcol_perform_match
       from oe_order_lines_all OEOL , mtl_system_items MSYI
       where OEOL.ato_line_id = p_bcol_line_id
         and OEOL.line_id = p_bcol_line_id
         and MSYI.bom_item_type = '1'
         and OEOL.inventory_item_id = MSYI.inventory_item_id
         and v_organization_id = MSYI.organization_id ;

       t_bcol(v_bcol_line_id).line_id := v_bcol_line_id ;
       t_bcol(v_bcol_line_id).header_id := v_bcol_header_id ;
       t_bcol(v_bcol_line_id).top_model_line_id := v_bcol_top_model_line_id ;
       t_bcol(v_bcol_line_id).ato_line_id := v_bcol_ato_line_id ;
       t_bcol(v_bcol_line_id).link_to_line_id  := v_bcol_link_to_line_id ;
       t_bcol(v_bcol_line_id).inventory_item_id := v_bcol_inventory_item_id ;
       t_bcol(v_bcol_line_id).ship_from_org_id := v_bcol_ship_from_org_id ;
       t_bcol(v_bcol_line_id).component_sequence_id := v_bcol_component_sequence_id ;
       t_bcol(v_bcol_line_id).component_code := v_bcol_component_code ;
       t_bcol(v_bcol_line_id).item_type_code := v_bcol_item_type_code ;
       t_bcol(v_bcol_line_id).schedule_ship_date := v_bcol_schedule_ship_date ;
       t_bcol(v_bcol_line_id).bom_item_type := v_bcol_bom_item_type ;
       t_bcol(v_bcol_line_id).wip_supply_type := v_bcol_wip_supply_type ;
       t_bcol(v_bcol_line_id).ordered_quantity := v_bcol_ordered_quantity ;
       t_bcol(v_bcol_line_id).order_quantity_uom := v_bcol_order_quantity_uom ;
       t_bcol(v_bcol_line_id).config_creation := v_bcol_config_creation ;



       /* match attribute on item should be respected only when match profile = 'Y' */
       if( lMatchProfile = 1 ) then
           if( l_custom_match_profile = 2 ) then
               t_bcol(v_bcol_line_id).perform_match := nvl( v_bcol_perform_match , 'Y' ) ;
           else
               t_bcol(v_bcol_line_id).perform_match := nvl( v_bcol_perform_match , 'C' ) ;
           end if;
       else
           t_bcol(v_bcol_line_id).perform_match := 'N'  ;
       end if;



       oe_debug_pub.add('bcol info : CONC REQ PARAMS ' , 3) ;
       oe_debug_pub.add('bcol info : CONC REQ ' ||  FND_GLOBAL.CONC_REQUEST_ID , 3 );
       oe_debug_pub.add('bcol info : CONC PROG ' ||  FND_GLOBAL.CONC_PROGRAM_ID , 3 );
       oe_debug_pub.add('bcol info : PROG APPL ' ||  FND_GLOBAL.PROG_APPL_ID , 3 );


       t_bcol(v_bcol_line_id).Request_Id := FND_GLOBAL.CONC_REQUEST_ID;
       t_bcol(v_bcol_line_id).Program_Id := FND_GLOBAL.CONC_PROGRAM_ID;
       t_bcol(v_bcol_line_id).Program_Application_Id := FND_GLOBAL.PROG_APPL_ID;



       /* set plan level to 0 for top level item */
       t_bcol(v_bcol_line_id).plan_level := 0 ;
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('populate_bcol: ' ||  ' ----- setting plan level = 0 for base item ' , 3  );
       END IF;

    exception
       when others then
            	IF PG_DEBUG <> 0 THEN
            		oe_debug_pub.add('populate_bcol: ' ||  ' got into exception for top level item at ' || v_step , 1 );

			oe_debug_pub.add('populate_bcol: ' || 'error in top ato model line id::'||sqlerrm , 1 );
		END IF;
     		cto_msg_pub.cto_message('BOM','CTO_CREATE_ITEM_ERROR');
		raise FND_API.G_EXC_ERROR;

    end;




    /*
    ** check whether to update the oeol_all table with batchid?
    */

        v_step := 'Step A5' ;

    open c1( v_organization_id ) ;

    v_kount := 1 ;

    /*
    ** retrieve information related to components of top level item in a pl/sql table
    ** also check whether a config item has already been created
    */
    while( TRUE )
    loop


        v_step := 'Step 6' ;

       fetch c1 into v_bcol_line_id
                   , v_bcol_top_model_line_id
                   , v_bcol_ato_line_id
                   , v_bcol_link_to_line_id
                   , v_bcol_inventory_item_id
                   , v_bcol_ship_from_org_id
                   , v_bcol_component_sequence_id
                   , v_bcol_component_code
                   , v_bcol_item_type_code
                   , v_bcol_schedule_ship_date
                   , v_bcol_bom_item_type
                   , v_bcol_wip_supply_type
                   , v_bcol_header_id
                   , v_bcol_ordered_quantity
                   , v_bcol_order_quantity_uom
                   , v_bcol_config_creation
                   , v_bcol_perform_match ;



       exit when c1%notfound ;


       if( upper( v_bcol_item_type_code) = 'CONFIG' ) then
           /* you need to error out as the config item exists */

           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('populate_bcol: ' ||  ' ---- CONFIG Exists ', 1 );
           END IF;

     	   cto_msg_pub.cto_message('BOM','CTO_CONFIG_ITEM_EXISTS');
	   raise FND_API.G_EXC_ERROR;

       end if ;


       t_bcol(v_bcol_line_id).line_id := v_bcol_line_id ;
       t_bcol(v_bcol_line_id).header_id := v_bcol_header_id ;
       t_bcol(v_bcol_line_id).top_model_line_id := v_bcol_top_model_line_id ;
       t_bcol(v_bcol_line_id).ato_line_id := v_bcol_ato_line_id ;
       t_bcol(v_bcol_line_id).link_to_line_id  := v_bcol_link_to_line_id ;
       t_bcol(v_bcol_line_id).inventory_item_id := v_bcol_inventory_item_id ;
       t_bcol(v_bcol_line_id).ship_from_org_id := v_bcol_ship_from_org_id ;
       t_bcol(v_bcol_line_id).component_sequence_id := v_bcol_component_sequence_id ;
       t_bcol(v_bcol_line_id).component_code := v_bcol_component_code ;
       t_bcol(v_bcol_line_id).item_type_code := v_bcol_item_type_code ;
       t_bcol(v_bcol_line_id).schedule_ship_date := v_bcol_schedule_ship_date ;
       t_bcol(v_bcol_line_id).bom_item_type := v_bcol_bom_item_type ;
       t_bcol(v_bcol_line_id).wip_supply_type := v_bcol_wip_supply_type ;
       t_bcol(v_bcol_line_id).ordered_quantity := v_bcol_ordered_quantity ;
       t_bcol(v_bcol_line_id).order_quantity_uom := v_bcol_order_quantity_uom ;

       t_bcol(v_bcol_line_id).config_creation := v_bcol_config_creation ;
       /* match attribute on item should be respected only when match profile = 'Y' */
       if( lMatchProfile = 1 ) then
           if( l_custom_match_profile = 2 ) then
               t_bcol(v_bcol_line_id).perform_match := nvl( v_bcol_perform_match , 'Y' ) ;
           else
               t_bcol(v_bcol_line_id).perform_match := nvl( v_bcol_perform_match , 'C' ) ;
           end if;
       else
           t_bcol(v_bcol_line_id).perform_match := 'N'  ;
       end if;

       oe_debug_pub.add('bcol info : CONC REQ PARAMS ' , 3) ;
       oe_debug_pub.add('bcol info : CONC REQ ' ||  FND_GLOBAL.CONC_REQUEST_ID , 3 );
       oe_debug_pub.add('bcol info : CONC PROG ' ||  FND_GLOBAL.CONC_PROGRAM_ID , 3 );
       oe_debug_pub.add('bcol info : PROG APPL ' ||  FND_GLOBAL.PROG_APPL_ID , 3 );


       t_bcol(v_bcol_line_id).Request_Id := FND_GLOBAL.CONC_REQUEST_ID;
       t_bcol(v_bcol_line_id).Program_Id := FND_GLOBAL.CONC_PROGRAM_ID;
       t_bcol(v_bcol_line_id).Program_Application_Id := FND_GLOBAL.PROG_APPL_ID;


       v_kount := v_kount + 1 ;


    end loop ;

    v_step := 'Step A7' ;

    close c1 ;

    /*
    ** this loop can be discarded
    */

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('populate_bcol: ' ||  'source data ' , 3 );

    	oe_debug_pub.add('populate_bcol: ' ||  'line_id top_model ato   link_to plan_level ', 1 );
    END IF;

    v_step := 'Step A8' ;

    i:= t_bcol.first ;

    /*   for i in 1..t_bcol.last  commented out for bug 1728383 */


    while i is not null
    loop

       if( t_bcol.exists(i) ) then
          IF PG_DEBUG <> 0 THEN
          	oe_debug_pub.add('populate_bcol: ' ||  t_bcol(i).line_id || '  ' || t_bcol(i).top_model_line_id
            || ' A ' ||  t_bcol(i).ato_line_id
            || ' LN ' || t_bcol(i).link_to_line_id
            || ' PAL ' ||  t_bcol(i).parent_ato_line_id
            || ' P ' ||  t_bcol(i).plan_level
            || ' BI '  || t_bcol(i).bom_item_type
            || ' WS ' || t_bcol(i).wip_supply_type
            || ' OQ ' || t_bcol(i).ordered_quantity
            || ' UOM ' || t_bcol(i).order_quantity_uom
            || ' creation  ' ||  t_bcol(i).config_creation
            || ' Match  ' ||  t_bcol(i).perform_match
            , 1 );
          END IF;


          /*
          ** update these records in oe_order_lines to indicate process locks
          */

        v_step := 'Step A9' ;

          oe_config_util.update_mfg_comp_seq_id( t_bcol(i).line_id
                                       , v_mfg_comp_seq_id
                                       , l_return_status  );

	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_bcol: ' || 'unexp error in update_mfg_comp_seq_id::'||sqlerrm , 1 );
		END IF;
		raise FND_API.G_EXC_UNEXPECTED_ERROR;

	ELSIF	l_return_status = FND_API.G_RET_STS_ERROR THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_bcol: ' || 'error in update_mfg_comp_seq_id::'||sqlerrm , 1 );
		END IF;
		raise FND_API.G_EXC_ERROR;
	END IF;

       end if ;



       i := t_bcol.next(i) ;

    end loop ;


    /*
    ** end of loop to be discarded.
    */


    /*
    ** call populate_line_id to populate the plan level
    */

    v_step := 'Step A10' ;

    populate_plan_level( t_bcol ) ;

    /*
    ** call populate_line_id to populate the plan level
    */

    v_step := 'Step A11' ;

    populate_parent_ato( t_bcol , p_bcol_line_id ) ;

    /*
    ** Populate parent line id of top level id as itself.
    ** NOTE: we need to populate this at the end to avoid ending in a recursive loop
    */
    t_bcol(p_bcol_line_id).parent_ato_line_id := p_bcol_line_id;

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('populate_bcol: ' ||  'processed data ' , 4 );

    	oe_debug_pub.add('populate_bcol: ' ||  'line_id top_model ato   link_to plan_level ' , 3 );

        oe_debug_pub.add('populate_bcol: ' ||  'going to check for invalid model setup ' , 4 );

    END IF;


    /*
    ** CHECK FOR INVALID MODEL SETUP
    **
    */


    i := t_bcol.first ;
    while i is not null
    loop
          if( t_bcol(i).bom_item_type = 1 and nvl(t_bcol(i).wip_supply_type, 1 ) <> 6 and t_bcol(i).config_creation in (1, 2) ) then

             if( t_bcol(t_bcol(i).parent_ato_line_id).config_creation = 3) then

                 IF PG_DEBUG <> 0 THEN
                    oe_debug_pub.add('populate_bcol: ' || 'INVALID MODEL SETUP exists for line id  '  || t_bcol(i).line_id
                                                       || ' model item ' || t_bcol(i).inventory_item_id
                                                       || ' item type ' || t_bcol(i).config_creation
                                      , 1 );
                    oe_debug_pub.add('populate_bcol: ' || ' parent line id  '  || t_bcol(t_bcol(i).parent_ato_line_id).line_id
                                                       || ' parent model item ' || t_bcol(t_bcol(i).parent_ato_line_id).inventory_item_id
                                                       || ' parent item type ' || t_bcol(t_bcol(i).parent_ato_line_id).config_creation
                                      , 1 );

                 END IF;


                 cto_msg_pub.cto_message('BOM','CTO_INVALID_MODEL_SETUP');
                 raise FND_API.G_EXC_ERROR;

             end if;

          end if ;


          i := t_bcol.next(i) ;

    end loop ;


    /*
    **  CALL TRANSFORMED MATCH ATTRIBUTES PENDING
    ** PENDING WORK!!!!
    */

    if( lMatchProfile = 1 ) then
         oe_debug_pub.add('populate_bcol: ' ||  ' preparing information for v_match_flag_tab ' , 3 );
         i :=t_bcol.first ;

         while i is not null
         loop

             if( t_bcol(i).bom_item_type = 1 and nvl( t_bcol(i).wip_supply_type , 1 )  <> 6 ) then
                 v_match_flag_tab(v_match_flag_tab.count + 1).line_id := t_bcol(i).line_id ;
                 v_match_flag_tab(v_match_flag_tab.count ).parent_ato_line_id := t_bcol(i).parent_ato_line_id ;
                 v_match_flag_tab(v_match_flag_tab.count ).ato_line_id := t_bcol(i).ato_line_id ;
                 v_match_flag_tab(v_match_flag_tab.count ).match_flag := t_bcol(i).perform_match ;

             end if;

             i := t_bcol.next(i) ;

         end loop ;


         oe_debug_pub.add('populate_bcol: ' ||  ' going to call cto_match_config.evaluate_n_pop_match_flag ' , 3 );

         cto_match_config.evaluate_n_pop_match_flag( p_match_flag_tab  => v_match_flag_tab
                                              , x_sparse_tab => v_sparse_tab
                                              , x_return_status => x_return_status
                                              , x_msg_count => x_msg_count
                                              , x_msg_data => x_msg_data );





         oe_debug_pub.add('populate_bcol: ' ||  ' populating match flag from results ' , 3 );

         i := v_sparse_tab.first ;

         while i is not null
         loop

             t_bcol(i).perform_match := v_sparse_tab(i).match_flag ;

             i := v_sparse_tab.next(i) ;

         end loop ;

         oe_debug_pub.add('populate_bcol: ' ||  ' done populating match flag from results ' , 3 );


    else

         oe_debug_pub.add('populate_bcol: ' ||  ' will not be calling cto_match_config.evaluate_n_pop_match_flag ' , 3 );

    end if ;


    v_step := 'Step A12' ;


    i := t_bcol.first ;


    /*    for i in 1..t_bcol.last  commented for bug 1728383 */


    while i is not null
    loop

       if( t_bcol.exists(i) ) then

          IF PG_DEBUG <> 0 THEN

          	oe_debug_pub.add('populate_bcol: ' ||  t_bcol(i).line_id || '  ' || t_bcol(i).top_model_line_id
            || ' A ' ||  t_bcol(i).ato_line_id
            || ' LN ' || t_bcol(i).link_to_line_id
            || ' PAL ' ||  t_bcol(i).parent_ato_line_id
            || ' P ' ||  t_bcol(i).plan_level
            || ' BI '  || t_bcol(i).bom_item_type
            || ' WS ' || t_bcol(i).wip_supply_type
            || ' OQ ' || t_bcol(i).ordered_quantity
            || ' UOM ' || t_bcol(i).order_quantity_uom
            || ' creation  ' ||  t_bcol(i).config_creation
            || ' Match  ' ||  t_bcol(i).perform_match
            , 1 );

          END IF;




          v_step := 'Step A16' ;


          if (nvl( p_reschedule, 'N') = 'N' ) then
             /*
             ** insert this information into bom_cto_order_lines table
             */

             insert into bom_cto_order_lines (
                         LINE_ID
                        ,HEADER_ID
                        ,TOP_MODEL_LINE_ID
                        ,LINK_TO_LINE_ID
                        ,ATO_LINE_ID
                        ,PARENT_ATO_LINE_ID
                        ,INVENTORY_ITEM_ID
                        ,SHIP_FROM_ORG_ID
                        ,COMPONENT_SEQUENCE_ID
                        ,COMPONENT_CODE
                        ,ITEM_TYPE_CODE
                        ,SCHEDULE_SHIP_DATE
                        ,PLAN_LEVEL
                        ,PERFORM_MATCH
                        ,CONFIG_ITEM_ID
                        ,BOM_ITEM_TYPE
                        ,WIP_SUPPLY_TYPE
                        ,ORDERED_QUANTITY
                        ,ORDER_QUANTITY_UOM
                        ,BATCH_ID
                        ,CREATION_DATE
                        ,CREATED_BY
                        ,LAST_UPDATE_DATE
                        ,LAST_UPDATED_BY
                        ,LAST_UPDATE_LOGIN
                        ,PROGRAM_APPLICATION_ID
                        ,PROGRAM_ID
                        ,REQUEST_ID
                        ,PROGRAM_UPDATE_DATE
                        ,QTY_PER_PARENT_MODEL
                        ,OPTION_SPECIFIC
                        ,REUSE_CONFIG
                        ,CONFIG_CREATION)
                        values (
                         t_bcol(i).LINE_ID
                        ,t_bcol(i).HEADER_ID
                        ,t_bcol(i).TOP_MODEL_LINE_ID
                        ,t_bcol(i).LINK_TO_LINE_ID
                        ,t_bcol(i).ATO_LINE_ID
                        ,t_bcol(i).PARENT_ATO_LINE_ID
                        ,t_bcol(i).INVENTORY_ITEM_ID
                        ,t_bcol(i).SHIP_FROM_ORG_ID
                        ,t_bcol(i).COMPONENT_SEQUENCE_ID
                        ,t_bcol(i).COMPONENT_CODE
                        ,t_bcol(i).ITEM_TYPE_CODE
                        ,t_bcol(i).SCHEDULE_SHIP_DATE
                        ,t_bcol(i).PLAN_LEVEL
                        ,t_bcol(i).PERFORM_MATCH
                        ,t_bcol(i).CONFIG_ITEM_ID
                        ,t_bcol(i).BOM_ITEM_TYPE
                        ,t_bcol(i).WIP_SUPPLY_TYPE
                        ,t_bcol(i).ORDERED_QUANTITY
                        ,t_bcol(i).ORDER_QUANTITY_UOM
                        ,t_bcol(i).BATCH_ID
                        ,sysdate
                        ,gUserId /* CREATED_BY  */
                        ,sysdate /* LAST_UPDATE_DATE */
                        ,gUserId /* LAST_UPDATED_BY */
                        ,gLoginId /* LAST_UPDATE_LOGIN */
                        ,FND_GLOBAL.PROG_APPL_ID /* PROGRAM_APPLICATION_ID */
                        ,FND_GLOBAL.CONC_PROGRAM_ID /* PROGRAM_ID */
                        ,FND_GLOBAL.CONC_REQUEST_ID /* REQUEST_ID */
                        ,sysdate /* PROGRAM_UPDATE_DATE */
                        ,t_bcol(i).ordered_quantity / t_bcol(t_bcol(i).parent_ato_line_id).ordered_quantity
                        ,'N'
                        ,'N'
                        ,t_bcol(i).config_creation );


                        IF PG_DEBUG <> 0 THEN
    	                   oe_debug_pub.add('populate_bcol: bcol ' || t_bcol(i).line_id  , 1 );
                        END IF;


          else


             insert into bom_cto_order_lines_gt (
                         LINE_ID
                        ,HEADER_ID
                        ,TOP_MODEL_LINE_ID
                        ,LINK_TO_LINE_ID
                        ,ATO_LINE_ID
                        ,PARENT_ATO_LINE_ID
                        ,INVENTORY_ITEM_ID
                        ,SHIP_FROM_ORG_ID
                        ,COMPONENT_SEQUENCE_ID
                        ,COMPONENT_CODE
                        ,ITEM_TYPE_CODE
                        ,SCHEDULE_SHIP_DATE
                        ,PLAN_LEVEL
                        ,PERFORM_MATCH
                        ,CONFIG_ITEM_ID
                        ,BOM_ITEM_TYPE
                        ,WIP_SUPPLY_TYPE
                        ,ORDERED_QUANTITY
                        ,ORDER_QUANTITY_UOM
                        ,BATCH_ID
                        ,CREATION_DATE
                        ,CREATED_BY
                        ,LAST_UPDATE_DATE
                        ,LAST_UPDATED_BY
                        ,LAST_UPDATE_LOGIN
                        ,PROGRAM_APPLICATION_ID
                        ,PROGRAM_ID
                        ,REQUEST_ID
                        ,PROGRAM_UPDATE_DATE
                        ,QTY_PER_PARENT_MODEL
                        ,CONFIG_CREATION
                        ,OPTION_SPECIFIC
                        ,REUSE_CONFIG
			,VALIDATION_ORG
             )
             values (
                         t_bcol(i).LINE_ID
                        ,t_bcol(i).HEADER_ID
                        ,t_bcol(i).TOP_MODEL_LINE_ID
                        ,t_bcol(i).LINK_TO_LINE_ID
                        ,t_bcol(i).ATO_LINE_ID
                        ,t_bcol(i).PARENT_ATO_LINE_ID
                        ,t_bcol(i).INVENTORY_ITEM_ID
                        ,t_bcol(i).SHIP_FROM_ORG_ID
                        ,t_bcol(i).COMPONENT_SEQUENCE_ID
                        ,t_bcol(i).COMPONENT_CODE
                        ,t_bcol(i).ITEM_TYPE_CODE
                        ,t_bcol(i).SCHEDULE_SHIP_DATE
                        ,t_bcol(i).PLAN_LEVEL
                        ,t_bcol(i).PERFORM_MATCH
                        ,t_bcol(i).CONFIG_ITEM_ID
                        ,t_bcol(i).BOM_ITEM_TYPE
                        ,t_bcol(i).WIP_SUPPLY_TYPE
                        ,t_bcol(i).ORDERED_QUANTITY
                        ,t_bcol(i).ORDER_QUANTITY_UOM
                        ,t_bcol(i).BATCH_ID
                        ,sysdate
                        ,gUserId /* CREATED_BY  */
                        ,sysdate /* LAST_UPDATE_DATE */
                        ,gUserId /* LAST_UPDATED_BY */
                        ,gLoginId /* LAST_UPDATE_LOGIN */
                        ,FND_GLOBAL.PROG_APPL_ID /* PROGRAM_APPLICATION_ID */
                        ,FND_GLOBAL.CONC_PROGRAM_ID /* PROGRAM_ID */
                        ,FND_GLOBAL.CONC_REQUEST_ID /* REQUEST_ID */
                        ,sysdate /* PROGRAM_UPDATE_DATE */
                        ,t_bcol(i).ordered_quantity / t_bcol(t_bcol(i).parent_ato_line_id).ordered_quantity
                        ,t_bcol(i).config_creation
                        , 'N'
                        , 'N'
			,t_bcol(i).SHIP_FROM_ORG_ID --bugfix 3555026
             ) ;

             IF PG_DEBUG <> 0 THEN
    	        oe_debug_pub.add('populate_bcol: bcol_gt ' || t_bcol(i).line_id  , 1 );
             END IF;


          end if ; /* check for reschedule flag */

       end if ;

       i := t_bcol.next(i) ; /* added for bug 1728383 for performance */

    end loop ;




    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('populate_bcol: ' || 'success in populate bcol ', 1 );
    END IF;

 exception

	when FND_API.G_EXC_ERROR then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_bcol: ' || 'populate_Bcol::exp error::'|| v_step ||'::'||sqlerrm , 1);
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;
		CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);

	when FND_API.G_EXC_UNEXPECTED_ERROR then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_bcol: ' || 'populate_Bcol::unexp error::'|| v_step ||'::'||sqlerrm , 1);
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);

	when OTHERS then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_bcol: ' || 'populate_Bcol::others::'|| v_step ||'::'||sqlerrm , 1 );
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            		FND_MSG_PUB.Add_Exc_Msg
            			(G_PKG_NAME
            			,'populate_bcol'
            			);
        	END IF;
        	CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);

 end populate_bcol ;


/*
 PROCEDURE validate_model_heir_behavior
 ( p_t_bcol  in out NOCOPY TAB_BCOL )
 is
 begin





 end validate_model_heir_behavior ;
*/


 PROCEDURE populate_plan_level
 ( p_t_bcol  in out NOCOPY TAB_BCOL )
 is
 TYPE TABNUM is TABLE of NUMBER index by binary_integer ;
 v_raw_line_id TABNUM ;
 v_src_point   number ;
 j             number ;
 v_step        VARCHAR2(10) ;
 i             number := 0 ;

 begin

    /*
    ** Strategy: Resolve plan_level for each line item by setting it to 1 + plan_level of parent.
    ** use the link_to_line_id column to get to the parent. if parents plan_level is not yet
    ** resolved, go to its immediate ancestor recursively till you find a line item with
    ** plan_level set( Top level plan level is always set to zero ). When coming out of recursion
    ** set the plan_level of any ancestors that havent been resolved yet.
    ** Implementation: As Pl/Sql does not support Stack built-in-datatype, an equivalent behavior
    ** can be achieved by storing items in a table( PUSH implementation) and retrieving them from
    ** the end of the table ( POP implmentation [LIFO] )
    */

        v_step := 'Step B1' ;

    i := p_t_bcol.first ;



    /*   for i in 1..p_t_bcol.last commented for bug 1728383 */


    while i is not null
    loop

       if( p_t_bcol.exists(i)  ) then

          v_src_point := i ;


          /*
          ** resolve plan level for item only if not yet resolved
          */
          while( p_t_bcol(v_src_point).plan_level is null )
          loop

             v_raw_line_id(v_raw_line_id.count + 1 ) := v_src_point  ;
             /* store each unresolved item in its heirarchy */

             v_src_point := p_t_bcol(v_src_point).link_to_line_id ;

          end loop ;

        v_step := 'Step B2' ;

          j := v_raw_line_id.count ; /* total number of items to be resolved */

          while( j >= 1 )
          loop

             p_t_bcol(v_raw_line_id(j)).plan_level := p_t_bcol(v_src_point).plan_level + 1;

             v_src_point := v_raw_line_id(j) ;

             j := j -1 ;
          end loop ;

          v_raw_line_id.delete ; /* remove all elements as they have been resolved */

       end if ;



       i := p_t_bcol.next(i) ;  /* added for bug 1728383 for performance */


    end loop ;

 end populate_plan_level ;



 PROCEDURE populate_parent_ato
 ( p_t_bcol  in out NOCOPY TAB_BCOL ,
  p_bcol_line_id in       bom_cto_order_lines.line_id%type )
 is
 TYPE TABNUM is TABLE of NUMBER index by binary_integer ;
 v_raw_line_id TABNUM ;
 v_src_point   number ;
 v_prev_src_point   number ;
 j             number ;
 v_step        VARCHAR2(10) ;
 i             number := 0 ;

 begin

    /*
    ** Strategy: Resolve parent_ato for each line item by setting it to 1 + plan_level of parent.
    ** use the link_to_line_id column to get to the parent. if parents plan_level is not yet
    ** resolved, go to its immediate ancestor recursively till you find a line item with
    ** plan_level set( Top level plan level is always set to zero ). When coming out of recursion
    ** set the plan_level of any ancestors that havent been resolved yet.
    ** Implementation: As Pl/Sql does not support Stack built-in-datatype, an equivalent behavior
    ** can be achieved by storing items in a table( PUSH implementation) and retrieving them from
    ** the end of the table ( POP implmentation [LIFO] )
    */

        v_step := 'Step C1' ;

    i := p_t_bcol.first ;


    /*  for i in 1..p_t_bcol.last commented for bug 1728383 */

    while i is not null
    loop

       if( p_t_bcol.exists(i)  ) then

          v_src_point := i ;
          /* please note, here it stores the index which is the same as line_id due to sparse array*/

          IF PG_DEBUG <> 0 THEN
          	oe_debug_pub.add('populate_parent_ato: ' ||  ' processing ' || to_char( v_src_point ) , 3 );
          END IF;
          /*
          ** resolve parent ato line id for item.
          */
        v_step := 'Step C2' ;

          while( p_t_bcol.exists(v_src_point) )
          loop

             v_raw_line_id(v_raw_line_id.count + 1 ) := v_src_point  ;
             /* store each unresolved item in its heirarchy */

             v_prev_src_point := v_src_point ;

             v_src_point := p_t_bcol(v_src_point).link_to_line_id ;


          IF PG_DEBUG <> 0 THEN
          	oe_debug_pub.add('populate_parent_ato: ' ||  'prev point ' || to_char( v_prev_src_point ) || ' bcol ' || to_char( p_bcol_line_id ) , 3 );
          END IF;


             if( v_src_point is null or v_prev_src_point = p_bcol_line_id ) then
                 v_src_point := v_prev_src_point ;

                 /* break if pto is on top of top level ato or
                    the current lineid is top level phantom ato
                 */

                 exit ;
             end if ;

             if( p_t_bcol(v_src_point).bom_item_type = '1' AND
                 p_t_bcol(v_src_point).ato_line_id is not null AND
                 nvl( p_t_bcol(v_src_point).wip_supply_type , 0 ) <> '6' ) then

                   exit ;
                  /* break if non phantom ato parent found */
             end if ;



          end loop ;

          j := v_raw_line_id.count ; /* total number of items to be resolved */

        v_step := 'Step C3' ;

          while( j >= 1 )
          loop

             p_t_bcol(v_raw_line_id(j)).parent_ato_line_id := v_src_point ;

             j := j -1 ;

          end loop ;

          v_raw_line_id.delete ; /* remove all elements as they have been resolved */

       end if ;



       i := p_t_bcol.next(i) ;  /* added for bug 1728383 for performance */


    end loop ;

 end populate_parent_ato ;


/*
** This procedure checks for existence of any sourcing rules for a given Item.
** An Item will be considered sourced if the sourcing rule type is 'TRANSFER FROM'.
** This procedure flags an error if multiple sourcing rules exist for an Item.
** A no data found for sourcing rule query or a 'MAKE AT' sourcing rule is considered as end of sourcing chain.
*/

/* Modified by Renga Kannan on 08/21/01 to support buy model sourcing. The signature
   of the procedure is changed. This change is done as part of the procuring fonit
   code changes
*/


PROCEDURE query_sourcing_org(
  p_inventory_item_id    NUMBER
, p_organization_id      NUMBER
, p_sourcing_rule_exists out NOCOPY varchar2
, p_source_type          out NOCOPY NUMBER    -- Added by Renga Kannan on 08/21/01
, p_sourcing_org         out NOCOPY NUMBER
, p_transit_lead_time    out NOCOPY NUMBER
, x_exp_error_code       out NOCOPY NUMBER
, x_return_status        out NOCOPY varchar2
)
is
v_sourcing_rule_id    number ;
l_stmt_num            number ;
v_source_type         varchar2(1) ;
v_sourcing_rule_count number;         -- Added by Renga Kannan on 08/21/01

l_make_buy_code       number;
begin
     /*
     ** This routine should consider no data found or one make at sourcing rule
     ** as no sourcing rule exist.
     */
           l_stmt_num := 1 ;

           -- Added by Renga Kannan on 06/26/01
           -- The following  initialize_assignment_set is used to initialize the global variable

           IF gMrpAssignmentSet is null THEN
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('query_sourcing_org: ' || 'Initializing the assignment set',5);
             END IF;
             initialize_assignment_set(x_return_status);
             if x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('query_sourcing_org: ' || 'Error in initializing assignment set',5);
                END IF;
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
             end if;
           End IF;


           p_sourcing_rule_exists := FND_API.G_FALSE ;
           x_return_status := FND_API.G_RET_STS_SUCCESS ;
           p_transit_lead_time := 0 ;


          -- Added by Renga Kannan on 08/27/01
          -- If the default assignment set is not defined then it needs to
          -- get the source type based on make or buy rule;

           IF  gMrpAssignmentSet is NULL Then
                SELECT planning_make_buy_code
                INTO   l_make_buy_code
                FROM   MTL_SYSTEM_ITEMS
                WHERE  inventory_item_id = p_inventory_item_id
                AND    organization_id   = p_organization_id;

                IF l_make_buy_code = 2 THEN
                  p_source_type := 3;
                  -- Renga Kannan added on 09/13/01 to set the sourcin_rule_exists
                  -- Output value to Y even in the case of Buy attribute
                  p_sourcing_rule_exists := FND_API.G_TRUE;

		ELSE
		   p_source_type := 2;


                END IF;
                return;
           END IF;



           /*
           ** Fix for Bug 1610583
           ** Source Type values in MRP_SOURCES_V
           ** 1 = Transfer From, 2 = Make At, 3 = Buy From.
           */


           -- In the following sql the Where condition is fixed by Renga Kannan
           -- on 04/30/2001. If the sourcing is defined in the org level the source_type
           -- will be null. Still we need to see that sourcing rule. So the condition
           -- Source_type <> 3 is replaced with nvl(source_type,1). When the source_type is
           -- Null it will be defaulted to 1(Transfer from). As per the discussion with Sushant.


           /* Please note the changes done for procuring config project */
           -- Since the buy sourcing needs to be supported the where condition for msv.source_type is removed
           -- from the following query. This is done by Renga Kannan

           l_stmt_num := 10 ;

           begin
              select distinct
                source_organization_id,
                sourcing_rule_id,
                nvl(source_type,1) ,
                nvl( avg_transit_lead_time , 0 )
              into
                p_sourcing_org
              , v_sourcing_rule_id
              , v_source_type
              , p_transit_lead_time
              from mrp_sources_v msv
              where msv.assignment_set_id = gMrpAssignmentSet
                and msv.inventory_item_id = p_inventory_item_id
                and msv.organization_id = p_organization_id
              --  and nvl(msv.source_type,1) <> 3 commented by Renga for BUY odel
                and nvl(effective_date,sysdate) <= nvl(disable_date, sysdate) -- Nvl fun is added by Renga Kannan on 05/05/2001
                and nvl(disable_date, sysdate+1) > sysdate;

              /*
              ** item is multi-org if sourcing rule is transfer from.
              */
              l_stmt_num := 20 ;

              --- The following assignment stmt is added by Renga Kannan
              --- to pass back the source type value as parameter

              p_source_type := v_source_type;

              if( v_source_type = 1 ) then
                  p_sourcing_rule_exists := FND_API.G_TRUE ;

              --- The following elseif clause is added by Renga Kannan
              --- For procuring config project change.
              elsif (v_source_type = 3) then
                  p_sourcing_rule_exists := FND_API.G_TRUE ;
                  IF PG_DEBUG <> 0 THEN
                  	oe_debug_pub.add('query_sourcing_org: ' || 'Buy Sourcing rule exists...',1);
                  END IF;
              end if ;


              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('query_sourcing_org: ' ||  '****$$$$ IID ' || p_inventory_item_id || ' in org ' ||
                      p_organization_id || ' is sourced from org ' || p_sourcing_org ||
                      ' type ' || v_source_type || ' $$$$****' , 1 );
              END IF;

           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('query_sourcing_org: ' ||  ' came into no data when finding source ' || to_char(l_stmt_num ) , 1  );
                END IF;
                /* removed no sourcing flag as cascading of sourcing rules will
                ** be continued till no more sourcing rules can be cascaded
                */

                --- Added by Renga Kannan on 08/21/01
                --- When there is no sourcing rule defined we need to look at the
                --- Planning_make_buy_code to determine the source_type
                --- If the planning_make_buy_code is 1(Make) we can return as it is
                --- If the planning_make_buy_code is 2(Buy) we need to set the p_source_type to 3 and return
                --- so that the calling application will knwo this as buy model

                SELECT planning_make_buy_code
                INTO   l_make_buy_code
                FROM   MTL_SYSTEM_ITEMS
                WHERE  inventory_item_id = p_inventory_item_id
                AND    organization_id   = p_organization_id;

                IF l_make_buy_code = 2 THEN
                  p_source_type := 3;
                  p_sourcing_rule_exists := FND_API.G_TRUE ;
                ELSE
		  p_source_type := 2;
                END IF;


                ---- End of addition by Renga


              WHEN TOO_MANY_ROWS THEN
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('query_sourcing_org: ' ||  ' came into too_many when finding source ' || to_char(l_stmt_num)  , 1  );
                END IF;
              select count(*)
              into v_sourcing_rule_count
              from mrp_sources_v msv
              where msv.assignment_set_id = gMrpAssignmentSet
                and msv.inventory_item_id = p_inventory_item_id
                and msv.organization_id = p_organization_id
                and nvl(msv.source_type,1) <> 3
                and nvl(effective_date,sysdate) <= nvl(disable_date, sysdate)
                    /* Nvl fun is added by Renga Kannan on 05/05/2001 */
                and nvl(disable_date, sysdate+1) > sysdate;


                if( v_sourcing_rule_count > 0 ) then

                   /*  x_return_status                := FND_API.G_RET_STS_ERROR;
	            cto_msg_pub.cto_message('BOM','CTO_INVALID_SOURCING');
                      x_exp_error_code := 66;

		      */

		   --by Kiran Konada , for DMF-J mutliple sources support
                   --from DMF-J , having multiple sources is not error
		   --use 66 as source type for multiple sourcing
		    p_source_type := 66;
                    p_sourcing_rule_exists := FND_API.G_TRUE ;


                else

                    p_source_type := 3 ;
                    p_sourcing_rule_exists := FND_API.G_TRUE ;


                end if ;


              WHEN OTHERS THEN
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('query_sourcing_org: ' ||  'QUERY_SOURCING_ORG::others:: ' ||
                                   to_char(l_stmt_num) || '::' ||
                                  ' came into others when finding source ' , 1  );

                	oe_debug_pub.add('query_sourcing_org: ' ||  ' SQLCODE ' || SQLCODE , 1 );

                	oe_debug_pub.add('query_sourcing_org: ' ||  ' SQLERRM ' || SQLERRM  , 1 );

                	oe_debug_pub.add('query_sourcing_org: ' ||  ' came into others when finding source ' , 1  );
                END IF;

                x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;



           END ;
end query_sourcing_org ;




PROCEDURE initialize_assignment_set ( x_return_status out NOCOPY varchar2 )
IS
   l_stmt_num                  number;
   assign_set_name            varchar2(80);
   INVALID_MRP_ASSIGNMENT_SET exception ;

BEGIN
      /* begin for static block */
   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   /*
   ** get MRP's default assignment set
   */
   l_stmt_num := 1 ;

   IF gMrpAssignmentSet is null THEN
      begin

        gMrpAssignmentSet := to_number(FND_PROFILE.VALUE('MRP_DEFAULT_ASSIGNMENT_SET'));
      exception
      when others then
         raise invalid_mrp_assignment_set ;
      end ;

      l_stmt_num := 5 ;

      IF( gMrpAssignmentSet is null )
      THEN
         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('initialize_assignment_set: ' || '**$$ Default assignment set is null',  1);
         END IF;

      ELSE
         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('initialize_assignment_set: ' || 'Default assignment set is '||to_char(gMrpAssignmentSet),2);
         END IF;

         l_stmt_num := 10 ;

         begin


             select assignment_set_name into assign_set_name
             from mrp_Assignment_sets
             where assignment_set_id = gMrpAssignmentSet ;

         exception
            when no_data_found then
               IF PG_DEBUG <> 0 THEN
               	oe_debug_pub.add('initialize_assignment_set: ' ||  'The assignment set pointed by the
                                   profile MRP_DEFAULT_ASSIGNMENT_SET
                                   does not exist in the database ' ,1);
               END IF;

                RAISE INVALID_MRP_ASSIGNMENT_SET ;

             when others then

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
         end ;

         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('initialize_assignment_set: ' || 'Default assignment set name is '||
               assign_set_name ,2);
         END IF;

      END IF;

   END IF;
exception
   when INVALID_MRP_ASSIGNMENT_SET then
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('initialize_assignment_set: ' || 'INITIALIZE_ASSIGNMENT_SET::INVALID ASSIGNMENT SET ::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
        END IF;


   when FND_API.G_EXC_UNEXPECTED_ERROR then
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('initialize_assignment_set: ' || 'INITIALIZE_ASSIGNMENT_SET::unexp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
        END IF;


   when OTHERS then
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('initialize_assignment_set: ' || 'INITIALIZE_ASSIGNMENT_SET::others::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
        END IF;


END initialize_assignment_set ;



/*
** This procedure checks whether a model has been sourced.
** It also checks for circular sourcing and flags an error if it detects one.
** This procedure keeps on chaining sourcing rules till no more sourcing rules exist.
*/


/* Modified by Renga Kannan on 08/21/01 to honor Buy model sourcing also. This changes were replicated from CTOATPIB.pls
   file. The signature of get_model_sourcing_org is changed for this purpose.
*/
PROCEDURE get_model_sourcing_org(
  p_inventory_item_id    NUMBER
, p_organization_id      NUMBER
, p_sourcing_rule_exists out NOCOPY varchar2
, p_sourcing_org         out NOCOPY NUMBER
, p_source_type          out NOCOPY NUMBER   --- Added by Renga Kannan on 08/21/01 for BUY Models
, p_transit_lead_time    out NOCOPY NUMBER
, x_return_status        out NOCOPY varchar2
, x_exp_error_code       out NOCOPY number
, p_line_id              in NUMBER
, p_ship_set_name        in varchar2
)
IS
   v_sourcing_organization_id  	number ;
   v_assignment_type   		number ;
   x_msg_data     		varchar2(2000) ;
   x_msg_count    		number ;
   l_stmt_num     		number ;
   l_error_code   		number ;
   v_organization_id 		number ;
   v_transit_lead_time 		number ;
   v_circular_sourcing 		boolean ;
   v_location          		number := 0 ;
   v_sourcing_rule_exists 	varchar2(1) ;
   CTO_MRP_ASSIGNMENT_SET  	exception;

   TYPE TABNUM is TABLE of NUMBER index by binary_integer ;
   v_orgs_tbl         		TABNUM ;

   --- Added for Buy Model sourcing
   v_source_type       number;

BEGIN
        l_stmt_num :=  1;

        p_sourcing_rule_exists := FND_API.G_FALSE ;
        p_transit_lead_time := 0 ;

        x_return_status := FND_API.G_RET_STS_SUCCESS ;

        v_organization_id := p_organization_id ;
        v_transit_lead_time := 0 ;
        v_circular_sourcing := FALSE ;
        v_orgs_tbl.delete ; /* reinitialize table to check circular sourcing */


        l_stmt_num := 10 ;

        <<OUTER>>
        while( TRUE )
        LOOP


           l_stmt_num := 20 ;

           /*
           ** check whether the current org exists in the orgs array
           */
           for i in 1..v_orgs_tbl.count
           loop
              if( v_orgs_tbl(i) = v_organization_id )
              then
                 v_circular_sourcing := TRUE ;
                 v_location := i ;
                 exit OUTER ;
              end if ;
           end loop ;

           v_orgs_tbl(v_orgs_tbl.count + 1 ) := v_organization_id ;

           l_stmt_num := 30 ;


           query_sourcing_org(
                p_inventory_item_id
              , v_organization_id
              , v_sourcing_rule_exists
              , v_source_type              -- Added by Renga for BUY MODEL
              , v_sourcing_organization_id
              , v_transit_lead_time
              , x_exp_error_code
              , x_return_status
           ) ;


           l_stmt_num := 40 ;

           IF x_return_status = FND_API.G_RET_STS_ERROR
           THEN

                   RAISE FND_API.G_EXC_ERROR;
           ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
           THEN

                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

           /* The following block is added by Renga Kannan on 08/21/01. This change is done as
              Part of BUY Model sourcing changes. The source type is being returned from
              query_sourcing_org is passed back to the calling application.
           */

           p_source_type  := v_source_type;

           IF (v_source_type = '3') THEN  --- If it is buy sourcing
             -- If the sourcing is of buy model we should not go in chain
             -- further. This will return the source_type to the calling
             -- application. The calling application will check the source_type
             -- and takes action based on that.
             p_sourcing_rule_exists := 'T' ;
             exit;
           ELSE

             if( FND_API.to_boolean( v_sourcing_rule_exists )  ) then
               p_sourcing_rule_exists := 'T' ;
             else
               exit ; /* always exit when no more sourcing rules to cascade */
             end if ;
            END IF;

           l_stmt_num := 50 ;

           /* set the query organization id to current sourcing organization to
           ** cascade sourcing rules.
           ** e.g.  M1 <- D1 , D1 <- M2  =>  M1 <- M2
           */
           v_organization_id := v_sourcing_organization_id ;

           /*
           ** please check with usha about adding lead times??.
           */
           p_transit_lead_time := p_transit_lead_time + v_transit_lead_time ;

        END LOOP OUTER ;

        l_stmt_num := 60 ;

        if( v_circular_sourcing )
        then
           x_exp_error_code := 66 ;
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('get_model_sourcing_org: ' ||  ' circular sourcing problem ' , 1 );
           END IF;

           --bugfix 2813271: Added message to show the user
           cto_msg_pub.cto_message('BOM','CTO_INVALID_SOURCING'); -- bugfix 2813271
           RAISE FND_API.G_EXC_ERROR;

        end if ;

        p_sourcing_org := v_organization_id ;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('get_model_sourcing_org: ' || 'sourcing org is ' || p_sourcing_org || ' lead time ' || to_char( p_transit_lead_time ) , 1 );
        END IF;

exception
   when FND_API.G_EXC_ERROR then
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('get_model_sourcing_org: ' || 'GET_MODEL_SOURCING_ORG::exp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;

        CTO_MSG_PUB.Count_And_Get(
          p_msg_count => x_msg_count
        , p_msg_data  => x_msg_data
        );

   when FND_API.G_EXC_UNEXPECTED_ERROR then
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('get_model_sourcing_org: ' || 'GET_MODEL_SOURCING_ORG::unexp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        CTO_MSG_PUB.Count_And_Get(
          p_msg_count => x_msg_count
        , p_msg_data  => x_msg_data
        );

   when OTHERS then
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('get_model_sourcing_org: ' || 'GET_MODEL_SOURCING_ORG::others::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MSG_PUB.Add_Exc_Msg(
             G_PKG_NAME
           , 'GET_MODEL_SOURCING_ORG'
           );
        END IF;

end get_model_sourcing_org ;


-- bugfix 1811007 begin
-- Added a new function convert_uom

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
                                  	  5,                      -- bugfix 2204376: pass precision of 5
                                          quantity,
                                          from_uom,
                                          to_uom,
                                          NULL,
                                          NULL);

     -- hard-coded value that means undefined conversion
     --  For example, conversion of FT2 to FT3 doesn't make sense...
     -- Reset the result to 0 to preserve compatibility before
     -- the bug fix made above (namely, always call inv_um_convert).

     /*Commenting as part of bugfix 9214765
     if result = -99999 then
        result := 0;
     end if;
     */

  END IF;
  RETURN result;

 END convert_uom;

-- bugfix 1811007 end



 --bugfix 1799874 begin
 FUNCTION get_source_document_id (pLineId in number) RETURN NUMBER
 IS
	  l_source_document_type_id  number;
 BEGIN

          IF PG_DEBUG <> 0 THEN
          	oe_debug_pub.add('get_source_document_id: ' || 'CTOUTILB: get_source_document_id: Fetching the source document type id', 1);
          END IF;

	  select h.source_document_type_id
	  into   l_source_document_type_id
	  from   oe_order_headers_all h, oe_order_lines_all l
	  where  h.header_id =  l.header_id
	  and    l.line_id = pLineId
	  and    rownum = 1;

          IF PG_DEBUG <> 0 THEN
          	oe_debug_pub.add('get_source_document_id: ' || 'CTOUTILB: get_source_document_id: source document type id = '||l_source_document_type_id, 1);
          END IF;

	  return (l_source_document_type_id);

 END get_source_document_id;
 --bugfix 1799874 end



 --begin bugfix 2001824
 FUNCTION check_rsv_quantity (p_order_line_id  IN NUMBER,
			      p_rsv_quantity   IN NUMBER)
 RETURN BOOLEAN is

	l_source_document_type_id  	number;
	allowed_unreservation_qty  	number := 0;
	l_shipped_qty			number := 0;
	l_reservation_qty		number := 0;

 BEGIN

	if ( nvl(p_rsv_quantity, 0) = 0 ) then
		return TRUE;
	end if;


	--
	-- Bugfix 2109503
	--
	-- We should consider only CLOSED lines since STAGED lines can be unreserved.
	-- For eg. if you have qty 10 as staged (after completing full w/o and p/r),
	-- ship-confirm 8 (close delivery) will trigger unreservation of 2
	--
	-- If shipping_interface_flag is 'N', consider ordered_quantity as unshipped_quantity.
	--

	--
	-- The latest changes to this piece of the code done on Mar 20th, 2002
	-- Earlier, we used to calculate the total allowed quantity to be unreserved by
	-- checking how much has NOT been shipped (the unshipped_quantity). This was done
	-- by checking the released_status <> 'C'. If the line didn't reach shipping, then,
	-- the ordered_quantity was the qty which could be unreserved.
	--

	--
	-- Bugfix 2276326:
	-- For Over completions, this will fail since WIP can reserve more than the ordered qty
	-- (if within tolerance)
	-- WIP first updates the existing wip-reservation to the overcompleted-qty and then
	-- calls INV to do the transfer. INV transfers the new qty from wip to inv.
	-- for eg., if workorder qty=10, and you overcomplete 15, then, wip reservation is first
	-- updated to 15, and inv then transfers this to inv reservation.

	-- In this scenerio, since the new qty is more than the sales order qty, CTO was preventing
	-- an unreserve activity. With this fix, CTO will check wrt reservation qty and decide whether
	-- to allow unreservation or not.
	--

	l_source_document_type_id := CTO_UTILITY_PK.get_source_document_id ( pLineId => p_order_line_id );


	--
	--  Get the total shipped qty for this line.
	--

        -- Bugfix 2426866 :  If inventory interface is run, the reservations will be releived.
	-- We should not consider the qty which has been interfaced to inventory. Otherwise,
	-- the allowed_unreservation_qty will be incorrectly calculated.
	-- l_Shipped_qty is the qty shipped but NOT interfaced to inventory.


        -- Modified by Renga Kannan on 06/11/02 added nvl fun.
        -- Removed the exception

	-- Bugfix 2638216 : added LEAST fn. in case of over-shipping after discussion with Usha and Vidyesh.

	   select nvl(sum( LEAST(nvl(wdd.shipped_quantity,0), nvl(wdd.picked_quantity,0)) ), 0)
	   into   l_shipped_qty
	   from   wsh_delivery_details_ob_grp_v wdd -- Modified by Renga on 11/02/03
	   where  wdd.source_line_id = p_order_line_id
	   and    wdd.source_code = 'OE'
	   and    wdd.released_status = 'C'		-- Closed [C]
	   and    nvl(wdd.inv_interfaced_flag, 'N') <> 'Y';



	--
	--  Get the total reservations for this line.
	--

        -- Modified by Renga Kannan on 06/11/02 added nvl fun.
        -- Removed the exception

	   select nvl(sum(mr.primary_reservation_quantity),0)
	   into   l_reservation_qty
	   from   mtl_reservations mr
	   where  mr.demand_source_type_id = decode (l_source_document_type_id, 10,
                                                  inv_reservation_global.g_source_type_internal_ord,
                                                  inv_reservation_global.g_source_type_oe )
           and    mr.primary_reservation_quantity > 0
           and    mr.demand_source_line_id = p_order_line_id;



	--
	--  The total allowed qty which can be unreserved is :
	--  total existing reservations minus total shipped qty.
	--

	allowed_unreservation_qty := nvl(l_reservation_qty,0) - nvl(l_shipped_qty,0);

        If PG_DEBUG <> 0 Then
    	CTO_WIP_WORKFLOW_API_PK.cto_debug('check_rsv_qty', 'l_shipped_qty = '||l_shipped_qty);
    	CTO_WIP_WORKFLOW_API_PK.cto_debug('check_rsv_qty', 'l_reservation_qty = '||l_reservation_qty);
    	CTO_WIP_WORKFLOW_API_PK.cto_debug('check_rsv_qty', 'allowed_unreservation_qty = '||allowed_unreservation_qty);
        End if;

    	IF PG_DEBUG <> 0 THEN
    		oe_debug_pub.add('check_rsv_quantity: ' || 'check_rsv_qty: l_shipped_qty = '||l_shipped_qty ||
    			 ' l_reservation_qty = '||l_reservation_qty ||
    	                 ' allowed_unreservation_qty = '||allowed_unreservation_qty, 2);
    	END IF;

	--
	-- p_rsv_quantity is the qty (in primary uom) which inv will pass us. INV is trying to unreserve this qty.
	-- If this qty is greater than the allowed unreservation qty, don't allow.
	--

	if ( p_rsv_quantity > allowed_unreservation_qty)
	then
		return FALSE;
	else
		return TRUE;
	end if;

 EXCEPTION

	when others then
           	IF PG_DEBUG <> 0 THEN
           		oe_debug_pub.add ('check_rsv_quantity: ' || 'OTHERS excpn while checking for unreserved qty :' ||substr(sqlerrm,1,150));
           	END IF;
  		raise FND_API.G_EXC_UNEXPECTED_ERROR;

 END CHECK_RSV_QUANTITY;
 -- end bugfix 2001824



FUNCTION get_cto_item_attachment(p_item_id in number,
		                 p_po_val_org_id in number,
				 x_return_status out nocopy varchar2)
RETURN clob IS

l_clob_loc          clob;
l_blob_loc          blob;
l_input_offset      BINARY_INTEGER;
l_lob_length        BINARY_INTEGER;
l_cur_chunk_size    NUMBER;
l_chunk_size        NUMBER := 30000;
l_buf_raw           RAW(32767);
l_buffer            VARCHAR2(32767);

BEGIN

x_return_status := fnd_api.g_ret_sts_success;

-- get the file attachment locator (blob)
select fl.file_data into l_blob_loc
from fnd_lobs fl, fnd_attached_documents fad, fnd_documents_tl fdt
where fad.pk1_value = to_char(p_po_val_org_id)
and fad.pk2_value = to_char(p_item_id)
and fad.entity_name = 'MTL_SYSTEM_ITEMS'
and fad.pk3_value = 'CTO:BOM:ATTACHMENT'
and fad.document_id = fdt.document_id
and fdt.media_id = fl.file_id
and fdt.language = userenv('LANG');

if l_blob_loc is null then
   x_return_status := fnd_api.g_ret_sts_error;
   oe_debug_pub.add('get_cto_item_attachment: ' || 'File attachment is null. Nothing to convert to clob... returning null', 1);
   return null;
end if;

l_lob_length := dbms_lob.getlength(l_blob_loc);
l_input_offset := 1;

DBMS_LOB.CREATETEMPORARY(l_clob_loc, TRUE, DBMS_LOB.SESSION);
DBMS_LOB.OPEN (l_clob_loc, DBMS_LOB.LOB_READWRITE);

-- Loop through the blob, and convert and copy to clob in smaller chunks.

LOOP
   -- Exit the loop when all the chunks are copied, indicated by
   -- l_input_offset passing l_lob_length.
   EXIT WHEN l_input_offset > l_lob_length;

   -- If at least l_chunk_size remains in the blob, copy that
   -- much.  Otherwise, copy only however much remains.
   IF (l_lob_length - l_input_offset + 1) > l_chunk_size THEN
      l_cur_chunk_size := l_chunk_size;
   ELSE
      l_cur_chunk_size := l_lob_length - l_input_offset + 1;
   END IF;

   dbms_lob.read(l_blob_loc, l_cur_chunk_size, l_input_offset, l_buf_raw);

   l_buffer := utl_raw.cast_to_varchar2(l_buf_raw);

   -- Write the current chunk.
   DBMS_LOB.writeappend(l_clob_loc, length(l_buffer), l_buffer);

   -- Increment the input offset by the current chunk size.
   l_input_offset := l_input_offset + l_cur_chunk_size;

END LOOP;

DBMS_LOB.CLOSE (l_clob_loc);

return l_clob_loc;

Exception

when no_data_found then
   x_return_status := fnd_api.g_ret_sts_error;
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('get_cto_item_attachment: ' || 'no file attachment existsfor given item and org', 1);
   END IF;
   return null;

when others then
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('get_cto_item_attachment: ' || 'When others exception ..' || sqlerrm, 1);
   END IF;
   return null;

END get_cto_item_attachment;



-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
 --- The following procedure is added by Renga Kannan on 08/24/01 to add attachment to an item
 --- I will add enough comments later for this procedure


   PROCEDURE create_attachment(
                               p_item_id        IN mtl_system_items.inventory_item_id%type,
                               p_org_id         IN mtl_system_items.organization_id%type,
                               p_text           IN Long,
                               p_desc           IN varchar2,
                               p_doc_type       IN Varchar2,
                               x_return_status  OUT NOCOPY varchar2) as

   l_doc_id                Number;
   l_media_id              Number;
   l_doc_text              Long;
   l_seq_num               Number;
   l_attached_document_id  Number;
   l_row_id                Varchar2(1000);
   l_stmt                  Number;

   BEGIN
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   l_stmt := 10;
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('create_attachment: ' || 'Entering Create_attachment...',1);

   	oe_debug_pub.add('create_attachment: ' || 'Attachment desc = '||p_desc,1);
   END IF;

   -- The following FND API will create a document with the given Text information.

   -- Creating a long text document using text

   fnd_documents_pkg.insert_row(
                  x_rowid                  => l_row_id,
                  x_document_id            => l_doc_id,
                  x_creation_date          => sysdate,
                  x_created_by             => fnd_global.USER_ID,
                  x_last_update_date       => sysdate,
                  x_last_updated_by        => fnd_global.USER_ID,
                  x_last_update_login      => fnd_global.USER_ID,
                  x_request_id             => fnd_global.USER_ID,
                  x_program_application_id => fnd_global.PROG_APPL_ID,
                  x_program_id             => fnd_global.CONC_REQUEST_ID,
                  x_program_update_date    => sysdate,
                  x_datatype_id            => 2,
                  x_category_id            => 33,
                  x_security_type          => 4,
                  x_security_id            => NULL
                  ,x_publish_flag          => 'Y'
                  ,x_image_type            => null
                  ,x_storage_type          => null
                  ,x_usage_type            => 'S'
                  ,x_start_date_active     => sysdate
                  ,x_end_date_active       => null
                  ,x_language              => 'AMERICAN'
                  ,x_description           => p_desc
                  ,x_file_name             => null
                  ,x_media_id              => l_media_id
                  ,x_attribute_category    => null
                  ,x_attribute1            => null
                  ,x_attribute2   => null
                  ,x_attribute3   => null
                  ,x_attribute4   => null
                  ,x_attribute5   => null
                  ,x_attribute6   => null
                  ,x_attribute7   => null
                  ,x_attribute8   => null
                  ,x_attribute9   => null
                  ,x_attribute10  => null
                  ,x_attribute11  => null
                  ,x_attribute12  => null
                  ,x_attribute13  => null
                  ,x_attribute14  => null
                  ,x_attribute15  => null
		  --Bugfix 10014847: Adding the attachment title
		  ,x_title        => p_desc);


           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('create_attachment: ' || 'The document is created with the following id....'||to_char(l_doc_id),1);

           	oe_debug_pub.add('create_attachment: ' || 'Media id ...'||to_char(l_media_id),1);
           END IF;

    -- The following insert is inserting into the media and text infor into fnd_documents_long_text

    l_stmt := 20;

    Insert into fnd_documents_long_text
               (
                 Media_id,
                 long_text)
           Values
               ( l_media_id,p_text);



   -- Get the sequence no for attachment

    l_stmt := 30;

    select (nvl(max(seq_num),0) + 10)
    into l_seq_num
    from fnd_attached_documents
    where entity_name = 'MTL_SYSTEM_ITEMS'
    and pk1_value =  to_char(p_org_id)		-- 2774570
    and pk2_value = to_char(p_item_id);         -- 6069512: Added to improve performance, we do not need seq to be unique across items.


    l_stmt := 40;
    select fnd_attached_documents_s.nextval
    into l_attached_document_id
    from dual;

    l_stmt := 50;

    FND_ATTACHED_DOCUMENTS_PKG.INSERT_ROW
		(x_rowid			=> l_row_id
		, x_attached_document_id	=> l_attached_document_id
		, x_document_id			=> l_doc_id
		, x_seq_num			=> l_seq_num
		, x_entity_name			=> 'MTL_SYSTEM_ITEMS'
		, x_pk1_value			=> p_org_id
		, x_pk2_value			=> p_item_id
		, x_pk3_value			=> p_doc_type  -- This field is used for procuring config
		, x_pk4_value			=> NULL
		, x_pk5_value			=> NULL
		, x_automatically_added_flag	=> 'N'
		, x_creation_date		=> sysdate
		, x_created_by			=> fnd_global.USER_ID
		, x_last_update_date		=> sysdate
		, x_last_updated_by		=> fnd_global.USER_ID
		, x_last_update_login		=> fnd_global.LOGIN_ID
		-- following parameters are required for the API but we do not
		-- use so send in as null
		, x_column1			=> null
		, x_datatype_id			=> null
		, x_category_id			=> null
		, x_security_type		=> null
		, X_security_id			=> null
		, X_publish_flag		=> null
		, X_image_type			=> null
		, X_storage_type		=> null
		, X_usage_type			=> null
		, X_language			=> null
		, X_description			=> null
		, X_file_name			=> null
		, X_media_id			=> l_media_id
		, X_doc_attribute_Category      => null
		, X_doc_attribute1		=> null
		, X_doc_attribute2		=> null
		, X_doc_attribute3		=> null
		, X_doc_attribute4		=> null
		, X_doc_attribute5		=> null
		, X_doc_attribute6		=> null
		, X_doc_attribute7		=> null
		, X_doc_attribute8		=> null
		, X_doc_attribute9		=> null
		, X_doc_attribute10		=> null
		, X_doc_attribute11		=> null
		, X_doc_attribute12		=> null
		, X_doc_attribute13		=> null
		, X_doc_attribute14		=> null
		, X_doc_attribute15		=> null
		);



   EXCEPTION

        when FND_API.G_EXC_UNEXPECTED_ERROR then
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('create_attachment: ' || 'Create_attachment::unexp error::'||l_Stmt||'::'||sqlerrm,1);
                END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        when FND_API.G_EXC_ERROR then
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('create_attachment: ' || 'Create_attachment::exp error::'||l_Stmt||'::'||sqlerrm,1);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

        when others then
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('create_attachment: ' || 'Create_attachment::OTHERS error::'||l_Stmt||'::'||sqlerrm,1);
                END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


   END create_attachment;



/*********************************************************************************************************
**********************************************************************************************************

           Procedure Name : Generate_Bom_attachment_text
            Input          : inventory_item_id and Organization_id

           Output         : Attachment text

           Purpose        : This procedure is generating the bom attachment for the given inventory_item_id
                            in the given organization id. This text will be used to attachment text for
                            config item in PO validation organization.

*********************************************************************************************************
*********************************************************************************************************/


 PROCEDURE  GENERATE_BOM_ATTACH_TEXT
                                   (p_line_id             bom_cto_src_orgs.line_id%type,
                                    x_text        in out NOCOPY long,
                                    x_return_status  out NOCOPY varchar2
                                    ) is


   --to get the Bom of procured configuration in correct hierarchy
   cursor components is
  	select  level,
 		bcol.inventory_item_id inventory_item_id,
		bcol.ordered_quantity        ordered_qty,
		bcol.ship_from_org_id        ship_from_org_id
	from	bom_cto_order_lines bcol
        start   with line_id = p_line_id
	connect by link_to_line_id = prior line_id;


	l_desc		Mtl_system_items_kfv.description%type;
        l_prim_uom      Mtl_system_items_kfv.primary_uom_code%type;
        l_loop_switch   Boolean := TRUE;
	l_item_name     Mtl_system_items_kfv.concatenated_segments%type;
	l_model_ord_qty Number;


        l_new_line   varchar2(10) := fnd_global.newline;
        l_hdr_text   varchar2(1000);
        l_temp_text  varchar2(1000);
        --l_form_feed  varchar2(100) := FND_GLOBAL.local_chr(12);  Bugfix 6116881
        l_space      varchar2(10) := fnd_global.local_chr(32);

        l_page_size  Number        := 15;
        l_stmt       Number;
        l_line_count Number        := 0;

        l_level_width number := 5;
        l_qty_width number := 12;
        l_uom_width number := 8;
        l_item_width number := 25;
        l_desc_width number := 25;

        --
        -- bug 6717456
        -- ntungare
        --
        l_test_text     long;
        text_too_long   EXCEPTION;

        PRAGMA EXCEPTION_INIT(text_too_long, -06502);

begin

IF PG_DEBUG <> 0 THEN
	oe_debug_pub.add('GENERATE_BOM_ATTACH_TEXT: ' || 'Entering GENERATE_BOM_ATTACH_TEXT',1);

	oe_debug_pub.add('GENERATE_BOM_ATTACH_TEXT: ' || 'line_id =>'||p_line_id,1);
END IF;


x_return_status :=  FND_API.G_RET_STS_SUCCESS;

l_stmt  := 10;

-- rkaza. 02/06/2006. bug 4938433. FP for bug 4506153:
-- Adjusted length of the fields to ensure printing allignment. PO has a hard
-- limit of 76 characters while printing the attach text which CTO must honour.
-- The new lengths are
-- Level - 5
-- Qty - 12
-- UOM - 8
-- item name - 25
-- Description - 25
-- Between any two fields there will be one additional space character.
-- This makes for total 71 + 4 = 75

-- Previously lenghts were adjusted thru trial and error (using tab texts) such
-- that data belonging to a column appears more or less under that column
-- header within a reasonable range in forms.
-- Now it was decided to go with the new format as described above. It
-- prints correctly. But it may not look good in forms because of variable
-- versus fixed font issue.


--for text attachmnet header
l_hdr_text := l_new_line
              || 'Level' || l_space
              || rpad('QTY', l_qty_width, l_space) || l_space
              || rpad('UOM', l_uom_width, l_space) || l_space
              || rpad('Item#', l_item_width, l_space) || l_space
              || 'Description'
              || l_new_line;



l_hdr_text := concat(l_hdr_text,rpad(' ', 75, '-')|| l_new_line || l_new_line);

	-- NEW CODE WITH BCOL APPROACH

	l_stmt := 20;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('GENERATE_BOM_ATTACH_TEXT: ' || 'before starting the loop (inorder to get bcol lines)',1);
        END IF;
        for comp_cur in components

        loop
                --To get ration of model to component quantity
		if l_loop_switch then
			l_model_ord_qty := comp_cur.ordered_qty;
			l_loop_switch := false;
                       IF PG_DEBUG <> 0 THEN
                       	oe_debug_pub.add('GENERATE_BOM_ATTACH_TEXT: ' || 'in IF block of loop_siwtch,model_ord_qty=>l_model_ord_qty',1);
                       END IF;
		end if;

                --for text attachment
   		if nvl(l_line_count,0) = l_page_size then
     			--x_text := x_text||l_form_feed;  Bugfix 6116881
                        --
                        -- bug 6717456
                        -- ntungare
                        --
     			--x_text := concat(x_text,l_hdr_text);
                        l_test_text := concat(l_test_text,l_hdr_text);
     			l_line_count := 0;
                        IF PG_DEBUG <> 0 THEN
                        	oe_debug_pub.add('GENERATE_BOM_ATTACH_TEXT: ' || 'should start on new line as l_line_count = 15',1);
                        END IF;
   		elsif nvl(l_line_count,0) = 0 then
                        --
                        -- bug 6717456
                        -- ntungare
                        --
     			--x_text := concat(x_text,l_hdr_text);
                        l_test_text := concat(l_test_text,l_hdr_text);
                        IF PG_DEBUG <> 0 THEN
                        	oe_debug_pub.add('GENERATE_BOM_ATTACH_TEXT: ' || 'adding header text as l_line_count = 0',1);
                        END IF;
   		end if;



               --to get the item details from mtl_system_items
		select msi.description,
		       msi.primary_uom_code,
		       msi.concatenated_segments
		into   l_desc,
		       l_prim_uom,
		       l_item_name
		from   mtl_system_items_kfv msi
		where  msi.inventory_item_id = comp_cur.inventory_item_id
		and    msi.organization_id   = comp_cur.ship_from_org_id;

                --for text attachment
                --
                -- bug 6717456
                -- Introduced this new variable so that if text_too_long exception occurs,
                -- a full line goes in the attachment
                -- ntungare
                --
                /*
		x_text :=
                   concat(nvl(x_text, ''), rpad(comp_cur.level-1, l_level_width, l_space) ||
                   l_space ||
                   rpad(round(comp_cur.ordered_qty/l_model_ord_qty,7), l_qty_width, l_space) ||
                   l_space ||
                   rpad(l_prim_uom, l_uom_width, l_space) ||
                   l_space ||
                   rpad(substr(l_item_name, 1, l_item_width), l_item_width, l_space) ||
                   l_space ||
                   rpad(substr(l_desc, 1, l_desc_width), l_desc_width, l_space) ||
                   l_new_line);	*/

                l_stmt := 40;

                l_test_text :=
                   concat(nvl(l_test_text, ''), rpad(comp_cur.level-1, l_level_width, l_space) ||
                   l_space ||
                   rpad(round(comp_cur.ordered_qty/l_model_ord_qty,7), l_qty_width, l_space) ||
                   l_space ||
                   rpad(l_prim_uom, l_uom_width, l_space) ||
                   l_space ||
                   rpad(substr(l_item_name, 1, l_item_width), l_item_width, l_space) ||
                   l_space ||
                   rpad(substr(l_desc, 1, l_desc_width), l_desc_width, l_space) ||
                   l_new_line);

                x_text := l_test_text;

		l_line_count := nvl(l_line_count,0) + 1;
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('GENERATE_BOM_ATTACH_TEXT: ' || 'value of l_line_count'||l_line_count,4);
                END IF;


	end loop;

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('GENERATE_BOM_ATTACH_TEXT: ' || 'End of LOOP in generate BOM attachment',1);
	END IF;


EXCEPTION

     when FND_API.G_EXC_UNEXPECTED_ERROR then
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('GENERATE_BOM_ATTACH_TEXT: ' || 'GENERATE_BOM_ATTACH_TEXT::unexp error::'||l_Stmt||sqlerrm,1);
             END IF;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     when FND_API.G_EXC_ERROR then
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('GENERATE_BOM_ATTACH_TEXT: ' || 'GENERATE_BOM_ATTACH_TEXT::exp error::'||l_Stmt||sqlerrm,1);
             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;

     --
     -- bug 6717456
     -- ntungare
     --
     when text_too_long THEN
             IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('GENERATE_BOM_ATTACH_TEXT: ' || 'GENERATE_BOM_ATTACH_TEXT::text too long exception::'||l_Stmt||sqlerrm,1);
                oe_debug_pub.add('GENERATE_BOM_ATTACH_TEXT: ' || 'GENERATE_BOM_ATTACH_TEXT::text too long exception:: continuing..',1);
             END IF;

     when others then
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('GENERATE_BOM_ATTACH_TEXT: ' || 'GENERATE_BOM_ATTACH_TEXT::OTHERS error::'||l_Stmt||sqlerrm,1);
             END IF;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END GENERATE_BOM_ATTACH_TEXT;



FUNCTION CHECK_CONFIG_ITEM(
                           p_parent_item_id     IN Mtl_system_items.inventory_item_id%type,
                           p_inventory_item_id  IN Mtl_system_items.inventory_item_id%type,
                           p_organization_id    IN Mtl_system_items.organization_id%type) RETURN Varchar2 Is

l_found          varchar2(1) := 'N';
l_model_item_id  Mtl_system_items.inventory_item_id%type;

BEGIN

   /* Select the base model_item_id from the parent. Then compare the given inventory_item with the first
      level bill of parent model. If you get a match it is ato item. If we cannot get a match it is config item
   */

   SELECT base_item_id
   INTO   l_model_item_id
   FROM   MTL_SYSTEM_ITEMS
   WHERE  Inventory_item_id = p_parent_item_id
   AND    organization_id   = p_organization_id;

   BEGIN
      SELECT 'Y'
      INTO   l_found
      FROM   BOM_INVENTORY_COMPONENTS BIC,
             BOM_BILL_OF_MATERIALS BOM
      WHERE  BIC.bill_sequence_id  = BOM.Common_bill_sequence_id
      AND    BOM.assembly_item_id  = l_model_item_id
      AND    BOM.Organization_id   = p_organization_id
      AND    BIC.component_item_id = p_inventory_item_id;
      return l_found;
   EXCEPTION WHEN NO_DATA_FOUND THEN
      return 'N';
   END;
END CHECK_CONFIG_ITEM;


/*---------------------------------------------------------------------------------------------
Procedure : chk_all_rsv_details --bugfix 2327972
Description: This procedure gets the different types of reservation done on a line_id (item)
             When a reservation exists,It returns success and reservation qunatity, reservation id and type of              supply are stored in table of records.
Input:  p_line_Id        in         --line_id
        p_rsv_details    out        --table of records
        x_msg_count      out
        x_msg_data       out
        x_return_status  out        -returns 'S' if reservation exists
                                    --returns 'F' if there is no reservation

-------------------------------------------------------------------------------------------*/


Procedure chk_all_rsv_details
(
         p_line_Id          in     number    ,
         p_rsv_details   out NOCOPY t_resv_details,
         x_msg_count     out NOCOPY number  ,
         x_msg_data      out NOCOPY varchar2,
         x_return_status out NOCOPY varchar2
)
is




l_reservation_id           Number;
l_reservation_quantity     Number;
l_supply_source_type_id    Number;


l_index NUMBER;
l_stmt  Number;


CURSOR c_rsv_details IS
select reservation_id,reservation_quantity,supply_source_type_id
    from   mtl_reservations     mr,
           oe_order_lines_all   oel,
           oe_order_headers_all oeh,
           oe_transaction_types_all ota,
           oe_transaction_types_tl  otl,
           mtl_sales_orders     mso
    where  mr.demand_source_line_id = oel.line_id    --ato item line id
    and    oel.line_id              = p_line_Id
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
    and    mr.reservation_quantity  > 0;



BEGIN

  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('chk_all_rsv_details: ' || 'Entered CTO_UTILITY_PK.chk_all_rsv_details',1);
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  l_stmt := 111;
  OPEN c_rsv_details;
   LOOP

       FETCH c_rsv_details into l_reservation_id,
                                l_reservation_quantity,
                                l_supply_source_type_id;
        	EXIT WHEN c_rsv_details%NOTFOUND;

       l_stmt := 211;
       IF ( p_rsv_details.count=0 ) THEN
            p_rsv_details(1).l_reservation_id        :=  l_reservation_id;
            p_rsv_details(1).l_reservation_quantity  :=  l_reservation_quantity;
            p_rsv_details(1).l_supply_source_type_id :=  l_supply_source_type_id;
       ELSE
           p_rsv_details( p_rsv_details.LAST+1).l_reservation_id       :=  l_reservation_id;
           p_rsv_details(p_rsv_details.LAST).l_reservation_quantity  :=  l_reservation_quantity;
           p_rsv_details(p_rsv_details.LAST).l_supply_source_type_id :=  l_supply_source_type_id;
       END IF;

   END LOOP;
   CLOSE c_rsv_details;

    l_stmt := 311;
    IF (p_rsv_details.count>0) THEN
       l_index := p_rsv_details.FIRST;
       LOOP
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('chk_all_rsv_details: ' || 'rsv id '||p_rsv_details(l_index).l_reservation_id,5);

            	oe_debug_pub.add('chk_all_rsv_details: ' || 'rsv qty '||p_rsv_details(l_index).l_reservation_quantity,5);

            	oe_debug_pub.add('chk_all_rsv_details: ' || 'suppy sourc '||p_rsv_details(l_index).l_supply_source_type_id,5);
            END IF;

            	 EXIT WHEN l_index = p_rsv_details.LAST;
            l_index := p_rsv_details.NEXT(l_index);
        END LOOP;
        x_return_status := FND_API.G_RET_STS_SUCCESS;--resv exists
    ELSE
        --no reservation exists
        x_return_status := FND_API.G_FALSE;

    END IF;






EXCEPTION
      when others then
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add ('chk_all_rsv_details: ' || 'unexpected error in called program chk_all_rsv_details'|| l_stmt||sqlerrm , 1);
              END IF;
              if fnd_msg_pub.check_msg_level
                  (fnd_msg_pub.g_msg_lvl_unexp_error)
              then
                  fnd_msg_pub.Add_Exc_msg
                   ( 'CTO_WORKFLOW',
                     'chk_all_rsv_details'
                    );
              end if;
              cto_msg_pub.count_and_get
                (
                   p_msg_count=>x_msg_count,
                   p_msg_data=>x_msg_data
                 );
END  chk_all_rsv_details;



/*
** Note: This procedure itentifies whether a Model is Multi-Level.
** The bill_sequence_id passed as a parameter should have a valid bill.
** for eg. if the bom is commoned you should be sending the
** common_bill_sequence_id
**
*/
FUNCTION isModelMLMO( p_bill_sequence_id in number )
return number
is

  cursor option_class ( c_bill_sequence_id  in number )
  is
        select component_item_id
             , component_sequence_id
             , bom_item_type
          from bom_inventory_components
         where bill_sequence_id = c_bill_sequence_id
           and ( bom_item_type = '2' OR
                 ( bom_item_type = '1' and nvl( wip_supply_type , 6 ) <> 6 )
                 /* check only non phantom models and option classes */
               ) ;

v_model_count number ;
v_organization_id number ;
v_assembly_item_id number ;
v_return_status number ;
v_component_item_id number ;
v_component_sequence_id number ;
v_element_bill_seq_id number ;

v_bom_item_type     bom_inventory_components.bom_item_type%type;
v_stmt_number number := -1 ;

x_sourcing_rule_exists varchar2(2) ;
x_new_org              number ;
x_source_type          number ;
x_transit_lead_time    number ;
x_return_status        varchar2(10) ;
x_exp_error_code       number ;

begin


           /* check whether base model is multilevel */





           select organization_id
                , assembly_item_id
             into v_organization_id
                , v_assembly_item_id
             from bom_bill_of_materials
            where bill_sequence_id = p_bill_sequence_id ;


           v_stmt_number := -4 ;



             get_model_sourcing_org(
                              v_assembly_item_id
                            , v_organization_id
                            , x_sourcing_rule_exists
                            , x_new_org
                            , x_source_type
                            , x_transit_lead_time
                            , x_return_status
                            , x_exp_error_code
                            , null
                            , null
                           ) ;

             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('isModelMLMO: ' ||  ' after get model source status ' || x_return_status, 4 );
             END IF;


             IF x_return_status = FND_API.G_RET_STS_ERROR
             THEN

                   RAISE FND_API.G_EXC_ERROR;
             ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
             THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;


             if( FND_API.to_boolean( x_sourcing_rule_exists )  ) then
                 return 1;
             end if ;


             v_stmt_number := -6 ;

             open option_class( p_bill_sequence_id ) ;

             loop

                   fetch option_class into v_component_item_id
                                        , v_component_sequence_id , v_bom_item_type ;

                   exit when option_class%notfound ;


                   if( v_bom_item_type = 1 ) then
                       return 1 ;
                   end if ;




                   v_stmt_number := -8 ;

                   select common_bill_sequence_id
                    into v_element_bill_seq_id
                    from bom_bill_of_materials
                   where assembly_item_id = v_component_item_id
                     and organization_id = v_organization_id ;


                  v_stmt_number := -10 ;

                  v_return_status := isModelMLMO( v_element_bill_seq_id ) ;


                  if( v_return_status = 1 ) then
                      return 1 ;
                  end if ;

             end loop ;




    return 0 ;


exception
when others then

    return v_stmt_number ;

end isModelMLMO;

/*----------------------------------------------------------------------+
This function recursively explodes a configuration item BOM and inserts
it into bom_explosion_temp with a unique group_id. It is called while
displaying the configuration BOM from iSupplierPortal.
+----------------------------------------------------------------------*/

FUNCTION create_isp_bom
(
p_item_id IN number,
p_org_id IN number)
RETURN NUMBER IS

xGrpId	number;
rowcount number;
l_sort number := 0;

BEGIN

        If PG_DEBUG <> 0 Then
	cto_wip_workflow_api_pk.cto_debug('create_isp_bom', 'entering');
        End if;

    	select bom_explosion_temp_s.nextval
    	into   xGrpId
    	from dual;

        If PG_DEBUG <> 0 Then
	cto_wip_workflow_api_pk.cto_debug('create_isp_bom', 'xGrpId::'||to_char(xGrpId));
	cto_wip_workflow_api_pk.cto_debug('create_isp_bom', 'ItemId::'||to_char(p_item_id));
	cto_wip_workflow_api_pk.cto_debug('create_isp_bom', 'OrgId::'||to_char(p_org_id));
        End if;

	-- insert top level config BOM

    	insert into bom_explosion_temp(
        	top_bill_sequence_id,
        	bill_sequence_id,
        	organization_id,
        	sort_order,
        	component_item_id,
		--component_sequence_id,
        	plan_level,
		component_quantity,
		component_code,
		item_num,
        	group_id)
   	select
		bic.bill_sequence_id,
		bic.bill_sequence_id,
		p_org_id,
		to_char(l_sort),
        	bic.component_item_id,
		--bic.component_sequence_id,
		nvl(bic.plan_level, 0),
		bic.component_quantity,
		to_char(bic.bill_sequence_id),
		bic.item_num,
        	xGrpId
   	from
		bom_inventory_components bic,
		bom_bill_of_materials bbom
        where 	bbom.assembly_item_id = p_item_id
	and	bbom.organization_id = p_org_id
	and 	bbom.alternate_bom_designator is null
	and 	bbom.common_bill_sequence_id = bic.bill_sequence_id
	and 	nvl(bic.optional_on_model,1) = 1;

        If PG_DEBUG <> 0 Then
	cto_wip_workflow_api_pk.cto_debug('create_isp_bom', 'rowcount::'||sql%rowcount);
        End if;


        rowcount := 1 ;
        while rowcount > 0 LOOP

	    l_sort := l_sort + 1;

            insert into bom_explosion_temp(
               	top_bill_sequence_id,
               	bill_sequence_id,
               	organization_id,
               	sort_order,
               	component_item_id,
		--component_sequence_id,
               	plan_level,
               	component_quantity,
		component_code,
		item_num,
               	group_id)
           select
		bic.bill_sequence_id,
		bic.bill_sequence_id,
		p_org_id,
		to_char(l_sort),
        	bic.component_item_id,
		--concat(concat(bet.component_sequence_id,'-'),bic.component_sequence_id),
		decode(bic.plan_level,null,(bet.plan_level+1),(bic.plan_level+bet.plan_level)),
		bic.component_quantity,
		CTO_UTILITY_PK.Concat_Values(bet.component_code,bic.bill_sequence_id),
		bic.item_num,
        	xGrpId
           from
                bom_inventory_components bic,
		bom_bill_of_materials bbom,
		bom_explosion_temp bet,
		mtl_system_items msi
           where 	bbom.assembly_item_id = bet.component_item_id
	   and	bbom.organization_id = bet.organization_id
	   and 	bbom.alternate_bom_designator is null
	   and 	bbom.common_bill_sequence_id = bic.bill_sequence_id
	   and 	nvl(bic.optional_on_model,1) = 1
	   and 	bet.group_id = xGrpId
	   and 	bet.sort_order = to_char(l_sort - 1)
	   and 	bet.component_item_id = msi.inventory_item_id
	   and	bet.organization_id = msi.organization_id
	   and	msi.base_item_id is not null
	   and 	nvl(msi.auto_created_config_flag, 'N') = 'Y';


           rowcount := SQL%ROWCOUNT;

           IF PG_DEBUG <> 0 THEN
           oe_debug_pub.add ('Row Count : '   || rowcount, 2);
           END IF;

           If PG_DEBUG <> 0 Then
           cto_wip_workflow_api_pk.cto_debug('create_isp_bom', 'Row Count:'||rowcount);
           End if;

        END LOOP;

	delete from bom_explosion_temp bet
	where bet.group_id = xGrpId
	and bet.component_item_id =
		(select msi.inventory_item_id
		from mtl_system_items msi
		where msi.inventory_item_id = bet.component_item_id
		and msi.organization_id = bet.organization_id
		and msi.base_item_id is not null
	   	and nvl(msi.auto_created_config_flag, 'N') = 'Y');

	rowcount := SQL%ROWCOUNT;
        IF PG_DEBUG <> 0 THEN
	oe_debug_pub.add ('Deleted Row Count : '   || rowcount, 2);
        END IF;

        If PG_DEBUG <> 0 Then
        cto_wip_workflow_api_pk.cto_debug('create_isp_bom', 'Deleted Row Count:'||rowcount);
        End if;

	return xGrpId;

EXCEPTION
WHEN OTHERS THEN
        If PG_DEBUG <> 0 Then
   	cto_wip_workflow_api_pk.cto_debug('create_isp_bom', 'Others exception:'||sqlerrm);
        End if;
	return xGrpId;
END;

FUNCTION concat_values(
p_value1 IN varchar2,
p_value2 IN number)
RETURN Varchar2 IS

p_concat_value Varchar2(2000);
BEGIN

p_concat_value := concat(p_value1, '-');
p_concat_value := concat(p_concat_value, to_char(p_value2));
IF PG_DEBUG <> 0 Then
cto_wip_workflow_api_pk.cto_debug('create_isp_bom', 'Concat segment:'||p_concat_value);
End if;

RETURN p_concat_value;

END;

procedure copy_cost(
                             p_src_cost_type_id   number
                           , p_dest_cost_type_id   number
                           , p_config_item_id number
                           , p_organization_id   number
)
is
lStmtNumber		number;
begin

        lStmtNumber := 2;


        delete from cst_item_cost_details
        where inventory_item_id = p_config_item_id
          and organization_id = p_organization_id
          and cost_type_id = p_dest_cost_type_id ;

        lStmtNumber := 20 ;


        delete from cst_item_costs
        where inventory_item_id = p_config_item_id
          and organization_id = p_organization_id
          and cost_type_id = p_dest_cost_type_id ;




        /*-------------------------------------------------------+
        Insert a row into the cst_item_costs_table
        +------------------------------------------------------- */

        lStmtNumber := 220;

        insert into CST_ITEM_COSTS
                (inventory_item_id,
                organization_id,
                cost_type_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                inventory_asset_flag,
                lot_size,
                based_on_rollup_flag,
                shrinkage_rate,
                defaulted_flag,
                cost_update_id,
                pl_material,
                pl_material_overhead,
                pl_resource,
                pl_outside_processing,
                pl_overhead,
                tl_material,
                tl_material_overhead,
                tl_resource,
                tl_outside_processing,
                tl_overhead,
                material_cost,
                material_overhead_cost,
                resource_cost,
                outside_processing_cost ,
                overhead_cost,
                pl_item_cost,
                tl_item_cost,
                item_cost,
                unburdened_cost ,
                burden_cost,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15
                )
        select distinct
                p_config_item_id,                -- INVENTORY_ITEM_ID
                p_organization_id,
                p_dest_cost_type_id,
                sysdate,                  -- last_update_date
                -1,                       -- last_updated_by
                sysdate,                  -- creation_date
                -1,                       -- created_by
                -1,                       -- last_update_login
                C.inventory_asset_flag,
                C.lot_size,
                C.based_on_rollup_flag,
                C.shrinkage_rate,
                C.defaulted_flag,
                p_src_cost_type_id,                     -- cost_update_id
                C.pl_material,
                C.pl_material_overhead,
                C.pl_resource,
                C.pl_outside_processing,
                C.pl_overhead,
                C.tl_material,
                C.tl_material_overhead,
                C.tl_resource,
                C.tl_outside_processing,
                C.tl_overhead,
                C.material_cost,
                C.material_overhead_cost,
                C.resource_cost,
                C.outside_processing_cost ,
                C.overhead_cost,
                C.pl_item_cost,
                C.tl_item_cost,
                C.item_cost,
                C.unburdened_cost ,
                C.burden_cost,
                C.attribute_category,
                C.attribute1,
                C.attribute2,
                C.attribute3,
                C.attribute4,
                C.attribute5,
                C.attribute6,
                C.attribute7,
                C.attribute8,
                C.attribute9,
                C.attribute10,
                C.attribute11,
                C.ATTRIBUTE12,
                C.attribute13,
                C.attribute14,
                C.attribute15
        from
                cst_item_costs C
        where  C.inventory_item_id = p_config_item_id
        and    C.organization_id   = p_organization_id
        and    C.cost_type_id  = p_src_cost_type_id;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('copy_cost: ' || 'after insert:CST_ITEM_COSTS',2);

        	oe_debug_pub.add('copy_cost: ' || 'after insert:CST_ITEM_COSTS' || sql%rowcount ,2);
        END IF;

        /*------ ----------------------------------------------+
         Insert rows into the cst_item_cost_details table
        +-----------------------------------------------------*/

        lStmtNumber := 230;

        insert into cst_item_cost_details
                (inventory_item_id,
                cost_type_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                organization_id,
                operation_sequence_id,
                operation_seq_num,
                department_id,
                level_type,
                activity_id,
                resource_seq_num,
                resource_id,
                resource_rate,
                item_units,
                activity_units,
                usage_rate_or_amount,
                basis_type,
                basis_resource_id,
                basis_factor,
                net_yield_or_shrinkage_factor,
                item_cost,
                cost_element_id,
                rollup_source_type,
                activity_context,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15
                )
        select distinct
                p_config_item_id,                   -- inventory_item_id
                p_dest_cost_type_id,
                sysdate,                     -- last_update_date
                -1,                          -- last_updated_by
                sysdate,                     -- creation_date
                -1,                          -- created_by
                -1,                          -- last_update_login
                p_organization_id,
                c.operation_sequence_id,
                c.operation_seq_num,
                c.department_id,
                c.level_type,
                c.activity_id,
                c.resource_seq_num,
                c.resource_id,
                c.resource_rate,
                c.item_units,
                c.activity_units,
                c.usage_rate_or_amount,
                c.basis_type,
                c.basis_resource_id,
                c.basis_factor,
                c.net_yield_or_shrinkage_factor,
                c.item_cost,
                c.cost_element_id,
                C.rollup_source_type,
                C.activity_context,
                C.attribute_category,
                C.attribute1,
                C.attribute2,
                C.attribute3,
                C.attribute4,
                C.attribute5,
                C.attribute6,
                C.attribute7,
                C.attribute8,
                C.attribute9,
                C.attribute10,
                C.attribute11,
                C.attribute12,
                C.attribute13,
                C.attribute14,
                C.attribute15
        from
                cst_item_cost_details C
        where  C.inventory_item_id = p_config_item_id
        and    C.organization_id   = p_organization_id
        and    C.cost_type_id  = p_src_cost_type_id ;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('copy_cost: ' || 'after insert:cst_item_cost_details',2);

        	oe_debug_pub.add('copy_cost: ' || 'after insert:cst_item_cost_details' || sql%rowcount ,2);
        END IF;


  exception
    when NO_DATA_FOUND THEN
/*
      xErrorMessage := 'CTOCSTRB:' || to_char(lStmtNum) || ':' ||
                        substrb(sqlerrm,1,150);
        xMessageName  := 'CTO_CALC_COST_ROLLUP_ERROR';
*/

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('copy_cost: ' || 'copy_ctocost_to_frozen no data found ',2);
        END IF;

    when OTHERS THEN
/*
      xErrorMessage := 'CTOCSTRB:' || to_char(lStmtNum) || ':' ||
                        substrb(sqlerrm,1,150);
      --xMessageName  := 'BOM_ATO_PROCESS_ERROR';
        xMessageName  := 'CTO_CALC_COST_ROLLUP_ERROR';
*/

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('copy_cost: ' || 'copy_ctocost_to_frozen others ',2);
        END IF;





end copy_cost;


--This procedure checks if pllanning needs to create supply
--or CTO can create supply
--x_can_create_supply = Y : CTO
--  = N : Planning
--Calls
--1. custom API Check_supply
--2. query sourcing org
--Added by kkonada for DMF-J
PROCEDURE check_cto_can_create_supply (
	P_config_item_id	IN   number,
	P_org_id		IN   number,
	x_can_create_supply     OUT  NOCOPY Varchar2,
	--p_source_type           OUT  NOCOPY Varchar2,
        p_source_type           OUT  NOCOPY number,  --Bugfix 6470516
	x_return_status         OUT  NOCOPY varchar2,
	X_msg_count		OUT  NOCOPY    number,
	X_msg_data		OUT  NOCOPY   Varchar2,
	x_sourcing_org          OUT  NOCOPY NUMBER,  --opm
	x_message               OUT  NOCOPY varchar2 --opm
 )
 IS

 P_custom_in_params_rec   CTO_CUSTOM_SUPPLY_CHECK_PK.in_params_rec_type;
 x_custom_out_params_rec  CTO_CUSTOM_SUPPLY_CHECK_PK.out_params_rec_type;

 lStmtNum number;

 l_sourcing_rule_exists VARCHAR2(1);
 l_source_type          NUMBER;
 l_transit_lead_time    NUMBER;
 l_exp_error_code       NUMBER;


 BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_can_create_supply := 'Y';

      IF PG_DEBUG <> 0 THEN
         oe_debug_pub.add('check_cto_can_create_supply : ' ||'ENTERED',1);
      END IF;

      --call custom API
      lStmtNum := 10;
      P_custom_in_params_rec.CONFIG_ITEM_ID := P_config_item_id;
      P_custom_in_params_rec.Org_id         := P_org_id		;

      IF PG_DEBUG <> 0 THEN
         oe_debug_pub.add('check_cto_can_create_supply : ' ||'P_config_item_id'
				||P_config_item_id,1);
	  oe_debug_pub.add('check_cto_can_create_supply : ' ||'P_org_id'
	                         ||P_org_id,1);
      END IF;


      lStmtNum :=20;
      CTO_CUSTOM_SUPPLY_CHECK_PK.Check_Supply
                               (
			         P_in_params_rec  =>P_custom_in_params_rec,
				 X_out_params_rec =>x_custom_out_params_rec ,
				 X_return_status  =>  x_return_status,
			         X_msg_count      => X_msg_count,
			         X_msg_data       => X_msg_data

                                );

  lStmtNum:=30;
  IF X_return_status = FND_API.G_RET_STS_SUCCESS
     and
     X_custom_out_params_rec.can_cto_create_supply = 'Y'  THEN


      IF PG_DEBUG <> 0 THEN
         oe_debug_pub.add('check_cto_can_create_supply : '
				||'success from custom API',5);
      END IF;




      --call query sourcing org
        lStmtNum:=40;
        CTO_UTILITY_PK.query_sourcing_org(
                          p_inventory_item_id		=> P_config_item_id,
                          p_organization_id		=> P_org_id,
                          p_sourcing_rule_exists	=> l_sourcing_rule_exists,
                          p_sourcing_org		=> x_sourcing_org,
                          p_source_type			=> p_source_type ,
                          p_transit_lead_time		=> l_transit_lead_time,
                          x_return_status		=> x_return_status,
                          x_exp_error_code		=> l_exp_error_code );

      lStmtNum:=50;
      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
            IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('check_cto_can_create_supply : '
				||'success from query sourcing org',5);
	    END IF;

	    -- 100% trasfer rule = 1 and multiple sources = 66
	    -- rkaza. ireq project. 05/02/2005.
            -- Previosly CTO cannot create supply for source type 1 and 66.
            -- Now CTO can create supply for 1. So removed it in if condition.
            IF p_source_type = 66 THEN

		IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('check_cto_can_create_supply : '
				   ||'P_source_type'||p_source_type,5);
		 END IF;
	        x_can_create_supply := 'N';
		x_message := 'MULTIPLE SOURCES PRESENT';
	    END IF;

           --OPM
	   --If x_can_create_supply=Y. Avoid make and process org combination

	   IF x_can_create_supply = 'Y' and p_source_type =2 THEN

	       IF INV_GMI_RSV_BRANCH.Process_Branch
	              (p_organization_id =>P_org_id) THEN

                   IF PG_DEBUG <> 0 THEN
		     oe_debug_pub.add('check_cto_can_create_supply : '
				   ||'MAKE in a process org not allowed',1);
		   END IF;

		   x_can_create_supply := 'N';
		   x_message := 'MAKE in PROCESS Org INVALID combination';

	       END IF;--check process org
	   END IF; --can_create = y and source_type =2



     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('check_cto_can_create_supply : ' || 'Unexpected Error in the sourcing rule.',1);
         END IF;
         raise FND_API.G_EXC_UNEXPECTED_ERROR;

     END IF;

  ELSIF X_return_status = FND_API.G_RET_STS_SUCCESS --cutsom API's out param
        and X_custom_out_params_rec.can_cto_create_supply = 'N' THEN

	  IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('check_cto_can_create_supply : '
			||'from custom api:can_create_supply is N',5);
          END IF;

           x_can_create_supply := 'N';
	   x_message := 'Custom api for SUPPLY returned N';

  ELSIF X_return_status = FND_API.G_RET_STS_ERROR  THEN
         RAISE FND_API.G_EXC_ERROR;

  ELSE
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

EXCEPTION

 WHEN fnd_api.g_exc_error THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('check_cto_can_create_supply: ' || 'Exception in stmt num: '
		                    || to_char(lStmtNum), 1);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
   WHEN fnd_api.g_exc_unexpected_error THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('check_cto_can_create_supply: ' || ' Unexpected Exception in stmt num: '
		                       || to_char(lStmtNum), 1);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
   WHEN OTHERS then
        IF PG_DEBUG <> 0 THEN

        	oe_debug_pub.add('check_cto_can_create_supply: ' || 'Others Exception in stmt num: '
		                    || to_char(lStmtNum), 1);
		oe_debug_pub.add('check_cto_can_create_supply: ' || 'errormsg='||sqlerrm, 1);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );




 END check_cto_can_create_supply;



procedure split_line (
p_ato_line_id   in number ,
x_return_status out nocopy varchar2,
x_msg_count     out nocopy number,
x_msg_data      out nocopy varchar2
)
is

cursor config_update( c_organization_id in number)
is
   select line_id, split_from_line_id
   from oe_order_lines_all  oeol , mtl_system_items msi
   where oeol.line_id = p_ato_line_id
     and oeol.inventory_item_id = msi.inventory_item_id
     and msi.organization_id = c_organization_id
     and msi.bom_item_type = 1 ;

v_organization_id   number ;
v_config     config_update%rowtype ;

lstmtnum number:= 0 ;
begin



     oe_debug_pub.add('CTOUTILB.split_line: entered split_line ' , 1);




       /*
         BUG:3484511
         -----------
        select master_organization_id
        into   v_organization_id
        from   oe_order_lines_all oel,
           oe_system_parameters_all ospa
        where  oel.line_id = p_ato_line_id
        and    nvl(oel.org_id, -1) = nvl(ospa.org_id, -1) ;  --bug 1531691
       */



           IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('CTOUTILB.split_line: ' ||  'Going to fetch Validation Org ' ,2);
           END IF;


           select nvl( oe_sys_parameters.value( 'MASTER_ORGANIZATION_ID' , oel.org_id) , -99)
              into v_organization_id from oe_order_lines_all oel
           where oel.line_id = p_ato_line_id;




     lstmtnum := 10 ;


     CTO_UTILITY_PK.Populate_Bcol(
               p_bcol_line_id     => p_ato_line_id,
               x_return_status    => x_return_status ,
               x_msg_count        => x_msg_count,
               x_msg_data         => x_msg_data,
               p_reschedule       => 'N' ) ;

               /* reschedule should be always No for Split Line
               */


     oe_debug_pub.add('CTOUTILB.split_line: opening config_update cursor ' , 1);



     lstmtnum := 20 ;


     open config_update( v_organization_id ) ;

     loop

          fetch config_update into v_config ;


          exit when config_update%notfound ;


          oe_debug_pub.add('CTOUTILB.split_line: line ' || v_config.line_id , 1);
          oe_debug_pub.add('CTOUTILB.split_line: split line ' ||
                            v_config.split_from_line_id , 1);


          update bom_cto_order_lines set config_item_id = ( select bcol1.config_item_id
                             from bom_cto_order_lines bcol1
                             where bcol1.line_id = v_config.split_from_line_id )
           where line_id = v_config.line_id ;

          oe_debug_pub.add('CTOUTILB.split_line: update cnt ' || SQL%ROWCOUNT , 1);


     end loop ;



exception
 when others then
       IF PG_DEBUG <> 0 THEN

          oe_debug_pub.add('CTO_UTILITY_PK.split_line: ' || 'Others Exception in stmt num : '
                            || to_char(lStmtNum), 1);
          oe_debug_pub.add('CTO_UTILITY_PK.split_line: ' || 'errormsg='||sqlerrm, 1);

       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


end split_line ;


procedure adjust_bcol_for_split(
p_ato_line_id   in number ,
x_return_status out nocopy varchar2,
x_msg_count     out nocopy number,
x_msg_data      out nocopy varchar2
)
is
begin

     oe_debug_pub.add('CTO_UTILITY_PK.adjust_bcol_for_split: entered ' || p_ato_line_id , 1);

     update bom_cto_order_lines bcol
        set ordered_quantity = ( select ordered_quantity
                  from oe_order_lines_all
                  where ato_line_id = bcol.ato_line_id
                    and line_id = bcol.line_id )
      where ato_line_id = p_ato_line_id ;

     oe_debug_pub.add('CTO_UTILITY_PK.adjust_bcol_for_split: upd cnt ' || SQL%ROWCOUNT , 1);

end adjust_bcol_for_split ;


procedure adjust_bcol_for_warehouse(
p_ato_line_id   in number ,
x_return_status out nocopy varchar2,
x_msg_count     out nocopy number,
x_msg_data      out nocopy varchar2
)
is
begin

     oe_debug_pub.add('CTO_UTILITY_PK.adjust_bcol_for_warehouse: entered ' || p_ato_line_id , 1);

     update bom_cto_order_lines bcol
        set ship_from_org_id = ( select ship_from_org_id
                  from oe_order_lines_all
                  where ato_line_id = bcol.ato_line_id
                    and line_id = bcol.line_id )
      where ato_line_id = p_ato_line_id ;

     oe_debug_pub.add('CTO_UTILITY_PK.adjust_bcol_for_warehouse: upd cnt ' || SQL%ROWCOUNT , 1);



end adjust_bcol_for_warehouse;


  PROCEDURE  Reservation_Exists(
                               Pconfiglineid	in	number,
                               x_return_status	out nocopy varchar2,
                               x_result		out nocopy boolean,
                               X_Msg_Count	out nocopy number,
                               X_Msg_Data	out nocopy varchar2) as

    l_reservation_id mtl_reservations.reservation_id%type;

  BEGIN

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('Reservation_Exists: ' || 'Entering into Reservation_exists procedure....',1);
   END IF;
   -- Check if flow schedule exists . If not check some inv/work order Reservation
   -- exists. If both of them does'nt exists then return false. Other wise return true.

   IF CTO_WORKFLOW.flow_sch_exists(pconfigLineId) <> TRUE  THEN

      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('Reservation_Exists: ' || 'flow Reservation not exists..',5);

      	oe_debug_pub.add('Reservation_Exists: ' || 'The line_id passed for reservation = '||to_char(pconfiglineid),5);
      END IF;

      SELECT   reservation_id
      INTO     l_reservation_id
      FROM
            mtl_reservations mr,
            oe_order_lines_all oel,
            oe_order_headers_all oeh,
            oe_transaction_types_all ota,
            oe_transaction_types_tl otl,
            mtl_sales_orders mso
      WHERE
               mr.demand_source_line_id = oel.line_id
      and      oel.line_id              = pconfigLineId    --- Configuration item line id
      and      oeh.header_id            = oel.header_id
      and      oeh.order_type_id        = ota.transaction_type_id
      and      ota.transaction_type_code=  'ORDER'
      and      ota.transaction_type_id   = otl.transaction_type_id
      and      oeh.order_number         = mso.segment1
      and      otl.name                 = mso.segment2
      and      otl.language             = (select language_code
                                           from  fnd_languages
                                           where installed_flag  ='B')
      and      mso.sales_order_id       = mr.demand_source_header_id
      --and      mr.demand_source_type_id = INV_RESERVATION_GLOBAL.g_source_type_oe
      and      mr.demand_source_type_id = decode(oeh.source_document_type_id, 10, INV_RESERVATION_GLOBAL.g_source_type_internal_ord,
                                             INV_RESERVATION_GLOBAL.g_source_type_oe)	--bugfix 1799874
      and      mr.reservation_quantity  > 0
      and      rownum                   = 1;
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('Reservation_Exists: ' || 'Work order/Inv reservation Exists..',5);
      END IF;
    END IF;

    x_result := TRUE;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

 EXCEPTION
           WHEN no_data_found THEN
           	IF PG_DEBUG <> 0 THEN
           		oe_debug_pub.add('Reservation_Exists: ' || 'Coming out of reservation_exists procedure with FALSE...',2);
           	END IF;
           	x_return_status := FND_API.G_RET_STS_SUCCESS;
	   	x_result :=  FALSE;

           WHEN others THEN
           	IF PG_DEBUG <> 0 THEN
           		oe_debug_pub.add('Reservation_Exists: ' || 'OTHERS excpn occured in Reservation_Exists procedure..',2);

           		oe_debug_pub.add('Reservation_Exists: ' || 'Error message is : '||sqlerrm,1);
           	END IF;
           	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           	x_result := FALSE;

 END Reservation_Exists;




procedure copy_bcolgt_bcol(     p_ato_line_id   in      number,
                                x_return_status out     NOCOPY varchar2,
                                x_msg_count     out     NOCOPY number,
                                x_msg_data      out     NOCOPY varchar2)

is
lStmtNumber             number;
begin

oe_debug_pub.add( ' entered copy bcol_gt  to bcol' , 1) ;

                    insert into bom_cto_order_lines (
                           LINE_ID
                          ,HEADER_ID
                          ,TOP_MODEL_LINE_ID
                          ,LINK_TO_LINE_ID
                          ,ATO_LINE_ID
                          ,PARENT_ATO_LINE_ID
                          ,INVENTORY_ITEM_ID
                          ,SHIP_FROM_ORG_ID
                          ,COMPONENT_SEQUENCE_ID
                          ,COMPONENT_CODE
                          ,ITEM_TYPE_CODE
                          ,SCHEDULE_SHIP_DATE
                          ,PLAN_LEVEL
                          ,PERFORM_MATCH
                          ,CONFIG_ITEM_ID
                          ,BOM_ITEM_TYPE
                          ,WIP_SUPPLY_TYPE
                          ,ORDERED_QUANTITY
                          ,ORDER_QUANTITY_UOM
                          ,BATCH_ID
                          ,CREATION_DATE
                          ,CREATED_BY
                          ,LAST_UPDATE_DATE
                          ,LAST_UPDATED_BY
                          ,LAST_UPDATE_LOGIN
                          ,PROGRAM_APPLICATION_ID
                          ,PROGRAM_ID
                          ,PROGRAM_UPDATE_DATE
                          ,REUSE_CONFIG
                          ,OPTION_SPECIFIC
                          ,QTY_PER_PARENT_MODEL
                          ,CONFIG_CREATION)
                    select /*+ INDEX (BOM_CTO_ORDER_LINES_GT BOM_CTO_ORDER_LINES_GT_N1) */
                           LINE_ID
                          ,HEADER_ID
                          ,TOP_MODEL_LINE_ID
                          ,LINK_TO_LINE_ID
                          ,ATO_LINE_ID
                          ,PARENT_ATO_LINE_ID
                          ,INVENTORY_ITEM_ID
                          ,SHIP_FROM_ORG_ID
                          ,COMPONENT_SEQUENCE_ID
                          ,COMPONENT_CODE
                          ,ITEM_TYPE_CODE
                          ,SCHEDULE_SHIP_DATE
                          ,PLAN_LEVEL
                          ,PERFORM_MATCH
                          ,CONFIG_ITEM_ID
                          ,BOM_ITEM_TYPE
                          ,WIP_SUPPLY_TYPE
                          ,ORDERED_QUANTITY
                          ,ORDER_QUANTITY_UOM
                          ,BATCH_ID
                          ,CREATION_DATE
                          ,CREATED_BY
                          ,LAST_UPDATE_DATE
                          ,LAST_UPDATED_BY
                          ,LAST_UPDATE_LOGIN
                          ,PROGRAM_APPLICATION_ID
                          ,PROGRAM_ID
                          ,PROGRAM_UPDATE_DATE
                          ,REUSE_CONFIG
                          ,OPTION_SPECIFIC
                          ,QTY_PER_PARENT_MODEL
                          ,CONFIG_CREATION
                      from bom_cto_order_lines_gt
                     where ato_line_id = p_ato_line_id ;

oe_debug_pub.add( ' copied bcol_gt to bcol ' || SQL%ROWCOUNT , 1) ;




end copy_bcolgt_bcol ;



procedure copy_bcol_bcolgt(      p_ato_line_id   in      number,
                                x_return_status out     NOCOPY varchar2,
                                x_msg_count     out     NOCOPY number,
                                x_msg_data      out     NOCOPY varchar2)

is
lStmtNumber             number;
begin

oe_debug_pub.add( ' entered copy bcol to bcol_gt ' , 1) ;
                    --bugfix#3756670
                    delete from bom_cto_order_lines_gt
		    where ato_line_id = p_ato_line_id ;

                    insert into bom_cto_order_lines_gt (
                           LINE_ID
                          ,HEADER_ID
                          ,TOP_MODEL_LINE_ID
                          ,LINK_TO_LINE_ID
                          ,ATO_LINE_ID
                          ,PARENT_ATO_LINE_ID
                          ,INVENTORY_ITEM_ID
                          ,SHIP_FROM_ORG_ID
                          ,COMPONENT_SEQUENCE_ID
                          ,COMPONENT_CODE
                          ,ITEM_TYPE_CODE
                          ,SCHEDULE_SHIP_DATE
                          ,PLAN_LEVEL
                          ,PERFORM_MATCH
                          ,CONFIG_ITEM_ID
                          ,BOM_ITEM_TYPE
                          ,WIP_SUPPLY_TYPE
                          ,ORDERED_QUANTITY
                          ,ORDER_QUANTITY_UOM
                          ,BATCH_ID
                          ,CREATION_DATE
                          ,CREATED_BY
                          ,LAST_UPDATE_DATE
                          ,LAST_UPDATED_BY
                          ,LAST_UPDATE_LOGIN
                          ,PROGRAM_APPLICATION_ID
                          ,PROGRAM_ID
                          ,PROGRAM_UPDATE_DATE
                          ,REUSE_CONFIG
                          ,OPTION_SPECIFIC
                          ,QTY_PER_PARENT_MODEL
                          ,CONFIG_CREATION
			  ,VALIDATION_ORG)
                    select
                           LINE_ID
                          ,HEADER_ID
                          ,TOP_MODEL_LINE_ID
                          ,LINK_TO_LINE_ID
                          ,ATO_LINE_ID
                          ,PARENT_ATO_LINE_ID
                          ,INVENTORY_ITEM_ID
                          ,SHIP_FROM_ORG_ID
                          ,COMPONENT_SEQUENCE_ID
                          ,COMPONENT_CODE
                          ,ITEM_TYPE_CODE
                          ,SCHEDULE_SHIP_DATE
                          ,PLAN_LEVEL
                          ,PERFORM_MATCH
                          ,CONFIG_ITEM_ID
                          ,BOM_ITEM_TYPE
                          ,WIP_SUPPLY_TYPE
                          ,ORDERED_QUANTITY
                          ,ORDER_QUANTITY_UOM
                          ,BATCH_ID
                          ,CREATION_DATE
                          ,CREATED_BY
                          ,LAST_UPDATE_DATE
                          ,LAST_UPDATED_BY
                          ,LAST_UPDATE_LOGIN
                          ,PROGRAM_APPLICATION_ID
                          ,PROGRAM_ID
                          ,PROGRAM_UPDATE_DATE
                          ,REUSE_CONFIG
                          ,OPTION_SPECIFIC
                          ,QTY_PER_PARENT_MODEL
                          ,CONFIG_CREATION
			  ,SHIP_FROM_ORG_ID --3555026
                      from bom_cto_order_lines
                     where ato_line_id = p_ato_line_id ;



oe_debug_pub.add( ' copied bcol to bcol_gt ' || SQL%ROWCOUNT , 1) ;


end copy_bcol_bcolgt ;




procedure send_notification(
                            P_PROCESS                       in    varchar2
                           ,P_LINE_ID                       in    number
                           ,P_SALES_ORDER_NUM               in    number
                           ,P_ERROR_MESSAGE                 in    varchar2
                           ,P_TOP_MODEL_NAME                in    varchar2
                           ,P_TOP_MODEL_LINE_NUM            in    varchar2
                           ,P_TOP_CONFIG_NAME               in    varchar2
                           ,P_TOP_CONFIG_LINE_NUM           in    varchar2
                           ,P_PROBLEM_MODEL                 in    varchar2
                           ,P_PROBLEM_MODEL_LINE_NUM        in    varchar2
                           ,P_PROBLEM_CONFIG                in    varchar2
                           ,P_ERROR_ORG                     in    varchar2
                           ,P_NOTIFY_USER                   in    varchar2
                           ,P_REQUEST_ID                    in    varchar2
                           ,P_MFG_REL_DATE                  in    date default null
)
is
   l_aname                      wf_engine.nametabtyp;
   l_anumvalue                  wf_engine.numtabtyp;
   l_atxtvalue                  wf_engine.texttabtyp;
   l_adatevalue                 wf_engine.datetabtyp;
   luser_key                    varchar2(100);
   litem_key                    varchar2(100);
   lplanner_code                mtl_system_items_vl.planner_code%type;

   l_dname                      wf_engine.nametabtyp;
  porder_no                     number := 2222 ;
  pline_no                      number := 1111 ;

  lstmt_num                     number ;

    l_new_line  varchar2(10) := fnd_global.local_chr(10);

  i     number ;


begin




          lstmt_num := 10 ;


          litem_key := to_char(p_line_id)||to_char(sysdate,'mmddyyhhmiss' );

          oe_debug_pub.add( 'SEND_NOTIFICATION item_key ' || litem_key , 1 ) ;
          g_error_seq := g_error_seq + 1 ;
          oe_debug_pub.add( 'error_seq is ' || g_error_seq , 1 ) ;

          luser_key := litem_key;

          lplanner_code := P_NOTIFY_USER ;

          lstmt_num := 20 ;




          i := 1 ;

          l_aname(i) :=  'ERROR_MESSAGE' ;
          l_atxtvalue(i) :=  P_ERROR_MESSAGE ;

          i := i + 1 ;

          l_aname(i) :=  'TOP_MODEL' ;
          l_atxtvalue(i) := P_TOP_MODEL_NAME ;

          i := i + 1 ;

          l_aname(i) := 'TOP_MODEL_LINE_NUM' ;
          l_atxtvalue(i) := P_TOP_MODEL_LINE_NUM ;



          if( p_request_id is not null ) then
             i := i + 1 ;
             l_aname(i) := 'REQUEST_ID' ;

             l_atxtvalue(i) := P_REQUEST_ID  ;

          end if;


          /*
          i := i + 1 ;

          l_aname(i) := 'MFG_DATE' ;
          l_atxtvalue(i) := P_MFG_REL_DATE  ;
          */

          l_dname(1) := 'MFG_DATE' ;
          l_adatevalue(1) := P_MFG_REL_DATE ;



          lstmt_num := 30 ;

         if( P_PROCESS in ( 'NOTIFY_OID_INC' ,  'NOTIFY_OID_IC' ) ) then

          i := i + 1 ;

          l_aname(i) :=  'PROBLEM_MODEL' ;
          l_atxtvalue(i) := P_PROBLEM_MODEL   ;

          i := i + 1 ;

          l_aname(i) := 'PROBLEM_MODEL_LINE_NUM' ;
          l_atxtvalue(i) :=  P_PROBLEM_MODEL_LINE_NUM ;

          i := i + 1 ;

          l_aname(i) := 'ERROR_ORG' ;
          l_atxtvalue(i) := P_ERROR_ORG   ;


         end if ;

          lstmt_num := 40 ;

         if( P_PROCESS in  ( 'NOTIFY_OID_IC' , 'NOTIFY_OEE_IC'  )) then

          i := i + 1 ;

          l_aname(i) := 'TOP_CONFIG' ;
          l_atxtvalue(i) := P_TOP_CONFIG_NAME  ;

          i := i + 1 ;

          l_aname(i) := 'TOP_CONFIG_LINE_NUM' ;
          l_atxtvalue(i) := P_TOP_CONFIG_LINE_NUM ;


        end if ;


         if( P_PROCESS = 'NOTIFY_OID_IC' ) then

          i := i + 1 ;

          l_aname(i) := 'PROBLEM_CONFIG' ;
          l_atxtvalue(i) := P_PROBLEM_CONFIG  ;


        end if;


          lstmt_num := 50 ;

          if( P_PROCESS = 'NOTIFY_OID_IC' ) then
              oe_debug_pub.add( ' going to create process 1 ' || P_PROCESS ) ;

              litem_key := litem_key || to_char( g_error_seq ) || '1111' ;

              oe_debug_pub.add( 'SEND_NOTIFICATION modified item_key ' || litem_key , 1 ) ;

              wf_engine.CreateProcess (ItemType=> 'CTOEXCP',ItemKey=>litem_key,Process=>'NOTIFY_OID_IC');

          elsif( P_PROCESS = 'NOTIFY_OID_INC' ) then

              litem_key := litem_key || to_char( g_error_seq ) || '2222' ;

              oe_debug_pub.add( 'SEND_NOTIFICATION modified item_key ' || litem_key , 1 ) ;

              oe_debug_pub.add( ' going to create process 2 ' || P_PROCESS ) ;
              wf_engine.CreateProcess (ItemType=> 'CTOEXCP',ItemKey=>litem_key,Process=>'NOTIFY_OID_INC');

          elsif( P_PROCESS = 'NOTIFY_OEE_INC' ) then

              litem_key := litem_key || to_char( g_error_seq ) || '3333' ;

              oe_debug_pub.add( 'SEND_NOTIFICATION modified item_key ' || litem_key , 1 ) ;


              oe_debug_pub.add( ' going to create process 3 ' || P_PROCESS ) ;
              wf_engine.CreateProcess (ItemType=> 'CTOEXCP',ItemKey=>litem_key,Process=>'NOTIFY_OEE_INC');

          elsif( P_PROCESS = 'NOTIFY_OEE_IC' ) then

              litem_key := litem_key || to_char(g_error_seq ) || '4444' ;

              oe_debug_pub.add( 'SEND_NOTIFICATION modified item_key ' || litem_key , 1 ) ;



              oe_debug_pub.add( ' going to create process 4 ' || P_PROCESS ) ;
              wf_engine.CreateProcess (ItemType=> 'CTOEXCP',ItemKey=>litem_key,Process=>'NOTIFY_OEE_IC');

          end if;


          lstmt_num := 60 ;
          wf_engine.SetItemUserKey(ItemType=> 'CTOEXCP',ItemKey=>litem_key,UserKey=>luser_key);



          lstmt_num := 70 ;

          IF WF_DIRECTORY.USERACTIVE(lplanner_code) <>TRUE THEN
             -- Get the default adminstrator value from Workflow Attributes.
             lplanner_code := wf_engine.getItemAttrText(ItemType => 'CTOEXCP',
                                                 ItemKey  => litem_key,
                                                 aname    => 'WF_ADMINISTRATOR');
             oe_debug_pub.add('start_work_flow: ' || 'Planner code is not a valid workflow user...Defaulting to'||lplanner_code,5);

          ELSE

             oe_debug_pub.add('start_work_flow: ' || 'Planner code is a valid workflow user...' ,5);

          END IF;


          lstmt_num := 80 ;


          i := i + 1 ;

          l_aname(i)     := 'NOTIFY_USER';
          l_atxtvalue(i) := lplanner_code;



          lstmt_num := 90 ;

          wf_engine.SetItemAttrNumber(ItemType   =>'CTOEXCP',
                              itemkey    =>litem_key,
                              aname      =>'ORDER_NUM',
                              avalue     => p_sales_order_num );

          lstmt_num := 100 ;
          wf_engine.SetItemAttrTextArray(ItemType =>'CTOEXCP',ItemKey=>litem_key,aname=>l_aname,avalue=>l_atxtvalue);

          lstmt_num := 110 ;
          wf_engine.SetItemAttrDateArray(ItemType =>'CTOEXCP',ItemKey=>litem_key,aname=>l_dname,avalue=>l_adatevalue);


          lstmt_num := 120 ;
          wf_engine.SetItemOwner(Itemtype=>'CTOEXCP',itemkey=>litem_key,owner=>lplanner_code);


          lstmt_num := 130 ;
          wf_engine.StartProcess(itemtype=>'CTOEXCP',ItemKey=>litem_key);


          oe_debug_pub.add( ' done till stmt ' || lstmt_num ) ;



exception
when others then

 oe_debug_pub.add( ' exception in others at stmt ' || lstmt_num ) ;
 oe_debug_pub.add( ' exception in others ' || SQLCODE ) ;
 oe_debug_pub.add( ' exception in others ' || SQLERRM ) ;


end send_notification ;



procedure notify_expected_errors ( P_PROCESS                       in    varchar2
                           ,P_LINE_ID                       in    number
                           ,P_SALES_ORDER_NUM               in    number
                           ,P_TOP_MODEL_NAME                in    varchar2
                           ,P_TOP_MODEL_LINE_NUM            in    varchar2
                           ,P_MSG_COUNT                     in    number
                           ,P_NOTIFY_USER                   in    varchar2
                           ,P_REQUEST_ID                    in    varchar2
                           ,P_ERROR_MESSAGE                 in    varchar2 default null
                           ,P_TOP_CONFIG_NAME               in    varchar2 default null
                           ,P_TOP_CONFIG_LINE_NUM           in    varchar2 default null
                           ,P_PROBLEM_MODEL                 in    varchar2 default null
                           ,P_PROBLEM_MODEL_LINE_NUM        in    varchar2 default null
                           ,P_PROBLEM_CONFIG                in    varchar2 default null
                           ,P_ERROR_ORG                     in    varchar2 default null
)
is
PRAGMA AUTONOMOUS_TRANSACTION  ;

  l_new_line  varchar2(10) := fnd_global.local_chr(10);
  v_error_message    varchar2(2300) ;
  l_msg_data         varchar2(2300) ;


begin

              oe_debug_pub.add('CTO_UTILITY_PK.notify_expected_errors: ******** BEGIN AUTONOMOUS TRANSACTION    **********' , 1 );



              oe_debug_pub.add('CTO_UTILITY_PK.notify_expected_errors: msg count ' || P_MSG_COUNT , 1 );


              if ( nvl( p_msg_count , 0 ) = 0 ) then
                   oe_debug_pub.add('CTO_UTILITY_PK.notify_expected_errors: nothing to notify' , 1 );
                   return ;
              end if;


              FOR l_index IN 1..P_MSG_COUNT LOOP
	         -- Fixed bug 5639511
		 -- Added substr function to avoid buffer overflow error

                 l_msg_data := substr(fnd_msg_pub.get(
                                   p_msg_index => l_index,
                                   p_encoded  => FND_API.G_FALSE),1,2000);

                 oe_debug_pub.add('CTO_UTILITY_PK.notify_expected_error: '||substr(l_msg_data,1,250));

                 -- Fixed bug 5639511
		 -- Added Substr fucntion to avoid buffer overflow error

                 v_error_message := substr(v_error_message || l_msg_data  || l_new_line,1,2000) ;

	         -- Fixed bug 5639511
		 -- If the string reached 2000 char length exit out of loop
                 if( length (v_error_message ) >= 2000 ) then

                     v_error_message := substr(v_error_message, 1 , 2000)  ;

                     oe_debug_pub.add('CTO_UTILITY_PK.notify_expected_error: truncated v_error_message to 4000 chars ' );
		     exit; -- Added exit statement for bug fix 5639511
                 end if;


              END LOOP;


              oe_debug_pub.add('CTO_UTILITY_PK.notify_expected_errors: error_message  : ' || v_error_message  );

              g_t_expected_error_info(1).NOTIFY_USER           := P_NOTIFY_USER ;
              g_t_expected_error_info(1).SALES_ORDER_NUM       := P_SALES_ORDER_NUM ;
              g_t_expected_error_info(1).TOP_MODEL_NAME        := p_top_model_name ;
              g_t_expected_error_info(1).TOP_MODEL_LINE_NUM    := p_top_model_line_num ;
              g_t_expected_error_info(1).ERROR_MESSAGE         := v_error_message ;
              g_t_expected_error_info(1).TOP_CONFIG_NAME       := p_top_config_name ;
              g_t_expected_error_info(1).TOP_CONFIG_LINE_NUM   := p_top_config_line_num ;
              g_t_expected_error_info(1).REQUEST_ID             :=  P_REQUEST_ID ;
              g_t_expected_error_info(1).LINE_ID             :=  P_LINE_ID ;
              g_t_expected_error_info(1).PROCESS := P_PROCESS ;  /* WORKFLOW PROCESS */


              g_t_expected_error_info(1).TOP_CONFIG_NAME        := p_top_config_name ;
              g_t_expected_error_info(1).TOP_CONFIG_LINE_NUM    := p_top_config_line_num ;

          /*
           following are not supported for now
          g_t_dropped_item_type(v_table_count).LINE_ID               := pLineId ;
          g_t_dropped_item_type(v_table_count).PROBLEM_MODEL         := v_problem_model ;
          g_t_dropped_item_type(v_table_count).PROBLEM_MODEL_LINE_NUM := v_problem_model_line_num ;
          g_t_dropped_item_type(v_table_count).PROBLEM_CONFIG         := v_problem_config ;
          g_t_dropped_item_type(v_table_count).ERROR_ORG              := v_error_org ;
          g_t_dropped_item_type(v_table_count).ERROR_ORG_ID           := pOrgId ;
          */


                 oe_debug_pub.add( 'PROCESS: ' || g_t_expected_error_info(1).PROCESS  , 1 ) ;
                 oe_debug_pub.add( 'LINE_ID: ' || g_t_expected_error_info(1).LINE_ID  , 1 ) ;
                 oe_debug_pub.add( 'SALES_ORDER_NUM: ' || g_t_expected_error_info(1).SALES_ORDER_NUM ,1 );
                 oe_debug_pub.add( 'ERROR_MESSAGE: ' || g_t_expected_error_info(1).ERROR_MESSAGE  , 1 ) ;
                 oe_debug_pub.add( 'TOP_MODEL_NAME: ' || g_t_expected_error_info(1).TOP_MODEL_NAME , 1 ) ;
                 oe_debug_pub.add( 'TOP_MODEL_LINE_NUM: ' || g_t_expected_error_info(1).TOP_MODEL_LINE_NUM , 1 ) ;
                 oe_debug_pub.add( 'TOP_CONFIG_NAME: ' || g_t_expected_error_info(1).TOP_CONFIG_NAME , 1 ) ;
                 oe_debug_pub.add( 'TOP_CONFIG_LINE_NUM: ' || g_t_expected_error_info(1).TOP_CONFIG_LINE_NUM , 1) ;
                 oe_debug_pub.add( 'PROBLEM_MODEL: ' || g_t_expected_error_info(1).PROBLEM_MODEL , 1 ) ;
                 oe_debug_pub.add( 'PROBLEM_MODEL_LINE_NUM: ' || g_t_expected_error_info(1).PROBLEM_MODEL_LINE_NUM , 1 ) ;
                 oe_debug_pub.add( 'PROBLEM_CONFIG: ' || g_t_expected_error_info(1).PROBLEM_CONFIG  , 1) ;
                 oe_debug_pub.add( 'ERROR_ORG: ' || g_t_expected_error_info(1).ERROR_ORG , 1 ) ;
                 oe_debug_pub.add( 'ERROR_ORG_ID: ' || g_t_expected_error_info(1).ERROR_ORG_ID , 1) ;
                 oe_debug_pub.add( 'NOTIFY_USER: ' || g_t_expected_error_info(1).NOTIFY_USER, 1) ;
                 oe_debug_pub.add( 'REQUEST_ID: ' || g_t_expected_error_info(1).REQUEST_ID  , 1 ) ;


              oe_debug_pub.add('CTO_UTILITY_PK.notify_expected_errors: done expected errors ' , 1 );




              oe_debug_pub.add('CTO_UTILITY_PK.notify_expected_errors: going to call send notification ' , 1 );

                      send_notification (
                            P_PROCESS                      =>  g_t_expected_error_info(1).process
                           ,P_LINE_ID                      =>  g_t_expected_error_info(1).line_id
                           ,P_SALES_ORDER_NUM              => g_t_expected_error_info(1).sales_order_num
                           ,P_ERROR_MESSAGE                => g_t_expected_error_info(1).error_message
                           ,P_TOP_MODEL_NAME               => g_t_expected_error_info(1).top_model_name
                           ,P_TOP_MODEL_LINE_NUM           => g_t_expected_error_info(1).top_model_line_num
                           ,P_TOP_CONFIG_NAME              => g_t_expected_error_info(1).top_config_name
                           ,P_TOP_CONFIG_LINE_NUM          => g_t_expected_error_info(1).top_config_line_num
                           ,P_PROBLEM_MODEL                => g_t_expected_error_info(1).problem_model
                           ,P_PROBLEM_MODEL_LINE_NUM       => g_t_expected_error_info(1).problem_model_line_num
                           ,P_PROBLEM_CONFIG               => g_t_expected_error_info(1).problem_config
                           ,P_ERROR_ORG                    => g_t_expected_error_info(1).error_org
                           ,P_NOTIFY_USER                  => g_t_expected_error_info(1).notify_user
                           ,P_REQUEST_ID                   =>  g_t_expected_error_info(1).request_id );


              commit ;    /* COMMIT FOR AUTONOMOUS TRANSACTION */


              oe_debug_pub.add('CTO_UTILITY_PK.notify_expected_errors: done send notification ' , 1 );

              oe_debug_pub.add('CTO_UTILITY_PK.notify_expected_errors: ******** END AUTONOMOUS TRANSACTION FOR NOTIFY_EXPECTED_ERRORS   **********' , 1 );
end notify_expected_errors ;


PROCEDURE APPLY_CREATE_CONFIG_HOLD( p_line_id        in  number
                                  , p_header_id      in  number
                                  , x_return_status  out NOCOPY varchar2
                                  , x_msg_count      out NOCOPY number
                                  , x_msg_data       out NOCOPY varchar2)
is
      Pragma AUTONOMOUS_TRANSACTION;
      l_hold_source_rec           OE_Holds_PVT.Hold_Source_REC_type;
      l_return_stutus     varchar2(10) ;
      l_msg_count         number ;
      l_msg_data          varchar2(200) ;

BEGIN

                    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('******************APPLY_CREATE_CONFIG_HOLD:BEGIN APPLY AUTONOMOUS TRANSACTION   ****************  ' ,1);
                    END IF;




                    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('APPLY_CREATE_CONFIG_HOLD:Calling OM api to apply create config activity hold.' ,1);
                    END IF;

                    l_hold_source_rec.hold_entity_code   := 'O';
                    l_hold_source_rec.hold_id            := 60 ;  /* Change hold id 1062 to 60 after getting script  from gayatri */
                    l_hold_source_rec.hold_entity_id     := p_header_id;
                    l_hold_source_rec.header_id          := p_header_id;
                    l_hold_source_rec.line_id            := p_line_id;

                    OE_Holds_PUB.Apply_Holds (
                                   p_api_version        => 1.0
                               ,   p_hold_source_rec    => l_hold_source_rec
                               ,   x_return_status      => x_return_status
                               ,   x_msg_count          => x_msg_count
                               ,   x_msg_data           => x_msg_data);

                    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                        IF PG_DEBUG <> 0 THEN
                           oe_debug_pub.add('CTOCITMB:Failed in Apply Holds with expected error.' ,1);
                        END IF;
                        raise FND_API.G_EXC_ERROR;

                    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                        IF PG_DEBUG <> 0 THEN
                           oe_debug_pub.add('CTOCITMB:Failed in Apply Holds with unexpected error.' ,1);
                        END IF;
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;

                    commit ;   /* COMMIT FOR AUTONOMOUS TRANSACTION  */


                    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('******************APPLY_CREATE_CONFIG_HOLD:END APPLY AUTONOMOUS TRANSACTION   ****************  ' ,1);
                    END IF;


END APPLY_CREATE_CONFIG_HOLD ;



procedure send_oid_notification
is
PRAGMA AUTONOMOUS_TRANSACTION  ;
begin

             oe_debug_pub.add('SEND_OID_NOTIFICATION : ******** BEGIN AUTONOMOUS TRANSACTION FOR SEND_OID_NOTIFICATION **********' , 1 );


               if( CTO_CONFIG_BOM_PK.g_t_dropped_item_type.count > 0 ) then




                    oe_debug_pub.add( 'DROPPED ITEM TABLE '  || CTO_CONFIG_BOM_PK.g_t_dropped_item_type.count , 1 ) ;

                   for i in 1..CTO_CONFIG_BOM_PK.g_t_dropped_item_type.count
                   loop
                       oe_debug_pub.add( 'PROCESS: ' || CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).PROCESS  , 1 ) ;
                       oe_debug_pub.add( 'LINE_ID: ' || CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).LINE_ID  , 1 ) ;
                       oe_debug_pub.add( 'SALES_ORDER_NUM: ' || CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).SALES_ORDER_NUM ,1 );
                       oe_debug_pub.add( 'ERROR_MESSAGE: ' || CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).ERROR_MESSAGE  , 1 ) ;
                       oe_debug_pub.add( 'TOP_MODEL_NAME: ' || CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).TOP_MODEL_NAME , 1 ) ;
                       oe_debug_pub.add( 'TOP_MODEL_LINE_NUM: ' || CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).TOP_MODEL_LINE_NUM , 1 ) ;
                       oe_debug_pub.add( 'TOP_CONFIG_NAME: ' || CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).TOP_CONFIG_NAME , 1 ) ;
                       oe_debug_pub.add( 'TOP_CONFIG_LINE_NUM: ' || CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).TOP_CONFIG_LINE_NUM , 1) ;
                       oe_debug_pub.add( 'PROBLEM_MODEL: ' || CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).PROBLEM_MODEL , 1 ) ;
                       oe_debug_pub.add( 'PROBLEM_MODEL_LINE_NUM: ' || CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).PROBLEM_MODEL_LINE_NUM , 1 ) ;
                       oe_debug_pub.add( 'PROBLEM_CONFIG: ' || CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).PROBLEM_CONFIG  , 1) ;
                       oe_debug_pub.add( 'ERROR_ORG: ' || CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).ERROR_ORG , 1 ) ;
                       oe_debug_pub.add( 'ERROR_ORG_ID: ' || CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).ERROR_ORG_ID , 1) ;
                       oe_debug_pub.add( 'NOTIFY_USER: ' || CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).NOTIFY_USER, 1) ;
                       oe_debug_pub.add( 'REQUEST_ID: ' || CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).REQUEST_ID  , 1 ) ;

                       if( CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).MFG_REL_DATE is not null ) then
                       oe_debug_pub.add( 'MFG_REL_DATE: ' || to_char(CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).MFG_REL_DATE)  , 1 ) ;
                       else

                           oe_debug_pub.add( 'MFG REL DATE is null '  , 1 ) ;
                       end if;



                      oe_debug_pub.add( 'DROPPED ITEM TABLE '  || ' going to send notification ' , 1 ) ;

                      CTO_UTILITY_PK.send_notification (
                            P_PROCESS                      =>  CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).process
                           ,P_LINE_ID                      =>  CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).line_id
                           ,P_SALES_ORDER_NUM              => CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).sales_order_num
                           ,P_ERROR_MESSAGE                => CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).error_message
                           ,P_TOP_MODEL_NAME               => CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).top_model_name
                           ,P_TOP_MODEL_LINE_NUM           => CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).top_model_line_num
                           ,P_TOP_CONFIG_NAME              => CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).top_config_name
                           ,P_TOP_CONFIG_LINE_NUM          => CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).top_config_line_num
                           ,P_PROBLEM_MODEL                => CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).problem_model
                           ,P_PROBLEM_MODEL_LINE_NUM       => CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).problem_model_line_num
                           ,P_PROBLEM_CONFIG               => CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).problem_config
                           ,P_ERROR_ORG                    => CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).error_org
                           ,P_NOTIFY_USER                  => CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).notify_user
                           ,P_REQUEST_ID                   =>  CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).request_id
                           ,P_MFG_REL_DATE                 =>  CTO_CONFIG_BOM_PK.g_t_dropped_item_type(i).mfg_rel_date );

                      oe_debug_pub.add( 'DROPPED ITEM TABLE '  || ' sent notification ' , 1 ) ;


                   end loop ;

               else

                      oe_debug_pub.add( 'DROPPED ITEM TABLE '  || ' is empty ' , 1 ) ;

               end if ;


              commit ;  -- AUTONOMOUS TRANSACTION

             oe_debug_pub.add('SEND_OID_NOTIFICATION : ******** END AUTONOMOUS TRANSACTION FOR SEND_OID_NOTIFICATION **********' , 1 );
             CTO_CONFIG_BOM_PK.g_t_dropped_item_type.delete;

end send_oid_notification ;





procedure get_planner_code( p_inventory_item_id   in number
                         , p_organization_id     in number
                         , x_planner_code        out NOCOPY fnd_user.user_name%type )
is
begin

          IF PG_DEBUG <> 0 THEN
             oe_debug_pub.add('create_bom_ml: ' || 'Getting the planner code ..',3);
          END IF;

          BEGIN
            -- bugfix 2203802: Instead of getting the planner code directly from MSI,
            --                 get the corresponding application user.

               SELECT  u.user_name
                INTO   x_planner_code
                FROM   mtl_system_items_vl item
                      ,mtl_planners p
                      ,fnd_user u
               WHERE item.inventory_item_id = p_inventory_item_id
               and   item.organization_id   = p_organization_id
               and   p.organization_id = item.organization_id
               and   p.planner_code = item.planner_code
               and   p.employee_id = u.employee_id(+);         --outer join b'cos employee need not be an fnd user.


              oe_debug_pub.add('create_bom_ml: ' || '****PLANNER CODE DATA' || x_planner_code ,2);


          EXCEPTION

              WHEN OTHERS THEN
                   IF PG_DEBUG <> 0 THEN
                      oe_debug_pub.add('create_bom_ml: ' || 'Error in getting the planner code data. Defaulting to SYSADMIN.',2);

                      oe_debug_pub.add('create_bom_ml: ' || 'Error Message : '||sqlerrm,2);

                      x_planner_code := 'SYSADMIN' ;

                   END IF;
          END;


          oe_debug_pub.add('create_bom_ml: ' || '****PLANNER CODE DATA' || x_planner_code ,2);

end get_planner_code ;


procedure handle_expected_error( p_error_type           in number
                     , p_inventory_item_id    in number
                     , p_organization_id      in number
                     , p_line_id              in number
                     , p_sales_order_num      in number
                     , p_top_model_name       in varchar2
                     , p_top_model_line_num   in varchar2
                     , p_top_config_name       in varchar2 default null
                     , p_top_config_line_num   in varchar2 default null
                     , p_msg_count            in number
                     , p_planner_code         in varchar2
                     , p_request_id           in varchar2
                     , p_process              in varchar2 )
is
v_recipient      varchar2(200) ;
begin

                    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('handle_expected_error: entered handle_expected_error ' , 3);
                       oe_debug_pub.add('handle_expected_error: p_inventory_item_id ' || p_inventory_item_id , 3);
                       oe_debug_pub.add('handle_expected_error: p_organization_id ' || p_organization_id , 3);
                       oe_debug_pub.add('handle_expected_error: p_line_id ' || p_line_id , 3);
                       oe_debug_pub.add('handle_expected_error: p_sales_order_num ' || p_sales_order_num , 3);
                       oe_debug_pub.add('handle_expected_error: p_top_model_name ' || p_top_model_name , 3);
                       oe_debug_pub.add('handle_expected_error: p_top_model_line_num ' || p_top_model_line_num , 3);
                       oe_debug_pub.add('handle_expected_error: p_top_config_name ' || p_top_config_name , 3);
                       oe_debug_pub.add('handle_expected_error: p_top_config_line_num ' || p_top_config_line_num , 3);
                       oe_debug_pub.add('handle_expected_error: p_msg_count ' || p_msg_count , 3);
                       oe_debug_pub.add('handle_expected_error: p_planner_code ' || p_planner_code , 3);
                       oe_debug_pub.add('handle_expected_error: p_request_id ' || p_request_id , 3);
                       oe_debug_pub.add('handle_expected_error: ********    P_PROCESS ******** ' || p_process , 3);


                       oe_debug_pub.add('handle_expected_error: ' || 'Getting Custom Recipient..',3);
                    END IF;

                    v_recipient := CTO_CUSTOM_NOTIFY_PK.get_recipient( p_error_type        => p_error_type
                                                                      ,p_inventory_item_id => p_inventory_item_id
                                                                      ,p_organization_id   => p_organization_id
                                                                      ,p_line_id           => p_line_id );




                    if( v_recipient is not null ) then

                        IF PG_DEBUG <> 0 THEN
                           oe_debug_pub.add('handle_expected_error: ' || 'Recipient returned from CTO_CUSTOM_NOTIFY_PK..' || v_recipient ,3);
                        END IF;

                    else
                        v_recipient := p_planner_code ;
                        IF PG_DEBUG <> 0 THEN
                           oe_debug_pub.add('handle_expected_error: ' || 'planner code is ..' || v_recipient ,3);
                        END IF;
                    end if;





                    CTO_UTILITY_PK.notify_expected_errors ( P_PROCESS        => p_process
                           ,P_LINE_ID               => p_line_id
                           ,P_SALES_ORDER_NUM       => p_sales_order_num
                           ,P_TOP_MODEL_NAME        => p_top_model_name
                           ,P_TOP_MODEL_LINE_NUM    => p_top_model_line_num
                           ,P_TOP_CONFIG_NAME        => p_top_config_name
                           ,P_TOP_CONFIG_LINE_NUM    => p_top_config_line_num
                           ,P_MSG_COUNT             => p_msg_count
                           ,P_NOTIFY_USER           => v_recipient
                           ,P_REQUEST_ID            => p_request_id ) ;

                    IF PG_DEBUG <> 0 THEN
                           oe_debug_pub.add('handle_expected_error: ' || 'done handle_expected_error..' ,3);
                    END IF;


end handle_expected_error;


/********************************************************************************************************************************
 *                 The following procedure create_item_attachments is added by
 *                 Renga Kannan on 01/20/04. This procedure will create item
 *                 attachment for all the PO validations orgs for a specific
 *                 config item. Based on the new design for J, we will create
 *                 attachment for all the config irrespective of make or
 *                 buy.This is because in the case of cib attribute 3, it will
 *                 be very difficult to find out the model sourcing info. for
 *                 cib 1 and 2 it will be very difficult to derive this info.
 *                 Also, just having an item level attachment will not affect
 *                 any other functionality. Hence, As per Uhsa it is ok to
 *                 create attachment for all the configs in all possible po
 *                 validation orgs.
 *
 *
 **********************************************************************************************************************************/

 Procedure Create_item_attachments(
                                    p_ato_line_id     in   Number,
                                    x_return_status   out  NOCOPY Varchar2,
                                    x_msg_count       out  NOCOPY Number,
                                    x_msg_data        out  NOCOPY Varchar2)  is

   l_attach_text			long;
   l_document_id			Number;

   Cursor config_items_cur is
      Select bcol.line_id,
	     bcol.config_item_id
       from  bom_cto_order_lines bcol
       where ato_line_id = p_ato_line_id
       and   config_item_id is not null;

   Cursor config_orgs_cur(p_config_item_id  Number) is

       SELECT distinct nvl(fsp.inventory_organization_id,0) po_valid_org
       FROM   financials_system_params_all fsp
        Where fsp.org_id in (select org.operating_unit
	                     from   inv_organization_info_v org,
			            mtl_system_items msi
			     where  msi.inventory_item_id = p_config_item_id
			     and    msi.organization_id   = org.organization_id);

Begin

  For config_items_rec in config_items_cur
  Loop

     l_attach_text := '';
     CTO_UTILITY_PK.generate_bom_attach_text
			(p_line_id		=> config_items_rec.line_id
			,x_text			=> l_attach_text
			,x_Return_Status	=> x_Return_Status);

     For config_orgs_rec in config_orgs_cur(config_items_rec.config_item_id)
     Loop

        -- The validation part is added by Renga Kannan on 08/29/01
        -- Before creating the attachments first we need to verify that
        -- they are already existing for this item. It they are existing
        -- We should not create it once again.

        IF PG_DEBUG <> 0 THEN
     	   oe_debug_pub.add('Cto_Utility_pk: ' || 'Creating attachment for line id = '
   	                                                     ||to_char(config_items_rec.line_id),1);
	   oe_debug_pub.add('Cto_Utility_pk: '|| 'Config item id = '||to_char(config_items_rec.config_item_id),1);
	   oe_debug_pub.add('Cto_Utility_pk: '|| 'Po Validation Org = '||to_char(config_orgs_rec.po_valid_org),1);
        END IF;

        BEGIN
           SELECT document_id
           INTO   l_document_id
           FROM   FND_ATTACHED_DOCUMENTS
           WHERE  pk1_value   = to_char(config_orgs_rec.po_valid_org)	-- 2774570
           AND    pk2_value   = to_char(config_items_rec.config_item_id)	-- 2774570
           AND    entity_name = 'MTL_SYSTEM_ITEMS'
           AND    Pk3_value   = 'CTO:BOM:ATTACHMENT';

           IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('Cto_Utility_pk: '
		                 || 'Bom attachment already exists for this item.. document_id ='||to_char(l_document_id),1);
           END IF;
        EXCEPTION
	   WHEN NO_DATA_FOUND THEN
           IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('Cto_Utility_pk: '
		                 || 'There is no bom document  attached to this item.. We need to attach the document',1);
           END IF;

           IF l_attach_text is not null THEN

              CTO_UTILITY_PK.create_attachment
				(p_item_id	=> config_items_rec.config_item_id,
                                 p_org_id	=> config_orgs_rec.po_valid_org,
                                 p_text		=> l_attach_text,
				 p_desc		=> 'Bill Of Material Details',
                                 p_doc_type	=> 'CTO:BOM:ATTACHMENT',
                                 x_Return_Status => x_Return_Status);

              IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('Cto_Utility_pk: ' || 'Return status from create_attachment after bom attachment='
		                                                  ||x_Return_Status,1);
              END IF;

           END IF;
        END;

      End Loop;
  End Loop;
Exception When Others Then
    oe_debug_pub.add('Some Error occured in generating attachment',1);
    oe_debug_pub.add('Ignoring the error and continuing the process',1);
End Create_item_attachments;



-- bugfix 4044709 : Created new procedure to handle validation

  PROCEDURE validate_oe_data (  p_bcol_line_id  in      bom_cto_order_lines.line_id%type,
                                x_return_status out NOCOPY varchar2)
  is

  v_step                VARCHAR2(15) ;
  vbcol_line_id         NUMBER;
  voe_match_flag        VARCHAR2(1);
  bcol_count            NUMBER;
  oe_count              NUMBER;

  Type bcol_line_tbl_type IS TABLE OF number INDEX BY BINARY_INTEGER;

  l_bcol_line_tbl       bcol_line_tbl_type ;
  l_last_index          NUMBER;

  v_oe_bcol_diff     varchar2(1) := 'N' ;


  begin

    x_return_status := FND_API.G_RET_STS_SUCCESS ;

    v_step := 'Step A17' ;

    --
    -- We will check if BCOL picture is in sync with OEOL picture.
    -- First, we will see if the count matches. If not, raise error.
    -- Then, check if the line_ids match. If not, raise error.
    -- This is to avoid situations as mentioned in bug 3443450
    --

     select count(*) into bcol_count
    from bom_cto_order_lines
    where ato_line_id = p_bcol_line_id;

    select count(*) into oe_count
    from oe_order_lines_all
    where ato_line_id = p_bcol_line_id
    and item_type_code <>'CONFIG'
    and ordered_quantity > 0 ;  -- Added this condition to take care of cancel line cases.

    if bcol_count <> oe_count then
        IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add ('validate_oe_data: '||v_step||': OE count '||oe_count||' and BCOL count '||bcol_count||' does not match.');
        END IF;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;











     v_oe_bcol_diff:= 'N' ;

     begin
             select 'Y' into v_oe_bcol_diff from dual
             where exists
                   ((Select 1
                    from oe_order_lines_all oel
                    Where not exists
                         ( Select bcol.line_id,
                                  bcol.ordered_quantity,
                                  bcol.inventory_item_id
                             from bom_cto_order_lines bcol
                            where bcol.ato_line_id = p_bcol_line_id
                              and bcol.line_id = oel.line_id
                              and bcol.ordered_quantity = oel.ordered_quantity
                              and bcol.inventory_item_id = oel.inventory_item_id
                          )
                      AND oel.top_model_line_id is not null
                      AND oel.ato_line_id = p_bcol_line_id
                      AND oel.item_type_code <>'CONFIG'
                      AND oel.ordered_quantity > 0  ) -- Added this condition to take care of cancel line cases.
                    UNION
                    (Select 1
                    from bom_cto_order_lines bcol
                    Where not exists
                          ( Select oel.line_id,
                                   oel.ordered_quantity,
                                   oel.inventory_item_id
                              from oe_order_lines_all oel
                             where oel.ato_line_id = p_bcol_line_id
                              and oel.line_id = bcol.line_id
                              and oel.ordered_quantity = bcol.ordered_quantity
                              and oel.inventory_item_id = bcol.inventory_item_id
                              and oel.item_type_code <>'CONFIG'
                              and oel.ordered_quantity > 0  -- Added this condition to take care of cancel line cases.
                          )
                      AND bcol.top_model_line_id is not null
                      AND bcol.ato_line_id = p_bcol_line_id )) ;

           IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add ('validate_oe_data: Symmetric Difference between OEL and BCOL did return rows .');
           END IF;


           v_oe_bcol_diff := 'Y' ;

     exception
     when no_data_found then

           IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add ('validate_oe_data: Symmetric Difference between OEL and BCOL did not return any rows .');
           END IF;

     when others then

           IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add ('validate_oe_data: Symmetric Difference between OEL and BCOL did result in error .' || SQLCODE );
              oe_debug_pub.add ('validate_oe_data: Symmetric Difference between OEL and BCOL did result in error .' || SQLERRM );
           END IF;

           v_oe_bcol_diff := 'Y' ;


     end ;


    if( v_oe_bcol_diff = 'Y' ) then
           IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add ('validate_oe_data: data in BCOL and OE_ORDER_LINES_ALL does not match' , 1);
           END IF;
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;





  exception
     when OTHERS then
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        oe_debug_pub.add('validate_oe_data: ' || 'validate_oe_data::others:: '||sqlerrm,1);


  end validate_oe_data ;

    /* end bugfix 4044709 */

--
-- bugfix 4227993: added private function get_lock_handle.
-- This function allocates a unique user lock handle.
--
--
-- bug 7203643
-- changed the hash value variable type to varchar2
-- ntungare
--
FUNCTION get_lock_handle (
	 p_hash_string   IN VARCHAR2) RETURN VARCHAR2 IS

   PRAGMA AUTONOMOUS_TRANSACTION;
   l_lock_handle VARCHAR2(128);
   l_lock_name   VARCHAR2(30);
BEGIN

   l_lock_name := 'CTO_' || p_hash_string;
   --
   -- bug 7203643
   -- added expiration seconds equal to 1 day instead of
   -- the default 10 days
   -- ntungare
   --
   dbms_lock.allocate_unique(
	 lockname	 => utl_raw.cast_to_raw(l_lock_name)
	,lockhandle	 => l_lock_handle
        ,expiration_secs => 86400);
   return l_lock_handle;

END get_lock_handle;

--
-- bugfix 4227993: added public procedure lock_for_match.
--
-- This procedure performs the following steps:
-- 1. Builds up a string to uniquely identify a configuration in BAC
-- 2. For large configurations, it gets the 1st and the last 50-components (hardcoded) and
--    appends it to the count of optional components selected.
-- 3. Get the hash-value of this string and then get the user-lock handle by calling
--    the above function get_lock_handle.
-- 4. If lock cannot be acquired, it is possible that some other process is processing
--    the same configuration (although for a different order-line). In this case,
--    it will just wait until the other process commits.
-- 5. If a deadlock or other internal error occurs, lock_status is accordingly set and
--    passed to the calling program.
--
-- bug 7203643
-- changed the hash value variable type to varchar2
-- ntungare
--
PROCEDURE lock_for_match(
		x_return_status	OUT nocopy varchar2,
        	xMsgCount       OUT nocopy number,
        	xMsgData        OUT nocopy varchar2,
		x_lock_status	OUT nocopy number,
    		x_hash_value	OUT nocopy varchar2,
		p_line_id	IN  number)
IS

    g_hash_base 	number := 1;
    g_hash_size 	number := power(2, 25);

    l_lock_handle 	varchar2(128);

    -- Hardcode the COMPARESIZE to 50. We decided not to go with a profile as it is
    -- technical in nature and we thought its an overkill.

    COMPARESIZE	number := 50;
    str			varchar2(2000);
    j			number;
    loop_limit		number;

    type l_comp_item_id_tab 	is TABLE OF number index by binary_integer;
    l_comp_item_id  		l_comp_item_id_tab;


    cursor c1 is
       select  nvl(decode(bcolOptions.line_id, bcolModel.line_id, bcolOptions.inventory_item_id,
                                                                  bcolOptions.config_item_id),
                   bcolOptions.inventory_item_id) COMPONENT_ITEM_ID
       from
               bom_cto_order_lines_gt bcolModel,       -- Model  /* sushant made changes for bug 4341156 */
               bom_cto_order_lines_gt bcolOptions      -- Options /* sushant made changes for bug 4341156 */
        where  bcolModel.line_id = p_line_id
        and    (bcolOptions.parent_ato_line_id = bcolModel.line_id or
                bcolOptions.line_id = bcolModel.line_id)
	order by 1;

BEGIN
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       x_lock_status   := 0;
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Lock_For_Match Start Time: '||to_char(sysdate , 'MM/DD/YYYY HH24:MI:SS'));

       OPEN c1;
       FETCH c1 BULK COLLECT INTO l_comp_item_id;

       if l_comp_item_id.count = 0 then
	-- This situation should never arise. If it does, raise error.
	     oe_debug_pub.add ('l_comp_item_id.count = 0. Raising error..');
	     raise FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;

       IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add ('Number of records selected = '|| l_comp_item_id.count);
          oe_debug_pub.add ('COMPARESIZE = '|| COMPARESIZE);
       END IF;

       if (l_comp_item_id.count > COMPARESIZE) then
	-- Get the first N components
	  for i in 1 .. COMPARESIZE
	  loop
	     str := str || l_comp_item_id(i);
   	     IF PG_DEBUG <> 0 THEN
	        oe_debug_pub.add (' str = '||str);
	     END IF;
	     if (i < COMPARESIZE) then
	        str := str || '-';	-- Append "-" for each value.
	     end if;
	  end loop;

	  str := str || '***';	-- Append "***" between directions

	-- Get the last N components
          j := l_comp_item_id.count;
 	  loop_limit := j - COMPARESIZE;

          while (j <> loop_limit)
          loop
	     str := str || l_comp_item_id(j);
   	     IF PG_DEBUG <> 0 THEN
	        oe_debug_pub.add (' str = '||str);
	     END IF;
             j := j - 1;
	     if (j <> loop_limit) then
		  str := str || '-';
	     end if;
   	  end loop;

       elsif (l_comp_item_id.count > 0 and l_comp_item_id.count < COMPARESIZE) then
	-- Get all the components
	  for i in 1 .. l_comp_item_id.count
	  loop
	     str := str || l_comp_item_id(i);
   	     IF PG_DEBUG <> 0 THEN
	        oe_debug_pub.add (' str = '||str);
	     END IF;
	     if (i < l_comp_item_id.count) then
	        str := str || '-';	-- Append "-" for each value.
	     end if;
	  end loop;
       end if;

	str := l_comp_item_id.count||'*'||str;

   	IF PG_DEBUG <> 0 THEN
	   oe_debug_pub.add ('str = '|| str);
   	END IF;

        --
        -- bug 7203643
        -- Using the MD5 hashing algorithm to get the hash values
        -- ntungare
        --
	/*
        x_hash_value := dbms_utility.get_hash_value(
                                  name => str,
                                  base => g_hash_base,
                                  hash_size =>g_hash_size );*/

        x_hash_value := DBMS_OBFUSCATION_TOOLKIT.MD5(
                                  input_string => str);

   	IF PG_DEBUG <> 0 THEN
            -- bug 7203643
	    --oe_debug_pub.add ('x_hash_value = '||x_hash_value);
            oe_debug_pub.add ('x_hash_value = '||utl_raw.cast_to_raw(x_hash_value));
   	END IF;

	l_lock_handle := get_lock_handle (p_hash_string => x_hash_value );

   	IF PG_DEBUG <> 0 THEN
            -- bug 7203643
	    --oe_debug_pub.add ('x_hash_value = '||x_hash_value);
            oe_debug_pub.add ('l_lock_handle = '||l_lock_handle);
   	END IF;

        --
        -- request lock with release_on_commit TRUE so that we dont have to manually
	-- release the lock later.
	--
        x_lock_status := dbms_lock.request(
	   lockhandle	   => l_lock_handle
	  ,lockmode	   => dbms_lock.x_mode
	  ,timeout	   => dbms_lock.maxwait
          ,release_on_commit => TRUE);

   	IF PG_DEBUG <> 0 THEN
	   oe_debug_pub.add ('lock_for_match: Returning from lock_for_match.');
   	END IF;
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Lock_For_Match End Time: '||to_char(sysdate , 'MM/DD/YYYY HH24:MI:SS'));

EXCEPTION

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR then
      	oe_debug_pub.add('lock_for_match: ' || 'Unexpected Error.');
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        --  Get message count and data
        cto_msg_pub.count_and_get
          (  p_msg_count  => xMsgCount
           , p_msg_data   => xMsgData
             );
   WHEN OTHERS then
      	oe_debug_pub.add('lock_for_match: ' || 'Others Exception : ' || sqlerrm);
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        --  Get message count and data
        cto_msg_pub.count_and_get
          (  p_msg_count  => xMsgCount
           , p_msg_data   => xMsgData
             );
END;


-- bugfix 4227993:
-- Procedure
--   release_lock
-- Description
--   this function releases the user lock on the generated hash-value.
--   Users who call lock_for_match do not always have to call release_lock explicitly.
--   The lock is released automatically at commit, rollback, or session loss.
--
-- bug 7203643
-- changed the hash value variable type to varchar2
-- ntungare
--
PROCEDURE release_lock(
     x_return_status        OUT NOCOPY VARCHAR2
   , x_msg_count            OUT NOCOPY NUMBER
   , x_msg_data             OUT NOCOPY VARCHAR2
   , p_hash_value	    IN  VARCHAR2)

IS
   l_return_status        VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_lock_handle          VARCHAR2(128);
   l_status               INTEGER;


BEGIN

   --validate hash_value
   IF (p_hash_value IS NULL) THEN
	--raise error condition
	 oe_debug_pub.add('RELEASE_LOCK: Hash Value is null but required for releasing lock.');
         RAISE fnd_api.g_exc_error;
   END IF;


   --get lock handle by calling helper function
   l_lock_handle := get_lock_handle( p_hash_string   => p_hash_value);


   l_status := dbms_lock.release(l_lock_handle);

   --if success (status = 0) or session does not own lock (status=4),
   -- 	do nothing
   --if parameter error or illegal lock handle (internal error)
   if l_status IN (3,5) THEN
      cto_msg_pub.cto_message('BOM','BOM_LOCK_RELEASE_ERROR');
      RAISE fnd_api.g_exc_error;
   end if;

   x_return_status := l_return_status;

EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      	oe_debug_pub.add('release_lock: ' || 'expected error');
        x_return_status := fnd_api.g_ret_sts_error;

   WHEN fnd_api.g_exc_unexpected_error THEN
      	oe_debug_pub.add('release_lock: ' || 'Unexpected error');
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

    WHEN OTHERS THEN
      	oe_debug_pub.add('release_lock: ' || 'Others Exception : ' || sqlerrm);
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

END release_lock;




/*******************************************************************************************
-- API name : get_resv_qty
-- Type     : Public
-- Pre-reqs : None.
-- Function : Given config/ato item Order line id  it returns
--            the supply details tied to this line in a record structure. Also, it return the
              total supply qty in primary uom and pass the primary uom code to the calling module.
-- Parameters:
-- IN       : p_order_line_id     Expects the config/ato item order line       Required
--
-- OUT      : x_rsv_rec           Record strcutre with each supply type
                                  and supply qty in primary uom
	      x_primary_uom_code  Primary uom code of the order line's
	                          inventory item id .
	      x_sum_rsv_qty       Sum of supply quantities tied to the
	                          order line in primary uom.
	      x_return_status     Standard error message status
	      x_msg_count         Std. error message count in the message stack
	      x_msg_data          Std. error message data in the message stack
-- Version  :
--
--
******************************************************************************************/

PROCEDURE Get_Resv_Qty
               ( p_order_line_id                 NUMBER,
		 x_rsv_rec          OUT  NOCOPY  CTO_UTILITY_PK.resv_tbl_rec_type,
		 x_primary_uom_code OUT  NOCOPY  VARCHAR2,
		 x_sum_rsv_qty	    OUT  NOCOPY  NUMBER,
                 x_return_status    OUT  NOCOPY  VARCHAR2,
		 x_msg_count	    OUT  NOCOPY  NUMBER,
                 x_msg_data	    OUT  NOCOPY  VARCHAR2
	        )
IS



l_index number;

v_open_flow_qty NUMBER; --OPM and Ireq
i number;
lStmtNum number;
k        number;
l        number;
l_message VARCHAR2(200);
l_source_document_type_id    number;






--This gets the reservation_qty and the type of reservation
-- Modified by Renga Kannan on 06/24/05 for Cross Dock project
-- getting reservation qty for ASN, Internal req and Receiving supply types also
-- Also, getting the primary UOM

CURSOR c_resv IS
  select sum(nvl(primary_reservation_quantity,0)) primary_reservation_quantity,--bugfix2466429
         sum(nvl(reservation_quantity,0)) secondary_reservation_quantity, --OPM
         supply_source_type_id
  from   mtl_reservations
  where  demand_source_type_id = decode (l_source_document_type_id, 10,
                                         inv_reservation_global.g_source_type_internal_ord,
					 inv_reservation_global.g_source_type_oe )	-- bugfix 1799874
  and    demand_source_line_id = p_order_line_id
  and    supply_source_type_id IN
                                 ( inv_reservation_global.g_source_type_inv,
				   inv_reservation_global.g_source_type_wip,
				   inv_reservation_global.g_source_type_po,
				   inv_reservation_global.g_source_type_req,
				   inv_reservation_global.g_source_type_internal_req,
				   inv_reservation_global.g_source_type_asn,
				   inv_reservation_global.g_source_type_rcv
				  )
  group by supply_source_type_id;

 --opm and ireq
 l_ext_req_qty		  number;
 l_int_req_qty		  number;
 l_ext_req_secondary_qty  Number;
 l_int_req_secondary_qty  Number;

BEGIN

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --need this for flow and interface data alone
      Select msi.primary_uom_code
	into   x_primary_uom_code
	from   mtl_system_items msi,
	       oe_order_lines_all oel
	where  msi.inventory_item_id = oel.inventory_item_id
	and    msi.organization_id   = oel.ship_from_org_id
	and    oel.line_id = p_order_line_id; --bugfix 4557050

      IF PG_DEBUG <> 0 THEN
	     oe_debug_pub.add('get_resv_qty: ' || 'Entered get_resv_qty', 1);
             l_message := 'Entered get_rsv_qty_code';
	     cto_wip_workflow_api_pk.cto_debug('get_resv_qty:', l_message);
	     oe_debug_pub.add('get_resv_qty: ' || 'Before cursor c_resv', 5);
	     l_message := 'Before cursor c_resv';
	     cto_wip_workflow_api_pk.cto_debug('get_resv_qty:', l_message);
      END IF;

      l_source_document_type_id := CTO_UTILITY_PK.get_source_document_id ( pLineId => p_order_line_id );

      lStmtNum := 10;
      FOR cur_var in c_resv
      LOOP
        l_index := cur_var.supply_source_type_id;

	x_rsv_rec(l_index).supply_source_type_id          := l_index;
 	x_rsv_rec(l_index).primary_reservation_quantity   := cur_var.primary_reservation_quantity;
        x_rsv_rec(l_index).secondary_reservation_quantity := cur_var.secondary_reservation_quantity;


        IF PG_DEBUG <> 0 THEN
	     oe_debug_pub.add('get_resv_qty:'||'source_id=>' || cur_var.supply_source_type_id, 5);
             l_message := 'source_id=>'|| cur_var.supply_source_type_id;
             cto_wip_workflow_api_pk.cto_debug('get_resv_qty:', l_message);

             oe_debug_pub.add('get_resv_qty:'||'prim_rsv_qty=>' || cur_var.primary_reservation_quantity, 5);
	     l_message := 'rsv_qty=>' || cur_var.primary_reservation_quantity;
             cto_wip_workflow_api_pk.cto_debug('get_resv_qty:', l_message);

	     oe_debug_pub.add('get_resv_qty:'||'sec_rsv_qty=>' || cur_var.secondary_reservation_quantity, 5);
	     l_message := 'sec_rsv_qty=>' || cur_var.secondary_reservation_quantity;
             cto_wip_workflow_api_pk.cto_debug('get_resv_qty:', l_message);

        END IF;

      END LOOP;

      IF PG_DEBUG = 5 THEN
         oe_debug_pub.add('get_resv_qty:'||'printing rsv source type and qty in loop', 5);
         l_message := 'printing rsv source type and qty in loop';
	 cto_wip_workflow_api_pk.cto_debug('get_resv_qty:', l_message);

         oe_debug_pub.add('get_resv_qty:'||'RSV_SRC_TYP  '||' Prim Quantity '
	                                          ||' Sec qunatity ', 5);


         IF x_rsv_rec.count <> 0 THEN
           k := x_rsv_rec.first;
	   WHILE(k is not null)
	   LOOP

	     oe_debug_pub.add('get_resv_qty:'||x_rsv_rec(k).supply_source_type_id
	                       ||' => ' ||x_rsv_rec(k).primary_reservation_quantity
			       ||' => ' ||x_rsv_rec(k).secondary_reservation_quantity,5);


             l_message := x_rsv_rec(k).supply_source_type_id
	                       ||' => ' ||x_rsv_rec(k).primary_reservation_quantity
			       ||' => ' ||x_rsv_rec(k).secondary_reservation_quantity;

	     cto_wip_workflow_api_pk.cto_debug('get_resv_qty:', l_message);

             k := x_rsv_rec.next(k);
	   END LOOP;
         END IF;

      END IF;

      lStmtNum := 20;
      -- 3076061  Flow Schedule status : 1 = Open  2 = Closed/Completed


	-- begin bugfix 3174334
	-- Since flow does not update the schedule with new line_id when the order line is split, we need
	-- to call the following function which will determine the open quantity.
	-- If open_qty exists, we should keep the line status in PRODUCTION_OPEN

	--OPM and IREQ (kkonada), get flow open quantity from MRP api
	--This would work for both fresh order line and split order line

	-- As per Kiran, Flow API allwasy returns in primary reservation qty.

	lStmtNum := 30;


        lStmtNum := 40;
	v_open_flow_qty :=
		MRP_FLOW_SCHEDULE_UTIL.GET_FLOW_QUANTITY( p_demand_source_line     => to_char(p_order_line_id),
							  p_demand_source_type     => inv_reservation_global.g_source_type_oe,
							  p_demand_source_delivery => NULL,
							  p_use_open_quantity      => 'Y');
                IF PG_DEBUG <> 0 THEN
	             oe_debug_pub.add('get_resv_qty:'||'flow open quantity =>' || v_open_flow_qty, 5);
                END IF;
	-- Added by Renga Kannan on 06/27/05
	-- Getting the primary uom code from mtl system items.

        If v_open_flow_qty <> 0 then




	-- end bugfix 3174334

        lStmtNum := 45;

           IF PG_DEBUG <> 0 THEN
	             oe_debug_pub.add('get_resv_qty:'||'adding flow to x_rsv_rec', 5);
           END IF;

          --add this to record structure
           l_index := CTO_UTILITY_PK.g_source_type_flow;

	   --flow qty is not reserved thru inv so cannot consider as reservation_qty
	   --Hence assigimng the qty to record structure
	   --Supply source type id is hard coded to in CTOWFAPS as constant
	   x_rsv_rec(l_index).primary_reservation_quantity           := v_open_flow_qty;
	   x_rsv_rec(l_index).supply_source_type_id                  := l_index;

	End if; /* v_open_flow_qty */

       --OPM and Ireq kkonada , get interface data
       --added join with oel as part of code review

         Select sum(CTO_UTILITY_PK.convert_uom(po.uom_code,x_primary_uom_code,nvl(po.quantity,0),po.item_id)),
	        sum(nvl(po.secondary_quantity,0))
	 into   l_ext_req_qty,
	        l_ext_req_secondary_qty
	 from   po_requisitions_interface_all po,
	        oe_order_lines_all oel
	 where  po.interface_source_line_id = oel.line_id
	 and    oel.line_id = p_order_line_id
	 and    po.item_id = oel.inventory_item_id
	 and    po.source_type_code = 'VENDOR'
	 and    po.process_flag is null;

         Select sum(CTO_UTILITY_PK.convert_uom(po.uom_code,x_primary_uom_code,nvl(po.quantity,0),po.item_id)),
	        sum(nvl(po.secondary_quantity,0))
	 into   l_int_req_qty,
	        l_int_req_secondary_qty --changed as part of opm code review
	 from   po_requisitions_interface_all po,
	        oe_order_lines_all oel
	 where  po.interface_source_line_id = oel.line_id
         and    oel.line_id = p_order_line_id
         and    po.item_id = oel.inventory_item_id
	 and    po.source_type_code = 'INVENTORY'
	 and    po.process_flag is null;


	 --add external and internal req intf data to record struc
	 If l_ext_req_qty is not null then
           l_index := CTO_UTILITY_PK.g_source_type_ext_req_if;
           x_rsv_rec(l_index).primary_reservation_quantity           := l_ext_req_qty;
	   x_rsv_rec(l_index).secondary_reservation_quantity         := l_ext_req_secondary_qty;
	   x_rsv_rec(l_index).supply_source_type_id                  := l_index;
	 end if;

         If l_int_req_qty is not null then
           l_index := CTO_UTILITY_PK.g_source_type_int_req_if;
           x_rsv_rec(l_index).primary_reservation_quantity           := l_int_req_qty;
	   x_rsv_rec(l_index).secondary_reservation_quantity         := l_int_req_secondary_qty;
	   x_rsv_rec(l_index).supply_source_type_id                  := l_index;
         end if;

         x_sum_rsv_qty := 0;
	 i := x_rsv_rec.first;
         WHILE(i is not null)
         LOOP
           x_sum_rsv_qty :=  x_sum_rsv_qty + x_rsv_rec(i).primary_reservation_quantity;
           i := x_rsv_rec.next(i);
	 END LOOP;


EXCEPTION
 WHEN fnd_api.g_exc_error THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('get_resv_qty: ' || 'Exception in stmt num: '
		                    || to_char(lStmtNum), 1);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
   WHEN fnd_api.g_exc_unexpected_error THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('get_resv_qty: '|| ' Unexpected Exception in stmt num: '
		                       || to_char(lStmtNum), 1);
       END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
   WHEN OTHERS then
	oe_debug_pub.add('errmsg'||sqlerrm);
       IF PG_DEBUG <> 0 THEN

        	oe_debug_pub.add('get_resv_qty: ' || 'Others Exception in stmt num: '
		                    || to_char(lStmtNum), 1);
       END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
END Get_Resv_Qty;

END CTO_UTILITY_PK;

/
