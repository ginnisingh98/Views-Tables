--------------------------------------------------------
--  DDL for Package Body CTO_BOM_RTG_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_BOM_RTG_PK" as
/* $Header: CTOBMRTB.pls 120.7.12010000.2 2011/02/08 08:01:03 abhissri ship $ */

/*************************************************************************************
*
*     Modified by : Sushant Sawant
*     Modified on : 01/23/2001
*     Desc        : In Creating Bom If the model bill is not existing
*                   in the organization where we create the config bom
*                   the procedure needs to error out
*
*     History     : 06/18/01 sbhaskar
*	 	    bugfix 1835357
*		    Comment out all FND_FILE calls since we are using oe_debug_pub.
*
*
*
*
*
*              Modified on 24-AUG-2001 by Sushant Sawant: BUG #1957336
*                                         Added a new functionality for preconfigure bom.
*              Modified on 08-MAR-2002 by Sushant Sawant: BUG#2234858
*                                         Added a new functionality for Drop Ship
*
*
*	       Modified on 11-MAR-2002 By Renga Kannan Bug#2255396
*                                         Attachment creation for multiple buy model
*                                         under a top model was erroring out
*                                         I have changed the implimentation of this to
*                                         work for multiple buy models
*
*              Modified on 27-MAR-2002 By Kiran Konada
*                                         changed the signature in call to GENERATE_BOM_ATTACH_TEXT
*                                          above changes have been made as part of patchset-H
*
*              Modified on 09-JAN-2003 by Sushant Sawant:
*                                         Added code for enhanced costing issues.
*
*              Modified on 14-FEB-2003 By Kundan Sarkar
*                                         Bugfix 2804321 : Propagating customer bugfix 2774570
*                                         to main.
*
*              Modified on 18-FEB-2003 by Sushant Sawant:
*                                         Fixed bug 2808704.

*               Modified on 20-FEB-2003 Sushant Sawant
*                                       Fixed Bug 2810797
*                                       Changed logic for overriding cost rollup.

*               Modified on 28-FEB-2003 Sushant Sawant
*                                       Fixed Bug 2828634
*                                       Check whether item has been transacted in standard costing org.
*
*
*              Modified on 02-JUL-2003 By Kundan Sarkar ( Bug 2986192) Customer bug 2929861
*                                         Add warning for dropped items during match.
*                                         Config item creation will now depend upon the
*					  value of profile BOM:CONFIG_EXCEPTION
*

*               Modified on 09-JAN-2004 Sushant Sawant
*                                       Fixed Bug 3349142
*                                       Added token to error message CTO_NO_BOM_CREATED_IN_ANY_ORGS
*
|               ssawant   15-JAN-04   Bugfix 3374548
|               Added delete from from bom_inventory_comps_interface to avoid corrupt data.
|
              Modified on 21-APR-2004 By  Renga Kannan ( Bug 3543547)
*                                         Autocreate config is dropping
*                                         components from bill
*                                         *
*                                         since dropped component logic is based
*                                         on bill
*                                         *
*                                         sequence id instead of common bill
*                                         sequence id .
*
*               Modified on 19-NOV-2004 Sushant Sawant
*                                       Fixed Bug 3877317 front port for bug 3764447
*                                       This bug has been front ported with some modifications
*                                       to account for 11.5.10 features.
*
*                                       BUG 3877317.
*
*                                       old_behavior:
*                                       Organizations where Cost rollup needs to be performed were determined using
*                                       RCV_ORG_ID and ORGANIZATION_ID columns in bom_cto_src_orgs view.
*
*                                       new behavior:
*                                       Organizations where cost rollup needs to be performed will now be determined using
*                                       only ORGANIZATION_ID column in bom_cto_src_orgs view.
*
*                                       procedure CREATE_IN_SRC_ORGS has changed
*
*                                       1) change to cursor cSrcOrgs
*                                          columns create_bom, cost_rollup and organization_type have been removed as they
*                                          will now be queried in the cursor loop
*                                       2) added new variables v_create_bom, v_perform_cost_rollup
*                                       3) cost_rollup flag needs to be queried again as the flag can be updated in the loop
*                                       4) create_bom flag needs to be queried in the loop
*
*                                       procedure OVERRIDE_BCSO_COST_ROLLUP has changed.
*
*                                       1) query fixed to get v_organization_type.
*                                       2) added new too_many_rows exception handler due to query in 1 above
*                                          is now dependent only on organization_id
*                                       3) SQL added in too_many_rows exception handler declared in 2 above to check whether
*                                          organization_id is make org. query is now based only on organization_id and hence
*                                          needs to check whether it is manufacturing org using the following sql.
*                                          The code to check whether cost rollup should not be performed needs to know whether
*                                          the organization is make organization. In 11.5.9 this check was not required as
*                                          create_bom flag was set only for manufacturing org.
*
*                                       All changes are marked with bug 3877317.
*
*
*
***************************************************************************************/

/*-------------------------------------------------------------+
  Name : Create_all_boms_and_routings
         This procedure loops through all the configuration
         items in bom_cto_order_lines and calls create_in_src_orgs
         for each item.
+-------------------------------------------------------------*/
PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);


procedure override_bcso_cost_rollup(
        pLineId         in  number, -- Current Model Line ID
        pModelId        in  number,
        pConfigId       in  number,
        p_cost_organization_id in number,
        p_organization_id      in number,
        p_group_reference_id   in number,
        xReturnStatus   out NOCOPY varchar2,
        xMsgCount       out NOCOPY number,
        xMsgData        out NOCOPY varchar2
        );



FUNCTION is_item_transacted(  p_inventory_item_id NUMBER
                             , p_organization_id NUMBER
                             , p_cost_type_id  NUMBER )
 Return BOOLEAN;



procedure create_all_boms_and_routings(
        pAtoLineId         in  number, -- this is the top ato model line id
        pFlowCalc          in  number,
        xReturnStatus      out NOCOPY varchar2,
        xMsgCount          out NOCOPY number,
        xMsgData           out NOCOPY varchar2
        )

IS

   cursor cAllConfigItems is
          select bcol.line_id, bcol.inventory_item_id,
                 bcol.config_item_id
          from   bom_cto_order_lines bcol
          --where  bcol.top_model_line_id = pTopModelLineId
          where  bcol.ato_line_id = pAtoLineId
          and    bcol.bom_item_type = 1
          and    nvl(bcol.wip_supply_type,0) <> 6
          and    bcol.config_item_id is not null
          and    bcol.ato_line_id is not null
          order by plan_level desc;

          l_line_id        oe_order_lines_all.line_id%type;
          l_config_item_id oe_order_lines_all.inventory_item_id%type;
          l_rcv_org_id     oe_order_lines_all.ship_from_org_id%type;


     v_bcol_count number:= 0 ;
BEGIN



    xReturnStatus := FND_API.G_RET_STS_SUCCESS;



   select count(*) into v_bcol_count from bom_cto_order_lines
    where ato_line_id = pAtoLineId ;

   oe_debug_pub.add(' CTOBMRTB bcol count ' || v_bcol_count  || ' for ' || pAtoLineid , 1);


    for lNextRec in cAllConfigItems loop

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('create_all_boms_and_routings: ' || 'Calling create_in_src_orgs with item ' ||
                          to_char(lNextRec.config_item_id) ||
                          ' and line ' || to_char(lNextRec.line_id), 1);
        END IF;

        create_in_src_orgs(
                           lNextRec.line_id,           -- model line id
                           lNextRec.inventory_item_id, -- model item
                           lNextRec.config_item_id,
                           pFlowCalc,
                           xReturnStatus,
                           xMsgCount,
                           xMsgData);

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('create_all_boms_and_routings: ' || 'Returned from create_in_src_orgs with result '
                          || xReturnStatus, 1);
        END IF;

        /* BUG #1957336 Change for preconfigure bom by Sushant Sawant */
        /* Sushant corrected this implementation */

  	if( xReturnStatus = FND_API.G_RET_STS_ERROR ) then
            RAISE FND_API.G_EXC_ERROR ;

        elsif( xReturnStatus = FND_API.G_RET_STS_UNEXP_ERROR ) then
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

        end if ;

    end loop;

    /* 2986192 */

    CTO_MATCH_CONFIG.gMatch := 0;

    IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('Value of gMatch ..  '||CTO_MATCH_CONFIG.gMatch,1);
    END IF;


   --- Added by Renga Kannan on 01/20/04 . Calling the new procedure to Create item attachments

   oe_debug_pub.add('Create_all_boms_and_routings: Calling Create_item_attachments API',1);

   CTO_UTILITY_PK.create_item_attachments(
                                    p_ato_line_id   => pAtoLineId,
				    x_return_status => xReturnStatus,
				    x_msg_count     => xMsgCount,
				    x_msg_data      => xMsgData);
   oe_debug_pub.add('Create_all_boms_and_routings: After Create_item_attachments API',1);



     --  Get message count and data
        cto_msg_pub.count_and_get
          (  p_msg_count => xMsgCount
           , p_msg_data  => xMsgData
           );


EXCEPTION

   WHEN fnd_api.g_exc_error THEN
        xReturnStatus := fnd_api.g_ret_sts_error;
        --  Get message count and data
        if( xMsgData is null ) then
        cto_msg_pub.count_and_get
          (  p_msg_count => xMsgCount
           , p_msg_data  => xMsgData
           );
        end if ;

     IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('create_all_boms_and_routings: ' || xMsgData , 1);
        END IF;

   WHEN fnd_api.g_exc_unexpected_error THEN
        xReturnStatus := fnd_api.g_ret_sts_unexp_error ;
        --  Get message count and data
        cto_msg_pub.count_and_get
          (  p_msg_count  => xMsgCount
           , p_msg_data   => xMsgData
            );

   WHEN OTHERS then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('create_all_boms_and_routings: ' || 'create_all_boms_and_routings::others::'||'::'||sqlerrm, 1);
	END IF;
        xReturnStatus := fnd_api.g_ret_sts_unexp_error;
        --  Get message count and data
        cto_msg_pub.count_and_get
          (  p_msg_count  => xMsgCount
           , p_msg_data   => xMsgData
             );

END create_all_boms_and_routings;



-- rkaza. bug 4315973. 08/25/2005. Helper function called from create_in_src
-- _orgs
-- Start of comments
-- API name : get_ato_line_id
-- Type	    : private
-- Pre-reqs : None.
-- Function : Given line_id, it gives ato_line_id and header_id
--
-- Parameters:
-- IN	    : p_line_id           	IN NUMBER	Required.
-- Version  :
-- End of comments

Procedure get_ato_line_id(p_line_id IN Number,
                          x_ato_line_id out NOCOPY number,
                          x_header_id out NOCOPY number,
			  x_return_status OUT NOCOPY varchar2) is

Begin

x_return_status := FND_API.G_RET_STS_SUCCESS;

select ato_line_id, header_id
into   x_ato_line_id, x_header_id
from   bom_cto_order_lines
where  line_id = p_line_id ;

IF PG_DEBUG <> 0 THEN
   oe_debug_pub.add('get_ato_line_id: ' || 'Queried ato_line_id from bcol for given line_id. exiting...', 5);
END IF;

Exception

when FND_API.G_EXC_ERROR THEN
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('get_ato_line_id: ' || 'expected error: ' || sqlerrm, 1);
   END IF;
   x_return_status := FND_API.G_RET_STS_ERROR;

when FND_API.G_EXC_UNEXPECTED_ERROR then
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('get_ato_line_id: ' || 'unexpected error: ' || sqlerrm, 1);
   END IF;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

when others then
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('get_ato_line_id: ' || 'When others exception ..' || sqlerrm, 1);
   END IF;
   x_return_status := fnd_api.g_ret_sts_unexp_error;

End get_ato_line_id;




/*-------------------------------------------------------------+
  Name : create_in_src_orgs
         This procedure creates a config item's bom and routing
         in all of the proper sourcing orgs based on the base
         model's sourcing rules.
+-------------------------------------------------------------*/
procedure create_in_src_orgs(
        pLineId         in  number, -- Current Model Line ID
        pModelId        in  number,
        pConfigId       in  number,
        pFlowCalc       in  number,
        xReturnStatus   out NOCOPY varchar2,
        xMsgCount       out NOCOPY number,
        xMsgData        out NOCOPY varchar2
        )

