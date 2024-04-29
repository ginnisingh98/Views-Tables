--------------------------------------------------------
--  DDL for Package Body CTO_GOP_INTERFACE_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_GOP_INTERFACE_PK" as
/* $Header: CTOGOPIB.pls 120.2.12010000.2 2009/07/03 16:02:02 abhissri ship $*/
/*----------------------------------------------------------------------------+
| Copyright (c) 2003 Oracle Corporation    Belmont, California, USA
|                       All rights reserved.
|                       Oracle Manufacturing
|
|FILE NAME   : CTOGOPIB.pls
|
|DESCRIPTION : Contains modules to :
|		conatins a wrapper procedure for ATP
|               This calls match api, reuse api and option specific sources
|               api
|HISTORY     :
|              09-05-2003   Kiran Konada
|
|
|              10-21-2003  Kiran Konada
|                          removed x-Match_found as apramter to
|                          procedure Match_configured_item to keep in syn with
|                          spec change
|
|              11-05-2003  Kiran Konada
|                          put the debug statement with rows passed before
|                          insertion into BCOL
|
|             01-22-2004    Kiran Konada
|                          bugfix 3391383
|                          config_orgs attribute from model is inserted into bcol_gt
|                          bug was we tried to get for config_item_id
|
|             02-23-2004   Kiran Konada
|                          bugfix 3259017
|
|             05-17-2004   Kiran Konada
|                          bugfix 3555026
|                          --null value in config_orgs should be treated as
|                            based on sourcing
|                          --When ATP passes null in ship_from_org_id, we should
|                            NOT default to any other organization
|                            AS that org could be a ware house on SO pad
|                            during intial scheduling and hence bcol could have
|                            the data AND would create a problem in re-use,
|                            as configitem is reused if ware house is same
|                            before and after re-scheduling
-------------------------------------------------------------------------------
*/
G_PKG_NAME CONSTANT VARCHAR2(30) := 'CTO_GOP_INTERFACE_PK';
--remove teh level 5
PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);

PROCEDURE init_rec(p_match_rec_of_tab IN OUT NOCOPY CTO_Configured_Item_GRP.CTO_MATCH_REC_TYPE)
  AS
BEGIN
  p_match_rec_of_tab.CONFIG_ITEM_ID.delete;
  p_match_rec_of_tab.LINE_ID.delete;
  p_match_rec_of_tab.LINK_TO_LINE_ID.delete;
  p_match_rec_of_tab.ATO_LINE_ID.delete;
  p_match_rec_of_tab.TOP_MODEL_LINE_ID.delete;
  p_match_rec_of_tab.INVENTORY_ITEM_ID.delete;
  p_match_rec_of_tab.COMPONENT_CODE.delete;
  p_match_rec_of_tab.COMPONENT_SEQUENCE_ID.delete;
  p_match_rec_of_tab.VALIDATION_ORG.delete;
  p_match_rec_of_tab.QTY_PER_PARENT_MODEL.delete;
  p_match_rec_of_tab.ORDERED_QUANTITY.delete;
  p_match_rec_of_tab.ORDER_QUANTITY_UOM.delete;
  p_match_rec_of_tab.PARENT_ATO_LINE_ID.delete;
  p_match_rec_of_tab.GOP_PARENT_ATO_LINE_ID.delete;
  p_match_rec_of_tab.PERFORM_MATCH.delete;
  p_match_rec_of_tab.PLAN_LEVEL.delete;
  p_match_rec_of_tab.BOM_ITEM_TYPE.delete;
  p_match_rec_of_tab.WIP_SUPPLY_TYPE.delete;
  p_match_rec_of_tab.OSS_ERROR_CODE.delete;
  p_match_rec_of_tab.SHIP_FROM_ORG_ID.delete;
  p_match_rec_of_tab.Attribute_1.delete;
  p_match_rec_of_tab.Attribute_2.delete;
  p_match_rec_of_tab.Attribute_3.delete;
  p_match_rec_of_tab.Attribute_4.delete;
  p_match_rec_of_tab.Attribute_5.delete;
  p_match_rec_of_tab.Attribute_6 := CTO_Configured_Item_GRP.date_arr_tbl_type(NULL);
  p_match_rec_of_tab.Attribute_6.delete;
  p_match_rec_of_tab.Attribute_7 := CTO_Configured_Item_GRP.date_arr_tbl_type(NULL);
  p_match_rec_of_tab.Attribute_7.delete;
  p_match_rec_of_tab.Attribute_8 := CTO_Configured_Item_GRP.date_arr_tbl_type(NULL);
  p_match_rec_of_tab.Attribute_8.delete;
  p_match_rec_of_tab.Attribute_9.delete;
