--------------------------------------------------------
--  DDL for Package POA_DBI_PC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_PC_PKG" 
/* $Header: poadbipcs.pls 120.1 2005/09/14 05:38:22 sriswami noship $*/
AUTHID CURRENT_USER AS
  PROCEDURE status_sql(p_param		IN	    BIS_PMV_PAGE_PARAMETER_TBL
		      ,x_custom_sql	OUT NOCOPY  VARCHAR2,
		       x_custom_output	OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL);

  PROCEDURE dtl_rpt_sql(p_param         IN          BIS_PMV_PAGE_PARAMETER_TBL
                       ,x_custom_sql    OUT NOCOPY  VARCHAR2
                       ,x_custom_output OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL);

END poa_dbi_pc_pkg;

 

/
