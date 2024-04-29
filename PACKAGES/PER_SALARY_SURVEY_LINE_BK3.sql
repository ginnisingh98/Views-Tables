--------------------------------------------------------
--  DDL for Package PER_SALARY_SURVEY_LINE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SALARY_SURVEY_LINE_BK3" AUTHID CURRENT_USER as
/* $Header: pesslapi.pkh 120.2 2005/11/03 12:14:14 rthiagar noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_salary_survey_line_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_salary_survey_line_b
  (p_salary_survey_line_id         in     number
  ,p_ssl_object_version_number     in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< delete_salary_survey_line_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_salary_survey_line_a
  (p_salary_survey_line_id         in     number
  ,p_ssl_object_version_number     in     number
  );
--
end PER_SALARY_SURVEY_LINE_BK3;

 

/
