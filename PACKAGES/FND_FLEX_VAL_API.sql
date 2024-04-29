--------------------------------------------------------
--  DDL for Package FND_FLEX_VAL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_VAL_API" AUTHID CURRENT_USER AS
/* $Header: AFFFVAIS.pls 120.7.12010000.1 2008/07/25 14:14:43 appldev ship $ */


--
-- Following are the return codes for get_*_vset_select functions.
--

g_ret_no_error            NUMBER := 0;
g_ret_invalid_parameter   NUMBER := 1;
g_ret_others              NUMBER := 9;
g_ret_no_value_set        NUMBER := 11;
g_ret_vtype_mismatch      NUMBER := 12;
g_ret_vtype_not_supported NUMBER := 13;
g_ret_not_indep_validated NUMBER := 21;
g_ret_not_dep_validated   NUMBER := 31;
g_ret_no_parent_value     NUMBER := 32;
g_ret_not_table_validated NUMBER := 51;
g_ret_no_table_info       NUMBER := 52;

--
-- Rename FND_API constants.
--
-- In Update APIs
--    NULL means "ignore this field, do not update it", and
--    Following constants mean "set the field to NULL."
--
g_null_number             NUMBER       := fnd_api.g_miss_num;
g_null_varchar2           VARCHAR2(10) := fnd_api.g_miss_char;
g_null_date               DATE         := fnd_api.g_miss_date;


PROCEDURE debug_on ;


PROCEDURE debug_off ;


PROCEDURE set_session_mode(session_mode IN VARCHAR2);


FUNCTION version RETURN VARCHAR2 ;

FUNCTION message RETURN VARCHAR2 ;



PROCEDURE create_valueset_none(
	/* basic parameters */
	value_set_name		        IN VARCHAR2,
	description			IN VARCHAR2,
	security_available		IN VARCHAR2,
	enable_longlist			IN VARCHAR2,
	format_type			IN VARCHAR2,
	maximum_size   			IN NUMBER,
	precision 		        IN NUMBER    DEFAULT NULL,
	numbers_only 			IN VARCHAR2,
	uppercase_only     		IN VARCHAR2,
	right_justify_zero_fill		IN VARCHAR2,
	min_value			IN VARCHAR2,
        max_value 			IN VARCHAR2);




PROCEDURE create_valueset_independent(
        /* basic parameters */
	value_set_name		        IN VARCHAR2,
	description			IN VARCHAR2,
	security_available		IN VARCHAR2,
	enable_longlist			IN VARCHAR2,
	format_type			IN VARCHAR2,
	maximum_size   			IN NUMBER,
	precision 			IN NUMBER   DEFAULT NULL,
	numbers_only 			IN VARCHAR2,
	uppercase_only     		IN VARCHAR2,
	right_justify_zero_fill		IN VARCHAR2,
	min_value			IN VARCHAR2,
	max_value 			IN VARCHAR2);




PROCEDURE create_valueset_dependent(
        /* basic parameters */
	value_set_name		        IN VARCHAR2,
	description			IN VARCHAR2,
	security_available		IN VARCHAR2,
	enable_longlist			IN VARCHAR2,
	format_type			IN VARCHAR2,
	maximum_size   			IN NUMBER,
	precision 			IN NUMBER   DEFAULT NULL,
	numbers_only 			IN VARCHAR2,
	uppercase_only     		IN VARCHAR2,
	right_justify_zero_fill		IN VARCHAR2,
	min_value			IN VARCHAR2,
	max_value 			IN VARCHAR2,

	parent_flex_value_set		IN VARCHAR2,
	dependent_default_value		IN VARCHAR2,
	dependent_default_meaning	IN VARCHAR2);





