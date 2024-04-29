--------------------------------------------------------
--  DDL for Package HR_FLEXFIELD_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FLEXFIELD_INFO" AUTHID CURRENT_USER as
/* $Header: peffinfo.pkh 115.7 2002/12/05 16:31:13 pkakar ship $ */

TYPE boolean_a IS TABLE OF BOOLEAN INDEX BY BINARY_INTEGER;
TYPE segment_description_a IS TABLE OF
          VARCHAR2(2000) INDEX BY BINARY_INTEGER;
TYPE application_column_name_a IS TABLE OF
          VARCHAR2(2000)
          INDEX BY BINARY_INTEGER;
TYPE segment_name_a IS TABLE OF
          VARCHAR2(2000)
          INDEX BY BINARY_INTEGER;
TYPE sequence_a IS TABLE OF
          NUMBER
          INDEX BY BINARY_INTEGER;
TYPE display_size_a IS TABLE OF
          NUMBER
          INDEX BY BINARY_INTEGER;
TYPE row_prompt_a IS TABLE OF
          VARCHAR2(2000)
          INDEX BY BINARY_INTEGER;
TYPE column_prompt_a IS TABLE OF
          VARCHAR2(2000)
          INDEX BY BINARY_INTEGER;
TYPE value_set_a IS TABLE OF
          NUMBER
          INDEX BY BINARY_INTEGER;
TYPE validation_type_a IS TABLE OF
          VARCHAR2(2000)
          INDEX BY BINARY_INTEGER;
TYPE default_type_a IS TABLE OF
          VARCHAR2(2000)
          INDEX BY BINARY_INTEGER;
TYPE default_value_a IS TABLE OF
          VARCHAR2(2000)
          INDEX BY BINARY_INTEGER;
TYPE parent_segments_a IS TABLE OF
          VARCHAR2(2000)
          INDEX BY BINARY_INTEGER;
TYPE number_parents_a IS TABLE OF
          BINARY_INTEGER
          INDEX BY BINARY_INTEGER;
TYPE psegment_pointer_a IS TABLE OF
          BINARY_INTEGER
          INDEX BY BINARY_INTEGER;
TYPE ak_region_code_a IS TABLE OF
          fnd_common_lookups.meaning%TYPE
          INDEX BY BINARY_INTEGER;
TYPE number_of_children_a IS TABLE OF
          NUMBER
          INDEX BY BINARY_INTEGER;
TYPE format_type_a IS TABLE OF
          fnd_flex_value_sets.format_type%TYPE
          INDEX BY BINARY_INTEGER;
TYPE alphanumeric_allowed_flag_a IS TABLE OF
          fnd_flex_value_sets.alphanumeric_allowed_flag%TYPE
          INDEX BY BINARY_INTEGER;
TYPE uppercase_only_flag_a IS TABLE OF
          fnd_flex_value_sets.uppercase_only_flag%TYPE
          INDEX BY BINARY_INTEGER;
TYPE numeric_mode_enabled_flag_a IS TABLE OF
          fnd_flex_value_sets.numeric_mode_enabled_flag%TYPE
          INDEX BY BINARY_INTEGER;
TYPE maximum_size_a IS TABLE OF
          fnd_flex_value_sets.maximum_size%TYPE
          INDEX BY BINARY_INTEGER;
TYPE maximum_value_a IS TABLE OF
          fnd_flex_value_sets.maximum_value%TYPE
          INDEX BY BINARY_INTEGER;
TYPE minimum_value_a IS TABLE OF
          fnd_flex_value_sets.minimum_value%TYPE
          INDEX BY BINARY_INTEGER;
TYPE sql_text_a IS TABLE OF
          LONG
          INDEX BY BINARY_INTEGER;
TYPE segment_value_a IS TABLE OF
          VARCHAR2(2000)
          INDEX BY BINARY_INTEGER;
TYPE segment_value_changed_a IS TABLE OF
          BOOLEAN
          INDEX BY BINARY_INTEGER;

