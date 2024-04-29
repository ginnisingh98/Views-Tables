--------------------------------------------------------
--  DDL for Package FII_AP_INV_ACTIVITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AP_INV_ACTIVITY" AUTHID CURRENT_USER AS
/* $Header: FIIAPS4S.pls 115.3 2003/07/02 10:29:39 supandey noship $ */

  PROCEDURE get_inv_activity(
	p_page_parameter_tbl in         BIS_PMV_PAGE_PARAMETER_TBL,
	inv_act_anal_sql     out NOCOPY VARCHAR2,
	inv_act_anal_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

  PROCEDURE get_inv_type(
	p_page_parameter_tbl in         BIS_PMV_PAGE_PARAMETER_TBL,
	inv_type_sql         out NOCOPY VARCHAR2,
	inv_type_output      out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

  PROCEDURE get_electronic_inv(
	p_page_parameter_tbl in         BIS_PMV_PAGE_PARAMETER_TBL,
	elec_inv_sql         out NOCOPY VARCHAR2,
	elec_inv_output      out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

  PROCEDURE get_hold_activity(
	p_page_parameter_tbl in         BIS_PMV_PAGE_PARAMETER_TBL,
	get_hold_sql         out NOCOPY VARCHAR2,
	get_hold_output      out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

  PROCEDURE Local_Bind_Variable
                ( p_sqlstmt IN Varchar2,
                  p_page_parameter_tbl        IN BIS_PMV_PAGE_PARAMETER_TBL,
                  p_sql_output                OUT NOCOPY Varchar2,
                  p_bind_output_table         OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL,
                  p_record_type_id            IN Number   Default Null,
                  p_view_by                   IN Varchar2 Default Null,
                  p_gid                       IN Number   Default Null,
                  p_period_start              IN Date     Default null,
                  p_report_start              IN Date     Default null,
                  p_cur_effective_num         IN Number   Default Null,
                  p_period_id                 IN Number   Default Null);

  PROCEDURE get_period_details(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
                            p_period_start       OUT NOCOPY Date,
                            p_cur_period         OUT NOCOPY Number,
                            p_id_column          OUT NOCOPY Varchar2,
                            p_report_start       OUT NOCOPY DATE,
                            p_cur_effective_num  OUT NOCOPY number,
                            p_period_id          OUT NOCOPY number);

  PROCEDURE get_electronic_inv_trend (
        p_page_parameter_tbl            IN  BIS_PMV_PAGE_PARAMETER_TBL,
        electronic_inv_trend_sql        OUT NOCOPY VARCHAR2,
        electronic_inv_trend_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


END fii_ap_inv_activity;

 

/
