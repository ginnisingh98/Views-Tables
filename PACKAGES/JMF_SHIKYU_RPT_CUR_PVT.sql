--------------------------------------------------------
--  DDL for Package JMF_SHIKYU_RPT_CUR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JMF_SHIKYU_RPT_CUR_PVT" AUTHID CURRENT_USER AS
--$Header: JMFVCURS.pls 120.5 2005/12/05 20:14:57 vchu noship $
--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :            JMFVCURS.pls                                       |
--|                                                                           |
--|  DESCRIPTION:          Specification file of the package for creating     |
--|                        temporary data for the Shikyu Cost Update          |
--|                        Analysis report.                                   |
--|                                                                           |
--|  HISTORY:                                                                 |
--|   28-MAY-2005          fwang  Created.                                    |
--|   30-NOV-2005          Sherly added a new function FUNCTION               |
--|                        is_current_period                                  |
--|   05-DEC-2005          Sherly added a new parameter  p_rate_not_found     |
--+===========================================================================+

  --========================================================================
  -- PROCEDURE : cuar_get_cost_data          PUBLIC
  -- PARAMETERS: p_cost_type_id              cost type id
  --           : p_ou_id                     operating unit id
  --           : p_inv_org_name_from         oem inventory org name from
  --           : p_inv_org_name_to           oem inventory org name to
  --           : p_run                       report run type
  --           : p_currency_cnv_type         currency conversion type
  --           : p_currency_cnv_date         currency conversion date
  --           : p_function_currency         Functional Currency
  --           : p_rate_not_found            Currency conversion Rate not found flag
  -- COMMENT   : used as portal to choose process according to run type
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE cuar_get_cost_data
  (
    p_cost_type_id      IN NUMBER
   ,p_org_id            IN NUMBER
   ,p_inv_org_name_from IN VARCHAR2
   ,p_inv_org_name_to   IN VARCHAR2
   ,p_run               IN VARCHAR2
   ,p_currency_cnv_type IN VARCHAR2
   ,p_currency_cnv_date IN VARCHAR2
   ,p_function_currency IN VARCHAR2
   ,p_rate_not_found OUT NOCOPY VARCHAR2
  );

  --========================================================================
  -- PROCEDURE : cuar_get_unreceived_po      PUBLIC
  -- PARAMETERS: p_cost_type_id              cost type id
  --           : p_ou_id                     operating unit id
  --           : p_inv_org_name_from         oem inventory org name from
  --           : p_inv_org_name_to           oem inventory org name to
  --           : p_currency_cnv_type         currency conversion type
  --           : p_currency_cnv_date         currency conversion date
  --           : p_func_currency_code        functional currency code
  -- COMMENT   : collect appropriate unreceived po qty data and insert into
  --             the temporary table
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE cuar_get_unreceived_po
  (
    p_cost_type_id       IN NUMBER
   ,p_org_id             IN NUMBER
   ,p_inv_org_name_from  IN VARCHAR2
   ,p_inv_org_name_to    IN VARCHAR2
   ,p_currency_cnv_type  IN VARCHAR2
   ,p_currency_cnv_date  IN DATE
   ,p_func_currency_code IN VARCHAR2
  );

  --========================================================================
  -- PROCEDURE : cuar_get_unshipped_so       PUBLIC
  -- PARAMETERS: p_cost_type_id              cost type id
  --           : p_ou_id                     operating unit id
  --           : p_inv_org_name_from         oem inventory org name from
  --           : p_inv_org_name_to           oem inventory org name to
  --           : p_currency_cnv_type         currency conversion type
  --           : p_currency_cnv_date         currency conversion date
  --           : p_func_currency_code        functional currency code
  -- COMMENT   : collect appropriate unshipped so qty data and insert into
  --             the temporary table
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE cuar_get_unshipped_so
  (
    p_cost_type_id       IN NUMBER
   ,p_org_id             IN NUMBER
   ,p_inv_org_name_from  IN VARCHAR2
   ,p_inv_org_name_to    IN VARCHAR2
   ,p_currency_cnv_type  IN VARCHAR2
   ,p_currency_cnv_date  IN DATE
   ,p_func_currency_code IN VARCHAR2
  );

  --========================================================================
  -- PROCEDURE : cuar_get_rma_so             PUBLIC
  -- PARAMETERS: p_cost_type_id              cost type id
  --           : p_ou_id                     operating unit id
  --           : p_inv_org_name_from         oem inventory org name from
  --           : p_inv_org_name_to           oem inventory org name to
  --           : p_currency_cnv_type         currency conversion type
  --           : p_currency_cnv_date         currency conversion date
  --           : p_func_currency_code        functional currency code
  -- COMMENT   : collect appropriate rma so qty data and insert into
  --             the temporary table
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE cuar_get_rma_so
  (
    p_org_id             IN NUMBER
   ,p_inv_org_name_from  IN VARCHAR2
   ,p_inv_org_name_to    IN VARCHAR2
   ,p_func_currency_code IN VARCHAR2
  );

  --========================================================================
  -- FUNCTION  : cuar_get_item_cost          PUBLIC
  -- PARAMETERS: p_ou_id                     operating unit id
  --           : p_item_id                   item id
  --           : p_cst_type_id               item cost type id
  -- RETURN    : will return the item cost
  -- COMMENT   : get item cost  for specific item
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION cuar_get_item_cost
  (
    p_org_id      IN NUMBER
   ,p_item_id     IN NUMBER
   ,p_cst_type_id IN NUMBER
  ) RETURN NUMBER;

  --========================================================================
  -- FUNCTION  : get_uom_primary          PUBLIC
  -- PARAMETERS: p_inventory_item_id      inventory item id
  --           : p_org_id                 organization id
  -- RETURN    : will return the primary uom
  -- COMMENT   : getting the  primary UOM
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_uom_primary
  (
    p_inventory_item_id IN NUMBER
   ,p_org_id            IN NUMBER
  ) RETURN VARCHAR2;

  --========================================================================
  -- FUNCTION  : get_uom_primary_code     PUBLIC
  -- PARAMETERS: p_inventory_item_id      inventory item id
  --           : p_org_id                 organization id
  -- RETURN    : will return the primary uom code
  -- COMMENT   : getting the  primary UOM code
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_uom_primary_code
  (
    p_inventory_item_id IN NUMBER
   ,p_org_id            IN NUMBER
  ) RETURN VARCHAR2;

  --========================================================================
  -- FUNCTION  : get_uom_primary_qty      PUBLIC
  -- PARAMETERS: p_inventory_item_id      inventory item id
  --           : p_org_id                 organization id
  --           : p_precision              precision
  --           : p_from_quantity          quantity of from UOM
  --           : p_from_unit              from UOM
  -- RETURN    : will return the quantity with primary uom
  -- COMMENT   : getting the quantity with primary uom
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_uom_primary_qty
  (
    p_inventory_item_id IN NUMBER
   ,p_org_id            IN NUMBER
   ,p_precision         IN NUMBER
   ,p_from_quantity     IN NUMBER
   ,p_from_unit         IN VARCHAR2
  ) RETURN NUMBER;

  --========================================================================
  -- FUNCTION  : get_uom_primary_qty_from_code     PUBLIC
  -- PARAMETERS: p_inventory_item_id               inventory item id
  --           : p_org_id                          organization id
  --           : p_precision                       precision
  --           : p_from_quantity                   quantity of from UOM
  --           : p_from_unit                       from UOM code
  -- RETURN    : will return the quantity with primary uom code
  -- COMMENT   : getting the quantity with primary uom code
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_uom_primary_qty_from_code
  (
    p_inventory_item_id IN NUMBER
   ,p_org_id            IN NUMBER
   ,p_precision         IN NUMBER
   ,p_from_quantity     IN NUMBER
   ,p_from_unit         IN VARCHAR2
  ) RETURN NUMBER;

   --========================================================================
  -- FUNCTION  : IS_CURRENT_PERIOD          PUBLIC
  -- PARAMETERS: p_date                     DATE
  --           : p_org_id                   Inventory org id
  --
  -- RETURN    : will return if input date is in current inventory accounting period
  -- COMMENT   :
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION is_current_period
  ( p_date IN DATE
    ,p_org_id IN NUMBER
  ) RETURN BOOLEAN   ;

END jmf_shikyu_rpt_cur_pvt;

 

/