IS

   lStmtNum        number;
   lStatus         number;
   lItmBillId      number;
   lCfgBillId      number;
   lCfgRtgId       number;
   xBillId         number;
   lXErrorMessage  varchar2(100);
   lXMessageName   varchar2(100);
   lXTableName     varchar2(100);

   /* Report errors for single bom not created for non oss
      bom not created in mfg org for oss
      bom may not be created if create_config_bom = 'N' or model bom does not exist.
   */
    /* bug 3877317.
       change to cursor cSrcOrgs
       columns create_bom, cost_rollup and organization_type have been removed as they
       will now be queried in the cursor loop
    */
   cursor cSrcOrgs is
          select   distinct bcso.organization_id,
                            mp.cost_organization_id,
                            bcol.perform_match,
                            bcol.option_specific,
                            -- bcso.create_bom bom_create,  bug 3877317 column will be queried in the cursor
                            bcso.model_item_id,
                            bcso.config_item_id,
                            bcso.group_reference_id
                            -- bcso.cost_rollup,        bug 3877317 column will be queried in the cursor
                            -- bcso.organization_type   bug 3877317 column will be queried in the cursor
          from     bom_cto_src_orgs bcso, bom_cto_order_lines bcol, mtl_parameters mp
          where    bcso.line_id = pLineId
          and      bcso.model_item_id = pModelId
          and      bcso.config_item_id is not null
          and      bcso.line_id = bcol.line_id
          and      bcso.organization_id = mp.organization_id ;




   v_primary_cost_method mtl_parameters.primary_cost_method%type := null ;
   v_cto_cost            cst_item_costs.item_cost%type := null ;
   v_cto_cost_xudc       cst_item_costs.item_cost%type := null ;
   v_valuation_cost      cst_item_costs.item_cost%type := null ;
   v_buy_cost            cst_item_costs.item_cost%type := null ;

  v_cto_cost_type_id     cst_item_costs.cost_type_id%type ;
  v_buy_cost_type_id     cst_item_costs.cost_type_id%type ;
  v_rolledup_cost_count   number ;
  v_rolledup_cost         number ;
  lBuyCostType            varchar2(30);

  v_item_transacted       boolean := FALSE ;

  /* bugfix 2986192 Cursor to select dropped items during match */
  /*  Effectivity date bug fix : 4147224
     Need to validate the dropped component for Estimated relase date
     window. Added a xEstRelDate parameter to cursor and
     added effectivity window condition for bom_inventory_comps_interface
     Sql
  */

   cursor mismatched_items (        	xlineid         number,
                                	xconfigbillid   number,
					xEstRelDate     Date) is
   select 	inventory_item_id
   from 	bom_cto_order_lines
   where 	parent_ato_line_id=xlineid
   and 		parent_ato_line_id <> line_id    /* to avoid selecting top model */
   and          NOT ( bom_item_type = 1 and wip_supply_type <> 6 and line_id <> xlineid ) /* to avoid selecting lower level models */
   minus
   select 	component_item_id
   from 	bom_inventory_comps_interface
   where 	bill_sequence_id = xconfigbillid
   and greatest(sysdate, xEstRelDate ) >= effectivity_date
   and (( disable_date is null ) or ( disable_date is not null and  disable_date >= greatest(sysdate, xEstRelDate)  )) ;

   l_missed_item_id             number;
   v_missed_item                varchar2(50);
   l_config_item                varchar2(50);
   l_model                      varchar2(50);
--   l_missed_line_number         varchar2(50);
   v_order_number               number	:= 0;
   l_token			CTO_MSG_PUB.token_tbl;
   l_token1			CTO_MSG_PUB.token_tbl;
   lcreate_item			number;
   lorg_code			varchar2(3);


   /* 2986192 End declaration */
   lComItmBillId                Number;         -- 3543547

  v_bom_created  number := 0 ;
  v_config_bom_exists  number := 0 ;
  v_bcol_count  number := 0 ;

  v_model_item_name  varchar2(2000) ;

   /* bug 3877317
      added new variables v_create_bom, v_perform_cost_rollup
   */
   v_create_bom          bom_cto_src_orgs.create_bom%type := null ;  -- bug 3877317
   v_perform_cost_rollup bom_cto_src_orgs.cost_rollup%type := null ; -- bug 3877317

   l_ato_line_id number;
   l_header_id number;
   lEstRelDate   Date;
   lLeadTime     Number;
   -- Fix bug 5199775
   v_program_id      	bom_cto_order_lines.program_id%type ;
   v_option_num          number := 0 ;
   v_dropped_item_string   varchar2(2000) ;
   v_sub_dropped_item_string   varchar2(2000) ;
   v_ac_message_string   varchar2(2000) ;
   v_missed_line_number		varchar2(50);
   l_new_line  varchar2(10) := fnd_global.local_chr(10);
   v_problem_model     varchar2(1000) ;
   v_problem_config    varchar2(1000) ;
   v_problem_model_line_num  varchar2(1000) ;
   v_table_count       number ;
   v_error_org         varchar2(1000) ;
   v_recipient         varchar2(100) ;
   lplanner_code                mtl_system_items_vl.planner_code%type;

   --Bugfix 11056452
   lCnt number;