PROCEDURE create_valueset_table(
        /* basic parameters */
	value_set_name		        IN VARCHAR2,
	description			IN VARCHAR2,
	security_available		IN VARCHAR2,
	enable_longlist			IN VARCHAR2,
	format_type			IN VARCHAR2,
	maximum_size   			IN NUMBER,
	precision 			IN NUMBER   DEFAULT NULL,
	numbers_only 			IN VARCHAR2,
	uppercase_only     		IN VARCHAR2,
	right_justify_zero_fill		IN VARCHAR2,
	min_value			IN VARCHAR2,
	max_value 			IN VARCHAR2,

	table_application		IN VARCHAR2 DEFAULT NULL,
	table_appl_short_name           IN VARCHAR2 DEFAULT NULL,
	table_name			IN VARCHAR2,
	allow_parent_values		IN VARCHAR2,
	value_column_name		IN VARCHAR2,
	value_column_type		IN VARCHAR2,
	value_column_size		IN NUMBER,
	meaning_column_name		IN VARCHAR2 DEFAULT NULL,
	meaning_column_type		IN VARCHAR2 DEFAULT NULL,
	meaning_column_size		IN NUMBER   DEFAULT NULL,
	id_column_name			IN VARCHAR2 DEFAULT NULL,
	id_column_type			IN VARCHAR2 DEFAULT NULL,
	id_column_size			IN NUMBER   DEFAULT NULL,
	where_order_by  		IN VARCHAR2 DEFAULT NULL,
	additional_columns	        IN VARCHAR2 DEFAULT NULL);






PROCEDURE create_valueset_special(
        /* basic parameters */
	value_set_name		        IN VARCHAR2,
	description			IN VARCHAR2,
	security_available		IN VARCHAR2,
	enable_longlist			IN VARCHAR2,
	format_type			IN VARCHAR2,
	maximum_size   			IN NUMBER,
	precision 			IN NUMBER   DEFAULT NULL,
	numbers_only 			IN VARCHAR2,
	uppercase_only     		IN VARCHAR2,
	right_justify_zero_fill	IN VARCHAR2,
	min_value			IN VARCHAR2,
	max_value 			IN VARCHAR2);



PROCEDURE create_valueset_pair(
        /* basic parameters */
	value_set_name		        IN VARCHAR2,
	description			IN VARCHAR2,
	security_available		IN VARCHAR2,
	enable_longlist			IN VARCHAR2,
	format_type			IN VARCHAR2,
	maximum_size   			IN NUMBER,
	precision 		        IN NUMBER   DEFAULT NULL,
	numbers_only 	                IN VARCHAR2,
	uppercase_only     		IN VARCHAR2,
	right_justify_zero_fill	        IN VARCHAR2,
	min_value			IN VARCHAR2,
	max_value 			IN VARCHAR2);


PROCEDURE add_event(value_set_name              IN VARCHAR2,
                    event                       IN VARCHAR2,
                    function_text               IN long);


PROCEDURE delete_valueset(value_set IN VARCHAR2);



PROCEDURE destructive_rename(old_value_set IN VARCHAR2,
			     new_value_set IN VARCHAR2);



FUNCTION valueset_exists(value_set IN VARCHAR2) RETURN BOOLEAN;



PROCEDURE update_table_sizes(
      value_set_name   IN VARCHAR2,
      id_size          IN fnd_flex_validation_tables.id_column_size%TYPE
			     DEFAULT NULL,
      value_size       IN fnd_flex_validation_tables.value_column_size%TYPE
			     DEFAULT NULL,
      meaning_size     IN fnd_flex_validation_tables.meaning_column_size%TYPE
			     DEFAULT NULL);


PROCEDURE update_maxsize(
      value_set_name IN VARCHAR2,
      maxsize        IN fnd_flex_value_sets.maximum_size%TYPE);

