--------------------------------------------------------
--  DDL for Package Body CTO_MSUTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_MSUTIL_PUB" as
/* $Header: CTOMSUTB.pls 120.11.12010000.7 2011/11/22 09:05:51 ntungare ship $*/

/*----------------------------------------------------------------------------+
| Copyright (c) 1993 Oracle Corporation    Belmont, California, USA
|                       All rights reserved.
|                       Oracle Manufacturing
|
|FILE NAME   : CTOMSUTB.pls
|
|DESCRIPTION : Contains modules to :
|		1. Populate temporary tables bom_cto_order_lines and
|		bom_cto_src_orgs, used for intermediate CTO processing
|		2. Update these tables with the config_item_id
|		3. Copy sourcing rule assignments from model to config item
|
|HISTORY     : Created on 04-OCT-2003  by Sushant Sawant
|
|              Modified on 09-JAN-2004  by Sushant Sawant
|                                          Fixed Bug# 3349142
|                                          fixed insert into bcso for dropship/procure/no assignment set scenarios.
|
|
|              Modified on 12-FEB-2004  by Sushant Sawant
|                                          Fixed Bug# 3418684
|                                          Changed logic to not fork processing based in source_type
|                                          Supply Chain will be traversed for CIB = 1,2 irrespective of source_type
|
|               Modified   :    02-MAR-2004     Sushant Sawant
|                                               Fixed Bug 3472654
|                                               upgrades for matched config from CIB = 1 or 2 to 3 were not performed properly.
|                                               data was not transformed to bcmo.
|                                               perform_match check includes 'Y' and 'U'
|
|
|               Modified   :    17-MAR-2004     Sushant Sawant
|                                               Fixed bug 3504744.
|                                               bom_parameter may not exist for some organizations.
|
|               Modified   :    29-APR-2004     Sushant Sawant
|                                               Fixed bug 3598139
|                                               changed cursor c_parent_src_orgs to account for buy models and their children as
|                                               create_bom flag may not be set to 'Y' for such models.
|
|
|               Modified   :    14-MAY-2004     Sushant Sawant
|                                               Fixed bug 3484511.
|
|
|               Modified   :    14-MAY-2004     Sushant Sawant
|                                               Fixed bug 3640783. Sourcing across Operating Units with PO and OE
|                                               validation org as part of the supply chain for CIB = 1 results in errors.
|                                               This issue has been addressed as part of this fix.
|
|               modfieid        26-JUL-2004     Kiran Konada
|                                               	3785158
|                                               values were not incremented properly corrected
|
|               Modified   :    14-APR-2005     Sushant Sawant
|                                               Fixed bug fp bug 4227127. This is fp for bug 4162642.
|                                               Exception handling added for call to get_other_orgs.
|                                               Exception handling added to get_other_orgs procedure.
|                                               Original issue of handling sparse and or empty  array after deleting orgs from
|                                               the validation org list was already handled in 11.5.10 as part of bug 3640783.
|

|              Modified    :    05-Jul-2005     Renga Kannan
|                                               Modified for MOAC project
+-----------------------------------------------------------------------------*/

 G_PKG_NAME CONSTANT VARCHAR2(30) := 'CTO_MSUTIL_PUB';
 TYPE TAB_BCOL is TABLE of bom_cto_order_lines%rowtype index by binary_integer   ;
 gMrpAssignmentSet        number ;

 gUserId   number := nvl(fnd_global.user_id, -1);
 gLoginId  number := nvl(fnd_global.login_id, -1);

 type x_orgs_tbl_type is table of number index by binary_integer;        --Bugfix 7522447/7410091
 x_orgs_tbl     x_orgs_tbl_type;                                         --Bugfix 7522447/7410091


procedure process_sourcing_chain(
        p_model_item_id         IN  number
      , p_organization_id       IN  number
      , p_line_id               IN  number
      , p_top_ato_line_id       IN  number
      , p_mode                  IN  varchar2 default 'AUTOCONFIG'
      , p_config_item_id        IN  number default NULL
      , px_concat_org_id        IN OUT NOCOPY varchar2
      , x_return_status         OUT NOCOPY varchar2
      , x_msg_count             OUT NOCOPY number
      , x_msg_data              OUT NOCOPY varchar2

) ;


procedure insert_type3_bcso( p_top_ato_line_id       in NUMBER
                    , p_model_line_id in NUMBER
                    , p_model_item_id in NUMBER
                    , p_config_item_id in NUMBER default null ) ;



procedure insert_type3_bcmo_bcso( p_top_ato_line_id       in NUMBER
                    , p_model_line_id in NUMBER
                    , p_model_item_id in NUMBER) ;





procedure insert_type3_referenced_bcso( p_top_ato_line_id       in NUMBER
                    , p_model_line_id in NUMBER
                    , p_model_item_id in NUMBER
                    , p_config_item_id in NUMBER default null ) ;


procedure procured_model_bcso_override ( p_line_id  in number
                             , p_model_item_id  in number
                             , p_ship_org_id  in number ) ;


  --
  -- Forward Declarations
  --
  PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);



/*--------------------------------------------------------------------------+
   This function identifies the model items for which configuration items need
   to be created and populates the temporary table bom_cto_src_orgs with all the
   organizations that each configuration item needs to be created in.
+-------------------------------------------------------------------------*/

FUNCTION Populate_Src_Orgs(pTopAtoLineId in number,
		           x_return_status	OUT	NOCOPY varchar2,
			   x_msg_count	OUT	NOCOPY number,
			   x_msg_data	OUT	NOCOPY varchar2)
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
             plan_level,
             config_creation,
             perform_match,
             config_item_id,
             option_specific
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
      and ( bcso.create_bom = 'Y' or bcso.organization_type in (  '3' , '4') ) ; /* 3598139 Buy Models may not have a bom */

   cursor c_debug is
      select line_id,
             model_item_id,
             rcv_org_id,
             organization_id,
             create_bom,
             create_src_rules,
             organization_type,
             group_reference_id
      from bom_cto_src_orgs
      where top_model_line_id = pTopAtoLineId;


   cursor get_each_type1_model is
      select line_id , inventory_item_id , config_creation from bom_cto_order_lines
       where bom_item_type = 1 and nvl(wip_supply_type, 1) <> 6
         and ato_line_id = pTopAtoLineId order by plan_level ;



  v_t_org_list  CTO_MSUTIL_PUB.org_list;

  v_current_model_line_id   number ;
  v_current_model_item_id   number ;
  v_config_creation         bom_cto_order_lines.config_creation%type ;


 v_group_reference_id       number ;
 v_orgs_list cto_oss_source_pk.orgs_list ;
 x_orgs_list                CTO_MSUTIL_PUB.org_list;

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

            if( v_model_lines.config_creation in ( 1, 2 ) ) then

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


            else

                oe_debug_pub.add( 'config creation 3 not yet implemented ' , 1) ;


                oe_debug_pub.add( '$$$$$$$$ TYPE 3 model line ' || v_model_lines.line_id , 1 ) ;


                if( v_model_lines.perform_match = 'N' ) then


                    oe_debug_pub.add( '$$$$$$$$ GOING TO CALL insert_type3_bcso ' || v_model_lines.line_id , 1 ) ;

                    CTO_MSUTIL_PUB.insert_type3_bcso( pTopAtoLineId
                                                    , v_model_lines.line_id
                                                    , v_model_lines.inventory_item_id ) ;

                elsif( v_model_lines.perform_match in (  'Y' , 'C' )  ) then


                    oe_debug_pub.add( '$$$$$$$$ GOING TO CALL insert_type3_referenced_bcso ' || v_model_lines.line_id , 1 ) ;

                    CTO_MSUTIL_PUB.insert_type3_referenced_bcso( pTopAtoLineId
                                                               , v_model_lines.line_id
                                                               , v_model_lines.inventory_item_id
                                                               , v_model_lines.config_item_id) ;

                    /* ACHTUNG: CHECK WHETHER YOU NEED A SHORT-CIRCUIT to type3_bcmo_bcso for no data found */


                elsif( v_model_lines.perform_match = 'U' ) then


                    oe_debug_pub.add( '$$$$$$$$ GOING TO CALL insert_type3_bcmo_bcso ' || v_model_lines.line_id , 1 ) ;

                    CTO_MSUTIL_PUB.insert_type3_bcmo_bcso( pTopAtoLineId
                                                         , v_model_lines.line_id
                                                         , v_model_lines.inventory_item_id ) ;

                end if ;







            end if ; /* config_creation check */




        oe_debug_pub.add( '$$$$$$$$$$$$Going to START GET OSS BOM ORGS for Create BOM Indication '  || to_char( v_model_lines.line_id )  , 1 ) ;
        oe_debug_pub.add( '$$$$$$$$$$$$Going to START GET OSS BOM ORGS for Create BOM Indication '  || v_model_lines.option_specific , 1 ) ;

        if(  v_model_lines.option_specific in ( '1' , '2',  '3' )  ) then  /* do not execute this code as we will be changing it tomorrow */

            oe_debug_pub.add( 'Going to Call GET OSS BOM ORGS for Create BOM Indication '  || to_char( v_model_lines.line_id)  , 1 ) ;


            cto_oss_source_pk.get_oss_bom_orgs( p_line_id => v_model_lines.line_id
                                            ,x_orgs_list => v_orgs_list
                                            ,x_return_status => x_return_status
                                            ,x_msg_count => x_msg_count
                                            ,x_msg_data => x_msg_data  ) ;






            if x_return_status = FND_API.G_RET_STS_ERROR then

                IF PG_DEBUG <> 0 THEN
                      oe_debug_pub.add ('GET_ALL_ITEM_ORGS: ' ||
                                        'Failed in cto_oss_source_pk.get_oss_bom_orgs with expected error.', 1);
                END IF;

                raise FND_API.G_EXC_ERROR;

            elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then

                IF PG_DEBUG <> 0 THEN
                      oe_debug_pub.add ('GET_ALL_ITEM_ORGS: ' ||
                                        'Failed in cto_oss_source_pk.get_oss_bom_orgs with unexpected error.', 1);
                END IF;

                raise FND_API.G_EXC_UNEXPECTED_ERROR;

            end if;

            IF PG_DEBUG <> 0 THEN
                   oe_debug_pub.add('Create_And_Link_Item: ' || 'Ater Populate_Bcol', 5);
            END IF;



            oe_debug_pub.add( 'OSS ORGS for Create BOM list size ' || v_orgs_list.count  , 1 ) ;

            oe_debug_pub.add( 'OSS ORGS for Create BOM UPDATE ' , 1 ) ;


            if( v_orgs_list.count > 0 ) then


                if( v_model_lines.config_creation = 3 and v_model_lines.perform_match in ( 'Y', 'U' ) ) then

                    select group_reference_id into v_group_reference_id from bom_cto_src_orgs_b
                     where line_id = v_model_lines.line_id ;

                    update bom_cto_model_orgs set create_bom = 'N'
                     where group_reference_id = v_group_reference_id  ;

                    oe_debug_pub.add( 'UPDATED BCMO create_bom = N for line id  ' || v_model_lines.line_id || ' rows ' || SQL%ROWCOUNT  , 1 ) ;
                else


                    update bom_cto_src_orgs_b set create_bom = 'N'
                     where line_id = v_model_lines.line_id ;

                    oe_debug_pub.add( 'UPDATED BCSO create_bom = N for line id  ' || v_model_lines.line_id || ' rows ' || SQL%ROWCOUNT  , 1 ) ;

                end if;



            for i in 1..v_orgs_list.count
            loop

                oe_debug_pub.add( 'OSS ORGS for Create BOM ' || v_orgs_list(i) , 1 ) ;

                if( v_model_lines.config_creation = 3 and v_model_lines.perform_match in ( 'Y', 'U' ) ) then

                    select group_reference_id into v_group_reference_id from bom_cto_src_orgs_b
                     where line_id = v_model_lines.line_id ;

                    update bom_cto_model_orgs set create_bom = 'Y'
                     where group_reference_id = v_group_reference_id and organization_id = v_orgs_list(i)
		     -- bugfix 4274446 : Check create_config_bom parameter
		     and exists
		     	( select 1 from bom_parameters
			  where organization_id = v_orgs_list(i)
			  and nvl(create_config_bom,'N') = 'Y' );

                    oe_debug_pub.add( 'UPDATED BCMO create_bom = Y for line id  ' || v_model_lines.line_id  || ' rows ' || SQL%ROWCOUNT  , 1 ) ;

                else


                    update bom_cto_src_orgs_b set create_bom = 'Y'
                     where line_id = v_model_lines.line_id and organization_id = v_orgs_list(i)
		     -- bugfix 4274446 : Check create_config_bom parameter
		     and exists
		     	( select 1 from bom_parameters
			  where organization_id = v_orgs_list(i)
			  and nvl(create_config_bom,'N') = 'Y' );

                    oe_debug_pub.add( 'UPDATED BCSO create_bom = Y for line id  ' || v_model_lines.line_id  || ' rows ' || SQL%ROWCOUNT  , 1 ) ;

                end if;


            end loop ;


            end if ; /* v_orgs_list.count  > 0   */



        end if;




        oe_debug_pub.add( '$$$$$$$$$$$$ DONE GET OSS BOM ORGS for Create BOM Indication '  || v_model_lines.line_id , 1 ) ;






	END LOOP;

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('populate_plan_level: ' || 'end of loop',1);

		oe_debug_pub.add('populate_plan_level: ' || 'printing out bcso :', 2);

		oe_debug_pub.add('populate_plan_level: ' || 'line_id  model_item_id  rcv_org_id  org_id  create_bom create_src_rules organization_type  group_reference_id ', 2);
	END IF;

	FOR v_debug IN c_debug LOOP
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || to_char(v_debug.line_id)||'  '||
					to_char(v_debug.model_item_id)||'  '||
					nvl(to_char(v_debug.rcv_org_id),null)||'  '||
					to_char(v_debug.organization_id)||'  '||
					nvl(v_debug.create_bom, null)||'  '||
					nvl(v_debug.create_src_rules, null) || ' ' ||
					nvl(v_debug.organization_type, null) || ' ' ||
					nvl(v_debug.group_reference_id , null), 2);
		END IF;
	END LOOP;



       /* make a call to get validation orgs and purchasing related orgs */

       oe_debug_pub.add( '$$$$$$$$ Additional Type 1 and  2 Processing ' , 1 ) ;

       open get_each_type1_model ;

       loop

           fetch get_each_type1_model into v_current_model_line_id , v_current_model_item_id , v_config_creation ;

           exit when get_each_type1_model%notfound ;

           oe_debug_pub.add( '$$$$$$$$ calling ORg List for model line ' || v_current_model_line_id , 1 ) ;

           if( v_config_creation = 1) then

               oe_debug_pub.add( '$$$$$$$$ TYPE 1 model line ' || v_current_model_line_id , 1 ) ;

               CTO_MSUTIL_PUB.get_other_orgs( pmodellineid => v_current_model_line_id ,
                                           xorglst => v_t_org_list ,
                                        x_return_status => x_return_status ,
                                        x_msg_count     => x_msg_count ,
                                        x_msg_data      => x_msg_data );

               /* bugfix 4227127 fp for bug 4162642 :added return status check */
               if x_return_status = FND_API.G_RET_STS_ERROR then

                  if PG_DEBUG <> 0 then
                     oe_debug_pub.add( 'ERROR: get_other_orgs api return expected error' , 1 ) ;
                  end if;

                  Raise FND_API.G_EXC_ERROR;

               elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then

                  if PG_DEBUG <> 0 then
                     oe_debug_pub.add( 'ERROR: get_other_orgs api return unexpected error' , 1 ) ;
                  end if;

                  Raise FND_API.G_EXC_UNEXPECTED_ERROR;

               end if;



               oe_debug_pub.add( '$$$$$$$$ ORg List for model line ' || v_current_model_line_id , 1 ) ;


               CTO_MSUTIL_PUB.insert_val_into_bcso( pTopAtoLineId, v_current_model_line_id, v_current_model_item_id,  v_t_org_list ) ;


               oe_debug_pub.add( '$$$$$$$$ ORg List DONE for model line ' || v_current_model_line_id , 1 ) ;

	       -- Added by Renga Kannan  on 15-Sep-2005
               -- Added for ATG performance Project

	       CTO_MSUTIL_PUB.Get_Master_orgs(
						p_model_line_id  => v_current_model_line_id ,
						x_orgs_list      => x_orgs_list,
						x_return_status  => x_return_status,
						x_msg_count      => x_msg_count,
						x_msg_data       => x_msg_data);

               if x_return_status = FND_API.G_RET_STS_ERROR then

                  if PG_DEBUG <> 0 then
                     oe_debug_pub.add( 'ERROR: get_Master_orgs api return expected error' , 1 ) ;
                  end if;

                  Raise FND_API.G_EXC_ERROR;

               elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then

                  if PG_DEBUG <> 0 then
                     oe_debug_pub.add( 'ERROR: get_Master_orgs api return unexpected error' , 1 ) ;
                  end if;

                  Raise FND_API.G_EXC_UNEXPECTED_ERROR;

               end if;
	       If x_orgs_list.count <> 0 then
                  CTO_MSUTIL_PUB.insert_val_into_bcso( pTopAtoLineId,
		                                       v_current_model_line_id,
						       v_current_model_item_id,
						       x_orgs_list ) ;
	       End if;

           elsif( v_config_creation = 2 ) then

               oe_debug_pub.add( '$$$$$$$$ TYPE 2 model line ' || v_current_model_line_id , 1 ) ;

               CTO_MSUTIL_PUB.insert_all_into_bcso( pTopAtoLineId, v_current_model_line_id, v_current_model_item_id ) ;

           end if;


       end loop ;

       close get_each_type1_model ;




       oe_debug_pub.add( '$$$$$$$$ Going to update Create BOM flag for Shared Costing Organizations '  , 1 ) ;

        /*Update Create_BOM Flag for Shared Costing Organizations */
        update bom_cto_src_orgs_b bcso_b1 set create_bom = 'Y'
         where ( organization_id , line_id ) in ( select mp.cost_organization_id , bcso_b.line_id
                                      from mtl_parameters mp, bom_cto_src_orgs_b bcso_b, bom_cto_order_lines bcol
                                     where bcso_b.top_model_line_id = pTopAtoLineId
                                       and bcol.ato_line_id = pTopAtoLineId
                                       and bcol.line_id = bcso_b.line_id
                                       and bcol.config_creation in ( 1 , 2 )
                                       and mp.organization_id   = bcso_b.organization_id
                                       and mp.organization_id <> mp.cost_organization_id
                                       and bcso_b.create_bom = 'Y' )
            and exists ( select 1 from bom_parameters bp
                         where  bp.organization_id = bcso_b1.organization_id
                           and  bp.create_config_bom = 'Y' ) ;



       oe_debug_pub.add( '$$$$$$$$ Create BOM flag updated for Shared Costing Organizations ' || to_char(sql%rowcount) , 1 ) ;



      /* print debug output for Shared Cost update */
      if( sql%rowcount > 0 ) then
        FOR v_debug IN c_debug LOOP
                IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('populate_plan_level: ' || to_char(v_debug.line_id)||'  '||
                                        to_char(v_debug.model_item_id)||'  '||
                                        nvl(to_char(v_debug.rcv_org_id),null)||'  '||
                                        to_char(v_debug.organization_id)||'  '||
                                        nvl(v_debug.create_bom, null)||'  '||
                                        nvl(v_debug.create_src_rules, null) || ' ' ||
                                        nvl(v_debug.organization_type, null) || ' ' ||
                                        nvl(v_debug.group_reference_id , null), 2);
                END IF;
        END LOOP;
      end if;




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
   This function identifies the model items for which configuration items need
   to be created and populates the temporary table bom_cto_src_orgs with all the
   organizations that each configuration item needs to be created in.
   This will be called by Upgrade batch program.
