--------------------------------------------------------
--  DDL for Package ISC_MAINT_WO_BACKLOG_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_MAINT_WO_BACKLOG_RPT_PKG" 
/*$Header: iscmaintwoblrpts.pls 120.0 2005/05/25 17:21:57 appldev noship $ */
AUTHID CURRENT_USER as

 PROCEDURE get_tbl_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL, x_custom_sql OUT NOCOPY VARCHAR2, x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

 PROCEDURE get_trd_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL, x_custom_sql OUT NOCOPY VARCHAR2, x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

 PROCEDURE get_wo_bl_dtl_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL, x_custom_sql  OUT NOCOPY VARCHAR2, x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

 PROCEDURE get_cur_past_due_dtl_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL, x_custom_sql  OUT NOCOPY VARCHAR2, x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

 PROCEDURE get_pastdue_aging_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL, x_custom_sql OUT NOCOPY VARCHAR2, x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


end ISC_MAINT_WO_BACKLOG_RPT_PKG;

 

/
