--------------------------------------------------------
--  DDL for Package OE_BIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BIS" AUTHID CURRENT_USER AS
/* $Header: OEXBISRS.pls 115.2 99/10/13 14:41:23 porting shi $ */
function get_daily_value_shipped ( p_day          IN DATE,
                                   p_warehouse_id IN NUMBER,
				   p_currency     IN VARCHAR2)
   return number;
   pragma restrict_references (get_daily_value_shipped, WNDS, RNPS, WNPS);

function get_days_top_returns (p_day IN DATE,
                               p_org_id IN NUMBER)
   return NUMBER;
   pragma restrict_references (get_days_top_returns, WNDS);

function get_days_top_deliveries (p_day IN DATE,
                                  p_org_id IN NUMBER)
   return NUMBER;
   pragma restrict_references (get_days_top_deliveries, WNDS, RNPS, WNPS);

procedure get_top_customers    ( p_period_start IN DATE,
				 P_PERIOD_END   IN DATE,
                                 P_CURRENCY     IN VARCHAR2,
                                 P_ORG_ID       IN NUMBER );

procedure get_bbb_info         ( p_period_start IN DATE,
				 P_PERIOD_END   IN DATE,
                                 P_CURRENCY     IN VARCHAR2,
                                 P_ORG_ID       IN NUMBER );

end oe_bis;

 

/
