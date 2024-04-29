--------------------------------------------------------
--  DDL for Package HR_DESCR_FLEX_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DESCR_FLEX_INFO" 
/* $Header: hrdflinf.pkh 120.0 2005/05/30 23:39:10 appldev noship $ */
AUTHID CURRENT_USER AS
  --
  -- Global Types
  --
  TYPE t_segment IS RECORD
    (column_name                    fnd_columns.column_name%TYPE
    );
  TYPE t_segments IS TABLE OF t_segment;
--
-- -----------------------------------------------------------------------------
-- |-----------------------< default_context_field_name >----------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns the default context field name for a descriptive
--   flexfield.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   Name                           Reqd Type     Description
--   p_application_id               Y    number   Application identifier
--   p_descriptive_flexfield_name   Y    varchar2 Descriptive flexfield name
--   p_field_name_prefix            N    varchar2 Prefix to add to field name
--
-- Post Success
--   The default context field name for the descriptive flexfield is returned.
--
-- Post Failure
--   An error is raised.
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION default_context_field_name
  (p_application_short_name       IN     fnd_application.application_short_name%TYPE
  ,p_descriptive_flexfield_name   IN     fnd_descriptive_flexs.descriptive_flexfield_name%TYPE
  ,p_field_name_prefix            IN     VARCHAR2 DEFAULT NULL
  )
RETURN fnd_descriptive_flexs.default_context_field_name%TYPE;
--
-- -----------------------------------------------------------------------------
-- |---------------------------< context_column_name >-------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns the context column name for a descriptive flexfield.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   Name                           Reqd Type     Description
--   p_application_id               Y    number   Application identifier
--   p_descriptive_flexfield_name   Y    varchar2 Descriptive flexfield name
--   p_field_name_prefix            N    varchar2 Prefix to add to field name
--
-- Post Success
--   The context column name for the descriptive flexfield is returned.
--
-- Post Failure
--   An error is raised.
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION context_column_name
  (p_application_short_name       IN     fnd_application.application_short_name%TYPE
  ,p_descriptive_flexfield_name   IN     fnd_descriptive_flexs.descriptive_flexfield_name%TYPE
  ,p_field_name_prefix            IN     VARCHAR2 DEFAULT NULL
  )
RETURN fnd_descriptive_flexs.context_column_name%TYPE;
--
-- -----------------------------------------------------------------------------
-- |--------------------------------< segments >-------------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns a table containing details of all the columns which
--   are available for use with the descriptive flexfield.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   Name                           Reqd Type     Description
--   p_application_id               Y    number   Application identifier
--   p_descriptive_flexfield_name   Y    varchar2 Descriptive flexfield name
--
-- Post Success
--   A table containg the available columns is returned.
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
  (p_application_id               IN     fnd_descriptive_flexs.application_id%TYPE
  ,p_descriptive_flexfield_name   IN     fnd_descriptive_flexs.descriptive_flexfield_name%TYPE
  )
RETURN t_segments;
--
END hr_descr_flex_info;

 

/
