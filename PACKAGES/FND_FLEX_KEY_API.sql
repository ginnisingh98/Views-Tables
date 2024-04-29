--------------------------------------------------------
--  DDL for Package FND_FLEX_KEY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_KEY_API" AUTHID CURRENT_USER AS
/* $Header: AFFFKAIS.pls 120.2.12010000.3 2016/03/11 22:13:22 tebarnes ship $ */


TYPE awc_element_type IS RECORD
        (tag     varchar2(30),
         clause  varchar2(4000));

TYPE awc_elements_type IS TABLE OF awc_element_type INDEX BY BINARY_INTEGER;


-- Turn debug mode on. enables some extra output.
PROCEDURE debug_on ;

-- Turn debug mode off. disables some extra output.
PROCEDURE debug_off ;

-- Turn validation on or off.
-- @param v_in validation on or off.
PROCEDURE set_validation(v_in BOOLEAN);

-- Specify the session mode.
-- @param session_mode the session mode; either seed_data or
-- 'customer_data'
PROCEDURE set_session_mode(session_mode IN VARCHAR2);

-- Returns the RCS header information for the package.
FUNCTION version RETURN VARCHAR2;

-- Return the current error message string.
FUNCTION message RETURN VARCHAR2;

bad_parameter EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_parameter, -06501);

TYPE flexfield_type IS RECORD
  (instantiated                VARCHAR2(1),
   appl_short_name             fnd_application.application_short_name%TYPE,
   flex_code                   fnd_id_flexs.id_flex_code%TYPE,

   flex_title                  fnd_id_flexs.id_flex_name%TYPE,
   description                 fnd_id_flexs.description%TYPE,
   table_appl_short_name       fnd_application.application_short_name%TYPE,
   table_name                  fnd_tables.table_name%TYPE,
   concatenated_segs_view_name fnd_id_flexs.concatenated_segs_view_name%TYPE,
   unique_id_column            fnd_id_flexs.unique_id_column_name%TYPE,
   structure_column            fnd_id_flexs.set_defining_column_name%TYPE,
   dynamic_inserts             fnd_id_flexs.dynamic_inserts_feasible_flag%TYPE,
   allow_id_value_sets         fnd_id_flexs.allow_id_valuesets%TYPE,
   index_flag                  fnd_id_flexs.index_flag%TYPE,
   concat_seg_len_max          fnd_id_flexs.maximum_concatenation_len%TYPE,
   concat_len_warning          fnd_id_flexs.concatenation_len_warning%TYPE,

   application_id              fnd_application.application_id%TYPE,
   table_application_id        fnd_application.application_id%TYPE,
   table_id                    fnd_tables.table_id%TYPE);

-- We would normally have a reference to the flexfield here,
-- but pl/sql doesn't support it, so require the flexfield_type
-- to be passed all the time.
TYPE structure_type IS RECORD
  (instantiated           VARCHAR2(1),
   structure_number       fnd_id_flex_structures_vl.id_flex_num%TYPE,
   structure_code         fnd_id_flex_structures_vl.id_flex_structure_code%TYPE,
   structure_name         fnd_id_flex_structures_vl.id_flex_structure_name%TYPE,
   description            fnd_id_flex_structures_vl.description%TYPE,
   view_name              fnd_id_flex_structures_vl.structure_view_name%TYPE,
   freeze_flag            fnd_id_flex_structures_vl.freeze_flex_definition_flag%TYPE,
   enabled_flag           fnd_id_flex_structures_vl.enabled_flag%TYPE,
   segment_separator      fnd_id_flex_structures_vl.concatenated_segment_delimiter%TYPE,
   cross_val_flag         fnd_id_flex_structures_vl.cross_segment_validation_flag%TYPE,
   freeze_rollup_flag     fnd_id_flex_structures_vl.freeze_structured_hier_flag%TYPE,
   dynamic_insert_flag    fnd_id_flex_structures_vl.dynamic_inserts_allowed_flag%TYPE,
   shorthand_enabled_flag fnd_id_flex_structures_vl.shorthand_enabled_flag%TYPE,
   shorthand_prompt       fnd_id_flex_structures_vl.shorthand_prompt%TYPE,
   shorthand_length       fnd_id_flex_structures_vl.shorthand_length%TYPE);

