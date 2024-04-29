--------------------------------------------------------
--  DDL for Package PSB_WS_AMOUNTS_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WS_AMOUNTS_SETUP" AUTHID CURRENT_USER as
/* $Header: PSBVWASS.pls 115.3 2002/11/22 07:39:10 pmamdaba ship $ */
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

  Function  ws_get_totals(p_worksheet_id in number,   p_stage in number,
			p_position_line_id in number, p_service_package_id in number,
			p_element_set_id in number,   p_budget_year_id in number)
			RETURN Number;
	pragma RESTRICT_REFERENCES(ws_get_totals, WNDS, WNPS);

End psb_ws_amounts_setup;

 

/
