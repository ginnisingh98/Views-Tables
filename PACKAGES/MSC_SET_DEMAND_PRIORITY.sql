--------------------------------------------------------
--  DDL for Package MSC_SET_DEMAND_PRIORITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_SET_DEMAND_PRIORITY" AUTHID CURRENT_USER AS
/* $Header: MSCDMPRS.pls 120.0 2005/05/25 19:59:54 appldev noship $ */
   FUNCTION MSC_DEMAND_PRIORITY(
        arg_plan_id   IN   NUMBER )	 RETURN NUMBER;

   FUNCTION GET_INTERPLANT_DEMAND_PRIORITY(
		arg_plan_id IN NUMBER,
		arg_trans_id IN NUMBER) RETURN NUMBER;

	LOWEST_PRIORITY INTEGER := 100000;

	  PRAGMA RESTRICT_REFERENCES (get_interplant_demand_priority, WNDS,WNPS);


END MSC_SET_DEMAND_PRIORITY;


 

/
