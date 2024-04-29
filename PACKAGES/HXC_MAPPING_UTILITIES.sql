--------------------------------------------------------
--  DDL for Package HXC_MAPPING_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_MAPPING_UTILITIES" AUTHID CURRENT_USER as
/* $Header: hxcmputl.pkh 120.0 2005/05/29 04:59:25 appldev noship $ */

g_package  varchar2(33)	:= '  hxc_mapping_utilities';  -- Global package name

TYPE r_bld_blk_info IS RECORD ( bld_blk_info_type_id hxc_time_attributes.bld_blk_info_type_id%TYPE );

TYPE t_bld_blk_info IS TABLE OF r_bld_blk_info INDEX BY BINARY_INTEGER;

TYPE Consolidated_info IS RECORD ( bld_blk_info_type_id hxc_time_attributes.bld_blk_info_type_id%TYPE
				  ,field_name hxc_mapping_components.field_name%TYPE
				  ,field_value varchar2(1000)
				  ,segment hxc_mapping_components.segment%TYPE);


TYPE t_consolidated_info_1 IS TABLE OF Consolidated_info INDEX BY BINARY_INTEGER;


FUNCTION get_day_date ( p_type VARCHAR2, p_bb_id NUMBER, p_bb_ovn NUMBER ) RETURN DATE;

-- public function
--   chk_mapping_changed
-- description
--   Returns true if any attributes identified by the specified mapping
--   have changed between the timecard specified by the TIMECARD scope
--   time building block and the earliest previous version of the timecard
--   time building block of the specified status
--
--   Algorithm
--   First of all if the object version number of any of the time building
--   blocks is 1 then the function returns TRUE - since the time building
--   block did not previously exist.
--   If this is not the case then for each building block the current attributes
--   are read into a table. Then the attributes for a prior version of the
--   building block with the specified status are found. If none exist then again
--   the function returns TRUE.
--   At this point before comparing the individual attributes in the table an
--   analysis is made of the number of bld blk info types and their value between
--   the old and the new. If the number of records in the new table is different
--   to the number in the old then the function returns TRUE. (NOTE: we have to
--   make sure that these are records where the bld_blk_info_type_id is not null
--   since there is an outer join to detect when a bld blk info type is added or
--   deleted). If the number of old and new bld blk info types is the same then

--   a comparison is made to see if they are the same values before attempting
--   to compare each attribute. Finally, if the old and the new bld blk info types
--   are the same each old and new attribute value is compared.
--   NOTE: all these comparisons above are made within the scope of the attributes
--         and bld blk info types specified by the mapping

FUNCTION chk_mapping_changed ( 	p_mapping_id	NUMBER
			,	p_timecard_bb_id NUMBER
			,	p_timecard_ovn	NUMBER
			,	p_start_date	DATE
			,	p_end_date	DATE
			,	p_last_status   VARCHAR2
			,	p_time_building_blocks	hxc_self_service_time_deposit.timecard_info
			,	p_time_attributes	hxc_self_service_time_deposit.building_block_attribute_info
                        ,       p_called_from   VARCHAR2 default 'APPROVALS' )
RETURN BOOLEAN;

-- public function
--   chk_bld_blk_changed
-- description
--   checks to see if the start time, stop time or measure have
--   changed between the current timecard and that of the prior
--   approval status specified.
--
--   Returns true if any of the bld blk attribution has changed
--
--   The bld blk attributes are
--     measure    (at the DETAIL scope only)
--     start time (at the DAY scope only)
--     stop time  (at the DAY scope only)
--
--   Algorithm
--    populates table of current timecard bld blks whose ovn is not 1
--    If the current bld bld is deleted store in separate table
--
--    For deleted bld blks get the prior status bld blks
--     check to see what the prior status bld blk looks like
--      if deleted then do nothing
--      if not deleted then RETURN TRUE
--      if not found at the prior status then do nothing
--
--    For non deleted bld blks get the prior status bld blks
--     if exists then retrieve to prior status table
--     if not then DO NOTHING
--
--    Finally, have table of prior bld blks
--    Compare the start and stop times at the DAY level
--    and measure at the DETAIL level - if any differ then RETURN TRUE
--    else return FALSE

FUNCTION chk_bld_blk_changed (  p_timecard_bb_id NUMBER
			,	p_timecard_ovn	NUMBER
			,	p_start_date	DATE
			,	p_end_date	DATE
			,	p_last_status   VARCHAR2
			,	p_time_bld_blks hxc_self_service_time_deposit.timecard_info ) RETURN BOOLEAN;

