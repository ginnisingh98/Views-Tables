--------------------------------------------------------
--  DDL for Package BIS_PMV_QUERY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMV_QUERY_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVQUES.pls 115.26 2003/01/10 01:38:25 serao noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile:~PROD:~PATH:~FILE
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

QUERY_STR_KEY CHAR(4) := 'QSTR';
VIEW_BY_KEY CHAR(6) := 'VIEWBY';
ORDER_BY_KEY CHAR(7) := 'ORDERBY';

procedure getQuerySQL(p_region_code in VARCHAR2,
 p_function_name in VARCHAR2,
                         p_user_id in VARCHAR2,
                         p_session_id in VARCHAR2,
                         p_resp_id in VARCHAR2,
                         p_page_id in VARCHAR2 DEFAULT NULL,
                         p_schedule_id in VARCHAR2 DEFAULT NULL,
                         p_sort_attribute in VARCHAR2 DEFAULT NULL,
                         p_sort_direction in VARCHAR2 DEFAULT NULL,
			 p_source         in VARCHAR2 DEFAULT 'REPORT',
                        p_lower_bound IN INTEGER DEFAULT 1,
                        p_upper_bound IN INTEGER DEFAULT -1,
                         x_sql out NOCOPY VARCHAR2,
                         x_target_alias out NOCOPY VARCHAR2,
			 x_has_target   out NOCOPY varchar2,
			 x_viewby_table out NOCOPY VARCHAR2,
                         x_return_status out NOCOPY VARCHAR2,
                         x_msg_count out NOCOPY NUMBER,
                         x_msg_data out NOCOPY VARCHAR2,
                      x_bind_variables in OUT NOCOPY VARCHAR2,
                      x_plsql_bind_variables in OUT NOCOPY VARCHAR2,
                      x_bind_indexes in OUT NOCOPY VARCHAR2,
                      x_bind_datatypes IN OUT NOCOPY VARCHAR2,
                      x_view_by_value OUT NOCOPY VARCHAR2
                         );

  procedure getQuery(p_region_code in VARCHAR2,
                      p_function_name in VARCHAR2,
                      p_user_id in VARCHAR2,
                      p_session_id in VARCHAR2,
                      p_resp_id in VARCHAR2,
                      p_page_id in VARCHAR2 DEFAULT NULL,
                      p_schedule_id in VARCHAR2 DEFAULT NULL,
                      p_sort_attribute in VARCHAR2 DEFAULT NULL,
                      p_sort_direction in VARCHAR2 DEFAULT NULL,
		      p_source         in varchar2 DEFAULT 'REPORT',
                      p_customization_code in varchar2 DEFAULT NULL,
                      p_lower_bound IN INTEGER DEFAULT 1,
                      p_upper_bound IN INTEGER DEFAULT -1,
                      x_sql out NOCOPY VARCHAR2,
                      x_target_alias out NOCOPY VARCHAR2,
		      x_has_target out NOCOPY varchar2,
		      x_viewby_table out NOCOPY varchar2,
                      x_return_status out NOCOPY VARCHAR2,
                      x_msg_count out NOCOPY NUMBER,
                      x_msg_data out NOCOPY VARCHAR2,
                      x_bind_variables out NOCOPY VARCHAR2,
                      x_plsql_bind_variables out NOCOPY VARCHAR2,
                      x_bind_indexes out NOCOPY VARCHAR2,
                      x_bind_datatypes  OUT NOCOPY VARCHAR2,
                      x_view_by_value OUT NOCOPY VARCHAR2
                      );

  function GET_NORMAL_SELECT(p_ak_region_item_rec in BIS_PMV_METADATA_PVT.AK_REGION_ITEM_REC) return varchar2;
  function APPLY_DATA_FORMAT(p_ak_region_item_rec in BIS_PMV_METADATA_PVT.AK_REGION_ITEM_REC) return varchar2;
  function GET_CALCULATE_SELECT(p_ak_region_item_rec in BIS_PMV_METADATA_PVT.AK_REGION_ITEM_REC
		,p_parameter_tbl  in BIS_PMV_PARAMETERS_PVT.PARAMETER_TBL_TYPE
	        ,p_base_column_tbl  in out NOCOPY BISVIEWER.t_char
		,p_aggregation_tbl  in out NOCOPY BISVIEWER.t_char) return varchar2;
  function REPLACE_FORMULA(p_ak_region_item_rec in BIS_PMV_METADATA_PVT.AK_REGION_ITEM_REC
,p_parameter_tbl in BIS_PMV_PARAMETERS_PVT.PARAMETER_TBL_TYPE
,p_base_column_tbl  in out NOCOPY BISVIEWER.t_char
,p_aggregation_tbl  in out NOCOPY BISVIEWER.t_Char) return varchar2;
  procedure GET_TARGET_SELECT(p_user_session_rec in BIS_PMV_SESSION_PVT.SESSION_REC_TYPE,
                              p_ak_region_item_rec in BIS_PMV_METADATA_PVT.AK_REGION_ITEM_REC,
                              p_parameter_tbl in BIS_PMV_PARAMETERS_PVT.PARAMETER_TBL_TYPE,
                              p_report_type in VARCHAR2,
                              p_plan_id in VARCHAR2,
                              p_viewby_dimension in VARCHAR2,
                              p_viewby_attribute2 in VARCHAR2,
                              p_viewby_id_name in VARCHAR2,
                              p_time_from_description in VARCHAR2,
                              p_time_to_description in VARCHAR2,
                              x_target_select out NOCOPY VARCHAR2,
                              x_no_target out NOCOPY boolean,
                              x_bind_variables in OUT NOCOPY VARCHAR2,
                              --x_bind_indexes in OUT NOCOPY VARCHAR2,
                              x_bind_count in out NOCOPY number
                      );
  function GET_DIMENSION_WHERE(p_parameter_rec in BIS_PMV_PARAMETERS_PVT.PARAMETER_REC_TYPE,
                               p_save_region_item_rec in BIS_PMV_METADATA_PVT.SAVE_REGION_ITEM_REC,
                               p_ak_region_rec in BIS_PMV_METADATA_PVT.AK_REGION_REC,
                               p_org_dimension_level in VARCHAR2,
                               p_org_dimension_level_value in VARCHAR2,
                               p_viewby_dimension in VARCHAR2,
                               p_time_id_name in VARCHAR2,
                               p_time_value_name in VARCHAR2,
                               p_region_code in VARCHAR2,
                               p_TM_alias in VARCHAR2,
                               x_bind_variables in OUT NOCOPY VARCHAR2,
                               --x_bind_indexes in OUT NOCOPY VARCHAR2,
                               x_bind_count in out NOCOPY number) return varchar2;
  function GET_TIME_WHERE(p_parameter_rec in BIS_PMV_PARAMETERS_PVT.PARAMETER_REC_TYPE,
                          p_save_region_item_rec in BIS_PMV_METADATA_PVT.SAVE_REGION_ITEM_REC,
                          p_ak_region_rec in BIS_PMV_METADATA_PVT.AK_REGION_REC,
                          p_org_dimension_level in VARCHAR2,
                          p_org_dimension_level_value in VARCHAR2,
                          p_viewby_dimension in VARCHAR2,
                          p_time_id_name in VARCHAR2,
                          p_time_value_name in VARCHAR2,
                          p_region_code in VARCHAR2,
                          p_TM_alias in VARCHAR2,
                          x_bind_variables in OUT NOCOPY VARCHAR2,
                          --x_bind_indexes in OUT NOCOPY VARCHAR2,
                          x_bind_count in out NOCOPY number) return varchar2;
  function GET_TIME_LABEL_WHERE(p_parameter_description in VARCHAR2,
                                p_time_value_name in VARCHAR2,
                                p_TM_alias in VARCHAR2,
                                   x_bind_variables in OUT NOCOPY VARCHAR2,
                                   --x_bind_indexes in OUT NOCOPY VARCHAR2,
                                   x_bind_count in out NOCOPY number) return varchar2;
  function GET_NON_TIME_WHERE(p_parameter_rec in BIS_PMV_PARAMETERS_PVT.PARAMETER_REC_TYPE,
                              p_save_region_item_rec in BIS_PMV_METADATA_PVT.SAVE_REGION_ITEM_REC,
                              p_source in varchar2 default null,
                                 x_bind_variables in OUT NOCOPY VARCHAR2,
                                 --x_bind_indexes in OUT NOCOPY VARCHAR2,
                                 x_bind_count in out NOCOPY number) return varchar2;
  function GET_NON_DIMENSION_WHERE(p_parameter_rec in BIS_PMV_PARAMETERS_PVT.PARAMETER_REC_TYPE,
                                   p_save_region_item_rec in BIS_PMV_METADATA_PVT.SAVE_REGION_ITEM_REC,
                                      x_bind_variables in OUT NOCOPY VARCHAR2,
                                      --x_bind_indexes in OUT NOCOPY VARCHAR2,
                                      x_bind_count in out NOCOPY number) return varchar2;
  function GET_LOV_WHERE(p_parameter_tbl in BIS_PMV_PARAMETERS_PVT.PARAMETER_TBL_TYPE,
                         p_where_clause in VARCHAR2,
                         p_region_code in VARCHAR2 ) return varchar2;
  function GET_GROUP_BY(p_disable_viewby in VARCHAR2,
                        p_viewby_id_name in VARCHAR2,
                        p_viewby_value_name in VARCHAR2,
                        p_viewby_dimension in VARCHAR2,
                        p_viewby_dimension_level in VARCHAR2,
                        p_extra_groupby in VARCHAR2,
                        p_user_groupby in VARCHAR2,
                        p_user_orderby in VARCHAR2,
                        p_no_target in BOOLEAN DEFAULT TRUE) return varchar2;
  function GET_ORDER_BY(p_disable_viewby in VARCHAR2,
                        p_sort_attribute in VARCHAR2,
                        p_sort_direction in VARCHAR2,
                        p_viewby_dimension in VARCHAR2,
                        p_viewby_dimension_level in VARCHAR2,
                        p_default_sort_attribute in VARCHAR2,
                        p_user_orderby in VARCHAR2) return varchar2;
  function GET_USER_STRING(p_user_string in VARCHAR2) return varchar2;
