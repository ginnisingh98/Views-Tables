--------------------------------------------------------
--  DDL for Package HR_SALARY_SURVEY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SALARY_SURVEY_BK3" AUTHID CURRENT_USER as
/* $Header: pepssapi.pkh 120.1 2005/10/02 02:22:51 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_salary_survey_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_salary_survey_b
  (p_salary_survey_id              in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_salary_survey_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_salary_survey_a
  (p_salary_survey_id              in     number
  ,p_object_version_number         in     number
  );
--
end hr_salary_survey_bk3;

 

/
