--------------------------------------------------------
--  DDL for Package WMS_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_CACHE" AUTHID CURRENT_USER AS
/* $Header: WMSCACHS.pls 120.0.12010000.3 2009/08/21 05:52:52 kjujjuru noship $*/

-- File        : WMSCACHS.pls
-- Content     : wms_cahce package specification
-- Description : WMS Cache public API's

  g_hash_base                        NUMBER        := 1;
  g_hash_size                        NUMBER        := POWER(2, 25);
  g_bulk_fetch_limit       CONSTANT  NUMBER        := 1000;

 TYPE tbl_num          IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
 TYPE tbl_varchar3     IS TABLE OF VARCHAR2(3)   INDEX BY BINARY_INTEGER;

 g_from_uom_code_tbl                tbl_varchar3;
 g_to_uom_code_tbl                  tbl_varchar3;
 g_from_to_uom_ratio_tbl            tbl_num;
 g_item_tbl                         tbl_num;



 TYPE tbl_plsint IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
 TYPE Strategy_rec_type IS RECORD (
     over_allocation_mode  wms_strategies_b.over_allocation_mode%TYPE,
     tolerance_value       wms_strategies_b.tolerance_value%TYPE,
     rule_id_tbl           tbl_num,
     partial_succ_flag_tbl tbl_plsint
 );

 TYPE strategy_tbl_type IS TABLE OF Strategy_rec_type INDEX BY BINARY_INTEGER;
 strategy_tbl strategy_tbl_type;

Function UOM_CONVERT (
        item_id   number,
        precision number,
        from_quantity number,
        from_unit varchar2,
        to_unit	  varchar2 )
                            RETURN NUMBER;


/*************************************/
-- This function will be used to cache strategy, its properties like over allocation mode and tolerance, list of rule_ids associated and value of partial success flag associated.
-- This function will be called from wms_stategy_pvt when a new strategy comes in.
-- This fucntion will intern call the API   Wms_re_common_pvt.InitRule() to store all the rules in the PL/SQL table on which the rules engine works currenlty.
-- Inputs-
--      p_strategy_id            - Strategy id of the strategy that's is being applied by WMS Rules engine
-- Outputs-
--     x_over_alloc_mode     - Over allocation mode
--     x_toelrance	       - Over allocation tolerance.
-- Return value -
--     The function will return number of rules associated with the strategy.
/*************************************/

Function get_Strategy_from_cache (
   	p_strategy_id           IN NUMBER ,
	  x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,
	  x_over_alloc_mode	      OUT NOCOPY  NUMBER,
	  x_tolerance	            OUT NOCOPY  NUMBER
    ) RETURN NUMBER;

/*************************************/
--This procedure is to remove all the rules cached
/*************************************/
PROCEDURE cleanup_rules_cache;

END wms_cache;

/
