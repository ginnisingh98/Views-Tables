--------------------------------------------------------
--  DDL for Package IGW_PROP_COSTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_COSTS" AUTHID CURRENT_USER as
--$Header: igwprs2s.pls 115.3 2002/03/28 19:13:48 pkm ship    $

  FUNCTION get_annual_direct_costs(i_prop_id   	NUMBER) return NUMBER;
  pragma restrict_references(get_annual_direct_costs, wnds);

  FUNCTION get_total_costs(i_prop_id   	NUMBER) return NUMBER;
  pragma restrict_references(get_total_costs, wnds);

END IGW_PROP_COSTS;

 

/