procedure sort
(pSortNameTbl   in out  NOCOPY BISVIEWER.t_char
,pSortValueTbl  in out  NOCOPY BISVIEWER.t_Char
);
procedure get_customized_order_by(p_viewby in varchar2,
                      p_attribute_code in varchar2,
                      p_region_code in varchar2,
                      p_user_id  in varchar2,
                      p_customization_code in varchar2,
                      p_main_order_by in out NOCOPY varchar2,
                      p_first_order_by in out NOCOPY varchar2,
                      p_second_order_by in out NOCOPY varchar2);
procedure get_custom_sql (		      p_source         in varchar2 DEFAULT 'REPORT',
                          pAKRegionRec in BIS_PMV_METADATA_PVT.AK_REGION_REC,
                          pParameterTbl in BIS_PMV_PARAMETERS_PVT.PARAMETER_TBL_TYPE,
                          pUserSession  in BIS_PMV_SESSION_PVT.SESSION_REC_TYPE,
                          p_sort_attribute in VARCHAR2 DEFAULT NULL,
                          p_sort_direction in VARCHAR2 DEFAULT NULL,
                          p_viewby_attribute2 IN VARCHAR2,
                          p_viewby_dimension IN VARCHAR2,
                          p_viewby_dimension_level IN VARCHAR2,
                          p_lower_bound IN INTEGER DEFAULT 1,
                          p_upper_bound IN INTEGER DEFAULT -1,
                          x_sql_string  out NOCOPY VARCHAR2,
			  x_bind_variables out NOCOPY VARCHAR2,
			  x_plsql_bind_variables out NOCOPY VARCHAR2,
			  x_bind_indexes out NOCOPY VARCHAR2,
                          x_bind_datatypes OUT NOCOPY VARCHAR2,
                          x_return_Status out NOCOPY VARCHAR2,
                          x_msg_data OUT NOCOPY varchar2,
			  x_msg_count OUT NOCOPY NUMBER,
        x_view_by_value OUT NOCOPY VARCHAR2);

