--------------------------------------------------------
--  DDL for Package ENI_DBI_CFM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_DBI_CFM_PKG" AUTHID CURRENT_USER AS
/* $Header: ENICFMPS.pls 115.0 2003/10/28 00:24:06 sbag noship $ */

PROCEDURE Get_Sql (	p_param		IN	     BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY   VARCHAR2,
			x_custom_output	OUT NOCOPY   BIS_QUERY_ATTRIBUTES_TBL);

END ENI_DBI_CFM_PKG;

 

/
