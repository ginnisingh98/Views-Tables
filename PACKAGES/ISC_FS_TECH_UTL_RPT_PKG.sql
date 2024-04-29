--------------------------------------------------------
--  DDL for Package ISC_FS_TECH_UTL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_FS_TECH_UTL_RPT_PKG" AUTHID CURRENT_USER AS
/*$Header: iscfstutlrpts.pls 120.0 2005/08/28 15:02:14 kreardon noship $ */
	PROCEDURE get_tbl_sql(
	    p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
	    x_custom_sql OUT NOCOPY VARCHAR2,
	    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
	);

	PROCEDURE get_trd_sql
	( p_param           in bis_pmv_page_parameter_tbl
	, x_custom_sql      out nocopy varchar2
	, x_custom_output   out nocopy bis_query_attributes_tbl
	);

END ISC_FS_TECH_UTL_RPT_PKG;

 

/