TYPE segment_type IS RECORD
  (instantiated              VARCHAR2(1),
   segment_name              fnd_id_flex_segments_vl.segment_name%TYPE,
   description               fnd_id_flex_segments_vl.description%TYPE,
   column_name               fnd_id_flex_segments_vl.application_column_name%TYPE,
   segment_number            fnd_id_flex_segments_vl.segment_num%TYPE,
   enabled_flag              fnd_id_flex_segments_vl.enabled_flag%TYPE,
   displayed_flag            fnd_id_flex_segments_vl.display_flag%TYPE,
   indexed_flag              fnd_id_flex_segments_vl.application_column_index_flag%TYPE,
   value_set_id              fnd_id_flex_segments_vl.flex_value_set_id%TYPE,
   value_set_name            fnd_flex_value_sets.flex_value_set_name%TYPE,
   default_type              fnd_id_flex_segments_vl.default_type%TYPE,
   default_value             fnd_id_flex_segments_vl.default_value%TYPE,
   runtime_property_function fnd_id_flex_segments_vl.runtime_property_function%TYPE,
   additional_where_clause   fnd_id_flex_segments_vl.additional_where_clause%TYPE,
   required_flag             fnd_id_flex_segments_vl.required_flag%TYPE,
   security_flag             fnd_id_flex_segments_vl.security_enabled_flag%TYPE,
   range_code                fnd_id_flex_segments_vl.range_code%TYPE,

   display_size              fnd_id_flex_segments_vl.display_size%TYPE,
   description_size          fnd_id_flex_segments_vl.maximum_description_len%TYPE,
   concat_size               fnd_id_flex_segments_vl.concatenation_description_len%TYPE,
   lov_prompt                fnd_id_flex_segments_vl.form_above_prompt%TYPE,
   window_prompt             fnd_id_flex_segments_vl.form_left_prompt%TYPE);

TYPE structure_list IS TABLE OF fnd_id_flex_structures.id_flex_num%TYPE
  INDEX BY BINARY_INTEGER;

TYPE segment_list IS TABLE OF fnd_id_flex_segments.segment_name%TYPE
  INDEX BY BINARY_INTEGER;


-- Last created (via find or new/add) versions
last_flexfield flexfield_type;
last_structure structure_type;
last_segment   segment_type;


--
-- Check for existance by either set of criteria
-- (short name and code or short name and title)
-- @param appl_short_name the application short name of the flexfield
-- @param flex_code the flexfield code of the flexfield
-- @param flex_title the title of the flexfield
-- @return true if the flexfield exists in the database
FUNCTION flexfield_exists
  (appl_short_name    IN VARCHAR2,
   flex_code          IN VARCHAR2 DEFAULT NULL,
   flex_title         IN VARCHAR2 DEFAULT NULL)
  RETURN BOOLEAN;


--
-- Create a new key flexfield
-- @return a handle to the flexfield
--
FUNCTION new_flexfield
  (appl_short_name             IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   flex_code                   IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   flex_title                  IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   description                 IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   table_appl_short_name       IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   table_name                  IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   unique_id_column            IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   structure_column            IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   dynamic_inserts             IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   allow_id_value_sets         IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   index_flag                  IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   concat_seg_len_max          IN NUMBER   DEFAULT fnd_api.g_null_num,
   concat_len_warning          IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   concatenated_segs_view_name IN VARCHAR2 DEFAULT fnd_api.g_null_char)
  RETURN flexfield_type;

-- find a flexfield when base table not in fnd_tables or fnd_columns
--  (i.e. following data dictionary cleanup)
-- @param appl_short_name the application short name of the flexfield
-- being searched for
-- @param flex_code the id_flex_code for the flexfield being searched for.
-- @return a handle to the fieldfield.
FUNCTION find_flexfield_notab
  (appl_short_name    IN VARCHAR2,
   flex_code          IN VARCHAR2)
  RETURN flexfield_type;


-- find a flexfield
-- @param appl_short_name the application short name of the flexfield
-- being searched for
-- @param flex_code the id_flex_code for the flexfield being searched for.
-- @return a handle to the fieldfield.
FUNCTION find_flexfield
  (appl_short_name    IN VARCHAR2,
   flex_code          IN VARCHAR2)
  RETURN flexfield_type;


-- register a flexfield
-- @param flexfield the flexfield to register
-- @param enable_columns determies whether to enable the columns
-- that are normally enabled when a flexfield is registers
-- in the form.
PROCEDURE register
  (flexfield        IN OUT nocopy flexfield_type,
   enable_columns   IN VARCHAR2 DEFAULT 'Y');


-- delete a flexfield
-- @param flexfield the flexfield to delete
PROCEDURE delete_flexfield
  (flexfield  IN flexfield_type);