BEGIN

   xReturnStatus := fnd_api.g_ret_sts_success;

   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add(' entered create_in_src_orgs: model ' || pModelId
                     || ' Line ' || pLineId  , 1);
   END IF;

   -- rkaza. bug 4315973.
   get_ato_line_id(p_line_id => pLineId,
                   x_ato_line_id => l_ato_line_id,
                   x_header_id => l_header_id,
	           x_return_status => xReturnStatus);

   if xReturnStatus <> fnd_api.g_ret_sts_success then
      raise fnd_api.g_exc_unexpected_error;
   end if;

   --- Fixed bug 5485452
   select program_id
   into   v_program_id
   from   bom_cto_order_lines
   where  line_id = pLineId;

   select count(*) into v_bcol_count from bom_cto_order_lines
    where ato_line_id = pLineId ;

   oe_debug_pub.add(' bcol count ' || v_bcol_count  , 1);

   select count(*) into v_bcol_count from bom_cto_order_lines
    where ato_line_id = pLineId and option_specific = 'N'  ;

   oe_debug_pub.add(' bcol count ' || v_bcol_count  , 1);

   lStmtNum := 10 ;


   for lNextRec in cSrcOrgs loop

      oe_debug_pub.add(' ******  entered cSrcOrgs loop ****************************' , 1);

      lStmtNum := 20 ;



      /* begin bug 3877317
         cost_rollup flag needs to be queried again as the flag can be updated in the loop
      */
      v_perform_cost_rollup := 'N' ;

      begin

      select 'Y'  into v_perform_cost_rollup from dual
      where exists ( select * from bom_cto_src_orgs
                    where line_id = pLineId
                      and cost_rollup = 'Y'
                      and organization_id = lNextRec.cost_organization_id ) ;


      exception
      when others then
           v_perform_cost_rollup := 'N' ;

      end ;

      /* end bug 3877317 */



      /* begin bug 3877317
         create_bom flag needs to be queried in the loop
      */

      v_create_bom := 'N' ;

      begin

      select 'Y'  into v_create_bom from dual
      where exists ( select * from bom_cto_src_orgs
                    where line_id = pLineId
                      and create_bom = 'Y'
                      and organization_id = lNextRec.organization_id ) ;


      exception
      when others then
           v_create_bom := 'N' ;

      end ;

      /* end bug 3877317 */


      oe_debug_pub.add(' entered cSRcOrgs model ' || lNextRec.model_item_id
                     || ' config ' || lNextRec.config_item_id
                     || ' org ' || lNextRec.organization_id , 1);

      oe_debug_pub.add(' entered cSRcOrgs model bom ' || v_create_bom || ' cost ' || v_perform_cost_rollup || ' option ' || lNextRec.option_specific , 1 ) ;


      if( v_perform_cost_rollup = 'Y'    ) then    -- bug 3877317 replaced variable
          oe_debug_pub.add(' create_in_src_orgs: ' || ' Going to call override_bcso_cost_rollup ' , 1 ) ;

          override_bcso_cost_rollup(
             pLineId, -- Current Model Line ID
             pModelId,
             pConfigId,
             lNextRec.cost_organization_id,
             lNextRec.organization_id,
             lNextRec.group_reference_id,
             xReturnStatus,
             xMsgCount,
             xMsgData        );

         oe_debug_pub.add(' create_in_src_orgs: ' || ' Done override_bcso_cost_rollup ' , 1 ) ;

      end if;


      lStmtNum := 30 ;

       if( v_create_bom = 'Y' ) then   -- bug 3877317  replaced variable
       -- check if model bom exists in src org

       lStmtNum := 40;
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('create_in_src_orgs: ' || ' Going to check bom for . Item: ' ||
                         to_char(pConfigId) || '. Org ' ||
                         to_char(lNextRec.organization_id), 1);
       END IF;


       /*  May not be required as model bom exists */
       lStmtNum := 100;
       lStatus := CTO_CONFIG_BOM_PK.check_bom(
					pItemId	=> pModelId,
                                        pOrgId	=> lNextRec.organization_id,
                                        xBillId	=> lItmBillId);

       IF PG_DEBUG <> 0 THEN
       	  oe_debug_pub.add('create_in_src_orgs: '
                         || 'Returned from check_bom for model with result '
                         || to_char(lStatus), 1);
       END IF;



       if (lStatus = 1) then



           lStmtNum := 110;
           lStatus := CTO_CONFIG_BOM_PK.check_bom(
					pItemId	=> pConfigId,
                                        pOrgId	=> lNextRec.organization_id,
                                        xBillId	=> lItmBillId);

           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('create_in_src_orgs: '
                        || 'Returned from check_bom for config with result '
                        || to_char(lStatus), 1);
           END IF;

           if (lStatus = 1) then
               v_config_bom_exists := v_config_bom_exists + 1 ;

               IF PG_DEBUG <> 0 THEN
               	oe_debug_pub.add('create_in_src_orgs: ' ||  'Config BOM ' || lItmBillId || '
                                  already exists ' ,1);
               END IF;

	       /*2986192*/

               IF PG_DEBUG <> 0 THEN
                 oe_debug_pub.add('Checking for dropped items ... ' ,1);
                 oe_debug_pub.add('Config id '||pConfigId||' Org '||lNextRec.organization_id, 1);
               END IF;

               -- 3543547

               select common_bill_sequence_id
               into lComItmBillId
               from bom_bill_of_materials
               where bill_sequence_id = lItmBillId;

               IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('create_in_src_orgs: ' ||  'Common Bill Id '
                                                        ||lComItmBillId,1);
               END IF;

               --  3543547

               lStmtNum := 111;

               begin

               IF PG_DEBUG <> 0 THEN
                 oe_debug_pub.add('Inserting into BICI ... ' ,1);
               END IF;

               -- rkaza. bug 4524248. 11/09/2005.
               -- bom structure import enhancements. Added batch_id.

               insert into bom_inventory_comps_interface(component_item_id,bill_sequence_id, batch_id,
	                                                 effectivity_date,disable_date)
   	       select component_item_id, bill_sequence_id,
                      cto_msutil_pub.bom_batch_id,effectivity_date,disable_date
   	       from   bom_inventory_components
               where bill_sequence_id = lComItmBillId; -- 3543547 lItmBillId;

   	       IF PG_DEBUG <> 0 THEN
   	         oe_debug_pub.add('Value of gMatch '||CTO_MATCH_CONFIG.gMatch ,1);
   	         oe_debug_pub.add('inserting into bici'|| SQL%ROWCOUNT || ' for bill ' || lItmBillId ,1);
   	       END IF;






   	       if CTO_MATCH_CONFIG.gMatch = 1 then




/*
   	       if lNextRec.perform_match = 'Y' then
*/

             	  lStmtNum := 121;

             	  IF PG_DEBUG <> 0 THEN
             	    oe_debug_pub.add('Inserting child base model into BICI for matched cases... ' ,1);
             	  END IF;

             	  insert into bom_inventory_comps_interface(component_item_id,bill_sequence_id, batch_id,
		                                            effectivity_date,disable_date)
   	     	  select distinct a.base_model_id, b.bill_sequence_id,
                         cto_msutil_pub.bom_batch_id,effectivity_date,disable_date
   	     	  from   bom_ato_configurations a,bom_inventory_components b
   	     	  where  a.config_item_id = b.component_item_id
                  and    b.bill_sequence_id =  lComItmBillId;    -- 3543547 lItmBillId

   	       end if;

   	     exception
       	        when others then
       	           IF PG_DEBUG <> 0 THEN
                     oe_debug_pub.add('Failed to insert into bom_inventory_comps_interface with error '||sqlerrm);
            	   END IF;
            	   raise fnd_api.g_exc_error;
    	     end ;

      	     lStmtNum := 112;

      	     begin

      	     IF PG_DEBUG <> 0 THEN
    	       oe_debug_pub.add ('Line_id '||pLineId,1);
    	     END IF;

    	     lcreate_item := nvl(FND_PROFILE.VALUE('CTO_CONFIG_EXCEPTION'), 1);

    	     IF PG_DEBUG <> 0 THEN
    	       oe_debug_pub.add ('Config exception profile '||lcreate_item);
      	     END IF;

	     /* Added by Renga Kannan
     	         Effectivity date bug fix : 4147224
		The following part of the code is added
		to get the lead time of config item */
             lStmtNum := 113;
             Begin
	        -- Fixed fp bug 5485452
                If ( v_program_id = CTO_UTILITY_PK.PC_BOM_PROGRAM_ID ) then
		select (ceil(nvl(msi.fixed_lead_time,0)
                   +  nvl(msi.variable_lead_time,0) * bcol.ordered_quantity))
                into    lLeadTime
                from    mtl_system_items msi,
	                bom_cto_order_lines bcol
                where   bcol.line_id = pLineId
	        and     msi.inventory_item_id = bcol.inventory_item_id
                and     msi.organization_id = CTO_UTILITY_PK.PC_BOM_VALIDATION_ORG;

                else
                select (ceil(nvl(msi.fixed_lead_time,0)
                   +  nvl(msi.variable_lead_time,0) * oel.ordered_quantity))
                into    lLeadTime
                from    mtl_system_items msi,
	                oe_order_lines_all oel
                where   oel.line_id = pLineId
	        and     msi.inventory_item_id = oel.inventory_item_id
                and     msi.organization_id = oe_sys_parameters.value( 'MASTER_ORGANIZATION_ID' , oel.org_id);
		end if;
	      Exception when others then
                 IF PG_DEBUG <> 0 THEN
         	   oe_debug_pub.add('create_in_src_orgs: ' || 'Failed in get_model_lead_time. ', 1);
                 END IF;
                 raise FND_API.G_EXC_ERROR;
	      End;

	      If PG_DEBUG <> 0 Then
                 oe_debug_pub.add('Create_in_src_orgs: '||' Config item lead time = '||to_char(lLeadTime),1);
		 oe_debug_pub.add('Create_in_src_orgs: Going to Calculate Estimated release date for the matched config item',1);
	      End if;
              lStmtNum := 114;
              begin
                 select CAL.CALENDAR_DATE
                 into   lEstRelDate
                 from   bom_calendar_dates cal,
                        mtl_system_items   msi,
                        bom_cto_order_lines   bcol,
                        mtl_parameters     mp
                 where  msi.organization_id    = lNextRec.organization_id
                 and    msi.inventory_item_id  = pModelId
                 and    bcol.line_id            = pLineId
                 and    bcol.inventory_item_id  = msi.inventory_item_id
                 and    mp.organization_id     = msi.organization_id
                 and    cal.calendar_code      = mp.calendar_code
                 and    cal.exception_set_id   = mp.calendar_exception_set_id
                 and    cal.seq_num =
                       (select cal2.prior_seq_num - lLeadTime
                        from   bom_calendar_dates cal2
                        where  cal2.calendar_code    = mp.calendar_code
                        and    cal2.exception_set_id = mp.calendar_exception_set_id
                        and    cal2.calendar_date    = trunc(bcol.schedule_ship_date));
              exception
   	         when no_data_found then
                    IF PG_DEBUG <> 0 THEN
		       oe_debug_pub.add('Create_in_src_orgs: ' || 'Unexpected error while computing estimated relase date',1);
                    END IF;
                    raise fnd_api.g_exc_unexpected_error;
              end;

              If PG_DEBUG <> 0 Then
                 oe_debug_pub.add('Create_in_src_orgs: '||' Estimated Release Date = '||to_char(lEstRelDate,'mm/dd/yy:hh:mi:ss'),1);
	      End if;
             /* End of  bug fix 4147224 */

             Open mismatched_items(pLineId, lComItmBillId,lEstRelDate);     -- 3543547 Replace lItmBillId with LComItmBillId

     	     loop

        	fetch mismatched_items into l_missed_item_id;

        	IF PG_DEBUG <> 0 THEN
        	  oe_debug_pub.add ('Missed item id '||l_missed_item_id,1);
        	END IF;

        	exit when mismatched_items%NOTFOUND;

                v_option_num := v_option_num + 1 ;

        	lStmtNum := 113;

        	begin

        	IF PG_DEBUG <> 0 THEN
        	  oe_debug_pub.add('Select missed component details.. ' ,1);
        	END IF;

		-- Bug Fix 5199775
        	if( v_program_id = CTO_UTILITY_PK.PC_BOM_PROGRAM_ID ) then
                   IF PG_DEBUG <> 0 THEN
                      oe_debug_pub.add('Pre configured Item .. ' ,1);
                   END IF;
                   IF PG_DEBUG <> 0 THEN
                      oe_debug_pub.add('Pre configured Item .. ' ,1);
                   END IF;

                   select substrb(msi.concatenated_segments,1,50),
                             'Not Available' ,
                            -1
                   into     v_missed_item,
                            v_missed_line_number,
                            v_order_number
                   from mtl_system_items_kfv msi,
                           bom_cto_order_lines bcol
                   where msi.organization_id = bcol.ship_from_org_id
                   and msi.inventory_item_id = bcol.inventory_item_id
                   and bcol.parent_ato_line_id = pLineId
                   and bcol.inventory_item_id  = l_missed_item_id
                   and rownum = 1;

                else

                   IF PG_DEBUG <> 0 THEN
                      oe_debug_pub.add('Auto configured Item .. ' ,1);
                   END IF;

        	   select  substrb(concatenated_segments,1,50),
                	to_char(oel.line_number)||'.'||to_char(oel.shipment_number) ||
				decode(oel.option_number,NULL,NULL,'.'||to_char(option_number)),
                	oeh.order_number
        	   into    v_missed_item,
		           v_missed_line_number,
			   v_order_number
        	   from    mtl_system_items_kfv msi,
		           oe_order_lines_all oel,
			   oe_order_headers_all oeh
             	   	  ,bom_cto_order_lines bcol
        	   where   msi.organization_id = oel.ship_from_org_id
        	   and     msi.inventory_item_id = oel.inventory_item_id
        	   and     oel.header_id   = oeh.header_id
        	   and     oel.inventory_item_id = l_missed_item_id
        	   and 	   oel.line_id = bcol.line_id
        	   and     bcol.parent_ato_line_id = pLineId
		   and     rownum =1;
		End if;

        	/*  fix oel.ato_line_id = pLineId to bcol.parent_ato_line_id = pLineId
        	pLineId is the line id of child model while ato_line_id is the line_id of parent model.
        	For multi-level model where option is missing for child model , join of
        	oel.ato_line_id = pLineId will fail
        	E.g
        	   BILL			Line id 	ATO line Id 	Parent ATO line id

        	   M1			100		100		100
        	    ....M2		200		100		100
        	    ........OC1		300		100		200
        	    .........OI1	400		100		200
        	    .........OI2	500		100		200


        	So if OI2 is dropped , pLineId = 200 whereas ato_line_id = 100
        	The program will error out with NDF
        	*/


   		lStmtNum := 114;
   		IF PG_DEBUG <> 0 THEN
   		  oe_debug_pub.add('Select model.. ' ,1);
        	END IF;

        	select  substrb(concatenated_segments,1,50)
        	into    l_model
        	from    mtl_system_items_kfv
        	where   organization_id = lNextRec.organization_id
        	and     inventory_item_id = pModelId ;


        	lStmtNum := 117;
        	IF PG_DEBUG <> 0 THEN
        	  oe_debug_pub.add('Select Org.. ' ,1);
        	END IF;

        	select	organization_code
        	into 	lOrg_code
        	from 	mtl_parameters
        	where	organization_id = lNextRec.organization_id ;

               -- Bug Fix 519975

	       if ( v_option_num = 1 ) then
                  v_dropped_item_string := 'Option ' || v_option_num || ':  ' || v_missed_item || l_new_line ;
                  v_ac_message_string := ' Line ' || v_missed_line_number || ' ' || v_dropped_item_string ;
               else
                  v_sub_dropped_item_string := 'Option ' || v_option_num || ':  ' || v_missed_item || l_new_line ;
                  v_dropped_item_string := v_dropped_item_string || v_sub_dropped_item_string ;
                  v_ac_message_string :=  v_ac_message_string || ' Line ' || v_missed_line_number || ' ' || v_sub_dropped_item_string ;
               end if ;


		-- Bug Fix 519975

        	if ( lcreate_item = 1 ) then
        	  IF PG_DEBUG <> 0 THEN
       		    oe_debug_pub.add ('Warning: The component '||v_missed_item
                        	|| ' on Line Number '||v_missed_line_number
                        	|| ' in organization ' || lOrg_code
                        	|| ' was not included in the configured item''s bill. ',1);
       		    oe_debug_pub.add ('Model Name : '||l_model,1);
       		    oe_debug_pub.add ('Order Number : '||v_order_number,1);
       		  END IF;
		  -- Bug fix 5199775. Commented the following error message
		  -- as we will be raising one message for all components
/*

       		  l_token(1).token_name  := 'OPTION_NAME';
                  l_token(1).token_value := l_missed_item;
                  l_token(2).token_name  := 'LINE_ID';
                  l_token(2).token_value := l_missed_line_number;
                  l_token(3).token_name  := 'ORG_CODE';
                  l_token(3).token_value := lOrg_code ;
                  l_token(4).token_name  := 'MODEL_NAME';
                  l_token(4).token_value := l_model;
                  l_token(5).token_name  := 'ORDER_NUMBER';
                  l_token(5).token_value := l_order_number;

    	          cto_msg_pub.cto_message('BOM','CTO_DROP_ITEM_FROM_CONFIG',l_token);
    	       */
    	        else
    	          IF PG_DEBUG <> 0 THEN
    	            oe_debug_pub.add ('Warning: The configured item was not created because component '||v_missed_item
                        	|| ' on Line Number '||v_missed_line_number
                        	|| ' in organization ' || lOrg_code
                        	|| '  could not be included in the configured item''s bill. ',1);
       		    oe_debug_pub.add ('Model Name : '||l_model,1);
       		    oe_debug_pub.add ('Order Number : '||v_order_number,1);
       		  END IF;

		 -- Bug Fix 5199775

		/*
       		  l_token(1).token_name  := 'OPTION_NAME';
                  l_token(1).token_value := l_missed_item;
                  l_token(2).token_name  := 'LINE_ID';
                  l_token(2).token_value := l_missed_line_number;
                  l_token(3).token_name  := 'ORG_CODE';
                  l_token(3).token_value := lOrg_code ;
                  l_token(4).token_name  := 'MODEL_NAME';
                  l_token(4).token_value := l_model;
                  l_token(5).token_name  := 'ORDER_NUMBER';
                  l_token(5).token_value := l_order_number;

    	          cto_msg_pub.cto_message('BOM','CTO_DO_NOT_CREATE_ITEM',l_token);
		  */

    	        end if;
    	        -- end new message fix 2986192


       		EXCEPTION			/* exception for stmt 113 ,114 and 117*/

     	        when others then
     	          IF PG_DEBUG <> 0 THEN
                    oe_debug_pub.add('Others excepn from stmt '||lStmtNum ||':'||sqlerrm);
            	  END IF;
            	  raise fnd_api.g_exc_error;
    	        END ;

             end loop;
/* Fixed by Renga Kannan for bug 5199775

    	     if mismatched_items%ROWCOUNT > 0 then

    	    	 CTO_CONFIG_BOM_PK.gDropItem := 0;

    	     	 lStmtNum := 115;


    	     	if ( lcreate_item = 1)  then
    	     	  IF PG_DEBUG <> 0 THEN
    	       	    oe_debug_pub.add ('Setting the global var gApplyHold to Y');
     	       	  END IF;
     	       	    CTO_CONFIG_BOM_PK.gApplyHold := 'Y';





     	     	else
     	     	  IF PG_DEBUG <> 0 THEN
     	       	    oe_debug_pub.add ('Not creating Item...');
     	       	  END IF;

  		  -- rkaza. 08/25/2005. bug 4315973.
                  -- Applying hold even for dropped item cases when config bom
                  -- exists and profile set to not create item.

             	  cto_utility_pk.apply_create_config_hold( l_ato_line_id, l_header_id, xReturnStatus, xMsgCount, xMsgData ) ;

		  -- pop up message that model is put on hold.
		  cto_msg_pub.cto_message('BOM','CTO_MODEL_LINE_EXCPN_HOLD');

     	       	  raise fnd_api.g_exc_error;

     	     	end if;

    	      end if;
*/

    if( v_program_id = CTO_UTILITY_PK.PC_BOM_PROGRAM_ID ) then
          IF PG_DEBUG <> 0 THEN
    	     oe_debug_pub.add ('Will not go through Hold Logic and Notification as Preconfigured Bom' , 1 );
          END IF;
          if mismatched_items%ROWCOUNT > 0 then
             if ( lcreate_item = 1 ) then
                IF PG_DEBUG <> 0 THEN
    	       oe_debug_pub.add ('Create Item profile set to Create and Link Item ' , 1 );
	    END IF;

  	    lxMessageName  := 'CTO_DROP_ITEM_FROM_CONFIG';

                select segment1
                into v_problem_model
                from mtl_system_items
                where inventory_item_id = pModelId
                and rownum = 1 ;

                select segment1
                 into v_problem_config
                 from mtl_system_items
                 where inventory_item_id = pConfigId
                 and rownum = 1 ;

                select organization_name
                into v_error_org
                 from inv_organization_name_v
                 where organization_id = lNextRec.organization_id ;

                v_problem_model_line_num := ' -1 ' ;

               v_table_count := CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE.count + 1 ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).PROCESS := 'NOTIFY_OID_IC' ;  /* ITEM CREATED */
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).LINE_ID               := pLineId ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).SALES_ORDER_NUM       := null ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).ERROR_MESSAGE         := v_dropped_item_string ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).TOP_MODEL_NAME        := null ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).TOP_MODEL_LINE_NUM    := null ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).TOP_CONFIG_NAME       := null ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).TOP_CONFIG_LINE_NUM   := null ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).PROBLEM_MODEL         := v_problem_model ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).PROBLEM_MODEL_LINE_NUM := v_problem_model_line_num ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).PROBLEM_CONFIG         := v_problem_config ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).ERROR_ORG              := v_error_org ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).ERROR_ORG_ID           := lNextRec.organization_id ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).MFG_REL_DATE           := lEstRelDate ;

               IF PG_DEBUG <> 0 THEN
    	             oe_debug_pub.add ('CTOCBOMB: REQUEST ID : ' || fnd_global.conc_request_id , 1 );
	  END IF;

               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).REQUEST_ID             := to_char( fnd_global.conc_request_id ) ;

             else /* lcreate_item <> 1 */

               IF PG_DEBUG <> 0 THEN
    	      oe_debug_pub.add ('Create Item profile set to Do Not Create Item ' , 1 );
	   END IF;

	   lxMessageName  := 'CTO_DO_NOT_CREATE_ITEM';

               select segment1
               into v_problem_model
               from mtl_system_items
               where inventory_item_id = pModelId
               and rownum = 1 ;

               select segment1
               into v_problem_config
               from mtl_system_items
               where inventory_item_id = pConfigId
               and rownum = 1 ;

               select organization_name
               into v_error_org
               from inv_organization_name_v
               where organization_id = lNextRec.organization_id ;


               v_problem_model_line_num := ' -1 ' ;


               v_table_count := CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE.count + 1 ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).PROCESS := 'NOTIFY_OID_INC' ;  /* ITEM NOT CREATED */
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).LINE_ID               := pLineId ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).SALES_ORDER_NUM       := null ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).ERROR_MESSAGE         := v_dropped_item_string ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).TOP_MODEL_NAME        := null ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).TOP_MODEL_LINE_NUM    := null ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).TOP_CONFIG_NAME       := null ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).TOP_CONFIG_LINE_NUM   := null ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).PROBLEM_MODEL         := v_problem_model ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).PROBLEM_MODEL_LINE_NUM := v_problem_model_line_num ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).PROBLEM_CONFIG         := v_problem_config ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).ERROR_ORG              := v_error_org ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).ERROR_ORG_ID           := lNextRec.organization_id ;
               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).MFG_REL_DATE           := lEstRelDate  ;

               IF PG_DEBUG <> 0 THEN
                     oe_debug_pub.add ('CTOCBOMB: REQUEST ID : ' || fnd_global.conc_request_id , 1 );
               END IF;

               CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).REQUEST_ID             := to_char( fnd_global.conc_request_id ) ;



     	   raise fnd_api.g_exc_error;

             end if; /* lcreate_item = 1 */

          end if; /*mismatched_items%ROWCOUNT > 0  */

    else  /* v_program_id <> CTO_UTILITY_PK.PC_BOM_PROGRAM_ID  */
       if mismatched_items%ROWCOUNT > 0 then
          CTO_CONFIG_BOM_PK.gDropItem := 0;

          lStmtNum := 55;
          if ( lcreate_item = 1 ) then
             IF PG_DEBUG <> 0 THEN
    	     oe_debug_pub.add ('Setting the global var gApplyHold to Y');
	 END IF;

	 CTO_CONFIG_BOM_PK.gApplyHold := 'Y';
             select segment1
             into v_problem_model
             from mtl_system_items
             where inventory_item_id = pModelId
             and rownum = 1 ;

            select segment1
            into v_problem_config
            from mtl_system_items
            where inventory_item_id = pConfigId
            and rownum = 1 ;

            select organization_name
            into v_error_org
            from inv_organization_name_v
            where organization_id = lNextRec.organization_id ;

            if( v_program_id = CTO_UTILITY_PK.PC_BOM_PROGRAM_ID ) then
               v_problem_model_line_num := ' -1 ' ;
           else
             select oel.line_number || '.' || oel.shipment_number
             into v_problem_model_line_num
             from oe_order_lines_all oel
             where line_id = pLineId ;
           end if;
           oe_debug_pub.add( ' DROPPED ITEM INFO: ' ||
                            ' Problem Model ' || v_problem_model ||
                            ' Problem CONFIG ' || v_problem_config ||
                            ' ERROR ORG ' || v_error_org  ||
                            ' PROBLEM MODEL LINE NUM ' || v_problem_model_line_num
                            , 1 ) ;

           v_table_count := CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE.count + 1 ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).PROCESS := 'NOTIFY_OID_IC' ;  /* ITEM CREATED */
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).LINE_ID               := pLineId ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).SALES_ORDER_NUM       := null ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).ERROR_MESSAGE         := v_dropped_item_string ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).TOP_MODEL_NAME        := null ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).TOP_MODEL_LINE_NUM    := null ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).TOP_CONFIG_NAME       := null ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).TOP_CONFIG_LINE_NUM   := null ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).PROBLEM_MODEL         := v_problem_model ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).PROBLEM_MODEL_LINE_NUM := v_problem_model_line_num ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).PROBLEM_CONFIG         := v_problem_config ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).ERROR_ORG              := v_error_org ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).ERROR_ORG_ID           := lNextRec.organization_id ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).MFG_REL_DATE           := lEstRelDate ;

           IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add ('CTOCBOMB: REQUEST ID : ' || fnd_global.conc_request_id , 1 );
           END IF;

           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).REQUEST_ID             := to_char(fnd_global.conc_request_id) ;

           IF PG_DEBUG <> 0 THEN
             oe_debug_pub.add('create_bom_ml: ' || 'Getting Custom Recipient..',3);
           END IF;

           v_recipient := CTO_CUSTOM_NOTIFY_PK.get_recipient( p_error_type        => CTO_UTILITY_PK.OPT_DROP_AND_ITEM_CREATED
                                             ,p_inventory_item_id => pModelId
                                             ,p_organization_id   => lNextRec.organization_id
                                             ,p_line_id           => pLineId   );




           if( v_recipient is not null ) then
              IF PG_DEBUG <> 0 THEN
                 oe_debug_pub.add('create_bom_ml: ' || 'Recipient returned from CTO_CUSTOM_NOTIFY_PK..' || v_recipient ,3);
              END IF;

              CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).NOTIFY_USER             := v_recipient ;  /* commented 'MFG' */

          else
              IF PG_DEBUG <> 0 THEN
                 oe_debug_pub.add('create_bom_ml: ' || 'Recipient returned from CTO_CUSTOM_NOTIFY_PK is null ..' , 3);
                 oe_debug_pub.add('create_bom_ml: ' || 'Getting the planner code ..',3);
              END IF;

              BEGIN
                 SELECT  u.user_name
                   INTO   lplanner_code
                   FROM   mtl_system_items_vl item
                         ,mtl_planners p
                         ,fnd_user u
                  WHERE item.inventory_item_id = pModelId
                  and   item.organization_id   = lNextRec.organization_id
                  and   p.organization_id = item.organization_id
                  and   p.planner_code = item.planner_code
                  and   p.employee_id = u.employee_id(+);         --outer join b'cos employee need not be an fnd user.
                  oe_debug_pub.add('create_bom_ml: ' || '****PLANNER CODE DATA' || lplanner_code ,2);
              EXCEPTION
              WHEN OTHERS THEN
                   IF PG_DEBUG <> 0 THEN
                      oe_debug_pub.add('create_bom_ml: ' || 'Error in getting the planner code data. Defaulting to SYSADMIN.',2);

                      oe_debug_pub.add('create_bom_ml: ' || 'Error Message : '||sqlerrm,2);


                   END IF;
              END;



              CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).NOTIFY_USER             := lplanner_code ;  /* commented 'MFG' */

          end if; /* check custom recipient */
           l_token(1).token_name  := 'ORDER_NUM';
           l_token(1).token_value := v_order_number;
           l_token(2).token_name  := 'ORG';
           l_token(2).token_value := v_error_org;
           l_token(3).token_name  := 'CONFIG_NAME';
           l_token(3).token_value := v_problem_config;
           l_token(4).token_name  := 'ERROR_MESSAGE';
           l_token(4).token_value := v_ac_message_string ;
           cto_msg_pub.cto_message('BOM','CTO_DROP_ITEM_FROM_CONFIG',l_token);


        else

           IF PG_DEBUG <> 0 THEN
	    oe_debug_pub.add ('Not creating Item...');
           END IF;
           select segment1
           into v_problem_model
           from mtl_system_items
           where inventory_item_id = pModelId
           and rownum = 1 ;

           select segment1
           into v_problem_config
           from mtl_system_items
           where inventory_item_id = pConfigId
           and rownum = 1 ;
           select organization_name
           into v_error_org
           from inv_organization_name_v
           where organization_id = lNextRec.organization_id ;


           select oel.line_number || '.' || oel.shipment_number
           into v_problem_model_line_num
           from oe_order_lines_all oel
           where line_id = pLineId ;
           v_table_count := CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE.count + 1 ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).PROCESS := 'NOTIFY_OID_INC' ;  /* ITEM NOT CREATED */
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).LINE_ID               := pLineId ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).SALES_ORDER_NUM       := null ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).ERROR_MESSAGE         := v_dropped_item_string ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).TOP_MODEL_NAME        := null ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).TOP_MODEL_LINE_NUM    := null ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).TOP_CONFIG_NAME       := null ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).TOP_CONFIG_LINE_NUM   := null ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).PROBLEM_MODEL         := v_problem_model ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).PROBLEM_MODEL_LINE_NUM := v_problem_model_line_num ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).PROBLEM_CONFIG         := v_problem_config ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).ERROR_ORG              := v_error_org ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).ERROR_ORG_ID           := lNextRec.organization_id ;
           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).MFG_REL_DATE           := lEstRelDate ;

           IF PG_DEBUG <> 0 THEN
                     oe_debug_pub.add ('CTOCBOMB: REQUEST ID : ' || fnd_global.conc_request_id , 1 );
           END IF;

           CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).REQUEST_ID             := to_char( fnd_global.conc_request_id ) ;

           IF PG_DEBUG <> 0 THEN
             oe_debug_pub.add('create_bom_ml: ' || 'Getting Custom Recipient..',3);
           END IF;

           v_recipient := CTO_CUSTOM_NOTIFY_PK.get_recipient( p_error_type        => CTO_UTILITY_PK.OPT_DROP_AND_ITEM_NOT_CREATED
                                                            ,p_inventory_item_id => pModelId
                                                            ,p_organization_id   => lNextRec.organization_id
                                                            ,p_line_id           => pLineId   );




          if( v_recipient is not null ) then
              IF PG_DEBUG <> 0 THEN
                 oe_debug_pub.add('create_bom_ml: ' || 'Recipient returned from CTO_CUSTOM_NOTIFY_PK..' || v_recipient ,3);
              END IF;

              CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).NOTIFY_USER             := v_recipient ;  /* commented 'MFG' */

          else

             IF PG_DEBUG <> 0 THEN
                 oe_debug_pub.add('create_bom_ml: ' || 'Recipient returned from CTO_CUSTOM_NOTIFY_PK is null ..' , 3);
                 oe_debug_pub.add('create_bom_ml: ' || 'Getting the planner code ..',3);
             END IF;

             BEGIN
                SELECT  u.user_name
                INTO  lplanner_code
                FROM  mtl_system_items_vl item
                          ,mtl_planners p
                          ,fnd_user u
                WHERE item.inventory_item_id = pModelId
                and   item.organization_id   = lNextRec.organization_id
                and   p.organization_id = item.organization_id
                and   p.planner_code = item.planner_code
                and   p.employee_id = u.employee_id(+);         --outer join b'cos employee need not be an fnd user.


                oe_debug_pub.add('create_bom_ml: ' || '****PLANNER CODE DATA' || lplanner_code ,2);


             EXCEPTION
              WHEN OTHERS THEN
                   IF PG_DEBUG <> 0 THEN
                      oe_debug_pub.add('create_bom_ml: ' || 'Error in getting the planner code data. Defaulting to SYSADMIN.',2);

                      oe_debug_pub.add('create_bom_ml: ' || 'Error Message : '||sqlerrm,2);


                   END IF;
             END;

              CTO_CONFIG_BOM_PK.G_T_DROPPED_ITEM_TYPE(v_table_count).NOTIFY_USER             := lplanner_code ;  /* commented 'MFG' */

          end if; /* check custom recipient */



          -- rkaza. bug 4315973. 08/24/2005.
          -- Hold ato line for dropped items when profile is set to do not
          -- create item. Removed aps_version restriction.

          oe_debug_pub.add('create_bom_ml: ' || 'fetching information for apply hold on lineid '|| to_char(pLineId) ,2);
          oe_debug_pub.add('create_bom_ml: ' || 'going to apply hold on lineid '|| to_char(pLineId) ,2);

          cto_utility_pk.apply_create_config_hold( l_ato_line_id, l_header_id, xReturnStatus, xMsgCount, xMsgData ) ;


               l_token(1).token_name  := 'ORDER_NUM';
               l_token(1).token_value := v_order_number;
               l_token(2).token_name  := 'CONFIG_NAME';
               l_token(2).token_value := v_problem_config;
               l_token(3).token_name  := 'ORG';
               l_token(3).token_value := v_error_org;
               l_token(4).token_name  := 'ERROR_MESSAGE';
               l_token(4).token_value := v_ac_message_string ;

               cto_msg_pub.cto_message('BOM','CTO_DO_NOT_CREATE_ITEM',l_token);

	       -- Bugfix 4084568: Adding message for model line on Hold.

               cto_msg_pub.cto_message('BOM','CTO_MODEL_LINE_EXCPN_HOLD');



     	  raise fnd_api.g_exc_error;

     	end if; /* create item profile condition */

    end if; /* missed lines cursor condition */

    end if; /* Preconfigure / Autoconfigure condition */

     	     close mismatched_items;

     	     lStmtNum := 116;

             -- 3543547 Replace lItmBillId with lComItmBillId
             delete from bom_inventory_comps_interface
             where  bill_sequence_id =   lComItmBillId
             and batch_id = cto_msutil_pub.bom_batch_id;

	     lCnt := sql%rowcount;
             IF PG_DEBUG <> 0 THEN
	       oe_debug_pub.add('Deleted from bici, rows::'||lCnt);
	     END IF;

	     --Bugfix 11056452
             delete from bom_bill_of_mtls_interface
             where bill_sequence_id = lComItmBillId
             and batch_id = cto_msutil_pub.bom_batch_id;

	     lCnt := sql%rowcount;
             IF PG_DEBUG <> 0 THEN
	       oe_debug_pub.add('Deleted from bmi, rows::'||lCnt);
	     END IF;


     	     EXCEPTION			/* exception for stmt 112 , 115 and 116 */

     	     when others then
     	        IF PG_DEBUG <> 0 THEN
     		  oe_debug_pub.add ('Failed in stmt ' || lStmtNum || ' with error: '||sqlerrm);
            	END IF;
            	raise fnd_api.g_exc_error;
    	     END ;

    	     /* Bugfix 2986192 ends here */



           else


               lStmtNum := 125;
               lStatus := CTO_CONFIG_BOM_PK.create_bom_ml(
						pModelId	=> pModelId,
                                                pConfigId	=> pConfigId,
                                                pOrgId		=> lNextRec.organization_id,
                                                pLineId		=> pLineId,
                                                xBillId		=> lCfgBillId,
                                                xErrorMessage	=> lXErrorMessage,
                                                xMessageName	=> lXMessageName,
                                                xTableName	=> lXTableName);






               IF PG_DEBUG <> 0 THEN
               	oe_debug_pub.add('create_in_src_orgs: '
                                || 'Returned from Create_bom_ml with status: '
                                || to_char(lStatus), 1);
               END IF;

               if (lStatus <> 1) then

                   /*----------------------------+
                      BOM Creation failed
                   +----------------------------*/
                   IF PG_DEBUG <> 0 THEN
                   	oe_debug_pub.add('create_in_src_orgs: ' || ' Failed in Create_bom.', 1);
                   END IF;

                   /* Clean up bom_inventory_comps_interface  */
                   delete from bom_inventory_comps_interface
                   where  bill_sequence_id = lCfgBillId;

		   lCnt := sql%rowcount;
                   IF PG_DEBUG <> 0 THEN
                     oe_debug_pub.add('Deleted from bici, rows::'||lCnt);
		   END IF;

		   --Bugfix 11056452
                   delete from bom_bill_of_mtls_interface
                   where bill_sequence_id = lCfgBillId;

		   lCnt := sql%rowcount;
                   IF PG_DEBUG <> 0 THEN
                     oe_debug_pub.add('Deleted from bmi, rows::'||lCnt);
		   END IF;


                   if( lStatus = -1) then  /* add a message for unexpected errors(-1), expected errors(0) already have a message */
                       cto_msg_pub.cto_message('BOM', 'CTO_CREATE_BOM_ERROR');
                   end if;

                   raise fnd_api.g_exc_error;

               end if;





               v_bom_created := v_bom_created + 1 ;  /* increment bom created variable */



               lStmtNum := 130;
               lStatus := CTO_CONFIG_ROUTING_PK.create_routing_ml(
                                                pModelId	=> pModelId ,
                                                pConfigId	=> pConfigId,
                                                pCfgBillId	=> lCfgBillId,
                                                pOrgId		=> lNextRec.organization_id,
                                                pLineId		=> pLineId,
                                                pFlowCalc	=> pFlowCalc,
                                                xRtgId		=> lCfgRtgId,
                                                xErrorMessage	=> lXErrorMessage,
                                                xMessageName	=> lXMessageName,
                                                xTableName	=> lXTableName   );

               IF PG_DEBUG <> 0 THEN
               	oe_debug_pub.add('create_in_src_orgs: '
                                || 'Returned from Create_routing_ml with status: '
                                || to_char(lStatus), 1);
               END IF;


               if (lStatus <> 1) then

                   /*----------------------------+
                      Routing Creation failed
                   +----------------------------*/
                   IF PG_DEBUG <> 0 THEN
                   	oe_debug_pub.add('create_in_src_orgs: ' || ' Failed in create_routing.');
                   END IF;

                   /* Clean up bom_inventory_comps_interface  */
                   delete from bom_inventory_comps_interface
                   where  bill_sequence_id = lCfgBillId;

		   lCnt := sql%rowcount;
                   IF PG_DEBUG <> 0 THEN
                     oe_debug_pub.add('Deleted from bici, rows::'||lCnt);
		   END IF;

		   --Bugfix 11056452
                   delete from bom_bill_of_mtls_interface
                   where bill_sequence_id = lCfgBillId;

		   lCnt := sql%rowcount;
                   IF PG_DEBUG <> 0 THEN
                     oe_debug_pub.add('Deleted from bmi, rows::'||lCnt);
		   END IF;

                   cto_msg_pub.cto_message('BOM', 'CTO_CREATE_ROUTING_ERROR');
                   raise fnd_api.g_exc_error;

               end if;


               if (lCfgBillId > 0)  then
                   lStmtNum := 135;
                   lStatus := CTO_CONFIG_BOM_PK.create_bom_data_ml(
                                                pModelId,
                                                pConfigId,
                                                lNextRec.organization_id,
                                                lCfgBillId,
                                                lXErrorMessage,
                                                lXMessageName,
                                                lXTableName);

                   IF PG_DEBUG <> 0 THEN
                   	oe_debug_pub.add('create_in_src_orgs: '
                                || 'Returned from Create_bom with status: '
                                || to_char(lStatus), 1);
                   END IF;

                   if (lStatus <> 1) then

                         IF PG_DEBUG <> 0 THEN
                         	oe_debug_pub.add('create_in_src_orgs: '
                                 || ' Failed in Create_bom_data', 1);
                         END IF;

                   /* Clean up bom_inventory_comps_interface  */
                   delete from bom_inventory_comps_interface
                   where  bill_sequence_id = lCfgBillId;

		   lCnt := sql%rowcount;
                   IF PG_DEBUG <> 0 THEN
                     oe_debug_pub.add('Deleted from bici, rows::'||lCnt);
		   END IF;

		   --Bugfix 11056452
                   delete from bom_bill_of_mtls_interface
                   where bill_sequence_id = lCfgBillId;

		   lCnt := sql%rowcount;
                   IF PG_DEBUG <> 0 THEN
                     oe_debug_pub.add('Deleted from bmi, rows::'||lCnt);
		   END IF;

                       if( lXMessageName is not null ) then
                            xMsgData := lXMessageName ;
                         -- cto_msg_pub.cto_message('BOM', lXMessageName );
                       else
                         cto_msg_pub.cto_message('BOM', 'CTO_CREATE_BOM_ERROR');
                       end if;




                         IF PG_DEBUG <> 0 THEN
                         	oe_debug_pub.add('added club_comp_error ' , 1) ;
                         end if ;

                       raise fnd_api.g_exc_error;

                   end if;

               end if;  -- end lCfgBillId > 0


           end if; -- end check config bom

       else
             -- Added by Renga Kannan to handle the exception
             IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('create_in_src_orgs: '
                          || 'There is no bill for this model in this org',1);

        	oe_debug_pub.add('create_in_src_orgs: '
                          || 'Model id :'||to_char(pModelId),1);
                oe_debug_pub.add('Org id   ;'||to_char(lNextRec.organization_id),1);
             END IF;

            /*



             ** Warning **

             ** Achtung **

             ** Model BOM does not exist should not be treated as an error
             **
             ** Case: Specific Org
             **       BOM is created only in the end manufacturing org
             **
             ** Case: All Org
             **       BOM is created in all orgs where the model bom exists
             **
             **       In either case the error will be caught if the bom
             **       was not created even in a single org.


             cto_msg_pub.cto_message('BOM','CTO_BOM_NOT_DEFINED');
             -- bugfix 2294708: Replaced msg CTO_CREATE_BOM_ERROR with more specific
             -- error CTO_BOM_NOT_DEFINED.

             raise fnd_api.g_exc_error;





             */



       end if; -- end check model bom


      else /* create_config_bom = 'N' */

             IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('create_in_src_orgs: '
                          || 'create_config_bom parameter is set to N in this org',1);

                oe_debug_pub.add('create_in_src_orgs: '
                          || 'Model id :'||to_char(pModelId),1);
                oe_debug_pub.add('Org id   ;'||to_char(lNextRec.organization_id),1);
             END IF;

             -- bugfix 2294708: Replaced msg CTO_CREATE_BOM_ERROR with more specific
             -- error CTO_BOM_NOT_DEFINED.




      end if ;


   end loop;


   if( v_bom_created = 0 and v_config_bom_exists = 0 ) then

        select concatenated_segments into v_model_item_name
          from mtl_system_items_kfv
        where inventory_item_id = pModelId
          and rownum = 1 ;


       l_token1(1).token_name  := 'MODEL_NAME';
       l_token1(1).token_value := v_model_item_name ;

       cto_msg_pub.cto_message('BOM','CTO_NO_BOM_CREATED_IN_ANY_ORGS', l_token1 );  -- Bug 3349142
       raise fnd_api.g_exc_error;

   end if ;




   cto_msg_pub.count_and_get
          (  p_msg_count => xMsgCount
           , p_msg_data  => xMsgData
           );


