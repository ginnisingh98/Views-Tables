--------------------------------------------------------
--  DDL for Package MTL_ABC_COMPILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_ABC_COMPILE_PKG" AUTHID CURRENT_USER AS
/* $Header: INVCAACS.pls 120.1 2005/06/28 05:31:19 appldev ship $ */

-- This procedure is to perform ABC compile when user
-- choose Forecast usage value/forecast usage quantity.
-- This will get called from incaac.opp
PROCEDURE COMPILE_FUTURE_VALUE(x_organization_id IN NUMBER,
                               x_compile_id IN NUMBER,
                               x_forc_name IN VARCHAR2,
                               x_org_cost_group_id IN NUMBER,
                               x_cal_code IN VARCHAR2,
                               x_except_id IN NUMBER,
                               x_start_date IN VARCHAR2,
                               x_cutoff_date IN VARCHAR2,
                               x_item_scope_code IN NUMBER,
                               x_subinventory IN VARCHAR2);

-- This function will return item cost.
-- Gets called from above procedure COMPILE_FUTURE_VALUE()
FUNCTION GET_ITEM_COST(x_organization_id IN NUMBER,
              x_inventory_item_id IN NUMBER,
              x_project_id IN NUMBER,
              x_cost_group_id IN NUMBER) RETURN NUMBER;

-- BEGIN INVCONV
PROCEDURE CALCULATE_COMPILE_VALUE (
     p_organization_id   NUMBER
   , p_compile_id        NUMBER
   , p_cost_type_id      NUMBER);
-- END INVCONV

END MTL_ABC_COMPILE_PKG;

 

/
