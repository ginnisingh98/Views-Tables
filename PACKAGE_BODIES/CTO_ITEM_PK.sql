--------------------------------------------------------
--  DDL for Package Body CTO_ITEM_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_ITEM_PK" as
/* $Header: CTOCCFGB.pls 120.5.12010000.6 2010/03/03 08:12:12 abhissri ship $ */

/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|
| FILE NAME   : CTOCCFGB.pls
| DESCRIPTION : Creates new inventory item for CTO orders. Performs
|               the same functions as BOMLDCIB.pls and INVPRCIB.pls
|               for streamlined CTO supported with new OE architecture.
|
| HISTORY     : Created based on BOMLDCIB.pls  and INVPRCIB.pls
|               Created On : 	09-JUL-1999	Usha Arora
|		Modified   : 	01-JUN-2000	Sajani Sheth
|			     	Added code to support Multilevel/Multi-org CTO functionality
|
|                            	18-JUN-01 	Shashi Bhaskaran
|	 			Bugfix 1835357: Comment out all FND_FILE calls
|				since we are using oe_debug_pub.
|
|              			24-AUG-2001	Sushant Sawant
|				Bugfix 1957336: Added a new functionality for
|				preconfigure bom.
|
|                              09-10-2003          Kiran Konada
|
|			       bugfix  3070429,3124169
|                              propagation bugfix #: 3143556
|
|                              After a call to create item ,  a new call is added to
|                              CTO_ENI_WRAPPER.CTO_CALL_TO_ENI
|
|                              NOTE: CTO_ENI_WRAPPER is maintained in bom Source control and
|                              is owned by ENI team. This is done as part of bugfix 3070429
|
|                              Always the main code contains stubbed version and branch has the
|                              a call to file maintained in ENI product top
|
|                              Branch is always shipped with  ENI
|
|                              The above approach was taken as CTO could not directly make a
|                              call to a ENI file. ENI is present from 11.5.4 onwards and
|                              CTO bugfixes can be shipped to all customers since base release
|                              (11.5.2)
|
|                              The error messages if any from CTO_CALL_TO_ENI  are ignored
|                              decision:Usha Arora,Krishna Bhagvatula,Anuradha subramnian<Kiran Koanda)
|                              As CTO should not error out in its process becuase of failure in inserting
|                              in DBI atbles used for intelligence

|
|
|		Modified   : 	18-FEB-2004	Sushant Sawant
|                                               Fixed Bug 3441482
|                                               Item Creation Code should not continue any further item processing
|                                               for full configuration reuse.
|
|
|		Modified   : 	02-MAR-2004	Sushant Sawant
|                                               Fixed Bug 3472654
|                                               provided check to see whether Config Item is enabled in all organizations
|                                               where the model item is enabled for models with CIB = 3 and match = 'Y'.
|
|
|		Modified   : 	02-APR-2004	Sushant Sawant
|                                               Fixed Bug 3545019
|                                               User created config for type3 model with match off
|                                               changed order qty for option item and recreated config with match on
|                                               This scenario errors out as bom_cto_src_orgs_b should be cleared
|                                               for all partial reuse or no reuse scenarios. Data for type3 configs
|                                               is stored in different formats.
|                                               The fix will always clear bom_cto_src_orgs_b for partial reuse and no
|                                               reuse scenarios to avoid the current issue.
|
|
|		Modified   : 	13-APR-2004	Sushant Sawant
|                                               Fixed Bug 3533192
|                                               Similar configurations under different models should result in same config item
|
|
|                               17-May-2004     Kiran Konada
|                                               inserted ship_from_org-id from BCOL into the
|                                               validation_org col on BCOL_GT
|                                               code has been changed in CTO_REUSE for
|                                               3555026 to look at validation_org, and so
|                                               validation-org cannot be null
|
*============================================================================*/

PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);

/* OSS Items Org list for creating BOM */
g_bom_org_list CTO_OSS_SOURCE_PK.bom_org_list_tab ; /* line_id, inventory_item_id, org_id */

/*
  procedure perform_match(
     p_ato_line_id           in  bom_cto_order_lines.ato_line_id%type ,
     x_match_found           out NOCOPY varchar2,
     x_matching_config_id    out NOCOPY number,
     x_error_message         out NOCOPY VARCHAR2,
     x_message_name          out NOCOPY varchar2
  );
*/



PROCEDURE evaluate_item_behavior( p_ato_line_id  in NUMBER
                                ,x_return_status   out NOCOPY varchar2
                                ,x_msg_count     out NOCOPY number
                                ,x_msg_data   out NOCOPY varchar2     ) ;



FUNCTION Create_And_Link_Item(pTopAtoLineId in number,
			      xReturnStatus  out NOCOPY varchar2,
			      xMsgCount out NOCOPY number,
			      xMsgData  out NOCOPY varchar2,
                              p_mode     in varchar2 default 'AUTOCONFIG' )
RETURN integer
IS

lSegDel			varchar2(3) ;
lCiDel	  		varchar2(3) ;
lConfigSegName		fnd_id_flex_segments.segment_name%type;
lStmtNum       		number ;
lStatus        		varchar2(10) ;
lMatchProfile         	varchar2(10);
lOrgId			number;
xErrorMessage		varchar2(240);
xMessageName		varchar2(240);
xTableName		varchar2(240);
lModelId		number;
lConfigId		number;
lModelLineId		number;
lTopModelLineId		number;


v_bcol_data_exists     varchar2(1) ;
v_config_change        varchar2(1) ;

v_reuse_bcol_count     number ;

cursor c_copy_src_rules IS
        select bcso.rcv_org_id, bcso.organization_id, bcol.config_creation, bcso.create_src_rules
             , bcso.model_item_id , bcso.config_item_id
        from bom_cto_order_lines bcol, bom_cto_src_orgs bcso
        where bcol.ato_line_id = pTopAtoLineId
          and bcol.bom_item_type = '1' and nvl( bcol.wip_supply_type , 1 )  <> '6'
          and bcol.option_specific = 'N'
	  and bcol.perform_match <> 'Y'
	  -- Bugfix 8894392. For matched configs, no OSS processing happens. So the option_specific flag
	  -- value stays as N. Now for such configs, this cursor copied all the model's sourcing
	  -- rules without taking care of OSS.
          and bcol.line_id = bcso.line_id ;     /*Do not copy sourcing assignments for OSS Items*/

        /*
          and bcso.reference_id is null
        UNION
        select bcso.rcv_org_id, bcso.organization_id, bcol.config_creation, bcso.create_src_rules
             , bcso.inventory_item_id, bcso.config_item_id
        from bom_cto_order_lines bcol, bom_cto_src_orgs bcso, bom_cto_model_orgs bcmo
        where bcol.ato_line_id = pTopAtoLineId
          and bcol.bom_item_type = '1' and nvl( bcol.wip_supply_type , 1 )  <> '6'
          and bcol.option_specific = 'N'
          and bcol.line_id = bcso.line_id
          and bcso.reference_id is not null ;
         */


x_match_found                   varchar2(10);
x_top_matched_item_id           number ;
x_error_message                 varchar2(240);
x_message_name                  varchar2(240);

v_source_type_code              oe_order_lines_all.source_type_code%type ;

x_return_status  varchar2(10) ;
x_msg_count      number ;
x_msg_data       varchar2(2000) ;

v_reuse_config_item_id  number ;
v_reuse_config_flag     varchar2(30) ;
v_reuse_config_creation     varchar2(30) ;

v_bcol_ship_from_org_id number ;
v_bcolgt_ship_from_org_id number ;
v_bcso_data_exists  varchar2(1) := 'N'; -- bug fix 5435745
l_oss_check_reqd number := 0;   --Bugfix 7716203
lReuseProfile number;  --Bugfix 6642016

              cursor c_debug is
      select line_id,
             inventory_item_id,
             ship_from_org_id,
             perform_match,
             config_item_id,
             config_creation, plan_level , link_to_line_id
      from bom_cto_order_lines
      where top_model_line_id = pTopAtoLineId;