EXCEPTION

   WHEN fnd_api.g_exc_error THEN
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('create_in_src_orgs: '
                  || 'expected error::'||to_char(lStmtNum)||'::'||sqlerrm, 1);
	END IF;

        xReturnStatus := fnd_api.g_ret_sts_unexp_error;
        --  Get message count and data
        xReturnStatus := fnd_api.g_ret_sts_error;
        --  Get message count and data


        cto_msg_pub.count_and_get
          (  p_msg_count => xMsgCount
           , p_msg_data  => xMsgData
           );

        IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('create_in_src_orgs: ' || xMsgData , 1   ) ;
                oe_debug_pub.add('create_in_src_orgs: ' || xMsgCount , 1 ) ;

        END IF;

   WHEN fnd_api.g_exc_unexpected_error THEN


        xReturnStatus := fnd_api.g_ret_sts_unexp_error ;
        --  Get message count and data


        cto_msg_pub.count_and_get
          (  p_msg_count  => xMsgCount
           , p_msg_data   => xMsgData
            );

   WHEN OTHERS then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('create_in_src_orgs: '
                              || 'create_in_src_orgs::others::'||to_char(lStmtNum)
                              ||'::'||sqlerrm, 1);
	END IF;

        xReturnStatus := fnd_api.g_ret_sts_unexp_error;
        --  Get message count and data

        cto_msg_pub.count_and_get
          (  p_msg_count  => xMsgCount
           , p_msg_data   => xMsgData
             );