-- delete a flexfield
-- @param appl_short_name the application short name of the application
-- the flexfield belongs to.
-- @param flex_code the id flexc code for the flexfield.
PROCEDURE delete_flexfield
  (appl_short_name       IN VARCHAR2,
   flex_code             IN VARCHAR2);

-- drop the concatenated segment view for the KFF for bug#5058433
PROCEDURE drop_KFV
      (p_application_id       IN VARCHAR2,
       p_flex_code            IN VARCHAR2);

--
-- enable (or disable) columns for the flexfield.
--
PROCEDURE enable_column
  (flexfield             IN flexfield_type,
   column_name           IN VARCHAR2,
   enable_flag           IN VARCHAR2 DEFAULT 'Y');

-- update fnd_columns
--
-- enable (or disable) a batch of columns at the same time.
-- @param pattern the pattern to match for column name. uses
-- the sql LIKE match.
-- @param enable_fleg whetther we are enabling or disabling. Y/N
PROCEDURE enable_columns_like
  (flexfield             IN flexfield_type,
   pattern               IN VARCHAR2,
   enable_flag           IN VARCHAR2 DEFAULT 'Y');


--
-- create a new flexfield qualifier
--
PROCEDURE add_flex_qualifier
  (flexfield             IN flexfield_type,
   qualifier_name        IN VARCHAR2,
   prompt                IN VARCHAR2,
   description           IN VARCHAR2,
   global_flag           IN VARCHAR2 DEFAULT 'N',
   required_flag         IN VARCHAR2 DEFAULT 'N',
   unique_flag           IN VARCHAR2 DEFAULT 'N');


--
-- delete flexfield qualifier.
-- If recursive_delete is TRUE then all flexfield qualifier
-- related data will also be deleted. (Segment qualifiers, and
-- associations between segments and flexfield qualifier.)
-- if recursive_delete is FALSE but there is related data
-- then this function will not delete the flexfield qualifier.
-- Returns -1 in case of error,
--          0 if nothing to delete,
--          # number of deletes for successful operation.
--
FUNCTION delete_flex_qualifier
  (flexfield        IN flexfield_type,
   qualifier_name   IN VARCHAR2,
   recursive_delete IN BOOLEAN DEFAULT TRUE)
  RETURN NUMBER;


--
-- fill in cross product table between flexfield qualifier and
-- segments.
-- This is mostly used when a qualifier is created in seed database.
-- In this case upgrading customers will not get fnd_segment_attribute_values
-- table populated properly. So this function should be called in
-- post-DataMerge phase.
--
-- Returns -1 in case of error,
--          0 if nothing to assign
--          # number of assigns for successful operation.
--
FUNCTION fill_segment_attribute_values
  RETURN NUMBER;


--
-- create a new segment qualifier
--
PROCEDURE add_seg_qualifier
  (flexfield             IN flexfield_type,
   flex_qualifier        IN VARCHAR2,

   qualifier_name        IN VARCHAR2,
   prompt                IN VARCHAR2,
   description           IN VARCHAR2,
   derived_column        IN VARCHAR2,
   quickcode_type        IN VARCHAR2,
   default_value         IN VARCHAR2);


--
-- delete segment qualifier.
-- Warning : Flex team do not suggest deleting a segment qualifier.
--           If some values are created with segment qualifier values,
--           then you may get inconcistent behavior for those values.
-- Since segment qualifier values are parsed according to their assignment
-- dates, deleting them may cause inconsistent data.
--
-- Returns -1 in case of error,
--          0 if nothing to delete,
--          # number of deletes for successful operation.
--
FUNCTION delete_seg_qualifier
  (flexfield          IN flexfield_type,
   flex_qualifier     IN VARCHAR2,
   qualifier_name     IN VARCHAR2) RETURN NUMBER;


-- create a new flexfield structure.
FUNCTION new_structure
  (flexfield              IN flexfield_type,

   structure_code         IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   structure_title        IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   description            IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   view_name              IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   freeze_flag            IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   enabled_flag           IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   segment_separator      IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   cross_val_flag         IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   freeze_rollup_flag     IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   dynamic_insert_flag    IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   shorthand_enabled_flag IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   shorthand_prompt       IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   shorthand_length       IN NUMBER   DEFAULT fnd_api.g_null_num)
  RETURN structure_type;


-- find a flexfield structure
-- @param flexfield  the flexfield the structure belongs to
-- @param structure_code the code of the structure
FUNCTION find_structure
  (flexfield              IN flexfield_type,
   structure_code         IN VARCHAR2)
  RETURN structure_type;