BEGIN

	xReturnStatus := FND_API.G_RET_STS_SUCCESS;


        v_bcol_data_exists := 'N' ;


        if( p_mode = 'AUTOCONFIG' ) then


              delete /*+ INDEX (BOM_CTO_ORDER_LINES_GT BOM_CTO_ORDER_LINES_GT_N1) */
              from bom_cto_order_lines_gt where ato_line_id = pTopAtoLineId ;

              oe_debug_pub.add( ' Deleted from bom_cto_order_lines_gt  ' || SQL%ROWCOUNT , 1 ) ;


            begin

                select 'Y' into v_bcol_data_exists
                  from dual
                 where exists ( select line_id from bom_cto_order_lines
                           where line_id = pTopAtoLineId ) ;



            exception
            when others then

                 v_bcol_data_exists := 'N' ;

            end ;


        end if;





  	--
  	-- populate bom_cto_order_lines
  	-- populating bcol using ato_line_id instead of top_model_line_id
	-- change to support multiple ATO models under a PTO model
	--

	lStmtNum := 5;
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_And_Link_Item: ' || 'pTopAtoLineId::'||to_char(pTopAtoLineId), 2);
	END IF;





            if( p_mode = 'AUTOCONFIG' ) then


                -- delete from bom_cto_order_lines where ato_line_id = pTopAtoLineId ;

	        IF PG_DEBUG <> 0 THEN
	           oe_debug_pub.add('Create_And_Link_Item: ' || ' deleted ' || SQL%ROWCOUNT ||
                   ' from bcol ' || to_char(pTopAtoLineId), 2);
	        END IF;

                CTO_UTILITY_PK.Populate_Bcol(
                                     p_bcol_line_id     => pTopAtoLineId,
                                     x_return_status    => XReturnStatus,
                                     x_msg_count        => XMsgCount,
                                     x_msg_data	        => XMsgData,
                                     p_reschedule       => v_bcol_data_exists  ) ;
                 /* p_reschedule parameter should be 'N' for match scenario */



                if XReturnStatus = FND_API.G_RET_STS_ERROR then

                   IF PG_DEBUG <> 0 THEN
                      oe_debug_pub.add ('Create_And_Link_Item: ' ||
                                        'Failed in populate_bcol with expected error.', 1);
                   END IF;

                   raise FND_API.G_EXC_ERROR;

                elsif XReturnStatus = FND_API.G_RET_STS_UNEXP_ERROR then

                   IF PG_DEBUG <> 0 THEN
                      oe_debug_pub.add ('Create_And_Link_Item: ' ||
                                        'Failed in populate_bcol with unexpected error.', 1);
                   END IF;

		   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                end if;

                IF PG_DEBUG <> 0 THEN
                   oe_debug_pub.add('Create_And_Link_Item: ' || 'After Populate_Bcol', 5);
                END IF;



                /* copy bcol data to bcol_temp */



            else /* preconfigured items */



	       lStmtNum := 10 ;


              oe_debug_pub.add( 'came into PRECONFIG UPDATE BCOL QUERY ' , 1 ) ;

                 update bom_cto_order_lines
                    set perform_match = 'Y'
                  where ato_line_id = pTopAtoLineId
                    and inventory_item_id in
                           ( select inventory_item_id
                               from bom_cto_order_lines
                              where ato_line_id = pTopAtoLineId
                                and bom_item_type = '1'
                                and wip_supply_type <> 6
                                and perform_match = 'U'
                              group by inventory_item_id
                             having count(*) > 1
                           );


              oe_debug_pub.add( 'PRECONFIG Similar Instance UPDATE BCOL QUERY count '  || SQL%ROWCOUNT , 1 ) ;



            end if; /* check for autoconfig or preconfig */



            --
            --
            --  Step 2)    Call Reuse for current configuration
            --


                   oe_debug_pub.add('Create_And_Link_Item: ' || 'REUSE Section ', 5);


	       lStmtNum := 20 ;


            if( p_mode = 'AUTOCONFIG' ) then
            if ( v_bcol_data_exists = 'Y' ) then

                lReuseProfile := FND_PROFILE.Value('CTO_REUSE_CONFIG');  --Bugfix 6642016

                IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('Create_And_Link_Item: ' ||
                                        ' Reuse Configuration profile: '  || to_char(lReuseProfile) , 5);
                END IF;  --Bugfix 6642016

                if ( nvl(lReuseProfile,1) = 1 ) then  ----Bugfix 6642016

                   select count(*) into v_reuse_bcol_count from bom_cto_order_lines
                    where ato_line_id = pTopAtoLineId ;


                    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('Create_And_Link_Item: ' ||
                                        ' calling reuse config'  || to_char(v_reuse_bcol_count) , 5);
                    END IF;

                    /* call reuse config api */
                    CTO_MATCH_CONFIG.cto_reuse_configuration(
                                                 p_ato_line_id     => pTopAtoLineId
                                                ,x_config_change   => v_config_change
                                                ,x_return_status   => XReturnStatus
                                                ,x_msg_count       => XMsgCount
                                                ,x_msg_data        => XMsgData);




                    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('Create_And_Link_Item: done reuse. '    , 5);
                    END IF;

                    end if;  --lReuseProfile = 1  Bugfix 6642016


                    /* Bug 3441482 */
                   begin
                    select /*+ INDEX (BOM_CTO_ORDER_LINES_GT BOM_CTO_ORDER_LINES_GT_U1) */
                       bcol.ship_from_org_id , bcolgt.ship_from_org_id
                       into v_bcol_ship_from_org_id, v_bcolgt_ship_from_org_id
                    from   bom_cto_order_lines bcol, bom_cto_order_lines_gt bcolgt
                    where bcol.line_id = bcolgt.line_id and bcol.line_id = pTopAtoLineId ;

                   exception
                    when others then
                     v_bcol_ship_from_org_id := -1 ;
                     v_bcolgt_ship_from_org_id := -1 ;

                   end ;


                    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('Create_And_Link_Item: ' ||
                                                 ' v_bcol_ship_from_org_id : ' || v_bcol_ship_from_org_id     ||
                                                 ' v_bcolgt_ship_from_org_id : ' || v_bcolgt_ship_from_org_id
                                                 , 5);
                    END IF;

			/*Adding the following IF condition for bug 7716203*/
			 if (v_bcol_ship_from_org_id <> v_bcolgt_ship_from_org_id) then
 	                        l_oss_check_reqd := 1;
 	                 end if;

                    /* Bug 3441482 */
                    update /*+ INDEX (BOM_CTO_ORDER_LINES_GT BOM_CTO_ORDER_LINES_GT_N1) */
                          bom_cto_order_lines_gt bcolgt set option_specific  =
                          ( select option_specific from bom_cto_order_lines bcol
                            where bcolgt.line_id = bcol.line_id )
                    where bcolgt.ato_line_id = pTopAtoLineId ;



                    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('Create_And_Link_Item: done oss flag update for reuse. '    , 5);
                    END IF;


                    /* delete from bcol */

                    delete from bom_cto_order_lines where ato_line_id = pTopAtoLineId ;

                    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('Create_And_Link_Item: ' ||
                                        ' deleting from bcol '  || to_char(sql%rowcount) , 5);
                    END IF;

                    lStmtNum := 30 ;

                    /* copy bcol_temp data to bcol */

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
                          ,nvl( option_specific, 'N' )
                          ,QTY_PER_PARENT_MODEL
                          ,CONFIG_CREATION
                      from bom_cto_order_lines_gt
                     where ato_line_id = pTopAtoLineId ;
                     /* add ods and reuse flag */

                IF PG_DEBUG <> 0 THEN
                   oe_debug_pub.add('Create_And_Link_Item: ' || SQL%ROWCOUNT ||
                                    ' copied from bcol_gt to bcol ', 5);
                END IF;



            else


	       lStmtNum := 40 ;

                   oe_debug_pub.add('Create_And_Link_Item: ' || 'copy bcol to bcol_gt ', 5);
                    /* copy bcol data to bcol_temp for matching */

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
			  ,SHIP_FROM_ORG_ID --for bugfix3555026
                      from bom_cto_order_lines
                     where ato_line_id = pTopAtoLineId ;

            oe_debug_pub.add('Create_And_Link_Item: ' || ' copied bcol to bcol gt rows ' || SQL%ROWCOUNT , 5);
            end if ; /* bcol data exists */
            end if ; /* p_mode = AUTOCONFIG */


            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('Create_And_Link_Item: ' ||
                                 ' querying Reuse Flag ' , 2);
            END IF;

	    lStmtNum := 50 ;


            begin
                select reuse_config, config_item_id , config_creation
                 into  v_reuse_config_flag, v_reuse_config_item_id , v_reuse_config_creation
                  from bom_cto_order_lines
                 where line_id = pTopAtoLineId ;

                IF PG_DEBUG <> 0 THEN
                   oe_debug_pub.add('Create_And_Link_Item: ' ||
                                 'Reuse item ' || v_reuse_config_item_id ||
                                 ' Reuse Flag ' || v_reuse_config_flag  ||
                                 ' Config Creation ' || v_reuse_config_creation
                                 , 2);
                END IF;


           Exception
           when others then

                raise ;

           end ;







            if( p_mode = 'AUTOCONFIG' ) then  /* validate_oe_data code to be execute only for auto create config bug 4341156 */


            -- begin bugfix 4044709: New procedure validate_oe_data to validate
            -- 1) BCOL(count) = OE (count ) for specific ato_line_id in question
            -- 2) Line_id's in OE and BCOL matches for specific ato_line_id in question


            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('create_and_link_item: ' || 'going to call validate_oe_data ', 1 );
            END IF;

            CTO_UTILITY_PK.validate_oe_data(p_bcol_line_id  => pTopAtoLineId,
                       x_return_status => xReturnStatus);


            if xReturnStatus <>  FND_API.G_RET_STS_SUCCESS THEN
               oe_debug_pub.add('create_and_link_item: ' || 'Error in OE BCOL Validation',5);
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
            end if;


            -- end bugfix 4044709: New procedure validate_oe_data to validate

            end if; /* This check should be done only for Auto create configurations*/







                        oe_debug_pub.add('create_and_link_item: BCOL DATA ' || ' line_id '   ||
                                                    ' inventory_item_id ' || ' ship_org ' || ' match ' ||
                                                    ' config item ' || ' CIB ' || ' level '   || ' link '  , 1 ) ;
        FOR v_debug IN c_debug LOOP
                IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('create_and_link_item: ' || to_char(v_debug.line_id)||'  '||
                                        to_char(v_debug.inventory_item_id)||'  '||
                                        nvl(to_char(v_debug.ship_from_org_id),null)||'  '||
                                        to_char(v_debug.perform_match)||'  '||
                                        nvl(v_debug.config_item_id, null)||'  '||
                                        nvl(v_debug.config_creation, null) || '  ' ||
                                        nvl(v_debug.plan_level, null) || '  ' ||
                                        nvl(v_debug.link_to_line_id, null)
                                       , 2);
                END IF;
        END LOOP;


           /* NO Item processing required for Reused Configurations */
           /* No processing is required for full reuse of type 3 or full reuse of type 1,2 with no warehouse change */

         /* bug 5435745: Check whether bcso data exists for reuse cases. It will not exists in case
               of split config line. bcso needs to be populated in such cases.
            */

            begin
               select 'Y' into v_bcso_data_exists
               from bom_cto_src_orgs
	       where top_model_line_id = pTopAtoLineId
	       and   rownum = 1; -- Bug Fix 5532777
            exception
            when no_data_found then
                v_bcso_data_exists := 'N';
            end;

                    /* Bug 3441482 */
		    -- bug 5380678: added condn on v_bcso_data_exists

            if ( v_reuse_config_item_id is not null and v_reuse_config_flag = 'Y' and v_bcso_data_exists = 'Y') then

	                    lStmtNum := 1001;
 	                    --Bugfix 7716203: Reuse case. But validating shipping org.
 	                    --In case, the shipping warehouse was changed after delink, there might be a condition
 	                    --where the new warehouse is not part of the OSS setup.
 	                    if (v_reuse_config_creation = 3 and l_oss_check_reqd = 1) then

 	                         lStmtNum := 1002;
 	                         CTO_OSS_SOURCE_PK.PROCESS_OSS_CONFIGURATIONS(  p_ato_line_id     => pTopAtoLineId
 	                                                                       ,x_return_status   => XReturnStatus
 	                                                                       ,x_msg_count       => XMsgCount
 	                                                                       ,x_msg_data        => XMsgData);

 	                         lStmtNum := 1003;
 	                         IF (XReturnStatus = FND_API.G_RET_STS_ERROR) THEN
 	                                 IF PG_DEBUG <> 0 THEN
 	                                         oe_debug_pub.add('Create_And_Link_Item: ' || 'process oss configurations exp error',1);
 	                                 END IF;
 	                                 raise FND_API.G_EXC_ERROR;

 	                         ELSIF (XReturnStatus = FND_API.G_RET_STS_UNEXP_ERROR) THEN
 	                                 IF PG_DEBUG <> 0 THEN
 	                                         oe_debug_pub.add('Create_And_Link_Item: ' || 'process_oss_configurations returned with unexp error',1);
 	                                 END IF;
 	                                 raise FND_API.G_EXC_UNEXPECTED_ERROR;

 	                         END IF;

 	                         IF PG_DEBUG <> 0 THEN
 	                                 oe_debug_pub.add('Create_And_Link_Item: ' || 'After process_oss_configurations ', 2);
 	                         END IF;

 	                    end if;

 	                    lStmtNum := 1004;

                   IF PG_DEBUG <> 0 THEN
                      oe_debug_pub.add('Create_And_Link_Item: ' ||
                                 'Will Not Perform Any Item processing as it is reuse case ', 2);
                   END IF;



            else




                    /* Fix for bug 3545019 and partial reuse scenarios */

                    delete from bom_cto_src_orgs_b where top_model_line_id = pTopAtoLineId ;

                    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('Create_And_Link_Item: ' ||
                                        ' deleted from bcso_b as reuse is not applicable or doesnt exist '
                                         || to_char(sql%rowcount) , 5);
                    END IF;





            --
            --
            --  Step 3)    Call Match for current configuration
            --

            oe_debug_pub.add('Create_And_Link_Item: ' || 'Match section ', 5);


	       lStmtNum := 50 ;

            lMatchProfile := FND_PROFILE.Value('BOM:MATCH_CONFIG');

            oe_debug_pub.add('Create_And_Link_Item: ' || ' Done Match section ', 5);
            oe_debug_pub.add('Create_And_Link_Item: ' || ' Done Match section ' || lMatchProfile , 5);

            if( lMatchProfile = 1 and  p_mode = 'AUTOCONFIG' ) then


                oe_debug_pub.add( 'CREATE_AND_LINK_ITEM ' ||  ' going to call CTO_MATCH_CONFIG perform_match '  , 1 ) ;


                CTO_MATCH_CONFIG.perform_match( pTopAtoLineId ,
                     x_return_status ,
                     x_msg_count,
                     x_msg_data
                    ) ;

                oe_debug_pub.add( 'CREATE_AND_LINK_ITEM '  || ' done perform_match '  , 1 ) ;



	        lStmtNum := 55 ;

                   select /*+ INDEX (BOM_CTO_ORDER_LINES_GT BOM_CTO_ORDER_LINES_GT_U1) */
                     perform_match , config_item_id   into x_match_found , x_top_matched_item_id
                     from bom_cto_order_lines_gt
                    where line_id = pTopAtoLineId ;


                oe_debug_pub.add( 'CREATE_AND_LINK_ITEM:: perform match data  ' ||
                                                          'x_match_found '  || x_match_found  ||
                                                          'x_top_matched_item_id  '  || to_char( x_top_matched_item_id )
                                                           , 1 ) ;


                if( x_match_found = 'Y' ) then
                    oe_debug_pub.add( 'CREATE_AND_LINK_ITEM ' ||  'Top Model Match Success ' , 1 ) ;
                    oe_debug_pub.add( 'CREATE_AND_LINK_ITEM ' ||  'Top Match '|| to_char( x_top_matched_item_id )   , 1 ) ;

                    null ;

                end if ;


            end if ; /* check for match profile */



	    lStmtNum := 60 ;
            oe_debug_pub.add('Create_And_Link_Item: ' || ' Going to Synch up BCOL with data from BCOL_GT for matched info ' , 5);



            update bom_cto_order_lines bcol
                   set ( bcol.perform_match, bcol.config_item_id ) =
                       ( select /*+ INDEX (BOM_CTO_ORDER_LINES_GT BOM_CTO_ORDER_LINES_GT_U1) */
                           bcol_gt.perform_match, bcol_gt.config_item_id
                           from bom_cto_order_lines_gt bcol_gt
                          where bcol.line_id = bcol_gt.line_id )
            where bcol.ato_line_id = pTopAtoLineId ;


           oe_debug_pub.add('Create_And_Link_Item: ' || ' Synch up BCOL with data from BCOL_GT for matched info rows ' || SQL%ROWCOUNT  , 5);


            --
            --
            --  Step 4) Call OSS Processing API to identify OSS Models
            --


	       lStmtNum := 70 ;


                CTO_OSS_SOURCE_PK.PROCESS_OSS_CONFIGURATIONS(  p_ato_line_id => pTopAtoLineId
                                                              ,x_return_status   => XReturnStatus
                                                              ,x_msg_count       => XMsgCount
                                                              ,x_msg_data        => XMsgData);



            IF (XReturnStatus = FND_API.G_RET_STS_ERROR) THEN
                IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('Create_And_Link_Item: ' || 'process oss configurations exp error',1);
                END IF;
                raise FND_API.G_EXC_ERROR;

            ELSIF (XReturnStatus = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('Create_And_Link_Item: ' || 'process_oss_configurations returned with unexp error',1);
                END IF;
                raise FND_API.G_EXC_UNEXPECTED_ERROR;

            END IF;

            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('Create_And_Link_Item: ' || 'After process_oss_configurations ', 2);
            END IF;







            --
            --
            --
            --
            --  Call OSS Processing API to identify OSS Models
            --




            --
            --  Step 5) populate bom_cto_src_orgs
            --

	       lStmtNum := 80 ;




               IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('Create_And_Link_Item: ' || 'Before CTO_MSUTIL_PUB.Populate_Src_Orgs', 2);
               END IF;
            lStatus := CTO_MSUTIL_PUB.Populate_Src_Orgs(
                                        pTopAtoLineId   => pTopAtoLineId,
                                        x_return_status => XReturnStatus,
                                        x_msg_count     => XMsgCount,
                                        x_msg_data      => XMsgData);

            IF (lStatus <> 1) AND (XReturnStatus = FND_API.G_RET_STS_ERROR) THEN
                IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('Create_And_Link_Item: ' || 'Populate_src_orgs returned with exp error',1);
                END IF;
                raise FND_API.G_EXC_ERROR;

            ELSIF (lStatus <> 1) AND (XReturnStatus = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('Create_And_Link_Item: ' || 'Populate_src_orgs returned with unexp error',1);
                END IF;
                raise FND_API.G_EXC_UNEXPECTED_ERROR;

            END IF;

            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('Create_And_Link_Item: ' || 'After Populate_Src_Orgs', 2);
            END IF;






  	--
	-- Check delimiter to ensure it is a length of one
	-- and that it is not the same as the item delimiter value.
	--

	       lStmtNum := 90 ;
	lCiDel := FND_PROFILE.Value('BOM:CONFIG_ITEM_DELIMITER');

	if (lCiDel = ' ') then
		lCiDel := '';
	end if;

    	if (length(lCiDel )<> 1 ) then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add ('Create_And_Link_Item: ' || 'Error: Length of delimiter <> 1', 1);
		END IF;
		cto_msg_pub.cto_message('BOM','CTO_DELIMITER_ERROR');
		raise FND_API.G_EXC_ERROR;
    	end if;
    	IF PG_DEBUG <> 0 THEN
    		oe_debug_pub.add('Create_And_Link_Item: ' ||  'Delimiter is : ' ||  lCiDel,2);
    	END IF;


  	--
	-- Get the item FF delimiter value
	--

	       lStmtNum := 100 ;
	select concatenated_segment_delimiter
    	into   lSegDel
    	from   fnd_id_flex_structures
    	where  application_id = 401
    	and    id_flex_code = 'MSTK'
    	and    id_flex_num = 101;

    	IF PG_DEBUG <> 0 THEN
    		oe_debug_pub.add('Create_And_Link_Item: ' ||  'Items FF segment Separator is  : ' ||  lSegDel,2);
    	END IF;

    	if ( lSegDel = lCiDel ) then
      		IF PG_DEBUG <> 0 THEN
      			oe_debug_pub.add ('Create_And_Link_Item: ' || 'Error : Config Item delimiter = System Items FF segment separator. Not a valid setup.', 1);

      			oe_debug_pub.add ('Create_And_Link_Item: ' || 'Please set a different value for profile BOM:Configuration Item Delimiter.',1);
      		END IF;
		cto_msg_pub.cto_message('BOM','CTO_DELIMITER_ERROR');
		raise FND_API.G_EXC_ERROR;
    	end if;






		-- Perform Match is set to NO

		--
		-- call create_all_items
		--

	       lStmtNum := 110 ;
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Create_And_Link_Item: ' || 'SRS Calling Create_All_Items', 2);
		END IF;

		lStatus := Create_All_Items(
					pTopAtoLineId,
					xReturnStatus,
                                     	XMsgCount,
                                     	XMsgData,
                                        p_mode);
		IF lStatus <> 1 then
     			IF PG_DEBUG <> 0 THEN
     				oe_debug_pub.add ('Create_And_Link_Item: ' || 'Create_All_Items returned with 0', 1);
     			END IF;
			--cto_msg_pub.cto_message('BOM','CTO_CREATE_ITEM_ERROR');
			raise FND_API.G_EXC_ERROR;
  		end if;





     	oe_debug_pub.add ('Create_And_Link_Item: ' || 'calling oss processing ', 1);






        /* Call OSS Rules processing API */


	lStmtNum := 120 ;

        CTO_OSS_SOURCE_PK.create_oss_sourcing_rules( p_ato_line_id => pTopAtoLineId,
                                                     x_return_status => xReturnStatus,
                                                     x_msg_count => XMsgCount,
                                                     x_msg_data => XMsgData ) ;



        --
        -- create sourcing rules if necessary
        --

	       lStmtNum := 130 ;

        FOR v_src_rule IN c_copy_src_rules LOOP
                --
                -- call API to copy sourcing rules from model item
                -- to config item
                --

                lStmtNum:= 110;

                oe_debug_pub.add ('Create_Item: ' || ' c_copy_src_rules LOOP '  || v_src_rule.config_creation , 1 );


                if( v_src_rule.create_src_rules = 'Y' and  v_src_rule.config_creation in ( 1, 2) ) then



                    IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add ('Create_Item: ' || 'Copying src rule for cfg item '
                        ||to_char(v_src_rule.config_item_id)||' in org '||
                        to_char(v_src_rule.organization_id), 2);
                    END IF;


	       lStmtNum := 140 ;

                    CTO_MSUTIL_PUB.Create_Sourcing_Rules(
                                pModelItemId    => v_src_rule.model_item_id,
                                pConfigId       => v_src_rule.config_item_id,
                                pRcvOrgId       => v_src_rule.rcv_org_id,
                                x_return_status => lStatus,
                                x_msg_count     => xMsgCount,
                                x_msg_data      => xMsgData);

                    IF (lStatus = fnd_api.G_RET_STS_ERROR) THEN
                        IF PG_DEBUG <> 0 THEN
                           oe_debug_pub.add ('Create_Item: ' ||
                           'Create_Sourcing_Rules returned with expected error.');
                        END IF;
                        raise FND_API.G_EXC_ERROR;

                    ELSIF (lStatus = fnd_api.G_RET_STS_UNEXP_ERROR) THEN
                        IF PG_DEBUG <> 0 THEN
                           oe_debug_pub.add ('Create_Item: ' ||
                           'Create_Sourcing_Rules returned with unexp error.');
                        END IF;
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;

                    END IF;

                elsif( v_src_rule.config_creation = 3 ) then

                    IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add ('Create_Item: ' || 'Copying src rule for cfg item '
                        ||to_char(v_src_rule.config_item_id)||' in org '||
                        to_char(v_src_rule.organization_id), 2);
                    END IF;

	            lStmtNum := 150 ;

                    CTO_MSUTIL_PUB.Create_TYPE3_Sourcing_Rules(
                                pModelItemId    => v_src_rule.model_item_id,
                                pConfigId       => v_src_rule.config_item_id,
                                pRcvOrgId       => v_src_rule.organization_id,
                                x_return_status => lStatus,
                                x_msg_count     => xMsgCount,
                                x_msg_data      => xMsgData);

                    oe_debug_pub.add ('Create_Item:  type3 sourcing rules done ' , 1) ;

                    IF (lStatus = fnd_api.G_RET_STS_ERROR) THEN
                        IF PG_DEBUG <> 0 THEN
                           oe_debug_pub.add ('Create_Item: ' ||
                           'Create_Sourcing_Rules returned with expected error.');
                        END IF;
                        raise FND_API.G_EXC_ERROR;

                    ELSIF (lStatus = fnd_api.G_RET_STS_UNEXP_ERROR) THEN
                        IF PG_DEBUG <> 0 THEN
                           oe_debug_pub.add ('Create_Item: ' ||
                           'Create_Sourcing_Rules returned with unexp error.');
                        END IF;
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;

                    END IF;




                end if;

                oe_debug_pub.add ('Create_Item:  next iteration ' , 1) ;

        END LOOP;




        end if; /* Check for Reuse Flag */


     	IF PG_DEBUG <> 0 THEN
     		oe_debug_pub.add ('Create_And_Link_Item: ' ||
                                  'Success in Item Creation function', 1);
     	END IF;

  	return(1);

EXCEPTION
	when NO_DATA_FOUND then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Create_And_Link_Item: ' ||  'create_and_link_item::ndf::lStmtNum::'||to_char(lStmtNum)||'::'||sqlerrm, 1);
		END IF;
		cto_msg_pub.count_and_get
          		( p_msg_count => xMsgCount
           		, p_msg_data  => xMsgData
           		);
		xReturnStatus := FND_API.G_RET_STS_UNEXP_ERROR;
		return(0);

	when FND_API.G_EXC_ERROR then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Create_And_Link_Item: ' || 'create_and_link_item::exp error in stmt '||to_char(lStmtNum), 1);
		END IF;
		cto_msg_pub.count_and_get
          		( p_msg_count => xMsgCount
           		, p_msg_data  => xMsgData
           		);
		xReturnStatus := FND_API.G_RET_STS_ERROR;
		return(0);

	when FND_API.G_EXC_UNEXPECTED_ERROR then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Create_And_Link_Item: ' || 'create_and_link_item::unexp error in stmt '||to_char(lStmtNum)||'::'||sqlerrm, 1);
		END IF;
		cto_msg_pub.count_and_get
          		(  p_msg_count => xMsgCount
           		, p_msg_data  => xMsgData
           		);
		xReturnStatus := FND_API.G_RET_STS_UNEXP_ERROR;
		return(0);

	when OTHERS then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Create_And_Link_Item: ' || 'create_and_link_item::others::'||to_char(lStmtNum)||'::'||sqlerrm, 1);
		END IF;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            		FND_MSG_PUB.Add_Exc_Msg
            			('CTO_ITEM_PK'
            			,'create_and_link_item'
            			);
        	END IF;
		cto_msg_pub.count_and_get
          		(  p_msg_count => xMsgCount
           		, p_msg_data  => xMsgData
           		);
		xReturnStatus := FND_API.G_RET_STS_UNEXP_ERROR;
		return(0);

END Create_And_Link_Item;



FUNCTION Create_All_Items(
			pTopAtoLineId in number,
			xReturnStatus  out NOCOPY varchar2,
			xMsgCount out NOCOPY number,
			xMsgData  out NOCOPY varchar2,
                        p_mode  in varchar2 default 'AUTOCONFIG')
RETURN integer
IS

   lStmtNum     	number ;
   lStatus		number;
   xConfigId		number;
   xErrorMessage	varchar2(100);
   xMessageName		varchar2(100);
   xTableName		varchar2(100);

   cursor c_model_lines is
      select line_id,
             inventory_item_id,
             config_item_id,
             parent_ato_line_id,
             config_creation
      from   bom_cto_order_lines
      where  ato_line_id = pTopAtoLineId
      and    ( bom_item_type = '1' )
      and    nvl(wip_supply_type,0) <> '6'
      order by plan_level desc;		-- added order by clause for wt/vol project


     v_line_exists number ;
       lXConfigId       number;
       l_x_error_msg    varchar2(100);
       l_x_msg_name     varchar2(30);
       l_x_table_name     varchar2(30);
       v_perform_match  varchar2(1) ;
       v_parent_ato_line_id number ;
       v_ato_line_id number ;

       lUserId          Number;
       lLoginId          Number;

       v_match_found boolean := false ;

         --start bugfix  3070429,3124169
     l_eni_star_record    CTO_ENI_WRAPPER.STAR_REC_TYPE;
     eni_return_status VARCHAR2(1);
    --end bugfix  3070429,3124169
     v_update_count number ;

     v_bcso_group_reference_id   number ;


     v_bcmo_config_orgs         bom_cto_order_lines.config_creation%type ;

     v_model_item_status number ;
     v_config_item_status number ;
     l_token                      CTO_MSG_PUB.token_tbl;

     v_model_item_name   varchar2(2000) ;
     v_config_item_name   varchar2(2000) ;
     l_lock_status    number;    -- bugfix 4227993
     --
     -- bug 7203643
     -- changed the hash value variable type to varchar2
     -- ntungare
     --
     --l_hash_value     number;    -- bugfix 4227993
     l_hash_value     varchar2(2000);

BEGIN


        oe_debug_pub.add ('Create_All_items: ' || 'Entered ', 1);

	xReturnStatus := FND_API.G_RET_STS_SUCCESS;
        lUserId  := nvl(Fnd_Global.USER_ID, -1) ;
        lLoginId := nvl(Fnd_Global.LOGIN_ID, -1);






        oe_debug_pub.add ('Create_All_items: ' || 'Entered 1 ', 1);







	--
	-- For each identified model line, call create_item to
	-- create config items in all required orgs
	--

     lStmtNum := 30;


     FOR v_model_lines IN c_model_lines
     LOOP

                oe_debug_pub.add ('Create_All_items: ' || 'Entered 2 ', 1);
                v_match_found := FALSE ;



                IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Create_All_Items: ' ||  'loop::'||
                           to_char(v_model_lines.line_id)||'::'||
                           to_char(v_model_lines.inventory_item_id), 2);
                END IF;

		--
		-- create this config item in all required orgs
                --

		xConfigId := v_model_lines.config_item_id;
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Create_All_Items: ' ||
                           'Before calling create_item::config_id is::'||to_char(xConfigId), 2);
                END IF;



                oe_debug_pub.add ('Create_All_items: ' || 'Entered 3' , 1);


                /* check for perform match flag */

                select perform_match
                  into v_perform_match
                  from bom_cto_order_lines
                 where line_id = v_model_lines.line_id;


                oe_debug_pub.add ('Create_All_items: ' || 'perform_match ' || v_perform_match , 1);

                lXConfigId := v_model_lines.config_item_id ;

                if( v_perform_match in (  'Y' , 'C' )  and lXConfigId is null ) then /* Reattempt Match for preconfigured Scenario */

                        /* call check config match API */

                --
    		-- Begin Bugfix 4227993
    		-- Acquire user-lock by calling lock_for_match so that the process does not end up
		-- creating new configs if a non-commited match exists.
		-- Incase lock is not acquired, wait indefinitely. We could error out but we decided
    		-- to wait so that user does not have to resubmit the process again.
    		--
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling cto_utility_pk.lock_for_match: start time: ' ||
       						to_char(sysdate , 'MM/DD/YYYY HH24:MI:SS'));
		CTO_UTILITY_PK.lock_for_match(
					x_return_status	=> xReturnStatus,
        				xMsgCount       => xMsgCount,
        				xMsgData        => xMsgData,
					x_lock_status	=> l_lock_status,
    		                        x_hash_value	=> l_hash_value,
					p_line_id	=> v_model_lines.line_id );

                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling cto_utility_pk.lock_for_match: end time: ' ||
       						to_char(sysdate , 'MM/DD/YYYY HH24:MI:SS'));

		if xReturnStatus <>  FND_API.G_RET_STS_SUCCESS then
   		     oe_debug_pub.add('match_and_create_all_items: '|| 'get_user_lock returned error');
		     raise fnd_api.g_exc_unexpected_error;
		end if;

   		--check for error cases
		if ( l_lock_status  <> 0 ) THEN
      			if (l_lock_status = 1) then -- timeout
   				oe_debug_pub.add('l_lock_status = 1: TIMEOUT ');
      				cto_msg_pub.cto_message('BOM','CTO_LOCK_TIMEOUT');
   				raise fnd_api.g_exc_unexpected_error;

      			elsif (l_lock_status = 2) then -- deadlock
   				oe_debug_pub.add('l_lock_status = 2: DEADLOCK ');
      				cto_msg_pub.cto_message('BOM','CTO_LOCK_DEADLOCK');
   				raise fnd_api.g_exc_unexpected_error;

      			elsif (l_lock_status = 3) then -- parameter error
   				oe_debug_pub.add('l_lock_status = 3: PARAMETER ERROR ');
      				cto_msg_pub.cto_message('BOM','CTO_LOCK_PARAM_ERROR');
   				raise fnd_api.g_exc_unexpected_error;

      			elsif (l_lock_status = 4) then -- already locked.
   				oe_debug_pub.add('l_lock_status = 4: ALREADY LOCKED  ERROR ');
      				cto_msg_pub.cto_message('BOM','CTO_LOCK_ALREADY_LOCKED');
   				-- we shall not raise an error if we are already holding the lock.

      			else -- internal error - not fault of user
   				oe_debug_pub.add('l_lock_status = '||l_lock_status||': INTERNAL ERROR ');
      				cto_msg_pub.cto_message('BOM','CTO_LOCK_ERROR');
   				raise fnd_api.g_exc_unexpected_error;
      			end if;
		else
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('match_and_create_all_items: ' || 'Successfully obtained lock for match.');
			END IF;

		end if;
    		--
    		-- End Bugfix 4227993
    		--



                        if( v_perform_match = 'Y' ) then
                              lStatus := CTO_MATCH_CONFIG.check_config_match(
                                        p_model_line_id   => v_model_lines.line_id,
                                        x_config_match_id => lXConfigId,
                                        x_error_message   => l_x_error_msg,
                                        x_message_name    => l_x_msg_name);

                        else /* custom match */
                             lStatus := CTO_CUSTOM_MATCH_PK.find_matching_config(
                                          pModelLineId          => v_model_lines.line_id,
                                          xMatchedItemId        => lXConfigId,
                                          xErrorMessage         => l_x_error_msg,
                                          xMessageName          => l_x_msg_name,
                                          xTableName            => l_x_table_name);



                        end if ;
                        -- bug 5859780 : need to handle error from match function.
                        if lStatus <> 1 then
                             oe_debug_pub.add('match_and_create_all_items: v_perform_match = '||v_perform_match);
                             oe_debug_pub.add('match_and_create_all_items: '|| 'match returned error: '||l_x_error_msg);
                             raise fnd_api.g_exc_error;
                        end if;
                        -- end bug 5859780



                        if( lXConfigId is not null ) then
                            v_match_found := TRUE ;

	        	    --
                            -- begin bugfix 4227993
                            --
                            CTO_UTILITY_PK.release_lock(
		        	x_return_status	=> xReturnStatus,
        	        	x_Msg_Count     => xMsgCount,
        	        	x_Msg_Data      => xMsgData,
   		        	p_hash_value	=> l_hash_value);

        		    if xReturnStatus <>  FND_API.G_RET_STS_SUCCESS then
        		       oe_debug_pub.add('match_and_create_all_items: '|| 'get_user_lock returned error');
        		       raise fnd_api.g_exc_unexpected_error;
        		    end if;

        		    --
        		    -- end bugfix 4227993
        		    --

                        end if;

                        if (lXConfigId is null) then

                             oe_debug_pub.add ('Create_All_items: ' || 'no match found ' , 1);

                             /* Sushant is Testig Important
                               v_parent_ato_line_id := v_model_lines.parent_ato_line_id ;
                             */

                             v_parent_ato_line_id := v_model_lines.line_id ;


                             /* Set Perform Match = 'N' for current model and its parents */

                             v_update_count := null ; /* this has to be initialized to null for the loop below */

                             WHILE (TRUE)
                             LOOP

                                if (v_parent_ato_line_id = v_ato_line_id  or v_update_count = 0 ) then
                                    exit;
                                end if;

                                update bom_cto_order_lines
                                   set perform_match = 'U' /* Unsuccessful Match */
                                 where line_id = v_parent_ato_line_id
                                   and perform_match = 'Y'
                                 returning parent_ato_line_id , ato_line_id
                                      into v_parent_ato_line_id , v_ato_line_id ;

                                 v_update_count := SQL%rowcount ;

                                 oe_debug_pub.add ('Create_All_items: ' || ' v_parent_ato ' || v_parent_ato_line_id
                                                                        || ' v_ato ' || v_ato_line_id
                                                                        || ' upd count ' || v_update_count , 1);


                             END LOOP ;






                        else /* Match Found */

                            /* update matched config in bcol and bcol_temp */

                            update bom_cto_order_lines
                               set config_item_id = lXConfigId
                             where line_id = v_model_lines.line_id
                             returning config_creation into v_bcmo_config_orgs ;

		                oe_debug_pub.add('Create_All_Items: ' ||
                                   'update bcol count::'||
                                    SQL%ROWCOUNT , 1);

                            oe_debug_pub.add ('Create_All_items: ' || 'updated bcol ' || lXConfigId
                                               || ' for ' || v_model_lines.line_id
                                               || ' config_orgs ' || v_bcmo_config_orgs
                                               || ' rows ' || SQL%ROWCOUNT, 1);


                            update /*+ INDEX (BOM_CTO_ORDER_LINES_GT BOM_CTO_ORDER_LINES_GT_U1) */
                               bom_cto_order_lines_gt
                               set config_item_id = lXConfigId
                             where line_id = v_model_lines.line_id ;

                            oe_debug_pub.add ('Create_All_items: ' || 'updated bcol_gt ' || lXConfigId
                                               || ' for ' || v_model_lines.line_id
                                               || ' rows ' || SQL%ROWCOUNT, 1);


                            if( v_bcmo_config_orgs = '3' ) then

                                select group_reference_id into v_bcso_group_reference_id from bom_cto_src_orgs_b
                                where line_id = v_model_lines.line_id ;



                                update bom_cto_model_orgs
                                set config_item_id = lXConfigId
                                where group_reference_id = v_bcso_group_reference_id ;



                                oe_debug_pub.add ('Create_All_items: matched item ' || 'updated bcmo ' || lXConfigId
                                               || ' line id info  ' || v_model_lines.line_id
                                               || ' for ' || v_bcso_group_reference_id
                                               || ' rows ' || SQL%ROWCOUNT, 1);






                            else
                               update bom_cto_src_orgs_b
                               set config_item_id = lXConfigId
                               where line_id = v_model_lines.line_id ;


                               oe_debug_pub.add ('Create_All_items: ' || 'updated bcso_b ' || lXConfigId
                                               || ' for ' || v_model_lines.line_id
                                               || ' rows ' || SQL%ROWCOUNT, 1);



                            end if;



                        end if;

                end if; /* attempt match code */


                /* create config item for matched and non matched configurations */



                IF( lXConfigId is null or
                   ( lXConfigId is not null and nvl(v_model_lines.config_creation, 1) <> 3 )
                   or
                   ( p_mode = 'PRECONFIG' )
                  ) then

			oe_debug_pub.add('Create_All_Items: Handle Item Creation for Type 1 , 2 , Preconfig or no match/reuse ' , 1 ) ;

                        lStatus := CTO_CONFIG_ITEM_PK.create_item(
	 			pModelId	=> v_model_lines.inventory_item_id,
	 			pLineId	=> v_model_lines.line_id,
         			pConfigId	=> lxConfigId,
				xMsgCount	=> xMsgCount,
				xMsgData	=> xMsgData,
                                p_mode          => p_mode );

		        IF lStatus <> 1 THEN
		           IF PG_DEBUG <> 0 THEN
				  oe_debug_pub.add('Create_All_Items: ' ||
                                   'Create_Item returned 0::item::'||
                                    to_char(v_model_lines.inventory_item_id), 1);
			     END IF;

			     -- cto_msg_pub.cto_message('BOM','CTO_CREATE_ITEM_ERROR');
			     raise FND_API.G_EXC_ERROR;


                        ELSE --if status is success
                             --start bugfix  3070429,3124169

                             l_eni_star_record.inventory_item_id := lxConfigId;

			     IF PG_DEBUG <> 0 THEN
				   oe_debug_pub.add('Create_All_Items: ' || 'conifg item id passed to ENI=>'||
				                   l_eni_star_record.inventory_item_id , 5);
			     END IF;

                             --follwoing API is maintained by PLM,DBI team present in Bom source control


			     CTO_ENI_WRAPPER.CTO_CALL_TO_ENI
			        (p_api_version  => 1.0,
				   p_star_record  => l_eni_star_record,
				   x_return_status =>eni_return_status,
                             x_msg_count	 => xMsgCount,
                             x_msg_data	 => xMsgData);





			     --return status passed as 'S' and not as FND_API.XXXXX
			     --CTO has decided not to fail for error messages but just log messages
			     --refer bug 3124169 for more info
			     IF  eni_return_status = 'S' THEN
			         IF PG_DEBUG <> 0 THEN
				      oe_debug_pub.add('Cto_Eni_Wrapper_Api:' || 'ENI_CONFIG_ITEMS_PKG.Create_config_items returned=>'
                                                     ||eni_return_status, 5);
			         END IF;
			     ELSE
			         IF PG_DEBUG <> 0 THEN
				      oe_debug_pub.add('Cto_Eni_Wrapper_Api: ' || 'ENI_CONFIG_ITEMS_PKG.Create_config_items returned=>'
                                                     ||eni_return_status, 1);
			            oe_debug_pub.add('Cto_Eni_Wrapper_Api: ' || 'IGNORING ABOVE ERROR', 1);
			         END IF;

			     END IF;

		             --end bugfix  3070429,3124169




                        END IF;


		        IF PG_DEBUG <> 0 THEN
			     oe_debug_pub.add('Create_All_Items: ' ||
                                         'Create_Item returned with lStatus::'||to_char(lStatus), 2);

			     oe_debug_pub.add('Create_All_Items: ' ||  'ITEM CREATED IS ::'||
                                          to_char(lxConfigId), 1);



			     oe_debug_pub.add('Create_All_Items: ' ||  'V_PERFORM_MATCH IS ::'|| v_perform_match, 1);
		        END IF;


                        /* update newly created config in bcol and bcol_temp */

                        update bom_cto_order_lines
                           set config_item_id = lXConfigId
                         where line_id = v_model_lines.line_id
                          returning perform_match into v_perform_match;


                        oe_debug_pub.add ('Create_All_items: ' || 'updated bcol ' || lXConfigId
                                           || ' for ' || v_model_lines.line_id , 1);


			oe_debug_pub.add('Create_All_Items: ' ||  'V_PERFORM_MATCH IS ::'|| v_perform_match, 1);

                        update /*+ INDEX (BOM_CTO_ORDER_LINES_GT BOM_CTO_ORDER_LINES_GT_U1) */
                           bom_cto_order_lines_gt
                           set config_item_id = lXConfigId
                         where line_id = v_model_lines.line_id ;


                        oe_debug_pub.add ('Create_All_items: ' || 'updated bcol_gt ' || lXConfigId
                                           || ' for ' || v_model_lines.line_id , 1);

			IF( NVL(v_model_lines.config_creation, 1) IN (1,2) OR
			     (v_model_lines.config_creation = 3 AND v_perform_match = 'N')) THEN  --Bugfix 7640680

			    update bom_cto_src_orgs_b
			      set config_item_id = lXConfigId
                            where line_id = v_model_lines.line_id ;

			END IF;

                        oe_debug_pub.add ('Create_All_items: ' || 'updated bcso ' || lXConfigId
                                               || ' for ' || v_model_lines.line_id
                                               || ' config_creation ' || v_model_lines.config_creation
                                               || ' rows ' || SQL%ROWCOUNT, 1);


                        --Bugfix 7640680: For perform_match in Y,U,C, the relevant data is in bcmo and not bcso.
                        --if( v_model_lines.config_creation = 3 and v_perform_match = 'U' ) then
			if( nvl(v_model_lines.config_creation, 1) = 3 and v_perform_match in ('Y', 'U', 'C')) then

                            select group_reference_id into v_bcso_group_reference_id from bom_cto_src_orgs_b
                                where line_id = v_model_lines.line_id ;



                            update bom_cto_model_orgs
                                set config_item_id = lXConfigId
                              where group_reference_id = v_bcso_group_reference_id ;



                            oe_debug_pub.add ('Create_All_items: ' || 'updated bcmo ' || lXConfigId
                                               || ' for ' || v_bcso_group_reference_id
                                               || ' rows ' || SQL%ROWCOUNT, 1);


                        end if;









                        IF( v_perform_match = 'U') then

                            oe_debug_pub.add ('Create_All_items: ' || 'canning configuration' || v_model_lines.line_id, 1);

                            /* CAN configuration for items created when match profile = 'Yes' */

                            lStatus := CTO_MATCH_CONFIG.can_configurations(
                                          v_model_lines.line_id,
                                          0,
                                          0,
                                          0,
                                          lUserId,
                                          lLoginId,
                                          l_x_error_msg,
                                          l_x_msg_name);



                        END IF;


               /* Matched Type 3 configurations */
                   elsif  ( lXConfigId is not null and nvl(v_model_lines.config_creation, 1) = 3 and  v_perform_match <> 'N' ) then





                     v_model_item_status :=  0 ;
                     v_config_item_status :=  0 ;

                     begin
                        select 1 /* BCMO not in synch with Model Item */ into v_model_item_status from dual
                        where exists ( select organization_id from mtl_system_items msi
                                           where not exists
                                                 ( select organization_id from bom_cto_model_orgs bcmo
                                                   where bcmo.config_item_id = lXConfigId
                                                     and bcmo.organization_id = msi.organization_id )
                                             and msi.inventory_item_id = v_model_lines.inventory_item_id ) ;

                     exception
                     when others then

                          null ;
                     end ;



                     begin
                        select 1 /*Config not in synch with Model Item */ into v_config_item_status from dual
                        where exists ( select organization_id from mtl_system_items model
                                           where not exists
                                                 ( select organization_id from mtl_system_items config
                                                   where config.inventory_item_id = lXConfigId
                                                     and config.organization_id = model.organization_id )
                                             and model.inventory_item_id = v_model_lines.inventory_item_id ) ;

                     exception
                     when others then

                          null ;
                     end ;


		     IF PG_DEBUG <> 0 THEN
		           oe_debug_pub.add ('Create_All_Items: ' ||
                                             'v_model_item_status ' || to_char(v_model_item_status) ||
                                             'v_config_item_status ' || to_char(v_config_item_status) , 1);
		     END IF;


                     if( v_model_item_status = 1 or v_config_item_status = 1  ) then


		        IF PG_DEBUG <> 0 THEN
		           oe_debug_pub.add ('Create_All_Items: ' || 'Error: Item Not Enabled in some orgs', 1);
		        END IF;

                        select concatenated_segments into v_model_item_name
                          from mtl_system_items_kfv
                         where inventory_item_id = v_model_lines.inventory_item_id
                           and rownum = 1 ;


                        l_token(1).token_name  := 'MODEL_NAME';
                        l_token(1).token_value := v_model_item_name ;



                        select concatenated_segments into v_config_item_name
                          from mtl_system_items_kfv
                         where inventory_item_id = lXConfigId
                           and rownum = 1 ;


                        l_token(2).token_name  := 'CONFIG_NAME';
                        l_token(2).token_value := v_config_item_name;


		        cto_msg_pub.cto_message('BOM','CTO_MATCH_ITEM_NOT_ENABLED', l_token );

		        raise FND_API.G_EXC_ERROR;


                     else

		        IF PG_DEBUG <> 0 THEN
		           oe_debug_pub.add ('Create_All_Items: ' || 'Item Enabled in all orgs', 1);
		        END IF;


                     end if;


			oe_debug_pub.add('Create_All_Items: No need to Handle Item Creation for Type 3 matched AutoConfig ' , 1 ) ;






                        /* update newly created config in bcol and bcol_temp */

                        update bom_cto_order_lines
                           set config_item_id = lXConfigId
                         where line_id = v_model_lines.line_id ;


                        oe_debug_pub.add ('Create_All_items: ' || 'updated bcol ' || lXConfigId
                                           || ' for ' || v_model_lines.line_id , 1);



                        update /*+ INDEX (BOM_CTO_ORDER_LINES_GT BOM_CTO_ORDER_LINES_GT_U1) */
                           bom_cto_order_lines_gt
                           set config_item_id = lXConfigId
                         where line_id = v_model_lines.line_id ;


                        oe_debug_pub.add ('Create_All_items: ' || 'updated bcol_gt ' || lXConfigId
                                           || ' for ' || v_model_lines.line_id , 1);


                        select group_reference_id into v_bcso_group_reference_id from bom_cto_src_orgs_b
                        where line_id = v_model_lines.line_id ;



                        update bom_cto_model_orgs
                        set config_item_id = lXConfigId
                        where group_reference_id = v_bcso_group_reference_id ;



                        oe_debug_pub.add ('Create_All_items: ' || 'updated bcmo ' || lXConfigId
                                               || ' for ' || v_bcso_group_reference_id
                                               || ' rows ' || SQL%ROWCOUNT, 1);


                        /* Needs to account for BCMO for type 3 */
                        update bom_cto_src_orgs_b
                           set config_item_id = lXConfigId
                         where line_id = v_model_lines.line_id ;



                        oe_debug_pub.add ('Create_All_items: ' || 'updated bcso ' || lXConfigId
                                               || ' for ' || v_model_lines.line_id
                                               || ' rows ' || SQL%ROWCOUNT, 1);



                   elsif  ( lXConfigId is not null and nvl(v_model_lines.config_creation, 1) = 3 and  v_perform_match = 'N' ) then

			oe_debug_pub.add('Create_All_Items: Handle Item Creation for Type 3 reuse ' , 1 ) ;

                        lStatus := CTO_CONFIG_ITEM_PK.create_item(
	 			pModelId	=> v_model_lines.inventory_item_id,
	 			pLineId	=> v_model_lines.line_id,
         			pConfigId	=> lxConfigId,
				xMsgCount	=> xMsgCount,
				xMsgData	=> xMsgData,
                                p_mode          => p_mode );

		        IF lStatus <> 1 THEN
		           IF PG_DEBUG <> 0 THEN
				  oe_debug_pub.add('Create_All_Items: ' ||
                                   'Create_Item returned 0::item::'||
                                    to_char(v_model_lines.inventory_item_id), 1);
			     END IF;

			     -- cto_msg_pub.cto_message('BOM','CTO_CREATE_ITEM_ERROR');
			     raise FND_API.G_EXC_ERROR;


                        ELSE --if status is success
                             --start bugfix  3070429,3124169

                             l_eni_star_record.inventory_item_id := lxConfigId;

			     IF PG_DEBUG <> 0 THEN
				   oe_debug_pub.add('Create_All_Items: ' || 'conifg item id passed to ENI=>'||
				                   l_eni_star_record.inventory_item_id , 5);
			     END IF;

                             --follwoing API is maintained by PLM,DBI team present in Bom source control


			     CTO_ENI_WRAPPER.CTO_CALL_TO_ENI
			        (p_api_version  => 1.0,
				   p_star_record  => l_eni_star_record,
				   x_return_status =>eni_return_status,
                             x_msg_count	 => xMsgCount,
                             x_msg_data	 => xMsgData);





			     --return status passed as 'S' and not as FND_API.XXXXX
			     --CTO has decided not to fail for error messages but just log messages
			     --refer bug 3124169 for more info
			     IF  eni_return_status = 'S' THEN
			         IF PG_DEBUG <> 0 THEN
				      oe_debug_pub.add('Cto_Eni_Wrapper_Api:' || 'ENI_CONFIG_ITEMS_PKG.Create_config_items returned=>'
                                                     ||eni_return_status, 5);
			         END IF;
			     ELSE
			         IF PG_DEBUG <> 0 THEN
				      oe_debug_pub.add('Cto_Eni_Wrapper_Api: ' || 'ENI_CONFIG_ITEMS_PKG.Create_config_items returned=>'
                                                     ||eni_return_status, 1);
			            oe_debug_pub.add('Cto_Eni_Wrapper_Api: ' || 'IGNORING ABOVE ERROR', 1);
			         END IF;

			     END IF;

		             --end bugfix  3070429,3124169




                        END IF;


		        IF PG_DEBUG <> 0 THEN
			     oe_debug_pub.add('Create_All_Items: ' ||
                                         'Create_Item returned with lStatus::'||to_char(lStatus), 2);

			     oe_debug_pub.add('Create_All_Items: ' ||  'ITEM CREATED IS ::'||
                                          to_char(lxConfigId), 1);
		        END IF;


                        /* update newly created config in bcol and bcol_temp */

                        update bom_cto_order_lines
                           set config_item_id = lXConfigId
                         where line_id = v_model_lines.line_id ;


                        oe_debug_pub.add ('Create_All_items: ' || 'updated bcol ' || lXConfigId
                                           || ' for ' || v_model_lines.line_id , 1);



                        update bom_cto_src_orgs_b
                           set config_item_id = lXConfigId
                         where line_id = v_model_lines.line_id ;



                        oe_debug_pub.add ('Create_All_items: ' || 'updated bcso ' || lXConfigId
                                               || ' for ' || v_model_lines.line_id
                                               || ' config_creation ' || v_model_lines.config_creation
                                               || ' rows ' || SQL%ROWCOUNT, 1);




               END IF; /* check for config item creation */


       END LOOP; /* config creation loop for each model line */

       --Bugfix 9223554: Clear the global collection g_wt_tbl and g_vol_tbl
       CTO_CONFIG_ITEM_PK.g_wt_tbl.delete;
       CTO_CONFIG_ITEM_PK.g_vol_tbl.delete;
       IF PG_DEBUG <> 0 THEN
         oe_debug_pub.add('Count Wt:' || CTO_CONFIG_ITEM_PK.g_wt_tbl.count ||
                          'Count Vol:' || CTO_CONFIG_ITEM_PK.g_vol_tbl.count, 1);
       END IF;

       return(1);

