--------------------------------------------------------
--  DDL for Package HR_ID_FLEX_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ID_FLEX_INFO" 
/* $Header: hrkflinf.pkh 120.0 2005/05/31 01:06:01 appldev noship $ */
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
-- |--------------------------< defining_column_name >-------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns the defining column for a key flexfield.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   Name                           Reqd Type     Description
--   p_application_short_name       Y    varchar2 Application short name
--   p_id_flex_code                 Y    varchar2 Key flexfield code
--
-- Post Success
--   The defining column name for the key flexfield is returned.
--
-- Post Failure
--   An error is raised.
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION defining_column_name
  (p_application_short_name       IN     fnd_application.application_short_name%TYPE
  ,p_id_flex_code                 IN     fnd_id_flexs.id_flex_code%TYPE
  )
RETURN fnd_id_flexs.set_defining_column_name%TYPE;
--
-- -----------------------------------------------------------------------------
-- |--------------------------------< segments >-------------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns a table containing details of all the columns which
--   are available for use with the key flexfield.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   Name                           Reqd Type     Description
--   p_application_id               Y    number   Application identifier
--   p_id_flex_code                 Y    varchar2 Key flexfield code
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
  (p_application_id               IN     fnd_id_flexs.application_id%TYPE
  ,p_id_flex_code                 IN     fnd_id_flexs.id_flex_code%TYPE
  )
RETURN t_segments;
--
END hr_id_flex_info;

 

/
