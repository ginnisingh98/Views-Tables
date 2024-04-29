--------------------------------------------------------
--  DDL for Package PER_DRT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DRT_API" AUTHID CURRENT_USER as
/* $Header: pedrtapi.pkh 120.0.12010000.2 2018/04/13 09:21:35 gahluwal noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< INSERT_TABLES_DETAILS >--------------------------|
-- ----------------------------------------------------------------------------
-- Description:
-- Business process to create table details.
--
-- Prerequisites:
--
--
-- In Parameters:

--  Name                             Reqd Type     Description
--  p_product_code					         yes	varchar2
--  p_schema            				 		 yes	varchar2
--  p_table_name            				 yes	varchar2
--  p_table_phase			               yes	varchar2
--  p_record_identifier              yes	varchar2
--  p_entity_type                    yes	varchar2

--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
procedure insert_tables_details
  (p_product_code								in varchar2
  ,p_schema											in varchar2
  ,p_table_name            			in varchar2
  ,p_table_phase			        	in number default '100'
  ,p_record_identifier					in varchar2
  ,p_entity_type                in varchar2
  ,p_table_id                   in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< INSERT_COLUMNS_DETAILS >--------------------------|
-- ----------------------------------------------------------------------------
-- Description:
-- Business process to create table details.
--
-- Prerequisites:
--
--
-- In Parameters:

--  Name                             Reqd Type     Description
--	p_table_id                  number
--  p_column_name					      varchar2
--  p_column_phase							varchar2
--  p_attribute			            varchar2
--  p_ff_type             		 	varchar2
--  p_rule_type                	varchar2
--  p_parameter_1			          varchar2
--  p_parameter_2             	varchar2
--  p_comments                 	varchar2

--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
procedure insert_columns_details
  (p_table_id                  	in number
	,p_column_name								in varchar2
  ,p_column_phase            		in number default null
  ,p_attribute			    				in varchar2 default null
  ,p_ff_type             				in varchar2 default 'NONE'
  ,p_rule_type                  in varchar2 default null
  ,p_parameter_1								in varchar2 default null
  ,p_parameter_2            		in varchar2 default null
  ,p_comments			            	in varchar2 default null
  ,p_column_id                  in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< INSERT_COL_CONTEXTS_DETAILS >--------------------------|
-- ----------------------------------------------------------------------------
-- Description:
-- Business process to create table details.
--
-- Prerequisites:
--
--
-- In Parameters:

--  Name                             Reqd Type     Description
--	p_column_id									number
--  p_column_name					      varchar2
--  p_column_phase							varchar2
--  p_attribute			            varchar2
--  p_ff_name             		 	varchar2
--  p_context_name             	varchar2
--  p_rule_type                	varchar2
--  p_parameter_1			          varchar2
--  p_parameter_2             	varchar2
--  p_comments                 	varchar2

--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
procedure insert_col_contexts_details
  (p_column_id                  in number
  ,p_ff_name             				in varchar2
  ,p_context_name             	in varchar2
	,p_column_name								in varchar2
  ,p_column_phase            		in number	default '1'
  ,p_attribute			    				in varchar2
  ,p_rule_type                  in varchar2
  ,p_parameter_1								in varchar2	default null
  ,p_parameter_2            		in varchar2	default null
  ,p_comments			            	in varchar2	default null
  ,p_ff_column_id              	in out nocopy number
 );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_TABLES_DETAILS >-----------------------|
-- ----------------------------------------------------------------------------
-- Description:
-- Business process to update table details.
--
-- Prerequisites:
--
--
-- In Parameters:

--  Name                         Reqd Type     Description
--  p_table_id					         		 yes	varchar2
--  p_product_code					         yes	varchar2
--  p_table_name            				 yes	varchar2
--  p_schema            				 		 yes	varchar2
--  p_table_phase			               yes	varchar2
--  p_record_identifier              yes	varchar2
--  p_entity_type                    yes	varchar2
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
procedure update_tables_details
  (p_table_id										in number
	,p_product_code								in varchar2
  ,p_schema											in varchar2
  ,p_table_name            			in varchar2
  ,p_table_phase			        	in number default '100'
  ,p_record_identifier					in varchar2
  ,p_entity_type                in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_COLUMNS_DETAILS >-----------------------|
-- ----------------------------------------------------------------------------
-- Description:
-- Business process to update table details.
--
-- Prerequisites:
--
--
-- In Parameters:

--  Name                         Reqd Type     Description
--	p_column_id											yes 		number
--	p_column_name										yes 		varchar2
--	p_column_phase									yes			number
--	p_attribute			    						yes 		varchar2
--	p_ff_type             					yes 		varchar2
--	p_rule_type            					yes 		varchar2
--	p_parameter_1										yes 		varchar2
--	p_parameter_2          					yes 		varchar2
--	p_comments			        				yes 		varchar2
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
procedure update_columns_details
  (p_column_id						in number
	,p_table_id							in number
  ,p_column_name					in varchar2
  ,p_column_phase					in number		default null
  ,p_attribute			    	in varchar2 default null
  ,p_ff_type             	in varchar2 default 'NONE'
  ,p_rule_type            in varchar2 default null
  ,p_parameter_1					in varchar2 default null
  ,p_parameter_2          in varchar2 default null
  ,p_comments			        in varchar2 default null
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_COL_CONTEXTS_DETAILS >-----------------------|
-- ----------------------------------------------------------------------------
-- Description:
-- Business process to update table details.
--
-- Prerequisites:
--
--
-- In Parameters:

--  Name                         Reqd Type     Description
--	p_ff_column_id									yes 		number
--	p_ff_name             					yes 		varchar2
--	p_context_name         					yes 		varchar2
--	p_column_name										yes 		varchar2
--	p_column_phase									yes			number
--	p_attribute			    						yes 		varchar2
--	p_rule_type            					yes 		varchar2
--	p_parameter_1										yes 		varchar2
--	p_parameter_2          					yes 		varchar2
--	p_comments			        				yes 		varchar2
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
procedure update_col_contexts_details
  (p_ff_column_id					in number
	,p_column_id						in number
  ,p_ff_name             	in varchar2
  ,p_context_name         in varchar2
  ,p_column_name					in varchar2
  ,p_column_phase					in number default '1'
  ,p_attribute			    	in varchar2
  ,p_rule_type            in varchar2
  ,p_parameter_1					in varchar2	default null
  ,p_parameter_2          in varchar2	default null
  ,p_comments			        in varchar2	default null
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_DRT_DETAILS >-----------------------|
-- ----------------------------------------------------------------------------
-- Description:
-- Business process to delete table details.
--
-- Prerequisites:
--
--
-- In Parameters:
--  p_table_id					        		in		number default null
--  p_column_id            					in		number default null
--  p_ff_column_id            			in		number default null

-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
procedure delete_drt_details
  (p_table_id					           in 		number default null
	,p_column_id					         in 		number default null
	,p_ff_column_id					       in 		number default null
  );

end PER_DRT_API;

/