EXCEPTION
	when NO_DATA_FOUND then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Create_All_Items: ' ||  'create_all_items::ndf::lStmtNum::'||to_char(lStmtNum)||'::'||sqlerrm, 1);
		END IF;
		xReturnStatus := fnd_api.g_ret_sts_error;
		cto_msg_pub.count_and_get
          		(  p_msg_count => xMsgCount
           		, p_msg_data  => xMsgData
           		);
		return(0);

	when FND_API.G_EXC_ERROR then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Create_All_Items: ' || 'Create_All_Items::exp error::'||to_char(lStmtNum)||'::'||sqlerrm, 1);
		END IF;
		xReturnStatus := fnd_api.g_ret_sts_error;
		cto_msg_pub.count_and_get
          		(  p_msg_count => xMsgCount
           		, p_msg_data  => xMsgData
           		);
		return(0);

	when FND_API.G_EXC_UNEXPECTED_ERROR then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Create_All_Items: ' || 'Create_All_Items::unexp error::'||to_char(lStmtNum)||'::'||sqlerrm, 1);
		END IF;
		xReturnStatus := fnd_api.g_ret_sts_unexp_error;
		cto_msg_pub.count_and_get
          		(  p_msg_count => xMsgCount
           		, p_msg_data  => xMsgData
           		);
		return(0);

	when OTHERS then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Create_All_Items: ' || 'Create_All_Items::others::'||to_char(lStmtNum)||'::'||sqlerrm, 1);
		END IF;
		xReturnStatus := fnd_api.g_ret_sts_unexp_error;
		cto_msg_pub.count_and_get
          		(  p_msg_count => xMsgCount
           		, p_msg_data  => xMsgData
           		);
		return(0);

