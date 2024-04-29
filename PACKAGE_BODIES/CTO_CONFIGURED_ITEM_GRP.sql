--------------------------------------------------------
--  DDL for Package Body CTO_CONFIGURED_ITEM_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_CONFIGURED_ITEM_GRP" AS
/* $Header: CTOGCFGB.pls 115.6 2004/05/28 22:08:31 kkonada noship $*/

/*----------------------------------------------------------------------------+
| Copyright (c) 2003 Oracle Corporation    RedwoodShores, California, USA
|                       All rights reserved.
|                       Oracle Manufacturing
|
|FILE NAME   : CTOGCFGB.pls
|
|DESCRIPTION :
|
-- Start of comments
--	API name 	: MATCH_CONFIGURED_ITEM
--	Type		: Group
--	Function	:To match configured items
--	Pre-reqs	:1. table BOMC_TO_ORDER_LINES_TEMP/DMF J
--	Parameters	:
--	IN		:	p_api_version           IN NUMBER	Required
--				p_init_msg_list		IN VARCHAR2 	Optional
--					                Default = FND_API.G_FALSE
--				p_commit	    	IN VARCHAR2	Optional
--					                 Default = FND_API.G_FALSE
--				Action                  IN    VARCHAR2(30)
-- 			        Source    		IN     VARCHAR2(30)
--		                p_cto_match_rec  	IN OUT  CTO_MATCH_REC_TYPE                         			.
--				.
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count		OUT	NUMBER
--				x_msg_data		OUT	VARCHAR2(2000)
--				x_match_found  		OUT      Varchar2(1)          Y/N
--				.
--	Version	: Current version	1.0
--				Changed....
--
--			  Initial version 	1.0
---
--
--	Notes		: Note text
--
--
-- End of comments

*/


G_PKG_NAME CONSTANT VARCHAR2(30) := 'CTO_Configured_Item_GRP';

PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);

PROCEDURE MATCH_CONFIGURED_ITEM
(
	    --std parameters
	   p_api_version 	             		IN NUMBER,
	   p_init_msg_list 				IN VARCHAR2 default FND_API.G_FALSE,
	   p_commit       				IN VARCHAR2 default FND_API.G_FALSE,
	   p_validation_level                           IN NUMBER  default FND_API.G_VALID_LEVEL_FULL,
	   x_return_status 				OUT NOCOPY VARCHAR2,
	   x_msg_count     				OUT NOCOPY NUMBER,
	   x_msg_data      				OUT NOCOPY VARCHAR2,

	--program parameters
	   p_Action  		 			IN    VARCHAR2,
	   p_Source    					IN     VARCHAR2 ,

	   p_cto_match_rec  				IN OUT NOCOPY CTO_MATCH_REC_TYPE

)