--------------------------------------------------------------
-- Get Select Statements.
--------------------------------------------------------------
-- Usage :
--   - Pass Only Flex Value Set Id or Flex Value Set Name, not both.
--   - You can control what to include in SELECT clause. (i.e. column names)
--   - VALUE column is always included.
--   - WHERE clause always has (1 = 1) condition which is always true and
--     does not effect the SELECT statement.
--   - ID and MEANING columns are included by default, can be excluded.
--   - p_inc_* parameters controls what to include in SELECT or WHERE parts.
--   - Passing a p_inc_* parameter as 'Y' doesn't guarantee this column will
--     be included in either SELECT column list or in WHERE clause.
--   - In the select list each column name is seperated by a newline char.
--   - Value column name is just after the SELECT clause.
--   - You can check what was included by parsing x_mapping_code.
--      Mapping Codes :
--      ---------------
--      Select part starts with S: and Where part starts with W:
--      Each column name or where clause has two char code. This code is
--      followed by a number. 0 means not included, 1 means included.
--      These are for SELECT column name list:
--      --------------------------------------
--        VA : VALUE column, (you will always see VA1).
--        ID : ID columns,
--        ME : MEANING column,
--        EN : ENABLED column,
--        SD : START_DATE column,
--        ED : END_DATE column,
--        SM : SUMMARY column,
--        CA : COMPILED_ATTRIBUTE column,
--        HL : HIERARCHY_LEVEL column,
--        AU : Additional User Columns,
--        AQ : Additional Quickpick Columns.
--      You can add additional user columns in Select list, if you know
--      these column names. Ex. : 'COL1, COL2'
--      Note: Seperate col names with comma, but do not add comma
--            after the last column name.
--            Make sure these columns exist in the table.
--            Do not include newline char in your column list.
--   - AQ is last in the select statement if it is included.
--
--      These are for WHERE conditions:
--      --------------------------------------
--        WW : (1 = 1) part. (you will always see WW1)
--        EF : Enabled Flag check,
--        VD : Validation Date check: This code may have 4 different values.
--             0 : not checked.
--             1 : only start date is checked.
--             2 : only end date is checked.
--             3 : both start date and end date are checked.
--             In general it is either 0 or 3.
--             Each date check is in seperate line.
--             By default these dates are checked against SYSDATE.
--             You can pass fixed dates in p_validation_date_char.
--             Do not forget to pass single quotes if you are passing
--             dates in char format.
--             Ex. : 'to_date(''01-01-1998'',''DD-MM-YYYY'')'
--        UW : User Where Clause, You can pass additional where clause.
--             It will be ANDed to the rest of where clause.
--        AW : Additional Where clause, This is the where clause defined in
--             Table validated value set.
--    - Pass independent_value (or parent value) for dependent value sets.
--      You don't need to use extra single quotes. Value will be single quoted.
--      NULL is not a valid parent value.
--    - Check x_success first. For return codes see g_ret_* codes above.
--
--------------------------------------------------------------
PROCEDURE get_independent_vset_select
  (p_value_set_name IN fnd_flex_value_sets.flex_value_set_name%TYPE
                       DEFAULT fnd_api.g_miss_char,
   p_value_set_id   IN fnd_flex_value_sets.flex_value_set_id%TYPE
                       DEFAULT fnd_api.g_miss_num,
   --
   -- Do you want to include these columns in SELECT statement?
   -- VALUE column is always included.
   -- ID and MEANING columns are included by default.
   --
   p_inc_id_col                 IN VARCHAR2 DEFAULT 'Y',
   p_inc_meaning_col            IN VARCHAR2 DEFAULT 'Y',
   p_inc_enabled_col            IN VARCHAR2 DEFAULT 'N',
   p_inc_start_date_col         IN VARCHAR2 DEFAULT 'N',
   p_inc_end_date_col           IN VARCHAR2 DEFAULT 'N',
   p_inc_summary_col            IN VARCHAR2 DEFAULT 'N',
   p_inc_compiled_attribute_col IN VARCHAR2 DEFAULT 'N',
   p_inc_hierarchy_level_col    IN VARCHAR2 DEFAULT 'N',
   --
   -- Do you want to add extra checks in SELECT?
   --
   p_check_enabled_flag     IN VARCHAR2 DEFAULT 'Y',
   p_check_validation_date  IN VARCHAR2 DEFAULT 'Y',
   p_validation_date_char   IN VARCHAR2 DEFAULT 'SYSDATE',
   p_inc_user_where_clause  IN VARCHAR2 DEFAULT 'N',
   p_user_where_clause      IN VARCHAR2 DEFAULT NULL,

   x_select OUT NOCOPY VARCHAR2,
   x_mapping_code OUT NOCOPY VARCHAR2,
   x_success OUT NOCOPY NUMBER);