END Create_All_Items;


  procedure perform_match(
     p_ato_line_id           in  bom_cto_order_lines.ato_line_id%type ,
     x_match_found           out NOCOPY varchar2,
     x_matching_config_id    out NOCOPY number,
     x_error_message         out NOCOPY VARCHAR2,
     x_message_name          out NOCOPY varchar2
  )
  is
l_stmt_num       number := 0;
l_cfm_value      number;
l_config_line_id number;
l_tree_id        integer;
l_return_status  varchar2(1);
l_x_error_msg_count    number;
l_x_error_msg          varchar2(240);
l_x_error_msg_name     varchar2(30);
l_x_table_name   varchar2(30);
l_match_profile  varchar2(10);
l_org_id         number;
l_model_id       number;
l_primary_uom_code     varchar(3);
l_x_config_id    number;
l_top_model_line_id number;

l_x_qoh          number;
l_x_rqoh         number;
l_x_qs           number;
l_x_qr           number;
l_x_att          number;
l_active_activity varchar2(30);
l_x_bill_seq_id  number;
l_status         number ;

l_perform_match  varchar2(1) ;

x_return_status  varchar2(1);
x_msg_count      number;
x_msg_data       varchar2(100);

PROCESS_ERROR      EXCEPTION;


  cursor c_model_lines is
       select line_id, parent_ato_line_id
       from   bom_cto_order_lines
       where  bom_item_type = '1'
       and    ato_line_id = p_ato_line_id
       and    nvl(wip_supply_type,0) <> 6
       order by plan_level desc;

  v_sqlcode               number ;
 l_custom_match_profile varchar2(10);