TYPE segments IS RECORD (
  n_segments binary_integer,
  segment_name segment_name_a,
  segment_value segment_value_a,
  segment_value_changed segment_value_changed_a);

TYPE hr_segments_info IS RECORD (nsegments  BINARY_INTEGER,
     application_column_name application_column_name_a,
     segment_name        segment_name_a,
     sequence            sequence_a,
     is_displayed        boolean_a,
     display_size        display_size_a,
     row_prompt          row_prompt_a,
     column_prompt       column_prompt_a,
     is_enabled          boolean_a,
     is_required         boolean_a,
     description         segment_description_a,
     value_set           value_set_a,
     validation_type     validation_type_a,
     default_type        default_type_a,
     default_value       default_value_a,
     number_parents      number_parents_a,
     number_children     number_of_children_a,
     psegment_pointer    psegment_pointer_a,
     parent_segments     parent_segments_a,
     ak_region_code      ak_region_code_a,
     format_type         format_type_a,
     alphanumeric_allowed_flag alphanumeric_allowed_flag_a,
     uppercase_only_flag uppercase_only_flag_a,
     numeric_mode_flag   numeric_mode_enabled_flag_a,
     max_size            maximum_size_a,
     max_value           maximum_value_a,
     min_value           minimum_value_a,
     longlist_enabled    boolean_a,
     has_id              boolean_a,
     has_meaning         boolean_a,
     sql_text            sql_text_a,
     sql_txt_descr       sql_text_a);
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< Initialize >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--            This procedure initializes the global variables used by the
-- HR_FLEXFIELD_INFO package.  It should be called before any other call to
-- this package.
--
-- Prerequisites:
--            There are no prerequisites to using this procedure.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--    None
--
-- Post Success:
--   The global variables are initialized.
--
-- Post Failure:
--   This procedure will not generate any error.
--
-- Access Status:
--   Public.
--
-- {End of Comments}
--
procedure initialize;
--
procedure structure_column_name(
                      p_appl_short_name IN VARCHAR2
                     ,p_flex_name IN VARCHAR2
                     ,p_column_name OUT NOCOPY VARCHAR2
                     ,p_column_name_prompt OUT NOCOPY VARCHAR2
                     ,p_dcontext_field OUT NOCOPY VARCHAR2
                     ,p_default_context_value OUT NOCOPY VARCHAR2);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_concatenated_contexts >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure retrieves the context_codes for a descriptive flexfield
--  and concatenates with any character that is passed to this procedure
--  through p_concatenation_chr input parameter.  This procedure was built
--  for a particular Self Service WEB requirement.
--
-- Prerequisites:
--  There are no prereqs for this procedure.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_appl_short_name               Yes varchar2 Application Short Name
--                                                (eg. 'FND','PER',etc.)
--   p_flexfield_name                Yes varchar2 Flexfield name
--   p_enabled_only                  Yes boolean  'TRUE' for enabled contexts
--                                                and 'FALSE' for all contexts
--   p_concatenation_chr             Yes varchar2 Character that should be
--                                                used for concatenation
--                                                (eg. '-','#',etc.)
--
-- Out Parameters:
--   Name                Type      Description
--   p_context_list      long      This out parameter will contain the
--                                 concatenated list of the contexts
-- Post Success:
--   A string containing the  valid contexts are returned.  The contexts
--   are separated by the concenation character sent in by the calling
--   procedure.
--
-- Post Failure:
--   An empty string is returned.
--
-- Access Status:
--   Public.
--
PROCEDURE get_concatenated_contexts
              (p_appl_short_name IN
                     fnd_application.application_short_name%TYPE,
               p_flexfield_name  IN
                     fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE,
               p_enabled_only      IN  BOOLEAN,
               p_concatenation_chr IN  VARCHAR2,
               p_context_list      OUT NOCOPY LONG);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_segments >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure retrieves the segment information for a particular context