+-------------------------------------------------------------------------*/

FUNCTION Populate_Src_Orgs_Upg(pTopAtoLineId in number,
				x_return_status	OUT	NOCOPY varchar2,
				x_msg_count	OUT	NOCOPY number,
				x_msg_data	OUT	NOCOPY varchar2)
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
             plan_level,
             config_creation,
             perform_match,
             config_item_id,
             option_specific
      from bom_cto_order_lines_upg
      where ato_line_id = pTopAtoLineId
      and bom_item_type = 1
      and nvl(wip_supply_type,0) <> 6
      order by plan_level;

   cursor c_parent_src_orgs is
      select distinct bcso.organization_id
      from bom_cto_src_orgs bcso,
           bom_cto_order_lines_upg bcol
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


   cursor get_each_type1_model is
      select line_id , inventory_item_id , config_creation, config_item_id
	from bom_cto_order_lines_upg
       where bom_item_type = 1 and nvl(wip_supply_type, 1) <> 6
         and ato_line_id = pTopAtoLineId order by plan_level ;



  v_t_org_list  CTO_MSUTIL_PUB.org_list;

  v_current_model_line_id   number ;
  v_current_model_item_id   number ;
  v_current_config_item_id number;
  v_config_creation         bom_cto_order_lines_upg.config_creation%type ;


 v_group_reference_id       number ;
 v_orgs_list cto_oss_source_pk.orgs_list ;
 -- Added by Renga Kannan on 15-Sep-2005
 -- For ATG performance Project
 x_orgs_list                CTO_MSUTIL_PUB.org_list;

BEGIN
        --Bugfix 13362916
 	x_return_status := FND_API.G_RET_STS_SUCCESS;

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

            if( v_model_lines.config_creation in ( 1, 2 ) ) then

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
			from bom_cto_order_lines_upg
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
					x_msg_data,
					'UPGRADE',
					v_model_lines.config_item_id);

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
					x_msg_data,
					'UPGRADE',
					v_model_lines.config_item_id);

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


            else

                oe_debug_pub.add( '$$$$$$$$ TYPE 3 model line ' || v_model_lines.line_id , 1 ) ;

                /* Fixed bug 3472654 */
                if( v_model_lines.perform_match in ( 'Y' , 'U') ) then
                    CTO_MSUTIL_PUB.insert_type3_referenced_bcso( pTopAtoLineId
                                                               , v_model_lines.line_id
                                                               , v_model_lines.inventory_item_id
                                                               , v_model_lines.config_item_id) ;


                else


                    CTO_MSUTIL_PUB.insert_type3_bcso( pTopAtoLineId
                                                    , v_model_lines.line_id
                                                    , v_model_lines.inventory_item_id
                                                    , v_model_lines.config_item_id) ;





                end if;


            end if ; /* config_creation check */


        oe_debug_pub.add( '$$$$$$$$$$$$Going to START GET OSS BOM ORGS for Create BOM Indication '  || to_char( v_model_lines.line_id )  , 1 ) ;
        oe_debug_pub.add( '$$$$$$$$$$$$Going to START GET OSS BOM ORGS for Create BOM Indication '  || v_model_lines.option_specific , 1 ) ;

        if(  v_model_lines.option_specific in ( '1' , '2',  '3' )  ) then

            oe_debug_pub.add( 'Going to Call GET OSS BOM ORGS for Create BOM Indication '  || to_char( v_model_lines.line_id)  , 1 ) ;


            cto_oss_source_pk.get_oss_bom_orgs( p_line_id => v_model_lines.line_id
                                            ,x_orgs_list => v_orgs_list
                                            ,x_return_status => x_return_status
                                            ,x_msg_count => x_msg_count
                                            ,x_msg_data => x_msg_data  ) ;






            if x_return_status = FND_API.G_RET_STS_ERROR then

                IF PG_DEBUG <> 0 THEN
                      oe_debug_pub.add ('GET_ALL_ITEM_ORGS: ' ||
                                        'Failed in cto_oss_source_pk.get_oss_bom_orgs with expected error.', 1);
                END IF;

                raise FND_API.G_EXC_ERROR;

            elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then

                IF PG_DEBUG <> 0 THEN
                      oe_debug_pub.add ('GET_ALL_ITEM_ORGS: ' ||
                                        'Failed in cto_oss_source_pk.get_oss_bom_orgs with unexpected error.', 1);
                END IF;

                raise FND_API.G_EXC_UNEXPECTED_ERROR;

            end if;

            IF PG_DEBUG <> 0 THEN
                   oe_debug_pub.add('Create_And_Link_Item: ' || 'Ater Populate_Bcol', 5);
            END IF;



            oe_debug_pub.add( 'OSS ORGS for Create BOM list size ' || v_orgs_list.count  , 1 ) ;

            oe_debug_pub.add( 'OSS ORGS for Create BOM UPDATE ' , 1 ) ;


            if( v_orgs_list.count > 0 ) then


                if( v_model_lines.config_creation = 3 and v_model_lines.perform_match in ( 'Y', 'U' ) ) then

                    select group_reference_id into v_group_reference_id from bom_cto_src_orgs_b
                     where line_id = v_model_lines.line_id ;

                    update bom_cto_model_orgs set create_bom = 'N'
                     where group_reference_id = v_group_reference_id  ;

                    oe_debug_pub.add( 'UPDATED BCMO create_bom = N for line id  ' || v_model_lines.line_id || ' rows ' || SQL%ROWCOUNT  , 1 ) ;
                else


                    update bom_cto_src_orgs_b set create_bom = 'N'
                     where line_id = v_model_lines.line_id ;

                    oe_debug_pub.add( 'UPDATED BCSO create_bom = N for line id  ' || v_model_lines.line_id || ' rows ' || SQL%ROWCOUNT  , 1 ) ;

                end if;



            for i in 1..v_orgs_list.count
            loop

                oe_debug_pub.add( 'OSS ORGS for Create BOM ' || v_orgs_list(i) , 1 ) ;

                if( v_model_lines.config_creation = 3 and v_model_lines.perform_match in ( 'Y', 'U' ) ) then

                    select group_reference_id into v_group_reference_id from bom_cto_src_orgs_b
                     where line_id = v_model_lines.line_id ;

                    update bom_cto_model_orgs set create_bom = 'Y'
                     where group_reference_id = v_group_reference_id and organization_id = v_orgs_list(i)
		     -- bugfix 4274446 : Check create_config_bom parameter
		     and exists
		     	( select 1 from bom_parameters
			  where organization_id = v_orgs_list(i)
			  and nvl(create_config_bom,'N') = 'Y' );

                    oe_debug_pub.add( 'UPDATED BCMO create_bom = Y for line id  ' || v_model_lines.line_id  || ' rows ' || SQL%ROWCOUNT  , 1 ) ;

                else


                    update bom_cto_src_orgs_b set create_bom = 'Y'
                     where line_id = v_model_lines.line_id and organization_id = v_orgs_list(i)
		     -- bugfix 4274446 : Check create_config_bom parameter
		     and exists
		     	( select 1 from bom_parameters
			  where organization_id = v_orgs_list(i)
			  and nvl(create_config_bom,'N') = 'Y' );

                    oe_debug_pub.add( 'UPDATED BCSO create_bom = Y for line id  ' || v_model_lines.line_id  || ' rows ' || SQL%ROWCOUNT  , 1 ) ;

                end if;


            end loop ;


            end if ; /* v_orgs_list.count  > 0   */



        end if;




        oe_debug_pub.add( '$$$$$$$$$$$$ DONE GET OSS BOM ORGS for Create BOM Indication '  || v_model_lines.line_id , 1 ) ;



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





       oe_debug_pub.add( '$$$$$$$$ Going to update Create BOM flag for Shared Costing Organizations '  , 1 ) ;

        /*Update Create_BOM Flag for Shared Costing Organizations */
        update bom_cto_src_orgs_b bcso_b1 set create_bom = 'Y'
         where ( organization_id , line_id ) in ( select mp.cost_organization_id , bcso_b.line_id
                                      from mtl_parameters mp, bom_cto_src_orgs_b bcso_b, bom_cto_order_lines bcol
                                     where bcso_b.top_model_line_id = pTopAtoLineId
                                       and bcol.ato_line_id = pTopAtoLineId
                                       and bcol.line_id = bcso_b.line_id
                                       and bcol.config_creation in ( 1 , 2 )
                                       and mp.organization_id   = bcso_b.organization_id
                                       and mp.organization_id <> mp.cost_organization_id
                                       and bcso_b.create_bom = 'Y' )
            and exists ( select 1 from bom_parameters bp
                         where  bp.organization_id = bcso_b1.organization_id
                           and  bp.create_config_bom = 'Y' ) ;



       oe_debug_pub.add( '$$$$$$$$ Create BOM flag updated for Shared Costing Organizations ' || to_char(sql%rowcount) , 1 ) ;



      /* print debug output for Shared Cost update */
      if( sql%rowcount > 0 ) then
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

      end if;



       /* make a call to get validation orgs and purchasing related orgs */

       oe_debug_pub.add( '$$$$$$$$ Additional Type 1 and  2 Processing ' , 1 ) ;

       open get_each_type1_model ;

       loop

           fetch get_each_type1_model into v_current_model_line_id , v_current_model_item_id , v_config_creation , v_current_config_item_id;

           exit when get_each_type1_model%notfound ;

           oe_debug_pub.add( '$$$$$$$$ calling ORg List for model line ' || v_current_model_line_id , 1 ) ;

           if( v_config_creation = 1) then

               oe_debug_pub.add( '$$$$$$$$ TYPE 1 model line ' || v_current_model_line_id , 1 ) ;

               CTO_MSUTIL_PUB.get_other_orgs( pmodellineid => v_current_model_line_id ,
					p_mode => 'UPG',
                                           xorglst => v_t_org_list ,
                                        x_return_status => x_return_status ,
                                        x_msg_count     => x_msg_count ,
                                        x_msg_data      => x_msg_data );


               /* bugfix 4162642 :added return status check */
               if x_return_status = FND_API.G_RET_STS_ERROR then

                  if PG_DEBUG <> 0 then
                     oe_debug_pub.add( 'ERROR: get_other_orgs api return expected error' , 1 ) ;
                  end if;

                  Raise FND_API.G_EXC_ERROR;

               elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then

                  if PG_DEBUG <> 0 then
                     oe_debug_pub.add( 'ERROR: get_other_orgs api return unexpected error' , 1 ) ;
                  end if;

                  Raise FND_API.G_EXC_UNEXPECTED_ERROR;

               end if;


               oe_debug_pub.add( '$$$$$$$$ ORg List for model line ' || v_current_model_line_id , 1 ) ;


               CTO_MSUTIL_PUB.insert_val_into_bcso( pTopAtoLineId, v_current_model_line_id, v_current_model_item_id,  v_t_org_list , v_current_config_item_id) ;


               oe_debug_pub.add( '$$$$$$$$ ORg List DONE for model line ' || v_current_model_line_id , 1 ) ;
	       -- Added by Renga Kannan  on 15-Sep-2005
               -- Added for ATG performance Project

	       CTO_MSUTIL_PUB.Get_Master_orgs(
						p_model_line_id  => v_current_model_line_id ,
						x_orgs_list      => x_orgs_list,
						x_return_status  => x_return_status,
						x_msg_count      => x_msg_count,
						x_msg_data       => x_msg_data);

               if x_return_status = FND_API.G_RET_STS_ERROR then

                  if PG_DEBUG <> 0 then
                     oe_debug_pub.add( 'ERROR: get_Master_orgs api return expected error' , 1 ) ;
                  end if;

                  Raise FND_API.G_EXC_ERROR;

               elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then

                  if PG_DEBUG <> 0 then
                     oe_debug_pub.add( 'ERROR: get_Master_orgs api return unexpected error' , 1 ) ;
                  end if;

                  Raise FND_API.G_EXC_UNEXPECTED_ERROR;

               end if;
	       If x_orgs_list.count <> 0 then
                  CTO_MSUTIL_PUB.insert_val_into_bcso( pTopAtoLineId,
		                                       v_current_model_line_id,
						       v_current_model_item_id,
						       x_orgs_list ) ;
	       End if;


           elsif( v_config_creation = 2 ) then

               oe_debug_pub.add( '$$$$$$$$ TYPE 2 model line ' || v_current_model_line_id , 1 ) ;

               CTO_MSUTIL_PUB.insert_all_into_bcso( pTopAtoLineId, v_current_model_line_id, v_current_model_item_id , v_current_config_item_id) ;

           end if;


       end loop ;

       close get_each_type1_model ;

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

END Populate_Src_Orgs_Upg;


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
			    x_return_status    OUT NOCOPY varchar2,
			    x_msg_count	       OUT NOCOPY number,
			    x_msg_data	       OUT NOCOPY varchar2,
                            p_mode          in      varchar2 default 'AUTOCONFIG',
			    p_config_item_id in number default NULL  )
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


lConfigCreation   bom_cto_order_lines.config_creation%type ;
lPerformMatch     bom_cto_order_lines.perform_match%type ;
lOptionSpecific   bom_cto_order_lines.option_specific%type ;

vx_concat_org_id  varchar2(200) ;
v_group_reference_id   number ;
v_100_procured        varchar2(1) := 'N' ;