v_bcol_count number ;
v_bcol_gt_count number ;


  begin



     select count(*) into v_bcol_count from bom_cto_order_lines
     where ato_line_id = p_ato_line_id ;


     select /*+ INDEX (BOM_CTO_ORDER_LINES_GT BOM_CTO_ORDER_LINES_GT_N1) */
     count(*) into v_bcol_gt_count from bom_cto_order_lines_gt
     where ato_line_id = p_ato_line_id ;


      oe_debug_pub.add( ' perform_match bcol count ' || v_bcol_count , 1 ) ;
      oe_debug_pub.add( ' perform_match bcol_gt count ' || v_bcol_gt_count , 1 ) ;

        l_stmt_num := 1;

        x_match_found := 'N' ;

        l_custom_match_profile := FND_PROFILE.Value('BOM:CUSTOM_MATCH');

        l_stmt_num := 5;

        /* for each model */

        for l_next_rec in c_model_lines loop

           l_x_config_id := NULL;



           select perform_match into l_perform_match
            from  bom_cto_order_lines
           where  line_id = l_next_rec.line_id ;


          oe_debug_pub.add( ' perform_match: line_id ' || l_next_rec.line_id || ' match ' || l_perform_match , 1 ) ;


          if( l_perform_match = 'U' ) then

             begin

                 update bom_cto_order_lines set perform_match = 'U'
                 where perform_match = 'Y'
                   and line_id = l_next_rec.parent_ato_line_id ;

             exception
                when no_data_found then
                     null ;

             end ;

             x_match_found := 'N' ;

             x_matching_config_id := NULL ; /* fix for bug#2048023. */



          elsif( l_perform_match in(  'Y' , 'C' ) ) then

              if ( l_perform_match = 'Y' ) then
                   l_stmt_num := 10;
                   oe_debug_pub.add('Standard Match.', 1);
                   l_status := cto_match_config.check_config_match(
                                          l_next_rec.line_id,
                                          l_x_config_id,
                                          l_x_error_msg,
                                          l_x_error_msg_name);

                  oe_debug_pub.add(' done Check Config Match ' , 1 ) ;


              elsif ( l_perform_match = 'C' ) then
                   l_stmt_num := 15;
                   l_status := CTO_CUSTOM_MATCH_PK.find_matching_config(
                                          l_next_rec.line_id,
                                          l_x_config_id,
                                          l_x_error_msg,
                                          l_x_error_msg_name,
                                          l_x_table_name);
              end if;

              l_stmt_num := 20;

              if (l_status = 0) then
                  oe_debug_pub.add('Failed in Check Config Match for line id '
                                || to_char(l_next_rec.line_id), 1);

                  raise PROCESS_ERROR;

              end if;


              l_stmt_num := 25;


              if (l_status = 1 and l_x_config_id is NULL) then
                  l_stmt_num := 30;

                  x_message_name := 'CTO_MR_NO_MATCH';
                  x_error_message := 'No matching configurations for line '
                                   || to_char(l_next_rec.line_id);
                  l_stmt_num := 137;

                  -- insert into my_debug_messages values ( 'No Match found' ) ;
                  x_match_found := 'N' ;

                  x_matching_config_id := NULL ; /* fix for bug#2048023. */

                  /* fix for bug#2048023.
                     This variable has to be initialized to null as it was not
                     null for a lower level match in the perform match loop.
                  */


                  /* update the perform match column to 'U' so that this item is canned */
                  begin
                       update bom_cto_order_lines
                       set    perform_match = 'U'
                       where  line_id = l_next_rec.line_id
                       and    perform_match = 'Y';

                  exception
                     when no_data_found then
                       null ;

                  end ;



                  /* update the perform match column to 'U' so that no match
                     is attempted against its parent and it is canned
                  */

                  begin
                       update bom_cto_order_lines
                       set    perform_match = 'U'
                       where  line_id = l_next_rec.parent_ato_line_id
                       and    perform_match = 'Y';

                  exception
                     when no_data_found then
                       null ;

                  end ;


                  x_match_found := 'U' ;

                  x_matching_config_id := NULL ;

              elsif (l_status = 1 and l_x_config_id is not null) then

                  l_stmt_num := 35;


                    oe_debug_pub.add('Match for line id '
                                || to_char(l_next_rec.line_id)
                                || ' is ' || to_char(l_x_config_id) ,1);


                  update bom_cto_order_lines
                     set config_item_id = l_x_config_id
                   where  line_id = l_next_rec.line_id;



                  oe_debug_pub.add( 'perform_match: bcol update ' || SQL%rowcount , 1 ) ;

                  update /*+ INDEX (BOM_CTO_ORDER_LINES_GT BOM_CTO_ORDER_LINES_GT_U1) */
                     bom_cto_order_lines_gt
                     set config_item_id = l_x_config_id
                   where  line_id = l_next_rec.line_id;


                  oe_debug_pub.add( 'perform_match: bcol_gt update ' || SQL%rowcount , 1 ) ;

                  l_stmt_num := 40 ;

                  x_matching_config_id := l_x_config_id ;

                  x_match_found := 'Y' ;


                  l_stmt_num := 45 ;

                  -- insert into my_debug_messages values ( 'Match found' ) ;
                  -- insert into my_debug_messages values ( 'Matched Item '  ||  to_char(x_matching_config_id  ) ) ;


              end if;

           else

              oe_debug_pub.add(' Match OFF  for line id '
                                || to_char(l_next_rec.line_id) ,1);


              x_match_found := 'N' ;


           end if ; /* if perform_match = 'N' 'U' 'Y' 'C'  */


        end loop;


  exception
      when others then
                  V_SQLCODE := SQLCODE ;
                  oe_debug_pub.add ( ' exception in match at step ' || to_char( l_stmt_num ) ) ;
                  -- insert into my_debug_messages values ( ' exception in match at step ' || to_char( l_stmt_num ) ) ;
                  -- insert into my_debug_messages values ( ' exception in match SQL ' || to_char( V_SQLCODE ) ) ;

  end perform_match ;









