--------------------------------------------------------
--  DDL for Package BIS_BIA_MSGLOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_BIA_MSGLOG_PKG" AUTHID CURRENT_USER AS
/* $Header: BISPMVRS.pls 115.2 2004/03/09 13:47:42 tiwang noship $ */

 PROCEDURE Get_Sql (
            p_param 	IN 		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output OUT NOCOPY 	BIS_QUERY_ATTRIBUTES_TBL);

END BIS_BIA_MSGLOG_PKG;

 

/
