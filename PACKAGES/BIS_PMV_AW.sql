--------------------------------------------------------
--  DDL for Package BIS_PMV_AW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMV_AW" AUTHID CURRENT_USER AS
/* $Header: BISVAWDS.pls 120.0 2005/06/01 15:08:36 appldev noship $ */
	PROCEDURE SET_DIMENSION_LEVEL_VALUES (p_parameters_tbl  IN	BIS_PMV_PAGE_PARAMETER_TBL,
					      p_aw_name	    	IN	VARCHAR2);
END BIS_PMV_AW;

 

/