BEGIN
        --Bugfix 13362916
 	x_return_status := FND_API.G_RET_STS_SUCCESS;

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

	select ato_line_id,parent_ato_line_id, nvl(program_id,0)
             , config_creation , perform_match , option_specific /* added by sushant for preconfigure bom identification */
	into lTopAtoLineId,l_parent_ato_line_id, lProgramId
             , lConfigCreation, lPerformMatch , lOptionSpecific
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
           and    ( bcso.create_bom         = 'Y' or bcso.organization_type in ( '3', '2'))
           and    organization_id = pRcvOrgId ;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                Null;

           when too_many_rows then
                IF PG_DEBUG <> 0 THEN
                    oe_debug_pub.add('get_all_item_orgs: ' || 'too_many_rows happens when make and buy exist' ||
                                       to_char(l_parent_ato_line_id ),2);

                END IF;

                l_source_type := 2 ;


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



	        lStmtNumber := 220;
	        insert into bom_cto_src_orgs_b
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
                   -- 'Y' , /* this statement is executed for lower buy models */
                   'N' , /* create bom should be no for org  type 4 */
                   -- decode( bp.create_config_bom , 'Y', decode( bbom.common_bill_sequence_id , null ,'N' , 'Y') , 'N' ) ,   -- create_bom
                   'N' , /* cost rollup should be no for org type 4 */
		    -- decode( l_source_type , 4 , 'N' , 6 , 'N' , 'Y' ) , -- cost_rollup
		    l_source_type,	-- org_type is used to store the source_type
		    p_config_item_id,	-- config_item_id
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
	        from   bom_parameters bp, bom_bill_of_materials bbom
	        where  bp.organization_id = pRcvOrgId
                  and  bp.organization_id = bbom.organization_id (+)
                  and  pModelItemId = bbom.assembly_item_id (+)
                  and  bbom.alternate_bom_designator is null
                  and  NOT EXISTS
		       (select NULL
		          from bom_cto_src_orgs_b
		         where line_id = pLineId
                           and organization_id = pRcvOrgId
                           and rcv_org_id = pRcvOrgId
		           and model_item_id = pModelItemId);

	       IF PG_DEBUG <> 0 THEN
	          oe_debug_pub.add('Get_All_Item_Orgs: ' || 'Inserted in BCSO for procured child model same org id, rcv org id ' || SQL%rowcount
                                                         || ' at stmt ' || to_char(lStmtNumber) ,2);

                  oe_debug_pub.add('Get_All_Iitem_Orgs: ' || 'Inserted into BCSO ' || ' for model ' || to_char( pmodelitemid )
                                                                                   || ' line ' || to_char(pLineId) ,2);
	       END IF;








        ELSE
            lStmtNumber := 40;

	    IF lMrpAssignmentSet is null THEN
		 IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_plan_level: ' || 'Default assignment set is null',1);
		 END IF;


                 -- added by Renga Kannan on 08/21/01
                 -- When there is no sourcing rule defined we need to check for the make_buy_type of the
                 -- item to determine the buy model

                 lStmtNumber := 50;

                 -- The following select statement is modified by Renga Kannan
                 -- On 12/21/01. The where condition organization_id is modified




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




                 lStmtNumber := 60;

                 l_curr_src_org := pRcvOrgId ;



                 if( l_make_buy_code  = 2) then

                     l_source_type := 3 ;
                     v_100_procured := 'Y' ;
                 else
                     l_source_type := 2 ;
                     v_100_procured := 'N' ;
                 end if;



                 l_curr_rank  := null ;

                 lStmtNumber := 70;

		 insert into bom_cto_src_orgs_b
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
				ltopatolineid ,
				plineid ,
				pmodelitemid ,
				null ,
				l_curr_src_org,
                                decode( bp.create_config_bom , 'Y',
                                                decode( bbom.common_bill_sequence_id , null ,'N' , 'Y') , 'N' ) ,   -- create_bom
				'Y',		-- cost_rollup
				l_source_type,	-- org_type is used to store the source type
				p_config_item_id,	-- config_item_id
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
                   from   bom_parameters bp, bom_bill_of_materials bbom
                   where  bp.organization_id = pRcvOrgId
                     and  bp.organization_id = bbom.organization_id (+)
                     and  pModelItemId = bbom.assembly_item_id (+)
                     and  bbom.alternate_bom_designator is null
                     and  NOT EXISTS
                          (select NULL
                             from bom_cto_src_orgs_b
                            where line_id = pLineId
                              and organization_id = pRcvOrgId
                              and model_item_id = pModelItemId);

		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Get_All_Iitem_Orgs: ' || 'Inserted into BCSO ' || SQL%ROWCOUNT || ' at stmt ' || to_char(lStmtNumber) ,2);

			oe_debug_pub.add('Get_All_Iitem_Orgs: ' || 'Inserted into BCSO ' || ' for model ' || to_char( pmodelitemid )
                                                                                         || ' line ' || to_char(plineid)  , 2 );
		END IF;


	   ELSE


                lStmtNumber := 80;

		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Get_All_Iitem_Orgs: ' || 'Default assignment set is '||to_char(lMrpAssignmentSet),2);
		END IF;



                    vx_concat_org_id := to_char( pRcvOrgId )  ;

                    lStmtNumber := 90;

                    process_sourcing_chain( pModelItemId
                                      , pRcvOrgId
                                      , plineid
                                      , ltopatolineid
                                      , p_mode
                                      , p_config_item_id
                                      , vx_concat_org_id
                                      , x_return_status
                                      , x_msg_count
                                      , x_msg_data );




                    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                         IF PG_DEBUG <> 0 THEN
                                        oe_debug_pub.add('get_all_item_orgs: ' || 'process_sourcing_chain returned with unexp error',1);
                         END IF;
                         raise FND_API.G_EXC_UNEXPECTED_ERROR;

                    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                         IF PG_DEBUG <> 0 THEN
                                        oe_debug_pub.add('get_all_item_orgs: ' || 'process_sourcing_chain returned with exp error',1);
                         END IF;
                         raise FND_API.G_EXC_ERROR;
                    END IF;


                    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('get_all_item_orgs: ' || 'after calling process_sourcing_chain::x_return_status::'||x_return_status,2);
                    END IF;




	   END IF; /* MRP profile is not null */

        END IF; /* check for DROP SHIP , BUY_ITEM_FLAG is not Y */



            lStmtNumber := 140;

            IF lMrpAssignmentSet is not null THEN

	        --
	        -- If mrp_sources_v does not insert any rows into
	        -- bom_cto_src_orgs, this means that no sourcing rules are set-up
	        -- for this model item in this org. Assuming that in this case
	        -- the item in this org is sourced from itself, inserting a row
	        -- with the receiving org as the sourcing org


	        lStmtNumber := 160;
	        insert into bom_cto_src_orgs_b
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
                   'N' , /* this statement is executed when there are onyly transfer from sourcing rules in shipping org */
		    /*decode( bp.create_config_bom , 'Y', decode( bbom.common_bill_sequence_id , null ,'N' , 'Y') , 'N' ) ,		-- create_bom */
		    decode( l_source_type , 4 , 'N' , 6 , 'N' , 'Y' ) , -- cost_rollup
		    l_source_type,	-- org_type is used to store the source_type
		    p_config_item_id,	-- config_item_id
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
	        from   bom_parameters bp, bom_bill_of_materials bbom
	        where  bp.organization_id = pRcvOrgId
                  and  bp.organization_id = bbom.organization_id (+)
                  and  pModelItemId = bbom.assembly_item_id (+)
                  and  bbom.alternate_bom_designator is null
                  and  NOT EXISTS
		       (select NULL
		          from bom_cto_src_orgs_b
		         where line_id = pLineId
                           and organization_id = pRcvOrgId
                           and rcv_org_id = pRcvOrgId
		           and model_item_id = pModelItemId);

	       IF PG_DEBUG <> 0 THEN
	          oe_debug_pub.add('Get_All_Item_Orgs: ' || 'Inserted in BCSO for transfer same org id, rcv org id ' || SQL%rowcount
                                                                 || ' at stmt ' || to_char(lStmtNumber) ,2);

                  oe_debug_pub.add('Get_All_Iitem_Orgs: ' || 'Inserted into BCSO ' || ' for model ' || to_char( pmodelitemid )
                                                                 || ' line ' || to_char(plineid) ,2);
	       END IF;




		lStmtNumber := 180;
		IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('get_all_item_orgs : ' || 'done recursive chain for model '||to_char(pmodelitemid ), 1);
		END IF;



                oe_debug_pub.add( ' procured_model_bcso_override mode ' || p_mode   , 1);

                if( p_mode = 'AUTOCONFIG' ) then
                    oe_debug_pub.add( ' going to call procured_model_bcso_override '  , 1);

		    lStmtNumber := 200;



                    procured_model_bcso_override( p_model_item_id => pModelItemId
                                                 ,p_line_id  => pLineId
                                                 ,p_ship_org_id => pRcvOrgId ) ;



                end if;


            else

	        --
	        -- If mrp_sources_v does not insert any rows into
	        -- bom_cto_src_orgs, this means that no sourcing rules are set-up
	        -- for this model item in this org. Assuming that in this case
	        -- the item in this org is sourced from itself, inserting a row
	        -- with the receiving org as the sourcing org


                null ;


            end if; /* check whether assignment set is null */




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




procedure process_sourcing_chain(
        p_model_item_id         IN  number
      , p_organization_id       IN  number
      , p_line_id               IN  number
      , p_top_ato_line_id       IN  number
      , p_mode                  IN  varchar2 default 'AUTOCONFIG'
      , p_config_item_id        IN  number default NULL
      , px_concat_org_id        IN OUT NOCOPY varchar2
      , x_return_status         OUT NOCOPY varchar2
      , x_msg_count             OUT NOCOPY number
      , x_msg_data              OUT NOCOPY varchar2

)
is



v_t_sourcing_info   SOURCING_INFO;
v_buy_traversed   boolean := false ;
v_source_type       mrp_sources_v.source_type%type ;
l_make_buy_code     mtl_system_items.planning_make_buy_code%type ;

l_curr_src_org      mrp_sources_v.source_organization_id%type  ;
l_source_type       mrp_sources_v.source_type%type ;
l_curr_assg_type    mrp_sources_v.assignment_type%type ;
l_curr_rank         mrp_sources_v.rank%type ;
v_sourcing_rule_exists varchar2(10) ;


lstmtnumber number ;
x_exp_error_code   varchar2(100) ;

lStmtNum  number ;


v_option_specific  varchar2(1) ;
v_px_concat_org_id      varchar2(200) ;

 v_bcso_count                    number ;
v_circular_src_exists          varchar2(10);
v_bom_created                  varchar2(1) := 'N' ;
v_recursive_call               varchar2(1) := 'Y' ;
v_100_procured                 varchar2(1) := 'Y' ;

v_org_check                    varchar2(200) ;

l_orgs_index                   number;                                  --Bugfix 7522447/7410091
j                              number;                                  --Bugfix 7522447/7410091

BEGIN




                x_return_status := FND_API.G_RET_STS_SUCCESS;




                IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add( 'Entered process sourcing chain ' , 1 ) ;
                oe_debug_pub.add( 'Entered process sourcing chain line ' || p_line_id  , 1 ) ;
                oe_debug_pub.add( 'Entered process sourcing chain org' || p_organization_id  , 1 ) ;
                oe_debug_pub.add( 'Entered process sourcing chain model item ' || p_model_item_id , 1 ) ;
                END IF ;


                if( to_char(p_organization_id ) = px_concat_org_id ) then
                    v_recursive_call := 'N' ;

                end if;

                lStmtNum := 0;
		--Bugfix 7522447/7410091
                l_orgs_index := p_organization_id;
                x_orgs_tbl(l_orgs_index) := p_organization_id;

                IF PG_DEBUG <> 0 THEN
                  oe_debug_pub.add( 'Printing values in x_orgs_tbl' , 1 ) ;

                  if x_orgs_tbl.count > 0 then
                     IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('Count '|| x_orgs_tbl.Count, 5);
                     END IF;

                     j := x_orgs_tbl.first;
                     WHILE j IS NOT null LOOP
                          IF PG_DEBUG <> 0 THEN
                             oe_debug_pub.add('x_sparse_tbl(j) '|| x_orgs_tbl(j));
                          END IF;
                          j := x_orgs_tbl.NEXT(j);
                     END LOOP;
                  end if;
                END IF;
                --Bugfix 7522447/7410091

		lStmtNum := 1;
                v_buy_traversed := FALSE ;


                IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add( 'calling query sourcing org ' , 1 ) ;
                END IF;


                 if( p_mode = 'AUTOCONFIG' ) then
                     select nvl( option_specific , 'N' )  into v_option_specific from bom_cto_order_lines
                       where line_id = p_line_id ;

                 else
                     select nvl( option_specific , 'N' )  into v_option_specific from bom_cto_order_lines_upg
                       where line_id = p_line_id ;

                 end if ;



                if( v_option_specific = 'N' ) then

                query_sourcing_org_ms ( p_model_item_id
                               , p_organization_id
                               , v_sourcing_rule_exists
                               , v_source_type
                               , v_t_sourcing_info
                               , x_exp_error_code
                               , x_return_status      );


                else


                    CTO_OSS_SOURCE_PK.query_oss_sourcing_org(   p_line_id => p_line_id,
                                                                p_inventory_item_id => p_model_item_id,
                                                                p_organization_id => p_organization_id,
                                                                x_sourcing_rule_exists => v_sourcing_rule_exists,
                                                                x_source_type =>  v_source_type ,
                                                                x_t_sourcing_info => v_t_sourcing_info,
                                                                x_exp_error_code => x_exp_error_code,
                                                                x_return_status =>  x_return_status,
                                                                x_msg_data => x_msg_data,
                                                                x_msg_count =>  x_msg_count );









              end if;



              if( p_mode = 'AUTOCONFIG' ) then
                    v_100_procured := 'Y' ;

                    FOR i in 1..v_t_sourcing_info.source_type.count
                    LOOP

                        if( v_t_sourcing_info.source_type(i) in ( 1, 2) ) then
                            v_100_procured := 'N' ;
                            exit ;
                        end if ;
                    END LOOP ;

              else

                    v_100_procured := 'N' ;

              end if;





                IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add( 'output query sourcing org rule '  || v_t_sourcing_info.sourcing_rule_id.count , 1 ) ;
                oe_debug_pub.add( 'output query sourcing org src org '  || v_t_sourcing_info.source_organization_id.count , 1 ) ;
                oe_debug_pub.add( 'output query sourcing org src type'  || v_t_sourcing_info.source_type.count , 1 ) ;
                END IF;



                if( v_t_sourcing_info.source_type.count > 0 ) then

                    FOR i in 1..v_t_sourcing_info.source_type.count
                    LOOP

                        IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add( 'output query sourcing org type '  || v_t_sourcing_info.source_type(i)  , 1 ) ;
                        END IF;

                        /* Reinitialize variables */
                        l_curr_src_org  := null ;
                        l_source_type   := null ;
                        l_curr_rank     := null ;

                        IF PG_DEBUG <> 0 THEN
                           if( v_t_sourcing_info.source_type(i) = 1 ) then

                               oe_debug_pub.add( 'output query sourcing org type 1 ' ,  1)   ;

                           elsif ( v_t_sourcing_info.source_type(i) = 2 ) then
                               oe_debug_pub.add( 'output query sourcing org type 2 ' ,  1)  ;


                           elsif ( v_t_sourcing_info.source_type(i) = 3 ) then

                               oe_debug_pub.add( 'output query sourcing org type 3 ' ,  1)  ;


                           else

                               oe_debug_pub.add( 'output query sourcing org type else  ' ,  1) ;

                           end if ;
                        END IF;



                        if(  v_t_sourcing_info.source_type(i) in ( 1, 2 )  ) then


                             IF PG_DEBUG <> 0 THEN
                             oe_debug_pub.add( ' came into type 1,2  '  , 1 ) ;
                             END IF;


                             begin
                             lStmtNum := 1 ;
		             l_curr_src_org := v_t_sourcing_info.source_organization_id(i) ;
                             lStmtNum := 2 ;
		             l_source_type  := v_t_sourcing_info.source_type(i) ;
                             lStmtNum := 3 ;
			     l_curr_assg_type := v_t_sourcing_info.assignment_type(i) ;
                             lStmtNum := 4 ;
			     l_curr_rank := v_t_sourcing_info.rank(i) ;

                             exception
                             when others then

                                  IF PG_DEBUG <> 0 THEN
                                  oe_debug_pub.add( ' errored into type 1,2  at '  || lStmtNum  || ' err ' || SQLERRM , 1 ) ;
                                  END IF;
                             end ;

                             IF PG_DEBUG <> 0 THEN
                             oe_debug_pub.add( ' value for l_curr_src_org '  || l_curr_src_org , 1 ) ;
                             oe_debug_pub.add( ' value for l_source_type '  || l_source_type , 1 ) ;
                             oe_debug_pub.add( ' value for l_curr_rank '  || l_curr_rank , 1 ) ;
                             END IF;





                             if( l_source_type = 1 ) then

                                  IF PG_DEBUG <> 0 THEN
                                  oe_debug_pub.add( 'going to check for circular sourcing   '  , 1 ) ;
                                  /* check for circular sourcing in bcso */
                                  oe_debug_pub.add( 'CIRCULAR SOURCE CHECK ' || px_concat_org_id  ) ;
                                  END IF;


                                  v_org_check := to_char(l_curr_src_org) ;

                                  IF PG_DEBUG <> 0 THEN
                                  oe_debug_pub.add( 'CIRCULAR SOURCE CHECK px_concat_org_id ' || px_concat_org_id  || ' v_org_check ' || v_org_check  ) ;
                                  END IF;


                                  /* Commenting as part of Bugfix 7522447/7410091
				  if( instr( px_concat_org_id , v_org_check ) > 0 ) then
                                      v_circular_src_exists := 'Y' ;
                                      IF PG_DEBUG <> 0 THEN
                                      oe_debug_pub.add( 'CIRCULAR SOURCE DETECTED ' ) ;
                                      END IF;

                                  else

                                      v_circular_src_exists := 'N' ;

                                  end if ;*/

				  --Begin Bugfix 7522447/7410091
                                  if (x_orgs_tbl.exists(l_curr_src_org)) then
                                     lStmtNum := 6;
                                     v_circular_src_exists := 'Y';
                                     IF PG_DEBUG <> 0 THEN
                                       oe_debug_pub.add( 'CIRCULAR SOURCE DETECTED ' ) ;
                                     END IF;

                                  else
                                      v_circular_src_exists := 'N' ;
                                  end if ;
                                  --End Bugfix 7522447/7410091


                                  if( v_circular_src_exists = 'Y' OR ( l_source_type = 1 and p_organization_id = l_curr_src_org)  ) then

                                      lStmtNum := 5;
                                      IF PG_DEBUG <> 0 THEN
                                         oe_debug_pub.add('process_sourcing_chain: ' || 'Circular sourcing defined for model '
                                                           || to_char(p_model_item_id)
                                                           || ' in org '
                                                           ||to_char(l_curr_src_org)  || ' via org ' || to_char(p_organization_id ) , 1);


                                         oe_debug_pub.add('process_sourcing_chain: ' || 'Circular sourcing additional info '
                                                           || px_concat_org_id || '::' || to_char(l_curr_src_org) , 1) ;

                                      END IF;

                                      cto_msg_pub.cto_message('BOM','CTO_INVALID_SOURCING');
                                      raise FND_API.G_EXC_ERROR;



                                  end if;

                             end if; /* l_source_type = 1 */


                             IF PG_DEBUG <> 0 THEN
                             oe_debug_pub.add( 'going to insert bcso for type 1,2  '  , 1 ) ;
                             END IF;

                             lStmtNum := 10 ;
		             insert into bom_cto_src_orgs_b
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
				p_top_ato_line_id,
				p_line_id,
				p_model_item_id,
				p_organization_id,
				l_curr_src_org,
				decode( l_source_type  , 2 ,
                                        decode( bp.create_config_bom, 'Y', 'Y' , 'N' )
                                       , 'N' ),		-- create_bom
				'Y',		-- cost_rollup
				l_source_type,	-- org_type is used to store the source type
				p_config_item_id ,		-- config_item_id
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
		             from bom_parameters bp
                             where bp.organization_id = l_curr_src_org
                               and NOT EXISTS  /* NOT EXISTS should be there to check whether same org is reached thru other paths */
                                (select NULL
                                  from bom_cto_src_orgs_b
                                  where line_id = p_line_id
                                    and rcv_org_id = p_organization_id
                                    and organization_id = l_curr_src_org
                                    and organization_type = l_source_type
                                    and model_item_id = p_model_item_id );




                             IF PG_DEBUG <> 0 THEN
                             oe_debug_pub.add( 'inserted bcso for type 1,2  '  || SQL%rowcount , 1 ) ;
                             oe_debug_pub.add( 'inserted bcso for type 1,2  rcv '  || p_organization_id || ' org ' || l_curr_src_org  , 1 ) ;
                             END IF;




                        elsif( v_t_sourcing_info.source_type(i) = 3 and NOT v_buy_traversed ) then

                             v_buy_traversed := TRUE ;

                             oe_debug_pub.add( ' came into type 3 '  , 1 ) ;

                             lStmtNum := 20 ;

                             begin
                             lStmtNum := 21 ;
		             l_curr_src_org := nvl( v_t_sourcing_info.source_organization_id(i) , p_organization_id )  ; /* could be null please check ?? */
                             lStmtNum := 22 ;
		             l_source_type  := v_t_sourcing_info.source_type(i) ;
                             lStmtNum := 23 ;
			     l_curr_assg_type := v_t_sourcing_info.assignment_type(i) ;
                             lStmtNum := 24 ;
			     l_curr_rank := v_t_sourcing_info.rank(i) ;

                             exception
                             when others then

                              IF PG_DEBUG <> 0 THEN
                                 oe_debug_pub.add( ' errored into type 3  at '  || lStmtNum  || ' err ' || SQLERRM , 1 ) ;
                              END IF;

                             end ;




                             lStmtNum := 30 ;

		             insert into bom_cto_src_orgs_b
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
				p_top_ato_line_id,
				p_line_id,
				p_model_item_id,
				p_organization_id,
				l_curr_src_org,
				decode( v_100_procured , 'Y' , 'N' ,
                                        decode( bp.create_config_bom, 'Y', 'Y' , 'N')
                                       ) ,-- create_bom  /* 100 % procured will be 'N' */
				'Y',		-- cost_rollup
				l_source_type,	-- org_type is used to store the source type
				p_config_item_id,		-- config_item_id
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
		             from bom_parameters bp
                            where bp.organization_id = l_curr_src_org
                              and NOT EXISTS     /* NOT EXISTS should be there to check whether same org is reached thru other paths */
                                (select NULL
                                  from bom_cto_src_orgs_b
                                  where line_id = p_line_id
                                    and rcv_org_id = p_organization_id
                                    and organization_id = l_curr_src_org
                                    and organization_type = l_source_type
                                    and model_item_id = p_model_item_id );



                             IF PG_DEBUG <> 0 THEN
                             oe_debug_pub.add( 'inserted bcso for type 3 '  || SQL%rowcount , 1 ) ;
                             oe_debug_pub.add( 'inserted bcso for type 3  rcv '  || p_organization_id || ' org ' || l_curr_src_org  , 1 ) ;
                             END IF;




                        end if;


                        lStmtNum := 40 ;

                        if( v_t_sourcing_info.source_type(i) = 1 ) then


                            oe_debug_pub.add( 'calling process sourcing chain recursive  '  , 1 ) ;

                            lStmtNum := 50 ;

                            /* implemented using another variable as it is a multipath tree recursion */
                            v_px_concat_org_id := px_concat_org_id || '::' || to_char( v_t_sourcing_info.source_organization_id(i)) ;


                            process_sourcing_chain( p_model_item_id
                                                  , v_t_sourcing_info.source_organization_id(i)
                                                  , p_line_id
                                                  , p_top_ato_line_id
                                                  , p_mode
                                                  , p_config_item_id
                                                  , v_px_concat_org_id
                                                  , x_return_status
                                                  , x_msg_count
                                                  , x_msg_data );




                            IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                                IF PG_DEBUG <> 0 THEN
                                        oe_debug_pub.add('process_sourcing_chain: ' || 'process_sourcing_chain returned with unexp error',1);
                                END IF;
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;

                            ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                                IF PG_DEBUG <> 0 THEN
                                        oe_debug_pub.add('process_sourcing_chain: ' || 'process_sourcing_chain returned with exp error',1);
                                END IF;
                                raise FND_API.G_EXC_ERROR;
                            END IF;


                            IF PG_DEBUG <> 0 THEN
                                oe_debug_pub.add('process_sourcing_chain: ' || 'after calling process_sourcing_chain::x_return_status::'||x_return_status,2);
                            END IF;


                        end if;


                    END LOOP ;


                else

                     -- When there is no sourcing rule defined we need to check for the make_buy_type of the
                     -- item to determine the buy model

                     -- if( v_source_type_code = 'INTERNAL' ) then


			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('process_sourcing_chain : ' || 'NDF::End of chain for model '||to_char(p_model_item_id), 1);
				oe_debug_pub.add('process_sourcing_chain : ' || 'NDF::End of chain in org '||  p_organization_id , 1);
			END IF;


                        lStmtNumber := 70;

                        -- When the item is not defined in the sourcing org it needs to be
                        -- treated as INVALID sourcing

                        BEGIN

                           SELECT planning_make_buy_code
                           INTO   l_make_buy_code
                           FROM   MTL_SYSTEM_ITEMS
                           WHERE  inventory_item_id = p_model_item_id
                           AND    organization_id   = p_organization_id ;

                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN

                           IF PG_DEBUG <> 0 THEN
                           	oe_debug_pub.add('process_sourcing_chain: ' || 'Inventory_item_id  = '|| to_char(p_model_item_id ),1);

                           	oe_debug_pub.add('process_sourcing_chain: ' || 'Organization id    = '|| to_char(p_organization_id),1);

                           	oe_debug_pub.add('process_sourcing_chain: ' || 'ERROR::The item is not defined in the sourcing org',1);
                           END IF;


                           -- The following message handling is modified by Renga Kannan
                           -- We need to give the add for once to FND function and other
                           -- to OE, in both cases we need to set the message again
                           -- This is because if we not set the token once again the
                           -- second add will not get the message.

                           cto_msg_pub.cto_message('BOM','CTO_INVALID_SOURCING');
                           raise FND_API.G_EXC_ERROR;

                        END;


                        lStmtNumber := 80;

                        l_curr_src_org := p_organization_id ;

                        if( l_make_buy_code  = 2) then

                            l_source_type := 3 ;
                        else
                            l_source_type := 2 ;
                        end if;


                        if( p_mode = 'AUTOCONFIG' and l_source_type = 3 ) then

                            v_100_procured := 'Y' ;

                        else

                            v_100_procured := 'N' ;
                        end if ;


                        l_curr_rank  := null ;

                        lStmtNumber := 90;

		        insert into bom_cto_src_orgs_b
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
				p_top_ato_line_id ,
				p_line_id ,
				p_model_item_id ,
				p_organization_id, /* will work for end of chain source or no source */
				p_organization_id,
				decode( v_100_procured , 'Y'  , 'N' , decode( bp.create_config_bom , 'Y',
                                        decode(bom.assembly_item_id, null , 'N', 'Y')
                                        , 'N')) ,  -- create_bom
				'Y',		-- cost_rollup
				l_source_type,	-- org_type is used to store the source type
				p_config_item_id ,		-- config_item_id
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
		        from bom_bill_of_materials bom, bom_parameters bp
                        where p_organization_id = bp.organization_id
                          and p_model_item_id = bom.assembly_item_id(+)
                          and bp.organization_id = bom.organization_id(+)
                          and bom.alternate_bom_designator is null
                          and NOT EXISTS    /* NOT EXISTS should be there to check whether same org is reached thru other paths */
                                (select NULL
                                  from bom_cto_src_orgs_b
                                  where line_id = p_line_id
                                    and rcv_org_id = p_organization_id
                                    and organization_id = p_organization_id
                                    and organization_type = l_source_type
                                    and model_item_id = p_model_item_id ) ;


                        IF PG_DEBUG <> 0 THEN
                             oe_debug_pub.add( 'inserted bcso for end of chain  '  || SQL%rowcount , 1 ) ;
                             oe_debug_pub.add( 'inserted bcso for end of chain '  || p_organization_id ||
                                               ' org ' || p_organization_id
                                               , 1 ) ;
                        END IF;



                end if;



               IF PG_DEBUG <> 0 THEN
	       oe_debug_pub.add('process_sourcing_chain: ' || 'end p_organization_id '||to_char(p_organization_id), 1);
	       oe_debug_pub.add('process_sourcing_chain: ' || 'end px_concat_org_id '|| px_concat_org_id , 1);
               END IF;

	       x_orgs_tbl.delete(p_organization_id);  --Bugfix 7522447/7410091
	       IF PG_DEBUG <> 0 THEN
	       oe_debug_pub.add('process_sourcing_chain: ' || 'Org deleted from collection: '||to_char(p_organization_id), 1);
	       END IF;