-- function
--   attribute_column
--
-- description
--   returns the name of the attribute column in HXC_TIME_ATTRIBUTES which
--   maps to the parameter p_field_name, based on the building block
--   category and information type
--
-- parameters
--   p_field_name                 - the name of the field to be mapped
--   p_bld_blk_info_type          - the information type of the attribute
--   p_descriptive_flexfield_name - the name of the flexfield

function attribute_column
  (p_field_name                 in varchar2
  ,p_bld_blk_info_type          in varchar2
  ,p_descriptive_flexfield_name in varchar2
  ) return varchar2;


-- function
--   attribute_column
--
-- description
--   overload of attribute_column function.  returns the name of the
--   attribute column in HXC_TIME_ATTRIBUTES which maps to the parameter
--   p_field_name, based on the deposit or retrieval process identifier.
--   since there is no guarantee that mappings have been explicitly defined
--   for the given process, the column name is returned in an out parameter,
--   and the function returns true or false depending on whether or not a
--   mapping was found.
--
-- parameters
--   p_field_name              - the name of the field to be mapped
--   p_process_type            - (D)eposit or (R)etrieval
--   p_process_id              - deposit or retrieval process id
--   p_column_name (out)       - the column name where the specified field is
--                               stored
--   p_bld_blk_info_type (out) - the information type of the mapped field

function attribute_column
  (p_field_name        in     varchar2
  ,p_process_type      in     varchar2
  ,p_process_id        in     number
  ,p_column_name       in out nocopy varchar2
  ,p_bld_blk_info_type in out nocopy varchar2
  ) return boolean;

-- function
--   chk_mapping_exists
--
-- description
--   Returns TRUE if the mapping field name and value specified exists
--   anywhere in the time store. Returns FALSE if not.
--
--   If the retrieval process name is specified then
--
--   Returns TRUE only if the mapping exists but has NOT been
--   successfully retrieved, else RETURNS FALSE which means
--   that at least one has been transferred or it did not exist
--
--
--
-- parameters
--   p_bld_blk_info_type       - bld blk info type of the mapping
--   p_field_name              - field name of the mapping component
--   p_field_value             - value to search for
--   p_scope                   - the scope at which the value is associated
--   p_retrieval_process       - Retrieval Process Name

FUNCTION chk_mapping_exists ( p_bld_blk_info_type   VARCHAR2
		,	      p_field_name  	    VARCHAR2
		,             p_field_value 	    VARCHAR2
		,	      p_bld_blk_info_type2  VARCHAR2 default null
		,	      p_field_name2  	    VARCHAR2 default null
		,             p_field_value2 	    VARCHAR2 default null
		,	      p_bld_blk_info_type3  VARCHAR2 default null
		, 	      p_field_name3  	    VARCHAR2 default null
		,             p_field_value3  	    VARCHAR2 default null
		,	      p_bld_blk_info_type4  VARCHAR2 default null
		,	      p_field_name4  	    VARCHAR2 default null
		,             p_field_value4 	    VARCHAR2 default null
		,	      p_bld_blk_info_type5  VARCHAR2 default null
		,	      p_field_name5  	    VARCHAR2 default null
		,             p_field_value5 	    VARCHAR2 default null
		,             p_scope        	    VARCHAR2
                ,             p_retrieval_process_name VARCHAR2 DEFAULT 'None'
                ,             p_status VARCHAR2 DEFAULT 'None'
                ,             p_end_date DATE DEFAULT null) RETURN BOOLEAN ;

FUNCTION get_mappingvalue_sum ( p_bld_blk_info_type  VARCHAR2
		,	        p_field_name1        VARCHAR2
		,               p_bld_blk_info_type2 VARCHAR2 default null
		,	        p_field_name2        VARCHAR2
		,               p_field_value2       VARCHAR2
		,               p_bld_blk_info_type3 VARCHAR2 default null
		,	        p_field_name3        VARCHAR2 default null
		,               p_field_value3       VARCHAR2 default null
		,               p_bld_blk_info_type4 VARCHAR2 default null
		,	        p_field_name4        VARCHAR2 default null
		,               p_field_value4       VARCHAR2 default null
		,               p_bld_blk_info_type5 VARCHAR2 default null
		,	        p_field_name5        VARCHAR2 default null
		,               p_field_value5       VARCHAR2 default null
		,               p_status             VARCHAR2
                ,               p_resource_id        VARCHAR2
		) RETURN NUMBER;

Procedure get_mapping_value(p_bld_blk_info_type in varchar2,
			    p_field_name  in varchar2,
			    p_segment out nocopy hxc_mapping_components.segment%TYPE,
			    p_bld_blk_info_type_id out nocopy hxc_mapping_components.bld_blk_info_type_id%TYPE ) ;




end hxc_mapping_utilities;

 

/
