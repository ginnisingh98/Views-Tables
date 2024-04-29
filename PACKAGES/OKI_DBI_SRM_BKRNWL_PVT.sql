--------------------------------------------------------
--  DDL for Package OKI_DBI_SRM_BKRNWL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_DBI_SRM_BKRNWL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKIIBKGS.pls 120.1 2006/03/28 23:27:11 asparama noship $ */


	PROCEDURE get_rates_table_sql(
			p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql OUT NOCOPY VARCHAR2,
			x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

	PROCEDURE get_table_sql(
			p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql OUT NOCOPY VARCHAR2,
			x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

	PROCEDURE get_trend_sql(
			p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql OUT NOCOPY VARCHAR2,
			x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END OKI_DBI_SRM_BKRNWL_PVT;

 

/
