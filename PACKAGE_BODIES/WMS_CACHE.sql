--------------------------------------------------------
--  DDL for Package Body WMS_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_CACHE" AS
/* $Header: WMSCACHB.pls 120.0.12010000.3 2009/09/23 19:00:09 mchemban noship $ */

FUNCTION UOM_CONVERT (
        item_id     NUMBER ,
        precision   NUMBER ,
        from_quantity NUMBER ,
        from_unit VARCHAR2 ,
        to_unit	  VARCHAR2  )
                            RETURN NUMBER IS

    l_result     NUMBER;
    l_uom_rate   NUMBER;
    l_hash_value NUMBER;
    l_hash_string VARCHAR2(2000);
    l_precision  NUMBER := precision;

  BEGIN

    l_hash_string := from_unit||'-'||to_unit||'-'||item_id;

    l_hash_value  := DBMS_UTILITY.get_hash_value
                                      ( name      => l_hash_string
                                      , base      => g_hash_base
                                      , hash_size => g_hash_size
                                      );
    IF g_from_to_uom_ratio_tbl.EXISTS(l_hash_value)
              AND g_from_uom_code_tbl(l_hash_value) = from_unit
              AND g_to_uom_code_tbl(l_hash_value)   = to_unit
              AND g_item_tbl(l_hash_value)          = item_id
    THEN
          l_uom_rate := g_from_to_uom_ratio_tbl(l_hash_value);

    ELSE
	  -- Compute conversion ratio between transaction UOM and item primary UOM
          inv_convert.inv_um_conversion( from_unit => from_unit ,
                                          to_unit   => to_unit   ,
                                          item_id   => item_id   ,
                                          uom_rate  => l_uom_rate
                                            );

            IF (l_uom_rate = -99999 )  THEN
	      RETURN l_uom_rate; /*8934647*/
	    END IF;

            g_from_uom_code_tbl(l_hash_value)     := from_unit;
            g_to_uom_code_tbl(l_hash_value)       := to_unit;
	    g_item_tbl(l_hash_value)		:= item_id ;
            g_from_to_uom_ratio_tbl(l_hash_value)  := l_uom_rate;

            --Now store the inverse

            l_hash_string := to_unit||'-'|| from_unit||'-'||item_id;
            l_hash_value  := DBMS_UTILITY.get_hash_value
                                      ( name      => l_hash_string
                                      , base      => g_hash_base
                                      , hash_size => g_hash_size
                                      );
            g_from_uom_code_tbl(l_hash_value)     := to_unit;
            g_to_uom_code_tbl(l_hash_value)       := from_unit;
	    g_item_tbl(l_hash_value)		:= item_id ;
            g_from_to_uom_ratio_tbl(l_hash_value)  := 1/l_uom_rate;

    END IF;

    IF ( from_quantity IS NOT NULL ) THEN
            l_result := from_quantity * l_uom_rate;
    END IF;

      l_precision := PRECISION;

    IF (l_precision IS NULL) THEN --default precision is 5
        l_precision := 5 ;
    END IF;

    RETURN round(l_result , l_precision);

END UOM_CONVERT;


FUNCTION get_Strategy_from_cache (
   	                              p_strategy_id           IN   NUMBER ,
	                                x_return_status         OUT  NOCOPY  varchar2,
                                  x_msg_count             OUT  NOCOPY  number,
                                  x_msg_data              OUT  NOCOPY  varchar2,
	                                x_over_alloc_mode	      OUT  NOCOPY  NUMBER,
	                                x_tolerance	out NOCOPY  NUMBER
                                  ) RETURN NUMBER IS

  l_org_id         NUMBER;
  l_rule_counter   NUMBER := 0 ;

  CURSOR rules_cur IS
      SELECT  wsm.rule_id ,
              wsm.partial_success_allowed_flag
        FROM  wms_strategy_members  wsm ,
	      wms_rules_b		 wrb
      WHERE wsm.strategy_id  = p_strategy_id
        AND wrb.rule_id 	    = wsm.rule_id
        AND wrb.enabled_flag = 'Y'
        AND wms_datecheck_pvt.date_valid (l_org_id,
				        wsm.date_type_code,
				        wsm.date_type_from,
				        wsm.date_type_to,
				        wsm.effective_from,
				        wsm.effective_to) = 'Y' ;




  BEGIN
  IF (strategy_tbl.EXISTS(p_strategy_id) ) THEN  --The strategy is already there in cache

	      x_over_alloc_mode := strategy_tbl(p_strategy_id).over_allocation_mode;
	      x_tolerance             := strategy_tbl(p_strategy_id).tolerance_value;
  FOR ii IN strategy_tbl(p_strategy_id).rule_id_tbl.FIRST .. strategy_tbl(p_strategy_id).rule_id_tbl.LAST LOOP
    /*
    This will store all the rules into the pl/sql table that has been used by rules engine to work on the current data
    */
      Wms_re_common_pvt.InitRule (
                  strategy_tbl(p_strategy_id).rule_id_tbl(ii) ,
                  strategy_tbl(p_strategy_id).partial_succ_flag_tbl(ii),
                  l_rule_counter
        );

  END LOOP;


  ELSE  --Need to get strategy details from DB table

      SELECT wsb.organization_id ,
          NVL(wsb.over_allocation_mode, 1) ,
            wsb.tolerance_value
      INTO   l_org_id,
	           x_over_alloc_mode,
             x_tolerance
      FROM   wms_strategies_b  wsb
      WHERE wsb.strategy_id  = p_strategy_id;

      strategy_tbl(p_strategy_id).over_allocation_mode := x_over_alloc_mode;
      strategy_tbl(p_strategy_id).tolerance_value := x_tolerance;

      OPEN rules_cur ; --get rules for the strategy
      LOOP
	      FETCH rules_cur BULK COLLECT INTO
			  strategy_tbl(p_strategy_id).rule_id_tbl,
			  strategy_tbl(p_strategy_id).partial_succ_flag_tbl
	        LIMIT g_bulk_fetch_limit;

	      EXIT WHEN strategy_tbl(p_strategy_id).rule_id_tbl.COUNT = 0;
  FOR ii IN strategy_tbl(p_strategy_id).rule_id_tbl.FIRST .. strategy_tbl(p_strategy_id).rule_id_tbl.LAST LOOP
    /*
    This will store all the rules into the pl/sql table that has been used by rules engine to work on the current data
    */
      Wms_re_common_pvt.InitRule (
                  strategy_tbl(p_strategy_id).rule_id_tbl(ii) ,
                  strategy_tbl(p_strategy_id).partial_succ_flag_tbl(ii),
                  l_rule_counter
        );

  END LOOP;


      END LOOP;
    Close rules_cur;
  END IF;


  RETURN  l_rule_counter;

  EXCEPTION
  WHEN OTHERS THEN
  RETURN -999;
END get_Strategy_from_cache;

PROCEDURE cleanup_rules_cache IS
  BEGIN
    strategy_tbl.DELETE;
  EXCEPTION
   WHEN OTHERS THEN
   NULL;

  END cleanup_rules_cache ;

END wms_cache;

/