IS

 l_model_exists VARCHAR2(1);

 Type number_tbl_type IS TABLE OF number INDEX BY BINARY_INTEGER;

 l_ato_line_tbl number_tbl_type ;

 l_last_index number;
 l_custom_match_profile VARCHAR2(10);
 lStmtNum number;
 i NUMBER;

 l_api_name CONSTANT VARCHAR2(30) := 'MATCH_CONFIGURED_ITEM';
 l_api_version CONSTANT NUMBER := 1.0;

 l_dummy_line_id number;
 j number;

 l_match_flag_tab	 CTO_MATCH_CONFIG.MATCH_FLAG_TBL_TYPE;
 x_sparse_match_tab      CTO_MATCH_CONFIG.MATCH_FLAG_TBL_TYPE;
 l_match_flag_rec_of_tab CTO_MATCH_CONFIG.Match_flag_rec_of_tab;

 CURSOR c_models_match_flag
 IS
    SELECT line_id,
           parent_ato_line_id,
	   ato_line_id,
	   perform_match
    FROM   bom_cto_order_lines_gt
    WHERE  bom_item_type = '1'
    AND    wip_supply_type <> 6;

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
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Enable this call in future versions
     lStmtNum:= 10;
    IF NOT FND_API.Compatible_API_call(l_api_version,
                                         p_api_version,
					 l_api_name,
					 G_PKG_NAME)
    THEN
          RAISE fnd_api.g_exc_unexpected_error;
    END IF;


      lStmtNum:=20;
      --no need of match profile as upto customer discretion to
      --call macth api
      --l_custom_match_profile := FND_PROFILE.Value('BOM:CUSTOM_MATCH');

       IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add('MATCH_CONFIGURED_ITEM:'||'CUSTOM_MATCH: ' || l_custom_match_profile, 1);
       END IF;


      IF   p_Source <> 'GOP'  THEN
                lStmtNum:=30;
		CTO_MATCH_CONFIG.Insert_into_bcol_gt(
					p_match_rec_of_tab =>p_cto_match_rec,
					x_return_status    =>x_return_status,
					x_msg_count	   =>X_msg_count,
					x_msg_data         =>X_msg_data
					);

	        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

		--    IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('MATCH_CONFIGURED_ITEM:'||'success after CTO_MATCH_CONFIG.Insert_into_bcol_gt', 1);
		--    END IF;


		ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
	            RAISE fnd_api.g_exc_error;
	        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	             RAISE fnd_api.g_exc_unexpected_error;
	        END IF;

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

  IF l_model_exists = 'Y' THEN

      lStmtNum:=50;
     CTO_MATCH_CONFIG.Update_BCOLGT_with_match_flag
     (
	x_return_status	=> x_return_status,
	x_msg_count	=> x_msg_count,
	x_msg_data	=> x_msg_data
     );

     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
	   --level1
	--    IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('MATCH_CONFIGURED_ITEM:'||'success after CTO_MATCH_CONFIG.Update_BCOLGT_with_match_flag', 1);
	--    END IF;
     ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
	     RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	      RAISE fnd_api.g_exc_unexpected_error;
     END IF;


     lStmtNum:=60;
     IF p_Source  NOT IN ('CTO','GOP')	THEN

         lStmtNum:=70;
	 CTO_MATCH_CONFIG.prepare_bcol_temp_data(
				   p_source           =>  p_Source,
				   p_match_rec_of_tab =>  p_cto_match_rec,
				   x_return_status    =>  x_return_status,
				   x_msg_count	       =>  X_msg_count,
				   x_msg_data         =>  X_msg_data
				  );
        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
	   --level1
	   -- IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('MATCH_CONFIGURED_ITEM:'||'success after CTO_MATCH_CONFIG.prepare_bcol_temp_data', 1);
	   -- END IF;
	ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
	     RAISE fnd_api.g_exc_error;
	ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	      RAISE fnd_api.g_exc_unexpected_error;
	END IF;


     END IF;--source = not cto/gop

     --Following needs to be executed for both
     --CTO and GOP
     lStmtNum:=80;
     SELECT ato_line_id
     BULK COLLECT INTO
            l_ato_line_tbl
     FROM bom_cto_order_lines_gt
     WHERE line_id =ato_line_id
     AND   top_model_line_id is not null
     AND   config_item_id is null
     AND bom_item_type = '1'; --implies item not re-used

    IF PG_DEBUG <> 0 THEN
	oe_debug_pub.add('MATCH_CONFIGURED_ITEM:'||'# of top most ato models=>'||sql%rowcount, 5);
     END IF;

     lStmtNum:=81;
     l_last_index := l_ato_line_tbl.count;
     IF PG_DEBUG <> 0 THEN
	oe_debug_pub.add('MATCH_CONFIGURED_ITEM:'||'l_ato_line_tbl.count='||l_last_index, 5);
     END IF;


     lStmtNum:=90;
     FOR i in 1..l_last_index LOOP

        lStmtNum:= 100;
        CTO_MATCH_CONFIG.perform_match
		(
		  p_ato_line_id		 => l_ato_line_tbl(i),
		--  p_custom_match_profile => l_custom_match_profile,
		  x_return_status    	 => x_return_status,
		  x_msg_count	   	 => x_msg_count,
		  x_msg_data         	 => x_msg_data
		);

        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
 	  --level 3
          IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('MATCH_CONFIGURED_ITEM:'||'success after CTO_MATCH_CONFIG.perform_match for line_id=>'
		                   ||l_ato_line_tbl(i), 3);
          END IF;


	ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
	       RAISE fnd_api.g_exc_error;
	ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	       RAISE fnd_api.g_exc_unexpected_error;
        END IF;

     END LOOP;


     lStmtNum:= 110;

     SELECT  config_item_id,
             perform_match
     BULK COLLECT INTO
	 --during Ut make sure next statement
	 --over writes existing values , ifnot
	 --additional rows may get created during
	 --for MATCH 0n cases. remove comment after UT
             p_cto_match_rec.config_item_id,
	     p_cto_match_rec.perform_match
     FROM bom_cto_order_lines_gt;


  END IF; --if model eixsts

  lStmtNum:= 120;
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




 EXCEPTION
      WHEN fnd_api.g_exc_error THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('MATCH_CONFIGURED_ITEM: ' || 'Exception in stmt num: '
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
        	oe_debug_pub.add('MATCH_CONFIGURED_ITEM: ' || ' Unexpected Exception in stmt num: '
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

        	oe_debug_pub.add('MATCH_CONFIGURED_ITEM: ' || 'Others Exception in stmt num: '
		              || to_char(lStmtNum), 1);
	         oe_debug_pub.add('error '||sqlerrm,1);
       END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );


 END MATCH_CONFIGURED_ITEM;




END CTO_Configured_Item_GRP;

/