EXCEPTION
 WHEN fnd_api.g_exc_error THEN
        IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('process_sourcing_chain: ' || 'Exception in stmt num: '
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
                oe_debug_pub.add('process_sourcing_chain: ' || ' Unexpected Exception in stmt num: '
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

                oe_debug_pub.add('process_sourcing_chain: ' || 'Others Exception in stmt num: '
                                    || to_char(lStmtNum), 1);
                oe_debug_pub.add('process_sourcing_chain: ' || 'errormsg='||sqlerrm, 1);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );

END process_sourcing_chain;



/*
** This procedure checks whether a model has been sourced.
** It also checks for circular sourcing and flags an error if it detects one.
** This procedure keeps on chaining sourcing rules till no more sourcing rules exist.
*/



PROCEDURE query_sourcing_org_ms(
  p_inventory_item_id    NUMBER
, p_organization_id      NUMBER
, p_sourcing_rule_exists OUT NOCOPY varchar2
, p_source_type          OUT NOCOPY NUMBER    -- Added by Renga Kannan on 08/21/01
, p_t_sourcing_info      OUT NOCOPY SOURCING_INFO
, x_exp_error_code       OUT NOCOPY NUMBER
, x_return_status        OUT NOCOPY varchar2
)
is
v_sourcing_rule_id    number ;
l_stmt_num            number ;
v_source_type         varchar2(1) ;
v_sourcing_rule_count number;         -- Added by Renga Kannan on 08/21/01

l_make_buy_code       number;



cursor item_sources  is
              select distinct
                source_organization_id,
                sourcing_rule_id,
                nvl(source_type,1) ,
                rank,
                assignment_id,
                assignment_type
              from mrp_sources_v msv
              where msv.assignment_set_id = gMrpAssignmentSet
                and msv.inventory_item_id = p_inventory_item_id
                and msv.organization_id = p_organization_id
              --  and nvl(msv.source_type,1) <> 3 commented by Renga for BUY odel
                and nvl(effective_date,sysdate) <= nvl(disable_date, sysdate) -- Nvl fun is added by Renga Kannan on 05/05/2001
                and nvl(disable_date, sysdate+1) > sysdate;

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
             	oe_debug_pub.add('query_sourcing_org_ms: ' || 'Initializing the assignment set',5);
             END IF;
             initialize_assignment_set(x_return_status);
             if x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('query_sourcing_org_ms: ' || 'Error in initializing assignment set',5);
                END IF;
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
             end if;
           End IF;


           p_sourcing_rule_exists := FND_API.G_FALSE ;
           x_return_status := FND_API.G_RET_STS_SUCCESS ;


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



           open item_sources;


           -- loop

           fetch item_sources bulk collect into p_t_sourcing_info.source_organization_id
                                                 , p_t_sourcing_info.sourcing_rule_id
                                                 , p_t_sourcing_info.source_type
                                                 , p_t_sourcing_info.rank
                                                 , p_t_sourcing_info.assignment_id
                                                 , p_t_sourcing_info.assignment_type ;

              -- exit when item_sources%notfound ;


           -- end loop ;

           close item_sources ;


           oe_debug_pub.add('query_sourcing_org_ms: ' ||  '****$$$$ count ' || p_t_sourcing_info.source_organization_id.count , 1 ) ;


           for i in 1..p_t_sourcing_info.sourcing_rule_id.count
           loop

              	oe_debug_pub.add('query_sourcing_org_ms: ' ||  '****$$$$ org ' || p_t_sourcing_info.source_organization_id(i)
                                                        ||  '****$$$$ rule  ' || p_t_sourcing_info.sourcing_rule_id(i)
                                                        ||  '****$$$$ type  ' || p_t_sourcing_info.source_type(i)
                                                        ||  '****$$$$ rank ' || p_t_sourcing_info.rank(i)
                                                        ||  '****$$$$ assig id  ' || p_t_sourcing_info.assignment_id(i)  , 1 ) ;
           end loop ;



              /*
              ** item is multi-org if sourcing rule is transfer from.
              */
              l_stmt_num := 20 ;

              --- The following assignment stmt is added by Renga Kannan
              --- to pass back the source type value as parameter


              if( p_t_sourcing_info.sourcing_rule_id.count > 0 ) then
                  p_sourcing_rule_exists := FND_API.G_TRUE ;

              end if ;



           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('query_sourcing_org_ms: ' ||  ' came into no data when finding source ' || to_char(l_stmt_num ) , 1  );
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


              WHEN OTHERS THEN
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('query_sourcing_org_ms: ' ||  'query_sourcing_org_ms::others:: ' ||
                                   to_char(l_stmt_num) || '::' ||
                                  ' came into others when finding source ' , 1  );

                	oe_debug_pub.add('query_sourcing_org_ms: ' ||  ' SQLCODE ' || SQLCODE , 1 );

                	oe_debug_pub.add('query_sourcing_org_ms: ' ||  ' SQLERRM ' || SQLERRM  , 1 );

                	oe_debug_pub.add('query_sourcing_org_ms: ' ||  ' came into others when finding source ' , 1  );
                END IF;

                x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;



end query_sourcing_org_ms ;








/*--------------------------------------------------------------------------+
This procedure creates sourcing information for a configuration item.
It copies the sourcing rule assignment of the model into the configuration
item and adds this assignment to the MRP default assignment set.
+-------------------------------------------------------------------------*/


PROCEDURE Create_Sourcing_Rules(pModelItemId	in	number,
				pConfigId	in	number,
				pRcvOrgId	in	number,
				x_return_status	OUT	NOCOPY varchar2,
				x_msg_count	OUT	NOCOPY number,
				x_msg_data	OUT	NOCOPY varchar2,
                                p_mode          in      varchar2 default 'AUTOCONFIG' )
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

lUPGAssignmentSet	number;
BEGIN

	x_return_status := FND_API.G_RET_STS_SUCCESS;
	lAssignmentExists := 0;

	lStmtNum := 10;
	/* get MRP's default assignment set */
	lMrpAssignmentSet := to_number(FND_PROFILE.VALUE('MRP_DEFAULT_ASSIGNMENT_SET'));




        if( p_mode  = 'AUTOCONFIG' ) then

            lUPGAssignmentSet := lMrpAssignmentSet ;

        else

            select assignment_set_id into lUPGAssignmentSet
              from mrp_assignment_sets
             where assignment_set_name = 'CTO Configuration Updates' ;

        end if;





	IF lMrpAssignmentSet is null THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'Default assignment set is null, returning from create_sourcing_rules procedure',1);
		END IF;
		return;
	ELSE
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'Default assignment set is '||to_char(lMrpAssignmentSet),2);
			oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'Upgrade assignment set is '||to_char(lUPGAssignmentSet),2);
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

	-- Fixed FP bug 5156690
	-- MPR_SOURCES_V will return all the sourcing info including the ones
	-- that are defined in the item definition
	-- we should copy only the explicit sourcing assignments defined by users
	-- added another filter condition assignment_id is not null to select
	-- only explicit sourcing rules from mrp_sources_v view definition

        BEGIN

	   select distinct assignment_id, assignment_type
	   into lAssignmentId, lAssignmentType
	   from mrp_sources_v msv
	   where msv.assignment_set_id = lMrpAssignmentSet
	   and msv.inventory_item_id = pModelItemId
	   and msv.organization_id = pRcvOrgId
	   and effective_date <= nvl(disable_date, sysdate)
	   and nvl(disable_date, sysdate+1) > sysdate
           and assignment_type in (3,6)
	   and assignment_id is not null;

        EXCEPTION
	WHEN NO_DATA_FOUND THEN

           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'There is no sourcing rule defined ',1);
           END IF;
           raise no_sourcing_defined;

        END;


	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'lAssnType::'||to_char(lAssignmentType)||'::lAssnId::'||to_char(lAssignmentId),2);
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

        -- bug 8789722
        --
        /*
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
             WHERE   ASSIGNMENT_ID = lAssignmentId;*/

          /*-------------------
          bug 8789722
          Start
          --------------------*/
          BEGIN
             IF pConfigId IS NOT NULL THEN
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
                     FROM    MRP_SR_ASSIGNMENTS A
                     WHERE   ASSIGNMENT_ID = lAssignmentId
                     AND NOT EXISTS(SELECT /*+ INDEX(B MRP_SR_ASSIGNMENTS_U2)*/ 1
                                     FROM MRP_SR_ASSIGNMENTS B
                                    WHERE a.assignment_set_id = b.assignment_set_id and
                                          a.assignment_type = b.assignment_type and
                                          nvl(b.organization_id,-1) = nvl(a.organization_id,-1) and
                                          nvl(b.customer_id,-1) = nvl(a.customer_id,-1) and
                                          nvl(b.ship_to_site_id,-1) = nvl(a.ship_to_site_id,-1) and
                                          b.sourcing_rule_type = a.sourcing_rule_type and
                                          b.inventory_item_id = pConfigId and
                                          nvl(b.category_id,-1) = nvl(a.category_id,-1) and
                                          rownum = 1);
             ELSE
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
                     FROM    MRP_SR_ASSIGNMENTS A
                     WHERE   ASSIGNMENT_ID = lAssignmentId
                     AND NOT EXISTS(SELECT /*+ INDEX(B MRP_SR_ASSIGNMENTS_U2)*/ 1
                                     FROM MRP_SR_ASSIGNMENTS B
                                    WHERE a.assignment_set_id = b.assignment_set_id and
                                          a.assignment_type = b.assignment_type and
                                          nvl(b.organization_id,-1) = nvl(a.organization_id,-1) and
                                          nvl(b.customer_id,-1) = nvl(a.customer_id,-1) and
                                          nvl(b.ship_to_site_id,-1) = nvl(a.ship_to_site_id,-1) and
                                          b.sourcing_rule_type = a.sourcing_rule_type and
                                          b.inventory_item_id IS NULL and
                                          nvl(b.category_id,-1) = nvl(a.category_id,-1) and
                                          rownum = 1);
             END IF;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN

                IF PG_DEBUG <> 0 THEN
                    oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'assignment exists already, do not recreate go to end of loop',2);
                END IF;

                RETURN;

          WHEN OTHERS THEN
                IF PG_DEBUG <> 0 THEN
                    oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'others exception while checking ifassignment exists, not handling, creating assignment:: '||sqlerrm,2);
                END IF;
          END;

          IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'after query row',2);
          END IF;

        --
        -- check if this assignment already exists for config item
        --
        lStmtNum := 35;
