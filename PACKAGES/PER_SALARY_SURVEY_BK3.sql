--------------------------------------------------------
--  DDL for Package PER_SALARY_SURVEY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SALARY_SURVEY_BK3" AUTHID CURRENT_USER as
/* $Header: pepssapi.pkh 115.2 99/10/11 08:29:59 porting ship  $ */
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
end per_salary_survey_bk3;

 

/