-- locate a structure by its structure number
-- @param flexfield  the flexfield the structure belongs to
-- @param structure_number the structure number being searched for
-- @return the structure handle
-- @see find_structure
FUNCTION find_structure
  (flexfield              IN flexfield_type,
   structure_number       IN NUMBER)
  RETURN structure_type;


--
-- add a structure to a flexfield
--
PROCEDURE add_structure
  (flexfield IN flexfield_type DEFAULT last_flexfield,
   structure IN OUT nocopy structure_type);


-- delete a structure
PROCEDURE delete_structure
  (flexfield             IN flexfield_type,
   structure             IN structure_type);

-- delete the structure view bug#5058433
PROCEDURE drop_KFSV
  (p_application_id       IN VARCHAR2,
   p_flex_code             IN VARCHAR2,
   p_struct_num            IN NUMBER);


-- create a new segment
-- @return the segment handle
FUNCTION new_segment
  (flexfield IN flexfield_type,
   structure IN structure_type,

   segment_name              IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   description               IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   column_name               IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   segment_number            IN NUMBER   DEFAULT fnd_api.g_null_num,
   enabled_flag              IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   displayed_flag            IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   indexed_flag              IN VARCHAR2 DEFAULT fnd_api.g_null_char,

   /* validation */
   value_set                 IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   default_type              IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   default_value             IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   required_flag             IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   security_flag             IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   range_code                IN VARCHAR2 DEFAULT fnd_api.g_null_char,

   /* sizes */
   display_size              IN NUMBER   DEFAULT fnd_api.g_null_num,
   description_size          IN NUMBER   DEFAULT fnd_api.g_null_num,
   concat_size               IN NUMBER   DEFAULT fnd_api.g_null_num,

   /* prompts */
   lov_prompt                IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   window_prompt             IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   runtime_property_function IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   additional_where_clause   IN VARCHAR2 DEFAULT fnd_api.g_null_char)
  RETURN segment_type;


-- locate a segment by its name.
-- @param flexfield  the flexfield
-- @param structure the structure
-- @param segment_name the segment name
-- @return the segment handle
FUNCTION find_segment
  (flexfield    IN flexfield_type,
   structure    IN structure_type,
   segment_name IN VARCHAR2)
  RETURN segment_type;


--
-- add a segment to a structure
--
PROCEDURE add_segment
  (flexfield IN flexfield_type,
   structure IN structure_type,
   segment   IN OUT nocopy segment_type);
-- insert into fnd_id_flex_segments
-- insert into fnd_segment_attribute_values
-- insert into fnd_flex_validation_qualifiers


-- delete a segment
-- @param flexfield  the flexfield
-- @param structure the structure
-- @param segment the segment
PROCEDURE delete_segment
  (flexfield             IN flexfield_type,
   structure             IN structure_type,
   segment               IN segment_type);


-- assign a qualifier.
-- qualifiers are automatiicaly assigned as disabled when the segment
-- is created.
-- @param flexfield  the flexfield
-- @param structure the structure
-- @param segment the segment
-- @param flexfield_qualifier the flexfield qualifier
-- @param enable_flag enable if 'Y', disable if 'N'
PROCEDURE assign_qualifier
  (flexfield             IN flexfield_type,
   structure             IN structure_type,
   segment               IN segment_type,
   flexfield_qualifier   IN VARCHAR2,
   enable_flag           IN VARCHAR2 DEFAULT 'Y');
-- update fnd_segment_attribute_values


-- Modify the specified flexfield based on the values specified in
-- the new flexfield.
-- @param original the flexfield to be modified
-- @param modified the new flexfield information to be changed to
PROCEDURE modify_flexfield
  (original        IN flexfield_type,
   modified        IN flexfield_type);


-- Modify the specified flexfield structure based on the values specified in
-- the new structure.
-- @param flexfield the flexfield
-- @param original the structure to be modified
-- @param modified the new structure information to be changed to
PROCEDURE modify_structure
  (flexfield       IN flexfield_type,
   original        IN structure_type,
   modified        IN structure_type);


-- Modify the specified segment based on the values specified in
-- the new segment.
-- @param flexfield the flexfield
-- @param structure the structure
-- @param original the segment to be modified
-- @param modified the new segment information to be changed to
PROCEDURE modify_segment
  (flexfield       IN flexfield_type,
   structure       IN structure_type,
   original        IN segment_type,
   modified        IN segment_type);


-- a test function. not maintained.
PROCEDURE test(name IN VARCHAR2);