END create_in_src_orgs;



/*------------------------------------------------+
   This function is to send new information to
   ATP after the config BOM has been created
+------------------------------------------------*/

function update_atp( pLineId       in   number,
                     xErrorMessage out   NOCOPY varchar2,
                     xMessageName  out   NOCOPY varchar2,
                     xTableName    out   NOCOPY varchar2)
return integer
is

  p_atp_table             MRP_ATP_PUB.ATP_Rec_Typ;
  l_smc_table             MRP_ATP_PUB.ATP_Rec_Typ;
  l_instance_id           integer := -1;
  l_session_id            number := 101;
  l_atp_table             MRP_ATP_PUB.ATP_Rec_Typ;
  l_atp_supply_demand     MRP_ATP_PUB.ATP_Supply_Demand_Typ;
  l_atp_period            MRP_ATP_PUB.ATP_Period_Typ;
  l_atp_details           MRP_ATP_PUB.ATP_Details_Typ;

  l_return_status         VARCHAR2(1);
  l_msg_count             number;
  l_msg_data              varchar2(200);

  atp_error   exception;

  lStatus      varchar2(1);
  lStmt        number;
  i            number;
  temp         number  := null;
  temp1        date    := null;

begin
   /*-----------------------------------------------------+
      Prepare initial input record for atp
      Copy model row information to p_atp_table
      Although, we are still using model and options info
      in oe_order_lines, call to get_bom_mandatory_comps
      will ensure that we get the latest picture of
      mandatory comps.
      This has changed to make a call to
      bom_mandatory_components instead.
   +-----------------------------------------------------*/

       lStmt := 50;
    select oel.inventory_item_id,
           oel.ship_from_org_id,
           oel.line_id,
           oel.ordered_quantity,
           oel.order_quantity_uom,
           oel.request_date,
           oel.demand_class_code,
           temp,      -- calling module
           temp,      -- customer_id
           temp,      -- customer_site_id
           temp,      -- destination_time_zone
           oel.schedule_arrival_date,
           temp1,     -- latest acceptable_date
           oel.delivery_lead_time,      -- delivery lead time
           temp,      -- Freight_Carrier
           temp,      -- Ship_Method
           temp,      --Ship_Set_Name
           temp,      -- Arrival_Set_Name
           1,         -- Override_Flag
           temp,      -- Action
           temp1,     -- Ship_date
           temp,      -- available_quantity
           temp,      -- requested_date_quantity
           temp1,     -- group_ship_date
           temp1,     -- group_arrival_date
           temp,      -- vendor_id
           temp,      -- vendor_site_id
           temp,      -- insert_flag
           temp,      -- error_code
           temp       -- Message
      bulk collect into
           p_atp_table.Inventory_Item_Id       ,
           p_atp_table.Source_Organization_Id  ,
           p_atp_table.Identifier              ,
           p_atp_table.Quantity_Ordered        ,
           p_atp_table.Quantity_UOM            ,
           p_atp_table.Requested_Ship_Date     ,
           p_atp_table.Demand_Class            ,
           p_atp_table.Calling_Module          ,
           p_atp_table.Customer_Id             ,
           p_atp_table.Customer_Site_Id        ,
           p_atp_table.Destination_Time_Zone   ,
           p_atp_table.Requested_Arrival_Date  ,
           p_atp_table.Latest_Acceptable_Date  ,
           p_atp_table.Delivery_Lead_Time      ,
           p_atp_table.Freight_Carrier         ,
           p_atp_table.Ship_Method             ,
           p_atp_table.Ship_Set_Name           ,
           p_atp_table.Arrival_Set_Name        ,
           p_atp_table.Override_Flag           ,
           p_atp_table.Action                  ,
           p_atp_table.Ship_Date               ,
           p_atp_table.Available_Quantity      ,
           p_atp_table.Requested_Date_Quantity ,
           p_atp_table.Group_Ship_Date         ,
           p_atp_table.Group_Arrival_Date      ,
           p_atp_table.Vendor_Id               ,
           p_atp_table.Vendor_Site_Id          ,
           p_atp_table.Insert_Flag             ,
           p_atp_table.Error_Code              ,
           p_atp_table.Message
   from  oe_order_lines_all  oel,
         oe_order_lines_all  oel1,
	 mtl_system_items    msi
   where msi.inventory_item_id = oel.inventory_item_id
   and msi.organization_id = oel.ship_from_org_id
   and msi.bom_item_type = 1
   and   oel.line_id             = pLineId
   --and   oel.item_type_code      = 'MODEL'
   and   oel1.item_type_code     = 'CONFIG'
   --and   oel1.top_model_line_id  = pLineId
   and   oel1.ato_line_id  = pLineId
   and   oel1.link_to_line_id    = pLineId
   and   oel1.ordered_quantity   > 0 ;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('update_atp: ' || ' Line Id '      || p_atp_table.identifier(1));

   	oe_debug_pub.add('update_atp: ' || ' Inventory Id ' || p_atp_table.inventory_item_id(1));

   	oe_debug_pub.add('update_atp: ' || ' Req Date   '   || p_atp_table.requested_ship_date(1));

   	oe_debug_pub.add('update_atp: ' || '  qty       '   || p_atp_table.quantity_ordered(1));
   END IF;


    /*--------------------------------------+
        Get Mandatory components
    +--------------------------------------*/

