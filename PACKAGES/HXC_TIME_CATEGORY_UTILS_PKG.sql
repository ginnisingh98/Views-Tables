--------------------------------------------------------
--  DDL for Package HXC_TIME_CATEGORY_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIME_CATEGORY_UTILS_PKG" AUTHID CURRENT_USER as
/* $Header: hxchtcutl.pkh 120.2 2006/08/29 20:58:24 arundell noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= ' hxc_time_category_utils_pkg.';  -- Global package name

g_tc_bb_not_ok_string VARCHAR2(32000);

CURSOR  csr_get_time_sql ( p_time_category_id NUMBER ) IS
SELECT	htc.time_sql
FROM	hxc_time_categories htc
WHERE	htc.time_category_id = p_time_category_id;

-- *******************************************
-- structures for backward compatibilty start

TYPE r_time_category IS RECORD (
	bld_blk_info_type	hxc_time_attributes.attribute_category%TYPE
,	segment			fnd_descr_flex_column_usages.end_user_column_name%TYPE
,	value_id		hxc_time_attributes.attribute1%TYPE );

TYPE t_time_category IS TABLE OF r_time_category INDEX BY BINARY_INTEGER;

g_time_category_tab t_time_category;

TYPE r_seg_info IS RECORD (
     application_column_name VARCHAR2(2000)
,    segment_name            VARCHAR2(2000)
,    column_prompt           VARCHAR2(2000)
,    value_set               NUMBER
,    validation_type         VARCHAR2(2000)
,    sql_text                LONG
,    sql_ok                  BOOLEAN
,    no_sql                  BOOLEAN );

TYPE t_seg_info IS TABLE OF r_seg_info INDEX BY BINARY_INTEGER;

TYPE r_context IS RECORD ( context_code fnd_descr_flex_column_usages.descriptive_flex_context_code%TYPE );
TYPE t_context IS TABLE OF r_context INDEX BY BINARY_INTEGER;

-- structures for backward compatibilty end
-- *******************************************

TYPE r_vs_comp IS RECORD (
                           time_category_id      number(15)
                         , time_category_comp_id number(15)
                         , component_type_id     number(15)
                         , is_null               varchar2(1)
                         , equal_to              varchar2(1)
                         , flex_value_set_id     hxc_time_category_comps.flex_value_set_id%TYPE
                         , sql_string            hxc_time_category_comp_sql.sql_string%TYPE
                         , last_update_date      DATE );

TYPE t_vs_comp IS TABLE OF r_vs_comp INDEX BY BINARY_INTEGER;

TYPE r_an_comp IS RECORD ( sql_string hxc_time_category_comp_sql.sql_string%TYPE );
TYPE t_an_comp IS TABLE OF r_an_comp INDEX BY BINARY_INTEGER;

TYPE r_tc_comp IS RECORD ( ref_tc_id hxc_time_category_comps.time_category_id%TYPE );
TYPE t_tc_comp IS TABLE OF r_tc_comp INDEX BY BINARY_INTEGER;

TYPE r_master_tc_info IS RECORD (
                                  time_category_id  hxc_time_categories.time_category_id%TYPE
                                , time_card_id      hxc_time_building_blocks.time_building_Block_id%TYPE
                                , operator          hxc_time_categories.operator%TYPE
                                , attribute_count   number );

TYPE r_tc_bb_ok IS RECORD ( bb_id_ok varchar2(1) );

TYPE t_tc_bb_ok IS TABLE OF r_tc_bb_ok INDEX BY BINARY_INTEGER;

g_tc_bb_ok_tab t_tc_bb_ok;

g_tc_in_bb_ok  hxc_time_categories.time_category_id%TYPE;

g_time_category_id hxc_time_categories.time_category_id%TYPE;

g_tc_bb_ok_string VARCHAR2(32000);

g_master_tc_info_rec r_master_tc_info;



PROCEDURE mapping_component_string ( p_time_category_id NUMBER
			,	     p_time_sql	    IN OUT NOCOPY LONG );

PROCEDURE alternate_name_string ( p_alias_value_id NUMBER
                        ,         p_operator       VARCHAR2
			,         p_is_null        VARCHAR2
                        ,         p_equal_to       VARCHAR2
			,	  p_time_sql	    IN OUT NOCOPY LONG );

-- public procedure
--   push_timecard
--
-- description
--
-- Takes the timecard stored in the block and attributes tables structures and
-- inserts it into the corresponding temporary tables

-- parameters
--   p_blocks       - the timecard block table
--   p_attributes   - the timecard attribute table
--   p_detail_blocks_only -
--                    passes detail block only
--                    this is used for approvals which creates these structures
--                    from the database. NOTE: must denormalise the DAY start
--                    and STOP times when passing only DETAILS

PROCEDURE push_timecard ( p_blocks hxc_block_table_type,
                          p_attributes hxc_attribute_table_type,
                          p_detail_blocks_only BOOLEAN DEFAULT FALSE );


PROCEDURE push_attributes ( p_attributes hxc_self_service_time_deposit.building_block_attribute_info );


-- public procedure
--   evaluate_time_category
--
-- description
--
-- Evaluates the given time category against the timecard
-- stored in the temporary table

-- Returns a table of DETAIL time building blocks and string
-- which satisfied the given time category

-- parameters
--   p_time_category_id     - Time Category ID
--   p_tc_bb_ok_tab         - Table of Valid bb ids
--   p_tc_bb_ok_string      - string of the valid building blocks
--   p_tc_bb_not_ok_string  - string of the invalid building blocks
--   p_use_tc_cache         - uses the Time Category cache
--                          -  default to TRUE.
--   p_use_tc_bb_cache      - uses the Time Category building block cache
--                          -  Used in ELP where we want to evaluate the
--                          -  timecard for the old structure too. We do
--                          -  not want this evaluation to use the cache
--                          -  or maintain it.
--   p_use_temp_table       - Whether the time categry is evaluated against
--                            the temp table (called from Self Service)
--                            or the live table
--   p_scope                - scope of the time building block and ovn supplied
--   p_tbb_id               - buildibg block to be evaluated (non Self Service call)
--   p_tbb_ovn              - building block ovn to be evaluated (non Self Service call)

PROCEDURE evaluate_time_category ( p_time_category_id     IN NUMBER
                               ,   p_tc_bb_ok_tab         IN OUT NOCOPY t_tc_bb_ok
                               ,   p_tc_bb_ok_string      IN OUT NOCOPY VARCHAR2
                               ,   p_tc_bb_not_ok_string  IN OUT NOCOPY VARCHAR2
                               ,   p_use_tc_cache         IN BOOLEAN  DEFAULT TRUE
                               ,   p_use_tc_bb_cache      IN BOOLEAN  DEFAULT TRUE
                               ,   p_use_temp_table       IN BOOLEAN  DEFAULT TRUE
                               ,   p_scope                IN VARCHAR2 DEFAULT 'TIME'
                               ,   p_tbb_id               IN NUMBER   DEFAULT NULL
                               ,   p_tbb_ovn              IN NUMBER   DEFAULT NULL );

-- public procedure
--   sum_tc_bb_ok_hrs
--
-- description
--
-- Sums the hours on the timecard which satisfy the time category

-- parameters
--   p_tc_bb_ok_string - string of the valid building blocks
--   p_hrs             - sum of hours on the timecard
--   p_period_start    - time entry rule period start
--   p_period_end      - time entry rule period end

PROCEDURE sum_tc_bb_ok_hrs ( p_tc_bb_ok_string   VARCHAR2
                           , p_hrs IN OUT NOCOPY NUMBER
                           , p_period_start      DATE
                           , p_period_end        DATE  );


-- public function
--   chk_tc_bb_ok

-- description

-- Does a simple EXISTS on the global table g_tc_bb_ok_tab. If the bb id exists
-- in the table then return TRUE otherwise return FALSE.

FUNCTION chk_tc_bb_ok (
   p_tbb_id   NUMBER ) RETURN BOOLEAN;



PROCEDURE insert_time_category_comp_sql ( p_rec  hxc_tcc_shd.g_rec_type );
PROCEDURE update_time_category_comp_sql ( p_rec  hxc_tcc_shd.g_rec_type );
PROCEDURE delete_time_category_comp_sql ( p_rec  hxc_tcc_shd.g_rec_type );



-- ----------------------------------------------------------------------------
-- |----------------------------< get_value_set_sql >-------------------------|
-- ----------------------------------------------------------------------------
--
-- public function
--   get_value_set_sql
--
-- description
--   get the SQL associated with a particular value set


FUNCTION get_value_set_sql
              (p_flex_value_set_id IN NUMBER,
               p_session_date   IN     DATE ) RETURN LONG;



-- public procedure
--   get_flex_info
--
-- description
--   get flex field context segment info. In particular information
--   on the validation and value set associated with each segment
--   within the context
--   Used in the Time Categories form to dynamically set the LOV associated
--   with each mapping component chosen.

PROCEDURE get_flex_info (
		p_context_code    IN  VARCHAR2
        ,       p_seg_info        OUT NOCOPY t_seg_info
        ,       p_session_date    IN  DATE );



-- public function
--   get_flex_value
--
-- description
--   retrieves the value based on the id and flex value set id
--   used in the hxc_time_category_comps_v view.

FUNCTION get_flex_value (  p_flex_value_set_id NUMBER
	,		p_id  VARCHAR2 ) RETURN VARCHAR2;



-- prublic function
--   get_time_category_id
--
-- description
--   get time category id based on time category name

FUNCTION get_time_category_id ( p_time_category_name VARCHAR2 ) RETURN NUMBER;



-- PUBLIC function for backward compatibility with Phase I Time Categories

PROCEDURE initialise_time_category (
                        p_time_category_id NUMBER
               ,        p_tco_att   hxc_self_service_time_deposit.building_block_attribute_info );



-- PUBLIC function for backward compatibility with Phase I Time Categories

PROCEDURE initialise_time_category (
                        p_time_category_id NUMBER
               ,        p_tco_att   hxc_attribute_table_type );



-- public function
--   category_timecard_hrs
--
-- description
--   Returns the number of hours for timecard
--   for a specified time category name

FUNCTION category_timecard_hrs (
		p_tbb_id	NUMBER
	,	p_tbb_ovn	NUMBER
	,       p_time_category_name VARCHAR2 ) RETURN NUMBER;

-- public function
--   category_timecard_hrs_ind
--
-- description
--   Returns the number of hours for timecard
--   for a specified time category name
--  Similar to category_timecard_hrs but
-- it also processes the hour value according
-- to decimal precision and rounding rule
-- as set in preference

FUNCTION category_timecard_hrs_ind (
		p_tbb_id	NUMBER
	,	p_tbb_ovn	NUMBER
	,       p_time_category_name VARCHAR2 ) RETURN NUMBER;

-- public function
--   category_detail_hrs (Overloaded)
--
-- description
--   Returns the number of hours for 1 DETAIL time building block
--   for a specified time category name

FUNCTION category_detail_hrs (
		p_tbb_id	NUMBER
	,	p_tbb_ovn	NUMBER
	,       p_time_category_name VARCHAR2 ) RETURN NUMBER;

-- public function
--   category_detail_hrs (Overloaded)
--
-- description
--   Returns the number of hours for 1 DETAIL time building block
--   (the global variable g time category id is presumed to be set)

FUNCTION category_detail_hrs (
		p_tbb_id	NUMBER
	,	p_tbb_ovn	NUMBER ) RETURN NUMBER;


-- public function
--   category_detail_hrs
--
-- description
--   Returns the number of hours for 1 DETAIL time building block
--   for a specified time category id

FUNCTION category_detail_hrs (
		p_tbb_id	NUMBER
	,	p_tbb_ovn	NUMBER
	,       p_time_category_id NUMBER ) RETURN NUMBER;



-- public function
--   category_app_period_tc_hrs
--
-- description
--   Returns the number of hours for person within a date range
--   and specified time category and application_period_id

FUNCTION category_app_period_tc_hrs (
		p_period_start_time     IN DATE
	,	p_period_stop_time      IN DATE
	,	p_resource_id           IN NUMBER
	,       p_time_category_name    IN VARCHAR2
        ,       p_application_period_id IN NUMBER ) RETURN NUMBER;



-- public procedure
--   process_tc_timecard
--
-- description
--
--   This procedure is obsolete. Users should use evaluate_time_category
--

PROCEDURE process_tc_timecard (
   p_tco_att   hxc_self_service_time_deposit.building_block_attribute_info
,  p_time_cat  t_time_category
,  p_bb_ok_tab IN OUT NOCOPY t_tc_bb_ok
,  p_operator  VARCHAR2 default 'OR' );


-- public procedure
--   time_category_String
--
-- description
--
--   This procedure is obsolete. Users should use evaluate_time_category
--

PROCEDURE time_category_string ( p_time_category_id NUMBER
			,	 p_dyn_or_tab	    IN VARCHAR2
			,	 p_dyn_sql	    IN OUT NOCOPY LONG
			,        p_category_tab     IN OUT NOCOPY t_time_category
                        ,        p_operator         IN OUT NOCOPY VARCHAR2 );


PROCEDURE alias_value_ref_int_chk ( p_alias_value_id NUMBER
                                  , p_action         VARCHAR2 );

PROCEDURE alias_definition_ref_int_chk ( p_alias_definition_id NUMBER );

PROCEDURE alias_type_comp_ref_int_chk ( p_alias_type_id NUMBER );
--
-- ---------------------------------------------------------------------------
-- |------------------------< reset_cache >----------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure resets the internal time category cache, and corresponding
-- categorized time cache.  This ensures that if any changes have been made
-- to the time category definition at runtime, the new version of the time
-- category is used and not the existing categorization.  This function is
-- currently called from the Project Manager approval package when time
-- categories are created and modified dynamically.  Added for bug 5469357
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Success:
--   Internal caches are cleared.
--
-- Post Failure:
--   Failure should not occur, but if so, function returns false indicating
-- a failure to clear the internal time category caches.
--
-- Access Status:
--   Public - HRMS Development Only.
--
-- {End Of Comments}
--
  Function reset_cache Return Boolean;

end hxc_time_category_utils_pkg;

 

/