--  of a descriptive flexfield.  It makes use of AOL flexfield APIs
--  FND_DFLEX.get_contexts.
--
--  Prerequisites:
--           A call to initialize must be made before this procedure will
--   function properly.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_appl_short_name               Yes varchar2 Application Short Name
--                                                (eg. 'FND','PER',etc.)
--   p_flexfield_name                Yes varchar2 Flexfield name
--   p_context_code                  Yes varchar2 Context Code
--   p_enabled_only                  Yes boolean  'TRUE' for enabled segments
--                                                and 'FALSE' for all segments
--
-- Out Parameters:
--   Name          Type                         Description
--   p_segments    hr_flexfield_info_pkg.       This out parameter will contain
--                    hr_segments_info          information about all segments
--                                              within a particular context
--                                              of the flexfield in the
--                                              following record structure
--
-- TYPE segments_info IS RECORD (nsegments,
--    application_column_name, (The column to which the segment is mapped)
--    segment_name, (The name given to the segment)
--    sequence,  (The order of the display of segments)
--    is_displayed, (whether the segment is displayed)
--    display_size, (An appropriate display size)
--    row_prompt, (The prompt for the segment)
--    column_prompt (The prompt for an LOV associated with this segment)
--    is_enabled, (Whether the segment is enabled?)
--    is_required,(Whether this is a required segment)
--    description, (the description of the segment)
--    value_set, (The ID of the value set associated with the segment)
--    default_type, (The default type of the segment)
--    default_value (The default value of the segment)
--     number_parents (The number of segments that must be populated before
--                     this segment can be entered)
--     psegment_pointer (The pointer to the parent segments table for this
--                     segment)
--     parent_segments (A list of the parent segments of this segment)
--     ak_region_code (The region code need for the Java window LOV)
--     format_type (The format type of the segment)
--     alphanumeric_allowed_flag (Whether this segment is numbers only)
--     uppercase_only_flag (Whether the aphlas in this segment must be
--                          uppercase)
--     numeric_mode_flag   (Whether the numbers in this field are right
--                          justified an zero filled)
--     max_size            (The maximum number of characters in the
--                          segment)
--     max_value           (The maximum value of the segment)
--     min_value           (The minimum value of the segment)
--     longlist_enabled    (Whether the LOV is a long list)
--     has_id              (Whether the value set has an ID column)
--     has_meaning         (Whether the value set has a meaning column)
--     sql_text            (The SQL text needed to generate the LOV for
--                          this segment)
--     sql_txt_descr       (The SQL text need to convert the value/id into
--                          a meaning or the id into a value)
--
-- Post Success:
--   The record structure is fully populated with the information on
--   the segments for the supplied flexfield, for the supplied context
--   procedure.
--
-- Post Failure:
--   A Null record is returned. (Dependant on the behaviour of the
--   the flexfield routine)
--
-- Access Status:
--   Public.
--
--
PROCEDURE get_segments
              (p_appl_short_name IN
                     fnd_application.application_short_name%TYPE,
               p_flexfield_name  IN
                     fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE,
               p_context_code    IN  VARCHAR2,
               p_enabled_only    IN  BOOLEAN,
               p_segments        OUT NOCOPY hr_segments_info,
               p_session_date    IN  DATE);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< build_sql_text >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--             This procedure replaces the application column name bind
-- variables in the SQL text with the entered values.  Note these values
-- must be those the flexfield is expecting to store on the Database, i.e
-- the 'VALUE' or 'ID' - not the 'DESCRIPTION'.  Each column name must have
-- the value associated with it.
--
-- Prerequisites:
--             The SQL text must be that obtained from a call to
-- get_segments.  It can be either SQL text.  You *must* supply all
-- possible bind reference data to this procedure.
--
-- In Parameters:
--   Name                Req'd  Type             Description
-- p_sql_text              Y     LONG            The SQL text, found from a call
--                                               to get_validation_info
-- p_application_short_name Y    VARCHAR2        The short name of the calling
--                                               application
-- p_application_table_name Y    VARCHAR2        The table name associated with
--                                               this flexfield.
-- p_column_namex          N     VARCHAR2        A base table column name
--                                               associated with this flexfield
-- p_column_valuex         N     VARCHAR2        The value associated with the
--                                               xth column
--
-- Out Parameters:
--   Name                Type             Description
--
--   p_sql_text           LONG            The SQL text, with the bind references
--                                        replaced with the actual values.
--
-- Post Success:
--   The SQL text will replace any bind references of the form
--   APPLICATION_COLUMN_NAME, with the supplied value.
--
-- Post Failure:
--   This procedure will fail if a bind reference is supplied for which
--   there is no value.  The bind reference will remain in the SQL text,
--   and thus the SQL text will not run against a database without further
--   input.
--
-- Access Status:
--   Public.

PROCEDURE build_sql_text(
			 p_sql_text IN OUT NOCOPY long,
			 p_application_short_name IN fnd_application.application_short_name%TYPE,
			 p_application_table_name IN fnd_tables.table_name%TYPE,
			 p_segment_name_value IN segments);

PROCEDURE build_sql_text
              (p_sql_text       IN OUT NOCOPY long,
               p_application_short_name in
                                    fnd_application.application_short_name%TYPE,
               p_application_table_name in fnd_tables.table_name%TYPE,
               p_column_name1   IN VARCHAR2 default null,
               p_column_value1  IN VARCHAR2 default null,
               p_column_name2   IN VARCHAR2 default null,
               p_column_value2  IN VARCHAR2 default null,
               p_column_name3   IN VARCHAR2 default null,
               p_column_value3  IN VARCHAR2 default null,
               p_column_name4   IN VARCHAR2 default null,
               p_column_value4  IN VARCHAR2 default null,
               p_column_name5   IN VARCHAR2 default null,
               p_column_value5  IN VARCHAR2 default null,
               p_column_name6   IN VARCHAR2 default null,
               p_column_value6  IN VARCHAR2 default null,
               p_column_name7   IN VARCHAR2 default null,
               p_column_value7  IN VARCHAR2 default null,
               p_column_name8   IN VARCHAR2 default null,
               p_column_value8  IN VARCHAR2 default null,
               p_column_name9   IN VARCHAR2 default null,
               p_column_value9  IN VARCHAR2 default null,
               p_column_name10   IN VARCHAR2 default null,
               p_column_value10  IN VARCHAR2 default null,
               p_column_name11   IN VARCHAR2 default null,
               p_column_value11  IN VARCHAR2 default null,
               p_column_name12   IN VARCHAR2 default null,
               p_column_value12  IN VARCHAR2 default null,
               p_column_name13   IN VARCHAR2 default null,
               p_column_value13  IN VARCHAR2 default null,
               p_column_name14   IN VARCHAR2 default null,
               p_column_value14  IN VARCHAR2 default null,
               p_column_name15   IN VARCHAR2 default null,
               p_column_value15  IN VARCHAR2 default null,
               p_column_name16   IN VARCHAR2 default null,
               p_column_value16  IN VARCHAR2 default null,
               p_column_name17   IN VARCHAR2 default null,
               p_column_value17  IN VARCHAR2 default null,
               p_column_name18   IN VARCHAR2 default null,
               p_column_value18  IN VARCHAR2 default null,
               p_column_name19   IN VARCHAR2 default null,
               p_column_value19  IN VARCHAR2 default null,
               p_column_name20   IN VARCHAR2 default null,
               p_column_value20  IN VARCHAR2 default null,
               p_column_name21   IN VARCHAR2 default null,
               p_column_value21  IN VARCHAR2 default null,
               p_column_name22   IN VARCHAR2 default null,
               p_column_value22  IN VARCHAR2 default null,
               p_column_name23   IN VARCHAR2 default null,
               p_column_value23  IN VARCHAR2 default null,
               p_column_name24   IN VARCHAR2 default null,
               p_column_value24  IN VARCHAR2 default null,
               p_column_name25   IN VARCHAR2 default null,
               p_column_value25  IN VARCHAR2 default null,
               p_column_name26   IN VARCHAR2 default null,
               p_column_value26  IN VARCHAR2 default null,
               p_column_name27   IN VARCHAR2 default null,
               p_column_value27  IN VARCHAR2 default null,
               p_column_name28   IN VARCHAR2 default null,
               p_column_value28  IN VARCHAR2 default null,
               p_column_name29   IN VARCHAR2 default null,
               p_column_value29  IN VARCHAR2 default null,
               p_column_name30   IN VARCHAR2 default null,
               p_column_value30  IN VARCHAR2 default null);
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_kf_concatenated_structures >-------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure retrieves the structure codes for a key flexfield,
--  and concatenates with any character that is passed to this procedure
--  through p_concatenation_chr input parameter.
--
-- Prerequisites:
--  There are no prereqs for this procedure.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_appl_short_name               Yes varchar2 Application Short Name
--                                                (eg. 'FND','PER',etc.)
--   p_id_flex_code                  Yes varchar2 Flexfield name
--   p_enabled_only                  Yes boolean  TRUE for enabled structures
--                                                and FALSE for all structures.
--   p_concatenation_chr             Yes varchar2 Character that should be
--                                                used for concatenation
--                                                (eg. '-','#',etc.)
--
-- Out Parameters:
--   Name                Type      Description
--   p_structure_list    long      This out parameter will contain the
--                                 concatenated list of the contexts
-- Post Success:
--   A string containing the valid structures are returned.  The structures
--   are separated by the concatenation character sent in by the calling
--   procedure.
--
-- Post Failure:
--   An empty string is returned.
--
-- Access Status:
--   Public.
--
PROCEDURE get_kf_concatenated_structures
(p_appl_short_name   IN     fnd_application.application_short_name%TYPE
,p_id_flex_code      IN     fnd_id_flex_structures_vl.id_flex_code%TYPE
,p_enabled_only      IN     BOOLEAN
,p_concatenation_chr IN     VARCHAR2
,p_structure_list       OUT NOCOPY LONG
);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_kf_segments >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure retrieves the segment information for a particular
--  key flexfield structure. It makes use of AOL key flexfield APIs.
--
--  Prerequisites:
--   A call to initialize must be made before each call of this procedure.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_appl_short_name               Yes varchar2 Application Short Name
--                                                (eg. 'FND','PER',etc.)
--   p_id_flex_code                  Yes varchar2 Identifies the flexfield.
--   p_id_flex_structure_name        Yes varchar2 Identifies the structure.
--   p_enabled_only                  Yes boolean  'TRUE' for enabled segments
--                                                and 'FALSE' for all segments
--
-- Out Parameters:
--   Name          Type                         Description
--   p_segments    hr_segments_info             This out parameter will contain
--                                              information about all segments
--                                              for a particular structure
--                                              of the flexfield.
-- Post Success:
--   The record structure is fully populated with the information on
--   the segments for the supplied flexfield, for the supplied context
--   procedure.
--
-- Post Failure:
--   A Null record is returned. (Dependant on the behaviour of the
--   flexfield routine)
--
-- Access Status:
--   Public.
--
--
PROCEDURE get_kf_segments
(p_appl_short_name        IN  fnd_application.application_short_name%TYPE
,p_id_flex_code           IN  fnd_id_flex_structures_vl.id_flex_code%TYPE
,p_id_flex_structure_name IN
 fnd_id_flex_structures_vl.id_flex_structure_name%TYPE
,p_enabled_only           IN  BOOLEAN
,p_segments               OUT NOCOPY hr_segments_info
,p_session_date           IN  DATE
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< gen_ak_web_region_code >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This function returns the AK_WEB_REGION_CODE lookup value for a
--  segment within an instance of a flexfield.
--
-- Prerequisites:
--  There are no prereqs for this function.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_flexfield                     Yes varchar2 The flexfield.
--   p_context_or_id_flex_num        Yes varchar2 The flexfield instance.
--   p_segment                       Yes varchar2 The flexfield segment.
--
-- Access Status:
--   Public.
--
--
function gen_ak_web_region_code
(p_flex_type              in varchar2
,p_flexfield              in varchar2
,p_context_or_id_flex_num in varchar2
,p_segment                in varchar2
) return varchar2;

end hr_flexfield_info;

 

/