/*  lstatus := cto_config_item_pk.get_Bom_Mandatory_comps(
                                  p_atp_table      ,
                                  l_smc_table      ,
                                  xErrorMessage    ,
                                  xMessageName     ,
                                  xTableName       );
*/

    lstatus := cto_config_item_pk.Get_Mandatory_Components(
         	    p_atp_table, --p_ship_set in MRP_ATP_PUB.ATP_Rec_Typ
		    null, --p_organization_id in number default null (passing null because OM)
		    null, --p_inventory_item_id in number default null (passing null because OM)
                    l_smc_table, --p_sm_rec out MRP_ATP_PUB.ATP_Rec_Typ
         	    xErrorMessage,
         	    xMessageName,
         	    xTableName );


   i := l_smc_table.inventory_item_id.FIRST;

   if i is not null then

            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('update_atp: ' ||  'From output record ---> ',1);
            END IF;

            while i is  not null
            loop

               IF PG_DEBUG <> 0 THEN
               	oe_debug_pub.add('update_atp: ' || ' Line Id '
                      || l_smc_table.identifier(i));

               	oe_debug_pub.add('update_atp: ' || ' Inventory Id '
                      || l_smc_table.inventory_item_id(i));

               	oe_debug_pub.add('update_atp: ' || ' Req Date   '
                      || l_smc_table.requested_ship_date(i));

               	oe_debug_pub.add('update_atp: ' || '  qty       '
                      || l_smc_table.quantity_ordered(i));
               END IF;

               i := l_smc_table.inventory_item_id.NEXT(i);
             end loop;

             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('update_atp: ' ||  'Calling ATP  ---> ',1);
             END IF;

             /*----------------------------+
                Call ATP
             +----------------------------*/

             MRP_ATP_PUB.Call_ATP(
                 l_session_id,
                 l_smc_table,
                 l_atp_table,
                 l_atp_supply_demand,
                 l_atp_period,
                 l_atp_details,
                 l_return_status,
                 l_msg_data,
                 l_msg_count);

             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('update_atp: ' || 'ATP returned ' || l_return_status);
             END IF;

             IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
                  or l_return_status = FND_API.G_RET_STS_ERROR ) then
                  raise atp_error;
             END IF;
   else
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('update_atp: ' || 'No Mandatory components for ATP found' );
             END IF;

   end if;

   return (1);


exception

    when atp_error then
        xErrormessage := 'update_atp:'||to_char(lStmt)||':'||' ATP API returned Error';
        xMessageName := 'CTO_CREATE_BOM_ERROR';
        return(0);

    when others then
        xErrorMessage := 'update_atp:'||to_char(lStmt)||':'||substrb(sqlerrm,1,150) ;
        xMessageName := 'CTO_CREATE_BOM_ERROR';
      return(0);

end update_atp;



FUNCTION is_item_transacted(  p_inventory_item_id NUMBER
                             , p_organization_id NUMBER
                             , p_cost_type_id  NUMBER )
 Return BOOLEAN IS
  Updateable VARCHAR2(10) := null ;
  RetVal   BOOLEAN;
  intransit_count NUMBER;

  Cursor Check_Updateable is
    Select 'YES'
    From  MTL_MATERIAL_TRANSACTIONS t
    Where Inventory_Item_Id = p_inventory_item_id
    And Exists
    (Select 'all these org have the org as costing org'
     From  MTL_PARAMETERS
     Where Cost_Organization_Id = p_organization_id
     AND Organization_Id = t.Organization_Id);

  Cursor Check_Updateable_2 is
    Select 'YES'
    From  MTL_MATERIAL_TRANSACTIONS_TEMP t
    Where Inventory_Item_Id = p_inventory_item_id
    And Exists
    (Select 'all these org have the org as costing org'
     From  MTL_PARAMETERS
     Where Cost_Organization_Id = p_organization_id
     AND Organization_Id = t.Organization_Id);

  BEGIN
    -- If we are dealing with a frozon cost type, it is only updateable when
    -- there does not exist any transactions.

    IF ( p_cost_type_id  = 1) THEN
      IF (Updateable is NULL) THEN
        Open Check_Updateable;
        Fetch Check_Updateable into Updateable;
        Close Check_Updateable;

        IF (Updateable is Null) THEN

          Open Check_Updateable_2;
          Fetch Check_Updateable_2 into Updateable;
          Close Check_Updateable_2;
        END IF;

        IF (Updateable is NULL) THEN

           select count(*)
           into intransit_count
           from mtl_supply m
           where m.item_id = p_inventory_item_id
           and m.intransit_owning_org_id = p_organization_id
           and m.to_organization_id = p_organization_id ;
           IF (intransit_count > 0) THEN
             Updateable := 'YES';
           END IF;
        END IF;

      END IF;
      IF (Updateable = 'YES') THEN
        -- fnd_message.Set_Name('BOM', 'CST_ITEM_USED_IN_TXN');
        RetVal := TRUE;
      ELSE
           IF PG_DEBUG <> 0 THEN
               oe_debug_pub.add( ' is_item_transacted is null -> true ' ) ;
           END IF;

        RetVal := FALSE ;
      END IF;

    ELSE
        IF PG_DEBUG <> 0 THEN
           oe_debug_pub.add( ' cost type id not 1 ' ) ;
        END IF;

      RetVal := FALSE ;
    END IF;

    IF PG_DEBUG <> 0 THEN

         if( RetVal = TRUE ) then
             oe_debug_pub.add( ' is_item_transacted is true ' ) ;
         elsif( RetVal = False ) then
             oe_debug_pub.add( ' is_item_transacted is false' ) ;
         elsif( RetVal is null ) then
             oe_debug_pub.add( ' is_item_transacted is null ' ) ;
         end if ;
    END IF;



    Return RetVal;



  END is_item_transacted ;







