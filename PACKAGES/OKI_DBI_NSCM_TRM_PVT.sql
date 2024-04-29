--------------------------------------------------------
--  DDL for Package OKI_DBI_NSCM_TRM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_DBI_NSCM_TRM_PVT" AUTHID CURRENT_USER AS
/* $Header: OKIPNTRS.pls 120.1 2006/03/28 23:32:39 asparama noship $ */

  PROCEDURE Get_Terminations_Sql(
	p_param			IN		BIS_PMV_PAGE_PARAMETER_TBL,
	x_custom_sql		OUT NOCOPY	VARCHAR2,
	x_custom_output		OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL);

  FUNCTION Get_Terminations_Sel_Clause(
	p_view_by_dim		IN	VARCHAR2,
	p_view_by_col		IN	VARCHAR2) RETURN VARCHAR2;

  PROCEDURE Get_Terminations_Detail_Sql(
	p_param			IN		BIS_PMV_PAGE_PARAMETER_TBL,
	x_custom_sql		OUT	NOCOPY	VARCHAR2,
	x_custom_output		OUT	NOCOPY	BIS_QUERY_ATTRIBUTES_TBL);

  PROCEDURE Get_Terminations_Trend_Sql(
	p_param			IN      	BIS_PMV_PAGE_PARAMETER_TBL,
	x_custom_sql		OUT	NOCOPY	VARCHAR2,
	x_custom_output		OUT	NOCOPY	BIS_QUERY_ATTRIBUTES_TBL);

   FUNCTION Get_Trm_Trend_Sel_Clause	RETURN VARCHAR2;

END OKI_DBI_NSCM_TRM_PVT;

 

/