END init_rec;


PROCEDURE CTO_GOP_WRAPPER_API (
	p_Action		IN	VARCHAR2,
	p_Source		IN	VARCHAR2,
	p_match_rec_of_tab IN OUT NOCOPY CTO_Configured_Item_GRP.CTO_MATCH_REC_TYPE,
	X_oss_orgs_list	OUT	NOCOPY   CTO_OSS_SOURCE_PK.Oss_orgs_list_rec_type,
	x_return_status	OUT     NOCOPY VARCHAR2,
	X_msg_count	OUT     NOCOPY number,
	X_msg_data	OUT     NOCOPY Varchar2
 )
 IS
  i number;
  --why is match prfoile a varchr??
  l_match_profile number;
  l_match_found   VARCHAR2 (1);

  l_last_index number;
  l_model_exists  varchar2(1);
  l_config_change varchar2(1);
  lStmtNum	 number;

  --dummy
  l_count	number;
  l_PDS_ODS	number; --PDS= 4, ODS= 5, any value other than 4 is treated as ODS(vivek)

  lReuseProfile number;  --Bugfix 6642016


  CURSOR c_debug IS
  SELECT config_item_id,
         line_id,
         link_to_line_id,
	 parent_ato_line_id,
	 gop_parent_ato_line_id,
	 ato_line_id,
	 top_model_line_id,
	 inventory_item_id,
	 ordered_quantity,
	 qty_per_parent_model,
	 ship_from_org_id,
	 validation_org,
	 plan_level,
	 wip_supply_type,
	 bom_item_type,
	 reuse_config,
	 perform_match,
	 config_creation,
	 option_specific,
	 oss_error_code
  FROM bom_cto_order_lines_gt;


 BEGIN

      oe_debug_pub.add('             START TIME STAMP : '||to_char(sysdate,'hh:mi:ss')||'        ',5);

     x_return_status := FND_API.G_RET_STS_SUCCESS;


     lStmtNum := 10;
     DELETE FROM bom_cto_order_lines_gt;

     lStmtNum :=  20;
     l_match_profile := FND_PROFILE.Value('BOM:MATCH_CONFIG');



     lStmtNum :=  30;
     l_PDS_ODS := FND_PROFILE.Value('INV_CTP');



     --level1
     IF PG_DEBUG <> 0 THEN
	oe_debug_pub.add('match profile =>'||l_match_profile,1);
     END IF;

     lStmtNum :=  40;
     l_last_index := p_match_rec_of_tab.line_id.count;

     IF PG_DEBUG = 5 THEN
     lStmtNum :=  50;
     select count(*)
     into   l_count
     from   bom_cto_order_lines_gt;

     oe_debug_pub.add('count before insert into bCOL =>'||l_count,1);

     END IF;


      --debug level 5
    IF PG_DEBUG = 5 THEN
        FOR i IN 1..l_last_index LOOP
		 oe_debug_pub.add('line_id=>'||p_match_rec_of_tab.line_id(i)||
	                      'QTY=>'||p_match_rec_of_tab.ordered_quantity(i)||
			      'ship_frm_org=>'||p_match_rec_of_tab.SHIP_FROM_ORG_ID(i)||
			      'validation_org=>'||p_match_rec_of_tab.Validation_org(i),5);
        END LOOP;

        oe_debug_pub.add('Sql%row count ='||sql%rowcount,3);
    END IF;



      --used an diff insert than one from grp match api
      --reason: for better performance
      --        insert fo grp api needed an extend api
      --	and un-ncessary insertion of null values
      lStmtNum:=10;
     FORALL i in 1..l_last_index
         INSERT INTO bom_cto_order_lines_gt
	      (
	      ATO_LINE_ID,
	      COMPONENT_CODE,
	      COMPONENT_SEQUENCE_ID,
	      BOM_ITEM_TYPE,
	      WIP_SUPPLY_TYPE,
	      INVENTORY_ITEM_ID,
	      LINE_ID,
	      LINK_TO_LINE_ID,
	      ORDERED_QUANTITY,
	      ORDER_QUANTITY_UOM,
	      TOP_MODEL_LINE_ID,
	      SHIP_FROM_ORG_ID,
	      config_item_id,
	      VALIDATION_ORG --3503764
	      )
	 VALUES
	      (
	       p_match_rec_of_tab.ato_line_id(i),
	       p_match_rec_of_tab.component_code(i),
	       p_match_rec_of_tab.component_sequence_id(i),
			--for oss pefromance improvement
			--added -1
			--bom_item_type
	       decode(p_match_rec_of_tab.top_model_line_id(i),null,-1, --ato item
	              -- 1 for topst ato model and default is -1
	              decode(p_match_rec_of_tab.ato_line_id(i),p_match_rec_of_tab.line_id(i),1,-1)
		      ),
	       -1,    --wip_supply_type
	       p_match_rec_of_tab.inventory_item_id(i),
	       p_match_rec_of_tab.line_id(i),
	       p_match_rec_of_tab.link_to_line_id(i),
	       p_match_rec_of_tab.ordered_quantity(i),
	       p_match_rec_of_tab.order_quantity_uom(i),
	       p_match_rec_of_tab.top_model_line_id(i),
	       nvl(p_match_rec_of_tab.ship_from_org_id(i),-99),--3555026
	       --need for better prformance of OSS code
	       --if independent ato line order
	       --populate inv_item_id as config item id
	       --conatct info : kiran/renga
	       decode(p_match_rec_of_tab.top_model_line_id(i),
		            null,
		            p_match_rec_of_tab.inventory_item_id(i)
	              ),

	       p_match_rec_of_tab.validation_org(i)--3503764
	      );

              IF PG_DEBUG <> 0 THEN
	       oe_debug_pub.add(sql%rowcount||' rows inserted into bcol_gt',5);
	       END IF;


     lStmtNum:=40;
     BEGIN
	SELECT 'Y'
	INTO   l_model_exists
	FROM bom_cto_order_lines_gt
	WHERE line_id = ato_line_id
	AND   top_model_line_id is not null
	AND rownum = 1;
     EXCEPTION
	WHEN others THEN
		l_model_exists :='N';
     END;

    --l_model_exists := 'N';
    IF l_model_exists = 'Y' THEN  --ato model and maybe atoitem
        lStmtNum:=50;
        CTO_MATCH_CONFIG.prepare_bcol_temp_data(
					   p_source           =>  p_Source,
					   p_match_rec_of_tab =>  p_match_rec_of_tab,
					   x_return_status    =>  x_return_status,
					   x_msg_count	       =>  X_msg_count,
					   x_msg_data         =>  X_msg_data
					  );
	IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
		--level 1
	 --   IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('SUCCESS after CTO_MATCH_CONFIG.prepare_bcol_temp_data',1);
	 --   END IF;
	ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE fnd_api.g_exc_error;
	ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE fnd_api.g_exc_unexpected_error;
	END IF;


      IF l_PDS_ODS = 4 THEN --PDS

            lStmtNum:=60;
	    UPDATE bom_cto_order_lines_gt child
	    SET    qty_per_parent_model =
	                  --used round to be consistent with can_configuration code
	 	 ( SELECT  ROUND(child.ordered_quantity/parent.ordered_quantity,7)
		   FROM   bom_cto_order_lines_gt parent
		   WHERE  child.parent_ato_line_id= parent.line_id
		  )
	    --to filter out ato item order lines
	    WHERE top_model_line_id is not null;

	    IF PG_DEBUG <> 0 THEN
	     oe_debug_pub.add('qty_per_parent_model is calculated for'||sql%rowcount||' rows in bcol_gt',5);
	    END IF;

            --call reuse configuration API
	    lStmtNum:=70;
            lReuseProfile := FND_PROFILE.Value('CTO_REUSE_CONFIG');  --Bugfix 6642016

            IF PG_DEBUG <> 0 THEN
                   oe_debug_pub.add('Create_And_Link_Item: ' ||
                                    ' Reuse Configuration profile: '  || to_char(lReuseProfile) , 5);
            END IF;  --Bugfix 6642016

            if ( nvl(lReuseProfile,1) = 1 ) then  ----Bugfix 6642016
            lStmtNum:=80;
	    CTO_MATCH_CONFIG.CTO_REUSE_CONFIGURATION(
			X_config_change    =>l_config_change,
			X_return_status	   =>x_return_status,
			X_msg_count	   =>x_msg_count,
			X_msg_data	   =>x_msg_data
			) ;
	    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
	  --    IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('SUCCESS after CTO_MATCH_CONFIG.CTO_REUSE_CONFIGURATION',1);
	  --    END IF;
	    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE fnd_api.g_exc_error;
	    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE fnd_api.g_exc_unexpected_error;
	    END IF;
            end if;  --lReuseProfile = 1  Bugfix 6642016

            IF l_match_profile = 1 THEN

		lStmtNum:=30;
		CTO_Configured_Item_GRP.MATCH_CONFIGURED_ITEM
		(
			 p_api_version   => 1.0,
			 x_return_status => x_return_status,
			 x_msg_count     => X_msg_count,
			 x_msg_data      => X_msg_data,
		         p_Action  	    => p_Action,
		         p_Source        => p_Source ,

			p_cto_match_rec => p_match_rec_of_tab

		);

		IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
			IF PG_DEBUG <> 0 THEN
			  oe_debug_pub.add('SUCCESS after CTO_Configured_Item_GRP.MATCH_CONFIGURED_ITEM',1);
			END IF;
	        ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE fnd_api.g_exc_error;
		ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE fnd_api.g_exc_unexpected_error;
		END IF;

	   END IF; -- l_match_pfoile = 1

	   --get config_creation attr for OSS purposes
	   --for matched.re-used config_item only

	   --as per perf std ahmed almori
           --If the global temporary table is referenced in a sub-query in a
           --SQL statement which accesses other tables.
           --In such cases, the join order may not be optimal due to the lack
           --of stats on the temp table, hence hints should be used to ensure the optimal join order.

           UPDATE /*+ INDEX (GT BOM_CTO_ORDER_LINES_GT_N5) */ bom_cto_order_lines_gt GT
	   SET GT.config_creation = ( SELECT nvl(MTL.config_orgs,1)--3555026
	                              FROM   mtl_system_items MTL
				      WHERE  MTL.inventory_item_id = GT.inventory_item_id -- bugfix 3391383
				      AND    MTL.organization_id = GT.validation_org--3555026
				      AND    GT.bom_item_type = '1'
				      AND    GT.config_item_id is not null
                                    )
	   WHERE GT.bom_item_type = '1'
	   AND   GT.config_item_id is not null;

	   IF PG_DEBUG <> 0 THEN
	     oe_debug_pub.add('Updated  '||sql%rowcount||'  model rows with config_orgs or config_creation attribute',5);
	   END IF;


       END IF; -- l_pds_ods =4

  END IF; --ato model and maybe atoitem


      --make a call to option dependent sources api
    lStmtNum:=80;
    CTO_OSS_SOURCE_PK.GET_OSS_ORGS_LIST(
					     X_OSS_ORGS_LIST =>	X_oss_orgs_list,
					     X_RETURN_STATUS =>x_return_status,
					     X_MSG_DATA      =>X_msg_data,
					     X_MSG_COUNT     =>X_msg_count
					     );

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
			--level 1
     --  IF PG_DEBUG <> 0 THEN
	  oe_debug_pub.add('SUCCESS after CTO_OSS_SOURCE_PK.GET_OSS_ORGS_LIST',1);
      --  END IF;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE fnd_api.g_exc_unexpected_error;
    END IF;

      --make sure floowling sql bring null values too
     lStmtNum:=90;
     /*Commenting this sql as part of bugfix 8636348
     SELECT  oss_error_code,
	     config_item_id,
	     parent_ato_line_id,
	     gop_parent_ato_line_id,
	     bom_item_type,
	     wip_supply_type
     BULK COLLECT INTO
	     p_match_rec_of_tab.oss_error_code,
			--during Ut make sure next statement
			--over writes existing values , ifnot
			--additional rows may get created during
			--for MATCH 0n cases. remove comment after UT
	     p_match_rec_of_tab.config_item_id,
             p_match_rec_of_tab.parent_ato_line_id,
	     p_match_rec_of_tab.gop_parent_ato_line_id,
	     p_match_rec_of_tab.bom_item_type,
	     p_match_rec_of_tab.wip_supply_type
     FROM bom_cto_order_lines_gt
     ORDER BY line_id;  --Bugfix 6055375*/

     --Bugfix 8636348: The collection needs to be cleaned up before repopulating
     IF PG_DEBUG <> 0 THEN
       oe_debug_pub.add('CTOGOPIB: Before cleaning p_match_rec_of_tab');
     END IF;

     init_rec(p_match_rec_of_tab);

     IF PG_DEBUG <> 0 THEN
       oe_debug_pub.add('CTOGOPIB: After cleaning p_match_rec_of_tab');
     END IF;

     select
	CONFIG_ITEM_ID,
	LINE_ID,
	LINK_TO_LINE_ID,
	ATO_LINE_ID,
	TOP_MODEL_LINE_ID,
	INVENTORY_ITEM_ID,
	COMPONENT_CODE,
	COMPONENT_SEQUENCE_ID,
	VALIDATION_ORG,
	QTY_PER_PARENT_MODEL,
	ORDERED_QUANTITY,
	ORDER_QUANTITY_UOM,
	PARENT_ATO_LINE_ID,
	GOP_PARENT_ATO_LINE_ID,
	PERFORM_MATCH,
	PLAN_LEVEL,
	BOM_ITEM_TYPE,
	WIP_SUPPLY_TYPE,
	OSS_ERROR_CODE,
	SHIP_FROM_ORG_ID
     BULK COLLECT INTO
	p_match_rec_of_tab.CONFIG_ITEM_ID,
	p_match_rec_of_tab.LINE_ID,
	p_match_rec_of_tab.LINK_TO_LINE_ID,
	p_match_rec_of_tab.ATO_LINE_ID,
	p_match_rec_of_tab.TOP_MODEL_LINE_ID,
	p_match_rec_of_tab.INVENTORY_ITEM_ID,
	p_match_rec_of_tab.COMPONENT_CODE,
	p_match_rec_of_tab.COMPONENT_SEQUENCE_ID,
	p_match_rec_of_tab.VALIDATION_ORG,
	p_match_rec_of_tab.QTY_PER_PARENT_MODEL,
	p_match_rec_of_tab.ORDERED_QUANTITY,
	p_match_rec_of_tab.ORDER_QUANTITY_UOM,
	p_match_rec_of_tab.PARENT_ATO_LINE_ID,
	p_match_rec_of_tab.GOP_PARENT_ATO_LINE_ID,
	p_match_rec_of_tab.PERFORM_MATCH,
	p_match_rec_of_tab.PLAN_LEVEL,
	p_match_rec_of_tab.BOM_ITEM_TYPE,
	p_match_rec_of_tab.WIP_SUPPLY_TYPE,
	p_match_rec_of_tab.OSS_ERROR_CODE,
	p_match_rec_of_tab.SHIP_FROM_ORG_ID
     FROM bom_cto_order_lines_gt
     ORDER BY line_id;
     --End Bugfix 8636348


     IF PG_DEBUG <> 0 THEN
	  oe_debug_pub.add('Line_id count=>'||p_match_rec_of_tab.line_id.count,5);
	  oe_debug_pub.add('config_id count=>'||p_match_rec_of_tab.config_item_id.count,5);
	  oe_debug_pub.add('oss error code count=>'||p_match_rec_of_tab.oss_error_code.count,5);
          oe_debug_pub.add('wip supply_type=>'||p_match_rec_of_tab.WIP_SUPPLY_TYPE.count,5);

	  --oe_debug_pub.add('Matched item id=>'||p_match_rec_of_tab.config_item_id(1),5);
     END IF;

     lStmtNum:=95;
     IF PG_DEBUG = 5 THEN
    Oe_debug_pub.add(' config_item_id --'||
                     ' line_id --'||
                     ' link_to_line_id --'||
	             ' parent_ato_line_id --'||
	             ' gop_parent_ato_line_id --'||
	             ' ato_line_id --'||
	             ' top_model_line_id --'||
	             ' inventory_item_id --'||
	             ' ordered_qunatity  --'||
	             ' qty_per_parent_model --'||
	             ' ship_from_org_id --'||
		     'validation_org--'||
	             ' plan_level --'||
	             ' wip_supply_type --'||
	             ' bom_item_type --'||
	             ' reuse_config --'||
	             ' perform_match --'||
	             ' config_creation --'||
	             ' option_specific --'||
	             ' oss_error_code ',5);
 	FOR debug_rec in c_debug
	LOOP
	    oe_debug_pub.add(
                             debug_rec.config_item_id ||' -- '||
			     debug_rec.line_id ||' -- '||
			     debug_rec.link_to_line_id ||' -- '||
	                     debug_rec.parent_ato_line_id ||' -- '||
	                     debug_rec.gop_parent_ato_line_id ||' -- '||
	                     debug_rec.ato_line_id ||' -- '||
	                     debug_rec.top_model_line_id ||' -- '||
			     debug_rec.inventory_item_id ||' -- '||
	                     debug_rec.ordered_quantity  ||' -- '||
	                     debug_rec.qty_per_parent_model ||' --'||
	                     debug_rec.ship_from_org_id ||' -- '||
			     debug_rec.validation_org||' -- '||
	                     debug_rec.plan_level ||' -- '||
	                     debug_rec.wip_supply_type ||' -- '||
	                     debug_rec.bom_item_type ||' -- '||
	                     debug_rec.reuse_config ||' -- '||
	                    debug_rec.perform_match ||' -- '||
	                    debug_rec.config_creation ||' -- '||
	                    debug_rec.option_specific ||' -- '||
	                    debug_rec.oss_error_code ,5);
	END LOOP;
    END IF;--debug



    lStmtNum:=100;

    --need this when we make bcol_gt a session table
    DELETE FROM bom_cto_order_lines_gt;

    --Bugfix 8636348: Adding this portion for debug purposes
    IF PG_DEBUG <> 0 THEN
       oe_debug_pub.add('CTOGOPIB: After deleting records from bcol_gt');
    END IF;

    l_last_index := p_match_rec_of_tab.line_id.count;

    IF PG_DEBUG = 5 THEN
        oe_debug_pub.add('-----------------------------------------------------------');
	oe_debug_pub.add('CTOGOPIB: Printing values in the record we pass to GOP');
        FOR i IN 1..l_last_index LOOP
		 oe_debug_pub.add('line_id=>'|| p_match_rec_of_tab.line_id(i)||
				  ' LINK_TO_LINE_ID=>'|| p_match_rec_of_tab.LINK_TO_LINE_ID(i)||
				  ' ATO_LINE_ID=>'|| p_match_rec_of_tab.ATO_LINE_ID(i)||
				  ' TOP_MODEL_LINE_ID=>'|| p_match_rec_of_tab.TOP_MODEL_LINE_ID(i)||
				  ' PARENT_ATO_LINE_ID=>'|| p_match_rec_of_tab.PARENT_ATO_LINE_ID(i)||
				  ' GOP_PARENT_ATO_LINE_ID=>'|| p_match_rec_of_tab.GOP_PARENT_ATO_LINE_ID(i)||
				  ' CONFIG_ITEM_ID=>'|| p_match_rec_of_tab.CONFIG_ITEM_ID(i)||
				  ' INVENTORY_ITEM_ID=>'|| p_match_rec_of_tab.INVENTORY_ITEM_ID(i)||
				  ' QTY=>'|| p_match_rec_of_tab.ordered_quantity(i)||
				  ' ship_frm_org=>'|| p_match_rec_of_tab.SHIP_FROM_ORG_ID(i)||
				  ' validation_org=>'|| p_match_rec_of_tab.Validation_org(i)||
				  ' PERFORM_MATCH=>'|| p_match_rec_of_tab.PERFORM_MATCH(i)||
				  ' PLAN_LEVEL=>'|| p_match_rec_of_tab.PLAN_LEVEL(i), 5);
        END LOOP;
	oe_debug_pub.add('-----------------------------------------------------------');
	oe_debug_pub.add('CTOGOPIB: After printing values.');
    END IF;
    --End debugging. Bugfix 8636348.

     oe_debug_pub.add('  END TIME STAMP : '||to_char(sysdate,'hh:mi:ss')||'        ',5);

 EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('CTO_GOP_WRAPPER_API: ' || 'Exception in stmt num: '
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
        	oe_debug_pub.add('CTO_GOP_WRAPPER_API: ' || ' Unexpected Exception in stmt num: '
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
        	oe_debug_pub.add('CTO_GOP_WRAPPER_API: ' || 'Others Exception in stmt num: '
		                    || to_char(lStmtNum), 1);
		oe_debug_pub.add('error='||sqlerrm);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
 END  CTO_GOP_WRAPPER_API;
 END CTO_GOP_INTERFACE_PK;

/