PROCEDURE get_dependent_vset_select
  (p_value_set_name IN fnd_flex_value_sets.flex_value_set_name%TYPE
                       DEFAULT fnd_api.g_miss_char,
   p_value_set_id   IN fnd_flex_value_sets.flex_value_set_id%TYPE
                       DEFAULT fnd_api.g_miss_num,
   p_independent_value IN VARCHAR2 DEFAULT NULL,
   --
   -- Do you want to include these columns in SELECT statement?
   -- VALUE column is always included.
   -- ID and MEANING columns are included by default.
   --
   p_inc_id_col                 IN VARCHAR2 DEFAULT 'Y',
   p_inc_meaning_col            IN VARCHAR2 DEFAULT 'Y',
   p_inc_enabled_col            IN VARCHAR2 DEFAULT 'N',
   p_inc_start_date_col         IN VARCHAR2 DEFAULT 'N',
   p_inc_end_date_col           IN VARCHAR2 DEFAULT 'N',
   p_inc_summary_col            IN VARCHAR2 DEFAULT 'N',
   p_inc_compiled_attribute_col IN VARCHAR2 DEFAULT 'N',
   p_inc_hierarchy_level_col    IN VARCHAR2 DEFAULT 'N',
   --
   -- Do you want to add extra checks in SELECT?
   --
   p_check_enabled_flag     IN VARCHAR2 DEFAULT 'Y',
   p_check_validation_date  IN VARCHAR2 DEFAULT 'Y',
   p_validation_date_char   IN VARCHAR2 DEFAULT 'SYSDATE',
   p_inc_user_where_clause  IN VARCHAR2 DEFAULT 'N',
   p_user_where_clause      IN VARCHAR2 DEFAULT NULL,

   x_select OUT NOCOPY VARCHAR2,
   x_mapping_code OUT NOCOPY VARCHAR2,
   x_success OUT NOCOPY NUMBER);


PROCEDURE get_table_vset_select
  (p_value_set_name IN fnd_flex_value_sets.flex_value_set_name%TYPE
                       DEFAULT fnd_api.g_miss_char,
   p_value_set_id   IN fnd_flex_value_sets.flex_value_set_id%TYPE
                       DEFAULT fnd_api.g_miss_num,
   --
   -- Do you want to include these columns in SELECT statement?
   -- VALUE column is always included.
   -- ID and MEANING columns are included by default.
   --
   p_inc_id_col                 IN VARCHAR2 DEFAULT 'Y',
   p_inc_meaning_col            IN VARCHAR2 DEFAULT 'Y',
   p_inc_enabled_col            IN VARCHAR2 DEFAULT 'N',
   p_inc_start_date_col         IN VARCHAR2 DEFAULT 'N',
   p_inc_end_date_col           IN VARCHAR2 DEFAULT 'N',
   p_inc_summary_col            IN VARCHAR2 DEFAULT 'N',
   p_inc_compiled_attribute_col IN VARCHAR2 DEFAULT 'N',
   p_inc_hierarchy_level_col    IN VARCHAR2 DEFAULT 'N',
   p_inc_addtl_user_columns     IN VARCHAR2 DEFAULT 'N',
   p_additional_user_columns    IN VARCHAR2 DEFAULT NULL,
   p_inc_addtl_quickpick_cols   IN VARCHAR2 DEFAULT 'N',
   --
   -- Do you want to add extra checks in SELECT?
   --
   p_check_enabled_flag     IN VARCHAR2 DEFAULT 'Y',
   p_check_validation_date  IN VARCHAR2 DEFAULT 'Y',
   p_validation_date_char   IN VARCHAR2 DEFAULT 'SYSDATE',
   p_inc_user_where_clause  IN VARCHAR2 DEFAULT 'N',
   p_user_where_clause      IN VARCHAR2 DEFAULT NULL,
   p_inc_addtl_where_clause IN VARCHAR2 DEFAULT 'Y',

   x_select OUT NOCOPY VARCHAR2,
   x_mapping_code OUT NOCOPY VARCHAR2,
   x_success OUT NOCOPY NUMBER);