--      BEGIN
--
--		IF PG_DEBUG <> 0 THEN
--			oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'assignment_set_id::'||to_char(lAssignmentRec.assignment_set_id),2);
--
--			oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'assignment_type::'||to_char(lAssignmentRec.assignment_type),2);
--
--			oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'organization_id::'||to_char(lAssignmentRec.organization_id),2);
--
--			oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'customer_id::'||to_char(lAssignmentRec.customer_id),2);
--
--			oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'ship_to_site_id::'||to_char(lAssignmentRec.ship_to_site_id),2);
--
--			oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'sourcing_rule_type::'||to_char(lAssignmentRec.sourcing_rule_type),2);
--
--			oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'inventory_item_id:: '||to_char(pConfigId),2);
--
--			oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'category_id:: '||to_char(lAssignmentRec.category_id),2);
--		END IF;
--
--                -- bug 6617686
--                IF pConfigId IS NOT NULL THEN
--                        select 1
--                        into lAssignmentExists
--                        from mrp_sr_assignments
--                        where assignment_set_id = lUPGAssignmentSet   /* lAssignmentRec.assignment_set_id  commented for upgrade logic */
--                        and assignment_type = lAssignmentRec.assignment_type
--                        and nvl(organization_id,-1) = nvl(lAssignmentRec.organization_id,-1)
--                        and nvl(customer_id,-1) = nvl(lAssignmentRec.customer_id,-1)
--                        and nvl(ship_to_site_id,-1) = nvl(lAssignmentRec.ship_to_site_id,-1)
--                        and sourcing_rule_type = lAssignmentRec.sourcing_rule_type
--                        and inventory_item_id = pConfigId
--                        and nvl(category_id,-1) = nvl(lAssignmentRec.category_id,-1);
--                ELSE
--                        select 1
--                        into lAssignmentExists
--                        from mrp_sr_assignments
--                        where assignment_set_id = lUPGAssignmentSet   /* lAssignmentRec.assignment_set_id  commented for upgrade logic */
--                        and assignment_type = lAssignmentRec.assignment_type
--                        and nvl(organization_id,-1) = nvl(lAssignmentRec.organization_id,-1)
--                        and nvl(customer_id,-1) = nvl(lAssignmentRec.customer_id,-1)
--                        and nvl(ship_to_site_id,-1) = nvl(lAssignmentRec.ship_to_site_id,-1)
--                        and sourcing_rule_type = lAssignmentRec.sourcing_rule_type
--                        and nvl(inventory_item_id,-1) IS NULL
--                        and nvl(category_id,-1) = nvl(lAssignmentRec.category_id,-1);
--                END IF;
--                -- end: bug 6617686
--
--		IF lAssignmentExists = 1 THEN
--			IF PG_DEBUG <> 0 THEN
--				oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'assignment exists already, do not recreate',2);
--			END IF;
--			return;
--		END IF;
--
--	EXCEPTION
--		when NO_DATA_FOUND then
--			IF PG_DEBUG <> 0 THEN
--				oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'assignment does not exist, create it',2);
--			END IF;
--		when OTHERS then
--			IF PG_DEBUG <> 0 THEN
--				oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'others exception while checking ifassignment exists, not handling, creating assignment:: '||sqlerrm,2);
--			END IF;
--	END;

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
	lAssignmentTbl(1).Assignment_Set_Id	:= lUPGAssignmentSet ;   /* commented for upgrade logic lAssignmentRec.Assignment_Set_Id; */
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
		oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'after forming lAssignmentTbl',2);
	END IF;

	--
	-- form lAssignmentSetRec
	--
	lStmtNum := 50;
	lAssignmentSetRec.operation := MRP_Globals.G_OPR_NONE;
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'after forming lAssignmentSetRec',2);
	END IF;

	--
	-- call mrp API to insert rec into assignment set
	--
	lStmtNum := 60;
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'before Process_Assignment',2);
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
			oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'unexp error in process_assignment::'||sqlerrm,1);
		END IF;
		raise FND_API.G_EXC_UNEXPECTED_ERROR;

	ELSIF	l_return_status = FND_API.G_RET_STS_ERROR THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'error in process_assignment::'||sqlerrm,1);
		END IF;

                oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: count:'||l_msg_count , 1 );

                IF l_msg_count > 0 THEN
                   FOR l_index IN 1..l_msg_count LOOP
                       l_msg_data := fnd_msg_pub.get(
                          p_msg_index => l_index,
                          p_encoded   => FND_API.G_FALSE);

                       oe_debug_pub.add( 'CTO_MSUTIL_PUB.create_sourcing_rule: ' || substr(l_msg_data,1,250)  , 1 );
                   END LOOP;

                   oe_debug_pub.add(' CTO_MSUTIL_PUB.create_sourcing_rules: MSG:'|| xAssignmentSetRec.return_status);
                END IF;

                oe_debug_pub.add('Failure!' , 1 );


		raise FND_API.G_EXC_ERROR;

	END IF;
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'success in process_assignment',2);
	END IF;

EXCEPTION
        When NO_sourcing_defined THEN
                null;

	when FND_API.G_EXC_ERROR then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'Create_Src_Rules::exp error::'||to_char(lStmtNum)||'::'||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;
		CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);

	when FND_API.G_EXC_UNEXPECTED_ERROR then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'Create_Src_Rules::unexp error::'||to_char(lStmtNum)||'::'||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);

	when OTHERS then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'Create_Src_Rules::others::'||to_char(lStmtNum)||'::'||sqlerrm,1);
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


PROCEDURE Create_TYPE3_Sourcing_Rules(pModelItemId	in	number,
				pConfigId	in	number,
				pRcvOrgId	in	number,
				x_return_status	OUT	NOCOPY varchar2,
				x_msg_count	OUT	NOCOPY number,
				x_msg_data	OUT	NOCOPY varchar2,
                                p_mode          in      varchar2 default 'AUTOCONFIG'  )
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


lUPGAssignmentSet	number;

cursor c_type3_assignments ( c_def_assg_set number, c_item_id number)
is
select
            /*
             nvl(rcv.receipt_organization_id,assg.organization_id),
                    src.source_organization_id,
             assg.customer_id,
             assg.ship_to_site_id,
                    src.VENDOR_ID,
                    vend.VENDOR_SITE_code,
                    src.RANK,
                    src.ALLOCATION_PERCENT,
                    src.SOURCE_TYPE,
             assg.sourcing_rule_id,
             rcv.sr_receipt_id,
             src.sr_source_id,
             */
             --Bugfix 13029577: Adding a distinct. This sql returns same assignment_id multiple
             --times if there is a global transfer from sourcing rule from multiple orgs. Ex.
             --Let the rule be:
             --Transfer from M1:50%, M2:30%, M3:15%, M4:5%
             --For this sourcing rule, there would be 4 records in table mrp_sr_source_org for one
             --value of sr_receipt_id.
             --The result is that the same assignment is attempted multiple times. MRP API
             --process_assignment throws ORA-00001: unique constraint (MRP.MRP_SR_ASSIGNMENTS_U2)
             --violated error.
 	     distinct
             assg.assignment_id,
             assg.assignment_type
      from
                    mrp_sr_receipt_org rcv,
                    mrp_sr_source_org src,
                    mrp_sr_assignments assg,
             mrp_sourcing_rules rule,
             po_vendor_sites_all vend
      where
             assg.assignment_set_id   = c_def_assg_set
       and   assg.inventory_item_id   = c_item_id
              and   assg.sourcing_rule_id    = rcv.sourcing_rule_id
       and   assg.sourcing_rule_id    = rule.sourcing_rule_id
       and   rule.planning_active     = 1
              and   rcv.effective_date      <= sysdate
              and   nvl(rcv.disable_date,sysdate+1)>sysdate
              and   rcv.SR_RECEIPT_ID        = src.sr_receipt_id
       and   src.vendor_site_id = vend.vendor_site_id(+) ;

      --debugging for bug 13029577
      cursor c_config_assignments(c_def_assg_set number, c_item_id number) is
        select assignment_set_id,
               assignment_type,
               organization_id,
               customer_id,
               ship_to_site_id,
               sourcing_rule_type,
               category_id
        from mrp_sr_assignments
        where assignment_set_id = c_def_assg_set
        and inventory_item_id = c_item_id;
BEGIN

	x_return_status := FND_API.G_RET_STS_SUCCESS;
	lAssignmentExists := 0;

	lStmtNum := 10;
	/* get MRP's default assignment set */
	lMrpAssignmentSet := to_number(FND_PROFILE.VALUE('MRP_DEFAULT_ASSIGNMENT_SET'));

        if( p_mode   = 'AUTOCONFIG' ) then

            lUPGAssignmentSet := lMrpAssignmentSet ;

        else

            select assignment_set_id into lUPGAssignmentSet
              from mrp_assignment_sets
             where assignment_set_name = 'CTO Configuration Updates' ;

        end if;







	IF lMrpAssignmentSet is null THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'Default assignment set is null, returning from create_sourcing_rules procedure',1);
		END IF;
		return;
	ELSE
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'Default assignment set is '||to_char(lMrpAssignmentSet),2);
			oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'UPG assignment set is '||to_char(lUPGAssignmentSet),2);
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


        /*


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
           	oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'There is no sourcing rule defined ',1);
           END IF;
           raise no_sourcing_defined;

        END;


        */






        open c_type3_assignments ( lMrpAssignmentSet , pModelItemId ) ;


        LOOP


              fetch c_type3_assignments into lAssignmentId, lAssignmentType ;



              exit when c_type3_assignments%notfound ;


	      IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'lAssnType::'||to_char(lAssignmentType)||'::lAssnId::'||to_char(lAssignmentId),2);
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

              -- bug 8789722
              --
              /*
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
               WHERE   ASSIGNMENT_ID = lAssignmentId;*/

             /*-------------------
               bug 8789722
               Start
              --------------------*/
              BEGIN
                 IF pConfigId IS NOT NULL THEN
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
                     FROM    MRP_SR_ASSIGNMENTS A
                     WHERE   ASSIGNMENT_ID = lAssignmentId
                     AND NOT EXISTS(SELECT /*+ INDEX(B MRP_SR_ASSIGNMENTS_U2)*/ 1
                                     FROM MRP_SR_ASSIGNMENTS B
                                    WHERE a.assignment_set_id = b.assignment_set_id and
                                          a.assignment_type = b.assignment_type and
                                          nvl(b.organization_id,-1) = nvl(a.organization_id,-1) and
                                          nvl(b.customer_id,-1) = nvl(a.customer_id,-1) and
                                          nvl(b.ship_to_site_id,-1) = nvl(a.ship_to_site_id,-1) and
                                          b.sourcing_rule_type = a.sourcing_rule_type and
                                          b.inventory_item_id = pConfigId and
                                          nvl(b.category_id,-1) = nvl(a.category_id,-1) and
                                          rownum = 1);
                 ELSE
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
                     FROM    MRP_SR_ASSIGNMENTS A
                     WHERE   ASSIGNMENT_ID = lAssignmentId
                     AND NOT EXISTS(SELECT /*+ INDEX(B MRP_SR_ASSIGNMENTS_U2)*/ 1
                                     FROM MRP_SR_ASSIGNMENTS B
                                    WHERE a.assignment_set_id = b.assignment_set_id and
                                          a.assignment_type = b.assignment_type and
                                          nvl(b.organization_id,-1) = nvl(a.organization_id,-1) and
                                          nvl(b.customer_id,-1) = nvl(a.customer_id,-1) and
                                          nvl(b.ship_to_site_id,-1) = nvl(a.ship_to_site_id,-1) and
                                          b.sourcing_rule_type = a.sourcing_rule_type and
                                          b.inventory_item_id IS NULL and
                                          nvl(b.category_id,-1) = nvl(a.category_id,-1) and
                                          rownum = 1);
              END IF;

              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'assignment exists already, do not recreate',2);
                    END IF;
                    goto END_OF_LOOP;

                 WHEN OTHERS THEN
                    IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: ' || 'others exception while checking ifassignment exists, not handling, creating assignment:: '||sqlerrm,2);
                    END IF;
              END;

              IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'after query row',2);
              END IF;

	      --
	      -- check if this assignment already exists for config item
	      --
	      lStmtNum := 35;