/*-------------------------------------------------------------+
  Name : override_bcso_cost_rollup_flag
         This procedure updates cost_rollup_flag in bcso to avoid cost rollup.
+-------------------------------------------------------------*/
procedure override_bcso_cost_rollup(
        pLineId         in  number, -- Current Model Line ID
        pModelId        in  number,
        pConfigId       in  number,
        p_cost_organization_id in number,
        p_organization_id      in number,
        p_group_reference_id   in number,
        xReturnStatus   out NOCOPY varchar2,
        xMsgCount       out NOCOPY number,
        xMsgData        out NOCOPY varchar2
        )

IS

   lStmtNum        number;
   lStatus         number;
   lItmBillId      number;
   lCfgBillId      number;
   lCfgRtgId       number;
   xBillId         number;
   lXErrorMessage  varchar2(100);
   lXMessageName   varchar2(100);
   lXTableName     varchar2(100);

   v_primary_cost_method mtl_parameters.primary_cost_method%type := null ;
   v_cto_cost            cst_item_costs.item_cost%type := null ;
   v_cto_cost_xudc       cst_item_costs.item_cost%type := null ;
   v_valuation_cost      cst_item_costs.item_cost%type := null ;
   v_buy_cost            cst_item_costs.item_cost%type := null ;

   v_organization_type   bom_cto_src_orgs.organization_type%type := null ;

  v_cto_cost_type_id     cst_item_costs.cost_type_id%type ;
  v_buy_cost_type_id     cst_item_costs.cost_type_id%type ;
  v_rolledup_cost_count   number ;
  v_rolledup_cost         number ;
  lBuyCostType            varchar2(30);

  v_item_transacted       boolean := FALSE ;

   l_missed_item_id             number;
   l_missed_item                varchar2(50);
   l_config_item                varchar2(50);
   l_model                      varchar2(50);
   l_missed_line_number         varchar2(50);
   l_order_number               number	:= 0;
   l_token			CTO_MSG_PUB.token_tbl;
   lcreate_item			number;
   lorg_code			varchar2(3);


   /* 2986190 End declaration */

