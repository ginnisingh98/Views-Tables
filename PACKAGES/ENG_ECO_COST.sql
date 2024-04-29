--------------------------------------------------------
--  DDL for Package ENG_ECO_COST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_ECO_COST" AUTHID CURRENT_USER AS
/* $Header: ENGCOSTS.pls 120.2 2006/03/27 06:55:54 sdarbha noship $ */

	-- Global variable to store the esitmated cost so that the
	-- report can read it.
	g_estimated_cost	NUMBER;

        PROCEDURE Eco_Cost_Calculate ( p_change_notice IN varchar2,
                                       p_org_id        IN number,
                                       p_plan_name     IN varchar2,
                                       p_start_date    IN DATE,
                                       p_end_date      IN DATE,
                                       p_query_id      IN number);

	FUNCTION get_estimated_cost RETURN NUMBER;

END Eng_Eco_Cost;

 

/