--	      BEGIN
--
--		IF PG_DEBUG <> 0 THEN
--			oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'assignment_set_id::'||to_char(lAssignmentRec.assignment_set_id),2);
--
--			oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'Source assignment_set_id::'||to_char(lMrpAssignmentSet),2);
--			oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'Destination assignment_set_id::'||to_char(lUPGAssignmentSet),2);
--
--			oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'assignment_type::'||to_char(lAssignmentRec.assignment_type),2);
--
--			oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'organization_id::'||to_char(lAssignmentRec.organization_id),2);
--
--			oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'customer_id::'||to_char(lAssignmentRec.customer_id),2);
--
--			oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'ship_to_site_id::'||to_char(lAssignmentRec.ship_to_site_id),2);
--
--			oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'sourcing_rule_type::'||to_char(lAssignmentRec.sourcing_rule_type),2);
--
--			oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'inventory_item_id:: '||to_char(pConfigId),2);
--
--			oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'category_id:: '||to_char(lAssignmentRec.category_id),2);
--		END IF;
--
--		-- bug 6617686
--                IF pConfigId IS NOT NULL THEN
--                        select 1
--                        into lAssignmentExists
--                        from mrp_sr_assignments
--                        where assignment_set_id = lUPGAssignmentSet  /*  commented for upgrade issues lAssignmentRec.assignment_set_id */
--                        and assignment_type = lAssignmentRec.assignment_type
--                        and nvl(organization_id,-1) = nvl(lAssignmentRec.organization_id,-1)
--                        and nvl(customer_id,-1) = nvl(lAssignmentRec.customer_id,-1)
--                        and nvl(ship_to_site_id,-1) = nvl(lAssignmentRec.ship_to_site_id,-1)
--                        and sourcing_rule_type = lAssignmentRec.sourcing_rule_type
--                        and nvl(inventory_item_id,-1) = pConfigId
--                        and nvl(category_id,-1) = nvl(lAssignmentRec.category_id,-1);
--                ELSE
--                        select 1
--                        into lAssignmentExists
--                        from mrp_sr_assignments
--                        where assignment_set_id = lUPGAssignmentSet  /*  commented for upgrade issues lAssignmentRec.assignment_set_id */
--                        and assignment_type = lAssignmentRec.assignment_type
--                        and nvl(organization_id,-1) = nvl(lAssignmentRec.organization_id,-1)
--                        and nvl(customer_id,-1) = nvl(lAssignmentRec.customer_id,-1)
--                        and nvl(ship_to_site_id,-1) = nvl(lAssignmentRec.ship_to_site_id,-1)
--                        and sourcing_rule_type = lAssignmentRec.sourcing_rule_type
--                        and inventory_item_id is null
--                        and nvl(category_id,-1) = nvl(lAssignmentRec.category_id,-1);
--                END IF;
--                -- end : bug 6617686
--
--		IF lAssignmentExists = 1 THEN
--			IF PG_DEBUG <> 0 THEN
--				oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'assignment exists already, do not recreate',2);
--			END IF;
--
--
--
--			goto END_OF_LOOP ; /* continue with next record */
--
--
--		END IF;
--
--	      EXCEPTION
--		when NO_DATA_FOUND then
--			IF PG_DEBUG <> 0 THEN
--				oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'assignment does not exist, create it',2);
--			END IF;
--		when OTHERS then
--			IF PG_DEBUG <> 0 THEN
--				oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' ||
--                                'others exception while checking ifassignment exists, not handling, creating assignment:: '||sqlerrm,2);
--			END IF;
--	      END;

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
	      lAssignmentTbl(1).Assignment_Id 	        := lConfigAssignmentId;
	      lAssignmentTbl(1).Assignment_Set_Id	:= lUPGAssignmentSet  ;  /* commented for upgrade logic lAssignmentRec.Assignment_Set_Id; */
	      lAssignmentTbl(1).Assignment_Type	        := lAssignmentRec.Assignment_Type;
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
	      lAssignmentTbl(1).Category_Set_Id	        := lAssignmentRec.Category_Set_Id;
	      lAssignmentTbl(1).Created_By		:= lAssignmentRec.Created_By;
	      lAssignmentTbl(1).Creation_Date		:= lAssignmentRec.Creation_Date;
	      lAssignmentTbl(1).Customer_Id		:= lAssignmentRec.Customer_Id;
	      lAssignmentTbl(1).Inventory_Item_Id	:= pConfigId;
	      lAssignmentTbl(1).Last_Updated_By	        := lAssignmentRec.Last_Updated_By;
	      lAssignmentTbl(1).Last_Update_Date	:= lAssignmentRec.Last_Update_Date;
	      lAssignmentTbl(1).Last_Update_Login	:= lAssignmentRec.Last_Update_Login;
	      lAssignmentTbl(1).Organization_Id	        := lAssignmentRec.Organization_Id;
	      lAssignmentTbl(1).Program_Application_Id  := lAssignmentRec.Program_Application_Id;
	      lAssignmentTbl(1).Program_Id		:= lAssignmentRec.Program_Id;
	      lAssignmentTbl(1).Program_Update_Date	:= lAssignmentRec.Program_Update_Date;
	      lAssignmentTbl(1).Request_Id		:= lAssignmentRec.Request_Id;
	      lAssignmentTbl(1).Secondary_Inventory	:= lAssignmentRec.Secondary_Inventory;
	      lAssignmentTbl(1).Ship_To_Site_Id	        := lAssignmentRec.Ship_To_Site_Id;
	      lAssignmentTbl(1).Sourcing_Rule_Id	:= lAssignmentRec.Sourcing_Rule_Id;
	      lAssignmentTbl(1).Sourcing_Rule_Type	:= lAssignmentRec.Sourcing_Rule_Type;
	      lAssignmentTbl(1).return_status		:= NULL;
	      lAssignmentTbl(1).db_flag    		:= NULL;
	      lAssignmentTbl(1).operation 		:= MRP_Globals.G_OPR_CREATE;

	      IF PG_DEBUG <> 0 THEN
		      oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'after forming lAssignmentTbl',2);
	      END IF;

	      --
	      -- form lAssignmentSetRec
	      --
	      lStmtNum := 50;
	      lAssignmentSetRec.operation := MRP_Globals.G_OPR_NONE;
	      IF PG_DEBUG <> 0 THEN
		      oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'after forming lAssignmentSetRec',2);
	      END IF;

	      --
	      -- call mrp API to insert rec into assignment set
	      --
	      lStmtNum := 60;
              IF PG_DEBUG <> 0 THEN
                   oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'before Process_Assignment',2);
                   oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'printing lAssignmentRec');
                   oe_debug_pub.add('--------------------------------------------------------------------------');
                   oe_debug_pub.add('lAssignmentRec.ASSIGNMENT_ID:' || lAssignmentRec.ASSIGNMENT_ID );
                   oe_debug_pub.add('lAssignmentRec.ASSIGNMENT_SET_ID:' || lAssignmentRec.ASSIGNMENT_SET_ID );
                   oe_debug_pub.add('lAssignmentRec.ASSIGNMENT_TYPE:' || lAssignmentRec.ASSIGNMENT_TYPE );
                   oe_debug_pub.add('lAssignmentRec.ATTRIBUTE1:' || lAssignmentRec.ATTRIBUTE1 );
                   oe_debug_pub.add('lAssignmentRec.ATTRIBUTE2:' || lAssignmentRec.ATTRIBUTE2 );
                   oe_debug_pub.add('lAssignmentRec.ATTRIBUTE3:' || lAssignmentRec.ATTRIBUTE3 );
                   oe_debug_pub.add('lAssignmentRec.ATTRIBUTE4:' || lAssignmentRec.ATTRIBUTE4 );
                   oe_debug_pub.add('lAssignmentRec.ATTRIBUTE5:' || lAssignmentRec.ATTRIBUTE5 );
                   oe_debug_pub.add('lAssignmentRec.ATTRIBUTE6:' || lAssignmentRec.ATTRIBUTE6 );
                   oe_debug_pub.add('lAssignmentRec.ATTRIBUTE7:' || lAssignmentRec.ATTRIBUTE7 );
                   oe_debug_pub.add('lAssignmentRec.ATTRIBUTE8:' || lAssignmentRec.ATTRIBUTE8 );
                   oe_debug_pub.add('lAssignmentRec.ATTRIBUTE9:' || lAssignmentRec.ATTRIBUTE9 );
                   oe_debug_pub.add('lAssignmentRec.ATTRIBUTE10:' || lAssignmentRec.ATTRIBUTE10 );
                   oe_debug_pub.add('lAssignmentRec.ATTRIBUTE11:' || lAssignmentRec.ATTRIBUTE11 );
                   oe_debug_pub.add('lAssignmentRec.ATTRIBUTE12:' || lAssignmentRec.ATTRIBUTE12 );
                   oe_debug_pub.add('lAssignmentRec.ATTRIBUTE13:' || lAssignmentRec.ATTRIBUTE13 );
                   oe_debug_pub.add('lAssignmentRec.ATTRIBUTE14:' || lAssignmentRec.ATTRIBUTE14 );
                   oe_debug_pub.add('lAssignmentRec.ATTRIBUTE15:' || lAssignmentRec.ATTRIBUTE15 );
                   oe_debug_pub.add('lAssignmentRec.ATTRIBUTE_CATEGORY:' || lAssignmentRec.ATTRIBUTE_CATEGORY );
                   oe_debug_pub.add('lAssignmentRec.CATEGORY_ID:' || lAssignmentRec.CATEGORY_ID );
                   oe_debug_pub.add('lAssignmentRec.CATEGORY_SET_ID:' || lAssignmentRec.CATEGORY_SET_ID );
                   oe_debug_pub.add('lAssignmentRec.CREATED_BY:' || lAssignmentRec.CREATED_BY );
                   oe_debug_pub.add('lAssignmentRec.CREATION_DATE:' || lAssignmentRec.CREATION_DATE );
                   oe_debug_pub.add('lAssignmentRec.CUSTOMER_ID:' || lAssignmentRec.CUSTOMER_ID );
                   oe_debug_pub.add('lAssignmentRec.INVENTORY_ITEM_ID:' || lAssignmentRec.INVENTORY_ITEM_ID );
                   oe_debug_pub.add('lAssignmentRec.LAST_UPDATED_BY:' || lAssignmentRec.LAST_UPDATED_BY );
                   oe_debug_pub.add('lAssignmentRec.LAST_UPDATE_DATE:' || lAssignmentRec.LAST_UPDATE_DATE );
                   oe_debug_pub.add('lAssignmentRec.LAST_UPDATE_LOGIN:' || lAssignmentRec.LAST_UPDATE_LOGIN );
                   oe_debug_pub.add('lAssignmentRec.ORGANIZATION_ID:' || lAssignmentRec.ORGANIZATION_ID );
                   oe_debug_pub.add('lAssignmentRec.PROGRAM_APPLICATION_ID:' || lAssignmentRec.PROGRAM_APPLICATION_ID );
                   oe_debug_pub.add('lAssignmentRec.PROGRAM_ID:' || lAssignmentRec.PROGRAM_ID );
                   oe_debug_pub.add('lAssignmentRec.PROGRAM_UPDATE_DATE:' || lAssignmentRec.PROGRAM_UPDATE_DATE );
                   oe_debug_pub.add('lAssignmentRec.REQUEST_ID:' || lAssignmentRec.REQUEST_ID );
                   oe_debug_pub.add('lAssignmentRec.SECONDARY_INVENTORY:' || lAssignmentRec.SECONDARY_INVENTORY );
                   oe_debug_pub.add('lAssignmentRec.SHIP_TO_SITE_ID:' || lAssignmentRec.SHIP_TO_SITE_ID );
                   oe_debug_pub.add('lAssignmentRec.SOURCING_RULE_ID:' || lAssignmentRec.SOURCING_RULE_ID );
                   oe_debug_pub.add('lAssignmentRec.SOURCING_RULE_TYPE:' || lAssignmentRec.SOURCING_RULE_TYPE );
                   oe_debug_pub.add('lAssignmentRec.OPERATION:' || lAssignmentRec.OPERATION );
                   oe_debug_pub.add('--------------------------------------------------------------------------');
                   oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'printing lAssignmentRec');
                   oe_debug_pub.add('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                   oe_debug_pub.add('lAssignmentTbl(1).Assignment_Id:' || lAssignmentTbl(1).Assignment_Id);
                   oe_debug_pub.add('lAssignmentTbl(1).Assignment_Set_Id:' || lAssignmentTbl(1).Assignment_Set_Id);
                   oe_debug_pub.add('lAssignmentTbl(1).Assignment_Type:' || lAssignmentTbl(1).Assignment_Type);
                   oe_debug_pub.add('lAssignmentTbl(1).Attribute1:' || lAssignmentTbl(1).Attribute1);
                   oe_debug_pub.add('lAssignmentTbl(1).Attribute10:' || lAssignmentTbl(1).Attribute10);
                   oe_debug_pub.add('lAssignmentTbl(1).Attribute11:' || lAssignmentTbl(1).Attribute11);
                   oe_debug_pub.add('lAssignmentTbl(1).Attribute12:' || lAssignmentTbl(1).Attribute12);
                   oe_debug_pub.add('lAssignmentTbl(1).Attribute13:' || lAssignmentTbl(1).Attribute13);
                   oe_debug_pub.add('lAssignmentTbl(1).Attribute14:' || lAssignmentTbl(1).Attribute14);
                   oe_debug_pub.add('lAssignmentTbl(1).Attribute15:' || lAssignmentTbl(1).Attribute15);
                   oe_debug_pub.add('lAssignmentTbl(1).Attribute2:' || lAssignmentTbl(1).Attribute2);
                   oe_debug_pub.add('lAssignmentTbl(1).Attribute3:' || lAssignmentTbl(1).Attribute3);
                   oe_debug_pub.add('lAssignmentTbl(1).Attribute4:' || lAssignmentTbl(1).Attribute4);
                   oe_debug_pub.add('lAssignmentTbl(1).Attribute5:' || lAssignmentTbl(1).Attribute5);
                   oe_debug_pub.add('lAssignmentTbl(1).Attribute6:' || lAssignmentTbl(1).Attribute6);
                   oe_debug_pub.add('lAssignmentTbl(1).Attribute7:' || lAssignmentTbl(1).Attribute7);
                   oe_debug_pub.add('lAssignmentTbl(1).Attribute8:' || lAssignmentTbl(1).Attribute8);
                   oe_debug_pub.add('lAssignmentTbl(1).Attribute9:' || lAssignmentTbl(1).Attribute9);
                   oe_debug_pub.add('lAssignmentTbl(1).Attribute_Category:' || lAssignmentTbl(1).Attribute_Category);
                   oe_debug_pub.add('lAssignmentTbl(1).Category_Id:' || lAssignmentTbl(1).Category_Id);
                   oe_debug_pub.add('lAssignmentTbl(1).Category_Set_Id:' || lAssignmentTbl(1).Category_Set_Id);
                   oe_debug_pub.add('lAssignmentTbl(1).Created_By:' || lAssignmentTbl(1).Created_By);
                   oe_debug_pub.add('lAssignmentTbl(1).Creation_Date:' || lAssignmentTbl(1).Creation_Date);
                   oe_debug_pub.add('lAssignmentTbl(1).Customer_Id:' || lAssignmentTbl(1).Customer_Id);
                   oe_debug_pub.add('lAssignmentTbl(1).Inventory_Item_Id:' || lAssignmentTbl(1).Inventory_Item_Id);
                   oe_debug_pub.add('lAssignmentTbl(1).Last_Updated_By:' || lAssignmentTbl(1).Last_Updated_By);
                   oe_debug_pub.add('lAssignmentTbl(1).Last_Update_Date:' || lAssignmentTbl(1).Last_Update_Date);
                   oe_debug_pub.add('lAssignmentTbl(1).Last_Update_Login:' || lAssignmentTbl(1).Last_Update_Login);
                   oe_debug_pub.add('lAssignmentTbl(1).Organization_Id:' || lAssignmentTbl(1).Organization_Id);
                   oe_debug_pub.add('lAssignmentTbl(1).Program_Application_Id:' || lAssignmentTbl(1).Program_Application_Id);
                   oe_debug_pub.add('lAssignmentTbl(1).Program_Id:' || lAssignmentTbl(1).Program_Id);
                   oe_debug_pub.add('lAssignmentTbl(1).Program_Update_Date:' || lAssignmentTbl(1).Program_Update_Date);
                   oe_debug_pub.add('lAssignmentTbl(1).Request_Id:' || lAssignmentTbl(1).Request_Id);
                   oe_debug_pub.add('lAssignmentTbl(1).Secondary_Inventory:' || lAssignmentTbl(1).Secondary_Inventory);
                   oe_debug_pub.add('lAssignmentTbl(1).Ship_To_Site_Id:' || lAssignmentTbl(1).Ship_To_Site_Id);
                   oe_debug_pub.add('lAssignmentTbl(1).Sourcing_Rule_Id:' || lAssignmentTbl(1).Sourcing_Rule_Id);
                   oe_debug_pub.add('lAssignmentTbl(1).Sourcing_Rule_Type:' || lAssignmentTbl(1).Sourcing_Rule_Type);
                   oe_debug_pub.add('lAssignmentTbl(1).return_status:' || lAssignmentTbl(1).return_status);
                   oe_debug_pub.add('lAssignmentTbl(1).db_flag:' || lAssignmentTbl(1).db_flag);
                   oe_debug_pub.add('lAssignmentTbl(1).operation:' || lAssignmentTbl(1).operation);
                   oe_debug_pub.add('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
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
			oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'unexp error in process_assignment::'||sqlerrm,1);
                        oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'l_msg_data::'||l_msg_data,1);
		END IF;
		raise FND_API.G_EXC_UNEXPECTED_ERROR;

	      ELSIF	l_return_status = FND_API.G_RET_STS_ERROR THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'error in process_assignment::'||sqlerrm,1);
		END IF;


                oe_debug_pub.add('CTO_MSUTIL_PUB.create_sourcing_rules: count:'||l_msg_count , 1 );

                IF l_msg_count > 0 THEN
                   FOR l_index IN 1..l_msg_count LOOP
                       l_msg_data := fnd_msg_pub.get(
                          p_msg_index => l_index,
                          p_encoded   => FND_API.G_FALSE);

                       oe_debug_pub.add( 'CTO_MSUTIL_PUB.create_sourcing_rule: ' || substr(l_msg_data,1,250)  , 1 );
                   END LOOP;

                   oe_debug_pub.add(' CTO_MSUTIL_PUB.create_sourcing_rules: MSG:'|| xAssignmentSetRec.return_status);
                END IF;

                oe_debug_pub.add('Failure!' , 1 );


		raise FND_API.G_EXC_ERROR;

	      END IF;
	      IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'success in process_assignment',2);
	      END IF;


	      lStmtNum := 70;

	      oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'before end_of_loop',2);
              <<END_OF_LOOP>>
              null ;
	      oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'after end_of_loop',2);
        END LOOP;


        if( c_type3_assignments%rowcount = 0 ) then

	    oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'no sourcing assignments ',2);

        end if;

	lStmtNum := 80;

	oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'before close c_type3_assignments ',2);

        close c_type3_assignments ;

        --debugging for bug 13362916
        oe_debug_pub.add('++++++++++++++++++++++++++++++++++++++++++');
        oe_debug_pub.add('printing config assignment values');
        FOR v_config_assignments in c_config_assignments(lMrpAssignmentSet, pConfigId) LOOP
          oe_debug_pub.add('set_id:' || v_config_assignments.assignment_set_id ||
                           '::type::' || v_config_assignments.assignment_type ||
                           '::org::' || v_config_assignments.organization_id ||
                           '::cust::' || v_config_assignments.customer_id ||
                           '::ship::' || v_config_assignments.ship_to_site_id ||
                           '::rule_type::' || v_config_assignments.sourcing_rule_type ||
                           '::cat::' || v_config_assignments.category_id);
        END LOOP;
        oe_debug_pub.add('++++++++++++++++++++++++++++++++++++++++++');
        oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || 'Exit Create_TYPE3_Sourcing_Rules.');
        --end debugging for bug 13051516

EXCEPTION
        When NO_sourcing_defined THEN
                null;

	when FND_API.G_EXC_ERROR then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || '::exp error::'||to_char(lStmtNum)||'::'||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;
		CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);

	when FND_API.G_EXC_UNEXPECTED_ERROR then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || '::unexp error::'||to_char(lStmtNum)||'::'||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);

	when OTHERS then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('CTO_MSUTIL_PUB.create_type3_sourcing_rules: ' || '::others::'||to_char(lStmtNum)||'::'||sqlerrm,1);
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


END Create_TYPE3_Sourcing_Rules;




PROCEDURE initialize_assignment_set ( x_return_status OUT NOCOPY varchar2 )
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



procedure insert_val_into_bcso( p_top_ato_line_id       in NUMBER
                    , p_model_line_id in NUMBER
                    , p_model_item_id in NUMBER
                    , p_t_org_list            in CTO_MSUTIL_PUB.org_list
		    , p_config_item_id in number default null)
is
i number ;
v_source_type_code  varchar2(20) ;
begin

         oe_debug_pub.add( '$$$ insert val into bcso ' , 1 ) ;
         oe_debug_pub.add( '$$$ VAL ORGS count ' || p_t_org_list.count  , 1 ) ;



         begin
             select source_type_code into v_source_type_code
               from oe_order_lines_all
              where line_id = p_top_ato_line_id ;
         exception
         when others then
              v_source_type_code := 'INTERNAL' ;
         end ;

         oe_debug_pub.add( '$$$ source type code ' || v_source_type_code , 1 ) ;



         if( p_t_org_list.count > 0 ) then
         -- for i in 1..p_t_org_list.count

         i := p_t_org_list.first ;

         while i is not null
         loop

                        oe_debug_pub.add( '$$$ VAL ORGS ' || p_t_org_list(i) , 1 ) ;

		        insert into bom_cto_src_orgs_b
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
				p_top_ato_line_id ,
				p_model_line_id ,
				p_model_item_id ,
				null ,
				p_t_org_list(i),
				'N',		-- create_bom
				'N',		-- cost_rollup
				/* commented for dropship decode( v_source_type_code , 'INTERNAL' , NULL ,
                                        decode( p_top_ato_line_id, p_model_line_id, '5', '6' ))  , -- org_type used for source type
                                */
                                NULL,
				p_config_item_id, -- config_item_id
				'N',
				NULL , /* rank */
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
                               from bom_cto_src_orgs_b
                              where line_id = p_model_line_id
                                and model_item_id = p_model_item_id
                                and organization_id = p_t_org_list(i) );

         i := p_t_org_list.next(i) ;

         end loop ;

         end if ;



end insert_val_into_bcso ;



procedure insert_all_into_bcso( p_top_ato_line_id       in NUMBER
                    , p_model_line_id in NUMBER
                    , p_model_item_id in NUMBER
		    , p_config_item_id in NUMBER default null)
is
v_source_type_code   varchar2(20) ;

begin

         oe_debug_pub.add( '$$$ insert all into bcso ' , 1 ) ;


         begin
             select source_type_code into v_source_type_code
               from oe_order_lines_all
              where line_id = p_top_ato_line_id ;
         exception
         when others then
              v_source_type_code := 'INTERNAL' ;
         end ;

         oe_debug_pub.add( '$$$ source type code ' || v_source_type_code , 1 ) ;




		        insert into bom_cto_src_orgs_b
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
				p_top_ato_line_id ,
				p_model_line_id ,
				p_model_item_id ,
				null ,
				msi.organization_id,
				'N',		-- create_bom
				'N',		-- cost_rollup
                                /* commented for dropship
                                decode( v_source_type_code , 'INTERNAL' , NULL ,
                                        decode( p_top_ato_line_id, p_model_line_id, '5', '6' ))  , -- org_type used for source type
                                */
                                NULL,
				p_config_item_id,	-- config_item_id
				'N',
				NULL , /* rank */
				sysdate,	-- creation_date
				gUserId,	-- created_by
				sysdate,	-- last_update_date
				gUserId,	-- last_updated_by
				gLoginId,	-- last_update_login
				null, 		-- program_application_id,??
				null, 		-- program_id,??
				sysdate		-- program_update_date
		        from mtl_system_items msi
                        where msi.inventory_item_id = p_model_item_id
                        and  NOT EXISTS
                             (select NULL
                               from bom_cto_src_orgs_b
                              where line_id = p_model_line_id
                                and model_item_id = msi.inventory_item_id
                                and organization_id = msi.organization_id );



         oe_debug_pub.add( '$$$ insert all into bcso ' || SQL%rowcount  , 1 ) ;

end insert_all_into_bcso ;




procedure insert_type3_bcso( p_top_ato_line_id       in NUMBER
                    , p_model_line_id in NUMBER
                    , p_model_item_id in NUMBER
                    , p_config_item_id in NUMBER default null )
