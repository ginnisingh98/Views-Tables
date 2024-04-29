--------------------------------------------------------
--  DDL for Package ENI_DBI_RVA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_DBI_RVA_PKG" AUTHID CURRENT_USER AS
/* $Header: ENIRVAPS.pls 115.0 2003/11/04 01:40:23 ansubram noship $ */

PROCEDURE Get_Sql (	p_param		IN	     BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY   VARCHAR2,
			x_custom_output	OUT NOCOPY   BIS_QUERY_ATTRIBUTES_TBL);

END ENI_DBI_RVA_PKG;

 

/
