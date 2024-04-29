--------------------------------------------------------
--  DDL for Package ENI_DBI_RVR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_DBI_RVR_PKG" AUTHID CURRENT_USER AS
/* $Header: ENIRVRPS.pls 115.0 2003/10/31 22:50:36 sbag noship $ */

PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL);

END ENI_DBI_RVR_PKG ;

 

/