is
begin

         oe_debug_pub.add( '$$$ insert type3 bcso ' , 1 ) ;


		        insert into bom_cto_src_orgs_b
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
				p_top_ato_line_id ,
				p_model_line_id ,
				p_model_item_id ,
				null ,
				msi.organization_id,
				decode( bp.create_config_bom , 'Y',
                                        decode(bom.assembly_item_id, msi.inventory_item_id, 'Y', 'N')
                                        , 'N') ,  -- create_bom
				decode(bp.organization_id , null , 'N' , 'Y') ,		-- cost_rollup
				decode( msi.planning_make_buy_code, 2, 3 , 2 ) ,  -- org_type should be 3(buy) for buy items else 2(make)
				p_config_item_id,		-- config_item_id
				'N',    -- create_src_rules
				NULL , /* rank */
				sysdate,	-- creation_date
				gUserId,	-- created_by
				sysdate,	-- last_update_date
				gUserId,	-- last_updated_by
				gLoginId,	-- last_update_login
				null, 		-- program_application_id,??
				null, 		-- program_id,??
				sysdate		-- program_update_date
		        from mtl_system_items msi, bom_bill_of_materials bom, bom_parameters bp
                        where msi.inventory_item_id = p_model_item_id
                          and msi.inventory_item_id = bom.assembly_item_id(+)
                          and msi.organization_id  = bom.organization_id(+)
                          and bom.alternate_bom_designator is null
                          and msi.organization_id = bp.organization_id (+) /* added for bug 3504744 */
                        and  NOT EXISTS
                             (select NULL
                               from bom_cto_src_orgs_b
                              where line_id = p_model_line_id
                                and model_item_id = msi.inventory_item_id
                                and organization_id = msi.organization_id );




         oe_debug_pub.add( '$$$ insert type3 bcso ' || SQL%rowcount  , 1 ) ;

end insert_type3_bcso ;




procedure insert_type3_bcmo_bcso( p_top_ato_line_id       in NUMBER
                    , p_model_line_id in NUMBER
                    , p_model_item_id in NUMBER)
is
v_group_reference_id   number(10);
begin

         oe_debug_pub.add( '$$$ insert type3 bcmo bcso ' , 1 ) ;

         select bom_cto_model_orgs_s1.nextval into v_group_reference_id from dual ;



		        insert into bom_cto_model_orgs
				(
                                reference_id,
                                group_reference_id,
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
                                bom_cto_model_orgs_s1.nextval,
                                v_group_reference_id,
				p_model_item_id ,
				null ,
				msi.organization_id,
				decode( bp.create_config_bom , 'Y',
                                        decode(bom.assembly_item_id, msi.inventory_item_id, 'Y', 'N')
                                        , 'N') ,  -- create_bom
				decode(bp.organization_id , null , 'N' , 'Y') ,		-- cost_rollup
				decode( msi.planning_make_buy_code, 2, 3 , 2 ) ,  -- org_type should be 3(buy) for buy items else 2(make)
				NULL,		-- config_item_id
				'N',
				NULL , /* rank */
				sysdate,	-- creation_date
				gUserId,	-- created_by
				sysdate,	-- last_update_date
				gUserId,	-- last_updated_by
				gLoginId,	-- last_update_login
				null, 		-- program_application_id,??
				null, 		-- program_id,??
				sysdate		-- program_update_date
		        from mtl_system_items msi, bom_bill_of_materials bom, bom_parameters bp
                        where msi.inventory_item_id = p_model_item_id
                          and msi.inventory_item_id = bom.assembly_item_id(+)
                          and msi.organization_id  = bom.organization_id(+)
                          and bom.alternate_bom_designator is null
                          and msi.organization_id = bp.organization_id (+) /* added for bug 3504744 */;
                       /*
                        and  NOT EXISTS
                             (select NULL
                               from bom_cto_model_orgs bcmo
                              where bcmo.model_item_id = msi.inventory_item_id
                                and bcmo.organization_id = msi.organization_id );
                      */



         oe_debug_pub.add( '$$$ insert type3 bcmo bcmo ' || SQL%rowcount  , 1 ) ;

		        insert into bom_cto_src_orgs_b
				(
				top_model_line_id,
				line_id,
                                group_reference_id,
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
				p_top_ato_line_id ,
				p_model_line_id ,
                                v_group_reference_id,
				p_model_item_id ,
				null ,
				-1,             -- organization_id is -1 for type 3 matched
				null,		-- create_bom
				'Y',		-- cost_rollup
				NULL ,	-- org_type is used to store the source type
				NULL,		-- config_item_id
				NULL,
				NULL , /* rank */
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
                               from bom_cto_src_orgs_b
                              where line_id = p_model_line_id );



         oe_debug_pub.add( '$$$ insert type3 bcmo bcso ' || SQL%rowcount  , 1 ) ;




end insert_type3_bcmo_bcso ;






procedure insert_type3_referenced_bcso( p_top_ato_line_id       in NUMBER
                    , p_model_line_id in NUMBER
                    , p_model_item_id in NUMBER
                    , p_config_item_id in NUMBER default null )
is
v_group_reference_id   number(10);
lCnt number;  --debug 10240482
begin

         oe_debug_pub.add( '$$$ insert type3 referenced bcso ' , 1 ) ;

	 --debug 10240482
	 oe_debug_pub.add( '$$$ insert type3 referenced bcso: p_top_ato_line_id:' || p_top_ato_line_id) ;
	 oe_debug_pub.add( '$$$ insert type3 referenced bcso: p_model_line_id:' || p_model_line_id) ;
	 oe_debug_pub.add( '$$$ insert type3 referenced bcso: p_model_item_id:' || p_model_item_id) ;
	 oe_debug_pub.add( '$$$ insert type3 referenced bcso: p_config_item_id:' || p_config_item_id) ;
	 --debug end

         begin
         select group_reference_id into v_group_reference_id from bom_cto_model_orgs
           where config_item_id = p_config_item_id and rownum = 1 ;  /* all records have the same group reference id */


         exception
         when no_data_found then

         oe_debug_pub.add( '$$$ short circuit for type3 referenced bcso ' , 1 ) ;
                       select bom_cto_model_orgs_s1.nextval into v_group_reference_id from dual ;



                        insert into bom_cto_model_orgs
                                (
                                reference_id,
                                group_reference_id,
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
                                bom_cto_model_orgs_s1.nextval,
                                v_group_reference_id,
                                p_model_item_id ,
                                null ,
                                msi.organization_id,
                                decode( bp.create_config_bom , 'Y',
                                        decode(bom.assembly_item_id, msi.inventory_item_id, 'Y', 'N')
                                        , 'N') ,  -- create_bom
				decode(bp.organization_id , null , 'N' , 'Y') ,		-- cost_rollup
                                decode( msi.planning_make_buy_code, 2, 3 , 2 ) ,  -- org_type should be 3(buy) for buy items else 2(make)
                                p_config_item_id,     -- config_item_id
                                'N',
                                NULL , /* rank */
                                sysdate,        -- creation_date
                                gUserId,        -- created_by
                                sysdate,        -- last_update_date
                                gUserId,        -- last_updated_by
                                gLoginId,       -- last_update_login
                                null,           -- program_application_id,??
                                null,           -- program_id,??
                                sysdate         -- program_update_date
                        from mtl_system_items msi, bom_bill_of_materials bom, bom_parameters bp
                        where msi.inventory_item_id = p_model_item_id
                          and msi.inventory_item_id = bom.assembly_item_id(+)
                          and msi.organization_id  = bom.organization_id(+)
                          and bom.alternate_bom_designator is null
                          and msi.organization_id = bp.organization_id (+) /* added for bug 3504744 */;

		       --debug 10240482
		       lCnt := sql%rowcount;
		       oe_debug_pub.add('$$$ insert type3 referenced bcso: Rows in bcmo:' || lCnt  , 1 ) ;



         when others then


                 null ;
                 raise ;

         end ;


		        insert into bom_cto_src_orgs_b
				(
				top_model_line_id,
				line_id,
                                group_reference_id,
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
				p_top_ato_line_id ,
				p_model_line_id ,
                                v_group_reference_id,
				p_model_item_id ,
				null ,
				-1,             -- organization_id is -1 for type3 matched
				null,		-- create_bom
				'Y',		-- cost_rollup   /* TYPE3 rollup can be avoided for matched items */
				NULL ,	-- org_type is used to store the source type
				p_config_item_id,		-- config_item_id
				NULL,
				NULL , /* rank */
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
                               from bom_cto_src_orgs_b
                              where line_id = p_model_line_id );

         --debug 10240482
         lCnt := sql%rowcount;
	 oe_debug_pub.add('$$$ insert type3 referenced bcso: Rows in bcso:' || lCnt  , 1 ) ;
         --oe_debug_pub.add( '$$$ insert type3 referenced bcso ' || SQL%rowcount  , 1 ) ;




end insert_type3_referenced_bcso ;




/**********************************
ASSUMPTIONS:

For each operating unit there shud be ONE OE Validation and
ONE PO validation Org present

Is more than ONE OEV or POV a valid scenario ?
Is it a valid scenario for oper unit having no OEV or POV ?

***********************************/


Procedure get_other_orgs (
	pModelLineId	IN 	NUMBER,
	p_mode		IN	VARCHAR2 default 'ACC',
	xOrgLst		OUT NOCOPY CTO_MSUTIL_PUB.Org_list,
	x_return_status	OUT NOCOPY VARCHAR2,
	x_msg_count	OUT NOCOPY NUMBER,
	x_msg_data	OUT NOCOPY VARCHAR2
	) IS

lOperUnit		inv_organization_info_v.operating_unit%TYPE;
xModelItemId		bom_cto_src_orgs.model_item_id%TYPE;
l_model_vendors      	PO_AUTOSOURCE_SV.vendor_record_details;
l_doc_header_id		Number;
l_doc_type_code		Varchar2(20);
l_doc_line_num		Number;
l_doc_line_id		Number;
l_vendor_contact_id	Number;
-- 4283726 l_vendor_product_num	Varchar2(50);
l_vendor_product_num po_approved_supplier_list.primary_vendor_item%type;       -- 4283726
l_buyer_id		Number;
-- 4283726 l_purchase_uom		Varchar2(10);
l_purchase_uom       po_asl_attributes.purchasing_unit_of_measure%type;        -- 4283726
l_doc_return		Varchar2(5);
l_ga_flag		po_headers_all.global_Agreement_flag%TYPE;
l_own_org		po_headers_all.org_id%TYPE;
l_chk_own_oper_unit	Varchar2(1) := 'N';    -- 3348635
l_enable_flag		varchar2(1);
l_own_pov_org		Number;
i			Number  := 0;
z			Number;
lstmt_num 		Number;
l_config_creation       Varchar2(1);
l_chk_org		Varchar2(1)	:= 'N';

PG_DEBUG 		Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);

 /* Get all bcso orgs . This is needed determine final xOrgList */
 cursor get_bcso_orgs is
   select  	organization_id  bcso_org_id
   from 	bom_cto_src_orgs
   where 	line_id = pModelLineId;

  xOrgLst_copy     CTO_MSUTIL_PUB.Org_list;
begin

     /* Clear OrgList array if any element exist */


     xOrgLst.DELETE;

     x_return_status := FND_API.G_RET_STS_SUCCESS ;


     IF p_mode = 'UPG' THEN
     	select inventory_item_id,
            nvl(config_creation,1)
     	into   xModelItemId,
     	       l_config_creation
     	from   bom_cto_order_lines_upg
     	where  line_id=pModelLineId;

     ELSE

	select inventory_item_id,
            nvl(config_creation,1)
     	into   xModelItemId,
            l_config_creation
     	from   bom_cto_order_lines
     	where  line_id=pModelLineId;
     END IF;

     if l_config_creation in ('2','3') then

        lstmt_num := 99;

        select organization_id
        BULK COLLECT into xOrgLst
        from mtl_system_items
        where inventory_item_id = xModelItemId
        and   organization_id not  in (
                                      select organization_id
                                      from   bom_cto_src_orgs
                                      where  line_id = pModelLineId);

    else


       lstmt_num := 1;

       -- rkaza. 3742393. 08/12/2004.
       -- Repalcing org_organization_definitions with inv_organization_info_v

       select 	distinct  ou_id
       BULK COLLECT INTO xOrgLst
       from
        ( select  distinct to_number(nvl(oe_sys_parameters.value('MASTER_ORGANIZATION_ID',ood.operating_unit),-99)) ou_id
  	 from  	 inv_organization_info_v  ood,
  	         bom_cto_src_orgs bcso
  	 where 	 ( ood.organization_id = bcso.organization_id
  	          or
                  ood.organization_id = bcso.rcv_org_id
                 )
 	    and   bcso.line_id = pModelLineId
       UNION
       select distinct nvl(inventory_organization_id,-99) ou_id
       from   financials_system_params_all
       where  org_id in
  	 (
	 select  distinct ood.operating_unit
  	 from  	 inv_organization_info_v  ood,
  	         bom_cto_src_orgs bcso
  	 where 	 ( ood.organization_id = bcso.organization_id
  	         or
                   ood.organization_id = bcso.rcv_org_id
                 )
 	    and     bcso.line_id = pModelLineId
 	 )
       UNION /* added for bug 4291847. item should be enabled in validation org of operating unit where the order was entered */
        ( select
           to_number(nvl(oe_sys_parameters.value('MASTER_ORGANIZATION_ID',oel.org_id),-99)) ou_id
          from oe_order_lines_all oel where oel.line_id = pModelLineid )
     );


       -- Printing Orgs
       if xOrgLst.count > 0 then
	 for x1 in xOrgLst.FIRST..xOrgLst.LAST loop

  	   IF PG_DEBUG <> 0 THEN
       		oe_debug_pub.add ('get_other_orgs:'||'OE and PO Validation Orgs ('||x1||') = '||xOrglst(x1),5);
  	   END IF;

	 end loop;
       end if;

       -- Getting current number of elements in xOrgLst

       i :=  xOrgLst.COUNT;


       begin
       select 'Y' into l_chk_org
       from   dual
       where  EXISTS (
       	  	select 	1
       		from 	bom_cto_src_orgs
       		where 	line_id = pModelLineId
       		and   	organization_type in (3,5));



       exception
       when no_data_found then
            l_chk_org := 'N' ;

       when others then
             raise ;


       end ;



       if  l_chk_org = 'Y' then			/* Only execute if any procuring org in bcso */


        lstmt_num  := 2;

        /* Get all ASL */

        PO_AUTOSOURCE_SV.get_all_item_asl(
                        x_item_id               => xModelItemId,
                        X_using_organization_id => -1,
                        x_vendor_details        => l_model_vendors,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data);




        /* For each ASL get global blanket agreements */

        lstmt_num  := 3;

	z := l_model_vendors.first;

       while ( z is not null ) loop

         IF PG_DEBUG <> 0 THEN
       		oe_debug_pub.add ('get_other_orgs:'||'Vendor ID '||l_model_vendors(z).vendor_id,5);
       		oe_debug_pub.add ('get_other_orgs:'||'Vendor Site ID '||l_model_vendors(z).vendor_site_id,5);
       		oe_debug_pub.add ('get_other_orgs:'||'ASL ID '||l_model_vendors(z).asl_id,5);

 	 END IF;

	 PO_AUTOSOURCE_SV.blanket_document_sourcing(
                                x_item_id              => xModelItemId,
                                x_vendor_id            => l_model_vendors(z).vendor_id,
                                x_vendor_site_id       => l_model_vendors(z).vendor_site_id,
                                x_asl_id               => l_model_vendors(z).asl_id,
                                x_destination_doc_type => null,
                                x_organization_id     => -1,
                                x_currency_code        => null,
                                x_item_rev             => null,
                                x_autosource_date      => null,
                                x_document_header_id   => l_doc_header_id,
                                x_document_type_code   => l_doc_type_code,
                                x_document_line_num    => l_doc_line_num,
                                x_document_line_id     => l_doc_line_id,
                                x_vendor_contact_id    => l_vendor_contact_id,
                                x_vendor_product_num   => l_vendor_product_num,
                                x_buyer_id             => l_buyer_id,
                                x_purchasing_uom       => l_purchase_uom,
                                x_multi_org            => 'Y',
                                x_doc_return           => l_doc_return,
                                x_return_status        => x_return_status,
                                x_msg_count            => x_msg_count,
                                x_msg_data             => x_msg_data);

	  IF PG_DEBUG <> 0 THEN

       		oe_debug_pub.add ('get_other_orgs:'||'Doc Header ID '||l_doc_header_id,5);

 	  END IF;

 	  if l_doc_return  = 'Y' then

              IF PG_DEBUG <> 0 THEN
                  oe_debug_pub.add('get_other_orgs:'|| 'Valid Blanket found for config ..',5);
              END IF;

          else
              IF PG_DEBUG <> 0 THEN
                  oe_debug_pub.add('get_other_orgs:' || 'Valid Blanket not found for this config',5);
              END IF;

              exit;

          end if;


       /* Chk if blanket global and get owning OU */

       lstmt_num  := 4;

       select global_agreement_flag,org_id
       into 	l_ga_flag,l_own_org
       from 	po_headers_all
       where po_header_id = l_doc_header_id ;




       -- bugfix 3348635
       IF PG_DEBUG <> 0 THEN
         oe_debug_pub.add('get_other_orgs:' || 'Ga Flag: '||l_ga_flag||' :: Owning Org: '||l_own_org ,5);
       END IF;



       /* If any global blanket , check if owning OU is enabled and in bcso with org_type in 3,5 */

       lstmt_num  := 5;

       if l_ga_flag = 'Y' then

       begin
         -- rkaza. 3742393. 08/12/2004.
         -- Repalcing org_organization_definitions with inv_organization_info_v
         select 'Y' into l_chk_own_oper_unit
         from dual
         where EXISTS (
	  select po_header_id
	  from   po_ga_org_assignments
	  where  enabled_flag = 'Y'
	  and    organization_id in (
                  select odd.operating_unit
                  from   inv_organization_info_v odd,
                         bom_cto_src_orgs bcso
                  where bcso.line_id = pModelLineId
                  and   bcso.organization_type in (3,5)
                  and   odd.organization_id = bcso.organization_id));


      exception
      	 WHEN NO_DATA_FOUND then
         l_chk_own_oper_unit := 'N';
      end;



      -- bugfix 3348635
      IF PG_DEBUG <> 0 THEN
         oe_debug_pub.add('get_other_orgs:' || 'Owning Op Unit: '||l_chk_own_oper_unit,5);
      END IF;




      /* Get PO Validation org for owning OU's which are enabled */

      lstmt_num  := 6;

       if l_chk_own_oper_unit = 'Y'	then
	  select inventory_organization_id
	  into   l_own_pov_org
   	  from   financials_system_params_all
   	  where  org_id = l_own_org;
       end if;						/* lchk_own_oper_unit = Y */

    end if;						/* l_ga_flag = 'Y' */



     -- bugfix 3348635
     IF PG_DEBUG <> 0 THEN
         oe_debug_pub.add('get_other_orgs:' || 'Owning POV Org: '||l_own_pov_org,5);
      END IF;



    -- insert PO Validation Org in the list

    lstmt_num  := 7;

    if l_own_pov_org is NOT NULL then           -- bugfix 3348635
        xOrglst(i + 1) := l_own_pov_org;
	i := i + 1; --	3785158

    end if;


    -- increment i



    z := l_model_vendors.next(z); --bugfix 3348635 ,	3785158

  end loop;

    -- setting i to 0

    i := 0;

    -- Printing Orgs
    if xOrgLst.count > 0 then
	for x2 in xOrgLst.FIRST..xOrgLst.LAST loop

 	   IF PG_DEBUG <> 0 THEN
       		oe_debug_pub.add ('get_other_orgs:'||'Validation Orgs ('||x2||') = '||xOrglst(x2),5);
 	   END IF;

	end loop;

    end if;

  end if ; 		-- Procure org chk in bcso



/* From final list , remove all orgs which are in bcso */

  lstmt_num  := 8;

  for rget_bcso_orgs in get_bcso_orgs loop

   if xOrgLst.count > 0 then

    for x4 in xOrglst.FIRST..xOrglst.LAST  loop


     if xOrgLst.exists(x4) then
        if xOrgLst(x4) = rget_bcso_orgs.bcso_org_id then

           IF PG_DEBUG <> 0 THEN
     	      oe_debug_pub.add ('get_other_orgs:'||'Deleting Org ('||x4||') = '||xOrglst(x4),5);
           END IF;

           xOrgLst.delete(x4);


        end if;
     end if;

    end loop;					/* End loop xOrgLst */

   end if;

  end loop;					/* End loop bcso orgs */


  /*
     The copy loop has been placed outside the above loop as each org may be copied more than once.
     Also, Orgs that could be subsequently deleted may get copied during earlier iterations.
  */

  if( xOrgLst.count > 0 ) then
      for x6 in xOrgLst.First..xOrgLst.Last loop

          if xOrgLst.exists(x6) then
     	     oe_debug_pub.add ('get_other_orgs:'||'Copied Org ('||x6||') = '||xOrglst(x6),5);
             xOrgLst_copy(xOrgLst_copy.count + 1) := xOrgLst(x6) ;

          end if;

      end loop ;


      xOrgLst := xOrgLst_copy ;  /* Assign Copied List to Original List */

  end if;


  End if;  /* CIB Attribute check */




  -- Printing Final List of Orgs

  if xOrgLst.count > 0 then

  	for x5 in xOrgLst.FIRST..xOrgLst.LAST loop

          if xOrgLst.exists(x5) then


   	   IF PG_DEBUG <> 0 THEN
       		oe_debug_pub.add ('get_other_orgs:'||'Final Org List ('||x5||') = '||xOrglst(x5),5);
   	   END IF;



          end if;

 	end loop;

   end if;


  exception /* added exception handling for expected and unexpected error as part of bug 4227127 (fp for bug 4162642) */
        when FND_API.G_EXC_UNEXPECTED_ERROR then
                IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('get_other_orgs: ' || 'GET_OTHER_ORGS::unexp error::'|| to_char(lstmt_num) ||sqlerrm,1);
                END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data
                        );

        when FND_API.G_EXC_ERROR then
                IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('get_other_orgs: ' || 'GET_OTHER_ORGS::exp error::'|| to_char(lstmt_num) ||sqlerrm,1);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data);


  	 WHEN OTHERS THEN
  	    IF PG_DEBUG <> 0 THEN
  	       oe_debug_pub.add('get_other_orgs: ' || 'GET_OTHER_ORGS::unexp error:: '||to_char(lstmt_num)||'::'||sqlerrm,5);
	    END IF;

	   /*  commented raise as the calling api will handle the error using x_return_status RAISE FND_API.G_EXC_UNEXPECTED_ERROR; */

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	    CTO_MSG_PUB.Count_And_Get(p_msg_count => x_msg_count ,p_msg_data  => x_msg_data);


  END get_other_orgs;




