--------------------------------------------------------
--  DDL for Package PER_DRT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DRT_SWI" AUTHID CURRENT_USER as
/* $Header: pedrtswi.pkh 120.0.12010000.2 2018/04/13 09:34:56 gahluwal noship $ */

procedure insert_tables_details
  (p_product_code								in varchar2
  ,p_schema											in varchar2
  ,p_table_name            			in varchar2
  ,p_table_phase			        	in number default '100'
  ,p_record_identifier					in varchar2 default null
  ,p_entity_type                in varchar2 default null
  ,p_table_id                   in out nocopy number
  ,p_return_status              out nocopy varchar2
  );

procedure insert_columns_details
  (p_table_id                  	in number
	,p_column_name								in varchar2
  ,p_column_phase            		in number	default '1'
  ,p_attribute			    				in varchar2 default null
  ,p_ff_type             				in varchar2 default 'NONE'
  ,p_rule_type                  in varchar2 default null
  ,p_parameter_1								in varchar2 default null
  ,p_parameter_2            		in varchar2 default null
  ,p_comments			            	in varchar2 default null
  ,p_column_id                  in out nocopy number
  ,p_return_status              out nocopy varchar2
 );

procedure insert_col_contexts_details
  (p_column_id                  in number
  ,p_ff_name             				in varchar2
  ,p_context_name             	in varchar2
	,p_column_name								in varchar2
  ,p_column_phase            		in number
  ,p_attribute			    				in varchar2 default null
  ,p_rule_type                  in varchar2	default null
  ,p_parameter_1								in varchar2	default null
  ,p_parameter_2            		in varchar2	default null
  ,p_comments			            	in varchar2	default null
  ,p_ff_column_id              	in out nocopy number
  ,p_return_status              out nocopy varchar2
 );

procedure update_tables_details
  (p_table_id										in number
	,p_product_code								in varchar2
  ,p_schema											in varchar2
  ,p_table_name            			in varchar2
  ,p_table_phase			        	in number default '100'
  ,p_record_identifier					in varchar2	default hr_api.g_varchar2
  ,p_entity_type                in varchar2	default hr_api.g_varchar2
  ,p_return_status              out nocopy varchar2
  );

procedure update_columns_details
  (p_column_id						in number
	,p_table_id							in number
  ,p_column_name					in varchar2
  ,p_column_phase					in number	default '1'
  ,p_attribute			    	in varchar2 default hr_api.g_varchar2
  ,p_ff_type             	in varchar2 default 'NONE'
  ,p_rule_type            in varchar2 default hr_api.g_varchar2
  ,p_parameter_1					in varchar2 default hr_api.g_varchar2
  ,p_parameter_2          in varchar2 default hr_api.g_varchar2
  ,p_comments			        in varchar2 default hr_api.g_varchar2
  ,p_return_status              out nocopy varchar2
  );

procedure update_col_contexts_details
  (p_ff_column_id					in number
	,p_column_id						in number
  ,p_ff_name             	in varchar2
  ,p_context_name         in varchar2
  ,p_column_name					in varchar2
  ,p_column_phase					in number
  ,p_attribute			    	in varchar2 default hr_api.g_varchar2
  ,p_rule_type            in varchar2	default hr_api.g_varchar2
  ,p_parameter_1					in varchar2	default hr_api.g_varchar2
  ,p_parameter_2          in varchar2	default hr_api.g_varchar2
  ,p_comments			        in varchar2	default hr_api.g_varchar2
  ,p_return_status              out nocopy varchar2
  );

procedure delete_drt_details
  (p_table_id					           in 		number default null
	,p_column_id					         in 		number default null
	,p_ff_column_id					       in 		number default null
  ,p_return_status              out nocopy varchar2
  );

function getTableName(p_table_id in NUMBER
) return VARCHAR2 ;

Procedure getColumnDetails(p_tableName in varchar2, p_schema in varchar2,
                           p_colName in varchar2, p_dt  out nocopy varchar2,
              p_na  out nocopy varchar2, p_ffTye out nocopy varchar2, p_ffName out nocopy varchar2);

function getdataType(p_tableId in Number,
                          p_colName in VARCHAR2
) return VARCHAR2;

function getnullable(p_tableId in Number,
                          p_colName in VARCHAR2
) return VARCHAR2;

function getFlexFieldName(p_tableName in VARCHAR2,
                          p_colName in VARCHAR2
) return VARCHAR2;

function getFlexFieldType(p_tableName in VARCHAR2,
                          p_colName in VARCHAR2
) return VARCHAR2;

function getTableNameForFlex(p_col_id in NUMBER
) return VARCHAR2;

procedure getFlexColumnForValidation(p_ffType in varchar2,
                                    p_flexName in varchar2,
                                    p_contextCode in varchar2,
                                    p_contextColName out nocopy varchar2,
                                    p_kffFlexNum out nocopy varchar2);
END PER_DRT_SWI;


/