--------------------------------------------------------------
-- These APIs are used mostly by AD to find out if a given TABLE, and/or
-- COLUMN is used by flexfield value sets.
--
-- If a table/column is in use these APIs return TRUE.
--
--------------------------------------------------------------
FUNCTION is_table_used(p_application_id IN fnd_tables.application_id%TYPE,
		       p_table_name     IN fnd_tables.table_name%TYPE,
		       x_message        OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

FUNCTION is_column_used(p_application_id IN fnd_tables.application_id%TYPE,
			p_table_name     IN fnd_tables.table_name%TYPE,
			p_column_name    IN fnd_columns.column_name%TYPE,
			x_message        OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


--------------------------------------------------------------
-- This API is used to get the hierarchy_id, when hierarchy_code
-- is given. These are known as Rollup Groups.
--
--------------------------------------------------------------
PROCEDURE get_hierarchy_id(p_flex_value_set_name IN VARCHAR2,
			   p_hierarchy_code      IN VARCHAR2,
			   x_hierarchy_id        OUT NOCOPY NUMBER);

--------------------------------------------------------------
-- These APIs are used to create/update independent/dependent value set
-- values.
--
-- p_flex_value_set_name - name of the value set
-- p_flex_value - display version of the value
-- p_description - description of the value
-- p_enabled_flag - enabled flag. 'Y' or 'N'
-- p_start_date_active - start date active
-- p_end_date_active - end date active
-- p_summary_flag - summary flag. 'Y' or 'N'
-- p_structured_hierarchy_id - rollup group id, see get_hierarchy_id
-- p_hierarchy_level - hierarhcy level
-- x_storage_value - storage version of the value.
--
-- p_parent_flex_value - parent value for a dependent vset value
--------------------------------------------------------------
PROCEDURE create_independent_vset_value
  (p_flex_value_set_name        IN VARCHAR2,
   p_flex_value                 IN VARCHAR2,
   p_description                IN VARCHAR2 DEFAULT NULL,
   p_enabled_flag               IN VARCHAR2 DEFAULT 'Y',
   p_start_date_active          IN DATE DEFAULT NULL,
   p_end_date_active            IN DATE DEFAULT NULL,
   p_summary_flag               IN VARCHAR2 DEFAULT 'N',
   p_structured_hierarchy_level IN NUMBER DEFAULT NULL,
   p_hierarchy_level            IN VARCHAR2 DEFAULT NULL,
   x_storage_value              OUT NOCOPY VARCHAR2);

PROCEDURE create_dependent_vset_value
  (p_flex_value_set_name        IN VARCHAR2,
   p_parent_flex_value          IN VARCHAR2,
   p_flex_value                 IN VARCHAR2,
   p_description                IN VARCHAR2 DEFAULT NULL,
   p_enabled_flag               IN VARCHAR2 DEFAULT 'Y',
   p_start_date_active          IN DATE DEFAULT NULL,
   p_end_date_active            IN DATE DEFAULT NULL,
   p_hierarchy_level            IN VARCHAR2 DEFAULT NULL,
   x_storage_value              OUT NOCOPY VARCHAR2);

PROCEDURE update_independent_vset_value
  (p_flex_value_set_name        IN VARCHAR2,
   p_flex_value                 IN VARCHAR2,
   p_description                IN VARCHAR2 DEFAULT NULL,
   p_enabled_flag               IN VARCHAR2 DEFAULT NULL,
   p_start_date_active          IN DATE DEFAULT NULL,
   p_end_date_active            IN DATE DEFAULT NULL,
   p_summary_flag               IN VARCHAR2 DEFAULT NULL,
   p_structured_hierarchy_level IN NUMBER DEFAULT NULL,
   p_hierarchy_level            IN VARCHAR2 DEFAULT NULL,
   x_storage_value              OUT NOCOPY VARCHAR2);

PROCEDURE update_dependent_vset_value
  (p_flex_value_set_name        IN VARCHAR2,
   p_parent_flex_value          IN VARCHAR2,
   p_flex_value                 IN VARCHAR2,
   p_description                IN VARCHAR2 DEFAULT NULL,
   p_enabled_flag               IN VARCHAR2 DEFAULT NULL,
   p_start_date_active          IN DATE DEFAULT NULL,
   p_end_date_active            IN DATE DEFAULT NULL,
   p_hierarchy_level            IN VARCHAR2 DEFAULT NULL,
   x_storage_value              OUT NOCOPY VARCHAR2);

--------------------------------------------------------------
-- This API is used to create a value hierarchy for independent value
-- set values
--
-- p_flex_value_set_name - name of the value set
-- p_parent_flex_value - the parent value (i.e. summary flag is 'Y')
-- p_range_attribute - 'C' for Child only, and 'P' for Parent only ranges
-- p_child_flex_value_low - Low value for the range
-- p_child_flex_value_high - High value for the range
--------------------------------------------------------------
PROCEDURE create_value_hierarchy
  (p_flex_value_set_name        IN VARCHAR2,
   p_parent_flex_value          IN VARCHAR2,
   p_range_attribute            IN VARCHAR2,
   p_child_flex_value_low       IN VARCHAR2,
   p_child_flex_value_high      IN VARCHAR2);

--------------------------------------------------------------
-- This API submits Value Set Hierarchy Compiler Concurrent Program.
--------------------------------------------------------------
PROCEDURE submit_vset_hierarchy_compiler
  (p_flex_value_set_name        IN VARCHAR2,
   x_request_id                 OUT NOCOPY NUMBER);



PROCEDURE is_valueset_allowed(p_flex_field in VARCHAR2,
                              p_value_set_id in NUMBER,
                              p_allow_id_valuesets in VARCHAR2,
                              p_segment_name in VARCHAR2,
                              p_id_flex_num in NUMBER,
                              p_segment_num in NUMBER,
                              p_desc_flex_context_code in VARCHAR2,
                              p_column_seq_num in NUMBER,
                              p_application_column_type in VARCHAR2,
                              p_application_column_size in NUMBER);

PROCEDURE validate_table_vset(
        p_flex_value_set_name           IN  fnd_flex_value_sets.flex_value_set_name%TYPE,
        p_id_column_name                IN  fnd_flex_validation_tables.id_column_name%TYPE,
        p_value_column_name             IN  fnd_flex_validation_tables.value_column_name%TYPE,
        p_meaning_column_name           IN  fnd_flex_validation_tables.meaning_column_name%TYPE,
        p_additional_quickpick_columns  IN  fnd_flex_validation_tables.additional_quickpick_columns%TYPE,
        p_application_table_name        IN  fnd_flex_validation_tables.application_table_name%TYPE,
        p_additional_where_clause       IN  fnd_flex_validation_tables.additional_where_clause%TYPE,
        x_result                        OUT NOCOPY VARCHAR2,
        x_message                       OUT NOCOPY VARCHAR2);

PROCEDURE is_value_set_allowed_dff
  (p_flex_value_set_id               IN   fnd_flex_value_sets.flex_value_set_id%TYPE,
   p_application_id                  IN   fnd_descr_flex_column_usages.application_id%TYPE,
   p_descriptive_flexfield_name      IN   fnd_descr_flex_column_usages.descriptive_flexfield_name%TYPE,
   p_desc_flex_context_code          IN   fnd_descr_flex_column_usages.descriptive_flex_context_code%TYPE,
   p_application_column_name         IN   fnd_descr_flex_column_usages.application_column_name%TYPE,
   p_end_user_column_name            IN   fnd_descr_flex_column_usages.end_user_column_name%TYPE,
   p_column_seq_num                  IN   fnd_descr_flex_column_usages.column_seq_num%TYPE);

PROCEDURE is_value_set_allowed_kff
  (p_flex_value_set_id         IN   fnd_flex_value_sets.flex_value_set_id%TYPE,
   p_application_id            IN   fnd_id_flex_segments.application_id%TYPE,
   p_id_flex_code              IN   fnd_id_flex_segments.id_flex_code%TYPE,
   p_id_flex_num               IN   fnd_id_flex_segments.id_flex_num%TYPE,
   p_application_column_name   IN   fnd_id_flex_segments.application_column_name%TYPE,
   p_segment_name              IN   fnd_id_flex_segments.segment_name%TYPE,
   p_segment_num               IN   fnd_id_flex_segments.segment_num%TYPE);

END fnd_flex_val_api;

/
