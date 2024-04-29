--------------------------------------------------------
--  DDL for Package HR_ID_FLEX_STRUCTURE_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ID_FLEX_STRUCTURE_INFO" 
/* $Header: hrkfsinf.pkh 115.2 2002/12/11 14:23:59 hjonnala ship $ */
AUTHID CURRENT_USER AS
  --
  -- Global Types
  --
  TYPE t_segment IS RECORD
    (column_name                    fnd_id_flex_segments.application_column_name%TYPE
    ,sequence                       fnd_id_flex_segments.segment_num%TYPE
    ,additional_column1_title       VARCHAR2(2000)
    ,additional_column1_width       VARCHAR2(2000)
    ,additional_column2_title       VARCHAR2(2000)
    ,additional_column2_width       VARCHAR2(2000)
    ,additional_column3_title       VARCHAR2(2000)
    ,additional_column3_width       VARCHAR2(2000)
    ,alphanumeric_allowed_flag      fnd_flex_value_sets.alphanumeric_allowed_flag%TYPE
    ,concatenation_description_len  fnd_id_flex_segments.concatenation_description_len%TYPE
    ,default_type                   fnd_id_flex_segments.default_type%TYPE
    ,default_value                  fnd_id_flex_segments.default_value%TYPE
    ,display_flag                   fnd_id_flex_segments.display_flag%TYPE
    ,display_size                   fnd_id_flex_segments.display_size%TYPE
    ,enabled_flag                   fnd_id_flex_segments.enabled_flag%TYPE
    ,flex_value_set_id              fnd_flex_value_sets.flex_value_set_id%TYPE
    ,flex_value_set_name            fnd_flex_value_sets.flex_value_set_name%TYPE
    ,format_type                    fnd_flex_value_sets.format_type%TYPE
    ,form_above_prompt              fnd_id_flex_segments_tl.form_above_prompt%TYPE
    ,form_left_prompt               fnd_id_flex_segments_tl.form_left_prompt%TYPE
    ,identification_sql             VARCHAR2(32767)
    ,id_column_type                 VARCHAR2(1)
    ,has_meaning                    BOOLEAN
    ,longlist_flag                  fnd_flex_value_sets.longlist_flag%TYPE
    ,maximum_description_len        fnd_id_flex_segments.maximum_description_len%TYPE
    ,maximum_size                   fnd_flex_value_sets.maximum_size%TYPE
    ,maximum_value                  fnd_flex_value_sets.maximum_value%TYPE
    ,minimum_value                  fnd_flex_value_sets.minimum_value%TYPE
    ,number_precision               fnd_flex_value_sets.number_precision%TYPE
    ,numeric_mode_enabled_flag      fnd_flex_value_sets.numeric_mode_enabled_flag%TYPE
    ,required_flag                  fnd_id_flex_segments.required_flag%TYPE
    ,segment_name                   fnd_id_flex_segments.segment_name%TYPE
    ,uppercase_only_flag            fnd_flex_value_sets.uppercase_only_flag%TYPE
    ,validation_sql                 VARCHAR2(32767)
    ,validation_type                fnd_flex_value_sets.validation_type%TYPE
    );
  TYPE t_segments IS TABLE OF t_segment;
  TYPE t_segments_pst IS TABLE OF t_segment INDEX BY BINARY_INTEGER;
--
-- -----------------------------------------------------------------------------
-- |--------------------------------< segments >-------------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns a table containing the details of columns for a key
--   flexfield structure. There will be a row in the returned table structure
--   for all columns available for the key flexfield, even though it may not be
--   used for the specified structure.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   Name                           Reqd Type     Description
--   p_application_id               Y    number   Application identifier
--   p_id_flex_code                 Y    varchar2 Key flexfield code
--   p_id_flex_num                  Y    number   Key flexfield structure number
--   p_effective_date               Y    date     Effective date
--
-- Post Success
--   A table containg the columns for the key flexfield structure is returned.
--
-- Post Failure
--   An error is raised.
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION segments
  (p_application_id               IN     fnd_id_flex_structures.application_id%TYPE
  ,p_id_flex_code                 IN     fnd_id_flex_structures.id_flex_code%TYPE
  ,p_id_flex_num                  IN     fnd_id_flex_structures.id_flex_num%TYPE
  ,p_effective_date               IN     DATE
  )
RETURN t_segments;
-- -----------------------------------------------------------------------------
-- |------------------------------< segments_pst >-----------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns a table containing the details of columns for a key
--   flexfield structure. There will be a row in the returned table structure
--   for all columns available for the key flexfield, even though it may not be
--   used for the specified structure.
--   A PL/SQL table is returned so it may be correctly retrieved by procedures
--   within a Forms Application. Form 6 cannot retrieve nested tables from
--   server-sde packages.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   Name                           Reqd Type     Description
--   p_application_short_name       Y    varchar2 Application short name
--   p_id_flex_code                 Y    varchar2 Key flexfield code
--   p_id_flex_num                  Y    number   Key flexfield structure number
--   p_effective_date               Y    date     Effective date
--
-- Post Success
--   A table containg the columns for the key flexfield structure is returned.
--
-- Post Failure
--   An error is raised.
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION segments_pst
  (p_application_short_name       IN     fnd_application.application_short_name%TYPE
  ,p_id_flex_code                 IN     fnd_id_flex_structures.id_flex_code%TYPE
  ,p_id_flex_num                  IN     fnd_id_flex_structures.id_flex_num%TYPE
  ,p_effective_date               IN     DATE
  )
RETURN t_segments_pst;
--
END hr_id_flex_structure_info;

 

/
