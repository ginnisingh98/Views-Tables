--------------------------------------------------------
--  DDL for Package MRP_OE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_OE" AUTHID CURRENT_USER AS
/* $Header: MRPPNOES.pls 120.0 2005/05/25 03:51:01 appldev noship $ */

/*-------------------------------------------------------------------+
 | Define constants                                                  |
 +------------------------------------------------------------------*/

    MTL_SALES_ORDER         CONSTANT INTEGER := 2;      /* sales order */
    MTL_INT_SALES_ORDER     CONSTANT INTEGER := 8;      /* internal sales
                                                           order */

    IN_PROCESS              CONSTANT INTEGER := 3;

/*-------------------------------------------------------------------+
 | Define functions                                                  |
 +------------------------------------------------------------------*/

FUNCTION mrp_quantity(p_demand_id IN NUMBER) RETURN NUMBER;
pragma restrict_references(mrp_quantity, WNDS,WNPS);

FUNCTION mrp_date(p_demand_id IN NUMBER) RETURN DATE;
pragma restrict_references(mrp_date, WNDS,WNPS);

FUNCTION available_to_mrp(p_demand_id IN NUMBER) RETURN NUMBER;
pragma restrict_references(available_to_mrp, WNDS,WNPS);

FUNCTION updated_flag(p_demand_id IN NUMBER) RETURN NUMBER;
pragma restrict_references(updated_flag, WNDS,WNPS);

FUNCTION available_to_atp(p_demand_id IN NUMBER) RETURN NUMBER;
pragma restrict_references(available_to_atp, WNDS,WNPS);

FUNCTION total_reserv_qty (p_demand_id IN NUMBER) RETURN NUMBER;
pragma restrict_references(total_reserv_qty, WNDS,WNPS);

END MRP_OE;

 

/