FUNCTION getParameterAcronym (
  p_lookup_type IN VARCHAR2,
  p_Parameter_name IN VARCHAR2
) RETURN VARCHAR2 ;

PROCEDURE substitute_lov_where(
  pUserSession_rec IN BIS_PMV_SESSION_PVT.SESSION_REC_TYPE,
  pSchedule_id IN VARCHAR2,
  pSource In VARCHAR2 DEFAULT'REPORT',
  x_lov_where IN OUT NOCOPY VARCHAR2,
  x_return_status out NOCOPY VARCHAR2,
  x_msg_count out NOCOPY NUMBER,
  x_msg_data out NOCOPY VARCHAR2
) ;

procedure replace_with_bind_variables
(p_search_string in varchar2,
 p_bind_value in varchar2,
 p_bind_datatype IN number DEFAULT 2,
 p_initial_index in number,
 p_bind_function in varchar2 default null,
 p_bind_to_date in varchar2 default 'N',
 p_original_sql in varchar2,
 x_custom_sql in out NOCOPY varchar2,
 x_bind_variables in out NOCOPY varchar2,
 x_plsql_bind_variables in out NOCOPY varchar2,
 x_bind_indexes in out NOCOPY varchar2,
 x_bind_datatypes IN OUT NOCOPY VARCHAR2,
 x_bind_count in out NOCOPY number);
procedure replace_product_binds
(pUserSession in BIS_PMV_SESSION_PVT.SESSION_REC_TYPE,
p_original_sql IN VARCHAR2,
p_custom_output IN BIS_QUERY_ATTRIBUTES_TBL,
x_custom_sql IN OUT NOCOPY VARCHAR2,
x_bind_variables IN OUT NOCOPY VARCHAR2,
x_plsql_bind_variables IN OUT NOCOPY VARCHAR2,
x_bind_indexes IN OUT NOCOPY VARCHAR2,
x_bind_Datatypes IN OUT NOCOPY VARCHAR2,
x_bind_count IN OUT NOCOPY NUMBER,
x_view_by_value OUT NOCOPY VARCHAR2
);

end BIS_PMV_QUERY_PVT;

 

/
