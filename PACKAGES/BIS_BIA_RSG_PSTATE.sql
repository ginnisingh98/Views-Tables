--------------------------------------------------------
--  DDL for Package BIS_BIA_RSG_PSTATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_BIA_RSG_PSTATE" AUTHID CURRENT_USER AS
/* $Header: BISPGSTS.pls 120.0 2005/06/01 14:36:48 appldev noship $ */

 FUNCTION duration(
	p_duration		number) return VARCHAR2;

 PROCEDURE Get_Sql (
            p_param 	IN 		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output OUT NOCOPY 	BIS_QUERY_ATTRIBUTES_TBL);

 FUNCTION get_refresh_mode(P_REQUEST_SET_NAME varchar2) RETURN VARCHAR2; --added for bug 4183903

 function sync_last_refresh_time(p_last_refresh_time in date) return date;

END BIS_BIA_RSG_PSTATE;

 

/
