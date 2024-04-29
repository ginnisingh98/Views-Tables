--------------------------------------------------------
--  DDL for Package WMS_OPP_CYC_COUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_OPP_CYC_COUNT" AUTHID CURRENT_USER AS
/* $Header: WMSOPCCS.pls 120.1.12010000.3 2010/03/08 12:00:04 abasheer noship $ */

TYPE t_genref IS REF CURSOR;

  FUNCTION is_cyc_count_enabled
  (  p_organization_id    IN NUMBER
   , p_subinventory_code  IN VARCHAR2
   , p_loc_id             IN NUMBER
   , p_inventory_item_id  IN NUMBER
  )
  RETURN NUMBER;

  PROCEDURE process_entry
  (p_cycle_count_header_id    IN    NUMBER            ,
   p_organization_id          IN    NUMBER            ,
   p_subinventory             IN    VARCHAR2          ,
   p_locator_id               IN    NUMBER   := NULL  ,
   p_parent_lpn_id            IN    NUMBER   := NULL  ,
   p_inventory_item_id        IN    NUMBER            ,
   p_revision                 IN    VARCHAR2 := NULL  ,
   p_lot_number               IN    VARCHAR2 := NULL  ,
   p_from_serial_number       IN    VARCHAR2 := NULL  ,
   p_to_serial_number         IN    VARCHAR2 := NULL  ,
   p_sys_quantity             IN    NUMBER            ,
   p_count_quantity           IN    NUMBER            ,
   p_count_uom                IN    VARCHAR2          ,
   p_unscheduled_count_entry  IN    NUMBER            ,
   p_user_id                  IN    NUMBER            ,
   p_cost_group_id            IN    NUMBER   := NULL  ,
   p_secondary_uom            IN VARCHAR2    := NULL  ,
   p_secondary_qty            IN NUMBER      := NULL
   );

  PROCEDURE process_summary
  (p_cycle_count_header_id    IN    NUMBER            ,
   p_organization_id          IN    NUMBER            ,
   p_subinventory             IN    VARCHAR2          ,
   p_locator_id               IN    NUMBER   := NULL  ,
   p_parent_lpn_id            IN    NUMBER   := NULL  ,
   p_inventory_item_id        IN    NUMBER            ,
   p_unscheduled_count_entry  IN    NUMBER            ,
   p_user_id                  IN    NUMBER
   );


END wms_opp_cyc_count;

/
