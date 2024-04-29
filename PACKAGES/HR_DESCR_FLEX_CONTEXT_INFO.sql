--------------------------------------------------------
--  DDL for Package HR_DESCR_FLEX_CONTEXT_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DESCR_FLEX_CONTEXT_INFO" 
/* $Header: hrdfcinf.pkh 115.2 2002/12/10 08:51:49 hjonnala ship $ */
AUTHID CURRENT_USER AS
  --
  -- Global Types
  --
  TYPE t_segment IS RECORD
    (column_name                    fnd_descr_flex_column_usages.application_column_name%TYPE
    ,sequence                       fnd_descr_flex_column_usages.column_seq_num%TYPE
    ,additional_column1_title       VARCHAR2(2000)
    ,additional_column1_width       VARCHAR2(2000)
    ,additional_column2_title       VARCHAR2(2000)
    ,additional_column2_width       VARCHAR2(2000)
    ,additional_column3_title       VARCHAR2(2000)
    ,additional_column3_width       VARCHAR2(2000)
    ,alphanumeric_allowed_flag      fnd_flex_value_sets.alphanumeric_allowed_flag%TYPE
    ,concatenation_description_len  fnd_descr_flex_column_usages.concatenation_description_len%TYPE
    ,default_type                   fnd_descr_flex_column_usages.default_type%TYPE
    ,default_value                  fnd_descr_flex_column_usages.default_value%TYPE
    ,display_flag                   fnd_descr_flex_column_usages.display_flag%TYPE
    ,display_size                   fnd_descr_flex_column_usages.display_size%TYPE
    ,enabled_flag                   fnd_descr_flex_column_usages.enabled_flag%TYPE
    ,end_user_column_name           fnd_descr_flex_column_usages.end_user_column_name%TYPE
    ,flex_value_set_id              fnd_flex_value_sets.flex_value_set_id%TYPE
    ,flex_value_set_name            fnd_flex_value_sets.flex_value_set_name%TYPE
    ,format_type                    fnd_flex_value_sets.format_type%TYPE
    ,form_above_prompt              fnd_descr_flex_col_usage_tl.form_above_prompt%TYPE
    ,form_left_prompt               fnd_descr_flex_col_usage_tl.form_left_prompt%TYPE
    ,identification_sql             VARCHAR2(32767)
    ,id_column_type                 VARCHAR2(1)
    ,has_meaning                    BOOLEAN
    ,longlist_flag                  fnd_flex_value_sets.longlist_flag%TYPE
    ,maximum_description_len        fnd_descr_flex_column_usages.maximum_description_len%TYPE
    ,maximum_size                   fnd_flex_value_sets.maximum_size%TYPE
    ,maximum_value                  fnd_flex_value_sets.maximum_value%TYPE
    ,minimum_value                  fnd_flex_value_sets.minimum_value%TYPE
    ,number_precision               fnd_flex_value_sets.number_precision%TYPE
    ,numeric_mode_enabled_flag      fnd_flex_value_sets.numeric_mode_enabled_flag%TYPE
    ,required_flag                  fnd_descr_flex_column_usages.required_flag%TYPE
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
--   This function returns a table containing the details of columns for a
--   descriptive flexfield context. There will be a row in the returned table
--   structure for all columns available for the descriptive flexfield, even
--   though it may not be used for the specified context.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   p_application_id               Y    number   Application identifier
--   p_descriptive_flexfield_name   Y    varchar2 Descriptive flexfield name
--   p_descr_flex_context_code      Y    varchar2 Descriptive flexfield context
--   p_effective_date               Y    date     Effective date
--
-- Post Success
--   A table containg the columns for the descriptive flexfield structure is
--   returned.
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
  (p_application_id               IN     fnd_descr_flex_contexts.application_id%TYPE
  ,p_descriptive_flexfield_name   IN     fnd_descr_flex_contexts.descriptive_flexfield_name%TYPE
  ,p_descr_flex_context_code      IN     fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE
  ,p_effective_date               IN     DATE
  )
RETURN t_segments;
--
-- -----------------------------------------------------------------------------
-- |------------------------------< segments_pst >-----------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns a table containing the details of columns for a
--   descriptive flexfield context. There will be a row in the returned table
--   structure for all columns available for the descriptive flexfield, even
--   though it may not be used for the specified context.
--   A PL/SQL table is returned so it may be correctly retrieved by procedures
--   within a Forms Application. Forms 6 cannot retrieve nested tables from
--   server-side packages.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   p_application_short_name       Y    varchar2 Application short name
--   p_descriptive_flexfield_name   Y    varchar2 Descriptive flexfield name
--   p_descr_flex_context_code      Y    varchar2 Descriptive flexfield context
--   p_effective_date               Y    date     Effective date
--
-- Post Success
--   A table containg the columns for the descriptive flexfield structure is
--   returned.
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
  ,p_descriptive_flexfield_name   IN     fnd_descr_flex_contexts.descriptive_flexfield_name%TYPE
  ,p_descr_flex_context_code      IN     fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE
  ,p_effective_date               IN     DATE
  )
RETURN t_segments_pst;
--
END hr_descr_flex_context_info;

 

/
