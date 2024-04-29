--------------------------------------------------------
--  DDL for Package ISC_MAINT_WO_CMPL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_MAINT_WO_CMPL_RPT_PKG" 
/*$Header: iscmaintwocrpts.pls 120.0 2005/05/25 17:26:00 appldev noship $ */
AUTHID CURRENT_USER as

 PROCEDURE get_tbl_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL, x_custom_sql OUT NOCOPY VARCHAR2, x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

 PROCEDURE get_late_cmpl_age(p_param in BIS_PMV_PAGE_PARAMETER_TBL, x_custom_sql OUT NOCOPY VARCHAR2, x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

 PROCEDURE get_trd_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL, x_custom_sql OUT NOCOPY VARCHAR2, x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

 PROCEDURE get_wo_dtl_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL, x_custom_sql  OUT NOCOPY VARCHAR2, x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

 PROCEDURE get_wo_late_dtl_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL, x_custom_sql  OUT NOCOPY VARCHAR2, x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


end isc_maint_wo_cmpl_rpt_pkg;

 

/
