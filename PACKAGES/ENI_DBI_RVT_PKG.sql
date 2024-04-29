--------------------------------------------------------
--  DDL for Package ENI_DBI_RVT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_DBI_RVT_PKG" AUTHID CURRENT_USER AS
/* $Header: ENIRVTPS.pls 115.0 2003/12/29 21:15:14 sbag noship $ */

PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL);

END ENI_DBI_RVT_PKG ;

 

/