procedure procured_model_bcso_override ( p_line_id  in number
                             , p_model_item_id  in number
                             , p_ship_org_id  in number )
is
v_procured_models_exist varchar2(1) := 'N' ;
v_bom_created           varchar2(1) := 'N' ;
v_ship_org_bom_update   number ;
lStmtNumber             number ;


v_receiving_org   number ;
begin
                begin

                             select 'Y' into v_procured_models_exist from dual
                             where exists
                                   ( select * from bom_cto_src_orgs_b
                                      where line_id = p_line_id
                                        and model_item_id = p_model_item_id
                                        and nvl(organization_type , 2 ) in( '3' , '4' )  );


                             oe_debug_pub.add( ' atleast one procured/dropship model/child model exist  '  , 1);


                exception
                        when others then
                             oe_debug_pub.add( ' No procured/dropship model/child model exist  '  , 1);
                            null ;
                end ;



                if( v_procured_models_exist = 'Y' ) then
                    begin

                             v_bom_created := 'N' ;

                             select 'Y' into v_bom_created from dual
                             where exists
                                   ( select * from bom_cto_src_orgs_b where line_id = p_line_id
                                        and model_item_id = p_model_item_id
                                        and create_bom = 'Y'  );


                             oe_debug_pub.add( ' atleast one org has  bom flag = Y '  , 1);


                    exception
                    when others then
                                null ;
                    end ;



                    if( v_bom_created = 'N' ) then









                        begin
                            select organization_id into v_receiving_org
                              from bom_cto_src_orgs
                             where line_id = p_line_id and organization_id = rcv_org_id
                               and organization_type in (  '3'  , '4' ) and   rownum = 1 ;

                            oe_debug_pub.add( ' Org to be Updated '  || to_char(v_receiving_org) , 1);

                        exception
                        when others then
                            null ;
                            oe_debug_pub.add( ' Got Error '  || SQLERRM  , 1);
                            v_receiving_org := p_ship_org_id ;
                            oe_debug_pub.add( ' Assigning Ship Org as  Org to be Updated '  || to_char(v_receiving_org) , 1);
                        end ;



                        oe_debug_pub.add( ' need to create bom in atleast one receiving org as bom flag = Y
                                                 does not exist for any  org '  , 1);

                        lStmtNumber := 140;
                        update bom_cto_src_orgs_b
                                set create_bom = 'Y' /* , organization_type = l_source_type */
                              where line_id = p_line_id
                                and model_item_id = p_model_item_id
                                and organization_id = v_receiving_org
                                and rcv_org_id = v_receiving_org
                                and exists
                                    ( select * from bom_parameters bp, bom_bill_of_materials bbom
                                       where bp.organization_id = v_receiving_org
                                         and bbom.organization_id = bp.organization_id
                                         and bbom.assembly_item_id = p_model_item_id
                                         and bp.create_config_bom = 'Y' ) ;


                        oe_debug_pub.add( ' updated for org ' || v_receiving_org || ' rcv org ' || v_receiving_org ) ;
                        oe_debug_pub.add( ' Records updated ' || SQL%ROWCOUNT ) ;


                        v_ship_org_bom_update := SQL%ROWCOUNT ;






                       if( v_ship_org_bom_update = 0 ) then




                             oe_debug_pub.add( ' need to create bom in any org as shipping org does not have model bom or bom param'  , 1);

                             lStmtNumber := 140;
                             update bom_cto_src_orgs_b
                                set create_bom = 'Y' /* , organization_type = l_source_type */
                              where line_id = p_line_id
                                and model_item_id = p_model_item_id
                                and rcv_org_id in (
                                     select bp.organization_id
                                       from bom_parameters bp, bom_bill_of_materials bbom
                                       where bbom.organization_id = bp.organization_id
                                         and bbom.assembly_item_id = p_model_item_id
                                         and bp.create_config_bom = 'Y' )
                                and rownum = 1 ;


                             oe_debug_pub.add( ' updated in any shipping org Records updated ' || SQL%ROWCOUNT ) ;


                       end if ; /* shipping_org no bom */


                    end if; /* bom_created = 'N' */

                end if ; /* procured_models */




end procured_model_bcso_override ;

--- Added by Renga Kannan on 15-Sep-2005
--- Added for R12 ATG Performance Project


/*--------------------------------------------------------------------------+
This procedure will get the model line id as input to give the list of
master orgs where the item needs to be enabled.
This will look the bcso tables to identify the list of orgs where the config
item needs to be enabled due to sourcing and derive the master orgs for these organization
and return them in pl/sql record struct.
+-------------------------------------------------------------------------*/

PROCEDURE Get_Master_Orgs(
			  p_model_line_id       IN  Number,
			  x_orgs_list           OUT NOCOPY CTO_MSUTIL_PUB.org_list,
			  x_msg_count           OUT NOCOPY Number,
			  x_msg_data            OUT NOCOPY varchar2,
			  x_return_status       OUT NOCOPY varchar2) is
LSTMT_NUM      Number :=10;
i              Number;
Begin

   If PG_DEBUG <> 0 Then
      oe_debug_pub.add('Get_Master_orgs: Entering Get_Master_orgs API for Model Line id = '||p_model_line_id,3);
   End if;

   Begin
      Select distinct mp1.master_organization_id
      Bulk Collect into
      x_orgs_list
      from   mtl_parameters mp1,
          bom_cto_src_orgs bcso
     where  bcso.line_id = p_model_line_id
     and    bcso.organization_id  = mp1.organization_id
     and    mp1.master_organization_id not in
	  ( Select organization_id
	    from   bom_cto_src_orgs
     where  line_id = p_model_line_id);

     If PG_DEBUG <> 0 Then
        i := x_orgs_list.first;
	while (i is not null)
	Loop
           oe_debug_pub.add('Get_Master_Orgs: Master Org = '||x_orgs_list(i),5);
           i := x_orgs_list.next(i);
	End Loop;
        If i is null Then
           oe_debug_pub.add('Get_Master_Orgs: No master orgs insterted..',5);
        End if;
     End if;
   Exception when no_data_found then
     If PG_DEBUG <> 0 Then
        oe_debug_pub.add('Get_Master_Orgs: No new Masters orgs are added.... ',1);
     End if;
   End;

x_return_status := FND_API.G_RET_STS_SUCCESS;

Exception /* added exception handling for expected and unexpected error as part of bug 4227127 (fp for bug 4162642) */
        when FND_API.G_EXC_UNEXPECTED_ERROR then
                IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('Get_Master_orgs: ' || 'GET_OTHER_ORGS::unexp error::'|| to_char(lstmt_num) ||sqlerrm,1);
                END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data
                        );

        when FND_API.G_EXC_ERROR then
                IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('Get_Master_orgs: ' || 'GET_OTHER_ORGS::exp error::'|| to_char(lstmt_num) ||sqlerrm,1);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data);


  	 WHEN OTHERS THEN
  	    IF PG_DEBUG <> 0 THEN
  	       oe_debug_pub.add('get_other_orgs: ' || 'Get_Master_Orgs::unexp error:: '||to_char(lstmt_num)||'::'||sqlerrm,5);
	    END IF;

	   /*  commented raise as the calling api will handle the error using x_return_status RAISE FND_API.G_EXC_UNEXPECTED_ERROR; */

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	    CTO_MSG_PUB.Count_And_Get(p_msg_count => x_msg_count ,p_msg_data  => x_msg_data);

End Get_Master_orgs;



-- rkaza. 11/08/2005. bom sturcture import enhancements. bug 4524248.
Procedure set_bom_batch_id(x_return_status	OUT	NOCOPY varchar2) IS

Begin

x_return_status := FND_API.G_RET_STS_SUCCESS;

bom_batch_id := Bom_Import_Pub.Get_BatchId;

if bom_batch_id = 0 then
   oe_debug_pub.add('Get_bom_batch_id: batch_id is 0', 1);
   raise FND_API.G_EXC_UNEXPECTED_ERROR;
end if;

IF PG_DEBUG <> 0 THEN
   oe_debug_pub.add('Get_bom_batch_id: Batch_id = ' || bom_batch_id, 1);
END IF;

Exception

When FND_API.G_EXC_UNEXPECTED_ERROR then
IF PG_DEBUG <> 0 THEN
   oe_debug_pub.add('Get_bom_batch_id: unexpected error: ' || sqlerrm, 1);
END IF;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

When others then
IF PG_DEBUG <> 0 THEN
   oe_debug_pub.add('Get_bom_batch_id: unexpected error: ' || sqlerrm, 1);
END IF;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

End set_bom_batch_id;


-- Added by Renga Kannan 03/30/06
-- This is a wrapper API to call PLM team's to sync up item media index
-- With out this sync up the item cannot be searched in Simple item search page
-- This is fixed for bug 4656048

Procedure Syncup_Item_Media_index is
Begin
   -- Calling PLM API to sync up item media index
   EGO_ITEM_PUB.SYNC_IM_INDEX ;
Exception When others then
   raise fnd_api.g_exc_unexpected_error;
End Syncup_item_media_index;



-- Added by Renga Kannan on 04/28/06
-- Utility API to Switch CONTEXT TO ORDER LINE CONTEXT
-- For Bug Fix 5122923

Procedure Switch_to_oe_Context(
                         p_oe_org_id    IN               Number,
			 x_current_mode  OUT NOCOPY       Varchar2,
			 x_current_org   OUT NOCOPY       Number,
			 x_context_switch_flag OUT NOCOPY Varchar2) is
Begin
   x_context_switch_flag := 'N';
   x_current_mode  := nvl(MO_GLOBAL.get_access_mode,'N');
   x_current_org   := nvl(MO_GLOBAL.get_current_org_id,-99);

   If PG_DEBUG <> 0 Then
     oe_debug_pub.add('Switch_to_oe_Context : Order Line Org Id  = '||to_char(p_oe_org_id),5);
     oe_debug_pub.add('Switch_to_oe_Context : Current Mode       = '||x_current_mode,5);
     oe_debug_pub.add('Switch_to_oe_Context : Current Org        = '||to_char(x_current_org),5);
     cto_wip_workflow_api_pk.cto_debug('Switch_to_oe_Context','Change_status_batch: Order Line Org Id ='||to_char(p_oe_org_id));
     cto_wip_workflow_api_pk.cto_debug('Switch_to_oe_Context','Change_Status_batch: Current Mode = '||x_current_mode);
     cto_wip_workflow_api_pk.cto_debug('Switch_to_oe_Context','Change_status_batch: Current org = '||to_char(x_current_org));
   end if;

   If x_current_mode = 'N' or x_current_mode = 'M' or(x_current_mode = 'S' and p_oe_org_id <> x_current_org)
      or x_current_mode = 'A' --5446723
      Then
     If x_current_mode <> 'N' then
        x_context_switch_flag := 'Y';
     End if;
     If PG_DEBUG <> 0 Then
        oe_debug_pub.add('Switch_to_oe_Context : Changing the operating unit context to Order Line context',5);
     End if;
     MO_GLOBAL.set_policy_context(p_access_mode => 'S',
                                  p_org_id      => p_oe_org_id);

   Else--5446723
     If PG_DEBUG <> 0 Then
        oe_debug_pub.add('Switch_to_oe_Context : UN-EXPECTED MOAC MODE',5);
     End if;
   End if;

   If PG_DEBUG <> 0 Then
      oe_debug_pub.add('SWITCH_TO_OE_CONTEXT : Done with Chaning the context to OE ',5);
      cto_wip_workflow_api_pk.cto_Debug('Switch_to_oe_Context:', 'Done with Chaning the context to OE');
   End if;
End Switch_to_oe_context;

-- Added by Renga Kannan on 04/28/06
-- For bug fix 5122923

Procedure Switch_context_back(
                              p_old_mode  IN  Varchar2,
			      p_old_org   IN  varchar2) is
Begin

     If p_old_mode = 'S' then
        MO_GLOBAL.set_policy_context(p_access_mode => 'S',
	                             p_org_id      => p_old_org);
     elsif p_old_mode = 'M' then
        MO_GLOBAL.set_policy_context(p_access_mode => 'M',
	                             p_org_id      => null);
     elsif p_old_mode = 'A' then --5446723
        MO_GLOBAL.set_policy_context(p_access_mode => 'A',
	                             p_org_id      => null);

     end if; /* l_old_mode = 'S' */

     If PG_DEBUG <> 0 Then
      oe_debug_pub.add('Switch_context_back : Done with Chaning the context BAck',5);
      cto_wip_workflow_api_pk.cto_Debug('Switch_to_oe_Context:', 'Done with Chaning the context Back');
    End if;

End Switch_context_back;

--Start Bugfix 8305535
--This is a wrapper API to raise event for every config item created.
Procedure Raise_event_for_seibel
IS
   sql_stmt        varchar2(5000);
   i               number;
   l_config_exists number;
   l_org           number;

   CURSOR config_orgs(pConfigId number) IS
      select organization_id
      from mtl_system_items_b
      where inventory_item_id = pConfigId;

BEGIN
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('Inside Raise_event_for_seibel',2);
      oe_debug_pub.add('Count of configs:: '|| CTO_MSUTIL_PUB.cfg_tbl_var.count,2);
   END IF;

   for i in 1..CTO_MSUTIL_PUB.cfg_tbl_var.count loop
      for l_org in config_orgs(CTO_MSUTIL_PUB.cfg_tbl_var(i)) loop
         IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add('Config:: ' || CTO_MSUTIL_PUB.cfg_tbl_var(i),2);
            oe_debug_pub.add('Org:: ' || l_org.organization_id,2);
         END IF;

         sql_stmt := 'BEGIN                                                            '||
                     'INV_ITEM_EVENTS_PVT.Raise_Events(                                '||
                     'p_inventory_item_id => :p_inventory_item_id,                     '||
                     'p_organization_id   => :p_organization_id,                       '||
                     'p_event_name    => ''EGO_WF_WRAPPER_PVT.G_ITEM_CREATE_EVENT'',   '||
                     'p_dml_type      => ''CREATE'');                                  '||
                     'END;';


          EXECUTE IMMEDIATE sql_stmt
          using IN CTO_MSUTIL_PUB.cfg_tbl_var(i),
                IN l_org.organization_id;
      end loop;  --loop for l_org
   end loop;

EXCEPTION
   When others then
      IF PG_DEBUG <> 0 THEN
         oe_debug_pub.add(G_PKG_NAME || ' Error: '||sqlerrm,5);
         oe_debug_pub.add('Not an error');
      END IF;

End Raise_event_for_seibel;
--End Bugfix 8305535

END CTO_MSUTIL_PUB ;

/