PROCEDURE evaluate_item_behavior( p_ato_line_id  in NUMBER
                                ,x_return_status   out NOCOPY varchar2
                                ,x_msg_count     out NOCOPY number
                                ,x_msg_data   out NOCOPY varchar2     )
is

cursor c_item_behavior
is
select config_creation , line_id , parent_ato_line_id
from bom_cto_order_lines
where ato_line_id = p_ato_line_id
 and  bom_item_type = '1' and nvl(wip_supply_type, 1 ) <> 6
order by plan_level desc ;


v_config_creation          bom_cto_order_lines.config_creation%type ;
v_line_id                  number ;
v_parent_ato_line_id       number ;
v_last_config_creation     bom_cto_order_lines.config_creation%type ;


 TYPE TAB_BCOL is TABLE of bom_cto_order_lines%rowtype index by binary_integer   ;

 item_behavior_violated exception ;

 t_bcol TAB_BCOL ;
 i number ;

begin

                  oe_debug_pub.add ( ' entered evaluate item behavior ' , 1 ) ;



     open c_item_behavior ;

     loop

         fetch c_item_behavior into v_config_creation
                                   ,v_line_id
                                   ,v_parent_ato_line_id ;


         exit when c_item_behavior%notfound ;


         t_bcol(v_line_id).line_id := v_line_id ;
         t_bcol(v_line_id).parent_ato_line_id := v_parent_ato_line_id ;
         t_bcol(v_line_id).config_creation := v_config_creation ;



     end loop ;

     close c_item_behavior ;


     i := t_bcol.first ;

     while i is not null
     loop


         if( t_bcol(i).config_creation  in ( 1, 2 ) and t_bcol(t_bcol(i).parent_ato_line_id).config_creation = 3 ) then

          oe_debug_pub.add( 'evaluate_item_behavior:' || ' item behavior violated for line id ' || t_bcol(i).line_id
                                                                   || ' behavior ' || t_bcol(i).config_creation
                             || ' parent ato line ' ||  t_bcol(i).parent_ato_line_id
                             || ' parent behavior ' || t_bcol(t_bcol(i).parent_ato_line_id).config_creation  , 1 ) ;


              raise item_behavior_violated ;
         end if;


         i := t_bcol.next(i) ;

     end loop ;



exception
   when item_behavior_violated then

          oe_debug_pub.add( 'evaluate_item_behavior:' || ' item behavior violated ' , 1 ) ;


end evaluate_item_behavior;

end CTO_ITEM_PK;

/
