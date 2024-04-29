--------------------------------------------------------
--  DDL for Package POA_DBI_CUD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_CUD_PKG" 
/* $Header: poadbicuds.pls 120.1 2005/09/14 05:36:55 sriswami noship $*/
AUTHID CURRENT_USER AS

  PROCEDURE con_drill_rpt_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

  PROCEDURE ncp_drill_rpt_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

  PROCEDURE pcl_drill_rpt_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END poa_dbi_cud_pkg;

 

/
