--------------------------------------------------------
--  DDL for Package ISC_DBI_PLAN_RM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_PLAN_RM_PKG" AUTHID CURRENT_USER AS
/* $Header: ISCRGAIS.pls 115.0 2003/07/14 20:36:44 chu noship $ */

PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL);

END ISC_DBI_PLAN_RM_PKG ;

 

/
