--------------------------------------------------------
--  DDL for Package CSP_ITEM_PL_PARAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_ITEM_PL_PARAMS_PVT" AUTHID CURRENT_USER AS
/* $Header: cspvpips.pls 120.0 2006/01/11 16:22:51 phegde noship $ */
--
-- Purpose: Insert or update table mtl_item_pl_params based on some conditions
--
-- MODIFICATION HISTORY
-- Person      Date      Comments
-- ---------   ------    ------------------------------------------
--  phegde      01/05/06  created package


  PROCEDURE merge_item_params
     (  p_organization_id       NUMBER
       ,p_inventory_item_id     NUMBER
       ,p_excess_service_level  NUMBER
       ,p_repair_service_level  NUMBER
       ,p_newbuy_service_level  NUMBER
       ,p_excess_edq_factor     NUMBER
       ,p_repair_edq_factor     NUMBER
       ,p_newbuy_edq_factor     NUMBER
       ,p_excess_edq_multiple   NUMBER
       ,p_repair_edq_multiple   NUMBER
       ,p_newbuy_edq_multiple   NUMBER
     );

END;

 

/