-- Print out a program that will create this flexfield.
-- @param flexfield the flexfield to print out
-- @param recurse also create all dependent
--        structures, segments and qualifiers.
PROCEDURE dump_flexfield(flexfield          IN flexfield_type,
			 recurse            IN BOOLEAN DEFAULT TRUE);


PROCEDURE dump_all_flex_qualifiers(flexfield IN flexfield_type,
				   recurse   IN BOOLEAN DEFAULT TRUE);

PROCEDURE dump_all_seg_qualifiers(flexfield      IN flexfield_type,
				  flex_qualifier IN VARCHAR2);


PROCEDURE dump_structure(flexfield          IN flexfield_type,
			 structure          IN structure_type,
			 recurse            IN BOOLEAN DEFAULT TRUE);


PROCEDURE dump_all_structures(flexfield     IN flexfield_type,
			      recurse       IN BOOLEAN DEFAULT TRUE);


PROCEDURE dump_segment(flexfield       IN flexfield_type,
		       structure       IN structure_type,
		       segment         IN segment_type);

PROCEDURE dump_all_segments(flexfield       IN flexfield_type,
			    structure       IN structure_type);


--
-- Return a list of structures for a flexfield.
-- @param flexfield the flexfield
-- @param enabled_only only return enabled segments if true
-- @param nsegments the number of segments returned
-- @param nsegments the segment names
PROCEDURE get_structures
  (flexfield    IN flexfield_type,
   enabled_only IN BOOLEAN DEFAULT TRUE,
   nstructures  OUT nocopy NUMBER,
   structures   OUT nocopy structure_list);

--
-- Return a list of the segments for a flexfield structure.
-- @param flexfield the flexfield
-- @param structure the structure to list segments for
-- @param enabled_only only return enabled segments if true
-- @param nsegments the number of segments returned
-- @param nsegments the segment names
PROCEDURE get_segments
  (flexfield    IN flexfield_type,
   structure    IN structure_type,
   enabled_only IN BOOLEAN DEFAULT TRUE,
   nsegments    OUT nocopy NUMBER,
   segments     OUT nocopy segment_list);

FUNCTION is_table_used(p_application_id IN fnd_tables.application_id%TYPE,
		       p_table_name     IN fnd_tables.table_name%TYPE,
		       x_message        OUT nocopy VARCHAR2) RETURN BOOLEAN;

FUNCTION is_column_used(p_application_id IN fnd_tables.application_id%TYPE,
			p_table_name     IN fnd_tables.table_name%TYPE,
			p_column_name    IN fnd_columns.column_name%TYPE,
			x_message        OUT nocopy VARCHAR2) RETURN BOOLEAN;

--
-- Get the segment display order given the qualifier name.
--
FUNCTION get_seg_order_by_qual_name(p_application_id         IN  NUMBER,
				    p_id_flex_code           IN  VARCHAR2,
				    p_id_flex_num            IN  NUMBER,
				    p_segment_attribute_type IN  VARCHAR2,
				    x_segment_order          OUT nocopy NUMBER)
  RETURN BOOLEAN;

PROCEDURE get_awc_elements
                 (p_flexfield               IN flexfield_type,
                  p_structure               IN structure_type,
                  p_segment                 IN segment_type,
                  x_numof_awc_elements      OUT nocopy number,
                  x_awc_elements            OUT nocopy awc_elements_type);

PROCEDURE add_awc(p_flexfield               IN flexfield_type,
                  p_structure               IN structure_type,
                  p_segment                 IN segment_type,
                  p_tag                     IN varchar2,
                  p_clause                  IN varchar2);

PROCEDURE delete_awc(p_flexfield               IN flexfield_type,
                     p_structure               IN structure_type,
                     p_segment                 IN segment_type,
                     p_tag                     IN varchar2);

FUNCTION awc_exists(p_flexfield               IN flexfield_type,
                     p_structure               IN structure_type,
                     p_segment                 IN segment_type,
                     p_tag                     IN varchar2)
         RETURN BOOLEAN;

--
-- Remove all key flexfields whose base table is not registered in fnd_tables
--
PROCEDURE delete_missing_tbl_flexs ;

--
-- Cleanup both key and descriptive flexfields for data dictionary cleanup
-- initiative.  Requires removal of all key and descriptive flexfields
-- whose base table is not registered in fnd_tables.  The fnd_tables was
-- cleaned as part of the data dictionary cleanup initiative.  All entries
-- were removed when not found in either dba_tables, dba_views, or
-- dba_synonyms.  Flexfield base tables may be a table, view, or synonym.
--
PROCEDURE cleanup_flex_tables ;


END fnd_flex_key_api;

/