BEGIN

   xReturnStatus := fnd_api.g_ret_sts_success;

   -- check if model bom exists in src org

       lStmtNum := 10;
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('create_in_src_orgs: ' || 'In create_in_src_orgs. Item: ' ||
                         to_char(pConfigId) || '. Costing Org ' ||			-- 3116778
			 to_char(p_cost_organization_id) || '. Source Org ' ||           -- 3116778
                         to_char(p_organization_id), 1);
       END IF;





       lStmtNum := 20;

       v_primary_cost_method := null ;
       v_cto_cost := null ;
       v_cto_cost_xudc := null ;
       v_valuation_cost := null ;
       v_buy_cost := null ;
       v_organization_type := null ;


       lStmtNum := 25;

       begin

       select mp1.primary_cost_method into v_primary_cost_method
       from mtl_parameters mp1
       where mp1.organization_id = p_cost_organization_id ;    -- 3116778

       exception

       when others then
            raise fnd_api.g_exc_error;

       end ;

       lStmtNum := 26;
        begin

            select cost_type_id into v_cto_cost_type_id
            from cst_cost_types
            where cost_type = 'CTO' ;




        exception
        when no_data_found then

           cto_msg_pub.cto_message('BOM','CTO_COST_NOT_FOUND');
           raise  FND_API.G_EXC_ERROR;

        when others then

           raise  FND_API.G_EXC_UNEXPECTED_ERROR;


        end;



       lStmtNum := 27;

        lBuyCostType := FND_PROFILE.VALUE('CTO_BUY_COST_TYPE');


        if( lBuyCostType is not null ) then
        begin
           select cost_type_id into v_buy_cost_type_id
           from cst_cost_types
           where cost_type = lBuyCostType ;

           IF  PG_DEBUG <> 0 THEN
                oe_debug_pub.add('Buy Cost Type id ::'|| v_buy_cost_type_id , 2);
           END IF;

        exception
        when no_data_found then

           cto_msg_pub.cto_message('BOM','CTO_BUY_COST_NOT_FOUND');
           raise  FND_API.G_EXC_ERROR;

        when others then

           raise  FND_API.G_EXC_UNEXPECTED_ERROR;


        end;

        else
            v_buy_cost_type_id := v_cto_cost_type_id ;

           IF  PG_DEBUG <> 0 THEN
                oe_debug_pub.add('defaulting buy cost = cto cost ' , 2);
           END IF;

        end if ;


       lStmtNum := 30;
       begin

       select item_cost into v_cto_cost from cst_item_costs
       where inventory_item_id = pConfigId
       and organization_id = p_cost_organization_id      -- 3116778
       and cost_type_id = v_cto_cost_type_id ;

       lStmtNum := 32;
       select sum(item_cost) into v_cto_cost_xudc from cst_item_cost_details
       where inventory_item_id = pConfigId
       and organization_id = p_cost_organization_id      -- 3116778
       and cost_type_id = v_cto_cost_type_id
       and rollup_source_type = 3 ; -- bugfix 2808704


        IF  PG_DEBUG <> 0 THEN
       	    oe_debug_pub.add('cto cost ' || v_cto_cost ) ;
       	    oe_debug_pub.add('cto cost xudc ' || v_cto_cost_xudc ) ;
        END IF;


       exception
       when no_data_found then
            v_cto_cost := null ;
            v_cto_cost_xudc := null ;

       when others then

            raise fnd_api.g_exc_error;

       end ;





       lStmtNum := 35;
       begin

       select item_cost into v_valuation_cost from cst_item_costs
       where inventory_item_id =  pConfigId
       and organization_id =  p_cost_organization_id      -- 3116778
       and cost_type_id = v_primary_cost_method ;


       exception
       when no_data_found then

            v_valuation_cost := null ;

       when others then

            raise fnd_api.g_exc_error;

       end ;


       v_rolledup_cost_count := null ;
       v_rolledup_cost_count := null ;


       /* check whether rolledup cost exists in frozen cost in standard costing org */
       if( v_primary_cost_method = 1) then
          begin
             select count(*) , sum(item_cost) into v_rolledup_cost_count, v_rolledup_cost
               from cst_item_cost_details
              where inventory_item_id = pConfigId
                and organization_id = p_cost_organization_id     -- 3116778l
                and cost_type_id = v_primary_cost_method
                and rollup_source_type = 3 ;

          exception
          when others then

               raise fnd_api.g_exc_error ;

          end ;
       end if ;







       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('going for stmt 40 ' || pConfigId
                       || ' org ' || p_organization_id
		       || ' cost org ' || p_cost_organization_id         -- 3116778
                       || ' pri ' || v_primary_cost_method
                       || ' buy ' || v_buy_cost_type_id
                       || ' line ' || pLineId , 1);
       END IF;




       lStmtNum := 40;

       if( lBuyCostType is not null ) then
          begin
             select item_cost into v_buy_cost from cst_item_costs
              where inventory_item_id = pConfigId
             and organization_id = p_cost_organization_id        -- 3116778
             and cost_type_id = v_buy_cost_type_id ;




               IF PG_DEBUG <> 0 THEN
       	          oe_debug_pub.add('v_buy_cost ' || v_buy_cost  , 1);
       	          oe_debug_pub.add('org ' || p_organization_id , 1);
		  oe_debug_pub.add('cost org ' || p_cost_organization_id , 1);   -- 3116778
       	          oe_debug_pub.add('cost id ' || v_buy_cost_type_id, 1);
               END IF;

          exception
          when no_data_found then

            v_buy_cost := null ;

            IF PG_DEBUG <> 0 THEN
       	          oe_debug_pub.add('v_buy_cost null ' , 1);
       	          oe_debug_pub.add('org ' || p_organization_id , 1);
		  oe_debug_pub.add('cost org ' || p_cost_organization_id , 1);   -- 3116778
            END IF;

          when others then

            raise fnd_api.g_exc_error;

          end ;


       else

           IF PG_DEBUG <> 0 THEN
       	          oe_debug_pub.add('v_buy_cost null as buy cost profile is not set ' , 1);
           END IF;

           v_buy_cost := null ;

       end if;



       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('going for stmt 45 ' , 1);
       END IF;


       lStmtNum := 45;

       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('line ' || pLineId , 1);
       END IF;




       /*
         bug 3877317
         query fixed to get v_organization_type.
         added new too_many_rows exception handler due to query being dependent only on organization_id
       */
       begin
          select nvl( organization_type , 1 )  into v_organization_type
            from bom_cto_src_orgs
           where line_id = pLineId
             and cost_rollup = 'Y'
             and organization_id = p_organization_id ; -- added for bug 3877317  copied from fp.
                                                       -- In 11.5.10 there could be multiple manufacturing orgs.

       exception
       when too_many_rows then  -- added for bug 3877317
            IF PG_DEBUG <> 0 THEN
               oe_debug_pub.add('others ' || SQLERRM  , 1);
               oe_debug_pub.add('going to check whether make organization for too_many_rows ' , 1);
            END IF;

          /*
             BUG 3877317
             SQL added in too_many_rows exception handler to check whether p_organization_id is make org.
             query is now based only on organization_id and hence needs to check whether it is manufacturing org
             using the following sql. The code to check whether cost rollup should not be performed needs to know
             whether the organization is make organization. In 11.5.9 this check was not required as create_bom flag
             was set only for manufacturing org.
          */

          begin
          select organization_type into v_organization_type
            from bom_cto_src_orgs
           where line_id = pLineId
             and rcv_org_id = p_organization_id
             and organization_id = p_organization_id
             and organization_type = '2'
             and cost_rollup = 'Y' ;

            IF PG_DEBUG <> 0 THEN
               oe_debug_pub.add( p_organization_id || ' is make organization ' , 1);
            END IF;
          exception
          when no_data_found then
               v_organization_type := 1 ;


          end ;
          -- end of bug 3877317  to check whether p_organization_id is make org.


       when others then
            IF PG_DEBUG <> 0 THEN
       	       oe_debug_pub.add('others ' || SQLERRM  , 1);
       	       oe_debug_pub.add('defaulting organization type =  4 ' , 1);
            END IF;

            v_organization_type := 4 ;
            /* cost rollup is 'N' for child models of drop ship or buy */


            -- raise fnd_api.g_exc_error;

       end ;




       IF PG_DEBUG <> 0 THEN
        oe_debug_pub.add('organization_type ' || v_organization_type  , 1);

       	oe_debug_pub.add('valuation cost ' || v_valuation_cost , 1);
       	oe_debug_pub.add('primary cost method ' || v_primary_cost_method , 1);
       	oe_debug_pub.add('cto cost ' || v_cto_cost ) ;
       	oe_debug_pub.add('cto cost xudc ' || v_cto_cost_xudc ) ;
       	oe_debug_pub.add('buy cost ' || v_buy_cost ) ;


       	oe_debug_pub.add('going for stmt 50 ' , 1);
       END IF;


       lStmtNum := 50;





   /* Standard or Average, Lifo, Fifo processing logic */
   if( v_primary_cost_method = 1 ) then



       v_item_transacted := FALSE ;

       v_item_transacted := is_item_transacted( pConfigId
                                           , p_cost_organization_id              -- 3116778
                                           , 1 ) ;


       if( v_item_transacted ) then

           IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add( ' came into item transacted ' , 1 ) ;
           END IF;

           if( v_valuation_cost <> v_cto_cost  or v_cto_cost is null ) then

                    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add( ' going to copy cost valuation cost ' ||
                                           v_primary_cost_method , 1 ) ;
                       oe_debug_pub.add( ' cto cost ' || v_cto_cost_type_id , 1 ) ;
                       oe_debug_pub.add( ' config id ' || pConfigId , 1 ) ;
                       oe_debug_pub.add( ' organization id ' || p_organization_id , 1 ) ;
		       oe_debug_pub.add( 'cost organization id ' || p_cost_organization_id , 1 ) ;   -- 3116778

                    END IF;


                    /* copy_valuation_cost_to_cto_cost() ; */
                    lStmtNum := 55;
                    CTO_UTILITY_PK.copy_cost(v_primary_cost_method
                                   , v_cto_cost_type_id
                                   , pConfigId
                                   , p_cost_organization_id              -- 3116778
                                   )  ;


           else

                    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add( ' cto cost is same as valuation cost no need to synch up ' , 1 ) ;
                    END IF;

           end if ;


           lStmtNum := 60;

           if( p_group_reference_id is null ) then
           update bom_cto_src_orgs_b
               set    cost_rollup = 'N'
               where  line_id = pLineId
               and  organization_id = p_organization_id ;


                      IF PG_DEBUG <> 0 THEN
                         oe_debug_pub.add( ' updated bcso cost rollup N for line ' || pLineId
                                           || ' org ' || p_organization_id
                                           || ' count ' || to_char(sql%rowcount)
                                           , 1 ) ;
                      END IF;


           else

              update bom_cto_model_orgs
                 set cost_rollup = 'N'
               where group_reference_id = p_group_reference_id
                 and organization_id = p_organization_id ;


                      IF PG_DEBUG <> 0 THEN
                         oe_debug_pub.add( ' updated bcmo cost rollup N for group_ref ' || p_group_reference_id
                                           || ' org ' || p_organization_id
                                           || ' count ' || to_char(sql%rowcount)
                                           , 1 ) ;
                      END IF;



           end if ;


           IF PG_DEBUG <> 0 THEN
                  oe_debug_pub.add( ' going to indicate no cost rollup due to transacted condition 1 '
                  , 1 ) ;
           END IF;






       else  /* No transactions have taken place */


           /* Cost Rollup Override logic in Standard costing org. */

           if( v_organization_type = '2' ) then /* make */

               IF PG_DEBUG <> 0 THEN
                  oe_debug_pub.add( ' came into make organization type ' , 1 ) ;
               END IF;

               if( v_rolledup_cost_count > 0  and
                   ( v_rolledup_cost <> v_buy_cost or v_buy_cost is null ) ) then

                  /* Synch up cto cost with valuation cost in case of average costing org. */


                  if( v_valuation_cost <> v_cto_cost  or v_cto_cost is null ) then

                      IF PG_DEBUG <> 0 THEN
                         oe_debug_pub.add( ' going to copy cost valuation cost ' ||
                                           v_primary_cost_method , 1 ) ;
                         oe_debug_pub.add( ' cto cost ' || v_cto_cost_type_id , 1 ) ;
                         oe_debug_pub.add( ' config id ' || pConfigId , 1 ) ;
                         oe_debug_pub.add( ' organization id ' || p_organization_id , 1 ) ;
			 oe_debug_pub.add( ' cost organization id ' || p_cost_organization_id , 1 ) ;  -- 3116778
                      END IF;


                      /* copy_valuation_cost_to_cto_cost() ; */
                      lStmtNum := 55;
                      CTO_UTILITY_PK.copy_cost(v_primary_cost_method
                                   , v_cto_cost_type_id
                                   , pConfigId
                                   , p_cost_organization_id              -- 3116778
                                   )  ;


                  else

                      IF PG_DEBUG <> 0 THEN
                         oe_debug_pub.add( ' cto cost is same as valuation cost no need to synch up ' , 1 ) ;
                      END IF;

                  end if ;

                  lStmtNum := 60;

                  if( p_group_reference_id is null ) then
                      update bom_cto_src_orgs_b
                         set    cost_rollup = 'N'
                       where  line_id = pLineId
                         and  organization_id = p_organization_id ;

                      IF PG_DEBUG <> 0 THEN
                         oe_debug_pub.add( ' updated bcso cost rollup N for line ' || pLineId
                                           || ' org ' || p_organization_id
                                           || ' count ' || to_char(sql%rowcount)
                                           , 1 ) ;
                      END IF;

                  else

                     update bom_cto_model_orgs
                        set cost_rollup = 'N'
                      where group_reference_id = p_group_reference_id
                        and organization_id = p_organization_id  ;

                      IF PG_DEBUG <> 0 THEN
                         oe_debug_pub.add( ' updated bcmo cost rollup N for group_ref ' || p_group_reference_id
                                           || ' org ' || p_organization_id
                                           || ' count ' || to_char(sql%rowcount)
                                           , 1 ) ;

                      END IF;


                  end if ;

                  IF PG_DEBUG <> 0 THEN
                     oe_debug_pub.add( ' going to indicate no cost rollup due to std make condition 1 '
                                       , 1 ) ;
                  END IF;



              end if; /* rolledup cost exists in Standard costing Org for make context */



           elsif( v_organization_type in ( '3', '5')) then /* buy, dropship */

               IF PG_DEBUG <> 0 THEN
                  oe_debug_pub.add( ' came into buy organization type ' , 1 ) ;
                  oe_debug_pub.add( ' cto ' || v_cto_cost  , 1 ) ;
                  oe_debug_pub.add( ' cto xudc ' || v_cto_cost_xudc  , 1 ) ;
                  oe_debug_pub.add( ' cto buy ' || v_buy_cost  , 1 ) ;
               END IF ;


           end if ; /* costing for matched items logic */



       end if ; /* item transacted */

    else

         /* Cost Rollup Override logic in Average, Lifo, Fifo Costing org. */


         if( v_valuation_cost <>  0 ) then

               /* Synch up cto cost with valuation cost in case of average costing org. */


               if( v_valuation_cost <> v_cto_cost or v_cto_cost is null ) then
                   IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add( ' going to copy cost valuation cost ' ||
                                           v_primary_cost_method , 1 ) ;
                       oe_debug_pub.add( ' cto cost ' || v_cto_cost_type_id , 1 ) ;
                       oe_debug_pub.add( ' config id ' || pConfigId , 1 ) ;
                       oe_debug_pub.add( ' organization id ' || p_organization_id , 1 ) ;
		       oe_debug_pub.add( ' cost organization id ' || p_cost_organization_id , 1 ) ;    -- 3116778
                   END IF;


                   /* copy_valuation_cost_to_cto_cost() ; */
                   lStmtNum := 65;
                   CTO_UTILITY_PK.copy_cost( v_primary_cost_method
                                   , v_cto_cost_type_id
                                   , pConfigId
                                   ,  p_cost_organization_id              -- 3116778
                                   )  ;

               else

                    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add( ' cto cost is same as valuation cost no need to synch up ' , 1 ) ;
                    END IF;

               end if ;




               lStmtNum := 70;


               if( p_group_reference_id is null ) then
                      update bom_cto_src_orgs_b
                         set    cost_rollup = 'N'
                       where  line_id = pLineId
                        and  organization_id = p_organization_id ;

                      IF PG_DEBUG <> 0 THEN
                         oe_debug_pub.add( ' updated bcso cost rollup N for line ' || pLineId
                                           || ' org ' || p_organization_id
                                           || ' count ' || to_char(sql%rowcount)
                                           , 1 ) ;
                      END IF;

               else

                     update bom_cto_model_orgs
                        set cost_rollup = 'N'
                      where group_reference_id = p_group_reference_id
                        and organization_id = p_organization_id ;

                      IF PG_DEBUG <> 0 THEN
                         oe_debug_pub.add( ' updated bcmo cost rollup N for group_ref ' || p_group_reference_id
                                           || ' org ' || p_organization_id
                                           || ' count ' || to_char(sql%rowcount)
                                           , 1 ) ;

                      END IF;



               end if ;


               IF PG_DEBUG <> 0 THEN
                  oe_debug_pub.add( ' going to indicate no cost rollup due to avg make condition 1 '
                  , 1 ) ;
               END IF;



         else

             /* Logic for Make or Buy within Average/Lifo/Fifo Costing Org */

             if( v_organization_type = '2' ) then /* make */


                 if( v_cto_cost is not null and
                     ( v_buy_cost is null or v_cto_cost_xudc <> v_buy_cost )) then


                     lStmtNum := 75;


                     if( p_group_reference_id is null ) then
                         update bom_cto_src_orgs_b
                         set    cost_rollup = 'N'
                         where  line_id = pLineId
                         and  organization_id = p_organization_id ;

                         IF PG_DEBUG <> 0 THEN
                            oe_debug_pub.add( ' updated bcso cost rollup N for line ' || pLineId
                                           || ' org ' || p_organization_id
                                           || ' count ' || to_char(sql%rowcount)
                                           , 1 ) ;
                         END IF;

                     else

                          update bom_cto_model_orgs
                           set cost_rollup = 'N'
                           where group_reference_id = p_group_reference_id
                           and organization_id = p_organization_id  ;

                           IF PG_DEBUG <> 0 THEN
                              oe_debug_pub.add( ' updated bcmo cost rollup N for group_ref ' || p_group_reference_id
                                           || ' org ' || p_organization_id
                                           || ' count ' || to_char(sql%rowcount)
                                           , 1 ) ;

                           END IF;



                      end if ;


                     IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add( ' going to indicate no cost rollup due to avg make condition 2 '
                        , 1 ) ;
                     END IF;


                 end if ;


             elsif( v_organization_type in ( '3', '5')) then /* buy, dropship */

               IF PG_DEBUG <> 0 THEN
                  oe_debug_pub.add( ' came into buy organization type ' , 1 ) ;
                  oe_debug_pub.add( ' cto ' || v_cto_cost  , 1 ) ;
                  oe_debug_pub.add( ' cto xudc ' || v_cto_cost_xudc  , 1 ) ;
                  oe_debug_pub.add( ' cto buy ' || v_buy_cost  , 1 ) ;
               END IF ;


             end if ; /* costing for make or buy logic */




         end if; /* Valuation exists or not logic in Average/Lifo/Fifo costing org */









    end if ;
    /* Cost Rollup Override logic for Standard or Average, Lifo, Fifo processing logic */







Exception
   WHEN fnd_api.g_exc_error THEN
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('create_in_src_orgs: '
                  || 'expected error::'||to_char(lStmtNum)||'::'||sqlerrm, 1);
	END IF;

        xReturnStatus := fnd_api.g_ret_sts_unexp_error;
        --  Get message count and data
        xReturnStatus := fnd_api.g_ret_sts_error;
        --  Get message count and data


        cto_msg_pub.count_and_get
          (  p_msg_count => xMsgCount
           , p_msg_data  => xMsgData
           );

   WHEN fnd_api.g_exc_unexpected_error THEN


        xReturnStatus := fnd_api.g_ret_sts_unexp_error ;
        --  Get message count and data


        cto_msg_pub.count_and_get
          (  p_msg_count  => xMsgCount
           , p_msg_data   => xMsgData
            );

   WHEN OTHERS then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('create_in_src_orgs: '
                              || 'create_in_src_orgs::others::'||to_char(lStmtNum)
                              ||'::'||sqlerrm, 1);
	END IF;

        xReturnStatus := fnd_api.g_ret_sts_unexp_error;
        --  Get message count and data

        cto_msg_pub.count_and_get
          (  p_msg_count  => xMsgCount
           , p_msg_data   => xMsgData
             );


END override_bcso_cost_rollup;



END CTO_BOM_RTG_PK;

/
