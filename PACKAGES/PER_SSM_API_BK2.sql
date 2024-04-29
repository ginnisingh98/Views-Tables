--------------------------------------------------------
--  DDL for Package PER_SSM_API_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SSM_API_BK2" AUTHID CURRENT_USER as
/* $Header: pessmapi.pkh 120.1 2005/10/02 02:24:45 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_mapping_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_mapping_b
  (p_effective_date                in     date
  ,p_location_id                   in     number
  ,p_grade_id                      in     number
  ,p_company_organization_id       in     number
  ,p_company_age_code              in     varchar2
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
  ,p_salary_survey_mapping_id      in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_mapping_a >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_mapping_a
  (p_effective_date                in     date
  ,p_location_id                   in     number
  ,p_grade_id                      in     number
  ,p_company_organization_id       in     number
  ,p_company_age_code              in     varchar2
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
  ,p_salary_survey_mapping_id      in     number
  ,p_object_version_number         in     number
  );
--
end per_ssm_api_bk2;

 

/
