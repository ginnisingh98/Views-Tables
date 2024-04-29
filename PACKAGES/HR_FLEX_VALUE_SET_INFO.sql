--------------------------------------------------------
--  DDL for Package HR_FLEX_VALUE_SET_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FLEX_VALUE_SET_INFO" 
/* $Header: hrfvsinf.pkh 120.0.12010000.1 2008/07/28 03:19:41 appldev ship $ */
AUTHID CURRENT_USER AS
  --
  -- Global types
  --
  TYPE t_value_set IS RECORD
    (flex_value_set_id              fnd_flex_value_sets.flex_value_set_id%TYPE
    ,additional_column1_title       VARCHAR2(2000)
    ,additional_column1_width       VARCHAR2(2000)
    ,additional_column2_title       VARCHAR2(2000)
    ,additional_column2_width       VARCHAR2(2000)
    ,additional_column3_title       VARCHAR2(2000)
    ,additional_column3_width       VARCHAR2(2000)
    ,alphanumeric_allowed_flag      fnd_flex_value_sets.alphanumeric_allowed_flag%TYPE
    ,flex_value_set_name            fnd_flex_value_sets.flex_value_set_name%TYPE
    ,format_type                    fnd_flex_value_sets.format_type%TYPE
    ,identification_sql             VARCHAR2(32767)
    ,id_column_type                 VARCHAR2(1)
    ,has_meaning                    BOOLEAN
    ,longlist_flag                  fnd_flex_value_sets.longlist_flag%TYPE
    ,maximum_size                   fnd_flex_value_sets.maximum_size%TYPE
    ,maximum_value                  fnd_flex_value_sets.maximum_value%TYPE
    ,minimum_value                  fnd_flex_value_sets.minimum_value%TYPE
    ,number_precision               fnd_flex_value_sets.number_precision%TYPE
    ,numeric_mode_enabled_flag      fnd_flex_value_sets.numeric_mode_enabled_flag%TYPE
    ,uppercase_only_flag            fnd_flex_value_sets.uppercase_only_flag%TYPE
    ,validation_sql                 VARCHAR2(32767)
    ,validation_type                fnd_flex_value_sets.validation_type%TYPE
    );
--
-- -----------------------------------------------------------------------------
-- |-------------------------------< value_set >-------------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns a record containing the details of a flexfield value
--   set.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   Name                           Reqd Type     Description
--   p_flex_value_set_id            Y    number   Flexfield value set identifier
--   p_effective_date               Y    date     Effective date
--
-- Post Success
--   A record containg the details of a flexfield value set is returned.
--
-- Post Failure
--   An error is raised.
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION value_set
  (p_flex_value_set_id            IN     fnd_flex_value_sets.flex_value_set_id%TYPE
  ,p_effective_date               IN     DATE
  )
RETURN t_value_set;
--
END hr_flex_value_set_info;

/
