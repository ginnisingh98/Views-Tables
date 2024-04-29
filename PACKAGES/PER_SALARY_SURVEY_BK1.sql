--------------------------------------------------------
--  DDL for Package PER_SALARY_SURVEY_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SALARY_SURVEY_BK1" AUTHID CURRENT_USER as
/* $Header: pepssapi.pkh 115.2 99/10/11 08:29:59 porting ship  $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_salary_survey_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_salary_survey_b
  (p_survey_name                   in     varchar2
  ,p_survey_company_code           in     varchar2
  ,p_identifier                    in     varchar2
--ras  ,p_currency_code                 in     varchar2
  ,p_survey_type_code              in     varchar2
  ,p_base_region                   in     varchar2
  ,p_effective_date                in     date
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_salary_survey_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_salary_survey_a
  (p_survey_name                   in     varchar2
  ,p_survey_company_code           in     varchar2
  ,p_identifier                    in     varchar2
--ras  ,p_currency_code                 in     varchar2
  ,p_survey_type_code              in     varchar2
  ,p_base_region                   in     varchar2
  ,p_effective_date                in     date
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_salary_survey_id              in     number
  ,p_object_version_number         in     number
  );
--
end per_salary_survey_bk1;

 

/
